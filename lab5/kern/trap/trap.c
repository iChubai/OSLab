#include <defs.h>
#include <mmu.h>
#include <memlayout.h>
#include <clock.h>
#include <trap.h>
#include <riscv.h>
#include <stdio.h>
#include <assert.h>
#include <console.h>
#include <vmm.h>
#include <kdebug.h>
#include <unistd.h>
#include <syscall.h>
#include <error.h>
#include <sched.h>
#include <sync.h>
#include <sbi.h>
#include <pmm.h>
#include <string.h>

#define TICK_NUM 100

static int num = 0;

static void print_ticks()
{
    cprintf("%d ticks\n", TICK_NUM);
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
}

// trap_in_kernel - 检查异常是否发生在内核模式
// 通过检查sstatus寄存器的SPP位(SSTATUS_SPP)来判断
// SPP=1: 内核模式, SPP=0: 用户模式
bool trap_in_kernel(struct trapframe *tf)
{
    return (tf->status & SSTATUS_SPP) != 0;
}

void print_trapframe(struct trapframe *tf)
{
    cprintf("trapframe at %p\n", tf);
    // cprintf("trapframe at 0x%x\n", tf);
    print_regs(&tf->gpr);
    cprintf("  status   0x%08x\n", tf->status);
    cprintf("  epc      0x%08x\n", tf->epc);
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
    cprintf("  ra       0x%08x\n", gpr->ra);
    cprintf("  sp       0x%08x\n", gpr->sp);
    cprintf("  gp       0x%08x\n", gpr->gp);
    cprintf("  tp       0x%08x\n", gpr->tp);
    cprintf("  t0       0x%08x\n", gpr->t0);
    cprintf("  t1       0x%08x\n", gpr->t1);
    cprintf("  t2       0x%08x\n", gpr->t2);
    cprintf("  s0       0x%08x\n", gpr->s0);
    cprintf("  s1       0x%08x\n", gpr->s1);
    cprintf("  a0       0x%08x\n", gpr->a0);
    cprintf("  a1       0x%08x\n", gpr->a1);
    cprintf("  a2       0x%08x\n", gpr->a2);
    cprintf("  a3       0x%08x\n", gpr->a3);
    cprintf("  a4       0x%08x\n", gpr->a4);
    cprintf("  a5       0x%08x\n", gpr->a5);
    cprintf("  a6       0x%08x\n", gpr->a6);
    cprintf("  a7       0x%08x\n", gpr->a7);
    cprintf("  s2       0x%08x\n", gpr->s2);
    cprintf("  s3       0x%08x\n", gpr->s3);
    cprintf("  s4       0x%08x\n", gpr->s4);
    cprintf("  s5       0x%08x\n", gpr->s5);
    cprintf("  s6       0x%08x\n", gpr->s6);
    cprintf("  s7       0x%08x\n", gpr->s7);
    cprintf("  s8       0x%08x\n", gpr->s8);
    cprintf("  s9       0x%08x\n", gpr->s9);
    cprintf("  s10      0x%08x\n", gpr->s10);
    cprintf("  s11      0x%08x\n", gpr->s11);
    cprintf("  t3       0x%08x\n", gpr->t3);
    cprintf("  t4       0x%08x\n", gpr->t4);
    cprintf("  t5       0x%08x\n", gpr->t5);
    cprintf("  t6       0x%08x\n", gpr->t6);
}

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
    {
    case IRQ_U_SOFT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_SOFT:
        cprintf("Supervisor software interrupt\n");
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
        break;
    case IRQ_U_TIMER:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_TIMER:
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // cprintf("Supervisor timer interrupt\n");
        /* LAB3 EXERCISE1   YOUR CODE :  */
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();
        ticks++;
        if (ticks % 100 == 0) {
            cprintf("100 ticks\n");
            num++;
            print_ticks();
        }
        current->need_resched = 1;
        if (num == 10) {
            sbi_shutdown();
        }
        break;
    case IRQ_H_TIMER:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_TIMER:
        cprintf("Machine software interrupt\n");
        break;
    case IRQ_U_EXT:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_EXT:
        cprintf("Supervisor external interrupt\n");
        break;
    case IRQ_H_EXT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_EXT:
        cprintf("Machine software interrupt\n");
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
// exception_handler - 异常处理分发器，根据异常原因调用相应处理
// tf: trapframe指针，包含异常发生时的完整上下文信息
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)  // 根据异常原因(scause寄存器)进行分发
    {
    case CAUSE_MISALIGNED_FETCH:     // 指令地址未对齐
        cprintf("Instruction address misaligned\n");
        break;
    case CAUSE_FETCH_ACCESS:         // 指令访问错误(页错误)
        cprintf("Instruction access fault\n");
        break;
    case CAUSE_ILLEGAL_INSTRUCTION:  // 非法指令
        cprintf("Illegal instruction\n");
        break;
    case CAUSE_BREAKPOINT:           // 断点异常(ebreak指令)
        cprintf("Breakpoint\n");
        if (tf->gpr.a7 == 10)        // 特殊标识，表示内核系统调用
        {
            tf->epc += 4;           // 跳过ebreak指令
            syscall();              // 执行系统调用
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);  // 返回处理
        }
        break;
    case CAUSE_MISALIGNED_LOAD:
        cprintf("Load address misaligned\n");
        break;
    case CAUSE_LOAD_ACCESS:
        cprintf("Load access fault\n");
        break;
    case CAUSE_MISALIGNED_STORE:
        panic("AMO address misaligned\n");
        break;
    case CAUSE_STORE_ACCESS:
        cprintf("Store/AMO access fault\n");
        break;
    case CAUSE_USER_ECALL:
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_HYPERVISOR_ECALL:
        cprintf("Environment call from H-mode\n");
        break;
    case CAUSE_MACHINE_ECALL:
        cprintf("Environment call from M-mode\n");
        break;
    case CAUSE_FETCH_PAGE_FAULT:
        cprintf("Instruction page fault\n");
        break;
    case CAUSE_LOAD_PAGE_FAULT:
        cprintf("Load page fault\n");
        break;
    case CAUSE_STORE_PAGE_FAULT:
    {
        if (current != NULL && current->mm != NULL)
        {
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
            if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW))
            {
                uint32_t perm = (*ptep & PTE_USER);
                struct Page *page = pte2page(*ptep);
                if (page_ref(page) > 1)
                {
                    struct Page *npage = alloc_page();
                    if (npage == NULL)
                    {
                        panic("COW: no mem\n");
                    }
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
                    perm = (perm & ~PTE_COW) | PTE_W;
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
                    {
                        panic("COW: insert fail\n");
                    }
                }
                else
                {
                    perm = (perm & ~PTE_COW) | PTE_W;
                    *ptep = pte_create(page2ppn(page), perm | PTE_V);
                    tlb_invalidate(current->mm->pgdir, va);
                }
                break;
            }
        }
        cprintf("Store/AMO page fault\n");
        break;
    }
    default:
        print_trapframe(tf);
        break;
    }
}

