/**
 * @file slub.c
 * @brief 简化版SLUB分配器实现 - Simplified SLUB Allocator Implementation
 * 
 * SLUB (Simplified Linux Unified Buffer) 是Linux内核中用于小对象分配的高效内存分配器。
 * 本实现提供了SLUB分配器的简化版本，主要特性包括：
 * 
 * 设计特点：
 * - 两层设计：小对象使用固定大小类别，大对象直接分配页面
 * - 嵌入式空闲链表：在空闲对象本身存储下一个空闲对象的指针
 * - 部分空闲和全满页面的分离管理
 * - 快速分配和释放机制
 * 
 * 算法优势：
 * - 快速分配：O(1)时间复杂度
 * - 减少外部碎片：使用固定大小类别
 * - 高效的空间利用：嵌入式空闲链表
 * - 支持大小对象的统一接口
 * 
 * 主要函数：
 * - slub_init(): 初始化缓存结构
 * - kmalloc(size): 分配size字节的内存
 * - kfree(ptr): 释放指针指向的内存
 * - slub_check(): 基本功能测试
 * 
 * Function: Simplified SLUB allocator
 * -----------------------------------
 * Two-layer design with power-of-two size classes; freelist is embedded.
 * slub_init(): initialize caches
 * kmalloc(size): allocate size bytes
 * kfree(ptr): free pointer
 * slub_check(): basic tests
 */

#include <slub.h>
#include <pmm.h>
#include <string.h>
#include <stdio.h>

/**
 * @struct slab_page
 * @brief SLAB页面描述符 - SLAB page descriptor
 * 
 * 每个SLAB页面用于管理固定大小对象的分配，包含空闲链表和使用统计信息。
 */
typedef struct slab_page {
    struct Page *page;              // 指向物理页面的指针 - Pointer to physical page
    void *free_head;                // 空闲对象链表头 - Head of free object list
    unsigned int inuse;             // 已使用对象数量 - Number of objects in use
    unsigned int capacity;          // 页面可容纳的对象总数 - Total object capacity
    struct slab_page *next;         // 链表中的下一个SLAB页面 - Next SLAB page in list
} slab_page_t;

/**
 * @struct kmem_cache_t
 * @brief 内存缓存结构 - Kernel memory cache structure
 * 
 * 每个大小类别对应一个缓存，管理该大小的对象分配。
 * 使用部分空闲(partial)和全满(full)两个链表来提高分配效率。
 */
typedef struct {
    size_t object_size;             // 对象大小 - Size of objects in this cache
    slab_page_t *partial;           // 部分空闲的SLAB页面链表 - List of partially free SLAB pages
    slab_page_t *full;              // 全满的SLAB页面链表 - List of full SLAB pages
} kmem_cache_t;

/* SLUB配置参数 - SLUB configuration parameters */
#define SLUB_NUM_CLASSES 8                      // 支持的大小类别数 - Number of size classes
static kmem_cache_t caches[SLUB_NUM_CLASSES];   // 各个大小类别的缓存数组 - Cache array for each size class

/* 预定义的对象大小类别 (字节) - Predefined object size classes (bytes) */
static const size_t class_sizes[SLUB_NUM_CLASSES] = {16, 32, 64, 128, 256, 512, 1024, 2048};

/**
 * @struct large_hdr
 * @brief 大对象头部结构 - Large object header structure
 * 
 * 对于超过最大size class的大对象，直接分配页面，并在开头存储此头部信息用于释放。
 */
typedef struct large_hdr {
    uint32_t magic;                 // 魔数，用于验证头部有效性 - Magic number for header validation
    uint32_t pages;                 // 分配的页面数 - Number of allocated pages
    struct Page *page;              // 指向起始物理页面 - Pointer to starting physical page
} large_hdr_t;

#define LARGE_MAGIC 0x4C52474C       // 大对象魔数 "LRGL" - Large object magic number "LRGL"

/* SLAB页面描述符池 - SLAB page descriptor pool */
#define SLUB_SP_MAX 256                         // SLAB页面描述符池的最大容量 - Maximum SLAB page descriptor pool size
static slab_page_t sp_pool[SLUB_SP_MAX];       // SLAB页面描述符池 - SLAB page descriptor pool
static int sp_freelist_head = -1;              // 空闲描述符链表头索引 - Head index of free descriptor list

/**
 * @brief 分配SLAB页面描述符 - Allocate SLAB page descriptor
 * 
 * 从描述符池中分配一个空闲的slab_page_t结构。
 * 
 * @return 成功返回描述符指针，失败返回NULL
 */
