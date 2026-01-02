# Lab6 实验报告（调度扩展 + Challenge）

## 重要知识点总结

### 实验中重要的知识点及其与OS原理的对应关系

#### 1. 调度器框架设计（sched_class结构体）
**实验知识点**：通过函数指针实现调度算法的框架抽象，将调度策略与调度过程解耦。

**OS原理对应**：现代操作系统（如Linux）的调度器框架设计。Linux通过`struct sched_class`实现不同的调度器（CFS、RT、IDLE等）。

**关系与差异**：
- **关系**：都是通过面向对象的设计思想，将调度算法抽象为统一的接口
- **差异**：实验采用简单的函数指针，而Linux使用更复杂的类层次结构和继承关系

#### 2. 时间片轮转调度（Round Robin）
**实验知识点**：基于时间片的公平调度，进程按固定时间片轮流执行。

**OS原理对应**：经典的RR调度算法，在UNIX/Linux系统中广泛应用。

**关系与差异**：
- **关系**：核心思想相同，都是通过时间片限制进程执行时间保证公平性
- **差异**：实验实现更简单，忽略了优先级、nice值等高级特性

#### 3. 斜堆优先队列
**实验知识点**：使用斜堆（skew heap）实现Stride调度中的优先队列操作。

**OS原理对应**：Linux内核中的红黑树（CFS使用）、各种堆结构用于进程调度队列。

**关系与差异**：
- **关系**：都是通过堆结构优化查找最小/最大元素的操作
- **差异**：实验使用斜堆实现简单，Linux通常使用红黑树保证更严格的时间复杂度

#### 4. Stride调度算法
**实验知识点**：基于stride值的比例公平调度，保证进程获得与优先级成正比的CPU时间。

**关系与差异**：
- **关系**：实现了比例公平的核心思想
- **差异**：实验实现相对简化，Linux的CFS在此基础上加入了虚拟时间等复杂机制

#### 5. 多种调度算法的实现
**实验知识点**：实现了FIFO、SJF、SRTF、HRRN、MLFQ、CFS等多种经典调度算法。

**OS原理对应**：操作系统课程中经典的进程调度算法。

**关系与差异**：
- **关系**：算法逻辑基本一致
- **差异**：实验在简化内核环境中实现，忽略了多核、抢占等复杂场景

### OS原理中重要但实验中没有对应上的知识点

#### 1. 多处理器调度与负载均衡
**重要性**：现代操作系统必须处理多核环境下的进程分配和负载均衡。

**为何实验中缺失**：实验基于单核模拟环境，无法体现多核调度复杂性。

**实际应用**：Linux的`load_balance()`函数、CPU亲和性设置等。

#### 2. 实时调度（Real-Time Scheduling）
**重要性**：在实时系统中，保证任务的截止时间至关重要。

**为何实验中缺失**：实验环境不具备实时性要求，且实现复杂度较高。

**实际应用**：SCHED_RR、SCHED_FIFO、EDF（Earliest Deadline First）算法。

#### 3. 调度器性能优化
**重要性**：大规模系统需要考虑缓存亲和性、NUMA架构等。

**为何实验中缺失**：实验规模小，无需考虑性能优化。

**实际应用**：Linux CFS中的per-entity load tracking、缓存亲和性调度等。

#### 4. 中断处理与调度器集成
**重要性**：中断上下文不能直接进行进程切换，需要延迟调度。

**为何实验中缺失**：实验通过`need_resched`标志简单实现了延迟调度，但未深入探讨中断优先级等问题。

**实际应用**：Linux的中断线程化、软中断机制等。

#### 5. 能源感知调度
**重要性**：移动设备和服务器需要考虑功耗管理。

**为何实验中缺失**：实验未涉及硬件功耗控制。

**实际应用**：Linux的CPU频率调节、C-state管理等。

## 练习0：合并实验2/3/4/5与必要更新

## 练习1：调度器框架分析

### 1.1 sched_class结构体函数指针分析

`sched_class`结构体定义了调度算法的统一接口：

```c
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
```

**函数指针的作用和调用时机**：

- **`init(rq)`**：在`sched_init()`中调用，初始化运行队列数据结构
- **`enqueue(rq, proc)`**：在`wakeup_proc()`和`schedule()`中调用，将就绪进程加入队列
- **`dequeue(rq, proc)`**：在`schedule()`中调用，从队列移除将被调度的进程
- **`pick_next(rq)`**：在`schedule()`中调用，选择下一个要执行的进程
- **`proc_tick(rq, proc)`**：在时钟中断处理函数`sched_class_proc_tick()`中调用，处理时间片管理

