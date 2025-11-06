/**
 * @file kern/process/proc.c
 * @brief 进程管理核心实现文件
 *
 * 本文件实现了ucore操作系统中的进程管理机制，包括：
 * - 进程的创建、销毁、切换
 * - 进程状态管理
 * - 内核线程创建
 * - 进程调度相关接口
 * - 进程内存空间管理
 */

#include <proc.h>       // 进程相关结构体定义
#include <kmalloc.h>    // 内核内存分配
#include <string.h>     // 字符串操作
#include <sync.h>       // 同步机制
#include <pmm.h>        // 物理内存管理
#include <error.h>      // 错误码定义
#include <sched.h>      // 调度器接口
#include <elf.h>        // ELF文件格式（预留）
#include <vmm.h>        // 虚拟内存管理
#include <trap.h>       // 中断和异常处理
#include <riscv.h>      // RISC-V架构相关
#include <stdio.h>      // 标准输入输出
#include <stdlib.h>     // 标准库
#include <assert.h>     // 断言

/* =====================================================================
 * 进程/线程机制设计与实现概述
 * =====================================================================
 * ucore实现了一个简化的Linux风格的进程/线程机制：
 *
 * 进程组成要素：
 * - 独立的内存空间（地址空间）
 * - 至少一个执行线程
 * - 内核管理数据结构
 * - 处理器状态（用于上下文切换）
 * - 文件描述符（lab6中实现）
 *
 * 在ucore中，线程被实现为一种特殊的进程（共享父进程的内存空间）。
 * =====================================================================
 */

/* =====================================================================
 * 进程状态定义和状态转换图
 * =====================================================================
 * 进程状态枚举值及其含义：
 *   PROC_UNINIT    : 未初始化状态     - 通过alloc_proc创建后处于此状态
 *   PROC_SLEEPING  : 睡眠状态         - 等待资源或事件，通过wakeup_proc唤醒
 *   PROC_RUNNABLE  : 可运行状态       - 准备执行或正在执行
 *   PROC_ZOMBIE    : 僵尸状态         - 进程已终止，等待父进程回收资源
 *
 * 状态转换图：
 *
 *   alloc_proc()                                CPU执行中
 *       +                                     +----------+
 *       |                                     | proc_run |
 *       V                                     +----------+
 * PROC_UNINIT --proc_init/wakeup_proc--> PROC_RUNNABLE --阻塞操作--> PROC_SLEEPING
 *                                             |     ^                    |
 *                                             |     |                    |
 *                                             +-----+                    |
 *                                             |                          |
 *                                             +---do_exit()--> PROC_ZOMBIE
 *                                                           ^
 *                                                           |
 *                                                wakeup_proc(父进程)
 * =====================================================================
 */

/* =====================================================================
 * 进程间关系定义
 * =====================================================================
 * 进程树结构：
 * - parent:     proc->parent  (当前进程的父进程)
 * - children:   proc->cptr    (当前进程的第一个子进程)
 * - sibling:    proc->optr    (哥哥进程，older sibling)
 *               proc->yptr    (弟弟进程，younger sibling)
 *
 * 注：在lab4中，进程树关系字段被注释掉了，实际实现中未使用
 * =====================================================================
 */

/* =====================================================================
 * 系统调用与进程管理函数映射
 * =====================================================================
 * SYS_exit    : 进程退出           -> do_exit()
 * SYS_fork    : 创建子进程         -> do_fork() -> wakeup_proc()
 * SYS_wait    : 等待子进程         -> do_wait()
 * SYS_exec    : 执行新程序         -> 加载程序并刷新内存空间
 * SYS_clone   : 创建线程           -> do_fork() -> wakeup_proc()
 * SYS_yield   : 让出CPU           -> 设置need_resched标志，调度器重新调度
 * SYS_sleep   : 进程睡眠           -> do_sleep()
 * SYS_kill    : 杀死进程           -> do_kill() -> 设置退出标志 -> wakeup_proc()
 * SYS_getpid  : 获取进程PID       -> 返回current->pid
 * =====================================================================
 */

// ============================================================================
// 全局变量定义
// ============================================================================

/**
 * @brief 进程链表头节点
 *
 * 所有进程（除idle进程外）都链接在这个双向循环链表中
 * 用于进程遍历和调度
 */
