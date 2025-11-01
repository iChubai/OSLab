#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_pmm.h>

/**
 * @file buddy_pmm.c
 * @brief 伙伴系统物理内存管理器 - Buddy System Physical Memory Manager
 * 
 * 伙伴系统是一种经典的内存分配算法，它将内存按2的幂次分割和合并。
 * 
 * 伙伴系统基本原理：
 * - 将内存按2的幂次大小(2^0, 2^1, 2^2, ... 2^n个页面)分成不同级别(order)的块
 * - 每个级别维护一个空闲链表，记录该级别的所有空闲块
 * - 分配时找到满足要求的最小级别，如果该级别没有空闲块则分割更大的块
 * - 释放时尝试与伙伴块合并，形成更大的块以减少外部碎片
 * 
 * 伙伴块的定义：两个相同大小的块，它们的起始地址相差一个块大小，且较小地址的块
 * 的起始地址能被(块大小*2)整除。例如，大小为4页的块0和块4是伙伴关系。
 * 
 * 算法优点：
 * - 快速分配和释放(对数时间复杂度)
 * - 有效减少外部碎片
 * - 支持高效的块合并
 * 
 * 算法缺点：
 * - 只能分配2的幂次大小的块，可能造成内部碎片
 * - 实现相对复杂
 * 
 * 主要函数说明：
 * - buddy_init(): 初始化内部数据结构
 * - buddy_init_memmap(base, n): 将连续区域[base, base+n)加入伙伴系统作为空闲块
 * - buddy_alloc_pages(n): 分配n个连续页面，返回基地址或NULL
 * - buddy_free_pages(base, n): 释放从base开始的n个连续页面
 * - buddy_nr_free_pages(): 返回总的空闲页面数
 * - buddy_check(): 自检正确性(分配、释放、合并、分割)
 * 
 * Function: Buddy-based physical page allocator
 * ---------------------------------------------
 * Implements a classic buddy allocator on page granularity.
 * - Manages free blocks in orders, each block size = (1 << order) pages
 * - Uses per-order free lists; head page of a free block has PG_property=1
 * - Stores the order in Page.property for the head page
 * - Allocates exactly n contiguous pages by carving a prefix from a larger buddy block and
 *   returning the first n pages; the remaining suffix is reinserted into free lists with merging
 * - Frees a contiguous n-page region by splitting into maximal aligned buddy blocks and merging
 */

/* 伙伴系统最大阶数 - Maximum order for buddy system */
#define BUDDY_MAX_ORDER  18                    // 支持最大2^18 = 256K个页面的块

/**
 * @struct buddy_area_t
 * @brief 伙伴系统区域结构 - Buddy area structure
 * 
 * 每个order级别的空闲块管理结构，包含该级别的空闲链表和空闲页面计数
 */
typedef struct {
    list_entry_t free_list;                    // 该order级别的空闲链表 - Free list for this order
    unsigned int nr_free;                      // 该order级别的空闲页面总数 - Total free pages in this order
} buddy_area_t;

/* 伙伴系统全局数据结构 - Global buddy system data structures */
static buddy_area_t buddy_area[BUDDY_MAX_ORDER + 1];  // 每个order级别的管理结构数组
static size_t buddy_total_free = 0;                   // 系统总空闲页面数 - Total free pages in system

/* 便捷访问宏 - Convenience access macros */
#define order_free_list(order) (buddy_area[(order)].free_list)  // 获取指定order的空闲链表
#define order_nr_free(order)   (buddy_area[(order)].nr_free)    // 获取指定order的空闲页数

/* 内联辅助函数 - Inline helper functions */
static inline size_t page_index(struct Page *p) { 
    return (size_t)(p - pages);                        // 计算页面在页面数组中的索引 - Calculate page index in page array
}

static inline struct Page *index_to_page(size_t idx) { 
    return pages + idx;                               // 根据索引获取页面指针 - Get page pointer from index
}

