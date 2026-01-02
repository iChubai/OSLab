#ifndef __KERN_SCHEDULE_SCHED_H__
#define __KERN_SCHEDULE_SCHED_H__

#include <defs.h>
#include <list.h>
#include <skew_heap.h>

#define MAX_TIME_SLICE 5

#define SCHED_POLICY_RR 0
#define SCHED_POLICY_FIFO 1
#define SCHED_POLICY_SJF 2
#define SCHED_POLICY_SRTF 3
#define SCHED_POLICY_HRRN 4
#define SCHED_POLICY_MLFQ 5
#define SCHED_POLICY_STRIDE 6
#define SCHED_POLICY_CFS 7

#ifndef SCHED_POLICY
#define SCHED_POLICY SCHED_POLICY_RR
#endif

#define MLFQ_LEVELS 4
#define MLFQ_BOOST_INTERVAL 200

struct proc_struct;

struct run_queue;

// The introduction of scheduling classes is borrrowed from Linux, and makes the
// core scheduler quite extensible. These classes (the scheduler modules) encapsulate
// the scheduling policies.
struct sched_class
{
    // the name of sched_class
    const char *name;
    // Init the run queue
    void (*init)(struct run_queue *rq);
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
    /* for SMP support in the future
     *  load_balance
     *     void (*load_balance)(struct rq* rq);
     *  get some proc from this rq, used in load_balance,
     *  return value is the num of gotten proc
     *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
     */
};

struct run_queue
{
    list_entry_t run_list;
    unsigned int proc_num;
    int max_time_slice;
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;
    list_entry_t mlfq[MLFQ_LEVELS];
    int mlfq_levels;
    uint32_t mlfq_boost_interval;
    uint32_t mlfq_last_boost;
    uint64_t cfs_min_vruntime;
    uint32_t cfs_total_weight;
};

void sched_init(void);
void wakeup_proc(struct proc_struct *proc);
void schedule(void);
void sched_class_proc_tick(struct proc_struct *proc);
#endif /* !__KERN_SCHEDULE_SCHED_H__ */
