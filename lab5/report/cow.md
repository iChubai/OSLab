# Copy-on-Write 设计说明

## 目标
- 父子进程在 fork 后共享可写用户页，写入时再复制，降低 fork 开销。
- 兼容现有页表/调度/系统调用逻辑，并保持 make grade 通过。

## 关键改动
- 新增 `PTE_COW` 作为软件位标记 COW 页。
- `copy_range` 对可写用户页去写权限、加 COW 标记，父子共享同一物理页；只读/可执行页保持共享映射。
- `CAUSE_STORE_PAGE_FAULT` 处理中识别 COW：
  - `ref>1` 分配新页，拷贝内容，重新插入可写映射。
  - `ref==1` 直接去掉 COW、恢复写权限。
- TLB 及时刷新，使用 `page_insert` 维持引用计数正确。

## 状态机（单页粒度）
- **Shared-RO (COW)**: `PTE_V=1, PTE_W=0, PTE_COW=1, ref>=2`
  - 事件：写访问 → 若 `ref>1` 复制到新页 → **Private-RW**；若 `ref==1` 直接去掉 COW → **Private-RW**。
- **Private-RW**: `PTE_V=1, PTE_W=1, PTE_COW=0, ref==1`
  - 事件：fork 且页可写 → 去写权限+设 COW，`ref++` → **Shared-RO (COW)**。
- **Invalid**: 无映射
  - 事件：缺页/分配 → 按需进入 **Private-RW** 或 **Shared-RO**。

## Dirty COW 讨论
- 脏牛漏洞源于 COW 处理与页表更新缺乏同步，导致两个并发线程在“判定需复制”与“实际改写 PTE”间出现竞态，进而共享了本应私有的页。
- 本实现在单核/关中断的异常处理路径中完成 COW 判定与映射更新，保持原子性，不会暴露竞态窗口。

## 测试建议
- `make run-cow`：父写 1、子写 2，父读应仍为 1。
- 压力：循环 fork+写多页，验证 ref 计数未泄漏、内容隔离。
- 现有 `make grade` 全部通过。