static slab_page_t *alloc_sp(void) {
    if (sp_freelist_head < 0) return NULL;          // 池已空 - Pool is empty
    int idx = sp_freelist_head;                     // 获取头部索引 - Get head index
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;  // 更新链表头 - Update list head
    sp_pool[idx].next = NULL;                       // 清空next指针 - Clear next pointer
    return &sp_pool[idx];                           // 返回描述符 - Return descriptor
}

/**
 * @brief 释放SLAB页面描述符 - Free SLAB page descriptor
 * 
 * 将使用完的slab_page_t结构返回到描述符池。
 * 
 * @param sp 要释放的SLAB页面描述符
 */
static void free_sp(slab_page_t *sp) {
    int idx = (int)(sp - sp_pool);                  // 计算描述符在池中的索引 - Calculate descriptor index in pool
    sp->next = (slab_page_t *)(uintptr_t)sp_freelist_head;  // 链接到空闲链表 - Link to free list
    sp_freelist_head = idx;                         // 更新链表头 - Update list head
}

/**
 * @brief 向上对齐 - Align up to boundary
 * 
 * 将数值向上对齐到指定边界。边界必须是2的幂。
 * 
 * @param x 要对齐的数值
 * @param a 对齐边界
 * @return 对齐后的数值
 */
static inline size_t align_up(size_t x, size_t a) {
    return (x + a - 1) & ~(a - 1);
}

/**
 * @brief 选择合适的缓存 - Pick appropriate cache
 * 
 * 根据请求的大小选择合适的大小类别。如果没有合适的类别，返回-1表示需要大对象分配。
 * 
 * @param size 请求分配的大小
 * @return 缓存索引，-1表示需要大对象分配
 */
static int pick_cache(size_t size) {
    // 确保大小至少为指针大小（用于空闲链表） - Ensure size is at least pointer size (for free list)
    size = size < sizeof(void*) ? sizeof(void*) : size;
    
    // 查找最小的满足要求的大小类别 - Find smallest size class that satisfies requirement
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        if (class_sizes[i] >= size) return i;
    }
    return -1;  // 需要大对象分配 - Need large object allocation
}

/**
 * @brief 创建新的SLAB页面 - Create new SLAB page
 * 
 * 分配一个物理页面并初始化为SLAB页面，将页面中的对象组织成空闲链表。
 * 使用嵌入式链表设计：在每个空闲对象的开头存储指向下一个空闲对象的指针。
 * 
 * @param cache 目标缓存
 * @return 成功返回新创建的SLAB页面描述符，失败返回NULL
 */
static slab_page_t *new_slab_page(kmem_cache_t *cache) {
    // 分配一个物理页面 - Allocate one physical page
    struct Page *pg = alloc_page();
    if (pg == NULL) return NULL;
    
    // 将物理地址转换为内核虚拟地址 - Convert physical address to kernel virtual address
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
    size_t obj_size = cache->object_size;
    size_t objs = PGSIZE / obj_size;                // 计算页面可容纳的对象数 - Calculate objects per page
    
    if (objs == 0) {
        free_page(pg);
        return NULL;
    }
    
    // 构建嵌入式空闲链表 - Build embedded free list
    // 从后往前链接，使得第一个对象成为链表头 - Link from back to front so first object becomes head
    void *head = NULL;
    for (size_t i = 0; i < objs; i++) {
        void **slot = (void **)((char *)mem + i * obj_size);    // 当前对象位置 - Current object location
        *slot = head;                               // 在对象开头存储下一个空闲对象指针 - Store next free object pointer at object start
        head = slot;                                // 更新链表头 - Update list head
    }
    
    // 分配SLAB页面描述符 - Allocate SLAB page descriptor
    slab_page_t *sp = alloc_sp();
    if (sp == NULL) {
        free_page(pg);
        return NULL;
    }
    
    // 初始化SLAB页面描述符 - Initialize SLAB page descriptor
    sp->page = pg;                                  // 关联物理页面 - Associate physical page
    sp->free_head = head;                          // 设置空闲链表头 - Set free list head
    sp->inuse = 0;                                 // 初始时无对象被使用 - Initially no objects in use
    sp->capacity = (unsigned int)objs;             // 设置容量 - Set capacity
    sp->next = cache->partial;                     // 插入到部分空闲链表 - Insert into partial list
    cache->partial = sp;
    
    return sp;
}

