#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/**
 * @file default_pmm.c
 * @brief 默认物理内存管理器 - 首次适应算法 (First Fit Algorithm)
 * 
 * 在首次适应算法中，分配器维护一个空闲块链表（称为空闲链表），当接收到内存请求时，
 * 沿着链表扫描，找到第一个足够大的块来满足请求。如果所选择的块比请求的块大很多，
 * 通常会将其分割，剩余部分作为另一个空闲块加入到链表中。
 * 
 * In the first fit algorithm, the allocator keeps a list of free blocks (known as the free list) and,
 * on receiving a request for memory, scans along the list for the first block that is large enough to
 * satisfy the request. If the chosen block is significantly larger than that requested, then it is 
 * usually split, and the remainder added to the list as another free block.
 * Please see Page 196~198, Section 8.2 of Yan Wei Min's chinese book "Data Structure -- C programming language"
 */
/**
 * @brief 首次适应内存分配算法(FFMA)实现详解
 * 
 * LAB2 EXERCISE 1: 需要重写以下函数: default_init, default_init_memmap, default_alloc_pages, default_free_pages.
 * 
 * 首次适应内存分配(FFMA)算法实现细节：
 * 
 * (1) 准备工作：为了实现首次适应内存分配(FFMA)，我们需要使用链表来管理空闲内存块。
 *     - free_area_t结构用于管理空闲内存块
 *     - 需要熟悉list.h中的双向链表实现，掌握以下操作：
 *       list_init, list_add(list_add_after), list_add_before, list_del, list_next, list_prev
 *     - 需要了解从通用链表结构转换为特定结构的方法：
 *       le2page宏 (在memlayout.h中定义)
 * 
 * (2) default_init: 初始化空闲链表并将nr_free设为0
 *     - free_list用于记录空闲内存块
 *     - nr_free是空闲内存块的总数
 * 
 * (3) default_init_memmap: 初始化一个空闲块
 *     调用图：kern_init --> pmm_init --> page_init --> init_memmap --> pmm_manager->init_memmap
 *     - 初始化空闲块中的每个页面，包括：
 *       * p->flags应设置PG_property位（表示该页面有效）
 *       * 如果页面空闲且不是空闲块的第一个页面，p->property应设为0
 *       * 如果页面空闲且是空闲块的第一个页面，p->property应设为块的总页数
 *       * p->ref应设为0（因为现在页面空闲且无引用）
 *     - 使用p->page_link将页面链接到free_list
 *     - 最后增加空闲内存块数量：nr_free += n
 * 
 * (4) default_alloc_pages: 在空闲链表中查找第一个大小>=n的空闲块并调整空闲块大小
 *     - 搜索空闲链表找到合适的块
 *     - 如果找到合适的块，分配前n个页面
 *     - 如果块大小>n，需要重新计算剩余空闲块的大小
 *     - 更新nr_free计数
 * 
 * (5) default_free_pages: 将页面重新链接到空闲链表，可能合并小的空闲块为大的空闲块
 *     - 根据基地址在空闲链表中找到正确位置（从低地址到高地址）插入页面
 *     - 重置页面字段，如p->ref, p->flags (PageProperty)
 *     - 尝试合并低地址或高地址的块，注意正确更新页面的p->property
 */
/* 全局空闲区域管理结构 - Global free area management structure */
static free_area_t free_area;

/* 便捷访问宏 - Convenience access macros */
#define free_list (free_area.free_list)    // 空闲链表 - Free list
#define nr_free (free_area.nr_free)        // 空闲页数 - Number of free pages

/**
 * @brief 初始化默认内存管理器 - Initialize default memory manager
 * 
 * 初始化空闲链表并清零空闲页计数。
 * Initialize the free list and reset free page counter to zero.
 */
static void
default_init(void) {
    list_init(&free_list);              // 初始化空闲链表 - Initialize free list
    nr_free = 0;                        // 清零空闲页数 - Reset free page count
}

/**
 * @brief 初始化内存映射 - Initialize memory mapping
 * 
 * 将一个连续的页面区域[base, base+n)初始化为空闲状态并加入空闲链表。
 * 空闲链表按地址从低到高排序。
 * 
 * @param base 页面区域的起始页面
 * @param n    页面数量
 */
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    
    // 初始化区域内的每个页面 - Initialize each page in the region
    for (; p != base + n; p ++) {
        assert(PageReserved(p));        // 确保页面之前是保留状态 - Ensure page was reserved
        p->flags = p->property = 0;     // 清空标志和属性 - Clear flags and property
        set_page_ref(p, 0);             // 设置引用计数为0 - Set reference count to 0
    }
    
    // 设置头页面属性 - Set head page property
    base->property = n;                 // 头页面记录整个块的大小 - Head page records the size of entire block
    SetPageProperty(base);              // 设置页面属性标志 - Set page property flag
    nr_free += n;                       // 增加空闲页计数 - Increment free page count
    
    // 将块插入空闲链表（按地址排序）- Insert block into free list (sorted by address)
    if (list_empty(&free_list)) {
        // 空闲链表为空，直接添加 - Free list is empty, add directly
        list_add(&free_list, &(base->page_link));
    } else {
        // 找到合适位置插入（保持地址升序）- Find appropriate position to insert (maintain ascending order)
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                // 找到第一个地址比base大的页面，在其前面插入
                // Found first page with address > base, insert before it
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                // 已到链表末尾，在末尾添加
                // Reached end of list, add at the end
                list_add(le, &(base->page_link));
            }
        }
    }
}

