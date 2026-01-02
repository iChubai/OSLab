#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <clock.h>

#define NICE_0_WEIGHT 1024
#define VRUNTIME_SCALE 1024

static const uint32_t cfs_weight_table[40] = {
    88761, 71755, 56483, 46273, 36291,
    29154, 23254, 18705, 14949, 11916,
    9548,  7620,  6100,  4904,  3906,
    3121,  2501,  1991,  1586,  1277,
    1024,  820,   655,   526,   423,
    335,   272,   215,   172,   137,
    110,   87,    70,    56,    45,
    36,    29,    23,    18,    15,
};

static inline uint32_t
cfs_weight(int nice)
{
    if (nice < -20)
    {
        nice = -20;
    }
    if (nice > 19)
    {
        nice = 19;
    }
    return cfs_weight_table[nice + 20];
}

static int
proc_vruntime_comp_f(void *a, void *b)
{
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    if (p->sched_vruntime > q->sched_vruntime)
    {
        return 1;
    }
    if (p->sched_vruntime == q->sched_vruntime)
    {
        return 0;
    }
    return -1;
}

static void
cfs_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
    rq->lab6_run_pool = NULL;
    rq->cfs_min_vruntime = 0;
    rq->cfs_total_weight = 0;
}

static void
cfs_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    uint32_t weight = cfs_weight(proc->sched_nice);
    if (proc->sched_vruntime < rq->cfs_min_vruntime)
    {
        proc->sched_vruntime = rq->cfs_min_vruntime;
    }
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice)
    {
        proc->time_slice = rq->max_time_slice;
    }
    proc->sched_wait_start = (uint32_t)ticks;
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_vruntime_comp_f);
    rq->proc_num++;
    rq->cfs_total_weight += weight;
    proc->rq = rq;
}

static void
cfs_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    uint32_t weight = cfs_weight(proc->sched_nice);
    rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_vruntime_comp_f);
    rq->proc_num--;
    if (rq->cfs_total_weight >= weight)
    {
        rq->cfs_total_weight -= weight;
    }
    else
    {
        rq->cfs_total_weight = 0;
    }
}

static struct proc_struct *
cfs_pick_next(struct run_queue *rq)
{
    if (rq->lab6_run_pool == NULL)
    {
        return NULL;
    }
    struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
    uint32_t weight = cfs_weight(p->sched_nice);
    if (rq->cfs_total_weight == 0)
    {
        p->time_slice = rq->max_time_slice;
    }
    else
    {
        uint32_t slice = (uint32_t)((uint64_t)rq->max_time_slice * weight / rq->cfs_total_weight);
        if (slice == 0)
        {
            slice = 1;
        }
        p->time_slice = slice;
    }
    p->sched_last_start = (uint32_t)ticks;
    return p;
}

static void
cfs_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    uint32_t weight = cfs_weight(proc->sched_nice);
    uint64_t delta = ((uint64_t)NICE_0_WEIGHT * VRUNTIME_SCALE) / weight;
    proc->sched_vruntime += delta;

    if (proc->time_slice > 0)
    {
        proc->time_slice--;
    }
    if (proc->time_slice == 0)
    {
        proc->need_resched = 1;
    }

    if (rq->lab6_run_pool != NULL)
    {
        struct proc_struct *minp = le2proc(rq->lab6_run_pool, lab6_run_pool);
        uint64_t minv = minp->sched_vruntime;
        if (proc->sched_vruntime < minv)
        {
            minv = proc->sched_vruntime;
        }
        rq->cfs_min_vruntime = minv;
    }
    else
    {
        rq->cfs_min_vruntime = proc->sched_vruntime;
    }
}

struct sched_class cfs_sched_class = {
    .name = "CFS_scheduler",
    .init = cfs_init,
    .enqueue = cfs_enqueue,
    .dequeue = cfs_dequeue,
    .pick_next = cfs_pick_next,
    .proc_tick = cfs_proc_tick,
};