/**
 * @brief 初始化SLUB分配器 - Initialize SLUB allocator
 * 
 * 初始化SLAB页面描述符池和所有大小类别的缓存结构。
 * 这个函数必须在使用kmalloc之前调用。
 */
void slub_init(void) {
    // 初始化SLAB页面描述符池的空闲链表 - Initialize free list of SLAB page descriptor pool
    sp_freelist_head = -1;
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
        // 将索引作为指针存储在next字段中构建空闲链表 - Store index as pointer in next field to build free list
        sp_pool[i].next = (slab_page_t *)(uintptr_t)sp_freelist_head;
        sp_freelist_head = i;
    }
    
    // 初始化所有大小类别的缓存 - Initialize caches for all size classes
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        caches[i].object_size = class_sizes[i];     // 设置对象大小 - Set object size
        caches[i].partial = NULL;                   // 初始时无部分空闲页面 - Initially no partial pages
        caches[i].full = NULL;                      // 初始时无全满页面 - Initially no full pages
    }
}

/**
 * @brief 分配内存 - Allocate memory
 * 
 * 根据请求大小分配内存。小对象使用SLAB分配器，大对象直接分配页面。
 * 
 * 分配策略：
 * - size <= 2048字节：使用对应的大小类别进行SLAB分配
 * - size > 2048字节：直接分配页面，并在开头存储large_hdr信息
 * 
 * @param size 请求分配的字节数
 * @return 成功返回内存指针，失败返回NULL
 */
void *kmalloc(size_t size) {
    int idx = pick_cache(size);
    
    if (idx < 0) {
        // 大对象分配：直接分配页面 - Large object allocation: allocate pages directly
        size_t bytes = align_up(size + sizeof(large_hdr_t), PGSIZE);  // 包含头部信息 - Include header info
        size_t pages_need = bytes / PGSIZE;
        struct Page *pg = alloc_pages(pages_need);
        if (pg == NULL) return NULL;
        
        // 转换为内核虚拟地址 - Convert to kernel virtual address
        void *kva = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
        
        // 在开头构造large_hdr - Construct large_hdr at the beginning
        large_hdr_t *hdr = (large_hdr_t *)kva;
        hdr->magic = LARGE_MAGIC;               // 设置魔数 - Set magic number
        hdr->pages = (uint32_t)pages_need;      // 记录页面数 - Record page count
        hdr->page = pg;                         // 记录起始页面 - Record starting page
        
        // 返回头部之后的地址给用户 - Return address after header to user
        return (void *)((char *)kva + sizeof(large_hdr_t));
    }
    
    // 小对象分配：使用SLAB分配器 - Small object allocation: use SLAB allocator
    kmem_cache_t *cache = &caches[idx];
    
    // 如果没有部分空闲页面，创建新页面 - If no partial pages, create new page
    if (cache->partial == NULL) {
        if (new_slab_page(cache) == NULL) return NULL;
    }
    
    slab_page_t *sp = cache->partial;
    void *obj = sp->free_head;
    
    // 检查空闲链表是否为空（理论上不应该发生） - Check if free list is empty (should not happen)
    if (obj == NULL) {
        // 将页面移到全满链表，然后重试 - Move page to full list and retry
        cache->partial = sp->next;
        sp->next = cache->full;
        cache->full = sp;
        return kmalloc(size);  // 递归重试 - Recursive retry
    }
    
    // 从空闲链表中取出对象 - Take object from free list
    sp->free_head = *(void **)obj;              // 更新空闲链表头 - Update free list head
    sp->inuse++;                                // 增加使用计数 - Increment usage count
    
    // 如果页面已满，移动到全满链表 - If page is full, move to full list
    if (sp->inuse == sp->capacity) {
        cache->partial = sp->next;
        sp->next = cache->full;
        cache->full = sp;
    }
    
    return obj;
}

/**
 * @brief 在链表中释放对象 - Free object in list
 * 
 * 在指定的SLAB页面链表中查找并释放对象。如果找到对应的页面，
 * 将对象添加到空闲链表，并根据使用情况调整页面在不同链表间的位置。
 * 
 * @param list_head 链表头指针的地址
 * @param cache     目标缓存
 * @param ptr       要释放的对象指针
 * @return 找到并释放返回1，未找到返回0
 */
