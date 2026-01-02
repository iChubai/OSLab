#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <clock.h>

static inline int
mlfq_level_slice(struct run_queue *rq, int level)
{
    int slice = rq->max_time_slice;
    if (level > 0)
    {
        slice <<= level;
    }
    return slice;
}

static void
mlfq_boost(struct run_queue *rq)
{
    int level;
    for (level = 1; level < rq->mlfq_levels; level++)
    {
        list_entry_t *head = &(rq->mlfq[level]);
        while (!list_empty(head))
        {
            list_entry_t *le = list_next(head);
            struct proc_struct *p = le2proc(le, run_link);
            list_del_init(le);
            p->sched_qlevel = 0;
            p->time_slice = mlfq_level_slice(rq, 0);
            list_add_before(&(rq->mlfq[0]), &(p->run_link));
        }
    }
    rq->mlfq_last_boost = (uint32_t)ticks;
}

static void
mlfq_init(struct run_queue *rq)
{
    int i;
    list_init(&(rq->run_list));
    for (i = 0; i < MLFQ_LEVELS; i++)
    {
        list_init(&(rq->mlfq[i]));
    }
    rq->proc_num = 0;
    rq->lab6_run_pool = NULL;
    rq->mlfq_levels = MLFQ_LEVELS;
    rq->mlfq_boost_interval = MLFQ_BOOST_INTERVAL;
    rq->mlfq_last_boost = (uint32_t)ticks;
}

static void
mlfq_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    int level = proc->sched_qlevel;
    if (level < 0)
    {
        level = 0;
    }
    if (level >= rq->mlfq_levels)
    {
        level = rq->mlfq_levels - 1;
    }
    proc->sched_qlevel = level;
    if (proc->time_slice == 0 || proc->time_slice > mlfq_level_slice(rq, level))
    {
        proc->time_slice = mlfq_level_slice(rq, level);
    }
    proc->sched_wait_start = (uint32_t)ticks;
    list_add_before(&(rq->mlfq[level]), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
}

static void
mlfq_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
}

static struct proc_struct *
mlfq_pick_next(struct run_queue *rq)
{
    int level;
    for (level = 0; level < rq->mlfq_levels; level++)
    {
        if (!list_empty(&(rq->mlfq[level])))
        {
            list_entry_t *le = list_next(&(rq->mlfq[level]));
            struct proc_struct *p = le2proc(le, run_link);
            p->sched_last_start = (uint32_t)ticks;
            return p;
        }
    }
    return NULL;
}

static void
mlfq_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if ((uint32_t)ticks - rq->mlfq_last_boost >= rq->mlfq_boost_interval)
    {
        mlfq_boost(rq);
        proc->sched_qlevel = 0;
    }

    if (proc->time_slice > 0)
    {
        proc->time_slice--;
    }
    if (proc->time_slice == 0)
    {
        if (proc->sched_qlevel < rq->mlfq_levels - 1)
        {
            proc->sched_qlevel++;
        }
        proc->need_resched = 1;
    }
}

struct sched_class mlfq_sched_class = {
    .name = "MLFQ_scheduler",
    .init = mlfq_init,
    .enqueue = mlfq_enqueue,
    .dequeue = mlfq_dequeue,
    .pick_next = mlfq_pick_next,
    .proc_tick = mlfq_proc_tick,
};
