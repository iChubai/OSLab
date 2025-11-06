
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0205337          	lui	t1,0xc0205
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
    extern char edata[], end[];
    /* 清除BSS段（未初始化的全局变量区域）
     * edata是数据段结束，end是BSS段结束
     * 确保所有未初始化的全局变量都被设置为0
     */
    memset(edata, 0, end - edata);
ffffffffc0200054:	00006517          	auipc	a0,0x6
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0206028 <free_area>
ffffffffc020005c:	00006617          	auipc	a2,0x6
ffffffffc0200060:	43c60613          	addi	a2,a2,1084 # ffffffffc0206498 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	14d010ef          	jal	ra,ffffffffc02019b8 <memset>

    /* 初始化设备树
     * 从DTB（Device Tree Blob）中解析系统硬件信息
     * 包括内存布局、设备信息等
     */
    dtb_init();
ffffffffc0200070:	3c0000ef          	jal	ra,ffffffffc0200430 <dtb_init>

    /* 初始化控制台设备
     * 设置串口作为内核的输入输出设备
     * 必须在cprintf等函数使用前完成
     */
    cons_init();
ffffffffc0200074:	7b0000ef          	jal	ra,ffffffffc0200824 <cons_init>

    /* 显示系统启动信息 */
    const char *message = "(THU.CST) os is loading ...\0";
    cputs(message);  // 使用cputs而不是cprintf，因为printf可能还没完全初始化
ffffffffc0200078:	00002517          	auipc	a0,0x2
ffffffffc020007c:	e6050513          	addi	a0,a0,-416 # ffffffffc0201ed8 <etext+0x2>
ffffffffc0200080:	092000ef          	jal	ra,ffffffffc0200112 <cputs>

    /* 打印内核内存布局信息 */
    print_kerninfo();
ffffffffc0200084:	13a000ef          	jal	ra,ffffffffc02001be <print_kerninfo>

    /* 第一次中断初始化 - 设置异常/中断处理向量
     * 必须在其他可能触发异常的操作之前完成
     * 设置stvec和sscratch等CSR
     */
    idt_init();
ffffffffc0200088:	7b6000ef          	jal	ra,ffffffffc020083e <idt_init>

    /* 初始化物理内存管理
     * 设置页表、内存分配器等
     * 这是最复杂的初始化步骤之一
     */
    pmm_init();
ffffffffc020008c:	4b1000ef          	jal	ra,ffffffffc0200d3c <pmm_init>
     * 为什么需要再次调用？可能是因为pmm_init()中的某些操作
     * 覆盖了之前的中断设置，或者需要基于新的内存布局重新设置
     *
     * 这可能是一个需要注意的设计问题，在生产代码中应该避免重复初始化
     */
    idt_init();
ffffffffc0200090:	7ae000ef          	jal	ra,ffffffffc020083e <idt_init>

    /* =================================================================================
     * 第三阶段：设备和中断使能
     * ================================================================================= */

    __asm__ __volatile__("ebreak");
ffffffffc0200094:	9002                	ebreak

    /* 初始化时钟中断系统
     * 设置定时器中断，为系统提供时间基准
     * 这会启动周期性的时钟中断
     */
    clock_init();
ffffffffc0200096:	74a000ef          	jal	ra,ffffffffc02007e0 <clock_init>

    /* 启用硬件中断
     * 到此时，所有中断处理程序都已设置完成
     * 系统现在可以响应中断事件
     */
    intr_enable();
ffffffffc020009a:	798000ef          	jal	ra,ffffffffc0200832 <intr_enable>
    /* 内核初始化完成，进入无限循环
     * 系统现在由中断驱动，不会执行到这里
     * 如果执行到这里，说明系统出现问题
     */

    while (1)
ffffffffc020009e:	a001                	j	ffffffffc020009e <kern_init+0x4a>

ffffffffc02000a0 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000a0:	1141                	addi	sp,sp,-16
ffffffffc02000a2:	e022                	sd	s0,0(sp)
ffffffffc02000a4:	e406                	sd	ra,8(sp)
ffffffffc02000a6:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000a8:	77e000ef          	jal	ra,ffffffffc0200826 <cons_putc>
    (*cnt) ++;
ffffffffc02000ac:	401c                	lw	a5,0(s0)
}
ffffffffc02000ae:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000b0:	2785                	addiw	a5,a5,1
ffffffffc02000b2:	c01c                	sw	a5,0(s0)
}
ffffffffc02000b4:	6402                	ld	s0,0(sp)
ffffffffc02000b6:	0141                	addi	sp,sp,16
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ba:	1101                	addi	sp,sp,-32
ffffffffc02000bc:	862a                	mv	a2,a0
ffffffffc02000be:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fe050513          	addi	a0,a0,-32 # ffffffffc02000a0 <cputch>
ffffffffc02000c8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ca:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000cc:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ce:	169010ef          	jal	ra,ffffffffc0201a36 <vprintfmt>
    return cnt;
}
ffffffffc02000d2:	60e2                	ld	ra,24(sp)
ffffffffc02000d4:	4532                	lw	a0,12(sp)
ffffffffc02000d6:	6105                	addi	sp,sp,32
ffffffffc02000d8:	8082                	ret

ffffffffc02000da <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000da:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000dc:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000e0:	8e2a                	mv	t3,a0
ffffffffc02000e2:	f42e                	sd	a1,40(sp)
ffffffffc02000e4:	f832                	sd	a2,48(sp)
ffffffffc02000e6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e8:	00000517          	auipc	a0,0x0
ffffffffc02000ec:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a0 <cputch>
ffffffffc02000f0:	004c                	addi	a1,sp,4
ffffffffc02000f2:	869a                	mv	a3,t1
ffffffffc02000f4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000f6:	ec06                	sd	ra,24(sp)
ffffffffc02000f8:	e0ba                	sd	a4,64(sp)
ffffffffc02000fa:	e4be                	sd	a5,72(sp)
ffffffffc02000fc:	e8c2                	sd	a6,80(sp)
ffffffffc02000fe:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200100:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200102:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200104:	133010ef          	jal	ra,ffffffffc0201a36 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200108:	60e2                	ld	ra,24(sp)
ffffffffc020010a:	4512                	lw	a0,4(sp)
ffffffffc020010c:	6125                	addi	sp,sp,96
ffffffffc020010e:	8082                	ret

ffffffffc0200110 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200110:	af19                	j	ffffffffc0200826 <cons_putc>

ffffffffc0200112 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200112:	1101                	addi	sp,sp,-32
ffffffffc0200114:	e822                	sd	s0,16(sp)
ffffffffc0200116:	ec06                	sd	ra,24(sp)
ffffffffc0200118:	e426                	sd	s1,8(sp)
ffffffffc020011a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020011c:	00054503          	lbu	a0,0(a0)
ffffffffc0200120:	c51d                	beqz	a0,ffffffffc020014e <cputs+0x3c>
ffffffffc0200122:	0405                	addi	s0,s0,1
ffffffffc0200124:	4485                	li	s1,1
ffffffffc0200126:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200128:	6fe000ef          	jal	ra,ffffffffc0200826 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020012c:	00044503          	lbu	a0,0(s0)
ffffffffc0200130:	008487bb          	addw	a5,s1,s0
ffffffffc0200134:	0405                	addi	s0,s0,1
ffffffffc0200136:	f96d                	bnez	a0,ffffffffc0200128 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200138:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020013c:	4529                	li	a0,10
ffffffffc020013e:	6e8000ef          	jal	ra,ffffffffc0200826 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200142:	60e2                	ld	ra,24(sp)
ffffffffc0200144:	8522                	mv	a0,s0
ffffffffc0200146:	6442                	ld	s0,16(sp)
ffffffffc0200148:	64a2                	ld	s1,8(sp)
ffffffffc020014a:	6105                	addi	sp,sp,32
ffffffffc020014c:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020014e:	4405                	li	s0,1
ffffffffc0200150:	b7f5                	j	ffffffffc020013c <cputs+0x2a>

ffffffffc0200152 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200152:	1141                	addi	sp,sp,-16
ffffffffc0200154:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200156:	6d8000ef          	jal	ra,ffffffffc020082e <cons_getc>
ffffffffc020015a:	dd75                	beqz	a0,ffffffffc0200156 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020015c:	60a2                	ld	ra,8(sp)
ffffffffc020015e:	0141                	addi	sp,sp,16
ffffffffc0200160:	8082                	ret

ffffffffc0200162 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200162:	00006317          	auipc	t1,0x6
ffffffffc0200166:	2de30313          	addi	t1,t1,734 # ffffffffc0206440 <is_panic>
ffffffffc020016a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020016e:	715d                	addi	sp,sp,-80
ffffffffc0200170:	ec06                	sd	ra,24(sp)
ffffffffc0200172:	e822                	sd	s0,16(sp)
ffffffffc0200174:	f436                	sd	a3,40(sp)
ffffffffc0200176:	f83a                	sd	a4,48(sp)
ffffffffc0200178:	fc3e                	sd	a5,56(sp)
ffffffffc020017a:	e0c2                	sd	a6,64(sp)
ffffffffc020017c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020017e:	020e1a63          	bnez	t3,ffffffffc02001b2 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200182:	4785                	li	a5,1
ffffffffc0200184:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200188:	8432                	mv	s0,a2
ffffffffc020018a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020018c:	862e                	mv	a2,a1
ffffffffc020018e:	85aa                	mv	a1,a0
ffffffffc0200190:	00002517          	auipc	a0,0x2
ffffffffc0200194:	d6850513          	addi	a0,a0,-664 # ffffffffc0201ef8 <etext+0x22>
    va_start(ap, fmt);
ffffffffc0200198:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020019a:	f41ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    vcprintf(fmt, ap);
ffffffffc020019e:	65a2                	ld	a1,8(sp)
ffffffffc02001a0:	8522                	mv	a0,s0
ffffffffc02001a2:	f19ff0ef          	jal	ra,ffffffffc02000ba <vcprintf>
    cprintf("\n");
ffffffffc02001a6:	00002517          	auipc	a0,0x2
ffffffffc02001aa:	e3a50513          	addi	a0,a0,-454 # ffffffffc0201fe0 <etext+0x10a>
ffffffffc02001ae:	f2dff0ef          	jal	ra,ffffffffc02000da <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02001b2:	686000ef          	jal	ra,ffffffffc0200838 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02001b6:	4501                	li	a0,0
ffffffffc02001b8:	130000ef          	jal	ra,ffffffffc02002e8 <kmonitor>
    while (1) {
ffffffffc02001bc:	bfed                	j	ffffffffc02001b6 <__panic+0x54>

ffffffffc02001be <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001be:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	d5850513          	addi	a0,a0,-680 # ffffffffc0201f18 <etext+0x42>
void print_kerninfo(void) {
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001ca:	f11ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ce:	00000597          	auipc	a1,0x0
ffffffffc02001d2:	e8658593          	addi	a1,a1,-378 # ffffffffc0200054 <kern_init>
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	d6250513          	addi	a0,a0,-670 # ffffffffc0201f38 <etext+0x62>
ffffffffc02001de:	efdff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001e2:	00002597          	auipc	a1,0x2
ffffffffc02001e6:	cf458593          	addi	a1,a1,-780 # ffffffffc0201ed6 <etext>
ffffffffc02001ea:	00002517          	auipc	a0,0x2
ffffffffc02001ee:	d6e50513          	addi	a0,a0,-658 # ffffffffc0201f58 <etext+0x82>
ffffffffc02001f2:	ee9ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001f6:	00006597          	auipc	a1,0x6
ffffffffc02001fa:	e3258593          	addi	a1,a1,-462 # ffffffffc0206028 <free_area>
ffffffffc02001fe:	00002517          	auipc	a0,0x2
ffffffffc0200202:	d7a50513          	addi	a0,a0,-646 # ffffffffc0201f78 <etext+0xa2>
ffffffffc0200206:	ed5ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020020a:	00006597          	auipc	a1,0x6
ffffffffc020020e:	28e58593          	addi	a1,a1,654 # ffffffffc0206498 <end>
ffffffffc0200212:	00002517          	auipc	a0,0x2
ffffffffc0200216:	d8650513          	addi	a0,a0,-634 # ffffffffc0201f98 <etext+0xc2>
ffffffffc020021a:	ec1ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020021e:	00006597          	auipc	a1,0x6
ffffffffc0200222:	67958593          	addi	a1,a1,1657 # ffffffffc0206897 <end+0x3ff>
ffffffffc0200226:	00000797          	auipc	a5,0x0
ffffffffc020022a:	e2e78793          	addi	a5,a5,-466 # ffffffffc0200054 <kern_init>
ffffffffc020022e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200232:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200236:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200238:	3ff5f593          	andi	a1,a1,1023
ffffffffc020023c:	95be                	add	a1,a1,a5
ffffffffc020023e:	85a9                	srai	a1,a1,0xa
ffffffffc0200240:	00002517          	auipc	a0,0x2
ffffffffc0200244:	d7850513          	addi	a0,a0,-648 # ffffffffc0201fb8 <etext+0xe2>
}
ffffffffc0200248:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	bd41                	j	ffffffffc02000da <cprintf>

ffffffffc020024c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020024c:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020024e:	00002617          	auipc	a2,0x2
ffffffffc0200252:	d9a60613          	addi	a2,a2,-614 # ffffffffc0201fe8 <etext+0x112>
ffffffffc0200256:	04d00593          	li	a1,77
ffffffffc020025a:	00002517          	auipc	a0,0x2
ffffffffc020025e:	da650513          	addi	a0,a0,-602 # ffffffffc0202000 <etext+0x12a>
void print_stackframe(void) {
ffffffffc0200262:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200264:	effff0ef          	jal	ra,ffffffffc0200162 <__panic>

ffffffffc0200268 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020026a:	00002617          	auipc	a2,0x2
ffffffffc020026e:	dae60613          	addi	a2,a2,-594 # ffffffffc0202018 <etext+0x142>
ffffffffc0200272:	00002597          	auipc	a1,0x2
ffffffffc0200276:	dc658593          	addi	a1,a1,-570 # ffffffffc0202038 <etext+0x162>
ffffffffc020027a:	00002517          	auipc	a0,0x2
ffffffffc020027e:	dc650513          	addi	a0,a0,-570 # ffffffffc0202040 <etext+0x16a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	e57ff0ef          	jal	ra,ffffffffc02000da <cprintf>
ffffffffc0200288:	00002617          	auipc	a2,0x2
ffffffffc020028c:	dc860613          	addi	a2,a2,-568 # ffffffffc0202050 <etext+0x17a>
ffffffffc0200290:	00002597          	auipc	a1,0x2
ffffffffc0200294:	de858593          	addi	a1,a1,-536 # ffffffffc0202078 <etext+0x1a2>
ffffffffc0200298:	00002517          	auipc	a0,0x2
ffffffffc020029c:	da850513          	addi	a0,a0,-600 # ffffffffc0202040 <etext+0x16a>
ffffffffc02002a0:	e3bff0ef          	jal	ra,ffffffffc02000da <cprintf>
ffffffffc02002a4:	00002617          	auipc	a2,0x2
ffffffffc02002a8:	de460613          	addi	a2,a2,-540 # ffffffffc0202088 <etext+0x1b2>
ffffffffc02002ac:	00002597          	auipc	a1,0x2
ffffffffc02002b0:	dfc58593          	addi	a1,a1,-516 # ffffffffc02020a8 <etext+0x1d2>
ffffffffc02002b4:	00002517          	auipc	a0,0x2
ffffffffc02002b8:	d8c50513          	addi	a0,a0,-628 # ffffffffc0202040 <etext+0x16a>
ffffffffc02002bc:	e1fff0ef          	jal	ra,ffffffffc02000da <cprintf>
    }
    return 0;
}
ffffffffc02002c0:	60a2                	ld	ra,8(sp)
ffffffffc02002c2:	4501                	li	a0,0
ffffffffc02002c4:	0141                	addi	sp,sp,16
ffffffffc02002c6:	8082                	ret

ffffffffc02002c8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c8:	1141                	addi	sp,sp,-16
ffffffffc02002ca:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002cc:	ef3ff0ef          	jal	ra,ffffffffc02001be <print_kerninfo>
    return 0;
}
ffffffffc02002d0:	60a2                	ld	ra,8(sp)
ffffffffc02002d2:	4501                	li	a0,0
ffffffffc02002d4:	0141                	addi	sp,sp,16
ffffffffc02002d6:	8082                	ret

ffffffffc02002d8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d8:	1141                	addi	sp,sp,-16
ffffffffc02002da:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002dc:	f71ff0ef          	jal	ra,ffffffffc020024c <print_stackframe>
    return 0;
}
ffffffffc02002e0:	60a2                	ld	ra,8(sp)
ffffffffc02002e2:	4501                	li	a0,0
ffffffffc02002e4:	0141                	addi	sp,sp,16
ffffffffc02002e6:	8082                	ret

