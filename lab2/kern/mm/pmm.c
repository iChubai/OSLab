/**
 * @file pmm.c
 * @brief 物理内存管理器核心实现 - Physical Memory Manager Core Implementation
 * 
 * 本文件实现了物理内存管理的核心功能，包括：
 * - 物理内存管理器的初始化和管理
 * - 页面分配和释放的统一接口
 * - 虚拟地址和物理地址的转换
 * - 内存布局的建立和管理
 * - SLUB分配器的集成
 */

#include <default_pmm.h>
#include <best_fit_pmm.h>
#include <buddy_pmm.h>
#include <defs.h>
#include <error.h>
#include <memlayout.h>
#include <mmu.h>
#include <pmm.h>
#include <sbi.h>
#include <slub.h>
#include <stdio.h>
#include <string.h>
#include <riscv.h>
#include <dtb.h>

/* 全局变量 - Global Variables */
struct Page *pages;                     // 物理页面数组的虚拟地址 - Virtual address of physical page array
size_t npage = 0;                       // 物理内存总页数 - Amount of physical memory (in pages)
uint64_t va_pa_offset;                  // 虚拟地址与物理地址的偏移量 - VA to PA offset (kernel image mapping)
const size_t nbase = DRAM_BASE / PGSIZE; // 内存起始页号 - Base page number (RISC-V memory starts at 0x80000000)

/* 页表相关变量 - Page Table Related Variables */
uintptr_t *satp_virtual = NULL;         // 启动时页目录的虚拟地址 - Virtual address of boot-time page directory
uintptr_t satp_physical;                // 启动时页目录的物理地址 - Physical address of boot-time page directory

/* 物理内存管理器 - Physical Memory Manager */
const struct pmm_manager *pmm_manager;

/* 内部函数声明 - Internal Function Declarations */
static void check_alloc_page(void);

/**
 * @brief 初始化物理内存管理器实例 - Initialize a pmm_manager instance
 * 
 * 选择并初始化一个具体的物理内存管理算法。目前使用最佳适应算法。
 * 可以通过修改这里来切换不同的内存管理算法：
 * - &default_pmm_manager: 首次适应算法
 * - &best_fit_pmm_manager: 最佳适应算法  
 * - &buddy_pmm_manager: 伙伴系统算法
 */
static void init_pmm_manager(void) {
    pmm_manager = &best_fit_pmm_manager;        // 选择内存管理算法 - Select memory management algorithm
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();                        // 初始化选定的管理器 - Initialize selected manager
}

/**
 * @brief 初始化内存映射 - Initialize memory mapping
 * 
 * 调用具体PMM管理器的init_memmap方法来为空闲内存构建Page结构体。
 * 
 * @param base 内存区域的起始Page结构体
 * @param n    页面数量
 */
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

/**
 * @brief 分配页面 - Allocate pages
 * 
 * 调用具体PMM管理器的alloc_pages方法来分配n个连续的物理页面。
 * 
 * @param n 要分配的页面数量
 * @return 分配成功返回起始Page结构体指针，失败返回NULL
 */
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
}

/**
 * @brief 释放页面 - Free pages
 * 
 * 调用具体PMM管理器的free_pages方法来释放n个连续的物理页面。
 * 
 * @param base 要释放页面的起始Page结构体
 * @param n    要释放的页面数量
 */
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
}

/**
 * @brief 获取空闲页面数 - Get number of free pages
 * 
 * 调用具体PMM管理器的nr_free_pages方法来获取当前空闲内存的大小。
 * 
 * @return 当前空闲页面的数量
 */
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
}

/**
 * @brief 页面管理初始化 - Page management initialization
 * 
 * 初始化页面管理系统，包括：
 * 1. 设置虚拟地址到物理地址的偏移量
 * 2. 从设备树获取内存信息
 * 3. 计算可管理的内存范围
 * 4. 初始化页面描述符数组
 * 5. 将空闲内存加入到内存管理器
 */
static void page_init(void) {
    // 设置虚拟地址与物理地址的偏移量 - Set VA to PA offset
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // 从设备树获取内存信息 - Get memory info from device tree
    uint64_t mem_begin = get_memory_base();     // 内存起始物理地址 - Memory start physical address
    uint64_t mem_size  = get_memory_size();     // 内存总大小 - Total memory size
    if (mem_size == 0) {
        panic("DTB memory info not available");
    }
    uint64_t mem_end   = mem_begin + mem_size;  // 内存结束物理地址 - Memory end physical address

    // 打印物理内存映射信息 - Print physical memory map info
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin, mem_end - 1);

    // 确定最大可管理物理地址 - Determine maximum manageable physical address
    uint64_t maxpa = mem_end;
    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;                        // 限制在内核虚拟地址空间内 - Limit within kernel virtual address space
    }

    extern char end[];                          // 内核代码段结束位置 - End of kernel code segment

    // 计算页面数量和页面描述符数组位置 - Calculate page count and page descriptor array location
    npage = maxpa / PGSIZE;                     // 总页面数 - Total page count
    //kernel在end[]结束, pages是剩下的页的开始 - Kernel ends at end[], pages start from the remaining area
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 初始化所有页面为保留状态 - Initialize all pages as reserved
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);
    }

    // 计算空闲内存的起始位置 - Calculate start of free memory
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    // 对齐空闲内存边界 - Align free memory boundaries
    mem_begin = ROUNDUP(freemem, PGSIZE);       // 向上对齐到页边界 - Round up to page boundary
    mem_end = ROUNDDOWN(mem_end, PGSIZE);       // 向下对齐到页边界 - Round down to page boundary
    
    // 如果有可用的空闲内存，加入到内存管理器 - If there's available free memory, add to memory manager
    if (freemem < mem_end) {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
    // We need to alloc/free the physical memory (granularity is 4KB or other size).
    // So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    // First we should init a physical memory manager(pmm) based on the framework.
    // Then pmm can alloc/free the physical memory.
    // Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();

    // use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();

    // initialize slub on top of pmm and run a basic self-check
    slub_init();
    slub_check();

    extern char boot_page_table_sv39[];
    satp_virtual = (pte_t*)boot_page_table_sv39;
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}