list_entry_t proc_list;

/**
 * @brief PID哈希表相关宏定义
 */
#define HASH_SHIFT          10                          /**< 哈希表大小的位移量 */
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)          /**< 哈希表大小：2^10 = 1024 */
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))    /**< PID哈希函数 */

/**
 * @brief 进程PID哈希表
 *
 * 用于根据PID快速查找进程结构体
 * 每个哈希桶都是一个双向循环链表
 */
static list_entry_t hash_list[HASH_LIST_SIZE];

/**
 * @brief 全局进程指针
 */
struct proc_struct *idleproc = NULL;   /**< 空闲进程（PID=0）*/
struct proc_struct *initproc = NULL;   /**< 初始化进程（PID=1）*/
struct proc_struct *current = NULL;    /**< 当前正在执行的进程 */

/**
 * @brief 当前系统中进程总数
 */
static int nr_process = 0;

// ============================================================================
// 函数声明
// ============================================================================

/**
 * @brief 内核线程入口函数（在entry.S中定义）
 * @param arg 传递给线程函数的参数
 */
void kernel_thread_entry(void);

/**
 * @brief fork返回函数（在trapentry.S中定义）
 * @param tf trapframe结构体指针
 */
void forkrets(struct trapframe *tf);

/**
 * @brief 进程上下文切换函数（在switch.S中定义）
 * @param from 当前进程的上下文指针
 * @param to   目标进程的上下文指针
 */
void switch_to(struct context *from, struct context *to);

// ============================================================================
// 进程创建和初始化函数
// ============================================================================

/* =====================================================================
 * 函数: alloc_proc
 * 功能: 分配一个新的proc_struct结构体并初始化所有字段
 * 参数: void
 * 返回: 新分配的proc_struct指针，失败时返回NULL
 *
 * 详细说明:
 * 该函数是进程创建的第一步，负责从内核堆中分配进程结构体并进行基础初始化。
 * 初始化后的进程处于PROC_UNINIT状态，还不能被调度执行。
 *
 * 初始化字段说明:
 * - state: 进程状态，初始化为PROC_UNINIT（未初始化）
 * - pid: 进程ID，初始化为-1（无效值），后续通过get_pid()分配
 * - runs: 进程运行次数计数器，初始化为0
 * - kstack: 内核栈地址，初始化为0，后续通过setup_kstack()分配
 * - need_resched: 重新调度标志，初始化为0（不需要调度）
 * - parent: 父进程指针，初始化为NULL
 * - mm: 内存管理结构体，初始化为NULL（lab4中未使用）
 * - context: 进程上下文，全部清零
 * - tf: trapframe指针，初始化为NULL
 * - pgdir: 页目录基地址，设置为boot_pgdir_pa（引导时页目录）
 * - flags: 进程标志位，初始化为0
 * - name: 进程名称，全部清零
 * - list_link: 进程链表节点，初始化为空链表
 * - hash_link: 哈希链表节点，初始化为空链表
 * ===================================================================== */
static struct proc_struct *
alloc_proc(void)
{
    // 从内核堆中分配进程结构体内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));

    if (proc != NULL)
    {
        // LAB4:EXERCISE1 - 进程结构体字段初始化
        // 以下字段需要按照规范进行初始化：

        // ========== 进程状态和标识 ==========
        proc->state = PROC_UNINIT;          // 进程状态：未初始化
        proc->pid = -1;                     // 进程ID：无效值，待分配
        proc->runs = 0;                     // 运行次数计数器：初始为0

        // ========== 内存管理相关 ==========
        proc->kstack = 0;                   // 内核栈地址：待分配
        proc->pgdir = boot_pgdir_pa;        // 页目录：使用引导时的页目录

        // ========== 调度相关 ==========
        proc->need_resched = 0;             // 重新调度标志：不需要

        // ========== 进程关系 ==========
        proc->parent = NULL;                // 父进程：无
        proc->mm = NULL;                    // 内存管理结构体：lab4中未使用

        // ========== 执行上下文 ==========
        memset(&(proc->context), 0, sizeof(struct context)); // 上下文清零
        proc->tf = NULL;                    // trapframe：无

        // ========== 标志和属性 ==========
        proc->flags = 0;                    // 进程标志：无特殊标志
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空

        // ========== 链表节点初始化 ==========
        list_init(&(proc->list_link));      // 进程链表节点初始化
        list_init(&(proc->hash_link));      // 哈希链表节点初始化
    }

    return proc;
}