static inline size_t order_block_pages(size_t order) { 
    return ((size_t)1u << order);                     // 计算指定order对应的页面数 = 2^order
}

/* 伙伴系统函数声明 - Buddy system function declarations */
static void buddy_init(void);                        // 初始化伙伴系统 - Initialize buddy system
static void buddy_init_memmap(struct Page *base, size_t n);  // 初始化内存映射 - Initialize memory mapping
static struct Page *buddy_alloc_pages(size_t n);     // 分配页面 - Allocate pages
static void buddy_free_pages(struct Page *base, size_t n);   // 释放页面 - Free pages
static size_t buddy_nr_free_pages(void);             // 获取空闲页数 - Get free page count
static void buddy_check(void);                       // 自检函数 - Self-check function

/*
 * Function: try_coalesce_and_insert
 * ---------------------------------
 * Merge a free block with its buddy iteratively, then insert into the final order list.
 * Inputs: base - head page of the block, order - current order of the block
 * Effects: updates per-order and total counters appropriately
 */
static void try_coalesce_and_insert(struct Page *base, unsigned int order) {
    size_t idx = page_index(base);                  // 获取当前块的页面索引 - Get current block's page index
    
    // 向上合并循环 - Upward merging loop
    while (order < BUDDY_MAX_ORDER) {
        // 计算伙伴块的索引：当前索引异或块大小 - Calculate buddy block index: current index XOR block size
        size_t buddy_idx = idx ^ order_block_pages(order);
        struct Page *buddy_head = index_to_page(buddy_idx);
        
        // 检查伙伴块是否空闲且order相同 - Check if buddy block is free and has same order
        if (PageProperty(buddy_head) && buddy_head->property == order) {
            // 伙伴块可以合并 - Buddy block can be merged
            list_del(&(buddy_head->page_link));                    // 从链表中移除伙伴块 - Remove buddy from list
            order_nr_free(order) -= order_block_pages(order);      // 减少当前order的页面计数 - Decrease page count for current order
            ClearPageProperty(buddy_head);                         // 清除伙伴块的属性 - Clear buddy's property
            buddy_head->property = 0;                              // 重置伙伴块的属性值 - Reset buddy's property value
            
            // 选择较小地址作为合并后块的起始地址 - Choose smaller address as start of merged block
            if (buddy_idx < idx) {
                base = buddy_head;
                idx = buddy_idx;
            }
            order++;                                               // 提升到下一个order级别 - Promote to next order level
            continue;                                              // 继续尝试更高级别的合并 - Continue trying higher level merging
        }
        break;                                                     // 无法合并，退出循环 - Cannot merge, exit loop
    }
    
    // 设置最终块的属性并插入对应链表 - Set final block properties and insert into corresponding list
    base->property = order;                                        // 设置块的order - Set block's order
    SetPageProperty(base);                                         // 设置属性标志 - Set property flag
    list_add(&order_free_list(order), &(base->page_link));        // 插入到对应order的链表 - Insert into corresponding order list
    order_nr_free(order) += order_block_pages(order);             // 增加该order的页面计数 - Increase page count for this order
}

/**
 * @brief 插入区域到伙伴系统 - Insert region into buddy system
 * 
 * 将一个连续区域[base, base+n)插入伙伴系统的空闲链表中。
 * 使用贪心策略将区域分割为最大的对齐块，然后向上合并。
 * 
 * 算法策略：
 * 1. 从当前位置开始，找到能容纳的最大对齐块大小
 * 2. 将该块插入伙伴系统并尝试合并
 * 3. 移动到下一个位置，重复步骤1-2，直到处理完整个区域
 * 
 * Function: insert_region
 * -----------------------
 * Insert and merge a contiguous region [base, base+n) into buddy free lists.
 * Greedy split into maximal aligned blocks at each step, then coalesce upward.
 * 
 * @param base 区域起始页面 - Start page of region
 * @param n    区域页面数 - Number of pages in region
 */
