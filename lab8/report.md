# Lab8 文件系统实验报告

## 实验概述

Lab8 是 ucore 操作系统实验的最后一个实验，主要目标是在前面实验的基础上实现一个简单的文件系统（Simple File System，SFS）。本实验涉及文件系统的核心概念，包括 VFS（虚拟文件系统）、SFS 文件系统、文件读写操作以及基于文件系统的程序执行机制。

---

## 练习0：填写已有实验

本实验依赖实验 2/3/4/5/6/7。需要将之前实验中完成的代码填入本实验相应位置。

### 主要代码合并内容

#### 1. `kern/process/proc.c` - `alloc_proc` 函数

需要在 Lab7 基础上新增对 `filesp` 字段的初始化：

```c
static struct proc_struct *
alloc_proc(void)
{
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4 代码：基本进程字段初始化
        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
        proc->flags = 0;
        memset(proc->name, 0, sizeof(proc->name));
        
        // LAB5 代码：进程关系字段初始化
        proc->wait_state = 0;
        proc->cptr = proc->optr = proc->yptr = NULL;
        
        // LAB6 代码：调度器字段初始化
        proc->rq = NULL;
        list_init(&(proc->run_link));
        proc->time_slice = 0;
        skew_heap_init(&(proc->lab6_run_pool));
        proc->lab6_stride = 0;
        proc->lab6_priority = 1;
        
        // LAB8 新增：文件结构指针初始化
        proc->filesp = NULL;
    }
    return proc;
}
```

#### 2. `kern/process/proc.c` - `do_fork` 函数

在 Lab7 基础上需要添加文件描述符表的复制：

```c
// 在 copy_mm 之后添加文件复制
if (copy_files(clone_flags, proc) != 0)
{
    goto bad_fork_cleanup_mm;
}
```

#### 3. `kern/process/proc.c` - `proc_run` 函数

在 Lab7 基础上需要添加 TLB 刷新操作：

```c
void proc_run(struct proc_struct *proc)
{
    if (proc != current)
    {
        bool intr_flag;
        struct proc_struct *prev = current;
        local_intr_save(intr_flag);
        {
            current = proc;
            lsatp(proc->pgdir);
            flush_tlb();  // LAB8 新增：刷新TLB
            switch_to(&(prev->context), &(proc->context));
        }
        local_intr_restore(intr_flag);
    }
}
```

---

## 练习1：完成读文件操作的实现

### 1.1 文件读写流程分析

在 ucore 中，文件读写的完整调用链如下：

```
用户程序 read()
    → sys_read()
    → sysfile_read()
    → file_read()
    → vop_read()
    → sfs_read()
    → sfs_io()
    → sfs_io_nolock()
```

### 1.2 `sfs_io_nolock` 函数实现

该函数位于 `kern/fs/sfs/sfs_inode.c`，是 SFS 文件系统中实现文件读写的核心函数。

#### 函数原型与参数说明

```c
/*
 * sfs_io_nolock - 从 offset 位置读/写 *alenp 长度的数据到 buffer
 * @sfs:    SFS 文件系统结构
 * @sin:    内存中的 SFS inode
 * @buf:    读/写缓冲区
 * @offset: 文件偏移量
 * @alenp:  需要读/写的长度指针，函数返回时存储实际读/写的长度
 * @write:  布尔值，0 表示读，1 表示写
 */
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, 
              off_t offset, size_t *alenp, bool write);
```

#### 核心实现代码