// ============================================================================
// 进程属性管理函数
// ============================================================================

/* =====================================================================
 * 函数: set_proc_name
 * 功能: 设置进程的名称
 * 参数:
 *   proc - 目标进程结构体指针
 *   name - 新的进程名称字符串
 * 返回: 进程名称字段的指针
 *
 * 说明:
 * - 首先清空原有的进程名称
 * - 复制新名称到进程结构体，最多复制PROC_NAME_LEN个字符
 * - 超过长度的部分会被截断
 * ===================================================================== */
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    // 清空原有名称
    memset(proc->name, 0, sizeof(proc->name));
    // 复制新名称（会自动截断过长的名称）
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

/* =====================================================================
 * 函数: get_proc_name
 * 功能: 获取进程的名称
 * 参数:
 *   proc - 目标进程结构体指针
 * 返回: 进程名称字符串的副本
 *
 * 说明:
 * - 返回静态缓冲区中的字符串副本
 * - 调用者应该尽快使用返回值，因为下次调用会覆盖缓冲区内容
 * ===================================================================== */
char *
get_proc_name(struct proc_struct *proc)
{
    // 使用静态缓冲区存储名称副本
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

/* =====================================================================
 * 函数: get_pid
 * 功能: 为新进程分配一个唯一的PID
 * 参数: void
 * 返回: 新分配的PID值
 *
 * 算法说明:
 * 该函数使用了一种高效的PID分配策略：
 * 1. 维护一个last_pid变量，从1开始递增
 * 2. 当last_pid达到MAX_PID时，从1重新开始
 * 3. 通过遍历进程链表检查PID是否已被使用
 * 4. 维护next_safe变量优化查找过程
 *
 * PID范围: 1 ~ MAX_PID-1 (0保留给idle进程)
 * ===================================================================== */
static int
get_pid(void)
{
    // 静态断言：确保PID空间足够大
    static_assert(MAX_PID > MAX_PROCESS);

    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;

    // 静态变量：维护PID分配状态
    static int next_safe = MAX_PID, last_pid = MAX_PID;

    // 递增last_pid，如果超出范围则回绕到1
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside;  // 跳转到内部检查逻辑
    }

    // 如果last_pid达到next_safe，需要进行完整检查
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;  // 重置安全边界

    repeat:
        le = list;
        // 遍历进程链表，检查是否有进程使用当前last_pid
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid)
            {
                // PID已被使用，尝试下一个
                if (++last_pid >= next_safe)
                {
                    if (last_pid >= MAX_PID)
                    {
                        last_pid = 1;  // 回绕到1
                    }
                    next_safe = MAX_PID;  // 重置安全边界
                    goto repeat;  // 重新开始检查
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                // 更新安全边界：找到一个更大的未使用PID
                next_safe = proc->pid;
            }
        }
    }

    return last_pid;
}

// ============================================================================
// 进程调度和切换函数
// ============================================================================

/* =====================================================================
 * 函数: proc_run
 * 功能: 将CPU执行上下文切换到指定的进程
 * 参数:
 *   proc - 要切换到的目标进程
 * 返回: void
 *
 * 详细说明:
 * 该函数是进程调度的核心，负责将CPU控制权从当前进程切换到目标进程。
 * 切换过程包括：
 * 1. 保存当前中断状态并关闭中断（保证切换的原子性）
 * 2. 更新current指针指向新进程
 * 3. 更新页表基地址寄存器(satp)以切换地址空间
 * 4. 调用switch_to进行上下文切换
 * 5. 恢复中断状态
 *
 * 注意：
 * - 如果目标进程就是当前进程，则不进行切换
 * - 中断关闭期间不会被调度器中断，保证切换的原子性
 * - 切换完成后，原进程的上下文被保存，新进程的上下文被恢复
 * ===================================================================== */