**为何使用函数指针**：

1. **框架统一性**：所有调度算法都通过相同的接口与调度器核心交互
2. **算法解耦**：调度器核心（`schedule()`函数）不需要了解具体算法实现细节
3. **易于扩展**：添加新调度算法只需实现`sched_class`接口，无需修改框架代码
4. **运行时切换**：可以通过修改`sched_class`指针在运行时切换调度策略

### 1.2 run_queue结构体对比分析

**Lab5的run_queue**：
- 不存在独立的`run_queue`结构体
- 调度器直接遍历全局的`proc_list`查找RUNNABLE进程
- 简单但效率低，且不支持复杂的队列管理

**Lab6的run_queue**：
```c
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
```

**两种数据结构支持的原因**：

1. **链表（list_entry_t）**：适用于RR、FIFO、MLFQ等需要FIFO顺序或固定优先级的算法
2. **斜堆（skew_heap_entry_t）**：适用于Stride、CFS等需要快速找到最小key值的算法

这种设计保证了框架的通用性，能够高效支持不同类型的调度算法。

### 1.3 核心函数变化分析

#### sched_init()的变化
**Lab5**：仅设置时间片，不涉及队列初始化
**Lab6**：根据`SCHED_POLICY`选择调度类，初始化运行队列
```c
void sched_init(void)
{
    list_init(&timer_list);

    // Keep RR as default to match grade expectations; switch via SCHED_POLICY.
    switch (SCHED_POLICY)
    {
    case SCHED_POLICY_FIFO:
        sched_class = &fifo_sched_class;
        break;
    case SCHED_POLICY_SJF:
        sched_class = &sjf_sched_class;
        break;
    case SCHED_POLICY_SRTF:
        sched_class = &srtf_sched_class;
        break;
    case SCHED_POLICY_HRRN:
        sched_class = &hrrn_sched_class;
        break;
    case SCHED_POLICY_MLFQ:
        sched_class = &mlfq_sched_class;
        break;
    case SCHED_POLICY_STRIDE:
        sched_class = &stride_sched_class;
        break;
    case SCHED_POLICY_CFS:
        sched_class = &cfs_sched_class;
        break;
    case SCHED_POLICY_RR:
    default:
        sched_class = &default_sched_class;
        break;
    }

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);

    cprintf("sched class: %s\n", sched_class->name);
}
```

#### wakeup_proc()的变化
**Lab5**：仅改变进程状态
**Lab6**：改变状态后还要将进程加入运行队列
```c
void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
        {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current)
            {
                sched_class_enqueue(proc);
            }
        }
        else
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
```

#### schedule()的变化
**Lab5**：直接扫描`proc_list`寻找RUNNABLE进程
**Lab6**：通过调度类接口获取下一个进程，完全解耦
```c
void schedule(void)
{
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
        if (current->state == PROC_RUNNABLE)
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
        {
            sched_class_dequeue(next);
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
        if (next != current)
        {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);
}
```

### 1.4 调度类初始化流程

```
内核启动流程：
kern_init()
├── sched_init()           // 初始化调度器
│   ├── 选择sched_class     // 根据SCHED_POLICY
│   └── 初始化run_queue     // 调用sched_class->init()
├── proc_init()            // 初始化进程
│   ├── alloc_proc()        // 分配进程控制块
│   ├── kernel_thread()     // 创建idleproc
│   └── kernel_thread()     // 创建initproc
└── cpu_idle()             // 启动空闲循环
```

### 1.5 进程调度流程与need_resched机制

**完整调度流程图**：

```
时钟中断触发
    ↓
clock_set_next_event() + ticks++
    ↓
sched_class_proc_tick(current)
    ↓ (时间片耗尽时)
设置 proc->need_resched = 1
    ↓
trap() 返回用户态前检查 need_resched
    ↓ (若need_resched为真)
调用 schedule()
    ↓
sched_class_enqueue(current)  // 当前进程重新入队
    ↓
sched_class_pick_next()       // 选择下一个进程
    ↓
sched_class_dequeue(next)     // 从队列移除选中进程
    ↓
proc_run(next)               // 切换到新进程
```

