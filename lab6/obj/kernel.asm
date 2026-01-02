
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
ffffffffc020004a:	000e1517          	auipc	a0,0xe1
ffffffffc020004e:	cee50513          	addi	a0,a0,-786 # ffffffffc02e0d38 <buf>
ffffffffc0200052:	000e5617          	auipc	a2,0xe5
ffffffffc0200056:	22e60613          	addi	a2,a2,558 # ffffffffc02e5280 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc020aff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	70e050ef          	jal	ffffffffc0205770 <memset>
    cons_init(); // init the console
ffffffffc0200066:	025000ef          	jal	ffffffffc020088a <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	b1658593          	addi	a1,a1,-1258 # ffffffffc0205b80 <etext+0x4>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	b2e50513          	addi	a0,a0,-1234 # ffffffffc0205ba0 <etext+0x24>
ffffffffc020007a:	068000ef          	jal	ffffffffc02000e2 <cprintf>

    print_kerninfo();
ffffffffc020007e:	25c000ef          	jal	ffffffffc02002da <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	478000ef          	jal	ffffffffc02004fa <dtb_init>

    pmm_init(); // init physical memory management
ffffffffc0200086:	004030ef          	jal	ffffffffc020308a <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	073000ef          	jal	ffffffffc02008fc <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	07d000ef          	jal	ffffffffc020090a <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	42e010ef          	jal	ffffffffc02014c0 <vmm_init>
    sched_init();
ffffffffc0200096:	2f4050ef          	jal	ffffffffc020538a <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	010050ef          	jal	ffffffffc02050aa <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	7a2000ef          	jal	ffffffffc0200840 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	05d000ef          	jal	ffffffffc02008fe <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	1a4050ef          	jal	ffffffffc020524a <cpu_idle>

ffffffffc02000aa <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc02000aa:	1101                	addi	sp,sp,-32
ffffffffc02000ac:	ec06                	sd	ra,24(sp)
ffffffffc02000ae:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc02000b0:	7dc000ef          	jal	ffffffffc020088c <cons_putc>
    (*cnt)++;
ffffffffc02000b4:	65a2                	ld	a1,8(sp)
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
    (*cnt)++;
ffffffffc02000b8:	419c                	lw	a5,0(a1)
ffffffffc02000ba:	2785                	addiw	a5,a5,1
ffffffffc02000bc:	c19c                	sw	a5,0(a1)
}
ffffffffc02000be:	6105                	addi	sp,sp,32
ffffffffc02000c0:	8082                	ret

ffffffffc02000c2 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc02000c2:	1101                	addi	sp,sp,-32
ffffffffc02000c4:	862a                	mv	a2,a0
ffffffffc02000c6:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fe250513          	addi	a0,a0,-30 # ffffffffc02000aa <cputch>
ffffffffc02000d0:	006c                	addi	a1,sp,12
{
ffffffffc02000d2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d4:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000d6:	72a050ef          	jal	ffffffffc0205800 <vprintfmt>
    return cnt;
}
ffffffffc02000da:	60e2                	ld	ra,24(sp)
ffffffffc02000dc:	4532                	lw	a0,12(sp)
ffffffffc02000de:	6105                	addi	sp,sp,32
ffffffffc02000e0:	8082                	ret

ffffffffc02000e2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc02000e2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e4:	02810313          	addi	t1,sp,40
{
ffffffffc02000e8:	f42e                	sd	a1,40(sp)
ffffffffc02000ea:	f832                	sd	a2,48(sp)
ffffffffc02000ec:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ee:	862a                	mv	a2,a0
ffffffffc02000f0:	004c                	addi	a1,sp,4
ffffffffc02000f2:	00000517          	auipc	a0,0x0
ffffffffc02000f6:	fb850513          	addi	a0,a0,-72 # ffffffffc02000aa <cputch>
ffffffffc02000fa:	869a                	mv	a3,t1
{
ffffffffc02000fc:	ec06                	sd	ra,24(sp)
ffffffffc02000fe:	e0ba                	sd	a4,64(sp)
ffffffffc0200100:	e4be                	sd	a5,72(sp)
ffffffffc0200102:	e8c2                	sd	a6,80(sp)
ffffffffc0200104:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc0200106:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc0200108:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020010a:	6f6050ef          	jal	ffffffffc0205800 <vprintfmt>
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
ffffffffc0200116:	7760006f          	j	ffffffffc020088c <cons_putc>

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
ffffffffc0200120:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc0200122:	00054503          	lbu	a0,0(a0)
ffffffffc0200126:	c51d                	beqz	a0,ffffffffc0200154 <cputs+0x3a>
ffffffffc0200128:	e426                	sd	s1,8(sp)
ffffffffc020012a:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc020012c:	4481                	li	s1,0
    cons_putc(c);
ffffffffc020012e:	75e000ef          	jal	ffffffffc020088c <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc0200132:	00044503          	lbu	a0,0(s0)
ffffffffc0200136:	0405                	addi	s0,s0,1
ffffffffc0200138:	87a6                	mv	a5,s1
    (*cnt)++;
ffffffffc020013a:	2485                	addiw	s1,s1,1
    while ((c = *str++) != '\0')
ffffffffc020013c:	f96d                	bnez	a0,ffffffffc020012e <cputs+0x14>
    cons_putc(c);
ffffffffc020013e:	4529                	li	a0,10
    (*cnt)++;
ffffffffc0200140:	0027841b          	addiw	s0,a5,2
ffffffffc0200144:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc0200146:	746000ef          	jal	ffffffffc020088c <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020014a:	60e2                	ld	ra,24(sp)
ffffffffc020014c:	8522                	mv	a0,s0
ffffffffc020014e:	6442                	ld	s0,16(sp)
ffffffffc0200150:	6105                	addi	sp,sp,32
ffffffffc0200152:	8082                	ret
    cons_putc(c);
ffffffffc0200154:	4529                	li	a0,10
ffffffffc0200156:	736000ef          	jal	ffffffffc020088c <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc020015a:	4405                	li	s0,1
}
ffffffffc020015c:	60e2                	ld	ra,24(sp)
ffffffffc020015e:	8522                	mv	a0,s0
ffffffffc0200160:	6442                	ld	s0,16(sp)
ffffffffc0200162:	6105                	addi	sp,sp,32
ffffffffc0200164:	8082                	ret

ffffffffc0200166 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc0200166:	1141                	addi	sp,sp,-16
ffffffffc0200168:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020016a:	756000ef          	jal	ffffffffc02008c0 <cons_getc>
ffffffffc020016e:	dd75                	beqz	a0,ffffffffc020016a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200170:	60a2                	ld	ra,8(sp)
ffffffffc0200172:	0141                	addi	sp,sp,16
ffffffffc0200174:	8082                	ret

ffffffffc0200176 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200176:	7179                	addi	sp,sp,-48
ffffffffc0200178:	f406                	sd	ra,40(sp)
ffffffffc020017a:	f022                	sd	s0,32(sp)
ffffffffc020017c:	ec26                	sd	s1,24(sp)
ffffffffc020017e:	e84a                	sd	s2,16(sp)
ffffffffc0200180:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc0200182:	c901                	beqz	a0,ffffffffc0200192 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc0200184:	85aa                	mv	a1,a0
ffffffffc0200186:	00006517          	auipc	a0,0x6
ffffffffc020018a:	a2250513          	addi	a0,a0,-1502 # ffffffffc0205ba8 <etext+0x2c>
ffffffffc020018e:	f55ff0ef          	jal	ffffffffc02000e2 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0200192:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200194:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc0200196:	000e1997          	auipc	s3,0xe1
ffffffffc020019a:	ba298993          	addi	s3,s3,-1118 # ffffffffc02e0d38 <buf>
        c = getchar();
ffffffffc020019e:	fc9ff0ef          	jal	ffffffffc0200166 <getchar>
ffffffffc02001a2:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc02001a4:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001a8:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02001ac:	ff650693          	addi	a3,a0,-10
ffffffffc02001b0:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02001b4:	02054963          	bltz	a0,ffffffffc02001e6 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b8:	02a95f63          	bge	s2,a0,ffffffffc02001f6 <readline+0x80>
ffffffffc02001bc:	cf0d                	beqz	a4,ffffffffc02001f6 <readline+0x80>
            cputchar(c);
ffffffffc02001be:	f59ff0ef          	jal	ffffffffc0200116 <cputchar>
            buf[i ++] = c;
ffffffffc02001c2:	009987b3          	add	a5,s3,s1
ffffffffc02001c6:	00878023          	sb	s0,0(a5)
ffffffffc02001ca:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc02001cc:	f9bff0ef          	jal	ffffffffc0200166 <getchar>
ffffffffc02001d0:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc02001d2:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001d6:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc02001da:	ff650693          	addi	a3,a0,-10
ffffffffc02001de:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02001e2:	fc055be3          	bgez	a0,ffffffffc02001b8 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc02001e6:	70a2                	ld	ra,40(sp)
ffffffffc02001e8:	7402                	ld	s0,32(sp)
ffffffffc02001ea:	64e2                	ld	s1,24(sp)
ffffffffc02001ec:	6942                	ld	s2,16(sp)
ffffffffc02001ee:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc02001f0:	4501                	li	a0,0
}
ffffffffc02001f2:	6145                	addi	sp,sp,48
ffffffffc02001f4:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc02001f6:	eb81                	bnez	a5,ffffffffc0200206 <readline+0x90>
            cputchar(c);
ffffffffc02001f8:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc02001fa:	00905663          	blez	s1,ffffffffc0200206 <readline+0x90>
            cputchar(c);
ffffffffc02001fe:	f19ff0ef          	jal	ffffffffc0200116 <cputchar>
            i --;
ffffffffc0200202:	34fd                	addiw	s1,s1,-1
ffffffffc0200204:	bf69                	j	ffffffffc020019e <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0200206:	c291                	beqz	a3,ffffffffc020020a <readline+0x94>
ffffffffc0200208:	fa59                	bnez	a2,ffffffffc020019e <readline+0x28>
            cputchar(c);
ffffffffc020020a:	8522                	mv	a0,s0
ffffffffc020020c:	f0bff0ef          	jal	ffffffffc0200116 <cputchar>
            buf[i] = '\0';
ffffffffc0200210:	000e1517          	auipc	a0,0xe1
ffffffffc0200214:	b2850513          	addi	a0,a0,-1240 # ffffffffc02e0d38 <buf>
ffffffffc0200218:	94aa                	add	s1,s1,a0
ffffffffc020021a:	00048023          	sb	zero,0(s1)
}
ffffffffc020021e:	70a2                	ld	ra,40(sp)
ffffffffc0200220:	7402                	ld	s0,32(sp)
ffffffffc0200222:	64e2                	ld	s1,24(sp)
ffffffffc0200224:	6942                	ld	s2,16(sp)
ffffffffc0200226:	69a2                	ld	s3,8(sp)
ffffffffc0200228:	6145                	addi	sp,sp,48
ffffffffc020022a:	8082                	ret

ffffffffc020022c <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020022c:	000e5317          	auipc	t1,0xe5
ffffffffc0200230:	fc433303          	ld	t1,-60(t1) # ffffffffc02e51f0 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200234:	715d                	addi	sp,sp,-80
ffffffffc0200236:	ec06                	sd	ra,24(sp)
ffffffffc0200238:	f436                	sd	a3,40(sp)
ffffffffc020023a:	f83a                	sd	a4,48(sp)
ffffffffc020023c:	fc3e                	sd	a5,56(sp)
ffffffffc020023e:	e0c2                	sd	a6,64(sp)
ffffffffc0200240:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200242:	02031e63          	bnez	t1,ffffffffc020027e <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200246:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200248:	103c                	addi	a5,sp,40
ffffffffc020024a:	e822                	sd	s0,16(sp)
ffffffffc020024c:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020024e:	862e                	mv	a2,a1
ffffffffc0200250:	85aa                	mv	a1,a0
ffffffffc0200252:	00006517          	auipc	a0,0x6
ffffffffc0200256:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205bb0 <etext+0x34>
    is_panic = 1;
ffffffffc020025a:	000e5697          	auipc	a3,0xe5
ffffffffc020025e:	f8e6bb23          	sd	a4,-106(a3) # ffffffffc02e51f0 <is_panic>
    va_start(ap, fmt);
ffffffffc0200262:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200264:	e7fff0ef          	jal	ffffffffc02000e2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200268:	65a2                	ld	a1,8(sp)
ffffffffc020026a:	8522                	mv	a0,s0
ffffffffc020026c:	e57ff0ef          	jal	ffffffffc02000c2 <vcprintf>
    cprintf("\n");
ffffffffc0200270:	00006517          	auipc	a0,0x6
ffffffffc0200274:	96050513          	addi	a0,a0,-1696 # ffffffffc0205bd0 <etext+0x54>
ffffffffc0200278:	e6bff0ef          	jal	ffffffffc02000e2 <cprintf>
ffffffffc020027c:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020027e:	4501                	li	a0,0
ffffffffc0200280:	4581                	li	a1,0
ffffffffc0200282:	4601                	li	a2,0
ffffffffc0200284:	48a1                	li	a7,8
ffffffffc0200286:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc020028a:	67a000ef          	jal	ffffffffc0200904 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020028e:	4501                	li	a0,0
ffffffffc0200290:	14c000ef          	jal	ffffffffc02003dc <kmonitor>
    while (1) {
ffffffffc0200294:	bfed                	j	ffffffffc020028e <__panic+0x62>

ffffffffc0200296 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200296:	715d                	addi	sp,sp,-80
ffffffffc0200298:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
ffffffffc020029a:	02810313          	addi	t1,sp,40
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc020029e:	8432                	mv	s0,a2
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002a0:	862e                	mv	a2,a1
ffffffffc02002a2:	85aa                	mv	a1,a0
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	93450513          	addi	a0,a0,-1740 # ffffffffc0205bd8 <etext+0x5c>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02002ac:	ec06                	sd	ra,24(sp)
ffffffffc02002ae:	f436                	sd	a3,40(sp)
ffffffffc02002b0:	f83a                	sd	a4,48(sp)
ffffffffc02002b2:	fc3e                	sd	a5,56(sp)
ffffffffc02002b4:	e0c2                	sd	a6,64(sp)
ffffffffc02002b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002b8:	e41a                	sd	t1,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002ba:	e29ff0ef          	jal	ffffffffc02000e2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002be:	65a2                	ld	a1,8(sp)
ffffffffc02002c0:	8522                	mv	a0,s0
ffffffffc02002c2:	e01ff0ef          	jal	ffffffffc02000c2 <vcprintf>
    cprintf("\n");
ffffffffc02002c6:	00006517          	auipc	a0,0x6
ffffffffc02002ca:	90a50513          	addi	a0,a0,-1782 # ffffffffc0205bd0 <etext+0x54>
ffffffffc02002ce:	e15ff0ef          	jal	ffffffffc02000e2 <cprintf>
    va_end(ap);
}
ffffffffc02002d2:	60e2                	ld	ra,24(sp)
ffffffffc02002d4:	6442                	ld	s0,16(sp)
ffffffffc02002d6:	6161                	addi	sp,sp,80
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02002da:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002dc:	00006517          	auipc	a0,0x6
ffffffffc02002e0:	91c50513          	addi	a0,a0,-1764 # ffffffffc0205bf8 <etext+0x7c>
void print_kerninfo(void) {
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002e6:	dfdff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002ea:	00000597          	auipc	a1,0x0
ffffffffc02002ee:	d6058593          	addi	a1,a1,-672 # ffffffffc020004a <kern_init>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	92650513          	addi	a0,a0,-1754 # ffffffffc0205c18 <etext+0x9c>
ffffffffc02002fa:	de9ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002fe:	00006597          	auipc	a1,0x6
ffffffffc0200302:	87e58593          	addi	a1,a1,-1922 # ffffffffc0205b7c <etext>
ffffffffc0200306:	00006517          	auipc	a0,0x6
ffffffffc020030a:	93250513          	addi	a0,a0,-1742 # ffffffffc0205c38 <etext+0xbc>
ffffffffc020030e:	dd5ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200312:	000e1597          	auipc	a1,0xe1
ffffffffc0200316:	a2658593          	addi	a1,a1,-1498 # ffffffffc02e0d38 <buf>
ffffffffc020031a:	00006517          	auipc	a0,0x6
ffffffffc020031e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205c58 <etext+0xdc>
ffffffffc0200322:	dc1ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200326:	000e5597          	auipc	a1,0xe5
ffffffffc020032a:	f5a58593          	addi	a1,a1,-166 # ffffffffc02e5280 <end>
ffffffffc020032e:	00006517          	auipc	a0,0x6
ffffffffc0200332:	94a50513          	addi	a0,a0,-1718 # ffffffffc0205c78 <etext+0xfc>
ffffffffc0200336:	dadff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020033a:	00000717          	auipc	a4,0x0
ffffffffc020033e:	d1070713          	addi	a4,a4,-752 # ffffffffc020004a <kern_init>
ffffffffc0200342:	000e5797          	auipc	a5,0xe5
ffffffffc0200346:	33d78793          	addi	a5,a5,829 # ffffffffc02e567f <end+0x3ff>
ffffffffc020034a:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020034c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200350:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200352:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200356:	95be                	add	a1,a1,a5
ffffffffc0200358:	85a9                	srai	a1,a1,0xa
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205c98 <etext+0x11c>
}
ffffffffc0200362:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200364:	bbbd                	j	ffffffffc02000e2 <cprintf>

ffffffffc0200366 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200366:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200368:	00006617          	auipc	a2,0x6
ffffffffc020036c:	96060613          	addi	a2,a2,-1696 # ffffffffc0205cc8 <etext+0x14c>
ffffffffc0200370:	04d00593          	li	a1,77
ffffffffc0200374:	00006517          	auipc	a0,0x6
ffffffffc0200378:	96c50513          	addi	a0,a0,-1684 # ffffffffc0205ce0 <etext+0x164>
void print_stackframe(void) {
ffffffffc020037c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020037e:	eafff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200382 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200382:	1101                	addi	sp,sp,-32
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	e426                	sd	s1,8(sp)
ffffffffc0200388:	ec06                	sd	ra,24(sp)
ffffffffc020038a:	00007417          	auipc	s0,0x7
ffffffffc020038e:	55e40413          	addi	s0,s0,1374 # ffffffffc02078e8 <commands>
ffffffffc0200392:	00007497          	auipc	s1,0x7
ffffffffc0200396:	59e48493          	addi	s1,s1,1438 # ffffffffc0207930 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020039a:	6410                	ld	a2,8(s0)
ffffffffc020039c:	600c                	ld	a1,0(s0)
ffffffffc020039e:	00006517          	auipc	a0,0x6
ffffffffc02003a2:	95a50513          	addi	a0,a0,-1702 # ffffffffc0205cf8 <etext+0x17c>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a6:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02003a8:	d3bff0ef          	jal	ffffffffc02000e2 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	fe9417e3          	bne	s0,s1,ffffffffc020039a <mon_help+0x18>
    }
    return 0;
}
ffffffffc02003b0:	60e2                	ld	ra,24(sp)
ffffffffc02003b2:	6442                	ld	s0,16(sp)
ffffffffc02003b4:	64a2                	ld	s1,8(sp)
ffffffffc02003b6:	4501                	li	a0,0
ffffffffc02003b8:	6105                	addi	sp,sp,32
ffffffffc02003ba:	8082                	ret

ffffffffc02003bc <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003bc:	1141                	addi	sp,sp,-16
ffffffffc02003be:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003c0:	f1bff0ef          	jal	ffffffffc02002da <print_kerninfo>
    return 0;
}
ffffffffc02003c4:	60a2                	ld	ra,8(sp)
ffffffffc02003c6:	4501                	li	a0,0
ffffffffc02003c8:	0141                	addi	sp,sp,16
ffffffffc02003ca:	8082                	ret

ffffffffc02003cc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02003cc:	1141                	addi	sp,sp,-16
ffffffffc02003ce:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003d0:	f97ff0ef          	jal	ffffffffc0200366 <print_stackframe>
    return 0;
}
ffffffffc02003d4:	60a2                	ld	ra,8(sp)
ffffffffc02003d6:	4501                	li	a0,0
ffffffffc02003d8:	0141                	addi	sp,sp,16
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02003dc:	7131                	addi	sp,sp,-192
ffffffffc02003de:	e952                	sd	s4,144(sp)
ffffffffc02003e0:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003e2:	00006517          	auipc	a0,0x6
ffffffffc02003e6:	92650513          	addi	a0,a0,-1754 # ffffffffc0205d08 <etext+0x18c>
kmonitor(struct trapframe *tf) {
ffffffffc02003ea:	fd06                	sd	ra,184(sp)
ffffffffc02003ec:	f922                	sd	s0,176(sp)
ffffffffc02003ee:	f526                	sd	s1,168(sp)
ffffffffc02003f0:	ed4e                	sd	s3,152(sp)
ffffffffc02003f2:	e556                	sd	s5,136(sp)
ffffffffc02003f4:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f6:	cedff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02003fa:	00006517          	auipc	a0,0x6
ffffffffc02003fe:	93650513          	addi	a0,a0,-1738 # ffffffffc0205d30 <etext+0x1b4>
ffffffffc0200402:	ce1ff0ef          	jal	ffffffffc02000e2 <cprintf>
    if (tf != NULL) {
ffffffffc0200406:	000a0563          	beqz	s4,ffffffffc0200410 <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc020040a:	8552                	mv	a0,s4
ffffffffc020040c:	6e6000ef          	jal	ffffffffc0200af2 <print_trapframe>
ffffffffc0200410:	00007a97          	auipc	s5,0x7
ffffffffc0200414:	4d8a8a93          	addi	s5,s5,1240 # ffffffffc02078e8 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200418:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020041a:	00006517          	auipc	a0,0x6
ffffffffc020041e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205d58 <etext+0x1dc>
ffffffffc0200422:	d55ff0ef          	jal	ffffffffc0200176 <readline>
ffffffffc0200426:	842a                	mv	s0,a0
ffffffffc0200428:	d96d                	beqz	a0,ffffffffc020041a <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020042a:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020042e:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200430:	e99d                	bnez	a1,ffffffffc0200466 <kmonitor+0x8a>
    int argc = 0;
ffffffffc0200432:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc0200434:	fe0b03e3          	beqz	s6,ffffffffc020041a <kmonitor+0x3e>
ffffffffc0200438:	00007497          	auipc	s1,0x7
ffffffffc020043c:	4b048493          	addi	s1,s1,1200 # ffffffffc02078e8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200440:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200442:	6582                	ld	a1,0(sp)
ffffffffc0200444:	6088                	ld	a0,0(s1)
ffffffffc0200446:	2bc050ef          	jal	ffffffffc0205702 <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020044a:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020044c:	c149                	beqz	a0,ffffffffc02004ce <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020044e:	2405                	addiw	s0,s0,1
ffffffffc0200450:	04e1                	addi	s1,s1,24
ffffffffc0200452:	fef418e3          	bne	s0,a5,ffffffffc0200442 <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200456:	6582                	ld	a1,0(sp)
ffffffffc0200458:	00006517          	auipc	a0,0x6
ffffffffc020045c:	93050513          	addi	a0,a0,-1744 # ffffffffc0205d88 <etext+0x20c>
ffffffffc0200460:	c83ff0ef          	jal	ffffffffc02000e2 <cprintf>
    return 0;
ffffffffc0200464:	bf5d                	j	ffffffffc020041a <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200466:	00006517          	auipc	a0,0x6
ffffffffc020046a:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0205d60 <etext+0x1e4>
ffffffffc020046e:	2f0050ef          	jal	ffffffffc020575e <strchr>
ffffffffc0200472:	c901                	beqz	a0,ffffffffc0200482 <kmonitor+0xa6>
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020047e:	d9d5                	beqz	a1,ffffffffc0200432 <kmonitor+0x56>
ffffffffc0200480:	b7dd                	j	ffffffffc0200466 <kmonitor+0x8a>
        if (*buf == '\0') {
ffffffffc0200482:	00044783          	lbu	a5,0(s0)
ffffffffc0200486:	d7d5                	beqz	a5,ffffffffc0200432 <kmonitor+0x56>
        if (argc == MAXARGS - 1) {
ffffffffc0200488:	03348b63          	beq	s1,s3,ffffffffc02004be <kmonitor+0xe2>
        argv[argc ++] = buf;
ffffffffc020048c:	00349793          	slli	a5,s1,0x3
ffffffffc0200490:	978a                	add	a5,a5,sp
ffffffffc0200492:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200494:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200498:	2485                	addiw	s1,s1,1
ffffffffc020049a:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020049c:	e591                	bnez	a1,ffffffffc02004a8 <kmonitor+0xcc>
ffffffffc020049e:	bf59                	j	ffffffffc0200434 <kmonitor+0x58>
ffffffffc02004a0:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02004a4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02004a6:	d5d1                	beqz	a1,ffffffffc0200432 <kmonitor+0x56>
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	8b850513          	addi	a0,a0,-1864 # ffffffffc0205d60 <etext+0x1e4>
ffffffffc02004b0:	2ae050ef          	jal	ffffffffc020575e <strchr>
ffffffffc02004b4:	d575                	beqz	a0,ffffffffc02004a0 <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02004b6:	00044583          	lbu	a1,0(s0)
ffffffffc02004ba:	dda5                	beqz	a1,ffffffffc0200432 <kmonitor+0x56>
ffffffffc02004bc:	b76d                	j	ffffffffc0200466 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02004be:	45c1                	li	a1,16
ffffffffc02004c0:	00006517          	auipc	a0,0x6
ffffffffc02004c4:	8a850513          	addi	a0,a0,-1880 # ffffffffc0205d68 <etext+0x1ec>
ffffffffc02004c8:	c1bff0ef          	jal	ffffffffc02000e2 <cprintf>
ffffffffc02004cc:	b7c1                	j	ffffffffc020048c <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ce:	00141793          	slli	a5,s0,0x1
ffffffffc02004d2:	97a2                	add	a5,a5,s0
ffffffffc02004d4:	078e                	slli	a5,a5,0x3
ffffffffc02004d6:	97d6                	add	a5,a5,s5
ffffffffc02004d8:	6b9c                	ld	a5,16(a5)
ffffffffc02004da:	fffb051b          	addiw	a0,s6,-1
ffffffffc02004de:	8652                	mv	a2,s4
ffffffffc02004e0:	002c                	addi	a1,sp,8
ffffffffc02004e2:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02004e4:	f2055be3          	bgez	a0,ffffffffc020041a <kmonitor+0x3e>
}
ffffffffc02004e8:	70ea                	ld	ra,184(sp)
ffffffffc02004ea:	744a                	ld	s0,176(sp)
ffffffffc02004ec:	74aa                	ld	s1,168(sp)
ffffffffc02004ee:	69ea                	ld	s3,152(sp)
ffffffffc02004f0:	6a4a                	ld	s4,144(sp)
ffffffffc02004f2:	6aaa                	ld	s5,136(sp)
ffffffffc02004f4:	6b0a                	ld	s6,128(sp)
ffffffffc02004f6:	6129                	addi	sp,sp,192
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02004fa:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc02004fc:	00006517          	auipc	a0,0x6
ffffffffc0200500:	93450513          	addi	a0,a0,-1740 # ffffffffc0205e30 <etext+0x2b4>
void dtb_init(void) {
ffffffffc0200504:	f406                	sd	ra,40(sp)
ffffffffc0200506:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200508:	bdbff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020050c:	0000c597          	auipc	a1,0xc
ffffffffc0200510:	af45b583          	ld	a1,-1292(a1) # ffffffffc020c000 <boot_hartid>
ffffffffc0200514:	00006517          	auipc	a0,0x6
ffffffffc0200518:	92c50513          	addi	a0,a0,-1748 # ffffffffc0205e40 <etext+0x2c4>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020051c:	0000c417          	auipc	s0,0xc
ffffffffc0200520:	aec40413          	addi	s0,s0,-1300 # ffffffffc020c008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200524:	bbfff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200528:	600c                	ld	a1,0(s0)
ffffffffc020052a:	00006517          	auipc	a0,0x6
ffffffffc020052e:	92650513          	addi	a0,a0,-1754 # ffffffffc0205e50 <etext+0x2d4>
ffffffffc0200532:	bb1ff0ef          	jal	ffffffffc02000e2 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200536:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200538:	00006517          	auipc	a0,0x6
ffffffffc020053c:	93050513          	addi	a0,a0,-1744 # ffffffffc0205e68 <etext+0x2ec>
    if (boot_dtb == 0) {
ffffffffc0200540:	10070163          	beqz	a4,ffffffffc0200642 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200544:	57f5                	li	a5,-3
ffffffffc0200546:	07fa                	slli	a5,a5,0x1e
ffffffffc0200548:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020054a:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020054c:	d00e06b7          	lui	a3,0xd00e0
ffffffffc0200550:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfdfac6d>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200554:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200558:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020055c:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200560:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200564:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200568:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020056a:	8e49                	or	a2,a2,a0
ffffffffc020056c:	0ff7f793          	zext.b	a5,a5
ffffffffc0200570:	8dd1                	or	a1,a1,a2
ffffffffc0200572:	07a2                	slli	a5,a5,0x8
ffffffffc0200574:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200576:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc020057a:	0cd59863          	bne	a1,a3,ffffffffc020064a <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020057e:	4710                	lw	a2,8(a4)
ffffffffc0200580:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200582:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200584:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200588:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020058c:	01865e1b          	srliw	t3,a2,0x18
ffffffffc0200590:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200594:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200598:	0186959b          	slliw	a1,a3,0x18
ffffffffc020059c:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a0:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a8:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02005ac:	01c56533          	or	a0,a0,t3
ffffffffc02005b0:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005b4:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b8:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005bc:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005c0:	0ff6f693          	zext.b	a3,a3
ffffffffc02005c4:	8c49                	or	s0,s0,a0
ffffffffc02005c6:	0622                	slli	a2,a2,0x8
ffffffffc02005c8:	8fcd                	or	a5,a5,a1
ffffffffc02005ca:	06a2                	slli	a3,a3,0x8
ffffffffc02005cc:	8c51                	or	s0,s0,a2
ffffffffc02005ce:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005d0:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005d2:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005d4:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005d6:	9381                	srli	a5,a5,0x20
ffffffffc02005d8:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc02005da:	4301                	li	t1,0
        switch (token) {
ffffffffc02005dc:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005de:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005e0:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc02005e4:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005e6:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e8:	0087579b          	srliw	a5,a4,0x8
ffffffffc02005ec:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f0:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f4:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f8:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005fc:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200600:	8ed1                	or	a3,a3,a2
ffffffffc0200602:	0ff77713          	zext.b	a4,a4
ffffffffc0200606:	8fd5                	or	a5,a5,a3
ffffffffc0200608:	0722                	slli	a4,a4,0x8
ffffffffc020060a:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc020060c:	05178763          	beq	a5,a7,ffffffffc020065a <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200610:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc0200612:	00f8e963          	bltu	a7,a5,ffffffffc0200624 <dtb_init+0x12a>
ffffffffc0200616:	07c78d63          	beq	a5,t3,ffffffffc0200690 <dtb_init+0x196>
ffffffffc020061a:	4709                	li	a4,2
ffffffffc020061c:	00e79763          	bne	a5,a4,ffffffffc020062a <dtb_init+0x130>
ffffffffc0200620:	4301                	li	t1,0
ffffffffc0200622:	b7d1                	j	ffffffffc02005e6 <dtb_init+0xec>
ffffffffc0200624:	4711                	li	a4,4
ffffffffc0200626:	fce780e3          	beq	a5,a4,ffffffffc02005e6 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020062a:	00006517          	auipc	a0,0x6
ffffffffc020062e:	90650513          	addi	a0,a0,-1786 # ffffffffc0205f30 <etext+0x3b4>
ffffffffc0200632:	ab1ff0ef          	jal	ffffffffc02000e2 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200636:	64e2                	ld	s1,24(sp)
ffffffffc0200638:	6942                	ld	s2,16(sp)
ffffffffc020063a:	00006517          	auipc	a0,0x6
ffffffffc020063e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205f68 <etext+0x3ec>
}
ffffffffc0200642:	7402                	ld	s0,32(sp)
ffffffffc0200644:	70a2                	ld	ra,40(sp)
ffffffffc0200646:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200648:	bc69                	j	ffffffffc02000e2 <cprintf>
}
ffffffffc020064a:	7402                	ld	s0,32(sp)
ffffffffc020064c:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020064e:	00006517          	auipc	a0,0x6
ffffffffc0200652:	83a50513          	addi	a0,a0,-1990 # ffffffffc0205e88 <etext+0x30c>
}
ffffffffc0200656:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200658:	b469                	j	ffffffffc02000e2 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc020065a:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020065c:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200660:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200664:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200668:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020066c:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200670:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200674:	8ed1                	or	a3,a3,a2
ffffffffc0200676:	0ff77713          	zext.b	a4,a4
ffffffffc020067a:	8fd5                	or	a5,a5,a3
ffffffffc020067c:	0722                	slli	a4,a4,0x8
ffffffffc020067e:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200680:	04031463          	bnez	t1,ffffffffc02006c8 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200684:	1782                	slli	a5,a5,0x20
ffffffffc0200686:	9381                	srli	a5,a5,0x20
ffffffffc0200688:	043d                	addi	s0,s0,15
ffffffffc020068a:	943e                	add	s0,s0,a5
ffffffffc020068c:	9871                	andi	s0,s0,-4
                break;
ffffffffc020068e:	bfa1                	j	ffffffffc02005e6 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc0200690:	8522                	mv	a0,s0
ffffffffc0200692:	e01a                	sd	t1,0(sp)
ffffffffc0200694:	028050ef          	jal	ffffffffc02056bc <strlen>
ffffffffc0200698:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020069a:	4619                	li	a2,6
ffffffffc020069c:	8522                	mv	a0,s0
ffffffffc020069e:	00006597          	auipc	a1,0x6
ffffffffc02006a2:	81258593          	addi	a1,a1,-2030 # ffffffffc0205eb0 <etext+0x334>
ffffffffc02006a6:	090050ef          	jal	ffffffffc0205736 <strncmp>
ffffffffc02006aa:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006ac:	0411                	addi	s0,s0,4
ffffffffc02006ae:	0004879b          	sext.w	a5,s1
ffffffffc02006b2:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006b4:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006b8:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006ba:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02006be:	00ff0837          	lui	a6,0xff0
ffffffffc02006c2:	488d                	li	a7,3
ffffffffc02006c4:	4e05                	li	t3,1
ffffffffc02006c6:	b705                	j	ffffffffc02005e6 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006c8:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006ca:	00005597          	auipc	a1,0x5
ffffffffc02006ce:	7ee58593          	addi	a1,a1,2030 # ffffffffc0205eb8 <etext+0x33c>
ffffffffc02006d2:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d4:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d8:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006dc:	0187169b          	slliw	a3,a4,0x18
ffffffffc02006e0:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e4:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006e8:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ec:	8ed1                	or	a3,a3,a2
ffffffffc02006ee:	0ff77713          	zext.b	a4,a4
ffffffffc02006f2:	0722                	slli	a4,a4,0x8
ffffffffc02006f4:	8d55                	or	a0,a0,a3
ffffffffc02006f6:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02006f8:	1502                	slli	a0,a0,0x20
ffffffffc02006fa:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006fc:	954a                	add	a0,a0,s2
ffffffffc02006fe:	e01a                	sd	t1,0(sp)
ffffffffc0200700:	002050ef          	jal	ffffffffc0205702 <strcmp>
ffffffffc0200704:	67a2                	ld	a5,8(sp)
ffffffffc0200706:	473d                	li	a4,15
ffffffffc0200708:	6302                	ld	t1,0(sp)
ffffffffc020070a:	00ff0837          	lui	a6,0xff0
ffffffffc020070e:	488d                	li	a7,3
ffffffffc0200710:	4e05                	li	t3,1
ffffffffc0200712:	f6f779e3          	bgeu	a4,a5,ffffffffc0200684 <dtb_init+0x18a>
ffffffffc0200716:	f53d                	bnez	a0,ffffffffc0200684 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200718:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020071c:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200720:	00005517          	auipc	a0,0x5
ffffffffc0200724:	7a050513          	addi	a0,a0,1952 # ffffffffc0205ec0 <etext+0x344>
           fdt32_to_cpu(x >> 32);
ffffffffc0200728:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020072c:	0087d31b          	srliw	t1,a5,0x8
ffffffffc0200730:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200734:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200738:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020073c:	0187959b          	slliw	a1,a5,0x18
ffffffffc0200740:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200744:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200748:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020074c:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200750:	01037333          	and	t1,t1,a6
ffffffffc0200754:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200758:	01e5e5b3          	or	a1,a1,t5
ffffffffc020075c:	0ff7f793          	zext.b	a5,a5
ffffffffc0200760:	01de6e33          	or	t3,t3,t4
ffffffffc0200764:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200768:	01067633          	and	a2,a2,a6
ffffffffc020076c:	0086d31b          	srliw	t1,a3,0x8
ffffffffc0200770:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200774:	07a2                	slli	a5,a5,0x8
ffffffffc0200776:	0108d89b          	srliw	a7,a7,0x10
ffffffffc020077a:	0186df1b          	srliw	t5,a3,0x18
ffffffffc020077e:	01875e9b          	srliw	t4,a4,0x18
ffffffffc0200782:	8ddd                	or	a1,a1,a5
ffffffffc0200784:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	0186979b          	slliw	a5,a3,0x18
ffffffffc020078c:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200790:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200794:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200798:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079c:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a0:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007a4:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a8:	08a2                	slli	a7,a7,0x8
ffffffffc02007aa:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ae:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007b2:	0ff6f693          	zext.b	a3,a3
ffffffffc02007b6:	01de6833          	or	a6,t3,t4
ffffffffc02007ba:	0ff77713          	zext.b	a4,a4
ffffffffc02007be:	01166633          	or	a2,a2,a7
ffffffffc02007c2:	0067e7b3          	or	a5,a5,t1
ffffffffc02007c6:	06a2                	slli	a3,a3,0x8
ffffffffc02007c8:	01046433          	or	s0,s0,a6
ffffffffc02007cc:	0722                	slli	a4,a4,0x8
ffffffffc02007ce:	8fd5                	or	a5,a5,a3
ffffffffc02007d0:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc02007d2:	1582                	slli	a1,a1,0x20
ffffffffc02007d4:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007d6:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007d8:	9201                	srli	a2,a2,0x20
ffffffffc02007da:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007dc:	1402                	slli	s0,s0,0x20
ffffffffc02007de:	00b7e4b3          	or	s1,a5,a1
ffffffffc02007e2:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007e4:	8ffff0ef          	jal	ffffffffc02000e2 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02007e8:	85a6                	mv	a1,s1
ffffffffc02007ea:	00005517          	auipc	a0,0x5
ffffffffc02007ee:	6f650513          	addi	a0,a0,1782 # ffffffffc0205ee0 <etext+0x364>
ffffffffc02007f2:	8f1ff0ef          	jal	ffffffffc02000e2 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02007f6:	01445613          	srli	a2,s0,0x14
ffffffffc02007fa:	85a2                	mv	a1,s0
ffffffffc02007fc:	00005517          	auipc	a0,0x5
ffffffffc0200800:	6fc50513          	addi	a0,a0,1788 # ffffffffc0205ef8 <etext+0x37c>
ffffffffc0200804:	8dfff0ef          	jal	ffffffffc02000e2 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200808:	009405b3          	add	a1,s0,s1
ffffffffc020080c:	15fd                	addi	a1,a1,-1
ffffffffc020080e:	00005517          	auipc	a0,0x5
ffffffffc0200812:	70a50513          	addi	a0,a0,1802 # ffffffffc0205f18 <etext+0x39c>
ffffffffc0200816:	8cdff0ef          	jal	ffffffffc02000e2 <cprintf>
        memory_base = mem_base;
ffffffffc020081a:	000e5797          	auipc	a5,0xe5
ffffffffc020081e:	9e97b323          	sd	s1,-1562(a5) # ffffffffc02e5200 <memory_base>
        memory_size = mem_size;
ffffffffc0200822:	000e5797          	auipc	a5,0xe5
ffffffffc0200826:	9c87bb23          	sd	s0,-1578(a5) # ffffffffc02e51f8 <memory_size>
ffffffffc020082a:	b531                	j	ffffffffc0200636 <dtb_init+0x13c>

ffffffffc020082c <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020082c:	000e5517          	auipc	a0,0xe5
ffffffffc0200830:	9d453503          	ld	a0,-1580(a0) # ffffffffc02e5200 <memory_base>
ffffffffc0200834:	8082                	ret

ffffffffc0200836 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200836:	000e5517          	auipc	a0,0xe5
ffffffffc020083a:	9c253503          	ld	a0,-1598(a0) # ffffffffc02e51f8 <memory_size>
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void)
{
    set_csr(sie, MIP_STIP);
ffffffffc0200840:	02000793          	li	a5,32
ffffffffc0200844:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200848:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020084c:	67e1                	lui	a5,0x18
ffffffffc020084e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcbe0>
ffffffffc0200852:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200854:	4581                	li	a1,0
ffffffffc0200856:	4601                	li	a2,0
ffffffffc0200858:	4881                	li	a7,0
ffffffffc020085a:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc020085e:	00005517          	auipc	a0,0x5
ffffffffc0200862:	72250513          	addi	a0,a0,1826 # ffffffffc0205f80 <etext+0x404>
    ticks = 0;
ffffffffc0200866:	000e5797          	auipc	a5,0xe5
ffffffffc020086a:	9a07b123          	sd	zero,-1630(a5) # ffffffffc02e5208 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020086e:	875ff06f          	j	ffffffffc02000e2 <cprintf>

ffffffffc0200872 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200872:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200876:	67e1                	lui	a5,0x18
ffffffffc0200878:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcbe0>
ffffffffc020087c:	953e                	add	a0,a0,a5
ffffffffc020087e:	4581                	li	a1,0
ffffffffc0200880:	4601                	li	a2,0
ffffffffc0200882:	4881                	li	a7,0
ffffffffc0200884:	00000073          	ecall
ffffffffc0200888:	8082                	ret

ffffffffc020088a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020088a:	8082                	ret

ffffffffc020088c <cons_putc>:
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020088c:	100027f3          	csrr	a5,sstatus
ffffffffc0200890:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200892:	0ff57513          	zext.b	a0,a0
ffffffffc0200896:	e799                	bnez	a5,ffffffffc02008a4 <cons_putc+0x18>
ffffffffc0200898:	4581                	li	a1,0
ffffffffc020089a:	4601                	li	a2,0
ffffffffc020089c:	4885                	li	a7,1
ffffffffc020089e:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc02008a2:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02008a4:	1101                	addi	sp,sp,-32
ffffffffc02008a6:	ec06                	sd	ra,24(sp)
ffffffffc02008a8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02008aa:	05a000ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02008ae:	6522                	ld	a0,8(sp)
ffffffffc02008b0:	4581                	li	a1,0
ffffffffc02008b2:	4601                	li	a2,0
ffffffffc02008b4:	4885                	li	a7,1
ffffffffc02008b6:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008ba:	60e2                	ld	ra,24(sp)
ffffffffc02008bc:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc02008be:	a081                	j	ffffffffc02008fe <intr_enable>

ffffffffc02008c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02008c0:	100027f3          	csrr	a5,sstatus
ffffffffc02008c4:	8b89                	andi	a5,a5,2
ffffffffc02008c6:	eb89                	bnez	a5,ffffffffc02008d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02008c8:	4501                	li	a0,0
ffffffffc02008ca:	4581                	li	a1,0
ffffffffc02008cc:	4601                	li	a2,0
ffffffffc02008ce:	4889                	li	a7,2
ffffffffc02008d0:	00000073          	ecall
ffffffffc02008d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02008d6:	8082                	ret
int cons_getc(void) {
ffffffffc02008d8:	1101                	addi	sp,sp,-32
ffffffffc02008da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02008dc:	028000ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02008e0:	4501                	li	a0,0
ffffffffc02008e2:	4581                	li	a1,0
ffffffffc02008e4:	4601                	li	a2,0
ffffffffc02008e6:	4889                	li	a7,2
ffffffffc02008e8:	00000073          	ecall
ffffffffc02008ec:	2501                	sext.w	a0,a0
ffffffffc02008ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02008f0:	00e000ef          	jal	ffffffffc02008fe <intr_enable>
}
ffffffffc02008f4:	60e2                	ld	ra,24(sp)
ffffffffc02008f6:	6522                	ld	a0,8(sp)
ffffffffc02008f8:	6105                	addi	sp,sp,32
ffffffffc02008fa:	8082                	ret

ffffffffc02008fc <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02008fc:	8082                	ret

ffffffffc02008fe <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02008fe:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200902:	8082                	ret

ffffffffc0200904 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200904:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200908:	8082                	ret

ffffffffc020090a <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020090a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020090e:	00000797          	auipc	a5,0x0
ffffffffc0200912:	6ae78793          	addi	a5,a5,1710 # ffffffffc0200fbc <__alltraps>
ffffffffc0200916:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020091a:	000407b7          	lui	a5,0x40
ffffffffc020091e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200922:	8082                	ret

ffffffffc0200924 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200924:	610c                	ld	a1,0(a0)
{
ffffffffc0200926:	1141                	addi	sp,sp,-16
ffffffffc0200928:	e022                	sd	s0,0(sp)
ffffffffc020092a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020092c:	00005517          	auipc	a0,0x5
ffffffffc0200930:	67450513          	addi	a0,a0,1652 # ffffffffc0205fa0 <etext+0x424>
{
ffffffffc0200934:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200936:	facff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020093a:	640c                	ld	a1,8(s0)
ffffffffc020093c:	00005517          	auipc	a0,0x5
ffffffffc0200940:	67c50513          	addi	a0,a0,1660 # ffffffffc0205fb8 <etext+0x43c>
ffffffffc0200944:	f9eff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200948:	680c                	ld	a1,16(s0)
ffffffffc020094a:	00005517          	auipc	a0,0x5
ffffffffc020094e:	68650513          	addi	a0,a0,1670 # ffffffffc0205fd0 <etext+0x454>
ffffffffc0200952:	f90ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200956:	6c0c                	ld	a1,24(s0)
ffffffffc0200958:	00005517          	auipc	a0,0x5
ffffffffc020095c:	69050513          	addi	a0,a0,1680 # ffffffffc0205fe8 <etext+0x46c>
ffffffffc0200960:	f82ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200964:	700c                	ld	a1,32(s0)
ffffffffc0200966:	00005517          	auipc	a0,0x5
ffffffffc020096a:	69a50513          	addi	a0,a0,1690 # ffffffffc0206000 <etext+0x484>
ffffffffc020096e:	f74ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200972:	740c                	ld	a1,40(s0)
ffffffffc0200974:	00005517          	auipc	a0,0x5
ffffffffc0200978:	6a450513          	addi	a0,a0,1700 # ffffffffc0206018 <etext+0x49c>
ffffffffc020097c:	f66ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200980:	780c                	ld	a1,48(s0)
ffffffffc0200982:	00005517          	auipc	a0,0x5
ffffffffc0200986:	6ae50513          	addi	a0,a0,1710 # ffffffffc0206030 <etext+0x4b4>
ffffffffc020098a:	f58ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020098e:	7c0c                	ld	a1,56(s0)
ffffffffc0200990:	00005517          	auipc	a0,0x5
ffffffffc0200994:	6b850513          	addi	a0,a0,1720 # ffffffffc0206048 <etext+0x4cc>
ffffffffc0200998:	f4aff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc020099c:	602c                	ld	a1,64(s0)
ffffffffc020099e:	00005517          	auipc	a0,0x5
ffffffffc02009a2:	6c250513          	addi	a0,a0,1730 # ffffffffc0206060 <etext+0x4e4>
ffffffffc02009a6:	f3cff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009aa:	642c                	ld	a1,72(s0)
ffffffffc02009ac:	00005517          	auipc	a0,0x5
ffffffffc02009b0:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206078 <etext+0x4fc>
ffffffffc02009b4:	f2eff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009b8:	682c                	ld	a1,80(s0)
ffffffffc02009ba:	00005517          	auipc	a0,0x5
ffffffffc02009be:	6d650513          	addi	a0,a0,1750 # ffffffffc0206090 <etext+0x514>
ffffffffc02009c2:	f20ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c6:	6c2c                	ld	a1,88(s0)
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	6e050513          	addi	a0,a0,1760 # ffffffffc02060a8 <etext+0x52c>
ffffffffc02009d0:	f12ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d4:	702c                	ld	a1,96(s0)
ffffffffc02009d6:	00005517          	auipc	a0,0x5
ffffffffc02009da:	6ea50513          	addi	a0,a0,1770 # ffffffffc02060c0 <etext+0x544>
ffffffffc02009de:	f04ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009e2:	742c                	ld	a1,104(s0)
ffffffffc02009e4:	00005517          	auipc	a0,0x5
ffffffffc02009e8:	6f450513          	addi	a0,a0,1780 # ffffffffc02060d8 <etext+0x55c>
ffffffffc02009ec:	ef6ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009f0:	782c                	ld	a1,112(s0)
ffffffffc02009f2:	00005517          	auipc	a0,0x5
ffffffffc02009f6:	6fe50513          	addi	a0,a0,1790 # ffffffffc02060f0 <etext+0x574>
ffffffffc02009fa:	ee8ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc02009fe:	7c2c                	ld	a1,120(s0)
ffffffffc0200a00:	00005517          	auipc	a0,0x5
ffffffffc0200a04:	70850513          	addi	a0,a0,1800 # ffffffffc0206108 <etext+0x58c>
ffffffffc0200a08:	edaff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a0c:	604c                	ld	a1,128(s0)
ffffffffc0200a0e:	00005517          	auipc	a0,0x5
ffffffffc0200a12:	71250513          	addi	a0,a0,1810 # ffffffffc0206120 <etext+0x5a4>
ffffffffc0200a16:	eccff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a1a:	644c                	ld	a1,136(s0)
ffffffffc0200a1c:	00005517          	auipc	a0,0x5
ffffffffc0200a20:	71c50513          	addi	a0,a0,1820 # ffffffffc0206138 <etext+0x5bc>
ffffffffc0200a24:	ebeff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a28:	684c                	ld	a1,144(s0)
ffffffffc0200a2a:	00005517          	auipc	a0,0x5
ffffffffc0200a2e:	72650513          	addi	a0,a0,1830 # ffffffffc0206150 <etext+0x5d4>
ffffffffc0200a32:	eb0ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a36:	6c4c                	ld	a1,152(s0)
ffffffffc0200a38:	00005517          	auipc	a0,0x5
ffffffffc0200a3c:	73050513          	addi	a0,a0,1840 # ffffffffc0206168 <etext+0x5ec>
ffffffffc0200a40:	ea2ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a44:	704c                	ld	a1,160(s0)
ffffffffc0200a46:	00005517          	auipc	a0,0x5
ffffffffc0200a4a:	73a50513          	addi	a0,a0,1850 # ffffffffc0206180 <etext+0x604>
ffffffffc0200a4e:	e94ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a52:	744c                	ld	a1,168(s0)
ffffffffc0200a54:	00005517          	auipc	a0,0x5
ffffffffc0200a58:	74450513          	addi	a0,a0,1860 # ffffffffc0206198 <etext+0x61c>
ffffffffc0200a5c:	e86ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a60:	784c                	ld	a1,176(s0)
ffffffffc0200a62:	00005517          	auipc	a0,0x5
ffffffffc0200a66:	74e50513          	addi	a0,a0,1870 # ffffffffc02061b0 <etext+0x634>
ffffffffc0200a6a:	e78ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a6e:	7c4c                	ld	a1,184(s0)
ffffffffc0200a70:	00005517          	auipc	a0,0x5
ffffffffc0200a74:	75850513          	addi	a0,a0,1880 # ffffffffc02061c8 <etext+0x64c>
ffffffffc0200a78:	e6aff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a7c:	606c                	ld	a1,192(s0)
ffffffffc0200a7e:	00005517          	auipc	a0,0x5
ffffffffc0200a82:	76250513          	addi	a0,a0,1890 # ffffffffc02061e0 <etext+0x664>
ffffffffc0200a86:	e5cff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a8a:	646c                	ld	a1,200(s0)
ffffffffc0200a8c:	00005517          	auipc	a0,0x5
ffffffffc0200a90:	76c50513          	addi	a0,a0,1900 # ffffffffc02061f8 <etext+0x67c>
ffffffffc0200a94:	e4eff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a98:	686c                	ld	a1,208(s0)
ffffffffc0200a9a:	00005517          	auipc	a0,0x5
ffffffffc0200a9e:	77650513          	addi	a0,a0,1910 # ffffffffc0206210 <etext+0x694>
ffffffffc0200aa2:	e40ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa6:	6c6c                	ld	a1,216(s0)
ffffffffc0200aa8:	00005517          	auipc	a0,0x5
ffffffffc0200aac:	78050513          	addi	a0,a0,1920 # ffffffffc0206228 <etext+0x6ac>
ffffffffc0200ab0:	e32ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab4:	706c                	ld	a1,224(s0)
ffffffffc0200ab6:	00005517          	auipc	a0,0x5
ffffffffc0200aba:	78a50513          	addi	a0,a0,1930 # ffffffffc0206240 <etext+0x6c4>
ffffffffc0200abe:	e24ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200ac2:	746c                	ld	a1,232(s0)
ffffffffc0200ac4:	00005517          	auipc	a0,0x5
ffffffffc0200ac8:	79450513          	addi	a0,a0,1940 # ffffffffc0206258 <etext+0x6dc>
ffffffffc0200acc:	e16ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200ad0:	786c                	ld	a1,240(s0)
ffffffffc0200ad2:	00005517          	auipc	a0,0x5
ffffffffc0200ad6:	79e50513          	addi	a0,a0,1950 # ffffffffc0206270 <etext+0x6f4>
ffffffffc0200ada:	e08ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ade:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200ae0:	6402                	ld	s0,0(sp)
ffffffffc0200ae2:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae4:	00005517          	auipc	a0,0x5
ffffffffc0200ae8:	7a450513          	addi	a0,a0,1956 # ffffffffc0206288 <etext+0x70c>
}
ffffffffc0200aec:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200aee:	df4ff06f          	j	ffffffffc02000e2 <cprintf>

ffffffffc0200af2 <print_trapframe>:
{
ffffffffc0200af2:	1141                	addi	sp,sp,-16
ffffffffc0200af4:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200af6:	85aa                	mv	a1,a0
{
ffffffffc0200af8:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200afa:	00005517          	auipc	a0,0x5
ffffffffc0200afe:	7a650513          	addi	a0,a0,1958 # ffffffffc02062a0 <etext+0x724>
{
ffffffffc0200b02:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b04:	ddeff0ef          	jal	ffffffffc02000e2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	e1bff0ef          	jal	ffffffffc0200924 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b0e:	10043583          	ld	a1,256(s0)
ffffffffc0200b12:	00005517          	auipc	a0,0x5
ffffffffc0200b16:	7a650513          	addi	a0,a0,1958 # ffffffffc02062b8 <etext+0x73c>
ffffffffc0200b1a:	dc8ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b1e:	10843583          	ld	a1,264(s0)
ffffffffc0200b22:	00005517          	auipc	a0,0x5
ffffffffc0200b26:	7ae50513          	addi	a0,a0,1966 # ffffffffc02062d0 <etext+0x754>
ffffffffc0200b2a:	db8ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b2e:	11043583          	ld	a1,272(s0)
ffffffffc0200b32:	00005517          	auipc	a0,0x5
ffffffffc0200b36:	7b650513          	addi	a0,a0,1974 # ffffffffc02062e8 <etext+0x76c>
ffffffffc0200b3a:	da8ff0ef          	jal	ffffffffc02000e2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b3e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b42:	6402                	ld	s0,0(sp)
ffffffffc0200b44:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b46:	00005517          	auipc	a0,0x5
ffffffffc0200b4a:	7b250513          	addi	a0,a0,1970 # ffffffffc02062f8 <etext+0x77c>
}
ffffffffc0200b4e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b50:	d92ff06f          	j	ffffffffc02000e2 <cprintf>

ffffffffc0200b54 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200b54:	11853783          	ld	a5,280(a0)
ffffffffc0200b58:	472d                	li	a4,11
ffffffffc0200b5a:	0786                	slli	a5,a5,0x1
ffffffffc0200b5c:	8385                	srli	a5,a5,0x1
ffffffffc0200b5e:	0cf76063          	bltu	a4,a5,ffffffffc0200c1e <interrupt_handler+0xca>
ffffffffc0200b62:	00007717          	auipc	a4,0x7
ffffffffc0200b66:	dce70713          	addi	a4,a4,-562 # ffffffffc0207930 <commands+0x48>
ffffffffc0200b6a:	078a                	slli	a5,a5,0x2
ffffffffc0200b6c:	97ba                	add	a5,a5,a4
ffffffffc0200b6e:	439c                	lw	a5,0(a5)
ffffffffc0200b70:	97ba                	add	a5,a5,a4
ffffffffc0200b72:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200b74:	00005517          	auipc	a0,0x5
ffffffffc0200b78:	7fc50513          	addi	a0,a0,2044 # ffffffffc0206370 <etext+0x7f4>
ffffffffc0200b7c:	d66ff06f          	j	ffffffffc02000e2 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b80:	00005517          	auipc	a0,0x5
ffffffffc0200b84:	7d050513          	addi	a0,a0,2000 # ffffffffc0206350 <etext+0x7d4>
ffffffffc0200b88:	d5aff06f          	j	ffffffffc02000e2 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b8c:	00005517          	auipc	a0,0x5
ffffffffc0200b90:	78450513          	addi	a0,a0,1924 # ffffffffc0206310 <etext+0x794>
ffffffffc0200b94:	d4eff06f          	j	ffffffffc02000e2 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b98:	00005517          	auipc	a0,0x5
ffffffffc0200b9c:	79850513          	addi	a0,a0,1944 # ffffffffc0206330 <etext+0x7b4>
ffffffffc0200ba0:	d42ff06f          	j	ffffffffc02000e2 <cprintf>
{
ffffffffc0200ba4:	1141                	addi	sp,sp,-16
ffffffffc0200ba6:	e406                	sd	ra,8(sp)
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // clear_csr(sip, SIP_STIP);

        clock_set_next_event();
ffffffffc0200ba8:	ccbff0ef          	jal	ffffffffc0200872 <clock_set_next_event>
        ticks++;
ffffffffc0200bac:	000e4797          	auipc	a5,0xe4
ffffffffc0200bb0:	65c78793          	addi	a5,a5,1628 # ffffffffc02e5208 <ticks>
ffffffffc0200bb4:	6394                	ld	a3,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200bb6:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200bba:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_matrix_out_size+0x28f507cf>
        ticks++;
ffffffffc0200bbe:	0685                	addi	a3,a3,1
ffffffffc0200bc0:	e394                	sd	a3,0(a5)
        if (ticks % TICK_NUM == 0)
ffffffffc0200bc2:	6390                	ld	a2,0(a5)
ffffffffc0200bc4:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200bc8:	1702                	slli	a4,a4,0x20
ffffffffc0200bca:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <_binary_obj___user_matrix_out_size+0x5c283b03>
ffffffffc0200bce:	00265793          	srli	a5,a2,0x2
ffffffffc0200bd2:	9736                	add	a4,a4,a3
ffffffffc0200bd4:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200bd8:	06400593          	li	a1,100
ffffffffc0200bdc:	8389                	srli	a5,a5,0x2
ffffffffc0200bde:	02b787b3          	mul	a5,a5,a1
ffffffffc0200be2:	02f60f63          	beq	a2,a5,ffffffffc0200c20 <interrupt_handler+0xcc>
        {
            print_ticks();
            num++;
        }
        sched_class_proc_tick(current);
ffffffffc0200be6:	000e4517          	auipc	a0,0xe4
ffffffffc0200bea:	67253503          	ld	a0,1650(a0) # ffffffffc02e5258 <current>
ffffffffc0200bee:	76a040ef          	jal	ffffffffc0205358 <sched_class_proc_tick>
        if (num == 10)
ffffffffc0200bf2:	000e4717          	auipc	a4,0xe4
ffffffffc0200bf6:	61e72703          	lw	a4,1566(a4) # ffffffffc02e5210 <num>
ffffffffc0200bfa:	47a9                	li	a5,10
ffffffffc0200bfc:	00f71863          	bne	a4,a5,ffffffffc0200c0c <interrupt_handler+0xb8>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c00:	4501                	li	a0,0
ffffffffc0200c02:	4581                	li	a1,0
ffffffffc0200c04:	4601                	li	a2,0
ffffffffc0200c06:	48a1                	li	a7,8
ffffffffc0200c08:	00000073          	ecall
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c0c:	60a2                	ld	ra,8(sp)
ffffffffc0200c0e:	0141                	addi	sp,sp,16
ffffffffc0200c10:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c12:	00005517          	auipc	a0,0x5
ffffffffc0200c16:	78e50513          	addi	a0,a0,1934 # ffffffffc02063a0 <etext+0x824>
ffffffffc0200c1a:	cc8ff06f          	j	ffffffffc02000e2 <cprintf>
        print_trapframe(tf);
ffffffffc0200c1e:	bdd1                	j	ffffffffc0200af2 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c20:	00005517          	auipc	a0,0x5
ffffffffc0200c24:	77050513          	addi	a0,a0,1904 # ffffffffc0206390 <etext+0x814>
ffffffffc0200c28:	cbaff0ef          	jal	ffffffffc02000e2 <cprintf>
            num++;
ffffffffc0200c2c:	000e4797          	auipc	a5,0xe4
ffffffffc0200c30:	5e47a783          	lw	a5,1508(a5) # ffffffffc02e5210 <num>
ffffffffc0200c34:	2785                	addiw	a5,a5,1
ffffffffc0200c36:	000e4717          	auipc	a4,0xe4
ffffffffc0200c3a:	5cf72d23          	sw	a5,1498(a4) # ffffffffc02e5210 <num>
ffffffffc0200c3e:	b765                	j	ffffffffc0200be6 <interrupt_handler+0x92>

ffffffffc0200c40 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c40:	11853783          	ld	a5,280(a0)
ffffffffc0200c44:	473d                	li	a4,15
ffffffffc0200c46:	24f76563          	bltu	a4,a5,ffffffffc0200e90 <exception_handler+0x250>
ffffffffc0200c4a:	00007717          	auipc	a4,0x7
ffffffffc0200c4e:	d1670713          	addi	a4,a4,-746 # ffffffffc0207960 <commands+0x78>
ffffffffc0200c52:	078a                	slli	a5,a5,0x2
ffffffffc0200c54:	97ba                	add	a5,a5,a4
ffffffffc0200c56:	439c                	lw	a5,0(a5)
{
ffffffffc0200c58:	7179                	addi	sp,sp,-48
ffffffffc0200c5a:	f406                	sd	ra,40(sp)
    switch (tf->cause)
ffffffffc0200c5c:	97ba                	add	a5,a5,a4
ffffffffc0200c5e:	86aa                	mv	a3,a0
ffffffffc0200c60:	8782                	jr	a5
ffffffffc0200c62:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c64:	00006517          	auipc	a0,0x6
ffffffffc0200c68:	84450513          	addi	a0,a0,-1980 # ffffffffc02064a8 <etext+0x92c>
ffffffffc0200c6c:	c76ff0ef          	jal	ffffffffc02000e2 <cprintf>
        tf->epc += 4;
ffffffffc0200c70:	66a2                	ld	a3,8(sp)
ffffffffc0200c72:	1086b783          	ld	a5,264(a3)
    }
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c76:	70a2                	ld	ra,40(sp)
        tf->epc += 4;
ffffffffc0200c78:	0791                	addi	a5,a5,4
ffffffffc0200c7a:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c7e:	6145                	addi	sp,sp,48
        syscall();
ffffffffc0200c80:	1bf0406f          	j	ffffffffc020563e <syscall>
}
ffffffffc0200c84:	70a2                	ld	ra,40(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c86:	00006517          	auipc	a0,0x6
ffffffffc0200c8a:	84250513          	addi	a0,a0,-1982 # ffffffffc02064c8 <etext+0x94c>
}
ffffffffc0200c8e:	6145                	addi	sp,sp,48
        cprintf("Environment call from H-mode\n");
ffffffffc0200c90:	c52ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200c94:	70a2                	ld	ra,40(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c96:	00006517          	auipc	a0,0x6
ffffffffc0200c9a:	85250513          	addi	a0,a0,-1966 # ffffffffc02064e8 <etext+0x96c>
}
ffffffffc0200c9e:	6145                	addi	sp,sp,48
        cprintf("Environment call from M-mode\n");
ffffffffc0200ca0:	c42ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200ca4:	70a2                	ld	ra,40(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200ca6:	00006517          	auipc	a0,0x6
ffffffffc0200caa:	86250513          	addi	a0,a0,-1950 # ffffffffc0206508 <etext+0x98c>
}
ffffffffc0200cae:	6145                	addi	sp,sp,48
        cprintf("Instruction page fault\n");
ffffffffc0200cb0:	c32ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200cb4:	70a2                	ld	ra,40(sp)
        cprintf("Load page fault\n");
ffffffffc0200cb6:	00006517          	auipc	a0,0x6
ffffffffc0200cba:	86a50513          	addi	a0,a0,-1942 # ffffffffc0206520 <etext+0x9a4>
}
ffffffffc0200cbe:	6145                	addi	sp,sp,48
        cprintf("Load page fault\n");
ffffffffc0200cc0:	c22ff06f          	j	ffffffffc02000e2 <cprintf>
        if (current != NULL && current->mm != NULL)
ffffffffc0200cc4:	000e4797          	auipc	a5,0xe4
ffffffffc0200cc8:	5947b783          	ld	a5,1428(a5) # ffffffffc02e5258 <current>
ffffffffc0200ccc:	cb95                	beqz	a5,ffffffffc0200d00 <exception_handler+0xc0>
ffffffffc0200cce:	779c                	ld	a5,40(a5)
ffffffffc0200cd0:	cb85                	beqz	a5,ffffffffc0200d00 <exception_handler+0xc0>
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200cd2:	11053683          	ld	a3,272(a0)
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200cd6:	6f88                	ld	a0,24(a5)
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200cd8:	77fd                	lui	a5,0xfffff
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200cda:	00f6f5b3          	and	a1,a3,a5
ffffffffc0200cde:	4601                	li	a2,0
ffffffffc0200ce0:	f022                	sd	s0,32(sp)
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200ce2:	00f6f433          	and	s0,a3,a5
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200ce6:	379010ef          	jal	ffffffffc020285e <get_pte>
ffffffffc0200cea:	87aa                	mv	a5,a0
            if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW))
ffffffffc0200cec:	c909                	beqz	a0,ffffffffc0200cfe <exception_handler+0xbe>
ffffffffc0200cee:	00053803          	ld	a6,0(a0)
ffffffffc0200cf2:	20100693          	li	a3,513
ffffffffc0200cf6:	00d87633          	and	a2,a6,a3
ffffffffc0200cfa:	0ad60a63          	beq	a2,a3,ffffffffc0200dae <exception_handler+0x16e>
ffffffffc0200cfe:	7402                	ld	s0,32(sp)
}
ffffffffc0200d00:	70a2                	ld	ra,40(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200d02:	00006517          	auipc	a0,0x6
ffffffffc0200d06:	8b650513          	addi	a0,a0,-1866 # ffffffffc02065b8 <etext+0xa3c>
}
ffffffffc0200d0a:	6145                	addi	sp,sp,48
        cprintf("Store/AMO page fault\n");
ffffffffc0200d0c:	bd6ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200d10:	70a2                	ld	ra,40(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200d12:	00005517          	auipc	a0,0x5
ffffffffc0200d16:	6ae50513          	addi	a0,a0,1710 # ffffffffc02063c0 <etext+0x844>
}
ffffffffc0200d1a:	6145                	addi	sp,sp,48
        cprintf("Instruction address misaligned\n");
ffffffffc0200d1c:	bc6ff06f          	j	ffffffffc02000e2 <cprintf>
ffffffffc0200d20:	e42a                	sd	a0,8(sp)
        cprintf("Breakpoint\n");
ffffffffc0200d22:	00005517          	auipc	a0,0x5
ffffffffc0200d26:	6f650513          	addi	a0,a0,1782 # ffffffffc0206418 <etext+0x89c>
ffffffffc0200d2a:	bb8ff0ef          	jal	ffffffffc02000e2 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200d2e:	66a2                	ld	a3,8(sp)
ffffffffc0200d30:	47a9                	li	a5,10
ffffffffc0200d32:	66d8                	ld	a4,136(a3)
ffffffffc0200d34:	12f70c63          	beq	a4,a5,ffffffffc0200e6c <exception_handler+0x22c>
}
ffffffffc0200d38:	70a2                	ld	ra,40(sp)
ffffffffc0200d3a:	6145                	addi	sp,sp,48
ffffffffc0200d3c:	8082                	ret
ffffffffc0200d3e:	70a2                	ld	ra,40(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200d40:	00005517          	auipc	a0,0x5
ffffffffc0200d44:	6e850513          	addi	a0,a0,1768 # ffffffffc0206428 <etext+0x8ac>
}
ffffffffc0200d48:	6145                	addi	sp,sp,48
        cprintf("Load address misaligned\n");
ffffffffc0200d4a:	b98ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200d4e:	70a2                	ld	ra,40(sp)
        cprintf("Load access fault\n");
ffffffffc0200d50:	00005517          	auipc	a0,0x5
ffffffffc0200d54:	6f850513          	addi	a0,a0,1784 # ffffffffc0206448 <etext+0x8cc>
}
ffffffffc0200d58:	6145                	addi	sp,sp,48
        cprintf("Load access fault\n");
ffffffffc0200d5a:	b88ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200d5e:	70a2                	ld	ra,40(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200d60:	00005517          	auipc	a0,0x5
ffffffffc0200d64:	73050513          	addi	a0,a0,1840 # ffffffffc0206490 <etext+0x914>
}
ffffffffc0200d68:	6145                	addi	sp,sp,48
        cprintf("Store/AMO access fault\n");
ffffffffc0200d6a:	b78ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200d6e:	70a2                	ld	ra,40(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200d70:	00005517          	auipc	a0,0x5
ffffffffc0200d74:	67050513          	addi	a0,a0,1648 # ffffffffc02063e0 <etext+0x864>
}
ffffffffc0200d78:	6145                	addi	sp,sp,48
        cprintf("Instruction access fault\n");
ffffffffc0200d7a:	b68ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200d7e:	70a2                	ld	ra,40(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200d80:	00005517          	auipc	a0,0x5
ffffffffc0200d84:	68050513          	addi	a0,a0,1664 # ffffffffc0206400 <etext+0x884>
}
ffffffffc0200d88:	6145                	addi	sp,sp,48
        cprintf("Illegal instruction\n");
ffffffffc0200d8a:	b58ff06f          	j	ffffffffc02000e2 <cprintf>
}
ffffffffc0200d8e:	70a2                	ld	ra,40(sp)
ffffffffc0200d90:	6145                	addi	sp,sp,48
        print_trapframe(tf);
ffffffffc0200d92:	b385                	j	ffffffffc0200af2 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200d94:	00005617          	auipc	a2,0x5
ffffffffc0200d98:	6cc60613          	addi	a2,a2,1740 # ffffffffc0206460 <etext+0x8e4>
ffffffffc0200d9c:	0c100593          	li	a1,193
ffffffffc0200da0:	00005517          	auipc	a0,0x5
ffffffffc0200da4:	6d850513          	addi	a0,a0,1752 # ffffffffc0206478 <etext+0x8fc>
ffffffffc0200da8:	f022                	sd	s0,32(sp)
ffffffffc0200daa:	c82ff0ef          	jal	ffffffffc020022c <__panic>
}

static inline struct Page *
pa2page(uintptr_t pa)
{
    if (PPN(pa) >= npage)
ffffffffc0200dae:	000e4617          	auipc	a2,0xe4
ffffffffc0200db2:	49263603          	ld	a2,1170(a2) # ffffffffc02e5240 <npage>
{
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200db6:	00281693          	slli	a3,a6,0x2
ffffffffc0200dba:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0200dbc:	10c6f063          	bgeu	a3,a2,ffffffffc0200ebc <exception_handler+0x27c>
    return &pages[PPN(pa) - nbase];
ffffffffc0200dc0:	00007897          	auipc	a7,0x7
ffffffffc0200dc4:	6388b883          	ld	a7,1592(a7) # ffffffffc02083f8 <nbase>
ffffffffc0200dc8:	000e4617          	auipc	a2,0xe4
ffffffffc0200dcc:	48063603          	ld	a2,1152(a2) # ffffffffc02e5248 <pages>
                if (page_ref(page) > 1)
ffffffffc0200dd0:	4505                	li	a0,1
ffffffffc0200dd2:	411686b3          	sub	a3,a3,a7
ffffffffc0200dd6:	069a                	slli	a3,a3,0x6
ffffffffc0200dd8:	9636                	add	a2,a2,a3
ffffffffc0200dda:	00062303          	lw	t1,0(a2)
ffffffffc0200dde:	0a655a63          	bge	a0,t1,ffffffffc0200e92 <exception_handler+0x252>
ffffffffc0200de2:	e846                	sd	a7,16(sp)
ffffffffc0200de4:	e442                	sd	a6,8(sp)
                    struct Page *npage = alloc_page();
ffffffffc0200de6:	ec32                	sd	a2,24(sp)
ffffffffc0200de8:	1cf010ef          	jal	ffffffffc02027b6 <alloc_pages>
                    if (npage == NULL)
ffffffffc0200dec:	6822                	ld	a6,8(sp)
ffffffffc0200dee:	68c2                	ld	a7,16(sp)
ffffffffc0200df0:	6662                	ld	a2,24(sp)
                    struct Page *npage = alloc_page();
ffffffffc0200df2:	832a                	mv	t1,a0
                    if (npage == NULL)
ffffffffc0200df4:	12050563          	beqz	a0,ffffffffc0200f1e <exception_handler+0x2de>
    return page - pages + nbase;
ffffffffc0200df8:	000e4e17          	auipc	t3,0xe4
ffffffffc0200dfc:	450e3e03          	ld	t3,1104(t3) # ffffffffc02e5248 <pages>
    return KADDR(page2pa(page));
ffffffffc0200e00:	55fd                	li	a1,-1
ffffffffc0200e02:	000e4517          	auipc	a0,0xe4
ffffffffc0200e06:	43e53503          	ld	a0,1086(a0) # ffffffffc02e5240 <npage>
    return page - pages + nbase;
ffffffffc0200e0a:	41c307b3          	sub	a5,t1,t3
ffffffffc0200e0e:	8799                	srai	a5,a5,0x6
ffffffffc0200e10:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc0200e12:	81b1                	srli	a1,a1,0xc
ffffffffc0200e14:	00b7feb3          	and	t4,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e18:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e1c:	0eaef563          	bgeu	t4,a0,ffffffffc0200f06 <exception_handler+0x2c6>
    return page - pages + nbase;
ffffffffc0200e20:	41c607b3          	sub	a5,a2,t3
ffffffffc0200e24:	8799                	srai	a5,a5,0x6
ffffffffc0200e26:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc0200e28:	8dfd                	and	a1,a1,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e2a:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e2c:	0ca5f063          	bgeu	a1,a0,ffffffffc0200eec <exception_handler+0x2ac>
ffffffffc0200e30:	000e4517          	auipc	a0,0xe4
ffffffffc0200e34:	40853503          	ld	a0,1032(a0) # ffffffffc02e5238 <va_pa_offset>
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0200e38:	6605                	lui	a2,0x1
ffffffffc0200e3a:	e442                	sd	a6,8(sp)
ffffffffc0200e3c:	00a785b3          	add	a1,a5,a0
ffffffffc0200e40:	9536                	add	a0,a0,a3
ffffffffc0200e42:	e81a                	sd	t1,16(sp)
ffffffffc0200e44:	13f040ef          	jal	ffffffffc0205782 <memcpy>
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e48:	000e4797          	auipc	a5,0xe4
ffffffffc0200e4c:	4107b783          	ld	a5,1040(a5) # ffffffffc02e5258 <current>
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200e50:	6822                	ld	a6,8(sp)
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e52:	65c2                	ld	a1,16(sp)
ffffffffc0200e54:	779c                	ld	a5,40(a5)
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200e56:	01b87693          	andi	a3,a6,27
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e5a:	0046e693          	ori	a3,a3,4
ffffffffc0200e5e:	6f88                	ld	a0,24(a5)
ffffffffc0200e60:	8622                	mv	a2,s0
ffffffffc0200e62:	132020ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc0200e66:	e53d                	bnez	a0,ffffffffc0200ed4 <exception_handler+0x294>
ffffffffc0200e68:	7402                	ld	s0,32(sp)
ffffffffc0200e6a:	b5f9                	j	ffffffffc0200d38 <exception_handler+0xf8>
            tf->epc += 4;
ffffffffc0200e6c:	1086b783          	ld	a5,264(a3)
ffffffffc0200e70:	0791                	addi	a5,a5,4
ffffffffc0200e72:	10f6b423          	sd	a5,264(a3)
            syscall();
ffffffffc0200e76:	7c8040ef          	jal	ffffffffc020563e <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e7a:	000e4717          	auipc	a4,0xe4
ffffffffc0200e7e:	3de73703          	ld	a4,990(a4) # ffffffffc02e5258 <current>
ffffffffc0200e82:	6522                	ld	a0,8(sp)
}
ffffffffc0200e84:	70a2                	ld	ra,40(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e86:	6b0c                	ld	a1,16(a4)
ffffffffc0200e88:	6789                	lui	a5,0x2
ffffffffc0200e8a:	95be                	add	a1,a1,a5
}
ffffffffc0200e8c:	6145                	addi	sp,sp,48
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e8e:	aaf5                	j	ffffffffc020108a <kernel_execve_ret>
        print_trapframe(tf);
ffffffffc0200e90:	b18d                	j	ffffffffc0200af2 <print_trapframe>
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200e92:	000e4717          	auipc	a4,0xe4
ffffffffc0200e96:	3c673703          	ld	a4,966(a4) # ffffffffc02e5258 <current>
    return page - pages + nbase;
ffffffffc0200e9a:	8699                	srai	a3,a3,0x6
ffffffffc0200e9c:	96c6                	add	a3,a3,a7
ffffffffc0200e9e:	7710                	ld	a2,40(a4)
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200ea0:	06aa                	slli	a3,a3,0xa
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200ea2:	01b87713          	andi	a4,a6,27
ffffffffc0200ea6:	8f55                	or	a4,a4,a3
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200ea8:	85a2                	mv	a1,s0
ffffffffc0200eaa:	7402                	ld	s0,32(sp)
ffffffffc0200eac:	6e08                	ld	a0,24(a2)
}
ffffffffc0200eae:	70a2                	ld	ra,40(sp)
ffffffffc0200eb0:	00576713          	ori	a4,a4,5
                    *ptep = pte_create(page2ppn(page), perm | PTE_V);
ffffffffc0200eb4:	e398                	sd	a4,0(a5)
}
ffffffffc0200eb6:	6145                	addi	sp,sp,48
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200eb8:	7950206f          	j	ffffffffc0203e4c <tlb_invalidate>
        panic("pa2page called with invalid pa");
ffffffffc0200ebc:	00005617          	auipc	a2,0x5
ffffffffc0200ec0:	67c60613          	addi	a2,a2,1660 # ffffffffc0206538 <etext+0x9bc>
ffffffffc0200ec4:	06900593          	li	a1,105
ffffffffc0200ec8:	00005517          	auipc	a0,0x5
ffffffffc0200ecc:	69050513          	addi	a0,a0,1680 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0200ed0:	b5cff0ef          	jal	ffffffffc020022c <__panic>
                        panic("COW: insert fail\n");
ffffffffc0200ed4:	00005617          	auipc	a2,0x5
ffffffffc0200ed8:	6cc60613          	addi	a2,a2,1740 # ffffffffc02065a0 <etext+0xa24>
ffffffffc0200edc:	0f100593          	li	a1,241
ffffffffc0200ee0:	00005517          	auipc	a0,0x5
ffffffffc0200ee4:	59850513          	addi	a0,a0,1432 # ffffffffc0206478 <etext+0x8fc>
ffffffffc0200ee8:	b44ff0ef          	jal	ffffffffc020022c <__panic>
    return KADDR(page2pa(page));
ffffffffc0200eec:	86be                	mv	a3,a5
ffffffffc0200eee:	00005617          	auipc	a2,0x5
ffffffffc0200ef2:	68a60613          	addi	a2,a2,1674 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0200ef6:	07100593          	li	a1,113
ffffffffc0200efa:	00005517          	auipc	a0,0x5
ffffffffc0200efe:	65e50513          	addi	a0,a0,1630 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0200f02:	b2aff0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0200f06:	00005617          	auipc	a2,0x5
ffffffffc0200f0a:	67260613          	addi	a2,a2,1650 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0200f0e:	07100593          	li	a1,113
ffffffffc0200f12:	00005517          	auipc	a0,0x5
ffffffffc0200f16:	64650513          	addi	a0,a0,1606 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0200f1a:	b12ff0ef          	jal	ffffffffc020022c <__panic>
                        panic("COW: no mem\n");
ffffffffc0200f1e:	00005617          	auipc	a2,0x5
ffffffffc0200f22:	64a60613          	addi	a2,a2,1610 # ffffffffc0206568 <etext+0x9ec>
ffffffffc0200f26:	0eb00593          	li	a1,235
ffffffffc0200f2a:	00005517          	auipc	a0,0x5
ffffffffc0200f2e:	54e50513          	addi	a0,a0,1358 # ffffffffc0206478 <etext+0x8fc>
ffffffffc0200f32:	afaff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200f36 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200f36:	000e4717          	auipc	a4,0xe4
ffffffffc0200f3a:	32273703          	ld	a4,802(a4) # ffffffffc02e5258 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f3e:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200f42:	cf21                	beqz	a4,ffffffffc0200f9a <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200f44:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200f48:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200f4c:	1101                	addi	sp,sp,-32
ffffffffc0200f4e:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200f50:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200f54:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f56:	e432                	sd	a2,8(sp)
ffffffffc0200f58:	e042                	sd	a6,0(sp)
ffffffffc0200f5a:	0205c763          	bltz	a1,ffffffffc0200f88 <trap+0x52>
        exception_handler(tf);
ffffffffc0200f5e:	ce3ff0ef          	jal	ffffffffc0200c40 <exception_handler>
ffffffffc0200f62:	6622                	ld	a2,8(sp)
ffffffffc0200f64:	6802                	ld	a6,0(sp)
ffffffffc0200f66:	000e4697          	auipc	a3,0xe4
ffffffffc0200f6a:	2f268693          	addi	a3,a3,754 # ffffffffc02e5258 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200f6e:	6298                	ld	a4,0(a3)
ffffffffc0200f70:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200f74:	e619                	bnez	a2,ffffffffc0200f82 <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200f76:	0b072783          	lw	a5,176(a4)
ffffffffc0200f7a:	8b85                	andi	a5,a5,1
ffffffffc0200f7c:	e79d                	bnez	a5,ffffffffc0200faa <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200f7e:	6f1c                	ld	a5,24(a4)
ffffffffc0200f80:	e38d                	bnez	a5,ffffffffc0200fa2 <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200f82:	60e2                	ld	ra,24(sp)
ffffffffc0200f84:	6105                	addi	sp,sp,32
ffffffffc0200f86:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200f88:	bcdff0ef          	jal	ffffffffc0200b54 <interrupt_handler>
ffffffffc0200f8c:	6802                	ld	a6,0(sp)
ffffffffc0200f8e:	6622                	ld	a2,8(sp)
ffffffffc0200f90:	000e4697          	auipc	a3,0xe4
ffffffffc0200f94:	2c868693          	addi	a3,a3,712 # ffffffffc02e5258 <current>
ffffffffc0200f98:	bfd9                	j	ffffffffc0200f6e <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200f9a:	0005c363          	bltz	a1,ffffffffc0200fa0 <trap+0x6a>
        exception_handler(tf);
ffffffffc0200f9e:	b14d                	j	ffffffffc0200c40 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200fa0:	be55                	j	ffffffffc0200b54 <interrupt_handler>
}
ffffffffc0200fa2:	60e2                	ld	ra,24(sp)
ffffffffc0200fa4:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200fa6:	5300406f          	j	ffffffffc02054d6 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200faa:	555d                	li	a0,-9
ffffffffc0200fac:	5c6030ef          	jal	ffffffffc0204572 <do_exit>
            if (current->need_resched)
ffffffffc0200fb0:	000e4717          	auipc	a4,0xe4
ffffffffc0200fb4:	2a873703          	ld	a4,680(a4) # ffffffffc02e5258 <current>
ffffffffc0200fb8:	b7d9                	j	ffffffffc0200f7e <trap+0x48>
	...

ffffffffc0200fbc <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200fbc:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200fc0:	00011463          	bnez	sp,ffffffffc0200fc8 <__alltraps+0xc>
ffffffffc0200fc4:	14002173          	csrr	sp,sscratch
ffffffffc0200fc8:	712d                	addi	sp,sp,-288
ffffffffc0200fca:	e002                	sd	zero,0(sp)
ffffffffc0200fcc:	e406                	sd	ra,8(sp)
ffffffffc0200fce:	ec0e                	sd	gp,24(sp)
ffffffffc0200fd0:	f012                	sd	tp,32(sp)
ffffffffc0200fd2:	f416                	sd	t0,40(sp)
ffffffffc0200fd4:	f81a                	sd	t1,48(sp)
ffffffffc0200fd6:	fc1e                	sd	t2,56(sp)
ffffffffc0200fd8:	e0a2                	sd	s0,64(sp)
ffffffffc0200fda:	e4a6                	sd	s1,72(sp)
ffffffffc0200fdc:	e8aa                	sd	a0,80(sp)
ffffffffc0200fde:	ecae                	sd	a1,88(sp)
ffffffffc0200fe0:	f0b2                	sd	a2,96(sp)
ffffffffc0200fe2:	f4b6                	sd	a3,104(sp)
ffffffffc0200fe4:	f8ba                	sd	a4,112(sp)
ffffffffc0200fe6:	fcbe                	sd	a5,120(sp)
ffffffffc0200fe8:	e142                	sd	a6,128(sp)
ffffffffc0200fea:	e546                	sd	a7,136(sp)
ffffffffc0200fec:	e94a                	sd	s2,144(sp)
ffffffffc0200fee:	ed4e                	sd	s3,152(sp)
ffffffffc0200ff0:	f152                	sd	s4,160(sp)
ffffffffc0200ff2:	f556                	sd	s5,168(sp)
ffffffffc0200ff4:	f95a                	sd	s6,176(sp)
ffffffffc0200ff6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ff8:	e1e2                	sd	s8,192(sp)
ffffffffc0200ffa:	e5e6                	sd	s9,200(sp)
ffffffffc0200ffc:	e9ea                	sd	s10,208(sp)
ffffffffc0200ffe:	edee                	sd	s11,216(sp)
ffffffffc0201000:	f1f2                	sd	t3,224(sp)
ffffffffc0201002:	f5f6                	sd	t4,232(sp)
ffffffffc0201004:	f9fa                	sd	t5,240(sp)
ffffffffc0201006:	fdfe                	sd	t6,248(sp)
ffffffffc0201008:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020100c:	100024f3          	csrr	s1,sstatus
ffffffffc0201010:	14102973          	csrr	s2,sepc
ffffffffc0201014:	143029f3          	csrr	s3,stval
ffffffffc0201018:	14202a73          	csrr	s4,scause
ffffffffc020101c:	e822                	sd	s0,16(sp)
ffffffffc020101e:	e226                	sd	s1,256(sp)
ffffffffc0201020:	e64a                	sd	s2,264(sp)
ffffffffc0201022:	ea4e                	sd	s3,272(sp)
ffffffffc0201024:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0201026:	850a                	mv	a0,sp
    jal trap
ffffffffc0201028:	f0fff0ef          	jal	ffffffffc0200f36 <trap>

ffffffffc020102c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc020102c:	6492                	ld	s1,256(sp)
ffffffffc020102e:	6932                	ld	s2,264(sp)
ffffffffc0201030:	1004f413          	andi	s0,s1,256
ffffffffc0201034:	e401                	bnez	s0,ffffffffc020103c <__trapret+0x10>
ffffffffc0201036:	1200                	addi	s0,sp,288
ffffffffc0201038:	14041073          	csrw	sscratch,s0
ffffffffc020103c:	10049073          	csrw	sstatus,s1
ffffffffc0201040:	14191073          	csrw	sepc,s2
ffffffffc0201044:	60a2                	ld	ra,8(sp)
ffffffffc0201046:	61e2                	ld	gp,24(sp)
ffffffffc0201048:	7202                	ld	tp,32(sp)
ffffffffc020104a:	72a2                	ld	t0,40(sp)
ffffffffc020104c:	7342                	ld	t1,48(sp)
ffffffffc020104e:	73e2                	ld	t2,56(sp)
ffffffffc0201050:	6406                	ld	s0,64(sp)
ffffffffc0201052:	64a6                	ld	s1,72(sp)
ffffffffc0201054:	6546                	ld	a0,80(sp)
ffffffffc0201056:	65e6                	ld	a1,88(sp)
ffffffffc0201058:	7606                	ld	a2,96(sp)
ffffffffc020105a:	76a6                	ld	a3,104(sp)
ffffffffc020105c:	7746                	ld	a4,112(sp)
ffffffffc020105e:	77e6                	ld	a5,120(sp)
ffffffffc0201060:	680a                	ld	a6,128(sp)
ffffffffc0201062:	68aa                	ld	a7,136(sp)
ffffffffc0201064:	694a                	ld	s2,144(sp)
ffffffffc0201066:	69ea                	ld	s3,152(sp)
ffffffffc0201068:	7a0a                	ld	s4,160(sp)
ffffffffc020106a:	7aaa                	ld	s5,168(sp)
ffffffffc020106c:	7b4a                	ld	s6,176(sp)
ffffffffc020106e:	7bea                	ld	s7,184(sp)
ffffffffc0201070:	6c0e                	ld	s8,192(sp)
ffffffffc0201072:	6cae                	ld	s9,200(sp)
ffffffffc0201074:	6d4e                	ld	s10,208(sp)
ffffffffc0201076:	6dee                	ld	s11,216(sp)
ffffffffc0201078:	7e0e                	ld	t3,224(sp)
ffffffffc020107a:	7eae                	ld	t4,232(sp)
ffffffffc020107c:	7f4e                	ld	t5,240(sp)
ffffffffc020107e:	7fee                	ld	t6,248(sp)
ffffffffc0201080:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0201082:	10200073          	sret

ffffffffc0201086 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0201086:	812a                	mv	sp,a0
    j __trapret
ffffffffc0201088:	b755                	j	ffffffffc020102c <__trapret>

ffffffffc020108a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    # adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc020108a:	ee058593          	addi	a1,a1,-288

    # copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc020108e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0201092:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0201096:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc020109a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc020109e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc02010a2:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc02010a6:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc02010aa:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc02010ae:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc02010b0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc02010b2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc02010b4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc02010b6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc02010b8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc02010ba:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc02010bc:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc02010be:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc02010c0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc02010c2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc02010c4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc02010c6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc02010c8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc02010ca:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc02010cc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc02010ce:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc02010d0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc02010d2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc02010d4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc02010d6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc02010d8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc02010da:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc02010dc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc02010de:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc02010e0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc02010e2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc02010e4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc02010e6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc02010e8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc02010ea:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc02010ec:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc02010ee:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc02010f0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc02010f2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc02010f4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc02010f6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc02010f8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc02010fa:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc02010fc:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc02010fe:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0201100:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0201102:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0201104:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0201106:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0201108:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc020110a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc020110c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc020110e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0201110:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0201112:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0201114:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0201116:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0201118:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc020111a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc020111c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc020111e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0201120:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0201122:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0201124:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0201126:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0201128:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc020112a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc020112c:	e184                	sd	s1,0(a1)

    # acutually adjust sp
    move sp, a1
ffffffffc020112e:	812e                	mv	sp,a1
ffffffffc0201130:	bdf5                	j	ffffffffc020102c <__trapret>

ffffffffc0201132 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201132:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201134:	00005697          	auipc	a3,0x5
ffffffffc0201138:	49c68693          	addi	a3,a3,1180 # ffffffffc02065d0 <etext+0xa54>
ffffffffc020113c:	00005617          	auipc	a2,0x5
ffffffffc0201140:	4b460613          	addi	a2,a2,1204 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0201144:	07400593          	li	a1,116
ffffffffc0201148:	00005517          	auipc	a0,0x5
ffffffffc020114c:	4c050513          	addi	a0,a0,1216 # ffffffffc0206608 <etext+0xa8c>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201150:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201152:	8daff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201156 <mm_create>:
{
ffffffffc0201156:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201158:	04000513          	li	a0,64
{
ffffffffc020115c:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020115e:	1ad000ef          	jal	ffffffffc0201b0a <kmalloc>
    if (mm != NULL)
ffffffffc0201162:	cd19                	beqz	a0,ffffffffc0201180 <mm_create+0x2a>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201164:	e508                	sd	a0,8(a0)
ffffffffc0201166:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0201168:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020116c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201170:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0201174:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0201178:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc020117c:	02053c23          	sd	zero,56(a0)
}
ffffffffc0201180:	60a2                	ld	ra,8(sp)
ffffffffc0201182:	0141                	addi	sp,sp,16
ffffffffc0201184:	8082                	ret

ffffffffc0201186 <find_vma>:
    if (mm != NULL)
ffffffffc0201186:	c505                	beqz	a0,ffffffffc02011ae <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc0201188:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020118a:	c781                	beqz	a5,ffffffffc0201192 <find_vma+0xc>
ffffffffc020118c:	6798                	ld	a4,8(a5)
ffffffffc020118e:	02e5f363          	bgeu	a1,a4,ffffffffc02011b4 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201192:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc0201194:	00f50d63          	beq	a0,a5,ffffffffc02011ae <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0201198:	fe87b703          	ld	a4,-24(a5) # 1fe8 <_binary_obj___user_softint_out_size-0x74c8>
ffffffffc020119c:	00e5e663          	bltu	a1,a4,ffffffffc02011a8 <find_vma+0x22>
ffffffffc02011a0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02011a4:	00e5ee63          	bltu	a1,a4,ffffffffc02011c0 <find_vma+0x3a>
ffffffffc02011a8:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02011aa:	fef517e3          	bne	a0,a5,ffffffffc0201198 <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc02011ae:	4781                	li	a5,0
}
ffffffffc02011b0:	853e                	mv	a0,a5
ffffffffc02011b2:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02011b4:	6b98                	ld	a4,16(a5)
ffffffffc02011b6:	fce5fee3          	bgeu	a1,a4,ffffffffc0201192 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02011ba:	e91c                	sd	a5,16(a0)
}
ffffffffc02011bc:	853e                	mv	a0,a5
ffffffffc02011be:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02011c0:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc02011c2:	e91c                	sd	a5,16(a0)
ffffffffc02011c4:	bfe5                	j	ffffffffc02011bc <find_vma+0x36>

ffffffffc02011c6 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02011c6:	6590                	ld	a2,8(a1)
ffffffffc02011c8:	0105b803          	ld	a6,16(a1)
{
ffffffffc02011cc:	1141                	addi	sp,sp,-16
ffffffffc02011ce:	e406                	sd	ra,8(sp)
ffffffffc02011d0:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02011d2:	01066763          	bltu	a2,a6,ffffffffc02011e0 <insert_vma_struct+0x1a>
ffffffffc02011d6:	a8b9                	j	ffffffffc0201234 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02011d8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02011dc:	04e66763          	bltu	a2,a4,ffffffffc020122a <insert_vma_struct+0x64>
ffffffffc02011e0:	86be                	mv	a3,a5
ffffffffc02011e2:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02011e4:	fef51ae3          	bne	a0,a5,ffffffffc02011d8 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02011e8:	02a68463          	beq	a3,a0,ffffffffc0201210 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02011ec:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02011f0:	fe86b883          	ld	a7,-24(a3)
ffffffffc02011f4:	08e8f063          	bgeu	a7,a4,ffffffffc0201274 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02011f8:	04e66e63          	bltu	a2,a4,ffffffffc0201254 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc02011fc:	00f50a63          	beq	a0,a5,ffffffffc0201210 <insert_vma_struct+0x4a>
ffffffffc0201200:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201204:	05076863          	bltu	a4,a6,ffffffffc0201254 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0201208:	ff07b603          	ld	a2,-16(a5)
ffffffffc020120c:	02c77263          	bgeu	a4,a2,ffffffffc0201230 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0201210:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201212:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201214:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201218:	e390                	sd	a2,0(a5)
ffffffffc020121a:	e690                	sd	a2,8(a3)
}
ffffffffc020121c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020121e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201220:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0201222:	2705                	addiw	a4,a4,1
ffffffffc0201224:	d118                	sw	a4,32(a0)
}
ffffffffc0201226:	0141                	addi	sp,sp,16
ffffffffc0201228:	8082                	ret
    if (le_prev != list)
ffffffffc020122a:	fca691e3          	bne	a3,a0,ffffffffc02011ec <insert_vma_struct+0x26>
ffffffffc020122e:	bfd9                	j	ffffffffc0201204 <insert_vma_struct+0x3e>
ffffffffc0201230:	f03ff0ef          	jal	ffffffffc0201132 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201234:	00005697          	auipc	a3,0x5
ffffffffc0201238:	3e468693          	addi	a3,a3,996 # ffffffffc0206618 <etext+0xa9c>
ffffffffc020123c:	00005617          	auipc	a2,0x5
ffffffffc0201240:	3b460613          	addi	a2,a2,948 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0201244:	07a00593          	li	a1,122
ffffffffc0201248:	00005517          	auipc	a0,0x5
ffffffffc020124c:	3c050513          	addi	a0,a0,960 # ffffffffc0206608 <etext+0xa8c>
ffffffffc0201250:	fddfe0ef          	jal	ffffffffc020022c <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201254:	00005697          	auipc	a3,0x5
ffffffffc0201258:	40468693          	addi	a3,a3,1028 # ffffffffc0206658 <etext+0xadc>
ffffffffc020125c:	00005617          	auipc	a2,0x5
ffffffffc0201260:	39460613          	addi	a2,a2,916 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0201264:	07300593          	li	a1,115
ffffffffc0201268:	00005517          	auipc	a0,0x5
ffffffffc020126c:	3a050513          	addi	a0,a0,928 # ffffffffc0206608 <etext+0xa8c>
ffffffffc0201270:	fbdfe0ef          	jal	ffffffffc020022c <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201274:	00005697          	auipc	a3,0x5
ffffffffc0201278:	3c468693          	addi	a3,a3,964 # ffffffffc0206638 <etext+0xabc>
ffffffffc020127c:	00005617          	auipc	a2,0x5
ffffffffc0201280:	37460613          	addi	a2,a2,884 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0201284:	07200593          	li	a1,114
ffffffffc0201288:	00005517          	auipc	a0,0x5
ffffffffc020128c:	38050513          	addi	a0,a0,896 # ffffffffc0206608 <etext+0xa8c>
ffffffffc0201290:	f9dfe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201294 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0201294:	591c                	lw	a5,48(a0)
{
ffffffffc0201296:	1141                	addi	sp,sp,-16
ffffffffc0201298:	e406                	sd	ra,8(sp)
ffffffffc020129a:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020129c:	e78d                	bnez	a5,ffffffffc02012c6 <mm_destroy+0x32>
ffffffffc020129e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02012a0:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02012a2:	00a40c63          	beq	s0,a0,ffffffffc02012ba <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02012a6:	6118                	ld	a4,0(a0)
ffffffffc02012a8:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02012aa:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02012ac:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02012ae:	e398                	sd	a4,0(a5)
ffffffffc02012b0:	101000ef          	jal	ffffffffc0201bb0 <kfree>
    return listelm->next;
ffffffffc02012b4:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02012b6:	fea418e3          	bne	s0,a0,ffffffffc02012a6 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02012ba:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02012bc:	6402                	ld	s0,0(sp)
ffffffffc02012be:	60a2                	ld	ra,8(sp)
ffffffffc02012c0:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02012c2:	0ef0006f          	j	ffffffffc0201bb0 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02012c6:	00005697          	auipc	a3,0x5
ffffffffc02012ca:	3b268693          	addi	a3,a3,946 # ffffffffc0206678 <etext+0xafc>
ffffffffc02012ce:	00005617          	auipc	a2,0x5
ffffffffc02012d2:	32260613          	addi	a2,a2,802 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02012d6:	09e00593          	li	a1,158
ffffffffc02012da:	00005517          	auipc	a0,0x5
ffffffffc02012de:	32e50513          	addi	a0,a0,814 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02012e2:	f4bfe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02012e6 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02012e6:	6785                	lui	a5,0x1
ffffffffc02012e8:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x84b1>
ffffffffc02012ea:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc02012ec:	4785                	li	a5,1
{
ffffffffc02012ee:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02012f0:	962e                	add	a2,a2,a1
ffffffffc02012f2:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc02012f4:	07fe                	slli	a5,a5,0x1f
{
ffffffffc02012f6:	f822                	sd	s0,48(sp)
ffffffffc02012f8:	f426                	sd	s1,40(sp)
ffffffffc02012fa:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02012fe:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0201302:	0785                	addi	a5,a5,1
ffffffffc0201304:	0084b633          	sltu	a2,s1,s0
ffffffffc0201308:	00f437b3          	sltu	a5,s0,a5
ffffffffc020130c:	00163613          	seqz	a2,a2
ffffffffc0201310:	0017b793          	seqz	a5,a5
{
ffffffffc0201314:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0201316:	8fd1                	or	a5,a5,a2
ffffffffc0201318:	ebbd                	bnez	a5,ffffffffc020138e <mm_map+0xa8>
ffffffffc020131a:	002007b7          	lui	a5,0x200
ffffffffc020131e:	06f4e863          	bltu	s1,a5,ffffffffc020138e <mm_map+0xa8>
ffffffffc0201322:	f04a                	sd	s2,32(sp)
ffffffffc0201324:	ec4e                	sd	s3,24(sp)
ffffffffc0201326:	e852                	sd	s4,16(sp)
ffffffffc0201328:	892a                	mv	s2,a0
ffffffffc020132a:	89ba                	mv	s3,a4
ffffffffc020132c:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020132e:	c135                	beqz	a0,ffffffffc0201392 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0201330:	85a6                	mv	a1,s1
ffffffffc0201332:	e55ff0ef          	jal	ffffffffc0201186 <find_vma>
ffffffffc0201336:	c501                	beqz	a0,ffffffffc020133e <mm_map+0x58>
ffffffffc0201338:	651c                	ld	a5,8(a0)
ffffffffc020133a:	0487e763          	bltu	a5,s0,ffffffffc0201388 <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020133e:	03000513          	li	a0,48
ffffffffc0201342:	7c8000ef          	jal	ffffffffc0201b0a <kmalloc>
ffffffffc0201346:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0201348:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc020134a:	c59d                	beqz	a1,ffffffffc0201378 <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc020134c:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc020134e:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0201350:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0201354:	854a                	mv	a0,s2
ffffffffc0201356:	e42e                	sd	a1,8(sp)
ffffffffc0201358:	e6fff0ef          	jal	ffffffffc02011c6 <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc020135c:	65a2                	ld	a1,8(sp)
ffffffffc020135e:	00098463          	beqz	s3,ffffffffc0201366 <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc0201362:	00b9b023          	sd	a1,0(s3)
ffffffffc0201366:	7902                	ld	s2,32(sp)
ffffffffc0201368:	69e2                	ld	s3,24(sp)
ffffffffc020136a:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc020136c:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc020136e:	70e2                	ld	ra,56(sp)
ffffffffc0201370:	7442                	ld	s0,48(sp)
ffffffffc0201372:	74a2                	ld	s1,40(sp)
ffffffffc0201374:	6121                	addi	sp,sp,64
ffffffffc0201376:	8082                	ret
ffffffffc0201378:	70e2                	ld	ra,56(sp)
ffffffffc020137a:	7442                	ld	s0,48(sp)
ffffffffc020137c:	7902                	ld	s2,32(sp)
ffffffffc020137e:	69e2                	ld	s3,24(sp)
ffffffffc0201380:	6a42                	ld	s4,16(sp)
ffffffffc0201382:	74a2                	ld	s1,40(sp)
ffffffffc0201384:	6121                	addi	sp,sp,64
ffffffffc0201386:	8082                	ret
ffffffffc0201388:	7902                	ld	s2,32(sp)
ffffffffc020138a:	69e2                	ld	s3,24(sp)
ffffffffc020138c:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc020138e:	5575                	li	a0,-3
ffffffffc0201390:	bff9                	j	ffffffffc020136e <mm_map+0x88>
    assert(mm != NULL);
ffffffffc0201392:	00005697          	auipc	a3,0x5
ffffffffc0201396:	2fe68693          	addi	a3,a3,766 # ffffffffc0206690 <etext+0xb14>
ffffffffc020139a:	00005617          	auipc	a2,0x5
ffffffffc020139e:	25660613          	addi	a2,a2,598 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02013a2:	0b300593          	li	a1,179
ffffffffc02013a6:	00005517          	auipc	a0,0x5
ffffffffc02013aa:	26250513          	addi	a0,a0,610 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02013ae:	e7ffe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02013b2 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc02013b2:	7139                	addi	sp,sp,-64
ffffffffc02013b4:	fc06                	sd	ra,56(sp)
ffffffffc02013b6:	f822                	sd	s0,48(sp)
ffffffffc02013b8:	f426                	sd	s1,40(sp)
ffffffffc02013ba:	f04a                	sd	s2,32(sp)
ffffffffc02013bc:	ec4e                	sd	s3,24(sp)
ffffffffc02013be:	e852                	sd	s4,16(sp)
ffffffffc02013c0:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02013c2:	c525                	beqz	a0,ffffffffc020142a <dup_mmap+0x78>
ffffffffc02013c4:	892a                	mv	s2,a0
ffffffffc02013c6:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02013c8:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02013ca:	c1a5                	beqz	a1,ffffffffc020142a <dup_mmap+0x78>
    return listelm->prev;
ffffffffc02013cc:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc02013ce:	04848c63          	beq	s1,s0,ffffffffc0201426 <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013d2:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02013d6:	fe843a83          	ld	s5,-24(s0)
ffffffffc02013da:	ff043a03          	ld	s4,-16(s0)
ffffffffc02013de:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013e2:	728000ef          	jal	ffffffffc0201b0a <kmalloc>
    if (vma != NULL)
ffffffffc02013e6:	c515                	beqz	a0,ffffffffc0201412 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02013e8:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02013ea:	01553423          	sd	s5,8(a0)
ffffffffc02013ee:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02013f2:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc02013f6:	854a                	mv	a0,s2
ffffffffc02013f8:	dcfff0ef          	jal	ffffffffc02011c6 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc02013fc:	ff043683          	ld	a3,-16(s0)
ffffffffc0201400:	fe843603          	ld	a2,-24(s0)
ffffffffc0201404:	6c8c                	ld	a1,24(s1)
ffffffffc0201406:	01893503          	ld	a0,24(s2)
ffffffffc020140a:	4701                	li	a4,0
ffffffffc020140c:	0c9020ef          	jal	ffffffffc0203cd4 <copy_range>
ffffffffc0201410:	dd55                	beqz	a0,ffffffffc02013cc <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0201412:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0201414:	70e2                	ld	ra,56(sp)
ffffffffc0201416:	7442                	ld	s0,48(sp)
ffffffffc0201418:	74a2                	ld	s1,40(sp)
ffffffffc020141a:	7902                	ld	s2,32(sp)
ffffffffc020141c:	69e2                	ld	s3,24(sp)
ffffffffc020141e:	6a42                	ld	s4,16(sp)
ffffffffc0201420:	6aa2                	ld	s5,8(sp)
ffffffffc0201422:	6121                	addi	sp,sp,64
ffffffffc0201424:	8082                	ret
    return 0;
ffffffffc0201426:	4501                	li	a0,0
ffffffffc0201428:	b7f5                	j	ffffffffc0201414 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc020142a:	00005697          	auipc	a3,0x5
ffffffffc020142e:	27668693          	addi	a3,a3,630 # ffffffffc02066a0 <etext+0xb24>
ffffffffc0201432:	00005617          	auipc	a2,0x5
ffffffffc0201436:	1be60613          	addi	a2,a2,446 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020143a:	0cf00593          	li	a1,207
ffffffffc020143e:	00005517          	auipc	a0,0x5
ffffffffc0201442:	1ca50513          	addi	a0,a0,458 # ffffffffc0206608 <etext+0xa8c>
ffffffffc0201446:	de7fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020144a <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc020144a:	1101                	addi	sp,sp,-32
ffffffffc020144c:	ec06                	sd	ra,24(sp)
ffffffffc020144e:	e822                	sd	s0,16(sp)
ffffffffc0201450:	e426                	sd	s1,8(sp)
ffffffffc0201452:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201454:	c531                	beqz	a0,ffffffffc02014a0 <exit_mmap+0x56>
ffffffffc0201456:	591c                	lw	a5,48(a0)
ffffffffc0201458:	84aa                	mv	s1,a0
ffffffffc020145a:	e3b9                	bnez	a5,ffffffffc02014a0 <exit_mmap+0x56>
    return listelm->next;
ffffffffc020145c:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc020145e:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0201462:	02850663          	beq	a0,s0,ffffffffc020148e <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201466:	ff043603          	ld	a2,-16(s0)
ffffffffc020146a:	fe843583          	ld	a1,-24(s0)
ffffffffc020146e:	854a                	mv	a0,s2
ffffffffc0201470:	6a0010ef          	jal	ffffffffc0202b10 <unmap_range>
ffffffffc0201474:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0201476:	fe8498e3          	bne	s1,s0,ffffffffc0201466 <exit_mmap+0x1c>
ffffffffc020147a:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc020147c:	00848c63          	beq	s1,s0,ffffffffc0201494 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201480:	ff043603          	ld	a2,-16(s0)
ffffffffc0201484:	fe843583          	ld	a1,-24(s0)
ffffffffc0201488:	854a                	mv	a0,s2
ffffffffc020148a:	7ba010ef          	jal	ffffffffc0202c44 <exit_range>
ffffffffc020148e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0201490:	fe8498e3          	bne	s1,s0,ffffffffc0201480 <exit_mmap+0x36>
    }
}
ffffffffc0201494:	60e2                	ld	ra,24(sp)
ffffffffc0201496:	6442                	ld	s0,16(sp)
ffffffffc0201498:	64a2                	ld	s1,8(sp)
ffffffffc020149a:	6902                	ld	s2,0(sp)
ffffffffc020149c:	6105                	addi	sp,sp,32
ffffffffc020149e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02014a0:	00005697          	auipc	a3,0x5
ffffffffc02014a4:	22068693          	addi	a3,a3,544 # ffffffffc02066c0 <etext+0xb44>
ffffffffc02014a8:	00005617          	auipc	a2,0x5
ffffffffc02014ac:	14860613          	addi	a2,a2,328 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02014b0:	0e800593          	li	a1,232
ffffffffc02014b4:	00005517          	auipc	a0,0x5
ffffffffc02014b8:	15450513          	addi	a0,a0,340 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02014bc:	d71fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02014c0 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc02014c0:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02014c2:	04000513          	li	a0,64
{
ffffffffc02014c6:	f406                	sd	ra,40(sp)
ffffffffc02014c8:	f022                	sd	s0,32(sp)
ffffffffc02014ca:	ec26                	sd	s1,24(sp)
ffffffffc02014cc:	e84a                	sd	s2,16(sp)
ffffffffc02014ce:	e44e                	sd	s3,8(sp)
ffffffffc02014d0:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02014d2:	638000ef          	jal	ffffffffc0201b0a <kmalloc>
    if (mm != NULL)
ffffffffc02014d6:	16050c63          	beqz	a0,ffffffffc020164e <vmm_init+0x18e>
ffffffffc02014da:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc02014dc:	e508                	sd	a0,8(a0)
ffffffffc02014de:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02014e0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02014e4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02014e8:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02014ec:	02053423          	sd	zero,40(a0)
ffffffffc02014f0:	02052823          	sw	zero,48(a0)
ffffffffc02014f4:	02053c23          	sd	zero,56(a0)
ffffffffc02014f8:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02014fc:	03000513          	li	a0,48
ffffffffc0201500:	60a000ef          	jal	ffffffffc0201b0a <kmalloc>
    if (vma != NULL)
ffffffffc0201504:	12050563          	beqz	a0,ffffffffc020162e <vmm_init+0x16e>
        vma->vm_end = vm_end;
ffffffffc0201508:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc020150c:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc020150e:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0201512:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201514:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0201516:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0201518:	8522                	mv	a0,s0
ffffffffc020151a:	cadff0ef          	jal	ffffffffc02011c6 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc020151e:	fcf9                	bnez	s1,ffffffffc02014fc <vmm_init+0x3c>
ffffffffc0201520:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0201524:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201528:	03000513          	li	a0,48
ffffffffc020152c:	5de000ef          	jal	ffffffffc0201b0a <kmalloc>
    if (vma != NULL)
ffffffffc0201530:	12050f63          	beqz	a0,ffffffffc020166e <vmm_init+0x1ae>
        vma->vm_end = vm_end;
ffffffffc0201534:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0201538:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc020153a:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc020153e:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201540:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0201542:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0201544:	8522                	mv	a0,s0
ffffffffc0201546:	c81ff0ef          	jal	ffffffffc02011c6 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc020154a:	fd249fe3          	bne	s1,s2,ffffffffc0201528 <vmm_init+0x68>
    return listelm->next;
ffffffffc020154e:	641c                	ld	a5,8(s0)
ffffffffc0201550:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0201552:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0201556:	1ef40c63          	beq	s0,a5,ffffffffc020174e <vmm_init+0x28e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020155a:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f4528>
ffffffffc020155e:	ffe70693          	addi	a3,a4,-2
ffffffffc0201562:	12d61663          	bne	a2,a3,ffffffffc020168e <vmm_init+0x1ce>
ffffffffc0201566:	ff07b683          	ld	a3,-16(a5)
ffffffffc020156a:	12e69263          	bne	a3,a4,ffffffffc020168e <vmm_init+0x1ce>
    for (i = 1; i <= step2; i++)
ffffffffc020156e:	0715                	addi	a4,a4,5
ffffffffc0201570:	679c                	ld	a5,8(a5)
ffffffffc0201572:	feb712e3          	bne	a4,a1,ffffffffc0201556 <vmm_init+0x96>
ffffffffc0201576:	491d                	li	s2,7
ffffffffc0201578:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020157a:	85a6                	mv	a1,s1
ffffffffc020157c:	8522                	mv	a0,s0
ffffffffc020157e:	c09ff0ef          	jal	ffffffffc0201186 <find_vma>
ffffffffc0201582:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0201584:	20050563          	beqz	a0,ffffffffc020178e <vmm_init+0x2ce>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0201588:	00148593          	addi	a1,s1,1
ffffffffc020158c:	8522                	mv	a0,s0
ffffffffc020158e:	bf9ff0ef          	jal	ffffffffc0201186 <find_vma>
ffffffffc0201592:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201594:	1c050d63          	beqz	a0,ffffffffc020176e <vmm_init+0x2ae>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0201598:	85ca                	mv	a1,s2
ffffffffc020159a:	8522                	mv	a0,s0
ffffffffc020159c:	bebff0ef          	jal	ffffffffc0201186 <find_vma>
        assert(vma3 == NULL);
ffffffffc02015a0:	18051763          	bnez	a0,ffffffffc020172e <vmm_init+0x26e>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc02015a4:	00348593          	addi	a1,s1,3
ffffffffc02015a8:	8522                	mv	a0,s0
ffffffffc02015aa:	bddff0ef          	jal	ffffffffc0201186 <find_vma>
        assert(vma4 == NULL);
ffffffffc02015ae:	16051063          	bnez	a0,ffffffffc020170e <vmm_init+0x24e>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc02015b2:	00448593          	addi	a1,s1,4
ffffffffc02015b6:	8522                	mv	a0,s0
ffffffffc02015b8:	bcfff0ef          	jal	ffffffffc0201186 <find_vma>
        assert(vma5 == NULL);
ffffffffc02015bc:	12051963          	bnez	a0,ffffffffc02016ee <vmm_init+0x22e>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02015c0:	008a3783          	ld	a5,8(s4)
ffffffffc02015c4:	10979563          	bne	a5,s1,ffffffffc02016ce <vmm_init+0x20e>
ffffffffc02015c8:	010a3783          	ld	a5,16(s4)
ffffffffc02015cc:	11279163          	bne	a5,s2,ffffffffc02016ce <vmm_init+0x20e>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02015d0:	0089b783          	ld	a5,8(s3)
ffffffffc02015d4:	0c979d63          	bne	a5,s1,ffffffffc02016ae <vmm_init+0x1ee>
ffffffffc02015d8:	0109b783          	ld	a5,16(s3)
ffffffffc02015dc:	0d279963          	bne	a5,s2,ffffffffc02016ae <vmm_init+0x1ee>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02015e0:	0495                	addi	s1,s1,5
ffffffffc02015e2:	1f900793          	li	a5,505
ffffffffc02015e6:	0915                	addi	s2,s2,5
ffffffffc02015e8:	f8f499e3          	bne	s1,a5,ffffffffc020157a <vmm_init+0xba>
ffffffffc02015ec:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02015ee:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02015f0:	85a6                	mv	a1,s1
ffffffffc02015f2:	8522                	mv	a0,s0
ffffffffc02015f4:	b93ff0ef          	jal	ffffffffc0201186 <find_vma>
        if (vma_below_5 != NULL)
ffffffffc02015f8:	1a051b63          	bnez	a0,ffffffffc02017ae <vmm_init+0x2ee>
    for (i = 4; i >= 0; i--)
ffffffffc02015fc:	14fd                	addi	s1,s1,-1
ffffffffc02015fe:	ff2499e3          	bne	s1,s2,ffffffffc02015f0 <vmm_init+0x130>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0201602:	8522                	mv	a0,s0
ffffffffc0201604:	c91ff0ef          	jal	ffffffffc0201294 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201608:	00005517          	auipc	a0,0x5
ffffffffc020160c:	22850513          	addi	a0,a0,552 # ffffffffc0206830 <etext+0xcb4>
ffffffffc0201610:	ad3fe0ef          	jal	ffffffffc02000e2 <cprintf>
}
ffffffffc0201614:	7402                	ld	s0,32(sp)
ffffffffc0201616:	70a2                	ld	ra,40(sp)
ffffffffc0201618:	64e2                	ld	s1,24(sp)
ffffffffc020161a:	6942                	ld	s2,16(sp)
ffffffffc020161c:	69a2                	ld	s3,8(sp)
ffffffffc020161e:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201620:	00005517          	auipc	a0,0x5
ffffffffc0201624:	23050513          	addi	a0,a0,560 # ffffffffc0206850 <etext+0xcd4>
}
ffffffffc0201628:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc020162a:	ab9fe06f          	j	ffffffffc02000e2 <cprintf>
        assert(vma != NULL);
ffffffffc020162e:	00005697          	auipc	a3,0x5
ffffffffc0201632:	0b268693          	addi	a3,a3,178 # ffffffffc02066e0 <etext+0xb64>
ffffffffc0201636:	00005617          	auipc	a2,0x5
ffffffffc020163a:	fba60613          	addi	a2,a2,-70 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020163e:	12c00593          	li	a1,300
ffffffffc0201642:	00005517          	auipc	a0,0x5
ffffffffc0201646:	fc650513          	addi	a0,a0,-58 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020164a:	be3fe0ef          	jal	ffffffffc020022c <__panic>
    assert(mm != NULL);
ffffffffc020164e:	00005697          	auipc	a3,0x5
ffffffffc0201652:	04268693          	addi	a3,a3,66 # ffffffffc0206690 <etext+0xb14>
ffffffffc0201656:	00005617          	auipc	a2,0x5
ffffffffc020165a:	f9a60613          	addi	a2,a2,-102 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020165e:	12400593          	li	a1,292
ffffffffc0201662:	00005517          	auipc	a0,0x5
ffffffffc0201666:	fa650513          	addi	a0,a0,-90 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020166a:	bc3fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma != NULL);
ffffffffc020166e:	00005697          	auipc	a3,0x5
ffffffffc0201672:	07268693          	addi	a3,a3,114 # ffffffffc02066e0 <etext+0xb64>
ffffffffc0201676:	00005617          	auipc	a2,0x5
ffffffffc020167a:	f7a60613          	addi	a2,a2,-134 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020167e:	13300593          	li	a1,307
ffffffffc0201682:	00005517          	auipc	a0,0x5
ffffffffc0201686:	f8650513          	addi	a0,a0,-122 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020168a:	ba3fe0ef          	jal	ffffffffc020022c <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020168e:	00005697          	auipc	a3,0x5
ffffffffc0201692:	07a68693          	addi	a3,a3,122 # ffffffffc0206708 <etext+0xb8c>
ffffffffc0201696:	00005617          	auipc	a2,0x5
ffffffffc020169a:	f5a60613          	addi	a2,a2,-166 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020169e:	13d00593          	li	a1,317
ffffffffc02016a2:	00005517          	auipc	a0,0x5
ffffffffc02016a6:	f6650513          	addi	a0,a0,-154 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02016aa:	b83fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02016ae:	00005697          	auipc	a3,0x5
ffffffffc02016b2:	11268693          	addi	a3,a3,274 # ffffffffc02067c0 <etext+0xc44>
ffffffffc02016b6:	00005617          	auipc	a2,0x5
ffffffffc02016ba:	f3a60613          	addi	a2,a2,-198 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02016be:	14f00593          	li	a1,335
ffffffffc02016c2:	00005517          	auipc	a0,0x5
ffffffffc02016c6:	f4650513          	addi	a0,a0,-186 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02016ca:	b63fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02016ce:	00005697          	auipc	a3,0x5
ffffffffc02016d2:	0c268693          	addi	a3,a3,194 # ffffffffc0206790 <etext+0xc14>
ffffffffc02016d6:	00005617          	auipc	a2,0x5
ffffffffc02016da:	f1a60613          	addi	a2,a2,-230 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02016de:	14e00593          	li	a1,334
ffffffffc02016e2:	00005517          	auipc	a0,0x5
ffffffffc02016e6:	f2650513          	addi	a0,a0,-218 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02016ea:	b43fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma5 == NULL);
ffffffffc02016ee:	00005697          	auipc	a3,0x5
ffffffffc02016f2:	09268693          	addi	a3,a3,146 # ffffffffc0206780 <etext+0xc04>
ffffffffc02016f6:	00005617          	auipc	a2,0x5
ffffffffc02016fa:	efa60613          	addi	a2,a2,-262 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02016fe:	14c00593          	li	a1,332
ffffffffc0201702:	00005517          	auipc	a0,0x5
ffffffffc0201706:	f0650513          	addi	a0,a0,-250 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020170a:	b23fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma4 == NULL);
ffffffffc020170e:	00005697          	auipc	a3,0x5
ffffffffc0201712:	06268693          	addi	a3,a3,98 # ffffffffc0206770 <etext+0xbf4>
ffffffffc0201716:	00005617          	auipc	a2,0x5
ffffffffc020171a:	eda60613          	addi	a2,a2,-294 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020171e:	14a00593          	li	a1,330
ffffffffc0201722:	00005517          	auipc	a0,0x5
ffffffffc0201726:	ee650513          	addi	a0,a0,-282 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020172a:	b03fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma3 == NULL);
ffffffffc020172e:	00005697          	auipc	a3,0x5
ffffffffc0201732:	03268693          	addi	a3,a3,50 # ffffffffc0206760 <etext+0xbe4>
ffffffffc0201736:	00005617          	auipc	a2,0x5
ffffffffc020173a:	eba60613          	addi	a2,a2,-326 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020173e:	14800593          	li	a1,328
ffffffffc0201742:	00005517          	auipc	a0,0x5
ffffffffc0201746:	ec650513          	addi	a0,a0,-314 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020174a:	ae3fe0ef          	jal	ffffffffc020022c <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020174e:	00005697          	auipc	a3,0x5
ffffffffc0201752:	fa268693          	addi	a3,a3,-94 # ffffffffc02066f0 <etext+0xb74>
ffffffffc0201756:	00005617          	auipc	a2,0x5
ffffffffc020175a:	e9a60613          	addi	a2,a2,-358 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020175e:	13b00593          	li	a1,315
ffffffffc0201762:	00005517          	auipc	a0,0x5
ffffffffc0201766:	ea650513          	addi	a0,a0,-346 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020176a:	ac3fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma2 != NULL);
ffffffffc020176e:	00005697          	auipc	a3,0x5
ffffffffc0201772:	fe268693          	addi	a3,a3,-30 # ffffffffc0206750 <etext+0xbd4>
ffffffffc0201776:	00005617          	auipc	a2,0x5
ffffffffc020177a:	e7a60613          	addi	a2,a2,-390 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020177e:	14600593          	li	a1,326
ffffffffc0201782:	00005517          	auipc	a0,0x5
ffffffffc0201786:	e8650513          	addi	a0,a0,-378 # ffffffffc0206608 <etext+0xa8c>
ffffffffc020178a:	aa3fe0ef          	jal	ffffffffc020022c <__panic>
        assert(vma1 != NULL);
ffffffffc020178e:	00005697          	auipc	a3,0x5
ffffffffc0201792:	fb268693          	addi	a3,a3,-78 # ffffffffc0206740 <etext+0xbc4>
ffffffffc0201796:	00005617          	auipc	a2,0x5
ffffffffc020179a:	e5a60613          	addi	a2,a2,-422 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020179e:	14400593          	li	a1,324
ffffffffc02017a2:	00005517          	auipc	a0,0x5
ffffffffc02017a6:	e6650513          	addi	a0,a0,-410 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02017aa:	a83fe0ef          	jal	ffffffffc020022c <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02017ae:	6914                	ld	a3,16(a0)
ffffffffc02017b0:	6510                	ld	a2,8(a0)
ffffffffc02017b2:	0004859b          	sext.w	a1,s1
ffffffffc02017b6:	00005517          	auipc	a0,0x5
ffffffffc02017ba:	03a50513          	addi	a0,a0,58 # ffffffffc02067f0 <etext+0xc74>
ffffffffc02017be:	925fe0ef          	jal	ffffffffc02000e2 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc02017c2:	00005697          	auipc	a3,0x5
ffffffffc02017c6:	05668693          	addi	a3,a3,86 # ffffffffc0206818 <etext+0xc9c>
ffffffffc02017ca:	00005617          	auipc	a2,0x5
ffffffffc02017ce:	e2660613          	addi	a2,a2,-474 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02017d2:	15900593          	li	a1,345
ffffffffc02017d6:	00005517          	auipc	a0,0x5
ffffffffc02017da:	e3250513          	addi	a0,a0,-462 # ffffffffc0206608 <etext+0xa8c>
ffffffffc02017de:	a4ffe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02017e2 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc02017e2:	7179                	addi	sp,sp,-48
ffffffffc02017e4:	f022                	sd	s0,32(sp)
ffffffffc02017e6:	f406                	sd	ra,40(sp)
ffffffffc02017e8:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc02017ea:	c52d                	beqz	a0,ffffffffc0201854 <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc02017ec:	002007b7          	lui	a5,0x200
ffffffffc02017f0:	04f5ed63          	bltu	a1,a5,ffffffffc020184a <user_mem_check+0x68>
ffffffffc02017f4:	ec26                	sd	s1,24(sp)
ffffffffc02017f6:	00c584b3          	add	s1,a1,a2
ffffffffc02017fa:	0695ff63          	bgeu	a1,s1,ffffffffc0201878 <user_mem_check+0x96>
ffffffffc02017fe:	4785                	li	a5,1
ffffffffc0201800:	07fe                	slli	a5,a5,0x1f
ffffffffc0201802:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_matrix_out_size+0x1f4541>
ffffffffc0201804:	06f4fa63          	bgeu	s1,a5,ffffffffc0201878 <user_mem_check+0x96>
ffffffffc0201808:	e84a                	sd	s2,16(sp)
ffffffffc020180a:	e44e                	sd	s3,8(sp)
ffffffffc020180c:	8936                	mv	s2,a3
ffffffffc020180e:	89aa                	mv	s3,a0
ffffffffc0201810:	a829                	j	ffffffffc020182a <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0201812:	6685                	lui	a3,0x1
ffffffffc0201814:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0201816:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc020181a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020181c:	c685                	beqz	a3,ffffffffc0201844 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc020181e:	c399                	beqz	a5,ffffffffc0201824 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0201820:	02e46263          	bltu	s0,a4,ffffffffc0201844 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201824:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0201826:	04947b63          	bgeu	s0,s1,ffffffffc020187c <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc020182a:	85a2                	mv	a1,s0
ffffffffc020182c:	854e                	mv	a0,s3
ffffffffc020182e:	959ff0ef          	jal	ffffffffc0201186 <find_vma>
ffffffffc0201832:	c909                	beqz	a0,ffffffffc0201844 <user_mem_check+0x62>
ffffffffc0201834:	6518                	ld	a4,8(a0)
ffffffffc0201836:	00e46763          	bltu	s0,a4,ffffffffc0201844 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020183a:	4d1c                	lw	a5,24(a0)
ffffffffc020183c:	fc091be3          	bnez	s2,ffffffffc0201812 <user_mem_check+0x30>
ffffffffc0201840:	8b85                	andi	a5,a5,1
ffffffffc0201842:	f3ed                	bnez	a5,ffffffffc0201824 <user_mem_check+0x42>
ffffffffc0201844:	64e2                	ld	s1,24(sp)
ffffffffc0201846:	6942                	ld	s2,16(sp)
ffffffffc0201848:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc020184a:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc020184c:	70a2                	ld	ra,40(sp)
ffffffffc020184e:	7402                	ld	s0,32(sp)
ffffffffc0201850:	6145                	addi	sp,sp,48
ffffffffc0201852:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201854:	c02007b7          	lui	a5,0xc0200
ffffffffc0201858:	fef5eae3          	bltu	a1,a5,ffffffffc020184c <user_mem_check+0x6a>
ffffffffc020185c:	c80007b7          	lui	a5,0xc8000
ffffffffc0201860:	962e                	add	a2,a2,a1
ffffffffc0201862:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d1ad81>
ffffffffc0201864:	00c5b433          	sltu	s0,a1,a2
ffffffffc0201868:	00f63633          	sltu	a2,a2,a5
}
ffffffffc020186c:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc020186e:	00867533          	and	a0,a2,s0
}
ffffffffc0201872:	7402                	ld	s0,32(sp)
ffffffffc0201874:	6145                	addi	sp,sp,48
ffffffffc0201876:	8082                	ret
ffffffffc0201878:	64e2                	ld	s1,24(sp)
ffffffffc020187a:	bfc1                	j	ffffffffc020184a <user_mem_check+0x68>
ffffffffc020187c:	64e2                	ld	s1,24(sp)
ffffffffc020187e:	6942                	ld	s2,16(sp)
ffffffffc0201880:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0201882:	4505                	li	a0,1
ffffffffc0201884:	b7e1                	j	ffffffffc020184c <user_mem_check+0x6a>

ffffffffc0201886 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201886:	c531                	beqz	a0,ffffffffc02018d2 <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201888:	e9b9                	bnez	a1,ffffffffc02018de <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020188a:	100027f3          	csrr	a5,sstatus
ffffffffc020188e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201890:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201892:	efb1                	bnez	a5,ffffffffc02018ee <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201894:	000df797          	auipc	a5,0xdf
ffffffffc0201898:	4947b783          	ld	a5,1172(a5) # ffffffffc02e0d28 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020189c:	873e                	mv	a4,a5
ffffffffc020189e:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018a0:	02a77a63          	bgeu	a4,a0,ffffffffc02018d4 <slob_free+0x4e>
ffffffffc02018a4:	00f56463          	bltu	a0,a5,ffffffffc02018ac <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018a8:	fef76ae3          	bltu	a4,a5,ffffffffc020189c <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc02018ac:	4110                	lw	a2,0(a0)
ffffffffc02018ae:	00461693          	slli	a3,a2,0x4
ffffffffc02018b2:	96aa                	add	a3,a3,a0
ffffffffc02018b4:	0ad78463          	beq	a5,a3,ffffffffc020195c <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02018b8:	4310                	lw	a2,0(a4)
ffffffffc02018ba:	e51c                	sd	a5,8(a0)
ffffffffc02018bc:	00461693          	slli	a3,a2,0x4
ffffffffc02018c0:	96ba                	add	a3,a3,a4
ffffffffc02018c2:	08d50163          	beq	a0,a3,ffffffffc0201944 <slob_free+0xbe>
ffffffffc02018c6:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc02018c8:	000df797          	auipc	a5,0xdf
ffffffffc02018cc:	46e7b023          	sd	a4,1120(a5) # ffffffffc02e0d28 <slobfree>
    if (flag)
ffffffffc02018d0:	e9a5                	bnez	a1,ffffffffc0201940 <slob_free+0xba>
ffffffffc02018d2:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018d4:	fcf574e3          	bgeu	a0,a5,ffffffffc020189c <slob_free+0x16>
ffffffffc02018d8:	fcf762e3          	bltu	a4,a5,ffffffffc020189c <slob_free+0x16>
ffffffffc02018dc:	bfc1                	j	ffffffffc02018ac <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc02018de:	25bd                	addiw	a1,a1,15
ffffffffc02018e0:	8191                	srli	a1,a1,0x4
ffffffffc02018e2:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02018e4:	100027f3          	csrr	a5,sstatus
ffffffffc02018e8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018ea:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02018ec:	d7c5                	beqz	a5,ffffffffc0201894 <slob_free+0xe>
{
ffffffffc02018ee:	1101                	addi	sp,sp,-32
ffffffffc02018f0:	e42a                	sd	a0,8(sp)
ffffffffc02018f2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02018f4:	810ff0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc02018f8:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018fa:	000df797          	auipc	a5,0xdf
ffffffffc02018fe:	42e7b783          	ld	a5,1070(a5) # ffffffffc02e0d28 <slobfree>
ffffffffc0201902:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201904:	873e                	mv	a4,a5
ffffffffc0201906:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201908:	06a77663          	bgeu	a4,a0,ffffffffc0201974 <slob_free+0xee>
ffffffffc020190c:	00f56463          	bltu	a0,a5,ffffffffc0201914 <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201910:	fef76ae3          	bltu	a4,a5,ffffffffc0201904 <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201914:	4110                	lw	a2,0(a0)
ffffffffc0201916:	00461693          	slli	a3,a2,0x4
ffffffffc020191a:	96aa                	add	a3,a3,a0
ffffffffc020191c:	06d78363          	beq	a5,a3,ffffffffc0201982 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201920:	4310                	lw	a2,0(a4)
ffffffffc0201922:	e51c                	sd	a5,8(a0)
ffffffffc0201924:	00461693          	slli	a3,a2,0x4
ffffffffc0201928:	96ba                	add	a3,a3,a4
ffffffffc020192a:	06d50163          	beq	a0,a3,ffffffffc020198c <slob_free+0x106>
ffffffffc020192e:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201930:	000df797          	auipc	a5,0xdf
ffffffffc0201934:	3ee7bc23          	sd	a4,1016(a5) # ffffffffc02e0d28 <slobfree>
    if (flag)
ffffffffc0201938:	e1a9                	bnez	a1,ffffffffc020197a <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020193a:	60e2                	ld	ra,24(sp)
ffffffffc020193c:	6105                	addi	sp,sp,32
ffffffffc020193e:	8082                	ret
        intr_enable();
ffffffffc0201940:	fbffe06f          	j	ffffffffc02008fe <intr_enable>
		cur->units += b->units;
ffffffffc0201944:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201946:	853e                	mv	a0,a5
ffffffffc0201948:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc020194a:	00c687bb          	addw	a5,a3,a2
ffffffffc020194e:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201950:	000df797          	auipc	a5,0xdf
ffffffffc0201954:	3ce7bc23          	sd	a4,984(a5) # ffffffffc02e0d28 <slobfree>
    if (flag)
ffffffffc0201958:	ddad                	beqz	a1,ffffffffc02018d2 <slob_free+0x4c>
ffffffffc020195a:	b7dd                	j	ffffffffc0201940 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc020195c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020195e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201960:	9eb1                	addw	a3,a3,a2
ffffffffc0201962:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201964:	4310                	lw	a2,0(a4)
ffffffffc0201966:	e51c                	sd	a5,8(a0)
ffffffffc0201968:	00461693          	slli	a3,a2,0x4
ffffffffc020196c:	96ba                	add	a3,a3,a4
ffffffffc020196e:	f4d51ce3          	bne	a0,a3,ffffffffc02018c6 <slob_free+0x40>
ffffffffc0201972:	bfc9                	j	ffffffffc0201944 <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201974:	f8f56ee3          	bltu	a0,a5,ffffffffc0201910 <slob_free+0x8a>
ffffffffc0201978:	b771                	j	ffffffffc0201904 <slob_free+0x7e>
}
ffffffffc020197a:	60e2                	ld	ra,24(sp)
ffffffffc020197c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020197e:	f81fe06f          	j	ffffffffc02008fe <intr_enable>
		b->units += cur->next->units;
ffffffffc0201982:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201984:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201986:	9eb1                	addw	a3,a3,a2
ffffffffc0201988:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc020198a:	bf59                	j	ffffffffc0201920 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc020198c:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc020198e:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201990:	00c687bb          	addw	a5,a3,a2
ffffffffc0201994:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201996:	bf61                	j	ffffffffc020192e <slob_free+0xa8>

ffffffffc0201998 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201998:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020199a:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc020199c:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019a0:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019a2:	615000ef          	jal	ffffffffc02027b6 <alloc_pages>
	if (!page)
ffffffffc02019a6:	c91d                	beqz	a0,ffffffffc02019dc <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02019a8:	000e4697          	auipc	a3,0xe4
ffffffffc02019ac:	8a06b683          	ld	a3,-1888(a3) # ffffffffc02e5248 <pages>
ffffffffc02019b0:	00007797          	auipc	a5,0x7
ffffffffc02019b4:	a487b783          	ld	a5,-1464(a5) # ffffffffc02083f8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02019b8:	000e4717          	auipc	a4,0xe4
ffffffffc02019bc:	88873703          	ld	a4,-1912(a4) # ffffffffc02e5240 <npage>
    return page - pages + nbase;
ffffffffc02019c0:	8d15                	sub	a0,a0,a3
ffffffffc02019c2:	8519                	srai	a0,a0,0x6
ffffffffc02019c4:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc02019c6:	00c51793          	slli	a5,a0,0xc
ffffffffc02019ca:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02019cc:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ce:	00e7fa63          	bgeu	a5,a4,ffffffffc02019e2 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019d2:	000e4797          	auipc	a5,0xe4
ffffffffc02019d6:	8667b783          	ld	a5,-1946(a5) # ffffffffc02e5238 <va_pa_offset>
ffffffffc02019da:	953e                	add	a0,a0,a5
}
ffffffffc02019dc:	60a2                	ld	ra,8(sp)
ffffffffc02019de:	0141                	addi	sp,sp,16
ffffffffc02019e0:	8082                	ret
ffffffffc02019e2:	86aa                	mv	a3,a0
ffffffffc02019e4:	00005617          	auipc	a2,0x5
ffffffffc02019e8:	b9460613          	addi	a2,a2,-1132 # ffffffffc0206578 <etext+0x9fc>
ffffffffc02019ec:	07100593          	li	a1,113
ffffffffc02019f0:	00005517          	auipc	a0,0x5
ffffffffc02019f4:	b6850513          	addi	a0,a0,-1176 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02019f8:	835fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02019fc <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019fc:	7179                	addi	sp,sp,-48
ffffffffc02019fe:	f406                	sd	ra,40(sp)
ffffffffc0201a00:	f022                	sd	s0,32(sp)
ffffffffc0201a02:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201a04:	01050713          	addi	a4,a0,16
ffffffffc0201a08:	6785                	lui	a5,0x1
ffffffffc0201a0a:	0af77e63          	bgeu	a4,a5,ffffffffc0201ac6 <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201a0e:	00f50413          	addi	s0,a0,15
ffffffffc0201a12:	8011                	srli	s0,s0,0x4
ffffffffc0201a14:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a16:	100025f3          	csrr	a1,sstatus
ffffffffc0201a1a:	8989                	andi	a1,a1,2
ffffffffc0201a1c:	edd1                	bnez	a1,ffffffffc0201ab8 <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201a1e:	000df497          	auipc	s1,0xdf
ffffffffc0201a22:	30a48493          	addi	s1,s1,778 # ffffffffc02e0d28 <slobfree>
ffffffffc0201a26:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a28:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201a2a:	4314                	lw	a3,0(a4)
ffffffffc0201a2c:	0886da63          	bge	a3,s0,ffffffffc0201ac0 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201a30:	00e60a63          	beq	a2,a4,ffffffffc0201a44 <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a34:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201a36:	4394                	lw	a3,0(a5)
ffffffffc0201a38:	0286d863          	bge	a3,s0,ffffffffc0201a68 <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201a3c:	6090                	ld	a2,0(s1)
ffffffffc0201a3e:	873e                	mv	a4,a5
ffffffffc0201a40:	fee61ae3          	bne	a2,a4,ffffffffc0201a34 <slob_alloc.constprop.0+0x38>
    if (flag)
ffffffffc0201a44:	e9b1                	bnez	a1,ffffffffc0201a98 <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a46:	4501                	li	a0,0
ffffffffc0201a48:	f51ff0ef          	jal	ffffffffc0201998 <__slob_get_free_pages.constprop.0>
ffffffffc0201a4c:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201a4e:	c915                	beqz	a0,ffffffffc0201a82 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a50:	6585                	lui	a1,0x1
ffffffffc0201a52:	e35ff0ef          	jal	ffffffffc0201886 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a56:	100025f3          	csrr	a1,sstatus
ffffffffc0201a5a:	8989                	andi	a1,a1,2
ffffffffc0201a5c:	e98d                	bnez	a1,ffffffffc0201a8e <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201a5e:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a60:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201a62:	4394                	lw	a3,0(a5)
ffffffffc0201a64:	fc86cce3          	blt	a3,s0,ffffffffc0201a3c <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201a68:	04d40563          	beq	s0,a3,ffffffffc0201ab2 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201a6c:	00441613          	slli	a2,s0,0x4
ffffffffc0201a70:	963e                	add	a2,a2,a5
ffffffffc0201a72:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201a74:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201a76:	9e81                	subw	a3,a3,s0
ffffffffc0201a78:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201a7a:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201a7c:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201a7e:	e098                	sd	a4,0(s1)
    if (flag)
ffffffffc0201a80:	ed99                	bnez	a1,ffffffffc0201a9e <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201a82:	70a2                	ld	ra,40(sp)
ffffffffc0201a84:	7402                	ld	s0,32(sp)
ffffffffc0201a86:	64e2                	ld	s1,24(sp)
ffffffffc0201a88:	853e                	mv	a0,a5
ffffffffc0201a8a:	6145                	addi	sp,sp,48
ffffffffc0201a8c:	8082                	ret
        intr_disable();
ffffffffc0201a8e:	e77fe0ef          	jal	ffffffffc0200904 <intr_disable>
			cur = slobfree;
ffffffffc0201a92:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201a94:	4585                	li	a1,1
ffffffffc0201a96:	b7e9                	j	ffffffffc0201a60 <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201a98:	e67fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201a9c:	b76d                	j	ffffffffc0201a46 <slob_alloc.constprop.0+0x4a>
ffffffffc0201a9e:	e43e                	sd	a5,8(sp)
ffffffffc0201aa0:	e5ffe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201aa4:	67a2                	ld	a5,8(sp)
}
ffffffffc0201aa6:	70a2                	ld	ra,40(sp)
ffffffffc0201aa8:	7402                	ld	s0,32(sp)
ffffffffc0201aaa:	64e2                	ld	s1,24(sp)
ffffffffc0201aac:	853e                	mv	a0,a5
ffffffffc0201aae:	6145                	addi	sp,sp,48
ffffffffc0201ab0:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201ab2:	6794                	ld	a3,8(a5)
ffffffffc0201ab4:	e714                	sd	a3,8(a4)
ffffffffc0201ab6:	b7e1                	j	ffffffffc0201a7e <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201ab8:	e4dfe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201abc:	4585                	li	a1,1
ffffffffc0201abe:	b785                	j	ffffffffc0201a1e <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ac0:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201ac2:	8732                	mv	a4,a2
ffffffffc0201ac4:	b755                	j	ffffffffc0201a68 <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201ac6:	00005697          	auipc	a3,0x5
ffffffffc0201aca:	da268693          	addi	a3,a3,-606 # ffffffffc0206868 <etext+0xcec>
ffffffffc0201ace:	00005617          	auipc	a2,0x5
ffffffffc0201ad2:	b2260613          	addi	a2,a2,-1246 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0201ad6:	06300593          	li	a1,99
ffffffffc0201ada:	00005517          	auipc	a0,0x5
ffffffffc0201ade:	dae50513          	addi	a0,a0,-594 # ffffffffc0206888 <etext+0xd0c>
ffffffffc0201ae2:	f4afe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201ae6 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201ae6:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201ae8:	00005517          	auipc	a0,0x5
ffffffffc0201aec:	db850513          	addi	a0,a0,-584 # ffffffffc02068a0 <etext+0xd24>
{
ffffffffc0201af0:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201af2:	df0fe0ef          	jal	ffffffffc02000e2 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201af6:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201af8:	00005517          	auipc	a0,0x5
ffffffffc0201afc:	dc050513          	addi	a0,a0,-576 # ffffffffc02068b8 <etext+0xd3c>
}
ffffffffc0201b00:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b02:	de0fe06f          	j	ffffffffc02000e2 <cprintf>

ffffffffc0201b06 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201b06:	4501                	li	a0,0
ffffffffc0201b08:	8082                	ret

ffffffffc0201b0a <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b0a:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b0c:	6685                	lui	a3,0x1
{
ffffffffc0201b0e:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b10:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x84c1>
ffffffffc0201b12:	04a6f963          	bgeu	a3,a0,ffffffffc0201b64 <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b16:	e42a                	sd	a0,8(sp)
ffffffffc0201b18:	4561                	li	a0,24
ffffffffc0201b1a:	e822                	sd	s0,16(sp)
ffffffffc0201b1c:	ee1ff0ef          	jal	ffffffffc02019fc <slob_alloc.constprop.0>
ffffffffc0201b20:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201b22:	c541                	beqz	a0,ffffffffc0201baa <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201b24:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201b26:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201b28:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201b2a:	00f75763          	bge	a4,a5,ffffffffc0201b38 <kmalloc+0x2e>
ffffffffc0201b2e:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201b32:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201b34:	fef74de3          	blt	a4,a5,ffffffffc0201b2e <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201b38:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b3a:	e5fff0ef          	jal	ffffffffc0201998 <__slob_get_free_pages.constprop.0>
ffffffffc0201b3e:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201b40:	cd31                	beqz	a0,ffffffffc0201b9c <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b42:	100027f3          	csrr	a5,sstatus
ffffffffc0201b46:	8b89                	andi	a5,a5,2
ffffffffc0201b48:	eb85                	bnez	a5,ffffffffc0201b78 <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201b4a:	000e3797          	auipc	a5,0xe3
ffffffffc0201b4e:	6ce7b783          	ld	a5,1742(a5) # ffffffffc02e5218 <bigblocks>
		bigblocks = bb;
ffffffffc0201b52:	000e3717          	auipc	a4,0xe3
ffffffffc0201b56:	6c873323          	sd	s0,1734(a4) # ffffffffc02e5218 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201b5a:	e81c                	sd	a5,16(s0)
    if (flag)
ffffffffc0201b5c:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201b5e:	60e2                	ld	ra,24(sp)
ffffffffc0201b60:	6105                	addi	sp,sp,32
ffffffffc0201b62:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b64:	0541                	addi	a0,a0,16
ffffffffc0201b66:	e97ff0ef          	jal	ffffffffc02019fc <slob_alloc.constprop.0>
ffffffffc0201b6a:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b6c:	0541                	addi	a0,a0,16
ffffffffc0201b6e:	fbe5                	bnez	a5,ffffffffc0201b5e <kmalloc+0x54>
		return 0;
ffffffffc0201b70:	4501                	li	a0,0
}
ffffffffc0201b72:	60e2                	ld	ra,24(sp)
ffffffffc0201b74:	6105                	addi	sp,sp,32
ffffffffc0201b76:	8082                	ret
        intr_disable();
ffffffffc0201b78:	d8dfe0ef          	jal	ffffffffc0200904 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b7c:	000e3797          	auipc	a5,0xe3
ffffffffc0201b80:	69c7b783          	ld	a5,1692(a5) # ffffffffc02e5218 <bigblocks>
		bigblocks = bb;
ffffffffc0201b84:	000e3717          	auipc	a4,0xe3
ffffffffc0201b88:	68873a23          	sd	s0,1684(a4) # ffffffffc02e5218 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201b8c:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201b8e:	d71fe0ef          	jal	ffffffffc02008fe <intr_enable>
		return bb->pages;
ffffffffc0201b92:	6408                	ld	a0,8(s0)
}
ffffffffc0201b94:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201b96:	6442                	ld	s0,16(sp)
}
ffffffffc0201b98:	6105                	addi	sp,sp,32
ffffffffc0201b9a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b9c:	8522                	mv	a0,s0
ffffffffc0201b9e:	45e1                	li	a1,24
ffffffffc0201ba0:	ce7ff0ef          	jal	ffffffffc0201886 <slob_free>
		return 0;
ffffffffc0201ba4:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ba6:	6442                	ld	s0,16(sp)
ffffffffc0201ba8:	b7e9                	j	ffffffffc0201b72 <kmalloc+0x68>
ffffffffc0201baa:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201bac:	4501                	li	a0,0
ffffffffc0201bae:	b7d1                	j	ffffffffc0201b72 <kmalloc+0x68>

ffffffffc0201bb0 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bb0:	c571                	beqz	a0,ffffffffc0201c7c <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201bb2:	03451793          	slli	a5,a0,0x34
ffffffffc0201bb6:	e3e1                	bnez	a5,ffffffffc0201c76 <kfree+0xc6>
{
ffffffffc0201bb8:	1101                	addi	sp,sp,-32
ffffffffc0201bba:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201bbc:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc0:	8b89                	andi	a5,a5,2
ffffffffc0201bc2:	e7c1                	bnez	a5,ffffffffc0201c4a <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201bc4:	000e3797          	auipc	a5,0xe3
ffffffffc0201bc8:	6547b783          	ld	a5,1620(a5) # ffffffffc02e5218 <bigblocks>
    return 0;
ffffffffc0201bcc:	4581                	li	a1,0
ffffffffc0201bce:	cbad                	beqz	a5,ffffffffc0201c40 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bd0:	000e3617          	auipc	a2,0xe3
ffffffffc0201bd4:	64860613          	addi	a2,a2,1608 # ffffffffc02e5218 <bigblocks>
ffffffffc0201bd8:	a021                	j	ffffffffc0201be0 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201bda:	01070613          	addi	a2,a4,16
ffffffffc0201bde:	c3a5                	beqz	a5,ffffffffc0201c3e <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201be0:	6794                	ld	a3,8(a5)
ffffffffc0201be2:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201be4:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201be6:	fea69ae3          	bne	a3,a0,ffffffffc0201bda <kfree+0x2a>
				*last = bb->next;
ffffffffc0201bea:	e21c                	sd	a5,0(a2)
    if (flag)
ffffffffc0201bec:	edb5                	bnez	a1,ffffffffc0201c68 <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201bee:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bf2:	0af56263          	bltu	a0,a5,ffffffffc0201c96 <kfree+0xe6>
ffffffffc0201bf6:	000e3797          	auipc	a5,0xe3
ffffffffc0201bfa:	6427b783          	ld	a5,1602(a5) # ffffffffc02e5238 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201bfe:	000e3697          	auipc	a3,0xe3
ffffffffc0201c02:	6426b683          	ld	a3,1602(a3) # ffffffffc02e5240 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201c06:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201c08:	00c55793          	srli	a5,a0,0xc
ffffffffc0201c0c:	06d7f963          	bgeu	a5,a3,ffffffffc0201c7e <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c10:	00006617          	auipc	a2,0x6
ffffffffc0201c14:	7e863603          	ld	a2,2024(a2) # ffffffffc02083f8 <nbase>
ffffffffc0201c18:	000e3517          	auipc	a0,0xe3
ffffffffc0201c1c:	63053503          	ld	a0,1584(a0) # ffffffffc02e5248 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201c20:	4314                	lw	a3,0(a4)
ffffffffc0201c22:	8f91                	sub	a5,a5,a2
ffffffffc0201c24:	079a                	slli	a5,a5,0x6
ffffffffc0201c26:	4585                	li	a1,1
ffffffffc0201c28:	953e                	add	a0,a0,a5
ffffffffc0201c2a:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201c2e:	e03a                	sd	a4,0(sp)
ffffffffc0201c30:	3c1000ef          	jal	ffffffffc02027f0 <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c34:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c36:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c38:	45e1                	li	a1,24
}
ffffffffc0201c3a:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c3c:	b1a9                	j	ffffffffc0201886 <slob_free>
ffffffffc0201c3e:	e185                	bnez	a1,ffffffffc0201c5e <kfree+0xae>
}
ffffffffc0201c40:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c42:	1541                	addi	a0,a0,-16
ffffffffc0201c44:	4581                	li	a1,0
}
ffffffffc0201c46:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c48:	b93d                	j	ffffffffc0201886 <slob_free>
        intr_disable();
ffffffffc0201c4a:	e02a                	sd	a0,0(sp)
ffffffffc0201c4c:	cb9fe0ef          	jal	ffffffffc0200904 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c50:	000e3797          	auipc	a5,0xe3
ffffffffc0201c54:	5c87b783          	ld	a5,1480(a5) # ffffffffc02e5218 <bigblocks>
ffffffffc0201c58:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201c5a:	4585                	li	a1,1
ffffffffc0201c5c:	fbb5                	bnez	a5,ffffffffc0201bd0 <kfree+0x20>
ffffffffc0201c5e:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201c60:	c9ffe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201c64:	6502                	ld	a0,0(sp)
ffffffffc0201c66:	bfe9                	j	ffffffffc0201c40 <kfree+0x90>
ffffffffc0201c68:	e42a                	sd	a0,8(sp)
ffffffffc0201c6a:	e03a                	sd	a4,0(sp)
ffffffffc0201c6c:	c93fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201c70:	6522                	ld	a0,8(sp)
ffffffffc0201c72:	6702                	ld	a4,0(sp)
ffffffffc0201c74:	bfad                	j	ffffffffc0201bee <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c76:	1541                	addi	a0,a0,-16
ffffffffc0201c78:	4581                	li	a1,0
ffffffffc0201c7a:	b131                	j	ffffffffc0201886 <slob_free>
ffffffffc0201c7c:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c7e:	00005617          	auipc	a2,0x5
ffffffffc0201c82:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0206538 <etext+0x9bc>
ffffffffc0201c86:	06900593          	li	a1,105
ffffffffc0201c8a:	00005517          	auipc	a0,0x5
ffffffffc0201c8e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0201c92:	d9afe0ef          	jal	ffffffffc020022c <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c96:	86aa                	mv	a3,a0
ffffffffc0201c98:	00005617          	auipc	a2,0x5
ffffffffc0201c9c:	c4060613          	addi	a2,a2,-960 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc0201ca0:	07700593          	li	a1,119
ffffffffc0201ca4:	00005517          	auipc	a0,0x5
ffffffffc0201ca8:	8b450513          	addi	a0,a0,-1868 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0201cac:	d80fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201cb0 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201cb0:	000df797          	auipc	a5,0xdf
ffffffffc0201cb4:	48878793          	addi	a5,a5,1160 # ffffffffc02e1138 <free_area>
ffffffffc0201cb8:	e79c                	sd	a5,8(a5)
ffffffffc0201cba:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201cbc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201cc0:	8082                	ret

ffffffffc0201cc2 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201cc2:	000df517          	auipc	a0,0xdf
ffffffffc0201cc6:	48656503          	lwu	a0,1158(a0) # ffffffffc02e1148 <free_area+0x10>
ffffffffc0201cca:	8082                	ret

ffffffffc0201ccc <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201ccc:	711d                	addi	sp,sp,-96
ffffffffc0201cce:	e0ca                	sd	s2,64(sp)
    return listelm->next;
ffffffffc0201cd0:	000df917          	auipc	s2,0xdf
ffffffffc0201cd4:	46890913          	addi	s2,s2,1128 # ffffffffc02e1138 <free_area>
ffffffffc0201cd8:	00893783          	ld	a5,8(s2)
ffffffffc0201cdc:	ec86                	sd	ra,88(sp)
ffffffffc0201cde:	e8a2                	sd	s0,80(sp)
ffffffffc0201ce0:	e4a6                	sd	s1,72(sp)
ffffffffc0201ce2:	fc4e                	sd	s3,56(sp)
ffffffffc0201ce4:	f852                	sd	s4,48(sp)
ffffffffc0201ce6:	f456                	sd	s5,40(sp)
ffffffffc0201ce8:	f05a                	sd	s6,32(sp)
ffffffffc0201cea:	ec5e                	sd	s7,24(sp)
ffffffffc0201cec:	e862                	sd	s8,16(sp)
ffffffffc0201cee:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201cf0:	2f278363          	beq	a5,s2,ffffffffc0201fd6 <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0201cf4:	4401                	li	s0,0
ffffffffc0201cf6:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201cf8:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201cfc:	8b09                	andi	a4,a4,2
ffffffffc0201cfe:	2e070063          	beqz	a4,ffffffffc0201fde <default_check+0x312>
        count++, total += p->property;
ffffffffc0201d02:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201d06:	679c                	ld	a5,8(a5)
ffffffffc0201d08:	2485                	addiw	s1,s1,1
ffffffffc0201d0a:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d0c:	ff2796e3          	bne	a5,s2,ffffffffc0201cf8 <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0201d10:	89a2                	mv	s3,s0
ffffffffc0201d12:	317000ef          	jal	ffffffffc0202828 <nr_free_pages>
ffffffffc0201d16:	73351463          	bne	a0,s3,ffffffffc020243e <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201d1a:	4505                	li	a0,1
ffffffffc0201d1c:	29b000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201d20:	8a2a                	mv	s4,a0
ffffffffc0201d22:	44050e63          	beqz	a0,ffffffffc020217e <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201d26:	4505                	li	a0,1
ffffffffc0201d28:	28f000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201d2c:	89aa                	mv	s3,a0
ffffffffc0201d2e:	72050863          	beqz	a0,ffffffffc020245e <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201d32:	4505                	li	a0,1
ffffffffc0201d34:	283000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201d38:	8aaa                	mv	s5,a0
ffffffffc0201d3a:	4c050263          	beqz	a0,ffffffffc02021fe <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201d3e:	40a987b3          	sub	a5,s3,a0
ffffffffc0201d42:	40aa0733          	sub	a4,s4,a0
ffffffffc0201d46:	0017b793          	seqz	a5,a5
ffffffffc0201d4a:	00173713          	seqz	a4,a4
ffffffffc0201d4e:	8fd9                	or	a5,a5,a4
ffffffffc0201d50:	30079763          	bnez	a5,ffffffffc020205e <default_check+0x392>
ffffffffc0201d54:	313a0563          	beq	s4,s3,ffffffffc020205e <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201d58:	000a2783          	lw	a5,0(s4)
ffffffffc0201d5c:	2a079163          	bnez	a5,ffffffffc0201ffe <default_check+0x332>
ffffffffc0201d60:	0009a783          	lw	a5,0(s3)
ffffffffc0201d64:	28079d63          	bnez	a5,ffffffffc0201ffe <default_check+0x332>
ffffffffc0201d68:	411c                	lw	a5,0(a0)
ffffffffc0201d6a:	28079a63          	bnez	a5,ffffffffc0201ffe <default_check+0x332>
    return page - pages + nbase;
ffffffffc0201d6e:	000e3797          	auipc	a5,0xe3
ffffffffc0201d72:	4da7b783          	ld	a5,1242(a5) # ffffffffc02e5248 <pages>
ffffffffc0201d76:	00006617          	auipc	a2,0x6
ffffffffc0201d7a:	68263603          	ld	a2,1666(a2) # ffffffffc02083f8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201d7e:	000e3697          	auipc	a3,0xe3
ffffffffc0201d82:	4c26b683          	ld	a3,1218(a3) # ffffffffc02e5240 <npage>
ffffffffc0201d86:	40fa0733          	sub	a4,s4,a5
ffffffffc0201d8a:	8719                	srai	a4,a4,0x6
ffffffffc0201d8c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d8e:	0732                	slli	a4,a4,0xc
ffffffffc0201d90:	06b2                	slli	a3,a3,0xc
ffffffffc0201d92:	2ad77663          	bgeu	a4,a3,ffffffffc020203e <default_check+0x372>
    return page - pages + nbase;
ffffffffc0201d96:	40f98733          	sub	a4,s3,a5
ffffffffc0201d9a:	8719                	srai	a4,a4,0x6
ffffffffc0201d9c:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d9e:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201da0:	4cd77f63          	bgeu	a4,a3,ffffffffc020227e <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc0201da4:	40f507b3          	sub	a5,a0,a5
ffffffffc0201da8:	8799                	srai	a5,a5,0x6
ffffffffc0201daa:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dac:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201dae:	32d7f863          	bgeu	a5,a3,ffffffffc02020de <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc0201db2:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201db4:	00093c03          	ld	s8,0(s2)
ffffffffc0201db8:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0201dbc:	000dfb17          	auipc	s6,0xdf
ffffffffc0201dc0:	38cb2b03          	lw	s6,908(s6) # ffffffffc02e1148 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0201dc4:	01293023          	sd	s2,0(s2)
ffffffffc0201dc8:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0201dcc:	000df797          	auipc	a5,0xdf
ffffffffc0201dd0:	3607ae23          	sw	zero,892(a5) # ffffffffc02e1148 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201dd4:	1e3000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201dd8:	2e051363          	bnez	a0,ffffffffc02020be <default_check+0x3f2>
    free_page(p0);
ffffffffc0201ddc:	8552                	mv	a0,s4
ffffffffc0201dde:	4585                	li	a1,1
ffffffffc0201de0:	211000ef          	jal	ffffffffc02027f0 <free_pages>
    free_page(p1);
ffffffffc0201de4:	854e                	mv	a0,s3
ffffffffc0201de6:	4585                	li	a1,1
ffffffffc0201de8:	209000ef          	jal	ffffffffc02027f0 <free_pages>
    free_page(p2);
ffffffffc0201dec:	8556                	mv	a0,s5
ffffffffc0201dee:	4585                	li	a1,1
ffffffffc0201df0:	201000ef          	jal	ffffffffc02027f0 <free_pages>
    assert(nr_free == 3);
ffffffffc0201df4:	000df717          	auipc	a4,0xdf
ffffffffc0201df8:	35472703          	lw	a4,852(a4) # ffffffffc02e1148 <free_area+0x10>
ffffffffc0201dfc:	478d                	li	a5,3
ffffffffc0201dfe:	2af71063          	bne	a4,a5,ffffffffc020209e <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201e02:	4505                	li	a0,1
ffffffffc0201e04:	1b3000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e08:	89aa                	mv	s3,a0
ffffffffc0201e0a:	26050a63          	beqz	a0,ffffffffc020207e <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201e0e:	4505                	li	a0,1
ffffffffc0201e10:	1a7000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e14:	8aaa                	mv	s5,a0
ffffffffc0201e16:	3c050463          	beqz	a0,ffffffffc02021de <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201e1a:	4505                	li	a0,1
ffffffffc0201e1c:	19b000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e20:	8a2a                	mv	s4,a0
ffffffffc0201e22:	38050e63          	beqz	a0,ffffffffc02021be <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc0201e26:	4505                	li	a0,1
ffffffffc0201e28:	18f000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e2c:	36051963          	bnez	a0,ffffffffc020219e <default_check+0x4d2>
    free_page(p0);
ffffffffc0201e30:	4585                	li	a1,1
ffffffffc0201e32:	854e                	mv	a0,s3
ffffffffc0201e34:	1bd000ef          	jal	ffffffffc02027f0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201e38:	00893783          	ld	a5,8(s2)
ffffffffc0201e3c:	1f278163          	beq	a5,s2,ffffffffc020201e <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc0201e40:	4505                	li	a0,1
ffffffffc0201e42:	175000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e46:	8caa                	mv	s9,a0
ffffffffc0201e48:	30a99b63          	bne	s3,a0,ffffffffc020215e <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc0201e4c:	4505                	li	a0,1
ffffffffc0201e4e:	169000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e52:	2e051663          	bnez	a0,ffffffffc020213e <default_check+0x472>
    assert(nr_free == 0);
ffffffffc0201e56:	000df797          	auipc	a5,0xdf
ffffffffc0201e5a:	2f27a783          	lw	a5,754(a5) # ffffffffc02e1148 <free_area+0x10>
ffffffffc0201e5e:	2c079063          	bnez	a5,ffffffffc020211e <default_check+0x452>
    free_page(p);
ffffffffc0201e62:	8566                	mv	a0,s9
ffffffffc0201e64:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201e66:	01893023          	sd	s8,0(s2)
ffffffffc0201e6a:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201e6e:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201e72:	17f000ef          	jal	ffffffffc02027f0 <free_pages>
    free_page(p1);
ffffffffc0201e76:	8556                	mv	a0,s5
ffffffffc0201e78:	4585                	li	a1,1
ffffffffc0201e7a:	177000ef          	jal	ffffffffc02027f0 <free_pages>
    free_page(p2);
ffffffffc0201e7e:	8552                	mv	a0,s4
ffffffffc0201e80:	4585                	li	a1,1
ffffffffc0201e82:	16f000ef          	jal	ffffffffc02027f0 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201e86:	4515                	li	a0,5
ffffffffc0201e88:	12f000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201e8c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201e8e:	26050863          	beqz	a0,ffffffffc02020fe <default_check+0x432>
ffffffffc0201e92:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc0201e94:	8b89                	andi	a5,a5,2
ffffffffc0201e96:	54079463          	bnez	a5,ffffffffc02023de <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201e9a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201e9c:	00093b83          	ld	s7,0(s2)
ffffffffc0201ea0:	00893b03          	ld	s6,8(s2)
ffffffffc0201ea4:	01293023          	sd	s2,0(s2)
ffffffffc0201ea8:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0201eac:	10b000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201eb0:	50051763          	bnez	a0,ffffffffc02023be <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201eb4:	08098a13          	addi	s4,s3,128
ffffffffc0201eb8:	8552                	mv	a0,s4
ffffffffc0201eba:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201ebc:	000dfc17          	auipc	s8,0xdf
ffffffffc0201ec0:	28cc2c03          	lw	s8,652(s8) # ffffffffc02e1148 <free_area+0x10>
    nr_free = 0;
ffffffffc0201ec4:	000df797          	auipc	a5,0xdf
ffffffffc0201ec8:	2807a223          	sw	zero,644(a5) # ffffffffc02e1148 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201ecc:	125000ef          	jal	ffffffffc02027f0 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201ed0:	4511                	li	a0,4
ffffffffc0201ed2:	0e5000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201ed6:	4c051463          	bnez	a0,ffffffffc020239e <default_check+0x6d2>
ffffffffc0201eda:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	48078f63          	beqz	a5,ffffffffc020237e <default_check+0x6b2>
ffffffffc0201ee4:	0909a503          	lw	a0,144(s3)
ffffffffc0201ee8:	478d                	li	a5,3
ffffffffc0201eea:	48f51a63          	bne	a0,a5,ffffffffc020237e <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201eee:	0c9000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201ef2:	8aaa                	mv	s5,a0
ffffffffc0201ef4:	46050563          	beqz	a0,ffffffffc020235e <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc0201ef8:	4505                	li	a0,1
ffffffffc0201efa:	0bd000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201efe:	44051063          	bnez	a0,ffffffffc020233e <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201f02:	415a1e63          	bne	s4,s5,ffffffffc020231e <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201f06:	4585                	li	a1,1
ffffffffc0201f08:	854e                	mv	a0,s3
ffffffffc0201f0a:	0e7000ef          	jal	ffffffffc02027f0 <free_pages>
    free_pages(p1, 3);
ffffffffc0201f0e:	8552                	mv	a0,s4
ffffffffc0201f10:	458d                	li	a1,3
ffffffffc0201f12:	0df000ef          	jal	ffffffffc02027f0 <free_pages>
ffffffffc0201f16:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201f1a:	8b89                	andi	a5,a5,2
ffffffffc0201f1c:	3e078163          	beqz	a5,ffffffffc02022fe <default_check+0x632>
ffffffffc0201f20:	0109aa83          	lw	s5,16(s3)
ffffffffc0201f24:	4785                	li	a5,1
ffffffffc0201f26:	3cfa9c63          	bne	s5,a5,ffffffffc02022fe <default_check+0x632>
ffffffffc0201f2a:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201f2e:	8b89                	andi	a5,a5,2
ffffffffc0201f30:	3a078763          	beqz	a5,ffffffffc02022de <default_check+0x612>
ffffffffc0201f34:	010a2703          	lw	a4,16(s4)
ffffffffc0201f38:	478d                	li	a5,3
ffffffffc0201f3a:	3af71263          	bne	a4,a5,ffffffffc02022de <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201f3e:	8556                	mv	a0,s5
ffffffffc0201f40:	077000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201f44:	36a99d63          	bne	s3,a0,ffffffffc02022be <default_check+0x5f2>
    free_page(p0);
ffffffffc0201f48:	85d6                	mv	a1,s5
ffffffffc0201f4a:	0a7000ef          	jal	ffffffffc02027f0 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201f4e:	4509                	li	a0,2
ffffffffc0201f50:	067000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201f54:	34aa1563          	bne	s4,a0,ffffffffc020229e <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc0201f58:	4589                	li	a1,2
ffffffffc0201f5a:	097000ef          	jal	ffffffffc02027f0 <free_pages>
    free_page(p2);
ffffffffc0201f5e:	04098513          	addi	a0,s3,64
ffffffffc0201f62:	85d6                	mv	a1,s5
ffffffffc0201f64:	08d000ef          	jal	ffffffffc02027f0 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201f68:	4515                	li	a0,5
ffffffffc0201f6a:	04d000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201f6e:	89aa                	mv	s3,a0
ffffffffc0201f70:	48050763          	beqz	a0,ffffffffc02023fe <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc0201f74:	8556                	mv	a0,s5
ffffffffc0201f76:	041000ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0201f7a:	2e051263          	bnez	a0,ffffffffc020225e <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201f7e:	000df797          	auipc	a5,0xdf
ffffffffc0201f82:	1ca7a783          	lw	a5,458(a5) # ffffffffc02e1148 <free_area+0x10>
ffffffffc0201f86:	2a079c63          	bnez	a5,ffffffffc020223e <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201f8a:	854e                	mv	a0,s3
ffffffffc0201f8c:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0201f8e:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0201f92:	01793023          	sd	s7,0(s2)
ffffffffc0201f96:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0201f9a:	057000ef          	jal	ffffffffc02027f0 <free_pages>
    return listelm->next;
ffffffffc0201f9e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fa2:	01278963          	beq	a5,s2,ffffffffc0201fb4 <default_check+0x2e8>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0201fa6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201faa:	679c                	ld	a5,8(a5)
ffffffffc0201fac:	34fd                	addiw	s1,s1,-1
ffffffffc0201fae:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fb0:	ff279be3          	bne	a5,s2,ffffffffc0201fa6 <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc0201fb4:	26049563          	bnez	s1,ffffffffc020221e <default_check+0x552>
    assert(total == 0);
ffffffffc0201fb8:	46041363          	bnez	s0,ffffffffc020241e <default_check+0x752>
}
ffffffffc0201fbc:	60e6                	ld	ra,88(sp)
ffffffffc0201fbe:	6446                	ld	s0,80(sp)
ffffffffc0201fc0:	64a6                	ld	s1,72(sp)
ffffffffc0201fc2:	6906                	ld	s2,64(sp)
ffffffffc0201fc4:	79e2                	ld	s3,56(sp)
ffffffffc0201fc6:	7a42                	ld	s4,48(sp)
ffffffffc0201fc8:	7aa2                	ld	s5,40(sp)
ffffffffc0201fca:	7b02                	ld	s6,32(sp)
ffffffffc0201fcc:	6be2                	ld	s7,24(sp)
ffffffffc0201fce:	6c42                	ld	s8,16(sp)
ffffffffc0201fd0:	6ca2                	ld	s9,8(sp)
ffffffffc0201fd2:	6125                	addi	sp,sp,96
ffffffffc0201fd4:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fd6:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201fd8:	4401                	li	s0,0
ffffffffc0201fda:	4481                	li	s1,0
ffffffffc0201fdc:	bb1d                	j	ffffffffc0201d12 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0201fde:	00005697          	auipc	a3,0x5
ffffffffc0201fe2:	92268693          	addi	a3,a3,-1758 # ffffffffc0206900 <etext+0xd84>
ffffffffc0201fe6:	00004617          	auipc	a2,0x4
ffffffffc0201fea:	60a60613          	addi	a2,a2,1546 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0201fee:	11000593          	li	a1,272
ffffffffc0201ff2:	00005517          	auipc	a0,0x5
ffffffffc0201ff6:	91e50513          	addi	a0,a0,-1762 # ffffffffc0206910 <etext+0xd94>
ffffffffc0201ffa:	a32fe0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201ffe:	00005697          	auipc	a3,0x5
ffffffffc0202002:	9d268693          	addi	a3,a3,-1582 # ffffffffc02069d0 <etext+0xe54>
ffffffffc0202006:	00004617          	auipc	a2,0x4
ffffffffc020200a:	5ea60613          	addi	a2,a2,1514 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020200e:	0dc00593          	li	a1,220
ffffffffc0202012:	00005517          	auipc	a0,0x5
ffffffffc0202016:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0206910 <etext+0xd94>
ffffffffc020201a:	a12fe0ef          	jal	ffffffffc020022c <__panic>
    assert(!list_empty(&free_list));
ffffffffc020201e:	00005697          	auipc	a3,0x5
ffffffffc0202022:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0206a98 <etext+0xf1c>
ffffffffc0202026:	00004617          	auipc	a2,0x4
ffffffffc020202a:	5ca60613          	addi	a2,a2,1482 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020202e:	0f700593          	li	a1,247
ffffffffc0202032:	00005517          	auipc	a0,0x5
ffffffffc0202036:	8de50513          	addi	a0,a0,-1826 # ffffffffc0206910 <etext+0xd94>
ffffffffc020203a:	9f2fe0ef          	jal	ffffffffc020022c <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020203e:	00005697          	auipc	a3,0x5
ffffffffc0202042:	9d268693          	addi	a3,a3,-1582 # ffffffffc0206a10 <etext+0xe94>
ffffffffc0202046:	00004617          	auipc	a2,0x4
ffffffffc020204a:	5aa60613          	addi	a2,a2,1450 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020204e:	0de00593          	li	a1,222
ffffffffc0202052:	00005517          	auipc	a0,0x5
ffffffffc0202056:	8be50513          	addi	a0,a0,-1858 # ffffffffc0206910 <etext+0xd94>
ffffffffc020205a:	9d2fe0ef          	jal	ffffffffc020022c <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020205e:	00005697          	auipc	a3,0x5
ffffffffc0202062:	94a68693          	addi	a3,a3,-1718 # ffffffffc02069a8 <etext+0xe2c>
ffffffffc0202066:	00004617          	auipc	a2,0x4
ffffffffc020206a:	58a60613          	addi	a2,a2,1418 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020206e:	0db00593          	li	a1,219
ffffffffc0202072:	00005517          	auipc	a0,0x5
ffffffffc0202076:	89e50513          	addi	a0,a0,-1890 # ffffffffc0206910 <etext+0xd94>
ffffffffc020207a:	9b2fe0ef          	jal	ffffffffc020022c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020207e:	00005697          	auipc	a3,0x5
ffffffffc0202082:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0206948 <etext+0xdcc>
ffffffffc0202086:	00004617          	auipc	a2,0x4
ffffffffc020208a:	56a60613          	addi	a2,a2,1386 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020208e:	0f000593          	li	a1,240
ffffffffc0202092:	00005517          	auipc	a0,0x5
ffffffffc0202096:	87e50513          	addi	a0,a0,-1922 # ffffffffc0206910 <etext+0xd94>
ffffffffc020209a:	992fe0ef          	jal	ffffffffc020022c <__panic>
    assert(nr_free == 3);
ffffffffc020209e:	00005697          	auipc	a3,0x5
ffffffffc02020a2:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0206a88 <etext+0xf0c>
ffffffffc02020a6:	00004617          	auipc	a2,0x4
ffffffffc02020aa:	54a60613          	addi	a2,a2,1354 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02020ae:	0ee00593          	li	a1,238
ffffffffc02020b2:	00005517          	auipc	a0,0x5
ffffffffc02020b6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0206910 <etext+0xd94>
ffffffffc02020ba:	972fe0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020be:	00005697          	auipc	a3,0x5
ffffffffc02020c2:	9b268693          	addi	a3,a3,-1614 # ffffffffc0206a70 <etext+0xef4>
ffffffffc02020c6:	00004617          	auipc	a2,0x4
ffffffffc02020ca:	52a60613          	addi	a2,a2,1322 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02020ce:	0e900593          	li	a1,233
ffffffffc02020d2:	00005517          	auipc	a0,0x5
ffffffffc02020d6:	83e50513          	addi	a0,a0,-1986 # ffffffffc0206910 <etext+0xd94>
ffffffffc02020da:	952fe0ef          	jal	ffffffffc020022c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02020de:	00005697          	auipc	a3,0x5
ffffffffc02020e2:	97268693          	addi	a3,a3,-1678 # ffffffffc0206a50 <etext+0xed4>
ffffffffc02020e6:	00004617          	auipc	a2,0x4
ffffffffc02020ea:	50a60613          	addi	a2,a2,1290 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02020ee:	0e000593          	li	a1,224
ffffffffc02020f2:	00005517          	auipc	a0,0x5
ffffffffc02020f6:	81e50513          	addi	a0,a0,-2018 # ffffffffc0206910 <etext+0xd94>
ffffffffc02020fa:	932fe0ef          	jal	ffffffffc020022c <__panic>
    assert(p0 != NULL);
ffffffffc02020fe:	00005697          	auipc	a3,0x5
ffffffffc0202102:	9e268693          	addi	a3,a3,-1566 # ffffffffc0206ae0 <etext+0xf64>
ffffffffc0202106:	00004617          	auipc	a2,0x4
ffffffffc020210a:	4ea60613          	addi	a2,a2,1258 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020210e:	11800593          	li	a1,280
ffffffffc0202112:	00004517          	auipc	a0,0x4
ffffffffc0202116:	7fe50513          	addi	a0,a0,2046 # ffffffffc0206910 <etext+0xd94>
ffffffffc020211a:	912fe0ef          	jal	ffffffffc020022c <__panic>
    assert(nr_free == 0);
ffffffffc020211e:	00005697          	auipc	a3,0x5
ffffffffc0202122:	9b268693          	addi	a3,a3,-1614 # ffffffffc0206ad0 <etext+0xf54>
ffffffffc0202126:	00004617          	auipc	a2,0x4
ffffffffc020212a:	4ca60613          	addi	a2,a2,1226 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020212e:	0fd00593          	li	a1,253
ffffffffc0202132:	00004517          	auipc	a0,0x4
ffffffffc0202136:	7de50513          	addi	a0,a0,2014 # ffffffffc0206910 <etext+0xd94>
ffffffffc020213a:	8f2fe0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_page() == NULL);
ffffffffc020213e:	00005697          	auipc	a3,0x5
ffffffffc0202142:	93268693          	addi	a3,a3,-1742 # ffffffffc0206a70 <etext+0xef4>
ffffffffc0202146:	00004617          	auipc	a2,0x4
ffffffffc020214a:	4aa60613          	addi	a2,a2,1194 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020214e:	0fb00593          	li	a1,251
ffffffffc0202152:	00004517          	auipc	a0,0x4
ffffffffc0202156:	7be50513          	addi	a0,a0,1982 # ffffffffc0206910 <etext+0xd94>
ffffffffc020215a:	8d2fe0ef          	jal	ffffffffc020022c <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020215e:	00005697          	auipc	a3,0x5
ffffffffc0202162:	95268693          	addi	a3,a3,-1710 # ffffffffc0206ab0 <etext+0xf34>
ffffffffc0202166:	00004617          	auipc	a2,0x4
ffffffffc020216a:	48a60613          	addi	a2,a2,1162 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020216e:	0fa00593          	li	a1,250
ffffffffc0202172:	00004517          	auipc	a0,0x4
ffffffffc0202176:	79e50513          	addi	a0,a0,1950 # ffffffffc0206910 <etext+0xd94>
ffffffffc020217a:	8b2fe0ef          	jal	ffffffffc020022c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020217e:	00004697          	auipc	a3,0x4
ffffffffc0202182:	7ca68693          	addi	a3,a3,1994 # ffffffffc0206948 <etext+0xdcc>
ffffffffc0202186:	00004617          	auipc	a2,0x4
ffffffffc020218a:	46a60613          	addi	a2,a2,1130 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020218e:	0d700593          	li	a1,215
ffffffffc0202192:	00004517          	auipc	a0,0x4
ffffffffc0202196:	77e50513          	addi	a0,a0,1918 # ffffffffc0206910 <etext+0xd94>
ffffffffc020219a:	892fe0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_page() == NULL);
ffffffffc020219e:	00005697          	auipc	a3,0x5
ffffffffc02021a2:	8d268693          	addi	a3,a3,-1838 # ffffffffc0206a70 <etext+0xef4>
ffffffffc02021a6:	00004617          	auipc	a2,0x4
ffffffffc02021aa:	44a60613          	addi	a2,a2,1098 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02021ae:	0f400593          	li	a1,244
ffffffffc02021b2:	00004517          	auipc	a0,0x4
ffffffffc02021b6:	75e50513          	addi	a0,a0,1886 # ffffffffc0206910 <etext+0xd94>
ffffffffc02021ba:	872fe0ef          	jal	ffffffffc020022c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021be:	00004697          	auipc	a3,0x4
ffffffffc02021c2:	7ca68693          	addi	a3,a3,1994 # ffffffffc0206988 <etext+0xe0c>
ffffffffc02021c6:	00004617          	auipc	a2,0x4
ffffffffc02021ca:	42a60613          	addi	a2,a2,1066 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02021ce:	0f200593          	li	a1,242
ffffffffc02021d2:	00004517          	auipc	a0,0x4
ffffffffc02021d6:	73e50513          	addi	a0,a0,1854 # ffffffffc0206910 <etext+0xd94>
ffffffffc02021da:	852fe0ef          	jal	ffffffffc020022c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02021de:	00004697          	auipc	a3,0x4
ffffffffc02021e2:	78a68693          	addi	a3,a3,1930 # ffffffffc0206968 <etext+0xdec>
ffffffffc02021e6:	00004617          	auipc	a2,0x4
ffffffffc02021ea:	40a60613          	addi	a2,a2,1034 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02021ee:	0f100593          	li	a1,241
ffffffffc02021f2:	00004517          	auipc	a0,0x4
ffffffffc02021f6:	71e50513          	addi	a0,a0,1822 # ffffffffc0206910 <etext+0xd94>
ffffffffc02021fa:	832fe0ef          	jal	ffffffffc020022c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021fe:	00004697          	auipc	a3,0x4
ffffffffc0202202:	78a68693          	addi	a3,a3,1930 # ffffffffc0206988 <etext+0xe0c>
ffffffffc0202206:	00004617          	auipc	a2,0x4
ffffffffc020220a:	3ea60613          	addi	a2,a2,1002 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020220e:	0d900593          	li	a1,217
ffffffffc0202212:	00004517          	auipc	a0,0x4
ffffffffc0202216:	6fe50513          	addi	a0,a0,1790 # ffffffffc0206910 <etext+0xd94>
ffffffffc020221a:	812fe0ef          	jal	ffffffffc020022c <__panic>
    assert(count == 0);
ffffffffc020221e:	00005697          	auipc	a3,0x5
ffffffffc0202222:	a1268693          	addi	a3,a3,-1518 # ffffffffc0206c30 <etext+0x10b4>
ffffffffc0202226:	00004617          	auipc	a2,0x4
ffffffffc020222a:	3ca60613          	addi	a2,a2,970 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020222e:	14600593          	li	a1,326
ffffffffc0202232:	00004517          	auipc	a0,0x4
ffffffffc0202236:	6de50513          	addi	a0,a0,1758 # ffffffffc0206910 <etext+0xd94>
ffffffffc020223a:	ff3fd0ef          	jal	ffffffffc020022c <__panic>
    assert(nr_free == 0);
ffffffffc020223e:	00005697          	auipc	a3,0x5
ffffffffc0202242:	89268693          	addi	a3,a3,-1902 # ffffffffc0206ad0 <etext+0xf54>
ffffffffc0202246:	00004617          	auipc	a2,0x4
ffffffffc020224a:	3aa60613          	addi	a2,a2,938 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020224e:	13a00593          	li	a1,314
ffffffffc0202252:	00004517          	auipc	a0,0x4
ffffffffc0202256:	6be50513          	addi	a0,a0,1726 # ffffffffc0206910 <etext+0xd94>
ffffffffc020225a:	fd3fd0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_page() == NULL);
ffffffffc020225e:	00005697          	auipc	a3,0x5
ffffffffc0202262:	81268693          	addi	a3,a3,-2030 # ffffffffc0206a70 <etext+0xef4>
ffffffffc0202266:	00004617          	auipc	a2,0x4
ffffffffc020226a:	38a60613          	addi	a2,a2,906 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020226e:	13800593          	li	a1,312
ffffffffc0202272:	00004517          	auipc	a0,0x4
ffffffffc0202276:	69e50513          	addi	a0,a0,1694 # ffffffffc0206910 <etext+0xd94>
ffffffffc020227a:	fb3fd0ef          	jal	ffffffffc020022c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020227e:	00004697          	auipc	a3,0x4
ffffffffc0202282:	7b268693          	addi	a3,a3,1970 # ffffffffc0206a30 <etext+0xeb4>
ffffffffc0202286:	00004617          	auipc	a2,0x4
ffffffffc020228a:	36a60613          	addi	a2,a2,874 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020228e:	0df00593          	li	a1,223
ffffffffc0202292:	00004517          	auipc	a0,0x4
ffffffffc0202296:	67e50513          	addi	a0,a0,1662 # ffffffffc0206910 <etext+0xd94>
ffffffffc020229a:	f93fd0ef          	jal	ffffffffc020022c <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020229e:	00005697          	auipc	a3,0x5
ffffffffc02022a2:	95268693          	addi	a3,a3,-1710 # ffffffffc0206bf0 <etext+0x1074>
ffffffffc02022a6:	00004617          	auipc	a2,0x4
ffffffffc02022aa:	34a60613          	addi	a2,a2,842 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02022ae:	13200593          	li	a1,306
ffffffffc02022b2:	00004517          	auipc	a0,0x4
ffffffffc02022b6:	65e50513          	addi	a0,a0,1630 # ffffffffc0206910 <etext+0xd94>
ffffffffc02022ba:	f73fd0ef          	jal	ffffffffc020022c <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02022be:	00005697          	auipc	a3,0x5
ffffffffc02022c2:	91268693          	addi	a3,a3,-1774 # ffffffffc0206bd0 <etext+0x1054>
ffffffffc02022c6:	00004617          	auipc	a2,0x4
ffffffffc02022ca:	32a60613          	addi	a2,a2,810 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02022ce:	13000593          	li	a1,304
ffffffffc02022d2:	00004517          	auipc	a0,0x4
ffffffffc02022d6:	63e50513          	addi	a0,a0,1598 # ffffffffc0206910 <etext+0xd94>
ffffffffc02022da:	f53fd0ef          	jal	ffffffffc020022c <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02022de:	00005697          	auipc	a3,0x5
ffffffffc02022e2:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0206ba8 <etext+0x102c>
ffffffffc02022e6:	00004617          	auipc	a2,0x4
ffffffffc02022ea:	30a60613          	addi	a2,a2,778 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02022ee:	12e00593          	li	a1,302
ffffffffc02022f2:	00004517          	auipc	a0,0x4
ffffffffc02022f6:	61e50513          	addi	a0,a0,1566 # ffffffffc0206910 <etext+0xd94>
ffffffffc02022fa:	f33fd0ef          	jal	ffffffffc020022c <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02022fe:	00005697          	auipc	a3,0x5
ffffffffc0202302:	88268693          	addi	a3,a3,-1918 # ffffffffc0206b80 <etext+0x1004>
ffffffffc0202306:	00004617          	auipc	a2,0x4
ffffffffc020230a:	2ea60613          	addi	a2,a2,746 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020230e:	12d00593          	li	a1,301
ffffffffc0202312:	00004517          	auipc	a0,0x4
ffffffffc0202316:	5fe50513          	addi	a0,a0,1534 # ffffffffc0206910 <etext+0xd94>
ffffffffc020231a:	f13fd0ef          	jal	ffffffffc020022c <__panic>
    assert(p0 + 2 == p1);
ffffffffc020231e:	00005697          	auipc	a3,0x5
ffffffffc0202322:	85268693          	addi	a3,a3,-1966 # ffffffffc0206b70 <etext+0xff4>
ffffffffc0202326:	00004617          	auipc	a2,0x4
ffffffffc020232a:	2ca60613          	addi	a2,a2,714 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020232e:	12800593          	li	a1,296
ffffffffc0202332:	00004517          	auipc	a0,0x4
ffffffffc0202336:	5de50513          	addi	a0,a0,1502 # ffffffffc0206910 <etext+0xd94>
ffffffffc020233a:	ef3fd0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_page() == NULL);
ffffffffc020233e:	00004697          	auipc	a3,0x4
ffffffffc0202342:	73268693          	addi	a3,a3,1842 # ffffffffc0206a70 <etext+0xef4>
ffffffffc0202346:	00004617          	auipc	a2,0x4
ffffffffc020234a:	2aa60613          	addi	a2,a2,682 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020234e:	12700593          	li	a1,295
ffffffffc0202352:	00004517          	auipc	a0,0x4
ffffffffc0202356:	5be50513          	addi	a0,a0,1470 # ffffffffc0206910 <etext+0xd94>
ffffffffc020235a:	ed3fd0ef          	jal	ffffffffc020022c <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020235e:	00004697          	auipc	a3,0x4
ffffffffc0202362:	7f268693          	addi	a3,a3,2034 # ffffffffc0206b50 <etext+0xfd4>
ffffffffc0202366:	00004617          	auipc	a2,0x4
ffffffffc020236a:	28a60613          	addi	a2,a2,650 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020236e:	12600593          	li	a1,294
ffffffffc0202372:	00004517          	auipc	a0,0x4
ffffffffc0202376:	59e50513          	addi	a0,a0,1438 # ffffffffc0206910 <etext+0xd94>
ffffffffc020237a:	eb3fd0ef          	jal	ffffffffc020022c <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020237e:	00004697          	auipc	a3,0x4
ffffffffc0202382:	7a268693          	addi	a3,a3,1954 # ffffffffc0206b20 <etext+0xfa4>
ffffffffc0202386:	00004617          	auipc	a2,0x4
ffffffffc020238a:	26a60613          	addi	a2,a2,618 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020238e:	12500593          	li	a1,293
ffffffffc0202392:	00004517          	auipc	a0,0x4
ffffffffc0202396:	57e50513          	addi	a0,a0,1406 # ffffffffc0206910 <etext+0xd94>
ffffffffc020239a:	e93fd0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020239e:	00004697          	auipc	a3,0x4
ffffffffc02023a2:	76a68693          	addi	a3,a3,1898 # ffffffffc0206b08 <etext+0xf8c>
ffffffffc02023a6:	00004617          	auipc	a2,0x4
ffffffffc02023aa:	24a60613          	addi	a2,a2,586 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02023ae:	12400593          	li	a1,292
ffffffffc02023b2:	00004517          	auipc	a0,0x4
ffffffffc02023b6:	55e50513          	addi	a0,a0,1374 # ffffffffc0206910 <etext+0xd94>
ffffffffc02023ba:	e73fd0ef          	jal	ffffffffc020022c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023be:	00004697          	auipc	a3,0x4
ffffffffc02023c2:	6b268693          	addi	a3,a3,1714 # ffffffffc0206a70 <etext+0xef4>
ffffffffc02023c6:	00004617          	auipc	a2,0x4
ffffffffc02023ca:	22a60613          	addi	a2,a2,554 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02023ce:	11e00593          	li	a1,286
ffffffffc02023d2:	00004517          	auipc	a0,0x4
ffffffffc02023d6:	53e50513          	addi	a0,a0,1342 # ffffffffc0206910 <etext+0xd94>
ffffffffc02023da:	e53fd0ef          	jal	ffffffffc020022c <__panic>
    assert(!PageProperty(p0));
ffffffffc02023de:	00004697          	auipc	a3,0x4
ffffffffc02023e2:	71268693          	addi	a3,a3,1810 # ffffffffc0206af0 <etext+0xf74>
ffffffffc02023e6:	00004617          	auipc	a2,0x4
ffffffffc02023ea:	20a60613          	addi	a2,a2,522 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02023ee:	11900593          	li	a1,281
ffffffffc02023f2:	00004517          	auipc	a0,0x4
ffffffffc02023f6:	51e50513          	addi	a0,a0,1310 # ffffffffc0206910 <etext+0xd94>
ffffffffc02023fa:	e33fd0ef          	jal	ffffffffc020022c <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02023fe:	00005697          	auipc	a3,0x5
ffffffffc0202402:	81268693          	addi	a3,a3,-2030 # ffffffffc0206c10 <etext+0x1094>
ffffffffc0202406:	00004617          	auipc	a2,0x4
ffffffffc020240a:	1ea60613          	addi	a2,a2,490 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020240e:	13700593          	li	a1,311
ffffffffc0202412:	00004517          	auipc	a0,0x4
ffffffffc0202416:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206910 <etext+0xd94>
ffffffffc020241a:	e13fd0ef          	jal	ffffffffc020022c <__panic>
    assert(total == 0);
ffffffffc020241e:	00005697          	auipc	a3,0x5
ffffffffc0202422:	82268693          	addi	a3,a3,-2014 # ffffffffc0206c40 <etext+0x10c4>
ffffffffc0202426:	00004617          	auipc	a2,0x4
ffffffffc020242a:	1ca60613          	addi	a2,a2,458 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020242e:	14700593          	li	a1,327
ffffffffc0202432:	00004517          	auipc	a0,0x4
ffffffffc0202436:	4de50513          	addi	a0,a0,1246 # ffffffffc0206910 <etext+0xd94>
ffffffffc020243a:	df3fd0ef          	jal	ffffffffc020022c <__panic>
    assert(total == nr_free_pages());
ffffffffc020243e:	00004697          	auipc	a3,0x4
ffffffffc0202442:	4ea68693          	addi	a3,a3,1258 # ffffffffc0206928 <etext+0xdac>
ffffffffc0202446:	00004617          	auipc	a2,0x4
ffffffffc020244a:	1aa60613          	addi	a2,a2,426 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020244e:	11300593          	li	a1,275
ffffffffc0202452:	00004517          	auipc	a0,0x4
ffffffffc0202456:	4be50513          	addi	a0,a0,1214 # ffffffffc0206910 <etext+0xd94>
ffffffffc020245a:	dd3fd0ef          	jal	ffffffffc020022c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020245e:	00004697          	auipc	a3,0x4
ffffffffc0202462:	50a68693          	addi	a3,a3,1290 # ffffffffc0206968 <etext+0xdec>
ffffffffc0202466:	00004617          	auipc	a2,0x4
ffffffffc020246a:	18a60613          	addi	a2,a2,394 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020246e:	0d800593          	li	a1,216
ffffffffc0202472:	00004517          	auipc	a0,0x4
ffffffffc0202476:	49e50513          	addi	a0,a0,1182 # ffffffffc0206910 <etext+0xd94>
ffffffffc020247a:	db3fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020247e <default_free_pages>:
{
ffffffffc020247e:	1141                	addi	sp,sp,-16
ffffffffc0202480:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202482:	14058663          	beqz	a1,ffffffffc02025ce <default_free_pages+0x150>
    for (; p != base + n; p++)
ffffffffc0202486:	00659713          	slli	a4,a1,0x6
ffffffffc020248a:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020248e:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc0202490:	c30d                	beqz	a4,ffffffffc02024b2 <default_free_pages+0x34>
ffffffffc0202492:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202494:	8b05                	andi	a4,a4,1
ffffffffc0202496:	10071c63          	bnez	a4,ffffffffc02025ae <default_free_pages+0x130>
ffffffffc020249a:	6798                	ld	a4,8(a5)
ffffffffc020249c:	8b09                	andi	a4,a4,2
ffffffffc020249e:	10071863          	bnez	a4,ffffffffc02025ae <default_free_pages+0x130>
        p->flags = 0;
ffffffffc02024a2:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02024a6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02024aa:	04078793          	addi	a5,a5,64
ffffffffc02024ae:	fed792e3          	bne	a5,a3,ffffffffc0202492 <default_free_pages+0x14>
    base->property = n;
ffffffffc02024b2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02024b4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024b8:	4789                	li	a5,2
ffffffffc02024ba:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02024be:	000df717          	auipc	a4,0xdf
ffffffffc02024c2:	c8a72703          	lw	a4,-886(a4) # ffffffffc02e1148 <free_area+0x10>
ffffffffc02024c6:	000df697          	auipc	a3,0xdf
ffffffffc02024ca:	c7268693          	addi	a3,a3,-910 # ffffffffc02e1138 <free_area>
    return list->next == list;
ffffffffc02024ce:	669c                	ld	a5,8(a3)
ffffffffc02024d0:	9f2d                	addw	a4,a4,a1
ffffffffc02024d2:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc02024d4:	0ad78163          	beq	a5,a3,ffffffffc0202576 <default_free_pages+0xf8>
            struct Page *page = le2page(le, page_link);
ffffffffc02024d8:	fe878713          	addi	a4,a5,-24
ffffffffc02024dc:	4581                	li	a1,0
ffffffffc02024de:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc02024e2:	00e56a63          	bltu	a0,a4,ffffffffc02024f6 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02024e6:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02024e8:	04d70c63          	beq	a4,a3,ffffffffc0202540 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc02024ec:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc02024ee:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc02024f2:	fee57ae3          	bgeu	a0,a4,ffffffffc02024e6 <default_free_pages+0x68>
ffffffffc02024f6:	c199                	beqz	a1,ffffffffc02024fc <default_free_pages+0x7e>
ffffffffc02024f8:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02024fc:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc02024fe:	e390                	sd	a2,0(a5)
ffffffffc0202500:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0202502:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0202504:	f11c                	sd	a5,32(a0)
    if (le != &free_list)
ffffffffc0202506:	00d70d63          	beq	a4,a3,ffffffffc0202520 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020250a:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020250e:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0202512:	02059813          	slli	a6,a1,0x20
ffffffffc0202516:	01a85793          	srli	a5,a6,0x1a
ffffffffc020251a:	97b2                	add	a5,a5,a2
ffffffffc020251c:	02f50c63          	beq	a0,a5,ffffffffc0202554 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202520:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0202522:	00d78c63          	beq	a5,a3,ffffffffc020253a <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0202526:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202528:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020252c:	02061593          	slli	a1,a2,0x20
ffffffffc0202530:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202534:	972a                	add	a4,a4,a0
ffffffffc0202536:	04e68c63          	beq	a3,a4,ffffffffc020258e <default_free_pages+0x110>
}
ffffffffc020253a:	60a2                	ld	ra,8(sp)
ffffffffc020253c:	0141                	addi	sp,sp,16
ffffffffc020253e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202540:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202542:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202544:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202546:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0202548:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc020254a:	02d70f63          	beq	a4,a3,ffffffffc0202588 <default_free_pages+0x10a>
ffffffffc020254e:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0202550:	87ba                	mv	a5,a4
ffffffffc0202552:	bf71                	j	ffffffffc02024ee <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202554:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202556:	5875                	li	a6,-3
ffffffffc0202558:	9fad                	addw	a5,a5,a1
ffffffffc020255a:	fef72c23          	sw	a5,-8(a4)
ffffffffc020255e:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202562:	01853803          	ld	a6,24(a0)
ffffffffc0202566:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0202568:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020256a:	00b83423          	sd	a1,8(a6) # fffffffffffff008 <end+0x3fd19d88>
    return listelm->next;
ffffffffc020256e:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0202570:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_softint_out_size-0x84b0>
ffffffffc0202574:	b77d                	j	ffffffffc0202522 <default_free_pages+0xa4>
}
ffffffffc0202576:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202578:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020257c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020257e:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0202580:	e398                	sd	a4,0(a5)
ffffffffc0202582:	e798                	sd	a4,8(a5)
}
ffffffffc0202584:	0141                	addi	sp,sp,16
ffffffffc0202586:	8082                	ret
ffffffffc0202588:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020258a:	873e                	mv	a4,a5
ffffffffc020258c:	bfad                	j	ffffffffc0202506 <default_free_pages+0x88>
            base->property += p->property;
ffffffffc020258e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202592:	56f5                	li	a3,-3
ffffffffc0202594:	9f31                	addw	a4,a4,a2
ffffffffc0202596:	c918                	sw	a4,16(a0)
ffffffffc0202598:	ff078713          	addi	a4,a5,-16
ffffffffc020259c:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02025a0:	6398                	ld	a4,0(a5)
ffffffffc02025a2:	679c                	ld	a5,8(a5)
}
ffffffffc02025a4:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02025a6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025a8:	e398                	sd	a4,0(a5)
ffffffffc02025aa:	0141                	addi	sp,sp,16
ffffffffc02025ac:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02025ae:	00004697          	auipc	a3,0x4
ffffffffc02025b2:	6aa68693          	addi	a3,a3,1706 # ffffffffc0206c58 <etext+0x10dc>
ffffffffc02025b6:	00004617          	auipc	a2,0x4
ffffffffc02025ba:	03a60613          	addi	a2,a2,58 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02025be:	09400593          	li	a1,148
ffffffffc02025c2:	00004517          	auipc	a0,0x4
ffffffffc02025c6:	34e50513          	addi	a0,a0,846 # ffffffffc0206910 <etext+0xd94>
ffffffffc02025ca:	c63fd0ef          	jal	ffffffffc020022c <__panic>
    assert(n > 0);
ffffffffc02025ce:	00004697          	auipc	a3,0x4
ffffffffc02025d2:	68268693          	addi	a3,a3,1666 # ffffffffc0206c50 <etext+0x10d4>
ffffffffc02025d6:	00004617          	auipc	a2,0x4
ffffffffc02025da:	01a60613          	addi	a2,a2,26 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02025de:	09000593          	li	a1,144
ffffffffc02025e2:	00004517          	auipc	a0,0x4
ffffffffc02025e6:	32e50513          	addi	a0,a0,814 # ffffffffc0206910 <etext+0xd94>
ffffffffc02025ea:	c43fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02025ee <default_alloc_pages>:
    assert(n > 0);
ffffffffc02025ee:	c951                	beqz	a0,ffffffffc0202682 <default_alloc_pages+0x94>
    if (n > nr_free)
ffffffffc02025f0:	000df597          	auipc	a1,0xdf
ffffffffc02025f4:	b585a583          	lw	a1,-1192(a1) # ffffffffc02e1148 <free_area+0x10>
ffffffffc02025f8:	86aa                	mv	a3,a0
ffffffffc02025fa:	02059793          	slli	a5,a1,0x20
ffffffffc02025fe:	9381                	srli	a5,a5,0x20
ffffffffc0202600:	00a7ef63          	bltu	a5,a0,ffffffffc020261e <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0202604:	000df617          	auipc	a2,0xdf
ffffffffc0202608:	b3460613          	addi	a2,a2,-1228 # ffffffffc02e1138 <free_area>
ffffffffc020260c:	87b2                	mv	a5,a2
ffffffffc020260e:	a029                	j	ffffffffc0202618 <default_alloc_pages+0x2a>
        if (p->property >= n)
ffffffffc0202610:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0202614:	00d77763          	bgeu	a4,a3,ffffffffc0202622 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc0202618:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020261a:	fec79be3          	bne	a5,a2,ffffffffc0202610 <default_alloc_pages+0x22>
        return NULL;
ffffffffc020261e:	4501                	li	a0,0
}
ffffffffc0202620:	8082                	ret
        if (page->property > n)
ffffffffc0202622:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc0202626:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020262a:	6798                	ld	a4,8(a5)
ffffffffc020262c:	02089313          	slli	t1,a7,0x20
ffffffffc0202630:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0202634:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0202638:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc020263c:	fe878513          	addi	a0,a5,-24
        if (page->property > n)
ffffffffc0202640:	0266fa63          	bgeu	a3,t1,ffffffffc0202674 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0202644:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc0202648:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc020264c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020264e:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202652:	00870313          	addi	t1,a4,8
ffffffffc0202656:	4889                	li	a7,2
ffffffffc0202658:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020265c:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0202660:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc0202664:	0068b023          	sd	t1,0(a7)
ffffffffc0202668:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc020266c:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0202670:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0202674:	9d95                	subw	a1,a1,a3
ffffffffc0202676:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202678:	5775                	li	a4,-3
ffffffffc020267a:	17c1                	addi	a5,a5,-16
ffffffffc020267c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202680:	8082                	ret
{
ffffffffc0202682:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202684:	00004697          	auipc	a3,0x4
ffffffffc0202688:	5cc68693          	addi	a3,a3,1484 # ffffffffc0206c50 <etext+0x10d4>
ffffffffc020268c:	00004617          	auipc	a2,0x4
ffffffffc0202690:	f6460613          	addi	a2,a2,-156 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0202694:	06c00593          	li	a1,108
ffffffffc0202698:	00004517          	auipc	a0,0x4
ffffffffc020269c:	27850513          	addi	a0,a0,632 # ffffffffc0206910 <etext+0xd94>
{
ffffffffc02026a0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026a2:	b8bfd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02026a6 <default_init_memmap>:
{
ffffffffc02026a6:	1141                	addi	sp,sp,-16
ffffffffc02026a8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026aa:	c9e1                	beqz	a1,ffffffffc020277a <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc02026ac:	00659713          	slli	a4,a1,0x6
ffffffffc02026b0:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02026b4:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02026b6:	cf11                	beqz	a4,ffffffffc02026d2 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02026b8:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02026ba:	8b05                	andi	a4,a4,1
ffffffffc02026bc:	cf59                	beqz	a4,ffffffffc020275a <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02026be:	0007a823          	sw	zero,16(a5)
ffffffffc02026c2:	0007b423          	sd	zero,8(a5)
ffffffffc02026c6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02026ca:	04078793          	addi	a5,a5,64
ffffffffc02026ce:	fed795e3          	bne	a5,a3,ffffffffc02026b8 <default_init_memmap+0x12>
    base->property = n;
ffffffffc02026d2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02026d4:	4789                	li	a5,2
ffffffffc02026d6:	00850713          	addi	a4,a0,8
ffffffffc02026da:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02026de:	000df717          	auipc	a4,0xdf
ffffffffc02026e2:	a6a72703          	lw	a4,-1430(a4) # ffffffffc02e1148 <free_area+0x10>
ffffffffc02026e6:	000df697          	auipc	a3,0xdf
ffffffffc02026ea:	a5268693          	addi	a3,a3,-1454 # ffffffffc02e1138 <free_area>
    return list->next == list;
ffffffffc02026ee:	669c                	ld	a5,8(a3)
ffffffffc02026f0:	9f2d                	addw	a4,a4,a1
ffffffffc02026f2:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc02026f4:	04d78663          	beq	a5,a3,ffffffffc0202740 <default_init_memmap+0x9a>
            struct Page *page = le2page(le, page_link);
ffffffffc02026f8:	fe878713          	addi	a4,a5,-24
ffffffffc02026fc:	4581                	li	a1,0
ffffffffc02026fe:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0202702:	00e56a63          	bltu	a0,a4,ffffffffc0202716 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0202706:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0202708:	02d70263          	beq	a4,a3,ffffffffc020272c <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc020270c:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc020270e:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0202712:	fee57ae3          	bgeu	a0,a4,ffffffffc0202706 <default_init_memmap+0x60>
ffffffffc0202716:	c199                	beqz	a1,ffffffffc020271c <default_init_memmap+0x76>
ffffffffc0202718:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020271c:	6398                	ld	a4,0(a5)
}
ffffffffc020271e:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202720:	e390                	sd	a2,0(a5)
ffffffffc0202722:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0202724:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0202726:	f11c                	sd	a5,32(a0)
ffffffffc0202728:	0141                	addi	sp,sp,16
ffffffffc020272a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020272c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020272e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202730:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202732:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0202734:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc0202736:	00d70e63          	beq	a4,a3,ffffffffc0202752 <default_init_memmap+0xac>
ffffffffc020273a:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020273c:	87ba                	mv	a5,a4
ffffffffc020273e:	bfc1                	j	ffffffffc020270e <default_init_memmap+0x68>
}
ffffffffc0202740:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202742:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0202746:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202748:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc020274a:	e398                	sd	a4,0(a5)
ffffffffc020274c:	e798                	sd	a4,8(a5)
}
ffffffffc020274e:	0141                	addi	sp,sp,16
ffffffffc0202750:	8082                	ret
ffffffffc0202752:	60a2                	ld	ra,8(sp)
ffffffffc0202754:	e290                	sd	a2,0(a3)
ffffffffc0202756:	0141                	addi	sp,sp,16
ffffffffc0202758:	8082                	ret
        assert(PageReserved(p));
ffffffffc020275a:	00004697          	auipc	a3,0x4
ffffffffc020275e:	52668693          	addi	a3,a3,1318 # ffffffffc0206c80 <etext+0x1104>
ffffffffc0202762:	00004617          	auipc	a2,0x4
ffffffffc0202766:	e8e60613          	addi	a2,a2,-370 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020276a:	04b00593          	li	a1,75
ffffffffc020276e:	00004517          	auipc	a0,0x4
ffffffffc0202772:	1a250513          	addi	a0,a0,418 # ffffffffc0206910 <etext+0xd94>
ffffffffc0202776:	ab7fd0ef          	jal	ffffffffc020022c <__panic>
    assert(n > 0);
ffffffffc020277a:	00004697          	auipc	a3,0x4
ffffffffc020277e:	4d668693          	addi	a3,a3,1238 # ffffffffc0206c50 <etext+0x10d4>
ffffffffc0202782:	00004617          	auipc	a2,0x4
ffffffffc0202786:	e6e60613          	addi	a2,a2,-402 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020278a:	04700593          	li	a1,71
ffffffffc020278e:	00004517          	auipc	a0,0x4
ffffffffc0202792:	18250513          	addi	a0,a0,386 # ffffffffc0206910 <etext+0xd94>
ffffffffc0202796:	a97fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020279a <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc020279a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020279c:	00004617          	auipc	a2,0x4
ffffffffc02027a0:	d9c60613          	addi	a2,a2,-612 # ffffffffc0206538 <etext+0x9bc>
ffffffffc02027a4:	06900593          	li	a1,105
ffffffffc02027a8:	00004517          	auipc	a0,0x4
ffffffffc02027ac:	db050513          	addi	a0,a0,-592 # ffffffffc0206558 <etext+0x9dc>
pa2page(uintptr_t pa)
ffffffffc02027b0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02027b2:	a7bfd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02027b6 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027b6:	100027f3          	csrr	a5,sstatus
ffffffffc02027ba:	8b89                	andi	a5,a5,2
ffffffffc02027bc:	e799                	bnez	a5,ffffffffc02027ca <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02027be:	000e3797          	auipc	a5,0xe3
ffffffffc02027c2:	a627b783          	ld	a5,-1438(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc02027c6:	6f9c                	ld	a5,24(a5)
ffffffffc02027c8:	8782                	jr	a5
{
ffffffffc02027ca:	1101                	addi	sp,sp,-32
ffffffffc02027cc:	ec06                	sd	ra,24(sp)
ffffffffc02027ce:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02027d0:	934fe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02027d4:	000e3797          	auipc	a5,0xe3
ffffffffc02027d8:	a4c7b783          	ld	a5,-1460(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc02027dc:	6522                	ld	a0,8(sp)
ffffffffc02027de:	6f9c                	ld	a5,24(a5)
ffffffffc02027e0:	9782                	jalr	a5
ffffffffc02027e2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02027e4:	91afe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02027e8:	60e2                	ld	ra,24(sp)
ffffffffc02027ea:	6522                	ld	a0,8(sp)
ffffffffc02027ec:	6105                	addi	sp,sp,32
ffffffffc02027ee:	8082                	ret

ffffffffc02027f0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027f0:	100027f3          	csrr	a5,sstatus
ffffffffc02027f4:	8b89                	andi	a5,a5,2
ffffffffc02027f6:	e799                	bnez	a5,ffffffffc0202804 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02027f8:	000e3797          	auipc	a5,0xe3
ffffffffc02027fc:	a287b783          	ld	a5,-1496(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202800:	739c                	ld	a5,32(a5)
ffffffffc0202802:	8782                	jr	a5
{
ffffffffc0202804:	1101                	addi	sp,sp,-32
ffffffffc0202806:	ec06                	sd	ra,24(sp)
ffffffffc0202808:	e42e                	sd	a1,8(sp)
ffffffffc020280a:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020280c:	8f8fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202810:	000e3797          	auipc	a5,0xe3
ffffffffc0202814:	a107b783          	ld	a5,-1520(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202818:	65a2                	ld	a1,8(sp)
ffffffffc020281a:	6502                	ld	a0,0(sp)
ffffffffc020281c:	739c                	ld	a5,32(a5)
ffffffffc020281e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202820:	60e2                	ld	ra,24(sp)
ffffffffc0202822:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202824:	8dafe06f          	j	ffffffffc02008fe <intr_enable>

ffffffffc0202828 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202828:	100027f3          	csrr	a5,sstatus
ffffffffc020282c:	8b89                	andi	a5,a5,2
ffffffffc020282e:	e799                	bnez	a5,ffffffffc020283c <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0202830:	000e3797          	auipc	a5,0xe3
ffffffffc0202834:	9f07b783          	ld	a5,-1552(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202838:	779c                	ld	a5,40(a5)
ffffffffc020283a:	8782                	jr	a5
{
ffffffffc020283c:	1101                	addi	sp,sp,-32
ffffffffc020283e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0202840:	8c4fe0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202844:	000e3797          	auipc	a5,0xe3
ffffffffc0202848:	9dc7b783          	ld	a5,-1572(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc020284c:	779c                	ld	a5,40(a5)
ffffffffc020284e:	9782                	jalr	a5
ffffffffc0202850:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202852:	8acfe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202856:	60e2                	ld	ra,24(sp)
ffffffffc0202858:	6522                	ld	a0,8(sp)
ffffffffc020285a:	6105                	addi	sp,sp,32
ffffffffc020285c:	8082                	ret

ffffffffc020285e <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020285e:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202862:	1ff7f793          	andi	a5,a5,511
ffffffffc0202866:	078e                	slli	a5,a5,0x3
ffffffffc0202868:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc020286c:	6314                	ld	a3,0(a4)
{
ffffffffc020286e:	7139                	addi	sp,sp,-64
ffffffffc0202870:	f822                	sd	s0,48(sp)
ffffffffc0202872:	f426                	sd	s1,40(sp)
ffffffffc0202874:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0202876:	0016f793          	andi	a5,a3,1
{
ffffffffc020287a:	842e                	mv	s0,a1
ffffffffc020287c:	8832                	mv	a6,a2
ffffffffc020287e:	000e3497          	auipc	s1,0xe3
ffffffffc0202882:	9c248493          	addi	s1,s1,-1598 # ffffffffc02e5240 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0202886:	ebd1                	bnez	a5,ffffffffc020291a <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202888:	16060d63          	beqz	a2,ffffffffc0202a02 <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020288c:	100027f3          	csrr	a5,sstatus
ffffffffc0202890:	8b89                	andi	a5,a5,2
ffffffffc0202892:	16079e63          	bnez	a5,ffffffffc0202a0e <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202896:	000e3797          	auipc	a5,0xe3
ffffffffc020289a:	98a7b783          	ld	a5,-1654(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc020289e:	4505                	li	a0,1
ffffffffc02028a0:	e43a                	sd	a4,8(sp)
ffffffffc02028a2:	6f9c                	ld	a5,24(a5)
ffffffffc02028a4:	e832                	sd	a2,16(sp)
ffffffffc02028a6:	9782                	jalr	a5
ffffffffc02028a8:	6722                	ld	a4,8(sp)
ffffffffc02028aa:	6842                	ld	a6,16(sp)
ffffffffc02028ac:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02028ae:	14078a63          	beqz	a5,ffffffffc0202a02 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc02028b2:	000e3517          	auipc	a0,0xe3
ffffffffc02028b6:	99653503          	ld	a0,-1642(a0) # ffffffffc02e5248 <pages>
ffffffffc02028ba:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02028be:	000e3497          	auipc	s1,0xe3
ffffffffc02028c2:	98248493          	addi	s1,s1,-1662 # ffffffffc02e5240 <npage>
ffffffffc02028c6:	40a78533          	sub	a0,a5,a0
ffffffffc02028ca:	8519                	srai	a0,a0,0x6
ffffffffc02028cc:	9546                	add	a0,a0,a7
ffffffffc02028ce:	6090                	ld	a2,0(s1)
ffffffffc02028d0:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc02028d4:	4585                	li	a1,1
ffffffffc02028d6:	82b1                	srli	a3,a3,0xc
ffffffffc02028d8:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc02028da:	0532                	slli	a0,a0,0xc
ffffffffc02028dc:	1ac6f763          	bgeu	a3,a2,ffffffffc0202a8a <get_pte+0x22c>
ffffffffc02028e0:	000e3697          	auipc	a3,0xe3
ffffffffc02028e4:	9586b683          	ld	a3,-1704(a3) # ffffffffc02e5238 <va_pa_offset>
ffffffffc02028e8:	6605                	lui	a2,0x1
ffffffffc02028ea:	4581                	li	a1,0
ffffffffc02028ec:	9536                	add	a0,a0,a3
ffffffffc02028ee:	ec42                	sd	a6,24(sp)
ffffffffc02028f0:	e83e                	sd	a5,16(sp)
ffffffffc02028f2:	e43a                	sd	a4,8(sp)
ffffffffc02028f4:	67d020ef          	jal	ffffffffc0205770 <memset>
    return page - pages + nbase;
ffffffffc02028f8:	000e3697          	auipc	a3,0xe3
ffffffffc02028fc:	9506b683          	ld	a3,-1712(a3) # ffffffffc02e5248 <pages>
ffffffffc0202900:	67c2                	ld	a5,16(sp)
ffffffffc0202902:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202906:	6722                	ld	a4,8(sp)
ffffffffc0202908:	40d786b3          	sub	a3,a5,a3
ffffffffc020290c:	8699                	srai	a3,a3,0x6
ffffffffc020290e:	96c6                	add	a3,a3,a7
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202910:	06aa                	slli	a3,a3,0xa
ffffffffc0202912:	6862                	ld	a6,24(sp)
ffffffffc0202914:	0116e693          	ori	a3,a3,17
ffffffffc0202918:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020291a:	c006f693          	andi	a3,a3,-1024
ffffffffc020291e:	6098                	ld	a4,0(s1)
ffffffffc0202920:	068a                	slli	a3,a3,0x2
ffffffffc0202922:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202926:	14e7f663          	bgeu	a5,a4,ffffffffc0202a72 <get_pte+0x214>
ffffffffc020292a:	000e3897          	auipc	a7,0xe3
ffffffffc020292e:	90e88893          	addi	a7,a7,-1778 # ffffffffc02e5238 <va_pa_offset>
ffffffffc0202932:	0008b603          	ld	a2,0(a7)
ffffffffc0202936:	01545793          	srli	a5,s0,0x15
ffffffffc020293a:	1ff7f793          	andi	a5,a5,511
ffffffffc020293e:	96b2                	add	a3,a3,a2
ffffffffc0202940:	078e                	slli	a5,a5,0x3
ffffffffc0202942:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0202944:	6394                	ld	a3,0(a5)
ffffffffc0202946:	0016f613          	andi	a2,a3,1
ffffffffc020294a:	e659                	bnez	a2,ffffffffc02029d8 <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020294c:	0a080b63          	beqz	a6,ffffffffc0202a02 <get_pte+0x1a4>
ffffffffc0202950:	10002773          	csrr	a4,sstatus
ffffffffc0202954:	8b09                	andi	a4,a4,2
ffffffffc0202956:	ef71                	bnez	a4,ffffffffc0202a32 <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202958:	000e3717          	auipc	a4,0xe3
ffffffffc020295c:	8c873703          	ld	a4,-1848(a4) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202960:	4505                	li	a0,1
ffffffffc0202962:	e43e                	sd	a5,8(sp)
ffffffffc0202964:	6f18                	ld	a4,24(a4)
ffffffffc0202966:	9702                	jalr	a4
ffffffffc0202968:	67a2                	ld	a5,8(sp)
ffffffffc020296a:	872a                	mv	a4,a0
ffffffffc020296c:	000e3897          	auipc	a7,0xe3
ffffffffc0202970:	8cc88893          	addi	a7,a7,-1844 # ffffffffc02e5238 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202974:	c759                	beqz	a4,ffffffffc0202a02 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0202976:	000e3697          	auipc	a3,0xe3
ffffffffc020297a:	8d26b683          	ld	a3,-1838(a3) # ffffffffc02e5248 <pages>
ffffffffc020297e:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202982:	608c                	ld	a1,0(s1)
ffffffffc0202984:	40d706b3          	sub	a3,a4,a3
ffffffffc0202988:	8699                	srai	a3,a3,0x6
ffffffffc020298a:	96c2                	add	a3,a3,a6
ffffffffc020298c:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc0202990:	4505                	li	a0,1
ffffffffc0202992:	8231                	srli	a2,a2,0xc
ffffffffc0202994:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202996:	06b2                	slli	a3,a3,0xc
ffffffffc0202998:	10b67663          	bgeu	a2,a1,ffffffffc0202aa4 <get_pte+0x246>
ffffffffc020299c:	0008b503          	ld	a0,0(a7)
ffffffffc02029a0:	6605                	lui	a2,0x1
ffffffffc02029a2:	4581                	li	a1,0
ffffffffc02029a4:	9536                	add	a0,a0,a3
ffffffffc02029a6:	e83a                	sd	a4,16(sp)
ffffffffc02029a8:	e43e                	sd	a5,8(sp)
ffffffffc02029aa:	5c7020ef          	jal	ffffffffc0205770 <memset>
    return page - pages + nbase;
ffffffffc02029ae:	000e3697          	auipc	a3,0xe3
ffffffffc02029b2:	89a6b683          	ld	a3,-1894(a3) # ffffffffc02e5248 <pages>
ffffffffc02029b6:	6742                	ld	a4,16(sp)
ffffffffc02029b8:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02029bc:	67a2                	ld	a5,8(sp)
ffffffffc02029be:	40d706b3          	sub	a3,a4,a3
ffffffffc02029c2:	8699                	srai	a3,a3,0x6
ffffffffc02029c4:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02029c6:	06aa                	slli	a3,a3,0xa
ffffffffc02029c8:	0116e693          	ori	a3,a3,17
ffffffffc02029cc:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02029ce:	6098                	ld	a4,0(s1)
ffffffffc02029d0:	000e3897          	auipc	a7,0xe3
ffffffffc02029d4:	86888893          	addi	a7,a7,-1944 # ffffffffc02e5238 <va_pa_offset>
ffffffffc02029d8:	c006f693          	andi	a3,a3,-1024
ffffffffc02029dc:	068a                	slli	a3,a3,0x2
ffffffffc02029de:	00c6d793          	srli	a5,a3,0xc
ffffffffc02029e2:	06e7fc63          	bgeu	a5,a4,ffffffffc0202a5a <get_pte+0x1fc>
ffffffffc02029e6:	0008b783          	ld	a5,0(a7)
ffffffffc02029ea:	8031                	srli	s0,s0,0xc
ffffffffc02029ec:	1ff47413          	andi	s0,s0,511
ffffffffc02029f0:	040e                	slli	s0,s0,0x3
ffffffffc02029f2:	96be                	add	a3,a3,a5
}
ffffffffc02029f4:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02029f6:	00868533          	add	a0,a3,s0
}
ffffffffc02029fa:	7442                	ld	s0,48(sp)
ffffffffc02029fc:	74a2                	ld	s1,40(sp)
ffffffffc02029fe:	6121                	addi	sp,sp,64
ffffffffc0202a00:	8082                	ret
ffffffffc0202a02:	70e2                	ld	ra,56(sp)
ffffffffc0202a04:	7442                	ld	s0,48(sp)
ffffffffc0202a06:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0202a08:	4501                	li	a0,0
}
ffffffffc0202a0a:	6121                	addi	sp,sp,64
ffffffffc0202a0c:	8082                	ret
        intr_disable();
ffffffffc0202a0e:	e83a                	sd	a4,16(sp)
ffffffffc0202a10:	ec32                	sd	a2,24(sp)
ffffffffc0202a12:	ef3fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a16:	000e3797          	auipc	a5,0xe3
ffffffffc0202a1a:	80a7b783          	ld	a5,-2038(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202a1e:	4505                	li	a0,1
ffffffffc0202a20:	6f9c                	ld	a5,24(a5)
ffffffffc0202a22:	9782                	jalr	a5
ffffffffc0202a24:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202a26:	ed9fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202a2a:	6862                	ld	a6,24(sp)
ffffffffc0202a2c:	6742                	ld	a4,16(sp)
ffffffffc0202a2e:	67a2                	ld	a5,8(sp)
ffffffffc0202a30:	bdbd                	j	ffffffffc02028ae <get_pte+0x50>
        intr_disable();
ffffffffc0202a32:	e83e                	sd	a5,16(sp)
ffffffffc0202a34:	ed1fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202a38:	000e2717          	auipc	a4,0xe2
ffffffffc0202a3c:	7e873703          	ld	a4,2024(a4) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202a40:	4505                	li	a0,1
ffffffffc0202a42:	6f18                	ld	a4,24(a4)
ffffffffc0202a44:	9702                	jalr	a4
ffffffffc0202a46:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202a48:	eb7fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202a4c:	6722                	ld	a4,8(sp)
ffffffffc0202a4e:	67c2                	ld	a5,16(sp)
ffffffffc0202a50:	000e2897          	auipc	a7,0xe2
ffffffffc0202a54:	7e888893          	addi	a7,a7,2024 # ffffffffc02e5238 <va_pa_offset>
ffffffffc0202a58:	bf31                	j	ffffffffc0202974 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202a5a:	00004617          	auipc	a2,0x4
ffffffffc0202a5e:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0202a62:	0fa00593          	li	a1,250
ffffffffc0202a66:	00004517          	auipc	a0,0x4
ffffffffc0202a6a:	24250513          	addi	a0,a0,578 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202a6e:	fbefd0ef          	jal	ffffffffc020022c <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202a72:	00004617          	auipc	a2,0x4
ffffffffc0202a76:	b0660613          	addi	a2,a2,-1274 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0202a7a:	0ed00593          	li	a1,237
ffffffffc0202a7e:	00004517          	auipc	a0,0x4
ffffffffc0202a82:	22a50513          	addi	a0,a0,554 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202a86:	fa6fd0ef          	jal	ffffffffc020022c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202a8a:	86aa                	mv	a3,a0
ffffffffc0202a8c:	00004617          	auipc	a2,0x4
ffffffffc0202a90:	aec60613          	addi	a2,a2,-1300 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0202a94:	0e900593          	li	a1,233
ffffffffc0202a98:	00004517          	auipc	a0,0x4
ffffffffc0202a9c:	21050513          	addi	a0,a0,528 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202aa0:	f8cfd0ef          	jal	ffffffffc020022c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202aa4:	00004617          	auipc	a2,0x4
ffffffffc0202aa8:	ad460613          	addi	a2,a2,-1324 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0202aac:	0f700593          	li	a1,247
ffffffffc0202ab0:	00004517          	auipc	a0,0x4
ffffffffc0202ab4:	1f850513          	addi	a0,a0,504 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202ab8:	f74fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0202abc <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202abc:	1141                	addi	sp,sp,-16
ffffffffc0202abe:	e022                	sd	s0,0(sp)
ffffffffc0202ac0:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ac2:	4601                	li	a2,0
{
ffffffffc0202ac4:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ac6:	d99ff0ef          	jal	ffffffffc020285e <get_pte>
    if (ptep_store != NULL)
ffffffffc0202aca:	c011                	beqz	s0,ffffffffc0202ace <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202acc:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ace:	c511                	beqz	a0,ffffffffc0202ada <get_page+0x1e>
ffffffffc0202ad0:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202ad2:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ad4:	0017f713          	andi	a4,a5,1
ffffffffc0202ad8:	e709                	bnez	a4,ffffffffc0202ae2 <get_page+0x26>
}
ffffffffc0202ada:	60a2                	ld	ra,8(sp)
ffffffffc0202adc:	6402                	ld	s0,0(sp)
ffffffffc0202ade:	0141                	addi	sp,sp,16
ffffffffc0202ae0:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202ae2:	000e2717          	auipc	a4,0xe2
ffffffffc0202ae6:	75e73703          	ld	a4,1886(a4) # ffffffffc02e5240 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202aea:	078a                	slli	a5,a5,0x2
ffffffffc0202aec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202aee:	00e7ff63          	bgeu	a5,a4,ffffffffc0202b0c <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af2:	000e2517          	auipc	a0,0xe2
ffffffffc0202af6:	75653503          	ld	a0,1878(a0) # ffffffffc02e5248 <pages>
ffffffffc0202afa:	60a2                	ld	ra,8(sp)
ffffffffc0202afc:	6402                	ld	s0,0(sp)
ffffffffc0202afe:	079a                	slli	a5,a5,0x6
ffffffffc0202b00:	fe000737          	lui	a4,0xfe000
ffffffffc0202b04:	97ba                	add	a5,a5,a4
ffffffffc0202b06:	953e                	add	a0,a0,a5
ffffffffc0202b08:	0141                	addi	sp,sp,16
ffffffffc0202b0a:	8082                	ret
ffffffffc0202b0c:	c8fff0ef          	jal	ffffffffc020279a <pa2page.part.0>

ffffffffc0202b10 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202b10:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b12:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202b16:	e486                	sd	ra,72(sp)
ffffffffc0202b18:	e0a2                	sd	s0,64(sp)
ffffffffc0202b1a:	fc26                	sd	s1,56(sp)
ffffffffc0202b1c:	f84a                	sd	s2,48(sp)
ffffffffc0202b1e:	f44e                	sd	s3,40(sp)
ffffffffc0202b20:	f052                	sd	s4,32(sp)
ffffffffc0202b22:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b24:	03479713          	slli	a4,a5,0x34
ffffffffc0202b28:	ef61                	bnez	a4,ffffffffc0202c00 <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc0202b2a:	00200a37          	lui	s4,0x200
ffffffffc0202b2e:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202b32:	0145b733          	sltu	a4,a1,s4
ffffffffc0202b36:	0017b793          	seqz	a5,a5
ffffffffc0202b3a:	8fd9                	or	a5,a5,a4
ffffffffc0202b3c:	842e                	mv	s0,a1
ffffffffc0202b3e:	84b2                	mv	s1,a2
ffffffffc0202b40:	e3e5                	bnez	a5,ffffffffc0202c20 <unmap_range+0x110>
ffffffffc0202b42:	4785                	li	a5,1
ffffffffc0202b44:	07fe                	slli	a5,a5,0x1f
ffffffffc0202b46:	0785                	addi	a5,a5,1
ffffffffc0202b48:	892a                	mv	s2,a0
ffffffffc0202b4a:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202b4c:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc0202b50:	0cf67863          	bgeu	a2,a5,ffffffffc0202c20 <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202b54:	4601                	li	a2,0
ffffffffc0202b56:	85a2                	mv	a1,s0
ffffffffc0202b58:	854a                	mv	a0,s2
ffffffffc0202b5a:	d05ff0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc0202b5e:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc0202b60:	cd31                	beqz	a0,ffffffffc0202bbc <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc0202b62:	6118                	ld	a4,0(a0)
ffffffffc0202b64:	ef11                	bnez	a4,ffffffffc0202b80 <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202b66:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202b68:	c019                	beqz	s0,ffffffffc0202b6e <unmap_range+0x5e>
ffffffffc0202b6a:	fe9465e3          	bltu	s0,s1,ffffffffc0202b54 <unmap_range+0x44>
}
ffffffffc0202b6e:	60a6                	ld	ra,72(sp)
ffffffffc0202b70:	6406                	ld	s0,64(sp)
ffffffffc0202b72:	74e2                	ld	s1,56(sp)
ffffffffc0202b74:	7942                	ld	s2,48(sp)
ffffffffc0202b76:	79a2                	ld	s3,40(sp)
ffffffffc0202b78:	7a02                	ld	s4,32(sp)
ffffffffc0202b7a:	6ae2                	ld	s5,24(sp)
ffffffffc0202b7c:	6161                	addi	sp,sp,80
ffffffffc0202b7e:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202b80:	00177693          	andi	a3,a4,1
ffffffffc0202b84:	d2ed                	beqz	a3,ffffffffc0202b66 <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc0202b86:	000e2697          	auipc	a3,0xe2
ffffffffc0202b8a:	6ba6b683          	ld	a3,1722(a3) # ffffffffc02e5240 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b8e:	070a                	slli	a4,a4,0x2
ffffffffc0202b90:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b92:	0ad77763          	bgeu	a4,a3,ffffffffc0202c40 <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b96:	000e2517          	auipc	a0,0xe2
ffffffffc0202b9a:	6b253503          	ld	a0,1714(a0) # ffffffffc02e5248 <pages>
ffffffffc0202b9e:	071a                	slli	a4,a4,0x6
ffffffffc0202ba0:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202ba4:	9736                	add	a4,a4,a3
ffffffffc0202ba6:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202ba8:	4118                	lw	a4,0(a0)
ffffffffc0202baa:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd1ad7f>
ffffffffc0202bac:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202bae:	cb19                	beqz	a4,ffffffffc0202bc4 <unmap_range+0xb4>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202bb0:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202bb4:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202bb8:	944e                	add	s0,s0,s3
ffffffffc0202bba:	b77d                	j	ffffffffc0202b68 <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202bbc:	9452                	add	s0,s0,s4
ffffffffc0202bbe:	01547433          	and	s0,s0,s5
            continue;
ffffffffc0202bc2:	b75d                	j	ffffffffc0202b68 <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202bc4:	10002773          	csrr	a4,sstatus
ffffffffc0202bc8:	8b09                	andi	a4,a4,2
ffffffffc0202bca:	eb19                	bnez	a4,ffffffffc0202be0 <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc0202bcc:	000e2717          	auipc	a4,0xe2
ffffffffc0202bd0:	65473703          	ld	a4,1620(a4) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202bd4:	4585                	li	a1,1
ffffffffc0202bd6:	e03e                	sd	a5,0(sp)
ffffffffc0202bd8:	7318                	ld	a4,32(a4)
ffffffffc0202bda:	9702                	jalr	a4
    if (flag)
ffffffffc0202bdc:	6782                	ld	a5,0(sp)
ffffffffc0202bde:	bfc9                	j	ffffffffc0202bb0 <unmap_range+0xa0>
        intr_disable();
ffffffffc0202be0:	e43e                	sd	a5,8(sp)
ffffffffc0202be2:	e02a                	sd	a0,0(sp)
ffffffffc0202be4:	d21fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202be8:	000e2717          	auipc	a4,0xe2
ffffffffc0202bec:	63873703          	ld	a4,1592(a4) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202bf0:	6502                	ld	a0,0(sp)
ffffffffc0202bf2:	4585                	li	a1,1
ffffffffc0202bf4:	7318                	ld	a4,32(a4)
ffffffffc0202bf6:	9702                	jalr	a4
        intr_enable();
ffffffffc0202bf8:	d07fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202bfc:	67a2                	ld	a5,8(sp)
ffffffffc0202bfe:	bf4d                	j	ffffffffc0202bb0 <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c00:	00004697          	auipc	a3,0x4
ffffffffc0202c04:	0b868693          	addi	a3,a3,184 # ffffffffc0206cb8 <etext+0x113c>
ffffffffc0202c08:	00004617          	auipc	a2,0x4
ffffffffc0202c0c:	9e860613          	addi	a2,a2,-1560 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0202c10:	12200593          	li	a1,290
ffffffffc0202c14:	00004517          	auipc	a0,0x4
ffffffffc0202c18:	09450513          	addi	a0,a0,148 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202c1c:	e10fd0ef          	jal	ffffffffc020022c <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202c20:	00004697          	auipc	a3,0x4
ffffffffc0202c24:	0c868693          	addi	a3,a3,200 # ffffffffc0206ce8 <etext+0x116c>
ffffffffc0202c28:	00004617          	auipc	a2,0x4
ffffffffc0202c2c:	9c860613          	addi	a2,a2,-1592 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0202c30:	12300593          	li	a1,291
ffffffffc0202c34:	00004517          	auipc	a0,0x4
ffffffffc0202c38:	07450513          	addi	a0,a0,116 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202c3c:	df0fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202c40:	b5bff0ef          	jal	ffffffffc020279a <pa2page.part.0>

ffffffffc0202c44 <exit_range>:
{
ffffffffc0202c44:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c46:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202c4a:	ed06                	sd	ra,152(sp)
ffffffffc0202c4c:	e922                	sd	s0,144(sp)
ffffffffc0202c4e:	e526                	sd	s1,136(sp)
ffffffffc0202c50:	e14a                	sd	s2,128(sp)
ffffffffc0202c52:	fcce                	sd	s3,120(sp)
ffffffffc0202c54:	f8d2                	sd	s4,112(sp)
ffffffffc0202c56:	f4d6                	sd	s5,104(sp)
ffffffffc0202c58:	f0da                	sd	s6,96(sp)
ffffffffc0202c5a:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c5c:	17d2                	slli	a5,a5,0x34
ffffffffc0202c5e:	22079263          	bnez	a5,ffffffffc0202e82 <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc0202c62:	00200937          	lui	s2,0x200
ffffffffc0202c66:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202c6a:	0125b733          	sltu	a4,a1,s2
ffffffffc0202c6e:	0017b793          	seqz	a5,a5
ffffffffc0202c72:	8fd9                	or	a5,a5,a4
ffffffffc0202c74:	26079263          	bnez	a5,ffffffffc0202ed8 <exit_range+0x294>
ffffffffc0202c78:	4785                	li	a5,1
ffffffffc0202c7a:	07fe                	slli	a5,a5,0x1f
ffffffffc0202c7c:	0785                	addi	a5,a5,1
ffffffffc0202c7e:	24f67d63          	bgeu	a2,a5,ffffffffc0202ed8 <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202c82:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202c86:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202c8a:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202c8c:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202c8e:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc0202c92:	000e2a97          	auipc	s5,0xe2
ffffffffc0202c96:	5aea8a93          	addi	s5,s5,1454 # ffffffffc02e5240 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202c9a:	400009b7          	lui	s3,0x40000
ffffffffc0202c9e:	a809                	j	ffffffffc0202cb0 <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc0202ca0:	013487b3          	add	a5,s1,s3
ffffffffc0202ca4:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202ca8:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc0202caa:	c3f1                	beqz	a5,ffffffffc0202d6e <exit_range+0x12a>
ffffffffc0202cac:	0cc7f163          	bgeu	a5,a2,ffffffffc0202d6e <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202cb0:	01e4d413          	srli	s0,s1,0x1e
ffffffffc0202cb4:	1ff47413          	andi	s0,s0,511
ffffffffc0202cb8:	040e                	slli	s0,s0,0x3
ffffffffc0202cba:	9452                	add	s0,s0,s4
ffffffffc0202cbc:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc0202cc0:	0018f793          	andi	a5,a7,1
ffffffffc0202cc4:	dff1                	beqz	a5,ffffffffc0202ca0 <exit_range+0x5c>
ffffffffc0202cc6:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cca:	088a                	slli	a7,a7,0x2
ffffffffc0202ccc:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cd0:	20f8f263          	bgeu	a7,a5,ffffffffc0202ed4 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cd4:	fff802b7          	lui	t0,0xfff80
ffffffffc0202cd8:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc0202cdc:	000803b7          	lui	t2,0x80
ffffffffc0202ce0:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ce4:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202ce8:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc0202cea:	1cf77863          	bgeu	a4,a5,ffffffffc0202eba <exit_range+0x276>
ffffffffc0202cee:	000e2f97          	auipc	t6,0xe2
ffffffffc0202cf2:	54af8f93          	addi	t6,t6,1354 # ffffffffc02e5238 <va_pa_offset>
ffffffffc0202cf6:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc0202cfa:	4e85                	li	t4,1
ffffffffc0202cfc:	6b05                	lui	s6,0x1
ffffffffc0202cfe:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202d00:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202d04:	01585713          	srli	a4,a6,0x15
ffffffffc0202d08:	1ff77713          	andi	a4,a4,511
ffffffffc0202d0c:	070e                	slli	a4,a4,0x3
ffffffffc0202d0e:	9772                	add	a4,a4,t3
ffffffffc0202d10:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc0202d12:	0017f693          	andi	a3,a5,1
ffffffffc0202d16:	e6bd                	bnez	a3,ffffffffc0202d84 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc0202d18:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc0202d1a:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202d1c:	00080863          	beqz	a6,ffffffffc0202d2c <exit_range+0xe8>
ffffffffc0202d20:	879a                	mv	a5,t1
ffffffffc0202d22:	00667363          	bgeu	a2,t1,ffffffffc0202d28 <exit_range+0xe4>
ffffffffc0202d26:	87b2                	mv	a5,a2
ffffffffc0202d28:	fcf86ee3          	bltu	a6,a5,ffffffffc0202d04 <exit_range+0xc0>
            if (free_pd0)
ffffffffc0202d2c:	f60e8ae3          	beqz	t4,ffffffffc0202ca0 <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc0202d30:	000ab783          	ld	a5,0(s5)
ffffffffc0202d34:	1af8f063          	bgeu	a7,a5,ffffffffc0202ed4 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d38:	000e2517          	auipc	a0,0xe2
ffffffffc0202d3c:	51053503          	ld	a0,1296(a0) # ffffffffc02e5248 <pages>
ffffffffc0202d40:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202d42:	100027f3          	csrr	a5,sstatus
ffffffffc0202d46:	8b89                	andi	a5,a5,2
ffffffffc0202d48:	10079b63          	bnez	a5,ffffffffc0202e5e <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc0202d4c:	000e2797          	auipc	a5,0xe2
ffffffffc0202d50:	4d47b783          	ld	a5,1236(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202d54:	4585                	li	a1,1
ffffffffc0202d56:	e432                	sd	a2,8(sp)
ffffffffc0202d58:	739c                	ld	a5,32(a5)
ffffffffc0202d5a:	9782                	jalr	a5
ffffffffc0202d5c:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202d5e:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc0202d62:	013487b3          	add	a5,s1,s3
ffffffffc0202d66:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202d6a:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc0202d6c:	f3a1                	bnez	a5,ffffffffc0202cac <exit_range+0x68>
}
ffffffffc0202d6e:	60ea                	ld	ra,152(sp)
ffffffffc0202d70:	644a                	ld	s0,144(sp)
ffffffffc0202d72:	64aa                	ld	s1,136(sp)
ffffffffc0202d74:	690a                	ld	s2,128(sp)
ffffffffc0202d76:	79e6                	ld	s3,120(sp)
ffffffffc0202d78:	7a46                	ld	s4,112(sp)
ffffffffc0202d7a:	7aa6                	ld	s5,104(sp)
ffffffffc0202d7c:	7b06                	ld	s6,96(sp)
ffffffffc0202d7e:	6be6                	ld	s7,88(sp)
ffffffffc0202d80:	610d                	addi	sp,sp,160
ffffffffc0202d82:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202d84:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d88:	078a                	slli	a5,a5,0x2
ffffffffc0202d8a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d8c:	14a7f463          	bgeu	a5,a0,ffffffffc0202ed4 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d90:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc0202d92:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc0202d96:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d9a:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc0202d9e:	10abf263          	bgeu	s7,a0,ffffffffc0202ea2 <exit_range+0x25e>
ffffffffc0202da2:	000fb783          	ld	a5,0(t6)
ffffffffc0202da6:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202da8:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc0202dac:	629c                	ld	a5,0(a3)
ffffffffc0202dae:	8b85                	andi	a5,a5,1
ffffffffc0202db0:	f7ad                	bnez	a5,ffffffffc0202d1a <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202db2:	06a1                	addi	a3,a3,8
ffffffffc0202db4:	fea69ce3          	bne	a3,a0,ffffffffc0202dac <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc0202db8:	000e2517          	auipc	a0,0xe2
ffffffffc0202dbc:	49053503          	ld	a0,1168(a0) # ffffffffc02e5248 <pages>
ffffffffc0202dc0:	952e                	add	a0,a0,a1
ffffffffc0202dc2:	100027f3          	csrr	a5,sstatus
ffffffffc0202dc6:	8b89                	andi	a5,a5,2
ffffffffc0202dc8:	e3b9                	bnez	a5,ffffffffc0202e0e <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc0202dca:	000e2797          	auipc	a5,0xe2
ffffffffc0202dce:	4567b783          	ld	a5,1110(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202dd2:	4585                	li	a1,1
ffffffffc0202dd4:	e0b2                	sd	a2,64(sp)
ffffffffc0202dd6:	739c                	ld	a5,32(a5)
ffffffffc0202dd8:	fc1a                	sd	t1,56(sp)
ffffffffc0202dda:	f846                	sd	a7,48(sp)
ffffffffc0202ddc:	f47a                	sd	t5,40(sp)
ffffffffc0202dde:	f072                	sd	t3,32(sp)
ffffffffc0202de0:	ec76                	sd	t4,24(sp)
ffffffffc0202de2:	e842                	sd	a6,16(sp)
ffffffffc0202de4:	e43a                	sd	a4,8(sp)
ffffffffc0202de6:	9782                	jalr	a5
    if (flag)
ffffffffc0202de8:	6722                	ld	a4,8(sp)
ffffffffc0202dea:	6842                	ld	a6,16(sp)
ffffffffc0202dec:	6ee2                	ld	t4,24(sp)
ffffffffc0202dee:	7e02                	ld	t3,32(sp)
ffffffffc0202df0:	7f22                	ld	t5,40(sp)
ffffffffc0202df2:	78c2                	ld	a7,48(sp)
ffffffffc0202df4:	7362                	ld	t1,56(sp)
ffffffffc0202df6:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202df8:	fff802b7          	lui	t0,0xfff80
ffffffffc0202dfc:	000803b7          	lui	t2,0x80
ffffffffc0202e00:	000e2f97          	auipc	t6,0xe2
ffffffffc0202e04:	438f8f93          	addi	t6,t6,1080 # ffffffffc02e5238 <va_pa_offset>
ffffffffc0202e08:	00073023          	sd	zero,0(a4)
ffffffffc0202e0c:	b739                	j	ffffffffc0202d1a <exit_range+0xd6>
        intr_disable();
ffffffffc0202e0e:	e4b2                	sd	a2,72(sp)
ffffffffc0202e10:	e09a                	sd	t1,64(sp)
ffffffffc0202e12:	fc46                	sd	a7,56(sp)
ffffffffc0202e14:	f47a                	sd	t5,40(sp)
ffffffffc0202e16:	f072                	sd	t3,32(sp)
ffffffffc0202e18:	ec76                	sd	t4,24(sp)
ffffffffc0202e1a:	e842                	sd	a6,16(sp)
ffffffffc0202e1c:	e43a                	sd	a4,8(sp)
ffffffffc0202e1e:	f82a                	sd	a0,48(sp)
ffffffffc0202e20:	ae5fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e24:	000e2797          	auipc	a5,0xe2
ffffffffc0202e28:	3fc7b783          	ld	a5,1020(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202e2c:	7542                	ld	a0,48(sp)
ffffffffc0202e2e:	4585                	li	a1,1
ffffffffc0202e30:	739c                	ld	a5,32(a5)
ffffffffc0202e32:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e34:	acbfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e38:	6722                	ld	a4,8(sp)
ffffffffc0202e3a:	6626                	ld	a2,72(sp)
ffffffffc0202e3c:	6306                	ld	t1,64(sp)
ffffffffc0202e3e:	78e2                	ld	a7,56(sp)
ffffffffc0202e40:	7f22                	ld	t5,40(sp)
ffffffffc0202e42:	7e02                	ld	t3,32(sp)
ffffffffc0202e44:	6ee2                	ld	t4,24(sp)
ffffffffc0202e46:	6842                	ld	a6,16(sp)
ffffffffc0202e48:	000e2f97          	auipc	t6,0xe2
ffffffffc0202e4c:	3f0f8f93          	addi	t6,t6,1008 # ffffffffc02e5238 <va_pa_offset>
ffffffffc0202e50:	000803b7          	lui	t2,0x80
ffffffffc0202e54:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202e58:	00073023          	sd	zero,0(a4)
ffffffffc0202e5c:	bd7d                	j	ffffffffc0202d1a <exit_range+0xd6>
        intr_disable();
ffffffffc0202e5e:	e832                	sd	a2,16(sp)
ffffffffc0202e60:	e42a                	sd	a0,8(sp)
ffffffffc0202e62:	aa3fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e66:	000e2797          	auipc	a5,0xe2
ffffffffc0202e6a:	3ba7b783          	ld	a5,954(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202e6e:	6522                	ld	a0,8(sp)
ffffffffc0202e70:	4585                	li	a1,1
ffffffffc0202e72:	739c                	ld	a5,32(a5)
ffffffffc0202e74:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e76:	a89fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e7a:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202e7c:	00043023          	sd	zero,0(s0)
ffffffffc0202e80:	b5cd                	j	ffffffffc0202d62 <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202e82:	00004697          	auipc	a3,0x4
ffffffffc0202e86:	e3668693          	addi	a3,a3,-458 # ffffffffc0206cb8 <etext+0x113c>
ffffffffc0202e8a:	00003617          	auipc	a2,0x3
ffffffffc0202e8e:	76660613          	addi	a2,a2,1894 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0202e92:	13700593          	li	a1,311
ffffffffc0202e96:	00004517          	auipc	a0,0x4
ffffffffc0202e9a:	e1250513          	addi	a0,a0,-494 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202e9e:	b8efd0ef          	jal	ffffffffc020022c <__panic>
    return KADDR(page2pa(page));
ffffffffc0202ea2:	00003617          	auipc	a2,0x3
ffffffffc0202ea6:	6d660613          	addi	a2,a2,1750 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0202eaa:	07100593          	li	a1,113
ffffffffc0202eae:	00003517          	auipc	a0,0x3
ffffffffc0202eb2:	6aa50513          	addi	a0,a0,1706 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0202eb6:	b76fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202eba:	86f2                	mv	a3,t3
ffffffffc0202ebc:	00003617          	auipc	a2,0x3
ffffffffc0202ec0:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0202ec4:	07100593          	li	a1,113
ffffffffc0202ec8:	00003517          	auipc	a0,0x3
ffffffffc0202ecc:	69050513          	addi	a0,a0,1680 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0202ed0:	b5cfd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202ed4:	8c7ff0ef          	jal	ffffffffc020279a <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202ed8:	00004697          	auipc	a3,0x4
ffffffffc0202edc:	e1068693          	addi	a3,a3,-496 # ffffffffc0206ce8 <etext+0x116c>
ffffffffc0202ee0:	00003617          	auipc	a2,0x3
ffffffffc0202ee4:	71060613          	addi	a2,a2,1808 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0202ee8:	13800593          	li	a1,312
ffffffffc0202eec:	00004517          	auipc	a0,0x4
ffffffffc0202ef0:	dbc50513          	addi	a0,a0,-580 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0202ef4:	b38fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0202ef8 <page_remove>:
{
ffffffffc0202ef8:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202efa:	4601                	li	a2,0
{
ffffffffc0202efc:	e822                	sd	s0,16(sp)
ffffffffc0202efe:	ec06                	sd	ra,24(sp)
ffffffffc0202f00:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202f02:	95dff0ef          	jal	ffffffffc020285e <get_pte>
    if (ptep != NULL)
ffffffffc0202f06:	c511                	beqz	a0,ffffffffc0202f12 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc0202f08:	6118                	ld	a4,0(a0)
ffffffffc0202f0a:	87aa                	mv	a5,a0
ffffffffc0202f0c:	00177693          	andi	a3,a4,1
ffffffffc0202f10:	e689                	bnez	a3,ffffffffc0202f1a <page_remove+0x22>
}
ffffffffc0202f12:	60e2                	ld	ra,24(sp)
ffffffffc0202f14:	6442                	ld	s0,16(sp)
ffffffffc0202f16:	6105                	addi	sp,sp,32
ffffffffc0202f18:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202f1a:	000e2697          	auipc	a3,0xe2
ffffffffc0202f1e:	3266b683          	ld	a3,806(a3) # ffffffffc02e5240 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202f22:	070a                	slli	a4,a4,0x2
ffffffffc0202f24:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202f26:	06d77563          	bgeu	a4,a3,ffffffffc0202f90 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f2a:	000e2517          	auipc	a0,0xe2
ffffffffc0202f2e:	31e53503          	ld	a0,798(a0) # ffffffffc02e5248 <pages>
ffffffffc0202f32:	071a                	slli	a4,a4,0x6
ffffffffc0202f34:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202f38:	9736                	add	a4,a4,a3
ffffffffc0202f3a:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202f3c:	4118                	lw	a4,0(a0)
ffffffffc0202f3e:	377d                	addiw	a4,a4,-1
ffffffffc0202f40:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202f42:	cb09                	beqz	a4,ffffffffc0202f54 <page_remove+0x5c>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202f44:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202f48:	12040073          	sfence.vma	s0
}
ffffffffc0202f4c:	60e2                	ld	ra,24(sp)
ffffffffc0202f4e:	6442                	ld	s0,16(sp)
ffffffffc0202f50:	6105                	addi	sp,sp,32
ffffffffc0202f52:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202f54:	10002773          	csrr	a4,sstatus
ffffffffc0202f58:	8b09                	andi	a4,a4,2
ffffffffc0202f5a:	eb19                	bnez	a4,ffffffffc0202f70 <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc0202f5c:	000e2717          	auipc	a4,0xe2
ffffffffc0202f60:	2c473703          	ld	a4,708(a4) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202f64:	4585                	li	a1,1
ffffffffc0202f66:	e03e                	sd	a5,0(sp)
ffffffffc0202f68:	7318                	ld	a4,32(a4)
ffffffffc0202f6a:	9702                	jalr	a4
    if (flag)
ffffffffc0202f6c:	6782                	ld	a5,0(sp)
ffffffffc0202f6e:	bfd9                	j	ffffffffc0202f44 <page_remove+0x4c>
        intr_disable();
ffffffffc0202f70:	e43e                	sd	a5,8(sp)
ffffffffc0202f72:	e02a                	sd	a0,0(sp)
ffffffffc0202f74:	991fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202f78:	000e2717          	auipc	a4,0xe2
ffffffffc0202f7c:	2a873703          	ld	a4,680(a4) # ffffffffc02e5220 <pmm_manager>
ffffffffc0202f80:	6502                	ld	a0,0(sp)
ffffffffc0202f82:	4585                	li	a1,1
ffffffffc0202f84:	7318                	ld	a4,32(a4)
ffffffffc0202f86:	9702                	jalr	a4
        intr_enable();
ffffffffc0202f88:	977fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202f8c:	67a2                	ld	a5,8(sp)
ffffffffc0202f8e:	bf5d                	j	ffffffffc0202f44 <page_remove+0x4c>
ffffffffc0202f90:	80bff0ef          	jal	ffffffffc020279a <pa2page.part.0>

ffffffffc0202f94 <page_insert>:
{
ffffffffc0202f94:	7139                	addi	sp,sp,-64
ffffffffc0202f96:	f426                	sd	s1,40(sp)
ffffffffc0202f98:	84b2                	mv	s1,a2
ffffffffc0202f9a:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202f9c:	4605                	li	a2,1
{
ffffffffc0202f9e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202fa0:	85a6                	mv	a1,s1
{
ffffffffc0202fa2:	fc06                	sd	ra,56(sp)
ffffffffc0202fa4:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202fa6:	8b9ff0ef          	jal	ffffffffc020285e <get_pte>
    if (ptep == NULL)
ffffffffc0202faa:	cd61                	beqz	a0,ffffffffc0203082 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202fac:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202fae:	611c                	ld	a5,0(a0)
ffffffffc0202fb0:	66a2                	ld	a3,8(sp)
ffffffffc0202fb2:	0015861b          	addiw	a2,a1,1
ffffffffc0202fb6:	c010                	sw	a2,0(s0)
ffffffffc0202fb8:	0017f613          	andi	a2,a5,1
ffffffffc0202fbc:	872a                	mv	a4,a0
ffffffffc0202fbe:	e61d                	bnez	a2,ffffffffc0202fec <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fc0:	000e2617          	auipc	a2,0xe2
ffffffffc0202fc4:	28863603          	ld	a2,648(a2) # ffffffffc02e5248 <pages>
    return page - pages + nbase;
ffffffffc0202fc8:	8c11                	sub	s0,s0,a2
ffffffffc0202fca:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202fcc:	200007b7          	lui	a5,0x20000
ffffffffc0202fd0:	042a                	slli	s0,s0,0xa
ffffffffc0202fd2:	943e                	add	s0,s0,a5
ffffffffc0202fd4:	8ec1                	or	a3,a3,s0
ffffffffc0202fd6:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202fda:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202fdc:	12048073          	sfence.vma	s1
    return 0;
ffffffffc0202fe0:	4501                	li	a0,0
}
ffffffffc0202fe2:	70e2                	ld	ra,56(sp)
ffffffffc0202fe4:	7442                	ld	s0,48(sp)
ffffffffc0202fe6:	74a2                	ld	s1,40(sp)
ffffffffc0202fe8:	6121                	addi	sp,sp,64
ffffffffc0202fea:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202fec:	000e2617          	auipc	a2,0xe2
ffffffffc0202ff0:	25463603          	ld	a2,596(a2) # ffffffffc02e5240 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ff4:	078a                	slli	a5,a5,0x2
ffffffffc0202ff6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ff8:	08c7f763          	bgeu	a5,a2,ffffffffc0203086 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ffc:	000e2617          	auipc	a2,0xe2
ffffffffc0203000:	24c63603          	ld	a2,588(a2) # ffffffffc02e5248 <pages>
ffffffffc0203004:	fe000537          	lui	a0,0xfe000
ffffffffc0203008:	079a                	slli	a5,a5,0x6
ffffffffc020300a:	97aa                	add	a5,a5,a0
ffffffffc020300c:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc0203010:	00a40963          	beq	s0,a0,ffffffffc0203022 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc0203014:	411c                	lw	a5,0(a0)
ffffffffc0203016:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_matrix_out_size+0x1fff453f>
ffffffffc0203018:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc020301a:	c791                	beqz	a5,ffffffffc0203026 <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020301c:	12048073          	sfence.vma	s1
}
ffffffffc0203020:	b765                	j	ffffffffc0202fc8 <page_insert+0x34>
ffffffffc0203022:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc0203024:	b755                	j	ffffffffc0202fc8 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203026:	100027f3          	csrr	a5,sstatus
ffffffffc020302a:	8b89                	andi	a5,a5,2
ffffffffc020302c:	e39d                	bnez	a5,ffffffffc0203052 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc020302e:	000e2797          	auipc	a5,0xe2
ffffffffc0203032:	1f27b783          	ld	a5,498(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0203036:	4585                	li	a1,1
ffffffffc0203038:	e83a                	sd	a4,16(sp)
ffffffffc020303a:	739c                	ld	a5,32(a5)
ffffffffc020303c:	e436                	sd	a3,8(sp)
ffffffffc020303e:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203040:	000e2617          	auipc	a2,0xe2
ffffffffc0203044:	20863603          	ld	a2,520(a2) # ffffffffc02e5248 <pages>
ffffffffc0203048:	66a2                	ld	a3,8(sp)
ffffffffc020304a:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020304c:	12048073          	sfence.vma	s1
ffffffffc0203050:	bfa5                	j	ffffffffc0202fc8 <page_insert+0x34>
        intr_disable();
ffffffffc0203052:	ec3a                	sd	a4,24(sp)
ffffffffc0203054:	e836                	sd	a3,16(sp)
ffffffffc0203056:	e42a                	sd	a0,8(sp)
ffffffffc0203058:	8adfd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020305c:	000e2797          	auipc	a5,0xe2
ffffffffc0203060:	1c47b783          	ld	a5,452(a5) # ffffffffc02e5220 <pmm_manager>
ffffffffc0203064:	6522                	ld	a0,8(sp)
ffffffffc0203066:	4585                	li	a1,1
ffffffffc0203068:	739c                	ld	a5,32(a5)
ffffffffc020306a:	9782                	jalr	a5
        intr_enable();
ffffffffc020306c:	893fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203070:	000e2617          	auipc	a2,0xe2
ffffffffc0203074:	1d863603          	ld	a2,472(a2) # ffffffffc02e5248 <pages>
ffffffffc0203078:	6762                	ld	a4,24(sp)
ffffffffc020307a:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020307c:	12048073          	sfence.vma	s1
ffffffffc0203080:	b7a1                	j	ffffffffc0202fc8 <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc0203082:	5571                	li	a0,-4
ffffffffc0203084:	bfb9                	j	ffffffffc0202fe2 <page_insert+0x4e>
ffffffffc0203086:	f14ff0ef          	jal	ffffffffc020279a <pa2page.part.0>

ffffffffc020308a <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020308a:	00005797          	auipc	a5,0x5
ffffffffc020308e:	91678793          	addi	a5,a5,-1770 # ffffffffc02079a0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203092:	638c                	ld	a1,0(a5)
{
ffffffffc0203094:	7159                	addi	sp,sp,-112
ffffffffc0203096:	f486                	sd	ra,104(sp)
ffffffffc0203098:	e8ca                	sd	s2,80(sp)
ffffffffc020309a:	e4ce                	sd	s3,72(sp)
ffffffffc020309c:	f85a                	sd	s6,48(sp)
ffffffffc020309e:	f0a2                	sd	s0,96(sp)
ffffffffc02030a0:	eca6                	sd	s1,88(sp)
ffffffffc02030a2:	e0d2                	sd	s4,64(sp)
ffffffffc02030a4:	fc56                	sd	s5,56(sp)
ffffffffc02030a6:	f45e                	sd	s7,40(sp)
ffffffffc02030a8:	f062                	sd	s8,32(sp)
ffffffffc02030aa:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02030ac:	000e2b17          	auipc	s6,0xe2
ffffffffc02030b0:	174b0b13          	addi	s6,s6,372 # ffffffffc02e5220 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030b4:	00004517          	auipc	a0,0x4
ffffffffc02030b8:	c4c50513          	addi	a0,a0,-948 # ffffffffc0206d00 <etext+0x1184>
    pmm_manager = &default_pmm_manager;
ffffffffc02030bc:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030c0:	822fd0ef          	jal	ffffffffc02000e2 <cprintf>
    pmm_manager->init();
ffffffffc02030c4:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02030c8:	000e2997          	auipc	s3,0xe2
ffffffffc02030cc:	17098993          	addi	s3,s3,368 # ffffffffc02e5238 <va_pa_offset>
    pmm_manager->init();
ffffffffc02030d0:	679c                	ld	a5,8(a5)
ffffffffc02030d2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02030d4:	57f5                	li	a5,-3
ffffffffc02030d6:	07fa                	slli	a5,a5,0x1e
ffffffffc02030d8:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02030dc:	f50fd0ef          	jal	ffffffffc020082c <get_memory_base>
ffffffffc02030e0:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02030e2:	f54fd0ef          	jal	ffffffffc0200836 <get_memory_size>
    if (mem_size == 0)
ffffffffc02030e6:	70050e63          	beqz	a0,ffffffffc0203802 <pmm_init+0x778>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02030ea:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02030ec:	00004517          	auipc	a0,0x4
ffffffffc02030f0:	c4c50513          	addi	a0,a0,-948 # ffffffffc0206d38 <etext+0x11bc>
ffffffffc02030f4:	feffc0ef          	jal	ffffffffc02000e2 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02030f8:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02030fc:	864a                	mv	a2,s2
ffffffffc02030fe:	85a6                	mv	a1,s1
ffffffffc0203100:	fff40693          	addi	a3,s0,-1
ffffffffc0203104:	00004517          	auipc	a0,0x4
ffffffffc0203108:	c4c50513          	addi	a0,a0,-948 # ffffffffc0206d50 <etext+0x11d4>
ffffffffc020310c:	fd7fc0ef          	jal	ffffffffc02000e2 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc0203110:	c80007b7          	lui	a5,0xc8000
ffffffffc0203114:	8522                	mv	a0,s0
ffffffffc0203116:	5287ed63          	bltu	a5,s0,ffffffffc0203650 <pmm_init+0x5c6>
ffffffffc020311a:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020311c:	000e3617          	auipc	a2,0xe3
ffffffffc0203120:	16360613          	addi	a2,a2,355 # ffffffffc02e627f <end+0xfff>
ffffffffc0203124:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc0203126:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203128:	000e2b97          	auipc	s7,0xe2
ffffffffc020312c:	120b8b93          	addi	s7,s7,288 # ffffffffc02e5248 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203130:	000e2497          	auipc	s1,0xe2
ffffffffc0203134:	11048493          	addi	s1,s1,272 # ffffffffc02e5240 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203138:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc020313c:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020313e:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203142:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203144:	02f50763          	beq	a0,a5,ffffffffc0203172 <pmm_init+0xe8>
ffffffffc0203148:	4701                	li	a4,0
ffffffffc020314a:	4585                	li	a1,1
ffffffffc020314c:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0203150:	00671793          	slli	a5,a4,0x6
ffffffffc0203154:	97b2                	add	a5,a5,a2
ffffffffc0203156:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_matrix_out_size+0x74548>
ffffffffc0203158:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020315c:	6088                	ld	a0,0(s1)
ffffffffc020315e:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203160:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203164:	00d507b3          	add	a5,a0,a3
ffffffffc0203168:	fef764e3          	bltu	a4,a5,ffffffffc0203150 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020316c:	079a                	slli	a5,a5,0x6
ffffffffc020316e:	00f606b3          	add	a3,a2,a5
ffffffffc0203172:	c02007b7          	lui	a5,0xc0200
ffffffffc0203176:	16f6eee3          	bltu	a3,a5,ffffffffc0203af2 <pmm_init+0xa68>
ffffffffc020317a:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020317e:	77fd                	lui	a5,0xfffff
ffffffffc0203180:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203182:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0203184:	4e86ed63          	bltu	a3,s0,ffffffffc020367e <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0203188:	00004517          	auipc	a0,0x4
ffffffffc020318c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0206d78 <etext+0x11fc>
ffffffffc0203190:	f53fc0ef          	jal	ffffffffc02000e2 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0203194:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0203198:	000e2917          	auipc	s2,0xe2
ffffffffc020319c:	09890913          	addi	s2,s2,152 # ffffffffc02e5230 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02031a0:	7b9c                	ld	a5,48(a5)
ffffffffc02031a2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02031a4:	00004517          	auipc	a0,0x4
ffffffffc02031a8:	bec50513          	addi	a0,a0,-1044 # ffffffffc0206d90 <etext+0x1214>
ffffffffc02031ac:	f37fc0ef          	jal	ffffffffc02000e2 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02031b0:	00008697          	auipc	a3,0x8
ffffffffc02031b4:	e5068693          	addi	a3,a3,-432 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02031b8:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02031bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02031c0:	2af6eee3          	bltu	a3,a5,ffffffffc0203c7c <pmm_init+0xbf2>
ffffffffc02031c4:	0009b783          	ld	a5,0(s3)
ffffffffc02031c8:	8e9d                	sub	a3,a3,a5
ffffffffc02031ca:	000e2797          	auipc	a5,0xe2
ffffffffc02031ce:	04d7bf23          	sd	a3,94(a5) # ffffffffc02e5228 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02031d2:	100027f3          	csrr	a5,sstatus
ffffffffc02031d6:	8b89                	andi	a5,a5,2
ffffffffc02031d8:	48079963          	bnez	a5,ffffffffc020366a <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02031dc:	000b3783          	ld	a5,0(s6)
ffffffffc02031e0:	779c                	ld	a5,40(a5)
ffffffffc02031e2:	9782                	jalr	a5
ffffffffc02031e4:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031e6:	6098                	ld	a4,0(s1)
ffffffffc02031e8:	c80007b7          	lui	a5,0xc8000
ffffffffc02031ec:	83b1                	srli	a5,a5,0xc
ffffffffc02031ee:	66e7e663          	bltu	a5,a4,ffffffffc020385a <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02031f2:	00093503          	ld	a0,0(s2)
ffffffffc02031f6:	64050263          	beqz	a0,ffffffffc020383a <pmm_init+0x7b0>
ffffffffc02031fa:	03451793          	slli	a5,a0,0x34
ffffffffc02031fe:	62079e63          	bnez	a5,ffffffffc020383a <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203202:	4601                	li	a2,0
ffffffffc0203204:	4581                	li	a1,0
ffffffffc0203206:	8b7ff0ef          	jal	ffffffffc0202abc <get_page>
ffffffffc020320a:	240519e3          	bnez	a0,ffffffffc0203c5c <pmm_init+0xbd2>
ffffffffc020320e:	100027f3          	csrr	a5,sstatus
ffffffffc0203212:	8b89                	andi	a5,a5,2
ffffffffc0203214:	44079063          	bnez	a5,ffffffffc0203654 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203218:	000b3783          	ld	a5,0(s6)
ffffffffc020321c:	4505                	li	a0,1
ffffffffc020321e:	6f9c                	ld	a5,24(a5)
ffffffffc0203220:	9782                	jalr	a5
ffffffffc0203222:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203224:	00093503          	ld	a0,0(s2)
ffffffffc0203228:	4681                	li	a3,0
ffffffffc020322a:	4601                	li	a2,0
ffffffffc020322c:	85d2                	mv	a1,s4
ffffffffc020322e:	d67ff0ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc0203232:	280511e3          	bnez	a0,ffffffffc0203cb4 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203236:	00093503          	ld	a0,0(s2)
ffffffffc020323a:	4601                	li	a2,0
ffffffffc020323c:	4581                	li	a1,0
ffffffffc020323e:	e20ff0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc0203242:	240509e3          	beqz	a0,ffffffffc0203c94 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc0203246:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0203248:	0017f713          	andi	a4,a5,1
ffffffffc020324c:	58070f63          	beqz	a4,ffffffffc02037ea <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0203250:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203252:	078a                	slli	a5,a5,0x2
ffffffffc0203254:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203256:	58e7f863          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc020325a:	000bb683          	ld	a3,0(s7)
ffffffffc020325e:	079a                	slli	a5,a5,0x6
ffffffffc0203260:	fe000637          	lui	a2,0xfe000
ffffffffc0203264:	97b2                	add	a5,a5,a2
ffffffffc0203266:	97b6                	add	a5,a5,a3
ffffffffc0203268:	14fa1ae3          	bne	s4,a5,ffffffffc0203bbc <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc020326c:	000a2683          	lw	a3,0(s4) # 200000 <_binary_obj___user_matrix_out_size+0x1f4540>
ffffffffc0203270:	4785                	li	a5,1
ffffffffc0203272:	12f695e3          	bne	a3,a5,ffffffffc0203b9c <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203276:	00093503          	ld	a0,0(s2)
ffffffffc020327a:	77fd                	lui	a5,0xfffff
ffffffffc020327c:	6114                	ld	a3,0(a0)
ffffffffc020327e:	068a                	slli	a3,a3,0x2
ffffffffc0203280:	8efd                	and	a3,a3,a5
ffffffffc0203282:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203286:	0ee67fe3          	bgeu	a2,a4,ffffffffc0203b84 <pmm_init+0xafa>
ffffffffc020328a:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020328e:	96e2                	add	a3,a3,s8
ffffffffc0203290:	0006ba83          	ld	s5,0(a3)
ffffffffc0203294:	0a8a                	slli	s5,s5,0x2
ffffffffc0203296:	00fafab3          	and	s5,s5,a5
ffffffffc020329a:	00cad793          	srli	a5,s5,0xc
ffffffffc020329e:	0ce7f6e3          	bgeu	a5,a4,ffffffffc0203b6a <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032a2:	4601                	li	a2,0
ffffffffc02032a4:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032a6:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032a8:	db6ff0ef          	jal	ffffffffc020285e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032ac:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032ae:	05851ee3          	bne	a0,s8,ffffffffc0203b0a <pmm_init+0xa80>
ffffffffc02032b2:	100027f3          	csrr	a5,sstatus
ffffffffc02032b6:	8b89                	andi	a5,a5,2
ffffffffc02032b8:	3e079b63          	bnez	a5,ffffffffc02036ae <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc02032bc:	000b3783          	ld	a5,0(s6)
ffffffffc02032c0:	4505                	li	a0,1
ffffffffc02032c2:	6f9c                	ld	a5,24(a5)
ffffffffc02032c4:	9782                	jalr	a5
ffffffffc02032c6:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032c8:	00093503          	ld	a0,0(s2)
ffffffffc02032cc:	46d1                	li	a3,20
ffffffffc02032ce:	6605                	lui	a2,0x1
ffffffffc02032d0:	85e2                	mv	a1,s8
ffffffffc02032d2:	cc3ff0ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc02032d6:	06051ae3          	bnez	a0,ffffffffc0203b4a <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032da:	00093503          	ld	a0,0(s2)
ffffffffc02032de:	4601                	li	a2,0
ffffffffc02032e0:	6585                	lui	a1,0x1
ffffffffc02032e2:	d7cff0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc02032e6:	040502e3          	beqz	a0,ffffffffc0203b2a <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc02032ea:	611c                	ld	a5,0(a0)
ffffffffc02032ec:	0107f713          	andi	a4,a5,16
ffffffffc02032f0:	7e070163          	beqz	a4,ffffffffc0203ad2 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc02032f4:	8b91                	andi	a5,a5,4
ffffffffc02032f6:	7a078e63          	beqz	a5,ffffffffc0203ab2 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02032fa:	00093503          	ld	a0,0(s2)
ffffffffc02032fe:	611c                	ld	a5,0(a0)
ffffffffc0203300:	8bc1                	andi	a5,a5,16
ffffffffc0203302:	78078863          	beqz	a5,ffffffffc0203a92 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0203306:	000c2703          	lw	a4,0(s8)
ffffffffc020330a:	4785                	li	a5,1
ffffffffc020330c:	76f71363          	bne	a4,a5,ffffffffc0203a72 <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203310:	4681                	li	a3,0
ffffffffc0203312:	6605                	lui	a2,0x1
ffffffffc0203314:	85d2                	mv	a1,s4
ffffffffc0203316:	c7fff0ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc020331a:	72051c63          	bnez	a0,ffffffffc0203a52 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc020331e:	000a2703          	lw	a4,0(s4)
ffffffffc0203322:	4789                	li	a5,2
ffffffffc0203324:	70f71763          	bne	a4,a5,ffffffffc0203a32 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0203328:	000c2783          	lw	a5,0(s8)
ffffffffc020332c:	6e079363          	bnez	a5,ffffffffc0203a12 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203330:	00093503          	ld	a0,0(s2)
ffffffffc0203334:	4601                	li	a2,0
ffffffffc0203336:	6585                	lui	a1,0x1
ffffffffc0203338:	d26ff0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc020333c:	6a050b63          	beqz	a0,ffffffffc02039f2 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0203340:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0203342:	00177793          	andi	a5,a4,1
ffffffffc0203346:	4a078263          	beqz	a5,ffffffffc02037ea <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc020334a:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020334c:	00271793          	slli	a5,a4,0x2
ffffffffc0203350:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203352:	48d7fa63          	bgeu	a5,a3,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203356:	000bb683          	ld	a3,0(s7)
ffffffffc020335a:	fff80ab7          	lui	s5,0xfff80
ffffffffc020335e:	97d6                	add	a5,a5,s5
ffffffffc0203360:	079a                	slli	a5,a5,0x6
ffffffffc0203362:	97b6                	add	a5,a5,a3
ffffffffc0203364:	66fa1763          	bne	s4,a5,ffffffffc02039d2 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203368:	8b41                	andi	a4,a4,16
ffffffffc020336a:	64071463          	bnez	a4,ffffffffc02039b2 <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc020336e:	00093503          	ld	a0,0(s2)
ffffffffc0203372:	4581                	li	a1,0
ffffffffc0203374:	b85ff0ef          	jal	ffffffffc0202ef8 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0203378:	000a2c83          	lw	s9,0(s4)
ffffffffc020337c:	4785                	li	a5,1
ffffffffc020337e:	60fc9a63          	bne	s9,a5,ffffffffc0203992 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0203382:	000c2783          	lw	a5,0(s8)
ffffffffc0203386:	5e079663          	bnez	a5,ffffffffc0203972 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc020338a:	00093503          	ld	a0,0(s2)
ffffffffc020338e:	6585                	lui	a1,0x1
ffffffffc0203390:	b69ff0ef          	jal	ffffffffc0202ef8 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203394:	000a2783          	lw	a5,0(s4)
ffffffffc0203398:	52079d63          	bnez	a5,ffffffffc02038d2 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc020339c:	000c2783          	lw	a5,0(s8)
ffffffffc02033a0:	50079963          	bnez	a5,ffffffffc02038b2 <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02033a4:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc02033a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033aa:	000a3783          	ld	a5,0(s4)
ffffffffc02033ae:	078a                	slli	a5,a5,0x2
ffffffffc02033b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033b2:	42e7fa63          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02033b6:	000bb503          	ld	a0,0(s7)
ffffffffc02033ba:	97d6                	add	a5,a5,s5
ffffffffc02033bc:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc02033be:	00f506b3          	add	a3,a0,a5
ffffffffc02033c2:	4294                	lw	a3,0(a3)
ffffffffc02033c4:	4d969763          	bne	a3,s9,ffffffffc0203892 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc02033c8:	8799                	srai	a5,a5,0x6
ffffffffc02033ca:	00080637          	lui	a2,0x80
ffffffffc02033ce:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02033d0:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02033d4:	4ae7f363          	bgeu	a5,a4,ffffffffc020387a <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02033d8:	0009b783          	ld	a5,0(s3)
ffffffffc02033dc:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02033de:	639c                	ld	a5,0(a5)
ffffffffc02033e0:	078a                	slli	a5,a5,0x2
ffffffffc02033e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033e4:	40e7f163          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02033e8:	8f91                	sub	a5,a5,a2
ffffffffc02033ea:	079a                	slli	a5,a5,0x6
ffffffffc02033ec:	953e                	add	a0,a0,a5
ffffffffc02033ee:	100027f3          	csrr	a5,sstatus
ffffffffc02033f2:	8b89                	andi	a5,a5,2
ffffffffc02033f4:	30079863          	bnez	a5,ffffffffc0203704 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc02033f8:	000b3783          	ld	a5,0(s6)
ffffffffc02033fc:	4585                	li	a1,1
ffffffffc02033fe:	739c                	ld	a5,32(a5)
ffffffffc0203400:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203402:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0203406:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203408:	078a                	slli	a5,a5,0x2
ffffffffc020340a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020340c:	3ce7fd63          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203410:	000bb503          	ld	a0,0(s7)
ffffffffc0203414:	fe000737          	lui	a4,0xfe000
ffffffffc0203418:	079a                	slli	a5,a5,0x6
ffffffffc020341a:	97ba                	add	a5,a5,a4
ffffffffc020341c:	953e                	add	a0,a0,a5
ffffffffc020341e:	100027f3          	csrr	a5,sstatus
ffffffffc0203422:	8b89                	andi	a5,a5,2
ffffffffc0203424:	2c079463          	bnez	a5,ffffffffc02036ec <pmm_init+0x662>
ffffffffc0203428:	000b3783          	ld	a5,0(s6)
ffffffffc020342c:	4585                	li	a1,1
ffffffffc020342e:	739c                	ld	a5,32(a5)
ffffffffc0203430:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0203432:	00093783          	ld	a5,0(s2)
ffffffffc0203436:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd19d80>
    asm volatile("sfence.vma");
ffffffffc020343a:	12000073          	sfence.vma
ffffffffc020343e:	100027f3          	csrr	a5,sstatus
ffffffffc0203442:	8b89                	andi	a5,a5,2
ffffffffc0203444:	28079a63          	bnez	a5,ffffffffc02036d8 <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203448:	000b3783          	ld	a5,0(s6)
ffffffffc020344c:	779c                	ld	a5,40(a5)
ffffffffc020344e:	9782                	jalr	a5
ffffffffc0203450:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203452:	4d441063          	bne	s0,s4,ffffffffc0203912 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203456:	00004517          	auipc	a0,0x4
ffffffffc020345a:	c8a50513          	addi	a0,a0,-886 # ffffffffc02070e0 <etext+0x1564>
ffffffffc020345e:	c85fc0ef          	jal	ffffffffc02000e2 <cprintf>
ffffffffc0203462:	100027f3          	csrr	a5,sstatus
ffffffffc0203466:	8b89                	andi	a5,a5,2
ffffffffc0203468:	24079e63          	bnez	a5,ffffffffc02036c4 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc020346c:	000b3783          	ld	a5,0(s6)
ffffffffc0203470:	779c                	ld	a5,40(a5)
ffffffffc0203472:	9782                	jalr	a5
ffffffffc0203474:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0203476:	609c                	ld	a5,0(s1)
ffffffffc0203478:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020347c:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020347e:	00c79713          	slli	a4,a5,0xc
ffffffffc0203482:	6a85                	lui	s5,0x1
ffffffffc0203484:	02e47c63          	bgeu	s0,a4,ffffffffc02034bc <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203488:	00c45713          	srli	a4,s0,0xc
ffffffffc020348c:	30f77063          	bgeu	a4,a5,ffffffffc020378c <pmm_init+0x702>
ffffffffc0203490:	0009b583          	ld	a1,0(s3)
ffffffffc0203494:	00093503          	ld	a0,0(s2)
ffffffffc0203498:	4601                	li	a2,0
ffffffffc020349a:	95a2                	add	a1,a1,s0
ffffffffc020349c:	bc2ff0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc02034a0:	32050363          	beqz	a0,ffffffffc02037c6 <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02034a4:	611c                	ld	a5,0(a0)
ffffffffc02034a6:	078a                	slli	a5,a5,0x2
ffffffffc02034a8:	0147f7b3          	and	a5,a5,s4
ffffffffc02034ac:	2e879d63          	bne	a5,s0,ffffffffc02037a6 <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02034b0:	609c                	ld	a5,0(s1)
ffffffffc02034b2:	9456                	add	s0,s0,s5
ffffffffc02034b4:	00c79713          	slli	a4,a5,0xc
ffffffffc02034b8:	fce468e3          	bltu	s0,a4,ffffffffc0203488 <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc02034bc:	00093783          	ld	a5,0(s2)
ffffffffc02034c0:	639c                	ld	a5,0(a5)
ffffffffc02034c2:	42079863          	bnez	a5,ffffffffc02038f2 <pmm_init+0x868>
ffffffffc02034c6:	100027f3          	csrr	a5,sstatus
ffffffffc02034ca:	8b89                	andi	a5,a5,2
ffffffffc02034cc:	24079863          	bnez	a5,ffffffffc020371c <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034d0:	000b3783          	ld	a5,0(s6)
ffffffffc02034d4:	4505                	li	a0,1
ffffffffc02034d6:	6f9c                	ld	a5,24(a5)
ffffffffc02034d8:	9782                	jalr	a5
ffffffffc02034da:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02034dc:	00093503          	ld	a0,0(s2)
ffffffffc02034e0:	4699                	li	a3,6
ffffffffc02034e2:	10000613          	li	a2,256
ffffffffc02034e6:	85a2                	mv	a1,s0
ffffffffc02034e8:	aadff0ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc02034ec:	46051363          	bnez	a0,ffffffffc0203952 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc02034f0:	4018                	lw	a4,0(s0)
ffffffffc02034f2:	4785                	li	a5,1
ffffffffc02034f4:	42f71f63          	bne	a4,a5,ffffffffc0203932 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02034f8:	00093503          	ld	a0,0(s2)
ffffffffc02034fc:	6605                	lui	a2,0x1
ffffffffc02034fe:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x83b0>
ffffffffc0203502:	4699                	li	a3,6
ffffffffc0203504:	85a2                	mv	a1,s0
ffffffffc0203506:	a8fff0ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc020350a:	72051963          	bnez	a0,ffffffffc0203c3c <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc020350e:	4018                	lw	a4,0(s0)
ffffffffc0203510:	4789                	li	a5,2
ffffffffc0203512:	70f71563          	bne	a4,a5,ffffffffc0203c1c <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0203516:	00004597          	auipc	a1,0x4
ffffffffc020351a:	d1258593          	addi	a1,a1,-750 # ffffffffc0207228 <etext+0x16ac>
ffffffffc020351e:	10000513          	li	a0,256
ffffffffc0203522:	1ce020ef          	jal	ffffffffc02056f0 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203526:	6585                	lui	a1,0x1
ffffffffc0203528:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x83b0>
ffffffffc020352c:	10000513          	li	a0,256
ffffffffc0203530:	1d2020ef          	jal	ffffffffc0205702 <strcmp>
ffffffffc0203534:	6c051463          	bnez	a0,ffffffffc0203bfc <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0203538:	000bb683          	ld	a3,0(s7)
ffffffffc020353c:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0203540:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0203542:	40d406b3          	sub	a3,s0,a3
ffffffffc0203546:	8699                	srai	a3,a3,0x6
ffffffffc0203548:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020354a:	00c69793          	slli	a5,a3,0xc
ffffffffc020354e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203550:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203552:	32e7f463          	bgeu	a5,a4,ffffffffc020387a <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203556:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020355a:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020355e:	97b6                	add	a5,a5,a3
ffffffffc0203560:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_matrix_out_size+0x74640>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203564:	158020ef          	jal	ffffffffc02056bc <strlen>
ffffffffc0203568:	66051a63          	bnez	a0,ffffffffc0203bdc <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc020356c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0203570:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203572:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd19d80>
ffffffffc0203576:	078a                	slli	a5,a5,0x2
ffffffffc0203578:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020357a:	26e7f663          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc020357e:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203582:	2ee7fc63          	bgeu	a5,a4,ffffffffc020387a <pmm_init+0x7f0>
ffffffffc0203586:	0009b783          	ld	a5,0(s3)
ffffffffc020358a:	00f689b3          	add	s3,a3,a5
ffffffffc020358e:	100027f3          	csrr	a5,sstatus
ffffffffc0203592:	8b89                	andi	a5,a5,2
ffffffffc0203594:	1e079163          	bnez	a5,ffffffffc0203776 <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0203598:	000b3783          	ld	a5,0(s6)
ffffffffc020359c:	8522                	mv	a0,s0
ffffffffc020359e:	4585                	li	a1,1
ffffffffc02035a0:	739c                	ld	a5,32(a5)
ffffffffc02035a2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035a4:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc02035a8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035aa:	078a                	slli	a5,a5,0x2
ffffffffc02035ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035ae:	22e7fc63          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02035b2:	000bb503          	ld	a0,0(s7)
ffffffffc02035b6:	fe000737          	lui	a4,0xfe000
ffffffffc02035ba:	079a                	slli	a5,a5,0x6
ffffffffc02035bc:	97ba                	add	a5,a5,a4
ffffffffc02035be:	953e                	add	a0,a0,a5
ffffffffc02035c0:	100027f3          	csrr	a5,sstatus
ffffffffc02035c4:	8b89                	andi	a5,a5,2
ffffffffc02035c6:	18079c63          	bnez	a5,ffffffffc020375e <pmm_init+0x6d4>
ffffffffc02035ca:	000b3783          	ld	a5,0(s6)
ffffffffc02035ce:	4585                	li	a1,1
ffffffffc02035d0:	739c                	ld	a5,32(a5)
ffffffffc02035d2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035d4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02035d8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035da:	078a                	slli	a5,a5,0x2
ffffffffc02035dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035de:	20e7f463          	bgeu	a5,a4,ffffffffc02037e6 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02035e2:	000bb503          	ld	a0,0(s7)
ffffffffc02035e6:	fe000737          	lui	a4,0xfe000
ffffffffc02035ea:	079a                	slli	a5,a5,0x6
ffffffffc02035ec:	97ba                	add	a5,a5,a4
ffffffffc02035ee:	953e                	add	a0,a0,a5
ffffffffc02035f0:	100027f3          	csrr	a5,sstatus
ffffffffc02035f4:	8b89                	andi	a5,a5,2
ffffffffc02035f6:	14079863          	bnez	a5,ffffffffc0203746 <pmm_init+0x6bc>
ffffffffc02035fa:	000b3783          	ld	a5,0(s6)
ffffffffc02035fe:	4585                	li	a1,1
ffffffffc0203600:	739c                	ld	a5,32(a5)
ffffffffc0203602:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0203604:	00093783          	ld	a5,0(s2)
ffffffffc0203608:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc020360c:	12000073          	sfence.vma
ffffffffc0203610:	100027f3          	csrr	a5,sstatus
ffffffffc0203614:	8b89                	andi	a5,a5,2
ffffffffc0203616:	10079e63          	bnez	a5,ffffffffc0203732 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020361a:	000b3783          	ld	a5,0(s6)
ffffffffc020361e:	779c                	ld	a5,40(a5)
ffffffffc0203620:	9782                	jalr	a5
ffffffffc0203622:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203624:	1e8c1b63          	bne	s8,s0,ffffffffc020381a <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203628:	00004517          	auipc	a0,0x4
ffffffffc020362c:	c7850513          	addi	a0,a0,-904 # ffffffffc02072a0 <etext+0x1724>
ffffffffc0203630:	ab3fc0ef          	jal	ffffffffc02000e2 <cprintf>
}
ffffffffc0203634:	7406                	ld	s0,96(sp)
ffffffffc0203636:	70a6                	ld	ra,104(sp)
ffffffffc0203638:	64e6                	ld	s1,88(sp)
ffffffffc020363a:	6946                	ld	s2,80(sp)
ffffffffc020363c:	69a6                	ld	s3,72(sp)
ffffffffc020363e:	6a06                	ld	s4,64(sp)
ffffffffc0203640:	7ae2                	ld	s5,56(sp)
ffffffffc0203642:	7b42                	ld	s6,48(sp)
ffffffffc0203644:	7ba2                	ld	s7,40(sp)
ffffffffc0203646:	7c02                	ld	s8,32(sp)
ffffffffc0203648:	6ce2                	ld	s9,24(sp)
ffffffffc020364a:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc020364c:	c9afe06f          	j	ffffffffc0201ae6 <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0203650:	853e                	mv	a0,a5
ffffffffc0203652:	b4e1                	j	ffffffffc020311a <pmm_init+0x90>
        intr_disable();
ffffffffc0203654:	ab0fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203658:	000b3783          	ld	a5,0(s6)
ffffffffc020365c:	4505                	li	a0,1
ffffffffc020365e:	6f9c                	ld	a5,24(a5)
ffffffffc0203660:	9782                	jalr	a5
ffffffffc0203662:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203664:	a9afd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203668:	be75                	j	ffffffffc0203224 <pmm_init+0x19a>
        intr_disable();
ffffffffc020366a:	a9afd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020366e:	000b3783          	ld	a5,0(s6)
ffffffffc0203672:	779c                	ld	a5,40(a5)
ffffffffc0203674:	9782                	jalr	a5
ffffffffc0203676:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203678:	a86fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020367c:	b6ad                	j	ffffffffc02031e6 <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020367e:	6705                	lui	a4,0x1
ffffffffc0203680:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x84b1>
ffffffffc0203682:	96ba                	add	a3,a3,a4
ffffffffc0203684:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0203686:	00c7d713          	srli	a4,a5,0xc
ffffffffc020368a:	14a77e63          	bgeu	a4,a0,ffffffffc02037e6 <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc020368e:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203692:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0203694:	071a                	slli	a4,a4,0x6
ffffffffc0203696:	fe0007b7          	lui	a5,0xfe000
ffffffffc020369a:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc020369c:	6a9c                	ld	a5,16(a3)
ffffffffc020369e:	00c45593          	srli	a1,s0,0xc
ffffffffc02036a2:	00e60533          	add	a0,a2,a4
ffffffffc02036a6:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02036a8:	0009b583          	ld	a1,0(s3)
}
ffffffffc02036ac:	bcf1                	j	ffffffffc0203188 <pmm_init+0xfe>
        intr_disable();
ffffffffc02036ae:	a56fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02036b2:	000b3783          	ld	a5,0(s6)
ffffffffc02036b6:	4505                	li	a0,1
ffffffffc02036b8:	6f9c                	ld	a5,24(a5)
ffffffffc02036ba:	9782                	jalr	a5
ffffffffc02036bc:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02036be:	a40fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02036c2:	b119                	j	ffffffffc02032c8 <pmm_init+0x23e>
        intr_disable();
ffffffffc02036c4:	a40fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02036c8:	000b3783          	ld	a5,0(s6)
ffffffffc02036cc:	779c                	ld	a5,40(a5)
ffffffffc02036ce:	9782                	jalr	a5
ffffffffc02036d0:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02036d2:	a2cfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02036d6:	b345                	j	ffffffffc0203476 <pmm_init+0x3ec>
        intr_disable();
ffffffffc02036d8:	a2cfd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02036dc:	000b3783          	ld	a5,0(s6)
ffffffffc02036e0:	779c                	ld	a5,40(a5)
ffffffffc02036e2:	9782                	jalr	a5
ffffffffc02036e4:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02036e6:	a18fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02036ea:	b3a5                	j	ffffffffc0203452 <pmm_init+0x3c8>
ffffffffc02036ec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02036ee:	a16fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02036f2:	000b3783          	ld	a5,0(s6)
ffffffffc02036f6:	6522                	ld	a0,8(sp)
ffffffffc02036f8:	4585                	li	a1,1
ffffffffc02036fa:	739c                	ld	a5,32(a5)
ffffffffc02036fc:	9782                	jalr	a5
        intr_enable();
ffffffffc02036fe:	a00fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203702:	bb05                	j	ffffffffc0203432 <pmm_init+0x3a8>
ffffffffc0203704:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203706:	9fefd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc020370a:	000b3783          	ld	a5,0(s6)
ffffffffc020370e:	6522                	ld	a0,8(sp)
ffffffffc0203710:	4585                	li	a1,1
ffffffffc0203712:	739c                	ld	a5,32(a5)
ffffffffc0203714:	9782                	jalr	a5
        intr_enable();
ffffffffc0203716:	9e8fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020371a:	b1e5                	j	ffffffffc0203402 <pmm_init+0x378>
        intr_disable();
ffffffffc020371c:	9e8fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203720:	000b3783          	ld	a5,0(s6)
ffffffffc0203724:	4505                	li	a0,1
ffffffffc0203726:	6f9c                	ld	a5,24(a5)
ffffffffc0203728:	9782                	jalr	a5
ffffffffc020372a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020372c:	9d2fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203730:	b375                	j	ffffffffc02034dc <pmm_init+0x452>
        intr_disable();
ffffffffc0203732:	9d2fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203736:	000b3783          	ld	a5,0(s6)
ffffffffc020373a:	779c                	ld	a5,40(a5)
ffffffffc020373c:	9782                	jalr	a5
ffffffffc020373e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203740:	9befd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203744:	b5c5                	j	ffffffffc0203624 <pmm_init+0x59a>
ffffffffc0203746:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203748:	9bcfd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020374c:	000b3783          	ld	a5,0(s6)
ffffffffc0203750:	6522                	ld	a0,8(sp)
ffffffffc0203752:	4585                	li	a1,1
ffffffffc0203754:	739c                	ld	a5,32(a5)
ffffffffc0203756:	9782                	jalr	a5
        intr_enable();
ffffffffc0203758:	9a6fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020375c:	b565                	j	ffffffffc0203604 <pmm_init+0x57a>
ffffffffc020375e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203760:	9a4fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0203764:	000b3783          	ld	a5,0(s6)
ffffffffc0203768:	6522                	ld	a0,8(sp)
ffffffffc020376a:	4585                	li	a1,1
ffffffffc020376c:	739c                	ld	a5,32(a5)
ffffffffc020376e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203770:	98efd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203774:	b585                	j	ffffffffc02035d4 <pmm_init+0x54a>
        intr_disable();
ffffffffc0203776:	98efd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc020377a:	000b3783          	ld	a5,0(s6)
ffffffffc020377e:	8522                	mv	a0,s0
ffffffffc0203780:	4585                	li	a1,1
ffffffffc0203782:	739c                	ld	a5,32(a5)
ffffffffc0203784:	9782                	jalr	a5
        intr_enable();
ffffffffc0203786:	978fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020378a:	bd29                	j	ffffffffc02035a4 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020378c:	86a2                	mv	a3,s0
ffffffffc020378e:	00003617          	auipc	a2,0x3
ffffffffc0203792:	dea60613          	addi	a2,a2,-534 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0203796:	23e00593          	li	a1,574
ffffffffc020379a:	00003517          	auipc	a0,0x3
ffffffffc020379e:	50e50513          	addi	a0,a0,1294 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02037a2:	a8bfc0ef          	jal	ffffffffc020022c <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02037a6:	00004697          	auipc	a3,0x4
ffffffffc02037aa:	99a68693          	addi	a3,a3,-1638 # ffffffffc0207140 <etext+0x15c4>
ffffffffc02037ae:	00003617          	auipc	a2,0x3
ffffffffc02037b2:	e4260613          	addi	a2,a2,-446 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02037b6:	23f00593          	li	a1,575
ffffffffc02037ba:	00003517          	auipc	a0,0x3
ffffffffc02037be:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02037c2:	a6bfc0ef          	jal	ffffffffc020022c <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02037c6:	00004697          	auipc	a3,0x4
ffffffffc02037ca:	93a68693          	addi	a3,a3,-1734 # ffffffffc0207100 <etext+0x1584>
ffffffffc02037ce:	00003617          	auipc	a2,0x3
ffffffffc02037d2:	e2260613          	addi	a2,a2,-478 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02037d6:	23e00593          	li	a1,574
ffffffffc02037da:	00003517          	auipc	a0,0x3
ffffffffc02037de:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02037e2:	a4bfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02037e6:	fb5fe0ef          	jal	ffffffffc020279a <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc02037ea:	00003617          	auipc	a2,0x3
ffffffffc02037ee:	6b660613          	addi	a2,a2,1718 # ffffffffc0206ea0 <etext+0x1324>
ffffffffc02037f2:	07f00593          	li	a1,127
ffffffffc02037f6:	00003517          	auipc	a0,0x3
ffffffffc02037fa:	d6250513          	addi	a0,a0,-670 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02037fe:	a2ffc0ef          	jal	ffffffffc020022c <__panic>
        panic("DTB memory info not available");
ffffffffc0203802:	00003617          	auipc	a2,0x3
ffffffffc0203806:	51660613          	addi	a2,a2,1302 # ffffffffc0206d18 <etext+0x119c>
ffffffffc020380a:	06500593          	li	a1,101
ffffffffc020380e:	00003517          	auipc	a0,0x3
ffffffffc0203812:	49a50513          	addi	a0,a0,1178 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203816:	a17fc0ef          	jal	ffffffffc020022c <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020381a:	00004697          	auipc	a3,0x4
ffffffffc020381e:	89e68693          	addi	a3,a3,-1890 # ffffffffc02070b8 <etext+0x153c>
ffffffffc0203822:	00003617          	auipc	a2,0x3
ffffffffc0203826:	dce60613          	addi	a2,a2,-562 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020382a:	25900593          	li	a1,601
ffffffffc020382e:	00003517          	auipc	a0,0x3
ffffffffc0203832:	47a50513          	addi	a0,a0,1146 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203836:	9f7fc0ef          	jal	ffffffffc020022c <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020383a:	00003697          	auipc	a3,0x3
ffffffffc020383e:	59668693          	addi	a3,a3,1430 # ffffffffc0206dd0 <etext+0x1254>
ffffffffc0203842:	00003617          	auipc	a2,0x3
ffffffffc0203846:	dae60613          	addi	a2,a2,-594 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020384a:	20000593          	li	a1,512
ffffffffc020384e:	00003517          	auipc	a0,0x3
ffffffffc0203852:	45a50513          	addi	a0,a0,1114 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203856:	9d7fc0ef          	jal	ffffffffc020022c <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020385a:	00003697          	auipc	a3,0x3
ffffffffc020385e:	55668693          	addi	a3,a3,1366 # ffffffffc0206db0 <etext+0x1234>
ffffffffc0203862:	00003617          	auipc	a2,0x3
ffffffffc0203866:	d8e60613          	addi	a2,a2,-626 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020386a:	1ff00593          	li	a1,511
ffffffffc020386e:	00003517          	auipc	a0,0x3
ffffffffc0203872:	43a50513          	addi	a0,a0,1082 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203876:	9b7fc0ef          	jal	ffffffffc020022c <__panic>
    return KADDR(page2pa(page));
ffffffffc020387a:	00003617          	auipc	a2,0x3
ffffffffc020387e:	cfe60613          	addi	a2,a2,-770 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0203882:	07100593          	li	a1,113
ffffffffc0203886:	00003517          	auipc	a0,0x3
ffffffffc020388a:	cd250513          	addi	a0,a0,-814 # ffffffffc0206558 <etext+0x9dc>
ffffffffc020388e:	99ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203892:	00003697          	auipc	a3,0x3
ffffffffc0203896:	7f668693          	addi	a3,a3,2038 # ffffffffc0207088 <etext+0x150c>
ffffffffc020389a:	00003617          	auipc	a2,0x3
ffffffffc020389e:	d5660613          	addi	a2,a2,-682 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02038a2:	22700593          	li	a1,551
ffffffffc02038a6:	00003517          	auipc	a0,0x3
ffffffffc02038aa:	40250513          	addi	a0,a0,1026 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02038ae:	97ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038b2:	00003697          	auipc	a3,0x3
ffffffffc02038b6:	78e68693          	addi	a3,a3,1934 # ffffffffc0207040 <etext+0x14c4>
ffffffffc02038ba:	00003617          	auipc	a2,0x3
ffffffffc02038be:	d3660613          	addi	a2,a2,-714 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02038c2:	22500593          	li	a1,549
ffffffffc02038c6:	00003517          	auipc	a0,0x3
ffffffffc02038ca:	3e250513          	addi	a0,a0,994 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02038ce:	95ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02038d2:	00003697          	auipc	a3,0x3
ffffffffc02038d6:	79e68693          	addi	a3,a3,1950 # ffffffffc0207070 <etext+0x14f4>
ffffffffc02038da:	00003617          	auipc	a2,0x3
ffffffffc02038de:	d1660613          	addi	a2,a2,-746 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02038e2:	22400593          	li	a1,548
ffffffffc02038e6:	00003517          	auipc	a0,0x3
ffffffffc02038ea:	3c250513          	addi	a0,a0,962 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02038ee:	93ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02038f2:	00004697          	auipc	a3,0x4
ffffffffc02038f6:	86668693          	addi	a3,a3,-1946 # ffffffffc0207158 <etext+0x15dc>
ffffffffc02038fa:	00003617          	auipc	a2,0x3
ffffffffc02038fe:	cf660613          	addi	a2,a2,-778 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203902:	24200593          	li	a1,578
ffffffffc0203906:	00003517          	auipc	a0,0x3
ffffffffc020390a:	3a250513          	addi	a0,a0,930 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc020390e:	91ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203912:	00003697          	auipc	a3,0x3
ffffffffc0203916:	7a668693          	addi	a3,a3,1958 # ffffffffc02070b8 <etext+0x153c>
ffffffffc020391a:	00003617          	auipc	a2,0x3
ffffffffc020391e:	cd660613          	addi	a2,a2,-810 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203922:	22f00593          	li	a1,559
ffffffffc0203926:	00003517          	auipc	a0,0x3
ffffffffc020392a:	38250513          	addi	a0,a0,898 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc020392e:	8fffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203932:	00004697          	auipc	a3,0x4
ffffffffc0203936:	87e68693          	addi	a3,a3,-1922 # ffffffffc02071b0 <etext+0x1634>
ffffffffc020393a:	00003617          	auipc	a2,0x3
ffffffffc020393e:	cb660613          	addi	a2,a2,-842 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203942:	24700593          	li	a1,583
ffffffffc0203946:	00003517          	auipc	a0,0x3
ffffffffc020394a:	36250513          	addi	a0,a0,866 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc020394e:	8dffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203952:	00004697          	auipc	a3,0x4
ffffffffc0203956:	81e68693          	addi	a3,a3,-2018 # ffffffffc0207170 <etext+0x15f4>
ffffffffc020395a:	00003617          	auipc	a2,0x3
ffffffffc020395e:	c9660613          	addi	a2,a2,-874 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203962:	24600593          	li	a1,582
ffffffffc0203966:	00003517          	auipc	a0,0x3
ffffffffc020396a:	34250513          	addi	a0,a0,834 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc020396e:	8bffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203972:	00003697          	auipc	a3,0x3
ffffffffc0203976:	6ce68693          	addi	a3,a3,1742 # ffffffffc0207040 <etext+0x14c4>
ffffffffc020397a:	00003617          	auipc	a2,0x3
ffffffffc020397e:	c7660613          	addi	a2,a2,-906 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203982:	22100593          	li	a1,545
ffffffffc0203986:	00003517          	auipc	a0,0x3
ffffffffc020398a:	32250513          	addi	a0,a0,802 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc020398e:	89ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203992:	00003697          	auipc	a3,0x3
ffffffffc0203996:	54e68693          	addi	a3,a3,1358 # ffffffffc0206ee0 <etext+0x1364>
ffffffffc020399a:	00003617          	auipc	a2,0x3
ffffffffc020399e:	c5660613          	addi	a2,a2,-938 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02039a2:	22000593          	li	a1,544
ffffffffc02039a6:	00003517          	auipc	a0,0x3
ffffffffc02039aa:	30250513          	addi	a0,a0,770 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02039ae:	87ffc0ef          	jal	ffffffffc020022c <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02039b2:	00003697          	auipc	a3,0x3
ffffffffc02039b6:	6a668693          	addi	a3,a3,1702 # ffffffffc0207058 <etext+0x14dc>
ffffffffc02039ba:	00003617          	auipc	a2,0x3
ffffffffc02039be:	c3660613          	addi	a2,a2,-970 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02039c2:	21d00593          	li	a1,541
ffffffffc02039c6:	00003517          	auipc	a0,0x3
ffffffffc02039ca:	2e250513          	addi	a0,a0,738 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02039ce:	85ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02039d2:	00003697          	auipc	a3,0x3
ffffffffc02039d6:	4f668693          	addi	a3,a3,1270 # ffffffffc0206ec8 <etext+0x134c>
ffffffffc02039da:	00003617          	auipc	a2,0x3
ffffffffc02039de:	c1660613          	addi	a2,a2,-1002 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02039e2:	21c00593          	li	a1,540
ffffffffc02039e6:	00003517          	auipc	a0,0x3
ffffffffc02039ea:	2c250513          	addi	a0,a0,706 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc02039ee:	83ffc0ef          	jal	ffffffffc020022c <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02039f2:	00003697          	auipc	a3,0x3
ffffffffc02039f6:	57668693          	addi	a3,a3,1398 # ffffffffc0206f68 <etext+0x13ec>
ffffffffc02039fa:	00003617          	auipc	a2,0x3
ffffffffc02039fe:	bf660613          	addi	a2,a2,-1034 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203a02:	21b00593          	li	a1,539
ffffffffc0203a06:	00003517          	auipc	a0,0x3
ffffffffc0203a0a:	2a250513          	addi	a0,a0,674 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203a0e:	81ffc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203a12:	00003697          	auipc	a3,0x3
ffffffffc0203a16:	62e68693          	addi	a3,a3,1582 # ffffffffc0207040 <etext+0x14c4>
ffffffffc0203a1a:	00003617          	auipc	a2,0x3
ffffffffc0203a1e:	bd660613          	addi	a2,a2,-1066 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203a22:	21a00593          	li	a1,538
ffffffffc0203a26:	00003517          	auipc	a0,0x3
ffffffffc0203a2a:	28250513          	addi	a0,a0,642 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203a2e:	ffefc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203a32:	00003697          	auipc	a3,0x3
ffffffffc0203a36:	5f668693          	addi	a3,a3,1526 # ffffffffc0207028 <etext+0x14ac>
ffffffffc0203a3a:	00003617          	auipc	a2,0x3
ffffffffc0203a3e:	bb660613          	addi	a2,a2,-1098 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203a42:	21900593          	li	a1,537
ffffffffc0203a46:	00003517          	auipc	a0,0x3
ffffffffc0203a4a:	26250513          	addi	a0,a0,610 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203a4e:	fdefc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203a52:	00003697          	auipc	a3,0x3
ffffffffc0203a56:	5a668693          	addi	a3,a3,1446 # ffffffffc0206ff8 <etext+0x147c>
ffffffffc0203a5a:	00003617          	auipc	a2,0x3
ffffffffc0203a5e:	b9660613          	addi	a2,a2,-1130 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203a62:	21800593          	li	a1,536
ffffffffc0203a66:	00003517          	auipc	a0,0x3
ffffffffc0203a6a:	24250513          	addi	a0,a0,578 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203a6e:	fbefc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203a72:	00003697          	auipc	a3,0x3
ffffffffc0203a76:	56e68693          	addi	a3,a3,1390 # ffffffffc0206fe0 <etext+0x1464>
ffffffffc0203a7a:	00003617          	auipc	a2,0x3
ffffffffc0203a7e:	b7660613          	addi	a2,a2,-1162 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203a82:	21600593          	li	a1,534
ffffffffc0203a86:	00003517          	auipc	a0,0x3
ffffffffc0203a8a:	22250513          	addi	a0,a0,546 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203a8e:	f9efc0ef          	jal	ffffffffc020022c <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203a92:	00003697          	auipc	a3,0x3
ffffffffc0203a96:	52e68693          	addi	a3,a3,1326 # ffffffffc0206fc0 <etext+0x1444>
ffffffffc0203a9a:	00003617          	auipc	a2,0x3
ffffffffc0203a9e:	b5660613          	addi	a2,a2,-1194 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203aa2:	21500593          	li	a1,533
ffffffffc0203aa6:	00003517          	auipc	a0,0x3
ffffffffc0203aaa:	20250513          	addi	a0,a0,514 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203aae:	f7efc0ef          	jal	ffffffffc020022c <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203ab2:	00003697          	auipc	a3,0x3
ffffffffc0203ab6:	4fe68693          	addi	a3,a3,1278 # ffffffffc0206fb0 <etext+0x1434>
ffffffffc0203aba:	00003617          	auipc	a2,0x3
ffffffffc0203abe:	b3660613          	addi	a2,a2,-1226 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203ac2:	21400593          	li	a1,532
ffffffffc0203ac6:	00003517          	auipc	a0,0x3
ffffffffc0203aca:	1e250513          	addi	a0,a0,482 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203ace:	f5efc0ef          	jal	ffffffffc020022c <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203ad2:	00003697          	auipc	a3,0x3
ffffffffc0203ad6:	4ce68693          	addi	a3,a3,1230 # ffffffffc0206fa0 <etext+0x1424>
ffffffffc0203ada:	00003617          	auipc	a2,0x3
ffffffffc0203ade:	b1660613          	addi	a2,a2,-1258 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203ae2:	21300593          	li	a1,531
ffffffffc0203ae6:	00003517          	auipc	a0,0x3
ffffffffc0203aea:	1c250513          	addi	a0,a0,450 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203aee:	f3efc0ef          	jal	ffffffffc020022c <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203af2:	00003617          	auipc	a2,0x3
ffffffffc0203af6:	de660613          	addi	a2,a2,-538 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc0203afa:	08100593          	li	a1,129
ffffffffc0203afe:	00003517          	auipc	a0,0x3
ffffffffc0203b02:	1aa50513          	addi	a0,a0,426 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203b06:	f26fc0ef          	jal	ffffffffc020022c <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203b0a:	00003697          	auipc	a3,0x3
ffffffffc0203b0e:	3ee68693          	addi	a3,a3,1006 # ffffffffc0206ef8 <etext+0x137c>
ffffffffc0203b12:	00003617          	auipc	a2,0x3
ffffffffc0203b16:	ade60613          	addi	a2,a2,-1314 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203b1a:	20e00593          	li	a1,526
ffffffffc0203b1e:	00003517          	auipc	a0,0x3
ffffffffc0203b22:	18a50513          	addi	a0,a0,394 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203b26:	f06fc0ef          	jal	ffffffffc020022c <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203b2a:	00003697          	auipc	a3,0x3
ffffffffc0203b2e:	43e68693          	addi	a3,a3,1086 # ffffffffc0206f68 <etext+0x13ec>
ffffffffc0203b32:	00003617          	auipc	a2,0x3
ffffffffc0203b36:	abe60613          	addi	a2,a2,-1346 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203b3a:	21200593          	li	a1,530
ffffffffc0203b3e:	00003517          	auipc	a0,0x3
ffffffffc0203b42:	16a50513          	addi	a0,a0,362 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203b46:	ee6fc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203b4a:	00003697          	auipc	a3,0x3
ffffffffc0203b4e:	3de68693          	addi	a3,a3,990 # ffffffffc0206f28 <etext+0x13ac>
ffffffffc0203b52:	00003617          	auipc	a2,0x3
ffffffffc0203b56:	a9e60613          	addi	a2,a2,-1378 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203b5a:	21100593          	li	a1,529
ffffffffc0203b5e:	00003517          	auipc	a0,0x3
ffffffffc0203b62:	14a50513          	addi	a0,a0,330 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203b66:	ec6fc0ef          	jal	ffffffffc020022c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203b6a:	86d6                	mv	a3,s5
ffffffffc0203b6c:	00003617          	auipc	a2,0x3
ffffffffc0203b70:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0203b74:	20d00593          	li	a1,525
ffffffffc0203b78:	00003517          	auipc	a0,0x3
ffffffffc0203b7c:	13050513          	addi	a0,a0,304 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203b80:	eacfc0ef          	jal	ffffffffc020022c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203b84:	00003617          	auipc	a2,0x3
ffffffffc0203b88:	9f460613          	addi	a2,a2,-1548 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0203b8c:	20c00593          	li	a1,524
ffffffffc0203b90:	00003517          	auipc	a0,0x3
ffffffffc0203b94:	11850513          	addi	a0,a0,280 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203b98:	e94fc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203b9c:	00003697          	auipc	a3,0x3
ffffffffc0203ba0:	34468693          	addi	a3,a3,836 # ffffffffc0206ee0 <etext+0x1364>
ffffffffc0203ba4:	00003617          	auipc	a2,0x3
ffffffffc0203ba8:	a4c60613          	addi	a2,a2,-1460 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203bac:	20a00593          	li	a1,522
ffffffffc0203bb0:	00003517          	auipc	a0,0x3
ffffffffc0203bb4:	0f850513          	addi	a0,a0,248 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203bb8:	e74fc0ef          	jal	ffffffffc020022c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203bbc:	00003697          	auipc	a3,0x3
ffffffffc0203bc0:	30c68693          	addi	a3,a3,780 # ffffffffc0206ec8 <etext+0x134c>
ffffffffc0203bc4:	00003617          	auipc	a2,0x3
ffffffffc0203bc8:	a2c60613          	addi	a2,a2,-1492 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203bcc:	20900593          	li	a1,521
ffffffffc0203bd0:	00003517          	auipc	a0,0x3
ffffffffc0203bd4:	0d850513          	addi	a0,a0,216 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203bd8:	e54fc0ef          	jal	ffffffffc020022c <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203bdc:	00003697          	auipc	a3,0x3
ffffffffc0203be0:	69c68693          	addi	a3,a3,1692 # ffffffffc0207278 <etext+0x16fc>
ffffffffc0203be4:	00003617          	auipc	a2,0x3
ffffffffc0203be8:	a0c60613          	addi	a2,a2,-1524 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203bec:	25000593          	li	a1,592
ffffffffc0203bf0:	00003517          	auipc	a0,0x3
ffffffffc0203bf4:	0b850513          	addi	a0,a0,184 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203bf8:	e34fc0ef          	jal	ffffffffc020022c <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203bfc:	00003697          	auipc	a3,0x3
ffffffffc0203c00:	64468693          	addi	a3,a3,1604 # ffffffffc0207240 <etext+0x16c4>
ffffffffc0203c04:	00003617          	auipc	a2,0x3
ffffffffc0203c08:	9ec60613          	addi	a2,a2,-1556 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203c0c:	24d00593          	li	a1,589
ffffffffc0203c10:	00003517          	auipc	a0,0x3
ffffffffc0203c14:	09850513          	addi	a0,a0,152 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203c18:	e14fc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c1c:	00003697          	auipc	a3,0x3
ffffffffc0203c20:	5f468693          	addi	a3,a3,1524 # ffffffffc0207210 <etext+0x1694>
ffffffffc0203c24:	00003617          	auipc	a2,0x3
ffffffffc0203c28:	9cc60613          	addi	a2,a2,-1588 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203c2c:	24900593          	li	a1,585
ffffffffc0203c30:	00003517          	auipc	a0,0x3
ffffffffc0203c34:	07850513          	addi	a0,a0,120 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203c38:	df4fc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203c3c:	00003697          	auipc	a3,0x3
ffffffffc0203c40:	58c68693          	addi	a3,a3,1420 # ffffffffc02071c8 <etext+0x164c>
ffffffffc0203c44:	00003617          	auipc	a2,0x3
ffffffffc0203c48:	9ac60613          	addi	a2,a2,-1620 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203c4c:	24800593          	li	a1,584
ffffffffc0203c50:	00003517          	auipc	a0,0x3
ffffffffc0203c54:	05850513          	addi	a0,a0,88 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203c58:	dd4fc0ef          	jal	ffffffffc020022c <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203c5c:	00003697          	auipc	a3,0x3
ffffffffc0203c60:	1b468693          	addi	a3,a3,436 # ffffffffc0206e10 <etext+0x1294>
ffffffffc0203c64:	00003617          	auipc	a2,0x3
ffffffffc0203c68:	98c60613          	addi	a2,a2,-1652 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203c6c:	20100593          	li	a1,513
ffffffffc0203c70:	00003517          	auipc	a0,0x3
ffffffffc0203c74:	03850513          	addi	a0,a0,56 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203c78:	db4fc0ef          	jal	ffffffffc020022c <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203c7c:	00003617          	auipc	a2,0x3
ffffffffc0203c80:	c5c60613          	addi	a2,a2,-932 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc0203c84:	0c900593          	li	a1,201
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	02050513          	addi	a0,a0,32 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203c90:	d9cfc0ef          	jal	ffffffffc020022c <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203c94:	00003697          	auipc	a3,0x3
ffffffffc0203c98:	1dc68693          	addi	a3,a3,476 # ffffffffc0206e70 <etext+0x12f4>
ffffffffc0203c9c:	00003617          	auipc	a2,0x3
ffffffffc0203ca0:	95460613          	addi	a2,a2,-1708 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203ca4:	20800593          	li	a1,520
ffffffffc0203ca8:	00003517          	auipc	a0,0x3
ffffffffc0203cac:	00050513          	mv	a0,a0
ffffffffc0203cb0:	d7cfc0ef          	jal	ffffffffc020022c <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203cb4:	00003697          	auipc	a3,0x3
ffffffffc0203cb8:	18c68693          	addi	a3,a3,396 # ffffffffc0206e40 <etext+0x12c4>
ffffffffc0203cbc:	00003617          	auipc	a2,0x3
ffffffffc0203cc0:	93460613          	addi	a2,a2,-1740 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203cc4:	20500593          	li	a1,517
ffffffffc0203cc8:	00003517          	auipc	a0,0x3
ffffffffc0203ccc:	fe050513          	addi	a0,a0,-32 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203cd0:	d5cfc0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0203cd4 <copy_range>:
{
ffffffffc0203cd4:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cd6:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203cda:	ec86                	sd	ra,88(sp)
ffffffffc0203cdc:	e8a2                	sd	s0,80(sp)
ffffffffc0203cde:	e4a6                	sd	s1,72(sp)
ffffffffc0203ce0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ce2:	fc4e                	sd	s3,56(sp)
ffffffffc0203ce4:	f852                	sd	s4,48(sp)
ffffffffc0203ce6:	f456                	sd	s5,40(sp)
ffffffffc0203ce8:	f05a                	sd	s6,32(sp)
ffffffffc0203cea:	ec5e                	sd	s7,24(sp)
ffffffffc0203cec:	e862                	sd	s8,16(sp)
ffffffffc0203cee:	e466                	sd	s9,8(sp)
ffffffffc0203cf0:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cf2:	03479713          	slli	a4,a5,0x34
ffffffffc0203cf6:	12071b63          	bnez	a4,ffffffffc0203e2c <copy_range+0x158>
    assert(USER_ACCESS(start, end));
ffffffffc0203cfa:	00200c37          	lui	s8,0x200
ffffffffc0203cfe:	00d637b3          	sltu	a5,a2,a3
ffffffffc0203d02:	01863733          	sltu	a4,a2,s8
ffffffffc0203d06:	0017b793          	seqz	a5,a5
ffffffffc0203d0a:	8fd9                	or	a5,a5,a4
ffffffffc0203d0c:	8432                	mv	s0,a2
ffffffffc0203d0e:	84b6                	mv	s1,a3
ffffffffc0203d10:	0e079e63          	bnez	a5,ffffffffc0203e0c <copy_range+0x138>
ffffffffc0203d14:	4785                	li	a5,1
ffffffffc0203d16:	07fe                	slli	a5,a5,0x1f
ffffffffc0203d18:	0785                	addi	a5,a5,1 # fffffffffe000001 <end+0x3dd1ad81>
ffffffffc0203d1a:	0ef6f963          	bgeu	a3,a5,ffffffffc0203e0c <copy_range+0x138>
ffffffffc0203d1e:	8a2a                	mv	s4,a0
ffffffffc0203d20:	892e                	mv	s2,a1
ffffffffc0203d22:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc0203d24:	000e1b97          	auipc	s7,0xe1
ffffffffc0203d28:	51cb8b93          	addi	s7,s7,1308 # ffffffffc02e5240 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d2c:	000e1b17          	auipc	s6,0xe1
ffffffffc0203d30:	51cb0b13          	addi	s6,s6,1308 # ffffffffc02e5248 <pages>
ffffffffc0203d34:	fff80ab7          	lui	s5,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203d38:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203d3c:	4601                	li	a2,0
ffffffffc0203d3e:	85a2                	mv	a1,s0
ffffffffc0203d40:	854a                	mv	a0,s2
ffffffffc0203d42:	b1dfe0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc0203d46:	8d2a                	mv	s10,a0
        if (ptep == NULL)
ffffffffc0203d48:	c935                	beqz	a0,ffffffffc0203dbc <copy_range+0xe8>
        if (*ptep & PTE_V)
ffffffffc0203d4a:	611c                	ld	a5,0(a0)
ffffffffc0203d4c:	8b85                	andi	a5,a5,1
ffffffffc0203d4e:	e785                	bnez	a5,ffffffffc0203d76 <copy_range+0xa2>
        start += PGSIZE;
ffffffffc0203d50:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203d52:	c019                	beqz	s0,ffffffffc0203d58 <copy_range+0x84>
ffffffffc0203d54:	fe9464e3          	bltu	s0,s1,ffffffffc0203d3c <copy_range+0x68>
    return 0;
ffffffffc0203d58:	4501                	li	a0,0
}
ffffffffc0203d5a:	60e6                	ld	ra,88(sp)
ffffffffc0203d5c:	6446                	ld	s0,80(sp)
ffffffffc0203d5e:	64a6                	ld	s1,72(sp)
ffffffffc0203d60:	6906                	ld	s2,64(sp)
ffffffffc0203d62:	79e2                	ld	s3,56(sp)
ffffffffc0203d64:	7a42                	ld	s4,48(sp)
ffffffffc0203d66:	7aa2                	ld	s5,40(sp)
ffffffffc0203d68:	7b02                	ld	s6,32(sp)
ffffffffc0203d6a:	6be2                	ld	s7,24(sp)
ffffffffc0203d6c:	6c42                	ld	s8,16(sp)
ffffffffc0203d6e:	6ca2                	ld	s9,8(sp)
ffffffffc0203d70:	6d02                	ld	s10,0(sp)
ffffffffc0203d72:	6125                	addi	sp,sp,96
ffffffffc0203d74:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203d76:	4605                	li	a2,1
ffffffffc0203d78:	85a2                	mv	a1,s0
ffffffffc0203d7a:	8552                	mv	a0,s4
ffffffffc0203d7c:	ae3fe0ef          	jal	ffffffffc020285e <get_pte>
ffffffffc0203d80:	cd05                	beqz	a0,ffffffffc0203db8 <copy_range+0xe4>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203d82:	000d3683          	ld	a3,0(s10)
    if (!(pte & PTE_V))
ffffffffc0203d86:	0016f793          	andi	a5,a3,1
ffffffffc0203d8a:	c7ad                	beqz	a5,ffffffffc0203df4 <copy_range+0x120>
    if (PPN(pa) >= npage)
ffffffffc0203d8c:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203d90:	00269793          	slli	a5,a3,0x2
ffffffffc0203d94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203d96:	04e7f363          	bgeu	a5,a4,ffffffffc0203ddc <copy_range+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d9a:	000b3583          	ld	a1,0(s6)
ffffffffc0203d9e:	97d6                	add	a5,a5,s5
ffffffffc0203da0:	079a                	slli	a5,a5,0x6
ffffffffc0203da2:	95be                	add	a1,a1,a5
            if (perm & PTE_W)
ffffffffc0203da4:	0046f793          	andi	a5,a3,4
ffffffffc0203da8:	ef91                	bnez	a5,ffffffffc0203dc4 <copy_range+0xf0>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203daa:	21f6f693          	andi	a3,a3,543
            int ret = page_insert(to, page, start, perm);
ffffffffc0203dae:	8622                	mv	a2,s0
ffffffffc0203db0:	8552                	mv	a0,s4
ffffffffc0203db2:	9e2ff0ef          	jal	ffffffffc0202f94 <page_insert>
            if (ret != 0)
ffffffffc0203db6:	dd49                	beqz	a0,ffffffffc0203d50 <copy_range+0x7c>
                return -E_NO_MEM;
ffffffffc0203db8:	5571                	li	a0,-4
ffffffffc0203dba:	b745                	j	ffffffffc0203d5a <copy_range+0x86>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203dbc:	9462                	add	s0,s0,s8
ffffffffc0203dbe:	01947433          	and	s0,s0,s9
            continue;
ffffffffc0203dc2:	bf41                	j	ffffffffc0203d52 <copy_range+0x7e>
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203dc4:	dfb6f793          	andi	a5,a3,-517
ffffffffc0203dc8:	2007e793          	ori	a5,a5,512
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0203dcc:	8aed                	andi	a3,a3,27
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203dce:	00fd3023          	sd	a5,0(s10)
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0203dd2:	2006e693          	ori	a3,a3,512
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dd6:	12040073          	sfence.vma	s0
}
ffffffffc0203dda:	bfd1                	j	ffffffffc0203dae <copy_range+0xda>
        panic("pa2page called with invalid pa");
ffffffffc0203ddc:	00002617          	auipc	a2,0x2
ffffffffc0203de0:	75c60613          	addi	a2,a2,1884 # ffffffffc0206538 <etext+0x9bc>
ffffffffc0203de4:	06900593          	li	a1,105
ffffffffc0203de8:	00002517          	auipc	a0,0x2
ffffffffc0203dec:	77050513          	addi	a0,a0,1904 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0203df0:	c3cfc0ef          	jal	ffffffffc020022c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203df4:	00003617          	auipc	a2,0x3
ffffffffc0203df8:	0ac60613          	addi	a2,a2,172 # ffffffffc0206ea0 <etext+0x1324>
ffffffffc0203dfc:	07f00593          	li	a1,127
ffffffffc0203e00:	00002517          	auipc	a0,0x2
ffffffffc0203e04:	75850513          	addi	a0,a0,1880 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0203e08:	c24fc0ef          	jal	ffffffffc020022c <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203e0c:	00003697          	auipc	a3,0x3
ffffffffc0203e10:	edc68693          	addi	a3,a3,-292 # ffffffffc0206ce8 <etext+0x116c>
ffffffffc0203e14:	00002617          	auipc	a2,0x2
ffffffffc0203e18:	7dc60613          	addi	a2,a2,2012 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203e1c:	17e00593          	li	a1,382
ffffffffc0203e20:	00003517          	auipc	a0,0x3
ffffffffc0203e24:	e8850513          	addi	a0,a0,-376 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203e28:	c04fc0ef          	jal	ffffffffc020022c <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203e2c:	00003697          	auipc	a3,0x3
ffffffffc0203e30:	e8c68693          	addi	a3,a3,-372 # ffffffffc0206cb8 <etext+0x113c>
ffffffffc0203e34:	00002617          	auipc	a2,0x2
ffffffffc0203e38:	7bc60613          	addi	a2,a2,1980 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203e3c:	17d00593          	li	a1,381
ffffffffc0203e40:	00003517          	auipc	a0,0x3
ffffffffc0203e44:	e6850513          	addi	a0,a0,-408 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203e48:	be4fc0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0203e4c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e4c:	12058073          	sfence.vma	a1
}
ffffffffc0203e50:	8082                	ret

ffffffffc0203e52 <pgdir_alloc_page>:
{
ffffffffc0203e52:	7139                	addi	sp,sp,-64
ffffffffc0203e54:	f426                	sd	s1,40(sp)
ffffffffc0203e56:	f04a                	sd	s2,32(sp)
ffffffffc0203e58:	ec4e                	sd	s3,24(sp)
ffffffffc0203e5a:	fc06                	sd	ra,56(sp)
ffffffffc0203e5c:	f822                	sd	s0,48(sp)
ffffffffc0203e5e:	892a                	mv	s2,a0
ffffffffc0203e60:	84ae                	mv	s1,a1
ffffffffc0203e62:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e64:	100027f3          	csrr	a5,sstatus
ffffffffc0203e68:	8b89                	andi	a5,a5,2
ffffffffc0203e6a:	ebb5                	bnez	a5,ffffffffc0203ede <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203e6c:	000e1417          	auipc	s0,0xe1
ffffffffc0203e70:	3b440413          	addi	s0,s0,948 # ffffffffc02e5220 <pmm_manager>
ffffffffc0203e74:	601c                	ld	a5,0(s0)
ffffffffc0203e76:	4505                	li	a0,1
ffffffffc0203e78:	6f9c                	ld	a5,24(a5)
ffffffffc0203e7a:	9782                	jalr	a5
ffffffffc0203e7c:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc0203e7e:	c5b9                	beqz	a1,ffffffffc0203ecc <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203e80:	86ce                	mv	a3,s3
ffffffffc0203e82:	854a                	mv	a0,s2
ffffffffc0203e84:	8626                	mv	a2,s1
ffffffffc0203e86:	e42e                	sd	a1,8(sp)
ffffffffc0203e88:	90cff0ef          	jal	ffffffffc0202f94 <page_insert>
ffffffffc0203e8c:	65a2                	ld	a1,8(sp)
ffffffffc0203e8e:	e515                	bnez	a0,ffffffffc0203eba <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc0203e90:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc0203e92:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc0203e94:	4785                	li	a5,1
ffffffffc0203e96:	02f70c63          	beq	a4,a5,ffffffffc0203ece <pgdir_alloc_page+0x7c>
ffffffffc0203e9a:	00003697          	auipc	a3,0x3
ffffffffc0203e9e:	42668693          	addi	a3,a3,1062 # ffffffffc02072c0 <etext+0x1744>
ffffffffc0203ea2:	00002617          	auipc	a2,0x2
ffffffffc0203ea6:	74e60613          	addi	a2,a2,1870 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0203eaa:	1e600593          	li	a1,486
ffffffffc0203eae:	00003517          	auipc	a0,0x3
ffffffffc0203eb2:	dfa50513          	addi	a0,a0,-518 # ffffffffc0206ca8 <etext+0x112c>
ffffffffc0203eb6:	b76fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203eba:	100027f3          	csrr	a5,sstatus
ffffffffc0203ebe:	8b89                	andi	a5,a5,2
ffffffffc0203ec0:	ef95                	bnez	a5,ffffffffc0203efc <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc0203ec2:	601c                	ld	a5,0(s0)
ffffffffc0203ec4:	852e                	mv	a0,a1
ffffffffc0203ec6:	4585                	li	a1,1
ffffffffc0203ec8:	739c                	ld	a5,32(a5)
ffffffffc0203eca:	9782                	jalr	a5
            return NULL;
ffffffffc0203ecc:	4581                	li	a1,0
}
ffffffffc0203ece:	70e2                	ld	ra,56(sp)
ffffffffc0203ed0:	7442                	ld	s0,48(sp)
ffffffffc0203ed2:	74a2                	ld	s1,40(sp)
ffffffffc0203ed4:	7902                	ld	s2,32(sp)
ffffffffc0203ed6:	69e2                	ld	s3,24(sp)
ffffffffc0203ed8:	852e                	mv	a0,a1
ffffffffc0203eda:	6121                	addi	sp,sp,64
ffffffffc0203edc:	8082                	ret
        intr_disable();
ffffffffc0203ede:	a27fc0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203ee2:	000e1417          	auipc	s0,0xe1
ffffffffc0203ee6:	33e40413          	addi	s0,s0,830 # ffffffffc02e5220 <pmm_manager>
ffffffffc0203eea:	601c                	ld	a5,0(s0)
ffffffffc0203eec:	4505                	li	a0,1
ffffffffc0203eee:	6f9c                	ld	a5,24(a5)
ffffffffc0203ef0:	9782                	jalr	a5
ffffffffc0203ef2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203ef4:	a0bfc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203ef8:	65a2                	ld	a1,8(sp)
ffffffffc0203efa:	b751                	j	ffffffffc0203e7e <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc0203efc:	a09fc0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203f00:	601c                	ld	a5,0(s0)
ffffffffc0203f02:	6522                	ld	a0,8(sp)
ffffffffc0203f04:	4585                	li	a1,1
ffffffffc0203f06:	739c                	ld	a5,32(a5)
ffffffffc0203f08:	9782                	jalr	a5
        intr_enable();
ffffffffc0203f0a:	9f5fc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203f0e:	bf7d                	j	ffffffffc0203ecc <pgdir_alloc_page+0x7a>

ffffffffc0203f10 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203f10:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203f12:	9402                	jalr	s0

	jal do_exit
ffffffffc0203f14:	65e000ef          	jal	ffffffffc0204572 <do_exit>

ffffffffc0203f18 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203f18:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203f1c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203f20:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203f22:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203f24:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203f28:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203f2c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203f30:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203f34:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203f38:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203f3c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203f40:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203f44:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203f48:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203f4c:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203f50:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0203f54:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203f56:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203f58:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203f5c:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203f60:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0203f64:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203f68:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203f6c:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203f70:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0203f74:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203f78:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203f7c:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0203f80:	8082                	ret

ffffffffc0203f82 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203f82:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f84:	17000513          	li	a0,368
{
ffffffffc0203f88:	e022                	sd	s0,0(sp)
ffffffffc0203f8a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f8c:	b7ffd0ef          	jal	ffffffffc0201b0a <kmalloc>
ffffffffc0203f90:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203f92:	cd51                	beqz	a0,ffffffffc020402e <alloc_proc+0xac>
    {
        proc->state = PROC_UNINIT;
ffffffffc0203f94:	57fd                	li	a5,-1
ffffffffc0203f96:	1782                	slli	a5,a5,0x20
ffffffffc0203f98:	e11c                	sd	a5,0(a0)
        proc->pid = -1;
        proc->runs = 0;
ffffffffc0203f9a:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203f9e:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203fa2:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203fa6:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0203faa:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203fae:	07000613          	li	a2,112
ffffffffc0203fb2:	4581                	li	a1,0
ffffffffc0203fb4:	03050513          	addi	a0,a0,48
ffffffffc0203fb8:	7b8010ef          	jal	ffffffffc0205770 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fbc:	000e1797          	auipc	a5,0xe1
ffffffffc0203fc0:	26c7b783          	ld	a5,620(a5) # ffffffffc02e5228 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203fc4:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203fc8:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fcc:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203fce:	0b440513          	addi	a0,s0,180
ffffffffc0203fd2:	4641                	li	a2,16
ffffffffc0203fd4:	4581                	li	a1,0
ffffffffc0203fd6:	79a010ef          	jal	ffffffffc0205770 <memset>
        proc->cptr = proc->yptr = proc->optr = NULL;
        proc->rq = NULL;
        list_init(&(proc->run_link));
        proc->time_slice = 0;
        skew_heap_init(&(proc->lab6_run_pool));
        proc->lab6_stride = 0;
ffffffffc0203fda:	47e5                	li	a5,25
ffffffffc0203fdc:	4705                	li	a4,1
ffffffffc0203fde:	1786                	slli	a5,a5,0x21
        list_init(&(proc->run_link));
ffffffffc0203fe0:	11040693          	addi	a3,s0,272
        proc->lab6_stride = 0;
ffffffffc0203fe4:	1702                	slli	a4,a4,0x20
ffffffffc0203fe6:	03278793          	addi	a5,a5,50
        proc->wait_state = 0;
ffffffffc0203fea:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0203fee:	10043023          	sd	zero,256(s0)
ffffffffc0203ff2:	0e043c23          	sd	zero,248(s0)
ffffffffc0203ff6:	0e043823          	sd	zero,240(s0)
        proc->rq = NULL;
ffffffffc0203ffa:	10043423          	sd	zero,264(s0)
        proc->time_slice = 0;
ffffffffc0203ffe:	12042023          	sw	zero,288(s0)
     compare_f comp) __attribute__((always_inline));

static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL;
ffffffffc0204002:	12043423          	sd	zero,296(s0)
ffffffffc0204006:	12043c23          	sd	zero,312(s0)
ffffffffc020400a:	12043823          	sd	zero,304(s0)
        proc->lab6_stride = 0;
ffffffffc020400e:	14043823          	sd	zero,336(s0)
        proc->lab6_priority = 1;
        proc->sched_expected = SCHED_DEFAULT_EXPECTED;
        proc->sched_remaining = SCHED_DEFAULT_EXPECTED;
        proc->sched_wait_start = 0;
        proc->sched_last_start = 0;
        proc->sched_runtime_ticks = 0;
ffffffffc0204012:	14042c23          	sw	zero,344(s0)
        proc->sched_vruntime = 0;
ffffffffc0204016:	16043023          	sd	zero,352(s0)
        proc->sched_qlevel = 0;
ffffffffc020401a:	16043423          	sd	zero,360(s0)
        proc->lab6_stride = 0;
ffffffffc020401e:	14e43023          	sd	a4,320(s0)
ffffffffc0204022:	14f43423          	sd	a5,328(s0)
    elm->prev = elm->next = elm;
ffffffffc0204026:	10d43c23          	sd	a3,280(s0)
ffffffffc020402a:	10d43823          	sd	a3,272(s0)
        proc->sched_nice = 0;
    }
    return proc;
}
ffffffffc020402e:	60a2                	ld	ra,8(sp)
ffffffffc0204030:	8522                	mv	a0,s0
ffffffffc0204032:	6402                	ld	s0,0(sp)
ffffffffc0204034:	0141                	addi	sp,sp,16
ffffffffc0204036:	8082                	ret

ffffffffc0204038 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204038:	000e1797          	auipc	a5,0xe1
ffffffffc020403c:	2207b783          	ld	a5,544(a5) # ffffffffc02e5258 <current>
ffffffffc0204040:	73c8                	ld	a0,160(a5)
ffffffffc0204042:	844fd06f          	j	ffffffffc0201086 <forkrets>

ffffffffc0204046 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204046:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0204048:	1141                	addi	sp,sp,-16
ffffffffc020404a:	e406                	sd	ra,8(sp)
ffffffffc020404c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204050:	02f6ee63          	bltu	a3,a5,ffffffffc020408c <put_pgdir+0x46>
ffffffffc0204054:	000e1717          	auipc	a4,0xe1
ffffffffc0204058:	1e473703          	ld	a4,484(a4) # ffffffffc02e5238 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc020405c:	000e1797          	auipc	a5,0xe1
ffffffffc0204060:	1e47b783          	ld	a5,484(a5) # ffffffffc02e5240 <npage>
    return pa2page(PADDR(kva));
ffffffffc0204064:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204066:	82b1                	srli	a3,a3,0xc
ffffffffc0204068:	02f6fe63          	bgeu	a3,a5,ffffffffc02040a4 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020406c:	00004797          	auipc	a5,0x4
ffffffffc0204070:	38c7b783          	ld	a5,908(a5) # ffffffffc02083f8 <nbase>
ffffffffc0204074:	000e1517          	auipc	a0,0xe1
ffffffffc0204078:	1d453503          	ld	a0,468(a0) # ffffffffc02e5248 <pages>
    free_page(kva2page(mm->pgdir));
}
ffffffffc020407c:	60a2                	ld	ra,8(sp)
ffffffffc020407e:	8e9d                	sub	a3,a3,a5
ffffffffc0204080:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204082:	4585                	li	a1,1
ffffffffc0204084:	9536                	add	a0,a0,a3
}
ffffffffc0204086:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204088:	f68fe06f          	j	ffffffffc02027f0 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc020408c:	00003617          	auipc	a2,0x3
ffffffffc0204090:	84c60613          	addi	a2,a2,-1972 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc0204094:	07700593          	li	a1,119
ffffffffc0204098:	00002517          	auipc	a0,0x2
ffffffffc020409c:	4c050513          	addi	a0,a0,1216 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02040a0:	98cfc0ef          	jal	ffffffffc020022c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02040a4:	00002617          	auipc	a2,0x2
ffffffffc02040a8:	49460613          	addi	a2,a2,1172 # ffffffffc0206538 <etext+0x9bc>
ffffffffc02040ac:	06900593          	li	a1,105
ffffffffc02040b0:	00002517          	auipc	a0,0x2
ffffffffc02040b4:	4a850513          	addi	a0,a0,1192 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02040b8:	974fc0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02040bc <proc_run>:
    if (proc != current)
ffffffffc02040bc:	000e1697          	auipc	a3,0xe1
ffffffffc02040c0:	19c6b683          	ld	a3,412(a3) # ffffffffc02e5258 <current>
ffffffffc02040c4:	04a68463          	beq	a3,a0,ffffffffc020410c <proc_run+0x50>
{
ffffffffc02040c8:	1101                	addi	sp,sp,-32
ffffffffc02040ca:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02040cc:	100027f3          	csrr	a5,sstatus
ffffffffc02040d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02040d2:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02040d4:	ef8d                	bnez	a5,ffffffffc020410e <proc_run+0x52>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc02040d6:	755c                	ld	a5,168(a0)
ffffffffc02040d8:	577d                	li	a4,-1
ffffffffc02040da:	177e                	slli	a4,a4,0x3f
ffffffffc02040dc:	83b1                	srli	a5,a5,0xc
ffffffffc02040de:	e032                	sd	a2,0(sp)
            current = proc;
ffffffffc02040e0:	000e1597          	auipc	a1,0xe1
ffffffffc02040e4:	16a5bc23          	sd	a0,376(a1) # ffffffffc02e5258 <current>
ffffffffc02040e8:	8fd9                	or	a5,a5,a4
ffffffffc02040ea:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc02040ee:	03050593          	addi	a1,a0,48
ffffffffc02040f2:	03068513          	addi	a0,a3,48
ffffffffc02040f6:	e23ff0ef          	jal	ffffffffc0203f18 <switch_to>
    if (flag)
ffffffffc02040fa:	6602                	ld	a2,0(sp)
ffffffffc02040fc:	e601                	bnez	a2,ffffffffc0204104 <proc_run+0x48>
}
ffffffffc02040fe:	60e2                	ld	ra,24(sp)
ffffffffc0204100:	6105                	addi	sp,sp,32
ffffffffc0204102:	8082                	ret
ffffffffc0204104:	60e2                	ld	ra,24(sp)
ffffffffc0204106:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204108:	ff6fc06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc020410c:	8082                	ret
ffffffffc020410e:	e42a                	sd	a0,8(sp)
ffffffffc0204110:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc0204112:	ff2fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0204116:	6522                	ld	a0,8(sp)
ffffffffc0204118:	6682                	ld	a3,0(sp)
ffffffffc020411a:	4605                	li	a2,1
ffffffffc020411c:	bf6d                	j	ffffffffc02040d6 <proc_run+0x1a>

ffffffffc020411e <do_fork>:
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc020411e:	000e1797          	auipc	a5,0xe1
ffffffffc0204122:	1327a783          	lw	a5,306(a5) # ffffffffc02e5250 <nr_process>
{
ffffffffc0204126:	7159                	addi	sp,sp,-112
ffffffffc0204128:	e4ce                	sd	s3,72(sp)
ffffffffc020412a:	f486                	sd	ra,104(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020412c:	6985                	lui	s3,0x1
ffffffffc020412e:	3737db63          	bge	a5,s3,ffffffffc02044a4 <do_fork+0x386>
ffffffffc0204132:	f0a2                	sd	s0,96(sp)
ffffffffc0204134:	eca6                	sd	s1,88(sp)
ffffffffc0204136:	e8ca                	sd	s2,80(sp)
ffffffffc0204138:	e86a                	sd	s10,16(sp)
ffffffffc020413a:	892e                	mv	s2,a1
ffffffffc020413c:	84b2                	mv	s1,a2
ffffffffc020413e:	8d2a                	mv	s10,a0
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204140:	e43ff0ef          	jal	ffffffffc0203f82 <alloc_proc>
ffffffffc0204144:	842a                	mv	s0,a0
ffffffffc0204146:	2e050c63          	beqz	a0,ffffffffc020443e <do_fork+0x320>
ffffffffc020414a:	f45e                	sd	s7,40(sp)
    {
        goto fork_out;
    }

    proc->parent = current;
ffffffffc020414c:	000e1b97          	auipc	s7,0xe1
ffffffffc0204150:	10cb8b93          	addi	s7,s7,268 # ffffffffc02e5258 <current>
ffffffffc0204154:	000bb783          	ld	a5,0(s7)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204158:	4509                	li	a0,2
    proc->parent = current;
ffffffffc020415a:	f01c                	sd	a5,32(s0)
    current->wait_state = 0;
ffffffffc020415c:	0e07a623          	sw	zero,236(a5)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204160:	e56fe0ef          	jal	ffffffffc02027b6 <alloc_pages>
    if (page != NULL)
ffffffffc0204164:	2c050963          	beqz	a0,ffffffffc0204436 <do_fork+0x318>
ffffffffc0204168:	e0d2                	sd	s4,64(sp)
    return page - pages + nbase;
ffffffffc020416a:	000e1a17          	auipc	s4,0xe1
ffffffffc020416e:	0dea0a13          	addi	s4,s4,222 # ffffffffc02e5248 <pages>
ffffffffc0204172:	000a3783          	ld	a5,0(s4)
ffffffffc0204176:	fc56                	sd	s5,56(sp)
ffffffffc0204178:	00004a97          	auipc	s5,0x4
ffffffffc020417c:	280a8a93          	addi	s5,s5,640 # ffffffffc02083f8 <nbase>
ffffffffc0204180:	000ab703          	ld	a4,0(s5)
ffffffffc0204184:	40f506b3          	sub	a3,a0,a5
ffffffffc0204188:	f85a                	sd	s6,48(sp)
    return KADDR(page2pa(page));
ffffffffc020418a:	000e1b17          	auipc	s6,0xe1
ffffffffc020418e:	0b6b0b13          	addi	s6,s6,182 # ffffffffc02e5240 <npage>
ffffffffc0204192:	ec66                	sd	s9,24(sp)
    return page - pages + nbase;
ffffffffc0204194:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204196:	5cfd                	li	s9,-1
ffffffffc0204198:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc020419c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020419e:	00ccdc93          	srli	s9,s9,0xc
ffffffffc02041a2:	0196f633          	and	a2,a3,s9
ffffffffc02041a6:	f062                	sd	s8,32(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02041a8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02041aa:	32f67763          	bgeu	a2,a5,ffffffffc02044d8 <do_fork+0x3ba>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02041ae:	000bb603          	ld	a2,0(s7)
ffffffffc02041b2:	000e1b97          	auipc	s7,0xe1
ffffffffc02041b6:	086b8b93          	addi	s7,s7,134 # ffffffffc02e5238 <va_pa_offset>
ffffffffc02041ba:	000bb783          	ld	a5,0(s7)
ffffffffc02041be:	02863c03          	ld	s8,40(a2)
ffffffffc02041c2:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02041c4:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc02041c6:	020c0863          	beqz	s8,ffffffffc02041f6 <do_fork+0xd8>
    if (clone_flags & CLONE_VM)
ffffffffc02041ca:	100d7793          	andi	a5,s10,256
ffffffffc02041ce:	18078863          	beqz	a5,ffffffffc020435e <do_fork+0x240>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc02041d2:	030c2703          	lw	a4,48(s8) # 200030 <_binary_obj___user_matrix_out_size+0x1f4570>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041d6:	018c3783          	ld	a5,24(s8)
ffffffffc02041da:	c02006b7          	lui	a3,0xc0200
ffffffffc02041de:	2705                	addiw	a4,a4,1
ffffffffc02041e0:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc02041e4:	03843423          	sd	s8,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041e8:	30d7e463          	bltu	a5,a3,ffffffffc02044f0 <do_fork+0x3d2>
ffffffffc02041ec:	000bb703          	ld	a4,0(s7)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041f0:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02041f2:	8f99                	sub	a5,a5,a4
ffffffffc02041f4:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02041f6:	6789                	lui	a5,0x2
ffffffffc02041f8:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x75d0>
ffffffffc02041fc:	96be                	add	a3,a3,a5
ffffffffc02041fe:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204200:	87b6                	mv	a5,a3
ffffffffc0204202:	12048713          	addi	a4,s1,288
ffffffffc0204206:	6890                	ld	a2,16(s1)
ffffffffc0204208:	6088                	ld	a0,0(s1)
ffffffffc020420a:	648c                	ld	a1,8(s1)
ffffffffc020420c:	eb90                	sd	a2,16(a5)
ffffffffc020420e:	e388                	sd	a0,0(a5)
ffffffffc0204210:	e78c                	sd	a1,8(a5)
ffffffffc0204212:	6c90                	ld	a2,24(s1)
ffffffffc0204214:	02048493          	addi	s1,s1,32
ffffffffc0204218:	02078793          	addi	a5,a5,32
ffffffffc020421c:	fec7bc23          	sd	a2,-8(a5)
ffffffffc0204220:	fee493e3          	bne	s1,a4,ffffffffc0204206 <do_fork+0xe8>
    proc->tf->gpr.a0 = 0;
ffffffffc0204224:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204228:	22090163          	beqz	s2,ffffffffc020444a <do_fork+0x32c>
ffffffffc020422c:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204230:	00000797          	auipc	a5,0x0
ffffffffc0204234:	e0878793          	addi	a5,a5,-504 # ffffffffc0204038 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204238:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020423a:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020423c:	100027f3          	csrr	a5,sstatus
ffffffffc0204240:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204242:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204244:	22079263          	bnez	a5,ffffffffc0204468 <do_fork+0x34a>
    if (++last_pid >= MAX_PID)
ffffffffc0204248:	000dd517          	auipc	a0,0xdd
ffffffffc020424c:	aec52503          	lw	a0,-1300(a0) # ffffffffc02e0d34 <last_pid.1>
ffffffffc0204250:	6789                	lui	a5,0x2
ffffffffc0204252:	2505                	addiw	a0,a0,1
ffffffffc0204254:	000dd717          	auipc	a4,0xdd
ffffffffc0204258:	aea72023          	sw	a0,-1312(a4) # ffffffffc02e0d34 <last_pid.1>
ffffffffc020425c:	22f55563          	bge	a0,a5,ffffffffc0204486 <do_fork+0x368>
    if (last_pid >= next_safe)
ffffffffc0204260:	000dd797          	auipc	a5,0xdd
ffffffffc0204264:	ad07a783          	lw	a5,-1328(a5) # ffffffffc02e0d30 <next_safe.0>
ffffffffc0204268:	000e1497          	auipc	s1,0xe1
ffffffffc020426c:	ee848493          	addi	s1,s1,-280 # ffffffffc02e5150 <proc_list>
ffffffffc0204270:	06f54563          	blt	a0,a5,ffffffffc02042da <do_fork+0x1bc>
    return listelm->next;
ffffffffc0204274:	000e1497          	auipc	s1,0xe1
ffffffffc0204278:	edc48493          	addi	s1,s1,-292 # ffffffffc02e5150 <proc_list>
ffffffffc020427c:	0084b883          	ld	a7,8(s1)
        next_safe = MAX_PID;
ffffffffc0204280:	6789                	lui	a5,0x2
ffffffffc0204282:	000dd717          	auipc	a4,0xdd
ffffffffc0204286:	aaf72723          	sw	a5,-1362(a4) # ffffffffc02e0d30 <next_safe.0>
ffffffffc020428a:	86aa                	mv	a3,a0
ffffffffc020428c:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020428e:	04988063          	beq	a7,s1,ffffffffc02042ce <do_fork+0x1b0>
ffffffffc0204292:	882e                	mv	a6,a1
ffffffffc0204294:	87c6                	mv	a5,a7
ffffffffc0204296:	6609                	lui	a2,0x2
ffffffffc0204298:	a811                	j	ffffffffc02042ac <do_fork+0x18e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020429a:	00e6d663          	bge	a3,a4,ffffffffc02042a6 <do_fork+0x188>
ffffffffc020429e:	00c75463          	bge	a4,a2,ffffffffc02042a6 <do_fork+0x188>
                next_safe = proc->pid;
ffffffffc02042a2:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042a4:	4805                	li	a6,1
ffffffffc02042a6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02042a8:	00978d63          	beq	a5,s1,ffffffffc02042c2 <do_fork+0x1a4>
            if (proc->pid == last_pid)
ffffffffc02042ac:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x7574>
ffffffffc02042b0:	fed715e3          	bne	a4,a3,ffffffffc020429a <do_fork+0x17c>
                if (++last_pid >= next_safe)
ffffffffc02042b4:	2685                	addiw	a3,a3,1
ffffffffc02042b6:	1ec6d163          	bge	a3,a2,ffffffffc0204498 <do_fork+0x37a>
ffffffffc02042ba:	679c                	ld	a5,8(a5)
ffffffffc02042bc:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02042be:	fe9797e3          	bne	a5,s1,ffffffffc02042ac <do_fork+0x18e>
ffffffffc02042c2:	00080663          	beqz	a6,ffffffffc02042ce <do_fork+0x1b0>
ffffffffc02042c6:	000dd797          	auipc	a5,0xdd
ffffffffc02042ca:	a6c7a523          	sw	a2,-1430(a5) # ffffffffc02e0d30 <next_safe.0>
ffffffffc02042ce:	c591                	beqz	a1,ffffffffc02042da <do_fork+0x1bc>
ffffffffc02042d0:	000dd797          	auipc	a5,0xdd
ffffffffc02042d4:	a6d7a223          	sw	a3,-1436(a5) # ffffffffc02e0d34 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042d8:	8536                	mv	a0,a3
    copy_thread(proc, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
ffffffffc02042da:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02042dc:	45a9                	li	a1,10
ffffffffc02042de:	089010ef          	jal	ffffffffc0205b66 <hash32>
ffffffffc02042e2:	02051793          	slli	a5,a0,0x20
ffffffffc02042e6:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02042ea:	000dd797          	auipc	a5,0xdd
ffffffffc02042ee:	e6678793          	addi	a5,a5,-410 # ffffffffc02e1150 <hash_list>
ffffffffc02042f2:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02042f4:	6518                	ld	a4,8(a0)
ffffffffc02042f6:	0d840793          	addi	a5,s0,216
ffffffffc02042fa:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02042fc:	e31c                	sd	a5,0(a4)
ffffffffc02042fe:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204300:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204302:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204306:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc0204308:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020430a:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc020430c:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204310:	7b74                	ld	a3,240(a4)
ffffffffc0204312:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc0204314:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204316:	e464                	sd	s1,200(s0)
ffffffffc0204318:	10d43023          	sd	a3,256(s0)
ffffffffc020431c:	c299                	beqz	a3,ffffffffc0204322 <do_fork+0x204>
        proc->optr->yptr = proc;
ffffffffc020431e:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc0204320:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc0204322:	000e1797          	auipc	a5,0xe1
ffffffffc0204326:	f2e7a783          	lw	a5,-210(a5) # ffffffffc02e5250 <nr_process>
    proc->parent->cptr = proc;
ffffffffc020432a:	fb60                	sd	s0,240(a4)
    nr_process++;
ffffffffc020432c:	2785                	addiw	a5,a5,1
ffffffffc020432e:	000e1717          	auipc	a4,0xe1
ffffffffc0204332:	f2f72123          	sw	a5,-222(a4) # ffffffffc02e5250 <nr_process>
    if (flag)
ffffffffc0204336:	14091e63          	bnez	s2,ffffffffc0204492 <do_fork+0x374>
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc020433a:	8522                	mv	a0,s0
ffffffffc020433c:	0a2010ef          	jal	ffffffffc02053de <wakeup_proc>
    ret = proc->pid;
ffffffffc0204340:	4048                	lw	a0,4(s0)
ffffffffc0204342:	64e6                	ld	s1,88(sp)
ffffffffc0204344:	7406                	ld	s0,96(sp)
ffffffffc0204346:	6946                	ld	s2,80(sp)
ffffffffc0204348:	6a06                	ld	s4,64(sp)
ffffffffc020434a:	7ae2                	ld	s5,56(sp)
ffffffffc020434c:	7b42                	ld	s6,48(sp)
ffffffffc020434e:	7ba2                	ld	s7,40(sp)
ffffffffc0204350:	7c02                	ld	s8,32(sp)
ffffffffc0204352:	6ce2                	ld	s9,24(sp)
ffffffffc0204354:	6d42                	ld	s10,16(sp)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc0204356:	70a6                	ld	ra,104(sp)
ffffffffc0204358:	69a6                	ld	s3,72(sp)
ffffffffc020435a:	6165                	addi	sp,sp,112
ffffffffc020435c:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc020435e:	e43a                	sd	a4,8(sp)
ffffffffc0204360:	df7fc0ef          	jal	ffffffffc0201156 <mm_create>
ffffffffc0204364:	8d2a                	mv	s10,a0
ffffffffc0204366:	c959                	beqz	a0,ffffffffc02043fc <do_fork+0x2de>
    if ((page = alloc_page()) == NULL)
ffffffffc0204368:	4505                	li	a0,1
ffffffffc020436a:	c4cfe0ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc020436e:	c541                	beqz	a0,ffffffffc02043f6 <do_fork+0x2d8>
    return page - pages + nbase;
ffffffffc0204370:	000a3683          	ld	a3,0(s4)
ffffffffc0204374:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc0204376:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc020437a:	40d506b3          	sub	a3,a0,a3
ffffffffc020437e:	8699                	srai	a3,a3,0x6
ffffffffc0204380:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0204382:	0196fcb3          	and	s9,a3,s9
    return page2ppn(page) << PGSHIFT;
ffffffffc0204386:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204388:	14fcf863          	bgeu	s9,a5,ffffffffc02044d8 <do_fork+0x3ba>
ffffffffc020438c:	000bb783          	ld	a5,0(s7)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204390:	000e1597          	auipc	a1,0xe1
ffffffffc0204394:	ea05b583          	ld	a1,-352(a1) # ffffffffc02e5230 <boot_pgdir_va>
ffffffffc0204398:	864e                	mv	a2,s3
ffffffffc020439a:	00f689b3          	add	s3,a3,a5
ffffffffc020439e:	854e                	mv	a0,s3
ffffffffc02043a0:	3e2010ef          	jal	ffffffffc0205782 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02043a4:	038c0c93          	addi	s9,s8,56
    mm->pgdir = pgdir;
ffffffffc02043a8:	013d3c23          	sd	s3,24(s10)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02043ac:	4785                	li	a5,1
ffffffffc02043ae:	40fcb7af          	amoor.d	a5,a5,(s9)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc02043b2:	03f79713          	slli	a4,a5,0x3f
ffffffffc02043b6:	03f75793          	srli	a5,a4,0x3f
ffffffffc02043ba:	4985                	li	s3,1
ffffffffc02043bc:	cb91                	beqz	a5,ffffffffc02043d0 <do_fork+0x2b2>
    {
        schedule();
ffffffffc02043be:	118010ef          	jal	ffffffffc02054d6 <schedule>
ffffffffc02043c2:	413cb7af          	amoor.d	a5,s3,(s9)
    while (!try_lock(lock))
ffffffffc02043c6:	03f79713          	slli	a4,a5,0x3f
ffffffffc02043ca:	03f75793          	srli	a5,a4,0x3f
ffffffffc02043ce:	fbe5                	bnez	a5,ffffffffc02043be <do_fork+0x2a0>
        ret = dup_mmap(mm, oldmm);
ffffffffc02043d0:	85e2                	mv	a1,s8
ffffffffc02043d2:	856a                	mv	a0,s10
ffffffffc02043d4:	fdffc0ef          	jal	ffffffffc02013b2 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02043d8:	57f9                	li	a5,-2
ffffffffc02043da:	60fcb7af          	amoand.d	a5,a5,(s9)
ffffffffc02043de:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc02043e0:	12078563          	beqz	a5,ffffffffc020450a <do_fork+0x3ec>
    if ((mm = mm_create()) == NULL)
ffffffffc02043e4:	8c6a                	mv	s8,s10
    if (ret != 0)
ffffffffc02043e6:	de0506e3          	beqz	a0,ffffffffc02041d2 <do_fork+0xb4>
    exit_mmap(mm);
ffffffffc02043ea:	856a                	mv	a0,s10
ffffffffc02043ec:	85efd0ef          	jal	ffffffffc020144a <exit_mmap>
    put_pgdir(mm);
ffffffffc02043f0:	856a                	mv	a0,s10
ffffffffc02043f2:	c55ff0ef          	jal	ffffffffc0204046 <put_pgdir>
    mm_destroy(mm);
ffffffffc02043f6:	856a                	mv	a0,s10
ffffffffc02043f8:	e9dfc0ef          	jal	ffffffffc0201294 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02043fc:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02043fe:	c02007b7          	lui	a5,0xc0200
ffffffffc0204402:	0af6ef63          	bltu	a3,a5,ffffffffc02044c0 <do_fork+0x3a2>
ffffffffc0204406:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage)
ffffffffc020440a:	000b3703          	ld	a4,0(s6)
    return pa2page(PADDR(kva));
ffffffffc020440e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204412:	83b1                	srli	a5,a5,0xc
ffffffffc0204414:	08e7fa63          	bgeu	a5,a4,ffffffffc02044a8 <do_fork+0x38a>
    return &pages[PPN(pa) - nbase];
ffffffffc0204418:	000ab703          	ld	a4,0(s5)
ffffffffc020441c:	000a3503          	ld	a0,0(s4)
ffffffffc0204420:	4589                	li	a1,2
ffffffffc0204422:	8f99                	sub	a5,a5,a4
ffffffffc0204424:	079a                	slli	a5,a5,0x6
ffffffffc0204426:	953e                	add	a0,a0,a5
ffffffffc0204428:	bc8fe0ef          	jal	ffffffffc02027f0 <free_pages>
}
ffffffffc020442c:	6a06                	ld	s4,64(sp)
ffffffffc020442e:	7ae2                	ld	s5,56(sp)
ffffffffc0204430:	7b42                	ld	s6,48(sp)
ffffffffc0204432:	7c02                	ld	s8,32(sp)
ffffffffc0204434:	6ce2                	ld	s9,24(sp)
    kfree(proc);
ffffffffc0204436:	8522                	mv	a0,s0
ffffffffc0204438:	f78fd0ef          	jal	ffffffffc0201bb0 <kfree>
ffffffffc020443c:	7ba2                	ld	s7,40(sp)
ffffffffc020443e:	7406                	ld	s0,96(sp)
ffffffffc0204440:	64e6                	ld	s1,88(sp)
ffffffffc0204442:	6946                	ld	s2,80(sp)
ffffffffc0204444:	6d42                	ld	s10,16(sp)
    ret = -E_NO_MEM;
ffffffffc0204446:	5571                	li	a0,-4
    return ret;
ffffffffc0204448:	b739                	j	ffffffffc0204356 <do_fork+0x238>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020444a:	8936                	mv	s2,a3
ffffffffc020444c:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204450:	00000797          	auipc	a5,0x0
ffffffffc0204454:	be878793          	addi	a5,a5,-1048 # ffffffffc0204038 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204458:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020445a:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020445c:	100027f3          	csrr	a5,sstatus
ffffffffc0204460:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204462:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204464:	de0782e3          	beqz	a5,ffffffffc0204248 <do_fork+0x12a>
        intr_disable();
ffffffffc0204468:	c9cfc0ef          	jal	ffffffffc0200904 <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc020446c:	000dd517          	auipc	a0,0xdd
ffffffffc0204470:	8c852503          	lw	a0,-1848(a0) # ffffffffc02e0d34 <last_pid.1>
ffffffffc0204474:	6789                	lui	a5,0x2
        return 1;
ffffffffc0204476:	4905                	li	s2,1
ffffffffc0204478:	2505                	addiw	a0,a0,1
ffffffffc020447a:	000dd717          	auipc	a4,0xdd
ffffffffc020447e:	8aa72d23          	sw	a0,-1862(a4) # ffffffffc02e0d34 <last_pid.1>
ffffffffc0204482:	dcf54fe3          	blt	a0,a5,ffffffffc0204260 <do_fork+0x142>
        last_pid = 1;
ffffffffc0204486:	4505                	li	a0,1
ffffffffc0204488:	000dd797          	auipc	a5,0xdd
ffffffffc020448c:	8aa7a623          	sw	a0,-1876(a5) # ffffffffc02e0d34 <last_pid.1>
        goto inside;
ffffffffc0204490:	b3d5                	j	ffffffffc0204274 <do_fork+0x156>
        intr_enable();
ffffffffc0204492:	c6cfc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0204496:	b555                	j	ffffffffc020433a <do_fork+0x21c>
                    if (last_pid >= MAX_PID)
ffffffffc0204498:	6789                	lui	a5,0x2
ffffffffc020449a:	00f6c363          	blt	a3,a5,ffffffffc02044a0 <do_fork+0x382>
                        last_pid = 1;
ffffffffc020449e:	4685                	li	a3,1
                    goto repeat;
ffffffffc02044a0:	4585                	li	a1,1
ffffffffc02044a2:	b3f5                	j	ffffffffc020428e <do_fork+0x170>
    int ret = -E_NO_FREE_PROC;
ffffffffc02044a4:	556d                	li	a0,-5
ffffffffc02044a6:	bd45                	j	ffffffffc0204356 <do_fork+0x238>
        panic("pa2page called with invalid pa");
ffffffffc02044a8:	00002617          	auipc	a2,0x2
ffffffffc02044ac:	09060613          	addi	a2,a2,144 # ffffffffc0206538 <etext+0x9bc>
ffffffffc02044b0:	06900593          	li	a1,105
ffffffffc02044b4:	00002517          	auipc	a0,0x2
ffffffffc02044b8:	0a450513          	addi	a0,a0,164 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02044bc:	d71fb0ef          	jal	ffffffffc020022c <__panic>
    return pa2page(PADDR(kva));
ffffffffc02044c0:	00002617          	auipc	a2,0x2
ffffffffc02044c4:	41860613          	addi	a2,a2,1048 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc02044c8:	07700593          	li	a1,119
ffffffffc02044cc:	00002517          	auipc	a0,0x2
ffffffffc02044d0:	08c50513          	addi	a0,a0,140 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02044d4:	d59fb0ef          	jal	ffffffffc020022c <__panic>
    return KADDR(page2pa(page));
ffffffffc02044d8:	00002617          	auipc	a2,0x2
ffffffffc02044dc:	0a060613          	addi	a2,a2,160 # ffffffffc0206578 <etext+0x9fc>
ffffffffc02044e0:	07100593          	li	a1,113
ffffffffc02044e4:	00002517          	auipc	a0,0x2
ffffffffc02044e8:	07450513          	addi	a0,a0,116 # ffffffffc0206558 <etext+0x9dc>
ffffffffc02044ec:	d41fb0ef          	jal	ffffffffc020022c <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc02044f0:	86be                	mv	a3,a5
ffffffffc02044f2:	00002617          	auipc	a2,0x2
ffffffffc02044f6:	3e660613          	addi	a2,a2,998 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc02044fa:	17a00593          	li	a1,378
ffffffffc02044fe:	00003517          	auipc	a0,0x3
ffffffffc0204502:	e0250513          	addi	a0,a0,-510 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204506:	d27fb0ef          	jal	ffffffffc020022c <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc020450a:	00003617          	auipc	a2,0x3
ffffffffc020450e:	dce60613          	addi	a2,a2,-562 # ffffffffc02072d8 <etext+0x175c>
ffffffffc0204512:	04000593          	li	a1,64
ffffffffc0204516:	00003517          	auipc	a0,0x3
ffffffffc020451a:	dd250513          	addi	a0,a0,-558 # ffffffffc02072e8 <etext+0x176c>
ffffffffc020451e:	d0ffb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204522 <kernel_thread>:
{
ffffffffc0204522:	7129                	addi	sp,sp,-320
ffffffffc0204524:	fa22                	sd	s0,304(sp)
ffffffffc0204526:	f626                	sd	s1,296(sp)
ffffffffc0204528:	f24a                	sd	s2,288(sp)
ffffffffc020452a:	842a                	mv	s0,a0
ffffffffc020452c:	84ae                	mv	s1,a1
ffffffffc020452e:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204530:	850a                	mv	a0,sp
ffffffffc0204532:	12000613          	li	a2,288
ffffffffc0204536:	4581                	li	a1,0
{
ffffffffc0204538:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020453a:	236010ef          	jal	ffffffffc0205770 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020453e:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204540:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204542:	100027f3          	csrr	a5,sstatus
ffffffffc0204546:	edd7f793          	andi	a5,a5,-291
ffffffffc020454a:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020454e:	860a                	mv	a2,sp
ffffffffc0204550:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204554:	00000717          	auipc	a4,0x0
ffffffffc0204558:	9bc70713          	addi	a4,a4,-1604 # ffffffffc0203f10 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020455c:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020455e:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204560:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204562:	bbdff0ef          	jal	ffffffffc020411e <do_fork>
}
ffffffffc0204566:	70f2                	ld	ra,312(sp)
ffffffffc0204568:	7452                	ld	s0,304(sp)
ffffffffc020456a:	74b2                	ld	s1,296(sp)
ffffffffc020456c:	7912                	ld	s2,288(sp)
ffffffffc020456e:	6131                	addi	sp,sp,320
ffffffffc0204570:	8082                	ret

ffffffffc0204572 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc0204572:	7179                	addi	sp,sp,-48
ffffffffc0204574:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204576:	000e1417          	auipc	s0,0xe1
ffffffffc020457a:	ce240413          	addi	s0,s0,-798 # ffffffffc02e5258 <current>
ffffffffc020457e:	601c                	ld	a5,0(s0)
ffffffffc0204580:	000e1717          	auipc	a4,0xe1
ffffffffc0204584:	ce873703          	ld	a4,-792(a4) # ffffffffc02e5268 <idleproc>
{
ffffffffc0204588:	f406                	sd	ra,40(sp)
ffffffffc020458a:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc020458c:	0ce78b63          	beq	a5,a4,ffffffffc0204662 <do_exit+0xf0>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc0204590:	000e1497          	auipc	s1,0xe1
ffffffffc0204594:	cd048493          	addi	s1,s1,-816 # ffffffffc02e5260 <initproc>
ffffffffc0204598:	6098                	ld	a4,0(s1)
ffffffffc020459a:	e84a                	sd	s2,16(sp)
ffffffffc020459c:	0ee78a63          	beq	a5,a4,ffffffffc0204690 <do_exit+0x11e>
ffffffffc02045a0:	892a                	mv	s2,a0
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc02045a2:	7788                	ld	a0,40(a5)
    if (mm != NULL)
ffffffffc02045a4:	c115                	beqz	a0,ffffffffc02045c8 <do_exit+0x56>
ffffffffc02045a6:	000e1797          	auipc	a5,0xe1
ffffffffc02045aa:	c827b783          	ld	a5,-894(a5) # ffffffffc02e5228 <boot_pgdir_pa>
ffffffffc02045ae:	577d                	li	a4,-1
ffffffffc02045b0:	177e                	slli	a4,a4,0x3f
ffffffffc02045b2:	83b1                	srli	a5,a5,0xc
ffffffffc02045b4:	8fd9                	or	a5,a5,a4
ffffffffc02045b6:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02045ba:	591c                	lw	a5,48(a0)
ffffffffc02045bc:	37fd                	addiw	a5,a5,-1
ffffffffc02045be:	d91c                	sw	a5,48(a0)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc02045c0:	cfd5                	beqz	a5,ffffffffc020467c <do_exit+0x10a>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc02045c2:	601c                	ld	a5,0(s0)
ffffffffc02045c4:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc02045c8:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc02045ca:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02045ce:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045d0:	100027f3          	csrr	a5,sstatus
ffffffffc02045d4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02045d6:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02045d8:	ebe1                	bnez	a5,ffffffffc02046a8 <do_exit+0x136>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc02045da:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc02045dc:	800007b7          	lui	a5,0x80000
ffffffffc02045e0:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4541>
        proc = current->parent;
ffffffffc02045e2:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc02045e4:	0ec52703          	lw	a4,236(a0)
ffffffffc02045e8:	0cf70463          	beq	a4,a5,ffffffffc02046b0 <do_exit+0x13e>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc02045ec:	6018                	ld	a4,0(s0)
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc02045ee:	800005b7          	lui	a1,0x80000
ffffffffc02045f2:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4541>
        while (current->cptr != NULL)
ffffffffc02045f4:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02045f6:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc02045f8:	e789                	bnez	a5,ffffffffc0204602 <do_exit+0x90>
ffffffffc02045fa:	a83d                	j	ffffffffc0204638 <do_exit+0xc6>
ffffffffc02045fc:	6018                	ld	a4,0(s0)
ffffffffc02045fe:	7b7c                	ld	a5,240(a4)
ffffffffc0204600:	cf85                	beqz	a5,ffffffffc0204638 <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc0204602:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204606:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204608:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc020460a:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020460e:	7978                	ld	a4,240(a0)
ffffffffc0204610:	10e7b023          	sd	a4,256(a5)
ffffffffc0204614:	c311                	beqz	a4,ffffffffc0204618 <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc0204616:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204618:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc020461a:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc020461c:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020461e:	fcc71fe3          	bne	a4,a2,ffffffffc02045fc <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204622:	0ec52783          	lw	a5,236(a0)
ffffffffc0204626:	fcb79be3          	bne	a5,a1,ffffffffc02045fc <do_exit+0x8a>
                {
                    wakeup_proc(initproc);
ffffffffc020462a:	5b5000ef          	jal	ffffffffc02053de <wakeup_proc>
ffffffffc020462e:	800005b7          	lui	a1,0x80000
ffffffffc0204632:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4541>
ffffffffc0204634:	460d                	li	a2,3
ffffffffc0204636:	b7d9                	j	ffffffffc02045fc <do_exit+0x8a>
    if (flag)
ffffffffc0204638:	02091263          	bnez	s2,ffffffffc020465c <do_exit+0xea>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc020463c:	69b000ef          	jal	ffffffffc02054d6 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204640:	601c                	ld	a5,0(s0)
ffffffffc0204642:	00003617          	auipc	a2,0x3
ffffffffc0204646:	cf660613          	addi	a2,a2,-778 # ffffffffc0207338 <etext+0x17bc>
ffffffffc020464a:	22000593          	li	a1,544
ffffffffc020464e:	43d4                	lw	a3,4(a5)
ffffffffc0204650:	00003517          	auipc	a0,0x3
ffffffffc0204654:	cb050513          	addi	a0,a0,-848 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204658:	bd5fb0ef          	jal	ffffffffc020022c <__panic>
        intr_enable();
ffffffffc020465c:	aa2fc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0204660:	bff1                	j	ffffffffc020463c <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc0204662:	00003617          	auipc	a2,0x3
ffffffffc0204666:	cb660613          	addi	a2,a2,-842 # ffffffffc0207318 <etext+0x179c>
ffffffffc020466a:	1ec00593          	li	a1,492
ffffffffc020466e:	00003517          	auipc	a0,0x3
ffffffffc0204672:	c9250513          	addi	a0,a0,-878 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204676:	e84a                	sd	s2,16(sp)
ffffffffc0204678:	bb5fb0ef          	jal	ffffffffc020022c <__panic>
            exit_mmap(mm);
ffffffffc020467c:	e42a                	sd	a0,8(sp)
ffffffffc020467e:	dcdfc0ef          	jal	ffffffffc020144a <exit_mmap>
            put_pgdir(mm);
ffffffffc0204682:	6522                	ld	a0,8(sp)
ffffffffc0204684:	9c3ff0ef          	jal	ffffffffc0204046 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204688:	6522                	ld	a0,8(sp)
ffffffffc020468a:	c0bfc0ef          	jal	ffffffffc0201294 <mm_destroy>
ffffffffc020468e:	bf15                	j	ffffffffc02045c2 <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc0204690:	00003617          	auipc	a2,0x3
ffffffffc0204694:	c9860613          	addi	a2,a2,-872 # ffffffffc0207328 <etext+0x17ac>
ffffffffc0204698:	1f000593          	li	a1,496
ffffffffc020469c:	00003517          	auipc	a0,0x3
ffffffffc02046a0:	c6450513          	addi	a0,a0,-924 # ffffffffc0207300 <etext+0x1784>
ffffffffc02046a4:	b89fb0ef          	jal	ffffffffc020022c <__panic>
        intr_disable();
ffffffffc02046a8:	a5cfc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc02046ac:	4905                	li	s2,1
ffffffffc02046ae:	b735                	j	ffffffffc02045da <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc02046b0:	52f000ef          	jal	ffffffffc02053de <wakeup_proc>
ffffffffc02046b4:	bf25                	j	ffffffffc02045ec <do_exit+0x7a>

ffffffffc02046b6 <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc02046b6:	7179                	addi	sp,sp,-48
ffffffffc02046b8:	ec26                	sd	s1,24(sp)
ffffffffc02046ba:	e84a                	sd	s2,16(sp)
ffffffffc02046bc:	e44e                	sd	s3,8(sp)
ffffffffc02046be:	f406                	sd	ra,40(sp)
ffffffffc02046c0:	f022                	sd	s0,32(sp)
ffffffffc02046c2:	84aa                	mv	s1,a0
ffffffffc02046c4:	892e                	mv	s2,a1
ffffffffc02046c6:	000e1997          	auipc	s3,0xe1
ffffffffc02046ca:	b9298993          	addi	s3,s3,-1134 # ffffffffc02e5258 <current>

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0)
ffffffffc02046ce:	cd19                	beqz	a0,ffffffffc02046ec <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc02046d0:	6789                	lui	a5,0x2
ffffffffc02046d2:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x74b2>
ffffffffc02046d4:	fff5071b          	addiw	a4,a0,-1
ffffffffc02046d8:	12e7f563          	bgeu	a5,a4,ffffffffc0204802 <do_wait.part.0+0x14c>
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc02046dc:	70a2                	ld	ra,40(sp)
ffffffffc02046de:	7402                	ld	s0,32(sp)
ffffffffc02046e0:	64e2                	ld	s1,24(sp)
ffffffffc02046e2:	6942                	ld	s2,16(sp)
ffffffffc02046e4:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc02046e6:	5579                	li	a0,-2
}
ffffffffc02046e8:	6145                	addi	sp,sp,48
ffffffffc02046ea:	8082                	ret
        proc = current->cptr;
ffffffffc02046ec:	0009b703          	ld	a4,0(s3)
ffffffffc02046f0:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc02046f2:	d46d                	beqz	s0,ffffffffc02046dc <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046f4:	468d                	li	a3,3
ffffffffc02046f6:	a021                	j	ffffffffc02046fe <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc02046f8:	10043403          	ld	s0,256(s0)
ffffffffc02046fc:	c075                	beqz	s0,ffffffffc02047e0 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046fe:	401c                	lw	a5,0(s0)
ffffffffc0204700:	fed79ce3          	bne	a5,a3,ffffffffc02046f8 <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc0204704:	000e1797          	auipc	a5,0xe1
ffffffffc0204708:	b647b783          	ld	a5,-1180(a5) # ffffffffc02e5268 <idleproc>
ffffffffc020470c:	14878263          	beq	a5,s0,ffffffffc0204850 <do_wait.part.0+0x19a>
ffffffffc0204710:	000e1797          	auipc	a5,0xe1
ffffffffc0204714:	b507b783          	ld	a5,-1200(a5) # ffffffffc02e5260 <initproc>
ffffffffc0204718:	12f40c63          	beq	s0,a5,ffffffffc0204850 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc020471c:	00090663          	beqz	s2,ffffffffc0204728 <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc0204720:	0e842783          	lw	a5,232(s0)
ffffffffc0204724:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204728:	100027f3          	csrr	a5,sstatus
ffffffffc020472c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020472e:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204730:	10079963          	bnez	a5,ffffffffc0204842 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204734:	6c74                	ld	a3,216(s0)
ffffffffc0204736:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc0204738:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc020473c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020473e:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204740:	6474                	ld	a3,200(s0)
ffffffffc0204742:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc0204744:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204746:	e314                	sd	a3,0(a4)
ffffffffc0204748:	c789                	beqz	a5,ffffffffc0204752 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc020474a:	7c78                	ld	a4,248(s0)
ffffffffc020474c:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc020474e:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc0204752:	7c78                	ld	a4,248(s0)
ffffffffc0204754:	c36d                	beqz	a4,ffffffffc0204836 <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc0204756:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc020475a:	000e1797          	auipc	a5,0xe1
ffffffffc020475e:	af67a783          	lw	a5,-1290(a5) # ffffffffc02e5250 <nr_process>
ffffffffc0204762:	37fd                	addiw	a5,a5,-1
ffffffffc0204764:	000e1717          	auipc	a4,0xe1
ffffffffc0204768:	aef72623          	sw	a5,-1300(a4) # ffffffffc02e5250 <nr_process>
    if (flag)
ffffffffc020476c:	e271                	bnez	a2,ffffffffc0204830 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020476e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204770:	c02007b7          	lui	a5,0xc0200
ffffffffc0204774:	10f6e663          	bltu	a3,a5,ffffffffc0204880 <do_wait.part.0+0x1ca>
ffffffffc0204778:	000e1717          	auipc	a4,0xe1
ffffffffc020477c:	ac073703          	ld	a4,-1344(a4) # ffffffffc02e5238 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0204780:	000e1797          	auipc	a5,0xe1
ffffffffc0204784:	ac07b783          	ld	a5,-1344(a5) # ffffffffc02e5240 <npage>
    return pa2page(PADDR(kva));
ffffffffc0204788:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc020478a:	82b1                	srli	a3,a3,0xc
ffffffffc020478c:	0cf6fe63          	bgeu	a3,a5,ffffffffc0204868 <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204790:	00004797          	auipc	a5,0x4
ffffffffc0204794:	c687b783          	ld	a5,-920(a5) # ffffffffc02083f8 <nbase>
ffffffffc0204798:	000e1517          	auipc	a0,0xe1
ffffffffc020479c:	ab053503          	ld	a0,-1360(a0) # ffffffffc02e5248 <pages>
ffffffffc02047a0:	4589                	li	a1,2
ffffffffc02047a2:	8e9d                	sub	a3,a3,a5
ffffffffc02047a4:	069a                	slli	a3,a3,0x6
ffffffffc02047a6:	9536                	add	a0,a0,a3
ffffffffc02047a8:	848fe0ef          	jal	ffffffffc02027f0 <free_pages>
    kfree(proc);
ffffffffc02047ac:	8522                	mv	a0,s0
ffffffffc02047ae:	c02fd0ef          	jal	ffffffffc0201bb0 <kfree>
}
ffffffffc02047b2:	70a2                	ld	ra,40(sp)
ffffffffc02047b4:	7402                	ld	s0,32(sp)
ffffffffc02047b6:	64e2                	ld	s1,24(sp)
ffffffffc02047b8:	6942                	ld	s2,16(sp)
ffffffffc02047ba:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc02047bc:	4501                	li	a0,0
}
ffffffffc02047be:	6145                	addi	sp,sp,48
ffffffffc02047c0:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc02047c2:	000e1997          	auipc	s3,0xe1
ffffffffc02047c6:	a9698993          	addi	s3,s3,-1386 # ffffffffc02e5258 <current>
ffffffffc02047ca:	0009b703          	ld	a4,0(s3)
ffffffffc02047ce:	f487b683          	ld	a3,-184(a5)
ffffffffc02047d2:	f0e695e3          	bne	a3,a4,ffffffffc02046dc <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc02047d6:	f287a603          	lw	a2,-216(a5)
ffffffffc02047da:	468d                	li	a3,3
ffffffffc02047dc:	06d60063          	beq	a2,a3,ffffffffc020483c <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc02047e0:	800007b7          	lui	a5,0x80000
ffffffffc02047e4:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4541>
        current->state = PROC_SLEEPING;
ffffffffc02047e6:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc02047e8:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc02047ec:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc02047ee:	4e9000ef          	jal	ffffffffc02054d6 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc02047f2:	0009b783          	ld	a5,0(s3)
ffffffffc02047f6:	0b07a783          	lw	a5,176(a5)
ffffffffc02047fa:	8b85                	andi	a5,a5,1
ffffffffc02047fc:	e7b9                	bnez	a5,ffffffffc020484a <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc02047fe:	ee0487e3          	beqz	s1,ffffffffc02046ec <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204802:	45a9                	li	a1,10
ffffffffc0204804:	8526                	mv	a0,s1
ffffffffc0204806:	360010ef          	jal	ffffffffc0205b66 <hash32>
ffffffffc020480a:	02051793          	slli	a5,a0,0x20
ffffffffc020480e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204812:	000dd797          	auipc	a5,0xdd
ffffffffc0204816:	93e78793          	addi	a5,a5,-1730 # ffffffffc02e1150 <hash_list>
ffffffffc020481a:	953e                	add	a0,a0,a5
ffffffffc020481c:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc020481e:	a029                	j	ffffffffc0204828 <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc0204820:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204824:	f8970fe3          	beq	a4,s1,ffffffffc02047c2 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc0204828:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020482a:	fef51be3          	bne	a0,a5,ffffffffc0204820 <do_wait.part.0+0x16a>
ffffffffc020482e:	b57d                	j	ffffffffc02046dc <do_wait.part.0+0x26>
        intr_enable();
ffffffffc0204830:	8cefc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0204834:	bf2d                	j	ffffffffc020476e <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc0204836:	7018                	ld	a4,32(s0)
ffffffffc0204838:	fb7c                	sd	a5,240(a4)
ffffffffc020483a:	b705                	j	ffffffffc020475a <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020483c:	f2878413          	addi	s0,a5,-216
ffffffffc0204840:	b5d1                	j	ffffffffc0204704 <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc0204842:	8c2fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0204846:	4605                	li	a2,1
ffffffffc0204848:	b5f5                	j	ffffffffc0204734 <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc020484a:	555d                	li	a0,-9
ffffffffc020484c:	d27ff0ef          	jal	ffffffffc0204572 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc0204850:	00003617          	auipc	a2,0x3
ffffffffc0204854:	b0860613          	addi	a2,a2,-1272 # ffffffffc0207358 <etext+0x17dc>
ffffffffc0204858:	33900593          	li	a1,825
ffffffffc020485c:	00003517          	auipc	a0,0x3
ffffffffc0204860:	aa450513          	addi	a0,a0,-1372 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204864:	9c9fb0ef          	jal	ffffffffc020022c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204868:	00002617          	auipc	a2,0x2
ffffffffc020486c:	cd060613          	addi	a2,a2,-816 # ffffffffc0206538 <etext+0x9bc>
ffffffffc0204870:	06900593          	li	a1,105
ffffffffc0204874:	00002517          	auipc	a0,0x2
ffffffffc0204878:	ce450513          	addi	a0,a0,-796 # ffffffffc0206558 <etext+0x9dc>
ffffffffc020487c:	9b1fb0ef          	jal	ffffffffc020022c <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204880:	00002617          	auipc	a2,0x2
ffffffffc0204884:	05860613          	addi	a2,a2,88 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc0204888:	07700593          	li	a1,119
ffffffffc020488c:	00002517          	auipc	a0,0x2
ffffffffc0204890:	ccc50513          	addi	a0,a0,-820 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0204894:	999fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204898 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204898:	1141                	addi	sp,sp,-16
ffffffffc020489a:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020489c:	f8dfd0ef          	jal	ffffffffc0202828 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02048a0:	a66fd0ef          	jal	ffffffffc0201b06 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02048a4:	4601                	li	a2,0
ffffffffc02048a6:	4581                	li	a1,0
ffffffffc02048a8:	00000517          	auipc	a0,0x0
ffffffffc02048ac:	6b050513          	addi	a0,a0,1712 # ffffffffc0204f58 <user_main>
ffffffffc02048b0:	c73ff0ef          	jal	ffffffffc0204522 <kernel_thread>
    if (pid <= 0)
ffffffffc02048b4:	00a04563          	bgtz	a0,ffffffffc02048be <init_main+0x26>
ffffffffc02048b8:	a071                	j	ffffffffc0204944 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc02048ba:	41d000ef          	jal	ffffffffc02054d6 <schedule>
    if (code_store != NULL)
ffffffffc02048be:	4581                	li	a1,0
ffffffffc02048c0:	4501                	li	a0,0
ffffffffc02048c2:	df5ff0ef          	jal	ffffffffc02046b6 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc02048c6:	d975                	beqz	a0,ffffffffc02048ba <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02048c8:	00003517          	auipc	a0,0x3
ffffffffc02048cc:	ad050513          	addi	a0,a0,-1328 # ffffffffc0207398 <etext+0x181c>
ffffffffc02048d0:	813fb0ef          	jal	ffffffffc02000e2 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02048d4:	000e1797          	auipc	a5,0xe1
ffffffffc02048d8:	98c7b783          	ld	a5,-1652(a5) # ffffffffc02e5260 <initproc>
ffffffffc02048dc:	7bf8                	ld	a4,240(a5)
ffffffffc02048de:	e339                	bnez	a4,ffffffffc0204924 <init_main+0x8c>
ffffffffc02048e0:	7ff8                	ld	a4,248(a5)
ffffffffc02048e2:	e329                	bnez	a4,ffffffffc0204924 <init_main+0x8c>
ffffffffc02048e4:	1007b703          	ld	a4,256(a5)
ffffffffc02048e8:	ef15                	bnez	a4,ffffffffc0204924 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc02048ea:	000e1697          	auipc	a3,0xe1
ffffffffc02048ee:	9666a683          	lw	a3,-1690(a3) # ffffffffc02e5250 <nr_process>
ffffffffc02048f2:	4709                	li	a4,2
ffffffffc02048f4:	0ae69463          	bne	a3,a4,ffffffffc020499c <init_main+0x104>
ffffffffc02048f8:	000e1697          	auipc	a3,0xe1
ffffffffc02048fc:	85868693          	addi	a3,a3,-1960 # ffffffffc02e5150 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204900:	6698                	ld	a4,8(a3)
ffffffffc0204902:	0c878793          	addi	a5,a5,200
ffffffffc0204906:	06f71b63          	bne	a4,a5,ffffffffc020497c <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020490a:	629c                	ld	a5,0(a3)
ffffffffc020490c:	04f71863          	bne	a4,a5,ffffffffc020495c <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204910:	00003517          	auipc	a0,0x3
ffffffffc0204914:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207480 <etext+0x1904>
ffffffffc0204918:	fcafb0ef          	jal	ffffffffc02000e2 <cprintf>
    return 0;
}
ffffffffc020491c:	60a2                	ld	ra,8(sp)
ffffffffc020491e:	4501                	li	a0,0
ffffffffc0204920:	0141                	addi	sp,sp,16
ffffffffc0204922:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204924:	00003697          	auipc	a3,0x3
ffffffffc0204928:	a9c68693          	addi	a3,a3,-1380 # ffffffffc02073c0 <etext+0x1844>
ffffffffc020492c:	00002617          	auipc	a2,0x2
ffffffffc0204930:	cc460613          	addi	a2,a2,-828 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0204934:	3a500593          	li	a1,933
ffffffffc0204938:	00003517          	auipc	a0,0x3
ffffffffc020493c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204940:	8edfb0ef          	jal	ffffffffc020022c <__panic>
        panic("create user_main failed.\n");
ffffffffc0204944:	00003617          	auipc	a2,0x3
ffffffffc0204948:	a3460613          	addi	a2,a2,-1484 # ffffffffc0207378 <etext+0x17fc>
ffffffffc020494c:	39c00593          	li	a1,924
ffffffffc0204950:	00003517          	auipc	a0,0x3
ffffffffc0204954:	9b050513          	addi	a0,a0,-1616 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204958:	8d5fb0ef          	jal	ffffffffc020022c <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020495c:	00003697          	auipc	a3,0x3
ffffffffc0204960:	af468693          	addi	a3,a3,-1292 # ffffffffc0207450 <etext+0x18d4>
ffffffffc0204964:	00002617          	auipc	a2,0x2
ffffffffc0204968:	c8c60613          	addi	a2,a2,-884 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020496c:	3a800593          	li	a1,936
ffffffffc0204970:	00003517          	auipc	a0,0x3
ffffffffc0204974:	99050513          	addi	a0,a0,-1648 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204978:	8b5fb0ef          	jal	ffffffffc020022c <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020497c:	00003697          	auipc	a3,0x3
ffffffffc0204980:	aa468693          	addi	a3,a3,-1372 # ffffffffc0207420 <etext+0x18a4>
ffffffffc0204984:	00002617          	auipc	a2,0x2
ffffffffc0204988:	c6c60613          	addi	a2,a2,-916 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020498c:	3a700593          	li	a1,935
ffffffffc0204990:	00003517          	auipc	a0,0x3
ffffffffc0204994:	97050513          	addi	a0,a0,-1680 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204998:	895fb0ef          	jal	ffffffffc020022c <__panic>
    assert(nr_process == 2);
ffffffffc020499c:	00003697          	auipc	a3,0x3
ffffffffc02049a0:	a7468693          	addi	a3,a3,-1420 # ffffffffc0207410 <etext+0x1894>
ffffffffc02049a4:	00002617          	auipc	a2,0x2
ffffffffc02049a8:	c4c60613          	addi	a2,a2,-948 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02049ac:	3a600593          	li	a1,934
ffffffffc02049b0:	00003517          	auipc	a0,0x3
ffffffffc02049b4:	95050513          	addi	a0,a0,-1712 # ffffffffc0207300 <etext+0x1784>
ffffffffc02049b8:	875fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02049bc <do_execve>:
{
ffffffffc02049bc:	7171                	addi	sp,sp,-176
ffffffffc02049be:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049c0:	000e1d17          	auipc	s10,0xe1
ffffffffc02049c4:	898d0d13          	addi	s10,s10,-1896 # ffffffffc02e5258 <current>
ffffffffc02049c8:	000d3783          	ld	a5,0(s10)
{
ffffffffc02049cc:	e94a                	sd	s2,144(sp)
ffffffffc02049ce:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02049d0:	0287b903          	ld	s2,40(a5)
{
ffffffffc02049d4:	84ae                	mv	s1,a1
ffffffffc02049d6:	e54e                	sd	s3,136(sp)
ffffffffc02049d8:	ec32                	sd	a2,24(sp)
ffffffffc02049da:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02049dc:	85aa                	mv	a1,a0
ffffffffc02049de:	8626                	mv	a2,s1
ffffffffc02049e0:	854a                	mv	a0,s2
ffffffffc02049e2:	4681                	li	a3,0
{
ffffffffc02049e4:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02049e6:	dfdfc0ef          	jal	ffffffffc02017e2 <user_mem_check>
ffffffffc02049ea:	46050f63          	beqz	a0,ffffffffc0204e68 <do_execve+0x4ac>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02049ee:	4641                	li	a2,16
ffffffffc02049f0:	1808                	addi	a0,sp,48
ffffffffc02049f2:	4581                	li	a1,0
ffffffffc02049f4:	57d000ef          	jal	ffffffffc0205770 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc02049f8:	47bd                	li	a5,15
ffffffffc02049fa:	8626                	mv	a2,s1
ffffffffc02049fc:	0e97ef63          	bltu	a5,s1,ffffffffc0204afa <do_execve+0x13e>
    memcpy(local_name, name, len);
ffffffffc0204a00:	85ce                	mv	a1,s3
ffffffffc0204a02:	1808                	addi	a0,sp,48
ffffffffc0204a04:	57f000ef          	jal	ffffffffc0205782 <memcpy>
    if (mm != NULL)
ffffffffc0204a08:	10090063          	beqz	s2,ffffffffc0204b08 <do_execve+0x14c>
        cputs("mm != NULL");
ffffffffc0204a0c:	00002517          	auipc	a0,0x2
ffffffffc0204a10:	c8450513          	addi	a0,a0,-892 # ffffffffc0206690 <etext+0xb14>
ffffffffc0204a14:	f06fb0ef          	jal	ffffffffc020011a <cputs>
ffffffffc0204a18:	000e1797          	auipc	a5,0xe1
ffffffffc0204a1c:	8107b783          	ld	a5,-2032(a5) # ffffffffc02e5228 <boot_pgdir_pa>
ffffffffc0204a20:	577d                	li	a4,-1
ffffffffc0204a22:	177e                	slli	a4,a4,0x3f
ffffffffc0204a24:	83b1                	srli	a5,a5,0xc
ffffffffc0204a26:	8fd9                	or	a5,a5,a4
ffffffffc0204a28:	18079073          	csrw	satp,a5
ffffffffc0204a2c:	03092783          	lw	a5,48(s2)
ffffffffc0204a30:	37fd                	addiw	a5,a5,-1
ffffffffc0204a32:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0204a36:	30078563          	beqz	a5,ffffffffc0204d40 <do_execve+0x384>
        current->mm = NULL;
ffffffffc0204a3a:	000d3783          	ld	a5,0(s10)
ffffffffc0204a3e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a42:	f14fc0ef          	jal	ffffffffc0201156 <mm_create>
ffffffffc0204a46:	892a                	mv	s2,a0
ffffffffc0204a48:	22050063          	beqz	a0,ffffffffc0204c68 <do_execve+0x2ac>
    if ((page = alloc_page()) == NULL)
ffffffffc0204a4c:	4505                	li	a0,1
ffffffffc0204a4e:	d69fd0ef          	jal	ffffffffc02027b6 <alloc_pages>
ffffffffc0204a52:	42050063          	beqz	a0,ffffffffc0204e72 <do_execve+0x4b6>
    return page - pages + nbase;
ffffffffc0204a56:	f0e2                	sd	s8,96(sp)
ffffffffc0204a58:	000e0c17          	auipc	s8,0xe0
ffffffffc0204a5c:	7f0c0c13          	addi	s8,s8,2032 # ffffffffc02e5248 <pages>
ffffffffc0204a60:	000c3783          	ld	a5,0(s8)
ffffffffc0204a64:	f4de                	sd	s7,104(sp)
ffffffffc0204a66:	00004b97          	auipc	s7,0x4
ffffffffc0204a6a:	992bbb83          	ld	s7,-1646(s7) # ffffffffc02083f8 <nbase>
ffffffffc0204a6e:	40f506b3          	sub	a3,a0,a5
ffffffffc0204a72:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc0204a74:	000e0c97          	auipc	s9,0xe0
ffffffffc0204a78:	7ccc8c93          	addi	s9,s9,1996 # ffffffffc02e5240 <npage>
ffffffffc0204a7c:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc0204a7e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204a80:	5b7d                	li	s6,-1
ffffffffc0204a82:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0204a86:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204a88:	00cb5713          	srli	a4,s6,0xc
ffffffffc0204a8c:	e83a                	sd	a4,16(sp)
ffffffffc0204a8e:	fcd6                	sd	s5,120(sp)
ffffffffc0204a90:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a92:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a94:	40f77263          	bgeu	a4,a5,ffffffffc0204e98 <do_execve+0x4dc>
ffffffffc0204a98:	000e0a97          	auipc	s5,0xe0
ffffffffc0204a9c:	7a0a8a93          	addi	s5,s5,1952 # ffffffffc02e5238 <va_pa_offset>
ffffffffc0204aa0:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204aa4:	000e0597          	auipc	a1,0xe0
ffffffffc0204aa8:	78c5b583          	ld	a1,1932(a1) # ffffffffc02e5230 <boot_pgdir_va>
ffffffffc0204aac:	6605                	lui	a2,0x1
ffffffffc0204aae:	00f684b3          	add	s1,a3,a5
ffffffffc0204ab2:	8526                	mv	a0,s1
ffffffffc0204ab4:	4cf000ef          	jal	ffffffffc0205782 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204ab8:	66e2                	ld	a3,24(sp)
ffffffffc0204aba:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204abe:	00993c23          	sd	s1,24(s2)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204ac2:	4298                	lw	a4,0(a3)
ffffffffc0204ac4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b8abf>
ffffffffc0204ac8:	06f70863          	beq	a4,a5,ffffffffc0204b38 <do_execve+0x17c>
        ret = -E_INVAL_ELF;
ffffffffc0204acc:	54e1                	li	s1,-8
    put_pgdir(mm);
ffffffffc0204ace:	854a                	mv	a0,s2
ffffffffc0204ad0:	d76ff0ef          	jal	ffffffffc0204046 <put_pgdir>
ffffffffc0204ad4:	7ae6                	ld	s5,120(sp)
ffffffffc0204ad6:	7b46                	ld	s6,112(sp)
ffffffffc0204ad8:	7ba6                	ld	s7,104(sp)
ffffffffc0204ada:	7c06                	ld	s8,96(sp)
ffffffffc0204adc:	6ce6                	ld	s9,88(sp)
    mm_destroy(mm);
ffffffffc0204ade:	854a                	mv	a0,s2
ffffffffc0204ae0:	fb4fc0ef          	jal	ffffffffc0201294 <mm_destroy>
    do_exit(ret);
ffffffffc0204ae4:	8526                	mv	a0,s1
ffffffffc0204ae6:	f122                	sd	s0,160(sp)
ffffffffc0204ae8:	e152                	sd	s4,128(sp)
ffffffffc0204aea:	fcd6                	sd	s5,120(sp)
ffffffffc0204aec:	f8da                	sd	s6,112(sp)
ffffffffc0204aee:	f4de                	sd	s7,104(sp)
ffffffffc0204af0:	f0e2                	sd	s8,96(sp)
ffffffffc0204af2:	ece6                	sd	s9,88(sp)
ffffffffc0204af4:	e4ee                	sd	s11,72(sp)
ffffffffc0204af6:	a7dff0ef          	jal	ffffffffc0204572 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc0204afa:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc0204afc:	85ce                	mv	a1,s3
ffffffffc0204afe:	1808                	addi	a0,sp,48
ffffffffc0204b00:	483000ef          	jal	ffffffffc0205782 <memcpy>
    if (mm != NULL)
ffffffffc0204b04:	f00914e3          	bnez	s2,ffffffffc0204a0c <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc0204b08:	000d3783          	ld	a5,0(s10)
ffffffffc0204b0c:	779c                	ld	a5,40(a5)
ffffffffc0204b0e:	db95                	beqz	a5,ffffffffc0204a42 <do_execve+0x86>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204b10:	00003617          	auipc	a2,0x3
ffffffffc0204b14:	99060613          	addi	a2,a2,-1648 # ffffffffc02074a0 <etext+0x1924>
ffffffffc0204b18:	22c00593          	li	a1,556
ffffffffc0204b1c:	00002517          	auipc	a0,0x2
ffffffffc0204b20:	7e450513          	addi	a0,a0,2020 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204b24:	f122                	sd	s0,160(sp)
ffffffffc0204b26:	e152                	sd	s4,128(sp)
ffffffffc0204b28:	fcd6                	sd	s5,120(sp)
ffffffffc0204b2a:	f8da                	sd	s6,112(sp)
ffffffffc0204b2c:	f4de                	sd	s7,104(sp)
ffffffffc0204b2e:	f0e2                	sd	s8,96(sp)
ffffffffc0204b30:	ece6                	sd	s9,88(sp)
ffffffffc0204b32:	e4ee                	sd	s11,72(sp)
ffffffffc0204b34:	ef8fb0ef          	jal	ffffffffc020022c <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b38:	0386d703          	lhu	a4,56(a3)
ffffffffc0204b3c:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b3e:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b42:	00371793          	slli	a5,a4,0x3
ffffffffc0204b46:	8f99                	sub	a5,a5,a4
ffffffffc0204b48:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b4a:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b4c:	97d2                	add	a5,a5,s4
ffffffffc0204b4e:	f122                	sd	s0,160(sp)
ffffffffc0204b50:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204b52:	00fa7e63          	bgeu	s4,a5,ffffffffc0204b6e <do_execve+0x1b2>
ffffffffc0204b56:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204b58:	000a2783          	lw	a5,0(s4)
ffffffffc0204b5c:	4705                	li	a4,1
ffffffffc0204b5e:	10e78763          	beq	a5,a4,ffffffffc0204c6c <do_execve+0x2b0>
    for (; ph < ph_end; ph++)
ffffffffc0204b62:	77a2                	ld	a5,40(sp)
ffffffffc0204b64:	038a0a13          	addi	s4,s4,56
ffffffffc0204b68:	fefa68e3          	bltu	s4,a5,ffffffffc0204b58 <do_execve+0x19c>
ffffffffc0204b6c:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204b6e:	4701                	li	a4,0
ffffffffc0204b70:	46ad                	li	a3,11
ffffffffc0204b72:	00100637          	lui	a2,0x100
ffffffffc0204b76:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204b7a:	854a                	mv	a0,s2
ffffffffc0204b7c:	f6afc0ef          	jal	ffffffffc02012e6 <mm_map>
ffffffffc0204b80:	84aa                	mv	s1,a0
ffffffffc0204b82:	1a051963          	bnez	a0,ffffffffc0204d34 <do_execve+0x378>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204b86:	01893503          	ld	a0,24(s2)
ffffffffc0204b8a:	467d                	li	a2,31
ffffffffc0204b8c:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204b90:	ac2ff0ef          	jal	ffffffffc0203e52 <pgdir_alloc_page>
ffffffffc0204b94:	3a050163          	beqz	a0,ffffffffc0204f36 <do_execve+0x57a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204b98:	01893503          	ld	a0,24(s2)
ffffffffc0204b9c:	467d                	li	a2,31
ffffffffc0204b9e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204ba2:	ab0ff0ef          	jal	ffffffffc0203e52 <pgdir_alloc_page>
ffffffffc0204ba6:	36050763          	beqz	a0,ffffffffc0204f14 <do_execve+0x558>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204baa:	01893503          	ld	a0,24(s2)
ffffffffc0204bae:	467d                	li	a2,31
ffffffffc0204bb0:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204bb4:	a9eff0ef          	jal	ffffffffc0203e52 <pgdir_alloc_page>
ffffffffc0204bb8:	32050d63          	beqz	a0,ffffffffc0204ef2 <do_execve+0x536>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bbc:	01893503          	ld	a0,24(s2)
ffffffffc0204bc0:	467d                	li	a2,31
ffffffffc0204bc2:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204bc6:	a8cff0ef          	jal	ffffffffc0203e52 <pgdir_alloc_page>
ffffffffc0204bca:	30050363          	beqz	a0,ffffffffc0204ed0 <do_execve+0x514>
    mm->mm_count += 1;
ffffffffc0204bce:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0204bd2:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204bd6:	01893683          	ld	a3,24(s2)
ffffffffc0204bda:	2785                	addiw	a5,a5,1
ffffffffc0204bdc:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0204be0:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf4568>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204be4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204be8:	2cf6e763          	bltu	a3,a5,ffffffffc0204eb6 <do_execve+0x4fa>
ffffffffc0204bec:	000ab783          	ld	a5,0(s5)
ffffffffc0204bf0:	577d                	li	a4,-1
ffffffffc0204bf2:	177e                	slli	a4,a4,0x3f
ffffffffc0204bf4:	8e9d                	sub	a3,a3,a5
ffffffffc0204bf6:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204bfa:	f654                	sd	a3,168(a2)
ffffffffc0204bfc:	8fd9                	or	a5,a5,a4
ffffffffc0204bfe:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204c02:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c04:	4581                	li	a1,0
ffffffffc0204c06:	12000613          	li	a2,288
ffffffffc0204c0a:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204c0c:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c10:	361000ef          	jal	ffffffffc0205770 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204c14:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c16:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204c1a:	edd97913          	andi	s2,s2,-291
    tf->epc = elf->e_entry;
ffffffffc0204c1e:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204c20:	4785                	li	a5,1
ffffffffc0204c22:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204c24:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc0204c28:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204c2c:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204c2e:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c32:	4641                	li	a2,16
ffffffffc0204c34:	4581                	li	a1,0
ffffffffc0204c36:	0b498513          	addi	a0,s3,180
ffffffffc0204c3a:	337000ef          	jal	ffffffffc0205770 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204c3e:	180c                	addi	a1,sp,48
ffffffffc0204c40:	0b498513          	addi	a0,s3,180
ffffffffc0204c44:	463d                	li	a2,15
ffffffffc0204c46:	33d000ef          	jal	ffffffffc0205782 <memcpy>
ffffffffc0204c4a:	740a                	ld	s0,160(sp)
ffffffffc0204c4c:	6a0a                	ld	s4,128(sp)
ffffffffc0204c4e:	7ae6                	ld	s5,120(sp)
ffffffffc0204c50:	7b46                	ld	s6,112(sp)
ffffffffc0204c52:	7ba6                	ld	s7,104(sp)
ffffffffc0204c54:	7c06                	ld	s8,96(sp)
ffffffffc0204c56:	6ce6                	ld	s9,88(sp)
}
ffffffffc0204c58:	70aa                	ld	ra,168(sp)
ffffffffc0204c5a:	694a                	ld	s2,144(sp)
ffffffffc0204c5c:	69aa                	ld	s3,136(sp)
ffffffffc0204c5e:	6d46                	ld	s10,80(sp)
ffffffffc0204c60:	8526                	mv	a0,s1
ffffffffc0204c62:	64ea                	ld	s1,152(sp)
ffffffffc0204c64:	614d                	addi	sp,sp,176
ffffffffc0204c66:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0204c68:	54f1                	li	s1,-4
ffffffffc0204c6a:	bdad                	j	ffffffffc0204ae4 <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204c6c:	028a3603          	ld	a2,40(s4)
ffffffffc0204c70:	020a3783          	ld	a5,32(s4)
ffffffffc0204c74:	20f66363          	bltu	a2,a5,ffffffffc0204e7a <do_execve+0x4be>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204c78:	004a2783          	lw	a5,4(s4)
ffffffffc0204c7c:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204c80:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204c84:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c86:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204c88:	c6f1                	beqz	a3,ffffffffc0204d54 <do_execve+0x398>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204c8a:	1c079763          	bnez	a5,ffffffffc0204e58 <do_execve+0x49c>
            perm |= (PTE_W | PTE_R);
ffffffffc0204c8e:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc0204c90:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc0204c94:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0204c96:	c709                	beqz	a4,ffffffffc0204ca0 <do_execve+0x2e4>
            perm |= PTE_X;
ffffffffc0204c98:	67a2                	ld	a5,8(sp)
ffffffffc0204c9a:	0087e793          	ori	a5,a5,8
ffffffffc0204c9e:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204ca0:	010a3583          	ld	a1,16(s4)
ffffffffc0204ca4:	4701                	li	a4,0
ffffffffc0204ca6:	854a                	mv	a0,s2
ffffffffc0204ca8:	e3efc0ef          	jal	ffffffffc02012e6 <mm_map>
ffffffffc0204cac:	84aa                	mv	s1,a0
ffffffffc0204cae:	1c051463          	bnez	a0,ffffffffc0204e76 <do_execve+0x4ba>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204cb2:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204cb6:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204cba:	77fd                	lui	a5,0xfffff
ffffffffc0204cbc:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc0204cc0:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc0204cc2:	1a9b7563          	bgeu	s6,s1,ffffffffc0204e6c <do_execve+0x4b0>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204cc6:	008a3983          	ld	s3,8(s4)
ffffffffc0204cca:	67e2                	ld	a5,24(sp)
ffffffffc0204ccc:	99be                	add	s3,s3,a5
ffffffffc0204cce:	a881                	j	ffffffffc0204d1e <do_execve+0x362>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204cd0:	6785                	lui	a5,0x1
ffffffffc0204cd2:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc0204cd6:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc0204cda:	01b4e463          	bltu	s1,s11,ffffffffc0204ce2 <do_execve+0x326>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204cde:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc0204ce2:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204ce6:	67c2                	ld	a5,16(sp)
ffffffffc0204ce8:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0204cec:	40d406b3          	sub	a3,s0,a3
ffffffffc0204cf0:	8699                	srai	a3,a3,0x6
ffffffffc0204cf2:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204cf4:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cf8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cfa:	18a87363          	bgeu	a6,a0,ffffffffc0204e80 <do_execve+0x4c4>
ffffffffc0204cfe:	000ab503          	ld	a0,0(s5)
ffffffffc0204d02:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204d06:	e032                	sd	a2,0(sp)
ffffffffc0204d08:	9536                	add	a0,a0,a3
ffffffffc0204d0a:	952e                	add	a0,a0,a1
ffffffffc0204d0c:	85ce                	mv	a1,s3
ffffffffc0204d0e:	275000ef          	jal	ffffffffc0205782 <memcpy>
            start += size, from += size;
ffffffffc0204d12:	6602                	ld	a2,0(sp)
ffffffffc0204d14:	9b32                	add	s6,s6,a2
ffffffffc0204d16:	99b2                	add	s3,s3,a2
        while (start < end)
ffffffffc0204d18:	049b7563          	bgeu	s6,s1,ffffffffc0204d62 <do_execve+0x3a6>
ffffffffc0204d1c:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d1e:	01893503          	ld	a0,24(s2)
ffffffffc0204d22:	6622                	ld	a2,8(sp)
ffffffffc0204d24:	e02e                	sd	a1,0(sp)
ffffffffc0204d26:	92cff0ef          	jal	ffffffffc0203e52 <pgdir_alloc_page>
ffffffffc0204d2a:	6582                	ld	a1,0(sp)
ffffffffc0204d2c:	842a                	mv	s0,a0
ffffffffc0204d2e:	f14d                	bnez	a0,ffffffffc0204cd0 <do_execve+0x314>
ffffffffc0204d30:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0204d32:	54f1                	li	s1,-4
    exit_mmap(mm);
ffffffffc0204d34:	854a                	mv	a0,s2
ffffffffc0204d36:	f14fc0ef          	jal	ffffffffc020144a <exit_mmap>
ffffffffc0204d3a:	740a                	ld	s0,160(sp)
ffffffffc0204d3c:	6a0a                	ld	s4,128(sp)
ffffffffc0204d3e:	bb41                	j	ffffffffc0204ace <do_execve+0x112>
            exit_mmap(mm);
ffffffffc0204d40:	854a                	mv	a0,s2
ffffffffc0204d42:	f08fc0ef          	jal	ffffffffc020144a <exit_mmap>
            put_pgdir(mm);
ffffffffc0204d46:	854a                	mv	a0,s2
ffffffffc0204d48:	afeff0ef          	jal	ffffffffc0204046 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204d4c:	854a                	mv	a0,s2
ffffffffc0204d4e:	d46fc0ef          	jal	ffffffffc0201294 <mm_destroy>
ffffffffc0204d52:	b1e5                	j	ffffffffc0204a3a <do_execve+0x7e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204d54:	0e078e63          	beqz	a5,ffffffffc0204e50 <do_execve+0x494>
            perm |= PTE_R;
ffffffffc0204d58:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0204d5a:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc0204d5e:	e43e                	sd	a5,8(sp)
ffffffffc0204d60:	bf1d                	j	ffffffffc0204c96 <do_execve+0x2da>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204d62:	010a3483          	ld	s1,16(s4)
ffffffffc0204d66:	028a3683          	ld	a3,40(s4)
ffffffffc0204d6a:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204d6c:	07bb7c63          	bgeu	s6,s11,ffffffffc0204de4 <do_execve+0x428>
            if (start == end)
ffffffffc0204d70:	df6489e3          	beq	s1,s6,ffffffffc0204b62 <do_execve+0x1a6>
                size -= la - end;
ffffffffc0204d74:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204d78:	0fb4f563          	bgeu	s1,s11,ffffffffc0204e62 <do_execve+0x4a6>
    return page - pages + nbase;
ffffffffc0204d7c:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204d80:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204d84:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d88:	8699                	srai	a3,a3,0x6
ffffffffc0204d8a:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204d8c:	00c69593          	slli	a1,a3,0xc
ffffffffc0204d90:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d92:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d94:	0ec5f663          	bgeu	a1,a2,ffffffffc0204e80 <do_execve+0x4c4>
ffffffffc0204d98:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204d9c:	6505                	lui	a0,0x1
ffffffffc0204d9e:	955a                	add	a0,a0,s6
ffffffffc0204da0:	96b2                	add	a3,a3,a2
ffffffffc0204da2:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204da6:	9536                	add	a0,a0,a3
ffffffffc0204da8:	864e                	mv	a2,s3
ffffffffc0204daa:	4581                	li	a1,0
ffffffffc0204dac:	1c5000ef          	jal	ffffffffc0205770 <memset>
            start += size;
ffffffffc0204db0:	9b4e                	add	s6,s6,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204db2:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc0204db6:	01b4f463          	bgeu	s1,s11,ffffffffc0204dbe <do_execve+0x402>
ffffffffc0204dba:	db6484e3          	beq	s1,s6,ffffffffc0204b62 <do_execve+0x1a6>
ffffffffc0204dbe:	e299                	bnez	a3,ffffffffc0204dc4 <do_execve+0x408>
ffffffffc0204dc0:	03bb0263          	beq	s6,s11,ffffffffc0204de4 <do_execve+0x428>
ffffffffc0204dc4:	00002697          	auipc	a3,0x2
ffffffffc0204dc8:	70468693          	addi	a3,a3,1796 # ffffffffc02074c8 <etext+0x194c>
ffffffffc0204dcc:	00002617          	auipc	a2,0x2
ffffffffc0204dd0:	82460613          	addi	a2,a2,-2012 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0204dd4:	29500593          	li	a1,661
ffffffffc0204dd8:	00002517          	auipc	a0,0x2
ffffffffc0204ddc:	52850513          	addi	a0,a0,1320 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204de0:	c4cfb0ef          	jal	ffffffffc020022c <__panic>
        while (start < end)
ffffffffc0204de4:	d69b7fe3          	bgeu	s6,s1,ffffffffc0204b62 <do_execve+0x1a6>
ffffffffc0204de8:	56fd                	li	a3,-1
ffffffffc0204dea:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204dee:	f03e                	sd	a5,32(sp)
ffffffffc0204df0:	a0b9                	j	ffffffffc0204e3e <do_execve+0x482>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204df2:	6785                	lui	a5,0x1
ffffffffc0204df4:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc0204df8:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204dfc:	0104e463          	bltu	s1,a6,ffffffffc0204e04 <do_execve+0x448>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e00:	416809b3          	sub	s3,a6,s6
    return page - pages + nbase;
ffffffffc0204e04:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204e08:	7782                	ld	a5,32(sp)
ffffffffc0204e0a:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0204e0e:	40d406b3          	sub	a3,s0,a3
ffffffffc0204e12:	8699                	srai	a3,a3,0x6
ffffffffc0204e14:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204e16:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e1a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e1c:	06b57263          	bgeu	a0,a1,ffffffffc0204e80 <do_execve+0x4c4>
ffffffffc0204e20:	000ab583          	ld	a1,0(s5)
ffffffffc0204e24:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e28:	864e                	mv	a2,s3
ffffffffc0204e2a:	96ae                	add	a3,a3,a1
ffffffffc0204e2c:	9536                	add	a0,a0,a3
ffffffffc0204e2e:	4581                	li	a1,0
            start += size;
ffffffffc0204e30:	9b4e                	add	s6,s6,s3
ffffffffc0204e32:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e34:	13d000ef          	jal	ffffffffc0205770 <memset>
        while (start < end)
ffffffffc0204e38:	d29b75e3          	bgeu	s6,s1,ffffffffc0204b62 <do_execve+0x1a6>
ffffffffc0204e3c:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204e3e:	01893503          	ld	a0,24(s2)
ffffffffc0204e42:	6622                	ld	a2,8(sp)
ffffffffc0204e44:	85ee                	mv	a1,s11
ffffffffc0204e46:	80cff0ef          	jal	ffffffffc0203e52 <pgdir_alloc_page>
ffffffffc0204e4a:	842a                	mv	s0,a0
ffffffffc0204e4c:	f15d                	bnez	a0,ffffffffc0204df2 <do_execve+0x436>
ffffffffc0204e4e:	b5cd                	j	ffffffffc0204d30 <do_execve+0x374>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e50:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204e52:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204e54:	e43e                	sd	a5,8(sp)
ffffffffc0204e56:	b581                	j	ffffffffc0204c96 <do_execve+0x2da>
            perm |= (PTE_W | PTE_R);
ffffffffc0204e58:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc0204e5a:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc0204e5e:	e43e                	sd	a5,8(sp)
ffffffffc0204e60:	bd1d                	j	ffffffffc0204c96 <do_execve+0x2da>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204e62:	416d89b3          	sub	s3,s11,s6
ffffffffc0204e66:	bf19                	j	ffffffffc0204d7c <do_execve+0x3c0>
        return -E_INVAL;
ffffffffc0204e68:	54f5                	li	s1,-3
ffffffffc0204e6a:	b3fd                	j	ffffffffc0204c58 <do_execve+0x29c>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204e6c:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc0204e6e:	84da                	mv	s1,s6
ffffffffc0204e70:	bddd                	j	ffffffffc0204d66 <do_execve+0x3aa>
    int ret = -E_NO_MEM;
ffffffffc0204e72:	54f1                	li	s1,-4
ffffffffc0204e74:	b1ad                	j	ffffffffc0204ade <do_execve+0x122>
ffffffffc0204e76:	6da6                	ld	s11,72(sp)
ffffffffc0204e78:	bd75                	j	ffffffffc0204d34 <do_execve+0x378>
            ret = -E_INVAL_ELF;
ffffffffc0204e7a:	6da6                	ld	s11,72(sp)
ffffffffc0204e7c:	54e1                	li	s1,-8
ffffffffc0204e7e:	bd5d                	j	ffffffffc0204d34 <do_execve+0x378>
ffffffffc0204e80:	00001617          	auipc	a2,0x1
ffffffffc0204e84:	6f860613          	addi	a2,a2,1784 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0204e88:	07100593          	li	a1,113
ffffffffc0204e8c:	00001517          	auipc	a0,0x1
ffffffffc0204e90:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0204e94:	b98fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204e98:	00001617          	auipc	a2,0x1
ffffffffc0204e9c:	6e060613          	addi	a2,a2,1760 # ffffffffc0206578 <etext+0x9fc>
ffffffffc0204ea0:	07100593          	li	a1,113
ffffffffc0204ea4:	00001517          	auipc	a0,0x1
ffffffffc0204ea8:	6b450513          	addi	a0,a0,1716 # ffffffffc0206558 <etext+0x9dc>
ffffffffc0204eac:	f122                	sd	s0,160(sp)
ffffffffc0204eae:	e152                	sd	s4,128(sp)
ffffffffc0204eb0:	e4ee                	sd	s11,72(sp)
ffffffffc0204eb2:	b7afb0ef          	jal	ffffffffc020022c <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204eb6:	00002617          	auipc	a2,0x2
ffffffffc0204eba:	a2260613          	addi	a2,a2,-1502 # ffffffffc02068d8 <etext+0xd5c>
ffffffffc0204ebe:	2b400593          	li	a1,692
ffffffffc0204ec2:	00002517          	auipc	a0,0x2
ffffffffc0204ec6:	43e50513          	addi	a0,a0,1086 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204eca:	e4ee                	sd	s11,72(sp)
ffffffffc0204ecc:	b60fb0ef          	jal	ffffffffc020022c <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ed0:	00002697          	auipc	a3,0x2
ffffffffc0204ed4:	71068693          	addi	a3,a3,1808 # ffffffffc02075e0 <etext+0x1a64>
ffffffffc0204ed8:	00001617          	auipc	a2,0x1
ffffffffc0204edc:	71860613          	addi	a2,a2,1816 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0204ee0:	2af00593          	li	a1,687
ffffffffc0204ee4:	00002517          	auipc	a0,0x2
ffffffffc0204ee8:	41c50513          	addi	a0,a0,1052 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204eec:	e4ee                	sd	s11,72(sp)
ffffffffc0204eee:	b3efb0ef          	jal	ffffffffc020022c <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ef2:	00002697          	auipc	a3,0x2
ffffffffc0204ef6:	6a668693          	addi	a3,a3,1702 # ffffffffc0207598 <etext+0x1a1c>
ffffffffc0204efa:	00001617          	auipc	a2,0x1
ffffffffc0204efe:	6f660613          	addi	a2,a2,1782 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0204f02:	2ae00593          	li	a1,686
ffffffffc0204f06:	00002517          	auipc	a0,0x2
ffffffffc0204f0a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204f0e:	e4ee                	sd	s11,72(sp)
ffffffffc0204f10:	b1cfb0ef          	jal	ffffffffc020022c <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f14:	00002697          	auipc	a3,0x2
ffffffffc0204f18:	63c68693          	addi	a3,a3,1596 # ffffffffc0207550 <etext+0x19d4>
ffffffffc0204f1c:	00001617          	auipc	a2,0x1
ffffffffc0204f20:	6d460613          	addi	a2,a2,1748 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0204f24:	2ad00593          	li	a1,685
ffffffffc0204f28:	00002517          	auipc	a0,0x2
ffffffffc0204f2c:	3d850513          	addi	a0,a0,984 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204f30:	e4ee                	sd	s11,72(sp)
ffffffffc0204f32:	afafb0ef          	jal	ffffffffc020022c <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204f36:	00002697          	auipc	a3,0x2
ffffffffc0204f3a:	5d268693          	addi	a3,a3,1490 # ffffffffc0207508 <etext+0x198c>
ffffffffc0204f3e:	00001617          	auipc	a2,0x1
ffffffffc0204f42:	6b260613          	addi	a2,a2,1714 # ffffffffc02065f0 <etext+0xa74>
ffffffffc0204f46:	2ac00593          	li	a1,684
ffffffffc0204f4a:	00002517          	auipc	a0,0x2
ffffffffc0204f4e:	3b650513          	addi	a0,a0,950 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204f52:	e4ee                	sd	s11,72(sp)
ffffffffc0204f54:	ad8fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204f58 <user_main>:
{
ffffffffc0204f58:	1101                	addi	sp,sp,-32
ffffffffc0204f5a:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f5c:	000e0497          	auipc	s1,0xe0
ffffffffc0204f60:	2fc48493          	addi	s1,s1,764 # ffffffffc02e5258 <current>
ffffffffc0204f64:	609c                	ld	a5,0(s1)
ffffffffc0204f66:	00002617          	auipc	a2,0x2
ffffffffc0204f6a:	6c260613          	addi	a2,a2,1730 # ffffffffc0207628 <etext+0x1aac>
ffffffffc0204f6e:	00002517          	auipc	a0,0x2
ffffffffc0204f72:	6ca50513          	addi	a0,a0,1738 # ffffffffc0207638 <etext+0x1abc>
ffffffffc0204f76:	43cc                	lw	a1,4(a5)
{
ffffffffc0204f78:	ec06                	sd	ra,24(sp)
ffffffffc0204f7a:	e822                	sd	s0,16(sp)
ffffffffc0204f7c:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204f7e:	964fb0ef          	jal	ffffffffc02000e2 <cprintf>
    size_t len = strlen(name);
ffffffffc0204f82:	00002517          	auipc	a0,0x2
ffffffffc0204f86:	6a650513          	addi	a0,a0,1702 # ffffffffc0207628 <etext+0x1aac>
ffffffffc0204f8a:	732000ef          	jal	ffffffffc02056bc <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc0204f8e:	6098                	ld	a4,0(s1)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204f90:	6789                	lui	a5,0x2
ffffffffc0204f92:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x75d0>
ffffffffc0204f96:	6b00                	ld	s0,16(a4)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204f98:	734c                	ld	a1,160(a4)
    size_t len = strlen(name);
ffffffffc0204f9a:	892a                	mv	s2,a0
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204f9c:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204f9e:	12000613          	li	a2,288
ffffffffc0204fa2:	8522                	mv	a0,s0
ffffffffc0204fa4:	7de000ef          	jal	ffffffffc0205782 <memcpy>
    current->tf = new_tf;
ffffffffc0204fa8:	609c                	ld	a5,0(s1)
    ret = do_execve(name, len, binary, size);
ffffffffc0204faa:	85ca                	mv	a1,s2
ffffffffc0204fac:	3fe06697          	auipc	a3,0x3fe06
ffffffffc0204fb0:	ce468693          	addi	a3,a3,-796 # ac90 <_binary_obj___user_priority_out_size>
    current->tf = new_tf;
ffffffffc0204fb4:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0204fb6:	00044617          	auipc	a2,0x44
ffffffffc0204fba:	b0260613          	addi	a2,a2,-1278 # ffffffffc0248ab8 <_binary_obj___user_priority_out_start>
ffffffffc0204fbe:	00002517          	auipc	a0,0x2
ffffffffc0204fc2:	66a50513          	addi	a0,a0,1642 # ffffffffc0207628 <etext+0x1aac>
ffffffffc0204fc6:	9f7ff0ef          	jal	ffffffffc02049bc <do_execve>
    asm volatile(
ffffffffc0204fca:	8122                	mv	sp,s0
ffffffffc0204fcc:	860fc06f          	j	ffffffffc020102c <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204fd0:	00002617          	auipc	a2,0x2
ffffffffc0204fd4:	69060613          	addi	a2,a2,1680 # ffffffffc0207660 <etext+0x1ae4>
ffffffffc0204fd8:	38f00593          	li	a1,911
ffffffffc0204fdc:	00002517          	auipc	a0,0x2
ffffffffc0204fe0:	32450513          	addi	a0,a0,804 # ffffffffc0207300 <etext+0x1784>
ffffffffc0204fe4:	a48fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204fe8 <do_yield>:
    current->need_resched = 1;
ffffffffc0204fe8:	000e0797          	auipc	a5,0xe0
ffffffffc0204fec:	2707b783          	ld	a5,624(a5) # ffffffffc02e5258 <current>
ffffffffc0204ff0:	4705                	li	a4,1
}
ffffffffc0204ff2:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0204ff4:	ef98                	sd	a4,24(a5)
}
ffffffffc0204ff6:	8082                	ret

ffffffffc0204ff8 <do_wait>:
    if (code_store != NULL)
ffffffffc0204ff8:	c59d                	beqz	a1,ffffffffc0205026 <do_wait+0x2e>
{
ffffffffc0204ffa:	1101                	addi	sp,sp,-32
ffffffffc0204ffc:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204ffe:	000e0517          	auipc	a0,0xe0
ffffffffc0205002:	25a53503          	ld	a0,602(a0) # ffffffffc02e5258 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205006:	4685                	li	a3,1
ffffffffc0205008:	4611                	li	a2,4
ffffffffc020500a:	7508                	ld	a0,40(a0)
{
ffffffffc020500c:	ec06                	sd	ra,24(sp)
ffffffffc020500e:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205010:	fd2fc0ef          	jal	ffffffffc02017e2 <user_mem_check>
ffffffffc0205014:	6702                	ld	a4,0(sp)
ffffffffc0205016:	67a2                	ld	a5,8(sp)
ffffffffc0205018:	c909                	beqz	a0,ffffffffc020502a <do_wait+0x32>
}
ffffffffc020501a:	60e2                	ld	ra,24(sp)
ffffffffc020501c:	85be                	mv	a1,a5
ffffffffc020501e:	853a                	mv	a0,a4
ffffffffc0205020:	6105                	addi	sp,sp,32
ffffffffc0205022:	e94ff06f          	j	ffffffffc02046b6 <do_wait.part.0>
ffffffffc0205026:	e90ff06f          	j	ffffffffc02046b6 <do_wait.part.0>
ffffffffc020502a:	60e2                	ld	ra,24(sp)
ffffffffc020502c:	5575                	li	a0,-3
ffffffffc020502e:	6105                	addi	sp,sp,32
ffffffffc0205030:	8082                	ret

ffffffffc0205032 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0205032:	6789                	lui	a5,0x2
ffffffffc0205034:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205038:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x74b2>
ffffffffc020503a:	06e7e463          	bltu	a5,a4,ffffffffc02050a2 <do_kill+0x70>
{
ffffffffc020503e:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205040:	45a9                	li	a1,10
{
ffffffffc0205042:	ec06                	sd	ra,24(sp)
ffffffffc0205044:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205046:	321000ef          	jal	ffffffffc0205b66 <hash32>
ffffffffc020504a:	02051793          	slli	a5,a0,0x20
ffffffffc020504e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205052:	000dc797          	auipc	a5,0xdc
ffffffffc0205056:	0fe78793          	addi	a5,a5,254 # ffffffffc02e1150 <hash_list>
ffffffffc020505a:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc020505c:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020505e:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0205060:	a029                	j	ffffffffc020506a <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0205062:	f2c52703          	lw	a4,-212(a0)
ffffffffc0205066:	00c70963          	beq	a4,a2,ffffffffc0205078 <do_kill+0x46>
ffffffffc020506a:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc020506c:	fea69be3          	bne	a3,a0,ffffffffc0205062 <do_kill+0x30>
}
ffffffffc0205070:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0205072:	5575                	li	a0,-3
}
ffffffffc0205074:	6105                	addi	sp,sp,32
ffffffffc0205076:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0205078:	fd852703          	lw	a4,-40(a0)
ffffffffc020507c:	00177693          	andi	a3,a4,1
ffffffffc0205080:	e29d                	bnez	a3,ffffffffc02050a6 <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205082:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205084:	00176713          	ori	a4,a4,1
ffffffffc0205088:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc020508c:	0006c663          	bltz	a3,ffffffffc0205098 <do_kill+0x66>
            return 0;
ffffffffc0205090:	4501                	li	a0,0
}
ffffffffc0205092:	60e2                	ld	ra,24(sp)
ffffffffc0205094:	6105                	addi	sp,sp,32
ffffffffc0205096:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205098:	f2850513          	addi	a0,a0,-216
ffffffffc020509c:	342000ef          	jal	ffffffffc02053de <wakeup_proc>
ffffffffc02050a0:	bfc5                	j	ffffffffc0205090 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc02050a2:	5575                	li	a0,-3
}
ffffffffc02050a4:	8082                	ret
        return -E_KILLED;
ffffffffc02050a6:	555d                	li	a0,-9
ffffffffc02050a8:	b7ed                	j	ffffffffc0205092 <do_kill+0x60>

ffffffffc02050aa <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc02050aa:	1101                	addi	sp,sp,-32
ffffffffc02050ac:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02050ae:	000e0797          	auipc	a5,0xe0
ffffffffc02050b2:	0a278793          	addi	a5,a5,162 # ffffffffc02e5150 <proc_list>
ffffffffc02050b6:	ec06                	sd	ra,24(sp)
ffffffffc02050b8:	e822                	sd	s0,16(sp)
ffffffffc02050ba:	e04a                	sd	s2,0(sp)
ffffffffc02050bc:	000dc497          	auipc	s1,0xdc
ffffffffc02050c0:	09448493          	addi	s1,s1,148 # ffffffffc02e1150 <hash_list>
ffffffffc02050c4:	e79c                	sd	a5,8(a5)
ffffffffc02050c6:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc02050c8:	000e0717          	auipc	a4,0xe0
ffffffffc02050cc:	08870713          	addi	a4,a4,136 # ffffffffc02e5150 <proc_list>
ffffffffc02050d0:	87a6                	mv	a5,s1
ffffffffc02050d2:	e79c                	sd	a5,8(a5)
ffffffffc02050d4:	e39c                	sd	a5,0(a5)
ffffffffc02050d6:	07c1                	addi	a5,a5,16
ffffffffc02050d8:	fee79de3          	bne	a5,a4,ffffffffc02050d2 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02050dc:	ea7fe0ef          	jal	ffffffffc0203f82 <alloc_proc>
ffffffffc02050e0:	000e0917          	auipc	s2,0xe0
ffffffffc02050e4:	18890913          	addi	s2,s2,392 # ffffffffc02e5268 <idleproc>
ffffffffc02050e8:	00a93023          	sd	a0,0(s2)
ffffffffc02050ec:	10050363          	beqz	a0,ffffffffc02051f2 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02050f0:	4789                	li	a5,2
ffffffffc02050f2:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02050f4:	00004797          	auipc	a5,0x4
ffffffffc02050f8:	f0c78793          	addi	a5,a5,-244 # ffffffffc0209000 <bootstack>
ffffffffc02050fc:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050fe:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc0205102:	4785                	li	a5,1
ffffffffc0205104:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205106:	4641                	li	a2,16
ffffffffc0205108:	8522                	mv	a0,s0
ffffffffc020510a:	4581                	li	a1,0
ffffffffc020510c:	664000ef          	jal	ffffffffc0205770 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205110:	8522                	mv	a0,s0
ffffffffc0205112:	463d                	li	a2,15
ffffffffc0205114:	00002597          	auipc	a1,0x2
ffffffffc0205118:	58458593          	addi	a1,a1,1412 # ffffffffc0207698 <etext+0x1b1c>
ffffffffc020511c:	666000ef          	jal	ffffffffc0205782 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205120:	000e0797          	auipc	a5,0xe0
ffffffffc0205124:	1307a783          	lw	a5,304(a5) # ffffffffc02e5250 <nr_process>

    current = idleproc;
ffffffffc0205128:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020512c:	4601                	li	a2,0
    nr_process++;
ffffffffc020512e:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205130:	4581                	li	a1,0
ffffffffc0205132:	fffff517          	auipc	a0,0xfffff
ffffffffc0205136:	76650513          	addi	a0,a0,1894 # ffffffffc0204898 <init_main>
    current = idleproc;
ffffffffc020513a:	000e0697          	auipc	a3,0xe0
ffffffffc020513e:	10e6bf23          	sd	a4,286(a3) # ffffffffc02e5258 <current>
    nr_process++;
ffffffffc0205142:	000e0717          	auipc	a4,0xe0
ffffffffc0205146:	10f72723          	sw	a5,270(a4) # ffffffffc02e5250 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020514a:	bd8ff0ef          	jal	ffffffffc0204522 <kernel_thread>
ffffffffc020514e:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205150:	08a05563          	blez	a0,ffffffffc02051da <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205154:	6789                	lui	a5,0x2
ffffffffc0205156:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x74b2>
ffffffffc0205158:	fff5071b          	addiw	a4,a0,-1
ffffffffc020515c:	02e7e463          	bltu	a5,a4,ffffffffc0205184 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205160:	45a9                	li	a1,10
ffffffffc0205162:	205000ef          	jal	ffffffffc0205b66 <hash32>
ffffffffc0205166:	02051713          	slli	a4,a0,0x20
ffffffffc020516a:	01c75793          	srli	a5,a4,0x1c
ffffffffc020516e:	00f486b3          	add	a3,s1,a5
ffffffffc0205172:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205174:	a029                	j	ffffffffc020517e <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc0205176:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020517a:	04870d63          	beq	a4,s0,ffffffffc02051d4 <proc_init+0x12a>
    return listelm->next;
ffffffffc020517e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205180:	fef69be3          	bne	a3,a5,ffffffffc0205176 <proc_init+0xcc>
    return NULL;
ffffffffc0205184:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205186:	0b478413          	addi	s0,a5,180
ffffffffc020518a:	4641                	li	a2,16
ffffffffc020518c:	4581                	li	a1,0
ffffffffc020518e:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205190:	000e0717          	auipc	a4,0xe0
ffffffffc0205194:	0cf73823          	sd	a5,208(a4) # ffffffffc02e5260 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205198:	5d8000ef          	jal	ffffffffc0205770 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020519c:	8522                	mv	a0,s0
ffffffffc020519e:	463d                	li	a2,15
ffffffffc02051a0:	00002597          	auipc	a1,0x2
ffffffffc02051a4:	52058593          	addi	a1,a1,1312 # ffffffffc02076c0 <etext+0x1b44>
ffffffffc02051a8:	5da000ef          	jal	ffffffffc0205782 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02051ac:	00093783          	ld	a5,0(s2)
ffffffffc02051b0:	cfad                	beqz	a5,ffffffffc020522a <proc_init+0x180>
ffffffffc02051b2:	43dc                	lw	a5,4(a5)
ffffffffc02051b4:	ebbd                	bnez	a5,ffffffffc020522a <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02051b6:	000e0797          	auipc	a5,0xe0
ffffffffc02051ba:	0aa7b783          	ld	a5,170(a5) # ffffffffc02e5260 <initproc>
ffffffffc02051be:	c7b1                	beqz	a5,ffffffffc020520a <proc_init+0x160>
ffffffffc02051c0:	43d8                	lw	a4,4(a5)
ffffffffc02051c2:	4785                	li	a5,1
ffffffffc02051c4:	04f71363          	bne	a4,a5,ffffffffc020520a <proc_init+0x160>
}
ffffffffc02051c8:	60e2                	ld	ra,24(sp)
ffffffffc02051ca:	6442                	ld	s0,16(sp)
ffffffffc02051cc:	64a2                	ld	s1,8(sp)
ffffffffc02051ce:	6902                	ld	s2,0(sp)
ffffffffc02051d0:	6105                	addi	sp,sp,32
ffffffffc02051d2:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02051d4:	f2878793          	addi	a5,a5,-216
ffffffffc02051d8:	b77d                	j	ffffffffc0205186 <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc02051da:	00002617          	auipc	a2,0x2
ffffffffc02051de:	4c660613          	addi	a2,a2,1222 # ffffffffc02076a0 <etext+0x1b24>
ffffffffc02051e2:	3cb00593          	li	a1,971
ffffffffc02051e6:	00002517          	auipc	a0,0x2
ffffffffc02051ea:	11a50513          	addi	a0,a0,282 # ffffffffc0207300 <etext+0x1784>
ffffffffc02051ee:	83efb0ef          	jal	ffffffffc020022c <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02051f2:	00002617          	auipc	a2,0x2
ffffffffc02051f6:	48e60613          	addi	a2,a2,1166 # ffffffffc0207680 <etext+0x1b04>
ffffffffc02051fa:	3bc00593          	li	a1,956
ffffffffc02051fe:	00002517          	auipc	a0,0x2
ffffffffc0205202:	10250513          	addi	a0,a0,258 # ffffffffc0207300 <etext+0x1784>
ffffffffc0205206:	826fb0ef          	jal	ffffffffc020022c <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020520a:	00002697          	auipc	a3,0x2
ffffffffc020520e:	4e668693          	addi	a3,a3,1254 # ffffffffc02076f0 <etext+0x1b74>
ffffffffc0205212:	00001617          	auipc	a2,0x1
ffffffffc0205216:	3de60613          	addi	a2,a2,990 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020521a:	3d200593          	li	a1,978
ffffffffc020521e:	00002517          	auipc	a0,0x2
ffffffffc0205222:	0e250513          	addi	a0,a0,226 # ffffffffc0207300 <etext+0x1784>
ffffffffc0205226:	806fb0ef          	jal	ffffffffc020022c <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020522a:	00002697          	auipc	a3,0x2
ffffffffc020522e:	49e68693          	addi	a3,a3,1182 # ffffffffc02076c8 <etext+0x1b4c>
ffffffffc0205232:	00001617          	auipc	a2,0x1
ffffffffc0205236:	3be60613          	addi	a2,a2,958 # ffffffffc02065f0 <etext+0xa74>
ffffffffc020523a:	3d100593          	li	a1,977
ffffffffc020523e:	00002517          	auipc	a0,0x2
ffffffffc0205242:	0c250513          	addi	a0,a0,194 # ffffffffc0207300 <etext+0x1784>
ffffffffc0205246:	fe7fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020524a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc020524a:	1141                	addi	sp,sp,-16
ffffffffc020524c:	e022                	sd	s0,0(sp)
ffffffffc020524e:	e406                	sd	ra,8(sp)
ffffffffc0205250:	000e0417          	auipc	s0,0xe0
ffffffffc0205254:	00840413          	addi	s0,s0,8 # ffffffffc02e5258 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205258:	6018                	ld	a4,0(s0)
ffffffffc020525a:	6f1c                	ld	a5,24(a4)
ffffffffc020525c:	dffd                	beqz	a5,ffffffffc020525a <cpu_idle+0x10>
        {
            schedule();
ffffffffc020525e:	278000ef          	jal	ffffffffc02054d6 <schedule>
ffffffffc0205262:	bfdd                	j	ffffffffc0205258 <cpu_idle+0xe>

ffffffffc0205264 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0205264:	1101                	addi	sp,sp,-32
ffffffffc0205266:	85aa                	mv	a1,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205268:	e42a                	sd	a0,8(sp)
ffffffffc020526a:	00002517          	auipc	a0,0x2
ffffffffc020526e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0207718 <etext+0x1b9c>
{
ffffffffc0205272:	ec06                	sd	ra,24(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205274:	e6ffa0ef          	jal	ffffffffc02000e2 <cprintf>
    if (priority == 0)
ffffffffc0205278:	65a2                	ld	a1,8(sp)
        current->lab6_priority = 1;
ffffffffc020527a:	000e0717          	auipc	a4,0xe0
ffffffffc020527e:	fde73703          	ld	a4,-34(a4) # ffffffffc02e5258 <current>
    if (priority == 0)
ffffffffc0205282:	4785                	li	a5,1
ffffffffc0205284:	c191                	beqz	a1,ffffffffc0205288 <lab6_set_priority+0x24>
ffffffffc0205286:	87ae                	mv	a5,a1
    else
        current->lab6_priority = priority;
}
ffffffffc0205288:	60e2                	ld	ra,24(sp)
        current->lab6_priority = 1;
ffffffffc020528a:	14f72223          	sw	a5,324(a4)
}
ffffffffc020528e:	6105                	addi	sp,sp,32
ffffffffc0205290:	8082                	ret

ffffffffc0205292 <sched_set_burst>:

void sched_set_burst(uint32_t expected, uint32_t remaining)
{
    if (expected == 0)
ffffffffc0205292:	87aa                	mv	a5,a0
ffffffffc0205294:	e111                	bnez	a0,ffffffffc0205298 <sched_set_burst+0x6>
ffffffffc0205296:	4785                	li	a5,1
    {
        expected = 1;
    }
    current->sched_expected = expected;
ffffffffc0205298:	000e0717          	auipc	a4,0xe0
ffffffffc020529c:	fc073703          	ld	a4,-64(a4) # ffffffffc02e5258 <current>
    if (expected == 0)
ffffffffc02052a0:	0007869b          	sext.w	a3,a5
    current->sched_expected = expected;
ffffffffc02052a4:	14f72423          	sw	a5,328(a4)
    if (remaining == 0)
ffffffffc02052a8:	c191                	beqz	a1,ffffffffc02052ac <sched_set_burst+0x1a>
ffffffffc02052aa:	86ae                	mv	a3,a1
    {
        remaining = expected;
    }
    current->sched_remaining = remaining;
ffffffffc02052ac:	14d72623          	sw	a3,332(a4)
}
ffffffffc02052b0:	8082                	ret

ffffffffc02052b2 <sched_set_nice>:
{
    if (nice < -20)
    {
        nice = -20;
    }
    if (nice > 19)
ffffffffc02052b2:	474d                	li	a4,19
    {
        nice = 19;
    }
    current->sched_nice = nice;
ffffffffc02052b4:	000e0697          	auipc	a3,0xe0
ffffffffc02052b8:	fa46b683          	ld	a3,-92(a3) # ffffffffc02e5258 <current>
    if (nice > 19)
ffffffffc02052bc:	87aa                	mv	a5,a0
ffffffffc02052be:	00a75363          	bge	a4,a0,ffffffffc02052c4 <sched_set_nice+0x12>
ffffffffc02052c2:	87ba                	mv	a5,a4
    if (nice < -20)
ffffffffc02052c4:	0007861b          	sext.w	a2,a5
ffffffffc02052c8:	5731                	li	a4,-20
ffffffffc02052ca:	00e65363          	bge	a2,a4,ffffffffc02052d0 <sched_set_nice+0x1e>
ffffffffc02052ce:	87ba                	mv	a5,a4
    current->sched_nice = nice;
ffffffffc02052d0:	16f6a623          	sw	a5,364(a3)
}
ffffffffc02052d4:	8082                	ret

ffffffffc02052d6 <RR_init>:
    elm->prev = elm->next = elm;
ffffffffc02052d6:	e508                	sd	a0,8(a0)
ffffffffc02052d8:	e108                	sd	a0,0(a0)
 */
static void
RR_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc02052da:	00052823          	sw	zero,16(a0)
    rq->lab6_run_pool = NULL;
ffffffffc02052de:	00053c23          	sd	zero,24(a0)
}
ffffffffc02052e2:	8082                	ret

ffffffffc02052e4 <RR_enqueue>:
 * hint: see libs/list.h for routines of the list structures.
 */
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice)
ffffffffc02052e4:	1205a783          	lw	a5,288(a1)
ffffffffc02052e8:	4958                	lw	a4,20(a0)
ffffffffc02052ea:	c399                	beqz	a5,ffffffffc02052f0 <RR_enqueue+0xc>
ffffffffc02052ec:	00f75463          	bge	a4,a5,ffffffffc02052f4 <RR_enqueue+0x10>
    {
        proc->time_slice = rq->max_time_slice;
ffffffffc02052f0:	12e5a023          	sw	a4,288(a1)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02052f4:	6118                	ld	a4,0(a0)
    }
    list_add_before(&(rq->run_list), &(proc->run_link));
    proc->rq = rq;
    rq->proc_num++;
ffffffffc02052f6:	491c                	lw	a5,16(a0)
    list_add_before(&(rq->run_list), &(proc->run_link));
ffffffffc02052f8:	11058693          	addi	a3,a1,272
    prev->next = next->prev = elm;
ffffffffc02052fc:	e114                	sd	a3,0(a0)
ffffffffc02052fe:	e714                	sd	a3,8(a4)
    elm->prev = prev;
ffffffffc0205300:	10e5b823          	sd	a4,272(a1)
    elm->next = next;
ffffffffc0205304:	10a5bc23          	sd	a0,280(a1)
    proc->rq = rq;
ffffffffc0205308:	10a5b423          	sd	a0,264(a1)
    rq->proc_num++;
ffffffffc020530c:	2785                	addiw	a5,a5,1
ffffffffc020530e:	c91c                	sw	a5,16(a0)
}
ffffffffc0205310:	8082                	ret

ffffffffc0205312 <RR_dequeue>:
    __list_del(listelm->prev, listelm->next);
ffffffffc0205312:	1185b703          	ld	a4,280(a1)
ffffffffc0205316:	1105b683          	ld	a3,272(a1)
 */
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
    list_del_init(&(proc->run_link));
    rq->proc_num--;
ffffffffc020531a:	491c                	lw	a5,16(a0)
    prev->next = next;
ffffffffc020531c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020531e:	e314                	sd	a3,0(a4)
    list_del_init(&(proc->run_link));
ffffffffc0205320:	11058713          	addi	a4,a1,272
    rq->proc_num--;
ffffffffc0205324:	37fd                	addiw	a5,a5,-1
    elm->prev = elm->next = elm;
ffffffffc0205326:	10e5bc23          	sd	a4,280(a1)
ffffffffc020532a:	10e5b823          	sd	a4,272(a1)
ffffffffc020532e:	c91c                	sw	a5,16(a0)
}
ffffffffc0205330:	8082                	ret

ffffffffc0205332 <RR_pick_next>:
    return listelm->next;
ffffffffc0205332:	651c                	ld	a5,8(a0)
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list))
ffffffffc0205334:	00f50563          	beq	a0,a5,ffffffffc020533e <RR_pick_next+0xc>
    {
        return le2proc(le, run_link);
ffffffffc0205338:	ef078513          	addi	a0,a5,-272
ffffffffc020533c:	8082                	ret
    }
    return NULL;
ffffffffc020533e:	4501                	li	a0,0
}
ffffffffc0205340:	8082                	ret

ffffffffc0205342 <RR_proc_tick>:
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice > 0)
ffffffffc0205342:	1205a783          	lw	a5,288(a1)
ffffffffc0205346:	00f05563          	blez	a5,ffffffffc0205350 <RR_proc_tick+0xe>
    {
        proc->time_slice--;
ffffffffc020534a:	37fd                	addiw	a5,a5,-1
ffffffffc020534c:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0)
ffffffffc0205350:	e399                	bnez	a5,ffffffffc0205356 <RR_proc_tick+0x14>
    {
        proc->need_resched = 1;
ffffffffc0205352:	4785                	li	a5,1
ffffffffc0205354:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0205356:	8082                	ret

ffffffffc0205358 <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
ffffffffc0205358:	000e0797          	auipc	a5,0xe0
ffffffffc020535c:	f107b783          	ld	a5,-240(a5) # ffffffffc02e5268 <idleproc>
{
ffffffffc0205360:	85aa                	mv	a1,a0
    if (proc != idleproc)
ffffffffc0205362:	02a78163          	beq	a5,a0,ffffffffc0205384 <sched_class_proc_tick+0x2c>
    {
        proc->sched_runtime_ticks++;
        sched_class->proc_tick(rq, proc);
ffffffffc0205366:	000e0717          	auipc	a4,0xe0
ffffffffc020536a:	f1273703          	ld	a4,-238(a4) # ffffffffc02e5278 <sched_class>
        proc->sched_runtime_ticks++;
ffffffffc020536e:	15852783          	lw	a5,344(a0)
        sched_class->proc_tick(rq, proc);
ffffffffc0205372:	000e0517          	auipc	a0,0xe0
ffffffffc0205376:	efe53503          	ld	a0,-258(a0) # ffffffffc02e5270 <rq>
ffffffffc020537a:	7718                	ld	a4,40(a4)
        proc->sched_runtime_ticks++;
ffffffffc020537c:	2785                	addiw	a5,a5,1
ffffffffc020537e:	14f5ac23          	sw	a5,344(a1)
        sched_class->proc_tick(rq, proc);
ffffffffc0205382:	8702                	jr	a4
    }
    else
    {
        proc->need_resched = 1;
ffffffffc0205384:	4705                	li	a4,1
ffffffffc0205386:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc0205388:	8082                	ret

ffffffffc020538a <sched_init>:
    case SCHED_POLICY_CFS:
        sched_class = &cfs_sched_class;
        break;
    case SCHED_POLICY_RR:
    default:
        sched_class = &default_sched_class;
ffffffffc020538a:	000dc797          	auipc	a5,0xdc
ffffffffc020538e:	96e78793          	addi	a5,a5,-1682 # ffffffffc02e0cf8 <default_sched_class>
{
ffffffffc0205392:	1141                	addi	sp,sp,-16
        break;
    }

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0205394:	6794                	ld	a3,8(a5)
        sched_class = &default_sched_class;
ffffffffc0205396:	000e0717          	auipc	a4,0xe0
ffffffffc020539a:	eef73123          	sd	a5,-286(a4) # ffffffffc02e5278 <sched_class>
{
ffffffffc020539e:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02053a0:	000e0797          	auipc	a5,0xe0
ffffffffc02053a4:	e4078793          	addi	a5,a5,-448 # ffffffffc02e51e0 <timer_list>
    rq = &__rq;
ffffffffc02053a8:	000e0717          	auipc	a4,0xe0
ffffffffc02053ac:	db870713          	addi	a4,a4,-584 # ffffffffc02e5160 <__rq>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02053b0:	4615                	li	a2,5
ffffffffc02053b2:	e79c                	sd	a5,8(a5)
ffffffffc02053b4:	e39c                	sd	a5,0(a5)
    sched_class->init(rq);
ffffffffc02053b6:	853a                	mv	a0,a4
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02053b8:	cb50                	sw	a2,20(a4)
    rq = &__rq;
ffffffffc02053ba:	000e0797          	auipc	a5,0xe0
ffffffffc02053be:	eae7bb23          	sd	a4,-330(a5) # ffffffffc02e5270 <rq>
    sched_class->init(rq);
ffffffffc02053c2:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02053c4:	000e0797          	auipc	a5,0xe0
ffffffffc02053c8:	eb47b783          	ld	a5,-332(a5) # ffffffffc02e5278 <sched_class>
}
ffffffffc02053cc:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02053ce:	00002517          	auipc	a0,0x2
ffffffffc02053d2:	37250513          	addi	a0,a0,882 # ffffffffc0207740 <etext+0x1bc4>
ffffffffc02053d6:	638c                	ld	a1,0(a5)
}
ffffffffc02053d8:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02053da:	d09fa06f          	j	ffffffffc02000e2 <cprintf>

ffffffffc02053de <wakeup_proc>:

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053de:	4118                	lw	a4,0(a0)
{
ffffffffc02053e0:	1101                	addi	sp,sp,-32
ffffffffc02053e2:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02053e4:	478d                	li	a5,3
ffffffffc02053e6:	0cf70863          	beq	a4,a5,ffffffffc02054b6 <wakeup_proc+0xd8>
ffffffffc02053ea:	85aa                	mv	a1,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02053ec:	100027f3          	csrr	a5,sstatus
ffffffffc02053f0:	8b89                	andi	a5,a5,2
ffffffffc02053f2:	e3b1                	bnez	a5,ffffffffc0205436 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc02053f4:	4789                	li	a5,2
ffffffffc02053f6:	08f70563          	beq	a4,a5,ffffffffc0205480 <wakeup_proc+0xa2>
        {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current)
ffffffffc02053fa:	000e0717          	auipc	a4,0xe0
ffffffffc02053fe:	e5e73703          	ld	a4,-418(a4) # ffffffffc02e5258 <current>
            proc->wait_state = 0;
ffffffffc0205402:	0e052623          	sw	zero,236(a0)
            proc->state = PROC_RUNNABLE;
ffffffffc0205406:	c11c                	sw	a5,0(a0)
            if (proc != current)
ffffffffc0205408:	02e50463          	beq	a0,a4,ffffffffc0205430 <wakeup_proc+0x52>
    if (proc != idleproc)
ffffffffc020540c:	000e0797          	auipc	a5,0xe0
ffffffffc0205410:	e5c7b783          	ld	a5,-420(a5) # ffffffffc02e5268 <idleproc>
ffffffffc0205414:	00f50e63          	beq	a0,a5,ffffffffc0205430 <wakeup_proc+0x52>
        sched_class->enqueue(rq, proc);
ffffffffc0205418:	000e0797          	auipc	a5,0xe0
ffffffffc020541c:	e607b783          	ld	a5,-416(a5) # ffffffffc02e5278 <sched_class>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205420:	60e2                	ld	ra,24(sp)
        sched_class->enqueue(rq, proc);
ffffffffc0205422:	000e0517          	auipc	a0,0xe0
ffffffffc0205426:	e4e53503          	ld	a0,-434(a0) # ffffffffc02e5270 <rq>
ffffffffc020542a:	6b9c                	ld	a5,16(a5)
}
ffffffffc020542c:	6105                	addi	sp,sp,32
        sched_class->enqueue(rq, proc);
ffffffffc020542e:	8782                	jr	a5
}
ffffffffc0205430:	60e2                	ld	ra,24(sp)
ffffffffc0205432:	6105                	addi	sp,sp,32
ffffffffc0205434:	8082                	ret
        intr_disable();
ffffffffc0205436:	e42a                	sd	a0,8(sp)
ffffffffc0205438:	cccfb0ef          	jal	ffffffffc0200904 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc020543c:	65a2                	ld	a1,8(sp)
ffffffffc020543e:	4789                	li	a5,2
ffffffffc0205440:	4198                	lw	a4,0(a1)
ffffffffc0205442:	04f70d63          	beq	a4,a5,ffffffffc020549c <wakeup_proc+0xbe>
            if (proc != current)
ffffffffc0205446:	000e0717          	auipc	a4,0xe0
ffffffffc020544a:	e1273703          	ld	a4,-494(a4) # ffffffffc02e5258 <current>
            proc->wait_state = 0;
ffffffffc020544e:	0e05a623          	sw	zero,236(a1)
            proc->state = PROC_RUNNABLE;
ffffffffc0205452:	c19c                	sw	a5,0(a1)
            if (proc != current)
ffffffffc0205454:	02e58263          	beq	a1,a4,ffffffffc0205478 <wakeup_proc+0x9a>
    if (proc != idleproc)
ffffffffc0205458:	000e0797          	auipc	a5,0xe0
ffffffffc020545c:	e107b783          	ld	a5,-496(a5) # ffffffffc02e5268 <idleproc>
ffffffffc0205460:	00f58c63          	beq	a1,a5,ffffffffc0205478 <wakeup_proc+0x9a>
        sched_class->enqueue(rq, proc);
ffffffffc0205464:	000e0797          	auipc	a5,0xe0
ffffffffc0205468:	e147b783          	ld	a5,-492(a5) # ffffffffc02e5278 <sched_class>
ffffffffc020546c:	000e0517          	auipc	a0,0xe0
ffffffffc0205470:	e0453503          	ld	a0,-508(a0) # ffffffffc02e5270 <rq>
ffffffffc0205474:	6b9c                	ld	a5,16(a5)
ffffffffc0205476:	9782                	jalr	a5
}
ffffffffc0205478:	60e2                	ld	ra,24(sp)
ffffffffc020547a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020547c:	c82fb06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc0205480:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc0205482:	00002617          	auipc	a2,0x2
ffffffffc0205486:	30e60613          	addi	a2,a2,782 # ffffffffc0207790 <etext+0x1c14>
ffffffffc020548a:	06e00593          	li	a1,110
ffffffffc020548e:	00002517          	auipc	a0,0x2
ffffffffc0205492:	2ea50513          	addi	a0,a0,746 # ffffffffc0207778 <etext+0x1bfc>
}
ffffffffc0205496:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc0205498:	dfffa06f          	j	ffffffffc0200296 <__warn>
ffffffffc020549c:	00002617          	auipc	a2,0x2
ffffffffc02054a0:	2f460613          	addi	a2,a2,756 # ffffffffc0207790 <etext+0x1c14>
ffffffffc02054a4:	06e00593          	li	a1,110
ffffffffc02054a8:	00002517          	auipc	a0,0x2
ffffffffc02054ac:	2d050513          	addi	a0,a0,720 # ffffffffc0207778 <etext+0x1bfc>
ffffffffc02054b0:	de7fa0ef          	jal	ffffffffc0200296 <__warn>
    if (flag)
ffffffffc02054b4:	b7d1                	j	ffffffffc0205478 <wakeup_proc+0x9a>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02054b6:	00002697          	auipc	a3,0x2
ffffffffc02054ba:	2a268693          	addi	a3,a3,674 # ffffffffc0207758 <etext+0x1bdc>
ffffffffc02054be:	00001617          	auipc	a2,0x1
ffffffffc02054c2:	13260613          	addi	a2,a2,306 # ffffffffc02065f0 <etext+0xa74>
ffffffffc02054c6:	05f00593          	li	a1,95
ffffffffc02054ca:	00002517          	auipc	a0,0x2
ffffffffc02054ce:	2ae50513          	addi	a0,a0,686 # ffffffffc0207778 <etext+0x1bfc>
ffffffffc02054d2:	d5bfa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02054d6 <schedule>:

void schedule(void)
{
ffffffffc02054d6:	7139                	addi	sp,sp,-64
ffffffffc02054d8:	fc06                	sd	ra,56(sp)
ffffffffc02054da:	f822                	sd	s0,48(sp)
ffffffffc02054dc:	f426                	sd	s1,40(sp)
ffffffffc02054de:	f04a                	sd	s2,32(sp)
ffffffffc02054e0:	ec4e                	sd	s3,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02054e2:	100027f3          	csrr	a5,sstatus
ffffffffc02054e6:	8b89                	andi	a5,a5,2
ffffffffc02054e8:	4981                	li	s3,0
ffffffffc02054ea:	efc9                	bnez	a5,ffffffffc0205584 <schedule+0xae>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02054ec:	000e0417          	auipc	s0,0xe0
ffffffffc02054f0:	d6c40413          	addi	s0,s0,-660 # ffffffffc02e5258 <current>
ffffffffc02054f4:	600c                	ld	a1,0(s0)
        if (current->state == PROC_RUNNABLE)
ffffffffc02054f6:	4789                	li	a5,2
ffffffffc02054f8:	000e0497          	auipc	s1,0xe0
ffffffffc02054fc:	d7848493          	addi	s1,s1,-648 # ffffffffc02e5270 <rq>
ffffffffc0205500:	4198                	lw	a4,0(a1)
        current->need_resched = 0;
ffffffffc0205502:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205506:	000e0917          	auipc	s2,0xe0
ffffffffc020550a:	d7290913          	addi	s2,s2,-654 # ffffffffc02e5278 <sched_class>
ffffffffc020550e:	04f70f63          	beq	a4,a5,ffffffffc020556c <schedule+0x96>
    return sched_class->pick_next(rq);
ffffffffc0205512:	00093783          	ld	a5,0(s2)
ffffffffc0205516:	6088                	ld	a0,0(s1)
ffffffffc0205518:	739c                	ld	a5,32(a5)
ffffffffc020551a:	9782                	jalr	a5
ffffffffc020551c:	85aa                	mv	a1,a0
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
ffffffffc020551e:	c131                	beqz	a0,ffffffffc0205562 <schedule+0x8c>
    sched_class->dequeue(rq, proc);
ffffffffc0205520:	00093783          	ld	a5,0(s2)
ffffffffc0205524:	6088                	ld	a0,0(s1)
ffffffffc0205526:	e42e                	sd	a1,8(sp)
ffffffffc0205528:	6f9c                	ld	a5,24(a5)
ffffffffc020552a:	9782                	jalr	a5
ffffffffc020552c:	65a2                	ld	a1,8(sp)
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc020552e:	459c                	lw	a5,8(a1)
        if (next != current)
ffffffffc0205530:	6018                	ld	a4,0(s0)
        next->runs++;
ffffffffc0205532:	2785                	addiw	a5,a5,1
ffffffffc0205534:	c59c                	sw	a5,8(a1)
        if (next != current)
ffffffffc0205536:	00b70563          	beq	a4,a1,ffffffffc0205540 <schedule+0x6a>
        {
            proc_run(next);
ffffffffc020553a:	852e                	mv	a0,a1
ffffffffc020553c:	b81fe0ef          	jal	ffffffffc02040bc <proc_run>
    if (flag)
ffffffffc0205540:	00099963          	bnez	s3,ffffffffc0205552 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205544:	70e2                	ld	ra,56(sp)
ffffffffc0205546:	7442                	ld	s0,48(sp)
ffffffffc0205548:	74a2                	ld	s1,40(sp)
ffffffffc020554a:	7902                	ld	s2,32(sp)
ffffffffc020554c:	69e2                	ld	s3,24(sp)
ffffffffc020554e:	6121                	addi	sp,sp,64
ffffffffc0205550:	8082                	ret
ffffffffc0205552:	7442                	ld	s0,48(sp)
ffffffffc0205554:	70e2                	ld	ra,56(sp)
ffffffffc0205556:	74a2                	ld	s1,40(sp)
ffffffffc0205558:	7902                	ld	s2,32(sp)
ffffffffc020555a:	69e2                	ld	s3,24(sp)
ffffffffc020555c:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc020555e:	ba0fb06f          	j	ffffffffc02008fe <intr_enable>
            next = idleproc;
ffffffffc0205562:	000e0597          	auipc	a1,0xe0
ffffffffc0205566:	d065b583          	ld	a1,-762(a1) # ffffffffc02e5268 <idleproc>
ffffffffc020556a:	b7d1                	j	ffffffffc020552e <schedule+0x58>
    if (proc != idleproc)
ffffffffc020556c:	000e0797          	auipc	a5,0xe0
ffffffffc0205570:	cfc7b783          	ld	a5,-772(a5) # ffffffffc02e5268 <idleproc>
ffffffffc0205574:	f8f58fe3          	beq	a1,a5,ffffffffc0205512 <schedule+0x3c>
        sched_class->enqueue(rq, proc);
ffffffffc0205578:	00093783          	ld	a5,0(s2)
ffffffffc020557c:	6088                	ld	a0,0(s1)
ffffffffc020557e:	6b9c                	ld	a5,16(a5)
ffffffffc0205580:	9782                	jalr	a5
ffffffffc0205582:	bf41                	j	ffffffffc0205512 <schedule+0x3c>
        intr_disable();
ffffffffc0205584:	b80fb0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0205588:	4985                	li	s3,1
ffffffffc020558a:	b78d                	j	ffffffffc02054ec <schedule+0x16>

ffffffffc020558c <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020558c:	000e0797          	auipc	a5,0xe0
ffffffffc0205590:	ccc7b783          	ld	a5,-820(a5) # ffffffffc02e5258 <current>
}
ffffffffc0205594:	43c8                	lw	a0,4(a5)
ffffffffc0205596:	8082                	ret

ffffffffc0205598 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205598:	4501                	li	a0,0
ffffffffc020559a:	8082                	ret

ffffffffc020559c <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc020559c:	000e0797          	auipc	a5,0xe0
ffffffffc02055a0:	c6c7b783          	ld	a5,-916(a5) # ffffffffc02e5208 <ticks>
ffffffffc02055a4:	0027951b          	slliw	a0,a5,0x2
ffffffffc02055a8:	9d3d                	addw	a0,a0,a5
ffffffffc02055aa:	0015151b          	slliw	a0,a0,0x1
}
ffffffffc02055ae:	8082                	ret

ffffffffc02055b0 <sys_sched_get_runtime>:
    sched_set_nice(nice);
    return 0;
}
static int sys_sched_get_runtime(uint64_t arg[]){
    (void)arg;
    return (int)current->sched_runtime_ticks;
ffffffffc02055b0:	000e0797          	auipc	a5,0xe0
ffffffffc02055b4:	ca87b783          	ld	a5,-856(a5) # ffffffffc02e5258 <current>
}
ffffffffc02055b8:	1587a503          	lw	a0,344(a5)
ffffffffc02055bc:	8082                	ret

ffffffffc02055be <sys_lab6_set_priority>:
    lab6_set_priority(priority);
ffffffffc02055be:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc02055c0:	1141                	addi	sp,sp,-16
ffffffffc02055c2:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc02055c4:	ca1ff0ef          	jal	ffffffffc0205264 <lab6_set_priority>
}
ffffffffc02055c8:	60a2                	ld	ra,8(sp)
ffffffffc02055ca:	4501                	li	a0,0
ffffffffc02055cc:	0141                	addi	sp,sp,16
ffffffffc02055ce:	8082                	ret

ffffffffc02055d0 <sys_sched_set_nice>:
    sched_set_nice(nice);
ffffffffc02055d0:	4108                	lw	a0,0(a0)
static int sys_sched_set_nice(uint64_t arg[]){
ffffffffc02055d2:	1141                	addi	sp,sp,-16
ffffffffc02055d4:	e406                	sd	ra,8(sp)
    sched_set_nice(nice);
ffffffffc02055d6:	cddff0ef          	jal	ffffffffc02052b2 <sched_set_nice>
}
ffffffffc02055da:	60a2                	ld	ra,8(sp)
ffffffffc02055dc:	4501                	li	a0,0
ffffffffc02055de:	0141                	addi	sp,sp,16
ffffffffc02055e0:	8082                	ret

ffffffffc02055e2 <sys_sched_set_burst>:
    sched_set_burst(expected, remaining);
ffffffffc02055e2:	450c                	lw	a1,8(a0)
ffffffffc02055e4:	4108                	lw	a0,0(a0)
static int sys_sched_set_burst(uint64_t arg[]){
ffffffffc02055e6:	1141                	addi	sp,sp,-16
ffffffffc02055e8:	e406                	sd	ra,8(sp)
    sched_set_burst(expected, remaining);
ffffffffc02055ea:	ca9ff0ef          	jal	ffffffffc0205292 <sched_set_burst>
}
ffffffffc02055ee:	60a2                	ld	ra,8(sp)
ffffffffc02055f0:	4501                	li	a0,0
ffffffffc02055f2:	0141                	addi	sp,sp,16
ffffffffc02055f4:	8082                	ret

ffffffffc02055f6 <sys_putc>:
    cputchar(c);
ffffffffc02055f6:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02055f8:	1141                	addi	sp,sp,-16
ffffffffc02055fa:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02055fc:	b1bfa0ef          	jal	ffffffffc0200116 <cputchar>
}
ffffffffc0205600:	60a2                	ld	ra,8(sp)
ffffffffc0205602:	4501                	li	a0,0
ffffffffc0205604:	0141                	addi	sp,sp,16
ffffffffc0205606:	8082                	ret

ffffffffc0205608 <sys_kill>:
    return do_kill(pid);
ffffffffc0205608:	4108                	lw	a0,0(a0)
ffffffffc020560a:	a29ff06f          	j	ffffffffc0205032 <do_kill>

ffffffffc020560e <sys_yield>:
    return do_yield();
ffffffffc020560e:	9dbff06f          	j	ffffffffc0204fe8 <do_yield>

ffffffffc0205612 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205612:	6d14                	ld	a3,24(a0)
ffffffffc0205614:	6910                	ld	a2,16(a0)
ffffffffc0205616:	650c                	ld	a1,8(a0)
ffffffffc0205618:	6108                	ld	a0,0(a0)
ffffffffc020561a:	ba2ff06f          	j	ffffffffc02049bc <do_execve>

ffffffffc020561e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020561e:	650c                	ld	a1,8(a0)
ffffffffc0205620:	4108                	lw	a0,0(a0)
ffffffffc0205622:	9d7ff06f          	j	ffffffffc0204ff8 <do_wait>

ffffffffc0205626 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205626:	000e0797          	auipc	a5,0xe0
ffffffffc020562a:	c327b783          	ld	a5,-974(a5) # ffffffffc02e5258 <current>
    return do_fork(0, stack, tf);
ffffffffc020562e:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205630:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205632:	6a0c                	ld	a1,16(a2)
ffffffffc0205634:	aebfe06f          	j	ffffffffc020411e <do_fork>

ffffffffc0205638 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205638:	4108                	lw	a0,0(a0)
ffffffffc020563a:	f39fe06f          	j	ffffffffc0204572 <do_exit>

ffffffffc020563e <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc020563e:	000e0697          	auipc	a3,0xe0
ffffffffc0205642:	c1a6b683          	ld	a3,-998(a3) # ffffffffc02e5258 <current>
syscall(void) {
ffffffffc0205646:	715d                	addi	sp,sp,-80
ffffffffc0205648:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc020564a:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc020564c:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020564e:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0205652:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205654:	02d7ec63          	bltu	a5,a3,ffffffffc020568c <syscall+0x4e>
        if (syscalls[num] != NULL) {
ffffffffc0205658:	00002797          	auipc	a5,0x2
ffffffffc020565c:	38078793          	addi	a5,a5,896 # ffffffffc02079d8 <syscalls>
ffffffffc0205660:	00369613          	slli	a2,a3,0x3
ffffffffc0205664:	97b2                	add	a5,a5,a2
ffffffffc0205666:	639c                	ld	a5,0(a5)
ffffffffc0205668:	c395                	beqz	a5,ffffffffc020568c <syscall+0x4e>
            arg[0] = tf->gpr.a1;
ffffffffc020566a:	7028                	ld	a0,96(s0)
ffffffffc020566c:	742c                	ld	a1,104(s0)
ffffffffc020566e:	7830                	ld	a2,112(s0)
ffffffffc0205670:	7c34                	ld	a3,120(s0)
ffffffffc0205672:	6c38                	ld	a4,88(s0)
ffffffffc0205674:	f02a                	sd	a0,32(sp)
ffffffffc0205676:	f42e                	sd	a1,40(sp)
ffffffffc0205678:	f832                	sd	a2,48(sp)
ffffffffc020567a:	fc36                	sd	a3,56(sp)
ffffffffc020567c:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020567e:	0828                	addi	a0,sp,24
ffffffffc0205680:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205682:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205684:	e828                	sd	a0,80(s0)
}
ffffffffc0205686:	6406                	ld	s0,64(sp)
ffffffffc0205688:	6161                	addi	sp,sp,80
ffffffffc020568a:	8082                	ret
    print_trapframe(tf);
ffffffffc020568c:	8522                	mv	a0,s0
ffffffffc020568e:	e436                	sd	a3,8(sp)
ffffffffc0205690:	c62fb0ef          	jal	ffffffffc0200af2 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205694:	000e0797          	auipc	a5,0xe0
ffffffffc0205698:	bc47b783          	ld	a5,-1084(a5) # ffffffffc02e5258 <current>
ffffffffc020569c:	66a2                	ld	a3,8(sp)
ffffffffc020569e:	00002617          	auipc	a2,0x2
ffffffffc02056a2:	11260613          	addi	a2,a2,274 # ffffffffc02077b0 <etext+0x1c34>
ffffffffc02056a6:	43d8                	lw	a4,4(a5)
ffffffffc02056a8:	07e00593          	li	a1,126
ffffffffc02056ac:	0b478793          	addi	a5,a5,180
ffffffffc02056b0:	00002517          	auipc	a0,0x2
ffffffffc02056b4:	13050513          	addi	a0,a0,304 # ffffffffc02077e0 <etext+0x1c64>
ffffffffc02056b8:	b75fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02056bc <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02056bc:	00054783          	lbu	a5,0(a0)
ffffffffc02056c0:	cb81                	beqz	a5,ffffffffc02056d0 <strlen+0x14>
    size_t cnt = 0;
ffffffffc02056c2:	4781                	li	a5,0
        cnt ++;
ffffffffc02056c4:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02056c6:	00f50733          	add	a4,a0,a5
ffffffffc02056ca:	00074703          	lbu	a4,0(a4)
ffffffffc02056ce:	fb7d                	bnez	a4,ffffffffc02056c4 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02056d0:	853e                	mv	a0,a5
ffffffffc02056d2:	8082                	ret

ffffffffc02056d4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02056d4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02056d6:	e589                	bnez	a1,ffffffffc02056e0 <strnlen+0xc>
ffffffffc02056d8:	a811                	j	ffffffffc02056ec <strnlen+0x18>
        cnt ++;
ffffffffc02056da:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02056dc:	00f58863          	beq	a1,a5,ffffffffc02056ec <strnlen+0x18>
ffffffffc02056e0:	00f50733          	add	a4,a0,a5
ffffffffc02056e4:	00074703          	lbu	a4,0(a4)
ffffffffc02056e8:	fb6d                	bnez	a4,ffffffffc02056da <strnlen+0x6>
ffffffffc02056ea:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02056ec:	852e                	mv	a0,a1
ffffffffc02056ee:	8082                	ret

ffffffffc02056f0 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02056f0:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02056f2:	0005c703          	lbu	a4,0(a1)
ffffffffc02056f6:	0585                	addi	a1,a1,1
ffffffffc02056f8:	0785                	addi	a5,a5,1
ffffffffc02056fa:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02056fe:	fb75                	bnez	a4,ffffffffc02056f2 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205700:	8082                	ret

ffffffffc0205702 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205702:	00054783          	lbu	a5,0(a0)
ffffffffc0205706:	e791                	bnez	a5,ffffffffc0205712 <strcmp+0x10>
ffffffffc0205708:	a01d                	j	ffffffffc020572e <strcmp+0x2c>
ffffffffc020570a:	00054783          	lbu	a5,0(a0)
ffffffffc020570e:	cb99                	beqz	a5,ffffffffc0205724 <strcmp+0x22>
ffffffffc0205710:	0585                	addi	a1,a1,1
ffffffffc0205712:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0205716:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205718:	fef709e3          	beq	a4,a5,ffffffffc020570a <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020571c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205720:	9d19                	subw	a0,a0,a4
ffffffffc0205722:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205724:	0015c703          	lbu	a4,1(a1)
ffffffffc0205728:	4501                	li	a0,0
}
ffffffffc020572a:	9d19                	subw	a0,a0,a4
ffffffffc020572c:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020572e:	0005c703          	lbu	a4,0(a1)
ffffffffc0205732:	4501                	li	a0,0
ffffffffc0205734:	b7f5                	j	ffffffffc0205720 <strcmp+0x1e>

ffffffffc0205736 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205736:	ce01                	beqz	a2,ffffffffc020574e <strncmp+0x18>
ffffffffc0205738:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020573c:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020573e:	cb91                	beqz	a5,ffffffffc0205752 <strncmp+0x1c>
ffffffffc0205740:	0005c703          	lbu	a4,0(a1)
ffffffffc0205744:	00f71763          	bne	a4,a5,ffffffffc0205752 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0205748:	0505                	addi	a0,a0,1
ffffffffc020574a:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020574c:	f675                	bnez	a2,ffffffffc0205738 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020574e:	4501                	li	a0,0
ffffffffc0205750:	8082                	ret
ffffffffc0205752:	00054503          	lbu	a0,0(a0)
ffffffffc0205756:	0005c783          	lbu	a5,0(a1)
ffffffffc020575a:	9d1d                	subw	a0,a0,a5
}
ffffffffc020575c:	8082                	ret

ffffffffc020575e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020575e:	a021                	j	ffffffffc0205766 <strchr+0x8>
        if (*s == c) {
ffffffffc0205760:	00f58763          	beq	a1,a5,ffffffffc020576e <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0205764:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205766:	00054783          	lbu	a5,0(a0)
ffffffffc020576a:	fbfd                	bnez	a5,ffffffffc0205760 <strchr+0x2>
    }
    return NULL;
ffffffffc020576c:	4501                	li	a0,0
}
ffffffffc020576e:	8082                	ret

ffffffffc0205770 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205770:	ca01                	beqz	a2,ffffffffc0205780 <memset+0x10>
ffffffffc0205772:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205774:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205776:	0785                	addi	a5,a5,1
ffffffffc0205778:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020577c:	fef61de3          	bne	a2,a5,ffffffffc0205776 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205780:	8082                	ret

ffffffffc0205782 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205782:	ca19                	beqz	a2,ffffffffc0205798 <memcpy+0x16>
ffffffffc0205784:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205786:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205788:	0005c703          	lbu	a4,0(a1)
ffffffffc020578c:	0585                	addi	a1,a1,1
ffffffffc020578e:	0785                	addi	a5,a5,1
ffffffffc0205790:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205794:	feb61ae3          	bne	a2,a1,ffffffffc0205788 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205798:	8082                	ret

ffffffffc020579a <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020579a:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020579c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057a0:	f022                	sd	s0,32(sp)
ffffffffc02057a2:	ec26                	sd	s1,24(sp)
ffffffffc02057a4:	e84a                	sd	s2,16(sp)
ffffffffc02057a6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02057a8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057ac:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02057ae:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02057b2:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02057b6:	84aa                	mv	s1,a0
ffffffffc02057b8:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02057ba:	03067d63          	bgeu	a2,a6,ffffffffc02057f4 <printnum+0x5a>
ffffffffc02057be:	e44e                	sd	s3,8(sp)
ffffffffc02057c0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02057c2:	4785                	li	a5,1
ffffffffc02057c4:	00e7d763          	bge	a5,a4,ffffffffc02057d2 <printnum+0x38>
            putch(padc, putdat);
ffffffffc02057c8:	85ca                	mv	a1,s2
ffffffffc02057ca:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02057cc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02057ce:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02057d0:	fc65                	bnez	s0,ffffffffc02057c8 <printnum+0x2e>
ffffffffc02057d2:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057d4:	00002797          	auipc	a5,0x2
ffffffffc02057d8:	02478793          	addi	a5,a5,36 # ffffffffc02077f8 <etext+0x1c7c>
ffffffffc02057dc:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02057de:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057e0:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02057e4:	70a2                	ld	ra,40(sp)
ffffffffc02057e6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057e8:	85ca                	mv	a1,s2
ffffffffc02057ea:	87a6                	mv	a5,s1
}
ffffffffc02057ec:	6942                	ld	s2,16(sp)
ffffffffc02057ee:	64e2                	ld	s1,24(sp)
ffffffffc02057f0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02057f2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02057f4:	03065633          	divu	a2,a2,a6
ffffffffc02057f8:	8722                	mv	a4,s0
ffffffffc02057fa:	fa1ff0ef          	jal	ffffffffc020579a <printnum>
ffffffffc02057fe:	bfd9                	j	ffffffffc02057d4 <printnum+0x3a>

ffffffffc0205800 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205800:	7119                	addi	sp,sp,-128
ffffffffc0205802:	f4a6                	sd	s1,104(sp)
ffffffffc0205804:	f0ca                	sd	s2,96(sp)
ffffffffc0205806:	ecce                	sd	s3,88(sp)
ffffffffc0205808:	e8d2                	sd	s4,80(sp)
ffffffffc020580a:	e4d6                	sd	s5,72(sp)
ffffffffc020580c:	e0da                	sd	s6,64(sp)
ffffffffc020580e:	f862                	sd	s8,48(sp)
ffffffffc0205810:	fc86                	sd	ra,120(sp)
ffffffffc0205812:	f8a2                	sd	s0,112(sp)
ffffffffc0205814:	fc5e                	sd	s7,56(sp)
ffffffffc0205816:	f466                	sd	s9,40(sp)
ffffffffc0205818:	f06a                	sd	s10,32(sp)
ffffffffc020581a:	ec6e                	sd	s11,24(sp)
ffffffffc020581c:	84aa                	mv	s1,a0
ffffffffc020581e:	8c32                	mv	s8,a2
ffffffffc0205820:	8a36                	mv	s4,a3
ffffffffc0205822:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205824:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205828:	05500b13          	li	s6,85
ffffffffc020582c:	00003a97          	auipc	s5,0x3
ffffffffc0205830:	9aca8a93          	addi	s5,s5,-1620 # ffffffffc02081d8 <syscalls+0x800>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205834:	000c4503          	lbu	a0,0(s8)
ffffffffc0205838:	001c0413          	addi	s0,s8,1
ffffffffc020583c:	01350a63          	beq	a0,s3,ffffffffc0205850 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0205840:	cd0d                	beqz	a0,ffffffffc020587a <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0205842:	85ca                	mv	a1,s2
ffffffffc0205844:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205846:	00044503          	lbu	a0,0(s0)
ffffffffc020584a:	0405                	addi	s0,s0,1
ffffffffc020584c:	ff351ae3          	bne	a0,s3,ffffffffc0205840 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc0205850:	5cfd                	li	s9,-1
ffffffffc0205852:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0205854:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0205858:	4b81                	li	s7,0
ffffffffc020585a:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020585c:	00044683          	lbu	a3,0(s0)
ffffffffc0205860:	00140c13          	addi	s8,s0,1
ffffffffc0205864:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0205868:	0ff5f593          	zext.b	a1,a1
ffffffffc020586c:	02bb6663          	bltu	s6,a1,ffffffffc0205898 <vprintfmt+0x98>
ffffffffc0205870:	058a                	slli	a1,a1,0x2
ffffffffc0205872:	95d6                	add	a1,a1,s5
ffffffffc0205874:	4198                	lw	a4,0(a1)
ffffffffc0205876:	9756                	add	a4,a4,s5
ffffffffc0205878:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020587a:	70e6                	ld	ra,120(sp)
ffffffffc020587c:	7446                	ld	s0,112(sp)
ffffffffc020587e:	74a6                	ld	s1,104(sp)
ffffffffc0205880:	7906                	ld	s2,96(sp)
ffffffffc0205882:	69e6                	ld	s3,88(sp)
ffffffffc0205884:	6a46                	ld	s4,80(sp)
ffffffffc0205886:	6aa6                	ld	s5,72(sp)
ffffffffc0205888:	6b06                	ld	s6,64(sp)
ffffffffc020588a:	7be2                	ld	s7,56(sp)
ffffffffc020588c:	7c42                	ld	s8,48(sp)
ffffffffc020588e:	7ca2                	ld	s9,40(sp)
ffffffffc0205890:	7d02                	ld	s10,32(sp)
ffffffffc0205892:	6de2                	ld	s11,24(sp)
ffffffffc0205894:	6109                	addi	sp,sp,128
ffffffffc0205896:	8082                	ret
            putch('%', putdat);
ffffffffc0205898:	85ca                	mv	a1,s2
ffffffffc020589a:	02500513          	li	a0,37
ffffffffc020589e:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02058a0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02058a4:	02500713          	li	a4,37
ffffffffc02058a8:	8c22                	mv	s8,s0
ffffffffc02058aa:	f8e785e3          	beq	a5,a4,ffffffffc0205834 <vprintfmt+0x34>
ffffffffc02058ae:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02058b2:	1c7d                	addi	s8,s8,-1
ffffffffc02058b4:	fee79de3          	bne	a5,a4,ffffffffc02058ae <vprintfmt+0xae>
ffffffffc02058b8:	bfb5                	j	ffffffffc0205834 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02058ba:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02058be:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02058c0:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02058c4:	fd06071b          	addiw	a4,a2,-48
ffffffffc02058c8:	24e56a63          	bltu	a0,a4,ffffffffc0205b1c <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02058cc:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058ce:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02058d0:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02058d4:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02058d8:	0197073b          	addw	a4,a4,s9
ffffffffc02058dc:	0017171b          	slliw	a4,a4,0x1
ffffffffc02058e0:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc02058e2:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02058e6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02058e8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02058ec:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc02058f0:	feb570e3          	bgeu	a0,a1,ffffffffc02058d0 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc02058f4:	f60d54e3          	bgez	s10,ffffffffc020585c <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02058f8:	8d66                	mv	s10,s9
ffffffffc02058fa:	5cfd                	li	s9,-1
ffffffffc02058fc:	b785                	j	ffffffffc020585c <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02058fe:	8db6                	mv	s11,a3
ffffffffc0205900:	8462                	mv	s0,s8
ffffffffc0205902:	bfa9                	j	ffffffffc020585c <vprintfmt+0x5c>
ffffffffc0205904:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0205906:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0205908:	bf91                	j	ffffffffc020585c <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc020590a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020590c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205910:	00f74463          	blt	a4,a5,ffffffffc0205918 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0205914:	1a078763          	beqz	a5,ffffffffc0205ac2 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0205918:	000a3603          	ld	a2,0(s4)
ffffffffc020591c:	46c1                	li	a3,16
ffffffffc020591e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205920:	000d879b          	sext.w	a5,s11
ffffffffc0205924:	876a                	mv	a4,s10
ffffffffc0205926:	85ca                	mv	a1,s2
ffffffffc0205928:	8526                	mv	a0,s1
ffffffffc020592a:	e71ff0ef          	jal	ffffffffc020579a <printnum>
            break;
ffffffffc020592e:	b719                	j	ffffffffc0205834 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0205930:	000a2503          	lw	a0,0(s4)
ffffffffc0205934:	85ca                	mv	a1,s2
ffffffffc0205936:	0a21                	addi	s4,s4,8
ffffffffc0205938:	9482                	jalr	s1
            break;
ffffffffc020593a:	bded                	j	ffffffffc0205834 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020593c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020593e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205942:	00f74463          	blt	a4,a5,ffffffffc020594a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0205946:	16078963          	beqz	a5,ffffffffc0205ab8 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc020594a:	000a3603          	ld	a2,0(s4)
ffffffffc020594e:	46a9                	li	a3,10
ffffffffc0205950:	8a2e                	mv	s4,a1
ffffffffc0205952:	b7f9                	j	ffffffffc0205920 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0205954:	85ca                	mv	a1,s2
ffffffffc0205956:	03000513          	li	a0,48
ffffffffc020595a:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc020595c:	85ca                	mv	a1,s2
ffffffffc020595e:	07800513          	li	a0,120
ffffffffc0205962:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205964:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0205968:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020596a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020596c:	bf55                	j	ffffffffc0205920 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc020596e:	85ca                	mv	a1,s2
ffffffffc0205970:	02500513          	li	a0,37
ffffffffc0205974:	9482                	jalr	s1
            break;
ffffffffc0205976:	bd7d                	j	ffffffffc0205834 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0205978:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020597c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020597e:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0205980:	bf95                	j	ffffffffc02058f4 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0205982:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205984:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205988:	00f74463          	blt	a4,a5,ffffffffc0205990 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc020598c:	12078163          	beqz	a5,ffffffffc0205aae <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc0205990:	000a3603          	ld	a2,0(s4)
ffffffffc0205994:	46a1                	li	a3,8
ffffffffc0205996:	8a2e                	mv	s4,a1
ffffffffc0205998:	b761                	j	ffffffffc0205920 <vprintfmt+0x120>
            if (width < 0)
ffffffffc020599a:	876a                	mv	a4,s10
ffffffffc020599c:	000d5363          	bgez	s10,ffffffffc02059a2 <vprintfmt+0x1a2>
ffffffffc02059a0:	4701                	li	a4,0
ffffffffc02059a2:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02059a6:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02059a8:	bd55                	j	ffffffffc020585c <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02059aa:	000d841b          	sext.w	s0,s11
ffffffffc02059ae:	fd340793          	addi	a5,s0,-45
ffffffffc02059b2:	00f037b3          	snez	a5,a5
ffffffffc02059b6:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02059ba:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc02059be:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02059c0:	008a0793          	addi	a5,s4,8
ffffffffc02059c4:	e43e                	sd	a5,8(sp)
ffffffffc02059c6:	100d8c63          	beqz	s11,ffffffffc0205ade <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02059ca:	12071363          	bnez	a4,ffffffffc0205af0 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059ce:	000dc783          	lbu	a5,0(s11)
ffffffffc02059d2:	0007851b          	sext.w	a0,a5
ffffffffc02059d6:	c78d                	beqz	a5,ffffffffc0205a00 <vprintfmt+0x200>
ffffffffc02059d8:	0d85                	addi	s11,s11,1
ffffffffc02059da:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059dc:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059e0:	000cc563          	bltz	s9,ffffffffc02059ea <vprintfmt+0x1ea>
ffffffffc02059e4:	3cfd                	addiw	s9,s9,-1
ffffffffc02059e6:	008c8d63          	beq	s9,s0,ffffffffc0205a00 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02059ea:	020b9663          	bnez	s7,ffffffffc0205a16 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc02059ee:	85ca                	mv	a1,s2
ffffffffc02059f0:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02059f2:	000dc783          	lbu	a5,0(s11)
ffffffffc02059f6:	0d85                	addi	s11,s11,1
ffffffffc02059f8:	3d7d                	addiw	s10,s10,-1
ffffffffc02059fa:	0007851b          	sext.w	a0,a5
ffffffffc02059fe:	f3ed                	bnez	a5,ffffffffc02059e0 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0205a00:	01a05963          	blez	s10,ffffffffc0205a12 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0205a04:	85ca                	mv	a1,s2
ffffffffc0205a06:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0205a0a:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0205a0c:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0205a0e:	fe0d1be3          	bnez	s10,ffffffffc0205a04 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205a12:	6a22                	ld	s4,8(sp)
ffffffffc0205a14:	b505                	j	ffffffffc0205834 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205a16:	3781                	addiw	a5,a5,-32
ffffffffc0205a18:	fcfa7be3          	bgeu	s4,a5,ffffffffc02059ee <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0205a1c:	03f00513          	li	a0,63
ffffffffc0205a20:	85ca                	mv	a1,s2
ffffffffc0205a22:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205a24:	000dc783          	lbu	a5,0(s11)
ffffffffc0205a28:	0d85                	addi	s11,s11,1
ffffffffc0205a2a:	3d7d                	addiw	s10,s10,-1
ffffffffc0205a2c:	0007851b          	sext.w	a0,a5
ffffffffc0205a30:	dbe1                	beqz	a5,ffffffffc0205a00 <vprintfmt+0x200>
ffffffffc0205a32:	fa0cd9e3          	bgez	s9,ffffffffc02059e4 <vprintfmt+0x1e4>
ffffffffc0205a36:	b7c5                	j	ffffffffc0205a16 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0205a38:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205a3c:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc0205a3e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205a40:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0205a44:	8fb9                	xor	a5,a5,a4
ffffffffc0205a46:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205a4a:	02d64563          	blt	a2,a3,ffffffffc0205a74 <vprintfmt+0x274>
ffffffffc0205a4e:	00003797          	auipc	a5,0x3
ffffffffc0205a52:	8e278793          	addi	a5,a5,-1822 # ffffffffc0208330 <error_string>
ffffffffc0205a56:	00369713          	slli	a4,a3,0x3
ffffffffc0205a5a:	97ba                	add	a5,a5,a4
ffffffffc0205a5c:	639c                	ld	a5,0(a5)
ffffffffc0205a5e:	cb99                	beqz	a5,ffffffffc0205a74 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205a60:	86be                	mv	a3,a5
ffffffffc0205a62:	00000617          	auipc	a2,0x0
ffffffffc0205a66:	14660613          	addi	a2,a2,326 # ffffffffc0205ba8 <etext+0x2c>
ffffffffc0205a6a:	85ca                	mv	a1,s2
ffffffffc0205a6c:	8526                	mv	a0,s1
ffffffffc0205a6e:	0d8000ef          	jal	ffffffffc0205b46 <printfmt>
ffffffffc0205a72:	b3c9                	j	ffffffffc0205834 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0205a74:	00002617          	auipc	a2,0x2
ffffffffc0205a78:	da460613          	addi	a2,a2,-604 # ffffffffc0207818 <etext+0x1c9c>
ffffffffc0205a7c:	85ca                	mv	a1,s2
ffffffffc0205a7e:	8526                	mv	a0,s1
ffffffffc0205a80:	0c6000ef          	jal	ffffffffc0205b46 <printfmt>
ffffffffc0205a84:	bb45                	j	ffffffffc0205834 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0205a86:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205a88:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0205a8c:	00f74363          	blt	a4,a5,ffffffffc0205a92 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc0205a90:	cf81                	beqz	a5,ffffffffc0205aa8 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0205a92:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0205a96:	02044b63          	bltz	s0,ffffffffc0205acc <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0205a9a:	8622                	mv	a2,s0
ffffffffc0205a9c:	8a5e                	mv	s4,s7
ffffffffc0205a9e:	46a9                	li	a3,10
ffffffffc0205aa0:	b541                	j	ffffffffc0205920 <vprintfmt+0x120>
            lflag ++;
ffffffffc0205aa2:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205aa4:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0205aa6:	bb5d                	j	ffffffffc020585c <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0205aa8:	000a2403          	lw	s0,0(s4)
ffffffffc0205aac:	b7ed                	j	ffffffffc0205a96 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0205aae:	000a6603          	lwu	a2,0(s4)
ffffffffc0205ab2:	46a1                	li	a3,8
ffffffffc0205ab4:	8a2e                	mv	s4,a1
ffffffffc0205ab6:	b5ad                	j	ffffffffc0205920 <vprintfmt+0x120>
ffffffffc0205ab8:	000a6603          	lwu	a2,0(s4)
ffffffffc0205abc:	46a9                	li	a3,10
ffffffffc0205abe:	8a2e                	mv	s4,a1
ffffffffc0205ac0:	b585                	j	ffffffffc0205920 <vprintfmt+0x120>
ffffffffc0205ac2:	000a6603          	lwu	a2,0(s4)
ffffffffc0205ac6:	46c1                	li	a3,16
ffffffffc0205ac8:	8a2e                	mv	s4,a1
ffffffffc0205aca:	bd99                	j	ffffffffc0205920 <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0205acc:	85ca                	mv	a1,s2
ffffffffc0205ace:	02d00513          	li	a0,45
ffffffffc0205ad2:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0205ad4:	40800633          	neg	a2,s0
ffffffffc0205ad8:	8a5e                	mv	s4,s7
ffffffffc0205ada:	46a9                	li	a3,10
ffffffffc0205adc:	b591                	j	ffffffffc0205920 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0205ade:	e329                	bnez	a4,ffffffffc0205b20 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205ae0:	02800793          	li	a5,40
ffffffffc0205ae4:	853e                	mv	a0,a5
ffffffffc0205ae6:	00002d97          	auipc	s11,0x2
ffffffffc0205aea:	d2bd8d93          	addi	s11,s11,-725 # ffffffffc0207811 <etext+0x1c95>
ffffffffc0205aee:	b5f5                	j	ffffffffc02059da <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205af0:	85e6                	mv	a1,s9
ffffffffc0205af2:	856e                	mv	a0,s11
ffffffffc0205af4:	be1ff0ef          	jal	ffffffffc02056d4 <strnlen>
ffffffffc0205af8:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0205afc:	01a05863          	blez	s10,ffffffffc0205b0c <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0205b00:	85ca                	mv	a1,s2
ffffffffc0205b02:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b04:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0205b06:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b08:	fe0d1ce3          	bnez	s10,ffffffffc0205b00 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b0c:	000dc783          	lbu	a5,0(s11)
ffffffffc0205b10:	0007851b          	sext.w	a0,a5
ffffffffc0205b14:	ec0792e3          	bnez	a5,ffffffffc02059d8 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205b18:	6a22                	ld	s4,8(sp)
ffffffffc0205b1a:	bb29                	j	ffffffffc0205834 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205b1c:	8462                	mv	s0,s8
ffffffffc0205b1e:	bbd9                	j	ffffffffc02058f4 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b20:	85e6                	mv	a1,s9
ffffffffc0205b22:	00002517          	auipc	a0,0x2
ffffffffc0205b26:	cee50513          	addi	a0,a0,-786 # ffffffffc0207810 <etext+0x1c94>
ffffffffc0205b2a:	babff0ef          	jal	ffffffffc02056d4 <strnlen>
ffffffffc0205b2e:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b32:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0205b36:	00002d97          	auipc	s11,0x2
ffffffffc0205b3a:	cdad8d93          	addi	s11,s11,-806 # ffffffffc0207810 <etext+0x1c94>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205b3e:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205b40:	fda040e3          	bgtz	s10,ffffffffc0205b00 <vprintfmt+0x300>
ffffffffc0205b44:	bd51                	j	ffffffffc02059d8 <vprintfmt+0x1d8>

ffffffffc0205b46 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b46:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205b48:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b4c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205b4e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205b50:	ec06                	sd	ra,24(sp)
ffffffffc0205b52:	f83a                	sd	a4,48(sp)
ffffffffc0205b54:	fc3e                	sd	a5,56(sp)
ffffffffc0205b56:	e0c2                	sd	a6,64(sp)
ffffffffc0205b58:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205b5a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205b5c:	ca5ff0ef          	jal	ffffffffc0205800 <vprintfmt>
}
ffffffffc0205b60:	60e2                	ld	ra,24(sp)
ffffffffc0205b62:	6161                	addi	sp,sp,80
ffffffffc0205b64:	8082                	ret

ffffffffc0205b66 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205b66:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205b6a:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_matrix_out_size+0xffffffff9e364541>
ffffffffc0205b6c:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205b70:	02000513          	li	a0,32
ffffffffc0205b74:	9d0d                	subw	a0,a0,a1
}
ffffffffc0205b76:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0205b7a:	8082                	ret