void proc_run(struct proc_struct *proc)
// LAB4:EXERCISE3 - 实现进程切换逻辑
{
    // 如果目标进程不是当前进程，才需要进行切换
    if (proc != current)
    {
        bool intr_flag;           // 保存中断状态
        struct proc_struct *prev; // 保存当前进程指针

        // 关闭中断，保证进程切换的原子性
        local_intr_save(intr_flag);

        prev = current;           // 保存当前进程
        current = proc;           // 更新当前进程指针

        // 更新页表基地址：切换到新进程的地址空间
        lsatp(proc->pgdir);

        // 执行上下文切换：保存prev的上下文，恢复proc的上下文
        // switch_to函数在switch.S中实现，使用汇编进行上下文切换
        switch_to(&(prev->context), &(proc->context));

        // 恢复中断状态
        local_intr_restore(intr_flag);
    }
}

/* =====================================================================
 * 函数: forkret
 * 功能: 新进程/线程的第一次内核入口点
 * 参数: void
 * 返回: void (通过trapframe返回到用户空间)
 *
 * 详细说明:
 * 该函数是fork创建的新进程第一次被调度执行时的入口点。
 * 当switch_to切换到新进程时，会从forkret开始执行。
 *
 * 执行流程：
 * 1. 调用forkrets()恢复trapframe（在trapentry.S中定义）
 * 2. 通过trapframe返回到用户空间或继续内核执行
 * 3. 对于子进程，forkrets会设置a0=0表示这是子进程
 * ===================================================================== */
static void
forkret(void)
{
    // 调用forkrets恢复trapframe并返回
    // current->tf是在copy_thread中设置的trapframe
    forkrets(current->tf);
}

// ============================================================================
// 进程查找和管理函数
// ============================================================================

/* =====================================================================
 * 函数: hash_proc
 * 功能: 将进程添加到PID哈希表中
 * 参数:
 *   proc - 要添加的进程结构体指针
 * 返回: void
 *
 * 说明:
 * - 根据进程的PID计算哈希值
 * - 将进程插入对应哈希桶的链表中
 * - 用于通过PID快速查找进程
 * ===================================================================== */
static void
hash_proc(struct proc_struct *proc)
{
    // 计算哈希值并插入对应哈希桶
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

/* =====================================================================
 * 函数: find_proc
 * 功能: 根据PID从哈希表中查找进程
 * 参数:
 *   pid - 要查找的进程ID
 * 返回: 找到的进程结构体指针，未找到返回NULL
 *
 * 说明:
 * - 验证PID的有效性（1到MAX_PID-1）
 * - 计算哈希值定位到对应的哈希桶
 * - 在哈希桶的链表中线性查找匹配的PID
 * ===================================================================== */
struct proc_struct *
find_proc(int pid)
{
    // 检查PID的有效性
    if (0 < pid && pid < MAX_PID)
    {
        // 计算哈希值，找到对应的哈希桶
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;

        // 在哈希桶中遍历查找
        while ((le = list_next(le)) != list)
        {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid)
            {
                return proc;
            }
        }
    }
    return NULL;
}

// ============================================================================
// 内核线程创建函数
// ============================================================================

/* =====================================================================
 * 函数: kernel_thread
 * 功能: 创建一个内核线程
 * 参数:
 *   fn - 线程函数指针
 *   arg - 传递给线程函数的参数
 *   clone_flags - 克隆标志（通常为0）
 * 返回: 新线程的PID，失败返回负数
 *
 * 详细说明:
 * 该函数简化了内核线程的创建过程：
 * 1. 构造一个临时的trapframe，设置线程函数和参数
 * 2. 设置CPU状态：内核态、开中断
 * 3. 设置入口点为kernel_thread_entry
 * 4. 调用do_fork创建新进程
 *
 * trapframe设置说明：
 * - s0寄存器：存储线程函数指针
 * - s1寄存器：存储函数参数
 * - status：设置SPP(Supervisor Previous Privilege)=1表示从内核态来
 *          设置SPIE(Supervisor Previous Interrupt Enable)=1
 *          清除SIE(Supervisor Interrupt Enable)=0（初始关闭中断）
 * - epc：设置为kernel_thread_entry的地址
 * ===================================================================== */
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));

    // 设置线程函数和参数
    tf.gpr.s0 = (uintptr_t)fn;        // s0 = 线程函数地址
    tf.gpr.s1 = (uintptr_t)arg;       // s1 = 函数参数

    // 设置CPU状态：内核态，开中断（SPIE=1），初始关中断（SIE=0）
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;

    // 设置程序计数器：指向内核线程入口
    tf.epc = (uintptr_t)kernel_thread_entry;

    // 调用do_fork创建新进程，并传入CLONE_VM标志（共享地址空间）
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// ============================================================================
// 内核栈管理函数
// ============================================================================

