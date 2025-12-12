#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc,
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:

  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - 分配并初始化进程控制块结构体
// 为新进程分配内存空间并初始化所有必要的字段
// 返回值: 成功返回指向新进程控制块的指针，失败返回NULL
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4:EXERCISE1 YOUR CODE
        /*
         * below fields in proc_struct need to be initialized
         *       enum proc_state state;                      // Process state
         *       int pid;                                    // Process ID
         *       int runs;                                   // the running times of Proces
         *       uintptr_t kstack;                           // Process kernel stack
         *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
         *       struct proc_struct *parent;                 // the parent process
         *       struct mm_struct *mm;                       // Process's memory management field
         *       struct context context;                     // Switch here to run process
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */

        // LAB5 YOUR CODE : (update LAB4 steps)
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */

        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
        proc->flags = 0;
        memset(proc->name, 0, sizeof(proc->name));
        proc->wait_state = 0;
        proc->cptr = proc->yptr = proc->optr = NULL;
    }
    return proc;
}

// set_proc_name - 设置进程的名称
// 将指定的名称字符串复制到进程控制块的name字段中
// 参数:
//   proc: 指向目标进程控制块的指针
//   name: 要设置的进程名称字符串
// 返回值: 返回进程名称字段的指针
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - 获取进程的名称
// 从进程控制块中获取进程名称的副本
// 参数:
//   proc: 指向目标进程控制块的指针
// 返回值: 返回进程名称字符串的指针（静态缓冲区）
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// set_links - 设置进程的关系链接
// 将进程插入到进程列表中，并建立与父进程的家族关系链接
// 参数:
//   proc: 指向要设置链接的进程控制块的指针
static void
set_links(struct proc_struct *proc)
{
    list_add(&proc_list, &(proc->list_link));
    proc->yptr = NULL;
    if ((proc->optr = proc->parent->cptr) != NULL)
    {
        proc->optr->yptr = proc;
    }
    proc->parent->cptr = proc;
    nr_process++;
}

// remove_links - 清理进程的关系链接
// 从进程列表和家族关系中移除进程的所有链接
// 参数:
//   proc: 指向要移除链接的进程控制块的指针
static void
remove_links(struct proc_struct *proc)
{
    list_del(&(proc->list_link));
    if (proc->optr != NULL)
    {
        proc->optr->yptr = proc->yptr;
    }
    if (proc->yptr != NULL)
    {
        proc->yptr->optr = proc->optr;
    }
    else
    {
        proc->parent->cptr = proc->optr;
    }
    nr_process--;
}

