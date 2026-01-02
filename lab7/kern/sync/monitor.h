#ifndef __KERN_SYNC_MONITOR_CONDVAR_H__
#define __KERN_SYNC_MOINTOR_CONDVAR_H__

#include <sem.h>
/* In [OS CONCEPT] 7.7 section, the accurate define and approximate implementation of MONITOR was introduced.
 * INTRODUCTION:
 *  Monitors were invented by C. A. R. Hoare and Per Brinch Hansen, and were first implemented in Brinch Hansen's
 *  Concurrent Pascal language. Generally, a monitor is a language construct and the compiler usually enforces mutual exclusion. Compare this with semaphores, which are usually an OS construct.
 * DEFNIE & CHARACTERISTIC:
 *  A monitor is a collection of procedures, variables, and data structures grouped together.
 *  Processes can call the monitor procedures but cannot access the internal data structures.
 *  Only one process at a time may be be active in a monitor.
 *  Condition variables allow for blocking and unblocking.
 *     cv.wait() blocks a process.
 *        The process is said to be waiting for (or waiting on) the condition variable cv.
 *     cv.signal() (also called cv.notify) unblocks a process waiting for the condition variable cv.
 *        When this occurs, we need to still require that only one process is active in the monitor. This can be done in several ways:
 *            on some systems the old process (the one executing the signal) leaves the monitor and the new one enters
 *            on some systems the signal must be the last statement executed inside the monitor.
 *            on some systems the old process will block until the monitor is available again.
 *            on some systems the new process (the one unblocked by the signal) will remain blocked until the monitor is available again.
 *   If a condition variable is signaled with nobody waiting, the signal is lost. Compare this with semaphores, in which a signal will allow a process that executes a wait in the future to no block.
 *   You should not think of a condition variable as a variable in the traditional sense.
 *     It does not have a value.
 *     Think of it as an object in the OOP sense.
 *     It has two methods, wait and signal that manipulate the calling process.
 * IMPLEMENTATION:
 *   monitor mt {
 *     ----------------variable------------------
 *     semaphore mutex;
 *     semaphore next;
 *     int next_count;
 *     condvar {int count, sempahore sem}  cv[N];
 *     other variables in mt;
 *     --------condvar wait/signal---------------
 *     cond_wait (cv) {
 *         cv.count ++;
 *         if(mt.next_count>0)
 *            signal(mt.next)
 *         else
 *            signal(mt.mutex);
 *         wait(cv.sem);
 *         cv.count --;
 *      }
 *
 *      cond_signal(cv) {
 *          if(cv.count>0) {
 *             mt.next_count ++;
 *             signal(cv.sem);
 *             wait(mt.next);
 *             mt.next_count--;
 *          }
 *       }
 *     --------routines in monitor---------------
 *     routineA_in_mt () {
 *        wait(mt.mutex);
 *        ...
 *        real body of routineA
 *        ...
 *        if(next_count>0)
 *            signal(mt.next);
 *        else
 *            signal(mt.mutex);
 *     }
 */
/* 在[OS CONCEPT] 7.7章节中，介绍了MONITOR的准确定义和近似实现。
 * 引言：
 *  管程（Monitors）是由C. A. R. Hoare和Per Brinch Hansen发明的，首先在Brinch Hansen的
 *  Concurrent Pascal语言中实现。一般来说，管程是一个语言构造，编译器通常强制执行互斥。将其与信号量比较，信号量通常是一个操作系统构造。
 * 定义与特性：
 *  管程是一组过程、变量和数据结构的集合。
 *  进程可以调用管程的过程，但不能访问内部数据结构。
 *  在任何时刻，只有一个进程可以在管程中处于活跃状态。
 *  条件变量允许阻塞和解除阻塞。
 *     cv.wait() 会阻塞一个进程。
 *        该进程被称为正在等待（或等待在）条件变量cv上。
 *     cv.signal()（也称为cv.notify）会解除等待条件变量cv的进程的阻塞。
 *        当这种情况发生时，我们仍然需要要求只有一个进程在管程中处于活跃状态。这可以通过几种方式实现：
 *            在某些系统中，旧进程（执行signal的进程）离开管程，新进程进入
 *            在某些系统中，signal必须是管程内执行的最后一条语句。
 *            在某些系统中，旧进程将阻塞直到管程再次可用。
 *            在某些系统中，新进程（被signal解除阻塞的进程）将保持阻塞直到管程再次可用。
 *   如果对一个没有人等待的条件变量发出signal，该信号会丢失。将此与信号量比较，在信号量中，一个signal将允许将来执行wait的进程不被阻塞。
 *   你不应该将条件变量视为传统意义上的变量。
 *     它没有值。
 *     从面向对象的意义上将其视为一个对象。
 *     它有两个方法，wait和signal，用于操纵调用进程。
 * 实现：
 *   monitor mt {
 *     ----------------变量------------------
 *     semaphore mutex;
 *     semaphore next;
 *     int next_count;
 *     condvar {int count, sempahore sem}  cv[N];
 *     mt中的其他变量;
 *     --------条件变量wait/signal---------------
 *     cond_wait (cv) {
 *         cv.count ++;
 *         if(mt.next_count>0)
 *            signal(mt.next)
 *         else
 *            signal(mt.mutex);
 *         wait(cv.sem);
 *         cv.count --;
 *      }
 *
 *      cond_signal(cv) {
 *          if(cv.count>0) {
 *             mt.next_count ++;
 *             signal(cv.sem);
 *             wait(mt.next);
 *             mt.next_count--;
 *          }
 *       }
 *     --------管程中的例程---------------
 *     routineA_in_mt () {
 *        wait(mt.mutex);
 *        ...
 *        routineA的实际主体
 *        ...
 *        if(next_count>0)
 *            signal(mt.next);
 *        else
 *            signal(mt.mutex);
 *     }
typedef struct monitor monitor_t;

typedef struct condvar{
    semaphore_t sem;        // the sem semaphore  is used to down the waiting proc, and the signaling proc should up the waiting proc
    int count;              // the number of waiters on condvar
    monitor_t * owner;      // the owner(monitor) of this condvar
} condvar_t;

typedef struct monitor{
    semaphore_t mutex;      // the mutex lock for going into the routines in monitor, should be initialized to 1
    semaphore_t next;       // the next semaphore is used to down the signaling proc itself, and the other OR wakeuped waiting proc should wake up the sleeped signaling proc.
    int next_count;         // the number of of sleeped signaling proc
    condvar_t *cv;          // the condvars in monitor
} monitor_t;

// Initialize variables in monitor.
void     monitor_init (monitor_t *cvp, size_t num_cv);
// Free variables in monitor.
void     monitor_free (monitor_t *cvp, size_t num_cv);
// Unlock one of threads waiting on the condition variable.
void     cond_signal (condvar_t *cvp);
// Suspend calling thread on a condition variable waiting for condition atomically unlock mutex in monitor,
// and suspends calling thread on conditional variable after waking up locks mutex.
void     cond_wait (condvar_t *cvp);
     
#endif /* !__KERN_SYNC_MONITOR_CONDVAR_H__ */
