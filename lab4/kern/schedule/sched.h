/**
 * @file kern/schedule/sched.h
 * @brief 进程调度器接口定义
 *
 * 本头文件定义了进程调度器的所有接口函数声明。
 * 调度器负责在多个可运行进程中选择下一个要执行的进程。
 */

#ifndef __KERN_SCHEDULE_SCHED_H__
#define __KERN_SCHEDULE_SCHED_H__

#include <proc.h>  // 进程结构体定义

// ============================================================================
// 调度器核心接口
// ============================================================================

/**
 * @brief 执行进程调度
 *
 * 该函数是调度器的核心，负责选择下一个要执行的进程并进行切换。
 * 使用轮转调度算法，在所有可运行进程中公平地分配CPU时间。
 */
void schedule(void);

/**
 * @brief 唤醒睡眠进程
 *
 * 将处于睡眠状态的进程转换为可运行状态，使其可以被调度器选中执行。
 * @param proc 要唤醒的进程指针
 */
void wakeup_proc(struct proc_struct *proc);

#endif /* !__KERN_SCHEDULE_SCHED_H__ */