// get_pid - 为进程分配唯一的PID
// 从可用的PID池中分配一个未使用的进程ID
// 使用哈希表查找机制确保PID的唯一性
// 返回值: 返回分配的唯一PID
static int
get_pid(void)
{
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++last_pid >= MAX_PID)
    {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe)
    {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid)
            {
                if (++last_pid >= next_safe)
                {
                    if (last_pid >= MAX_PID)
                    {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - 让指定进程在CPU上运行
// 执行进程上下文切换，使指定进程成为当前运行进程
// 注意: 在调用switch_to之前，必须加载进程新的页目录表基地址
// 参数:
//   proc: 指向要运行的进程控制块的指针
void proc_run(struct proc_struct *proc)
{
    if (proc != current)
    {
        // LAB4:EXERCISE3 YOUR CODE
        /*
         * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
         * MACROs or Functions:
         *   local_intr_save():        Disable interrupts
         *   local_intr_restore():     Enable Interrupts
         *   lsatp():                   Modify the value of satp register
         *   switch_to():              Context switching between two processes
         */
        bool intr_flag;
        struct proc_struct *prev = current;
        local_intr_save(intr_flag);
        {
            current = proc;
            lsatp(proc->pgdir);
            switch_to(&(prev->context), &(proc->context));
        }
        local_intr_restore(intr_flag);
    }
}

// forkret - 新线程/进程的第一个内核入口点
// 新创建的线程或进程在上下文切换后首先执行的函数
// 注意: forkret的地址在copy_thread函数中设置
//       switch_to执行后，当前进程将从这里开始执行
static void
forkret(void)
{
    forkrets(current->tf);
}

// hash_proc - 将进程添加到进程哈希列表
// 根据进程PID计算哈希值，将进程插入到相应的哈希桶中
// 参数:
//   proc: 指向要添加到哈希列表的进程控制块的指针
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// unhash_proc - 从进程哈希列表删除进程
// 将进程从其所在的哈希桶中移除
// 参数:
//   proc: 指向要从哈希列表删除的进程控制块的指针
static void
unhash_proc(struct proc_struct *proc)
{
    list_del(&(proc->hash_link));
}

// find_proc - 根据PID从进程哈希列表查找进程
// 通过PID在哈希表中查找对应的进程控制块
// 参数:
//   pid: 要查找的进程ID
// 返回值: 找到返回进程控制块指针，未找到返回NULL
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
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

// kernel_thread - 使用指定函数创建内核线程
// 创建一个新的内核线程，执行指定的函数
// 注意: 临时trapframe tf的内容将在do_fork-->copy_thread函数中复制到proc->tf
// SSTATUS_SPP: 设置为supervisor模式 (内核态)
// SSTATUS_SPIE: 启用之前的全局中断 (previous interrupt enable)
// SSTATUS_SIE: 禁用当前全局中断 (global interrupt disable)
// 参数:
//   fn: 线程要执行的函数指针
//   arg: 传递给线程函数的参数
//   clone_flags: 克隆标志
// 返回值: 成功返回新线程PID，失败返回错误码
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - 为进程分配内核栈页
// 分配指定大小的页面作为进程的内核栈空间
// 参数:
//   proc: 指向需要分配内核栈的进程控制块的指针
// 返回值: 成功返回0，失败返回-E_NO_MEM
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL)
    {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - 释放进程内核栈内存空间
// 释放进程内核栈占用的物理页面
// 参数:
//   proc: 指向要释放内核栈的进程控制块的指针
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// setup_pgdir - 分配一个页面作为页目录表(PDT)
// 为内存管理结构分配并初始化页目录表
// 参数:
//   mm: 指向内存管理结构的指针
// 返回值: 成功返回0，失败返回-E_NO_MEM
static int
setup_pgdir(struct mm_struct *mm)
{
    struct Page *page;
    if ((page = alloc_page()) == NULL)
    {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir_va, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}

// put_pgdir - 释放页目录表(PDT)的内存空间
// 释放页目录表占用的物理页面
// 参数:
//   mm: 指向包含要释放页目录表的内存管理结构的指针
static void
put_pgdir(struct mm_struct *mm)
{
    free_page(kva2page(mm->pgdir));
}

// copy_mm - 根据克隆标志复制或共享当前进程的内存空间
// 如果clone_flags包含CLONE_VM，则共享内存空间；否则复制内存空间
// 参数:
//   clone_flags: 克隆标志，决定是共享还是复制内存
//   proc: 指向目标进程控制块的指针
// 返回值: 成功返回0，失败返回错误码
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    struct mm_struct *mm, *oldmm = current->mm;

    /* current is a kernel thread */
    if (oldmm == NULL)
    {
        return 0;
    }
    if (clone_flags & CLONE_VM)
    {
        mm = oldmm;
        goto good_mm;
    }
    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }
    lock_mm(oldmm);
    {
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm);

    if (ret != 0)
    {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
    proc->mm = mm;
    proc->pgdir = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}

// copy_thread - 在进程内核栈顶部设置trapframe，并设置进程的内核入口点和栈
// 将trapframe复制到进程内核栈的顶部，并初始化进程的上下文信息
// 参数:
//   proc: 指向目标进程控制块的指针
//   esp: 用户栈指针（如果为0表示创建内核线程）
//   tf: 要复制的trapframe信息
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0;
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

// do_fork - 创建新的子进程，是fork系统调用的核心实现
// 执行完整的进程创建流程：分配进程控制块、设置内核栈、复制/共享内存空间等
// 参数:
//   clone_flags: 克隆标志，控制子进程的创建方式(内存共享等)
//   stack: 父进程的用户栈指针，如果为0表示创建内核线程
//   tf: trapframe信息，将被复制到子进程的proc->tf
// 返回值: 成功返回子进程PID，失败返回错误码
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    // LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

    if ((proc = alloc_proc()) == NULL)
    {
        goto fork_out;
    }

    proc->parent = current;
    current->wait_state = 0;

    if (setup_kstack(proc) != 0)
    {
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
    ret = proc->pid;

    // LAB5 YOUR CODE : (update LAB4 steps)
    // TIPS: you should modify your written code in lab4(step1 and step5), not add more code.
    /* Some Functions
     *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process
     *    -------------------
     *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
     *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
     */

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

// do_exit - 进程退出处理，由sys_exit系统调用触发，不会返回
// 执行进程退出流程：释放内存空间、设置僵尸状态、唤醒父进程、调度其他进程
// 步骤:
//   1. 调用exit_mmap、put_pgdir、mm_destroy释放进程几乎所有内存空间
//   2. 设置进程状态为PROC_ZOMBIE，调用wakeup_proc唤醒父进程回收自己
//   3. 调用调度器切换到其他进程
// 参数:
//   error_code: 退出错误码，传递给父进程
// 返回值: 此函数不会返回
int do_exit(int error_code)
{
    if (current == idleproc)
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
    if (mm != NULL)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
        if (proc->wait_state == WT_CHILD)
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
        {
            proc = current->cptr;
            current->cptr = proc->optr;

            proc->yptr = NULL;
            if ((proc->optr = initproc->cptr) != NULL)
            {
                initproc->cptr->yptr = proc;
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
                {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
    panic("do_exit will not return!! %d.\n", current->pid);
}

// load_icode - 将ELF格式的二进制程序内容加载为当前进程的新内容
// 执行完整的ELF程序加载过程：解析ELF文件格式，将程序的各个段映射到进程的虚拟内存空间，
// 设置程序入口点和用户栈，最终使进程可以执行加载的程序
// 参数:
//   binary: 二进制程序内容的内存地址
//   size: 二进制程序内容的大小
// 返回值: 成功返回0，失败返回错误码
static int
load_icode(unsigned char *binary, size_t size)
{
    // 确保当前进程没有内存管理结构，这是execve的要求
    if (current->mm != NULL)
    {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;

    // 步骤(1): 为当前进程创建新的内存管理结构(mm_struct)
    // mm_struct包含进程的页目录表指针和虚拟内存区域链表
    if ((mm = mm_create()) == NULL)
    {
        goto bad_mm;
    }

    // 步骤(2): 创建新的页目录表(PDT)，并设置mm->pgdir为页目录表的内核虚拟地址
    // 页目录表用于管理进程的虚拟地址空间到物理地址空间的映射
    if (setup_pgdir(mm) != 0)
    {
        goto bad_pgdir_cleanup_mm;
    }
    // 步骤(3): 将二进制程序的TEXT/DATA段复制到进程内存空间，并构建BSS段
    struct Page *page;

    // (3.1) 获取二进制程序的文件头(ELF格式)
    // ELF文件头包含程序的基本信息，如入口点、段表偏移等
    struct elfhdr *elf = (struct elfhdr *)binary;

    // (3.2) 获取程序段头表的入口
    // 段头表描述了程序中各个段的位置、大小和属性
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);

    // (3.3) 验证程序是否为有效的ELF格式
    // 通过检查魔数来确认文件格式
    if (elf->e_magic != ELF_MAGIC)
    {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;

    // 遍历所有程序段头，处理需要加载的段
    for (; ph < ph_end; ph++)
    {
        // (3.4) 查找所有程序段头，只处理需要加载的段(ELF_PT_LOAD类型)
        if (ph->p_type != ELF_PT_LOAD)
        {
            continue;  // 跳过不需要加载的段
        }

        // 验证段的合法性：文件大小不能大于内存大小
        if (ph->p_filesz > ph->p_memsz)
        {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }

        // 如果文件大小为0，说明这个段只在内存中存在(可能是BSS段)
        if (ph->p_filesz == 0)
        {
            // 继续处理，但需要初始化内存空间
        }

        // (3.5) 调用mm_map函数设置新的虚拟内存区域(VMA)
        // 根据段的权限标志设置虚拟内存权限
        vm_flags = 0, perm = PTE_U | PTE_V;  // 用户态可访问，页表项有效
        if (ph->p_flags & ELF_PF_X)
            vm_flags |= VM_EXEC;     // 可执行权限
        if (ph->p_flags & ELF_PF_W)
            vm_flags |= VM_WRITE;    // 可写权限
        if (ph->p_flags & ELF_PF_R)
            vm_flags |= VM_READ;     // 可读权限

        // 为RISC-V架构修改权限位
        // RISC-V的页表项权限位与x86不同，需要特殊处理
        if (vm_flags & VM_READ)
            perm |= PTE_R;           // 读权限
        if (vm_flags & VM_WRITE)
            perm |= (PTE_W | PTE_R); // 写权限(必须同时有读权限)
        if (vm_flags & VM_EXEC)
            perm |= PTE_X;           // 执行权限

        // 在内存管理结构中映射虚拟地址空间
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
        {
            goto bad_cleanup_mmap;
        }
        // 获取段在文件中的数据起始位置
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

        // (3.6) 分配内存，并将每个程序段的内容复制到进程的内存空间
        end = ph->p_va + ph->p_filesz;

        // (3.6.1) 复制二进制程序的TEXT/DATA段
        // TEXT段包含可执行代码，DATA段包含已初始化的全局变量
        while (start < end)
        {
            // 为当前页分配物理页面
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
            {
                goto bad_cleanup_mmap;
            }

            // 计算在页面内的偏移量和需要复制的大小
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la)
            {
                size -= la - end;  // 调整大小以适应段边界
            }

            // 将文件中的数据复制到分配的物理页面
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

        // (3.6.2) 构建二进制程序的BSS段
        // BSS段包含未初始化的全局变量和静态变量，需要初始化为0
        end = ph->p_va + ph->p_memsz;

        // 处理当前页面中剩余的BSS区域
        if (start < la)
        {
            /* ph->p_memsz == ph->p_filesz 表示没有BSS区域 */
            if (start == end)
            {
                continue;  // 没有BSS区域，直接处理下一个段
            }

            // 计算当前页面中BSS区域的位置和大小
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la)
            {
                size -= la - end;
            }

            // 将BSS区域初始化为0
            memset(page2kva(page) + off, 0, size);
            start += size;

            // 断言确保处理正确
            assert((end < la && start == end) || (end >= la && start == la));
        }

        // 处理完整的页面作为BSS区域
        while (start < end)
        {
            // 为BSS区域分配新的物理页面
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
            {
                goto bad_cleanup_mmap;
            }

            // 计算页面内的BSS区域大小
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la)
            {
                size -= la - end;
            }

            // 将整个页面初始化为0
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }

    // 步骤(4): 构建用户栈内存
    // 用户栈用于存放函数调用时的局部变量、返回地址等信息
    vm_flags = VM_READ | VM_WRITE | VM_STACK;  // 用户栈需要读写权限，并标记为栈区域
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
    {
        goto bad_cleanup_mmap;
    }

    // 为用户栈分配实际的物理页面
    // 预先分配几个页面以确保栈的初始可用性
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);

    // 步骤(5): 设置当前进程的内存管理和页表
    // 增加内存管理结构的引用计数，避免被意外释放
    mm_count_inc(mm);
    current->mm = mm;                    // 设置进程的内存管理结构
    current->pgdir = PADDR(mm->pgdir);   // 设置进程的页目录表物理地址
    lsatp(PADDR(mm->pgdir));             // 设置satp寄存器，切换到新的页表

    // 步骤(6): 为用户环境设置trapframe
    // trapframe保存了从内核态切换到用户态时需要恢复的上下文信息
    struct trapframe *tf = current->tf;

    // 保存当前的sstatus状态，然后清空trapframe
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));

    /* LAB5:EXERCISE1 设置trapframe的关键字段 */
    tf->gpr.sp = USTACKTOP;              // 设置用户栈顶指针
    tf->epc = elf->e_entry;              // 设置程序入口点(从ELF头获取)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
    // 设置状态寄存器：清除特权模式位(SPP)和中断使能位(SIE)，
    // 但设置前一个中断使能位(SPIE)，表示从内核返回用户态时恢复中断
    // 加载成功，设置返回值
    ret = 0;

    // 函数正常出口
out:
    return ret;

// 错误处理：清理已分配的内存映射
bad_cleanup_mmap:
    exit_mmap(mm);          // 清理虚拟内存区域映射
    goto bad_elf_cleanup_pgdir;

// 错误处理：清理页目录表
bad_elf_cleanup_pgdir:
    put_pgdir(mm);          // 释放页目录表
    goto bad_pgdir_cleanup_mm;

// 错误处理：销毁内存管理结构
bad_pgdir_cleanup_mm:
    mm_destroy(mm);         // 销毁内存管理结构
    goto bad_mm;

// 最终错误出口
bad_mm:
    goto out;
}

// do_execve - 回收当前进程的内存空间并加载新的二进制程序
// 首先释放当前进程的内存管理结构，然后加载新的ELF程序到内存空间
// 参数:
//   name: 程序名称字符串
//   len: 程序名称长度
//   binary: 二进制程序数据
//   size: 二进制程序数据大小
// 返回值: 成功返回0，失败返回错误码
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size)
{
    struct mm_struct *mm = current->mm;
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
    {
        return -E_INVAL;
    }
    if (len > PROC_NAME_LEN)
    {
        len = PROC_NAME_LEN;
    }

    char local_name[PROC_NAME_LEN + 1];
    memset(local_name, 0, sizeof(local_name));
    memcpy(local_name, name, len);

    if (mm != NULL)
    {
        cputs("mm != NULL");
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
    }
    int ret;
    if ((ret = load_icode(binary, size)) != 0)
    {
        goto execve_exit;
    }
    set_proc_name(current, local_name);
    return 0;

execve_exit:
    do_exit(ret);
    panic("already exit: %e.\n", ret);
}

// do_yield - 让出CPU，请求调度器进行重新调度
// 设置当前进程的重调度标志，让调度器在下次调度时重新选择进程
// 返回值: 总是返回0
int do_yield(void)
{
    current->need_resched = 1;  // 设置重调度标志
    return 0;
}

// do_wait - 等待一个或所有子进程进入PROC_ZOMBIE状态，并释放其内核栈和进程结构体
// 等待指定的子进程或任意子进程结束，并回收其所有资源
// 注意: 只有在do_wait函数执行后，子进程的所有资源才会被完全释放
// 参数:
//   pid: 要等待的子进程PID，如果为0则等待任意子进程
//   code_store: 存储子进程退出码的指针
// 返回值: 成功返回0，失败返回错误码
int do_wait(int pid, int *code_store)
{
    struct mm_struct *mm = current->mm;
    if (code_store != NULL)
    {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
        {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0)
    {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found;
            }
        }
    }
    else
    {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr)
        {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE)
            {
                goto found;
            }
        }
    }
    if (haskid)
    {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING)
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc)
    {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL)
    {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}

