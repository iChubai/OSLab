
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000c297          	auipc	t0,0xc
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020c000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000c297          	auipc	t0,0xc
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020c008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc020003c:	c020b137          	lui	sp,0xc020b

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000c3517          	auipc	a0,0xc3
ffffffffc020004e:	86e50513          	addi	a0,a0,-1938 # ffffffffc02c28b8 <buf>
ffffffffc0200052:	000c7617          	auipc	a2,0xc7
ffffffffc0200056:	d4e60613          	addi	a2,a2,-690 # ffffffffc02c6da0 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	556050ef          	jal	ra,ffffffffc02055b8 <memset>
    cons_init(); // init the console
ffffffffc0200066:	0d5000ef          	jal	ra,ffffffffc020093a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	97e58593          	addi	a1,a1,-1666 # ffffffffc02059e8 <etext+0x2>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	99650513          	addi	a0,a0,-1642 # ffffffffc0205a08 <etext+0x22>
ffffffffc020007a:	06a000ef          	jal	ra,ffffffffc02000e4 <cprintf>

    print_kerninfo();
ffffffffc020007e:	250000ef          	jal	ra,ffffffffc02002ce <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	4be000ef          	jal	ra,ffffffffc0200540 <dtb_init>

    pmm_init(); // init physical memory management
ffffffffc0200086:	7db020ef          	jal	ra,ffffffffc0203060 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	123000ef          	jal	ra,ffffffffc02009ac <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	12d000ef          	jal	ra,ffffffffc02009ba <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	4ba010ef          	jal	ra,ffffffffc020154c <vmm_init>
    sched_init();
ffffffffc0200096:	13a050ef          	jal	ra,ffffffffc02051d0 <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	723040ef          	jal	ra,ffffffffc0204fbc <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	053000ef          	jal	ra,ffffffffc02008f0 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	10d000ef          	jal	ra,ffffffffc02009ae <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	0ae050ef          	jal	ra,ffffffffc0205154 <cpu_idle>

ffffffffc02000aa <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc02000aa:	1141                	addi	sp,sp,-16
ffffffffc02000ac:	e022                	sd	s0,0(sp)
ffffffffc02000ae:	e406                	sd	ra,8(sp)
ffffffffc02000b0:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000b2:	08b000ef          	jal	ra,ffffffffc020093c <cons_putc>
    (*cnt)++;
ffffffffc02000b6:	401c                	lw	a5,0(s0)
}
ffffffffc02000b8:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc02000ba:	2785                	addiw	a5,a5,1
ffffffffc02000bc:	c01c                	sw	a5,0(s0)
}
ffffffffc02000be:	6402                	ld	s0,0(sp)
ffffffffc02000c0:	0141                	addi	sp,sp,16
ffffffffc02000c2:	8082                	ret

ffffffffc02000c4 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc02000c4:	1101                	addi	sp,sp,-32
ffffffffc02000c6:	862a                	mv	a2,a0
ffffffffc02000c8:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	00000517          	auipc	a0,0x0
ffffffffc02000ce:	fe050513          	addi	a0,a0,-32 # ffffffffc02000aa <cputch>
ffffffffc02000d2:	006c                	addi	a1,sp,12
{
ffffffffc02000d4:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d6:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000d8:	576050ef          	jal	ra,ffffffffc020564e <vprintfmt>
    return cnt;
}
ffffffffc02000dc:	60e2                	ld	ra,24(sp)
ffffffffc02000de:	4532                	lw	a0,12(sp)
ffffffffc02000e0:	6105                	addi	sp,sp,32
ffffffffc02000e2:	8082                	ret

ffffffffc02000e4 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc02000e4:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e6:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
{
ffffffffc02000ea:	8e2a                	mv	t3,a0
ffffffffc02000ec:	f42e                	sd	a1,40(sp)
ffffffffc02000ee:	f832                	sd	a2,48(sp)
ffffffffc02000f0:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000f2:	00000517          	auipc	a0,0x0
ffffffffc02000f6:	fb850513          	addi	a0,a0,-72 # ffffffffc02000aa <cputch>
ffffffffc02000fa:	004c                	addi	a1,sp,4
ffffffffc02000fc:	869a                	mv	a3,t1
ffffffffc02000fe:	8672                	mv	a2,t3
{
ffffffffc0200100:	ec06                	sd	ra,24(sp)
ffffffffc0200102:	e0ba                	sd	a4,64(sp)
ffffffffc0200104:	e4be                	sd	a5,72(sp)
ffffffffc0200106:	e8c2                	sd	a6,80(sp)
ffffffffc0200108:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc020010a:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc020010c:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020010e:	540050ef          	jal	ra,ffffffffc020564e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200112:	60e2                	ld	ra,24(sp)
ffffffffc0200114:	4512                	lw	a0,4(sp)
ffffffffc0200116:	6125                	addi	sp,sp,96
ffffffffc0200118:	8082                	ret

ffffffffc020011a <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc020011a:	0230006f          	j	ffffffffc020093c <cons_putc>

ffffffffc020011e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc020011e:	1101                	addi	sp,sp,-32
ffffffffc0200120:	e822                	sd	s0,16(sp)
ffffffffc0200122:	ec06                	sd	ra,24(sp)
ffffffffc0200124:	e426                	sd	s1,8(sp)
ffffffffc0200126:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc0200128:	00054503          	lbu	a0,0(a0)
ffffffffc020012c:	c51d                	beqz	a0,ffffffffc020015a <cputs+0x3c>
ffffffffc020012e:	0405                	addi	s0,s0,1
ffffffffc0200130:	4485                	li	s1,1
ffffffffc0200132:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200134:	009000ef          	jal	ra,ffffffffc020093c <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc0200138:	00044503          	lbu	a0,0(s0)
ffffffffc020013c:	008487bb          	addw	a5,s1,s0
ffffffffc0200140:	0405                	addi	s0,s0,1
ffffffffc0200142:	f96d                	bnez	a0,ffffffffc0200134 <cputs+0x16>
    (*cnt)++;
ffffffffc0200144:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200148:	4529                	li	a0,10
ffffffffc020014a:	7f2000ef          	jal	ra,ffffffffc020093c <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020014e:	60e2                	ld	ra,24(sp)
ffffffffc0200150:	8522                	mv	a0,s0
ffffffffc0200152:	6442                	ld	s0,16(sp)
ffffffffc0200154:	64a2                	ld	s1,8(sp)
ffffffffc0200156:	6105                	addi	sp,sp,32
ffffffffc0200158:	8082                	ret
    while ((c = *str++) != '\0')
ffffffffc020015a:	4405                	li	s0,1
ffffffffc020015c:	b7f5                	j	ffffffffc0200148 <cputs+0x2a>

ffffffffc020015e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020015e:	1141                	addi	sp,sp,-16
ffffffffc0200160:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200162:	00f000ef          	jal	ra,ffffffffc0200970 <cons_getc>
ffffffffc0200166:	dd75                	beqz	a0,ffffffffc0200162 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200168:	60a2                	ld	ra,8(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020016e:	715d                	addi	sp,sp,-80
ffffffffc0200170:	e486                	sd	ra,72(sp)
ffffffffc0200172:	e0a6                	sd	s1,64(sp)
ffffffffc0200174:	fc4a                	sd	s2,56(sp)
ffffffffc0200176:	f84e                	sd	s3,48(sp)
ffffffffc0200178:	f452                	sd	s4,40(sp)
ffffffffc020017a:	f056                	sd	s5,32(sp)
ffffffffc020017c:	ec5a                	sd	s6,24(sp)
ffffffffc020017e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200180:	c901                	beqz	a0,ffffffffc0200190 <readline+0x22>
ffffffffc0200182:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0200184:	00006517          	auipc	a0,0x6
ffffffffc0200188:	88c50513          	addi	a0,a0,-1908 # ffffffffc0205a10 <etext+0x2a>
ffffffffc020018c:	f59ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
readline(const char *prompt) {
ffffffffc0200190:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200192:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200194:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200196:	4aa9                	li	s5,10
ffffffffc0200198:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020019a:	000c2b97          	auipc	s7,0xc2
ffffffffc020019e:	71eb8b93          	addi	s7,s7,1822 # ffffffffc02c28b8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001a2:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02001a6:	fb9ff0ef          	jal	ra,ffffffffc020015e <getchar>
        if (c < 0) {
ffffffffc02001aa:	00054a63          	bltz	a0,ffffffffc02001be <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001ae:	00a95a63          	bge	s2,a0,ffffffffc02001c2 <readline+0x54>
ffffffffc02001b2:	029a5263          	bge	s4,s1,ffffffffc02001d6 <readline+0x68>
        c = getchar();
ffffffffc02001b6:	fa9ff0ef          	jal	ra,ffffffffc020015e <getchar>
        if (c < 0) {
ffffffffc02001ba:	fe055ae3          	bgez	a0,ffffffffc02001ae <readline+0x40>
            return NULL;
ffffffffc02001be:	4501                	li	a0,0
ffffffffc02001c0:	a091                	j	ffffffffc0200204 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001c2:	03351463          	bne	a0,s3,ffffffffc02001ea <readline+0x7c>
ffffffffc02001c6:	e8a9                	bnez	s1,ffffffffc0200218 <readline+0xaa>
        c = getchar();
ffffffffc02001c8:	f97ff0ef          	jal	ra,ffffffffc020015e <getchar>
        if (c < 0) {
ffffffffc02001cc:	fe0549e3          	bltz	a0,ffffffffc02001be <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001d0:	fea959e3          	bge	s2,a0,ffffffffc02001c2 <readline+0x54>
ffffffffc02001d4:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001d6:	e42a                	sd	a0,8(sp)
ffffffffc02001d8:	f43ff0ef          	jal	ra,ffffffffc020011a <cputchar>
            buf[i ++] = c;
ffffffffc02001dc:	6522                	ld	a0,8(sp)
ffffffffc02001de:	009b87b3          	add	a5,s7,s1
ffffffffc02001e2:	2485                	addiw	s1,s1,1
ffffffffc02001e4:	00a78023          	sb	a0,0(a5)
ffffffffc02001e8:	bf7d                	j	ffffffffc02001a6 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001ea:	01550463          	beq	a0,s5,ffffffffc02001f2 <readline+0x84>
ffffffffc02001ee:	fb651ce3          	bne	a0,s6,ffffffffc02001a6 <readline+0x38>
            cputchar(c);
ffffffffc02001f2:	f29ff0ef          	jal	ra,ffffffffc020011a <cputchar>
            buf[i] = '\0';
ffffffffc02001f6:	000c2517          	auipc	a0,0xc2
ffffffffc02001fa:	6c250513          	addi	a0,a0,1730 # ffffffffc02c28b8 <buf>
ffffffffc02001fe:	94aa                	add	s1,s1,a0
ffffffffc0200200:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200204:	60a6                	ld	ra,72(sp)
ffffffffc0200206:	6486                	ld	s1,64(sp)
ffffffffc0200208:	7962                	ld	s2,56(sp)
ffffffffc020020a:	79c2                	ld	s3,48(sp)
ffffffffc020020c:	7a22                	ld	s4,40(sp)
ffffffffc020020e:	7a82                	ld	s5,32(sp)
ffffffffc0200210:	6b62                	ld	s6,24(sp)
ffffffffc0200212:	6bc2                	ld	s7,16(sp)
ffffffffc0200214:	6161                	addi	sp,sp,80
ffffffffc0200216:	8082                	ret
            cputchar(c);
ffffffffc0200218:	4521                	li	a0,8
ffffffffc020021a:	f01ff0ef          	jal	ra,ffffffffc020011a <cputchar>
            i --;
ffffffffc020021e:	34fd                	addiw	s1,s1,-1
ffffffffc0200220:	b759                	j	ffffffffc02001a6 <readline+0x38>

ffffffffc0200222 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200222:	000c7317          	auipc	t1,0xc7
ffffffffc0200226:	aee30313          	addi	t1,t1,-1298 # ffffffffc02c6d10 <is_panic>
ffffffffc020022a:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020022e:	715d                	addi	sp,sp,-80
ffffffffc0200230:	ec06                	sd	ra,24(sp)
ffffffffc0200232:	e822                	sd	s0,16(sp)
ffffffffc0200234:	f436                	sd	a3,40(sp)
ffffffffc0200236:	f83a                	sd	a4,48(sp)
ffffffffc0200238:	fc3e                	sd	a5,56(sp)
ffffffffc020023a:	e0c2                	sd	a6,64(sp)
ffffffffc020023c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020023e:	020e1a63          	bnez	t3,ffffffffc0200272 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200242:	4785                	li	a5,1
ffffffffc0200244:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200248:	8432                	mv	s0,a2
ffffffffc020024a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020024c:	862e                	mv	a2,a1
ffffffffc020024e:	85aa                	mv	a1,a0
ffffffffc0200250:	00005517          	auipc	a0,0x5
ffffffffc0200254:	7c850513          	addi	a0,a0,1992 # ffffffffc0205a18 <etext+0x32>
    va_start(ap, fmt);
ffffffffc0200258:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020025a:	e8bff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020025e:	65a2                	ld	a1,8(sp)
ffffffffc0200260:	8522                	mv	a0,s0
ffffffffc0200262:	e63ff0ef          	jal	ra,ffffffffc02000c4 <vcprintf>
    cprintf("\n");
ffffffffc0200266:	00007517          	auipc	a0,0x7
ffffffffc020026a:	de250513          	addi	a0,a0,-542 # ffffffffc0207048 <default_pmm_manager+0x460>
ffffffffc020026e:	e77ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	4581                	li	a1,0
ffffffffc0200276:	4601                	li	a2,0
ffffffffc0200278:	48a1                	li	a7,8
ffffffffc020027a:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc020027e:	736000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	174000ef          	jal	ra,ffffffffc02003f8 <kmonitor>
    while (1) {
ffffffffc0200288:	bfed                	j	ffffffffc0200282 <__panic+0x60>

ffffffffc020028a <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc020028a:	715d                	addi	sp,sp,-80
ffffffffc020028c:	832e                	mv	t1,a1
ffffffffc020028e:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200290:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200292:	8432                	mv	s0,a2
ffffffffc0200294:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200296:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc0200298:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020029a:	00005517          	auipc	a0,0x5
ffffffffc020029e:	79e50513          	addi	a0,a0,1950 # ffffffffc0205a38 <etext+0x52>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02002a2:	ec06                	sd	ra,24(sp)
ffffffffc02002a4:	f436                	sd	a3,40(sp)
ffffffffc02002a6:	f83a                	sd	a4,48(sp)
ffffffffc02002a8:	e0c2                	sd	a6,64(sp)
ffffffffc02002aa:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002ac:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002ae:	e37ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002b2:	65a2                	ld	a1,8(sp)
ffffffffc02002b4:	8522                	mv	a0,s0
ffffffffc02002b6:	e0fff0ef          	jal	ra,ffffffffc02000c4 <vcprintf>
    cprintf("\n");
ffffffffc02002ba:	00007517          	auipc	a0,0x7
ffffffffc02002be:	d8e50513          	addi	a0,a0,-626 # ffffffffc0207048 <default_pmm_manager+0x460>
ffffffffc02002c2:	e23ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    va_end(ap);
}
ffffffffc02002c6:	60e2                	ld	ra,24(sp)
ffffffffc02002c8:	6442                	ld	s0,16(sp)
ffffffffc02002ca:	6161                	addi	sp,sp,80
ffffffffc02002cc:	8082                	ret

ffffffffc02002ce <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002ce:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002d0:	00005517          	auipc	a0,0x5
ffffffffc02002d4:	78850513          	addi	a0,a0,1928 # ffffffffc0205a58 <etext+0x72>
void print_kerninfo(void) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002da:	e0bff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002de:	00000597          	auipc	a1,0x0
ffffffffc02002e2:	d6c58593          	addi	a1,a1,-660 # ffffffffc020004a <kern_init>
ffffffffc02002e6:	00005517          	auipc	a0,0x5
ffffffffc02002ea:	79250513          	addi	a0,a0,1938 # ffffffffc0205a78 <etext+0x92>
ffffffffc02002ee:	df7ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002f2:	00005597          	auipc	a1,0x5
ffffffffc02002f6:	6f458593          	addi	a1,a1,1780 # ffffffffc02059e6 <etext>
ffffffffc02002fa:	00005517          	auipc	a0,0x5
ffffffffc02002fe:	79e50513          	addi	a0,a0,1950 # ffffffffc0205a98 <etext+0xb2>
ffffffffc0200302:	de3ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200306:	000c2597          	auipc	a1,0xc2
ffffffffc020030a:	5b258593          	addi	a1,a1,1458 # ffffffffc02c28b8 <buf>
ffffffffc020030e:	00005517          	auipc	a0,0x5
ffffffffc0200312:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205ab8 <etext+0xd2>
ffffffffc0200316:	dcfff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020031a:	000c7597          	auipc	a1,0xc7
ffffffffc020031e:	a8658593          	addi	a1,a1,-1402 # ffffffffc02c6da0 <end>
ffffffffc0200322:	00005517          	auipc	a0,0x5
ffffffffc0200326:	7b650513          	addi	a0,a0,1974 # ffffffffc0205ad8 <etext+0xf2>
ffffffffc020032a:	dbbff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020032e:	000c7597          	auipc	a1,0xc7
ffffffffc0200332:	e7158593          	addi	a1,a1,-399 # ffffffffc02c719f <end+0x3ff>
ffffffffc0200336:	00000797          	auipc	a5,0x0
ffffffffc020033a:	d1478793          	addi	a5,a5,-748 # ffffffffc020004a <kern_init>
ffffffffc020033e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200342:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200348:	3ff5f593          	andi	a1,a1,1023
ffffffffc020034c:	95be                	add	a1,a1,a5
ffffffffc020034e:	85a9                	srai	a1,a1,0xa
ffffffffc0200350:	00005517          	auipc	a0,0x5
ffffffffc0200354:	7a850513          	addi	a0,a0,1960 # ffffffffc0205af8 <etext+0x112>
}
ffffffffc0200358:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020035a:	b369                	j	ffffffffc02000e4 <cprintf>

ffffffffc020035c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020035c:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020035e:	00005617          	auipc	a2,0x5
ffffffffc0200362:	7ca60613          	addi	a2,a2,1994 # ffffffffc0205b28 <etext+0x142>
ffffffffc0200366:	04d00593          	li	a1,77
ffffffffc020036a:	00005517          	auipc	a0,0x5
ffffffffc020036e:	7d650513          	addi	a0,a0,2006 # ffffffffc0205b40 <etext+0x15a>
void print_stackframe(void) {
ffffffffc0200372:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200374:	eafff0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0200378 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200378:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020037a:	00005617          	auipc	a2,0x5
ffffffffc020037e:	7de60613          	addi	a2,a2,2014 # ffffffffc0205b58 <etext+0x172>
ffffffffc0200382:	00005597          	auipc	a1,0x5
ffffffffc0200386:	7f658593          	addi	a1,a1,2038 # ffffffffc0205b78 <etext+0x192>
ffffffffc020038a:	00005517          	auipc	a0,0x5
ffffffffc020038e:	7f650513          	addi	a0,a0,2038 # ffffffffc0205b80 <etext+0x19a>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200392:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200394:	d51ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
ffffffffc0200398:	00005617          	auipc	a2,0x5
ffffffffc020039c:	7f860613          	addi	a2,a2,2040 # ffffffffc0205b90 <etext+0x1aa>
ffffffffc02003a0:	00006597          	auipc	a1,0x6
ffffffffc02003a4:	81858593          	addi	a1,a1,-2024 # ffffffffc0205bb8 <etext+0x1d2>
ffffffffc02003a8:	00005517          	auipc	a0,0x5
ffffffffc02003ac:	7d850513          	addi	a0,a0,2008 # ffffffffc0205b80 <etext+0x19a>
ffffffffc02003b0:	d35ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
ffffffffc02003b4:	00006617          	auipc	a2,0x6
ffffffffc02003b8:	81460613          	addi	a2,a2,-2028 # ffffffffc0205bc8 <etext+0x1e2>
ffffffffc02003bc:	00006597          	auipc	a1,0x6
ffffffffc02003c0:	82c58593          	addi	a1,a1,-2004 # ffffffffc0205be8 <etext+0x202>
ffffffffc02003c4:	00005517          	auipc	a0,0x5
ffffffffc02003c8:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205b80 <etext+0x19a>
ffffffffc02003cc:	d19ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    }
    return 0;
}
ffffffffc02003d0:	60a2                	ld	ra,8(sp)
ffffffffc02003d2:	4501                	li	a0,0
ffffffffc02003d4:	0141                	addi	sp,sp,16
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003d8:	1141                	addi	sp,sp,-16
ffffffffc02003da:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003dc:	ef3ff0ef          	jal	ra,ffffffffc02002ce <print_kerninfo>
    return 0;
}
ffffffffc02003e0:	60a2                	ld	ra,8(sp)
ffffffffc02003e2:	4501                	li	a0,0
ffffffffc02003e4:	0141                	addi	sp,sp,16
ffffffffc02003e6:	8082                	ret

ffffffffc02003e8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003e8:	1141                	addi	sp,sp,-16
ffffffffc02003ea:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003ec:	f71ff0ef          	jal	ra,ffffffffc020035c <print_stackframe>
    return 0;
}
ffffffffc02003f0:	60a2                	ld	ra,8(sp)
ffffffffc02003f2:	4501                	li	a0,0
ffffffffc02003f4:	0141                	addi	sp,sp,16
ffffffffc02003f6:	8082                	ret

ffffffffc02003f8 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003f8:	7115                	addi	sp,sp,-224
ffffffffc02003fa:	ed5e                	sd	s7,152(sp)
ffffffffc02003fc:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003fe:	00005517          	auipc	a0,0x5
ffffffffc0200402:	7fa50513          	addi	a0,a0,2042 # ffffffffc0205bf8 <etext+0x212>
kmonitor(struct trapframe *tf) {
ffffffffc0200406:	ed86                	sd	ra,216(sp)
ffffffffc0200408:	e9a2                	sd	s0,208(sp)
ffffffffc020040a:	e5a6                	sd	s1,200(sp)
ffffffffc020040c:	e1ca                	sd	s2,192(sp)
ffffffffc020040e:	fd4e                	sd	s3,184(sp)
ffffffffc0200410:	f952                	sd	s4,176(sp)
ffffffffc0200412:	f556                	sd	s5,168(sp)
ffffffffc0200414:	f15a                	sd	s6,160(sp)
ffffffffc0200416:	e962                	sd	s8,144(sp)
ffffffffc0200418:	e566                	sd	s9,136(sp)
ffffffffc020041a:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020041c:	cc9ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200420:	00006517          	auipc	a0,0x6
ffffffffc0200424:	80050513          	addi	a0,a0,-2048 # ffffffffc0205c20 <etext+0x23a>
ffffffffc0200428:	cbdff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    if (tf != NULL) {
ffffffffc020042c:	000b8563          	beqz	s7,ffffffffc0200436 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200430:	855e                	mv	a0,s7
ffffffffc0200432:	770000ef          	jal	ra,ffffffffc0200ba2 <print_trapframe>
ffffffffc0200436:	00006c17          	auipc	s8,0x6
ffffffffc020043a:	85ac0c13          	addi	s8,s8,-1958 # ffffffffc0205c90 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020043e:	00006917          	auipc	s2,0x6
ffffffffc0200442:	80a90913          	addi	s2,s2,-2038 # ffffffffc0205c48 <etext+0x262>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200446:	00006497          	auipc	s1,0x6
ffffffffc020044a:	80a48493          	addi	s1,s1,-2038 # ffffffffc0205c50 <etext+0x26a>
        if (argc == MAXARGS - 1) {
ffffffffc020044e:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200450:	00006b17          	auipc	s6,0x6
ffffffffc0200454:	808b0b13          	addi	s6,s6,-2040 # ffffffffc0205c58 <etext+0x272>
        argv[argc ++] = buf;
ffffffffc0200458:	00005a17          	auipc	s4,0x5
ffffffffc020045c:	720a0a13          	addi	s4,s4,1824 # ffffffffc0205b78 <etext+0x192>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200460:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200462:	854a                	mv	a0,s2
ffffffffc0200464:	d0bff0ef          	jal	ra,ffffffffc020016e <readline>
ffffffffc0200468:	842a                	mv	s0,a0
ffffffffc020046a:	dd65                	beqz	a0,ffffffffc0200462 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020046c:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200470:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200472:	e1bd                	bnez	a1,ffffffffc02004d8 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200474:	fe0c87e3          	beqz	s9,ffffffffc0200462 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200478:	6582                	ld	a1,0(sp)
ffffffffc020047a:	00006d17          	auipc	s10,0x6
ffffffffc020047e:	816d0d13          	addi	s10,s10,-2026 # ffffffffc0205c90 <commands>
        argv[argc ++] = buf;
ffffffffc0200482:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200484:	4401                	li	s0,0
ffffffffc0200486:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200488:	0d6050ef          	jal	ra,ffffffffc020555e <strcmp>
ffffffffc020048c:	c919                	beqz	a0,ffffffffc02004a2 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020048e:	2405                	addiw	s0,s0,1
ffffffffc0200490:	0b540063          	beq	s0,s5,ffffffffc0200530 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200494:	000d3503          	ld	a0,0(s10)
ffffffffc0200498:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020049a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020049c:	0c2050ef          	jal	ra,ffffffffc020555e <strcmp>
ffffffffc02004a0:	f57d                	bnez	a0,ffffffffc020048e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004a2:	00141793          	slli	a5,s0,0x1
ffffffffc02004a6:	97a2                	add	a5,a5,s0
ffffffffc02004a8:	078e                	slli	a5,a5,0x3
ffffffffc02004aa:	97e2                	add	a5,a5,s8
ffffffffc02004ac:	6b9c                	ld	a5,16(a5)
ffffffffc02004ae:	865e                	mv	a2,s7
ffffffffc02004b0:	002c                	addi	a1,sp,8
ffffffffc02004b2:	fffc851b          	addiw	a0,s9,-1
ffffffffc02004b6:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004b8:	fa0555e3          	bgez	a0,ffffffffc0200462 <kmonitor+0x6a>
}
ffffffffc02004bc:	60ee                	ld	ra,216(sp)
ffffffffc02004be:	644e                	ld	s0,208(sp)
ffffffffc02004c0:	64ae                	ld	s1,200(sp)
ffffffffc02004c2:	690e                	ld	s2,192(sp)
ffffffffc02004c4:	79ea                	ld	s3,184(sp)
ffffffffc02004c6:	7a4a                	ld	s4,176(sp)
ffffffffc02004c8:	7aaa                	ld	s5,168(sp)
ffffffffc02004ca:	7b0a                	ld	s6,160(sp)
ffffffffc02004cc:	6bea                	ld	s7,152(sp)
ffffffffc02004ce:	6c4a                	ld	s8,144(sp)
ffffffffc02004d0:	6caa                	ld	s9,136(sp)
ffffffffc02004d2:	6d0a                	ld	s10,128(sp)
ffffffffc02004d4:	612d                	addi	sp,sp,224
ffffffffc02004d6:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004d8:	8526                	mv	a0,s1
ffffffffc02004da:	0c8050ef          	jal	ra,ffffffffc02055a2 <strchr>
ffffffffc02004de:	c901                	beqz	a0,ffffffffc02004ee <kmonitor+0xf6>
ffffffffc02004e0:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02004e4:	00040023          	sb	zero,0(s0)
ffffffffc02004e8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004ea:	d5c9                	beqz	a1,ffffffffc0200474 <kmonitor+0x7c>
ffffffffc02004ec:	b7f5                	j	ffffffffc02004d8 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc02004ee:	00044783          	lbu	a5,0(s0)
ffffffffc02004f2:	d3c9                	beqz	a5,ffffffffc0200474 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc02004f4:	033c8963          	beq	s9,s3,ffffffffc0200526 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc02004f8:	003c9793          	slli	a5,s9,0x3
ffffffffc02004fc:	0118                	addi	a4,sp,128
ffffffffc02004fe:	97ba                	add	a5,a5,a4
ffffffffc0200500:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200504:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200508:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020050a:	e591                	bnez	a1,ffffffffc0200516 <kmonitor+0x11e>
ffffffffc020050c:	b7b5                	j	ffffffffc0200478 <kmonitor+0x80>
ffffffffc020050e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200512:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200514:	d1a5                	beqz	a1,ffffffffc0200474 <kmonitor+0x7c>
ffffffffc0200516:	8526                	mv	a0,s1
ffffffffc0200518:	08a050ef          	jal	ra,ffffffffc02055a2 <strchr>
ffffffffc020051c:	d96d                	beqz	a0,ffffffffc020050e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020051e:	00044583          	lbu	a1,0(s0)
ffffffffc0200522:	d9a9                	beqz	a1,ffffffffc0200474 <kmonitor+0x7c>
ffffffffc0200524:	bf55                	j	ffffffffc02004d8 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200526:	45c1                	li	a1,16
ffffffffc0200528:	855a                	mv	a0,s6
ffffffffc020052a:	bbbff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
ffffffffc020052e:	b7e9                	j	ffffffffc02004f8 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200530:	6582                	ld	a1,0(sp)
ffffffffc0200532:	00005517          	auipc	a0,0x5
ffffffffc0200536:	74650513          	addi	a0,a0,1862 # ffffffffc0205c78 <etext+0x292>
ffffffffc020053a:	babff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    return 0;
ffffffffc020053e:	b715                	j	ffffffffc0200462 <kmonitor+0x6a>

ffffffffc0200540 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200540:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200542:	00005517          	auipc	a0,0x5
ffffffffc0200546:	79650513          	addi	a0,a0,1942 # ffffffffc0205cd8 <commands+0x48>
void dtb_init(void) {
ffffffffc020054a:	fc86                	sd	ra,120(sp)
ffffffffc020054c:	f8a2                	sd	s0,112(sp)
ffffffffc020054e:	e8d2                	sd	s4,80(sp)
ffffffffc0200550:	f4a6                	sd	s1,104(sp)
ffffffffc0200552:	f0ca                	sd	s2,96(sp)
ffffffffc0200554:	ecce                	sd	s3,88(sp)
ffffffffc0200556:	e4d6                	sd	s5,72(sp)
ffffffffc0200558:	e0da                	sd	s6,64(sp)
ffffffffc020055a:	fc5e                	sd	s7,56(sp)
ffffffffc020055c:	f862                	sd	s8,48(sp)
ffffffffc020055e:	f466                	sd	s9,40(sp)
ffffffffc0200560:	f06a                	sd	s10,32(sp)
ffffffffc0200562:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200564:	b81ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200568:	0000c597          	auipc	a1,0xc
ffffffffc020056c:	a985b583          	ld	a1,-1384(a1) # ffffffffc020c000 <boot_hartid>
ffffffffc0200570:	00005517          	auipc	a0,0x5
ffffffffc0200574:	77850513          	addi	a0,a0,1912 # ffffffffc0205ce8 <commands+0x58>
ffffffffc0200578:	b6dff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020057c:	0000c417          	auipc	s0,0xc
ffffffffc0200580:	a8c40413          	addi	s0,s0,-1396 # ffffffffc020c008 <boot_dtb>
ffffffffc0200584:	600c                	ld	a1,0(s0)
ffffffffc0200586:	00005517          	auipc	a0,0x5
ffffffffc020058a:	77250513          	addi	a0,a0,1906 # ffffffffc0205cf8 <commands+0x68>
ffffffffc020058e:	b57ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200592:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200596:	00005517          	auipc	a0,0x5
ffffffffc020059a:	77a50513          	addi	a0,a0,1914 # ffffffffc0205d10 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc020059e:	120a0463          	beqz	s4,ffffffffc02006c6 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc02005a2:	57f5                	li	a5,-3
ffffffffc02005a4:	07fa                	slli	a5,a5,0x1e
ffffffffc02005a6:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02005aa:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ac:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b0:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005b2:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005b6:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ba:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005be:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005c2:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c6:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005c8:	8ec9                	or	a3,a3,a0
ffffffffc02005ca:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005ce:	1b7d                	addi	s6,s6,-1
ffffffffc02005d0:	0167f7b3          	and	a5,a5,s6
ffffffffc02005d4:	8dd5                	or	a1,a1,a3
ffffffffc02005d6:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02005d8:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005dc:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02005de:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe1914d>
ffffffffc02005e2:	10f59163          	bne	a1,a5,ffffffffc02006e4 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02005e6:	471c                	lw	a5,8(a4)
ffffffffc02005e8:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02005ea:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ec:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005f0:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02005f4:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f8:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005fc:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200600:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200604:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200608:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020060c:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200610:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200614:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200616:	01146433          	or	s0,s0,a7
ffffffffc020061a:	0086969b          	slliw	a3,a3,0x8
ffffffffc020061e:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200622:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200624:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200628:	8c49                	or	s0,s0,a0
ffffffffc020062a:	0166f6b3          	and	a3,a3,s6
ffffffffc020062e:	00ca6a33          	or	s4,s4,a2
ffffffffc0200632:	0167f7b3          	and	a5,a5,s6
ffffffffc0200636:	8c55                	or	s0,s0,a3
ffffffffc0200638:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020063c:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020063e:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200640:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200642:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200646:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200648:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020064a:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020064e:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200650:	00005917          	auipc	s2,0x5
ffffffffc0200654:	71090913          	addi	s2,s2,1808 # ffffffffc0205d60 <commands+0xd0>
ffffffffc0200658:	49bd                	li	s3,15
        switch (token) {
ffffffffc020065a:	4d91                	li	s11,4
ffffffffc020065c:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020065e:	00005497          	auipc	s1,0x5
ffffffffc0200662:	6fa48493          	addi	s1,s1,1786 # ffffffffc0205d58 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200666:	000a2703          	lw	a4,0(s4)
ffffffffc020066a:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066e:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200672:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200676:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067a:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067e:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200682:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200684:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200688:	0087171b          	slliw	a4,a4,0x8
ffffffffc020068c:	8fd5                	or	a5,a5,a3
ffffffffc020068e:	00eb7733          	and	a4,s6,a4
ffffffffc0200692:	8fd9                	or	a5,a5,a4
ffffffffc0200694:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200696:	09778c63          	beq	a5,s7,ffffffffc020072e <dtb_init+0x1ee>
ffffffffc020069a:	00fbea63          	bltu	s7,a5,ffffffffc02006ae <dtb_init+0x16e>
ffffffffc020069e:	07a78663          	beq	a5,s10,ffffffffc020070a <dtb_init+0x1ca>
ffffffffc02006a2:	4709                	li	a4,2
ffffffffc02006a4:	00e79763          	bne	a5,a4,ffffffffc02006b2 <dtb_init+0x172>
ffffffffc02006a8:	4c81                	li	s9,0
ffffffffc02006aa:	8a56                	mv	s4,s5
ffffffffc02006ac:	bf6d                	j	ffffffffc0200666 <dtb_init+0x126>
ffffffffc02006ae:	ffb78ee3          	beq	a5,s11,ffffffffc02006aa <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006b2:	00005517          	auipc	a0,0x5
ffffffffc02006b6:	72650513          	addi	a0,a0,1830 # ffffffffc0205dd8 <commands+0x148>
ffffffffc02006ba:	a2bff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006be:	00005517          	auipc	a0,0x5
ffffffffc02006c2:	75250513          	addi	a0,a0,1874 # ffffffffc0205e10 <commands+0x180>
}
ffffffffc02006c6:	7446                	ld	s0,112(sp)
ffffffffc02006c8:	70e6                	ld	ra,120(sp)
ffffffffc02006ca:	74a6                	ld	s1,104(sp)
ffffffffc02006cc:	7906                	ld	s2,96(sp)
ffffffffc02006ce:	69e6                	ld	s3,88(sp)
ffffffffc02006d0:	6a46                	ld	s4,80(sp)
ffffffffc02006d2:	6aa6                	ld	s5,72(sp)
ffffffffc02006d4:	6b06                	ld	s6,64(sp)
ffffffffc02006d6:	7be2                	ld	s7,56(sp)
ffffffffc02006d8:	7c42                	ld	s8,48(sp)
ffffffffc02006da:	7ca2                	ld	s9,40(sp)
ffffffffc02006dc:	7d02                	ld	s10,32(sp)
ffffffffc02006de:	6de2                	ld	s11,24(sp)
ffffffffc02006e0:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02006e2:	b409                	j	ffffffffc02000e4 <cprintf>
}
ffffffffc02006e4:	7446                	ld	s0,112(sp)
ffffffffc02006e6:	70e6                	ld	ra,120(sp)
ffffffffc02006e8:	74a6                	ld	s1,104(sp)
ffffffffc02006ea:	7906                	ld	s2,96(sp)
ffffffffc02006ec:	69e6                	ld	s3,88(sp)
ffffffffc02006ee:	6a46                	ld	s4,80(sp)
ffffffffc02006f0:	6aa6                	ld	s5,72(sp)
ffffffffc02006f2:	6b06                	ld	s6,64(sp)
ffffffffc02006f4:	7be2                	ld	s7,56(sp)
ffffffffc02006f6:	7c42                	ld	s8,48(sp)
ffffffffc02006f8:	7ca2                	ld	s9,40(sp)
ffffffffc02006fa:	7d02                	ld	s10,32(sp)
ffffffffc02006fc:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02006fe:	00005517          	auipc	a0,0x5
ffffffffc0200702:	63250513          	addi	a0,a0,1586 # ffffffffc0205d30 <commands+0xa0>
}
ffffffffc0200706:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200708:	baf1                	j	ffffffffc02000e4 <cprintf>
                int name_len = strlen(name);
ffffffffc020070a:	8556                	mv	a0,s5
ffffffffc020070c:	60b040ef          	jal	ra,ffffffffc0205516 <strlen>
ffffffffc0200710:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200712:	4619                	li	a2,6
ffffffffc0200714:	85a6                	mv	a1,s1
ffffffffc0200716:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200718:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020071a:	663040ef          	jal	ra,ffffffffc020557c <strncmp>
ffffffffc020071e:	e111                	bnez	a0,ffffffffc0200722 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200720:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200722:	0a91                	addi	s5,s5,4
ffffffffc0200724:	9ad2                	add	s5,s5,s4
ffffffffc0200726:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020072a:	8a56                	mv	s4,s5
ffffffffc020072c:	bf2d                	j	ffffffffc0200666 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020072e:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200732:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200736:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020073a:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200742:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200746:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020074a:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020074e:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200752:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200756:	00eaeab3          	or	s5,s5,a4
ffffffffc020075a:	00fb77b3          	and	a5,s6,a5
ffffffffc020075e:	00faeab3          	or	s5,s5,a5
ffffffffc0200762:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200764:	000c9c63          	bnez	s9,ffffffffc020077c <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200768:	1a82                	slli	s5,s5,0x20
ffffffffc020076a:	00368793          	addi	a5,a3,3
ffffffffc020076e:	020ada93          	srli	s5,s5,0x20
ffffffffc0200772:	9abe                	add	s5,s5,a5
ffffffffc0200774:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200778:	8a56                	mv	s4,s5
ffffffffc020077a:	b5f5                	j	ffffffffc0200666 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020077c:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200780:	85ca                	mv	a1,s2
ffffffffc0200782:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200784:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200788:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020078c:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200790:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200794:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200798:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079a:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020079e:	0087979b          	slliw	a5,a5,0x8
ffffffffc02007a2:	8d59                	or	a0,a0,a4
ffffffffc02007a4:	00fb77b3          	and	a5,s6,a5
ffffffffc02007a8:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007aa:	1502                	slli	a0,a0,0x20
ffffffffc02007ac:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007ae:	9522                	add	a0,a0,s0
ffffffffc02007b0:	5af040ef          	jal	ra,ffffffffc020555e <strcmp>
ffffffffc02007b4:	66a2                	ld	a3,8(sp)
ffffffffc02007b6:	f94d                	bnez	a0,ffffffffc0200768 <dtb_init+0x228>
ffffffffc02007b8:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200768 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007bc:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007c0:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007c4:	00005517          	auipc	a0,0x5
ffffffffc02007c8:	5a450513          	addi	a0,a0,1444 # ffffffffc0205d68 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc02007cc:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007d0:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02007d4:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d8:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02007dc:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007e0:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007e4:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007e8:	0187d693          	srli	a3,a5,0x18
ffffffffc02007ec:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02007f0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02007f4:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f8:	0106561b          	srliw	a2,a2,0x10
ffffffffc02007fc:	010f6f33          	or	t5,t5,a6
ffffffffc0200800:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200804:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200808:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020080c:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200810:	0186f6b3          	and	a3,a3,s8
ffffffffc0200814:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200818:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020081c:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200820:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200824:	8361                	srli	a4,a4,0x18
ffffffffc0200826:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020082a:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020082e:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200832:	00cb7633          	and	a2,s6,a2
ffffffffc0200836:	0088181b          	slliw	a6,a6,0x8
ffffffffc020083a:	0085959b          	slliw	a1,a1,0x8
ffffffffc020083e:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200842:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200846:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084a:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020084e:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200852:	011b78b3          	and	a7,s6,a7
ffffffffc0200856:	005eeeb3          	or	t4,t4,t0
ffffffffc020085a:	00c6e733          	or	a4,a3,a2
ffffffffc020085e:	006c6c33          	or	s8,s8,t1
ffffffffc0200862:	010b76b3          	and	a3,s6,a6
ffffffffc0200866:	00bb7b33          	and	s6,s6,a1
ffffffffc020086a:	01d7e7b3          	or	a5,a5,t4
ffffffffc020086e:	016c6b33          	or	s6,s8,s6
ffffffffc0200872:	01146433          	or	s0,s0,a7
ffffffffc0200876:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200878:	1702                	slli	a4,a4,0x20
ffffffffc020087a:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020087c:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020087e:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200880:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200882:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200886:	0167eb33          	or	s6,a5,s6
ffffffffc020088a:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc020088c:	859ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200890:	85a2                	mv	a1,s0
ffffffffc0200892:	00005517          	auipc	a0,0x5
ffffffffc0200896:	4f650513          	addi	a0,a0,1270 # ffffffffc0205d88 <commands+0xf8>
ffffffffc020089a:	84bff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020089e:	014b5613          	srli	a2,s6,0x14
ffffffffc02008a2:	85da                	mv	a1,s6
ffffffffc02008a4:	00005517          	auipc	a0,0x5
ffffffffc02008a8:	4fc50513          	addi	a0,a0,1276 # ffffffffc0205da0 <commands+0x110>
ffffffffc02008ac:	839ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008b0:	008b05b3          	add	a1,s6,s0
ffffffffc02008b4:	15fd                	addi	a1,a1,-1
ffffffffc02008b6:	00005517          	auipc	a0,0x5
ffffffffc02008ba:	50a50513          	addi	a0,a0,1290 # ffffffffc0205dc0 <commands+0x130>
ffffffffc02008be:	827ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02008c2:	00005517          	auipc	a0,0x5
ffffffffc02008c6:	54e50513          	addi	a0,a0,1358 # ffffffffc0205e10 <commands+0x180>
        memory_base = mem_base;
ffffffffc02008ca:	000c6797          	auipc	a5,0xc6
ffffffffc02008ce:	4487b723          	sd	s0,1102(a5) # ffffffffc02c6d18 <memory_base>
        memory_size = mem_size;
ffffffffc02008d2:	000c6797          	auipc	a5,0xc6
ffffffffc02008d6:	4567b723          	sd	s6,1102(a5) # ffffffffc02c6d20 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02008da:	b3f5                	j	ffffffffc02006c6 <dtb_init+0x186>

ffffffffc02008dc <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008dc:	000c6517          	auipc	a0,0xc6
ffffffffc02008e0:	43c53503          	ld	a0,1084(a0) # ffffffffc02c6d18 <memory_base>
ffffffffc02008e4:	8082                	ret

ffffffffc02008e6 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008e6:	000c6517          	auipc	a0,0xc6
ffffffffc02008ea:	43a53503          	ld	a0,1082(a0) # ffffffffc02c6d20 <memory_size>
ffffffffc02008ee:	8082                	ret

ffffffffc02008f0 <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void)
{
    set_csr(sie, MIP_STIP);
ffffffffc02008f0:	02000793          	li	a5,32
ffffffffc02008f4:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02008f8:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02008fc:	67e1                	lui	a5,0x18
ffffffffc02008fe:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xbf78>
ffffffffc0200902:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200904:	4581                	li	a1,0
ffffffffc0200906:	4601                	li	a2,0
ffffffffc0200908:	4881                	li	a7,0
ffffffffc020090a:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc020090e:	00005517          	auipc	a0,0x5
ffffffffc0200912:	51a50513          	addi	a0,a0,1306 # ffffffffc0205e28 <commands+0x198>
    ticks = 0;
ffffffffc0200916:	000c6797          	auipc	a5,0xc6
ffffffffc020091a:	4007b923          	sd	zero,1042(a5) # ffffffffc02c6d28 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020091e:	fc6ff06f          	j	ffffffffc02000e4 <cprintf>

ffffffffc0200922 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200922:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200926:	67e1                	lui	a5,0x18
ffffffffc0200928:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xbf78>
ffffffffc020092c:	953e                	add	a0,a0,a5
ffffffffc020092e:	4581                	li	a1,0
ffffffffc0200930:	4601                	li	a2,0
ffffffffc0200932:	4881                	li	a7,0
ffffffffc0200934:	00000073          	ecall
ffffffffc0200938:	8082                	ret

ffffffffc020093a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020093a:	8082                	ret

ffffffffc020093c <cons_putc>:
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020093c:	100027f3          	csrr	a5,sstatus
ffffffffc0200940:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200942:	0ff57513          	zext.b	a0,a0
ffffffffc0200946:	e799                	bnez	a5,ffffffffc0200954 <cons_putc+0x18>
ffffffffc0200948:	4581                	li	a1,0
ffffffffc020094a:	4601                	li	a2,0
ffffffffc020094c:	4885                	li	a7,1
ffffffffc020094e:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc0200952:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200954:	1101                	addi	sp,sp,-32
ffffffffc0200956:	ec06                	sd	ra,24(sp)
ffffffffc0200958:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020095a:	05a000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020095e:	6522                	ld	a0,8(sp)
ffffffffc0200960:	4581                	li	a1,0
ffffffffc0200962:	4601                	li	a2,0
ffffffffc0200964:	4885                	li	a7,1
ffffffffc0200966:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020096a:	60e2                	ld	ra,24(sp)
ffffffffc020096c:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc020096e:	a081                	j	ffffffffc02009ae <intr_enable>

ffffffffc0200970 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200970:	100027f3          	csrr	a5,sstatus
ffffffffc0200974:	8b89                	andi	a5,a5,2
ffffffffc0200976:	eb89                	bnez	a5,ffffffffc0200988 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200978:	4501                	li	a0,0
ffffffffc020097a:	4581                	li	a1,0
ffffffffc020097c:	4601                	li	a2,0
ffffffffc020097e:	4889                	li	a7,2
ffffffffc0200980:	00000073          	ecall
ffffffffc0200984:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200986:	8082                	ret
int cons_getc(void) {
ffffffffc0200988:	1101                	addi	sp,sp,-32
ffffffffc020098a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020098c:	028000ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0200990:	4501                	li	a0,0
ffffffffc0200992:	4581                	li	a1,0
ffffffffc0200994:	4601                	li	a2,0
ffffffffc0200996:	4889                	li	a7,2
ffffffffc0200998:	00000073          	ecall
ffffffffc020099c:	2501                	sext.w	a0,a0
ffffffffc020099e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02009a0:	00e000ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc02009a4:	60e2                	ld	ra,24(sp)
ffffffffc02009a6:	6522                	ld	a0,8(sp)
ffffffffc02009a8:	6105                	addi	sp,sp,32
ffffffffc02009aa:	8082                	ret

ffffffffc02009ac <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02009ac:	8082                	ret

ffffffffc02009ae <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009ae:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02009b2:	8082                	ret

ffffffffc02009b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009b4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02009b8:	8082                	ret

ffffffffc02009ba <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02009ba:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02009be:	00000797          	auipc	a5,0x0
ffffffffc02009c2:	6a278793          	addi	a5,a5,1698 # ffffffffc0201060 <__alltraps>
ffffffffc02009c6:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc02009ca:	000407b7          	lui	a5,0x40
ffffffffc02009ce:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02009d2:	8082                	ret

ffffffffc02009d4 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009d4:	610c                	ld	a1,0(a0)
{
ffffffffc02009d6:	1141                	addi	sp,sp,-16
ffffffffc02009d8:	e022                	sd	s0,0(sp)
ffffffffc02009da:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009dc:	00005517          	auipc	a0,0x5
ffffffffc02009e0:	46c50513          	addi	a0,a0,1132 # ffffffffc0205e48 <commands+0x1b8>
{
ffffffffc02009e4:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e6:	efeff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009ea:	640c                	ld	a1,8(s0)
ffffffffc02009ec:	00005517          	auipc	a0,0x5
ffffffffc02009f0:	47450513          	addi	a0,a0,1140 # ffffffffc0205e60 <commands+0x1d0>
ffffffffc02009f4:	ef0ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009f8:	680c                	ld	a1,16(s0)
ffffffffc02009fa:	00005517          	auipc	a0,0x5
ffffffffc02009fe:	47e50513          	addi	a0,a0,1150 # ffffffffc0205e78 <commands+0x1e8>
ffffffffc0200a02:	ee2ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a06:	6c0c                	ld	a1,24(s0)
ffffffffc0200a08:	00005517          	auipc	a0,0x5
ffffffffc0200a0c:	48850513          	addi	a0,a0,1160 # ffffffffc0205e90 <commands+0x200>
ffffffffc0200a10:	ed4ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a14:	700c                	ld	a1,32(s0)
ffffffffc0200a16:	00005517          	auipc	a0,0x5
ffffffffc0200a1a:	49250513          	addi	a0,a0,1170 # ffffffffc0205ea8 <commands+0x218>
ffffffffc0200a1e:	ec6ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a22:	740c                	ld	a1,40(s0)
ffffffffc0200a24:	00005517          	auipc	a0,0x5
ffffffffc0200a28:	49c50513          	addi	a0,a0,1180 # ffffffffc0205ec0 <commands+0x230>
ffffffffc0200a2c:	eb8ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a30:	780c                	ld	a1,48(s0)
ffffffffc0200a32:	00005517          	auipc	a0,0x5
ffffffffc0200a36:	4a650513          	addi	a0,a0,1190 # ffffffffc0205ed8 <commands+0x248>
ffffffffc0200a3a:	eaaff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a3e:	7c0c                	ld	a1,56(s0)
ffffffffc0200a40:	00005517          	auipc	a0,0x5
ffffffffc0200a44:	4b050513          	addi	a0,a0,1200 # ffffffffc0205ef0 <commands+0x260>
ffffffffc0200a48:	e9cff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a4c:	602c                	ld	a1,64(s0)
ffffffffc0200a4e:	00005517          	auipc	a0,0x5
ffffffffc0200a52:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205f08 <commands+0x278>
ffffffffc0200a56:	e8eff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a5a:	642c                	ld	a1,72(s0)
ffffffffc0200a5c:	00005517          	auipc	a0,0x5
ffffffffc0200a60:	4c450513          	addi	a0,a0,1220 # ffffffffc0205f20 <commands+0x290>
ffffffffc0200a64:	e80ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a68:	682c                	ld	a1,80(s0)
ffffffffc0200a6a:	00005517          	auipc	a0,0x5
ffffffffc0200a6e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205f38 <commands+0x2a8>
ffffffffc0200a72:	e72ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a76:	6c2c                	ld	a1,88(s0)
ffffffffc0200a78:	00005517          	auipc	a0,0x5
ffffffffc0200a7c:	4d850513          	addi	a0,a0,1240 # ffffffffc0205f50 <commands+0x2c0>
ffffffffc0200a80:	e64ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a84:	702c                	ld	a1,96(s0)
ffffffffc0200a86:	00005517          	auipc	a0,0x5
ffffffffc0200a8a:	4e250513          	addi	a0,a0,1250 # ffffffffc0205f68 <commands+0x2d8>
ffffffffc0200a8e:	e56ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a92:	742c                	ld	a1,104(s0)
ffffffffc0200a94:	00005517          	auipc	a0,0x5
ffffffffc0200a98:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205f80 <commands+0x2f0>
ffffffffc0200a9c:	e48ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa0:	782c                	ld	a1,112(s0)
ffffffffc0200aa2:	00005517          	auipc	a0,0x5
ffffffffc0200aa6:	4f650513          	addi	a0,a0,1270 # ffffffffc0205f98 <commands+0x308>
ffffffffc0200aaa:	e3aff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200aae:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab0:	00005517          	auipc	a0,0x5
ffffffffc0200ab4:	50050513          	addi	a0,a0,1280 # ffffffffc0205fb0 <commands+0x320>
ffffffffc0200ab8:	e2cff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200abc:	604c                	ld	a1,128(s0)
ffffffffc0200abe:	00005517          	auipc	a0,0x5
ffffffffc0200ac2:	50a50513          	addi	a0,a0,1290 # ffffffffc0205fc8 <commands+0x338>
ffffffffc0200ac6:	e1eff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200aca:	644c                	ld	a1,136(s0)
ffffffffc0200acc:	00005517          	auipc	a0,0x5
ffffffffc0200ad0:	51450513          	addi	a0,a0,1300 # ffffffffc0205fe0 <commands+0x350>
ffffffffc0200ad4:	e10ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ad8:	684c                	ld	a1,144(s0)
ffffffffc0200ada:	00005517          	auipc	a0,0x5
ffffffffc0200ade:	51e50513          	addi	a0,a0,1310 # ffffffffc0205ff8 <commands+0x368>
ffffffffc0200ae2:	e02ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200ae6:	6c4c                	ld	a1,152(s0)
ffffffffc0200ae8:	00005517          	auipc	a0,0x5
ffffffffc0200aec:	52850513          	addi	a0,a0,1320 # ffffffffc0206010 <commands+0x380>
ffffffffc0200af0:	df4ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200af4:	704c                	ld	a1,160(s0)
ffffffffc0200af6:	00005517          	auipc	a0,0x5
ffffffffc0200afa:	53250513          	addi	a0,a0,1330 # ffffffffc0206028 <commands+0x398>
ffffffffc0200afe:	de6ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b02:	744c                	ld	a1,168(s0)
ffffffffc0200b04:	00005517          	auipc	a0,0x5
ffffffffc0200b08:	53c50513          	addi	a0,a0,1340 # ffffffffc0206040 <commands+0x3b0>
ffffffffc0200b0c:	dd8ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b10:	784c                	ld	a1,176(s0)
ffffffffc0200b12:	00005517          	auipc	a0,0x5
ffffffffc0200b16:	54650513          	addi	a0,a0,1350 # ffffffffc0206058 <commands+0x3c8>
ffffffffc0200b1a:	dcaff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b1e:	7c4c                	ld	a1,184(s0)
ffffffffc0200b20:	00005517          	auipc	a0,0x5
ffffffffc0200b24:	55050513          	addi	a0,a0,1360 # ffffffffc0206070 <commands+0x3e0>
ffffffffc0200b28:	dbcff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b2c:	606c                	ld	a1,192(s0)
ffffffffc0200b2e:	00005517          	auipc	a0,0x5
ffffffffc0200b32:	55a50513          	addi	a0,a0,1370 # ffffffffc0206088 <commands+0x3f8>
ffffffffc0200b36:	daeff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b3a:	646c                	ld	a1,200(s0)
ffffffffc0200b3c:	00005517          	auipc	a0,0x5
ffffffffc0200b40:	56450513          	addi	a0,a0,1380 # ffffffffc02060a0 <commands+0x410>
ffffffffc0200b44:	da0ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b48:	686c                	ld	a1,208(s0)
ffffffffc0200b4a:	00005517          	auipc	a0,0x5
ffffffffc0200b4e:	56e50513          	addi	a0,a0,1390 # ffffffffc02060b8 <commands+0x428>
ffffffffc0200b52:	d92ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b56:	6c6c                	ld	a1,216(s0)
ffffffffc0200b58:	00005517          	auipc	a0,0x5
ffffffffc0200b5c:	57850513          	addi	a0,a0,1400 # ffffffffc02060d0 <commands+0x440>
ffffffffc0200b60:	d84ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b64:	706c                	ld	a1,224(s0)
ffffffffc0200b66:	00005517          	auipc	a0,0x5
ffffffffc0200b6a:	58250513          	addi	a0,a0,1410 # ffffffffc02060e8 <commands+0x458>
ffffffffc0200b6e:	d76ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b72:	746c                	ld	a1,232(s0)
ffffffffc0200b74:	00005517          	auipc	a0,0x5
ffffffffc0200b78:	58c50513          	addi	a0,a0,1420 # ffffffffc0206100 <commands+0x470>
ffffffffc0200b7c:	d68ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b80:	786c                	ld	a1,240(s0)
ffffffffc0200b82:	00005517          	auipc	a0,0x5
ffffffffc0200b86:	59650513          	addi	a0,a0,1430 # ffffffffc0206118 <commands+0x488>
ffffffffc0200b8a:	d5aff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b8e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b90:	6402                	ld	s0,0(sp)
ffffffffc0200b92:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b94:	00005517          	auipc	a0,0x5
ffffffffc0200b98:	59c50513          	addi	a0,a0,1436 # ffffffffc0206130 <commands+0x4a0>
}
ffffffffc0200b9c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b9e:	d46ff06f          	j	ffffffffc02000e4 <cprintf>

ffffffffc0200ba2 <print_trapframe>:
{
ffffffffc0200ba2:	1141                	addi	sp,sp,-16
ffffffffc0200ba4:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200ba6:	85aa                	mv	a1,a0
{
ffffffffc0200ba8:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200baa:	00005517          	auipc	a0,0x5
ffffffffc0200bae:	59e50513          	addi	a0,a0,1438 # ffffffffc0206148 <commands+0x4b8>
{
ffffffffc0200bb2:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb4:	d30ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bb8:	8522                	mv	a0,s0
ffffffffc0200bba:	e1bff0ef          	jal	ra,ffffffffc02009d4 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bbe:	10043583          	ld	a1,256(s0)
ffffffffc0200bc2:	00005517          	auipc	a0,0x5
ffffffffc0200bc6:	59e50513          	addi	a0,a0,1438 # ffffffffc0206160 <commands+0x4d0>
ffffffffc0200bca:	d1aff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bce:	10843583          	ld	a1,264(s0)
ffffffffc0200bd2:	00005517          	auipc	a0,0x5
ffffffffc0200bd6:	5a650513          	addi	a0,a0,1446 # ffffffffc0206178 <commands+0x4e8>
ffffffffc0200bda:	d0aff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200bde:	11043583          	ld	a1,272(s0)
ffffffffc0200be2:	00005517          	auipc	a0,0x5
ffffffffc0200be6:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206190 <commands+0x500>
ffffffffc0200bea:	cfaff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bee:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf2:	6402                	ld	s0,0(sp)
ffffffffc0200bf4:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf6:	00005517          	auipc	a0,0x5
ffffffffc0200bfa:	5aa50513          	addi	a0,a0,1450 # ffffffffc02061a0 <commands+0x510>
}
ffffffffc0200bfe:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200c00:	ce4ff06f          	j	ffffffffc02000e4 <cprintf>

ffffffffc0200c04 <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c04:	11853783          	ld	a5,280(a0)
ffffffffc0200c08:	472d                	li	a4,11
ffffffffc0200c0a:	0786                	slli	a5,a5,0x1
ffffffffc0200c0c:	8385                	srli	a5,a5,0x1
ffffffffc0200c0e:	0af76363          	bltu	a4,a5,ffffffffc0200cb4 <interrupt_handler+0xb0>
ffffffffc0200c12:	00005717          	auipc	a4,0x5
ffffffffc0200c16:	65670713          	addi	a4,a4,1622 # ffffffffc0206268 <commands+0x5d8>
ffffffffc0200c1a:	078a                	slli	a5,a5,0x2
ffffffffc0200c1c:	97ba                	add	a5,a5,a4
ffffffffc0200c1e:	439c                	lw	a5,0(a5)
ffffffffc0200c20:	97ba                	add	a5,a5,a4
ffffffffc0200c22:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200c24:	00005517          	auipc	a0,0x5
ffffffffc0200c28:	5f450513          	addi	a0,a0,1524 # ffffffffc0206218 <commands+0x588>
ffffffffc0200c2c:	cb8ff06f          	j	ffffffffc02000e4 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c30:	00005517          	auipc	a0,0x5
ffffffffc0200c34:	5c850513          	addi	a0,a0,1480 # ffffffffc02061f8 <commands+0x568>
ffffffffc0200c38:	cacff06f          	j	ffffffffc02000e4 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c3c:	00005517          	auipc	a0,0x5
ffffffffc0200c40:	57c50513          	addi	a0,a0,1404 # ffffffffc02061b8 <commands+0x528>
ffffffffc0200c44:	ca0ff06f          	j	ffffffffc02000e4 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c48:	00005517          	auipc	a0,0x5
ffffffffc0200c4c:	59050513          	addi	a0,a0,1424 # ffffffffc02061d8 <commands+0x548>
ffffffffc0200c50:	c94ff06f          	j	ffffffffc02000e4 <cprintf>
{
ffffffffc0200c54:	1141                	addi	sp,sp,-16
ffffffffc0200c56:	e022                	sd	s0,0(sp)
ffffffffc0200c58:	e406                	sd	ra,8(sp)
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // clear_csr(sip, SIP_STIP);

        clock_set_next_event();
ffffffffc0200c5a:	cc9ff0ef          	jal	ra,ffffffffc0200922 <clock_set_next_event>
        ticks++;
ffffffffc0200c5e:	000c6797          	auipc	a5,0xc6
ffffffffc0200c62:	0ca78793          	addi	a5,a5,202 # ffffffffc02c6d28 <ticks>
ffffffffc0200c66:	6398                	ld	a4,0(a5)
ffffffffc0200c68:	000c6417          	auipc	s0,0xc6
ffffffffc0200c6c:	0c840413          	addi	s0,s0,200 # ffffffffc02c6d30 <num>
ffffffffc0200c70:	0705                	addi	a4,a4,1
ffffffffc0200c72:	e398                	sd	a4,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200c74:	639c                	ld	a5,0(a5)
ffffffffc0200c76:	06400713          	li	a4,100
ffffffffc0200c7a:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200c7e:	cf85                	beqz	a5,ffffffffc0200cb6 <interrupt_handler+0xb2>
        {
            print_ticks();
            num++;
        }
        sched_class_proc_tick(current);
ffffffffc0200c80:	000c6517          	auipc	a0,0xc6
ffffffffc0200c84:	0f053503          	ld	a0,240(a0) # ffffffffc02c6d70 <current>
ffffffffc0200c88:	520040ef          	jal	ra,ffffffffc02051a8 <sched_class_proc_tick>
        if (num == 10)
ffffffffc0200c8c:	4018                	lw	a4,0(s0)
ffffffffc0200c8e:	47a9                	li	a5,10
ffffffffc0200c90:	00f71863          	bne	a4,a5,ffffffffc0200ca0 <interrupt_handler+0x9c>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c94:	4501                	li	a0,0
ffffffffc0200c96:	4581                	li	a1,0
ffffffffc0200c98:	4601                	li	a2,0
ffffffffc0200c9a:	48a1                	li	a7,8
ffffffffc0200c9c:	00000073          	ecall
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200ca0:	60a2                	ld	ra,8(sp)
ffffffffc0200ca2:	6402                	ld	s0,0(sp)
ffffffffc0200ca4:	0141                	addi	sp,sp,16
ffffffffc0200ca6:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200ca8:	00005517          	auipc	a0,0x5
ffffffffc0200cac:	5a050513          	addi	a0,a0,1440 # ffffffffc0206248 <commands+0x5b8>
ffffffffc0200cb0:	c34ff06f          	j	ffffffffc02000e4 <cprintf>
        print_trapframe(tf);
ffffffffc0200cb4:	b5fd                	j	ffffffffc0200ba2 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200cb6:	06400593          	li	a1,100
ffffffffc0200cba:	00005517          	auipc	a0,0x5
ffffffffc0200cbe:	57e50513          	addi	a0,a0,1406 # ffffffffc0206238 <commands+0x5a8>
ffffffffc0200cc2:	c22ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
            num++;
ffffffffc0200cc6:	401c                	lw	a5,0(s0)
ffffffffc0200cc8:	2785                	addiw	a5,a5,1
ffffffffc0200cca:	c01c                	sw	a5,0(s0)
ffffffffc0200ccc:	bf55                	j	ffffffffc0200c80 <interrupt_handler+0x7c>

ffffffffc0200cce <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200cce:	11853783          	ld	a5,280(a0)
{
ffffffffc0200cd2:	715d                	addi	sp,sp,-80
ffffffffc0200cd4:	e0a2                	sd	s0,64(sp)
ffffffffc0200cd6:	e486                	sd	ra,72(sp)
ffffffffc0200cd8:	fc26                	sd	s1,56(sp)
ffffffffc0200cda:	f84a                	sd	s2,48(sp)
ffffffffc0200cdc:	f44e                	sd	s3,40(sp)
ffffffffc0200cde:	f052                	sd	s4,32(sp)
ffffffffc0200ce0:	ec56                	sd	s5,24(sp)
ffffffffc0200ce2:	e85a                	sd	s6,16(sp)
ffffffffc0200ce4:	e45e                	sd	s7,8(sp)
ffffffffc0200ce6:	473d                	li	a4,15
ffffffffc0200ce8:	842a                	mv	s0,a0
ffffffffc0200cea:	1ef76563          	bltu	a4,a5,ffffffffc0200ed4 <exception_handler+0x206>
ffffffffc0200cee:	00005717          	auipc	a4,0x5
ffffffffc0200cf2:	7e270713          	addi	a4,a4,2018 # ffffffffc02064d0 <commands+0x840>
ffffffffc0200cf6:	078a                	slli	a5,a5,0x2
ffffffffc0200cf8:	97ba                	add	a5,a5,a4
ffffffffc0200cfa:	439c                	lw	a5,0(a5)
ffffffffc0200cfc:	97ba                	add	a5,a5,a4
ffffffffc0200cfe:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d00:	00005517          	auipc	a0,0x5
ffffffffc0200d04:	68050513          	addi	a0,a0,1664 # ffffffffc0206380 <commands+0x6f0>
ffffffffc0200d08:	bdcff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
        tf->epc += 4;
ffffffffc0200d0c:	10843783          	ld	a5,264(s0)
    }
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d10:	60a6                	ld	ra,72(sp)
ffffffffc0200d12:	74e2                	ld	s1,56(sp)
        tf->epc += 4;
ffffffffc0200d14:	0791                	addi	a5,a5,4
ffffffffc0200d16:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d1a:	6406                	ld	s0,64(sp)
ffffffffc0200d1c:	7942                	ld	s2,48(sp)
ffffffffc0200d1e:	79a2                	ld	s3,40(sp)
ffffffffc0200d20:	7a02                	ld	s4,32(sp)
ffffffffc0200d22:	6ae2                	ld	s5,24(sp)
ffffffffc0200d24:	6b42                	ld	s6,16(sp)
ffffffffc0200d26:	6ba2                	ld	s7,8(sp)
ffffffffc0200d28:	6161                	addi	sp,sp,80
        syscall();
ffffffffc0200d2a:	76a0406f          	j	ffffffffc0205494 <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d2e:	00005517          	auipc	a0,0x5
ffffffffc0200d32:	67250513          	addi	a0,a0,1650 # ffffffffc02063a0 <commands+0x710>
}
ffffffffc0200d36:	6406                	ld	s0,64(sp)
ffffffffc0200d38:	60a6                	ld	ra,72(sp)
ffffffffc0200d3a:	74e2                	ld	s1,56(sp)
ffffffffc0200d3c:	7942                	ld	s2,48(sp)
ffffffffc0200d3e:	79a2                	ld	s3,40(sp)
ffffffffc0200d40:	7a02                	ld	s4,32(sp)
ffffffffc0200d42:	6ae2                	ld	s5,24(sp)
ffffffffc0200d44:	6b42                	ld	s6,16(sp)
ffffffffc0200d46:	6ba2                	ld	s7,8(sp)
ffffffffc0200d48:	6161                	addi	sp,sp,80
        cprintf("Instruction access fault\n");
ffffffffc0200d4a:	b9aff06f          	j	ffffffffc02000e4 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d4e:	00005517          	auipc	a0,0x5
ffffffffc0200d52:	67250513          	addi	a0,a0,1650 # ffffffffc02063c0 <commands+0x730>
ffffffffc0200d56:	b7c5                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Instruction page fault\n");
ffffffffc0200d58:	00005517          	auipc	a0,0x5
ffffffffc0200d5c:	68850513          	addi	a0,a0,1672 # ffffffffc02063e0 <commands+0x750>
ffffffffc0200d60:	bfd9                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Load page fault\n");
ffffffffc0200d62:	00005517          	auipc	a0,0x5
ffffffffc0200d66:	69650513          	addi	a0,a0,1686 # ffffffffc02063f8 <commands+0x768>
ffffffffc0200d6a:	b7f1                	j	ffffffffc0200d36 <exception_handler+0x68>
        if (current != NULL && current->mm != NULL)
ffffffffc0200d6c:	000c6497          	auipc	s1,0xc6
ffffffffc0200d70:	00448493          	addi	s1,s1,4 # ffffffffc02c6d70 <current>
ffffffffc0200d74:	609c                	ld	a5,0(s1)
ffffffffc0200d76:	16078b63          	beqz	a5,ffffffffc0200eec <exception_handler+0x21e>
ffffffffc0200d7a:	779c                	ld	a5,40(a5)
ffffffffc0200d7c:	16078863          	beqz	a5,ffffffffc0200eec <exception_handler+0x21e>
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200d80:	11053703          	ld	a4,272(a0)
ffffffffc0200d84:	747d                	lui	s0,0xfffff
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200d86:	6f88                	ld	a0,24(a5)
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200d88:	8c79                	and	s0,s0,a4
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200d8a:	4601                	li	a2,0
ffffffffc0200d8c:	85a2                	mv	a1,s0
ffffffffc0200d8e:	2ed010ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc0200d92:	87aa                	mv	a5,a0
            if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW))
ffffffffc0200d94:	14050c63          	beqz	a0,ffffffffc0200eec <exception_handler+0x21e>
ffffffffc0200d98:	6118                	ld	a4,0(a0)
ffffffffc0200d9a:	20100693          	li	a3,513
ffffffffc0200d9e:	20177613          	andi	a2,a4,513
ffffffffc0200da2:	14d61563          	bne	a2,a3,ffffffffc0200eec <exception_handler+0x21e>
}

static inline struct Page *
pte2page(pte_t pte)
{
    if (!(pte & PTE_V))
ffffffffc0200da6:	00177693          	andi	a3,a4,1
                uint32_t perm = (*ptep & PTE_USER);
ffffffffc0200daa:	0007091b          	sext.w	s2,a4
ffffffffc0200dae:	20068863          	beqz	a3,ffffffffc0200fbe <exception_handler+0x2f0>
    if (PPN(pa) >= npage)
ffffffffc0200db2:	000c6b17          	auipc	s6,0xc6
ffffffffc0200db6:	f9eb0b13          	addi	s6,s6,-98 # ffffffffc02c6d50 <npage>
ffffffffc0200dba:	000b3683          	ld	a3,0(s6)
    {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200dbe:	070a                	slli	a4,a4,0x2
ffffffffc0200dc0:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0200dc2:	1ed77263          	bgeu	a4,a3,ffffffffc0200fa6 <exception_handler+0x2d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0200dc6:	000c6b97          	auipc	s7,0xc6
ffffffffc0200dca:	f92b8b93          	addi	s7,s7,-110 # ffffffffc02c6d58 <pages>
ffffffffc0200dce:	000bb983          	ld	s3,0(s7)
ffffffffc0200dd2:	00007a17          	auipc	s4,0x7
ffffffffc0200dd6:	486a3a03          	ld	s4,1158(s4) # ffffffffc0208258 <nbase>
ffffffffc0200dda:	41470733          	sub	a4,a4,s4
ffffffffc0200dde:	071a                	slli	a4,a4,0x6
ffffffffc0200de0:	99ba                	add	s3,s3,a4
                if (page_ref(page) > 1)
ffffffffc0200de2:	0009a603          	lw	a2,0(s3)
ffffffffc0200de6:	4685                	li	a3,1
ffffffffc0200de8:	14c6dd63          	bge	a3,a2,ffffffffc0200f42 <exception_handler+0x274>
                    struct Page *npage = alloc_page();
ffffffffc0200dec:	4505                	li	a0,1
ffffffffc0200dee:	1d5010ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0200df2:	8aaa                	mv	s5,a0
                    if (npage == NULL)
ffffffffc0200df4:	18050d63          	beqz	a0,ffffffffc0200f8e <exception_handler+0x2c0>
    return page - pages + nbase;
ffffffffc0200df8:	000bb583          	ld	a1,0(s7)
    return KADDR(page2pa(page));
ffffffffc0200dfc:	577d                	li	a4,-1
ffffffffc0200dfe:	000b3603          	ld	a2,0(s6)
    return page - pages + nbase;
ffffffffc0200e02:	40b507b3          	sub	a5,a0,a1
ffffffffc0200e06:	8799                	srai	a5,a5,0x6
ffffffffc0200e08:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0200e0a:	8331                	srli	a4,a4,0xc
ffffffffc0200e0c:	00e7f533          	and	a0,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e10:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e14:	16c57163          	bgeu	a0,a2,ffffffffc0200f76 <exception_handler+0x2a8>
    return page - pages + nbase;
ffffffffc0200e18:	40b987b3          	sub	a5,s3,a1
ffffffffc0200e1c:	8799                	srai	a5,a5,0x6
ffffffffc0200e1e:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0200e20:	000c6597          	auipc	a1,0xc6
ffffffffc0200e24:	f485b583          	ld	a1,-184(a1) # ffffffffc02c6d68 <va_pa_offset>
ffffffffc0200e28:	8f7d                	and	a4,a4,a5
ffffffffc0200e2a:	00b68533          	add	a0,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e2e:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e32:	14c77263          	bgeu	a4,a2,ffffffffc0200f76 <exception_handler+0x2a8>
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0200e36:	95b6                	add	a1,a1,a3
ffffffffc0200e38:	6605                	lui	a2,0x1
ffffffffc0200e3a:	790040ef          	jal	ra,ffffffffc02055ca <memcpy>
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e3e:	609c                	ld	a5,0(s1)
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200e40:	01b97693          	andi	a3,s2,27
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e44:	0046e693          	ori	a3,a3,4
ffffffffc0200e48:	779c                	ld	a5,40(a5)
ffffffffc0200e4a:	8622                	mv	a2,s0
ffffffffc0200e4c:	85d6                	mv	a1,s5
ffffffffc0200e4e:	6f88                	ld	a0,24(a5)
ffffffffc0200e50:	11a020ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc0200e54:	c531                	beqz	a0,ffffffffc0200ea0 <exception_handler+0x1d2>
                        panic("COW: insert fail\n");
ffffffffc0200e56:	00005617          	auipc	a2,0x5
ffffffffc0200e5a:	64a60613          	addi	a2,a2,1610 # ffffffffc02064a0 <commands+0x810>
ffffffffc0200e5e:	0f500593          	li	a1,245
ffffffffc0200e62:	00005517          	auipc	a0,0x5
ffffffffc0200e66:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206350 <commands+0x6c0>
ffffffffc0200e6a:	bb8ff0ef          	jal	ra,ffffffffc0200222 <__panic>
        cprintf("Instruction address misaligned\n");
ffffffffc0200e6e:	00005517          	auipc	a0,0x5
ffffffffc0200e72:	42a50513          	addi	a0,a0,1066 # ffffffffc0206298 <commands+0x608>
ffffffffc0200e76:	b5c1                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Instruction access fault\n");
ffffffffc0200e78:	00005517          	auipc	a0,0x5
ffffffffc0200e7c:	44050513          	addi	a0,a0,1088 # ffffffffc02062b8 <commands+0x628>
ffffffffc0200e80:	bd5d                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Illegal instruction\n");
ffffffffc0200e82:	00005517          	auipc	a0,0x5
ffffffffc0200e86:	45650513          	addi	a0,a0,1110 # ffffffffc02062d8 <commands+0x648>
ffffffffc0200e8a:	b575                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Breakpoint\n");
ffffffffc0200e8c:	00005517          	auipc	a0,0x5
ffffffffc0200e90:	46450513          	addi	a0,a0,1124 # ffffffffc02062f0 <commands+0x660>
ffffffffc0200e94:	a50ff0ef          	jal	ra,ffffffffc02000e4 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200e98:	6458                	ld	a4,136(s0)
ffffffffc0200e9a:	47a9                	li	a5,10
ffffffffc0200e9c:	06f70963          	beq	a4,a5,ffffffffc0200f0e <exception_handler+0x240>
}
ffffffffc0200ea0:	60a6                	ld	ra,72(sp)
ffffffffc0200ea2:	6406                	ld	s0,64(sp)
ffffffffc0200ea4:	74e2                	ld	s1,56(sp)
ffffffffc0200ea6:	7942                	ld	s2,48(sp)
ffffffffc0200ea8:	79a2                	ld	s3,40(sp)
ffffffffc0200eaa:	7a02                	ld	s4,32(sp)
ffffffffc0200eac:	6ae2                	ld	s5,24(sp)
ffffffffc0200eae:	6b42                	ld	s6,16(sp)
ffffffffc0200eb0:	6ba2                	ld	s7,8(sp)
ffffffffc0200eb2:	6161                	addi	sp,sp,80
ffffffffc0200eb4:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200eb6:	00005517          	auipc	a0,0x5
ffffffffc0200eba:	44a50513          	addi	a0,a0,1098 # ffffffffc0206300 <commands+0x670>
ffffffffc0200ebe:	bda5                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Load access fault\n");
ffffffffc0200ec0:	00005517          	auipc	a0,0x5
ffffffffc0200ec4:	46050513          	addi	a0,a0,1120 # ffffffffc0206320 <commands+0x690>
ffffffffc0200ec8:	b5bd                	j	ffffffffc0200d36 <exception_handler+0x68>
        cprintf("Store/AMO access fault\n");
ffffffffc0200eca:	00005517          	auipc	a0,0x5
ffffffffc0200ece:	49e50513          	addi	a0,a0,1182 # ffffffffc0206368 <commands+0x6d8>
ffffffffc0200ed2:	b595                	j	ffffffffc0200d36 <exception_handler+0x68>
        print_trapframe(tf);
ffffffffc0200ed4:	8522                	mv	a0,s0
}
ffffffffc0200ed6:	6406                	ld	s0,64(sp)
ffffffffc0200ed8:	60a6                	ld	ra,72(sp)
ffffffffc0200eda:	74e2                	ld	s1,56(sp)
ffffffffc0200edc:	7942                	ld	s2,48(sp)
ffffffffc0200ede:	79a2                	ld	s3,40(sp)
ffffffffc0200ee0:	7a02                	ld	s4,32(sp)
ffffffffc0200ee2:	6ae2                	ld	s5,24(sp)
ffffffffc0200ee4:	6b42                	ld	s6,16(sp)
ffffffffc0200ee6:	6ba2                	ld	s7,8(sp)
ffffffffc0200ee8:	6161                	addi	sp,sp,80
        print_trapframe(tf);
ffffffffc0200eea:	b965                	j	ffffffffc0200ba2 <print_trapframe>
        cprintf("Store/AMO page fault\n");
ffffffffc0200eec:	00005517          	auipc	a0,0x5
ffffffffc0200ef0:	5cc50513          	addi	a0,a0,1484 # ffffffffc02064b8 <commands+0x828>
ffffffffc0200ef4:	b589                	j	ffffffffc0200d36 <exception_handler+0x68>
        panic("AMO address misaligned\n");
ffffffffc0200ef6:	00005617          	auipc	a2,0x5
ffffffffc0200efa:	44260613          	addi	a2,a2,1090 # ffffffffc0206338 <commands+0x6a8>
ffffffffc0200efe:	0c500593          	li	a1,197
ffffffffc0200f02:	00005517          	auipc	a0,0x5
ffffffffc0200f06:	44e50513          	addi	a0,a0,1102 # ffffffffc0206350 <commands+0x6c0>
ffffffffc0200f0a:	b18ff0ef          	jal	ra,ffffffffc0200222 <__panic>
            tf->epc += 4;
ffffffffc0200f0e:	10843783          	ld	a5,264(s0) # fffffffffffff108 <end+0x3fd38368>
ffffffffc0200f12:	0791                	addi	a5,a5,4
ffffffffc0200f14:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200f18:	57c040ef          	jal	ra,ffffffffc0205494 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200f1c:	000c6797          	auipc	a5,0xc6
ffffffffc0200f20:	e547b783          	ld	a5,-428(a5) # ffffffffc02c6d70 <current>
ffffffffc0200f24:	6b9c                	ld	a5,16(a5)
ffffffffc0200f26:	8522                	mv	a0,s0
}
ffffffffc0200f28:	6406                	ld	s0,64(sp)
ffffffffc0200f2a:	60a6                	ld	ra,72(sp)
ffffffffc0200f2c:	74e2                	ld	s1,56(sp)
ffffffffc0200f2e:	7942                	ld	s2,48(sp)
ffffffffc0200f30:	79a2                	ld	s3,40(sp)
ffffffffc0200f32:	7a02                	ld	s4,32(sp)
ffffffffc0200f34:	6ae2                	ld	s5,24(sp)
ffffffffc0200f36:	6b42                	ld	s6,16(sp)
ffffffffc0200f38:	6ba2                	ld	s7,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200f3a:	6589                	lui	a1,0x2
ffffffffc0200f3c:	95be                	add	a1,a1,a5
}
ffffffffc0200f3e:	6161                	addi	sp,sp,80
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200f40:	a2fd                	j	ffffffffc020112e <kernel_execve_ret>
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f42:	6094                	ld	a3,0(s1)
    return page - pages + nbase;
ffffffffc0200f44:	8719                	srai	a4,a4,0x6
ffffffffc0200f46:	9752                	add	a4,a4,s4
ffffffffc0200f48:	7694                	ld	a3,40(a3)
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200f4a:	01b97913          	andi	s2,s2,27
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f4e:	072a                	slli	a4,a4,0xa
ffffffffc0200f50:	00e96733          	or	a4,s2,a4
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f54:	85a2                	mv	a1,s0
}
ffffffffc0200f56:	6406                	ld	s0,64(sp)
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f58:	6e88                	ld	a0,24(a3)
}
ffffffffc0200f5a:	60a6                	ld	ra,72(sp)
ffffffffc0200f5c:	74e2                	ld	s1,56(sp)
ffffffffc0200f5e:	7942                	ld	s2,48(sp)
ffffffffc0200f60:	79a2                	ld	s3,40(sp)
ffffffffc0200f62:	7a02                	ld	s4,32(sp)
ffffffffc0200f64:	6ae2                	ld	s5,24(sp)
ffffffffc0200f66:	6b42                	ld	s6,16(sp)
ffffffffc0200f68:	6ba2                	ld	s7,8(sp)
ffffffffc0200f6a:	00576713          	ori	a4,a4,5
                    *ptep = pte_create(page2ppn(page), perm | PTE_V);
ffffffffc0200f6e:	e398                	sd	a4,0(a5)
}
ffffffffc0200f70:	6161                	addi	sp,sp,80
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f72:	6a50206f          	j	ffffffffc0203e16 <tlb_invalidate>
    return KADDR(page2pa(page));
ffffffffc0200f76:	00005617          	auipc	a2,0x5
ffffffffc0200f7a:	50260613          	addi	a2,a2,1282 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0200f7e:	07100593          	li	a1,113
ffffffffc0200f82:	00005517          	auipc	a0,0x5
ffffffffc0200f86:	4b650513          	addi	a0,a0,1206 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0200f8a:	a98ff0ef          	jal	ra,ffffffffc0200222 <__panic>
                        panic("COW: no mem\n");
ffffffffc0200f8e:	00005617          	auipc	a2,0x5
ffffffffc0200f92:	4da60613          	addi	a2,a2,1242 # ffffffffc0206468 <commands+0x7d8>
ffffffffc0200f96:	0ef00593          	li	a1,239
ffffffffc0200f9a:	00005517          	auipc	a0,0x5
ffffffffc0200f9e:	3b650513          	addi	a0,a0,950 # ffffffffc0206350 <commands+0x6c0>
ffffffffc0200fa2:	a80ff0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200fa6:	00005617          	auipc	a2,0x5
ffffffffc0200faa:	4a260613          	addi	a2,a2,1186 # ffffffffc0206448 <commands+0x7b8>
ffffffffc0200fae:	06900593          	li	a1,105
ffffffffc0200fb2:	00005517          	auipc	a0,0x5
ffffffffc0200fb6:	48650513          	addi	a0,a0,1158 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0200fba:	a68ff0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0200fbe:	00005617          	auipc	a2,0x5
ffffffffc0200fc2:	45260613          	addi	a2,a2,1106 # ffffffffc0206410 <commands+0x780>
ffffffffc0200fc6:	07f00593          	li	a1,127
ffffffffc0200fca:	00005517          	auipc	a0,0x5
ffffffffc0200fce:	46e50513          	addi	a0,a0,1134 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0200fd2:	a50ff0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0200fd6 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200fd6:	1101                	addi	sp,sp,-32
ffffffffc0200fd8:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200fda:	000c6417          	auipc	s0,0xc6
ffffffffc0200fde:	d9640413          	addi	s0,s0,-618 # ffffffffc02c6d70 <current>
ffffffffc0200fe2:	6018                	ld	a4,0(s0)
{
ffffffffc0200fe4:	ec06                	sd	ra,24(sp)
ffffffffc0200fe6:	e426                	sd	s1,8(sp)
ffffffffc0200fe8:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200fea:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0200fee:	cf1d                	beqz	a4,ffffffffc020102c <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200ff0:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200ff4:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200ff8:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200ffa:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ffe:	0206c463          	bltz	a3,ffffffffc0201026 <trap+0x50>
        exception_handler(tf);
ffffffffc0201002:	ccdff0ef          	jal	ra,ffffffffc0200cce <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0201006:	601c                	ld	a5,0(s0)
ffffffffc0201008:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc020100c:	e499                	bnez	s1,ffffffffc020101a <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc020100e:	0b07a703          	lw	a4,176(a5)
ffffffffc0201012:	8b05                	andi	a4,a4,1
ffffffffc0201014:	e329                	bnez	a4,ffffffffc0201056 <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0201016:	6f9c                	ld	a5,24(a5)
ffffffffc0201018:	eb85                	bnez	a5,ffffffffc0201048 <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc020101a:	60e2                	ld	ra,24(sp)
ffffffffc020101c:	6442                	ld	s0,16(sp)
ffffffffc020101e:	64a2                	ld	s1,8(sp)
ffffffffc0201020:	6902                	ld	s2,0(sp)
ffffffffc0201022:	6105                	addi	sp,sp,32
ffffffffc0201024:	8082                	ret
        interrupt_handler(tf);
ffffffffc0201026:	bdfff0ef          	jal	ra,ffffffffc0200c04 <interrupt_handler>
ffffffffc020102a:	bff1                	j	ffffffffc0201006 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc020102c:	0006c863          	bltz	a3,ffffffffc020103c <trap+0x66>
}
ffffffffc0201030:	6442                	ld	s0,16(sp)
ffffffffc0201032:	60e2                	ld	ra,24(sp)
ffffffffc0201034:	64a2                	ld	s1,8(sp)
ffffffffc0201036:	6902                	ld	s2,0(sp)
ffffffffc0201038:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc020103a:	b951                	j	ffffffffc0200cce <exception_handler>
}
ffffffffc020103c:	6442                	ld	s0,16(sp)
ffffffffc020103e:	60e2                	ld	ra,24(sp)
ffffffffc0201040:	64a2                	ld	s1,8(sp)
ffffffffc0201042:	6902                	ld	s2,0(sp)
ffffffffc0201044:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0201046:	be7d                	j	ffffffffc0200c04 <interrupt_handler>
}
ffffffffc0201048:	6442                	ld	s0,16(sp)
ffffffffc020104a:	60e2                	ld	ra,24(sp)
ffffffffc020104c:	64a2                	ld	s1,8(sp)
ffffffffc020104e:	6902                	ld	s2,0(sp)
ffffffffc0201050:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0201052:	2820406f          	j	ffffffffc02052d4 <schedule>
                do_exit(-E_KILLED);
ffffffffc0201056:	555d                	li	a0,-9
ffffffffc0201058:	4b0030ef          	jal	ra,ffffffffc0204508 <do_exit>
            if (current->need_resched)
ffffffffc020105c:	601c                	ld	a5,0(s0)
ffffffffc020105e:	bf65                	j	ffffffffc0201016 <trap+0x40>

ffffffffc0201060 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0201060:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0201064:	00011463          	bnez	sp,ffffffffc020106c <__alltraps+0xc>
ffffffffc0201068:	14002173          	csrr	sp,sscratch
ffffffffc020106c:	712d                	addi	sp,sp,-288
ffffffffc020106e:	e002                	sd	zero,0(sp)
ffffffffc0201070:	e406                	sd	ra,8(sp)
ffffffffc0201072:	ec0e                	sd	gp,24(sp)
ffffffffc0201074:	f012                	sd	tp,32(sp)
ffffffffc0201076:	f416                	sd	t0,40(sp)
ffffffffc0201078:	f81a                	sd	t1,48(sp)
ffffffffc020107a:	fc1e                	sd	t2,56(sp)
ffffffffc020107c:	e0a2                	sd	s0,64(sp)
ffffffffc020107e:	e4a6                	sd	s1,72(sp)
ffffffffc0201080:	e8aa                	sd	a0,80(sp)
ffffffffc0201082:	ecae                	sd	a1,88(sp)
ffffffffc0201084:	f0b2                	sd	a2,96(sp)
ffffffffc0201086:	f4b6                	sd	a3,104(sp)
ffffffffc0201088:	f8ba                	sd	a4,112(sp)
ffffffffc020108a:	fcbe                	sd	a5,120(sp)
ffffffffc020108c:	e142                	sd	a6,128(sp)
ffffffffc020108e:	e546                	sd	a7,136(sp)
ffffffffc0201090:	e94a                	sd	s2,144(sp)
ffffffffc0201092:	ed4e                	sd	s3,152(sp)
ffffffffc0201094:	f152                	sd	s4,160(sp)
ffffffffc0201096:	f556                	sd	s5,168(sp)
ffffffffc0201098:	f95a                	sd	s6,176(sp)
ffffffffc020109a:	fd5e                	sd	s7,184(sp)
ffffffffc020109c:	e1e2                	sd	s8,192(sp)
ffffffffc020109e:	e5e6                	sd	s9,200(sp)
ffffffffc02010a0:	e9ea                	sd	s10,208(sp)
ffffffffc02010a2:	edee                	sd	s11,216(sp)
ffffffffc02010a4:	f1f2                	sd	t3,224(sp)
ffffffffc02010a6:	f5f6                	sd	t4,232(sp)
ffffffffc02010a8:	f9fa                	sd	t5,240(sp)
ffffffffc02010aa:	fdfe                	sd	t6,248(sp)
ffffffffc02010ac:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02010b0:	100024f3          	csrr	s1,sstatus
ffffffffc02010b4:	14102973          	csrr	s2,sepc
ffffffffc02010b8:	143029f3          	csrr	s3,stval
ffffffffc02010bc:	14202a73          	csrr	s4,scause
ffffffffc02010c0:	e822                	sd	s0,16(sp)
ffffffffc02010c2:	e226                	sd	s1,256(sp)
ffffffffc02010c4:	e64a                	sd	s2,264(sp)
ffffffffc02010c6:	ea4e                	sd	s3,272(sp)
ffffffffc02010c8:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02010ca:	850a                	mv	a0,sp
    jal trap
ffffffffc02010cc:	f0bff0ef          	jal	ra,ffffffffc0200fd6 <trap>

ffffffffc02010d0 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02010d0:	6492                	ld	s1,256(sp)
ffffffffc02010d2:	6932                	ld	s2,264(sp)
ffffffffc02010d4:	1004f413          	andi	s0,s1,256
ffffffffc02010d8:	e401                	bnez	s0,ffffffffc02010e0 <__trapret+0x10>
ffffffffc02010da:	1200                	addi	s0,sp,288
ffffffffc02010dc:	14041073          	csrw	sscratch,s0
ffffffffc02010e0:	10049073          	csrw	sstatus,s1
ffffffffc02010e4:	14191073          	csrw	sepc,s2
ffffffffc02010e8:	60a2                	ld	ra,8(sp)
ffffffffc02010ea:	61e2                	ld	gp,24(sp)
ffffffffc02010ec:	7202                	ld	tp,32(sp)
ffffffffc02010ee:	72a2                	ld	t0,40(sp)
ffffffffc02010f0:	7342                	ld	t1,48(sp)
ffffffffc02010f2:	73e2                	ld	t2,56(sp)
ffffffffc02010f4:	6406                	ld	s0,64(sp)
ffffffffc02010f6:	64a6                	ld	s1,72(sp)
ffffffffc02010f8:	6546                	ld	a0,80(sp)
ffffffffc02010fa:	65e6                	ld	a1,88(sp)
ffffffffc02010fc:	7606                	ld	a2,96(sp)
ffffffffc02010fe:	76a6                	ld	a3,104(sp)
ffffffffc0201100:	7746                	ld	a4,112(sp)
ffffffffc0201102:	77e6                	ld	a5,120(sp)
ffffffffc0201104:	680a                	ld	a6,128(sp)
ffffffffc0201106:	68aa                	ld	a7,136(sp)
ffffffffc0201108:	694a                	ld	s2,144(sp)
ffffffffc020110a:	69ea                	ld	s3,152(sp)
ffffffffc020110c:	7a0a                	ld	s4,160(sp)
ffffffffc020110e:	7aaa                	ld	s5,168(sp)
ffffffffc0201110:	7b4a                	ld	s6,176(sp)
ffffffffc0201112:	7bea                	ld	s7,184(sp)
ffffffffc0201114:	6c0e                	ld	s8,192(sp)
ffffffffc0201116:	6cae                	ld	s9,200(sp)
ffffffffc0201118:	6d4e                	ld	s10,208(sp)
ffffffffc020111a:	6dee                	ld	s11,216(sp)
ffffffffc020111c:	7e0e                	ld	t3,224(sp)
ffffffffc020111e:	7eae                	ld	t4,232(sp)
ffffffffc0201120:	7f4e                	ld	t5,240(sp)
ffffffffc0201122:	7fee                	ld	t6,248(sp)
ffffffffc0201124:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0201126:	10200073          	sret

ffffffffc020112a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc020112a:	812a                	mv	sp,a0
    j __trapret
ffffffffc020112c:	b755                	j	ffffffffc02010d0 <__trapret>

ffffffffc020112e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    # adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc020112e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8080>

    # copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0201132:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0201136:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc020113a:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc020113e:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0201142:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0201146:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc020114a:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc020114e:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0201152:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0201154:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0201156:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0201158:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc020115a:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc020115c:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc020115e:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0201160:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0201162:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0201164:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0201166:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0201168:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc020116a:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc020116c:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc020116e:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0201170:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0201172:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0201174:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0201176:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0201178:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc020117a:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc020117c:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc020117e:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0201180:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0201182:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0201184:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0201186:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0201188:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc020118a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc020118c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc020118e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0201190:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0201192:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201194:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0201196:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201198:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc020119a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc020119c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc020119e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc02011a0:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc02011a2:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc02011a4:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc02011a6:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc02011a8:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc02011aa:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc02011ac:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc02011ae:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc02011b0:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc02011b2:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc02011b4:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc02011b6:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc02011b8:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc02011ba:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc02011bc:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc02011be:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc02011c0:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc02011c2:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc02011c4:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc02011c6:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc02011c8:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc02011ca:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc02011cc:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc02011ce:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc02011d0:	e184                	sd	s1,0(a1)

    # acutually adjust sp
    move sp, a1
ffffffffc02011d2:	812e                	mv	sp,a1
ffffffffc02011d4:	bdf5                	j	ffffffffc02010d0 <__trapret>

ffffffffc02011d6 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02011d6:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02011d8:	00005697          	auipc	a3,0x5
ffffffffc02011dc:	33868693          	addi	a3,a3,824 # ffffffffc0206510 <commands+0x880>
ffffffffc02011e0:	00005617          	auipc	a2,0x5
ffffffffc02011e4:	35060613          	addi	a2,a2,848 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02011e8:	07400593          	li	a1,116
ffffffffc02011ec:	00005517          	auipc	a0,0x5
ffffffffc02011f0:	35c50513          	addi	a0,a0,860 # ffffffffc0206548 <commands+0x8b8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02011f4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02011f6:	82cff0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02011fa <mm_create>:
{
ffffffffc02011fa:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02011fc:	04000513          	li	a0,64
{
ffffffffc0201200:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201202:	135000ef          	jal	ra,ffffffffc0201b36 <kmalloc>
    if (mm != NULL)
ffffffffc0201206:	cd19                	beqz	a0,ffffffffc0201224 <mm_create+0x2a>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201208:	e508                	sd	a0,8(a0)
ffffffffc020120a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020120c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201210:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201214:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0201218:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020121c:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0201220:	02053c23          	sd	zero,56(a0)
}
ffffffffc0201224:	60a2                	ld	ra,8(sp)
ffffffffc0201226:	0141                	addi	sp,sp,16
ffffffffc0201228:	8082                	ret

ffffffffc020122a <find_vma>:
{
ffffffffc020122a:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc020122c:	c505                	beqz	a0,ffffffffc0201254 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc020122e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0201230:	c501                	beqz	a0,ffffffffc0201238 <find_vma+0xe>
ffffffffc0201232:	651c                	ld	a5,8(a0)
ffffffffc0201234:	02f5f263          	bgeu	a1,a5,ffffffffc0201258 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201238:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020123a:	00f68d63          	beq	a3,a5,ffffffffc0201254 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020123e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201242:	00e5e663          	bltu	a1,a4,ffffffffc020124e <find_vma+0x24>
ffffffffc0201246:	ff07b703          	ld	a4,-16(a5)
ffffffffc020124a:	00e5ec63          	bltu	a1,a4,ffffffffc0201262 <find_vma+0x38>
ffffffffc020124e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0201250:	fef697e3          	bne	a3,a5,ffffffffc020123e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201254:	4501                	li	a0,0
}
ffffffffc0201256:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0201258:	691c                	ld	a5,16(a0)
ffffffffc020125a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0201238 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020125e:	ea88                	sd	a0,16(a3)
ffffffffc0201260:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0201262:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0201266:	ea88                	sd	a0,16(a3)
ffffffffc0201268:	8082                	ret

ffffffffc020126a <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020126a:	6590                	ld	a2,8(a1)
ffffffffc020126c:	0105b803          	ld	a6,16(a1)
{
ffffffffc0201270:	1141                	addi	sp,sp,-16
ffffffffc0201272:	e406                	sd	ra,8(sp)
ffffffffc0201274:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201276:	01066763          	bltu	a2,a6,ffffffffc0201284 <insert_vma_struct+0x1a>
ffffffffc020127a:	a085                	j	ffffffffc02012da <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020127c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201280:	04e66863          	bltu	a2,a4,ffffffffc02012d0 <insert_vma_struct+0x66>
ffffffffc0201284:	86be                	mv	a3,a5
ffffffffc0201286:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0201288:	fef51ae3          	bne	a0,a5,ffffffffc020127c <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020128c:	02a68463          	beq	a3,a0,ffffffffc02012b4 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201290:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201294:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201298:	08e8f163          	bgeu	a7,a4,ffffffffc020131a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020129c:	04e66f63          	bltu	a2,a4,ffffffffc02012fa <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02012a0:	00f50a63          	beq	a0,a5,ffffffffc02012b4 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02012a4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02012a8:	05076963          	bltu	a4,a6,ffffffffc02012fa <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02012ac:	ff07b603          	ld	a2,-16(a5)
ffffffffc02012b0:	02c77363          	bgeu	a4,a2,ffffffffc02012d6 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02012b4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02012b6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02012b8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012bc:	e390                	sd	a2,0(a5)
ffffffffc02012be:	e690                	sd	a2,8(a3)
}
ffffffffc02012c0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02012c2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02012c4:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02012c6:	0017079b          	addiw	a5,a4,1
ffffffffc02012ca:	d11c                	sw	a5,32(a0)
}
ffffffffc02012cc:	0141                	addi	sp,sp,16
ffffffffc02012ce:	8082                	ret
    if (le_prev != list)
ffffffffc02012d0:	fca690e3          	bne	a3,a0,ffffffffc0201290 <insert_vma_struct+0x26>
ffffffffc02012d4:	bfd1                	j	ffffffffc02012a8 <insert_vma_struct+0x3e>
ffffffffc02012d6:	f01ff0ef          	jal	ra,ffffffffc02011d6 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02012da:	00005697          	auipc	a3,0x5
ffffffffc02012de:	27e68693          	addi	a3,a3,638 # ffffffffc0206558 <commands+0x8c8>
ffffffffc02012e2:	00005617          	auipc	a2,0x5
ffffffffc02012e6:	24e60613          	addi	a2,a2,590 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02012ea:	07a00593          	li	a1,122
ffffffffc02012ee:	00005517          	auipc	a0,0x5
ffffffffc02012f2:	25a50513          	addi	a0,a0,602 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02012f6:	f2dfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02012fa:	00005697          	auipc	a3,0x5
ffffffffc02012fe:	29e68693          	addi	a3,a3,670 # ffffffffc0206598 <commands+0x908>
ffffffffc0201302:	00005617          	auipc	a2,0x5
ffffffffc0201306:	22e60613          	addi	a2,a2,558 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020130a:	07300593          	li	a1,115
ffffffffc020130e:	00005517          	auipc	a0,0x5
ffffffffc0201312:	23a50513          	addi	a0,a0,570 # ffffffffc0206548 <commands+0x8b8>
ffffffffc0201316:	f0dfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020131a:	00005697          	auipc	a3,0x5
ffffffffc020131e:	25e68693          	addi	a3,a3,606 # ffffffffc0206578 <commands+0x8e8>
ffffffffc0201322:	00005617          	auipc	a2,0x5
ffffffffc0201326:	20e60613          	addi	a2,a2,526 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020132a:	07200593          	li	a1,114
ffffffffc020132e:	00005517          	auipc	a0,0x5
ffffffffc0201332:	21a50513          	addi	a0,a0,538 # ffffffffc0206548 <commands+0x8b8>
ffffffffc0201336:	eedfe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020133a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020133a:	591c                	lw	a5,48(a0)
{
ffffffffc020133c:	1141                	addi	sp,sp,-16
ffffffffc020133e:	e406                	sd	ra,8(sp)
ffffffffc0201340:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0201342:	e78d                	bnez	a5,ffffffffc020136c <mm_destroy+0x32>
ffffffffc0201344:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0201346:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0201348:	00a40c63          	beq	s0,a0,ffffffffc0201360 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020134c:	6118                	ld	a4,0(a0)
ffffffffc020134e:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0201350:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201352:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201354:	e398                	sd	a4,0(a5)
ffffffffc0201356:	091000ef          	jal	ra,ffffffffc0201be6 <kfree>
    return listelm->next;
ffffffffc020135a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc020135c:	fea418e3          	bne	s0,a0,ffffffffc020134c <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0201360:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0201362:	6402                	ld	s0,0(sp)
ffffffffc0201364:	60a2                	ld	ra,8(sp)
ffffffffc0201366:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0201368:	07f0006f          	j	ffffffffc0201be6 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020136c:	00005697          	auipc	a3,0x5
ffffffffc0201370:	24c68693          	addi	a3,a3,588 # ffffffffc02065b8 <commands+0x928>
ffffffffc0201374:	00005617          	auipc	a2,0x5
ffffffffc0201378:	1bc60613          	addi	a2,a2,444 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020137c:	09e00593          	li	a1,158
ffffffffc0201380:	00005517          	auipc	a0,0x5
ffffffffc0201384:	1c850513          	addi	a0,a0,456 # ffffffffc0206548 <commands+0x8b8>
ffffffffc0201388:	e9bfe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020138c <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc020138c:	7139                	addi	sp,sp,-64
ffffffffc020138e:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201390:	6405                	lui	s0,0x1
ffffffffc0201392:	147d                	addi	s0,s0,-1
ffffffffc0201394:	77fd                	lui	a5,0xfffff
ffffffffc0201396:	9622                	add	a2,a2,s0
ffffffffc0201398:	962e                	add	a2,a2,a1
{
ffffffffc020139a:	f426                	sd	s1,40(sp)
ffffffffc020139c:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020139e:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02013a2:	f04a                	sd	s2,32(sp)
ffffffffc02013a4:	ec4e                	sd	s3,24(sp)
ffffffffc02013a6:	e852                	sd	s4,16(sp)
ffffffffc02013a8:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02013aa:	002005b7          	lui	a1,0x200
ffffffffc02013ae:	00f67433          	and	s0,a2,a5
ffffffffc02013b2:	06b4e363          	bltu	s1,a1,ffffffffc0201418 <mm_map+0x8c>
ffffffffc02013b6:	0684f163          	bgeu	s1,s0,ffffffffc0201418 <mm_map+0x8c>
ffffffffc02013ba:	4785                	li	a5,1
ffffffffc02013bc:	07fe                	slli	a5,a5,0x1f
ffffffffc02013be:	0487ed63          	bltu	a5,s0,ffffffffc0201418 <mm_map+0x8c>
ffffffffc02013c2:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02013c4:	cd21                	beqz	a0,ffffffffc020141c <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02013c6:	85a6                	mv	a1,s1
ffffffffc02013c8:	8ab6                	mv	s5,a3
ffffffffc02013ca:	8a3a                	mv	s4,a4
ffffffffc02013cc:	e5fff0ef          	jal	ra,ffffffffc020122a <find_vma>
ffffffffc02013d0:	c501                	beqz	a0,ffffffffc02013d8 <mm_map+0x4c>
ffffffffc02013d2:	651c                	ld	a5,8(a0)
ffffffffc02013d4:	0487e263          	bltu	a5,s0,ffffffffc0201418 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013d8:	03000513          	li	a0,48
ffffffffc02013dc:	75a000ef          	jal	ra,ffffffffc0201b36 <kmalloc>
ffffffffc02013e0:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02013e2:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02013e4:	02090163          	beqz	s2,ffffffffc0201406 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02013e8:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02013ea:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02013ee:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02013f2:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02013f6:	85ca                	mv	a1,s2
ffffffffc02013f8:	e73ff0ef          	jal	ra,ffffffffc020126a <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02013fc:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc02013fe:	000a0463          	beqz	s4,ffffffffc0201406 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0201402:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0201406:	70e2                	ld	ra,56(sp)
ffffffffc0201408:	7442                	ld	s0,48(sp)
ffffffffc020140a:	74a2                	ld	s1,40(sp)
ffffffffc020140c:	7902                	ld	s2,32(sp)
ffffffffc020140e:	69e2                	ld	s3,24(sp)
ffffffffc0201410:	6a42                	ld	s4,16(sp)
ffffffffc0201412:	6aa2                	ld	s5,8(sp)
ffffffffc0201414:	6121                	addi	sp,sp,64
ffffffffc0201416:	8082                	ret
        return -E_INVAL;
ffffffffc0201418:	5575                	li	a0,-3
ffffffffc020141a:	b7f5                	j	ffffffffc0201406 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc020141c:	00005697          	auipc	a3,0x5
ffffffffc0201420:	1b468693          	addi	a3,a3,436 # ffffffffc02065d0 <commands+0x940>
ffffffffc0201424:	00005617          	auipc	a2,0x5
ffffffffc0201428:	10c60613          	addi	a2,a2,268 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020142c:	0b300593          	li	a1,179
ffffffffc0201430:	00005517          	auipc	a0,0x5
ffffffffc0201434:	11850513          	addi	a0,a0,280 # ffffffffc0206548 <commands+0x8b8>
ffffffffc0201438:	debfe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020143c <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc020143c:	7139                	addi	sp,sp,-64
ffffffffc020143e:	fc06                	sd	ra,56(sp)
ffffffffc0201440:	f822                	sd	s0,48(sp)
ffffffffc0201442:	f426                	sd	s1,40(sp)
ffffffffc0201444:	f04a                	sd	s2,32(sp)
ffffffffc0201446:	ec4e                	sd	s3,24(sp)
ffffffffc0201448:	e852                	sd	s4,16(sp)
ffffffffc020144a:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020144c:	c52d                	beqz	a0,ffffffffc02014b6 <dup_mmap+0x7a>
ffffffffc020144e:	892a                	mv	s2,a0
ffffffffc0201450:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0201452:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0201454:	e595                	bnez	a1,ffffffffc0201480 <dup_mmap+0x44>
ffffffffc0201456:	a085                	j	ffffffffc02014b6 <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0201458:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc020145a:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_matrix_out_size+0x1f38e0>
        vma->vm_end = vm_end;
ffffffffc020145e:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0201462:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0201466:	e05ff0ef          	jal	ra,ffffffffc020126a <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc020146a:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8f70>
ffffffffc020146e:	fe843603          	ld	a2,-24(s0)
ffffffffc0201472:	6c8c                	ld	a1,24(s1)
ffffffffc0201474:	01893503          	ld	a0,24(s2)
ffffffffc0201478:	4701                	li	a4,0
ffffffffc020147a:	027020ef          	jal	ra,ffffffffc0203ca0 <copy_range>
ffffffffc020147e:	e105                	bnez	a0,ffffffffc020149e <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0201480:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0201482:	02848863          	beq	s1,s0,ffffffffc02014b2 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201486:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020148a:	fe843a83          	ld	s5,-24(s0)
ffffffffc020148e:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201492:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201496:	6a0000ef          	jal	ra,ffffffffc0201b36 <kmalloc>
ffffffffc020149a:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc020149c:	fd55                	bnez	a0,ffffffffc0201458 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020149e:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02014a0:	70e2                	ld	ra,56(sp)
ffffffffc02014a2:	7442                	ld	s0,48(sp)
ffffffffc02014a4:	74a2                	ld	s1,40(sp)
ffffffffc02014a6:	7902                	ld	s2,32(sp)
ffffffffc02014a8:	69e2                	ld	s3,24(sp)
ffffffffc02014aa:	6a42                	ld	s4,16(sp)
ffffffffc02014ac:	6aa2                	ld	s5,8(sp)
ffffffffc02014ae:	6121                	addi	sp,sp,64
ffffffffc02014b0:	8082                	ret
    return 0;
ffffffffc02014b2:	4501                	li	a0,0
ffffffffc02014b4:	b7f5                	j	ffffffffc02014a0 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02014b6:	00005697          	auipc	a3,0x5
ffffffffc02014ba:	12a68693          	addi	a3,a3,298 # ffffffffc02065e0 <commands+0x950>
ffffffffc02014be:	00005617          	auipc	a2,0x5
ffffffffc02014c2:	07260613          	addi	a2,a2,114 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02014c6:	0cf00593          	li	a1,207
ffffffffc02014ca:	00005517          	auipc	a0,0x5
ffffffffc02014ce:	07e50513          	addi	a0,a0,126 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02014d2:	d51fe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02014d6 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02014d6:	1101                	addi	sp,sp,-32
ffffffffc02014d8:	ec06                	sd	ra,24(sp)
ffffffffc02014da:	e822                	sd	s0,16(sp)
ffffffffc02014dc:	e426                	sd	s1,8(sp)
ffffffffc02014de:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02014e0:	c531                	beqz	a0,ffffffffc020152c <exit_mmap+0x56>
ffffffffc02014e2:	591c                	lw	a5,48(a0)
ffffffffc02014e4:	84aa                	mv	s1,a0
ffffffffc02014e6:	e3b9                	bnez	a5,ffffffffc020152c <exit_mmap+0x56>
    return listelm->next;
ffffffffc02014e8:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02014ea:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02014ee:	02850663          	beq	a0,s0,ffffffffc020151a <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02014f2:	ff043603          	ld	a2,-16(s0)
ffffffffc02014f6:	fe843583          	ld	a1,-24(s0)
ffffffffc02014fa:	854a                	mv	a0,s2
ffffffffc02014fc:	5fa010ef          	jal	ra,ffffffffc0202af6 <unmap_range>
ffffffffc0201500:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0201502:	fe8498e3          	bne	s1,s0,ffffffffc02014f2 <exit_mmap+0x1c>
ffffffffc0201506:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0201508:	00848c63          	beq	s1,s0,ffffffffc0201520 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020150c:	ff043603          	ld	a2,-16(s0)
ffffffffc0201510:	fe843583          	ld	a1,-24(s0)
ffffffffc0201514:	854a                	mv	a0,s2
ffffffffc0201516:	726010ef          	jal	ra,ffffffffc0202c3c <exit_range>
ffffffffc020151a:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020151c:	fe8498e3          	bne	s1,s0,ffffffffc020150c <exit_mmap+0x36>
    }
}
ffffffffc0201520:	60e2                	ld	ra,24(sp)
ffffffffc0201522:	6442                	ld	s0,16(sp)
ffffffffc0201524:	64a2                	ld	s1,8(sp)
ffffffffc0201526:	6902                	ld	s2,0(sp)
ffffffffc0201528:	6105                	addi	sp,sp,32
ffffffffc020152a:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020152c:	00005697          	auipc	a3,0x5
ffffffffc0201530:	0d468693          	addi	a3,a3,212 # ffffffffc0206600 <commands+0x970>
ffffffffc0201534:	00005617          	auipc	a2,0x5
ffffffffc0201538:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020153c:	0e800593          	li	a1,232
ffffffffc0201540:	00005517          	auipc	a0,0x5
ffffffffc0201544:	00850513          	addi	a0,a0,8 # ffffffffc0206548 <commands+0x8b8>
ffffffffc0201548:	cdbfe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020154c <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc020154c:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020154e:	04000513          	li	a0,64
{
ffffffffc0201552:	fc06                	sd	ra,56(sp)
ffffffffc0201554:	f822                	sd	s0,48(sp)
ffffffffc0201556:	f426                	sd	s1,40(sp)
ffffffffc0201558:	f04a                	sd	s2,32(sp)
ffffffffc020155a:	ec4e                	sd	s3,24(sp)
ffffffffc020155c:	e852                	sd	s4,16(sp)
ffffffffc020155e:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201560:	5d6000ef          	jal	ra,ffffffffc0201b36 <kmalloc>
    if (mm != NULL)
ffffffffc0201564:	2e050663          	beqz	a0,ffffffffc0201850 <vmm_init+0x304>
ffffffffc0201568:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc020156a:	e508                	sd	a0,8(a0)
ffffffffc020156c:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc020156e:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201572:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201576:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020157a:	02053423          	sd	zero,40(a0)
ffffffffc020157e:	02052823          	sw	zero,48(a0)
ffffffffc0201582:	02053c23          	sd	zero,56(a0)
ffffffffc0201586:	03200413          	li	s0,50
ffffffffc020158a:	a811                	j	ffffffffc020159e <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc020158c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020158e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201590:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0201594:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201596:	8526                	mv	a0,s1
ffffffffc0201598:	cd3ff0ef          	jal	ra,ffffffffc020126a <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc020159c:	c80d                	beqz	s0,ffffffffc02015ce <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020159e:	03000513          	li	a0,48
ffffffffc02015a2:	594000ef          	jal	ra,ffffffffc0201b36 <kmalloc>
ffffffffc02015a6:	85aa                	mv	a1,a0
ffffffffc02015a8:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02015ac:	f165                	bnez	a0,ffffffffc020158c <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc02015ae:	00005697          	auipc	a3,0x5
ffffffffc02015b2:	1ea68693          	addi	a3,a3,490 # ffffffffc0206798 <commands+0xb08>
ffffffffc02015b6:	00005617          	auipc	a2,0x5
ffffffffc02015ba:	f7a60613          	addi	a2,a2,-134 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02015be:	12c00593          	li	a1,300
ffffffffc02015c2:	00005517          	auipc	a0,0x5
ffffffffc02015c6:	f8650513          	addi	a0,a0,-122 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02015ca:	c59fe0ef          	jal	ra,ffffffffc0200222 <__panic>
ffffffffc02015ce:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02015d2:	1f900913          	li	s2,505
ffffffffc02015d6:	a819                	j	ffffffffc02015ec <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc02015d8:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02015da:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02015dc:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02015e0:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02015e2:	8526                	mv	a0,s1
ffffffffc02015e4:	c87ff0ef          	jal	ra,ffffffffc020126a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02015e8:	03240a63          	beq	s0,s2,ffffffffc020161c <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02015ec:	03000513          	li	a0,48
ffffffffc02015f0:	546000ef          	jal	ra,ffffffffc0201b36 <kmalloc>
ffffffffc02015f4:	85aa                	mv	a1,a0
ffffffffc02015f6:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02015fa:	fd79                	bnez	a0,ffffffffc02015d8 <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc02015fc:	00005697          	auipc	a3,0x5
ffffffffc0201600:	19c68693          	addi	a3,a3,412 # ffffffffc0206798 <commands+0xb08>
ffffffffc0201604:	00005617          	auipc	a2,0x5
ffffffffc0201608:	f2c60613          	addi	a2,a2,-212 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020160c:	13300593          	li	a1,307
ffffffffc0201610:	00005517          	auipc	a0,0x5
ffffffffc0201614:	f3850513          	addi	a0,a0,-200 # ffffffffc0206548 <commands+0x8b8>
ffffffffc0201618:	c0bfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    return listelm->next;
ffffffffc020161c:	649c                	ld	a5,8(s1)
ffffffffc020161e:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0201620:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0201624:	16f48663          	beq	s1,a5,ffffffffc0201790 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201628:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd38248>
ffffffffc020162c:	ffe70693          	addi	a3,a4,-2
ffffffffc0201630:	10d61063          	bne	a2,a3,ffffffffc0201730 <vmm_init+0x1e4>
ffffffffc0201634:	ff07b683          	ld	a3,-16(a5)
ffffffffc0201638:	0ed71c63          	bne	a4,a3,ffffffffc0201730 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc020163c:	0715                	addi	a4,a4,5
ffffffffc020163e:	679c                	ld	a5,8(a5)
ffffffffc0201640:	feb712e3          	bne	a4,a1,ffffffffc0201624 <vmm_init+0xd8>
ffffffffc0201644:	4a1d                	li	s4,7
ffffffffc0201646:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0201648:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020164c:	85a2                	mv	a1,s0
ffffffffc020164e:	8526                	mv	a0,s1
ffffffffc0201650:	bdbff0ef          	jal	ra,ffffffffc020122a <find_vma>
ffffffffc0201654:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0201656:	16050d63          	beqz	a0,ffffffffc02017d0 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020165a:	00140593          	addi	a1,s0,1
ffffffffc020165e:	8526                	mv	a0,s1
ffffffffc0201660:	bcbff0ef          	jal	ra,ffffffffc020122a <find_vma>
ffffffffc0201664:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201666:	14050563          	beqz	a0,ffffffffc02017b0 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc020166a:	85d2                	mv	a1,s4
ffffffffc020166c:	8526                	mv	a0,s1
ffffffffc020166e:	bbdff0ef          	jal	ra,ffffffffc020122a <find_vma>
        assert(vma3 == NULL);
ffffffffc0201672:	16051f63          	bnez	a0,ffffffffc02017f0 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0201676:	00340593          	addi	a1,s0,3
ffffffffc020167a:	8526                	mv	a0,s1
ffffffffc020167c:	bafff0ef          	jal	ra,ffffffffc020122a <find_vma>
        assert(vma4 == NULL);
ffffffffc0201680:	1a051863          	bnez	a0,ffffffffc0201830 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0201684:	00440593          	addi	a1,s0,4
ffffffffc0201688:	8526                	mv	a0,s1
ffffffffc020168a:	ba1ff0ef          	jal	ra,ffffffffc020122a <find_vma>
        assert(vma5 == NULL);
ffffffffc020168e:	18051163          	bnez	a0,ffffffffc0201810 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0201692:	00893783          	ld	a5,8(s2)
ffffffffc0201696:	0a879d63          	bne	a5,s0,ffffffffc0201750 <vmm_init+0x204>
ffffffffc020169a:	01093783          	ld	a5,16(s2)
ffffffffc020169e:	0b479963          	bne	a5,s4,ffffffffc0201750 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02016a2:	0089b783          	ld	a5,8(s3)
ffffffffc02016a6:	0c879563          	bne	a5,s0,ffffffffc0201770 <vmm_init+0x224>
ffffffffc02016aa:	0109b783          	ld	a5,16(s3)
ffffffffc02016ae:	0d479163          	bne	a5,s4,ffffffffc0201770 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02016b2:	0415                	addi	s0,s0,5
ffffffffc02016b4:	0a15                	addi	s4,s4,5
ffffffffc02016b6:	f9541be3          	bne	s0,s5,ffffffffc020164c <vmm_init+0x100>
ffffffffc02016ba:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02016bc:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02016be:	85a2                	mv	a1,s0
ffffffffc02016c0:	8526                	mv	a0,s1
ffffffffc02016c2:	b69ff0ef          	jal	ra,ffffffffc020122a <find_vma>
ffffffffc02016c6:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc02016ca:	c90d                	beqz	a0,ffffffffc02016fc <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02016cc:	6914                	ld	a3,16(a0)
ffffffffc02016ce:	6510                	ld	a2,8(a0)
ffffffffc02016d0:	00005517          	auipc	a0,0x5
ffffffffc02016d4:	05050513          	addi	a0,a0,80 # ffffffffc0206720 <commands+0xa90>
ffffffffc02016d8:	a0dfe0ef          	jal	ra,ffffffffc02000e4 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02016dc:	00005697          	auipc	a3,0x5
ffffffffc02016e0:	06c68693          	addi	a3,a3,108 # ffffffffc0206748 <commands+0xab8>
ffffffffc02016e4:	00005617          	auipc	a2,0x5
ffffffffc02016e8:	e4c60613          	addi	a2,a2,-436 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02016ec:	15900593          	li	a1,345
ffffffffc02016f0:	00005517          	auipc	a0,0x5
ffffffffc02016f4:	e5850513          	addi	a0,a0,-424 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02016f8:	b2bfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc02016fc:	147d                	addi	s0,s0,-1
ffffffffc02016fe:	fd2410e3          	bne	s0,s2,ffffffffc02016be <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0201702:	8526                	mv	a0,s1
ffffffffc0201704:	c37ff0ef          	jal	ra,ffffffffc020133a <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201708:	00005517          	auipc	a0,0x5
ffffffffc020170c:	05850513          	addi	a0,a0,88 # ffffffffc0206760 <commands+0xad0>
ffffffffc0201710:	9d5fe0ef          	jal	ra,ffffffffc02000e4 <cprintf>
}
ffffffffc0201714:	7442                	ld	s0,48(sp)
ffffffffc0201716:	70e2                	ld	ra,56(sp)
ffffffffc0201718:	74a2                	ld	s1,40(sp)
ffffffffc020171a:	7902                	ld	s2,32(sp)
ffffffffc020171c:	69e2                	ld	s3,24(sp)
ffffffffc020171e:	6a42                	ld	s4,16(sp)
ffffffffc0201720:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201722:	00005517          	auipc	a0,0x5
ffffffffc0201726:	05e50513          	addi	a0,a0,94 # ffffffffc0206780 <commands+0xaf0>
}
ffffffffc020172a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020172c:	9b9fe06f          	j	ffffffffc02000e4 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201730:	00005697          	auipc	a3,0x5
ffffffffc0201734:	f0868693          	addi	a3,a3,-248 # ffffffffc0206638 <commands+0x9a8>
ffffffffc0201738:	00005617          	auipc	a2,0x5
ffffffffc020173c:	df860613          	addi	a2,a2,-520 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201740:	13d00593          	li	a1,317
ffffffffc0201744:	00005517          	auipc	a0,0x5
ffffffffc0201748:	e0450513          	addi	a0,a0,-508 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020174c:	ad7fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0201750:	00005697          	auipc	a3,0x5
ffffffffc0201754:	f7068693          	addi	a3,a3,-144 # ffffffffc02066c0 <commands+0xa30>
ffffffffc0201758:	00005617          	auipc	a2,0x5
ffffffffc020175c:	dd860613          	addi	a2,a2,-552 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201760:	14e00593          	li	a1,334
ffffffffc0201764:	00005517          	auipc	a0,0x5
ffffffffc0201768:	de450513          	addi	a0,a0,-540 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020176c:	ab7fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0201770:	00005697          	auipc	a3,0x5
ffffffffc0201774:	f8068693          	addi	a3,a3,-128 # ffffffffc02066f0 <commands+0xa60>
ffffffffc0201778:	00005617          	auipc	a2,0x5
ffffffffc020177c:	db860613          	addi	a2,a2,-584 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201780:	14f00593          	li	a1,335
ffffffffc0201784:	00005517          	auipc	a0,0x5
ffffffffc0201788:	dc450513          	addi	a0,a0,-572 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020178c:	a97fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201790:	00005697          	auipc	a3,0x5
ffffffffc0201794:	e9068693          	addi	a3,a3,-368 # ffffffffc0206620 <commands+0x990>
ffffffffc0201798:	00005617          	auipc	a2,0x5
ffffffffc020179c:	d9860613          	addi	a2,a2,-616 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02017a0:	13b00593          	li	a1,315
ffffffffc02017a4:	00005517          	auipc	a0,0x5
ffffffffc02017a8:	da450513          	addi	a0,a0,-604 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02017ac:	a77fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma2 != NULL);
ffffffffc02017b0:	00005697          	auipc	a3,0x5
ffffffffc02017b4:	ed068693          	addi	a3,a3,-304 # ffffffffc0206680 <commands+0x9f0>
ffffffffc02017b8:	00005617          	auipc	a2,0x5
ffffffffc02017bc:	d7860613          	addi	a2,a2,-648 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02017c0:	14600593          	li	a1,326
ffffffffc02017c4:	00005517          	auipc	a0,0x5
ffffffffc02017c8:	d8450513          	addi	a0,a0,-636 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02017cc:	a57fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma1 != NULL);
ffffffffc02017d0:	00005697          	auipc	a3,0x5
ffffffffc02017d4:	ea068693          	addi	a3,a3,-352 # ffffffffc0206670 <commands+0x9e0>
ffffffffc02017d8:	00005617          	auipc	a2,0x5
ffffffffc02017dc:	d5860613          	addi	a2,a2,-680 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02017e0:	14400593          	li	a1,324
ffffffffc02017e4:	00005517          	auipc	a0,0x5
ffffffffc02017e8:	d6450513          	addi	a0,a0,-668 # ffffffffc0206548 <commands+0x8b8>
ffffffffc02017ec:	a37fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma3 == NULL);
ffffffffc02017f0:	00005697          	auipc	a3,0x5
ffffffffc02017f4:	ea068693          	addi	a3,a3,-352 # ffffffffc0206690 <commands+0xa00>
ffffffffc02017f8:	00005617          	auipc	a2,0x5
ffffffffc02017fc:	d3860613          	addi	a2,a2,-712 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201800:	14800593          	li	a1,328
ffffffffc0201804:	00005517          	auipc	a0,0x5
ffffffffc0201808:	d4450513          	addi	a0,a0,-700 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020180c:	a17fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma5 == NULL);
ffffffffc0201810:	00005697          	auipc	a3,0x5
ffffffffc0201814:	ea068693          	addi	a3,a3,-352 # ffffffffc02066b0 <commands+0xa20>
ffffffffc0201818:	00005617          	auipc	a2,0x5
ffffffffc020181c:	d1860613          	addi	a2,a2,-744 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201820:	14c00593          	li	a1,332
ffffffffc0201824:	00005517          	auipc	a0,0x5
ffffffffc0201828:	d2450513          	addi	a0,a0,-732 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020182c:	9f7fe0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(vma4 == NULL);
ffffffffc0201830:	00005697          	auipc	a3,0x5
ffffffffc0201834:	e7068693          	addi	a3,a3,-400 # ffffffffc02066a0 <commands+0xa10>
ffffffffc0201838:	00005617          	auipc	a2,0x5
ffffffffc020183c:	cf860613          	addi	a2,a2,-776 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201840:	14a00593          	li	a1,330
ffffffffc0201844:	00005517          	auipc	a0,0x5
ffffffffc0201848:	d0450513          	addi	a0,a0,-764 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020184c:	9d7fe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(mm != NULL);
ffffffffc0201850:	00005697          	auipc	a3,0x5
ffffffffc0201854:	d8068693          	addi	a3,a3,-640 # ffffffffc02065d0 <commands+0x940>
ffffffffc0201858:	00005617          	auipc	a2,0x5
ffffffffc020185c:	cd860613          	addi	a2,a2,-808 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201860:	12400593          	li	a1,292
ffffffffc0201864:	00005517          	auipc	a0,0x5
ffffffffc0201868:	ce450513          	addi	a0,a0,-796 # ffffffffc0206548 <commands+0x8b8>
ffffffffc020186c:	9b7fe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0201870 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0201870:	7179                	addi	sp,sp,-48
ffffffffc0201872:	f022                	sd	s0,32(sp)
ffffffffc0201874:	f406                	sd	ra,40(sp)
ffffffffc0201876:	ec26                	sd	s1,24(sp)
ffffffffc0201878:	e84a                	sd	s2,16(sp)
ffffffffc020187a:	e44e                	sd	s3,8(sp)
ffffffffc020187c:	e052                	sd	s4,0(sp)
ffffffffc020187e:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0201880:	c135                	beqz	a0,ffffffffc02018e4 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0201882:	002007b7          	lui	a5,0x200
ffffffffc0201886:	04f5e663          	bltu	a1,a5,ffffffffc02018d2 <user_mem_check+0x62>
ffffffffc020188a:	00c584b3          	add	s1,a1,a2
ffffffffc020188e:	0495f263          	bgeu	a1,s1,ffffffffc02018d2 <user_mem_check+0x62>
ffffffffc0201892:	4785                	li	a5,1
ffffffffc0201894:	07fe                	slli	a5,a5,0x1f
ffffffffc0201896:	0297ee63          	bltu	a5,s1,ffffffffc02018d2 <user_mem_check+0x62>
ffffffffc020189a:	892a                	mv	s2,a0
ffffffffc020189c:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc020189e:	6a05                	lui	s4,0x1
ffffffffc02018a0:	a821                	j	ffffffffc02018b8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02018a2:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc02018a6:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02018a8:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02018aa:	c685                	beqz	a3,ffffffffc02018d2 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02018ac:	c399                	beqz	a5,ffffffffc02018b2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc02018ae:	02e46263          	bltu	s0,a4,ffffffffc02018d2 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02018b2:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc02018b4:	04947663          	bgeu	s0,s1,ffffffffc0201900 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc02018b8:	85a2                	mv	a1,s0
ffffffffc02018ba:	854a                	mv	a0,s2
ffffffffc02018bc:	96fff0ef          	jal	ra,ffffffffc020122a <find_vma>
ffffffffc02018c0:	c909                	beqz	a0,ffffffffc02018d2 <user_mem_check+0x62>
ffffffffc02018c2:	6518                	ld	a4,8(a0)
ffffffffc02018c4:	00e46763          	bltu	s0,a4,ffffffffc02018d2 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02018c8:	4d1c                	lw	a5,24(a0)
ffffffffc02018ca:	fc099ce3          	bnez	s3,ffffffffc02018a2 <user_mem_check+0x32>
ffffffffc02018ce:	8b85                	andi	a5,a5,1
ffffffffc02018d0:	f3ed                	bnez	a5,ffffffffc02018b2 <user_mem_check+0x42>
            return 0;
ffffffffc02018d2:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc02018d4:	70a2                	ld	ra,40(sp)
ffffffffc02018d6:	7402                	ld	s0,32(sp)
ffffffffc02018d8:	64e2                	ld	s1,24(sp)
ffffffffc02018da:	6942                	ld	s2,16(sp)
ffffffffc02018dc:	69a2                	ld	s3,8(sp)
ffffffffc02018de:	6a02                	ld	s4,0(sp)
ffffffffc02018e0:	6145                	addi	sp,sp,48
ffffffffc02018e2:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02018e4:	c02007b7          	lui	a5,0xc0200
ffffffffc02018e8:	4501                	li	a0,0
ffffffffc02018ea:	fef5e5e3          	bltu	a1,a5,ffffffffc02018d4 <user_mem_check+0x64>
ffffffffc02018ee:	962e                	add	a2,a2,a1
ffffffffc02018f0:	fec5f2e3          	bgeu	a1,a2,ffffffffc02018d4 <user_mem_check+0x64>
ffffffffc02018f4:	c8000537          	lui	a0,0xc8000
ffffffffc02018f8:	0505                	addi	a0,a0,1
ffffffffc02018fa:	00a63533          	sltu	a0,a2,a0
ffffffffc02018fe:	bfd9                	j	ffffffffc02018d4 <user_mem_check+0x64>
        return 1;
ffffffffc0201900:	4505                	li	a0,1
ffffffffc0201902:	bfc9                	j	ffffffffc02018d4 <user_mem_check+0x64>

ffffffffc0201904 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201904:	c94d                	beqz	a0,ffffffffc02019b6 <slob_free+0xb2>
{
ffffffffc0201906:	1141                	addi	sp,sp,-16
ffffffffc0201908:	e022                	sd	s0,0(sp)
ffffffffc020190a:	e406                	sd	ra,8(sp)
ffffffffc020190c:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc020190e:	e9c1                	bnez	a1,ffffffffc020199e <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201910:	100027f3          	csrr	a5,sstatus
ffffffffc0201914:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201916:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201918:	ebd9                	bnez	a5,ffffffffc02019ae <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020191a:	000c1617          	auipc	a2,0xc1
ffffffffc020191e:	f8e60613          	addi	a2,a2,-114 # ffffffffc02c28a8 <slobfree>
ffffffffc0201922:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201924:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201926:	679c                	ld	a5,8(a5)
ffffffffc0201928:	02877a63          	bgeu	a4,s0,ffffffffc020195c <slob_free+0x58>
ffffffffc020192c:	00f46463          	bltu	s0,a5,ffffffffc0201934 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201930:	fef76ae3          	bltu	a4,a5,ffffffffc0201924 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201934:	400c                	lw	a1,0(s0)
ffffffffc0201936:	00459693          	slli	a3,a1,0x4
ffffffffc020193a:	96a2                	add	a3,a3,s0
ffffffffc020193c:	02d78a63          	beq	a5,a3,ffffffffc0201970 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201940:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201942:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201944:	00469793          	slli	a5,a3,0x4
ffffffffc0201948:	97ba                	add	a5,a5,a4
ffffffffc020194a:	02f40e63          	beq	s0,a5,ffffffffc0201986 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc020194e:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201950:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201952:	e129                	bnez	a0,ffffffffc0201994 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201954:	60a2                	ld	ra,8(sp)
ffffffffc0201956:	6402                	ld	s0,0(sp)
ffffffffc0201958:	0141                	addi	sp,sp,16
ffffffffc020195a:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020195c:	fcf764e3          	bltu	a4,a5,ffffffffc0201924 <slob_free+0x20>
ffffffffc0201960:	fcf472e3          	bgeu	s0,a5,ffffffffc0201924 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201964:	400c                	lw	a1,0(s0)
ffffffffc0201966:	00459693          	slli	a3,a1,0x4
ffffffffc020196a:	96a2                	add	a3,a3,s0
ffffffffc020196c:	fcd79ae3          	bne	a5,a3,ffffffffc0201940 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201970:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201972:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201974:	9db5                	addw	a1,a1,a3
ffffffffc0201976:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201978:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020197a:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc020197c:	00469793          	slli	a5,a3,0x4
ffffffffc0201980:	97ba                	add	a5,a5,a4
ffffffffc0201982:	fcf416e3          	bne	s0,a5,ffffffffc020194e <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201986:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201988:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020198a:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc020198c:	9ebd                	addw	a3,a3,a5
ffffffffc020198e:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201990:	e70c                	sd	a1,8(a4)
ffffffffc0201992:	d169                	beqz	a0,ffffffffc0201954 <slob_free+0x50>
}
ffffffffc0201994:	6402                	ld	s0,0(sp)
ffffffffc0201996:	60a2                	ld	ra,8(sp)
ffffffffc0201998:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020199a:	814ff06f          	j	ffffffffc02009ae <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020199e:	25bd                	addiw	a1,a1,15
ffffffffc02019a0:	8191                	srli	a1,a1,0x4
ffffffffc02019a2:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019a4:	100027f3          	csrr	a5,sstatus
ffffffffc02019a8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019aa:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019ac:	d7bd                	beqz	a5,ffffffffc020191a <slob_free+0x16>
        intr_disable();
ffffffffc02019ae:	806ff0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02019b2:	4505                	li	a0,1
ffffffffc02019b4:	b79d                	j	ffffffffc020191a <slob_free+0x16>
ffffffffc02019b6:	8082                	ret

ffffffffc02019b8 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019b8:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019ba:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019bc:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019c0:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019c2:	601000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
	if (!page)
ffffffffc02019c6:	c91d                	beqz	a0,ffffffffc02019fc <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02019c8:	000c5697          	auipc	a3,0xc5
ffffffffc02019cc:	3906b683          	ld	a3,912(a3) # ffffffffc02c6d58 <pages>
ffffffffc02019d0:	8d15                	sub	a0,a0,a3
ffffffffc02019d2:	8519                	srai	a0,a0,0x6
ffffffffc02019d4:	00007697          	auipc	a3,0x7
ffffffffc02019d8:	8846b683          	ld	a3,-1916(a3) # ffffffffc0208258 <nbase>
ffffffffc02019dc:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02019de:	00c51793          	slli	a5,a0,0xc
ffffffffc02019e2:	83b1                	srli	a5,a5,0xc
ffffffffc02019e4:	000c5717          	auipc	a4,0xc5
ffffffffc02019e8:	36c73703          	ld	a4,876(a4) # ffffffffc02c6d50 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02019ec:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ee:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a02 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019f2:	000c5697          	auipc	a3,0xc5
ffffffffc02019f6:	3766b683          	ld	a3,886(a3) # ffffffffc02c6d68 <va_pa_offset>
ffffffffc02019fa:	9536                	add	a0,a0,a3
}
ffffffffc02019fc:	60a2                	ld	ra,8(sp)
ffffffffc02019fe:	0141                	addi	sp,sp,16
ffffffffc0201a00:	8082                	ret
ffffffffc0201a02:	86aa                	mv	a3,a0
ffffffffc0201a04:	00005617          	auipc	a2,0x5
ffffffffc0201a08:	a7460613          	addi	a2,a2,-1420 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0201a0c:	07100593          	li	a1,113
ffffffffc0201a10:	00005517          	auipc	a0,0x5
ffffffffc0201a14:	a2850513          	addi	a0,a0,-1496 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0201a18:	80bfe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0201a1c <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201a1c:	1101                	addi	sp,sp,-32
ffffffffc0201a1e:	ec06                	sd	ra,24(sp)
ffffffffc0201a20:	e822                	sd	s0,16(sp)
ffffffffc0201a22:	e426                	sd	s1,8(sp)
ffffffffc0201a24:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201a26:	01050713          	addi	a4,a0,16
ffffffffc0201a2a:	6785                	lui	a5,0x1
ffffffffc0201a2c:	0cf77363          	bgeu	a4,a5,ffffffffc0201af2 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201a30:	00f50493          	addi	s1,a0,15
ffffffffc0201a34:	8091                	srli	s1,s1,0x4
ffffffffc0201a36:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a38:	10002673          	csrr	a2,sstatus
ffffffffc0201a3c:	8a09                	andi	a2,a2,2
ffffffffc0201a3e:	e25d                	bnez	a2,ffffffffc0201ae4 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a40:	000c1917          	auipc	s2,0xc1
ffffffffc0201a44:	e6890913          	addi	s2,s2,-408 # ffffffffc02c28a8 <slobfree>
ffffffffc0201a48:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a4c:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201a4e:	4398                	lw	a4,0(a5)
ffffffffc0201a50:	08975e63          	bge	a4,s1,ffffffffc0201aec <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201a54:	00f68b63          	beq	a3,a5,ffffffffc0201a6a <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a58:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201a5a:	4018                	lw	a4,0(s0)
ffffffffc0201a5c:	02975a63          	bge	a4,s1,ffffffffc0201a90 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201a60:	00093683          	ld	a3,0(s2)
ffffffffc0201a64:	87a2                	mv	a5,s0
ffffffffc0201a66:	fef699e3          	bne	a3,a5,ffffffffc0201a58 <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201a6a:	ee31                	bnez	a2,ffffffffc0201ac6 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a6c:	4501                	li	a0,0
ffffffffc0201a6e:	f4bff0ef          	jal	ra,ffffffffc02019b8 <__slob_get_free_pages.constprop.0>
ffffffffc0201a72:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a74:	cd05                	beqz	a0,ffffffffc0201aac <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a76:	6585                	lui	a1,0x1
ffffffffc0201a78:	e8dff0ef          	jal	ra,ffffffffc0201904 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a7c:	10002673          	csrr	a2,sstatus
ffffffffc0201a80:	8a09                	andi	a2,a2,2
ffffffffc0201a82:	ee05                	bnez	a2,ffffffffc0201aba <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a84:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a88:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201a8a:	4018                	lw	a4,0(s0)
ffffffffc0201a8c:	fc974ae3          	blt	a4,s1,ffffffffc0201a60 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201a90:	04e48763          	beq	s1,a4,ffffffffc0201ade <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a94:	00449693          	slli	a3,s1,0x4
ffffffffc0201a98:	96a2                	add	a3,a3,s0
ffffffffc0201a9a:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a9c:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a9e:	9f05                	subw	a4,a4,s1
ffffffffc0201aa0:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201aa2:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201aa4:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201aa6:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201aaa:	e20d                	bnez	a2,ffffffffc0201acc <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201aac:	60e2                	ld	ra,24(sp)
ffffffffc0201aae:	8522                	mv	a0,s0
ffffffffc0201ab0:	6442                	ld	s0,16(sp)
ffffffffc0201ab2:	64a2                	ld	s1,8(sp)
ffffffffc0201ab4:	6902                	ld	s2,0(sp)
ffffffffc0201ab6:	6105                	addi	sp,sp,32
ffffffffc0201ab8:	8082                	ret
        intr_disable();
ffffffffc0201aba:	efbfe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
			cur = slobfree;
ffffffffc0201abe:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201ac2:	4605                	li	a2,1
ffffffffc0201ac4:	b7d1                	j	ffffffffc0201a88 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201ac6:	ee9fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201aca:	b74d                	j	ffffffffc0201a6c <slob_alloc.constprop.0+0x50>
ffffffffc0201acc:	ee3fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
}
ffffffffc0201ad0:	60e2                	ld	ra,24(sp)
ffffffffc0201ad2:	8522                	mv	a0,s0
ffffffffc0201ad4:	6442                	ld	s0,16(sp)
ffffffffc0201ad6:	64a2                	ld	s1,8(sp)
ffffffffc0201ad8:	6902                	ld	s2,0(sp)
ffffffffc0201ada:	6105                	addi	sp,sp,32
ffffffffc0201adc:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201ade:	6418                	ld	a4,8(s0)
ffffffffc0201ae0:	e798                	sd	a4,8(a5)
ffffffffc0201ae2:	b7d1                	j	ffffffffc0201aa6 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201ae4:	ed1fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0201ae8:	4605                	li	a2,1
ffffffffc0201aea:	bf99                	j	ffffffffc0201a40 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201aec:	843e                	mv	s0,a5
ffffffffc0201aee:	87b6                	mv	a5,a3
ffffffffc0201af0:	b745                	j	ffffffffc0201a90 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201af2:	00005697          	auipc	a3,0x5
ffffffffc0201af6:	cb668693          	addi	a3,a3,-842 # ffffffffc02067a8 <commands+0xb18>
ffffffffc0201afa:	00005617          	auipc	a2,0x5
ffffffffc0201afe:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201b02:	06300593          	li	a1,99
ffffffffc0201b06:	00005517          	auipc	a0,0x5
ffffffffc0201b0a:	cc250513          	addi	a0,a0,-830 # ffffffffc02067c8 <commands+0xb38>
ffffffffc0201b0e:	f14fe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0201b12 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201b12:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201b14:	00005517          	auipc	a0,0x5
ffffffffc0201b18:	ccc50513          	addi	a0,a0,-820 # ffffffffc02067e0 <commands+0xb50>
{
ffffffffc0201b1c:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201b1e:	dc6fe0ef          	jal	ra,ffffffffc02000e4 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201b22:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b24:	00005517          	auipc	a0,0x5
ffffffffc0201b28:	cd450513          	addi	a0,a0,-812 # ffffffffc02067f8 <commands+0xb68>
}
ffffffffc0201b2c:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b2e:	db6fe06f          	j	ffffffffc02000e4 <cprintf>

ffffffffc0201b32 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201b32:	4501                	li	a0,0
ffffffffc0201b34:	8082                	ret

ffffffffc0201b36 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b36:	1101                	addi	sp,sp,-32
ffffffffc0201b38:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b3a:	6905                	lui	s2,0x1
{
ffffffffc0201b3c:	e822                	sd	s0,16(sp)
ffffffffc0201b3e:	ec06                	sd	ra,24(sp)
ffffffffc0201b40:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b42:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8f71>
{
ffffffffc0201b46:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b48:	04a7f963          	bgeu	a5,a0,ffffffffc0201b9a <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b4c:	4561                	li	a0,24
ffffffffc0201b4e:	ecfff0ef          	jal	ra,ffffffffc0201a1c <slob_alloc.constprop.0>
ffffffffc0201b52:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b54:	c929                	beqz	a0,ffffffffc0201ba6 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b56:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b5a:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201b5c:	00f95763          	bge	s2,a5,ffffffffc0201b6a <kmalloc+0x34>
ffffffffc0201b60:	6705                	lui	a4,0x1
ffffffffc0201b62:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b64:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201b66:	fef74ee3          	blt	a4,a5,ffffffffc0201b62 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b6a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b6c:	e4dff0ef          	jal	ra,ffffffffc02019b8 <__slob_get_free_pages.constprop.0>
ffffffffc0201b70:	e488                	sd	a0,8(s1)
ffffffffc0201b72:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201b74:	c525                	beqz	a0,ffffffffc0201bdc <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b76:	100027f3          	csrr	a5,sstatus
ffffffffc0201b7a:	8b89                	andi	a5,a5,2
ffffffffc0201b7c:	ef8d                	bnez	a5,ffffffffc0201bb6 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b7e:	000c5797          	auipc	a5,0xc5
ffffffffc0201b82:	1ba78793          	addi	a5,a5,442 # ffffffffc02c6d38 <bigblocks>
ffffffffc0201b86:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b88:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b8a:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201b8c:	60e2                	ld	ra,24(sp)
ffffffffc0201b8e:	8522                	mv	a0,s0
ffffffffc0201b90:	6442                	ld	s0,16(sp)
ffffffffc0201b92:	64a2                	ld	s1,8(sp)
ffffffffc0201b94:	6902                	ld	s2,0(sp)
ffffffffc0201b96:	6105                	addi	sp,sp,32
ffffffffc0201b98:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b9a:	0541                	addi	a0,a0,16
ffffffffc0201b9c:	e81ff0ef          	jal	ra,ffffffffc0201a1c <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201ba0:	01050413          	addi	s0,a0,16
ffffffffc0201ba4:	f565                	bnez	a0,ffffffffc0201b8c <kmalloc+0x56>
ffffffffc0201ba6:	4401                	li	s0,0
}
ffffffffc0201ba8:	60e2                	ld	ra,24(sp)
ffffffffc0201baa:	8522                	mv	a0,s0
ffffffffc0201bac:	6442                	ld	s0,16(sp)
ffffffffc0201bae:	64a2                	ld	s1,8(sp)
ffffffffc0201bb0:	6902                	ld	s2,0(sp)
ffffffffc0201bb2:	6105                	addi	sp,sp,32
ffffffffc0201bb4:	8082                	ret
        intr_disable();
ffffffffc0201bb6:	dfffe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201bba:	000c5797          	auipc	a5,0xc5
ffffffffc0201bbe:	17e78793          	addi	a5,a5,382 # ffffffffc02c6d38 <bigblocks>
ffffffffc0201bc2:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201bc4:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201bc6:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201bc8:	de7fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
		return bb->pages;
ffffffffc0201bcc:	6480                	ld	s0,8(s1)
}
ffffffffc0201bce:	60e2                	ld	ra,24(sp)
ffffffffc0201bd0:	64a2                	ld	s1,8(sp)
ffffffffc0201bd2:	8522                	mv	a0,s0
ffffffffc0201bd4:	6442                	ld	s0,16(sp)
ffffffffc0201bd6:	6902                	ld	s2,0(sp)
ffffffffc0201bd8:	6105                	addi	sp,sp,32
ffffffffc0201bda:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bdc:	45e1                	li	a1,24
ffffffffc0201bde:	8526                	mv	a0,s1
ffffffffc0201be0:	d25ff0ef          	jal	ra,ffffffffc0201904 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201be4:	b765                	j	ffffffffc0201b8c <kmalloc+0x56>

ffffffffc0201be6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201be6:	c169                	beqz	a0,ffffffffc0201ca8 <kfree+0xc2>
{
ffffffffc0201be8:	1101                	addi	sp,sp,-32
ffffffffc0201bea:	e822                	sd	s0,16(sp)
ffffffffc0201bec:	ec06                	sd	ra,24(sp)
ffffffffc0201bee:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201bf0:	03451793          	slli	a5,a0,0x34
ffffffffc0201bf4:	842a                	mv	s0,a0
ffffffffc0201bf6:	e3d9                	bnez	a5,ffffffffc0201c7c <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201bf8:	100027f3          	csrr	a5,sstatus
ffffffffc0201bfc:	8b89                	andi	a5,a5,2
ffffffffc0201bfe:	e7d9                	bnez	a5,ffffffffc0201c8c <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c00:	000c5797          	auipc	a5,0xc5
ffffffffc0201c04:	1387b783          	ld	a5,312(a5) # ffffffffc02c6d38 <bigblocks>
    return 0;
ffffffffc0201c08:	4601                	li	a2,0
ffffffffc0201c0a:	cbad                	beqz	a5,ffffffffc0201c7c <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201c0c:	000c5697          	auipc	a3,0xc5
ffffffffc0201c10:	12c68693          	addi	a3,a3,300 # ffffffffc02c6d38 <bigblocks>
ffffffffc0201c14:	a021                	j	ffffffffc0201c1c <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c16:	01048693          	addi	a3,s1,16
ffffffffc0201c1a:	c3a5                	beqz	a5,ffffffffc0201c7a <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201c1c:	6798                	ld	a4,8(a5)
ffffffffc0201c1e:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201c20:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201c22:	fe871ae3          	bne	a4,s0,ffffffffc0201c16 <kfree+0x30>
				*last = bb->next;
ffffffffc0201c26:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201c28:	ee2d                	bnez	a2,ffffffffc0201ca2 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201c2a:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201c2e:	4098                	lw	a4,0(s1)
ffffffffc0201c30:	08f46963          	bltu	s0,a5,ffffffffc0201cc2 <kfree+0xdc>
ffffffffc0201c34:	000c5697          	auipc	a3,0xc5
ffffffffc0201c38:	1346b683          	ld	a3,308(a3) # ffffffffc02c6d68 <va_pa_offset>
ffffffffc0201c3c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201c3e:	8031                	srli	s0,s0,0xc
ffffffffc0201c40:	000c5797          	auipc	a5,0xc5
ffffffffc0201c44:	1107b783          	ld	a5,272(a5) # ffffffffc02c6d50 <npage>
ffffffffc0201c48:	06f47163          	bgeu	s0,a5,ffffffffc0201caa <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c4c:	00006517          	auipc	a0,0x6
ffffffffc0201c50:	60c53503          	ld	a0,1548(a0) # ffffffffc0208258 <nbase>
ffffffffc0201c54:	8c09                	sub	s0,s0,a0
ffffffffc0201c56:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201c58:	000c5517          	auipc	a0,0xc5
ffffffffc0201c5c:	10053503          	ld	a0,256(a0) # ffffffffc02c6d58 <pages>
ffffffffc0201c60:	4585                	li	a1,1
ffffffffc0201c62:	9522                	add	a0,a0,s0
ffffffffc0201c64:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c68:	399000ef          	jal	ra,ffffffffc0202800 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c6c:	6442                	ld	s0,16(sp)
ffffffffc0201c6e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c70:	8526                	mv	a0,s1
}
ffffffffc0201c72:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c74:	45e1                	li	a1,24
}
ffffffffc0201c76:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c78:	b171                	j	ffffffffc0201904 <slob_free>
ffffffffc0201c7a:	e20d                	bnez	a2,ffffffffc0201c9c <kfree+0xb6>
ffffffffc0201c7c:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c80:	6442                	ld	s0,16(sp)
ffffffffc0201c82:	60e2                	ld	ra,24(sp)
ffffffffc0201c84:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c86:	4581                	li	a1,0
}
ffffffffc0201c88:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c8a:	b9ad                	j	ffffffffc0201904 <slob_free>
        intr_disable();
ffffffffc0201c8c:	d29fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c90:	000c5797          	auipc	a5,0xc5
ffffffffc0201c94:	0a87b783          	ld	a5,168(a5) # ffffffffc02c6d38 <bigblocks>
        return 1;
ffffffffc0201c98:	4605                	li	a2,1
ffffffffc0201c9a:	fbad                	bnez	a5,ffffffffc0201c0c <kfree+0x26>
        intr_enable();
ffffffffc0201c9c:	d13fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201ca0:	bff1                	j	ffffffffc0201c7c <kfree+0x96>
ffffffffc0201ca2:	d0dfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0201ca6:	b751                	j	ffffffffc0201c2a <kfree+0x44>
ffffffffc0201ca8:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201caa:	00004617          	auipc	a2,0x4
ffffffffc0201cae:	79e60613          	addi	a2,a2,1950 # ffffffffc0206448 <commands+0x7b8>
ffffffffc0201cb2:	06900593          	li	a1,105
ffffffffc0201cb6:	00004517          	auipc	a0,0x4
ffffffffc0201cba:	78250513          	addi	a0,a0,1922 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0201cbe:	d64fe0ef          	jal	ra,ffffffffc0200222 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201cc2:	86a2                	mv	a3,s0
ffffffffc0201cc4:	00005617          	auipc	a2,0x5
ffffffffc0201cc8:	b5460613          	addi	a2,a2,-1196 # ffffffffc0206818 <commands+0xb88>
ffffffffc0201ccc:	07700593          	li	a1,119
ffffffffc0201cd0:	00004517          	auipc	a0,0x4
ffffffffc0201cd4:	76850513          	addi	a0,a0,1896 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0201cd8:	d4afe0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0201cdc <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201cdc:	000c1797          	auipc	a5,0xc1
ffffffffc0201ce0:	fdc78793          	addi	a5,a5,-36 # ffffffffc02c2cb8 <free_area>
ffffffffc0201ce4:	e79c                	sd	a5,8(a5)
ffffffffc0201ce6:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201ce8:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201cec:	8082                	ret

ffffffffc0201cee <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201cee:	000c1517          	auipc	a0,0xc1
ffffffffc0201cf2:	fda56503          	lwu	a0,-38(a0) # ffffffffc02c2cc8 <free_area+0x10>
ffffffffc0201cf6:	8082                	ret

ffffffffc0201cf8 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201cf8:	715d                	addi	sp,sp,-80
ffffffffc0201cfa:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201cfc:	000c1417          	auipc	s0,0xc1
ffffffffc0201d00:	fbc40413          	addi	s0,s0,-68 # ffffffffc02c2cb8 <free_area>
ffffffffc0201d04:	641c                	ld	a5,8(s0)
ffffffffc0201d06:	e486                	sd	ra,72(sp)
ffffffffc0201d08:	fc26                	sd	s1,56(sp)
ffffffffc0201d0a:	f84a                	sd	s2,48(sp)
ffffffffc0201d0c:	f44e                	sd	s3,40(sp)
ffffffffc0201d0e:	f052                	sd	s4,32(sp)
ffffffffc0201d10:	ec56                	sd	s5,24(sp)
ffffffffc0201d12:	e85a                	sd	s6,16(sp)
ffffffffc0201d14:	e45e                	sd	s7,8(sp)
ffffffffc0201d16:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d18:	2a878d63          	beq	a5,s0,ffffffffc0201fd2 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0201d1c:	4481                	li	s1,0
ffffffffc0201d1e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201d20:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201d24:	8b09                	andi	a4,a4,2
ffffffffc0201d26:	2a070a63          	beqz	a4,ffffffffc0201fda <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0201d2a:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201d2e:	679c                	ld	a5,8(a5)
ffffffffc0201d30:	2905                	addiw	s2,s2,1
ffffffffc0201d32:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d34:	fe8796e3          	bne	a5,s0,ffffffffc0201d20 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201d38:	89a6                	mv	s3,s1
ffffffffc0201d3a:	307000ef          	jal	ra,ffffffffc0202840 <nr_free_pages>
ffffffffc0201d3e:	6f351e63          	bne	a0,s3,ffffffffc020243a <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201d42:	4505                	li	a0,1
ffffffffc0201d44:	27f000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201d48:	8aaa                	mv	s5,a0
ffffffffc0201d4a:	42050863          	beqz	a0,ffffffffc020217a <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201d4e:	4505                	li	a0,1
ffffffffc0201d50:	273000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201d54:	89aa                	mv	s3,a0
ffffffffc0201d56:	70050263          	beqz	a0,ffffffffc020245a <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201d5a:	4505                	li	a0,1
ffffffffc0201d5c:	267000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201d60:	8a2a                	mv	s4,a0
ffffffffc0201d62:	48050c63          	beqz	a0,ffffffffc02021fa <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201d66:	293a8a63          	beq	s5,s3,ffffffffc0201ffa <default_check+0x302>
ffffffffc0201d6a:	28aa8863          	beq	s5,a0,ffffffffc0201ffa <default_check+0x302>
ffffffffc0201d6e:	28a98663          	beq	s3,a0,ffffffffc0201ffa <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201d72:	000aa783          	lw	a5,0(s5)
ffffffffc0201d76:	2a079263          	bnez	a5,ffffffffc020201a <default_check+0x322>
ffffffffc0201d7a:	0009a783          	lw	a5,0(s3)
ffffffffc0201d7e:	28079e63          	bnez	a5,ffffffffc020201a <default_check+0x322>
ffffffffc0201d82:	411c                	lw	a5,0(a0)
ffffffffc0201d84:	28079b63          	bnez	a5,ffffffffc020201a <default_check+0x322>
    return page - pages + nbase;
ffffffffc0201d88:	000c5797          	auipc	a5,0xc5
ffffffffc0201d8c:	fd07b783          	ld	a5,-48(a5) # ffffffffc02c6d58 <pages>
ffffffffc0201d90:	40fa8733          	sub	a4,s5,a5
ffffffffc0201d94:	00006617          	auipc	a2,0x6
ffffffffc0201d98:	4c463603          	ld	a2,1220(a2) # ffffffffc0208258 <nbase>
ffffffffc0201d9c:	8719                	srai	a4,a4,0x6
ffffffffc0201d9e:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201da0:	000c5697          	auipc	a3,0xc5
ffffffffc0201da4:	fb06b683          	ld	a3,-80(a3) # ffffffffc02c6d50 <npage>
ffffffffc0201da8:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201daa:	0732                	slli	a4,a4,0xc
ffffffffc0201dac:	28d77763          	bgeu	a4,a3,ffffffffc020203a <default_check+0x342>
    return page - pages + nbase;
ffffffffc0201db0:	40f98733          	sub	a4,s3,a5
ffffffffc0201db4:	8719                	srai	a4,a4,0x6
ffffffffc0201db6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201db8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201dba:	4cd77063          	bgeu	a4,a3,ffffffffc020227a <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201dbe:	40f507b3          	sub	a5,a0,a5
ffffffffc0201dc2:	8799                	srai	a5,a5,0x6
ffffffffc0201dc4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dc6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201dc8:	30d7f963          	bgeu	a5,a3,ffffffffc02020da <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201dcc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201dce:	00043c03          	ld	s8,0(s0)
ffffffffc0201dd2:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201dd6:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201dda:	e400                	sd	s0,8(s0)
ffffffffc0201ddc:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201dde:	000c1797          	auipc	a5,0xc1
ffffffffc0201de2:	ee07a523          	sw	zero,-278(a5) # ffffffffc02c2cc8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201de6:	1dd000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201dea:	2c051863          	bnez	a0,ffffffffc02020ba <default_check+0x3c2>
    free_page(p0);
ffffffffc0201dee:	4585                	li	a1,1
ffffffffc0201df0:	8556                	mv	a0,s5
ffffffffc0201df2:	20f000ef          	jal	ra,ffffffffc0202800 <free_pages>
    free_page(p1);
ffffffffc0201df6:	4585                	li	a1,1
ffffffffc0201df8:	854e                	mv	a0,s3
ffffffffc0201dfa:	207000ef          	jal	ra,ffffffffc0202800 <free_pages>
    free_page(p2);
ffffffffc0201dfe:	4585                	li	a1,1
ffffffffc0201e00:	8552                	mv	a0,s4
ffffffffc0201e02:	1ff000ef          	jal	ra,ffffffffc0202800 <free_pages>
    assert(nr_free == 3);
ffffffffc0201e06:	4818                	lw	a4,16(s0)
ffffffffc0201e08:	478d                	li	a5,3
ffffffffc0201e0a:	28f71863          	bne	a4,a5,ffffffffc020209a <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201e0e:	4505                	li	a0,1
ffffffffc0201e10:	1b3000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e14:	89aa                	mv	s3,a0
ffffffffc0201e16:	26050263          	beqz	a0,ffffffffc020207a <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201e1a:	4505                	li	a0,1
ffffffffc0201e1c:	1a7000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e20:	8aaa                	mv	s5,a0
ffffffffc0201e22:	3a050c63          	beqz	a0,ffffffffc02021da <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201e26:	4505                	li	a0,1
ffffffffc0201e28:	19b000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e2c:	8a2a                	mv	s4,a0
ffffffffc0201e2e:	38050663          	beqz	a0,ffffffffc02021ba <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0201e32:	4505                	li	a0,1
ffffffffc0201e34:	18f000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e38:	36051163          	bnez	a0,ffffffffc020219a <default_check+0x4a2>
    free_page(p0);
ffffffffc0201e3c:	4585                	li	a1,1
ffffffffc0201e3e:	854e                	mv	a0,s3
ffffffffc0201e40:	1c1000ef          	jal	ra,ffffffffc0202800 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201e44:	641c                	ld	a5,8(s0)
ffffffffc0201e46:	20878a63          	beq	a5,s0,ffffffffc020205a <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201e4a:	4505                	li	a0,1
ffffffffc0201e4c:	177000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e50:	30a99563          	bne	s3,a0,ffffffffc020215a <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0201e54:	4505                	li	a0,1
ffffffffc0201e56:	16d000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e5a:	2e051063          	bnez	a0,ffffffffc020213a <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0201e5e:	481c                	lw	a5,16(s0)
ffffffffc0201e60:	2a079d63          	bnez	a5,ffffffffc020211a <default_check+0x422>
    free_page(p);
ffffffffc0201e64:	854e                	mv	a0,s3
ffffffffc0201e66:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201e68:	01843023          	sd	s8,0(s0)
ffffffffc0201e6c:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201e70:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201e74:	18d000ef          	jal	ra,ffffffffc0202800 <free_pages>
    free_page(p1);
ffffffffc0201e78:	4585                	li	a1,1
ffffffffc0201e7a:	8556                	mv	a0,s5
ffffffffc0201e7c:	185000ef          	jal	ra,ffffffffc0202800 <free_pages>
    free_page(p2);
ffffffffc0201e80:	4585                	li	a1,1
ffffffffc0201e82:	8552                	mv	a0,s4
ffffffffc0201e84:	17d000ef          	jal	ra,ffffffffc0202800 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201e88:	4515                	li	a0,5
ffffffffc0201e8a:	139000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201e8e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201e90:	26050563          	beqz	a0,ffffffffc02020fa <default_check+0x402>
ffffffffc0201e94:	651c                	ld	a5,8(a0)
ffffffffc0201e96:	8385                	srli	a5,a5,0x1
ffffffffc0201e98:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201e9a:	54079063          	bnez	a5,ffffffffc02023da <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201e9e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201ea0:	00043b03          	ld	s6,0(s0)
ffffffffc0201ea4:	00843a83          	ld	s5,8(s0)
ffffffffc0201ea8:	e000                	sd	s0,0(s0)
ffffffffc0201eaa:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201eac:	117000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201eb0:	50051563          	bnez	a0,ffffffffc02023ba <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201eb4:	08098a13          	addi	s4,s3,128
ffffffffc0201eb8:	8552                	mv	a0,s4
ffffffffc0201eba:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201ebc:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201ec0:	000c1797          	auipc	a5,0xc1
ffffffffc0201ec4:	e007a423          	sw	zero,-504(a5) # ffffffffc02c2cc8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201ec8:	139000ef          	jal	ra,ffffffffc0202800 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201ecc:	4511                	li	a0,4
ffffffffc0201ece:	0f5000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201ed2:	4c051463          	bnez	a0,ffffffffc020239a <default_check+0x6a2>
ffffffffc0201ed6:	0889b783          	ld	a5,136(s3)
ffffffffc0201eda:	8385                	srli	a5,a5,0x1
ffffffffc0201edc:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201ede:	48078e63          	beqz	a5,ffffffffc020237a <default_check+0x682>
ffffffffc0201ee2:	0909a703          	lw	a4,144(s3)
ffffffffc0201ee6:	478d                	li	a5,3
ffffffffc0201ee8:	48f71963          	bne	a4,a5,ffffffffc020237a <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201eec:	450d                	li	a0,3
ffffffffc0201eee:	0d5000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201ef2:	8c2a                	mv	s8,a0
ffffffffc0201ef4:	46050363          	beqz	a0,ffffffffc020235a <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201ef8:	4505                	li	a0,1
ffffffffc0201efa:	0c9000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201efe:	42051e63          	bnez	a0,ffffffffc020233a <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201f02:	418a1c63          	bne	s4,s8,ffffffffc020231a <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201f06:	4585                	li	a1,1
ffffffffc0201f08:	854e                	mv	a0,s3
ffffffffc0201f0a:	0f7000ef          	jal	ra,ffffffffc0202800 <free_pages>
    free_pages(p1, 3);
ffffffffc0201f0e:	458d                	li	a1,3
ffffffffc0201f10:	8552                	mv	a0,s4
ffffffffc0201f12:	0ef000ef          	jal	ra,ffffffffc0202800 <free_pages>
ffffffffc0201f16:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201f1a:	04098c13          	addi	s8,s3,64
ffffffffc0201f1e:	8385                	srli	a5,a5,0x1
ffffffffc0201f20:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201f22:	3c078c63          	beqz	a5,ffffffffc02022fa <default_check+0x602>
ffffffffc0201f26:	0109a703          	lw	a4,16(s3)
ffffffffc0201f2a:	4785                	li	a5,1
ffffffffc0201f2c:	3cf71763          	bne	a4,a5,ffffffffc02022fa <default_check+0x602>
ffffffffc0201f30:	008a3783          	ld	a5,8(s4) # 1008 <_binary_obj___user_faultread_out_size-0x8f58>
ffffffffc0201f34:	8385                	srli	a5,a5,0x1
ffffffffc0201f36:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201f38:	3a078163          	beqz	a5,ffffffffc02022da <default_check+0x5e2>
ffffffffc0201f3c:	010a2703          	lw	a4,16(s4)
ffffffffc0201f40:	478d                	li	a5,3
ffffffffc0201f42:	38f71c63          	bne	a4,a5,ffffffffc02022da <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201f46:	4505                	li	a0,1
ffffffffc0201f48:	07b000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201f4c:	36a99763          	bne	s3,a0,ffffffffc02022ba <default_check+0x5c2>
    free_page(p0);
ffffffffc0201f50:	4585                	li	a1,1
ffffffffc0201f52:	0af000ef          	jal	ra,ffffffffc0202800 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201f56:	4509                	li	a0,2
ffffffffc0201f58:	06b000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201f5c:	32aa1f63          	bne	s4,a0,ffffffffc020229a <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0201f60:	4589                	li	a1,2
ffffffffc0201f62:	09f000ef          	jal	ra,ffffffffc0202800 <free_pages>
    free_page(p2);
ffffffffc0201f66:	4585                	li	a1,1
ffffffffc0201f68:	8562                	mv	a0,s8
ffffffffc0201f6a:	097000ef          	jal	ra,ffffffffc0202800 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201f6e:	4515                	li	a0,5
ffffffffc0201f70:	053000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201f74:	89aa                	mv	s3,a0
ffffffffc0201f76:	48050263          	beqz	a0,ffffffffc02023fa <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201f7a:	4505                	li	a0,1
ffffffffc0201f7c:	047000ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0201f80:	2c051d63          	bnez	a0,ffffffffc020225a <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0201f84:	481c                	lw	a5,16(s0)
ffffffffc0201f86:	2a079a63          	bnez	a5,ffffffffc020223a <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201f8a:	4595                	li	a1,5
ffffffffc0201f8c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201f8e:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201f92:	01643023          	sd	s6,0(s0)
ffffffffc0201f96:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201f9a:	067000ef          	jal	ra,ffffffffc0202800 <free_pages>
    return listelm->next;
ffffffffc0201f9e:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fa0:	00878963          	beq	a5,s0,ffffffffc0201fb2 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0201fa4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201fa8:	679c                	ld	a5,8(a5)
ffffffffc0201faa:	397d                	addiw	s2,s2,-1
ffffffffc0201fac:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fae:	fe879be3          	bne	a5,s0,ffffffffc0201fa4 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0201fb2:	26091463          	bnez	s2,ffffffffc020221a <default_check+0x522>
    assert(total == 0);
ffffffffc0201fb6:	46049263          	bnez	s1,ffffffffc020241a <default_check+0x722>
}
ffffffffc0201fba:	60a6                	ld	ra,72(sp)
ffffffffc0201fbc:	6406                	ld	s0,64(sp)
ffffffffc0201fbe:	74e2                	ld	s1,56(sp)
ffffffffc0201fc0:	7942                	ld	s2,48(sp)
ffffffffc0201fc2:	79a2                	ld	s3,40(sp)
ffffffffc0201fc4:	7a02                	ld	s4,32(sp)
ffffffffc0201fc6:	6ae2                	ld	s5,24(sp)
ffffffffc0201fc8:	6b42                	ld	s6,16(sp)
ffffffffc0201fca:	6ba2                	ld	s7,8(sp)
ffffffffc0201fcc:	6c02                	ld	s8,0(sp)
ffffffffc0201fce:	6161                	addi	sp,sp,80
ffffffffc0201fd0:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fd2:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201fd4:	4481                	li	s1,0
ffffffffc0201fd6:	4901                	li	s2,0
ffffffffc0201fd8:	b38d                	j	ffffffffc0201d3a <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201fda:	00005697          	auipc	a3,0x5
ffffffffc0201fde:	86668693          	addi	a3,a3,-1946 # ffffffffc0206840 <commands+0xbb0>
ffffffffc0201fe2:	00004617          	auipc	a2,0x4
ffffffffc0201fe6:	54e60613          	addi	a2,a2,1358 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0201fea:	11000593          	li	a1,272
ffffffffc0201fee:	00005517          	auipc	a0,0x5
ffffffffc0201ff2:	86250513          	addi	a0,a0,-1950 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0201ff6:	a2cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201ffa:	00005697          	auipc	a3,0x5
ffffffffc0201ffe:	8ee68693          	addi	a3,a3,-1810 # ffffffffc02068e8 <commands+0xc58>
ffffffffc0202002:	00004617          	auipc	a2,0x4
ffffffffc0202006:	52e60613          	addi	a2,a2,1326 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020200a:	0db00593          	li	a1,219
ffffffffc020200e:	00005517          	auipc	a0,0x5
ffffffffc0202012:	84250513          	addi	a0,a0,-1982 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202016:	a0cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020201a:	00005697          	auipc	a3,0x5
ffffffffc020201e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0206910 <commands+0xc80>
ffffffffc0202022:	00004617          	auipc	a2,0x4
ffffffffc0202026:	50e60613          	addi	a2,a2,1294 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020202a:	0dc00593          	li	a1,220
ffffffffc020202e:	00005517          	auipc	a0,0x5
ffffffffc0202032:	82250513          	addi	a0,a0,-2014 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202036:	9ecfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020203a:	00005697          	auipc	a3,0x5
ffffffffc020203e:	91668693          	addi	a3,a3,-1770 # ffffffffc0206950 <commands+0xcc0>
ffffffffc0202042:	00004617          	auipc	a2,0x4
ffffffffc0202046:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020204a:	0de00593          	li	a1,222
ffffffffc020204e:	00005517          	auipc	a0,0x5
ffffffffc0202052:	80250513          	addi	a0,a0,-2046 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202056:	9ccfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020205a:	00005697          	auipc	a3,0x5
ffffffffc020205e:	97e68693          	addi	a3,a3,-1666 # ffffffffc02069d8 <commands+0xd48>
ffffffffc0202062:	00004617          	auipc	a2,0x4
ffffffffc0202066:	4ce60613          	addi	a2,a2,1230 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020206a:	0f700593          	li	a1,247
ffffffffc020206e:	00004517          	auipc	a0,0x4
ffffffffc0202072:	7e250513          	addi	a0,a0,2018 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202076:	9acfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020207a:	00005697          	auipc	a3,0x5
ffffffffc020207e:	80e68693          	addi	a3,a3,-2034 # ffffffffc0206888 <commands+0xbf8>
ffffffffc0202082:	00004617          	auipc	a2,0x4
ffffffffc0202086:	4ae60613          	addi	a2,a2,1198 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020208a:	0f000593          	li	a1,240
ffffffffc020208e:	00004517          	auipc	a0,0x4
ffffffffc0202092:	7c250513          	addi	a0,a0,1986 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202096:	98cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(nr_free == 3);
ffffffffc020209a:	00005697          	auipc	a3,0x5
ffffffffc020209e:	92e68693          	addi	a3,a3,-1746 # ffffffffc02069c8 <commands+0xd38>
ffffffffc02020a2:	00004617          	auipc	a2,0x4
ffffffffc02020a6:	48e60613          	addi	a2,a2,1166 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02020aa:	0ee00593          	li	a1,238
ffffffffc02020ae:	00004517          	auipc	a0,0x4
ffffffffc02020b2:	7a250513          	addi	a0,a0,1954 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02020b6:	96cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020ba:	00005697          	auipc	a3,0x5
ffffffffc02020be:	8f668693          	addi	a3,a3,-1802 # ffffffffc02069b0 <commands+0xd20>
ffffffffc02020c2:	00004617          	auipc	a2,0x4
ffffffffc02020c6:	46e60613          	addi	a2,a2,1134 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02020ca:	0e900593          	li	a1,233
ffffffffc02020ce:	00004517          	auipc	a0,0x4
ffffffffc02020d2:	78250513          	addi	a0,a0,1922 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02020d6:	94cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02020da:	00005697          	auipc	a3,0x5
ffffffffc02020de:	8b668693          	addi	a3,a3,-1866 # ffffffffc0206990 <commands+0xd00>
ffffffffc02020e2:	00004617          	auipc	a2,0x4
ffffffffc02020e6:	44e60613          	addi	a2,a2,1102 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02020ea:	0e000593          	li	a1,224
ffffffffc02020ee:	00004517          	auipc	a0,0x4
ffffffffc02020f2:	76250513          	addi	a0,a0,1890 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02020f6:	92cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(p0 != NULL);
ffffffffc02020fa:	00005697          	auipc	a3,0x5
ffffffffc02020fe:	92668693          	addi	a3,a3,-1754 # ffffffffc0206a20 <commands+0xd90>
ffffffffc0202102:	00004617          	auipc	a2,0x4
ffffffffc0202106:	42e60613          	addi	a2,a2,1070 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020210a:	11800593          	li	a1,280
ffffffffc020210e:	00004517          	auipc	a0,0x4
ffffffffc0202112:	74250513          	addi	a0,a0,1858 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202116:	90cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(nr_free == 0);
ffffffffc020211a:	00005697          	auipc	a3,0x5
ffffffffc020211e:	8f668693          	addi	a3,a3,-1802 # ffffffffc0206a10 <commands+0xd80>
ffffffffc0202122:	00004617          	auipc	a2,0x4
ffffffffc0202126:	40e60613          	addi	a2,a2,1038 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020212a:	0fd00593          	li	a1,253
ffffffffc020212e:	00004517          	auipc	a0,0x4
ffffffffc0202132:	72250513          	addi	a0,a0,1826 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202136:	8ecfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020213a:	00005697          	auipc	a3,0x5
ffffffffc020213e:	87668693          	addi	a3,a3,-1930 # ffffffffc02069b0 <commands+0xd20>
ffffffffc0202142:	00004617          	auipc	a2,0x4
ffffffffc0202146:	3ee60613          	addi	a2,a2,1006 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020214a:	0fb00593          	li	a1,251
ffffffffc020214e:	00004517          	auipc	a0,0x4
ffffffffc0202152:	70250513          	addi	a0,a0,1794 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202156:	8ccfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020215a:	00005697          	auipc	a3,0x5
ffffffffc020215e:	89668693          	addi	a3,a3,-1898 # ffffffffc02069f0 <commands+0xd60>
ffffffffc0202162:	00004617          	auipc	a2,0x4
ffffffffc0202166:	3ce60613          	addi	a2,a2,974 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020216a:	0fa00593          	li	a1,250
ffffffffc020216e:	00004517          	auipc	a0,0x4
ffffffffc0202172:	6e250513          	addi	a0,a0,1762 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202176:	8acfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020217a:	00004697          	auipc	a3,0x4
ffffffffc020217e:	70e68693          	addi	a3,a3,1806 # ffffffffc0206888 <commands+0xbf8>
ffffffffc0202182:	00004617          	auipc	a2,0x4
ffffffffc0202186:	3ae60613          	addi	a2,a2,942 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020218a:	0d700593          	li	a1,215
ffffffffc020218e:	00004517          	auipc	a0,0x4
ffffffffc0202192:	6c250513          	addi	a0,a0,1730 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202196:	88cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020219a:	00005697          	auipc	a3,0x5
ffffffffc020219e:	81668693          	addi	a3,a3,-2026 # ffffffffc02069b0 <commands+0xd20>
ffffffffc02021a2:	00004617          	auipc	a2,0x4
ffffffffc02021a6:	38e60613          	addi	a2,a2,910 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02021aa:	0f400593          	li	a1,244
ffffffffc02021ae:	00004517          	auipc	a0,0x4
ffffffffc02021b2:	6a250513          	addi	a0,a0,1698 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02021b6:	86cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021ba:	00004697          	auipc	a3,0x4
ffffffffc02021be:	70e68693          	addi	a3,a3,1806 # ffffffffc02068c8 <commands+0xc38>
ffffffffc02021c2:	00004617          	auipc	a2,0x4
ffffffffc02021c6:	36e60613          	addi	a2,a2,878 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02021ca:	0f200593          	li	a1,242
ffffffffc02021ce:	00004517          	auipc	a0,0x4
ffffffffc02021d2:	68250513          	addi	a0,a0,1666 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02021d6:	84cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02021da:	00004697          	auipc	a3,0x4
ffffffffc02021de:	6ce68693          	addi	a3,a3,1742 # ffffffffc02068a8 <commands+0xc18>
ffffffffc02021e2:	00004617          	auipc	a2,0x4
ffffffffc02021e6:	34e60613          	addi	a2,a2,846 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02021ea:	0f100593          	li	a1,241
ffffffffc02021ee:	00004517          	auipc	a0,0x4
ffffffffc02021f2:	66250513          	addi	a0,a0,1634 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02021f6:	82cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021fa:	00004697          	auipc	a3,0x4
ffffffffc02021fe:	6ce68693          	addi	a3,a3,1742 # ffffffffc02068c8 <commands+0xc38>
ffffffffc0202202:	00004617          	auipc	a2,0x4
ffffffffc0202206:	32e60613          	addi	a2,a2,814 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020220a:	0d900593          	li	a1,217
ffffffffc020220e:	00004517          	auipc	a0,0x4
ffffffffc0202212:	64250513          	addi	a0,a0,1602 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202216:	80cfe0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(count == 0);
ffffffffc020221a:	00005697          	auipc	a3,0x5
ffffffffc020221e:	95668693          	addi	a3,a3,-1706 # ffffffffc0206b70 <commands+0xee0>
ffffffffc0202222:	00004617          	auipc	a2,0x4
ffffffffc0202226:	30e60613          	addi	a2,a2,782 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020222a:	14600593          	li	a1,326
ffffffffc020222e:	00004517          	auipc	a0,0x4
ffffffffc0202232:	62250513          	addi	a0,a0,1570 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202236:	fedfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(nr_free == 0);
ffffffffc020223a:	00004697          	auipc	a3,0x4
ffffffffc020223e:	7d668693          	addi	a3,a3,2006 # ffffffffc0206a10 <commands+0xd80>
ffffffffc0202242:	00004617          	auipc	a2,0x4
ffffffffc0202246:	2ee60613          	addi	a2,a2,750 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020224a:	13a00593          	li	a1,314
ffffffffc020224e:	00004517          	auipc	a0,0x4
ffffffffc0202252:	60250513          	addi	a0,a0,1538 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202256:	fcdfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020225a:	00004697          	auipc	a3,0x4
ffffffffc020225e:	75668693          	addi	a3,a3,1878 # ffffffffc02069b0 <commands+0xd20>
ffffffffc0202262:	00004617          	auipc	a2,0x4
ffffffffc0202266:	2ce60613          	addi	a2,a2,718 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020226a:	13800593          	li	a1,312
ffffffffc020226e:	00004517          	auipc	a0,0x4
ffffffffc0202272:	5e250513          	addi	a0,a0,1506 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202276:	fadfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020227a:	00004697          	auipc	a3,0x4
ffffffffc020227e:	6f668693          	addi	a3,a3,1782 # ffffffffc0206970 <commands+0xce0>
ffffffffc0202282:	00004617          	auipc	a2,0x4
ffffffffc0202286:	2ae60613          	addi	a2,a2,686 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020228a:	0df00593          	li	a1,223
ffffffffc020228e:	00004517          	auipc	a0,0x4
ffffffffc0202292:	5c250513          	addi	a0,a0,1474 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202296:	f8dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020229a:	00005697          	auipc	a3,0x5
ffffffffc020229e:	89668693          	addi	a3,a3,-1898 # ffffffffc0206b30 <commands+0xea0>
ffffffffc02022a2:	00004617          	auipc	a2,0x4
ffffffffc02022a6:	28e60613          	addi	a2,a2,654 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02022aa:	13200593          	li	a1,306
ffffffffc02022ae:	00004517          	auipc	a0,0x4
ffffffffc02022b2:	5a250513          	addi	a0,a0,1442 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02022b6:	f6dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02022ba:	00005697          	auipc	a3,0x5
ffffffffc02022be:	85668693          	addi	a3,a3,-1962 # ffffffffc0206b10 <commands+0xe80>
ffffffffc02022c2:	00004617          	auipc	a2,0x4
ffffffffc02022c6:	26e60613          	addi	a2,a2,622 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02022ca:	13000593          	li	a1,304
ffffffffc02022ce:	00004517          	auipc	a0,0x4
ffffffffc02022d2:	58250513          	addi	a0,a0,1410 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02022d6:	f4dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02022da:	00005697          	auipc	a3,0x5
ffffffffc02022de:	80e68693          	addi	a3,a3,-2034 # ffffffffc0206ae8 <commands+0xe58>
ffffffffc02022e2:	00004617          	auipc	a2,0x4
ffffffffc02022e6:	24e60613          	addi	a2,a2,590 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02022ea:	12e00593          	li	a1,302
ffffffffc02022ee:	00004517          	auipc	a0,0x4
ffffffffc02022f2:	56250513          	addi	a0,a0,1378 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02022f6:	f2dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02022fa:	00004697          	auipc	a3,0x4
ffffffffc02022fe:	7c668693          	addi	a3,a3,1990 # ffffffffc0206ac0 <commands+0xe30>
ffffffffc0202302:	00004617          	auipc	a2,0x4
ffffffffc0202306:	22e60613          	addi	a2,a2,558 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020230a:	12d00593          	li	a1,301
ffffffffc020230e:	00004517          	auipc	a0,0x4
ffffffffc0202312:	54250513          	addi	a0,a0,1346 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202316:	f0dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(p0 + 2 == p1);
ffffffffc020231a:	00004697          	auipc	a3,0x4
ffffffffc020231e:	79668693          	addi	a3,a3,1942 # ffffffffc0206ab0 <commands+0xe20>
ffffffffc0202322:	00004617          	auipc	a2,0x4
ffffffffc0202326:	20e60613          	addi	a2,a2,526 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020232a:	12800593          	li	a1,296
ffffffffc020232e:	00004517          	auipc	a0,0x4
ffffffffc0202332:	52250513          	addi	a0,a0,1314 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202336:	eedfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020233a:	00004697          	auipc	a3,0x4
ffffffffc020233e:	67668693          	addi	a3,a3,1654 # ffffffffc02069b0 <commands+0xd20>
ffffffffc0202342:	00004617          	auipc	a2,0x4
ffffffffc0202346:	1ee60613          	addi	a2,a2,494 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020234a:	12700593          	li	a1,295
ffffffffc020234e:	00004517          	auipc	a0,0x4
ffffffffc0202352:	50250513          	addi	a0,a0,1282 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202356:	ecdfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020235a:	00004697          	auipc	a3,0x4
ffffffffc020235e:	73668693          	addi	a3,a3,1846 # ffffffffc0206a90 <commands+0xe00>
ffffffffc0202362:	00004617          	auipc	a2,0x4
ffffffffc0202366:	1ce60613          	addi	a2,a2,462 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020236a:	12600593          	li	a1,294
ffffffffc020236e:	00004517          	auipc	a0,0x4
ffffffffc0202372:	4e250513          	addi	a0,a0,1250 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202376:	eadfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020237a:	00004697          	auipc	a3,0x4
ffffffffc020237e:	6e668693          	addi	a3,a3,1766 # ffffffffc0206a60 <commands+0xdd0>
ffffffffc0202382:	00004617          	auipc	a2,0x4
ffffffffc0202386:	1ae60613          	addi	a2,a2,430 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020238a:	12500593          	li	a1,293
ffffffffc020238e:	00004517          	auipc	a0,0x4
ffffffffc0202392:	4c250513          	addi	a0,a0,1218 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202396:	e8dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020239a:	00004697          	auipc	a3,0x4
ffffffffc020239e:	6ae68693          	addi	a3,a3,1710 # ffffffffc0206a48 <commands+0xdb8>
ffffffffc02023a2:	00004617          	auipc	a2,0x4
ffffffffc02023a6:	18e60613          	addi	a2,a2,398 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02023aa:	12400593          	li	a1,292
ffffffffc02023ae:	00004517          	auipc	a0,0x4
ffffffffc02023b2:	4a250513          	addi	a0,a0,1186 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02023b6:	e6dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023ba:	00004697          	auipc	a3,0x4
ffffffffc02023be:	5f668693          	addi	a3,a3,1526 # ffffffffc02069b0 <commands+0xd20>
ffffffffc02023c2:	00004617          	auipc	a2,0x4
ffffffffc02023c6:	16e60613          	addi	a2,a2,366 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02023ca:	11e00593          	li	a1,286
ffffffffc02023ce:	00004517          	auipc	a0,0x4
ffffffffc02023d2:	48250513          	addi	a0,a0,1154 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02023d6:	e4dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(!PageProperty(p0));
ffffffffc02023da:	00004697          	auipc	a3,0x4
ffffffffc02023de:	65668693          	addi	a3,a3,1622 # ffffffffc0206a30 <commands+0xda0>
ffffffffc02023e2:	00004617          	auipc	a2,0x4
ffffffffc02023e6:	14e60613          	addi	a2,a2,334 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02023ea:	11900593          	li	a1,281
ffffffffc02023ee:	00004517          	auipc	a0,0x4
ffffffffc02023f2:	46250513          	addi	a0,a0,1122 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02023f6:	e2dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02023fa:	00004697          	auipc	a3,0x4
ffffffffc02023fe:	75668693          	addi	a3,a3,1878 # ffffffffc0206b50 <commands+0xec0>
ffffffffc0202402:	00004617          	auipc	a2,0x4
ffffffffc0202406:	12e60613          	addi	a2,a2,302 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020240a:	13700593          	li	a1,311
ffffffffc020240e:	00004517          	auipc	a0,0x4
ffffffffc0202412:	44250513          	addi	a0,a0,1090 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202416:	e0dfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(total == 0);
ffffffffc020241a:	00004697          	auipc	a3,0x4
ffffffffc020241e:	76668693          	addi	a3,a3,1894 # ffffffffc0206b80 <commands+0xef0>
ffffffffc0202422:	00004617          	auipc	a2,0x4
ffffffffc0202426:	10e60613          	addi	a2,a2,270 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020242a:	14700593          	li	a1,327
ffffffffc020242e:	00004517          	auipc	a0,0x4
ffffffffc0202432:	42250513          	addi	a0,a0,1058 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202436:	dedfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(total == nr_free_pages());
ffffffffc020243a:	00004697          	auipc	a3,0x4
ffffffffc020243e:	42e68693          	addi	a3,a3,1070 # ffffffffc0206868 <commands+0xbd8>
ffffffffc0202442:	00004617          	auipc	a2,0x4
ffffffffc0202446:	0ee60613          	addi	a2,a2,238 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020244a:	11300593          	li	a1,275
ffffffffc020244e:	00004517          	auipc	a0,0x4
ffffffffc0202452:	40250513          	addi	a0,a0,1026 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202456:	dcdfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020245a:	00004697          	auipc	a3,0x4
ffffffffc020245e:	44e68693          	addi	a3,a3,1102 # ffffffffc02068a8 <commands+0xc18>
ffffffffc0202462:	00004617          	auipc	a2,0x4
ffffffffc0202466:	0ce60613          	addi	a2,a2,206 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020246a:	0d800593          	li	a1,216
ffffffffc020246e:	00004517          	auipc	a0,0x4
ffffffffc0202472:	3e250513          	addi	a0,a0,994 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202476:	dadfd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020247a <default_free_pages>:
{
ffffffffc020247a:	1141                	addi	sp,sp,-16
ffffffffc020247c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020247e:	14058463          	beqz	a1,ffffffffc02025c6 <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc0202482:	00659693          	slli	a3,a1,0x6
ffffffffc0202486:	96aa                	add	a3,a3,a0
ffffffffc0202488:	87aa                	mv	a5,a0
ffffffffc020248a:	02d50263          	beq	a0,a3,ffffffffc02024ae <default_free_pages+0x34>
ffffffffc020248e:	6798                	ld	a4,8(a5)
ffffffffc0202490:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202492:	10071a63          	bnez	a4,ffffffffc02025a6 <default_free_pages+0x12c>
ffffffffc0202496:	6798                	ld	a4,8(a5)
ffffffffc0202498:	8b09                	andi	a4,a4,2
ffffffffc020249a:	10071663          	bnez	a4,ffffffffc02025a6 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc020249e:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02024a2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02024a6:	04078793          	addi	a5,a5,64
ffffffffc02024aa:	fed792e3          	bne	a5,a3,ffffffffc020248e <default_free_pages+0x14>
    base->property = n;
ffffffffc02024ae:	2581                	sext.w	a1,a1
ffffffffc02024b0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02024b2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024b6:	4789                	li	a5,2
ffffffffc02024b8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02024bc:	000c0697          	auipc	a3,0xc0
ffffffffc02024c0:	7fc68693          	addi	a3,a3,2044 # ffffffffc02c2cb8 <free_area>
ffffffffc02024c4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02024c6:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02024c8:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02024cc:	9db9                	addw	a1,a1,a4
ffffffffc02024ce:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02024d0:	0ad78463          	beq	a5,a3,ffffffffc0202578 <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc02024d4:	fe878713          	addi	a4,a5,-24
ffffffffc02024d8:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02024dc:	4581                	li	a1,0
            if (base < page)
ffffffffc02024de:	00e56a63          	bltu	a0,a4,ffffffffc02024f2 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02024e2:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02024e4:	04d70c63          	beq	a4,a3,ffffffffc020253c <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc02024e8:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02024ea:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02024ee:	fee57ae3          	bgeu	a0,a4,ffffffffc02024e2 <default_free_pages+0x68>
ffffffffc02024f2:	c199                	beqz	a1,ffffffffc02024f8 <default_free_pages+0x7e>
ffffffffc02024f4:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02024f8:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02024fa:	e390                	sd	a2,0(a5)
ffffffffc02024fc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02024fe:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202500:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0202502:	00d70d63          	beq	a4,a3,ffffffffc020251c <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc0202506:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8f68>
        p = le2page(le, page_link);
ffffffffc020250a:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc020250e:	02059813          	slli	a6,a1,0x20
ffffffffc0202512:	01a85793          	srli	a5,a6,0x1a
ffffffffc0202516:	97b2                	add	a5,a5,a2
ffffffffc0202518:	02f50c63          	beq	a0,a5,ffffffffc0202550 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020251c:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc020251e:	00d78c63          	beq	a5,a3,ffffffffc0202536 <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0202522:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202524:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0202528:	02061593          	slli	a1,a2,0x20
ffffffffc020252c:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202530:	972a                	add	a4,a4,a0
ffffffffc0202532:	04e68a63          	beq	a3,a4,ffffffffc0202586 <default_free_pages+0x10c>
}
ffffffffc0202536:	60a2                	ld	ra,8(sp)
ffffffffc0202538:	0141                	addi	sp,sp,16
ffffffffc020253a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020253c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020253e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202540:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202542:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0202544:	02d70763          	beq	a4,a3,ffffffffc0202572 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0202548:	8832                	mv	a6,a2
ffffffffc020254a:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc020254c:	87ba                	mv	a5,a4
ffffffffc020254e:	bf71                	j	ffffffffc02024ea <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202550:	491c                	lw	a5,16(a0)
ffffffffc0202552:	9dbd                	addw	a1,a1,a5
ffffffffc0202554:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202558:	57f5                	li	a5,-3
ffffffffc020255a:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020255e:	01853803          	ld	a6,24(a0)
ffffffffc0202562:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0202564:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0202566:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020256a:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020256c:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8f60>
ffffffffc0202570:	b77d                	j	ffffffffc020251e <default_free_pages+0xa4>
ffffffffc0202572:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0202574:	873e                	mv	a4,a5
ffffffffc0202576:	bf41                	j	ffffffffc0202506 <default_free_pages+0x8c>
}
ffffffffc0202578:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020257a:	e390                	sd	a2,0(a5)
ffffffffc020257c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020257e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202580:	ed1c                	sd	a5,24(a0)
ffffffffc0202582:	0141                	addi	sp,sp,16
ffffffffc0202584:	8082                	ret
            base->property += p->property;
ffffffffc0202586:	ff87a703          	lw	a4,-8(a5)
ffffffffc020258a:	ff078693          	addi	a3,a5,-16
ffffffffc020258e:	9e39                	addw	a2,a2,a4
ffffffffc0202590:	c910                	sw	a2,16(a0)
ffffffffc0202592:	5775                	li	a4,-3
ffffffffc0202594:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202598:	6398                	ld	a4,0(a5)
ffffffffc020259a:	679c                	ld	a5,8(a5)
}
ffffffffc020259c:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020259e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025a0:	e398                	sd	a4,0(a5)
ffffffffc02025a2:	0141                	addi	sp,sp,16
ffffffffc02025a4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02025a6:	00004697          	auipc	a3,0x4
ffffffffc02025aa:	5f268693          	addi	a3,a3,1522 # ffffffffc0206b98 <commands+0xf08>
ffffffffc02025ae:	00004617          	auipc	a2,0x4
ffffffffc02025b2:	f8260613          	addi	a2,a2,-126 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02025b6:	09400593          	li	a1,148
ffffffffc02025ba:	00004517          	auipc	a0,0x4
ffffffffc02025be:	29650513          	addi	a0,a0,662 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02025c2:	c61fd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(n > 0);
ffffffffc02025c6:	00004697          	auipc	a3,0x4
ffffffffc02025ca:	5ca68693          	addi	a3,a3,1482 # ffffffffc0206b90 <commands+0xf00>
ffffffffc02025ce:	00004617          	auipc	a2,0x4
ffffffffc02025d2:	f6260613          	addi	a2,a2,-158 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02025d6:	09000593          	li	a1,144
ffffffffc02025da:	00004517          	auipc	a0,0x4
ffffffffc02025de:	27650513          	addi	a0,a0,630 # ffffffffc0206850 <commands+0xbc0>
ffffffffc02025e2:	c41fd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02025e6 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02025e6:	c941                	beqz	a0,ffffffffc0202676 <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc02025e8:	000c0597          	auipc	a1,0xc0
ffffffffc02025ec:	6d058593          	addi	a1,a1,1744 # ffffffffc02c2cb8 <free_area>
ffffffffc02025f0:	0105a803          	lw	a6,16(a1)
ffffffffc02025f4:	872a                	mv	a4,a0
ffffffffc02025f6:	02081793          	slli	a5,a6,0x20
ffffffffc02025fa:	9381                	srli	a5,a5,0x20
ffffffffc02025fc:	00a7ee63          	bltu	a5,a0,ffffffffc0202618 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202600:	87ae                	mv	a5,a1
ffffffffc0202602:	a801                	j	ffffffffc0202612 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc0202604:	ff87a683          	lw	a3,-8(a5)
ffffffffc0202608:	02069613          	slli	a2,a3,0x20
ffffffffc020260c:	9201                	srli	a2,a2,0x20
ffffffffc020260e:	00e67763          	bgeu	a2,a4,ffffffffc020261c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202612:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0202614:	feb798e3          	bne	a5,a1,ffffffffc0202604 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202618:	4501                	li	a0,0
}
ffffffffc020261a:	8082                	ret
    return listelm->prev;
ffffffffc020261c:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202620:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202624:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0202628:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020262c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202630:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc0202634:	02c77863          	bgeu	a4,a2,ffffffffc0202664 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0202638:	071a                	slli	a4,a4,0x6
ffffffffc020263a:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020263c:	41c686bb          	subw	a3,a3,t3
ffffffffc0202640:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202642:	00870613          	addi	a2,a4,8
ffffffffc0202646:	4689                	li	a3,2
ffffffffc0202648:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020264c:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202650:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0202654:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202658:	e290                	sd	a2,0(a3)
ffffffffc020265a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc020265e:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0202660:	01173c23          	sd	a7,24(a4)
ffffffffc0202664:	41c8083b          	subw	a6,a6,t3
ffffffffc0202668:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020266c:	5775                	li	a4,-3
ffffffffc020266e:	17c1                	addi	a5,a5,-16
ffffffffc0202670:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202674:	8082                	ret
{
ffffffffc0202676:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202678:	00004697          	auipc	a3,0x4
ffffffffc020267c:	51868693          	addi	a3,a3,1304 # ffffffffc0206b90 <commands+0xf00>
ffffffffc0202680:	00004617          	auipc	a2,0x4
ffffffffc0202684:	eb060613          	addi	a2,a2,-336 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0202688:	06c00593          	li	a1,108
ffffffffc020268c:	00004517          	auipc	a0,0x4
ffffffffc0202690:	1c450513          	addi	a0,a0,452 # ffffffffc0206850 <commands+0xbc0>
{
ffffffffc0202694:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202696:	b8dfd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020269a <default_init_memmap>:
{
ffffffffc020269a:	1141                	addi	sp,sp,-16
ffffffffc020269c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020269e:	c5f1                	beqz	a1,ffffffffc020276a <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc02026a0:	00659693          	slli	a3,a1,0x6
ffffffffc02026a4:	96aa                	add	a3,a3,a0
ffffffffc02026a6:	87aa                	mv	a5,a0
ffffffffc02026a8:	00d50f63          	beq	a0,a3,ffffffffc02026c6 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02026ac:	6798                	ld	a4,8(a5)
ffffffffc02026ae:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02026b0:	cf49                	beqz	a4,ffffffffc020274a <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02026b2:	0007a823          	sw	zero,16(a5)
ffffffffc02026b6:	0007b423          	sd	zero,8(a5)
ffffffffc02026ba:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02026be:	04078793          	addi	a5,a5,64
ffffffffc02026c2:	fed795e3          	bne	a5,a3,ffffffffc02026ac <default_init_memmap+0x12>
    base->property = n;
ffffffffc02026c6:	2581                	sext.w	a1,a1
ffffffffc02026c8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02026ca:	4789                	li	a5,2
ffffffffc02026cc:	00850713          	addi	a4,a0,8
ffffffffc02026d0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02026d4:	000c0697          	auipc	a3,0xc0
ffffffffc02026d8:	5e468693          	addi	a3,a3,1508 # ffffffffc02c2cb8 <free_area>
ffffffffc02026dc:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02026de:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02026e0:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02026e4:	9db9                	addw	a1,a1,a4
ffffffffc02026e6:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02026e8:	04d78a63          	beq	a5,a3,ffffffffc020273c <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc02026ec:	fe878713          	addi	a4,a5,-24
ffffffffc02026f0:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02026f4:	4581                	li	a1,0
            if (base < page)
ffffffffc02026f6:	00e56a63          	bltu	a0,a4,ffffffffc020270a <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02026fa:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02026fc:	02d70263          	beq	a4,a3,ffffffffc0202720 <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0202700:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0202702:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0202706:	fee57ae3          	bgeu	a0,a4,ffffffffc02026fa <default_init_memmap+0x60>
ffffffffc020270a:	c199                	beqz	a1,ffffffffc0202710 <default_init_memmap+0x76>
ffffffffc020270c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202710:	6398                	ld	a4,0(a5)
}
ffffffffc0202712:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202714:	e390                	sd	a2,0(a5)
ffffffffc0202716:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202718:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020271a:	ed18                	sd	a4,24(a0)
ffffffffc020271c:	0141                	addi	sp,sp,16
ffffffffc020271e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202720:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202722:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202724:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202726:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0202728:	00d70663          	beq	a4,a3,ffffffffc0202734 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020272c:	8832                	mv	a6,a2
ffffffffc020272e:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0202730:	87ba                	mv	a5,a4
ffffffffc0202732:	bfc1                	j	ffffffffc0202702 <default_init_memmap+0x68>
}
ffffffffc0202734:	60a2                	ld	ra,8(sp)
ffffffffc0202736:	e290                	sd	a2,0(a3)
ffffffffc0202738:	0141                	addi	sp,sp,16
ffffffffc020273a:	8082                	ret
ffffffffc020273c:	60a2                	ld	ra,8(sp)
ffffffffc020273e:	e390                	sd	a2,0(a5)
ffffffffc0202740:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202742:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202744:	ed1c                	sd	a5,24(a0)
ffffffffc0202746:	0141                	addi	sp,sp,16
ffffffffc0202748:	8082                	ret
        assert(PageReserved(p));
ffffffffc020274a:	00004697          	auipc	a3,0x4
ffffffffc020274e:	47668693          	addi	a3,a3,1142 # ffffffffc0206bc0 <commands+0xf30>
ffffffffc0202752:	00004617          	auipc	a2,0x4
ffffffffc0202756:	dde60613          	addi	a2,a2,-546 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020275a:	04b00593          	li	a1,75
ffffffffc020275e:	00004517          	auipc	a0,0x4
ffffffffc0202762:	0f250513          	addi	a0,a0,242 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202766:	abdfd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(n > 0);
ffffffffc020276a:	00004697          	auipc	a3,0x4
ffffffffc020276e:	42668693          	addi	a3,a3,1062 # ffffffffc0206b90 <commands+0xf00>
ffffffffc0202772:	00004617          	auipc	a2,0x4
ffffffffc0202776:	dbe60613          	addi	a2,a2,-578 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020277a:	04700593          	li	a1,71
ffffffffc020277e:	00004517          	auipc	a0,0x4
ffffffffc0202782:	0d250513          	addi	a0,a0,210 # ffffffffc0206850 <commands+0xbc0>
ffffffffc0202786:	a9dfd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020278a <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc020278a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020278c:	00004617          	auipc	a2,0x4
ffffffffc0202790:	cbc60613          	addi	a2,a2,-836 # ffffffffc0206448 <commands+0x7b8>
ffffffffc0202794:	06900593          	li	a1,105
ffffffffc0202798:	00004517          	auipc	a0,0x4
ffffffffc020279c:	ca050513          	addi	a0,a0,-864 # ffffffffc0206438 <commands+0x7a8>
pa2page(uintptr_t pa)
ffffffffc02027a0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02027a2:	a81fd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02027a6 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc02027a6:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02027a8:	00004617          	auipc	a2,0x4
ffffffffc02027ac:	c6860613          	addi	a2,a2,-920 # ffffffffc0206410 <commands+0x780>
ffffffffc02027b0:	07f00593          	li	a1,127
ffffffffc02027b4:	00004517          	auipc	a0,0x4
ffffffffc02027b8:	c8450513          	addi	a0,a0,-892 # ffffffffc0206438 <commands+0x7a8>
pte2page(pte_t pte)
ffffffffc02027bc:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02027be:	a65fd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02027c2 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027c2:	100027f3          	csrr	a5,sstatus
ffffffffc02027c6:	8b89                	andi	a5,a5,2
ffffffffc02027c8:	e799                	bnez	a5,ffffffffc02027d6 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02027ca:	000c4797          	auipc	a5,0xc4
ffffffffc02027ce:	5967b783          	ld	a5,1430(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc02027d2:	6f9c                	ld	a5,24(a5)
ffffffffc02027d4:	8782                	jr	a5
{
ffffffffc02027d6:	1141                	addi	sp,sp,-16
ffffffffc02027d8:	e406                	sd	ra,8(sp)
ffffffffc02027da:	e022                	sd	s0,0(sp)
ffffffffc02027dc:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02027de:	9d6fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02027e2:	000c4797          	auipc	a5,0xc4
ffffffffc02027e6:	57e7b783          	ld	a5,1406(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc02027ea:	6f9c                	ld	a5,24(a5)
ffffffffc02027ec:	8522                	mv	a0,s0
ffffffffc02027ee:	9782                	jalr	a5
ffffffffc02027f0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02027f2:	9bcfe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02027f6:	60a2                	ld	ra,8(sp)
ffffffffc02027f8:	8522                	mv	a0,s0
ffffffffc02027fa:	6402                	ld	s0,0(sp)
ffffffffc02027fc:	0141                	addi	sp,sp,16
ffffffffc02027fe:	8082                	ret

ffffffffc0202800 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202800:	100027f3          	csrr	a5,sstatus
ffffffffc0202804:	8b89                	andi	a5,a5,2
ffffffffc0202806:	e799                	bnez	a5,ffffffffc0202814 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202808:	000c4797          	auipc	a5,0xc4
ffffffffc020280c:	5587b783          	ld	a5,1368(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202810:	739c                	ld	a5,32(a5)
ffffffffc0202812:	8782                	jr	a5
{
ffffffffc0202814:	1101                	addi	sp,sp,-32
ffffffffc0202816:	ec06                	sd	ra,24(sp)
ffffffffc0202818:	e822                	sd	s0,16(sp)
ffffffffc020281a:	e426                	sd	s1,8(sp)
ffffffffc020281c:	842a                	mv	s0,a0
ffffffffc020281e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202820:	994fe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202824:	000c4797          	auipc	a5,0xc4
ffffffffc0202828:	53c7b783          	ld	a5,1340(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc020282c:	739c                	ld	a5,32(a5)
ffffffffc020282e:	85a6                	mv	a1,s1
ffffffffc0202830:	8522                	mv	a0,s0
ffffffffc0202832:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202834:	6442                	ld	s0,16(sp)
ffffffffc0202836:	60e2                	ld	ra,24(sp)
ffffffffc0202838:	64a2                	ld	s1,8(sp)
ffffffffc020283a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020283c:	972fe06f          	j	ffffffffc02009ae <intr_enable>

ffffffffc0202840 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202840:	100027f3          	csrr	a5,sstatus
ffffffffc0202844:	8b89                	andi	a5,a5,2
ffffffffc0202846:	e799                	bnez	a5,ffffffffc0202854 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0202848:	000c4797          	auipc	a5,0xc4
ffffffffc020284c:	5187b783          	ld	a5,1304(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202850:	779c                	ld	a5,40(a5)
ffffffffc0202852:	8782                	jr	a5
{
ffffffffc0202854:	1141                	addi	sp,sp,-16
ffffffffc0202856:	e406                	sd	ra,8(sp)
ffffffffc0202858:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020285a:	95afe0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020285e:	000c4797          	auipc	a5,0xc4
ffffffffc0202862:	5027b783          	ld	a5,1282(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202866:	779c                	ld	a5,40(a5)
ffffffffc0202868:	9782                	jalr	a5
ffffffffc020286a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020286c:	942fe0ef          	jal	ra,ffffffffc02009ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202870:	60a2                	ld	ra,8(sp)
ffffffffc0202872:	8522                	mv	a0,s0
ffffffffc0202874:	6402                	ld	s0,0(sp)
ffffffffc0202876:	0141                	addi	sp,sp,16
ffffffffc0202878:	8082                	ret

ffffffffc020287a <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020287a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc020287e:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0202882:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202884:	078e                	slli	a5,a5,0x3
{
ffffffffc0202886:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202888:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc020288c:	6094                	ld	a3,0(s1)
{
ffffffffc020288e:	f04a                	sd	s2,32(sp)
ffffffffc0202890:	ec4e                	sd	s3,24(sp)
ffffffffc0202892:	e852                	sd	s4,16(sp)
ffffffffc0202894:	fc06                	sd	ra,56(sp)
ffffffffc0202896:	f822                	sd	s0,48(sp)
ffffffffc0202898:	e456                	sd	s5,8(sp)
ffffffffc020289a:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc020289c:	0016f793          	andi	a5,a3,1
{
ffffffffc02028a0:	892e                	mv	s2,a1
ffffffffc02028a2:	8a32                	mv	s4,a2
ffffffffc02028a4:	000c4997          	auipc	s3,0xc4
ffffffffc02028a8:	4ac98993          	addi	s3,s3,1196 # ffffffffc02c6d50 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc02028ac:	efbd                	bnez	a5,ffffffffc020292a <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02028ae:	14060c63          	beqz	a2,ffffffffc0202a06 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02028b2:	100027f3          	csrr	a5,sstatus
ffffffffc02028b6:	8b89                	andi	a5,a5,2
ffffffffc02028b8:	14079963          	bnez	a5,ffffffffc0202a0a <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc02028bc:	000c4797          	auipc	a5,0xc4
ffffffffc02028c0:	4a47b783          	ld	a5,1188(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc02028c4:	6f9c                	ld	a5,24(a5)
ffffffffc02028c6:	4505                	li	a0,1
ffffffffc02028c8:	9782                	jalr	a5
ffffffffc02028ca:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02028cc:	12040d63          	beqz	s0,ffffffffc0202a06 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02028d0:	000c4b17          	auipc	s6,0xc4
ffffffffc02028d4:	488b0b13          	addi	s6,s6,1160 # ffffffffc02c6d58 <pages>
ffffffffc02028d8:	000b3503          	ld	a0,0(s6)
ffffffffc02028dc:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02028e0:	000c4997          	auipc	s3,0xc4
ffffffffc02028e4:	47098993          	addi	s3,s3,1136 # ffffffffc02c6d50 <npage>
ffffffffc02028e8:	40a40533          	sub	a0,s0,a0
ffffffffc02028ec:	8519                	srai	a0,a0,0x6
ffffffffc02028ee:	9556                	add	a0,a0,s5
ffffffffc02028f0:	0009b703          	ld	a4,0(s3)
ffffffffc02028f4:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02028f8:	4685                	li	a3,1
ffffffffc02028fa:	c014                	sw	a3,0(s0)
ffffffffc02028fc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02028fe:	0532                	slli	a0,a0,0xc
ffffffffc0202900:	16e7f763          	bgeu	a5,a4,ffffffffc0202a6e <get_pte+0x1f4>
ffffffffc0202904:	000c4797          	auipc	a5,0xc4
ffffffffc0202908:	4647b783          	ld	a5,1124(a5) # ffffffffc02c6d68 <va_pa_offset>
ffffffffc020290c:	6605                	lui	a2,0x1
ffffffffc020290e:	4581                	li	a1,0
ffffffffc0202910:	953e                	add	a0,a0,a5
ffffffffc0202912:	4a7020ef          	jal	ra,ffffffffc02055b8 <memset>
    return page - pages + nbase;
ffffffffc0202916:	000b3683          	ld	a3,0(s6)
ffffffffc020291a:	40d406b3          	sub	a3,s0,a3
ffffffffc020291e:	8699                	srai	a3,a3,0x6
ffffffffc0202920:	96d6                	add	a3,a3,s5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202922:	06aa                	slli	a3,a3,0xa
ffffffffc0202924:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202928:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020292a:	77fd                	lui	a5,0xfffff
ffffffffc020292c:	068a                	slli	a3,a3,0x2
ffffffffc020292e:	0009b703          	ld	a4,0(s3)
ffffffffc0202932:	8efd                	and	a3,a3,a5
ffffffffc0202934:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202938:	10e7ff63          	bgeu	a5,a4,ffffffffc0202a56 <get_pte+0x1dc>
ffffffffc020293c:	000c4a97          	auipc	s5,0xc4
ffffffffc0202940:	42ca8a93          	addi	s5,s5,1068 # ffffffffc02c6d68 <va_pa_offset>
ffffffffc0202944:	000ab403          	ld	s0,0(s5)
ffffffffc0202948:	01595793          	srli	a5,s2,0x15
ffffffffc020294c:	1ff7f793          	andi	a5,a5,511
ffffffffc0202950:	96a2                	add	a3,a3,s0
ffffffffc0202952:	00379413          	slli	s0,a5,0x3
ffffffffc0202956:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0202958:	6014                	ld	a3,0(s0)
ffffffffc020295a:	0016f793          	andi	a5,a3,1
ffffffffc020295e:	ebad                	bnez	a5,ffffffffc02029d0 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202960:	0a0a0363          	beqz	s4,ffffffffc0202a06 <get_pte+0x18c>
ffffffffc0202964:	100027f3          	csrr	a5,sstatus
ffffffffc0202968:	8b89                	andi	a5,a5,2
ffffffffc020296a:	efcd                	bnez	a5,ffffffffc0202a24 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc020296c:	000c4797          	auipc	a5,0xc4
ffffffffc0202970:	3f47b783          	ld	a5,1012(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202974:	6f9c                	ld	a5,24(a5)
ffffffffc0202976:	4505                	li	a0,1
ffffffffc0202978:	9782                	jalr	a5
ffffffffc020297a:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020297c:	c4c9                	beqz	s1,ffffffffc0202a06 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc020297e:	000c4b17          	auipc	s6,0xc4
ffffffffc0202982:	3dab0b13          	addi	s6,s6,986 # ffffffffc02c6d58 <pages>
ffffffffc0202986:	000b3503          	ld	a0,0(s6)
ffffffffc020298a:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020298e:	0009b703          	ld	a4,0(s3)
ffffffffc0202992:	40a48533          	sub	a0,s1,a0
ffffffffc0202996:	8519                	srai	a0,a0,0x6
ffffffffc0202998:	9552                	add	a0,a0,s4
ffffffffc020299a:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020299e:	4685                	li	a3,1
ffffffffc02029a0:	c094                	sw	a3,0(s1)
ffffffffc02029a2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029a4:	0532                	slli	a0,a0,0xc
ffffffffc02029a6:	0ee7f163          	bgeu	a5,a4,ffffffffc0202a88 <get_pte+0x20e>
ffffffffc02029aa:	000ab783          	ld	a5,0(s5)
ffffffffc02029ae:	6605                	lui	a2,0x1
ffffffffc02029b0:	4581                	li	a1,0
ffffffffc02029b2:	953e                	add	a0,a0,a5
ffffffffc02029b4:	405020ef          	jal	ra,ffffffffc02055b8 <memset>
    return page - pages + nbase;
ffffffffc02029b8:	000b3683          	ld	a3,0(s6)
ffffffffc02029bc:	40d486b3          	sub	a3,s1,a3
ffffffffc02029c0:	8699                	srai	a3,a3,0x6
ffffffffc02029c2:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02029c4:	06aa                	slli	a3,a3,0xa
ffffffffc02029c6:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02029ca:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02029cc:	0009b703          	ld	a4,0(s3)
ffffffffc02029d0:	068a                	slli	a3,a3,0x2
ffffffffc02029d2:	757d                	lui	a0,0xfffff
ffffffffc02029d4:	8ee9                	and	a3,a3,a0
ffffffffc02029d6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02029da:	06e7f263          	bgeu	a5,a4,ffffffffc0202a3e <get_pte+0x1c4>
ffffffffc02029de:	000ab503          	ld	a0,0(s5)
ffffffffc02029e2:	00c95913          	srli	s2,s2,0xc
ffffffffc02029e6:	1ff97913          	andi	s2,s2,511
ffffffffc02029ea:	96aa                	add	a3,a3,a0
ffffffffc02029ec:	00391513          	slli	a0,s2,0x3
ffffffffc02029f0:	9536                	add	a0,a0,a3
}
ffffffffc02029f2:	70e2                	ld	ra,56(sp)
ffffffffc02029f4:	7442                	ld	s0,48(sp)
ffffffffc02029f6:	74a2                	ld	s1,40(sp)
ffffffffc02029f8:	7902                	ld	s2,32(sp)
ffffffffc02029fa:	69e2                	ld	s3,24(sp)
ffffffffc02029fc:	6a42                	ld	s4,16(sp)
ffffffffc02029fe:	6aa2                	ld	s5,8(sp)
ffffffffc0202a00:	6b02                	ld	s6,0(sp)
ffffffffc0202a02:	6121                	addi	sp,sp,64
ffffffffc0202a04:	8082                	ret
            return NULL;
ffffffffc0202a06:	4501                	li	a0,0
ffffffffc0202a08:	b7ed                	j	ffffffffc02029f2 <get_pte+0x178>
        intr_disable();
ffffffffc0202a0a:	fabfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a0e:	000c4797          	auipc	a5,0xc4
ffffffffc0202a12:	3527b783          	ld	a5,850(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202a16:	6f9c                	ld	a5,24(a5)
ffffffffc0202a18:	4505                	li	a0,1
ffffffffc0202a1a:	9782                	jalr	a5
ffffffffc0202a1c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a1e:	f91fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202a22:	b56d                	j	ffffffffc02028cc <get_pte+0x52>
        intr_disable();
ffffffffc0202a24:	f91fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202a28:	000c4797          	auipc	a5,0xc4
ffffffffc0202a2c:	3387b783          	ld	a5,824(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202a30:	6f9c                	ld	a5,24(a5)
ffffffffc0202a32:	4505                	li	a0,1
ffffffffc0202a34:	9782                	jalr	a5
ffffffffc0202a36:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0202a38:	f77fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202a3c:	b781                	j	ffffffffc020297c <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202a3e:	00004617          	auipc	a2,0x4
ffffffffc0202a42:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0202a46:	0fa00593          	li	a1,250
ffffffffc0202a4a:	00004517          	auipc	a0,0x4
ffffffffc0202a4e:	1d650513          	addi	a0,a0,470 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202a52:	fd0fd0ef          	jal	ra,ffffffffc0200222 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202a56:	00004617          	auipc	a2,0x4
ffffffffc0202a5a:	a2260613          	addi	a2,a2,-1502 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0202a5e:	0ed00593          	li	a1,237
ffffffffc0202a62:	00004517          	auipc	a0,0x4
ffffffffc0202a66:	1be50513          	addi	a0,a0,446 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202a6a:	fb8fd0ef          	jal	ra,ffffffffc0200222 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202a6e:	86aa                	mv	a3,a0
ffffffffc0202a70:	00004617          	auipc	a2,0x4
ffffffffc0202a74:	a0860613          	addi	a2,a2,-1528 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0202a78:	0e900593          	li	a1,233
ffffffffc0202a7c:	00004517          	auipc	a0,0x4
ffffffffc0202a80:	1a450513          	addi	a0,a0,420 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202a84:	f9efd0ef          	jal	ra,ffffffffc0200222 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202a88:	86aa                	mv	a3,a0
ffffffffc0202a8a:	00004617          	auipc	a2,0x4
ffffffffc0202a8e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0202a92:	0f700593          	li	a1,247
ffffffffc0202a96:	00004517          	auipc	a0,0x4
ffffffffc0202a9a:	18a50513          	addi	a0,a0,394 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202a9e:	f84fd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0202aa2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202aa2:	1141                	addi	sp,sp,-16
ffffffffc0202aa4:	e022                	sd	s0,0(sp)
ffffffffc0202aa6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202aa8:	4601                	li	a2,0
{
ffffffffc0202aaa:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202aac:	dcfff0ef          	jal	ra,ffffffffc020287a <get_pte>
    if (ptep_store != NULL)
ffffffffc0202ab0:	c011                	beqz	s0,ffffffffc0202ab4 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202ab2:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ab4:	c511                	beqz	a0,ffffffffc0202ac0 <get_page+0x1e>
ffffffffc0202ab6:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202ab8:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202aba:	0017f713          	andi	a4,a5,1
ffffffffc0202abe:	e709                	bnez	a4,ffffffffc0202ac8 <get_page+0x26>
}
ffffffffc0202ac0:	60a2                	ld	ra,8(sp)
ffffffffc0202ac2:	6402                	ld	s0,0(sp)
ffffffffc0202ac4:	0141                	addi	sp,sp,16
ffffffffc0202ac6:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ac8:	078a                	slli	a5,a5,0x2
ffffffffc0202aca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202acc:	000c4717          	auipc	a4,0xc4
ffffffffc0202ad0:	28473703          	ld	a4,644(a4) # ffffffffc02c6d50 <npage>
ffffffffc0202ad4:	00e7ff63          	bgeu	a5,a4,ffffffffc0202af2 <get_page+0x50>
ffffffffc0202ad8:	60a2                	ld	ra,8(sp)
ffffffffc0202ada:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0202adc:	fff80537          	lui	a0,0xfff80
ffffffffc0202ae0:	97aa                	add	a5,a5,a0
ffffffffc0202ae2:	079a                	slli	a5,a5,0x6
ffffffffc0202ae4:	000c4517          	auipc	a0,0xc4
ffffffffc0202ae8:	27453503          	ld	a0,628(a0) # ffffffffc02c6d58 <pages>
ffffffffc0202aec:	953e                	add	a0,a0,a5
ffffffffc0202aee:	0141                	addi	sp,sp,16
ffffffffc0202af0:	8082                	ret
ffffffffc0202af2:	c99ff0ef          	jal	ra,ffffffffc020278a <pa2page.part.0>

ffffffffc0202af6 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202af6:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202af8:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202afc:	f486                	sd	ra,104(sp)
ffffffffc0202afe:	f0a2                	sd	s0,96(sp)
ffffffffc0202b00:	eca6                	sd	s1,88(sp)
ffffffffc0202b02:	e8ca                	sd	s2,80(sp)
ffffffffc0202b04:	e4ce                	sd	s3,72(sp)
ffffffffc0202b06:	e0d2                	sd	s4,64(sp)
ffffffffc0202b08:	fc56                	sd	s5,56(sp)
ffffffffc0202b0a:	f85a                	sd	s6,48(sp)
ffffffffc0202b0c:	f45e                	sd	s7,40(sp)
ffffffffc0202b0e:	f062                	sd	s8,32(sp)
ffffffffc0202b10:	ec66                	sd	s9,24(sp)
ffffffffc0202b12:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b14:	17d2                	slli	a5,a5,0x34
ffffffffc0202b16:	e3ed                	bnez	a5,ffffffffc0202bf8 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202b18:	002007b7          	lui	a5,0x200
ffffffffc0202b1c:	842e                	mv	s0,a1
ffffffffc0202b1e:	0ef5ed63          	bltu	a1,a5,ffffffffc0202c18 <unmap_range+0x122>
ffffffffc0202b22:	8932                	mv	s2,a2
ffffffffc0202b24:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202c18 <unmap_range+0x122>
ffffffffc0202b28:	4785                	li	a5,1
ffffffffc0202b2a:	07fe                	slli	a5,a5,0x1f
ffffffffc0202b2c:	0ec7e663          	bltu	a5,a2,ffffffffc0202c18 <unmap_range+0x122>
ffffffffc0202b30:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202b32:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202b34:	000c4c97          	auipc	s9,0xc4
ffffffffc0202b38:	21cc8c93          	addi	s9,s9,540 # ffffffffc02c6d50 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b3c:	000c4c17          	auipc	s8,0xc4
ffffffffc0202b40:	21cc0c13          	addi	s8,s8,540 # ffffffffc02c6d58 <pages>
ffffffffc0202b44:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202b48:	000c4d17          	auipc	s10,0xc4
ffffffffc0202b4c:	218d0d13          	addi	s10,s10,536 # ffffffffc02c6d60 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202b50:	00200b37          	lui	s6,0x200
ffffffffc0202b54:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202b58:	4601                	li	a2,0
ffffffffc0202b5a:	85a2                	mv	a1,s0
ffffffffc0202b5c:	854e                	mv	a0,s3
ffffffffc0202b5e:	d1dff0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc0202b62:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0202b64:	cd29                	beqz	a0,ffffffffc0202bbe <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc0202b66:	611c                	ld	a5,0(a0)
ffffffffc0202b68:	e395                	bnez	a5,ffffffffc0202b8c <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202b6a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202b6c:	ff2466e3          	bltu	s0,s2,ffffffffc0202b58 <unmap_range+0x62>
}
ffffffffc0202b70:	70a6                	ld	ra,104(sp)
ffffffffc0202b72:	7406                	ld	s0,96(sp)
ffffffffc0202b74:	64e6                	ld	s1,88(sp)
ffffffffc0202b76:	6946                	ld	s2,80(sp)
ffffffffc0202b78:	69a6                	ld	s3,72(sp)
ffffffffc0202b7a:	6a06                	ld	s4,64(sp)
ffffffffc0202b7c:	7ae2                	ld	s5,56(sp)
ffffffffc0202b7e:	7b42                	ld	s6,48(sp)
ffffffffc0202b80:	7ba2                	ld	s7,40(sp)
ffffffffc0202b82:	7c02                	ld	s8,32(sp)
ffffffffc0202b84:	6ce2                	ld	s9,24(sp)
ffffffffc0202b86:	6d42                	ld	s10,16(sp)
ffffffffc0202b88:	6165                	addi	sp,sp,112
ffffffffc0202b8a:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202b8c:	0017f713          	andi	a4,a5,1
ffffffffc0202b90:	df69                	beqz	a4,ffffffffc0202b6a <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202b92:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b96:	078a                	slli	a5,a5,0x2
ffffffffc0202b98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b9a:	08e7ff63          	bgeu	a5,a4,ffffffffc0202c38 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b9e:	000c3503          	ld	a0,0(s8)
ffffffffc0202ba2:	97de                	add	a5,a5,s7
ffffffffc0202ba4:	079a                	slli	a5,a5,0x6
ffffffffc0202ba6:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202ba8:	411c                	lw	a5,0(a0)
ffffffffc0202baa:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202bae:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202bb0:	cf11                	beqz	a4,ffffffffc0202bcc <unmap_range+0xd6>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202bb2:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202bb6:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202bba:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202bbc:	bf45                	j	ffffffffc0202b6c <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202bbe:	945a                	add	s0,s0,s6
ffffffffc0202bc0:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202bc4:	d455                	beqz	s0,ffffffffc0202b70 <unmap_range+0x7a>
ffffffffc0202bc6:	f92469e3          	bltu	s0,s2,ffffffffc0202b58 <unmap_range+0x62>
ffffffffc0202bca:	b75d                	j	ffffffffc0202b70 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202bcc:	100027f3          	csrr	a5,sstatus
ffffffffc0202bd0:	8b89                	andi	a5,a5,2
ffffffffc0202bd2:	e799                	bnez	a5,ffffffffc0202be0 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0202bd4:	000d3783          	ld	a5,0(s10)
ffffffffc0202bd8:	4585                	li	a1,1
ffffffffc0202bda:	739c                	ld	a5,32(a5)
ffffffffc0202bdc:	9782                	jalr	a5
    if (flag)
ffffffffc0202bde:	bfd1                	j	ffffffffc0202bb2 <unmap_range+0xbc>
ffffffffc0202be0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202be2:	dd3fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202be6:	000d3783          	ld	a5,0(s10)
ffffffffc0202bea:	6522                	ld	a0,8(sp)
ffffffffc0202bec:	4585                	li	a1,1
ffffffffc0202bee:	739c                	ld	a5,32(a5)
ffffffffc0202bf0:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bf2:	dbdfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202bf6:	bf75                	j	ffffffffc0202bb2 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202bf8:	00004697          	auipc	a3,0x4
ffffffffc0202bfc:	03868693          	addi	a3,a3,56 # ffffffffc0206c30 <default_pmm_manager+0x48>
ffffffffc0202c00:	00004617          	auipc	a2,0x4
ffffffffc0202c04:	93060613          	addi	a2,a2,-1744 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0202c08:	12200593          	li	a1,290
ffffffffc0202c0c:	00004517          	auipc	a0,0x4
ffffffffc0202c10:	01450513          	addi	a0,a0,20 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202c14:	e0efd0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202c18:	00004697          	auipc	a3,0x4
ffffffffc0202c1c:	04868693          	addi	a3,a3,72 # ffffffffc0206c60 <default_pmm_manager+0x78>
ffffffffc0202c20:	00004617          	auipc	a2,0x4
ffffffffc0202c24:	91060613          	addi	a2,a2,-1776 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0202c28:	12300593          	li	a1,291
ffffffffc0202c2c:	00004517          	auipc	a0,0x4
ffffffffc0202c30:	ff450513          	addi	a0,a0,-12 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202c34:	deefd0ef          	jal	ra,ffffffffc0200222 <__panic>
ffffffffc0202c38:	b53ff0ef          	jal	ra,ffffffffc020278a <pa2page.part.0>

ffffffffc0202c3c <exit_range>:
{
ffffffffc0202c3c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c3e:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202c42:	fc86                	sd	ra,120(sp)
ffffffffc0202c44:	f8a2                	sd	s0,112(sp)
ffffffffc0202c46:	f4a6                	sd	s1,104(sp)
ffffffffc0202c48:	f0ca                	sd	s2,96(sp)
ffffffffc0202c4a:	ecce                	sd	s3,88(sp)
ffffffffc0202c4c:	e8d2                	sd	s4,80(sp)
ffffffffc0202c4e:	e4d6                	sd	s5,72(sp)
ffffffffc0202c50:	e0da                	sd	s6,64(sp)
ffffffffc0202c52:	fc5e                	sd	s7,56(sp)
ffffffffc0202c54:	f862                	sd	s8,48(sp)
ffffffffc0202c56:	f466                	sd	s9,40(sp)
ffffffffc0202c58:	f06a                	sd	s10,32(sp)
ffffffffc0202c5a:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c5c:	17d2                	slli	a5,a5,0x34
ffffffffc0202c5e:	20079a63          	bnez	a5,ffffffffc0202e72 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202c62:	002007b7          	lui	a5,0x200
ffffffffc0202c66:	24f5e463          	bltu	a1,a5,ffffffffc0202eae <exit_range+0x272>
ffffffffc0202c6a:	8ab2                	mv	s5,a2
ffffffffc0202c6c:	24c5f163          	bgeu	a1,a2,ffffffffc0202eae <exit_range+0x272>
ffffffffc0202c70:	4785                	li	a5,1
ffffffffc0202c72:	07fe                	slli	a5,a5,0x1f
ffffffffc0202c74:	22c7ed63          	bltu	a5,a2,ffffffffc0202eae <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202c78:	c00009b7          	lui	s3,0xc0000
ffffffffc0202c7c:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202c80:	ffe00937          	lui	s2,0xffe00
ffffffffc0202c84:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202c88:	5cfd                	li	s9,-1
ffffffffc0202c8a:	8c2a                	mv	s8,a0
ffffffffc0202c8c:	0125f933          	and	s2,a1,s2
ffffffffc0202c90:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202c92:	000c4d17          	auipc	s10,0xc4
ffffffffc0202c96:	0bed0d13          	addi	s10,s10,190 # ffffffffc02c6d50 <npage>
    return KADDR(page2pa(page));
ffffffffc0202c9a:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202c9e:	000c4717          	auipc	a4,0xc4
ffffffffc0202ca2:	0ba70713          	addi	a4,a4,186 # ffffffffc02c6d58 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0202ca6:	000c4d97          	auipc	s11,0xc4
ffffffffc0202caa:	0bad8d93          	addi	s11,s11,186 # ffffffffc02c6d60 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202cae:	c0000437          	lui	s0,0xc0000
ffffffffc0202cb2:	944e                	add	s0,s0,s3
ffffffffc0202cb4:	8079                	srli	s0,s0,0x1e
ffffffffc0202cb6:	1ff47413          	andi	s0,s0,511
ffffffffc0202cba:	040e                	slli	s0,s0,0x3
ffffffffc0202cbc:	9462                	add	s0,s0,s8
ffffffffc0202cbe:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
        if (pde1 & PTE_V)
ffffffffc0202cc2:	001a7793          	andi	a5,s4,1
ffffffffc0202cc6:	eb99                	bnez	a5,ffffffffc0202cdc <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0202cc8:	12098463          	beqz	s3,ffffffffc0202df0 <exit_range+0x1b4>
ffffffffc0202ccc:	400007b7          	lui	a5,0x40000
ffffffffc0202cd0:	97ce                	add	a5,a5,s3
ffffffffc0202cd2:	894e                	mv	s2,s3
ffffffffc0202cd4:	1159fe63          	bgeu	s3,s5,ffffffffc0202df0 <exit_range+0x1b4>
ffffffffc0202cd8:	89be                	mv	s3,a5
ffffffffc0202cda:	bfd1                	j	ffffffffc0202cae <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc0202cdc:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ce0:	0a0a                	slli	s4,s4,0x2
ffffffffc0202ce2:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ce6:	1cfa7263          	bgeu	s4,a5,ffffffffc0202eaa <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cea:	fff80637          	lui	a2,0xfff80
ffffffffc0202cee:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202cf0:	000806b7          	lui	a3,0x80
ffffffffc0202cf4:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202cf6:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202cfa:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cfc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202cfe:	18f5fa63          	bgeu	a1,a5,ffffffffc0202e92 <exit_range+0x256>
ffffffffc0202d02:	000c4817          	auipc	a6,0xc4
ffffffffc0202d06:	06680813          	addi	a6,a6,102 # ffffffffc02c6d68 <va_pa_offset>
ffffffffc0202d0a:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202d0e:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202d10:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202d14:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202d16:	00080337          	lui	t1,0x80
ffffffffc0202d1a:	6885                	lui	a7,0x1
ffffffffc0202d1c:	a819                	j	ffffffffc0202d32 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202d1e:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202d20:	002007b7          	lui	a5,0x200
ffffffffc0202d24:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202d26:	08090c63          	beqz	s2,ffffffffc0202dbe <exit_range+0x182>
ffffffffc0202d2a:	09397a63          	bgeu	s2,s3,ffffffffc0202dbe <exit_range+0x182>
ffffffffc0202d2e:	0f597063          	bgeu	s2,s5,ffffffffc0202e0e <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202d32:	01595493          	srli	s1,s2,0x15
ffffffffc0202d36:	1ff4f493          	andi	s1,s1,511
ffffffffc0202d3a:	048e                	slli	s1,s1,0x3
ffffffffc0202d3c:	94da                	add	s1,s1,s6
ffffffffc0202d3e:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202d40:	0017f693          	andi	a3,a5,1
ffffffffc0202d44:	dee9                	beqz	a3,ffffffffc0202d1e <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202d46:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d4a:	078a                	slli	a5,a5,0x2
ffffffffc0202d4c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d4e:	14b7fe63          	bgeu	a5,a1,ffffffffc0202eaa <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d52:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202d54:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202d58:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202d5c:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d60:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d62:	12bef863          	bgeu	t4,a1,ffffffffc0202e92 <exit_range+0x256>
ffffffffc0202d66:	00083783          	ld	a5,0(a6)
ffffffffc0202d6a:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202d6c:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202d70:	629c                	ld	a5,0(a3)
ffffffffc0202d72:	8b85                	andi	a5,a5,1
ffffffffc0202d74:	f7d5                	bnez	a5,ffffffffc0202d20 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202d76:	06a1                	addi	a3,a3,8
ffffffffc0202d78:	fed59ce3          	bne	a1,a3,ffffffffc0202d70 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d7c:	631c                	ld	a5,0(a4)
ffffffffc0202d7e:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202d80:	100027f3          	csrr	a5,sstatus
ffffffffc0202d84:	8b89                	andi	a5,a5,2
ffffffffc0202d86:	e7d9                	bnez	a5,ffffffffc0202e14 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202d88:	000db783          	ld	a5,0(s11)
ffffffffc0202d8c:	4585                	li	a1,1
ffffffffc0202d8e:	e032                	sd	a2,0(sp)
ffffffffc0202d90:	739c                	ld	a5,32(a5)
ffffffffc0202d92:	9782                	jalr	a5
    if (flag)
ffffffffc0202d94:	6602                	ld	a2,0(sp)
ffffffffc0202d96:	000c4817          	auipc	a6,0xc4
ffffffffc0202d9a:	fd280813          	addi	a6,a6,-46 # ffffffffc02c6d68 <va_pa_offset>
ffffffffc0202d9e:	fff80e37          	lui	t3,0xfff80
ffffffffc0202da2:	00080337          	lui	t1,0x80
ffffffffc0202da6:	6885                	lui	a7,0x1
ffffffffc0202da8:	000c4717          	auipc	a4,0xc4
ffffffffc0202dac:	fb070713          	addi	a4,a4,-80 # ffffffffc02c6d58 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202db0:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0202db4:	002007b7          	lui	a5,0x200
ffffffffc0202db8:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202dba:	f60918e3          	bnez	s2,ffffffffc0202d2a <exit_range+0xee>
            if (free_pd0)
ffffffffc0202dbe:	f00b85e3          	beqz	s7,ffffffffc0202cc8 <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc0202dc2:	000d3783          	ld	a5,0(s10)
ffffffffc0202dc6:	0efa7263          	bgeu	s4,a5,ffffffffc0202eaa <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dca:	6308                	ld	a0,0(a4)
ffffffffc0202dcc:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202dce:	100027f3          	csrr	a5,sstatus
ffffffffc0202dd2:	8b89                	andi	a5,a5,2
ffffffffc0202dd4:	efad                	bnez	a5,ffffffffc0202e4e <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0202dd6:	000db783          	ld	a5,0(s11)
ffffffffc0202dda:	4585                	li	a1,1
ffffffffc0202ddc:	739c                	ld	a5,32(a5)
ffffffffc0202dde:	9782                	jalr	a5
ffffffffc0202de0:	000c4717          	auipc	a4,0xc4
ffffffffc0202de4:	f7870713          	addi	a4,a4,-136 # ffffffffc02c6d58 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202de8:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202dec:	ee0990e3          	bnez	s3,ffffffffc0202ccc <exit_range+0x90>
}
ffffffffc0202df0:	70e6                	ld	ra,120(sp)
ffffffffc0202df2:	7446                	ld	s0,112(sp)
ffffffffc0202df4:	74a6                	ld	s1,104(sp)
ffffffffc0202df6:	7906                	ld	s2,96(sp)
ffffffffc0202df8:	69e6                	ld	s3,88(sp)
ffffffffc0202dfa:	6a46                	ld	s4,80(sp)
ffffffffc0202dfc:	6aa6                	ld	s5,72(sp)
ffffffffc0202dfe:	6b06                	ld	s6,64(sp)
ffffffffc0202e00:	7be2                	ld	s7,56(sp)
ffffffffc0202e02:	7c42                	ld	s8,48(sp)
ffffffffc0202e04:	7ca2                	ld	s9,40(sp)
ffffffffc0202e06:	7d02                	ld	s10,32(sp)
ffffffffc0202e08:	6de2                	ld	s11,24(sp)
ffffffffc0202e0a:	6109                	addi	sp,sp,128
ffffffffc0202e0c:	8082                	ret
            if (free_pd0)
ffffffffc0202e0e:	ea0b8fe3          	beqz	s7,ffffffffc0202ccc <exit_range+0x90>
ffffffffc0202e12:	bf45                	j	ffffffffc0202dc2 <exit_range+0x186>
ffffffffc0202e14:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202e16:	e42a                	sd	a0,8(sp)
ffffffffc0202e18:	b9dfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e1c:	000db783          	ld	a5,0(s11)
ffffffffc0202e20:	6522                	ld	a0,8(sp)
ffffffffc0202e22:	4585                	li	a1,1
ffffffffc0202e24:	739c                	ld	a5,32(a5)
ffffffffc0202e26:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e28:	b87fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e2c:	6602                	ld	a2,0(sp)
ffffffffc0202e2e:	000c4717          	auipc	a4,0xc4
ffffffffc0202e32:	f2a70713          	addi	a4,a4,-214 # ffffffffc02c6d58 <pages>
ffffffffc0202e36:	6885                	lui	a7,0x1
ffffffffc0202e38:	00080337          	lui	t1,0x80
ffffffffc0202e3c:	fff80e37          	lui	t3,0xfff80
ffffffffc0202e40:	000c4817          	auipc	a6,0xc4
ffffffffc0202e44:	f2880813          	addi	a6,a6,-216 # ffffffffc02c6d68 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202e48:	0004b023          	sd	zero,0(s1)
ffffffffc0202e4c:	b7a5                	j	ffffffffc0202db4 <exit_range+0x178>
ffffffffc0202e4e:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202e50:	b65fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e54:	000db783          	ld	a5,0(s11)
ffffffffc0202e58:	6502                	ld	a0,0(sp)
ffffffffc0202e5a:	4585                	li	a1,1
ffffffffc0202e5c:	739c                	ld	a5,32(a5)
ffffffffc0202e5e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e60:	b4ffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202e64:	000c4717          	auipc	a4,0xc4
ffffffffc0202e68:	ef470713          	addi	a4,a4,-268 # ffffffffc02c6d58 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202e6c:	00043023          	sd	zero,0(s0)
ffffffffc0202e70:	bfb5                	j	ffffffffc0202dec <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202e72:	00004697          	auipc	a3,0x4
ffffffffc0202e76:	dbe68693          	addi	a3,a3,-578 # ffffffffc0206c30 <default_pmm_manager+0x48>
ffffffffc0202e7a:	00003617          	auipc	a2,0x3
ffffffffc0202e7e:	6b660613          	addi	a2,a2,1718 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0202e82:	13700593          	li	a1,311
ffffffffc0202e86:	00004517          	auipc	a0,0x4
ffffffffc0202e8a:	d9a50513          	addi	a0,a0,-614 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202e8e:	b94fd0ef          	jal	ra,ffffffffc0200222 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e92:	00003617          	auipc	a2,0x3
ffffffffc0202e96:	5e660613          	addi	a2,a2,1510 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0202e9a:	07100593          	li	a1,113
ffffffffc0202e9e:	00003517          	auipc	a0,0x3
ffffffffc0202ea2:	59a50513          	addi	a0,a0,1434 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0202ea6:	b7cfd0ef          	jal	ra,ffffffffc0200222 <__panic>
ffffffffc0202eaa:	8e1ff0ef          	jal	ra,ffffffffc020278a <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202eae:	00004697          	auipc	a3,0x4
ffffffffc0202eb2:	db268693          	addi	a3,a3,-590 # ffffffffc0206c60 <default_pmm_manager+0x78>
ffffffffc0202eb6:	00003617          	auipc	a2,0x3
ffffffffc0202eba:	67a60613          	addi	a2,a2,1658 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0202ebe:	13800593          	li	a1,312
ffffffffc0202ec2:	00004517          	auipc	a0,0x4
ffffffffc0202ec6:	d5e50513          	addi	a0,a0,-674 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0202eca:	b58fd0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0202ece <page_remove>:
{
ffffffffc0202ece:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ed0:	4601                	li	a2,0
{
ffffffffc0202ed2:	ec26                	sd	s1,24(sp)
ffffffffc0202ed4:	f406                	sd	ra,40(sp)
ffffffffc0202ed6:	f022                	sd	s0,32(sp)
ffffffffc0202ed8:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202eda:	9a1ff0ef          	jal	ra,ffffffffc020287a <get_pte>
    if (ptep != NULL)
ffffffffc0202ede:	c511                	beqz	a0,ffffffffc0202eea <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202ee0:	611c                	ld	a5,0(a0)
ffffffffc0202ee2:	842a                	mv	s0,a0
ffffffffc0202ee4:	0017f713          	andi	a4,a5,1
ffffffffc0202ee8:	e711                	bnez	a4,ffffffffc0202ef4 <page_remove+0x26>
}
ffffffffc0202eea:	70a2                	ld	ra,40(sp)
ffffffffc0202eec:	7402                	ld	s0,32(sp)
ffffffffc0202eee:	64e2                	ld	s1,24(sp)
ffffffffc0202ef0:	6145                	addi	sp,sp,48
ffffffffc0202ef2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ef4:	078a                	slli	a5,a5,0x2
ffffffffc0202ef6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ef8:	000c4717          	auipc	a4,0xc4
ffffffffc0202efc:	e5873703          	ld	a4,-424(a4) # ffffffffc02c6d50 <npage>
ffffffffc0202f00:	06e7f363          	bgeu	a5,a4,ffffffffc0202f66 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f04:	fff80537          	lui	a0,0xfff80
ffffffffc0202f08:	97aa                	add	a5,a5,a0
ffffffffc0202f0a:	079a                	slli	a5,a5,0x6
ffffffffc0202f0c:	000c4517          	auipc	a0,0xc4
ffffffffc0202f10:	e4c53503          	ld	a0,-436(a0) # ffffffffc02c6d58 <pages>
ffffffffc0202f14:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202f16:	411c                	lw	a5,0(a0)
ffffffffc0202f18:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f1c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202f1e:	cb11                	beqz	a4,ffffffffc0202f32 <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202f20:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202f24:	12048073          	sfence.vma	s1
}
ffffffffc0202f28:	70a2                	ld	ra,40(sp)
ffffffffc0202f2a:	7402                	ld	s0,32(sp)
ffffffffc0202f2c:	64e2                	ld	s1,24(sp)
ffffffffc0202f2e:	6145                	addi	sp,sp,48
ffffffffc0202f30:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202f32:	100027f3          	csrr	a5,sstatus
ffffffffc0202f36:	8b89                	andi	a5,a5,2
ffffffffc0202f38:	eb89                	bnez	a5,ffffffffc0202f4a <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202f3a:	000c4797          	auipc	a5,0xc4
ffffffffc0202f3e:	e267b783          	ld	a5,-474(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202f42:	739c                	ld	a5,32(a5)
ffffffffc0202f44:	4585                	li	a1,1
ffffffffc0202f46:	9782                	jalr	a5
    if (flag)
ffffffffc0202f48:	bfe1                	j	ffffffffc0202f20 <page_remove+0x52>
        intr_disable();
ffffffffc0202f4a:	e42a                	sd	a0,8(sp)
ffffffffc0202f4c:	a69fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0202f50:	000c4797          	auipc	a5,0xc4
ffffffffc0202f54:	e107b783          	ld	a5,-496(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0202f58:	739c                	ld	a5,32(a5)
ffffffffc0202f5a:	6522                	ld	a0,8(sp)
ffffffffc0202f5c:	4585                	li	a1,1
ffffffffc0202f5e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f60:	a4ffd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0202f64:	bf75                	j	ffffffffc0202f20 <page_remove+0x52>
ffffffffc0202f66:	825ff0ef          	jal	ra,ffffffffc020278a <pa2page.part.0>

ffffffffc0202f6a <page_insert>:
{
ffffffffc0202f6a:	7139                	addi	sp,sp,-64
ffffffffc0202f6c:	e852                	sd	s4,16(sp)
ffffffffc0202f6e:	8a32                	mv	s4,a2
ffffffffc0202f70:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f72:	4605                	li	a2,1
{
ffffffffc0202f74:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f76:	85d2                	mv	a1,s4
{
ffffffffc0202f78:	f426                	sd	s1,40(sp)
ffffffffc0202f7a:	fc06                	sd	ra,56(sp)
ffffffffc0202f7c:	f04a                	sd	s2,32(sp)
ffffffffc0202f7e:	ec4e                	sd	s3,24(sp)
ffffffffc0202f80:	e456                	sd	s5,8(sp)
ffffffffc0202f82:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f84:	8f7ff0ef          	jal	ra,ffffffffc020287a <get_pte>
    if (ptep == NULL)
ffffffffc0202f88:	c961                	beqz	a0,ffffffffc0203058 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202f8a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202f8c:	611c                	ld	a5,0(a0)
ffffffffc0202f8e:	89aa                	mv	s3,a0
ffffffffc0202f90:	0016871b          	addiw	a4,a3,1
ffffffffc0202f94:	c018                	sw	a4,0(s0)
ffffffffc0202f96:	0017f713          	andi	a4,a5,1
ffffffffc0202f9a:	ef05                	bnez	a4,ffffffffc0202fd2 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202f9c:	000c4717          	auipc	a4,0xc4
ffffffffc0202fa0:	dbc73703          	ld	a4,-580(a4) # ffffffffc02c6d58 <pages>
ffffffffc0202fa4:	8c19                	sub	s0,s0,a4
ffffffffc0202fa6:	000807b7          	lui	a5,0x80
ffffffffc0202faa:	8419                	srai	s0,s0,0x6
ffffffffc0202fac:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202fae:	042a                	slli	s0,s0,0xa
ffffffffc0202fb0:	8cc1                	or	s1,s1,s0
ffffffffc0202fb2:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202fb6:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_matrix_out_size+0xffffffffbfff38d8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202fba:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202fbe:	4501                	li	a0,0
}
ffffffffc0202fc0:	70e2                	ld	ra,56(sp)
ffffffffc0202fc2:	7442                	ld	s0,48(sp)
ffffffffc0202fc4:	74a2                	ld	s1,40(sp)
ffffffffc0202fc6:	7902                	ld	s2,32(sp)
ffffffffc0202fc8:	69e2                	ld	s3,24(sp)
ffffffffc0202fca:	6a42                	ld	s4,16(sp)
ffffffffc0202fcc:	6aa2                	ld	s5,8(sp)
ffffffffc0202fce:	6121                	addi	sp,sp,64
ffffffffc0202fd0:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202fd2:	078a                	slli	a5,a5,0x2
ffffffffc0202fd4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202fd6:	000c4717          	auipc	a4,0xc4
ffffffffc0202fda:	d7a73703          	ld	a4,-646(a4) # ffffffffc02c6d50 <npage>
ffffffffc0202fde:	06e7ff63          	bgeu	a5,a4,ffffffffc020305c <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fe2:	000c4a97          	auipc	s5,0xc4
ffffffffc0202fe6:	d76a8a93          	addi	s5,s5,-650 # ffffffffc02c6d58 <pages>
ffffffffc0202fea:	000ab703          	ld	a4,0(s5)
ffffffffc0202fee:	fff80937          	lui	s2,0xfff80
ffffffffc0202ff2:	993e                	add	s2,s2,a5
ffffffffc0202ff4:	091a                	slli	s2,s2,0x6
ffffffffc0202ff6:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc0202ff8:	01240c63          	beq	s0,s2,ffffffffc0203010 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202ffc:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fcb9260>
ffffffffc0203000:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203004:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0203008:	c691                	beqz	a3,ffffffffc0203014 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020300a:	120a0073          	sfence.vma	s4
}
ffffffffc020300e:	bf59                	j	ffffffffc0202fa4 <page_insert+0x3a>
ffffffffc0203010:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203012:	bf49                	j	ffffffffc0202fa4 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203014:	100027f3          	csrr	a5,sstatus
ffffffffc0203018:	8b89                	andi	a5,a5,2
ffffffffc020301a:	ef91                	bnez	a5,ffffffffc0203036 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc020301c:	000c4797          	auipc	a5,0xc4
ffffffffc0203020:	d447b783          	ld	a5,-700(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0203024:	739c                	ld	a5,32(a5)
ffffffffc0203026:	4585                	li	a1,1
ffffffffc0203028:	854a                	mv	a0,s2
ffffffffc020302a:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc020302c:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203030:	120a0073          	sfence.vma	s4
ffffffffc0203034:	bf85                	j	ffffffffc0202fa4 <page_insert+0x3a>
        intr_disable();
ffffffffc0203036:	97ffd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020303a:	000c4797          	auipc	a5,0xc4
ffffffffc020303e:	d267b783          	ld	a5,-730(a5) # ffffffffc02c6d60 <pmm_manager>
ffffffffc0203042:	739c                	ld	a5,32(a5)
ffffffffc0203044:	4585                	li	a1,1
ffffffffc0203046:	854a                	mv	a0,s2
ffffffffc0203048:	9782                	jalr	a5
        intr_enable();
ffffffffc020304a:	965fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020304e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203052:	120a0073          	sfence.vma	s4
ffffffffc0203056:	b7b9                	j	ffffffffc0202fa4 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0203058:	5571                	li	a0,-4
ffffffffc020305a:	b79d                	j	ffffffffc0202fc0 <page_insert+0x56>
ffffffffc020305c:	f2eff0ef          	jal	ra,ffffffffc020278a <pa2page.part.0>

ffffffffc0203060 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203060:	00004797          	auipc	a5,0x4
ffffffffc0203064:	b8878793          	addi	a5,a5,-1144 # ffffffffc0206be8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203068:	638c                	ld	a1,0(a5)
{
ffffffffc020306a:	7159                	addi	sp,sp,-112
ffffffffc020306c:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020306e:	00004517          	auipc	a0,0x4
ffffffffc0203072:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0206c78 <default_pmm_manager+0x90>
    pmm_manager = &default_pmm_manager;
ffffffffc0203076:	000c4b17          	auipc	s6,0xc4
ffffffffc020307a:	ceab0b13          	addi	s6,s6,-790 # ffffffffc02c6d60 <pmm_manager>
{
ffffffffc020307e:	f486                	sd	ra,104(sp)
ffffffffc0203080:	e8ca                	sd	s2,80(sp)
ffffffffc0203082:	e4ce                	sd	s3,72(sp)
ffffffffc0203084:	f0a2                	sd	s0,96(sp)
ffffffffc0203086:	eca6                	sd	s1,88(sp)
ffffffffc0203088:	e0d2                	sd	s4,64(sp)
ffffffffc020308a:	fc56                	sd	s5,56(sp)
ffffffffc020308c:	f45e                	sd	s7,40(sp)
ffffffffc020308e:	f062                	sd	s8,32(sp)
ffffffffc0203090:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0203092:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203096:	84efd0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    pmm_manager->init();
ffffffffc020309a:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020309e:	000c4997          	auipc	s3,0xc4
ffffffffc02030a2:	cca98993          	addi	s3,s3,-822 # ffffffffc02c6d68 <va_pa_offset>
    pmm_manager->init();
ffffffffc02030a6:	679c                	ld	a5,8(a5)
ffffffffc02030a8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02030aa:	57f5                	li	a5,-3
ffffffffc02030ac:	07fa                	slli	a5,a5,0x1e
ffffffffc02030ae:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02030b2:	82bfd0ef          	jal	ra,ffffffffc02008dc <get_memory_base>
ffffffffc02030b6:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02030b8:	82ffd0ef          	jal	ra,ffffffffc02008e6 <get_memory_size>
    if (mem_size == 0)
ffffffffc02030bc:	200505e3          	beqz	a0,ffffffffc0203ac6 <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02030c0:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02030c2:	00004517          	auipc	a0,0x4
ffffffffc02030c6:	bee50513          	addi	a0,a0,-1042 # ffffffffc0206cb0 <default_pmm_manager+0xc8>
ffffffffc02030ca:	81afd0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02030ce:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02030d2:	fff40693          	addi	a3,s0,-1
ffffffffc02030d6:	864a                	mv	a2,s2
ffffffffc02030d8:	85a6                	mv	a1,s1
ffffffffc02030da:	00004517          	auipc	a0,0x4
ffffffffc02030de:	bee50513          	addi	a0,a0,-1042 # ffffffffc0206cc8 <default_pmm_manager+0xe0>
ffffffffc02030e2:	802fd0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02030e6:	c8000737          	lui	a4,0xc8000
ffffffffc02030ea:	87a2                	mv	a5,s0
ffffffffc02030ec:	54876163          	bltu	a4,s0,ffffffffc020362e <pmm_init+0x5ce>
ffffffffc02030f0:	757d                	lui	a0,0xfffff
ffffffffc02030f2:	000c5617          	auipc	a2,0xc5
ffffffffc02030f6:	cad60613          	addi	a2,a2,-851 # ffffffffc02c7d9f <end+0xfff>
ffffffffc02030fa:	8e69                	and	a2,a2,a0
ffffffffc02030fc:	000c4497          	auipc	s1,0xc4
ffffffffc0203100:	c5448493          	addi	s1,s1,-940 # ffffffffc02c6d50 <npage>
ffffffffc0203104:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203108:	000c4b97          	auipc	s7,0xc4
ffffffffc020310c:	c50b8b93          	addi	s7,s7,-944 # ffffffffc02c6d58 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203110:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203112:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203116:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020311a:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020311c:	02f50863          	beq	a0,a5,ffffffffc020314c <pmm_init+0xec>
ffffffffc0203120:	4781                	li	a5,0
ffffffffc0203122:	4585                	li	a1,1
ffffffffc0203124:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0203128:	00679513          	slli	a0,a5,0x6
ffffffffc020312c:	9532                	add	a0,a0,a2
ffffffffc020312e:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd38268>
ffffffffc0203132:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203136:	6088                	ld	a0,0(s1)
ffffffffc0203138:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020313a:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020313e:	00d50733          	add	a4,a0,a3
ffffffffc0203142:	fee7e3e3          	bltu	a5,a4,ffffffffc0203128 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203146:	071a                	slli	a4,a4,0x6
ffffffffc0203148:	00e606b3          	add	a3,a2,a4
ffffffffc020314c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203150:	2ef6ece3          	bltu	a3,a5,ffffffffc0203c48 <pmm_init+0xbe8>
ffffffffc0203154:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0203158:	77fd                	lui	a5,0xfffff
ffffffffc020315a:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020315c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020315e:	5086eb63          	bltu	a3,s0,ffffffffc0203674 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0203162:	00004517          	auipc	a0,0x4
ffffffffc0203166:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0206cf0 <default_pmm_manager+0x108>
ffffffffc020316a:	f7bfc0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc020316e:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0203172:	000c4917          	auipc	s2,0xc4
ffffffffc0203176:	bd690913          	addi	s2,s2,-1066 # ffffffffc02c6d48 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020317a:	7b9c                	ld	a5,48(a5)
ffffffffc020317c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020317e:	00004517          	auipc	a0,0x4
ffffffffc0203182:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0206d08 <default_pmm_manager+0x120>
ffffffffc0203186:	f5ffc0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020318a:	00008697          	auipc	a3,0x8
ffffffffc020318e:	e7668693          	addi	a3,a3,-394 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0203192:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203196:	c02007b7          	lui	a5,0xc0200
ffffffffc020319a:	28f6ebe3          	bltu	a3,a5,ffffffffc0203c30 <pmm_init+0xbd0>
ffffffffc020319e:	0009b783          	ld	a5,0(s3)
ffffffffc02031a2:	8e9d                	sub	a3,a3,a5
ffffffffc02031a4:	000c4797          	auipc	a5,0xc4
ffffffffc02031a8:	b8d7be23          	sd	a3,-1124(a5) # ffffffffc02c6d40 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02031ac:	100027f3          	csrr	a5,sstatus
ffffffffc02031b0:	8b89                	andi	a5,a5,2
ffffffffc02031b2:	4a079763          	bnez	a5,ffffffffc0203660 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02031b6:	000b3783          	ld	a5,0(s6)
ffffffffc02031ba:	779c                	ld	a5,40(a5)
ffffffffc02031bc:	9782                	jalr	a5
ffffffffc02031be:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031c0:	6098                	ld	a4,0(s1)
ffffffffc02031c2:	c80007b7          	lui	a5,0xc8000
ffffffffc02031c6:	83b1                	srli	a5,a5,0xc
ffffffffc02031c8:	66e7e363          	bltu	a5,a4,ffffffffc020382e <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02031cc:	00093503          	ld	a0,0(s2)
ffffffffc02031d0:	62050f63          	beqz	a0,ffffffffc020380e <pmm_init+0x7ae>
ffffffffc02031d4:	03451793          	slli	a5,a0,0x34
ffffffffc02031d8:	62079b63          	bnez	a5,ffffffffc020380e <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02031dc:	4601                	li	a2,0
ffffffffc02031de:	4581                	li	a1,0
ffffffffc02031e0:	8c3ff0ef          	jal	ra,ffffffffc0202aa2 <get_page>
ffffffffc02031e4:	60051563          	bnez	a0,ffffffffc02037ee <pmm_init+0x78e>
ffffffffc02031e8:	100027f3          	csrr	a5,sstatus
ffffffffc02031ec:	8b89                	andi	a5,a5,2
ffffffffc02031ee:	44079e63          	bnez	a5,ffffffffc020364a <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02031f2:	000b3783          	ld	a5,0(s6)
ffffffffc02031f6:	4505                	li	a0,1
ffffffffc02031f8:	6f9c                	ld	a5,24(a5)
ffffffffc02031fa:	9782                	jalr	a5
ffffffffc02031fc:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02031fe:	00093503          	ld	a0,0(s2)
ffffffffc0203202:	4681                	li	a3,0
ffffffffc0203204:	4601                	li	a2,0
ffffffffc0203206:	85d2                	mv	a1,s4
ffffffffc0203208:	d63ff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc020320c:	26051ae3          	bnez	a0,ffffffffc0203c80 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203210:	00093503          	ld	a0,0(s2)
ffffffffc0203214:	4601                	li	a2,0
ffffffffc0203216:	4581                	li	a1,0
ffffffffc0203218:	e62ff0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc020321c:	240502e3          	beqz	a0,ffffffffc0203c60 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0203220:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0203222:	0017f713          	andi	a4,a5,1
ffffffffc0203226:	5a070263          	beqz	a4,ffffffffc02037ca <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020322a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020322c:	078a                	slli	a5,a5,0x2
ffffffffc020322e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203230:	58e7fb63          	bgeu	a5,a4,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203234:	000bb683          	ld	a3,0(s7)
ffffffffc0203238:	fff80637          	lui	a2,0xfff80
ffffffffc020323c:	97b2                	add	a5,a5,a2
ffffffffc020323e:	079a                	slli	a5,a5,0x6
ffffffffc0203240:	97b6                	add	a5,a5,a3
ffffffffc0203242:	14fa17e3          	bne	s4,a5,ffffffffc0203b90 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0203246:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f60>
ffffffffc020324a:	4785                	li	a5,1
ffffffffc020324c:	12f692e3          	bne	a3,a5,ffffffffc0203b70 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203250:	00093503          	ld	a0,0(s2)
ffffffffc0203254:	77fd                	lui	a5,0xfffff
ffffffffc0203256:	6114                	ld	a3,0(a0)
ffffffffc0203258:	068a                	slli	a3,a3,0x2
ffffffffc020325a:	8efd                	and	a3,a3,a5
ffffffffc020325c:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203260:	0ee67ce3          	bgeu	a2,a4,ffffffffc0203b58 <pmm_init+0xaf8>
ffffffffc0203264:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203268:	96e2                	add	a3,a3,s8
ffffffffc020326a:	0006ba83          	ld	s5,0(a3)
ffffffffc020326e:	0a8a                	slli	s5,s5,0x2
ffffffffc0203270:	00fafab3          	and	s5,s5,a5
ffffffffc0203274:	00cad793          	srli	a5,s5,0xc
ffffffffc0203278:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203b3e <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020327c:	4601                	li	a2,0
ffffffffc020327e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203280:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203282:	df8ff0ef          	jal	ra,ffffffffc020287a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203286:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203288:	55551363          	bne	a0,s5,ffffffffc02037ce <pmm_init+0x76e>
ffffffffc020328c:	100027f3          	csrr	a5,sstatus
ffffffffc0203290:	8b89                	andi	a5,a5,2
ffffffffc0203292:	3a079163          	bnez	a5,ffffffffc0203634 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203296:	000b3783          	ld	a5,0(s6)
ffffffffc020329a:	4505                	li	a0,1
ffffffffc020329c:	6f9c                	ld	a5,24(a5)
ffffffffc020329e:	9782                	jalr	a5
ffffffffc02032a0:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032a2:	00093503          	ld	a0,0(s2)
ffffffffc02032a6:	46d1                	li	a3,20
ffffffffc02032a8:	6605                	lui	a2,0x1
ffffffffc02032aa:	85e2                	mv	a1,s8
ffffffffc02032ac:	cbfff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc02032b0:	060517e3          	bnez	a0,ffffffffc0203b1e <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032b4:	00093503          	ld	a0,0(s2)
ffffffffc02032b8:	4601                	li	a2,0
ffffffffc02032ba:	6585                	lui	a1,0x1
ffffffffc02032bc:	dbeff0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc02032c0:	02050fe3          	beqz	a0,ffffffffc0203afe <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc02032c4:	611c                	ld	a5,0(a0)
ffffffffc02032c6:	0107f713          	andi	a4,a5,16
ffffffffc02032ca:	7c070e63          	beqz	a4,ffffffffc0203aa6 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc02032ce:	8b91                	andi	a5,a5,4
ffffffffc02032d0:	7a078b63          	beqz	a5,ffffffffc0203a86 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02032d4:	00093503          	ld	a0,0(s2)
ffffffffc02032d8:	611c                	ld	a5,0(a0)
ffffffffc02032da:	8bc1                	andi	a5,a5,16
ffffffffc02032dc:	78078563          	beqz	a5,ffffffffc0203a66 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02032e0:	000c2703          	lw	a4,0(s8)
ffffffffc02032e4:	4785                	li	a5,1
ffffffffc02032e6:	76f71063          	bne	a4,a5,ffffffffc0203a46 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02032ea:	4681                	li	a3,0
ffffffffc02032ec:	6605                	lui	a2,0x1
ffffffffc02032ee:	85d2                	mv	a1,s4
ffffffffc02032f0:	c7bff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc02032f4:	72051963          	bnez	a0,ffffffffc0203a26 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc02032f8:	000a2703          	lw	a4,0(s4)
ffffffffc02032fc:	4789                	li	a5,2
ffffffffc02032fe:	70f71463          	bne	a4,a5,ffffffffc0203a06 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0203302:	000c2783          	lw	a5,0(s8)
ffffffffc0203306:	6e079063          	bnez	a5,ffffffffc02039e6 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020330a:	00093503          	ld	a0,0(s2)
ffffffffc020330e:	4601                	li	a2,0
ffffffffc0203310:	6585                	lui	a1,0x1
ffffffffc0203312:	d68ff0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc0203316:	6a050863          	beqz	a0,ffffffffc02039c6 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc020331a:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc020331c:	00177793          	andi	a5,a4,1
ffffffffc0203320:	4a078563          	beqz	a5,ffffffffc02037ca <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0203324:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203326:	00271793          	slli	a5,a4,0x2
ffffffffc020332a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020332c:	48d7fd63          	bgeu	a5,a3,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203330:	000bb683          	ld	a3,0(s7)
ffffffffc0203334:	fff80ab7          	lui	s5,0xfff80
ffffffffc0203338:	97d6                	add	a5,a5,s5
ffffffffc020333a:	079a                	slli	a5,a5,0x6
ffffffffc020333c:	97b6                	add	a5,a5,a3
ffffffffc020333e:	66fa1463          	bne	s4,a5,ffffffffc02039a6 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203342:	8b41                	andi	a4,a4,16
ffffffffc0203344:	64071163          	bnez	a4,ffffffffc0203986 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0203348:	00093503          	ld	a0,0(s2)
ffffffffc020334c:	4581                	li	a1,0
ffffffffc020334e:	b81ff0ef          	jal	ra,ffffffffc0202ece <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203352:	000a2c83          	lw	s9,0(s4)
ffffffffc0203356:	4785                	li	a5,1
ffffffffc0203358:	60fc9763          	bne	s9,a5,ffffffffc0203966 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc020335c:	000c2783          	lw	a5,0(s8)
ffffffffc0203360:	5e079363          	bnez	a5,ffffffffc0203946 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0203364:	00093503          	ld	a0,0(s2)
ffffffffc0203368:	6585                	lui	a1,0x1
ffffffffc020336a:	b65ff0ef          	jal	ra,ffffffffc0202ece <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020336e:	000a2783          	lw	a5,0(s4)
ffffffffc0203372:	52079a63          	bnez	a5,ffffffffc02038a6 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0203376:	000c2783          	lw	a5,0(s8)
ffffffffc020337a:	50079663          	bnez	a5,ffffffffc0203886 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020337e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0203382:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203384:	000a3683          	ld	a3,0(s4)
ffffffffc0203388:	068a                	slli	a3,a3,0x2
ffffffffc020338a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020338c:	42b6fd63          	bgeu	a3,a1,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203390:	000bb503          	ld	a0,0(s7)
ffffffffc0203394:	96d6                	add	a3,a3,s5
ffffffffc0203396:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0203398:	00d507b3          	add	a5,a0,a3
ffffffffc020339c:	439c                	lw	a5,0(a5)
ffffffffc020339e:	4d979463          	bne	a5,s9,ffffffffc0203866 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc02033a2:	8699                	srai	a3,a3,0x6
ffffffffc02033a4:	00080637          	lui	a2,0x80
ffffffffc02033a8:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02033aa:	00c69713          	slli	a4,a3,0xc
ffffffffc02033ae:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02033b0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02033b2:	48b77e63          	bgeu	a4,a1,ffffffffc020384e <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02033b6:	0009b703          	ld	a4,0(s3)
ffffffffc02033ba:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02033bc:	629c                	ld	a5,0(a3)
ffffffffc02033be:	078a                	slli	a5,a5,0x2
ffffffffc02033c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033c2:	40b7f263          	bgeu	a5,a1,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02033c6:	8f91                	sub	a5,a5,a2
ffffffffc02033c8:	079a                	slli	a5,a5,0x6
ffffffffc02033ca:	953e                	add	a0,a0,a5
ffffffffc02033cc:	100027f3          	csrr	a5,sstatus
ffffffffc02033d0:	8b89                	andi	a5,a5,2
ffffffffc02033d2:	30079963          	bnez	a5,ffffffffc02036e4 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc02033d6:	000b3783          	ld	a5,0(s6)
ffffffffc02033da:	4585                	li	a1,1
ffffffffc02033dc:	739c                	ld	a5,32(a5)
ffffffffc02033de:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02033e0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02033e4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033e6:	078a                	slli	a5,a5,0x2
ffffffffc02033e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033ea:	3ce7fe63          	bgeu	a5,a4,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02033ee:	000bb503          	ld	a0,0(s7)
ffffffffc02033f2:	fff80737          	lui	a4,0xfff80
ffffffffc02033f6:	97ba                	add	a5,a5,a4
ffffffffc02033f8:	079a                	slli	a5,a5,0x6
ffffffffc02033fa:	953e                	add	a0,a0,a5
ffffffffc02033fc:	100027f3          	csrr	a5,sstatus
ffffffffc0203400:	8b89                	andi	a5,a5,2
ffffffffc0203402:	2c079563          	bnez	a5,ffffffffc02036cc <pmm_init+0x66c>
ffffffffc0203406:	000b3783          	ld	a5,0(s6)
ffffffffc020340a:	4585                	li	a1,1
ffffffffc020340c:	739c                	ld	a5,32(a5)
ffffffffc020340e:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0203410:	00093783          	ld	a5,0(s2)
ffffffffc0203414:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd38260>
    asm volatile("sfence.vma");
ffffffffc0203418:	12000073          	sfence.vma
ffffffffc020341c:	100027f3          	csrr	a5,sstatus
ffffffffc0203420:	8b89                	andi	a5,a5,2
ffffffffc0203422:	28079b63          	bnez	a5,ffffffffc02036b8 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203426:	000b3783          	ld	a5,0(s6)
ffffffffc020342a:	779c                	ld	a5,40(a5)
ffffffffc020342c:	9782                	jalr	a5
ffffffffc020342e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203430:	4b441b63          	bne	s0,s4,ffffffffc02038e6 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203434:	00004517          	auipc	a0,0x4
ffffffffc0203438:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0207030 <default_pmm_manager+0x448>
ffffffffc020343c:	ca9fc0ef          	jal	ra,ffffffffc02000e4 <cprintf>
ffffffffc0203440:	100027f3          	csrr	a5,sstatus
ffffffffc0203444:	8b89                	andi	a5,a5,2
ffffffffc0203446:	24079f63          	bnez	a5,ffffffffc02036a4 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc020344a:	000b3783          	ld	a5,0(s6)
ffffffffc020344e:	779c                	ld	a5,40(a5)
ffffffffc0203450:	9782                	jalr	a5
ffffffffc0203452:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0203454:	6098                	ld	a4,0(s1)
ffffffffc0203456:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020345a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020345c:	00c71793          	slli	a5,a4,0xc
ffffffffc0203460:	6a05                	lui	s4,0x1
ffffffffc0203462:	02f47c63          	bgeu	s0,a5,ffffffffc020349a <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203466:	00c45793          	srli	a5,s0,0xc
ffffffffc020346a:	00093503          	ld	a0,0(s2)
ffffffffc020346e:	2ee7ff63          	bgeu	a5,a4,ffffffffc020376c <pmm_init+0x70c>
ffffffffc0203472:	0009b583          	ld	a1,0(s3)
ffffffffc0203476:	4601                	li	a2,0
ffffffffc0203478:	95a2                	add	a1,a1,s0
ffffffffc020347a:	c00ff0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc020347e:	32050463          	beqz	a0,ffffffffc02037a6 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203482:	611c                	ld	a5,0(a0)
ffffffffc0203484:	078a                	slli	a5,a5,0x2
ffffffffc0203486:	0157f7b3          	and	a5,a5,s5
ffffffffc020348a:	2e879e63          	bne	a5,s0,ffffffffc0203786 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020348e:	6098                	ld	a4,0(s1)
ffffffffc0203490:	9452                	add	s0,s0,s4
ffffffffc0203492:	00c71793          	slli	a5,a4,0xc
ffffffffc0203496:	fcf468e3          	bltu	s0,a5,ffffffffc0203466 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc020349a:	00093783          	ld	a5,0(s2)
ffffffffc020349e:	639c                	ld	a5,0(a5)
ffffffffc02034a0:	42079363          	bnez	a5,ffffffffc02038c6 <pmm_init+0x866>
ffffffffc02034a4:	100027f3          	csrr	a5,sstatus
ffffffffc02034a8:	8b89                	andi	a5,a5,2
ffffffffc02034aa:	24079963          	bnez	a5,ffffffffc02036fc <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034ae:	000b3783          	ld	a5,0(s6)
ffffffffc02034b2:	4505                	li	a0,1
ffffffffc02034b4:	6f9c                	ld	a5,24(a5)
ffffffffc02034b6:	9782                	jalr	a5
ffffffffc02034b8:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02034ba:	00093503          	ld	a0,0(s2)
ffffffffc02034be:	4699                	li	a3,6
ffffffffc02034c0:	10000613          	li	a2,256
ffffffffc02034c4:	85d2                	mv	a1,s4
ffffffffc02034c6:	aa5ff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc02034ca:	44051e63          	bnez	a0,ffffffffc0203926 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc02034ce:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f60>
ffffffffc02034d2:	4785                	li	a5,1
ffffffffc02034d4:	42f71963          	bne	a4,a5,ffffffffc0203906 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034d8:	00093503          	ld	a0,0(s2)
ffffffffc02034dc:	6405                	lui	s0,0x1
ffffffffc02034de:	4699                	li	a3,6
ffffffffc02034e0:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8e60>
ffffffffc02034e4:	85d2                	mv	a1,s4
ffffffffc02034e6:	a85ff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc02034ea:	72051363          	bnez	a0,ffffffffc0203c10 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc02034ee:	000a2703          	lw	a4,0(s4)
ffffffffc02034f2:	4789                	li	a5,2
ffffffffc02034f4:	6ef71e63          	bne	a4,a5,ffffffffc0203bf0 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02034f8:	00004597          	auipc	a1,0x4
ffffffffc02034fc:	c8058593          	addi	a1,a1,-896 # ffffffffc0207178 <default_pmm_manager+0x590>
ffffffffc0203500:	10000513          	li	a0,256
ffffffffc0203504:	048020ef          	jal	ra,ffffffffc020554c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203508:	10040593          	addi	a1,s0,256
ffffffffc020350c:	10000513          	li	a0,256
ffffffffc0203510:	04e020ef          	jal	ra,ffffffffc020555e <strcmp>
ffffffffc0203514:	6a051e63          	bnez	a0,ffffffffc0203bd0 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0203518:	000bb683          	ld	a3,0(s7)
ffffffffc020351c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0203520:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0203522:	40da06b3          	sub	a3,s4,a3
ffffffffc0203526:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203528:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020352a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020352c:	8031                	srli	s0,s0,0xc
ffffffffc020352e:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203532:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203534:	30f77d63          	bgeu	a4,a5,ffffffffc020384e <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203538:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020353c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203540:	96be                	add	a3,a3,a5
ffffffffc0203542:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203546:	7d1010ef          	jal	ra,ffffffffc0205516 <strlen>
ffffffffc020354a:	66051363          	bnez	a0,ffffffffc0203bb0 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc020354e:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0203552:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203554:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd38260>
ffffffffc0203558:	068a                	slli	a3,a3,0x2
ffffffffc020355a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020355c:	26f6f563          	bgeu	a3,a5,ffffffffc02037c6 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0203560:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203562:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203564:	2ef47563          	bgeu	s0,a5,ffffffffc020384e <pmm_init+0x7ee>
ffffffffc0203568:	0009b403          	ld	s0,0(s3)
ffffffffc020356c:	9436                	add	s0,s0,a3
ffffffffc020356e:	100027f3          	csrr	a5,sstatus
ffffffffc0203572:	8b89                	andi	a5,a5,2
ffffffffc0203574:	1e079163          	bnez	a5,ffffffffc0203756 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0203578:	000b3783          	ld	a5,0(s6)
ffffffffc020357c:	4585                	li	a1,1
ffffffffc020357e:	8552                	mv	a0,s4
ffffffffc0203580:	739c                	ld	a5,32(a5)
ffffffffc0203582:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203584:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0203586:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203588:	078a                	slli	a5,a5,0x2
ffffffffc020358a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020358c:	22e7fd63          	bgeu	a5,a4,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203590:	000bb503          	ld	a0,0(s7)
ffffffffc0203594:	fff80737          	lui	a4,0xfff80
ffffffffc0203598:	97ba                	add	a5,a5,a4
ffffffffc020359a:	079a                	slli	a5,a5,0x6
ffffffffc020359c:	953e                	add	a0,a0,a5
ffffffffc020359e:	100027f3          	csrr	a5,sstatus
ffffffffc02035a2:	8b89                	andi	a5,a5,2
ffffffffc02035a4:	18079d63          	bnez	a5,ffffffffc020373e <pmm_init+0x6de>
ffffffffc02035a8:	000b3783          	ld	a5,0(s6)
ffffffffc02035ac:	4585                	li	a1,1
ffffffffc02035ae:	739c                	ld	a5,32(a5)
ffffffffc02035b0:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b2:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc02035b6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b8:	078a                	slli	a5,a5,0x2
ffffffffc02035ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035bc:	20e7f563          	bgeu	a5,a4,ffffffffc02037c6 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02035c0:	000bb503          	ld	a0,0(s7)
ffffffffc02035c4:	fff80737          	lui	a4,0xfff80
ffffffffc02035c8:	97ba                	add	a5,a5,a4
ffffffffc02035ca:	079a                	slli	a5,a5,0x6
ffffffffc02035cc:	953e                	add	a0,a0,a5
ffffffffc02035ce:	100027f3          	csrr	a5,sstatus
ffffffffc02035d2:	8b89                	andi	a5,a5,2
ffffffffc02035d4:	14079963          	bnez	a5,ffffffffc0203726 <pmm_init+0x6c6>
ffffffffc02035d8:	000b3783          	ld	a5,0(s6)
ffffffffc02035dc:	4585                	li	a1,1
ffffffffc02035de:	739c                	ld	a5,32(a5)
ffffffffc02035e0:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02035e2:	00093783          	ld	a5,0(s2)
ffffffffc02035e6:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc02035ea:	12000073          	sfence.vma
ffffffffc02035ee:	100027f3          	csrr	a5,sstatus
ffffffffc02035f2:	8b89                	andi	a5,a5,2
ffffffffc02035f4:	10079f63          	bnez	a5,ffffffffc0203712 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc02035f8:	000b3783          	ld	a5,0(s6)
ffffffffc02035fc:	779c                	ld	a5,40(a5)
ffffffffc02035fe:	9782                	jalr	a5
ffffffffc0203600:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203602:	4c8c1e63          	bne	s8,s0,ffffffffc0203ade <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203606:	00004517          	auipc	a0,0x4
ffffffffc020360a:	bea50513          	addi	a0,a0,-1046 # ffffffffc02071f0 <default_pmm_manager+0x608>
ffffffffc020360e:	ad7fc0ef          	jal	ra,ffffffffc02000e4 <cprintf>
}
ffffffffc0203612:	7406                	ld	s0,96(sp)
ffffffffc0203614:	70a6                	ld	ra,104(sp)
ffffffffc0203616:	64e6                	ld	s1,88(sp)
ffffffffc0203618:	6946                	ld	s2,80(sp)
ffffffffc020361a:	69a6                	ld	s3,72(sp)
ffffffffc020361c:	6a06                	ld	s4,64(sp)
ffffffffc020361e:	7ae2                	ld	s5,56(sp)
ffffffffc0203620:	7b42                	ld	s6,48(sp)
ffffffffc0203622:	7ba2                	ld	s7,40(sp)
ffffffffc0203624:	7c02                	ld	s8,32(sp)
ffffffffc0203626:	6ce2                	ld	s9,24(sp)
ffffffffc0203628:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc020362a:	ce8fe06f          	j	ffffffffc0201b12 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc020362e:	c80007b7          	lui	a5,0xc8000
ffffffffc0203632:	bc7d                	j	ffffffffc02030f0 <pmm_init+0x90>
        intr_disable();
ffffffffc0203634:	b80fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203638:	000b3783          	ld	a5,0(s6)
ffffffffc020363c:	4505                	li	a0,1
ffffffffc020363e:	6f9c                	ld	a5,24(a5)
ffffffffc0203640:	9782                	jalr	a5
ffffffffc0203642:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203644:	b6afd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203648:	b9a9                	j	ffffffffc02032a2 <pmm_init+0x242>
        intr_disable();
ffffffffc020364a:	b6afd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020364e:	000b3783          	ld	a5,0(s6)
ffffffffc0203652:	4505                	li	a0,1
ffffffffc0203654:	6f9c                	ld	a5,24(a5)
ffffffffc0203656:	9782                	jalr	a5
ffffffffc0203658:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020365a:	b54fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020365e:	b645                	j	ffffffffc02031fe <pmm_init+0x19e>
        intr_disable();
ffffffffc0203660:	b54fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203664:	000b3783          	ld	a5,0(s6)
ffffffffc0203668:	779c                	ld	a5,40(a5)
ffffffffc020366a:	9782                	jalr	a5
ffffffffc020366c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020366e:	b40fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203672:	b6b9                	j	ffffffffc02031c0 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203674:	6705                	lui	a4,0x1
ffffffffc0203676:	177d                	addi	a4,a4,-1
ffffffffc0203678:	96ba                	add	a3,a3,a4
ffffffffc020367a:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc020367c:	00c7d713          	srli	a4,a5,0xc
ffffffffc0203680:	14a77363          	bgeu	a4,a0,ffffffffc02037c6 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0203684:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0203688:	fff80537          	lui	a0,0xfff80
ffffffffc020368c:	972a                	add	a4,a4,a0
ffffffffc020368e:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203690:	8c1d                	sub	s0,s0,a5
ffffffffc0203692:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0203696:	00c45593          	srli	a1,s0,0xc
ffffffffc020369a:	9532                	add	a0,a0,a2
ffffffffc020369c:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020369e:	0009b583          	ld	a1,0(s3)
}
ffffffffc02036a2:	b4c1                	j	ffffffffc0203162 <pmm_init+0x102>
        intr_disable();
ffffffffc02036a4:	b10fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02036a8:	000b3783          	ld	a5,0(s6)
ffffffffc02036ac:	779c                	ld	a5,40(a5)
ffffffffc02036ae:	9782                	jalr	a5
ffffffffc02036b0:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02036b2:	afcfd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02036b6:	bb79                	j	ffffffffc0203454 <pmm_init+0x3f4>
        intr_disable();
ffffffffc02036b8:	afcfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02036bc:	000b3783          	ld	a5,0(s6)
ffffffffc02036c0:	779c                	ld	a5,40(a5)
ffffffffc02036c2:	9782                	jalr	a5
ffffffffc02036c4:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02036c6:	ae8fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02036ca:	b39d                	j	ffffffffc0203430 <pmm_init+0x3d0>
ffffffffc02036cc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036ce:	ae6fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02036d2:	000b3783          	ld	a5,0(s6)
ffffffffc02036d6:	6522                	ld	a0,8(sp)
ffffffffc02036d8:	4585                	li	a1,1
ffffffffc02036da:	739c                	ld	a5,32(a5)
ffffffffc02036dc:	9782                	jalr	a5
        intr_enable();
ffffffffc02036de:	ad0fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02036e2:	b33d                	j	ffffffffc0203410 <pmm_init+0x3b0>
ffffffffc02036e4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036e6:	acefd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc02036ea:	000b3783          	ld	a5,0(s6)
ffffffffc02036ee:	6522                	ld	a0,8(sp)
ffffffffc02036f0:	4585                	li	a1,1
ffffffffc02036f2:	739c                	ld	a5,32(a5)
ffffffffc02036f4:	9782                	jalr	a5
        intr_enable();
ffffffffc02036f6:	ab8fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02036fa:	b1dd                	j	ffffffffc02033e0 <pmm_init+0x380>
        intr_disable();
ffffffffc02036fc:	ab8fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203700:	000b3783          	ld	a5,0(s6)
ffffffffc0203704:	4505                	li	a0,1
ffffffffc0203706:	6f9c                	ld	a5,24(a5)
ffffffffc0203708:	9782                	jalr	a5
ffffffffc020370a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020370c:	aa2fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203710:	b36d                	j	ffffffffc02034ba <pmm_init+0x45a>
        intr_disable();
ffffffffc0203712:	aa2fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203716:	000b3783          	ld	a5,0(s6)
ffffffffc020371a:	779c                	ld	a5,40(a5)
ffffffffc020371c:	9782                	jalr	a5
ffffffffc020371e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203720:	a8efd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203724:	bdf9                	j	ffffffffc0203602 <pmm_init+0x5a2>
ffffffffc0203726:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203728:	a8cfd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020372c:	000b3783          	ld	a5,0(s6)
ffffffffc0203730:	6522                	ld	a0,8(sp)
ffffffffc0203732:	4585                	li	a1,1
ffffffffc0203734:	739c                	ld	a5,32(a5)
ffffffffc0203736:	9782                	jalr	a5
        intr_enable();
ffffffffc0203738:	a76fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020373c:	b55d                	j	ffffffffc02035e2 <pmm_init+0x582>
ffffffffc020373e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203740:	a74fd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0203744:	000b3783          	ld	a5,0(s6)
ffffffffc0203748:	6522                	ld	a0,8(sp)
ffffffffc020374a:	4585                	li	a1,1
ffffffffc020374c:	739c                	ld	a5,32(a5)
ffffffffc020374e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203750:	a5efd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203754:	bdb9                	j	ffffffffc02035b2 <pmm_init+0x552>
        intr_disable();
ffffffffc0203756:	a5efd0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc020375a:	000b3783          	ld	a5,0(s6)
ffffffffc020375e:	4585                	li	a1,1
ffffffffc0203760:	8552                	mv	a0,s4
ffffffffc0203762:	739c                	ld	a5,32(a5)
ffffffffc0203764:	9782                	jalr	a5
        intr_enable();
ffffffffc0203766:	a48fd0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020376a:	bd29                	j	ffffffffc0203584 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020376c:	86a2                	mv	a3,s0
ffffffffc020376e:	00003617          	auipc	a2,0x3
ffffffffc0203772:	d0a60613          	addi	a2,a2,-758 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0203776:	23e00593          	li	a1,574
ffffffffc020377a:	00003517          	auipc	a0,0x3
ffffffffc020377e:	4a650513          	addi	a0,a0,1190 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203782:	aa1fc0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203786:	00004697          	auipc	a3,0x4
ffffffffc020378a:	90a68693          	addi	a3,a3,-1782 # ffffffffc0207090 <default_pmm_manager+0x4a8>
ffffffffc020378e:	00003617          	auipc	a2,0x3
ffffffffc0203792:	da260613          	addi	a2,a2,-606 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203796:	23f00593          	li	a1,575
ffffffffc020379a:	00003517          	auipc	a0,0x3
ffffffffc020379e:	48650513          	addi	a0,a0,1158 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02037a2:	a81fc0ef          	jal	ra,ffffffffc0200222 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02037a6:	00004697          	auipc	a3,0x4
ffffffffc02037aa:	8aa68693          	addi	a3,a3,-1878 # ffffffffc0207050 <default_pmm_manager+0x468>
ffffffffc02037ae:	00003617          	auipc	a2,0x3
ffffffffc02037b2:	d8260613          	addi	a2,a2,-638 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02037b6:	23e00593          	li	a1,574
ffffffffc02037ba:	00003517          	auipc	a0,0x3
ffffffffc02037be:	46650513          	addi	a0,a0,1126 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02037c2:	a61fc0ef          	jal	ra,ffffffffc0200222 <__panic>
ffffffffc02037c6:	fc5fe0ef          	jal	ra,ffffffffc020278a <pa2page.part.0>
ffffffffc02037ca:	fddfe0ef          	jal	ra,ffffffffc02027a6 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02037ce:	00003697          	auipc	a3,0x3
ffffffffc02037d2:	67a68693          	addi	a3,a3,1658 # ffffffffc0206e48 <default_pmm_manager+0x260>
ffffffffc02037d6:	00003617          	auipc	a2,0x3
ffffffffc02037da:	d5a60613          	addi	a2,a2,-678 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02037de:	20e00593          	li	a1,526
ffffffffc02037e2:	00003517          	auipc	a0,0x3
ffffffffc02037e6:	43e50513          	addi	a0,a0,1086 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02037ea:	a39fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02037ee:	00003697          	auipc	a3,0x3
ffffffffc02037f2:	59a68693          	addi	a3,a3,1434 # ffffffffc0206d88 <default_pmm_manager+0x1a0>
ffffffffc02037f6:	00003617          	auipc	a2,0x3
ffffffffc02037fa:	d3a60613          	addi	a2,a2,-710 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02037fe:	20100593          	li	a1,513
ffffffffc0203802:	00003517          	auipc	a0,0x3
ffffffffc0203806:	41e50513          	addi	a0,a0,1054 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc020380a:	a19fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020380e:	00003697          	auipc	a3,0x3
ffffffffc0203812:	53a68693          	addi	a3,a3,1338 # ffffffffc0206d48 <default_pmm_manager+0x160>
ffffffffc0203816:	00003617          	auipc	a2,0x3
ffffffffc020381a:	d1a60613          	addi	a2,a2,-742 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020381e:	20000593          	li	a1,512
ffffffffc0203822:	00003517          	auipc	a0,0x3
ffffffffc0203826:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc020382a:	9f9fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020382e:	00003697          	auipc	a3,0x3
ffffffffc0203832:	4fa68693          	addi	a3,a3,1274 # ffffffffc0206d28 <default_pmm_manager+0x140>
ffffffffc0203836:	00003617          	auipc	a2,0x3
ffffffffc020383a:	cfa60613          	addi	a2,a2,-774 # ffffffffc0206530 <commands+0x8a0>
ffffffffc020383e:	1ff00593          	li	a1,511
ffffffffc0203842:	00003517          	auipc	a0,0x3
ffffffffc0203846:	3de50513          	addi	a0,a0,990 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc020384a:	9d9fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    return KADDR(page2pa(page));
ffffffffc020384e:	00003617          	auipc	a2,0x3
ffffffffc0203852:	c2a60613          	addi	a2,a2,-982 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0203856:	07100593          	li	a1,113
ffffffffc020385a:	00003517          	auipc	a0,0x3
ffffffffc020385e:	bde50513          	addi	a0,a0,-1058 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0203862:	9c1fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203866:	00003697          	auipc	a3,0x3
ffffffffc020386a:	77268693          	addi	a3,a3,1906 # ffffffffc0206fd8 <default_pmm_manager+0x3f0>
ffffffffc020386e:	00003617          	auipc	a2,0x3
ffffffffc0203872:	cc260613          	addi	a2,a2,-830 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203876:	22700593          	li	a1,551
ffffffffc020387a:	00003517          	auipc	a0,0x3
ffffffffc020387e:	3a650513          	addi	a0,a0,934 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203882:	9a1fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203886:	00003697          	auipc	a3,0x3
ffffffffc020388a:	70a68693          	addi	a3,a3,1802 # ffffffffc0206f90 <default_pmm_manager+0x3a8>
ffffffffc020388e:	00003617          	auipc	a2,0x3
ffffffffc0203892:	ca260613          	addi	a2,a2,-862 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203896:	22500593          	li	a1,549
ffffffffc020389a:	00003517          	auipc	a0,0x3
ffffffffc020389e:	38650513          	addi	a0,a0,902 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02038a2:	981fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02038a6:	00003697          	auipc	a3,0x3
ffffffffc02038aa:	71a68693          	addi	a3,a3,1818 # ffffffffc0206fc0 <default_pmm_manager+0x3d8>
ffffffffc02038ae:	00003617          	auipc	a2,0x3
ffffffffc02038b2:	c8260613          	addi	a2,a2,-894 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02038b6:	22400593          	li	a1,548
ffffffffc02038ba:	00003517          	auipc	a0,0x3
ffffffffc02038be:	36650513          	addi	a0,a0,870 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02038c2:	961fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02038c6:	00003697          	auipc	a3,0x3
ffffffffc02038ca:	7e268693          	addi	a3,a3,2018 # ffffffffc02070a8 <default_pmm_manager+0x4c0>
ffffffffc02038ce:	00003617          	auipc	a2,0x3
ffffffffc02038d2:	c6260613          	addi	a2,a2,-926 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02038d6:	24200593          	li	a1,578
ffffffffc02038da:	00003517          	auipc	a0,0x3
ffffffffc02038de:	34650513          	addi	a0,a0,838 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02038e2:	941fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02038e6:	00003697          	auipc	a3,0x3
ffffffffc02038ea:	72268693          	addi	a3,a3,1826 # ffffffffc0207008 <default_pmm_manager+0x420>
ffffffffc02038ee:	00003617          	auipc	a2,0x3
ffffffffc02038f2:	c4260613          	addi	a2,a2,-958 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02038f6:	22f00593          	li	a1,559
ffffffffc02038fa:	00003517          	auipc	a0,0x3
ffffffffc02038fe:	32650513          	addi	a0,a0,806 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203902:	921fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203906:	00003697          	auipc	a3,0x3
ffffffffc020390a:	7fa68693          	addi	a3,a3,2042 # ffffffffc0207100 <default_pmm_manager+0x518>
ffffffffc020390e:	00003617          	auipc	a2,0x3
ffffffffc0203912:	c2260613          	addi	a2,a2,-990 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203916:	24700593          	li	a1,583
ffffffffc020391a:	00003517          	auipc	a0,0x3
ffffffffc020391e:	30650513          	addi	a0,a0,774 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203922:	901fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203926:	00003697          	auipc	a3,0x3
ffffffffc020392a:	79a68693          	addi	a3,a3,1946 # ffffffffc02070c0 <default_pmm_manager+0x4d8>
ffffffffc020392e:	00003617          	auipc	a2,0x3
ffffffffc0203932:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203936:	24600593          	li	a1,582
ffffffffc020393a:	00003517          	auipc	a0,0x3
ffffffffc020393e:	2e650513          	addi	a0,a0,742 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203942:	8e1fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203946:	00003697          	auipc	a3,0x3
ffffffffc020394a:	64a68693          	addi	a3,a3,1610 # ffffffffc0206f90 <default_pmm_manager+0x3a8>
ffffffffc020394e:	00003617          	auipc	a2,0x3
ffffffffc0203952:	be260613          	addi	a2,a2,-1054 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203956:	22100593          	li	a1,545
ffffffffc020395a:	00003517          	auipc	a0,0x3
ffffffffc020395e:	2c650513          	addi	a0,a0,710 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203962:	8c1fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203966:	00003697          	auipc	a3,0x3
ffffffffc020396a:	4ca68693          	addi	a3,a3,1226 # ffffffffc0206e30 <default_pmm_manager+0x248>
ffffffffc020396e:	00003617          	auipc	a2,0x3
ffffffffc0203972:	bc260613          	addi	a2,a2,-1086 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203976:	22000593          	li	a1,544
ffffffffc020397a:	00003517          	auipc	a0,0x3
ffffffffc020397e:	2a650513          	addi	a0,a0,678 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203982:	8a1fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203986:	00003697          	auipc	a3,0x3
ffffffffc020398a:	62268693          	addi	a3,a3,1570 # ffffffffc0206fa8 <default_pmm_manager+0x3c0>
ffffffffc020398e:	00003617          	auipc	a2,0x3
ffffffffc0203992:	ba260613          	addi	a2,a2,-1118 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203996:	21d00593          	li	a1,541
ffffffffc020399a:	00003517          	auipc	a0,0x3
ffffffffc020399e:	28650513          	addi	a0,a0,646 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02039a2:	881fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02039a6:	00003697          	auipc	a3,0x3
ffffffffc02039aa:	47268693          	addi	a3,a3,1138 # ffffffffc0206e18 <default_pmm_manager+0x230>
ffffffffc02039ae:	00003617          	auipc	a2,0x3
ffffffffc02039b2:	b8260613          	addi	a2,a2,-1150 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02039b6:	21c00593          	li	a1,540
ffffffffc02039ba:	00003517          	auipc	a0,0x3
ffffffffc02039be:	26650513          	addi	a0,a0,614 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02039c2:	861fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02039c6:	00003697          	auipc	a3,0x3
ffffffffc02039ca:	4f268693          	addi	a3,a3,1266 # ffffffffc0206eb8 <default_pmm_manager+0x2d0>
ffffffffc02039ce:	00003617          	auipc	a2,0x3
ffffffffc02039d2:	b6260613          	addi	a2,a2,-1182 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02039d6:	21b00593          	li	a1,539
ffffffffc02039da:	00003517          	auipc	a0,0x3
ffffffffc02039de:	24650513          	addi	a0,a0,582 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc02039e2:	841fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02039e6:	00003697          	auipc	a3,0x3
ffffffffc02039ea:	5aa68693          	addi	a3,a3,1450 # ffffffffc0206f90 <default_pmm_manager+0x3a8>
ffffffffc02039ee:	00003617          	auipc	a2,0x3
ffffffffc02039f2:	b4260613          	addi	a2,a2,-1214 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02039f6:	21a00593          	li	a1,538
ffffffffc02039fa:	00003517          	auipc	a0,0x3
ffffffffc02039fe:	22650513          	addi	a0,a0,550 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203a02:	821fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203a06:	00003697          	auipc	a3,0x3
ffffffffc0203a0a:	57268693          	addi	a3,a3,1394 # ffffffffc0206f78 <default_pmm_manager+0x390>
ffffffffc0203a0e:	00003617          	auipc	a2,0x3
ffffffffc0203a12:	b2260613          	addi	a2,a2,-1246 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203a16:	21900593          	li	a1,537
ffffffffc0203a1a:	00003517          	auipc	a0,0x3
ffffffffc0203a1e:	20650513          	addi	a0,a0,518 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203a22:	801fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203a26:	00003697          	auipc	a3,0x3
ffffffffc0203a2a:	52268693          	addi	a3,a3,1314 # ffffffffc0206f48 <default_pmm_manager+0x360>
ffffffffc0203a2e:	00003617          	auipc	a2,0x3
ffffffffc0203a32:	b0260613          	addi	a2,a2,-1278 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203a36:	21800593          	li	a1,536
ffffffffc0203a3a:	00003517          	auipc	a0,0x3
ffffffffc0203a3e:	1e650513          	addi	a0,a0,486 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203a42:	fe0fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203a46:	00003697          	auipc	a3,0x3
ffffffffc0203a4a:	4ea68693          	addi	a3,a3,1258 # ffffffffc0206f30 <default_pmm_manager+0x348>
ffffffffc0203a4e:	00003617          	auipc	a2,0x3
ffffffffc0203a52:	ae260613          	addi	a2,a2,-1310 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203a56:	21600593          	li	a1,534
ffffffffc0203a5a:	00003517          	auipc	a0,0x3
ffffffffc0203a5e:	1c650513          	addi	a0,a0,454 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203a62:	fc0fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203a66:	00003697          	auipc	a3,0x3
ffffffffc0203a6a:	4aa68693          	addi	a3,a3,1194 # ffffffffc0206f10 <default_pmm_manager+0x328>
ffffffffc0203a6e:	00003617          	auipc	a2,0x3
ffffffffc0203a72:	ac260613          	addi	a2,a2,-1342 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203a76:	21500593          	li	a1,533
ffffffffc0203a7a:	00003517          	auipc	a0,0x3
ffffffffc0203a7e:	1a650513          	addi	a0,a0,422 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203a82:	fa0fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203a86:	00003697          	auipc	a3,0x3
ffffffffc0203a8a:	47a68693          	addi	a3,a3,1146 # ffffffffc0206f00 <default_pmm_manager+0x318>
ffffffffc0203a8e:	00003617          	auipc	a2,0x3
ffffffffc0203a92:	aa260613          	addi	a2,a2,-1374 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203a96:	21400593          	li	a1,532
ffffffffc0203a9a:	00003517          	auipc	a0,0x3
ffffffffc0203a9e:	18650513          	addi	a0,a0,390 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203aa2:	f80fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203aa6:	00003697          	auipc	a3,0x3
ffffffffc0203aaa:	44a68693          	addi	a3,a3,1098 # ffffffffc0206ef0 <default_pmm_manager+0x308>
ffffffffc0203aae:	00003617          	auipc	a2,0x3
ffffffffc0203ab2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203ab6:	21300593          	li	a1,531
ffffffffc0203aba:	00003517          	auipc	a0,0x3
ffffffffc0203abe:	16650513          	addi	a0,a0,358 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203ac2:	f60fc0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("DTB memory info not available");
ffffffffc0203ac6:	00003617          	auipc	a2,0x3
ffffffffc0203aca:	1ca60613          	addi	a2,a2,458 # ffffffffc0206c90 <default_pmm_manager+0xa8>
ffffffffc0203ace:	06500593          	li	a1,101
ffffffffc0203ad2:	00003517          	auipc	a0,0x3
ffffffffc0203ad6:	14e50513          	addi	a0,a0,334 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203ada:	f48fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203ade:	00003697          	auipc	a3,0x3
ffffffffc0203ae2:	52a68693          	addi	a3,a3,1322 # ffffffffc0207008 <default_pmm_manager+0x420>
ffffffffc0203ae6:	00003617          	auipc	a2,0x3
ffffffffc0203aea:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203aee:	25900593          	li	a1,601
ffffffffc0203af2:	00003517          	auipc	a0,0x3
ffffffffc0203af6:	12e50513          	addi	a0,a0,302 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203afa:	f28fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203afe:	00003697          	auipc	a3,0x3
ffffffffc0203b02:	3ba68693          	addi	a3,a3,954 # ffffffffc0206eb8 <default_pmm_manager+0x2d0>
ffffffffc0203b06:	00003617          	auipc	a2,0x3
ffffffffc0203b0a:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203b0e:	21200593          	li	a1,530
ffffffffc0203b12:	00003517          	auipc	a0,0x3
ffffffffc0203b16:	10e50513          	addi	a0,a0,270 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203b1a:	f08fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203b1e:	00003697          	auipc	a3,0x3
ffffffffc0203b22:	35a68693          	addi	a3,a3,858 # ffffffffc0206e78 <default_pmm_manager+0x290>
ffffffffc0203b26:	00003617          	auipc	a2,0x3
ffffffffc0203b2a:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203b2e:	21100593          	li	a1,529
ffffffffc0203b32:	00003517          	auipc	a0,0x3
ffffffffc0203b36:	0ee50513          	addi	a0,a0,238 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203b3a:	ee8fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203b3e:	86d6                	mv	a3,s5
ffffffffc0203b40:	00003617          	auipc	a2,0x3
ffffffffc0203b44:	93860613          	addi	a2,a2,-1736 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0203b48:	20d00593          	li	a1,525
ffffffffc0203b4c:	00003517          	auipc	a0,0x3
ffffffffc0203b50:	0d450513          	addi	a0,a0,212 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203b54:	ecefc0ef          	jal	ra,ffffffffc0200222 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203b58:	00003617          	auipc	a2,0x3
ffffffffc0203b5c:	92060613          	addi	a2,a2,-1760 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0203b60:	20c00593          	li	a1,524
ffffffffc0203b64:	00003517          	auipc	a0,0x3
ffffffffc0203b68:	0bc50513          	addi	a0,a0,188 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203b6c:	eb6fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203b70:	00003697          	auipc	a3,0x3
ffffffffc0203b74:	2c068693          	addi	a3,a3,704 # ffffffffc0206e30 <default_pmm_manager+0x248>
ffffffffc0203b78:	00003617          	auipc	a2,0x3
ffffffffc0203b7c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203b80:	20a00593          	li	a1,522
ffffffffc0203b84:	00003517          	auipc	a0,0x3
ffffffffc0203b88:	09c50513          	addi	a0,a0,156 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203b8c:	e96fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203b90:	00003697          	auipc	a3,0x3
ffffffffc0203b94:	28868693          	addi	a3,a3,648 # ffffffffc0206e18 <default_pmm_manager+0x230>
ffffffffc0203b98:	00003617          	auipc	a2,0x3
ffffffffc0203b9c:	99860613          	addi	a2,a2,-1640 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203ba0:	20900593          	li	a1,521
ffffffffc0203ba4:	00003517          	auipc	a0,0x3
ffffffffc0203ba8:	07c50513          	addi	a0,a0,124 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203bac:	e76fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203bb0:	00003697          	auipc	a3,0x3
ffffffffc0203bb4:	61868693          	addi	a3,a3,1560 # ffffffffc02071c8 <default_pmm_manager+0x5e0>
ffffffffc0203bb8:	00003617          	auipc	a2,0x3
ffffffffc0203bbc:	97860613          	addi	a2,a2,-1672 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203bc0:	25000593          	li	a1,592
ffffffffc0203bc4:	00003517          	auipc	a0,0x3
ffffffffc0203bc8:	05c50513          	addi	a0,a0,92 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203bcc:	e56fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203bd0:	00003697          	auipc	a3,0x3
ffffffffc0203bd4:	5c068693          	addi	a3,a3,1472 # ffffffffc0207190 <default_pmm_manager+0x5a8>
ffffffffc0203bd8:	00003617          	auipc	a2,0x3
ffffffffc0203bdc:	95860613          	addi	a2,a2,-1704 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203be0:	24d00593          	li	a1,589
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	03c50513          	addi	a0,a0,60 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203bec:	e36fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203bf0:	00003697          	auipc	a3,0x3
ffffffffc0203bf4:	57068693          	addi	a3,a3,1392 # ffffffffc0207160 <default_pmm_manager+0x578>
ffffffffc0203bf8:	00003617          	auipc	a2,0x3
ffffffffc0203bfc:	93860613          	addi	a2,a2,-1736 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203c00:	24900593          	li	a1,585
ffffffffc0203c04:	00003517          	auipc	a0,0x3
ffffffffc0203c08:	01c50513          	addi	a0,a0,28 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203c0c:	e16fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203c10:	00003697          	auipc	a3,0x3
ffffffffc0203c14:	50868693          	addi	a3,a3,1288 # ffffffffc0207118 <default_pmm_manager+0x530>
ffffffffc0203c18:	00003617          	auipc	a2,0x3
ffffffffc0203c1c:	91860613          	addi	a2,a2,-1768 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203c20:	24800593          	li	a1,584
ffffffffc0203c24:	00003517          	auipc	a0,0x3
ffffffffc0203c28:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203c2c:	df6fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203c30:	00003617          	auipc	a2,0x3
ffffffffc0203c34:	be860613          	addi	a2,a2,-1048 # ffffffffc0206818 <commands+0xb88>
ffffffffc0203c38:	0c900593          	li	a1,201
ffffffffc0203c3c:	00003517          	auipc	a0,0x3
ffffffffc0203c40:	fe450513          	addi	a0,a0,-28 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203c44:	ddefc0ef          	jal	ra,ffffffffc0200222 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203c48:	00003617          	auipc	a2,0x3
ffffffffc0203c4c:	bd060613          	addi	a2,a2,-1072 # ffffffffc0206818 <commands+0xb88>
ffffffffc0203c50:	08100593          	li	a1,129
ffffffffc0203c54:	00003517          	auipc	a0,0x3
ffffffffc0203c58:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203c5c:	dc6fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203c60:	00003697          	auipc	a3,0x3
ffffffffc0203c64:	18868693          	addi	a3,a3,392 # ffffffffc0206de8 <default_pmm_manager+0x200>
ffffffffc0203c68:	00003617          	auipc	a2,0x3
ffffffffc0203c6c:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203c70:	20800593          	li	a1,520
ffffffffc0203c74:	00003517          	auipc	a0,0x3
ffffffffc0203c78:	fac50513          	addi	a0,a0,-84 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203c7c:	da6fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203c80:	00003697          	auipc	a3,0x3
ffffffffc0203c84:	13868693          	addi	a3,a3,312 # ffffffffc0206db8 <default_pmm_manager+0x1d0>
ffffffffc0203c88:	00003617          	auipc	a2,0x3
ffffffffc0203c8c:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203c90:	20500593          	li	a1,517
ffffffffc0203c94:	00003517          	auipc	a0,0x3
ffffffffc0203c98:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203c9c:	d86fc0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0203ca0 <copy_range>:
{
ffffffffc0203ca0:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203ca2:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203ca6:	ec86                	sd	ra,88(sp)
ffffffffc0203ca8:	e8a2                	sd	s0,80(sp)
ffffffffc0203caa:	e4a6                	sd	s1,72(sp)
ffffffffc0203cac:	e0ca                	sd	s2,64(sp)
ffffffffc0203cae:	fc4e                	sd	s3,56(sp)
ffffffffc0203cb0:	f852                	sd	s4,48(sp)
ffffffffc0203cb2:	f456                	sd	s5,40(sp)
ffffffffc0203cb4:	f05a                	sd	s6,32(sp)
ffffffffc0203cb6:	ec5e                	sd	s7,24(sp)
ffffffffc0203cb8:	e862                	sd	s8,16(sp)
ffffffffc0203cba:	e466                	sd	s9,8(sp)
ffffffffc0203cbc:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cbe:	17d2                	slli	a5,a5,0x34
ffffffffc0203cc0:	10079f63          	bnez	a5,ffffffffc0203dde <copy_range+0x13e>
    assert(USER_ACCESS(start, end));
ffffffffc0203cc4:	002007b7          	lui	a5,0x200
ffffffffc0203cc8:	8432                	mv	s0,a2
ffffffffc0203cca:	0ef66a63          	bltu	a2,a5,ffffffffc0203dbe <copy_range+0x11e>
ffffffffc0203cce:	8936                	mv	s2,a3
ffffffffc0203cd0:	0ed67763          	bgeu	a2,a3,ffffffffc0203dbe <copy_range+0x11e>
ffffffffc0203cd4:	4785                	li	a5,1
ffffffffc0203cd6:	07fe                	slli	a5,a5,0x1f
ffffffffc0203cd8:	0ed7e363          	bltu	a5,a3,ffffffffc0203dbe <copy_range+0x11e>
ffffffffc0203cdc:	8aaa                	mv	s5,a0
ffffffffc0203cde:	89ae                	mv	s3,a1
    if (PPN(pa) >= npage)
ffffffffc0203ce0:	000c3c17          	auipc	s8,0xc3
ffffffffc0203ce4:	070c0c13          	addi	s8,s8,112 # ffffffffc02c6d50 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203ce8:	000c3b97          	auipc	s7,0xc3
ffffffffc0203cec:	070b8b93          	addi	s7,s7,112 # ffffffffc02c6d58 <pages>
ffffffffc0203cf0:	fff80b37          	lui	s6,0xfff80
        start += PGSIZE;
ffffffffc0203cf4:	6a05                	lui	s4,0x1
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203cf6:	00200d37          	lui	s10,0x200
ffffffffc0203cfa:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203cfe:	4601                	li	a2,0
ffffffffc0203d00:	85a2                	mv	a1,s0
ffffffffc0203d02:	854e                	mv	a0,s3
ffffffffc0203d04:	b77fe0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc0203d08:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203d0a:	c935                	beqz	a0,ffffffffc0203d7e <copy_range+0xde>
        if (*ptep & PTE_V)
ffffffffc0203d0c:	611c                	ld	a5,0(a0)
ffffffffc0203d0e:	8b85                	andi	a5,a5,1
ffffffffc0203d10:	e39d                	bnez	a5,ffffffffc0203d36 <copy_range+0x96>
        start += PGSIZE;
ffffffffc0203d12:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203d14:	ff2465e3          	bltu	s0,s2,ffffffffc0203cfe <copy_range+0x5e>
    return 0;
ffffffffc0203d18:	4501                	li	a0,0
}
ffffffffc0203d1a:	60e6                	ld	ra,88(sp)
ffffffffc0203d1c:	6446                	ld	s0,80(sp)
ffffffffc0203d1e:	64a6                	ld	s1,72(sp)
ffffffffc0203d20:	6906                	ld	s2,64(sp)
ffffffffc0203d22:	79e2                	ld	s3,56(sp)
ffffffffc0203d24:	7a42                	ld	s4,48(sp)
ffffffffc0203d26:	7aa2                	ld	s5,40(sp)
ffffffffc0203d28:	7b02                	ld	s6,32(sp)
ffffffffc0203d2a:	6be2                	ld	s7,24(sp)
ffffffffc0203d2c:	6c42                	ld	s8,16(sp)
ffffffffc0203d2e:	6ca2                	ld	s9,8(sp)
ffffffffc0203d30:	6d02                	ld	s10,0(sp)
ffffffffc0203d32:	6125                	addi	sp,sp,96
ffffffffc0203d34:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203d36:	4605                	li	a2,1
ffffffffc0203d38:	85a2                	mv	a1,s0
ffffffffc0203d3a:	8556                	mv	a0,s5
ffffffffc0203d3c:	b3ffe0ef          	jal	ra,ffffffffc020287a <get_pte>
ffffffffc0203d40:	c12d                	beqz	a0,ffffffffc0203da2 <copy_range+0x102>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203d42:	6098                	ld	a4,0(s1)
    if (!(pte & PTE_V))
ffffffffc0203d44:	00177793          	andi	a5,a4,1
ffffffffc0203d48:	0007069b          	sext.w	a3,a4
ffffffffc0203d4c:	cfa9                	beqz	a5,ffffffffc0203da6 <copy_range+0x106>
    if (PPN(pa) >= npage)
ffffffffc0203d4e:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d52:	00271793          	slli	a5,a4,0x2
ffffffffc0203d56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203d58:	0ac7f363          	bgeu	a5,a2,ffffffffc0203dfe <copy_range+0x15e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d5c:	000bb583          	ld	a1,0(s7)
ffffffffc0203d60:	97da                	add	a5,a5,s6
ffffffffc0203d62:	079a                	slli	a5,a5,0x6
            if (perm & PTE_W)
ffffffffc0203d64:	0046f613          	andi	a2,a3,4
ffffffffc0203d68:	95be                	add	a1,a1,a5
ffffffffc0203d6a:	e20d                	bnez	a2,ffffffffc0203d8c <copy_range+0xec>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203d6c:	21f6f693          	andi	a3,a3,543
            int ret = page_insert(to, page, start, perm);
ffffffffc0203d70:	8622                	mv	a2,s0
ffffffffc0203d72:	8556                	mv	a0,s5
ffffffffc0203d74:	9f6ff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
            if (ret != 0)
ffffffffc0203d78:	f14d                	bnez	a0,ffffffffc0203d1a <copy_range+0x7a>
        start += PGSIZE;
ffffffffc0203d7a:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203d7c:	bf61                	j	ffffffffc0203d14 <copy_range+0x74>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203d7e:	946a                	add	s0,s0,s10
ffffffffc0203d80:	01947433          	and	s0,s0,s9
    } while (start != 0 && start < end);
ffffffffc0203d84:	d851                	beqz	s0,ffffffffc0203d18 <copy_range+0x78>
ffffffffc0203d86:	f7246ce3          	bltu	s0,s2,ffffffffc0203cfe <copy_range+0x5e>
ffffffffc0203d8a:	b779                	j	ffffffffc0203d18 <copy_range+0x78>
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203d8c:	dfb77713          	andi	a4,a4,-517
ffffffffc0203d90:	20076713          	ori	a4,a4,512
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0203d94:	8aed                	andi	a3,a3,27
ffffffffc0203d96:	2006e693          	ori	a3,a3,512
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203d9a:	e098                	sd	a4,0(s1)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203d9c:	12040073          	sfence.vma	s0
}
ffffffffc0203da0:	bfc1                	j	ffffffffc0203d70 <copy_range+0xd0>
                return -E_NO_MEM;
ffffffffc0203da2:	5571                	li	a0,-4
ffffffffc0203da4:	bf9d                	j	ffffffffc0203d1a <copy_range+0x7a>
        panic("pte2page called with invalid pte");
ffffffffc0203da6:	00002617          	auipc	a2,0x2
ffffffffc0203daa:	66a60613          	addi	a2,a2,1642 # ffffffffc0206410 <commands+0x780>
ffffffffc0203dae:	07f00593          	li	a1,127
ffffffffc0203db2:	00002517          	auipc	a0,0x2
ffffffffc0203db6:	68650513          	addi	a0,a0,1670 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0203dba:	c68fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203dbe:	00003697          	auipc	a3,0x3
ffffffffc0203dc2:	ea268693          	addi	a3,a3,-350 # ffffffffc0206c60 <default_pmm_manager+0x78>
ffffffffc0203dc6:	00002617          	auipc	a2,0x2
ffffffffc0203dca:	76a60613          	addi	a2,a2,1898 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203dce:	17e00593          	li	a1,382
ffffffffc0203dd2:	00003517          	auipc	a0,0x3
ffffffffc0203dd6:	e4e50513          	addi	a0,a0,-434 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203dda:	c48fc0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203dde:	00003697          	auipc	a3,0x3
ffffffffc0203de2:	e5268693          	addi	a3,a3,-430 # ffffffffc0206c30 <default_pmm_manager+0x48>
ffffffffc0203de6:	00002617          	auipc	a2,0x2
ffffffffc0203dea:	74a60613          	addi	a2,a2,1866 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203dee:	17d00593          	li	a1,381
ffffffffc0203df2:	00003517          	auipc	a0,0x3
ffffffffc0203df6:	e2e50513          	addi	a0,a0,-466 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203dfa:	c28fc0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203dfe:	00002617          	auipc	a2,0x2
ffffffffc0203e02:	64a60613          	addi	a2,a2,1610 # ffffffffc0206448 <commands+0x7b8>
ffffffffc0203e06:	06900593          	li	a1,105
ffffffffc0203e0a:	00002517          	auipc	a0,0x2
ffffffffc0203e0e:	62e50513          	addi	a0,a0,1582 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0203e12:	c10fc0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0203e16 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e16:	12058073          	sfence.vma	a1
}
ffffffffc0203e1a:	8082                	ret

ffffffffc0203e1c <pgdir_alloc_page>:
{
ffffffffc0203e1c:	7179                	addi	sp,sp,-48
ffffffffc0203e1e:	ec26                	sd	s1,24(sp)
ffffffffc0203e20:	e84a                	sd	s2,16(sp)
ffffffffc0203e22:	e052                	sd	s4,0(sp)
ffffffffc0203e24:	f406                	sd	ra,40(sp)
ffffffffc0203e26:	f022                	sd	s0,32(sp)
ffffffffc0203e28:	e44e                	sd	s3,8(sp)
ffffffffc0203e2a:	8a2a                	mv	s4,a0
ffffffffc0203e2c:	84ae                	mv	s1,a1
ffffffffc0203e2e:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e30:	100027f3          	csrr	a5,sstatus
ffffffffc0203e34:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203e36:	000c3997          	auipc	s3,0xc3
ffffffffc0203e3a:	f2a98993          	addi	s3,s3,-214 # ffffffffc02c6d60 <pmm_manager>
ffffffffc0203e3e:	ef8d                	bnez	a5,ffffffffc0203e78 <pgdir_alloc_page+0x5c>
ffffffffc0203e40:	0009b783          	ld	a5,0(s3)
ffffffffc0203e44:	4505                	li	a0,1
ffffffffc0203e46:	6f9c                	ld	a5,24(a5)
ffffffffc0203e48:	9782                	jalr	a5
ffffffffc0203e4a:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203e4c:	cc09                	beqz	s0,ffffffffc0203e66 <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203e4e:	86ca                	mv	a3,s2
ffffffffc0203e50:	8626                	mv	a2,s1
ffffffffc0203e52:	85a2                	mv	a1,s0
ffffffffc0203e54:	8552                	mv	a0,s4
ffffffffc0203e56:	914ff0ef          	jal	ra,ffffffffc0202f6a <page_insert>
ffffffffc0203e5a:	e915                	bnez	a0,ffffffffc0203e8e <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203e5c:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203e5e:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203e60:	4785                	li	a5,1
ffffffffc0203e62:	04f71e63          	bne	a4,a5,ffffffffc0203ebe <pgdir_alloc_page+0xa2>
}
ffffffffc0203e66:	70a2                	ld	ra,40(sp)
ffffffffc0203e68:	8522                	mv	a0,s0
ffffffffc0203e6a:	7402                	ld	s0,32(sp)
ffffffffc0203e6c:	64e2                	ld	s1,24(sp)
ffffffffc0203e6e:	6942                	ld	s2,16(sp)
ffffffffc0203e70:	69a2                	ld	s3,8(sp)
ffffffffc0203e72:	6a02                	ld	s4,0(sp)
ffffffffc0203e74:	6145                	addi	sp,sp,48
ffffffffc0203e76:	8082                	ret
        intr_disable();
ffffffffc0203e78:	b3dfc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203e7c:	0009b783          	ld	a5,0(s3)
ffffffffc0203e80:	4505                	li	a0,1
ffffffffc0203e82:	6f9c                	ld	a5,24(a5)
ffffffffc0203e84:	9782                	jalr	a5
ffffffffc0203e86:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203e88:	b27fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203e8c:	b7c1                	j	ffffffffc0203e4c <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e8e:	100027f3          	csrr	a5,sstatus
ffffffffc0203e92:	8b89                	andi	a5,a5,2
ffffffffc0203e94:	eb89                	bnez	a5,ffffffffc0203ea6 <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0203e96:	0009b783          	ld	a5,0(s3)
ffffffffc0203e9a:	8522                	mv	a0,s0
ffffffffc0203e9c:	4585                	li	a1,1
ffffffffc0203e9e:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0203ea0:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203ea2:	9782                	jalr	a5
    if (flag)
ffffffffc0203ea4:	b7c9                	j	ffffffffc0203e66 <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc0203ea6:	b0ffc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
ffffffffc0203eaa:	0009b783          	ld	a5,0(s3)
ffffffffc0203eae:	8522                	mv	a0,s0
ffffffffc0203eb0:	4585                	li	a1,1
ffffffffc0203eb2:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0203eb4:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203eb6:	9782                	jalr	a5
        intr_enable();
ffffffffc0203eb8:	af7fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc0203ebc:	b76d                	j	ffffffffc0203e66 <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc0203ebe:	00003697          	auipc	a3,0x3
ffffffffc0203ec2:	35268693          	addi	a3,a3,850 # ffffffffc0207210 <default_pmm_manager+0x628>
ffffffffc0203ec6:	00002617          	auipc	a2,0x2
ffffffffc0203eca:	66a60613          	addi	a2,a2,1642 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0203ece:	1e600593          	li	a1,486
ffffffffc0203ed2:	00003517          	auipc	a0,0x3
ffffffffc0203ed6:	d4e50513          	addi	a0,a0,-690 # ffffffffc0206c20 <default_pmm_manager+0x38>
ffffffffc0203eda:	b48fc0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0203ede <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203ede:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203ee0:	9402                	jalr	s0

	jal do_exit
ffffffffc0203ee2:	626000ef          	jal	ra,ffffffffc0204508 <do_exit>

ffffffffc0203ee6 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203ee6:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203eea:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203eee:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203ef0:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203ef2:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203ef6:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203efa:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203efe:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203f02:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203f06:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203f0a:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203f0e:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203f12:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203f16:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203f1a:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203f1e:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0203f22:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203f24:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203f26:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203f2a:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203f2e:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0203f32:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203f36:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203f3a:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203f3e:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0203f42:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203f46:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203f4a:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0203f4e:	8082                	ret

ffffffffc0203f50 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203f50:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f52:	14800513          	li	a0,328
{
ffffffffc0203f56:	e022                	sd	s0,0(sp)
ffffffffc0203f58:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f5a:	bddfd0ef          	jal	ra,ffffffffc0201b36 <kmalloc>
ffffffffc0203f5e:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203f60:	c141                	beqz	a0,ffffffffc0203fe0 <alloc_proc+0x90>
    {
        proc->state = PROC_UNINIT;
ffffffffc0203f62:	57fd                	li	a5,-1
ffffffffc0203f64:	1782                	slli	a5,a5,0x20
ffffffffc0203f66:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203f68:	07000613          	li	a2,112
ffffffffc0203f6c:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0203f6e:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203f72:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203f76:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203f7a:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0203f7e:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203f82:	03050513          	addi	a0,a0,48
ffffffffc0203f86:	632010ef          	jal	ra,ffffffffc02055b8 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203f8a:	000c3797          	auipc	a5,0xc3
ffffffffc0203f8e:	db67b783          	ld	a5,-586(a5) # ffffffffc02c6d40 <boot_pgdir_pa>
ffffffffc0203f92:	f45c                	sd	a5,168(s0)
        proc->tf = NULL;
ffffffffc0203f94:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203f98:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203f9c:	4641                	li	a2,16
ffffffffc0203f9e:	4581                	li	a1,0
ffffffffc0203fa0:	0b440513          	addi	a0,s0,180
ffffffffc0203fa4:	614010ef          	jal	ra,ffffffffc02055b8 <memset>
        proc->wait_state = 0;
        proc->cptr = proc->yptr = proc->optr = NULL;
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc0203fa8:	11040793          	addi	a5,s0,272
    elm->prev = elm->next = elm;
ffffffffc0203fac:	10f43c23          	sd	a5,280(s0)
ffffffffc0203fb0:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;
        skew_heap_init(&(proc->lab6_run_pool));
        proc->lab6_stride = 0;
ffffffffc0203fb4:	4785                	li	a5,1
ffffffffc0203fb6:	1782                	slli	a5,a5,0x20
        proc->wait_state = 0;
ffffffffc0203fb8:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0203fbc:	10043023          	sd	zero,256(s0)
ffffffffc0203fc0:	0e043c23          	sd	zero,248(s0)
ffffffffc0203fc4:	0e043823          	sd	zero,240(s0)
        proc->rq = NULL;
ffffffffc0203fc8:	10043423          	sd	zero,264(s0)
        proc->time_slice = 0;
ffffffffc0203fcc:	12042023          	sw	zero,288(s0)
     compare_f comp) __attribute__((always_inline));

static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL;
ffffffffc0203fd0:	12043423          	sd	zero,296(s0)
ffffffffc0203fd4:	12043823          	sd	zero,304(s0)
ffffffffc0203fd8:	12043c23          	sd	zero,312(s0)
        proc->lab6_stride = 0;
ffffffffc0203fdc:	14f43023          	sd	a5,320(s0)
        proc->lab6_priority = 1;
    }
    return proc;
}
ffffffffc0203fe0:	60a2                	ld	ra,8(sp)
ffffffffc0203fe2:	8522                	mv	a0,s0
ffffffffc0203fe4:	6402                	ld	s0,0(sp)
ffffffffc0203fe6:	0141                	addi	sp,sp,16
ffffffffc0203fe8:	8082                	ret

ffffffffc0203fea <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203fea:	000c3797          	auipc	a5,0xc3
ffffffffc0203fee:	d867b783          	ld	a5,-634(a5) # ffffffffc02c6d70 <current>
ffffffffc0203ff2:	73c8                	ld	a0,160(a5)
ffffffffc0203ff4:	936fd06f          	j	ffffffffc020112a <forkrets>

ffffffffc0203ff8 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203ff8:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0203ffa:	1141                	addi	sp,sp,-16
ffffffffc0203ffc:	e406                	sd	ra,8(sp)
ffffffffc0203ffe:	c02007b7          	lui	a5,0xc0200
ffffffffc0204002:	02f6ee63          	bltu	a3,a5,ffffffffc020403e <put_pgdir+0x46>
ffffffffc0204006:	000c3517          	auipc	a0,0xc3
ffffffffc020400a:	d6253503          	ld	a0,-670(a0) # ffffffffc02c6d68 <va_pa_offset>
ffffffffc020400e:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc0204010:	82b1                	srli	a3,a3,0xc
ffffffffc0204012:	000c3797          	auipc	a5,0xc3
ffffffffc0204016:	d3e7b783          	ld	a5,-706(a5) # ffffffffc02c6d50 <npage>
ffffffffc020401a:	02f6fe63          	bgeu	a3,a5,ffffffffc0204056 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020401e:	00004517          	auipc	a0,0x4
ffffffffc0204022:	23a53503          	ld	a0,570(a0) # ffffffffc0208258 <nbase>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0204026:	60a2                	ld	ra,8(sp)
ffffffffc0204028:	8e89                	sub	a3,a3,a0
ffffffffc020402a:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020402c:	000c3517          	auipc	a0,0xc3
ffffffffc0204030:	d2c53503          	ld	a0,-724(a0) # ffffffffc02c6d58 <pages>
ffffffffc0204034:	4585                	li	a1,1
ffffffffc0204036:	9536                	add	a0,a0,a3
}
ffffffffc0204038:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc020403a:	fc6fe06f          	j	ffffffffc0202800 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc020403e:	00002617          	auipc	a2,0x2
ffffffffc0204042:	7da60613          	addi	a2,a2,2010 # ffffffffc0206818 <commands+0xb88>
ffffffffc0204046:	07700593          	li	a1,119
ffffffffc020404a:	00002517          	auipc	a0,0x2
ffffffffc020404e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0204052:	9d0fc0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204056:	00002617          	auipc	a2,0x2
ffffffffc020405a:	3f260613          	addi	a2,a2,1010 # ffffffffc0206448 <commands+0x7b8>
ffffffffc020405e:	06900593          	li	a1,105
ffffffffc0204062:	00002517          	auipc	a0,0x2
ffffffffc0204066:	3d650513          	addi	a0,a0,982 # ffffffffc0206438 <commands+0x7a8>
ffffffffc020406a:	9b8fc0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc020406e <proc_run>:
{
ffffffffc020406e:	7179                	addi	sp,sp,-48
ffffffffc0204070:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc0204072:	000c3917          	auipc	s2,0xc3
ffffffffc0204076:	cfe90913          	addi	s2,s2,-770 # ffffffffc02c6d70 <current>
{
ffffffffc020407a:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc020407c:	00093483          	ld	s1,0(s2)
{
ffffffffc0204080:	f406                	sd	ra,40(sp)
ffffffffc0204082:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc0204084:	02a48863          	beq	s1,a0,ffffffffc02040b4 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204088:	100027f3          	csrr	a5,sstatus
ffffffffc020408c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020408e:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204090:	ef9d                	bnez	a5,ffffffffc02040ce <proc_run+0x60>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204092:	755c                	ld	a5,168(a0)
ffffffffc0204094:	577d                	li	a4,-1
ffffffffc0204096:	177e                	slli	a4,a4,0x3f
ffffffffc0204098:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc020409a:	00a93023          	sd	a0,0(s2)
ffffffffc020409e:	8fd9                	or	a5,a5,a4
ffffffffc02040a0:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc02040a4:	03050593          	addi	a1,a0,48
ffffffffc02040a8:	03048513          	addi	a0,s1,48
ffffffffc02040ac:	e3bff0ef          	jal	ra,ffffffffc0203ee6 <switch_to>
    if (flag)
ffffffffc02040b0:	00099863          	bnez	s3,ffffffffc02040c0 <proc_run+0x52>
}
ffffffffc02040b4:	70a2                	ld	ra,40(sp)
ffffffffc02040b6:	7482                	ld	s1,32(sp)
ffffffffc02040b8:	6962                	ld	s2,24(sp)
ffffffffc02040ba:	69c2                	ld	s3,16(sp)
ffffffffc02040bc:	6145                	addi	sp,sp,48
ffffffffc02040be:	8082                	ret
ffffffffc02040c0:	70a2                	ld	ra,40(sp)
ffffffffc02040c2:	7482                	ld	s1,32(sp)
ffffffffc02040c4:	6962                	ld	s2,24(sp)
ffffffffc02040c6:	69c2                	ld	s3,16(sp)
ffffffffc02040c8:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02040ca:	8e5fc06f          	j	ffffffffc02009ae <intr_enable>
ffffffffc02040ce:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02040d0:	8e5fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02040d4:	6522                	ld	a0,8(sp)
ffffffffc02040d6:	4985                	li	s3,1
ffffffffc02040d8:	bf6d                	j	ffffffffc0204092 <proc_run+0x24>

ffffffffc02040da <do_fork>:
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
ffffffffc02040da:	7119                	addi	sp,sp,-128
ffffffffc02040dc:	f0ca                	sd	s2,96(sp)
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc02040de:	000c3917          	auipc	s2,0xc3
ffffffffc02040e2:	caa90913          	addi	s2,s2,-854 # ffffffffc02c6d88 <nr_process>
ffffffffc02040e6:	00092703          	lw	a4,0(s2)
{
ffffffffc02040ea:	fc86                	sd	ra,120(sp)
ffffffffc02040ec:	f8a2                	sd	s0,112(sp)
ffffffffc02040ee:	f4a6                	sd	s1,104(sp)
ffffffffc02040f0:	ecce                	sd	s3,88(sp)
ffffffffc02040f2:	e8d2                	sd	s4,80(sp)
ffffffffc02040f4:	e4d6                	sd	s5,72(sp)
ffffffffc02040f6:	e0da                	sd	s6,64(sp)
ffffffffc02040f8:	fc5e                	sd	s7,56(sp)
ffffffffc02040fa:	f862                	sd	s8,48(sp)
ffffffffc02040fc:	f466                	sd	s9,40(sp)
ffffffffc02040fe:	f06a                	sd	s10,32(sp)
ffffffffc0204100:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204102:	6785                	lui	a5,0x1
ffffffffc0204104:	32f75863          	bge	a4,a5,ffffffffc0204434 <do_fork+0x35a>
ffffffffc0204108:	8a2a                	mv	s4,a0
ffffffffc020410a:	89ae                	mv	s3,a1
ffffffffc020410c:	8432                	mv	s0,a2
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL)
ffffffffc020410e:	e43ff0ef          	jal	ra,ffffffffc0203f50 <alloc_proc>
ffffffffc0204112:	84aa                	mv	s1,a0
ffffffffc0204114:	30050163          	beqz	a0,ffffffffc0204416 <do_fork+0x33c>
    {
        goto fork_out;
    }

    proc->parent = current;
ffffffffc0204118:	000c3c17          	auipc	s8,0xc3
ffffffffc020411c:	c58c0c13          	addi	s8,s8,-936 # ffffffffc02c6d70 <current>
ffffffffc0204120:	000c3783          	ld	a5,0(s8)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204124:	4509                	li	a0,2
    proc->parent = current;
ffffffffc0204126:	f09c                	sd	a5,32(s1)
    current->wait_state = 0;
ffffffffc0204128:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8e74>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020412c:	e96fe0ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
    if (page != NULL)
ffffffffc0204130:	2e050063          	beqz	a0,ffffffffc0204410 <do_fork+0x336>
    return page - pages + nbase;
ffffffffc0204134:	000c3a97          	auipc	s5,0xc3
ffffffffc0204138:	c24a8a93          	addi	s5,s5,-988 # ffffffffc02c6d58 <pages>
ffffffffc020413c:	000ab683          	ld	a3,0(s5)
ffffffffc0204140:	00004b17          	auipc	s6,0x4
ffffffffc0204144:	118b0b13          	addi	s6,s6,280 # ffffffffc0208258 <nbase>
ffffffffc0204148:	000b3783          	ld	a5,0(s6)
ffffffffc020414c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204150:	000c3b97          	auipc	s7,0xc3
ffffffffc0204154:	c00b8b93          	addi	s7,s7,-1024 # ffffffffc02c6d50 <npage>
    return page - pages + nbase;
ffffffffc0204158:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020415a:	5dfd                	li	s11,-1
ffffffffc020415c:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204160:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204162:	00cddd93          	srli	s11,s11,0xc
ffffffffc0204166:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc020416a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020416c:	32e67a63          	bgeu	a2,a4,ffffffffc02044a0 <do_fork+0x3c6>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204170:	000c3603          	ld	a2,0(s8)
ffffffffc0204174:	000c3c17          	auipc	s8,0xc3
ffffffffc0204178:	bf4c0c13          	addi	s8,s8,-1036 # ffffffffc02c6d68 <va_pa_offset>
ffffffffc020417c:	000c3703          	ld	a4,0(s8)
ffffffffc0204180:	02863d03          	ld	s10,40(a2)
ffffffffc0204184:	e43e                	sd	a5,8(sp)
ffffffffc0204186:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204188:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc020418a:	020d0863          	beqz	s10,ffffffffc02041ba <do_fork+0xe0>
    if (clone_flags & CLONE_VM)
ffffffffc020418e:	100a7a13          	andi	s4,s4,256
ffffffffc0204192:	1c0a0163          	beqz	s4,ffffffffc0204354 <do_fork+0x27a>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204196:	030d2703          	lw	a4,48(s10) # 200030 <_binary_obj___user_matrix_out_size+0x1f3908>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020419a:	018d3783          	ld	a5,24(s10)
ffffffffc020419e:	c02006b7          	lui	a3,0xc0200
ffffffffc02041a2:	2705                	addiw	a4,a4,1
ffffffffc02041a4:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc02041a8:	03a4b423          	sd	s10,40(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041ac:	2cd7e163          	bltu	a5,a3,ffffffffc020446e <do_fork+0x394>
ffffffffc02041b0:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041b4:	6894                	ld	a3,16(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041b6:	8f99                	sub	a5,a5,a4
ffffffffc02041b8:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041ba:	6789                	lui	a5,0x2
ffffffffc02041bc:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8080>
ffffffffc02041c0:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02041c2:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041c4:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc02041c6:	87b6                	mv	a5,a3
ffffffffc02041c8:	12040893          	addi	a7,s0,288
ffffffffc02041cc:	00063803          	ld	a6,0(a2)
ffffffffc02041d0:	6608                	ld	a0,8(a2)
ffffffffc02041d2:	6a0c                	ld	a1,16(a2)
ffffffffc02041d4:	6e18                	ld	a4,24(a2)
ffffffffc02041d6:	0107b023          	sd	a6,0(a5)
ffffffffc02041da:	e788                	sd	a0,8(a5)
ffffffffc02041dc:	eb8c                	sd	a1,16(a5)
ffffffffc02041de:	ef98                	sd	a4,24(a5)
ffffffffc02041e0:	02060613          	addi	a2,a2,32
ffffffffc02041e4:	02078793          	addi	a5,a5,32
ffffffffc02041e8:	ff1612e3          	bne	a2,a7,ffffffffc02041cc <do_fork+0xf2>
    proc->tf->gpr.a0 = 0;
ffffffffc02041ec:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02041f0:	12098f63          	beqz	s3,ffffffffc020432e <do_fork+0x254>
ffffffffc02041f4:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02041f8:	00000797          	auipc	a5,0x0
ffffffffc02041fc:	df278793          	addi	a5,a5,-526 # ffffffffc0203fea <forkret>
ffffffffc0204200:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204202:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204204:	100027f3          	csrr	a5,sstatus
ffffffffc0204208:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020420a:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020420c:	14079063          	bnez	a5,ffffffffc020434c <do_fork+0x272>
    if (++last_pid >= MAX_PID)
ffffffffc0204210:	000be817          	auipc	a6,0xbe
ffffffffc0204214:	6a080813          	addi	a6,a6,1696 # ffffffffc02c28b0 <last_pid.1>
ffffffffc0204218:	00082783          	lw	a5,0(a6)
ffffffffc020421c:	6709                	lui	a4,0x2
ffffffffc020421e:	0017851b          	addiw	a0,a5,1
ffffffffc0204222:	00a82023          	sw	a0,0(a6)
ffffffffc0204226:	08e55d63          	bge	a0,a4,ffffffffc02042c0 <do_fork+0x1e6>
    if (last_pid >= next_safe)
ffffffffc020422a:	000be317          	auipc	t1,0xbe
ffffffffc020422e:	68a30313          	addi	t1,t1,1674 # ffffffffc02c28b4 <next_safe.0>
ffffffffc0204232:	00032783          	lw	a5,0(t1)
ffffffffc0204236:	000c3417          	auipc	s0,0xc3
ffffffffc020423a:	a9a40413          	addi	s0,s0,-1382 # ffffffffc02c6cd0 <proc_list>
ffffffffc020423e:	08f55963          	bge	a0,a5,ffffffffc02042d0 <do_fork+0x1f6>
    copy_thread(proc, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
ffffffffc0204242:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204244:	45a9                	li	a1,10
ffffffffc0204246:	2501                	sext.w	a0,a0
ffffffffc0204248:	788010ef          	jal	ra,ffffffffc02059d0 <hash32>
ffffffffc020424c:	02051793          	slli	a5,a0,0x20
ffffffffc0204250:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204254:	000bf797          	auipc	a5,0xbf
ffffffffc0204258:	a7c78793          	addi	a5,a5,-1412 # ffffffffc02c2cd0 <hash_list>
ffffffffc020425c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020425e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204260:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204262:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204266:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204268:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc020426a:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020426c:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020426e:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204272:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204274:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204276:	e21c                	sd	a5,0(a2)
ffffffffc0204278:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc020427a:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc020427c:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc020427e:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204282:	10e4b023          	sd	a4,256(s1)
ffffffffc0204286:	c311                	beqz	a4,ffffffffc020428a <do_fork+0x1b0>
        proc->optr->yptr = proc;
ffffffffc0204288:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc020428a:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020428e:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc0204290:	2785                	addiw	a5,a5,1
ffffffffc0204292:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc0204296:	18099263          	bnez	s3,ffffffffc020441a <do_fork+0x340>
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc020429a:	8526                	mv	a0,s1
ffffffffc020429c:	787000ef          	jal	ra,ffffffffc0205222 <wakeup_proc>
    ret = proc->pid;
ffffffffc02042a0:	40c8                	lw	a0,4(s1)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc02042a2:	70e6                	ld	ra,120(sp)
ffffffffc02042a4:	7446                	ld	s0,112(sp)
ffffffffc02042a6:	74a6                	ld	s1,104(sp)
ffffffffc02042a8:	7906                	ld	s2,96(sp)
ffffffffc02042aa:	69e6                	ld	s3,88(sp)
ffffffffc02042ac:	6a46                	ld	s4,80(sp)
ffffffffc02042ae:	6aa6                	ld	s5,72(sp)
ffffffffc02042b0:	6b06                	ld	s6,64(sp)
ffffffffc02042b2:	7be2                	ld	s7,56(sp)
ffffffffc02042b4:	7c42                	ld	s8,48(sp)
ffffffffc02042b6:	7ca2                	ld	s9,40(sp)
ffffffffc02042b8:	7d02                	ld	s10,32(sp)
ffffffffc02042ba:	6de2                	ld	s11,24(sp)
ffffffffc02042bc:	6109                	addi	sp,sp,128
ffffffffc02042be:	8082                	ret
        last_pid = 1;
ffffffffc02042c0:	4785                	li	a5,1
ffffffffc02042c2:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc02042c6:	4505                	li	a0,1
ffffffffc02042c8:	000be317          	auipc	t1,0xbe
ffffffffc02042cc:	5ec30313          	addi	t1,t1,1516 # ffffffffc02c28b4 <next_safe.0>
    return listelm->next;
ffffffffc02042d0:	000c3417          	auipc	s0,0xc3
ffffffffc02042d4:	a0040413          	addi	s0,s0,-1536 # ffffffffc02c6cd0 <proc_list>
ffffffffc02042d8:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02042dc:	6789                	lui	a5,0x2
ffffffffc02042de:	00f32023          	sw	a5,0(t1)
ffffffffc02042e2:	86aa                	mv	a3,a0
ffffffffc02042e4:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02042e6:	6e89                	lui	t4,0x2
ffffffffc02042e8:	148e0163          	beq	t3,s0,ffffffffc020442a <do_fork+0x350>
ffffffffc02042ec:	88ae                	mv	a7,a1
ffffffffc02042ee:	87f2                	mv	a5,t3
ffffffffc02042f0:	6609                	lui	a2,0x2
ffffffffc02042f2:	a811                	j	ffffffffc0204306 <do_fork+0x22c>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042f4:	00e6d663          	bge	a3,a4,ffffffffc0204300 <do_fork+0x226>
ffffffffc02042f8:	00c75463          	bge	a4,a2,ffffffffc0204300 <do_fork+0x226>
ffffffffc02042fc:	863a                	mv	a2,a4
ffffffffc02042fe:	4885                	li	a7,1
ffffffffc0204300:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204302:	00878d63          	beq	a5,s0,ffffffffc020431c <do_fork+0x242>
            if (proc->pid == last_pid)
ffffffffc0204306:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x8024>
ffffffffc020430a:	fed715e3          	bne	a4,a3,ffffffffc02042f4 <do_fork+0x21a>
                if (++last_pid >= next_safe)
ffffffffc020430e:	2685                	addiw	a3,a3,1
ffffffffc0204310:	10c6d863          	bge	a3,a2,ffffffffc0204420 <do_fork+0x346>
ffffffffc0204314:	679c                	ld	a5,8(a5)
ffffffffc0204316:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204318:	fe8797e3          	bne	a5,s0,ffffffffc0204306 <do_fork+0x22c>
ffffffffc020431c:	c581                	beqz	a1,ffffffffc0204324 <do_fork+0x24a>
ffffffffc020431e:	00d82023          	sw	a3,0(a6)
ffffffffc0204322:	8536                	mv	a0,a3
ffffffffc0204324:	f0088fe3          	beqz	a7,ffffffffc0204242 <do_fork+0x168>
ffffffffc0204328:	00c32023          	sw	a2,0(t1)
ffffffffc020432c:	bf19                	j	ffffffffc0204242 <do_fork+0x168>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020432e:	89b6                	mv	s3,a3
ffffffffc0204330:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204334:	00000797          	auipc	a5,0x0
ffffffffc0204338:	cb678793          	addi	a5,a5,-842 # ffffffffc0203fea <forkret>
ffffffffc020433c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020433e:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204340:	100027f3          	csrr	a5,sstatus
ffffffffc0204344:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204346:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204348:	ec0784e3          	beqz	a5,ffffffffc0204210 <do_fork+0x136>
        intr_disable();
ffffffffc020434c:	e68fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204350:	4985                	li	s3,1
ffffffffc0204352:	bd7d                	j	ffffffffc0204210 <do_fork+0x136>
    if ((mm = mm_create()) == NULL)
ffffffffc0204354:	ea7fc0ef          	jal	ra,ffffffffc02011fa <mm_create>
ffffffffc0204358:	8caa                	mv	s9,a0
ffffffffc020435a:	c159                	beqz	a0,ffffffffc02043e0 <do_fork+0x306>
    if ((page = alloc_page()) == NULL)
ffffffffc020435c:	4505                	li	a0,1
ffffffffc020435e:	c64fe0ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc0204362:	cd25                	beqz	a0,ffffffffc02043da <do_fork+0x300>
    return page - pages + nbase;
ffffffffc0204364:	000ab683          	ld	a3,0(s5)
ffffffffc0204368:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc020436a:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc020436e:	40d506b3          	sub	a3,a0,a3
ffffffffc0204372:	8699                	srai	a3,a3,0x6
ffffffffc0204374:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204376:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc020437a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020437c:	12edf263          	bgeu	s11,a4,ffffffffc02044a0 <do_fork+0x3c6>
ffffffffc0204380:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204384:	6605                	lui	a2,0x1
ffffffffc0204386:	000c3597          	auipc	a1,0xc3
ffffffffc020438a:	9c25b583          	ld	a1,-1598(a1) # ffffffffc02c6d48 <boot_pgdir_va>
ffffffffc020438e:	9a36                	add	s4,s4,a3
ffffffffc0204390:	8552                	mv	a0,s4
ffffffffc0204392:	238010ef          	jal	ra,ffffffffc02055ca <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204396:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc020439a:	014cbc23          	sd	s4,24(s9) # ffffffffffe00018 <end+0x3fb39278>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020439e:	4785                	li	a5,1
ffffffffc02043a0:	40fdb7af          	amoor.d	a5,a5,(s11)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02043a4:	8b85                	andi	a5,a5,1
ffffffffc02043a6:	4a05                	li	s4,1
ffffffffc02043a8:	c799                	beqz	a5,ffffffffc02043b6 <do_fork+0x2dc>
    {
        schedule();
ffffffffc02043aa:	72b000ef          	jal	ra,ffffffffc02052d4 <schedule>
ffffffffc02043ae:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock))
ffffffffc02043b2:	8b85                	andi	a5,a5,1
ffffffffc02043b4:	fbfd                	bnez	a5,ffffffffc02043aa <do_fork+0x2d0>
        ret = dup_mmap(mm, oldmm);
ffffffffc02043b6:	85ea                	mv	a1,s10
ffffffffc02043b8:	8566                	mv	a0,s9
ffffffffc02043ba:	882fd0ef          	jal	ra,ffffffffc020143c <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02043be:	57f9                	li	a5,-2
ffffffffc02043c0:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02043c4:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc02043c6:	cfa5                	beqz	a5,ffffffffc020443e <do_fork+0x364>
good_mm:
ffffffffc02043c8:	8d66                	mv	s10,s9
    if (ret != 0)
ffffffffc02043ca:	dc0506e3          	beqz	a0,ffffffffc0204196 <do_fork+0xbc>
    exit_mmap(mm);
ffffffffc02043ce:	8566                	mv	a0,s9
ffffffffc02043d0:	906fd0ef          	jal	ra,ffffffffc02014d6 <exit_mmap>
    put_pgdir(mm);
ffffffffc02043d4:	8566                	mv	a0,s9
ffffffffc02043d6:	c23ff0ef          	jal	ra,ffffffffc0203ff8 <put_pgdir>
    mm_destroy(mm);
ffffffffc02043da:	8566                	mv	a0,s9
ffffffffc02043dc:	f5ffc0ef          	jal	ra,ffffffffc020133a <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02043e0:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02043e2:	c02007b7          	lui	a5,0xc0200
ffffffffc02043e6:	0af6e163          	bltu	a3,a5,ffffffffc0204488 <do_fork+0x3ae>
ffffffffc02043ea:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc02043ee:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02043f2:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc02043f6:	83b1                	srli	a5,a5,0xc
ffffffffc02043f8:	04e7ff63          	bgeu	a5,a4,ffffffffc0204456 <do_fork+0x37c>
    return &pages[PPN(pa) - nbase];
ffffffffc02043fc:	000b3703          	ld	a4,0(s6)
ffffffffc0204400:	000ab503          	ld	a0,0(s5)
ffffffffc0204404:	4589                	li	a1,2
ffffffffc0204406:	8f99                	sub	a5,a5,a4
ffffffffc0204408:	079a                	slli	a5,a5,0x6
ffffffffc020440a:	953e                	add	a0,a0,a5
ffffffffc020440c:	bf4fe0ef          	jal	ra,ffffffffc0202800 <free_pages>
    kfree(proc);
ffffffffc0204410:	8526                	mv	a0,s1
ffffffffc0204412:	fd4fd0ef          	jal	ra,ffffffffc0201be6 <kfree>
    ret = -E_NO_MEM;
ffffffffc0204416:	5571                	li	a0,-4
    return ret;
ffffffffc0204418:	b569                	j	ffffffffc02042a2 <do_fork+0x1c8>
        intr_enable();
ffffffffc020441a:	d94fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc020441e:	bdb5                	j	ffffffffc020429a <do_fork+0x1c0>
                    if (last_pid >= MAX_PID)
ffffffffc0204420:	01d6c363          	blt	a3,t4,ffffffffc0204426 <do_fork+0x34c>
                        last_pid = 1;
ffffffffc0204424:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204426:	4585                	li	a1,1
ffffffffc0204428:	b5c1                	j	ffffffffc02042e8 <do_fork+0x20e>
ffffffffc020442a:	c599                	beqz	a1,ffffffffc0204438 <do_fork+0x35e>
ffffffffc020442c:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0204430:	8536                	mv	a0,a3
ffffffffc0204432:	bd01                	j	ffffffffc0204242 <do_fork+0x168>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204434:	556d                	li	a0,-5
ffffffffc0204436:	b5b5                	j	ffffffffc02042a2 <do_fork+0x1c8>
    return last_pid;
ffffffffc0204438:	00082503          	lw	a0,0(a6)
ffffffffc020443c:	b519                	j	ffffffffc0204242 <do_fork+0x168>
    {
        panic("Unlock failed.\n");
ffffffffc020443e:	00003617          	auipc	a2,0x3
ffffffffc0204442:	dea60613          	addi	a2,a2,-534 # ffffffffc0207228 <default_pmm_manager+0x640>
ffffffffc0204446:	04000593          	li	a1,64
ffffffffc020444a:	00003517          	auipc	a0,0x3
ffffffffc020444e:	dee50513          	addi	a0,a0,-530 # ffffffffc0207238 <default_pmm_manager+0x650>
ffffffffc0204452:	dd1fb0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204456:	00002617          	auipc	a2,0x2
ffffffffc020445a:	ff260613          	addi	a2,a2,-14 # ffffffffc0206448 <commands+0x7b8>
ffffffffc020445e:	06900593          	li	a1,105
ffffffffc0204462:	00002517          	auipc	a0,0x2
ffffffffc0204466:	fd650513          	addi	a0,a0,-42 # ffffffffc0206438 <commands+0x7a8>
ffffffffc020446a:	db9fb0ef          	jal	ra,ffffffffc0200222 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020446e:	86be                	mv	a3,a5
ffffffffc0204470:	00002617          	auipc	a2,0x2
ffffffffc0204474:	3a860613          	addi	a2,a2,936 # ffffffffc0206818 <commands+0xb88>
ffffffffc0204478:	16f00593          	li	a1,367
ffffffffc020447c:	00003517          	auipc	a0,0x3
ffffffffc0204480:	dd450513          	addi	a0,a0,-556 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204484:	d9ffb0ef          	jal	ra,ffffffffc0200222 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204488:	00002617          	auipc	a2,0x2
ffffffffc020448c:	39060613          	addi	a2,a2,912 # ffffffffc0206818 <commands+0xb88>
ffffffffc0204490:	07700593          	li	a1,119
ffffffffc0204494:	00002517          	auipc	a0,0x2
ffffffffc0204498:	fa450513          	addi	a0,a0,-92 # ffffffffc0206438 <commands+0x7a8>
ffffffffc020449c:	d87fb0ef          	jal	ra,ffffffffc0200222 <__panic>
    return KADDR(page2pa(page));
ffffffffc02044a0:	00002617          	auipc	a2,0x2
ffffffffc02044a4:	fd860613          	addi	a2,a2,-40 # ffffffffc0206478 <commands+0x7e8>
ffffffffc02044a8:	07100593          	li	a1,113
ffffffffc02044ac:	00002517          	auipc	a0,0x2
ffffffffc02044b0:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206438 <commands+0x7a8>
ffffffffc02044b4:	d6ffb0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02044b8 <kernel_thread>:
{
ffffffffc02044b8:	7129                	addi	sp,sp,-320
ffffffffc02044ba:	fa22                	sd	s0,304(sp)
ffffffffc02044bc:	f626                	sd	s1,296(sp)
ffffffffc02044be:	f24a                	sd	s2,288(sp)
ffffffffc02044c0:	84ae                	mv	s1,a1
ffffffffc02044c2:	892a                	mv	s2,a0
ffffffffc02044c4:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02044c6:	4581                	li	a1,0
ffffffffc02044c8:	12000613          	li	a2,288
ffffffffc02044cc:	850a                	mv	a0,sp
{
ffffffffc02044ce:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02044d0:	0e8010ef          	jal	ra,ffffffffc02055b8 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02044d4:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02044d6:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02044d8:	100027f3          	csrr	a5,sstatus
ffffffffc02044dc:	edd7f793          	andi	a5,a5,-291
ffffffffc02044e0:	1207e793          	ori	a5,a5,288
ffffffffc02044e4:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044e6:	860a                	mv	a2,sp
ffffffffc02044e8:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044ec:	00000797          	auipc	a5,0x0
ffffffffc02044f0:	9f278793          	addi	a5,a5,-1550 # ffffffffc0203ede <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044f4:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044f6:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044f8:	be3ff0ef          	jal	ra,ffffffffc02040da <do_fork>
}
ffffffffc02044fc:	70f2                	ld	ra,312(sp)
ffffffffc02044fe:	7452                	ld	s0,304(sp)
ffffffffc0204500:	74b2                	ld	s1,296(sp)
ffffffffc0204502:	7912                	ld	s2,288(sp)
ffffffffc0204504:	6131                	addi	sp,sp,320
ffffffffc0204506:	8082                	ret

ffffffffc0204508 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc0204508:	7179                	addi	sp,sp,-48
ffffffffc020450a:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc020450c:	000c3417          	auipc	s0,0xc3
ffffffffc0204510:	86440413          	addi	s0,s0,-1948 # ffffffffc02c6d70 <current>
ffffffffc0204514:	601c                	ld	a5,0(s0)
{
ffffffffc0204516:	f406                	sd	ra,40(sp)
ffffffffc0204518:	ec26                	sd	s1,24(sp)
ffffffffc020451a:	e84a                	sd	s2,16(sp)
ffffffffc020451c:	e44e                	sd	s3,8(sp)
ffffffffc020451e:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc0204520:	000c3717          	auipc	a4,0xc3
ffffffffc0204524:	85873703          	ld	a4,-1960(a4) # ffffffffc02c6d78 <idleproc>
ffffffffc0204528:	0ce78c63          	beq	a5,a4,ffffffffc0204600 <do_exit+0xf8>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc020452c:	000c3497          	auipc	s1,0xc3
ffffffffc0204530:	85448493          	addi	s1,s1,-1964 # ffffffffc02c6d80 <initproc>
ffffffffc0204534:	6098                	ld	a4,0(s1)
ffffffffc0204536:	0ee78b63          	beq	a5,a4,ffffffffc020462c <do_exit+0x124>
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc020453a:	0287b983          	ld	s3,40(a5)
ffffffffc020453e:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204540:	02098663          	beqz	s3,ffffffffc020456c <do_exit+0x64>
ffffffffc0204544:	000c2797          	auipc	a5,0xc2
ffffffffc0204548:	7fc7b783          	ld	a5,2044(a5) # ffffffffc02c6d40 <boot_pgdir_pa>
ffffffffc020454c:	577d                	li	a4,-1
ffffffffc020454e:	177e                	slli	a4,a4,0x3f
ffffffffc0204550:	83b1                	srli	a5,a5,0xc
ffffffffc0204552:	8fd9                	or	a5,a5,a4
ffffffffc0204554:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204558:	0309a783          	lw	a5,48(s3)
ffffffffc020455c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204560:	02e9a823          	sw	a4,48(s3)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc0204564:	cb55                	beqz	a4,ffffffffc0204618 <do_exit+0x110>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc0204566:	601c                	ld	a5,0(s0)
ffffffffc0204568:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc020456c:	601c                	ld	a5,0(s0)
ffffffffc020456e:	470d                	li	a4,3
ffffffffc0204570:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0204572:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204576:	100027f3          	csrr	a5,sstatus
ffffffffc020457a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020457c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020457e:	e3f9                	bnez	a5,ffffffffc0204644 <do_exit+0x13c>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc0204580:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204582:	800007b7          	lui	a5,0x80000
ffffffffc0204586:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0204588:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020458a:	0ec52703          	lw	a4,236(a0)
ffffffffc020458e:	0af70f63          	beq	a4,a5,ffffffffc020464c <do_exit+0x144>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc0204592:	6018                	ld	a4,0(s0)
ffffffffc0204594:	7b7c                	ld	a5,240(a4)
ffffffffc0204596:	c3a1                	beqz	a5,ffffffffc02045d6 <do_exit+0xce>
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204598:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc020459c:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc020459e:	0985                	addi	s3,s3,1
ffffffffc02045a0:	a021                	j	ffffffffc02045a8 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc02045a2:	6018                	ld	a4,0(s0)
ffffffffc02045a4:	7b7c                	ld	a5,240(a4)
ffffffffc02045a6:	cb85                	beqz	a5,ffffffffc02045d6 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc02045a8:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff39d8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02045ac:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02045ae:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02045b0:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02045b2:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02045b6:	10e7b023          	sd	a4,256(a5)
ffffffffc02045ba:	c311                	beqz	a4,ffffffffc02045be <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc02045bc:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02045be:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02045c0:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02045c2:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02045c4:	fd271fe3          	bne	a4,s2,ffffffffc02045a2 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02045c8:	0ec52783          	lw	a5,236(a0)
ffffffffc02045cc:	fd379be3          	bne	a5,s3,ffffffffc02045a2 <do_exit+0x9a>
                {
                    wakeup_proc(initproc);
ffffffffc02045d0:	453000ef          	jal	ra,ffffffffc0205222 <wakeup_proc>
ffffffffc02045d4:	b7f9                	j	ffffffffc02045a2 <do_exit+0x9a>
    if (flag)
ffffffffc02045d6:	020a1263          	bnez	s4,ffffffffc02045fa <do_exit+0xf2>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc02045da:	4fb000ef          	jal	ra,ffffffffc02052d4 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02045de:	601c                	ld	a5,0(s0)
ffffffffc02045e0:	00003617          	auipc	a2,0x3
ffffffffc02045e4:	ca860613          	addi	a2,a2,-856 # ffffffffc0207288 <default_pmm_manager+0x6a0>
ffffffffc02045e8:	21500593          	li	a1,533
ffffffffc02045ec:	43d4                	lw	a3,4(a5)
ffffffffc02045ee:	00003517          	auipc	a0,0x3
ffffffffc02045f2:	c6250513          	addi	a0,a0,-926 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc02045f6:	c2dfb0ef          	jal	ra,ffffffffc0200222 <__panic>
        intr_enable();
ffffffffc02045fa:	bb4fc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02045fe:	bff1                	j	ffffffffc02045da <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc0204600:	00003617          	auipc	a2,0x3
ffffffffc0204604:	c6860613          	addi	a2,a2,-920 # ffffffffc0207268 <default_pmm_manager+0x680>
ffffffffc0204608:	1e100593          	li	a1,481
ffffffffc020460c:	00003517          	auipc	a0,0x3
ffffffffc0204610:	c4450513          	addi	a0,a0,-956 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204614:	c0ffb0ef          	jal	ra,ffffffffc0200222 <__panic>
            exit_mmap(mm);
ffffffffc0204618:	854e                	mv	a0,s3
ffffffffc020461a:	ebdfc0ef          	jal	ra,ffffffffc02014d6 <exit_mmap>
            put_pgdir(mm);
ffffffffc020461e:	854e                	mv	a0,s3
ffffffffc0204620:	9d9ff0ef          	jal	ra,ffffffffc0203ff8 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204624:	854e                	mv	a0,s3
ffffffffc0204626:	d15fc0ef          	jal	ra,ffffffffc020133a <mm_destroy>
ffffffffc020462a:	bf35                	j	ffffffffc0204566 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020462c:	00003617          	auipc	a2,0x3
ffffffffc0204630:	c4c60613          	addi	a2,a2,-948 # ffffffffc0207278 <default_pmm_manager+0x690>
ffffffffc0204634:	1e500593          	li	a1,485
ffffffffc0204638:	00003517          	auipc	a0,0x3
ffffffffc020463c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204640:	be3fb0ef          	jal	ra,ffffffffc0200222 <__panic>
        intr_disable();
ffffffffc0204644:	b70fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0204648:	4a05                	li	s4,1
ffffffffc020464a:	bf1d                	j	ffffffffc0204580 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020464c:	3d7000ef          	jal	ra,ffffffffc0205222 <wakeup_proc>
ffffffffc0204650:	b789                	j	ffffffffc0204592 <do_exit+0x8a>

ffffffffc0204652 <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc0204652:	715d                	addi	sp,sp,-80
ffffffffc0204654:	f84a                	sd	s2,48(sp)
ffffffffc0204656:	f44e                	sd	s3,40(sp)
        }
    }
    if (haskid)
    {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
ffffffffc0204658:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc020465c:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc020465e:	fc26                	sd	s1,56(sp)
ffffffffc0204660:	f052                	sd	s4,32(sp)
ffffffffc0204662:	ec56                	sd	s5,24(sp)
ffffffffc0204664:	e85a                	sd	s6,16(sp)
ffffffffc0204666:	e45e                	sd	s7,8(sp)
ffffffffc0204668:	e486                	sd	ra,72(sp)
ffffffffc020466a:	e0a2                	sd	s0,64(sp)
ffffffffc020466c:	84aa                	mv	s1,a0
ffffffffc020466e:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0204670:	000c2b97          	auipc	s7,0xc2
ffffffffc0204674:	700b8b93          	addi	s7,s7,1792 # ffffffffc02c6d70 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204678:	00050b1b          	sext.w	s6,a0
ffffffffc020467c:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0204680:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0204682:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc0204684:	ccbd                	beqz	s1,ffffffffc0204702 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204686:	0359e863          	bltu	s3,s5,ffffffffc02046b6 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020468a:	45a9                	li	a1,10
ffffffffc020468c:	855a                	mv	a0,s6
ffffffffc020468e:	342010ef          	jal	ra,ffffffffc02059d0 <hash32>
ffffffffc0204692:	02051793          	slli	a5,a0,0x20
ffffffffc0204696:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020469a:	000be797          	auipc	a5,0xbe
ffffffffc020469e:	63678793          	addi	a5,a5,1590 # ffffffffc02c2cd0 <hash_list>
ffffffffc02046a2:	953e                	add	a0,a0,a5
ffffffffc02046a4:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc02046a6:	a029                	j	ffffffffc02046b0 <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc02046a8:	f2c42783          	lw	a5,-212(s0)
ffffffffc02046ac:	02978163          	beq	a5,s1,ffffffffc02046ce <do_wait.part.0+0x7c>
ffffffffc02046b0:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc02046b2:	fe851be3          	bne	a0,s0,ffffffffc02046a8 <do_wait.part.0+0x56>
        {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;
ffffffffc02046b6:	5579                	li	a0,-2
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc02046b8:	60a6                	ld	ra,72(sp)
ffffffffc02046ba:	6406                	ld	s0,64(sp)
ffffffffc02046bc:	74e2                	ld	s1,56(sp)
ffffffffc02046be:	7942                	ld	s2,48(sp)
ffffffffc02046c0:	79a2                	ld	s3,40(sp)
ffffffffc02046c2:	7a02                	ld	s4,32(sp)
ffffffffc02046c4:	6ae2                	ld	s5,24(sp)
ffffffffc02046c6:	6b42                	ld	s6,16(sp)
ffffffffc02046c8:	6ba2                	ld	s7,8(sp)
ffffffffc02046ca:	6161                	addi	sp,sp,80
ffffffffc02046cc:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02046ce:	000bb683          	ld	a3,0(s7)
ffffffffc02046d2:	f4843783          	ld	a5,-184(s0)
ffffffffc02046d6:	fed790e3          	bne	a5,a3,ffffffffc02046b6 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046da:	f2842703          	lw	a4,-216(s0)
ffffffffc02046de:	478d                	li	a5,3
ffffffffc02046e0:	0ef70b63          	beq	a4,a5,ffffffffc02047d6 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02046e4:	4785                	li	a5,1
ffffffffc02046e6:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02046e8:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02046ec:	3e9000ef          	jal	ra,ffffffffc02052d4 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02046f0:	000bb783          	ld	a5,0(s7)
ffffffffc02046f4:	0b07a783          	lw	a5,176(a5)
ffffffffc02046f8:	8b85                	andi	a5,a5,1
ffffffffc02046fa:	d7c9                	beqz	a5,ffffffffc0204684 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02046fc:	555d                	li	a0,-9
ffffffffc02046fe:	e0bff0ef          	jal	ra,ffffffffc0204508 <do_exit>
        proc = current->cptr;
ffffffffc0204702:	000bb683          	ld	a3,0(s7)
ffffffffc0204706:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204708:	d45d                	beqz	s0,ffffffffc02046b6 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020470a:	470d                	li	a4,3
ffffffffc020470c:	a021                	j	ffffffffc0204714 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020470e:	10043403          	ld	s0,256(s0)
ffffffffc0204712:	d869                	beqz	s0,ffffffffc02046e4 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204714:	401c                	lw	a5,0(s0)
ffffffffc0204716:	fee79ce3          	bne	a5,a4,ffffffffc020470e <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc020471a:	000c2797          	auipc	a5,0xc2
ffffffffc020471e:	65e7b783          	ld	a5,1630(a5) # ffffffffc02c6d78 <idleproc>
ffffffffc0204722:	0c878963          	beq	a5,s0,ffffffffc02047f4 <do_wait.part.0+0x1a2>
ffffffffc0204726:	000c2797          	auipc	a5,0xc2
ffffffffc020472a:	65a7b783          	ld	a5,1626(a5) # ffffffffc02c6d80 <initproc>
ffffffffc020472e:	0cf40363          	beq	s0,a5,ffffffffc02047f4 <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc0204732:	000a0663          	beqz	s4,ffffffffc020473e <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0204736:	0e842783          	lw	a5,232(s0)
ffffffffc020473a:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8f60>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020473e:	100027f3          	csrr	a5,sstatus
ffffffffc0204742:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204744:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204746:	e7c1                	bnez	a5,ffffffffc02047ce <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204748:	6c70                	ld	a2,216(s0)
ffffffffc020474a:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc020474c:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0204750:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0204752:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0204754:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204756:	6470                	ld	a2,200(s0)
ffffffffc0204758:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020475a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020475c:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc020475e:	c319                	beqz	a4,ffffffffc0204764 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0204760:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc0204762:	7c7c                	ld	a5,248(s0)
ffffffffc0204764:	c3b5                	beqz	a5,ffffffffc02047c8 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0204766:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc020476a:	000c2717          	auipc	a4,0xc2
ffffffffc020476e:	61e70713          	addi	a4,a4,1566 # ffffffffc02c6d88 <nr_process>
ffffffffc0204772:	431c                	lw	a5,0(a4)
ffffffffc0204774:	37fd                	addiw	a5,a5,-1
ffffffffc0204776:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc0204778:	e5a9                	bnez	a1,ffffffffc02047c2 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020477a:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020477c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204780:	04f6ee63          	bltu	a3,a5,ffffffffc02047dc <do_wait.part.0+0x18a>
ffffffffc0204784:	000c2797          	auipc	a5,0xc2
ffffffffc0204788:	5e47b783          	ld	a5,1508(a5) # ffffffffc02c6d68 <va_pa_offset>
ffffffffc020478c:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc020478e:	82b1                	srli	a3,a3,0xc
ffffffffc0204790:	000c2797          	auipc	a5,0xc2
ffffffffc0204794:	5c07b783          	ld	a5,1472(a5) # ffffffffc02c6d50 <npage>
ffffffffc0204798:	06f6fa63          	bgeu	a3,a5,ffffffffc020480c <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020479c:	00004517          	auipc	a0,0x4
ffffffffc02047a0:	abc53503          	ld	a0,-1348(a0) # ffffffffc0208258 <nbase>
ffffffffc02047a4:	8e89                	sub	a3,a3,a0
ffffffffc02047a6:	069a                	slli	a3,a3,0x6
ffffffffc02047a8:	000c2517          	auipc	a0,0xc2
ffffffffc02047ac:	5b053503          	ld	a0,1456(a0) # ffffffffc02c6d58 <pages>
ffffffffc02047b0:	9536                	add	a0,a0,a3
ffffffffc02047b2:	4589                	li	a1,2
ffffffffc02047b4:	84cfe0ef          	jal	ra,ffffffffc0202800 <free_pages>
    kfree(proc);
ffffffffc02047b8:	8522                	mv	a0,s0
ffffffffc02047ba:	c2cfd0ef          	jal	ra,ffffffffc0201be6 <kfree>
    return 0;
ffffffffc02047be:	4501                	li	a0,0
ffffffffc02047c0:	bde5                	j	ffffffffc02046b8 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02047c2:	9ecfc0ef          	jal	ra,ffffffffc02009ae <intr_enable>
ffffffffc02047c6:	bf55                	j	ffffffffc020477a <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc02047c8:	701c                	ld	a5,32(s0)
ffffffffc02047ca:	fbf8                	sd	a4,240(a5)
ffffffffc02047cc:	bf79                	j	ffffffffc020476a <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02047ce:	9e6fc0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc02047d2:	4585                	li	a1,1
ffffffffc02047d4:	bf95                	j	ffffffffc0204748 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02047d6:	f2840413          	addi	s0,s0,-216
ffffffffc02047da:	b781                	j	ffffffffc020471a <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02047dc:	00002617          	auipc	a2,0x2
ffffffffc02047e0:	03c60613          	addi	a2,a2,60 # ffffffffc0206818 <commands+0xb88>
ffffffffc02047e4:	07700593          	li	a1,119
ffffffffc02047e8:	00002517          	auipc	a0,0x2
ffffffffc02047ec:	c5050513          	addi	a0,a0,-944 # ffffffffc0206438 <commands+0x7a8>
ffffffffc02047f0:	a33fb0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02047f4:	00003617          	auipc	a2,0x3
ffffffffc02047f8:	ab460613          	addi	a2,a2,-1356 # ffffffffc02072a8 <default_pmm_manager+0x6c0>
ffffffffc02047fc:	32e00593          	li	a1,814
ffffffffc0204800:	00003517          	auipc	a0,0x3
ffffffffc0204804:	a5050513          	addi	a0,a0,-1456 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204808:	a1bfb0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020480c:	00002617          	auipc	a2,0x2
ffffffffc0204810:	c3c60613          	addi	a2,a2,-964 # ffffffffc0206448 <commands+0x7b8>
ffffffffc0204814:	06900593          	li	a1,105
ffffffffc0204818:	00002517          	auipc	a0,0x2
ffffffffc020481c:	c2050513          	addi	a0,a0,-992 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0204820:	a03fb0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0204824 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204824:	1141                	addi	sp,sp,-16
ffffffffc0204826:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204828:	818fe0ef          	jal	ra,ffffffffc0202840 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020482c:	b06fd0ef          	jal	ra,ffffffffc0201b32 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204830:	4601                	li	a2,0
ffffffffc0204832:	4581                	li	a1,0
ffffffffc0204834:	00000517          	auipc	a0,0x0
ffffffffc0204838:	62850513          	addi	a0,a0,1576 # ffffffffc0204e5c <user_main>
ffffffffc020483c:	c7dff0ef          	jal	ra,ffffffffc02044b8 <kernel_thread>
    if (pid <= 0)
ffffffffc0204840:	00a04563          	bgtz	a0,ffffffffc020484a <init_main+0x26>
ffffffffc0204844:	a071                	j	ffffffffc02048d0 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204846:	28f000ef          	jal	ra,ffffffffc02052d4 <schedule>
    if (code_store != NULL)
ffffffffc020484a:	4581                	li	a1,0
ffffffffc020484c:	4501                	li	a0,0
ffffffffc020484e:	e05ff0ef          	jal	ra,ffffffffc0204652 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204852:	d975                	beqz	a0,ffffffffc0204846 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204854:	00003517          	auipc	a0,0x3
ffffffffc0204858:	a9450513          	addi	a0,a0,-1388 # ffffffffc02072e8 <default_pmm_manager+0x700>
ffffffffc020485c:	889fb0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204860:	000c2797          	auipc	a5,0xc2
ffffffffc0204864:	5207b783          	ld	a5,1312(a5) # ffffffffc02c6d80 <initproc>
ffffffffc0204868:	7bf8                	ld	a4,240(a5)
ffffffffc020486a:	e339                	bnez	a4,ffffffffc02048b0 <init_main+0x8c>
ffffffffc020486c:	7ff8                	ld	a4,248(a5)
ffffffffc020486e:	e329                	bnez	a4,ffffffffc02048b0 <init_main+0x8c>
ffffffffc0204870:	1007b703          	ld	a4,256(a5)
ffffffffc0204874:	ef15                	bnez	a4,ffffffffc02048b0 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204876:	000c2697          	auipc	a3,0xc2
ffffffffc020487a:	5126a683          	lw	a3,1298(a3) # ffffffffc02c6d88 <nr_process>
ffffffffc020487e:	4709                	li	a4,2
ffffffffc0204880:	0ae69463          	bne	a3,a4,ffffffffc0204928 <init_main+0x104>
    return listelm->next;
ffffffffc0204884:	000c2697          	auipc	a3,0xc2
ffffffffc0204888:	44c68693          	addi	a3,a3,1100 # ffffffffc02c6cd0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020488c:	6698                	ld	a4,8(a3)
ffffffffc020488e:	0c878793          	addi	a5,a5,200
ffffffffc0204892:	06f71b63          	bne	a4,a5,ffffffffc0204908 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204896:	629c                	ld	a5,0(a3)
ffffffffc0204898:	04f71863          	bne	a4,a5,ffffffffc02048e8 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020489c:	00003517          	auipc	a0,0x3
ffffffffc02048a0:	b3450513          	addi	a0,a0,-1228 # ffffffffc02073d0 <default_pmm_manager+0x7e8>
ffffffffc02048a4:	841fb0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    return 0;
}
ffffffffc02048a8:	60a2                	ld	ra,8(sp)
ffffffffc02048aa:	4501                	li	a0,0
ffffffffc02048ac:	0141                	addi	sp,sp,16
ffffffffc02048ae:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02048b0:	00003697          	auipc	a3,0x3
ffffffffc02048b4:	a6068693          	addi	a3,a3,-1440 # ffffffffc0207310 <default_pmm_manager+0x728>
ffffffffc02048b8:	00002617          	auipc	a2,0x2
ffffffffc02048bc:	c7860613          	addi	a2,a2,-904 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02048c0:	39a00593          	li	a1,922
ffffffffc02048c4:	00003517          	auipc	a0,0x3
ffffffffc02048c8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc02048cc:	957fb0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("create user_main failed.\n");
ffffffffc02048d0:	00003617          	auipc	a2,0x3
ffffffffc02048d4:	9f860613          	addi	a2,a2,-1544 # ffffffffc02072c8 <default_pmm_manager+0x6e0>
ffffffffc02048d8:	39100593          	li	a1,913
ffffffffc02048dc:	00003517          	auipc	a0,0x3
ffffffffc02048e0:	97450513          	addi	a0,a0,-1676 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc02048e4:	93ffb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02048e8:	00003697          	auipc	a3,0x3
ffffffffc02048ec:	ab868693          	addi	a3,a3,-1352 # ffffffffc02073a0 <default_pmm_manager+0x7b8>
ffffffffc02048f0:	00002617          	auipc	a2,0x2
ffffffffc02048f4:	c4060613          	addi	a2,a2,-960 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02048f8:	39d00593          	li	a1,925
ffffffffc02048fc:	00003517          	auipc	a0,0x3
ffffffffc0204900:	95450513          	addi	a0,a0,-1708 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204904:	91ffb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204908:	00003697          	auipc	a3,0x3
ffffffffc020490c:	a6868693          	addi	a3,a3,-1432 # ffffffffc0207370 <default_pmm_manager+0x788>
ffffffffc0204910:	00002617          	auipc	a2,0x2
ffffffffc0204914:	c2060613          	addi	a2,a2,-992 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204918:	39c00593          	li	a1,924
ffffffffc020491c:	00003517          	auipc	a0,0x3
ffffffffc0204920:	93450513          	addi	a0,a0,-1740 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204924:	8fffb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(nr_process == 2);
ffffffffc0204928:	00003697          	auipc	a3,0x3
ffffffffc020492c:	a3868693          	addi	a3,a3,-1480 # ffffffffc0207360 <default_pmm_manager+0x778>
ffffffffc0204930:	00002617          	auipc	a2,0x2
ffffffffc0204934:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204938:	39b00593          	li	a1,923
ffffffffc020493c:	00003517          	auipc	a0,0x3
ffffffffc0204940:	91450513          	addi	a0,a0,-1772 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204944:	8dffb0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0204948 <do_execve>:
{
ffffffffc0204948:	7171                	addi	sp,sp,-176
ffffffffc020494a:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020494c:	000c2d97          	auipc	s11,0xc2
ffffffffc0204950:	424d8d93          	addi	s11,s11,1060 # ffffffffc02c6d70 <current>
ffffffffc0204954:	000db783          	ld	a5,0(s11)
{
ffffffffc0204958:	e54e                	sd	s3,136(sp)
ffffffffc020495a:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020495c:	0287b983          	ld	s3,40(a5)
{
ffffffffc0204960:	e94a                	sd	s2,144(sp)
ffffffffc0204962:	f4de                	sd	s7,104(sp)
ffffffffc0204964:	892a                	mv	s2,a0
ffffffffc0204966:	8bb2                	mv	s7,a2
ffffffffc0204968:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020496a:	862e                	mv	a2,a1
ffffffffc020496c:	4681                	li	a3,0
ffffffffc020496e:	85aa                	mv	a1,a0
ffffffffc0204970:	854e                	mv	a0,s3
{
ffffffffc0204972:	f506                	sd	ra,168(sp)
ffffffffc0204974:	f122                	sd	s0,160(sp)
ffffffffc0204976:	e152                	sd	s4,128(sp)
ffffffffc0204978:	fcd6                	sd	s5,120(sp)
ffffffffc020497a:	f8da                	sd	s6,112(sp)
ffffffffc020497c:	f0e2                	sd	s8,96(sp)
ffffffffc020497e:	ece6                	sd	s9,88(sp)
ffffffffc0204980:	e8ea                	sd	s10,80(sp)
ffffffffc0204982:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204984:	eedfc0ef          	jal	ra,ffffffffc0201870 <user_mem_check>
ffffffffc0204988:	40050a63          	beqz	a0,ffffffffc0204d9c <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020498c:	4641                	li	a2,16
ffffffffc020498e:	4581                	li	a1,0
ffffffffc0204990:	1808                	addi	a0,sp,48
ffffffffc0204992:	427000ef          	jal	ra,ffffffffc02055b8 <memset>
    memcpy(local_name, name, len);
ffffffffc0204996:	47bd                	li	a5,15
ffffffffc0204998:	8626                	mv	a2,s1
ffffffffc020499a:	1e97e263          	bltu	a5,s1,ffffffffc0204b7e <do_execve+0x236>
ffffffffc020499e:	85ca                	mv	a1,s2
ffffffffc02049a0:	1808                	addi	a0,sp,48
ffffffffc02049a2:	429000ef          	jal	ra,ffffffffc02055ca <memcpy>
    if (mm != NULL)
ffffffffc02049a6:	1e098363          	beqz	s3,ffffffffc0204b8c <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc02049aa:	00002517          	auipc	a0,0x2
ffffffffc02049ae:	c2650513          	addi	a0,a0,-986 # ffffffffc02065d0 <commands+0x940>
ffffffffc02049b2:	f6cfb0ef          	jal	ra,ffffffffc020011e <cputs>
ffffffffc02049b6:	000c2797          	auipc	a5,0xc2
ffffffffc02049ba:	38a7b783          	ld	a5,906(a5) # ffffffffc02c6d40 <boot_pgdir_pa>
ffffffffc02049be:	577d                	li	a4,-1
ffffffffc02049c0:	177e                	slli	a4,a4,0x3f
ffffffffc02049c2:	83b1                	srli	a5,a5,0xc
ffffffffc02049c4:	8fd9                	or	a5,a5,a4
ffffffffc02049c6:	18079073          	csrw	satp,a5
ffffffffc02049ca:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7f30>
ffffffffc02049ce:	fff7871b          	addiw	a4,a5,-1
ffffffffc02049d2:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02049d6:	2c070463          	beqz	a4,ffffffffc0204c9e <do_execve+0x356>
        current->mm = NULL;
ffffffffc02049da:	000db783          	ld	a5,0(s11)
ffffffffc02049de:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02049e2:	819fc0ef          	jal	ra,ffffffffc02011fa <mm_create>
ffffffffc02049e6:	84aa                	mv	s1,a0
ffffffffc02049e8:	1c050d63          	beqz	a0,ffffffffc0204bc2 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc02049ec:	4505                	li	a0,1
ffffffffc02049ee:	dd5fd0ef          	jal	ra,ffffffffc02027c2 <alloc_pages>
ffffffffc02049f2:	3a050963          	beqz	a0,ffffffffc0204da4 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc02049f6:	000c2c97          	auipc	s9,0xc2
ffffffffc02049fa:	362c8c93          	addi	s9,s9,866 # ffffffffc02c6d58 <pages>
ffffffffc02049fe:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204a02:	000c2c17          	auipc	s8,0xc2
ffffffffc0204a06:	34ec0c13          	addi	s8,s8,846 # ffffffffc02c6d50 <npage>
    return page - pages + nbase;
ffffffffc0204a0a:	00004717          	auipc	a4,0x4
ffffffffc0204a0e:	84e73703          	ld	a4,-1970(a4) # ffffffffc0208258 <nbase>
ffffffffc0204a12:	40d506b3          	sub	a3,a0,a3
ffffffffc0204a16:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204a18:	5afd                	li	s5,-1
ffffffffc0204a1a:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204a1e:	96ba                	add	a3,a3,a4
ffffffffc0204a20:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204a22:	00cad713          	srli	a4,s5,0xc
ffffffffc0204a26:	ec3a                	sd	a4,24(sp)
ffffffffc0204a28:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a2a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a2c:	38f77063          	bgeu	a4,a5,ffffffffc0204dac <do_execve+0x464>
ffffffffc0204a30:	000c2b17          	auipc	s6,0xc2
ffffffffc0204a34:	338b0b13          	addi	s6,s6,824 # ffffffffc02c6d68 <va_pa_offset>
ffffffffc0204a38:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204a3c:	6605                	lui	a2,0x1
ffffffffc0204a3e:	000c2597          	auipc	a1,0xc2
ffffffffc0204a42:	30a5b583          	ld	a1,778(a1) # ffffffffc02c6d48 <boot_pgdir_va>
ffffffffc0204a46:	9936                	add	s2,s2,a3
ffffffffc0204a48:	854a                	mv	a0,s2
ffffffffc0204a4a:	381000ef          	jal	ra,ffffffffc02055ca <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204a4e:	7782                	ld	a5,32(sp)
ffffffffc0204a50:	4398                	lw	a4,0(a5)
ffffffffc0204a52:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204a56:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204a5a:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b7e57>
ffffffffc0204a5e:	14f71863          	bne	a4,a5,ffffffffc0204bae <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a62:	7682                	ld	a3,32(sp)
ffffffffc0204a64:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204a68:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a6c:	00371793          	slli	a5,a4,0x3
ffffffffc0204a70:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204a72:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204a74:	078e                	slli	a5,a5,0x3
ffffffffc0204a76:	97ce                	add	a5,a5,s3
ffffffffc0204a78:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204a7a:	00f9fc63          	bgeu	s3,a5,ffffffffc0204a92 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204a7e:	0009a783          	lw	a5,0(s3)
ffffffffc0204a82:	4705                	li	a4,1
ffffffffc0204a84:	14e78163          	beq	a5,a4,ffffffffc0204bc6 <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc0204a88:	77a2                	ld	a5,40(sp)
ffffffffc0204a8a:	03898993          	addi	s3,s3,56
ffffffffc0204a8e:	fef9e8e3          	bltu	s3,a5,ffffffffc0204a7e <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204a92:	4701                	li	a4,0
ffffffffc0204a94:	46ad                	li	a3,11
ffffffffc0204a96:	00100637          	lui	a2,0x100
ffffffffc0204a9a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204a9e:	8526                	mv	a0,s1
ffffffffc0204aa0:	8edfc0ef          	jal	ra,ffffffffc020138c <mm_map>
ffffffffc0204aa4:	8a2a                	mv	s4,a0
ffffffffc0204aa6:	1e051263          	bnez	a0,ffffffffc0204c8a <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204aaa:	6c88                	ld	a0,24(s1)
ffffffffc0204aac:	467d                	li	a2,31
ffffffffc0204aae:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204ab2:	b6aff0ef          	jal	ra,ffffffffc0203e1c <pgdir_alloc_page>
ffffffffc0204ab6:	38050363          	beqz	a0,ffffffffc0204e3c <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204aba:	6c88                	ld	a0,24(s1)
ffffffffc0204abc:	467d                	li	a2,31
ffffffffc0204abe:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204ac2:	b5aff0ef          	jal	ra,ffffffffc0203e1c <pgdir_alloc_page>
ffffffffc0204ac6:	34050b63          	beqz	a0,ffffffffc0204e1c <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204aca:	6c88                	ld	a0,24(s1)
ffffffffc0204acc:	467d                	li	a2,31
ffffffffc0204ace:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204ad2:	b4aff0ef          	jal	ra,ffffffffc0203e1c <pgdir_alloc_page>
ffffffffc0204ad6:	32050363          	beqz	a0,ffffffffc0204dfc <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ada:	6c88                	ld	a0,24(s1)
ffffffffc0204adc:	467d                	li	a2,31
ffffffffc0204ade:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204ae2:	b3aff0ef          	jal	ra,ffffffffc0203e1c <pgdir_alloc_page>
ffffffffc0204ae6:	2e050b63          	beqz	a0,ffffffffc0204ddc <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204aea:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204aec:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204af0:	6c94                	ld	a3,24(s1)
ffffffffc0204af2:	2785                	addiw	a5,a5,1
ffffffffc0204af4:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204af6:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204af8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204afc:	2cf6e463          	bltu	a3,a5,ffffffffc0204dc4 <do_execve+0x47c>
ffffffffc0204b00:	000b3783          	ld	a5,0(s6)
ffffffffc0204b04:	577d                	li	a4,-1
ffffffffc0204b06:	177e                	slli	a4,a4,0x3f
ffffffffc0204b08:	8e9d                	sub	a3,a3,a5
ffffffffc0204b0a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204b0e:	f654                	sd	a3,168(a2)
ffffffffc0204b10:	8fd9                	or	a5,a5,a4
ffffffffc0204b12:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204b16:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204b18:	4581                	li	a1,0
ffffffffc0204b1a:	12000613          	li	a2,288
ffffffffc0204b1e:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204b20:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204b24:	295000ef          	jal	ra,ffffffffc02055b8 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204b28:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b2a:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204b2e:	edd4f493          	andi	s1,s1,-291
    tf->epc = elf->e_entry;
ffffffffc0204b32:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b34:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b36:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_matrix_out_size+0xffffffff7fff398c>
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b3a:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204b3c:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b40:	4641                	li	a2,16
ffffffffc0204b42:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b44:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0204b46:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204b4a:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b4e:	854a                	mv	a0,s2
ffffffffc0204b50:	269000ef          	jal	ra,ffffffffc02055b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204b54:	463d                	li	a2,15
ffffffffc0204b56:	180c                	addi	a1,sp,48
ffffffffc0204b58:	854a                	mv	a0,s2
ffffffffc0204b5a:	271000ef          	jal	ra,ffffffffc02055ca <memcpy>
}
ffffffffc0204b5e:	70aa                	ld	ra,168(sp)
ffffffffc0204b60:	740a                	ld	s0,160(sp)
ffffffffc0204b62:	64ea                	ld	s1,152(sp)
ffffffffc0204b64:	694a                	ld	s2,144(sp)
ffffffffc0204b66:	69aa                	ld	s3,136(sp)
ffffffffc0204b68:	7ae6                	ld	s5,120(sp)
ffffffffc0204b6a:	7b46                	ld	s6,112(sp)
ffffffffc0204b6c:	7ba6                	ld	s7,104(sp)
ffffffffc0204b6e:	7c06                	ld	s8,96(sp)
ffffffffc0204b70:	6ce6                	ld	s9,88(sp)
ffffffffc0204b72:	6d46                	ld	s10,80(sp)
ffffffffc0204b74:	6da6                	ld	s11,72(sp)
ffffffffc0204b76:	8552                	mv	a0,s4
ffffffffc0204b78:	6a0a                	ld	s4,128(sp)
ffffffffc0204b7a:	614d                	addi	sp,sp,176
ffffffffc0204b7c:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204b7e:	463d                	li	a2,15
ffffffffc0204b80:	85ca                	mv	a1,s2
ffffffffc0204b82:	1808                	addi	a0,sp,48
ffffffffc0204b84:	247000ef          	jal	ra,ffffffffc02055ca <memcpy>
    if (mm != NULL)
ffffffffc0204b88:	e20991e3          	bnez	s3,ffffffffc02049aa <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204b8c:	000db783          	ld	a5,0(s11)
ffffffffc0204b90:	779c                	ld	a5,40(a5)
ffffffffc0204b92:	e40788e3          	beqz	a5,ffffffffc02049e2 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204b96:	00003617          	auipc	a2,0x3
ffffffffc0204b9a:	85a60613          	addi	a2,a2,-1958 # ffffffffc02073f0 <default_pmm_manager+0x808>
ffffffffc0204b9e:	22100593          	li	a1,545
ffffffffc0204ba2:	00002517          	auipc	a0,0x2
ffffffffc0204ba6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204baa:	e78fb0ef          	jal	ra,ffffffffc0200222 <__panic>
    put_pgdir(mm);
ffffffffc0204bae:	8526                	mv	a0,s1
ffffffffc0204bb0:	c48ff0ef          	jal	ra,ffffffffc0203ff8 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204bb4:	8526                	mv	a0,s1
ffffffffc0204bb6:	f84fc0ef          	jal	ra,ffffffffc020133a <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204bba:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204bbc:	8552                	mv	a0,s4
ffffffffc0204bbe:	94bff0ef          	jal	ra,ffffffffc0204508 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204bc2:	5a71                	li	s4,-4
ffffffffc0204bc4:	bfe5                	j	ffffffffc0204bbc <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204bc6:	0289b603          	ld	a2,40(s3)
ffffffffc0204bca:	0209b783          	ld	a5,32(s3)
ffffffffc0204bce:	1cf66d63          	bltu	a2,a5,ffffffffc0204da8 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204bd2:	0049a783          	lw	a5,4(s3)
ffffffffc0204bd6:	0017f693          	andi	a3,a5,1
ffffffffc0204bda:	c291                	beqz	a3,ffffffffc0204bde <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc0204bdc:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204bde:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204be2:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204be4:	e779                	bnez	a4,ffffffffc0204cb2 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204be6:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204be8:	c781                	beqz	a5,ffffffffc0204bf0 <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc0204bea:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204bee:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc0204bf0:	0026f793          	andi	a5,a3,2
ffffffffc0204bf4:	e3f1                	bnez	a5,ffffffffc0204cb8 <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc0204bf6:	0046f793          	andi	a5,a3,4
ffffffffc0204bfa:	c399                	beqz	a5,ffffffffc0204c00 <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc0204bfc:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204c00:	0109b583          	ld	a1,16(s3)
ffffffffc0204c04:	4701                	li	a4,0
ffffffffc0204c06:	8526                	mv	a0,s1
ffffffffc0204c08:	f84fc0ef          	jal	ra,ffffffffc020138c <mm_map>
ffffffffc0204c0c:	8a2a                	mv	s4,a0
ffffffffc0204c0e:	ed35                	bnez	a0,ffffffffc0204c8a <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204c10:	0109bb83          	ld	s7,16(s3)
ffffffffc0204c14:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204c16:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204c1a:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204c1e:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204c22:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204c24:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204c26:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc0204c28:	054be963          	bltu	s7,s4,ffffffffc0204c7a <do_execve+0x332>
ffffffffc0204c2c:	aa95                	j	ffffffffc0204da0 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204c2e:	6785                	lui	a5,0x1
ffffffffc0204c30:	415b8533          	sub	a0,s7,s5
ffffffffc0204c34:	9abe                	add	s5,s5,a5
ffffffffc0204c36:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204c3a:	015a7463          	bgeu	s4,s5,ffffffffc0204c42 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204c3e:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0204c42:	000cb683          	ld	a3,0(s9)
ffffffffc0204c46:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204c48:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204c4c:	40d406b3          	sub	a3,s0,a3
ffffffffc0204c50:	8699                	srai	a3,a3,0x6
ffffffffc0204c52:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204c54:	67e2                	ld	a5,24(sp)
ffffffffc0204c56:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c5a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c5c:	14b87863          	bgeu	a6,a1,ffffffffc0204dac <do_execve+0x464>
ffffffffc0204c60:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c64:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204c66:	9bb2                	add	s7,s7,a2
ffffffffc0204c68:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c6a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204c6c:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204c6e:	15d000ef          	jal	ra,ffffffffc02055ca <memcpy>
            start += size, from += size;
ffffffffc0204c72:	6622                	ld	a2,8(sp)
ffffffffc0204c74:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204c76:	054bf363          	bgeu	s7,s4,ffffffffc0204cbc <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204c7a:	6c88                	ld	a0,24(s1)
ffffffffc0204c7c:	866a                	mv	a2,s10
ffffffffc0204c7e:	85d6                	mv	a1,s5
ffffffffc0204c80:	99cff0ef          	jal	ra,ffffffffc0203e1c <pgdir_alloc_page>
ffffffffc0204c84:	842a                	mv	s0,a0
ffffffffc0204c86:	f545                	bnez	a0,ffffffffc0204c2e <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204c88:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204c8a:	8526                	mv	a0,s1
ffffffffc0204c8c:	84bfc0ef          	jal	ra,ffffffffc02014d6 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204c90:	8526                	mv	a0,s1
ffffffffc0204c92:	b66ff0ef          	jal	ra,ffffffffc0203ff8 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c96:	8526                	mv	a0,s1
ffffffffc0204c98:	ea2fc0ef          	jal	ra,ffffffffc020133a <mm_destroy>
    return ret;
ffffffffc0204c9c:	b705                	j	ffffffffc0204bbc <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204c9e:	854e                	mv	a0,s3
ffffffffc0204ca0:	837fc0ef          	jal	ra,ffffffffc02014d6 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204ca4:	854e                	mv	a0,s3
ffffffffc0204ca6:	b52ff0ef          	jal	ra,ffffffffc0203ff8 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204caa:	854e                	mv	a0,s3
ffffffffc0204cac:	e8efc0ef          	jal	ra,ffffffffc020133a <mm_destroy>
ffffffffc0204cb0:	b32d                	j	ffffffffc02049da <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204cb2:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204cb6:	fb95                	bnez	a5,ffffffffc0204bea <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204cb8:	4d5d                	li	s10,23
ffffffffc0204cba:	bf35                	j	ffffffffc0204bf6 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204cbc:	0109b683          	ld	a3,16(s3)
ffffffffc0204cc0:	0289b903          	ld	s2,40(s3)
ffffffffc0204cc4:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204cc6:	075bfd63          	bgeu	s7,s5,ffffffffc0204d40 <do_execve+0x3f8>
            if (start == end)
ffffffffc0204cca:	db790fe3          	beq	s2,s7,ffffffffc0204a88 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204cce:	6785                	lui	a5,0x1
ffffffffc0204cd0:	00fb8533          	add	a0,s7,a5
ffffffffc0204cd4:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204cd8:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204cdc:	0b597d63          	bgeu	s2,s5,ffffffffc0204d96 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204ce0:	000cb683          	ld	a3,0(s9)
ffffffffc0204ce4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204ce6:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204cea:	40d406b3          	sub	a3,s0,a3
ffffffffc0204cee:	8699                	srai	a3,a3,0x6
ffffffffc0204cf0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204cf2:	67e2                	ld	a5,24(sp)
ffffffffc0204cf4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cf8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cfa:	0ac5f963          	bgeu	a1,a2,ffffffffc0204dac <do_execve+0x464>
ffffffffc0204cfe:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d02:	8652                	mv	a2,s4
ffffffffc0204d04:	4581                	li	a1,0
ffffffffc0204d06:	96c2                	add	a3,a3,a6
ffffffffc0204d08:	9536                	add	a0,a0,a3
ffffffffc0204d0a:	0af000ef          	jal	ra,ffffffffc02055b8 <memset>
            start += size;
ffffffffc0204d0e:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204d12:	03597463          	bgeu	s2,s5,ffffffffc0204d3a <do_execve+0x3f2>
ffffffffc0204d16:	d6e909e3          	beq	s2,a4,ffffffffc0204a88 <do_execve+0x140>
ffffffffc0204d1a:	00002697          	auipc	a3,0x2
ffffffffc0204d1e:	6fe68693          	addi	a3,a3,1790 # ffffffffc0207418 <default_pmm_manager+0x830>
ffffffffc0204d22:	00002617          	auipc	a2,0x2
ffffffffc0204d26:	80e60613          	addi	a2,a2,-2034 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204d2a:	28a00593          	li	a1,650
ffffffffc0204d2e:	00002517          	auipc	a0,0x2
ffffffffc0204d32:	52250513          	addi	a0,a0,1314 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204d36:	cecfb0ef          	jal	ra,ffffffffc0200222 <__panic>
ffffffffc0204d3a:	ff5710e3          	bne	a4,s5,ffffffffc0204d1a <do_execve+0x3d2>
ffffffffc0204d3e:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204d40:	d52bf4e3          	bgeu	s7,s2,ffffffffc0204a88 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d44:	6c88                	ld	a0,24(s1)
ffffffffc0204d46:	866a                	mv	a2,s10
ffffffffc0204d48:	85d6                	mv	a1,s5
ffffffffc0204d4a:	8d2ff0ef          	jal	ra,ffffffffc0203e1c <pgdir_alloc_page>
ffffffffc0204d4e:	842a                	mv	s0,a0
ffffffffc0204d50:	dd05                	beqz	a0,ffffffffc0204c88 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d52:	6785                	lui	a5,0x1
ffffffffc0204d54:	415b8533          	sub	a0,s7,s5
ffffffffc0204d58:	9abe                	add	s5,s5,a5
ffffffffc0204d5a:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204d5e:	01597463          	bgeu	s2,s5,ffffffffc0204d66 <do_execve+0x41e>
                size -= la - end;
ffffffffc0204d62:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204d66:	000cb683          	ld	a3,0(s9)
ffffffffc0204d6a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204d6c:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204d70:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d74:	8699                	srai	a3,a3,0x6
ffffffffc0204d76:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204d78:	67e2                	ld	a5,24(sp)
ffffffffc0204d7a:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d7e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d80:	02b87663          	bgeu	a6,a1,ffffffffc0204dac <do_execve+0x464>
ffffffffc0204d84:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d88:	4581                	li	a1,0
            start += size;
ffffffffc0204d8a:	9bb2                	add	s7,s7,a2
ffffffffc0204d8c:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d8e:	9536                	add	a0,a0,a3
ffffffffc0204d90:	029000ef          	jal	ra,ffffffffc02055b8 <memset>
ffffffffc0204d94:	b775                	j	ffffffffc0204d40 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204d96:	417a8a33          	sub	s4,s5,s7
ffffffffc0204d9a:	b799                	j	ffffffffc0204ce0 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204d9c:	5a75                	li	s4,-3
ffffffffc0204d9e:	b3c1                	j	ffffffffc0204b5e <do_execve+0x216>
        while (start < end)
ffffffffc0204da0:	86de                	mv	a3,s7
ffffffffc0204da2:	bf39                	j	ffffffffc0204cc0 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204da4:	5a71                	li	s4,-4
ffffffffc0204da6:	bdc5                	j	ffffffffc0204c96 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204da8:	5a61                	li	s4,-8
ffffffffc0204daa:	b5c5                	j	ffffffffc0204c8a <do_execve+0x342>
ffffffffc0204dac:	00001617          	auipc	a2,0x1
ffffffffc0204db0:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206478 <commands+0x7e8>
ffffffffc0204db4:	07100593          	li	a1,113
ffffffffc0204db8:	00001517          	auipc	a0,0x1
ffffffffc0204dbc:	68050513          	addi	a0,a0,1664 # ffffffffc0206438 <commands+0x7a8>
ffffffffc0204dc0:	c62fb0ef          	jal	ra,ffffffffc0200222 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204dc4:	00002617          	auipc	a2,0x2
ffffffffc0204dc8:	a5460613          	addi	a2,a2,-1452 # ffffffffc0206818 <commands+0xb88>
ffffffffc0204dcc:	2a900593          	li	a1,681
ffffffffc0204dd0:	00002517          	auipc	a0,0x2
ffffffffc0204dd4:	48050513          	addi	a0,a0,1152 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204dd8:	c4afb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ddc:	00002697          	auipc	a3,0x2
ffffffffc0204de0:	75468693          	addi	a3,a3,1876 # ffffffffc0207530 <default_pmm_manager+0x948>
ffffffffc0204de4:	00001617          	auipc	a2,0x1
ffffffffc0204de8:	74c60613          	addi	a2,a2,1868 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204dec:	2a400593          	li	a1,676
ffffffffc0204df0:	00002517          	auipc	a0,0x2
ffffffffc0204df4:	46050513          	addi	a0,a0,1120 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204df8:	c2afb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204dfc:	00002697          	auipc	a3,0x2
ffffffffc0204e00:	6ec68693          	addi	a3,a3,1772 # ffffffffc02074e8 <default_pmm_manager+0x900>
ffffffffc0204e04:	00001617          	auipc	a2,0x1
ffffffffc0204e08:	72c60613          	addi	a2,a2,1836 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204e0c:	2a300593          	li	a1,675
ffffffffc0204e10:	00002517          	auipc	a0,0x2
ffffffffc0204e14:	44050513          	addi	a0,a0,1088 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204e18:	c0afb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204e1c:	00002697          	auipc	a3,0x2
ffffffffc0204e20:	68468693          	addi	a3,a3,1668 # ffffffffc02074a0 <default_pmm_manager+0x8b8>
ffffffffc0204e24:	00001617          	auipc	a2,0x1
ffffffffc0204e28:	70c60613          	addi	a2,a2,1804 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204e2c:	2a200593          	li	a1,674
ffffffffc0204e30:	00002517          	auipc	a0,0x2
ffffffffc0204e34:	42050513          	addi	a0,a0,1056 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204e38:	beafb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204e3c:	00002697          	auipc	a3,0x2
ffffffffc0204e40:	61c68693          	addi	a3,a3,1564 # ffffffffc0207458 <default_pmm_manager+0x870>
ffffffffc0204e44:	00001617          	auipc	a2,0x1
ffffffffc0204e48:	6ec60613          	addi	a2,a2,1772 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0204e4c:	2a100593          	li	a1,673
ffffffffc0204e50:	00002517          	auipc	a0,0x2
ffffffffc0204e54:	40050513          	addi	a0,a0,1024 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204e58:	bcafb0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0204e5c <user_main>:
{
ffffffffc0204e5c:	1101                	addi	sp,sp,-32
ffffffffc0204e5e:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE(priority);
ffffffffc0204e60:	000c2917          	auipc	s2,0xc2
ffffffffc0204e64:	f1090913          	addi	s2,s2,-240 # ffffffffc02c6d70 <current>
ffffffffc0204e68:	00093783          	ld	a5,0(s2)
ffffffffc0204e6c:	00002617          	auipc	a2,0x2
ffffffffc0204e70:	70c60613          	addi	a2,a2,1804 # ffffffffc0207578 <default_pmm_manager+0x990>
ffffffffc0204e74:	00002517          	auipc	a0,0x2
ffffffffc0204e78:	71450513          	addi	a0,a0,1812 # ffffffffc0207588 <default_pmm_manager+0x9a0>
ffffffffc0204e7c:	43cc                	lw	a1,4(a5)
{
ffffffffc0204e7e:	ec06                	sd	ra,24(sp)
ffffffffc0204e80:	e822                	sd	s0,16(sp)
ffffffffc0204e82:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE(priority);
ffffffffc0204e84:	a60fb0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    size_t len = strlen(name);
ffffffffc0204e88:	00002517          	auipc	a0,0x2
ffffffffc0204e8c:	6f050513          	addi	a0,a0,1776 # ffffffffc0207578 <default_pmm_manager+0x990>
ffffffffc0204e90:	686000ef          	jal	ra,ffffffffc0205516 <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc0204e94:	00093783          	ld	a5,0(s2)
    size_t len = strlen(name);
ffffffffc0204e98:	84aa                	mv	s1,a0
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204e9a:	12000613          	li	a2,288
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204e9e:	6b80                	ld	s0,16(a5)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204ea0:	73cc                	ld	a1,160(a5)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204ea2:	6789                	lui	a5,0x2
ffffffffc0204ea4:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x8080>
ffffffffc0204ea8:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204eaa:	8522                	mv	a0,s0
ffffffffc0204eac:	71e000ef          	jal	ra,ffffffffc02055ca <memcpy>
    current->tf = new_tf;
ffffffffc0204eb0:	00093783          	ld	a5,0(s2)
    ret = do_execve(name, len, binary, size);
ffffffffc0204eb4:	3fe07697          	auipc	a3,0x3fe07
ffffffffc0204eb8:	89c68693          	addi	a3,a3,-1892 # b750 <_binary_obj___user_priority_out_size>
ffffffffc0204ebc:	0003c617          	auipc	a2,0x3c
ffffffffc0204ec0:	7a460613          	addi	a2,a2,1956 # ffffffffc0241660 <_binary_obj___user_priority_out_start>
    current->tf = new_tf;
ffffffffc0204ec4:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0204ec6:	85a6                	mv	a1,s1
ffffffffc0204ec8:	00002517          	auipc	a0,0x2
ffffffffc0204ecc:	6b050513          	addi	a0,a0,1712 # ffffffffc0207578 <default_pmm_manager+0x990>
ffffffffc0204ed0:	a79ff0ef          	jal	ra,ffffffffc0204948 <do_execve>
    asm volatile(
ffffffffc0204ed4:	8122                	mv	sp,s0
ffffffffc0204ed6:	9fafc06f          	j	ffffffffc02010d0 <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204eda:	00002617          	auipc	a2,0x2
ffffffffc0204ede:	6d660613          	addi	a2,a2,1750 # ffffffffc02075b0 <default_pmm_manager+0x9c8>
ffffffffc0204ee2:	38400593          	li	a1,900
ffffffffc0204ee6:	00002517          	auipc	a0,0x2
ffffffffc0204eea:	36a50513          	addi	a0,a0,874 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0204eee:	b34fb0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0204ef2 <do_yield>:
    current->need_resched = 1;
ffffffffc0204ef2:	000c2797          	auipc	a5,0xc2
ffffffffc0204ef6:	e7e7b783          	ld	a5,-386(a5) # ffffffffc02c6d70 <current>
ffffffffc0204efa:	4705                	li	a4,1
ffffffffc0204efc:	ef98                	sd	a4,24(a5)
}
ffffffffc0204efe:	4501                	li	a0,0
ffffffffc0204f00:	8082                	ret

ffffffffc0204f02 <do_wait>:
{
ffffffffc0204f02:	1101                	addi	sp,sp,-32
ffffffffc0204f04:	e822                	sd	s0,16(sp)
ffffffffc0204f06:	e426                	sd	s1,8(sp)
ffffffffc0204f08:	ec06                	sd	ra,24(sp)
ffffffffc0204f0a:	842e                	mv	s0,a1
ffffffffc0204f0c:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204f0e:	c999                	beqz	a1,ffffffffc0204f24 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204f10:	000c2797          	auipc	a5,0xc2
ffffffffc0204f14:	e607b783          	ld	a5,-416(a5) # ffffffffc02c6d70 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204f18:	7788                	ld	a0,40(a5)
ffffffffc0204f1a:	4685                	li	a3,1
ffffffffc0204f1c:	4611                	li	a2,4
ffffffffc0204f1e:	953fc0ef          	jal	ra,ffffffffc0201870 <user_mem_check>
ffffffffc0204f22:	c909                	beqz	a0,ffffffffc0204f34 <do_wait+0x32>
ffffffffc0204f24:	85a2                	mv	a1,s0
}
ffffffffc0204f26:	6442                	ld	s0,16(sp)
ffffffffc0204f28:	60e2                	ld	ra,24(sp)
ffffffffc0204f2a:	8526                	mv	a0,s1
ffffffffc0204f2c:	64a2                	ld	s1,8(sp)
ffffffffc0204f2e:	6105                	addi	sp,sp,32
ffffffffc0204f30:	f22ff06f          	j	ffffffffc0204652 <do_wait.part.0>
ffffffffc0204f34:	60e2                	ld	ra,24(sp)
ffffffffc0204f36:	6442                	ld	s0,16(sp)
ffffffffc0204f38:	64a2                	ld	s1,8(sp)
ffffffffc0204f3a:	5575                	li	a0,-3
ffffffffc0204f3c:	6105                	addi	sp,sp,32
ffffffffc0204f3e:	8082                	ret

ffffffffc0204f40 <do_kill>:
{
ffffffffc0204f40:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f42:	6789                	lui	a5,0x2
{
ffffffffc0204f44:	e406                	sd	ra,8(sp)
ffffffffc0204f46:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f48:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204f4c:	17f9                	addi	a5,a5,-2
ffffffffc0204f4e:	02e7e963          	bltu	a5,a4,ffffffffc0204f80 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f52:	842a                	mv	s0,a0
ffffffffc0204f54:	45a9                	li	a1,10
ffffffffc0204f56:	2501                	sext.w	a0,a0
ffffffffc0204f58:	279000ef          	jal	ra,ffffffffc02059d0 <hash32>
ffffffffc0204f5c:	02051793          	slli	a5,a0,0x20
ffffffffc0204f60:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204f64:	000be797          	auipc	a5,0xbe
ffffffffc0204f68:	d6c78793          	addi	a5,a5,-660 # ffffffffc02c2cd0 <hash_list>
ffffffffc0204f6c:	953e                	add	a0,a0,a5
ffffffffc0204f6e:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204f70:	a029                	j	ffffffffc0204f7a <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204f72:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204f76:	00870b63          	beq	a4,s0,ffffffffc0204f8c <do_kill+0x4c>
ffffffffc0204f7a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204f7c:	fef51be3          	bne	a0,a5,ffffffffc0204f72 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204f80:	5475                	li	s0,-3
}
ffffffffc0204f82:	60a2                	ld	ra,8(sp)
ffffffffc0204f84:	8522                	mv	a0,s0
ffffffffc0204f86:	6402                	ld	s0,0(sp)
ffffffffc0204f88:	0141                	addi	sp,sp,16
ffffffffc0204f8a:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204f8c:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204f90:	00177693          	andi	a3,a4,1
ffffffffc0204f94:	e295                	bnez	a3,ffffffffc0204fb8 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204f96:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204f98:	00176713          	ori	a4,a4,1
ffffffffc0204f9c:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204fa0:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204fa2:	fe06d0e3          	bgez	a3,ffffffffc0204f82 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204fa6:	f2878513          	addi	a0,a5,-216
ffffffffc0204faa:	278000ef          	jal	ra,ffffffffc0205222 <wakeup_proc>
}
ffffffffc0204fae:	60a2                	ld	ra,8(sp)
ffffffffc0204fb0:	8522                	mv	a0,s0
ffffffffc0204fb2:	6402                	ld	s0,0(sp)
ffffffffc0204fb4:	0141                	addi	sp,sp,16
ffffffffc0204fb6:	8082                	ret
        return -E_KILLED;
ffffffffc0204fb8:	545d                	li	s0,-9
ffffffffc0204fba:	b7e1                	j	ffffffffc0204f82 <do_kill+0x42>

ffffffffc0204fbc <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204fbc:	1101                	addi	sp,sp,-32
ffffffffc0204fbe:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204fc0:	000c2797          	auipc	a5,0xc2
ffffffffc0204fc4:	d1078793          	addi	a5,a5,-752 # ffffffffc02c6cd0 <proc_list>
ffffffffc0204fc8:	ec06                	sd	ra,24(sp)
ffffffffc0204fca:	e822                	sd	s0,16(sp)
ffffffffc0204fcc:	e04a                	sd	s2,0(sp)
ffffffffc0204fce:	000be497          	auipc	s1,0xbe
ffffffffc0204fd2:	d0248493          	addi	s1,s1,-766 # ffffffffc02c2cd0 <hash_list>
ffffffffc0204fd6:	e79c                	sd	a5,8(a5)
ffffffffc0204fd8:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204fda:	000c2717          	auipc	a4,0xc2
ffffffffc0204fde:	cf670713          	addi	a4,a4,-778 # ffffffffc02c6cd0 <proc_list>
ffffffffc0204fe2:	87a6                	mv	a5,s1
ffffffffc0204fe4:	e79c                	sd	a5,8(a5)
ffffffffc0204fe6:	e39c                	sd	a5,0(a5)
ffffffffc0204fe8:	07c1                	addi	a5,a5,16
ffffffffc0204fea:	fef71de3          	bne	a4,a5,ffffffffc0204fe4 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204fee:	f63fe0ef          	jal	ra,ffffffffc0203f50 <alloc_proc>
ffffffffc0204ff2:	000c2917          	auipc	s2,0xc2
ffffffffc0204ff6:	d8690913          	addi	s2,s2,-634 # ffffffffc02c6d78 <idleproc>
ffffffffc0204ffa:	00a93023          	sd	a0,0(s2)
ffffffffc0204ffe:	0e050f63          	beqz	a0,ffffffffc02050fc <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205002:	4789                	li	a5,2
ffffffffc0205004:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205006:	00004797          	auipc	a5,0x4
ffffffffc020500a:	ffa78793          	addi	a5,a5,-6 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020500e:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205012:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205014:	4785                	li	a5,1
ffffffffc0205016:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205018:	4641                	li	a2,16
ffffffffc020501a:	4581                	li	a1,0
ffffffffc020501c:	8522                	mv	a0,s0
ffffffffc020501e:	59a000ef          	jal	ra,ffffffffc02055b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205022:	463d                	li	a2,15
ffffffffc0205024:	00002597          	auipc	a1,0x2
ffffffffc0205028:	5c458593          	addi	a1,a1,1476 # ffffffffc02075e8 <default_pmm_manager+0xa00>
ffffffffc020502c:	8522                	mv	a0,s0
ffffffffc020502e:	59c000ef          	jal	ra,ffffffffc02055ca <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205032:	000c2717          	auipc	a4,0xc2
ffffffffc0205036:	d5670713          	addi	a4,a4,-682 # ffffffffc02c6d88 <nr_process>
ffffffffc020503a:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020503c:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205040:	4601                	li	a2,0
    nr_process++;
ffffffffc0205042:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205044:	4581                	li	a1,0
ffffffffc0205046:	fffff517          	auipc	a0,0xfffff
ffffffffc020504a:	7de50513          	addi	a0,a0,2014 # ffffffffc0204824 <init_main>
    nr_process++;
ffffffffc020504e:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205050:	000c2797          	auipc	a5,0xc2
ffffffffc0205054:	d2d7b023          	sd	a3,-736(a5) # ffffffffc02c6d70 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205058:	c60ff0ef          	jal	ra,ffffffffc02044b8 <kernel_thread>
ffffffffc020505c:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc020505e:	08a05363          	blez	a0,ffffffffc02050e4 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205062:	6789                	lui	a5,0x2
ffffffffc0205064:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205068:	17f9                	addi	a5,a5,-2
ffffffffc020506a:	2501                	sext.w	a0,a0
ffffffffc020506c:	02e7e363          	bltu	a5,a4,ffffffffc0205092 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205070:	45a9                	li	a1,10
ffffffffc0205072:	15f000ef          	jal	ra,ffffffffc02059d0 <hash32>
ffffffffc0205076:	02051793          	slli	a5,a0,0x20
ffffffffc020507a:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020507e:	96a6                	add	a3,a3,s1
ffffffffc0205080:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205082:	a029                	j	ffffffffc020508c <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0205084:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x8034>
ffffffffc0205088:	04870b63          	beq	a4,s0,ffffffffc02050de <proc_init+0x122>
    return listelm->next;
ffffffffc020508c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020508e:	fef69be3          	bne	a3,a5,ffffffffc0205084 <proc_init+0xc8>
    return NULL;
ffffffffc0205092:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205094:	0b478493          	addi	s1,a5,180
ffffffffc0205098:	4641                	li	a2,16
ffffffffc020509a:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc020509c:	000c2417          	auipc	s0,0xc2
ffffffffc02050a0:	ce440413          	addi	s0,s0,-796 # ffffffffc02c6d80 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050a4:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02050a6:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050a8:	510000ef          	jal	ra,ffffffffc02055b8 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050ac:	463d                	li	a2,15
ffffffffc02050ae:	00002597          	auipc	a1,0x2
ffffffffc02050b2:	56258593          	addi	a1,a1,1378 # ffffffffc0207610 <default_pmm_manager+0xa28>
ffffffffc02050b6:	8526                	mv	a0,s1
ffffffffc02050b8:	512000ef          	jal	ra,ffffffffc02055ca <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02050bc:	00093783          	ld	a5,0(s2)
ffffffffc02050c0:	cbb5                	beqz	a5,ffffffffc0205134 <proc_init+0x178>
ffffffffc02050c2:	43dc                	lw	a5,4(a5)
ffffffffc02050c4:	eba5                	bnez	a5,ffffffffc0205134 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02050c6:	601c                	ld	a5,0(s0)
ffffffffc02050c8:	c7b1                	beqz	a5,ffffffffc0205114 <proc_init+0x158>
ffffffffc02050ca:	43d8                	lw	a4,4(a5)
ffffffffc02050cc:	4785                	li	a5,1
ffffffffc02050ce:	04f71363          	bne	a4,a5,ffffffffc0205114 <proc_init+0x158>
}
ffffffffc02050d2:	60e2                	ld	ra,24(sp)
ffffffffc02050d4:	6442                	ld	s0,16(sp)
ffffffffc02050d6:	64a2                	ld	s1,8(sp)
ffffffffc02050d8:	6902                	ld	s2,0(sp)
ffffffffc02050da:	6105                	addi	sp,sp,32
ffffffffc02050dc:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02050de:	f2878793          	addi	a5,a5,-216
ffffffffc02050e2:	bf4d                	j	ffffffffc0205094 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc02050e4:	00002617          	auipc	a2,0x2
ffffffffc02050e8:	50c60613          	addi	a2,a2,1292 # ffffffffc02075f0 <default_pmm_manager+0xa08>
ffffffffc02050ec:	3c000593          	li	a1,960
ffffffffc02050f0:	00002517          	auipc	a0,0x2
ffffffffc02050f4:	16050513          	addi	a0,a0,352 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc02050f8:	92afb0ef          	jal	ra,ffffffffc0200222 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02050fc:	00002617          	auipc	a2,0x2
ffffffffc0205100:	4d460613          	addi	a2,a2,1236 # ffffffffc02075d0 <default_pmm_manager+0x9e8>
ffffffffc0205104:	3b100593          	li	a1,945
ffffffffc0205108:	00002517          	auipc	a0,0x2
ffffffffc020510c:	14850513          	addi	a0,a0,328 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0205110:	912fb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205114:	00002697          	auipc	a3,0x2
ffffffffc0205118:	52c68693          	addi	a3,a3,1324 # ffffffffc0207640 <default_pmm_manager+0xa58>
ffffffffc020511c:	00001617          	auipc	a2,0x1
ffffffffc0205120:	41460613          	addi	a2,a2,1044 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0205124:	3c700593          	li	a1,967
ffffffffc0205128:	00002517          	auipc	a0,0x2
ffffffffc020512c:	12850513          	addi	a0,a0,296 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0205130:	8f2fb0ef          	jal	ra,ffffffffc0200222 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205134:	00002697          	auipc	a3,0x2
ffffffffc0205138:	4e468693          	addi	a3,a3,1252 # ffffffffc0207618 <default_pmm_manager+0xa30>
ffffffffc020513c:	00001617          	auipc	a2,0x1
ffffffffc0205140:	3f460613          	addi	a2,a2,1012 # ffffffffc0206530 <commands+0x8a0>
ffffffffc0205144:	3c600593          	li	a1,966
ffffffffc0205148:	00002517          	auipc	a0,0x2
ffffffffc020514c:	10850513          	addi	a0,a0,264 # ffffffffc0207250 <default_pmm_manager+0x668>
ffffffffc0205150:	8d2fb0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0205154 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205154:	1141                	addi	sp,sp,-16
ffffffffc0205156:	e022                	sd	s0,0(sp)
ffffffffc0205158:	e406                	sd	ra,8(sp)
ffffffffc020515a:	000c2417          	auipc	s0,0xc2
ffffffffc020515e:	c1640413          	addi	s0,s0,-1002 # ffffffffc02c6d70 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205162:	6018                	ld	a4,0(s0)
ffffffffc0205164:	6f1c                	ld	a5,24(a4)
ffffffffc0205166:	dffd                	beqz	a5,ffffffffc0205164 <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205168:	16c000ef          	jal	ra,ffffffffc02052d4 <schedule>
ffffffffc020516c:	bfdd                	j	ffffffffc0205162 <cpu_idle+0xe>

ffffffffc020516e <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc020516e:	1141                	addi	sp,sp,-16
ffffffffc0205170:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205172:	85aa                	mv	a1,a0
{
ffffffffc0205174:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205176:	00002517          	auipc	a0,0x2
ffffffffc020517a:	4f250513          	addi	a0,a0,1266 # ffffffffc0207668 <default_pmm_manager+0xa80>
{
ffffffffc020517e:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205180:	f65fa0ef          	jal	ra,ffffffffc02000e4 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0205184:	000c2797          	auipc	a5,0xc2
ffffffffc0205188:	bec7b783          	ld	a5,-1044(a5) # ffffffffc02c6d70 <current>
    if (priority == 0)
ffffffffc020518c:	e801                	bnez	s0,ffffffffc020519c <lab6_set_priority+0x2e>
    else
        current->lab6_priority = priority;
}
ffffffffc020518e:	60a2                	ld	ra,8(sp)
ffffffffc0205190:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0205192:	4705                	li	a4,1
ffffffffc0205194:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0205198:	0141                	addi	sp,sp,16
ffffffffc020519a:	8082                	ret
ffffffffc020519c:	60a2                	ld	ra,8(sp)
        current->lab6_priority = priority;
ffffffffc020519e:	1487a223          	sw	s0,324(a5)
}
ffffffffc02051a2:	6402                	ld	s0,0(sp)
ffffffffc02051a4:	0141                	addi	sp,sp,16
ffffffffc02051a6:	8082                	ret

ffffffffc02051a8 <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
ffffffffc02051a8:	000c2797          	auipc	a5,0xc2
ffffffffc02051ac:	bd07b783          	ld	a5,-1072(a5) # ffffffffc02c6d78 <idleproc>
{
ffffffffc02051b0:	85aa                	mv	a1,a0
    if (proc != idleproc)
ffffffffc02051b2:	00a78c63          	beq	a5,a0,ffffffffc02051ca <sched_class_proc_tick+0x22>
    {
        sched_class->proc_tick(rq, proc);
ffffffffc02051b6:	000c2797          	auipc	a5,0xc2
ffffffffc02051ba:	be27b783          	ld	a5,-1054(a5) # ffffffffc02c6d98 <sched_class>
ffffffffc02051be:	779c                	ld	a5,40(a5)
ffffffffc02051c0:	000c2517          	auipc	a0,0xc2
ffffffffc02051c4:	bd053503          	ld	a0,-1072(a0) # ffffffffc02c6d90 <rq>
ffffffffc02051c8:	8782                	jr	a5
    }
    else
    {
        proc->need_resched = 1;
ffffffffc02051ca:	4705                	li	a4,1
ffffffffc02051cc:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc02051ce:	8082                	ret

ffffffffc02051d0 <sched_init>:

static struct run_queue __rq;

void sched_init(void)
{
ffffffffc02051d0:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc02051d2:	000bd717          	auipc	a4,0xbd
ffffffffc02051d6:	6a670713          	addi	a4,a4,1702 # ffffffffc02c2878 <default_sched_class>
{
ffffffffc02051da:	e022                	sd	s0,0(sp)
ffffffffc02051dc:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02051de:	000c2797          	auipc	a5,0xc2
ffffffffc02051e2:	b2278793          	addi	a5,a5,-1246 # ffffffffc02c6d00 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc02051e6:	6714                	ld	a3,8(a4)
    rq = &__rq;
ffffffffc02051e8:	000c2517          	auipc	a0,0xc2
ffffffffc02051ec:	af850513          	addi	a0,a0,-1288 # ffffffffc02c6ce0 <__rq>
ffffffffc02051f0:	e79c                	sd	a5,8(a5)
ffffffffc02051f2:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02051f4:	4795                	li	a5,5
ffffffffc02051f6:	c95c                	sw	a5,20(a0)
    sched_class = &default_sched_class;
ffffffffc02051f8:	000c2417          	auipc	s0,0xc2
ffffffffc02051fc:	ba040413          	addi	s0,s0,-1120 # ffffffffc02c6d98 <sched_class>
    rq = &__rq;
ffffffffc0205200:	000c2797          	auipc	a5,0xc2
ffffffffc0205204:	b8a7b823          	sd	a0,-1136(a5) # ffffffffc02c6d90 <rq>
    sched_class = &default_sched_class;
ffffffffc0205208:	e018                	sd	a4,0(s0)
    sched_class->init(rq);
ffffffffc020520a:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc020520c:	601c                	ld	a5,0(s0)
}
ffffffffc020520e:	6402                	ld	s0,0(sp)
ffffffffc0205210:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205212:	638c                	ld	a1,0(a5)
ffffffffc0205214:	00002517          	auipc	a0,0x2
ffffffffc0205218:	46c50513          	addi	a0,a0,1132 # ffffffffc0207680 <default_pmm_manager+0xa98>
}
ffffffffc020521c:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc020521e:	ec7fa06f          	j	ffffffffc02000e4 <cprintf>

ffffffffc0205222 <wakeup_proc>:

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205222:	4118                	lw	a4,0(a0)
{
ffffffffc0205224:	1101                	addi	sp,sp,-32
ffffffffc0205226:	ec06                	sd	ra,24(sp)
ffffffffc0205228:	e822                	sd	s0,16(sp)
ffffffffc020522a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020522c:	478d                	li	a5,3
ffffffffc020522e:	08f70363          	beq	a4,a5,ffffffffc02052b4 <wakeup_proc+0x92>
ffffffffc0205232:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205234:	100027f3          	csrr	a5,sstatus
ffffffffc0205238:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020523a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020523c:	e7bd                	bnez	a5,ffffffffc02052aa <wakeup_proc+0x88>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc020523e:	4789                	li	a5,2
ffffffffc0205240:	04f70863          	beq	a4,a5,ffffffffc0205290 <wakeup_proc+0x6e>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205244:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205246:	0e042623          	sw	zero,236(s0)
            if (proc != current)
ffffffffc020524a:	000c2797          	auipc	a5,0xc2
ffffffffc020524e:	b267b783          	ld	a5,-1242(a5) # ffffffffc02c6d70 <current>
ffffffffc0205252:	02878363          	beq	a5,s0,ffffffffc0205278 <wakeup_proc+0x56>
    if (proc != idleproc)
ffffffffc0205256:	000c2797          	auipc	a5,0xc2
ffffffffc020525a:	b227b783          	ld	a5,-1246(a5) # ffffffffc02c6d78 <idleproc>
ffffffffc020525e:	00f40d63          	beq	s0,a5,ffffffffc0205278 <wakeup_proc+0x56>
        sched_class->enqueue(rq, proc);
ffffffffc0205262:	000c2797          	auipc	a5,0xc2
ffffffffc0205266:	b367b783          	ld	a5,-1226(a5) # ffffffffc02c6d98 <sched_class>
ffffffffc020526a:	6b9c                	ld	a5,16(a5)
ffffffffc020526c:	85a2                	mv	a1,s0
ffffffffc020526e:	000c2517          	auipc	a0,0xc2
ffffffffc0205272:	b2253503          	ld	a0,-1246(a0) # ffffffffc02c6d90 <rq>
ffffffffc0205276:	9782                	jalr	a5
    if (flag)
ffffffffc0205278:	e491                	bnez	s1,ffffffffc0205284 <wakeup_proc+0x62>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020527a:	60e2                	ld	ra,24(sp)
ffffffffc020527c:	6442                	ld	s0,16(sp)
ffffffffc020527e:	64a2                	ld	s1,8(sp)
ffffffffc0205280:	6105                	addi	sp,sp,32
ffffffffc0205282:	8082                	ret
ffffffffc0205284:	6442                	ld	s0,16(sp)
ffffffffc0205286:	60e2                	ld	ra,24(sp)
ffffffffc0205288:	64a2                	ld	s1,8(sp)
ffffffffc020528a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020528c:	f22fb06f          	j	ffffffffc02009ae <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205290:	00002617          	auipc	a2,0x2
ffffffffc0205294:	44060613          	addi	a2,a2,1088 # ffffffffc02076d0 <default_pmm_manager+0xae8>
ffffffffc0205298:	05100593          	li	a1,81
ffffffffc020529c:	00002517          	auipc	a0,0x2
ffffffffc02052a0:	41c50513          	addi	a0,a0,1052 # ffffffffc02076b8 <default_pmm_manager+0xad0>
ffffffffc02052a4:	fe7fa0ef          	jal	ra,ffffffffc020028a <__warn>
ffffffffc02052a8:	bfc1                	j	ffffffffc0205278 <wakeup_proc+0x56>
        intr_disable();
ffffffffc02052aa:	f0afb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc02052ae:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02052b0:	4485                	li	s1,1
ffffffffc02052b2:	b771                	j	ffffffffc020523e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052b4:	00002697          	auipc	a3,0x2
ffffffffc02052b8:	3e468693          	addi	a3,a3,996 # ffffffffc0207698 <default_pmm_manager+0xab0>
ffffffffc02052bc:	00001617          	auipc	a2,0x1
ffffffffc02052c0:	27460613          	addi	a2,a2,628 # ffffffffc0206530 <commands+0x8a0>
ffffffffc02052c4:	04200593          	li	a1,66
ffffffffc02052c8:	00002517          	auipc	a0,0x2
ffffffffc02052cc:	3f050513          	addi	a0,a0,1008 # ffffffffc02076b8 <default_pmm_manager+0xad0>
ffffffffc02052d0:	f53fa0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc02052d4 <schedule>:

void schedule(void)
{
ffffffffc02052d4:	7179                	addi	sp,sp,-48
ffffffffc02052d6:	f406                	sd	ra,40(sp)
ffffffffc02052d8:	f022                	sd	s0,32(sp)
ffffffffc02052da:	ec26                	sd	s1,24(sp)
ffffffffc02052dc:	e84a                	sd	s2,16(sp)
ffffffffc02052de:	e44e                	sd	s3,8(sp)
ffffffffc02052e0:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02052e2:	100027f3          	csrr	a5,sstatus
ffffffffc02052e6:	8b89                	andi	a5,a5,2
ffffffffc02052e8:	4a01                	li	s4,0
ffffffffc02052ea:	e3cd                	bnez	a5,ffffffffc020538c <schedule+0xb8>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02052ec:	000c2497          	auipc	s1,0xc2
ffffffffc02052f0:	a8448493          	addi	s1,s1,-1404 # ffffffffc02c6d70 <current>
ffffffffc02052f4:	608c                	ld	a1,0(s1)
        sched_class->enqueue(rq, proc);
ffffffffc02052f6:	000c2997          	auipc	s3,0xc2
ffffffffc02052fa:	aa298993          	addi	s3,s3,-1374 # ffffffffc02c6d98 <sched_class>
ffffffffc02052fe:	000c2917          	auipc	s2,0xc2
ffffffffc0205302:	a9290913          	addi	s2,s2,-1390 # ffffffffc02c6d90 <rq>
        if (current->state == PROC_RUNNABLE)
ffffffffc0205306:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0205308:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE)
ffffffffc020530c:	4709                	li	a4,2
        sched_class->enqueue(rq, proc);
ffffffffc020530e:	0009b783          	ld	a5,0(s3)
ffffffffc0205312:	00093503          	ld	a0,0(s2)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205316:	04e68e63          	beq	a3,a4,ffffffffc0205372 <schedule+0x9e>
    return sched_class->pick_next(rq);
ffffffffc020531a:	739c                	ld	a5,32(a5)
ffffffffc020531c:	9782                	jalr	a5
ffffffffc020531e:	842a                	mv	s0,a0
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
ffffffffc0205320:	c521                	beqz	a0,ffffffffc0205368 <schedule+0x94>
    sched_class->dequeue(rq, proc);
ffffffffc0205322:	0009b783          	ld	a5,0(s3)
ffffffffc0205326:	00093503          	ld	a0,0(s2)
ffffffffc020532a:	85a2                	mv	a1,s0
ffffffffc020532c:	6f9c                	ld	a5,24(a5)
ffffffffc020532e:	9782                	jalr	a5
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205330:	441c                	lw	a5,8(s0)
        if (next != current)
ffffffffc0205332:	6098                	ld	a4,0(s1)
        next->runs++;
ffffffffc0205334:	2785                	addiw	a5,a5,1
ffffffffc0205336:	c41c                	sw	a5,8(s0)
        if (next != current)
ffffffffc0205338:	00870563          	beq	a4,s0,ffffffffc0205342 <schedule+0x6e>
        {
            proc_run(next);
ffffffffc020533c:	8522                	mv	a0,s0
ffffffffc020533e:	d31fe0ef          	jal	ra,ffffffffc020406e <proc_run>
    if (flag)
ffffffffc0205342:	000a1a63          	bnez	s4,ffffffffc0205356 <schedule+0x82>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205346:	70a2                	ld	ra,40(sp)
ffffffffc0205348:	7402                	ld	s0,32(sp)
ffffffffc020534a:	64e2                	ld	s1,24(sp)
ffffffffc020534c:	6942                	ld	s2,16(sp)
ffffffffc020534e:	69a2                	ld	s3,8(sp)
ffffffffc0205350:	6a02                	ld	s4,0(sp)
ffffffffc0205352:	6145                	addi	sp,sp,48
ffffffffc0205354:	8082                	ret
ffffffffc0205356:	7402                	ld	s0,32(sp)
ffffffffc0205358:	70a2                	ld	ra,40(sp)
ffffffffc020535a:	64e2                	ld	s1,24(sp)
ffffffffc020535c:	6942                	ld	s2,16(sp)
ffffffffc020535e:	69a2                	ld	s3,8(sp)
ffffffffc0205360:	6a02                	ld	s4,0(sp)
ffffffffc0205362:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0205364:	e4afb06f          	j	ffffffffc02009ae <intr_enable>
            next = idleproc;
ffffffffc0205368:	000c2417          	auipc	s0,0xc2
ffffffffc020536c:	a1043403          	ld	s0,-1520(s0) # ffffffffc02c6d78 <idleproc>
ffffffffc0205370:	b7c1                	j	ffffffffc0205330 <schedule+0x5c>
    if (proc != idleproc)
ffffffffc0205372:	000c2717          	auipc	a4,0xc2
ffffffffc0205376:	a0673703          	ld	a4,-1530(a4) # ffffffffc02c6d78 <idleproc>
ffffffffc020537a:	fae580e3          	beq	a1,a4,ffffffffc020531a <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc020537e:	6b9c                	ld	a5,16(a5)
ffffffffc0205380:	9782                	jalr	a5
    return sched_class->pick_next(rq);
ffffffffc0205382:	0009b783          	ld	a5,0(s3)
ffffffffc0205386:	00093503          	ld	a0,0(s2)
ffffffffc020538a:	bf41                	j	ffffffffc020531a <schedule+0x46>
        intr_disable();
ffffffffc020538c:	e28fb0ef          	jal	ra,ffffffffc02009b4 <intr_disable>
        return 1;
ffffffffc0205390:	4a05                	li	s4,1
ffffffffc0205392:	bfa9                	j	ffffffffc02052ec <schedule+0x18>

ffffffffc0205394 <RR_init>:
ffffffffc0205394:	e508                	sd	a0,8(a0)
ffffffffc0205396:	e108                	sd	a0,0(a0)
 */
static void
RR_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc0205398:	00052823          	sw	zero,16(a0)
    rq->lab6_run_pool = NULL;
ffffffffc020539c:	00053c23          	sd	zero,24(a0)
}
ffffffffc02053a0:	8082                	ret

ffffffffc02053a2 <RR_enqueue>:
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice)
ffffffffc02053a2:	1205a783          	lw	a5,288(a1)
ffffffffc02053a6:	4958                	lw	a4,20(a0)
ffffffffc02053a8:	c399                	beqz	a5,ffffffffc02053ae <RR_enqueue+0xc>
ffffffffc02053aa:	00f75463          	bge	a4,a5,ffffffffc02053b2 <RR_enqueue+0x10>
    {
        proc->time_slice = rq->max_time_slice;
ffffffffc02053ae:	12e5a023          	sw	a4,288(a1)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02053b2:	6118                	ld	a4,0(a0)
    }
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
ffffffffc02053b4:	491c                	lw	a5,16(a0)
    list_add_before(&(rq->run_list), &(proc->run_link));
ffffffffc02053b6:	11058693          	addi	a3,a1,272
    prev->next = next->prev = elm;
ffffffffc02053ba:	e114                	sd	a3,0(a0)
ffffffffc02053bc:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc02053be:	10a5bc23          	sd	a0,280(a1)
    elm->prev = prev;
ffffffffc02053c2:	10e5b823          	sd	a4,272(a1)
    proc->rq = rq;
ffffffffc02053c6:	10a5b423          	sd	a0,264(a1)
    rq->proc_num++;
ffffffffc02053ca:	2785                	addiw	a5,a5,1
ffffffffc02053cc:	c91c                	sw	a5,16(a0)
}
ffffffffc02053ce:	8082                	ret

ffffffffc02053d0 <RR_dequeue>:
    __list_del(listelm->prev, listelm->next);
ffffffffc02053d0:	1185b703          	ld	a4,280(a1)
ffffffffc02053d4:	1105b683          	ld	a3,272(a1)
 */
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
ffffffffc02053d8:	491c                	lw	a5,16(a0)
    prev->next = next;
ffffffffc02053da:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02053dc:	e314                	sd	a3,0(a4)
    list_del_init(&(proc->run_link));
ffffffffc02053de:	11058713          	addi	a4,a1,272
    elm->prev = elm->next = elm;
ffffffffc02053e2:	10e5bc23          	sd	a4,280(a1)
ffffffffc02053e6:	10e5b823          	sd	a4,272(a1)
    rq->proc_num--;
ffffffffc02053ea:	37fd                	addiw	a5,a5,-1
ffffffffc02053ec:	c91c                	sw	a5,16(a0)
}
ffffffffc02053ee:	8082                	ret

ffffffffc02053f0 <RR_pick_next>:
    return listelm->next;
ffffffffc02053f0:	651c                	ld	a5,8(a0)
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list))
ffffffffc02053f2:	00f50563          	beq	a0,a5,ffffffffc02053fc <RR_pick_next+0xc>
    {
        return le2proc(le, run_link);
ffffffffc02053f6:	ef078513          	addi	a0,a5,-272
ffffffffc02053fa:	8082                	ret
    }
    return NULL;
ffffffffc02053fc:	4501                	li	a0,0
}
ffffffffc02053fe:	8082                	ret

ffffffffc0205400 <RR_proc_tick>:
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice > 0)
ffffffffc0205400:	1205a783          	lw	a5,288(a1)
ffffffffc0205404:	00f05563          	blez	a5,ffffffffc020540e <RR_proc_tick+0xe>
    {
        proc->time_slice--;
ffffffffc0205408:	37fd                	addiw	a5,a5,-1
ffffffffc020540a:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0)
ffffffffc020540e:	e399                	bnez	a5,ffffffffc0205414 <RR_proc_tick+0x14>
    {
        proc->need_resched = 1;
ffffffffc0205410:	4785                	li	a5,1
ffffffffc0205412:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0205414:	8082                	ret

ffffffffc0205416 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205416:	000c2797          	auipc	a5,0xc2
ffffffffc020541a:	95a7b783          	ld	a5,-1702(a5) # ffffffffc02c6d70 <current>
}
ffffffffc020541e:	43c8                	lw	a0,4(a5)
ffffffffc0205420:	8082                	ret

ffffffffc0205422 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205422:	4501                	li	a0,0
ffffffffc0205424:	8082                	ret

ffffffffc0205426 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0205426:	000c2797          	auipc	a5,0xc2
ffffffffc020542a:	9027b783          	ld	a5,-1790(a5) # ffffffffc02c6d28 <ticks>
ffffffffc020542e:	0027951b          	slliw	a0,a5,0x2
ffffffffc0205432:	9d3d                	addw	a0,a0,a5
}
ffffffffc0205434:	0015151b          	slliw	a0,a0,0x1
ffffffffc0205438:	8082                	ret

ffffffffc020543a <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc020543a:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc020543c:	1141                	addi	sp,sp,-16
ffffffffc020543e:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0205440:	d2fff0ef          	jal	ra,ffffffffc020516e <lab6_set_priority>
    return 0;
}
ffffffffc0205444:	60a2                	ld	ra,8(sp)
ffffffffc0205446:	4501                	li	a0,0
ffffffffc0205448:	0141                	addi	sp,sp,16
ffffffffc020544a:	8082                	ret

ffffffffc020544c <sys_putc>:
    cputchar(c);
ffffffffc020544c:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020544e:	1141                	addi	sp,sp,-16
ffffffffc0205450:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205452:	cc9fa0ef          	jal	ra,ffffffffc020011a <cputchar>
}
ffffffffc0205456:	60a2                	ld	ra,8(sp)
ffffffffc0205458:	4501                	li	a0,0
ffffffffc020545a:	0141                	addi	sp,sp,16
ffffffffc020545c:	8082                	ret

ffffffffc020545e <sys_kill>:
    return do_kill(pid);
ffffffffc020545e:	4108                	lw	a0,0(a0)
ffffffffc0205460:	ae1ff06f          	j	ffffffffc0204f40 <do_kill>

ffffffffc0205464 <sys_yield>:
    return do_yield();
ffffffffc0205464:	a8fff06f          	j	ffffffffc0204ef2 <do_yield>

ffffffffc0205468 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205468:	6d14                	ld	a3,24(a0)
ffffffffc020546a:	6910                	ld	a2,16(a0)
ffffffffc020546c:	650c                	ld	a1,8(a0)
ffffffffc020546e:	6108                	ld	a0,0(a0)
ffffffffc0205470:	cd8ff06f          	j	ffffffffc0204948 <do_execve>

ffffffffc0205474 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205474:	650c                	ld	a1,8(a0)
ffffffffc0205476:	4108                	lw	a0,0(a0)
ffffffffc0205478:	a8bff06f          	j	ffffffffc0204f02 <do_wait>

ffffffffc020547c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020547c:	000c2797          	auipc	a5,0xc2
ffffffffc0205480:	8f47b783          	ld	a5,-1804(a5) # ffffffffc02c6d70 <current>
ffffffffc0205484:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205486:	4501                	li	a0,0
ffffffffc0205488:	6a0c                	ld	a1,16(a2)
ffffffffc020548a:	c51fe06f          	j	ffffffffc02040da <do_fork>

ffffffffc020548e <sys_exit>:
    return do_exit(error_code);
ffffffffc020548e:	4108                	lw	a0,0(a0)
ffffffffc0205490:	878ff06f          	j	ffffffffc0204508 <do_exit>

ffffffffc0205494 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205494:	715d                	addi	sp,sp,-80
ffffffffc0205496:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205498:	000c2497          	auipc	s1,0xc2
ffffffffc020549c:	8d848493          	addi	s1,s1,-1832 # ffffffffc02c6d70 <current>
ffffffffc02054a0:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02054a2:	e0a2                	sd	s0,64(sp)
ffffffffc02054a4:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02054a6:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02054a8:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054aa:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc02054ae:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02054b2:	0327ee63          	bltu	a5,s2,ffffffffc02054ee <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc02054b6:	00391713          	slli	a4,s2,0x3
ffffffffc02054ba:	00002797          	auipc	a5,0x2
ffffffffc02054be:	28e78793          	addi	a5,a5,654 # ffffffffc0207748 <syscalls>
ffffffffc02054c2:	97ba                	add	a5,a5,a4
ffffffffc02054c4:	639c                	ld	a5,0(a5)
ffffffffc02054c6:	c785                	beqz	a5,ffffffffc02054ee <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc02054c8:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02054ca:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02054cc:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02054ce:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02054d0:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02054d2:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02054d4:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02054d6:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02054d8:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02054da:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02054dc:	0028                	addi	a0,sp,8
ffffffffc02054de:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02054e0:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02054e2:	e828                	sd	a0,80(s0)
}
ffffffffc02054e4:	6406                	ld	s0,64(sp)
ffffffffc02054e6:	74e2                	ld	s1,56(sp)
ffffffffc02054e8:	7942                	ld	s2,48(sp)
ffffffffc02054ea:	6161                	addi	sp,sp,80
ffffffffc02054ec:	8082                	ret
    print_trapframe(tf);
ffffffffc02054ee:	8522                	mv	a0,s0
ffffffffc02054f0:	eb2fb0ef          	jal	ra,ffffffffc0200ba2 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02054f4:	609c                	ld	a5,0(s1)
ffffffffc02054f6:	86ca                	mv	a3,s2
ffffffffc02054f8:	00002617          	auipc	a2,0x2
ffffffffc02054fc:	20860613          	addi	a2,a2,520 # ffffffffc0207700 <default_pmm_manager+0xb18>
ffffffffc0205500:	43d8                	lw	a4,4(a5)
ffffffffc0205502:	06c00593          	li	a1,108
ffffffffc0205506:	0b478793          	addi	a5,a5,180
ffffffffc020550a:	00002517          	auipc	a0,0x2
ffffffffc020550e:	22650513          	addi	a0,a0,550 # ffffffffc0207730 <default_pmm_manager+0xb48>
ffffffffc0205512:	d11fa0ef          	jal	ra,ffffffffc0200222 <__panic>

ffffffffc0205516 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205516:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020551a:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc020551c:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020551e:	cb81                	beqz	a5,ffffffffc020552e <strlen+0x18>
        cnt ++;
ffffffffc0205520:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0205522:	00a707b3          	add	a5,a4,a0
ffffffffc0205526:	0007c783          	lbu	a5,0(a5)
ffffffffc020552a:	fbfd                	bnez	a5,ffffffffc0205520 <strlen+0xa>
ffffffffc020552c:	8082                	ret
    }
    return cnt;
}
ffffffffc020552e:	8082                	ret

ffffffffc0205530 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205530:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205532:	e589                	bnez	a1,ffffffffc020553c <strnlen+0xc>
ffffffffc0205534:	a811                	j	ffffffffc0205548 <strnlen+0x18>
        cnt ++;
ffffffffc0205536:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205538:	00f58863          	beq	a1,a5,ffffffffc0205548 <strnlen+0x18>
ffffffffc020553c:	00f50733          	add	a4,a0,a5
ffffffffc0205540:	00074703          	lbu	a4,0(a4)
ffffffffc0205544:	fb6d                	bnez	a4,ffffffffc0205536 <strnlen+0x6>
ffffffffc0205546:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205548:	852e                	mv	a0,a1
ffffffffc020554a:	8082                	ret

ffffffffc020554c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020554c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020554e:	0005c703          	lbu	a4,0(a1)
ffffffffc0205552:	0785                	addi	a5,a5,1
ffffffffc0205554:	0585                	addi	a1,a1,1
ffffffffc0205556:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020555a:	fb75                	bnez	a4,ffffffffc020554e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020555c:	8082                	ret

ffffffffc020555e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020555e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205562:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205566:	cb89                	beqz	a5,ffffffffc0205578 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205568:	0505                	addi	a0,a0,1
ffffffffc020556a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020556c:	fee789e3          	beq	a5,a4,ffffffffc020555e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205570:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205574:	9d19                	subw	a0,a0,a4
ffffffffc0205576:	8082                	ret
ffffffffc0205578:	4501                	li	a0,0
ffffffffc020557a:	bfed                	j	ffffffffc0205574 <strcmp+0x16>

ffffffffc020557c <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020557c:	c20d                	beqz	a2,ffffffffc020559e <strncmp+0x22>
ffffffffc020557e:	962e                	add	a2,a2,a1
ffffffffc0205580:	a031                	j	ffffffffc020558c <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0205582:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205584:	00e79a63          	bne	a5,a4,ffffffffc0205598 <strncmp+0x1c>
ffffffffc0205588:	00b60b63          	beq	a2,a1,ffffffffc020559e <strncmp+0x22>
ffffffffc020558c:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205590:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205592:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0205596:	f7f5                	bnez	a5,ffffffffc0205582 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205598:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020559c:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020559e:	4501                	li	a0,0
ffffffffc02055a0:	8082                	ret

ffffffffc02055a2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02055a2:	00054783          	lbu	a5,0(a0)
ffffffffc02055a6:	c799                	beqz	a5,ffffffffc02055b4 <strchr+0x12>
        if (*s == c) {
ffffffffc02055a8:	00f58763          	beq	a1,a5,ffffffffc02055b6 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02055ac:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02055b0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02055b2:	fbfd                	bnez	a5,ffffffffc02055a8 <strchr+0x6>
    }
    return NULL;
ffffffffc02055b4:	4501                	li	a0,0
}
ffffffffc02055b6:	8082                	ret

ffffffffc02055b8 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02055b8:	ca01                	beqz	a2,ffffffffc02055c8 <memset+0x10>
ffffffffc02055ba:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02055bc:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02055be:	0785                	addi	a5,a5,1
ffffffffc02055c0:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02055c4:	fec79de3          	bne	a5,a2,ffffffffc02055be <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02055c8:	8082                	ret

ffffffffc02055ca <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02055ca:	ca19                	beqz	a2,ffffffffc02055e0 <memcpy+0x16>
ffffffffc02055cc:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02055ce:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02055d0:	0005c703          	lbu	a4,0(a1)
ffffffffc02055d4:	0585                	addi	a1,a1,1
ffffffffc02055d6:	0785                	addi	a5,a5,1
ffffffffc02055d8:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02055dc:	fec59ae3          	bne	a1,a2,ffffffffc02055d0 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02055e0:	8082                	ret

ffffffffc02055e2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02055e2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055e6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02055e8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055ec:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02055ee:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02055f2:	f022                	sd	s0,32(sp)
ffffffffc02055f4:	ec26                	sd	s1,24(sp)
ffffffffc02055f6:	e84a                	sd	s2,16(sp)
ffffffffc02055f8:	f406                	sd	ra,40(sp)
ffffffffc02055fa:	e44e                	sd	s3,8(sp)
ffffffffc02055fc:	84aa                	mv	s1,a0
ffffffffc02055fe:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205600:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205604:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0205606:	03067e63          	bgeu	a2,a6,ffffffffc0205642 <printnum+0x60>
ffffffffc020560a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020560c:	00805763          	blez	s0,ffffffffc020561a <printnum+0x38>
ffffffffc0205610:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205612:	85ca                	mv	a1,s2
ffffffffc0205614:	854e                	mv	a0,s3
ffffffffc0205616:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205618:	fc65                	bnez	s0,ffffffffc0205610 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020561a:	1a02                	slli	s4,s4,0x20
ffffffffc020561c:	00003797          	auipc	a5,0x3
ffffffffc0205620:	92c78793          	addi	a5,a5,-1748 # ffffffffc0207f48 <syscalls+0x800>
ffffffffc0205624:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205628:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020562a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020562c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205630:	70a2                	ld	ra,40(sp)
ffffffffc0205632:	69a2                	ld	s3,8(sp)
ffffffffc0205634:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205636:	85ca                	mv	a1,s2
ffffffffc0205638:	87a6                	mv	a5,s1
}
ffffffffc020563a:	6942                	ld	s2,16(sp)
ffffffffc020563c:	64e2                	ld	s1,24(sp)
ffffffffc020563e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205640:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205642:	03065633          	divu	a2,a2,a6
ffffffffc0205646:	8722                	mv	a4,s0
ffffffffc0205648:	f9bff0ef          	jal	ra,ffffffffc02055e2 <printnum>
ffffffffc020564c:	b7f9                	j	ffffffffc020561a <printnum+0x38>

ffffffffc020564e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020564e:	7119                	addi	sp,sp,-128
ffffffffc0205650:	f4a6                	sd	s1,104(sp)
ffffffffc0205652:	f0ca                	sd	s2,96(sp)
ffffffffc0205654:	ecce                	sd	s3,88(sp)
ffffffffc0205656:	e8d2                	sd	s4,80(sp)
ffffffffc0205658:	e4d6                	sd	s5,72(sp)
ffffffffc020565a:	e0da                	sd	s6,64(sp)
ffffffffc020565c:	fc5e                	sd	s7,56(sp)
ffffffffc020565e:	f06a                	sd	s10,32(sp)
ffffffffc0205660:	fc86                	sd	ra,120(sp)
ffffffffc0205662:	f8a2                	sd	s0,112(sp)
ffffffffc0205664:	f862                	sd	s8,48(sp)
ffffffffc0205666:	f466                	sd	s9,40(sp)
ffffffffc0205668:	ec6e                	sd	s11,24(sp)
ffffffffc020566a:	892a                	mv	s2,a0
ffffffffc020566c:	84ae                	mv	s1,a1
ffffffffc020566e:	8d32                	mv	s10,a2
ffffffffc0205670:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205672:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205676:	5b7d                	li	s6,-1
ffffffffc0205678:	00003a97          	auipc	s5,0x3
ffffffffc020567c:	8fca8a93          	addi	s5,s5,-1796 # ffffffffc0207f74 <syscalls+0x82c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205680:	00003b97          	auipc	s7,0x3
ffffffffc0205684:	b10b8b93          	addi	s7,s7,-1264 # ffffffffc0208190 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205688:	000d4503          	lbu	a0,0(s10)
ffffffffc020568c:	001d0413          	addi	s0,s10,1
ffffffffc0205690:	01350a63          	beq	a0,s3,ffffffffc02056a4 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0205694:	c121                	beqz	a0,ffffffffc02056d4 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0205696:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205698:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020569a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020569c:	fff44503          	lbu	a0,-1(s0)
ffffffffc02056a0:	ff351ae3          	bne	a0,s3,ffffffffc0205694 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056a4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02056a8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02056ac:	4c81                	li	s9,0
ffffffffc02056ae:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02056b0:	5c7d                	li	s8,-1
ffffffffc02056b2:	5dfd                	li	s11,-1
ffffffffc02056b4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02056b8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056ba:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02056be:	0ff5f593          	zext.b	a1,a1
ffffffffc02056c2:	00140d13          	addi	s10,s0,1
ffffffffc02056c6:	04b56263          	bltu	a0,a1,ffffffffc020570a <vprintfmt+0xbc>
ffffffffc02056ca:	058a                	slli	a1,a1,0x2
ffffffffc02056cc:	95d6                	add	a1,a1,s5
ffffffffc02056ce:	4194                	lw	a3,0(a1)
ffffffffc02056d0:	96d6                	add	a3,a3,s5
ffffffffc02056d2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02056d4:	70e6                	ld	ra,120(sp)
ffffffffc02056d6:	7446                	ld	s0,112(sp)
ffffffffc02056d8:	74a6                	ld	s1,104(sp)
ffffffffc02056da:	7906                	ld	s2,96(sp)
ffffffffc02056dc:	69e6                	ld	s3,88(sp)
ffffffffc02056de:	6a46                	ld	s4,80(sp)
ffffffffc02056e0:	6aa6                	ld	s5,72(sp)
ffffffffc02056e2:	6b06                	ld	s6,64(sp)
ffffffffc02056e4:	7be2                	ld	s7,56(sp)
ffffffffc02056e6:	7c42                	ld	s8,48(sp)
ffffffffc02056e8:	7ca2                	ld	s9,40(sp)
ffffffffc02056ea:	7d02                	ld	s10,32(sp)
ffffffffc02056ec:	6de2                	ld	s11,24(sp)
ffffffffc02056ee:	6109                	addi	sp,sp,128
ffffffffc02056f0:	8082                	ret
            padc = '0';
ffffffffc02056f2:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02056f4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056f8:	846a                	mv	s0,s10
ffffffffc02056fa:	00140d13          	addi	s10,s0,1
ffffffffc02056fe:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0205702:	0ff5f593          	zext.b	a1,a1
ffffffffc0205706:	fcb572e3          	bgeu	a0,a1,ffffffffc02056ca <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020570a:	85a6                	mv	a1,s1
ffffffffc020570c:	02500513          	li	a0,37
ffffffffc0205710:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205712:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205716:	8d22                	mv	s10,s0
ffffffffc0205718:	f73788e3          	beq	a5,s3,ffffffffc0205688 <vprintfmt+0x3a>
ffffffffc020571c:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205720:	1d7d                	addi	s10,s10,-1
ffffffffc0205722:	ff379de3          	bne	a5,s3,ffffffffc020571c <vprintfmt+0xce>
ffffffffc0205726:	b78d                	j	ffffffffc0205688 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205728:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020572c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205730:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0205732:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0205736:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020573a:	02d86463          	bltu	a6,a3,ffffffffc0205762 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020573e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205742:	002c169b          	slliw	a3,s8,0x2
ffffffffc0205746:	0186873b          	addw	a4,a3,s8
ffffffffc020574a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020574e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0205750:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205754:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205756:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020575a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020575e:	fed870e3          	bgeu	a6,a3,ffffffffc020573e <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0205762:	f40ddce3          	bgez	s11,ffffffffc02056ba <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0205766:	8de2                	mv	s11,s8
ffffffffc0205768:	5c7d                	li	s8,-1
ffffffffc020576a:	bf81                	j	ffffffffc02056ba <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020576c:	fffdc693          	not	a3,s11
ffffffffc0205770:	96fd                	srai	a3,a3,0x3f
ffffffffc0205772:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205776:	00144603          	lbu	a2,1(s0)
ffffffffc020577a:	2d81                	sext.w	s11,s11
ffffffffc020577c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020577e:	bf35                	j	ffffffffc02056ba <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0205780:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205784:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0205788:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020578a:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020578c:	bfd9                	j	ffffffffc0205762 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020578e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205790:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205794:	01174463          	blt	a4,a7,ffffffffc020579c <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0205798:	1a088e63          	beqz	a7,ffffffffc0205954 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020579c:	000a3603          	ld	a2,0(s4)
ffffffffc02057a0:	46c1                	li	a3,16
ffffffffc02057a2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02057a4:	2781                	sext.w	a5,a5
ffffffffc02057a6:	876e                	mv	a4,s11
ffffffffc02057a8:	85a6                	mv	a1,s1
ffffffffc02057aa:	854a                	mv	a0,s2
ffffffffc02057ac:	e37ff0ef          	jal	ra,ffffffffc02055e2 <printnum>
            break;
ffffffffc02057b0:	bde1                	j	ffffffffc0205688 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02057b2:	000a2503          	lw	a0,0(s4)
ffffffffc02057b6:	85a6                	mv	a1,s1
ffffffffc02057b8:	0a21                	addi	s4,s4,8
ffffffffc02057ba:	9902                	jalr	s2
            break;
ffffffffc02057bc:	b5f1                	j	ffffffffc0205688 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02057be:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057c0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057c4:	01174463          	blt	a4,a7,ffffffffc02057cc <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02057c8:	18088163          	beqz	a7,ffffffffc020594a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02057cc:	000a3603          	ld	a2,0(s4)
ffffffffc02057d0:	46a9                	li	a3,10
ffffffffc02057d2:	8a2e                	mv	s4,a1
ffffffffc02057d4:	bfc1                	j	ffffffffc02057a4 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057d6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02057da:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057dc:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057de:	bdf1                	j	ffffffffc02056ba <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02057e0:	85a6                	mv	a1,s1
ffffffffc02057e2:	02500513          	li	a0,37
ffffffffc02057e6:	9902                	jalr	s2
            break;
ffffffffc02057e8:	b545                	j	ffffffffc0205688 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057ea:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02057ee:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057f0:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02057f2:	b5e1                	j	ffffffffc02056ba <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02057f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02057fa:	01174463          	blt	a4,a7,ffffffffc0205802 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02057fe:	14088163          	beqz	a7,ffffffffc0205940 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0205802:	000a3603          	ld	a2,0(s4)
ffffffffc0205806:	46a1                	li	a3,8
ffffffffc0205808:	8a2e                	mv	s4,a1
ffffffffc020580a:	bf69                	j	ffffffffc02057a4 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020580c:	03000513          	li	a0,48
ffffffffc0205810:	85a6                	mv	a1,s1
ffffffffc0205812:	e03e                	sd	a5,0(sp)
ffffffffc0205814:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0205816:	85a6                	mv	a1,s1
ffffffffc0205818:	07800513          	li	a0,120
ffffffffc020581c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020581e:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205820:	6782                	ld	a5,0(sp)
ffffffffc0205822:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205824:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205828:	bfb5                	j	ffffffffc02057a4 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020582a:	000a3403          	ld	s0,0(s4)
ffffffffc020582e:	008a0713          	addi	a4,s4,8
ffffffffc0205832:	e03a                	sd	a4,0(sp)
ffffffffc0205834:	14040263          	beqz	s0,ffffffffc0205978 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205838:	0fb05763          	blez	s11,ffffffffc0205926 <vprintfmt+0x2d8>
ffffffffc020583c:	02d00693          	li	a3,45
ffffffffc0205840:	0cd79163          	bne	a5,a3,ffffffffc0205902 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205844:	00044783          	lbu	a5,0(s0)
ffffffffc0205848:	0007851b          	sext.w	a0,a5
ffffffffc020584c:	cf85                	beqz	a5,ffffffffc0205884 <vprintfmt+0x236>
ffffffffc020584e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205852:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205856:	000c4563          	bltz	s8,ffffffffc0205860 <vprintfmt+0x212>
ffffffffc020585a:	3c7d                	addiw	s8,s8,-1
ffffffffc020585c:	036c0263          	beq	s8,s6,ffffffffc0205880 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205860:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205862:	0e0c8e63          	beqz	s9,ffffffffc020595e <vprintfmt+0x310>
ffffffffc0205866:	3781                	addiw	a5,a5,-32
ffffffffc0205868:	0ef47b63          	bgeu	s0,a5,ffffffffc020595e <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020586c:	03f00513          	li	a0,63
ffffffffc0205870:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205872:	000a4783          	lbu	a5,0(s4)
ffffffffc0205876:	3dfd                	addiw	s11,s11,-1
ffffffffc0205878:	0a05                	addi	s4,s4,1
ffffffffc020587a:	0007851b          	sext.w	a0,a5
ffffffffc020587e:	ffe1                	bnez	a5,ffffffffc0205856 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205880:	01b05963          	blez	s11,ffffffffc0205892 <vprintfmt+0x244>
ffffffffc0205884:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0205886:	85a6                	mv	a1,s1
ffffffffc0205888:	02000513          	li	a0,32
ffffffffc020588c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020588e:	fe0d9be3          	bnez	s11,ffffffffc0205884 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205892:	6a02                	ld	s4,0(sp)
ffffffffc0205894:	bbd5                	j	ffffffffc0205688 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0205896:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205898:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020589c:	01174463          	blt	a4,a7,ffffffffc02058a4 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02058a0:	08088d63          	beqz	a7,ffffffffc020593a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02058a4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02058a8:	0a044d63          	bltz	s0,ffffffffc0205962 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02058ac:	8622                	mv	a2,s0
ffffffffc02058ae:	8a66                	mv	s4,s9
ffffffffc02058b0:	46a9                	li	a3,10
ffffffffc02058b2:	bdcd                	j	ffffffffc02057a4 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02058b4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058b8:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02058ba:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02058bc:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02058c0:	8fb5                	xor	a5,a5,a3
ffffffffc02058c2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02058c6:	02d74163          	blt	a4,a3,ffffffffc02058e8 <vprintfmt+0x29a>
ffffffffc02058ca:	00369793          	slli	a5,a3,0x3
ffffffffc02058ce:	97de                	add	a5,a5,s7
ffffffffc02058d0:	639c                	ld	a5,0(a5)
ffffffffc02058d2:	cb99                	beqz	a5,ffffffffc02058e8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02058d4:	86be                	mv	a3,a5
ffffffffc02058d6:	00000617          	auipc	a2,0x0
ffffffffc02058da:	13a60613          	addi	a2,a2,314 # ffffffffc0205a10 <etext+0x2a>
ffffffffc02058de:	85a6                	mv	a1,s1
ffffffffc02058e0:	854a                	mv	a0,s2
ffffffffc02058e2:	0ce000ef          	jal	ra,ffffffffc02059b0 <printfmt>
ffffffffc02058e6:	b34d                	j	ffffffffc0205688 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02058e8:	00002617          	auipc	a2,0x2
ffffffffc02058ec:	68060613          	addi	a2,a2,1664 # ffffffffc0207f68 <syscalls+0x820>
ffffffffc02058f0:	85a6                	mv	a1,s1
ffffffffc02058f2:	854a                	mv	a0,s2
ffffffffc02058f4:	0bc000ef          	jal	ra,ffffffffc02059b0 <printfmt>
ffffffffc02058f8:	bb41                	j	ffffffffc0205688 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02058fa:	00002417          	auipc	s0,0x2
ffffffffc02058fe:	66640413          	addi	s0,s0,1638 # ffffffffc0207f60 <syscalls+0x818>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205902:	85e2                	mv	a1,s8
ffffffffc0205904:	8522                	mv	a0,s0
ffffffffc0205906:	e43e                	sd	a5,8(sp)
ffffffffc0205908:	c29ff0ef          	jal	ra,ffffffffc0205530 <strnlen>
ffffffffc020590c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205910:	01b05b63          	blez	s11,ffffffffc0205926 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0205914:	67a2                	ld	a5,8(sp)
ffffffffc0205916:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020591a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020591c:	85a6                	mv	a1,s1
ffffffffc020591e:	8552                	mv	a0,s4
ffffffffc0205920:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205922:	fe0d9ce3          	bnez	s11,ffffffffc020591a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205926:	00044783          	lbu	a5,0(s0)
ffffffffc020592a:	00140a13          	addi	s4,s0,1
ffffffffc020592e:	0007851b          	sext.w	a0,a5
ffffffffc0205932:	d3a5                	beqz	a5,ffffffffc0205892 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205934:	05e00413          	li	s0,94
ffffffffc0205938:	bf39                	j	ffffffffc0205856 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020593a:	000a2403          	lw	s0,0(s4)
ffffffffc020593e:	b7ad                	j	ffffffffc02058a8 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205940:	000a6603          	lwu	a2,0(s4)
ffffffffc0205944:	46a1                	li	a3,8
ffffffffc0205946:	8a2e                	mv	s4,a1
ffffffffc0205948:	bdb1                	j	ffffffffc02057a4 <vprintfmt+0x156>
ffffffffc020594a:	000a6603          	lwu	a2,0(s4)
ffffffffc020594e:	46a9                	li	a3,10
ffffffffc0205950:	8a2e                	mv	s4,a1
ffffffffc0205952:	bd89                	j	ffffffffc02057a4 <vprintfmt+0x156>
ffffffffc0205954:	000a6603          	lwu	a2,0(s4)
ffffffffc0205958:	46c1                	li	a3,16
ffffffffc020595a:	8a2e                	mv	s4,a1
ffffffffc020595c:	b5a1                	j	ffffffffc02057a4 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020595e:	9902                	jalr	s2
ffffffffc0205960:	bf09                	j	ffffffffc0205872 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0205962:	85a6                	mv	a1,s1
ffffffffc0205964:	02d00513          	li	a0,45
ffffffffc0205968:	e03e                	sd	a5,0(sp)
ffffffffc020596a:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020596c:	6782                	ld	a5,0(sp)
ffffffffc020596e:	8a66                	mv	s4,s9
ffffffffc0205970:	40800633          	neg	a2,s0
ffffffffc0205974:	46a9                	li	a3,10
ffffffffc0205976:	b53d                	j	ffffffffc02057a4 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205978:	03b05163          	blez	s11,ffffffffc020599a <vprintfmt+0x34c>
ffffffffc020597c:	02d00693          	li	a3,45
ffffffffc0205980:	f6d79de3          	bne	a5,a3,ffffffffc02058fa <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0205984:	00002417          	auipc	s0,0x2
ffffffffc0205988:	5dc40413          	addi	s0,s0,1500 # ffffffffc0207f60 <syscalls+0x818>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020598c:	02800793          	li	a5,40
ffffffffc0205990:	02800513          	li	a0,40
ffffffffc0205994:	00140a13          	addi	s4,s0,1
ffffffffc0205998:	bd6d                	j	ffffffffc0205852 <vprintfmt+0x204>
ffffffffc020599a:	00002a17          	auipc	s4,0x2
ffffffffc020599e:	5c7a0a13          	addi	s4,s4,1479 # ffffffffc0207f61 <syscalls+0x819>
ffffffffc02059a2:	02800513          	li	a0,40
ffffffffc02059a6:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059aa:	05e00413          	li	s0,94
ffffffffc02059ae:	b565                	j	ffffffffc0205856 <vprintfmt+0x208>

ffffffffc02059b0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059b0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02059b2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059b6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059b8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02059ba:	ec06                	sd	ra,24(sp)
ffffffffc02059bc:	f83a                	sd	a4,48(sp)
ffffffffc02059be:	fc3e                	sd	a5,56(sp)
ffffffffc02059c0:	e0c2                	sd	a6,64(sp)
ffffffffc02059c2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02059c4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02059c6:	c89ff0ef          	jal	ra,ffffffffc020564e <vprintfmt>
}
ffffffffc02059ca:	60e2                	ld	ra,24(sp)
ffffffffc02059cc:	6161                	addi	sp,sp,80
ffffffffc02059ce:	8082                	ret

ffffffffc02059d0 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02059d0:	9e3707b7          	lui	a5,0x9e370
ffffffffc02059d4:	2785                	addiw	a5,a5,1
ffffffffc02059d6:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02059da:	02000793          	li	a5,32
ffffffffc02059de:	9f8d                	subw	a5,a5,a1
}
ffffffffc02059e0:	00f5553b          	srlw	a0,a0,a5
ffffffffc02059e4:	8082                	ret
