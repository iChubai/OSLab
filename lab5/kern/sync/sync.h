#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <sched.h>
#include <riscv.h>
#include <assert.h>

// __intr_save - 保存中断状态，如果中断开启则关闭并返回1
static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
    {
        intr_disable();  // 关闭中断
        return 1;        // 返回原状态：开启
    }
    return 0;           // 返回原状态：关闭
}

// __intr_restore - 根据保存的状态恢复中断
static inline void __intr_restore(bool flag)
{
    if (flag)           // 如果原来中断是开启的
    {
        intr_enable();  // 重新开启中断
    }
}

#define local_intr_save(x) \
    do                     \
    {                      \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

typedef volatile bool lock_t;

// lock_init - 初始化自旋锁，初始状态为解锁(0)
static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
}

// try_lock - 尝试获取锁，原子操作
// 返回true表示获取成功，false表示锁已被占用
static inline bool
try_lock(lock_t *lock)
{
    return !test_and_set_bit(0, lock);  // 原子设置位并返回原值
}

// lock - 获取自旋锁，忙等待直到获取成功
static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))  // 循环尝试获取锁
    {
        schedule();           // 获取失败时让出CPU
    }
}

// unlock - 释放自旋锁
static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))  // 原子清除位并返回原值
    {
        panic("Unlock failed.\n");     // 解锁失败表示锁状态错误
    }
}

#endif /* !__KERN_SYNC_SYNC_H__ */