/* =====================================================================
 * 函数: setup_kstack
 * 功能: 为进程分配内核栈
 * 参数:
 *   proc - 目标进程结构体指针
 * 返回: 成功返回0，失败返回-E_NO_MEM
 *
 * 说明:
 * - 分配KSTACKPAGE个物理页作为内核栈
 * - 将物理页地址转换为内核虚拟地址
 * - 设置进程的kstack字段指向栈底
 * ===================================================================== */
static int
setup_kstack(struct proc_struct *proc)
{
    // 分配KSTACKPAGE个连续的物理页
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        // 将物理页转换为内核虚拟地址，并设置进程的内核栈指针
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;  // 内存分配失败
}

/* =====================================================================
 * 函数: put_kstack
 * 功能: 释放进程的内核栈内存
 * 参数:
 *   proc - 目标进程结构体指针
 * 返回: void
 *
 * 说明:
 * - 将内核虚拟地址转换为物理页
 * - 释放KSTACKPAGE个物理页
 * ===================================================================== */
static void
put_kstack(struct proc_struct *proc)
{
    // 将内核虚拟地址转换为物理页并释放
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// ============================================================================
// 进程内存空间和上下文复制函数
// ============================================================================

/* =====================================================================
 * 函数: copy_mm
 * 功能: 复制或共享当前进程的内存空间到新进程
 * 参数:
 *   clone_flags - 克隆标志，决定是复制还是共享
 *   proc - 新进程结构体指针
 * 返回: 成功返回0，失败返回错误码
 *
 * 说明:
 * - 如果clone_flags包含CLONE_VM，则共享内存空间
 * - 否则复制内存空间
 * - 在lab4中未实现内存管理，所以直接返回0
 * ===================================================================== */
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    // lab4中不涉及用户空间内存管理，current->mm始终为NULL
    assert(current->mm == NULL);
    // 不进行任何内存复制操作
    return 0;
}

