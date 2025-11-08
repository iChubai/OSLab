
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00009297          	auipc	t0,0x9
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0209000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00009297          	auipc	t0,0x9
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0209008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02082b7          	lui	t0,0xc0208
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
ffffffffc020003c:	c0208137          	lui	sp,0xc0208

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
ffffffffc020004a:	00009517          	auipc	a0,0x9
ffffffffc020004e:	fe650513          	addi	a0,a0,-26 # ffffffffc0209030 <buf>
ffffffffc0200052:	0000d617          	auipc	a2,0xd
ffffffffc0200056:	49660613          	addi	a2,a2,1174 # ffffffffc020d4e8 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0207ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	295030ef          	jal	ffffffffc0203af6 <memset>
    dtb_init();
ffffffffc0200066:	3fe000ef          	jal	ffffffffc0200464 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	794000ef          	jal	ffffffffc02007fe <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	eba58593          	addi	a1,a1,-326 # ffffffffc0203f28 <etext+0x2>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	ed250513          	addi	a0,a0,-302 # ffffffffc0203f48 <etext+0x22>
ffffffffc020007e:	060000ef          	jal	ffffffffc02000de <cprintf>

    print_kerninfo();
ffffffffc0200082:	1b6000ef          	jal	ffffffffc0200238 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	592020ef          	jal	ffffffffc0202618 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	7e6000ef          	jal	ffffffffc0200870 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	7f0000ef          	jal	ffffffffc020087e <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	627000ef          	jal	ffffffffc0200eb8 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	672030ef          	jal	ffffffffc0203708 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	710000ef          	jal	ffffffffc02007aa <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	7d4000ef          	jal	ffffffffc0200872 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	0bf030ef          	jal	ffffffffc0203960 <cpu_idle>

ffffffffc02000a6 <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc02000a6:	1101                	addi	sp,sp,-32
ffffffffc02000a8:	ec06                	sd	ra,24(sp)
ffffffffc02000aa:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc02000ac:	754000ef          	jal	ffffffffc0200800 <cons_putc>
    (*cnt)++;
ffffffffc02000b0:	65a2                	ld	a1,8(sp)
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
    (*cnt)++;
ffffffffc02000b4:	419c                	lw	a5,0(a1)
ffffffffc02000b6:	2785                	addiw	a5,a5,1
ffffffffc02000b8:	c19c                	sw	a5,0(a1)
}
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc02000be:	1101                	addi	sp,sp,-32
ffffffffc02000c0:	862a                	mv	a2,a0
ffffffffc02000c2:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000c4:	00000517          	auipc	a0,0x0
ffffffffc02000c8:	fe250513          	addi	a0,a0,-30 # ffffffffc02000a6 <cputch>
ffffffffc02000cc:	006c                	addi	a1,sp,12
{
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000d0:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000d2:	2d9030ef          	jal	ffffffffc0203baa <vprintfmt>
    return cnt;
}
ffffffffc02000d6:	60e2                	ld	ra,24(sp)
ffffffffc02000d8:	4532                	lw	a0,12(sp)
ffffffffc02000da:	6105                	addi	sp,sp,32
ffffffffc02000dc:	8082                	ret

ffffffffc02000de <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc02000de:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000e0:	02810313          	addi	t1,sp,40
{
ffffffffc02000e4:	f42e                	sd	a1,40(sp)
ffffffffc02000e6:	f832                	sd	a2,48(sp)
ffffffffc02000e8:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ea:	862a                	mv	a2,a0
ffffffffc02000ec:	004c                	addi	a1,sp,4
ffffffffc02000ee:	00000517          	auipc	a0,0x0
ffffffffc02000f2:	fb850513          	addi	a0,a0,-72 # ffffffffc02000a6 <cputch>
ffffffffc02000f6:	869a                	mv	a3,t1
{
ffffffffc02000f8:	ec06                	sd	ra,24(sp)
ffffffffc02000fa:	e0ba                	sd	a4,64(sp)
ffffffffc02000fc:	e4be                	sd	a5,72(sp)
ffffffffc02000fe:	e8c2                	sd	a6,80(sp)
ffffffffc0200100:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc0200102:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc0200104:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200106:	2a5030ef          	jal	ffffffffc0203baa <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020010a:	60e2                	ld	ra,24(sp)
ffffffffc020010c:	4512                	lw	a0,4(sp)
ffffffffc020010e:	6125                	addi	sp,sp,96
ffffffffc0200110:	8082                	ret

ffffffffc0200112 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc0200112:	a5fd                	j	ffffffffc0200800 <cons_putc>

ffffffffc0200114 <getchar>:
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc0200114:	1141                	addi	sp,sp,-16
ffffffffc0200116:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200118:	71c000ef          	jal	ffffffffc0200834 <cons_getc>
ffffffffc020011c:	dd75                	beqz	a0,ffffffffc0200118 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020011e:	60a2                	ld	ra,8(sp)
ffffffffc0200120:	0141                	addi	sp,sp,16
ffffffffc0200122:	8082                	ret

ffffffffc0200124 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200124:	7179                	addi	sp,sp,-48
ffffffffc0200126:	f406                	sd	ra,40(sp)
ffffffffc0200128:	f022                	sd	s0,32(sp)
ffffffffc020012a:	ec26                	sd	s1,24(sp)
ffffffffc020012c:	e84a                	sd	s2,16(sp)
ffffffffc020012e:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc0200130:	c901                	beqz	a0,ffffffffc0200140 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc0200132:	85aa                	mv	a1,a0
ffffffffc0200134:	00004517          	auipc	a0,0x4
ffffffffc0200138:	e1c50513          	addi	a0,a0,-484 # ffffffffc0203f50 <etext+0x2a>
ffffffffc020013c:	fa3ff0ef          	jal	ffffffffc02000de <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0200140:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200142:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc0200144:	00009997          	auipc	s3,0x9
ffffffffc0200148:	eec98993          	addi	s3,s3,-276 # ffffffffc0209030 <buf>
        c = getchar();
ffffffffc020014c:	fc9ff0ef          	jal	ffffffffc0200114 <getchar>
ffffffffc0200150:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200152:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200156:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020015a:	ff650693          	addi	a3,a0,-10
ffffffffc020015e:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0200162:	02054963          	bltz	a0,ffffffffc0200194 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200166:	02a95f63          	bge	s2,a0,ffffffffc02001a4 <readline+0x80>
ffffffffc020016a:	cf0d                	beqz	a4,ffffffffc02001a4 <readline+0x80>
            cputchar(c);
ffffffffc020016c:	fa7ff0ef          	jal	ffffffffc0200112 <cputchar>
            buf[i ++] = c;
ffffffffc0200170:	009987b3          	add	a5,s3,s1
ffffffffc0200174:	00878023          	sb	s0,0(a5)
ffffffffc0200178:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc020017a:	f9bff0ef          	jal	ffffffffc0200114 <getchar>
ffffffffc020017e:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0200180:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200184:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc0200188:	ff650693          	addi	a3,a0,-10
ffffffffc020018c:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0200190:	fc055be3          	bgez	a0,ffffffffc0200166 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc0200194:	70a2                	ld	ra,40(sp)
ffffffffc0200196:	7402                	ld	s0,32(sp)
ffffffffc0200198:	64e2                	ld	s1,24(sp)
ffffffffc020019a:	6942                	ld	s2,16(sp)
ffffffffc020019c:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc020019e:	4501                	li	a0,0
}
ffffffffc02001a0:	6145                	addi	sp,sp,48
ffffffffc02001a2:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc02001a4:	eb81                	bnez	a5,ffffffffc02001b4 <readline+0x90>
            cputchar(c);
ffffffffc02001a6:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc02001a8:	00905663          	blez	s1,ffffffffc02001b4 <readline+0x90>
            cputchar(c);
ffffffffc02001ac:	f67ff0ef          	jal	ffffffffc0200112 <cputchar>
            i --;
ffffffffc02001b0:	34fd                	addiw	s1,s1,-1
ffffffffc02001b2:	bf69                	j	ffffffffc020014c <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc02001b4:	c291                	beqz	a3,ffffffffc02001b8 <readline+0x94>
ffffffffc02001b6:	fa59                	bnez	a2,ffffffffc020014c <readline+0x28>
            cputchar(c);
ffffffffc02001b8:	8522                	mv	a0,s0
ffffffffc02001ba:	f59ff0ef          	jal	ffffffffc0200112 <cputchar>
            buf[i] = '\0';
ffffffffc02001be:	00009517          	auipc	a0,0x9
ffffffffc02001c2:	e7250513          	addi	a0,a0,-398 # ffffffffc0209030 <buf>
ffffffffc02001c6:	94aa                	add	s1,s1,a0
ffffffffc02001c8:	00048023          	sb	zero,0(s1)
}
ffffffffc02001cc:	70a2                	ld	ra,40(sp)
ffffffffc02001ce:	7402                	ld	s0,32(sp)
ffffffffc02001d0:	64e2                	ld	s1,24(sp)
ffffffffc02001d2:	6942                	ld	s2,16(sp)
ffffffffc02001d4:	69a2                	ld	s3,8(sp)
ffffffffc02001d6:	6145                	addi	sp,sp,48
ffffffffc02001d8:	8082                	ret

ffffffffc02001da <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001da:	0000d317          	auipc	t1,0xd
ffffffffc02001de:	28e32303          	lw	t1,654(t1) # ffffffffc020d468 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001e2:	715d                	addi	sp,sp,-80
ffffffffc02001e4:	ec06                	sd	ra,24(sp)
ffffffffc02001e6:	f436                	sd	a3,40(sp)
ffffffffc02001e8:	f83a                	sd	a4,48(sp)
ffffffffc02001ea:	fc3e                	sd	a5,56(sp)
ffffffffc02001ec:	e0c2                	sd	a6,64(sp)
ffffffffc02001ee:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001f0:	02031e63          	bnez	t1,ffffffffc020022c <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001f4:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001f6:	103c                	addi	a5,sp,40
ffffffffc02001f8:	e822                	sd	s0,16(sp)
ffffffffc02001fa:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	862e                	mv	a2,a1
ffffffffc02001fe:	85aa                	mv	a1,a0
ffffffffc0200200:	00004517          	auipc	a0,0x4
ffffffffc0200204:	d5850513          	addi	a0,a0,-680 # ffffffffc0203f58 <etext+0x32>
    is_panic = 1;
ffffffffc0200208:	0000d697          	auipc	a3,0xd
ffffffffc020020c:	26e6a023          	sw	a4,608(a3) # ffffffffc020d468 <is_panic>
    va_start(ap, fmt);
ffffffffc0200210:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200212:	ecdff0ef          	jal	ffffffffc02000de <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200216:	65a2                	ld	a1,8(sp)
ffffffffc0200218:	8522                	mv	a0,s0
ffffffffc020021a:	ea5ff0ef          	jal	ffffffffc02000be <vcprintf>
    cprintf("\n");
ffffffffc020021e:	00004517          	auipc	a0,0x4
ffffffffc0200222:	d5a50513          	addi	a0,a0,-678 # ffffffffc0203f78 <etext+0x52>
ffffffffc0200226:	eb9ff0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc020022a:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020022c:	64c000ef          	jal	ffffffffc0200878 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200230:	4501                	li	a0,0
ffffffffc0200232:	108000ef          	jal	ffffffffc020033a <kmonitor>
    while (1) {
ffffffffc0200236:	bfed                	j	ffffffffc0200230 <__panic+0x56>

ffffffffc0200238 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc0200238:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020023a:	00004517          	auipc	a0,0x4
ffffffffc020023e:	d4650513          	addi	a0,a0,-698 # ffffffffc0203f80 <etext+0x5a>
{
ffffffffc0200242:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200244:	e9bff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200248:	00000597          	auipc	a1,0x0
ffffffffc020024c:	e0258593          	addi	a1,a1,-510 # ffffffffc020004a <kern_init>
ffffffffc0200250:	00004517          	auipc	a0,0x4
ffffffffc0200254:	d5050513          	addi	a0,a0,-688 # ffffffffc0203fa0 <etext+0x7a>
ffffffffc0200258:	e87ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025c:	00004597          	auipc	a1,0x4
ffffffffc0200260:	cca58593          	addi	a1,a1,-822 # ffffffffc0203f26 <etext>
ffffffffc0200264:	00004517          	auipc	a0,0x4
ffffffffc0200268:	d5c50513          	addi	a0,a0,-676 # ffffffffc0203fc0 <etext+0x9a>
ffffffffc020026c:	e73ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200270:	00009597          	auipc	a1,0x9
ffffffffc0200274:	dc058593          	addi	a1,a1,-576 # ffffffffc0209030 <buf>
ffffffffc0200278:	00004517          	auipc	a0,0x4
ffffffffc020027c:	d6850513          	addi	a0,a0,-664 # ffffffffc0203fe0 <etext+0xba>
ffffffffc0200280:	e5fff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200284:	0000d597          	auipc	a1,0xd
ffffffffc0200288:	26458593          	addi	a1,a1,612 # ffffffffc020d4e8 <end>
ffffffffc020028c:	00004517          	auipc	a0,0x4
ffffffffc0200290:	d7450513          	addi	a0,a0,-652 # ffffffffc0204000 <etext+0xda>
ffffffffc0200294:	e4bff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200298:	00000717          	auipc	a4,0x0
ffffffffc020029c:	db270713          	addi	a4,a4,-590 # ffffffffc020004a <kern_init>
ffffffffc02002a0:	0000d797          	auipc	a5,0xd
ffffffffc02002a4:	64778793          	addi	a5,a5,1607 # ffffffffc020d8e7 <end+0x3ff>
ffffffffc02002a8:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002aa:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002ae:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b4:	95be                	add	a1,a1,a5
ffffffffc02002b6:	85a9                	srai	a1,a1,0xa
ffffffffc02002b8:	00004517          	auipc	a0,0x4
ffffffffc02002bc:	d6850513          	addi	a0,a0,-664 # ffffffffc0204020 <etext+0xfa>
}
ffffffffc02002c0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c2:	bd31                	j	ffffffffc02000de <cprintf>

ffffffffc02002c4 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002c4:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002c6:	00004617          	auipc	a2,0x4
ffffffffc02002ca:	d8a60613          	addi	a2,a2,-630 # ffffffffc0204050 <etext+0x12a>
ffffffffc02002ce:	04900593          	li	a1,73
ffffffffc02002d2:	00004517          	auipc	a0,0x4
ffffffffc02002d6:	d9650513          	addi	a0,a0,-618 # ffffffffc0204068 <etext+0x142>
{
ffffffffc02002da:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002dc:	effff0ef          	jal	ffffffffc02001da <__panic>

ffffffffc02002e0 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e0:	1101                	addi	sp,sp,-32
ffffffffc02002e2:	e822                	sd	s0,16(sp)
ffffffffc02002e4:	e426                	sd	s1,8(sp)
ffffffffc02002e6:	ec06                	sd	ra,24(sp)
ffffffffc02002e8:	00005417          	auipc	s0,0x5
ffffffffc02002ec:	51040413          	addi	s0,s0,1296 # ffffffffc02057f8 <commands>
ffffffffc02002f0:	00005497          	auipc	s1,0x5
ffffffffc02002f4:	55048493          	addi	s1,s1,1360 # ffffffffc0205840 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002f8:	6410                	ld	a2,8(s0)
ffffffffc02002fa:	600c                	ld	a1,0(s0)
ffffffffc02002fc:	00004517          	auipc	a0,0x4
ffffffffc0200300:	d8450513          	addi	a0,a0,-636 # ffffffffc0204080 <etext+0x15a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200306:	dd9ff0ef          	jal	ffffffffc02000de <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030a:	fe9417e3          	bne	s0,s1,ffffffffc02002f8 <mon_help+0x18>
    }
    return 0;
}
ffffffffc020030e:	60e2                	ld	ra,24(sp)
ffffffffc0200310:	6442                	ld	s0,16(sp)
ffffffffc0200312:	64a2                	ld	s1,8(sp)
ffffffffc0200314:	4501                	li	a0,0
ffffffffc0200316:	6105                	addi	sp,sp,32
ffffffffc0200318:	8082                	ret

ffffffffc020031a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031a:	1141                	addi	sp,sp,-16
ffffffffc020031c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020031e:	f1bff0ef          	jal	ffffffffc0200238 <print_kerninfo>
    return 0;
}
ffffffffc0200322:	60a2                	ld	ra,8(sp)
ffffffffc0200324:	4501                	li	a0,0
ffffffffc0200326:	0141                	addi	sp,sp,16
ffffffffc0200328:	8082                	ret

ffffffffc020032a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032a:	1141                	addi	sp,sp,-16
ffffffffc020032c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020032e:	f97ff0ef          	jal	ffffffffc02002c4 <print_stackframe>
    return 0;
}
ffffffffc0200332:	60a2                	ld	ra,8(sp)
ffffffffc0200334:	4501                	li	a0,0
ffffffffc0200336:	0141                	addi	sp,sp,16
ffffffffc0200338:	8082                	ret

ffffffffc020033a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020033a:	7131                	addi	sp,sp,-192
ffffffffc020033c:	e952                	sd	s4,144(sp)
ffffffffc020033e:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200340:	00004517          	auipc	a0,0x4
ffffffffc0200344:	d5050513          	addi	a0,a0,-688 # ffffffffc0204090 <etext+0x16a>
kmonitor(struct trapframe *tf) {
ffffffffc0200348:	fd06                	sd	ra,184(sp)
ffffffffc020034a:	f922                	sd	s0,176(sp)
ffffffffc020034c:	f526                	sd	s1,168(sp)
ffffffffc020034e:	f14a                	sd	s2,160(sp)
ffffffffc0200350:	e556                	sd	s5,136(sp)
ffffffffc0200352:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200354:	d8bff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200358:	00004517          	auipc	a0,0x4
ffffffffc020035c:	d6050513          	addi	a0,a0,-672 # ffffffffc02040b8 <etext+0x192>
ffffffffc0200360:	d7fff0ef          	jal	ffffffffc02000de <cprintf>
    if (tf != NULL) {
ffffffffc0200364:	000a0563          	beqz	s4,ffffffffc020036e <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc0200368:	8552                	mv	a0,s4
ffffffffc020036a:	6fc000ef          	jal	ffffffffc0200a66 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020036e:	4501                	li	a0,0
ffffffffc0200370:	4581                	li	a1,0
ffffffffc0200372:	4601                	li	a2,0
ffffffffc0200374:	48a1                	li	a7,8
ffffffffc0200376:	00000073          	ecall
ffffffffc020037a:	00005a97          	auipc	s5,0x5
ffffffffc020037e:	47ea8a93          	addi	s5,s5,1150 # ffffffffc02057f8 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200382:	493d                	li	s2,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200384:	00004517          	auipc	a0,0x4
ffffffffc0200388:	d5c50513          	addi	a0,a0,-676 # ffffffffc02040e0 <etext+0x1ba>
ffffffffc020038c:	d99ff0ef          	jal	ffffffffc0200124 <readline>
ffffffffc0200390:	842a                	mv	s0,a0
ffffffffc0200392:	d96d                	beqz	a0,ffffffffc0200384 <kmonitor+0x4a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200394:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200398:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039a:	e99d                	bnez	a1,ffffffffc02003d0 <kmonitor+0x96>
    int argc = 0;
ffffffffc020039c:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc020039e:	fe0b03e3          	beqz	s6,ffffffffc0200384 <kmonitor+0x4a>
ffffffffc02003a2:	00005497          	auipc	s1,0x5
ffffffffc02003a6:	45648493          	addi	s1,s1,1110 # ffffffffc02057f8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ac:	6582                	ld	a1,0(sp)
ffffffffc02003ae:	6088                	ld	a0,0(s1)
ffffffffc02003b0:	6d8030ef          	jal	ffffffffc0203a88 <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b4:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b6:	c149                	beqz	a0,ffffffffc0200438 <kmonitor+0xfe>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b8:	2405                	addiw	s0,s0,1
ffffffffc02003ba:	04e1                	addi	s1,s1,24
ffffffffc02003bc:	fef418e3          	bne	s0,a5,ffffffffc02003ac <kmonitor+0x72>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	d4e50513          	addi	a0,a0,-690 # ffffffffc0204110 <etext+0x1ea>
ffffffffc02003ca:	d15ff0ef          	jal	ffffffffc02000de <cprintf>
    return 0;
ffffffffc02003ce:	bf5d                	j	ffffffffc0200384 <kmonitor+0x4a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	00004517          	auipc	a0,0x4
ffffffffc02003d4:	d1850513          	addi	a0,a0,-744 # ffffffffc02040e8 <etext+0x1c2>
ffffffffc02003d8:	70c030ef          	jal	ffffffffc0203ae4 <strchr>
ffffffffc02003dc:	c901                	beqz	a0,ffffffffc02003ec <kmonitor+0xb2>
ffffffffc02003de:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003e2:	00040023          	sb	zero,0(s0)
ffffffffc02003e6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e8:	d9d5                	beqz	a1,ffffffffc020039c <kmonitor+0x62>
ffffffffc02003ea:	b7dd                	j	ffffffffc02003d0 <kmonitor+0x96>
        if (*buf == '\0') {
ffffffffc02003ec:	00044783          	lbu	a5,0(s0)
ffffffffc02003f0:	d7d5                	beqz	a5,ffffffffc020039c <kmonitor+0x62>
        if (argc == MAXARGS - 1) {
ffffffffc02003f2:	03248b63          	beq	s1,s2,ffffffffc0200428 <kmonitor+0xee>
        argv[argc ++] = buf;
ffffffffc02003f6:	00349793          	slli	a5,s1,0x3
ffffffffc02003fa:	978a                	add	a5,a5,sp
ffffffffc02003fc:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003fe:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200402:	2485                	addiw	s1,s1,1
ffffffffc0200404:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200406:	e591                	bnez	a1,ffffffffc0200412 <kmonitor+0xd8>
ffffffffc0200408:	bf59                	j	ffffffffc020039e <kmonitor+0x64>
ffffffffc020040a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020040e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200410:	d5d1                	beqz	a1,ffffffffc020039c <kmonitor+0x62>
ffffffffc0200412:	00004517          	auipc	a0,0x4
ffffffffc0200416:	cd650513          	addi	a0,a0,-810 # ffffffffc02040e8 <etext+0x1c2>
ffffffffc020041a:	6ca030ef          	jal	ffffffffc0203ae4 <strchr>
ffffffffc020041e:	d575                	beqz	a0,ffffffffc020040a <kmonitor+0xd0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200420:	00044583          	lbu	a1,0(s0)
ffffffffc0200424:	dda5                	beqz	a1,ffffffffc020039c <kmonitor+0x62>
ffffffffc0200426:	b76d                	j	ffffffffc02003d0 <kmonitor+0x96>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200428:	45c1                	li	a1,16
ffffffffc020042a:	00004517          	auipc	a0,0x4
ffffffffc020042e:	cc650513          	addi	a0,a0,-826 # ffffffffc02040f0 <etext+0x1ca>
ffffffffc0200432:	cadff0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc0200436:	b7c1                	j	ffffffffc02003f6 <kmonitor+0xbc>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200438:	00141793          	slli	a5,s0,0x1
ffffffffc020043c:	97a2                	add	a5,a5,s0
ffffffffc020043e:	078e                	slli	a5,a5,0x3
ffffffffc0200440:	97d6                	add	a5,a5,s5
ffffffffc0200442:	6b9c                	ld	a5,16(a5)
ffffffffc0200444:	fffb051b          	addiw	a0,s6,-1
ffffffffc0200448:	8652                	mv	a2,s4
ffffffffc020044a:	002c                	addi	a1,sp,8
ffffffffc020044c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020044e:	f2055be3          	bgez	a0,ffffffffc0200384 <kmonitor+0x4a>
}
ffffffffc0200452:	70ea                	ld	ra,184(sp)
ffffffffc0200454:	744a                	ld	s0,176(sp)
ffffffffc0200456:	74aa                	ld	s1,168(sp)
ffffffffc0200458:	790a                	ld	s2,160(sp)
ffffffffc020045a:	6a4a                	ld	s4,144(sp)
ffffffffc020045c:	6aaa                	ld	s5,136(sp)
ffffffffc020045e:	6b0a                	ld	s6,128(sp)
ffffffffc0200460:	6129                	addi	sp,sp,192
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200464:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc0200466:	00004517          	auipc	a0,0x4
ffffffffc020046a:	d5250513          	addi	a0,a0,-686 # ffffffffc02041b8 <etext+0x292>
void dtb_init(void) {
ffffffffc020046e:	f406                	sd	ra,40(sp)
ffffffffc0200470:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200472:	c6dff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200476:	00009597          	auipc	a1,0x9
ffffffffc020047a:	b8a5b583          	ld	a1,-1142(a1) # ffffffffc0209000 <boot_hartid>
ffffffffc020047e:	00004517          	auipc	a0,0x4
ffffffffc0200482:	d4a50513          	addi	a0,a0,-694 # ffffffffc02041c8 <etext+0x2a2>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200486:	00009417          	auipc	s0,0x9
ffffffffc020048a:	b8240413          	addi	s0,s0,-1150 # ffffffffc0209008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020048e:	c51ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200492:	600c                	ld	a1,0(s0)
ffffffffc0200494:	00004517          	auipc	a0,0x4
ffffffffc0200498:	d4450513          	addi	a0,a0,-700 # ffffffffc02041d8 <etext+0x2b2>
ffffffffc020049c:	c43ff0ef          	jal	ffffffffc02000de <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02004a0:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02004a2:	00004517          	auipc	a0,0x4
ffffffffc02004a6:	d4e50513          	addi	a0,a0,-690 # ffffffffc02041f0 <etext+0x2ca>
    if (boot_dtb == 0) {
ffffffffc02004aa:	10070163          	beqz	a4,ffffffffc02005ac <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc02004ae:	57f5                	li	a5,-3
ffffffffc02004b0:	07fa                	slli	a5,a5,0x1e
ffffffffc02004b2:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02004b4:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc02004b6:	d00e06b7          	lui	a3,0xd00e0
ffffffffc02004ba:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed2a05>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004be:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004c2:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c6:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ca:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d2:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d4:	8e49                	or	a2,a2,a0
ffffffffc02004d6:	0ff7f793          	zext.b	a5,a5
ffffffffc02004da:	8dd1                	or	a1,a1,a2
ffffffffc02004dc:	07a2                	slli	a5,a5,0x8
ffffffffc02004de:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e0:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02004e4:	0cd59863          	bne	a1,a3,ffffffffc02005b4 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02004e8:	4710                	lw	a2,8(a4)
ffffffffc02004ea:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02004ec:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ee:	0086541b          	srliw	s0,a2,0x8
ffffffffc02004f2:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f6:	01865e1b          	srliw	t3,a2,0x18
ffffffffc02004fa:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004fe:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200502:	0186959b          	slliw	a1,a3,0x18
ffffffffc0200506:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020050a:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020050e:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200512:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200516:	01c56533          	or	a0,a0,t3
ffffffffc020051a:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020051e:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200522:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200526:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052a:	0ff6f693          	zext.b	a3,a3
ffffffffc020052e:	8c49                	or	s0,s0,a0
ffffffffc0200530:	0622                	slli	a2,a2,0x8
ffffffffc0200532:	8fcd                	or	a5,a5,a1
ffffffffc0200534:	06a2                	slli	a3,a3,0x8
ffffffffc0200536:	8c51                	or	s0,s0,a2
ffffffffc0200538:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020053a:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020053c:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020053e:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200540:	9381                	srli	a5,a5,0x20
ffffffffc0200542:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200544:	4301                	li	t1,0
        switch (token) {
ffffffffc0200546:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200548:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020054a:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc020054e:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200550:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200552:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200556:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020055a:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020055e:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200562:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200566:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020056a:	8ed1                	or	a3,a3,a2
ffffffffc020056c:	0ff77713          	zext.b	a4,a4
ffffffffc0200570:	8fd5                	or	a5,a5,a3
ffffffffc0200572:	0722                	slli	a4,a4,0x8
ffffffffc0200574:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc0200576:	05178763          	beq	a5,a7,ffffffffc02005c4 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020057a:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc020057c:	00f8e963          	bltu	a7,a5,ffffffffc020058e <dtb_init+0x12a>
ffffffffc0200580:	07c78d63          	beq	a5,t3,ffffffffc02005fa <dtb_init+0x196>
ffffffffc0200584:	4709                	li	a4,2
ffffffffc0200586:	00e79763          	bne	a5,a4,ffffffffc0200594 <dtb_init+0x130>
ffffffffc020058a:	4301                	li	t1,0
ffffffffc020058c:	b7d1                	j	ffffffffc0200550 <dtb_init+0xec>
ffffffffc020058e:	4711                	li	a4,4
ffffffffc0200590:	fce780e3          	beq	a5,a4,ffffffffc0200550 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200594:	00004517          	auipc	a0,0x4
ffffffffc0200598:	d2450513          	addi	a0,a0,-732 # ffffffffc02042b8 <etext+0x392>
ffffffffc020059c:	b43ff0ef          	jal	ffffffffc02000de <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02005a0:	64e2                	ld	s1,24(sp)
ffffffffc02005a2:	6942                	ld	s2,16(sp)
ffffffffc02005a4:	00004517          	auipc	a0,0x4
ffffffffc02005a8:	d4c50513          	addi	a0,a0,-692 # ffffffffc02042f0 <etext+0x3ca>
}
ffffffffc02005ac:	7402                	ld	s0,32(sp)
ffffffffc02005ae:	70a2                	ld	ra,40(sp)
ffffffffc02005b0:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc02005b2:	b635                	j	ffffffffc02000de <cprintf>
}
ffffffffc02005b4:	7402                	ld	s0,32(sp)
ffffffffc02005b6:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005b8:	00004517          	auipc	a0,0x4
ffffffffc02005bc:	c5850513          	addi	a0,a0,-936 # ffffffffc0204210 <etext+0x2ea>
}
ffffffffc02005c0:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005c2:	be31                	j	ffffffffc02000de <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005c4:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c6:	0087579b          	srliw	a5,a4,0x8
ffffffffc02005ca:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ce:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005d2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005d6:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005da:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005de:	8ed1                	or	a3,a3,a2
ffffffffc02005e0:	0ff77713          	zext.b	a4,a4
ffffffffc02005e4:	8fd5                	or	a5,a5,a3
ffffffffc02005e6:	0722                	slli	a4,a4,0x8
ffffffffc02005e8:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005ea:	04031463          	bnez	t1,ffffffffc0200632 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02005ee:	1782                	slli	a5,a5,0x20
ffffffffc02005f0:	9381                	srli	a5,a5,0x20
ffffffffc02005f2:	043d                	addi	s0,s0,15
ffffffffc02005f4:	943e                	add	s0,s0,a5
ffffffffc02005f6:	9871                	andi	s0,s0,-4
                break;
ffffffffc02005f8:	bfa1                	j	ffffffffc0200550 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc02005fa:	8522                	mv	a0,s0
ffffffffc02005fc:	e01a                	sd	t1,0(sp)
ffffffffc02005fe:	444030ef          	jal	ffffffffc0203a42 <strlen>
ffffffffc0200602:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200604:	4619                	li	a2,6
ffffffffc0200606:	8522                	mv	a0,s0
ffffffffc0200608:	00004597          	auipc	a1,0x4
ffffffffc020060c:	c3058593          	addi	a1,a1,-976 # ffffffffc0204238 <etext+0x312>
ffffffffc0200610:	4ac030ef          	jal	ffffffffc0203abc <strncmp>
ffffffffc0200614:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200616:	0411                	addi	s0,s0,4
ffffffffc0200618:	0004879b          	sext.w	a5,s1
ffffffffc020061c:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020061e:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200622:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200624:	00a36333          	or	t1,t1,a0
                break;
ffffffffc0200628:	00ff0837          	lui	a6,0xff0
ffffffffc020062c:	488d                	li	a7,3
ffffffffc020062e:	4e05                	li	t3,1
ffffffffc0200630:	b705                	j	ffffffffc0200550 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200632:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200634:	00004597          	auipc	a1,0x4
ffffffffc0200638:	c0c58593          	addi	a1,a1,-1012 # ffffffffc0204240 <etext+0x31a>
ffffffffc020063c:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020063e:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200642:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200646:	0187169b          	slliw	a3,a4,0x18
ffffffffc020064a:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020064e:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200652:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200656:	8ed1                	or	a3,a3,a2
ffffffffc0200658:	0ff77713          	zext.b	a4,a4
ffffffffc020065c:	0722                	slli	a4,a4,0x8
ffffffffc020065e:	8d55                	or	a0,a0,a3
ffffffffc0200660:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200662:	1502                	slli	a0,a0,0x20
ffffffffc0200664:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200666:	954a                	add	a0,a0,s2
ffffffffc0200668:	e01a                	sd	t1,0(sp)
ffffffffc020066a:	41e030ef          	jal	ffffffffc0203a88 <strcmp>
ffffffffc020066e:	67a2                	ld	a5,8(sp)
ffffffffc0200670:	473d                	li	a4,15
ffffffffc0200672:	6302                	ld	t1,0(sp)
ffffffffc0200674:	00ff0837          	lui	a6,0xff0
ffffffffc0200678:	488d                	li	a7,3
ffffffffc020067a:	4e05                	li	t3,1
ffffffffc020067c:	f6f779e3          	bgeu	a4,a5,ffffffffc02005ee <dtb_init+0x18a>
ffffffffc0200680:	f53d                	bnez	a0,ffffffffc02005ee <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200682:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200686:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020068a:	00004517          	auipc	a0,0x4
ffffffffc020068e:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0204248 <etext+0x322>
           fdt32_to_cpu(x >> 32);
ffffffffc0200692:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200696:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020069a:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc020069e:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006a2:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a6:	0187959b          	slliw	a1,a5,0x18
ffffffffc02006aa:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ae:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006b2:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	01037333          	and	t1,t1,a6
ffffffffc02006be:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006c2:	01e5e5b3          	or	a1,a1,t5
ffffffffc02006c6:	0ff7f793          	zext.b	a5,a5
ffffffffc02006ca:	01de6e33          	or	t3,t3,t4
ffffffffc02006ce:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d2:	01067633          	and	a2,a2,a6
ffffffffc02006d6:	0086d31b          	srliw	t1,a3,0x8
ffffffffc02006da:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006de:	07a2                	slli	a5,a5,0x8
ffffffffc02006e0:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02006e4:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02006e8:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02006ec:	8ddd                	or	a1,a1,a5
ffffffffc02006ee:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006f2:	0186979b          	slliw	a5,a3,0x18
ffffffffc02006f6:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006fa:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006fe:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200702:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200706:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020070a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020070e:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200712:	08a2                	slli	a7,a7,0x8
ffffffffc0200714:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200718:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071c:	0ff6f693          	zext.b	a3,a3
ffffffffc0200720:	01de6833          	or	a6,t3,t4
ffffffffc0200724:	0ff77713          	zext.b	a4,a4
ffffffffc0200728:	01166633          	or	a2,a2,a7
ffffffffc020072c:	0067e7b3          	or	a5,a5,t1
ffffffffc0200730:	06a2                	slli	a3,a3,0x8
ffffffffc0200732:	01046433          	or	s0,s0,a6
ffffffffc0200736:	0722                	slli	a4,a4,0x8
ffffffffc0200738:	8fd5                	or	a5,a5,a3
ffffffffc020073a:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc020073c:	1582                	slli	a1,a1,0x20
ffffffffc020073e:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200740:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200742:	9201                	srli	a2,a2,0x20
ffffffffc0200744:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200746:	1402                	slli	s0,s0,0x20
ffffffffc0200748:	00b7e4b3          	or	s1,a5,a1
ffffffffc020074c:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc020074e:	991ff0ef          	jal	ffffffffc02000de <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200752:	85a6                	mv	a1,s1
ffffffffc0200754:	00004517          	auipc	a0,0x4
ffffffffc0200758:	b1450513          	addi	a0,a0,-1260 # ffffffffc0204268 <etext+0x342>
ffffffffc020075c:	983ff0ef          	jal	ffffffffc02000de <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200760:	01445613          	srli	a2,s0,0x14
ffffffffc0200764:	85a2                	mv	a1,s0
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0204280 <etext+0x35a>
ffffffffc020076e:	971ff0ef          	jal	ffffffffc02000de <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200772:	009405b3          	add	a1,s0,s1
ffffffffc0200776:	15fd                	addi	a1,a1,-1
ffffffffc0200778:	00004517          	auipc	a0,0x4
ffffffffc020077c:	b2850513          	addi	a0,a0,-1240 # ffffffffc02042a0 <etext+0x37a>
ffffffffc0200780:	95fff0ef          	jal	ffffffffc02000de <cprintf>
        memory_base = mem_base;
ffffffffc0200784:	0000d797          	auipc	a5,0xd
ffffffffc0200788:	ce97ba23          	sd	s1,-780(a5) # ffffffffc020d478 <memory_base>
        memory_size = mem_size;
ffffffffc020078c:	0000d797          	auipc	a5,0xd
ffffffffc0200790:	ce87b223          	sd	s0,-796(a5) # ffffffffc020d470 <memory_size>
ffffffffc0200794:	b531                	j	ffffffffc02005a0 <dtb_init+0x13c>

ffffffffc0200796 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200796:	0000d517          	auipc	a0,0xd
ffffffffc020079a:	ce253503          	ld	a0,-798(a0) # ffffffffc020d478 <memory_base>
ffffffffc020079e:	8082                	ret

ffffffffc02007a0 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02007a0:	0000d517          	auipc	a0,0xd
ffffffffc02007a4:	cd053503          	ld	a0,-816(a0) # ffffffffc020d470 <memory_size>
ffffffffc02007a8:	8082                	ret

ffffffffc02007aa <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02007aa:	67e1                	lui	a5,0x18
ffffffffc02007ac:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02007b0:	0000d717          	auipc	a4,0xd
ffffffffc02007b4:	ccf73823          	sd	a5,-816(a4) # ffffffffc020d480 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02007b8:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02007bc:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02007be:	953e                	add	a0,a0,a5
ffffffffc02007c0:	4601                	li	a2,0
ffffffffc02007c2:	4881                	li	a7,0
ffffffffc02007c4:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02007c8:	02000793          	li	a5,32
ffffffffc02007cc:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	b3850513          	addi	a0,a0,-1224 # ffffffffc0204308 <etext+0x3e2>
    ticks = 0;
ffffffffc02007d8:	0000d797          	auipc	a5,0xd
ffffffffc02007dc:	ca07b823          	sd	zero,-848(a5) # ffffffffc020d488 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02007e0:	8ffff06f          	j	ffffffffc02000de <cprintf>

ffffffffc02007e4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02007e4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02007e8:	0000d797          	auipc	a5,0xd
ffffffffc02007ec:	c987b783          	ld	a5,-872(a5) # ffffffffc020d480 <timebase>
ffffffffc02007f0:	4581                	li	a1,0
ffffffffc02007f2:	4601                	li	a2,0
ffffffffc02007f4:	953e                	add	a0,a0,a5
ffffffffc02007f6:	4881                	li	a7,0
ffffffffc02007f8:	00000073          	ecall
ffffffffc02007fc:	8082                	ret

ffffffffc02007fe <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02007fe:	8082                	ret

ffffffffc0200800 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200800:	100027f3          	csrr	a5,sstatus
ffffffffc0200804:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200806:	0ff57513          	zext.b	a0,a0
ffffffffc020080a:	e799                	bnez	a5,ffffffffc0200818 <cons_putc+0x18>
ffffffffc020080c:	4581                	li	a1,0
ffffffffc020080e:	4601                	li	a2,0
ffffffffc0200810:	4885                	li	a7,1
ffffffffc0200812:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200816:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200818:	1101                	addi	sp,sp,-32
ffffffffc020081a:	ec06                	sd	ra,24(sp)
ffffffffc020081c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020081e:	05a000ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0200822:	6522                	ld	a0,8(sp)
ffffffffc0200824:	4581                	li	a1,0
ffffffffc0200826:	4601                	li	a2,0
ffffffffc0200828:	4885                	li	a7,1
ffffffffc020082a:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020082e:	60e2                	ld	ra,24(sp)
ffffffffc0200830:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200832:	a081                	j	ffffffffc0200872 <intr_enable>

ffffffffc0200834 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200834:	100027f3          	csrr	a5,sstatus
ffffffffc0200838:	8b89                	andi	a5,a5,2
ffffffffc020083a:	eb89                	bnez	a5,ffffffffc020084c <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020083c:	4501                	li	a0,0
ffffffffc020083e:	4581                	li	a1,0
ffffffffc0200840:	4601                	li	a2,0
ffffffffc0200842:	4889                	li	a7,2
ffffffffc0200844:	00000073          	ecall
ffffffffc0200848:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020084a:	8082                	ret
int cons_getc(void) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200850:	028000ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0200854:	4501                	li	a0,0
ffffffffc0200856:	4581                	li	a1,0
ffffffffc0200858:	4601                	li	a2,0
ffffffffc020085a:	4889                	li	a7,2
ffffffffc020085c:	00000073          	ecall
ffffffffc0200860:	2501                	sext.w	a0,a0
ffffffffc0200862:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200864:	00e000ef          	jal	ffffffffc0200872 <intr_enable>
}
ffffffffc0200868:	60e2                	ld	ra,24(sp)
ffffffffc020086a:	6522                	ld	a0,8(sp)
ffffffffc020086c:	6105                	addi	sp,sp,32
ffffffffc020086e:	8082                	ret

ffffffffc0200870 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200870:	8082                	ret

ffffffffc0200872 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200872:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200876:	8082                	ret

ffffffffc0200878 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200878:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020087c:	8082                	ret

ffffffffc020087e <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020087e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200882:	00000797          	auipc	a5,0x0
ffffffffc0200886:	44a78793          	addi	a5,a5,1098 # ffffffffc0200ccc <__alltraps>
ffffffffc020088a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020088e:	000407b7          	lui	a5,0x40
ffffffffc0200892:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200896:	8082                	ret

ffffffffc0200898 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200898:	610c                	ld	a1,0(a0)
{
ffffffffc020089a:	1141                	addi	sp,sp,-16
ffffffffc020089c:	e022                	sd	s0,0(sp)
ffffffffc020089e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008a0:	00004517          	auipc	a0,0x4
ffffffffc02008a4:	a8850513          	addi	a0,a0,-1400 # ffffffffc0204328 <etext+0x402>
{
ffffffffc02008a8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008aa:	835ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02008ae:	640c                	ld	a1,8(s0)
ffffffffc02008b0:	00004517          	auipc	a0,0x4
ffffffffc02008b4:	a9050513          	addi	a0,a0,-1392 # ffffffffc0204340 <etext+0x41a>
ffffffffc02008b8:	827ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02008bc:	680c                	ld	a1,16(s0)
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	a9a50513          	addi	a0,a0,-1382 # ffffffffc0204358 <etext+0x432>
ffffffffc02008c6:	819ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02008ca:	6c0c                	ld	a1,24(s0)
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	aa450513          	addi	a0,a0,-1372 # ffffffffc0204370 <etext+0x44a>
ffffffffc02008d4:	80bff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02008d8:	700c                	ld	a1,32(s0)
ffffffffc02008da:	00004517          	auipc	a0,0x4
ffffffffc02008de:	aae50513          	addi	a0,a0,-1362 # ffffffffc0204388 <etext+0x462>
ffffffffc02008e2:	ffcff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02008e6:	740c                	ld	a1,40(s0)
ffffffffc02008e8:	00004517          	auipc	a0,0x4
ffffffffc02008ec:	ab850513          	addi	a0,a0,-1352 # ffffffffc02043a0 <etext+0x47a>
ffffffffc02008f0:	feeff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008f4:	780c                	ld	a1,48(s0)
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	ac250513          	addi	a0,a0,-1342 # ffffffffc02043b8 <etext+0x492>
ffffffffc02008fe:	fe0ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200902:	7c0c                	ld	a1,56(s0)
ffffffffc0200904:	00004517          	auipc	a0,0x4
ffffffffc0200908:	acc50513          	addi	a0,a0,-1332 # ffffffffc02043d0 <etext+0x4aa>
ffffffffc020090c:	fd2ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200910:	602c                	ld	a1,64(s0)
ffffffffc0200912:	00004517          	auipc	a0,0x4
ffffffffc0200916:	ad650513          	addi	a0,a0,-1322 # ffffffffc02043e8 <etext+0x4c2>
ffffffffc020091a:	fc4ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020091e:	642c                	ld	a1,72(s0)
ffffffffc0200920:	00004517          	auipc	a0,0x4
ffffffffc0200924:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204400 <etext+0x4da>
ffffffffc0200928:	fb6ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020092c:	682c                	ld	a1,80(s0)
ffffffffc020092e:	00004517          	auipc	a0,0x4
ffffffffc0200932:	aea50513          	addi	a0,a0,-1302 # ffffffffc0204418 <etext+0x4f2>
ffffffffc0200936:	fa8ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020093a:	6c2c                	ld	a1,88(s0)
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	af450513          	addi	a0,a0,-1292 # ffffffffc0204430 <etext+0x50a>
ffffffffc0200944:	f9aff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200948:	702c                	ld	a1,96(s0)
ffffffffc020094a:	00004517          	auipc	a0,0x4
ffffffffc020094e:	afe50513          	addi	a0,a0,-1282 # ffffffffc0204448 <etext+0x522>
ffffffffc0200952:	f8cff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200956:	742c                	ld	a1,104(s0)
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204460 <etext+0x53a>
ffffffffc0200960:	f7eff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200964:	782c                	ld	a1,112(s0)
ffffffffc0200966:	00004517          	auipc	a0,0x4
ffffffffc020096a:	b1250513          	addi	a0,a0,-1262 # ffffffffc0204478 <etext+0x552>
ffffffffc020096e:	f70ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200972:	7c2c                	ld	a1,120(s0)
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0204490 <etext+0x56a>
ffffffffc020097c:	f62ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200980:	604c                	ld	a1,128(s0)
ffffffffc0200982:	00004517          	auipc	a0,0x4
ffffffffc0200986:	b2650513          	addi	a0,a0,-1242 # ffffffffc02044a8 <etext+0x582>
ffffffffc020098a:	f54ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020098e:	644c                	ld	a1,136(s0)
ffffffffc0200990:	00004517          	auipc	a0,0x4
ffffffffc0200994:	b3050513          	addi	a0,a0,-1232 # ffffffffc02044c0 <etext+0x59a>
ffffffffc0200998:	f46ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020099c:	684c                	ld	a1,144(s0)
ffffffffc020099e:	00004517          	auipc	a0,0x4
ffffffffc02009a2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc02044d8 <etext+0x5b2>
ffffffffc02009a6:	f38ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02009aa:	6c4c                	ld	a1,152(s0)
ffffffffc02009ac:	00004517          	auipc	a0,0x4
ffffffffc02009b0:	b4450513          	addi	a0,a0,-1212 # ffffffffc02044f0 <etext+0x5ca>
ffffffffc02009b4:	f2aff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02009b8:	704c                	ld	a1,160(s0)
ffffffffc02009ba:	00004517          	auipc	a0,0x4
ffffffffc02009be:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0204508 <etext+0x5e2>
ffffffffc02009c2:	f1cff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02009c6:	744c                	ld	a1,168(s0)
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	b5850513          	addi	a0,a0,-1192 # ffffffffc0204520 <etext+0x5fa>
ffffffffc02009d0:	f0eff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02009d4:	784c                	ld	a1,176(s0)
ffffffffc02009d6:	00004517          	auipc	a0,0x4
ffffffffc02009da:	b6250513          	addi	a0,a0,-1182 # ffffffffc0204538 <etext+0x612>
ffffffffc02009de:	f00ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02009e2:	7c4c                	ld	a1,184(s0)
ffffffffc02009e4:	00004517          	auipc	a0,0x4
ffffffffc02009e8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0204550 <etext+0x62a>
ffffffffc02009ec:	ef2ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009f0:	606c                	ld	a1,192(s0)
ffffffffc02009f2:	00004517          	auipc	a0,0x4
ffffffffc02009f6:	b7650513          	addi	a0,a0,-1162 # ffffffffc0204568 <etext+0x642>
ffffffffc02009fa:	ee4ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02009fe:	646c                	ld	a1,200(s0)
ffffffffc0200a00:	00004517          	auipc	a0,0x4
ffffffffc0200a04:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204580 <etext+0x65a>
ffffffffc0200a08:	ed6ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a0c:	686c                	ld	a1,208(s0)
ffffffffc0200a0e:	00004517          	auipc	a0,0x4
ffffffffc0200a12:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0204598 <etext+0x672>
ffffffffc0200a16:	ec8ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200a1a:	6c6c                	ld	a1,216(s0)
ffffffffc0200a1c:	00004517          	auipc	a0,0x4
ffffffffc0200a20:	b9450513          	addi	a0,a0,-1132 # ffffffffc02045b0 <etext+0x68a>
ffffffffc0200a24:	ebaff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200a28:	706c                	ld	a1,224(s0)
ffffffffc0200a2a:	00004517          	auipc	a0,0x4
ffffffffc0200a2e:	b9e50513          	addi	a0,a0,-1122 # ffffffffc02045c8 <etext+0x6a2>
ffffffffc0200a32:	eacff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200a36:	746c                	ld	a1,232(s0)
ffffffffc0200a38:	00004517          	auipc	a0,0x4
ffffffffc0200a3c:	ba850513          	addi	a0,a0,-1112 # ffffffffc02045e0 <etext+0x6ba>
ffffffffc0200a40:	e9eff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200a44:	786c                	ld	a1,240(s0)
ffffffffc0200a46:	00004517          	auipc	a0,0x4
ffffffffc0200a4a:	bb250513          	addi	a0,a0,-1102 # ffffffffc02045f8 <etext+0x6d2>
ffffffffc0200a4e:	e90ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a52:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a54:	6402                	ld	s0,0(sp)
ffffffffc0200a56:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a58:	00004517          	auipc	a0,0x4
ffffffffc0200a5c:	bb850513          	addi	a0,a0,-1096 # ffffffffc0204610 <etext+0x6ea>
}
ffffffffc0200a60:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a62:	e7cff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200a66 <print_trapframe>:
{
ffffffffc0200a66:	1141                	addi	sp,sp,-16
ffffffffc0200a68:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a6a:	85aa                	mv	a1,a0
{
ffffffffc0200a6c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a6e:	00004517          	auipc	a0,0x4
ffffffffc0200a72:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204628 <etext+0x702>
{
ffffffffc0200a76:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a78:	e66ff0ef          	jal	ffffffffc02000de <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a7c:	8522                	mv	a0,s0
ffffffffc0200a7e:	e1bff0ef          	jal	ffffffffc0200898 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200a82:	10043583          	ld	a1,256(s0)
ffffffffc0200a86:	00004517          	auipc	a0,0x4
ffffffffc0200a8a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204640 <etext+0x71a>
ffffffffc0200a8e:	e50ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200a92:	10843583          	ld	a1,264(s0)
ffffffffc0200a96:	00004517          	auipc	a0,0x4
ffffffffc0200a9a:	bc250513          	addi	a0,a0,-1086 # ffffffffc0204658 <etext+0x732>
ffffffffc0200a9e:	e40ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200aa2:	11043583          	ld	a1,272(s0)
ffffffffc0200aa6:	00004517          	auipc	a0,0x4
ffffffffc0200aaa:	bca50513          	addi	a0,a0,-1078 # ffffffffc0204670 <etext+0x74a>
ffffffffc0200aae:	e30ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ab2:	11843583          	ld	a1,280(s0)
}
ffffffffc0200ab6:	6402                	ld	s0,0(sp)
ffffffffc0200ab8:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200aba:	00004517          	auipc	a0,0x4
ffffffffc0200abe:	bce50513          	addi	a0,a0,-1074 # ffffffffc0204688 <etext+0x762>
}
ffffffffc0200ac2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ac4:	e1aff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200ac8 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200ac8:	11853783          	ld	a5,280(a0)
ffffffffc0200acc:	472d                	li	a4,11
ffffffffc0200ace:	0786                	slli	a5,a5,0x1
ffffffffc0200ad0:	8385                	srli	a5,a5,0x1
ffffffffc0200ad2:	0af76863          	bltu	a4,a5,ffffffffc0200b82 <interrupt_handler+0xba>
ffffffffc0200ad6:	00005717          	auipc	a4,0x5
ffffffffc0200ada:	d6a70713          	addi	a4,a4,-662 # ffffffffc0205840 <commands+0x48>
ffffffffc0200ade:	078a                	slli	a5,a5,0x2
ffffffffc0200ae0:	97ba                	add	a5,a5,a4
ffffffffc0200ae2:	439c                	lw	a5,0(a5)
ffffffffc0200ae4:	97ba                	add	a5,a5,a4
ffffffffc0200ae6:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200ae8:	00004517          	auipc	a0,0x4
ffffffffc0200aec:	c1850513          	addi	a0,a0,-1000 # ffffffffc0204700 <etext+0x7da>
ffffffffc0200af0:	deeff06f          	j	ffffffffc02000de <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200af4:	00004517          	auipc	a0,0x4
ffffffffc0200af8:	bec50513          	addi	a0,a0,-1044 # ffffffffc02046e0 <etext+0x7ba>
ffffffffc0200afc:	de2ff06f          	j	ffffffffc02000de <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b00:	00004517          	auipc	a0,0x4
ffffffffc0200b04:	ba050513          	addi	a0,a0,-1120 # ffffffffc02046a0 <etext+0x77a>
ffffffffc0200b08:	dd6ff06f          	j	ffffffffc02000de <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b0c:	00004517          	auipc	a0,0x4
ffffffffc0200b10:	bb450513          	addi	a0,a0,-1100 # ffffffffc02046c0 <etext+0x79a>
ffffffffc0200b14:	dcaff06f          	j	ffffffffc02000de <cprintf>
{
ffffffffc0200b18:	1141                	addi	sp,sp,-16
ffffffffc0200b1a:	e406                	sd	ra,8(sp)
        break;
    case IRQ_U_TIMER:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_TIMER:
        clock_set_next_event();
ffffffffc0200b1c:	cc9ff0ef          	jal	ffffffffc02007e4 <clock_set_next_event>
        ticks++;
ffffffffc0200b20:	0000d697          	auipc	a3,0xd
ffffffffc0200b24:	96868693          	addi	a3,a3,-1688 # ffffffffc020d488 <ticks>
ffffffffc0200b28:	629c                	ld	a5,0(a3)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200b2a:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200b2e:	28f70713          	addi	a4,a4,655 # 28f5c28f <kern_entry-0xffffffff972a3d71>
        ticks++;
ffffffffc0200b32:	0785                	addi	a5,a5,1 # 40001 <kern_entry-0xffffffffc01bffff>
ffffffffc0200b34:	e29c                	sd	a5,0(a3)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200b36:	6288                	ld	a0,0(a3)
ffffffffc0200b38:	5c28f637          	lui	a2,0x5c28f
ffffffffc0200b3c:	1702                	slli	a4,a4,0x20
ffffffffc0200b3e:	5c360613          	addi	a2,a2,1475 # 5c28f5c3 <kern_entry-0xffffffff63f70a3d>
ffffffffc0200b42:	00255793          	srli	a5,a0,0x2
ffffffffc0200b46:	9732                	add	a4,a4,a2
ffffffffc0200b48:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200b4c:	06400593          	li	a1,100
ffffffffc0200b50:	8389                	srli	a5,a5,0x2
ffffffffc0200b52:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b56:	02f50763          	beq	a0,a5,ffffffffc0200b84 <interrupt_handler+0xbc>
            print_ticks();
        }
        if (ticks == 10 * TICK_NUM) {
ffffffffc0200b5a:	6298                	ld	a4,0(a3)
ffffffffc0200b5c:	3e800793          	li	a5,1000
ffffffffc0200b60:	00f71863          	bne	a4,a5,ffffffffc0200b70 <interrupt_handler+0xa8>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200b64:	4501                	li	a0,0
ffffffffc0200b66:	4581                	li	a1,0
ffffffffc0200b68:	4601                	li	a2,0
ffffffffc0200b6a:	48a1                	li	a7,8
ffffffffc0200b6c:	00000073          	ecall
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200b70:	60a2                	ld	ra,8(sp)
ffffffffc0200b72:	0141                	addi	sp,sp,16
ffffffffc0200b74:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200b76:	00004517          	auipc	a0,0x4
ffffffffc0200b7a:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204730 <etext+0x80a>
ffffffffc0200b7e:	d60ff06f          	j	ffffffffc02000de <cprintf>
        print_trapframe(tf);
ffffffffc0200b82:	b5d5                	j	ffffffffc0200a66 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b84:	00004517          	auipc	a0,0x4
ffffffffc0200b88:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0204720 <etext+0x7fa>
ffffffffc0200b8c:	d52ff0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc0200b90:	0000d697          	auipc	a3,0xd
ffffffffc0200b94:	8f868693          	addi	a3,a3,-1800 # ffffffffc020d488 <ticks>
}
ffffffffc0200b98:	b7c9                	j	ffffffffc0200b5a <interrupt_handler+0x92>

ffffffffc0200b9a <exception_handler>:

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200b9a:	11853783          	ld	a5,280(a0)
ffffffffc0200b9e:	473d                	li	a4,15
ffffffffc0200ba0:	10f76e63          	bltu	a4,a5,ffffffffc0200cbc <exception_handler+0x122>
ffffffffc0200ba4:	00005717          	auipc	a4,0x5
ffffffffc0200ba8:	ccc70713          	addi	a4,a4,-820 # ffffffffc0205870 <commands+0x78>
ffffffffc0200bac:	078a                	slli	a5,a5,0x2
ffffffffc0200bae:	97ba                	add	a5,a5,a4
ffffffffc0200bb0:	439c                	lw	a5,0(a5)
{
ffffffffc0200bb2:	1101                	addi	sp,sp,-32
ffffffffc0200bb4:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200bb6:	97ba                	add	a5,a5,a4
ffffffffc0200bb8:	8782                	jr	a5
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200bba:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200bbc:	00004517          	auipc	a0,0x4
ffffffffc0200bc0:	d1450513          	addi	a0,a0,-748 # ffffffffc02048d0 <etext+0x9aa>
}
ffffffffc0200bc4:	6105                	addi	sp,sp,32
        cprintf("Store/AMO page fault\n");
ffffffffc0200bc6:	d18ff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200bca:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200bcc:	00004517          	auipc	a0,0x4
ffffffffc0200bd0:	b8450513          	addi	a0,a0,-1148 # ffffffffc0204750 <etext+0x82a>
}
ffffffffc0200bd4:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200bd6:	d08ff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200bda:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200bdc:	00004517          	auipc	a0,0x4
ffffffffc0200be0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0204770 <etext+0x84a>
}
ffffffffc0200be4:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200be6:	cf8ff06f          	j	ffffffffc02000de <cprintf>
ffffffffc0200bea:	e42a                	sd	a0,8(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200bec:	00004517          	auipc	a0,0x4
ffffffffc0200bf0:	ba450513          	addi	a0,a0,-1116 # ffffffffc0204790 <etext+0x86a>
        cprintf("Breakpoint\n");
ffffffffc0200bf4:	ceaff0ef          	jal	ffffffffc02000de <cprintf>
        tf->epc += 4;
ffffffffc0200bf8:	66a2                	ld	a3,8(sp)
}
ffffffffc0200bfa:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200bfc:	1086b783          	ld	a5,264(a3)
ffffffffc0200c00:	0791                	addi	a5,a5,4
ffffffffc0200c02:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c06:	6105                	addi	sp,sp,32
ffffffffc0200c08:	8082                	ret
ffffffffc0200c0a:	e42a                	sd	a0,8(sp)
        cprintf("Breakpoint\n");
ffffffffc0200c0c:	00004517          	auipc	a0,0x4
ffffffffc0200c10:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02047a8 <etext+0x882>
ffffffffc0200c14:	b7c5                	j	ffffffffc0200bf4 <exception_handler+0x5a>
}
ffffffffc0200c16:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200c18:	00004517          	auipc	a0,0x4
ffffffffc0200c1c:	ba050513          	addi	a0,a0,-1120 # ffffffffc02047b8 <etext+0x892>
}
ffffffffc0200c20:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200c22:	cbcff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c26:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200c28:	00004517          	auipc	a0,0x4
ffffffffc0200c2c:	bb050513          	addi	a0,a0,-1104 # ffffffffc02047d8 <etext+0x8b2>
}
ffffffffc0200c30:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200c32:	cacff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c36:	60e2                	ld	ra,24(sp)
        cprintf("AMO address misaligned\n");
ffffffffc0200c38:	00004517          	auipc	a0,0x4
ffffffffc0200c3c:	bb850513          	addi	a0,a0,-1096 # ffffffffc02047f0 <etext+0x8ca>
}
ffffffffc0200c40:	6105                	addi	sp,sp,32
        cprintf("AMO address misaligned\n");
ffffffffc0200c42:	c9cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c46:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200c48:	00004517          	auipc	a0,0x4
ffffffffc0200c4c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204808 <etext+0x8e2>
}
ffffffffc0200c50:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200c52:	c8cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c56:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from U-mode\n");
ffffffffc0200c58:	00004517          	auipc	a0,0x4
ffffffffc0200c5c:	bc850513          	addi	a0,a0,-1080 # ffffffffc0204820 <etext+0x8fa>
}
ffffffffc0200c60:	6105                	addi	sp,sp,32
        cprintf("Environment call from U-mode\n");
ffffffffc0200c62:	c7cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c66:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from S-mode\n");
ffffffffc0200c68:	00004517          	auipc	a0,0x4
ffffffffc0200c6c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204840 <etext+0x91a>
}
ffffffffc0200c70:	6105                	addi	sp,sp,32
        cprintf("Environment call from S-mode\n");
ffffffffc0200c72:	c6cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c76:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c78:	00004517          	auipc	a0,0x4
ffffffffc0200c7c:	be850513          	addi	a0,a0,-1048 # ffffffffc0204860 <etext+0x93a>
}
ffffffffc0200c80:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200c82:	c5cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c86:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c88:	00004517          	auipc	a0,0x4
ffffffffc0200c8c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0204880 <etext+0x95a>
}
ffffffffc0200c90:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200c92:	c4cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200c98:	00004517          	auipc	a0,0x4
ffffffffc0200c9c:	c0850513          	addi	a0,a0,-1016 # ffffffffc02048a0 <etext+0x97a>
}
ffffffffc0200ca0:	6105                	addi	sp,sp,32
        cprintf("Instruction page fault\n");
ffffffffc0200ca2:	c3cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200ca6:	60e2                	ld	ra,24(sp)
        cprintf("Load page fault\n");
ffffffffc0200ca8:	00004517          	auipc	a0,0x4
ffffffffc0200cac:	c1050513          	addi	a0,a0,-1008 # ffffffffc02048b8 <etext+0x992>
}
ffffffffc0200cb0:	6105                	addi	sp,sp,32
        cprintf("Load page fault\n");
ffffffffc0200cb2:	c2cff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200cb6:	60e2                	ld	ra,24(sp)
ffffffffc0200cb8:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200cba:	b375                	j	ffffffffc0200a66 <print_trapframe>
ffffffffc0200cbc:	b36d                	j	ffffffffc0200a66 <print_trapframe>

ffffffffc0200cbe <trap>:
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
ffffffffc0200cbe:	11853783          	ld	a5,280(a0)
ffffffffc0200cc2:	0007c363          	bltz	a5,ffffffffc0200cc8 <trap+0xa>
        interrupt_handler(tf);
    }
    else
    {
        // exceptions
        exception_handler(tf);
ffffffffc0200cc6:	bdd1                	j	ffffffffc0200b9a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200cc8:	b501                	j	ffffffffc0200ac8 <interrupt_handler>
	...

ffffffffc0200ccc <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ccc:	14011073          	csrw	sscratch,sp
ffffffffc0200cd0:	712d                	addi	sp,sp,-288
ffffffffc0200cd2:	e406                	sd	ra,8(sp)
ffffffffc0200cd4:	ec0e                	sd	gp,24(sp)
ffffffffc0200cd6:	f012                	sd	tp,32(sp)
ffffffffc0200cd8:	f416                	sd	t0,40(sp)
ffffffffc0200cda:	f81a                	sd	t1,48(sp)
ffffffffc0200cdc:	fc1e                	sd	t2,56(sp)
ffffffffc0200cde:	e0a2                	sd	s0,64(sp)
ffffffffc0200ce0:	e4a6                	sd	s1,72(sp)
ffffffffc0200ce2:	e8aa                	sd	a0,80(sp)
ffffffffc0200ce4:	ecae                	sd	a1,88(sp)
ffffffffc0200ce6:	f0b2                	sd	a2,96(sp)
ffffffffc0200ce8:	f4b6                	sd	a3,104(sp)
ffffffffc0200cea:	f8ba                	sd	a4,112(sp)
ffffffffc0200cec:	fcbe                	sd	a5,120(sp)
ffffffffc0200cee:	e142                	sd	a6,128(sp)
ffffffffc0200cf0:	e546                	sd	a7,136(sp)
ffffffffc0200cf2:	e94a                	sd	s2,144(sp)
ffffffffc0200cf4:	ed4e                	sd	s3,152(sp)
ffffffffc0200cf6:	f152                	sd	s4,160(sp)
ffffffffc0200cf8:	f556                	sd	s5,168(sp)
ffffffffc0200cfa:	f95a                	sd	s6,176(sp)
ffffffffc0200cfc:	fd5e                	sd	s7,184(sp)
ffffffffc0200cfe:	e1e2                	sd	s8,192(sp)
ffffffffc0200d00:	e5e6                	sd	s9,200(sp)
ffffffffc0200d02:	e9ea                	sd	s10,208(sp)
ffffffffc0200d04:	edee                	sd	s11,216(sp)
ffffffffc0200d06:	f1f2                	sd	t3,224(sp)
ffffffffc0200d08:	f5f6                	sd	t4,232(sp)
ffffffffc0200d0a:	f9fa                	sd	t5,240(sp)
ffffffffc0200d0c:	fdfe                	sd	t6,248(sp)
ffffffffc0200d0e:	14002473          	csrr	s0,sscratch
ffffffffc0200d12:	100024f3          	csrr	s1,sstatus
ffffffffc0200d16:	14102973          	csrr	s2,sepc
ffffffffc0200d1a:	143029f3          	csrr	s3,stval
ffffffffc0200d1e:	14202a73          	csrr	s4,scause
ffffffffc0200d22:	e822                	sd	s0,16(sp)
ffffffffc0200d24:	e226                	sd	s1,256(sp)
ffffffffc0200d26:	e64a                	sd	s2,264(sp)
ffffffffc0200d28:	ea4e                	sd	s3,272(sp)
ffffffffc0200d2a:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d2c:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d2e:	f91ff0ef          	jal	ffffffffc0200cbe <trap>

ffffffffc0200d32 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d32:	6492                	ld	s1,256(sp)
ffffffffc0200d34:	6932                	ld	s2,264(sp)
ffffffffc0200d36:	10049073          	csrw	sstatus,s1
ffffffffc0200d3a:	14191073          	csrw	sepc,s2
ffffffffc0200d3e:	60a2                	ld	ra,8(sp)
ffffffffc0200d40:	61e2                	ld	gp,24(sp)
ffffffffc0200d42:	7202                	ld	tp,32(sp)
ffffffffc0200d44:	72a2                	ld	t0,40(sp)
ffffffffc0200d46:	7342                	ld	t1,48(sp)
ffffffffc0200d48:	73e2                	ld	t2,56(sp)
ffffffffc0200d4a:	6406                	ld	s0,64(sp)
ffffffffc0200d4c:	64a6                	ld	s1,72(sp)
ffffffffc0200d4e:	6546                	ld	a0,80(sp)
ffffffffc0200d50:	65e6                	ld	a1,88(sp)
ffffffffc0200d52:	7606                	ld	a2,96(sp)
ffffffffc0200d54:	76a6                	ld	a3,104(sp)
ffffffffc0200d56:	7746                	ld	a4,112(sp)
ffffffffc0200d58:	77e6                	ld	a5,120(sp)
ffffffffc0200d5a:	680a                	ld	a6,128(sp)
ffffffffc0200d5c:	68aa                	ld	a7,136(sp)
ffffffffc0200d5e:	694a                	ld	s2,144(sp)
ffffffffc0200d60:	69ea                	ld	s3,152(sp)
ffffffffc0200d62:	7a0a                	ld	s4,160(sp)
ffffffffc0200d64:	7aaa                	ld	s5,168(sp)
ffffffffc0200d66:	7b4a                	ld	s6,176(sp)
ffffffffc0200d68:	7bea                	ld	s7,184(sp)
ffffffffc0200d6a:	6c0e                	ld	s8,192(sp)
ffffffffc0200d6c:	6cae                	ld	s9,200(sp)
ffffffffc0200d6e:	6d4e                	ld	s10,208(sp)
ffffffffc0200d70:	6dee                	ld	s11,216(sp)
ffffffffc0200d72:	7e0e                	ld	t3,224(sp)
ffffffffc0200d74:	7eae                	ld	t4,232(sp)
ffffffffc0200d76:	7f4e                	ld	t5,240(sp)
ffffffffc0200d78:	7fee                	ld	t6,248(sp)
ffffffffc0200d7a:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200d7c:	10200073          	sret

ffffffffc0200d80 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d80:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d82:	bf45                	j	ffffffffc0200d32 <__trapret>
ffffffffc0200d84:	0001                	nop

ffffffffc0200d86 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0200d86:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200d88:	00004697          	auipc	a3,0x4
ffffffffc0200d8c:	b6068693          	addi	a3,a3,-1184 # ffffffffc02048e8 <etext+0x9c2>
ffffffffc0200d90:	00004617          	auipc	a2,0x4
ffffffffc0200d94:	b7860613          	addi	a2,a2,-1160 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0200d98:	08800593          	li	a1,136
ffffffffc0200d9c:	00004517          	auipc	a0,0x4
ffffffffc0200da0:	b8450513          	addi	a0,a0,-1148 # ffffffffc0204920 <etext+0x9fa>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0200da4:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200da6:	c34ff0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0200daa <find_vma>:
    if (mm != NULL)
ffffffffc0200daa:	c505                	beqz	a0,ffffffffc0200dd2 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc0200dac:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0200dae:	c781                	beqz	a5,ffffffffc0200db6 <find_vma+0xc>
ffffffffc0200db0:	6798                	ld	a4,8(a5)
ffffffffc0200db2:	02e5f363          	bgeu	a1,a4,ffffffffc0200dd8 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200db6:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc0200db8:	00f50d63          	beq	a0,a5,ffffffffc0200dd2 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0200dbc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200dc0:	00e5e663          	bltu	a1,a4,ffffffffc0200dcc <find_vma+0x22>
ffffffffc0200dc4:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200dc8:	00e5ee63          	bltu	a1,a4,ffffffffc0200de4 <find_vma+0x3a>
ffffffffc0200dcc:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0200dce:	fef517e3          	bne	a0,a5,ffffffffc0200dbc <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc0200dd2:	4781                	li	a5,0
}
ffffffffc0200dd4:	853e                	mv	a0,a5
ffffffffc0200dd6:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0200dd8:	6b98                	ld	a4,16(a5)
ffffffffc0200dda:	fce5fee3          	bgeu	a1,a4,ffffffffc0200db6 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0200dde:	e91c                	sd	a5,16(a0)
}
ffffffffc0200de0:	853e                	mv	a0,a5
ffffffffc0200de2:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0200de4:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200de6:	e91c                	sd	a5,16(a0)
ffffffffc0200de8:	bfe5                	j	ffffffffc0200de0 <find_vma+0x36>

ffffffffc0200dea <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200dea:	6590                	ld	a2,8(a1)
ffffffffc0200dec:	0105b803          	ld	a6,16(a1)
{
ffffffffc0200df0:	1141                	addi	sp,sp,-16
ffffffffc0200df2:	e406                	sd	ra,8(sp)
ffffffffc0200df4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200df6:	01066763          	bltu	a2,a6,ffffffffc0200e04 <insert_vma_struct+0x1a>
ffffffffc0200dfa:	a8b9                	j	ffffffffc0200e58 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0200dfc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200e00:	04e66763          	bltu	a2,a4,ffffffffc0200e4e <insert_vma_struct+0x64>
ffffffffc0200e04:	86be                	mv	a3,a5
ffffffffc0200e06:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0200e08:	fef51ae3          	bne	a0,a5,ffffffffc0200dfc <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0200e0c:	02a68463          	beq	a3,a0,ffffffffc0200e34 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200e10:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200e14:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200e18:	08e8f063          	bgeu	a7,a4,ffffffffc0200e98 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200e1c:	04e66e63          	bltu	a2,a4,ffffffffc0200e78 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc0200e20:	00f50a63          	beq	a0,a5,ffffffffc0200e34 <insert_vma_struct+0x4a>
ffffffffc0200e24:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200e28:	05076863          	bltu	a4,a6,ffffffffc0200e78 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0200e2c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200e30:	02c77263          	bgeu	a4,a2,ffffffffc0200e54 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0200e34:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200e36:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200e38:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200e3c:	e390                	sd	a2,0(a5)
ffffffffc0200e3e:	e690                	sd	a2,8(a3)
}
ffffffffc0200e40:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200e42:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200e44:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0200e46:	2705                	addiw	a4,a4,1
ffffffffc0200e48:	d118                	sw	a4,32(a0)
}
ffffffffc0200e4a:	0141                	addi	sp,sp,16
ffffffffc0200e4c:	8082                	ret
    if (le_prev != list)
ffffffffc0200e4e:	fca691e3          	bne	a3,a0,ffffffffc0200e10 <insert_vma_struct+0x26>
ffffffffc0200e52:	bfd9                	j	ffffffffc0200e28 <insert_vma_struct+0x3e>
ffffffffc0200e54:	f33ff0ef          	jal	ffffffffc0200d86 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200e58:	00004697          	auipc	a3,0x4
ffffffffc0200e5c:	ad868693          	addi	a3,a3,-1320 # ffffffffc0204930 <etext+0xa0a>
ffffffffc0200e60:	00004617          	auipc	a2,0x4
ffffffffc0200e64:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0200e68:	08e00593          	li	a1,142
ffffffffc0200e6c:	00004517          	auipc	a0,0x4
ffffffffc0200e70:	ab450513          	addi	a0,a0,-1356 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0200e74:	b66ff0ef          	jal	ffffffffc02001da <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200e78:	00004697          	auipc	a3,0x4
ffffffffc0200e7c:	af868693          	addi	a3,a3,-1288 # ffffffffc0204970 <etext+0xa4a>
ffffffffc0200e80:	00004617          	auipc	a2,0x4
ffffffffc0200e84:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0200e88:	08700593          	li	a1,135
ffffffffc0200e8c:	00004517          	auipc	a0,0x4
ffffffffc0200e90:	a9450513          	addi	a0,a0,-1388 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0200e94:	b46ff0ef          	jal	ffffffffc02001da <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200e98:	00004697          	auipc	a3,0x4
ffffffffc0200e9c:	ab868693          	addi	a3,a3,-1352 # ffffffffc0204950 <etext+0xa2a>
ffffffffc0200ea0:	00004617          	auipc	a2,0x4
ffffffffc0200ea4:	a6860613          	addi	a2,a2,-1432 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0200ea8:	08600593          	li	a1,134
ffffffffc0200eac:	00004517          	auipc	a0,0x4
ffffffffc0200eb0:	a7450513          	addi	a0,a0,-1420 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0200eb4:	b26ff0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0200eb8 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0200eb8:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200eba:	03000513          	li	a0,48
{
ffffffffc0200ebe:	fc06                	sd	ra,56(sp)
ffffffffc0200ec0:	f822                	sd	s0,48(sp)
ffffffffc0200ec2:	f426                	sd	s1,40(sp)
ffffffffc0200ec4:	f04a                	sd	s2,32(sp)
ffffffffc0200ec6:	ec4e                	sd	s3,24(sp)
ffffffffc0200ec8:	e852                	sd	s4,16(sp)
ffffffffc0200eca:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ecc:	5ac000ef          	jal	ffffffffc0201478 <kmalloc>
    if (mm != NULL)
ffffffffc0200ed0:	18050a63          	beqz	a0,ffffffffc0201064 <vmm_init+0x1ac>
ffffffffc0200ed4:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc0200ed6:	e508                	sd	a0,8(a0)
ffffffffc0200ed8:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200eda:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200ede:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ee2:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0200ee6:	02053423          	sd	zero,40(a0)
ffffffffc0200eea:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200eee:	03000513          	li	a0,48
ffffffffc0200ef2:	586000ef          	jal	ffffffffc0201478 <kmalloc>
    if (vma != NULL)
ffffffffc0200ef6:	14050763          	beqz	a0,ffffffffc0201044 <vmm_init+0x18c>
        vma->vm_end = vm_end;
ffffffffc0200efa:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0200efe:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200f00:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0200f04:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200f06:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0200f08:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0200f0a:	8522                	mv	a0,s0
ffffffffc0200f0c:	edfff0ef          	jal	ffffffffc0200dea <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0200f10:	fcf9                	bnez	s1,ffffffffc0200eee <vmm_init+0x36>
ffffffffc0200f12:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200f16:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f1a:	03000513          	li	a0,48
ffffffffc0200f1e:	55a000ef          	jal	ffffffffc0201478 <kmalloc>
    if (vma != NULL)
ffffffffc0200f22:	16050163          	beqz	a0,ffffffffc0201084 <vmm_init+0x1cc>
        vma->vm_end = vm_end;
ffffffffc0200f26:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0200f2a:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200f2c:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0200f30:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200f32:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200f34:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0200f36:	8522                	mv	a0,s0
ffffffffc0200f38:	eb3ff0ef          	jal	ffffffffc0200dea <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200f3c:	fd249fe3          	bne	s1,s2,ffffffffc0200f1a <vmm_init+0x62>
    return listelm->next;
ffffffffc0200f40:	641c                	ld	a5,8(s0)
ffffffffc0200f42:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0200f44:	1fb00593          	li	a1,507
ffffffffc0200f48:	8abe                	mv	s5,a5
    {
        assert(le != &(mm->mmap_list));
ffffffffc0200f4a:	20f40d63          	beq	s0,a5,ffffffffc0201164 <vmm_init+0x2ac>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200f4e:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200f52:	ffe70693          	addi	a3,a4,-2
ffffffffc0200f56:	14d61763          	bne	a2,a3,ffffffffc02010a4 <vmm_init+0x1ec>
ffffffffc0200f5a:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200f5e:	14e69363          	bne	a3,a4,ffffffffc02010a4 <vmm_init+0x1ec>
    for (i = 1; i <= step2; i++)
ffffffffc0200f62:	0715                	addi	a4,a4,5
ffffffffc0200f64:	679c                	ld	a5,8(a5)
ffffffffc0200f66:	feb712e3          	bne	a4,a1,ffffffffc0200f4a <vmm_init+0x92>
ffffffffc0200f6a:	491d                	li	s2,7
ffffffffc0200f6c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200f6e:	85a6                	mv	a1,s1
ffffffffc0200f70:	8522                	mv	a0,s0
ffffffffc0200f72:	e39ff0ef          	jal	ffffffffc0200daa <find_vma>
ffffffffc0200f76:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0200f78:	22050663          	beqz	a0,ffffffffc02011a4 <vmm_init+0x2ec>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0200f7c:	00148593          	addi	a1,s1,1
ffffffffc0200f80:	8522                	mv	a0,s0
ffffffffc0200f82:	e29ff0ef          	jal	ffffffffc0200daa <find_vma>
ffffffffc0200f86:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200f88:	1e050e63          	beqz	a0,ffffffffc0201184 <vmm_init+0x2cc>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0200f8c:	85ca                	mv	a1,s2
ffffffffc0200f8e:	8522                	mv	a0,s0
ffffffffc0200f90:	e1bff0ef          	jal	ffffffffc0200daa <find_vma>
        assert(vma3 == NULL);
ffffffffc0200f94:	1a051863          	bnez	a0,ffffffffc0201144 <vmm_init+0x28c>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0200f98:	00348593          	addi	a1,s1,3
ffffffffc0200f9c:	8522                	mv	a0,s0
ffffffffc0200f9e:	e0dff0ef          	jal	ffffffffc0200daa <find_vma>
        assert(vma4 == NULL);
ffffffffc0200fa2:	18051163          	bnez	a0,ffffffffc0201124 <vmm_init+0x26c>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0200fa6:	00448593          	addi	a1,s1,4
ffffffffc0200faa:	8522                	mv	a0,s0
ffffffffc0200fac:	dffff0ef          	jal	ffffffffc0200daa <find_vma>
        assert(vma5 == NULL);
ffffffffc0200fb0:	14051a63          	bnez	a0,ffffffffc0201104 <vmm_init+0x24c>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0200fb4:	008a3783          	ld	a5,8(s4)
ffffffffc0200fb8:	12979663          	bne	a5,s1,ffffffffc02010e4 <vmm_init+0x22c>
ffffffffc0200fbc:	010a3783          	ld	a5,16(s4)
ffffffffc0200fc0:	13279263          	bne	a5,s2,ffffffffc02010e4 <vmm_init+0x22c>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0200fc4:	0089b783          	ld	a5,8(s3)
ffffffffc0200fc8:	0e979e63          	bne	a5,s1,ffffffffc02010c4 <vmm_init+0x20c>
ffffffffc0200fcc:	0109b783          	ld	a5,16(s3)
ffffffffc0200fd0:	0f279a63          	bne	a5,s2,ffffffffc02010c4 <vmm_init+0x20c>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0200fd4:	0495                	addi	s1,s1,5
ffffffffc0200fd6:	1f900793          	li	a5,505
ffffffffc0200fda:	0915                	addi	s2,s2,5
ffffffffc0200fdc:	f8f499e3          	bne	s1,a5,ffffffffc0200f6e <vmm_init+0xb6>
ffffffffc0200fe0:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0200fe2:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0200fe4:	85a6                	mv	a1,s1
ffffffffc0200fe6:	8522                	mv	a0,s0
ffffffffc0200fe8:	dc3ff0ef          	jal	ffffffffc0200daa <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0200fec:	1c051c63          	bnez	a0,ffffffffc02011c4 <vmm_init+0x30c>
    for (i = 4; i >= 0; i--)
ffffffffc0200ff0:	14fd                	addi	s1,s1,-1
ffffffffc0200ff2:	ff2499e3          	bne	s1,s2,ffffffffc0200fe4 <vmm_init+0x12c>
    while ((le = list_next(list)) != list)
ffffffffc0200ff6:	028a8063          	beq	s5,s0,ffffffffc0201016 <vmm_init+0x15e>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ffa:	008ab783          	ld	a5,8(s5)
ffffffffc0200ffe:	000ab703          	ld	a4,0(s5)
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0201002:	fe0a8513          	addi	a0,s5,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201006:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201008:	e398                	sd	a4,0(a5)
ffffffffc020100a:	514000ef          	jal	ffffffffc020151e <kfree>
    return listelm->next;
ffffffffc020100e:	641c                	ld	a5,8(s0)
ffffffffc0201010:	8abe                	mv	s5,a5
    while ((le = list_next(list)) != list)
ffffffffc0201012:	fef414e3          	bne	s0,a5,ffffffffc0200ffa <vmm_init+0x142>
    kfree(mm); // kfree mm
ffffffffc0201016:	8522                	mv	a0,s0
ffffffffc0201018:	506000ef          	jal	ffffffffc020151e <kfree>
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	ad450513          	addi	a0,a0,-1324 # ffffffffc0204af0 <etext+0xbca>
ffffffffc0201024:	8baff0ef          	jal	ffffffffc02000de <cprintf>
}
ffffffffc0201028:	7442                	ld	s0,48(sp)
ffffffffc020102a:	70e2                	ld	ra,56(sp)
ffffffffc020102c:	74a2                	ld	s1,40(sp)
ffffffffc020102e:	7902                	ld	s2,32(sp)
ffffffffc0201030:	69e2                	ld	s3,24(sp)
ffffffffc0201032:	6a42                	ld	s4,16(sp)
ffffffffc0201034:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	ada50513          	addi	a0,a0,-1318 # ffffffffc0204b10 <etext+0xbea>
}
ffffffffc020103e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201040:	89eff06f          	j	ffffffffc02000de <cprintf>
        assert(vma != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	95c68693          	addi	a3,a3,-1700 # ffffffffc02049a0 <etext+0xa7a>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201054:	0da00593          	li	a1,218
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	8c850513          	addi	a0,a0,-1848 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201060:	97aff0ef          	jal	ffffffffc02001da <__panic>
    assert(mm != NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	92c68693          	addi	a3,a3,-1748 # ffffffffc0204990 <etext+0xa6a>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	89c60613          	addi	a2,a2,-1892 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201074:	0d200593          	li	a1,210
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	8a850513          	addi	a0,a0,-1880 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201080:	95aff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma != NULL);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	91c68693          	addi	a3,a3,-1764 # ffffffffc02049a0 <etext+0xa7a>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	87c60613          	addi	a2,a2,-1924 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201094:	0e100593          	li	a1,225
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	88850513          	addi	a0,a0,-1912 # ffffffffc0204920 <etext+0x9fa>
ffffffffc02010a0:	93aff0ef          	jal	ffffffffc02001da <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	92468693          	addi	a3,a3,-1756 # ffffffffc02049c8 <etext+0xaa2>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	85c60613          	addi	a2,a2,-1956 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02010b4:	0eb00593          	li	a1,235
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	86850513          	addi	a0,a0,-1944 # ffffffffc0204920 <etext+0x9fa>
ffffffffc02010c0:	91aff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0204a80 <etext+0xb5a>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	83c60613          	addi	a2,a2,-1988 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02010d4:	0fd00593          	li	a1,253
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	84850513          	addi	a0,a0,-1976 # ffffffffc0204920 <etext+0x9fa>
ffffffffc02010e0:	8faff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	96c68693          	addi	a3,a3,-1684 # ffffffffc0204a50 <etext+0xb2a>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	81c60613          	addi	a2,a2,-2020 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02010f4:	0fc00593          	li	a1,252
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	82850513          	addi	a0,a0,-2008 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201100:	8daff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma5 == NULL);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	93c68693          	addi	a3,a3,-1732 # ffffffffc0204a40 <etext+0xb1a>
ffffffffc020110c:	00003617          	auipc	a2,0x3
ffffffffc0201110:	7fc60613          	addi	a2,a2,2044 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201114:	0fa00593          	li	a1,250
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	80850513          	addi	a0,a0,-2040 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201120:	8baff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma4 == NULL);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	90c68693          	addi	a3,a3,-1780 # ffffffffc0204a30 <etext+0xb0a>
ffffffffc020112c:	00003617          	auipc	a2,0x3
ffffffffc0201130:	7dc60613          	addi	a2,a2,2012 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201134:	0f800593          	li	a1,248
ffffffffc0201138:	00003517          	auipc	a0,0x3
ffffffffc020113c:	7e850513          	addi	a0,a0,2024 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201140:	89aff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma3 == NULL);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0204a20 <etext+0xafa>
ffffffffc020114c:	00003617          	auipc	a2,0x3
ffffffffc0201150:	7bc60613          	addi	a2,a2,1980 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201154:	0f600593          	li	a1,246
ffffffffc0201158:	00003517          	auipc	a0,0x3
ffffffffc020115c:	7c850513          	addi	a0,a0,1992 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201160:	87aff0ef          	jal	ffffffffc02001da <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	84c68693          	addi	a3,a3,-1972 # ffffffffc02049b0 <etext+0xa8a>
ffffffffc020116c:	00003617          	auipc	a2,0x3
ffffffffc0201170:	79c60613          	addi	a2,a2,1948 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201174:	0e900593          	li	a1,233
ffffffffc0201178:	00003517          	auipc	a0,0x3
ffffffffc020117c:	7a850513          	addi	a0,a0,1960 # ffffffffc0204920 <etext+0x9fa>
ffffffffc0201180:	85aff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma2 != NULL);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	88c68693          	addi	a3,a3,-1908 # ffffffffc0204a10 <etext+0xaea>
ffffffffc020118c:	00003617          	auipc	a2,0x3
ffffffffc0201190:	77c60613          	addi	a2,a2,1916 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201194:	0f400593          	li	a1,244
ffffffffc0201198:	00003517          	auipc	a0,0x3
ffffffffc020119c:	78850513          	addi	a0,a0,1928 # ffffffffc0204920 <etext+0x9fa>
ffffffffc02011a0:	83aff0ef          	jal	ffffffffc02001da <__panic>
        assert(vma1 != NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	85c68693          	addi	a3,a3,-1956 # ffffffffc0204a00 <etext+0xada>
ffffffffc02011ac:	00003617          	auipc	a2,0x3
ffffffffc02011b0:	75c60613          	addi	a2,a2,1884 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02011b4:	0f200593          	li	a1,242
ffffffffc02011b8:	00003517          	auipc	a0,0x3
ffffffffc02011bc:	76850513          	addi	a0,a0,1896 # ffffffffc0204920 <etext+0x9fa>
ffffffffc02011c0:	81aff0ef          	jal	ffffffffc02001da <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02011c4:	6914                	ld	a3,16(a0)
ffffffffc02011c6:	6510                	ld	a2,8(a0)
ffffffffc02011c8:	0004859b          	sext.w	a1,s1
ffffffffc02011cc:	00004517          	auipc	a0,0x4
ffffffffc02011d0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0204ab0 <etext+0xb8a>
ffffffffc02011d4:	f0bfe0ef          	jal	ffffffffc02000de <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc02011d8:	00004697          	auipc	a3,0x4
ffffffffc02011dc:	90068693          	addi	a3,a3,-1792 # ffffffffc0204ad8 <etext+0xbb2>
ffffffffc02011e0:	00003617          	auipc	a2,0x3
ffffffffc02011e4:	72860613          	addi	a2,a2,1832 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02011e8:	10700593          	li	a1,263
ffffffffc02011ec:	00003517          	auipc	a0,0x3
ffffffffc02011f0:	73450513          	addi	a0,a0,1844 # ffffffffc0204920 <etext+0x9fa>
ffffffffc02011f4:	fe7fe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc02011f8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02011f8:	c531                	beqz	a0,ffffffffc0201244 <slob_free+0x4c>
		return;

	if (size)
ffffffffc02011fa:	e9b9                	bnez	a1,ffffffffc0201250 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02011fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201200:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201202:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201204:	efb1                	bnez	a5,ffffffffc0201260 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201206:	00008797          	auipc	a5,0x8
ffffffffc020120a:	e1a7b783          	ld	a5,-486(a5) # ffffffffc0209020 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020120e:	873e                	mv	a4,a5
ffffffffc0201210:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201212:	02a77a63          	bgeu	a4,a0,ffffffffc0201246 <slob_free+0x4e>
ffffffffc0201216:	00f56463          	bltu	a0,a5,ffffffffc020121e <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020121a:	fef76ae3          	bltu	a4,a5,ffffffffc020120e <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc020121e:	4110                	lw	a2,0(a0)
ffffffffc0201220:	00461693          	slli	a3,a2,0x4
ffffffffc0201224:	96aa                	add	a3,a3,a0
ffffffffc0201226:	0ad78463          	beq	a5,a3,ffffffffc02012ce <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc020122a:	4310                	lw	a2,0(a4)
ffffffffc020122c:	e51c                	sd	a5,8(a0)
ffffffffc020122e:	00461693          	slli	a3,a2,0x4
ffffffffc0201232:	96ba                	add	a3,a3,a4
ffffffffc0201234:	08d50163          	beq	a0,a3,ffffffffc02012b6 <slob_free+0xbe>
ffffffffc0201238:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc020123a:	00008797          	auipc	a5,0x8
ffffffffc020123e:	dee7b323          	sd	a4,-538(a5) # ffffffffc0209020 <slobfree>
    if (flag) {
ffffffffc0201242:	e9a5                	bnez	a1,ffffffffc02012b2 <slob_free+0xba>
ffffffffc0201244:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201246:	fcf574e3          	bgeu	a0,a5,ffffffffc020120e <slob_free+0x16>
ffffffffc020124a:	fcf762e3          	bltu	a4,a5,ffffffffc020120e <slob_free+0x16>
ffffffffc020124e:	bfc1                	j	ffffffffc020121e <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201250:	25bd                	addiw	a1,a1,15
ffffffffc0201252:	8191                	srli	a1,a1,0x4
ffffffffc0201254:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201256:	100027f3          	csrr	a5,sstatus
ffffffffc020125a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020125c:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020125e:	d7c5                	beqz	a5,ffffffffc0201206 <slob_free+0xe>
{
ffffffffc0201260:	1101                	addi	sp,sp,-32
ffffffffc0201262:	e42a                	sd	a0,8(sp)
ffffffffc0201264:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201266:	e12ff0ef          	jal	ffffffffc0200878 <intr_disable>
        return 1;
ffffffffc020126a:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020126c:	00008797          	auipc	a5,0x8
ffffffffc0201270:	db47b783          	ld	a5,-588(a5) # ffffffffc0209020 <slobfree>
ffffffffc0201274:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201276:	873e                	mv	a4,a5
ffffffffc0201278:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020127a:	06a77663          	bgeu	a4,a0,ffffffffc02012e6 <slob_free+0xee>
ffffffffc020127e:	00f56463          	bltu	a0,a5,ffffffffc0201286 <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201282:	fef76ae3          	bltu	a4,a5,ffffffffc0201276 <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201286:	4110                	lw	a2,0(a0)
ffffffffc0201288:	00461693          	slli	a3,a2,0x4
ffffffffc020128c:	96aa                	add	a3,a3,a0
ffffffffc020128e:	06d78363          	beq	a5,a3,ffffffffc02012f4 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201292:	4310                	lw	a2,0(a4)
ffffffffc0201294:	e51c                	sd	a5,8(a0)
ffffffffc0201296:	00461693          	slli	a3,a2,0x4
ffffffffc020129a:	96ba                	add	a3,a3,a4
ffffffffc020129c:	06d50163          	beq	a0,a3,ffffffffc02012fe <slob_free+0x106>
ffffffffc02012a0:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc02012a2:	00008797          	auipc	a5,0x8
ffffffffc02012a6:	d6e7bf23          	sd	a4,-642(a5) # ffffffffc0209020 <slobfree>
    if (flag) {
ffffffffc02012aa:	e1a9                	bnez	a1,ffffffffc02012ec <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02012ac:	60e2                	ld	ra,24(sp)
ffffffffc02012ae:	6105                	addi	sp,sp,32
ffffffffc02012b0:	8082                	ret
        intr_enable();
ffffffffc02012b2:	dc0ff06f          	j	ffffffffc0200872 <intr_enable>
		cur->units += b->units;
ffffffffc02012b6:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc02012b8:	853e                	mv	a0,a5
ffffffffc02012ba:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc02012bc:	00c687bb          	addw	a5,a3,a2
ffffffffc02012c0:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc02012c2:	00008797          	auipc	a5,0x8
ffffffffc02012c6:	d4e7bf23          	sd	a4,-674(a5) # ffffffffc0209020 <slobfree>
    if (flag) {
ffffffffc02012ca:	ddad                	beqz	a1,ffffffffc0201244 <slob_free+0x4c>
ffffffffc02012cc:	b7dd                	j	ffffffffc02012b2 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc02012ce:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02012d0:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02012d2:	9eb1                	addw	a3,a3,a2
ffffffffc02012d4:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc02012d6:	4310                	lw	a2,0(a4)
ffffffffc02012d8:	e51c                	sd	a5,8(a0)
ffffffffc02012da:	00461693          	slli	a3,a2,0x4
ffffffffc02012de:	96ba                	add	a3,a3,a4
ffffffffc02012e0:	f4d51ce3          	bne	a0,a3,ffffffffc0201238 <slob_free+0x40>
ffffffffc02012e4:	bfc9                	j	ffffffffc02012b6 <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02012e6:	f8f56ee3          	bltu	a0,a5,ffffffffc0201282 <slob_free+0x8a>
ffffffffc02012ea:	b771                	j	ffffffffc0201276 <slob_free+0x7e>
}
ffffffffc02012ec:	60e2                	ld	ra,24(sp)
ffffffffc02012ee:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02012f0:	d82ff06f          	j	ffffffffc0200872 <intr_enable>
		b->units += cur->next->units;
ffffffffc02012f4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02012f6:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02012f8:	9eb1                	addw	a3,a3,a2
ffffffffc02012fa:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc02012fc:	bf59                	j	ffffffffc0201292 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc02012fe:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201300:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201302:	00c687bb          	addw	a5,a3,a2
ffffffffc0201306:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201308:	bf61                	j	ffffffffc02012a0 <slob_free+0xa8>

ffffffffc020130a <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc020130a:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020130c:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc020130e:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201312:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201314:	619000ef          	jal	ffffffffc020212c <alloc_pages>
	if (!page)
ffffffffc0201318:	c91d                	beqz	a0,ffffffffc020134e <__slob_get_free_pages.constprop.0+0x44>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc020131a:	0000c697          	auipc	a3,0xc
ffffffffc020131e:	1a66b683          	ld	a3,422(a3) # ffffffffc020d4c0 <pages>
ffffffffc0201322:	00004797          	auipc	a5,0x4
ffffffffc0201326:	7567b783          	ld	a5,1878(a5) # ffffffffc0205a78 <nbase>
}

static inline void *
page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
ffffffffc020132a:	0000c717          	auipc	a4,0xc
ffffffffc020132e:	18e73703          	ld	a4,398(a4) # ffffffffc020d4b8 <npage>
    return page - pages + nbase;
ffffffffc0201332:	8d15                	sub	a0,a0,a3
ffffffffc0201334:	8519                	srai	a0,a0,0x6
ffffffffc0201336:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201338:	00c51793          	slli	a5,a0,0xc
ffffffffc020133c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020133e:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201340:	00e7fa63          	bgeu	a5,a4,ffffffffc0201354 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201344:	0000c797          	auipc	a5,0xc
ffffffffc0201348:	16c7b783          	ld	a5,364(a5) # ffffffffc020d4b0 <va_pa_offset>
ffffffffc020134c:	953e                	add	a0,a0,a5
}
ffffffffc020134e:	60a2                	ld	ra,8(sp)
ffffffffc0201350:	0141                	addi	sp,sp,16
ffffffffc0201352:	8082                	ret
ffffffffc0201354:	86aa                	mv	a3,a0
ffffffffc0201356:	00003617          	auipc	a2,0x3
ffffffffc020135a:	7d260613          	addi	a2,a2,2002 # ffffffffc0204b28 <etext+0xc02>
ffffffffc020135e:	07100593          	li	a1,113
ffffffffc0201362:	00003517          	auipc	a0,0x3
ffffffffc0201366:	7ee50513          	addi	a0,a0,2030 # ffffffffc0204b50 <etext+0xc2a>
ffffffffc020136a:	e71fe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc020136e <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc020136e:	7179                	addi	sp,sp,-48
ffffffffc0201370:	f406                	sd	ra,40(sp)
ffffffffc0201372:	f022                	sd	s0,32(sp)
ffffffffc0201374:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201376:	01050713          	addi	a4,a0,16
ffffffffc020137a:	6785                	lui	a5,0x1
ffffffffc020137c:	0af77e63          	bgeu	a4,a5,ffffffffc0201438 <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201380:	00f50413          	addi	s0,a0,15
ffffffffc0201384:	8011                	srli	s0,s0,0x4
ffffffffc0201386:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201388:	100025f3          	csrr	a1,sstatus
ffffffffc020138c:	8989                	andi	a1,a1,2
ffffffffc020138e:	edd1                	bnez	a1,ffffffffc020142a <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201390:	00008497          	auipc	s1,0x8
ffffffffc0201394:	c9048493          	addi	s1,s1,-880 # ffffffffc0209020 <slobfree>
ffffffffc0201398:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc020139a:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc020139c:	4314                	lw	a3,0(a4)
ffffffffc020139e:	0886da63          	bge	a3,s0,ffffffffc0201432 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc02013a2:	00e60a63          	beq	a2,a4,ffffffffc02013b6 <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013a6:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc02013a8:	4394                	lw	a3,0(a5)
ffffffffc02013aa:	0286d863          	bge	a3,s0,ffffffffc02013da <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc02013ae:	6090                	ld	a2,0(s1)
ffffffffc02013b0:	873e                	mv	a4,a5
ffffffffc02013b2:	fee61ae3          	bne	a2,a4,ffffffffc02013a6 <slob_alloc.constprop.0+0x38>
    if (flag) {
ffffffffc02013b6:	e9b1                	bnez	a1,ffffffffc020140a <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02013b8:	4501                	li	a0,0
ffffffffc02013ba:	f51ff0ef          	jal	ffffffffc020130a <__slob_get_free_pages.constprop.0>
ffffffffc02013be:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc02013c0:	c915                	beqz	a0,ffffffffc02013f4 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc02013c2:	6585                	lui	a1,0x1
ffffffffc02013c4:	e35ff0ef          	jal	ffffffffc02011f8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013c8:	100025f3          	csrr	a1,sstatus
ffffffffc02013cc:	8989                	andi	a1,a1,2
ffffffffc02013ce:	e98d                	bnez	a1,ffffffffc0201400 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc02013d0:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013d2:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc02013d4:	4394                	lw	a3,0(a5)
ffffffffc02013d6:	fc86cce3          	blt	a3,s0,ffffffffc02013ae <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc02013da:	04d40563          	beq	s0,a3,ffffffffc0201424 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc02013de:	00441613          	slli	a2,s0,0x4
ffffffffc02013e2:	963e                	add	a2,a2,a5
ffffffffc02013e4:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc02013e6:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc02013e8:	9e81                	subw	a3,a3,s0
ffffffffc02013ea:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc02013ec:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc02013ee:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc02013f0:	e098                	sd	a4,0(s1)
    if (flag) {
ffffffffc02013f2:	ed99                	bnez	a1,ffffffffc0201410 <slob_alloc.constprop.0+0xa2>
}
ffffffffc02013f4:	70a2                	ld	ra,40(sp)
ffffffffc02013f6:	7402                	ld	s0,32(sp)
ffffffffc02013f8:	64e2                	ld	s1,24(sp)
ffffffffc02013fa:	853e                	mv	a0,a5
ffffffffc02013fc:	6145                	addi	sp,sp,48
ffffffffc02013fe:	8082                	ret
        intr_disable();
ffffffffc0201400:	c78ff0ef          	jal	ffffffffc0200878 <intr_disable>
			cur = slobfree;
ffffffffc0201404:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201406:	4585                	li	a1,1
ffffffffc0201408:	b7e9                	j	ffffffffc02013d2 <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc020140a:	c68ff0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc020140e:	b76d                	j	ffffffffc02013b8 <slob_alloc.constprop.0+0x4a>
ffffffffc0201410:	e43e                	sd	a5,8(sp)
ffffffffc0201412:	c60ff0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0201416:	67a2                	ld	a5,8(sp)
}
ffffffffc0201418:	70a2                	ld	ra,40(sp)
ffffffffc020141a:	7402                	ld	s0,32(sp)
ffffffffc020141c:	64e2                	ld	s1,24(sp)
ffffffffc020141e:	853e                	mv	a0,a5
ffffffffc0201420:	6145                	addi	sp,sp,48
ffffffffc0201422:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201424:	6794                	ld	a3,8(a5)
ffffffffc0201426:	e714                	sd	a3,8(a4)
ffffffffc0201428:	b7e1                	j	ffffffffc02013f0 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc020142a:	c4eff0ef          	jal	ffffffffc0200878 <intr_disable>
        return 1;
ffffffffc020142e:	4585                	li	a1,1
ffffffffc0201430:	b785                	j	ffffffffc0201390 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201432:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201434:	8732                	mv	a4,a2
ffffffffc0201436:	b755                	j	ffffffffc02013da <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201438:	00003697          	auipc	a3,0x3
ffffffffc020143c:	72868693          	addi	a3,a3,1832 # ffffffffc0204b60 <etext+0xc3a>
ffffffffc0201440:	00003617          	auipc	a2,0x3
ffffffffc0201444:	4c860613          	addi	a2,a2,1224 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201448:	06300593          	li	a1,99
ffffffffc020144c:	00003517          	auipc	a0,0x3
ffffffffc0201450:	73450513          	addi	a0,a0,1844 # ffffffffc0204b80 <etext+0xc5a>
ffffffffc0201454:	d87fe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0201458 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201458:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc020145a:	00003517          	auipc	a0,0x3
ffffffffc020145e:	73e50513          	addi	a0,a0,1854 # ffffffffc0204b98 <etext+0xc72>
{
ffffffffc0201462:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201464:	c7bfe0ef          	jal	ffffffffc02000de <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201468:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc020146a:	00003517          	auipc	a0,0x3
ffffffffc020146e:	74650513          	addi	a0,a0,1862 # ffffffffc0204bb0 <etext+0xc8a>
}
ffffffffc0201472:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201474:	c6bfe06f          	j	ffffffffc02000de <cprintf>

ffffffffc0201478 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201478:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc020147a:	6685                	lui	a3,0x1
{
ffffffffc020147c:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc020147e:	16bd                	addi	a3,a3,-17 # fef <kern_entry-0xffffffffc01ff011>
ffffffffc0201480:	04a6f963          	bgeu	a3,a0,ffffffffc02014d2 <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201484:	e42a                	sd	a0,8(sp)
ffffffffc0201486:	4561                	li	a0,24
ffffffffc0201488:	e822                	sd	s0,16(sp)
ffffffffc020148a:	ee5ff0ef          	jal	ffffffffc020136e <slob_alloc.constprop.0>
ffffffffc020148e:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201490:	c541                	beqz	a0,ffffffffc0201518 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201492:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201494:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201496:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201498:	00f75763          	bge	a4,a5,ffffffffc02014a6 <kmalloc+0x2e>
ffffffffc020149c:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc02014a0:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc02014a2:	fef74de3          	blt	a4,a5,ffffffffc020149c <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc02014a6:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02014a8:	e63ff0ef          	jal	ffffffffc020130a <__slob_get_free_pages.constprop.0>
ffffffffc02014ac:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc02014ae:	cd31                	beqz	a0,ffffffffc020150a <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014b0:	100027f3          	csrr	a5,sstatus
ffffffffc02014b4:	8b89                	andi	a5,a5,2
ffffffffc02014b6:	eb85                	bnez	a5,ffffffffc02014e6 <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc02014b8:	0000c797          	auipc	a5,0xc
ffffffffc02014bc:	fd87b783          	ld	a5,-40(a5) # ffffffffc020d490 <bigblocks>
		bigblocks = bb;
ffffffffc02014c0:	0000c717          	auipc	a4,0xc
ffffffffc02014c4:	fc873823          	sd	s0,-48(a4) # ffffffffc020d490 <bigblocks>
		bb->next = bigblocks;
ffffffffc02014c8:	e81c                	sd	a5,16(s0)
    if (flag) {
ffffffffc02014ca:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc02014cc:	60e2                	ld	ra,24(sp)
ffffffffc02014ce:	6105                	addi	sp,sp,32
ffffffffc02014d0:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02014d2:	0541                	addi	a0,a0,16
ffffffffc02014d4:	e9bff0ef          	jal	ffffffffc020136e <slob_alloc.constprop.0>
ffffffffc02014d8:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc02014da:	0541                	addi	a0,a0,16
ffffffffc02014dc:	fbe5                	bnez	a5,ffffffffc02014cc <kmalloc+0x54>
		return 0;
ffffffffc02014de:	4501                	li	a0,0
}
ffffffffc02014e0:	60e2                	ld	ra,24(sp)
ffffffffc02014e2:	6105                	addi	sp,sp,32
ffffffffc02014e4:	8082                	ret
        intr_disable();
ffffffffc02014e6:	b92ff0ef          	jal	ffffffffc0200878 <intr_disable>
		bb->next = bigblocks;
ffffffffc02014ea:	0000c797          	auipc	a5,0xc
ffffffffc02014ee:	fa67b783          	ld	a5,-90(a5) # ffffffffc020d490 <bigblocks>
		bigblocks = bb;
ffffffffc02014f2:	0000c717          	auipc	a4,0xc
ffffffffc02014f6:	f8873f23          	sd	s0,-98(a4) # ffffffffc020d490 <bigblocks>
		bb->next = bigblocks;
ffffffffc02014fa:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc02014fc:	b76ff0ef          	jal	ffffffffc0200872 <intr_enable>
		return bb->pages;
ffffffffc0201500:	6408                	ld	a0,8(s0)
}
ffffffffc0201502:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201504:	6442                	ld	s0,16(sp)
}
ffffffffc0201506:	6105                	addi	sp,sp,32
ffffffffc0201508:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020150a:	8522                	mv	a0,s0
ffffffffc020150c:	45e1                	li	a1,24
ffffffffc020150e:	cebff0ef          	jal	ffffffffc02011f8 <slob_free>
		return 0;
ffffffffc0201512:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201514:	6442                	ld	s0,16(sp)
ffffffffc0201516:	b7e9                	j	ffffffffc02014e0 <kmalloc+0x68>
ffffffffc0201518:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc020151a:	4501                	li	a0,0
ffffffffc020151c:	b7d1                	j	ffffffffc02014e0 <kmalloc+0x68>

ffffffffc020151e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020151e:	c571                	beqz	a0,ffffffffc02015ea <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201520:	03451793          	slli	a5,a0,0x34
ffffffffc0201524:	e3e1                	bnez	a5,ffffffffc02015e4 <kfree+0xc6>
{
ffffffffc0201526:	1101                	addi	sp,sp,-32
ffffffffc0201528:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020152a:	100027f3          	csrr	a5,sstatus
ffffffffc020152e:	8b89                	andi	a5,a5,2
ffffffffc0201530:	e7c1                	bnez	a5,ffffffffc02015b8 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201532:	0000c797          	auipc	a5,0xc
ffffffffc0201536:	f5e7b783          	ld	a5,-162(a5) # ffffffffc020d490 <bigblocks>
    return 0;
ffffffffc020153a:	4581                	li	a1,0
ffffffffc020153c:	cbad                	beqz	a5,ffffffffc02015ae <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc020153e:	0000c617          	auipc	a2,0xc
ffffffffc0201542:	f5260613          	addi	a2,a2,-174 # ffffffffc020d490 <bigblocks>
ffffffffc0201546:	a021                	j	ffffffffc020154e <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201548:	01070613          	addi	a2,a4,16
ffffffffc020154c:	c3a5                	beqz	a5,ffffffffc02015ac <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc020154e:	6794                	ld	a3,8(a5)
ffffffffc0201550:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201552:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201554:	fea69ae3          	bne	a3,a0,ffffffffc0201548 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201558:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc020155a:	edb5                	bnez	a1,ffffffffc02015d6 <kfree+0xb8>
}

static inline struct Page *
kva2page(void *kva)
{
    return pa2page(PADDR(kva));
ffffffffc020155c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201560:	0af56263          	bltu	a0,a5,ffffffffc0201604 <kfree+0xe6>
ffffffffc0201564:	0000c797          	auipc	a5,0xc
ffffffffc0201568:	f4c7b783          	ld	a5,-180(a5) # ffffffffc020d4b0 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc020156c:	0000c697          	auipc	a3,0xc
ffffffffc0201570:	f4c6b683          	ld	a3,-180(a3) # ffffffffc020d4b8 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201574:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201576:	00c55793          	srli	a5,a0,0xc
ffffffffc020157a:	06d7f963          	bgeu	a5,a3,ffffffffc02015ec <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc020157e:	00004617          	auipc	a2,0x4
ffffffffc0201582:	4fa63603          	ld	a2,1274(a2) # ffffffffc0205a78 <nbase>
ffffffffc0201586:	0000c517          	auipc	a0,0xc
ffffffffc020158a:	f3a53503          	ld	a0,-198(a0) # ffffffffc020d4c0 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc020158e:	4314                	lw	a3,0(a4)
ffffffffc0201590:	8f91                	sub	a5,a5,a2
ffffffffc0201592:	079a                	slli	a5,a5,0x6
ffffffffc0201594:	4585                	li	a1,1
ffffffffc0201596:	953e                	add	a0,a0,a5
ffffffffc0201598:	00d595bb          	sllw	a1,a1,a3
ffffffffc020159c:	e03a                	sd	a4,0(sp)
ffffffffc020159e:	3c9000ef          	jal	ffffffffc0202166 <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02015a2:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02015a4:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02015a6:	45e1                	li	a1,24
}
ffffffffc02015a8:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02015aa:	b1b9                	j	ffffffffc02011f8 <slob_free>
ffffffffc02015ac:	e185                	bnez	a1,ffffffffc02015cc <kfree+0xae>
}
ffffffffc02015ae:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02015b0:	1541                	addi	a0,a0,-16
ffffffffc02015b2:	4581                	li	a1,0
}
ffffffffc02015b4:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02015b6:	b189                	j	ffffffffc02011f8 <slob_free>
        intr_disable();
ffffffffc02015b8:	e02a                	sd	a0,0(sp)
ffffffffc02015ba:	abeff0ef          	jal	ffffffffc0200878 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02015be:	0000c797          	auipc	a5,0xc
ffffffffc02015c2:	ed27b783          	ld	a5,-302(a5) # ffffffffc020d490 <bigblocks>
ffffffffc02015c6:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc02015c8:	4585                	li	a1,1
ffffffffc02015ca:	fbb5                	bnez	a5,ffffffffc020153e <kfree+0x20>
ffffffffc02015cc:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc02015ce:	aa4ff0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc02015d2:	6502                	ld	a0,0(sp)
ffffffffc02015d4:	bfe9                	j	ffffffffc02015ae <kfree+0x90>
ffffffffc02015d6:	e42a                	sd	a0,8(sp)
ffffffffc02015d8:	e03a                	sd	a4,0(sp)
ffffffffc02015da:	a98ff0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc02015de:	6522                	ld	a0,8(sp)
ffffffffc02015e0:	6702                	ld	a4,0(sp)
ffffffffc02015e2:	bfad                	j	ffffffffc020155c <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc02015e4:	1541                	addi	a0,a0,-16
ffffffffc02015e6:	4581                	li	a1,0
ffffffffc02015e8:	b901                	j	ffffffffc02011f8 <slob_free>
ffffffffc02015ea:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02015ec:	00003617          	auipc	a2,0x3
ffffffffc02015f0:	60c60613          	addi	a2,a2,1548 # ffffffffc0204bf8 <etext+0xcd2>
ffffffffc02015f4:	06900593          	li	a1,105
ffffffffc02015f8:	00003517          	auipc	a0,0x3
ffffffffc02015fc:	55850513          	addi	a0,a0,1368 # ffffffffc0204b50 <etext+0xc2a>
ffffffffc0201600:	bdbfe0ef          	jal	ffffffffc02001da <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201604:	86aa                	mv	a3,a0
ffffffffc0201606:	00003617          	auipc	a2,0x3
ffffffffc020160a:	5ca60613          	addi	a2,a2,1482 # ffffffffc0204bd0 <etext+0xcaa>
ffffffffc020160e:	07700593          	li	a1,119
ffffffffc0201612:	00003517          	auipc	a0,0x3
ffffffffc0201616:	53e50513          	addi	a0,a0,1342 # ffffffffc0204b50 <etext+0xc2a>
ffffffffc020161a:	bc1fe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc020161e <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020161e:	00008797          	auipc	a5,0x8
ffffffffc0201622:	e1278793          	addi	a5,a5,-494 # ffffffffc0209430 <free_area>
ffffffffc0201626:	e79c                	sd	a5,8(a5)
ffffffffc0201628:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020162a:	0007a823          	sw	zero,16(a5)
}
ffffffffc020162e:	8082                	ret

ffffffffc0201630 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201630:	00008517          	auipc	a0,0x8
ffffffffc0201634:	e1056503          	lwu	a0,-496(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc0201638:	8082                	ret

ffffffffc020163a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc020163a:	711d                	addi	sp,sp,-96
ffffffffc020163c:	e0ca                	sd	s2,64(sp)
    return listelm->next;
ffffffffc020163e:	00008917          	auipc	s2,0x8
ffffffffc0201642:	df290913          	addi	s2,s2,-526 # ffffffffc0209430 <free_area>
ffffffffc0201646:	00893783          	ld	a5,8(s2)
ffffffffc020164a:	ec86                	sd	ra,88(sp)
ffffffffc020164c:	e8a2                	sd	s0,80(sp)
ffffffffc020164e:	e4a6                	sd	s1,72(sp)
ffffffffc0201650:	fc4e                	sd	s3,56(sp)
ffffffffc0201652:	f852                	sd	s4,48(sp)
ffffffffc0201654:	f456                	sd	s5,40(sp)
ffffffffc0201656:	f05a                	sd	s6,32(sp)
ffffffffc0201658:	ec5e                	sd	s7,24(sp)
ffffffffc020165a:	e862                	sd	s8,16(sp)
ffffffffc020165c:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020165e:	2f278763          	beq	a5,s2,ffffffffc020194c <default_check+0x312>
    int count = 0, total = 0;
ffffffffc0201662:	4401                	li	s0,0
ffffffffc0201664:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201666:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020166a:	8b09                	andi	a4,a4,2
ffffffffc020166c:	2e070463          	beqz	a4,ffffffffc0201954 <default_check+0x31a>
        count ++, total += p->property;
ffffffffc0201670:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201674:	679c                	ld	a5,8(a5)
ffffffffc0201676:	2485                	addiw	s1,s1,1
ffffffffc0201678:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020167a:	ff2796e3          	bne	a5,s2,ffffffffc0201666 <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc020167e:	89a2                	mv	s3,s0
ffffffffc0201680:	31f000ef          	jal	ffffffffc020219e <nr_free_pages>
ffffffffc0201684:	73351863          	bne	a0,s3,ffffffffc0201db4 <default_check+0x77a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201688:	4505                	li	a0,1
ffffffffc020168a:	2a3000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc020168e:	8a2a                	mv	s4,a0
ffffffffc0201690:	46050263          	beqz	a0,ffffffffc0201af4 <default_check+0x4ba>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201694:	4505                	li	a0,1
ffffffffc0201696:	297000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc020169a:	89aa                	mv	s3,a0
ffffffffc020169c:	72050c63          	beqz	a0,ffffffffc0201dd4 <default_check+0x79a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02016a0:	4505                	li	a0,1
ffffffffc02016a2:	28b000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02016a6:	8aaa                	mv	s5,a0
ffffffffc02016a8:	4c050663          	beqz	a0,ffffffffc0201b74 <default_check+0x53a>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02016ac:	40aa07b3          	sub	a5,s4,a0
ffffffffc02016b0:	40a98733          	sub	a4,s3,a0
ffffffffc02016b4:	0017b793          	seqz	a5,a5
ffffffffc02016b8:	00173713          	seqz	a4,a4
ffffffffc02016bc:	8fd9                	or	a5,a5,a4
ffffffffc02016be:	30079b63          	bnez	a5,ffffffffc02019d4 <default_check+0x39a>
ffffffffc02016c2:	313a0963          	beq	s4,s3,ffffffffc02019d4 <default_check+0x39a>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02016c6:	000a2783          	lw	a5,0(s4)
ffffffffc02016ca:	2a079563          	bnez	a5,ffffffffc0201974 <default_check+0x33a>
ffffffffc02016ce:	0009a783          	lw	a5,0(s3)
ffffffffc02016d2:	2a079163          	bnez	a5,ffffffffc0201974 <default_check+0x33a>
ffffffffc02016d6:	411c                	lw	a5,0(a0)
ffffffffc02016d8:	28079e63          	bnez	a5,ffffffffc0201974 <default_check+0x33a>
    return page - pages + nbase;
ffffffffc02016dc:	0000c797          	auipc	a5,0xc
ffffffffc02016e0:	de47b783          	ld	a5,-540(a5) # ffffffffc020d4c0 <pages>
ffffffffc02016e4:	00004617          	auipc	a2,0x4
ffffffffc02016e8:	39463603          	ld	a2,916(a2) # ffffffffc0205a78 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02016ec:	0000c697          	auipc	a3,0xc
ffffffffc02016f0:	dcc6b683          	ld	a3,-564(a3) # ffffffffc020d4b8 <npage>
ffffffffc02016f4:	40fa0733          	sub	a4,s4,a5
ffffffffc02016f8:	8719                	srai	a4,a4,0x6
ffffffffc02016fa:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02016fc:	0732                	slli	a4,a4,0xc
ffffffffc02016fe:	06b2                	slli	a3,a3,0xc
ffffffffc0201700:	2ad77a63          	bgeu	a4,a3,ffffffffc02019b4 <default_check+0x37a>
    return page - pages + nbase;
ffffffffc0201704:	40f98733          	sub	a4,s3,a5
ffffffffc0201708:	8719                	srai	a4,a4,0x6
ffffffffc020170a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020170c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020170e:	4ed77363          	bgeu	a4,a3,ffffffffc0201bf4 <default_check+0x5ba>
    return page - pages + nbase;
ffffffffc0201712:	40f507b3          	sub	a5,a0,a5
ffffffffc0201716:	8799                	srai	a5,a5,0x6
ffffffffc0201718:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020171a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020171c:	32d7fc63          	bgeu	a5,a3,ffffffffc0201a54 <default_check+0x41a>
    assert(alloc_page() == NULL);
ffffffffc0201720:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201722:	00093c03          	ld	s8,0(s2)
ffffffffc0201726:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc020172a:	00008b17          	auipc	s6,0x8
ffffffffc020172e:	d16b2b03          	lw	s6,-746(s6) # ffffffffc0209440 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0201732:	01293023          	sd	s2,0(s2)
ffffffffc0201736:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc020173a:	00008797          	auipc	a5,0x8
ffffffffc020173e:	d007a323          	sw	zero,-762(a5) # ffffffffc0209440 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201742:	1eb000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201746:	2e051763          	bnez	a0,ffffffffc0201a34 <default_check+0x3fa>
    free_page(p0);
ffffffffc020174a:	8552                	mv	a0,s4
ffffffffc020174c:	4585                	li	a1,1
ffffffffc020174e:	219000ef          	jal	ffffffffc0202166 <free_pages>
    free_page(p1);
ffffffffc0201752:	854e                	mv	a0,s3
ffffffffc0201754:	4585                	li	a1,1
ffffffffc0201756:	211000ef          	jal	ffffffffc0202166 <free_pages>
    free_page(p2);
ffffffffc020175a:	8556                	mv	a0,s5
ffffffffc020175c:	4585                	li	a1,1
ffffffffc020175e:	209000ef          	jal	ffffffffc0202166 <free_pages>
    assert(nr_free == 3);
ffffffffc0201762:	00008717          	auipc	a4,0x8
ffffffffc0201766:	cde72703          	lw	a4,-802(a4) # ffffffffc0209440 <free_area+0x10>
ffffffffc020176a:	478d                	li	a5,3
ffffffffc020176c:	2af71463          	bne	a4,a5,ffffffffc0201a14 <default_check+0x3da>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201770:	4505                	li	a0,1
ffffffffc0201772:	1bb000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201776:	89aa                	mv	s3,a0
ffffffffc0201778:	26050e63          	beqz	a0,ffffffffc02019f4 <default_check+0x3ba>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020177c:	4505                	li	a0,1
ffffffffc020177e:	1af000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201782:	8aaa                	mv	s5,a0
ffffffffc0201784:	3c050863          	beqz	a0,ffffffffc0201b54 <default_check+0x51a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201788:	4505                	li	a0,1
ffffffffc020178a:	1a3000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc020178e:	8a2a                	mv	s4,a0
ffffffffc0201790:	3a050263          	beqz	a0,ffffffffc0201b34 <default_check+0x4fa>
    assert(alloc_page() == NULL);
ffffffffc0201794:	4505                	li	a0,1
ffffffffc0201796:	197000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc020179a:	36051d63          	bnez	a0,ffffffffc0201b14 <default_check+0x4da>
    free_page(p0);
ffffffffc020179e:	4585                	li	a1,1
ffffffffc02017a0:	854e                	mv	a0,s3
ffffffffc02017a2:	1c5000ef          	jal	ffffffffc0202166 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02017a6:	00893783          	ld	a5,8(s2)
ffffffffc02017aa:	1f278563          	beq	a5,s2,ffffffffc0201994 <default_check+0x35a>
    assert((p = alloc_page()) == p0);
ffffffffc02017ae:	4505                	li	a0,1
ffffffffc02017b0:	17d000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02017b4:	8caa                	mv	s9,a0
ffffffffc02017b6:	30a99f63          	bne	s3,a0,ffffffffc0201ad4 <default_check+0x49a>
    assert(alloc_page() == NULL);
ffffffffc02017ba:	4505                	li	a0,1
ffffffffc02017bc:	171000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02017c0:	2e051a63          	bnez	a0,ffffffffc0201ab4 <default_check+0x47a>
    assert(nr_free == 0);
ffffffffc02017c4:	00008797          	auipc	a5,0x8
ffffffffc02017c8:	c7c7a783          	lw	a5,-900(a5) # ffffffffc0209440 <free_area+0x10>
ffffffffc02017cc:	2c079463          	bnez	a5,ffffffffc0201a94 <default_check+0x45a>
    free_page(p);
ffffffffc02017d0:	8566                	mv	a0,s9
ffffffffc02017d2:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02017d4:	01893023          	sd	s8,0(s2)
ffffffffc02017d8:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc02017dc:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc02017e0:	187000ef          	jal	ffffffffc0202166 <free_pages>
    free_page(p1);
ffffffffc02017e4:	8556                	mv	a0,s5
ffffffffc02017e6:	4585                	li	a1,1
ffffffffc02017e8:	17f000ef          	jal	ffffffffc0202166 <free_pages>
    free_page(p2);
ffffffffc02017ec:	8552                	mv	a0,s4
ffffffffc02017ee:	4585                	li	a1,1
ffffffffc02017f0:	177000ef          	jal	ffffffffc0202166 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02017f4:	4515                	li	a0,5
ffffffffc02017f6:	137000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02017fa:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02017fc:	26050c63          	beqz	a0,ffffffffc0201a74 <default_check+0x43a>
ffffffffc0201800:	651c                	ld	a5,8(a0)
ffffffffc0201802:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201804:	8b85                	andi	a5,a5,1
ffffffffc0201806:	54079763          	bnez	a5,ffffffffc0201d54 <default_check+0x71a>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020180a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020180c:	00093b83          	ld	s7,0(s2)
ffffffffc0201810:	00893b03          	ld	s6,8(s2)
ffffffffc0201814:	01293023          	sd	s2,0(s2)
ffffffffc0201818:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc020181c:	111000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201820:	50051a63          	bnez	a0,ffffffffc0201d34 <default_check+0x6fa>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201824:	08098a13          	addi	s4,s3,128
ffffffffc0201828:	8552                	mv	a0,s4
ffffffffc020182a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020182c:	00008c17          	auipc	s8,0x8
ffffffffc0201830:	c14c2c03          	lw	s8,-1004(s8) # ffffffffc0209440 <free_area+0x10>
    nr_free = 0;
ffffffffc0201834:	00008797          	auipc	a5,0x8
ffffffffc0201838:	c007a623          	sw	zero,-1012(a5) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020183c:	12b000ef          	jal	ffffffffc0202166 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201840:	4511                	li	a0,4
ffffffffc0201842:	0eb000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201846:	4c051763          	bnez	a0,ffffffffc0201d14 <default_check+0x6da>
ffffffffc020184a:	0889b783          	ld	a5,136(s3)
ffffffffc020184e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201850:	8b85                	andi	a5,a5,1
ffffffffc0201852:	4a078163          	beqz	a5,ffffffffc0201cf4 <default_check+0x6ba>
ffffffffc0201856:	0909a503          	lw	a0,144(s3)
ffffffffc020185a:	478d                	li	a5,3
ffffffffc020185c:	48f51c63          	bne	a0,a5,ffffffffc0201cf4 <default_check+0x6ba>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201860:	0cd000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201864:	8aaa                	mv	s5,a0
ffffffffc0201866:	46050763          	beqz	a0,ffffffffc0201cd4 <default_check+0x69a>
    assert(alloc_page() == NULL);
ffffffffc020186a:	4505                	li	a0,1
ffffffffc020186c:	0c1000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc0201870:	44051263          	bnez	a0,ffffffffc0201cb4 <default_check+0x67a>
    assert(p0 + 2 == p1);
ffffffffc0201874:	435a1063          	bne	s4,s5,ffffffffc0201c94 <default_check+0x65a>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201878:	4585                	li	a1,1
ffffffffc020187a:	854e                	mv	a0,s3
ffffffffc020187c:	0eb000ef          	jal	ffffffffc0202166 <free_pages>
    free_pages(p1, 3);
ffffffffc0201880:	8552                	mv	a0,s4
ffffffffc0201882:	458d                	li	a1,3
ffffffffc0201884:	0e3000ef          	jal	ffffffffc0202166 <free_pages>
ffffffffc0201888:	0089b783          	ld	a5,8(s3)
ffffffffc020188c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020188e:	8b85                	andi	a5,a5,1
ffffffffc0201890:	3e078263          	beqz	a5,ffffffffc0201c74 <default_check+0x63a>
ffffffffc0201894:	0109aa83          	lw	s5,16(s3)
ffffffffc0201898:	4785                	li	a5,1
ffffffffc020189a:	3cfa9d63          	bne	s5,a5,ffffffffc0201c74 <default_check+0x63a>
ffffffffc020189e:	008a3783          	ld	a5,8(s4)
ffffffffc02018a2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02018a4:	8b85                	andi	a5,a5,1
ffffffffc02018a6:	3a078763          	beqz	a5,ffffffffc0201c54 <default_check+0x61a>
ffffffffc02018aa:	010a2703          	lw	a4,16(s4)
ffffffffc02018ae:	478d                	li	a5,3
ffffffffc02018b0:	3af71263          	bne	a4,a5,ffffffffc0201c54 <default_check+0x61a>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02018b4:	8556                	mv	a0,s5
ffffffffc02018b6:	077000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02018ba:	36a99d63          	bne	s3,a0,ffffffffc0201c34 <default_check+0x5fa>
    free_page(p0);
ffffffffc02018be:	85d6                	mv	a1,s5
ffffffffc02018c0:	0a7000ef          	jal	ffffffffc0202166 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02018c4:	4509                	li	a0,2
ffffffffc02018c6:	067000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02018ca:	34aa1563          	bne	s4,a0,ffffffffc0201c14 <default_check+0x5da>

    free_pages(p0, 2);
ffffffffc02018ce:	4589                	li	a1,2
ffffffffc02018d0:	097000ef          	jal	ffffffffc0202166 <free_pages>
    free_page(p2);
ffffffffc02018d4:	04098513          	addi	a0,s3,64
ffffffffc02018d8:	85d6                	mv	a1,s5
ffffffffc02018da:	08d000ef          	jal	ffffffffc0202166 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02018de:	4515                	li	a0,5
ffffffffc02018e0:	04d000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02018e4:	89aa                	mv	s3,a0
ffffffffc02018e6:	48050763          	beqz	a0,ffffffffc0201d74 <default_check+0x73a>
    assert(alloc_page() == NULL);
ffffffffc02018ea:	8556                	mv	a0,s5
ffffffffc02018ec:	041000ef          	jal	ffffffffc020212c <alloc_pages>
ffffffffc02018f0:	2e051263          	bnez	a0,ffffffffc0201bd4 <default_check+0x59a>

    assert(nr_free == 0);
ffffffffc02018f4:	00008797          	auipc	a5,0x8
ffffffffc02018f8:	b4c7a783          	lw	a5,-1204(a5) # ffffffffc0209440 <free_area+0x10>
ffffffffc02018fc:	2a079c63          	bnez	a5,ffffffffc0201bb4 <default_check+0x57a>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201900:	854e                	mv	a0,s3
ffffffffc0201902:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0201904:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0201908:	01793023          	sd	s7,0(s2)
ffffffffc020190c:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0201910:	057000ef          	jal	ffffffffc0202166 <free_pages>
    return listelm->next;
ffffffffc0201914:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201918:	01278963          	beq	a5,s2,ffffffffc020192a <default_check+0x2f0>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020191c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201920:	679c                	ld	a5,8(a5)
ffffffffc0201922:	34fd                	addiw	s1,s1,-1
ffffffffc0201924:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201926:	ff279be3          	bne	a5,s2,ffffffffc020191c <default_check+0x2e2>
    }
    assert(count == 0);
ffffffffc020192a:	26049563          	bnez	s1,ffffffffc0201b94 <default_check+0x55a>
    assert(total == 0);
ffffffffc020192e:	46041363          	bnez	s0,ffffffffc0201d94 <default_check+0x75a>
}
ffffffffc0201932:	60e6                	ld	ra,88(sp)
ffffffffc0201934:	6446                	ld	s0,80(sp)
ffffffffc0201936:	64a6                	ld	s1,72(sp)
ffffffffc0201938:	6906                	ld	s2,64(sp)
ffffffffc020193a:	79e2                	ld	s3,56(sp)
ffffffffc020193c:	7a42                	ld	s4,48(sp)
ffffffffc020193e:	7aa2                	ld	s5,40(sp)
ffffffffc0201940:	7b02                	ld	s6,32(sp)
ffffffffc0201942:	6be2                	ld	s7,24(sp)
ffffffffc0201944:	6c42                	ld	s8,16(sp)
ffffffffc0201946:	6ca2                	ld	s9,8(sp)
ffffffffc0201948:	6125                	addi	sp,sp,96
ffffffffc020194a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020194c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020194e:	4401                	li	s0,0
ffffffffc0201950:	4481                	li	s1,0
ffffffffc0201952:	b33d                	j	ffffffffc0201680 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0201954:	00003697          	auipc	a3,0x3
ffffffffc0201958:	2c468693          	addi	a3,a3,708 # ffffffffc0204c18 <etext+0xcf2>
ffffffffc020195c:	00003617          	auipc	a2,0x3
ffffffffc0201960:	fac60613          	addi	a2,a2,-84 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201964:	0f000593          	li	a1,240
ffffffffc0201968:	00003517          	auipc	a0,0x3
ffffffffc020196c:	2c050513          	addi	a0,a0,704 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201970:	86bfe0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201974:	00003697          	auipc	a3,0x3
ffffffffc0201978:	37468693          	addi	a3,a3,884 # ffffffffc0204ce8 <etext+0xdc2>
ffffffffc020197c:	00003617          	auipc	a2,0x3
ffffffffc0201980:	f8c60613          	addi	a2,a2,-116 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201984:	0be00593          	li	a1,190
ffffffffc0201988:	00003517          	auipc	a0,0x3
ffffffffc020198c:	2a050513          	addi	a0,a0,672 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201990:	84bfe0ef          	jal	ffffffffc02001da <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201994:	00003697          	auipc	a3,0x3
ffffffffc0201998:	41c68693          	addi	a3,a3,1052 # ffffffffc0204db0 <etext+0xe8a>
ffffffffc020199c:	00003617          	auipc	a2,0x3
ffffffffc02019a0:	f6c60613          	addi	a2,a2,-148 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02019a4:	0d900593          	li	a1,217
ffffffffc02019a8:	00003517          	auipc	a0,0x3
ffffffffc02019ac:	28050513          	addi	a0,a0,640 # ffffffffc0204c28 <etext+0xd02>
ffffffffc02019b0:	82bfe0ef          	jal	ffffffffc02001da <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02019b4:	00003697          	auipc	a3,0x3
ffffffffc02019b8:	37468693          	addi	a3,a3,884 # ffffffffc0204d28 <etext+0xe02>
ffffffffc02019bc:	00003617          	auipc	a2,0x3
ffffffffc02019c0:	f4c60613          	addi	a2,a2,-180 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02019c4:	0c000593          	li	a1,192
ffffffffc02019c8:	00003517          	auipc	a0,0x3
ffffffffc02019cc:	26050513          	addi	a0,a0,608 # ffffffffc0204c28 <etext+0xd02>
ffffffffc02019d0:	80bfe0ef          	jal	ffffffffc02001da <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02019d4:	00003697          	auipc	a3,0x3
ffffffffc02019d8:	2ec68693          	addi	a3,a3,748 # ffffffffc0204cc0 <etext+0xd9a>
ffffffffc02019dc:	00003617          	auipc	a2,0x3
ffffffffc02019e0:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02019e4:	0bd00593          	li	a1,189
ffffffffc02019e8:	00003517          	auipc	a0,0x3
ffffffffc02019ec:	24050513          	addi	a0,a0,576 # ffffffffc0204c28 <etext+0xd02>
ffffffffc02019f0:	feafe0ef          	jal	ffffffffc02001da <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02019f4:	00003697          	auipc	a3,0x3
ffffffffc02019f8:	26c68693          	addi	a3,a3,620 # ffffffffc0204c60 <etext+0xd3a>
ffffffffc02019fc:	00003617          	auipc	a2,0x3
ffffffffc0201a00:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201a04:	0d200593          	li	a1,210
ffffffffc0201a08:	00003517          	auipc	a0,0x3
ffffffffc0201a0c:	22050513          	addi	a0,a0,544 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201a10:	fcafe0ef          	jal	ffffffffc02001da <__panic>
    assert(nr_free == 3);
ffffffffc0201a14:	00003697          	auipc	a3,0x3
ffffffffc0201a18:	38c68693          	addi	a3,a3,908 # ffffffffc0204da0 <etext+0xe7a>
ffffffffc0201a1c:	00003617          	auipc	a2,0x3
ffffffffc0201a20:	eec60613          	addi	a2,a2,-276 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201a24:	0d000593          	li	a1,208
ffffffffc0201a28:	00003517          	auipc	a0,0x3
ffffffffc0201a2c:	20050513          	addi	a0,a0,512 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201a30:	faafe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201a34:	00003697          	auipc	a3,0x3
ffffffffc0201a38:	35468693          	addi	a3,a3,852 # ffffffffc0204d88 <etext+0xe62>
ffffffffc0201a3c:	00003617          	auipc	a2,0x3
ffffffffc0201a40:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201a44:	0cb00593          	li	a1,203
ffffffffc0201a48:	00003517          	auipc	a0,0x3
ffffffffc0201a4c:	1e050513          	addi	a0,a0,480 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201a50:	f8afe0ef          	jal	ffffffffc02001da <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201a54:	00003697          	auipc	a3,0x3
ffffffffc0201a58:	31468693          	addi	a3,a3,788 # ffffffffc0204d68 <etext+0xe42>
ffffffffc0201a5c:	00003617          	auipc	a2,0x3
ffffffffc0201a60:	eac60613          	addi	a2,a2,-340 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201a64:	0c200593          	li	a1,194
ffffffffc0201a68:	00003517          	auipc	a0,0x3
ffffffffc0201a6c:	1c050513          	addi	a0,a0,448 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201a70:	f6afe0ef          	jal	ffffffffc02001da <__panic>
    assert(p0 != NULL);
ffffffffc0201a74:	00003697          	auipc	a3,0x3
ffffffffc0201a78:	38468693          	addi	a3,a3,900 # ffffffffc0204df8 <etext+0xed2>
ffffffffc0201a7c:	00003617          	auipc	a2,0x3
ffffffffc0201a80:	e8c60613          	addi	a2,a2,-372 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201a84:	0f800593          	li	a1,248
ffffffffc0201a88:	00003517          	auipc	a0,0x3
ffffffffc0201a8c:	1a050513          	addi	a0,a0,416 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201a90:	f4afe0ef          	jal	ffffffffc02001da <__panic>
    assert(nr_free == 0);
ffffffffc0201a94:	00003697          	auipc	a3,0x3
ffffffffc0201a98:	35468693          	addi	a3,a3,852 # ffffffffc0204de8 <etext+0xec2>
ffffffffc0201a9c:	00003617          	auipc	a2,0x3
ffffffffc0201aa0:	e6c60613          	addi	a2,a2,-404 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201aa4:	0df00593          	li	a1,223
ffffffffc0201aa8:	00003517          	auipc	a0,0x3
ffffffffc0201aac:	18050513          	addi	a0,a0,384 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201ab0:	f2afe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201ab4:	00003697          	auipc	a3,0x3
ffffffffc0201ab8:	2d468693          	addi	a3,a3,724 # ffffffffc0204d88 <etext+0xe62>
ffffffffc0201abc:	00003617          	auipc	a2,0x3
ffffffffc0201ac0:	e4c60613          	addi	a2,a2,-436 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201ac4:	0dd00593          	li	a1,221
ffffffffc0201ac8:	00003517          	auipc	a0,0x3
ffffffffc0201acc:	16050513          	addi	a0,a0,352 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201ad0:	f0afe0ef          	jal	ffffffffc02001da <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201ad4:	00003697          	auipc	a3,0x3
ffffffffc0201ad8:	2f468693          	addi	a3,a3,756 # ffffffffc0204dc8 <etext+0xea2>
ffffffffc0201adc:	00003617          	auipc	a2,0x3
ffffffffc0201ae0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201ae4:	0dc00593          	li	a1,220
ffffffffc0201ae8:	00003517          	auipc	a0,0x3
ffffffffc0201aec:	14050513          	addi	a0,a0,320 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201af0:	eeafe0ef          	jal	ffffffffc02001da <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201af4:	00003697          	auipc	a3,0x3
ffffffffc0201af8:	16c68693          	addi	a3,a3,364 # ffffffffc0204c60 <etext+0xd3a>
ffffffffc0201afc:	00003617          	auipc	a2,0x3
ffffffffc0201b00:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201b04:	0b900593          	li	a1,185
ffffffffc0201b08:	00003517          	auipc	a0,0x3
ffffffffc0201b0c:	12050513          	addi	a0,a0,288 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201b10:	ecafe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201b14:	00003697          	auipc	a3,0x3
ffffffffc0201b18:	27468693          	addi	a3,a3,628 # ffffffffc0204d88 <etext+0xe62>
ffffffffc0201b1c:	00003617          	auipc	a2,0x3
ffffffffc0201b20:	dec60613          	addi	a2,a2,-532 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201b24:	0d600593          	li	a1,214
ffffffffc0201b28:	00003517          	auipc	a0,0x3
ffffffffc0201b2c:	10050513          	addi	a0,a0,256 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201b30:	eaafe0ef          	jal	ffffffffc02001da <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b34:	00003697          	auipc	a3,0x3
ffffffffc0201b38:	16c68693          	addi	a3,a3,364 # ffffffffc0204ca0 <etext+0xd7a>
ffffffffc0201b3c:	00003617          	auipc	a2,0x3
ffffffffc0201b40:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201b44:	0d400593          	li	a1,212
ffffffffc0201b48:	00003517          	auipc	a0,0x3
ffffffffc0201b4c:	0e050513          	addi	a0,a0,224 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201b50:	e8afe0ef          	jal	ffffffffc02001da <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201b54:	00003697          	auipc	a3,0x3
ffffffffc0201b58:	12c68693          	addi	a3,a3,300 # ffffffffc0204c80 <etext+0xd5a>
ffffffffc0201b5c:	00003617          	auipc	a2,0x3
ffffffffc0201b60:	dac60613          	addi	a2,a2,-596 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201b64:	0d300593          	li	a1,211
ffffffffc0201b68:	00003517          	auipc	a0,0x3
ffffffffc0201b6c:	0c050513          	addi	a0,a0,192 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201b70:	e6afe0ef          	jal	ffffffffc02001da <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b74:	00003697          	auipc	a3,0x3
ffffffffc0201b78:	12c68693          	addi	a3,a3,300 # ffffffffc0204ca0 <etext+0xd7a>
ffffffffc0201b7c:	00003617          	auipc	a2,0x3
ffffffffc0201b80:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201b84:	0bb00593          	li	a1,187
ffffffffc0201b88:	00003517          	auipc	a0,0x3
ffffffffc0201b8c:	0a050513          	addi	a0,a0,160 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201b90:	e4afe0ef          	jal	ffffffffc02001da <__panic>
    assert(count == 0);
ffffffffc0201b94:	00003697          	auipc	a3,0x3
ffffffffc0201b98:	3b468693          	addi	a3,a3,948 # ffffffffc0204f48 <etext+0x1022>
ffffffffc0201b9c:	00003617          	auipc	a2,0x3
ffffffffc0201ba0:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201ba4:	12500593          	li	a1,293
ffffffffc0201ba8:	00003517          	auipc	a0,0x3
ffffffffc0201bac:	08050513          	addi	a0,a0,128 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201bb0:	e2afe0ef          	jal	ffffffffc02001da <__panic>
    assert(nr_free == 0);
ffffffffc0201bb4:	00003697          	auipc	a3,0x3
ffffffffc0201bb8:	23468693          	addi	a3,a3,564 # ffffffffc0204de8 <etext+0xec2>
ffffffffc0201bbc:	00003617          	auipc	a2,0x3
ffffffffc0201bc0:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201bc4:	11a00593          	li	a1,282
ffffffffc0201bc8:	00003517          	auipc	a0,0x3
ffffffffc0201bcc:	06050513          	addi	a0,a0,96 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201bd0:	e0afe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201bd4:	00003697          	auipc	a3,0x3
ffffffffc0201bd8:	1b468693          	addi	a3,a3,436 # ffffffffc0204d88 <etext+0xe62>
ffffffffc0201bdc:	00003617          	auipc	a2,0x3
ffffffffc0201be0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201be4:	11800593          	li	a1,280
ffffffffc0201be8:	00003517          	auipc	a0,0x3
ffffffffc0201bec:	04050513          	addi	a0,a0,64 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201bf0:	deafe0ef          	jal	ffffffffc02001da <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201bf4:	00003697          	auipc	a3,0x3
ffffffffc0201bf8:	15468693          	addi	a3,a3,340 # ffffffffc0204d48 <etext+0xe22>
ffffffffc0201bfc:	00003617          	auipc	a2,0x3
ffffffffc0201c00:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201c04:	0c100593          	li	a1,193
ffffffffc0201c08:	00003517          	auipc	a0,0x3
ffffffffc0201c0c:	02050513          	addi	a0,a0,32 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201c10:	dcafe0ef          	jal	ffffffffc02001da <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201c14:	00003697          	auipc	a3,0x3
ffffffffc0201c18:	2f468693          	addi	a3,a3,756 # ffffffffc0204f08 <etext+0xfe2>
ffffffffc0201c1c:	00003617          	auipc	a2,0x3
ffffffffc0201c20:	cec60613          	addi	a2,a2,-788 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201c24:	11200593          	li	a1,274
ffffffffc0201c28:	00003517          	auipc	a0,0x3
ffffffffc0201c2c:	00050513          	mv	a0,a0
ffffffffc0201c30:	daafe0ef          	jal	ffffffffc02001da <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201c34:	00003697          	auipc	a3,0x3
ffffffffc0201c38:	2b468693          	addi	a3,a3,692 # ffffffffc0204ee8 <etext+0xfc2>
ffffffffc0201c3c:	00003617          	auipc	a2,0x3
ffffffffc0201c40:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201c44:	11000593          	li	a1,272
ffffffffc0201c48:	00003517          	auipc	a0,0x3
ffffffffc0201c4c:	fe050513          	addi	a0,a0,-32 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201c50:	d8afe0ef          	jal	ffffffffc02001da <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201c54:	00003697          	auipc	a3,0x3
ffffffffc0201c58:	26c68693          	addi	a3,a3,620 # ffffffffc0204ec0 <etext+0xf9a>
ffffffffc0201c5c:	00003617          	auipc	a2,0x3
ffffffffc0201c60:	cac60613          	addi	a2,a2,-852 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201c64:	10e00593          	li	a1,270
ffffffffc0201c68:	00003517          	auipc	a0,0x3
ffffffffc0201c6c:	fc050513          	addi	a0,a0,-64 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201c70:	d6afe0ef          	jal	ffffffffc02001da <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201c74:	00003697          	auipc	a3,0x3
ffffffffc0201c78:	22468693          	addi	a3,a3,548 # ffffffffc0204e98 <etext+0xf72>
ffffffffc0201c7c:	00003617          	auipc	a2,0x3
ffffffffc0201c80:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201c84:	10d00593          	li	a1,269
ffffffffc0201c88:	00003517          	auipc	a0,0x3
ffffffffc0201c8c:	fa050513          	addi	a0,a0,-96 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201c90:	d4afe0ef          	jal	ffffffffc02001da <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201c94:	00003697          	auipc	a3,0x3
ffffffffc0201c98:	1f468693          	addi	a3,a3,500 # ffffffffc0204e88 <etext+0xf62>
ffffffffc0201c9c:	00003617          	auipc	a2,0x3
ffffffffc0201ca0:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201ca4:	10800593          	li	a1,264
ffffffffc0201ca8:	00003517          	auipc	a0,0x3
ffffffffc0201cac:	f8050513          	addi	a0,a0,-128 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201cb0:	d2afe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201cb4:	00003697          	auipc	a3,0x3
ffffffffc0201cb8:	0d468693          	addi	a3,a3,212 # ffffffffc0204d88 <etext+0xe62>
ffffffffc0201cbc:	00003617          	auipc	a2,0x3
ffffffffc0201cc0:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201cc4:	10700593          	li	a1,263
ffffffffc0201cc8:	00003517          	auipc	a0,0x3
ffffffffc0201ccc:	f6050513          	addi	a0,a0,-160 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201cd0:	d0afe0ef          	jal	ffffffffc02001da <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201cd4:	00003697          	auipc	a3,0x3
ffffffffc0201cd8:	19468693          	addi	a3,a3,404 # ffffffffc0204e68 <etext+0xf42>
ffffffffc0201cdc:	00003617          	auipc	a2,0x3
ffffffffc0201ce0:	c2c60613          	addi	a2,a2,-980 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201ce4:	10600593          	li	a1,262
ffffffffc0201ce8:	00003517          	auipc	a0,0x3
ffffffffc0201cec:	f4050513          	addi	a0,a0,-192 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201cf0:	ceafe0ef          	jal	ffffffffc02001da <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201cf4:	00003697          	auipc	a3,0x3
ffffffffc0201cf8:	14468693          	addi	a3,a3,324 # ffffffffc0204e38 <etext+0xf12>
ffffffffc0201cfc:	00003617          	auipc	a2,0x3
ffffffffc0201d00:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201d04:	10500593          	li	a1,261
ffffffffc0201d08:	00003517          	auipc	a0,0x3
ffffffffc0201d0c:	f2050513          	addi	a0,a0,-224 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201d10:	ccafe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d14:	00003697          	auipc	a3,0x3
ffffffffc0201d18:	10c68693          	addi	a3,a3,268 # ffffffffc0204e20 <etext+0xefa>
ffffffffc0201d1c:	00003617          	auipc	a2,0x3
ffffffffc0201d20:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201d24:	10400593          	li	a1,260
ffffffffc0201d28:	00003517          	auipc	a0,0x3
ffffffffc0201d2c:	f0050513          	addi	a0,a0,-256 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201d30:	caafe0ef          	jal	ffffffffc02001da <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201d34:	00003697          	auipc	a3,0x3
ffffffffc0201d38:	05468693          	addi	a3,a3,84 # ffffffffc0204d88 <etext+0xe62>
ffffffffc0201d3c:	00003617          	auipc	a2,0x3
ffffffffc0201d40:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201d44:	0fe00593          	li	a1,254
ffffffffc0201d48:	00003517          	auipc	a0,0x3
ffffffffc0201d4c:	ee050513          	addi	a0,a0,-288 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201d50:	c8afe0ef          	jal	ffffffffc02001da <__panic>
    assert(!PageProperty(p0));
ffffffffc0201d54:	00003697          	auipc	a3,0x3
ffffffffc0201d58:	0b468693          	addi	a3,a3,180 # ffffffffc0204e08 <etext+0xee2>
ffffffffc0201d5c:	00003617          	auipc	a2,0x3
ffffffffc0201d60:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201d64:	0f900593          	li	a1,249
ffffffffc0201d68:	00003517          	auipc	a0,0x3
ffffffffc0201d6c:	ec050513          	addi	a0,a0,-320 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201d70:	c6afe0ef          	jal	ffffffffc02001da <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201d74:	00003697          	auipc	a3,0x3
ffffffffc0201d78:	1b468693          	addi	a3,a3,436 # ffffffffc0204f28 <etext+0x1002>
ffffffffc0201d7c:	00003617          	auipc	a2,0x3
ffffffffc0201d80:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201d84:	11700593          	li	a1,279
ffffffffc0201d88:	00003517          	auipc	a0,0x3
ffffffffc0201d8c:	ea050513          	addi	a0,a0,-352 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201d90:	c4afe0ef          	jal	ffffffffc02001da <__panic>
    assert(total == 0);
ffffffffc0201d94:	00003697          	auipc	a3,0x3
ffffffffc0201d98:	1c468693          	addi	a3,a3,452 # ffffffffc0204f58 <etext+0x1032>
ffffffffc0201d9c:	00003617          	auipc	a2,0x3
ffffffffc0201da0:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201da4:	12600593          	li	a1,294
ffffffffc0201da8:	00003517          	auipc	a0,0x3
ffffffffc0201dac:	e8050513          	addi	a0,a0,-384 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201db0:	c2afe0ef          	jal	ffffffffc02001da <__panic>
    assert(total == nr_free_pages());
ffffffffc0201db4:	00003697          	auipc	a3,0x3
ffffffffc0201db8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0204c40 <etext+0xd1a>
ffffffffc0201dbc:	00003617          	auipc	a2,0x3
ffffffffc0201dc0:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201dc4:	0f300593          	li	a1,243
ffffffffc0201dc8:	00003517          	auipc	a0,0x3
ffffffffc0201dcc:	e6050513          	addi	a0,a0,-416 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201dd0:	c0afe0ef          	jal	ffffffffc02001da <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201dd4:	00003697          	auipc	a3,0x3
ffffffffc0201dd8:	eac68693          	addi	a3,a3,-340 # ffffffffc0204c80 <etext+0xd5a>
ffffffffc0201ddc:	00003617          	auipc	a2,0x3
ffffffffc0201de0:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201de4:	0ba00593          	li	a1,186
ffffffffc0201de8:	00003517          	auipc	a0,0x3
ffffffffc0201dec:	e4050513          	addi	a0,a0,-448 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201df0:	beafe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0201df4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201df4:	1141                	addi	sp,sp,-16
ffffffffc0201df6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201df8:	14058663          	beqz	a1,ffffffffc0201f44 <default_free_pages+0x150>
    for (; p != base + n; p ++) {
ffffffffc0201dfc:	00659713          	slli	a4,a1,0x6
ffffffffc0201e00:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201e04:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201e06:	c30d                	beqz	a4,ffffffffc0201e28 <default_free_pages+0x34>
ffffffffc0201e08:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201e0a:	8b05                	andi	a4,a4,1
ffffffffc0201e0c:	10071c63          	bnez	a4,ffffffffc0201f24 <default_free_pages+0x130>
ffffffffc0201e10:	6798                	ld	a4,8(a5)
ffffffffc0201e12:	8b09                	andi	a4,a4,2
ffffffffc0201e14:	10071863          	bnez	a4,ffffffffc0201f24 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc0201e18:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201e1c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201e20:	04078793          	addi	a5,a5,64
ffffffffc0201e24:	fed792e3          	bne	a5,a3,ffffffffc0201e08 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201e28:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201e2a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201e2e:	4789                	li	a5,2
ffffffffc0201e30:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201e34:	00007717          	auipc	a4,0x7
ffffffffc0201e38:	60c72703          	lw	a4,1548(a4) # ffffffffc0209440 <free_area+0x10>
ffffffffc0201e3c:	00007697          	auipc	a3,0x7
ffffffffc0201e40:	5f468693          	addi	a3,a3,1524 # ffffffffc0209430 <free_area>
    return list->next == list;
ffffffffc0201e44:	669c                	ld	a5,8(a3)
ffffffffc0201e46:	9f2d                	addw	a4,a4,a1
ffffffffc0201e48:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201e4a:	0ad78163          	beq	a5,a3,ffffffffc0201eec <default_free_pages+0xf8>
            struct Page* page = le2page(le, page_link);
ffffffffc0201e4e:	fe878713          	addi	a4,a5,-24
ffffffffc0201e52:	4581                	li	a1,0
ffffffffc0201e54:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201e58:	00e56a63          	bltu	a0,a4,ffffffffc0201e6c <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201e5c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201e5e:	04d70c63          	beq	a4,a3,ffffffffc0201eb6 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc0201e62:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201e64:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201e68:	fee57ae3          	bgeu	a0,a4,ffffffffc0201e5c <default_free_pages+0x68>
ffffffffc0201e6c:	c199                	beqz	a1,ffffffffc0201e72 <default_free_pages+0x7e>
ffffffffc0201e6e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201e72:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201e74:	e390                	sd	a2,0(a5)
ffffffffc0201e76:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201e78:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201e7a:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201e7c:	00d70d63          	beq	a4,a3,ffffffffc0201e96 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201e80:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201e84:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201e88:	02059813          	slli	a6,a1,0x20
ffffffffc0201e8c:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201e90:	97b2                	add	a5,a5,a2
ffffffffc0201e92:	02f50c63          	beq	a0,a5,ffffffffc0201eca <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201e96:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201e98:	00d78c63          	beq	a5,a3,ffffffffc0201eb0 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201e9c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201e9e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201ea2:	02061593          	slli	a1,a2,0x20
ffffffffc0201ea6:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201eaa:	972a                	add	a4,a4,a0
ffffffffc0201eac:	04e68c63          	beq	a3,a4,ffffffffc0201f04 <default_free_pages+0x110>
}
ffffffffc0201eb0:	60a2                	ld	ra,8(sp)
ffffffffc0201eb2:	0141                	addi	sp,sp,16
ffffffffc0201eb4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201eb6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201eb8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201eba:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201ebc:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201ebe:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201ec0:	02d70f63          	beq	a4,a3,ffffffffc0201efe <default_free_pages+0x10a>
ffffffffc0201ec4:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201ec6:	87ba                	mv	a5,a4
ffffffffc0201ec8:	bf71                	j	ffffffffc0201e64 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201eca:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201ecc:	5875                	li	a6,-3
ffffffffc0201ece:	9fad                	addw	a5,a5,a1
ffffffffc0201ed0:	fef72c23          	sw	a5,-8(a4)
ffffffffc0201ed4:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ed8:	01853803          	ld	a6,24(a0)
ffffffffc0201edc:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201ede:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201ee0:	00b83423          	sd	a1,8(a6) # ff0008 <kern_entry-0xffffffffbf20fff8>
    return listelm->next;
ffffffffc0201ee4:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201ee6:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201eea:	b77d                	j	ffffffffc0201e98 <default_free_pages+0xa4>
}
ffffffffc0201eec:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201eee:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201ef2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201ef4:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201ef6:	e398                	sd	a4,0(a5)
ffffffffc0201ef8:	e798                	sd	a4,8(a5)
}
ffffffffc0201efa:	0141                	addi	sp,sp,16
ffffffffc0201efc:	8082                	ret
ffffffffc0201efe:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201f00:	873e                	mv	a4,a5
ffffffffc0201f02:	bfad                	j	ffffffffc0201e7c <default_free_pages+0x88>
            base->property += p->property;
ffffffffc0201f04:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f08:	56f5                	li	a3,-3
ffffffffc0201f0a:	9f31                	addw	a4,a4,a2
ffffffffc0201f0c:	c918                	sw	a4,16(a0)
ffffffffc0201f0e:	ff078713          	addi	a4,a5,-16
ffffffffc0201f12:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201f16:	6398                	ld	a4,0(a5)
ffffffffc0201f18:	679c                	ld	a5,8(a5)
}
ffffffffc0201f1a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201f1c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201f1e:	e398                	sd	a4,0(a5)
ffffffffc0201f20:	0141                	addi	sp,sp,16
ffffffffc0201f22:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201f24:	00003697          	auipc	a3,0x3
ffffffffc0201f28:	04c68693          	addi	a3,a3,76 # ffffffffc0204f70 <etext+0x104a>
ffffffffc0201f2c:	00003617          	auipc	a2,0x3
ffffffffc0201f30:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201f34:	08300593          	li	a1,131
ffffffffc0201f38:	00003517          	auipc	a0,0x3
ffffffffc0201f3c:	cf050513          	addi	a0,a0,-784 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201f40:	a9afe0ef          	jal	ffffffffc02001da <__panic>
    assert(n > 0);
ffffffffc0201f44:	00003697          	auipc	a3,0x3
ffffffffc0201f48:	02468693          	addi	a3,a3,36 # ffffffffc0204f68 <etext+0x1042>
ffffffffc0201f4c:	00003617          	auipc	a2,0x3
ffffffffc0201f50:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0201f54:	08000593          	li	a1,128
ffffffffc0201f58:	00003517          	auipc	a0,0x3
ffffffffc0201f5c:	cd050513          	addi	a0,a0,-816 # ffffffffc0204c28 <etext+0xd02>
ffffffffc0201f60:	a7afe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0201f64 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201f64:	c951                	beqz	a0,ffffffffc0201ff8 <default_alloc_pages+0x94>
    if (n > nr_free) {
ffffffffc0201f66:	00007597          	auipc	a1,0x7
ffffffffc0201f6a:	4da5a583          	lw	a1,1242(a1) # ffffffffc0209440 <free_area+0x10>
ffffffffc0201f6e:	86aa                	mv	a3,a0
ffffffffc0201f70:	02059793          	slli	a5,a1,0x20
ffffffffc0201f74:	9381                	srli	a5,a5,0x20
ffffffffc0201f76:	00a7ef63          	bltu	a5,a0,ffffffffc0201f94 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0201f7a:	00007617          	auipc	a2,0x7
ffffffffc0201f7e:	4b660613          	addi	a2,a2,1206 # ffffffffc0209430 <free_area>
ffffffffc0201f82:	87b2                	mv	a5,a2
ffffffffc0201f84:	a029                	j	ffffffffc0201f8e <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc0201f86:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201f8a:	00d77763          	bgeu	a4,a3,ffffffffc0201f98 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc0201f8e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f90:	fec79be3          	bne	a5,a2,ffffffffc0201f86 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201f94:	4501                	li	a0,0
}
ffffffffc0201f96:	8082                	ret
        if (page->property > n) {
ffffffffc0201f98:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc0201f9c:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201fa0:	6798                	ld	a4,8(a5)
ffffffffc0201fa2:	02089313          	slli	t1,a7,0x20
ffffffffc0201fa6:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0201faa:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201fae:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0201fb2:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc0201fb6:	0266fa63          	bgeu	a3,t1,ffffffffc0201fea <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0201fba:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc0201fbe:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc0201fc2:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201fc4:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201fc8:	00870313          	addi	t1,a4,8
ffffffffc0201fcc:	4889                	li	a7,2
ffffffffc0201fce:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201fd2:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0201fd6:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc0201fda:	0068b023          	sd	t1,0(a7)
ffffffffc0201fde:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc0201fe2:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201fe6:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0201fea:	9d95                	subw	a1,a1,a3
ffffffffc0201fec:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201fee:	5775                	li	a4,-3
ffffffffc0201ff0:	17c1                	addi	a5,a5,-16
ffffffffc0201ff2:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201ff6:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201ff8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201ffa:	00003697          	auipc	a3,0x3
ffffffffc0201ffe:	f6e68693          	addi	a3,a3,-146 # ffffffffc0204f68 <etext+0x1042>
ffffffffc0202002:	00003617          	auipc	a2,0x3
ffffffffc0202006:	90660613          	addi	a2,a2,-1786 # ffffffffc0204908 <etext+0x9e2>
ffffffffc020200a:	06200593          	li	a1,98
ffffffffc020200e:	00003517          	auipc	a0,0x3
ffffffffc0202012:	c1a50513          	addi	a0,a0,-998 # ffffffffc0204c28 <etext+0xd02>
default_alloc_pages(size_t n) {
ffffffffc0202016:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202018:	9c2fe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc020201c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020201c:	1141                	addi	sp,sp,-16
ffffffffc020201e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202020:	c9e1                	beqz	a1,ffffffffc02020f0 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202022:	00659713          	slli	a4,a1,0x6
ffffffffc0202026:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020202a:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020202c:	cf11                	beqz	a4,ffffffffc0202048 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020202e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202030:	8b05                	andi	a4,a4,1
ffffffffc0202032:	cf59                	beqz	a4,ffffffffc02020d0 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202034:	0007a823          	sw	zero,16(a5)
ffffffffc0202038:	0007b423          	sd	zero,8(a5)
ffffffffc020203c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202040:	04078793          	addi	a5,a5,64
ffffffffc0202044:	fed795e3          	bne	a5,a3,ffffffffc020202e <default_init_memmap+0x12>
    base->property = n;
ffffffffc0202048:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020204a:	4789                	li	a5,2
ffffffffc020204c:	00850713          	addi	a4,a0,8
ffffffffc0202050:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202054:	00007717          	auipc	a4,0x7
ffffffffc0202058:	3ec72703          	lw	a4,1004(a4) # ffffffffc0209440 <free_area+0x10>
ffffffffc020205c:	00007697          	auipc	a3,0x7
ffffffffc0202060:	3d468693          	addi	a3,a3,980 # ffffffffc0209430 <free_area>
    return list->next == list;
ffffffffc0202064:	669c                	ld	a5,8(a3)
ffffffffc0202066:	9f2d                	addw	a4,a4,a1
ffffffffc0202068:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020206a:	04d78663          	beq	a5,a3,ffffffffc02020b6 <default_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc020206e:	fe878713          	addi	a4,a5,-24
ffffffffc0202072:	4581                	li	a1,0
ffffffffc0202074:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0202078:	00e56a63          	bltu	a0,a4,ffffffffc020208c <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020207c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020207e:	02d70263          	beq	a4,a3,ffffffffc02020a2 <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc0202082:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202084:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202088:	fee57ae3          	bgeu	a0,a4,ffffffffc020207c <default_init_memmap+0x60>
ffffffffc020208c:	c199                	beqz	a1,ffffffffc0202092 <default_init_memmap+0x76>
ffffffffc020208e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202092:	6398                	ld	a4,0(a5)
}
ffffffffc0202094:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202096:	e390                	sd	a2,0(a5)
ffffffffc0202098:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc020209a:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc020209c:	f11c                	sd	a5,32(a0)
ffffffffc020209e:	0141                	addi	sp,sp,16
ffffffffc02020a0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02020a2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02020a4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02020a6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02020a8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02020aa:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02020ac:	00d70e63          	beq	a4,a3,ffffffffc02020c8 <default_init_memmap+0xac>
ffffffffc02020b0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02020b2:	87ba                	mv	a5,a4
ffffffffc02020b4:	bfc1                	j	ffffffffc0202084 <default_init_memmap+0x68>
}
ffffffffc02020b6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02020b8:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc02020bc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02020be:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc02020c0:	e398                	sd	a4,0(a5)
ffffffffc02020c2:	e798                	sd	a4,8(a5)
}
ffffffffc02020c4:	0141                	addi	sp,sp,16
ffffffffc02020c6:	8082                	ret
ffffffffc02020c8:	60a2                	ld	ra,8(sp)
ffffffffc02020ca:	e290                	sd	a2,0(a3)
ffffffffc02020cc:	0141                	addi	sp,sp,16
ffffffffc02020ce:	8082                	ret
        assert(PageReserved(p));
ffffffffc02020d0:	00003697          	auipc	a3,0x3
ffffffffc02020d4:	ec868693          	addi	a3,a3,-312 # ffffffffc0204f98 <etext+0x1072>
ffffffffc02020d8:	00003617          	auipc	a2,0x3
ffffffffc02020dc:	83060613          	addi	a2,a2,-2000 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02020e0:	04900593          	li	a1,73
ffffffffc02020e4:	00003517          	auipc	a0,0x3
ffffffffc02020e8:	b4450513          	addi	a0,a0,-1212 # ffffffffc0204c28 <etext+0xd02>
ffffffffc02020ec:	8eefe0ef          	jal	ffffffffc02001da <__panic>
    assert(n > 0);
ffffffffc02020f0:	00003697          	auipc	a3,0x3
ffffffffc02020f4:	e7868693          	addi	a3,a3,-392 # ffffffffc0204f68 <etext+0x1042>
ffffffffc02020f8:	00003617          	auipc	a2,0x3
ffffffffc02020fc:	81060613          	addi	a2,a2,-2032 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202100:	04600593          	li	a1,70
ffffffffc0202104:	00003517          	auipc	a0,0x3
ffffffffc0202108:	b2450513          	addi	a0,a0,-1244 # ffffffffc0204c28 <etext+0xd02>
ffffffffc020210c:	8cefe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0202110 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0202110:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202112:	00003617          	auipc	a2,0x3
ffffffffc0202116:	ae660613          	addi	a2,a2,-1306 # ffffffffc0204bf8 <etext+0xcd2>
ffffffffc020211a:	06900593          	li	a1,105
ffffffffc020211e:	00003517          	auipc	a0,0x3
ffffffffc0202122:	a3250513          	addi	a0,a0,-1486 # ffffffffc0204b50 <etext+0xc2a>
pa2page(uintptr_t pa)
ffffffffc0202126:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202128:	8b2fe0ef          	jal	ffffffffc02001da <__panic>

ffffffffc020212c <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020212c:	100027f3          	csrr	a5,sstatus
ffffffffc0202130:	8b89                	andi	a5,a5,2
ffffffffc0202132:	e799                	bnez	a5,ffffffffc0202140 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0202134:	0000b797          	auipc	a5,0xb
ffffffffc0202138:	3647b783          	ld	a5,868(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc020213c:	6f9c                	ld	a5,24(a5)
ffffffffc020213e:	8782                	jr	a5
{
ffffffffc0202140:	1101                	addi	sp,sp,-32
ffffffffc0202142:	ec06                	sd	ra,24(sp)
ffffffffc0202144:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202146:	f32fe0ef          	jal	ffffffffc0200878 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020214a:	0000b797          	auipc	a5,0xb
ffffffffc020214e:	34e7b783          	ld	a5,846(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc0202152:	6522                	ld	a0,8(sp)
ffffffffc0202154:	6f9c                	ld	a5,24(a5)
ffffffffc0202156:	9782                	jalr	a5
ffffffffc0202158:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020215a:	f18fe0ef          	jal	ffffffffc0200872 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020215e:	60e2                	ld	ra,24(sp)
ffffffffc0202160:	6522                	ld	a0,8(sp)
ffffffffc0202162:	6105                	addi	sp,sp,32
ffffffffc0202164:	8082                	ret

ffffffffc0202166 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202166:	100027f3          	csrr	a5,sstatus
ffffffffc020216a:	8b89                	andi	a5,a5,2
ffffffffc020216c:	e799                	bnez	a5,ffffffffc020217a <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020216e:	0000b797          	auipc	a5,0xb
ffffffffc0202172:	32a7b783          	ld	a5,810(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc0202176:	739c                	ld	a5,32(a5)
ffffffffc0202178:	8782                	jr	a5
{
ffffffffc020217a:	1101                	addi	sp,sp,-32
ffffffffc020217c:	ec06                	sd	ra,24(sp)
ffffffffc020217e:	e42e                	sd	a1,8(sp)
ffffffffc0202180:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202182:	ef6fe0ef          	jal	ffffffffc0200878 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202186:	0000b797          	auipc	a5,0xb
ffffffffc020218a:	3127b783          	ld	a5,786(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc020218e:	65a2                	ld	a1,8(sp)
ffffffffc0202190:	6502                	ld	a0,0(sp)
ffffffffc0202192:	739c                	ld	a5,32(a5)
ffffffffc0202194:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202196:	60e2                	ld	ra,24(sp)
ffffffffc0202198:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020219a:	ed8fe06f          	j	ffffffffc0200872 <intr_enable>

ffffffffc020219e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020219e:	100027f3          	csrr	a5,sstatus
ffffffffc02021a2:	8b89                	andi	a5,a5,2
ffffffffc02021a4:	e799                	bnez	a5,ffffffffc02021b2 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02021a6:	0000b797          	auipc	a5,0xb
ffffffffc02021aa:	2f27b783          	ld	a5,754(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc02021ae:	779c                	ld	a5,40(a5)
ffffffffc02021b0:	8782                	jr	a5
{
ffffffffc02021b2:	1101                	addi	sp,sp,-32
ffffffffc02021b4:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02021b6:	ec2fe0ef          	jal	ffffffffc0200878 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02021ba:	0000b797          	auipc	a5,0xb
ffffffffc02021be:	2de7b783          	ld	a5,734(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc02021c2:	779c                	ld	a5,40(a5)
ffffffffc02021c4:	9782                	jalr	a5
ffffffffc02021c6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02021c8:	eaafe0ef          	jal	ffffffffc0200872 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02021cc:	60e2                	ld	ra,24(sp)
ffffffffc02021ce:	6522                	ld	a0,8(sp)
ffffffffc02021d0:	6105                	addi	sp,sp,32
ffffffffc02021d2:	8082                	ret

ffffffffc02021d4 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02021d4:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02021d8:	1ff7f793          	andi	a5,a5,511
ffffffffc02021dc:	078e                	slli	a5,a5,0x3
ffffffffc02021de:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc02021e2:	6314                	ld	a3,0(a4)
{
ffffffffc02021e4:	7139                	addi	sp,sp,-64
ffffffffc02021e6:	f822                	sd	s0,48(sp)
ffffffffc02021e8:	f426                	sd	s1,40(sp)
ffffffffc02021ea:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc02021ec:	0016f793          	andi	a5,a3,1
{
ffffffffc02021f0:	842e                	mv	s0,a1
ffffffffc02021f2:	8832                	mv	a6,a2
ffffffffc02021f4:	0000b497          	auipc	s1,0xb
ffffffffc02021f8:	2c448493          	addi	s1,s1,708 # ffffffffc020d4b8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc02021fc:	ebd1                	bnez	a5,ffffffffc0202290 <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02021fe:	16060d63          	beqz	a2,ffffffffc0202378 <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202202:	100027f3          	csrr	a5,sstatus
ffffffffc0202206:	8b89                	andi	a5,a5,2
ffffffffc0202208:	16079e63          	bnez	a5,ffffffffc0202384 <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc020220c:	0000b797          	auipc	a5,0xb
ffffffffc0202210:	28c7b783          	ld	a5,652(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc0202214:	4505                	li	a0,1
ffffffffc0202216:	e43a                	sd	a4,8(sp)
ffffffffc0202218:	6f9c                	ld	a5,24(a5)
ffffffffc020221a:	e832                	sd	a2,16(sp)
ffffffffc020221c:	9782                	jalr	a5
ffffffffc020221e:	6722                	ld	a4,8(sp)
ffffffffc0202220:	6842                	ld	a6,16(sp)
ffffffffc0202222:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202224:	14078a63          	beqz	a5,ffffffffc0202378 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0202228:	0000b517          	auipc	a0,0xb
ffffffffc020222c:	29853503          	ld	a0,664(a0) # ffffffffc020d4c0 <pages>
ffffffffc0202230:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202234:	0000b497          	auipc	s1,0xb
ffffffffc0202238:	28448493          	addi	s1,s1,644 # ffffffffc020d4b8 <npage>
ffffffffc020223c:	40a78533          	sub	a0,a5,a0
ffffffffc0202240:	8519                	srai	a0,a0,0x6
ffffffffc0202242:	9546                	add	a0,a0,a7
ffffffffc0202244:	6090                	ld	a2,0(s1)
ffffffffc0202246:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc020224a:	4585                	li	a1,1
ffffffffc020224c:	82b1                	srli	a3,a3,0xc
ffffffffc020224e:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202250:	0532                	slli	a0,a0,0xc
ffffffffc0202252:	1ac6f763          	bgeu	a3,a2,ffffffffc0202400 <get_pte+0x22c>
ffffffffc0202256:	0000b697          	auipc	a3,0xb
ffffffffc020225a:	25a6b683          	ld	a3,602(a3) # ffffffffc020d4b0 <va_pa_offset>
ffffffffc020225e:	6605                	lui	a2,0x1
ffffffffc0202260:	4581                	li	a1,0
ffffffffc0202262:	9536                	add	a0,a0,a3
ffffffffc0202264:	ec42                	sd	a6,24(sp)
ffffffffc0202266:	e83e                	sd	a5,16(sp)
ffffffffc0202268:	e43a                	sd	a4,8(sp)
ffffffffc020226a:	08d010ef          	jal	ffffffffc0203af6 <memset>
    return page - pages + nbase;
ffffffffc020226e:	0000b697          	auipc	a3,0xb
ffffffffc0202272:	2526b683          	ld	a3,594(a3) # ffffffffc020d4c0 <pages>
ffffffffc0202276:	67c2                	ld	a5,16(sp)
ffffffffc0202278:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020227c:	6722                	ld	a4,8(sp)
ffffffffc020227e:	40d786b3          	sub	a3,a5,a3
ffffffffc0202282:	8699                	srai	a3,a3,0x6
ffffffffc0202284:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202286:	06aa                	slli	a3,a3,0xa
ffffffffc0202288:	6862                	ld	a6,24(sp)
ffffffffc020228a:	0116e693          	ori	a3,a3,17
ffffffffc020228e:	e314                	sd	a3,0(a4)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202290:	c006f693          	andi	a3,a3,-1024
ffffffffc0202294:	6098                	ld	a4,0(s1)
ffffffffc0202296:	068a                	slli	a3,a3,0x2
ffffffffc0202298:	00c6d793          	srli	a5,a3,0xc
ffffffffc020229c:	14e7f663          	bgeu	a5,a4,ffffffffc02023e8 <get_pte+0x214>
ffffffffc02022a0:	0000b897          	auipc	a7,0xb
ffffffffc02022a4:	21088893          	addi	a7,a7,528 # ffffffffc020d4b0 <va_pa_offset>
ffffffffc02022a8:	0008b603          	ld	a2,0(a7)
ffffffffc02022ac:	01545793          	srli	a5,s0,0x15
ffffffffc02022b0:	1ff7f793          	andi	a5,a5,511
ffffffffc02022b4:	96b2                	add	a3,a3,a2
ffffffffc02022b6:	078e                	slli	a5,a5,0x3
ffffffffc02022b8:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc02022ba:	6394                	ld	a3,0(a5)
ffffffffc02022bc:	0016f613          	andi	a2,a3,1
ffffffffc02022c0:	e659                	bnez	a2,ffffffffc020234e <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02022c2:	0a080b63          	beqz	a6,ffffffffc0202378 <get_pte+0x1a4>
ffffffffc02022c6:	10002773          	csrr	a4,sstatus
ffffffffc02022ca:	8b09                	andi	a4,a4,2
ffffffffc02022cc:	ef71                	bnez	a4,ffffffffc02023a8 <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc02022ce:	0000b717          	auipc	a4,0xb
ffffffffc02022d2:	1ca73703          	ld	a4,458(a4) # ffffffffc020d498 <pmm_manager>
ffffffffc02022d6:	4505                	li	a0,1
ffffffffc02022d8:	e43e                	sd	a5,8(sp)
ffffffffc02022da:	6f18                	ld	a4,24(a4)
ffffffffc02022dc:	9702                	jalr	a4
ffffffffc02022de:	67a2                	ld	a5,8(sp)
ffffffffc02022e0:	872a                	mv	a4,a0
ffffffffc02022e2:	0000b897          	auipc	a7,0xb
ffffffffc02022e6:	1ce88893          	addi	a7,a7,462 # ffffffffc020d4b0 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02022ea:	c759                	beqz	a4,ffffffffc0202378 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc02022ec:	0000b697          	auipc	a3,0xb
ffffffffc02022f0:	1d46b683          	ld	a3,468(a3) # ffffffffc020d4c0 <pages>
ffffffffc02022f4:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02022f8:	608c                	ld	a1,0(s1)
ffffffffc02022fa:	40d706b3          	sub	a3,a4,a3
ffffffffc02022fe:	8699                	srai	a3,a3,0x6
ffffffffc0202300:	96c2                	add	a3,a3,a6
ffffffffc0202302:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc0202306:	4505                	li	a0,1
ffffffffc0202308:	8231                	srli	a2,a2,0xc
ffffffffc020230a:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc020230c:	06b2                	slli	a3,a3,0xc
ffffffffc020230e:	10b67663          	bgeu	a2,a1,ffffffffc020241a <get_pte+0x246>
ffffffffc0202312:	0008b503          	ld	a0,0(a7)
ffffffffc0202316:	6605                	lui	a2,0x1
ffffffffc0202318:	4581                	li	a1,0
ffffffffc020231a:	9536                	add	a0,a0,a3
ffffffffc020231c:	e83a                	sd	a4,16(sp)
ffffffffc020231e:	e43e                	sd	a5,8(sp)
ffffffffc0202320:	7d6010ef          	jal	ffffffffc0203af6 <memset>
    return page - pages + nbase;
ffffffffc0202324:	0000b697          	auipc	a3,0xb
ffffffffc0202328:	19c6b683          	ld	a3,412(a3) # ffffffffc020d4c0 <pages>
ffffffffc020232c:	6742                	ld	a4,16(sp)
ffffffffc020232e:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202332:	67a2                	ld	a5,8(sp)
ffffffffc0202334:	40d706b3          	sub	a3,a4,a3
ffffffffc0202338:	8699                	srai	a3,a3,0x6
ffffffffc020233a:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020233c:	06aa                	slli	a3,a3,0xa
ffffffffc020233e:	0116e693          	ori	a3,a3,17
ffffffffc0202342:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202344:	6098                	ld	a4,0(s1)
ffffffffc0202346:	0000b897          	auipc	a7,0xb
ffffffffc020234a:	16a88893          	addi	a7,a7,362 # ffffffffc020d4b0 <va_pa_offset>
ffffffffc020234e:	c006f693          	andi	a3,a3,-1024
ffffffffc0202352:	068a                	slli	a3,a3,0x2
ffffffffc0202354:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202358:	06e7fc63          	bgeu	a5,a4,ffffffffc02023d0 <get_pte+0x1fc>
ffffffffc020235c:	0008b783          	ld	a5,0(a7)
ffffffffc0202360:	8031                	srli	s0,s0,0xc
ffffffffc0202362:	1ff47413          	andi	s0,s0,511
ffffffffc0202366:	040e                	slli	s0,s0,0x3
ffffffffc0202368:	96be                	add	a3,a3,a5
}
ffffffffc020236a:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020236c:	00868533          	add	a0,a3,s0
}
ffffffffc0202370:	7442                	ld	s0,48(sp)
ffffffffc0202372:	74a2                	ld	s1,40(sp)
ffffffffc0202374:	6121                	addi	sp,sp,64
ffffffffc0202376:	8082                	ret
ffffffffc0202378:	70e2                	ld	ra,56(sp)
ffffffffc020237a:	7442                	ld	s0,48(sp)
ffffffffc020237c:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc020237e:	4501                	li	a0,0
}
ffffffffc0202380:	6121                	addi	sp,sp,64
ffffffffc0202382:	8082                	ret
        intr_disable();
ffffffffc0202384:	e83a                	sd	a4,16(sp)
ffffffffc0202386:	ec32                	sd	a2,24(sp)
ffffffffc0202388:	cf0fe0ef          	jal	ffffffffc0200878 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020238c:	0000b797          	auipc	a5,0xb
ffffffffc0202390:	10c7b783          	ld	a5,268(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc0202394:	4505                	li	a0,1
ffffffffc0202396:	6f9c                	ld	a5,24(a5)
ffffffffc0202398:	9782                	jalr	a5
ffffffffc020239a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020239c:	cd6fe0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc02023a0:	6862                	ld	a6,24(sp)
ffffffffc02023a2:	6742                	ld	a4,16(sp)
ffffffffc02023a4:	67a2                	ld	a5,8(sp)
ffffffffc02023a6:	bdbd                	j	ffffffffc0202224 <get_pte+0x50>
        intr_disable();
ffffffffc02023a8:	e83e                	sd	a5,16(sp)
ffffffffc02023aa:	ccefe0ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc02023ae:	0000b717          	auipc	a4,0xb
ffffffffc02023b2:	0ea73703          	ld	a4,234(a4) # ffffffffc020d498 <pmm_manager>
ffffffffc02023b6:	4505                	li	a0,1
ffffffffc02023b8:	6f18                	ld	a4,24(a4)
ffffffffc02023ba:	9702                	jalr	a4
ffffffffc02023bc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02023be:	cb4fe0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc02023c2:	6722                	ld	a4,8(sp)
ffffffffc02023c4:	67c2                	ld	a5,16(sp)
ffffffffc02023c6:	0000b897          	auipc	a7,0xb
ffffffffc02023ca:	0ea88893          	addi	a7,a7,234 # ffffffffc020d4b0 <va_pa_offset>
ffffffffc02023ce:	bf31                	j	ffffffffc02022ea <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02023d0:	00002617          	auipc	a2,0x2
ffffffffc02023d4:	75860613          	addi	a2,a2,1880 # ffffffffc0204b28 <etext+0xc02>
ffffffffc02023d8:	0fb00593          	li	a1,251
ffffffffc02023dc:	00003517          	auipc	a0,0x3
ffffffffc02023e0:	be450513          	addi	a0,a0,-1052 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02023e4:	df7fd0ef          	jal	ffffffffc02001da <__panic>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02023e8:	00002617          	auipc	a2,0x2
ffffffffc02023ec:	74060613          	addi	a2,a2,1856 # ffffffffc0204b28 <etext+0xc02>
ffffffffc02023f0:	0ee00593          	li	a1,238
ffffffffc02023f4:	00003517          	auipc	a0,0x3
ffffffffc02023f8:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02023fc:	ddffd0ef          	jal	ffffffffc02001da <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202400:	86aa                	mv	a3,a0
ffffffffc0202402:	00002617          	auipc	a2,0x2
ffffffffc0202406:	72660613          	addi	a2,a2,1830 # ffffffffc0204b28 <etext+0xc02>
ffffffffc020240a:	0eb00593          	li	a1,235
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	bb250513          	addi	a0,a0,-1102 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202416:	dc5fd0ef          	jal	ffffffffc02001da <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020241a:	00002617          	auipc	a2,0x2
ffffffffc020241e:	70e60613          	addi	a2,a2,1806 # ffffffffc0204b28 <etext+0xc02>
ffffffffc0202422:	0f800593          	li	a1,248
ffffffffc0202426:	00003517          	auipc	a0,0x3
ffffffffc020242a:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020242e:	dadfd0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0202432 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202432:	1141                	addi	sp,sp,-16
ffffffffc0202434:	e022                	sd	s0,0(sp)
ffffffffc0202436:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202438:	4601                	li	a2,0
{
ffffffffc020243a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020243c:	d99ff0ef          	jal	ffffffffc02021d4 <get_pte>
    if (ptep_store != NULL)
ffffffffc0202440:	c011                	beqz	s0,ffffffffc0202444 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202442:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202444:	c511                	beqz	a0,ffffffffc0202450 <get_page+0x1e>
ffffffffc0202446:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202448:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020244a:	0017f713          	andi	a4,a5,1
ffffffffc020244e:	e709                	bnez	a4,ffffffffc0202458 <get_page+0x26>
}
ffffffffc0202450:	60a2                	ld	ra,8(sp)
ffffffffc0202452:	6402                	ld	s0,0(sp)
ffffffffc0202454:	0141                	addi	sp,sp,16
ffffffffc0202456:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202458:	0000b717          	auipc	a4,0xb
ffffffffc020245c:	06073703          	ld	a4,96(a4) # ffffffffc020d4b8 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202460:	078a                	slli	a5,a5,0x2
ffffffffc0202462:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202464:	00e7ff63          	bgeu	a5,a4,ffffffffc0202482 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc0202468:	0000b517          	auipc	a0,0xb
ffffffffc020246c:	05853503          	ld	a0,88(a0) # ffffffffc020d4c0 <pages>
ffffffffc0202470:	60a2                	ld	ra,8(sp)
ffffffffc0202472:	6402                	ld	s0,0(sp)
ffffffffc0202474:	079a                	slli	a5,a5,0x6
ffffffffc0202476:	fe000737          	lui	a4,0xfe000
ffffffffc020247a:	97ba                	add	a5,a5,a4
ffffffffc020247c:	953e                	add	a0,a0,a5
ffffffffc020247e:	0141                	addi	sp,sp,16
ffffffffc0202480:	8082                	ret
ffffffffc0202482:	c8fff0ef          	jal	ffffffffc0202110 <pa2page.part.0>

ffffffffc0202486 <page_remove>:
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
ffffffffc0202486:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202488:	4601                	li	a2,0
{
ffffffffc020248a:	e822                	sd	s0,16(sp)
ffffffffc020248c:	ec06                	sd	ra,24(sp)
ffffffffc020248e:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202490:	d45ff0ef          	jal	ffffffffc02021d4 <get_pte>
    if (ptep != NULL)
ffffffffc0202494:	c511                	beqz	a0,ffffffffc02024a0 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc0202496:	6118                	ld	a4,0(a0)
ffffffffc0202498:	87aa                	mv	a5,a0
ffffffffc020249a:	00177693          	andi	a3,a4,1
ffffffffc020249e:	e689                	bnez	a3,ffffffffc02024a8 <page_remove+0x22>
    {
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02024a0:	60e2                	ld	ra,24(sp)
ffffffffc02024a2:	6442                	ld	s0,16(sp)
ffffffffc02024a4:	6105                	addi	sp,sp,32
ffffffffc02024a6:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02024a8:	0000b697          	auipc	a3,0xb
ffffffffc02024ac:	0106b683          	ld	a3,16(a3) # ffffffffc020d4b8 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02024b0:	070a                	slli	a4,a4,0x2
ffffffffc02024b2:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02024b4:	06d77563          	bgeu	a4,a3,ffffffffc020251e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02024b8:	0000b517          	auipc	a0,0xb
ffffffffc02024bc:	00853503          	ld	a0,8(a0) # ffffffffc020d4c0 <pages>
ffffffffc02024c0:	071a                	slli	a4,a4,0x6
ffffffffc02024c2:	fe0006b7          	lui	a3,0xfe000
ffffffffc02024c6:	9736                	add	a4,a4,a3
ffffffffc02024c8:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02024ca:	4118                	lw	a4,0(a0)
ffffffffc02024cc:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3ddf2b17>
ffffffffc02024ce:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02024d0:	cb09                	beqz	a4,ffffffffc02024e2 <page_remove+0x5c>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02024d2:	0007b023          	sd	zero,0(a5)
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024d6:	12040073          	sfence.vma	s0
}
ffffffffc02024da:	60e2                	ld	ra,24(sp)
ffffffffc02024dc:	6442                	ld	s0,16(sp)
ffffffffc02024de:	6105                	addi	sp,sp,32
ffffffffc02024e0:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02024e2:	10002773          	csrr	a4,sstatus
ffffffffc02024e6:	8b09                	andi	a4,a4,2
ffffffffc02024e8:	eb19                	bnez	a4,ffffffffc02024fe <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc02024ea:	0000b717          	auipc	a4,0xb
ffffffffc02024ee:	fae73703          	ld	a4,-82(a4) # ffffffffc020d498 <pmm_manager>
ffffffffc02024f2:	4585                	li	a1,1
ffffffffc02024f4:	e03e                	sd	a5,0(sp)
ffffffffc02024f6:	7318                	ld	a4,32(a4)
ffffffffc02024f8:	9702                	jalr	a4
    if (flag) {
ffffffffc02024fa:	6782                	ld	a5,0(sp)
ffffffffc02024fc:	bfd9                	j	ffffffffc02024d2 <page_remove+0x4c>
        intr_disable();
ffffffffc02024fe:	e43e                	sd	a5,8(sp)
ffffffffc0202500:	e02a                	sd	a0,0(sp)
ffffffffc0202502:	b76fe0ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0202506:	0000b717          	auipc	a4,0xb
ffffffffc020250a:	f9273703          	ld	a4,-110(a4) # ffffffffc020d498 <pmm_manager>
ffffffffc020250e:	6502                	ld	a0,0(sp)
ffffffffc0202510:	4585                	li	a1,1
ffffffffc0202512:	7318                	ld	a4,32(a4)
ffffffffc0202514:	9702                	jalr	a4
        intr_enable();
ffffffffc0202516:	b5cfe0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc020251a:	67a2                	ld	a5,8(sp)
ffffffffc020251c:	bf5d                	j	ffffffffc02024d2 <page_remove+0x4c>
ffffffffc020251e:	bf3ff0ef          	jal	ffffffffc0202110 <pa2page.part.0>

ffffffffc0202522 <page_insert>:
{
ffffffffc0202522:	7139                	addi	sp,sp,-64
ffffffffc0202524:	f426                	sd	s1,40(sp)
ffffffffc0202526:	84b2                	mv	s1,a2
ffffffffc0202528:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020252a:	4605                	li	a2,1
{
ffffffffc020252c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020252e:	85a6                	mv	a1,s1
{
ffffffffc0202530:	fc06                	sd	ra,56(sp)
ffffffffc0202532:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202534:	ca1ff0ef          	jal	ffffffffc02021d4 <get_pte>
    if (ptep == NULL)
ffffffffc0202538:	cd61                	beqz	a0,ffffffffc0202610 <page_insert+0xee>
    page->ref += 1;
ffffffffc020253a:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc020253c:	611c                	ld	a5,0(a0)
ffffffffc020253e:	66a2                	ld	a3,8(sp)
ffffffffc0202540:	0015861b          	addiw	a2,a1,1
ffffffffc0202544:	c010                	sw	a2,0(s0)
ffffffffc0202546:	0017f613          	andi	a2,a5,1
ffffffffc020254a:	872a                	mv	a4,a0
ffffffffc020254c:	e61d                	bnez	a2,ffffffffc020257a <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc020254e:	0000b617          	auipc	a2,0xb
ffffffffc0202552:	f7263603          	ld	a2,-142(a2) # ffffffffc020d4c0 <pages>
    return page - pages + nbase;
ffffffffc0202556:	8c11                	sub	s0,s0,a2
ffffffffc0202558:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020255a:	200007b7          	lui	a5,0x20000
ffffffffc020255e:	042a                	slli	s0,s0,0xa
ffffffffc0202560:	943e                	add	s0,s0,a5
ffffffffc0202562:	8ec1                	or	a3,a3,s0
ffffffffc0202564:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202568:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020256a:	12048073          	sfence.vma	s1
    return 0;
ffffffffc020256e:	4501                	li	a0,0
}
ffffffffc0202570:	70e2                	ld	ra,56(sp)
ffffffffc0202572:	7442                	ld	s0,48(sp)
ffffffffc0202574:	74a2                	ld	s1,40(sp)
ffffffffc0202576:	6121                	addi	sp,sp,64
ffffffffc0202578:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc020257a:	0000b617          	auipc	a2,0xb
ffffffffc020257e:	f3e63603          	ld	a2,-194(a2) # ffffffffc020d4b8 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202582:	078a                	slli	a5,a5,0x2
ffffffffc0202584:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202586:	08c7f763          	bgeu	a5,a2,ffffffffc0202614 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc020258a:	0000b617          	auipc	a2,0xb
ffffffffc020258e:	f3663603          	ld	a2,-202(a2) # ffffffffc020d4c0 <pages>
ffffffffc0202592:	fe000537          	lui	a0,0xfe000
ffffffffc0202596:	079a                	slli	a5,a5,0x6
ffffffffc0202598:	97aa                	add	a5,a5,a0
ffffffffc020259a:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc020259e:	00a40963          	beq	s0,a0,ffffffffc02025b0 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc02025a2:	411c                	lw	a5,0(a0)
ffffffffc02025a4:	37fd                	addiw	a5,a5,-1 # 1fffffff <kern_entry-0xffffffffa0200001>
ffffffffc02025a6:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc02025a8:	c791                	beqz	a5,ffffffffc02025b4 <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025aa:	12048073          	sfence.vma	s1
}
ffffffffc02025ae:	b765                	j	ffffffffc0202556 <page_insert+0x34>
ffffffffc02025b0:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc02025b2:	b755                	j	ffffffffc0202556 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02025b4:	100027f3          	csrr	a5,sstatus
ffffffffc02025b8:	8b89                	andi	a5,a5,2
ffffffffc02025ba:	e39d                	bnez	a5,ffffffffc02025e0 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc02025bc:	0000b797          	auipc	a5,0xb
ffffffffc02025c0:	edc7b783          	ld	a5,-292(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc02025c4:	4585                	li	a1,1
ffffffffc02025c6:	e83a                	sd	a4,16(sp)
ffffffffc02025c8:	739c                	ld	a5,32(a5)
ffffffffc02025ca:	e436                	sd	a3,8(sp)
ffffffffc02025cc:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02025ce:	0000b617          	auipc	a2,0xb
ffffffffc02025d2:	ef263603          	ld	a2,-270(a2) # ffffffffc020d4c0 <pages>
ffffffffc02025d6:	66a2                	ld	a3,8(sp)
ffffffffc02025d8:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025da:	12048073          	sfence.vma	s1
ffffffffc02025de:	bfa5                	j	ffffffffc0202556 <page_insert+0x34>
        intr_disable();
ffffffffc02025e0:	ec3a                	sd	a4,24(sp)
ffffffffc02025e2:	e836                	sd	a3,16(sp)
ffffffffc02025e4:	e42a                	sd	a0,8(sp)
ffffffffc02025e6:	a92fe0ef          	jal	ffffffffc0200878 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025ea:	0000b797          	auipc	a5,0xb
ffffffffc02025ee:	eae7b783          	ld	a5,-338(a5) # ffffffffc020d498 <pmm_manager>
ffffffffc02025f2:	6522                	ld	a0,8(sp)
ffffffffc02025f4:	4585                	li	a1,1
ffffffffc02025f6:	739c                	ld	a5,32(a5)
ffffffffc02025f8:	9782                	jalr	a5
        intr_enable();
ffffffffc02025fa:	a78fe0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc02025fe:	0000b617          	auipc	a2,0xb
ffffffffc0202602:	ec263603          	ld	a2,-318(a2) # ffffffffc020d4c0 <pages>
ffffffffc0202606:	6762                	ld	a4,24(sp)
ffffffffc0202608:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020260a:	12048073          	sfence.vma	s1
ffffffffc020260e:	b7a1                	j	ffffffffc0202556 <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc0202610:	5571                	li	a0,-4
ffffffffc0202612:	bfb9                	j	ffffffffc0202570 <page_insert+0x4e>
ffffffffc0202614:	afdff0ef          	jal	ffffffffc0202110 <pa2page.part.0>

ffffffffc0202618 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202618:	00003797          	auipc	a5,0x3
ffffffffc020261c:	29878793          	addi	a5,a5,664 # ffffffffc02058b0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202620:	638c                	ld	a1,0(a5)
{
ffffffffc0202622:	7159                	addi	sp,sp,-112
ffffffffc0202624:	f486                	sd	ra,104(sp)
ffffffffc0202626:	e8ca                	sd	s2,80(sp)
ffffffffc0202628:	e4ce                	sd	s3,72(sp)
ffffffffc020262a:	f85a                	sd	s6,48(sp)
ffffffffc020262c:	f0a2                	sd	s0,96(sp)
ffffffffc020262e:	eca6                	sd	s1,88(sp)
ffffffffc0202630:	e0d2                	sd	s4,64(sp)
ffffffffc0202632:	fc56                	sd	s5,56(sp)
ffffffffc0202634:	f45e                	sd	s7,40(sp)
ffffffffc0202636:	f062                	sd	s8,32(sp)
ffffffffc0202638:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020263a:	0000bb17          	auipc	s6,0xb
ffffffffc020263e:	e5eb0b13          	addi	s6,s6,-418 # ffffffffc020d498 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202642:	00003517          	auipc	a0,0x3
ffffffffc0202646:	98e50513          	addi	a0,a0,-1650 # ffffffffc0204fd0 <etext+0x10aa>
    pmm_manager = &default_pmm_manager;
ffffffffc020264a:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020264e:	a91fd0ef          	jal	ffffffffc02000de <cprintf>
    pmm_manager->init();
ffffffffc0202652:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202656:	0000b997          	auipc	s3,0xb
ffffffffc020265a:	e5a98993          	addi	s3,s3,-422 # ffffffffc020d4b0 <va_pa_offset>
    pmm_manager->init();
ffffffffc020265e:	679c                	ld	a5,8(a5)
ffffffffc0202660:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202662:	57f5                	li	a5,-3
ffffffffc0202664:	07fa                	slli	a5,a5,0x1e
ffffffffc0202666:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc020266a:	92cfe0ef          	jal	ffffffffc0200796 <get_memory_base>
ffffffffc020266e:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0202670:	930fe0ef          	jal	ffffffffc02007a0 <get_memory_size>
    if (mem_size == 0) {
ffffffffc0202674:	70050e63          	beqz	a0,ffffffffc0202d90 <pmm_init+0x778>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0202678:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc020267a:	00003517          	auipc	a0,0x3
ffffffffc020267e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0205008 <etext+0x10e2>
ffffffffc0202682:	a5dfd0ef          	jal	ffffffffc02000de <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0202686:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020268a:	864a                	mv	a2,s2
ffffffffc020268c:	85a6                	mv	a1,s1
ffffffffc020268e:	fff40693          	addi	a3,s0,-1
ffffffffc0202692:	00003517          	auipc	a0,0x3
ffffffffc0202696:	98e50513          	addi	a0,a0,-1650 # ffffffffc0205020 <etext+0x10fa>
ffffffffc020269a:	a45fd0ef          	jal	ffffffffc02000de <cprintf>
    if (maxpa > KERNTOP)
ffffffffc020269e:	c80007b7          	lui	a5,0xc8000
ffffffffc02026a2:	8522                	mv	a0,s0
ffffffffc02026a4:	5287ed63          	bltu	a5,s0,ffffffffc0202bde <pmm_init+0x5c6>
ffffffffc02026a8:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026aa:	0000c617          	auipc	a2,0xc
ffffffffc02026ae:	e3d60613          	addi	a2,a2,-451 # ffffffffc020e4e7 <end+0xfff>
ffffffffc02026b2:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc02026b4:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026b6:	0000bb97          	auipc	s7,0xb
ffffffffc02026ba:	e0ab8b93          	addi	s7,s7,-502 # ffffffffc020d4c0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02026be:	0000b497          	auipc	s1,0xb
ffffffffc02026c2:	dfa48493          	addi	s1,s1,-518 # ffffffffc020d4b8 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c6:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc02026ca:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026cc:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026d0:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026d2:	02f50763          	beq	a0,a5,ffffffffc0202700 <pmm_init+0xe8>
ffffffffc02026d6:	4701                	li	a4,0
ffffffffc02026d8:	4585                	li	a1,1
ffffffffc02026da:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02026de:	00671793          	slli	a5,a4,0x6
ffffffffc02026e2:	97b2                	add	a5,a5,a2
ffffffffc02026e4:	07a1                	addi	a5,a5,8 # 80008 <kern_entry-0xffffffffc017fff8>
ffffffffc02026e6:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026ea:	6088                	ld	a0,0(s1)
ffffffffc02026ec:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026ee:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026f2:	00d507b3          	add	a5,a0,a3
ffffffffc02026f6:	fef764e3          	bltu	a4,a5,ffffffffc02026de <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026fa:	079a                	slli	a5,a5,0x6
ffffffffc02026fc:	00f606b3          	add	a3,a2,a5
ffffffffc0202700:	c02007b7          	lui	a5,0xc0200
ffffffffc0202704:	16f6eee3          	bltu	a3,a5,ffffffffc0203080 <pmm_init+0xa68>
ffffffffc0202708:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020270c:	77fd                	lui	a5,0xfffff
ffffffffc020270e:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202710:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202712:	4e86ed63          	bltu	a3,s0,ffffffffc0202c0c <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202716:	00003517          	auipc	a0,0x3
ffffffffc020271a:	93250513          	addi	a0,a0,-1742 # ffffffffc0205048 <etext+0x1122>
ffffffffc020271e:	9c1fd0ef          	jal	ffffffffc02000de <cprintf>
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202722:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202726:	0000b917          	auipc	s2,0xb
ffffffffc020272a:	d8290913          	addi	s2,s2,-638 # ffffffffc020d4a8 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020272e:	7b9c                	ld	a5,48(a5)
ffffffffc0202730:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202732:	00003517          	auipc	a0,0x3
ffffffffc0202736:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205060 <etext+0x113a>
ffffffffc020273a:	9a5fd0ef          	jal	ffffffffc02000de <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020273e:	00006697          	auipc	a3,0x6
ffffffffc0202742:	8c268693          	addi	a3,a3,-1854 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0202746:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020274a:	c02007b7          	lui	a5,0xc0200
ffffffffc020274e:	2af6eee3          	bltu	a3,a5,ffffffffc020320a <pmm_init+0xbf2>
ffffffffc0202752:	0009b783          	ld	a5,0(s3)
ffffffffc0202756:	8e9d                	sub	a3,a3,a5
ffffffffc0202758:	0000b797          	auipc	a5,0xb
ffffffffc020275c:	d4d7b423          	sd	a3,-696(a5) # ffffffffc020d4a0 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202760:	100027f3          	csrr	a5,sstatus
ffffffffc0202764:	8b89                	andi	a5,a5,2
ffffffffc0202766:	48079963          	bnez	a5,ffffffffc0202bf8 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc020276a:	000b3783          	ld	a5,0(s6)
ffffffffc020276e:	779c                	ld	a5,40(a5)
ffffffffc0202770:	9782                	jalr	a5
ffffffffc0202772:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202774:	6098                	ld	a4,0(s1)
ffffffffc0202776:	c80007b7          	lui	a5,0xc8000
ffffffffc020277a:	83b1                	srli	a5,a5,0xc
ffffffffc020277c:	66e7e663          	bltu	a5,a4,ffffffffc0202de8 <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202780:	00093503          	ld	a0,0(s2)
ffffffffc0202784:	64050263          	beqz	a0,ffffffffc0202dc8 <pmm_init+0x7b0>
ffffffffc0202788:	03451793          	slli	a5,a0,0x34
ffffffffc020278c:	62079e63          	bnez	a5,ffffffffc0202dc8 <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202790:	4601                	li	a2,0
ffffffffc0202792:	4581                	li	a1,0
ffffffffc0202794:	c9fff0ef          	jal	ffffffffc0202432 <get_page>
ffffffffc0202798:	240519e3          	bnez	a0,ffffffffc02031ea <pmm_init+0xbd2>
ffffffffc020279c:	100027f3          	csrr	a5,sstatus
ffffffffc02027a0:	8b89                	andi	a5,a5,2
ffffffffc02027a2:	44079063          	bnez	a5,ffffffffc0202be2 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc02027a6:	000b3783          	ld	a5,0(s6)
ffffffffc02027aa:	4505                	li	a0,1
ffffffffc02027ac:	6f9c                	ld	a5,24(a5)
ffffffffc02027ae:	9782                	jalr	a5
ffffffffc02027b0:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02027b2:	00093503          	ld	a0,0(s2)
ffffffffc02027b6:	4681                	li	a3,0
ffffffffc02027b8:	4601                	li	a2,0
ffffffffc02027ba:	85d2                	mv	a1,s4
ffffffffc02027bc:	d67ff0ef          	jal	ffffffffc0202522 <page_insert>
ffffffffc02027c0:	280511e3          	bnez	a0,ffffffffc0203242 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02027c4:	00093503          	ld	a0,0(s2)
ffffffffc02027c8:	4601                	li	a2,0
ffffffffc02027ca:	4581                	li	a1,0
ffffffffc02027cc:	a09ff0ef          	jal	ffffffffc02021d4 <get_pte>
ffffffffc02027d0:	240509e3          	beqz	a0,ffffffffc0203222 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027d4:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc02027d6:	0017f713          	andi	a4,a5,1
ffffffffc02027da:	58070f63          	beqz	a4,ffffffffc0202d78 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc02027de:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027e0:	078a                	slli	a5,a5,0x2
ffffffffc02027e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027e4:	58e7f863          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02027e8:	000bb683          	ld	a3,0(s7)
ffffffffc02027ec:	079a                	slli	a5,a5,0x6
ffffffffc02027ee:	fe000637          	lui	a2,0xfe000
ffffffffc02027f2:	97b2                	add	a5,a5,a2
ffffffffc02027f4:	97b6                	add	a5,a5,a3
ffffffffc02027f6:	14fa1ae3          	bne	s4,a5,ffffffffc020314a <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc02027fa:	000a2683          	lw	a3,0(s4)
ffffffffc02027fe:	4785                	li	a5,1
ffffffffc0202800:	12f695e3          	bne	a3,a5,ffffffffc020312a <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202804:	00093503          	ld	a0,0(s2)
ffffffffc0202808:	77fd                	lui	a5,0xfffff
ffffffffc020280a:	6114                	ld	a3,0(a0)
ffffffffc020280c:	068a                	slli	a3,a3,0x2
ffffffffc020280e:	8efd                	and	a3,a3,a5
ffffffffc0202810:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202814:	0ee67fe3          	bgeu	a2,a4,ffffffffc0203112 <pmm_init+0xafa>
ffffffffc0202818:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020281c:	96e2                	add	a3,a3,s8
ffffffffc020281e:	0006ba83          	ld	s5,0(a3)
ffffffffc0202822:	0a8a                	slli	s5,s5,0x2
ffffffffc0202824:	00fafab3          	and	s5,s5,a5
ffffffffc0202828:	00cad793          	srli	a5,s5,0xc
ffffffffc020282c:	0ce7f6e3          	bgeu	a5,a4,ffffffffc02030f8 <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202830:	4601                	li	a2,0
ffffffffc0202832:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202834:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202836:	99fff0ef          	jal	ffffffffc02021d4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020283a:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020283c:	05851ee3          	bne	a0,s8,ffffffffc0203098 <pmm_init+0xa80>
ffffffffc0202840:	100027f3          	csrr	a5,sstatus
ffffffffc0202844:	8b89                	andi	a5,a5,2
ffffffffc0202846:	3e079b63          	bnez	a5,ffffffffc0202c3c <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc020284a:	000b3783          	ld	a5,0(s6)
ffffffffc020284e:	4505                	li	a0,1
ffffffffc0202850:	6f9c                	ld	a5,24(a5)
ffffffffc0202852:	9782                	jalr	a5
ffffffffc0202854:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202856:	00093503          	ld	a0,0(s2)
ffffffffc020285a:	46d1                	li	a3,20
ffffffffc020285c:	6605                	lui	a2,0x1
ffffffffc020285e:	85e2                	mv	a1,s8
ffffffffc0202860:	cc3ff0ef          	jal	ffffffffc0202522 <page_insert>
ffffffffc0202864:	06051ae3          	bnez	a0,ffffffffc02030d8 <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202868:	00093503          	ld	a0,0(s2)
ffffffffc020286c:	4601                	li	a2,0
ffffffffc020286e:	6585                	lui	a1,0x1
ffffffffc0202870:	965ff0ef          	jal	ffffffffc02021d4 <get_pte>
ffffffffc0202874:	040502e3          	beqz	a0,ffffffffc02030b8 <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202878:	611c                	ld	a5,0(a0)
ffffffffc020287a:	0107f713          	andi	a4,a5,16
ffffffffc020287e:	7e070163          	beqz	a4,ffffffffc0203060 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202882:	8b91                	andi	a5,a5,4
ffffffffc0202884:	7a078e63          	beqz	a5,ffffffffc0203040 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202888:	00093503          	ld	a0,0(s2)
ffffffffc020288c:	611c                	ld	a5,0(a0)
ffffffffc020288e:	8bc1                	andi	a5,a5,16
ffffffffc0202890:	78078863          	beqz	a5,ffffffffc0203020 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202894:	000c2703          	lw	a4,0(s8)
ffffffffc0202898:	4785                	li	a5,1
ffffffffc020289a:	76f71363          	bne	a4,a5,ffffffffc0203000 <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020289e:	4681                	li	a3,0
ffffffffc02028a0:	6605                	lui	a2,0x1
ffffffffc02028a2:	85d2                	mv	a1,s4
ffffffffc02028a4:	c7fff0ef          	jal	ffffffffc0202522 <page_insert>
ffffffffc02028a8:	72051c63          	bnez	a0,ffffffffc0202fe0 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc02028ac:	000a2703          	lw	a4,0(s4)
ffffffffc02028b0:	4789                	li	a5,2
ffffffffc02028b2:	70f71763          	bne	a4,a5,ffffffffc0202fc0 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc02028b6:	000c2783          	lw	a5,0(s8)
ffffffffc02028ba:	6e079363          	bnez	a5,ffffffffc0202fa0 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02028be:	00093503          	ld	a0,0(s2)
ffffffffc02028c2:	4601                	li	a2,0
ffffffffc02028c4:	6585                	lui	a1,0x1
ffffffffc02028c6:	90fff0ef          	jal	ffffffffc02021d4 <get_pte>
ffffffffc02028ca:	6a050b63          	beqz	a0,ffffffffc0202f80 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc02028ce:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc02028d0:	00177793          	andi	a5,a4,1
ffffffffc02028d4:	4a078263          	beqz	a5,ffffffffc0202d78 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc02028d8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028da:	00271793          	slli	a5,a4,0x2
ffffffffc02028de:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02028e0:	48d7fa63          	bgeu	a5,a3,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02028e4:	000bb683          	ld	a3,0(s7)
ffffffffc02028e8:	fff80ab7          	lui	s5,0xfff80
ffffffffc02028ec:	97d6                	add	a5,a5,s5
ffffffffc02028ee:	079a                	slli	a5,a5,0x6
ffffffffc02028f0:	97b6                	add	a5,a5,a3
ffffffffc02028f2:	66fa1763          	bne	s4,a5,ffffffffc0202f60 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028f6:	8b41                	andi	a4,a4,16
ffffffffc02028f8:	64071463          	bnez	a4,ffffffffc0202f40 <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc02028fc:	00093503          	ld	a0,0(s2)
ffffffffc0202900:	4581                	li	a1,0
ffffffffc0202902:	b85ff0ef          	jal	ffffffffc0202486 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202906:	000a2c83          	lw	s9,0(s4)
ffffffffc020290a:	4785                	li	a5,1
ffffffffc020290c:	60fc9a63          	bne	s9,a5,ffffffffc0202f20 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202910:	000c2783          	lw	a5,0(s8)
ffffffffc0202914:	5e079663          	bnez	a5,ffffffffc0202f00 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202918:	00093503          	ld	a0,0(s2)
ffffffffc020291c:	6585                	lui	a1,0x1
ffffffffc020291e:	b69ff0ef          	jal	ffffffffc0202486 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202922:	000a2783          	lw	a5,0(s4)
ffffffffc0202926:	52079d63          	bnez	a5,ffffffffc0202e60 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc020292a:	000c2783          	lw	a5,0(s8)
ffffffffc020292e:	50079963          	bnez	a5,ffffffffc0202e40 <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202932:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202936:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202938:	000a3783          	ld	a5,0(s4)
ffffffffc020293c:	078a                	slli	a5,a5,0x2
ffffffffc020293e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202940:	42e7fa63          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202944:	000bb503          	ld	a0,0(s7)
ffffffffc0202948:	97d6                	add	a5,a5,s5
ffffffffc020294a:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc020294c:	00f506b3          	add	a3,a0,a5
ffffffffc0202950:	4294                	lw	a3,0(a3)
ffffffffc0202952:	4d969763          	bne	a3,s9,ffffffffc0202e20 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202956:	8799                	srai	a5,a5,0x6
ffffffffc0202958:	00080637          	lui	a2,0x80
ffffffffc020295c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020295e:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202962:	4ae7f363          	bgeu	a5,a4,ffffffffc0202e08 <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202966:	0009b783          	ld	a5,0(s3)
ffffffffc020296a:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020296c:	639c                	ld	a5,0(a5)
ffffffffc020296e:	078a                	slli	a5,a5,0x2
ffffffffc0202970:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202972:	40e7f163          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202976:	8f91                	sub	a5,a5,a2
ffffffffc0202978:	079a                	slli	a5,a5,0x6
ffffffffc020297a:	953e                	add	a0,a0,a5
ffffffffc020297c:	100027f3          	csrr	a5,sstatus
ffffffffc0202980:	8b89                	andi	a5,a5,2
ffffffffc0202982:	30079863          	bnez	a5,ffffffffc0202c92 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202986:	000b3783          	ld	a5,0(s6)
ffffffffc020298a:	4585                	li	a1,1
ffffffffc020298c:	739c                	ld	a5,32(a5)
ffffffffc020298e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202990:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202994:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202996:	078a                	slli	a5,a5,0x2
ffffffffc0202998:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020299a:	3ce7fd63          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc020299e:	000bb503          	ld	a0,0(s7)
ffffffffc02029a2:	fe000737          	lui	a4,0xfe000
ffffffffc02029a6:	079a                	slli	a5,a5,0x6
ffffffffc02029a8:	97ba                	add	a5,a5,a4
ffffffffc02029aa:	953e                	add	a0,a0,a5
ffffffffc02029ac:	100027f3          	csrr	a5,sstatus
ffffffffc02029b0:	8b89                	andi	a5,a5,2
ffffffffc02029b2:	2c079463          	bnez	a5,ffffffffc0202c7a <pmm_init+0x662>
ffffffffc02029b6:	000b3783          	ld	a5,0(s6)
ffffffffc02029ba:	4585                	li	a1,1
ffffffffc02029bc:	739c                	ld	a5,32(a5)
ffffffffc02029be:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02029c0:	00093783          	ld	a5,0(s2)
ffffffffc02029c4:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b18>
    asm volatile("sfence.vma");
ffffffffc02029c8:	12000073          	sfence.vma
ffffffffc02029cc:	100027f3          	csrr	a5,sstatus
ffffffffc02029d0:	8b89                	andi	a5,a5,2
ffffffffc02029d2:	28079a63          	bnez	a5,ffffffffc0202c66 <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029d6:	000b3783          	ld	a5,0(s6)
ffffffffc02029da:	779c                	ld	a5,40(a5)
ffffffffc02029dc:	9782                	jalr	a5
ffffffffc02029de:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02029e0:	4d441063          	bne	s0,s4,ffffffffc0202ea0 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029e4:	00003517          	auipc	a0,0x3
ffffffffc02029e8:	9cc50513          	addi	a0,a0,-1588 # ffffffffc02053b0 <etext+0x148a>
ffffffffc02029ec:	ef2fd0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc02029f0:	100027f3          	csrr	a5,sstatus
ffffffffc02029f4:	8b89                	andi	a5,a5,2
ffffffffc02029f6:	24079e63          	bnez	a5,ffffffffc0202c52 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029fa:	000b3783          	ld	a5,0(s6)
ffffffffc02029fe:	779c                	ld	a5,40(a5)
ffffffffc0202a00:	9782                	jalr	a5
ffffffffc0202a02:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a04:	609c                	ld	a5,0(s1)
ffffffffc0202a06:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a0a:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a0c:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a10:	6a85                	lui	s5,0x1
ffffffffc0202a12:	02e47c63          	bgeu	s0,a4,ffffffffc0202a4a <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a16:	00c45713          	srli	a4,s0,0xc
ffffffffc0202a1a:	30f77063          	bgeu	a4,a5,ffffffffc0202d1a <pmm_init+0x702>
ffffffffc0202a1e:	0009b583          	ld	a1,0(s3)
ffffffffc0202a22:	00093503          	ld	a0,0(s2)
ffffffffc0202a26:	4601                	li	a2,0
ffffffffc0202a28:	95a2                	add	a1,a1,s0
ffffffffc0202a2a:	faaff0ef          	jal	ffffffffc02021d4 <get_pte>
ffffffffc0202a2e:	32050363          	beqz	a0,ffffffffc0202d54 <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a32:	611c                	ld	a5,0(a0)
ffffffffc0202a34:	078a                	slli	a5,a5,0x2
ffffffffc0202a36:	0147f7b3          	and	a5,a5,s4
ffffffffc0202a3a:	2e879d63          	bne	a5,s0,ffffffffc0202d34 <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a3e:	609c                	ld	a5,0(s1)
ffffffffc0202a40:	9456                	add	s0,s0,s5
ffffffffc0202a42:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a46:	fce468e3          	bltu	s0,a4,ffffffffc0202a16 <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202a4a:	00093783          	ld	a5,0(s2)
ffffffffc0202a4e:	639c                	ld	a5,0(a5)
ffffffffc0202a50:	42079863          	bnez	a5,ffffffffc0202e80 <pmm_init+0x868>
ffffffffc0202a54:	100027f3          	csrr	a5,sstatus
ffffffffc0202a58:	8b89                	andi	a5,a5,2
ffffffffc0202a5a:	24079863          	bnez	a5,ffffffffc0202caa <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a5e:	000b3783          	ld	a5,0(s6)
ffffffffc0202a62:	4505                	li	a0,1
ffffffffc0202a64:	6f9c                	ld	a5,24(a5)
ffffffffc0202a66:	9782                	jalr	a5
ffffffffc0202a68:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a6a:	00093503          	ld	a0,0(s2)
ffffffffc0202a6e:	4699                	li	a3,6
ffffffffc0202a70:	10000613          	li	a2,256
ffffffffc0202a74:	85a2                	mv	a1,s0
ffffffffc0202a76:	aadff0ef          	jal	ffffffffc0202522 <page_insert>
ffffffffc0202a7a:	46051363          	bnez	a0,ffffffffc0202ee0 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202a7e:	4018                	lw	a4,0(s0)
ffffffffc0202a80:	4785                	li	a5,1
ffffffffc0202a82:	42f71f63          	bne	a4,a5,ffffffffc0202ec0 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a86:	00093503          	ld	a0,0(s2)
ffffffffc0202a8a:	6605                	lui	a2,0x1
ffffffffc0202a8c:	10060613          	addi	a2,a2,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202a90:	4699                	li	a3,6
ffffffffc0202a92:	85a2                	mv	a1,s0
ffffffffc0202a94:	a8fff0ef          	jal	ffffffffc0202522 <page_insert>
ffffffffc0202a98:	72051963          	bnez	a0,ffffffffc02031ca <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202a9c:	4018                	lw	a4,0(s0)
ffffffffc0202a9e:	4789                	li	a5,2
ffffffffc0202aa0:	70f71563          	bne	a4,a5,ffffffffc02031aa <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202aa4:	00003597          	auipc	a1,0x3
ffffffffc0202aa8:	a5458593          	addi	a1,a1,-1452 # ffffffffc02054f8 <etext+0x15d2>
ffffffffc0202aac:	10000513          	li	a0,256
ffffffffc0202ab0:	7c7000ef          	jal	ffffffffc0203a76 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ab4:	6585                	lui	a1,0x1
ffffffffc0202ab6:	10058593          	addi	a1,a1,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202aba:	10000513          	li	a0,256
ffffffffc0202abe:	7cb000ef          	jal	ffffffffc0203a88 <strcmp>
ffffffffc0202ac2:	6c051463          	bnez	a0,ffffffffc020318a <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202ac6:	000bb683          	ld	a3,0(s7)
ffffffffc0202aca:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202ace:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202ad0:	40d406b3          	sub	a3,s0,a3
ffffffffc0202ad4:	8699                	srai	a3,a3,0x6
ffffffffc0202ad6:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202ad8:	00c69793          	slli	a5,a3,0xc
ffffffffc0202adc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ade:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ae0:	32e7f463          	bgeu	a5,a4,ffffffffc0202e08 <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ae4:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ae8:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aec:	97b6                	add	a5,a5,a3
ffffffffc0202aee:	10078023          	sb	zero,256(a5) # 80100 <kern_entry-0xffffffffc017ff00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202af2:	751000ef          	jal	ffffffffc0203a42 <strlen>
ffffffffc0202af6:	66051a63          	bnez	a0,ffffffffc020316a <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202afa:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202afe:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b00:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fdf1b18>
ffffffffc0202b04:	078a                	slli	a5,a5,0x2
ffffffffc0202b06:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b08:	26e7f663          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b0c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202b10:	2ee7fc63          	bgeu	a5,a4,ffffffffc0202e08 <pmm_init+0x7f0>
ffffffffc0202b14:	0009b783          	ld	a5,0(s3)
ffffffffc0202b18:	00f689b3          	add	s3,a3,a5
ffffffffc0202b1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202b20:	8b89                	andi	a5,a5,2
ffffffffc0202b22:	1e079163          	bnez	a5,ffffffffc0202d04 <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202b26:	000b3783          	ld	a5,0(s6)
ffffffffc0202b2a:	8522                	mv	a0,s0
ffffffffc0202b2c:	4585                	li	a1,1
ffffffffc0202b2e:	739c                	ld	a5,32(a5)
ffffffffc0202b30:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b32:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202b36:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b38:	078a                	slli	a5,a5,0x2
ffffffffc0202b3a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b3c:	22e7fc63          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b40:	000bb503          	ld	a0,0(s7)
ffffffffc0202b44:	fe000737          	lui	a4,0xfe000
ffffffffc0202b48:	079a                	slli	a5,a5,0x6
ffffffffc0202b4a:	97ba                	add	a5,a5,a4
ffffffffc0202b4c:	953e                	add	a0,a0,a5
ffffffffc0202b4e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b52:	8b89                	andi	a5,a5,2
ffffffffc0202b54:	18079c63          	bnez	a5,ffffffffc0202cec <pmm_init+0x6d4>
ffffffffc0202b58:	000b3783          	ld	a5,0(s6)
ffffffffc0202b5c:	4585                	li	a1,1
ffffffffc0202b5e:	739c                	ld	a5,32(a5)
ffffffffc0202b60:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b62:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202b66:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b68:	078a                	slli	a5,a5,0x2
ffffffffc0202b6a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b6c:	20e7f463          	bgeu	a5,a4,ffffffffc0202d74 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b70:	000bb503          	ld	a0,0(s7)
ffffffffc0202b74:	fe000737          	lui	a4,0xfe000
ffffffffc0202b78:	079a                	slli	a5,a5,0x6
ffffffffc0202b7a:	97ba                	add	a5,a5,a4
ffffffffc0202b7c:	953e                	add	a0,a0,a5
ffffffffc0202b7e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b82:	8b89                	andi	a5,a5,2
ffffffffc0202b84:	14079863          	bnez	a5,ffffffffc0202cd4 <pmm_init+0x6bc>
ffffffffc0202b88:	000b3783          	ld	a5,0(s6)
ffffffffc0202b8c:	4585                	li	a1,1
ffffffffc0202b8e:	739c                	ld	a5,32(a5)
ffffffffc0202b90:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202b92:	00093783          	ld	a5,0(s2)
ffffffffc0202b96:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202b9a:	12000073          	sfence.vma
ffffffffc0202b9e:	100027f3          	csrr	a5,sstatus
ffffffffc0202ba2:	8b89                	andi	a5,a5,2
ffffffffc0202ba4:	10079e63          	bnez	a5,ffffffffc0202cc0 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ba8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bac:	779c                	ld	a5,40(a5)
ffffffffc0202bae:	9782                	jalr	a5
ffffffffc0202bb0:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202bb2:	1e8c1b63          	bne	s8,s0,ffffffffc0202da8 <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202bb6:	00003517          	auipc	a0,0x3
ffffffffc0202bba:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0205570 <etext+0x164a>
ffffffffc0202bbe:	d20fd0ef          	jal	ffffffffc02000de <cprintf>
}
ffffffffc0202bc2:	7406                	ld	s0,96(sp)
ffffffffc0202bc4:	70a6                	ld	ra,104(sp)
ffffffffc0202bc6:	64e6                	ld	s1,88(sp)
ffffffffc0202bc8:	6946                	ld	s2,80(sp)
ffffffffc0202bca:	69a6                	ld	s3,72(sp)
ffffffffc0202bcc:	6a06                	ld	s4,64(sp)
ffffffffc0202bce:	7ae2                	ld	s5,56(sp)
ffffffffc0202bd0:	7b42                	ld	s6,48(sp)
ffffffffc0202bd2:	7ba2                	ld	s7,40(sp)
ffffffffc0202bd4:	7c02                	ld	s8,32(sp)
ffffffffc0202bd6:	6ce2                	ld	s9,24(sp)
ffffffffc0202bd8:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202bda:	87ffe06f          	j	ffffffffc0201458 <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202bde:	853e                	mv	a0,a5
ffffffffc0202be0:	b4e1                	j	ffffffffc02026a8 <pmm_init+0x90>
        intr_disable();
ffffffffc0202be2:	c97fd0ef          	jal	ffffffffc0200878 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202be6:	000b3783          	ld	a5,0(s6)
ffffffffc0202bea:	4505                	li	a0,1
ffffffffc0202bec:	6f9c                	ld	a5,24(a5)
ffffffffc0202bee:	9782                	jalr	a5
ffffffffc0202bf0:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202bf2:	c81fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202bf6:	be75                	j	ffffffffc02027b2 <pmm_init+0x19a>
        intr_disable();
ffffffffc0202bf8:	c81fd0ef          	jal	ffffffffc0200878 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bfc:	000b3783          	ld	a5,0(s6)
ffffffffc0202c00:	779c                	ld	a5,40(a5)
ffffffffc0202c02:	9782                	jalr	a5
ffffffffc0202c04:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c06:	c6dfd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202c0a:	b6ad                	j	ffffffffc0202774 <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c0c:	6705                	lui	a4,0x1
ffffffffc0202c0e:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0202c10:	96ba                	add	a3,a3,a4
ffffffffc0202c12:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202c14:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202c18:	14a77e63          	bgeu	a4,a0,ffffffffc0202d74 <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202c1c:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c20:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202c22:	071a                	slli	a4,a4,0x6
ffffffffc0202c24:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202c28:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202c2a:	6a9c                	ld	a5,16(a3)
ffffffffc0202c2c:	00c45593          	srli	a1,s0,0xc
ffffffffc0202c30:	00e60533          	add	a0,a2,a4
ffffffffc0202c34:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202c36:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202c3a:	bcf1                	j	ffffffffc0202716 <pmm_init+0xfe>
        intr_disable();
ffffffffc0202c3c:	c3dfd0ef          	jal	ffffffffc0200878 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c40:	000b3783          	ld	a5,0(s6)
ffffffffc0202c44:	4505                	li	a0,1
ffffffffc0202c46:	6f9c                	ld	a5,24(a5)
ffffffffc0202c48:	9782                	jalr	a5
ffffffffc0202c4a:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202c4c:	c27fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202c50:	b119                	j	ffffffffc0202856 <pmm_init+0x23e>
        intr_disable();
ffffffffc0202c52:	c27fd0ef          	jal	ffffffffc0200878 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c56:	000b3783          	ld	a5,0(s6)
ffffffffc0202c5a:	779c                	ld	a5,40(a5)
ffffffffc0202c5c:	9782                	jalr	a5
ffffffffc0202c5e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202c60:	c13fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202c64:	b345                	j	ffffffffc0202a04 <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202c66:	c13fd0ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0202c6a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c6e:	779c                	ld	a5,40(a5)
ffffffffc0202c70:	9782                	jalr	a5
ffffffffc0202c72:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202c74:	bfffd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202c78:	b3a5                	j	ffffffffc02029e0 <pmm_init+0x3c8>
ffffffffc0202c7a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202c7c:	bfdfd0ef          	jal	ffffffffc0200878 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202c80:	000b3783          	ld	a5,0(s6)
ffffffffc0202c84:	6522                	ld	a0,8(sp)
ffffffffc0202c86:	4585                	li	a1,1
ffffffffc0202c88:	739c                	ld	a5,32(a5)
ffffffffc0202c8a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202c8c:	be7fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202c90:	bb05                	j	ffffffffc02029c0 <pmm_init+0x3a8>
ffffffffc0202c92:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202c94:	be5fd0ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0202c98:	000b3783          	ld	a5,0(s6)
ffffffffc0202c9c:	6522                	ld	a0,8(sp)
ffffffffc0202c9e:	4585                	li	a1,1
ffffffffc0202ca0:	739c                	ld	a5,32(a5)
ffffffffc0202ca2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ca4:	bcffd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202ca8:	b1e5                	j	ffffffffc0202990 <pmm_init+0x378>
        intr_disable();
ffffffffc0202caa:	bcffd0ef          	jal	ffffffffc0200878 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202cae:	000b3783          	ld	a5,0(s6)
ffffffffc0202cb2:	4505                	li	a0,1
ffffffffc0202cb4:	6f9c                	ld	a5,24(a5)
ffffffffc0202cb6:	9782                	jalr	a5
ffffffffc0202cb8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202cba:	bb9fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202cbe:	b375                	j	ffffffffc0202a6a <pmm_init+0x452>
        intr_disable();
ffffffffc0202cc0:	bb9fd0ef          	jal	ffffffffc0200878 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cc4:	000b3783          	ld	a5,0(s6)
ffffffffc0202cc8:	779c                	ld	a5,40(a5)
ffffffffc0202cca:	9782                	jalr	a5
ffffffffc0202ccc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202cce:	ba5fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202cd2:	b5c5                	j	ffffffffc0202bb2 <pmm_init+0x59a>
ffffffffc0202cd4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cd6:	ba3fd0ef          	jal	ffffffffc0200878 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202cda:	000b3783          	ld	a5,0(s6)
ffffffffc0202cde:	6522                	ld	a0,8(sp)
ffffffffc0202ce0:	4585                	li	a1,1
ffffffffc0202ce2:	739c                	ld	a5,32(a5)
ffffffffc0202ce4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ce6:	b8dfd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202cea:	b565                	j	ffffffffc0202b92 <pmm_init+0x57a>
ffffffffc0202cec:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cee:	b8bfd0ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0202cf2:	000b3783          	ld	a5,0(s6)
ffffffffc0202cf6:	6522                	ld	a0,8(sp)
ffffffffc0202cf8:	4585                	li	a1,1
ffffffffc0202cfa:	739c                	ld	a5,32(a5)
ffffffffc0202cfc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202cfe:	b75fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202d02:	b585                	j	ffffffffc0202b62 <pmm_init+0x54a>
        intr_disable();
ffffffffc0202d04:	b75fd0ef          	jal	ffffffffc0200878 <intr_disable>
ffffffffc0202d08:	000b3783          	ld	a5,0(s6)
ffffffffc0202d0c:	8522                	mv	a0,s0
ffffffffc0202d0e:	4585                	li	a1,1
ffffffffc0202d10:	739c                	ld	a5,32(a5)
ffffffffc0202d12:	9782                	jalr	a5
        intr_enable();
ffffffffc0202d14:	b5ffd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0202d18:	bd29                	j	ffffffffc0202b32 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d1a:	86a2                	mv	a3,s0
ffffffffc0202d1c:	00002617          	auipc	a2,0x2
ffffffffc0202d20:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204b28 <etext+0xc02>
ffffffffc0202d24:	1a400593          	li	a1,420
ffffffffc0202d28:	00002517          	auipc	a0,0x2
ffffffffc0202d2c:	29850513          	addi	a0,a0,664 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202d30:	caafd0ef          	jal	ffffffffc02001da <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d34:	00002697          	auipc	a3,0x2
ffffffffc0202d38:	6dc68693          	addi	a3,a3,1756 # ffffffffc0205410 <etext+0x14ea>
ffffffffc0202d3c:	00002617          	auipc	a2,0x2
ffffffffc0202d40:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202d44:	1a500593          	li	a1,421
ffffffffc0202d48:	00002517          	auipc	a0,0x2
ffffffffc0202d4c:	27850513          	addi	a0,a0,632 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202d50:	c8afd0ef          	jal	ffffffffc02001da <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d54:	00002697          	auipc	a3,0x2
ffffffffc0202d58:	67c68693          	addi	a3,a3,1660 # ffffffffc02053d0 <etext+0x14aa>
ffffffffc0202d5c:	00002617          	auipc	a2,0x2
ffffffffc0202d60:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202d64:	1a400593          	li	a1,420
ffffffffc0202d68:	00002517          	auipc	a0,0x2
ffffffffc0202d6c:	25850513          	addi	a0,a0,600 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202d70:	c6afd0ef          	jal	ffffffffc02001da <__panic>
ffffffffc0202d74:	b9cff0ef          	jal	ffffffffc0202110 <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc0202d78:	00002617          	auipc	a2,0x2
ffffffffc0202d7c:	3f860613          	addi	a2,a2,1016 # ffffffffc0205170 <etext+0x124a>
ffffffffc0202d80:	07f00593          	li	a1,127
ffffffffc0202d84:	00002517          	auipc	a0,0x2
ffffffffc0202d88:	dcc50513          	addi	a0,a0,-564 # ffffffffc0204b50 <etext+0xc2a>
ffffffffc0202d8c:	c4efd0ef          	jal	ffffffffc02001da <__panic>
        panic("DTB memory info not available");
ffffffffc0202d90:	00002617          	auipc	a2,0x2
ffffffffc0202d94:	25860613          	addi	a2,a2,600 # ffffffffc0204fe8 <etext+0x10c2>
ffffffffc0202d98:	06400593          	li	a1,100
ffffffffc0202d9c:	00002517          	auipc	a0,0x2
ffffffffc0202da0:	22450513          	addi	a0,a0,548 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202da4:	c36fd0ef          	jal	ffffffffc02001da <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202da8:	00002697          	auipc	a3,0x2
ffffffffc0202dac:	5e068693          	addi	a3,a3,1504 # ffffffffc0205388 <etext+0x1462>
ffffffffc0202db0:	00002617          	auipc	a2,0x2
ffffffffc0202db4:	b5860613          	addi	a2,a2,-1192 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202db8:	1bf00593          	li	a1,447
ffffffffc0202dbc:	00002517          	auipc	a0,0x2
ffffffffc0202dc0:	20450513          	addi	a0,a0,516 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202dc4:	c16fd0ef          	jal	ffffffffc02001da <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202dc8:	00002697          	auipc	a3,0x2
ffffffffc0202dcc:	2d868693          	addi	a3,a3,728 # ffffffffc02050a0 <etext+0x117a>
ffffffffc0202dd0:	00002617          	auipc	a2,0x2
ffffffffc0202dd4:	b3860613          	addi	a2,a2,-1224 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202dd8:	16600593          	li	a1,358
ffffffffc0202ddc:	00002517          	auipc	a0,0x2
ffffffffc0202de0:	1e450513          	addi	a0,a0,484 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202de4:	bf6fd0ef          	jal	ffffffffc02001da <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202de8:	00002697          	auipc	a3,0x2
ffffffffc0202dec:	29868693          	addi	a3,a3,664 # ffffffffc0205080 <etext+0x115a>
ffffffffc0202df0:	00002617          	auipc	a2,0x2
ffffffffc0202df4:	b1860613          	addi	a2,a2,-1256 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202df8:	16500593          	li	a1,357
ffffffffc0202dfc:	00002517          	auipc	a0,0x2
ffffffffc0202e00:	1c450513          	addi	a0,a0,452 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202e04:	bd6fd0ef          	jal	ffffffffc02001da <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e08:	00002617          	auipc	a2,0x2
ffffffffc0202e0c:	d2060613          	addi	a2,a2,-736 # ffffffffc0204b28 <etext+0xc02>
ffffffffc0202e10:	07100593          	li	a1,113
ffffffffc0202e14:	00002517          	auipc	a0,0x2
ffffffffc0202e18:	d3c50513          	addi	a0,a0,-708 # ffffffffc0204b50 <etext+0xc2a>
ffffffffc0202e1c:	bbefd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202e20:	00002697          	auipc	a3,0x2
ffffffffc0202e24:	53868693          	addi	a3,a3,1336 # ffffffffc0205358 <etext+0x1432>
ffffffffc0202e28:	00002617          	auipc	a2,0x2
ffffffffc0202e2c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202e30:	18d00593          	li	a1,397
ffffffffc0202e34:	00002517          	auipc	a0,0x2
ffffffffc0202e38:	18c50513          	addi	a0,a0,396 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202e3c:	b9efd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e40:	00002697          	auipc	a3,0x2
ffffffffc0202e44:	4d068693          	addi	a3,a3,1232 # ffffffffc0205310 <etext+0x13ea>
ffffffffc0202e48:	00002617          	auipc	a2,0x2
ffffffffc0202e4c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202e50:	18b00593          	li	a1,395
ffffffffc0202e54:	00002517          	auipc	a0,0x2
ffffffffc0202e58:	16c50513          	addi	a0,a0,364 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202e5c:	b7efd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e60:	00002697          	auipc	a3,0x2
ffffffffc0202e64:	4e068693          	addi	a3,a3,1248 # ffffffffc0205340 <etext+0x141a>
ffffffffc0202e68:	00002617          	auipc	a2,0x2
ffffffffc0202e6c:	aa060613          	addi	a2,a2,-1376 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202e70:	18a00593          	li	a1,394
ffffffffc0202e74:	00002517          	auipc	a0,0x2
ffffffffc0202e78:	14c50513          	addi	a0,a0,332 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202e7c:	b5efd0ef          	jal	ffffffffc02001da <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202e80:	00002697          	auipc	a3,0x2
ffffffffc0202e84:	5a868693          	addi	a3,a3,1448 # ffffffffc0205428 <etext+0x1502>
ffffffffc0202e88:	00002617          	auipc	a2,0x2
ffffffffc0202e8c:	a8060613          	addi	a2,a2,-1408 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202e90:	1a800593          	li	a1,424
ffffffffc0202e94:	00002517          	auipc	a0,0x2
ffffffffc0202e98:	12c50513          	addi	a0,a0,300 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202e9c:	b3efd0ef          	jal	ffffffffc02001da <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202ea0:	00002697          	auipc	a3,0x2
ffffffffc0202ea4:	4e868693          	addi	a3,a3,1256 # ffffffffc0205388 <etext+0x1462>
ffffffffc0202ea8:	00002617          	auipc	a2,0x2
ffffffffc0202eac:	a6060613          	addi	a2,a2,-1440 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202eb0:	19500593          	li	a1,405
ffffffffc0202eb4:	00002517          	auipc	a0,0x2
ffffffffc0202eb8:	10c50513          	addi	a0,a0,268 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202ebc:	b1efd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ec0:	00002697          	auipc	a3,0x2
ffffffffc0202ec4:	5c068693          	addi	a3,a3,1472 # ffffffffc0205480 <etext+0x155a>
ffffffffc0202ec8:	00002617          	auipc	a2,0x2
ffffffffc0202ecc:	a4060613          	addi	a2,a2,-1472 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202ed0:	1ad00593          	li	a1,429
ffffffffc0202ed4:	00002517          	auipc	a0,0x2
ffffffffc0202ed8:	0ec50513          	addi	a0,a0,236 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202edc:	afefd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202ee0:	00002697          	auipc	a3,0x2
ffffffffc0202ee4:	56068693          	addi	a3,a3,1376 # ffffffffc0205440 <etext+0x151a>
ffffffffc0202ee8:	00002617          	auipc	a2,0x2
ffffffffc0202eec:	a2060613          	addi	a2,a2,-1504 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202ef0:	1ac00593          	li	a1,428
ffffffffc0202ef4:	00002517          	auipc	a0,0x2
ffffffffc0202ef8:	0cc50513          	addi	a0,a0,204 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202efc:	adefd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f00:	00002697          	auipc	a3,0x2
ffffffffc0202f04:	41068693          	addi	a3,a3,1040 # ffffffffc0205310 <etext+0x13ea>
ffffffffc0202f08:	00002617          	auipc	a2,0x2
ffffffffc0202f0c:	a0060613          	addi	a2,a2,-1536 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202f10:	18700593          	li	a1,391
ffffffffc0202f14:	00002517          	auipc	a0,0x2
ffffffffc0202f18:	0ac50513          	addi	a0,a0,172 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202f1c:	abefd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f20:	00002697          	auipc	a3,0x2
ffffffffc0202f24:	29068693          	addi	a3,a3,656 # ffffffffc02051b0 <etext+0x128a>
ffffffffc0202f28:	00002617          	auipc	a2,0x2
ffffffffc0202f2c:	9e060613          	addi	a2,a2,-1568 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202f30:	18600593          	li	a1,390
ffffffffc0202f34:	00002517          	auipc	a0,0x2
ffffffffc0202f38:	08c50513          	addi	a0,a0,140 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202f3c:	a9efd0ef          	jal	ffffffffc02001da <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202f40:	00002697          	auipc	a3,0x2
ffffffffc0202f44:	3e868693          	addi	a3,a3,1000 # ffffffffc0205328 <etext+0x1402>
ffffffffc0202f48:	00002617          	auipc	a2,0x2
ffffffffc0202f4c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202f50:	18300593          	li	a1,387
ffffffffc0202f54:	00002517          	auipc	a0,0x2
ffffffffc0202f58:	06c50513          	addi	a0,a0,108 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202f5c:	a7efd0ef          	jal	ffffffffc02001da <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f60:	00002697          	auipc	a3,0x2
ffffffffc0202f64:	23868693          	addi	a3,a3,568 # ffffffffc0205198 <etext+0x1272>
ffffffffc0202f68:	00002617          	auipc	a2,0x2
ffffffffc0202f6c:	9a060613          	addi	a2,a2,-1632 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202f70:	18200593          	li	a1,386
ffffffffc0202f74:	00002517          	auipc	a0,0x2
ffffffffc0202f78:	04c50513          	addi	a0,a0,76 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202f7c:	a5efd0ef          	jal	ffffffffc02001da <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202f80:	00002697          	auipc	a3,0x2
ffffffffc0202f84:	2b868693          	addi	a3,a3,696 # ffffffffc0205238 <etext+0x1312>
ffffffffc0202f88:	00002617          	auipc	a2,0x2
ffffffffc0202f8c:	98060613          	addi	a2,a2,-1664 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202f90:	18100593          	li	a1,385
ffffffffc0202f94:	00002517          	auipc	a0,0x2
ffffffffc0202f98:	02c50513          	addi	a0,a0,44 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202f9c:	a3efd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fa0:	00002697          	auipc	a3,0x2
ffffffffc0202fa4:	37068693          	addi	a3,a3,880 # ffffffffc0205310 <etext+0x13ea>
ffffffffc0202fa8:	00002617          	auipc	a2,0x2
ffffffffc0202fac:	96060613          	addi	a2,a2,-1696 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202fb0:	18000593          	li	a1,384
ffffffffc0202fb4:	00002517          	auipc	a0,0x2
ffffffffc0202fb8:	00c50513          	addi	a0,a0,12 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202fbc:	a1efd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202fc0:	00002697          	auipc	a3,0x2
ffffffffc0202fc4:	33868693          	addi	a3,a3,824 # ffffffffc02052f8 <etext+0x13d2>
ffffffffc0202fc8:	00002617          	auipc	a2,0x2
ffffffffc0202fcc:	94060613          	addi	a2,a2,-1728 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202fd0:	17f00593          	li	a1,383
ffffffffc0202fd4:	00002517          	auipc	a0,0x2
ffffffffc0202fd8:	fec50513          	addi	a0,a0,-20 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202fdc:	9fefd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202fe0:	00002697          	auipc	a3,0x2
ffffffffc0202fe4:	2e868693          	addi	a3,a3,744 # ffffffffc02052c8 <etext+0x13a2>
ffffffffc0202fe8:	00002617          	auipc	a2,0x2
ffffffffc0202fec:	92060613          	addi	a2,a2,-1760 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0202ff0:	17e00593          	li	a1,382
ffffffffc0202ff4:	00002517          	auipc	a0,0x2
ffffffffc0202ff8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0202ffc:	9defd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203000:	00002697          	auipc	a3,0x2
ffffffffc0203004:	2b068693          	addi	a3,a3,688 # ffffffffc02052b0 <etext+0x138a>
ffffffffc0203008:	00002617          	auipc	a2,0x2
ffffffffc020300c:	90060613          	addi	a2,a2,-1792 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203010:	17c00593          	li	a1,380
ffffffffc0203014:	00002517          	auipc	a0,0x2
ffffffffc0203018:	fac50513          	addi	a0,a0,-84 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020301c:	9befd0ef          	jal	ffffffffc02001da <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203020:	00002697          	auipc	a3,0x2
ffffffffc0203024:	27068693          	addi	a3,a3,624 # ffffffffc0205290 <etext+0x136a>
ffffffffc0203028:	00002617          	auipc	a2,0x2
ffffffffc020302c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203030:	17b00593          	li	a1,379
ffffffffc0203034:	00002517          	auipc	a0,0x2
ffffffffc0203038:	f8c50513          	addi	a0,a0,-116 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020303c:	99efd0ef          	jal	ffffffffc02001da <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203040:	00002697          	auipc	a3,0x2
ffffffffc0203044:	24068693          	addi	a3,a3,576 # ffffffffc0205280 <etext+0x135a>
ffffffffc0203048:	00002617          	auipc	a2,0x2
ffffffffc020304c:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203050:	17a00593          	li	a1,378
ffffffffc0203054:	00002517          	auipc	a0,0x2
ffffffffc0203058:	f6c50513          	addi	a0,a0,-148 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020305c:	97efd0ef          	jal	ffffffffc02001da <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203060:	00002697          	auipc	a3,0x2
ffffffffc0203064:	21068693          	addi	a3,a3,528 # ffffffffc0205270 <etext+0x134a>
ffffffffc0203068:	00002617          	auipc	a2,0x2
ffffffffc020306c:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203070:	17900593          	li	a1,377
ffffffffc0203074:	00002517          	auipc	a0,0x2
ffffffffc0203078:	f4c50513          	addi	a0,a0,-180 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020307c:	95efd0ef          	jal	ffffffffc02001da <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203080:	00002617          	auipc	a2,0x2
ffffffffc0203084:	b5060613          	addi	a2,a2,-1200 # ffffffffc0204bd0 <etext+0xcaa>
ffffffffc0203088:	08000593          	li	a1,128
ffffffffc020308c:	00002517          	auipc	a0,0x2
ffffffffc0203090:	f3450513          	addi	a0,a0,-204 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0203094:	946fd0ef          	jal	ffffffffc02001da <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203098:	00002697          	auipc	a3,0x2
ffffffffc020309c:	13068693          	addi	a3,a3,304 # ffffffffc02051c8 <etext+0x12a2>
ffffffffc02030a0:	00002617          	auipc	a2,0x2
ffffffffc02030a4:	86860613          	addi	a2,a2,-1944 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02030a8:	17400593          	li	a1,372
ffffffffc02030ac:	00002517          	auipc	a0,0x2
ffffffffc02030b0:	f1450513          	addi	a0,a0,-236 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02030b4:	926fd0ef          	jal	ffffffffc02001da <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02030b8:	00002697          	auipc	a3,0x2
ffffffffc02030bc:	18068693          	addi	a3,a3,384 # ffffffffc0205238 <etext+0x1312>
ffffffffc02030c0:	00002617          	auipc	a2,0x2
ffffffffc02030c4:	84860613          	addi	a2,a2,-1976 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02030c8:	17800593          	li	a1,376
ffffffffc02030cc:	00002517          	auipc	a0,0x2
ffffffffc02030d0:	ef450513          	addi	a0,a0,-268 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02030d4:	906fd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02030d8:	00002697          	auipc	a3,0x2
ffffffffc02030dc:	12068693          	addi	a3,a3,288 # ffffffffc02051f8 <etext+0x12d2>
ffffffffc02030e0:	00002617          	auipc	a2,0x2
ffffffffc02030e4:	82860613          	addi	a2,a2,-2008 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02030e8:	17700593          	li	a1,375
ffffffffc02030ec:	00002517          	auipc	a0,0x2
ffffffffc02030f0:	ed450513          	addi	a0,a0,-300 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02030f4:	8e6fd0ef          	jal	ffffffffc02001da <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030f8:	86d6                	mv	a3,s5
ffffffffc02030fa:	00002617          	auipc	a2,0x2
ffffffffc02030fe:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204b28 <etext+0xc02>
ffffffffc0203102:	17300593          	li	a1,371
ffffffffc0203106:	00002517          	auipc	a0,0x2
ffffffffc020310a:	eba50513          	addi	a0,a0,-326 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020310e:	8ccfd0ef          	jal	ffffffffc02001da <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203112:	00002617          	auipc	a2,0x2
ffffffffc0203116:	a1660613          	addi	a2,a2,-1514 # ffffffffc0204b28 <etext+0xc02>
ffffffffc020311a:	17200593          	li	a1,370
ffffffffc020311e:	00002517          	auipc	a0,0x2
ffffffffc0203122:	ea250513          	addi	a0,a0,-350 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0203126:	8b4fd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020312a:	00002697          	auipc	a3,0x2
ffffffffc020312e:	08668693          	addi	a3,a3,134 # ffffffffc02051b0 <etext+0x128a>
ffffffffc0203132:	00001617          	auipc	a2,0x1
ffffffffc0203136:	7d660613          	addi	a2,a2,2006 # ffffffffc0204908 <etext+0x9e2>
ffffffffc020313a:	17000593          	li	a1,368
ffffffffc020313e:	00002517          	auipc	a0,0x2
ffffffffc0203142:	e8250513          	addi	a0,a0,-382 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0203146:	894fd0ef          	jal	ffffffffc02001da <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020314a:	00002697          	auipc	a3,0x2
ffffffffc020314e:	04e68693          	addi	a3,a3,78 # ffffffffc0205198 <etext+0x1272>
ffffffffc0203152:	00001617          	auipc	a2,0x1
ffffffffc0203156:	7b660613          	addi	a2,a2,1974 # ffffffffc0204908 <etext+0x9e2>
ffffffffc020315a:	16f00593          	li	a1,367
ffffffffc020315e:	00002517          	auipc	a0,0x2
ffffffffc0203162:	e6250513          	addi	a0,a0,-414 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0203166:	874fd0ef          	jal	ffffffffc02001da <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020316a:	00002697          	auipc	a3,0x2
ffffffffc020316e:	3de68693          	addi	a3,a3,990 # ffffffffc0205548 <etext+0x1622>
ffffffffc0203172:	00001617          	auipc	a2,0x1
ffffffffc0203176:	79660613          	addi	a2,a2,1942 # ffffffffc0204908 <etext+0x9e2>
ffffffffc020317a:	1b600593          	li	a1,438
ffffffffc020317e:	00002517          	auipc	a0,0x2
ffffffffc0203182:	e4250513          	addi	a0,a0,-446 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0203186:	854fd0ef          	jal	ffffffffc02001da <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020318a:	00002697          	auipc	a3,0x2
ffffffffc020318e:	38668693          	addi	a3,a3,902 # ffffffffc0205510 <etext+0x15ea>
ffffffffc0203192:	00001617          	auipc	a2,0x1
ffffffffc0203196:	77660613          	addi	a2,a2,1910 # ffffffffc0204908 <etext+0x9e2>
ffffffffc020319a:	1b300593          	li	a1,435
ffffffffc020319e:	00002517          	auipc	a0,0x2
ffffffffc02031a2:	e2250513          	addi	a0,a0,-478 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02031a6:	834fd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_ref(p) == 2);
ffffffffc02031aa:	00002697          	auipc	a3,0x2
ffffffffc02031ae:	33668693          	addi	a3,a3,822 # ffffffffc02054e0 <etext+0x15ba>
ffffffffc02031b2:	00001617          	auipc	a2,0x1
ffffffffc02031b6:	75660613          	addi	a2,a2,1878 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02031ba:	1af00593          	li	a1,431
ffffffffc02031be:	00002517          	auipc	a0,0x2
ffffffffc02031c2:	e0250513          	addi	a0,a0,-510 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02031c6:	814fd0ef          	jal	ffffffffc02001da <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02031ca:	00002697          	auipc	a3,0x2
ffffffffc02031ce:	2ce68693          	addi	a3,a3,718 # ffffffffc0205498 <etext+0x1572>
ffffffffc02031d2:	00001617          	auipc	a2,0x1
ffffffffc02031d6:	73660613          	addi	a2,a2,1846 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02031da:	1ae00593          	li	a1,430
ffffffffc02031de:	00002517          	auipc	a0,0x2
ffffffffc02031e2:	de250513          	addi	a0,a0,-542 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc02031e6:	ff5fc0ef          	jal	ffffffffc02001da <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02031ea:	00002697          	auipc	a3,0x2
ffffffffc02031ee:	ef668693          	addi	a3,a3,-266 # ffffffffc02050e0 <etext+0x11ba>
ffffffffc02031f2:	00001617          	auipc	a2,0x1
ffffffffc02031f6:	71660613          	addi	a2,a2,1814 # ffffffffc0204908 <etext+0x9e2>
ffffffffc02031fa:	16700593          	li	a1,359
ffffffffc02031fe:	00002517          	auipc	a0,0x2
ffffffffc0203202:	dc250513          	addi	a0,a0,-574 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc0203206:	fd5fc0ef          	jal	ffffffffc02001da <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020320a:	00002617          	auipc	a2,0x2
ffffffffc020320e:	9c660613          	addi	a2,a2,-1594 # ffffffffc0204bd0 <etext+0xcaa>
ffffffffc0203212:	0cb00593          	li	a1,203
ffffffffc0203216:	00002517          	auipc	a0,0x2
ffffffffc020321a:	daa50513          	addi	a0,a0,-598 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020321e:	fbdfc0ef          	jal	ffffffffc02001da <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203222:	00002697          	auipc	a3,0x2
ffffffffc0203226:	f1e68693          	addi	a3,a3,-226 # ffffffffc0205140 <etext+0x121a>
ffffffffc020322a:	00001617          	auipc	a2,0x1
ffffffffc020322e:	6de60613          	addi	a2,a2,1758 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203232:	16e00593          	li	a1,366
ffffffffc0203236:	00002517          	auipc	a0,0x2
ffffffffc020323a:	d8a50513          	addi	a0,a0,-630 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020323e:	f9dfc0ef          	jal	ffffffffc02001da <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203242:	00002697          	auipc	a3,0x2
ffffffffc0203246:	ece68693          	addi	a3,a3,-306 # ffffffffc0205110 <etext+0x11ea>
ffffffffc020324a:	00001617          	auipc	a2,0x1
ffffffffc020324e:	6be60613          	addi	a2,a2,1726 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203252:	16b00593          	li	a1,363
ffffffffc0203256:	00002517          	auipc	a0,0x2
ffffffffc020325a:	d6a50513          	addi	a0,a0,-662 # ffffffffc0204fc0 <etext+0x109a>
ffffffffc020325e:	f7dfc0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0203262 <switch_to>:
switch_to:
    # ========== 保存当前进程(from)的上下文 ==========
    # 将当前CPU中的寄存器值保存到from->context结构体中

    # 保存返回地址寄存器 (context.ra)
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203262:	00153023          	sd	ra,0(a0)

    # 保存栈指针寄存器 (context.sp)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203266:	00253423          	sd	sp,8(a0)

    # 保存保存寄存器s0-s11 (context.s0 ~ context.s11)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020326a:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020326c:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020326e:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203272:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203276:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020327a:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020327e:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203282:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203286:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020328a:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020328e:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203292:	07b53423          	sd	s11,104(a0)

    # ========== 恢复目标进程(to)的上下文 ==========
    # 从to->context结构体中恢复寄存器值到CPU

    # 恢复返回地址寄存器
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203296:	0005b083          	ld	ra,0(a1)

    # 恢复栈指针寄存器
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020329a:	0085b103          	ld	sp,8(a1)

    # 恢复保存寄存器s0-s11
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020329e:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02032a0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02032a2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02032a6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02032aa:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02032ae:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02032b2:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02032b6:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02032ba:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02032be:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02032c2:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02032c6:	0685bd83          	ld	s11,104(a1)

    # ========== 返回到目标进程 ==========
    # ret指令相当于"jalr x0, ra, 0"，跳转到ra指向的地址
    # 对于目标进程，ra指向了切换发生前的执行点
    ret
ffffffffc02032ca:	8082                	ret

ffffffffc02032cc <kernel_thread_entry>:
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

	# ========== 设置函数参数 ==========
	# 将s1寄存器中的参数移动到a0（第一个参数寄存器）
	move a0, s1
ffffffffc02032cc:	8526                	mv	a0,s1

	# ========== 调用线程函数 ==========
	# 跳转到s0寄存器中保存的函数地址
	# jalr指令会将返回地址保存到ra寄存器
	jalr s0
ffffffffc02032ce:	9402                	jalr	s0

	# ========== 线程函数返回，终止线程 ==========
	# 线程函数执行完毕，调用do_exit终止当前线程
	# 传递退出码0表示正常退出
	jal do_exit
ffffffffc02032d0:	41c000ef          	jal	ffffffffc02036ec <do_exit>

ffffffffc02032d4 <alloc_proc>:
 * - list_link: 进程链表节点，初始化为空链表
 * - hash_link: 哈希链表节点，初始化为空链表
 * ===================================================================== */
static struct proc_struct *
alloc_proc(void)
{
ffffffffc02032d4:	1141                	addi	sp,sp,-16
    // 从内核堆中分配进程结构体内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02032d6:	0e800513          	li	a0,232
{
ffffffffc02032da:	e022                	sd	s0,0(sp)
ffffffffc02032dc:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02032de:	99afe0ef          	jal	ffffffffc0201478 <kmalloc>
ffffffffc02032e2:	842a                	mv	s0,a0

    if (proc != NULL)
ffffffffc02032e4:	cd21                	beqz	a0,ffffffffc020333c <alloc_proc+0x68>
    {
        // LAB4:EXERCISE1 - 进程结构体字段初始化
        // 以下字段需要按照规范进行初始化：

        // ========== 进程状态和标识 ==========
        proc->state = PROC_UNINIT;          // 进程状态：未初始化
ffffffffc02032e6:	57fd                	li	a5,-1
ffffffffc02032e8:	1782                	slli	a5,a5,0x20
ffffffffc02032ea:	e11c                	sd	a5,0(a0)
        proc->pid = -1;                     // 进程ID：无效值，待分配
        proc->runs = 0;                     // 运行次数计数器：初始为0

        // ========== 内存管理相关 ==========
        proc->kstack = 0;                   // 内核栈地址：待分配
        proc->pgdir = boot_pgdir_pa;        // 页目录：使用引导时的页目录
ffffffffc02032ec:	0000a797          	auipc	a5,0xa
ffffffffc02032f0:	1b47b783          	ld	a5,436(a5) # ffffffffc020d4a0 <boot_pgdir_pa>
        proc->runs = 0;                     // 运行次数计数器：初始为0
ffffffffc02032f4:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                   // 内核栈地址：待分配
ffffffffc02032f8:	00053823          	sd	zero,16(a0)
        proc->pgdir = boot_pgdir_pa;        // 页目录：使用引导时的页目录
ffffffffc02032fc:	ed1c                	sd	a5,24(a0)

        // ========== 调度相关 ==========
        proc->need_resched = 0;             // 重新调度标志：不需要
ffffffffc02032fe:	02052023          	sw	zero,32(a0)

        // ========== 进程关系 ==========
        proc->parent = NULL;                // 父进程：无
ffffffffc0203302:	02053423          	sd	zero,40(a0)
        proc->mm = NULL;                    // 内存管理结构体：lab4中未使用
ffffffffc0203306:	02053823          	sd	zero,48(a0)

        // ========== 执行上下文 ==========
        memset(&(proc->context), 0, sizeof(struct context)); // 上下文清零
ffffffffc020330a:	07000613          	li	a2,112
ffffffffc020330e:	4581                	li	a1,0
ffffffffc0203310:	03850513          	addi	a0,a0,56
ffffffffc0203314:	7e2000ef          	jal	ffffffffc0203af6 <memset>
        proc->tf = NULL;                    // trapframe：无

        // ========== 标志和属性 ==========
        proc->flags = 0;                    // 进程标志：无特殊标志
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空
ffffffffc0203318:	0b440513          	addi	a0,s0,180 # ffffffffc02000b4 <cputch+0xe>
        proc->tf = NULL;                    // trapframe：无
ffffffffc020331c:	0a043423          	sd	zero,168(s0)
        proc->flags = 0;                    // 进程标志：无特殊标志
ffffffffc0203320:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空
ffffffffc0203324:	4641                	li	a2,16
ffffffffc0203326:	4581                	li	a1,0
ffffffffc0203328:	7ce000ef          	jal	ffffffffc0203af6 <memset>

        // ========== 链表节点初始化 ==========
        list_init(&(proc->list_link));      // 进程链表节点初始化
ffffffffc020332c:	0c840713          	addi	a4,s0,200
        list_init(&(proc->hash_link));      // 哈希链表节点初始化
ffffffffc0203330:	0d840793          	addi	a5,s0,216
    elm->prev = elm->next = elm;
ffffffffc0203334:	e878                	sd	a4,208(s0)
ffffffffc0203336:	e478                	sd	a4,200(s0)
ffffffffc0203338:	f07c                	sd	a5,224(s0)
ffffffffc020333a:	ec7c                	sd	a5,216(s0)
    }

    return proc;
}
ffffffffc020333c:	60a2                	ld	ra,8(sp)
ffffffffc020333e:	8522                	mv	a0,s0
ffffffffc0203340:	6402                	ld	s0,0(sp)
ffffffffc0203342:	0141                	addi	sp,sp,16
ffffffffc0203344:	8082                	ret

ffffffffc0203346 <forkret>:
static void
forkret(void)
{
    // 调用forkrets恢复trapframe并返回
    // current->tf是在copy_thread中设置的trapframe
    forkrets(current->tf);
ffffffffc0203346:	0000a797          	auipc	a5,0xa
ffffffffc020334a:	18a7b783          	ld	a5,394(a5) # ffffffffc020d4d0 <current>
ffffffffc020334e:	77c8                	ld	a0,168(a5)
ffffffffc0203350:	a31fd06f          	j	ffffffffc0200d80 <forkrets>

ffffffffc0203354 <init_main>:
 * 该线程用于系统初始化后的工作，演示内核线程的基本功能。
 * 打印进程信息和传入的参数，然后退出。
 * ===================================================================== */
static int
init_main(void *arg)
{
ffffffffc0203354:	1101                	addi	sp,sp,-32
ffffffffc0203356:	e822                	sd	s0,16(sp)
    // 打印当前进程（initproc）的信息
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
            current->pid, get_proc_name(current));
ffffffffc0203358:	0000a417          	auipc	s0,0xa
ffffffffc020335c:	17843403          	ld	s0,376(s0) # ffffffffc020d4d0 <current>
{
ffffffffc0203360:	e04a                	sd	s2,0(sp)
    memset(name, 0, sizeof(name));
ffffffffc0203362:	4641                	li	a2,16
{
ffffffffc0203364:	892a                	mv	s2,a0
    memset(name, 0, sizeof(name));
ffffffffc0203366:	4581                	li	a1,0
ffffffffc0203368:	00006517          	auipc	a0,0x6
ffffffffc020336c:	0e050513          	addi	a0,a0,224 # ffffffffc0209448 <name.2>
{
ffffffffc0203370:	ec06                	sd	ra,24(sp)
ffffffffc0203372:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
ffffffffc0203374:	4044                	lw	s1,4(s0)
    memset(name, 0, sizeof(name));
ffffffffc0203376:	780000ef          	jal	ffffffffc0203af6 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020337a:	0b440593          	addi	a1,s0,180
ffffffffc020337e:	463d                	li	a2,15
ffffffffc0203380:	00006517          	auipc	a0,0x6
ffffffffc0203384:	0c850513          	addi	a0,a0,200 # ffffffffc0209448 <name.2>
ffffffffc0203388:	780000ef          	jal	ffffffffc0203b08 <memcpy>
ffffffffc020338c:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
ffffffffc020338e:	85a6                	mv	a1,s1
ffffffffc0203390:	00002517          	auipc	a0,0x2
ffffffffc0203394:	20050513          	addi	a0,a0,512 # ffffffffc0205590 <etext+0x166a>
ffffffffc0203398:	d47fc0ef          	jal	ffffffffc02000de <cprintf>

    // 打印传入的参数
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020339c:	85ca                	mv	a1,s2
ffffffffc020339e:	00002517          	auipc	a0,0x2
ffffffffc02033a2:	21a50513          	addi	a0,a0,538 # ffffffffc02055b8 <etext+0x1692>
ffffffffc02033a6:	d39fc0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02033aa:	00002517          	auipc	a0,0x2
ffffffffc02033ae:	21e50513          	addi	a0,a0,542 # ffffffffc02055c8 <etext+0x16a2>
ffffffffc02033b2:	d2dfc0ef          	jal	ffffffffc02000de <cprintf>

    return 0;  // 线程正常退出
}
ffffffffc02033b6:	60e2                	ld	ra,24(sp)
ffffffffc02033b8:	6442                	ld	s0,16(sp)
ffffffffc02033ba:	64a2                	ld	s1,8(sp)
ffffffffc02033bc:	6902                	ld	s2,0(sp)
ffffffffc02033be:	4501                	li	a0,0
ffffffffc02033c0:	6105                	addi	sp,sp,32
ffffffffc02033c2:	8082                	ret

ffffffffc02033c4 <proc_run>:
    if (proc != current)
ffffffffc02033c4:	0000a797          	auipc	a5,0xa
ffffffffc02033c8:	10c78793          	addi	a5,a5,268 # ffffffffc020d4d0 <current>
ffffffffc02033cc:	6398                	ld	a4,0(a5)
ffffffffc02033ce:	04a70263          	beq	a4,a0,ffffffffc0203412 <proc_run+0x4e>
{
ffffffffc02033d2:	1101                	addi	sp,sp,-32
ffffffffc02033d4:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033d6:	100026f3          	csrr	a3,sstatus
ffffffffc02033da:	8a89                	andi	a3,a3,2
    return 0;
ffffffffc02033dc:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033de:	ea9d                	bnez	a3,ffffffffc0203414 <proc_run+0x50>
        current = proc;           // 更新当前进程指针
ffffffffc02033e0:	e388                	sd	a0,0(a5)
        lsatp(proc->pgdir);
ffffffffc02033e2:	6d1c                	ld	a5,24(a0)
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned int pgdir)
{
  write_csr(satp, SATP32_MODE | (pgdir >> RISCV_PGSHIFT));
ffffffffc02033e4:	800006b7          	lui	a3,0x80000
ffffffffc02033e8:	e432                	sd	a2,8(sp)
ffffffffc02033ea:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02033ee:	8fd5                	or	a5,a5,a3
ffffffffc02033f0:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));
ffffffffc02033f4:	03850593          	addi	a1,a0,56
ffffffffc02033f8:	03870513          	addi	a0,a4,56
ffffffffc02033fc:	e67ff0ef          	jal	ffffffffc0203262 <switch_to>
    if (flag) {
ffffffffc0203400:	6622                	ld	a2,8(sp)
ffffffffc0203402:	e601                	bnez	a2,ffffffffc020340a <proc_run+0x46>
}
ffffffffc0203404:	60e2                	ld	ra,24(sp)
ffffffffc0203406:	6105                	addi	sp,sp,32
ffffffffc0203408:	8082                	ret
ffffffffc020340a:	60e2                	ld	ra,24(sp)
ffffffffc020340c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020340e:	c64fd06f          	j	ffffffffc0200872 <intr_enable>
ffffffffc0203412:	8082                	ret
        intr_disable();
ffffffffc0203414:	e42a                	sd	a0,8(sp)
ffffffffc0203416:	c62fd0ef          	jal	ffffffffc0200878 <intr_disable>
        prev = current;           // 保存当前进程
ffffffffc020341a:	0000a797          	auipc	a5,0xa
ffffffffc020341e:	0b678793          	addi	a5,a5,182 # ffffffffc020d4d0 <current>
ffffffffc0203422:	6398                	ld	a4,0(a5)
        return 1;
ffffffffc0203424:	6522                	ld	a0,8(sp)
ffffffffc0203426:	4605                	li	a2,1
ffffffffc0203428:	bf65                	j	ffffffffc02033e0 <proc_run+0x1c>

ffffffffc020342a <do_fork>:
    if (nr_process >= MAX_PROCESS)
ffffffffc020342a:	0000a717          	auipc	a4,0xa
ffffffffc020342e:	09e72703          	lw	a4,158(a4) # ffffffffc020d4c8 <nr_process>
ffffffffc0203432:	6785                	lui	a5,0x1
ffffffffc0203434:	22f75663          	bge	a4,a5,ffffffffc0203660 <do_fork+0x236>
{
ffffffffc0203438:	7179                	addi	sp,sp,-48
ffffffffc020343a:	f022                	sd	s0,32(sp)
ffffffffc020343c:	ec26                	sd	s1,24(sp)
ffffffffc020343e:	e84a                	sd	s2,16(sp)
ffffffffc0203440:	f406                	sd	ra,40(sp)
ffffffffc0203442:	892e                	mv	s2,a1
ffffffffc0203444:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0203446:	e8fff0ef          	jal	ffffffffc02032d4 <alloc_proc>
ffffffffc020344a:	84aa                	mv	s1,a0
ffffffffc020344c:	20050863          	beqz	a0,ffffffffc020365c <do_fork+0x232>
ffffffffc0203450:	e44e                	sd	s3,8(sp)
    proc->parent = current;  // 设置父进程指针
ffffffffc0203452:	0000a997          	auipc	s3,0xa
ffffffffc0203456:	07e98993          	addi	s3,s3,126 # ffffffffc020d4d0 <current>
ffffffffc020345a:	0009b783          	ld	a5,0(s3)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020345e:	4509                	li	a0,2
    proc->parent = current;  // 设置父进程指针
ffffffffc0203460:	f49c                	sd	a5,40(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203462:	ccbfe0ef          	jal	ffffffffc020212c <alloc_pages>
    if (page != NULL)
ffffffffc0203466:	1e050763          	beqz	a0,ffffffffc0203654 <do_fork+0x22a>
    return page - pages + nbase;
ffffffffc020346a:	0000a697          	auipc	a3,0xa
ffffffffc020346e:	0566b683          	ld	a3,86(a3) # ffffffffc020d4c0 <pages>
ffffffffc0203472:	00002797          	auipc	a5,0x2
ffffffffc0203476:	6067b783          	ld	a5,1542(a5) # ffffffffc0205a78 <nbase>
    return KADDR(page2pa(page));
ffffffffc020347a:	0000a717          	auipc	a4,0xa
ffffffffc020347e:	03e73703          	ld	a4,62(a4) # ffffffffc020d4b8 <npage>
    return page - pages + nbase;
ffffffffc0203482:	40d506b3          	sub	a3,a0,a3
ffffffffc0203486:	8699                	srai	a3,a3,0x6
ffffffffc0203488:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020348a:	00c69793          	slli	a5,a3,0xc
ffffffffc020348e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203490:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203492:	1ee7f963          	bgeu	a5,a4,ffffffffc0203684 <do_fork+0x25a>
    assert(current->mm == NULL);
ffffffffc0203496:	0009b783          	ld	a5,0(s3)
ffffffffc020349a:	0000a717          	auipc	a4,0xa
ffffffffc020349e:	01673703          	ld	a4,22(a4) # ffffffffc020d4b0 <va_pa_offset>
ffffffffc02034a2:	7b9c                	ld	a5,48(a5)
ffffffffc02034a4:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02034a6:	e894                	sd	a3,16(s1)
    assert(current->mm == NULL);
ffffffffc02034a8:	1a079e63          	bnez	a5,ffffffffc0203664 <do_fork+0x23a>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02034ac:	6789                	lui	a5,0x2
ffffffffc02034ae:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc02034b2:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02034b4:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02034b6:	f4d4                	sd	a3,168(s1)
    *(proc->tf) = *tf;
ffffffffc02034b8:	87b6                	mv	a5,a3
ffffffffc02034ba:	12040713          	addi	a4,s0,288
ffffffffc02034be:	6a0c                	ld	a1,16(a2)
ffffffffc02034c0:	00063803          	ld	a6,0(a2)
ffffffffc02034c4:	6608                	ld	a0,8(a2)
ffffffffc02034c6:	eb8c                	sd	a1,16(a5)
ffffffffc02034c8:	0107b023          	sd	a6,0(a5)
ffffffffc02034cc:	e788                	sd	a0,8(a5)
ffffffffc02034ce:	6e0c                	ld	a1,24(a2)
ffffffffc02034d0:	02060613          	addi	a2,a2,32
ffffffffc02034d4:	02078793          	addi	a5,a5,32
ffffffffc02034d8:	feb7bc23          	sd	a1,-8(a5)
ffffffffc02034dc:	fee611e3          	bne	a2,a4,ffffffffc02034be <do_fork+0x94>
    proc->tf->gpr.a0 = 0;
ffffffffc02034e0:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02034e4:	10090b63          	beqz	s2,ffffffffc02035fa <do_fork+0x1d0>
ffffffffc02034e8:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02034ec:	00000797          	auipc	a5,0x0
ffffffffc02034f0:	e5a78793          	addi	a5,a5,-422 # ffffffffc0203346 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02034f4:	e0b4                	sd	a3,64(s1)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02034f6:	fc9c                	sd	a5,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034f8:	100027f3          	csrr	a5,sstatus
ffffffffc02034fc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02034fe:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203500:	10079c63          	bnez	a5,ffffffffc0203618 <do_fork+0x1ee>
    if (++last_pid >= MAX_PID)
ffffffffc0203504:	00006517          	auipc	a0,0x6
ffffffffc0203508:	b2852503          	lw	a0,-1240(a0) # ffffffffc020902c <last_pid.1>
ffffffffc020350c:	6789                	lui	a5,0x2
ffffffffc020350e:	2505                	addiw	a0,a0,1
ffffffffc0203510:	00006717          	auipc	a4,0x6
ffffffffc0203514:	b0a72e23          	sw	a0,-1252(a4) # ffffffffc020902c <last_pid.1>
ffffffffc0203518:	10f55f63          	bge	a0,a5,ffffffffc0203636 <do_fork+0x20c>
    if (last_pid >= next_safe)
ffffffffc020351c:	00006797          	auipc	a5,0x6
ffffffffc0203520:	b0c7a783          	lw	a5,-1268(a5) # ffffffffc0209028 <next_safe.0>
ffffffffc0203524:	0000a417          	auipc	s0,0xa
ffffffffc0203528:	f3440413          	addi	s0,s0,-204 # ffffffffc020d458 <proc_list>
ffffffffc020352c:	06f54563          	blt	a0,a5,ffffffffc0203596 <do_fork+0x16c>
    return listelm->next;
ffffffffc0203530:	0000a417          	auipc	s0,0xa
ffffffffc0203534:	f2840413          	addi	s0,s0,-216 # ffffffffc020d458 <proc_list>
ffffffffc0203538:	00843883          	ld	a7,8(s0)
        next_safe = MAX_PID;  // 重置安全边界
ffffffffc020353c:	6789                	lui	a5,0x2
ffffffffc020353e:	00006717          	auipc	a4,0x6
ffffffffc0203542:	aef72523          	sw	a5,-1302(a4) # ffffffffc0209028 <next_safe.0>
ffffffffc0203546:	86aa                	mv	a3,a0
ffffffffc0203548:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020354a:	04888063          	beq	a7,s0,ffffffffc020358a <do_fork+0x160>
ffffffffc020354e:	882e                	mv	a6,a1
ffffffffc0203550:	87c6                	mv	a5,a7
ffffffffc0203552:	6609                	lui	a2,0x2
ffffffffc0203554:	a811                	j	ffffffffc0203568 <do_fork+0x13e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203556:	00e6d663          	bge	a3,a4,ffffffffc0203562 <do_fork+0x138>
ffffffffc020355a:	00c75463          	bge	a4,a2,ffffffffc0203562 <do_fork+0x138>
                next_safe = proc->pid;
ffffffffc020355e:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203560:	4805                	li	a6,1
ffffffffc0203562:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0203564:	00878d63          	beq	a5,s0,ffffffffc020357e <do_fork+0x154>
            if (proc->pid == last_pid)
ffffffffc0203568:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc020356c:	fed715e3          	bne	a4,a3,ffffffffc0203556 <do_fork+0x12c>
                if (++last_pid >= next_safe)
ffffffffc0203570:	2685                	addiw	a3,a3,1
ffffffffc0203572:	0cc6db63          	bge	a3,a2,ffffffffc0203648 <do_fork+0x21e>
ffffffffc0203576:	679c                	ld	a5,8(a5)
ffffffffc0203578:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc020357a:	fe8797e3          	bne	a5,s0,ffffffffc0203568 <do_fork+0x13e>
ffffffffc020357e:	00080663          	beqz	a6,ffffffffc020358a <do_fork+0x160>
ffffffffc0203582:	00006797          	auipc	a5,0x6
ffffffffc0203586:	aac7a323          	sw	a2,-1370(a5) # ffffffffc0209028 <next_safe.0>
ffffffffc020358a:	c591                	beqz	a1,ffffffffc0203596 <do_fork+0x16c>
ffffffffc020358c:	00006797          	auipc	a5,0x6
ffffffffc0203590:	aad7a023          	sw	a3,-1376(a5) # ffffffffc020902c <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203594:	8536                	mv	a0,a3
        proc->pid = get_pid();
ffffffffc0203596:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0203598:	45a9                	li	a1,10
ffffffffc020359a:	177000ef          	jal	ffffffffc0203f10 <hash32>
ffffffffc020359e:	02051793          	slli	a5,a0,0x20
ffffffffc02035a2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02035a6:	00006797          	auipc	a5,0x6
ffffffffc02035aa:	eb278793          	addi	a5,a5,-334 # ffffffffc0209458 <hash_list>
ffffffffc02035ae:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02035b0:	6510                	ld	a2,8(a0)
ffffffffc02035b2:	0d848793          	addi	a5,s1,216
ffffffffc02035b6:	6414                	ld	a3,8(s0)
        nr_process++;
ffffffffc02035b8:	0000a717          	auipc	a4,0xa
ffffffffc02035bc:	f1072703          	lw	a4,-240(a4) # ffffffffc020d4c8 <nr_process>
    prev->next = next->prev = elm;
ffffffffc02035c0:	e21c                	sd	a5,0(a2)
ffffffffc02035c2:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc02035c4:	f0f0                	sd	a2,224(s1)
    elm->prev = prev;
ffffffffc02035c6:	ece8                	sd	a0,216(s1)
        list_add(&proc_list, &(proc->list_link));
ffffffffc02035c8:	0c848613          	addi	a2,s1,200
    prev->next = next->prev = elm;
ffffffffc02035cc:	e290                	sd	a2,0(a3)
        nr_process++;
ffffffffc02035ce:	0017079b          	addiw	a5,a4,1
ffffffffc02035d2:	e410                	sd	a2,8(s0)
    elm->next = next;
ffffffffc02035d4:	e8f4                	sd	a3,208(s1)
    elm->prev = prev;
ffffffffc02035d6:	e4e0                	sd	s0,200(s1)
ffffffffc02035d8:	0000a717          	auipc	a4,0xa
ffffffffc02035dc:	eef72823          	sw	a5,-272(a4) # ffffffffc020d4c8 <nr_process>
    if (flag) {
ffffffffc02035e0:	06091163          	bnez	s2,ffffffffc0203642 <do_fork+0x218>
    wakeup_proc(proc);
ffffffffc02035e4:	8526                	mv	a0,s1
ffffffffc02035e6:	394000ef          	jal	ffffffffc020397a <wakeup_proc>
    ret = proc->pid;
ffffffffc02035ea:	40c8                	lw	a0,4(s1)
ffffffffc02035ec:	69a2                	ld	s3,8(sp)
}
ffffffffc02035ee:	70a2                	ld	ra,40(sp)
ffffffffc02035f0:	7402                	ld	s0,32(sp)
ffffffffc02035f2:	64e2                	ld	s1,24(sp)
ffffffffc02035f4:	6942                	ld	s2,16(sp)
ffffffffc02035f6:	6145                	addi	sp,sp,48
ffffffffc02035f8:	8082                	ret
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02035fa:	8936                	mv	s2,a3
ffffffffc02035fc:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203600:	00000797          	auipc	a5,0x0
ffffffffc0203604:	d4678793          	addi	a5,a5,-698 # ffffffffc0203346 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203608:	e0b4                	sd	a3,64(s1)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020360a:	fc9c                	sd	a5,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020360c:	100027f3          	csrr	a5,sstatus
ffffffffc0203610:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203612:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203614:	ee0788e3          	beqz	a5,ffffffffc0203504 <do_fork+0xda>
        intr_disable();
ffffffffc0203618:	a60fd0ef          	jal	ffffffffc0200878 <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc020361c:	00006517          	auipc	a0,0x6
ffffffffc0203620:	a1052503          	lw	a0,-1520(a0) # ffffffffc020902c <last_pid.1>
ffffffffc0203624:	6789                	lui	a5,0x2
        return 1;
ffffffffc0203626:	4905                	li	s2,1
ffffffffc0203628:	2505                	addiw	a0,a0,1
ffffffffc020362a:	00006717          	auipc	a4,0x6
ffffffffc020362e:	a0a72123          	sw	a0,-1534(a4) # ffffffffc020902c <last_pid.1>
ffffffffc0203632:	eef545e3          	blt	a0,a5,ffffffffc020351c <do_fork+0xf2>
        last_pid = 1;
ffffffffc0203636:	4505                	li	a0,1
ffffffffc0203638:	00006797          	auipc	a5,0x6
ffffffffc020363c:	9ea7aa23          	sw	a0,-1548(a5) # ffffffffc020902c <last_pid.1>
        goto inside;  // 跳转到内部检查逻辑
ffffffffc0203640:	bdc5                	j	ffffffffc0203530 <do_fork+0x106>
        intr_enable();
ffffffffc0203642:	a30fd0ef          	jal	ffffffffc0200872 <intr_enable>
ffffffffc0203646:	bf79                	j	ffffffffc02035e4 <do_fork+0x1ba>
                    if (last_pid >= MAX_PID)
ffffffffc0203648:	6789                	lui	a5,0x2
ffffffffc020364a:	00f6c363          	blt	a3,a5,ffffffffc0203650 <do_fork+0x226>
                        last_pid = 1;  // 回绕到1
ffffffffc020364e:	4685                	li	a3,1
                    goto repeat;  // 重新开始检查
ffffffffc0203650:	4585                	li	a1,1
ffffffffc0203652:	bde5                	j	ffffffffc020354a <do_fork+0x120>
    kfree(proc);       // 释放进程结构体
ffffffffc0203654:	8526                	mv	a0,s1
ffffffffc0203656:	ec9fd0ef          	jal	ffffffffc020151e <kfree>
ffffffffc020365a:	69a2                	ld	s3,8(sp)
    ret = -E_NO_MEM;  // 默认错误：内存不足
ffffffffc020365c:	5571                	li	a0,-4
ffffffffc020365e:	bf41                	j	ffffffffc02035ee <do_fork+0x1c4>
    int ret = -E_NO_FREE_PROC;         // 默认错误：进程数达到上限
ffffffffc0203660:	556d                	li	a0,-5
}
ffffffffc0203662:	8082                	ret
    assert(current->mm == NULL);
ffffffffc0203664:	00002697          	auipc	a3,0x2
ffffffffc0203668:	f8468693          	addi	a3,a3,-124 # ffffffffc02055e8 <etext+0x16c2>
ffffffffc020366c:	00001617          	auipc	a2,0x1
ffffffffc0203670:	29c60613          	addi	a2,a2,668 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203674:	25600593          	li	a1,598
ffffffffc0203678:	00002517          	auipc	a0,0x2
ffffffffc020367c:	f8850513          	addi	a0,a0,-120 # ffffffffc0205600 <etext+0x16da>
ffffffffc0203680:	b5bfc0ef          	jal	ffffffffc02001da <__panic>
ffffffffc0203684:	00001617          	auipc	a2,0x1
ffffffffc0203688:	4a460613          	addi	a2,a2,1188 # ffffffffc0204b28 <etext+0xc02>
ffffffffc020368c:	07100593          	li	a1,113
ffffffffc0203690:	00001517          	auipc	a0,0x1
ffffffffc0203694:	4c050513          	addi	a0,a0,1216 # ffffffffc0204b50 <etext+0xc2a>
ffffffffc0203698:	b43fc0ef          	jal	ffffffffc02001da <__panic>

ffffffffc020369c <kernel_thread>:
{
ffffffffc020369c:	7129                	addi	sp,sp,-320
ffffffffc020369e:	fa22                	sd	s0,304(sp)
ffffffffc02036a0:	f626                	sd	s1,296(sp)
ffffffffc02036a2:	f24a                	sd	s2,288(sp)
ffffffffc02036a4:	842a                	mv	s0,a0
ffffffffc02036a6:	84ae                	mv	s1,a1
ffffffffc02036a8:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02036aa:	850a                	mv	a0,sp
ffffffffc02036ac:	12000613          	li	a2,288
ffffffffc02036b0:	4581                	li	a1,0
{
ffffffffc02036b2:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02036b4:	442000ef          	jal	ffffffffc0203af6 <memset>
    tf.gpr.s0 = (uintptr_t)fn;        // s0 = 线程函数地址
ffffffffc02036b8:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;       // s1 = 函数参数
ffffffffc02036ba:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02036bc:	100027f3          	csrr	a5,sstatus
ffffffffc02036c0:	edd7f793          	andi	a5,a5,-291
ffffffffc02036c4:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036c8:	860a                	mv	a2,sp
ffffffffc02036ca:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02036ce:	00000717          	auipc	a4,0x0
ffffffffc02036d2:	bfe70713          	addi	a4,a4,-1026 # ffffffffc02032cc <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036d6:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02036d8:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02036da:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036dc:	d4fff0ef          	jal	ffffffffc020342a <do_fork>
}
ffffffffc02036e0:	70f2                	ld	ra,312(sp)
ffffffffc02036e2:	7452                	ld	s0,304(sp)
ffffffffc02036e4:	74b2                	ld	s1,296(sp)
ffffffffc02036e6:	7912                	ld	s2,288(sp)
ffffffffc02036e8:	6131                	addi	sp,sp,320
ffffffffc02036ea:	8082                	ret

ffffffffc02036ec <do_exit>:
{
ffffffffc02036ec:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02036ee:	00002617          	auipc	a2,0x2
ffffffffc02036f2:	f2a60613          	addi	a2,a2,-214 # ffffffffc0205618 <etext+0x16f2>
ffffffffc02036f6:	30a00593          	li	a1,778
ffffffffc02036fa:	00002517          	auipc	a0,0x2
ffffffffc02036fe:	f0650513          	addi	a0,a0,-250 # ffffffffc0205600 <etext+0x16da>
{
ffffffffc0203702:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc0203704:	ad7fc0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0203708 <proc_init>:
 * - PID为0，是系统中第一个进程
 * - 使用预先分配的bootstack作为内核栈
 * - 始终处于可运行状态
 * ===================================================================== */
void proc_init(void)
{
ffffffffc0203708:	7179                	addi	sp,sp,-48
ffffffffc020370a:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc020370c:	0000a797          	auipc	a5,0xa
ffffffffc0203710:	d4c78793          	addi	a5,a5,-692 # ffffffffc020d458 <proc_list>
ffffffffc0203714:	f406                	sd	ra,40(sp)
ffffffffc0203716:	f022                	sd	s0,32(sp)
ffffffffc0203718:	e84a                	sd	s2,16(sp)
ffffffffc020371a:	e44e                	sd	s3,8(sp)
ffffffffc020371c:	00006497          	auipc	s1,0x6
ffffffffc0203720:	d3c48493          	addi	s1,s1,-708 # ffffffffc0209458 <hash_list>
ffffffffc0203724:	e79c                	sd	a5,8(a5)
ffffffffc0203726:	e39c                	sd	a5,0(a5)
    // ========== 1. 初始化进程管理数据结构 ==========
    // 初始化进程链表（双向循环链表）
    list_init(&proc_list);

    // 初始化PID哈希表的所有桶
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0203728:	0000a717          	auipc	a4,0xa
ffffffffc020372c:	d3070713          	addi	a4,a4,-720 # ffffffffc020d458 <proc_list>
ffffffffc0203730:	87a6                	mv	a5,s1
ffffffffc0203732:	e79c                	sd	a5,8(a5)
ffffffffc0203734:	e39c                	sd	a5,0(a5)
ffffffffc0203736:	07c1                	addi	a5,a5,16
ffffffffc0203738:	fee79de3          	bne	a5,a4,ffffffffc0203732 <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    // ========== 2. 创建idle进程 ==========
    if ((idleproc = alloc_proc()) == NULL)
ffffffffc020373c:	b99ff0ef          	jal	ffffffffc02032d4 <alloc_proc>
ffffffffc0203740:	0000a917          	auipc	s2,0xa
ffffffffc0203744:	da090913          	addi	s2,s2,-608 # ffffffffc020d4e0 <idleproc>
ffffffffc0203748:	00a93023          	sd	a0,0(s2)
ffffffffc020374c:	1a050263          	beqz	a0,ffffffffc02038f0 <proc_init+0x1e8>
        panic("cannot alloc idleproc.\n");
    }

    // ========== 3. 验证alloc_proc函数的正确性 ==========
    // 通过内存比较验证idleproc的各个字段是否正确初始化
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc0203750:	07000513          	li	a0,112
ffffffffc0203754:	d25fd0ef          	jal	ffffffffc0201478 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0203758:	07000613          	li	a2,112
ffffffffc020375c:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020375e:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0203760:	396000ef          	jal	ffffffffc0203af6 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0203764:	00093503          	ld	a0,0(s2)
ffffffffc0203768:	85a2                	mv	a1,s0
ffffffffc020376a:	07000613          	li	a2,112
ffffffffc020376e:	03850513          	addi	a0,a0,56
ffffffffc0203772:	3ae000ef          	jal	ffffffffc0203b20 <memcmp>
ffffffffc0203776:	89aa                	mv	s3,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203778:	453d                	li	a0,15
ffffffffc020377a:	cfffd0ef          	jal	ffffffffc0201478 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020377e:	463d                	li	a2,15
ffffffffc0203780:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203782:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0203784:	372000ef          	jal	ffffffffc0203af6 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0203788:	00093503          	ld	a0,0(s2)
ffffffffc020378c:	85a2                	mv	a1,s0
ffffffffc020378e:	463d                	li	a2,15
ffffffffc0203790:	0b450513          	addi	a0,a0,180
ffffffffc0203794:	38c000ef          	jal	ffffffffc0203b20 <memcmp>

    // 检查idleproc是否正确初始化
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
ffffffffc0203798:	00093783          	ld	a5,0(s2)
ffffffffc020379c:	0000a717          	auipc	a4,0xa
ffffffffc02037a0:	d0473703          	ld	a4,-764(a4) # ffffffffc020d4a0 <boot_pgdir_pa>
ffffffffc02037a4:	6f94                	ld	a3,24(a5)
ffffffffc02037a6:	0ee68863          	beq	a3,a4,ffffffffc0203896 <proc_init+0x18e>
        cprintf("alloc_proc() correct!\n");
    }

    // ========== 4. 设置idle进程属性 ==========
    idleproc->pid = 0;                          // 设置PID为0
    idleproc->state = PROC_RUNNABLE;            // 设置为可运行状态
ffffffffc02037aa:	4709                	li	a4,2
ffffffffc02037ac:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
ffffffffc02037ae:	00003717          	auipc	a4,0x3
ffffffffc02037b2:	85270713          	addi	a4,a4,-1966 # ffffffffc0206000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037b6:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
ffffffffc02037ba:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;                 // 需要立即调度
ffffffffc02037bc:	4705                	li	a4,1
ffffffffc02037be:	d398                	sw	a4,32(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037c0:	8522                	mv	a0,s0
ffffffffc02037c2:	4641                	li	a2,16
ffffffffc02037c4:	4581                	li	a1,0
ffffffffc02037c6:	330000ef          	jal	ffffffffc0203af6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02037ca:	8522                	mv	a0,s0
ffffffffc02037cc:	463d                	li	a2,15
ffffffffc02037ce:	00002597          	auipc	a1,0x2
ffffffffc02037d2:	e9258593          	addi	a1,a1,-366 # ffffffffc0205660 <etext+0x173a>
ffffffffc02037d6:	332000ef          	jal	ffffffffc0203b08 <memcpy>
    set_proc_name(idleproc, "idle");            // 设置进程名为"idle"
    nr_process++;                               // 进程计数加1
ffffffffc02037da:	0000a797          	auipc	a5,0xa
ffffffffc02037de:	cee7a783          	lw	a5,-786(a5) # ffffffffc020d4c8 <nr_process>

    // ========== 5. 设置当前进程为idleproc ==========
    current = idleproc;
ffffffffc02037e2:	00093703          	ld	a4,0(s2)

    // ========== 6. 创建init_main线程 ==========
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037e6:	4601                	li	a2,0
    nr_process++;                               // 进程计数加1
ffffffffc02037e8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037ea:	00002597          	auipc	a1,0x2
ffffffffc02037ee:	e7e58593          	addi	a1,a1,-386 # ffffffffc0205668 <etext+0x1742>
ffffffffc02037f2:	00000517          	auipc	a0,0x0
ffffffffc02037f6:	b6250513          	addi	a0,a0,-1182 # ffffffffc0203354 <init_main>
    current = idleproc;
ffffffffc02037fa:	0000a697          	auipc	a3,0xa
ffffffffc02037fe:	cce6bb23          	sd	a4,-810(a3) # ffffffffc020d4d0 <current>
    nr_process++;                               // 进程计数加1
ffffffffc0203802:	0000a717          	auipc	a4,0xa
ffffffffc0203806:	ccf72323          	sw	a5,-826(a4) # ffffffffc020d4c8 <nr_process>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020380a:	e93ff0ef          	jal	ffffffffc020369c <kernel_thread>
ffffffffc020380e:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0203810:	0ea05c63          	blez	a0,ffffffffc0203908 <proc_init+0x200>
    if (0 < pid && pid < MAX_PID)
ffffffffc0203814:	6789                	lui	a5,0x2
ffffffffc0203816:	17f9                	addi	a5,a5,-2 # 1ffe <kern_entry-0xffffffffc01fe002>
ffffffffc0203818:	fff5071b          	addiw	a4,a0,-1
ffffffffc020381c:	02e7e463          	bltu	a5,a4,ffffffffc0203844 <proc_init+0x13c>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0203820:	45a9                	li	a1,10
ffffffffc0203822:	6ee000ef          	jal	ffffffffc0203f10 <hash32>
ffffffffc0203826:	02051713          	slli	a4,a0,0x20
ffffffffc020382a:	01c75793          	srli	a5,a4,0x1c
ffffffffc020382e:	00f486b3          	add	a3,s1,a5
ffffffffc0203832:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0203834:	a029                	j	ffffffffc020383e <proc_init+0x136>
            if (proc->pid == pid)
ffffffffc0203836:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020383a:	0a870863          	beq	a4,s0,ffffffffc02038ea <proc_init+0x1e2>
    return listelm->next;
ffffffffc020383e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0203840:	fef69be3          	bne	a3,a5,ffffffffc0203836 <proc_init+0x12e>
    return NULL;
ffffffffc0203844:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203846:	0b478413          	addi	s0,a5,180
ffffffffc020384a:	4641                	li	a2,16
ffffffffc020384c:	4581                	li	a1,0
ffffffffc020384e:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    // ========== 7. 获取并命名init进程 ==========
    initproc = find_proc(pid);
ffffffffc0203850:	0000a717          	auipc	a4,0xa
ffffffffc0203854:	c8f73423          	sd	a5,-888(a4) # ffffffffc020d4d8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203858:	29e000ef          	jal	ffffffffc0203af6 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020385c:	8522                	mv	a0,s0
ffffffffc020385e:	463d                	li	a2,15
ffffffffc0203860:	00002597          	auipc	a1,0x2
ffffffffc0203864:	e3858593          	addi	a1,a1,-456 # ffffffffc0205698 <etext+0x1772>
ffffffffc0203868:	2a0000ef          	jal	ffffffffc0203b08 <memcpy>
    set_proc_name(initproc, "init");

    // ========== 8. 验证初始化结果 ==========
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020386c:	00093783          	ld	a5,0(s2)
ffffffffc0203870:	cbe1                	beqz	a5,ffffffffc0203940 <proc_init+0x238>
ffffffffc0203872:	43dc                	lw	a5,4(a5)
ffffffffc0203874:	e7f1                	bnez	a5,ffffffffc0203940 <proc_init+0x238>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203876:	0000a797          	auipc	a5,0xa
ffffffffc020387a:	c627b783          	ld	a5,-926(a5) # ffffffffc020d4d8 <initproc>
ffffffffc020387e:	c3cd                	beqz	a5,ffffffffc0203920 <proc_init+0x218>
ffffffffc0203880:	43d8                	lw	a4,4(a5)
ffffffffc0203882:	4785                	li	a5,1
ffffffffc0203884:	08f71e63          	bne	a4,a5,ffffffffc0203920 <proc_init+0x218>
}
ffffffffc0203888:	70a2                	ld	ra,40(sp)
ffffffffc020388a:	7402                	ld	s0,32(sp)
ffffffffc020388c:	64e2                	ld	s1,24(sp)
ffffffffc020388e:	6942                	ld	s2,16(sp)
ffffffffc0203890:	69a2                	ld	s3,8(sp)
ffffffffc0203892:	6145                	addi	sp,sp,48
ffffffffc0203894:	8082                	ret
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
ffffffffc0203896:	77d8                	ld	a4,168(a5)
        idleproc->tf == NULL &&                 // trapframe为空
ffffffffc0203898:	f00719e3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
ffffffffc020389c:	f00997e3          	bnez	s3,ffffffffc02037aa <proc_init+0xa2>
        !context_init_flag &&                   // context已清零
ffffffffc02038a0:	4398                	lw	a4,0(a5)
ffffffffc02038a2:	f00714e3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->state == PROC_UNINIT &&       // 状态为未初始化
ffffffffc02038a6:	43d4                	lw	a3,4(a5)
ffffffffc02038a8:	577d                	li	a4,-1
ffffffffc02038aa:	f0e690e3          	bne	a3,a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->pid == -1 &&                  // PID为无效值
ffffffffc02038ae:	4798                	lw	a4,8(a5)
ffffffffc02038b0:	ee071de3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->runs == 0 &&                  // 运行次数为0
ffffffffc02038b4:	6b98                	ld	a4,16(a5)
ffffffffc02038b6:	ee071ae3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->need_resched == 0 &&          // 不需要调度
ffffffffc02038ba:	5398                	lw	a4,32(a5)
        idleproc->kstack == 0 &&                // 内核栈未分配
ffffffffc02038bc:	ee0717e3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->need_resched == 0 &&          // 不需要调度
ffffffffc02038c0:	7798                	ld	a4,40(a5)
ffffffffc02038c2:	ee0714e3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->parent == NULL &&             // 无父进程
ffffffffc02038c6:	7b98                	ld	a4,48(a5)
ffffffffc02038c8:	ee0711e3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        idleproc->flags == 0 &&                 // 无特殊标志
ffffffffc02038cc:	0b07a703          	lw	a4,176(a5)
ffffffffc02038d0:	8f49                	or	a4,a4,a0
ffffffffc02038d2:	2701                	sext.w	a4,a4
ffffffffc02038d4:	ec071be3          	bnez	a4,ffffffffc02037aa <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc02038d8:	00002517          	auipc	a0,0x2
ffffffffc02038dc:	d7050513          	addi	a0,a0,-656 # ffffffffc0205648 <etext+0x1722>
ffffffffc02038e0:	ffefc0ef          	jal	ffffffffc02000de <cprintf>
    idleproc->pid = 0;                          // 设置PID为0
ffffffffc02038e4:	00093783          	ld	a5,0(s2)
ffffffffc02038e8:	b5c9                	j	ffffffffc02037aa <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02038ea:	f2878793          	addi	a5,a5,-216
ffffffffc02038ee:	bfa1                	j	ffffffffc0203846 <proc_init+0x13e>
        panic("cannot alloc idleproc.\n");
ffffffffc02038f0:	00002617          	auipc	a2,0x2
ffffffffc02038f4:	d4060613          	addi	a2,a2,-704 # ffffffffc0205630 <etext+0x170a>
ffffffffc02038f8:	35000593          	li	a1,848
ffffffffc02038fc:	00002517          	auipc	a0,0x2
ffffffffc0203900:	d0450513          	addi	a0,a0,-764 # ffffffffc0205600 <etext+0x16da>
ffffffffc0203904:	8d7fc0ef          	jal	ffffffffc02001da <__panic>
        panic("create init_main failed.\n");
ffffffffc0203908:	00002617          	auipc	a2,0x2
ffffffffc020390c:	d7060613          	addi	a2,a2,-656 # ffffffffc0205678 <etext+0x1752>
ffffffffc0203910:	37d00593          	li	a1,893
ffffffffc0203914:	00002517          	auipc	a0,0x2
ffffffffc0203918:	cec50513          	addi	a0,a0,-788 # ffffffffc0205600 <etext+0x16da>
ffffffffc020391c:	8bffc0ef          	jal	ffffffffc02001da <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203920:	00002697          	auipc	a3,0x2
ffffffffc0203924:	da868693          	addi	a3,a3,-600 # ffffffffc02056c8 <etext+0x17a2>
ffffffffc0203928:	00001617          	auipc	a2,0x1
ffffffffc020392c:	fe060613          	addi	a2,a2,-32 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203930:	38600593          	li	a1,902
ffffffffc0203934:	00002517          	auipc	a0,0x2
ffffffffc0203938:	ccc50513          	addi	a0,a0,-820 # ffffffffc0205600 <etext+0x16da>
ffffffffc020393c:	89ffc0ef          	jal	ffffffffc02001da <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203940:	00002697          	auipc	a3,0x2
ffffffffc0203944:	d6068693          	addi	a3,a3,-672 # ffffffffc02056a0 <etext+0x177a>
ffffffffc0203948:	00001617          	auipc	a2,0x1
ffffffffc020394c:	fc060613          	addi	a2,a2,-64 # ffffffffc0204908 <etext+0x9e2>
ffffffffc0203950:	38500593          	li	a1,901
ffffffffc0203954:	00002517          	auipc	a0,0x2
ffffffffc0203958:	cac50513          	addi	a0,a0,-852 # ffffffffc0205600 <etext+0x16da>
ffffffffc020395c:	87ffc0ef          	jal	ffffffffc02001da <__panic>

ffffffffc0203960 <cpu_idle>:
 * 3. 没有其他就绪进程时，idle进程会保持运行
 *
 * 这确保了系统在没有其他任务时不会"死机"，而是让CPU执行空闲循环。
 * ===================================================================== */
void cpu_idle(void)
{
ffffffffc0203960:	1141                	addi	sp,sp,-16
ffffffffc0203962:	e022                	sd	s0,0(sp)
ffffffffc0203964:	e406                	sd	ra,8(sp)
ffffffffc0203966:	0000a417          	auipc	s0,0xa
ffffffffc020396a:	b6a40413          	addi	s0,s0,-1174 # ffffffffc020d4d0 <current>
    while (1)  // 无限循环
    {
        // 检查是否需要重新调度
        if (current->need_resched)
ffffffffc020396e:	6018                	ld	a4,0(s0)
ffffffffc0203970:	531c                	lw	a5,32(a4)
ffffffffc0203972:	dffd                	beqz	a5,ffffffffc0203970 <cpu_idle+0x10>
        {
            // 调用调度器进行进程切换
            schedule();
ffffffffc0203974:	03a000ef          	jal	ffffffffc02039ae <schedule>
ffffffffc0203978:	bfdd                	j	ffffffffc020396e <cpu_idle+0xe>

ffffffffc020397a <wakeup_proc>:
 * - 不能重复唤醒已在可运行状态的进程
 * ===================================================================== */
void
wakeup_proc(struct proc_struct *proc) {
    // 断言：确保进程不在僵尸状态或可运行状态
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020397a:	411c                	lw	a5,0(a0)
ffffffffc020397c:	4705                	li	a4,1
ffffffffc020397e:	37f9                	addiw	a5,a5,-2
ffffffffc0203980:	00f77563          	bgeu	a4,a5,ffffffffc020398a <wakeup_proc+0x10>

    // 设置进程为可运行状态
    proc->state = PROC_RUNNABLE;
ffffffffc0203984:	4789                	li	a5,2
ffffffffc0203986:	c11c                	sw	a5,0(a0)
ffffffffc0203988:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc020398a:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020398c:	00002697          	auipc	a3,0x2
ffffffffc0203990:	d6468693          	addi	a3,a3,-668 # ffffffffc02056f0 <etext+0x17ca>
ffffffffc0203994:	00001617          	auipc	a2,0x1
ffffffffc0203998:	f7460613          	addi	a2,a2,-140 # ffffffffc0204908 <etext+0x9e2>
ffffffffc020399c:	02700593          	li	a1,39
ffffffffc02039a0:	00002517          	auipc	a0,0x2
ffffffffc02039a4:	d9050513          	addi	a0,a0,-624 # ffffffffc0205730 <etext+0x180a>
wakeup_proc(struct proc_struct *proc) {
ffffffffc02039a8:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02039aa:	831fc0ef          	jal	ffffffffc02001da <__panic>

ffffffffc02039ae <schedule>:
 * - 采用轮转方式：每个进程都有平等的机会获得CPU
 * - 优先级相同的进程按链表顺序轮流执行
 * - idle进程作为fallback，确保系统不会没有可执行进程
 * ===================================================================== */
void
schedule(void) {
ffffffffc02039ae:	1101                	addi	sp,sp,-32
ffffffffc02039b0:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02039b2:	100027f3          	csrr	a5,sstatus
ffffffffc02039b6:	8b89                	andi	a5,a5,2
ffffffffc02039b8:	4301                	li	t1,0
ffffffffc02039ba:	e3c1                	bnez	a5,ffffffffc0203a3a <schedule+0x8c>

    // 关闭中断，保证调度过程的原子性
    local_intr_save(intr_flag);
    {
        // 清除当前进程的重新调度标志
        current->need_resched = 0;
ffffffffc02039bc:	0000a897          	auipc	a7,0xa
ffffffffc02039c0:	b148b883          	ld	a7,-1260(a7) # ffffffffc020d4d0 <current>

        // ========== 确定查找起始点 ==========
        // 如果当前是idle进程，从链表头开始查找
        // 否则从当前进程的下一个开始查找（实现轮转调度）
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02039c4:	0000a517          	auipc	a0,0xa
ffffffffc02039c8:	b1c53503          	ld	a0,-1252(a0) # ffffffffc020d4e0 <idleproc>
        current->need_resched = 0;
ffffffffc02039cc:	0208a023          	sw	zero,32(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02039d0:	04a88f63          	beq	a7,a0,ffffffffc0203a2e <schedule+0x80>
ffffffffc02039d4:	0c888693          	addi	a3,a7,200
ffffffffc02039d8:	0000a617          	auipc	a2,0xa
ffffffffc02039dc:	a8060613          	addi	a2,a2,-1408 # ffffffffc020d458 <proc_list>
        le = last;
ffffffffc02039e0:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;   // 选中的下一个进程
ffffffffc02039e2:	4581                	li	a1,0
            // 获取下一个链表节点
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);

                // 找到第一个可运行状态的进程
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039e4:	4809                	li	a6,2
ffffffffc02039e6:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02039e8:	00c78863          	beq	a5,a2,ffffffffc02039f8 <schedule+0x4a>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039ec:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02039f0:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039f4:	03070363          	beq	a4,a6,ffffffffc0203a1a <schedule+0x6c>
                    break;  // 找到目标，跳出循环
                }
            }
        } while (le != last);  // 遍历完一圈后停止
ffffffffc02039f8:	fef697e3          	bne	a3,a5,ffffffffc02039e6 <schedule+0x38>

        // ========== 处理未找到可运行进程的情况 ==========
        // 如果没找到可运行进程或者找到的进程状态不对，选择idle进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02039fc:	ed99                	bnez	a1,ffffffffc0203a1a <schedule+0x6c>
            next = idleproc;
        }

        // ========== 更新进程运行统计 ==========
        next->runs ++;  // 增加选中进程的运行次数计数
ffffffffc02039fe:	451c                	lw	a5,8(a0)
ffffffffc0203a00:	2785                	addiw	a5,a5,1
ffffffffc0203a02:	c51c                	sw	a5,8(a0)

        // ========== 执行进程切换 ==========
        if (next != current) {
ffffffffc0203a04:	00a88663          	beq	a7,a0,ffffffffc0203a10 <schedule+0x62>
ffffffffc0203a08:	e41a                	sd	t1,8(sp)
            proc_run(next);  // 切换到选中进程
ffffffffc0203a0a:	9bbff0ef          	jal	ffffffffc02033c4 <proc_run>
ffffffffc0203a0e:	6322                	ld	t1,8(sp)
    if (flag) {
ffffffffc0203a10:	00031b63          	bnez	t1,ffffffffc0203a26 <schedule+0x78>
        }
        // 如果选中进程就是当前进程，则继续执行（不需要切换）
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);
}
ffffffffc0203a14:	60e2                	ld	ra,24(sp)
ffffffffc0203a16:	6105                	addi	sp,sp,32
ffffffffc0203a18:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0203a1a:	4198                	lw	a4,0(a1)
ffffffffc0203a1c:	4789                	li	a5,2
ffffffffc0203a1e:	fef710e3          	bne	a4,a5,ffffffffc02039fe <schedule+0x50>
ffffffffc0203a22:	852e                	mv	a0,a1
ffffffffc0203a24:	bfe9                	j	ffffffffc02039fe <schedule+0x50>
}
ffffffffc0203a26:	60e2                	ld	ra,24(sp)
ffffffffc0203a28:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203a2a:	e49fc06f          	j	ffffffffc0200872 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203a2e:	0000a617          	auipc	a2,0xa
ffffffffc0203a32:	a2a60613          	addi	a2,a2,-1494 # ffffffffc020d458 <proc_list>
ffffffffc0203a36:	86b2                	mv	a3,a2
ffffffffc0203a38:	b765                	j	ffffffffc02039e0 <schedule+0x32>
        intr_disable();
ffffffffc0203a3a:	e3ffc0ef          	jal	ffffffffc0200878 <intr_disable>
        return 1;
ffffffffc0203a3e:	4305                	li	t1,1
ffffffffc0203a40:	bfb5                	j	ffffffffc02039bc <schedule+0xe>

ffffffffc0203a42 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203a42:	00054783          	lbu	a5,0(a0)
ffffffffc0203a46:	cb81                	beqz	a5,ffffffffc0203a56 <strlen+0x14>
    size_t cnt = 0;
ffffffffc0203a48:	4781                	li	a5,0
        cnt ++;
ffffffffc0203a4a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203a4c:	00f50733          	add	a4,a0,a5
ffffffffc0203a50:	00074703          	lbu	a4,0(a4)
ffffffffc0203a54:	fb7d                	bnez	a4,ffffffffc0203a4a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203a56:	853e                	mv	a0,a5
ffffffffc0203a58:	8082                	ret

ffffffffc0203a5a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203a5a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a5c:	e589                	bnez	a1,ffffffffc0203a66 <strnlen+0xc>
ffffffffc0203a5e:	a811                	j	ffffffffc0203a72 <strnlen+0x18>
        cnt ++;
ffffffffc0203a60:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a62:	00f58863          	beq	a1,a5,ffffffffc0203a72 <strnlen+0x18>
ffffffffc0203a66:	00f50733          	add	a4,a0,a5
ffffffffc0203a6a:	00074703          	lbu	a4,0(a4)
ffffffffc0203a6e:	fb6d                	bnez	a4,ffffffffc0203a60 <strnlen+0x6>
ffffffffc0203a70:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203a72:	852e                	mv	a0,a1
ffffffffc0203a74:	8082                	ret

ffffffffc0203a76 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203a76:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203a78:	0005c703          	lbu	a4,0(a1)
ffffffffc0203a7c:	0585                	addi	a1,a1,1
ffffffffc0203a7e:	0785                	addi	a5,a5,1
ffffffffc0203a80:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203a84:	fb75                	bnez	a4,ffffffffc0203a78 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203a86:	8082                	ret

ffffffffc0203a88 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a88:	00054783          	lbu	a5,0(a0)
ffffffffc0203a8c:	e791                	bnez	a5,ffffffffc0203a98 <strcmp+0x10>
ffffffffc0203a8e:	a01d                	j	ffffffffc0203ab4 <strcmp+0x2c>
ffffffffc0203a90:	00054783          	lbu	a5,0(a0)
ffffffffc0203a94:	cb99                	beqz	a5,ffffffffc0203aaa <strcmp+0x22>
ffffffffc0203a96:	0585                	addi	a1,a1,1
ffffffffc0203a98:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0203a9c:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a9e:	fef709e3          	beq	a4,a5,ffffffffc0203a90 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203aa2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203aa6:	9d19                	subw	a0,a0,a4
ffffffffc0203aa8:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203aaa:	0015c703          	lbu	a4,1(a1)
ffffffffc0203aae:	4501                	li	a0,0
}
ffffffffc0203ab0:	9d19                	subw	a0,a0,a4
ffffffffc0203ab2:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ab4:	0005c703          	lbu	a4,0(a1)
ffffffffc0203ab8:	4501                	li	a0,0
ffffffffc0203aba:	b7f5                	j	ffffffffc0203aa6 <strcmp+0x1e>

ffffffffc0203abc <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203abc:	ce01                	beqz	a2,ffffffffc0203ad4 <strncmp+0x18>
ffffffffc0203abe:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0203ac2:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203ac4:	cb91                	beqz	a5,ffffffffc0203ad8 <strncmp+0x1c>
ffffffffc0203ac6:	0005c703          	lbu	a4,0(a1)
ffffffffc0203aca:	00f71763          	bne	a4,a5,ffffffffc0203ad8 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0203ace:	0505                	addi	a0,a0,1
ffffffffc0203ad0:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203ad2:	f675                	bnez	a2,ffffffffc0203abe <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ad4:	4501                	li	a0,0
ffffffffc0203ad6:	8082                	ret
ffffffffc0203ad8:	00054503          	lbu	a0,0(a0)
ffffffffc0203adc:	0005c783          	lbu	a5,0(a1)
ffffffffc0203ae0:	9d1d                	subw	a0,a0,a5
}
ffffffffc0203ae2:	8082                	ret

ffffffffc0203ae4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203ae4:	a021                	j	ffffffffc0203aec <strchr+0x8>
        if (*s == c) {
ffffffffc0203ae6:	00f58763          	beq	a1,a5,ffffffffc0203af4 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0203aea:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203aec:	00054783          	lbu	a5,0(a0)
ffffffffc0203af0:	fbfd                	bnez	a5,ffffffffc0203ae6 <strchr+0x2>
    }
    return NULL;
ffffffffc0203af2:	4501                	li	a0,0
}
ffffffffc0203af4:	8082                	ret

ffffffffc0203af6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203af6:	ca01                	beqz	a2,ffffffffc0203b06 <memset+0x10>
ffffffffc0203af8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203afa:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203afc:	0785                	addi	a5,a5,1
ffffffffc0203afe:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203b02:	fef61de3          	bne	a2,a5,ffffffffc0203afc <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203b06:	8082                	ret

ffffffffc0203b08 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203b08:	ca19                	beqz	a2,ffffffffc0203b1e <memcpy+0x16>
ffffffffc0203b0a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203b0c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203b0e:	0005c703          	lbu	a4,0(a1)
ffffffffc0203b12:	0585                	addi	a1,a1,1
ffffffffc0203b14:	0785                	addi	a5,a5,1
ffffffffc0203b16:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203b1a:	feb61ae3          	bne	a2,a1,ffffffffc0203b0e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203b1e:	8082                	ret

ffffffffc0203b20 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0203b20:	c205                	beqz	a2,ffffffffc0203b40 <memcmp+0x20>
ffffffffc0203b22:	962a                	add	a2,a2,a0
ffffffffc0203b24:	a019                	j	ffffffffc0203b2a <memcmp+0xa>
ffffffffc0203b26:	00c50d63          	beq	a0,a2,ffffffffc0203b40 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0203b2a:	00054783          	lbu	a5,0(a0)
ffffffffc0203b2e:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0203b32:	0505                	addi	a0,a0,1
ffffffffc0203b34:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0203b36:	fee788e3          	beq	a5,a4,ffffffffc0203b26 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203b3a:	40e7853b          	subw	a0,a5,a4
ffffffffc0203b3e:	8082                	ret
    }
    return 0;
ffffffffc0203b40:	4501                	li	a0,0
}
ffffffffc0203b42:	8082                	ret

ffffffffc0203b44 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b44:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203b46:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b4a:	f022                	sd	s0,32(sp)
ffffffffc0203b4c:	ec26                	sd	s1,24(sp)
ffffffffc0203b4e:	e84a                	sd	s2,16(sp)
ffffffffc0203b50:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b52:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b56:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b58:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203b5c:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b60:	84aa                	mv	s1,a0
ffffffffc0203b62:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0203b64:	03067d63          	bgeu	a2,a6,ffffffffc0203b9e <printnum+0x5a>
ffffffffc0203b68:	e44e                	sd	s3,8(sp)
ffffffffc0203b6a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203b6c:	4785                	li	a5,1
ffffffffc0203b6e:	00e7d763          	bge	a5,a4,ffffffffc0203b7c <printnum+0x38>
            putch(padc, putdat);
ffffffffc0203b72:	85ca                	mv	a1,s2
ffffffffc0203b74:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0203b76:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203b78:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203b7a:	fc65                	bnez	s0,ffffffffc0203b72 <printnum+0x2e>
ffffffffc0203b7c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b7e:	00002797          	auipc	a5,0x2
ffffffffc0203b82:	bca78793          	addi	a5,a5,-1078 # ffffffffc0205748 <etext+0x1822>
ffffffffc0203b86:	97d2                	add	a5,a5,s4
}
ffffffffc0203b88:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b8a:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0203b8e:	70a2                	ld	ra,40(sp)
ffffffffc0203b90:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b92:	85ca                	mv	a1,s2
ffffffffc0203b94:	87a6                	mv	a5,s1
}
ffffffffc0203b96:	6942                	ld	s2,16(sp)
ffffffffc0203b98:	64e2                	ld	s1,24(sp)
ffffffffc0203b9a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b9c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203b9e:	03065633          	divu	a2,a2,a6
ffffffffc0203ba2:	8722                	mv	a4,s0
ffffffffc0203ba4:	fa1ff0ef          	jal	ffffffffc0203b44 <printnum>
ffffffffc0203ba8:	bfd9                	j	ffffffffc0203b7e <printnum+0x3a>

ffffffffc0203baa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203baa:	7119                	addi	sp,sp,-128
ffffffffc0203bac:	f4a6                	sd	s1,104(sp)
ffffffffc0203bae:	f0ca                	sd	s2,96(sp)
ffffffffc0203bb0:	ecce                	sd	s3,88(sp)
ffffffffc0203bb2:	e8d2                	sd	s4,80(sp)
ffffffffc0203bb4:	e4d6                	sd	s5,72(sp)
ffffffffc0203bb6:	e0da                	sd	s6,64(sp)
ffffffffc0203bb8:	f862                	sd	s8,48(sp)
ffffffffc0203bba:	fc86                	sd	ra,120(sp)
ffffffffc0203bbc:	f8a2                	sd	s0,112(sp)
ffffffffc0203bbe:	fc5e                	sd	s7,56(sp)
ffffffffc0203bc0:	f466                	sd	s9,40(sp)
ffffffffc0203bc2:	f06a                	sd	s10,32(sp)
ffffffffc0203bc4:	ec6e                	sd	s11,24(sp)
ffffffffc0203bc6:	84aa                	mv	s1,a0
ffffffffc0203bc8:	8c32                	mv	s8,a2
ffffffffc0203bca:	8a36                	mv	s4,a3
ffffffffc0203bcc:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bce:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bd2:	05500b13          	li	s6,85
ffffffffc0203bd6:	00002a97          	auipc	s5,0x2
ffffffffc0203bda:	d12a8a93          	addi	s5,s5,-750 # ffffffffc02058e8 <default_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bde:	000c4503          	lbu	a0,0(s8)
ffffffffc0203be2:	001c0413          	addi	s0,s8,1
ffffffffc0203be6:	01350a63          	beq	a0,s3,ffffffffc0203bfa <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0203bea:	cd0d                	beqz	a0,ffffffffc0203c24 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0203bec:	85ca                	mv	a1,s2
ffffffffc0203bee:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bf0:	00044503          	lbu	a0,0(s0)
ffffffffc0203bf4:	0405                	addi	s0,s0,1
ffffffffc0203bf6:	ff351ae3          	bne	a0,s3,ffffffffc0203bea <vprintfmt+0x40>
        width = precision = -1;
ffffffffc0203bfa:	5cfd                	li	s9,-1
ffffffffc0203bfc:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0203bfe:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0203c02:	4b81                	li	s7,0
ffffffffc0203c04:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c06:	00044683          	lbu	a3,0(s0)
ffffffffc0203c0a:	00140c13          	addi	s8,s0,1
ffffffffc0203c0e:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0203c12:	0ff5f593          	zext.b	a1,a1
ffffffffc0203c16:	02bb6663          	bltu	s6,a1,ffffffffc0203c42 <vprintfmt+0x98>
ffffffffc0203c1a:	058a                	slli	a1,a1,0x2
ffffffffc0203c1c:	95d6                	add	a1,a1,s5
ffffffffc0203c1e:	4198                	lw	a4,0(a1)
ffffffffc0203c20:	9756                	add	a4,a4,s5
ffffffffc0203c22:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203c24:	70e6                	ld	ra,120(sp)
ffffffffc0203c26:	7446                	ld	s0,112(sp)
ffffffffc0203c28:	74a6                	ld	s1,104(sp)
ffffffffc0203c2a:	7906                	ld	s2,96(sp)
ffffffffc0203c2c:	69e6                	ld	s3,88(sp)
ffffffffc0203c2e:	6a46                	ld	s4,80(sp)
ffffffffc0203c30:	6aa6                	ld	s5,72(sp)
ffffffffc0203c32:	6b06                	ld	s6,64(sp)
ffffffffc0203c34:	7be2                	ld	s7,56(sp)
ffffffffc0203c36:	7c42                	ld	s8,48(sp)
ffffffffc0203c38:	7ca2                	ld	s9,40(sp)
ffffffffc0203c3a:	7d02                	ld	s10,32(sp)
ffffffffc0203c3c:	6de2                	ld	s11,24(sp)
ffffffffc0203c3e:	6109                	addi	sp,sp,128
ffffffffc0203c40:	8082                	ret
            putch('%', putdat);
ffffffffc0203c42:	85ca                	mv	a1,s2
ffffffffc0203c44:	02500513          	li	a0,37
ffffffffc0203c48:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203c4a:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203c4e:	02500713          	li	a4,37
ffffffffc0203c52:	8c22                	mv	s8,s0
ffffffffc0203c54:	f8e785e3          	beq	a5,a4,ffffffffc0203bde <vprintfmt+0x34>
ffffffffc0203c58:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0203c5c:	1c7d                	addi	s8,s8,-1
ffffffffc0203c5e:	fee79de3          	bne	a5,a4,ffffffffc0203c58 <vprintfmt+0xae>
ffffffffc0203c62:	bfb5                	j	ffffffffc0203bde <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0203c64:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0203c68:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc0203c6a:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0203c6e:	fd06071b          	addiw	a4,a2,-48
ffffffffc0203c72:	24e56a63          	bltu	a0,a4,ffffffffc0203ec6 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc0203c76:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c78:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc0203c7a:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0203c7e:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203c82:	0197073b          	addw	a4,a4,s9
ffffffffc0203c86:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203c8a:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203c8c:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203c90:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203c92:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203c96:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc0203c9a:	feb570e3          	bgeu	a0,a1,ffffffffc0203c7a <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0203c9e:	f60d54e3          	bgez	s10,ffffffffc0203c06 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0203ca2:	8d66                	mv	s10,s9
ffffffffc0203ca4:	5cfd                	li	s9,-1
ffffffffc0203ca6:	b785                	j	ffffffffc0203c06 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ca8:	8db6                	mv	s11,a3
ffffffffc0203caa:	8462                	mv	s0,s8
ffffffffc0203cac:	bfa9                	j	ffffffffc0203c06 <vprintfmt+0x5c>
ffffffffc0203cae:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0203cb0:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0203cb2:	bf91                	j	ffffffffc0203c06 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0203cb4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203cb6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203cba:	00f74463          	blt	a4,a5,ffffffffc0203cc2 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0203cbe:	1a078763          	beqz	a5,ffffffffc0203e6c <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0203cc2:	000a3603          	ld	a2,0(s4)
ffffffffc0203cc6:	46c1                	li	a3,16
ffffffffc0203cc8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203cca:	000d879b          	sext.w	a5,s11
ffffffffc0203cce:	876a                	mv	a4,s10
ffffffffc0203cd0:	85ca                	mv	a1,s2
ffffffffc0203cd2:	8526                	mv	a0,s1
ffffffffc0203cd4:	e71ff0ef          	jal	ffffffffc0203b44 <printnum>
            break;
ffffffffc0203cd8:	b719                	j	ffffffffc0203bde <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0203cda:	000a2503          	lw	a0,0(s4)
ffffffffc0203cde:	85ca                	mv	a1,s2
ffffffffc0203ce0:	0a21                	addi	s4,s4,8
ffffffffc0203ce2:	9482                	jalr	s1
            break;
ffffffffc0203ce4:	bded                	j	ffffffffc0203bde <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0203ce6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203ce8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203cec:	00f74463          	blt	a4,a5,ffffffffc0203cf4 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203cf0:	16078963          	beqz	a5,ffffffffc0203e62 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0203cf4:	000a3603          	ld	a2,0(s4)
ffffffffc0203cf8:	46a9                	li	a3,10
ffffffffc0203cfa:	8a2e                	mv	s4,a1
ffffffffc0203cfc:	b7f9                	j	ffffffffc0203cca <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0203cfe:	85ca                	mv	a1,s2
ffffffffc0203d00:	03000513          	li	a0,48
ffffffffc0203d04:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0203d06:	85ca                	mv	a1,s2
ffffffffc0203d08:	07800513          	li	a0,120
ffffffffc0203d0c:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d0e:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0203d12:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d14:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203d16:	bf55                	j	ffffffffc0203cca <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0203d18:	85ca                	mv	a1,s2
ffffffffc0203d1a:	02500513          	li	a0,37
ffffffffc0203d1e:	9482                	jalr	s1
            break;
ffffffffc0203d20:	bd7d                	j	ffffffffc0203bde <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0203d22:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d26:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0203d28:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0203d2a:	bf95                	j	ffffffffc0203c9e <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0203d2c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203d2e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203d32:	00f74463          	blt	a4,a5,ffffffffc0203d3a <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0203d36:	12078163          	beqz	a5,ffffffffc0203e58 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc0203d3a:	000a3603          	ld	a2,0(s4)
ffffffffc0203d3e:	46a1                	li	a3,8
ffffffffc0203d40:	8a2e                	mv	s4,a1
ffffffffc0203d42:	b761                	j	ffffffffc0203cca <vprintfmt+0x120>
            if (width < 0)
ffffffffc0203d44:	876a                	mv	a4,s10
ffffffffc0203d46:	000d5363          	bgez	s10,ffffffffc0203d4c <vprintfmt+0x1a2>
ffffffffc0203d4a:	4701                	li	a4,0
ffffffffc0203d4c:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d50:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0203d52:	bd55                	j	ffffffffc0203c06 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0203d54:	000d841b          	sext.w	s0,s11
ffffffffc0203d58:	fd340793          	addi	a5,s0,-45
ffffffffc0203d5c:	00f037b3          	snez	a5,a5
ffffffffc0203d60:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d64:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc0203d68:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d6a:	008a0793          	addi	a5,s4,8
ffffffffc0203d6e:	e43e                	sd	a5,8(sp)
ffffffffc0203d70:	100d8c63          	beqz	s11,ffffffffc0203e88 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0203d74:	12071363          	bnez	a4,ffffffffc0203e9a <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d78:	000dc783          	lbu	a5,0(s11)
ffffffffc0203d7c:	0007851b          	sext.w	a0,a5
ffffffffc0203d80:	c78d                	beqz	a5,ffffffffc0203daa <vprintfmt+0x200>
ffffffffc0203d82:	0d85                	addi	s11,s11,1
ffffffffc0203d84:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d86:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d8a:	000cc563          	bltz	s9,ffffffffc0203d94 <vprintfmt+0x1ea>
ffffffffc0203d8e:	3cfd                	addiw	s9,s9,-1
ffffffffc0203d90:	008c8d63          	beq	s9,s0,ffffffffc0203daa <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d94:	020b9663          	bnez	s7,ffffffffc0203dc0 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0203d98:	85ca                	mv	a1,s2
ffffffffc0203d9a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d9c:	000dc783          	lbu	a5,0(s11)
ffffffffc0203da0:	0d85                	addi	s11,s11,1
ffffffffc0203da2:	3d7d                	addiw	s10,s10,-1
ffffffffc0203da4:	0007851b          	sext.w	a0,a5
ffffffffc0203da8:	f3ed                	bnez	a5,ffffffffc0203d8a <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0203daa:	01a05963          	blez	s10,ffffffffc0203dbc <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0203dae:	85ca                	mv	a1,s2
ffffffffc0203db0:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0203db4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0203db6:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0203db8:	fe0d1be3          	bnez	s10,ffffffffc0203dae <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203dbc:	6a22                	ld	s4,8(sp)
ffffffffc0203dbe:	b505                	j	ffffffffc0203bde <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203dc0:	3781                	addiw	a5,a5,-32
ffffffffc0203dc2:	fcfa7be3          	bgeu	s4,a5,ffffffffc0203d98 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0203dc6:	03f00513          	li	a0,63
ffffffffc0203dca:	85ca                	mv	a1,s2
ffffffffc0203dcc:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203dce:	000dc783          	lbu	a5,0(s11)
ffffffffc0203dd2:	0d85                	addi	s11,s11,1
ffffffffc0203dd4:	3d7d                	addiw	s10,s10,-1
ffffffffc0203dd6:	0007851b          	sext.w	a0,a5
ffffffffc0203dda:	dbe1                	beqz	a5,ffffffffc0203daa <vprintfmt+0x200>
ffffffffc0203ddc:	fa0cd9e3          	bgez	s9,ffffffffc0203d8e <vprintfmt+0x1e4>
ffffffffc0203de0:	b7c5                	j	ffffffffc0203dc0 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0203de2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203de6:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc0203de8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203dea:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0203dee:	8fb9                	xor	a5,a5,a4
ffffffffc0203df0:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203df4:	02d64563          	blt	a2,a3,ffffffffc0203e1e <vprintfmt+0x274>
ffffffffc0203df8:	00002797          	auipc	a5,0x2
ffffffffc0203dfc:	c4878793          	addi	a5,a5,-952 # ffffffffc0205a40 <error_string>
ffffffffc0203e00:	00369713          	slli	a4,a3,0x3
ffffffffc0203e04:	97ba                	add	a5,a5,a4
ffffffffc0203e06:	639c                	ld	a5,0(a5)
ffffffffc0203e08:	cb99                	beqz	a5,ffffffffc0203e1e <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203e0a:	86be                	mv	a3,a5
ffffffffc0203e0c:	00000617          	auipc	a2,0x0
ffffffffc0203e10:	14460613          	addi	a2,a2,324 # ffffffffc0203f50 <etext+0x2a>
ffffffffc0203e14:	85ca                	mv	a1,s2
ffffffffc0203e16:	8526                	mv	a0,s1
ffffffffc0203e18:	0d8000ef          	jal	ffffffffc0203ef0 <printfmt>
ffffffffc0203e1c:	b3c9                	j	ffffffffc0203bde <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203e1e:	00002617          	auipc	a2,0x2
ffffffffc0203e22:	94a60613          	addi	a2,a2,-1718 # ffffffffc0205768 <etext+0x1842>
ffffffffc0203e26:	85ca                	mv	a1,s2
ffffffffc0203e28:	8526                	mv	a0,s1
ffffffffc0203e2a:	0c6000ef          	jal	ffffffffc0203ef0 <printfmt>
ffffffffc0203e2e:	bb45                	j	ffffffffc0203bde <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0203e30:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203e32:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0203e36:	00f74363          	blt	a4,a5,ffffffffc0203e3c <vprintfmt+0x292>
    else if (lflag) {
ffffffffc0203e3a:	cf81                	beqz	a5,ffffffffc0203e52 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0203e3c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203e40:	02044b63          	bltz	s0,ffffffffc0203e76 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0203e44:	8622                	mv	a2,s0
ffffffffc0203e46:	8a5e                	mv	s4,s7
ffffffffc0203e48:	46a9                	li	a3,10
ffffffffc0203e4a:	b541                	j	ffffffffc0203cca <vprintfmt+0x120>
            lflag ++;
ffffffffc0203e4c:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e4e:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0203e50:	bb5d                	j	ffffffffc0203c06 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0203e52:	000a2403          	lw	s0,0(s4)
ffffffffc0203e56:	b7ed                	j	ffffffffc0203e40 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0203e58:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e5c:	46a1                	li	a3,8
ffffffffc0203e5e:	8a2e                	mv	s4,a1
ffffffffc0203e60:	b5ad                	j	ffffffffc0203cca <vprintfmt+0x120>
ffffffffc0203e62:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e66:	46a9                	li	a3,10
ffffffffc0203e68:	8a2e                	mv	s4,a1
ffffffffc0203e6a:	b585                	j	ffffffffc0203cca <vprintfmt+0x120>
ffffffffc0203e6c:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e70:	46c1                	li	a3,16
ffffffffc0203e72:	8a2e                	mv	s4,a1
ffffffffc0203e74:	bd99                	j	ffffffffc0203cca <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0203e76:	85ca                	mv	a1,s2
ffffffffc0203e78:	02d00513          	li	a0,45
ffffffffc0203e7c:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0203e7e:	40800633          	neg	a2,s0
ffffffffc0203e82:	8a5e                	mv	s4,s7
ffffffffc0203e84:	46a9                	li	a3,10
ffffffffc0203e86:	b591                	j	ffffffffc0203cca <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0203e88:	e329                	bnez	a4,ffffffffc0203eca <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e8a:	02800793          	li	a5,40
ffffffffc0203e8e:	853e                	mv	a0,a5
ffffffffc0203e90:	00002d97          	auipc	s11,0x2
ffffffffc0203e94:	8d1d8d93          	addi	s11,s11,-1839 # ffffffffc0205761 <etext+0x183b>
ffffffffc0203e98:	b5f5                	j	ffffffffc0203d84 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e9a:	85e6                	mv	a1,s9
ffffffffc0203e9c:	856e                	mv	a0,s11
ffffffffc0203e9e:	bbdff0ef          	jal	ffffffffc0203a5a <strnlen>
ffffffffc0203ea2:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0203ea6:	01a05863          	blez	s10,ffffffffc0203eb6 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0203eaa:	85ca                	mv	a1,s2
ffffffffc0203eac:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203eae:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0203eb0:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203eb2:	fe0d1ce3          	bnez	s10,ffffffffc0203eaa <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203eb6:	000dc783          	lbu	a5,0(s11)
ffffffffc0203eba:	0007851b          	sext.w	a0,a5
ffffffffc0203ebe:	ec0792e3          	bnez	a5,ffffffffc0203d82 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203ec2:	6a22                	ld	s4,8(sp)
ffffffffc0203ec4:	bb29                	j	ffffffffc0203bde <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec6:	8462                	mv	s0,s8
ffffffffc0203ec8:	bbd9                	j	ffffffffc0203c9e <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203eca:	85e6                	mv	a1,s9
ffffffffc0203ecc:	00002517          	auipc	a0,0x2
ffffffffc0203ed0:	89450513          	addi	a0,a0,-1900 # ffffffffc0205760 <etext+0x183a>
ffffffffc0203ed4:	b87ff0ef          	jal	ffffffffc0203a5a <strnlen>
ffffffffc0203ed8:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203edc:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0203ee0:	00002d97          	auipc	s11,0x2
ffffffffc0203ee4:	880d8d93          	addi	s11,s11,-1920 # ffffffffc0205760 <etext+0x183a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ee8:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203eea:	fda040e3          	bgtz	s10,ffffffffc0203eaa <vprintfmt+0x300>
ffffffffc0203eee:	bd51                	j	ffffffffc0203d82 <vprintfmt+0x1d8>

ffffffffc0203ef0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ef0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203ef2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ef6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203ef8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203efa:	ec06                	sd	ra,24(sp)
ffffffffc0203efc:	f83a                	sd	a4,48(sp)
ffffffffc0203efe:	fc3e                	sd	a5,56(sp)
ffffffffc0203f00:	e0c2                	sd	a6,64(sp)
ffffffffc0203f02:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203f04:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203f06:	ca5ff0ef          	jal	ffffffffc0203baa <vprintfmt>
}
ffffffffc0203f0a:	60e2                	ld	ra,24(sp)
ffffffffc0203f0c:	6161                	addi	sp,sp,80
ffffffffc0203f0e:	8082                	ret

ffffffffc0203f10 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0203f10:	9e3707b7          	lui	a5,0x9e370
ffffffffc0203f14:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <kern_entry-0x21e8ffff>
ffffffffc0203f16:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc0203f1a:	02000513          	li	a0,32
ffffffffc0203f1e:	9d0d                	subw	a0,a0,a1
}
ffffffffc0203f20:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0203f24:	8082                	ret