```c
static int
sfs_io_nolock(struct sfs_fs *sfs, struct sfs_inode *sin, void *buf, 
              off_t offset, size_t *alenp, bool write) {
    struct sfs_disk_inode *din = sin->din;
    assert(din->type != SFS_TYPE_DIR);
    off_t endpos = offset + *alenp, blkoff;
    *alenp = 0;
    
    // 边界检查
    if (offset < 0 || offset >= SFS_MAX_FILE_SIZE || offset > endpos) {
        return -E_INVAL;
    }
    if (offset == endpos) {
        return 0;
    }
    if (endpos > SFS_MAX_FILE_SIZE) {
        endpos = SFS_MAX_FILE_SIZE;
    }
    
    // 读操作时需要检查文件大小边界
    if (!write) {
        if (offset >= din->size) {
            return 0;
        }
        if (endpos > din->size) {
            endpos = din->size;
        }
    }

    // 根据操作类型选择对应的读写函数
    int (*sfs_buf_op)(struct sfs_fs *sfs, void *buf, size_t len, 
                      uint32_t blkno, off_t offset);
    int (*sfs_block_op)(struct sfs_fs *sfs, void *buf, 
                        uint32_t blkno, uint32_t nblks);
    if (write) {
        sfs_buf_op = sfs_wbuf, sfs_block_op = sfs_wblock;
    } else {
        sfs_buf_op = sfs_rbuf, sfs_block_op = sfs_rblock;
    }

    int ret = 0;
    size_t size, alen = 0;
    uint32_t ino;
    uint32_t blkno = offset / SFS_BLKSIZE;          // 起始块号
    uint32_t nblks = endpos / SFS_BLKSIZE - blkno;  // 需要处理的完整块数
    size_t total_len = endpos - offset;

    // 计算块内偏移
    blkoff = offset % SFS_BLKSIZE;
    
    // (1) 处理首块（可能非对齐）
    if (blkoff != 0) {
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }
        alen += size;
        buf += size;
        blkno++;
        if (nblks > 0) {
            nblks--;
        }
    }
    
    // (2) 处理中间完整块
    if (nblks != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {
            goto out;
        }
        size = nblks * SFS_BLKSIZE;
        alen += size;
        buf += size;
        blkno += nblks;
    }
    
    // (3) 处理尾块（可能非对齐）
    if (alen < total_len) {
        size = total_len - alen;
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        alen += size;
    }

out:
    *alenp = alen;
    if (offset + alen > sin->din->size) {
        sin->din->size = offset + alen;
        sin->dirty = 1;
    }
    return ret;
}
```

### 1.3 实现原理分析

#### 三种情况的处理

文件读写需要处理三种情况：

| 情况 | 描述 | 处理方式 |
|------|------|----------|
| **首块非对齐** | offset 不在块边界上 | 使用 `sfs_buf_op` 读取部分块 |
| **中间整块** | 完整的数据块 | 使用 `sfs_block_op` 批量读取 |
| **尾块非对齐** | 末尾不足一个块 | 使用 `sfs_buf_op` 读取部分块 |

#### 块映射机制

```
逻辑块号 → sfs_bmap_load_nolock() → 物理块号
```

`sfs_bmap_load_nolock` 函数负责将逻辑块号转换为磁盘物理块号：
- 对于前 12 个块（直接块），直接从 `din->direct[index]` 获取
- 对于更大的块号，通过 `din->indirect` 间接块获取

#### 数据读写示意图

```
文件内容:  [====|====|====|====|====|====]
            ^                         ^
          offset                    endpos

处理方式:  [部分|完整|完整|完整|完整|部分]
           首块  ←── 中间块 ──→  尾块
```

---

## 练习2：完成基于文件系统的执行程序机制的实现

### 2.1 执行程序的整体流程

```
用户调用 exec()
    → sys_exec()
    → do_execve()
        → sysfile_open() 打开可执行文件
        → 释放旧的内存空间
        → load_icode() 加载新程序
            → 创建新的内存管理结构
            → 读取 ELF 头
            → 加载各个程序段
            → 建立用户栈
            → 设置 trapframe
    → 返回用户态执行新程序
```

### 2.2 `load_icode` 函数实现

该函数位于 `kern/process/proc.c`，负责从文件系统加载可执行文件并建立进程的地址空间。

#### 辅助函数 `load_icode_read`

```c
static int
load_icode_read(int fd, void *buf, size_t len, off_t offset)
{
    int ret;
    if ((ret = sysfile_seek(fd, offset, LSEEK_SET)) != 0) {
        return ret;
    }
    if ((ret = sysfile_read(fd, buf, len)) != len) {
        return (ret < 0) ? ret : -1;
    }
    return 0;
}
```

#### 主函数实现