static void insert_region(struct Page *base, size_t n) {
    size_t idx = page_index(base);              // 获取起始页面索引 - Get start page index
    
    while (n > 0) {
        unsigned int order = 0;                 // 当前尝试的order级别 - Current trying order level
        size_t max_fit = 1;                     // 当前能容纳的最大块大小 - Max block size that can fit
        
        // 寻找最大的对齐块 - Find maximal aligned block
        while (order < BUDDY_MAX_ORDER) {
            size_t blk = order_block_pages(order + 1);  // 下一个order的块大小 - Next order's block size
            if (blk > n) break;                         // 块大小超过剩余页面数 - Block size exceeds remaining pages
            if ((idx & (blk - 1)) != 0) break;          // 地址不对齐 - Address not aligned
            order++;                                    // 提升order级别 - Promote order level
            max_fit = blk;                              // 更新最大容纳大小 - Update max fit size
        }
        
        // 插入当前块并尝试合并 - Insert current block and try to merge
        try_coalesce_and_insert(index_to_page(idx), order);
        idx += max_fit;                         // 移动到下一个位置 - Move to next position
        n   -= max_fit;                         // 减少剩余页面数 - Decrease remaining pages
    }
}

/**
 * @brief 将剩余部分作为空闲块返回 - Return suffix as free block
 * 
 * 从块[base, base+s)中分配前缀[base, base+n)后，将后缀[base+n, base+s)
 * 作为空闲块返回给伙伴系统。这是分割大块时的关键操作。
 * 
 * Function: carve_suffix_as_free
 * ------------------------------
 * After allocating a prefix [base, base+n) from a block [base, base+s),
 * return the suffix [base+n, base+s) back to the buddy system as free.
 * 
 * @param base 原始块的起始页面 - Start page of original block
 * @param n    已分配的页面数 - Number of allocated pages
 * @param s    原始块的总页面数 - Total pages in original block
 */
static void carve_suffix_as_free(struct Page *base, size_t n, size_t s) {
    if (n < s) {
        struct Page *suffix = base + n;         // 剩余部分的起始页面 - Start page of suffix
        size_t suffix_pages = s - n;            // 剩余页面数 - Number of suffix pages
        insert_region(suffix, suffix_pages);    // 将剩余部分插入伙伴系统 - Insert suffix into buddy system
    }
}

/**
 * @brief 初始化伙伴系统 - Initialize buddy system
 * 
 * 初始化所有order级别的空闲链表和计数器。
 */
static void buddy_init(void) {
    // 初始化所有order级别的数据结构 - Initialize data structures for all order levels
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));         // 初始化空闲链表 - Initialize free list
        order_nr_free(i) = 0;                   // 清零页面计数 - Reset page count
    }
    buddy_total_free = 0;                       // 清零总空闲页面数 - Reset total free pages
}

/**
 * @brief 初始化内存映射 - Initialize memory mapping
 * 
 * 将一个连续的页面区域[base, base+n)初始化并加入伙伴系统。
 * 
 * @param base 页面区域的起始页面
 * @param n    页面数量
 */
static void buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    
    // 初始化区域内的每个页面 - Initialize each page in the region
    for (; p != base + n; p++) {
        assert(PageReserved(p));        // 确保页面之前是保留状态 - Ensure page was reserved
        p->flags = 0;                   // 清空标志位 - Clear flags
        p->property = 0;                // 清空属性 - Clear property
        set_page_ref(p, 0);             // 设置引用计数为0 - Set reference count to 0
    }
    
    insert_region(base, n);             // 将整个区域插入伙伴系统 - Insert entire region into buddy system
    buddy_total_free += n;              // 增加总空闲页面数 - Increment total free pages
}