ffffffffc02002e8 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002e8:	7115                	addi	sp,sp,-224
ffffffffc02002ea:	ed5e                	sd	s7,152(sp)
ffffffffc02002ec:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ee:	00002517          	auipc	a0,0x2
ffffffffc02002f2:	dca50513          	addi	a0,a0,-566 # ffffffffc02020b8 <etext+0x1e2>
kmonitor(struct trapframe *tf) {
ffffffffc02002f6:	ed86                	sd	ra,216(sp)
ffffffffc02002f8:	e9a2                	sd	s0,208(sp)
ffffffffc02002fa:	e5a6                	sd	s1,200(sp)
ffffffffc02002fc:	e1ca                	sd	s2,192(sp)
ffffffffc02002fe:	fd4e                	sd	s3,184(sp)
ffffffffc0200300:	f952                	sd	s4,176(sp)
ffffffffc0200302:	f556                	sd	s5,168(sp)
ffffffffc0200304:	f15a                	sd	s6,160(sp)
ffffffffc0200306:	e962                	sd	s8,144(sp)
ffffffffc0200308:	e566                	sd	s9,136(sp)
ffffffffc020030a:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020030c:	dcfff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200310:	00002517          	auipc	a0,0x2
ffffffffc0200314:	dd050513          	addi	a0,a0,-560 # ffffffffc02020e0 <etext+0x20a>
ffffffffc0200318:	dc3ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    if (tf != NULL) {
ffffffffc020031c:	000b8563          	beqz	s7,ffffffffc0200326 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200320:	855e                	mv	a0,s7
ffffffffc0200322:	6fc000ef          	jal	ra,ffffffffc0200a1e <print_trapframe>
ffffffffc0200326:	00002c17          	auipc	s8,0x2
ffffffffc020032a:	e2ac0c13          	addi	s8,s8,-470 # ffffffffc0202150 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020032e:	00002917          	auipc	s2,0x2
ffffffffc0200332:	dda90913          	addi	s2,s2,-550 # ffffffffc0202108 <etext+0x232>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200336:	00002497          	auipc	s1,0x2
ffffffffc020033a:	dda48493          	addi	s1,s1,-550 # ffffffffc0202110 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc020033e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200340:	00002b17          	auipc	s6,0x2
ffffffffc0200344:	dd8b0b13          	addi	s6,s6,-552 # ffffffffc0202118 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc0200348:	00002a17          	auipc	s4,0x2
ffffffffc020034c:	cf0a0a13          	addi	s4,s4,-784 # ffffffffc0202038 <etext+0x162>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200350:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200352:	854a                	mv	a0,s2
ffffffffc0200354:	265010ef          	jal	ra,ffffffffc0201db8 <readline>
ffffffffc0200358:	842a                	mv	s0,a0
ffffffffc020035a:	dd65                	beqz	a0,ffffffffc0200352 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200360:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200362:	e1bd                	bnez	a1,ffffffffc02003c8 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200364:	fe0c87e3          	beqz	s9,ffffffffc0200352 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200368:	6582                	ld	a1,0(sp)
ffffffffc020036a:	00002d17          	auipc	s10,0x2
ffffffffc020036e:	de6d0d13          	addi	s10,s10,-538 # ffffffffc0202150 <commands>
        argv[argc ++] = buf;
ffffffffc0200372:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200374:	4401                	li	s0,0
ffffffffc0200376:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200378:	5e6010ef          	jal	ra,ffffffffc020195e <strcmp>
ffffffffc020037c:	c919                	beqz	a0,ffffffffc0200392 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020037e:	2405                	addiw	s0,s0,1
ffffffffc0200380:	0b540063          	beq	s0,s5,ffffffffc0200420 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200384:	000d3503          	ld	a0,0(s10)
ffffffffc0200388:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020038a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020038c:	5d2010ef          	jal	ra,ffffffffc020195e <strcmp>
ffffffffc0200390:	f57d                	bnez	a0,ffffffffc020037e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200392:	00141793          	slli	a5,s0,0x1
ffffffffc0200396:	97a2                	add	a5,a5,s0
ffffffffc0200398:	078e                	slli	a5,a5,0x3
ffffffffc020039a:	97e2                	add	a5,a5,s8
ffffffffc020039c:	6b9c                	ld	a5,16(a5)
ffffffffc020039e:	865e                	mv	a2,s7
ffffffffc02003a0:	002c                	addi	a1,sp,8
ffffffffc02003a2:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003a6:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003a8:	fa0555e3          	bgez	a0,ffffffffc0200352 <kmonitor+0x6a>
}
ffffffffc02003ac:	60ee                	ld	ra,216(sp)
ffffffffc02003ae:	644e                	ld	s0,208(sp)
ffffffffc02003b0:	64ae                	ld	s1,200(sp)
ffffffffc02003b2:	690e                	ld	s2,192(sp)
ffffffffc02003b4:	79ea                	ld	s3,184(sp)
ffffffffc02003b6:	7a4a                	ld	s4,176(sp)
ffffffffc02003b8:	7aaa                	ld	s5,168(sp)
ffffffffc02003ba:	7b0a                	ld	s6,160(sp)
ffffffffc02003bc:	6bea                	ld	s7,152(sp)
ffffffffc02003be:	6c4a                	ld	s8,144(sp)
ffffffffc02003c0:	6caa                	ld	s9,136(sp)
ffffffffc02003c2:	6d0a                	ld	s10,128(sp)
ffffffffc02003c4:	612d                	addi	sp,sp,224
ffffffffc02003c6:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003c8:	8526                	mv	a0,s1
ffffffffc02003ca:	5d8010ef          	jal	ra,ffffffffc02019a2 <strchr>
ffffffffc02003ce:	c901                	beqz	a0,ffffffffc02003de <kmonitor+0xf6>
ffffffffc02003d0:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003d4:	00040023          	sb	zero,0(s0)
ffffffffc02003d8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003da:	d5c9                	beqz	a1,ffffffffc0200364 <kmonitor+0x7c>
ffffffffc02003dc:	b7f5                	j	ffffffffc02003c8 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02003de:	00044783          	lbu	a5,0(s0)
ffffffffc02003e2:	d3c9                	beqz	a5,ffffffffc0200364 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02003e4:	033c8963          	beq	s9,s3,ffffffffc0200416 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02003e8:	003c9793          	slli	a5,s9,0x3
ffffffffc02003ec:	0118                	addi	a4,sp,128
ffffffffc02003ee:	97ba                	add	a5,a5,a4
ffffffffc02003f0:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003f4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003f8:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003fa:	e591                	bnez	a1,ffffffffc0200406 <kmonitor+0x11e>
ffffffffc02003fc:	b7b5                	j	ffffffffc0200368 <kmonitor+0x80>
ffffffffc02003fe:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200402:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200404:	d1a5                	beqz	a1,ffffffffc0200364 <kmonitor+0x7c>
ffffffffc0200406:	8526                	mv	a0,s1
ffffffffc0200408:	59a010ef          	jal	ra,ffffffffc02019a2 <strchr>
ffffffffc020040c:	d96d                	beqz	a0,ffffffffc02003fe <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020040e:	00044583          	lbu	a1,0(s0)
ffffffffc0200412:	d9a9                	beqz	a1,ffffffffc0200364 <kmonitor+0x7c>
ffffffffc0200414:	bf55                	j	ffffffffc02003c8 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200416:	45c1                	li	a1,16
ffffffffc0200418:	855a                	mv	a0,s6
ffffffffc020041a:	cc1ff0ef          	jal	ra,ffffffffc02000da <cprintf>
ffffffffc020041e:	b7e9                	j	ffffffffc02003e8 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200420:	6582                	ld	a1,0(sp)
ffffffffc0200422:	00002517          	auipc	a0,0x2
ffffffffc0200426:	d1650513          	addi	a0,a0,-746 # ffffffffc0202138 <etext+0x262>
ffffffffc020042a:	cb1ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    return 0;
ffffffffc020042e:	b715                	j	ffffffffc0200352 <kmonitor+0x6a>

ffffffffc0200430 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200430:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	d6650513          	addi	a0,a0,-666 # ffffffffc0202198 <commands+0x48>
void dtb_init(void) {
ffffffffc020043a:	fc86                	sd	ra,120(sp)
ffffffffc020043c:	f8a2                	sd	s0,112(sp)
ffffffffc020043e:	e8d2                	sd	s4,80(sp)
ffffffffc0200440:	f4a6                	sd	s1,104(sp)
ffffffffc0200442:	f0ca                	sd	s2,96(sp)
ffffffffc0200444:	ecce                	sd	s3,88(sp)
ffffffffc0200446:	e4d6                	sd	s5,72(sp)
ffffffffc0200448:	e0da                	sd	s6,64(sp)
ffffffffc020044a:	fc5e                	sd	s7,56(sp)
ffffffffc020044c:	f862                	sd	s8,48(sp)
ffffffffc020044e:	f466                	sd	s9,40(sp)
ffffffffc0200450:	f06a                	sd	s10,32(sp)
ffffffffc0200452:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200454:	c87ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200458:	00006597          	auipc	a1,0x6
ffffffffc020045c:	ba85b583          	ld	a1,-1112(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200460:	00002517          	auipc	a0,0x2
ffffffffc0200464:	d4850513          	addi	a0,a0,-696 # ffffffffc02021a8 <commands+0x58>
ffffffffc0200468:	c73ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020046c:	00006417          	auipc	s0,0x6
ffffffffc0200470:	b9c40413          	addi	s0,s0,-1124 # ffffffffc0206008 <boot_dtb>
ffffffffc0200474:	600c                	ld	a1,0(s0)
ffffffffc0200476:	00002517          	auipc	a0,0x2
ffffffffc020047a:	d4250513          	addi	a0,a0,-702 # ffffffffc02021b8 <commands+0x68>
ffffffffc020047e:	c5dff0ef          	jal	ra,ffffffffc02000da <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200482:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200486:	00002517          	auipc	a0,0x2
ffffffffc020048a:	d4a50513          	addi	a0,a0,-694 # ffffffffc02021d0 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc020048e:	120a0463          	beqz	s4,ffffffffc02005b6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200492:	57f5                	li	a5,-3
ffffffffc0200494:	07fa                	slli	a5,a5,0x1e
ffffffffc0200496:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020049a:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020049c:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a0:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a2:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004a6:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004aa:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ae:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b8:	8ec9                	or	a3,a3,a0
ffffffffc02004ba:	0087979b          	slliw	a5,a5,0x8
ffffffffc02004be:	1b7d                	addi	s6,s6,-1
ffffffffc02004c0:	0167f7b3          	and	a5,a5,s6
ffffffffc02004c4:	8dd5                	or	a1,a1,a3
ffffffffc02004c6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02004c8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004cc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02004ce:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed9a55>
ffffffffc02004d2:	10f59163          	bne	a1,a5,ffffffffc02005d4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02004d6:	471c                	lw	a5,8(a4)
ffffffffc02004d8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02004da:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004dc:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004e0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02004e4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ec:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f0:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f4:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f8:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004fc:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200500:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200504:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200506:	01146433          	or	s0,s0,a7
ffffffffc020050a:	0086969b          	slliw	a3,a3,0x8
ffffffffc020050e:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200512:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200514:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200518:	8c49                	or	s0,s0,a0
ffffffffc020051a:	0166f6b3          	and	a3,a3,s6
ffffffffc020051e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200522:	0167f7b3          	and	a5,a5,s6
ffffffffc0200526:	8c55                	or	s0,s0,a3
ffffffffc0200528:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020052c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020052e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200530:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200532:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200536:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200538:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020053e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200540:	00002917          	auipc	s2,0x2
ffffffffc0200544:	ce090913          	addi	s2,s2,-800 # ffffffffc0202220 <commands+0xd0>
ffffffffc0200548:	49bd                	li	s3,15
        switch (token) {
ffffffffc020054a:	4d91                	li	s11,4
ffffffffc020054c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020054e:	00002497          	auipc	s1,0x2
ffffffffc0200552:	cca48493          	addi	s1,s1,-822 # ffffffffc0202218 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200556:	000a2703          	lw	a4,0(s4)
ffffffffc020055a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020055e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200562:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200566:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020056a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020056e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200572:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200574:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200578:	0087171b          	slliw	a4,a4,0x8
ffffffffc020057c:	8fd5                	or	a5,a5,a3
ffffffffc020057e:	00eb7733          	and	a4,s6,a4
ffffffffc0200582:	8fd9                	or	a5,a5,a4
ffffffffc0200584:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200586:	09778c63          	beq	a5,s7,ffffffffc020061e <dtb_init+0x1ee>
ffffffffc020058a:	00fbea63          	bltu	s7,a5,ffffffffc020059e <dtb_init+0x16e>
ffffffffc020058e:	07a78663          	beq	a5,s10,ffffffffc02005fa <dtb_init+0x1ca>
ffffffffc0200592:	4709                	li	a4,2
ffffffffc0200594:	00e79763          	bne	a5,a4,ffffffffc02005a2 <dtb_init+0x172>
ffffffffc0200598:	4c81                	li	s9,0
ffffffffc020059a:	8a56                	mv	s4,s5
ffffffffc020059c:	bf6d                	j	ffffffffc0200556 <dtb_init+0x126>
ffffffffc020059e:	ffb78ee3          	beq	a5,s11,ffffffffc020059a <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02005a2:	00002517          	auipc	a0,0x2
ffffffffc02005a6:	cf650513          	addi	a0,a0,-778 # ffffffffc0202298 <commands+0x148>
ffffffffc02005aa:	b31ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02005ae:	00002517          	auipc	a0,0x2
ffffffffc02005b2:	d2250513          	addi	a0,a0,-734 # ffffffffc02022d0 <commands+0x180>
}
ffffffffc02005b6:	7446                	ld	s0,112(sp)
ffffffffc02005b8:	70e6                	ld	ra,120(sp)
ffffffffc02005ba:	74a6                	ld	s1,104(sp)
ffffffffc02005bc:	7906                	ld	s2,96(sp)
ffffffffc02005be:	69e6                	ld	s3,88(sp)
ffffffffc02005c0:	6a46                	ld	s4,80(sp)
ffffffffc02005c2:	6aa6                	ld	s5,72(sp)
ffffffffc02005c4:	6b06                	ld	s6,64(sp)
ffffffffc02005c6:	7be2                	ld	s7,56(sp)
ffffffffc02005c8:	7c42                	ld	s8,48(sp)
ffffffffc02005ca:	7ca2                	ld	s9,40(sp)
ffffffffc02005cc:	7d02                	ld	s10,32(sp)
ffffffffc02005ce:	6de2                	ld	s11,24(sp)
ffffffffc02005d0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02005d2:	b621                	j	ffffffffc02000da <cprintf>
}
ffffffffc02005d4:	7446                	ld	s0,112(sp)
ffffffffc02005d6:	70e6                	ld	ra,120(sp)
ffffffffc02005d8:	74a6                	ld	s1,104(sp)
ffffffffc02005da:	7906                	ld	s2,96(sp)
ffffffffc02005dc:	69e6                	ld	s3,88(sp)
ffffffffc02005de:	6a46                	ld	s4,80(sp)
ffffffffc02005e0:	6aa6                	ld	s5,72(sp)
ffffffffc02005e2:	6b06                	ld	s6,64(sp)
ffffffffc02005e4:	7be2                	ld	s7,56(sp)
ffffffffc02005e6:	7c42                	ld	s8,48(sp)
ffffffffc02005e8:	7ca2                	ld	s9,40(sp)
ffffffffc02005ea:	7d02                	ld	s10,32(sp)
ffffffffc02005ec:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005ee:	00002517          	auipc	a0,0x2
ffffffffc02005f2:	c0250513          	addi	a0,a0,-1022 # ffffffffc02021f0 <commands+0xa0>
}
ffffffffc02005f6:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005f8:	b4cd                	j	ffffffffc02000da <cprintf>
                int name_len = strlen(name);
ffffffffc02005fa:	8556                	mv	a0,s5
ffffffffc02005fc:	32c010ef          	jal	ra,ffffffffc0201928 <strlen>
ffffffffc0200600:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200602:	4619                	li	a2,6
ffffffffc0200604:	85a6                	mv	a1,s1
ffffffffc0200606:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200608:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020060a:	372010ef          	jal	ra,ffffffffc020197c <strncmp>
ffffffffc020060e:	e111                	bnez	a0,ffffffffc0200612 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200610:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200612:	0a91                	addi	s5,s5,4
ffffffffc0200614:	9ad2                	add	s5,s5,s4
ffffffffc0200616:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020061a:	8a56                	mv	s4,s5
ffffffffc020061c:	bf2d                	j	ffffffffc0200556 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020061e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200622:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200626:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020062a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020062e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200632:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200636:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020063a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020063e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200642:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200646:	00eaeab3          	or	s5,s5,a4
ffffffffc020064a:	00fb77b3          	and	a5,s6,a5
ffffffffc020064e:	00faeab3          	or	s5,s5,a5
ffffffffc0200652:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200654:	000c9c63          	bnez	s9,ffffffffc020066c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200658:	1a82                	slli	s5,s5,0x20
ffffffffc020065a:	00368793          	addi	a5,a3,3
ffffffffc020065e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200662:	9abe                	add	s5,s5,a5
ffffffffc0200664:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200668:	8a56                	mv	s4,s5
ffffffffc020066a:	b5f5                	j	ffffffffc0200556 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020066c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200670:	85ca                	mv	a1,s2
ffffffffc0200672:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200674:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200678:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200680:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200684:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200688:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020068e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200692:	8d59                	or	a0,a0,a4
ffffffffc0200694:	00fb77b3          	and	a5,s6,a5
ffffffffc0200698:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020069a:	1502                	slli	a0,a0,0x20
ffffffffc020069c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020069e:	9522                	add	a0,a0,s0
ffffffffc02006a0:	2be010ef          	jal	ra,ffffffffc020195e <strcmp>
ffffffffc02006a4:	66a2                	ld	a3,8(sp)
ffffffffc02006a6:	f94d                	bnez	a0,ffffffffc0200658 <dtb_init+0x228>
ffffffffc02006a8:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200658 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02006ac:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02006b0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02006b4:	00002517          	auipc	a0,0x2
ffffffffc02006b8:	b7450513          	addi	a0,a0,-1164 # ffffffffc0202228 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc02006bc:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02006c4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02006cc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d8:	0187d693          	srli	a3,a5,0x18
ffffffffc02006dc:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02006e0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02006e4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02006ec:	010f6f33          	or	t5,t5,a6
ffffffffc02006f0:	0187529b          	srliw	t0,a4,0x18
ffffffffc02006f4:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006f8:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006fc:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200700:	0186f6b3          	and	a3,a3,s8
ffffffffc0200704:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200708:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020070c:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200710:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200714:	8361                	srli	a4,a4,0x18
ffffffffc0200716:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020071e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200722:	00cb7633          	and	a2,s6,a2
ffffffffc0200726:	0088181b          	slliw	a6,a6,0x8
ffffffffc020072a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020072e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200732:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200736:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200742:	011b78b3          	and	a7,s6,a7
ffffffffc0200746:	005eeeb3          	or	t4,t4,t0
ffffffffc020074a:	00c6e733          	or	a4,a3,a2
ffffffffc020074e:	006c6c33          	or	s8,s8,t1
ffffffffc0200752:	010b76b3          	and	a3,s6,a6
ffffffffc0200756:	00bb7b33          	and	s6,s6,a1
ffffffffc020075a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020075e:	016c6b33          	or	s6,s8,s6
ffffffffc0200762:	01146433          	or	s0,s0,a7
ffffffffc0200766:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200768:	1702                	slli	a4,a4,0x20
ffffffffc020076a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020076c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020076e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200770:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200772:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200776:	0167eb33          	or	s6,a5,s6
ffffffffc020077a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020077c:	95fff0ef          	jal	ra,ffffffffc02000da <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200780:	85a2                	mv	a1,s0
ffffffffc0200782:	00002517          	auipc	a0,0x2
ffffffffc0200786:	ac650513          	addi	a0,a0,-1338 # ffffffffc0202248 <commands+0xf8>
ffffffffc020078a:	951ff0ef          	jal	ra,ffffffffc02000da <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020078e:	014b5613          	srli	a2,s6,0x14
ffffffffc0200792:	85da                	mv	a1,s6
ffffffffc0200794:	00002517          	auipc	a0,0x2
ffffffffc0200798:	acc50513          	addi	a0,a0,-1332 # ffffffffc0202260 <commands+0x110>
ffffffffc020079c:	93fff0ef          	jal	ra,ffffffffc02000da <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02007a0:	008b05b3          	add	a1,s6,s0
ffffffffc02007a4:	15fd                	addi	a1,a1,-1
ffffffffc02007a6:	00002517          	auipc	a0,0x2
ffffffffc02007aa:	ada50513          	addi	a0,a0,-1318 # ffffffffc0202280 <commands+0x130>
ffffffffc02007ae:	92dff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02007b2:	00002517          	auipc	a0,0x2
ffffffffc02007b6:	b1e50513          	addi	a0,a0,-1250 # ffffffffc02022d0 <commands+0x180>
        memory_base = mem_base;
ffffffffc02007ba:	00006797          	auipc	a5,0x6
ffffffffc02007be:	c887b723          	sd	s0,-882(a5) # ffffffffc0206448 <memory_base>
        memory_size = mem_size;
ffffffffc02007c2:	00006797          	auipc	a5,0x6
ffffffffc02007c6:	c967b723          	sd	s6,-882(a5) # ffffffffc0206450 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02007ca:	b3f5                	j	ffffffffc02005b6 <dtb_init+0x186>

ffffffffc02007cc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02007cc:	00006517          	auipc	a0,0x6
ffffffffc02007d0:	c7c53503          	ld	a0,-900(a0) # ffffffffc0206448 <memory_base>
ffffffffc02007d4:	8082                	ret

ffffffffc02007d6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02007d6:	00006517          	auipc	a0,0x6
ffffffffc02007da:	c7a53503          	ld	a0,-902(a0) # ffffffffc0206450 <memory_size>
ffffffffc02007de:	8082                	ret

ffffffffc02007e0 <clock_init>:
 * 2. 设置第一次时钟中断
 * 3. 初始化时钟计数器
 *
 * 注意：RISC-V中没有传统的8253定时器芯片，这里通过SBI调用来设置
 * ====================================================================================== */
void clock_init(void) {
ffffffffc02007e0:	1141                	addi	sp,sp,-16
ffffffffc02007e2:	e406                	sd	ra,8(sp)
    /* 启用监管者态时钟中断
     * sie (Supervisor Interrupt Enable) 寄存器控制哪些中断被允许
     * MIP_STIP是时钟中断pending位，通过设置sie允许时钟中断
     */
    set_csr(sie, MIP_STIP);
ffffffffc02007e4:	02000793          	li	a5,32
ffffffffc02007e8:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02007ec:	c0102573          	rdtime	a0
 * ====================================================================================== */
void clock_set_next_event(void) {
    /* 计算下次中断的时间点
     * 当前时间 + 时间间隔 = 下次中断时间
     */
    sbi_set_timer(get_cycles() + timebase);
ffffffffc02007f0:	67e1                	lui	a5,0x18
ffffffffc02007f2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02007f6:	953e                	add	a0,a0,a5
ffffffffc02007f8:	68e010ef          	jal	ra,ffffffffc0201e86 <sbi_set_timer>
}
ffffffffc02007fc:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc02007fe:	00006797          	auipc	a5,0x6
ffffffffc0200802:	c407bd23          	sd	zero,-934(a5) # ffffffffc0206458 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200806:	00002517          	auipc	a0,0x2
ffffffffc020080a:	ae250513          	addi	a0,a0,-1310 # ffffffffc02022e8 <commands+0x198>
}
ffffffffc020080e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200810:	8cbff06f          	j	ffffffffc02000da <cprintf>

ffffffffc0200814 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200814:	c0102573          	rdtime	a0
    sbi_set_timer(get_cycles() + timebase);
ffffffffc0200818:	67e1                	lui	a5,0x18
ffffffffc020081a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020081e:	953e                	add	a0,a0,a5
ffffffffc0200820:	6660106f          	j	ffffffffc0201e86 <sbi_set_timer>

ffffffffc0200824 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200824:	8082                	ret

ffffffffc0200826 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200826:	0ff57513          	zext.b	a0,a0
ffffffffc020082a:	6420106f          	j	ffffffffc0201e6c <sbi_console_putchar>

ffffffffc020082e <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020082e:	6720106f          	j	ffffffffc0201ea0 <sbi_console_getchar>

ffffffffc0200832 <intr_enable>:
 *
 * 注意：这个函数只影响监管者态的中断，用户态中断由其他机制控制
 * ====================================================================================== */
void intr_enable(void) {
    /* 设置sstatus的SIE位为1，启用中断 */
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200832:	100167f3          	csrrsi	a5,sstatus,2
}
ffffffffc0200836:	8082                	ret

ffffffffc0200838 <intr_disable>:
 *
 * 注意：这个函数只影响监管者态的中断，用户态中断仍然可以发生
 * ====================================================================================== */
void intr_disable(void) {
    /* 清除sstatus的SIE位为0，禁用中断 */
    clear_csr(sstatus, SSTATUS_SIE);
ffffffffc0200838:	100177f3          	csrrci	a5,sstatus,2
}
ffffffffc020083c:	8082                	ret

ffffffffc020083e <idt_init>:
     * sscratch (Supervisor Scratch Register)的作用：
     * - 在用户态：保存内核栈指针（用于异常时切换到内核栈）
     * - 在内核态：设置为0，表示当前已经在内核模式
     * 这里设置为0告诉异常向量程序当前正在内核态执行
     */
    write_csr(sscratch, 0);
ffffffffc020083e:	14005073          	csrwi	sscratch,0
     * stvec (Supervisor Trap Vector)寄存器：
     * - 低位：异常处理函数的地址
     * - 高位：向量模式设置（这里使用直接模式）
     * 当异常发生时，硬件会跳转到stvec指向的地址开始执行
     */
    write_csr(stvec, &__alltraps);
ffffffffc0200842:	00000797          	auipc	a5,0x0
ffffffffc0200846:	38e78793          	addi	a5,a5,910 # ffffffffc0200bd0 <__alltraps>
ffffffffc020084a:	10579073          	csrw	stvec,a5
}
ffffffffc020084e:	8082                	ret