```c
static int
load_icode(int fd, int argc, char **kargv)
{
    // 检查当前进程没有内存管理结构
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm = NULL;
    struct elfhdr elf;
    struct proghdr ph;
    bool set_mm = 0;

    // (1) 创建新的内存管理结构
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    
    // (2) 创建新的页目录表
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    
    // (3.1) 从文件读取并解析 ELF 头
    if ((ret = load_icode_read(fd, &elf, sizeof(struct elfhdr), 0)) != 0) {
        goto bad_elf_cleanup_pgdir;
    }
    
    // 验证 ELF 魔数
    if (elf.e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    // (3.2-3.5) 遍历并加载各个程序段
    int i;
    for (i = 0; i < elf.e_phnum; i++) {
        // 读取程序头
        if ((ret = load_icode_read(fd, &ph, sizeof(struct proghdr),
                                   elf.e_phoff + i * sizeof(struct proghdr))) != 0) {
            goto bad_cleanup_mmap;
        }
        
        // 只处理可加载段
        if (ph.p_type != ELF_PT_LOAD) {
            continue;
        }
        
        // 验证段大小
        if (ph.p_filesz > ph.p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }

        // 设置 VMA 标志和页表权限
        uint32_t vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph.p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph.p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph.p_flags & ELF_PF_R) vm_flags |= VM_READ;

        if (vm_flags & VM_READ)  perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC)  perm |= PTE_X;

        // (3.3) 建立虚拟内存区域
        if ((ret = mm_map(mm, ph.p_va, ph.p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }

        // (3.4) 分配物理页面并复制段内容
        uintptr_t start = ph.p_va;
        uintptr_t end = ph.p_va + ph.p_filesz;
        uintptr_t la = ROUNDDOWN(start, PGSIZE);
        struct Page *page = NULL;

        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            size_t off = start - la;
            size_t size = PGSIZE - off;
            if (end < la + PGSIZE) {
                size = end - start;
            }
            // 从文件读取段内容到物理页
            if ((ret = load_icode_read(fd, page2kva(page) + off, size,
                                       ph.p_offset + (start - ph.p_va))) != 0) {
                goto bad_cleanup_mmap;
            }
            start += size;
            la += PGSIZE;
        }

        // (3.5) 处理 BSS 段（零初始化）
        end = ph.p_va + ph.p_memsz;
        if (start < la) {
            if (start == end) continue;
            size_t off = start + PGSIZE - la;
            size_t size = PGSIZE - off;
            if (end < la) size -= la - end;
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            size_t off = start - la;
            size_t size = PGSIZE - off;
            if (end < la) size -= la - end;
            memset(page2kva(page) + off, 0, size);
            start += size;
            la += PGSIZE;
        }
    }

    // (4) 建立用户栈
    uint32_t vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    
    // 预先分配 4 个页面给用户栈
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);

    // (5) 设置进程的 mm 和页目录
    mm_count_inc(mm);
    current->mm = mm;
    current->pgdir = PADDR(mm->pgdir);
    lsatp(PADDR(mm->pgdir));
    set_mm = 1;

    // (6) 设置用户栈参数 (argc/argv)
    uintptr_t stacktop = USTACKTOP;
    uintptr_t uargv[EXEC_MAX_ARG_NUM + 1];
    
    // 将参数字符串复制到用户栈
    for (i = argc - 1; i >= 0; i--) {
        size_t len = strlen(kargv[i]) + 1;
        if (stacktop < USTACKTOP - USTACKSIZE + len) {
            ret = -E_NO_MEM;
            goto bad_cleanup_current;
        }
        stacktop -= len;
        if (!copy_to_user(mm, (void *)stacktop, kargv[i], len)) {
            ret = -E_INVAL;
            goto bad_cleanup_current;
        }
        uargv[i] = stacktop;
    }
    uargv[argc] = 0;

    // 对齐栈指针并复制 argv 指针数组
    stacktop &= ~(sizeof(uintptr_t) - 1);
    stacktop -= (argc + 1) * sizeof(uintptr_t);
    if (!copy_to_user(mm, (void *)stacktop, uargv, (argc + 1) * sizeof(uintptr_t))) {
        ret = -E_INVAL;
        goto bad_cleanup_current;
    }

    // (7) 设置 trapframe
    struct trapframe *tf = current->tf;
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    tf->gpr.sp = stacktop;        // 栈指针
    tf->gpr.a0 = argc;            // 第一个参数：argc
    tf->gpr.a1 = stacktop;        // 第二个参数：argv
    tf->epc = elf.e_entry;        // 程序入口点
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;

    ret = 0;
out:
    sysfile_close(fd);
    return ret;

// 错误处理代码...
}
```

### 2.3 用户栈布局

程序执行时用户栈的布局如下：