// do_kill - 通过设置PF_EXITING标志终止指定PID的进程
// 向指定进程发送终止信号，使其在适当时候退出
// 参数:
//   pid: 要终止的进程ID
// 返回值: 成功返回0，失败返回错误码
int do_kill(int pid)
{
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL)
    {
        if (!(proc->flags & PF_EXITING))
        {
            proc->flags |= PF_EXITING;
            if (proc->wait_state & WT_INTERRUPTED)
            {
                wakeup_proc(proc);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}

// kernel_execve - 通过SYS_exec系统调用执行用户程序，由user_main内核线程调用
// 使用内联汇编直接调用系统调用来执行用户程序
// 参数:
//   name: 程序名字符串
//   binary: 程序二进制数据
//   size: 二进制数据大小
// 返回值: 系统调用返回值，存储在ret中，通过ebreak触发异常进入系统调用处理
static int
kernel_execve(const char *name, unsigned char *binary, size_t size)
{
    int64_t ret = 0, len = strlen(name);
    // 通过内联汇编调用系统调用 SYS_exec
    // 汇编代码解释:
    // li a0, %1        - a0 = SYS_exec (系统调用号)
    // lw a1, %2        - a1 = name (程序名)
    // lw a2, %3        - a2 = len (程序名长度)
    // lw a3, %4        - a3 = binary (二进制数据指针)
    // lw a4, %5        - a4 = size (二进制数据大小)
    // li a7, 10        - a7 = 10 (系统调用编号，实际由SYS_exec宏定义)
    // ebreak           - 触发断点异常，进入系统调用处理
    // sw a0, %0        - 将返回值存储到ret变量
    asm volatile(
        "li a0, %1\n"
        "lw a1, %2\n"
        "lw a2, %3\n"
        "lw a3, %4\n"
        "lw a4, %5\n"
        "li a7, 10\n"
        "ebreak\n"
        "sw a0, %0\n"
        : "=m"(ret)
        : "i"(SYS_exec), "m"(name), "m"(len), "m"(binary), "m"(size)
        : "memory");
    cprintf("ret = %d\n", ret);
    return ret;
}

#define __KERNEL_EXECVE(name, binary, size) ({           \
    cprintf("kernel_execve: pid = %d, name = \"%s\".\n", \
            current->pid, name);                         \
    kernel_execve(name, binary, (size_t)(size));         \
})

