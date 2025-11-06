/**
 * @file kern/process/switch.S
 * @brief 进程上下文切换汇编实现
 *
 * 该文件实现了进程上下文切换的核心汇编代码。
 * 上下文切换是操作系统中最关键的操作之一，负责保存和恢复进程的执行状态。
 */

#include <riscv.h>

.text

/**
 * @brief 进程上下文切换函数
 *
 * switch_to是进程切换的核心函数，实现了从一个进程到另一个进程的上下文切换。
 * 该函数保存当前进程(from)的上下文，并恢复目标进程(to)的上下文。
 *
 * 函数签名：void switch_to(struct proc_struct* from, struct proc_struct* to)
 * 参数：
 *   a0 (from): 当前进程的proc_struct指针
 *   a1 (to):   目标进程的proc_struct指针
 *
 * 执行流程：
 * 1. 保存from进程的上下文到from->context
 * 2. 从to->context恢复目标进程的上下文
 * 3. 返回到目标进程的执行点
 *
 * 保存的寄存器（按context结构体顺序）：
 * - ra (x1):  返回地址寄存器
 * - sp (x2):  栈指针寄存器
 * - s0-s11:   保存寄存器(共12个)
 *
 * 内存布局：
 * context结构体中的寄存器按以下顺序存储：
 * offset 0:  ra
 * offset 8:  sp
 * offset 16: s0
 * offset 24: s1
 * ...
 * offset 104: s11
 *
 * 注意：
 * - 不保存/恢复临时寄存器(t0-t6,a0-a7)，因为它们在函数调用中会被覆盖
 * - 不保存/恢复全局指针(gp)和线程指针(tp)，因为它们是进程共享的
 * - 切换完成后，目标进程从ret指令返回，回到切换前的执行点
 */
.globl switch_to
switch_to:
    # ========== 保存当前进程(from)的上下文 ==========
    # 将当前CPU中的寄存器值保存到from->context结构体中

    # 保存返回地址寄存器 (context.ra)
    STORE ra, 0*REGBYTES(a0)

    # 保存栈指针寄存器 (context.sp)
    STORE sp, 1*REGBYTES(a0)

    # 保存保存寄存器s0-s11 (context.s0 ~ context.s11)
    STORE s0, 2*REGBYTES(a0)
    STORE s1, 3*REGBYTES(a0)
    STORE s2, 4*REGBYTES(a0)
    STORE s3, 5*REGBYTES(a0)
    STORE s4, 6*REGBYTES(a0)
    STORE s5, 7*REGBYTES(a0)
    STORE s6, 8*REGBYTES(a0)
    STORE s7, 9*REGBYTES(a0)
    STORE s8, 10*REGBYTES(a0)
    STORE s9, 11*REGBYTES(a0)
    STORE s10, 12*REGBYTES(a0)
    STORE s11, 13*REGBYTES(a0)

    # ========== 恢复目标进程(to)的上下文 ==========
    # 从to->context结构体中恢复寄存器值到CPU

    # 恢复返回地址寄存器
    LOAD ra, 0*REGBYTES(a1)

    # 恢复栈指针寄存器
    LOAD sp, 1*REGBYTES(a1)

    # 恢复保存寄存器s0-s11
    LOAD s0, 2*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a1)
    LOAD s2, 4*REGBYTES(a1)
    LOAD s3, 5*REGBYTES(a1)
    LOAD s4, 6*REGBYTES(a1)
    LOAD s5, 7*REGBYTES(a1)
    LOAD s6, 8*REGBYTES(a1)
    LOAD s7, 9*REGBYTES(a1)
    LOAD s8, 10*REGBYTES(a1)
    LOAD s9, 11*REGBYTES(a1)
    LOAD s10, 12*REGBYTES(a1)
    LOAD s11, 13*REGBYTES(a1)

    # ========== 返回到目标进程 ==========
    # ret指令相当于"jalr x0, ra, 0"，跳转到ra指向的地址
    # 对于目标进程，ra指向了切换发生前的执行点
    ret