```
高地址
    +------------------+ <- USTACKTOP
    |      ...         |
    +------------------+
    | argv[n] string   |
    +------------------+
    | argv[n-1] string |
    +------------------+
    |      ...         |
    +------------------+
    | argv[0] string   |
    +------------------+
    | NULL (argv终止)   |
    +------------------+
    | argv[n] pointer  |
    +------------------+
    |      ...         |
    +------------------+
    | argv[0] pointer  | <- a1 (argv)
    +------------------+ <- sp
低地址
```

---

## 扩展练习 Challenge1：UNIX PIPE 机制设计方案

### 3.1 概述

管道（Pipe）是 UNIX 系统中一种重要的进程间通信（IPC）机制，它提供了一种单向的数据流通道，使得一个进程可以将输出直接传递给另一个进程作为输入。

### 3.2 数据结构设计

#### 管道核心结构

```c
#define PIPE_BUF_SIZE 4096  // 管道缓冲区大小

struct pipe_struct {
    char buf[PIPE_BUF_SIZE];    // 环形缓冲区
    uint32_t rpos;              // 读位置
    uint32_t wpos;              // 写位置
    uint32_t count;             // 缓冲区中的数据量
    int ref_count;              // 引用计数
    bool reader_closed;         // 读端是否关闭
    bool writer_closed;         // 写端是否关闭
    semaphore_t mutex;          // 互斥锁
    semaphore_t not_empty;      // 缓冲区非空信号量
    semaphore_t not_full;       // 缓冲区非满信号量
};
```

#### 管道 inode 结构

```c
struct pipe_inode {
    struct pipe_struct *pipe;   // 指向管道结构
    bool is_read_end;           // 是否为读端
};
```

#### 进程文件结构扩展

```c
struct file {
    enum {
        FD_NONE, 
        FD_INIT, 
        FD_OPENED, 
        FD_CLOSED,
        FD_PIPE       // 新增：管道类型
    } status;
    bool readable;
    bool writable;
    int fd;
    off_t pos;
    struct inode *node;
    struct pipe_struct *pipe;  // 新增：管道指针
    int open_count;
};
```

### 3.3 接口设计

#### 创建管道

```c
/*
 * pipe_create - 创建一个管道
 * @fds: 存储两个文件描述符的数组，fds[0] 为读端，fds[1] 为写端
 * Return: 0 成功，-E_NO_MEM 内存不足
 */
int pipe_create(int fds[2]);
```

#### 管道读操作

```c
/*
 * pipe_read - 从管道读取数据
 * @pipe: 管道结构指针
 * @buf:  目标缓冲区
 * @len:  请求读取的长度
 * Return: 实际读取的字节数，0 表示写端已关闭且缓冲区空
 * 
 * 同步语义：
 *   - 缓冲区为空且写端未关闭时阻塞
 *   - 缓冲区为空且写端已关闭时返回 0
 */
ssize_t pipe_read(struct pipe_struct *pipe, void *buf, size_t len);
```

#### 管道写操作

```c
/*
 * pipe_write - 向管道写入数据
 * @pipe: 管道结构指针
 * @buf:  源缓冲区
 * @len:  请求写入的长度
 * Return: 实际写入的字节数，-E_PIPE 表示读端已关闭
 * 
 * 同步语义：
 *   - 缓冲区满时阻塞
 *   - 读端关闭时产生 SIGPIPE 信号（简化实现返回错误）
 */
ssize_t pipe_write(struct pipe_struct *pipe, const void *buf, size_t len);
```

#### 关闭管道

```c
/*
 * pipe_close - 关闭管道的一端
 * @pipe: 管道结构指针
 * @is_read_end: 是否为读端
 * 
 * 同步语义：
 *   - 关闭读端时唤醒所有阻塞的写者
 *   - 关闭写端时唤醒所有阻塞的读者
 *   - 两端都关闭时释放管道资源
 */
void pipe_close(struct pipe_struct *pipe, bool is_read_end);
```

### 3.4 同步互斥处理

#### 读操作伪代码