ffffffffc0200850 <print_regs>:
 * - s0-s11(x8-x9,x18-x27): 保存寄存器
 * - a0-a7(x10-x17): 函数参数/返回值
 * ====================================================================================== */
void print_regs(struct pushregs *gpr) {
    // x0 (zero) - 硬连线为0，不可修改
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200850:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200852:	1141                	addi	sp,sp,-16
ffffffffc0200854:	e022                	sd	s0,0(sp)
ffffffffc0200856:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200858:	00002517          	auipc	a0,0x2
ffffffffc020085c:	ab050513          	addi	a0,a0,-1360 # ffffffffc0202308 <commands+0x1b8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200860:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200862:	879ff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // x1 (ra) - 返回地址，保存函数返回位置
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200866:	640c                	ld	a1,8(s0)
ffffffffc0200868:	00002517          	auipc	a0,0x2
ffffffffc020086c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0202320 <commands+0x1d0>
ffffffffc0200870:	86bff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // x2 (sp) - 栈指针，指向当前栈顶
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200874:	680c                	ld	a1,16(s0)
ffffffffc0200876:	00002517          	auipc	a0,0x2
ffffffffc020087a:	ac250513          	addi	a0,a0,-1342 # ffffffffc0202338 <commands+0x1e8>
ffffffffc020087e:	85dff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // x3 (gp) - 全局指针，用于访问全局变量
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200882:	6c0c                	ld	a1,24(s0)
ffffffffc0200884:	00002517          	auipc	a0,0x2
ffffffffc0200888:	acc50513          	addi	a0,a0,-1332 # ffffffffc0202350 <commands+0x200>
ffffffffc020088c:	84fff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // x4 (tp) - 线程指针，用于线程本地存储
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200890:	700c                	ld	a1,32(s0)
ffffffffc0200892:	00002517          	auipc	a0,0x2
ffffffffc0200896:	ad650513          	addi	a0,a0,-1322 # ffffffffc0202368 <commands+0x218>
ffffffffc020089a:	841ff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // 临时寄存器 t0-t2 (x5-x7) - 不需要跨函数调用保存
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020089e:	740c                	ld	a1,40(s0)
ffffffffc02008a0:	00002517          	auipc	a0,0x2
ffffffffc02008a4:	ae050513          	addi	a0,a0,-1312 # ffffffffc0202380 <commands+0x230>
ffffffffc02008a8:	833ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008ac:	780c                	ld	a1,48(s0)
ffffffffc02008ae:	00002517          	auipc	a0,0x2
ffffffffc02008b2:	aea50513          	addi	a0,a0,-1302 # ffffffffc0202398 <commands+0x248>
ffffffffc02008b6:	825ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02008ba:	7c0c                	ld	a1,56(s0)
ffffffffc02008bc:	00002517          	auipc	a0,0x2
ffffffffc02008c0:	af450513          	addi	a0,a0,-1292 # ffffffffc02023b0 <commands+0x260>
ffffffffc02008c4:	817ff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // 保存寄存器 s0-s1 (x8-x9) - 需要保存/恢复的寄存器
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02008c8:	602c                	ld	a1,64(s0)
ffffffffc02008ca:	00002517          	auipc	a0,0x2
ffffffffc02008ce:	afe50513          	addi	a0,a0,-1282 # ffffffffc02023c8 <commands+0x278>
ffffffffc02008d2:	809ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02008d6:	642c                	ld	a1,72(s0)
ffffffffc02008d8:	00002517          	auipc	a0,0x2
ffffffffc02008dc:	b0850513          	addi	a0,a0,-1272 # ffffffffc02023e0 <commands+0x290>
ffffffffc02008e0:	ffaff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // 参数/返回值寄存器 a0-a7 (x10-x17)
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02008e4:	682c                	ld	a1,80(s0)
ffffffffc02008e6:	00002517          	auipc	a0,0x2
ffffffffc02008ea:	b1250513          	addi	a0,a0,-1262 # ffffffffc02023f8 <commands+0x2a8>
ffffffffc02008ee:	fecff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02008f2:	6c2c                	ld	a1,88(s0)
ffffffffc02008f4:	00002517          	auipc	a0,0x2
ffffffffc02008f8:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0202410 <commands+0x2c0>
ffffffffc02008fc:	fdeff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200900:	702c                	ld	a1,96(s0)
ffffffffc0200902:	00002517          	auipc	a0,0x2
ffffffffc0200906:	b2650513          	addi	a0,a0,-1242 # ffffffffc0202428 <commands+0x2d8>
ffffffffc020090a:	fd0ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020090e:	742c                	ld	a1,104(s0)
ffffffffc0200910:	00002517          	auipc	a0,0x2
ffffffffc0200914:	b3050513          	addi	a0,a0,-1232 # ffffffffc0202440 <commands+0x2f0>
ffffffffc0200918:	fc2ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020091c:	782c                	ld	a1,112(s0)
ffffffffc020091e:	00002517          	auipc	a0,0x2
ffffffffc0200922:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0202458 <commands+0x308>
ffffffffc0200926:	fb4ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020092a:	7c2c                	ld	a1,120(s0)
ffffffffc020092c:	00002517          	auipc	a0,0x2
ffffffffc0200930:	b4450513          	addi	a0,a0,-1212 # ffffffffc0202470 <commands+0x320>
ffffffffc0200934:	fa6ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200938:	604c                	ld	a1,128(s0)
ffffffffc020093a:	00002517          	auipc	a0,0x2
ffffffffc020093e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0202488 <commands+0x338>
ffffffffc0200942:	f98ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200946:	644c                	ld	a1,136(s0)
ffffffffc0200948:	00002517          	auipc	a0,0x2
ffffffffc020094c:	b5850513          	addi	a0,a0,-1192 # ffffffffc02024a0 <commands+0x350>
ffffffffc0200950:	f8aff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // 保存寄存器 s2-s11 (x18-x27)
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200954:	684c                	ld	a1,144(s0)
ffffffffc0200956:	00002517          	auipc	a0,0x2
ffffffffc020095a:	b6250513          	addi	a0,a0,-1182 # ffffffffc02024b8 <commands+0x368>
ffffffffc020095e:	f7cff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200962:	6c4c                	ld	a1,152(s0)
ffffffffc0200964:	00002517          	auipc	a0,0x2
ffffffffc0200968:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02024d0 <commands+0x380>
ffffffffc020096c:	f6eff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200970:	704c                	ld	a1,160(s0)
ffffffffc0200972:	00002517          	auipc	a0,0x2
ffffffffc0200976:	b7650513          	addi	a0,a0,-1162 # ffffffffc02024e8 <commands+0x398>
ffffffffc020097a:	f60ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020097e:	744c                	ld	a1,168(s0)
ffffffffc0200980:	00002517          	auipc	a0,0x2
ffffffffc0200984:	b8050513          	addi	a0,a0,-1152 # ffffffffc0202500 <commands+0x3b0>
ffffffffc0200988:	f52ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020098c:	784c                	ld	a1,176(s0)
ffffffffc020098e:	00002517          	auipc	a0,0x2
ffffffffc0200992:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0202518 <commands+0x3c8>
ffffffffc0200996:	f44ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020099a:	7c4c                	ld	a1,184(s0)
ffffffffc020099c:	00002517          	auipc	a0,0x2
ffffffffc02009a0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0202530 <commands+0x3e0>
ffffffffc02009a4:	f36ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009a8:	606c                	ld	a1,192(s0)
ffffffffc02009aa:	00002517          	auipc	a0,0x2
ffffffffc02009ae:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0202548 <commands+0x3f8>
ffffffffc02009b2:	f28ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02009b6:	646c                	ld	a1,200(s0)
ffffffffc02009b8:	00002517          	auipc	a0,0x2
ffffffffc02009bc:	ba850513          	addi	a0,a0,-1112 # ffffffffc0202560 <commands+0x410>
ffffffffc02009c0:	f1aff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02009c4:	686c                	ld	a1,208(s0)
ffffffffc02009c6:	00002517          	auipc	a0,0x2
ffffffffc02009ca:	bb250513          	addi	a0,a0,-1102 # ffffffffc0202578 <commands+0x428>
ffffffffc02009ce:	f0cff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02009d2:	6c6c                	ld	a1,216(s0)
ffffffffc02009d4:	00002517          	auipc	a0,0x2
ffffffffc02009d8:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0202590 <commands+0x440>
ffffffffc02009dc:	efeff0ef          	jal	ra,ffffffffc02000da <cprintf>

    // 临时寄存器 t3-t6 (x28-x31)
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02009e0:	706c                	ld	a1,224(s0)
ffffffffc02009e2:	00002517          	auipc	a0,0x2
ffffffffc02009e6:	bc650513          	addi	a0,a0,-1082 # ffffffffc02025a8 <commands+0x458>
ffffffffc02009ea:	ef0ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02009ee:	746c                	ld	a1,232(s0)
ffffffffc02009f0:	00002517          	auipc	a0,0x2
ffffffffc02009f4:	bd050513          	addi	a0,a0,-1072 # ffffffffc02025c0 <commands+0x470>
ffffffffc02009f8:	ee2ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02009fc:	786c                	ld	a1,240(s0)
ffffffffc02009fe:	00002517          	auipc	a0,0x2
ffffffffc0200a02:	bda50513          	addi	a0,a0,-1062 # ffffffffc02025d8 <commands+0x488>
ffffffffc0200a06:	ed4ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a0a:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a0c:	6402                	ld	s0,0(sp)
ffffffffc0200a0e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a10:	00002517          	auipc	a0,0x2
ffffffffc0200a14:	be050513          	addi	a0,a0,-1056 # ffffffffc02025f0 <commands+0x4a0>
}
ffffffffc0200a18:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a1a:	ec0ff06f          	j	ffffffffc02000da <cprintf>

ffffffffc0200a1e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a1e:	1141                	addi	sp,sp,-16
ffffffffc0200a20:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a22:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a24:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a26:	00002517          	auipc	a0,0x2
ffffffffc0200a2a:	be250513          	addi	a0,a0,-1054 # ffffffffc0202608 <commands+0x4b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200a2e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a30:	eaaff0ef          	jal	ra,ffffffffc02000da <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a34:	8522                	mv	a0,s0
ffffffffc0200a36:	e1bff0ef          	jal	ra,ffffffffc0200850 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);    // sstatus: 状态寄存器
ffffffffc0200a3a:	10043583          	ld	a1,256(s0)
ffffffffc0200a3e:	00002517          	auipc	a0,0x2
ffffffffc0200a42:	be250513          	addi	a0,a0,-1054 # ffffffffc0202620 <commands+0x4d0>
ffffffffc0200a46:	e94ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);       // sepc: 异常程序计数器
ffffffffc0200a4a:	10843583          	ld	a1,264(s0)
ffffffffc0200a4e:	00002517          	auipc	a0,0x2
ffffffffc0200a52:	bea50513          	addi	a0,a0,-1046 # ffffffffc0202638 <commands+0x4e8>
ffffffffc0200a56:	e84ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);  // sbadaddr: 坏地址（用于地址异常）
ffffffffc0200a5a:	11043583          	ld	a1,272(s0)
ffffffffc0200a5e:	00002517          	auipc	a0,0x2
ffffffffc0200a62:	bf250513          	addi	a0,a0,-1038 # ffffffffc0202650 <commands+0x500>
ffffffffc0200a66:	e74ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);     // scause: 异常原因
ffffffffc0200a6a:	11843583          	ld	a1,280(s0)
}
ffffffffc0200a6e:	6402                	ld	s0,0(sp)
ffffffffc0200a70:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);     // scause: 异常原因
ffffffffc0200a72:	00002517          	auipc	a0,0x2
ffffffffc0200a76:	bf650513          	addi	a0,a0,-1034 # ffffffffc0202668 <commands+0x518>
}
ffffffffc0200a7a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);     // scause: 异常原因
ffffffffc0200a7c:	e5eff06f          	j	ffffffffc02000da <cprintf>

ffffffffc0200a80 <interrupt_handler>:
     * - 低位(bits 62:0): 具体的中断或异常编号
     *
     * 这里通过左移1位再右移1位来清除最高位，获取具体的中断编号
     * 这是一个常见的技巧来提取低位字段
     */
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200a80:	11853783          	ld	a5,280(a0)
ffffffffc0200a84:	472d                	li	a4,11
ffffffffc0200a86:	0786                	slli	a5,a5,0x1
ffffffffc0200a88:	8385                	srli	a5,a5,0x1
ffffffffc0200a8a:	08f76a63          	bltu	a4,a5,ffffffffc0200b1e <interrupt_handler+0x9e>
ffffffffc0200a8e:	00002717          	auipc	a4,0x2
ffffffffc0200a92:	cba70713          	addi	a4,a4,-838 # ffffffffc0202748 <commands+0x5f8>
ffffffffc0200a96:	078a                	slli	a5,a5,0x2
ffffffffc0200a98:	97ba                	add	a5,a5,a4
ffffffffc0200a9a:	439c                	lw	a5,0(a5)
ffffffffc0200a9c:	97ba                	add	a5,a5,a4
ffffffffc0200a9e:	8782                	jr	a5

        case IRQ_M_SOFT:
            /* 机器态软件中断
             * 由机器态软件触发，最高特权级别的软件中断
             */
            cprintf("Machine software interrupt\n");
ffffffffc0200aa0:	00002517          	auipc	a0,0x2
ffffffffc0200aa4:	c4050513          	addi	a0,a0,-960 # ffffffffc02026e0 <commands+0x590>
ffffffffc0200aa8:	e32ff06f          	j	ffffffffc02000da <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200aac:	00002517          	auipc	a0,0x2
ffffffffc0200ab0:	c1450513          	addi	a0,a0,-1004 # ffffffffc02026c0 <commands+0x570>
ffffffffc0200ab4:	e26ff06f          	j	ffffffffc02000da <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200ab8:	00002517          	auipc	a0,0x2
ffffffffc0200abc:	bc850513          	addi	a0,a0,-1080 # ffffffffc0202680 <commands+0x530>
ffffffffc0200ac0:	e1aff06f          	j	ffffffffc02000da <cprintf>

        case IRQ_U_TIMER:
            /* 用户态时钟中断
             * 用户程序设置的用户态定时器到期
             */
            cprintf("User Timer interrupt\n");
ffffffffc0200ac4:	00002517          	auipc	a0,0x2
ffffffffc0200ac8:	c3c50513          	addi	a0,a0,-964 # ffffffffc0202700 <commands+0x5b0>
ffffffffc0200acc:	e0eff06f          	j	ffffffffc02000da <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200ad0:	1141                	addi	sp,sp,-16
ffffffffc0200ad2:	e022                	sd	s0,0(sp)
ffffffffc0200ad4:	e406                	sd	ra,8(sp)

            /* (2) 计数器（ticks）加一
             * ticks是全局变量，记录总的时钟中断次数
             * 这个变量定义在clock.c中
             */
            ticks++;
ffffffffc0200ad6:	00006417          	auipc	s0,0x6
ffffffffc0200ada:	98240413          	addi	s0,s0,-1662 # ffffffffc0206458 <ticks>
            clock_set_next_event();
ffffffffc0200ade:	d37ff0ef          	jal	ra,ffffffffc0200814 <clock_set_next_event>
            ticks++;
ffffffffc0200ae2:	601c                	ld	a5,0(s0)

            /* (3) 当计数器达到100时，输出提示信息并增加打印计数 */
            if (ticks % TICK_NUM == 0) {
ffffffffc0200ae4:	06400713          	li	a4,100
            ticks++;
ffffffffc0200ae8:	0785                	addi	a5,a5,1
ffffffffc0200aea:	e01c                	sd	a5,0(s0)
            if (ticks % TICK_NUM == 0) {
ffffffffc0200aec:	601c                	ld	a5,0(s0)
ffffffffc0200aee:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200af2:	c79d                	beqz	a5,ffffffffc0200b20 <interrupt_handler+0xa0>
            }

            /* (4) 当ticks达到1000时（即打印了10次），关机
             * 这是为了防止测试程序无限运行
             */
            if (ticks == 10 * TICK_NUM) {
ffffffffc0200af4:	6018                	ld	a4,0(s0)
ffffffffc0200af6:	3e800793          	li	a5,1000
ffffffffc0200afa:	02f70c63          	beq	a4,a5,ffffffffc0200b32 <interrupt_handler+0xb2>
        default:
            /* 未识别的中断类型，打印完整trap frame用于调试 */
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200afe:	60a2                	ld	ra,8(sp)
ffffffffc0200b00:	6402                	ld	s0,0(sp)
ffffffffc0200b02:	0141                	addi	sp,sp,16
ffffffffc0200b04:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200b06:	00002517          	auipc	a0,0x2
ffffffffc0200b0a:	c2250513          	addi	a0,a0,-990 # ffffffffc0202728 <commands+0x5d8>
ffffffffc0200b0e:	dccff06f          	j	ffffffffc02000da <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200b12:	00002517          	auipc	a0,0x2
ffffffffc0200b16:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02026a0 <commands+0x550>
ffffffffc0200b1a:	dc0ff06f          	j	ffffffffc02000da <cprintf>
            print_trapframe(tf);
ffffffffc0200b1e:	b701                	j	ffffffffc0200a1e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b20:	06400593          	li	a1,100
ffffffffc0200b24:	00002517          	auipc	a0,0x2
ffffffffc0200b28:	bf450513          	addi	a0,a0,-1036 # ffffffffc0202718 <commands+0x5c8>
ffffffffc0200b2c:	daeff0ef          	jal	ra,ffffffffc02000da <cprintf>
}
ffffffffc0200b30:	b7d1                	j	ffffffffc0200af4 <interrupt_handler+0x74>
}
ffffffffc0200b32:	6402                	ld	s0,0(sp)
ffffffffc0200b34:	60a2                	ld	ra,8(sp)
ffffffffc0200b36:	0141                	addi	sp,sp,16
                sbi_shutdown();
ffffffffc0200b38:	3840106f          	j	ffffffffc0201ebc <sbi_shutdown>

ffffffffc0200b3c <exception_handler>:
 * 5. 系统调用异常(Environment Call): 执行ecall指令
 * 6. 页面错误(Page Fault): 页表映射不存在（MMU相关）
 * ====================================================================================== */
