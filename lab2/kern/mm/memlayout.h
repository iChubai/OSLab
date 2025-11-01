#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/**
 * @file memlayout.h
 * @brief 内存布局相关定义 - Memory Layout Definitions
 * 
 * 本文件定义了操作系统内核的内存布局，包括虚拟地址和物理地址的映射关系，
 * 页面描述符结构，以及内存管理相关的常量和宏定义。
 */

/* 所有物理内存映射到此虚拟地址 - All physical memory mapped at this address */
/* 内核虚拟地址基址 - Kernel Virtual Address Base */
#define KERNBASE            0xFFFFFFFFC0200000 // = 0x80200000(物理内存里内核的起始位置, KERN_BEGIN_PADDR) + 0xFFFFFFFF40000000(偏移量, PHYSICAL_MEMORY_OFFSET)
//把原有内存映射到虚拟内存空间的最后一页

/* 内核可用内存大小 - Maximum amount of kernel memory */
#define KMEMSIZE            0x7E00000          // the maximum amount of physical memory
// 0x7E00000 = 0x8000000 - 0x200000
// QEMU 缺省的RAM为 0x80000000到0x88000000, 128MiB, 0x80000000到0x80200000被OpenSBI占用

/* 内核虚拟地址上限 - Kernel Virtual Address Top */
#define KERNTOP             (KERNBASE + KMEMSIZE) // 0x88000000对应的虚拟地址

/* 物理内存布局相关常量 - Physical Memory Layout Constants */
#define PHYSICAL_MEMORY_END         0x88000000          // 物理内存结束地址
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000  // 虚拟地址与物理地址的偏移量
#define KERNEL_BEGIN_PADDR          0x80200000          // 内核物理地址起始位置
#define KERNEL_BEGIN_VADDR          0xFFFFFFFFC0200000  // 内核虚拟地址起始位置


/* 内核栈相关定义 - Kernel Stack Definitions */
#define KSTACKPAGE          2                           // 内核栈占用的页面数 - # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // 内核栈大小 - sizeof kernel stack

#ifndef __ASSEMBLER__

#include <defs.h>
#include <list.h>

/* 页表项类型定义 - Page Table Entry Types */
typedef uintptr_t pte_t;   // 页表项类型 - Page Table Entry
typedef uintptr_t pde_t;   // 页目录项类型 - Page Directory Entry

/**
 * @struct Page
 * @brief 页面描述符结构 - Page descriptor structures
 * 
 * 每个Page结构描述一个物理页面。在kern/mm/pmm.h中可以找到很多有用的函数
 * 来将Page转换为其他数据类型，如物理地址等。
 * Each Page describes one physical page. In kern/mm/pmm.h, you can find 
 * lots of useful functions that convert Page to other data types, such as physical address.
 */
struct Page {
    int ref;                        // 页框引用计数器 - page frame's reference counter
    uint64_t flags;                 // 描述页框状态的标志位数组 - array of flags that describe the status of the page frame
    unsigned int property;          // 空闲块的页面数，用于首次适应算法 - the num of free block, used in first fit pm manager
    list_entry_t page_link;         // 空闲链表链接 - free list link
};

/* 描述页框状态的标志位 - Flags describing the status of a page frame */
#define PG_reserved                 0       // 保留页标志：为1表示页面被内核保留，不能用于alloc/free_pages；为0表示可用
                                           // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // 属性页标志：为1表示该页是空闲内存块的头页面，可用于alloc_pages；为0表示已分配或不是头页面
                                           // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages

/* 页面标志位操作宏 - Page Flag Operation Macros */
#define SetPageReserved(page)       ((page)->flags |= (1UL << PG_reserved))    // 设置页面为保留状态
#define ClearPageReserved(page)     ((page)->flags &= ~(1UL << PG_reserved))   // 清除页面保留状态
#define PageReserved(page)          (((page)->flags >> PG_reserved) & 1)       // 检查页面是否为保留状态
#define SetPageProperty(page)       ((page)->flags |= (1UL << PG_property))    // 设置页面属性标志
#define ClearPageProperty(page)     ((page)->flags &= ~(1UL << PG_property))   // 清除页面属性标志
#define PageProperty(page)          (((page)->flags >> PG_property) & 1)       // 检查页面属性标志

/* 链表项到页面的转换 - convert list entry to page */
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)

/**
 * @struct free_area_t
 * @brief 空闲区域结构 - maintains a doubly linked list to record free (unused) pages
 * 
 * 维护一个双向链表来记录空闲（未使用）的页面
 */
typedef struct {
    list_entry_t free_list;         // 链表头 - the list header
    unsigned int nr_free;           // 此空闲链表中的空闲页面数 - number of free pages in this free list
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
