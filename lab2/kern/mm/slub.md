### SLUB 任意大小内存单元分配算法设计说明（简化版）

- 两层架构：
  - 第一层：页分配（依赖 pmm 的 alloc_pages/free_pages）。
  - 第二层：按 16~2048 的 2 次幂尺寸类建立缓存；对象首字节嵌入单链表 freelist。
- 主要数据结构：
  - `kmem_cache_t{object_size, partial, full}` 维护每个尺寸类的 slab 链。
  - `slab_page_t{page, free_head, inuse, capacity, next}` 描述一页 slab。
  - `sp_pool[]` 静态描述符池避免递归分配；大块分配使用 `large_hdr_t` 记录页数与首页。
- 初始化：
  - `slub_init` 建立描述符空闲池，初始化各尺寸类。
- 分配：
  - `kmalloc(size)` 小于等于 2048 走相应尺寸类；若无部分页则新建页并在页内构建 freelist；大于 2048 的大块按页对齐向上取整并在页首写入 `large_hdr_t`。
- 释放：
  - `kfree(ptr)` 优先在所有尺寸类的 partial/full 链查找归属页并回收；若非小块，则读取 `large_hdr_t` 并整页释放。
- 复杂度与特性：
  - 常数级分配/回收路径；外碎片低；页粒度回收；简化实现未做 NUMA、本地化和对象构造器。
- 自检：
  - `slub_check` 覆盖小块/中等块/大块的分配释放烟囱测试。