void exception_handler(struct trapframe *tf) {
    /* 根据scause的值分发不同的异常处理 */
    switch (tf->cause) {
ffffffffc0200b3c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200b40:	1141                	addi	sp,sp,-16
ffffffffc0200b42:	e022                	sd	s0,0(sp)
ffffffffc0200b44:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200b46:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200b48:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200b4a:	04e78663          	beq	a5,a4,ffffffffc0200b96 <exception_handler+0x5a>
ffffffffc0200b4e:	02f76c63          	bltu	a4,a5,ffffffffc0200b86 <exception_handler+0x4a>
ffffffffc0200b52:	4709                	li	a4,2
ffffffffc0200b54:	02e79563          	bne	a5,a4,ffffffffc0200b7e <exception_handler+0x42>
             * 2. 特权指令在用户态执行
             * 3. 不支持的扩展指令集
             */

            /* (1) 输出异常类型 */
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200b58:	00002517          	auipc	a0,0x2
ffffffffc0200b5c:	c2050513          	addi	a0,a0,-992 # ffffffffc0202778 <commands+0x628>
ffffffffc0200b60:	d7aff0ef          	jal	ra,ffffffffc02000da <cprintf>

            /* (2) 输出异常指令地址
             * sepc指向导致异常的指令地址
             */
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
ffffffffc0200b64:	10843583          	ld	a1,264(s0)
ffffffffc0200b68:	00002517          	auipc	a0,0x2
ffffffffc0200b6c:	c3850513          	addi	a0,a0,-968 # ffffffffc02027a0 <commands+0x650>
ffffffffc0200b70:	d6aff0ef          	jal	ra,ffffffffc02000da <cprintf>

            /* (3) 更新tf->epc以跳过非法指令
             * RISC-V指令通常是4字节长（压缩指令除外）
             * 将epc增加4，使CPU跳过这条非法指令继续执行
             */
            tf->epc += 4;
ffffffffc0200b74:	10843783          	ld	a5,264(s0)
ffffffffc0200b78:	0791                	addi	a5,a5,4
ffffffffc0200b7a:	10f43423          	sd	a5,264(s0)
        default:
            /* 未识别的异常类型，打印完整trap frame用于调试 */
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200b7e:	60a2                	ld	ra,8(sp)
ffffffffc0200b80:	6402                	ld	s0,0(sp)
ffffffffc0200b82:	0141                	addi	sp,sp,16
ffffffffc0200b84:	8082                	ret
    switch (tf->cause) {
ffffffffc0200b86:	17f1                	addi	a5,a5,-4
ffffffffc0200b88:	471d                	li	a4,7
ffffffffc0200b8a:	fef77ae3          	bgeu	a4,a5,ffffffffc0200b7e <exception_handler+0x42>
}
ffffffffc0200b8e:	6402                	ld	s0,0(sp)
ffffffffc0200b90:	60a2                	ld	ra,8(sp)
ffffffffc0200b92:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc0200b94:	b569                	j	ffffffffc0200a1e <print_trapframe>
            cprintf("Exception type: breakpoint\n");
ffffffffc0200b96:	00002517          	auipc	a0,0x2
ffffffffc0200b9a:	c3250513          	addi	a0,a0,-974 # ffffffffc02027c8 <commands+0x678>
ffffffffc0200b9e:	d3cff0ef          	jal	ra,ffffffffc02000da <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
ffffffffc0200ba2:	10843583          	ld	a1,264(s0)
ffffffffc0200ba6:	00002517          	auipc	a0,0x2
ffffffffc0200baa:	c4250513          	addi	a0,a0,-958 # ffffffffc02027e8 <commands+0x698>
ffffffffc0200bae:	d2cff0ef          	jal	ra,ffffffffc02000da <cprintf>
            tf->epc += 4;
ffffffffc0200bb2:	10843783          	ld	a5,264(s0)
}
ffffffffc0200bb6:	60a2                	ld	ra,8(sp)
            tf->epc += 4;
ffffffffc0200bb8:	0791                	addi	a5,a5,4
ffffffffc0200bba:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200bbe:	6402                	ld	s0,0(sp)
ffffffffc0200bc0:	0141                	addi	sp,sp,16
ffffffffc0200bc2:	8082                	ret

ffffffffc0200bc4 <trap>:
static inline void trap_dispatch(struct trapframe *tf) {
    /* 检查scause的最高位来区分中断和异常
     * 如果cause < 0，说明最高位为1，是中断
     * 如果cause >= 0，说明最高位为0，是异常
     */
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200bc4:	11853783          	ld	a5,280(a0)
ffffffffc0200bc8:	0007c363          	bltz	a5,ffffffffc0200bce <trap+0xa>
        // 最高位为1，表示中断，调用中断处理函数
        interrupt_handler(tf);
    } else {
        // 最高位为0，表示异常，调用异常处理函数
        exception_handler(tf);
ffffffffc0200bcc:	bf85                	j	ffffffffc0200b3c <exception_handler>
        interrupt_handler(tf);
ffffffffc0200bce:	bd4d                	j	ffffffffc0200a80 <interrupt_handler>

ffffffffc0200bd0 <__alltraps>:
# ======================================================================================
    .globl __alltraps
    .align(2)           /* 2字节对齐，确保地址正确 */
__alltraps:
    /* 保存完整的执行上下文到栈上 */
    SAVE_ALL
ffffffffc0200bd0:	14011073          	csrw	sscratch,sp
ffffffffc0200bd4:	712d                	addi	sp,sp,-288
ffffffffc0200bd6:	e002                	sd	zero,0(sp)
ffffffffc0200bd8:	e406                	sd	ra,8(sp)
ffffffffc0200bda:	ec0e                	sd	gp,24(sp)
ffffffffc0200bdc:	f012                	sd	tp,32(sp)
ffffffffc0200bde:	f416                	sd	t0,40(sp)
ffffffffc0200be0:	f81a                	sd	t1,48(sp)
ffffffffc0200be2:	fc1e                	sd	t2,56(sp)
ffffffffc0200be4:	e0a2                	sd	s0,64(sp)
ffffffffc0200be6:	e4a6                	sd	s1,72(sp)
ffffffffc0200be8:	e8aa                	sd	a0,80(sp)
ffffffffc0200bea:	ecae                	sd	a1,88(sp)
ffffffffc0200bec:	f0b2                	sd	a2,96(sp)
ffffffffc0200bee:	f4b6                	sd	a3,104(sp)
ffffffffc0200bf0:	f8ba                	sd	a4,112(sp)
ffffffffc0200bf2:	fcbe                	sd	a5,120(sp)
ffffffffc0200bf4:	e142                	sd	a6,128(sp)
ffffffffc0200bf6:	e546                	sd	a7,136(sp)
ffffffffc0200bf8:	e94a                	sd	s2,144(sp)
ffffffffc0200bfa:	ed4e                	sd	s3,152(sp)
ffffffffc0200bfc:	f152                	sd	s4,160(sp)
ffffffffc0200bfe:	f556                	sd	s5,168(sp)
ffffffffc0200c00:	f95a                	sd	s6,176(sp)
ffffffffc0200c02:	fd5e                	sd	s7,184(sp)
ffffffffc0200c04:	e1e2                	sd	s8,192(sp)
ffffffffc0200c06:	e5e6                	sd	s9,200(sp)
ffffffffc0200c08:	e9ea                	sd	s10,208(sp)
ffffffffc0200c0a:	edee                	sd	s11,216(sp)
ffffffffc0200c0c:	f1f2                	sd	t3,224(sp)
ffffffffc0200c0e:	f5f6                	sd	t4,232(sp)
ffffffffc0200c10:	f9fa                	sd	t5,240(sp)
ffffffffc0200c12:	fdfe                	sd	t6,248(sp)
ffffffffc0200c14:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200c18:	100024f3          	csrr	s1,sstatus
ffffffffc0200c1c:	14102973          	csrr	s2,sepc
ffffffffc0200c20:	143029f3          	csrr	s3,stval
ffffffffc0200c24:	14202a73          	csrr	s4,scause
ffffffffc0200c28:	e822                	sd	s0,16(sp)
ffffffffc0200c2a:	e226                	sd	s1,256(sp)
ffffffffc0200c2c:	e64a                	sd	s2,264(sp)
ffffffffc0200c2e:	ea4e                	sd	s3,272(sp)
ffffffffc0200c30:	ee52                	sd	s4,280(sp)

    /* 将当前栈指针（指向trap frame）作为参数传递给trap函数
     * 在RISC-V ABI中，a0是第一个参数寄存器
     */
    move  a0, sp
ffffffffc0200c32:	850a                	mv	a0,sp

    /* 调用C语言的trap处理函数
     * jal指令会保存返回地址到ra，并跳转到trap函数
     */
    jal trap
ffffffffc0200c34:	f91ff0ef          	jal	ra,ffffffffc0200bc4 <trap>

ffffffffc0200c38 <__trapret>:
# 并使用sret指令返回到被中断的代码继续执行
# ======================================================================================
    .globl __trapret
__trapret:
    /* 恢复所有保存的寄存器和CSR */
    RESTORE_ALL
ffffffffc0200c38:	6492                	ld	s1,256(sp)
ffffffffc0200c3a:	6932                	ld	s2,264(sp)
ffffffffc0200c3c:	10049073          	csrw	sstatus,s1
ffffffffc0200c40:	14191073          	csrw	sepc,s2
ffffffffc0200c44:	60a2                	ld	ra,8(sp)
ffffffffc0200c46:	61e2                	ld	gp,24(sp)
ffffffffc0200c48:	7202                	ld	tp,32(sp)
ffffffffc0200c4a:	72a2                	ld	t0,40(sp)
ffffffffc0200c4c:	7342                	ld	t1,48(sp)
ffffffffc0200c4e:	73e2                	ld	t2,56(sp)
ffffffffc0200c50:	6406                	ld	s0,64(sp)
ffffffffc0200c52:	64a6                	ld	s1,72(sp)
ffffffffc0200c54:	6546                	ld	a0,80(sp)
ffffffffc0200c56:	65e6                	ld	a1,88(sp)
ffffffffc0200c58:	7606                	ld	a2,96(sp)
ffffffffc0200c5a:	76a6                	ld	a3,104(sp)
ffffffffc0200c5c:	7746                	ld	a4,112(sp)
ffffffffc0200c5e:	77e6                	ld	a5,120(sp)
ffffffffc0200c60:	680a                	ld	a6,128(sp)
ffffffffc0200c62:	68aa                	ld	a7,136(sp)
ffffffffc0200c64:	694a                	ld	s2,144(sp)
ffffffffc0200c66:	69ea                	ld	s3,152(sp)
ffffffffc0200c68:	7a0a                	ld	s4,160(sp)
ffffffffc0200c6a:	7aaa                	ld	s5,168(sp)
ffffffffc0200c6c:	7b4a                	ld	s6,176(sp)
ffffffffc0200c6e:	7bea                	ld	s7,184(sp)
ffffffffc0200c70:	6c0e                	ld	s8,192(sp)
ffffffffc0200c72:	6cae                	ld	s9,200(sp)
ffffffffc0200c74:	6d4e                	ld	s10,208(sp)
ffffffffc0200c76:	6dee                	ld	s11,216(sp)
ffffffffc0200c78:	7e0e                	ld	t3,224(sp)
ffffffffc0200c7a:	7eae                	ld	t4,232(sp)
ffffffffc0200c7c:	7f4e                	ld	t5,240(sp)
ffffffffc0200c7e:	7fee                	ld	t6,248(sp)
ffffffffc0200c80:	6142                	ld	sp,16(sp)
     * sret会：
     * 1. 将sepc的值恢复到PC
     * 2. 恢复sstatus中的特权级和中断状态
     * 3. 继续执行被中断的代码
     */
    sret
ffffffffc0200c82:	10200073          	sret

ffffffffc0200c86 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200c86:	100027f3          	csrr	a5,sstatus
ffffffffc0200c8a:	8b89                	andi	a5,a5,2
ffffffffc0200c8c:	e799                	bnez	a5,ffffffffc0200c9a <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200c8e:	00005797          	auipc	a5,0x5
ffffffffc0200c92:	7e27b783          	ld	a5,2018(a5) # ffffffffc0206470 <pmm_manager>
ffffffffc0200c96:	6f9c                	ld	a5,24(a5)
ffffffffc0200c98:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200c9a:	1141                	addi	sp,sp,-16
ffffffffc0200c9c:	e406                	sd	ra,8(sp)
ffffffffc0200c9e:	e022                	sd	s0,0(sp)
ffffffffc0200ca0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200ca2:	b97ff0ef          	jal	ra,ffffffffc0200838 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200ca6:	00005797          	auipc	a5,0x5
ffffffffc0200caa:	7ca7b783          	ld	a5,1994(a5) # ffffffffc0206470 <pmm_manager>
ffffffffc0200cae:	6f9c                	ld	a5,24(a5)
ffffffffc0200cb0:	8522                	mv	a0,s0
ffffffffc0200cb2:	9782                	jalr	a5
ffffffffc0200cb4:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200cb6:	b7dff0ef          	jal	ra,ffffffffc0200832 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200cba:	60a2                	ld	ra,8(sp)
ffffffffc0200cbc:	8522                	mv	a0,s0
ffffffffc0200cbe:	6402                	ld	s0,0(sp)
ffffffffc0200cc0:	0141                	addi	sp,sp,16
ffffffffc0200cc2:	8082                	ret

ffffffffc0200cc4 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200cc4:	100027f3          	csrr	a5,sstatus
ffffffffc0200cc8:	8b89                	andi	a5,a5,2
ffffffffc0200cca:	e799                	bnez	a5,ffffffffc0200cd8 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200ccc:	00005797          	auipc	a5,0x5
ffffffffc0200cd0:	7a47b783          	ld	a5,1956(a5) # ffffffffc0206470 <pmm_manager>
ffffffffc0200cd4:	739c                	ld	a5,32(a5)
ffffffffc0200cd6:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200cd8:	1101                	addi	sp,sp,-32
ffffffffc0200cda:	ec06                	sd	ra,24(sp)
ffffffffc0200cdc:	e822                	sd	s0,16(sp)
ffffffffc0200cde:	e426                	sd	s1,8(sp)
ffffffffc0200ce0:	842a                	mv	s0,a0
ffffffffc0200ce2:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200ce4:	b55ff0ef          	jal	ra,ffffffffc0200838 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ce8:	00005797          	auipc	a5,0x5
ffffffffc0200cec:	7887b783          	ld	a5,1928(a5) # ffffffffc0206470 <pmm_manager>
ffffffffc0200cf0:	739c                	ld	a5,32(a5)
ffffffffc0200cf2:	85a6                	mv	a1,s1
ffffffffc0200cf4:	8522                	mv	a0,s0
ffffffffc0200cf6:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200cf8:	6442                	ld	s0,16(sp)
ffffffffc0200cfa:	60e2                	ld	ra,24(sp)
ffffffffc0200cfc:	64a2                	ld	s1,8(sp)
ffffffffc0200cfe:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200d00:	be0d                	j	ffffffffc0200832 <intr_enable>

ffffffffc0200d02 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d02:	100027f3          	csrr	a5,sstatus
ffffffffc0200d06:	8b89                	andi	a5,a5,2
ffffffffc0200d08:	e799                	bnez	a5,ffffffffc0200d16 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200d0a:	00005797          	auipc	a5,0x5
ffffffffc0200d0e:	7667b783          	ld	a5,1894(a5) # ffffffffc0206470 <pmm_manager>
ffffffffc0200d12:	779c                	ld	a5,40(a5)
ffffffffc0200d14:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200d16:	1141                	addi	sp,sp,-16
ffffffffc0200d18:	e406                	sd	ra,8(sp)
ffffffffc0200d1a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200d1c:	b1dff0ef          	jal	ra,ffffffffc0200838 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200d20:	00005797          	auipc	a5,0x5
ffffffffc0200d24:	7507b783          	ld	a5,1872(a5) # ffffffffc0206470 <pmm_manager>
ffffffffc0200d28:	779c                	ld	a5,40(a5)
ffffffffc0200d2a:	9782                	jalr	a5
ffffffffc0200d2c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200d2e:	b05ff0ef          	jal	ra,ffffffffc0200832 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200d32:	60a2                	ld	ra,8(sp)
ffffffffc0200d34:	8522                	mv	a0,s0
ffffffffc0200d36:	6402                	ld	s0,0(sp)
ffffffffc0200d38:	0141                	addi	sp,sp,16
ffffffffc0200d3a:	8082                	ret

ffffffffc0200d3c <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200d3c:	00002797          	auipc	a5,0x2
ffffffffc0200d40:	f5c78793          	addi	a5,a5,-164 # ffffffffc0202c98 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d44:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200d46:	7179                	addi	sp,sp,-48
ffffffffc0200d48:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d4a:	00002517          	auipc	a0,0x2
ffffffffc0200d4e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202808 <commands+0x6b8>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200d52:	00005417          	auipc	s0,0x5
ffffffffc0200d56:	71e40413          	addi	s0,s0,1822 # ffffffffc0206470 <pmm_manager>
void pmm_init(void) {
ffffffffc0200d5a:	f406                	sd	ra,40(sp)
ffffffffc0200d5c:	ec26                	sd	s1,24(sp)
ffffffffc0200d5e:	e44e                	sd	s3,8(sp)
ffffffffc0200d60:	e84a                	sd	s2,16(sp)
ffffffffc0200d62:	e052                	sd	s4,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200d64:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d66:	b74ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    pmm_manager->init();
ffffffffc0200d6a:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200d6c:	00005497          	auipc	s1,0x5
ffffffffc0200d70:	71c48493          	addi	s1,s1,1820 # ffffffffc0206488 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200d74:	679c                	ld	a5,8(a5)
ffffffffc0200d76:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200d78:	57f5                	li	a5,-3
ffffffffc0200d7a:	07fa                	slli	a5,a5,0x1e
ffffffffc0200d7c:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0200d7e:	a4fff0ef          	jal	ra,ffffffffc02007cc <get_memory_base>
ffffffffc0200d82:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200d84:	a53ff0ef          	jal	ra,ffffffffc02007d6 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200d88:	16050163          	beqz	a0,ffffffffc0200eea <pmm_init+0x1ae>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200d8c:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200d8e:	00002517          	auipc	a0,0x2
ffffffffc0200d92:	ac250513          	addi	a0,a0,-1342 # ffffffffc0202850 <commands+0x700>
ffffffffc0200d96:	b44ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200d9a:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200d9e:	864e                	mv	a2,s3
ffffffffc0200da0:	fffa0693          	addi	a3,s4,-1
ffffffffc0200da4:	85ca                	mv	a1,s2
ffffffffc0200da6:	00002517          	auipc	a0,0x2
ffffffffc0200daa:	ac250513          	addi	a0,a0,-1342 # ffffffffc0202868 <commands+0x718>
ffffffffc0200dae:	b2cff0ef          	jal	ra,ffffffffc02000da <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200db2:	c80007b7          	lui	a5,0xc8000
ffffffffc0200db6:	8652                	mv	a2,s4
ffffffffc0200db8:	0d47e863          	bltu	a5,s4,ffffffffc0200e88 <pmm_init+0x14c>
ffffffffc0200dbc:	00006797          	auipc	a5,0x6
ffffffffc0200dc0:	6db78793          	addi	a5,a5,1755 # ffffffffc0207497 <end+0xfff>
ffffffffc0200dc4:	757d                	lui	a0,0xfffff
ffffffffc0200dc6:	8d7d                	and	a0,a0,a5
ffffffffc0200dc8:	8231                	srli	a2,a2,0xc
ffffffffc0200dca:	00005597          	auipc	a1,0x5
ffffffffc0200dce:	69658593          	addi	a1,a1,1686 # ffffffffc0206460 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200dd2:	00005817          	auipc	a6,0x5
ffffffffc0200dd6:	69680813          	addi	a6,a6,1686 # ffffffffc0206468 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200dda:	e190                	sd	a2,0(a1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ddc:	00a83023          	sd	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200de0:	000807b7          	lui	a5,0x80
ffffffffc0200de4:	02f60663          	beq	a2,a5,ffffffffc0200e10 <pmm_init+0xd4>
ffffffffc0200de8:	4701                	li	a4,0
ffffffffc0200dea:	4781                	li	a5,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dec:	4305                	li	t1,1
ffffffffc0200dee:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200df2:	953a                	add	a0,a0,a4
ffffffffc0200df4:	00850693          	addi	a3,a0,8 # fffffffffffff008 <end+0x3fdf8b70>
ffffffffc0200df8:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200dfc:	6190                	ld	a2,0(a1)
ffffffffc0200dfe:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc0200e00:	00083503          	ld	a0,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e04:	011606b3          	add	a3,a2,a7
ffffffffc0200e08:	02870713          	addi	a4,a4,40
ffffffffc0200e0c:	fed7e3e3          	bltu	a5,a3,ffffffffc0200df2 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e10:	00261693          	slli	a3,a2,0x2
ffffffffc0200e14:	96b2                	add	a3,a3,a2
ffffffffc0200e16:	fec007b7          	lui	a5,0xfec00
ffffffffc0200e1a:	97aa                	add	a5,a5,a0
ffffffffc0200e1c:	068e                	slli	a3,a3,0x3
ffffffffc0200e1e:	96be                	add	a3,a3,a5
ffffffffc0200e20:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e24:	0af6e763          	bltu	a3,a5,ffffffffc0200ed2 <pmm_init+0x196>
ffffffffc0200e28:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200e2a:	77fd                	lui	a5,0xfffff
ffffffffc0200e2c:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e30:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200e32:	04b6ee63          	bltu	a3,a1,ffffffffc0200e8e <pmm_init+0x152>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200e36:	601c                	ld	a5,0(s0)
ffffffffc0200e38:	7b9c                	ld	a5,48(a5)
ffffffffc0200e3a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200e3c:	00002517          	auipc	a0,0x2
ffffffffc0200e40:	ab450513          	addi	a0,a0,-1356 # ffffffffc02028f0 <commands+0x7a0>
ffffffffc0200e44:	a96ff0ef          	jal	ra,ffffffffc02000da <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200e48:	00004597          	auipc	a1,0x4
ffffffffc0200e4c:	1b858593          	addi	a1,a1,440 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200e50:	00005797          	auipc	a5,0x5
ffffffffc0200e54:	62b7b823          	sd	a1,1584(a5) # ffffffffc0206480 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e58:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e5c:	0af5e363          	bltu	a1,a5,ffffffffc0200f02 <pmm_init+0x1c6>
ffffffffc0200e60:	6090                	ld	a2,0(s1)
}
ffffffffc0200e62:	7402                	ld	s0,32(sp)
ffffffffc0200e64:	70a2                	ld	ra,40(sp)
ffffffffc0200e66:	64e2                	ld	s1,24(sp)
ffffffffc0200e68:	6942                	ld	s2,16(sp)
ffffffffc0200e6a:	69a2                	ld	s3,8(sp)
ffffffffc0200e6c:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e6e:	40c58633          	sub	a2,a1,a2
ffffffffc0200e72:	00005797          	auipc	a5,0x5
ffffffffc0200e76:	60c7b323          	sd	a2,1542(a5) # ffffffffc0206478 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e7a:	00002517          	auipc	a0,0x2
ffffffffc0200e7e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0202910 <commands+0x7c0>
}
ffffffffc0200e82:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e84:	a56ff06f          	j	ffffffffc02000da <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200e88:	c8000637          	lui	a2,0xc8000
ffffffffc0200e8c:	bf05                	j	ffffffffc0200dbc <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200e8e:	6705                	lui	a4,0x1
ffffffffc0200e90:	177d                	addi	a4,a4,-1
ffffffffc0200e92:	96ba                	add	a3,a3,a4
ffffffffc0200e94:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200e96:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200e9a:	02c7f063          	bgeu	a5,a2,ffffffffc0200eba <pmm_init+0x17e>
    pmm_manager->init_memmap(base, n);
ffffffffc0200e9e:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200ea0:	fff80737          	lui	a4,0xfff80
ffffffffc0200ea4:	973e                	add	a4,a4,a5
ffffffffc0200ea6:	00271793          	slli	a5,a4,0x2
ffffffffc0200eaa:	97ba                	add	a5,a5,a4
ffffffffc0200eac:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200eae:	8d95                	sub	a1,a1,a3
ffffffffc0200eb0:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200eb2:	81b1                	srli	a1,a1,0xc
ffffffffc0200eb4:	953e                	add	a0,a0,a5
ffffffffc0200eb6:	9702                	jalr	a4
}
ffffffffc0200eb8:	bfbd                	j	ffffffffc0200e36 <pmm_init+0xfa>
        panic("pa2page called with invalid pa");