/* =====================================================================
 * 函数: copy_thread
 * 功能: 在进程内核栈顶部设置trapframe并初始化上下文
 * 参数:
 *   proc - 目标进程结构体指针
 *   esp - 用户栈指针（内核线程为0）
 *   tf - 要复制的trapframe
 * 返回: void
 *
 * 详细说明:
 * 该函数设置新进程的执行上下文：
 * 1. 在内核栈顶部放置trapframe副本
 * 2. 设置子进程的a0寄存器为0（标识这是子进程）
 * 3. 设置栈指针（用户栈或trapframe）
 * 4. 设置上下文的返回地址为forkret
 * 5. 设置上下文的栈指针指向trapframe
 *
 * 内存布局：
 * 内核栈底 <-- kstack
 *           ...
 * 内核栈顶 <-- kstack + KSTACKSIZE
 *           <-- trapframe (sizeof(struct trapframe)大小)
 * ===================================================================== */
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // 在内核栈顶部设置trapframe
    // 栈从高地址向低地址增长，所以trapframe放在栈顶
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));

    // 复制trapframe内容
    *(proc->tf) = *tf;

    // ========== 子进程标识设置 ==========
    // 设置a0为0，让子进程知道自己是刚被fork出来的
    // 在kernel_thread_entry中会检查这个值
    proc->tf->gpr.a0 = 0;

    // ========== 栈指针设置 ==========
    // 如果esp为0（内核线程），栈指针指向trapframe
    // 否则指向用户栈
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // ========== 上下文初始化 ==========
    // 设置上下文的返回地址：当switch_to切换到新进程时，从forkret开始执行
    proc->context.ra = (uintptr_t)forkret;
    // 设置上下文的栈指针：指向trapframe
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* =====================================================================
 * 函数: do_fork
 * 功能: 创建新的子进程（核心进程创建函数）
 * 参数:
 *   clone_flags - 克隆标志，控制子进程的创建方式
 *   stack - 父进程的用户栈指针（内核线程为0）
 *   tf - trapframe结构体，包含子进程的初始执行状态
 * 返回: 子进程的PID（成功），错误码（失败）
 *
 * 详细说明:
 * do_fork是ucore中进程创建的核心函数，实现了Linux风格的fork/clone机制。
 * 该函数按以下步骤创建新进程：
 * 1. 分配进程结构体并初始化
 * 2. 设置父子进程关系
 * 3. 分配内核栈
 * 4. 复制/共享内存空间
 * 5. 设置执行上下文
 * 6. 分配PID并注册到系统
 * 7. 设置为可运行状态
 *
 * 错误处理：
 * - 如果进程数量达到上限，返回-E_NO_FREE_PROC
 * - 如果内存分配失败，清理已分配的资源后返回-E_NO_MEM
 *
 * 克隆标志说明：
 * - CLONE_VM: 共享地址空间（用于创建线程）
 * ===================================================================== */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    // LAB4:EXERCISE2 - 实现进程创建逻辑

    // ========== 变量声明和初始化 ==========
    int ret = -E_NO_FREE_PROC;         // 默认错误：进程数达到上限
    struct proc_struct *proc;          // 新进程结构体指针

    // ========== 1. 检查进程数量限制 ==========
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;  // 进程数已达上限，直接返回错误
    }

    // ========== 2. 分配进程结构体 ==========
    ret = -E_NO_MEM;  // 默认错误：内存不足
    if ((proc = alloc_proc()) == NULL)
    {
        goto fork_out;  // 分配失败，直接返回
    }

    // ========== 3. 设置父子进程关系 ==========
    proc->parent = current;  // 设置父进程指针

    // ========== 4. 分配内核栈 ==========
    if ((ret = setup_kstack(proc)) != 0)
    {
        goto bad_fork_cleanup_proc;  // 内核栈分配失败，清理进程结构体
    }

    // ========== 5. 复制/共享内存空间 ==========
    if ((ret = copy_mm(clone_flags, proc)) != 0)
    {
        goto bad_fork_cleanup_kstack;  // 内存复制失败，清理内核栈
    }

    // ========== 6. 设置执行上下文 ==========
    copy_thread(proc, stack, tf);

    // ========== 7. 注册进程到系统（需要关中断保证原子性）==========
    bool intr_flag;
    local_intr_save(intr_flag);  // 关闭中断，保证操作原子性
    {
        // 分配唯一的PID
        proc->pid = get_pid();

        // 将进程添加到哈希表（用于PID查找）
        hash_proc(proc);

        // 将进程添加到进程链表（用于调度）
        list_add(&proc_list, &(proc->list_link));

        // 增加进程计数
        nr_process++;
    }
    local_intr_restore(intr_flag);  // 恢复中断状态

    // ========== 8. 设置进程为可运行状态 ==========
    wakeup_proc(proc);

    // ========== 9. 返回子进程PID ==========
    ret = proc->pid;

fork_out:
    return ret;

// ========== 错误处理：清理已分配的资源 ==========
bad_fork_cleanup_kstack:
    put_kstack(proc);  // 释放内核栈

bad_fork_cleanup_proc:
    kfree(proc);       // 释放进程结构体
    goto fork_out;
}

// ============================================================================
// 进程退出和系统初始化函数
// ============================================================================

/* =====================================================================
 * 函数: do_exit
 * 功能: 终止当前进程（进程退出处理函数）
 * 参数:
 *   error_code - 退出错误码
 * 返回: 从不返回（会切换到其他进程）
 *
 * 详细说明:
 * 该函数处理进程的正常退出，包括：
 * 1. 释放进程的内存空间（exit_mmap、put_pgdir、mm_destroy）
 * 2. 将进程状态设置为PROC_ZOMBIE
 * 3. 唤醒父进程来回收子进程资源
 * 4. 切换到其他进程继续执行
 *
 * 注：在lab4中该函数未实现，仅打印panic信息
 * ===================================================================== */
int do_exit(int error_code)
{
    // LAB4中未实现进程退出功能
    panic("process exit!!.\n");
    return 0;  // 永远不会执行到这里
}