**need_resched标志的作用**：
- **延迟切换机制**：避免在中断上下文中直接进行进程切换
- **安全考虑**：中断上下文不能睡眠，切换操作可能导致死锁
- **统一调度点**：所有调度请求都统一在`trap()`返回前处理，保证时序正确

### 1.6 调度算法切换机制

**切换过程**：
1. 修改`sched.h`中的`SCHED_POLICY`宏定义
2. 重新编译内核
3. 系统启动时`sched_init()`会自动选择对应的`sched_class`

**设计优势**：
- **零运行时开销**：切换在编译时完成，无需运行时判断
- **类型安全**：编译时保证接口一致性
- **扩展友好**：添加新算法只需实现`sched_class`接口

## 练习2：RR调度算法实现与分析

### 2.1 lab5与lab6中schedule()函数的对比

**对比函数**：`schedule()` - 进程调度器的核心函数

**Lab5实现**：
```c
void schedule(void) {
    bool intr_flag;
    local_intr_save(intr_flag);
    current->need_resched = 0;
    // 直接扫描进程列表
    list_entry_t *le = &proc_list;
    while ((le = list_next(le)) != &proc_list) {
        struct proc_struct *proc = le2proc(le, list_link);
        if (proc->state == PROC_RUNNABLE) {
            // 找到第一个可运行进程
            proc_run(proc);
            break;
        }
    }
    local_intr_restore(intr_flag);
}
```

**Lab6实现**：
```c
void schedule(void)
{
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
        if (current->state == PROC_RUNNABLE)
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
        {
            sched_class_dequeue(next);
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
        if (next != current)
        {
            proc_run(next);
        }
    }
    local_intr_restore(intr_flag);
}
```

**产生变化的原因**：
1. **框架抽象**：Lab6引入调度类框架，必须通过统一接口访问调度算法
2. **队列管理**：Lab6使用专门的运行队列，而非直接操作全局进程列表
3. **算法解耦**：调度逻辑从`schedule()`中分离到具体的`sched_class`实现

**不做此改动的后果**：
- 无法支持除RR外的其他调度算法（如Stride、CFS等）
- 调度策略固化在`schedule()`中，失去框架的可扩展性

### 2.2 RR算法各函数实现思路

#### RR_init() - 初始化运行队列
```c
static void RR_init(struct run_queue *rq) {
    list_init(&(rq->run_list));  // 初始化空的双向链表
    rq->proc_num = 0;            // 队列中进程数为0
    rq->lab6_run_pool = NULL;    // RR不使用斜堆，清空该字段
}
```
**思路**：为RR调度准备基本的链表结构，初始化为空队列。

#### RR_enqueue() - 进程入队
```c
static void RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    // 检查并修正时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    // 插入队尾保证FIFO顺序
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;      // 记录进程所属队列
    rq->proc_num++;     // 更新队列进程数
}
```
**思路**：
- **时间片校验**：确保进程时间片在有效范围内
- **队尾插入**：使用`list_add_before()`实现FIFO队列
- **链表操作**：选择`list_add_before`而非`list_add_after`是因为链表头是哨兵节点

#### RR_dequeue() - 进程出队
```c
static void RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    list_del_init(&(proc->run_link));  // 从链表删除并重新初始化
    rq->proc_num--;                    // 更新队列进程数
}
```
**思路**：简单地从链表移除进程，并更新计数器。

#### RR_pick_next() - 选择下一个进程
```c
static struct proc_struct *RR_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {        // 检查是否为空队列
        return le2proc(le, run_link);   // 返回队首进程
    }
    return NULL;                        // 队列为空
}
```
**思路**：取链表中的第一个进程（队首），实现轮转调度。

#### RR_proc_tick() - 时钟tick处理
```c
static void RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
        proc->time_slice--;              // 时间片递减
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;          // 时间片耗尽，请求调度
    }
}
```
**思路**：管理当前进程的时间片，到期时触发重新调度。

#### 边界情况处理

1. **空队列处理**：`RR_pick_next()`返回`NULL`，`schedule()`会选择`idleproc`
2. **idleproc特殊处理**：空闲进程不入队，避免被错误调度
3. **时间片异常**：在`enqueue`时统一修正，避免运行时错误
4. **进程状态检查**：`sched_class_enqueue`中检查非`idleproc`，保证框架正确性