ffffffffc0200eba:	00002617          	auipc	a2,0x2
ffffffffc0200ebe:	a0660613          	addi	a2,a2,-1530 # ffffffffc02028c0 <commands+0x770>
ffffffffc0200ec2:	06b00593          	li	a1,107
ffffffffc0200ec6:	00002517          	auipc	a0,0x2
ffffffffc0200eca:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02028e0 <commands+0x790>
ffffffffc0200ece:	a94ff0ef          	jal	ra,ffffffffc0200162 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ed2:	00002617          	auipc	a2,0x2
ffffffffc0200ed6:	9c660613          	addi	a2,a2,-1594 # ffffffffc0202898 <commands+0x748>
ffffffffc0200eda:	07100593          	li	a1,113
ffffffffc0200ede:	00002517          	auipc	a0,0x2
ffffffffc0200ee2:	96250513          	addi	a0,a0,-1694 # ffffffffc0202840 <commands+0x6f0>
ffffffffc0200ee6:	a7cff0ef          	jal	ra,ffffffffc0200162 <__panic>
        panic("DTB memory info not available");
ffffffffc0200eea:	00002617          	auipc	a2,0x2
ffffffffc0200eee:	93660613          	addi	a2,a2,-1738 # ffffffffc0202820 <commands+0x6d0>
ffffffffc0200ef2:	05a00593          	li	a1,90
ffffffffc0200ef6:	00002517          	auipc	a0,0x2
ffffffffc0200efa:	94a50513          	addi	a0,a0,-1718 # ffffffffc0202840 <commands+0x6f0>
ffffffffc0200efe:	a64ff0ef          	jal	ra,ffffffffc0200162 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f02:	86ae                	mv	a3,a1
ffffffffc0200f04:	00002617          	auipc	a2,0x2
ffffffffc0200f08:	99460613          	addi	a2,a2,-1644 # ffffffffc0202898 <commands+0x748>
ffffffffc0200f0c:	08c00593          	li	a1,140
ffffffffc0200f10:	00002517          	auipc	a0,0x2
ffffffffc0200f14:	93050513          	addi	a0,a0,-1744 # ffffffffc0202840 <commands+0x6f0>
ffffffffc0200f18:	a4aff0ef          	jal	ra,ffffffffc0200162 <__panic>

ffffffffc0200f1c <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f1c:	00005797          	auipc	a5,0x5
ffffffffc0200f20:	10c78793          	addi	a5,a5,268 # ffffffffc0206028 <free_area>
ffffffffc0200f24:	e79c                	sd	a5,8(a5)
ffffffffc0200f26:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200f28:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200f2c:	8082                	ret

ffffffffc0200f2e <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200f2e:	00005517          	auipc	a0,0x5
ffffffffc0200f32:	10a56503          	lwu	a0,266(a0) # ffffffffc0206038 <free_area+0x10>
ffffffffc0200f36:	8082                	ret

ffffffffc0200f38 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200f38:	c14d                	beqz	a0,ffffffffc0200fda <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200f3a:	00005617          	auipc	a2,0x5
ffffffffc0200f3e:	0ee60613          	addi	a2,a2,238 # ffffffffc0206028 <free_area>
ffffffffc0200f42:	01062803          	lw	a6,16(a2)
ffffffffc0200f46:	86aa                	mv	a3,a0
ffffffffc0200f48:	02081793          	slli	a5,a6,0x20
ffffffffc0200f4c:	9381                	srli	a5,a5,0x20
ffffffffc0200f4e:	08a7e463          	bltu	a5,a0,ffffffffc0200fd6 <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200f52:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc0200f54:	0018059b          	addiw	a1,a6,1
ffffffffc0200f58:	1582                	slli	a1,a1,0x20
ffffffffc0200f5a:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200f5c:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f5e:	06c78b63          	beq	a5,a2,ffffffffc0200fd4 <best_fit_alloc_pages+0x9c>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200f62:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200f66:	00d76763          	bltu	a4,a3,ffffffffc0200f74 <best_fit_alloc_pages+0x3c>
ffffffffc0200f6a:	00b77563          	bgeu	a4,a1,ffffffffc0200f74 <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200f6e:	fe878513          	addi	a0,a5,-24
ffffffffc0200f72:	85ba                	mv	a1,a4
ffffffffc0200f74:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f76:	fec796e3          	bne	a5,a2,ffffffffc0200f62 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200f7a:	cd29                	beqz	a0,ffffffffc0200fd4 <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f7c:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200f7e:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200f80:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200f82:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200f86:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200f88:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc0200f8a:	02059793          	slli	a5,a1,0x20
ffffffffc0200f8e:	9381                	srli	a5,a5,0x20
ffffffffc0200f90:	02f6f863          	bgeu	a3,a5,ffffffffc0200fc0 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200f94:	00269793          	slli	a5,a3,0x2
ffffffffc0200f98:	97b6                	add	a5,a5,a3
ffffffffc0200f9a:	078e                	slli	a5,a5,0x3
ffffffffc0200f9c:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200f9e:	411585bb          	subw	a1,a1,a7
ffffffffc0200fa2:	cb8c                	sw	a1,16(a5)
ffffffffc0200fa4:	4689                	li	a3,2
ffffffffc0200fa6:	00878593          	addi	a1,a5,8
ffffffffc0200faa:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200fae:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200fb0:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc0200fb4:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200fb8:	e28c                	sd	a1,0(a3)
ffffffffc0200fba:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200fbc:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200fbe:	ef98                	sd	a4,24(a5)
ffffffffc0200fc0:	4118083b          	subw	a6,a6,a7
ffffffffc0200fc4:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fc8:	57f5                	li	a5,-3
ffffffffc0200fca:	00850713          	addi	a4,a0,8
ffffffffc0200fce:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200fd2:	8082                	ret
}
ffffffffc0200fd4:	8082                	ret
        return NULL;