/**
 * @brief 分配页面 - Allocate pages (Buddy Algorithm)
 * 
 * 使用伙伴系统算法分配n个连续页面。
 * 
 * 算法步骤：
 * 1. 找到能容纳n个页面的最小order级别
 * 2. 从该级别开始向上查找，直到找到有空闲块的级别
 * 3. 取出一个空闲块，如果块大小>n，则将剩余部分返回系统
 * 4. 清理分配页面的属性，更新计数器
 * 
 * @param n 需要分配的页面数
 * @return 分配的页面起始地址，失败返回NULL
 */
static struct Page *buddy_alloc_pages(size_t n) {
    assert(n > 0);
    
    // 检查是否有足够的空闲页面 - Check if there are enough free pages
    if (n > buddy_total_free) {
        return NULL;
    }
    
    // 找到能容纳n个页面的最小order级别 - Find minimal order with block size >= n
    unsigned int want_order = 0;
    while ((order_block_pages(want_order) < n) && want_order < BUDDY_MAX_ORDER) {
        want_order++;
    }
    
    // 从需要的order开始向上查找有空闲块的级别 - Find order with non-empty free list starting from want_order
    unsigned int found_order = want_order;
    while (found_order <= BUDDY_MAX_ORDER && list_empty(&order_free_list(found_order))) {
        found_order++;
    }
    
    // 如果没找到合适的空闲块 - If no suitable free block found
    if (found_order > BUDDY_MAX_ORDER) {
        return NULL;
    }

    // 从found_order级别取出一个空闲块 - Pop one block from found_order
    list_entry_t *le = list_next(&order_free_list(found_order));
    struct Page *block = le2page(le, page_link);
    list_del(&(block->page_link));                                  // 从链表中移除 - Remove from list
    order_nr_free(found_order) -= order_block_pages(found_order);   // 减少该级别的页面计数 - Decrease page count for this level
    ClearPageProperty(block);                                       // 清除块的属性标志 - Clear block's property flag
    block->property = 0;                                            // 重置属性值 - Reset property value

    // 如果分配的块比需要的大，将剩余部分返回系统 - If allocated block is larger than needed, return surplus
    size_t s = order_block_pages(found_order);                      // 分配块的实际大小 - Actual size of allocated block
    carve_suffix_as_free(block, n, s);                              // 将剩余部分返回 - Return surplus part

    // 清理分配页面的属性 - Clear properties of allocated pages
    struct Page *p = block;
    for (size_t i = 0; i < n; i++, p++) {
        ClearPageProperty(p);                                       // 清除页面属性标志 - Clear page property flag
        p->property = 0;                                            // 重置属性值 - Reset property value
    }

    buddy_total_free -= n;                                          // 减少总空闲页面数 - Decrease total free pages
    return block;
}

/**
 * @brief 释放页面 - Free pages
 * 
 * 释放n个连续页面并将其返回给伙伴系统。伙伴系统会自动尝试
 * 将释放的页面与相邻的空闲块合并以减少碎片。
 * 
 * @param base 要释放的页面区域起始地址
 * @param n    要释放的页面数量
 */
static void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    
    // 重置要释放的页面状态 - Reset state of pages to be freed
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面可以被释放 - Ensure pages can be freed
        p->flags = 0;                                 // 清空标志位 - Clear flag bits
        set_page_ref(p, 0);                          // 清空引用计数 - Clear reference count
    }
    
    insert_region(base, n);                          // 将页面区域插入伙伴系统(会自动合并) - Insert region into buddy system (auto-merge)
    buddy_total_free += n;                           // 增加总空闲页面数 - Increment total free pages
}

/**
 * @brief 获取空闲页面数量 - Get number of free pages
 * 
 * @return 伙伴系统中空闲页面的总数
 */
static size_t buddy_nr_free_pages(void) { 
    return buddy_total_free; 
}