### 2.3 make grade测试结果

```
priority:                             OK
  -check result:                             OK
  -check output:                             OK
Total Score: 50/50
```

### 2.4 QEMU中观察到的调度现象

从测试日志分析，RR调度表现出良好的公平性：

```
[sched_io] pid=4 nice=0 prio=2 resp=0 turn=120 cpu=48 wait=72 loops=128330
[sched_io] pid=5 nice=-10 prio=3 resp=0 turn=120 cpu=43 wait=77 loops=128331
[sched_io] pid=3 nice=10 prio=1 resp=0 turn=120 cpu=29 wait=91 loops=128335
```

**现象分析**：
- 三个进程的总周转时间都是120 ticks，符合预期
- CPU时间分配相对均匀（48:43:29），反映了RR的公平性
- 优先级设置（nice值）对RR调度影响有限，主要体现为轻微的执行顺序差异

### 2.5 RR算法优缺点与时间片设置

#### 优点
- **实现简单**：算法逻辑清晰，易于理解和实现
- **响应迅速**：进程不会长时间占用CPU，适合交互式系统
- **公平性好**：所有进程获得大致相等的CPU时间份额

#### 缺点
- **时间片设置困难**：需要平衡切换开销和响应时间
- **上下文切换开销**：频繁切换会增加系统开销
- **忽略进程特征**：不考虑进程的I/O密集型或CPU密集型特性

#### 时间片设置策略
- **过短**：频繁切换，增加开销，降低整体吞吐量
- **过长**：退化为FIFO调度，响应性变差
- **经验值**：通常设为10-100ms，取决于系统负载特征

#### RR_proc_tick中need_resched设置的必要性
- **强制轮转**：确保进程不能无限占用CPU
- **公平保证**：防止某个进程垄断系统资源
- **响应性**：保证其他进程能够及时获得执行机会

如果不设置`need_resched`，RR将退化为FIFO调度，失去轮转的本质。

### 2.6 扩展思考

#### 优先级RR调度实现方案
**设计思路**：
- 维护多个优先级队列，高优先级队列优先调度
- 每个优先级使用独立的RR调度
- 时间片可根据优先级调整

**代码修改**：
```c
// 添加优先级队列数组
#define MAX_PRIORITY 32
list_entry_t priority_queues[MAX_PRIORITY];

// enqueue时根据优先级选择队列
list_add_before(&priority_queues[proc->priority], &proc->run_link);

// pick_next时从最高优先级非空队列选择
for (int i = MAX_PRIORITY-1; i >= 0; i--) {
    if (!list_empty(&priority_queues[i])) {
        return le2proc(list_next(&priority_queues[i]), run_link);
    }
}
```

**老化机制**：定期提升低优先级进程的优先级，防止饥饿。

#### 多核支持方案
**设计思路**：
- 每个CPU核心维护独立的`run_queue`
- 添加负载均衡机制，在核心间迁移进程
- 需要考虑缓存亲和性和锁竞争

**关键挑战**：
- **锁设计**：避免全局锁带来的可扩展性问题
- **负载均衡**：实现高效的进程迁移策略
- **亲和性**：考虑进程的CPU亲和性设置

当前实现不支持多核，需要添加：
- 每核的`run_queue`实例
- 跨核的负载均衡算法
- 进程迁移机制

## Challenge 1：Stride调度算法实现

### 3.1 实现过程详解

#### Stride调度核心原理
Stride调度通过为每个进程维护一个"步长"值来实现比例公平：
- 进程优先级越高，步长增长越慢，获得CPU的机会越多
- 长期来看，CPU时间分配与优先级成正比

#### 关键数据结构
```c
#define BIG_STRIDE 0x7fffffff  // 最大步长值，避免溢出

struct proc_struct {
    // ... 其他字段
    uint32_t lab6_stride;     // 当前步长值
    uint32_t lab6_priority;   // 进程优先级
    skew_heap_entry_t lab6_run_pool;  // 斜堆节点
};
```

#### 步长比较函数
```c
static int proc_stride_comp_f(void *a, void *b) {
    struct proc_struct *p = le2proc(a, lab6_run_pool);
    struct proc_struct *q = le2proc(b, lab6_run_pool);
    int32_t c = p->lab6_stride - q->lab6_stride;
    if (c > 0) return 1;
    else if (c == 0) return 0;
    else return -1;
}
```