ffffffffc0200fd6:	4501                	li	a0,0
ffffffffc0200fd8:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200fda:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200fdc:	00002697          	auipc	a3,0x2
ffffffffc0200fe0:	97468693          	addi	a3,a3,-1676 # ffffffffc0202950 <commands+0x800>
ffffffffc0200fe4:	00002617          	auipc	a2,0x2
ffffffffc0200fe8:	97460613          	addi	a2,a2,-1676 # ffffffffc0202958 <commands+0x808>
ffffffffc0200fec:	06400593          	li	a1,100
ffffffffc0200ff0:	00002517          	auipc	a0,0x2
ffffffffc0200ff4:	98050513          	addi	a0,a0,-1664 # ffffffffc0202970 <commands+0x820>
best_fit_alloc_pages(size_t n) {
ffffffffc0200ff8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ffa:	968ff0ef          	jal	ra,ffffffffc0200162 <__panic>

ffffffffc0200ffe <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200ffe:	715d                	addi	sp,sp,-80
ffffffffc0201000:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201002:	00005417          	auipc	s0,0x5
ffffffffc0201006:	02640413          	addi	s0,s0,38 # ffffffffc0206028 <free_area>
ffffffffc020100a:	641c                	ld	a5,8(s0)
ffffffffc020100c:	e486                	sd	ra,72(sp)
ffffffffc020100e:	fc26                	sd	s1,56(sp)
ffffffffc0201010:	f84a                	sd	s2,48(sp)
ffffffffc0201012:	f44e                	sd	s3,40(sp)
ffffffffc0201014:	f052                	sd	s4,32(sp)
ffffffffc0201016:	ec56                	sd	s5,24(sp)
ffffffffc0201018:	e85a                	sd	s6,16(sp)
ffffffffc020101a:	e45e                	sd	s7,8(sp)
ffffffffc020101c:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020101e:	26878b63          	beq	a5,s0,ffffffffc0201294 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0201022:	4481                	li	s1,0
ffffffffc0201024:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201026:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020102a:	8b09                	andi	a4,a4,2
ffffffffc020102c:	26070863          	beqz	a4,ffffffffc020129c <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0201030:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201034:	679c                	ld	a5,8(a5)
ffffffffc0201036:	2905                	addiw	s2,s2,1
ffffffffc0201038:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020103a:	fe8796e3          	bne	a5,s0,ffffffffc0201026 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020103e:	89a6                	mv	s3,s1
ffffffffc0201040:	cc3ff0ef          	jal	ra,ffffffffc0200d02 <nr_free_pages>
ffffffffc0201044:	33351c63          	bne	a0,s3,ffffffffc020137c <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201048:	4505                	li	a0,1
ffffffffc020104a:	c3dff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc020104e:	8a2a                	mv	s4,a0
ffffffffc0201050:	36050663          	beqz	a0,ffffffffc02013bc <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201054:	4505                	li	a0,1
ffffffffc0201056:	c31ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc020105a:	89aa                	mv	s3,a0
ffffffffc020105c:	34050063          	beqz	a0,ffffffffc020139c <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201060:	4505                	li	a0,1
ffffffffc0201062:	c25ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201066:	8aaa                	mv	s5,a0
ffffffffc0201068:	2c050a63          	beqz	a0,ffffffffc020133c <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020106c:	253a0863          	beq	s4,s3,ffffffffc02012bc <best_fit_check+0x2be>
ffffffffc0201070:	24aa0663          	beq	s4,a0,ffffffffc02012bc <best_fit_check+0x2be>
ffffffffc0201074:	24a98463          	beq	s3,a0,ffffffffc02012bc <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201078:	000a2783          	lw	a5,0(s4)
ffffffffc020107c:	26079063          	bnez	a5,ffffffffc02012dc <best_fit_check+0x2de>
ffffffffc0201080:	0009a783          	lw	a5,0(s3)
ffffffffc0201084:	24079c63          	bnez	a5,ffffffffc02012dc <best_fit_check+0x2de>
ffffffffc0201088:	411c                	lw	a5,0(a0)
ffffffffc020108a:	24079963          	bnez	a5,ffffffffc02012dc <best_fit_check+0x2de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020108e:	00005797          	auipc	a5,0x5
ffffffffc0201092:	3da7b783          	ld	a5,986(a5) # ffffffffc0206468 <pages>
ffffffffc0201096:	40fa0733          	sub	a4,s4,a5
ffffffffc020109a:	870d                	srai	a4,a4,0x3
ffffffffc020109c:	00002597          	auipc	a1,0x2
ffffffffc02010a0:	e845b583          	ld	a1,-380(a1) # ffffffffc0202f20 <nbase+0x8>
ffffffffc02010a4:	02b70733          	mul	a4,a4,a1
ffffffffc02010a8:	00002617          	auipc	a2,0x2
ffffffffc02010ac:	e7063603          	ld	a2,-400(a2) # ffffffffc0202f18 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02010b0:	00005697          	auipc	a3,0x5
ffffffffc02010b4:	3b06b683          	ld	a3,944(a3) # ffffffffc0206460 <npage>
ffffffffc02010b8:	06b2                	slli	a3,a3,0xc
ffffffffc02010ba:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010bc:	0732                	slli	a4,a4,0xc
ffffffffc02010be:	22d77f63          	bgeu	a4,a3,ffffffffc02012fc <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010c2:	40f98733          	sub	a4,s3,a5
ffffffffc02010c6:	870d                	srai	a4,a4,0x3
ffffffffc02010c8:	02b70733          	mul	a4,a4,a1
ffffffffc02010cc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010ce:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010d0:	3ed77663          	bgeu	a4,a3,ffffffffc02014bc <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02010d4:	40f507b3          	sub	a5,a0,a5
ffffffffc02010d8:	878d                	srai	a5,a5,0x3
ffffffffc02010da:	02b787b3          	mul	a5,a5,a1
ffffffffc02010de:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02010e0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02010e2:	3ad7fd63          	bgeu	a5,a3,ffffffffc020149c <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc02010e6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010e8:	00043c03          	ld	s8,0(s0)
ffffffffc02010ec:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02010f0:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02010f4:	e400                	sd	s0,8(s0)
ffffffffc02010f6:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02010f8:	00005797          	auipc	a5,0x5
ffffffffc02010fc:	f407a023          	sw	zero,-192(a5) # ffffffffc0206038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201100:	b87ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201104:	36051c63          	bnez	a0,ffffffffc020147c <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0201108:	4585                	li	a1,1
ffffffffc020110a:	8552                	mv	a0,s4
ffffffffc020110c:	bb9ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    free_page(p1);
ffffffffc0201110:	4585                	li	a1,1
ffffffffc0201112:	854e                	mv	a0,s3
ffffffffc0201114:	bb1ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    free_page(p2);
ffffffffc0201118:	4585                	li	a1,1
ffffffffc020111a:	8556                	mv	a0,s5
ffffffffc020111c:	ba9ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    assert(nr_free == 3);
ffffffffc0201120:	4818                	lw	a4,16(s0)
ffffffffc0201122:	478d                	li	a5,3
ffffffffc0201124:	32f71c63          	bne	a4,a5,ffffffffc020145c <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201128:	4505                	li	a0,1
ffffffffc020112a:	b5dff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc020112e:	89aa                	mv	s3,a0
ffffffffc0201130:	30050663          	beqz	a0,ffffffffc020143c <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201134:	4505                	li	a0,1
ffffffffc0201136:	b51ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc020113a:	8aaa                	mv	s5,a0
ffffffffc020113c:	2e050063          	beqz	a0,ffffffffc020141c <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201140:	4505                	li	a0,1
ffffffffc0201142:	b45ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201146:	8a2a                	mv	s4,a0
ffffffffc0201148:	2a050a63          	beqz	a0,ffffffffc02013fc <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc020114c:	4505                	li	a0,1
ffffffffc020114e:	b39ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201152:	28051563          	bnez	a0,ffffffffc02013dc <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0201156:	4585                	li	a1,1
ffffffffc0201158:	854e                	mv	a0,s3
ffffffffc020115a:	b6bff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020115e:	641c                	ld	a5,8(s0)
ffffffffc0201160:	1a878e63          	beq	a5,s0,ffffffffc020131c <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0201164:	4505                	li	a0,1
ffffffffc0201166:	b21ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc020116a:	52a99963          	bne	s3,a0,ffffffffc020169c <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc020116e:	4505                	li	a0,1
ffffffffc0201170:	b17ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201174:	50051463          	bnez	a0,ffffffffc020167c <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0201178:	481c                	lw	a5,16(s0)
ffffffffc020117a:	4e079163          	bnez	a5,ffffffffc020165c <best_fit_check+0x65e>
    free_page(p);
ffffffffc020117e:	854e                	mv	a0,s3
ffffffffc0201180:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201182:	01843023          	sd	s8,0(s0)
ffffffffc0201186:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020118a:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020118e:	b37ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    free_page(p1);
ffffffffc0201192:	4585                	li	a1,1
ffffffffc0201194:	8556                	mv	a0,s5
ffffffffc0201196:	b2fff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    free_page(p2);
ffffffffc020119a:	4585                	li	a1,1
ffffffffc020119c:	8552                	mv	a0,s4
ffffffffc020119e:	b27ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02011a2:	4515                	li	a0,5
ffffffffc02011a4:	ae3ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc02011a8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02011aa:	48050963          	beqz	a0,ffffffffc020163c <best_fit_check+0x63e>
ffffffffc02011ae:	651c                	ld	a5,8(a0)
ffffffffc02011b0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02011b2:	8b85                	andi	a5,a5,1
ffffffffc02011b4:	46079463          	bnez	a5,ffffffffc020161c <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02011b8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02011ba:	00043a83          	ld	s5,0(s0)
ffffffffc02011be:	00843a03          	ld	s4,8(s0)
ffffffffc02011c2:	e000                	sd	s0,0(s0)
ffffffffc02011c4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02011c6:	ac1ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc02011ca:	42051963          	bnez	a0,ffffffffc02015fc <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc02011ce:	4589                	li	a1,2
ffffffffc02011d0:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc02011d4:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc02011d8:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc02011dc:	00005797          	auipc	a5,0x5
ffffffffc02011e0:	e407ae23          	sw	zero,-420(a5) # ffffffffc0206038 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc02011e4:	ae1ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc02011e8:	8562                	mv	a0,s8
ffffffffc02011ea:	4585                	li	a1,1
ffffffffc02011ec:	ad9ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02011f0:	4511                	li	a0,4
ffffffffc02011f2:	a95ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc02011f6:	3e051363          	bnez	a0,ffffffffc02015dc <best_fit_check+0x5de>
ffffffffc02011fa:	0309b783          	ld	a5,48(s3)
ffffffffc02011fe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201200:	8b85                	andi	a5,a5,1
ffffffffc0201202:	3a078d63          	beqz	a5,ffffffffc02015bc <best_fit_check+0x5be>
ffffffffc0201206:	0389a703          	lw	a4,56(s3)
ffffffffc020120a:	4789                	li	a5,2
ffffffffc020120c:	3af71863          	bne	a4,a5,ffffffffc02015bc <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201210:	4505                	li	a0,1
ffffffffc0201212:	a75ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201216:	8baa                	mv	s7,a0
ffffffffc0201218:	38050263          	beqz	a0,ffffffffc020159c <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020121c:	4509                	li	a0,2
ffffffffc020121e:	a69ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201222:	34050d63          	beqz	a0,ffffffffc020157c <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0201226:	337c1b63          	bne	s8,s7,ffffffffc020155c <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc020122a:	854e                	mv	a0,s3
ffffffffc020122c:	4595                	li	a1,5
ffffffffc020122e:	a97ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201232:	4515                	li	a0,5
ffffffffc0201234:	a53ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201238:	89aa                	mv	s3,a0
ffffffffc020123a:	30050163          	beqz	a0,ffffffffc020153c <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc020123e:	4505                	li	a0,1
ffffffffc0201240:	a47ff0ef          	jal	ra,ffffffffc0200c86 <alloc_pages>
ffffffffc0201244:	2c051c63          	bnez	a0,ffffffffc020151c <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0201248:	481c                	lw	a5,16(s0)
ffffffffc020124a:	2a079963          	bnez	a5,ffffffffc02014fc <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020124e:	4595                	li	a1,5
ffffffffc0201250:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201252:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0201256:	01543023          	sd	s5,0(s0)
ffffffffc020125a:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc020125e:	a67ff0ef          	jal	ra,ffffffffc0200cc4 <free_pages>
    return listelm->next;
ffffffffc0201262:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201264:	00878963          	beq	a5,s0,ffffffffc0201276 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201268:	ff87a703          	lw	a4,-8(a5)
ffffffffc020126c:	679c                	ld	a5,8(a5)
ffffffffc020126e:	397d                	addiw	s2,s2,-1
ffffffffc0201270:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201272:	fe879be3          	bne	a5,s0,ffffffffc0201268 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0201276:	26091363          	bnez	s2,ffffffffc02014dc <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc020127a:	e0ed                	bnez	s1,ffffffffc020135c <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc020127c:	60a6                	ld	ra,72(sp)
ffffffffc020127e:	6406                	ld	s0,64(sp)
ffffffffc0201280:	74e2                	ld	s1,56(sp)
ffffffffc0201282:	7942                	ld	s2,48(sp)
ffffffffc0201284:	79a2                	ld	s3,40(sp)
ffffffffc0201286:	7a02                	ld	s4,32(sp)
ffffffffc0201288:	6ae2                	ld	s5,24(sp)
ffffffffc020128a:	6b42                	ld	s6,16(sp)
ffffffffc020128c:	6ba2                	ld	s7,8(sp)
ffffffffc020128e:	6c02                	ld	s8,0(sp)
ffffffffc0201290:	6161                	addi	sp,sp,80
ffffffffc0201292:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201294:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201296:	4481                	li	s1,0
ffffffffc0201298:	4901                	li	s2,0
ffffffffc020129a:	b35d                	j	ffffffffc0201040 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc020129c:	00001697          	auipc	a3,0x1
ffffffffc02012a0:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202988 <commands+0x838>
ffffffffc02012a4:	00001617          	auipc	a2,0x1
ffffffffc02012a8:	6b460613          	addi	a2,a2,1716 # ffffffffc0202958 <commands+0x808>
ffffffffc02012ac:	0f400593          	li	a1,244
ffffffffc02012b0:	00001517          	auipc	a0,0x1
ffffffffc02012b4:	6c050513          	addi	a0,a0,1728 # ffffffffc0202970 <commands+0x820>
ffffffffc02012b8:	eabfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02012bc:	00001697          	auipc	a3,0x1
ffffffffc02012c0:	75c68693          	addi	a3,a3,1884 # ffffffffc0202a18 <commands+0x8c8>
ffffffffc02012c4:	00001617          	auipc	a2,0x1
ffffffffc02012c8:	69460613          	addi	a2,a2,1684 # ffffffffc0202958 <commands+0x808>
ffffffffc02012cc:	0c000593          	li	a1,192
ffffffffc02012d0:	00001517          	auipc	a0,0x1
ffffffffc02012d4:	6a050513          	addi	a0,a0,1696 # ffffffffc0202970 <commands+0x820>
ffffffffc02012d8:	e8bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02012dc:	00001697          	auipc	a3,0x1
ffffffffc02012e0:	76468693          	addi	a3,a3,1892 # ffffffffc0202a40 <commands+0x8f0>
ffffffffc02012e4:	00001617          	auipc	a2,0x1
ffffffffc02012e8:	67460613          	addi	a2,a2,1652 # ffffffffc0202958 <commands+0x808>
ffffffffc02012ec:	0c100593          	li	a1,193
ffffffffc02012f0:	00001517          	auipc	a0,0x1
ffffffffc02012f4:	68050513          	addi	a0,a0,1664 # ffffffffc0202970 <commands+0x820>
ffffffffc02012f8:	e6bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02012fc:	00001697          	auipc	a3,0x1
ffffffffc0201300:	78468693          	addi	a3,a3,1924 # ffffffffc0202a80 <commands+0x930>
ffffffffc0201304:	00001617          	auipc	a2,0x1
ffffffffc0201308:	65460613          	addi	a2,a2,1620 # ffffffffc0202958 <commands+0x808>
ffffffffc020130c:	0c300593          	li	a1,195
ffffffffc0201310:	00001517          	auipc	a0,0x1
ffffffffc0201314:	66050513          	addi	a0,a0,1632 # ffffffffc0202970 <commands+0x820>
ffffffffc0201318:	e4bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020131c:	00001697          	auipc	a3,0x1
ffffffffc0201320:	7ec68693          	addi	a3,a3,2028 # ffffffffc0202b08 <commands+0x9b8>
ffffffffc0201324:	00001617          	auipc	a2,0x1
ffffffffc0201328:	63460613          	addi	a2,a2,1588 # ffffffffc0202958 <commands+0x808>
ffffffffc020132c:	0dc00593          	li	a1,220
ffffffffc0201330:	00001517          	auipc	a0,0x1
ffffffffc0201334:	64050513          	addi	a0,a0,1600 # ffffffffc0202970 <commands+0x820>
ffffffffc0201338:	e2bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020133c:	00001697          	auipc	a3,0x1
ffffffffc0201340:	6bc68693          	addi	a3,a3,1724 # ffffffffc02029f8 <commands+0x8a8>
ffffffffc0201344:	00001617          	auipc	a2,0x1
ffffffffc0201348:	61460613          	addi	a2,a2,1556 # ffffffffc0202958 <commands+0x808>
ffffffffc020134c:	0be00593          	li	a1,190
ffffffffc0201350:	00001517          	auipc	a0,0x1
ffffffffc0201354:	62050513          	addi	a0,a0,1568 # ffffffffc0202970 <commands+0x820>
ffffffffc0201358:	e0bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(total == 0);
ffffffffc020135c:	00002697          	auipc	a3,0x2
ffffffffc0201360:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0202c38 <commands+0xae8>
ffffffffc0201364:	00001617          	auipc	a2,0x1
ffffffffc0201368:	5f460613          	addi	a2,a2,1524 # ffffffffc0202958 <commands+0x808>
ffffffffc020136c:	13600593          	li	a1,310
ffffffffc0201370:	00001517          	auipc	a0,0x1
ffffffffc0201374:	60050513          	addi	a0,a0,1536 # ffffffffc0202970 <commands+0x820>
ffffffffc0201378:	debfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(total == nr_free_pages());
ffffffffc020137c:	00001697          	auipc	a3,0x1
ffffffffc0201380:	61c68693          	addi	a3,a3,1564 # ffffffffc0202998 <commands+0x848>
ffffffffc0201384:	00001617          	auipc	a2,0x1
ffffffffc0201388:	5d460613          	addi	a2,a2,1492 # ffffffffc0202958 <commands+0x808>
ffffffffc020138c:	0f700593          	li	a1,247
ffffffffc0201390:	00001517          	auipc	a0,0x1
ffffffffc0201394:	5e050513          	addi	a0,a0,1504 # ffffffffc0202970 <commands+0x820>
ffffffffc0201398:	dcbfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020139c:	00001697          	auipc	a3,0x1
ffffffffc02013a0:	63c68693          	addi	a3,a3,1596 # ffffffffc02029d8 <commands+0x888>
ffffffffc02013a4:	00001617          	auipc	a2,0x1
ffffffffc02013a8:	5b460613          	addi	a2,a2,1460 # ffffffffc0202958 <commands+0x808>
ffffffffc02013ac:	0bd00593          	li	a1,189
ffffffffc02013b0:	00001517          	auipc	a0,0x1
ffffffffc02013b4:	5c050513          	addi	a0,a0,1472 # ffffffffc0202970 <commands+0x820>
ffffffffc02013b8:	dabfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02013bc:	00001697          	auipc	a3,0x1
ffffffffc02013c0:	5fc68693          	addi	a3,a3,1532 # ffffffffc02029b8 <commands+0x868>
ffffffffc02013c4:	00001617          	auipc	a2,0x1
ffffffffc02013c8:	59460613          	addi	a2,a2,1428 # ffffffffc0202958 <commands+0x808>
ffffffffc02013cc:	0bc00593          	li	a1,188
ffffffffc02013d0:	00001517          	auipc	a0,0x1
ffffffffc02013d4:	5a050513          	addi	a0,a0,1440 # ffffffffc0202970 <commands+0x820>
ffffffffc02013d8:	d8bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013dc:	00001697          	auipc	a3,0x1
ffffffffc02013e0:	70468693          	addi	a3,a3,1796 # ffffffffc0202ae0 <commands+0x990>
ffffffffc02013e4:	00001617          	auipc	a2,0x1
ffffffffc02013e8:	57460613          	addi	a2,a2,1396 # ffffffffc0202958 <commands+0x808>
ffffffffc02013ec:	0d900593          	li	a1,217
ffffffffc02013f0:	00001517          	auipc	a0,0x1
ffffffffc02013f4:	58050513          	addi	a0,a0,1408 # ffffffffc0202970 <commands+0x820>
ffffffffc02013f8:	d6bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013fc:	00001697          	auipc	a3,0x1
ffffffffc0201400:	5fc68693          	addi	a3,a3,1532 # ffffffffc02029f8 <commands+0x8a8>
ffffffffc0201404:	00001617          	auipc	a2,0x1
ffffffffc0201408:	55460613          	addi	a2,a2,1364 # ffffffffc0202958 <commands+0x808>
ffffffffc020140c:	0d700593          	li	a1,215
ffffffffc0201410:	00001517          	auipc	a0,0x1
ffffffffc0201414:	56050513          	addi	a0,a0,1376 # ffffffffc0202970 <commands+0x820>
ffffffffc0201418:	d4bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020141c:	00001697          	auipc	a3,0x1
ffffffffc0201420:	5bc68693          	addi	a3,a3,1468 # ffffffffc02029d8 <commands+0x888>
ffffffffc0201424:	00001617          	auipc	a2,0x1
ffffffffc0201428:	53460613          	addi	a2,a2,1332 # ffffffffc0202958 <commands+0x808>
ffffffffc020142c:	0d600593          	li	a1,214
ffffffffc0201430:	00001517          	auipc	a0,0x1
ffffffffc0201434:	54050513          	addi	a0,a0,1344 # ffffffffc0202970 <commands+0x820>
ffffffffc0201438:	d2bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020143c:	00001697          	auipc	a3,0x1
ffffffffc0201440:	57c68693          	addi	a3,a3,1404 # ffffffffc02029b8 <commands+0x868>
ffffffffc0201444:	00001617          	auipc	a2,0x1
ffffffffc0201448:	51460613          	addi	a2,a2,1300 # ffffffffc0202958 <commands+0x808>
ffffffffc020144c:	0d500593          	li	a1,213
ffffffffc0201450:	00001517          	auipc	a0,0x1
ffffffffc0201454:	52050513          	addi	a0,a0,1312 # ffffffffc0202970 <commands+0x820>
ffffffffc0201458:	d0bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(nr_free == 3);
ffffffffc020145c:	00001697          	auipc	a3,0x1
ffffffffc0201460:	69c68693          	addi	a3,a3,1692 # ffffffffc0202af8 <commands+0x9a8>
ffffffffc0201464:	00001617          	auipc	a2,0x1
ffffffffc0201468:	4f460613          	addi	a2,a2,1268 # ffffffffc0202958 <commands+0x808>
ffffffffc020146c:	0d300593          	li	a1,211
ffffffffc0201470:	00001517          	auipc	a0,0x1
ffffffffc0201474:	50050513          	addi	a0,a0,1280 # ffffffffc0202970 <commands+0x820>
ffffffffc0201478:	cebfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020147c:	00001697          	auipc	a3,0x1
ffffffffc0201480:	66468693          	addi	a3,a3,1636 # ffffffffc0202ae0 <commands+0x990>
ffffffffc0201484:	00001617          	auipc	a2,0x1
ffffffffc0201488:	4d460613          	addi	a2,a2,1236 # ffffffffc0202958 <commands+0x808>
ffffffffc020148c:	0ce00593          	li	a1,206
ffffffffc0201490:	00001517          	auipc	a0,0x1
ffffffffc0201494:	4e050513          	addi	a0,a0,1248 # ffffffffc0202970 <commands+0x820>
ffffffffc0201498:	ccbfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020149c:	00001697          	auipc	a3,0x1
ffffffffc02014a0:	62468693          	addi	a3,a3,1572 # ffffffffc0202ac0 <commands+0x970>
ffffffffc02014a4:	00001617          	auipc	a2,0x1
ffffffffc02014a8:	4b460613          	addi	a2,a2,1204 # ffffffffc0202958 <commands+0x808>
ffffffffc02014ac:	0c500593          	li	a1,197
ffffffffc02014b0:	00001517          	auipc	a0,0x1
ffffffffc02014b4:	4c050513          	addi	a0,a0,1216 # ffffffffc0202970 <commands+0x820>
ffffffffc02014b8:	cabfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02014bc:	00001697          	auipc	a3,0x1
ffffffffc02014c0:	5e468693          	addi	a3,a3,1508 # ffffffffc0202aa0 <commands+0x950>
ffffffffc02014c4:	00001617          	auipc	a2,0x1
ffffffffc02014c8:	49460613          	addi	a2,a2,1172 # ffffffffc0202958 <commands+0x808>
ffffffffc02014cc:	0c400593          	li	a1,196
ffffffffc02014d0:	00001517          	auipc	a0,0x1
ffffffffc02014d4:	4a050513          	addi	a0,a0,1184 # ffffffffc0202970 <commands+0x820>
ffffffffc02014d8:	c8bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(count == 0);
ffffffffc02014dc:	00001697          	auipc	a3,0x1
ffffffffc02014e0:	74c68693          	addi	a3,a3,1868 # ffffffffc0202c28 <commands+0xad8>
ffffffffc02014e4:	00001617          	auipc	a2,0x1
ffffffffc02014e8:	47460613          	addi	a2,a2,1140 # ffffffffc0202958 <commands+0x808>
ffffffffc02014ec:	13500593          	li	a1,309
ffffffffc02014f0:	00001517          	auipc	a0,0x1
ffffffffc02014f4:	48050513          	addi	a0,a0,1152 # ffffffffc0202970 <commands+0x820>
ffffffffc02014f8:	c6bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(nr_free == 0);
ffffffffc02014fc:	00001697          	auipc	a3,0x1
ffffffffc0201500:	64468693          	addi	a3,a3,1604 # ffffffffc0202b40 <commands+0x9f0>
ffffffffc0201504:	00001617          	auipc	a2,0x1
ffffffffc0201508:	45460613          	addi	a2,a2,1108 # ffffffffc0202958 <commands+0x808>
ffffffffc020150c:	12a00593          	li	a1,298
ffffffffc0201510:	00001517          	auipc	a0,0x1
ffffffffc0201514:	46050513          	addi	a0,a0,1120 # ffffffffc0202970 <commands+0x820>
ffffffffc0201518:	c4bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020151c:	00001697          	auipc	a3,0x1
ffffffffc0201520:	5c468693          	addi	a3,a3,1476 # ffffffffc0202ae0 <commands+0x990>
ffffffffc0201524:	00001617          	auipc	a2,0x1
ffffffffc0201528:	43460613          	addi	a2,a2,1076 # ffffffffc0202958 <commands+0x808>
ffffffffc020152c:	12400593          	li	a1,292
ffffffffc0201530:	00001517          	auipc	a0,0x1
ffffffffc0201534:	44050513          	addi	a0,a0,1088 # ffffffffc0202970 <commands+0x820>
ffffffffc0201538:	c2bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020153c:	00001697          	auipc	a3,0x1
ffffffffc0201540:	6cc68693          	addi	a3,a3,1740 # ffffffffc0202c08 <commands+0xab8>
ffffffffc0201544:	00001617          	auipc	a2,0x1
ffffffffc0201548:	41460613          	addi	a2,a2,1044 # ffffffffc0202958 <commands+0x808>
ffffffffc020154c:	12300593          	li	a1,291
ffffffffc0201550:	00001517          	auipc	a0,0x1
ffffffffc0201554:	42050513          	addi	a0,a0,1056 # ffffffffc0202970 <commands+0x820>
ffffffffc0201558:	c0bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(p0 + 4 == p1);
ffffffffc020155c:	00001697          	auipc	a3,0x1
ffffffffc0201560:	69c68693          	addi	a3,a3,1692 # ffffffffc0202bf8 <commands+0xaa8>
ffffffffc0201564:	00001617          	auipc	a2,0x1
ffffffffc0201568:	3f460613          	addi	a2,a2,1012 # ffffffffc0202958 <commands+0x808>
ffffffffc020156c:	11b00593          	li	a1,283
ffffffffc0201570:	00001517          	auipc	a0,0x1
ffffffffc0201574:	40050513          	addi	a0,a0,1024 # ffffffffc0202970 <commands+0x820>
ffffffffc0201578:	bebfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020157c:	00001697          	auipc	a3,0x1
ffffffffc0201580:	66468693          	addi	a3,a3,1636 # ffffffffc0202be0 <commands+0xa90>
ffffffffc0201584:	00001617          	auipc	a2,0x1
ffffffffc0201588:	3d460613          	addi	a2,a2,980 # ffffffffc0202958 <commands+0x808>
ffffffffc020158c:	11a00593          	li	a1,282
ffffffffc0201590:	00001517          	auipc	a0,0x1
ffffffffc0201594:	3e050513          	addi	a0,a0,992 # ffffffffc0202970 <commands+0x820>
ffffffffc0201598:	bcbfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020159c:	00001697          	auipc	a3,0x1
ffffffffc02015a0:	62468693          	addi	a3,a3,1572 # ffffffffc0202bc0 <commands+0xa70>
ffffffffc02015a4:	00001617          	auipc	a2,0x1
ffffffffc02015a8:	3b460613          	addi	a2,a2,948 # ffffffffc0202958 <commands+0x808>
ffffffffc02015ac:	11900593          	li	a1,281
ffffffffc02015b0:	00001517          	auipc	a0,0x1
ffffffffc02015b4:	3c050513          	addi	a0,a0,960 # ffffffffc0202970 <commands+0x820>
ffffffffc02015b8:	babfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02015bc:	00001697          	auipc	a3,0x1
ffffffffc02015c0:	5d468693          	addi	a3,a3,1492 # ffffffffc0202b90 <commands+0xa40>
ffffffffc02015c4:	00001617          	auipc	a2,0x1
ffffffffc02015c8:	39460613          	addi	a2,a2,916 # ffffffffc0202958 <commands+0x808>
ffffffffc02015cc:	11700593          	li	a1,279
ffffffffc02015d0:	00001517          	auipc	a0,0x1
ffffffffc02015d4:	3a050513          	addi	a0,a0,928 # ffffffffc0202970 <commands+0x820>
ffffffffc02015d8:	b8bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02015dc:	00001697          	auipc	a3,0x1
ffffffffc02015e0:	59c68693          	addi	a3,a3,1436 # ffffffffc0202b78 <commands+0xa28>
ffffffffc02015e4:	00001617          	auipc	a2,0x1
ffffffffc02015e8:	37460613          	addi	a2,a2,884 # ffffffffc0202958 <commands+0x808>
ffffffffc02015ec:	11600593          	li	a1,278
ffffffffc02015f0:	00001517          	auipc	a0,0x1
ffffffffc02015f4:	38050513          	addi	a0,a0,896 # ffffffffc0202970 <commands+0x820>
ffffffffc02015f8:	b6bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015fc:	00001697          	auipc	a3,0x1
ffffffffc0201600:	4e468693          	addi	a3,a3,1252 # ffffffffc0202ae0 <commands+0x990>
ffffffffc0201604:	00001617          	auipc	a2,0x1
ffffffffc0201608:	35460613          	addi	a2,a2,852 # ffffffffc0202958 <commands+0x808>
ffffffffc020160c:	10a00593          	li	a1,266
ffffffffc0201610:	00001517          	auipc	a0,0x1
ffffffffc0201614:	36050513          	addi	a0,a0,864 # ffffffffc0202970 <commands+0x820>
ffffffffc0201618:	b4bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(!PageProperty(p0));
ffffffffc020161c:	00001697          	auipc	a3,0x1
ffffffffc0201620:	54468693          	addi	a3,a3,1348 # ffffffffc0202b60 <commands+0xa10>
ffffffffc0201624:	00001617          	auipc	a2,0x1
ffffffffc0201628:	33460613          	addi	a2,a2,820 # ffffffffc0202958 <commands+0x808>
ffffffffc020162c:	10100593          	li	a1,257
ffffffffc0201630:	00001517          	auipc	a0,0x1
ffffffffc0201634:	34050513          	addi	a0,a0,832 # ffffffffc0202970 <commands+0x820>
ffffffffc0201638:	b2bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(p0 != NULL);
ffffffffc020163c:	00001697          	auipc	a3,0x1
ffffffffc0201640:	51468693          	addi	a3,a3,1300 # ffffffffc0202b50 <commands+0xa00>
ffffffffc0201644:	00001617          	auipc	a2,0x1
ffffffffc0201648:	31460613          	addi	a2,a2,788 # ffffffffc0202958 <commands+0x808>
ffffffffc020164c:	10000593          	li	a1,256
ffffffffc0201650:	00001517          	auipc	a0,0x1
ffffffffc0201654:	32050513          	addi	a0,a0,800 # ffffffffc0202970 <commands+0x820>
ffffffffc0201658:	b0bfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(nr_free == 0);
ffffffffc020165c:	00001697          	auipc	a3,0x1
ffffffffc0201660:	4e468693          	addi	a3,a3,1252 # ffffffffc0202b40 <commands+0x9f0>
ffffffffc0201664:	00001617          	auipc	a2,0x1
ffffffffc0201668:	2f460613          	addi	a2,a2,756 # ffffffffc0202958 <commands+0x808>
ffffffffc020166c:	0e200593          	li	a1,226
ffffffffc0201670:	00001517          	auipc	a0,0x1
ffffffffc0201674:	30050513          	addi	a0,a0,768 # ffffffffc0202970 <commands+0x820>
ffffffffc0201678:	aebfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020167c:	00001697          	auipc	a3,0x1
ffffffffc0201680:	46468693          	addi	a3,a3,1124 # ffffffffc0202ae0 <commands+0x990>
ffffffffc0201684:	00001617          	auipc	a2,0x1
ffffffffc0201688:	2d460613          	addi	a2,a2,724 # ffffffffc0202958 <commands+0x808>
ffffffffc020168c:	0e000593          	li	a1,224
ffffffffc0201690:	00001517          	auipc	a0,0x1
ffffffffc0201694:	2e050513          	addi	a0,a0,736 # ffffffffc0202970 <commands+0x820>
ffffffffc0201698:	acbfe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020169c:	00001697          	auipc	a3,0x1
ffffffffc02016a0:	48468693          	addi	a3,a3,1156 # ffffffffc0202b20 <commands+0x9d0>
ffffffffc02016a4:	00001617          	auipc	a2,0x1
ffffffffc02016a8:	2b460613          	addi	a2,a2,692 # ffffffffc0202958 <commands+0x808>
ffffffffc02016ac:	0df00593          	li	a1,223
ffffffffc02016b0:	00001517          	auipc	a0,0x1
ffffffffc02016b4:	2c050513          	addi	a0,a0,704 # ffffffffc0202970 <commands+0x820>
ffffffffc02016b8:	aabfe0ef          	jal	ra,ffffffffc0200162 <__panic>

ffffffffc02016bc <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02016bc:	1141                	addi	sp,sp,-16
ffffffffc02016be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016c0:	14058a63          	beqz	a1,ffffffffc0201814 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc02016c4:	00259693          	slli	a3,a1,0x2
ffffffffc02016c8:	96ae                	add	a3,a3,a1
ffffffffc02016ca:	068e                	slli	a3,a3,0x3
ffffffffc02016cc:	96aa                	add	a3,a3,a0
ffffffffc02016ce:	87aa                	mv	a5,a0
ffffffffc02016d0:	02d50263          	beq	a0,a3,ffffffffc02016f4 <best_fit_free_pages+0x38>
ffffffffc02016d4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016d6:	8b05                	andi	a4,a4,1
ffffffffc02016d8:	10071e63          	bnez	a4,ffffffffc02017f4 <best_fit_free_pages+0x138>
ffffffffc02016dc:	6798                	ld	a4,8(a5)
ffffffffc02016de:	8b09                	andi	a4,a4,2
ffffffffc02016e0:	10071a63          	bnez	a4,ffffffffc02017f4 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc02016e4:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02016e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02016ec:	02878793          	addi	a5,a5,40
ffffffffc02016f0:	fed792e3          	bne	a5,a3,ffffffffc02016d4 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc02016f4:	2581                	sext.w	a1,a1
ffffffffc02016f6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016f8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016fc:	4789                	li	a5,2
ffffffffc02016fe:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201702:	00005697          	auipc	a3,0x5
ffffffffc0201706:	92668693          	addi	a3,a3,-1754 # ffffffffc0206028 <free_area>
ffffffffc020170a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020170c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020170e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201712:	9db9                	addw	a1,a1,a4
ffffffffc0201714:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201716:	0ad78863          	beq	a5,a3,ffffffffc02017c6 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc020171a:	fe878713          	addi	a4,a5,-24
ffffffffc020171e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201722:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201724:	00e56a63          	bltu	a0,a4,ffffffffc0201738 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0201728:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020172a:	06d70263          	beq	a4,a3,ffffffffc020178e <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020172e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201730:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201734:	fee57ae3          	bgeu	a0,a4,ffffffffc0201728 <best_fit_free_pages+0x6c>
ffffffffc0201738:	c199                	beqz	a1,ffffffffc020173e <best_fit_free_pages+0x82>
ffffffffc020173a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020173e:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201740:	e390                	sd	a2,0(a5)
ffffffffc0201742:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201744:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201746:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201748:	02d70063          	beq	a4,a3,ffffffffc0201768 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc020174c:	ff872803          	lw	a6,-8(a4) # fffffffffff7fff8 <end+0x3fd79b60>
        p = le2page(le, page_link);
ffffffffc0201750:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201754:	02081613          	slli	a2,a6,0x20
ffffffffc0201758:	9201                	srli	a2,a2,0x20
ffffffffc020175a:	00261793          	slli	a5,a2,0x2
ffffffffc020175e:	97b2                	add	a5,a5,a2
ffffffffc0201760:	078e                	slli	a5,a5,0x3
ffffffffc0201762:	97ae                	add	a5,a5,a1
ffffffffc0201764:	02f50f63          	beq	a0,a5,ffffffffc02017a2 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0201768:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020176a:	00d70f63          	beq	a4,a3,ffffffffc0201788 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020176e:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201770:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201774:	02059613          	slli	a2,a1,0x20
ffffffffc0201778:	9201                	srli	a2,a2,0x20
ffffffffc020177a:	00261793          	slli	a5,a2,0x2
ffffffffc020177e:	97b2                	add	a5,a5,a2
ffffffffc0201780:	078e                	slli	a5,a5,0x3
ffffffffc0201782:	97aa                	add	a5,a5,a0
ffffffffc0201784:	04f68863          	beq	a3,a5,ffffffffc02017d4 <best_fit_free_pages+0x118>
}
ffffffffc0201788:	60a2                	ld	ra,8(sp)
ffffffffc020178a:	0141                	addi	sp,sp,16
ffffffffc020178c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020178e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201790:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201792:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201794:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201796:	02d70563          	beq	a4,a3,ffffffffc02017c0 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc020179a:	8832                	mv	a6,a2
ffffffffc020179c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020179e:	87ba                	mv	a5,a4
ffffffffc02017a0:	bf41                	j	ffffffffc0201730 <best_fit_free_pages+0x74>
            p->property += base->property;
