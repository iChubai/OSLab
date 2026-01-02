// COW (Copy-on-Write) 内存机制测试程序
// 测试目标：验证操作系统正确实现了COW语义，确保进程间内存隔离和防止Dirty COW攻击

#include <ulib.h>        // 用户库头文件，包含系统调用和基本函数
#include <stdio.h>       // 标准输入输出头文件

// 内存页相关常量定义
#define PGSIZE 4096                                    // 页面大小（4KB）
#define WORDS_PER_PAGE (PGSIZE / sizeof(uint32_t))     // 每页可容纳的32位整数数量（1024个）
#define BUF_PAGES 32                                   // 测试缓冲区占用的页面数量
#define TOTAL_WORDS (BUF_PAGES * WORDS_PER_PAGE)       // 总的32位整数数量（32768个，128KB）

// 测试缓冲区：32页大小，按页边界对齐，使用volatile防止编译器优化
static volatile uint32_t cowbuf[TOTAL_WORDS] __attribute__((aligned(PGSIZE)));

// 根据种子和索引生成期望的数值，用于数据完整性验证
static inline uint32_t expected(uint32_t seed, int idx) {
    return seed ^ (uint32_t)idx;  // 使用异或运算生成可预测的测试数据
}

// 使用指定的种子填充整个测试缓冲区
static void fill_buf(uint32_t seed) {
    for (int i = 0; i < TOTAL_WORDS; i++) {
        cowbuf[i] = expected(seed, i);  // 每个位置填充对应的期望值
    }
}

// 检查整个缓冲区的数据完整性（完整检查，较慢但彻底）
static void check_buf_all(uint32_t seed) {
    for (int i = 0; i < TOTAL_WORDS; i++) {
        // 断言每个位置的值都等于期望值，否则程序崩溃
        assert(cowbuf[i] == expected(seed, i));
    }
}

// 采样检查缓冲区数据完整性（只检查每页的第一个和最后一个字，提高性能）
static void check_buf_sample(uint32_t seed) {
    for (int p = 0; p < BUF_PAGES; p++) {  // 遍历每一页
        int i0 = p * WORDS_PER_PAGE;       // 每页第一个字的索引
        int i1 = p * WORDS_PER_PAGE + (WORDS_PER_PAGE - 1);  // 每页最后一个字的索引
        uint32_t e0 = expected(seed, i0), e1 = expected(seed, i1);  // 计算期望值

        // 检查每页第一个字
        if (cowbuf[i0] != e0) {
            cprintf("cowtest: sample mismatch page=%d idx=%d got=0x%08x exp=0x%08x\n",
                    p, i0, cowbuf[i0], e0);
            panic("sample mismatch");  // 数据不匹配，程序崩溃
        }
        // 检查每页最后一个字
        if (cowbuf[i1] != e1) {
            cprintf("cowtest: sample mismatch page=%d idx=%d got=0x%08x exp=0x%08x\n",
                    p, i1, cowbuf[i1], e1);
            panic("sample mismatch");  // 数据不匹配，程序崩溃
        }
    }
}

// 测试1：基本隔离性测试
// 验证父子进程的COW内存是否正确隔离
static void test_basic_isolation(void) {
    // 使用特定的种子值初始化测试数据
    const uint32_t seed = 0xC0C00000u ^ 0x12345678u;
    fill_buf(seed);           // 填充缓冲区
    check_buf_all(seed);      // 验证填充正确性

    int pid = fork();         // 创建子进程
    assert(pid >= 0);         // 确保fork成功

    if (pid == 0) {           // 子进程执行分支
        check_buf_all(seed);  // 子进程验证继承的数据正确

        // 定义测试索引数组，覆盖不同页面的边界情况
        int idxs[] = {
            0,                                          // 第0页开头
            WORDS_PER_PAGE - 1,                         // 第0页结尾
            WORDS_PER_PAGE,                             // 第1页开头
            2 * WORDS_PER_PAGE + 123,                   // 第2页中间位置
            (BUF_PAGES - 1) * WORDS_PER_PAGE,           // 最后页开头
            (BUF_PAGES - 1) * WORDS_PER_PAGE + (WORDS_PER_PAGE - 1),  // 最后页结尾
        };

        // 子进程修改这些位置的值（触发COW写时复制）
        for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
            cowbuf[idxs[i]] = 0xA5A50000u ^ (uint32_t)idxs[i];
        }
        // 验证子进程的修改生效
        for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
            assert(cowbuf[idxs[i]] == (0xA5A50000u ^ (uint32_t)idxs[i]));
        }

        exit(0);  // 子进程退出
    }

    // 父进程：等待期间让出CPU，确保子进程有机会运行
    for (int i = 0; i < 200; i++) {
        yield();  // 让出CPU时间片
    }

    int status = -1;
    assert(waitpid(pid, &status) == 0);  // 等待子进程退出
    assert(status == 0);                // 确保子进程正常退出

    // 父进程验证其缓冲区未被子进程修改（关键测试点）
    int idxs[] = {
        0,
        WORDS_PER_PAGE - 1,
        WORDS_PER_PAGE,
        2 * WORDS_PER_PAGE + 123,
        (BUF_PAGES - 1) * WORDS_PER_PAGE,
        (BUF_PAGES - 1) * WORDS_PER_PAGE + (WORDS_PER_PAGE - 1),
    };
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
        // 断言父进程的数据仍然是原始值，未被子进程影响
        assert(cowbuf[idxs[i]] == expected(seed, idxs[i]));
    }

    // 父进程再次修改相同位置，验证写操作正常工作
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
        cowbuf[idxs[i]] = 0x5A5A0000u ^ (uint32_t)idxs[i];
    }
    for (unsigned int i = 0; i < sizeof(idxs) / sizeof(idxs[0]); i++) {
        assert(cowbuf[idxs[i]] == (0x5A5A0000u ^ (uint32_t)idxs[i]));
    }
}

