#include <riscv.h>

    .altmacro              # 启用替代宏语法
    .align 2               # 2字节对齐

    # SAVE_ALL 宏：保存所有寄存器到内核栈，建立trapframe
    # 用于异常/中断进入时的上下文保存
    .macro SAVE_ALL
    LOCAL _restore_kernel_sp
    LOCAL _save_context

    # 如果从用户空间进入，保存用户栈指针并加载内核栈指针
    # 如果从内核进入，sscratch包含0，继续使用当前栈
    csrrw sp, sscratch, sp          # 交换sp和sscratch，获取内核栈
    bnez sp, _save_context          # 如果sp不为0，说明从用户空间进入

_restore_kernel_sp:
    csrr sp, sscratch               # 从sscratch恢复内核栈指针
_save_context:
    addi sp, sp, -36 * REGBYTES     # 为trapframe分配栈空间(36个寄存器)
    # 保存通用寄存器 x0-x31 (x2/sp已在之前处理)
    STORE x0, 0*REGBYTES(sp)
    STORE x1, 1*REGBYTES(sp)       # ra (返回地址)
    STORE x3, 3*REGBYTES(sp)       # gp (全局指针)
    STORE x4, 4*REGBYTES(sp)       # tp (线程指针)
    STORE x5, 5*REGBYTES(sp)
    STORE x6, 6*REGBYTES(sp)
    STORE x7, 7*REGBYTES(sp)
    STORE x8, 8*REGBYTES(sp)       # s0/fp (帧指针)
    STORE x9, 9*REGBYTES(sp)       # s1
    STORE x10, 10*REGBYTES(sp)     # a0 (系统调用返回值/参数)
    STORE x11, 11*REGBYTES(sp)     # a1
    STORE x12, 12*REGBYTES(sp)     # a2
    STORE x13, 13*REGBYTES(sp)     # a3
    STORE x14, 14*REGBYTES(sp)     # a4
    STORE x15, 15*REGBYTES(sp)     # a5
    STORE x16, 16*REGBYTES(sp)     # a6
    STORE x17, 17*REGBYTES(sp)     # a7
    STORE x18, 18*REGBYTES(sp)     # s2
    STORE x19, 19*REGBYTES(sp)     # s3
    STORE x20, 20*REGBYTES(sp)     # s4
    STORE x21, 21*REGBYTES(sp)     # s5
    STORE x22, 22*REGBYTES(sp)     # s6
    STORE x23, 23*REGBYTES(sp)     # s7
    STORE x24, 24*REGBYTES(sp)     # s8
    STORE x25, 25*REGBYTES(sp)     # s9
    STORE x26, 26*REGBYTES(sp)     # s10
    STORE x27, 27*REGBYTES(sp)     # s11
    STORE x28, 28*REGBYTES(sp)     # t3
    STORE x29, 29*REGBYTES(sp)     # t4
    STORE x30, 30*REGBYTES(sp)     # t5
    STORE x31, 31*REGBYTES(sp)     # t6

    # 保存关键CSR寄存器到trapframe
    # 设置sscratch为0，用于识别递归异常是否来自内核
    csrrw s0, sscratch, x0          # 保存原sscratch，清零sscratch
    csrr s1, sstatus                # 保存状态寄存器
    csrr s2, sepc                   # 保存异常程序计数器
    csrr s3, 0x143                  # stval (异常值)
    csrr s4, scause                 # 保存异常原因

    STORE s0, 2*REGBYTES(sp)        # 保存原栈指针(x2)
    STORE s1, 32*REGBYTES(sp)       # sstatus
    STORE s2, 33*REGBYTES(sp)       # sepc
    STORE s3, 34*REGBYTES(sp)       # stval
    STORE s4, 35*REGBYTES(sp)       # scause
    .endm

    # RESTORE_ALL 宏：从内核栈恢复所有寄存器，清理trapframe
    # 用于异常/中断返回时的上下文恢复
    .macro RESTORE_ALL
    LOCAL _save_kernel_sp
    LOCAL _restore_context

    LOAD s1, 32*REGBYTES(sp)        # 恢复sstatus到s1
    LOAD s2, 33*REGBYTES(sp)        # 恢复sepc到s2

    andi s0, s1, SSTATUS_SPP         # 检查特权级(SSTATUS_SPP位)
    bnez s0, _restore_context        # 如果是内核模式，跳转恢复上下文

