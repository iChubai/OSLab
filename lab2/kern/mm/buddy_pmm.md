### 伙伴系统（Buddy System）分配算法设计说明

- 核心思想：按 2^order 页为单位管理空闲块；同阶块的伙伴地址由块首页索引 idx 与 (1<<order) 做 XOR 获取；释放时自底向上尝试与伙伴合并。
- 主要数据结构：
  - 多阶空闲链表数组 `buddy_area[0..BUDDY_MAX_ORDER]`，每项包含 `free_list` 与该阶空闲页计数 `nr_free`。
  - `Page.property` 存储块所属阶（仅块首页有效），`PG_property` 表示该页为空闲块首页。
- 初始化：
  - `buddy_init` 初始化各阶链表与计数；`buddy_init_memmap` 将 [base, base+n) 按最大对齐贪心拆分为若干块并插入，插入时调用 `try_coalesce_and_insert` 自底向上与伙伴合并。
- 分配：
  - `buddy_alloc_pages(n)` 选择最小不小于 n 的阶，若无则向上寻找更大阶并在取出后切割出前 n 页作为结果，剩余后缀再按 `insert_region` 回收以触发合并。
- 释放：
  - `buddy_free_pages(base,n)` 先清理标志，然后将 [base, base+n) 贪心拆分为最大对齐块并逐块 `try_coalesce_and_insert` 合并回各阶链表。
- 复杂度：
  - 分配/释放主要受阶数影响，单次操作 O(log N)。
- 正确性要点：
  - 只在块首页打 `PG_property`；仅块首页的 `property` 有意义；插入前需保证块未挂入链表；合并时严格按 XOR 伙伴与阶匹配判断。
- 自检：
  - `buddy_check` 覆盖：空链表分配失败、基础三页分配与释放、非 2 次幂大小分配/回收、切割与合并、分段释放后可恢复总空闲量。
