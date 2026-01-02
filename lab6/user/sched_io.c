#include <ulib.h>
#include <stdio.h>

#define TASKS 3
#define DURATION_MS 1200

static const int nice_vals[TASKS] = {10, 0, -10};
static const uint32_t prio_vals[TASKS] = {1, 2, 3};

static void
spin_delay(void)
{
    volatile int j = 0;
    int i;
    for (i = 0; i < 200; i++)
    {
        j += i;
    }
}

int
main(void)
{
    uint32_t t0 = gettime_msec();
    int pids[TASKS];
    int i;

    for (i = 0; i < TASKS; i++)
    {
        int pid = fork();
        if (pid == 0)
        {
            sched_set_burst(5, 5);
            sched_set_nice(nice_vals[i]);
            lab6_setpriority(prio_vals[i]);

            uint32_t first = gettime_msec();
            int cpu_start = sched_get_runtime();
            int loops = 0;
            while ((gettime_msec() - t0) < DURATION_MS)
            {
                spin_delay();
                loops++;
                yield();
            }
            int cpu_used = sched_get_runtime() - cpu_start;
            uint32_t end = gettime_msec();

            uint32_t resp = (first - t0) / 10;
            uint32_t turn = (end - t0) / 10;
            int wait = (int)turn - cpu_used;
            if (wait < 0)
            {
                wait = 0;
            }

            cprintf("[sched_io] pid=%d nice=%d prio=%u resp=%u turn=%u cpu=%d wait=%d loops=%d\n",
                    getpid(), nice_vals[i], prio_vals[i], resp, turn, cpu_used, wait, loops);
            exit(cpu_used);
        }
        pids[i] = pid;
    }

    for (i = 0; i < TASKS; i++)
    {
        waitpid(pids[i], NULL);
    }
    cprintf("[sched_io] done\n");
    return 0;
}