static void basic_check(void) {
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

    buddy_area_t saved[BUDDY_MAX_ORDER + 1];
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        saved[i] = buddy_area[i];
    }
    size_t total_saved = buddy_total_free;

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
    }
    size_t total_store = buddy_total_free;
    buddy_total_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(buddy_total_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(buddy_total_free >= 1);

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(buddy_total_free == 0);

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        order_free_list(i) = saved[i].free_list;
        order_nr_free(i) = saved[i].nr_free;
    }
    buddy_total_free = total_saved;

    free_page(p);
    free_page(p1);
    free_page(p2);
    (void)total_store;
}

static void buddy_check(void) {
    size_t total = 0;
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_entry_t *le = &order_free_list(i);
        while ((le = list_next(le)) != &order_free_list(i)) {
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
            assert(p->property == i);
            total += order_block_pages(i);
        }
    }
    assert(total == buddy_nr_free_pages());

    basic_check();

    size_t before = buddy_nr_free_pages();
    struct Page *q = alloc_pages(3);
    assert(q != NULL);
    assert(buddy_nr_free_pages() + 3 == before);
    free_pages(q, 3);
    assert(buddy_nr_free_pages() == before);

    struct Page *r = alloc_pages(8);
    assert(r != NULL);
    struct Page *r2 = r + 3;
    free_pages(r2, 5);
    free_pages(r, 3);

    assert(buddy_nr_free_pages() == before);

    // extra: isolated mini arena tests
    size_t g_before = buddy_nr_free_pages();
    struct Page *arena = alloc_pages(32);
    assert(arena != NULL);
    buddy_area_t saved2[BUDDY_MAX_ORDER + 1];
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        saved2[i] = buddy_area[i];
    }
    size_t saved_total2 = buddy_total_free;
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
    }
    buddy_total_free = 0;
    insert_region(arena, 32);
    buddy_total_free = 32;

    struct Page *b0 = alloc_pages(4);
    struct Page *b1 = alloc_pages(4);
    struct Page *b2 = alloc_pages(4);
    struct Page *b3 = alloc_pages(4);
    assert(b0 && b1 && b2 && b3);
    struct Page *d0 = alloc_pages(4);
    struct Page *d1 = alloc_pages(4);
    struct Page *d2 = alloc_pages(4);
    struct Page *d3 = alloc_pages(4);
    assert(d0 && d1 && d2 && d3);
    free_pages(b0 + 1, 2);
    assert(alloc_pages(3) == NULL);
    struct Page *t = alloc_pages(3);
    assert(t == NULL);
    free_page(b0);
    free_page(b0 + 3);
    struct Page *p4 = alloc_pages(4);
    assert(p4 == b0);
    free_pages(p4, 4);
    free_pages(b1, 4);
    free_pages(b2, 4);
    free_pages(b3, 4);

    free_pages(d0, 4);
    free_pages(d1, 4);
    free_pages(d2, 4);
    free_pages(d3, 4);
    struct Page *c0 = alloc_pages(8);
    assert(c0 != NULL);
    free_pages(c0, 4);
    free_pages(c0 + 4, 4);
    struct Page *c = alloc_pages(8);
    assert(c == c0);
    free_pages(c, 8);

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_entry_t *le = &order_free_list(i);
        for (list_entry_t *a = list_next(le); a != le; a = list_next(a)) {
            struct Page *pa = le2page(a, page_link);
            size_t idxa = page_index(pa);
            size_t bs = order_block_pages(i);
            size_t bidx = idxa ^ bs;
            for (list_entry_t *b = list_next(le); b != le; b = list_next(b)) {
                struct Page *pb = le2page(b, page_link);
                size_t idxb = page_index(pb);
                assert(!(idxb == bidx));
            }
        }
    }

    struct Page *drain[64];
    size_t dn = 0;
    struct Page *u;
    while ((u = alloc_pages(1)) != NULL && dn < 64) {
        drain[dn++] = u;
    }

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        order_free_list(i) = saved2[i].free_list;
        order_nr_free(i) = saved2[i].nr_free;
    }
    buddy_total_free = saved_total2;

    free_pages(arena, 32);
    assert(buddy_nr_free_pages() == g_before);
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};