// ============================================================================
// 系统初始化相关函数
// ============================================================================

/* =====================================================================
 * 函数: init_main
 * 功能: 系统初始化主线程（第二个内核线程）
 * 参数:
 *   arg - 传递的参数字符串
 * 返回: 线程退出状态（总是0）
 *
 * 说明:
 * 该线程用于系统初始化后的工作，演示内核线程的基本功能。
 * 打印进程信息和传入的参数，然后退出。
 * ===================================================================== */
static int
init_main(void *arg)
{
    // 打印当前进程（initproc）的信息
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
            current->pid, get_proc_name(current));

    // 打印传入的参数
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");

    return 0;  // 线程正常退出
}

/* =====================================================================
 * 函数: proc_init
 * 功能: 初始化进程管理系统
 * 参数: void
 * 返回: void
 *
 * 详细说明:
 * 该函数是进程系统的初始化入口，完成以下工作：
 * 1. 初始化进程链表和PID哈希表
 * 2. 创建idle进程（PID=0）
 * 3. 验证alloc_proc函数的正确性
 * 4. 设置idle进程的基本属性
 * 5. 创建init_main线程（PID=1）
 * 6. 验证初始化结果
 *
 * idle进程特点：
 * - PID为0，是系统中第一个进程
 * - 使用预先分配的bootstack作为内核栈
 * - 始终处于可运行状态
 * ===================================================================== */
void proc_init(void)
{
    int i;

    // ========== 1. 初始化进程管理数据结构 ==========
    // 初始化进程链表（双向循环链表）
    list_init(&proc_list);

    // 初始化PID哈希表的所有桶
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    // ========== 2. 创建idle进程 ==========
    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    // ========== 3. 验证alloc_proc函数的正确性 ==========
    // 通过内存比较验证idleproc的各个字段是否正确初始化
    int *context_mem = (int *)kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    // 检查idleproc是否正确初始化
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
        idleproc->tf == NULL &&                 // trapframe为空
        !context_init_flag &&                   // context已清零
        idleproc->state == PROC_UNINIT &&       // 状态为未初始化
        idleproc->pid == -1 &&                  // PID为无效值
        idleproc->runs == 0 &&                  // 运行次数为0
        idleproc->kstack == 0 &&                // 内核栈未分配
        idleproc->need_resched == 0 &&          // 不需要调度
        idleproc->parent == NULL &&             // 无父进程
        idleproc->mm == NULL &&                 // 无内存管理结构体
        idleproc->flags == 0 &&                 // 无特殊标志
        !proc_name_flag)                        // 进程名已清零
    {
        cprintf("alloc_proc() correct!\n");
    }

    // ========== 4. 设置idle进程属性 ==========
    idleproc->pid = 0;                          // 设置PID为0
    idleproc->state = PROC_RUNNABLE;            // 设置为可运行状态
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
    idleproc->need_resched = 1;                 // 需要立即调度
    set_proc_name(idleproc, "idle");            // 设置进程名为"idle"
    nr_process++;                               // 进程计数加1

    // ========== 5. 设置当前进程为idleproc ==========
    current = idleproc;

    // ========== 6. 创建init_main线程 ==========
    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");
    }

    // ========== 7. 获取并命名init进程 ==========
    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    // ========== 8. 验证初始化结果 ==========
    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

/* =====================================================================
 * 函数: cpu_idle
 * 功能: CPU空闲循环（idle进程的主循环）
 * 参数: void
 * 返回: 从不返回（无限循环）
 *
 * 详细说明:
 * 该函数是idle进程（PID=0）的主体函数，在系统初始化完成后执行。
 * 其主要职责是：
 * 1. 持续检查当前进程是否需要重新调度
 * 2. 当need_resched标志为1时，调用schedule()进行进程调度
 * 3. 没有其他就绪进程时，idle进程会保持运行
 *
 * 这确保了系统在没有其他任务时不会"死机"，而是让CPU执行空闲循环。
 * ===================================================================== */
void cpu_idle(void)
{
    while (1)  // 无限循环
    {
        // 检查是否需要重新调度
        if (current->need_resched)
        {
            // 调用调度器进行进程切换
            schedule();
        }
        // 如果不需要调度，继续循环
    }
}