ffffffffc02017a2:	491c                	lw	a5,16(a0)
ffffffffc02017a4:	0107883b          	addw	a6,a5,a6
ffffffffc02017a8:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017ac:	57f5                	li	a5,-3
ffffffffc02017ae:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017b2:	6d10                	ld	a2,24(a0)
ffffffffc02017b4:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02017b6:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02017b8:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02017ba:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02017bc:	e390                	sd	a2,0(a5)
ffffffffc02017be:	b775                	j	ffffffffc020176a <best_fit_free_pages+0xae>
ffffffffc02017c0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02017c2:	873e                	mv	a4,a5
ffffffffc02017c4:	b761                	j	ffffffffc020174c <best_fit_free_pages+0x90>
}
ffffffffc02017c6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02017c8:	e390                	sd	a2,0(a5)
ffffffffc02017ca:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02017cc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02017ce:	ed1c                	sd	a5,24(a0)
ffffffffc02017d0:	0141                	addi	sp,sp,16
ffffffffc02017d2:	8082                	ret
            base->property += p->property;
ffffffffc02017d4:	ff872783          	lw	a5,-8(a4)
ffffffffc02017d8:	ff070693          	addi	a3,a4,-16
ffffffffc02017dc:	9dbd                	addw	a1,a1,a5
ffffffffc02017de:	c90c                	sw	a1,16(a0)
ffffffffc02017e0:	57f5                	li	a5,-3
ffffffffc02017e2:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017e6:	6314                	ld	a3,0(a4)
ffffffffc02017e8:	671c                	ld	a5,8(a4)
}
ffffffffc02017ea:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017ec:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02017ee:	e394                	sd	a3,0(a5)
ffffffffc02017f0:	0141                	addi	sp,sp,16
ffffffffc02017f2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017f4:	00001697          	auipc	a3,0x1
ffffffffc02017f8:	45468693          	addi	a3,a3,1108 # ffffffffc0202c48 <commands+0xaf8>
ffffffffc02017fc:	00001617          	auipc	a2,0x1
ffffffffc0201800:	15c60613          	addi	a2,a2,348 # ffffffffc0202958 <commands+0x808>
ffffffffc0201804:	08700593          	li	a1,135
ffffffffc0201808:	00001517          	auipc	a0,0x1
ffffffffc020180c:	16850513          	addi	a0,a0,360 # ffffffffc0202970 <commands+0x820>
ffffffffc0201810:	953fe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(n > 0);
ffffffffc0201814:	00001697          	auipc	a3,0x1
ffffffffc0201818:	13c68693          	addi	a3,a3,316 # ffffffffc0202950 <commands+0x800>
ffffffffc020181c:	00001617          	auipc	a2,0x1
ffffffffc0201820:	13c60613          	addi	a2,a2,316 # ffffffffc0202958 <commands+0x808>
ffffffffc0201824:	08400593          	li	a1,132
ffffffffc0201828:	00001517          	auipc	a0,0x1
ffffffffc020182c:	14850513          	addi	a0,a0,328 # ffffffffc0202970 <commands+0x820>
ffffffffc0201830:	933fe0ef          	jal	ra,ffffffffc0200162 <__panic>

ffffffffc0201834 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201834:	1141                	addi	sp,sp,-16
ffffffffc0201836:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201838:	c9e1                	beqz	a1,ffffffffc0201908 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020183a:	00259693          	slli	a3,a1,0x2
ffffffffc020183e:	96ae                	add	a3,a3,a1
ffffffffc0201840:	068e                	slli	a3,a3,0x3
ffffffffc0201842:	96aa                	add	a3,a3,a0
ffffffffc0201844:	87aa                	mv	a5,a0
ffffffffc0201846:	00d50f63          	beq	a0,a3,ffffffffc0201864 <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020184a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc020184c:	8b05                	andi	a4,a4,1
ffffffffc020184e:	cf49                	beqz	a4,ffffffffc02018e8 <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc0201850:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201854:	0007a823          	sw	zero,16(a5)
ffffffffc0201858:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020185c:	02878793          	addi	a5,a5,40
ffffffffc0201860:	fed795e3          	bne	a5,a3,ffffffffc020184a <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0201864:	2581                	sext.w	a1,a1
ffffffffc0201866:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201868:	4789                	li	a5,2
ffffffffc020186a:	00850713          	addi	a4,a0,8
ffffffffc020186e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201872:	00004697          	auipc	a3,0x4
ffffffffc0201876:	7b668693          	addi	a3,a3,1974 # ffffffffc0206028 <free_area>
ffffffffc020187a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020187c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020187e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201882:	9db9                	addw	a1,a1,a4
ffffffffc0201884:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201886:	04d78a63          	beq	a5,a3,ffffffffc02018da <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc020188a:	fe878713          	addi	a4,a5,-24
ffffffffc020188e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201892:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201894:	00e56a63          	bltu	a0,a4,ffffffffc02018a8 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201898:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020189a:	02d70263          	beq	a4,a3,ffffffffc02018be <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc020189e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018a0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018a4:	fee57ae3          	bgeu	a0,a4,ffffffffc0201898 <best_fit_init_memmap+0x64>
ffffffffc02018a8:	c199                	beqz	a1,ffffffffc02018ae <best_fit_init_memmap+0x7a>
ffffffffc02018aa:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018ae:	6398                	ld	a4,0(a5)
}
ffffffffc02018b0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02018b2:	e390                	sd	a2,0(a5)
ffffffffc02018b4:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02018b6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018b8:	ed18                	sd	a4,24(a0)
ffffffffc02018ba:	0141                	addi	sp,sp,16
ffffffffc02018bc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02018be:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018c0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02018c2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02018c4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018c6:	00d70663          	beq	a4,a3,ffffffffc02018d2 <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02018ca:	8832                	mv	a6,a2
ffffffffc02018cc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02018ce:	87ba                	mv	a5,a4
ffffffffc02018d0:	bfc1                	j	ffffffffc02018a0 <best_fit_init_memmap+0x6c>
}
ffffffffc02018d2:	60a2                	ld	ra,8(sp)
ffffffffc02018d4:	e290                	sd	a2,0(a3)
ffffffffc02018d6:	0141                	addi	sp,sp,16
ffffffffc02018d8:	8082                	ret
ffffffffc02018da:	60a2                	ld	ra,8(sp)
ffffffffc02018dc:	e390                	sd	a2,0(a5)
ffffffffc02018de:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018e0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018e2:	ed1c                	sd	a5,24(a0)
ffffffffc02018e4:	0141                	addi	sp,sp,16
ffffffffc02018e6:	8082                	ret
        assert(PageReserved(p));
ffffffffc02018e8:	00001697          	auipc	a3,0x1
ffffffffc02018ec:	38868693          	addi	a3,a3,904 # ffffffffc0202c70 <commands+0xb20>
ffffffffc02018f0:	00001617          	auipc	a2,0x1
ffffffffc02018f4:	06860613          	addi	a2,a2,104 # ffffffffc0202958 <commands+0x808>
ffffffffc02018f8:	04a00593          	li	a1,74
ffffffffc02018fc:	00001517          	auipc	a0,0x1
ffffffffc0201900:	07450513          	addi	a0,a0,116 # ffffffffc0202970 <commands+0x820>
ffffffffc0201904:	85ffe0ef          	jal	ra,ffffffffc0200162 <__panic>
    assert(n > 0);
ffffffffc0201908:	00001697          	auipc	a3,0x1
ffffffffc020190c:	04868693          	addi	a3,a3,72 # ffffffffc0202950 <commands+0x800>
ffffffffc0201910:	00001617          	auipc	a2,0x1
ffffffffc0201914:	04860613          	addi	a2,a2,72 # ffffffffc0202958 <commands+0x808>
ffffffffc0201918:	04700593          	li	a1,71
ffffffffc020191c:	00001517          	auipc	a0,0x1
ffffffffc0201920:	05450513          	addi	a0,a0,84 # ffffffffc0202970 <commands+0x820>
ffffffffc0201924:	83ffe0ef          	jal	ra,ffffffffc0200162 <__panic>

ffffffffc0201928 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201928:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020192c:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020192e:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201930:	cb81                	beqz	a5,ffffffffc0201940 <strlen+0x18>
        cnt ++;
ffffffffc0201932:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0201934:	00a707b3          	add	a5,a4,a0
ffffffffc0201938:	0007c783          	lbu	a5,0(a5)
ffffffffc020193c:	fbfd                	bnez	a5,ffffffffc0201932 <strlen+0xa>
ffffffffc020193e:	8082                	ret
    }
    return cnt;
}
ffffffffc0201940:	8082                	ret

ffffffffc0201942 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201942:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201944:	e589                	bnez	a1,ffffffffc020194e <strnlen+0xc>
ffffffffc0201946:	a811                	j	ffffffffc020195a <strnlen+0x18>
        cnt ++;
ffffffffc0201948:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020194a:	00f58863          	beq	a1,a5,ffffffffc020195a <strnlen+0x18>
ffffffffc020194e:	00f50733          	add	a4,a0,a5
ffffffffc0201952:	00074703          	lbu	a4,0(a4)
ffffffffc0201956:	fb6d                	bnez	a4,ffffffffc0201948 <strnlen+0x6>
ffffffffc0201958:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020195a:	852e                	mv	a0,a1
ffffffffc020195c:	8082                	ret

ffffffffc020195e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020195e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201962:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201966:	cb89                	beqz	a5,ffffffffc0201978 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201968:	0505                	addi	a0,a0,1
ffffffffc020196a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020196c:	fee789e3          	beq	a5,a4,ffffffffc020195e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201970:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201974:	9d19                	subw	a0,a0,a4
ffffffffc0201976:	8082                	ret
ffffffffc0201978:	4501                	li	a0,0
ffffffffc020197a:	bfed                	j	ffffffffc0201974 <strcmp+0x16>

ffffffffc020197c <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020197c:	c20d                	beqz	a2,ffffffffc020199e <strncmp+0x22>
ffffffffc020197e:	962e                	add	a2,a2,a1
ffffffffc0201980:	a031                	j	ffffffffc020198c <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201982:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201984:	00e79a63          	bne	a5,a4,ffffffffc0201998 <strncmp+0x1c>
ffffffffc0201988:	00b60b63          	beq	a2,a1,ffffffffc020199e <strncmp+0x22>
ffffffffc020198c:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201990:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201992:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201996:	f7f5                	bnez	a5,ffffffffc0201982 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201998:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020199c:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020199e:	4501                	li	a0,0
ffffffffc02019a0:	8082                	ret

ffffffffc02019a2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019a2:	00054783          	lbu	a5,0(a0)
ffffffffc02019a6:	c799                	beqz	a5,ffffffffc02019b4 <strchr+0x12>
        if (*s == c) {
ffffffffc02019a8:	00f58763          	beq	a1,a5,ffffffffc02019b6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02019ac:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019b0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019b2:	fbfd                	bnez	a5,ffffffffc02019a8 <strchr+0x6>
    }
    return NULL;
ffffffffc02019b4:	4501                	li	a0,0
}
ffffffffc02019b6:	8082                	ret

ffffffffc02019b8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019b8:	ca01                	beqz	a2,ffffffffc02019c8 <memset+0x10>
ffffffffc02019ba:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019bc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019be:	0785                	addi	a5,a5,1
ffffffffc02019c0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019c4:	fec79de3          	bne	a5,a2,ffffffffc02019be <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019c8:	8082                	ret

ffffffffc02019ca <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02019ca:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019ce:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02019d0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019d4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02019d6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02019da:	f022                	sd	s0,32(sp)
ffffffffc02019dc:	ec26                	sd	s1,24(sp)
ffffffffc02019de:	e84a                	sd	s2,16(sp)
ffffffffc02019e0:	f406                	sd	ra,40(sp)
ffffffffc02019e2:	e44e                	sd	s3,8(sp)
ffffffffc02019e4:	84aa                	mv	s1,a0
ffffffffc02019e6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02019e8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02019ec:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02019ee:	03067e63          	bgeu	a2,a6,ffffffffc0201a2a <printnum+0x60>
ffffffffc02019f2:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02019f4:	00805763          	blez	s0,ffffffffc0201a02 <printnum+0x38>
ffffffffc02019f8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02019fa:	85ca                	mv	a1,s2
ffffffffc02019fc:	854e                	mv	a0,s3
ffffffffc02019fe:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201a00:	fc65                	bnez	s0,ffffffffc02019f8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a02:	1a02                	slli	s4,s4,0x20
ffffffffc0201a04:	00001797          	auipc	a5,0x1
ffffffffc0201a08:	2cc78793          	addi	a5,a5,716 # ffffffffc0202cd0 <best_fit_pmm_manager+0x38>
ffffffffc0201a0c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201a10:	9a3e                	add	s4,s4,a5
}
ffffffffc0201a12:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a14:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201a18:	70a2                	ld	ra,40(sp)
ffffffffc0201a1a:	69a2                	ld	s3,8(sp)
ffffffffc0201a1c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a1e:	85ca                	mv	a1,s2
ffffffffc0201a20:	87a6                	mv	a5,s1
}
ffffffffc0201a22:	6942                	ld	s2,16(sp)
ffffffffc0201a24:	64e2                	ld	s1,24(sp)
ffffffffc0201a26:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a28:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201a2a:	03065633          	divu	a2,a2,a6
ffffffffc0201a2e:	8722                	mv	a4,s0
ffffffffc0201a30:	f9bff0ef          	jal	ra,ffffffffc02019ca <printnum>
ffffffffc0201a34:	b7f9                	j	ffffffffc0201a02 <printnum+0x38>

ffffffffc0201a36 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201a36:	7119                	addi	sp,sp,-128
ffffffffc0201a38:	f4a6                	sd	s1,104(sp)
ffffffffc0201a3a:	f0ca                	sd	s2,96(sp)
ffffffffc0201a3c:	ecce                	sd	s3,88(sp)
ffffffffc0201a3e:	e8d2                	sd	s4,80(sp)
ffffffffc0201a40:	e4d6                	sd	s5,72(sp)
ffffffffc0201a42:	e0da                	sd	s6,64(sp)
ffffffffc0201a44:	fc5e                	sd	s7,56(sp)
ffffffffc0201a46:	f06a                	sd	s10,32(sp)
ffffffffc0201a48:	fc86                	sd	ra,120(sp)
ffffffffc0201a4a:	f8a2                	sd	s0,112(sp)
ffffffffc0201a4c:	f862                	sd	s8,48(sp)
ffffffffc0201a4e:	f466                	sd	s9,40(sp)
ffffffffc0201a50:	ec6e                	sd	s11,24(sp)
ffffffffc0201a52:	892a                	mv	s2,a0
ffffffffc0201a54:	84ae                	mv	s1,a1
ffffffffc0201a56:	8d32                	mv	s10,a2
ffffffffc0201a58:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a5a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201a5e:	5b7d                	li	s6,-1
ffffffffc0201a60:	00001a97          	auipc	s5,0x1
ffffffffc0201a64:	2a4a8a93          	addi	s5,s5,676 # ffffffffc0202d04 <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a68:	00001b97          	auipc	s7,0x1
ffffffffc0201a6c:	478b8b93          	addi	s7,s7,1144 # ffffffffc0202ee0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a70:	000d4503          	lbu	a0,0(s10)
ffffffffc0201a74:	001d0413          	addi	s0,s10,1
ffffffffc0201a78:	01350a63          	beq	a0,s3,ffffffffc0201a8c <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201a7c:	c121                	beqz	a0,ffffffffc0201abc <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201a7e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a80:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201a82:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a84:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201a88:	ff351ae3          	bne	a0,s3,ffffffffc0201a7c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a8c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201a90:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201a94:	4c81                	li	s9,0
ffffffffc0201a96:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201a98:	5c7d                	li	s8,-1
ffffffffc0201a9a:	5dfd                	li	s11,-1
ffffffffc0201a9c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201aa0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aa2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201aa6:	0ff5f593          	zext.b	a1,a1
ffffffffc0201aaa:	00140d13          	addi	s10,s0,1
ffffffffc0201aae:	04b56263          	bltu	a0,a1,ffffffffc0201af2 <vprintfmt+0xbc>
ffffffffc0201ab2:	058a                	slli	a1,a1,0x2
ffffffffc0201ab4:	95d6                	add	a1,a1,s5
ffffffffc0201ab6:	4194                	lw	a3,0(a1)
ffffffffc0201ab8:	96d6                	add	a3,a3,s5
ffffffffc0201aba:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201abc:	70e6                	ld	ra,120(sp)
ffffffffc0201abe:	7446                	ld	s0,112(sp)
ffffffffc0201ac0:	74a6                	ld	s1,104(sp)
ffffffffc0201ac2:	7906                	ld	s2,96(sp)
ffffffffc0201ac4:	69e6                	ld	s3,88(sp)
ffffffffc0201ac6:	6a46                	ld	s4,80(sp)
ffffffffc0201ac8:	6aa6                	ld	s5,72(sp)
ffffffffc0201aca:	6b06                	ld	s6,64(sp)
ffffffffc0201acc:	7be2                	ld	s7,56(sp)
ffffffffc0201ace:	7c42                	ld	s8,48(sp)
ffffffffc0201ad0:	7ca2                	ld	s9,40(sp)
ffffffffc0201ad2:	7d02                	ld	s10,32(sp)
ffffffffc0201ad4:	6de2                	ld	s11,24(sp)
ffffffffc0201ad6:	6109                	addi	sp,sp,128
ffffffffc0201ad8:	8082                	ret
            padc = '0';
