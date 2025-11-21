/**
 * @file kern/sync/sync.h
 * @brief 同步机制和中断控制接口
 *
 * 本头文件定义了操作系统中的同步机制，特别是中断的开关控制。
 * 中断控制是实现并发安全的关键机制，确保关键代码段的原子性执行。
 *
 * ============================================================================
 * 并发和同步的基本概念
 * ============================================================================
 *
 * 并发（Concurrency）：多个执行流（进程/线程）同时存在
 * 并行（Parallelism）：多个执行流同时在不同CPU核心上运行
 *
 * 同步（Synchronization）：协调多个并发执行流的执行顺序
 * 原子性（Atomicity）：操作不可被中断，要么全部完成，要么全部不完成
 *
 * ============================================================================
 * 中断控制的重要性
 * ============================================================================
 *
 * 在单处理器系统中，中断是导致并发的主要来源：
 * 1. 进程A正在执行
 * 2. 定时器中断发生，切换到进程B
 * 3. 进程B修改了进程A正在使用的共享数据
 * 4. 返回进程A，数据已经改变，导致不一致
 *
 * 解决方案：临界区（Critical Section）
 * - 在访问共享资源的代码段，禁止中断
 * - 确保这段代码执行的原子性
 * - 执行完成后恢复中断状态
 *
 * ============================================================================
 * RISC-V中断控制机制
 * ============================================================================
 *
 * sstatus.SIE (Supervisor Interrupt Enable) 位：
 * - SIE = 1：中断使能，可以响应中断
 * - SIE = 0：中断禁止，中断会被挂起
 *
 * 中断控制函数：
 * - intr_disable(): 关闭中断（设置SIE=0）
 * - intr_enable(): 开启中断（设置SIE=1）
 * - local_intr_save(): 保存当前中断状态并关闭中断
 * - local_intr_restore(): 恢复之前保存的中断状态
 */

#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

/**
 * @brief 保存当前中断状态并关闭中断
 *
 * 检查当前是否允许中断，如果是则关闭中断并返回true。
 * 这个函数用于实现"保存-关闭-恢复"的中断控制模式。
 *
 * 使用场景：
 * 进入临界区前调用，确保临界区代码的原子性执行。
 *
 * @return true: 中断原本是开启的，已关闭
 *         false: 中断原本就是关闭的，无需操作
 */
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();  // 关闭中断
        return 1;        // 返回true表示原本开启
    }
    return 0;            // 返回false表示原本关闭
}

/**
 * @brief 根据保存的状态恢复中断
 *
 * 根据传入的flag值决定是否恢复中断。
 * 如果flag为true，则开启中断；如果为false，保持关闭状态。
 *
 * 使用场景：
 * 离开临界区时调用，恢复进入临界区前的中断状态。
 *
 * @param flag 之前保存的中断状态
 */
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();   // 开启中断
    }
    // 如果flag为false，保持中断关闭状态
}

/**
 * @brief 宏：保存当前中断状态并关闭中断
 *
 * 这是一个宏定义，用于方便地保存中断状态并关闭中断。
 * 使用do-while(0)包装确保宏在使用时行为正确。
 *
 * 使用方法：
 *   bool intr_flag;
 *   local_intr_save(intr_flag);  // 保存状态并关闭中断
 *   // 执行临界区代码...
 *   local_intr_restore(intr_flag);  // 恢复之前的状态
 *
 * @param x 用于保存中断状态的变量名
 */
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)

/**
 * @brief 宏：恢复之前保存的中断状态
 *
 * 根据保存的状态恢复中断，使能状态与local_intr_save配对使用。
 *
 * @param x 之前保存的中断状态变量
 */
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
