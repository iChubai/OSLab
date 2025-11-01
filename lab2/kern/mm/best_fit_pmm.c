#include <pmm.h>
#include <list.h>
#include <string.h>
#include <best_fit_pmm.h>
#include <stdio.h>

/**
 * @file best_fit_pmm.c
 * @brief 最佳适应物理内存管理器 - Best Fit Physical Memory Manager
 * 
 * 最佳适应算法(Best Fit Algorithm)与首次适应算法类似，但它不是选择第一个
 * 足够大的空闲块，而是选择所有足够大的空闲块中最小的那个。这样可以减少
 * 内存碎片，提高内存利用率。
 * 
 * Best Fit Algorithm is similar to First Fit, but instead of choosing the first
 * block that is large enough, it chooses the smallest block among all blocks that
 * are large enough. This helps reduce memory fragmentation and improve memory utilization.
 * 
 * Please see Page 196~198, Section 8.2 of Yan Wei Min's chinese book "Data Structure -- C programming language"
 */
/**
 * @brief 最佳适应内存分配算法(BFMA)实现详解
 * 
 * LAB2 EXERCISE 1: 需要重写以下函数以实现最佳适应算法
 * 
 * 最佳适应内存分配(BFMA)算法实现细节：
 * 
 * 与首次适应算法的主要区别在于分配策略：
 * - 首次适应：选择第一个足够大的空闲块
 * - 最佳适应：选择所有足够大的空闲块中最小的那个
 * 
 * 算法优点：
 * - 减少内存碎片
 * - 提高内存利用率
 * - 留下的空闲块更大，更容易被后续请求使用
 * 
 * 算法缺点：
 * - 需要遍历整个空闲链表，时间复杂度较高
 * - 可能产生很多小的无用碎片
 * 
 * 实现要点：
 * (1) best_fit_alloc_pages: 遍历整个空闲链表，找到满足条件的最小空闲块
 *     - 记录当前找到的最小块大小(min_size)
 *     - 遍历过程中不断更新最优选择
 *     - 分配完成后处理剩余块的插入
 * 
 * 其他函数(init, init_memmap, free_pages, nr_free_pages)与首次适应算法相同。
 */
/* 全局空闲区域管理结构 - Global free area management structure */
static free_area_t free_area;

/* 便捷访问宏 - Convenience access macros */
#define free_list (free_area.free_list)    // 空闲链表 - Free list
#define nr_free (free_area.nr_free)        // 空闲页数 - Number of free pages

/**
 * @brief 初始化最佳适应内存管理器 - Initialize best fit memory manager
 * 
 * 初始化空闲链表并清零空闲页计数。
 * Initialize the free list and reset free page counter to zero.
 */
static void
best_fit_init(void) {
    list_init(&free_list);              // 初始化空闲链表 - Initialize free list
    nr_free = 0;                        // 清零空闲页数 - Reset free page count
}

/**
 * @brief 初始化内存映射 - Initialize memory mapping
 * 
 * 将一个连续的页面区域[base, base+n)初始化为空闲状态并加入空闲链表。
 * 实现与首次适应算法相同，空闲链表按地址从低到高排序。
 * 
 * @param base 页面区域的起始页面
 * @param n    页面数量
 */
static void
best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    
    // 初始化区域内的每个页面 - Initialize each page in the region
    for (; p != base + n; p ++) {
        assert(PageReserved(p));        // 确保页面之前是保留状态 - Ensure page was reserved
        p->flags = 0;                   // 清空标志位 - Clear flags
        p->property = 0;                // 清空属性 - Clear property
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
 * @brief 分配页面 - Allocate pages (Best Fit Algorithm)
 * 
 * 使用最佳适应算法分配n个连续的页面。遍历整个空闲链表，找到所有
 * 大小>=n的空闲块中最小的那个，如果块大小>n则进行分割。
 * 
 * 算法核心：在所有满足条件的块中选择最小的，以减少内存碎片。
 * 
 * @param n 需要分配的页面数
 * @return 分配的页面起始地址，失败返回NULL
 */
static struct Page *
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    
    // 检查是否有足够的空闲页面 - Check if there are enough free pages
    if (n > nr_free) {
        return NULL;
    }
    
    struct Page *page = NULL;           // 最佳匹配的页面 - Best matched page
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;      // 初始化为不可能的大小 - Initialize to impossible size
    
    // 遍历整个空闲链表寻找最佳匹配 - Traverse entire free list to find best match
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n && p->property < min_size) {
            // 找到更小的满足条件的块 - Found smaller block that satisfies requirement
            min_size = p->property;      // 更新最小大小 - Update minimum size
            page = p;                    // 更新最佳匹配页面 - Update best matched page
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
 * 释放n个连续页面并尝试与相邻的空闲块合并。实现与首次适应算法相同。
 * 释放的页面会按地址顺序插入空闲链表，然后检查前后相邻块进行合并操作。
 * 
 * @param base 要释放的页面区域起始地址
 * @param n    要释放的页面数量
 */
static void
best_fit_free_pages(struct Page *base, size_t n) {
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
    nr_free += n;                                    // 增加空闲页计数 - Increment free page count
    
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
best_fit_nr_free_pages(void) {
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

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
    free_pages(p0 + 4, 1);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
    assert(alloc_pages(2) != NULL);      // best fit feature
    assert(p0 + 4 == p1);

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
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
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}

const struct pmm_manager best_fit_pmm_manager = {
    .name = "best_fit_pmm_manager",
    .init = best_fit_init,
    .init_memmap = best_fit_init_memmap,
    .alloc_pages = best_fit_alloc_pages,
    .free_pages = best_fit_free_pages,
    .nr_free_pages = best_fit_nr_free_pages,
    .check = best_fit_check,
};