// 子进程的"Dirty COW"尝试函数
// 模拟恶意进程尝试通过竞争条件修改共享内存
static void child_dirty_attempt(int id, uint32_t seed) {
    // 第一阶段：修改每页的边界位置
    for (int p = 0; p < BUF_PAGES; p++) {
        int base = p * WORDS_PER_PAGE;  // 当前页的起始索引
        // 修改每页的第一个字
        cowbuf[base] = ((uint32_t)id << 24) ^ (uint32_t)p;
        // 修改每页的最后一个字
        cowbuf[base + (WORDS_PER_PAGE - 1)] = ((uint32_t)id << 24) ^ (uint32_t)(p ^ 0x55);
        // 每4页让出一次CPU，增加竞争条件的概率
        if ((p & 3) == 0) {
            yield();
        }
    }

    // 第二阶段：随机访问模式写入，模拟复杂的内存访问模式
    for (int i = 0; i < 200; i++) {
        // 使用伪随机索引生成器：(i * 97 + id * 13) % TOTAL_WORDS
        // 97和13是精心选择的质数，确保良好的分布
        int idx = (i * 97 + id * 13) % TOTAL_WORDS;
        cowbuf[idx] ^= (uint32_t)(id + i);  // 使用异或修改值
        // 每8次操作让出一次CPU
        if ((i & 7) == 0) {
            yield();
        }
    }

    // 最终验证：确保子进程确实写入了自己的私有副本
    // 如果子进程的数据仍然等于原始期望值，说明COW机制失败
    assert(cowbuf[0] != expected(seed, 0) || cowbuf[WORDS_PER_PAGE] != expected(seed, WORDS_PER_PAGE));
    exit(0);  // 子进程退出
}

// 测试2：Dirty COW攻击防护测试
// 创建多个并发进程，验证COW机制能防止竞争条件攻击
static void test_dirty_cow_attempt(void) {
    // 使用不同的种子值，避免与第一个测试冲突
    const uint32_t seed = 0xD1A70000u ^ 0xCAFEBABEu;
    fill_buf(seed);           // 初始化缓冲区
    check_buf_sample(seed);   // 采样检查初始化正确性

    const int nchild = 8;     // 创建8个子进程
    int pids[nchild];         // 存储子进程PID数组

    // 创建8个子进程，每个子进程执行child_dirty_attempt
    for (int i = 0; i < nchild; i++) {
        int pid = fork();
        assert(pid >= 0);
        if (pid == 0) {
            child_dirty_attempt(i + 1, seed);  // 子进程ID从1开始
        }
        pids[i] = pid;  // 记录子进程PID
    }

    // 父进程：持续监控自己的缓冲区，同时子进程在写入
    for (int round = 0; round < 500; round++) {
        check_buf_sample(seed);  // 验证父进程缓冲区未被修改
        if ((round & 3) == 0) {  // 每4轮让出一次CPU
            yield();
        }
    }

    // 等待所有子进程退出
    for (int i = 0; i < nchild; i++) {
        int status = -1;
        assert(waitpid(pids[i], &status) == 0);  // 等待子进程
        assert(status == 0);                     // 确保正常退出
    }

    check_buf_all(seed);  // 完整验证父进程缓冲区未被任何子进程修改

    // 边界情况测试：当引用计数为1时，验证COW清理路径正常工作
    cowbuf[0] = 0x13572468u;
    assert(cowbuf[0] == 0x13572468u);
}

// 主函数：执行所有测试
int main(void) {
    cprintf("cowtest: start\n");           // 输出测试开始信息
    test_basic_isolation();                // 执行基本隔离性测试
    cprintf("cowtest: basic isolation ok\n");  // 输出第一阶段测试通过
    test_dirty_cow_attempt();              // 执行Dirty COW防护测试
    cprintf("cowtest pass.\n");            // 输出所有测试通过
    return 0;                              // 程序正常退出
}
