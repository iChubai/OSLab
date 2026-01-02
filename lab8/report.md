# Lab8 实验报告

## 练习0：填写已有实验
在 `lab8/kern/process/proc.c` 中补齐进程创建、上下文切换与文件表复制逻辑，并在 `lab8/kern/mm/pmm.c` 中完成 `copy_range` 的页复制；调度器部分在 `lab8/kern/schedule/default_sched.c` 与 `lab8/kern/schedule/default_sched_stride.c` 对齐了前序实验的实现。这样保证 lab8 在进程/调度/同步基础上可直接承载文件系统与执行程序的新增功能。

## 练习1：完成读文件操作
读文件的核心路径落在 `lab8/kern/fs/sfs/sfs_inode.c` 的 `sfs_io_nolock`：先根据 offset 与 endpos 计算首块偏移与块数量，再通过 `sfs_bmap_load_nolock` 得到物理块号；非对齐部分使用 `sfs_rbuf`（或写路径的 `sfs_wbuf`）处理，整块区域使用 `sfs_rblock`（或 `sfs_wblock`）批量读写。该实现严格区分“首块非对齐、整块、尾块非对齐”三类情况，并通过 `alen` 累计已完成长度，保证读写长度与文件边界一致。

## 练习2：完成基于文件系统的执行程序机制
执行程序的核心是 `lab8/kern/process/proc.c` 的 `load_icode` 与 `do_execve`。`do_execve` 通过 `sysfile_open` 打开程序文件并释放旧地址空间，`load_icode` 则用 `load_icode_read` 从文件读取 ELF 头与段表，依次 `mm_map` 建立 VMA、`pgdir_alloc_page` 分配页并将段内容读入内存，随后构建 BSS。用户栈在 `USTACKTOP` 下方映射，并将 `argc/argv` 字符串拷贝到用户栈，同时把 `a0/a1/sp/epc/status` 写入 trapframe，确保从内核返回后能直接进入用户态入口函数。该流程实现了“文件 → ELF 解析 → 虚拟地址空间构造 → 用户态入口”的完整路径。

## 扩展练习 Challenge1：UNIX PIPE 机制设计方案
Pipe 可用一个环形缓冲区实现，结构体包含 `buf`、`rpos/wpos`、`count`、`refcnt`，并配合 `mutex` + `cond_read/cond_write`（或两个信号量）完成同步；接口需有 `pipe()` 创建读写 fd，`pipe_read` 在空缓冲区时睡眠，`pipe_write` 在满缓冲区时睡眠，`pipe_close` 处理引用计数与唤醒等待者。关键点在于“读空/写满”的阻塞语义与并发访问的互斥保护。

## 扩展练习 Challenge2：软连接与硬连接设计方案
硬链接可直接增加 inode 的 `nlinks` 并在目录中新建指向同一 inode 的目录项；软链接可用一种特殊 inode 类型，其数据区保存目标路径字符串，打开时在 VFS 层进行路径解析与递归跟随。接口上需提供 `link(path, newpath)`、`symlink(target, linkpath)`、`unlink(path)` 与 `lstat` 等语义；同步上需要在目录 inode 上加锁以保证目录项与 `nlinks` 更新原子性，避免并发下出现悬空或计数错误。

## 重要知识点与 OS 原理对应
本实验重点涵盖：SFS 文件的块映射与 inode 读写（对应文件系统的 inode/目录项/块管理原理）、ELF 装载与地址空间构建（对应进程装载与虚拟内存管理原理）、用户栈参数传递与 trapframe 切换（对应用户态/内核态切换机制）。从实现上看，`lab8/kern/fs/sfs/sfs_inode.c` 与 `lab8/kern/process/proc.c` 将抽象的“文件与进程”概念落实为可执行的内核路径。

## OS 原理中重要但实验未覆盖的知识点
实验未直接覆盖的部分包括：页缓存与回写策略、日志文件系统与崩溃一致性、mmap 文件映射与按需调页、VFS 的复杂挂载与跨文件系统一致性语义等，这些在完整 OS 中同样关键。