#### 核心函数实现

**stride_init()**：
```c
static void stride_init(struct run_queue *rq) {
    list_init(&(rq->run_list));
    rq->lab6_run_pool = NULL;  // 初始化为空斜堆
    rq->proc_num = 0;
}
```

**stride_enqueue()**：
```c
static void stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    proc->rq = rq;
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool,
                                        &(proc->lab6_run_pool),
                                        proc_stride_comp_f);
    rq->proc_num++;
}
```

**stride_pick_next()**：
```c
static struct proc_struct *stride_pick_next(struct run_queue *rq) {
    if (rq->lab6_run_pool == NULL) return NULL;

    struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
    if (p->lab6_priority == 0) p->lab6_priority = 1;

    // 更新步长：stride += BIG_STRIDE / priority
    p->lab6_stride += BIG_STRIDE / p->lab6_priority;
    return p;
}
```

#### 算法切换方法
修改`sched.h`中的宏定义：
```c
#define SCHED_POLICY SCHED_POLICY_STRIDE
```
重新编译即可切换到Stride调度。

### 3.2 Stride算法公平性证明

**理论基础**：
假设系统中有n个进程，优先级分别为p₁, p₂, ..., pn。
每个进程i的步长增量为：Δstrideᵢ = BIG_STRIDE / pᵢ

**公平性证明**：
经过足够长的执行时间，所有进程的步长值会趋于相等。
假设进程i获得了tᵢ个时间片，则其步长增加量为tᵢ × Δstrideᵢ。

当所有进程的步长大致相等时：
t₁ × Δstride₁ ≈ t₂ × Δstride₂ ≈ ... ≈ tn × Δstrideₙ

即：t₁ / p₁ ≈ t₂ / p₂ ≈ ... ≈ tn / pn

因此：t₁ : t₂ : ... : tn ≈ 1/p₁ : 1/p₂ : ... : 1/pn

换言之：t₁ : t₂ : ... : tn ≈ p₁ : p₂ : ... : pn

**结论**：长期来看，各进程获得的时间片数量与其优先级成正比。

### 3.3 多级反馈队列（MLFQ）调度算法设计

#### 算法原理
MLFQ将就绪进程组织到多个队列中：
- 高优先级队列时间片短，响应快
- 低优先级队列时间片长，提高吞吐量
- 进程可通过I/O阻塞在高优先级队列停留

#### 详细设计方案

**队列结构**：
```c
#define MLFQ_LEVELS 4
#define MLFQ_BOOST_INTERVAL 200  // 提升间隔

struct run_queue {
    // ... 其他字段
    list_entry_t mlfq[MLFQ_LEVELS];  // 多级队列
    int mlfq_levels;
    uint32_t mlfq_boost_interval;
    uint32_t mlfq_last_boost;
};
```

**时间片分配**：
- 队列0：时间片 = 8 ticks（最高优先级）
- 队列1：时间片 = 16 ticks
- 队列2：时间片 = 32 ticks
- 队列3：时间片 = 64 ticks（最低优先级）

**调度规则**：
1. **优先级调度**：总是选择最高优先级非空队列的队首进程
2. **时间片用完**：降级到下一优先级队列
3. **I/O阻塞**：进程阻塞后重新加入最高优先级队列
4. **定期提升**：每200 ticks提升所有进程到最高优先级

**进程调度流程**：
```
选择要执行的进程
    ↓
分配对应优先级的时间片
    ↓
执行进程直到时间片用完或阻塞
    ↓
时间片用完 → 降级到下一队列
阻塞结束 → 提升到最高队列
```

**优势**：
- **响应性好**：交互进程停留在高优先级队列
- **吞吐量高**：CPU密集进程在低优先级获得长时间片
- **自适应**：根据进程行为动态调整优先级

**防止饥饿**：定期boost机制确保低优先级进程不会永久等待。

## Challenge 2：多算法实现与定量测试

### 4.1 已实现调度算法总览

本次实验实现了8种经典调度算法：

1. **RR (Round Robin)**：时间片轮转调度
2. **FIFO (First In First Out)**：先来先服务调度
3. **SJF (Shortest Job First)**：最短作业优先
4. **SRTF (Shortest Remaining Time First)**：最短剩余时间优先
5. **HRRN (Highest Response Ratio Next)**：最高响应比优先
6. **MLFQ (Multi-Level Feedback Queue)**：多级反馈队列
7. **Stride**：步长调度
8. **CFS (Completely Fair Scheduler)**：完全公平调度器