```c
ssize_t pipe_read(struct pipe_struct *pipe, void *buf, size_t len) {
    ssize_t bytes_read = 0;
    
    down(&pipe->mutex);  // 获取互斥锁
    
    while (pipe->count == 0 && !pipe->writer_closed) {
        up(&pipe->mutex);              // 释放锁
        down(&pipe->not_empty);        // 等待非空
        down(&pipe->mutex);            // 重新获取锁
    }
    
    // 写端关闭且缓冲区空
    if (pipe->count == 0 && pipe->writer_closed) {
        up(&pipe->mutex);
        return 0;
    }
    
    // 从环形缓冲区读取数据
    while (len > 0 && pipe->count > 0) {
        buf[bytes_read++] = pipe->buf[pipe->rpos];
        pipe->rpos = (pipe->rpos + 1) % PIPE_BUF_SIZE;
        pipe->count--;
        len--;
    }
    
    up(&pipe->not_full);   // 通知写者可写
    up(&pipe->mutex);      // 释放锁
    
    return bytes_read;
}
```

#### 写操作伪代码

```c
ssize_t pipe_write(struct pipe_struct *pipe, const void *buf, size_t len) {
    ssize_t bytes_written = 0;
    
    down(&pipe->mutex);
    
    // 读端关闭，写入失败
    if (pipe->reader_closed) {
        up(&pipe->mutex);
        return -E_PIPE;
    }
    
    while (len > 0) {
        while (pipe->count == PIPE_BUF_SIZE && !pipe->reader_closed) {
            up(&pipe->mutex);
            down(&pipe->not_full);
            down(&pipe->mutex);
        }
        
        if (pipe->reader_closed) {
            up(&pipe->mutex);
            return (bytes_written > 0) ? bytes_written : -E_PIPE;
        }
        
        pipe->buf[pipe->wpos] = buf[bytes_written++];
        pipe->wpos = (pipe->wpos + 1) % PIPE_BUF_SIZE;
        pipe->count++;
        len--;
        
        up(&pipe->not_empty);  // 通知读者可读
    }
    
    up(&pipe->mutex);
    return bytes_written;
}
```

---

## 扩展练习 Challenge2：软连接与硬连接机制设计方案

### 4.1 概述

- **硬链接（Hard Link）**：多个目录项指向同一个 inode，共享数据块
- **软链接（Symbolic Link）**：一种特殊文件，内容是另一个文件的路径名

### 4.2 数据结构设计

#### 扩展磁盘 inode 结构

```c
struct sfs_disk_inode {
    uint32_t size;                      // 文件大小（字节）
    uint16_t type;                      // 文件类型
    uint16_t nlinks;                    // 硬链接计数
    uint32_t blocks;                    // 数据块数量
    uint32_t direct[SFS_NDIRECT];       // 直接块指针
    uint32_t indirect;                  // 间接块指针
};

// 文件类型定义
#define SFS_TYPE_INVAL  0   // 无效类型
#define SFS_TYPE_FILE   1   // 普通文件
#define SFS_TYPE_DIR    2   // 目录
#define SFS_TYPE_LINK   3   // 符号链接（新增使用）
```

#### 符号链接专用结构

```c
#define SFS_SYMLINK_MAX_LEN  (SFS_BLKSIZE - 1)

struct sfs_symlink_data {
    char target_path[SFS_SYMLINK_MAX_LEN + 1];  // 目标路径
};
```

#### 目录项结构

```c
struct sfs_disk_entry {
    uint32_t ino;                            // inode 编号
    char name[SFS_MAX_FNAME_LEN + 1];        // 文件名
};
```

### 4.3 硬链接接口设计

#### 创建硬链接

```c
/*
 * sfs_link - 创建硬链接
 * @old_path: 原文件路径
 * @new_path: 新链接路径
 * Return: 0 成功，错误码失败
 * 
 * 实现要点：
 *   1. 查找 old_path 对应的 inode
 *   2. 验证不是目录（POSIX 不允许目录硬链接）
 *   3. 在 new_path 的父目录中创建新目录项，指向相同 inode
 *   4. 增加 inode 的 nlinks 计数
 *   
 * 同步处理：
 *   - 加锁顺序：父目录 inode → 目标 inode
 *   - 目录项创建和 nlinks 更新需原子进行
 */
int sfs_link(const char *old_path, const char *new_path);
```

#### 删除链接

```c
/*
 * sfs_unlink - 删除链接（或文件）
 * @path: 文件/链接路径
 * Return: 0 成功，错误码失败
 * 
 * 实现要点：
 *   1. 查找路径对应的 inode
 *   2. 从父目录中删除目录项
 *   3. 减少 nlinks 计数
 *   4. 若 nlinks == 0 且无打开引用，释放 inode 和数据块
 */
int sfs_unlink(const char *path);
```