#define KERNEL_EXECVE(x) ({                                    \
    extern unsigned char _binary_obj___user_##x##_out_start[], \
        _binary_obj___user_##x##_out_size[];                   \
    __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,    \
                    _binary_obj___user_##x##_out_size);        \
})

#define __KERNEL_EXECVE2(x, xstart, xsize) ({   \
    extern unsigned char xstart[], xsize[];     \
    __KERNEL_EXECVE(#x, xstart, (size_t)xsize); \
})

#define KERNEL_EXECVE2(x, xstart, xsize) __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - 用于执行用户程序的内核线程
// 内核线程的主要功能是执行用户程序，通过kernel_execve调用系统调用
// 参数:
//   arg: 线程参数（未使用）
// 返回值: 正常情况下不会返回，失败时会调用panic
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
}

// init_main - 第二个内核线程，用于创建user_main内核线程
// 负责创建用户程序执行线程，并等待所有用户进程结束
// 参数:
//   arg: 线程参数（未使用）
// 返回值: 成功返回0
static int
init_main(void *arg)
{
    size_t nr_free_pages_store = nr_free_pages();
    size_t kernel_allocated_store = kallocated();

    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0)
    {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
    assert(nr_process == 2);
    assert(list_next(&proc_list) == &(initproc->list_link));
    assert(list_prev(&proc_list) == &(initproc->list_link));

    cprintf("init check memory pass.\n");
    return 0;
}

// proc_init - 初始化进程管理系统
// 创建第一个内核线程idleproc（空闲进程）和第二个内核线程init_main
// 这是进程系统初始化的核心函数
void proc_init(void)
{
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process++;

    current = idleproc;

    int pid = kernel_thread(init_main, NULL, 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - 在kern_init结束时，第一个内核线程idleproc将执行以下工作
// 空闲进程的主要循环，不断检查是否有进程需要重新调度
void cpu_idle(void)
{
    while (1)
    {
        if (current->need_resched)
        {
            schedule();
        }
    }
}