/**
 * @brief 分配页面 - Allocate pages (First Fit Algorithm)
 * 
 * 使用首次适应算法分配n个连续的页面。遍历空闲链表，找到第一个
 * 大小>=n的空闲块，如果块大小>n则进行分割。
 * 
 * @param n 需要分配的页面数
 * @return 分配的页面起始地址，失败返回NULL
 */
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    
    // 检查是否有足够的空闲页面 - Check if there are enough free pages
    if (n > nr_free) {
        return NULL;
    }
    
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    
    // 遍历空闲链表寻找第一个适合的块 - Traverse free list to find first suitable block
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            // 找到第一个满足大小要求的块 - Found first block that satisfies size requirement
            page = p;
            break;
        }
    }
    
    if (page != NULL) {
        // 记录前一个节点位置，用于可能的分割插入 - Record previous node for potential split insertion
        list_entry_t* prev = list_prev(&(page->page_link));
        
        // 从空闲链表中移除该块 - Remove the block from free list
        list_del(&(page->page_link));
        
        if (page->property > n) {
            // 块大小大于需求，需要分割 - Block is larger than needed, split it
            struct Page *p = page + n;          // 剩余部分的起始页面 - Start of remaining part
            p->property = page->property - n;   // 设置剩余部分的大小 - Set size of remaining part
            SetPageProperty(p);                 // 设置剩余部分为空闲块头 - Mark remaining part as free block head
            list_add(prev, &(p->page_link));    // 将剩余部分插入空闲链表 - Insert remaining part into free list
        }
        
        nr_free -= n;                           // 减少空闲页计数 - Decrease free page count
        ClearPageProperty(page);                // 清除分配页面的属性标志 - Clear property flag of allocated pages
    }
    return page;
}

/**
 * @brief 释放页面 - Free pages
 * 
 * 释放n个连续页面并尝试与相邻的空闲块合并。释放的页面会按地址
 * 顺序插入空闲链表，然后检查前后相邻块进行合并操作。
 * 
 * @param base 要释放的页面区域起始地址
 * @param n    要释放的页面数量
 */
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    
    // 重置要释放的页面状态 - Reset state of pages to be freed
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面可以被释放 - Ensure pages can be freed
        p->flags = 0;                                 // 清空标志位 - Clear flag bits
        set_page_ref(p, 0);                          // 清空引用计数 - Clear reference count
    }
    
    // 设置空闲块的头页面信息 - Set up head page of free block
    base->property = n;                              // 记录块大小 - Record block size
    SetPageProperty(base);                           // 设置属性标志 - Set property flag
    
     += n;                                    // 增加空闲页计数 - Increment free page count

    // 将释放的块按地址顺序插入空闲链表 - Insert freed block into free list in address order
    if (list_empty(&free_list)) {
        // 空闲链表为空，直接添加 - Free list is empty, add directly
        list_add(&free_list, &(base->page_link));
    } else {
        // 找到合适位置插入（保持地址升序）- Find appropriate position to insert (maintain ascending order)
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    // 尝试向前合并 - Try to merge with previous block
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            // 前面的块与当前块相邻，进行合并 - Previous block is adjacent, merge them
            p->property += base->property;      // 合并块大小 - Merge block sizes
            ClearPageProperty(base);            // 清除当前块的头标志 - Clear head flag of current block
            list_del(&(base->page_link));       // 从链表中移除当前块 - Remove current block from list
            base = p;                           // 更新base指针 - Update base pointer
        }
    }

    // 尝试向后合并 - Try to merge with next block
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            // 后面的块与当前块相邻，进行合并 - Next block is adjacent, merge them
            base->property += p->property;      // 合并块大小 - Merge block sizes
            ClearPageProperty(p);               // 清除后面块的头标志 - Clear head flag of next block
            list_del(&(p->page_link));          // 从链表中移除后面的块 - Remove next block from list
        }
    }
}

/**
 * @brief 获取空闲页面数量 - Get number of free pages
 * 
 * @return 当前空闲页面的总数
 */
static size_t
default_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