static int free_in_list(slab_page_t **list_head, kmem_cache_t *cache, void *ptr) {
    // 遍历链表寻找包含该地址的页面 - Traverse list to find page containing the address
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;    // 页面起始虚拟地址 - Page start virtual address
        uintptr_t end  = base + PGSIZE;                                 // 页面结束虚拟地址 - Page end virtual address
        
        // 检查地址是否在此页面范围内 - Check if address is within this page range
        if ((uintptr_t)ptr >= base && (uintptr_t)ptr < end) {
            // 将对象添加到空闲链表头部 - Add object to head of free list
            *(void **)ptr = sp->free_head;              // 在对象开头存储原链表头 - Store original list head at object start
            sp->free_head = ptr;                        // 更新链表头为当前对象 - Update list head to current object
            if (sp->inuse > 0) sp->inuse--;             // 减少使用计数 - Decrease usage count
            
            // 如果是从全满链表释放，且页面不再满，移动到部分空闲链表
            // If freeing from full list and page is no longer full, move to partial list
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
                // 从全满链表中移除 - Remove from full list
                if (prev) prev->next = sp->next; 
                else *list_head = sp->next;
                
                // 添加到部分空闲链表 - Add to partial list
                sp->next = cache->partial;
                cache->partial = sp;
            }
            
            // 如果页面完全空闲，释放页面和描述符 - If page is completely free, release page and descriptor
            if (sp->inuse == 0 && sp->capacity > 0) {
                if (list_head == &cache->partial) {
                    // 从部分空闲链表中移除 - Remove from partial list
                    if (prev) prev->next = sp->next; 
                    else *list_head = sp->next;
                }
                free_page(sp->page);                    // 释放物理页面 - Free physical page
                free_sp(sp);                            // 释放页面描述符 - Free page descriptor
            }
            return 1;  // 成功释放 - Successfully freed
        }
    }
    return 0;  // 未找到 - Not found
}

/**
 * @brief 释放内存 - Free memory
 * 
 * 释放由kmalloc分配的内存。自动识别小对象和大对象进行相应的释放操作。
 * 
 * 释放策略：
 * - 首先在所有SLAB缓存中查找该地址
 * - 如果在SLAB中找到，按SLAB规则释放
 * - 如果不在SLAB中，尝试作为大对象释放
 * 
 * @param ptr 要释放的内存指针，允许为NULL
 */
void kfree(void *ptr) {
    if (ptr == NULL) return;  // 允许释放NULL指针 - Allow freeing NULL pointer
    
    // 尝试在所有SLAB缓存中释放 - Try to free in all SLAB caches
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        // 先尝试部分空闲链表 - Try partial list first
        if (free_in_list(&caches[i].partial, &caches[i], ptr)) return;
        
        // 再尝试全满链表 - Then try full list
        if (free_in_list(&caches[i].full, &caches[i], ptr)) return;
    }
    
    // 如果不在SLAB中，尝试作为大对象释放 - If not in SLAB, try to free as large object
    large_hdr_t *hdr = (large_hdr_t *)((char *)ptr - sizeof(large_hdr_t));
    
    // 验证大对象头部的有效性 - Validate large object header
    if (hdr->magic == LARGE_MAGIC && hdr->page != NULL && hdr->pages > 0) {
        free_pages(hdr->page, hdr->pages);      // 释放页面 - Free pages
    }
    // 注意：如果既不是SLAB对象也不是有效的大对象，则可能是无效指针，此处选择静默忽略
    // Note: If neither SLAB object nor valid large object, might be invalid pointer, silently ignore here
}

/**
 * @brief SLUB分配器自检 - SLUB allocator self-check
 * 
 * 执行基本的分配和释放测试，验证SLUB分配器的正确性。
 * 测试包括不同大小的对象分配和释放。
 */
void slub_check(void) {
    // 测试不同大小的分配 - Test allocation of different sizes
    void *a = kmalloc(24);      // 小对象，应使用32字节类别 - Small object, should use 32-byte class
    void *b = kmalloc(200);     // 中等对象，应使用256字节类别 - Medium object, should use 256-byte class
    void *c = kmalloc(1024);    // 大对象，应使用1024字节类别 - Large object, should use 1024-byte class
    
    // 验证分配成功 - Verify allocation success
    assert(a != NULL && b != NULL && c != NULL);
    
    // 测试释放 - Test freeing
    kfree(a);
    kfree(b); 
    kfree(c);
    
    // 注意：这是一个基础测试，实际使用中可能需要更全面的测试
    // Note: This is a basic test, actual usage might need more comprehensive testing
}