### 4.4 软链接接口设计

#### 创建软链接

```c
/*
 * sfs_symlink - 创建符号链接
 * @target: 目标路径（存储在符号链接内）
 * @linkpath: 符号链接路径
 * Return: 0 成功，错误码失败
 * 
 * 实现要点：
 *   1. 分配新 inode，设置 type = SFS_TYPE_LINK
 *   2. 将 target 字符串存入 inode 的数据块
 *   3. 在 linkpath 的父目录中创建目录项
 */
int sfs_symlink(const char *target, const char *linkpath);
```

#### 读取软链接目标

```c
/*
 * sfs_readlink - 读取符号链接的目标路径
 * @path: 符号链接路径
 * @buf:  存储目标路径的缓冲区
 * @len:  缓冲区大小
 * Return: 目标路径长度，错误码失败
 */
ssize_t sfs_readlink(const char *path, char *buf, size_t len);
```

#### 路径解析时的符号链接处理

```c
/*
 * sfs_lookup_with_symlink - 解析路径，自动跟随符号链接
 * @path: 待解析路径
 * @node_store: 返回最终 inode
 * @follow_link: 是否跟随最后一个路径组件的符号链接
 * 
 * 实现要点：
 *   - 设置最大跟随深度（如 40）防止循环引用
 *   - 遇到符号链接时读取目标路径并递归解析
 */
int sfs_lookup_with_symlink(const char *path, struct inode **node_store, 
                            bool follow_link);
```

### 4.5 同步互斥处理

#### 硬链接操作的锁策略

```c
int sfs_link(const char *old_path, const char *new_path) {
    struct inode *old_node, *parent_node;
    
    // 1. 获取源文件 inode
    ret = vfs_lookup(old_path, &old_node);
    
    // 2. 获取目标父目录 inode
    ret = vfs_lookup_parent(new_path, &parent_node, &name);
    
    // 3. 按固定顺序加锁（避免死锁）
    // 策略：按 inode 编号顺序加锁
    if (old_node->ino < parent_node->ino) {
        lock_inode(old_node);
        lock_inode(parent_node);
    } else {
        lock_inode(parent_node);
        lock_inode(old_node);
    }
    
    // 4. 创建目录项
    ret = sfs_dirent_create(parent_node, name, old_node->ino);
    
    // 5. 增加 nlinks
    old_node->din->nlinks++;
    old_node->dirty = 1;
    
    // 6. 解锁
    unlock_inode(parent_node);
    unlock_inode(old_node);
    
    return ret;
}
```

#### 软链接循环检测

```c
#define MAX_SYMLINK_DEPTH 40

static int 
resolve_symlink(struct inode *node, char *resolved_path, int depth) {
    if (depth > MAX_SYMLINK_DEPTH) {
        return -E_LOOP;  // 符号链接嵌套过深
    }
    
    if (node->type != SFS_TYPE_LINK) {
        return 0;  // 不是符号链接
    }
    
    // 读取符号链接目标
    char target[SFS_SYMLINK_MAX_LEN + 1];
    sfs_read_symlink_target(node, target);
    
    // 递归解析
    struct inode *target_node;
    ret = sfs_lookup(target, &target_node);
    
    return resolve_symlink(target_node, resolved_path, depth + 1);
}
```

---

## 重要知识点与 OS 原理对应

### 5.1 实验涉及的核心知识点

| 实验知识点 | OS 原理知识点 | 含义与关系 |
|-----------|--------------|-----------|
| **SFS 文件系统** | 文件系统设计 | SFS 是简化的 UNIX 文件系统，实现了 inode、目录项、块管理等核心概念 |
| **VFS 虚拟文件系统** | 文件系统抽象层 | VFS 提供统一的文件操作接口，屏蔽底层文件系统差异 |
| **inode 与数据块映射** | 文件存储组织 | 直接块 + 间接块的经典设计，平衡小文件效率与大文件支持 |
| **文件描述符表** | 进程文件管理 | 进程级的打开文件表，实现文件共享与隔离 |
| **ELF 程序加载** | 可执行文件格式 | 标准的可执行文件格式，定义代码段、数据段、入口点等 |
| **用户栈参数传递** | 系统调用约定 | argc/argv 通过栈传递，遵循 RISC-V 调用约定 |
| **trapframe 设置** | 上下文切换 | 保存/恢复用户态执行环境，实现内核态↔用户态切换 |
| **信号量同步** | 进程同步机制 | 用于文件系统的互斥访问保护 |