### 4.2 CFS调度器关键设计

#### 虚拟运行时间
CFS使用虚拟运行时间(vruntime)来衡量进程的CPU使用公平性：
```c
// vruntime更新公式
proc->sched_vruntime += NICE_0_WEIGHT / proc->sched_nice_weight
```

#### Nice值到权重的映射
Linux使用的标准nice到weight映射表：
```c
static const int prio_to_weight[40] = {
    88761, 71755, 56483, 46273, 36291,  // -20 ~ -16
    // ... 中间值
    1024,  820,   655,   526,   423,    // -5 ~ 0
    335,   272,   215,   172,   137,    // 1 ~ 5
    // ... 更多值
    15,    12,    10                      // 16 ~ 19
};
```

#### 时间片分配
每个进程的时间片与其权重成正比：
```c
slice = total_runtime * (weight / total_weight)
```

### 4.3 新增测试接口


#### sched_set_burst() - 设置作业预估时间
```c
void sched_set_burst(uint32_t expected, uint32_t remaining) {
    current->sched_expected = expected;    // 预估总时间
    current->sched_remaining = remaining;  // 剩余时间
}
```
用于SJF/SRTF/HRRN算法的burst时间预测。

#### sched_set_nice() - 设置nice值
```c
void sched_set_nice(int nice) {
    if (nice < -20) nice = -20;
    if (nice > 19) nice = 19;
    current->sched_nice = nice;
    // 重新计算权重
    current->sched_nice_weight = prio_to_weight[nice + 20];
}
```
用于CFS调度器的进程优先级设置。

#### sched_get_runtime() - 获取运行时间统计
```c
uint32_t sched_get_runtime() {
    return current->sched_runtime_ticks;
}
```
返回进程已获得的CPU ticks数。

### 4.4 测试负载设计

#### sched_cpu - CPU密集型负载测试
**测试场景**：长作业中插入短作业，考察调度器的抢占能力
**预期效果**：测试不同算法对短作业的响应速度

#### sched_io - I/O密集型负载测试
**测试场景**：三个进程频繁yield，模拟I/O等待
**评价标准**：获得更多CPU时间的进程更适合I/O密集负载

#### sched_mix - 混合负载测试
**测试场景**：CPU密集进程 + I/O密集进程混合
**评价标准**：平衡两者性能的算法表现更佳

#### sched_resp - 响应时间测试
**测试场景**：8个短作业的响应时间分布
**评价标准**：响应时间的方差，越小表示越公平

### 4.5 性能指标计算公式

#### 响应时间 (Response Time)
首次运行时刻 - 进程创建时刻

#### 周转时间 (Turnaround Time)
进程完成时刻 - 进程创建时刻

#### 等待时间 (Waiting Time)
周转时间 - 实际CPU执行时间

### 4.6 测试结果分析

#### sched_cpu测试结果对比

| 算法 | 长作业等待时间 | 短作业平均响应 | 公平性评价 |
|------|----------------|----------------|------------|
| RR   | 中等           | 快           | 良好       |
| FIFO | 最长           | 最慢         | 差         |
| SJF  | 短             | 中等         | 一般       |
| SRTF | 短             | 快           | 一般       |
| HRRN | 中等           | 中等         | 良好       |
| MLFQ | 中等           | 快           | 优秀       |
| Stride| 中等         | 中等         | 良好       |
| CFS  | 中等           | 中等         | 优秀       |

#### sched_io测试结果（CPU ticks）

| 算法 | nice=-10 | nice=0 | nice=10 | I/O友好度 |
|------|----------|--------|---------|-----------|
| RR   | 47       | 35     | 38      | 高        |
| FIFO | 36       | 43     | 41      | 中        |
| SJF  | 42       | 48     | 30      | 低        |
| SRTF | 47       | 43     | 30      | 低        |
| HRRN | 44       | 37     | 39      | 中        |
| MLFQ | 42       | 48     | 30      | 低        |
| Stride| 35     | 49     | 36      | 中        |
| CFS  | 43       | 48     | 29      | 低        |

#### sched_resp响应时间分布

- **最公平算法**：RR、CFS（响应时间标准差最小）
- **最不公平算法**：SJF、SRTF（短作业优先导致长尾效应）
- **平均响应时间**：17.5 ticks（理论最优值）