_save_kernel_sp:
    # 保存展开的内核栈指针到sscratch，用于下次异常处理
    addi s0, sp, 36 * REGBYTES      # 计算栈顶位置
    csrw sscratch, s0               # 保存到sscratch
_restore_context:
    csrw sstatus, s1                 # 恢复状态寄存器
    csrw sepc, s2                    # 恢复异常程序计数器

    # 恢复所有通用寄存器 (顺序与保存相反，最后恢复sp)
    LOAD x1, 1*REGBYTES(sp)         # ra
    LOAD x3, 3*REGBYTES(sp)         # gp
    LOAD x4, 4*REGBYTES(sp)         # tp
    LOAD x5, 5*REGBYTES(sp)
    LOAD x6, 6*REGBYTES(sp)
    LOAD x7, 7*REGBYTES(sp)
    LOAD x8, 8*REGBYTES(sp)         # s0/fp
    LOAD x9, 9*REGBYTES(sp)         # s1
    LOAD x10, 10*REGBYTES(sp)       # a0
    LOAD x11, 11*REGBYTES(sp)       # a1
    LOAD x12, 12*REGBYTES(sp)       # a2
    LOAD x13, 13*REGBYTES(sp)       # a3
    LOAD x14, 14*REGBYTES(sp)       # a4
    LOAD x15, 15*REGBYTES(sp)       # a5
    LOAD x16, 16*REGBYTES(sp)       # a6
    LOAD x17, 17*REGBYTES(sp)       # a7
    LOAD x18, 18*REGBYTES(sp)       # s2
    LOAD x19, 19*REGBYTES(sp)       # s3
    LOAD x20, 20*REGBYTES(sp)       # s4
    LOAD x21, 21*REGBYTES(sp)       # s5
    LOAD x22, 22*REGBYTES(sp)       # s6
    LOAD x23, 23*REGBYTES(sp)       # s7
    LOAD x24, 24*REGBYTES(sp)       # s8
    LOAD x25, 25*REGBYTES(sp)       # s9
    LOAD x26, 26*REGBYTES(sp)       # s10
    LOAD x27, 27*REGBYTES(sp)       # s11
    LOAD x28, 28*REGBYTES(sp)       # t3
    LOAD x29, 29*REGBYTES(sp)       # t4
    LOAD x30, 30*REGBYTES(sp)       # t5
    LOAD x31, 31*REGBYTES(sp)       # t6
    # 最后恢复栈指针sp，确保所有其他寄存器已恢复
    LOAD x2, 2*REGBYTES(sp)         # sp (栈指针)
    .endm

    # __alltraps: 异常/中断统一入口点
    # 当发生异常/中断时，硬件自动跳转到此地址
    .globl __alltraps
__alltraps:
    SAVE_ALL                        # 保存所有上下文到trapframe

    move  a0, sp                    # a0 = 当前栈指针(指向trapframe)
    jal trap                        # 调用C函数trap()进行异常处理
    # jal返回后sp应该与调用前相同

    # __trapret: 异常/中断返回点
    # 从异常处理返回到被中断的代码
    .globl __trapret
