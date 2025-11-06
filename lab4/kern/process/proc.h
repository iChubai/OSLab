/**
 * @file kern/process/proc.h
 * @brief 进程管理核心数据结构和接口定义
 *
 * 本头文件定义了ucore操作系统中进程管理的所有核心数据结构和接口函数声明。
 * 包括进程状态、进程结构体、上下文结构体以及进程管理相关的所有函数原型。
 */

#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>       // 基本类型定义
#include <list.h>       // 双向链表
#include <trap.h>       // 中断和trapframe
#include <memlayout.h>  // 内存布局定义

// ============================================================================
// 进程状态定义
// ============================================================================

/**
 * @brief 进程状态枚举
 *
 * 定义了进程在其生命周期中的所有可能状态。
 * 这些状态控制着进程的调度行为和生命周期管理。
 */
enum proc_state
{
    PROC_UNINIT = 0,  /**< 未初始化状态：进程刚被创建，还未完全设置 */
    PROC_SLEEPING,    /**< 睡眠状态：等待某些事件或资源，无法被调度执行 */
    PROC_RUNNABLE,    /**< 可运行状态：准备执行或正在CPU上执行 */
    PROC_ZOMBIE,      /**< 僵尸状态：进程已终止，等待父进程回收其资源 */
};

/**
 * @brief 进程上下文结构体
 *
 * 保存进程切换时需要保存的CPU寄存器状态。
 * 当进程被切换出CPU时，这些寄存器值被保存；
 * 当进程重新获得CPU时，这些值被恢复。
 */
struct context
{
    uintptr_t ra;   /**< 返回地址寄存器 (x1) */
    uintptr_t sp;   /**< 栈指针寄存器 (x2) */
    uintptr_t s0;   /**< 保存寄存器 s0 (x8) */
    uintptr_t s1;   /**< 保存寄存器 s1 (x9) */
    uintptr_t s2;   /**< 保存寄存器 s2 (x18) */
    uintptr_t s3;   /**< 保存寄存器 s3 (x19) */
    uintptr_t s4;   /**< 保存寄存器 s4 (x20) */
    uintptr_t s5;   /**< 保存寄存器 s5 (x21) */
    uintptr_t s6;   /**< 保存寄存器 s6 (x22) */
    uintptr_t s7;   /**< 保存寄存器 s7 (x23) */
    uintptr_t s8;   /**< 保存寄存器 s8 (x24) */
    uintptr_t s9;   /**< 保存寄存器 s9 (x25) */
    uintptr_t s10;  /**< 保存寄存器 s10 (x26) */
    uintptr_t s11;  /**< 保存寄存器 s11 (x27) */
};

// ============================================================================
// 常量定义
// ============================================================================

/** 进程名称最大长度（不包括结尾的'\0'） */
#define PROC_NAME_LEN               15

/** 系统支持的最大进程数 */
#define MAX_PROCESS                 4096

/** PID的最大值（MAX_PROCESS * 2，确保有足够的PID空间） */
#define MAX_PID                     (MAX_PROCESS * 2)

// ============================================================================
// 全局变量声明
// ============================================================================

/**
 * @brief 进程链表头节点
 *
 * 所有可调度的进程（除idle进程外）都链接在这个双向循环链表中。
 * 调度器通过遍历这个链表来选择下一个要执行的进程。
 */
extern list_entry_t proc_list;

/**
 * @brief 进程结构体定义
 *
 * 这是ucore中进程的核心数据结构，包含了进程的所有状态信息。
 * 每个进程都对应一个proc_struct实例。
 */
struct proc_struct
{
    // ========== 进程状态和标识 ==========
    enum proc_state state;           /**< 进程当前状态 */
    int pid;                         /**< 进程ID (0表示idle进程) */
    int runs;                        /**< 进程被调度的次数统计 */

    // ========== 内存管理 ==========
    uintptr_t kstack;                /**< 内核栈的起始地址 */
    uintptr_t pgdir;                 /**< 页目录基地址 */

    // ========== 调度控制 ==========
    volatile bool need_resched;      /**< 是否需要重新调度 */

    // ========== 进程关系 ==========
    struct proc_struct *parent;      /**< 父进程指针 */

    // ========== 内存空间 ==========
    struct mm_struct *mm;            /**< 内存管理结构体（lab4中未使用） */

    // ========== 执行上下文 ==========
    struct context context;          /**< 进程上下文，用于进程切换 */
    struct trapframe *tf;            /**< 中断帧指针，保存中断时的CPU状态 */

    // ========== 进程属性 ==========
    uint32_t flags;                  /**< 进程标志位 */
    char name[PROC_NAME_LEN + 1];    /**< 进程名称字符串 */

    // ========== 链表节点 ==========
    list_entry_t list_link;          /**< 进程链表节点（用于调度） */
    list_entry_t hash_link;          /**< 哈希链表节点（用于PID查找） */
};

/**
 * @brief 将链表节点转换为进程结构体指针
 *
 * 这是一个常用的宏，用于从链表节点获得包含该节点的进程结构体地址。
 * @param le 链表节点指针
 * @param member 进程结构体中链表节点的成员名
 */
#define le2proc(le, member) \
    to_struct((le), struct proc_struct, member)

// ============================================================================
// 全局进程指针声明
// ============================================================================

extern struct proc_struct *idleproc;   /**< 空闲进程（PID=0）*/
extern struct proc_struct *initproc;   /**< 初始化进程（PID=1）*/
extern struct proc_struct *current;    /**< 当前正在执行的进程 */

// ============================================================================
// 函数声明
// ============================================================================

// ========== 进程系统初始化 ==========
void proc_init(void);  /**< 初始化进程管理系统 */

// ========== 进程调度和切换 ==========
void proc_run(struct proc_struct *proc);  /**< 切换到指定进程执行 */

// ========== 进程创建 ==========
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);
                                      /**< 创建内核线程 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
                                      /**< 创建新进程（核心函数）*/

// ========== 进程属性管理 ==========
char *set_proc_name(struct proc_struct *proc, const char *name);
                                      /**< 设置进程名称 */
char *get_proc_name(struct proc_struct *proc);
                                      /**< 获取进程名称 */

// ========== 进程查找 ==========
struct proc_struct *find_proc(int pid);  /**< 根据PID查找进程 */

// ========== 进程退出 ==========
int do_exit(int error_code);  /**< 终止当前进程 */

// ========== CPU空闲处理 ==========
void cpu_idle(void) __attribute__((noreturn));
                                      /**< CPU空闲循环 */

#endif /* !__KERN_PROCESS_PROC_H__ */
