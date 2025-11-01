#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

/**
 * @file pmm.h
 * @brief 物理内存管理器接口定义 - Physical Memory Manager Interface
 * 
 * 本文件定义了物理内存管理器的接口和相关的转换函数。物理内存管理器
 * 是一个物理内存管理类，特定的pmm管理器只需要实现pmm_manager类中
 * 的方法，就可以被ucore用来管理整个物理内存空间。
 */

#include <assert.h>
#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>

/**
 * @struct pmm_manager
 * @brief 物理内存管理器结构 - Physical Memory Management Class
 * 
 * pmm_manager是一个物理内存管理类。特定的pmm管理器（如XXX_pmm_manager）
 * 只需要实现pmm_manager类中的方法，然后XXX_pmm_manager就可以被ucore
 * 用来管理整个物理内存空间。
 * 
 * pmm_manager is a physical memory management class. A special pmm manager -
 * XXX_pmm_manager only needs to implement the methods in pmm_manager class, then
 * XXX_pmm_manager can be used by ucore to manage the total physical memory space.
 */
struct pmm_manager {
    const char *name;  // PMM管理器的名称 - XXX_pmm_manager's name
    
    void (*init)(void);  // 初始化内部描述和管理数据结构 - initialize internal description&management data structure
                        // (空闲块链表，空闲块数量等) - (free block list, number of free block) of XXX_pmm_manager
    
    void (*init_memmap)(struct Page *base, size_t n);  // 根据初始空闲物理内存空间设置描述和管理数据结构
                                                       // setup description&management data structcure according to
                                                       // the initial free physical memory space
    
    struct Page *(*alloc_pages)(size_t n);  // 分配>=n个页面，依赖于分配算法 - allocate >=n pages, depend on the allocation algorithm
    
    void (*free_pages)(struct Page *base, size_t n);  // 释放>=n个页面，base为页面描述符结构的基地址
                                                      // free >=n pages with "base" addr of Page descriptor structures(memlayout.h)
    
    size_t (*nr_free_pages)(void);  // 返回空闲页面数 - return the number of free pages
    void (*check)(void);            // 检查PMM管理器的正确性 - check the correctness of XXX_pmm_manager
};

/* 全局PMM管理器指针 */
extern const struct pmm_manager *pmm_manager;

/* 物理内存管理器接口函数 - Physical Memory Manager Interface Functions */
void pmm_init(void);                              // 初始化物理内存管理器 - Initialize physical memory manager

struct Page *alloc_pages(size_t n);               // 分配n个页面 - Allocate n pages
void free_pages(struct Page *base, size_t n);     // 释放n个页面 - Free n pages  
size_t nr_free_pages(void);                       // 获取空闲页面数 - Get number of free pages

/* 单页面分配和释放的便利宏 - Convenience macros for single page allocation */
#define alloc_page() alloc_pages(1)                // 分配一个页面 - Allocate one page
#define free_page(page) free_pages(page, 1)        // 释放一个页面 - Free one page


/**
 * @brief PADDR - 内核虚拟地址到物理地址转换
 * 
 * 接受一个内核虚拟地址（指向KERNBASE之上的地址），其中映射了机器的
 * 最大物理内存，并返回相应的物理地址。如果传入非内核虚拟地址会panic。
 * 
 * PADDR - takes a kernel virtual address (an address that points above KERNBASE),
 * where the machine's maximum physical memory is mapped and returns the
 * corresponding physical address. It panics if you pass it a non-kernel virtual address.
 */
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/**
 * @brief KADDR - 物理地址到内核虚拟地址转换
 * 
 * 接受一个物理地址并返回相应的内核虚拟地址。如果传入无效的物理地址会panic。
 * 
 * KADDR - takes a physical address and returns the corresponding kernel virtual
 * address. It panics if you pass an invalid physical address.
 */
/*
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })
*/

/* 全局变量 - Global Variables */
extern struct Page *pages;        // 页面数组 - Page array
extern size_t npage;              // 页面总数 - Total number of pages  
extern const size_t nbase;        // 基址页号 - Base page number
extern uint64_t va_pa_offset;     // 虚拟地址和物理地址偏移量 - Virtual to physical address offset

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}

static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}
static inline void flush_tlb() { asm volatile("sfence.vm"); }
extern char bootstack[], bootstacktop[]; // defined in entry.S

#endif /* !__KERN_MM_PMM_H__ */