### 5.2 各层次的知识对应

#### 文件系统层次结构

```
┌─────────────────────────────────────────────┐
│           用户程序 (read/write/open...)      │  ← 系统调用接口
├─────────────────────────────────────────────┤
│           sysfile 层 (sysfile_read...)      │  ← 系统调用实现
├─────────────────────────────────────────────┤
│           file 层 (file_read...)            │  ← 文件抽象
├─────────────────────────────────────────────┤
│           VFS 层 (vop_read...)              │  ← 虚拟文件系统
├─────────────────────────────────────────────┤
│           SFS 层 (sfs_read...)              │  ← 具体文件系统
├─────────────────────────────────────────────┤
│           设备层 (device read/write)         │  ← 块设备驱动
└─────────────────────────────────────────────┘
```

#### 原理与实现的差异

1. **块缓存（Buffer Cache）**
   - 原理：应有页缓存/块缓存提高性能
   - 实验：直接读写磁盘，无缓存机制

2. **文件锁定**
   - 原理：应支持 fcntl 文件锁、记录锁
   - 实验：仅有简单的信号量保护

3. **异步 I/O**
   - 原理：应支持异步读写提高并发性
   - 实验：所有 I/O 都是同步阻塞的

---

## OS 原理中重要但实验未覆盖的知识点

### 6.1 页缓存与回写策略

**原理**：Linux 等系统使用页缓存（Page Cache）缓存磁盘数据，采用延迟写（Write-back）策略，由 pdflush 等后台线程定期刷新脏页。

**实验缺失**：ucore SFS 每次读写都直接访问磁盘，无缓存机制，影响性能。

### 6.2 日志文件系统与崩溃一致性

**原理**：ext3/ext4、XFS 等使用日志（Journal）保证崩溃一致性，记录元数据或数据的修改日志，崩溃后可回放恢复。

**实验缺失**：SFS 无日志机制，崩溃可能导致文件系统不一致。

### 6.3 mmap 文件映射

**原理**：通过 mmap 将文件映射到进程地址空间，实现文件与内存的统一访问，支持按需调页（Demand Paging）。

**实验缺失**：ucore 不支持 mmap，文件只能通过 read/write 访问。

### 6.4 目录项缓存（dentry cache）

**原理**：缓存路径名到 inode 的映射，加速路径解析。

**实验缺失**：每次路径查找都从磁盘读取目录项。

### 6.5 虚拟文件系统的完整挂载机制

**原理**：支持多文件系统共存、挂载点管理、跨文件系统操作等。

**实验缺失**：ucore 只支持单一的 SFS 文件系统，挂载机制简化。

### 6.6 文件权限与访问控制

**原理**：UNIX 权限位（rwx）、ACL、SELinux 等多级访问控制机制。

**实验缺失**：ucore 未实现文件权限检查。

### 6.7 设备文件与特殊文件系统

**原理**：/dev 设备文件、/proc 进程文件系统、/sys 系统文件系统等。

**实验缺失**：仅实现了基本的 stdin/stdout/disk 设备，无完整的设备文件系统。

---

## 实验总结

Lab8 是 ucore 操作系统实验的收官之作，通过实现简单文件系统（SFS）和基于文件系统的程序执行机制，将前序实验中的进程管理、内存管理、同步机制等知识点串联起来，形成一个相对完整的操作系统雏形。

实验中实现的核心功能包括：
1. **sfs_io_nolock**：实现了文件的块级读写，处理了首块、中间块、尾块三种情况
2. **load_icode**：实现了从文件系统加载 ELF 可执行文件的完整流程
3. **文件描述符管理**：在进程中维护打开文件表

通过本次实验，深入理解了：
- 文件系统的层次化设计（VFS → 具体文件系统 → 块设备）
- inode 与数据块的映射关系
- 程序加载与执行的底层机制
- 用户态与内核态的切换过程

本实验虽然实现了基本功能，但与真实的 Linux 文件系统相比仍有较大差距，如缺少页缓存、日志、权限控制等机制，这些都是后续深入学习的方向。
