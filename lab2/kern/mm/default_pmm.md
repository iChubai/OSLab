# Default PMM (First-Fit 物理内存管理器) 详细文档

## 目录
- [引言](#引言)
- [内存管理基础概念](#内存管理基础概念)
- [Default PMM 概述](#default-pmm-概述)
- [数据结构详解](#数据结构详解)
- [算法原理](#算法原理)
- [核心函数实现](#核心函数实现)
- [工作流程详解](#工作流程详解)
- [关键技术和优势](#关键技术和优势)
- [使用示例](#使用示例)
- [测试和验证](#测试和验证)

## 引言

欢迎来到 **Default PMM** 的详细文档！如果你是操作系统内存管理的新手，别担心。本文档将从最基础的概念开始，一步步为你讲解 ucore 操作系统中的物理内存管理器实现。

**Default PMM** 是一个基于 **First-Fit（首次适应）算法** 的物理内存分配器，它负责管理计算机的物理内存，为操作系统内核和用户程序分配和释放内存页面。

## 内存管理基础概念

在深入 Default PMM 之前，让我们先了解一些基础概念：

### 1.1 什么是物理内存？
物理内存是计算机中真实的 RAM 芯片存储空间。在 32 位系统中，物理内存地址从 0x00000000 到 0xFFFFFFFF（4GB）。在 64 位系统中，这个范围要大得多。

### 1.2 页面（Page）的概念
现代操作系统不直接管理字节，而是将内存分成固定大小的块，称为"页面"（Page）。ucore 中每个页面大小为 **4096 字节（4KB）**。

### 1.3 为什么需要内存管理器？
想象一下，如果你想建造一栋大楼，你需要：
1. **跟踪哪些楼层是空的**（空闲内存）
2. **找到足够大的连续楼层**（连续内存分配）
3. **记录哪些楼层被占用了**（已分配内存）
4. **在不需要时释放楼层**（内存释放）

内存管理器就是干这些事情的！

## Default PMM 概述

**Default PMM** 是 ucore 操作系统的默认物理内存管理器实现，它采用了 **First-Fit 算法**。

### 2.1 First-Fit 算法是什么？

**First-Fit（首次适应）算法** 的工作原理很简单：
1. 维护一个空闲内存块的链表
2. 当需要分配 n 个页面时，从链表头部开始查找
3. 找到第一个**大小 >= n** 的空闲块
4. 如果找到，就从该块的前面切下 n 个页面分配出去
5. 如果剩余部分还有页面，就把剩余部分放回空闲链表

就像在超市排队买东西，你从队伍前面开始找，找到第一个能满足你需求的商品就拿走！

### 2.2 Default PMM 的特点

- **算法类型**：First-Fit（首次适应）
- **数据结构**：双向链表管理空闲块
- **页面大小**：4096 字节（4KB）
- **支持操作**：分配、释放、合并空闲块
- **适用场景**：物理内存管理，适合中等规模内存

## 数据结构详解

Default PMM 使用了几个关键数据结构，让我们逐一分析：

### 3.1 页面描述符（struct Page）

```c
struct Page {
    int ref;                        // 页面引用计数
    uint64_t flags;                 // 页面标志位（64位，包含多种状态）
    unsigned int property;          // 空闲块大小（仅对空闲块的第一个页面有效）
    list_entry_t page_link;         // 链表节点，用于链接空闲页面
};
```

**详细解释：**

- **`ref`**：引用计数器
  - 表示有多少个指针引用这个页面
  - 当 `ref > 0` 时，页面被使用，不能释放
  - 当 `ref = 0` 时，页面可以被释放

- **`flags`**：64位标志寄存器（非常重要！）
  ```c
  #define PG_reserved                 0  // 第0位：页面保留标志
  #define PG_property                 1  // 第1位：属性标志
  ```
  - 使用位操作管理页面状态，节省空间
  - `PG_reserved = 1`：页面被内核保留，不能分配
  - `PG_property = 1`：这是空闲块的第一个页面

- **`property`**：空闲块大小计数器
  - 只对空闲链表中的第一个页面有意义
  - 表示这个连续空闲块包含多少个页面
  - 被分配的页面这个值为0

- **`page_link`**：链表连接器
  - 将页面组织成双向链表
  - 空闲页面链表的节点

### 3.2 空闲区域管理器（free_area_t）

```c
typedef struct {
    list_entry_t free_list;         // 空闲链表头节点
    unsigned int nr_free;           // 空闲页面总数
} free_area_t;
```

**详细解释：**

- **`free_list`**：双向链表的头节点
  - 链表中存储的是空闲的连续内存块
  - 每个节点是一个 `struct Page`，但只用 `page_link` 字段

- **`nr_free`**：空闲页面总计数器
  - 记录整个系统中所有空闲页面的总数
  - 快速判断是否有足够内存分配

### 3.3 链表节点（list_entry_t）

```c
struct list_entry_t {
    struct list_entry_t *prev, *next;  // 前驱和后继指针
};
```

这是标准的双向链表节点，嵌入到 `struct Page` 中，形成侵入式链表。

## 算法原理

### 4.1 First-Fit 分配策略

**核心思想**："找到第一个能满足需求的空闲块"

**分配过程**：
1. 遍历空闲链表，从头开始查找
2. 找到第一个 `property >= n` 的页面
3. 如果 `property == n`，整块分配，标记为已使用
4. 如果 `property > n`，分割成两块：
   - 前 n 个页面分配出去
   - 剩余部分放回空闲链表

### 4.2 内存释放和合并策略

**释放原则**："尽可能合并相邻的空闲块"

**释放过程**：
1. 将释放的页面标记为空闲
2. 检查前一个块是否空闲，如果是则向前合并
3. 检查后一个块是否空闲，如果是则向后合并
4. 更新空闲块的 `property` 值

## 核心函数实现

让我们逐个分析 Default PMM 的核心函数：

### 5.1 初始化函数

```c
static void default_init(void) {
    list_init(&free_list);    // 初始化空闲链表
    nr_free = 0;             // 空闲页面数置零
}
```

**解释**：
- 建立一个空的空闲链表
- 初始状态下没有空闲页面

### 5.2 内存映射初始化

```c
static void default_init_memmap(struct Page *base, size_t n) {
    // 步骤1: 初始化所有页面
    for (int i = 0; i < n; i++) {
        PageReserved(base + i);        // 标记为保留（稍后会清除）
        (base + i)->flags = 0;         // 清零标志
        (base + i)->property = 0;      // 清零属性
        (base + i)->ref = 0;           // 清零引用计数
    }

    // 步骤2: 设置第一个页面的属性
    base->property = n;                // 空闲块大小设为 n
    SetPageProperty(base);             // 标记为属性页面
    nr_free += n;                      // 增加空闲页面计数

    // 步骤3: 插入到空闲链表
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        // 按地址顺序插入
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```

**详细步骤解释**：

1. **页面初始化**：将 n 个连续页面都标记为保留状态，然后清零所有标志，为加入空闲链表做准备

2. **设置属性**：将第一个页面的 `property` 设为 n，表示这是一个包含 n 个页面的空闲块

3. **链表插入**：按照地址从小到大的顺序插入空闲链表，保持链表有序

### 5.3 页面分配函数

```c
static struct Page *default_alloc_pages(size_t n) {
    // 步骤1: 参数检查
    if (n > nr_free) return NULL;

    // 步骤2: 查找合适的空闲块
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {      // 找到足够大的块
            // 步骤3: 从链表中移除
            list_entry_t* prev = list_prev(&(p->page_link));
            list_del(&(p->page_link));

            // 步骤4: 分割处理
            if (p->property > n) {
                struct Page *next = p + n;
                next->property = p->property - n;
                SetPageProperty(next);
                list_add(prev, &(next->page_link));
            }

            // 步骤5: 标记为已分配
            nr_free -= n;
            ClearPageProperty(p);
            return p;
        }
    }
    return NULL;  // 没找到合适的块
}
```

**分配算法详解**：

1. **查找阶段**：遍历空闲链表，寻找第一个满足 `property >= n` 的块
2. **分割逻辑**：如果空闲块更大，将剩余部分作为新块插入链表
3. **状态更新**：减少空闲计数，清空分配页面的属性标志

### 5.4 页面释放函数

```c
static void default_free_pages(struct Page *base, size_t n) {
    // 步骤1: 清空页面标志
    for (int i = 0; i < n; i++) {
        ClearPageReserved(base + i);
        (base + i)->flags = 0;
        (base + i)->ref = 0;
    }

    // 步骤2: 设置释放信息
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    // 步骤3: 插入空闲链表（地址有序）
    list_entry_t* le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page* page = le2page(le, page_link);
        if (base < page) {
            list_add_before(le, &(base->page_link));
            break;
        } else if (list_next(le) == &free_list) {
            list_add(le, &(base->page_link));
        }
    }

    // 步骤4: 向前合并
    le = list_prev(&(base->page_link));
    if (le != &free_list) {
        struct Page *prev = le2page(le, page_link);
        if (prev + prev->property == base) {
            prev->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = prev;
        }
    }

    // 步骤5: 向后合并
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        struct Page *next = le2page(le, page_link);
        if (base + base->property == next) {
            base->property += next->property;
            ClearPageProperty(next);
            list_del(&(next->page_link));
        }
    }
}
```

**释放算法详解**：

1. **清空标志**：将被释放的页面标记为空闲状态
2. **有序插入**：按照地址顺序插入空闲链表
3. **智能合并**：检查前后相邻块，自动合并连续空闲区域

## 工作流程详解

### 6.1 系统启动时的初始化流程

```
1. pmm_init() 被调用
   ├── init_pmm_manager() 选择 default_pmm_manager
   ├── page_init() 检测物理内存范围
   │   ├── 计算可用页面数 npage
   │   ├── 创建 pages 数组（每个页面一个 Page 结构体）
   │   └── 标记内核占用的页面为保留
   └── init_memmap() 将剩余页面加入空闲链表
```

### 6.2 页面分配流程（以分配 3 个连续页面为例）

```
原始空闲链表：[0x1000(5页)] [0x2000(8页)] [0x3000(2页)]

1. 查找阶段：遍历链表
   - 检查 0x1000：property=5 >=3 ✓
   - 找到第一个合适块

2. 分割处理：
   - 分配前3页：[0x1000, 0x1010, 0x1020]
   - 剩余2页：[0x1030, 0x1040] 创建新块

3. 更新链表：
   - 删除原 0x1000 块
   - 插入新 0x1030(2页) 块
   - nr_free -= 3

最终链表：[0x1030(2页)] [0x2000(8页)] [0x3000(2页)]
```

### 6.3 页面释放流程（以释放上述 3 个页面为例）

```
空闲链表：[0x1030(2页)] [0x2000(8页)] [0x3000(2页)]

1. 释放页面：[0x1000, 0x1010, 0x1020]
   - 标记为空闲，设置 property=3
   - 插入链表：位于 0x1030 之前

2. 向前合并检查：
   - 检查 0x1030 前面的块：无前块
   - 不需要向前合并

3. 向后合并检查：
   - 检查 0x1000 后面：0x1030
   - 0x1000 + 3 = 0x1030 ✓ 连续！
   - 合并：0x1000 property = 3 + 2 = 5
   - 删除 0x1030 块

最终链表：[0x1000 ■ 0x1030(5页)] [0x2000(8页)] [0x3000(2页)]
```

## 关键技术和优势

### 7.1 侵入式链表（Intrusive List）

**传统链表 vs 侵入式链表：**

```c
// 传统方式：需要额外内存存储链表节点
struct free_block {
    struct Page *page;           // 指向实际页面
    struct list_entry list_node; // 链表节点
};

// 侵入式方式：在数据结构中嵌入链表节点
struct Page {
    // ... 其他成员
    list_entry_t page_link;      // 直接嵌入！
};
```

**优势**：
- **节省内存**：不需要额外的链表节点内存
- **减少间接访问**：直接在页面结构体中操作
- **提高缓存友好性**：数据和链表节点在一起

### 7.2 位图标志管理

```c
uint64_t flags;  // 64位标志寄存器

// 单个位操作，管理多种状态
#define PG_reserved  0  // 保留位
#define PG_property  1  // 属性位

// 位操作函数
#define SetPageReserved(page)   ((page)->flags |= (1UL << PG_reserved))
#define PageReserved(page)      (((page)->flags >> PG_reserved) & 1)
```

**优势**：
- **空间高效**：一个 64 位整数管理 64 种状态
- **速度快**：位操作比条件判断快
- **易扩展**：轻松添加新标志位

### 7.3 连续块合并算法

**合并策略**：
- **向前合并**：释放时检查前一个块是否连续
- **向后合并**：释放时检查后一个块是否连续
- **即时合并**：释放时立即执行，避免碎片积累

**合并条件**：
```c
// 向前合并：前块结束地址 == 当前块开始地址
if (prev + prev->property == current) {
    prev->property += current->property;
    // 删除当前块
}

// 向后合并：当前块结束地址 == 后块开始地址
if (current + current->property == next) {
    current->property += next->property;
    // 删除后块
}
```

### 7.4 First-Fit 算法的优势

1. **实现简单**：算法逻辑清晰，易于理解和调试
2. **查找速度快**：找到第一个合适块就停止，不用遍历整个链表
3. **内存利用率高**：支持块分割，避免大块内存浪费
4. **合并效率高**：释放时及时合并，减少外部碎片

## 使用示例

### 8.1 基本分配释放

```c
// 分配单个页面
struct Page *page = alloc_page();
if (page != NULL) {
    // 使用页面...
    // 释放页面
    free_page(page);
}

// 分配多个连续页面
struct Page *pages = alloc_pages(5);  // 分配5个连续页面
if (pages != NULL) {
    // 使用连续内存块...
    free_pages(pages, 5);
}

// 检查空闲页面数
size_t free_count = nr_free_pages();
```

### 8.2 内存状态查询

```c
// 遍历所有空闲块
list_entry_t *le = &free_list;
while ((le = list_next(le)) != &free_list) {
    struct Page *p = le2page(le, page_link);
    printf("空闲块地址: 0x%lx, 大小: %d 页面\n",
           page2pa(p), p->property);
}

// 检查页面状态
struct Page *page = pa2page(0x1000000);  // 根据物理地址找页面
if (PageReserved(page)) {
    printf("页面被保留\n");
} else if (PageProperty(page)) {
    printf("页面是空闲块的第一个页面，大小: %d\n", page->property);
} else {
    printf("页面被分配，引用计数: %d\n", page->ref);
}
```

## 测试和验证

### 9.1 基本功能测试

Default PMM 包含完整的测试套件：

```c
static void basic_check(void) {
    // 测试基本分配释放功能
    struct Page *p0 = alloc_page();
    struct Page *p1 = alloc_page();
    struct Page *p2 = alloc_page();

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);
}
```

### 9.2 算法正确性测试

```c
static void default_check(void) {
    // 测试复杂分配场景
    struct Page *p0 = alloc_pages(5);

    // 分割释放测试
    free_pages(p0 + 2, 3);  // 释放中间3页
    assert(alloc_pages(4) == NULL);  // 无法分配4页
    assert(alloc_pages(3) != NULL);  // 可以分配3页

    // 合并测试
    free_pages(p0, 5);  // 释放所有
    assert(alloc_pages(5) != NULL); // 可以重新分配5页
}
```

### 9.3 性能测试

First-Fit 算法的时间复杂度：
- **分配**：O(n)，其中 n 是空闲块数量（最坏情况下遍历所有块）
- **释放**：O(n)，需要遍历查找插入位置和检查合并
- **空间复杂度**：O(m)，其中 m 是空闲块数量

## 总结

**Default PMM** 是一个功能完整、设计精巧的物理内存管理器。它采用 First-Fit 算法，通过侵入式链表和位图标志管理，实现了高效的内存分配和释放。核心优势包括：

1. **简单高效**：算法逻辑清晰，实现相对简单
2. **内存利用率高**：支持动态分割和智能合并
3. **扩展性好**：模块化设计，易于扩展和替换
4. **鲁棒性强**：包含完善的测试和错误检查

通过学习 Default PMM，你不仅掌握了物理内存管理的核心技术，还能深入理解操作系统底层的工作原理。这为学习虚拟内存管理、文件系统缓存等高级主题打下了坚实的基础。

如果你在学习过程中遇到任何问题，建议：
1. 仔细阅读代码注释
2. 动手调试运行，观察内存状态变化
3. 尝试修改算法参数，观察性能差异
4. 参考其他内存分配算法实现，对比优缺点

祝学习愉快！🎉
