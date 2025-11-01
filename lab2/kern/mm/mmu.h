#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

/**
 * @file mmu.h
 * @brief 内存管理单元(MMU)相关定义 - Memory Management Unit Definitions
 * 
 * 本文件定义了RISC-V架构下的MMU相关常量，包括SV39页表格式、
 * 页表项字段定义、虚拟地址格式等内容。
 */

#ifndef __ASSEMBLER__
#include <defs.h>
#endif


/* 页面基本参数 - Basic Page Parameters */
#define PGSIZE          4096                    // 一个页面映射的字节数 - bytes mapped by a page
#define PGSHIFT         12                      // PGSIZE的对数值 - log2(PGSIZE)

/* 地址到页号的转换 - physical/virtual page number of address */
#define PPN(la) (((uintptr_t)(la)) >> PGSHIFT)  // 从线性地址获取页号 - Get page number from linear address

/* SV39虚拟地址结构 - Sv39 linear address structure */
// +-------9--------+-------9--------+--------9---------+----------12----------+
// |      VPN2      |      VPN1      |       VPN0       |  Offset within Page  |
// +----------------+----------------+------------------+----------------------+
// VPN2: 虚拟页号第2级 (30-38位)    VPN1: 虚拟页号第1级 (21-29位)
// VPN0: 虚拟页号第0级 (12-20位)    Offset: 页内偏移 (0-11位)

/* SV39页表项结构 - Sv39 page table entry */
// RISC-V64中的SV39使用39位虚拟地址访问56位物理地址！
// Sv39 in RISC-V64 uses 39-bit virtual address to access 56-bit physical address!
// +-------10--------+--------26-------+--------9----------+--------9--------+---2----+-------8-------+
// |    Reserved     |      PPN[2]     |      PPN[1]       |      PPN[0]     |Reserved|D|A|G|U|X|W|R|V|
// +-----------------+-----------------+-------------------+-----------------+--------+---------------+
// PPN[2:0]: 物理页号  D: 脏位  A: 访问位  G: 全局位  U: 用户位  X: 执行位  W: 写位  R: 读位  V: 有效位

/* SV39页目录和页表常量 - page directory and page table constants */
#define SV39_NENTRY          512                     // 每个页目录中的页目录项数 - page directory entries per page directory

#define SV39_PGSIZE          4096                    // 一个页面映射的字节数 - bytes mapped by a page
#define SV39_PGSHIFT         12                      // PGSIZE的对数值 - log2(PGSIZE)
#define SV39_PTSIZE          (PGSIZE * SV39NENTRY)   // 一个页目录项映射的字节数 - bytes mapped by a page directory entry
#define SV39_PTSHIFT         21                      // PTSIZE的对数值 - log2(PTSIZE)

/* 虚拟页号在线性地址中的位移 - VPN shifts in linear address */
#define SV39_VPN0SHIFT       12                      // VPN0在线性地址中的偏移 - offset of VPN0 in a linear address
#define SV39_VPN1SHIFT       21                      // VPN1在线性地址中的偏移 - offset of VPN1 in a linear address
#define SV39_VPN2SHIFT       30                      // VPN2在线性地址中的偏移 - offset of VPN2 in a linear address
#define SV39_PTE_PPN_SHIFT   10                      // PPN在物理地址中的偏移 - offset of PPN in a physical address

/* 从线性地址提取虚拟页号 - Extract VPN from linear address */
#define SV39_VPN0(la) ((((uintptr_t)(la)) >> SV39_VPN0SHIFT) & 0x1FF)  // 提取VPN0 (9位)
#define SV39_VPN1(la) ((((uintptr_t)(la)) >> SV39_VPN1SHIFT) & 0x1FF)  // 提取VPN1 (9位)
#define SV39_VPN2(la) ((((uintptr_t)(la)) >> SV39_VPN2SHIFT) & 0x1FF)  // 提取VPN2 (9位)
#define SV39_VPN(la, n) ((((uintptr_t)(la)) >> 12 >> (9 * n)) & 0x1FF) // 提取第n级VPN

/* 从索引和偏移构造线性地址 - construct linear address from indexes and offset */
#define SV39_PGADDR(v2, v1, v0, o) ((uintptr_t)((v2) << SV39_VPN2SHIFT | (v1) << SV39_VPN1SHIFT | (v0) << SV39_VPN0SHIFT | (o)))

/* 从页表项获取地址 - address in page table or page directory entry */
#define SV39_PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x1FF) << 3)  // 提取页表项中的物理地址

/* 三级页表级别定义 - 3-level pagetable */
#define SV39_PT0                 0              // 第0级页表
#define SV39_PT1                 1              // 第1级页表  
#define SV39_PT2                 2              // 第2级页表

/* 页表项(PTE)字段定义 - page table entry (PTE) fields */
#define PTE_V     0x001 // 有效位 - Valid
#define PTE_R     0x002 // 可读位 - Read
#define PTE_W     0x004 // 可写位 - Write
#define PTE_X     0x008 // 可执行位 - Execute
#define PTE_U     0x010 // 用户模式位 - User
#define PTE_G     0x020 // 全局位 - Global
#define PTE_A     0x040 // 访问位 - Accessed
#define PTE_D     0x080 // 脏位 - Dirty
#define PTE_SOFT  0x300 // 软件保留位 - Reserved for Software

/* 常用权限组合 - Common Permission Combinations */
#define PAGE_TABLE_DIR (PTE_V)                          // 页目录项
#define READ_ONLY (PTE_R | PTE_V)                       // 只读
#define READ_WRITE (PTE_R | PTE_W | PTE_V)              // 读写
#define EXEC_ONLY (PTE_X | PTE_V)                       // 只执行
#define READ_EXEC (PTE_R | PTE_X | PTE_V)               // 读执行
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V) // 读写执行

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V) // 用户模式全权限

#endif /* !__KERN_MM_MMU_H__ */