ffffffffc0201ada:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201adc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ae0:	846a                	mv	s0,s10
ffffffffc0201ae2:	00140d13          	addi	s10,s0,1
ffffffffc0201ae6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201aea:	0ff5f593          	zext.b	a1,a1
ffffffffc0201aee:	fcb572e3          	bgeu	a0,a1,ffffffffc0201ab2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201af2:	85a6                	mv	a1,s1
ffffffffc0201af4:	02500513          	li	a0,37
ffffffffc0201af8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201afa:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201afe:	8d22                	mv	s10,s0
ffffffffc0201b00:	f73788e3          	beq	a5,s3,ffffffffc0201a70 <vprintfmt+0x3a>
ffffffffc0201b04:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201b08:	1d7d                	addi	s10,s10,-1
ffffffffc0201b0a:	ff379de3          	bne	a5,s3,ffffffffc0201b04 <vprintfmt+0xce>
ffffffffc0201b0e:	b78d                	j	ffffffffc0201a70 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201b10:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201b14:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b18:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201b1a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201b1e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b22:	02d86463          	bltu	a6,a3,ffffffffc0201b4a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201b26:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201b2a:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201b2e:	0186873b          	addw	a4,a3,s8
ffffffffc0201b32:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201b36:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201b38:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201b3c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201b3e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201b42:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201b46:	fed870e3          	bgeu	a6,a3,ffffffffc0201b26 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201b4a:	f40ddce3          	bgez	s11,ffffffffc0201aa2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201b4e:	8de2                	mv	s11,s8
ffffffffc0201b50:	5c7d                	li	s8,-1
ffffffffc0201b52:	bf81                	j	ffffffffc0201aa2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201b54:	fffdc693          	not	a3,s11
ffffffffc0201b58:	96fd                	srai	a3,a3,0x3f
ffffffffc0201b5a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b5e:	00144603          	lbu	a2,1(s0)
ffffffffc0201b62:	2d81                	sext.w	s11,s11
ffffffffc0201b64:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b66:	bf35                	j	ffffffffc0201aa2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201b68:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b6c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201b70:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b72:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201b74:	bfd9                	j	ffffffffc0201b4a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201b76:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b78:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b7c:	01174463          	blt	a4,a7,ffffffffc0201b84 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201b80:	1a088e63          	beqz	a7,ffffffffc0201d3c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201b84:	000a3603          	ld	a2,0(s4)
ffffffffc0201b88:	46c1                	li	a3,16
ffffffffc0201b8a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201b8c:	2781                	sext.w	a5,a5
ffffffffc0201b8e:	876e                	mv	a4,s11
ffffffffc0201b90:	85a6                	mv	a1,s1
ffffffffc0201b92:	854a                	mv	a0,s2
ffffffffc0201b94:	e37ff0ef          	jal	ra,ffffffffc02019ca <printnum>
            break;
ffffffffc0201b98:	bde1                	j	ffffffffc0201a70 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b9a:	000a2503          	lw	a0,0(s4)
ffffffffc0201b9e:	85a6                	mv	a1,s1
ffffffffc0201ba0:	0a21                	addi	s4,s4,8
ffffffffc0201ba2:	9902                	jalr	s2
            break;
ffffffffc0201ba4:	b5f1                	j	ffffffffc0201a70 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201ba6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201ba8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201bac:	01174463          	blt	a4,a7,ffffffffc0201bb4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201bb0:	18088163          	beqz	a7,ffffffffc0201d32 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201bb4:	000a3603          	ld	a2,0(s4)
ffffffffc0201bb8:	46a9                	li	a3,10
ffffffffc0201bba:	8a2e                	mv	s4,a1
ffffffffc0201bbc:	bfc1                	j	ffffffffc0201b8c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bbe:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201bc2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bc4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201bc6:	bdf1                	j	ffffffffc0201aa2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201bc8:	85a6                	mv	a1,s1
ffffffffc0201bca:	02500513          	li	a0,37
ffffffffc0201bce:	9902                	jalr	s2
            break;
ffffffffc0201bd0:	b545                	j	ffffffffc0201a70 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bd2:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201bd6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bd8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201bda:	b5e1                	j	ffffffffc0201aa2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201bdc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201bde:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201be2:	01174463          	blt	a4,a7,ffffffffc0201bea <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201be6:	14088163          	beqz	a7,ffffffffc0201d28 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201bea:	000a3603          	ld	a2,0(s4)
ffffffffc0201bee:	46a1                	li	a3,8
ffffffffc0201bf0:	8a2e                	mv	s4,a1
ffffffffc0201bf2:	bf69                	j	ffffffffc0201b8c <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201bf4:	03000513          	li	a0,48
ffffffffc0201bf8:	85a6                	mv	a1,s1
ffffffffc0201bfa:	e03e                	sd	a5,0(sp)
ffffffffc0201bfc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201bfe:	85a6                	mv	a1,s1
ffffffffc0201c00:	07800513          	li	a0,120
ffffffffc0201c04:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201c06:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201c08:	6782                	ld	a5,0(sp)
ffffffffc0201c0a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201c0c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201c10:	bfb5                	j	ffffffffc0201b8c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c12:	000a3403          	ld	s0,0(s4)
ffffffffc0201c16:	008a0713          	addi	a4,s4,8
ffffffffc0201c1a:	e03a                	sd	a4,0(sp)
ffffffffc0201c1c:	14040263          	beqz	s0,ffffffffc0201d60 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201c20:	0fb05763          	blez	s11,ffffffffc0201d0e <vprintfmt+0x2d8>
ffffffffc0201c24:	02d00693          	li	a3,45
ffffffffc0201c28:	0cd79163          	bne	a5,a3,ffffffffc0201cea <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c2c:	00044783          	lbu	a5,0(s0)
ffffffffc0201c30:	0007851b          	sext.w	a0,a5
ffffffffc0201c34:	cf85                	beqz	a5,ffffffffc0201c6c <vprintfmt+0x236>
ffffffffc0201c36:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c3a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c3e:	000c4563          	bltz	s8,ffffffffc0201c48 <vprintfmt+0x212>
ffffffffc0201c42:	3c7d                	addiw	s8,s8,-1
ffffffffc0201c44:	036c0263          	beq	s8,s6,ffffffffc0201c68 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201c48:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c4a:	0e0c8e63          	beqz	s9,ffffffffc0201d46 <vprintfmt+0x310>
ffffffffc0201c4e:	3781                	addiw	a5,a5,-32
ffffffffc0201c50:	0ef47b63          	bgeu	s0,a5,ffffffffc0201d46 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201c54:	03f00513          	li	a0,63
ffffffffc0201c58:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c5a:	000a4783          	lbu	a5,0(s4)
ffffffffc0201c5e:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c60:	0a05                	addi	s4,s4,1
ffffffffc0201c62:	0007851b          	sext.w	a0,a5
ffffffffc0201c66:	ffe1                	bnez	a5,ffffffffc0201c3e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201c68:	01b05963          	blez	s11,ffffffffc0201c7a <vprintfmt+0x244>
ffffffffc0201c6c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c6e:	85a6                	mv	a1,s1
ffffffffc0201c70:	02000513          	li	a0,32
ffffffffc0201c74:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c76:	fe0d9be3          	bnez	s11,ffffffffc0201c6c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c7a:	6a02                	ld	s4,0(sp)
ffffffffc0201c7c:	bbd5                	j	ffffffffc0201a70 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c7e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c80:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201c84:	01174463          	blt	a4,a7,ffffffffc0201c8c <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201c88:	08088d63          	beqz	a7,ffffffffc0201d22 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201c8c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c90:	0a044d63          	bltz	s0,ffffffffc0201d4a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201c94:	8622                	mv	a2,s0
ffffffffc0201c96:	8a66                	mv	s4,s9
ffffffffc0201c98:	46a9                	li	a3,10
ffffffffc0201c9a:	bdcd                	j	ffffffffc0201b8c <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201c9c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201ca0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201ca2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201ca4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201ca8:	8fb5                	xor	a5,a5,a3
ffffffffc0201caa:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201cae:	02d74163          	blt	a4,a3,ffffffffc0201cd0 <vprintfmt+0x29a>
ffffffffc0201cb2:	00369793          	slli	a5,a3,0x3
ffffffffc0201cb6:	97de                	add	a5,a5,s7
ffffffffc0201cb8:	639c                	ld	a5,0(a5)
ffffffffc0201cba:	cb99                	beqz	a5,ffffffffc0201cd0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201cbc:	86be                	mv	a3,a5
ffffffffc0201cbe:	00001617          	auipc	a2,0x1
ffffffffc0201cc2:	04260613          	addi	a2,a2,66 # ffffffffc0202d00 <best_fit_pmm_manager+0x68>
ffffffffc0201cc6:	85a6                	mv	a1,s1
ffffffffc0201cc8:	854a                	mv	a0,s2
ffffffffc0201cca:	0ce000ef          	jal	ra,ffffffffc0201d98 <printfmt>
ffffffffc0201cce:	b34d                	j	ffffffffc0201a70 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201cd0:	00001617          	auipc	a2,0x1
ffffffffc0201cd4:	02060613          	addi	a2,a2,32 # ffffffffc0202cf0 <best_fit_pmm_manager+0x58>
ffffffffc0201cd8:	85a6                	mv	a1,s1
ffffffffc0201cda:	854a                	mv	a0,s2
ffffffffc0201cdc:	0bc000ef          	jal	ra,ffffffffc0201d98 <printfmt>
ffffffffc0201ce0:	bb41                	j	ffffffffc0201a70 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201ce2:	00001417          	auipc	s0,0x1
ffffffffc0201ce6:	00640413          	addi	s0,s0,6 # ffffffffc0202ce8 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cea:	85e2                	mv	a1,s8
ffffffffc0201cec:	8522                	mv	a0,s0
ffffffffc0201cee:	e43e                	sd	a5,8(sp)
ffffffffc0201cf0:	c53ff0ef          	jal	ra,ffffffffc0201942 <strnlen>
ffffffffc0201cf4:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201cf8:	01b05b63          	blez	s11,ffffffffc0201d0e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201cfc:	67a2                	ld	a5,8(sp)
ffffffffc0201cfe:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201d02:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201d04:	85a6                	mv	a1,s1
ffffffffc0201d06:	8552                	mv	a0,s4
ffffffffc0201d08:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201d0a:	fe0d9ce3          	bnez	s11,ffffffffc0201d02 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d0e:	00044783          	lbu	a5,0(s0)
ffffffffc0201d12:	00140a13          	addi	s4,s0,1
ffffffffc0201d16:	0007851b          	sext.w	a0,a5
ffffffffc0201d1a:	d3a5                	beqz	a5,ffffffffc0201c7a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d1c:	05e00413          	li	s0,94
ffffffffc0201d20:	bf39                	j	ffffffffc0201c3e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201d22:	000a2403          	lw	s0,0(s4)
ffffffffc0201d26:	b7ad                	j	ffffffffc0201c90 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201d28:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d2c:	46a1                	li	a3,8
ffffffffc0201d2e:	8a2e                	mv	s4,a1
ffffffffc0201d30:	bdb1                	j	ffffffffc0201b8c <vprintfmt+0x156>
ffffffffc0201d32:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d36:	46a9                	li	a3,10
ffffffffc0201d38:	8a2e                	mv	s4,a1
ffffffffc0201d3a:	bd89                	j	ffffffffc0201b8c <vprintfmt+0x156>
ffffffffc0201d3c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d40:	46c1                	li	a3,16
ffffffffc0201d42:	8a2e                	mv	s4,a1
ffffffffc0201d44:	b5a1                	j	ffffffffc0201b8c <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201d46:	9902                	jalr	s2
ffffffffc0201d48:	bf09                	j	ffffffffc0201c5a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201d4a:	85a6                	mv	a1,s1
ffffffffc0201d4c:	02d00513          	li	a0,45
ffffffffc0201d50:	e03e                	sd	a5,0(sp)
ffffffffc0201d52:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201d54:	6782                	ld	a5,0(sp)
ffffffffc0201d56:	8a66                	mv	s4,s9
ffffffffc0201d58:	40800633          	neg	a2,s0
ffffffffc0201d5c:	46a9                	li	a3,10
ffffffffc0201d5e:	b53d                	j	ffffffffc0201b8c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201d60:	03b05163          	blez	s11,ffffffffc0201d82 <vprintfmt+0x34c>
ffffffffc0201d64:	02d00693          	li	a3,45
ffffffffc0201d68:	f6d79de3          	bne	a5,a3,ffffffffc0201ce2 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201d6c:	00001417          	auipc	s0,0x1
ffffffffc0201d70:	f7c40413          	addi	s0,s0,-132 # ffffffffc0202ce8 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d74:	02800793          	li	a5,40
ffffffffc0201d78:	02800513          	li	a0,40
ffffffffc0201d7c:	00140a13          	addi	s4,s0,1
ffffffffc0201d80:	bd6d                	j	ffffffffc0201c3a <vprintfmt+0x204>
ffffffffc0201d82:	00001a17          	auipc	s4,0x1
ffffffffc0201d86:	f67a0a13          	addi	s4,s4,-153 # ffffffffc0202ce9 <best_fit_pmm_manager+0x51>
ffffffffc0201d8a:	02800513          	li	a0,40
ffffffffc0201d8e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d92:	05e00413          	li	s0,94
ffffffffc0201d96:	b565                	j	ffffffffc0201c3e <vprintfmt+0x208>

ffffffffc0201d98 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d98:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201d9a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d9e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201da0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201da2:	ec06                	sd	ra,24(sp)
ffffffffc0201da4:	f83a                	sd	a4,48(sp)
ffffffffc0201da6:	fc3e                	sd	a5,56(sp)
ffffffffc0201da8:	e0c2                	sd	a6,64(sp)
ffffffffc0201daa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201dac:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201dae:	c89ff0ef          	jal	ra,ffffffffc0201a36 <vprintfmt>
}
ffffffffc0201db2:	60e2                	ld	ra,24(sp)
ffffffffc0201db4:	6161                	addi	sp,sp,80
ffffffffc0201db6:	8082                	ret

ffffffffc0201db8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201db8:	715d                	addi	sp,sp,-80
ffffffffc0201dba:	e486                	sd	ra,72(sp)
ffffffffc0201dbc:	e0a6                	sd	s1,64(sp)
ffffffffc0201dbe:	fc4a                	sd	s2,56(sp)
ffffffffc0201dc0:	f84e                	sd	s3,48(sp)
ffffffffc0201dc2:	f452                	sd	s4,40(sp)
ffffffffc0201dc4:	f056                	sd	s5,32(sp)
ffffffffc0201dc6:	ec5a                	sd	s6,24(sp)
ffffffffc0201dc8:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201dca:	c901                	beqz	a0,ffffffffc0201dda <readline+0x22>
ffffffffc0201dcc:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201dce:	00001517          	auipc	a0,0x1
ffffffffc0201dd2:	f3250513          	addi	a0,a0,-206 # ffffffffc0202d00 <best_fit_pmm_manager+0x68>
ffffffffc0201dd6:	b04fe0ef          	jal	ra,ffffffffc02000da <cprintf>
readline(const char *prompt) {
ffffffffc0201dda:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201ddc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201dde:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201de0:	4aa9                	li	s5,10
ffffffffc0201de2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201de4:	00004b97          	auipc	s7,0x4
ffffffffc0201de8:	25cb8b93          	addi	s7,s7,604 # ffffffffc0206040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201dec:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201df0:	b62fe0ef          	jal	ra,ffffffffc0200152 <getchar>
        if (c < 0) {
ffffffffc0201df4:	00054a63          	bltz	a0,ffffffffc0201e08 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201df8:	00a95a63          	bge	s2,a0,ffffffffc0201e0c <readline+0x54>
ffffffffc0201dfc:	029a5263          	bge	s4,s1,ffffffffc0201e20 <readline+0x68>
        c = getchar();
ffffffffc0201e00:	b52fe0ef          	jal	ra,ffffffffc0200152 <getchar>
        if (c < 0) {
ffffffffc0201e04:	fe055ae3          	bgez	a0,ffffffffc0201df8 <readline+0x40>
            return NULL;
ffffffffc0201e08:	4501                	li	a0,0
ffffffffc0201e0a:	a091                	j	ffffffffc0201e4e <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201e0c:	03351463          	bne	a0,s3,ffffffffc0201e34 <readline+0x7c>
ffffffffc0201e10:	e8a9                	bnez	s1,ffffffffc0201e62 <readline+0xaa>
        c = getchar();
ffffffffc0201e12:	b40fe0ef          	jal	ra,ffffffffc0200152 <getchar>
        if (c < 0) {
ffffffffc0201e16:	fe0549e3          	bltz	a0,ffffffffc0201e08 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e1a:	fea959e3          	bge	s2,a0,ffffffffc0201e0c <readline+0x54>
ffffffffc0201e1e:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201e20:	e42a                	sd	a0,8(sp)
ffffffffc0201e22:	aeefe0ef          	jal	ra,ffffffffc0200110 <cputchar>
            buf[i ++] = c;
ffffffffc0201e26:	6522                	ld	a0,8(sp)
ffffffffc0201e28:	009b87b3          	add	a5,s7,s1
ffffffffc0201e2c:	2485                	addiw	s1,s1,1
ffffffffc0201e2e:	00a78023          	sb	a0,0(a5)
ffffffffc0201e32:	bf7d                	j	ffffffffc0201df0 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201e34:	01550463          	beq	a0,s5,ffffffffc0201e3c <readline+0x84>
ffffffffc0201e38:	fb651ce3          	bne	a0,s6,ffffffffc0201df0 <readline+0x38>
            cputchar(c);
ffffffffc0201e3c:	ad4fe0ef          	jal	ra,ffffffffc0200110 <cputchar>
            buf[i] = '\0';
ffffffffc0201e40:	00004517          	auipc	a0,0x4
ffffffffc0201e44:	20050513          	addi	a0,a0,512 # ffffffffc0206040 <buf>
ffffffffc0201e48:	94aa                	add	s1,s1,a0
ffffffffc0201e4a:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201e4e:	60a6                	ld	ra,72(sp)
ffffffffc0201e50:	6486                	ld	s1,64(sp)
ffffffffc0201e52:	7962                	ld	s2,56(sp)
ffffffffc0201e54:	79c2                	ld	s3,48(sp)
ffffffffc0201e56:	7a22                	ld	s4,40(sp)
ffffffffc0201e58:	7a82                	ld	s5,32(sp)
ffffffffc0201e5a:	6b62                	ld	s6,24(sp)
ffffffffc0201e5c:	6bc2                	ld	s7,16(sp)
ffffffffc0201e5e:	6161                	addi	sp,sp,80
ffffffffc0201e60:	8082                	ret
            cputchar(c);
ffffffffc0201e62:	4521                	li	a0,8
ffffffffc0201e64:	aacfe0ef          	jal	ra,ffffffffc0200110 <cputchar>
            i --;
ffffffffc0201e68:	34fd                	addiw	s1,s1,-1
ffffffffc0201e6a:	b759                	j	ffffffffc0201df0 <readline+0x38>

ffffffffc0201e6c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201e6c:	4781                	li	a5,0
ffffffffc0201e6e:	00004717          	auipc	a4,0x4
ffffffffc0201e72:	1aa73703          	ld	a4,426(a4) # ffffffffc0206018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201e76:	88ba                	mv	a7,a4
ffffffffc0201e78:	852a                	mv	a0,a0
ffffffffc0201e7a:	85be                	mv	a1,a5
ffffffffc0201e7c:	863e                	mv	a2,a5
ffffffffc0201e7e:	00000073          	ecall
ffffffffc0201e82:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201e84:	8082                	ret

ffffffffc0201e86 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201e86:	4781                	li	a5,0
ffffffffc0201e88:	00004717          	auipc	a4,0x4
ffffffffc0201e8c:	60873703          	ld	a4,1544(a4) # ffffffffc0206490 <SBI_SET_TIMER>
ffffffffc0201e90:	88ba                	mv	a7,a4
ffffffffc0201e92:	852a                	mv	a0,a0
ffffffffc0201e94:	85be                	mv	a1,a5
ffffffffc0201e96:	863e                	mv	a2,a5
ffffffffc0201e98:	00000073          	ecall
ffffffffc0201e9c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201e9e:	8082                	ret

ffffffffc0201ea0 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201ea0:	4501                	li	a0,0
ffffffffc0201ea2:	00004797          	auipc	a5,0x4
ffffffffc0201ea6:	16e7b783          	ld	a5,366(a5) # ffffffffc0206010 <SBI_CONSOLE_GETCHAR>
ffffffffc0201eaa:	88be                	mv	a7,a5
ffffffffc0201eac:	852a                	mv	a0,a0
ffffffffc0201eae:	85aa                	mv	a1,a0
ffffffffc0201eb0:	862a                	mv	a2,a0
ffffffffc0201eb2:	00000073          	ecall
ffffffffc0201eb6:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201eb8:	2501                	sext.w	a0,a0
ffffffffc0201eba:	8082                	ret

ffffffffc0201ebc <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201ebc:	4781                	li	a5,0
ffffffffc0201ebe:	00004717          	auipc	a4,0x4
ffffffffc0201ec2:	16273703          	ld	a4,354(a4) # ffffffffc0206020 <SBI_SHUTDOWN>
ffffffffc0201ec6:	88ba                	mv	a7,a4
ffffffffc0201ec8:	853e                	mv	a0,a5
ffffffffc0201eca:	85be                	mv	a1,a5
ffffffffc0201ecc:	863e                	mv	a2,a5
ffffffffc0201ece:	00000073          	ecall
ffffffffc0201ed2:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201ed4:	8082                	ret
