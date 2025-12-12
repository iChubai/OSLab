
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

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
ffffffffc020004a:	000b1517          	auipc	a0,0xb1
ffffffffc020004e:	c5650513          	addi	a0,a0,-938 # ffffffffc02b0ca0 <buf>
ffffffffc0200052:	000b5617          	auipc	a2,0xb5
ffffffffc0200056:	0fa60613          	addi	a2,a2,250 # ffffffffc02b514c <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	36e050ef          	jal	ra,ffffffffc02053d0 <memset>
    dtb_init();
ffffffffc0200066:	4d6000ef          	jal	ra,ffffffffc020053c <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	0d7000ef          	jal	ra,ffffffffc0200940 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00005597          	auipc	a1,0x5
ffffffffc0200072:	79258593          	addi	a1,a1,1938 # ffffffffc0205800 <etext+0x2>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205820 <etext+0x22>
ffffffffc020007e:	062000ef          	jal	ra,ffffffffc02000e0 <cprintf>

    print_kerninfo();
ffffffffc0200082:	248000ef          	jal	ra,ffffffffc02002ca <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	7ef020ef          	jal	ra,ffffffffc0203074 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	129000ef          	jal	ra,ffffffffc02009b2 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	133000ef          	jal	ra,ffffffffc02009c0 <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	4ce010ef          	jal	ra,ffffffffc0201560 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	6fb040ef          	jal	ra,ffffffffc0204f90 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	053000ef          	jal	ra,ffffffffc02008ec <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	117000ef          	jal	ra,ffffffffc02009b4 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	086050ef          	jal	ra,ffffffffc0205128 <cpu_idle>

ffffffffc02000a6 <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc02000a6:	1141                	addi	sp,sp,-16
ffffffffc02000a8:	e022                	sd	s0,0(sp)
ffffffffc02000aa:	e406                	sd	ra,8(sp)
ffffffffc02000ac:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc02000ae:	095000ef          	jal	ra,ffffffffc0200942 <cons_putc>
    (*cnt)++;
ffffffffc02000b2:	401c                	lw	a5,0(s0)
}
ffffffffc02000b4:	60a2                	ld	ra,8(sp)
    (*cnt)++;
ffffffffc02000b6:	2785                	addiw	a5,a5,1
ffffffffc02000b8:	c01c                	sw	a5,0(s0)
}
ffffffffc02000ba:	6402                	ld	s0,0(sp)
ffffffffc02000bc:	0141                	addi	sp,sp,16
ffffffffc02000be:	8082                	ret

ffffffffc02000c0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc02000c0:	1101                	addi	sp,sp,-32
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fe050513          	addi	a0,a0,-32 # ffffffffc02000a6 <cputch>
ffffffffc02000ce:	006c                	addi	a1,sp,12
{
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d2:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000d4:	392050ef          	jal	ra,ffffffffc0205466 <vprintfmt>
    return cnt;
}
ffffffffc02000d8:	60e2                	ld	ra,24(sp)
ffffffffc02000da:	4532                	lw	a0,12(sp)
ffffffffc02000dc:	6105                	addi	sp,sp,32
ffffffffc02000de:	8082                	ret

ffffffffc02000e0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc02000e0:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e2:	02810313          	addi	t1,sp,40 # ffffffffc020a028 <boot_page_table_sv39+0x28>
{
ffffffffc02000e6:	8e2a                	mv	t3,a0
ffffffffc02000e8:	f42e                	sd	a1,40(sp)
ffffffffc02000ea:	f832                	sd	a2,48(sp)
ffffffffc02000ec:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ee:	00000517          	auipc	a0,0x0
ffffffffc02000f2:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a6 <cputch>
ffffffffc02000f6:	004c                	addi	a1,sp,4
ffffffffc02000f8:	869a                	mv	a3,t1
ffffffffc02000fa:	8672                	mv	a2,t3
{
ffffffffc02000fc:	ec06                	sd	ra,24(sp)
ffffffffc02000fe:	e0ba                	sd	a4,64(sp)
ffffffffc0200100:	e4be                	sd	a5,72(sp)
ffffffffc0200102:	e8c2                	sd	a6,80(sp)
ffffffffc0200104:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200106:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200108:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020010a:	35c050ef          	jal	ra,ffffffffc0205466 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020010e:	60e2                	ld	ra,24(sp)
ffffffffc0200110:	4512                	lw	a0,4(sp)
ffffffffc0200112:	6125                	addi	sp,sp,96
ffffffffc0200114:	8082                	ret

ffffffffc0200116 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc0200116:	02d0006f          	j	ffffffffc0200942 <cons_putc>

ffffffffc020011a <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc020011a:	1101                	addi	sp,sp,-32
ffffffffc020011c:	e822                	sd	s0,16(sp)
ffffffffc020011e:	ec06                	sd	ra,24(sp)
ffffffffc0200120:	e426                	sd	s1,8(sp)
ffffffffc0200122:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc0200124:	00054503          	lbu	a0,0(a0)
ffffffffc0200128:	c51d                	beqz	a0,ffffffffc0200156 <cputs+0x3c>
ffffffffc020012a:	0405                	addi	s0,s0,1
ffffffffc020012c:	4485                	li	s1,1
ffffffffc020012e:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200130:	013000ef          	jal	ra,ffffffffc0200942 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc0200134:	00044503          	lbu	a0,0(s0)
ffffffffc0200138:	008487bb          	addw	a5,s1,s0
ffffffffc020013c:	0405                	addi	s0,s0,1
ffffffffc020013e:	f96d                	bnez	a0,ffffffffc0200130 <cputs+0x16>
    (*cnt)++;
ffffffffc0200140:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200144:	4529                	li	a0,10
ffffffffc0200146:	7fc000ef          	jal	ra,ffffffffc0200942 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020014a:	60e2                	ld	ra,24(sp)
ffffffffc020014c:	8522                	mv	a0,s0
ffffffffc020014e:	6442                	ld	s0,16(sp)
ffffffffc0200150:	64a2                	ld	s1,8(sp)
ffffffffc0200152:	6105                	addi	sp,sp,32
ffffffffc0200154:	8082                	ret
    while ((c = *str++) != '\0')
ffffffffc0200156:	4405                	li	s0,1
ffffffffc0200158:	b7f5                	j	ffffffffc0200144 <cputs+0x2a>

ffffffffc020015a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020015a:	1141                	addi	sp,sp,-16
ffffffffc020015c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020015e:	019000ef          	jal	ra,ffffffffc0200976 <cons_getc>
ffffffffc0200162:	dd75                	beqz	a0,ffffffffc020015e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200164:	60a2                	ld	ra,8(sp)
ffffffffc0200166:	0141                	addi	sp,sp,16
ffffffffc0200168:	8082                	ret

ffffffffc020016a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020016a:	715d                	addi	sp,sp,-80
ffffffffc020016c:	e486                	sd	ra,72(sp)
ffffffffc020016e:	e0a6                	sd	s1,64(sp)
ffffffffc0200170:	fc4a                	sd	s2,56(sp)
ffffffffc0200172:	f84e                	sd	s3,48(sp)
ffffffffc0200174:	f452                	sd	s4,40(sp)
ffffffffc0200176:	f056                	sd	s5,32(sp)
ffffffffc0200178:	ec5a                	sd	s6,24(sp)
ffffffffc020017a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020017c:	c901                	beqz	a0,ffffffffc020018c <readline+0x22>
ffffffffc020017e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0200180:	00005517          	auipc	a0,0x5
ffffffffc0200184:	6a850513          	addi	a0,a0,1704 # ffffffffc0205828 <etext+0x2a>
ffffffffc0200188:	f59ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
readline(const char *prompt) {
ffffffffc020018c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200190:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200192:	4aa9                	li	s5,10
ffffffffc0200194:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200196:	000b1b97          	auipc	s7,0xb1
ffffffffc020019a:	b0ab8b93          	addi	s7,s7,-1270 # ffffffffc02b0ca0 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020019e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02001a2:	fb9ff0ef          	jal	ra,ffffffffc020015a <getchar>
        if (c < 0) {
ffffffffc02001a6:	00054a63          	bltz	a0,ffffffffc02001ba <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001aa:	00a95a63          	bge	s2,a0,ffffffffc02001be <readline+0x54>
ffffffffc02001ae:	029a5263          	bge	s4,s1,ffffffffc02001d2 <readline+0x68>
        c = getchar();
ffffffffc02001b2:	fa9ff0ef          	jal	ra,ffffffffc020015a <getchar>
        if (c < 0) {
ffffffffc02001b6:	fe055ae3          	bgez	a0,ffffffffc02001aa <readline+0x40>
            return NULL;
ffffffffc02001ba:	4501                	li	a0,0
ffffffffc02001bc:	a091                	j	ffffffffc0200200 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02001be:	03351463          	bne	a0,s3,ffffffffc02001e6 <readline+0x7c>
ffffffffc02001c2:	e8a9                	bnez	s1,ffffffffc0200214 <readline+0xaa>
        c = getchar();
ffffffffc02001c4:	f97ff0ef          	jal	ra,ffffffffc020015a <getchar>
        if (c < 0) {
ffffffffc02001c8:	fe0549e3          	bltz	a0,ffffffffc02001ba <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001cc:	fea959e3          	bge	s2,a0,ffffffffc02001be <readline+0x54>
ffffffffc02001d0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02001d2:	e42a                	sd	a0,8(sp)
ffffffffc02001d4:	f43ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i ++] = c;
ffffffffc02001d8:	6522                	ld	a0,8(sp)
ffffffffc02001da:	009b87b3          	add	a5,s7,s1
ffffffffc02001de:	2485                	addiw	s1,s1,1
ffffffffc02001e0:	00a78023          	sb	a0,0(a5)
ffffffffc02001e4:	bf7d                	j	ffffffffc02001a2 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001e6:	01550463          	beq	a0,s5,ffffffffc02001ee <readline+0x84>
ffffffffc02001ea:	fb651ce3          	bne	a0,s6,ffffffffc02001a2 <readline+0x38>
            cputchar(c);
ffffffffc02001ee:	f29ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i] = '\0';
ffffffffc02001f2:	000b1517          	auipc	a0,0xb1
ffffffffc02001f6:	aae50513          	addi	a0,a0,-1362 # ffffffffc02b0ca0 <buf>
ffffffffc02001fa:	94aa                	add	s1,s1,a0
ffffffffc02001fc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200200:	60a6                	ld	ra,72(sp)
ffffffffc0200202:	6486                	ld	s1,64(sp)
ffffffffc0200204:	7962                	ld	s2,56(sp)
ffffffffc0200206:	79c2                	ld	s3,48(sp)
ffffffffc0200208:	7a22                	ld	s4,40(sp)
ffffffffc020020a:	7a82                	ld	s5,32(sp)
ffffffffc020020c:	6b62                	ld	s6,24(sp)
ffffffffc020020e:	6bc2                	ld	s7,16(sp)
ffffffffc0200210:	6161                	addi	sp,sp,80
ffffffffc0200212:	8082                	ret
            cputchar(c);
ffffffffc0200214:	4521                	li	a0,8
ffffffffc0200216:	f01ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            i --;
ffffffffc020021a:	34fd                	addiw	s1,s1,-1
ffffffffc020021c:	b759                	j	ffffffffc02001a2 <readline+0x38>

ffffffffc020021e <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc020021e:	000b5317          	auipc	t1,0xb5
ffffffffc0200222:	eaa30313          	addi	t1,t1,-342 # ffffffffc02b50c8 <is_panic>
ffffffffc0200226:	00033e03          	ld	t3,0(t1)
{
ffffffffc020022a:	715d                	addi	sp,sp,-80
ffffffffc020022c:	ec06                	sd	ra,24(sp)
ffffffffc020022e:	e822                	sd	s0,16(sp)
ffffffffc0200230:	f436                	sd	a3,40(sp)
ffffffffc0200232:	f83a                	sd	a4,48(sp)
ffffffffc0200234:	fc3e                	sd	a5,56(sp)
ffffffffc0200236:	e0c2                	sd	a6,64(sp)
ffffffffc0200238:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020023a:	020e1a63          	bnez	t3,ffffffffc020026e <__panic+0x50>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020023e:	4785                	li	a5,1
ffffffffc0200240:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200244:	8432                	mv	s0,a2
ffffffffc0200246:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200248:	862e                	mv	a2,a1
ffffffffc020024a:	85aa                	mv	a1,a0
ffffffffc020024c:	00005517          	auipc	a0,0x5
ffffffffc0200250:	5e450513          	addi	a0,a0,1508 # ffffffffc0205830 <etext+0x32>
    va_start(ap, fmt);
ffffffffc0200254:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200256:	e8bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020025a:	65a2                	ld	a1,8(sp)
ffffffffc020025c:	8522                	mv	a0,s0
ffffffffc020025e:	e63ff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc0200262:	00007517          	auipc	a0,0x7
ffffffffc0200266:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0206e70 <default_pmm_manager+0x460>
ffffffffc020026a:	e77ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020026e:	4501                	li	a0,0
ffffffffc0200270:	4581                	li	a1,0
ffffffffc0200272:	4601                	li	a2,0
ffffffffc0200274:	48a1                	li	a7,8
ffffffffc0200276:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc020027a:	740000ef          	jal	ra,ffffffffc02009ba <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc020027e:	4501                	li	a0,0
ffffffffc0200280:	174000ef          	jal	ra,ffffffffc02003f4 <kmonitor>
    while (1)
ffffffffc0200284:	bfed                	j	ffffffffc020027e <__panic+0x60>

ffffffffc0200286 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc0200286:	715d                	addi	sp,sp,-80
ffffffffc0200288:	832e                	mv	t1,a1
ffffffffc020028a:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020028c:	85aa                	mv	a1,a0
{
ffffffffc020028e:	8432                	mv	s0,a2
ffffffffc0200290:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200292:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc0200294:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200296:	00005517          	auipc	a0,0x5
ffffffffc020029a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0205850 <etext+0x52>
{
ffffffffc020029e:	ec06                	sd	ra,24(sp)
ffffffffc02002a0:	f436                	sd	a3,40(sp)
ffffffffc02002a2:	f83a                	sd	a4,48(sp)
ffffffffc02002a4:	e0c2                	sd	a6,64(sp)
ffffffffc02002a6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002a8:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002aa:	e37ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002ae:	65a2                	ld	a1,8(sp)
ffffffffc02002b0:	8522                	mv	a0,s0
ffffffffc02002b2:	e0fff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc02002b6:	00007517          	auipc	a0,0x7
ffffffffc02002ba:	bba50513          	addi	a0,a0,-1094 # ffffffffc0206e70 <default_pmm_manager+0x460>
ffffffffc02002be:	e23ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    va_end(ap);
}
ffffffffc02002c2:	60e2                	ld	ra,24(sp)
ffffffffc02002c4:	6442                	ld	s0,16(sp)
ffffffffc02002c6:	6161                	addi	sp,sp,80
ffffffffc02002c8:	8082                	ret

ffffffffc02002ca <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02002ca:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002cc:	00005517          	auipc	a0,0x5
ffffffffc02002d0:	5a450513          	addi	a0,a0,1444 # ffffffffc0205870 <etext+0x72>
{
ffffffffc02002d4:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002d6:	e0bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002da:	00000597          	auipc	a1,0x0
ffffffffc02002de:	d7058593          	addi	a1,a1,-656 # ffffffffc020004a <kern_init>
ffffffffc02002e2:	00005517          	auipc	a0,0x5
ffffffffc02002e6:	5ae50513          	addi	a0,a0,1454 # ffffffffc0205890 <etext+0x92>
ffffffffc02002ea:	df7ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002ee:	00005597          	auipc	a1,0x5
ffffffffc02002f2:	51058593          	addi	a1,a1,1296 # ffffffffc02057fe <etext>
ffffffffc02002f6:	00005517          	auipc	a0,0x5
ffffffffc02002fa:	5ba50513          	addi	a0,a0,1466 # ffffffffc02058b0 <etext+0xb2>
ffffffffc02002fe:	de3ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200302:	000b1597          	auipc	a1,0xb1
ffffffffc0200306:	99e58593          	addi	a1,a1,-1634 # ffffffffc02b0ca0 <buf>
ffffffffc020030a:	00005517          	auipc	a0,0x5
ffffffffc020030e:	5c650513          	addi	a0,a0,1478 # ffffffffc02058d0 <etext+0xd2>
ffffffffc0200312:	dcfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200316:	000b5597          	auipc	a1,0xb5
ffffffffc020031a:	e3658593          	addi	a1,a1,-458 # ffffffffc02b514c <end>
ffffffffc020031e:	00005517          	auipc	a0,0x5
ffffffffc0200322:	5d250513          	addi	a0,a0,1490 # ffffffffc02058f0 <etext+0xf2>
ffffffffc0200326:	dbbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020032a:	000b5597          	auipc	a1,0xb5
ffffffffc020032e:	22158593          	addi	a1,a1,545 # ffffffffc02b554b <end+0x3ff>
ffffffffc0200332:	00000797          	auipc	a5,0x0
ffffffffc0200336:	d1878793          	addi	a5,a5,-744 # ffffffffc020004a <kern_init>
ffffffffc020033a:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020033e:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200342:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200344:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200348:	95be                	add	a1,a1,a5
ffffffffc020034a:	85a9                	srai	a1,a1,0xa
ffffffffc020034c:	00005517          	auipc	a0,0x5
ffffffffc0200350:	5c450513          	addi	a0,a0,1476 # ffffffffc0205910 <etext+0x112>
}
ffffffffc0200354:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200356:	b369                	j	ffffffffc02000e0 <cprintf>

ffffffffc0200358 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc0200358:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020035a:	00005617          	auipc	a2,0x5
ffffffffc020035e:	5e660613          	addi	a2,a2,1510 # ffffffffc0205940 <etext+0x142>
ffffffffc0200362:	04f00593          	li	a1,79
ffffffffc0200366:	00005517          	auipc	a0,0x5
ffffffffc020036a:	5f250513          	addi	a0,a0,1522 # ffffffffc0205958 <etext+0x15a>
{
ffffffffc020036e:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200370:	eafff0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0200374 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200374:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200376:	00005617          	auipc	a2,0x5
ffffffffc020037a:	5fa60613          	addi	a2,a2,1530 # ffffffffc0205970 <etext+0x172>
ffffffffc020037e:	00005597          	auipc	a1,0x5
ffffffffc0200382:	61258593          	addi	a1,a1,1554 # ffffffffc0205990 <etext+0x192>
ffffffffc0200386:	00005517          	auipc	a0,0x5
ffffffffc020038a:	61250513          	addi	a0,a0,1554 # ffffffffc0205998 <etext+0x19a>
{
ffffffffc020038e:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200390:	d51ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200394:	00005617          	auipc	a2,0x5
ffffffffc0200398:	61460613          	addi	a2,a2,1556 # ffffffffc02059a8 <etext+0x1aa>
ffffffffc020039c:	00005597          	auipc	a1,0x5
ffffffffc02003a0:	63458593          	addi	a1,a1,1588 # ffffffffc02059d0 <etext+0x1d2>
ffffffffc02003a4:	00005517          	auipc	a0,0x5
ffffffffc02003a8:	5f450513          	addi	a0,a0,1524 # ffffffffc0205998 <etext+0x19a>
ffffffffc02003ac:	d35ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02003b0:	00005617          	auipc	a2,0x5
ffffffffc02003b4:	63060613          	addi	a2,a2,1584 # ffffffffc02059e0 <etext+0x1e2>
ffffffffc02003b8:	00005597          	auipc	a1,0x5
ffffffffc02003bc:	64858593          	addi	a1,a1,1608 # ffffffffc0205a00 <etext+0x202>
ffffffffc02003c0:	00005517          	auipc	a0,0x5
ffffffffc02003c4:	5d850513          	addi	a0,a0,1496 # ffffffffc0205998 <etext+0x19a>
ffffffffc02003c8:	d19ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    return 0;
}
ffffffffc02003cc:	60a2                	ld	ra,8(sp)
ffffffffc02003ce:	4501                	li	a0,0
ffffffffc02003d0:	0141                	addi	sp,sp,16
ffffffffc02003d2:	8082                	ret

ffffffffc02003d4 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02003d4:	1141                	addi	sp,sp,-16
ffffffffc02003d6:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003d8:	ef3ff0ef          	jal	ra,ffffffffc02002ca <print_kerninfo>
    return 0;
}
ffffffffc02003dc:	60a2                	ld	ra,8(sp)
ffffffffc02003de:	4501                	li	a0,0
ffffffffc02003e0:	0141                	addi	sp,sp,16
ffffffffc02003e2:	8082                	ret

ffffffffc02003e4 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02003e4:	1141                	addi	sp,sp,-16
ffffffffc02003e6:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003e8:	f71ff0ef          	jal	ra,ffffffffc0200358 <print_stackframe>
    return 0;
}
ffffffffc02003ec:	60a2                	ld	ra,8(sp)
ffffffffc02003ee:	4501                	li	a0,0
ffffffffc02003f0:	0141                	addi	sp,sp,16
ffffffffc02003f2:	8082                	ret

ffffffffc02003f4 <kmonitor>:
{
ffffffffc02003f4:	7115                	addi	sp,sp,-224
ffffffffc02003f6:	ed5e                	sd	s7,152(sp)
ffffffffc02003f8:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003fa:	00005517          	auipc	a0,0x5
ffffffffc02003fe:	61650513          	addi	a0,a0,1558 # ffffffffc0205a10 <etext+0x212>
{
ffffffffc0200402:	ed86                	sd	ra,216(sp)
ffffffffc0200404:	e9a2                	sd	s0,208(sp)
ffffffffc0200406:	e5a6                	sd	s1,200(sp)
ffffffffc0200408:	e1ca                	sd	s2,192(sp)
ffffffffc020040a:	fd4e                	sd	s3,184(sp)
ffffffffc020040c:	f952                	sd	s4,176(sp)
ffffffffc020040e:	f556                	sd	s5,168(sp)
ffffffffc0200410:	f15a                	sd	s6,160(sp)
ffffffffc0200412:	e962                	sd	s8,144(sp)
ffffffffc0200414:	e566                	sd	s9,136(sp)
ffffffffc0200416:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200418:	cc9ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020041c:	00005517          	auipc	a0,0x5
ffffffffc0200420:	61c50513          	addi	a0,a0,1564 # ffffffffc0205a38 <etext+0x23a>
ffffffffc0200424:	cbdff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    if (tf != NULL)
ffffffffc0200428:	000b8563          	beqz	s7,ffffffffc0200432 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020042c:	855e                	mv	a0,s7
ffffffffc020042e:	77a000ef          	jal	ra,ffffffffc0200ba8 <print_trapframe>
ffffffffc0200432:	00005c17          	auipc	s8,0x5
ffffffffc0200436:	676c0c13          	addi	s8,s8,1654 # ffffffffc0205aa8 <commands>
        if ((buf = readline("K> ")) != NULL)
ffffffffc020043a:	00005917          	auipc	s2,0x5
ffffffffc020043e:	62690913          	addi	s2,s2,1574 # ffffffffc0205a60 <etext+0x262>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200442:	00005497          	auipc	s1,0x5
ffffffffc0200446:	62648493          	addi	s1,s1,1574 # ffffffffc0205a68 <etext+0x26a>
        if (argc == MAXARGS - 1)
ffffffffc020044a:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020044c:	00005b17          	auipc	s6,0x5
ffffffffc0200450:	624b0b13          	addi	s6,s6,1572 # ffffffffc0205a70 <etext+0x272>
        argv[argc++] = buf;
ffffffffc0200454:	00005a17          	auipc	s4,0x5
ffffffffc0200458:	53ca0a13          	addi	s4,s4,1340 # ffffffffc0205990 <etext+0x192>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020045c:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL)
ffffffffc020045e:	854a                	mv	a0,s2
ffffffffc0200460:	d0bff0ef          	jal	ra,ffffffffc020016a <readline>
ffffffffc0200464:	842a                	mv	s0,a0
ffffffffc0200466:	dd65                	beqz	a0,ffffffffc020045e <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200468:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020046c:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020046e:	e1bd                	bnez	a1,ffffffffc02004d4 <kmonitor+0xe0>
    if (argc == 0)
ffffffffc0200470:	fe0c87e3          	beqz	s9,ffffffffc020045e <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00005d17          	auipc	s10,0x5
ffffffffc020047a:	632d0d13          	addi	s10,s10,1586 # ffffffffc0205aa8 <commands>
        argv[argc++] = buf;
ffffffffc020047e:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200480:	4401                	li	s0,0
ffffffffc0200482:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200484:	6f3040ef          	jal	ra,ffffffffc0205376 <strcmp>
ffffffffc0200488:	c919                	beqz	a0,ffffffffc020049e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020048a:	2405                	addiw	s0,s0,1
ffffffffc020048c:	0b540063          	beq	s0,s5,ffffffffc020052c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200490:	000d3503          	ld	a0,0(s10)
ffffffffc0200494:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200496:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200498:	6df040ef          	jal	ra,ffffffffc0205376 <strcmp>
ffffffffc020049c:	f57d                	bnez	a0,ffffffffc020048a <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020049e:	00141793          	slli	a5,s0,0x1
ffffffffc02004a2:	97a2                	add	a5,a5,s0
ffffffffc02004a4:	078e                	slli	a5,a5,0x3
ffffffffc02004a6:	97e2                	add	a5,a5,s8
ffffffffc02004a8:	6b9c                	ld	a5,16(a5)
ffffffffc02004aa:	865e                	mv	a2,s7
ffffffffc02004ac:	002c                	addi	a1,sp,8
ffffffffc02004ae:	fffc851b          	addiw	a0,s9,-1
ffffffffc02004b2:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc02004b4:	fa0555e3          	bgez	a0,ffffffffc020045e <kmonitor+0x6a>
}
ffffffffc02004b8:	60ee                	ld	ra,216(sp)
ffffffffc02004ba:	644e                	ld	s0,208(sp)
ffffffffc02004bc:	64ae                	ld	s1,200(sp)
ffffffffc02004be:	690e                	ld	s2,192(sp)
ffffffffc02004c0:	79ea                	ld	s3,184(sp)
ffffffffc02004c2:	7a4a                	ld	s4,176(sp)
ffffffffc02004c4:	7aaa                	ld	s5,168(sp)
ffffffffc02004c6:	7b0a                	ld	s6,160(sp)
ffffffffc02004c8:	6bea                	ld	s7,152(sp)
ffffffffc02004ca:	6c4a                	ld	s8,144(sp)
ffffffffc02004cc:	6caa                	ld	s9,136(sp)
ffffffffc02004ce:	6d0a                	ld	s10,128(sp)
ffffffffc02004d0:	612d                	addi	sp,sp,224
ffffffffc02004d2:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02004d4:	8526                	mv	a0,s1
ffffffffc02004d6:	6e5040ef          	jal	ra,ffffffffc02053ba <strchr>
ffffffffc02004da:	c901                	beqz	a0,ffffffffc02004ea <kmonitor+0xf6>
ffffffffc02004dc:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc02004e0:	00040023          	sb	zero,0(s0)
ffffffffc02004e4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02004e6:	d5c9                	beqz	a1,ffffffffc0200470 <kmonitor+0x7c>
ffffffffc02004e8:	b7f5                	j	ffffffffc02004d4 <kmonitor+0xe0>
        if (*buf == '\0')
ffffffffc02004ea:	00044783          	lbu	a5,0(s0)
ffffffffc02004ee:	d3c9                	beqz	a5,ffffffffc0200470 <kmonitor+0x7c>
        if (argc == MAXARGS - 1)
ffffffffc02004f0:	033c8963          	beq	s9,s3,ffffffffc0200522 <kmonitor+0x12e>
        argv[argc++] = buf;
ffffffffc02004f4:	003c9793          	slli	a5,s9,0x3
ffffffffc02004f8:	0118                	addi	a4,sp,128
ffffffffc02004fa:	97ba                	add	a5,a5,a4
ffffffffc02004fc:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200500:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200504:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200506:	e591                	bnez	a1,ffffffffc0200512 <kmonitor+0x11e>
ffffffffc0200508:	b7b5                	j	ffffffffc0200474 <kmonitor+0x80>
ffffffffc020050a:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc020050e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200510:	d1a5                	beqz	a1,ffffffffc0200470 <kmonitor+0x7c>
ffffffffc0200512:	8526                	mv	a0,s1
ffffffffc0200514:	6a7040ef          	jal	ra,ffffffffc02053ba <strchr>
ffffffffc0200518:	d96d                	beqz	a0,ffffffffc020050a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020051a:	00044583          	lbu	a1,0(s0)
ffffffffc020051e:	d9a9                	beqz	a1,ffffffffc0200470 <kmonitor+0x7c>
ffffffffc0200520:	bf55                	j	ffffffffc02004d4 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200522:	45c1                	li	a1,16
ffffffffc0200524:	855a                	mv	a0,s6
ffffffffc0200526:	bbbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc020052a:	b7e9                	j	ffffffffc02004f4 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020052c:	6582                	ld	a1,0(sp)
ffffffffc020052e:	00005517          	auipc	a0,0x5
ffffffffc0200532:	56250513          	addi	a0,a0,1378 # ffffffffc0205a90 <etext+0x292>
ffffffffc0200536:	babff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
ffffffffc020053a:	b715                	j	ffffffffc020045e <kmonitor+0x6a>

ffffffffc020053c <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc020053c:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc020053e:	00005517          	auipc	a0,0x5
ffffffffc0200542:	5b250513          	addi	a0,a0,1458 # ffffffffc0205af0 <commands+0x48>
void dtb_init(void) {
ffffffffc0200546:	fc86                	sd	ra,120(sp)
ffffffffc0200548:	f8a2                	sd	s0,112(sp)
ffffffffc020054a:	e8d2                	sd	s4,80(sp)
ffffffffc020054c:	f4a6                	sd	s1,104(sp)
ffffffffc020054e:	f0ca                	sd	s2,96(sp)
ffffffffc0200550:	ecce                	sd	s3,88(sp)
ffffffffc0200552:	e4d6                	sd	s5,72(sp)
ffffffffc0200554:	e0da                	sd	s6,64(sp)
ffffffffc0200556:	fc5e                	sd	s7,56(sp)
ffffffffc0200558:	f862                	sd	s8,48(sp)
ffffffffc020055a:	f466                	sd	s9,40(sp)
ffffffffc020055c:	f06a                	sd	s10,32(sp)
ffffffffc020055e:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc0200560:	b81ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200564:	0000b597          	auipc	a1,0xb
ffffffffc0200568:	a9c5b583          	ld	a1,-1380(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc020056c:	00005517          	auipc	a0,0x5
ffffffffc0200570:	59450513          	addi	a0,a0,1428 # ffffffffc0205b00 <commands+0x58>
ffffffffc0200574:	b6dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200578:	0000b417          	auipc	s0,0xb
ffffffffc020057c:	a9040413          	addi	s0,s0,-1392 # ffffffffc020b008 <boot_dtb>
ffffffffc0200580:	600c                	ld	a1,0(s0)
ffffffffc0200582:	00005517          	auipc	a0,0x5
ffffffffc0200586:	58e50513          	addi	a0,a0,1422 # ffffffffc0205b10 <commands+0x68>
ffffffffc020058a:	b57ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020058e:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200592:	00005517          	auipc	a0,0x5
ffffffffc0200596:	59650513          	addi	a0,a0,1430 # ffffffffc0205b28 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc020059a:	120a0463          	beqz	s4,ffffffffc02006c2 <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020059e:	57f5                	li	a5,-3
ffffffffc02005a0:	07fa                	slli	a5,a5,0x1e
ffffffffc02005a2:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02005a6:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a8:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ac:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ae:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005b2:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b6:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ba:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005be:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c2:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005c4:	8ec9                	or	a3,a3,a0
ffffffffc02005c6:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005ca:	1b7d                	addi	s6,s6,-1
ffffffffc02005cc:	0167f7b3          	and	a5,a5,s6
ffffffffc02005d0:	8dd5                	or	a1,a1,a3
ffffffffc02005d2:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02005d4:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005d8:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02005da:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfe2ada1>
ffffffffc02005de:	10f59163          	bne	a1,a5,ffffffffc02006e0 <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02005e2:	471c                	lw	a5,8(a4)
ffffffffc02005e4:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02005e6:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e8:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02005ec:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02005f0:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f4:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f8:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005fc:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200600:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200604:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200608:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020060c:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200610:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200612:	01146433          	or	s0,s0,a7
ffffffffc0200616:	0086969b          	slliw	a3,a3,0x8
ffffffffc020061a:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020061e:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200620:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200624:	8c49                	or	s0,s0,a0
ffffffffc0200626:	0166f6b3          	and	a3,a3,s6
ffffffffc020062a:	00ca6a33          	or	s4,s4,a2
ffffffffc020062e:	0167f7b3          	and	a5,a5,s6
ffffffffc0200632:	8c55                	or	s0,s0,a3
ffffffffc0200634:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200638:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020063a:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020063c:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020063e:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200642:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200644:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200646:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc020064a:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020064c:	00005917          	auipc	s2,0x5
ffffffffc0200650:	52c90913          	addi	s2,s2,1324 # ffffffffc0205b78 <commands+0xd0>
ffffffffc0200654:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200656:	4d91                	li	s11,4
ffffffffc0200658:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020065a:	00005497          	auipc	s1,0x5
ffffffffc020065e:	51648493          	addi	s1,s1,1302 # ffffffffc0205b70 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200662:	000a2703          	lw	a4,0(s4)
ffffffffc0200666:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066a:	0087569b          	srliw	a3,a4,0x8
ffffffffc020066e:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200672:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200676:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067a:	0107571b          	srliw	a4,a4,0x10
ffffffffc020067e:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200680:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200684:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200688:	8fd5                	or	a5,a5,a3
ffffffffc020068a:	00eb7733          	and	a4,s6,a4
ffffffffc020068e:	8fd9                	or	a5,a5,a4
ffffffffc0200690:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc0200692:	09778c63          	beq	a5,s7,ffffffffc020072a <dtb_init+0x1ee>
ffffffffc0200696:	00fbea63          	bltu	s7,a5,ffffffffc02006aa <dtb_init+0x16e>
ffffffffc020069a:	07a78663          	beq	a5,s10,ffffffffc0200706 <dtb_init+0x1ca>
ffffffffc020069e:	4709                	li	a4,2
ffffffffc02006a0:	00e79763          	bne	a5,a4,ffffffffc02006ae <dtb_init+0x172>
ffffffffc02006a4:	4c81                	li	s9,0
ffffffffc02006a6:	8a56                	mv	s4,s5
ffffffffc02006a8:	bf6d                	j	ffffffffc0200662 <dtb_init+0x126>
ffffffffc02006aa:	ffb78ee3          	beq	a5,s11,ffffffffc02006a6 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006ae:	00005517          	auipc	a0,0x5
ffffffffc02006b2:	54250513          	addi	a0,a0,1346 # ffffffffc0205bf0 <commands+0x148>
ffffffffc02006b6:	a2bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006ba:	00005517          	auipc	a0,0x5
ffffffffc02006be:	56e50513          	addi	a0,a0,1390 # ffffffffc0205c28 <commands+0x180>
}
ffffffffc02006c2:	7446                	ld	s0,112(sp)
ffffffffc02006c4:	70e6                	ld	ra,120(sp)
ffffffffc02006c6:	74a6                	ld	s1,104(sp)
ffffffffc02006c8:	7906                	ld	s2,96(sp)
ffffffffc02006ca:	69e6                	ld	s3,88(sp)
ffffffffc02006cc:	6a46                	ld	s4,80(sp)
ffffffffc02006ce:	6aa6                	ld	s5,72(sp)
ffffffffc02006d0:	6b06                	ld	s6,64(sp)
ffffffffc02006d2:	7be2                	ld	s7,56(sp)
ffffffffc02006d4:	7c42                	ld	s8,48(sp)
ffffffffc02006d6:	7ca2                	ld	s9,40(sp)
ffffffffc02006d8:	7d02                	ld	s10,32(sp)
ffffffffc02006da:	6de2                	ld	s11,24(sp)
ffffffffc02006dc:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02006de:	b409                	j	ffffffffc02000e0 <cprintf>
}
ffffffffc02006e0:	7446                	ld	s0,112(sp)
ffffffffc02006e2:	70e6                	ld	ra,120(sp)
ffffffffc02006e4:	74a6                	ld	s1,104(sp)
ffffffffc02006e6:	7906                	ld	s2,96(sp)
ffffffffc02006e8:	69e6                	ld	s3,88(sp)
ffffffffc02006ea:	6a46                	ld	s4,80(sp)
ffffffffc02006ec:	6aa6                	ld	s5,72(sp)
ffffffffc02006ee:	6b06                	ld	s6,64(sp)
ffffffffc02006f0:	7be2                	ld	s7,56(sp)
ffffffffc02006f2:	7c42                	ld	s8,48(sp)
ffffffffc02006f4:	7ca2                	ld	s9,40(sp)
ffffffffc02006f6:	7d02                	ld	s10,32(sp)
ffffffffc02006f8:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	44e50513          	addi	a0,a0,1102 # ffffffffc0205b48 <commands+0xa0>
}
ffffffffc0200702:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200704:	baf1                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200706:	8556                	mv	a0,s5
ffffffffc0200708:	427040ef          	jal	ra,ffffffffc020532e <strlen>
ffffffffc020070c:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020070e:	4619                	li	a2,6
ffffffffc0200710:	85a6                	mv	a1,s1
ffffffffc0200712:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200714:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200716:	47f040ef          	jal	ra,ffffffffc0205394 <strncmp>
ffffffffc020071a:	e111                	bnez	a0,ffffffffc020071e <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc020071c:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020071e:	0a91                	addi	s5,s5,4
ffffffffc0200720:	9ad2                	add	s5,s5,s4
ffffffffc0200722:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200726:	8a56                	mv	s4,s5
ffffffffc0200728:	bf2d                	j	ffffffffc0200662 <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020072a:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020072e:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200732:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200736:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020073a:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073e:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200742:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200746:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020074a:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020074e:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200752:	00eaeab3          	or	s5,s5,a4
ffffffffc0200756:	00fb77b3          	and	a5,s6,a5
ffffffffc020075a:	00faeab3          	or	s5,s5,a5
ffffffffc020075e:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200760:	000c9c63          	bnez	s9,ffffffffc0200778 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200764:	1a82                	slli	s5,s5,0x20
ffffffffc0200766:	00368793          	addi	a5,a3,3
ffffffffc020076a:	020ada93          	srli	s5,s5,0x20
ffffffffc020076e:	9abe                	add	s5,s5,a5
ffffffffc0200770:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200774:	8a56                	mv	s4,s5
ffffffffc0200776:	b5f5                	j	ffffffffc0200662 <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200778:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020077c:	85ca                	mv	a1,s2
ffffffffc020077e:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200780:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200784:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	0187971b          	slliw	a4,a5,0x18
ffffffffc020078c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200790:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200794:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200796:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020079a:	0087979b          	slliw	a5,a5,0x8
ffffffffc020079e:	8d59                	or	a0,a0,a4
ffffffffc02007a0:	00fb77b3          	and	a5,s6,a5
ffffffffc02007a4:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007a6:	1502                	slli	a0,a0,0x20
ffffffffc02007a8:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007aa:	9522                	add	a0,a0,s0
ffffffffc02007ac:	3cb040ef          	jal	ra,ffffffffc0205376 <strcmp>
ffffffffc02007b0:	66a2                	ld	a3,8(sp)
ffffffffc02007b2:	f94d                	bnez	a0,ffffffffc0200764 <dtb_init+0x228>
ffffffffc02007b4:	fb59f8e3          	bgeu	s3,s5,ffffffffc0200764 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007b8:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007bc:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007c0:	00005517          	auipc	a0,0x5
ffffffffc02007c4:	3c050513          	addi	a0,a0,960 # ffffffffc0205b80 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc02007c8:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007cc:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02007d0:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d4:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02007d8:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007dc:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007e0:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007e4:	0187d693          	srli	a3,a5,0x18
ffffffffc02007e8:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02007ec:	0087579b          	srliw	a5,a4,0x8
ffffffffc02007f0:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f4:	0106561b          	srliw	a2,a2,0x10
ffffffffc02007f8:	010f6f33          	or	t5,t5,a6
ffffffffc02007fc:	0187529b          	srliw	t0,a4,0x18
ffffffffc0200800:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200804:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200808:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080c:	0186f6b3          	and	a3,a3,s8
ffffffffc0200810:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200814:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200818:	0107581b          	srliw	a6,a4,0x10
ffffffffc020081c:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200820:	8361                	srli	a4,a4,0x18
ffffffffc0200822:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200826:	0105d59b          	srliw	a1,a1,0x10
ffffffffc020082a:	01e6e6b3          	or	a3,a3,t5
ffffffffc020082e:	00cb7633          	and	a2,s6,a2
ffffffffc0200832:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200836:	0085959b          	slliw	a1,a1,0x8
ffffffffc020083a:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020083e:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200842:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200846:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020084a:	0088989b          	slliw	a7,a7,0x8
ffffffffc020084e:	011b78b3          	and	a7,s6,a7
ffffffffc0200852:	005eeeb3          	or	t4,t4,t0
ffffffffc0200856:	00c6e733          	or	a4,a3,a2
ffffffffc020085a:	006c6c33          	or	s8,s8,t1
ffffffffc020085e:	010b76b3          	and	a3,s6,a6
ffffffffc0200862:	00bb7b33          	and	s6,s6,a1
ffffffffc0200866:	01d7e7b3          	or	a5,a5,t4
ffffffffc020086a:	016c6b33          	or	s6,s8,s6
ffffffffc020086e:	01146433          	or	s0,s0,a7
ffffffffc0200872:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc0200874:	1702                	slli	a4,a4,0x20
ffffffffc0200876:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200878:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020087a:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020087c:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020087e:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200882:	0167eb33          	or	s6,a5,s6
ffffffffc0200886:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200888:	859ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020088c:	85a2                	mv	a1,s0
ffffffffc020088e:	00005517          	auipc	a0,0x5
ffffffffc0200892:	31250513          	addi	a0,a0,786 # ffffffffc0205ba0 <commands+0xf8>
ffffffffc0200896:	84bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc020089a:	014b5613          	srli	a2,s6,0x14
ffffffffc020089e:	85da                	mv	a1,s6
ffffffffc02008a0:	00005517          	auipc	a0,0x5
ffffffffc02008a4:	31850513          	addi	a0,a0,792 # ffffffffc0205bb8 <commands+0x110>
ffffffffc02008a8:	839ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008ac:	008b05b3          	add	a1,s6,s0
ffffffffc02008b0:	15fd                	addi	a1,a1,-1
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	32650513          	addi	a0,a0,806 # ffffffffc0205bd8 <commands+0x130>
ffffffffc02008ba:	827ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	36a50513          	addi	a0,a0,874 # ffffffffc0205c28 <commands+0x180>
        memory_base = mem_base;
ffffffffc02008c6:	000b5797          	auipc	a5,0xb5
ffffffffc02008ca:	8087b523          	sd	s0,-2038(a5) # ffffffffc02b50d0 <memory_base>
        memory_size = mem_size;
ffffffffc02008ce:	000b5797          	auipc	a5,0xb5
ffffffffc02008d2:	8167b523          	sd	s6,-2038(a5) # ffffffffc02b50d8 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02008d6:	b3f5                	j	ffffffffc02006c2 <dtb_init+0x186>

ffffffffc02008d8 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008d8:	000b4517          	auipc	a0,0xb4
ffffffffc02008dc:	7f853503          	ld	a0,2040(a0) # ffffffffc02b50d0 <memory_base>
ffffffffc02008e0:	8082                	ret

ffffffffc02008e2 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008e2:	000b4517          	auipc	a0,0xb4
ffffffffc02008e6:	7f653503          	ld	a0,2038(a0) # ffffffffc02b50d8 <memory_size>
ffffffffc02008ea:	8082                	ret

ffffffffc02008ec <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02008ec:	67e1                	lui	a5,0x18
ffffffffc02008ee:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd568>
ffffffffc02008f2:	000b4717          	auipc	a4,0xb4
ffffffffc02008f6:	7ef73b23          	sd	a5,2038(a4) # ffffffffc02b50e8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02008fa:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02008fe:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200900:	953e                	add	a0,a0,a5
ffffffffc0200902:	4601                	li	a2,0
ffffffffc0200904:	4881                	li	a7,0
ffffffffc0200906:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020090a:	02000793          	li	a5,32
ffffffffc020090e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200912:	00005517          	auipc	a0,0x5
ffffffffc0200916:	32e50513          	addi	a0,a0,814 # ffffffffc0205c40 <commands+0x198>
    ticks = 0;
ffffffffc020091a:	000b4797          	auipc	a5,0xb4
ffffffffc020091e:	7c07b323          	sd	zero,1990(a5) # ffffffffc02b50e0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200922:	fbeff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200926 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200926:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020092a:	000b4797          	auipc	a5,0xb4
ffffffffc020092e:	7be7b783          	ld	a5,1982(a5) # ffffffffc02b50e8 <timebase>
ffffffffc0200932:	953e                	add	a0,a0,a5
ffffffffc0200934:	4581                	li	a1,0
ffffffffc0200936:	4601                	li	a2,0
ffffffffc0200938:	4881                	li	a7,0
ffffffffc020093a:	00000073          	ecall
ffffffffc020093e:	8082                	ret

ffffffffc0200940 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200940:	8082                	ret

ffffffffc0200942 <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200942:	100027f3          	csrr	a5,sstatus
ffffffffc0200946:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200948:	0ff57513          	zext.b	a0,a0
ffffffffc020094c:	e799                	bnez	a5,ffffffffc020095a <cons_putc+0x18>
ffffffffc020094e:	4581                	li	a1,0
ffffffffc0200950:	4601                	li	a2,0
ffffffffc0200952:	4885                	li	a7,1
ffffffffc0200954:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc0200958:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020095a:	1101                	addi	sp,sp,-32
ffffffffc020095c:	ec06                	sd	ra,24(sp)
ffffffffc020095e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200960:	05a000ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0200964:	6522                	ld	a0,8(sp)
ffffffffc0200966:	4581                	li	a1,0
ffffffffc0200968:	4601                	li	a2,0
ffffffffc020096a:	4885                	li	a7,1
ffffffffc020096c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200970:	60e2                	ld	ra,24(sp)
ffffffffc0200972:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc0200974:	a081                	j	ffffffffc02009b4 <intr_enable>

ffffffffc0200976 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200976:	100027f3          	csrr	a5,sstatus
ffffffffc020097a:	8b89                	andi	a5,a5,2
ffffffffc020097c:	eb89                	bnez	a5,ffffffffc020098e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020097e:	4501                	li	a0,0
ffffffffc0200980:	4581                	li	a1,0
ffffffffc0200982:	4601                	li	a2,0
ffffffffc0200984:	4889                	li	a7,2
ffffffffc0200986:	00000073          	ecall
ffffffffc020098a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020098c:	8082                	ret
int cons_getc(void) {
ffffffffc020098e:	1101                	addi	sp,sp,-32
ffffffffc0200990:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200992:	028000ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0200996:	4501                	li	a0,0
ffffffffc0200998:	4581                	li	a1,0
ffffffffc020099a:	4601                	li	a2,0
ffffffffc020099c:	4889                	li	a7,2
ffffffffc020099e:	00000073          	ecall
ffffffffc02009a2:	2501                	sext.w	a0,a0
ffffffffc02009a4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02009a6:	00e000ef          	jal	ra,ffffffffc02009b4 <intr_enable>
}
ffffffffc02009aa:	60e2                	ld	ra,24(sp)
ffffffffc02009ac:	6522                	ld	a0,8(sp)
ffffffffc02009ae:	6105                	addi	sp,sp,32
ffffffffc02009b0:	8082                	ret

ffffffffc02009b2 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02009b2:	8082                	ret

ffffffffc02009b4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009b4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02009b8:	8082                	ret

ffffffffc02009ba <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02009ba:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02009be:	8082                	ret

ffffffffc02009c0 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02009c0:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02009c4:	00000797          	auipc	a5,0x0
ffffffffc02009c8:	6b078793          	addi	a5,a5,1712 # ffffffffc0201074 <__alltraps>
ffffffffc02009cc:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc02009d0:	000407b7          	lui	a5,0x40
ffffffffc02009d4:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02009d8:	8082                	ret

ffffffffc02009da <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009da:	610c                	ld	a1,0(a0)
{
ffffffffc02009dc:	1141                	addi	sp,sp,-16
ffffffffc02009de:	e022                	sd	s0,0(sp)
ffffffffc02009e0:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009e2:	00005517          	auipc	a0,0x5
ffffffffc02009e6:	27e50513          	addi	a0,a0,638 # ffffffffc0205c60 <commands+0x1b8>
{
ffffffffc02009ea:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02009ec:	ef4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02009f0:	640c                	ld	a1,8(s0)
ffffffffc02009f2:	00005517          	auipc	a0,0x5
ffffffffc02009f6:	28650513          	addi	a0,a0,646 # ffffffffc0205c78 <commands+0x1d0>
ffffffffc02009fa:	ee6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02009fe:	680c                	ld	a1,16(s0)
ffffffffc0200a00:	00005517          	auipc	a0,0x5
ffffffffc0200a04:	29050513          	addi	a0,a0,656 # ffffffffc0205c90 <commands+0x1e8>
ffffffffc0200a08:	ed8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200a0c:	6c0c                	ld	a1,24(s0)
ffffffffc0200a0e:	00005517          	auipc	a0,0x5
ffffffffc0200a12:	29a50513          	addi	a0,a0,666 # ffffffffc0205ca8 <commands+0x200>
ffffffffc0200a16:	ecaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200a1a:	700c                	ld	a1,32(s0)
ffffffffc0200a1c:	00005517          	auipc	a0,0x5
ffffffffc0200a20:	2a450513          	addi	a0,a0,676 # ffffffffc0205cc0 <commands+0x218>
ffffffffc0200a24:	ebcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200a28:	740c                	ld	a1,40(s0)
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	2ae50513          	addi	a0,a0,686 # ffffffffc0205cd8 <commands+0x230>
ffffffffc0200a32:	eaeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200a36:	780c                	ld	a1,48(s0)
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	2b850513          	addi	a0,a0,696 # ffffffffc0205cf0 <commands+0x248>
ffffffffc0200a40:	ea0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200a44:	7c0c                	ld	a1,56(s0)
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	2c250513          	addi	a0,a0,706 # ffffffffc0205d08 <commands+0x260>
ffffffffc0200a4e:	e92ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200a52:	602c                	ld	a1,64(s0)
ffffffffc0200a54:	00005517          	auipc	a0,0x5
ffffffffc0200a58:	2cc50513          	addi	a0,a0,716 # ffffffffc0205d20 <commands+0x278>
ffffffffc0200a5c:	e84ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200a60:	642c                	ld	a1,72(s0)
ffffffffc0200a62:	00005517          	auipc	a0,0x5
ffffffffc0200a66:	2d650513          	addi	a0,a0,726 # ffffffffc0205d38 <commands+0x290>
ffffffffc0200a6a:	e76ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200a6e:	682c                	ld	a1,80(s0)
ffffffffc0200a70:	00005517          	auipc	a0,0x5
ffffffffc0200a74:	2e050513          	addi	a0,a0,736 # ffffffffc0205d50 <commands+0x2a8>
ffffffffc0200a78:	e68ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200a7c:	6c2c                	ld	a1,88(s0)
ffffffffc0200a7e:	00005517          	auipc	a0,0x5
ffffffffc0200a82:	2ea50513          	addi	a0,a0,746 # ffffffffc0205d68 <commands+0x2c0>
ffffffffc0200a86:	e5aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a8a:	702c                	ld	a1,96(s0)
ffffffffc0200a8c:	00005517          	auipc	a0,0x5
ffffffffc0200a90:	2f450513          	addi	a0,a0,756 # ffffffffc0205d80 <commands+0x2d8>
ffffffffc0200a94:	e4cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a98:	742c                	ld	a1,104(s0)
ffffffffc0200a9a:	00005517          	auipc	a0,0x5
ffffffffc0200a9e:	2fe50513          	addi	a0,a0,766 # ffffffffc0205d98 <commands+0x2f0>
ffffffffc0200aa2:	e3eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200aa6:	782c                	ld	a1,112(s0)
ffffffffc0200aa8:	00005517          	auipc	a0,0x5
ffffffffc0200aac:	30850513          	addi	a0,a0,776 # ffffffffc0205db0 <commands+0x308>
ffffffffc0200ab0:	e30ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200ab4:	7c2c                	ld	a1,120(s0)
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	31250513          	addi	a0,a0,786 # ffffffffc0205dc8 <commands+0x320>
ffffffffc0200abe:	e22ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200ac2:	604c                	ld	a1,128(s0)
ffffffffc0200ac4:	00005517          	auipc	a0,0x5
ffffffffc0200ac8:	31c50513          	addi	a0,a0,796 # ffffffffc0205de0 <commands+0x338>
ffffffffc0200acc:	e14ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200ad0:	644c                	ld	a1,136(s0)
ffffffffc0200ad2:	00005517          	auipc	a0,0x5
ffffffffc0200ad6:	32650513          	addi	a0,a0,806 # ffffffffc0205df8 <commands+0x350>
ffffffffc0200ada:	e06ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200ade:	684c                	ld	a1,144(s0)
ffffffffc0200ae0:	00005517          	auipc	a0,0x5
ffffffffc0200ae4:	33050513          	addi	a0,a0,816 # ffffffffc0205e10 <commands+0x368>
ffffffffc0200ae8:	df8ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200aec:	6c4c                	ld	a1,152(s0)
ffffffffc0200aee:	00005517          	auipc	a0,0x5
ffffffffc0200af2:	33a50513          	addi	a0,a0,826 # ffffffffc0205e28 <commands+0x380>
ffffffffc0200af6:	deaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200afa:	704c                	ld	a1,160(s0)
ffffffffc0200afc:	00005517          	auipc	a0,0x5
ffffffffc0200b00:	34450513          	addi	a0,a0,836 # ffffffffc0205e40 <commands+0x398>
ffffffffc0200b04:	ddcff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200b08:	744c                	ld	a1,168(s0)
ffffffffc0200b0a:	00005517          	auipc	a0,0x5
ffffffffc0200b0e:	34e50513          	addi	a0,a0,846 # ffffffffc0205e58 <commands+0x3b0>
ffffffffc0200b12:	dceff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200b16:	784c                	ld	a1,176(s0)
ffffffffc0200b18:	00005517          	auipc	a0,0x5
ffffffffc0200b1c:	35850513          	addi	a0,a0,856 # ffffffffc0205e70 <commands+0x3c8>
ffffffffc0200b20:	dc0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200b24:	7c4c                	ld	a1,184(s0)
ffffffffc0200b26:	00005517          	auipc	a0,0x5
ffffffffc0200b2a:	36250513          	addi	a0,a0,866 # ffffffffc0205e88 <commands+0x3e0>
ffffffffc0200b2e:	db2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200b32:	606c                	ld	a1,192(s0)
ffffffffc0200b34:	00005517          	auipc	a0,0x5
ffffffffc0200b38:	36c50513          	addi	a0,a0,876 # ffffffffc0205ea0 <commands+0x3f8>
ffffffffc0200b3c:	da4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200b40:	646c                	ld	a1,200(s0)
ffffffffc0200b42:	00005517          	auipc	a0,0x5
ffffffffc0200b46:	37650513          	addi	a0,a0,886 # ffffffffc0205eb8 <commands+0x410>
ffffffffc0200b4a:	d96ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200b4e:	686c                	ld	a1,208(s0)
ffffffffc0200b50:	00005517          	auipc	a0,0x5
ffffffffc0200b54:	38050513          	addi	a0,a0,896 # ffffffffc0205ed0 <commands+0x428>
ffffffffc0200b58:	d88ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200b5c:	6c6c                	ld	a1,216(s0)
ffffffffc0200b5e:	00005517          	auipc	a0,0x5
ffffffffc0200b62:	38a50513          	addi	a0,a0,906 # ffffffffc0205ee8 <commands+0x440>
ffffffffc0200b66:	d7aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200b6a:	706c                	ld	a1,224(s0)
ffffffffc0200b6c:	00005517          	auipc	a0,0x5
ffffffffc0200b70:	39450513          	addi	a0,a0,916 # ffffffffc0205f00 <commands+0x458>
ffffffffc0200b74:	d6cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200b78:	746c                	ld	a1,232(s0)
ffffffffc0200b7a:	00005517          	auipc	a0,0x5
ffffffffc0200b7e:	39e50513          	addi	a0,a0,926 # ffffffffc0205f18 <commands+0x470>
ffffffffc0200b82:	d5eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b86:	786c                	ld	a1,240(s0)
ffffffffc0200b88:	00005517          	auipc	a0,0x5
ffffffffc0200b8c:	3a850513          	addi	a0,a0,936 # ffffffffc0205f30 <commands+0x488>
ffffffffc0200b90:	d50ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b94:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b96:	6402                	ld	s0,0(sp)
ffffffffc0200b98:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b9a:	00005517          	auipc	a0,0x5
ffffffffc0200b9e:	3ae50513          	addi	a0,a0,942 # ffffffffc0205f48 <commands+0x4a0>
}
ffffffffc0200ba2:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ba4:	d3cff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200ba8 <print_trapframe>:
{
ffffffffc0200ba8:	1141                	addi	sp,sp,-16
ffffffffc0200baa:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bac:	85aa                	mv	a1,a0
{
ffffffffc0200bae:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bb0:	00005517          	auipc	a0,0x5
ffffffffc0200bb4:	3b050513          	addi	a0,a0,944 # ffffffffc0205f60 <commands+0x4b8>
{
ffffffffc0200bb8:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200bba:	d26ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200bbe:	8522                	mv	a0,s0
ffffffffc0200bc0:	e1bff0ef          	jal	ra,ffffffffc02009da <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200bc4:	10043583          	ld	a1,256(s0)
ffffffffc0200bc8:	00005517          	auipc	a0,0x5
ffffffffc0200bcc:	3b050513          	addi	a0,a0,944 # ffffffffc0205f78 <commands+0x4d0>
ffffffffc0200bd0:	d10ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200bd4:	10843583          	ld	a1,264(s0)
ffffffffc0200bd8:	00005517          	auipc	a0,0x5
ffffffffc0200bdc:	3b850513          	addi	a0,a0,952 # ffffffffc0205f90 <commands+0x4e8>
ffffffffc0200be0:	d00ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200be4:	11043583          	ld	a1,272(s0)
ffffffffc0200be8:	00005517          	auipc	a0,0x5
ffffffffc0200bec:	3c050513          	addi	a0,a0,960 # ffffffffc0205fa8 <commands+0x500>
ffffffffc0200bf0:	cf0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bf4:	11843583          	ld	a1,280(s0)
}
ffffffffc0200bf8:	6402                	ld	s0,0(sp)
ffffffffc0200bfa:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200bfc:	00005517          	auipc	a0,0x5
ffffffffc0200c00:	3bc50513          	addi	a0,a0,956 # ffffffffc0205fb8 <commands+0x510>
}
ffffffffc0200c04:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200c06:	cdaff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200c0a <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200c0a:	11853783          	ld	a5,280(a0)
ffffffffc0200c0e:	472d                	li	a4,11
ffffffffc0200c10:	0786                	slli	a5,a5,0x1
ffffffffc0200c12:	8385                	srli	a5,a5,0x1
ffffffffc0200c14:	0af76363          	bltu	a4,a5,ffffffffc0200cba <interrupt_handler+0xb0>
ffffffffc0200c18:	00005717          	auipc	a4,0x5
ffffffffc0200c1c:	47870713          	addi	a4,a4,1144 # ffffffffc0206090 <commands+0x5e8>
ffffffffc0200c20:	078a                	slli	a5,a5,0x2
ffffffffc0200c22:	97ba                	add	a5,a5,a4
ffffffffc0200c24:	439c                	lw	a5,0(a5)
ffffffffc0200c26:	97ba                	add	a5,a5,a4
ffffffffc0200c28:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200c2a:	00005517          	auipc	a0,0x5
ffffffffc0200c2e:	40650513          	addi	a0,a0,1030 # ffffffffc0206030 <commands+0x588>
ffffffffc0200c32:	caeff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c36:	00005517          	auipc	a0,0x5
ffffffffc0200c3a:	3da50513          	addi	a0,a0,986 # ffffffffc0206010 <commands+0x568>
ffffffffc0200c3e:	ca2ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c42:	00005517          	auipc	a0,0x5
ffffffffc0200c46:	38e50513          	addi	a0,a0,910 # ffffffffc0205fd0 <commands+0x528>
ffffffffc0200c4a:	c96ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c4e:	00005517          	auipc	a0,0x5
ffffffffc0200c52:	3a250513          	addi	a0,a0,930 # ffffffffc0205ff0 <commands+0x548>
ffffffffc0200c56:	c8aff06f          	j	ffffffffc02000e0 <cprintf>
{
ffffffffc0200c5a:	1141                	addi	sp,sp,-16
ffffffffc0200c5c:	e022                	sd	s0,0(sp)
ffffffffc0200c5e:	e406                	sd	ra,8(sp)
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();
ffffffffc0200c60:	cc7ff0ef          	jal	ra,ffffffffc0200926 <clock_set_next_event>
        ticks++;
ffffffffc0200c64:	000b4797          	auipc	a5,0xb4
ffffffffc0200c68:	47c78793          	addi	a5,a5,1148 # ffffffffc02b50e0 <ticks>
ffffffffc0200c6c:	6398                	ld	a4,0(a5)
ffffffffc0200c6e:	000b4417          	auipc	s0,0xb4
ffffffffc0200c72:	48240413          	addi	s0,s0,1154 # ffffffffc02b50f0 <num>
ffffffffc0200c76:	0705                	addi	a4,a4,1
ffffffffc0200c78:	e398                	sd	a4,0(a5)
        if (ticks % 100 == 0) {
ffffffffc0200c7a:	639c                	ld	a5,0(a5)
ffffffffc0200c7c:	06400713          	li	a4,100
ffffffffc0200c80:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200c84:	cf85                	beqz	a5,ffffffffc0200cbc <interrupt_handler+0xb2>
            cprintf("100 ticks\n");
            num++;
            print_ticks();
        }
        current->need_resched = 1;
        if (num == 10) {
ffffffffc0200c86:	4018                	lw	a4,0(s0)
        current->need_resched = 1;
ffffffffc0200c88:	000b4797          	auipc	a5,0xb4
ffffffffc0200c8c:	4a87b783          	ld	a5,1192(a5) # ffffffffc02b5130 <current>
ffffffffc0200c90:	4685                	li	a3,1
ffffffffc0200c92:	ef94                	sd	a3,24(a5)
        if (num == 10) {
ffffffffc0200c94:	47a9                	li	a5,10
ffffffffc0200c96:	00f71863          	bne	a4,a5,ffffffffc0200ca6 <interrupt_handler+0x9c>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c9a:	4501                	li	a0,0
ffffffffc0200c9c:	4581                	li	a1,0
ffffffffc0200c9e:	4601                	li	a2,0
ffffffffc0200ca0:	48a1                	li	a7,8
ffffffffc0200ca2:	00000073          	ecall
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200ca6:	60a2                	ld	ra,8(sp)
ffffffffc0200ca8:	6402                	ld	s0,0(sp)
ffffffffc0200caa:	0141                	addi	sp,sp,16
ffffffffc0200cac:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200cae:	00005517          	auipc	a0,0x5
ffffffffc0200cb2:	3c250513          	addi	a0,a0,962 # ffffffffc0206070 <commands+0x5c8>
ffffffffc0200cb6:	c2aff06f          	j	ffffffffc02000e0 <cprintf>
        print_trapframe(tf);
ffffffffc0200cba:	b5fd                	j	ffffffffc0200ba8 <print_trapframe>
            cprintf("100 ticks\n");
ffffffffc0200cbc:	00005517          	auipc	a0,0x5
ffffffffc0200cc0:	39450513          	addi	a0,a0,916 # ffffffffc0206050 <commands+0x5a8>
ffffffffc0200cc4:	c1cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
            num++;
ffffffffc0200cc8:	401c                	lw	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200cca:	06400593          	li	a1,100
ffffffffc0200cce:	00005517          	auipc	a0,0x5
ffffffffc0200cd2:	39250513          	addi	a0,a0,914 # ffffffffc0206060 <commands+0x5b8>
            num++;
ffffffffc0200cd6:	2785                	addiw	a5,a5,1
ffffffffc0200cd8:	c01c                	sw	a5,0(s0)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200cda:	c06ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0200cde:	b765                	j	ffffffffc0200c86 <interrupt_handler+0x7c>

ffffffffc0200ce0 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200ce0:	11853783          	ld	a5,280(a0)
{
ffffffffc0200ce4:	715d                	addi	sp,sp,-80
ffffffffc0200ce6:	e0a2                	sd	s0,64(sp)
ffffffffc0200ce8:	e486                	sd	ra,72(sp)
ffffffffc0200cea:	fc26                	sd	s1,56(sp)
ffffffffc0200cec:	f84a                	sd	s2,48(sp)
ffffffffc0200cee:	f44e                	sd	s3,40(sp)
ffffffffc0200cf0:	f052                	sd	s4,32(sp)
ffffffffc0200cf2:	ec56                	sd	s5,24(sp)
ffffffffc0200cf4:	e85a                	sd	s6,16(sp)
ffffffffc0200cf6:	e45e                	sd	s7,8(sp)
ffffffffc0200cf8:	473d                	li	a4,15
ffffffffc0200cfa:	842a                	mv	s0,a0
ffffffffc0200cfc:	1ef76563          	bltu	a4,a5,ffffffffc0200ee6 <exception_handler+0x206>
ffffffffc0200d00:	00005717          	auipc	a4,0x5
ffffffffc0200d04:	5f870713          	addi	a4,a4,1528 # ffffffffc02062f8 <commands+0x850>
ffffffffc0200d08:	078a                	slli	a5,a5,0x2
ffffffffc0200d0a:	97ba                	add	a5,a5,a4
ffffffffc0200d0c:	439c                	lw	a5,0(a5)
ffffffffc0200d0e:	97ba                	add	a5,a5,a4
ffffffffc0200d10:	8782                	jr	a5
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200d12:	00005517          	auipc	a0,0x5
ffffffffc0200d16:	49650513          	addi	a0,a0,1174 # ffffffffc02061a8 <commands+0x700>
ffffffffc0200d1a:	bc6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        tf->epc += 4;
ffffffffc0200d1e:	10843783          	ld	a5,264(s0)
    }
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200d22:	60a6                	ld	ra,72(sp)
ffffffffc0200d24:	74e2                	ld	s1,56(sp)
        tf->epc += 4;
ffffffffc0200d26:	0791                	addi	a5,a5,4
ffffffffc0200d28:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200d2c:	6406                	ld	s0,64(sp)
ffffffffc0200d2e:	7942                	ld	s2,48(sp)
ffffffffc0200d30:	79a2                	ld	s3,40(sp)
ffffffffc0200d32:	7a02                	ld	s4,32(sp)
ffffffffc0200d34:	6ae2                	ld	s5,24(sp)
ffffffffc0200d36:	6b42                	ld	s6,16(sp)
ffffffffc0200d38:	6ba2                	ld	s7,8(sp)
ffffffffc0200d3a:	6161                	addi	sp,sp,80
        syscall();
ffffffffc0200d3c:	5720406f          	j	ffffffffc02052ae <syscall>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d40:	00005517          	auipc	a0,0x5
ffffffffc0200d44:	48850513          	addi	a0,a0,1160 # ffffffffc02061c8 <commands+0x720>
}
ffffffffc0200d48:	6406                	ld	s0,64(sp)
ffffffffc0200d4a:	60a6                	ld	ra,72(sp)
ffffffffc0200d4c:	74e2                	ld	s1,56(sp)
ffffffffc0200d4e:	7942                	ld	s2,48(sp)
ffffffffc0200d50:	79a2                	ld	s3,40(sp)
ffffffffc0200d52:	7a02                	ld	s4,32(sp)
ffffffffc0200d54:	6ae2                	ld	s5,24(sp)
ffffffffc0200d56:	6b42                	ld	s6,16(sp)
ffffffffc0200d58:	6ba2                	ld	s7,8(sp)
ffffffffc0200d5a:	6161                	addi	sp,sp,80
        cprintf("Instruction access fault\n");
ffffffffc0200d5c:	b84ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d60:	00005517          	auipc	a0,0x5
ffffffffc0200d64:	48850513          	addi	a0,a0,1160 # ffffffffc02061e8 <commands+0x740>
ffffffffc0200d68:	b7c5                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Instruction page fault\n");
ffffffffc0200d6a:	00005517          	auipc	a0,0x5
ffffffffc0200d6e:	49e50513          	addi	a0,a0,1182 # ffffffffc0206208 <commands+0x760>
ffffffffc0200d72:	bfd9                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Load page fault\n");
ffffffffc0200d74:	00005517          	auipc	a0,0x5
ffffffffc0200d78:	4ac50513          	addi	a0,a0,1196 # ffffffffc0206220 <commands+0x778>
ffffffffc0200d7c:	b7f1                	j	ffffffffc0200d48 <exception_handler+0x68>
        if (current != NULL && current->mm != NULL)
ffffffffc0200d7e:	000b4497          	auipc	s1,0xb4
ffffffffc0200d82:	3b248493          	addi	s1,s1,946 # ffffffffc02b5130 <current>
ffffffffc0200d86:	609c                	ld	a5,0(s1)
ffffffffc0200d88:	16078b63          	beqz	a5,ffffffffc0200efe <exception_handler+0x21e>
ffffffffc0200d8c:	779c                	ld	a5,40(a5)
ffffffffc0200d8e:	16078863          	beqz	a5,ffffffffc0200efe <exception_handler+0x21e>
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200d92:	11053703          	ld	a4,272(a0)
ffffffffc0200d96:	747d                	lui	s0,0xfffff
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200d98:	6f88                	ld	a0,24(a5)
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200d9a:	8c79                	and	s0,s0,a4
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200d9c:	4601                	li	a2,0
ffffffffc0200d9e:	85a2                	mv	a1,s0
ffffffffc0200da0:	2ef010ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc0200da4:	87aa                	mv	a5,a0
            if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW))
ffffffffc0200da6:	14050c63          	beqz	a0,ffffffffc0200efe <exception_handler+0x21e>
ffffffffc0200daa:	6118                	ld	a4,0(a0)
ffffffffc0200dac:	20100693          	li	a3,513
ffffffffc0200db0:	20177613          	andi	a2,a4,513
ffffffffc0200db4:	14d61563          	bne	a2,a3,ffffffffc0200efe <exception_handler+0x21e>
}

static inline struct Page *
pte2page(pte_t pte)
{
    if (!(pte & PTE_V))
ffffffffc0200db8:	00177693          	andi	a3,a4,1
                uint32_t perm = (*ptep & PTE_USER);
ffffffffc0200dbc:	0007091b          	sext.w	s2,a4
ffffffffc0200dc0:	20068863          	beqz	a3,ffffffffc0200fd0 <exception_handler+0x2f0>
    if (PPN(pa) >= npage)
ffffffffc0200dc4:	000b4b17          	auipc	s6,0xb4
ffffffffc0200dc8:	34cb0b13          	addi	s6,s6,844 # ffffffffc02b5110 <npage>
ffffffffc0200dcc:	000b3683          	ld	a3,0(s6)
    {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200dd0:	070a                	slli	a4,a4,0x2
ffffffffc0200dd2:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0200dd4:	1ed77263          	bgeu	a4,a3,ffffffffc0200fb8 <exception_handler+0x2d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0200dd8:	000b4b97          	auipc	s7,0xb4
ffffffffc0200ddc:	340b8b93          	addi	s7,s7,832 # ffffffffc02b5118 <pages>
ffffffffc0200de0:	000bb983          	ld	s3,0(s7)
ffffffffc0200de4:	00007a17          	auipc	s4,0x7
ffffffffc0200de8:	b6ca3a03          	ld	s4,-1172(s4) # ffffffffc0207950 <nbase>
ffffffffc0200dec:	41470733          	sub	a4,a4,s4
ffffffffc0200df0:	071a                	slli	a4,a4,0x6
ffffffffc0200df2:	99ba                	add	s3,s3,a4
                if (page_ref(page) > 1)
ffffffffc0200df4:	0009a603          	lw	a2,0(s3)
ffffffffc0200df8:	4685                	li	a3,1
ffffffffc0200dfa:	14c6dd63          	bge	a3,a2,ffffffffc0200f54 <exception_handler+0x274>
                    struct Page *npage = alloc_page();
ffffffffc0200dfe:	4505                	li	a0,1
ffffffffc0200e00:	1d7010ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0200e04:	8aaa                	mv	s5,a0
                    if (npage == NULL)
ffffffffc0200e06:	18050d63          	beqz	a0,ffffffffc0200fa0 <exception_handler+0x2c0>
    return page - pages + nbase;
ffffffffc0200e0a:	000bb583          	ld	a1,0(s7)
    return KADDR(page2pa(page));
ffffffffc0200e0e:	577d                	li	a4,-1
ffffffffc0200e10:	000b3603          	ld	a2,0(s6)
    return page - pages + nbase;
ffffffffc0200e14:	40b507b3          	sub	a5,a0,a1
ffffffffc0200e18:	8799                	srai	a5,a5,0x6
ffffffffc0200e1a:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0200e1c:	8331                	srli	a4,a4,0xc
ffffffffc0200e1e:	00e7f533          	and	a0,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e22:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e26:	16c57163          	bgeu	a0,a2,ffffffffc0200f88 <exception_handler+0x2a8>
    return page - pages + nbase;
ffffffffc0200e2a:	40b987b3          	sub	a5,s3,a1
ffffffffc0200e2e:	8799                	srai	a5,a5,0x6
ffffffffc0200e30:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0200e32:	000b4597          	auipc	a1,0xb4
ffffffffc0200e36:	2f65b583          	ld	a1,758(a1) # ffffffffc02b5128 <va_pa_offset>
ffffffffc0200e3a:	8f7d                	and	a4,a4,a5
ffffffffc0200e3c:	00b68533          	add	a0,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e40:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e44:	14c77263          	bgeu	a4,a2,ffffffffc0200f88 <exception_handler+0x2a8>
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0200e48:	95b6                	add	a1,a1,a3
ffffffffc0200e4a:	6605                	lui	a2,0x1
ffffffffc0200e4c:	596040ef          	jal	ra,ffffffffc02053e2 <memcpy>
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e50:	609c                	ld	a5,0(s1)
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200e52:	01b97693          	andi	a3,s2,27
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e56:	0046e693          	ori	a3,a3,4
ffffffffc0200e5a:	779c                	ld	a5,40(a5)
ffffffffc0200e5c:	8622                	mv	a2,s0
ffffffffc0200e5e:	85d6                	mv	a1,s5
ffffffffc0200e60:	6f88                	ld	a0,24(a5)
ffffffffc0200e62:	11c020ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc0200e66:	c531                	beqz	a0,ffffffffc0200eb2 <exception_handler+0x1d2>
                        panic("COW: insert fail\n");
ffffffffc0200e68:	00005617          	auipc	a2,0x5
ffffffffc0200e6c:	46060613          	addi	a2,a2,1120 # ffffffffc02062c8 <commands+0x820>
ffffffffc0200e70:	0f700593          	li	a1,247
ffffffffc0200e74:	00005517          	auipc	a0,0x5
ffffffffc0200e78:	30450513          	addi	a0,a0,772 # ffffffffc0206178 <commands+0x6d0>
ffffffffc0200e7c:	ba2ff0ef          	jal	ra,ffffffffc020021e <__panic>
        cprintf("Instruction address misaligned\n");
ffffffffc0200e80:	00005517          	auipc	a0,0x5
ffffffffc0200e84:	24050513          	addi	a0,a0,576 # ffffffffc02060c0 <commands+0x618>
ffffffffc0200e88:	b5c1                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Instruction access fault\n");
ffffffffc0200e8a:	00005517          	auipc	a0,0x5
ffffffffc0200e8e:	25650513          	addi	a0,a0,598 # ffffffffc02060e0 <commands+0x638>
ffffffffc0200e92:	bd5d                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Illegal instruction\n");
ffffffffc0200e94:	00005517          	auipc	a0,0x5
ffffffffc0200e98:	26c50513          	addi	a0,a0,620 # ffffffffc0206100 <commands+0x658>
ffffffffc0200e9c:	b575                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Breakpoint\n");
ffffffffc0200e9e:	00005517          	auipc	a0,0x5
ffffffffc0200ea2:	27a50513          	addi	a0,a0,634 # ffffffffc0206118 <commands+0x670>
ffffffffc0200ea6:	a3aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200eaa:	6458                	ld	a4,136(s0)
ffffffffc0200eac:	47a9                	li	a5,10
ffffffffc0200eae:	06f70963          	beq	a4,a5,ffffffffc0200f20 <exception_handler+0x240>
}
ffffffffc0200eb2:	60a6                	ld	ra,72(sp)
ffffffffc0200eb4:	6406                	ld	s0,64(sp)
ffffffffc0200eb6:	74e2                	ld	s1,56(sp)
ffffffffc0200eb8:	7942                	ld	s2,48(sp)
ffffffffc0200eba:	79a2                	ld	s3,40(sp)
ffffffffc0200ebc:	7a02                	ld	s4,32(sp)
ffffffffc0200ebe:	6ae2                	ld	s5,24(sp)
ffffffffc0200ec0:	6b42                	ld	s6,16(sp)
ffffffffc0200ec2:	6ba2                	ld	s7,8(sp)
ffffffffc0200ec4:	6161                	addi	sp,sp,80
ffffffffc0200ec6:	8082                	ret
        cprintf("Load address misaligned\n");
ffffffffc0200ec8:	00005517          	auipc	a0,0x5
ffffffffc0200ecc:	26050513          	addi	a0,a0,608 # ffffffffc0206128 <commands+0x680>
ffffffffc0200ed0:	bda5                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Load access fault\n");
ffffffffc0200ed2:	00005517          	auipc	a0,0x5
ffffffffc0200ed6:	27650513          	addi	a0,a0,630 # ffffffffc0206148 <commands+0x6a0>
ffffffffc0200eda:	b5bd                	j	ffffffffc0200d48 <exception_handler+0x68>
        cprintf("Store/AMO access fault\n");
ffffffffc0200edc:	00005517          	auipc	a0,0x5
ffffffffc0200ee0:	2b450513          	addi	a0,a0,692 # ffffffffc0206190 <commands+0x6e8>
ffffffffc0200ee4:	b595                	j	ffffffffc0200d48 <exception_handler+0x68>
        print_trapframe(tf);
ffffffffc0200ee6:	8522                	mv	a0,s0
}
ffffffffc0200ee8:	6406                	ld	s0,64(sp)
ffffffffc0200eea:	60a6                	ld	ra,72(sp)
ffffffffc0200eec:	74e2                	ld	s1,56(sp)
ffffffffc0200eee:	7942                	ld	s2,48(sp)
ffffffffc0200ef0:	79a2                	ld	s3,40(sp)
ffffffffc0200ef2:	7a02                	ld	s4,32(sp)
ffffffffc0200ef4:	6ae2                	ld	s5,24(sp)
ffffffffc0200ef6:	6b42                	ld	s6,16(sp)
ffffffffc0200ef8:	6ba2                	ld	s7,8(sp)
ffffffffc0200efa:	6161                	addi	sp,sp,80
        print_trapframe(tf);
ffffffffc0200efc:	b175                	j	ffffffffc0200ba8 <print_trapframe>
        cprintf("Store/AMO page fault\n");
ffffffffc0200efe:	00005517          	auipc	a0,0x5
ffffffffc0200f02:	3e250513          	addi	a0,a0,994 # ffffffffc02062e0 <commands+0x838>
ffffffffc0200f06:	b589                	j	ffffffffc0200d48 <exception_handler+0x68>
        panic("AMO address misaligned\n");
ffffffffc0200f08:	00005617          	auipc	a2,0x5
ffffffffc0200f0c:	25860613          	addi	a2,a2,600 # ffffffffc0206160 <commands+0x6b8>
ffffffffc0200f10:	0c700593          	li	a1,199
ffffffffc0200f14:	00005517          	auipc	a0,0x5
ffffffffc0200f18:	26450513          	addi	a0,a0,612 # ffffffffc0206178 <commands+0x6d0>
ffffffffc0200f1c:	b02ff0ef          	jal	ra,ffffffffc020021e <__panic>
            tf->epc += 4;
ffffffffc0200f20:	10843783          	ld	a5,264(s0) # fffffffffffff108 <end+0x3fd49fbc>
ffffffffc0200f24:	0791                	addi	a5,a5,4
ffffffffc0200f26:	10f43423          	sd	a5,264(s0)
            syscall();
ffffffffc0200f2a:	384040ef          	jal	ra,ffffffffc02052ae <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200f2e:	000b4797          	auipc	a5,0xb4
ffffffffc0200f32:	2027b783          	ld	a5,514(a5) # ffffffffc02b5130 <current>
ffffffffc0200f36:	6b9c                	ld	a5,16(a5)
ffffffffc0200f38:	8522                	mv	a0,s0
}
ffffffffc0200f3a:	6406                	ld	s0,64(sp)
ffffffffc0200f3c:	60a6                	ld	ra,72(sp)
ffffffffc0200f3e:	74e2                	ld	s1,56(sp)
ffffffffc0200f40:	7942                	ld	s2,48(sp)
ffffffffc0200f42:	79a2                	ld	s3,40(sp)
ffffffffc0200f44:	7a02                	ld	s4,32(sp)
ffffffffc0200f46:	6ae2                	ld	s5,24(sp)
ffffffffc0200f48:	6b42                	ld	s6,16(sp)
ffffffffc0200f4a:	6ba2                	ld	s7,8(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200f4c:	6589                	lui	a1,0x2
ffffffffc0200f4e:	95be                	add	a1,a1,a5
}
ffffffffc0200f50:	6161                	addi	sp,sp,80
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200f52:	aac5                	j	ffffffffc0201142 <kernel_execve_ret>
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f54:	6094                	ld	a3,0(s1)
    return page - pages + nbase;
ffffffffc0200f56:	8719                	srai	a4,a4,0x6
ffffffffc0200f58:	9752                	add	a4,a4,s4
ffffffffc0200f5a:	7694                	ld	a3,40(a3)
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200f5c:	01b97913          	andi	s2,s2,27
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200f60:	072a                	slli	a4,a4,0xa
ffffffffc0200f62:	00e96733          	or	a4,s2,a4
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f66:	85a2                	mv	a1,s0
}
ffffffffc0200f68:	6406                	ld	s0,64(sp)
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f6a:	6e88                	ld	a0,24(a3)
}
ffffffffc0200f6c:	60a6                	ld	ra,72(sp)
ffffffffc0200f6e:	74e2                	ld	s1,56(sp)
ffffffffc0200f70:	7942                	ld	s2,48(sp)
ffffffffc0200f72:	79a2                	ld	s3,40(sp)
ffffffffc0200f74:	7a02                	ld	s4,32(sp)
ffffffffc0200f76:	6ae2                	ld	s5,24(sp)
ffffffffc0200f78:	6b42                	ld	s6,16(sp)
ffffffffc0200f7a:	6ba2                	ld	s7,8(sp)
ffffffffc0200f7c:	00576713          	ori	a4,a4,5
                    *ptep = pte_create(page2ppn(page), perm | PTE_V);
ffffffffc0200f80:	e398                	sd	a4,0(a5)
}
ffffffffc0200f82:	6161                	addi	sp,sp,80
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200f84:	6a70206f          	j	ffffffffc0203e2a <tlb_invalidate>
    return KADDR(page2pa(page));
ffffffffc0200f88:	00005617          	auipc	a2,0x5
ffffffffc0200f8c:	31860613          	addi	a2,a2,792 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0200f90:	07300593          	li	a1,115
ffffffffc0200f94:	00005517          	auipc	a0,0x5
ffffffffc0200f98:	2cc50513          	addi	a0,a0,716 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0200f9c:	a82ff0ef          	jal	ra,ffffffffc020021e <__panic>
                        panic("COW: no mem\n");
ffffffffc0200fa0:	00005617          	auipc	a2,0x5
ffffffffc0200fa4:	2f060613          	addi	a2,a2,752 # ffffffffc0206290 <commands+0x7e8>
ffffffffc0200fa8:	0f100593          	li	a1,241
ffffffffc0200fac:	00005517          	auipc	a0,0x5
ffffffffc0200fb0:	1cc50513          	addi	a0,a0,460 # ffffffffc0206178 <commands+0x6d0>
ffffffffc0200fb4:	a6aff0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200fb8:	00005617          	auipc	a2,0x5
ffffffffc0200fbc:	2b860613          	addi	a2,a2,696 # ffffffffc0206270 <commands+0x7c8>
ffffffffc0200fc0:	06b00593          	li	a1,107
ffffffffc0200fc4:	00005517          	auipc	a0,0x5
ffffffffc0200fc8:	29c50513          	addi	a0,a0,668 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0200fcc:	a52ff0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0200fd0:	00005617          	auipc	a2,0x5
ffffffffc0200fd4:	26860613          	addi	a2,a2,616 # ffffffffc0206238 <commands+0x790>
ffffffffc0200fd8:	08100593          	li	a1,129
ffffffffc0200fdc:	00005517          	auipc	a0,0x5
ffffffffc0200fe0:	28450513          	addi	a0,a0,644 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0200fe4:	a3aff0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0200fe8 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
ffffffffc0200fe8:	1101                	addi	sp,sp,-32
ffffffffc0200fea:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200fec:	000b4417          	auipc	s0,0xb4
ffffffffc0200ff0:	14440413          	addi	s0,s0,324 # ffffffffc02b5130 <current>
ffffffffc0200ff4:	6018                	ld	a4,0(s0)
{
ffffffffc0200ff6:	ec06                	sd	ra,24(sp)
ffffffffc0200ff8:	e426                	sd	s1,8(sp)
ffffffffc0200ffa:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ffc:	11853683          	ld	a3,280(a0)
    if (current == NULL)
ffffffffc0201000:	cf1d                	beqz	a4,ffffffffc020103e <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0201002:	10053483          	ld	s1,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0201006:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc020100a:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020100c:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0)
ffffffffc0201010:	0206c463          	bltz	a3,ffffffffc0201038 <trap+0x50>
        exception_handler(tf);
ffffffffc0201014:	ccdff0ef          	jal	ra,ffffffffc0200ce0 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0201018:	601c                	ld	a5,0(s0)
ffffffffc020101a:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel)
ffffffffc020101e:	e499                	bnez	s1,ffffffffc020102c <trap+0x44>
        {
            if (current->flags & PF_EXITING)
ffffffffc0201020:	0b07a703          	lw	a4,176(a5)
ffffffffc0201024:	8b05                	andi	a4,a4,1
ffffffffc0201026:	e329                	bnez	a4,ffffffffc0201068 <trap+0x80>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0201028:	6f9c                	ld	a5,24(a5)
ffffffffc020102a:	eb85                	bnez	a5,ffffffffc020105a <trap+0x72>
            {
                schedule();
            }
        }
    }
}
ffffffffc020102c:	60e2                	ld	ra,24(sp)
ffffffffc020102e:	6442                	ld	s0,16(sp)
ffffffffc0201030:	64a2                	ld	s1,8(sp)
ffffffffc0201032:	6902                	ld	s2,0(sp)
ffffffffc0201034:	6105                	addi	sp,sp,32
ffffffffc0201036:	8082                	ret
        interrupt_handler(tf);
ffffffffc0201038:	bd3ff0ef          	jal	ra,ffffffffc0200c0a <interrupt_handler>
ffffffffc020103c:	bff1                	j	ffffffffc0201018 <trap+0x30>
    if ((intptr_t)tf->cause < 0)
ffffffffc020103e:	0006c863          	bltz	a3,ffffffffc020104e <trap+0x66>
}
ffffffffc0201042:	6442                	ld	s0,16(sp)
ffffffffc0201044:	60e2                	ld	ra,24(sp)
ffffffffc0201046:	64a2                	ld	s1,8(sp)
ffffffffc0201048:	6902                	ld	s2,0(sp)
ffffffffc020104a:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc020104c:	b951                	j	ffffffffc0200ce0 <exception_handler>
}
ffffffffc020104e:	6442                	ld	s0,16(sp)
ffffffffc0201050:	60e2                	ld	ra,24(sp)
ffffffffc0201052:	64a2                	ld	s1,8(sp)
ffffffffc0201054:	6902                	ld	s2,0(sp)
ffffffffc0201056:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0201058:	be4d                	j	ffffffffc0200c0a <interrupt_handler>
}
ffffffffc020105a:	6442                	ld	s0,16(sp)
ffffffffc020105c:	60e2                	ld	ra,24(sp)
ffffffffc020105e:	64a2                	ld	s1,8(sp)
ffffffffc0201060:	6902                	ld	s2,0(sp)
ffffffffc0201062:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0201064:	15e0406f          	j	ffffffffc02051c2 <schedule>
                do_exit(-E_KILLED);
ffffffffc0201068:	555d                	li	a0,-9
ffffffffc020106a:	508030ef          	jal	ra,ffffffffc0204572 <do_exit>
            if (current->need_resched)
ffffffffc020106e:	601c                	ld	a5,0(s0)
ffffffffc0201070:	bf65                	j	ffffffffc0201028 <trap+0x40>
	...

ffffffffc0201074 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0201074:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0201078:	00011463          	bnez	sp,ffffffffc0201080 <__alltraps+0xc>
ffffffffc020107c:	14002173          	csrr	sp,sscratch
ffffffffc0201080:	712d                	addi	sp,sp,-288
ffffffffc0201082:	e002                	sd	zero,0(sp)
ffffffffc0201084:	e406                	sd	ra,8(sp)
ffffffffc0201086:	ec0e                	sd	gp,24(sp)
ffffffffc0201088:	f012                	sd	tp,32(sp)
ffffffffc020108a:	f416                	sd	t0,40(sp)
ffffffffc020108c:	f81a                	sd	t1,48(sp)
ffffffffc020108e:	fc1e                	sd	t2,56(sp)
ffffffffc0201090:	e0a2                	sd	s0,64(sp)
ffffffffc0201092:	e4a6                	sd	s1,72(sp)
ffffffffc0201094:	e8aa                	sd	a0,80(sp)
ffffffffc0201096:	ecae                	sd	a1,88(sp)
ffffffffc0201098:	f0b2                	sd	a2,96(sp)
ffffffffc020109a:	f4b6                	sd	a3,104(sp)
ffffffffc020109c:	f8ba                	sd	a4,112(sp)
ffffffffc020109e:	fcbe                	sd	a5,120(sp)
ffffffffc02010a0:	e142                	sd	a6,128(sp)
ffffffffc02010a2:	e546                	sd	a7,136(sp)
ffffffffc02010a4:	e94a                	sd	s2,144(sp)
ffffffffc02010a6:	ed4e                	sd	s3,152(sp)
ffffffffc02010a8:	f152                	sd	s4,160(sp)
ffffffffc02010aa:	f556                	sd	s5,168(sp)
ffffffffc02010ac:	f95a                	sd	s6,176(sp)
ffffffffc02010ae:	fd5e                	sd	s7,184(sp)
ffffffffc02010b0:	e1e2                	sd	s8,192(sp)
ffffffffc02010b2:	e5e6                	sd	s9,200(sp)
ffffffffc02010b4:	e9ea                	sd	s10,208(sp)
ffffffffc02010b6:	edee                	sd	s11,216(sp)
ffffffffc02010b8:	f1f2                	sd	t3,224(sp)
ffffffffc02010ba:	f5f6                	sd	t4,232(sp)
ffffffffc02010bc:	f9fa                	sd	t5,240(sp)
ffffffffc02010be:	fdfe                	sd	t6,248(sp)
ffffffffc02010c0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02010c4:	100024f3          	csrr	s1,sstatus
ffffffffc02010c8:	14102973          	csrr	s2,sepc
ffffffffc02010cc:	143029f3          	csrr	s3,stval
ffffffffc02010d0:	14202a73          	csrr	s4,scause
ffffffffc02010d4:	e822                	sd	s0,16(sp)
ffffffffc02010d6:	e226                	sd	s1,256(sp)
ffffffffc02010d8:	e64a                	sd	s2,264(sp)
ffffffffc02010da:	ea4e                	sd	s3,272(sp)
ffffffffc02010dc:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02010de:	850a                	mv	a0,sp
    jal trap
ffffffffc02010e0:	f09ff0ef          	jal	ra,ffffffffc0200fe8 <trap>

ffffffffc02010e4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02010e4:	6492                	ld	s1,256(sp)
ffffffffc02010e6:	6932                	ld	s2,264(sp)
ffffffffc02010e8:	1004f413          	andi	s0,s1,256
ffffffffc02010ec:	e401                	bnez	s0,ffffffffc02010f4 <__trapret+0x10>
ffffffffc02010ee:	1200                	addi	s0,sp,288
ffffffffc02010f0:	14041073          	csrw	sscratch,s0
ffffffffc02010f4:	10049073          	csrw	sstatus,s1
ffffffffc02010f8:	14191073          	csrw	sepc,s2
ffffffffc02010fc:	60a2                	ld	ra,8(sp)
ffffffffc02010fe:	61e2                	ld	gp,24(sp)
ffffffffc0201100:	7202                	ld	tp,32(sp)
ffffffffc0201102:	72a2                	ld	t0,40(sp)
ffffffffc0201104:	7342                	ld	t1,48(sp)
ffffffffc0201106:	73e2                	ld	t2,56(sp)
ffffffffc0201108:	6406                	ld	s0,64(sp)
ffffffffc020110a:	64a6                	ld	s1,72(sp)
ffffffffc020110c:	6546                	ld	a0,80(sp)
ffffffffc020110e:	65e6                	ld	a1,88(sp)
ffffffffc0201110:	7606                	ld	a2,96(sp)
ffffffffc0201112:	76a6                	ld	a3,104(sp)
ffffffffc0201114:	7746                	ld	a4,112(sp)
ffffffffc0201116:	77e6                	ld	a5,120(sp)
ffffffffc0201118:	680a                	ld	a6,128(sp)
ffffffffc020111a:	68aa                	ld	a7,136(sp)
ffffffffc020111c:	694a                	ld	s2,144(sp)
ffffffffc020111e:	69ea                	ld	s3,152(sp)
ffffffffc0201120:	7a0a                	ld	s4,160(sp)
ffffffffc0201122:	7aaa                	ld	s5,168(sp)
ffffffffc0201124:	7b4a                	ld	s6,176(sp)
ffffffffc0201126:	7bea                	ld	s7,184(sp)
ffffffffc0201128:	6c0e                	ld	s8,192(sp)
ffffffffc020112a:	6cae                	ld	s9,200(sp)
ffffffffc020112c:	6d4e                	ld	s10,208(sp)
ffffffffc020112e:	6dee                	ld	s11,216(sp)
ffffffffc0201130:	7e0e                	ld	t3,224(sp)
ffffffffc0201132:	7eae                	ld	t4,232(sp)
ffffffffc0201134:	7f4e                	ld	t5,240(sp)
ffffffffc0201136:	7fee                	ld	t6,248(sp)
ffffffffc0201138:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020113a:	10200073          	sret

ffffffffc020113e <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc020113e:	812a                	mv	sp,a0
    j __trapret
ffffffffc0201140:	b755                	j	ffffffffc02010e4 <__trapret>

ffffffffc0201142 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0201142:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0201146:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc020114a:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc020114e:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0201152:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0201156:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc020115a:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc020115e:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0201162:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0201166:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0201168:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc020116a:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc020116c:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc020116e:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0201170:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0201172:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0201174:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0201176:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0201178:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc020117a:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc020117c:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc020117e:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0201180:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0201182:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0201184:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0201186:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0201188:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc020118a:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc020118c:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc020118e:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0201190:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0201192:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0201194:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0201196:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0201198:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc020119a:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc020119c:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc020119e:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc02011a0:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc02011a2:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc02011a4:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc02011a6:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc02011a8:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc02011aa:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc02011ac:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc02011ae:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc02011b0:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc02011b2:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc02011b4:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc02011b6:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc02011b8:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc02011ba:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc02011bc:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc02011be:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc02011c0:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc02011c2:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc02011c4:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc02011c6:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc02011c8:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc02011ca:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc02011cc:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc02011ce:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc02011d0:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc02011d2:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc02011d4:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc02011d6:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc02011d8:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc02011da:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc02011dc:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc02011de:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc02011e0:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc02011e2:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc02011e4:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc02011e6:	812e                	mv	sp,a1
ffffffffc02011e8:	bdf5                	j	ffffffffc02010e4 <__trapret>

ffffffffc02011ea <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02011ea:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02011ec:	00005697          	auipc	a3,0x5
ffffffffc02011f0:	14c68693          	addi	a3,a3,332 # ffffffffc0206338 <commands+0x890>
ffffffffc02011f4:	00005617          	auipc	a2,0x5
ffffffffc02011f8:	16460613          	addi	a2,a2,356 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02011fc:	07400593          	li	a1,116
ffffffffc0201200:	00005517          	auipc	a0,0x5
ffffffffc0201204:	17050513          	addi	a0,a0,368 # ffffffffc0206370 <commands+0x8c8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201208:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020120a:	814ff0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020120e <mm_create>:
{
ffffffffc020120e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201210:	04000513          	li	a0,64
{
ffffffffc0201214:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201216:	135000ef          	jal	ra,ffffffffc0201b4a <kmalloc>
    if (mm != NULL)
ffffffffc020121a:	cd19                	beqz	a0,ffffffffc0201238 <mm_create+0x2a>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020121c:	e508                	sd	a0,8(a0)
ffffffffc020121e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0201220:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201224:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201228:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020122c:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0201230:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0201234:	02053c23          	sd	zero,56(a0)
}
ffffffffc0201238:	60a2                	ld	ra,8(sp)
ffffffffc020123a:	0141                	addi	sp,sp,16
ffffffffc020123c:	8082                	ret

ffffffffc020123e <find_vma>:
{
ffffffffc020123e:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0201240:	c505                	beqz	a0,ffffffffc0201268 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0201242:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0201244:	c501                	beqz	a0,ffffffffc020124c <find_vma+0xe>
ffffffffc0201246:	651c                	ld	a5,8(a0)
ffffffffc0201248:	02f5f263          	bgeu	a1,a5,ffffffffc020126c <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020124c:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc020124e:	00f68d63          	beq	a3,a5,ffffffffc0201268 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0201252:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201256:	00e5e663          	bltu	a1,a4,ffffffffc0201262 <find_vma+0x24>
ffffffffc020125a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020125e:	00e5ec63          	bltu	a1,a4,ffffffffc0201276 <find_vma+0x38>
ffffffffc0201262:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0201264:	fef697e3          	bne	a3,a5,ffffffffc0201252 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0201268:	4501                	li	a0,0
}
ffffffffc020126a:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020126c:	691c                	ld	a5,16(a0)
ffffffffc020126e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020124c <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0201272:	ea88                	sd	a0,16(a3)
ffffffffc0201274:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0201276:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020127a:	ea88                	sd	a0,16(a3)
ffffffffc020127c:	8082                	ret

ffffffffc020127e <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020127e:	6590                	ld	a2,8(a1)
ffffffffc0201280:	0105b803          	ld	a6,16(a1)
{
ffffffffc0201284:	1141                	addi	sp,sp,-16
ffffffffc0201286:	e406                	sd	ra,8(sp)
ffffffffc0201288:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020128a:	01066763          	bltu	a2,a6,ffffffffc0201298 <insert_vma_struct+0x1a>
ffffffffc020128e:	a085                	j	ffffffffc02012ee <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0201290:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201294:	04e66863          	bltu	a2,a4,ffffffffc02012e4 <insert_vma_struct+0x66>
ffffffffc0201298:	86be                	mv	a3,a5
ffffffffc020129a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020129c:	fef51ae3          	bne	a0,a5,ffffffffc0201290 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02012a0:	02a68463          	beq	a3,a0,ffffffffc02012c8 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02012a4:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02012a8:	fe86b883          	ld	a7,-24(a3)
ffffffffc02012ac:	08e8f163          	bgeu	a7,a4,ffffffffc020132e <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02012b0:	04e66f63          	bltu	a2,a4,ffffffffc020130e <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc02012b4:	00f50a63          	beq	a0,a5,ffffffffc02012c8 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02012b8:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02012bc:	05076963          	bltu	a4,a6,ffffffffc020130e <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02012c0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02012c4:	02c77363          	bgeu	a4,a2,ffffffffc02012ea <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc02012c8:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02012ca:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02012cc:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012d0:	e390                	sd	a2,0(a5)
ffffffffc02012d2:	e690                	sd	a2,8(a3)
}
ffffffffc02012d4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02012d6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02012d8:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02012da:	0017079b          	addiw	a5,a4,1
ffffffffc02012de:	d11c                	sw	a5,32(a0)
}
ffffffffc02012e0:	0141                	addi	sp,sp,16
ffffffffc02012e2:	8082                	ret
    if (le_prev != list)
ffffffffc02012e4:	fca690e3          	bne	a3,a0,ffffffffc02012a4 <insert_vma_struct+0x26>
ffffffffc02012e8:	bfd1                	j	ffffffffc02012bc <insert_vma_struct+0x3e>
ffffffffc02012ea:	f01ff0ef          	jal	ra,ffffffffc02011ea <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02012ee:	00005697          	auipc	a3,0x5
ffffffffc02012f2:	09268693          	addi	a3,a3,146 # ffffffffc0206380 <commands+0x8d8>
ffffffffc02012f6:	00005617          	auipc	a2,0x5
ffffffffc02012fa:	06260613          	addi	a2,a2,98 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02012fe:	07a00593          	li	a1,122
ffffffffc0201302:	00005517          	auipc	a0,0x5
ffffffffc0201306:	06e50513          	addi	a0,a0,110 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020130a:	f15fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020130e:	00005697          	auipc	a3,0x5
ffffffffc0201312:	0b268693          	addi	a3,a3,178 # ffffffffc02063c0 <commands+0x918>
ffffffffc0201316:	00005617          	auipc	a2,0x5
ffffffffc020131a:	04260613          	addi	a2,a2,66 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020131e:	07300593          	li	a1,115
ffffffffc0201322:	00005517          	auipc	a0,0x5
ffffffffc0201326:	04e50513          	addi	a0,a0,78 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020132a:	ef5fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020132e:	00005697          	auipc	a3,0x5
ffffffffc0201332:	07268693          	addi	a3,a3,114 # ffffffffc02063a0 <commands+0x8f8>
ffffffffc0201336:	00005617          	auipc	a2,0x5
ffffffffc020133a:	02260613          	addi	a2,a2,34 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020133e:	07200593          	li	a1,114
ffffffffc0201342:	00005517          	auipc	a0,0x5
ffffffffc0201346:	02e50513          	addi	a0,a0,46 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020134a:	ed5fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020134e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc020134e:	591c                	lw	a5,48(a0)
{
ffffffffc0201350:	1141                	addi	sp,sp,-16
ffffffffc0201352:	e406                	sd	ra,8(sp)
ffffffffc0201354:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0201356:	e78d                	bnez	a5,ffffffffc0201380 <mm_destroy+0x32>
ffffffffc0201358:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020135a:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc020135c:	00a40c63          	beq	s0,a0,ffffffffc0201374 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0201360:	6118                	ld	a4,0(a0)
ffffffffc0201362:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0201364:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201366:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201368:	e398                	sd	a4,0(a5)
ffffffffc020136a:	091000ef          	jal	ra,ffffffffc0201bfa <kfree>
    return listelm->next;
ffffffffc020136e:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0201370:	fea418e3          	bne	s0,a0,ffffffffc0201360 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0201374:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0201376:	6402                	ld	s0,0(sp)
ffffffffc0201378:	60a2                	ld	ra,8(sp)
ffffffffc020137a:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc020137c:	07f0006f          	j	ffffffffc0201bfa <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0201380:	00005697          	auipc	a3,0x5
ffffffffc0201384:	06068693          	addi	a3,a3,96 # ffffffffc02063e0 <commands+0x938>
ffffffffc0201388:	00005617          	auipc	a2,0x5
ffffffffc020138c:	fd060613          	addi	a2,a2,-48 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201390:	09e00593          	li	a1,158
ffffffffc0201394:	00005517          	auipc	a0,0x5
ffffffffc0201398:	fdc50513          	addi	a0,a0,-36 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020139c:	e83fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02013a0 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
ffffffffc02013a0:	7139                	addi	sp,sp,-64
ffffffffc02013a2:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02013a4:	6405                	lui	s0,0x1
ffffffffc02013a6:	147d                	addi	s0,s0,-1
ffffffffc02013a8:	77fd                	lui	a5,0xfffff
ffffffffc02013aa:	9622                	add	a2,a2,s0
ffffffffc02013ac:	962e                	add	a2,a2,a1
{
ffffffffc02013ae:	f426                	sd	s1,40(sp)
ffffffffc02013b0:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02013b2:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02013b6:	f04a                	sd	s2,32(sp)
ffffffffc02013b8:	ec4e                	sd	s3,24(sp)
ffffffffc02013ba:	e852                	sd	s4,16(sp)
ffffffffc02013bc:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end))
ffffffffc02013be:	002005b7          	lui	a1,0x200
ffffffffc02013c2:	00f67433          	and	s0,a2,a5
ffffffffc02013c6:	06b4e363          	bltu	s1,a1,ffffffffc020142c <mm_map+0x8c>
ffffffffc02013ca:	0684f163          	bgeu	s1,s0,ffffffffc020142c <mm_map+0x8c>
ffffffffc02013ce:	4785                	li	a5,1
ffffffffc02013d0:	07fe                	slli	a5,a5,0x1f
ffffffffc02013d2:	0487ed63          	bltu	a5,s0,ffffffffc020142c <mm_map+0x8c>
ffffffffc02013d6:	89aa                	mv	s3,a0
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02013d8:	cd21                	beqz	a0,ffffffffc0201430 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02013da:	85a6                	mv	a1,s1
ffffffffc02013dc:	8ab6                	mv	s5,a3
ffffffffc02013de:	8a3a                	mv	s4,a4
ffffffffc02013e0:	e5fff0ef          	jal	ra,ffffffffc020123e <find_vma>
ffffffffc02013e4:	c501                	beqz	a0,ffffffffc02013ec <mm_map+0x4c>
ffffffffc02013e6:	651c                	ld	a5,8(a0)
ffffffffc02013e8:	0487e263          	bltu	a5,s0,ffffffffc020142c <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013ec:	03000513          	li	a0,48
ffffffffc02013f0:	75a000ef          	jal	ra,ffffffffc0201b4a <kmalloc>
ffffffffc02013f4:	892a                	mv	s2,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02013f6:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02013f8:	02090163          	beqz	s2,ffffffffc020141a <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02013fc:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02013fe:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0201402:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0201406:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020140a:	85ca                	mv	a1,s2
ffffffffc020140c:	e73ff0ef          	jal	ra,ffffffffc020127e <insert_vma_struct>
    if (vma_store != NULL)
    {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0201410:	4501                	li	a0,0
    if (vma_store != NULL)
ffffffffc0201412:	000a0463          	beqz	s4,ffffffffc020141a <mm_map+0x7a>
        *vma_store = vma;
ffffffffc0201416:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020141a:	70e2                	ld	ra,56(sp)
ffffffffc020141c:	7442                	ld	s0,48(sp)
ffffffffc020141e:	74a2                	ld	s1,40(sp)
ffffffffc0201420:	7902                	ld	s2,32(sp)
ffffffffc0201422:	69e2                	ld	s3,24(sp)
ffffffffc0201424:	6a42                	ld	s4,16(sp)
ffffffffc0201426:	6aa2                	ld	s5,8(sp)
ffffffffc0201428:	6121                	addi	sp,sp,64
ffffffffc020142a:	8082                	ret
        return -E_INVAL;
ffffffffc020142c:	5575                	li	a0,-3
ffffffffc020142e:	b7f5                	j	ffffffffc020141a <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0201430:	00005697          	auipc	a3,0x5
ffffffffc0201434:	fc868693          	addi	a3,a3,-56 # ffffffffc02063f8 <commands+0x950>
ffffffffc0201438:	00005617          	auipc	a2,0x5
ffffffffc020143c:	f2060613          	addi	a2,a2,-224 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201440:	0b300593          	li	a1,179
ffffffffc0201444:	00005517          	auipc	a0,0x5
ffffffffc0201448:	f2c50513          	addi	a0,a0,-212 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020144c:	dd3fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201450 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0201450:	7139                	addi	sp,sp,-64
ffffffffc0201452:	fc06                	sd	ra,56(sp)
ffffffffc0201454:	f822                	sd	s0,48(sp)
ffffffffc0201456:	f426                	sd	s1,40(sp)
ffffffffc0201458:	f04a                	sd	s2,32(sp)
ffffffffc020145a:	ec4e                	sd	s3,24(sp)
ffffffffc020145c:	e852                	sd	s4,16(sp)
ffffffffc020145e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0201460:	c52d                	beqz	a0,ffffffffc02014ca <dup_mmap+0x7a>
ffffffffc0201462:	892a                	mv	s2,a0
ffffffffc0201464:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0201466:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0201468:	e595                	bnez	a1,ffffffffc0201494 <dup_mmap+0x44>
ffffffffc020146a:	a085                	j	ffffffffc02014ca <dup_mmap+0x7a>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020146c:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc020146e:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ed0>
        vma->vm_end = vm_end;
ffffffffc0201472:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0201476:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc020147a:	e05ff0ef          	jal	ra,ffffffffc020127e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc020147e:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc0201482:	fe843603          	ld	a2,-24(s0)
ffffffffc0201486:	6c8c                	ld	a1,24(s1)
ffffffffc0201488:	01893503          	ld	a0,24(s2)
ffffffffc020148c:	4701                	li	a4,0
ffffffffc020148e:	027020ef          	jal	ra,ffffffffc0203cb4 <copy_range>
ffffffffc0201492:	e105                	bnez	a0,ffffffffc02014b2 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc0201494:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0201496:	02848863          	beq	s1,s0,ffffffffc02014c6 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020149a:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020149e:	fe843a83          	ld	s5,-24(s0)
ffffffffc02014a2:	ff043a03          	ld	s4,-16(s0)
ffffffffc02014a6:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02014aa:	6a0000ef          	jal	ra,ffffffffc0201b4a <kmalloc>
ffffffffc02014ae:	85aa                	mv	a1,a0
    if (vma != NULL)
ffffffffc02014b0:	fd55                	bnez	a0,ffffffffc020146c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02014b2:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02014b4:	70e2                	ld	ra,56(sp)
ffffffffc02014b6:	7442                	ld	s0,48(sp)
ffffffffc02014b8:	74a2                	ld	s1,40(sp)
ffffffffc02014ba:	7902                	ld	s2,32(sp)
ffffffffc02014bc:	69e2                	ld	s3,24(sp)
ffffffffc02014be:	6a42                	ld	s4,16(sp)
ffffffffc02014c0:	6aa2                	ld	s5,8(sp)
ffffffffc02014c2:	6121                	addi	sp,sp,64
ffffffffc02014c4:	8082                	ret
    return 0;
ffffffffc02014c6:	4501                	li	a0,0
ffffffffc02014c8:	b7f5                	j	ffffffffc02014b4 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02014ca:	00005697          	auipc	a3,0x5
ffffffffc02014ce:	f3e68693          	addi	a3,a3,-194 # ffffffffc0206408 <commands+0x960>
ffffffffc02014d2:	00005617          	auipc	a2,0x5
ffffffffc02014d6:	e8660613          	addi	a2,a2,-378 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02014da:	0cf00593          	li	a1,207
ffffffffc02014de:	00005517          	auipc	a0,0x5
ffffffffc02014e2:	e9250513          	addi	a0,a0,-366 # ffffffffc0206370 <commands+0x8c8>
ffffffffc02014e6:	d39fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02014ea <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02014ea:	1101                	addi	sp,sp,-32
ffffffffc02014ec:	ec06                	sd	ra,24(sp)
ffffffffc02014ee:	e822                	sd	s0,16(sp)
ffffffffc02014f0:	e426                	sd	s1,8(sp)
ffffffffc02014f2:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02014f4:	c531                	beqz	a0,ffffffffc0201540 <exit_mmap+0x56>
ffffffffc02014f6:	591c                	lw	a5,48(a0)
ffffffffc02014f8:	84aa                	mv	s1,a0
ffffffffc02014fa:	e3b9                	bnez	a5,ffffffffc0201540 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02014fc:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02014fe:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0201502:	02850663          	beq	a0,s0,ffffffffc020152e <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201506:	ff043603          	ld	a2,-16(s0)
ffffffffc020150a:	fe843583          	ld	a1,-24(s0)
ffffffffc020150e:	854a                	mv	a0,s2
ffffffffc0201510:	5fa010ef          	jal	ra,ffffffffc0202b0a <unmap_range>
ffffffffc0201514:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0201516:	fe8498e3          	bne	s1,s0,ffffffffc0201506 <exit_mmap+0x1c>
ffffffffc020151a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc020151c:	00848c63          	beq	s1,s0,ffffffffc0201534 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201520:	ff043603          	ld	a2,-16(s0)
ffffffffc0201524:	fe843583          	ld	a1,-24(s0)
ffffffffc0201528:	854a                	mv	a0,s2
ffffffffc020152a:	726010ef          	jal	ra,ffffffffc0202c50 <exit_range>
ffffffffc020152e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0201530:	fe8498e3          	bne	s1,s0,ffffffffc0201520 <exit_mmap+0x36>
    }
}
ffffffffc0201534:	60e2                	ld	ra,24(sp)
ffffffffc0201536:	6442                	ld	s0,16(sp)
ffffffffc0201538:	64a2                	ld	s1,8(sp)
ffffffffc020153a:	6902                	ld	s2,0(sp)
ffffffffc020153c:	6105                	addi	sp,sp,32
ffffffffc020153e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201540:	00005697          	auipc	a3,0x5
ffffffffc0201544:	ee868693          	addi	a3,a3,-280 # ffffffffc0206428 <commands+0x980>
ffffffffc0201548:	00005617          	auipc	a2,0x5
ffffffffc020154c:	e1060613          	addi	a2,a2,-496 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201550:	0e800593          	li	a1,232
ffffffffc0201554:	00005517          	auipc	a0,0x5
ffffffffc0201558:	e1c50513          	addi	a0,a0,-484 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020155c:	cc3fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201560 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0201560:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201562:	04000513          	li	a0,64
{
ffffffffc0201566:	fc06                	sd	ra,56(sp)
ffffffffc0201568:	f822                	sd	s0,48(sp)
ffffffffc020156a:	f426                	sd	s1,40(sp)
ffffffffc020156c:	f04a                	sd	s2,32(sp)
ffffffffc020156e:	ec4e                	sd	s3,24(sp)
ffffffffc0201570:	e852                	sd	s4,16(sp)
ffffffffc0201572:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201574:	5d6000ef          	jal	ra,ffffffffc0201b4a <kmalloc>
    if (mm != NULL)
ffffffffc0201578:	2e050663          	beqz	a0,ffffffffc0201864 <vmm_init+0x304>
ffffffffc020157c:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc020157e:	e508                	sd	a0,8(a0)
ffffffffc0201580:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0201582:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0201586:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020158a:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020158e:	02053423          	sd	zero,40(a0)
ffffffffc0201592:	02052823          	sw	zero,48(a0)
ffffffffc0201596:	02053c23          	sd	zero,56(a0)
ffffffffc020159a:	03200413          	li	s0,50
ffffffffc020159e:	a811                	j	ffffffffc02015b2 <vmm_init+0x52>
        vma->vm_start = vm_start;
ffffffffc02015a0:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02015a2:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02015a4:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc02015a8:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02015aa:	8526                	mv	a0,s1
ffffffffc02015ac:	cd3ff0ef          	jal	ra,ffffffffc020127e <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc02015b0:	c80d                	beqz	s0,ffffffffc02015e2 <vmm_init+0x82>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02015b2:	03000513          	li	a0,48
ffffffffc02015b6:	594000ef          	jal	ra,ffffffffc0201b4a <kmalloc>
ffffffffc02015ba:	85aa                	mv	a1,a0
ffffffffc02015bc:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc02015c0:	f165                	bnez	a0,ffffffffc02015a0 <vmm_init+0x40>
        assert(vma != NULL);
ffffffffc02015c2:	00005697          	auipc	a3,0x5
ffffffffc02015c6:	ffe68693          	addi	a3,a3,-2 # ffffffffc02065c0 <commands+0xb18>
ffffffffc02015ca:	00005617          	auipc	a2,0x5
ffffffffc02015ce:	d8e60613          	addi	a2,a2,-626 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02015d2:	12c00593          	li	a1,300
ffffffffc02015d6:	00005517          	auipc	a0,0x5
ffffffffc02015da:	d9a50513          	addi	a0,a0,-614 # ffffffffc0206370 <commands+0x8c8>
ffffffffc02015de:	c41fe0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc02015e2:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc02015e6:	1f900913          	li	s2,505
ffffffffc02015ea:	a819                	j	ffffffffc0201600 <vmm_init+0xa0>
        vma->vm_start = vm_start;
ffffffffc02015ec:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02015ee:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02015f0:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02015f4:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02015f6:	8526                	mv	a0,s1
ffffffffc02015f8:	c87ff0ef          	jal	ra,ffffffffc020127e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02015fc:	03240a63          	beq	s0,s2,ffffffffc0201630 <vmm_init+0xd0>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201600:	03000513          	li	a0,48
ffffffffc0201604:	546000ef          	jal	ra,ffffffffc0201b4a <kmalloc>
ffffffffc0201608:	85aa                	mv	a1,a0
ffffffffc020160a:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc020160e:	fd79                	bnez	a0,ffffffffc02015ec <vmm_init+0x8c>
        assert(vma != NULL);
ffffffffc0201610:	00005697          	auipc	a3,0x5
ffffffffc0201614:	fb068693          	addi	a3,a3,-80 # ffffffffc02065c0 <commands+0xb18>
ffffffffc0201618:	00005617          	auipc	a2,0x5
ffffffffc020161c:	d4060613          	addi	a2,a2,-704 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201620:	13300593          	li	a1,307
ffffffffc0201624:	00005517          	auipc	a0,0x5
ffffffffc0201628:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020162c:	bf3fe0ef          	jal	ra,ffffffffc020021e <__panic>
    return listelm->next;
ffffffffc0201630:	649c                	ld	a5,8(s1)
ffffffffc0201632:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0201634:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0201638:	16f48663          	beq	s1,a5,ffffffffc02017a4 <vmm_init+0x244>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020163c:	fe87b603          	ld	a2,-24(a5) # ffffffffffffefe8 <end+0x3fd49e9c>
ffffffffc0201640:	ffe70693          	addi	a3,a4,-2
ffffffffc0201644:	10d61063          	bne	a2,a3,ffffffffc0201744 <vmm_init+0x1e4>
ffffffffc0201648:	ff07b683          	ld	a3,-16(a5)
ffffffffc020164c:	0ed71c63          	bne	a4,a3,ffffffffc0201744 <vmm_init+0x1e4>
    for (i = 1; i <= step2; i++)
ffffffffc0201650:	0715                	addi	a4,a4,5
ffffffffc0201652:	679c                	ld	a5,8(a5)
ffffffffc0201654:	feb712e3          	bne	a4,a1,ffffffffc0201638 <vmm_init+0xd8>
ffffffffc0201658:	4a1d                	li	s4,7
ffffffffc020165a:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020165c:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201660:	85a2                	mv	a1,s0
ffffffffc0201662:	8526                	mv	a0,s1
ffffffffc0201664:	bdbff0ef          	jal	ra,ffffffffc020123e <find_vma>
ffffffffc0201668:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020166a:	16050d63          	beqz	a0,ffffffffc02017e4 <vmm_init+0x284>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020166e:	00140593          	addi	a1,s0,1
ffffffffc0201672:	8526                	mv	a0,s1
ffffffffc0201674:	bcbff0ef          	jal	ra,ffffffffc020123e <find_vma>
ffffffffc0201678:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020167a:	14050563          	beqz	a0,ffffffffc02017c4 <vmm_init+0x264>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc020167e:	85d2                	mv	a1,s4
ffffffffc0201680:	8526                	mv	a0,s1
ffffffffc0201682:	bbdff0ef          	jal	ra,ffffffffc020123e <find_vma>
        assert(vma3 == NULL);
ffffffffc0201686:	16051f63          	bnez	a0,ffffffffc0201804 <vmm_init+0x2a4>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020168a:	00340593          	addi	a1,s0,3
ffffffffc020168e:	8526                	mv	a0,s1
ffffffffc0201690:	bafff0ef          	jal	ra,ffffffffc020123e <find_vma>
        assert(vma4 == NULL);
ffffffffc0201694:	1a051863          	bnez	a0,ffffffffc0201844 <vmm_init+0x2e4>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0201698:	00440593          	addi	a1,s0,4
ffffffffc020169c:	8526                	mv	a0,s1
ffffffffc020169e:	ba1ff0ef          	jal	ra,ffffffffc020123e <find_vma>
        assert(vma5 == NULL);
ffffffffc02016a2:	18051163          	bnez	a0,ffffffffc0201824 <vmm_init+0x2c4>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02016a6:	00893783          	ld	a5,8(s2)
ffffffffc02016aa:	0a879d63          	bne	a5,s0,ffffffffc0201764 <vmm_init+0x204>
ffffffffc02016ae:	01093783          	ld	a5,16(s2)
ffffffffc02016b2:	0b479963          	bne	a5,s4,ffffffffc0201764 <vmm_init+0x204>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02016b6:	0089b783          	ld	a5,8(s3)
ffffffffc02016ba:	0c879563          	bne	a5,s0,ffffffffc0201784 <vmm_init+0x224>
ffffffffc02016be:	0109b783          	ld	a5,16(s3)
ffffffffc02016c2:	0d479163          	bne	a5,s4,ffffffffc0201784 <vmm_init+0x224>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02016c6:	0415                	addi	s0,s0,5
ffffffffc02016c8:	0a15                	addi	s4,s4,5
ffffffffc02016ca:	f9541be3          	bne	s0,s5,ffffffffc0201660 <vmm_init+0x100>
ffffffffc02016ce:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02016d0:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02016d2:	85a2                	mv	a1,s0
ffffffffc02016d4:	8526                	mv	a0,s1
ffffffffc02016d6:	b69ff0ef          	jal	ra,ffffffffc020123e <find_vma>
ffffffffc02016da:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc02016de:	c90d                	beqz	a0,ffffffffc0201710 <vmm_init+0x1b0>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02016e0:	6914                	ld	a3,16(a0)
ffffffffc02016e2:	6510                	ld	a2,8(a0)
ffffffffc02016e4:	00005517          	auipc	a0,0x5
ffffffffc02016e8:	e6450513          	addi	a0,a0,-412 # ffffffffc0206548 <commands+0xaa0>
ffffffffc02016ec:	9f5fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02016f0:	00005697          	auipc	a3,0x5
ffffffffc02016f4:	e8068693          	addi	a3,a3,-384 # ffffffffc0206570 <commands+0xac8>
ffffffffc02016f8:	00005617          	auipc	a2,0x5
ffffffffc02016fc:	c6060613          	addi	a2,a2,-928 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201700:	15900593          	li	a1,345
ffffffffc0201704:	00005517          	auipc	a0,0x5
ffffffffc0201708:	c6c50513          	addi	a0,a0,-916 # ffffffffc0206370 <commands+0x8c8>
ffffffffc020170c:	b13fe0ef          	jal	ra,ffffffffc020021e <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0201710:	147d                	addi	s0,s0,-1
ffffffffc0201712:	fd2410e3          	bne	s0,s2,ffffffffc02016d2 <vmm_init+0x172>
    }

    mm_destroy(mm);
ffffffffc0201716:	8526                	mv	a0,s1
ffffffffc0201718:	c37ff0ef          	jal	ra,ffffffffc020134e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020171c:	00005517          	auipc	a0,0x5
ffffffffc0201720:	e6c50513          	addi	a0,a0,-404 # ffffffffc0206588 <commands+0xae0>
ffffffffc0201724:	9bdfe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0201728:	7442                	ld	s0,48(sp)
ffffffffc020172a:	70e2                	ld	ra,56(sp)
ffffffffc020172c:	74a2                	ld	s1,40(sp)
ffffffffc020172e:	7902                	ld	s2,32(sp)
ffffffffc0201730:	69e2                	ld	s3,24(sp)
ffffffffc0201732:	6a42                	ld	s4,16(sp)
ffffffffc0201734:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201736:	00005517          	auipc	a0,0x5
ffffffffc020173a:	e7250513          	addi	a0,a0,-398 # ffffffffc02065a8 <commands+0xb00>
}
ffffffffc020173e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201740:	9a1fe06f          	j	ffffffffc02000e0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201744:	00005697          	auipc	a3,0x5
ffffffffc0201748:	d1c68693          	addi	a3,a3,-740 # ffffffffc0206460 <commands+0x9b8>
ffffffffc020174c:	00005617          	auipc	a2,0x5
ffffffffc0201750:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201754:	13d00593          	li	a1,317
ffffffffc0201758:	00005517          	auipc	a0,0x5
ffffffffc020175c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201760:	abffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0201764:	00005697          	auipc	a3,0x5
ffffffffc0201768:	d8468693          	addi	a3,a3,-636 # ffffffffc02064e8 <commands+0xa40>
ffffffffc020176c:	00005617          	auipc	a2,0x5
ffffffffc0201770:	bec60613          	addi	a2,a2,-1044 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201774:	14e00593          	li	a1,334
ffffffffc0201778:	00005517          	auipc	a0,0x5
ffffffffc020177c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201780:	a9ffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0201784:	00005697          	auipc	a3,0x5
ffffffffc0201788:	d9468693          	addi	a3,a3,-620 # ffffffffc0206518 <commands+0xa70>
ffffffffc020178c:	00005617          	auipc	a2,0x5
ffffffffc0201790:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201794:	14f00593          	li	a1,335
ffffffffc0201798:	00005517          	auipc	a0,0x5
ffffffffc020179c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0206370 <commands+0x8c8>
ffffffffc02017a0:	a7ffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02017a4:	00005697          	auipc	a3,0x5
ffffffffc02017a8:	ca468693          	addi	a3,a3,-860 # ffffffffc0206448 <commands+0x9a0>
ffffffffc02017ac:	00005617          	auipc	a2,0x5
ffffffffc02017b0:	bac60613          	addi	a2,a2,-1108 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02017b4:	13b00593          	li	a1,315
ffffffffc02017b8:	00005517          	auipc	a0,0x5
ffffffffc02017bc:	bb850513          	addi	a0,a0,-1096 # ffffffffc0206370 <commands+0x8c8>
ffffffffc02017c0:	a5ffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma2 != NULL);
ffffffffc02017c4:	00005697          	auipc	a3,0x5
ffffffffc02017c8:	ce468693          	addi	a3,a3,-796 # ffffffffc02064a8 <commands+0xa00>
ffffffffc02017cc:	00005617          	auipc	a2,0x5
ffffffffc02017d0:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02017d4:	14600593          	li	a1,326
ffffffffc02017d8:	00005517          	auipc	a0,0x5
ffffffffc02017dc:	b9850513          	addi	a0,a0,-1128 # ffffffffc0206370 <commands+0x8c8>
ffffffffc02017e0:	a3ffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma1 != NULL);
ffffffffc02017e4:	00005697          	auipc	a3,0x5
ffffffffc02017e8:	cb468693          	addi	a3,a3,-844 # ffffffffc0206498 <commands+0x9f0>
ffffffffc02017ec:	00005617          	auipc	a2,0x5
ffffffffc02017f0:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02017f4:	14400593          	li	a1,324
ffffffffc02017f8:	00005517          	auipc	a0,0x5
ffffffffc02017fc:	b7850513          	addi	a0,a0,-1160 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201800:	a1ffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma3 == NULL);
ffffffffc0201804:	00005697          	auipc	a3,0x5
ffffffffc0201808:	cb468693          	addi	a3,a3,-844 # ffffffffc02064b8 <commands+0xa10>
ffffffffc020180c:	00005617          	auipc	a2,0x5
ffffffffc0201810:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201814:	14800593          	li	a1,328
ffffffffc0201818:	00005517          	auipc	a0,0x5
ffffffffc020181c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201820:	9fffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma5 == NULL);
ffffffffc0201824:	00005697          	auipc	a3,0x5
ffffffffc0201828:	cb468693          	addi	a3,a3,-844 # ffffffffc02064d8 <commands+0xa30>
ffffffffc020182c:	00005617          	auipc	a2,0x5
ffffffffc0201830:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201834:	14c00593          	li	a1,332
ffffffffc0201838:	00005517          	auipc	a0,0x5
ffffffffc020183c:	b3850513          	addi	a0,a0,-1224 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201840:	9dffe0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(vma4 == NULL);
ffffffffc0201844:	00005697          	auipc	a3,0x5
ffffffffc0201848:	c8468693          	addi	a3,a3,-892 # ffffffffc02064c8 <commands+0xa20>
ffffffffc020184c:	00005617          	auipc	a2,0x5
ffffffffc0201850:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201854:	14a00593          	li	a1,330
ffffffffc0201858:	00005517          	auipc	a0,0x5
ffffffffc020185c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201860:	9bffe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(mm != NULL);
ffffffffc0201864:	00005697          	auipc	a3,0x5
ffffffffc0201868:	b9468693          	addi	a3,a3,-1132 # ffffffffc02063f8 <commands+0x950>
ffffffffc020186c:	00005617          	auipc	a2,0x5
ffffffffc0201870:	aec60613          	addi	a2,a2,-1300 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201874:	12400593          	li	a1,292
ffffffffc0201878:	00005517          	auipc	a0,0x5
ffffffffc020187c:	af850513          	addi	a0,a0,-1288 # ffffffffc0206370 <commands+0x8c8>
ffffffffc0201880:	99ffe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201884 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0201884:	7179                	addi	sp,sp,-48
ffffffffc0201886:	f022                	sd	s0,32(sp)
ffffffffc0201888:	f406                	sd	ra,40(sp)
ffffffffc020188a:	ec26                	sd	s1,24(sp)
ffffffffc020188c:	e84a                	sd	s2,16(sp)
ffffffffc020188e:	e44e                	sd	s3,8(sp)
ffffffffc0201890:	e052                	sd	s4,0(sp)
ffffffffc0201892:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0201894:	c135                	beqz	a0,ffffffffc02018f8 <user_mem_check+0x74>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0201896:	002007b7          	lui	a5,0x200
ffffffffc020189a:	04f5e663          	bltu	a1,a5,ffffffffc02018e6 <user_mem_check+0x62>
ffffffffc020189e:	00c584b3          	add	s1,a1,a2
ffffffffc02018a2:	0495f263          	bgeu	a1,s1,ffffffffc02018e6 <user_mem_check+0x62>
ffffffffc02018a6:	4785                	li	a5,1
ffffffffc02018a8:	07fe                	slli	a5,a5,0x1f
ffffffffc02018aa:	0297ee63          	bltu	a5,s1,ffffffffc02018e6 <user_mem_check+0x62>
ffffffffc02018ae:	892a                	mv	s2,a0
ffffffffc02018b0:	89b6                	mv	s3,a3
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc02018b2:	6a05                	lui	s4,0x1
ffffffffc02018b4:	a821                	j	ffffffffc02018cc <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02018b6:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE)
ffffffffc02018ba:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02018bc:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02018be:	c685                	beqz	a3,ffffffffc02018e6 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc02018c0:	c399                	beqz	a5,ffffffffc02018c6 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc02018c2:	02e46263          	bltu	s0,a4,ffffffffc02018e6 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02018c6:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc02018c8:	04947663          	bgeu	s0,s1,ffffffffc0201914 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc02018cc:	85a2                	mv	a1,s0
ffffffffc02018ce:	854a                	mv	a0,s2
ffffffffc02018d0:	96fff0ef          	jal	ra,ffffffffc020123e <find_vma>
ffffffffc02018d4:	c909                	beqz	a0,ffffffffc02018e6 <user_mem_check+0x62>
ffffffffc02018d6:	6518                	ld	a4,8(a0)
ffffffffc02018d8:	00e46763          	bltu	s0,a4,ffffffffc02018e6 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc02018dc:	4d1c                	lw	a5,24(a0)
ffffffffc02018de:	fc099ce3          	bnez	s3,ffffffffc02018b6 <user_mem_check+0x32>
ffffffffc02018e2:	8b85                	andi	a5,a5,1
ffffffffc02018e4:	f3ed                	bnez	a5,ffffffffc02018c6 <user_mem_check+0x42>
            return 0;
ffffffffc02018e6:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc02018e8:	70a2                	ld	ra,40(sp)
ffffffffc02018ea:	7402                	ld	s0,32(sp)
ffffffffc02018ec:	64e2                	ld	s1,24(sp)
ffffffffc02018ee:	6942                	ld	s2,16(sp)
ffffffffc02018f0:	69a2                	ld	s3,8(sp)
ffffffffc02018f2:	6a02                	ld	s4,0(sp)
ffffffffc02018f4:	6145                	addi	sp,sp,48
ffffffffc02018f6:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc02018f8:	c02007b7          	lui	a5,0xc0200
ffffffffc02018fc:	4501                	li	a0,0
ffffffffc02018fe:	fef5e5e3          	bltu	a1,a5,ffffffffc02018e8 <user_mem_check+0x64>
ffffffffc0201902:	962e                	add	a2,a2,a1
ffffffffc0201904:	fec5f2e3          	bgeu	a1,a2,ffffffffc02018e8 <user_mem_check+0x64>
ffffffffc0201908:	c8000537          	lui	a0,0xc8000
ffffffffc020190c:	0505                	addi	a0,a0,1
ffffffffc020190e:	00a63533          	sltu	a0,a2,a0
ffffffffc0201912:	bfd9                	j	ffffffffc02018e8 <user_mem_check+0x64>
        return 1;
ffffffffc0201914:	4505                	li	a0,1
ffffffffc0201916:	bfc9                	j	ffffffffc02018e8 <user_mem_check+0x64>

ffffffffc0201918 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201918:	c94d                	beqz	a0,ffffffffc02019ca <slob_free+0xb2>
{
ffffffffc020191a:	1141                	addi	sp,sp,-16
ffffffffc020191c:	e022                	sd	s0,0(sp)
ffffffffc020191e:	e406                	sd	ra,8(sp)
ffffffffc0201920:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201922:	e9c1                	bnez	a1,ffffffffc02019b2 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201924:	100027f3          	csrr	a5,sstatus
ffffffffc0201928:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020192a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020192c:	ebd9                	bnez	a5,ffffffffc02019c2 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020192e:	000af617          	auipc	a2,0xaf
ffffffffc0201932:	36260613          	addi	a2,a2,866 # ffffffffc02b0c90 <slobfree>
ffffffffc0201936:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201938:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020193a:	679c                	ld	a5,8(a5)
ffffffffc020193c:	02877a63          	bgeu	a4,s0,ffffffffc0201970 <slob_free+0x58>
ffffffffc0201940:	00f46463          	bltu	s0,a5,ffffffffc0201948 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201944:	fef76ae3          	bltu	a4,a5,ffffffffc0201938 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201948:	400c                	lw	a1,0(s0)
ffffffffc020194a:	00459693          	slli	a3,a1,0x4
ffffffffc020194e:	96a2                	add	a3,a3,s0
ffffffffc0201950:	02d78a63          	beq	a5,a3,ffffffffc0201984 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201954:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201956:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201958:	00469793          	slli	a5,a3,0x4
ffffffffc020195c:	97ba                	add	a5,a5,a4
ffffffffc020195e:	02f40e63          	beq	s0,a5,ffffffffc020199a <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc0201962:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201964:	e218                	sd	a4,0(a2)
    if (flag)
ffffffffc0201966:	e129                	bnez	a0,ffffffffc02019a8 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201968:	60a2                	ld	ra,8(sp)
ffffffffc020196a:	6402                	ld	s0,0(sp)
ffffffffc020196c:	0141                	addi	sp,sp,16
ffffffffc020196e:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201970:	fcf764e3          	bltu	a4,a5,ffffffffc0201938 <slob_free+0x20>
ffffffffc0201974:	fcf472e3          	bgeu	s0,a5,ffffffffc0201938 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201978:	400c                	lw	a1,0(s0)
ffffffffc020197a:	00459693          	slli	a3,a1,0x4
ffffffffc020197e:	96a2                	add	a3,a3,s0
ffffffffc0201980:	fcd79ae3          	bne	a5,a3,ffffffffc0201954 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201984:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201986:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201988:	9db5                	addw	a1,a1,a3
ffffffffc020198a:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc020198c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020198e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201990:	00469793          	slli	a5,a3,0x4
ffffffffc0201994:	97ba                	add	a5,a5,a4
ffffffffc0201996:	fcf416e3          	bne	s0,a5,ffffffffc0201962 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc020199a:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc020199c:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc020199e:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02019a0:	9ebd                	addw	a3,a3,a5
ffffffffc02019a2:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02019a4:	e70c                	sd	a1,8(a4)
ffffffffc02019a6:	d169                	beqz	a0,ffffffffc0201968 <slob_free+0x50>
}
ffffffffc02019a8:	6402                	ld	s0,0(sp)
ffffffffc02019aa:	60a2                	ld	ra,8(sp)
ffffffffc02019ac:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02019ae:	806ff06f          	j	ffffffffc02009b4 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02019b2:	25bd                	addiw	a1,a1,15
ffffffffc02019b4:	8191                	srli	a1,a1,0x4
ffffffffc02019b6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019b8:	100027f3          	csrr	a5,sstatus
ffffffffc02019bc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019be:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019c0:	d7bd                	beqz	a5,ffffffffc020192e <slob_free+0x16>
        intr_disable();
ffffffffc02019c2:	ff9fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc02019c6:	4505                	li	a0,1
ffffffffc02019c8:	b79d                	j	ffffffffc020192e <slob_free+0x16>
ffffffffc02019ca:	8082                	ret

ffffffffc02019cc <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019cc:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019ce:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019d0:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019d4:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019d6:	601000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
	if (!page)
ffffffffc02019da:	c91d                	beqz	a0,ffffffffc0201a10 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02019dc:	000b3697          	auipc	a3,0xb3
ffffffffc02019e0:	73c6b683          	ld	a3,1852(a3) # ffffffffc02b5118 <pages>
ffffffffc02019e4:	8d15                	sub	a0,a0,a3
ffffffffc02019e6:	8519                	srai	a0,a0,0x6
ffffffffc02019e8:	00006697          	auipc	a3,0x6
ffffffffc02019ec:	f686b683          	ld	a3,-152(a3) # ffffffffc0207950 <nbase>
ffffffffc02019f0:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02019f2:	00c51793          	slli	a5,a0,0xc
ffffffffc02019f6:	83b1                	srli	a5,a5,0xc
ffffffffc02019f8:	000b3717          	auipc	a4,0xb3
ffffffffc02019fc:	71873703          	ld	a4,1816(a4) # ffffffffc02b5110 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a00:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201a02:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a16 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201a06:	000b3697          	auipc	a3,0xb3
ffffffffc0201a0a:	7226b683          	ld	a3,1826(a3) # ffffffffc02b5128 <va_pa_offset>
ffffffffc0201a0e:	9536                	add	a0,a0,a3
}
ffffffffc0201a10:	60a2                	ld	ra,8(sp)
ffffffffc0201a12:	0141                	addi	sp,sp,16
ffffffffc0201a14:	8082                	ret
ffffffffc0201a16:	86aa                	mv	a3,a0
ffffffffc0201a18:	00005617          	auipc	a2,0x5
ffffffffc0201a1c:	88860613          	addi	a2,a2,-1912 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0201a20:	07300593          	li	a1,115
ffffffffc0201a24:	00005517          	auipc	a0,0x5
ffffffffc0201a28:	83c50513          	addi	a0,a0,-1988 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0201a2c:	ff2fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201a30 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201a30:	1101                	addi	sp,sp,-32
ffffffffc0201a32:	ec06                	sd	ra,24(sp)
ffffffffc0201a34:	e822                	sd	s0,16(sp)
ffffffffc0201a36:	e426                	sd	s1,8(sp)
ffffffffc0201a38:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201a3a:	01050713          	addi	a4,a0,16
ffffffffc0201a3e:	6785                	lui	a5,0x1
ffffffffc0201a40:	0cf77363          	bgeu	a4,a5,ffffffffc0201b06 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201a44:	00f50493          	addi	s1,a0,15
ffffffffc0201a48:	8091                	srli	s1,s1,0x4
ffffffffc0201a4a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a4c:	10002673          	csrr	a2,sstatus
ffffffffc0201a50:	8a09                	andi	a2,a2,2
ffffffffc0201a52:	e25d                	bnez	a2,ffffffffc0201af8 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a54:	000af917          	auipc	s2,0xaf
ffffffffc0201a58:	23c90913          	addi	s2,s2,572 # ffffffffc02b0c90 <slobfree>
ffffffffc0201a5c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a60:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc0201a62:	4398                	lw	a4,0(a5)
ffffffffc0201a64:	08975e63          	bge	a4,s1,ffffffffc0201b00 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc0201a68:	00f68b63          	beq	a3,a5,ffffffffc0201a7e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a6c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201a6e:	4018                	lw	a4,0(s0)
ffffffffc0201a70:	02975a63          	bge	a4,s1,ffffffffc0201aa4 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc0201a74:	00093683          	ld	a3,0(s2)
ffffffffc0201a78:	87a2                	mv	a5,s0
ffffffffc0201a7a:	fef699e3          	bne	a3,a5,ffffffffc0201a6c <slob_alloc.constprop.0+0x3c>
    if (flag)
ffffffffc0201a7e:	ee31                	bnez	a2,ffffffffc0201ada <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a80:	4501                	li	a0,0
ffffffffc0201a82:	f4bff0ef          	jal	ra,ffffffffc02019cc <__slob_get_free_pages.constprop.0>
ffffffffc0201a86:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a88:	cd05                	beqz	a0,ffffffffc0201ac0 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a8a:	6585                	lui	a1,0x1
ffffffffc0201a8c:	e8dff0ef          	jal	ra,ffffffffc0201918 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a90:	10002673          	csrr	a2,sstatus
ffffffffc0201a94:	8a09                	andi	a2,a2,2
ffffffffc0201a96:	ee05                	bnez	a2,ffffffffc0201ace <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a98:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a9c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201a9e:	4018                	lw	a4,0(s0)
ffffffffc0201aa0:	fc974ae3          	blt	a4,s1,ffffffffc0201a74 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201aa4:	04e48763          	beq	s1,a4,ffffffffc0201af2 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201aa8:	00449693          	slli	a3,s1,0x4
ffffffffc0201aac:	96a2                	add	a3,a3,s0
ffffffffc0201aae:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201ab0:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201ab2:	9f05                	subw	a4,a4,s1
ffffffffc0201ab4:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201ab6:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201ab8:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201aba:	00f93023          	sd	a5,0(s2)
    if (flag)
ffffffffc0201abe:	e20d                	bnez	a2,ffffffffc0201ae0 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201ac0:	60e2                	ld	ra,24(sp)
ffffffffc0201ac2:	8522                	mv	a0,s0
ffffffffc0201ac4:	6442                	ld	s0,16(sp)
ffffffffc0201ac6:	64a2                	ld	s1,8(sp)
ffffffffc0201ac8:	6902                	ld	s2,0(sp)
ffffffffc0201aca:	6105                	addi	sp,sp,32
ffffffffc0201acc:	8082                	ret
        intr_disable();
ffffffffc0201ace:	eedfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
			cur = slobfree;
ffffffffc0201ad2:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201ad6:	4605                	li	a2,1
ffffffffc0201ad8:	b7d1                	j	ffffffffc0201a9c <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201ada:	edbfe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201ade:	b74d                	j	ffffffffc0201a80 <slob_alloc.constprop.0+0x50>
ffffffffc0201ae0:	ed5fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
}
ffffffffc0201ae4:	60e2                	ld	ra,24(sp)
ffffffffc0201ae6:	8522                	mv	a0,s0
ffffffffc0201ae8:	6442                	ld	s0,16(sp)
ffffffffc0201aea:	64a2                	ld	s1,8(sp)
ffffffffc0201aec:	6902                	ld	s2,0(sp)
ffffffffc0201aee:	6105                	addi	sp,sp,32
ffffffffc0201af0:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201af2:	6418                	ld	a4,8(s0)
ffffffffc0201af4:	e798                	sd	a4,8(a5)
ffffffffc0201af6:	b7d1                	j	ffffffffc0201aba <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201af8:	ec3fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0201afc:	4605                	li	a2,1
ffffffffc0201afe:	bf99                	j	ffffffffc0201a54 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201b00:	843e                	mv	s0,a5
ffffffffc0201b02:	87b6                	mv	a5,a3
ffffffffc0201b04:	b745                	j	ffffffffc0201aa4 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201b06:	00005697          	auipc	a3,0x5
ffffffffc0201b0a:	aca68693          	addi	a3,a3,-1334 # ffffffffc02065d0 <commands+0xb28>
ffffffffc0201b0e:	00005617          	auipc	a2,0x5
ffffffffc0201b12:	84a60613          	addi	a2,a2,-1974 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201b16:	06300593          	li	a1,99
ffffffffc0201b1a:	00005517          	auipc	a0,0x5
ffffffffc0201b1e:	ad650513          	addi	a0,a0,-1322 # ffffffffc02065f0 <commands+0xb48>
ffffffffc0201b22:	efcfe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201b26 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201b26:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201b28:	00005517          	auipc	a0,0x5
ffffffffc0201b2c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0206608 <commands+0xb60>
{
ffffffffc0201b30:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201b32:	daefe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201b36:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b38:	00005517          	auipc	a0,0x5
ffffffffc0201b3c:	ae850513          	addi	a0,a0,-1304 # ffffffffc0206620 <commands+0xb78>
}
ffffffffc0201b40:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b42:	d9efe06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0201b46 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201b46:	4501                	li	a0,0
ffffffffc0201b48:	8082                	ret

ffffffffc0201b4a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b4a:	1101                	addi	sp,sp,-32
ffffffffc0201b4c:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b4e:	6905                	lui	s2,0x1
{
ffffffffc0201b50:	e822                	sd	s0,16(sp)
ffffffffc0201b52:	ec06                	sd	ra,24(sp)
ffffffffc0201b54:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b56:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bd9>
{
ffffffffc0201b5a:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b5c:	04a7f963          	bgeu	a5,a0,ffffffffc0201bae <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b60:	4561                	li	a0,24
ffffffffc0201b62:	ecfff0ef          	jal	ra,ffffffffc0201a30 <slob_alloc.constprop.0>
ffffffffc0201b66:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b68:	c929                	beqz	a0,ffffffffc0201bba <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b6a:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b6e:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201b70:	00f95763          	bge	s2,a5,ffffffffc0201b7e <kmalloc+0x34>
ffffffffc0201b74:	6705                	lui	a4,0x1
ffffffffc0201b76:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b78:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201b7a:	fef74ee3          	blt	a4,a5,ffffffffc0201b76 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b7e:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b80:	e4dff0ef          	jal	ra,ffffffffc02019cc <__slob_get_free_pages.constprop.0>
ffffffffc0201b84:	e488                	sd	a0,8(s1)
ffffffffc0201b86:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc0201b88:	c525                	beqz	a0,ffffffffc0201bf0 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b8a:	100027f3          	csrr	a5,sstatus
ffffffffc0201b8e:	8b89                	andi	a5,a5,2
ffffffffc0201b90:	ef8d                	bnez	a5,ffffffffc0201bca <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b92:	000b3797          	auipc	a5,0xb3
ffffffffc0201b96:	56678793          	addi	a5,a5,1382 # ffffffffc02b50f8 <bigblocks>
ffffffffc0201b9a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b9c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b9e:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201ba0:	60e2                	ld	ra,24(sp)
ffffffffc0201ba2:	8522                	mv	a0,s0
ffffffffc0201ba4:	6442                	ld	s0,16(sp)
ffffffffc0201ba6:	64a2                	ld	s1,8(sp)
ffffffffc0201ba8:	6902                	ld	s2,0(sp)
ffffffffc0201baa:	6105                	addi	sp,sp,32
ffffffffc0201bac:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201bae:	0541                	addi	a0,a0,16
ffffffffc0201bb0:	e81ff0ef          	jal	ra,ffffffffc0201a30 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201bb4:	01050413          	addi	s0,a0,16
ffffffffc0201bb8:	f565                	bnez	a0,ffffffffc0201ba0 <kmalloc+0x56>
ffffffffc0201bba:	4401                	li	s0,0
}
ffffffffc0201bbc:	60e2                	ld	ra,24(sp)
ffffffffc0201bbe:	8522                	mv	a0,s0
ffffffffc0201bc0:	6442                	ld	s0,16(sp)
ffffffffc0201bc2:	64a2                	ld	s1,8(sp)
ffffffffc0201bc4:	6902                	ld	s2,0(sp)
ffffffffc0201bc6:	6105                	addi	sp,sp,32
ffffffffc0201bc8:	8082                	ret
        intr_disable();
ffffffffc0201bca:	df1fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
		bb->next = bigblocks;
ffffffffc0201bce:	000b3797          	auipc	a5,0xb3
ffffffffc0201bd2:	52a78793          	addi	a5,a5,1322 # ffffffffc02b50f8 <bigblocks>
ffffffffc0201bd6:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201bd8:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201bda:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201bdc:	dd9fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
		return bb->pages;
ffffffffc0201be0:	6480                	ld	s0,8(s1)
}
ffffffffc0201be2:	60e2                	ld	ra,24(sp)
ffffffffc0201be4:	64a2                	ld	s1,8(sp)
ffffffffc0201be6:	8522                	mv	a0,s0
ffffffffc0201be8:	6442                	ld	s0,16(sp)
ffffffffc0201bea:	6902                	ld	s2,0(sp)
ffffffffc0201bec:	6105                	addi	sp,sp,32
ffffffffc0201bee:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bf0:	45e1                	li	a1,24
ffffffffc0201bf2:	8526                	mv	a0,s1
ffffffffc0201bf4:	d25ff0ef          	jal	ra,ffffffffc0201918 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201bf8:	b765                	j	ffffffffc0201ba0 <kmalloc+0x56>

ffffffffc0201bfa <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bfa:	c169                	beqz	a0,ffffffffc0201cbc <kfree+0xc2>
{
ffffffffc0201bfc:	1101                	addi	sp,sp,-32
ffffffffc0201bfe:	e822                	sd	s0,16(sp)
ffffffffc0201c00:	ec06                	sd	ra,24(sp)
ffffffffc0201c02:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201c04:	03451793          	slli	a5,a0,0x34
ffffffffc0201c08:	842a                	mv	s0,a0
ffffffffc0201c0a:	e3d9                	bnez	a5,ffffffffc0201c90 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c0c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c10:	8b89                	andi	a5,a5,2
ffffffffc0201c12:	e7d9                	bnez	a5,ffffffffc0201ca0 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c14:	000b3797          	auipc	a5,0xb3
ffffffffc0201c18:	4e47b783          	ld	a5,1252(a5) # ffffffffc02b50f8 <bigblocks>
    return 0;
ffffffffc0201c1c:	4601                	li	a2,0
ffffffffc0201c1e:	cbad                	beqz	a5,ffffffffc0201c90 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201c20:	000b3697          	auipc	a3,0xb3
ffffffffc0201c24:	4d868693          	addi	a3,a3,1240 # ffffffffc02b50f8 <bigblocks>
ffffffffc0201c28:	a021                	j	ffffffffc0201c30 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c2a:	01048693          	addi	a3,s1,16
ffffffffc0201c2e:	c3a5                	beqz	a5,ffffffffc0201c8e <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc0201c30:	6798                	ld	a4,8(a5)
ffffffffc0201c32:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201c34:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201c36:	fe871ae3          	bne	a4,s0,ffffffffc0201c2a <kfree+0x30>
				*last = bb->next;
ffffffffc0201c3a:	e29c                	sd	a5,0(a3)
    if (flag)
ffffffffc0201c3c:	ee2d                	bnez	a2,ffffffffc0201cb6 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201c3e:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201c42:	4098                	lw	a4,0(s1)
ffffffffc0201c44:	08f46963          	bltu	s0,a5,ffffffffc0201cd6 <kfree+0xdc>
ffffffffc0201c48:	000b3697          	auipc	a3,0xb3
ffffffffc0201c4c:	4e06b683          	ld	a3,1248(a3) # ffffffffc02b5128 <va_pa_offset>
ffffffffc0201c50:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc0201c52:	8031                	srli	s0,s0,0xc
ffffffffc0201c54:	000b3797          	auipc	a5,0xb3
ffffffffc0201c58:	4bc7b783          	ld	a5,1212(a5) # ffffffffc02b5110 <npage>
ffffffffc0201c5c:	06f47163          	bgeu	s0,a5,ffffffffc0201cbe <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c60:	00006517          	auipc	a0,0x6
ffffffffc0201c64:	cf053503          	ld	a0,-784(a0) # ffffffffc0207950 <nbase>
ffffffffc0201c68:	8c09                	sub	s0,s0,a0
ffffffffc0201c6a:	041a                	slli	s0,s0,0x6
	free_pages(kva2page(kva), 1 << order);
ffffffffc0201c6c:	000b3517          	auipc	a0,0xb3
ffffffffc0201c70:	4ac53503          	ld	a0,1196(a0) # ffffffffc02b5118 <pages>
ffffffffc0201c74:	4585                	li	a1,1
ffffffffc0201c76:	9522                	add	a0,a0,s0
ffffffffc0201c78:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c7c:	399000ef          	jal	ra,ffffffffc0202814 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c80:	6442                	ld	s0,16(sp)
ffffffffc0201c82:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c84:	8526                	mv	a0,s1
}
ffffffffc0201c86:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c88:	45e1                	li	a1,24
}
ffffffffc0201c8a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c8c:	b171                	j	ffffffffc0201918 <slob_free>
ffffffffc0201c8e:	e20d                	bnez	a2,ffffffffc0201cb0 <kfree+0xb6>
ffffffffc0201c90:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c94:	6442                	ld	s0,16(sp)
ffffffffc0201c96:	60e2                	ld	ra,24(sp)
ffffffffc0201c98:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c9a:	4581                	li	a1,0
}
ffffffffc0201c9c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c9e:	b9ad                	j	ffffffffc0201918 <slob_free>
        intr_disable();
ffffffffc0201ca0:	d1bfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ca4:	000b3797          	auipc	a5,0xb3
ffffffffc0201ca8:	4547b783          	ld	a5,1108(a5) # ffffffffc02b50f8 <bigblocks>
        return 1;
ffffffffc0201cac:	4605                	li	a2,1
ffffffffc0201cae:	fbad                	bnez	a5,ffffffffc0201c20 <kfree+0x26>
        intr_enable();
ffffffffc0201cb0:	d05fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201cb4:	bff1                	j	ffffffffc0201c90 <kfree+0x96>
ffffffffc0201cb6:	cfffe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0201cba:	b751                	j	ffffffffc0201c3e <kfree+0x44>
ffffffffc0201cbc:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201cbe:	00004617          	auipc	a2,0x4
ffffffffc0201cc2:	5b260613          	addi	a2,a2,1458 # ffffffffc0206270 <commands+0x7c8>
ffffffffc0201cc6:	06b00593          	li	a1,107
ffffffffc0201cca:	00004517          	auipc	a0,0x4
ffffffffc0201cce:	59650513          	addi	a0,a0,1430 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0201cd2:	d4cfe0ef          	jal	ra,ffffffffc020021e <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201cd6:	86a2                	mv	a3,s0
ffffffffc0201cd8:	00005617          	auipc	a2,0x5
ffffffffc0201cdc:	96860613          	addi	a2,a2,-1688 # ffffffffc0206640 <commands+0xb98>
ffffffffc0201ce0:	07900593          	li	a1,121
ffffffffc0201ce4:	00004517          	auipc	a0,0x4
ffffffffc0201ce8:	57c50513          	addi	a0,a0,1404 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0201cec:	d32fe0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0201cf0 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201cf0:	000af797          	auipc	a5,0xaf
ffffffffc0201cf4:	3b078793          	addi	a5,a5,944 # ffffffffc02b10a0 <free_area>
ffffffffc0201cf8:	e79c                	sd	a5,8(a5)
ffffffffc0201cfa:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201cfc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201d00:	8082                	ret

ffffffffc0201d02 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201d02:	000af517          	auipc	a0,0xaf
ffffffffc0201d06:	3ae56503          	lwu	a0,942(a0) # ffffffffc02b10b0 <free_area+0x10>
ffffffffc0201d0a:	8082                	ret

ffffffffc0201d0c <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201d0c:	715d                	addi	sp,sp,-80
ffffffffc0201d0e:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201d10:	000af417          	auipc	s0,0xaf
ffffffffc0201d14:	39040413          	addi	s0,s0,912 # ffffffffc02b10a0 <free_area>
ffffffffc0201d18:	641c                	ld	a5,8(s0)
ffffffffc0201d1a:	e486                	sd	ra,72(sp)
ffffffffc0201d1c:	fc26                	sd	s1,56(sp)
ffffffffc0201d1e:	f84a                	sd	s2,48(sp)
ffffffffc0201d20:	f44e                	sd	s3,40(sp)
ffffffffc0201d22:	f052                	sd	s4,32(sp)
ffffffffc0201d24:	ec56                	sd	s5,24(sp)
ffffffffc0201d26:	e85a                	sd	s6,16(sp)
ffffffffc0201d28:	e45e                	sd	s7,8(sp)
ffffffffc0201d2a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d2c:	2a878d63          	beq	a5,s0,ffffffffc0201fe6 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0201d30:	4481                	li	s1,0
ffffffffc0201d32:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201d34:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201d38:	8b09                	andi	a4,a4,2
ffffffffc0201d3a:	2a070a63          	beqz	a4,ffffffffc0201fee <default_check+0x2e2>
        count++, total += p->property;
ffffffffc0201d3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201d42:	679c                	ld	a5,8(a5)
ffffffffc0201d44:	2905                	addiw	s2,s2,1
ffffffffc0201d46:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d48:	fe8796e3          	bne	a5,s0,ffffffffc0201d34 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201d4c:	89a6                	mv	s3,s1
ffffffffc0201d4e:	307000ef          	jal	ra,ffffffffc0202854 <nr_free_pages>
ffffffffc0201d52:	6f351e63          	bne	a0,s3,ffffffffc020244e <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201d56:	4505                	li	a0,1
ffffffffc0201d58:	27f000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201d5c:	8aaa                	mv	s5,a0
ffffffffc0201d5e:	42050863          	beqz	a0,ffffffffc020218e <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201d62:	4505                	li	a0,1
ffffffffc0201d64:	273000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201d68:	89aa                	mv	s3,a0
ffffffffc0201d6a:	70050263          	beqz	a0,ffffffffc020246e <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201d6e:	4505                	li	a0,1
ffffffffc0201d70:	267000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201d74:	8a2a                	mv	s4,a0
ffffffffc0201d76:	48050c63          	beqz	a0,ffffffffc020220e <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201d7a:	293a8a63          	beq	s5,s3,ffffffffc020200e <default_check+0x302>
ffffffffc0201d7e:	28aa8863          	beq	s5,a0,ffffffffc020200e <default_check+0x302>
ffffffffc0201d82:	28a98663          	beq	s3,a0,ffffffffc020200e <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201d86:	000aa783          	lw	a5,0(s5)
ffffffffc0201d8a:	2a079263          	bnez	a5,ffffffffc020202e <default_check+0x322>
ffffffffc0201d8e:	0009a783          	lw	a5,0(s3)
ffffffffc0201d92:	28079e63          	bnez	a5,ffffffffc020202e <default_check+0x322>
ffffffffc0201d96:	411c                	lw	a5,0(a0)
ffffffffc0201d98:	28079b63          	bnez	a5,ffffffffc020202e <default_check+0x322>
    return page - pages + nbase;
ffffffffc0201d9c:	000b3797          	auipc	a5,0xb3
ffffffffc0201da0:	37c7b783          	ld	a5,892(a5) # ffffffffc02b5118 <pages>
ffffffffc0201da4:	40fa8733          	sub	a4,s5,a5
ffffffffc0201da8:	00006617          	auipc	a2,0x6
ffffffffc0201dac:	ba863603          	ld	a2,-1112(a2) # ffffffffc0207950 <nbase>
ffffffffc0201db0:	8719                	srai	a4,a4,0x6
ffffffffc0201db2:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201db4:	000b3697          	auipc	a3,0xb3
ffffffffc0201db8:	35c6b683          	ld	a3,860(a3) # ffffffffc02b5110 <npage>
ffffffffc0201dbc:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dbe:	0732                	slli	a4,a4,0xc
ffffffffc0201dc0:	28d77763          	bgeu	a4,a3,ffffffffc020204e <default_check+0x342>
    return page - pages + nbase;
ffffffffc0201dc4:	40f98733          	sub	a4,s3,a5
ffffffffc0201dc8:	8719                	srai	a4,a4,0x6
ffffffffc0201dca:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dcc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201dce:	4cd77063          	bgeu	a4,a3,ffffffffc020228e <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201dd2:	40f507b3          	sub	a5,a0,a5
ffffffffc0201dd6:	8799                	srai	a5,a5,0x6
ffffffffc0201dd8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dda:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201ddc:	30d7f963          	bgeu	a5,a3,ffffffffc02020ee <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201de0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201de2:	00043c03          	ld	s8,0(s0)
ffffffffc0201de6:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201dea:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201dee:	e400                	sd	s0,8(s0)
ffffffffc0201df0:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201df2:	000af797          	auipc	a5,0xaf
ffffffffc0201df6:	2a07af23          	sw	zero,702(a5) # ffffffffc02b10b0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201dfa:	1dd000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201dfe:	2c051863          	bnez	a0,ffffffffc02020ce <default_check+0x3c2>
    free_page(p0);
ffffffffc0201e02:	4585                	li	a1,1
ffffffffc0201e04:	8556                	mv	a0,s5
ffffffffc0201e06:	20f000ef          	jal	ra,ffffffffc0202814 <free_pages>
    free_page(p1);
ffffffffc0201e0a:	4585                	li	a1,1
ffffffffc0201e0c:	854e                	mv	a0,s3
ffffffffc0201e0e:	207000ef          	jal	ra,ffffffffc0202814 <free_pages>
    free_page(p2);
ffffffffc0201e12:	4585                	li	a1,1
ffffffffc0201e14:	8552                	mv	a0,s4
ffffffffc0201e16:	1ff000ef          	jal	ra,ffffffffc0202814 <free_pages>
    assert(nr_free == 3);
ffffffffc0201e1a:	4818                	lw	a4,16(s0)
ffffffffc0201e1c:	478d                	li	a5,3
ffffffffc0201e1e:	28f71863          	bne	a4,a5,ffffffffc02020ae <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201e22:	4505                	li	a0,1
ffffffffc0201e24:	1b3000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201e28:	89aa                	mv	s3,a0
ffffffffc0201e2a:	26050263          	beqz	a0,ffffffffc020208e <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201e2e:	4505                	li	a0,1
ffffffffc0201e30:	1a7000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201e34:	8aaa                	mv	s5,a0
ffffffffc0201e36:	3a050c63          	beqz	a0,ffffffffc02021ee <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201e3a:	4505                	li	a0,1
ffffffffc0201e3c:	19b000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201e40:	8a2a                	mv	s4,a0
ffffffffc0201e42:	38050663          	beqz	a0,ffffffffc02021ce <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0201e46:	4505                	li	a0,1
ffffffffc0201e48:	18f000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201e4c:	36051163          	bnez	a0,ffffffffc02021ae <default_check+0x4a2>
    free_page(p0);
ffffffffc0201e50:	4585                	li	a1,1
ffffffffc0201e52:	854e                	mv	a0,s3
ffffffffc0201e54:	1c1000ef          	jal	ra,ffffffffc0202814 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201e58:	641c                	ld	a5,8(s0)
ffffffffc0201e5a:	20878a63          	beq	a5,s0,ffffffffc020206e <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0201e5e:	4505                	li	a0,1
ffffffffc0201e60:	177000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201e64:	30a99563          	bne	s3,a0,ffffffffc020216e <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0201e68:	4505                	li	a0,1
ffffffffc0201e6a:	16d000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201e6e:	2e051063          	bnez	a0,ffffffffc020214e <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0201e72:	481c                	lw	a5,16(s0)
ffffffffc0201e74:	2a079d63          	bnez	a5,ffffffffc020212e <default_check+0x422>
    free_page(p);
ffffffffc0201e78:	854e                	mv	a0,s3
ffffffffc0201e7a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201e7c:	01843023          	sd	s8,0(s0)
ffffffffc0201e80:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201e84:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201e88:	18d000ef          	jal	ra,ffffffffc0202814 <free_pages>
    free_page(p1);
ffffffffc0201e8c:	4585                	li	a1,1
ffffffffc0201e8e:	8556                	mv	a0,s5
ffffffffc0201e90:	185000ef          	jal	ra,ffffffffc0202814 <free_pages>
    free_page(p2);
ffffffffc0201e94:	4585                	li	a1,1
ffffffffc0201e96:	8552                	mv	a0,s4
ffffffffc0201e98:	17d000ef          	jal	ra,ffffffffc0202814 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201e9c:	4515                	li	a0,5
ffffffffc0201e9e:	139000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201ea2:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201ea4:	26050563          	beqz	a0,ffffffffc020210e <default_check+0x402>
ffffffffc0201ea8:	651c                	ld	a5,8(a0)
ffffffffc0201eaa:	8385                	srli	a5,a5,0x1
ffffffffc0201eac:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201eae:	54079063          	bnez	a5,ffffffffc02023ee <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201eb2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201eb4:	00043b03          	ld	s6,0(s0)
ffffffffc0201eb8:	00843a83          	ld	s5,8(s0)
ffffffffc0201ebc:	e000                	sd	s0,0(s0)
ffffffffc0201ebe:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201ec0:	117000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201ec4:	50051563          	bnez	a0,ffffffffc02023ce <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201ec8:	08098a13          	addi	s4,s3,128
ffffffffc0201ecc:	8552                	mv	a0,s4
ffffffffc0201ece:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201ed0:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201ed4:	000af797          	auipc	a5,0xaf
ffffffffc0201ed8:	1c07ae23          	sw	zero,476(a5) # ffffffffc02b10b0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201edc:	139000ef          	jal	ra,ffffffffc0202814 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201ee0:	4511                	li	a0,4
ffffffffc0201ee2:	0f5000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201ee6:	4c051463          	bnez	a0,ffffffffc02023ae <default_check+0x6a2>
ffffffffc0201eea:	0889b783          	ld	a5,136(s3)
ffffffffc0201eee:	8385                	srli	a5,a5,0x1
ffffffffc0201ef0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201ef2:	48078e63          	beqz	a5,ffffffffc020238e <default_check+0x682>
ffffffffc0201ef6:	0909a703          	lw	a4,144(s3)
ffffffffc0201efa:	478d                	li	a5,3
ffffffffc0201efc:	48f71963          	bne	a4,a5,ffffffffc020238e <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201f00:	450d                	li	a0,3
ffffffffc0201f02:	0d5000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201f06:	8c2a                	mv	s8,a0
ffffffffc0201f08:	46050363          	beqz	a0,ffffffffc020236e <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201f0c:	4505                	li	a0,1
ffffffffc0201f0e:	0c9000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201f12:	42051e63          	bnez	a0,ffffffffc020234e <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201f16:	418a1c63          	bne	s4,s8,ffffffffc020232e <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201f1a:	4585                	li	a1,1
ffffffffc0201f1c:	854e                	mv	a0,s3
ffffffffc0201f1e:	0f7000ef          	jal	ra,ffffffffc0202814 <free_pages>
    free_pages(p1, 3);
ffffffffc0201f22:	458d                	li	a1,3
ffffffffc0201f24:	8552                	mv	a0,s4
ffffffffc0201f26:	0ef000ef          	jal	ra,ffffffffc0202814 <free_pages>
ffffffffc0201f2a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201f2e:	04098c13          	addi	s8,s3,64
ffffffffc0201f32:	8385                	srli	a5,a5,0x1
ffffffffc0201f34:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201f36:	3c078c63          	beqz	a5,ffffffffc020230e <default_check+0x602>
ffffffffc0201f3a:	0109a703          	lw	a4,16(s3)
ffffffffc0201f3e:	4785                	li	a5,1
ffffffffc0201f40:	3cf71763          	bne	a4,a5,ffffffffc020230e <default_check+0x602>
ffffffffc0201f44:	008a3783          	ld	a5,8(s4) # 1008 <_binary_obj___user_faultread_out_size-0x8bc0>
ffffffffc0201f48:	8385                	srli	a5,a5,0x1
ffffffffc0201f4a:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201f4c:	3a078163          	beqz	a5,ffffffffc02022ee <default_check+0x5e2>
ffffffffc0201f50:	010a2703          	lw	a4,16(s4)
ffffffffc0201f54:	478d                	li	a5,3
ffffffffc0201f56:	38f71c63          	bne	a4,a5,ffffffffc02022ee <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201f5a:	4505                	li	a0,1
ffffffffc0201f5c:	07b000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201f60:	36a99763          	bne	s3,a0,ffffffffc02022ce <default_check+0x5c2>
    free_page(p0);
ffffffffc0201f64:	4585                	li	a1,1
ffffffffc0201f66:	0af000ef          	jal	ra,ffffffffc0202814 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201f6a:	4509                	li	a0,2
ffffffffc0201f6c:	06b000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201f70:	32aa1f63          	bne	s4,a0,ffffffffc02022ae <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0201f74:	4589                	li	a1,2
ffffffffc0201f76:	09f000ef          	jal	ra,ffffffffc0202814 <free_pages>
    free_page(p2);
ffffffffc0201f7a:	4585                	li	a1,1
ffffffffc0201f7c:	8562                	mv	a0,s8
ffffffffc0201f7e:	097000ef          	jal	ra,ffffffffc0202814 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201f82:	4515                	li	a0,5
ffffffffc0201f84:	053000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201f88:	89aa                	mv	s3,a0
ffffffffc0201f8a:	48050263          	beqz	a0,ffffffffc020240e <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201f8e:	4505                	li	a0,1
ffffffffc0201f90:	047000ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0201f94:	2c051d63          	bnez	a0,ffffffffc020226e <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0201f98:	481c                	lw	a5,16(s0)
ffffffffc0201f9a:	2a079a63          	bnez	a5,ffffffffc020224e <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201f9e:	4595                	li	a1,5
ffffffffc0201fa0:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201fa2:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201fa6:	01643023          	sd	s6,0(s0)
ffffffffc0201faa:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201fae:	067000ef          	jal	ra,ffffffffc0202814 <free_pages>
    return listelm->next;
ffffffffc0201fb2:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fb4:	00878963          	beq	a5,s0,ffffffffc0201fc6 <default_check+0x2ba>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0201fb8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201fbc:	679c                	ld	a5,8(a5)
ffffffffc0201fbe:	397d                	addiw	s2,s2,-1
ffffffffc0201fc0:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fc2:	fe879be3          	bne	a5,s0,ffffffffc0201fb8 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0201fc6:	26091463          	bnez	s2,ffffffffc020222e <default_check+0x522>
    assert(total == 0);
ffffffffc0201fca:	46049263          	bnez	s1,ffffffffc020242e <default_check+0x722>
}
ffffffffc0201fce:	60a6                	ld	ra,72(sp)
ffffffffc0201fd0:	6406                	ld	s0,64(sp)
ffffffffc0201fd2:	74e2                	ld	s1,56(sp)
ffffffffc0201fd4:	7942                	ld	s2,48(sp)
ffffffffc0201fd6:	79a2                	ld	s3,40(sp)
ffffffffc0201fd8:	7a02                	ld	s4,32(sp)
ffffffffc0201fda:	6ae2                	ld	s5,24(sp)
ffffffffc0201fdc:	6b42                	ld	s6,16(sp)
ffffffffc0201fde:	6ba2                	ld	s7,8(sp)
ffffffffc0201fe0:	6c02                	ld	s8,0(sp)
ffffffffc0201fe2:	6161                	addi	sp,sp,80
ffffffffc0201fe4:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fe6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201fe8:	4481                	li	s1,0
ffffffffc0201fea:	4901                	li	s2,0
ffffffffc0201fec:	b38d                	j	ffffffffc0201d4e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201fee:	00004697          	auipc	a3,0x4
ffffffffc0201ff2:	67a68693          	addi	a3,a3,1658 # ffffffffc0206668 <commands+0xbc0>
ffffffffc0201ff6:	00004617          	auipc	a2,0x4
ffffffffc0201ffa:	36260613          	addi	a2,a2,866 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0201ffe:	11000593          	li	a1,272
ffffffffc0202002:	00004517          	auipc	a0,0x4
ffffffffc0202006:	67650513          	addi	a0,a0,1654 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020200a:	a14fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020200e:	00004697          	auipc	a3,0x4
ffffffffc0202012:	70268693          	addi	a3,a3,1794 # ffffffffc0206710 <commands+0xc68>
ffffffffc0202016:	00004617          	auipc	a2,0x4
ffffffffc020201a:	34260613          	addi	a2,a2,834 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020201e:	0db00593          	li	a1,219
ffffffffc0202022:	00004517          	auipc	a0,0x4
ffffffffc0202026:	65650513          	addi	a0,a0,1622 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020202a:	9f4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020202e:	00004697          	auipc	a3,0x4
ffffffffc0202032:	70a68693          	addi	a3,a3,1802 # ffffffffc0206738 <commands+0xc90>
ffffffffc0202036:	00004617          	auipc	a2,0x4
ffffffffc020203a:	32260613          	addi	a2,a2,802 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020203e:	0dc00593          	li	a1,220
ffffffffc0202042:	00004517          	auipc	a0,0x4
ffffffffc0202046:	63650513          	addi	a0,a0,1590 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020204a:	9d4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020204e:	00004697          	auipc	a3,0x4
ffffffffc0202052:	72a68693          	addi	a3,a3,1834 # ffffffffc0206778 <commands+0xcd0>
ffffffffc0202056:	00004617          	auipc	a2,0x4
ffffffffc020205a:	30260613          	addi	a2,a2,770 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020205e:	0de00593          	li	a1,222
ffffffffc0202062:	00004517          	auipc	a0,0x4
ffffffffc0202066:	61650513          	addi	a0,a0,1558 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020206a:	9b4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(!list_empty(&free_list));
ffffffffc020206e:	00004697          	auipc	a3,0x4
ffffffffc0202072:	79268693          	addi	a3,a3,1938 # ffffffffc0206800 <commands+0xd58>
ffffffffc0202076:	00004617          	auipc	a2,0x4
ffffffffc020207a:	2e260613          	addi	a2,a2,738 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020207e:	0f700593          	li	a1,247
ffffffffc0202082:	00004517          	auipc	a0,0x4
ffffffffc0202086:	5f650513          	addi	a0,a0,1526 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020208a:	994fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020208e:	00004697          	auipc	a3,0x4
ffffffffc0202092:	62268693          	addi	a3,a3,1570 # ffffffffc02066b0 <commands+0xc08>
ffffffffc0202096:	00004617          	auipc	a2,0x4
ffffffffc020209a:	2c260613          	addi	a2,a2,706 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020209e:	0f000593          	li	a1,240
ffffffffc02020a2:	00004517          	auipc	a0,0x4
ffffffffc02020a6:	5d650513          	addi	a0,a0,1494 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02020aa:	974fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 3);
ffffffffc02020ae:	00004697          	auipc	a3,0x4
ffffffffc02020b2:	74268693          	addi	a3,a3,1858 # ffffffffc02067f0 <commands+0xd48>
ffffffffc02020b6:	00004617          	auipc	a2,0x4
ffffffffc02020ba:	2a260613          	addi	a2,a2,674 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02020be:	0ee00593          	li	a1,238
ffffffffc02020c2:	00004517          	auipc	a0,0x4
ffffffffc02020c6:	5b650513          	addi	a0,a0,1462 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02020ca:	954fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020ce:	00004697          	auipc	a3,0x4
ffffffffc02020d2:	70a68693          	addi	a3,a3,1802 # ffffffffc02067d8 <commands+0xd30>
ffffffffc02020d6:	00004617          	auipc	a2,0x4
ffffffffc02020da:	28260613          	addi	a2,a2,642 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02020de:	0e900593          	li	a1,233
ffffffffc02020e2:	00004517          	auipc	a0,0x4
ffffffffc02020e6:	59650513          	addi	a0,a0,1430 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02020ea:	934fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02020ee:	00004697          	auipc	a3,0x4
ffffffffc02020f2:	6ca68693          	addi	a3,a3,1738 # ffffffffc02067b8 <commands+0xd10>
ffffffffc02020f6:	00004617          	auipc	a2,0x4
ffffffffc02020fa:	26260613          	addi	a2,a2,610 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02020fe:	0e000593          	li	a1,224
ffffffffc0202102:	00004517          	auipc	a0,0x4
ffffffffc0202106:	57650513          	addi	a0,a0,1398 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020210a:	914fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 != NULL);
ffffffffc020210e:	00004697          	auipc	a3,0x4
ffffffffc0202112:	73a68693          	addi	a3,a3,1850 # ffffffffc0206848 <commands+0xda0>
ffffffffc0202116:	00004617          	auipc	a2,0x4
ffffffffc020211a:	24260613          	addi	a2,a2,578 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020211e:	11800593          	li	a1,280
ffffffffc0202122:	00004517          	auipc	a0,0x4
ffffffffc0202126:	55650513          	addi	a0,a0,1366 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020212a:	8f4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 0);
ffffffffc020212e:	00004697          	auipc	a3,0x4
ffffffffc0202132:	70a68693          	addi	a3,a3,1802 # ffffffffc0206838 <commands+0xd90>
ffffffffc0202136:	00004617          	auipc	a2,0x4
ffffffffc020213a:	22260613          	addi	a2,a2,546 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020213e:	0fd00593          	li	a1,253
ffffffffc0202142:	00004517          	auipc	a0,0x4
ffffffffc0202146:	53650513          	addi	a0,a0,1334 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020214a:	8d4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020214e:	00004697          	auipc	a3,0x4
ffffffffc0202152:	68a68693          	addi	a3,a3,1674 # ffffffffc02067d8 <commands+0xd30>
ffffffffc0202156:	00004617          	auipc	a2,0x4
ffffffffc020215a:	20260613          	addi	a2,a2,514 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020215e:	0fb00593          	li	a1,251
ffffffffc0202162:	00004517          	auipc	a0,0x4
ffffffffc0202166:	51650513          	addi	a0,a0,1302 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020216a:	8b4fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020216e:	00004697          	auipc	a3,0x4
ffffffffc0202172:	6aa68693          	addi	a3,a3,1706 # ffffffffc0206818 <commands+0xd70>
ffffffffc0202176:	00004617          	auipc	a2,0x4
ffffffffc020217a:	1e260613          	addi	a2,a2,482 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020217e:	0fa00593          	li	a1,250
ffffffffc0202182:	00004517          	auipc	a0,0x4
ffffffffc0202186:	4f650513          	addi	a0,a0,1270 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020218a:	894fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020218e:	00004697          	auipc	a3,0x4
ffffffffc0202192:	52268693          	addi	a3,a3,1314 # ffffffffc02066b0 <commands+0xc08>
ffffffffc0202196:	00004617          	auipc	a2,0x4
ffffffffc020219a:	1c260613          	addi	a2,a2,450 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020219e:	0d700593          	li	a1,215
ffffffffc02021a2:	00004517          	auipc	a0,0x4
ffffffffc02021a6:	4d650513          	addi	a0,a0,1238 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02021aa:	874fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021ae:	00004697          	auipc	a3,0x4
ffffffffc02021b2:	62a68693          	addi	a3,a3,1578 # ffffffffc02067d8 <commands+0xd30>
ffffffffc02021b6:	00004617          	auipc	a2,0x4
ffffffffc02021ba:	1a260613          	addi	a2,a2,418 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02021be:	0f400593          	li	a1,244
ffffffffc02021c2:	00004517          	auipc	a0,0x4
ffffffffc02021c6:	4b650513          	addi	a0,a0,1206 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02021ca:	854fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021ce:	00004697          	auipc	a3,0x4
ffffffffc02021d2:	52268693          	addi	a3,a3,1314 # ffffffffc02066f0 <commands+0xc48>
ffffffffc02021d6:	00004617          	auipc	a2,0x4
ffffffffc02021da:	18260613          	addi	a2,a2,386 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02021de:	0f200593          	li	a1,242
ffffffffc02021e2:	00004517          	auipc	a0,0x4
ffffffffc02021e6:	49650513          	addi	a0,a0,1174 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02021ea:	834fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02021ee:	00004697          	auipc	a3,0x4
ffffffffc02021f2:	4e268693          	addi	a3,a3,1250 # ffffffffc02066d0 <commands+0xc28>
ffffffffc02021f6:	00004617          	auipc	a2,0x4
ffffffffc02021fa:	16260613          	addi	a2,a2,354 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02021fe:	0f100593          	li	a1,241
ffffffffc0202202:	00004517          	auipc	a0,0x4
ffffffffc0202206:	47650513          	addi	a0,a0,1142 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020220a:	814fe0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020220e:	00004697          	auipc	a3,0x4
ffffffffc0202212:	4e268693          	addi	a3,a3,1250 # ffffffffc02066f0 <commands+0xc48>
ffffffffc0202216:	00004617          	auipc	a2,0x4
ffffffffc020221a:	14260613          	addi	a2,a2,322 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020221e:	0d900593          	li	a1,217
ffffffffc0202222:	00004517          	auipc	a0,0x4
ffffffffc0202226:	45650513          	addi	a0,a0,1110 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020222a:	ff5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(count == 0);
ffffffffc020222e:	00004697          	auipc	a3,0x4
ffffffffc0202232:	76a68693          	addi	a3,a3,1898 # ffffffffc0206998 <commands+0xef0>
ffffffffc0202236:	00004617          	auipc	a2,0x4
ffffffffc020223a:	12260613          	addi	a2,a2,290 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020223e:	14600593          	li	a1,326
ffffffffc0202242:	00004517          	auipc	a0,0x4
ffffffffc0202246:	43650513          	addi	a0,a0,1078 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020224a:	fd5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free == 0);
ffffffffc020224e:	00004697          	auipc	a3,0x4
ffffffffc0202252:	5ea68693          	addi	a3,a3,1514 # ffffffffc0206838 <commands+0xd90>
ffffffffc0202256:	00004617          	auipc	a2,0x4
ffffffffc020225a:	10260613          	addi	a2,a2,258 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020225e:	13a00593          	li	a1,314
ffffffffc0202262:	00004517          	auipc	a0,0x4
ffffffffc0202266:	41650513          	addi	a0,a0,1046 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020226a:	fb5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020226e:	00004697          	auipc	a3,0x4
ffffffffc0202272:	56a68693          	addi	a3,a3,1386 # ffffffffc02067d8 <commands+0xd30>
ffffffffc0202276:	00004617          	auipc	a2,0x4
ffffffffc020227a:	0e260613          	addi	a2,a2,226 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020227e:	13800593          	li	a1,312
ffffffffc0202282:	00004517          	auipc	a0,0x4
ffffffffc0202286:	3f650513          	addi	a0,a0,1014 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020228a:	f95fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020228e:	00004697          	auipc	a3,0x4
ffffffffc0202292:	50a68693          	addi	a3,a3,1290 # ffffffffc0206798 <commands+0xcf0>
ffffffffc0202296:	00004617          	auipc	a2,0x4
ffffffffc020229a:	0c260613          	addi	a2,a2,194 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020229e:	0df00593          	li	a1,223
ffffffffc02022a2:	00004517          	auipc	a0,0x4
ffffffffc02022a6:	3d650513          	addi	a0,a0,982 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02022aa:	f75fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02022ae:	00004697          	auipc	a3,0x4
ffffffffc02022b2:	6aa68693          	addi	a3,a3,1706 # ffffffffc0206958 <commands+0xeb0>
ffffffffc02022b6:	00004617          	auipc	a2,0x4
ffffffffc02022ba:	0a260613          	addi	a2,a2,162 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02022be:	13200593          	li	a1,306
ffffffffc02022c2:	00004517          	auipc	a0,0x4
ffffffffc02022c6:	3b650513          	addi	a0,a0,950 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02022ca:	f55fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02022ce:	00004697          	auipc	a3,0x4
ffffffffc02022d2:	66a68693          	addi	a3,a3,1642 # ffffffffc0206938 <commands+0xe90>
ffffffffc02022d6:	00004617          	auipc	a2,0x4
ffffffffc02022da:	08260613          	addi	a2,a2,130 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02022de:	13000593          	li	a1,304
ffffffffc02022e2:	00004517          	auipc	a0,0x4
ffffffffc02022e6:	39650513          	addi	a0,a0,918 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02022ea:	f35fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02022ee:	00004697          	auipc	a3,0x4
ffffffffc02022f2:	62268693          	addi	a3,a3,1570 # ffffffffc0206910 <commands+0xe68>
ffffffffc02022f6:	00004617          	auipc	a2,0x4
ffffffffc02022fa:	06260613          	addi	a2,a2,98 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02022fe:	12e00593          	li	a1,302
ffffffffc0202302:	00004517          	auipc	a0,0x4
ffffffffc0202306:	37650513          	addi	a0,a0,886 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020230a:	f15fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020230e:	00004697          	auipc	a3,0x4
ffffffffc0202312:	5da68693          	addi	a3,a3,1498 # ffffffffc02068e8 <commands+0xe40>
ffffffffc0202316:	00004617          	auipc	a2,0x4
ffffffffc020231a:	04260613          	addi	a2,a2,66 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020231e:	12d00593          	li	a1,301
ffffffffc0202322:	00004517          	auipc	a0,0x4
ffffffffc0202326:	35650513          	addi	a0,a0,854 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020232a:	ef5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(p0 + 2 == p1);
ffffffffc020232e:	00004697          	auipc	a3,0x4
ffffffffc0202332:	5aa68693          	addi	a3,a3,1450 # ffffffffc02068d8 <commands+0xe30>
ffffffffc0202336:	00004617          	auipc	a2,0x4
ffffffffc020233a:	02260613          	addi	a2,a2,34 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020233e:	12800593          	li	a1,296
ffffffffc0202342:	00004517          	auipc	a0,0x4
ffffffffc0202346:	33650513          	addi	a0,a0,822 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020234a:	ed5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc020234e:	00004697          	auipc	a3,0x4
ffffffffc0202352:	48a68693          	addi	a3,a3,1162 # ffffffffc02067d8 <commands+0xd30>
ffffffffc0202356:	00004617          	auipc	a2,0x4
ffffffffc020235a:	00260613          	addi	a2,a2,2 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020235e:	12700593          	li	a1,295
ffffffffc0202362:	00004517          	auipc	a0,0x4
ffffffffc0202366:	31650513          	addi	a0,a0,790 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020236a:	eb5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020236e:	00004697          	auipc	a3,0x4
ffffffffc0202372:	54a68693          	addi	a3,a3,1354 # ffffffffc02068b8 <commands+0xe10>
ffffffffc0202376:	00004617          	auipc	a2,0x4
ffffffffc020237a:	fe260613          	addi	a2,a2,-30 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020237e:	12600593          	li	a1,294
ffffffffc0202382:	00004517          	auipc	a0,0x4
ffffffffc0202386:	2f650513          	addi	a0,a0,758 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020238a:	e95fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020238e:	00004697          	auipc	a3,0x4
ffffffffc0202392:	4fa68693          	addi	a3,a3,1274 # ffffffffc0206888 <commands+0xde0>
ffffffffc0202396:	00004617          	auipc	a2,0x4
ffffffffc020239a:	fc260613          	addi	a2,a2,-62 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020239e:	12500593          	li	a1,293
ffffffffc02023a2:	00004517          	auipc	a0,0x4
ffffffffc02023a6:	2d650513          	addi	a0,a0,726 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02023aa:	e75fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02023ae:	00004697          	auipc	a3,0x4
ffffffffc02023b2:	4c268693          	addi	a3,a3,1218 # ffffffffc0206870 <commands+0xdc8>
ffffffffc02023b6:	00004617          	auipc	a2,0x4
ffffffffc02023ba:	fa260613          	addi	a2,a2,-94 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02023be:	12400593          	li	a1,292
ffffffffc02023c2:	00004517          	auipc	a0,0x4
ffffffffc02023c6:	2b650513          	addi	a0,a0,694 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02023ca:	e55fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023ce:	00004697          	auipc	a3,0x4
ffffffffc02023d2:	40a68693          	addi	a3,a3,1034 # ffffffffc02067d8 <commands+0xd30>
ffffffffc02023d6:	00004617          	auipc	a2,0x4
ffffffffc02023da:	f8260613          	addi	a2,a2,-126 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02023de:	11e00593          	li	a1,286
ffffffffc02023e2:	00004517          	auipc	a0,0x4
ffffffffc02023e6:	29650513          	addi	a0,a0,662 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02023ea:	e35fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(!PageProperty(p0));
ffffffffc02023ee:	00004697          	auipc	a3,0x4
ffffffffc02023f2:	46a68693          	addi	a3,a3,1130 # ffffffffc0206858 <commands+0xdb0>
ffffffffc02023f6:	00004617          	auipc	a2,0x4
ffffffffc02023fa:	f6260613          	addi	a2,a2,-158 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02023fe:	11900593          	li	a1,281
ffffffffc0202402:	00004517          	auipc	a0,0x4
ffffffffc0202406:	27650513          	addi	a0,a0,630 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020240a:	e15fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020240e:	00004697          	auipc	a3,0x4
ffffffffc0202412:	56a68693          	addi	a3,a3,1386 # ffffffffc0206978 <commands+0xed0>
ffffffffc0202416:	00004617          	auipc	a2,0x4
ffffffffc020241a:	f4260613          	addi	a2,a2,-190 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020241e:	13700593          	li	a1,311
ffffffffc0202422:	00004517          	auipc	a0,0x4
ffffffffc0202426:	25650513          	addi	a0,a0,598 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020242a:	df5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(total == 0);
ffffffffc020242e:	00004697          	auipc	a3,0x4
ffffffffc0202432:	57a68693          	addi	a3,a3,1402 # ffffffffc02069a8 <commands+0xf00>
ffffffffc0202436:	00004617          	auipc	a2,0x4
ffffffffc020243a:	f2260613          	addi	a2,a2,-222 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020243e:	14700593          	li	a1,327
ffffffffc0202442:	00004517          	auipc	a0,0x4
ffffffffc0202446:	23650513          	addi	a0,a0,566 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020244a:	dd5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(total == nr_free_pages());
ffffffffc020244e:	00004697          	auipc	a3,0x4
ffffffffc0202452:	24268693          	addi	a3,a3,578 # ffffffffc0206690 <commands+0xbe8>
ffffffffc0202456:	00004617          	auipc	a2,0x4
ffffffffc020245a:	f0260613          	addi	a2,a2,-254 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020245e:	11300593          	li	a1,275
ffffffffc0202462:	00004517          	auipc	a0,0x4
ffffffffc0202466:	21650513          	addi	a0,a0,534 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020246a:	db5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020246e:	00004697          	auipc	a3,0x4
ffffffffc0202472:	26268693          	addi	a3,a3,610 # ffffffffc02066d0 <commands+0xc28>
ffffffffc0202476:	00004617          	auipc	a2,0x4
ffffffffc020247a:	ee260613          	addi	a2,a2,-286 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020247e:	0d800593          	li	a1,216
ffffffffc0202482:	00004517          	auipc	a0,0x4
ffffffffc0202486:	1f650513          	addi	a0,a0,502 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020248a:	d95fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020248e <default_free_pages>:
{
ffffffffc020248e:	1141                	addi	sp,sp,-16
ffffffffc0202490:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202492:	14058463          	beqz	a1,ffffffffc02025da <default_free_pages+0x14c>
    for (; p != base + n; p++)
ffffffffc0202496:	00659693          	slli	a3,a1,0x6
ffffffffc020249a:	96aa                	add	a3,a3,a0
ffffffffc020249c:	87aa                	mv	a5,a0
ffffffffc020249e:	02d50263          	beq	a0,a3,ffffffffc02024c2 <default_free_pages+0x34>
ffffffffc02024a2:	6798                	ld	a4,8(a5)
ffffffffc02024a4:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02024a6:	10071a63          	bnez	a4,ffffffffc02025ba <default_free_pages+0x12c>
ffffffffc02024aa:	6798                	ld	a4,8(a5)
ffffffffc02024ac:	8b09                	andi	a4,a4,2
ffffffffc02024ae:	10071663          	bnez	a4,ffffffffc02025ba <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02024b2:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02024b6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02024ba:	04078793          	addi	a5,a5,64
ffffffffc02024be:	fed792e3          	bne	a5,a3,ffffffffc02024a2 <default_free_pages+0x14>
    base->property = n;
ffffffffc02024c2:	2581                	sext.w	a1,a1
ffffffffc02024c4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02024c6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024ca:	4789                	li	a5,2
ffffffffc02024cc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02024d0:	000af697          	auipc	a3,0xaf
ffffffffc02024d4:	bd068693          	addi	a3,a3,-1072 # ffffffffc02b10a0 <free_area>
ffffffffc02024d8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02024da:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02024dc:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02024e0:	9db9                	addw	a1,a1,a4
ffffffffc02024e2:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02024e4:	0ad78463          	beq	a5,a3,ffffffffc020258c <default_free_pages+0xfe>
            struct Page *page = le2page(le, page_link);
ffffffffc02024e8:	fe878713          	addi	a4,a5,-24
ffffffffc02024ec:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc02024f0:	4581                	li	a1,0
            if (base < page)
ffffffffc02024f2:	00e56a63          	bltu	a0,a4,ffffffffc0202506 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02024f6:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02024f8:	04d70c63          	beq	a4,a3,ffffffffc0202550 <default_free_pages+0xc2>
    for (; p != base + n; p++)
ffffffffc02024fc:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02024fe:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0202502:	fee57ae3          	bgeu	a0,a4,ffffffffc02024f6 <default_free_pages+0x68>
ffffffffc0202506:	c199                	beqz	a1,ffffffffc020250c <default_free_pages+0x7e>
ffffffffc0202508:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020250c:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020250e:	e390                	sd	a2,0(a5)
ffffffffc0202510:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202512:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202514:	ed18                	sd	a4,24(a0)
    if (le != &free_list)
ffffffffc0202516:	00d70d63          	beq	a4,a3,ffffffffc0202530 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020251a:	ff872583          	lw	a1,-8(a4) # ff8 <_binary_obj___user_faultread_out_size-0x8bd0>
        p = le2page(le, page_link);
ffffffffc020251e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0202522:	02059813          	slli	a6,a1,0x20
ffffffffc0202526:	01a85793          	srli	a5,a6,0x1a
ffffffffc020252a:	97b2                	add	a5,a5,a2
ffffffffc020252c:	02f50c63          	beq	a0,a5,ffffffffc0202564 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202530:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0202532:	00d78c63          	beq	a5,a3,ffffffffc020254a <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0202536:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202538:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020253c:	02061593          	slli	a1,a2,0x20
ffffffffc0202540:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202544:	972a                	add	a4,a4,a0
ffffffffc0202546:	04e68a63          	beq	a3,a4,ffffffffc020259a <default_free_pages+0x10c>
}
ffffffffc020254a:	60a2                	ld	ra,8(sp)
ffffffffc020254c:	0141                	addi	sp,sp,16
ffffffffc020254e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202550:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202552:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202554:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202556:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc0202558:	02d70763          	beq	a4,a3,ffffffffc0202586 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020255c:	8832                	mv	a6,a2
ffffffffc020255e:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0202560:	87ba                	mv	a5,a4
ffffffffc0202562:	bf71                	j	ffffffffc02024fe <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202564:	491c                	lw	a5,16(a0)
ffffffffc0202566:	9dbd                	addw	a1,a1,a5
ffffffffc0202568:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020256c:	57f5                	li	a5,-3
ffffffffc020256e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202572:	01853803          	ld	a6,24(a0)
ffffffffc0202576:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0202578:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020257a:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020257e:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0202580:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc0202584:	b77d                	j	ffffffffc0202532 <default_free_pages+0xa4>
ffffffffc0202586:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list)
ffffffffc0202588:	873e                	mv	a4,a5
ffffffffc020258a:	bf41                	j	ffffffffc020251a <default_free_pages+0x8c>
}
ffffffffc020258c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020258e:	e390                	sd	a2,0(a5)
ffffffffc0202590:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202592:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202594:	ed1c                	sd	a5,24(a0)
ffffffffc0202596:	0141                	addi	sp,sp,16
ffffffffc0202598:	8082                	ret
            base->property += p->property;
ffffffffc020259a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020259e:	ff078693          	addi	a3,a5,-16
ffffffffc02025a2:	9e39                	addw	a2,a2,a4
ffffffffc02025a4:	c910                	sw	a2,16(a0)
ffffffffc02025a6:	5775                	li	a4,-3
ffffffffc02025a8:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02025ac:	6398                	ld	a4,0(a5)
ffffffffc02025ae:	679c                	ld	a5,8(a5)
}
ffffffffc02025b0:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02025b2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025b4:	e398                	sd	a4,0(a5)
ffffffffc02025b6:	0141                	addi	sp,sp,16
ffffffffc02025b8:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02025ba:	00004697          	auipc	a3,0x4
ffffffffc02025be:	40668693          	addi	a3,a3,1030 # ffffffffc02069c0 <commands+0xf18>
ffffffffc02025c2:	00004617          	auipc	a2,0x4
ffffffffc02025c6:	d9660613          	addi	a2,a2,-618 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02025ca:	09400593          	li	a1,148
ffffffffc02025ce:	00004517          	auipc	a0,0x4
ffffffffc02025d2:	0aa50513          	addi	a0,a0,170 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02025d6:	c49fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(n > 0);
ffffffffc02025da:	00004697          	auipc	a3,0x4
ffffffffc02025de:	3de68693          	addi	a3,a3,990 # ffffffffc02069b8 <commands+0xf10>
ffffffffc02025e2:	00004617          	auipc	a2,0x4
ffffffffc02025e6:	d7660613          	addi	a2,a2,-650 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02025ea:	09000593          	li	a1,144
ffffffffc02025ee:	00004517          	auipc	a0,0x4
ffffffffc02025f2:	08a50513          	addi	a0,a0,138 # ffffffffc0206678 <commands+0xbd0>
ffffffffc02025f6:	c29fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02025fa <default_alloc_pages>:
    assert(n > 0);
ffffffffc02025fa:	c941                	beqz	a0,ffffffffc020268a <default_alloc_pages+0x90>
    if (n > nr_free)
ffffffffc02025fc:	000af597          	auipc	a1,0xaf
ffffffffc0202600:	aa458593          	addi	a1,a1,-1372 # ffffffffc02b10a0 <free_area>
ffffffffc0202604:	0105a803          	lw	a6,16(a1)
ffffffffc0202608:	872a                	mv	a4,a0
ffffffffc020260a:	02081793          	slli	a5,a6,0x20
ffffffffc020260e:	9381                	srli	a5,a5,0x20
ffffffffc0202610:	00a7ee63          	bltu	a5,a0,ffffffffc020262c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202614:	87ae                	mv	a5,a1
ffffffffc0202616:	a801                	j	ffffffffc0202626 <default_alloc_pages+0x2c>
        if (p->property >= n)
ffffffffc0202618:	ff87a683          	lw	a3,-8(a5)
ffffffffc020261c:	02069613          	slli	a2,a3,0x20
ffffffffc0202620:	9201                	srli	a2,a2,0x20
ffffffffc0202622:	00e67763          	bgeu	a2,a4,ffffffffc0202630 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202626:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc0202628:	feb798e3          	bne	a5,a1,ffffffffc0202618 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020262c:	4501                	li	a0,0
}
ffffffffc020262e:	8082                	ret
    return listelm->prev;
ffffffffc0202630:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202634:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202638:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020263c:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0202640:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202644:	01133023          	sd	a7,0(t1)
        if (page->property > n)
ffffffffc0202648:	02c77863          	bgeu	a4,a2,ffffffffc0202678 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020264c:	071a                	slli	a4,a4,0x6
ffffffffc020264e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0202650:	41c686bb          	subw	a3,a3,t3
ffffffffc0202654:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202656:	00870613          	addi	a2,a4,8
ffffffffc020265a:	4689                	li	a3,2
ffffffffc020265c:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202660:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202664:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0202668:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020266c:	e290                	sd	a2,0(a3)
ffffffffc020266e:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202672:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0202674:	01173c23          	sd	a7,24(a4)
ffffffffc0202678:	41c8083b          	subw	a6,a6,t3
ffffffffc020267c:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202680:	5775                	li	a4,-3
ffffffffc0202682:	17c1                	addi	a5,a5,-16
ffffffffc0202684:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202688:	8082                	ret
{
ffffffffc020268a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020268c:	00004697          	auipc	a3,0x4
ffffffffc0202690:	32c68693          	addi	a3,a3,812 # ffffffffc02069b8 <commands+0xf10>
ffffffffc0202694:	00004617          	auipc	a2,0x4
ffffffffc0202698:	cc460613          	addi	a2,a2,-828 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020269c:	06c00593          	li	a1,108
ffffffffc02026a0:	00004517          	auipc	a0,0x4
ffffffffc02026a4:	fd850513          	addi	a0,a0,-40 # ffffffffc0206678 <commands+0xbd0>
{
ffffffffc02026a8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026aa:	b75fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02026ae <default_init_memmap>:
{
ffffffffc02026ae:	1141                	addi	sp,sp,-16
ffffffffc02026b0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026b2:	c5f1                	beqz	a1,ffffffffc020277e <default_init_memmap+0xd0>
    for (; p != base + n; p++)
ffffffffc02026b4:	00659693          	slli	a3,a1,0x6
ffffffffc02026b8:	96aa                	add	a3,a3,a0
ffffffffc02026ba:	87aa                	mv	a5,a0
ffffffffc02026bc:	00d50f63          	beq	a0,a3,ffffffffc02026da <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02026c0:	6798                	ld	a4,8(a5)
ffffffffc02026c2:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02026c4:	cf49                	beqz	a4,ffffffffc020275e <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02026c6:	0007a823          	sw	zero,16(a5)
ffffffffc02026ca:	0007b423          	sd	zero,8(a5)
ffffffffc02026ce:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02026d2:	04078793          	addi	a5,a5,64
ffffffffc02026d6:	fed795e3          	bne	a5,a3,ffffffffc02026c0 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02026da:	2581                	sext.w	a1,a1
ffffffffc02026dc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02026de:	4789                	li	a5,2
ffffffffc02026e0:	00850713          	addi	a4,a0,8
ffffffffc02026e4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02026e8:	000af697          	auipc	a3,0xaf
ffffffffc02026ec:	9b868693          	addi	a3,a3,-1608 # ffffffffc02b10a0 <free_area>
ffffffffc02026f0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02026f2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02026f4:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02026f8:	9db9                	addw	a1,a1,a4
ffffffffc02026fa:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list))
ffffffffc02026fc:	04d78a63          	beq	a5,a3,ffffffffc0202750 <default_init_memmap+0xa2>
            struct Page *page = le2page(le, page_link);
ffffffffc0202700:	fe878713          	addi	a4,a5,-24
ffffffffc0202704:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list))
ffffffffc0202708:	4581                	li	a1,0
            if (base < page)
ffffffffc020270a:	00e56a63          	bltu	a0,a4,ffffffffc020271e <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020270e:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0202710:	02d70263          	beq	a4,a3,ffffffffc0202734 <default_init_memmap+0x86>
    for (; p != base + n; p++)
ffffffffc0202714:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0202716:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc020271a:	fee57ae3          	bgeu	a0,a4,ffffffffc020270e <default_init_memmap+0x60>
ffffffffc020271e:	c199                	beqz	a1,ffffffffc0202724 <default_init_memmap+0x76>
ffffffffc0202720:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202724:	6398                	ld	a4,0(a5)
}
ffffffffc0202726:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202728:	e390                	sd	a2,0(a5)
ffffffffc020272a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020272c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020272e:	ed18                	sd	a4,24(a0)
ffffffffc0202730:	0141                	addi	sp,sp,16
ffffffffc0202732:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202734:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202736:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202738:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020273a:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list)
ffffffffc020273c:	00d70663          	beq	a4,a3,ffffffffc0202748 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0202740:	8832                	mv	a6,a2
ffffffffc0202742:	4585                	li	a1,1
    for (; p != base + n; p++)
ffffffffc0202744:	87ba                	mv	a5,a4
ffffffffc0202746:	bfc1                	j	ffffffffc0202716 <default_init_memmap+0x68>
}
ffffffffc0202748:	60a2                	ld	ra,8(sp)
ffffffffc020274a:	e290                	sd	a2,0(a3)
ffffffffc020274c:	0141                	addi	sp,sp,16
ffffffffc020274e:	8082                	ret
ffffffffc0202750:	60a2                	ld	ra,8(sp)
ffffffffc0202752:	e390                	sd	a2,0(a5)
ffffffffc0202754:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202756:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202758:	ed1c                	sd	a5,24(a0)
ffffffffc020275a:	0141                	addi	sp,sp,16
ffffffffc020275c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020275e:	00004697          	auipc	a3,0x4
ffffffffc0202762:	28a68693          	addi	a3,a3,650 # ffffffffc02069e8 <commands+0xf40>
ffffffffc0202766:	00004617          	auipc	a2,0x4
ffffffffc020276a:	bf260613          	addi	a2,a2,-1038 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020276e:	04b00593          	li	a1,75
ffffffffc0202772:	00004517          	auipc	a0,0x4
ffffffffc0202776:	f0650513          	addi	a0,a0,-250 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020277a:	aa5fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(n > 0);
ffffffffc020277e:	00004697          	auipc	a3,0x4
ffffffffc0202782:	23a68693          	addi	a3,a3,570 # ffffffffc02069b8 <commands+0xf10>
ffffffffc0202786:	00004617          	auipc	a2,0x4
ffffffffc020278a:	bd260613          	addi	a2,a2,-1070 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020278e:	04700593          	li	a1,71
ffffffffc0202792:	00004517          	auipc	a0,0x4
ffffffffc0202796:	ee650513          	addi	a0,a0,-282 # ffffffffc0206678 <commands+0xbd0>
ffffffffc020279a:	a85fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020279e <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc020279e:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02027a0:	00004617          	auipc	a2,0x4
ffffffffc02027a4:	ad060613          	addi	a2,a2,-1328 # ffffffffc0206270 <commands+0x7c8>
ffffffffc02027a8:	06b00593          	li	a1,107
ffffffffc02027ac:	00004517          	auipc	a0,0x4
ffffffffc02027b0:	ab450513          	addi	a0,a0,-1356 # ffffffffc0206260 <commands+0x7b8>
pa2page(uintptr_t pa)
ffffffffc02027b4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02027b6:	a69fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02027ba <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc02027ba:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02027bc:	00004617          	auipc	a2,0x4
ffffffffc02027c0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206238 <commands+0x790>
ffffffffc02027c4:	08100593          	li	a1,129
ffffffffc02027c8:	00004517          	auipc	a0,0x4
ffffffffc02027cc:	a9850513          	addi	a0,a0,-1384 # ffffffffc0206260 <commands+0x7b8>
pte2page(pte_t pte)
ffffffffc02027d0:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02027d2:	a4dfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02027d6 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027d6:	100027f3          	csrr	a5,sstatus
ffffffffc02027da:	8b89                	andi	a5,a5,2
ffffffffc02027dc:	e799                	bnez	a5,ffffffffc02027ea <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02027de:	000b3797          	auipc	a5,0xb3
ffffffffc02027e2:	9427b783          	ld	a5,-1726(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc02027e6:	6f9c                	ld	a5,24(a5)
ffffffffc02027e8:	8782                	jr	a5
{
ffffffffc02027ea:	1141                	addi	sp,sp,-16
ffffffffc02027ec:	e406                	sd	ra,8(sp)
ffffffffc02027ee:	e022                	sd	s0,0(sp)
ffffffffc02027f0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02027f2:	9c8fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02027f6:	000b3797          	auipc	a5,0xb3
ffffffffc02027fa:	92a7b783          	ld	a5,-1750(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc02027fe:	6f9c                	ld	a5,24(a5)
ffffffffc0202800:	8522                	mv	a0,s0
ffffffffc0202802:	9782                	jalr	a5
ffffffffc0202804:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202806:	9aefe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020280a:	60a2                	ld	ra,8(sp)
ffffffffc020280c:	8522                	mv	a0,s0
ffffffffc020280e:	6402                	ld	s0,0(sp)
ffffffffc0202810:	0141                	addi	sp,sp,16
ffffffffc0202812:	8082                	ret

ffffffffc0202814 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202814:	100027f3          	csrr	a5,sstatus
ffffffffc0202818:	8b89                	andi	a5,a5,2
ffffffffc020281a:	e799                	bnez	a5,ffffffffc0202828 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020281c:	000b3797          	auipc	a5,0xb3
ffffffffc0202820:	9047b783          	ld	a5,-1788(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202824:	739c                	ld	a5,32(a5)
ffffffffc0202826:	8782                	jr	a5
{
ffffffffc0202828:	1101                	addi	sp,sp,-32
ffffffffc020282a:	ec06                	sd	ra,24(sp)
ffffffffc020282c:	e822                	sd	s0,16(sp)
ffffffffc020282e:	e426                	sd	s1,8(sp)
ffffffffc0202830:	842a                	mv	s0,a0
ffffffffc0202832:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202834:	986fe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202838:	000b3797          	auipc	a5,0xb3
ffffffffc020283c:	8e87b783          	ld	a5,-1816(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202840:	739c                	ld	a5,32(a5)
ffffffffc0202842:	85a6                	mv	a1,s1
ffffffffc0202844:	8522                	mv	a0,s0
ffffffffc0202846:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202848:	6442                	ld	s0,16(sp)
ffffffffc020284a:	60e2                	ld	ra,24(sp)
ffffffffc020284c:	64a2                	ld	s1,8(sp)
ffffffffc020284e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202850:	964fe06f          	j	ffffffffc02009b4 <intr_enable>

ffffffffc0202854 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202854:	100027f3          	csrr	a5,sstatus
ffffffffc0202858:	8b89                	andi	a5,a5,2
ffffffffc020285a:	e799                	bnez	a5,ffffffffc0202868 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020285c:	000b3797          	auipc	a5,0xb3
ffffffffc0202860:	8c47b783          	ld	a5,-1852(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202864:	779c                	ld	a5,40(a5)
ffffffffc0202866:	8782                	jr	a5
{
ffffffffc0202868:	1141                	addi	sp,sp,-16
ffffffffc020286a:	e406                	sd	ra,8(sp)
ffffffffc020286c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020286e:	94cfe0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202872:	000b3797          	auipc	a5,0xb3
ffffffffc0202876:	8ae7b783          	ld	a5,-1874(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc020287a:	779c                	ld	a5,40(a5)
ffffffffc020287c:	9782                	jalr	a5
ffffffffc020287e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202880:	934fe0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202884:	60a2                	ld	ra,8(sp)
ffffffffc0202886:	8522                	mv	a0,s0
ffffffffc0202888:	6402                	ld	s0,0(sp)
ffffffffc020288a:	0141                	addi	sp,sp,16
ffffffffc020288c:	8082                	ret

ffffffffc020288e <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020288e:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202892:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0202896:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202898:	078e                	slli	a5,a5,0x3
{
ffffffffc020289a:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020289c:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc02028a0:	6094                	ld	a3,0(s1)
{
ffffffffc02028a2:	f04a                	sd	s2,32(sp)
ffffffffc02028a4:	ec4e                	sd	s3,24(sp)
ffffffffc02028a6:	e852                	sd	s4,16(sp)
ffffffffc02028a8:	fc06                	sd	ra,56(sp)
ffffffffc02028aa:	f822                	sd	s0,48(sp)
ffffffffc02028ac:	e456                	sd	s5,8(sp)
ffffffffc02028ae:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc02028b0:	0016f793          	andi	a5,a3,1
{
ffffffffc02028b4:	892e                	mv	s2,a1
ffffffffc02028b6:	8a32                	mv	s4,a2
ffffffffc02028b8:	000b3997          	auipc	s3,0xb3
ffffffffc02028bc:	85898993          	addi	s3,s3,-1960 # ffffffffc02b5110 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc02028c0:	efbd                	bnez	a5,ffffffffc020293e <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02028c2:	14060c63          	beqz	a2,ffffffffc0202a1a <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02028c6:	100027f3          	csrr	a5,sstatus
ffffffffc02028ca:	8b89                	andi	a5,a5,2
ffffffffc02028cc:	14079963          	bnez	a5,ffffffffc0202a1e <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc02028d0:	000b3797          	auipc	a5,0xb3
ffffffffc02028d4:	8507b783          	ld	a5,-1968(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc02028d8:	6f9c                	ld	a5,24(a5)
ffffffffc02028da:	4505                	li	a0,1
ffffffffc02028dc:	9782                	jalr	a5
ffffffffc02028de:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02028e0:	12040d63          	beqz	s0,ffffffffc0202a1a <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02028e4:	000b3b17          	auipc	s6,0xb3
ffffffffc02028e8:	834b0b13          	addi	s6,s6,-1996 # ffffffffc02b5118 <pages>
ffffffffc02028ec:	000b3503          	ld	a0,0(s6)
ffffffffc02028f0:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02028f4:	000b3997          	auipc	s3,0xb3
ffffffffc02028f8:	81c98993          	addi	s3,s3,-2020 # ffffffffc02b5110 <npage>
ffffffffc02028fc:	40a40533          	sub	a0,s0,a0
ffffffffc0202900:	8519                	srai	a0,a0,0x6
ffffffffc0202902:	9556                	add	a0,a0,s5
ffffffffc0202904:	0009b703          	ld	a4,0(s3)
ffffffffc0202908:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc020290c:	4685                	li	a3,1
ffffffffc020290e:	c014                	sw	a3,0(s0)
ffffffffc0202910:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202912:	0532                	slli	a0,a0,0xc
ffffffffc0202914:	16e7f763          	bgeu	a5,a4,ffffffffc0202a82 <get_pte+0x1f4>
ffffffffc0202918:	000b3797          	auipc	a5,0xb3
ffffffffc020291c:	8107b783          	ld	a5,-2032(a5) # ffffffffc02b5128 <va_pa_offset>
ffffffffc0202920:	6605                	lui	a2,0x1
ffffffffc0202922:	4581                	li	a1,0
ffffffffc0202924:	953e                	add	a0,a0,a5
ffffffffc0202926:	2ab020ef          	jal	ra,ffffffffc02053d0 <memset>
    return page - pages + nbase;
ffffffffc020292a:	000b3683          	ld	a3,0(s6)
ffffffffc020292e:	40d406b3          	sub	a3,s0,a3
ffffffffc0202932:	8699                	srai	a3,a3,0x6
ffffffffc0202934:	96d6                	add	a3,a3,s5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202936:	06aa                	slli	a3,a3,0xa
ffffffffc0202938:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020293c:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020293e:	77fd                	lui	a5,0xfffff
ffffffffc0202940:	068a                	slli	a3,a3,0x2
ffffffffc0202942:	0009b703          	ld	a4,0(s3)
ffffffffc0202946:	8efd                	and	a3,a3,a5
ffffffffc0202948:	00c6d793          	srli	a5,a3,0xc
ffffffffc020294c:	10e7ff63          	bgeu	a5,a4,ffffffffc0202a6a <get_pte+0x1dc>
ffffffffc0202950:	000b2a97          	auipc	s5,0xb2
ffffffffc0202954:	7d8a8a93          	addi	s5,s5,2008 # ffffffffc02b5128 <va_pa_offset>
ffffffffc0202958:	000ab403          	ld	s0,0(s5)
ffffffffc020295c:	01595793          	srli	a5,s2,0x15
ffffffffc0202960:	1ff7f793          	andi	a5,a5,511
ffffffffc0202964:	96a2                	add	a3,a3,s0
ffffffffc0202966:	00379413          	slli	s0,a5,0x3
ffffffffc020296a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc020296c:	6014                	ld	a3,0(s0)
ffffffffc020296e:	0016f793          	andi	a5,a3,1
ffffffffc0202972:	ebad                	bnez	a5,ffffffffc02029e4 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202974:	0a0a0363          	beqz	s4,ffffffffc0202a1a <get_pte+0x18c>
ffffffffc0202978:	100027f3          	csrr	a5,sstatus
ffffffffc020297c:	8b89                	andi	a5,a5,2
ffffffffc020297e:	efcd                	bnez	a5,ffffffffc0202a38 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202980:	000b2797          	auipc	a5,0xb2
ffffffffc0202984:	7a07b783          	ld	a5,1952(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202988:	6f9c                	ld	a5,24(a5)
ffffffffc020298a:	4505                	li	a0,1
ffffffffc020298c:	9782                	jalr	a5
ffffffffc020298e:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202990:	c4c9                	beqz	s1,ffffffffc0202a1a <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202992:	000b2b17          	auipc	s6,0xb2
ffffffffc0202996:	786b0b13          	addi	s6,s6,1926 # ffffffffc02b5118 <pages>
ffffffffc020299a:	000b3503          	ld	a0,0(s6)
ffffffffc020299e:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02029a2:	0009b703          	ld	a4,0(s3)
ffffffffc02029a6:	40a48533          	sub	a0,s1,a0
ffffffffc02029aa:	8519                	srai	a0,a0,0x6
ffffffffc02029ac:	9552                	add	a0,a0,s4
ffffffffc02029ae:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02029b2:	4685                	li	a3,1
ffffffffc02029b4:	c094                	sw	a3,0(s1)
ffffffffc02029b6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02029b8:	0532                	slli	a0,a0,0xc
ffffffffc02029ba:	0ee7f163          	bgeu	a5,a4,ffffffffc0202a9c <get_pte+0x20e>
ffffffffc02029be:	000ab783          	ld	a5,0(s5)
ffffffffc02029c2:	6605                	lui	a2,0x1
ffffffffc02029c4:	4581                	li	a1,0
ffffffffc02029c6:	953e                	add	a0,a0,a5
ffffffffc02029c8:	209020ef          	jal	ra,ffffffffc02053d0 <memset>
    return page - pages + nbase;
ffffffffc02029cc:	000b3683          	ld	a3,0(s6)
ffffffffc02029d0:	40d486b3          	sub	a3,s1,a3
ffffffffc02029d4:	8699                	srai	a3,a3,0x6
ffffffffc02029d6:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02029d8:	06aa                	slli	a3,a3,0xa
ffffffffc02029da:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02029de:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02029e0:	0009b703          	ld	a4,0(s3)
ffffffffc02029e4:	068a                	slli	a3,a3,0x2
ffffffffc02029e6:	757d                	lui	a0,0xfffff
ffffffffc02029e8:	8ee9                	and	a3,a3,a0
ffffffffc02029ea:	00c6d793          	srli	a5,a3,0xc
ffffffffc02029ee:	06e7f263          	bgeu	a5,a4,ffffffffc0202a52 <get_pte+0x1c4>
ffffffffc02029f2:	000ab503          	ld	a0,0(s5)
ffffffffc02029f6:	00c95913          	srli	s2,s2,0xc
ffffffffc02029fa:	1ff97913          	andi	s2,s2,511
ffffffffc02029fe:	96aa                	add	a3,a3,a0
ffffffffc0202a00:	00391513          	slli	a0,s2,0x3
ffffffffc0202a04:	9536                	add	a0,a0,a3
}
ffffffffc0202a06:	70e2                	ld	ra,56(sp)
ffffffffc0202a08:	7442                	ld	s0,48(sp)
ffffffffc0202a0a:	74a2                	ld	s1,40(sp)
ffffffffc0202a0c:	7902                	ld	s2,32(sp)
ffffffffc0202a0e:	69e2                	ld	s3,24(sp)
ffffffffc0202a10:	6a42                	ld	s4,16(sp)
ffffffffc0202a12:	6aa2                	ld	s5,8(sp)
ffffffffc0202a14:	6b02                	ld	s6,0(sp)
ffffffffc0202a16:	6121                	addi	sp,sp,64
ffffffffc0202a18:	8082                	ret
            return NULL;
ffffffffc0202a1a:	4501                	li	a0,0
ffffffffc0202a1c:	b7ed                	j	ffffffffc0202a06 <get_pte+0x178>
        intr_disable();
ffffffffc0202a1e:	f9dfd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a22:	000b2797          	auipc	a5,0xb2
ffffffffc0202a26:	6fe7b783          	ld	a5,1790(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202a2a:	6f9c                	ld	a5,24(a5)
ffffffffc0202a2c:	4505                	li	a0,1
ffffffffc0202a2e:	9782                	jalr	a5
ffffffffc0202a30:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202a32:	f83fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202a36:	b56d                	j	ffffffffc02028e0 <get_pte+0x52>
        intr_disable();
ffffffffc0202a38:	f83fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0202a3c:	000b2797          	auipc	a5,0xb2
ffffffffc0202a40:	6e47b783          	ld	a5,1764(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202a44:	6f9c                	ld	a5,24(a5)
ffffffffc0202a46:	4505                	li	a0,1
ffffffffc0202a48:	9782                	jalr	a5
ffffffffc0202a4a:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0202a4c:	f69fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202a50:	b781                	j	ffffffffc0202990 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202a52:	00004617          	auipc	a2,0x4
ffffffffc0202a56:	84e60613          	addi	a2,a2,-1970 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0202a5a:	0fa00593          	li	a1,250
ffffffffc0202a5e:	00004517          	auipc	a0,0x4
ffffffffc0202a62:	fea50513          	addi	a0,a0,-22 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202a66:	fb8fd0ef          	jal	ra,ffffffffc020021e <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202a6a:	00004617          	auipc	a2,0x4
ffffffffc0202a6e:	83660613          	addi	a2,a2,-1994 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0202a72:	0ed00593          	li	a1,237
ffffffffc0202a76:	00004517          	auipc	a0,0x4
ffffffffc0202a7a:	fd250513          	addi	a0,a0,-46 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202a7e:	fa0fd0ef          	jal	ra,ffffffffc020021e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202a82:	86aa                	mv	a3,a0
ffffffffc0202a84:	00004617          	auipc	a2,0x4
ffffffffc0202a88:	81c60613          	addi	a2,a2,-2020 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0202a8c:	0e900593          	li	a1,233
ffffffffc0202a90:	00004517          	auipc	a0,0x4
ffffffffc0202a94:	fb850513          	addi	a0,a0,-72 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202a98:	f86fd0ef          	jal	ra,ffffffffc020021e <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202a9c:	86aa                	mv	a3,a0
ffffffffc0202a9e:	00004617          	auipc	a2,0x4
ffffffffc0202aa2:	80260613          	addi	a2,a2,-2046 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0202aa6:	0f700593          	li	a1,247
ffffffffc0202aaa:	00004517          	auipc	a0,0x4
ffffffffc0202aae:	f9e50513          	addi	a0,a0,-98 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202ab2:	f6cfd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202ab6 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202ab6:	1141                	addi	sp,sp,-16
ffffffffc0202ab8:	e022                	sd	s0,0(sp)
ffffffffc0202aba:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202abc:	4601                	li	a2,0
{
ffffffffc0202abe:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ac0:	dcfff0ef          	jal	ra,ffffffffc020288e <get_pte>
    if (ptep_store != NULL)
ffffffffc0202ac4:	c011                	beqz	s0,ffffffffc0202ac8 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202ac6:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ac8:	c511                	beqz	a0,ffffffffc0202ad4 <get_page+0x1e>
ffffffffc0202aca:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202acc:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ace:	0017f713          	andi	a4,a5,1
ffffffffc0202ad2:	e709                	bnez	a4,ffffffffc0202adc <get_page+0x26>
}
ffffffffc0202ad4:	60a2                	ld	ra,8(sp)
ffffffffc0202ad6:	6402                	ld	s0,0(sp)
ffffffffc0202ad8:	0141                	addi	sp,sp,16
ffffffffc0202ada:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202adc:	078a                	slli	a5,a5,0x2
ffffffffc0202ade:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ae0:	000b2717          	auipc	a4,0xb2
ffffffffc0202ae4:	63073703          	ld	a4,1584(a4) # ffffffffc02b5110 <npage>
ffffffffc0202ae8:	00e7ff63          	bgeu	a5,a4,ffffffffc0202b06 <get_page+0x50>
ffffffffc0202aec:	60a2                	ld	ra,8(sp)
ffffffffc0202aee:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0202af0:	fff80537          	lui	a0,0xfff80
ffffffffc0202af4:	97aa                	add	a5,a5,a0
ffffffffc0202af6:	079a                	slli	a5,a5,0x6
ffffffffc0202af8:	000b2517          	auipc	a0,0xb2
ffffffffc0202afc:	62053503          	ld	a0,1568(a0) # ffffffffc02b5118 <pages>
ffffffffc0202b00:	953e                	add	a0,a0,a5
ffffffffc0202b02:	0141                	addi	sp,sp,16
ffffffffc0202b04:	8082                	ret
ffffffffc0202b06:	c99ff0ef          	jal	ra,ffffffffc020279e <pa2page.part.0>

ffffffffc0202b0a <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202b0a:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b0c:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202b10:	f486                	sd	ra,104(sp)
ffffffffc0202b12:	f0a2                	sd	s0,96(sp)
ffffffffc0202b14:	eca6                	sd	s1,88(sp)
ffffffffc0202b16:	e8ca                	sd	s2,80(sp)
ffffffffc0202b18:	e4ce                	sd	s3,72(sp)
ffffffffc0202b1a:	e0d2                	sd	s4,64(sp)
ffffffffc0202b1c:	fc56                	sd	s5,56(sp)
ffffffffc0202b1e:	f85a                	sd	s6,48(sp)
ffffffffc0202b20:	f45e                	sd	s7,40(sp)
ffffffffc0202b22:	f062                	sd	s8,32(sp)
ffffffffc0202b24:	ec66                	sd	s9,24(sp)
ffffffffc0202b26:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b28:	17d2                	slli	a5,a5,0x34
ffffffffc0202b2a:	e3ed                	bnez	a5,ffffffffc0202c0c <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202b2c:	002007b7          	lui	a5,0x200
ffffffffc0202b30:	842e                	mv	s0,a1
ffffffffc0202b32:	0ef5ed63          	bltu	a1,a5,ffffffffc0202c2c <unmap_range+0x122>
ffffffffc0202b36:	8932                	mv	s2,a2
ffffffffc0202b38:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202c2c <unmap_range+0x122>
ffffffffc0202b3c:	4785                	li	a5,1
ffffffffc0202b3e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202b40:	0ec7e663          	bltu	a5,a2,ffffffffc0202c2c <unmap_range+0x122>
ffffffffc0202b44:	89aa                	mv	s3,a0
        }
        if (*ptep != 0)
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202b46:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage)
ffffffffc0202b48:	000b2c97          	auipc	s9,0xb2
ffffffffc0202b4c:	5c8c8c93          	addi	s9,s9,1480 # ffffffffc02b5110 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b50:	000b2c17          	auipc	s8,0xb2
ffffffffc0202b54:	5c8c0c13          	addi	s8,s8,1480 # ffffffffc02b5118 <pages>
ffffffffc0202b58:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202b5c:	000b2d17          	auipc	s10,0xb2
ffffffffc0202b60:	5c4d0d13          	addi	s10,s10,1476 # ffffffffc02b5120 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202b64:	00200b37          	lui	s6,0x200
ffffffffc0202b68:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202b6c:	4601                	li	a2,0
ffffffffc0202b6e:	85a2                	mv	a1,s0
ffffffffc0202b70:	854e                	mv	a0,s3
ffffffffc0202b72:	d1dff0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc0202b76:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0202b78:	cd29                	beqz	a0,ffffffffc0202bd2 <unmap_range+0xc8>
        if (*ptep != 0)
ffffffffc0202b7a:	611c                	ld	a5,0(a0)
ffffffffc0202b7c:	e395                	bnez	a5,ffffffffc0202ba0 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202b7e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202b80:	ff2466e3          	bltu	s0,s2,ffffffffc0202b6c <unmap_range+0x62>
}
ffffffffc0202b84:	70a6                	ld	ra,104(sp)
ffffffffc0202b86:	7406                	ld	s0,96(sp)
ffffffffc0202b88:	64e6                	ld	s1,88(sp)
ffffffffc0202b8a:	6946                	ld	s2,80(sp)
ffffffffc0202b8c:	69a6                	ld	s3,72(sp)
ffffffffc0202b8e:	6a06                	ld	s4,64(sp)
ffffffffc0202b90:	7ae2                	ld	s5,56(sp)
ffffffffc0202b92:	7b42                	ld	s6,48(sp)
ffffffffc0202b94:	7ba2                	ld	s7,40(sp)
ffffffffc0202b96:	7c02                	ld	s8,32(sp)
ffffffffc0202b98:	6ce2                	ld	s9,24(sp)
ffffffffc0202b9a:	6d42                	ld	s10,16(sp)
ffffffffc0202b9c:	6165                	addi	sp,sp,112
ffffffffc0202b9e:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202ba0:	0017f713          	andi	a4,a5,1
ffffffffc0202ba4:	df69                	beqz	a4,ffffffffc0202b7e <unmap_range+0x74>
    if (PPN(pa) >= npage)
ffffffffc0202ba6:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202baa:	078a                	slli	a5,a5,0x2
ffffffffc0202bac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bae:	08e7ff63          	bgeu	a5,a4,ffffffffc0202c4c <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bb2:	000c3503          	ld	a0,0(s8)
ffffffffc0202bb6:	97de                	add	a5,a5,s7
ffffffffc0202bb8:	079a                	slli	a5,a5,0x6
ffffffffc0202bba:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202bbc:	411c                	lw	a5,0(a0)
ffffffffc0202bbe:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202bc2:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202bc4:	cf11                	beqz	a4,ffffffffc0202be0 <unmap_range+0xd6>
        *ptep = 0;
ffffffffc0202bc6:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202bca:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202bce:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202bd0:	bf45                	j	ffffffffc0202b80 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202bd2:	945a                	add	s0,s0,s6
ffffffffc0202bd4:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202bd8:	d455                	beqz	s0,ffffffffc0202b84 <unmap_range+0x7a>
ffffffffc0202bda:	f92469e3          	bltu	s0,s2,ffffffffc0202b6c <unmap_range+0x62>
ffffffffc0202bde:	b75d                	j	ffffffffc0202b84 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202be0:	100027f3          	csrr	a5,sstatus
ffffffffc0202be4:	8b89                	andi	a5,a5,2
ffffffffc0202be6:	e799                	bnez	a5,ffffffffc0202bf4 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc0202be8:	000d3783          	ld	a5,0(s10)
ffffffffc0202bec:	4585                	li	a1,1
ffffffffc0202bee:	739c                	ld	a5,32(a5)
ffffffffc0202bf0:	9782                	jalr	a5
    if (flag)
ffffffffc0202bf2:	bfd1                	j	ffffffffc0202bc6 <unmap_range+0xbc>
ffffffffc0202bf4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bf6:	dc5fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0202bfa:	000d3783          	ld	a5,0(s10)
ffffffffc0202bfe:	6522                	ld	a0,8(sp)
ffffffffc0202c00:	4585                	li	a1,1
ffffffffc0202c02:	739c                	ld	a5,32(a5)
ffffffffc0202c04:	9782                	jalr	a5
        intr_enable();
ffffffffc0202c06:	daffd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202c0a:	bf75                	j	ffffffffc0202bc6 <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c0c:	00004697          	auipc	a3,0x4
ffffffffc0202c10:	e4c68693          	addi	a3,a3,-436 # ffffffffc0206a58 <default_pmm_manager+0x48>
ffffffffc0202c14:	00003617          	auipc	a2,0x3
ffffffffc0202c18:	74460613          	addi	a2,a2,1860 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0202c1c:	12000593          	li	a1,288
ffffffffc0202c20:	00004517          	auipc	a0,0x4
ffffffffc0202c24:	e2850513          	addi	a0,a0,-472 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202c28:	df6fd0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202c2c:	00004697          	auipc	a3,0x4
ffffffffc0202c30:	e5c68693          	addi	a3,a3,-420 # ffffffffc0206a88 <default_pmm_manager+0x78>
ffffffffc0202c34:	00003617          	auipc	a2,0x3
ffffffffc0202c38:	72460613          	addi	a2,a2,1828 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0202c3c:	12100593          	li	a1,289
ffffffffc0202c40:	00004517          	auipc	a0,0x4
ffffffffc0202c44:	e0850513          	addi	a0,a0,-504 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202c48:	dd6fd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0202c4c:	b53ff0ef          	jal	ra,ffffffffc020279e <pa2page.part.0>

ffffffffc0202c50 <exit_range>:
{
ffffffffc0202c50:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c52:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202c56:	fc86                	sd	ra,120(sp)
ffffffffc0202c58:	f8a2                	sd	s0,112(sp)
ffffffffc0202c5a:	f4a6                	sd	s1,104(sp)
ffffffffc0202c5c:	f0ca                	sd	s2,96(sp)
ffffffffc0202c5e:	ecce                	sd	s3,88(sp)
ffffffffc0202c60:	e8d2                	sd	s4,80(sp)
ffffffffc0202c62:	e4d6                	sd	s5,72(sp)
ffffffffc0202c64:	e0da                	sd	s6,64(sp)
ffffffffc0202c66:	fc5e                	sd	s7,56(sp)
ffffffffc0202c68:	f862                	sd	s8,48(sp)
ffffffffc0202c6a:	f466                	sd	s9,40(sp)
ffffffffc0202c6c:	f06a                	sd	s10,32(sp)
ffffffffc0202c6e:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c70:	17d2                	slli	a5,a5,0x34
ffffffffc0202c72:	20079a63          	bnez	a5,ffffffffc0202e86 <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc0202c76:	002007b7          	lui	a5,0x200
ffffffffc0202c7a:	24f5e463          	bltu	a1,a5,ffffffffc0202ec2 <exit_range+0x272>
ffffffffc0202c7e:	8ab2                	mv	s5,a2
ffffffffc0202c80:	24c5f163          	bgeu	a1,a2,ffffffffc0202ec2 <exit_range+0x272>
ffffffffc0202c84:	4785                	li	a5,1
ffffffffc0202c86:	07fe                	slli	a5,a5,0x1f
ffffffffc0202c88:	22c7ed63          	bltu	a5,a2,ffffffffc0202ec2 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202c8c:	c00009b7          	lui	s3,0xc0000
ffffffffc0202c90:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202c94:	ffe00937          	lui	s2,0xffe00
ffffffffc0202c98:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202c9c:	5cfd                	li	s9,-1
ffffffffc0202c9e:	8c2a                	mv	s8,a0
ffffffffc0202ca0:	0125f933          	and	s2,a1,s2
ffffffffc0202ca4:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage)
ffffffffc0202ca6:	000b2d17          	auipc	s10,0xb2
ffffffffc0202caa:	46ad0d13          	addi	s10,s10,1130 # ffffffffc02b5110 <npage>
    return KADDR(page2pa(page));
ffffffffc0202cae:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202cb2:	000b2717          	auipc	a4,0xb2
ffffffffc0202cb6:	46670713          	addi	a4,a4,1126 # ffffffffc02b5118 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc0202cba:	000b2d97          	auipc	s11,0xb2
ffffffffc0202cbe:	466d8d93          	addi	s11,s11,1126 # ffffffffc02b5120 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202cc2:	c0000437          	lui	s0,0xc0000
ffffffffc0202cc6:	944e                	add	s0,s0,s3
ffffffffc0202cc8:	8079                	srli	s0,s0,0x1e
ffffffffc0202cca:	1ff47413          	andi	s0,s0,511
ffffffffc0202cce:	040e                	slli	s0,s0,0x3
ffffffffc0202cd0:	9462                	add	s0,s0,s8
ffffffffc0202cd2:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ec8>
        if (pde1 & PTE_V)
ffffffffc0202cd6:	001a7793          	andi	a5,s4,1
ffffffffc0202cda:	eb99                	bnez	a5,ffffffffc0202cf0 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0202cdc:	12098463          	beqz	s3,ffffffffc0202e04 <exit_range+0x1b4>
ffffffffc0202ce0:	400007b7          	lui	a5,0x40000
ffffffffc0202ce4:	97ce                	add	a5,a5,s3
ffffffffc0202ce6:	894e                	mv	s2,s3
ffffffffc0202ce8:	1159fe63          	bgeu	s3,s5,ffffffffc0202e04 <exit_range+0x1b4>
ffffffffc0202cec:	89be                	mv	s3,a5
ffffffffc0202cee:	bfd1                	j	ffffffffc0202cc2 <exit_range+0x72>
    if (PPN(pa) >= npage)
ffffffffc0202cf0:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cf4:	0a0a                	slli	s4,s4,0x2
ffffffffc0202cf6:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cfa:	1cfa7263          	bgeu	s4,a5,ffffffffc0202ebe <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cfe:	fff80637          	lui	a2,0xfff80
ffffffffc0202d02:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc0202d04:	000806b7          	lui	a3,0x80
ffffffffc0202d08:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202d0a:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202d0e:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d10:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d12:	18f5fa63          	bgeu	a1,a5,ffffffffc0202ea6 <exit_range+0x256>
ffffffffc0202d16:	000b2817          	auipc	a6,0xb2
ffffffffc0202d1a:	41280813          	addi	a6,a6,1042 # ffffffffc02b5128 <va_pa_offset>
ffffffffc0202d1e:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc0202d22:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202d24:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202d28:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202d2a:	00080337          	lui	t1,0x80
ffffffffc0202d2e:	6885                	lui	a7,0x1
ffffffffc0202d30:	a819                	j	ffffffffc0202d46 <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc0202d32:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc0202d34:	002007b7          	lui	a5,0x200
ffffffffc0202d38:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202d3a:	08090c63          	beqz	s2,ffffffffc0202dd2 <exit_range+0x182>
ffffffffc0202d3e:	09397a63          	bgeu	s2,s3,ffffffffc0202dd2 <exit_range+0x182>
ffffffffc0202d42:	0f597063          	bgeu	s2,s5,ffffffffc0202e22 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202d46:	01595493          	srli	s1,s2,0x15
ffffffffc0202d4a:	1ff4f493          	andi	s1,s1,511
ffffffffc0202d4e:	048e                	slli	s1,s1,0x3
ffffffffc0202d50:	94da                	add	s1,s1,s6
ffffffffc0202d52:	609c                	ld	a5,0(s1)
                if (pde0 & PTE_V)
ffffffffc0202d54:	0017f693          	andi	a3,a5,1
ffffffffc0202d58:	dee9                	beqz	a3,ffffffffc0202d32 <exit_range+0xe2>
    if (PPN(pa) >= npage)
ffffffffc0202d5a:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d5e:	078a                	slli	a5,a5,0x2
ffffffffc0202d60:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d62:	14b7fe63          	bgeu	a5,a1,ffffffffc0202ebe <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d66:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202d68:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202d6c:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202d70:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d76:	12bef863          	bgeu	t4,a1,ffffffffc0202ea6 <exit_range+0x256>
ffffffffc0202d7a:	00083783          	ld	a5,0(a6)
ffffffffc0202d7e:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202d80:	011685b3          	add	a1,a3,a7
                        if (pt[i] & PTE_V)
ffffffffc0202d84:	629c                	ld	a5,0(a3)
ffffffffc0202d86:	8b85                	andi	a5,a5,1
ffffffffc0202d88:	f7d5                	bnez	a5,ffffffffc0202d34 <exit_range+0xe4>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202d8a:	06a1                	addi	a3,a3,8
ffffffffc0202d8c:	fed59ce3          	bne	a1,a3,ffffffffc0202d84 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d90:	631c                	ld	a5,0(a4)
ffffffffc0202d92:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202d94:	100027f3          	csrr	a5,sstatus
ffffffffc0202d98:	8b89                	andi	a5,a5,2
ffffffffc0202d9a:	e7d9                	bnez	a5,ffffffffc0202e28 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202d9c:	000db783          	ld	a5,0(s11)
ffffffffc0202da0:	4585                	li	a1,1
ffffffffc0202da2:	e032                	sd	a2,0(sp)
ffffffffc0202da4:	739c                	ld	a5,32(a5)
ffffffffc0202da6:	9782                	jalr	a5
    if (flag)
ffffffffc0202da8:	6602                	ld	a2,0(sp)
ffffffffc0202daa:	000b2817          	auipc	a6,0xb2
ffffffffc0202dae:	37e80813          	addi	a6,a6,894 # ffffffffc02b5128 <va_pa_offset>
ffffffffc0202db2:	fff80e37          	lui	t3,0xfff80
ffffffffc0202db6:	00080337          	lui	t1,0x80
ffffffffc0202dba:	6885                	lui	a7,0x1
ffffffffc0202dbc:	000b2717          	auipc	a4,0xb2
ffffffffc0202dc0:	35c70713          	addi	a4,a4,860 # ffffffffc02b5118 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202dc4:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc0202dc8:	002007b7          	lui	a5,0x200
ffffffffc0202dcc:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202dce:	f60918e3          	bnez	s2,ffffffffc0202d3e <exit_range+0xee>
            if (free_pd0)
ffffffffc0202dd2:	f00b85e3          	beqz	s7,ffffffffc0202cdc <exit_range+0x8c>
    if (PPN(pa) >= npage)
ffffffffc0202dd6:	000d3783          	ld	a5,0(s10)
ffffffffc0202dda:	0efa7263          	bgeu	s4,a5,ffffffffc0202ebe <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dde:	6308                	ld	a0,0(a4)
ffffffffc0202de0:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202de2:	100027f3          	csrr	a5,sstatus
ffffffffc0202de6:	8b89                	andi	a5,a5,2
ffffffffc0202de8:	efad                	bnez	a5,ffffffffc0202e62 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc0202dea:	000db783          	ld	a5,0(s11)
ffffffffc0202dee:	4585                	li	a1,1
ffffffffc0202df0:	739c                	ld	a5,32(a5)
ffffffffc0202df2:	9782                	jalr	a5
ffffffffc0202df4:	000b2717          	auipc	a4,0xb2
ffffffffc0202df8:	32470713          	addi	a4,a4,804 # ffffffffc02b5118 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202dfc:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202e00:	ee0990e3          	bnez	s3,ffffffffc0202ce0 <exit_range+0x90>
}
ffffffffc0202e04:	70e6                	ld	ra,120(sp)
ffffffffc0202e06:	7446                	ld	s0,112(sp)
ffffffffc0202e08:	74a6                	ld	s1,104(sp)
ffffffffc0202e0a:	7906                	ld	s2,96(sp)
ffffffffc0202e0c:	69e6                	ld	s3,88(sp)
ffffffffc0202e0e:	6a46                	ld	s4,80(sp)
ffffffffc0202e10:	6aa6                	ld	s5,72(sp)
ffffffffc0202e12:	6b06                	ld	s6,64(sp)
ffffffffc0202e14:	7be2                	ld	s7,56(sp)
ffffffffc0202e16:	7c42                	ld	s8,48(sp)
ffffffffc0202e18:	7ca2                	ld	s9,40(sp)
ffffffffc0202e1a:	7d02                	ld	s10,32(sp)
ffffffffc0202e1c:	6de2                	ld	s11,24(sp)
ffffffffc0202e1e:	6109                	addi	sp,sp,128
ffffffffc0202e20:	8082                	ret
            if (free_pd0)
ffffffffc0202e22:	ea0b8fe3          	beqz	s7,ffffffffc0202ce0 <exit_range+0x90>
ffffffffc0202e26:	bf45                	j	ffffffffc0202dd6 <exit_range+0x186>
ffffffffc0202e28:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202e2a:	e42a                	sd	a0,8(sp)
ffffffffc0202e2c:	b8ffd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e30:	000db783          	ld	a5,0(s11)
ffffffffc0202e34:	6522                	ld	a0,8(sp)
ffffffffc0202e36:	4585                	li	a1,1
ffffffffc0202e38:	739c                	ld	a5,32(a5)
ffffffffc0202e3a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e3c:	b79fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202e40:	6602                	ld	a2,0(sp)
ffffffffc0202e42:	000b2717          	auipc	a4,0xb2
ffffffffc0202e46:	2d670713          	addi	a4,a4,726 # ffffffffc02b5118 <pages>
ffffffffc0202e4a:	6885                	lui	a7,0x1
ffffffffc0202e4c:	00080337          	lui	t1,0x80
ffffffffc0202e50:	fff80e37          	lui	t3,0xfff80
ffffffffc0202e54:	000b2817          	auipc	a6,0xb2
ffffffffc0202e58:	2d480813          	addi	a6,a6,724 # ffffffffc02b5128 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202e5c:	0004b023          	sd	zero,0(s1)
ffffffffc0202e60:	b7a5                	j	ffffffffc0202dc8 <exit_range+0x178>
ffffffffc0202e62:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202e64:	b57fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e68:	000db783          	ld	a5,0(s11)
ffffffffc0202e6c:	6502                	ld	a0,0(sp)
ffffffffc0202e6e:	4585                	li	a1,1
ffffffffc0202e70:	739c                	ld	a5,32(a5)
ffffffffc0202e72:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e74:	b41fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202e78:	000b2717          	auipc	a4,0xb2
ffffffffc0202e7c:	2a070713          	addi	a4,a4,672 # ffffffffc02b5118 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202e80:	00043023          	sd	zero,0(s0)
ffffffffc0202e84:	bfb5                	j	ffffffffc0202e00 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202e86:	00004697          	auipc	a3,0x4
ffffffffc0202e8a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0206a58 <default_pmm_manager+0x48>
ffffffffc0202e8e:	00003617          	auipc	a2,0x3
ffffffffc0202e92:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0202e96:	13500593          	li	a1,309
ffffffffc0202e9a:	00004517          	auipc	a0,0x4
ffffffffc0202e9e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202ea2:	b7cfd0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0202ea6:	00003617          	auipc	a2,0x3
ffffffffc0202eaa:	3fa60613          	addi	a2,a2,1018 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0202eae:	07300593          	li	a1,115
ffffffffc0202eb2:	00003517          	auipc	a0,0x3
ffffffffc0202eb6:	3ae50513          	addi	a0,a0,942 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0202eba:	b64fd0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0202ebe:	8e1ff0ef          	jal	ra,ffffffffc020279e <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202ec2:	00004697          	auipc	a3,0x4
ffffffffc0202ec6:	bc668693          	addi	a3,a3,-1082 # ffffffffc0206a88 <default_pmm_manager+0x78>
ffffffffc0202eca:	00003617          	auipc	a2,0x3
ffffffffc0202ece:	48e60613          	addi	a2,a2,1166 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0202ed2:	13600593          	li	a1,310
ffffffffc0202ed6:	00004517          	auipc	a0,0x4
ffffffffc0202eda:	b7250513          	addi	a0,a0,-1166 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0202ede:	b40fd0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0202ee2 <page_remove>:
{
ffffffffc0202ee2:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ee4:	4601                	li	a2,0
{
ffffffffc0202ee6:	ec26                	sd	s1,24(sp)
ffffffffc0202ee8:	f406                	sd	ra,40(sp)
ffffffffc0202eea:	f022                	sd	s0,32(sp)
ffffffffc0202eec:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202eee:	9a1ff0ef          	jal	ra,ffffffffc020288e <get_pte>
    if (ptep != NULL)
ffffffffc0202ef2:	c511                	beqz	a0,ffffffffc0202efe <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202ef4:	611c                	ld	a5,0(a0)
ffffffffc0202ef6:	842a                	mv	s0,a0
ffffffffc0202ef8:	0017f713          	andi	a4,a5,1
ffffffffc0202efc:	e711                	bnez	a4,ffffffffc0202f08 <page_remove+0x26>
}
ffffffffc0202efe:	70a2                	ld	ra,40(sp)
ffffffffc0202f00:	7402                	ld	s0,32(sp)
ffffffffc0202f02:	64e2                	ld	s1,24(sp)
ffffffffc0202f04:	6145                	addi	sp,sp,48
ffffffffc0202f06:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202f08:	078a                	slli	a5,a5,0x2
ffffffffc0202f0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202f0c:	000b2717          	auipc	a4,0xb2
ffffffffc0202f10:	20473703          	ld	a4,516(a4) # ffffffffc02b5110 <npage>
ffffffffc0202f14:	06e7f363          	bgeu	a5,a4,ffffffffc0202f7a <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f18:	fff80537          	lui	a0,0xfff80
ffffffffc0202f1c:	97aa                	add	a5,a5,a0
ffffffffc0202f1e:	079a                	slli	a5,a5,0x6
ffffffffc0202f20:	000b2517          	auipc	a0,0xb2
ffffffffc0202f24:	1f853503          	ld	a0,504(a0) # ffffffffc02b5118 <pages>
ffffffffc0202f28:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202f2a:	411c                	lw	a5,0(a0)
ffffffffc0202f2c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f30:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202f32:	cb11                	beqz	a4,ffffffffc0202f46 <page_remove+0x64>
        *ptep = 0;
ffffffffc0202f34:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202f38:	12048073          	sfence.vma	s1
}
ffffffffc0202f3c:	70a2                	ld	ra,40(sp)
ffffffffc0202f3e:	7402                	ld	s0,32(sp)
ffffffffc0202f40:	64e2                	ld	s1,24(sp)
ffffffffc0202f42:	6145                	addi	sp,sp,48
ffffffffc0202f44:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202f46:	100027f3          	csrr	a5,sstatus
ffffffffc0202f4a:	8b89                	andi	a5,a5,2
ffffffffc0202f4c:	eb89                	bnez	a5,ffffffffc0202f5e <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202f4e:	000b2797          	auipc	a5,0xb2
ffffffffc0202f52:	1d27b783          	ld	a5,466(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202f56:	739c                	ld	a5,32(a5)
ffffffffc0202f58:	4585                	li	a1,1
ffffffffc0202f5a:	9782                	jalr	a5
    if (flag)
ffffffffc0202f5c:	bfe1                	j	ffffffffc0202f34 <page_remove+0x52>
        intr_disable();
ffffffffc0202f5e:	e42a                	sd	a0,8(sp)
ffffffffc0202f60:	a5bfd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0202f64:	000b2797          	auipc	a5,0xb2
ffffffffc0202f68:	1bc7b783          	ld	a5,444(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0202f6c:	739c                	ld	a5,32(a5)
ffffffffc0202f6e:	6522                	ld	a0,8(sp)
ffffffffc0202f70:	4585                	li	a1,1
ffffffffc0202f72:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f74:	a41fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0202f78:	bf75                	j	ffffffffc0202f34 <page_remove+0x52>
ffffffffc0202f7a:	825ff0ef          	jal	ra,ffffffffc020279e <pa2page.part.0>

ffffffffc0202f7e <page_insert>:
{
ffffffffc0202f7e:	7139                	addi	sp,sp,-64
ffffffffc0202f80:	e852                	sd	s4,16(sp)
ffffffffc0202f82:	8a32                	mv	s4,a2
ffffffffc0202f84:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f86:	4605                	li	a2,1
{
ffffffffc0202f88:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f8a:	85d2                	mv	a1,s4
{
ffffffffc0202f8c:	f426                	sd	s1,40(sp)
ffffffffc0202f8e:	fc06                	sd	ra,56(sp)
ffffffffc0202f90:	f04a                	sd	s2,32(sp)
ffffffffc0202f92:	ec4e                	sd	s3,24(sp)
ffffffffc0202f94:	e456                	sd	s5,8(sp)
ffffffffc0202f96:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f98:	8f7ff0ef          	jal	ra,ffffffffc020288e <get_pte>
    if (ptep == NULL)
ffffffffc0202f9c:	c961                	beqz	a0,ffffffffc020306c <page_insert+0xee>
    page->ref += 1;
ffffffffc0202f9e:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202fa0:	611c                	ld	a5,0(a0)
ffffffffc0202fa2:	89aa                	mv	s3,a0
ffffffffc0202fa4:	0016871b          	addiw	a4,a3,1
ffffffffc0202fa8:	c018                	sw	a4,0(s0)
ffffffffc0202faa:	0017f713          	andi	a4,a5,1
ffffffffc0202fae:	ef05                	bnez	a4,ffffffffc0202fe6 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202fb0:	000b2717          	auipc	a4,0xb2
ffffffffc0202fb4:	16873703          	ld	a4,360(a4) # ffffffffc02b5118 <pages>
ffffffffc0202fb8:	8c19                	sub	s0,s0,a4
ffffffffc0202fba:	000807b7          	lui	a5,0x80
ffffffffc0202fbe:	8419                	srai	s0,s0,0x6
ffffffffc0202fc0:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202fc2:	042a                	slli	s0,s0,0xa
ffffffffc0202fc4:	8cc1                	or	s1,s1,s0
ffffffffc0202fc6:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202fca:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ec8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202fce:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202fd2:	4501                	li	a0,0
}
ffffffffc0202fd4:	70e2                	ld	ra,56(sp)
ffffffffc0202fd6:	7442                	ld	s0,48(sp)
ffffffffc0202fd8:	74a2                	ld	s1,40(sp)
ffffffffc0202fda:	7902                	ld	s2,32(sp)
ffffffffc0202fdc:	69e2                	ld	s3,24(sp)
ffffffffc0202fde:	6a42                	ld	s4,16(sp)
ffffffffc0202fe0:	6aa2                	ld	s5,8(sp)
ffffffffc0202fe2:	6121                	addi	sp,sp,64
ffffffffc0202fe4:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202fe6:	078a                	slli	a5,a5,0x2
ffffffffc0202fe8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202fea:	000b2717          	auipc	a4,0xb2
ffffffffc0202fee:	12673703          	ld	a4,294(a4) # ffffffffc02b5110 <npage>
ffffffffc0202ff2:	06e7ff63          	bgeu	a5,a4,ffffffffc0203070 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ff6:	000b2a97          	auipc	s5,0xb2
ffffffffc0202ffa:	122a8a93          	addi	s5,s5,290 # ffffffffc02b5118 <pages>
ffffffffc0202ffe:	000ab703          	ld	a4,0(s5)
ffffffffc0203002:	fff80937          	lui	s2,0xfff80
ffffffffc0203006:	993e                	add	s2,s2,a5
ffffffffc0203008:	091a                	slli	s2,s2,0x6
ffffffffc020300a:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc020300c:	01240c63          	beq	s0,s2,ffffffffc0203024 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203010:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccaeb4>
ffffffffc0203014:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203018:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc020301c:	c691                	beqz	a3,ffffffffc0203028 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020301e:	120a0073          	sfence.vma	s4
}
ffffffffc0203022:	bf59                	j	ffffffffc0202fb8 <page_insert+0x3a>
ffffffffc0203024:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203026:	bf49                	j	ffffffffc0202fb8 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203028:	100027f3          	csrr	a5,sstatus
ffffffffc020302c:	8b89                	andi	a5,a5,2
ffffffffc020302e:	ef91                	bnez	a5,ffffffffc020304a <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203030:	000b2797          	auipc	a5,0xb2
ffffffffc0203034:	0f07b783          	ld	a5,240(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0203038:	739c                	ld	a5,32(a5)
ffffffffc020303a:	4585                	li	a1,1
ffffffffc020303c:	854a                	mv	a0,s2
ffffffffc020303e:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203040:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203044:	120a0073          	sfence.vma	s4
ffffffffc0203048:	bf85                	j	ffffffffc0202fb8 <page_insert+0x3a>
        intr_disable();
ffffffffc020304a:	971fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020304e:	000b2797          	auipc	a5,0xb2
ffffffffc0203052:	0d27b783          	ld	a5,210(a5) # ffffffffc02b5120 <pmm_manager>
ffffffffc0203056:	739c                	ld	a5,32(a5)
ffffffffc0203058:	4585                	li	a1,1
ffffffffc020305a:	854a                	mv	a0,s2
ffffffffc020305c:	9782                	jalr	a5
        intr_enable();
ffffffffc020305e:	957fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203062:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203066:	120a0073          	sfence.vma	s4
ffffffffc020306a:	b7b9                	j	ffffffffc0202fb8 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020306c:	5571                	li	a0,-4
ffffffffc020306e:	b79d                	j	ffffffffc0202fd4 <page_insert+0x56>
ffffffffc0203070:	f2eff0ef          	jal	ra,ffffffffc020279e <pa2page.part.0>

ffffffffc0203074 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0203074:	00004797          	auipc	a5,0x4
ffffffffc0203078:	99c78793          	addi	a5,a5,-1636 # ffffffffc0206a10 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020307c:	638c                	ld	a1,0(a5)
{
ffffffffc020307e:	7159                	addi	sp,sp,-112
ffffffffc0203080:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203082:	00004517          	auipc	a0,0x4
ffffffffc0203086:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0206aa0 <default_pmm_manager+0x90>
    pmm_manager = &default_pmm_manager;
ffffffffc020308a:	000b2b17          	auipc	s6,0xb2
ffffffffc020308e:	096b0b13          	addi	s6,s6,150 # ffffffffc02b5120 <pmm_manager>
{
ffffffffc0203092:	f486                	sd	ra,104(sp)
ffffffffc0203094:	e8ca                	sd	s2,80(sp)
ffffffffc0203096:	e4ce                	sd	s3,72(sp)
ffffffffc0203098:	f0a2                	sd	s0,96(sp)
ffffffffc020309a:	eca6                	sd	s1,88(sp)
ffffffffc020309c:	e0d2                	sd	s4,64(sp)
ffffffffc020309e:	fc56                	sd	s5,56(sp)
ffffffffc02030a0:	f45e                	sd	s7,40(sp)
ffffffffc02030a2:	f062                	sd	s8,32(sp)
ffffffffc02030a4:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02030a6:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030aa:	836fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    pmm_manager->init();
ffffffffc02030ae:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02030b2:	000b2997          	auipc	s3,0xb2
ffffffffc02030b6:	07698993          	addi	s3,s3,118 # ffffffffc02b5128 <va_pa_offset>
    pmm_manager->init();
ffffffffc02030ba:	679c                	ld	a5,8(a5)
ffffffffc02030bc:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02030be:	57f5                	li	a5,-3
ffffffffc02030c0:	07fa                	slli	a5,a5,0x1e
ffffffffc02030c2:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02030c6:	813fd0ef          	jal	ra,ffffffffc02008d8 <get_memory_base>
ffffffffc02030ca:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02030cc:	817fd0ef          	jal	ra,ffffffffc02008e2 <get_memory_size>
    if (mem_size == 0)
ffffffffc02030d0:	200505e3          	beqz	a0,ffffffffc0203ada <pmm_init+0xa66>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02030d4:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02030d6:	00004517          	auipc	a0,0x4
ffffffffc02030da:	a0250513          	addi	a0,a0,-1534 # ffffffffc0206ad8 <default_pmm_manager+0xc8>
ffffffffc02030de:	802fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02030e2:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02030e6:	fff40693          	addi	a3,s0,-1
ffffffffc02030ea:	864a                	mv	a2,s2
ffffffffc02030ec:	85a6                	mv	a1,s1
ffffffffc02030ee:	00004517          	auipc	a0,0x4
ffffffffc02030f2:	a0250513          	addi	a0,a0,-1534 # ffffffffc0206af0 <default_pmm_manager+0xe0>
ffffffffc02030f6:	febfc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02030fa:	c8000737          	lui	a4,0xc8000
ffffffffc02030fe:	87a2                	mv	a5,s0
ffffffffc0203100:	54876163          	bltu	a4,s0,ffffffffc0203642 <pmm_init+0x5ce>
ffffffffc0203104:	757d                	lui	a0,0xfffff
ffffffffc0203106:	000b3617          	auipc	a2,0xb3
ffffffffc020310a:	04560613          	addi	a2,a2,69 # ffffffffc02b614b <end+0xfff>
ffffffffc020310e:	8e69                	and	a2,a2,a0
ffffffffc0203110:	000b2497          	auipc	s1,0xb2
ffffffffc0203114:	00048493          	mv	s1,s1
ffffffffc0203118:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020311c:	000b2b97          	auipc	s7,0xb2
ffffffffc0203120:	ffcb8b93          	addi	s7,s7,-4 # ffffffffc02b5118 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203124:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203126:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020312a:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020312e:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203130:	02f50863          	beq	a0,a5,ffffffffc0203160 <pmm_init+0xec>
ffffffffc0203134:	4781                	li	a5,0
ffffffffc0203136:	4585                	li	a1,1
ffffffffc0203138:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020313c:	00679513          	slli	a0,a5,0x6
ffffffffc0203140:	9532                	add	a0,a0,a2
ffffffffc0203142:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fd49ebc>
ffffffffc0203146:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020314a:	6088                	ld	a0,0(s1)
ffffffffc020314c:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc020314e:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203152:	00d50733          	add	a4,a0,a3
ffffffffc0203156:	fee7e3e3          	bltu	a5,a4,ffffffffc020313c <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020315a:	071a                	slli	a4,a4,0x6
ffffffffc020315c:	00e606b3          	add	a3,a2,a4
ffffffffc0203160:	c02007b7          	lui	a5,0xc0200
ffffffffc0203164:	2ef6ece3          	bltu	a3,a5,ffffffffc0203c5c <pmm_init+0xbe8>
ffffffffc0203168:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020316c:	77fd                	lui	a5,0xfffff
ffffffffc020316e:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203170:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0203172:	5086eb63          	bltu	a3,s0,ffffffffc0203688 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0203176:	00004517          	auipc	a0,0x4
ffffffffc020317a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0206b18 <default_pmm_manager+0x108>
ffffffffc020317e:	f63fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0203182:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0203186:	000b2917          	auipc	s2,0xb2
ffffffffc020318a:	f8290913          	addi	s2,s2,-126 # ffffffffc02b5108 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020318e:	7b9c                	ld	a5,48(a5)
ffffffffc0203190:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0203192:	00004517          	auipc	a0,0x4
ffffffffc0203196:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206b30 <default_pmm_manager+0x120>
ffffffffc020319a:	f47fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020319e:	00007697          	auipc	a3,0x7
ffffffffc02031a2:	e6268693          	addi	a3,a3,-414 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc02031a6:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02031aa:	c02007b7          	lui	a5,0xc0200
ffffffffc02031ae:	28f6ebe3          	bltu	a3,a5,ffffffffc0203c44 <pmm_init+0xbd0>
ffffffffc02031b2:	0009b783          	ld	a5,0(s3)
ffffffffc02031b6:	8e9d                	sub	a3,a3,a5
ffffffffc02031b8:	000b2797          	auipc	a5,0xb2
ffffffffc02031bc:	f4d7b423          	sd	a3,-184(a5) # ffffffffc02b5100 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02031c0:	100027f3          	csrr	a5,sstatus
ffffffffc02031c4:	8b89                	andi	a5,a5,2
ffffffffc02031c6:	4a079763          	bnez	a5,ffffffffc0203674 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc02031ca:	000b3783          	ld	a5,0(s6)
ffffffffc02031ce:	779c                	ld	a5,40(a5)
ffffffffc02031d0:	9782                	jalr	a5
ffffffffc02031d2:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031d4:	6098                	ld	a4,0(s1)
ffffffffc02031d6:	c80007b7          	lui	a5,0xc8000
ffffffffc02031da:	83b1                	srli	a5,a5,0xc
ffffffffc02031dc:	66e7e363          	bltu	a5,a4,ffffffffc0203842 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02031e0:	00093503          	ld	a0,0(s2)
ffffffffc02031e4:	62050f63          	beqz	a0,ffffffffc0203822 <pmm_init+0x7ae>
ffffffffc02031e8:	03451793          	slli	a5,a0,0x34
ffffffffc02031ec:	62079b63          	bnez	a5,ffffffffc0203822 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02031f0:	4601                	li	a2,0
ffffffffc02031f2:	4581                	li	a1,0
ffffffffc02031f4:	8c3ff0ef          	jal	ra,ffffffffc0202ab6 <get_page>
ffffffffc02031f8:	60051563          	bnez	a0,ffffffffc0203802 <pmm_init+0x78e>
ffffffffc02031fc:	100027f3          	csrr	a5,sstatus
ffffffffc0203200:	8b89                	andi	a5,a5,2
ffffffffc0203202:	44079e63          	bnez	a5,ffffffffc020365e <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203206:	000b3783          	ld	a5,0(s6)
ffffffffc020320a:	4505                	li	a0,1
ffffffffc020320c:	6f9c                	ld	a5,24(a5)
ffffffffc020320e:	9782                	jalr	a5
ffffffffc0203210:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203212:	00093503          	ld	a0,0(s2)
ffffffffc0203216:	4681                	li	a3,0
ffffffffc0203218:	4601                	li	a2,0
ffffffffc020321a:	85d2                	mv	a1,s4
ffffffffc020321c:	d63ff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc0203220:	26051ae3          	bnez	a0,ffffffffc0203c94 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203224:	00093503          	ld	a0,0(s2)
ffffffffc0203228:	4601                	li	a2,0
ffffffffc020322a:	4581                	li	a1,0
ffffffffc020322c:	e62ff0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc0203230:	240502e3          	beqz	a0,ffffffffc0203c74 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0203234:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0203236:	0017f713          	andi	a4,a5,1
ffffffffc020323a:	5a070263          	beqz	a4,ffffffffc02037de <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020323e:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203240:	078a                	slli	a5,a5,0x2
ffffffffc0203242:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203244:	58e7fb63          	bgeu	a5,a4,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203248:	000bb683          	ld	a3,0(s7)
ffffffffc020324c:	fff80637          	lui	a2,0xfff80
ffffffffc0203250:	97b2                	add	a5,a5,a2
ffffffffc0203252:	079a                	slli	a5,a5,0x6
ffffffffc0203254:	97b6                	add	a5,a5,a3
ffffffffc0203256:	14fa17e3          	bne	s4,a5,ffffffffc0203ba4 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc020325a:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc020325e:	4785                	li	a5,1
ffffffffc0203260:	12f692e3          	bne	a3,a5,ffffffffc0203b84 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203264:	00093503          	ld	a0,0(s2)
ffffffffc0203268:	77fd                	lui	a5,0xfffff
ffffffffc020326a:	6114                	ld	a3,0(a0)
ffffffffc020326c:	068a                	slli	a3,a3,0x2
ffffffffc020326e:	8efd                	and	a3,a3,a5
ffffffffc0203270:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203274:	0ee67ce3          	bgeu	a2,a4,ffffffffc0203b6c <pmm_init+0xaf8>
ffffffffc0203278:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020327c:	96e2                	add	a3,a3,s8
ffffffffc020327e:	0006ba83          	ld	s5,0(a3)
ffffffffc0203282:	0a8a                	slli	s5,s5,0x2
ffffffffc0203284:	00fafab3          	and	s5,s5,a5
ffffffffc0203288:	00cad793          	srli	a5,s5,0xc
ffffffffc020328c:	0ce7f3e3          	bgeu	a5,a4,ffffffffc0203b52 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203290:	4601                	li	a2,0
ffffffffc0203292:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203294:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203296:	df8ff0ef          	jal	ra,ffffffffc020288e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020329a:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020329c:	55551363          	bne	a0,s5,ffffffffc02037e2 <pmm_init+0x76e>
ffffffffc02032a0:	100027f3          	csrr	a5,sstatus
ffffffffc02032a4:	8b89                	andi	a5,a5,2
ffffffffc02032a6:	3a079163          	bnez	a5,ffffffffc0203648 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02032aa:	000b3783          	ld	a5,0(s6)
ffffffffc02032ae:	4505                	li	a0,1
ffffffffc02032b0:	6f9c                	ld	a5,24(a5)
ffffffffc02032b2:	9782                	jalr	a5
ffffffffc02032b4:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032b6:	00093503          	ld	a0,0(s2)
ffffffffc02032ba:	46d1                	li	a3,20
ffffffffc02032bc:	6605                	lui	a2,0x1
ffffffffc02032be:	85e2                	mv	a1,s8
ffffffffc02032c0:	cbfff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc02032c4:	060517e3          	bnez	a0,ffffffffc0203b32 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032c8:	00093503          	ld	a0,0(s2)
ffffffffc02032cc:	4601                	li	a2,0
ffffffffc02032ce:	6585                	lui	a1,0x1
ffffffffc02032d0:	dbeff0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc02032d4:	02050fe3          	beqz	a0,ffffffffc0203b12 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc02032d8:	611c                	ld	a5,0(a0)
ffffffffc02032da:	0107f713          	andi	a4,a5,16
ffffffffc02032de:	7c070e63          	beqz	a4,ffffffffc0203aba <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc02032e2:	8b91                	andi	a5,a5,4
ffffffffc02032e4:	7a078b63          	beqz	a5,ffffffffc0203a9a <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02032e8:	00093503          	ld	a0,0(s2)
ffffffffc02032ec:	611c                	ld	a5,0(a0)
ffffffffc02032ee:	8bc1                	andi	a5,a5,16
ffffffffc02032f0:	78078563          	beqz	a5,ffffffffc0203a7a <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02032f4:	000c2703          	lw	a4,0(s8)
ffffffffc02032f8:	4785                	li	a5,1
ffffffffc02032fa:	76f71063          	bne	a4,a5,ffffffffc0203a5a <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02032fe:	4681                	li	a3,0
ffffffffc0203300:	6605                	lui	a2,0x1
ffffffffc0203302:	85d2                	mv	a1,s4
ffffffffc0203304:	c7bff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc0203308:	72051963          	bnez	a0,ffffffffc0203a3a <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc020330c:	000a2703          	lw	a4,0(s4)
ffffffffc0203310:	4789                	li	a5,2
ffffffffc0203312:	70f71463          	bne	a4,a5,ffffffffc0203a1a <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc0203316:	000c2783          	lw	a5,0(s8)
ffffffffc020331a:	6e079063          	bnez	a5,ffffffffc02039fa <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020331e:	00093503          	ld	a0,0(s2)
ffffffffc0203322:	4601                	li	a2,0
ffffffffc0203324:	6585                	lui	a1,0x1
ffffffffc0203326:	d68ff0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc020332a:	6a050863          	beqz	a0,ffffffffc02039da <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc020332e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0203330:	00177793          	andi	a5,a4,1
ffffffffc0203334:	4a078563          	beqz	a5,ffffffffc02037de <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc0203338:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020333a:	00271793          	slli	a5,a4,0x2
ffffffffc020333e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203340:	48d7fd63          	bgeu	a5,a3,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203344:	000bb683          	ld	a3,0(s7)
ffffffffc0203348:	fff80ab7          	lui	s5,0xfff80
ffffffffc020334c:	97d6                	add	a5,a5,s5
ffffffffc020334e:	079a                	slli	a5,a5,0x6
ffffffffc0203350:	97b6                	add	a5,a5,a3
ffffffffc0203352:	66fa1463          	bne	s4,a5,ffffffffc02039ba <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203356:	8b41                	andi	a4,a4,16
ffffffffc0203358:	64071163          	bnez	a4,ffffffffc020399a <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc020335c:	00093503          	ld	a0,0(s2)
ffffffffc0203360:	4581                	li	a1,0
ffffffffc0203362:	b81ff0ef          	jal	ra,ffffffffc0202ee2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203366:	000a2c83          	lw	s9,0(s4)
ffffffffc020336a:	4785                	li	a5,1
ffffffffc020336c:	60fc9763          	bne	s9,a5,ffffffffc020397a <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc0203370:	000c2783          	lw	a5,0(s8)
ffffffffc0203374:	5e079363          	bnez	a5,ffffffffc020395a <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0203378:	00093503          	ld	a0,0(s2)
ffffffffc020337c:	6585                	lui	a1,0x1
ffffffffc020337e:	b65ff0ef          	jal	ra,ffffffffc0202ee2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203382:	000a2783          	lw	a5,0(s4)
ffffffffc0203386:	52079a63          	bnez	a5,ffffffffc02038ba <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc020338a:	000c2783          	lw	a5,0(s8)
ffffffffc020338e:	50079663          	bnez	a5,ffffffffc020389a <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203392:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0203396:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203398:	000a3683          	ld	a3,0(s4)
ffffffffc020339c:	068a                	slli	a3,a3,0x2
ffffffffc020339e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc02033a0:	42b6fd63          	bgeu	a3,a1,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02033a4:	000bb503          	ld	a0,0(s7)
ffffffffc02033a8:	96d6                	add	a3,a3,s5
ffffffffc02033aa:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02033ac:	00d507b3          	add	a5,a0,a3
ffffffffc02033b0:	439c                	lw	a5,0(a5)
ffffffffc02033b2:	4d979463          	bne	a5,s9,ffffffffc020387a <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc02033b6:	8699                	srai	a3,a3,0x6
ffffffffc02033b8:	00080637          	lui	a2,0x80
ffffffffc02033bc:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02033be:	00c69713          	slli	a4,a3,0xc
ffffffffc02033c2:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02033c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02033c6:	48b77e63          	bgeu	a4,a1,ffffffffc0203862 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02033ca:	0009b703          	ld	a4,0(s3)
ffffffffc02033ce:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc02033d0:	629c                	ld	a5,0(a3)
ffffffffc02033d2:	078a                	slli	a5,a5,0x2
ffffffffc02033d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033d6:	40b7f263          	bgeu	a5,a1,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02033da:	8f91                	sub	a5,a5,a2
ffffffffc02033dc:	079a                	slli	a5,a5,0x6
ffffffffc02033de:	953e                	add	a0,a0,a5
ffffffffc02033e0:	100027f3          	csrr	a5,sstatus
ffffffffc02033e4:	8b89                	andi	a5,a5,2
ffffffffc02033e6:	30079963          	bnez	a5,ffffffffc02036f8 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc02033ea:	000b3783          	ld	a5,0(s6)
ffffffffc02033ee:	4585                	li	a1,1
ffffffffc02033f0:	739c                	ld	a5,32(a5)
ffffffffc02033f2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02033f4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02033f8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033fa:	078a                	slli	a5,a5,0x2
ffffffffc02033fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033fe:	3ce7fe63          	bgeu	a5,a4,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0203402:	000bb503          	ld	a0,0(s7)
ffffffffc0203406:	fff80737          	lui	a4,0xfff80
ffffffffc020340a:	97ba                	add	a5,a5,a4
ffffffffc020340c:	079a                	slli	a5,a5,0x6
ffffffffc020340e:	953e                	add	a0,a0,a5
ffffffffc0203410:	100027f3          	csrr	a5,sstatus
ffffffffc0203414:	8b89                	andi	a5,a5,2
ffffffffc0203416:	2c079563          	bnez	a5,ffffffffc02036e0 <pmm_init+0x66c>
ffffffffc020341a:	000b3783          	ld	a5,0(s6)
ffffffffc020341e:	4585                	li	a1,1
ffffffffc0203420:	739c                	ld	a5,32(a5)
ffffffffc0203422:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0203424:	00093783          	ld	a5,0(s2)
ffffffffc0203428:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd49eb4>
    asm volatile("sfence.vma");
ffffffffc020342c:	12000073          	sfence.vma
ffffffffc0203430:	100027f3          	csrr	a5,sstatus
ffffffffc0203434:	8b89                	andi	a5,a5,2
ffffffffc0203436:	28079b63          	bnez	a5,ffffffffc02036cc <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc020343a:	000b3783          	ld	a5,0(s6)
ffffffffc020343e:	779c                	ld	a5,40(a5)
ffffffffc0203440:	9782                	jalr	a5
ffffffffc0203442:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203444:	4b441b63          	bne	s0,s4,ffffffffc02038fa <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203448:	00004517          	auipc	a0,0x4
ffffffffc020344c:	a1050513          	addi	a0,a0,-1520 # ffffffffc0206e58 <default_pmm_manager+0x448>
ffffffffc0203450:	c91fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0203454:	100027f3          	csrr	a5,sstatus
ffffffffc0203458:	8b89                	andi	a5,a5,2
ffffffffc020345a:	24079f63          	bnez	a5,ffffffffc02036b8 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc020345e:	000b3783          	ld	a5,0(s6)
ffffffffc0203462:	779c                	ld	a5,40(a5)
ffffffffc0203464:	9782                	jalr	a5
ffffffffc0203466:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0203468:	6098                	ld	a4,0(s1)
ffffffffc020346a:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020346e:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0203470:	00c71793          	slli	a5,a4,0xc
ffffffffc0203474:	6a05                	lui	s4,0x1
ffffffffc0203476:	02f47c63          	bgeu	s0,a5,ffffffffc02034ae <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020347a:	00c45793          	srli	a5,s0,0xc
ffffffffc020347e:	00093503          	ld	a0,0(s2)
ffffffffc0203482:	2ee7ff63          	bgeu	a5,a4,ffffffffc0203780 <pmm_init+0x70c>
ffffffffc0203486:	0009b583          	ld	a1,0(s3)
ffffffffc020348a:	4601                	li	a2,0
ffffffffc020348c:	95a2                	add	a1,a1,s0
ffffffffc020348e:	c00ff0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc0203492:	32050463          	beqz	a0,ffffffffc02037ba <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203496:	611c                	ld	a5,0(a0)
ffffffffc0203498:	078a                	slli	a5,a5,0x2
ffffffffc020349a:	0157f7b3          	and	a5,a5,s5
ffffffffc020349e:	2e879e63          	bne	a5,s0,ffffffffc020379a <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02034a2:	6098                	ld	a4,0(s1)
ffffffffc02034a4:	9452                	add	s0,s0,s4
ffffffffc02034a6:	00c71793          	slli	a5,a4,0xc
ffffffffc02034aa:	fcf468e3          	bltu	s0,a5,ffffffffc020347a <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc02034ae:	00093783          	ld	a5,0(s2)
ffffffffc02034b2:	639c                	ld	a5,0(a5)
ffffffffc02034b4:	42079363          	bnez	a5,ffffffffc02038da <pmm_init+0x866>
ffffffffc02034b8:	100027f3          	csrr	a5,sstatus
ffffffffc02034bc:	8b89                	andi	a5,a5,2
ffffffffc02034be:	24079963          	bnez	a5,ffffffffc0203710 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034c2:	000b3783          	ld	a5,0(s6)
ffffffffc02034c6:	4505                	li	a0,1
ffffffffc02034c8:	6f9c                	ld	a5,24(a5)
ffffffffc02034ca:	9782                	jalr	a5
ffffffffc02034cc:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02034ce:	00093503          	ld	a0,0(s2)
ffffffffc02034d2:	4699                	li	a3,6
ffffffffc02034d4:	10000613          	li	a2,256
ffffffffc02034d8:	85d2                	mv	a1,s4
ffffffffc02034da:	aa5ff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc02034de:	44051e63          	bnez	a0,ffffffffc020393a <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc02034e2:	000a2703          	lw	a4,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc8>
ffffffffc02034e6:	4785                	li	a5,1
ffffffffc02034e8:	42f71963          	bne	a4,a5,ffffffffc020391a <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034ec:	00093503          	ld	a0,0(s2)
ffffffffc02034f0:	6405                	lui	s0,0x1
ffffffffc02034f2:	4699                	li	a3,6
ffffffffc02034f4:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ac8>
ffffffffc02034f8:	85d2                	mv	a1,s4
ffffffffc02034fa:	a85ff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc02034fe:	72051363          	bnez	a0,ffffffffc0203c24 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0203502:	000a2703          	lw	a4,0(s4)
ffffffffc0203506:	4789                	li	a5,2
ffffffffc0203508:	6ef71e63          	bne	a4,a5,ffffffffc0203c04 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020350c:	00004597          	auipc	a1,0x4
ffffffffc0203510:	a9458593          	addi	a1,a1,-1388 # ffffffffc0206fa0 <default_pmm_manager+0x590>
ffffffffc0203514:	10000513          	li	a0,256
ffffffffc0203518:	64d010ef          	jal	ra,ffffffffc0205364 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020351c:	10040593          	addi	a1,s0,256
ffffffffc0203520:	10000513          	li	a0,256
ffffffffc0203524:	653010ef          	jal	ra,ffffffffc0205376 <strcmp>
ffffffffc0203528:	6a051e63          	bnez	a0,ffffffffc0203be4 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc020352c:	000bb683          	ld	a3,0(s7)
ffffffffc0203530:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0203534:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0203536:	40da06b3          	sub	a3,s4,a3
ffffffffc020353a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020353c:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020353e:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0203540:	8031                	srli	s0,s0,0xc
ffffffffc0203542:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203546:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203548:	30f77d63          	bgeu	a4,a5,ffffffffc0203862 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020354c:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203550:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203554:	96be                	add	a3,a3,a5
ffffffffc0203556:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020355a:	5d5010ef          	jal	ra,ffffffffc020532e <strlen>
ffffffffc020355e:	66051363          	bnez	a0,ffffffffc0203bc4 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0203562:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0203566:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203568:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fd49eb4>
ffffffffc020356c:	068a                	slli	a3,a3,0x2
ffffffffc020356e:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0203570:	26f6f563          	bgeu	a3,a5,ffffffffc02037da <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0203574:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203576:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203578:	2ef47563          	bgeu	s0,a5,ffffffffc0203862 <pmm_init+0x7ee>
ffffffffc020357c:	0009b403          	ld	s0,0(s3)
ffffffffc0203580:	9436                	add	s0,s0,a3
ffffffffc0203582:	100027f3          	csrr	a5,sstatus
ffffffffc0203586:	8b89                	andi	a5,a5,2
ffffffffc0203588:	1e079163          	bnez	a5,ffffffffc020376a <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc020358c:	000b3783          	ld	a5,0(s6)
ffffffffc0203590:	4585                	li	a1,1
ffffffffc0203592:	8552                	mv	a0,s4
ffffffffc0203594:	739c                	ld	a5,32(a5)
ffffffffc0203596:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203598:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc020359a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020359c:	078a                	slli	a5,a5,0x2
ffffffffc020359e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035a0:	22e7fd63          	bgeu	a5,a4,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02035a4:	000bb503          	ld	a0,0(s7)
ffffffffc02035a8:	fff80737          	lui	a4,0xfff80
ffffffffc02035ac:	97ba                	add	a5,a5,a4
ffffffffc02035ae:	079a                	slli	a5,a5,0x6
ffffffffc02035b0:	953e                	add	a0,a0,a5
ffffffffc02035b2:	100027f3          	csrr	a5,sstatus
ffffffffc02035b6:	8b89                	andi	a5,a5,2
ffffffffc02035b8:	18079d63          	bnez	a5,ffffffffc0203752 <pmm_init+0x6de>
ffffffffc02035bc:	000b3783          	ld	a5,0(s6)
ffffffffc02035c0:	4585                	li	a1,1
ffffffffc02035c2:	739c                	ld	a5,32(a5)
ffffffffc02035c4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035c6:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc02035ca:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035cc:	078a                	slli	a5,a5,0x2
ffffffffc02035ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035d0:	20e7f563          	bgeu	a5,a4,ffffffffc02037da <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02035d4:	000bb503          	ld	a0,0(s7)
ffffffffc02035d8:	fff80737          	lui	a4,0xfff80
ffffffffc02035dc:	97ba                	add	a5,a5,a4
ffffffffc02035de:	079a                	slli	a5,a5,0x6
ffffffffc02035e0:	953e                	add	a0,a0,a5
ffffffffc02035e2:	100027f3          	csrr	a5,sstatus
ffffffffc02035e6:	8b89                	andi	a5,a5,2
ffffffffc02035e8:	14079963          	bnez	a5,ffffffffc020373a <pmm_init+0x6c6>
ffffffffc02035ec:	000b3783          	ld	a5,0(s6)
ffffffffc02035f0:	4585                	li	a1,1
ffffffffc02035f2:	739c                	ld	a5,32(a5)
ffffffffc02035f4:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02035f6:	00093783          	ld	a5,0(s2)
ffffffffc02035fa:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc02035fe:	12000073          	sfence.vma
ffffffffc0203602:	100027f3          	csrr	a5,sstatus
ffffffffc0203606:	8b89                	andi	a5,a5,2
ffffffffc0203608:	10079f63          	bnez	a5,ffffffffc0203726 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc020360c:	000b3783          	ld	a5,0(s6)
ffffffffc0203610:	779c                	ld	a5,40(a5)
ffffffffc0203612:	9782                	jalr	a5
ffffffffc0203614:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203616:	4c8c1e63          	bne	s8,s0,ffffffffc0203af2 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020361a:	00004517          	auipc	a0,0x4
ffffffffc020361e:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0207018 <default_pmm_manager+0x608>
ffffffffc0203622:	abffc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0203626:	7406                	ld	s0,96(sp)
ffffffffc0203628:	70a6                	ld	ra,104(sp)
ffffffffc020362a:	64e6                	ld	s1,88(sp)
ffffffffc020362c:	6946                	ld	s2,80(sp)
ffffffffc020362e:	69a6                	ld	s3,72(sp)
ffffffffc0203630:	6a06                	ld	s4,64(sp)
ffffffffc0203632:	7ae2                	ld	s5,56(sp)
ffffffffc0203634:	7b42                	ld	s6,48(sp)
ffffffffc0203636:	7ba2                	ld	s7,40(sp)
ffffffffc0203638:	7c02                	ld	s8,32(sp)
ffffffffc020363a:	6ce2                	ld	s9,24(sp)
ffffffffc020363c:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc020363e:	ce8fe06f          	j	ffffffffc0201b26 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0203642:	c80007b7          	lui	a5,0xc8000
ffffffffc0203646:	bc7d                	j	ffffffffc0203104 <pmm_init+0x90>
        intr_disable();
ffffffffc0203648:	b72fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020364c:	000b3783          	ld	a5,0(s6)
ffffffffc0203650:	4505                	li	a0,1
ffffffffc0203652:	6f9c                	ld	a5,24(a5)
ffffffffc0203654:	9782                	jalr	a5
ffffffffc0203656:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203658:	b5cfd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020365c:	b9a9                	j	ffffffffc02032b6 <pmm_init+0x242>
        intr_disable();
ffffffffc020365e:	b5cfd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0203662:	000b3783          	ld	a5,0(s6)
ffffffffc0203666:	4505                	li	a0,1
ffffffffc0203668:	6f9c                	ld	a5,24(a5)
ffffffffc020366a:	9782                	jalr	a5
ffffffffc020366c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020366e:	b46fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203672:	b645                	j	ffffffffc0203212 <pmm_init+0x19e>
        intr_disable();
ffffffffc0203674:	b46fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203678:	000b3783          	ld	a5,0(s6)
ffffffffc020367c:	779c                	ld	a5,40(a5)
ffffffffc020367e:	9782                	jalr	a5
ffffffffc0203680:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203682:	b32fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203686:	b6b9                	j	ffffffffc02031d4 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203688:	6705                	lui	a4,0x1
ffffffffc020368a:	177d                	addi	a4,a4,-1
ffffffffc020368c:	96ba                	add	a3,a3,a4
ffffffffc020368e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0203690:	00c7d713          	srli	a4,a5,0xc
ffffffffc0203694:	14a77363          	bgeu	a4,a0,ffffffffc02037da <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0203698:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc020369c:	fff80537          	lui	a0,0xfff80
ffffffffc02036a0:	972a                	add	a4,a4,a0
ffffffffc02036a2:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02036a4:	8c1d                	sub	s0,s0,a5
ffffffffc02036a6:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02036aa:	00c45593          	srli	a1,s0,0xc
ffffffffc02036ae:	9532                	add	a0,a0,a2
ffffffffc02036b0:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02036b2:	0009b583          	ld	a1,0(s3)
}
ffffffffc02036b6:	b4c1                	j	ffffffffc0203176 <pmm_init+0x102>
        intr_disable();
ffffffffc02036b8:	b02fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02036bc:	000b3783          	ld	a5,0(s6)
ffffffffc02036c0:	779c                	ld	a5,40(a5)
ffffffffc02036c2:	9782                	jalr	a5
ffffffffc02036c4:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02036c6:	aeefd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02036ca:	bb79                	j	ffffffffc0203468 <pmm_init+0x3f4>
        intr_disable();
ffffffffc02036cc:	aeefd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc02036d0:	000b3783          	ld	a5,0(s6)
ffffffffc02036d4:	779c                	ld	a5,40(a5)
ffffffffc02036d6:	9782                	jalr	a5
ffffffffc02036d8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02036da:	adafd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02036de:	b39d                	j	ffffffffc0203444 <pmm_init+0x3d0>
ffffffffc02036e0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036e2:	ad8fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02036e6:	000b3783          	ld	a5,0(s6)
ffffffffc02036ea:	6522                	ld	a0,8(sp)
ffffffffc02036ec:	4585                	li	a1,1
ffffffffc02036ee:	739c                	ld	a5,32(a5)
ffffffffc02036f0:	9782                	jalr	a5
        intr_enable();
ffffffffc02036f2:	ac2fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc02036f6:	b33d                	j	ffffffffc0203424 <pmm_init+0x3b0>
ffffffffc02036f8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036fa:	ac0fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc02036fe:	000b3783          	ld	a5,0(s6)
ffffffffc0203702:	6522                	ld	a0,8(sp)
ffffffffc0203704:	4585                	li	a1,1
ffffffffc0203706:	739c                	ld	a5,32(a5)
ffffffffc0203708:	9782                	jalr	a5
        intr_enable();
ffffffffc020370a:	aaafd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020370e:	b1dd                	j	ffffffffc02033f4 <pmm_init+0x380>
        intr_disable();
ffffffffc0203710:	aaafd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203714:	000b3783          	ld	a5,0(s6)
ffffffffc0203718:	4505                	li	a0,1
ffffffffc020371a:	6f9c                	ld	a5,24(a5)
ffffffffc020371c:	9782                	jalr	a5
ffffffffc020371e:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203720:	a94fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203724:	b36d                	j	ffffffffc02034ce <pmm_init+0x45a>
        intr_disable();
ffffffffc0203726:	a94fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020372a:	000b3783          	ld	a5,0(s6)
ffffffffc020372e:	779c                	ld	a5,40(a5)
ffffffffc0203730:	9782                	jalr	a5
ffffffffc0203732:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203734:	a80fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203738:	bdf9                	j	ffffffffc0203616 <pmm_init+0x5a2>
ffffffffc020373a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020373c:	a7efd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203740:	000b3783          	ld	a5,0(s6)
ffffffffc0203744:	6522                	ld	a0,8(sp)
ffffffffc0203746:	4585                	li	a1,1
ffffffffc0203748:	739c                	ld	a5,32(a5)
ffffffffc020374a:	9782                	jalr	a5
        intr_enable();
ffffffffc020374c:	a68fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203750:	b55d                	j	ffffffffc02035f6 <pmm_init+0x582>
ffffffffc0203752:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203754:	a66fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0203758:	000b3783          	ld	a5,0(s6)
ffffffffc020375c:	6522                	ld	a0,8(sp)
ffffffffc020375e:	4585                	li	a1,1
ffffffffc0203760:	739c                	ld	a5,32(a5)
ffffffffc0203762:	9782                	jalr	a5
        intr_enable();
ffffffffc0203764:	a50fd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203768:	bdb9                	j	ffffffffc02035c6 <pmm_init+0x552>
        intr_disable();
ffffffffc020376a:	a50fd0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc020376e:	000b3783          	ld	a5,0(s6)
ffffffffc0203772:	4585                	li	a1,1
ffffffffc0203774:	8552                	mv	a0,s4
ffffffffc0203776:	739c                	ld	a5,32(a5)
ffffffffc0203778:	9782                	jalr	a5
        intr_enable();
ffffffffc020377a:	a3afd0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc020377e:	bd29                	j	ffffffffc0203598 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203780:	86a2                	mv	a3,s0
ffffffffc0203782:	00003617          	auipc	a2,0x3
ffffffffc0203786:	b1e60613          	addi	a2,a2,-1250 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc020378a:	23a00593          	li	a1,570
ffffffffc020378e:	00003517          	auipc	a0,0x3
ffffffffc0203792:	2ba50513          	addi	a0,a0,698 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203796:	a89fc0ef          	jal	ra,ffffffffc020021e <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020379a:	00003697          	auipc	a3,0x3
ffffffffc020379e:	71e68693          	addi	a3,a3,1822 # ffffffffc0206eb8 <default_pmm_manager+0x4a8>
ffffffffc02037a2:	00003617          	auipc	a2,0x3
ffffffffc02037a6:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02037aa:	23b00593          	li	a1,571
ffffffffc02037ae:	00003517          	auipc	a0,0x3
ffffffffc02037b2:	29a50513          	addi	a0,a0,666 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02037b6:	a69fc0ef          	jal	ra,ffffffffc020021e <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02037ba:	00003697          	auipc	a3,0x3
ffffffffc02037be:	6be68693          	addi	a3,a3,1726 # ffffffffc0206e78 <default_pmm_manager+0x468>
ffffffffc02037c2:	00003617          	auipc	a2,0x3
ffffffffc02037c6:	b9660613          	addi	a2,a2,-1130 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02037ca:	23a00593          	li	a1,570
ffffffffc02037ce:	00003517          	auipc	a0,0x3
ffffffffc02037d2:	27a50513          	addi	a0,a0,634 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02037d6:	a49fc0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc02037da:	fc5fe0ef          	jal	ra,ffffffffc020279e <pa2page.part.0>
ffffffffc02037de:	fddfe0ef          	jal	ra,ffffffffc02027ba <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02037e2:	00003697          	auipc	a3,0x3
ffffffffc02037e6:	48e68693          	addi	a3,a3,1166 # ffffffffc0206c70 <default_pmm_manager+0x260>
ffffffffc02037ea:	00003617          	auipc	a2,0x3
ffffffffc02037ee:	b6e60613          	addi	a2,a2,-1170 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02037f2:	20a00593          	li	a1,522
ffffffffc02037f6:	00003517          	auipc	a0,0x3
ffffffffc02037fa:	25250513          	addi	a0,a0,594 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02037fe:	a21fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203802:	00003697          	auipc	a3,0x3
ffffffffc0203806:	3ae68693          	addi	a3,a3,942 # ffffffffc0206bb0 <default_pmm_manager+0x1a0>
ffffffffc020380a:	00003617          	auipc	a2,0x3
ffffffffc020380e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203812:	1fd00593          	li	a1,509
ffffffffc0203816:	00003517          	auipc	a0,0x3
ffffffffc020381a:	23250513          	addi	a0,a0,562 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc020381e:	a01fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0203822:	00003697          	auipc	a3,0x3
ffffffffc0203826:	34e68693          	addi	a3,a3,846 # ffffffffc0206b70 <default_pmm_manager+0x160>
ffffffffc020382a:	00003617          	auipc	a2,0x3
ffffffffc020382e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203832:	1fc00593          	li	a1,508
ffffffffc0203836:	00003517          	auipc	a0,0x3
ffffffffc020383a:	21250513          	addi	a0,a0,530 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc020383e:	9e1fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203842:	00003697          	auipc	a3,0x3
ffffffffc0203846:	30e68693          	addi	a3,a3,782 # ffffffffc0206b50 <default_pmm_manager+0x140>
ffffffffc020384a:	00003617          	auipc	a2,0x3
ffffffffc020384e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203852:	1fb00593          	li	a1,507
ffffffffc0203856:	00003517          	auipc	a0,0x3
ffffffffc020385a:	1f250513          	addi	a0,a0,498 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc020385e:	9c1fc0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc0203862:	00003617          	auipc	a2,0x3
ffffffffc0203866:	a3e60613          	addi	a2,a2,-1474 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc020386a:	07300593          	li	a1,115
ffffffffc020386e:	00003517          	auipc	a0,0x3
ffffffffc0203872:	9f250513          	addi	a0,a0,-1550 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0203876:	9a9fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020387a:	00003697          	auipc	a3,0x3
ffffffffc020387e:	58668693          	addi	a3,a3,1414 # ffffffffc0206e00 <default_pmm_manager+0x3f0>
ffffffffc0203882:	00003617          	auipc	a2,0x3
ffffffffc0203886:	ad660613          	addi	a2,a2,-1322 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020388a:	22300593          	li	a1,547
ffffffffc020388e:	00003517          	auipc	a0,0x3
ffffffffc0203892:	1ba50513          	addi	a0,a0,442 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203896:	989fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020389a:	00003697          	auipc	a3,0x3
ffffffffc020389e:	51e68693          	addi	a3,a3,1310 # ffffffffc0206db8 <default_pmm_manager+0x3a8>
ffffffffc02038a2:	00003617          	auipc	a2,0x3
ffffffffc02038a6:	ab660613          	addi	a2,a2,-1354 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02038aa:	22100593          	li	a1,545
ffffffffc02038ae:	00003517          	auipc	a0,0x3
ffffffffc02038b2:	19a50513          	addi	a0,a0,410 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02038b6:	969fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02038ba:	00003697          	auipc	a3,0x3
ffffffffc02038be:	52e68693          	addi	a3,a3,1326 # ffffffffc0206de8 <default_pmm_manager+0x3d8>
ffffffffc02038c2:	00003617          	auipc	a2,0x3
ffffffffc02038c6:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02038ca:	22000593          	li	a1,544
ffffffffc02038ce:	00003517          	auipc	a0,0x3
ffffffffc02038d2:	17a50513          	addi	a0,a0,378 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02038d6:	949fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02038da:	00003697          	auipc	a3,0x3
ffffffffc02038de:	5f668693          	addi	a3,a3,1526 # ffffffffc0206ed0 <default_pmm_manager+0x4c0>
ffffffffc02038e2:	00003617          	auipc	a2,0x3
ffffffffc02038e6:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02038ea:	23e00593          	li	a1,574
ffffffffc02038ee:	00003517          	auipc	a0,0x3
ffffffffc02038f2:	15a50513          	addi	a0,a0,346 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02038f6:	929fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02038fa:	00003697          	auipc	a3,0x3
ffffffffc02038fe:	53668693          	addi	a3,a3,1334 # ffffffffc0206e30 <default_pmm_manager+0x420>
ffffffffc0203902:	00003617          	auipc	a2,0x3
ffffffffc0203906:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020390a:	22b00593          	li	a1,555
ffffffffc020390e:	00003517          	auipc	a0,0x3
ffffffffc0203912:	13a50513          	addi	a0,a0,314 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203916:	909fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p) == 1);
ffffffffc020391a:	00003697          	auipc	a3,0x3
ffffffffc020391e:	60e68693          	addi	a3,a3,1550 # ffffffffc0206f28 <default_pmm_manager+0x518>
ffffffffc0203922:	00003617          	auipc	a2,0x3
ffffffffc0203926:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020392a:	24300593          	li	a1,579
ffffffffc020392e:	00003517          	auipc	a0,0x3
ffffffffc0203932:	11a50513          	addi	a0,a0,282 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203936:	8e9fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020393a:	00003697          	auipc	a3,0x3
ffffffffc020393e:	5ae68693          	addi	a3,a3,1454 # ffffffffc0206ee8 <default_pmm_manager+0x4d8>
ffffffffc0203942:	00003617          	auipc	a2,0x3
ffffffffc0203946:	a1660613          	addi	a2,a2,-1514 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020394a:	24200593          	li	a1,578
ffffffffc020394e:	00003517          	auipc	a0,0x3
ffffffffc0203952:	0fa50513          	addi	a0,a0,250 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203956:	8c9fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020395a:	00003697          	auipc	a3,0x3
ffffffffc020395e:	45e68693          	addi	a3,a3,1118 # ffffffffc0206db8 <default_pmm_manager+0x3a8>
ffffffffc0203962:	00003617          	auipc	a2,0x3
ffffffffc0203966:	9f660613          	addi	a2,a2,-1546 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020396a:	21d00593          	li	a1,541
ffffffffc020396e:	00003517          	auipc	a0,0x3
ffffffffc0203972:	0da50513          	addi	a0,a0,218 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203976:	8a9fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020397a:	00003697          	auipc	a3,0x3
ffffffffc020397e:	2de68693          	addi	a3,a3,734 # ffffffffc0206c58 <default_pmm_manager+0x248>
ffffffffc0203982:	00003617          	auipc	a2,0x3
ffffffffc0203986:	9d660613          	addi	a2,a2,-1578 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020398a:	21c00593          	li	a1,540
ffffffffc020398e:	00003517          	auipc	a0,0x3
ffffffffc0203992:	0ba50513          	addi	a0,a0,186 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203996:	889fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020399a:	00003697          	auipc	a3,0x3
ffffffffc020399e:	43668693          	addi	a3,a3,1078 # ffffffffc0206dd0 <default_pmm_manager+0x3c0>
ffffffffc02039a2:	00003617          	auipc	a2,0x3
ffffffffc02039a6:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02039aa:	21900593          	li	a1,537
ffffffffc02039ae:	00003517          	auipc	a0,0x3
ffffffffc02039b2:	09a50513          	addi	a0,a0,154 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02039b6:	869fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02039ba:	00003697          	auipc	a3,0x3
ffffffffc02039be:	28668693          	addi	a3,a3,646 # ffffffffc0206c40 <default_pmm_manager+0x230>
ffffffffc02039c2:	00003617          	auipc	a2,0x3
ffffffffc02039c6:	99660613          	addi	a2,a2,-1642 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02039ca:	21800593          	li	a1,536
ffffffffc02039ce:	00003517          	auipc	a0,0x3
ffffffffc02039d2:	07a50513          	addi	a0,a0,122 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02039d6:	849fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02039da:	00003697          	auipc	a3,0x3
ffffffffc02039de:	30668693          	addi	a3,a3,774 # ffffffffc0206ce0 <default_pmm_manager+0x2d0>
ffffffffc02039e2:	00003617          	auipc	a2,0x3
ffffffffc02039e6:	97660613          	addi	a2,a2,-1674 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02039ea:	21700593          	li	a1,535
ffffffffc02039ee:	00003517          	auipc	a0,0x3
ffffffffc02039f2:	05a50513          	addi	a0,a0,90 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc02039f6:	829fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02039fa:	00003697          	auipc	a3,0x3
ffffffffc02039fe:	3be68693          	addi	a3,a3,958 # ffffffffc0206db8 <default_pmm_manager+0x3a8>
ffffffffc0203a02:	00003617          	auipc	a2,0x3
ffffffffc0203a06:	95660613          	addi	a2,a2,-1706 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203a0a:	21600593          	li	a1,534
ffffffffc0203a0e:	00003517          	auipc	a0,0x3
ffffffffc0203a12:	03a50513          	addi	a0,a0,58 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203a16:	809fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203a1a:	00003697          	auipc	a3,0x3
ffffffffc0203a1e:	38668693          	addi	a3,a3,902 # ffffffffc0206da0 <default_pmm_manager+0x390>
ffffffffc0203a22:	00003617          	auipc	a2,0x3
ffffffffc0203a26:	93660613          	addi	a2,a2,-1738 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203a2a:	21500593          	li	a1,533
ffffffffc0203a2e:	00003517          	auipc	a0,0x3
ffffffffc0203a32:	01a50513          	addi	a0,a0,26 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203a36:	fe8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203a3a:	00003697          	auipc	a3,0x3
ffffffffc0203a3e:	33668693          	addi	a3,a3,822 # ffffffffc0206d70 <default_pmm_manager+0x360>
ffffffffc0203a42:	00003617          	auipc	a2,0x3
ffffffffc0203a46:	91660613          	addi	a2,a2,-1770 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203a4a:	21400593          	li	a1,532
ffffffffc0203a4e:	00003517          	auipc	a0,0x3
ffffffffc0203a52:	ffa50513          	addi	a0,a0,-6 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203a56:	fc8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203a5a:	00003697          	auipc	a3,0x3
ffffffffc0203a5e:	2fe68693          	addi	a3,a3,766 # ffffffffc0206d58 <default_pmm_manager+0x348>
ffffffffc0203a62:	00003617          	auipc	a2,0x3
ffffffffc0203a66:	8f660613          	addi	a2,a2,-1802 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203a6a:	21200593          	li	a1,530
ffffffffc0203a6e:	00003517          	auipc	a0,0x3
ffffffffc0203a72:	fda50513          	addi	a0,a0,-38 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203a76:	fa8fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203a7a:	00003697          	auipc	a3,0x3
ffffffffc0203a7e:	2be68693          	addi	a3,a3,702 # ffffffffc0206d38 <default_pmm_manager+0x328>
ffffffffc0203a82:	00003617          	auipc	a2,0x3
ffffffffc0203a86:	8d660613          	addi	a2,a2,-1834 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203a8a:	21100593          	li	a1,529
ffffffffc0203a8e:	00003517          	auipc	a0,0x3
ffffffffc0203a92:	fba50513          	addi	a0,a0,-70 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203a96:	f88fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203a9a:	00003697          	auipc	a3,0x3
ffffffffc0203a9e:	28e68693          	addi	a3,a3,654 # ffffffffc0206d28 <default_pmm_manager+0x318>
ffffffffc0203aa2:	00003617          	auipc	a2,0x3
ffffffffc0203aa6:	8b660613          	addi	a2,a2,-1866 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203aaa:	21000593          	li	a1,528
ffffffffc0203aae:	00003517          	auipc	a0,0x3
ffffffffc0203ab2:	f9a50513          	addi	a0,a0,-102 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203ab6:	f68fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203aba:	00003697          	auipc	a3,0x3
ffffffffc0203abe:	25e68693          	addi	a3,a3,606 # ffffffffc0206d18 <default_pmm_manager+0x308>
ffffffffc0203ac2:	00003617          	auipc	a2,0x3
ffffffffc0203ac6:	89660613          	addi	a2,a2,-1898 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203aca:	20f00593          	li	a1,527
ffffffffc0203ace:	00003517          	auipc	a0,0x3
ffffffffc0203ad2:	f7a50513          	addi	a0,a0,-134 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203ad6:	f48fc0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("DTB memory info not available");
ffffffffc0203ada:	00003617          	auipc	a2,0x3
ffffffffc0203ade:	fde60613          	addi	a2,a2,-34 # ffffffffc0206ab8 <default_pmm_manager+0xa8>
ffffffffc0203ae2:	06500593          	li	a1,101
ffffffffc0203ae6:	00003517          	auipc	a0,0x3
ffffffffc0203aea:	f6250513          	addi	a0,a0,-158 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203aee:	f30fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203af2:	00003697          	auipc	a3,0x3
ffffffffc0203af6:	33e68693          	addi	a3,a3,830 # ffffffffc0206e30 <default_pmm_manager+0x420>
ffffffffc0203afa:	00003617          	auipc	a2,0x3
ffffffffc0203afe:	85e60613          	addi	a2,a2,-1954 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203b02:	25500593          	li	a1,597
ffffffffc0203b06:	00003517          	auipc	a0,0x3
ffffffffc0203b0a:	f4250513          	addi	a0,a0,-190 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203b0e:	f10fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203b12:	00003697          	auipc	a3,0x3
ffffffffc0203b16:	1ce68693          	addi	a3,a3,462 # ffffffffc0206ce0 <default_pmm_manager+0x2d0>
ffffffffc0203b1a:	00003617          	auipc	a2,0x3
ffffffffc0203b1e:	83e60613          	addi	a2,a2,-1986 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203b22:	20e00593          	li	a1,526
ffffffffc0203b26:	00003517          	auipc	a0,0x3
ffffffffc0203b2a:	f2250513          	addi	a0,a0,-222 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203b2e:	ef0fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203b32:	00003697          	auipc	a3,0x3
ffffffffc0203b36:	16e68693          	addi	a3,a3,366 # ffffffffc0206ca0 <default_pmm_manager+0x290>
ffffffffc0203b3a:	00003617          	auipc	a2,0x3
ffffffffc0203b3e:	81e60613          	addi	a2,a2,-2018 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203b42:	20d00593          	li	a1,525
ffffffffc0203b46:	00003517          	auipc	a0,0x3
ffffffffc0203b4a:	f0250513          	addi	a0,a0,-254 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203b4e:	ed0fc0ef          	jal	ra,ffffffffc020021e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203b52:	86d6                	mv	a3,s5
ffffffffc0203b54:	00002617          	auipc	a2,0x2
ffffffffc0203b58:	74c60613          	addi	a2,a2,1868 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0203b5c:	20900593          	li	a1,521
ffffffffc0203b60:	00003517          	auipc	a0,0x3
ffffffffc0203b64:	ee850513          	addi	a0,a0,-280 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203b68:	eb6fc0ef          	jal	ra,ffffffffc020021e <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203b6c:	00002617          	auipc	a2,0x2
ffffffffc0203b70:	73460613          	addi	a2,a2,1844 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0203b74:	20800593          	li	a1,520
ffffffffc0203b78:	00003517          	auipc	a0,0x3
ffffffffc0203b7c:	ed050513          	addi	a0,a0,-304 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203b80:	e9efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203b84:	00003697          	auipc	a3,0x3
ffffffffc0203b88:	0d468693          	addi	a3,a3,212 # ffffffffc0206c58 <default_pmm_manager+0x248>
ffffffffc0203b8c:	00002617          	auipc	a2,0x2
ffffffffc0203b90:	7cc60613          	addi	a2,a2,1996 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203b94:	20600593          	li	a1,518
ffffffffc0203b98:	00003517          	auipc	a0,0x3
ffffffffc0203b9c:	eb050513          	addi	a0,a0,-336 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203ba0:	e7efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203ba4:	00003697          	auipc	a3,0x3
ffffffffc0203ba8:	09c68693          	addi	a3,a3,156 # ffffffffc0206c40 <default_pmm_manager+0x230>
ffffffffc0203bac:	00002617          	auipc	a2,0x2
ffffffffc0203bb0:	7ac60613          	addi	a2,a2,1964 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203bb4:	20500593          	li	a1,517
ffffffffc0203bb8:	00003517          	auipc	a0,0x3
ffffffffc0203bbc:	e9050513          	addi	a0,a0,-368 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203bc0:	e5efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203bc4:	00003697          	auipc	a3,0x3
ffffffffc0203bc8:	42c68693          	addi	a3,a3,1068 # ffffffffc0206ff0 <default_pmm_manager+0x5e0>
ffffffffc0203bcc:	00002617          	auipc	a2,0x2
ffffffffc0203bd0:	78c60613          	addi	a2,a2,1932 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203bd4:	24c00593          	li	a1,588
ffffffffc0203bd8:	00003517          	auipc	a0,0x3
ffffffffc0203bdc:	e7050513          	addi	a0,a0,-400 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203be0:	e3efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203be4:	00003697          	auipc	a3,0x3
ffffffffc0203be8:	3d468693          	addi	a3,a3,980 # ffffffffc0206fb8 <default_pmm_manager+0x5a8>
ffffffffc0203bec:	00002617          	auipc	a2,0x2
ffffffffc0203bf0:	76c60613          	addi	a2,a2,1900 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203bf4:	24900593          	li	a1,585
ffffffffc0203bf8:	00003517          	auipc	a0,0x3
ffffffffc0203bfc:	e5050513          	addi	a0,a0,-432 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203c00:	e1efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c04:	00003697          	auipc	a3,0x3
ffffffffc0203c08:	38468693          	addi	a3,a3,900 # ffffffffc0206f88 <default_pmm_manager+0x578>
ffffffffc0203c0c:	00002617          	auipc	a2,0x2
ffffffffc0203c10:	74c60613          	addi	a2,a2,1868 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203c14:	24500593          	li	a1,581
ffffffffc0203c18:	00003517          	auipc	a0,0x3
ffffffffc0203c1c:	e3050513          	addi	a0,a0,-464 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203c20:	dfefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203c24:	00003697          	auipc	a3,0x3
ffffffffc0203c28:	31c68693          	addi	a3,a3,796 # ffffffffc0206f40 <default_pmm_manager+0x530>
ffffffffc0203c2c:	00002617          	auipc	a2,0x2
ffffffffc0203c30:	72c60613          	addi	a2,a2,1836 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203c34:	24400593          	li	a1,580
ffffffffc0203c38:	00003517          	auipc	a0,0x3
ffffffffc0203c3c:	e1050513          	addi	a0,a0,-496 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203c40:	ddefc0ef          	jal	ra,ffffffffc020021e <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203c44:	00003617          	auipc	a2,0x3
ffffffffc0203c48:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206640 <commands+0xb98>
ffffffffc0203c4c:	0c900593          	li	a1,201
ffffffffc0203c50:	00003517          	auipc	a0,0x3
ffffffffc0203c54:	df850513          	addi	a0,a0,-520 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203c58:	dc6fc0ef          	jal	ra,ffffffffc020021e <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203c5c:	00003617          	auipc	a2,0x3
ffffffffc0203c60:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206640 <commands+0xb98>
ffffffffc0203c64:	08100593          	li	a1,129
ffffffffc0203c68:	00003517          	auipc	a0,0x3
ffffffffc0203c6c:	de050513          	addi	a0,a0,-544 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203c70:	daefc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203c74:	00003697          	auipc	a3,0x3
ffffffffc0203c78:	f9c68693          	addi	a3,a3,-100 # ffffffffc0206c10 <default_pmm_manager+0x200>
ffffffffc0203c7c:	00002617          	auipc	a2,0x2
ffffffffc0203c80:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203c84:	20400593          	li	a1,516
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	dc050513          	addi	a0,a0,-576 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203c90:	d8efc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203c94:	00003697          	auipc	a3,0x3
ffffffffc0203c98:	f4c68693          	addi	a3,a3,-180 # ffffffffc0206be0 <default_pmm_manager+0x1d0>
ffffffffc0203c9c:	00002617          	auipc	a2,0x2
ffffffffc0203ca0:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203ca4:	20100593          	li	a1,513
ffffffffc0203ca8:	00003517          	auipc	a0,0x3
ffffffffc0203cac:	da050513          	addi	a0,a0,-608 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203cb0:	d6efc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203cb4 <copy_range>:
{
ffffffffc0203cb4:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cb6:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203cba:	ec86                	sd	ra,88(sp)
ffffffffc0203cbc:	e8a2                	sd	s0,80(sp)
ffffffffc0203cbe:	e4a6                	sd	s1,72(sp)
ffffffffc0203cc0:	e0ca                	sd	s2,64(sp)
ffffffffc0203cc2:	fc4e                	sd	s3,56(sp)
ffffffffc0203cc4:	f852                	sd	s4,48(sp)
ffffffffc0203cc6:	f456                	sd	s5,40(sp)
ffffffffc0203cc8:	f05a                	sd	s6,32(sp)
ffffffffc0203cca:	ec5e                	sd	s7,24(sp)
ffffffffc0203ccc:	e862                	sd	s8,16(sp)
ffffffffc0203cce:	e466                	sd	s9,8(sp)
ffffffffc0203cd0:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cd2:	17d2                	slli	a5,a5,0x34
ffffffffc0203cd4:	10079f63          	bnez	a5,ffffffffc0203df2 <copy_range+0x13e>
    assert(USER_ACCESS(start, end));
ffffffffc0203cd8:	002007b7          	lui	a5,0x200
ffffffffc0203cdc:	8432                	mv	s0,a2
ffffffffc0203cde:	0ef66a63          	bltu	a2,a5,ffffffffc0203dd2 <copy_range+0x11e>
ffffffffc0203ce2:	8936                	mv	s2,a3
ffffffffc0203ce4:	0ed67763          	bgeu	a2,a3,ffffffffc0203dd2 <copy_range+0x11e>
ffffffffc0203ce8:	4785                	li	a5,1
ffffffffc0203cea:	07fe                	slli	a5,a5,0x1f
ffffffffc0203cec:	0ed7e363          	bltu	a5,a3,ffffffffc0203dd2 <copy_range+0x11e>
ffffffffc0203cf0:	8aaa                	mv	s5,a0
ffffffffc0203cf2:	89ae                	mv	s3,a1
    if (PPN(pa) >= npage)
ffffffffc0203cf4:	000b1c17          	auipc	s8,0xb1
ffffffffc0203cf8:	41cc0c13          	addi	s8,s8,1052 # ffffffffc02b5110 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203cfc:	000b1b97          	auipc	s7,0xb1
ffffffffc0203d00:	41cb8b93          	addi	s7,s7,1052 # ffffffffc02b5118 <pages>
ffffffffc0203d04:	fff80b37          	lui	s6,0xfff80
        start += PGSIZE;
ffffffffc0203d08:	6a05                	lui	s4,0x1
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203d0a:	00200d37          	lui	s10,0x200
ffffffffc0203d0e:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203d12:	4601                	li	a2,0
ffffffffc0203d14:	85a2                	mv	a1,s0
ffffffffc0203d16:	854e                	mv	a0,s3
ffffffffc0203d18:	b77fe0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc0203d1c:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc0203d1e:	c935                	beqz	a0,ffffffffc0203d92 <copy_range+0xde>
        if (*ptep & PTE_V)
ffffffffc0203d20:	611c                	ld	a5,0(a0)
ffffffffc0203d22:	8b85                	andi	a5,a5,1
ffffffffc0203d24:	e39d                	bnez	a5,ffffffffc0203d4a <copy_range+0x96>
        start += PGSIZE;
ffffffffc0203d26:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203d28:	ff2465e3          	bltu	s0,s2,ffffffffc0203d12 <copy_range+0x5e>
    return 0;
ffffffffc0203d2c:	4501                	li	a0,0
}
ffffffffc0203d2e:	60e6                	ld	ra,88(sp)
ffffffffc0203d30:	6446                	ld	s0,80(sp)
ffffffffc0203d32:	64a6                	ld	s1,72(sp)
ffffffffc0203d34:	6906                	ld	s2,64(sp)
ffffffffc0203d36:	79e2                	ld	s3,56(sp)
ffffffffc0203d38:	7a42                	ld	s4,48(sp)
ffffffffc0203d3a:	7aa2                	ld	s5,40(sp)
ffffffffc0203d3c:	7b02                	ld	s6,32(sp)
ffffffffc0203d3e:	6be2                	ld	s7,24(sp)
ffffffffc0203d40:	6c42                	ld	s8,16(sp)
ffffffffc0203d42:	6ca2                	ld	s9,8(sp)
ffffffffc0203d44:	6d02                	ld	s10,0(sp)
ffffffffc0203d46:	6125                	addi	sp,sp,96
ffffffffc0203d48:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203d4a:	4605                	li	a2,1
ffffffffc0203d4c:	85a2                	mv	a1,s0
ffffffffc0203d4e:	8556                	mv	a0,s5
ffffffffc0203d50:	b3ffe0ef          	jal	ra,ffffffffc020288e <get_pte>
ffffffffc0203d54:	c12d                	beqz	a0,ffffffffc0203db6 <copy_range+0x102>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203d56:	6098                	ld	a4,0(s1)
    if (!(pte & PTE_V))
ffffffffc0203d58:	00177793          	andi	a5,a4,1
ffffffffc0203d5c:	0007069b          	sext.w	a3,a4
ffffffffc0203d60:	cfa9                	beqz	a5,ffffffffc0203dba <copy_range+0x106>
    if (PPN(pa) >= npage)
ffffffffc0203d62:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d66:	00271793          	slli	a5,a4,0x2
ffffffffc0203d6a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203d6c:	0ac7f363          	bgeu	a5,a2,ffffffffc0203e12 <copy_range+0x15e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d70:	000bb583          	ld	a1,0(s7)
ffffffffc0203d74:	97da                	add	a5,a5,s6
ffffffffc0203d76:	079a                	slli	a5,a5,0x6
            if (perm & PTE_W)
ffffffffc0203d78:	0046f613          	andi	a2,a3,4
ffffffffc0203d7c:	95be                	add	a1,a1,a5
ffffffffc0203d7e:	e20d                	bnez	a2,ffffffffc0203da0 <copy_range+0xec>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203d80:	21f6f693          	andi	a3,a3,543
            int ret = page_insert(to, page, start, perm);
ffffffffc0203d84:	8622                	mv	a2,s0
ffffffffc0203d86:	8556                	mv	a0,s5
ffffffffc0203d88:	9f6ff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
            if (ret != 0)
ffffffffc0203d8c:	f14d                	bnez	a0,ffffffffc0203d2e <copy_range+0x7a>
        start += PGSIZE;
ffffffffc0203d8e:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203d90:	bf61                	j	ffffffffc0203d28 <copy_range+0x74>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203d92:	946a                	add	s0,s0,s10
ffffffffc0203d94:	01947433          	and	s0,s0,s9
    } while (start != 0 && start < end);
ffffffffc0203d98:	d851                	beqz	s0,ffffffffc0203d2c <copy_range+0x78>
ffffffffc0203d9a:	f7246ce3          	bltu	s0,s2,ffffffffc0203d12 <copy_range+0x5e>
ffffffffc0203d9e:	b779                	j	ffffffffc0203d2c <copy_range+0x78>
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203da0:	dfb77713          	andi	a4,a4,-517
ffffffffc0203da4:	20076713          	ori	a4,a4,512
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0203da8:	8aed                	andi	a3,a3,27
ffffffffc0203daa:	2006e693          	ori	a3,a3,512
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203dae:	e098                	sd	a4,0(s1)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203db0:	12040073          	sfence.vma	s0
}
ffffffffc0203db4:	bfc1                	j	ffffffffc0203d84 <copy_range+0xd0>
                return -E_NO_MEM;
ffffffffc0203db6:	5571                	li	a0,-4
ffffffffc0203db8:	bf9d                	j	ffffffffc0203d2e <copy_range+0x7a>
        panic("pte2page called with invalid pte");
ffffffffc0203dba:	00002617          	auipc	a2,0x2
ffffffffc0203dbe:	47e60613          	addi	a2,a2,1150 # ffffffffc0206238 <commands+0x790>
ffffffffc0203dc2:	08100593          	li	a1,129
ffffffffc0203dc6:	00002517          	auipc	a0,0x2
ffffffffc0203dca:	49a50513          	addi	a0,a0,1178 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0203dce:	c50fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203dd2:	00003697          	auipc	a3,0x3
ffffffffc0203dd6:	cb668693          	addi	a3,a3,-842 # ffffffffc0206a88 <default_pmm_manager+0x78>
ffffffffc0203dda:	00002617          	auipc	a2,0x2
ffffffffc0203dde:	57e60613          	addi	a2,a2,1406 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203de2:	17c00593          	li	a1,380
ffffffffc0203de6:	00003517          	auipc	a0,0x3
ffffffffc0203dea:	c6250513          	addi	a0,a0,-926 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203dee:	c30fc0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203df2:	00003697          	auipc	a3,0x3
ffffffffc0203df6:	c6668693          	addi	a3,a3,-922 # ffffffffc0206a58 <default_pmm_manager+0x48>
ffffffffc0203dfa:	00002617          	auipc	a2,0x2
ffffffffc0203dfe:	55e60613          	addi	a2,a2,1374 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203e02:	17b00593          	li	a1,379
ffffffffc0203e06:	00003517          	auipc	a0,0x3
ffffffffc0203e0a:	c4250513          	addi	a0,a0,-958 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203e0e:	c10fc0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203e12:	00002617          	auipc	a2,0x2
ffffffffc0203e16:	45e60613          	addi	a2,a2,1118 # ffffffffc0206270 <commands+0x7c8>
ffffffffc0203e1a:	06b00593          	li	a1,107
ffffffffc0203e1e:	00002517          	auipc	a0,0x2
ffffffffc0203e22:	44250513          	addi	a0,a0,1090 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0203e26:	bf8fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203e2a <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e2a:	12058073          	sfence.vma	a1
}
ffffffffc0203e2e:	8082                	ret

ffffffffc0203e30 <pgdir_alloc_page>:
{
ffffffffc0203e30:	7179                	addi	sp,sp,-48
ffffffffc0203e32:	ec26                	sd	s1,24(sp)
ffffffffc0203e34:	e84a                	sd	s2,16(sp)
ffffffffc0203e36:	e052                	sd	s4,0(sp)
ffffffffc0203e38:	f406                	sd	ra,40(sp)
ffffffffc0203e3a:	f022                	sd	s0,32(sp)
ffffffffc0203e3c:	e44e                	sd	s3,8(sp)
ffffffffc0203e3e:	8a2a                	mv	s4,a0
ffffffffc0203e40:	84ae                	mv	s1,a1
ffffffffc0203e42:	8932                	mv	s2,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e44:	100027f3          	csrr	a5,sstatus
ffffffffc0203e48:	8b89                	andi	a5,a5,2
        page = pmm_manager->alloc_pages(n);
ffffffffc0203e4a:	000b1997          	auipc	s3,0xb1
ffffffffc0203e4e:	2d698993          	addi	s3,s3,726 # ffffffffc02b5120 <pmm_manager>
ffffffffc0203e52:	ef8d                	bnez	a5,ffffffffc0203e8c <pgdir_alloc_page+0x5c>
ffffffffc0203e54:	0009b783          	ld	a5,0(s3)
ffffffffc0203e58:	4505                	li	a0,1
ffffffffc0203e5a:	6f9c                	ld	a5,24(a5)
ffffffffc0203e5c:	9782                	jalr	a5
ffffffffc0203e5e:	842a                	mv	s0,a0
    if (page != NULL)
ffffffffc0203e60:	cc09                	beqz	s0,ffffffffc0203e7a <pgdir_alloc_page+0x4a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203e62:	86ca                	mv	a3,s2
ffffffffc0203e64:	8626                	mv	a2,s1
ffffffffc0203e66:	85a2                	mv	a1,s0
ffffffffc0203e68:	8552                	mv	a0,s4
ffffffffc0203e6a:	914ff0ef          	jal	ra,ffffffffc0202f7e <page_insert>
ffffffffc0203e6e:	e915                	bnez	a0,ffffffffc0203ea2 <pgdir_alloc_page+0x72>
        assert(page_ref(page) == 1);
ffffffffc0203e70:	4018                	lw	a4,0(s0)
        page->pra_vaddr = la;
ffffffffc0203e72:	fc04                	sd	s1,56(s0)
        assert(page_ref(page) == 1);
ffffffffc0203e74:	4785                	li	a5,1
ffffffffc0203e76:	04f71e63          	bne	a4,a5,ffffffffc0203ed2 <pgdir_alloc_page+0xa2>
}
ffffffffc0203e7a:	70a2                	ld	ra,40(sp)
ffffffffc0203e7c:	8522                	mv	a0,s0
ffffffffc0203e7e:	7402                	ld	s0,32(sp)
ffffffffc0203e80:	64e2                	ld	s1,24(sp)
ffffffffc0203e82:	6942                	ld	s2,16(sp)
ffffffffc0203e84:	69a2                	ld	s3,8(sp)
ffffffffc0203e86:	6a02                	ld	s4,0(sp)
ffffffffc0203e88:	6145                	addi	sp,sp,48
ffffffffc0203e8a:	8082                	ret
        intr_disable();
ffffffffc0203e8c:	b2ffc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203e90:	0009b783          	ld	a5,0(s3)
ffffffffc0203e94:	4505                	li	a0,1
ffffffffc0203e96:	6f9c                	ld	a5,24(a5)
ffffffffc0203e98:	9782                	jalr	a5
ffffffffc0203e9a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203e9c:	b19fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203ea0:	b7c1                	j	ffffffffc0203e60 <pgdir_alloc_page+0x30>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203ea2:	100027f3          	csrr	a5,sstatus
ffffffffc0203ea6:	8b89                	andi	a5,a5,2
ffffffffc0203ea8:	eb89                	bnez	a5,ffffffffc0203eba <pgdir_alloc_page+0x8a>
        pmm_manager->free_pages(base, n);
ffffffffc0203eaa:	0009b783          	ld	a5,0(s3)
ffffffffc0203eae:	8522                	mv	a0,s0
ffffffffc0203eb0:	4585                	li	a1,1
ffffffffc0203eb2:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0203eb4:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203eb6:	9782                	jalr	a5
    if (flag)
ffffffffc0203eb8:	b7c9                	j	ffffffffc0203e7a <pgdir_alloc_page+0x4a>
        intr_disable();
ffffffffc0203eba:	b01fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
ffffffffc0203ebe:	0009b783          	ld	a5,0(s3)
ffffffffc0203ec2:	8522                	mv	a0,s0
ffffffffc0203ec4:	4585                	li	a1,1
ffffffffc0203ec6:	739c                	ld	a5,32(a5)
            return NULL;
ffffffffc0203ec8:	4401                	li	s0,0
        pmm_manager->free_pages(base, n);
ffffffffc0203eca:	9782                	jalr	a5
        intr_enable();
ffffffffc0203ecc:	ae9fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0203ed0:	b76d                	j	ffffffffc0203e7a <pgdir_alloc_page+0x4a>
        assert(page_ref(page) == 1);
ffffffffc0203ed2:	00003697          	auipc	a3,0x3
ffffffffc0203ed6:	16668693          	addi	a3,a3,358 # ffffffffc0207038 <default_pmm_manager+0x628>
ffffffffc0203eda:	00002617          	auipc	a2,0x2
ffffffffc0203ede:	47e60613          	addi	a2,a2,1150 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0203ee2:	1e200593          	li	a1,482
ffffffffc0203ee6:	00003517          	auipc	a0,0x3
ffffffffc0203eea:	b6250513          	addi	a0,a0,-1182 # ffffffffc0206a48 <default_pmm_manager+0x38>
ffffffffc0203eee:	b30fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0203ef2 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203ef2:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203ef4:	9402                	jalr	s0

	jal do_exit
ffffffffc0203ef6:	67c000ef          	jal	ra,ffffffffc0204572 <do_exit>

ffffffffc0203efa <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203efa:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203efe:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203f02:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203f04:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203f06:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203f0a:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203f0e:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203f12:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203f16:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203f1a:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203f1e:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203f22:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203f26:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203f2a:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203f2e:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203f32:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0203f36:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203f38:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203f3a:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203f3e:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203f42:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0203f46:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203f4a:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203f4e:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203f52:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0203f56:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203f5a:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203f5e:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0203f62:	8082                	ret

ffffffffc0203f64 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203f64:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f66:	10800513          	li	a0,264
{
ffffffffc0203f6a:	e022                	sd	s0,0(sp)
ffffffffc0203f6c:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f6e:	bddfd0ef          	jal	ra,ffffffffc0201b4a <kmalloc>
ffffffffc0203f72:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203f74:	cd21                	beqz	a0,ffffffffc0203fcc <alloc_proc+0x68>
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */

        proc->state = PROC_UNINIT;
ffffffffc0203f76:	57fd                	li	a5,-1
ffffffffc0203f78:	1782                	slli	a5,a5,0x20
ffffffffc0203f7a:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203f7c:	07000613          	li	a2,112
ffffffffc0203f80:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0203f82:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203f86:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203f8a:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203f8e:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0203f92:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203f96:	03050513          	addi	a0,a0,48
ffffffffc0203f9a:	436010ef          	jal	ra,ffffffffc02053d0 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203f9e:	000b1797          	auipc	a5,0xb1
ffffffffc0203fa2:	1627b783          	ld	a5,354(a5) # ffffffffc02b5100 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203fa6:	0a043023          	sd	zero,160(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203faa:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc0203fac:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203fb0:	4641                	li	a2,16
ffffffffc0203fb2:	4581                	li	a1,0
ffffffffc0203fb4:	0b440513          	addi	a0,s0,180
ffffffffc0203fb8:	418010ef          	jal	ra,ffffffffc02053d0 <memset>
        proc->wait_state = 0;
ffffffffc0203fbc:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0203fc0:	10043023          	sd	zero,256(s0)
ffffffffc0203fc4:	0e043c23          	sd	zero,248(s0)
ffffffffc0203fc8:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0203fcc:	60a2                	ld	ra,8(sp)
ffffffffc0203fce:	8522                	mv	a0,s0
ffffffffc0203fd0:	6402                	ld	s0,0(sp)
ffffffffc0203fd2:	0141                	addi	sp,sp,16
ffffffffc0203fd4:	8082                	ret

ffffffffc0203fd6 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203fd6:	000b1797          	auipc	a5,0xb1
ffffffffc0203fda:	15a7b783          	ld	a5,346(a5) # ffffffffc02b5130 <current>
ffffffffc0203fde:	73c8                	ld	a0,160(a5)
ffffffffc0203fe0:	95efd06f          	j	ffffffffc020113e <forkrets>

ffffffffc0203fe4 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203fe4:	000b1797          	auipc	a5,0xb1
ffffffffc0203fe8:	14c7b783          	ld	a5,332(a5) # ffffffffc02b5130 <current>
ffffffffc0203fec:	43cc                	lw	a1,4(a5)
{
ffffffffc0203fee:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0203ff0:	00003617          	auipc	a2,0x3
ffffffffc0203ff4:	06060613          	addi	a2,a2,96 # ffffffffc0207050 <default_pmm_manager+0x640>
ffffffffc0203ff8:	00003517          	auipc	a0,0x3
ffffffffc0203ffc:	06850513          	addi	a0,a0,104 # ffffffffc0207060 <default_pmm_manager+0x650>
{
ffffffffc0204000:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204002:	8defc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0204006:	3fe07797          	auipc	a5,0x3fe07
ffffffffc020400a:	97a78793          	addi	a5,a5,-1670 # a980 <_binary_obj___user_forktest_out_size>
ffffffffc020400e:	e43e                	sd	a5,8(sp)
ffffffffc0204010:	00003517          	auipc	a0,0x3
ffffffffc0204014:	04050513          	addi	a0,a0,64 # ffffffffc0207050 <default_pmm_manager+0x640>
ffffffffc0204018:	00098797          	auipc	a5,0x98
ffffffffc020401c:	52878793          	addi	a5,a5,1320 # ffffffffc029c540 <_binary_obj___user_forktest_out_start>
ffffffffc0204020:	f03e                	sd	a5,32(sp)
ffffffffc0204022:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204024:	e802                	sd	zero,16(sp)
ffffffffc0204026:	308010ef          	jal	ra,ffffffffc020532e <strlen>
ffffffffc020402a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020402c:	4511                	li	a0,4
ffffffffc020402e:	55a2                	lw	a1,40(sp)
ffffffffc0204030:	4662                	lw	a2,24(sp)
ffffffffc0204032:	5682                	lw	a3,32(sp)
ffffffffc0204034:	4722                	lw	a4,8(sp)
ffffffffc0204036:	48a9                	li	a7,10
ffffffffc0204038:	9002                	ebreak
ffffffffc020403a:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020403c:	65c2                	ld	a1,16(sp)
ffffffffc020403e:	00003517          	auipc	a0,0x3
ffffffffc0204042:	04a50513          	addi	a0,a0,74 # ffffffffc0207088 <default_pmm_manager+0x678>
ffffffffc0204046:	89afc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc020404a:	00003617          	auipc	a2,0x3
ffffffffc020404e:	04e60613          	addi	a2,a2,78 # ffffffffc0207098 <default_pmm_manager+0x688>
ffffffffc0204052:	3ae00593          	li	a1,942
ffffffffc0204056:	00003517          	auipc	a0,0x3
ffffffffc020405a:	06250513          	addi	a0,a0,98 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc020405e:	9c0fc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204062 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204062:	6d14                	ld	a3,24(a0)
{
ffffffffc0204064:	1141                	addi	sp,sp,-16
ffffffffc0204066:	e406                	sd	ra,8(sp)
ffffffffc0204068:	c02007b7          	lui	a5,0xc0200
ffffffffc020406c:	02f6ee63          	bltu	a3,a5,ffffffffc02040a8 <put_pgdir+0x46>
ffffffffc0204070:	000b1517          	auipc	a0,0xb1
ffffffffc0204074:	0b853503          	ld	a0,184(a0) # ffffffffc02b5128 <va_pa_offset>
ffffffffc0204078:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage)
ffffffffc020407a:	82b1                	srli	a3,a3,0xc
ffffffffc020407c:	000b1797          	auipc	a5,0xb1
ffffffffc0204080:	0947b783          	ld	a5,148(a5) # ffffffffc02b5110 <npage>
ffffffffc0204084:	02f6fe63          	bgeu	a3,a5,ffffffffc02040c0 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204088:	00004517          	auipc	a0,0x4
ffffffffc020408c:	8c853503          	ld	a0,-1848(a0) # ffffffffc0207950 <nbase>
}
ffffffffc0204090:	60a2                	ld	ra,8(sp)
ffffffffc0204092:	8e89                	sub	a3,a3,a0
ffffffffc0204094:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204096:	000b1517          	auipc	a0,0xb1
ffffffffc020409a:	08253503          	ld	a0,130(a0) # ffffffffc02b5118 <pages>
ffffffffc020409e:	4585                	li	a1,1
ffffffffc02040a0:	9536                	add	a0,a0,a3
}
ffffffffc02040a2:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02040a4:	f70fe06f          	j	ffffffffc0202814 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02040a8:	00002617          	auipc	a2,0x2
ffffffffc02040ac:	59860613          	addi	a2,a2,1432 # ffffffffc0206640 <commands+0xb98>
ffffffffc02040b0:	07900593          	li	a1,121
ffffffffc02040b4:	00002517          	auipc	a0,0x2
ffffffffc02040b8:	1ac50513          	addi	a0,a0,428 # ffffffffc0206260 <commands+0x7b8>
ffffffffc02040bc:	962fc0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02040c0:	00002617          	auipc	a2,0x2
ffffffffc02040c4:	1b060613          	addi	a2,a2,432 # ffffffffc0206270 <commands+0x7c8>
ffffffffc02040c8:	06b00593          	li	a1,107
ffffffffc02040cc:	00002517          	auipc	a0,0x2
ffffffffc02040d0:	19450513          	addi	a0,a0,404 # ffffffffc0206260 <commands+0x7b8>
ffffffffc02040d4:	94afc0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02040d8 <proc_run>:
{
ffffffffc02040d8:	7179                	addi	sp,sp,-48
ffffffffc02040da:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc02040dc:	000b1917          	auipc	s2,0xb1
ffffffffc02040e0:	05490913          	addi	s2,s2,84 # ffffffffc02b5130 <current>
{
ffffffffc02040e4:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc02040e6:	00093483          	ld	s1,0(s2)
{
ffffffffc02040ea:	f406                	sd	ra,40(sp)
ffffffffc02040ec:	e84e                	sd	s3,16(sp)
    if (proc != current)
ffffffffc02040ee:	02a48863          	beq	s1,a0,ffffffffc020411e <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02040f2:	100027f3          	csrr	a5,sstatus
ffffffffc02040f6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02040f8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02040fa:	ef9d                	bnez	a5,ffffffffc0204138 <proc_run+0x60>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc02040fc:	755c                	ld	a5,168(a0)
ffffffffc02040fe:	577d                	li	a4,-1
ffffffffc0204100:	177e                	slli	a4,a4,0x3f
ffffffffc0204102:	83b1                	srli	a5,a5,0xc
            current = proc;
ffffffffc0204104:	00a93023          	sd	a0,0(s2)
ffffffffc0204108:	8fd9                	or	a5,a5,a4
ffffffffc020410a:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc020410e:	03050593          	addi	a1,a0,48
ffffffffc0204112:	03048513          	addi	a0,s1,48 # ffffffffc02b5140 <initproc>
ffffffffc0204116:	de5ff0ef          	jal	ra,ffffffffc0203efa <switch_to>
    if (flag)
ffffffffc020411a:	00099863          	bnez	s3,ffffffffc020412a <proc_run+0x52>
}
ffffffffc020411e:	70a2                	ld	ra,40(sp)
ffffffffc0204120:	7482                	ld	s1,32(sp)
ffffffffc0204122:	6962                	ld	s2,24(sp)
ffffffffc0204124:	69c2                	ld	s3,16(sp)
ffffffffc0204126:	6145                	addi	sp,sp,48
ffffffffc0204128:	8082                	ret
ffffffffc020412a:	70a2                	ld	ra,40(sp)
ffffffffc020412c:	7482                	ld	s1,32(sp)
ffffffffc020412e:	6962                	ld	s2,24(sp)
ffffffffc0204130:	69c2                	ld	s3,16(sp)
ffffffffc0204132:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204134:	881fc06f          	j	ffffffffc02009b4 <intr_enable>
ffffffffc0204138:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020413a:	881fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc020413e:	6522                	ld	a0,8(sp)
ffffffffc0204140:	4985                	li	s3,1
ffffffffc0204142:	bf6d                	j	ffffffffc02040fc <proc_run+0x24>

ffffffffc0204144 <do_fork>:
{
ffffffffc0204144:	7119                	addi	sp,sp,-128
ffffffffc0204146:	f0ca                	sd	s2,96(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0204148:	000b1917          	auipc	s2,0xb1
ffffffffc020414c:	00090913          	mv	s2,s2
ffffffffc0204150:	00092703          	lw	a4,0(s2) # ffffffffc02b5148 <nr_process>
{
ffffffffc0204154:	fc86                	sd	ra,120(sp)
ffffffffc0204156:	f8a2                	sd	s0,112(sp)
ffffffffc0204158:	f4a6                	sd	s1,104(sp)
ffffffffc020415a:	ecce                	sd	s3,88(sp)
ffffffffc020415c:	e8d2                	sd	s4,80(sp)
ffffffffc020415e:	e4d6                	sd	s5,72(sp)
ffffffffc0204160:	e0da                	sd	s6,64(sp)
ffffffffc0204162:	fc5e                	sd	s7,56(sp)
ffffffffc0204164:	f862                	sd	s8,48(sp)
ffffffffc0204166:	f466                	sd	s9,40(sp)
ffffffffc0204168:	f06a                	sd	s10,32(sp)
ffffffffc020416a:	ec6e                	sd	s11,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020416c:	6785                	lui	a5,0x1
ffffffffc020416e:	32f75863          	bge	a4,a5,ffffffffc020449e <do_fork+0x35a>
ffffffffc0204172:	8a2a                	mv	s4,a0
ffffffffc0204174:	89ae                	mv	s3,a1
ffffffffc0204176:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204178:	dedff0ef          	jal	ra,ffffffffc0203f64 <alloc_proc>
ffffffffc020417c:	84aa                	mv	s1,a0
ffffffffc020417e:	30050163          	beqz	a0,ffffffffc0204480 <do_fork+0x33c>
    proc->parent = current;
ffffffffc0204182:	000b1c17          	auipc	s8,0xb1
ffffffffc0204186:	faec0c13          	addi	s8,s8,-82 # ffffffffc02b5130 <current>
ffffffffc020418a:	000c3783          	ld	a5,0(s8)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020418e:	4509                	li	a0,2
    proc->parent = current;
ffffffffc0204190:	f09c                	sd	a5,32(s1)
    current->wait_state = 0;
ffffffffc0204192:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8adc>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204196:	e40fe0ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
    if (page != NULL)
ffffffffc020419a:	2e050063          	beqz	a0,ffffffffc020447a <do_fork+0x336>
    return page - pages + nbase;
ffffffffc020419e:	000b1a97          	auipc	s5,0xb1
ffffffffc02041a2:	f7aa8a93          	addi	s5,s5,-134 # ffffffffc02b5118 <pages>
ffffffffc02041a6:	000ab683          	ld	a3,0(s5)
ffffffffc02041aa:	00003b17          	auipc	s6,0x3
ffffffffc02041ae:	7a6b0b13          	addi	s6,s6,1958 # ffffffffc0207950 <nbase>
ffffffffc02041b2:	000b3783          	ld	a5,0(s6)
ffffffffc02041b6:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02041ba:	000b1b97          	auipc	s7,0xb1
ffffffffc02041be:	f56b8b93          	addi	s7,s7,-170 # ffffffffc02b5110 <npage>
    return page - pages + nbase;
ffffffffc02041c2:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02041c4:	5dfd                	li	s11,-1
ffffffffc02041c6:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02041ca:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02041cc:	00cddd93          	srli	s11,s11,0xc
ffffffffc02041d0:	01b6f633          	and	a2,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02041d4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02041d6:	32e67a63          	bgeu	a2,a4,ffffffffc020450a <do_fork+0x3c6>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02041da:	000c3603          	ld	a2,0(s8)
ffffffffc02041de:	000b1c17          	auipc	s8,0xb1
ffffffffc02041e2:	f4ac0c13          	addi	s8,s8,-182 # ffffffffc02b5128 <va_pa_offset>
ffffffffc02041e6:	000c3703          	ld	a4,0(s8)
ffffffffc02041ea:	02863d03          	ld	s10,40(a2)
ffffffffc02041ee:	e43e                	sd	a5,8(sp)
ffffffffc02041f0:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02041f2:	e894                	sd	a3,16(s1)
    if (oldmm == NULL)
ffffffffc02041f4:	020d0863          	beqz	s10,ffffffffc0204224 <do_fork+0xe0>
    if (clone_flags & CLONE_VM)
ffffffffc02041f8:	100a7a13          	andi	s4,s4,256
ffffffffc02041fc:	1c0a0163          	beqz	s4,ffffffffc02043be <do_fork+0x27a>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204200:	030d2703          	lw	a4,48(s10) # 200030 <_binary_obj___user_exit_out_size+0x1f4ef8>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204204:	018d3783          	ld	a5,24(s10)
ffffffffc0204208:	c02006b7          	lui	a3,0xc0200
ffffffffc020420c:	2705                	addiw	a4,a4,1
ffffffffc020420e:	02ed2823          	sw	a4,48(s10)
    proc->mm = mm;
ffffffffc0204212:	03a4b423          	sd	s10,40(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204216:	2cd7e163          	bltu	a5,a3,ffffffffc02044d8 <do_fork+0x394>
ffffffffc020421a:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020421e:	6894                	ld	a3,16(s1)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204220:	8f99                	sub	a5,a5,a4
ffffffffc0204222:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204224:	6789                	lui	a5,0x2
ffffffffc0204226:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7ce8>
ffffffffc020422a:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020422c:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020422e:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204230:	87b6                	mv	a5,a3
ffffffffc0204232:	12040893          	addi	a7,s0,288
ffffffffc0204236:	00063803          	ld	a6,0(a2)
ffffffffc020423a:	6608                	ld	a0,8(a2)
ffffffffc020423c:	6a0c                	ld	a1,16(a2)
ffffffffc020423e:	6e18                	ld	a4,24(a2)
ffffffffc0204240:	0107b023          	sd	a6,0(a5)
ffffffffc0204244:	e788                	sd	a0,8(a5)
ffffffffc0204246:	eb8c                	sd	a1,16(a5)
ffffffffc0204248:	ef98                	sd	a4,24(a5)
ffffffffc020424a:	02060613          	addi	a2,a2,32
ffffffffc020424e:	02078793          	addi	a5,a5,32
ffffffffc0204252:	ff1612e3          	bne	a2,a7,ffffffffc0204236 <do_fork+0xf2>
    proc->tf->gpr.a0 = 0;
ffffffffc0204256:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020425a:	12098f63          	beqz	s3,ffffffffc0204398 <do_fork+0x254>
ffffffffc020425e:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204262:	00000797          	auipc	a5,0x0
ffffffffc0204266:	d7478793          	addi	a5,a5,-652 # ffffffffc0203fd6 <forkret>
ffffffffc020426a:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020426c:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020426e:	100027f3          	csrr	a5,sstatus
ffffffffc0204272:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204274:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204276:	14079063          	bnez	a5,ffffffffc02043b6 <do_fork+0x272>
    if (++last_pid >= MAX_PID)
ffffffffc020427a:	000ad817          	auipc	a6,0xad
ffffffffc020427e:	a1e80813          	addi	a6,a6,-1506 # ffffffffc02b0c98 <last_pid.1>
ffffffffc0204282:	00082783          	lw	a5,0(a6)
ffffffffc0204286:	6709                	lui	a4,0x2
ffffffffc0204288:	0017851b          	addiw	a0,a5,1
ffffffffc020428c:	00a82023          	sw	a0,0(a6)
ffffffffc0204290:	08e55d63          	bge	a0,a4,ffffffffc020432a <do_fork+0x1e6>
    if (last_pid >= next_safe)
ffffffffc0204294:	000ad317          	auipc	t1,0xad
ffffffffc0204298:	a0830313          	addi	t1,t1,-1528 # ffffffffc02b0c9c <next_safe.0>
ffffffffc020429c:	00032783          	lw	a5,0(t1)
ffffffffc02042a0:	000b1417          	auipc	s0,0xb1
ffffffffc02042a4:	e1840413          	addi	s0,s0,-488 # ffffffffc02b50b8 <proc_list>
ffffffffc02042a8:	08f55963          	bge	a0,a5,ffffffffc020433a <do_fork+0x1f6>
        proc->pid = get_pid();
ffffffffc02042ac:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02042ae:	45a9                	li	a1,10
ffffffffc02042b0:	2501                	sext.w	a0,a0
ffffffffc02042b2:	536010ef          	jal	ra,ffffffffc02057e8 <hash32>
ffffffffc02042b6:	02051793          	slli	a5,a0,0x20
ffffffffc02042ba:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02042be:	000ad797          	auipc	a5,0xad
ffffffffc02042c2:	dfa78793          	addi	a5,a5,-518 # ffffffffc02b10b8 <hash_list>
ffffffffc02042c6:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02042c8:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02042ca:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02042cc:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc02042d0:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02042d2:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc02042d4:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02042d6:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02042d8:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc02042dc:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc02042de:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc02042e0:	e21c                	sd	a5,0(a2)
ffffffffc02042e2:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc02042e4:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc02042e6:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc02042e8:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02042ec:	10e4b023          	sd	a4,256(s1)
ffffffffc02042f0:	c311                	beqz	a4,ffffffffc02042f4 <do_fork+0x1b0>
        proc->optr->yptr = proc;
ffffffffc02042f2:	ff64                	sd	s1,248(a4)
    nr_process++;
ffffffffc02042f4:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc02042f8:	fae4                	sd	s1,240(a3)
    nr_process++;
ffffffffc02042fa:	2785                	addiw	a5,a5,1
ffffffffc02042fc:	00f92023          	sw	a5,0(s2)
    if (flag)
ffffffffc0204300:	18099263          	bnez	s3,ffffffffc0204484 <do_fork+0x340>
    wakeup_proc(proc);
ffffffffc0204304:	8526                	mv	a0,s1
ffffffffc0204306:	63d000ef          	jal	ra,ffffffffc0205142 <wakeup_proc>
    ret = proc->pid;
ffffffffc020430a:	40c8                	lw	a0,4(s1)
}
ffffffffc020430c:	70e6                	ld	ra,120(sp)
ffffffffc020430e:	7446                	ld	s0,112(sp)
ffffffffc0204310:	74a6                	ld	s1,104(sp)
ffffffffc0204312:	7906                	ld	s2,96(sp)
ffffffffc0204314:	69e6                	ld	s3,88(sp)
ffffffffc0204316:	6a46                	ld	s4,80(sp)
ffffffffc0204318:	6aa6                	ld	s5,72(sp)
ffffffffc020431a:	6b06                	ld	s6,64(sp)
ffffffffc020431c:	7be2                	ld	s7,56(sp)
ffffffffc020431e:	7c42                	ld	s8,48(sp)
ffffffffc0204320:	7ca2                	ld	s9,40(sp)
ffffffffc0204322:	7d02                	ld	s10,32(sp)
ffffffffc0204324:	6de2                	ld	s11,24(sp)
ffffffffc0204326:	6109                	addi	sp,sp,128
ffffffffc0204328:	8082                	ret
        last_pid = 1;
ffffffffc020432a:	4785                	li	a5,1
ffffffffc020432c:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0204330:	4505                	li	a0,1
ffffffffc0204332:	000ad317          	auipc	t1,0xad
ffffffffc0204336:	96a30313          	addi	t1,t1,-1686 # ffffffffc02b0c9c <next_safe.0>
    return listelm->next;
ffffffffc020433a:	000b1417          	auipc	s0,0xb1
ffffffffc020433e:	d7e40413          	addi	s0,s0,-642 # ffffffffc02b50b8 <proc_list>
ffffffffc0204342:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc0204346:	6789                	lui	a5,0x2
ffffffffc0204348:	00f32023          	sw	a5,0(t1)
ffffffffc020434c:	86aa                	mv	a3,a0
ffffffffc020434e:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0204350:	6e89                	lui	t4,0x2
ffffffffc0204352:	148e0163          	beq	t3,s0,ffffffffc0204494 <do_fork+0x350>
ffffffffc0204356:	88ae                	mv	a7,a1
ffffffffc0204358:	87f2                	mv	a5,t3
ffffffffc020435a:	6609                	lui	a2,0x2
ffffffffc020435c:	a811                	j	ffffffffc0204370 <do_fork+0x22c>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020435e:	00e6d663          	bge	a3,a4,ffffffffc020436a <do_fork+0x226>
ffffffffc0204362:	00c75463          	bge	a4,a2,ffffffffc020436a <do_fork+0x226>
ffffffffc0204366:	863a                	mv	a2,a4
ffffffffc0204368:	4885                	li	a7,1
ffffffffc020436a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020436c:	00878d63          	beq	a5,s0,ffffffffc0204386 <do_fork+0x242>
            if (proc->pid == last_pid)
ffffffffc0204370:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c8c>
ffffffffc0204374:	fed715e3          	bne	a4,a3,ffffffffc020435e <do_fork+0x21a>
                if (++last_pid >= next_safe)
ffffffffc0204378:	2685                	addiw	a3,a3,1
ffffffffc020437a:	10c6d863          	bge	a3,a2,ffffffffc020448a <do_fork+0x346>
ffffffffc020437e:	679c                	ld	a5,8(a5)
ffffffffc0204380:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204382:	fe8797e3          	bne	a5,s0,ffffffffc0204370 <do_fork+0x22c>
ffffffffc0204386:	c581                	beqz	a1,ffffffffc020438e <do_fork+0x24a>
ffffffffc0204388:	00d82023          	sw	a3,0(a6)
ffffffffc020438c:	8536                	mv	a0,a3
ffffffffc020438e:	f0088fe3          	beqz	a7,ffffffffc02042ac <do_fork+0x168>
ffffffffc0204392:	00c32023          	sw	a2,0(t1)
ffffffffc0204396:	bf19                	j	ffffffffc02042ac <do_fork+0x168>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204398:	89b6                	mv	s3,a3
ffffffffc020439a:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020439e:	00000797          	auipc	a5,0x0
ffffffffc02043a2:	c3878793          	addi	a5,a5,-968 # ffffffffc0203fd6 <forkret>
ffffffffc02043a6:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02043a8:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02043aa:	100027f3          	csrr	a5,sstatus
ffffffffc02043ae:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02043b0:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02043b2:	ec0784e3          	beqz	a5,ffffffffc020427a <do_fork+0x136>
        intr_disable();
ffffffffc02043b6:	e04fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc02043ba:	4985                	li	s3,1
ffffffffc02043bc:	bd7d                	j	ffffffffc020427a <do_fork+0x136>
    if ((mm = mm_create()) == NULL)
ffffffffc02043be:	e51fc0ef          	jal	ra,ffffffffc020120e <mm_create>
ffffffffc02043c2:	8caa                	mv	s9,a0
ffffffffc02043c4:	c159                	beqz	a0,ffffffffc020444a <do_fork+0x306>
    if ((page = alloc_page()) == NULL)
ffffffffc02043c6:	4505                	li	a0,1
ffffffffc02043c8:	c0efe0ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc02043cc:	cd25                	beqz	a0,ffffffffc0204444 <do_fork+0x300>
    return page - pages + nbase;
ffffffffc02043ce:	000ab683          	ld	a3,0(s5)
ffffffffc02043d2:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc02043d4:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02043d8:	40d506b3          	sub	a3,a0,a3
ffffffffc02043dc:	8699                	srai	a3,a3,0x6
ffffffffc02043de:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02043e0:	01b6fdb3          	and	s11,a3,s11
    return page2ppn(page) << PGSHIFT;
ffffffffc02043e4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043e6:	12edf263          	bgeu	s11,a4,ffffffffc020450a <do_fork+0x3c6>
ffffffffc02043ea:	000c3a03          	ld	s4,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02043ee:	6605                	lui	a2,0x1
ffffffffc02043f0:	000b1597          	auipc	a1,0xb1
ffffffffc02043f4:	d185b583          	ld	a1,-744(a1) # ffffffffc02b5108 <boot_pgdir_va>
ffffffffc02043f8:	9a36                	add	s4,s4,a3
ffffffffc02043fa:	8552                	mv	a0,s4
ffffffffc02043fc:	7e7000ef          	jal	ra,ffffffffc02053e2 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204400:	038d0d93          	addi	s11,s10,56
    mm->pgdir = pgdir;
ffffffffc0204404:	014cbc23          	sd	s4,24(s9) # ffffffffffe00018 <end+0x3fb4aecc>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204408:	4785                	li	a5,1
ffffffffc020440a:	40fdb7af          	amoor.d	a5,a5,(s11)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc020440e:	8b85                	andi	a5,a5,1
ffffffffc0204410:	4a05                	li	s4,1
ffffffffc0204412:	c799                	beqz	a5,ffffffffc0204420 <do_fork+0x2dc>
    {
        schedule();
ffffffffc0204414:	5af000ef          	jal	ra,ffffffffc02051c2 <schedule>
ffffffffc0204418:	414db7af          	amoor.d	a5,s4,(s11)
    while (!try_lock(lock))
ffffffffc020441c:	8b85                	andi	a5,a5,1
ffffffffc020441e:	fbfd                	bnez	a5,ffffffffc0204414 <do_fork+0x2d0>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204420:	85ea                	mv	a1,s10
ffffffffc0204422:	8566                	mv	a0,s9
ffffffffc0204424:	82cfd0ef          	jal	ra,ffffffffc0201450 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204428:	57f9                	li	a5,-2
ffffffffc020442a:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020442e:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204430:	cfa5                	beqz	a5,ffffffffc02044a8 <do_fork+0x364>
good_mm:
ffffffffc0204432:	8d66                	mv	s10,s9
    if (ret != 0)
ffffffffc0204434:	dc0506e3          	beqz	a0,ffffffffc0204200 <do_fork+0xbc>
    exit_mmap(mm);
ffffffffc0204438:	8566                	mv	a0,s9
ffffffffc020443a:	8b0fd0ef          	jal	ra,ffffffffc02014ea <exit_mmap>
    put_pgdir(mm);
ffffffffc020443e:	8566                	mv	a0,s9
ffffffffc0204440:	c23ff0ef          	jal	ra,ffffffffc0204062 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204444:	8566                	mv	a0,s9
ffffffffc0204446:	f09fc0ef          	jal	ra,ffffffffc020134e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020444a:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc020444c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204450:	0af6e163          	bltu	a3,a5,ffffffffc02044f2 <do_fork+0x3ae>
ffffffffc0204454:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc0204458:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020445c:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204460:	83b1                	srli	a5,a5,0xc
ffffffffc0204462:	04e7ff63          	bgeu	a5,a4,ffffffffc02044c0 <do_fork+0x37c>
    return &pages[PPN(pa) - nbase];
ffffffffc0204466:	000b3703          	ld	a4,0(s6)
ffffffffc020446a:	000ab503          	ld	a0,0(s5)
ffffffffc020446e:	4589                	li	a1,2
ffffffffc0204470:	8f99                	sub	a5,a5,a4
ffffffffc0204472:	079a                	slli	a5,a5,0x6
ffffffffc0204474:	953e                	add	a0,a0,a5
ffffffffc0204476:	b9efe0ef          	jal	ra,ffffffffc0202814 <free_pages>
    kfree(proc);
ffffffffc020447a:	8526                	mv	a0,s1
ffffffffc020447c:	f7efd0ef          	jal	ra,ffffffffc0201bfa <kfree>
    ret = -E_NO_MEM;
ffffffffc0204480:	5571                	li	a0,-4
    return ret;
ffffffffc0204482:	b569                	j	ffffffffc020430c <do_fork+0x1c8>
        intr_enable();
ffffffffc0204484:	d30fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204488:	bdb5                	j	ffffffffc0204304 <do_fork+0x1c0>
                    if (last_pid >= MAX_PID)
ffffffffc020448a:	01d6c363          	blt	a3,t4,ffffffffc0204490 <do_fork+0x34c>
                        last_pid = 1;
ffffffffc020448e:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204490:	4585                	li	a1,1
ffffffffc0204492:	b5c1                	j	ffffffffc0204352 <do_fork+0x20e>
ffffffffc0204494:	c599                	beqz	a1,ffffffffc02044a2 <do_fork+0x35e>
ffffffffc0204496:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc020449a:	8536                	mv	a0,a3
ffffffffc020449c:	bd01                	j	ffffffffc02042ac <do_fork+0x168>
    int ret = -E_NO_FREE_PROC;
ffffffffc020449e:	556d                	li	a0,-5
ffffffffc02044a0:	b5b5                	j	ffffffffc020430c <do_fork+0x1c8>
    return last_pid;
ffffffffc02044a2:	00082503          	lw	a0,0(a6)
ffffffffc02044a6:	b519                	j	ffffffffc02042ac <do_fork+0x168>
    {
        panic("Unlock failed.\n");
ffffffffc02044a8:	00003617          	auipc	a2,0x3
ffffffffc02044ac:	c2860613          	addi	a2,a2,-984 # ffffffffc02070d0 <default_pmm_manager+0x6c0>
ffffffffc02044b0:	03f00593          	li	a1,63
ffffffffc02044b4:	00003517          	auipc	a0,0x3
ffffffffc02044b8:	c2c50513          	addi	a0,a0,-980 # ffffffffc02070e0 <default_pmm_manager+0x6d0>
ffffffffc02044bc:	d63fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02044c0:	00002617          	auipc	a2,0x2
ffffffffc02044c4:	db060613          	addi	a2,a2,-592 # ffffffffc0206270 <commands+0x7c8>
ffffffffc02044c8:	06b00593          	li	a1,107
ffffffffc02044cc:	00002517          	auipc	a0,0x2
ffffffffc02044d0:	d9450513          	addi	a0,a0,-620 # ffffffffc0206260 <commands+0x7b8>
ffffffffc02044d4:	d4bfb0ef          	jal	ra,ffffffffc020021e <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02044d8:	86be                	mv	a3,a5
ffffffffc02044da:	00002617          	auipc	a2,0x2
ffffffffc02044de:	16660613          	addi	a2,a2,358 # ffffffffc0206640 <commands+0xb98>
ffffffffc02044e2:	18a00593          	li	a1,394
ffffffffc02044e6:	00003517          	auipc	a0,0x3
ffffffffc02044ea:	bd250513          	addi	a0,a0,-1070 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc02044ee:	d31fb0ef          	jal	ra,ffffffffc020021e <__panic>
    return pa2page(PADDR(kva));
ffffffffc02044f2:	00002617          	auipc	a2,0x2
ffffffffc02044f6:	14e60613          	addi	a2,a2,334 # ffffffffc0206640 <commands+0xb98>
ffffffffc02044fa:	07900593          	li	a1,121
ffffffffc02044fe:	00002517          	auipc	a0,0x2
ffffffffc0204502:	d6250513          	addi	a0,a0,-670 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0204506:	d19fb0ef          	jal	ra,ffffffffc020021e <__panic>
    return KADDR(page2pa(page));
ffffffffc020450a:	00002617          	auipc	a2,0x2
ffffffffc020450e:	d9660613          	addi	a2,a2,-618 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0204512:	07300593          	li	a1,115
ffffffffc0204516:	00002517          	auipc	a0,0x2
ffffffffc020451a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0206260 <commands+0x7b8>
ffffffffc020451e:	d01fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204522 <kernel_thread>:
{
ffffffffc0204522:	7129                	addi	sp,sp,-320
ffffffffc0204524:	fa22                	sd	s0,304(sp)
ffffffffc0204526:	f626                	sd	s1,296(sp)
ffffffffc0204528:	f24a                	sd	s2,288(sp)
ffffffffc020452a:	84ae                	mv	s1,a1
ffffffffc020452c:	892a                	mv	s2,a0
ffffffffc020452e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204530:	4581                	li	a1,0
ffffffffc0204532:	12000613          	li	a2,288
ffffffffc0204536:	850a                	mv	a0,sp
{
ffffffffc0204538:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020453a:	697000ef          	jal	ra,ffffffffc02053d0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020453e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204540:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204542:	100027f3          	csrr	a5,sstatus
ffffffffc0204546:	edd7f793          	andi	a5,a5,-291
ffffffffc020454a:	1207e793          	ori	a5,a5,288
ffffffffc020454e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204550:	860a                	mv	a2,sp
ffffffffc0204552:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204556:	00000797          	auipc	a5,0x0
ffffffffc020455a:	99c78793          	addi	a5,a5,-1636 # ffffffffc0203ef2 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020455e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204560:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204562:	be3ff0ef          	jal	ra,ffffffffc0204144 <do_fork>
}
ffffffffc0204566:	70f2                	ld	ra,312(sp)
ffffffffc0204568:	7452                	ld	s0,304(sp)
ffffffffc020456a:	74b2                	ld	s1,296(sp)
ffffffffc020456c:	7912                	ld	s2,288(sp)
ffffffffc020456e:	6131                	addi	sp,sp,320
ffffffffc0204570:	8082                	ret

ffffffffc0204572 <do_exit>:
{
ffffffffc0204572:	7179                	addi	sp,sp,-48
ffffffffc0204574:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204576:	000b1417          	auipc	s0,0xb1
ffffffffc020457a:	bba40413          	addi	s0,s0,-1094 # ffffffffc02b5130 <current>
ffffffffc020457e:	601c                	ld	a5,0(s0)
{
ffffffffc0204580:	f406                	sd	ra,40(sp)
ffffffffc0204582:	ec26                	sd	s1,24(sp)
ffffffffc0204584:	e84a                	sd	s2,16(sp)
ffffffffc0204586:	e44e                	sd	s3,8(sp)
ffffffffc0204588:	e052                	sd	s4,0(sp)
    if (current == idleproc)
ffffffffc020458a:	000b1717          	auipc	a4,0xb1
ffffffffc020458e:	bae73703          	ld	a4,-1106(a4) # ffffffffc02b5138 <idleproc>
ffffffffc0204592:	0ce78c63          	beq	a5,a4,ffffffffc020466a <do_exit+0xf8>
    if (current == initproc)
ffffffffc0204596:	000b1497          	auipc	s1,0xb1
ffffffffc020459a:	baa48493          	addi	s1,s1,-1110 # ffffffffc02b5140 <initproc>
ffffffffc020459e:	6098                	ld	a4,0(s1)
ffffffffc02045a0:	0ee78b63          	beq	a5,a4,ffffffffc0204696 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02045a4:	0287b983          	ld	s3,40(a5)
ffffffffc02045a8:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc02045aa:	02098663          	beqz	s3,ffffffffc02045d6 <do_exit+0x64>
ffffffffc02045ae:	000b1797          	auipc	a5,0xb1
ffffffffc02045b2:	b527b783          	ld	a5,-1198(a5) # ffffffffc02b5100 <boot_pgdir_pa>
ffffffffc02045b6:	577d                	li	a4,-1
ffffffffc02045b8:	177e                	slli	a4,a4,0x3f
ffffffffc02045ba:	83b1                	srli	a5,a5,0xc
ffffffffc02045bc:	8fd9                	or	a5,a5,a4
ffffffffc02045be:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02045c2:	0309a783          	lw	a5,48(s3)
ffffffffc02045c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02045ca:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc02045ce:	cb55                	beqz	a4,ffffffffc0204682 <do_exit+0x110>
        current->mm = NULL;
ffffffffc02045d0:	601c                	ld	a5,0(s0)
ffffffffc02045d2:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02045d6:	601c                	ld	a5,0(s0)
ffffffffc02045d8:	470d                	li	a4,3
ffffffffc02045da:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02045dc:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045e0:	100027f3          	csrr	a5,sstatus
ffffffffc02045e4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045e6:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045e8:	e3f9                	bnez	a5,ffffffffc02046ae <do_exit+0x13c>
        proc = current->parent;
ffffffffc02045ea:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc02045ec:	800007b7          	lui	a5,0x80000
ffffffffc02045f0:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02045f2:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc02045f4:	0ec52703          	lw	a4,236(a0)
ffffffffc02045f8:	0af70f63          	beq	a4,a5,ffffffffc02046b6 <do_exit+0x144>
        while (current->cptr != NULL)
ffffffffc02045fc:	6018                	ld	a4,0(s0)
ffffffffc02045fe:	7b7c                	ld	a5,240(a4)
ffffffffc0204600:	c3a1                	beqz	a5,ffffffffc0204640 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204602:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204606:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204608:	0985                	addi	s3,s3,1
ffffffffc020460a:	a021                	j	ffffffffc0204612 <do_exit+0xa0>
        while (current->cptr != NULL)
ffffffffc020460c:	6018                	ld	a4,0(s0)
ffffffffc020460e:	7b7c                	ld	a5,240(a4)
ffffffffc0204610:	cb85                	beqz	a5,ffffffffc0204640 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0204612:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fc8>
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204616:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204618:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020461a:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020461c:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204620:	10e7b023          	sd	a4,256(a5)
ffffffffc0204624:	c311                	beqz	a4,ffffffffc0204628 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0204626:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204628:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020462a:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020462c:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020462e:	fd271fe3          	bne	a4,s2,ffffffffc020460c <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204632:	0ec52783          	lw	a5,236(a0)
ffffffffc0204636:	fd379be3          	bne	a5,s3,ffffffffc020460c <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc020463a:	309000ef          	jal	ra,ffffffffc0205142 <wakeup_proc>
ffffffffc020463e:	b7f9                	j	ffffffffc020460c <do_exit+0x9a>
    if (flag)
ffffffffc0204640:	020a1263          	bnez	s4,ffffffffc0204664 <do_exit+0xf2>
    schedule();
ffffffffc0204644:	37f000ef          	jal	ra,ffffffffc02051c2 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204648:	601c                	ld	a5,0(s0)
ffffffffc020464a:	00003617          	auipc	a2,0x3
ffffffffc020464e:	ace60613          	addi	a2,a2,-1330 # ffffffffc0207118 <default_pmm_manager+0x708>
ffffffffc0204652:	23a00593          	li	a1,570
ffffffffc0204656:	43d4                	lw	a3,4(a5)
ffffffffc0204658:	00003517          	auipc	a0,0x3
ffffffffc020465c:	a6050513          	addi	a0,a0,-1440 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204660:	bbffb0ef          	jal	ra,ffffffffc020021e <__panic>
        intr_enable();
ffffffffc0204664:	b50fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204668:	bff1                	j	ffffffffc0204644 <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc020466a:	00003617          	auipc	a2,0x3
ffffffffc020466e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc02070f8 <default_pmm_manager+0x6e8>
ffffffffc0204672:	20600593          	li	a1,518
ffffffffc0204676:	00003517          	auipc	a0,0x3
ffffffffc020467a:	a4250513          	addi	a0,a0,-1470 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc020467e:	ba1fb0ef          	jal	ra,ffffffffc020021e <__panic>
            exit_mmap(mm);
ffffffffc0204682:	854e                	mv	a0,s3
ffffffffc0204684:	e67fc0ef          	jal	ra,ffffffffc02014ea <exit_mmap>
            put_pgdir(mm);
ffffffffc0204688:	854e                	mv	a0,s3
ffffffffc020468a:	9d9ff0ef          	jal	ra,ffffffffc0204062 <put_pgdir>
            mm_destroy(mm);
ffffffffc020468e:	854e                	mv	a0,s3
ffffffffc0204690:	cbffc0ef          	jal	ra,ffffffffc020134e <mm_destroy>
ffffffffc0204694:	bf35                	j	ffffffffc02045d0 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc0204696:	00003617          	auipc	a2,0x3
ffffffffc020469a:	a7260613          	addi	a2,a2,-1422 # ffffffffc0207108 <default_pmm_manager+0x6f8>
ffffffffc020469e:	20a00593          	li	a1,522
ffffffffc02046a2:	00003517          	auipc	a0,0x3
ffffffffc02046a6:	a1650513          	addi	a0,a0,-1514 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc02046aa:	b75fb0ef          	jal	ra,ffffffffc020021e <__panic>
        intr_disable();
ffffffffc02046ae:	b0cfc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc02046b2:	4a05                	li	s4,1
ffffffffc02046b4:	bf1d                	j	ffffffffc02045ea <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02046b6:	28d000ef          	jal	ra,ffffffffc0205142 <wakeup_proc>
ffffffffc02046ba:	b789                	j	ffffffffc02045fc <do_exit+0x8a>

ffffffffc02046bc <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc02046bc:	715d                	addi	sp,sp,-80
ffffffffc02046be:	f84a                	sd	s2,48(sp)
ffffffffc02046c0:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02046c2:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID)
ffffffffc02046c6:	6989                	lui	s3,0x2
int do_wait(int pid, int *code_store)
ffffffffc02046c8:	fc26                	sd	s1,56(sp)
ffffffffc02046ca:	f052                	sd	s4,32(sp)
ffffffffc02046cc:	ec56                	sd	s5,24(sp)
ffffffffc02046ce:	e85a                	sd	s6,16(sp)
ffffffffc02046d0:	e45e                	sd	s7,8(sp)
ffffffffc02046d2:	e486                	sd	ra,72(sp)
ffffffffc02046d4:	e0a2                	sd	s0,64(sp)
ffffffffc02046d6:	84aa                	mv	s1,a0
ffffffffc02046d8:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc02046da:	000b1b97          	auipc	s7,0xb1
ffffffffc02046de:	a56b8b93          	addi	s7,s7,-1450 # ffffffffc02b5130 <current>
    if (0 < pid && pid < MAX_PID)
ffffffffc02046e2:	00050b1b          	sext.w	s6,a0
ffffffffc02046e6:	fff50a9b          	addiw	s5,a0,-1
ffffffffc02046ea:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc02046ec:	0905                	addi	s2,s2,1
    if (pid != 0)
ffffffffc02046ee:	ccbd                	beqz	s1,ffffffffc020476c <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID)
ffffffffc02046f0:	0359e863          	bltu	s3,s5,ffffffffc0204720 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02046f4:	45a9                	li	a1,10
ffffffffc02046f6:	855a                	mv	a0,s6
ffffffffc02046f8:	0f0010ef          	jal	ra,ffffffffc02057e8 <hash32>
ffffffffc02046fc:	02051793          	slli	a5,a0,0x20
ffffffffc0204700:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204704:	000ad797          	auipc	a5,0xad
ffffffffc0204708:	9b478793          	addi	a5,a5,-1612 # ffffffffc02b10b8 <hash_list>
ffffffffc020470c:	953e                	add	a0,a0,a5
ffffffffc020470e:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list)
ffffffffc0204710:	a029                	j	ffffffffc020471a <do_wait.part.0+0x5e>
            if (proc->pid == pid)
ffffffffc0204712:	f2c42783          	lw	a5,-212(s0)
ffffffffc0204716:	02978163          	beq	a5,s1,ffffffffc0204738 <do_wait.part.0+0x7c>
ffffffffc020471a:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list)
ffffffffc020471c:	fe851be3          	bne	a0,s0,ffffffffc0204712 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0204720:	5579                	li	a0,-2
}
ffffffffc0204722:	60a6                	ld	ra,72(sp)
ffffffffc0204724:	6406                	ld	s0,64(sp)
ffffffffc0204726:	74e2                	ld	s1,56(sp)
ffffffffc0204728:	7942                	ld	s2,48(sp)
ffffffffc020472a:	79a2                	ld	s3,40(sp)
ffffffffc020472c:	7a02                	ld	s4,32(sp)
ffffffffc020472e:	6ae2                	ld	s5,24(sp)
ffffffffc0204730:	6b42                	ld	s6,16(sp)
ffffffffc0204732:	6ba2                	ld	s7,8(sp)
ffffffffc0204734:	6161                	addi	sp,sp,80
ffffffffc0204736:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204738:	000bb683          	ld	a3,0(s7)
ffffffffc020473c:	f4843783          	ld	a5,-184(s0)
ffffffffc0204740:	fed790e3          	bne	a5,a3,ffffffffc0204720 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204744:	f2842703          	lw	a4,-216(s0)
ffffffffc0204748:	478d                	li	a5,3
ffffffffc020474a:	0ef70b63          	beq	a4,a5,ffffffffc0204840 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc020474e:	4785                	li	a5,1
ffffffffc0204750:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc0204752:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0204756:	26d000ef          	jal	ra,ffffffffc02051c2 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc020475a:	000bb783          	ld	a5,0(s7)
ffffffffc020475e:	0b07a783          	lw	a5,176(a5)
ffffffffc0204762:	8b85                	andi	a5,a5,1
ffffffffc0204764:	d7c9                	beqz	a5,ffffffffc02046ee <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc0204766:	555d                	li	a0,-9
ffffffffc0204768:	e0bff0ef          	jal	ra,ffffffffc0204572 <do_exit>
        proc = current->cptr;
ffffffffc020476c:	000bb683          	ld	a3,0(s7)
ffffffffc0204770:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204772:	d45d                	beqz	s0,ffffffffc0204720 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204774:	470d                	li	a4,3
ffffffffc0204776:	a021                	j	ffffffffc020477e <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204778:	10043403          	ld	s0,256(s0)
ffffffffc020477c:	d869                	beqz	s0,ffffffffc020474e <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020477e:	401c                	lw	a5,0(s0)
ffffffffc0204780:	fee79ce3          	bne	a5,a4,ffffffffc0204778 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc)
ffffffffc0204784:	000b1797          	auipc	a5,0xb1
ffffffffc0204788:	9b47b783          	ld	a5,-1612(a5) # ffffffffc02b5138 <idleproc>
ffffffffc020478c:	0c878963          	beq	a5,s0,ffffffffc020485e <do_wait.part.0+0x1a2>
ffffffffc0204790:	000b1797          	auipc	a5,0xb1
ffffffffc0204794:	9b07b783          	ld	a5,-1616(a5) # ffffffffc02b5140 <initproc>
ffffffffc0204798:	0cf40363          	beq	s0,a5,ffffffffc020485e <do_wait.part.0+0x1a2>
    if (code_store != NULL)
ffffffffc020479c:	000a0663          	beqz	s4,ffffffffc02047a8 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02047a0:	0e842783          	lw	a5,232(s0)
ffffffffc02047a4:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bc8>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047a8:	100027f3          	csrr	a5,sstatus
ffffffffc02047ac:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02047ae:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047b0:	e7c1                	bnez	a5,ffffffffc0204838 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02047b2:	6c70                	ld	a2,216(s0)
ffffffffc02047b4:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL)
ffffffffc02047b6:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02047ba:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02047bc:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02047be:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02047c0:	6470                	ld	a2,200(s0)
ffffffffc02047c2:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02047c4:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02047c6:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL)
ffffffffc02047c8:	c319                	beqz	a4,ffffffffc02047ce <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc02047ca:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL)
ffffffffc02047cc:	7c7c                	ld	a5,248(s0)
ffffffffc02047ce:	c3b5                	beqz	a5,ffffffffc0204832 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc02047d0:	10e7b023          	sd	a4,256(a5)
    nr_process--;
ffffffffc02047d4:	000b1717          	auipc	a4,0xb1
ffffffffc02047d8:	97470713          	addi	a4,a4,-1676 # ffffffffc02b5148 <nr_process>
ffffffffc02047dc:	431c                	lw	a5,0(a4)
ffffffffc02047de:	37fd                	addiw	a5,a5,-1
ffffffffc02047e0:	c31c                	sw	a5,0(a4)
    if (flag)
ffffffffc02047e2:	e5a9                	bnez	a1,ffffffffc020482c <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02047e4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02047e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02047ea:	04f6ee63          	bltu	a3,a5,ffffffffc0204846 <do_wait.part.0+0x18a>
ffffffffc02047ee:	000b1797          	auipc	a5,0xb1
ffffffffc02047f2:	93a7b783          	ld	a5,-1734(a5) # ffffffffc02b5128 <va_pa_offset>
ffffffffc02047f6:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage)
ffffffffc02047f8:	82b1                	srli	a3,a3,0xc
ffffffffc02047fa:	000b1797          	auipc	a5,0xb1
ffffffffc02047fe:	9167b783          	ld	a5,-1770(a5) # ffffffffc02b5110 <npage>
ffffffffc0204802:	06f6fa63          	bgeu	a3,a5,ffffffffc0204876 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0204806:	00003517          	auipc	a0,0x3
ffffffffc020480a:	14a53503          	ld	a0,330(a0) # ffffffffc0207950 <nbase>
ffffffffc020480e:	8e89                	sub	a3,a3,a0
ffffffffc0204810:	069a                	slli	a3,a3,0x6
ffffffffc0204812:	000b1517          	auipc	a0,0xb1
ffffffffc0204816:	90653503          	ld	a0,-1786(a0) # ffffffffc02b5118 <pages>
ffffffffc020481a:	9536                	add	a0,a0,a3
ffffffffc020481c:	4589                	li	a1,2
ffffffffc020481e:	ff7fd0ef          	jal	ra,ffffffffc0202814 <free_pages>
    kfree(proc);
ffffffffc0204822:	8522                	mv	a0,s0
ffffffffc0204824:	bd6fd0ef          	jal	ra,ffffffffc0201bfa <kfree>
    return 0;
ffffffffc0204828:	4501                	li	a0,0
ffffffffc020482a:	bde5                	j	ffffffffc0204722 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc020482c:	988fc0ef          	jal	ra,ffffffffc02009b4 <intr_enable>
ffffffffc0204830:	bf55                	j	ffffffffc02047e4 <do_wait.part.0+0x128>
        proc->parent->cptr = proc->optr;
ffffffffc0204832:	701c                	ld	a5,32(s0)
ffffffffc0204834:	fbf8                	sd	a4,240(a5)
ffffffffc0204836:	bf79                	j	ffffffffc02047d4 <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0204838:	982fc0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc020483c:	4585                	li	a1,1
ffffffffc020483e:	bf95                	j	ffffffffc02047b2 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204840:	f2840413          	addi	s0,s0,-216
ffffffffc0204844:	b781                	j	ffffffffc0204784 <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0204846:	00002617          	auipc	a2,0x2
ffffffffc020484a:	dfa60613          	addi	a2,a2,-518 # ffffffffc0206640 <commands+0xb98>
ffffffffc020484e:	07900593          	li	a1,121
ffffffffc0204852:	00002517          	auipc	a0,0x2
ffffffffc0204856:	a0e50513          	addi	a0,a0,-1522 # ffffffffc0206260 <commands+0x7b8>
ffffffffc020485a:	9c5fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc020485e:	00003617          	auipc	a2,0x3
ffffffffc0204862:	8da60613          	addi	a2,a2,-1830 # ffffffffc0207138 <default_pmm_manager+0x728>
ffffffffc0204866:	35600593          	li	a1,854
ffffffffc020486a:	00003517          	auipc	a0,0x3
ffffffffc020486e:	84e50513          	addi	a0,a0,-1970 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204872:	9adfb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204876:	00002617          	auipc	a2,0x2
ffffffffc020487a:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0206270 <commands+0x7c8>
ffffffffc020487e:	06b00593          	li	a1,107
ffffffffc0204882:	00002517          	auipc	a0,0x2
ffffffffc0204886:	9de50513          	addi	a0,a0,-1570 # ffffffffc0206260 <commands+0x7b8>
ffffffffc020488a:	995fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020488e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc020488e:	1141                	addi	sp,sp,-16
ffffffffc0204890:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204892:	fc3fd0ef          	jal	ra,ffffffffc0202854 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204896:	ab0fd0ef          	jal	ra,ffffffffc0201b46 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020489a:	4601                	li	a2,0
ffffffffc020489c:	4581                	li	a1,0
ffffffffc020489e:	fffff517          	auipc	a0,0xfffff
ffffffffc02048a2:	74650513          	addi	a0,a0,1862 # ffffffffc0203fe4 <user_main>
ffffffffc02048a6:	c7dff0ef          	jal	ra,ffffffffc0204522 <kernel_thread>
    if (pid <= 0)
ffffffffc02048aa:	00a04563          	bgtz	a0,ffffffffc02048b4 <init_main+0x26>
ffffffffc02048ae:	a071                	j	ffffffffc020493a <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc02048b0:	113000ef          	jal	ra,ffffffffc02051c2 <schedule>
    if (code_store != NULL)
ffffffffc02048b4:	4581                	li	a1,0
ffffffffc02048b6:	4501                	li	a0,0
ffffffffc02048b8:	e05ff0ef          	jal	ra,ffffffffc02046bc <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc02048bc:	d975                	beqz	a0,ffffffffc02048b0 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02048be:	00003517          	auipc	a0,0x3
ffffffffc02048c2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0207178 <default_pmm_manager+0x768>
ffffffffc02048c6:	81bfb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02048ca:	000b1797          	auipc	a5,0xb1
ffffffffc02048ce:	8767b783          	ld	a5,-1930(a5) # ffffffffc02b5140 <initproc>
ffffffffc02048d2:	7bf8                	ld	a4,240(a5)
ffffffffc02048d4:	e339                	bnez	a4,ffffffffc020491a <init_main+0x8c>
ffffffffc02048d6:	7ff8                	ld	a4,248(a5)
ffffffffc02048d8:	e329                	bnez	a4,ffffffffc020491a <init_main+0x8c>
ffffffffc02048da:	1007b703          	ld	a4,256(a5)
ffffffffc02048de:	ef15                	bnez	a4,ffffffffc020491a <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02048e0:	000b1697          	auipc	a3,0xb1
ffffffffc02048e4:	8686a683          	lw	a3,-1944(a3) # ffffffffc02b5148 <nr_process>
ffffffffc02048e8:	4709                	li	a4,2
ffffffffc02048ea:	0ae69463          	bne	a3,a4,ffffffffc0204992 <init_main+0x104>
    return listelm->next;
ffffffffc02048ee:	000b0697          	auipc	a3,0xb0
ffffffffc02048f2:	7ca68693          	addi	a3,a3,1994 # ffffffffc02b50b8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02048f6:	6698                	ld	a4,8(a3)
ffffffffc02048f8:	0c878793          	addi	a5,a5,200
ffffffffc02048fc:	06f71b63          	bne	a4,a5,ffffffffc0204972 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204900:	629c                	ld	a5,0(a3)
ffffffffc0204902:	04f71863          	bne	a4,a5,ffffffffc0204952 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204906:	00003517          	auipc	a0,0x3
ffffffffc020490a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0207260 <default_pmm_manager+0x850>
ffffffffc020490e:	fd2fb0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
}
ffffffffc0204912:	60a2                	ld	ra,8(sp)
ffffffffc0204914:	4501                	li	a0,0
ffffffffc0204916:	0141                	addi	sp,sp,16
ffffffffc0204918:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020491a:	00003697          	auipc	a3,0x3
ffffffffc020491e:	88668693          	addi	a3,a3,-1914 # ffffffffc02071a0 <default_pmm_manager+0x790>
ffffffffc0204922:	00002617          	auipc	a2,0x2
ffffffffc0204926:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206358 <commands+0x8b0>
ffffffffc020492a:	3c400593          	li	a1,964
ffffffffc020492e:	00002517          	auipc	a0,0x2
ffffffffc0204932:	78a50513          	addi	a0,a0,1930 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204936:	8e9fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("create user_main failed.\n");
ffffffffc020493a:	00003617          	auipc	a2,0x3
ffffffffc020493e:	81e60613          	addi	a2,a2,-2018 # ffffffffc0207158 <default_pmm_manager+0x748>
ffffffffc0204942:	3bb00593          	li	a1,955
ffffffffc0204946:	00002517          	auipc	a0,0x2
ffffffffc020494a:	77250513          	addi	a0,a0,1906 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc020494e:	8d1fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204952:	00003697          	auipc	a3,0x3
ffffffffc0204956:	8de68693          	addi	a3,a3,-1826 # ffffffffc0207230 <default_pmm_manager+0x820>
ffffffffc020495a:	00002617          	auipc	a2,0x2
ffffffffc020495e:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204962:	3c700593          	li	a1,967
ffffffffc0204966:	00002517          	auipc	a0,0x2
ffffffffc020496a:	75250513          	addi	a0,a0,1874 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc020496e:	8b1fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204972:	00003697          	auipc	a3,0x3
ffffffffc0204976:	88e68693          	addi	a3,a3,-1906 # ffffffffc0207200 <default_pmm_manager+0x7f0>
ffffffffc020497a:	00002617          	auipc	a2,0x2
ffffffffc020497e:	9de60613          	addi	a2,a2,-1570 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204982:	3c600593          	li	a1,966
ffffffffc0204986:	00002517          	auipc	a0,0x2
ffffffffc020498a:	73250513          	addi	a0,a0,1842 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc020498e:	891fb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(nr_process == 2);
ffffffffc0204992:	00003697          	auipc	a3,0x3
ffffffffc0204996:	85e68693          	addi	a3,a3,-1954 # ffffffffc02071f0 <default_pmm_manager+0x7e0>
ffffffffc020499a:	00002617          	auipc	a2,0x2
ffffffffc020499e:	9be60613          	addi	a2,a2,-1602 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02049a2:	3c500593          	li	a1,965
ffffffffc02049a6:	00002517          	auipc	a0,0x2
ffffffffc02049aa:	71250513          	addi	a0,a0,1810 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc02049ae:	871fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02049b2 <do_execve>:
{
ffffffffc02049b2:	7171                	addi	sp,sp,-176
ffffffffc02049b4:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049b6:	000b0d97          	auipc	s11,0xb0
ffffffffc02049ba:	77ad8d93          	addi	s11,s11,1914 # ffffffffc02b5130 <current>
ffffffffc02049be:	000db783          	ld	a5,0(s11)
{
ffffffffc02049c2:	e54e                	sd	s3,136(sp)
ffffffffc02049c4:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049c6:	0287b983          	ld	s3,40(a5)
{
ffffffffc02049ca:	e94a                	sd	s2,144(sp)
ffffffffc02049cc:	f4de                	sd	s7,104(sp)
ffffffffc02049ce:	892a                	mv	s2,a0
ffffffffc02049d0:	8bb2                	mv	s7,a2
ffffffffc02049d2:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02049d4:	862e                	mv	a2,a1
ffffffffc02049d6:	4681                	li	a3,0
ffffffffc02049d8:	85aa                	mv	a1,a0
ffffffffc02049da:	854e                	mv	a0,s3
{
ffffffffc02049dc:	f506                	sd	ra,168(sp)
ffffffffc02049de:	f122                	sd	s0,160(sp)
ffffffffc02049e0:	e152                	sd	s4,128(sp)
ffffffffc02049e2:	fcd6                	sd	s5,120(sp)
ffffffffc02049e4:	f8da                	sd	s6,112(sp)
ffffffffc02049e6:	f0e2                	sd	s8,96(sp)
ffffffffc02049e8:	ece6                	sd	s9,88(sp)
ffffffffc02049ea:	e8ea                	sd	s10,80(sp)
ffffffffc02049ec:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02049ee:	e97fc0ef          	jal	ra,ffffffffc0201884 <user_mem_check>
ffffffffc02049f2:	40050a63          	beqz	a0,ffffffffc0204e06 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02049f6:	4641                	li	a2,16
ffffffffc02049f8:	4581                	li	a1,0
ffffffffc02049fa:	1808                	addi	a0,sp,48
ffffffffc02049fc:	1d5000ef          	jal	ra,ffffffffc02053d0 <memset>
    memcpy(local_name, name, len);
ffffffffc0204a00:	47bd                	li	a5,15
ffffffffc0204a02:	8626                	mv	a2,s1
ffffffffc0204a04:	1e97e263          	bltu	a5,s1,ffffffffc0204be8 <do_execve+0x236>
ffffffffc0204a08:	85ca                	mv	a1,s2
ffffffffc0204a0a:	1808                	addi	a0,sp,48
ffffffffc0204a0c:	1d7000ef          	jal	ra,ffffffffc02053e2 <memcpy>
    if (mm != NULL)
ffffffffc0204a10:	1e098363          	beqz	s3,ffffffffc0204bf6 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc0204a14:	00002517          	auipc	a0,0x2
ffffffffc0204a18:	9e450513          	addi	a0,a0,-1564 # ffffffffc02063f8 <commands+0x950>
ffffffffc0204a1c:	efefb0ef          	jal	ra,ffffffffc020011a <cputs>
ffffffffc0204a20:	000b0797          	auipc	a5,0xb0
ffffffffc0204a24:	6e07b783          	ld	a5,1760(a5) # ffffffffc02b5100 <boot_pgdir_pa>
ffffffffc0204a28:	577d                	li	a4,-1
ffffffffc0204a2a:	177e                	slli	a4,a4,0x3f
ffffffffc0204a2c:	83b1                	srli	a5,a5,0xc
ffffffffc0204a2e:	8fd9                	or	a5,a5,a4
ffffffffc0204a30:	18079073          	csrw	satp,a5
ffffffffc0204a34:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7b98>
ffffffffc0204a38:	fff7871b          	addiw	a4,a5,-1
ffffffffc0204a3c:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0)
ffffffffc0204a40:	2c070463          	beqz	a4,ffffffffc0204d08 <do_execve+0x356>
        current->mm = NULL;
ffffffffc0204a44:	000db783          	ld	a5,0(s11)
ffffffffc0204a48:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a4c:	fc2fc0ef          	jal	ra,ffffffffc020120e <mm_create>
ffffffffc0204a50:	84aa                	mv	s1,a0
ffffffffc0204a52:	1c050d63          	beqz	a0,ffffffffc0204c2c <do_execve+0x27a>
    if ((page = alloc_page()) == NULL)
ffffffffc0204a56:	4505                	li	a0,1
ffffffffc0204a58:	d7ffd0ef          	jal	ra,ffffffffc02027d6 <alloc_pages>
ffffffffc0204a5c:	3a050963          	beqz	a0,ffffffffc0204e0e <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc0204a60:	000b0c97          	auipc	s9,0xb0
ffffffffc0204a64:	6b8c8c93          	addi	s9,s9,1720 # ffffffffc02b5118 <pages>
ffffffffc0204a68:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204a6c:	000b0c17          	auipc	s8,0xb0
ffffffffc0204a70:	6a4c0c13          	addi	s8,s8,1700 # ffffffffc02b5110 <npage>
    return page - pages + nbase;
ffffffffc0204a74:	00003717          	auipc	a4,0x3
ffffffffc0204a78:	edc73703          	ld	a4,-292(a4) # ffffffffc0207950 <nbase>
ffffffffc0204a7c:	40d506b3          	sub	a3,a0,a3
ffffffffc0204a80:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204a82:	5afd                	li	s5,-1
ffffffffc0204a84:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204a88:	96ba                	add	a3,a3,a4
ffffffffc0204a8a:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204a8c:	00cad713          	srli	a4,s5,0xc
ffffffffc0204a90:	ec3a                	sd	a4,24(sp)
ffffffffc0204a92:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a94:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a96:	38f77063          	bgeu	a4,a5,ffffffffc0204e16 <do_execve+0x464>
ffffffffc0204a9a:	000b0b17          	auipc	s6,0xb0
ffffffffc0204a9e:	68eb0b13          	addi	s6,s6,1678 # ffffffffc02b5128 <va_pa_offset>
ffffffffc0204aa2:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204aa6:	6605                	lui	a2,0x1
ffffffffc0204aa8:	000b0597          	auipc	a1,0xb0
ffffffffc0204aac:	6605b583          	ld	a1,1632(a1) # ffffffffc02b5108 <boot_pgdir_va>
ffffffffc0204ab0:	9936                	add	s2,s2,a3
ffffffffc0204ab2:	854a                	mv	a0,s2
ffffffffc0204ab4:	12f000ef          	jal	ra,ffffffffc02053e2 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204ab8:	7782                	ld	a5,32(sp)
ffffffffc0204aba:	4398                	lw	a4,0(a5)
ffffffffc0204abc:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204ac0:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204ac4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9447>
ffffffffc0204ac8:	14f71863          	bne	a4,a5,ffffffffc0204c18 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204acc:	7682                	ld	a3,32(sp)
ffffffffc0204ace:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204ad2:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204ad6:	00371793          	slli	a5,a4,0x3
ffffffffc0204ada:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204adc:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204ade:	078e                	slli	a5,a5,0x3
ffffffffc0204ae0:	97ce                	add	a5,a5,s3
ffffffffc0204ae2:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204ae4:	00f9fc63          	bgeu	s3,a5,ffffffffc0204afc <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204ae8:	0009a783          	lw	a5,0(s3)
ffffffffc0204aec:	4705                	li	a4,1
ffffffffc0204aee:	14e78163          	beq	a5,a4,ffffffffc0204c30 <do_execve+0x27e>
    for (; ph < ph_end; ph++)
ffffffffc0204af2:	77a2                	ld	a5,40(sp)
ffffffffc0204af4:	03898993          	addi	s3,s3,56
ffffffffc0204af8:	fef9e8e3          	bltu	s3,a5,ffffffffc0204ae8 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204afc:	4701                	li	a4,0
ffffffffc0204afe:	46ad                	li	a3,11
ffffffffc0204b00:	00100637          	lui	a2,0x100
ffffffffc0204b04:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204b08:	8526                	mv	a0,s1
ffffffffc0204b0a:	897fc0ef          	jal	ra,ffffffffc02013a0 <mm_map>
ffffffffc0204b0e:	8a2a                	mv	s4,a0
ffffffffc0204b10:	1e051263          	bnez	a0,ffffffffc0204cf4 <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204b14:	6c88                	ld	a0,24(s1)
ffffffffc0204b16:	467d                	li	a2,31
ffffffffc0204b18:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204b1c:	b14ff0ef          	jal	ra,ffffffffc0203e30 <pgdir_alloc_page>
ffffffffc0204b20:	38050363          	beqz	a0,ffffffffc0204ea6 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204b24:	6c88                	ld	a0,24(s1)
ffffffffc0204b26:	467d                	li	a2,31
ffffffffc0204b28:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204b2c:	b04ff0ef          	jal	ra,ffffffffc0203e30 <pgdir_alloc_page>
ffffffffc0204b30:	34050b63          	beqz	a0,ffffffffc0204e86 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204b34:	6c88                	ld	a0,24(s1)
ffffffffc0204b36:	467d                	li	a2,31
ffffffffc0204b38:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204b3c:	af4ff0ef          	jal	ra,ffffffffc0203e30 <pgdir_alloc_page>
ffffffffc0204b40:	32050363          	beqz	a0,ffffffffc0204e66 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204b44:	6c88                	ld	a0,24(s1)
ffffffffc0204b46:	467d                	li	a2,31
ffffffffc0204b48:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204b4c:	ae4ff0ef          	jal	ra,ffffffffc0203e30 <pgdir_alloc_page>
ffffffffc0204b50:	2e050b63          	beqz	a0,ffffffffc0204e46 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc0204b54:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204b56:	000db603          	ld	a2,0(s11)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204b5a:	6c94                	ld	a3,24(s1)
ffffffffc0204b5c:	2785                	addiw	a5,a5,1
ffffffffc0204b5e:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204b60:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204b62:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b66:	2cf6e463          	bltu	a3,a5,ffffffffc0204e2e <do_execve+0x47c>
ffffffffc0204b6a:	000b3783          	ld	a5,0(s6)
ffffffffc0204b6e:	577d                	li	a4,-1
ffffffffc0204b70:	177e                	slli	a4,a4,0x3f
ffffffffc0204b72:	8e9d                	sub	a3,a3,a5
ffffffffc0204b74:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204b78:	f654                	sd	a3,168(a2)
ffffffffc0204b7a:	8fd9                	or	a5,a5,a4
ffffffffc0204b7c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204b80:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204b82:	4581                	li	a1,0
ffffffffc0204b84:	12000613          	li	a2,288
ffffffffc0204b88:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204b8a:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204b8e:	043000ef          	jal	ra,ffffffffc02053d0 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204b92:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204b94:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204b98:	edd4f493          	andi	s1,s1,-291
    tf->epc = elf->e_entry;
ffffffffc0204b9c:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204b9e:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ba0:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f7c>
    tf->gpr.sp = USTACKTOP;
ffffffffc0204ba4:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204ba6:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204baa:	4641                	li	a2,16
ffffffffc0204bac:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0204bae:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0204bb0:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204bb4:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204bb8:	854a                	mv	a0,s2
ffffffffc0204bba:	017000ef          	jal	ra,ffffffffc02053d0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204bbe:	463d                	li	a2,15
ffffffffc0204bc0:	180c                	addi	a1,sp,48
ffffffffc0204bc2:	854a                	mv	a0,s2
ffffffffc0204bc4:	01f000ef          	jal	ra,ffffffffc02053e2 <memcpy>
}
ffffffffc0204bc8:	70aa                	ld	ra,168(sp)
ffffffffc0204bca:	740a                	ld	s0,160(sp)
ffffffffc0204bcc:	64ea                	ld	s1,152(sp)
ffffffffc0204bce:	694a                	ld	s2,144(sp)
ffffffffc0204bd0:	69aa                	ld	s3,136(sp)
ffffffffc0204bd2:	7ae6                	ld	s5,120(sp)
ffffffffc0204bd4:	7b46                	ld	s6,112(sp)
ffffffffc0204bd6:	7ba6                	ld	s7,104(sp)
ffffffffc0204bd8:	7c06                	ld	s8,96(sp)
ffffffffc0204bda:	6ce6                	ld	s9,88(sp)
ffffffffc0204bdc:	6d46                	ld	s10,80(sp)
ffffffffc0204bde:	6da6                	ld	s11,72(sp)
ffffffffc0204be0:	8552                	mv	a0,s4
ffffffffc0204be2:	6a0a                	ld	s4,128(sp)
ffffffffc0204be4:	614d                	addi	sp,sp,176
ffffffffc0204be6:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0204be8:	463d                	li	a2,15
ffffffffc0204bea:	85ca                	mv	a1,s2
ffffffffc0204bec:	1808                	addi	a0,sp,48
ffffffffc0204bee:	7f4000ef          	jal	ra,ffffffffc02053e2 <memcpy>
    if (mm != NULL)
ffffffffc0204bf2:	e20991e3          	bnez	s3,ffffffffc0204a14 <do_execve+0x62>
    if (current->mm != NULL)
ffffffffc0204bf6:	000db783          	ld	a5,0(s11)
ffffffffc0204bfa:	779c                	ld	a5,40(a5)
ffffffffc0204bfc:	e40788e3          	beqz	a5,ffffffffc0204a4c <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204c00:	00002617          	auipc	a2,0x2
ffffffffc0204c04:	68060613          	addi	a2,a2,1664 # ffffffffc0207280 <default_pmm_manager+0x870>
ffffffffc0204c08:	24600593          	li	a1,582
ffffffffc0204c0c:	00002517          	auipc	a0,0x2
ffffffffc0204c10:	4ac50513          	addi	a0,a0,1196 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204c14:	e0afb0ef          	jal	ra,ffffffffc020021e <__panic>
    put_pgdir(mm);
ffffffffc0204c18:	8526                	mv	a0,s1
ffffffffc0204c1a:	c48ff0ef          	jal	ra,ffffffffc0204062 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204c1e:	8526                	mv	a0,s1
ffffffffc0204c20:	f2efc0ef          	jal	ra,ffffffffc020134e <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0204c24:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0204c26:	8552                	mv	a0,s4
ffffffffc0204c28:	94bff0ef          	jal	ra,ffffffffc0204572 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0204c2c:	5a71                	li	s4,-4
ffffffffc0204c2e:	bfe5                	j	ffffffffc0204c26 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204c30:	0289b603          	ld	a2,40(s3)
ffffffffc0204c34:	0209b783          	ld	a5,32(s3)
ffffffffc0204c38:	1cf66d63          	bltu	a2,a5,ffffffffc0204e12 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204c3c:	0049a783          	lw	a5,4(s3)
ffffffffc0204c40:	0017f693          	andi	a3,a5,1
ffffffffc0204c44:	c291                	beqz	a3,ffffffffc0204c48 <do_execve+0x296>
            vm_flags |= VM_EXEC;
ffffffffc0204c46:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204c48:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c4c:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204c4e:	e779                	bnez	a4,ffffffffc0204d1c <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204c50:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c52:	c781                	beqz	a5,ffffffffc0204c5a <do_execve+0x2a8>
            vm_flags |= VM_READ;
ffffffffc0204c54:	0016e693          	ori	a3,a3,1
            perm |= PTE_R;
ffffffffc0204c58:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE)
ffffffffc0204c5a:	0026f793          	andi	a5,a3,2
ffffffffc0204c5e:	e3f1                	bnez	a5,ffffffffc0204d22 <do_execve+0x370>
        if (vm_flags & VM_EXEC)
ffffffffc0204c60:	0046f793          	andi	a5,a3,4
ffffffffc0204c64:	c399                	beqz	a5,ffffffffc0204c6a <do_execve+0x2b8>
            perm |= PTE_X;
ffffffffc0204c66:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204c6a:	0109b583          	ld	a1,16(s3)
ffffffffc0204c6e:	4701                	li	a4,0
ffffffffc0204c70:	8526                	mv	a0,s1
ffffffffc0204c72:	f2efc0ef          	jal	ra,ffffffffc02013a0 <mm_map>
ffffffffc0204c76:	8a2a                	mv	s4,a0
ffffffffc0204c78:	ed35                	bnez	a0,ffffffffc0204cf4 <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204c7a:	0109bb83          	ld	s7,16(s3)
ffffffffc0204c7e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0204c80:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204c84:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204c88:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204c8c:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204c8e:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204c90:	993e                	add	s2,s2,a5
        while (start < end)
ffffffffc0204c92:	054be963          	bltu	s7,s4,ffffffffc0204ce4 <do_execve+0x332>
ffffffffc0204c96:	aa95                	j	ffffffffc0204e0a <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204c98:	6785                	lui	a5,0x1
ffffffffc0204c9a:	415b8533          	sub	a0,s7,s5
ffffffffc0204c9e:	9abe                	add	s5,s5,a5
ffffffffc0204ca0:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204ca4:	015a7463          	bgeu	s4,s5,ffffffffc0204cac <do_execve+0x2fa>
                size -= la - end;
ffffffffc0204ca8:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0204cac:	000cb683          	ld	a3,0(s9)
ffffffffc0204cb0:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204cb2:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204cb6:	40d406b3          	sub	a3,s0,a3
ffffffffc0204cba:	8699                	srai	a3,a3,0x6
ffffffffc0204cbc:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204cbe:	67e2                	ld	a5,24(sp)
ffffffffc0204cc0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cc4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cc6:	14b87863          	bgeu	a6,a1,ffffffffc0204e16 <do_execve+0x464>
ffffffffc0204cca:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204cce:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0204cd0:	9bb2                	add	s7,s7,a2
ffffffffc0204cd2:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204cd4:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0204cd6:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204cd8:	70a000ef          	jal	ra,ffffffffc02053e2 <memcpy>
            start += size, from += size;
ffffffffc0204cdc:	6622                	ld	a2,8(sp)
ffffffffc0204cde:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204ce0:	054bf363          	bgeu	s7,s4,ffffffffc0204d26 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ce4:	6c88                	ld	a0,24(s1)
ffffffffc0204ce6:	866a                	mv	a2,s10
ffffffffc0204ce8:	85d6                	mv	a1,s5
ffffffffc0204cea:	946ff0ef          	jal	ra,ffffffffc0203e30 <pgdir_alloc_page>
ffffffffc0204cee:	842a                	mv	s0,a0
ffffffffc0204cf0:	f545                	bnez	a0,ffffffffc0204c98 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0204cf2:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0204cf4:	8526                	mv	a0,s1
ffffffffc0204cf6:	ff4fc0ef          	jal	ra,ffffffffc02014ea <exit_mmap>
    put_pgdir(mm);
ffffffffc0204cfa:	8526                	mv	a0,s1
ffffffffc0204cfc:	b66ff0ef          	jal	ra,ffffffffc0204062 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204d00:	8526                	mv	a0,s1
ffffffffc0204d02:	e4cfc0ef          	jal	ra,ffffffffc020134e <mm_destroy>
    return ret;
ffffffffc0204d06:	b705                	j	ffffffffc0204c26 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0204d08:	854e                	mv	a0,s3
ffffffffc0204d0a:	fe0fc0ef          	jal	ra,ffffffffc02014ea <exit_mmap>
            put_pgdir(mm);
ffffffffc0204d0e:	854e                	mv	a0,s3
ffffffffc0204d10:	b52ff0ef          	jal	ra,ffffffffc0204062 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204d14:	854e                	mv	a0,s3
ffffffffc0204d16:	e38fc0ef          	jal	ra,ffffffffc020134e <mm_destroy>
ffffffffc0204d1a:	b32d                	j	ffffffffc0204a44 <do_execve+0x92>
            vm_flags |= VM_WRITE;
ffffffffc0204d1c:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204d20:	fb95                	bnez	a5,ffffffffc0204c54 <do_execve+0x2a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0204d22:	4d5d                	li	s10,23
ffffffffc0204d24:	bf35                	j	ffffffffc0204c60 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204d26:	0109b683          	ld	a3,16(s3)
ffffffffc0204d2a:	0289b903          	ld	s2,40(s3)
ffffffffc0204d2e:	9936                	add	s2,s2,a3
        if (start < la)
ffffffffc0204d30:	075bfd63          	bgeu	s7,s5,ffffffffc0204daa <do_execve+0x3f8>
            if (start == end)
ffffffffc0204d34:	db790fe3          	beq	s2,s7,ffffffffc0204af2 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204d38:	6785                	lui	a5,0x1
ffffffffc0204d3a:	00fb8533          	add	a0,s7,a5
ffffffffc0204d3e:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0204d42:	41790a33          	sub	s4,s2,s7
            if (end < la)
ffffffffc0204d46:	0b597d63          	bgeu	s2,s5,ffffffffc0204e00 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0204d4a:	000cb683          	ld	a3,0(s9)
ffffffffc0204d4e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204d50:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0204d54:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d58:	8699                	srai	a3,a3,0x6
ffffffffc0204d5a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204d5c:	67e2                	ld	a5,24(sp)
ffffffffc0204d5e:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d62:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d64:	0ac5f963          	bgeu	a1,a2,ffffffffc0204e16 <do_execve+0x464>
ffffffffc0204d68:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204d6c:	8652                	mv	a2,s4
ffffffffc0204d6e:	4581                	li	a1,0
ffffffffc0204d70:	96c2                	add	a3,a3,a6
ffffffffc0204d72:	9536                	add	a0,a0,a3
ffffffffc0204d74:	65c000ef          	jal	ra,ffffffffc02053d0 <memset>
            start += size;
ffffffffc0204d78:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204d7c:	03597463          	bgeu	s2,s5,ffffffffc0204da4 <do_execve+0x3f2>
ffffffffc0204d80:	d6e909e3          	beq	s2,a4,ffffffffc0204af2 <do_execve+0x140>
ffffffffc0204d84:	00002697          	auipc	a3,0x2
ffffffffc0204d88:	52468693          	addi	a3,a3,1316 # ffffffffc02072a8 <default_pmm_manager+0x898>
ffffffffc0204d8c:	00001617          	auipc	a2,0x1
ffffffffc0204d90:	5cc60613          	addi	a2,a2,1484 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204d94:	2af00593          	li	a1,687
ffffffffc0204d98:	00002517          	auipc	a0,0x2
ffffffffc0204d9c:	32050513          	addi	a0,a0,800 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204da0:	c7efb0ef          	jal	ra,ffffffffc020021e <__panic>
ffffffffc0204da4:	ff5710e3          	bne	a4,s5,ffffffffc0204d84 <do_execve+0x3d2>
ffffffffc0204da8:	8bd6                	mv	s7,s5
        while (start < end)
ffffffffc0204daa:	d52bf4e3          	bgeu	s7,s2,ffffffffc0204af2 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204dae:	6c88                	ld	a0,24(s1)
ffffffffc0204db0:	866a                	mv	a2,s10
ffffffffc0204db2:	85d6                	mv	a1,s5
ffffffffc0204db4:	87cff0ef          	jal	ra,ffffffffc0203e30 <pgdir_alloc_page>
ffffffffc0204db8:	842a                	mv	s0,a0
ffffffffc0204dba:	dd05                	beqz	a0,ffffffffc0204cf2 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204dbc:	6785                	lui	a5,0x1
ffffffffc0204dbe:	415b8533          	sub	a0,s7,s5
ffffffffc0204dc2:	9abe                	add	s5,s5,a5
ffffffffc0204dc4:	417a8633          	sub	a2,s5,s7
            if (end < la)
ffffffffc0204dc8:	01597463          	bgeu	s2,s5,ffffffffc0204dd0 <do_execve+0x41e>
                size -= la - end;
ffffffffc0204dcc:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0204dd0:	000cb683          	ld	a3,0(s9)
ffffffffc0204dd4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0204dd6:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204dda:	40d406b3          	sub	a3,s0,a3
ffffffffc0204dde:	8699                	srai	a3,a3,0x6
ffffffffc0204de0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204de2:	67e2                	ld	a5,24(sp)
ffffffffc0204de4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204de8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204dea:	02b87663          	bgeu	a6,a1,ffffffffc0204e16 <do_execve+0x464>
ffffffffc0204dee:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204df2:	4581                	li	a1,0
            start += size;
ffffffffc0204df4:	9bb2                	add	s7,s7,a2
ffffffffc0204df6:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0204df8:	9536                	add	a0,a0,a3
ffffffffc0204dfa:	5d6000ef          	jal	ra,ffffffffc02053d0 <memset>
ffffffffc0204dfe:	b775                	j	ffffffffc0204daa <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204e00:	417a8a33          	sub	s4,s5,s7
ffffffffc0204e04:	b799                	j	ffffffffc0204d4a <do_execve+0x398>
        return -E_INVAL;
ffffffffc0204e06:	5a75                	li	s4,-3
ffffffffc0204e08:	b3c1                	j	ffffffffc0204bc8 <do_execve+0x216>
        while (start < end)
ffffffffc0204e0a:	86de                	mv	a3,s7
ffffffffc0204e0c:	bf39                	j	ffffffffc0204d2a <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0204e0e:	5a71                	li	s4,-4
ffffffffc0204e10:	bdc5                	j	ffffffffc0204d00 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0204e12:	5a61                	li	s4,-8
ffffffffc0204e14:	b5c5                	j	ffffffffc0204cf4 <do_execve+0x342>
ffffffffc0204e16:	00001617          	auipc	a2,0x1
ffffffffc0204e1a:	48a60613          	addi	a2,a2,1162 # ffffffffc02062a0 <commands+0x7f8>
ffffffffc0204e1e:	07300593          	li	a1,115
ffffffffc0204e22:	00001517          	auipc	a0,0x1
ffffffffc0204e26:	43e50513          	addi	a0,a0,1086 # ffffffffc0206260 <commands+0x7b8>
ffffffffc0204e2a:	bf4fb0ef          	jal	ra,ffffffffc020021e <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204e2e:	00002617          	auipc	a2,0x2
ffffffffc0204e32:	81260613          	addi	a2,a2,-2030 # ffffffffc0206640 <commands+0xb98>
ffffffffc0204e36:	2ce00593          	li	a1,718
ffffffffc0204e3a:	00002517          	auipc	a0,0x2
ffffffffc0204e3e:	27e50513          	addi	a0,a0,638 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204e42:	bdcfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204e46:	00002697          	auipc	a3,0x2
ffffffffc0204e4a:	57a68693          	addi	a3,a3,1402 # ffffffffc02073c0 <default_pmm_manager+0x9b0>
ffffffffc0204e4e:	00001617          	auipc	a2,0x1
ffffffffc0204e52:	50a60613          	addi	a2,a2,1290 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204e56:	2c900593          	li	a1,713
ffffffffc0204e5a:	00002517          	auipc	a0,0x2
ffffffffc0204e5e:	25e50513          	addi	a0,a0,606 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204e62:	bbcfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204e66:	00002697          	auipc	a3,0x2
ffffffffc0204e6a:	51268693          	addi	a3,a3,1298 # ffffffffc0207378 <default_pmm_manager+0x968>
ffffffffc0204e6e:	00001617          	auipc	a2,0x1
ffffffffc0204e72:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204e76:	2c800593          	li	a1,712
ffffffffc0204e7a:	00002517          	auipc	a0,0x2
ffffffffc0204e7e:	23e50513          	addi	a0,a0,574 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204e82:	b9cfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204e86:	00002697          	auipc	a3,0x2
ffffffffc0204e8a:	4aa68693          	addi	a3,a3,1194 # ffffffffc0207330 <default_pmm_manager+0x920>
ffffffffc0204e8e:	00001617          	auipc	a2,0x1
ffffffffc0204e92:	4ca60613          	addi	a2,a2,1226 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204e96:	2c700593          	li	a1,711
ffffffffc0204e9a:	00002517          	auipc	a0,0x2
ffffffffc0204e9e:	21e50513          	addi	a0,a0,542 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204ea2:	b7cfb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204ea6:	00002697          	auipc	a3,0x2
ffffffffc0204eaa:	44268693          	addi	a3,a3,1090 # ffffffffc02072e8 <default_pmm_manager+0x8d8>
ffffffffc0204eae:	00001617          	auipc	a2,0x1
ffffffffc0204eb2:	4aa60613          	addi	a2,a2,1194 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0204eb6:	2c600593          	li	a1,710
ffffffffc0204eba:	00002517          	auipc	a0,0x2
ffffffffc0204ebe:	1fe50513          	addi	a0,a0,510 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0204ec2:	b5cfb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0204ec6 <do_yield>:
    current->need_resched = 1;
ffffffffc0204ec6:	000b0797          	auipc	a5,0xb0
ffffffffc0204eca:	26a7b783          	ld	a5,618(a5) # ffffffffc02b5130 <current>
ffffffffc0204ece:	4705                	li	a4,1
ffffffffc0204ed0:	ef98                	sd	a4,24(a5)
}
ffffffffc0204ed2:	4501                	li	a0,0
ffffffffc0204ed4:	8082                	ret

ffffffffc0204ed6 <do_wait>:
{
ffffffffc0204ed6:	1101                	addi	sp,sp,-32
ffffffffc0204ed8:	e822                	sd	s0,16(sp)
ffffffffc0204eda:	e426                	sd	s1,8(sp)
ffffffffc0204edc:	ec06                	sd	ra,24(sp)
ffffffffc0204ede:	842e                	mv	s0,a1
ffffffffc0204ee0:	84aa                	mv	s1,a0
    if (code_store != NULL)
ffffffffc0204ee2:	c999                	beqz	a1,ffffffffc0204ef8 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0204ee4:	000b0797          	auipc	a5,0xb0
ffffffffc0204ee8:	24c7b783          	ld	a5,588(a5) # ffffffffc02b5130 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204eec:	7788                	ld	a0,40(a5)
ffffffffc0204eee:	4685                	li	a3,1
ffffffffc0204ef0:	4611                	li	a2,4
ffffffffc0204ef2:	993fc0ef          	jal	ra,ffffffffc0201884 <user_mem_check>
ffffffffc0204ef6:	c909                	beqz	a0,ffffffffc0204f08 <do_wait+0x32>
ffffffffc0204ef8:	85a2                	mv	a1,s0
}
ffffffffc0204efa:	6442                	ld	s0,16(sp)
ffffffffc0204efc:	60e2                	ld	ra,24(sp)
ffffffffc0204efe:	8526                	mv	a0,s1
ffffffffc0204f00:	64a2                	ld	s1,8(sp)
ffffffffc0204f02:	6105                	addi	sp,sp,32
ffffffffc0204f04:	fb8ff06f          	j	ffffffffc02046bc <do_wait.part.0>
ffffffffc0204f08:	60e2                	ld	ra,24(sp)
ffffffffc0204f0a:	6442                	ld	s0,16(sp)
ffffffffc0204f0c:	64a2                	ld	s1,8(sp)
ffffffffc0204f0e:	5575                	li	a0,-3
ffffffffc0204f10:	6105                	addi	sp,sp,32
ffffffffc0204f12:	8082                	ret

ffffffffc0204f14 <do_kill>:
{
ffffffffc0204f14:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f16:	6789                	lui	a5,0x2
{
ffffffffc0204f18:	e406                	sd	ra,8(sp)
ffffffffc0204f1a:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID)
ffffffffc0204f1c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204f20:	17f9                	addi	a5,a5,-2
ffffffffc0204f22:	02e7e963          	bltu	a5,a4,ffffffffc0204f54 <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f26:	842a                	mv	s0,a0
ffffffffc0204f28:	45a9                	li	a1,10
ffffffffc0204f2a:	2501                	sext.w	a0,a0
ffffffffc0204f2c:	0bd000ef          	jal	ra,ffffffffc02057e8 <hash32>
ffffffffc0204f30:	02051793          	slli	a5,a0,0x20
ffffffffc0204f34:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204f38:	000ac797          	auipc	a5,0xac
ffffffffc0204f3c:	18078793          	addi	a5,a5,384 # ffffffffc02b10b8 <hash_list>
ffffffffc0204f40:	953e                	add	a0,a0,a5
ffffffffc0204f42:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204f44:	a029                	j	ffffffffc0204f4e <do_kill+0x3a>
            if (proc->pid == pid)
ffffffffc0204f46:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204f4a:	00870b63          	beq	a4,s0,ffffffffc0204f60 <do_kill+0x4c>
ffffffffc0204f4e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204f50:	fef51be3          	bne	a0,a5,ffffffffc0204f46 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0204f54:	5475                	li	s0,-3
}
ffffffffc0204f56:	60a2                	ld	ra,8(sp)
ffffffffc0204f58:	8522                	mv	a0,s0
ffffffffc0204f5a:	6402                	ld	s0,0(sp)
ffffffffc0204f5c:	0141                	addi	sp,sp,16
ffffffffc0204f5e:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204f60:	fd87a703          	lw	a4,-40(a5)
ffffffffc0204f64:	00177693          	andi	a3,a4,1
ffffffffc0204f68:	e295                	bnez	a3,ffffffffc0204f8c <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204f6a:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0204f6c:	00176713          	ori	a4,a4,1
ffffffffc0204f70:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0204f74:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204f76:	fe06d0e3          	bgez	a3,ffffffffc0204f56 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0204f7a:	f2878513          	addi	a0,a5,-216
ffffffffc0204f7e:	1c4000ef          	jal	ra,ffffffffc0205142 <wakeup_proc>
}
ffffffffc0204f82:	60a2                	ld	ra,8(sp)
ffffffffc0204f84:	8522                	mv	a0,s0
ffffffffc0204f86:	6402                	ld	s0,0(sp)
ffffffffc0204f88:	0141                	addi	sp,sp,16
ffffffffc0204f8a:	8082                	ret
        return -E_KILLED;
ffffffffc0204f8c:	545d                	li	s0,-9
ffffffffc0204f8e:	b7e1                	j	ffffffffc0204f56 <do_kill+0x42>

ffffffffc0204f90 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204f90:	1101                	addi	sp,sp,-32
ffffffffc0204f92:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204f94:	000b0797          	auipc	a5,0xb0
ffffffffc0204f98:	12478793          	addi	a5,a5,292 # ffffffffc02b50b8 <proc_list>
ffffffffc0204f9c:	ec06                	sd	ra,24(sp)
ffffffffc0204f9e:	e822                	sd	s0,16(sp)
ffffffffc0204fa0:	e04a                	sd	s2,0(sp)
ffffffffc0204fa2:	000ac497          	auipc	s1,0xac
ffffffffc0204fa6:	11648493          	addi	s1,s1,278 # ffffffffc02b10b8 <hash_list>
ffffffffc0204faa:	e79c                	sd	a5,8(a5)
ffffffffc0204fac:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204fae:	000b0717          	auipc	a4,0xb0
ffffffffc0204fb2:	10a70713          	addi	a4,a4,266 # ffffffffc02b50b8 <proc_list>
ffffffffc0204fb6:	87a6                	mv	a5,s1
ffffffffc0204fb8:	e79c                	sd	a5,8(a5)
ffffffffc0204fba:	e39c                	sd	a5,0(a5)
ffffffffc0204fbc:	07c1                	addi	a5,a5,16
ffffffffc0204fbe:	fef71de3          	bne	a4,a5,ffffffffc0204fb8 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204fc2:	fa3fe0ef          	jal	ra,ffffffffc0203f64 <alloc_proc>
ffffffffc0204fc6:	000b0917          	auipc	s2,0xb0
ffffffffc0204fca:	17290913          	addi	s2,s2,370 # ffffffffc02b5138 <idleproc>
ffffffffc0204fce:	00a93023          	sd	a0,0(s2)
ffffffffc0204fd2:	0e050f63          	beqz	a0,ffffffffc02050d0 <proc_init+0x140>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204fd6:	4789                	li	a5,2
ffffffffc0204fd8:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204fda:	00003797          	auipc	a5,0x3
ffffffffc0204fde:	02678793          	addi	a5,a5,38 # ffffffffc0208000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fe2:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204fe6:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0204fe8:	4785                	li	a5,1
ffffffffc0204fea:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204fec:	4641                	li	a2,16
ffffffffc0204fee:	4581                	li	a1,0
ffffffffc0204ff0:	8522                	mv	a0,s0
ffffffffc0204ff2:	3de000ef          	jal	ra,ffffffffc02053d0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ff6:	463d                	li	a2,15
ffffffffc0204ff8:	00002597          	auipc	a1,0x2
ffffffffc0204ffc:	42858593          	addi	a1,a1,1064 # ffffffffc0207420 <default_pmm_manager+0xa10>
ffffffffc0205000:	8522                	mv	a0,s0
ffffffffc0205002:	3e0000ef          	jal	ra,ffffffffc02053e2 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205006:	000b0717          	auipc	a4,0xb0
ffffffffc020500a:	14270713          	addi	a4,a4,322 # ffffffffc02b5148 <nr_process>
ffffffffc020500e:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205010:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205014:	4601                	li	a2,0
    nr_process++;
ffffffffc0205016:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205018:	4581                	li	a1,0
ffffffffc020501a:	00000517          	auipc	a0,0x0
ffffffffc020501e:	87450513          	addi	a0,a0,-1932 # ffffffffc020488e <init_main>
    nr_process++;
ffffffffc0205022:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205024:	000b0797          	auipc	a5,0xb0
ffffffffc0205028:	10d7b623          	sd	a3,268(a5) # ffffffffc02b5130 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020502c:	cf6ff0ef          	jal	ra,ffffffffc0204522 <kernel_thread>
ffffffffc0205030:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205032:	08a05363          	blez	a0,ffffffffc02050b8 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205036:	6789                	lui	a5,0x2
ffffffffc0205038:	fff5071b          	addiw	a4,a0,-1
ffffffffc020503c:	17f9                	addi	a5,a5,-2
ffffffffc020503e:	2501                	sext.w	a0,a0
ffffffffc0205040:	02e7e363          	bltu	a5,a4,ffffffffc0205066 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205044:	45a9                	li	a1,10
ffffffffc0205046:	7a2000ef          	jal	ra,ffffffffc02057e8 <hash32>
ffffffffc020504a:	02051793          	slli	a5,a0,0x20
ffffffffc020504e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205052:	96a6                	add	a3,a3,s1
ffffffffc0205054:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205056:	a029                	j	ffffffffc0205060 <proc_init+0xd0>
            if (proc->pid == pid)
ffffffffc0205058:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7c9c>
ffffffffc020505c:	04870b63          	beq	a4,s0,ffffffffc02050b2 <proc_init+0x122>
    return listelm->next;
ffffffffc0205060:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205062:	fef69be3          	bne	a3,a5,ffffffffc0205058 <proc_init+0xc8>
    return NULL;
ffffffffc0205066:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205068:	0b478493          	addi	s1,a5,180
ffffffffc020506c:	4641                	li	a2,16
ffffffffc020506e:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205070:	000b0417          	auipc	s0,0xb0
ffffffffc0205074:	0d040413          	addi	s0,s0,208 # ffffffffc02b5140 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205078:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020507a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020507c:	354000ef          	jal	ra,ffffffffc02053d0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205080:	463d                	li	a2,15
ffffffffc0205082:	00002597          	auipc	a1,0x2
ffffffffc0205086:	3c658593          	addi	a1,a1,966 # ffffffffc0207448 <default_pmm_manager+0xa38>
ffffffffc020508a:	8526                	mv	a0,s1
ffffffffc020508c:	356000ef          	jal	ra,ffffffffc02053e2 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205090:	00093783          	ld	a5,0(s2)
ffffffffc0205094:	cbb5                	beqz	a5,ffffffffc0205108 <proc_init+0x178>
ffffffffc0205096:	43dc                	lw	a5,4(a5)
ffffffffc0205098:	eba5                	bnez	a5,ffffffffc0205108 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020509a:	601c                	ld	a5,0(s0)
ffffffffc020509c:	c7b1                	beqz	a5,ffffffffc02050e8 <proc_init+0x158>
ffffffffc020509e:	43d8                	lw	a4,4(a5)
ffffffffc02050a0:	4785                	li	a5,1
ffffffffc02050a2:	04f71363          	bne	a4,a5,ffffffffc02050e8 <proc_init+0x158>
}
ffffffffc02050a6:	60e2                	ld	ra,24(sp)
ffffffffc02050a8:	6442                	ld	s0,16(sp)
ffffffffc02050aa:	64a2                	ld	s1,8(sp)
ffffffffc02050ac:	6902                	ld	s2,0(sp)
ffffffffc02050ae:	6105                	addi	sp,sp,32
ffffffffc02050b0:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02050b2:	f2878793          	addi	a5,a5,-216
ffffffffc02050b6:	bf4d                	j	ffffffffc0205068 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc02050b8:	00002617          	auipc	a2,0x2
ffffffffc02050bc:	37060613          	addi	a2,a2,880 # ffffffffc0207428 <default_pmm_manager+0xa18>
ffffffffc02050c0:	3ea00593          	li	a1,1002
ffffffffc02050c4:	00002517          	auipc	a0,0x2
ffffffffc02050c8:	ff450513          	addi	a0,a0,-12 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc02050cc:	952fb0ef          	jal	ra,ffffffffc020021e <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02050d0:	00002617          	auipc	a2,0x2
ffffffffc02050d4:	33860613          	addi	a2,a2,824 # ffffffffc0207408 <default_pmm_manager+0x9f8>
ffffffffc02050d8:	3db00593          	li	a1,987
ffffffffc02050dc:	00002517          	auipc	a0,0x2
ffffffffc02050e0:	fdc50513          	addi	a0,a0,-36 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc02050e4:	93afb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02050e8:	00002697          	auipc	a3,0x2
ffffffffc02050ec:	39068693          	addi	a3,a3,912 # ffffffffc0207478 <default_pmm_manager+0xa68>
ffffffffc02050f0:	00001617          	auipc	a2,0x1
ffffffffc02050f4:	26860613          	addi	a2,a2,616 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02050f8:	3f100593          	li	a1,1009
ffffffffc02050fc:	00002517          	auipc	a0,0x2
ffffffffc0205100:	fbc50513          	addi	a0,a0,-68 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0205104:	91afb0ef          	jal	ra,ffffffffc020021e <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205108:	00002697          	auipc	a3,0x2
ffffffffc020510c:	34868693          	addi	a3,a3,840 # ffffffffc0207450 <default_pmm_manager+0xa40>
ffffffffc0205110:	00001617          	auipc	a2,0x1
ffffffffc0205114:	24860613          	addi	a2,a2,584 # ffffffffc0206358 <commands+0x8b0>
ffffffffc0205118:	3f000593          	li	a1,1008
ffffffffc020511c:	00002517          	auipc	a0,0x2
ffffffffc0205120:	f9c50513          	addi	a0,a0,-100 # ffffffffc02070b8 <default_pmm_manager+0x6a8>
ffffffffc0205124:	8fafb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc0205128 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205128:	1141                	addi	sp,sp,-16
ffffffffc020512a:	e022                	sd	s0,0(sp)
ffffffffc020512c:	e406                	sd	ra,8(sp)
ffffffffc020512e:	000b0417          	auipc	s0,0xb0
ffffffffc0205132:	00240413          	addi	s0,s0,2 # ffffffffc02b5130 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205136:	6018                	ld	a4,0(s0)
ffffffffc0205138:	6f1c                	ld	a5,24(a4)
ffffffffc020513a:	dffd                	beqz	a5,ffffffffc0205138 <cpu_idle+0x10>
        {
            schedule();
ffffffffc020513c:	086000ef          	jal	ra,ffffffffc02051c2 <schedule>
ffffffffc0205140:	bfdd                	j	ffffffffc0205136 <cpu_idle+0xe>

ffffffffc0205142 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205142:	4118                	lw	a4,0(a0)
{
ffffffffc0205144:	1101                	addi	sp,sp,-32
ffffffffc0205146:	ec06                	sd	ra,24(sp)
ffffffffc0205148:	e822                	sd	s0,16(sp)
ffffffffc020514a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020514c:	478d                	li	a5,3
ffffffffc020514e:	04f70b63          	beq	a4,a5,ffffffffc02051a4 <wakeup_proc+0x62>
ffffffffc0205152:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0205154:	100027f3          	csrr	a5,sstatus
ffffffffc0205158:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020515a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020515c:	ef9d                	bnez	a5,ffffffffc020519a <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc020515e:	4789                	li	a5,2
ffffffffc0205160:	02f70163          	beq	a4,a5,ffffffffc0205182 <wakeup_proc+0x40>
        {
            proc->state = PROC_RUNNABLE;
ffffffffc0205164:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205166:	0e042623          	sw	zero,236(s0)
    if (flag)
ffffffffc020516a:	e491                	bnez	s1,ffffffffc0205176 <wakeup_proc+0x34>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020516c:	60e2                	ld	ra,24(sp)
ffffffffc020516e:	6442                	ld	s0,16(sp)
ffffffffc0205170:	64a2                	ld	s1,8(sp)
ffffffffc0205172:	6105                	addi	sp,sp,32
ffffffffc0205174:	8082                	ret
ffffffffc0205176:	6442                	ld	s0,16(sp)
ffffffffc0205178:	60e2                	ld	ra,24(sp)
ffffffffc020517a:	64a2                	ld	s1,8(sp)
ffffffffc020517c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020517e:	837fb06f          	j	ffffffffc02009b4 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205182:	00002617          	auipc	a2,0x2
ffffffffc0205186:	35660613          	addi	a2,a2,854 # ffffffffc02074d8 <default_pmm_manager+0xac8>
ffffffffc020518a:	45d1                	li	a1,20
ffffffffc020518c:	00002517          	auipc	a0,0x2
ffffffffc0205190:	33450513          	addi	a0,a0,820 # ffffffffc02074c0 <default_pmm_manager+0xab0>
ffffffffc0205194:	8f2fb0ef          	jal	ra,ffffffffc0200286 <__warn>
ffffffffc0205198:	bfc9                	j	ffffffffc020516a <wakeup_proc+0x28>
        intr_disable();
ffffffffc020519a:	821fb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc020519e:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc02051a0:	4485                	li	s1,1
ffffffffc02051a2:	bf75                	j	ffffffffc020515e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02051a4:	00002697          	auipc	a3,0x2
ffffffffc02051a8:	2fc68693          	addi	a3,a3,764 # ffffffffc02074a0 <default_pmm_manager+0xa90>
ffffffffc02051ac:	00001617          	auipc	a2,0x1
ffffffffc02051b0:	1ac60613          	addi	a2,a2,428 # ffffffffc0206358 <commands+0x8b0>
ffffffffc02051b4:	45a5                	li	a1,9
ffffffffc02051b6:	00002517          	auipc	a0,0x2
ffffffffc02051ba:	30a50513          	addi	a0,a0,778 # ffffffffc02074c0 <default_pmm_manager+0xab0>
ffffffffc02051be:	860fb0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc02051c2 <schedule>:

void schedule(void)
{
ffffffffc02051c2:	1141                	addi	sp,sp,-16
ffffffffc02051c4:	e406                	sd	ra,8(sp)
ffffffffc02051c6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02051c8:	100027f3          	csrr	a5,sstatus
ffffffffc02051cc:	8b89                	andi	a5,a5,2
ffffffffc02051ce:	4401                	li	s0,0
ffffffffc02051d0:	efbd                	bnez	a5,ffffffffc020524e <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02051d2:	000b0897          	auipc	a7,0xb0
ffffffffc02051d6:	f5e8b883          	ld	a7,-162(a7) # ffffffffc02b5130 <current>
ffffffffc02051da:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02051de:	000b0517          	auipc	a0,0xb0
ffffffffc02051e2:	f5a53503          	ld	a0,-166(a0) # ffffffffc02b5138 <idleproc>
ffffffffc02051e6:	04a88e63          	beq	a7,a0,ffffffffc0205242 <schedule+0x80>
ffffffffc02051ea:	0c888693          	addi	a3,a7,200
ffffffffc02051ee:	000b0617          	auipc	a2,0xb0
ffffffffc02051f2:	eca60613          	addi	a2,a2,-310 # ffffffffc02b50b8 <proc_list>
        le = last;
ffffffffc02051f6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02051f8:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc02051fa:	4809                	li	a6,2
ffffffffc02051fc:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc02051fe:	00c78863          	beq	a5,a2,ffffffffc020520e <schedule+0x4c>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205202:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205206:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc020520a:	03070163          	beq	a4,a6,ffffffffc020522c <schedule+0x6a>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc020520e:	fef697e3          	bne	a3,a5,ffffffffc02051fc <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205212:	ed89                	bnez	a1,ffffffffc020522c <schedule+0x6a>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205214:	451c                	lw	a5,8(a0)
ffffffffc0205216:	2785                	addiw	a5,a5,1
ffffffffc0205218:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc020521a:	00a88463          	beq	a7,a0,ffffffffc0205222 <schedule+0x60>
        {
            proc_run(next);
ffffffffc020521e:	ebbfe0ef          	jal	ra,ffffffffc02040d8 <proc_run>
    if (flag)
ffffffffc0205222:	e819                	bnez	s0,ffffffffc0205238 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205224:	60a2                	ld	ra,8(sp)
ffffffffc0205226:	6402                	ld	s0,0(sp)
ffffffffc0205228:	0141                	addi	sp,sp,16
ffffffffc020522a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc020522c:	4198                	lw	a4,0(a1)
ffffffffc020522e:	4789                	li	a5,2
ffffffffc0205230:	fef712e3          	bne	a4,a5,ffffffffc0205214 <schedule+0x52>
ffffffffc0205234:	852e                	mv	a0,a1
ffffffffc0205236:	bff9                	j	ffffffffc0205214 <schedule+0x52>
}
ffffffffc0205238:	6402                	ld	s0,0(sp)
ffffffffc020523a:	60a2                	ld	ra,8(sp)
ffffffffc020523c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020523e:	f76fb06f          	j	ffffffffc02009b4 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205242:	000b0617          	auipc	a2,0xb0
ffffffffc0205246:	e7660613          	addi	a2,a2,-394 # ffffffffc02b50b8 <proc_list>
ffffffffc020524a:	86b2                	mv	a3,a2
ffffffffc020524c:	b76d                	j	ffffffffc02051f6 <schedule+0x34>
        intr_disable();
ffffffffc020524e:	f6cfb0ef          	jal	ra,ffffffffc02009ba <intr_disable>
        return 1;
ffffffffc0205252:	4405                	li	s0,1
ffffffffc0205254:	bfbd                	j	ffffffffc02051d2 <schedule+0x10>

ffffffffc0205256 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205256:	000b0797          	auipc	a5,0xb0
ffffffffc020525a:	eda7b783          	ld	a5,-294(a5) # ffffffffc02b5130 <current>
}
ffffffffc020525e:	43c8                	lw	a0,4(a5)
ffffffffc0205260:	8082                	ret

ffffffffc0205262 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205262:	4501                	li	a0,0
ffffffffc0205264:	8082                	ret

ffffffffc0205266 <sys_putc>:
    cputchar(c);
ffffffffc0205266:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205268:	1141                	addi	sp,sp,-16
ffffffffc020526a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020526c:	eabfa0ef          	jal	ra,ffffffffc0200116 <cputchar>
}
ffffffffc0205270:	60a2                	ld	ra,8(sp)
ffffffffc0205272:	4501                	li	a0,0
ffffffffc0205274:	0141                	addi	sp,sp,16
ffffffffc0205276:	8082                	ret

ffffffffc0205278 <sys_kill>:
    return do_kill(pid);
ffffffffc0205278:	4108                	lw	a0,0(a0)
ffffffffc020527a:	c9bff06f          	j	ffffffffc0204f14 <do_kill>

ffffffffc020527e <sys_yield>:
    return do_yield();
ffffffffc020527e:	c49ff06f          	j	ffffffffc0204ec6 <do_yield>

ffffffffc0205282 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205282:	6d14                	ld	a3,24(a0)
ffffffffc0205284:	6910                	ld	a2,16(a0)
ffffffffc0205286:	650c                	ld	a1,8(a0)
ffffffffc0205288:	6108                	ld	a0,0(a0)
ffffffffc020528a:	f28ff06f          	j	ffffffffc02049b2 <do_execve>

ffffffffc020528e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020528e:	650c                	ld	a1,8(a0)
ffffffffc0205290:	4108                	lw	a0,0(a0)
ffffffffc0205292:	c45ff06f          	j	ffffffffc0204ed6 <do_wait>

ffffffffc0205296 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205296:	000b0797          	auipc	a5,0xb0
ffffffffc020529a:	e9a7b783          	ld	a5,-358(a5) # ffffffffc02b5130 <current>
ffffffffc020529e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02052a0:	4501                	li	a0,0
ffffffffc02052a2:	6a0c                	ld	a1,16(a2)
ffffffffc02052a4:	ea1fe06f          	j	ffffffffc0204144 <do_fork>

ffffffffc02052a8 <sys_exit>:
    return do_exit(error_code);
ffffffffc02052a8:	4108                	lw	a0,0(a0)
ffffffffc02052aa:	ac8ff06f          	j	ffffffffc0204572 <do_exit>

ffffffffc02052ae <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc02052ae:	715d                	addi	sp,sp,-80
ffffffffc02052b0:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc02052b2:	000b0497          	auipc	s1,0xb0
ffffffffc02052b6:	e7e48493          	addi	s1,s1,-386 # ffffffffc02b5130 <current>
ffffffffc02052ba:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc02052bc:	e0a2                	sd	s0,64(sp)
ffffffffc02052be:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02052c0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02052c2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02052c4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02052c6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02052ca:	0327ee63          	bltu	a5,s2,ffffffffc0205306 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02052ce:	00391713          	slli	a4,s2,0x3
ffffffffc02052d2:	00002797          	auipc	a5,0x2
ffffffffc02052d6:	26e78793          	addi	a5,a5,622 # ffffffffc0207540 <syscalls>
ffffffffc02052da:	97ba                	add	a5,a5,a4
ffffffffc02052dc:	639c                	ld	a5,0(a5)
ffffffffc02052de:	c785                	beqz	a5,ffffffffc0205306 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02052e0:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02052e2:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02052e4:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02052e6:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02052e8:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02052ea:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02052ec:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02052ee:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02052f0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02052f2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052f4:	0028                	addi	a0,sp,8
ffffffffc02052f6:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02052f8:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02052fa:	e828                	sd	a0,80(s0)
}
ffffffffc02052fc:	6406                	ld	s0,64(sp)
ffffffffc02052fe:	74e2                	ld	s1,56(sp)
ffffffffc0205300:	7942                	ld	s2,48(sp)
ffffffffc0205302:	6161                	addi	sp,sp,80
ffffffffc0205304:	8082                	ret
    print_trapframe(tf);
ffffffffc0205306:	8522                	mv	a0,s0
ffffffffc0205308:	8a1fb0ef          	jal	ra,ffffffffc0200ba8 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020530c:	609c                	ld	a5,0(s1)
ffffffffc020530e:	86ca                	mv	a3,s2
ffffffffc0205310:	00002617          	auipc	a2,0x2
ffffffffc0205314:	1e860613          	addi	a2,a2,488 # ffffffffc02074f8 <default_pmm_manager+0xae8>
ffffffffc0205318:	43d8                	lw	a4,4(a5)
ffffffffc020531a:	06200593          	li	a1,98
ffffffffc020531e:	0b478793          	addi	a5,a5,180
ffffffffc0205322:	00002517          	auipc	a0,0x2
ffffffffc0205326:	20650513          	addi	a0,a0,518 # ffffffffc0207528 <default_pmm_manager+0xb18>
ffffffffc020532a:	ef5fa0ef          	jal	ra,ffffffffc020021e <__panic>

ffffffffc020532e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020532e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0205332:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0205334:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0205336:	cb81                	beqz	a5,ffffffffc0205346 <strlen+0x18>
        cnt ++;
ffffffffc0205338:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020533a:	00a707b3          	add	a5,a4,a0
ffffffffc020533e:	0007c783          	lbu	a5,0(a5)
ffffffffc0205342:	fbfd                	bnez	a5,ffffffffc0205338 <strlen+0xa>
ffffffffc0205344:	8082                	ret
    }
    return cnt;
}
ffffffffc0205346:	8082                	ret

ffffffffc0205348 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205348:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020534a:	e589                	bnez	a1,ffffffffc0205354 <strnlen+0xc>
ffffffffc020534c:	a811                	j	ffffffffc0205360 <strnlen+0x18>
        cnt ++;
ffffffffc020534e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205350:	00f58863          	beq	a1,a5,ffffffffc0205360 <strnlen+0x18>
ffffffffc0205354:	00f50733          	add	a4,a0,a5
ffffffffc0205358:	00074703          	lbu	a4,0(a4)
ffffffffc020535c:	fb6d                	bnez	a4,ffffffffc020534e <strnlen+0x6>
ffffffffc020535e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205360:	852e                	mv	a0,a1
ffffffffc0205362:	8082                	ret

ffffffffc0205364 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205364:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205366:	0005c703          	lbu	a4,0(a1)
ffffffffc020536a:	0785                	addi	a5,a5,1
ffffffffc020536c:	0585                	addi	a1,a1,1
ffffffffc020536e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205372:	fb75                	bnez	a4,ffffffffc0205366 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205374:	8082                	ret

ffffffffc0205376 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205376:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020537a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020537e:	cb89                	beqz	a5,ffffffffc0205390 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0205380:	0505                	addi	a0,a0,1
ffffffffc0205382:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205384:	fee789e3          	beq	a5,a4,ffffffffc0205376 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205388:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020538c:	9d19                	subw	a0,a0,a4
ffffffffc020538e:	8082                	ret
ffffffffc0205390:	4501                	li	a0,0
ffffffffc0205392:	bfed                	j	ffffffffc020538c <strcmp+0x16>

ffffffffc0205394 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205394:	c20d                	beqz	a2,ffffffffc02053b6 <strncmp+0x22>
ffffffffc0205396:	962e                	add	a2,a2,a1
ffffffffc0205398:	a031                	j	ffffffffc02053a4 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc020539a:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020539c:	00e79a63          	bne	a5,a4,ffffffffc02053b0 <strncmp+0x1c>
ffffffffc02053a0:	00b60b63          	beq	a2,a1,ffffffffc02053b6 <strncmp+0x22>
ffffffffc02053a4:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02053a8:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02053aa:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02053ae:	f7f5                	bnez	a5,ffffffffc020539a <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02053b0:	40e7853b          	subw	a0,a5,a4
}
ffffffffc02053b4:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02053b6:	4501                	li	a0,0
ffffffffc02053b8:	8082                	ret

ffffffffc02053ba <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02053ba:	00054783          	lbu	a5,0(a0)
ffffffffc02053be:	c799                	beqz	a5,ffffffffc02053cc <strchr+0x12>
        if (*s == c) {
ffffffffc02053c0:	00f58763          	beq	a1,a5,ffffffffc02053ce <strchr+0x14>
    while (*s != '\0') {
ffffffffc02053c4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02053c8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02053ca:	fbfd                	bnez	a5,ffffffffc02053c0 <strchr+0x6>
    }
    return NULL;
ffffffffc02053cc:	4501                	li	a0,0
}
ffffffffc02053ce:	8082                	ret

ffffffffc02053d0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02053d0:	ca01                	beqz	a2,ffffffffc02053e0 <memset+0x10>
ffffffffc02053d2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02053d4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02053d6:	0785                	addi	a5,a5,1
ffffffffc02053d8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02053dc:	fec79de3          	bne	a5,a2,ffffffffc02053d6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02053e0:	8082                	ret

ffffffffc02053e2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02053e2:	ca19                	beqz	a2,ffffffffc02053f8 <memcpy+0x16>
ffffffffc02053e4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02053e6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02053e8:	0005c703          	lbu	a4,0(a1)
ffffffffc02053ec:	0585                	addi	a1,a1,1
ffffffffc02053ee:	0785                	addi	a5,a5,1
ffffffffc02053f0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02053f4:	fec59ae3          	bne	a1,a2,ffffffffc02053e8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02053f8:	8082                	ret

ffffffffc02053fa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02053fa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02053fe:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205400:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205404:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205406:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020540a:	f022                	sd	s0,32(sp)
ffffffffc020540c:	ec26                	sd	s1,24(sp)
ffffffffc020540e:	e84a                	sd	s2,16(sp)
ffffffffc0205410:	f406                	sd	ra,40(sp)
ffffffffc0205412:	e44e                	sd	s3,8(sp)
ffffffffc0205414:	84aa                	mv	s1,a0
ffffffffc0205416:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205418:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020541c:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020541e:	03067e63          	bgeu	a2,a6,ffffffffc020545a <printnum+0x60>
ffffffffc0205422:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205424:	00805763          	blez	s0,ffffffffc0205432 <printnum+0x38>
ffffffffc0205428:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020542a:	85ca                	mv	a1,s2
ffffffffc020542c:	854e                	mv	a0,s3
ffffffffc020542e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205430:	fc65                	bnez	s0,ffffffffc0205428 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205432:	1a02                	slli	s4,s4,0x20
ffffffffc0205434:	00002797          	auipc	a5,0x2
ffffffffc0205438:	20c78793          	addi	a5,a5,524 # ffffffffc0207640 <syscalls+0x100>
ffffffffc020543c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205440:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205442:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205444:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205448:	70a2                	ld	ra,40(sp)
ffffffffc020544a:	69a2                	ld	s3,8(sp)
ffffffffc020544c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020544e:	85ca                	mv	a1,s2
ffffffffc0205450:	87a6                	mv	a5,s1
}
ffffffffc0205452:	6942                	ld	s2,16(sp)
ffffffffc0205454:	64e2                	ld	s1,24(sp)
ffffffffc0205456:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205458:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020545a:	03065633          	divu	a2,a2,a6
ffffffffc020545e:	8722                	mv	a4,s0
ffffffffc0205460:	f9bff0ef          	jal	ra,ffffffffc02053fa <printnum>
ffffffffc0205464:	b7f9                	j	ffffffffc0205432 <printnum+0x38>

ffffffffc0205466 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205466:	7119                	addi	sp,sp,-128
ffffffffc0205468:	f4a6                	sd	s1,104(sp)
ffffffffc020546a:	f0ca                	sd	s2,96(sp)
ffffffffc020546c:	ecce                	sd	s3,88(sp)
ffffffffc020546e:	e8d2                	sd	s4,80(sp)
ffffffffc0205470:	e4d6                	sd	s5,72(sp)
ffffffffc0205472:	e0da                	sd	s6,64(sp)
ffffffffc0205474:	fc5e                	sd	s7,56(sp)
ffffffffc0205476:	f06a                	sd	s10,32(sp)
ffffffffc0205478:	fc86                	sd	ra,120(sp)
ffffffffc020547a:	f8a2                	sd	s0,112(sp)
ffffffffc020547c:	f862                	sd	s8,48(sp)
ffffffffc020547e:	f466                	sd	s9,40(sp)
ffffffffc0205480:	ec6e                	sd	s11,24(sp)
ffffffffc0205482:	892a                	mv	s2,a0
ffffffffc0205484:	84ae                	mv	s1,a1
ffffffffc0205486:	8d32                	mv	s10,a2
ffffffffc0205488:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020548a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020548e:	5b7d                	li	s6,-1
ffffffffc0205490:	00002a97          	auipc	s5,0x2
ffffffffc0205494:	1dca8a93          	addi	s5,s5,476 # ffffffffc020766c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205498:	00002b97          	auipc	s7,0x2
ffffffffc020549c:	3f0b8b93          	addi	s7,s7,1008 # ffffffffc0207888 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02054a0:	000d4503          	lbu	a0,0(s10)
ffffffffc02054a4:	001d0413          	addi	s0,s10,1
ffffffffc02054a8:	01350a63          	beq	a0,s3,ffffffffc02054bc <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02054ac:	c121                	beqz	a0,ffffffffc02054ec <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02054ae:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02054b0:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02054b2:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02054b4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02054b8:	ff351ae3          	bne	a0,s3,ffffffffc02054ac <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054bc:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02054c0:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02054c4:	4c81                	li	s9,0
ffffffffc02054c6:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02054c8:	5c7d                	li	s8,-1
ffffffffc02054ca:	5dfd                	li	s11,-1
ffffffffc02054cc:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02054d0:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02054d2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02054d6:	0ff5f593          	zext.b	a1,a1
ffffffffc02054da:	00140d13          	addi	s10,s0,1
ffffffffc02054de:	04b56263          	bltu	a0,a1,ffffffffc0205522 <vprintfmt+0xbc>
ffffffffc02054e2:	058a                	slli	a1,a1,0x2
ffffffffc02054e4:	95d6                	add	a1,a1,s5
ffffffffc02054e6:	4194                	lw	a3,0(a1)
ffffffffc02054e8:	96d6                	add	a3,a3,s5
ffffffffc02054ea:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02054ec:	70e6                	ld	ra,120(sp)
ffffffffc02054ee:	7446                	ld	s0,112(sp)
ffffffffc02054f0:	74a6                	ld	s1,104(sp)
ffffffffc02054f2:	7906                	ld	s2,96(sp)
ffffffffc02054f4:	69e6                	ld	s3,88(sp)
ffffffffc02054f6:	6a46                	ld	s4,80(sp)
ffffffffc02054f8:	6aa6                	ld	s5,72(sp)
ffffffffc02054fa:	6b06                	ld	s6,64(sp)
ffffffffc02054fc:	7be2                	ld	s7,56(sp)
ffffffffc02054fe:	7c42                	ld	s8,48(sp)
ffffffffc0205500:	7ca2                	ld	s9,40(sp)
ffffffffc0205502:	7d02                	ld	s10,32(sp)
ffffffffc0205504:	6de2                	ld	s11,24(sp)
ffffffffc0205506:	6109                	addi	sp,sp,128
ffffffffc0205508:	8082                	ret
            padc = '0';
ffffffffc020550a:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020550c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205510:	846a                	mv	s0,s10
ffffffffc0205512:	00140d13          	addi	s10,s0,1
ffffffffc0205516:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020551a:	0ff5f593          	zext.b	a1,a1
ffffffffc020551e:	fcb572e3          	bgeu	a0,a1,ffffffffc02054e2 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0205522:	85a6                	mv	a1,s1
ffffffffc0205524:	02500513          	li	a0,37
ffffffffc0205528:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020552a:	fff44783          	lbu	a5,-1(s0)
ffffffffc020552e:	8d22                	mv	s10,s0
ffffffffc0205530:	f73788e3          	beq	a5,s3,ffffffffc02054a0 <vprintfmt+0x3a>
ffffffffc0205534:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0205538:	1d7d                	addi	s10,s10,-1
ffffffffc020553a:	ff379de3          	bne	a5,s3,ffffffffc0205534 <vprintfmt+0xce>
ffffffffc020553e:	b78d                	j	ffffffffc02054a0 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0205540:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0205544:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205548:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020554a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020554e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205552:	02d86463          	bltu	a6,a3,ffffffffc020557a <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0205556:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020555a:	002c169b          	slliw	a3,s8,0x2
ffffffffc020555e:	0186873b          	addw	a4,a3,s8
ffffffffc0205562:	0017171b          	slliw	a4,a4,0x1
ffffffffc0205566:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0205568:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020556c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020556e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0205572:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205576:	fed870e3          	bgeu	a6,a3,ffffffffc0205556 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020557a:	f40ddce3          	bgez	s11,ffffffffc02054d2 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020557e:	8de2                	mv	s11,s8
ffffffffc0205580:	5c7d                	li	s8,-1
ffffffffc0205582:	bf81                	j	ffffffffc02054d2 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0205584:	fffdc693          	not	a3,s11
ffffffffc0205588:	96fd                	srai	a3,a3,0x3f
ffffffffc020558a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020558e:	00144603          	lbu	a2,1(s0)
ffffffffc0205592:	2d81                	sext.w	s11,s11
ffffffffc0205594:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0205596:	bf35                	j	ffffffffc02054d2 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0205598:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020559c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02055a0:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055a2:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02055a4:	bfd9                	j	ffffffffc020557a <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02055a6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055a8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055ac:	01174463          	blt	a4,a7,ffffffffc02055b4 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02055b0:	1a088e63          	beqz	a7,ffffffffc020576c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02055b4:	000a3603          	ld	a2,0(s4)
ffffffffc02055b8:	46c1                	li	a3,16
ffffffffc02055ba:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02055bc:	2781                	sext.w	a5,a5
ffffffffc02055be:	876e                	mv	a4,s11
ffffffffc02055c0:	85a6                	mv	a1,s1
ffffffffc02055c2:	854a                	mv	a0,s2
ffffffffc02055c4:	e37ff0ef          	jal	ra,ffffffffc02053fa <printnum>
            break;
ffffffffc02055c8:	bde1                	j	ffffffffc02054a0 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02055ca:	000a2503          	lw	a0,0(s4)
ffffffffc02055ce:	85a6                	mv	a1,s1
ffffffffc02055d0:	0a21                	addi	s4,s4,8
ffffffffc02055d2:	9902                	jalr	s2
            break;
ffffffffc02055d4:	b5f1                	j	ffffffffc02054a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02055d6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02055d8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02055dc:	01174463          	blt	a4,a7,ffffffffc02055e4 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02055e0:	18088163          	beqz	a7,ffffffffc0205762 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02055e4:	000a3603          	ld	a2,0(s4)
ffffffffc02055e8:	46a9                	li	a3,10
ffffffffc02055ea:	8a2e                	mv	s4,a1
ffffffffc02055ec:	bfc1                	j	ffffffffc02055bc <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055ee:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02055f2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055f4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02055f6:	bdf1                	j	ffffffffc02054d2 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02055f8:	85a6                	mv	a1,s1
ffffffffc02055fa:	02500513          	li	a0,37
ffffffffc02055fe:	9902                	jalr	s2
            break;
ffffffffc0205600:	b545                	j	ffffffffc02054a0 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205602:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0205606:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205608:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020560a:	b5e1                	j	ffffffffc02054d2 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020560c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020560e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205612:	01174463          	blt	a4,a7,ffffffffc020561a <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0205616:	14088163          	beqz	a7,ffffffffc0205758 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020561a:	000a3603          	ld	a2,0(s4)
ffffffffc020561e:	46a1                	li	a3,8
ffffffffc0205620:	8a2e                	mv	s4,a1
ffffffffc0205622:	bf69                	j	ffffffffc02055bc <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0205624:	03000513          	li	a0,48
ffffffffc0205628:	85a6                	mv	a1,s1
ffffffffc020562a:	e03e                	sd	a5,0(sp)
ffffffffc020562c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020562e:	85a6                	mv	a1,s1
ffffffffc0205630:	07800513          	li	a0,120
ffffffffc0205634:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205636:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205638:	6782                	ld	a5,0(sp)
ffffffffc020563a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020563c:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0205640:	bfb5                	j	ffffffffc02055bc <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205642:	000a3403          	ld	s0,0(s4)
ffffffffc0205646:	008a0713          	addi	a4,s4,8
ffffffffc020564a:	e03a                	sd	a4,0(sp)
ffffffffc020564c:	14040263          	beqz	s0,ffffffffc0205790 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0205650:	0fb05763          	blez	s11,ffffffffc020573e <vprintfmt+0x2d8>
ffffffffc0205654:	02d00693          	li	a3,45
ffffffffc0205658:	0cd79163          	bne	a5,a3,ffffffffc020571a <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020565c:	00044783          	lbu	a5,0(s0)
ffffffffc0205660:	0007851b          	sext.w	a0,a5
ffffffffc0205664:	cf85                	beqz	a5,ffffffffc020569c <vprintfmt+0x236>
ffffffffc0205666:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020566a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020566e:	000c4563          	bltz	s8,ffffffffc0205678 <vprintfmt+0x212>
ffffffffc0205672:	3c7d                	addiw	s8,s8,-1
ffffffffc0205674:	036c0263          	beq	s8,s6,ffffffffc0205698 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0205678:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020567a:	0e0c8e63          	beqz	s9,ffffffffc0205776 <vprintfmt+0x310>
ffffffffc020567e:	3781                	addiw	a5,a5,-32
ffffffffc0205680:	0ef47b63          	bgeu	s0,a5,ffffffffc0205776 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0205684:	03f00513          	li	a0,63
ffffffffc0205688:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020568a:	000a4783          	lbu	a5,0(s4)
ffffffffc020568e:	3dfd                	addiw	s11,s11,-1
ffffffffc0205690:	0a05                	addi	s4,s4,1
ffffffffc0205692:	0007851b          	sext.w	a0,a5
ffffffffc0205696:	ffe1                	bnez	a5,ffffffffc020566e <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0205698:	01b05963          	blez	s11,ffffffffc02056aa <vprintfmt+0x244>
ffffffffc020569c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020569e:	85a6                	mv	a1,s1
ffffffffc02056a0:	02000513          	li	a0,32
ffffffffc02056a4:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02056a6:	fe0d9be3          	bnez	s11,ffffffffc020569c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056aa:	6a02                	ld	s4,0(sp)
ffffffffc02056ac:	bbd5                	j	ffffffffc02054a0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02056ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02056b0:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02056b4:	01174463          	blt	a4,a7,ffffffffc02056bc <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02056b8:	08088d63          	beqz	a7,ffffffffc0205752 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02056bc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02056c0:	0a044d63          	bltz	s0,ffffffffc020577a <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02056c4:	8622                	mv	a2,s0
ffffffffc02056c6:	8a66                	mv	s4,s9
ffffffffc02056c8:	46a9                	li	a3,10
ffffffffc02056ca:	bdcd                	j	ffffffffc02055bc <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02056cc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02056d0:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02056d2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02056d4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02056d8:	8fb5                	xor	a5,a5,a3
ffffffffc02056da:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02056de:	02d74163          	blt	a4,a3,ffffffffc0205700 <vprintfmt+0x29a>
ffffffffc02056e2:	00369793          	slli	a5,a3,0x3
ffffffffc02056e6:	97de                	add	a5,a5,s7
ffffffffc02056e8:	639c                	ld	a5,0(a5)
ffffffffc02056ea:	cb99                	beqz	a5,ffffffffc0205700 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02056ec:	86be                	mv	a3,a5
ffffffffc02056ee:	00000617          	auipc	a2,0x0
ffffffffc02056f2:	13a60613          	addi	a2,a2,314 # ffffffffc0205828 <etext+0x2a>
ffffffffc02056f6:	85a6                	mv	a1,s1
ffffffffc02056f8:	854a                	mv	a0,s2
ffffffffc02056fa:	0ce000ef          	jal	ra,ffffffffc02057c8 <printfmt>
ffffffffc02056fe:	b34d                	j	ffffffffc02054a0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205700:	00002617          	auipc	a2,0x2
ffffffffc0205704:	f6060613          	addi	a2,a2,-160 # ffffffffc0207660 <syscalls+0x120>
ffffffffc0205708:	85a6                	mv	a1,s1
ffffffffc020570a:	854a                	mv	a0,s2
ffffffffc020570c:	0bc000ef          	jal	ra,ffffffffc02057c8 <printfmt>
ffffffffc0205710:	bb41                	j	ffffffffc02054a0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0205712:	00002417          	auipc	s0,0x2
ffffffffc0205716:	f4640413          	addi	s0,s0,-186 # ffffffffc0207658 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020571a:	85e2                	mv	a1,s8
ffffffffc020571c:	8522                	mv	a0,s0
ffffffffc020571e:	e43e                	sd	a5,8(sp)
ffffffffc0205720:	c29ff0ef          	jal	ra,ffffffffc0205348 <strnlen>
ffffffffc0205724:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0205728:	01b05b63          	blez	s11,ffffffffc020573e <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020572c:	67a2                	ld	a5,8(sp)
ffffffffc020572e:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205732:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0205734:	85a6                	mv	a1,s1
ffffffffc0205736:	8552                	mv	a0,s4
ffffffffc0205738:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020573a:	fe0d9ce3          	bnez	s11,ffffffffc0205732 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020573e:	00044783          	lbu	a5,0(s0)
ffffffffc0205742:	00140a13          	addi	s4,s0,1
ffffffffc0205746:	0007851b          	sext.w	a0,a5
ffffffffc020574a:	d3a5                	beqz	a5,ffffffffc02056aa <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020574c:	05e00413          	li	s0,94
ffffffffc0205750:	bf39                	j	ffffffffc020566e <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0205752:	000a2403          	lw	s0,0(s4)
ffffffffc0205756:	b7ad                	j	ffffffffc02056c0 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0205758:	000a6603          	lwu	a2,0(s4)
ffffffffc020575c:	46a1                	li	a3,8
ffffffffc020575e:	8a2e                	mv	s4,a1
ffffffffc0205760:	bdb1                	j	ffffffffc02055bc <vprintfmt+0x156>
ffffffffc0205762:	000a6603          	lwu	a2,0(s4)
ffffffffc0205766:	46a9                	li	a3,10
ffffffffc0205768:	8a2e                	mv	s4,a1
ffffffffc020576a:	bd89                	j	ffffffffc02055bc <vprintfmt+0x156>
ffffffffc020576c:	000a6603          	lwu	a2,0(s4)
ffffffffc0205770:	46c1                	li	a3,16
ffffffffc0205772:	8a2e                	mv	s4,a1
ffffffffc0205774:	b5a1                	j	ffffffffc02055bc <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0205776:	9902                	jalr	s2
ffffffffc0205778:	bf09                	j	ffffffffc020568a <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020577a:	85a6                	mv	a1,s1
ffffffffc020577c:	02d00513          	li	a0,45
ffffffffc0205780:	e03e                	sd	a5,0(sp)
ffffffffc0205782:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0205784:	6782                	ld	a5,0(sp)
ffffffffc0205786:	8a66                	mv	s4,s9
ffffffffc0205788:	40800633          	neg	a2,s0
ffffffffc020578c:	46a9                	li	a3,10
ffffffffc020578e:	b53d                	j	ffffffffc02055bc <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0205790:	03b05163          	blez	s11,ffffffffc02057b2 <vprintfmt+0x34c>
ffffffffc0205794:	02d00693          	li	a3,45
ffffffffc0205798:	f6d79de3          	bne	a5,a3,ffffffffc0205712 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020579c:	00002417          	auipc	s0,0x2
ffffffffc02057a0:	ebc40413          	addi	s0,s0,-324 # ffffffffc0207658 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057a4:	02800793          	li	a5,40
ffffffffc02057a8:	02800513          	li	a0,40
ffffffffc02057ac:	00140a13          	addi	s4,s0,1
ffffffffc02057b0:	bd6d                	j	ffffffffc020566a <vprintfmt+0x204>
ffffffffc02057b2:	00002a17          	auipc	s4,0x2
ffffffffc02057b6:	ea7a0a13          	addi	s4,s4,-345 # ffffffffc0207659 <syscalls+0x119>
ffffffffc02057ba:	02800513          	li	a0,40
ffffffffc02057be:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02057c2:	05e00413          	li	s0,94
ffffffffc02057c6:	b565                	j	ffffffffc020566e <vprintfmt+0x208>

ffffffffc02057c8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02057c8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02057ca:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02057ce:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02057d0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02057d2:	ec06                	sd	ra,24(sp)
ffffffffc02057d4:	f83a                	sd	a4,48(sp)
ffffffffc02057d6:	fc3e                	sd	a5,56(sp)
ffffffffc02057d8:	e0c2                	sd	a6,64(sp)
ffffffffc02057da:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02057dc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02057de:	c89ff0ef          	jal	ra,ffffffffc0205466 <vprintfmt>
}
ffffffffc02057e2:	60e2                	ld	ra,24(sp)
ffffffffc02057e4:	6161                	addi	sp,sp,80
ffffffffc02057e6:	8082                	ret

ffffffffc02057e8 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02057e8:	9e3707b7          	lui	a5,0x9e370
ffffffffc02057ec:	2785                	addiw	a5,a5,1
ffffffffc02057ee:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02057f2:	02000793          	li	a5,32
ffffffffc02057f6:	9f8d                	subw	a5,a5,a1
}
ffffffffc02057f8:	00f5553b          	srlw	a0,a0,a5
ffffffffc02057fc:	8082                	ret