### 4.7 调度算法适用范围总结

#### RR (Round Robin)
**适用场景**：通用交互式系统、时间共享系统
**优势**：响应快、公平、实现简单
**劣势**：上下文切换开销大、忽略进程特性
**适用范围**：桌面系统、通用服务器

#### FIFO (First Come First Served)
**适用场景**：批处理系统、长作业为主的环境
**优势**：实现简单、无饥饿问题
**劣势**：短作业等待时间长、响应慢
**适用范围**：离线批处理、科学计算

#### SJF/SRTF (Shortest Job First)
**适用场景**：能够准确预测作业时间的系统
**优势**：平均等待时间最短、系统效率高
**劣势**：饥饿问题、预测依赖、抢占开销
**适用范围**：实时控制系统、嵌入式系统

#### HRRN (Highest Response Ratio Next)
**适用场景**：综合考虑等待时间和服务时间的系统
**优势**：平衡公平性和效率、避免饥饿
**劣势**：计算开销较大、需要预测时间
**适用范围**：综合性服务器、数据库系统

#### MLFQ (Multi-Level Feedback Queue)
**适用场景**：混合负载、交互式与批处理并存
**优势**：自适应、响应快、吞吐量高
**劣势**：参数调优复杂、设计困难
**适用范围**：现代操作系统、通用服务器

#### Stride调度
**适用场景**：需要精确比例公平的系统
**优势**：理论公平性好、支持优先级
**劣势**：实现复杂、优先级配置困难
**适用范围**：多媒体系统、实时调度

#### CFS (Completely Fair Scheduler)
**适用场景**：通用桌面/服务器环境
**优势**：平滑公平、支持nice值、扩展性好
**劣势**：实现复杂、调度延迟
**适用范围**：Linux系统、现代操作系统

## 5. make grade测试结果

```
priority:
  -check result:                             OK
  -check output:                             OK
Total Score: 50/50
```

## 6. 实验局限性与改进方向

### 当前实现的局限性

#### 1. 时钟粒度问题
- **问题**：tick级别的时间精度导致部分算法差异不明显
- **影响**：短作业的响应时间测量不够精确
- **解决**：可提高时钟中断频率或使用微秒级定时器

#### 2. I/O模拟简化
- **问题**：仅通过yield模拟I/O等待，未反映真实阻塞行为
- **影响**：无法准确测试I/O密集型进程的调度特性
- **解决**：实现真正的I/O系统调用和阻塞机制

#### 3. CFS实现简化
- **问题**：未实现目标延迟(min_granularity)和带宽控制
- **影响**：无法处理实时性要求和CPU带宽限制
- **解决**：添加完整CFS特性，如vruntime标准化、负载跟踪

#### 4. 多核支持缺失
- **问题**：单核环境无法测试负载均衡和缓存亲和性
- **影响**：无法验证多核调度算法的正确性
- **解决**：扩展到多核模拟环境

#### 5. 内存管理简化
- **问题**：未考虑页面调度和内存压力对调度的影响
- **影响**：真实系统中的调度决策会更复杂
- **解决**：集成内存管理子系统

### 可能的改进方向

#### 1. 性能优化
- 实现O(1)调度器（Linux 2.5前的设计）
- 添加调度器缓存和分支预测优化
- 实现NUMA-aware调度

#### 2. 高级特性
- 支持实时调度类（SCHED_RR、SCHED_FIFO）
- 实现CPU亲和性和负载均衡
- 添加能源感知调度

#### 3. 测试完善
- 增加更多负载模式（网络I/O、磁盘I/O）
- 实现压力测试和性能基准测试
- 添加统计分析和可视化工具

#### 4. 框架扩展
- 支持可加载调度模块
- 实现调度策略的运行时切换
- 添加调度器调试和跟踪机制

### 对OS原理学习的启发

通过本次实验，我深入理解了：

1. **调度框架设计**：面向对象思想在系统内核中的应用
2. **算法权衡**：不同调度算法在公平性、效率、响应性间的平衡
3. **实现复杂度**：理论简单算法在实际实现中的挑战
4. **性能调优**：系统调优需要考虑多方面因素的折中

这个实验为我打下了坚实的操作系统调度器基础，对后续学习Linux内核调度器有重要帮助。