// trap_dispatch - 异常/中断分发器，根据cause值区分中断和异常
// RISC-V中：cause最高位为1表示中断，为0表示异常
static inline void trap_dispatch(struct trapframe *tf)
{
    if ((intptr_t)tf->cause < 0)  // cause最高位为1，表示中断
    {
        // interrupts - 调用中断处理函数
        interrupt_handler(tf);
    }
    else  // cause最高位为0，表示异常
    {
        // exceptions - 调用异常处理函数
        exception_handler(tf);
    }
}

/* *
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
// trap - 异常/中断处理主函数
// tf: 指向trapframe结构的指针，包含完整的异常上下文
void trap(struct trapframe *tf)
{
    // 根据异常类型进行分发处理
    // 如果当前进程不存在(系统初始化阶段)，直接处理异常
    if (current == NULL)
    {
        trap_dispatch(tf);
    }
    else
    {
        // 保存当前进程的旧trapframe指针
        struct trapframe *otf = current->tf;
        // 设置当前进程的trapframe为新的异常上下文
        current->tf = tf;
        // 判断异常是否发生在内核模式
        bool in_kernel = trap_in_kernel(tf);
        // 根据异常类型进行具体处理(系统调用、页面错误等)
        trap_dispatch(tf);
        // 恢复当前进程的原始trapframe
        current->tf = otf;
        // 如果异常发生在用户模式，需要进行进程状态检查
        if (!in_kernel)
        {
            // 如果进程正在退出，终止进程
            if (current->flags & PF_EXITING)
            {
                do_exit(-E_KILLED);
            }
            // 如果进程需要调度，执行调度
            if (current->need_resched)
            {
                schedule();
            }
        }
    }
}