__trapret:
    RESTORE_ALL                     # 恢复所有上下文
    # return from supervisor call
    sret                            # 执行sret指令返回，恢复PC和状态
 
    # forkrets: fork系统调用子进程返回点
    # 子进程从fork返回时使用此入口
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0                    # 设置栈指针指向新的trapframe
    j __trapret                    # 跳转到通用返回处理

    # kernel_execve_ret: 内核execve系统调用返回处理
    # 处理execve后的上下文切换，复制trapframe到新位置
    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES     # 计算新trapframe位置(kstacktop向下36个寄存器)

    // 复制trapframe: 从旧位置(a0)复制到新位置(a1)
    // 复制所有trapframe字段(36个64位字)
    LOAD s1, 35*REGBYTES(a0)     # scause
    STORE s1, 35*REGBYTES(a1)
    LOAD s1, 34*REGBYTES(a0)     # stval
    STORE s1, 34*REGBYTES(a1)
    LOAD s1, 33*REGBYTES(a0)     # sepc
    STORE s1, 33*REGBYTES(a1)
    LOAD s1, 32*REGBYTES(a0)     # sstatus
    STORE s1, 32*REGBYTES(a1)
    LOAD s1, 31*REGBYTES(a0)     # t6
    STORE s1, 31*REGBYTES(a1)
    LOAD s1, 30*REGBYTES(a0)     # t5
    STORE s1, 30*REGBYTES(a1)
    LOAD s1, 29*REGBYTES(a0)     # t4
    STORE s1, 29*REGBYTES(a1)
    LOAD s1, 28*REGBYTES(a0)     # t3
    STORE s1, 28*REGBYTES(a1)
    LOAD s1, 27*REGBYTES(a0)     # s11
    STORE s1, 27*REGBYTES(a1)
    LOAD s1, 26*REGBYTES(a0)     # s10
    STORE s1, 26*REGBYTES(a1)
    LOAD s1, 25*REGBYTES(a0)     # s9
    STORE s1, 25*REGBYTES(a1)
    LOAD s1, 24*REGBYTES(a0)     # s8
    STORE s1, 24*REGBYTES(a1)
    LOAD s1, 23*REGBYTES(a0)     # s7
    STORE s1, 23*REGBYTES(a1)
    LOAD s1, 22*REGBYTES(a0)     # s6
    STORE s1, 22*REGBYTES(a1)
    LOAD s1, 21*REGBYTES(a0)     # s5
    STORE s1, 21*REGBYTES(a1)
    LOAD s1, 20*REGBYTES(a0)     # s4
    STORE s1, 20*REGBYTES(a1)
    LOAD s1, 19*REGBYTES(a0)     # s3
    STORE s1, 19*REGBYTES(a1)
    LOAD s1, 18*REGBYTES(a0)     # s2
    STORE s1, 18*REGBYTES(a1)
    LOAD s1, 17*REGBYTES(a0)     # a7
    STORE s1, 17*REGBYTES(a1)
    LOAD s1, 16*REGBYTES(a0)     # a6
    STORE s1, 16*REGBYTES(a1)
    LOAD s1, 15*REGBYTES(a0)     # a5
    STORE s1, 15*REGBYTES(a1)
    LOAD s1, 14*REGBYTES(a0)     # a4
    STORE s1, 14*REGBYTES(a1)
    LOAD s1, 13*REGBYTES(a0)     # a3
    STORE s1, 13*REGBYTES(a1)
    LOAD s1, 12*REGBYTES(a0)     # a2
    STORE s1, 12*REGBYTES(a1)
    LOAD s1, 11*REGBYTES(a0)     # a1
    STORE s1, 11*REGBYTES(a1)
    LOAD s1, 10*REGBYTES(a0)     # a0
    STORE s1, 10*REGBYTES(a1)
    LOAD s1, 9*REGBYTES(a0)      # s1
    STORE s1, 9*REGBYTES(a1)
    LOAD s1, 8*REGBYTES(a0)      # s0/fp
    STORE s1, 8*REGBYTES(a1)
    LOAD s1, 7*REGBYTES(a0)      # x7
    STORE s1, 7*REGBYTES(a1)
    LOAD s1, 6*REGBYTES(a0)      # x6
    STORE s1, 6*REGBYTES(a1)
    LOAD s1, 5*REGBYTES(a0)      # x5
    STORE s1, 5*REGBYTES(a1)
    LOAD s1, 4*REGBYTES(a0)      # tp
    STORE s1, 4*REGBYTES(a1)
    LOAD s1, 3*REGBYTES(a0)      # gp
    STORE s1, 3*REGBYTES(a1)
    LOAD s1, 2*REGBYTES(a0)      # sp
    STORE s1, 2*REGBYTES(a1)
    LOAD s1, 1*REGBYTES(a0)      # ra
    STORE s1, 1*REGBYTES(a1)
    LOAD s1, 0*REGBYTES(a0)      # x0 (zero)
    STORE s1, 0*REGBYTES(a1)

    // 设置新的栈指针并返回
    move sp, a1                  # 设置栈指针到新trapframe位置
    j __trapret                  # 跳转到通用返回处理