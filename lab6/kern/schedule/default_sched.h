#ifndef __KERN_SCHEDULE_SCHED_RR_H__
#define __KERN_SCHEDULE_SCHED_RR_H__

#include <sched.h>

extern struct sched_class default_sched_class;
extern struct sched_class stride_sched_class;
extern struct sched_class fifo_sched_class;
extern struct sched_class sjf_sched_class;
extern struct sched_class srtf_sched_class;
extern struct sched_class hrrn_sched_class;
extern struct sched_class mlfq_sched_class;
extern struct sched_class cfs_sched_class;

#endif /* !__KERN_SCHEDULE_SCHED_RR_H__ */
