
bin/kernel:     file format elf64-littleriscv


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
ffffffffc0200056:	49260613          	addi	a2,a2,1170 # ffffffffc020d4e4 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	269030ef          	jal	ra,ffffffffc0203aca <memset>
    dtb_init();
ffffffffc0200066:	452000ef          	jal	ra,ffffffffc02004b8 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	053000ef          	jal	ra,ffffffffc02008bc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	eb258593          	addi	a1,a1,-334 # ffffffffc0203f20 <etext+0x4>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	eca50513          	addi	a0,a0,-310 # ffffffffc0203f40 <etext+0x24>
ffffffffc020007e:	062000ef          	jal	ra,ffffffffc02000e0 <cprintf>

    print_kerninfo();
ffffffffc0200082:	1b8000ef          	jal	ra,ffffffffc020023a <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	59a020ef          	jal	ra,ffffffffc0202620 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	0a5000ef          	jal	ra,ffffffffc020092e <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	0af000ef          	jal	ra,ffffffffc020093c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	6d9000ef          	jal	ra,ffffffffc0200f6a <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	660030ef          	jal	ra,ffffffffc02036f6 <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	7ce000ef          	jal	ra,ffffffffc0200868 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	093000ef          	jal	ra,ffffffffc0200930 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	0a3030ef          	jal	ra,ffffffffc0203944 <cpu_idle>

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
ffffffffc02000ae:	011000ef          	jal	ra,ffffffffc02008be <cons_putc>
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
ffffffffc02000d4:	2b1030ef          	jal	ra,ffffffffc0203b84 <vprintfmt>
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
ffffffffc02000e2:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <boot_page_table_sv39+0x28>
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
ffffffffc020010a:	27b030ef          	jal	ra,ffffffffc0203b84 <vprintfmt>
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
ffffffffc0200116:	7a80006f          	j	ffffffffc02008be <cons_putc>

ffffffffc020011a <getchar>:
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020011a:	1141                	addi	sp,sp,-16
ffffffffc020011c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020011e:	7d4000ef          	jal	ra,ffffffffc02008f2 <cons_getc>
ffffffffc0200122:	dd75                	beqz	a0,ffffffffc020011e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200124:	60a2                	ld	ra,8(sp)
ffffffffc0200126:	0141                	addi	sp,sp,16
ffffffffc0200128:	8082                	ret

ffffffffc020012a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020012a:	715d                	addi	sp,sp,-80
ffffffffc020012c:	e486                	sd	ra,72(sp)
ffffffffc020012e:	e0a6                	sd	s1,64(sp)
ffffffffc0200130:	fc4a                	sd	s2,56(sp)
ffffffffc0200132:	f84e                	sd	s3,48(sp)
ffffffffc0200134:	f452                	sd	s4,40(sp)
ffffffffc0200136:	f056                	sd	s5,32(sp)
ffffffffc0200138:	ec5a                	sd	s6,24(sp)
ffffffffc020013a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020013c:	c901                	beqz	a0,ffffffffc020014c <readline+0x22>
ffffffffc020013e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0200140:	00004517          	auipc	a0,0x4
ffffffffc0200144:	e0850513          	addi	a0,a0,-504 # ffffffffc0203f48 <etext+0x2c>
ffffffffc0200148:	f99ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
readline(const char *prompt) {
ffffffffc020014c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020014e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0200150:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0200152:	4aa9                	li	s5,10
ffffffffc0200154:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200156:	00009b97          	auipc	s7,0x9
ffffffffc020015a:	edab8b93          	addi	s7,s7,-294 # ffffffffc0209030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020015e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0200162:	fb9ff0ef          	jal	ra,ffffffffc020011a <getchar>
        if (c < 0) {
ffffffffc0200166:	00054a63          	bltz	a0,ffffffffc020017a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020016a:	00a95a63          	bge	s2,a0,ffffffffc020017e <readline+0x54>
ffffffffc020016e:	029a5263          	bge	s4,s1,ffffffffc0200192 <readline+0x68>
        c = getchar();
ffffffffc0200172:	fa9ff0ef          	jal	ra,ffffffffc020011a <getchar>
        if (c < 0) {
ffffffffc0200176:	fe055ae3          	bgez	a0,ffffffffc020016a <readline+0x40>
            return NULL;
ffffffffc020017a:	4501                	li	a0,0
ffffffffc020017c:	a091                	j	ffffffffc02001c0 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020017e:	03351463          	bne	a0,s3,ffffffffc02001a6 <readline+0x7c>
ffffffffc0200182:	e8a9                	bnez	s1,ffffffffc02001d4 <readline+0xaa>
        c = getchar();
ffffffffc0200184:	f97ff0ef          	jal	ra,ffffffffc020011a <getchar>
        if (c < 0) {
ffffffffc0200188:	fe0549e3          	bltz	a0,ffffffffc020017a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020018c:	fea959e3          	bge	s2,a0,ffffffffc020017e <readline+0x54>
ffffffffc0200190:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200192:	e42a                	sd	a0,8(sp)
ffffffffc0200194:	f83ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i ++] = c;
ffffffffc0200198:	6522                	ld	a0,8(sp)
ffffffffc020019a:	009b87b3          	add	a5,s7,s1
ffffffffc020019e:	2485                	addiw	s1,s1,1
ffffffffc02001a0:	00a78023          	sb	a0,0(a5)
ffffffffc02001a4:	bf7d                	j	ffffffffc0200162 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02001a6:	01550463          	beq	a0,s5,ffffffffc02001ae <readline+0x84>
ffffffffc02001aa:	fb651ce3          	bne	a0,s6,ffffffffc0200162 <readline+0x38>
            cputchar(c);
ffffffffc02001ae:	f69ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            buf[i] = '\0';
ffffffffc02001b2:	00009517          	auipc	a0,0x9
ffffffffc02001b6:	e7e50513          	addi	a0,a0,-386 # ffffffffc0209030 <buf>
ffffffffc02001ba:	94aa                	add	s1,s1,a0
ffffffffc02001bc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001c0:	60a6                	ld	ra,72(sp)
ffffffffc02001c2:	6486                	ld	s1,64(sp)
ffffffffc02001c4:	7962                	ld	s2,56(sp)
ffffffffc02001c6:	79c2                	ld	s3,48(sp)
ffffffffc02001c8:	7a22                	ld	s4,40(sp)
ffffffffc02001ca:	7a82                	ld	s5,32(sp)
ffffffffc02001cc:	6b62                	ld	s6,24(sp)
ffffffffc02001ce:	6bc2                	ld	s7,16(sp)
ffffffffc02001d0:	6161                	addi	sp,sp,80
ffffffffc02001d2:	8082                	ret
            cputchar(c);
ffffffffc02001d4:	4521                	li	a0,8
ffffffffc02001d6:	f41ff0ef          	jal	ra,ffffffffc0200116 <cputchar>
            i --;
ffffffffc02001da:	34fd                	addiw	s1,s1,-1
ffffffffc02001dc:	b759                	j	ffffffffc0200162 <readline+0x38>

ffffffffc02001de <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001de:	0000d317          	auipc	t1,0xd
ffffffffc02001e2:	28a30313          	addi	t1,t1,650 # ffffffffc020d468 <is_panic>
ffffffffc02001e6:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ea:	715d                	addi	sp,sp,-80
ffffffffc02001ec:	ec06                	sd	ra,24(sp)
ffffffffc02001ee:	e822                	sd	s0,16(sp)
ffffffffc02001f0:	f436                	sd	a3,40(sp)
ffffffffc02001f2:	f83a                	sd	a4,48(sp)
ffffffffc02001f4:	fc3e                	sd	a5,56(sp)
ffffffffc02001f6:	e0c2                	sd	a6,64(sp)
ffffffffc02001f8:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001fa:	020e1a63          	bnez	t3,ffffffffc020022e <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001fe:	4785                	li	a5,1
ffffffffc0200200:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200204:	8432                	mv	s0,a2
ffffffffc0200206:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200208:	862e                	mv	a2,a1
ffffffffc020020a:	85aa                	mv	a1,a0
ffffffffc020020c:	00004517          	auipc	a0,0x4
ffffffffc0200210:	d4450513          	addi	a0,a0,-700 # ffffffffc0203f50 <etext+0x34>
    va_start(ap, fmt);
ffffffffc0200214:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200216:	ecbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020021a:	65a2                	ld	a1,8(sp)
ffffffffc020021c:	8522                	mv	a0,s0
ffffffffc020021e:	ea3ff0ef          	jal	ra,ffffffffc02000c0 <vcprintf>
    cprintf("\n");
ffffffffc0200222:	00005517          	auipc	a0,0x5
ffffffffc0200226:	33e50513          	addi	a0,a0,830 # ffffffffc0205560 <default_pmm_manager+0x440>
ffffffffc020022a:	eb7ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc020022e:	708000ef          	jal	ra,ffffffffc0200936 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200232:	4501                	li	a0,0
ffffffffc0200234:	130000ef          	jal	ra,ffffffffc0200364 <kmonitor>
    while (1) {
ffffffffc0200238:	bfed                	j	ffffffffc0200232 <__panic+0x54>

ffffffffc020023a <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc020023a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020023c:	00004517          	auipc	a0,0x4
ffffffffc0200240:	d3450513          	addi	a0,a0,-716 # ffffffffc0203f70 <etext+0x54>
{
ffffffffc0200244:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200246:	e9bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020024a:	00000597          	auipc	a1,0x0
ffffffffc020024e:	e0058593          	addi	a1,a1,-512 # ffffffffc020004a <kern_init>
ffffffffc0200252:	00004517          	auipc	a0,0x4
ffffffffc0200256:	d3e50513          	addi	a0,a0,-706 # ffffffffc0203f90 <etext+0x74>
ffffffffc020025a:	e87ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025e:	00004597          	auipc	a1,0x4
ffffffffc0200262:	cbe58593          	addi	a1,a1,-834 # ffffffffc0203f1c <etext>
ffffffffc0200266:	00004517          	auipc	a0,0x4
ffffffffc020026a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0203fb0 <etext+0x94>
ffffffffc020026e:	e73ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200272:	00009597          	auipc	a1,0x9
ffffffffc0200276:	dbe58593          	addi	a1,a1,-578 # ffffffffc0209030 <buf>
ffffffffc020027a:	00004517          	auipc	a0,0x4
ffffffffc020027e:	d5650513          	addi	a0,a0,-682 # ffffffffc0203fd0 <etext+0xb4>
ffffffffc0200282:	e5fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200286:	0000d597          	auipc	a1,0xd
ffffffffc020028a:	25e58593          	addi	a1,a1,606 # ffffffffc020d4e4 <end>
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	d6250513          	addi	a0,a0,-670 # ffffffffc0203ff0 <etext+0xd4>
ffffffffc0200296:	e4bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020029a:	0000d597          	auipc	a1,0xd
ffffffffc020029e:	64958593          	addi	a1,a1,1609 # ffffffffc020d8e3 <end+0x3ff>
ffffffffc02002a2:	00000797          	auipc	a5,0x0
ffffffffc02002a6:	da878793          	addi	a5,a5,-600 # ffffffffc020004a <kern_init>
ffffffffc02002aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002b8:	95be                	add	a1,a1,a5
ffffffffc02002ba:	85a9                	srai	a1,a1,0xa
ffffffffc02002bc:	00004517          	auipc	a0,0x4
ffffffffc02002c0:	d5450513          	addi	a0,a0,-684 # ffffffffc0204010 <etext+0xf4>
}
ffffffffc02002c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002c6:	bd29                	j	ffffffffc02000e0 <cprintf>

ffffffffc02002c8 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002c8:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002ca:	00004617          	auipc	a2,0x4
ffffffffc02002ce:	d7660613          	addi	a2,a2,-650 # ffffffffc0204040 <etext+0x124>
ffffffffc02002d2:	04900593          	li	a1,73
ffffffffc02002d6:	00004517          	auipc	a0,0x4
ffffffffc02002da:	d8250513          	addi	a0,a0,-638 # ffffffffc0204058 <etext+0x13c>
{
ffffffffc02002de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002e0:	effff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02002e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	00004617          	auipc	a2,0x4
ffffffffc02002ea:	d8a60613          	addi	a2,a2,-630 # ffffffffc0204070 <etext+0x154>
ffffffffc02002ee:	00004597          	auipc	a1,0x4
ffffffffc02002f2:	da258593          	addi	a1,a1,-606 # ffffffffc0204090 <etext+0x174>
ffffffffc02002f6:	00004517          	auipc	a0,0x4
ffffffffc02002fa:	da250513          	addi	a0,a0,-606 # ffffffffc0204098 <etext+0x17c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200300:	de1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200304:	00004617          	auipc	a2,0x4
ffffffffc0200308:	da460613          	addi	a2,a2,-604 # ffffffffc02040a8 <etext+0x18c>
ffffffffc020030c:	00004597          	auipc	a1,0x4
ffffffffc0200310:	dc458593          	addi	a1,a1,-572 # ffffffffc02040d0 <etext+0x1b4>
ffffffffc0200314:	00004517          	auipc	a0,0x4
ffffffffc0200318:	d8450513          	addi	a0,a0,-636 # ffffffffc0204098 <etext+0x17c>
ffffffffc020031c:	dc5ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200320:	00004617          	auipc	a2,0x4
ffffffffc0200324:	dc060613          	addi	a2,a2,-576 # ffffffffc02040e0 <etext+0x1c4>
ffffffffc0200328:	00004597          	auipc	a1,0x4
ffffffffc020032c:	dd858593          	addi	a1,a1,-552 # ffffffffc0204100 <etext+0x1e4>
ffffffffc0200330:	00004517          	auipc	a0,0x4
ffffffffc0200334:	d6850513          	addi	a0,a0,-664 # ffffffffc0204098 <etext+0x17c>
ffffffffc0200338:	da9ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    return 0;
}
ffffffffc020033c:	60a2                	ld	ra,8(sp)
ffffffffc020033e:	4501                	li	a0,0
ffffffffc0200340:	0141                	addi	sp,sp,16
ffffffffc0200342:	8082                	ret

ffffffffc0200344 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200344:	1141                	addi	sp,sp,-16
ffffffffc0200346:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200348:	ef3ff0ef          	jal	ra,ffffffffc020023a <print_kerninfo>
    return 0;
}
ffffffffc020034c:	60a2                	ld	ra,8(sp)
ffffffffc020034e:	4501                	li	a0,0
ffffffffc0200350:	0141                	addi	sp,sp,16
ffffffffc0200352:	8082                	ret

ffffffffc0200354 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200354:	1141                	addi	sp,sp,-16
ffffffffc0200356:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200358:	f71ff0ef          	jal	ra,ffffffffc02002c8 <print_stackframe>
    return 0;
}
ffffffffc020035c:	60a2                	ld	ra,8(sp)
ffffffffc020035e:	4501                	li	a0,0
ffffffffc0200360:	0141                	addi	sp,sp,16
ffffffffc0200362:	8082                	ret

ffffffffc0200364 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200364:	7115                	addi	sp,sp,-224
ffffffffc0200366:	ed5e                	sd	s7,152(sp)
ffffffffc0200368:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020036a:	00004517          	auipc	a0,0x4
ffffffffc020036e:	da650513          	addi	a0,a0,-602 # ffffffffc0204110 <etext+0x1f4>
kmonitor(struct trapframe *tf) {
ffffffffc0200372:	ed86                	sd	ra,216(sp)
ffffffffc0200374:	e9a2                	sd	s0,208(sp)
ffffffffc0200376:	e5a6                	sd	s1,200(sp)
ffffffffc0200378:	e1ca                	sd	s2,192(sp)
ffffffffc020037a:	fd4e                	sd	s3,184(sp)
ffffffffc020037c:	f952                	sd	s4,176(sp)
ffffffffc020037e:	f556                	sd	s5,168(sp)
ffffffffc0200380:	f15a                	sd	s6,160(sp)
ffffffffc0200382:	e962                	sd	s8,144(sp)
ffffffffc0200384:	e566                	sd	s9,136(sp)
ffffffffc0200386:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200388:	d59ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020038c:	00004517          	auipc	a0,0x4
ffffffffc0200390:	dac50513          	addi	a0,a0,-596 # ffffffffc0204138 <etext+0x21c>
ffffffffc0200394:	d4dff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    if (tf != NULL) {
ffffffffc0200398:	000b8563          	beqz	s7,ffffffffc02003a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020039c:	855e                	mv	a0,s7
ffffffffc020039e:	786000ef          	jal	ra,ffffffffc0200b24 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02003a2:	4501                	li	a0,0
ffffffffc02003a4:	4581                	li	a1,0
ffffffffc02003a6:	4601                	li	a2,0
ffffffffc02003a8:	48a1                	li	a7,8
ffffffffc02003aa:	00000073          	ecall
ffffffffc02003ae:	00004c17          	auipc	s8,0x4
ffffffffc02003b2:	dfac0c13          	addi	s8,s8,-518 # ffffffffc02041a8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b6:	00004917          	auipc	s2,0x4
ffffffffc02003ba:	daa90913          	addi	s2,s2,-598 # ffffffffc0204160 <etext+0x244>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003be:	00004497          	auipc	s1,0x4
ffffffffc02003c2:	daa48493          	addi	s1,s1,-598 # ffffffffc0204168 <etext+0x24c>
        if (argc == MAXARGS - 1) {
ffffffffc02003c6:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c8:	00004b17          	auipc	s6,0x4
ffffffffc02003cc:	da8b0b13          	addi	s6,s6,-600 # ffffffffc0204170 <etext+0x254>
        argv[argc ++] = buf;
ffffffffc02003d0:	00004a17          	auipc	s4,0x4
ffffffffc02003d4:	cc0a0a13          	addi	s4,s4,-832 # ffffffffc0204090 <etext+0x174>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d8:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003da:	854a                	mv	a0,s2
ffffffffc02003dc:	d4fff0ef          	jal	ra,ffffffffc020012a <readline>
ffffffffc02003e0:	842a                	mv	s0,a0
ffffffffc02003e2:	dd65                	beqz	a0,ffffffffc02003da <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003e4:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003e8:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ea:	e1bd                	bnez	a1,ffffffffc0200450 <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003ec:	fe0c87e3          	beqz	s9,ffffffffc02003da <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f0:	6582                	ld	a1,0(sp)
ffffffffc02003f2:	00004d17          	auipc	s10,0x4
ffffffffc02003f6:	db6d0d13          	addi	s10,s10,-586 # ffffffffc02041a8 <commands>
        argv[argc ++] = buf;
ffffffffc02003fa:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	4401                	li	s0,0
ffffffffc02003fe:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200400:	670030ef          	jal	ra,ffffffffc0203a70 <strcmp>
ffffffffc0200404:	c919                	beqz	a0,ffffffffc020041a <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200406:	2405                	addiw	s0,s0,1
ffffffffc0200408:	0b540063          	beq	s0,s5,ffffffffc02004a8 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020040c:	000d3503          	ld	a0,0(s10)
ffffffffc0200410:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200412:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200414:	65c030ef          	jal	ra,ffffffffc0203a70 <strcmp>
ffffffffc0200418:	f57d                	bnez	a0,ffffffffc0200406 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020041a:	00141793          	slli	a5,s0,0x1
ffffffffc020041e:	97a2                	add	a5,a5,s0
ffffffffc0200420:	078e                	slli	a5,a5,0x3
ffffffffc0200422:	97e2                	add	a5,a5,s8
ffffffffc0200424:	6b9c                	ld	a5,16(a5)
ffffffffc0200426:	865e                	mv	a2,s7
ffffffffc0200428:	002c                	addi	a1,sp,8
ffffffffc020042a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020042e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200430:	fa0555e3          	bgez	a0,ffffffffc02003da <kmonitor+0x76>
}
ffffffffc0200434:	60ee                	ld	ra,216(sp)
ffffffffc0200436:	644e                	ld	s0,208(sp)
ffffffffc0200438:	64ae                	ld	s1,200(sp)
ffffffffc020043a:	690e                	ld	s2,192(sp)
ffffffffc020043c:	79ea                	ld	s3,184(sp)
ffffffffc020043e:	7a4a                	ld	s4,176(sp)
ffffffffc0200440:	7aaa                	ld	s5,168(sp)
ffffffffc0200442:	7b0a                	ld	s6,160(sp)
ffffffffc0200444:	6bea                	ld	s7,152(sp)
ffffffffc0200446:	6c4a                	ld	s8,144(sp)
ffffffffc0200448:	6caa                	ld	s9,136(sp)
ffffffffc020044a:	6d0a                	ld	s10,128(sp)
ffffffffc020044c:	612d                	addi	sp,sp,224
ffffffffc020044e:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	662030ef          	jal	ra,ffffffffc0203ab4 <strchr>
ffffffffc0200456:	c901                	beqz	a0,ffffffffc0200466 <kmonitor+0x102>
ffffffffc0200458:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020045c:	00040023          	sb	zero,0(s0)
ffffffffc0200460:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200462:	d5c9                	beqz	a1,ffffffffc02003ec <kmonitor+0x88>
ffffffffc0200464:	b7f5                	j	ffffffffc0200450 <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200466:	00044783          	lbu	a5,0(s0)
ffffffffc020046a:	d3c9                	beqz	a5,ffffffffc02003ec <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc020046c:	033c8963          	beq	s9,s3,ffffffffc020049e <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc0200470:	003c9793          	slli	a5,s9,0x3
ffffffffc0200474:	0118                	addi	a4,sp,128
ffffffffc0200476:	97ba                	add	a5,a5,a4
ffffffffc0200478:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020047c:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200480:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200482:	e591                	bnez	a1,ffffffffc020048e <kmonitor+0x12a>
ffffffffc0200484:	b7b5                	j	ffffffffc02003f0 <kmonitor+0x8c>
ffffffffc0200486:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020048a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020048c:	d1a5                	beqz	a1,ffffffffc02003ec <kmonitor+0x88>
ffffffffc020048e:	8526                	mv	a0,s1
ffffffffc0200490:	624030ef          	jal	ra,ffffffffc0203ab4 <strchr>
ffffffffc0200494:	d96d                	beqz	a0,ffffffffc0200486 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200496:	00044583          	lbu	a1,0(s0)
ffffffffc020049a:	d9a9                	beqz	a1,ffffffffc02003ec <kmonitor+0x88>
ffffffffc020049c:	bf55                	j	ffffffffc0200450 <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020049e:	45c1                	li	a1,16
ffffffffc02004a0:	855a                	mv	a0,s6
ffffffffc02004a2:	c3fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02004a6:	b7e9                	j	ffffffffc0200470 <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02004a8:	6582                	ld	a1,0(sp)
ffffffffc02004aa:	00004517          	auipc	a0,0x4
ffffffffc02004ae:	ce650513          	addi	a0,a0,-794 # ffffffffc0204190 <etext+0x274>
ffffffffc02004b2:	c2fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    return 0;
ffffffffc02004b6:	b715                	j	ffffffffc02003da <kmonitor+0x76>

ffffffffc02004b8 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02004b8:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc02004ba:	00004517          	auipc	a0,0x4
ffffffffc02004be:	d3650513          	addi	a0,a0,-714 # ffffffffc02041f0 <commands+0x48>
void dtb_init(void) {
ffffffffc02004c2:	fc86                	sd	ra,120(sp)
ffffffffc02004c4:	f8a2                	sd	s0,112(sp)
ffffffffc02004c6:	e8d2                	sd	s4,80(sp)
ffffffffc02004c8:	f4a6                	sd	s1,104(sp)
ffffffffc02004ca:	f0ca                	sd	s2,96(sp)
ffffffffc02004cc:	ecce                	sd	s3,88(sp)
ffffffffc02004ce:	e4d6                	sd	s5,72(sp)
ffffffffc02004d0:	e0da                	sd	s6,64(sp)
ffffffffc02004d2:	fc5e                	sd	s7,56(sp)
ffffffffc02004d4:	f862                	sd	s8,48(sp)
ffffffffc02004d6:	f466                	sd	s9,40(sp)
ffffffffc02004d8:	f06a                	sd	s10,32(sp)
ffffffffc02004da:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc02004dc:	c05ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02004e0:	00009597          	auipc	a1,0x9
ffffffffc02004e4:	b205b583          	ld	a1,-1248(a1) # ffffffffc0209000 <boot_hartid>
ffffffffc02004e8:	00004517          	auipc	a0,0x4
ffffffffc02004ec:	d1850513          	addi	a0,a0,-744 # ffffffffc0204200 <commands+0x58>
ffffffffc02004f0:	bf1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02004f4:	00009417          	auipc	s0,0x9
ffffffffc02004f8:	b1440413          	addi	s0,s0,-1260 # ffffffffc0209008 <boot_dtb>
ffffffffc02004fc:	600c                	ld	a1,0(s0)
ffffffffc02004fe:	00004517          	auipc	a0,0x4
ffffffffc0200502:	d1250513          	addi	a0,a0,-750 # ffffffffc0204210 <commands+0x68>
ffffffffc0200506:	bdbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020050a:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020050e:	00004517          	auipc	a0,0x4
ffffffffc0200512:	d1a50513          	addi	a0,a0,-742 # ffffffffc0204228 <commands+0x80>
    if (boot_dtb == 0) {
ffffffffc0200516:	120a0463          	beqz	s4,ffffffffc020063e <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc020051a:	57f5                	li	a5,-3
ffffffffc020051c:	07fa                	slli	a5,a5,0x1e
ffffffffc020051e:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200522:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200524:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200528:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020052e:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200532:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200536:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020053a:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020053e:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200540:	8ec9                	or	a3,a3,a0
ffffffffc0200542:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200546:	1b7d                	addi	s6,s6,-1
ffffffffc0200548:	0167f7b3          	and	a5,a5,s6
ffffffffc020054c:	8dd5                	or	a1,a1,a3
ffffffffc020054e:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc0200550:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200554:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc0200556:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed2a09>
ffffffffc020055a:	10f59163          	bne	a1,a5,ffffffffc020065c <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020055e:	471c                	lw	a5,8(a4)
ffffffffc0200560:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc0200562:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200564:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200568:	0086d51b          	srliw	a0,a3,0x8
ffffffffc020056c:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200570:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200574:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200578:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020057c:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200580:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200584:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200588:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020058c:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020058e:	01146433          	or	s0,s0,a7
ffffffffc0200592:	0086969b          	slliw	a3,a3,0x8
ffffffffc0200596:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020059a:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020059c:	0087979b          	slliw	a5,a5,0x8
ffffffffc02005a0:	8c49                	or	s0,s0,a0
ffffffffc02005a2:	0166f6b3          	and	a3,a3,s6
ffffffffc02005a6:	00ca6a33          	or	s4,s4,a2
ffffffffc02005aa:	0167f7b3          	and	a5,a5,s6
ffffffffc02005ae:	8c55                	or	s0,s0,a3
ffffffffc02005b0:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005b4:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005b6:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005b8:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005ba:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005be:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005c0:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c2:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc02005c6:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005c8:	00004917          	auipc	s2,0x4
ffffffffc02005cc:	cb090913          	addi	s2,s2,-848 # ffffffffc0204278 <commands+0xd0>
ffffffffc02005d0:	49bd                	li	s3,15
        switch (token) {
ffffffffc02005d2:	4d91                	li	s11,4
ffffffffc02005d4:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005d6:	00004497          	auipc	s1,0x4
ffffffffc02005da:	c9a48493          	addi	s1,s1,-870 # ffffffffc0204270 <commands+0xc8>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005de:	000a2703          	lw	a4,0(s4)
ffffffffc02005e2:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e6:	0087569b          	srliw	a3,a4,0x8
ffffffffc02005ea:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ee:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f2:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f6:	0107571b          	srliw	a4,a4,0x10
ffffffffc02005fa:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005fc:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200600:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200604:	8fd5                	or	a5,a5,a3
ffffffffc0200606:	00eb7733          	and	a4,s6,a4
ffffffffc020060a:	8fd9                	or	a5,a5,a4
ffffffffc020060c:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc020060e:	09778c63          	beq	a5,s7,ffffffffc02006a6 <dtb_init+0x1ee>
ffffffffc0200612:	00fbea63          	bltu	s7,a5,ffffffffc0200626 <dtb_init+0x16e>
ffffffffc0200616:	07a78663          	beq	a5,s10,ffffffffc0200682 <dtb_init+0x1ca>
ffffffffc020061a:	4709                	li	a4,2
ffffffffc020061c:	00e79763          	bne	a5,a4,ffffffffc020062a <dtb_init+0x172>
ffffffffc0200620:	4c81                	li	s9,0
ffffffffc0200622:	8a56                	mv	s4,s5
ffffffffc0200624:	bf6d                	j	ffffffffc02005de <dtb_init+0x126>
ffffffffc0200626:	ffb78ee3          	beq	a5,s11,ffffffffc0200622 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020062a:	00004517          	auipc	a0,0x4
ffffffffc020062e:	cc650513          	addi	a0,a0,-826 # ffffffffc02042f0 <commands+0x148>
ffffffffc0200632:	aafff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200636:	00004517          	auipc	a0,0x4
ffffffffc020063a:	cf250513          	addi	a0,a0,-782 # ffffffffc0204328 <commands+0x180>
}
ffffffffc020063e:	7446                	ld	s0,112(sp)
ffffffffc0200640:	70e6                	ld	ra,120(sp)
ffffffffc0200642:	74a6                	ld	s1,104(sp)
ffffffffc0200644:	7906                	ld	s2,96(sp)
ffffffffc0200646:	69e6                	ld	s3,88(sp)
ffffffffc0200648:	6a46                	ld	s4,80(sp)
ffffffffc020064a:	6aa6                	ld	s5,72(sp)
ffffffffc020064c:	6b06                	ld	s6,64(sp)
ffffffffc020064e:	7be2                	ld	s7,56(sp)
ffffffffc0200650:	7c42                	ld	s8,48(sp)
ffffffffc0200652:	7ca2                	ld	s9,40(sp)
ffffffffc0200654:	7d02                	ld	s10,32(sp)
ffffffffc0200656:	6de2                	ld	s11,24(sp)
ffffffffc0200658:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc020065a:	b459                	j	ffffffffc02000e0 <cprintf>
}
ffffffffc020065c:	7446                	ld	s0,112(sp)
ffffffffc020065e:	70e6                	ld	ra,120(sp)
ffffffffc0200660:	74a6                	ld	s1,104(sp)
ffffffffc0200662:	7906                	ld	s2,96(sp)
ffffffffc0200664:	69e6                	ld	s3,88(sp)
ffffffffc0200666:	6a46                	ld	s4,80(sp)
ffffffffc0200668:	6aa6                	ld	s5,72(sp)
ffffffffc020066a:	6b06                	ld	s6,64(sp)
ffffffffc020066c:	7be2                	ld	s7,56(sp)
ffffffffc020066e:	7c42                	ld	s8,48(sp)
ffffffffc0200670:	7ca2                	ld	s9,40(sp)
ffffffffc0200672:	7d02                	ld	s10,32(sp)
ffffffffc0200674:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200676:	00004517          	auipc	a0,0x4
ffffffffc020067a:	bd250513          	addi	a0,a0,-1070 # ffffffffc0204248 <commands+0xa0>
}
ffffffffc020067e:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200680:	b485                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200682:	8556                	mv	a0,s5
ffffffffc0200684:	3a4030ef          	jal	ra,ffffffffc0203a28 <strlen>
ffffffffc0200688:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020068a:	4619                	li	a2,6
ffffffffc020068c:	85a6                	mv	a1,s1
ffffffffc020068e:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200690:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200692:	3fc030ef          	jal	ra,ffffffffc0203a8e <strncmp>
ffffffffc0200696:	e111                	bnez	a0,ffffffffc020069a <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc0200698:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020069a:	0a91                	addi	s5,s5,4
ffffffffc020069c:	9ad2                	add	s5,s5,s4
ffffffffc020069e:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006a2:	8a56                	mv	s4,s5
ffffffffc02006a4:	bf2d                	j	ffffffffc02005de <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006a6:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006aa:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ae:	0087d71b          	srliw	a4,a5,0x8
ffffffffc02006b2:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02006c2:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c6:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ca:	0087979b          	slliw	a5,a5,0x8
ffffffffc02006ce:	00eaeab3          	or	s5,s5,a4
ffffffffc02006d2:	00fb77b3          	and	a5,s6,a5
ffffffffc02006d6:	00faeab3          	or	s5,s5,a5
ffffffffc02006da:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006dc:	000c9c63          	bnez	s9,ffffffffc02006f4 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02006e0:	1a82                	slli	s5,s5,0x20
ffffffffc02006e2:	00368793          	addi	a5,a3,3
ffffffffc02006e6:	020ada93          	srli	s5,s5,0x20
ffffffffc02006ea:	9abe                	add	s5,s5,a5
ffffffffc02006ec:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc02006f0:	8a56                	mv	s4,s5
ffffffffc02006f2:	b5f5                	j	ffffffffc02005de <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006f4:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f8:	85ca                	mv	a1,s2
ffffffffc02006fa:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006fc:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200700:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200704:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200708:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020070c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200710:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200712:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200716:	0087979b          	slliw	a5,a5,0x8
ffffffffc020071a:	8d59                	or	a0,a0,a4
ffffffffc020071c:	00fb77b3          	and	a5,s6,a5
ffffffffc0200720:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200722:	1502                	slli	a0,a0,0x20
ffffffffc0200724:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200726:	9522                	add	a0,a0,s0
ffffffffc0200728:	348030ef          	jal	ra,ffffffffc0203a70 <strcmp>
ffffffffc020072c:	66a2                	ld	a3,8(sp)
ffffffffc020072e:	f94d                	bnez	a0,ffffffffc02006e0 <dtb_init+0x228>
ffffffffc0200730:	fb59f8e3          	bgeu	s3,s5,ffffffffc02006e0 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200734:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200738:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020073c:	00004517          	auipc	a0,0x4
ffffffffc0200740:	b4450513          	addi	a0,a0,-1212 # ffffffffc0204280 <commands+0xd8>
           fdt32_to_cpu(x >> 32);
ffffffffc0200744:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200748:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc020074c:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200750:	0187de1b          	srliw	t3,a5,0x18
ffffffffc0200754:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200758:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020075c:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200760:	0187d693          	srli	a3,a5,0x18
ffffffffc0200764:	01861f1b          	slliw	t5,a2,0x18
ffffffffc0200768:	0087579b          	srliw	a5,a4,0x8
ffffffffc020076c:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200770:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200774:	010f6f33          	or	t5,t5,a6
ffffffffc0200778:	0187529b          	srliw	t0,a4,0x18
ffffffffc020077c:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200780:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200784:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200788:	0186f6b3          	and	a3,a3,s8
ffffffffc020078c:	01859e1b          	slliw	t3,a1,0x18
ffffffffc0200790:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200794:	0107581b          	srliw	a6,a4,0x10
ffffffffc0200798:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079c:	8361                	srli	a4,a4,0x18
ffffffffc020079e:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a2:	0105d59b          	srliw	a1,a1,0x10
ffffffffc02007a6:	01e6e6b3          	or	a3,a3,t5
ffffffffc02007aa:	00cb7633          	and	a2,s6,a2
ffffffffc02007ae:	0088181b          	slliw	a6,a6,0x8
ffffffffc02007b2:	0085959b          	slliw	a1,a1,0x8
ffffffffc02007b6:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ba:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007be:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007c2:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007c6:	0088989b          	slliw	a7,a7,0x8
ffffffffc02007ca:	011b78b3          	and	a7,s6,a7
ffffffffc02007ce:	005eeeb3          	or	t4,t4,t0
ffffffffc02007d2:	00c6e733          	or	a4,a3,a2
ffffffffc02007d6:	006c6c33          	or	s8,s8,t1
ffffffffc02007da:	010b76b3          	and	a3,s6,a6
ffffffffc02007de:	00bb7b33          	and	s6,s6,a1
ffffffffc02007e2:	01d7e7b3          	or	a5,a5,t4
ffffffffc02007e6:	016c6b33          	or	s6,s8,s6
ffffffffc02007ea:	01146433          	or	s0,s0,a7
ffffffffc02007ee:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc02007f0:	1702                	slli	a4,a4,0x20
ffffffffc02007f2:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007f4:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007f6:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007f8:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007fa:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007fe:	0167eb33          	or	s6,a5,s6
ffffffffc0200802:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200804:	8ddff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200808:	85a2                	mv	a1,s0
ffffffffc020080a:	00004517          	auipc	a0,0x4
ffffffffc020080e:	a9650513          	addi	a0,a0,-1386 # ffffffffc02042a0 <commands+0xf8>
ffffffffc0200812:	8cfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200816:	014b5613          	srli	a2,s6,0x14
ffffffffc020081a:	85da                	mv	a1,s6
ffffffffc020081c:	00004517          	auipc	a0,0x4
ffffffffc0200820:	a9c50513          	addi	a0,a0,-1380 # ffffffffc02042b8 <commands+0x110>
ffffffffc0200824:	8bdff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200828:	008b05b3          	add	a1,s6,s0
ffffffffc020082c:	15fd                	addi	a1,a1,-1
ffffffffc020082e:	00004517          	auipc	a0,0x4
ffffffffc0200832:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02042d8 <commands+0x130>
ffffffffc0200836:	8abff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0204328 <commands+0x180>
        memory_base = mem_base;
ffffffffc0200842:	0000d797          	auipc	a5,0xd
ffffffffc0200846:	c287b723          	sd	s0,-978(a5) # ffffffffc020d470 <memory_base>
        memory_size = mem_size;
ffffffffc020084a:	0000d797          	auipc	a5,0xd
ffffffffc020084e:	c367b723          	sd	s6,-978(a5) # ffffffffc020d478 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc0200852:	b3f5                	j	ffffffffc020063e <dtb_init+0x186>

ffffffffc0200854 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200854:	0000d517          	auipc	a0,0xd
ffffffffc0200858:	c1c53503          	ld	a0,-996(a0) # ffffffffc020d470 <memory_base>
ffffffffc020085c:	8082                	ret

ffffffffc020085e <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc020085e:	0000d517          	auipc	a0,0xd
ffffffffc0200862:	c1a53503          	ld	a0,-998(a0) # ffffffffc020d478 <memory_size>
ffffffffc0200866:	8082                	ret

ffffffffc0200868 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200868:	67e1                	lui	a5,0x18
ffffffffc020086a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020086e:	0000d717          	auipc	a4,0xd
ffffffffc0200872:	c0f73d23          	sd	a5,-998(a4) # ffffffffc020d488 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200876:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020087a:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020087c:	953e                	add	a0,a0,a5
ffffffffc020087e:	4601                	li	a2,0
ffffffffc0200880:	4881                	li	a7,0
ffffffffc0200882:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200886:	02000793          	li	a5,32
ffffffffc020088a:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020088e:	00004517          	auipc	a0,0x4
ffffffffc0200892:	ab250513          	addi	a0,a0,-1358 # ffffffffc0204340 <commands+0x198>
    ticks = 0;
ffffffffc0200896:	0000d797          	auipc	a5,0xd
ffffffffc020089a:	be07b523          	sd	zero,-1046(a5) # ffffffffc020d480 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020089e:	843ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc02008a2 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02008a2:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02008a6:	0000d797          	auipc	a5,0xd
ffffffffc02008aa:	be27b783          	ld	a5,-1054(a5) # ffffffffc020d488 <timebase>
ffffffffc02008ae:	953e                	add	a0,a0,a5
ffffffffc02008b0:	4581                	li	a1,0
ffffffffc02008b2:	4601                	li	a2,0
ffffffffc02008b4:	4881                	li	a7,0
ffffffffc02008b6:	00000073          	ecall
ffffffffc02008ba:	8082                	ret

ffffffffc02008bc <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02008bc:	8082                	ret

ffffffffc02008be <cons_putc>:
 *
 * @return true: 中断原本是开启的，已关闭
 *         false: 中断原本就是关闭的，无需操作
 */
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008be:	100027f3          	csrr	a5,sstatus
ffffffffc02008c2:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02008c4:	0ff57513          	zext.b	a0,a0
ffffffffc02008c8:	e799                	bnez	a5,ffffffffc02008d6 <cons_putc+0x18>
ffffffffc02008ca:	4581                	li	a1,0
ffffffffc02008cc:	4601                	li	a2,0
ffffffffc02008ce:	4885                	li	a7,1
ffffffffc02008d0:	00000073          	ecall
 * 离开临界区时调用，恢复进入临界区前的中断状态。
 *
 * @param flag 之前保存的中断状态
 */
static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02008d4:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02008d6:	1101                	addi	sp,sp,-32
ffffffffc02008d8:	ec06                	sd	ra,24(sp)
ffffffffc02008da:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc02008dc:	05a000ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc02008e0:	6522                	ld	a0,8(sp)
ffffffffc02008e2:	4581                	li	a1,0
ffffffffc02008e4:	4601                	li	a2,0
ffffffffc02008e6:	4885                	li	a7,1
ffffffffc02008e8:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008ec:	60e2                	ld	ra,24(sp)
ffffffffc02008ee:	6105                	addi	sp,sp,32
        intr_enable();   // 开启中断
ffffffffc02008f0:	a081                	j	ffffffffc0200930 <intr_enable>

ffffffffc02008f2 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02008f2:	100027f3          	csrr	a5,sstatus
ffffffffc02008f6:	8b89                	andi	a5,a5,2
ffffffffc02008f8:	eb89                	bnez	a5,ffffffffc020090a <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02008fa:	4501                	li	a0,0
ffffffffc02008fc:	4581                	li	a1,0
ffffffffc02008fe:	4601                	li	a2,0
ffffffffc0200900:	4889                	li	a7,2
ffffffffc0200902:	00000073          	ecall
ffffffffc0200906:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200908:	8082                	ret
int cons_getc(void) {
ffffffffc020090a:	1101                	addi	sp,sp,-32
ffffffffc020090c:	ec06                	sd	ra,24(sp)
        intr_disable();  // 关闭中断
ffffffffc020090e:	028000ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0200912:	4501                	li	a0,0
ffffffffc0200914:	4581                	li	a1,0
ffffffffc0200916:	4601                	li	a2,0
ffffffffc0200918:	4889                	li	a7,2
ffffffffc020091a:	00000073          	ecall
ffffffffc020091e:	2501                	sext.w	a0,a0
ffffffffc0200920:	e42a                	sd	a0,8(sp)
        intr_enable();   // 开启中断
ffffffffc0200922:	00e000ef          	jal	ra,ffffffffc0200930 <intr_enable>
}
ffffffffc0200926:	60e2                	ld	ra,24(sp)
ffffffffc0200928:	6522                	ld	a0,8(sp)
ffffffffc020092a:	6105                	addi	sp,sp,32
ffffffffc020092c:	8082                	ret

ffffffffc020092e <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020092e:	8082                	ret

ffffffffc0200930 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200930:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200934:	8082                	ret

ffffffffc0200936 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200936:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020093a:	8082                	ret

ffffffffc020093c <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020093c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200940:	00000797          	auipc	a5,0x0
ffffffffc0200944:	43c78793          	addi	a5,a5,1084 # ffffffffc0200d7c <__alltraps>
ffffffffc0200948:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020094c:	000407b7          	lui	a5,0x40
ffffffffc0200950:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200954:	8082                	ret

ffffffffc0200956 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200956:	610c                	ld	a1,0(a0)
{
ffffffffc0200958:	1141                	addi	sp,sp,-16
ffffffffc020095a:	e022                	sd	s0,0(sp)
ffffffffc020095c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020095e:	00004517          	auipc	a0,0x4
ffffffffc0200962:	a0250513          	addi	a0,a0,-1534 # ffffffffc0204360 <commands+0x1b8>
{
ffffffffc0200966:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200968:	f78ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020096c:	640c                	ld	a1,8(s0)
ffffffffc020096e:	00004517          	auipc	a0,0x4
ffffffffc0200972:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0204378 <commands+0x1d0>
ffffffffc0200976:	f6aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020097a:	680c                	ld	a1,16(s0)
ffffffffc020097c:	00004517          	auipc	a0,0x4
ffffffffc0200980:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204390 <commands+0x1e8>
ffffffffc0200984:	f5cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200988:	6c0c                	ld	a1,24(s0)
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	a1e50513          	addi	a0,a0,-1506 # ffffffffc02043a8 <commands+0x200>
ffffffffc0200992:	f4eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200996:	700c                	ld	a1,32(s0)
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	a2850513          	addi	a0,a0,-1496 # ffffffffc02043c0 <commands+0x218>
ffffffffc02009a0:	f40ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02009a4:	740c                	ld	a1,40(s0)
ffffffffc02009a6:	00004517          	auipc	a0,0x4
ffffffffc02009aa:	a3250513          	addi	a0,a0,-1486 # ffffffffc02043d8 <commands+0x230>
ffffffffc02009ae:	f32ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02009b2:	780c                	ld	a1,48(s0)
ffffffffc02009b4:	00004517          	auipc	a0,0x4
ffffffffc02009b8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc02043f0 <commands+0x248>
ffffffffc02009bc:	f24ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02009c0:	7c0c                	ld	a1,56(s0)
ffffffffc02009c2:	00004517          	auipc	a0,0x4
ffffffffc02009c6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0204408 <commands+0x260>
ffffffffc02009ca:	f16ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02009ce:	602c                	ld	a1,64(s0)
ffffffffc02009d0:	00004517          	auipc	a0,0x4
ffffffffc02009d4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0204420 <commands+0x278>
ffffffffc02009d8:	f08ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009dc:	642c                	ld	a1,72(s0)
ffffffffc02009de:	00004517          	auipc	a0,0x4
ffffffffc02009e2:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0204438 <commands+0x290>
ffffffffc02009e6:	efaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009ea:	682c                	ld	a1,80(s0)
ffffffffc02009ec:	00004517          	auipc	a0,0x4
ffffffffc02009f0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0204450 <commands+0x2a8>
ffffffffc02009f4:	eecff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009f8:	6c2c                	ld	a1,88(s0)
ffffffffc02009fa:	00004517          	auipc	a0,0x4
ffffffffc02009fe:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0204468 <commands+0x2c0>
ffffffffc0200a02:	edeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a06:	702c                	ld	a1,96(s0)
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0204480 <commands+0x2d8>
ffffffffc0200a10:	ed0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a14:	742c                	ld	a1,104(s0)
ffffffffc0200a16:	00004517          	auipc	a0,0x4
ffffffffc0200a1a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0204498 <commands+0x2f0>
ffffffffc0200a1e:	ec2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a22:	782c                	ld	a1,112(s0)
ffffffffc0200a24:	00004517          	auipc	a0,0x4
ffffffffc0200a28:	a8c50513          	addi	a0,a0,-1396 # ffffffffc02044b0 <commands+0x308>
ffffffffc0200a2c:	eb4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a30:	7c2c                	ld	a1,120(s0)
ffffffffc0200a32:	00004517          	auipc	a0,0x4
ffffffffc0200a36:	a9650513          	addi	a0,a0,-1386 # ffffffffc02044c8 <commands+0x320>
ffffffffc0200a3a:	ea6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a3e:	604c                	ld	a1,128(s0)
ffffffffc0200a40:	00004517          	auipc	a0,0x4
ffffffffc0200a44:	aa050513          	addi	a0,a0,-1376 # ffffffffc02044e0 <commands+0x338>
ffffffffc0200a48:	e98ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a4c:	644c                	ld	a1,136(s0)
ffffffffc0200a4e:	00004517          	auipc	a0,0x4
ffffffffc0200a52:	aaa50513          	addi	a0,a0,-1366 # ffffffffc02044f8 <commands+0x350>
ffffffffc0200a56:	e8aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a5a:	684c                	ld	a1,144(s0)
ffffffffc0200a5c:	00004517          	auipc	a0,0x4
ffffffffc0200a60:	ab450513          	addi	a0,a0,-1356 # ffffffffc0204510 <commands+0x368>
ffffffffc0200a64:	e7cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a68:	6c4c                	ld	a1,152(s0)
ffffffffc0200a6a:	00004517          	auipc	a0,0x4
ffffffffc0200a6e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0204528 <commands+0x380>
ffffffffc0200a72:	e6eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a76:	704c                	ld	a1,160(s0)
ffffffffc0200a78:	00004517          	auipc	a0,0x4
ffffffffc0200a7c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204540 <commands+0x398>
ffffffffc0200a80:	e60ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a84:	744c                	ld	a1,168(s0)
ffffffffc0200a86:	00004517          	auipc	a0,0x4
ffffffffc0200a8a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204558 <commands+0x3b0>
ffffffffc0200a8e:	e52ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a92:	784c                	ld	a1,176(s0)
ffffffffc0200a94:	00004517          	auipc	a0,0x4
ffffffffc0200a98:	adc50513          	addi	a0,a0,-1316 # ffffffffc0204570 <commands+0x3c8>
ffffffffc0200a9c:	e44ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200aa0:	7c4c                	ld	a1,184(s0)
ffffffffc0200aa2:	00004517          	auipc	a0,0x4
ffffffffc0200aa6:	ae650513          	addi	a0,a0,-1306 # ffffffffc0204588 <commands+0x3e0>
ffffffffc0200aaa:	e36ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200aae:	606c                	ld	a1,192(s0)
ffffffffc0200ab0:	00004517          	auipc	a0,0x4
ffffffffc0200ab4:	af050513          	addi	a0,a0,-1296 # ffffffffc02045a0 <commands+0x3f8>
ffffffffc0200ab8:	e28ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200abc:	646c                	ld	a1,200(s0)
ffffffffc0200abe:	00004517          	auipc	a0,0x4
ffffffffc0200ac2:	afa50513          	addi	a0,a0,-1286 # ffffffffc02045b8 <commands+0x410>
ffffffffc0200ac6:	e1aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200aca:	686c                	ld	a1,208(s0)
ffffffffc0200acc:	00004517          	auipc	a0,0x4
ffffffffc0200ad0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02045d0 <commands+0x428>
ffffffffc0200ad4:	e0cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200ad8:	6c6c                	ld	a1,216(s0)
ffffffffc0200ada:	00004517          	auipc	a0,0x4
ffffffffc0200ade:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02045e8 <commands+0x440>
ffffffffc0200ae2:	dfeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ae6:	706c                	ld	a1,224(s0)
ffffffffc0200ae8:	00004517          	auipc	a0,0x4
ffffffffc0200aec:	b1850513          	addi	a0,a0,-1256 # ffffffffc0204600 <commands+0x458>
ffffffffc0200af0:	df0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200af4:	746c                	ld	a1,232(s0)
ffffffffc0200af6:	00004517          	auipc	a0,0x4
ffffffffc0200afa:	b2250513          	addi	a0,a0,-1246 # ffffffffc0204618 <commands+0x470>
ffffffffc0200afe:	de2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b02:	786c                	ld	a1,240(s0)
ffffffffc0200b04:	00004517          	auipc	a0,0x4
ffffffffc0200b08:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0204630 <commands+0x488>
ffffffffc0200b0c:	dd4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b10:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b12:	6402                	ld	s0,0(sp)
ffffffffc0200b14:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b16:	00004517          	auipc	a0,0x4
ffffffffc0200b1a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0204648 <commands+0x4a0>
}
ffffffffc0200b1e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b20:	dc0ff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200b24 <print_trapframe>:
{
ffffffffc0200b24:	1141                	addi	sp,sp,-16
ffffffffc0200b26:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b28:	85aa                	mv	a1,a0
{
ffffffffc0200b2a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b2c:	00004517          	auipc	a0,0x4
ffffffffc0200b30:	b3450513          	addi	a0,a0,-1228 # ffffffffc0204660 <commands+0x4b8>
{
ffffffffc0200b34:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b36:	daaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b3a:	8522                	mv	a0,s0
ffffffffc0200b3c:	e1bff0ef          	jal	ra,ffffffffc0200956 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b40:	10043583          	ld	a1,256(s0)
ffffffffc0200b44:	00004517          	auipc	a0,0x4
ffffffffc0200b48:	b3450513          	addi	a0,a0,-1228 # ffffffffc0204678 <commands+0x4d0>
ffffffffc0200b4c:	d94ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b50:	10843583          	ld	a1,264(s0)
ffffffffc0200b54:	00004517          	auipc	a0,0x4
ffffffffc0200b58:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0204690 <commands+0x4e8>
ffffffffc0200b5c:	d84ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200b60:	11043583          	ld	a1,272(s0)
ffffffffc0200b64:	00004517          	auipc	a0,0x4
ffffffffc0200b68:	b4450513          	addi	a0,a0,-1212 # ffffffffc02046a8 <commands+0x500>
ffffffffc0200b6c:	d74ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b70:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b74:	6402                	ld	s0,0(sp)
ffffffffc0200b76:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b78:	00004517          	auipc	a0,0x4
ffffffffc0200b7c:	b4850513          	addi	a0,a0,-1208 # ffffffffc02046c0 <commands+0x518>
}
ffffffffc0200b80:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b82:	d5eff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200b86 <interrupt_handler>:
 */
void interrupt_handler(struct trapframe *tf)
{
    // 清除cause的符号位，获取真实的中断号
    // RISC-V中：中断的cause最高位为1，异常为0
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200b86:	11853783          	ld	a5,280(a0)
ffffffffc0200b8a:	472d                	li	a4,11
ffffffffc0200b8c:	0786                	slli	a5,a5,0x1
ffffffffc0200b8e:	8385                	srli	a5,a5,0x1
ffffffffc0200b90:	0cf76e63          	bltu	a4,a5,ffffffffc0200c6c <interrupt_handler+0xe6>
ffffffffc0200b94:	00004717          	auipc	a4,0x4
ffffffffc0200b98:	ca870713          	addi	a4,a4,-856 # ffffffffc020483c <commands+0x694>
ffffffffc0200b9c:	078a                	slli	a5,a5,0x2
ffffffffc0200b9e:	97ba                	add	a5,a5,a4
ffffffffc0200ba0:	439c                	lw	a5,0(a5)
ffffffffc0200ba2:	97ba                	add	a5,a5,a4
ffffffffc0200ba4:	8782                	jr	a5
    case IRQ_S_EXT:
        // 监管态外部中断 - 来自键盘、鼠标、网络等设备
        cprintf("Supervisor external interrupt\n");
        break;
    case IRQ_H_EXT:
        cprintf("Hypervisor external interrupt\n");
ffffffffc0200ba6:	00004517          	auipc	a0,0x4
ffffffffc0200baa:	c5a50513          	addi	a0,a0,-934 # ffffffffc0204800 <commands+0x658>
ffffffffc0200bae:	d32ff06f          	j	ffffffffc02000e0 <cprintf>
        break;
    case IRQ_M_EXT:
        cprintf("Machine external interrupt\n");
ffffffffc0200bb2:	00004517          	auipc	a0,0x4
ffffffffc0200bb6:	c6e50513          	addi	a0,a0,-914 # ffffffffc0204820 <commands+0x678>
ffffffffc0200bba:	d26ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200bbe:	00004517          	auipc	a0,0x4
ffffffffc0200bc2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc02046d8 <commands+0x530>
ffffffffc0200bc6:	d1aff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200bca:	00004517          	auipc	a0,0x4
ffffffffc0200bce:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02046f8 <commands+0x550>
ffffffffc0200bd2:	d0eff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200bd6:	00004517          	auipc	a0,0x4
ffffffffc0200bda:	b4250513          	addi	a0,a0,-1214 # ffffffffc0204718 <commands+0x570>
ffffffffc0200bde:	d02ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Machine software interrupt\n");
ffffffffc0200be2:	00004517          	auipc	a0,0x4
ffffffffc0200be6:	b5650513          	addi	a0,a0,-1194 # ffffffffc0204738 <commands+0x590>
ffffffffc0200bea:	cf6ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User timer interrupt\n");
ffffffffc0200bee:	00004517          	auipc	a0,0x4
ffffffffc0200bf2:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0204758 <commands+0x5b0>
ffffffffc0200bf6:	ceaff06f          	j	ffffffffc02000e0 <cprintf>
{
ffffffffc0200bfa:	1141                	addi	sp,sp,-16
ffffffffc0200bfc:	e022                	sd	s0,0(sp)
ffffffffc0200bfe:	e406                	sd	ra,8(sp)
        ticks++;
ffffffffc0200c00:	0000d417          	auipc	s0,0xd
ffffffffc0200c04:	88040413          	addi	s0,s0,-1920 # ffffffffc020d480 <ticks>
        clock_set_next_event();
ffffffffc0200c08:	c9bff0ef          	jal	ra,ffffffffc02008a2 <clock_set_next_event>
        ticks++;
ffffffffc0200c0c:	601c                	ld	a5,0(s0)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200c0e:	06400713          	li	a4,100
        ticks++;
ffffffffc0200c12:	0785                	addi	a5,a5,1
ffffffffc0200c14:	e01c                	sd	a5,0(s0)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200c16:	601c                	ld	a5,0(s0)
ffffffffc0200c18:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200c1c:	cba9                	beqz	a5,ffffffffc0200c6e <interrupt_handler+0xe8>
        if (ticks == 10 * TICK_NUM) {
ffffffffc0200c1e:	6018                	ld	a4,0(s0)
ffffffffc0200c20:	3e800793          	li	a5,1000
ffffffffc0200c24:	00f71863          	bne	a4,a5,ffffffffc0200c34 <interrupt_handler+0xae>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c28:	4501                	li	a0,0
ffffffffc0200c2a:	4581                	li	a1,0
ffffffffc0200c2c:	4601                	li	a2,0
ffffffffc0200c2e:	48a1                	li	a7,8
ffffffffc0200c30:	00000073          	ecall
    default:
        // 遇到未知中断类型，打印完整trapframe信息用于调试
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c34:	60a2                	ld	ra,8(sp)
ffffffffc0200c36:	6402                	ld	s0,0(sp)
ffffffffc0200c38:	0141                	addi	sp,sp,16
ffffffffc0200c3a:	8082                	ret
        cprintf("Hypervisor timer interrupt\n");
ffffffffc0200c3c:	00004517          	auipc	a0,0x4
ffffffffc0200c40:	b4450513          	addi	a0,a0,-1212 # ffffffffc0204780 <commands+0x5d8>
ffffffffc0200c44:	c9cff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User external interrupt\n");
ffffffffc0200c48:	00004517          	auipc	a0,0x4
ffffffffc0200c4c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02047c0 <commands+0x618>
ffffffffc0200c50:	c90ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c54:	00004517          	auipc	a0,0x4
ffffffffc0200c58:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02047e0 <commands+0x638>
ffffffffc0200c5c:	c84ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Machine timer interrupt\n");
ffffffffc0200c60:	00004517          	auipc	a0,0x4
ffffffffc0200c64:	b4050513          	addi	a0,a0,-1216 # ffffffffc02047a0 <commands+0x5f8>
ffffffffc0200c68:	c78ff06f          	j	ffffffffc02000e0 <cprintf>
        print_trapframe(tf);
ffffffffc0200c6c:	bd65                	j	ffffffffc0200b24 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c6e:	06400593          	li	a1,100
ffffffffc0200c72:	00004517          	auipc	a0,0x4
ffffffffc0200c76:	afe50513          	addi	a0,a0,-1282 # ffffffffc0204770 <commands+0x5c8>
ffffffffc0200c7a:	c66ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0200c7e:	b745                	j	ffffffffc0200c1e <interrupt_handler+0x98>

ffffffffc0200c80 <exception_handler>:
 */
void exception_handler(struct trapframe *tf)
{
    int ret;  // 用于可能的返回值（当前未使用）

    switch (tf->cause)
ffffffffc0200c80:	11853783          	ld	a5,280(a0)
{
ffffffffc0200c84:	1141                	addi	sp,sp,-16
ffffffffc0200c86:	e022                	sd	s0,0(sp)
ffffffffc0200c88:	e406                	sd	ra,8(sp)
ffffffffc0200c8a:	473d                	li	a4,15
ffffffffc0200c8c:	842a                	mv	s0,a0
ffffffffc0200c8e:	0cf76b63          	bltu	a4,a5,ffffffffc0200d64 <exception_handler+0xe4>
ffffffffc0200c92:	00004717          	auipc	a4,0x4
ffffffffc0200c96:	d7670713          	addi	a4,a4,-650 # ffffffffc0204a08 <commands+0x860>
ffffffffc0200c9a:	078a                	slli	a5,a5,0x2
ffffffffc0200c9c:	97ba                	add	a5,a5,a4
ffffffffc0200c9e:	439c                	lw	a5,0(a5)
ffffffffc0200ca0:	97ba                	add	a5,a5,a4
ffffffffc0200ca2:	8782                	jr	a5
        cprintf("Load page fault\n");
        break;

    case CAUSE_STORE_PAGE_FAULT:
        // 存储页面错误：写入数据的页面未映射或权限不足
        cprintf("Store/AMO page fault\n");
ffffffffc0200ca4:	00004517          	auipc	a0,0x4
ffffffffc0200ca8:	d4c50513          	addi	a0,a0,-692 # ffffffffc02049f0 <commands+0x848>
    default:
        // 遇到未知异常类型，打印完整trapframe信息用于调试
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200cac:	6402                	ld	s0,0(sp)
ffffffffc0200cae:	60a2                	ld	ra,8(sp)
ffffffffc0200cb0:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200cb2:	c2eff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Instruction address misaligned\n");
ffffffffc0200cb6:	00004517          	auipc	a0,0x4
ffffffffc0200cba:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204870 <commands+0x6c8>
ffffffffc0200cbe:	b7fd                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Instruction access fault\n");
ffffffffc0200cc0:	00004517          	auipc	a0,0x4
ffffffffc0200cc4:	bd050513          	addi	a0,a0,-1072 # ffffffffc0204890 <commands+0x6e8>
ffffffffc0200cc8:	b7d5                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Illegal instruction\n");
ffffffffc0200cca:	00004517          	auipc	a0,0x4
ffffffffc0200cce:	be650513          	addi	a0,a0,-1050 # ffffffffc02048b0 <commands+0x708>
ffffffffc0200cd2:	c0eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        tf->epc += 4;  // RISC-V指令长度为4字节
ffffffffc0200cd6:	10843783          	ld	a5,264(s0)
ffffffffc0200cda:	0791                	addi	a5,a5,4
ffffffffc0200cdc:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200ce0:	60a2                	ld	ra,8(sp)
ffffffffc0200ce2:	6402                	ld	s0,0(sp)
ffffffffc0200ce4:	0141                	addi	sp,sp,16
ffffffffc0200ce6:	8082                	ret
        cprintf("Breakpoint\n");
ffffffffc0200ce8:	00004517          	auipc	a0,0x4
ffffffffc0200cec:	be050513          	addi	a0,a0,-1056 # ffffffffc02048c8 <commands+0x720>
ffffffffc0200cf0:	bf0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        tf->epc += 4;
ffffffffc0200cf4:	10843783          	ld	a5,264(s0)
ffffffffc0200cf8:	0791                	addi	a5,a5,4
ffffffffc0200cfa:	10f43423          	sd	a5,264(s0)
        break;
ffffffffc0200cfe:	b7cd                	j	ffffffffc0200ce0 <exception_handler+0x60>
        cprintf("Load address misaligned\n");
ffffffffc0200d00:	00004517          	auipc	a0,0x4
ffffffffc0200d04:	bd850513          	addi	a0,a0,-1064 # ffffffffc02048d8 <commands+0x730>
ffffffffc0200d08:	b755                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Load access fault\n");
ffffffffc0200d0a:	00004517          	auipc	a0,0x4
ffffffffc0200d0e:	bee50513          	addi	a0,a0,-1042 # ffffffffc02048f8 <commands+0x750>
ffffffffc0200d12:	bf69                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("AMO address misaligned\n");
ffffffffc0200d14:	00004517          	auipc	a0,0x4
ffffffffc0200d18:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0204910 <commands+0x768>
ffffffffc0200d1c:	bf41                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200d1e:	00004517          	auipc	a0,0x4
ffffffffc0200d22:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0204928 <commands+0x780>
ffffffffc0200d26:	b759                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Environment call from U-mode\n");
ffffffffc0200d28:	00004517          	auipc	a0,0x4
ffffffffc0200d2c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0204940 <commands+0x798>
ffffffffc0200d30:	bfb5                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Environment call from S-mode\n");
ffffffffc0200d32:	00004517          	auipc	a0,0x4
ffffffffc0200d36:	c2e50513          	addi	a0,a0,-978 # ffffffffc0204960 <commands+0x7b8>
ffffffffc0200d3a:	bf8d                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Environment call from H-mode\n");
ffffffffc0200d3c:	00004517          	auipc	a0,0x4
ffffffffc0200d40:	c4450513          	addi	a0,a0,-956 # ffffffffc0204980 <commands+0x7d8>
ffffffffc0200d44:	b7a5                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Environment call from M-mode\n");
ffffffffc0200d46:	00004517          	auipc	a0,0x4
ffffffffc0200d4a:	c5a50513          	addi	a0,a0,-934 # ffffffffc02049a0 <commands+0x7f8>
ffffffffc0200d4e:	bfb9                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Instruction page fault\n");
ffffffffc0200d50:	00004517          	auipc	a0,0x4
ffffffffc0200d54:	c7050513          	addi	a0,a0,-912 # ffffffffc02049c0 <commands+0x818>
ffffffffc0200d58:	bf91                	j	ffffffffc0200cac <exception_handler+0x2c>
        cprintf("Load page fault\n");
ffffffffc0200d5a:	00004517          	auipc	a0,0x4
ffffffffc0200d5e:	c7e50513          	addi	a0,a0,-898 # ffffffffc02049d8 <commands+0x830>
ffffffffc0200d62:	b7a9                	j	ffffffffc0200cac <exception_handler+0x2c>
        print_trapframe(tf);
ffffffffc0200d64:	8522                	mv	a0,s0
}
ffffffffc0200d66:	6402                	ld	s0,0(sp)
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200d6c:	bb65                	j	ffffffffc0200b24 <print_trapframe>

ffffffffc0200d6e <trap>:
 * @note 该函数返回后，系统会自动恢复到中断发生前的执行状态
 */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d6e:	11853783          	ld	a5,280(a0)
ffffffffc0200d72:	0007c363          	bltz	a5,ffffffffc0200d78 <trap+0xa>
        interrupt_handler(tf);
    }
    else
    {
        // exceptions - 异常：同步事件，由cause最高位为0标识
        exception_handler(tf);
ffffffffc0200d76:	b729                	j	ffffffffc0200c80 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200d78:	b539                	j	ffffffffc0200b86 <interrupt_handler>
	...

ffffffffc0200d7c <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d7c:	14011073          	csrw	sscratch,sp
ffffffffc0200d80:	712d                	addi	sp,sp,-288
ffffffffc0200d82:	e406                	sd	ra,8(sp)
ffffffffc0200d84:	ec0e                	sd	gp,24(sp)
ffffffffc0200d86:	f012                	sd	tp,32(sp)
ffffffffc0200d88:	f416                	sd	t0,40(sp)
ffffffffc0200d8a:	f81a                	sd	t1,48(sp)
ffffffffc0200d8c:	fc1e                	sd	t2,56(sp)
ffffffffc0200d8e:	e0a2                	sd	s0,64(sp)
ffffffffc0200d90:	e4a6                	sd	s1,72(sp)
ffffffffc0200d92:	e8aa                	sd	a0,80(sp)
ffffffffc0200d94:	ecae                	sd	a1,88(sp)
ffffffffc0200d96:	f0b2                	sd	a2,96(sp)
ffffffffc0200d98:	f4b6                	sd	a3,104(sp)
ffffffffc0200d9a:	f8ba                	sd	a4,112(sp)
ffffffffc0200d9c:	fcbe                	sd	a5,120(sp)
ffffffffc0200d9e:	e142                	sd	a6,128(sp)
ffffffffc0200da0:	e546                	sd	a7,136(sp)
ffffffffc0200da2:	e94a                	sd	s2,144(sp)
ffffffffc0200da4:	ed4e                	sd	s3,152(sp)
ffffffffc0200da6:	f152                	sd	s4,160(sp)
ffffffffc0200da8:	f556                	sd	s5,168(sp)
ffffffffc0200daa:	f95a                	sd	s6,176(sp)
ffffffffc0200dac:	fd5e                	sd	s7,184(sp)
ffffffffc0200dae:	e1e2                	sd	s8,192(sp)
ffffffffc0200db0:	e5e6                	sd	s9,200(sp)
ffffffffc0200db2:	e9ea                	sd	s10,208(sp)
ffffffffc0200db4:	edee                	sd	s11,216(sp)
ffffffffc0200db6:	f1f2                	sd	t3,224(sp)
ffffffffc0200db8:	f5f6                	sd	t4,232(sp)
ffffffffc0200dba:	f9fa                	sd	t5,240(sp)
ffffffffc0200dbc:	fdfe                	sd	t6,248(sp)
ffffffffc0200dbe:	14002473          	csrr	s0,sscratch
ffffffffc0200dc2:	100024f3          	csrr	s1,sstatus
ffffffffc0200dc6:	14102973          	csrr	s2,sepc
ffffffffc0200dca:	143029f3          	csrr	s3,stval
ffffffffc0200dce:	14202a73          	csrr	s4,scause
ffffffffc0200dd2:	e822                	sd	s0,16(sp)
ffffffffc0200dd4:	e226                	sd	s1,256(sp)
ffffffffc0200dd6:	e64a                	sd	s2,264(sp)
ffffffffc0200dd8:	ea4e                	sd	s3,272(sp)
ffffffffc0200dda:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ddc:	850a                	mv	a0,sp
    jal trap
ffffffffc0200dde:	f91ff0ef          	jal	ra,ffffffffc0200d6e <trap>

ffffffffc0200de2 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200de2:	6492                	ld	s1,256(sp)
ffffffffc0200de4:	6932                	ld	s2,264(sp)
ffffffffc0200de6:	10049073          	csrw	sstatus,s1
ffffffffc0200dea:	14191073          	csrw	sepc,s2
ffffffffc0200dee:	60a2                	ld	ra,8(sp)
ffffffffc0200df0:	61e2                	ld	gp,24(sp)
ffffffffc0200df2:	7202                	ld	tp,32(sp)
ffffffffc0200df4:	72a2                	ld	t0,40(sp)
ffffffffc0200df6:	7342                	ld	t1,48(sp)
ffffffffc0200df8:	73e2                	ld	t2,56(sp)
ffffffffc0200dfa:	6406                	ld	s0,64(sp)
ffffffffc0200dfc:	64a6                	ld	s1,72(sp)
ffffffffc0200dfe:	6546                	ld	a0,80(sp)
ffffffffc0200e00:	65e6                	ld	a1,88(sp)
ffffffffc0200e02:	7606                	ld	a2,96(sp)
ffffffffc0200e04:	76a6                	ld	a3,104(sp)
ffffffffc0200e06:	7746                	ld	a4,112(sp)
ffffffffc0200e08:	77e6                	ld	a5,120(sp)
ffffffffc0200e0a:	680a                	ld	a6,128(sp)
ffffffffc0200e0c:	68aa                	ld	a7,136(sp)
ffffffffc0200e0e:	694a                	ld	s2,144(sp)
ffffffffc0200e10:	69ea                	ld	s3,152(sp)
ffffffffc0200e12:	7a0a                	ld	s4,160(sp)
ffffffffc0200e14:	7aaa                	ld	s5,168(sp)
ffffffffc0200e16:	7b4a                	ld	s6,176(sp)
ffffffffc0200e18:	7bea                	ld	s7,184(sp)
ffffffffc0200e1a:	6c0e                	ld	s8,192(sp)
ffffffffc0200e1c:	6cae                	ld	s9,200(sp)
ffffffffc0200e1e:	6d4e                	ld	s10,208(sp)
ffffffffc0200e20:	6dee                	ld	s11,216(sp)
ffffffffc0200e22:	7e0e                	ld	t3,224(sp)
ffffffffc0200e24:	7eae                	ld	t4,232(sp)
ffffffffc0200e26:	7f4e                	ld	t5,240(sp)
ffffffffc0200e28:	7fee                	ld	t6,248(sp)
ffffffffc0200e2a:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200e2c:	10200073          	sret

ffffffffc0200e30 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200e30:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200e32:	bf45                	j	ffffffffc0200de2 <__trapret>
	...

ffffffffc0200e36 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0200e36:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200e38:	00004697          	auipc	a3,0x4
ffffffffc0200e3c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0204a48 <commands+0x8a0>
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	c2860613          	addi	a2,a2,-984 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0200e48:	08800593          	li	a1,136
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	c3450513          	addi	a0,a0,-972 # ffffffffc0204a80 <commands+0x8d8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0200e54:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e56:	b88ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200e5a <find_vma>:
{
ffffffffc0200e5a:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0200e5c:	c505                	beqz	a0,ffffffffc0200e84 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200e5e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0200e60:	c501                	beqz	a0,ffffffffc0200e68 <find_vma+0xe>
ffffffffc0200e62:	651c                	ld	a5,8(a0)
ffffffffc0200e64:	02f5f263          	bgeu	a1,a5,ffffffffc0200e88 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e68:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0200e6a:	00f68d63          	beq	a3,a5,ffffffffc0200e84 <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0200e6e:	fe87b703          	ld	a4,-24(a5) # 3ffe8 <kern_entry-0xffffffffc01c0018>
ffffffffc0200e72:	00e5e663          	bltu	a1,a4,ffffffffc0200e7e <find_vma+0x24>
ffffffffc0200e76:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e7a:	00e5ec63          	bltu	a1,a4,ffffffffc0200e92 <find_vma+0x38>
ffffffffc0200e7e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0200e80:	fef697e3          	bne	a3,a5,ffffffffc0200e6e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200e84:	4501                	li	a0,0
}
ffffffffc0200e86:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0200e88:	691c                	ld	a5,16(a0)
ffffffffc0200e8a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200e68 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200e8e:	ea88                	sd	a0,16(a3)
ffffffffc0200e90:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0200e92:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200e96:	ea88                	sd	a0,16(a3)
ffffffffc0200e98:	8082                	ret

ffffffffc0200e9a <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200e9a:	6590                	ld	a2,8(a1)
ffffffffc0200e9c:	0105b803          	ld	a6,16(a1)
{
ffffffffc0200ea0:	1141                	addi	sp,sp,-16
ffffffffc0200ea2:	e406                	sd	ra,8(sp)
ffffffffc0200ea4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200ea6:	01066763          	bltu	a2,a6,ffffffffc0200eb4 <insert_vma_struct+0x1a>
ffffffffc0200eaa:	a085                	j	ffffffffc0200f0a <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0200eac:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200eb0:	04e66863          	bltu	a2,a4,ffffffffc0200f00 <insert_vma_struct+0x66>
ffffffffc0200eb4:	86be                	mv	a3,a5
ffffffffc0200eb6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0200eb8:	fef51ae3          	bne	a0,a5,ffffffffc0200eac <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0200ebc:	02a68463          	beq	a3,a0,ffffffffc0200ee4 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200ec0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200ec4:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200ec8:	08e8f163          	bgeu	a7,a4,ffffffffc0200f4a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200ecc:	04e66f63          	bltu	a2,a4,ffffffffc0200f2a <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0200ed0:	00f50a63          	beq	a0,a5,ffffffffc0200ee4 <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0200ed4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200ed8:	05076963          	bltu	a4,a6,ffffffffc0200f2a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200edc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200ee0:	02c77363          	bgeu	a4,a2,ffffffffc0200f06 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0200ee4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200ee6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200ee8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200eec:	e390                	sd	a2,0(a5)
ffffffffc0200eee:	e690                	sd	a2,8(a3)
}
ffffffffc0200ef0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200ef2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200ef4:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0200ef6:	0017079b          	addiw	a5,a4,1
ffffffffc0200efa:	d11c                	sw	a5,32(a0)
}
ffffffffc0200efc:	0141                	addi	sp,sp,16
ffffffffc0200efe:	8082                	ret
    if (le_prev != list)
ffffffffc0200f00:	fca690e3          	bne	a3,a0,ffffffffc0200ec0 <insert_vma_struct+0x26>
ffffffffc0200f04:	bfd1                	j	ffffffffc0200ed8 <insert_vma_struct+0x3e>
ffffffffc0200f06:	f31ff0ef          	jal	ra,ffffffffc0200e36 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200f0a:	00004697          	auipc	a3,0x4
ffffffffc0200f0e:	b8668693          	addi	a3,a3,-1146 # ffffffffc0204a90 <commands+0x8e8>
ffffffffc0200f12:	00004617          	auipc	a2,0x4
ffffffffc0200f16:	b5660613          	addi	a2,a2,-1194 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0200f1a:	08e00593          	li	a1,142
ffffffffc0200f1e:	00004517          	auipc	a0,0x4
ffffffffc0200f22:	b6250513          	addi	a0,a0,-1182 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc0200f26:	ab8ff0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200f2a:	00004697          	auipc	a3,0x4
ffffffffc0200f2e:	ba668693          	addi	a3,a3,-1114 # ffffffffc0204ad0 <commands+0x928>
ffffffffc0200f32:	00004617          	auipc	a2,0x4
ffffffffc0200f36:	b3660613          	addi	a2,a2,-1226 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0200f3a:	08700593          	li	a1,135
ffffffffc0200f3e:	00004517          	auipc	a0,0x4
ffffffffc0200f42:	b4250513          	addi	a0,a0,-1214 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc0200f46:	a98ff0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f4a:	00004697          	auipc	a3,0x4
ffffffffc0200f4e:	b6668693          	addi	a3,a3,-1178 # ffffffffc0204ab0 <commands+0x908>
ffffffffc0200f52:	00004617          	auipc	a2,0x4
ffffffffc0200f56:	b1660613          	addi	a2,a2,-1258 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0200f5a:	08600593          	li	a1,134
ffffffffc0200f5e:	00004517          	auipc	a0,0x4
ffffffffc0200f62:	b2250513          	addi	a0,a0,-1246 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc0200f66:	a78ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200f6a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0200f6a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f6c:	03000513          	li	a0,48
{
ffffffffc0200f70:	fc06                	sd	ra,56(sp)
ffffffffc0200f72:	f822                	sd	s0,48(sp)
ffffffffc0200f74:	f426                	sd	s1,40(sp)
ffffffffc0200f76:	f04a                	sd	s2,32(sp)
ffffffffc0200f78:	ec4e                	sd	s3,24(sp)
ffffffffc0200f7a:	e852                	sd	s4,16(sp)
ffffffffc0200f7c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f7e:	550000ef          	jal	ra,ffffffffc02014ce <kmalloc>
    if (mm != NULL)
ffffffffc0200f82:	2e050f63          	beqz	a0,ffffffffc0201280 <vmm_init+0x316>
ffffffffc0200f86:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0200f88:	e508                	sd	a0,8(a0)
ffffffffc0200f8a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200f8c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200f90:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200f94:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0200f98:	02053423          	sd	zero,40(a0)
ffffffffc0200f9c:	03200413          	li	s0,50
ffffffffc0200fa0:	a811                	j	ffffffffc0200fb4 <vmm_init+0x4a>
        vma->vm_start = vm_start;
ffffffffc0200fa2:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200fa4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200fa6:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0200faa:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200fac:	8526                	mv	a0,s1
ffffffffc0200fae:	eedff0ef          	jal	ra,ffffffffc0200e9a <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0200fb2:	c80d                	beqz	s0,ffffffffc0200fe4 <vmm_init+0x7a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200fb4:	03000513          	li	a0,48
ffffffffc0200fb8:	516000ef          	jal	ra,ffffffffc02014ce <kmalloc>
ffffffffc0200fbc:	85aa                	mv	a1,a0
ffffffffc0200fbe:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0200fc2:	f165                	bnez	a0,ffffffffc0200fa2 <vmm_init+0x38>
        assert(vma != NULL);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	ca468693          	addi	a3,a3,-860 # ffffffffc0204c68 <commands+0xac0>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0200fd4:	0da00593          	li	a1,218
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc0200fe0:	9feff0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc0200fe4:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200fe8:	1f900913          	li	s2,505
ffffffffc0200fec:	a819                	j	ffffffffc0201002 <vmm_init+0x98>
        vma->vm_start = vm_start;
ffffffffc0200fee:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ff0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ff2:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200ff6:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200ff8:	8526                	mv	a0,s1
ffffffffc0200ffa:	ea1ff0ef          	jal	ra,ffffffffc0200e9a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200ffe:	03240a63          	beq	s0,s2,ffffffffc0201032 <vmm_init+0xc8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201002:	03000513          	li	a0,48
ffffffffc0201006:	4c8000ef          	jal	ra,ffffffffc02014ce <kmalloc>
ffffffffc020100a:	85aa                	mv	a1,a0
ffffffffc020100c:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0201010:	fd79                	bnez	a0,ffffffffc0200fee <vmm_init+0x84>
        assert(vma != NULL);
ffffffffc0201012:	00004697          	auipc	a3,0x4
ffffffffc0201016:	c5668693          	addi	a3,a3,-938 # ffffffffc0204c68 <commands+0xac0>
ffffffffc020101a:	00004617          	auipc	a2,0x4
ffffffffc020101e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201022:	0e100593          	li	a1,225
ffffffffc0201026:	00004517          	auipc	a0,0x4
ffffffffc020102a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020102e:	9b0ff0ef          	jal	ra,ffffffffc02001de <__panic>
    return listelm->next;
ffffffffc0201032:	649c                	ld	a5,8(s1)
ffffffffc0201034:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0201036:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc020103a:	18f48363          	beq	s1,a5,ffffffffc02011c0 <vmm_init+0x256>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020103e:	fe87b603          	ld	a2,-24(a5)
ffffffffc0201042:	ffe70693          	addi	a3,a4,-2
ffffffffc0201046:	10d61d63          	bne	a2,a3,ffffffffc0201160 <vmm_init+0x1f6>
ffffffffc020104a:	ff07b683          	ld	a3,-16(a5)
ffffffffc020104e:	10e69963          	bne	a3,a4,ffffffffc0201160 <vmm_init+0x1f6>
    for (i = 1; i <= step2; i++)
ffffffffc0201052:	0715                	addi	a4,a4,5
ffffffffc0201054:	679c                	ld	a5,8(a5)
ffffffffc0201056:	feb712e3          	bne	a4,a1,ffffffffc020103a <vmm_init+0xd0>
ffffffffc020105a:	4a1d                	li	s4,7
ffffffffc020105c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc020105e:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0201062:	85a2                	mv	a1,s0
ffffffffc0201064:	8526                	mv	a0,s1
ffffffffc0201066:	df5ff0ef          	jal	ra,ffffffffc0200e5a <find_vma>
ffffffffc020106a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020106c:	18050a63          	beqz	a0,ffffffffc0201200 <vmm_init+0x296>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0201070:	00140593          	addi	a1,s0,1
ffffffffc0201074:	8526                	mv	a0,s1
ffffffffc0201076:	de5ff0ef          	jal	ra,ffffffffc0200e5a <find_vma>
ffffffffc020107a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020107c:	16050263          	beqz	a0,ffffffffc02011e0 <vmm_init+0x276>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0201080:	85d2                	mv	a1,s4
ffffffffc0201082:	8526                	mv	a0,s1
ffffffffc0201084:	dd7ff0ef          	jal	ra,ffffffffc0200e5a <find_vma>
        assert(vma3 == NULL);
ffffffffc0201088:	18051c63          	bnez	a0,ffffffffc0201220 <vmm_init+0x2b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020108c:	00340593          	addi	a1,s0,3
ffffffffc0201090:	8526                	mv	a0,s1
ffffffffc0201092:	dc9ff0ef          	jal	ra,ffffffffc0200e5a <find_vma>
        assert(vma4 == NULL);
ffffffffc0201096:	1c051563          	bnez	a0,ffffffffc0201260 <vmm_init+0x2f6>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc020109a:	00440593          	addi	a1,s0,4
ffffffffc020109e:	8526                	mv	a0,s1
ffffffffc02010a0:	dbbff0ef          	jal	ra,ffffffffc0200e5a <find_vma>
        assert(vma5 == NULL);
ffffffffc02010a4:	18051e63          	bnez	a0,ffffffffc0201240 <vmm_init+0x2d6>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02010a8:	00893783          	ld	a5,8(s2)
ffffffffc02010ac:	0c879a63          	bne	a5,s0,ffffffffc0201180 <vmm_init+0x216>
ffffffffc02010b0:	01093783          	ld	a5,16(s2)
ffffffffc02010b4:	0d479663          	bne	a5,s4,ffffffffc0201180 <vmm_init+0x216>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02010b8:	0089b783          	ld	a5,8(s3)
ffffffffc02010bc:	0e879263          	bne	a5,s0,ffffffffc02011a0 <vmm_init+0x236>
ffffffffc02010c0:	0109b783          	ld	a5,16(s3)
ffffffffc02010c4:	0d479e63          	bne	a5,s4,ffffffffc02011a0 <vmm_init+0x236>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02010c8:	0415                	addi	s0,s0,5
ffffffffc02010ca:	0a15                	addi	s4,s4,5
ffffffffc02010cc:	f9541be3          	bne	s0,s5,ffffffffc0201062 <vmm_init+0xf8>
ffffffffc02010d0:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02010d2:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02010d4:	85a2                	mv	a1,s0
ffffffffc02010d6:	8526                	mv	a0,s1
ffffffffc02010d8:	d83ff0ef          	jal	ra,ffffffffc0200e5a <find_vma>
ffffffffc02010dc:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc02010e0:	c90d                	beqz	a0,ffffffffc0201112 <vmm_init+0x1a8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02010e2:	6914                	ld	a3,16(a0)
ffffffffc02010e4:	6510                	ld	a2,8(a0)
ffffffffc02010e6:	00004517          	auipc	a0,0x4
ffffffffc02010ea:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204bf0 <commands+0xa48>
ffffffffc02010ee:	ff3fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02010f2:	00004697          	auipc	a3,0x4
ffffffffc02010f6:	b2668693          	addi	a3,a3,-1242 # ffffffffc0204c18 <commands+0xa70>
ffffffffc02010fa:	00004617          	auipc	a2,0x4
ffffffffc02010fe:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201102:	10700593          	li	a1,263
ffffffffc0201106:	00004517          	auipc	a0,0x4
ffffffffc020110a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020110e:	8d0ff0ef          	jal	ra,ffffffffc02001de <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc0201112:	147d                	addi	s0,s0,-1
ffffffffc0201114:	fd2410e3          	bne	s0,s2,ffffffffc02010d4 <vmm_init+0x16a>
ffffffffc0201118:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc020111a:	00a48c63          	beq	s1,a0,ffffffffc0201132 <vmm_init+0x1c8>
    __list_del(listelm->prev, listelm->next);
ffffffffc020111e:	6118                	ld	a4,0(a0)
ffffffffc0201120:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0201122:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201124:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201126:	e398                	sd	a4,0(a5)
ffffffffc0201128:	456000ef          	jal	ra,ffffffffc020157e <kfree>
    return listelm->next;
ffffffffc020112c:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc020112e:	fea498e3          	bne	s1,a0,ffffffffc020111e <vmm_init+0x1b4>
    kfree(mm); // kfree mm
ffffffffc0201132:	8526                	mv	a0,s1
ffffffffc0201134:	44a000ef          	jal	ra,ffffffffc020157e <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	af850513          	addi	a0,a0,-1288 # ffffffffc0204c30 <commands+0xa88>
ffffffffc0201140:	fa1fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0201144:	7442                	ld	s0,48(sp)
ffffffffc0201146:	70e2                	ld	ra,56(sp)
ffffffffc0201148:	74a2                	ld	s1,40(sp)
ffffffffc020114a:	7902                	ld	s2,32(sp)
ffffffffc020114c:	69e2                	ld	s3,24(sp)
ffffffffc020114e:	6a42                	ld	s4,16(sp)
ffffffffc0201150:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201152:	00004517          	auipc	a0,0x4
ffffffffc0201156:	afe50513          	addi	a0,a0,-1282 # ffffffffc0204c50 <commands+0xaa8>
}
ffffffffc020115a:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc020115c:	f85fe06f          	j	ffffffffc02000e0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201160:	00004697          	auipc	a3,0x4
ffffffffc0201164:	9a868693          	addi	a3,a3,-1624 # ffffffffc0204b08 <commands+0x960>
ffffffffc0201168:	00004617          	auipc	a2,0x4
ffffffffc020116c:	90060613          	addi	a2,a2,-1792 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201170:	0eb00593          	li	a1,235
ffffffffc0201174:	00004517          	auipc	a0,0x4
ffffffffc0201178:	90c50513          	addi	a0,a0,-1780 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020117c:	862ff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0201180:	00004697          	auipc	a3,0x4
ffffffffc0201184:	a1068693          	addi	a3,a3,-1520 # ffffffffc0204b90 <commands+0x9e8>
ffffffffc0201188:	00004617          	auipc	a2,0x4
ffffffffc020118c:	8e060613          	addi	a2,a2,-1824 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201190:	0fc00593          	li	a1,252
ffffffffc0201194:	00004517          	auipc	a0,0x4
ffffffffc0201198:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020119c:	842ff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02011a0:	00004697          	auipc	a3,0x4
ffffffffc02011a4:	a2068693          	addi	a3,a3,-1504 # ffffffffc0204bc0 <commands+0xa18>
ffffffffc02011a8:	00004617          	auipc	a2,0x4
ffffffffc02011ac:	8c060613          	addi	a2,a2,-1856 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02011b0:	0fd00593          	li	a1,253
ffffffffc02011b4:	00004517          	auipc	a0,0x4
ffffffffc02011b8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc02011bc:	822ff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02011c0:	00004697          	auipc	a3,0x4
ffffffffc02011c4:	93068693          	addi	a3,a3,-1744 # ffffffffc0204af0 <commands+0x948>
ffffffffc02011c8:	00004617          	auipc	a2,0x4
ffffffffc02011cc:	8a060613          	addi	a2,a2,-1888 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02011d0:	0e900593          	li	a1,233
ffffffffc02011d4:	00004517          	auipc	a0,0x4
ffffffffc02011d8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc02011dc:	802ff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma2 != NULL);
ffffffffc02011e0:	00004697          	auipc	a3,0x4
ffffffffc02011e4:	97068693          	addi	a3,a3,-1680 # ffffffffc0204b50 <commands+0x9a8>
ffffffffc02011e8:	00004617          	auipc	a2,0x4
ffffffffc02011ec:	88060613          	addi	a2,a2,-1920 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02011f0:	0f400593          	li	a1,244
ffffffffc02011f4:	00004517          	auipc	a0,0x4
ffffffffc02011f8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc02011fc:	fe3fe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma1 != NULL);
ffffffffc0201200:	00004697          	auipc	a3,0x4
ffffffffc0201204:	94068693          	addi	a3,a3,-1728 # ffffffffc0204b40 <commands+0x998>
ffffffffc0201208:	00004617          	auipc	a2,0x4
ffffffffc020120c:	86060613          	addi	a2,a2,-1952 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201210:	0f200593          	li	a1,242
ffffffffc0201214:	00004517          	auipc	a0,0x4
ffffffffc0201218:	86c50513          	addi	a0,a0,-1940 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020121c:	fc3fe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma3 == NULL);
ffffffffc0201220:	00004697          	auipc	a3,0x4
ffffffffc0201224:	94068693          	addi	a3,a3,-1728 # ffffffffc0204b60 <commands+0x9b8>
ffffffffc0201228:	00004617          	auipc	a2,0x4
ffffffffc020122c:	84060613          	addi	a2,a2,-1984 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201230:	0f600593          	li	a1,246
ffffffffc0201234:	00004517          	auipc	a0,0x4
ffffffffc0201238:	84c50513          	addi	a0,a0,-1972 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020123c:	fa3fe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma5 == NULL);
ffffffffc0201240:	00004697          	auipc	a3,0x4
ffffffffc0201244:	94068693          	addi	a3,a3,-1728 # ffffffffc0204b80 <commands+0x9d8>
ffffffffc0201248:	00004617          	auipc	a2,0x4
ffffffffc020124c:	82060613          	addi	a2,a2,-2016 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201250:	0fa00593          	li	a1,250
ffffffffc0201254:	00004517          	auipc	a0,0x4
ffffffffc0201258:	82c50513          	addi	a0,a0,-2004 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020125c:	f83fe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma4 == NULL);
ffffffffc0201260:	00004697          	auipc	a3,0x4
ffffffffc0201264:	91068693          	addi	a3,a3,-1776 # ffffffffc0204b70 <commands+0x9c8>
ffffffffc0201268:	00004617          	auipc	a2,0x4
ffffffffc020126c:	80060613          	addi	a2,a2,-2048 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201270:	0f800593          	li	a1,248
ffffffffc0201274:	00004517          	auipc	a0,0x4
ffffffffc0201278:	80c50513          	addi	a0,a0,-2036 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020127c:	f63fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(mm != NULL);
ffffffffc0201280:	00004697          	auipc	a3,0x4
ffffffffc0201284:	9f868693          	addi	a3,a3,-1544 # ffffffffc0204c78 <commands+0xad0>
ffffffffc0201288:	00003617          	auipc	a2,0x3
ffffffffc020128c:	7e060613          	addi	a2,a2,2016 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201290:	0d200593          	li	a1,210
ffffffffc0201294:	00003517          	auipc	a0,0x3
ffffffffc0201298:	7ec50513          	addi	a0,a0,2028 # ffffffffc0204a80 <commands+0x8d8>
ffffffffc020129c:	f43fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02012a0 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02012a0:	c94d                	beqz	a0,ffffffffc0201352 <slob_free+0xb2>
{
ffffffffc02012a2:	1141                	addi	sp,sp,-16
ffffffffc02012a4:	e022                	sd	s0,0(sp)
ffffffffc02012a6:	e406                	sd	ra,8(sp)
ffffffffc02012a8:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02012aa:	e9c1                	bnez	a1,ffffffffc020133a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ac:	100027f3          	csrr	a5,sstatus
ffffffffc02012b0:	8b89                	andi	a5,a5,2
    return 0;            // 返回false表示原本关闭
ffffffffc02012b2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012b4:	ebd9                	bnez	a5,ffffffffc020134a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02012b6:	00008617          	auipc	a2,0x8
ffffffffc02012ba:	d6a60613          	addi	a2,a2,-662 # ffffffffc0209020 <slobfree>
ffffffffc02012be:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02012c0:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02012c2:	679c                	ld	a5,8(a5)
ffffffffc02012c4:	02877a63          	bgeu	a4,s0,ffffffffc02012f8 <slob_free+0x58>
ffffffffc02012c8:	00f46463          	bltu	s0,a5,ffffffffc02012d0 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02012cc:	fef76ae3          	bltu	a4,a5,ffffffffc02012c0 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc02012d0:	400c                	lw	a1,0(s0)
ffffffffc02012d2:	00459693          	slli	a3,a1,0x4
ffffffffc02012d6:	96a2                	add	a3,a3,s0
ffffffffc02012d8:	02d78a63          	beq	a5,a3,ffffffffc020130c <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02012dc:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02012de:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02012e0:	00469793          	slli	a5,a3,0x4
ffffffffc02012e4:	97ba                	add	a5,a5,a4
ffffffffc02012e6:	02f40e63          	beq	s0,a5,ffffffffc0201322 <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc02012ea:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02012ec:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02012ee:	e129                	bnez	a0,ffffffffc0201330 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02012f0:	60a2                	ld	ra,8(sp)
ffffffffc02012f2:	6402                	ld	s0,0(sp)
ffffffffc02012f4:	0141                	addi	sp,sp,16
ffffffffc02012f6:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02012f8:	fcf764e3          	bltu	a4,a5,ffffffffc02012c0 <slob_free+0x20>
ffffffffc02012fc:	fcf472e3          	bgeu	s0,a5,ffffffffc02012c0 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc0201300:	400c                	lw	a1,0(s0)
ffffffffc0201302:	00459693          	slli	a3,a1,0x4
ffffffffc0201306:	96a2                	add	a3,a3,s0
ffffffffc0201308:	fcd79ae3          	bne	a5,a3,ffffffffc02012dc <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020130c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020130e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201310:	9db5                	addw	a1,a1,a3
ffffffffc0201312:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc0201314:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201316:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201318:	00469793          	slli	a5,a3,0x4
ffffffffc020131c:	97ba                	add	a5,a5,a4
ffffffffc020131e:	fcf416e3          	bne	s0,a5,ffffffffc02012ea <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201322:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201324:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201326:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201328:	9ebd                	addw	a3,a3,a5
ffffffffc020132a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc020132c:	e70c                	sd	a1,8(a4)
ffffffffc020132e:	d169                	beqz	a0,ffffffffc02012f0 <slob_free+0x50>
}
ffffffffc0201330:	6402                	ld	s0,0(sp)
ffffffffc0201332:	60a2                	ld	ra,8(sp)
ffffffffc0201334:	0141                	addi	sp,sp,16
        intr_enable();   // 开启中断
ffffffffc0201336:	dfaff06f          	j	ffffffffc0200930 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020133a:	25bd                	addiw	a1,a1,15
ffffffffc020133c:	8191                	srli	a1,a1,0x4
ffffffffc020133e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201340:	100027f3          	csrr	a5,sstatus
ffffffffc0201344:	8b89                	andi	a5,a5,2
    return 0;            // 返回false表示原本关闭
ffffffffc0201346:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201348:	d7bd                	beqz	a5,ffffffffc02012b6 <slob_free+0x16>
        intr_disable();  // 关闭中断
ffffffffc020134a:	decff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;        // 返回true表示原本开启
ffffffffc020134e:	4505                	li	a0,1
ffffffffc0201350:	b79d                	j	ffffffffc02012b6 <slob_free+0x16>
ffffffffc0201352:	8082                	ret

ffffffffc0201354 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201354:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201356:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201358:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020135c:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc020135e:	5fd000ef          	jal	ra,ffffffffc020215a <alloc_pages>
	if (!page)
ffffffffc0201362:	c91d                	beqz	a0,ffffffffc0201398 <__slob_get_free_pages.constprop.0+0x44>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0201364:	0000c697          	auipc	a3,0xc
ffffffffc0201368:	14c6b683          	ld	a3,332(a3) # ffffffffc020d4b0 <pages>
ffffffffc020136c:	8d15                	sub	a0,a0,a3
ffffffffc020136e:	8519                	srai	a0,a0,0x6
ffffffffc0201370:	00004697          	auipc	a3,0x4
ffffffffc0201374:	7b06b683          	ld	a3,1968(a3) # ffffffffc0205b20 <nbase>
ffffffffc0201378:	9536                	add	a0,a0,a3
}

static inline void *
page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
ffffffffc020137a:	00c51793          	slli	a5,a0,0xc
ffffffffc020137e:	83b1                	srli	a5,a5,0xc
ffffffffc0201380:	0000c717          	auipc	a4,0xc
ffffffffc0201384:	12873703          	ld	a4,296(a4) # ffffffffc020d4a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201388:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc020138a:	00e7fa63          	bgeu	a5,a4,ffffffffc020139e <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020138e:	0000c697          	auipc	a3,0xc
ffffffffc0201392:	1326b683          	ld	a3,306(a3) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc0201396:	9536                	add	a0,a0,a3
}
ffffffffc0201398:	60a2                	ld	ra,8(sp)
ffffffffc020139a:	0141                	addi	sp,sp,16
ffffffffc020139c:	8082                	ret
ffffffffc020139e:	86aa                	mv	a3,a0
ffffffffc02013a0:	00004617          	auipc	a2,0x4
ffffffffc02013a4:	8e860613          	addi	a2,a2,-1816 # ffffffffc0204c88 <commands+0xae0>
ffffffffc02013a8:	07100593          	li	a1,113
ffffffffc02013ac:	00004517          	auipc	a0,0x4
ffffffffc02013b0:	90450513          	addi	a0,a0,-1788 # ffffffffc0204cb0 <commands+0xb08>
ffffffffc02013b4:	e2bfe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02013b8 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02013b8:	1101                	addi	sp,sp,-32
ffffffffc02013ba:	ec06                	sd	ra,24(sp)
ffffffffc02013bc:	e822                	sd	s0,16(sp)
ffffffffc02013be:	e426                	sd	s1,8(sp)
ffffffffc02013c0:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02013c2:	01050713          	addi	a4,a0,16
ffffffffc02013c6:	6785                	lui	a5,0x1
ffffffffc02013c8:	0cf77363          	bgeu	a4,a5,ffffffffc020148e <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02013cc:	00f50493          	addi	s1,a0,15
ffffffffc02013d0:	8091                	srli	s1,s1,0x4
ffffffffc02013d2:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013d4:	10002673          	csrr	a2,sstatus
ffffffffc02013d8:	8a09                	andi	a2,a2,2
ffffffffc02013da:	e25d                	bnez	a2,ffffffffc0201480 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02013dc:	00008917          	auipc	s2,0x8
ffffffffc02013e0:	c4490913          	addi	s2,s2,-956 # ffffffffc0209020 <slobfree>
ffffffffc02013e4:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013e8:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc02013ea:	4398                	lw	a4,0(a5)
ffffffffc02013ec:	08975e63          	bge	a4,s1,ffffffffc0201488 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc02013f0:	00d78b63          	beq	a5,a3,ffffffffc0201406 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013f4:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02013f6:	4018                	lw	a4,0(s0)
ffffffffc02013f8:	02975a63          	bge	a4,s1,ffffffffc020142c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc02013fc:	00093683          	ld	a3,0(s2)
ffffffffc0201400:	87a2                	mv	a5,s0
ffffffffc0201402:	fed799e3          	bne	a5,a3,ffffffffc02013f4 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201406:	ee31                	bnez	a2,ffffffffc0201462 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201408:	4501                	li	a0,0
ffffffffc020140a:	f4bff0ef          	jal	ra,ffffffffc0201354 <__slob_get_free_pages.constprop.0>
ffffffffc020140e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201410:	cd05                	beqz	a0,ffffffffc0201448 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201412:	6585                	lui	a1,0x1
ffffffffc0201414:	e8dff0ef          	jal	ra,ffffffffc02012a0 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201418:	10002673          	csrr	a2,sstatus
ffffffffc020141c:	8a09                	andi	a2,a2,2
ffffffffc020141e:	ee05                	bnez	a2,ffffffffc0201456 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201420:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201424:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc0201426:	4018                	lw	a4,0(s0)
ffffffffc0201428:	fc974ae3          	blt	a4,s1,ffffffffc02013fc <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc020142c:	04e48763          	beq	s1,a4,ffffffffc020147a <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201430:	00449693          	slli	a3,s1,0x4
ffffffffc0201434:	96a2                	add	a3,a3,s0
ffffffffc0201436:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201438:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc020143a:	9f05                	subw	a4,a4,s1
ffffffffc020143c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc020143e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201440:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201442:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201446:	e20d                	bnez	a2,ffffffffc0201468 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201448:	60e2                	ld	ra,24(sp)
ffffffffc020144a:	8522                	mv	a0,s0
ffffffffc020144c:	6442                	ld	s0,16(sp)
ffffffffc020144e:	64a2                	ld	s1,8(sp)
ffffffffc0201450:	6902                	ld	s2,0(sp)
ffffffffc0201452:	6105                	addi	sp,sp,32
ffffffffc0201454:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc0201456:	ce0ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
			cur = slobfree;
ffffffffc020145a:	00093783          	ld	a5,0(s2)
        return 1;        // 返回true表示原本开启
ffffffffc020145e:	4605                	li	a2,1
ffffffffc0201460:	b7d1                	j	ffffffffc0201424 <slob_alloc.constprop.0+0x6c>
        intr_enable();   // 开启中断
ffffffffc0201462:	cceff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201466:	b74d                	j	ffffffffc0201408 <slob_alloc.constprop.0+0x50>
ffffffffc0201468:	cc8ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
}
ffffffffc020146c:	60e2                	ld	ra,24(sp)
ffffffffc020146e:	8522                	mv	a0,s0
ffffffffc0201470:	6442                	ld	s0,16(sp)
ffffffffc0201472:	64a2                	ld	s1,8(sp)
ffffffffc0201474:	6902                	ld	s2,0(sp)
ffffffffc0201476:	6105                	addi	sp,sp,32
ffffffffc0201478:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020147a:	6418                	ld	a4,8(s0)
ffffffffc020147c:	e798                	sd	a4,8(a5)
ffffffffc020147e:	b7d1                	j	ffffffffc0201442 <slob_alloc.constprop.0+0x8a>
        intr_disable();  // 关闭中断
ffffffffc0201480:	cb6ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;        // 返回true表示原本开启
ffffffffc0201484:	4605                	li	a2,1
ffffffffc0201486:	bf99                	j	ffffffffc02013dc <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201488:	843e                	mv	s0,a5
ffffffffc020148a:	87b6                	mv	a5,a3
ffffffffc020148c:	b745                	j	ffffffffc020142c <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc020148e:	00004697          	auipc	a3,0x4
ffffffffc0201492:	83268693          	addi	a3,a3,-1998 # ffffffffc0204cc0 <commands+0xb18>
ffffffffc0201496:	00003617          	auipc	a2,0x3
ffffffffc020149a:	5d260613          	addi	a2,a2,1490 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc020149e:	06300593          	li	a1,99
ffffffffc02014a2:	00004517          	auipc	a0,0x4
ffffffffc02014a6:	83e50513          	addi	a0,a0,-1986 # ffffffffc0204ce0 <commands+0xb38>
ffffffffc02014aa:	d35fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02014ae <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc02014ae:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc02014b0:	00004517          	auipc	a0,0x4
ffffffffc02014b4:	84850513          	addi	a0,a0,-1976 # ffffffffc0204cf8 <commands+0xb50>
{
ffffffffc02014b8:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc02014ba:	c27fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02014be:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc02014c0:	00004517          	auipc	a0,0x4
ffffffffc02014c4:	85050513          	addi	a0,a0,-1968 # ffffffffc0204d10 <commands+0xb68>
}
ffffffffc02014c8:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc02014ca:	c17fe06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc02014ce <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02014ce:	1101                	addi	sp,sp,-32
ffffffffc02014d0:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02014d2:	6905                	lui	s2,0x1
{
ffffffffc02014d4:	e822                	sd	s0,16(sp)
ffffffffc02014d6:	ec06                	sd	ra,24(sp)
ffffffffc02014d8:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02014da:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc02014de:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02014e0:	04a7f963          	bgeu	a5,a0,ffffffffc0201532 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02014e4:	4561                	li	a0,24
ffffffffc02014e6:	ed3ff0ef          	jal	ra,ffffffffc02013b8 <slob_alloc.constprop.0>
ffffffffc02014ea:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02014ec:	c929                	beqz	a0,ffffffffc020153e <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02014ee:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02014f2:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc02014f4:	00f95763          	bge	s2,a5,ffffffffc0201502 <kmalloc+0x34>
ffffffffc02014f8:	6705                	lui	a4,0x1
ffffffffc02014fa:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02014fc:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc02014fe:	fef74ee3          	blt	a4,a5,ffffffffc02014fa <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201502:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201504:	e51ff0ef          	jal	ra,ffffffffc0201354 <__slob_get_free_pages.constprop.0>
ffffffffc0201508:	e488                	sd	a0,8(s1)
ffffffffc020150a:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc020150c:	c525                	beqz	a0,ffffffffc0201574 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020150e:	100027f3          	csrr	a5,sstatus
ffffffffc0201512:	8b89                	andi	a5,a5,2
ffffffffc0201514:	ef8d                	bnez	a5,ffffffffc020154e <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201516:	0000c797          	auipc	a5,0xc
ffffffffc020151a:	f7a78793          	addi	a5,a5,-134 # ffffffffc020d490 <bigblocks>
ffffffffc020151e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201520:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201522:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201524:	60e2                	ld	ra,24(sp)
ffffffffc0201526:	8522                	mv	a0,s0
ffffffffc0201528:	6442                	ld	s0,16(sp)
ffffffffc020152a:	64a2                	ld	s1,8(sp)
ffffffffc020152c:	6902                	ld	s2,0(sp)
ffffffffc020152e:	6105                	addi	sp,sp,32
ffffffffc0201530:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201532:	0541                	addi	a0,a0,16
ffffffffc0201534:	e85ff0ef          	jal	ra,ffffffffc02013b8 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201538:	01050413          	addi	s0,a0,16
ffffffffc020153c:	f565                	bnez	a0,ffffffffc0201524 <kmalloc+0x56>
ffffffffc020153e:	4401                	li	s0,0
}
ffffffffc0201540:	60e2                	ld	ra,24(sp)
ffffffffc0201542:	8522                	mv	a0,s0
ffffffffc0201544:	6442                	ld	s0,16(sp)
ffffffffc0201546:	64a2                	ld	s1,8(sp)
ffffffffc0201548:	6902                	ld	s2,0(sp)
ffffffffc020154a:	6105                	addi	sp,sp,32
ffffffffc020154c:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc020154e:	be8ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201552:	0000c797          	auipc	a5,0xc
ffffffffc0201556:	f3e78793          	addi	a5,a5,-194 # ffffffffc020d490 <bigblocks>
ffffffffc020155a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc020155c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc020155e:	e898                	sd	a4,16(s1)
        intr_enable();   // 开启中断
ffffffffc0201560:	bd0ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
		return bb->pages;
ffffffffc0201564:	6480                	ld	s0,8(s1)
}
ffffffffc0201566:	60e2                	ld	ra,24(sp)
ffffffffc0201568:	64a2                	ld	s1,8(sp)
ffffffffc020156a:	8522                	mv	a0,s0
ffffffffc020156c:	6442                	ld	s0,16(sp)
ffffffffc020156e:	6902                	ld	s2,0(sp)
ffffffffc0201570:	6105                	addi	sp,sp,32
ffffffffc0201572:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201574:	45e1                	li	a1,24
ffffffffc0201576:	8526                	mv	a0,s1
ffffffffc0201578:	d29ff0ef          	jal	ra,ffffffffc02012a0 <slob_free>
	return __kmalloc(size, 0);
ffffffffc020157c:	b765                	j	ffffffffc0201524 <kmalloc+0x56>

ffffffffc020157e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc020157e:	c169                	beqz	a0,ffffffffc0201640 <kfree+0xc2>
{
ffffffffc0201580:	1101                	addi	sp,sp,-32
ffffffffc0201582:	e822                	sd	s0,16(sp)
ffffffffc0201584:	ec06                	sd	ra,24(sp)
ffffffffc0201586:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201588:	03451793          	slli	a5,a0,0x34
ffffffffc020158c:	842a                	mv	s0,a0
ffffffffc020158e:	e3d9                	bnez	a5,ffffffffc0201614 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201590:	100027f3          	csrr	a5,sstatus
ffffffffc0201594:	8b89                	andi	a5,a5,2
ffffffffc0201596:	e7d9                	bnez	a5,ffffffffc0201624 <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201598:	0000c797          	auipc	a5,0xc
ffffffffc020159c:	ef87b783          	ld	a5,-264(a5) # ffffffffc020d490 <bigblocks>
    return 0;            // 返回false表示原本关闭
ffffffffc02015a0:	4601                	li	a2,0
ffffffffc02015a2:	cbad                	beqz	a5,ffffffffc0201614 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc02015a4:	0000c697          	auipc	a3,0xc
ffffffffc02015a8:	eec68693          	addi	a3,a3,-276 # ffffffffc020d490 <bigblocks>
ffffffffc02015ac:	a021                	j	ffffffffc02015b4 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02015ae:	01048693          	addi	a3,s1,16
ffffffffc02015b2:	c3a5                	beqz	a5,ffffffffc0201612 <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc02015b4:	6798                	ld	a4,8(a5)
ffffffffc02015b6:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc02015b8:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc02015ba:	fe871ae3          	bne	a4,s0,ffffffffc02015ae <kfree+0x30>
				*last = bb->next;
ffffffffc02015be:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc02015c0:	ee2d                	bnez	a2,ffffffffc020163a <kfree+0xbc>
}

static inline struct Page *
kva2page(void *kva)
{
    return pa2page(PADDR(kva));
ffffffffc02015c2:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02015c6:	4098                	lw	a4,0(s1)
ffffffffc02015c8:	08f46963          	bltu	s0,a5,ffffffffc020165a <kfree+0xdc>
ffffffffc02015cc:	0000c697          	auipc	a3,0xc
ffffffffc02015d0:	ef46b683          	ld	a3,-268(a3) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc02015d4:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc02015d6:	8031                	srli	s0,s0,0xc
ffffffffc02015d8:	0000c797          	auipc	a5,0xc
ffffffffc02015dc:	ed07b783          	ld	a5,-304(a5) # ffffffffc020d4a8 <npage>
ffffffffc02015e0:	06f47163          	bgeu	s0,a5,ffffffffc0201642 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc02015e4:	00004517          	auipc	a0,0x4
ffffffffc02015e8:	53c53503          	ld	a0,1340(a0) # ffffffffc0205b20 <nbase>
ffffffffc02015ec:	8c09                	sub	s0,s0,a0
ffffffffc02015ee:	041a                	slli	s0,s0,0x6
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc02015f0:	0000c517          	auipc	a0,0xc
ffffffffc02015f4:	ec053503          	ld	a0,-320(a0) # ffffffffc020d4b0 <pages>
ffffffffc02015f8:	4585                	li	a1,1
ffffffffc02015fa:	9522                	add	a0,a0,s0
ffffffffc02015fc:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201600:	399000ef          	jal	ra,ffffffffc0202198 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201604:	6442                	ld	s0,16(sp)
ffffffffc0201606:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201608:	8526                	mv	a0,s1
}
ffffffffc020160a:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020160c:	45e1                	li	a1,24
}
ffffffffc020160e:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201610:	b941                	j	ffffffffc02012a0 <slob_free>
ffffffffc0201612:	e20d                	bnez	a2,ffffffffc0201634 <kfree+0xb6>
ffffffffc0201614:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201618:	6442                	ld	s0,16(sp)
ffffffffc020161a:	60e2                	ld	ra,24(sp)
ffffffffc020161c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020161e:	4581                	li	a1,0
}
ffffffffc0201620:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201622:	b9bd                	j	ffffffffc02012a0 <slob_free>
        intr_disable();  // 关闭中断
ffffffffc0201624:	b12ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201628:	0000c797          	auipc	a5,0xc
ffffffffc020162c:	e687b783          	ld	a5,-408(a5) # ffffffffc020d490 <bigblocks>
        return 1;        // 返回true表示原本开启
ffffffffc0201630:	4605                	li	a2,1
ffffffffc0201632:	fbad                	bnez	a5,ffffffffc02015a4 <kfree+0x26>
        intr_enable();   // 开启中断
ffffffffc0201634:	afcff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0201638:	bff1                	j	ffffffffc0201614 <kfree+0x96>
ffffffffc020163a:	af6ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020163e:	b751                	j	ffffffffc02015c2 <kfree+0x44>
ffffffffc0201640:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201642:	00003617          	auipc	a2,0x3
ffffffffc0201646:	71660613          	addi	a2,a2,1814 # ffffffffc0204d58 <commands+0xbb0>
ffffffffc020164a:	06900593          	li	a1,105
ffffffffc020164e:	00003517          	auipc	a0,0x3
ffffffffc0201652:	66250513          	addi	a0,a0,1634 # ffffffffc0204cb0 <commands+0xb08>
ffffffffc0201656:	b89fe0ef          	jal	ra,ffffffffc02001de <__panic>
    return pa2page(PADDR(kva));
ffffffffc020165a:	86a2                	mv	a3,s0
ffffffffc020165c:	00003617          	auipc	a2,0x3
ffffffffc0201660:	6d460613          	addi	a2,a2,1748 # ffffffffc0204d30 <commands+0xb88>
ffffffffc0201664:	07700593          	li	a1,119
ffffffffc0201668:	00003517          	auipc	a0,0x3
ffffffffc020166c:	64850513          	addi	a0,a0,1608 # ffffffffc0204cb0 <commands+0xb08>
ffffffffc0201670:	b6ffe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201674 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201674:	00008797          	auipc	a5,0x8
ffffffffc0201678:	dbc78793          	addi	a5,a5,-580 # ffffffffc0209430 <free_area>
ffffffffc020167c:	e79c                	sd	a5,8(a5)
ffffffffc020167e:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201680:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201684:	8082                	ret

ffffffffc0201686 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201686:	00008517          	auipc	a0,0x8
ffffffffc020168a:	dba56503          	lwu	a0,-582(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc020168e:	8082                	ret

ffffffffc0201690 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201690:	715d                	addi	sp,sp,-80
ffffffffc0201692:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201694:	00008417          	auipc	s0,0x8
ffffffffc0201698:	d9c40413          	addi	s0,s0,-612 # ffffffffc0209430 <free_area>
ffffffffc020169c:	641c                	ld	a5,8(s0)
ffffffffc020169e:	e486                	sd	ra,72(sp)
ffffffffc02016a0:	fc26                	sd	s1,56(sp)
ffffffffc02016a2:	f84a                	sd	s2,48(sp)
ffffffffc02016a4:	f44e                	sd	s3,40(sp)
ffffffffc02016a6:	f052                	sd	s4,32(sp)
ffffffffc02016a8:	ec56                	sd	s5,24(sp)
ffffffffc02016aa:	e85a                	sd	s6,16(sp)
ffffffffc02016ac:	e45e                	sd	s7,8(sp)
ffffffffc02016ae:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02016b0:	2a878d63          	beq	a5,s0,ffffffffc020196a <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc02016b4:	4481                	li	s1,0
ffffffffc02016b6:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02016b8:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02016bc:	8b09                	andi	a4,a4,2
ffffffffc02016be:	2a070a63          	beqz	a4,ffffffffc0201972 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc02016c2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016c6:	679c                	ld	a5,8(a5)
ffffffffc02016c8:	2905                	addiw	s2,s2,1
ffffffffc02016ca:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02016cc:	fe8796e3          	bne	a5,s0,ffffffffc02016b8 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02016d0:	89a6                	mv	s3,s1
ffffffffc02016d2:	307000ef          	jal	ra,ffffffffc02021d8 <nr_free_pages>
ffffffffc02016d6:	6f351e63          	bne	a0,s3,ffffffffc0201dd2 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02016da:	4505                	li	a0,1
ffffffffc02016dc:	27f000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02016e0:	8aaa                	mv	s5,a0
ffffffffc02016e2:	42050863          	beqz	a0,ffffffffc0201b12 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02016e6:	4505                	li	a0,1
ffffffffc02016e8:	273000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02016ec:	89aa                	mv	s3,a0
ffffffffc02016ee:	70050263          	beqz	a0,ffffffffc0201df2 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02016f2:	4505                	li	a0,1
ffffffffc02016f4:	267000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02016f8:	8a2a                	mv	s4,a0
ffffffffc02016fa:	48050c63          	beqz	a0,ffffffffc0201b92 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02016fe:	293a8a63          	beq	s5,s3,ffffffffc0201992 <default_check+0x302>
ffffffffc0201702:	28aa8863          	beq	s5,a0,ffffffffc0201992 <default_check+0x302>
ffffffffc0201706:	28a98663          	beq	s3,a0,ffffffffc0201992 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020170a:	000aa783          	lw	a5,0(s5)
ffffffffc020170e:	2a079263          	bnez	a5,ffffffffc02019b2 <default_check+0x322>
ffffffffc0201712:	0009a783          	lw	a5,0(s3)
ffffffffc0201716:	28079e63          	bnez	a5,ffffffffc02019b2 <default_check+0x322>
ffffffffc020171a:	411c                	lw	a5,0(a0)
ffffffffc020171c:	28079b63          	bnez	a5,ffffffffc02019b2 <default_check+0x322>
    return page - pages + nbase;
ffffffffc0201720:	0000c797          	auipc	a5,0xc
ffffffffc0201724:	d907b783          	ld	a5,-624(a5) # ffffffffc020d4b0 <pages>
ffffffffc0201728:	40fa8733          	sub	a4,s5,a5
ffffffffc020172c:	00004617          	auipc	a2,0x4
ffffffffc0201730:	3f463603          	ld	a2,1012(a2) # ffffffffc0205b20 <nbase>
ffffffffc0201734:	8719                	srai	a4,a4,0x6
ffffffffc0201736:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201738:	0000c697          	auipc	a3,0xc
ffffffffc020173c:	d706b683          	ld	a3,-656(a3) # ffffffffc020d4a8 <npage>
ffffffffc0201740:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201742:	0732                	slli	a4,a4,0xc
ffffffffc0201744:	28d77763          	bgeu	a4,a3,ffffffffc02019d2 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0201748:	40f98733          	sub	a4,s3,a5
ffffffffc020174c:	8719                	srai	a4,a4,0x6
ffffffffc020174e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201750:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201752:	4cd77063          	bgeu	a4,a3,ffffffffc0201c12 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0201756:	40f507b3          	sub	a5,a0,a5
ffffffffc020175a:	8799                	srai	a5,a5,0x6
ffffffffc020175c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020175e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201760:	30d7f963          	bgeu	a5,a3,ffffffffc0201a72 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0201764:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201766:	00043c03          	ld	s8,0(s0)
ffffffffc020176a:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020176e:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201772:	e400                	sd	s0,8(s0)
ffffffffc0201774:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201776:	00008797          	auipc	a5,0x8
ffffffffc020177a:	cc07a523          	sw	zero,-822(a5) # ffffffffc0209440 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020177e:	1dd000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc0201782:	2c051863          	bnez	a0,ffffffffc0201a52 <default_check+0x3c2>
    free_page(p0);
ffffffffc0201786:	4585                	li	a1,1
ffffffffc0201788:	8556                	mv	a0,s5
ffffffffc020178a:	20f000ef          	jal	ra,ffffffffc0202198 <free_pages>
    free_page(p1);
ffffffffc020178e:	4585                	li	a1,1
ffffffffc0201790:	854e                	mv	a0,s3
ffffffffc0201792:	207000ef          	jal	ra,ffffffffc0202198 <free_pages>
    free_page(p2);
ffffffffc0201796:	4585                	li	a1,1
ffffffffc0201798:	8552                	mv	a0,s4
ffffffffc020179a:	1ff000ef          	jal	ra,ffffffffc0202198 <free_pages>
    assert(nr_free == 3);
ffffffffc020179e:	4818                	lw	a4,16(s0)
ffffffffc02017a0:	478d                	li	a5,3
ffffffffc02017a2:	28f71863          	bne	a4,a5,ffffffffc0201a32 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02017a6:	4505                	li	a0,1
ffffffffc02017a8:	1b3000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02017ac:	89aa                	mv	s3,a0
ffffffffc02017ae:	26050263          	beqz	a0,ffffffffc0201a12 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02017b2:	4505                	li	a0,1
ffffffffc02017b4:	1a7000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02017b8:	8aaa                	mv	s5,a0
ffffffffc02017ba:	3a050c63          	beqz	a0,ffffffffc0201b72 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02017be:	4505                	li	a0,1
ffffffffc02017c0:	19b000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02017c4:	8a2a                	mv	s4,a0
ffffffffc02017c6:	38050663          	beqz	a0,ffffffffc0201b52 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc02017ca:	4505                	li	a0,1
ffffffffc02017cc:	18f000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02017d0:	36051163          	bnez	a0,ffffffffc0201b32 <default_check+0x4a2>
    free_page(p0);
ffffffffc02017d4:	4585                	li	a1,1
ffffffffc02017d6:	854e                	mv	a0,s3
ffffffffc02017d8:	1c1000ef          	jal	ra,ffffffffc0202198 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02017dc:	641c                	ld	a5,8(s0)
ffffffffc02017de:	20878a63          	beq	a5,s0,ffffffffc02019f2 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc02017e2:	4505                	li	a0,1
ffffffffc02017e4:	177000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02017e8:	30a99563          	bne	s3,a0,ffffffffc0201af2 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02017ec:	4505                	li	a0,1
ffffffffc02017ee:	16d000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02017f2:	2e051063          	bnez	a0,ffffffffc0201ad2 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02017f6:	481c                	lw	a5,16(s0)
ffffffffc02017f8:	2a079d63          	bnez	a5,ffffffffc0201ab2 <default_check+0x422>
    free_page(p);
ffffffffc02017fc:	854e                	mv	a0,s3
ffffffffc02017fe:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201800:	01843023          	sd	s8,0(s0)
ffffffffc0201804:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201808:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc020180c:	18d000ef          	jal	ra,ffffffffc0202198 <free_pages>
    free_page(p1);
ffffffffc0201810:	4585                	li	a1,1
ffffffffc0201812:	8556                	mv	a0,s5
ffffffffc0201814:	185000ef          	jal	ra,ffffffffc0202198 <free_pages>
    free_page(p2);
ffffffffc0201818:	4585                	li	a1,1
ffffffffc020181a:	8552                	mv	a0,s4
ffffffffc020181c:	17d000ef          	jal	ra,ffffffffc0202198 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201820:	4515                	li	a0,5
ffffffffc0201822:	139000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc0201826:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201828:	26050563          	beqz	a0,ffffffffc0201a92 <default_check+0x402>
ffffffffc020182c:	651c                	ld	a5,8(a0)
ffffffffc020182e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201830:	8b85                	andi	a5,a5,1
ffffffffc0201832:	54079063          	bnez	a5,ffffffffc0201d72 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201836:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201838:	00043b03          	ld	s6,0(s0)
ffffffffc020183c:	00843a83          	ld	s5,8(s0)
ffffffffc0201840:	e000                	sd	s0,0(s0)
ffffffffc0201842:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201844:	117000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc0201848:	50051563          	bnez	a0,ffffffffc0201d52 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020184c:	08098a13          	addi	s4,s3,128
ffffffffc0201850:	8552                	mv	a0,s4
ffffffffc0201852:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201854:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201858:	00008797          	auipc	a5,0x8
ffffffffc020185c:	be07a423          	sw	zero,-1048(a5) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201860:	139000ef          	jal	ra,ffffffffc0202198 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201864:	4511                	li	a0,4
ffffffffc0201866:	0f5000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc020186a:	4c051463          	bnez	a0,ffffffffc0201d32 <default_check+0x6a2>
ffffffffc020186e:	0889b783          	ld	a5,136(s3)
ffffffffc0201872:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201874:	8b85                	andi	a5,a5,1
ffffffffc0201876:	48078e63          	beqz	a5,ffffffffc0201d12 <default_check+0x682>
ffffffffc020187a:	0909a703          	lw	a4,144(s3)
ffffffffc020187e:	478d                	li	a5,3
ffffffffc0201880:	48f71963          	bne	a4,a5,ffffffffc0201d12 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201884:	450d                	li	a0,3
ffffffffc0201886:	0d5000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc020188a:	8c2a                	mv	s8,a0
ffffffffc020188c:	46050363          	beqz	a0,ffffffffc0201cf2 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201890:	4505                	li	a0,1
ffffffffc0201892:	0c9000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc0201896:	42051e63          	bnez	a0,ffffffffc0201cd2 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc020189a:	418a1c63          	bne	s4,s8,ffffffffc0201cb2 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020189e:	4585                	li	a1,1
ffffffffc02018a0:	854e                	mv	a0,s3
ffffffffc02018a2:	0f7000ef          	jal	ra,ffffffffc0202198 <free_pages>
    free_pages(p1, 3);
ffffffffc02018a6:	458d                	li	a1,3
ffffffffc02018a8:	8552                	mv	a0,s4
ffffffffc02018aa:	0ef000ef          	jal	ra,ffffffffc0202198 <free_pages>
ffffffffc02018ae:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02018b2:	04098c13          	addi	s8,s3,64
ffffffffc02018b6:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02018b8:	8b85                	andi	a5,a5,1
ffffffffc02018ba:	3c078c63          	beqz	a5,ffffffffc0201c92 <default_check+0x602>
ffffffffc02018be:	0109a703          	lw	a4,16(s3)
ffffffffc02018c2:	4785                	li	a5,1
ffffffffc02018c4:	3cf71763          	bne	a4,a5,ffffffffc0201c92 <default_check+0x602>
ffffffffc02018c8:	008a3783          	ld	a5,8(s4)
ffffffffc02018cc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02018ce:	8b85                	andi	a5,a5,1
ffffffffc02018d0:	3a078163          	beqz	a5,ffffffffc0201c72 <default_check+0x5e2>
ffffffffc02018d4:	010a2703          	lw	a4,16(s4)
ffffffffc02018d8:	478d                	li	a5,3
ffffffffc02018da:	38f71c63          	bne	a4,a5,ffffffffc0201c72 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02018de:	4505                	li	a0,1
ffffffffc02018e0:	07b000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02018e4:	36a99763          	bne	s3,a0,ffffffffc0201c52 <default_check+0x5c2>
    free_page(p0);
ffffffffc02018e8:	4585                	li	a1,1
ffffffffc02018ea:	0af000ef          	jal	ra,ffffffffc0202198 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02018ee:	4509                	li	a0,2
ffffffffc02018f0:	06b000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc02018f4:	32aa1f63          	bne	s4,a0,ffffffffc0201c32 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02018f8:	4589                	li	a1,2
ffffffffc02018fa:	09f000ef          	jal	ra,ffffffffc0202198 <free_pages>
    free_page(p2);
ffffffffc02018fe:	4585                	li	a1,1
ffffffffc0201900:	8562                	mv	a0,s8
ffffffffc0201902:	097000ef          	jal	ra,ffffffffc0202198 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201906:	4515                	li	a0,5
ffffffffc0201908:	053000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc020190c:	89aa                	mv	s3,a0
ffffffffc020190e:	48050263          	beqz	a0,ffffffffc0201d92 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0201912:	4505                	li	a0,1
ffffffffc0201914:	047000ef          	jal	ra,ffffffffc020215a <alloc_pages>
ffffffffc0201918:	2c051d63          	bnez	a0,ffffffffc0201bf2 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc020191c:	481c                	lw	a5,16(s0)
ffffffffc020191e:	2a079a63          	bnez	a5,ffffffffc0201bd2 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201922:	4595                	li	a1,5
ffffffffc0201924:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201926:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc020192a:	01643023          	sd	s6,0(s0)
ffffffffc020192e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201932:	067000ef          	jal	ra,ffffffffc0202198 <free_pages>
    return listelm->next;
ffffffffc0201936:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201938:	00878963          	beq	a5,s0,ffffffffc020194a <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020193c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201940:	679c                	ld	a5,8(a5)
ffffffffc0201942:	397d                	addiw	s2,s2,-1
ffffffffc0201944:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201946:	fe879be3          	bne	a5,s0,ffffffffc020193c <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc020194a:	26091463          	bnez	s2,ffffffffc0201bb2 <default_check+0x522>
    assert(total == 0);
ffffffffc020194e:	46049263          	bnez	s1,ffffffffc0201db2 <default_check+0x722>
}
ffffffffc0201952:	60a6                	ld	ra,72(sp)
ffffffffc0201954:	6406                	ld	s0,64(sp)
ffffffffc0201956:	74e2                	ld	s1,56(sp)
ffffffffc0201958:	7942                	ld	s2,48(sp)
ffffffffc020195a:	79a2                	ld	s3,40(sp)
ffffffffc020195c:	7a02                	ld	s4,32(sp)
ffffffffc020195e:	6ae2                	ld	s5,24(sp)
ffffffffc0201960:	6b42                	ld	s6,16(sp)
ffffffffc0201962:	6ba2                	ld	s7,8(sp)
ffffffffc0201964:	6c02                	ld	s8,0(sp)
ffffffffc0201966:	6161                	addi	sp,sp,80
ffffffffc0201968:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020196a:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020196c:	4481                	li	s1,0
ffffffffc020196e:	4901                	li	s2,0
ffffffffc0201970:	b38d                	j	ffffffffc02016d2 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201972:	00003697          	auipc	a3,0x3
ffffffffc0201976:	40668693          	addi	a3,a3,1030 # ffffffffc0204d78 <commands+0xbd0>
ffffffffc020197a:	00003617          	auipc	a2,0x3
ffffffffc020197e:	0ee60613          	addi	a2,a2,238 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201982:	0f000593          	li	a1,240
ffffffffc0201986:	00003517          	auipc	a0,0x3
ffffffffc020198a:	40250513          	addi	a0,a0,1026 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc020198e:	851fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201992:	00003697          	auipc	a3,0x3
ffffffffc0201996:	48e68693          	addi	a3,a3,1166 # ffffffffc0204e20 <commands+0xc78>
ffffffffc020199a:	00003617          	auipc	a2,0x3
ffffffffc020199e:	0ce60613          	addi	a2,a2,206 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02019a2:	0bd00593          	li	a1,189
ffffffffc02019a6:	00003517          	auipc	a0,0x3
ffffffffc02019aa:	3e250513          	addi	a0,a0,994 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc02019ae:	831fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02019b2:	00003697          	auipc	a3,0x3
ffffffffc02019b6:	49668693          	addi	a3,a3,1174 # ffffffffc0204e48 <commands+0xca0>
ffffffffc02019ba:	00003617          	auipc	a2,0x3
ffffffffc02019be:	0ae60613          	addi	a2,a2,174 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02019c2:	0be00593          	li	a1,190
ffffffffc02019c6:	00003517          	auipc	a0,0x3
ffffffffc02019ca:	3c250513          	addi	a0,a0,962 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc02019ce:	811fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02019d2:	00003697          	auipc	a3,0x3
ffffffffc02019d6:	4b668693          	addi	a3,a3,1206 # ffffffffc0204e88 <commands+0xce0>
ffffffffc02019da:	00003617          	auipc	a2,0x3
ffffffffc02019de:	08e60613          	addi	a2,a2,142 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02019e2:	0c000593          	li	a1,192
ffffffffc02019e6:	00003517          	auipc	a0,0x3
ffffffffc02019ea:	3a250513          	addi	a0,a0,930 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc02019ee:	ff0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(!list_empty(&free_list));
ffffffffc02019f2:	00003697          	auipc	a3,0x3
ffffffffc02019f6:	51e68693          	addi	a3,a3,1310 # ffffffffc0204f10 <commands+0xd68>
ffffffffc02019fa:	00003617          	auipc	a2,0x3
ffffffffc02019fe:	06e60613          	addi	a2,a2,110 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201a02:	0d900593          	li	a1,217
ffffffffc0201a06:	00003517          	auipc	a0,0x3
ffffffffc0201a0a:	38250513          	addi	a0,a0,898 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201a0e:	fd0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201a12:	00003697          	auipc	a3,0x3
ffffffffc0201a16:	3ae68693          	addi	a3,a3,942 # ffffffffc0204dc0 <commands+0xc18>
ffffffffc0201a1a:	00003617          	auipc	a2,0x3
ffffffffc0201a1e:	04e60613          	addi	a2,a2,78 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201a22:	0d200593          	li	a1,210
ffffffffc0201a26:	00003517          	auipc	a0,0x3
ffffffffc0201a2a:	36250513          	addi	a0,a0,866 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201a2e:	fb0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 3);
ffffffffc0201a32:	00003697          	auipc	a3,0x3
ffffffffc0201a36:	4ce68693          	addi	a3,a3,1230 # ffffffffc0204f00 <commands+0xd58>
ffffffffc0201a3a:	00003617          	auipc	a2,0x3
ffffffffc0201a3e:	02e60613          	addi	a2,a2,46 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201a42:	0d000593          	li	a1,208
ffffffffc0201a46:	00003517          	auipc	a0,0x3
ffffffffc0201a4a:	34250513          	addi	a0,a0,834 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201a4e:	f90fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201a52:	00003697          	auipc	a3,0x3
ffffffffc0201a56:	49668693          	addi	a3,a3,1174 # ffffffffc0204ee8 <commands+0xd40>
ffffffffc0201a5a:	00003617          	auipc	a2,0x3
ffffffffc0201a5e:	00e60613          	addi	a2,a2,14 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201a62:	0cb00593          	li	a1,203
ffffffffc0201a66:	00003517          	auipc	a0,0x3
ffffffffc0201a6a:	32250513          	addi	a0,a0,802 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201a6e:	f70fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201a72:	00003697          	auipc	a3,0x3
ffffffffc0201a76:	45668693          	addi	a3,a3,1110 # ffffffffc0204ec8 <commands+0xd20>
ffffffffc0201a7a:	00003617          	auipc	a2,0x3
ffffffffc0201a7e:	fee60613          	addi	a2,a2,-18 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201a82:	0c200593          	li	a1,194
ffffffffc0201a86:	00003517          	auipc	a0,0x3
ffffffffc0201a8a:	30250513          	addi	a0,a0,770 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201a8e:	f50fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 != NULL);
ffffffffc0201a92:	00003697          	auipc	a3,0x3
ffffffffc0201a96:	4c668693          	addi	a3,a3,1222 # ffffffffc0204f58 <commands+0xdb0>
ffffffffc0201a9a:	00003617          	auipc	a2,0x3
ffffffffc0201a9e:	fce60613          	addi	a2,a2,-50 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201aa2:	0f800593          	li	a1,248
ffffffffc0201aa6:	00003517          	auipc	a0,0x3
ffffffffc0201aaa:	2e250513          	addi	a0,a0,738 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201aae:	f30fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 0);
ffffffffc0201ab2:	00003697          	auipc	a3,0x3
ffffffffc0201ab6:	49668693          	addi	a3,a3,1174 # ffffffffc0204f48 <commands+0xda0>
ffffffffc0201aba:	00003617          	auipc	a2,0x3
ffffffffc0201abe:	fae60613          	addi	a2,a2,-82 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201ac2:	0df00593          	li	a1,223
ffffffffc0201ac6:	00003517          	auipc	a0,0x3
ffffffffc0201aca:	2c250513          	addi	a0,a0,706 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201ace:	f10fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201ad2:	00003697          	auipc	a3,0x3
ffffffffc0201ad6:	41668693          	addi	a3,a3,1046 # ffffffffc0204ee8 <commands+0xd40>
ffffffffc0201ada:	00003617          	auipc	a2,0x3
ffffffffc0201ade:	f8e60613          	addi	a2,a2,-114 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201ae2:	0dd00593          	li	a1,221
ffffffffc0201ae6:	00003517          	auipc	a0,0x3
ffffffffc0201aea:	2a250513          	addi	a0,a0,674 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201aee:	ef0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201af2:	00003697          	auipc	a3,0x3
ffffffffc0201af6:	43668693          	addi	a3,a3,1078 # ffffffffc0204f28 <commands+0xd80>
ffffffffc0201afa:	00003617          	auipc	a2,0x3
ffffffffc0201afe:	f6e60613          	addi	a2,a2,-146 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201b02:	0dc00593          	li	a1,220
ffffffffc0201b06:	00003517          	auipc	a0,0x3
ffffffffc0201b0a:	28250513          	addi	a0,a0,642 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201b0e:	ed0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201b12:	00003697          	auipc	a3,0x3
ffffffffc0201b16:	2ae68693          	addi	a3,a3,686 # ffffffffc0204dc0 <commands+0xc18>
ffffffffc0201b1a:	00003617          	auipc	a2,0x3
ffffffffc0201b1e:	f4e60613          	addi	a2,a2,-178 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201b22:	0b900593          	li	a1,185
ffffffffc0201b26:	00003517          	auipc	a0,0x3
ffffffffc0201b2a:	26250513          	addi	a0,a0,610 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201b2e:	eb0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201b32:	00003697          	auipc	a3,0x3
ffffffffc0201b36:	3b668693          	addi	a3,a3,950 # ffffffffc0204ee8 <commands+0xd40>
ffffffffc0201b3a:	00003617          	auipc	a2,0x3
ffffffffc0201b3e:	f2e60613          	addi	a2,a2,-210 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201b42:	0d600593          	li	a1,214
ffffffffc0201b46:	00003517          	auipc	a0,0x3
ffffffffc0201b4a:	24250513          	addi	a0,a0,578 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201b4e:	e90fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b52:	00003697          	auipc	a3,0x3
ffffffffc0201b56:	2ae68693          	addi	a3,a3,686 # ffffffffc0204e00 <commands+0xc58>
ffffffffc0201b5a:	00003617          	auipc	a2,0x3
ffffffffc0201b5e:	f0e60613          	addi	a2,a2,-242 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201b62:	0d400593          	li	a1,212
ffffffffc0201b66:	00003517          	auipc	a0,0x3
ffffffffc0201b6a:	22250513          	addi	a0,a0,546 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201b6e:	e70fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201b72:	00003697          	auipc	a3,0x3
ffffffffc0201b76:	26e68693          	addi	a3,a3,622 # ffffffffc0204de0 <commands+0xc38>
ffffffffc0201b7a:	00003617          	auipc	a2,0x3
ffffffffc0201b7e:	eee60613          	addi	a2,a2,-274 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201b82:	0d300593          	li	a1,211
ffffffffc0201b86:	00003517          	auipc	a0,0x3
ffffffffc0201b8a:	20250513          	addi	a0,a0,514 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201b8e:	e50fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b92:	00003697          	auipc	a3,0x3
ffffffffc0201b96:	26e68693          	addi	a3,a3,622 # ffffffffc0204e00 <commands+0xc58>
ffffffffc0201b9a:	00003617          	auipc	a2,0x3
ffffffffc0201b9e:	ece60613          	addi	a2,a2,-306 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201ba2:	0bb00593          	li	a1,187
ffffffffc0201ba6:	00003517          	auipc	a0,0x3
ffffffffc0201baa:	1e250513          	addi	a0,a0,482 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201bae:	e30fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(count == 0);
ffffffffc0201bb2:	00003697          	auipc	a3,0x3
ffffffffc0201bb6:	4f668693          	addi	a3,a3,1270 # ffffffffc02050a8 <commands+0xf00>
ffffffffc0201bba:	00003617          	auipc	a2,0x3
ffffffffc0201bbe:	eae60613          	addi	a2,a2,-338 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201bc2:	12500593          	li	a1,293
ffffffffc0201bc6:	00003517          	auipc	a0,0x3
ffffffffc0201bca:	1c250513          	addi	a0,a0,450 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201bce:	e10fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 0);
ffffffffc0201bd2:	00003697          	auipc	a3,0x3
ffffffffc0201bd6:	37668693          	addi	a3,a3,886 # ffffffffc0204f48 <commands+0xda0>
ffffffffc0201bda:	00003617          	auipc	a2,0x3
ffffffffc0201bde:	e8e60613          	addi	a2,a2,-370 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201be2:	11a00593          	li	a1,282
ffffffffc0201be6:	00003517          	auipc	a0,0x3
ffffffffc0201bea:	1a250513          	addi	a0,a0,418 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201bee:	df0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201bf2:	00003697          	auipc	a3,0x3
ffffffffc0201bf6:	2f668693          	addi	a3,a3,758 # ffffffffc0204ee8 <commands+0xd40>
ffffffffc0201bfa:	00003617          	auipc	a2,0x3
ffffffffc0201bfe:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201c02:	11800593          	li	a1,280
ffffffffc0201c06:	00003517          	auipc	a0,0x3
ffffffffc0201c0a:	18250513          	addi	a0,a0,386 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201c0e:	dd0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c12:	00003697          	auipc	a3,0x3
ffffffffc0201c16:	29668693          	addi	a3,a3,662 # ffffffffc0204ea8 <commands+0xd00>
ffffffffc0201c1a:	00003617          	auipc	a2,0x3
ffffffffc0201c1e:	e4e60613          	addi	a2,a2,-434 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201c22:	0c100593          	li	a1,193
ffffffffc0201c26:	00003517          	auipc	a0,0x3
ffffffffc0201c2a:	16250513          	addi	a0,a0,354 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201c2e:	db0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201c32:	00003697          	auipc	a3,0x3
ffffffffc0201c36:	43668693          	addi	a3,a3,1078 # ffffffffc0205068 <commands+0xec0>
ffffffffc0201c3a:	00003617          	auipc	a2,0x3
ffffffffc0201c3e:	e2e60613          	addi	a2,a2,-466 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201c42:	11200593          	li	a1,274
ffffffffc0201c46:	00003517          	auipc	a0,0x3
ffffffffc0201c4a:	14250513          	addi	a0,a0,322 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201c4e:	d90fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201c52:	00003697          	auipc	a3,0x3
ffffffffc0201c56:	3f668693          	addi	a3,a3,1014 # ffffffffc0205048 <commands+0xea0>
ffffffffc0201c5a:	00003617          	auipc	a2,0x3
ffffffffc0201c5e:	e0e60613          	addi	a2,a2,-498 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201c62:	11000593          	li	a1,272
ffffffffc0201c66:	00003517          	auipc	a0,0x3
ffffffffc0201c6a:	12250513          	addi	a0,a0,290 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201c6e:	d70fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201c72:	00003697          	auipc	a3,0x3
ffffffffc0201c76:	3ae68693          	addi	a3,a3,942 # ffffffffc0205020 <commands+0xe78>
ffffffffc0201c7a:	00003617          	auipc	a2,0x3
ffffffffc0201c7e:	dee60613          	addi	a2,a2,-530 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201c82:	10e00593          	li	a1,270
ffffffffc0201c86:	00003517          	auipc	a0,0x3
ffffffffc0201c8a:	10250513          	addi	a0,a0,258 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201c8e:	d50fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201c92:	00003697          	auipc	a3,0x3
ffffffffc0201c96:	36668693          	addi	a3,a3,870 # ffffffffc0204ff8 <commands+0xe50>
ffffffffc0201c9a:	00003617          	auipc	a2,0x3
ffffffffc0201c9e:	dce60613          	addi	a2,a2,-562 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201ca2:	10d00593          	li	a1,269
ffffffffc0201ca6:	00003517          	auipc	a0,0x3
ffffffffc0201caa:	0e250513          	addi	a0,a0,226 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201cae:	d30fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201cb2:	00003697          	auipc	a3,0x3
ffffffffc0201cb6:	33668693          	addi	a3,a3,822 # ffffffffc0204fe8 <commands+0xe40>
ffffffffc0201cba:	00003617          	auipc	a2,0x3
ffffffffc0201cbe:	dae60613          	addi	a2,a2,-594 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201cc2:	10800593          	li	a1,264
ffffffffc0201cc6:	00003517          	auipc	a0,0x3
ffffffffc0201cca:	0c250513          	addi	a0,a0,194 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201cce:	d10fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201cd2:	00003697          	auipc	a3,0x3
ffffffffc0201cd6:	21668693          	addi	a3,a3,534 # ffffffffc0204ee8 <commands+0xd40>
ffffffffc0201cda:	00003617          	auipc	a2,0x3
ffffffffc0201cde:	d8e60613          	addi	a2,a2,-626 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201ce2:	10700593          	li	a1,263
ffffffffc0201ce6:	00003517          	auipc	a0,0x3
ffffffffc0201cea:	0a250513          	addi	a0,a0,162 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201cee:	cf0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201cf2:	00003697          	auipc	a3,0x3
ffffffffc0201cf6:	2d668693          	addi	a3,a3,726 # ffffffffc0204fc8 <commands+0xe20>
ffffffffc0201cfa:	00003617          	auipc	a2,0x3
ffffffffc0201cfe:	d6e60613          	addi	a2,a2,-658 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201d02:	10600593          	li	a1,262
ffffffffc0201d06:	00003517          	auipc	a0,0x3
ffffffffc0201d0a:	08250513          	addi	a0,a0,130 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201d0e:	cd0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d12:	00003697          	auipc	a3,0x3
ffffffffc0201d16:	28668693          	addi	a3,a3,646 # ffffffffc0204f98 <commands+0xdf0>
ffffffffc0201d1a:	00003617          	auipc	a2,0x3
ffffffffc0201d1e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201d22:	10500593          	li	a1,261
ffffffffc0201d26:	00003517          	auipc	a0,0x3
ffffffffc0201d2a:	06250513          	addi	a0,a0,98 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201d2e:	cb0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d32:	00003697          	auipc	a3,0x3
ffffffffc0201d36:	24e68693          	addi	a3,a3,590 # ffffffffc0204f80 <commands+0xdd8>
ffffffffc0201d3a:	00003617          	auipc	a2,0x3
ffffffffc0201d3e:	d2e60613          	addi	a2,a2,-722 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201d42:	10400593          	li	a1,260
ffffffffc0201d46:	00003517          	auipc	a0,0x3
ffffffffc0201d4a:	04250513          	addi	a0,a0,66 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201d4e:	c90fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201d52:	00003697          	auipc	a3,0x3
ffffffffc0201d56:	19668693          	addi	a3,a3,406 # ffffffffc0204ee8 <commands+0xd40>
ffffffffc0201d5a:	00003617          	auipc	a2,0x3
ffffffffc0201d5e:	d0e60613          	addi	a2,a2,-754 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201d62:	0fe00593          	li	a1,254
ffffffffc0201d66:	00003517          	auipc	a0,0x3
ffffffffc0201d6a:	02250513          	addi	a0,a0,34 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201d6e:	c70fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(!PageProperty(p0));
ffffffffc0201d72:	00003697          	auipc	a3,0x3
ffffffffc0201d76:	1f668693          	addi	a3,a3,502 # ffffffffc0204f68 <commands+0xdc0>
ffffffffc0201d7a:	00003617          	auipc	a2,0x3
ffffffffc0201d7e:	cee60613          	addi	a2,a2,-786 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201d82:	0f900593          	li	a1,249
ffffffffc0201d86:	00003517          	auipc	a0,0x3
ffffffffc0201d8a:	00250513          	addi	a0,a0,2 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201d8e:	c50fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201d92:	00003697          	auipc	a3,0x3
ffffffffc0201d96:	2f668693          	addi	a3,a3,758 # ffffffffc0205088 <commands+0xee0>
ffffffffc0201d9a:	00003617          	auipc	a2,0x3
ffffffffc0201d9e:	cce60613          	addi	a2,a2,-818 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201da2:	11700593          	li	a1,279
ffffffffc0201da6:	00003517          	auipc	a0,0x3
ffffffffc0201daa:	fe250513          	addi	a0,a0,-30 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201dae:	c30fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(total == 0);
ffffffffc0201db2:	00003697          	auipc	a3,0x3
ffffffffc0201db6:	30668693          	addi	a3,a3,774 # ffffffffc02050b8 <commands+0xf10>
ffffffffc0201dba:	00003617          	auipc	a2,0x3
ffffffffc0201dbe:	cae60613          	addi	a2,a2,-850 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201dc2:	12600593          	li	a1,294
ffffffffc0201dc6:	00003517          	auipc	a0,0x3
ffffffffc0201dca:	fc250513          	addi	a0,a0,-62 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201dce:	c10fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(total == nr_free_pages());
ffffffffc0201dd2:	00003697          	auipc	a3,0x3
ffffffffc0201dd6:	fce68693          	addi	a3,a3,-50 # ffffffffc0204da0 <commands+0xbf8>
ffffffffc0201dda:	00003617          	auipc	a2,0x3
ffffffffc0201dde:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201de2:	0f300593          	li	a1,243
ffffffffc0201de6:	00003517          	auipc	a0,0x3
ffffffffc0201dea:	fa250513          	addi	a0,a0,-94 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201dee:	bf0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201df2:	00003697          	auipc	a3,0x3
ffffffffc0201df6:	fee68693          	addi	a3,a3,-18 # ffffffffc0204de0 <commands+0xc38>
ffffffffc0201dfa:	00003617          	auipc	a2,0x3
ffffffffc0201dfe:	c6e60613          	addi	a2,a2,-914 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201e02:	0ba00593          	li	a1,186
ffffffffc0201e06:	00003517          	auipc	a0,0x3
ffffffffc0201e0a:	f8250513          	addi	a0,a0,-126 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201e0e:	bd0fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201e12 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201e12:	1141                	addi	sp,sp,-16
ffffffffc0201e14:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201e16:	14058463          	beqz	a1,ffffffffc0201f5e <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0201e1a:	00659693          	slli	a3,a1,0x6
ffffffffc0201e1e:	96aa                	add	a3,a3,a0
ffffffffc0201e20:	87aa                	mv	a5,a0
ffffffffc0201e22:	02d50263          	beq	a0,a3,ffffffffc0201e46 <default_free_pages+0x34>
ffffffffc0201e26:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201e28:	8b05                	andi	a4,a4,1
ffffffffc0201e2a:	10071a63          	bnez	a4,ffffffffc0201f3e <default_free_pages+0x12c>
ffffffffc0201e2e:	6798                	ld	a4,8(a5)
ffffffffc0201e30:	8b09                	andi	a4,a4,2
ffffffffc0201e32:	10071663          	bnez	a4,ffffffffc0201f3e <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201e36:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201e3a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201e3e:	04078793          	addi	a5,a5,64
ffffffffc0201e42:	fed792e3          	bne	a5,a3,ffffffffc0201e26 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201e46:	2581                	sext.w	a1,a1
ffffffffc0201e48:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201e4a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201e4e:	4789                	li	a5,2
ffffffffc0201e50:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201e54:	00007697          	auipc	a3,0x7
ffffffffc0201e58:	5dc68693          	addi	a3,a3,1500 # ffffffffc0209430 <free_area>
ffffffffc0201e5c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201e5e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201e60:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201e64:	9db9                	addw	a1,a1,a4
ffffffffc0201e66:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201e68:	0ad78463          	beq	a5,a3,ffffffffc0201f10 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0201e6c:	fe878713          	addi	a4,a5,-24
ffffffffc0201e70:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201e74:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201e76:	00e56a63          	bltu	a0,a4,ffffffffc0201e8a <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201e7a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201e7c:	04d70c63          	beq	a4,a3,ffffffffc0201ed4 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0201e80:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201e82:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201e86:	fee57ae3          	bgeu	a0,a4,ffffffffc0201e7a <default_free_pages+0x68>
ffffffffc0201e8a:	c199                	beqz	a1,ffffffffc0201e90 <default_free_pages+0x7e>
ffffffffc0201e8c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201e90:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201e92:	e390                	sd	a2,0(a5)
ffffffffc0201e94:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201e96:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201e98:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201e9a:	00d70d63          	beq	a4,a3,ffffffffc0201eb4 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201e9e:	ff872583          	lw	a1,-8(a4) # ff8 <kern_entry-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0201ea2:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201ea6:	02059813          	slli	a6,a1,0x20
ffffffffc0201eaa:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201eae:	97b2                	add	a5,a5,a2
ffffffffc0201eb0:	02f50c63          	beq	a0,a5,ffffffffc0201ee8 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201eb4:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201eb6:	00d78c63          	beq	a5,a3,ffffffffc0201ece <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201eba:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201ebc:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201ec0:	02061593          	slli	a1,a2,0x20
ffffffffc0201ec4:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201ec8:	972a                	add	a4,a4,a0
ffffffffc0201eca:	04e68a63          	beq	a3,a4,ffffffffc0201f1e <default_free_pages+0x10c>
}
ffffffffc0201ece:	60a2                	ld	ra,8(sp)
ffffffffc0201ed0:	0141                	addi	sp,sp,16
ffffffffc0201ed2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201ed4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201ed6:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201ed8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201eda:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201edc:	02d70763          	beq	a4,a3,ffffffffc0201f0a <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201ee0:	8832                	mv	a6,a2
ffffffffc0201ee2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201ee4:	87ba                	mv	a5,a4
ffffffffc0201ee6:	bf71                	j	ffffffffc0201e82 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201ee8:	491c                	lw	a5,16(a0)
ffffffffc0201eea:	9dbd                	addw	a1,a1,a5
ffffffffc0201eec:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201ef0:	57f5                	li	a5,-3
ffffffffc0201ef2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ef6:	01853803          	ld	a6,24(a0)
ffffffffc0201efa:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201efc:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201efe:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201f02:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201f04:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201f08:	b77d                	j	ffffffffc0201eb6 <default_free_pages+0xa4>
ffffffffc0201f0a:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201f0c:	873e                	mv	a4,a5
ffffffffc0201f0e:	bf41                	j	ffffffffc0201e9e <default_free_pages+0x8c>
}
ffffffffc0201f10:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201f12:	e390                	sd	a2,0(a5)
ffffffffc0201f14:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201f16:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201f18:	ed1c                	sd	a5,24(a0)
ffffffffc0201f1a:	0141                	addi	sp,sp,16
ffffffffc0201f1c:	8082                	ret
            base->property += p->property;
ffffffffc0201f1e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f22:	ff078693          	addi	a3,a5,-16
ffffffffc0201f26:	9e39                	addw	a2,a2,a4
ffffffffc0201f28:	c910                	sw	a2,16(a0)
ffffffffc0201f2a:	5775                	li	a4,-3
ffffffffc0201f2c:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201f30:	6398                	ld	a4,0(a5)
ffffffffc0201f32:	679c                	ld	a5,8(a5)
}
ffffffffc0201f34:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201f36:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201f38:	e398                	sd	a4,0(a5)
ffffffffc0201f3a:	0141                	addi	sp,sp,16
ffffffffc0201f3c:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201f3e:	00003697          	auipc	a3,0x3
ffffffffc0201f42:	19268693          	addi	a3,a3,402 # ffffffffc02050d0 <commands+0xf28>
ffffffffc0201f46:	00003617          	auipc	a2,0x3
ffffffffc0201f4a:	b2260613          	addi	a2,a2,-1246 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201f4e:	08300593          	li	a1,131
ffffffffc0201f52:	00003517          	auipc	a0,0x3
ffffffffc0201f56:	e3650513          	addi	a0,a0,-458 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201f5a:	a84fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(n > 0);
ffffffffc0201f5e:	00003697          	auipc	a3,0x3
ffffffffc0201f62:	16a68693          	addi	a3,a3,362 # ffffffffc02050c8 <commands+0xf20>
ffffffffc0201f66:	00003617          	auipc	a2,0x3
ffffffffc0201f6a:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0201f6e:	08000593          	li	a1,128
ffffffffc0201f72:	00003517          	auipc	a0,0x3
ffffffffc0201f76:	e1650513          	addi	a0,a0,-490 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc0201f7a:	a64fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201f7e <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201f7e:	c941                	beqz	a0,ffffffffc020200e <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0201f80:	00007597          	auipc	a1,0x7
ffffffffc0201f84:	4b058593          	addi	a1,a1,1200 # ffffffffc0209430 <free_area>
ffffffffc0201f88:	0105a803          	lw	a6,16(a1)
ffffffffc0201f8c:	872a                	mv	a4,a0
ffffffffc0201f8e:	02081793          	slli	a5,a6,0x20
ffffffffc0201f92:	9381                	srli	a5,a5,0x20
ffffffffc0201f94:	00a7ee63          	bltu	a5,a0,ffffffffc0201fb0 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201f98:	87ae                	mv	a5,a1
ffffffffc0201f9a:	a801                	j	ffffffffc0201faa <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201f9c:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201fa0:	02069613          	slli	a2,a3,0x20
ffffffffc0201fa4:	9201                	srli	a2,a2,0x20
ffffffffc0201fa6:	00e67763          	bgeu	a2,a4,ffffffffc0201fb4 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201faa:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201fac:	feb798e3          	bne	a5,a1,ffffffffc0201f9c <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201fb0:	4501                	li	a0,0
}
ffffffffc0201fb2:	8082                	ret
    return listelm->prev;
ffffffffc0201fb4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201fb8:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201fbc:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201fc0:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201fc4:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201fc8:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201fcc:	02c77863          	bgeu	a4,a2,ffffffffc0201ffc <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201fd0:	071a                	slli	a4,a4,0x6
ffffffffc0201fd2:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201fd4:	41c686bb          	subw	a3,a3,t3
ffffffffc0201fd8:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201fda:	00870613          	addi	a2,a4,8
ffffffffc0201fde:	4689                	li	a3,2
ffffffffc0201fe0:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201fe4:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201fe8:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201fec:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201ff0:	e290                	sd	a2,0(a3)
ffffffffc0201ff2:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201ff6:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201ff8:	01173c23          	sd	a7,24(a4)
ffffffffc0201ffc:	41c8083b          	subw	a6,a6,t3
ffffffffc0202000:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202004:	5775                	li	a4,-3
ffffffffc0202006:	17c1                	addi	a5,a5,-16
ffffffffc0202008:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020200c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020200e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202010:	00003697          	auipc	a3,0x3
ffffffffc0202014:	0b868693          	addi	a3,a3,184 # ffffffffc02050c8 <commands+0xf20>
ffffffffc0202018:	00003617          	auipc	a2,0x3
ffffffffc020201c:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202020:	06200593          	li	a1,98
ffffffffc0202024:	00003517          	auipc	a0,0x3
ffffffffc0202028:	d6450513          	addi	a0,a0,-668 # ffffffffc0204d88 <commands+0xbe0>
default_alloc_pages(size_t n) {
ffffffffc020202c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020202e:	9b0fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0202032 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202032:	1141                	addi	sp,sp,-16
ffffffffc0202034:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202036:	c5f1                	beqz	a1,ffffffffc0202102 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0202038:	00659693          	slli	a3,a1,0x6
ffffffffc020203c:	96aa                	add	a3,a3,a0
ffffffffc020203e:	87aa                	mv	a5,a0
ffffffffc0202040:	00d50f63          	beq	a0,a3,ffffffffc020205e <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202044:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202046:	8b05                	andi	a4,a4,1
ffffffffc0202048:	cf49                	beqz	a4,ffffffffc02020e2 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc020204a:	0007a823          	sw	zero,16(a5)
ffffffffc020204e:	0007b423          	sd	zero,8(a5)
ffffffffc0202052:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202056:	04078793          	addi	a5,a5,64
ffffffffc020205a:	fed795e3          	bne	a5,a3,ffffffffc0202044 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020205e:	2581                	sext.w	a1,a1
ffffffffc0202060:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202062:	4789                	li	a5,2
ffffffffc0202064:	00850713          	addi	a4,a0,8
ffffffffc0202068:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020206c:	00007697          	auipc	a3,0x7
ffffffffc0202070:	3c468693          	addi	a3,a3,964 # ffffffffc0209430 <free_area>
ffffffffc0202074:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202076:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202078:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020207c:	9db9                	addw	a1,a1,a4
ffffffffc020207e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202080:	04d78a63          	beq	a5,a3,ffffffffc02020d4 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0202084:	fe878713          	addi	a4,a5,-24
ffffffffc0202088:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020208c:	4581                	li	a1,0
            if (base < page) {
ffffffffc020208e:	00e56a63          	bltu	a0,a4,ffffffffc02020a2 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0202092:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202094:	02d70263          	beq	a4,a3,ffffffffc02020b8 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0202098:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020209a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020209e:	fee57ae3          	bgeu	a0,a4,ffffffffc0202092 <default_init_memmap+0x60>
ffffffffc02020a2:	c199                	beqz	a1,ffffffffc02020a8 <default_init_memmap+0x76>
ffffffffc02020a4:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02020a8:	6398                	ld	a4,0(a5)
}
ffffffffc02020aa:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02020ac:	e390                	sd	a2,0(a5)
ffffffffc02020ae:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02020b0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02020b2:	ed18                	sd	a4,24(a0)
ffffffffc02020b4:	0141                	addi	sp,sp,16
ffffffffc02020b6:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02020b8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02020ba:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02020bc:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02020be:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02020c0:	00d70663          	beq	a4,a3,ffffffffc02020cc <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc02020c4:	8832                	mv	a6,a2
ffffffffc02020c6:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02020c8:	87ba                	mv	a5,a4
ffffffffc02020ca:	bfc1                	j	ffffffffc020209a <default_init_memmap+0x68>
}
ffffffffc02020cc:	60a2                	ld	ra,8(sp)
ffffffffc02020ce:	e290                	sd	a2,0(a3)
ffffffffc02020d0:	0141                	addi	sp,sp,16
ffffffffc02020d2:	8082                	ret
ffffffffc02020d4:	60a2                	ld	ra,8(sp)
ffffffffc02020d6:	e390                	sd	a2,0(a5)
ffffffffc02020d8:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02020da:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02020dc:	ed1c                	sd	a5,24(a0)
ffffffffc02020de:	0141                	addi	sp,sp,16
ffffffffc02020e0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02020e2:	00003697          	auipc	a3,0x3
ffffffffc02020e6:	01668693          	addi	a3,a3,22 # ffffffffc02050f8 <commands+0xf50>
ffffffffc02020ea:	00003617          	auipc	a2,0x3
ffffffffc02020ee:	97e60613          	addi	a2,a2,-1666 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02020f2:	04900593          	li	a1,73
ffffffffc02020f6:	00003517          	auipc	a0,0x3
ffffffffc02020fa:	c9250513          	addi	a0,a0,-878 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc02020fe:	8e0fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(n > 0);
ffffffffc0202102:	00003697          	auipc	a3,0x3
ffffffffc0202106:	fc668693          	addi	a3,a3,-58 # ffffffffc02050c8 <commands+0xf20>
ffffffffc020210a:	00003617          	auipc	a2,0x3
ffffffffc020210e:	95e60613          	addi	a2,a2,-1698 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202112:	04600593          	li	a1,70
ffffffffc0202116:	00003517          	auipc	a0,0x3
ffffffffc020211a:	c7250513          	addi	a0,a0,-910 # ffffffffc0204d88 <commands+0xbe0>
ffffffffc020211e:	8c0fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0202122 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0202122:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202124:	00003617          	auipc	a2,0x3
ffffffffc0202128:	c3460613          	addi	a2,a2,-972 # ffffffffc0204d58 <commands+0xbb0>
ffffffffc020212c:	06900593          	li	a1,105
ffffffffc0202130:	00003517          	auipc	a0,0x3
ffffffffc0202134:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204cb0 <commands+0xb08>
pa2page(uintptr_t pa)
ffffffffc0202138:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020213a:	8a4fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020213e <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc020213e:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202140:	00003617          	auipc	a2,0x3
ffffffffc0202144:	01860613          	addi	a2,a2,24 # ffffffffc0205158 <default_pmm_manager+0x38>
ffffffffc0202148:	07f00593          	li	a1,127
ffffffffc020214c:	00003517          	auipc	a0,0x3
ffffffffc0202150:	b6450513          	addi	a0,a0,-1180 # ffffffffc0204cb0 <commands+0xb08>
pte2page(pte_t pte)
ffffffffc0202154:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202156:	888fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020215a <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020215a:	100027f3          	csrr	a5,sstatus
ffffffffc020215e:	8b89                	andi	a5,a5,2
ffffffffc0202160:	e799                	bnez	a5,ffffffffc020216e <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0202162:	0000b797          	auipc	a5,0xb
ffffffffc0202166:	3567b783          	ld	a5,854(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020216a:	6f9c                	ld	a5,24(a5)
ffffffffc020216c:	8782                	jr	a5
{
ffffffffc020216e:	1141                	addi	sp,sp,-16
ffffffffc0202170:	e406                	sd	ra,8(sp)
ffffffffc0202172:	e022                	sd	s0,0(sp)
ffffffffc0202174:	842a                	mv	s0,a0
        intr_disable();  // 关闭中断
ffffffffc0202176:	fc0fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020217a:	0000b797          	auipc	a5,0xb
ffffffffc020217e:	33e7b783          	ld	a5,830(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202182:	6f9c                	ld	a5,24(a5)
ffffffffc0202184:	8522                	mv	a0,s0
ffffffffc0202186:	9782                	jalr	a5
ffffffffc0202188:	842a                	mv	s0,a0
        intr_enable();   // 开启中断
ffffffffc020218a:	fa6fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020218e:	60a2                	ld	ra,8(sp)
ffffffffc0202190:	8522                	mv	a0,s0
ffffffffc0202192:	6402                	ld	s0,0(sp)
ffffffffc0202194:	0141                	addi	sp,sp,16
ffffffffc0202196:	8082                	ret

ffffffffc0202198 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202198:	100027f3          	csrr	a5,sstatus
ffffffffc020219c:	8b89                	andi	a5,a5,2
ffffffffc020219e:	e799                	bnez	a5,ffffffffc02021ac <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02021a0:	0000b797          	auipc	a5,0xb
ffffffffc02021a4:	3187b783          	ld	a5,792(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02021a8:	739c                	ld	a5,32(a5)
ffffffffc02021aa:	8782                	jr	a5
{
ffffffffc02021ac:	1101                	addi	sp,sp,-32
ffffffffc02021ae:	ec06                	sd	ra,24(sp)
ffffffffc02021b0:	e822                	sd	s0,16(sp)
ffffffffc02021b2:	e426                	sd	s1,8(sp)
ffffffffc02021b4:	842a                	mv	s0,a0
ffffffffc02021b6:	84ae                	mv	s1,a1
        intr_disable();  // 关闭中断
ffffffffc02021b8:	f7efe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02021bc:	0000b797          	auipc	a5,0xb
ffffffffc02021c0:	2fc7b783          	ld	a5,764(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02021c4:	739c                	ld	a5,32(a5)
ffffffffc02021c6:	85a6                	mv	a1,s1
ffffffffc02021c8:	8522                	mv	a0,s0
ffffffffc02021ca:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02021cc:	6442                	ld	s0,16(sp)
ffffffffc02021ce:	60e2                	ld	ra,24(sp)
ffffffffc02021d0:	64a2                	ld	s1,8(sp)
ffffffffc02021d2:	6105                	addi	sp,sp,32
        intr_enable();   // 开启中断
ffffffffc02021d4:	f5cfe06f          	j	ffffffffc0200930 <intr_enable>

ffffffffc02021d8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02021d8:	100027f3          	csrr	a5,sstatus
ffffffffc02021dc:	8b89                	andi	a5,a5,2
ffffffffc02021de:	e799                	bnez	a5,ffffffffc02021ec <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02021e0:	0000b797          	auipc	a5,0xb
ffffffffc02021e4:	2d87b783          	ld	a5,728(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02021e8:	779c                	ld	a5,40(a5)
ffffffffc02021ea:	8782                	jr	a5
{
ffffffffc02021ec:	1141                	addi	sp,sp,-16
ffffffffc02021ee:	e406                	sd	ra,8(sp)
ffffffffc02021f0:	e022                	sd	s0,0(sp)
        intr_disable();  // 关闭中断
ffffffffc02021f2:	f44fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02021f6:	0000b797          	auipc	a5,0xb
ffffffffc02021fa:	2c27b783          	ld	a5,706(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02021fe:	779c                	ld	a5,40(a5)
ffffffffc0202200:	9782                	jalr	a5
ffffffffc0202202:	842a                	mv	s0,a0
        intr_enable();   // 开启中断
ffffffffc0202204:	f2cfe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202208:	60a2                	ld	ra,8(sp)
ffffffffc020220a:	8522                	mv	a0,s0
ffffffffc020220c:	6402                	ld	s0,0(sp)
ffffffffc020220e:	0141                	addi	sp,sp,16
ffffffffc0202210:	8082                	ret

ffffffffc0202212 <get_pte>:
{
    // ============================================================================
    // 第一级页表查找：根页表 -> 中间页表 (Level 2 -> Level 1)
    // ============================================================================
    // 计算根页表中的索引：PDX1(la) 提取 VPN[2] (虚拟页号的最高9位)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202212:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202216:	1ff7f793          	andi	a5,a5,511
{
ffffffffc020221a:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020221c:	078e                	slli	a5,a5,0x3
{
ffffffffc020221e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202220:	00f504b3          	add	s1,a0,a5

    // 检查一级页表项是否有效 (PTE_V = Valid 位)
    if (!(*pdep1 & PTE_V))
ffffffffc0202224:	6094                	ld	a3,0(s1)
{
ffffffffc0202226:	f04a                	sd	s2,32(sp)
ffffffffc0202228:	ec4e                	sd	s3,24(sp)
ffffffffc020222a:	e852                	sd	s4,16(sp)
ffffffffc020222c:	fc06                	sd	ra,56(sp)
ffffffffc020222e:	f822                	sd	s0,48(sp)
ffffffffc0202230:	e456                	sd	s5,8(sp)
ffffffffc0202232:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0202234:	0016f793          	andi	a5,a3,1
{
ffffffffc0202238:	892e                	mv	s2,a1
ffffffffc020223a:	8a32                	mv	s4,a2
ffffffffc020223c:	0000b997          	auipc	s3,0xb
ffffffffc0202240:	26c98993          	addi	s3,s3,620 # ffffffffc020d4a8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0202244:	efbd                	bnez	a5,ffffffffc02022c2 <get_pte+0xb0>
        // 中间页表不存在，需要分配新的物理页作为二级页表
        // ========================================================================
        struct Page *page;

        // 检查是否允许创建页表，以及内存分配是否成功
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202246:	14060c63          	beqz	a2,ffffffffc020239e <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020224a:	100027f3          	csrr	a5,sstatus
ffffffffc020224e:	8b89                	andi	a5,a5,2
ffffffffc0202250:	14079963          	bnez	a5,ffffffffc02023a2 <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202254:	0000b797          	auipc	a5,0xb
ffffffffc0202258:	2647b783          	ld	a5,612(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020225c:	6f9c                	ld	a5,24(a5)
ffffffffc020225e:	4505                	li	a0,1
ffffffffc0202260:	9782                	jalr	a5
ffffffffc0202262:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202264:	12040d63          	beqz	s0,ffffffffc020239e <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202268:	0000bb17          	auipc	s6,0xb
ffffffffc020226c:	248b0b13          	addi	s6,s6,584 # ffffffffc020d4b0 <pages>
ffffffffc0202270:	000b3503          	ld	a0,0(s6)
ffffffffc0202274:	00080ab7          	lui	s5,0x80

        // 获取物理页的物理地址
        uintptr_t pa = page2pa(page);

        // 清空新分配的页表页：确保所有页表项初始为0 (无效)
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202278:	0000b997          	auipc	s3,0xb
ffffffffc020227c:	23098993          	addi	s3,s3,560 # ffffffffc020d4a8 <npage>
ffffffffc0202280:	40a40533          	sub	a0,s0,a0
ffffffffc0202284:	8519                	srai	a0,a0,0x6
ffffffffc0202286:	9556                	add	a0,a0,s5
ffffffffc0202288:	0009b703          	ld	a4,0(s3)
ffffffffc020228c:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202290:	4685                	li	a3,1
ffffffffc0202292:	c014                	sw	a3,0(s0)
ffffffffc0202294:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202296:	0532                	slli	a0,a0,0xc
ffffffffc0202298:	16e7f763          	bgeu	a5,a4,ffffffffc0202406 <get_pte+0x1f4>
ffffffffc020229c:	0000b797          	auipc	a5,0xb
ffffffffc02022a0:	2247b783          	ld	a5,548(a5) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc02022a4:	6605                	lui	a2,0x1
ffffffffc02022a6:	4581                	li	a1,0
ffffffffc02022a8:	953e                	add	a0,a0,a5
ffffffffc02022aa:	021010ef          	jal	ra,ffffffffc0203aca <memset>
    return page - pages + nbase;
ffffffffc02022ae:	000b3683          	ld	a3,0(s6)
ffffffffc02022b2:	40d406b3          	sub	a3,s0,a3
ffffffffc02022b6:	8699                	srai	a3,a3,0x6
ffffffffc02022b8:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02022ba:	06aa                	slli	a3,a3,0xa
ffffffffc02022bc:	0116e693          	ori	a3,a3,17

        // 创建页表项：指向新分配的页表页
        // PTE_U | PTE_V：用户可访问 + 有效位
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02022c0:	e094                	sd	a3,0(s1)
    // ============================================================================
    // 第二级页表查找：中间页表 -> 末级页表 (Level 1 -> Level 0)
    // ============================================================================
    // 从一级页表项中提取中间页表的基地址：PDE_ADDR(*pdep1)
    // 然后计算二级页表中的索引：PDX0(la) 提取 VPN[1]
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02022c2:	77fd                	lui	a5,0xfffff
ffffffffc02022c4:	068a                	slli	a3,a3,0x2
ffffffffc02022c6:	0009b703          	ld	a4,0(s3)
ffffffffc02022ca:	8efd                	and	a3,a3,a5
ffffffffc02022cc:	00c6d793          	srli	a5,a3,0xc
ffffffffc02022d0:	10e7ff63          	bgeu	a5,a4,ffffffffc02023ee <get_pte+0x1dc>
ffffffffc02022d4:	0000ba97          	auipc	s5,0xb
ffffffffc02022d8:	1eca8a93          	addi	s5,s5,492 # ffffffffc020d4c0 <va_pa_offset>
ffffffffc02022dc:	000ab403          	ld	s0,0(s5)
ffffffffc02022e0:	01595793          	srli	a5,s2,0x15
ffffffffc02022e4:	1ff7f793          	andi	a5,a5,511
ffffffffc02022e8:	96a2                	add	a3,a3,s0
ffffffffc02022ea:	00379413          	slli	s0,a5,0x3
ffffffffc02022ee:	9436                	add	s0,s0,a3

    // 检查二级页表项是否有效
    if (!(*pdep0 & PTE_V))
ffffffffc02022f0:	6014                	ld	a3,0(s0)
ffffffffc02022f2:	0016f793          	andi	a5,a3,1
ffffffffc02022f6:	ebad                	bnez	a5,ffffffffc0202368 <get_pte+0x156>
        // 末级页表不存在，需要分配新的物理页作为三级页表
        // ========================================================================
        struct Page *page;

        // 检查是否允许创建页表，以及内存分配是否成功
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02022f8:	0a0a0363          	beqz	s4,ffffffffc020239e <get_pte+0x18c>
ffffffffc02022fc:	100027f3          	csrr	a5,sstatus
ffffffffc0202300:	8b89                	andi	a5,a5,2
ffffffffc0202302:	efcd                	bnez	a5,ffffffffc02023bc <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202304:	0000b797          	auipc	a5,0xb
ffffffffc0202308:	1b47b783          	ld	a5,436(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020230c:	6f9c                	ld	a5,24(a5)
ffffffffc020230e:	4505                	li	a0,1
ffffffffc0202310:	9782                	jalr	a5
ffffffffc0202312:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202314:	c4c9                	beqz	s1,ffffffffc020239e <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202316:	0000bb17          	auipc	s6,0xb
ffffffffc020231a:	19ab0b13          	addi	s6,s6,410 # ffffffffc020d4b0 <pages>
ffffffffc020231e:	000b3503          	ld	a0,0(s6)
ffffffffc0202322:	00080a37          	lui	s4,0x80

        // 获取物理页的物理地址
        uintptr_t pa = page2pa(page);

        // 清空新分配的页表页：确保所有页表项初始为0
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202326:	0009b703          	ld	a4,0(s3)
ffffffffc020232a:	40a48533          	sub	a0,s1,a0
ffffffffc020232e:	8519                	srai	a0,a0,0x6
ffffffffc0202330:	9552                	add	a0,a0,s4
ffffffffc0202332:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202336:	4685                	li	a3,1
ffffffffc0202338:	c094                	sw	a3,0(s1)
ffffffffc020233a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020233c:	0532                	slli	a0,a0,0xc
ffffffffc020233e:	0ee7f163          	bgeu	a5,a4,ffffffffc0202420 <get_pte+0x20e>
ffffffffc0202342:	000ab783          	ld	a5,0(s5)
ffffffffc0202346:	6605                	lui	a2,0x1
ffffffffc0202348:	4581                	li	a1,0
ffffffffc020234a:	953e                	add	a0,a0,a5
ffffffffc020234c:	77e010ef          	jal	ra,ffffffffc0203aca <memset>
    return page - pages + nbase;
ffffffffc0202350:	000b3683          	ld	a3,0(s6)
ffffffffc0202354:	40d486b3          	sub	a3,s1,a3
ffffffffc0202358:	8699                	srai	a3,a3,0x6
ffffffffc020235a:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020235c:	06aa                	slli	a3,a3,0xa
ffffffffc020235e:	0116e693          	ori	a3,a3,17

        // 创建页表项：指向新分配的页表页
        // PTE_U | PTE_V：用户可访问 + 有效位
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202362:	e014                	sd	a3,0(s0)
    // 返回末级页表中的页表项地址 (Level 0 PTE)
    // ============================================================================
    // 从二级页表项中提取末级页表的基地址：PDE_ADDR(*pdep0)
    // 然后计算末级页表中的索引：PTX(la) 提取 VPN[0]
    // 返回最终页表项的内核虚拟地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202364:	0009b703          	ld	a4,0(s3)
ffffffffc0202368:	068a                	slli	a3,a3,0x2
ffffffffc020236a:	757d                	lui	a0,0xfffff
ffffffffc020236c:	8ee9                	and	a3,a3,a0
ffffffffc020236e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202372:	06e7f263          	bgeu	a5,a4,ffffffffc02023d6 <get_pte+0x1c4>
ffffffffc0202376:	000ab503          	ld	a0,0(s5)
ffffffffc020237a:	00c95913          	srli	s2,s2,0xc
ffffffffc020237e:	1ff97913          	andi	s2,s2,511
ffffffffc0202382:	96aa                	add	a3,a3,a0
ffffffffc0202384:	00391513          	slli	a0,s2,0x3
ffffffffc0202388:	9536                	add	a0,a0,a3
}
ffffffffc020238a:	70e2                	ld	ra,56(sp)
ffffffffc020238c:	7442                	ld	s0,48(sp)
ffffffffc020238e:	74a2                	ld	s1,40(sp)
ffffffffc0202390:	7902                	ld	s2,32(sp)
ffffffffc0202392:	69e2                	ld	s3,24(sp)
ffffffffc0202394:	6a42                	ld	s4,16(sp)
ffffffffc0202396:	6aa2                	ld	s5,8(sp)
ffffffffc0202398:	6b02                	ld	s6,0(sp)
ffffffffc020239a:	6121                	addi	sp,sp,64
ffffffffc020239c:	8082                	ret
            return NULL;
ffffffffc020239e:	4501                	li	a0,0
ffffffffc02023a0:	b7ed                	j	ffffffffc020238a <get_pte+0x178>
        intr_disable();  // 关闭中断
ffffffffc02023a2:	d94fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02023a6:	0000b797          	auipc	a5,0xb
ffffffffc02023aa:	1127b783          	ld	a5,274(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02023ae:	6f9c                	ld	a5,24(a5)
ffffffffc02023b0:	4505                	li	a0,1
ffffffffc02023b2:	9782                	jalr	a5
ffffffffc02023b4:	842a                	mv	s0,a0
        intr_enable();   // 开启中断
ffffffffc02023b6:	d7afe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02023ba:	b56d                	j	ffffffffc0202264 <get_pte+0x52>
        intr_disable();  // 关闭中断
ffffffffc02023bc:	d7afe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc02023c0:	0000b797          	auipc	a5,0xb
ffffffffc02023c4:	0f87b783          	ld	a5,248(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02023c8:	6f9c                	ld	a5,24(a5)
ffffffffc02023ca:	4505                	li	a0,1
ffffffffc02023cc:	9782                	jalr	a5
ffffffffc02023ce:	84aa                	mv	s1,a0
        intr_enable();   // 开启中断
ffffffffc02023d0:	d60fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02023d4:	b781                	j	ffffffffc0202314 <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02023d6:	00003617          	auipc	a2,0x3
ffffffffc02023da:	8b260613          	addi	a2,a2,-1870 # ffffffffc0204c88 <commands+0xae0>
ffffffffc02023de:	24e00593          	li	a1,590
ffffffffc02023e2:	00003517          	auipc	a0,0x3
ffffffffc02023e6:	d9e50513          	addi	a0,a0,-610 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02023ea:	df5fd0ef          	jal	ra,ffffffffc02001de <__panic>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02023ee:	00003617          	auipc	a2,0x3
ffffffffc02023f2:	89a60613          	addi	a2,a2,-1894 # ffffffffc0204c88 <commands+0xae0>
ffffffffc02023f6:	22900593          	li	a1,553
ffffffffc02023fa:	00003517          	auipc	a0,0x3
ffffffffc02023fe:	d8650513          	addi	a0,a0,-634 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202402:	dddfd0ef          	jal	ra,ffffffffc02001de <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202406:	86aa                	mv	a3,a0
ffffffffc0202408:	00003617          	auipc	a2,0x3
ffffffffc020240c:	88060613          	addi	a2,a2,-1920 # ffffffffc0204c88 <commands+0xae0>
ffffffffc0202410:	21d00593          	li	a1,541
ffffffffc0202414:	00003517          	auipc	a0,0x3
ffffffffc0202418:	d6c50513          	addi	a0,a0,-660 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020241c:	dc3fd0ef          	jal	ra,ffffffffc02001de <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202420:	86aa                	mv	a3,a0
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	86660613          	addi	a2,a2,-1946 # ffffffffc0204c88 <commands+0xae0>
ffffffffc020242a:	24100593          	li	a1,577
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	d5250513          	addi	a0,a0,-686 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202436:	da9fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020243a <get_page>:
 * - get_page(): 查找完整的映射关系，返回物理页
 *
 * 这两个函数配合使用，提供了完整的虚拟内存查询功能。
 */
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc020243a:	1141                	addi	sp,sp,-16
ffffffffc020243c:	e022                	sd	s0,0(sp)
ffffffffc020243e:	8432                	mv	s0,a2
    // ========================================================================
    // 第一步：查找页表项 (不分配新的页表)
    // ========================================================================
    // 调用get_pte()查找虚拟地址对应的页表项
    // create=0 表示只查找，不分配缺失的中间页表
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202440:	4601                	li	a2,0
{
ffffffffc0202442:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202444:	dcfff0ef          	jal	ra,ffffffffc0202212 <get_pte>
    // ========================================================================
    // 第二步：存储页表项地址（如果需要）
    // ========================================================================
    // 如果调用者提供了ptep_store指针，将页表项地址存储起来
    // 这允许调用者直接操作页表项（比如修改权限位）
    if (ptep_store != NULL)
ffffffffc0202448:	c011                	beqz	s0,ffffffffc020244c <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc020244a:	e008                	sd	a0,0(s0)

    // ========================================================================
    // 第三步：验证映射有效性并返回物理页
    // ========================================================================
    // 检查页表项是否存在且有效 (PTE_V 位为1)
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020244c:	c511                	beqz	a0,ffffffffc0202458 <get_page+0x1e>
ffffffffc020244e:	611c                	ld	a5,0(a0)
        // pte2page() 根据页表项中的PPN找到对应的Page结构体
        return pte2page(*ptep);
    }

    // 页表项不存在或无效，返回NULL表示映射不存在
    return NULL;
ffffffffc0202450:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202452:	0017f713          	andi	a4,a5,1
ffffffffc0202456:	e709                	bnez	a4,ffffffffc0202460 <get_page+0x26>
}
ffffffffc0202458:	60a2                	ld	ra,8(sp)
ffffffffc020245a:	6402                	ld	s0,0(sp)
ffffffffc020245c:	0141                	addi	sp,sp,16
ffffffffc020245e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202460:	078a                	slli	a5,a5,0x2
ffffffffc0202462:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202464:	0000b717          	auipc	a4,0xb
ffffffffc0202468:	04473703          	ld	a4,68(a4) # ffffffffc020d4a8 <npage>
ffffffffc020246c:	00e7ff63          	bgeu	a5,a4,ffffffffc020248a <get_page+0x50>
ffffffffc0202470:	60a2                	ld	ra,8(sp)
ffffffffc0202472:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0202474:	fff80537          	lui	a0,0xfff80
ffffffffc0202478:	97aa                	add	a5,a5,a0
ffffffffc020247a:	079a                	slli	a5,a5,0x6
ffffffffc020247c:	0000b517          	auipc	a0,0xb
ffffffffc0202480:	03453503          	ld	a0,52(a0) # ffffffffc020d4b0 <pages>
ffffffffc0202484:	953e                	add	a0,a0,a5
ffffffffc0202486:	0141                	addi	sp,sp,16
ffffffffc0202488:	8082                	ret
ffffffffc020248a:	c99ff0ef          	jal	ra,ffffffffc0202122 <pa2page.part.0>

ffffffffc020248e <page_remove>:
 * 2. 页面替换：页面置换算法选择牺牲页时
 * 3. 进程退出：清理进程地址空间时
 * 4. 内存整理：系统内存整理操作时
 */
void page_remove(pde_t *pgdir, uintptr_t la)
{
ffffffffc020248e:	7179                	addi	sp,sp,-48
    // ========================================================================
    // 第一步：查找页表项
    // ========================================================================
    // 调用get_pte()查找虚拟地址对应的页表项
    // create=0表示只查找，不分配新的页表
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202490:	4601                	li	a2,0
{
ffffffffc0202492:	ec26                	sd	s1,24(sp)
ffffffffc0202494:	f406                	sd	ra,40(sp)
ffffffffc0202496:	f022                	sd	s0,32(sp)
ffffffffc0202498:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020249a:	d79ff0ef          	jal	ra,ffffffffc0202212 <get_pte>
    // ========================================================================
    // 第二步：如果页表项存在，解除映射
    // ========================================================================
    // 只有当页表项存在时才需要解除映射
    // 如果地址未映射，get_pte()返回NULL，这里直接跳过
    if (ptep != NULL)
ffffffffc020249e:	c511                	beqz	a0,ffffffffc02024aa <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc02024a0:	611c                	ld	a5,0(a0)
ffffffffc02024a2:	842a                	mv	s0,a0
ffffffffc02024a4:	0017f713          	andi	a4,a5,1
ffffffffc02024a8:	e711                	bnez	a4,ffffffffc02024b4 <page_remove+0x26>

    // ========================================================================
    // 处理完成
    // ========================================================================
    // 如果页表项不存在，函数安全地不执行任何操作
}
ffffffffc02024aa:	70a2                	ld	ra,40(sp)
ffffffffc02024ac:	7402                	ld	s0,32(sp)
ffffffffc02024ae:	64e2                	ld	s1,24(sp)
ffffffffc02024b0:	6145                	addi	sp,sp,48
ffffffffc02024b2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024b4:	078a                	slli	a5,a5,0x2
ffffffffc02024b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02024b8:	0000b717          	auipc	a4,0xb
ffffffffc02024bc:	ff073703          	ld	a4,-16(a4) # ffffffffc020d4a8 <npage>
ffffffffc02024c0:	06e7f363          	bgeu	a5,a4,ffffffffc0202526 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02024c4:	fff80537          	lui	a0,0xfff80
ffffffffc02024c8:	97aa                	add	a5,a5,a0
ffffffffc02024ca:	079a                	slli	a5,a5,0x6
ffffffffc02024cc:	0000b517          	auipc	a0,0xb
ffffffffc02024d0:	fe453503          	ld	a0,-28(a0) # ffffffffc020d4b0 <pages>
ffffffffc02024d4:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02024d6:	411c                	lw	a5,0(a0)
ffffffffc02024d8:	fff7871b          	addiw	a4,a5,-1
ffffffffc02024dc:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc02024de:	cb11                	beqz	a4,ffffffffc02024f2 <page_remove+0x64>
        *ptep = 0;
ffffffffc02024e0:	00043023          	sd	zero,0(s0)
    // ========================================================================
    // 使用选择性TLB刷新指令
    // ========================================================================
    // sfence.vma la 只会刷新指定虚拟地址的TLB条目
    // 这比刷新整个TLB更高效，特别是对于单个页面操作
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024e4:	12048073          	sfence.vma	s1
}
ffffffffc02024e8:	70a2                	ld	ra,40(sp)
ffffffffc02024ea:	7402                	ld	s0,32(sp)
ffffffffc02024ec:	64e2                	ld	s1,24(sp)
ffffffffc02024ee:	6145                	addi	sp,sp,48
ffffffffc02024f0:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02024f2:	100027f3          	csrr	a5,sstatus
ffffffffc02024f6:	8b89                	andi	a5,a5,2
ffffffffc02024f8:	eb89                	bnez	a5,ffffffffc020250a <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02024fa:	0000b797          	auipc	a5,0xb
ffffffffc02024fe:	fbe7b783          	ld	a5,-66(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202502:	739c                	ld	a5,32(a5)
ffffffffc0202504:	4585                	li	a1,1
ffffffffc0202506:	9782                	jalr	a5
    if (flag) {
ffffffffc0202508:	bfe1                	j	ffffffffc02024e0 <page_remove+0x52>
        intr_disable();  // 关闭中断
ffffffffc020250a:	e42a                	sd	a0,8(sp)
ffffffffc020250c:	c2afe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202510:	0000b797          	auipc	a5,0xb
ffffffffc0202514:	fa87b783          	ld	a5,-88(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202518:	739c                	ld	a5,32(a5)
ffffffffc020251a:	6522                	ld	a0,8(sp)
ffffffffc020251c:	4585                	li	a1,1
ffffffffc020251e:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc0202520:	c10fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202524:	bf75                	j	ffffffffc02024e0 <page_remove+0x52>
ffffffffc0202526:	bfdff0ef          	jal	ra,ffffffffc0202122 <pa2page.part.0>

ffffffffc020252a <page_insert>:
{
ffffffffc020252a:	7139                	addi	sp,sp,-64
ffffffffc020252c:	e852                	sd	s4,16(sp)
ffffffffc020252e:	8a32                	mv	s4,a2
ffffffffc0202530:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202532:	4605                	li	a2,1
{
ffffffffc0202534:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202536:	85d2                	mv	a1,s4
{
ffffffffc0202538:	f426                	sd	s1,40(sp)
ffffffffc020253a:	fc06                	sd	ra,56(sp)
ffffffffc020253c:	f04a                	sd	s2,32(sp)
ffffffffc020253e:	ec4e                	sd	s3,24(sp)
ffffffffc0202540:	e456                	sd	s5,8(sp)
ffffffffc0202542:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202544:	ccfff0ef          	jal	ra,ffffffffc0202212 <get_pte>
    if (ptep == NULL)
ffffffffc0202548:	c961                	beqz	a0,ffffffffc0202618 <page_insert+0xee>
    page->ref += 1;
ffffffffc020254a:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc020254c:	611c                	ld	a5,0(a0)
ffffffffc020254e:	89aa                	mv	s3,a0
ffffffffc0202550:	0016871b          	addiw	a4,a3,1
ffffffffc0202554:	c018                	sw	a4,0(s0)
ffffffffc0202556:	0017f713          	andi	a4,a5,1
ffffffffc020255a:	ef05                	bnez	a4,ffffffffc0202592 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc020255c:	0000b717          	auipc	a4,0xb
ffffffffc0202560:	f5473703          	ld	a4,-172(a4) # ffffffffc020d4b0 <pages>
ffffffffc0202564:	8c19                	sub	s0,s0,a4
ffffffffc0202566:	000807b7          	lui	a5,0x80
ffffffffc020256a:	8419                	srai	s0,s0,0x6
ffffffffc020256c:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020256e:	042a                	slli	s0,s0,0xa
ffffffffc0202570:	8cc1                	or	s1,s1,s0
ffffffffc0202572:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202576:	0099b023          	sd	s1,0(s3)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020257a:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc020257e:	4501                	li	a0,0
}
ffffffffc0202580:	70e2                	ld	ra,56(sp)
ffffffffc0202582:	7442                	ld	s0,48(sp)
ffffffffc0202584:	74a2                	ld	s1,40(sp)
ffffffffc0202586:	7902                	ld	s2,32(sp)
ffffffffc0202588:	69e2                	ld	s3,24(sp)
ffffffffc020258a:	6a42                	ld	s4,16(sp)
ffffffffc020258c:	6aa2                	ld	s5,8(sp)
ffffffffc020258e:	6121                	addi	sp,sp,64
ffffffffc0202590:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202592:	078a                	slli	a5,a5,0x2
ffffffffc0202594:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202596:	0000b717          	auipc	a4,0xb
ffffffffc020259a:	f1273703          	ld	a4,-238(a4) # ffffffffc020d4a8 <npage>
ffffffffc020259e:	06e7ff63          	bgeu	a5,a4,ffffffffc020261c <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02025a2:	0000ba97          	auipc	s5,0xb
ffffffffc02025a6:	f0ea8a93          	addi	s5,s5,-242 # ffffffffc020d4b0 <pages>
ffffffffc02025aa:	000ab703          	ld	a4,0(s5)
ffffffffc02025ae:	fff80937          	lui	s2,0xfff80
ffffffffc02025b2:	993e                	add	s2,s2,a5
ffffffffc02025b4:	091a                	slli	s2,s2,0x6
ffffffffc02025b6:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc02025b8:	01240c63          	beq	s0,s2,ffffffffc02025d0 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02025bc:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd72b1c>
ffffffffc02025c0:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025c4:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) == 0)
ffffffffc02025c8:	c691                	beqz	a3,ffffffffc02025d4 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ca:	120a0073          	sfence.vma	s4
}
ffffffffc02025ce:	bf59                	j	ffffffffc0202564 <page_insert+0x3a>
ffffffffc02025d0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02025d2:	bf49                	j	ffffffffc0202564 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02025d4:	100027f3          	csrr	a5,sstatus
ffffffffc02025d8:	8b89                	andi	a5,a5,2
ffffffffc02025da:	ef91                	bnez	a5,ffffffffc02025f6 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02025dc:	0000b797          	auipc	a5,0xb
ffffffffc02025e0:	edc7b783          	ld	a5,-292(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02025e4:	739c                	ld	a5,32(a5)
ffffffffc02025e6:	4585                	li	a1,1
ffffffffc02025e8:	854a                	mv	a0,s2
ffffffffc02025ea:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02025ec:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025f0:	120a0073          	sfence.vma	s4
ffffffffc02025f4:	bf85                	j	ffffffffc0202564 <page_insert+0x3a>
        intr_disable();  // 关闭中断
ffffffffc02025f6:	b40fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025fa:	0000b797          	auipc	a5,0xb
ffffffffc02025fe:	ebe7b783          	ld	a5,-322(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202602:	739c                	ld	a5,32(a5)
ffffffffc0202604:	4585                	li	a1,1
ffffffffc0202606:	854a                	mv	a0,s2
ffffffffc0202608:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc020260a:	b26fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020260e:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202612:	120a0073          	sfence.vma	s4
ffffffffc0202616:	b7b9                	j	ffffffffc0202564 <page_insert+0x3a>
        return -E_NO_MEM;  // 页表分配失败，内存不足
ffffffffc0202618:	5571                	li	a0,-4
ffffffffc020261a:	b79d                	j	ffffffffc0202580 <page_insert+0x56>
ffffffffc020261c:	b07ff0ef          	jal	ra,ffffffffc0202122 <pa2page.part.0>

ffffffffc0202620 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202620:	00003797          	auipc	a5,0x3
ffffffffc0202624:	b0078793          	addi	a5,a5,-1280 # ffffffffc0205120 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202628:	638c                	ld	a1,0(a5)
{
ffffffffc020262a:	7159                	addi	sp,sp,-112
ffffffffc020262c:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020262e:	00003517          	auipc	a0,0x3
ffffffffc0202632:	b6250513          	addi	a0,a0,-1182 # ffffffffc0205190 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc0202636:	0000bb17          	auipc	s6,0xb
ffffffffc020263a:	e82b0b13          	addi	s6,s6,-382 # ffffffffc020d4b8 <pmm_manager>
{
ffffffffc020263e:	f486                	sd	ra,104(sp)
ffffffffc0202640:	e8ca                	sd	s2,80(sp)
ffffffffc0202642:	e4ce                	sd	s3,72(sp)
ffffffffc0202644:	f0a2                	sd	s0,96(sp)
ffffffffc0202646:	eca6                	sd	s1,88(sp)
ffffffffc0202648:	e0d2                	sd	s4,64(sp)
ffffffffc020264a:	fc56                	sd	s5,56(sp)
ffffffffc020264c:	f45e                	sd	s7,40(sp)
ffffffffc020264e:	f062                	sd	s8,32(sp)
ffffffffc0202650:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202652:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202656:	a8bfd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    pmm_manager->init();
ffffffffc020265a:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020265e:	0000b997          	auipc	s3,0xb
ffffffffc0202662:	e6298993          	addi	s3,s3,-414 # ffffffffc020d4c0 <va_pa_offset>
    pmm_manager->init();
ffffffffc0202666:	679c                	ld	a5,8(a5)
ffffffffc0202668:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020266a:	57f5                	li	a5,-3
ffffffffc020266c:	07fa                	slli	a5,a5,0x1e
ffffffffc020266e:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202672:	9e2fe0ef          	jal	ra,ffffffffc0200854 <get_memory_base>
ffffffffc0202676:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0202678:	9e6fe0ef          	jal	ra,ffffffffc020085e <get_memory_size>
    if (mem_size == 0) {
ffffffffc020267c:	200505e3          	beqz	a0,ffffffffc0203086 <pmm_init+0xa66>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0202680:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202682:	00003517          	auipc	a0,0x3
ffffffffc0202686:	b4650513          	addi	a0,a0,-1210 # ffffffffc02051c8 <default_pmm_manager+0xa8>
ffffffffc020268a:	a57fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020268e:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202692:	fff40693          	addi	a3,s0,-1
ffffffffc0202696:	864a                	mv	a2,s2
ffffffffc0202698:	85a6                	mv	a1,s1
ffffffffc020269a:	00003517          	auipc	a0,0x3
ffffffffc020269e:	b4650513          	addi	a0,a0,-1210 # ffffffffc02051e0 <default_pmm_manager+0xc0>
ffffffffc02026a2:	a3ffd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc02026a6:	c8000737          	lui	a4,0xc8000
ffffffffc02026aa:	87a2                	mv	a5,s0
ffffffffc02026ac:	54876163          	bltu	a4,s0,ffffffffc0202bee <pmm_init+0x5ce>
ffffffffc02026b0:	757d                	lui	a0,0xfffff
ffffffffc02026b2:	0000c617          	auipc	a2,0xc
ffffffffc02026b6:	e3160613          	addi	a2,a2,-463 # ffffffffc020e4e3 <end+0xfff>
ffffffffc02026ba:	8e69                	and	a2,a2,a0
ffffffffc02026bc:	0000b497          	auipc	s1,0xb
ffffffffc02026c0:	dec48493          	addi	s1,s1,-532 # ffffffffc020d4a8 <npage>
ffffffffc02026c4:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c8:	0000bb97          	auipc	s7,0xb
ffffffffc02026cc:	de8b8b93          	addi	s7,s7,-536 # ffffffffc020d4b0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02026d0:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026d2:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026d6:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026da:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026dc:	02f50863          	beq	a0,a5,ffffffffc020270c <pmm_init+0xec>
ffffffffc02026e0:	4781                	li	a5,0
ffffffffc02026e2:	4585                	li	a1,1
ffffffffc02026e4:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02026e8:	00679513          	slli	a0,a5,0x6
ffffffffc02026ec:	9532                	add	a0,a0,a2
ffffffffc02026ee:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fdf1b24>
ffffffffc02026f2:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026f6:	6088                	ld	a0,0(s1)
ffffffffc02026f8:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc02026fa:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026fe:	00d50733          	add	a4,a0,a3
ffffffffc0202702:	fee7e3e3          	bltu	a5,a4,ffffffffc02026e8 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202706:	071a                	slli	a4,a4,0x6
ffffffffc0202708:	00e606b3          	add	a3,a2,a4
ffffffffc020270c:	c02007b7          	lui	a5,0xc0200
ffffffffc0202710:	2ef6ece3          	bltu	a3,a5,ffffffffc0203208 <pmm_init+0xbe8>
ffffffffc0202714:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202718:	77fd                	lui	a5,0xfffff
ffffffffc020271a:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020271c:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020271e:	5086eb63          	bltu	a3,s0,ffffffffc0202c34 <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202722:	00003517          	auipc	a0,0x3
ffffffffc0202726:	ae650513          	addi	a0,a0,-1306 # ffffffffc0205208 <default_pmm_manager+0xe8>
ffffffffc020272a:	9b7fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    // 但在某些架构中可能是唯一选择
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc020272e:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;     // 虚拟地址
ffffffffc0202732:	0000b917          	auipc	s2,0xb
ffffffffc0202736:	d6e90913          	addi	s2,s2,-658 # ffffffffc020d4a0 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020273a:	7b9c                	ld	a5,48(a5)
ffffffffc020273c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020273e:	00003517          	auipc	a0,0x3
ffffffffc0202742:	ae250513          	addi	a0,a0,-1310 # ffffffffc0205220 <default_pmm_manager+0x100>
ffffffffc0202746:	99bfd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;     // 虚拟地址
ffffffffc020274a:	00006697          	auipc	a3,0x6
ffffffffc020274e:	8b668693          	addi	a3,a3,-1866 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc0202752:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);              // 物理地址
ffffffffc0202756:	c02007b7          	lui	a5,0xc0200
ffffffffc020275a:	28f6ebe3          	bltu	a3,a5,ffffffffc02031f0 <pmm_init+0xbd0>
ffffffffc020275e:	0009b783          	ld	a5,0(s3)
ffffffffc0202762:	8e9d                	sub	a3,a3,a5
ffffffffc0202764:	0000b797          	auipc	a5,0xb
ffffffffc0202768:	d2d7ba23          	sd	a3,-716(a5) # ffffffffc020d498 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020276c:	100027f3          	csrr	a5,sstatus
ffffffffc0202770:	8b89                	andi	a5,a5,2
ffffffffc0202772:	4a079763          	bnez	a5,ffffffffc0202c20 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202776:	000b3783          	ld	a5,0(s6)
ffffffffc020277a:	779c                	ld	a5,40(a5)
ffffffffc020277c:	9782                	jalr	a5
ffffffffc020277e:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202780:	6098                	ld	a4,0(s1)
ffffffffc0202782:	c80007b7          	lui	a5,0xc8000
ffffffffc0202786:	83b1                	srli	a5,a5,0xc
ffffffffc0202788:	66e7e363          	bltu	a5,a4,ffffffffc0202dee <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020278c:	00093503          	ld	a0,0(s2)
ffffffffc0202790:	62050f63          	beqz	a0,ffffffffc0202dce <pmm_init+0x7ae>
ffffffffc0202794:	03451793          	slli	a5,a0,0x34
ffffffffc0202798:	62079b63          	bnez	a5,ffffffffc0202dce <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020279c:	4601                	li	a2,0
ffffffffc020279e:	4581                	li	a1,0
ffffffffc02027a0:	c9bff0ef          	jal	ra,ffffffffc020243a <get_page>
ffffffffc02027a4:	60051563          	bnez	a0,ffffffffc0202dae <pmm_init+0x78e>
ffffffffc02027a8:	100027f3          	csrr	a5,sstatus
ffffffffc02027ac:	8b89                	andi	a5,a5,2
ffffffffc02027ae:	44079e63          	bnez	a5,ffffffffc0202c0a <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc02027b2:	000b3783          	ld	a5,0(s6)
ffffffffc02027b6:	4505                	li	a0,1
ffffffffc02027b8:	6f9c                	ld	a5,24(a5)
ffffffffc02027ba:	9782                	jalr	a5
ffffffffc02027bc:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02027be:	00093503          	ld	a0,0(s2)
ffffffffc02027c2:	4681                	li	a3,0
ffffffffc02027c4:	4601                	li	a2,0
ffffffffc02027c6:	85d2                	mv	a1,s4
ffffffffc02027c8:	d63ff0ef          	jal	ra,ffffffffc020252a <page_insert>
ffffffffc02027cc:	26051ae3          	bnez	a0,ffffffffc0203240 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02027d0:	00093503          	ld	a0,0(s2)
ffffffffc02027d4:	4601                	li	a2,0
ffffffffc02027d6:	4581                	li	a1,0
ffffffffc02027d8:	a3bff0ef          	jal	ra,ffffffffc0202212 <get_pte>
ffffffffc02027dc:	240502e3          	beqz	a0,ffffffffc0203220 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc02027e0:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc02027e2:	0017f713          	andi	a4,a5,1
ffffffffc02027e6:	5a070263          	beqz	a4,ffffffffc0202d8a <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc02027ea:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027ec:	078a                	slli	a5,a5,0x2
ffffffffc02027ee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027f0:	58e7fb63          	bgeu	a5,a4,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02027f4:	000bb683          	ld	a3,0(s7)
ffffffffc02027f8:	fff80637          	lui	a2,0xfff80
ffffffffc02027fc:	97b2                	add	a5,a5,a2
ffffffffc02027fe:	079a                	slli	a5,a5,0x6
ffffffffc0202800:	97b6                	add	a5,a5,a3
ffffffffc0202802:	14fa17e3          	bne	s4,a5,ffffffffc0203150 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc0202806:	000a2683          	lw	a3,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc020280a:	4785                	li	a5,1
ffffffffc020280c:	12f692e3          	bne	a3,a5,ffffffffc0203130 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202810:	00093503          	ld	a0,0(s2)
ffffffffc0202814:	77fd                	lui	a5,0xfffff
ffffffffc0202816:	6114                	ld	a3,0(a0)
ffffffffc0202818:	068a                	slli	a3,a3,0x2
ffffffffc020281a:	8efd                	and	a3,a3,a5
ffffffffc020281c:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202820:	0ee67ce3          	bgeu	a2,a4,ffffffffc0203118 <pmm_init+0xaf8>
ffffffffc0202824:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202828:	96e2                	add	a3,a3,s8
ffffffffc020282a:	0006ba83          	ld	s5,0(a3)
ffffffffc020282e:	0a8a                	slli	s5,s5,0x2
ffffffffc0202830:	00fafab3          	and	s5,s5,a5
ffffffffc0202834:	00cad793          	srli	a5,s5,0xc
ffffffffc0202838:	0ce7f3e3          	bgeu	a5,a4,ffffffffc02030fe <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020283c:	4601                	li	a2,0
ffffffffc020283e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202840:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202842:	9d1ff0ef          	jal	ra,ffffffffc0202212 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202846:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202848:	55551363          	bne	a0,s5,ffffffffc0202d8e <pmm_init+0x76e>
ffffffffc020284c:	100027f3          	csrr	a5,sstatus
ffffffffc0202850:	8b89                	andi	a5,a5,2
ffffffffc0202852:	3a079163          	bnez	a5,ffffffffc0202bf4 <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202856:	000b3783          	ld	a5,0(s6)
ffffffffc020285a:	4505                	li	a0,1
ffffffffc020285c:	6f9c                	ld	a5,24(a5)
ffffffffc020285e:	9782                	jalr	a5
ffffffffc0202860:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202862:	00093503          	ld	a0,0(s2)
ffffffffc0202866:	46d1                	li	a3,20
ffffffffc0202868:	6605                	lui	a2,0x1
ffffffffc020286a:	85e2                	mv	a1,s8
ffffffffc020286c:	cbfff0ef          	jal	ra,ffffffffc020252a <page_insert>
ffffffffc0202870:	060517e3          	bnez	a0,ffffffffc02030de <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202874:	00093503          	ld	a0,0(s2)
ffffffffc0202878:	4601                	li	a2,0
ffffffffc020287a:	6585                	lui	a1,0x1
ffffffffc020287c:	997ff0ef          	jal	ra,ffffffffc0202212 <get_pte>
ffffffffc0202880:	02050fe3          	beqz	a0,ffffffffc02030be <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc0202884:	611c                	ld	a5,0(a0)
ffffffffc0202886:	0107f713          	andi	a4,a5,16
ffffffffc020288a:	7c070e63          	beqz	a4,ffffffffc0203066 <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc020288e:	8b91                	andi	a5,a5,4
ffffffffc0202890:	7a078b63          	beqz	a5,ffffffffc0203046 <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202894:	00093503          	ld	a0,0(s2)
ffffffffc0202898:	611c                	ld	a5,0(a0)
ffffffffc020289a:	8bc1                	andi	a5,a5,16
ffffffffc020289c:	78078563          	beqz	a5,ffffffffc0203026 <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc02028a0:	000c2703          	lw	a4,0(s8) # ff0000 <kern_entry-0xffffffffbf210000>
ffffffffc02028a4:	4785                	li	a5,1
ffffffffc02028a6:	76f71063          	bne	a4,a5,ffffffffc0203006 <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02028aa:	4681                	li	a3,0
ffffffffc02028ac:	6605                	lui	a2,0x1
ffffffffc02028ae:	85d2                	mv	a1,s4
ffffffffc02028b0:	c7bff0ef          	jal	ra,ffffffffc020252a <page_insert>
ffffffffc02028b4:	72051963          	bnez	a0,ffffffffc0202fe6 <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc02028b8:	000a2703          	lw	a4,0(s4)
ffffffffc02028bc:	4789                	li	a5,2
ffffffffc02028be:	70f71463          	bne	a4,a5,ffffffffc0202fc6 <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc02028c2:	000c2783          	lw	a5,0(s8)
ffffffffc02028c6:	6e079063          	bnez	a5,ffffffffc0202fa6 <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02028ca:	00093503          	ld	a0,0(s2)
ffffffffc02028ce:	4601                	li	a2,0
ffffffffc02028d0:	6585                	lui	a1,0x1
ffffffffc02028d2:	941ff0ef          	jal	ra,ffffffffc0202212 <get_pte>
ffffffffc02028d6:	6a050863          	beqz	a0,ffffffffc0202f86 <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc02028da:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc02028dc:	00177793          	andi	a5,a4,1
ffffffffc02028e0:	4a078563          	beqz	a5,ffffffffc0202d8a <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc02028e4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028e6:	00271793          	slli	a5,a4,0x2
ffffffffc02028ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02028ec:	48d7fd63          	bgeu	a5,a3,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02028f0:	000bb683          	ld	a3,0(s7)
ffffffffc02028f4:	fff80ab7          	lui	s5,0xfff80
ffffffffc02028f8:	97d6                	add	a5,a5,s5
ffffffffc02028fa:	079a                	slli	a5,a5,0x6
ffffffffc02028fc:	97b6                	add	a5,a5,a3
ffffffffc02028fe:	66fa1463          	bne	s4,a5,ffffffffc0202f66 <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202902:	8b41                	andi	a4,a4,16
ffffffffc0202904:	64071163          	bnez	a4,ffffffffc0202f46 <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202908:	00093503          	ld	a0,0(s2)
ffffffffc020290c:	4581                	li	a1,0
ffffffffc020290e:	b81ff0ef          	jal	ra,ffffffffc020248e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202912:	000a2c83          	lw	s9,0(s4)
ffffffffc0202916:	4785                	li	a5,1
ffffffffc0202918:	60fc9763          	bne	s9,a5,ffffffffc0202f26 <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc020291c:	000c2783          	lw	a5,0(s8)
ffffffffc0202920:	5e079363          	bnez	a5,ffffffffc0202f06 <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202924:	00093503          	ld	a0,0(s2)
ffffffffc0202928:	6585                	lui	a1,0x1
ffffffffc020292a:	b65ff0ef          	jal	ra,ffffffffc020248e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020292e:	000a2783          	lw	a5,0(s4)
ffffffffc0202932:	52079a63          	bnez	a5,ffffffffc0202e66 <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc0202936:	000c2783          	lw	a5,0(s8)
ffffffffc020293a:	50079663          	bnez	a5,ffffffffc0202e46 <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020293e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202942:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202944:	000a3683          	ld	a3,0(s4)
ffffffffc0202948:	068a                	slli	a3,a3,0x2
ffffffffc020294a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc020294c:	42b6fd63          	bgeu	a3,a1,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202950:	000bb503          	ld	a0,0(s7)
ffffffffc0202954:	96d6                	add	a3,a3,s5
ffffffffc0202956:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202958:	00d507b3          	add	a5,a0,a3
ffffffffc020295c:	439c                	lw	a5,0(a5)
ffffffffc020295e:	4d979463          	bne	a5,s9,ffffffffc0202e26 <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc0202962:	8699                	srai	a3,a3,0x6
ffffffffc0202964:	00080637          	lui	a2,0x80
ffffffffc0202968:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc020296a:	00c69713          	slli	a4,a3,0xc
ffffffffc020296e:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202970:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202972:	48b77e63          	bgeu	a4,a1,ffffffffc0202e0e <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202976:	0009b703          	ld	a4,0(s3)
ffffffffc020297a:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc020297c:	629c                	ld	a5,0(a3)
ffffffffc020297e:	078a                	slli	a5,a5,0x2
ffffffffc0202980:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202982:	40b7f263          	bgeu	a5,a1,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202986:	8f91                	sub	a5,a5,a2
ffffffffc0202988:	079a                	slli	a5,a5,0x6
ffffffffc020298a:	953e                	add	a0,a0,a5
ffffffffc020298c:	100027f3          	csrr	a5,sstatus
ffffffffc0202990:	8b89                	andi	a5,a5,2
ffffffffc0202992:	30079963          	bnez	a5,ffffffffc0202ca4 <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc0202996:	000b3783          	ld	a5,0(s6)
ffffffffc020299a:	4585                	li	a1,1
ffffffffc020299c:	739c                	ld	a5,32(a5)
ffffffffc020299e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02029a0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02029a4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029a6:	078a                	slli	a5,a5,0x2
ffffffffc02029a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02029aa:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02029ae:	000bb503          	ld	a0,0(s7)
ffffffffc02029b2:	fff80737          	lui	a4,0xfff80
ffffffffc02029b6:	97ba                	add	a5,a5,a4
ffffffffc02029b8:	079a                	slli	a5,a5,0x6
ffffffffc02029ba:	953e                	add	a0,a0,a5
ffffffffc02029bc:	100027f3          	csrr	a5,sstatus
ffffffffc02029c0:	8b89                	andi	a5,a5,2
ffffffffc02029c2:	2c079563          	bnez	a5,ffffffffc0202c8c <pmm_init+0x66c>
ffffffffc02029c6:	000b3783          	ld	a5,0(s6)
ffffffffc02029ca:	4585                	li	a1,1
ffffffffc02029cc:	739c                	ld	a5,32(a5)
ffffffffc02029ce:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc02029d0:	00093783          	ld	a5,0(s2)
ffffffffc02029d4:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b1c>
    asm volatile("sfence.vma");
ffffffffc02029d8:	12000073          	sfence.vma
ffffffffc02029dc:	100027f3          	csrr	a5,sstatus
ffffffffc02029e0:	8b89                	andi	a5,a5,2
ffffffffc02029e2:	28079b63          	bnez	a5,ffffffffc0202c78 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029e6:	000b3783          	ld	a5,0(s6)
ffffffffc02029ea:	779c                	ld	a5,40(a5)
ffffffffc02029ec:	9782                	jalr	a5
ffffffffc02029ee:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02029f0:	4b441b63          	bne	s0,s4,ffffffffc0202ea6 <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029f4:	00003517          	auipc	a0,0x3
ffffffffc02029f8:	b5450513          	addi	a0,a0,-1196 # ffffffffc0205548 <default_pmm_manager+0x428>
ffffffffc02029fc:	ee4fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0202a00:	100027f3          	csrr	a5,sstatus
ffffffffc0202a04:	8b89                	andi	a5,a5,2
ffffffffc0202a06:	24079f63          	bnez	a5,ffffffffc0202c64 <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a0a:	000b3783          	ld	a5,0(s6)
ffffffffc0202a0e:	779c                	ld	a5,40(a5)
ffffffffc0202a10:	9782                	jalr	a5
ffffffffc0202a12:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a14:	6098                	ld	a4,0(s1)
ffffffffc0202a16:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a1a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a1c:	00c71793          	slli	a5,a4,0xc
ffffffffc0202a20:	6a05                	lui	s4,0x1
ffffffffc0202a22:	02f47c63          	bgeu	s0,a5,ffffffffc0202a5a <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202a26:	00c45793          	srli	a5,s0,0xc
ffffffffc0202a2a:	00093503          	ld	a0,0(s2)
ffffffffc0202a2e:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202d2c <pmm_init+0x70c>
ffffffffc0202a32:	0009b583          	ld	a1,0(s3)
ffffffffc0202a36:	4601                	li	a2,0
ffffffffc0202a38:	95a2                	add	a1,a1,s0
ffffffffc0202a3a:	fd8ff0ef          	jal	ra,ffffffffc0202212 <get_pte>
ffffffffc0202a3e:	32050463          	beqz	a0,ffffffffc0202d66 <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a42:	611c                	ld	a5,0(a0)
ffffffffc0202a44:	078a                	slli	a5,a5,0x2
ffffffffc0202a46:	0157f7b3          	and	a5,a5,s5
ffffffffc0202a4a:	2e879e63          	bne	a5,s0,ffffffffc0202d46 <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a4e:	6098                	ld	a4,0(s1)
ffffffffc0202a50:	9452                	add	s0,s0,s4
ffffffffc0202a52:	00c71793          	slli	a5,a4,0xc
ffffffffc0202a56:	fcf468e3          	bltu	s0,a5,ffffffffc0202a26 <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202a5a:	00093783          	ld	a5,0(s2)
ffffffffc0202a5e:	639c                	ld	a5,0(a5)
ffffffffc0202a60:	42079363          	bnez	a5,ffffffffc0202e86 <pmm_init+0x866>
ffffffffc0202a64:	100027f3          	csrr	a5,sstatus
ffffffffc0202a68:	8b89                	andi	a5,a5,2
ffffffffc0202a6a:	24079963          	bnez	a5,ffffffffc0202cbc <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a6e:	000b3783          	ld	a5,0(s6)
ffffffffc0202a72:	4505                	li	a0,1
ffffffffc0202a74:	6f9c                	ld	a5,24(a5)
ffffffffc0202a76:	9782                	jalr	a5
ffffffffc0202a78:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a7a:	00093503          	ld	a0,0(s2)
ffffffffc0202a7e:	4699                	li	a3,6
ffffffffc0202a80:	10000613          	li	a2,256
ffffffffc0202a84:	85d2                	mv	a1,s4
ffffffffc0202a86:	aa5ff0ef          	jal	ra,ffffffffc020252a <page_insert>
ffffffffc0202a8a:	44051e63          	bnez	a0,ffffffffc0202ee6 <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202a8e:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202a92:	4785                	li	a5,1
ffffffffc0202a94:	42f71963          	bne	a4,a5,ffffffffc0202ec6 <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a98:	00093503          	ld	a0,0(s2)
ffffffffc0202a9c:	6405                	lui	s0,0x1
ffffffffc0202a9e:	4699                	li	a3,6
ffffffffc0202aa0:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202aa4:	85d2                	mv	a1,s4
ffffffffc0202aa6:	a85ff0ef          	jal	ra,ffffffffc020252a <page_insert>
ffffffffc0202aaa:	72051363          	bnez	a0,ffffffffc02031d0 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202aae:	000a2703          	lw	a4,0(s4)
ffffffffc0202ab2:	4789                	li	a5,2
ffffffffc0202ab4:	6ef71e63          	bne	a4,a5,ffffffffc02031b0 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202ab8:	00003597          	auipc	a1,0x3
ffffffffc0202abc:	bd858593          	addi	a1,a1,-1064 # ffffffffc0205690 <default_pmm_manager+0x570>
ffffffffc0202ac0:	10000513          	li	a0,256
ffffffffc0202ac4:	79b000ef          	jal	ra,ffffffffc0203a5e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ac8:	10040593          	addi	a1,s0,256
ffffffffc0202acc:	10000513          	li	a0,256
ffffffffc0202ad0:	7a1000ef          	jal	ra,ffffffffc0203a70 <strcmp>
ffffffffc0202ad4:	6a051e63          	bnez	a0,ffffffffc0203190 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202ad8:	000bb683          	ld	a3,0(s7)
ffffffffc0202adc:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202ae0:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202ae2:	40da06b3          	sub	a3,s4,a3
ffffffffc0202ae6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202ae8:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202aea:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202aec:	8031                	srli	s0,s0,0xc
ffffffffc0202aee:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202af2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202af4:	30f77d63          	bgeu	a4,a5,ffffffffc0202e0e <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202af8:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202afc:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202b00:	96be                	add	a3,a3,a5
ffffffffc0202b02:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202b06:	723000ef          	jal	ra,ffffffffc0203a28 <strlen>
ffffffffc0202b0a:	66051363          	bnez	a0,ffffffffc0203170 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202b0e:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b12:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b14:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fdf1b1c>
ffffffffc0202b18:	068a                	slli	a3,a3,0x2
ffffffffc0202b1a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b1c:	26f6f563          	bgeu	a3,a5,ffffffffc0202d86 <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202b20:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b22:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202b24:	2ef47563          	bgeu	s0,a5,ffffffffc0202e0e <pmm_init+0x7ee>
ffffffffc0202b28:	0009b403          	ld	s0,0(s3)
ffffffffc0202b2c:	9436                	add	s0,s0,a3
ffffffffc0202b2e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b32:	8b89                	andi	a5,a5,2
ffffffffc0202b34:	1e079163          	bnez	a5,ffffffffc0202d16 <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202b38:	000b3783          	ld	a5,0(s6)
ffffffffc0202b3c:	4585                	li	a1,1
ffffffffc0202b3e:	8552                	mv	a0,s4
ffffffffc0202b40:	739c                	ld	a5,32(a5)
ffffffffc0202b42:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b44:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202b46:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b48:	078a                	slli	a5,a5,0x2
ffffffffc0202b4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b4c:	22e7fd63          	bgeu	a5,a4,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b50:	000bb503          	ld	a0,0(s7)
ffffffffc0202b54:	fff80737          	lui	a4,0xfff80
ffffffffc0202b58:	97ba                	add	a5,a5,a4
ffffffffc0202b5a:	079a                	slli	a5,a5,0x6
ffffffffc0202b5c:	953e                	add	a0,a0,a5
ffffffffc0202b5e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b62:	8b89                	andi	a5,a5,2
ffffffffc0202b64:	18079d63          	bnez	a5,ffffffffc0202cfe <pmm_init+0x6de>
ffffffffc0202b68:	000b3783          	ld	a5,0(s6)
ffffffffc0202b6c:	4585                	li	a1,1
ffffffffc0202b6e:	739c                	ld	a5,32(a5)
ffffffffc0202b70:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b72:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202b76:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b78:	078a                	slli	a5,a5,0x2
ffffffffc0202b7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b7c:	20e7f563          	bgeu	a5,a4,ffffffffc0202d86 <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b80:	000bb503          	ld	a0,0(s7)
ffffffffc0202b84:	fff80737          	lui	a4,0xfff80
ffffffffc0202b88:	97ba                	add	a5,a5,a4
ffffffffc0202b8a:	079a                	slli	a5,a5,0x6
ffffffffc0202b8c:	953e                	add	a0,a0,a5
ffffffffc0202b8e:	100027f3          	csrr	a5,sstatus
ffffffffc0202b92:	8b89                	andi	a5,a5,2
ffffffffc0202b94:	14079963          	bnez	a5,ffffffffc0202ce6 <pmm_init+0x6c6>
ffffffffc0202b98:	000b3783          	ld	a5,0(s6)
ffffffffc0202b9c:	4585                	li	a1,1
ffffffffc0202b9e:	739c                	ld	a5,32(a5)
ffffffffc0202ba0:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202ba2:	00093783          	ld	a5,0(s2)
ffffffffc0202ba6:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202baa:	12000073          	sfence.vma
ffffffffc0202bae:	100027f3          	csrr	a5,sstatus
ffffffffc0202bb2:	8b89                	andi	a5,a5,2
ffffffffc0202bb4:	10079f63          	bnez	a5,ffffffffc0202cd2 <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bb8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bbc:	779c                	ld	a5,40(a5)
ffffffffc0202bbe:	9782                	jalr	a5
ffffffffc0202bc0:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202bc2:	4c8c1e63          	bne	s8,s0,ffffffffc020309e <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202bc6:	00003517          	auipc	a0,0x3
ffffffffc0202bca:	b4250513          	addi	a0,a0,-1214 # ffffffffc0205708 <default_pmm_manager+0x5e8>
ffffffffc0202bce:	d12fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0202bd2:	7406                	ld	s0,96(sp)
ffffffffc0202bd4:	70a6                	ld	ra,104(sp)
ffffffffc0202bd6:	64e6                	ld	s1,88(sp)
ffffffffc0202bd8:	6946                	ld	s2,80(sp)
ffffffffc0202bda:	69a6                	ld	s3,72(sp)
ffffffffc0202bdc:	6a06                	ld	s4,64(sp)
ffffffffc0202bde:	7ae2                	ld	s5,56(sp)
ffffffffc0202be0:	7b42                	ld	s6,48(sp)
ffffffffc0202be2:	7ba2                	ld	s7,40(sp)
ffffffffc0202be4:	7c02                	ld	s8,32(sp)
ffffffffc0202be6:	6ce2                	ld	s9,24(sp)
ffffffffc0202be8:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202bea:	8c5fe06f          	j	ffffffffc02014ae <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202bee:	c80007b7          	lui	a5,0xc8000
ffffffffc0202bf2:	bc7d                	j	ffffffffc02026b0 <pmm_init+0x90>
        intr_disable();  // 关闭中断
ffffffffc0202bf4:	d43fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202bf8:	000b3783          	ld	a5,0(s6)
ffffffffc0202bfc:	4505                	li	a0,1
ffffffffc0202bfe:	6f9c                	ld	a5,24(a5)
ffffffffc0202c00:	9782                	jalr	a5
ffffffffc0202c02:	8c2a                	mv	s8,a0
        intr_enable();   // 开启中断
ffffffffc0202c04:	d2dfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c08:	b9a9                	j	ffffffffc0202862 <pmm_init+0x242>
        intr_disable();  // 关闭中断
ffffffffc0202c0a:	d2dfd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202c0e:	000b3783          	ld	a5,0(s6)
ffffffffc0202c12:	4505                	li	a0,1
ffffffffc0202c14:	6f9c                	ld	a5,24(a5)
ffffffffc0202c16:	9782                	jalr	a5
ffffffffc0202c18:	8a2a                	mv	s4,a0
        intr_enable();   // 开启中断
ffffffffc0202c1a:	d17fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c1e:	b645                	j	ffffffffc02027be <pmm_init+0x19e>
        intr_disable();  // 关闭中断
ffffffffc0202c20:	d17fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c24:	000b3783          	ld	a5,0(s6)
ffffffffc0202c28:	779c                	ld	a5,40(a5)
ffffffffc0202c2a:	9782                	jalr	a5
ffffffffc0202c2c:	842a                	mv	s0,a0
        intr_enable();   // 开启中断
ffffffffc0202c2e:	d03fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c32:	b6b9                	j	ffffffffc0202780 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c34:	6705                	lui	a4,0x1
ffffffffc0202c36:	177d                	addi	a4,a4,-1
ffffffffc0202c38:	96ba                	add	a3,a3,a4
ffffffffc0202c3a:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202c3c:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202c40:	14a77363          	bgeu	a4,a0,ffffffffc0202d86 <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202c44:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202c48:	fff80537          	lui	a0,0xfff80
ffffffffc0202c4c:	972a                	add	a4,a4,a0
ffffffffc0202c4e:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c50:	8c1d                	sub	s0,s0,a5
ffffffffc0202c52:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202c56:	00c45593          	srli	a1,s0,0xc
ffffffffc0202c5a:	9532                	add	a0,a0,a2
ffffffffc0202c5c:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202c5e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202c62:	b4c1                	j	ffffffffc0202722 <pmm_init+0x102>
        intr_disable();  // 关闭中断
ffffffffc0202c64:	cd3fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c68:	000b3783          	ld	a5,0(s6)
ffffffffc0202c6c:	779c                	ld	a5,40(a5)
ffffffffc0202c6e:	9782                	jalr	a5
ffffffffc0202c70:	8c2a                	mv	s8,a0
        intr_enable();   // 开启中断
ffffffffc0202c72:	cbffd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c76:	bb79                	j	ffffffffc0202a14 <pmm_init+0x3f4>
        intr_disable();  // 关闭中断
ffffffffc0202c78:	cbffd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202c7c:	000b3783          	ld	a5,0(s6)
ffffffffc0202c80:	779c                	ld	a5,40(a5)
ffffffffc0202c82:	9782                	jalr	a5
ffffffffc0202c84:	8a2a                	mv	s4,a0
        intr_enable();   // 开启中断
ffffffffc0202c86:	cabfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c8a:	b39d                	j	ffffffffc02029f0 <pmm_init+0x3d0>
ffffffffc0202c8c:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc0202c8e:	ca9fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202c92:	000b3783          	ld	a5,0(s6)
ffffffffc0202c96:	6522                	ld	a0,8(sp)
ffffffffc0202c98:	4585                	li	a1,1
ffffffffc0202c9a:	739c                	ld	a5,32(a5)
ffffffffc0202c9c:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc0202c9e:	c93fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202ca2:	b33d                	j	ffffffffc02029d0 <pmm_init+0x3b0>
ffffffffc0202ca4:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc0202ca6:	c91fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202caa:	000b3783          	ld	a5,0(s6)
ffffffffc0202cae:	6522                	ld	a0,8(sp)
ffffffffc0202cb0:	4585                	li	a1,1
ffffffffc0202cb2:	739c                	ld	a5,32(a5)
ffffffffc0202cb4:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc0202cb6:	c7bfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202cba:	b1dd                	j	ffffffffc02029a0 <pmm_init+0x380>
        intr_disable();  // 关闭中断
ffffffffc0202cbc:	c7bfd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202cc0:	000b3783          	ld	a5,0(s6)
ffffffffc0202cc4:	4505                	li	a0,1
ffffffffc0202cc6:	6f9c                	ld	a5,24(a5)
ffffffffc0202cc8:	9782                	jalr	a5
ffffffffc0202cca:	8a2a                	mv	s4,a0
        intr_enable();   // 开启中断
ffffffffc0202ccc:	c65fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202cd0:	b36d                	j	ffffffffc0202a7a <pmm_init+0x45a>
        intr_disable();  // 关闭中断
ffffffffc0202cd2:	c65fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202cd6:	000b3783          	ld	a5,0(s6)
ffffffffc0202cda:	779c                	ld	a5,40(a5)
ffffffffc0202cdc:	9782                	jalr	a5
ffffffffc0202cde:	842a                	mv	s0,a0
        intr_enable();   // 开启中断
ffffffffc0202ce0:	c51fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202ce4:	bdf9                	j	ffffffffc0202bc2 <pmm_init+0x5a2>
ffffffffc0202ce6:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc0202ce8:	c4ffd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202cec:	000b3783          	ld	a5,0(s6)
ffffffffc0202cf0:	6522                	ld	a0,8(sp)
ffffffffc0202cf2:	4585                	li	a1,1
ffffffffc0202cf4:	739c                	ld	a5,32(a5)
ffffffffc0202cf6:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc0202cf8:	c39fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202cfc:	b55d                	j	ffffffffc0202ba2 <pmm_init+0x582>
ffffffffc0202cfe:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc0202d00:	c37fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202d04:	000b3783          	ld	a5,0(s6)
ffffffffc0202d08:	6522                	ld	a0,8(sp)
ffffffffc0202d0a:	4585                	li	a1,1
ffffffffc0202d0c:	739c                	ld	a5,32(a5)
ffffffffc0202d0e:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc0202d10:	c21fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202d14:	bdb9                	j	ffffffffc0202b72 <pmm_init+0x552>
        intr_disable();  // 关闭中断
ffffffffc0202d16:	c21fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202d1a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d1e:	4585                	li	a1,1
ffffffffc0202d20:	8552                	mv	a0,s4
ffffffffc0202d22:	739c                	ld	a5,32(a5)
ffffffffc0202d24:	9782                	jalr	a5
        intr_enable();   // 开启中断
ffffffffc0202d26:	c0bfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202d2a:	bd29                	j	ffffffffc0202b44 <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d2c:	86a2                	mv	a3,s0
ffffffffc0202d2e:	00002617          	auipc	a2,0x2
ffffffffc0202d32:	f5a60613          	addi	a2,a2,-166 # ffffffffc0204c88 <commands+0xae0>
ffffffffc0202d36:	4fb00593          	li	a1,1275
ffffffffc0202d3a:	00002517          	auipc	a0,0x2
ffffffffc0202d3e:	44650513          	addi	a0,a0,1094 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202d42:	c9cfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d46:	00003697          	auipc	a3,0x3
ffffffffc0202d4a:	86268693          	addi	a3,a3,-1950 # ffffffffc02055a8 <default_pmm_manager+0x488>
ffffffffc0202d4e:	00002617          	auipc	a2,0x2
ffffffffc0202d52:	d1a60613          	addi	a2,a2,-742 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202d56:	4fc00593          	li	a1,1276
ffffffffc0202d5a:	00002517          	auipc	a0,0x2
ffffffffc0202d5e:	42650513          	addi	a0,a0,1062 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202d62:	c7cfd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d66:	00003697          	auipc	a3,0x3
ffffffffc0202d6a:	80268693          	addi	a3,a3,-2046 # ffffffffc0205568 <default_pmm_manager+0x448>
ffffffffc0202d6e:	00002617          	auipc	a2,0x2
ffffffffc0202d72:	cfa60613          	addi	a2,a2,-774 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202d76:	4fb00593          	li	a1,1275
ffffffffc0202d7a:	00002517          	auipc	a0,0x2
ffffffffc0202d7e:	40650513          	addi	a0,a0,1030 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202d82:	c5cfd0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc0202d86:	b9cff0ef          	jal	ra,ffffffffc0202122 <pa2page.part.0>
ffffffffc0202d8a:	bb4ff0ef          	jal	ra,ffffffffc020213e <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202d8e:	00002697          	auipc	a3,0x2
ffffffffc0202d92:	5d268693          	addi	a3,a3,1490 # ffffffffc0205360 <default_pmm_manager+0x240>
ffffffffc0202d96:	00002617          	auipc	a2,0x2
ffffffffc0202d9a:	cd260613          	addi	a2,a2,-814 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202d9e:	4cb00593          	li	a1,1227
ffffffffc0202da2:	00002517          	auipc	a0,0x2
ffffffffc0202da6:	3de50513          	addi	a0,a0,990 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202daa:	c34fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202dae:	00002697          	auipc	a3,0x2
ffffffffc0202db2:	4f268693          	addi	a3,a3,1266 # ffffffffc02052a0 <default_pmm_manager+0x180>
ffffffffc0202db6:	00002617          	auipc	a2,0x2
ffffffffc0202dba:	cb260613          	addi	a2,a2,-846 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202dbe:	4be00593          	li	a1,1214
ffffffffc0202dc2:	00002517          	auipc	a0,0x2
ffffffffc0202dc6:	3be50513          	addi	a0,a0,958 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202dca:	c14fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202dce:	00002697          	auipc	a3,0x2
ffffffffc0202dd2:	49268693          	addi	a3,a3,1170 # ffffffffc0205260 <default_pmm_manager+0x140>
ffffffffc0202dd6:	00002617          	auipc	a2,0x2
ffffffffc0202dda:	c9260613          	addi	a2,a2,-878 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202dde:	4bd00593          	li	a1,1213
ffffffffc0202de2:	00002517          	auipc	a0,0x2
ffffffffc0202de6:	39e50513          	addi	a0,a0,926 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202dea:	bf4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202dee:	00002697          	auipc	a3,0x2
ffffffffc0202df2:	45268693          	addi	a3,a3,1106 # ffffffffc0205240 <default_pmm_manager+0x120>
ffffffffc0202df6:	00002617          	auipc	a2,0x2
ffffffffc0202dfa:	c7260613          	addi	a2,a2,-910 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202dfe:	4bc00593          	li	a1,1212
ffffffffc0202e02:	00002517          	auipc	a0,0x2
ffffffffc0202e06:	37e50513          	addi	a0,a0,894 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202e0a:	bd4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    return KADDR(page2pa(page));
ffffffffc0202e0e:	00002617          	auipc	a2,0x2
ffffffffc0202e12:	e7a60613          	addi	a2,a2,-390 # ffffffffc0204c88 <commands+0xae0>
ffffffffc0202e16:	07100593          	li	a1,113
ffffffffc0202e1a:	00002517          	auipc	a0,0x2
ffffffffc0202e1e:	e9650513          	addi	a0,a0,-362 # ffffffffc0204cb0 <commands+0xb08>
ffffffffc0202e22:	bbcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202e26:	00002697          	auipc	a3,0x2
ffffffffc0202e2a:	6ca68693          	addi	a3,a3,1738 # ffffffffc02054f0 <default_pmm_manager+0x3d0>
ffffffffc0202e2e:	00002617          	auipc	a2,0x2
ffffffffc0202e32:	c3a60613          	addi	a2,a2,-966 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202e36:	4e400593          	li	a1,1252
ffffffffc0202e3a:	00002517          	auipc	a0,0x2
ffffffffc0202e3e:	34650513          	addi	a0,a0,838 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202e42:	b9cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e46:	00002697          	auipc	a3,0x2
ffffffffc0202e4a:	66268693          	addi	a3,a3,1634 # ffffffffc02054a8 <default_pmm_manager+0x388>
ffffffffc0202e4e:	00002617          	auipc	a2,0x2
ffffffffc0202e52:	c1a60613          	addi	a2,a2,-998 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202e56:	4e200593          	li	a1,1250
ffffffffc0202e5a:	00002517          	auipc	a0,0x2
ffffffffc0202e5e:	32650513          	addi	a0,a0,806 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202e62:	b7cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e66:	00002697          	auipc	a3,0x2
ffffffffc0202e6a:	67268693          	addi	a3,a3,1650 # ffffffffc02054d8 <default_pmm_manager+0x3b8>
ffffffffc0202e6e:	00002617          	auipc	a2,0x2
ffffffffc0202e72:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202e76:	4e100593          	li	a1,1249
ffffffffc0202e7a:	00002517          	auipc	a0,0x2
ffffffffc0202e7e:	30650513          	addi	a0,a0,774 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202e82:	b5cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202e86:	00002697          	auipc	a3,0x2
ffffffffc0202e8a:	73a68693          	addi	a3,a3,1850 # ffffffffc02055c0 <default_pmm_manager+0x4a0>
ffffffffc0202e8e:	00002617          	auipc	a2,0x2
ffffffffc0202e92:	bda60613          	addi	a2,a2,-1062 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202e96:	4ff00593          	li	a1,1279
ffffffffc0202e9a:	00002517          	auipc	a0,0x2
ffffffffc0202e9e:	2e650513          	addi	a0,a0,742 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202ea2:	b3cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202ea6:	00002697          	auipc	a3,0x2
ffffffffc0202eaa:	67a68693          	addi	a3,a3,1658 # ffffffffc0205520 <default_pmm_manager+0x400>
ffffffffc0202eae:	00002617          	auipc	a2,0x2
ffffffffc0202eb2:	bba60613          	addi	a2,a2,-1094 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202eb6:	4ec00593          	li	a1,1260
ffffffffc0202eba:	00002517          	auipc	a0,0x2
ffffffffc0202ebe:	2c650513          	addi	a0,a0,710 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202ec2:	b1cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202ec6:	00002697          	auipc	a3,0x2
ffffffffc0202eca:	75268693          	addi	a3,a3,1874 # ffffffffc0205618 <default_pmm_manager+0x4f8>
ffffffffc0202ece:	00002617          	auipc	a2,0x2
ffffffffc0202ed2:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202ed6:	50400593          	li	a1,1284
ffffffffc0202eda:	00002517          	auipc	a0,0x2
ffffffffc0202ede:	2a650513          	addi	a0,a0,678 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202ee2:	afcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202ee6:	00002697          	auipc	a3,0x2
ffffffffc0202eea:	6f268693          	addi	a3,a3,1778 # ffffffffc02055d8 <default_pmm_manager+0x4b8>
ffffffffc0202eee:	00002617          	auipc	a2,0x2
ffffffffc0202ef2:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202ef6:	50300593          	li	a1,1283
ffffffffc0202efa:	00002517          	auipc	a0,0x2
ffffffffc0202efe:	28650513          	addi	a0,a0,646 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202f02:	adcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f06:	00002697          	auipc	a3,0x2
ffffffffc0202f0a:	5a268693          	addi	a3,a3,1442 # ffffffffc02054a8 <default_pmm_manager+0x388>
ffffffffc0202f0e:	00002617          	auipc	a2,0x2
ffffffffc0202f12:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202f16:	4de00593          	li	a1,1246
ffffffffc0202f1a:	00002517          	auipc	a0,0x2
ffffffffc0202f1e:	26650513          	addi	a0,a0,614 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202f22:	abcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f26:	00002697          	auipc	a3,0x2
ffffffffc0202f2a:	42268693          	addi	a3,a3,1058 # ffffffffc0205348 <default_pmm_manager+0x228>
ffffffffc0202f2e:	00002617          	auipc	a2,0x2
ffffffffc0202f32:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202f36:	4dd00593          	li	a1,1245
ffffffffc0202f3a:	00002517          	auipc	a0,0x2
ffffffffc0202f3e:	24650513          	addi	a0,a0,582 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202f42:	a9cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202f46:	00002697          	auipc	a3,0x2
ffffffffc0202f4a:	57a68693          	addi	a3,a3,1402 # ffffffffc02054c0 <default_pmm_manager+0x3a0>
ffffffffc0202f4e:	00002617          	auipc	a2,0x2
ffffffffc0202f52:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202f56:	4da00593          	li	a1,1242
ffffffffc0202f5a:	00002517          	auipc	a0,0x2
ffffffffc0202f5e:	22650513          	addi	a0,a0,550 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202f62:	a7cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f66:	00002697          	auipc	a3,0x2
ffffffffc0202f6a:	3ca68693          	addi	a3,a3,970 # ffffffffc0205330 <default_pmm_manager+0x210>
ffffffffc0202f6e:	00002617          	auipc	a2,0x2
ffffffffc0202f72:	afa60613          	addi	a2,a2,-1286 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202f76:	4d900593          	li	a1,1241
ffffffffc0202f7a:	00002517          	auipc	a0,0x2
ffffffffc0202f7e:	20650513          	addi	a0,a0,518 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202f82:	a5cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202f86:	00002697          	auipc	a3,0x2
ffffffffc0202f8a:	44a68693          	addi	a3,a3,1098 # ffffffffc02053d0 <default_pmm_manager+0x2b0>
ffffffffc0202f8e:	00002617          	auipc	a2,0x2
ffffffffc0202f92:	ada60613          	addi	a2,a2,-1318 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202f96:	4d800593          	li	a1,1240
ffffffffc0202f9a:	00002517          	auipc	a0,0x2
ffffffffc0202f9e:	1e650513          	addi	a0,a0,486 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202fa2:	a3cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fa6:	00002697          	auipc	a3,0x2
ffffffffc0202faa:	50268693          	addi	a3,a3,1282 # ffffffffc02054a8 <default_pmm_manager+0x388>
ffffffffc0202fae:	00002617          	auipc	a2,0x2
ffffffffc0202fb2:	aba60613          	addi	a2,a2,-1350 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202fb6:	4d700593          	li	a1,1239
ffffffffc0202fba:	00002517          	auipc	a0,0x2
ffffffffc0202fbe:	1c650513          	addi	a0,a0,454 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202fc2:	a1cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202fc6:	00002697          	auipc	a3,0x2
ffffffffc0202fca:	4ca68693          	addi	a3,a3,1226 # ffffffffc0205490 <default_pmm_manager+0x370>
ffffffffc0202fce:	00002617          	auipc	a2,0x2
ffffffffc0202fd2:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202fd6:	4d600593          	li	a1,1238
ffffffffc0202fda:	00002517          	auipc	a0,0x2
ffffffffc0202fde:	1a650513          	addi	a0,a0,422 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0202fe2:	9fcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202fe6:	00002697          	auipc	a3,0x2
ffffffffc0202fea:	47a68693          	addi	a3,a3,1146 # ffffffffc0205460 <default_pmm_manager+0x340>
ffffffffc0202fee:	00002617          	auipc	a2,0x2
ffffffffc0202ff2:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0202ff6:	4d500593          	li	a1,1237
ffffffffc0202ffa:	00002517          	auipc	a0,0x2
ffffffffc0202ffe:	18650513          	addi	a0,a0,390 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203002:	9dcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203006:	00002697          	auipc	a3,0x2
ffffffffc020300a:	44268693          	addi	a3,a3,1090 # ffffffffc0205448 <default_pmm_manager+0x328>
ffffffffc020300e:	00002617          	auipc	a2,0x2
ffffffffc0203012:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203016:	4d300593          	li	a1,1235
ffffffffc020301a:	00002517          	auipc	a0,0x2
ffffffffc020301e:	16650513          	addi	a0,a0,358 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203022:	9bcfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203026:	00002697          	auipc	a3,0x2
ffffffffc020302a:	40268693          	addi	a3,a3,1026 # ffffffffc0205428 <default_pmm_manager+0x308>
ffffffffc020302e:	00002617          	auipc	a2,0x2
ffffffffc0203032:	a3a60613          	addi	a2,a2,-1478 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203036:	4d200593          	li	a1,1234
ffffffffc020303a:	00002517          	auipc	a0,0x2
ffffffffc020303e:	14650513          	addi	a0,a0,326 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203042:	99cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203046:	00002697          	auipc	a3,0x2
ffffffffc020304a:	3d268693          	addi	a3,a3,978 # ffffffffc0205418 <default_pmm_manager+0x2f8>
ffffffffc020304e:	00002617          	auipc	a2,0x2
ffffffffc0203052:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203056:	4d100593          	li	a1,1233
ffffffffc020305a:	00002517          	auipc	a0,0x2
ffffffffc020305e:	12650513          	addi	a0,a0,294 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203062:	97cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203066:	00002697          	auipc	a3,0x2
ffffffffc020306a:	3a268693          	addi	a3,a3,930 # ffffffffc0205408 <default_pmm_manager+0x2e8>
ffffffffc020306e:	00002617          	auipc	a2,0x2
ffffffffc0203072:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203076:	4d000593          	li	a1,1232
ffffffffc020307a:	00002517          	auipc	a0,0x2
ffffffffc020307e:	10650513          	addi	a0,a0,262 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203082:	95cfd0ef          	jal	ra,ffffffffc02001de <__panic>
        panic("DTB memory info not available");
ffffffffc0203086:	00002617          	auipc	a2,0x2
ffffffffc020308a:	12260613          	addi	a2,a2,290 # ffffffffc02051a8 <default_pmm_manager+0x88>
ffffffffc020308e:	06400593          	li	a1,100
ffffffffc0203092:	00002517          	auipc	a0,0x2
ffffffffc0203096:	0ee50513          	addi	a0,a0,238 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020309a:	944fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020309e:	00002697          	auipc	a3,0x2
ffffffffc02030a2:	48268693          	addi	a3,a3,1154 # ffffffffc0205520 <default_pmm_manager+0x400>
ffffffffc02030a6:	00002617          	auipc	a2,0x2
ffffffffc02030aa:	9c260613          	addi	a2,a2,-1598 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02030ae:	51600593          	li	a1,1302
ffffffffc02030b2:	00002517          	auipc	a0,0x2
ffffffffc02030b6:	0ce50513          	addi	a0,a0,206 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02030ba:	924fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02030be:	00002697          	auipc	a3,0x2
ffffffffc02030c2:	31268693          	addi	a3,a3,786 # ffffffffc02053d0 <default_pmm_manager+0x2b0>
ffffffffc02030c6:	00002617          	auipc	a2,0x2
ffffffffc02030ca:	9a260613          	addi	a2,a2,-1630 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02030ce:	4cf00593          	li	a1,1231
ffffffffc02030d2:	00002517          	auipc	a0,0x2
ffffffffc02030d6:	0ae50513          	addi	a0,a0,174 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02030da:	904fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02030de:	00002697          	auipc	a3,0x2
ffffffffc02030e2:	2b268693          	addi	a3,a3,690 # ffffffffc0205390 <default_pmm_manager+0x270>
ffffffffc02030e6:	00002617          	auipc	a2,0x2
ffffffffc02030ea:	98260613          	addi	a2,a2,-1662 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02030ee:	4ce00593          	li	a1,1230
ffffffffc02030f2:	00002517          	auipc	a0,0x2
ffffffffc02030f6:	08e50513          	addi	a0,a0,142 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02030fa:	8e4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030fe:	86d6                	mv	a3,s5
ffffffffc0203100:	00002617          	auipc	a2,0x2
ffffffffc0203104:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204c88 <commands+0xae0>
ffffffffc0203108:	4ca00593          	li	a1,1226
ffffffffc020310c:	00002517          	auipc	a0,0x2
ffffffffc0203110:	07450513          	addi	a0,a0,116 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203114:	8cafd0ef          	jal	ra,ffffffffc02001de <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203118:	00002617          	auipc	a2,0x2
ffffffffc020311c:	b7060613          	addi	a2,a2,-1168 # ffffffffc0204c88 <commands+0xae0>
ffffffffc0203120:	4c900593          	li	a1,1225
ffffffffc0203124:	00002517          	auipc	a0,0x2
ffffffffc0203128:	05c50513          	addi	a0,a0,92 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020312c:	8b2fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203130:	00002697          	auipc	a3,0x2
ffffffffc0203134:	21868693          	addi	a3,a3,536 # ffffffffc0205348 <default_pmm_manager+0x228>
ffffffffc0203138:	00002617          	auipc	a2,0x2
ffffffffc020313c:	93060613          	addi	a2,a2,-1744 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203140:	4c700593          	li	a1,1223
ffffffffc0203144:	00002517          	auipc	a0,0x2
ffffffffc0203148:	03c50513          	addi	a0,a0,60 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020314c:	892fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203150:	00002697          	auipc	a3,0x2
ffffffffc0203154:	1e068693          	addi	a3,a3,480 # ffffffffc0205330 <default_pmm_manager+0x210>
ffffffffc0203158:	00002617          	auipc	a2,0x2
ffffffffc020315c:	91060613          	addi	a2,a2,-1776 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203160:	4c600593          	li	a1,1222
ffffffffc0203164:	00002517          	auipc	a0,0x2
ffffffffc0203168:	01c50513          	addi	a0,a0,28 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020316c:	872fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203170:	00002697          	auipc	a3,0x2
ffffffffc0203174:	57068693          	addi	a3,a3,1392 # ffffffffc02056e0 <default_pmm_manager+0x5c0>
ffffffffc0203178:	00002617          	auipc	a2,0x2
ffffffffc020317c:	8f060613          	addi	a2,a2,-1808 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203180:	50d00593          	li	a1,1293
ffffffffc0203184:	00002517          	auipc	a0,0x2
ffffffffc0203188:	ffc50513          	addi	a0,a0,-4 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020318c:	852fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203190:	00002697          	auipc	a3,0x2
ffffffffc0203194:	51868693          	addi	a3,a3,1304 # ffffffffc02056a8 <default_pmm_manager+0x588>
ffffffffc0203198:	00002617          	auipc	a2,0x2
ffffffffc020319c:	8d060613          	addi	a2,a2,-1840 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02031a0:	50a00593          	li	a1,1290
ffffffffc02031a4:	00002517          	auipc	a0,0x2
ffffffffc02031a8:	fdc50513          	addi	a0,a0,-36 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02031ac:	832fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p) == 2);
ffffffffc02031b0:	00002697          	auipc	a3,0x2
ffffffffc02031b4:	4c868693          	addi	a3,a3,1224 # ffffffffc0205678 <default_pmm_manager+0x558>
ffffffffc02031b8:	00002617          	auipc	a2,0x2
ffffffffc02031bc:	8b060613          	addi	a2,a2,-1872 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02031c0:	50600593          	li	a1,1286
ffffffffc02031c4:	00002517          	auipc	a0,0x2
ffffffffc02031c8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02031cc:	812fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02031d0:	00002697          	auipc	a3,0x2
ffffffffc02031d4:	46068693          	addi	a3,a3,1120 # ffffffffc0205630 <default_pmm_manager+0x510>
ffffffffc02031d8:	00002617          	auipc	a2,0x2
ffffffffc02031dc:	89060613          	addi	a2,a2,-1904 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc02031e0:	50500593          	li	a1,1285
ffffffffc02031e4:	00002517          	auipc	a0,0x2
ffffffffc02031e8:	f9c50513          	addi	a0,a0,-100 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc02031ec:	ff3fc0ef          	jal	ra,ffffffffc02001de <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);              // 物理地址
ffffffffc02031f0:	00002617          	auipc	a2,0x2
ffffffffc02031f4:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204d30 <commands+0xb88>
ffffffffc02031f8:	17c00593          	li	a1,380
ffffffffc02031fc:	00002517          	auipc	a0,0x2
ffffffffc0203200:	f8450513          	addi	a0,a0,-124 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc0203204:	fdbfc0ef          	jal	ra,ffffffffc02001de <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203208:	00002617          	auipc	a2,0x2
ffffffffc020320c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204d30 <commands+0xb88>
ffffffffc0203210:	08000593          	li	a1,128
ffffffffc0203214:	00002517          	auipc	a0,0x2
ffffffffc0203218:	f6c50513          	addi	a0,a0,-148 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020321c:	fc3fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203220:	00002697          	auipc	a3,0x2
ffffffffc0203224:	0e068693          	addi	a3,a3,224 # ffffffffc0205300 <default_pmm_manager+0x1e0>
ffffffffc0203228:	00002617          	auipc	a2,0x2
ffffffffc020322c:	84060613          	addi	a2,a2,-1984 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203230:	4c500593          	li	a1,1221
ffffffffc0203234:	00002517          	auipc	a0,0x2
ffffffffc0203238:	f4c50513          	addi	a0,a0,-180 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020323c:	fa3fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203240:	00002697          	auipc	a3,0x2
ffffffffc0203244:	09068693          	addi	a3,a3,144 # ffffffffc02052d0 <default_pmm_manager+0x1b0>
ffffffffc0203248:	00002617          	auipc	a2,0x2
ffffffffc020324c:	82060613          	addi	a2,a2,-2016 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203250:	4c200593          	li	a1,1218
ffffffffc0203254:	00002517          	auipc	a0,0x2
ffffffffc0203258:	f2c50513          	addi	a0,a0,-212 # ffffffffc0205180 <default_pmm_manager+0x60>
ffffffffc020325c:	f83fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203260 <kernel_thread_entry>:
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

	# ========== 设置函数参数 ==========
	# 将s1寄存器中的参数移动到a0（第一个参数寄存器）
	move a0, s1
ffffffffc0203260:	8526                	mv	a0,s1

	# ========== 调用线程函数 ==========
	# 跳转到s0寄存器中保存的函数地址
	# jalr指令会将返回地址保存到ra寄存器
	jalr s0
ffffffffc0203262:	9402                	jalr	s0

	# ========== 线程函数返回，终止线程 ==========
	# 线程函数执行完毕，调用do_exit终止当前线程
	# 传递退出码0表示正常退出
	jal do_exit
ffffffffc0203264:	476000ef          	jal	ra,ffffffffc02036da <do_exit>

ffffffffc0203268 <switch_to>:
switch_to:
    # ========== 保存当前进程(from)的上下文 ==========
    # 将当前CPU中的寄存器值保存到from->context结构体中

    # 保存返回地址寄存器 (context.ra)
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203268:	00153023          	sd	ra,0(a0)

    # 保存栈指针寄存器 (context.sp)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020326c:	00253423          	sd	sp,8(a0)

    # 保存保存寄存器s0-s11 (context.s0 ~ context.s11)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203270:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203272:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203274:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203278:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020327c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203280:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203284:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203288:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020328c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203290:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203294:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203298:	07b53423          	sd	s11,104(a0)

    # ========== 恢复目标进程(to)的上下文 ==========
    # 从to->context结构体中恢复寄存器值到CPU

    # 恢复返回地址寄存器
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020329c:	0005b083          	ld	ra,0(a1)

    # 恢复栈指针寄存器
    LOAD sp, 1*REGBYTES(a1)
ffffffffc02032a0:	0085b103          	ld	sp,8(a1)

    # 恢复保存寄存器s0-s11
    LOAD s0, 2*REGBYTES(a1)
ffffffffc02032a4:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc02032a6:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc02032a8:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc02032ac:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02032b0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02032b4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02032b8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02032bc:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02032c0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02032c4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02032c8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02032cc:	0685bd83          	ld	s11,104(a1)

    # ========== 返回到目标进程 ==========
    # ret指令相当于"jalr x0, ra, 0"，跳转到ra指向的地址
    # 对于目标进程，ra指向了切换发生前的执行点
    ret
ffffffffc02032d0:	8082                	ret

ffffffffc02032d2 <alloc_proc>:
 * - list_link: 进程链表节点，初始化为空链表
 * - hash_link: 哈希链表节点，初始化为空链表
 * ===================================================================== */
static struct proc_struct *
alloc_proc(void)
{
ffffffffc02032d2:	1141                	addi	sp,sp,-16
    // 从内核堆中分配进程结构体内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02032d4:	0e800513          	li	a0,232
{
ffffffffc02032d8:	e022                	sd	s0,0(sp)
ffffffffc02032da:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02032dc:	9f2fe0ef          	jal	ra,ffffffffc02014ce <kmalloc>
ffffffffc02032e0:	842a                	mv	s0,a0

    if (proc != NULL)
ffffffffc02032e2:	cd21                	beqz	a0,ffffffffc020333a <alloc_proc+0x68>
    {
        // LAB4:EXERCISE1 - 进程结构体字段初始化
        // 以下字段需要按照规范进行初始化：

        // ========== 进程状态和标识 ==========
        proc->state = PROC_UNINIT;          // 进程状态：未初始化
ffffffffc02032e4:	57fd                	li	a5,-1
ffffffffc02032e6:	1782                	slli	a5,a5,0x20
ffffffffc02032e8:	e11c                	sd	a5,0(a0)
        proc->pid = -1;                     // 进程ID：无效值，待分配
        proc->runs = 0;                     // 运行次数计数器：初始为0

        // ========== 内存管理相关 ==========
        proc->kstack = 0;                   // 内核栈地址：待分配
        proc->pgdir = boot_pgdir_pa;        // 页目录：使用引导时的页目录
ffffffffc02032ea:	0000a797          	auipc	a5,0xa
ffffffffc02032ee:	1ae7b783          	ld	a5,430(a5) # ffffffffc020d498 <boot_pgdir_pa>
ffffffffc02032f2:	ed1c                	sd	a5,24(a0)
        // ========== 进程关系 ==========
        proc->parent = NULL;                // 父进程：无
        proc->mm = NULL;                    // 内存管理结构体：lab4中未使用

        // ========== 执行上下文 ==========
        memset(&(proc->context), 0, sizeof(struct context)); // 上下文清零
ffffffffc02032f4:	07000613          	li	a2,112
ffffffffc02032f8:	4581                	li	a1,0
        proc->runs = 0;                     // 运行次数计数器：初始为0
ffffffffc02032fa:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                   // 内核栈地址：待分配
ffffffffc02032fe:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;             // 重新调度标志：不需要
ffffffffc0203302:	02052023          	sw	zero,32(a0)
        proc->parent = NULL;                // 父进程：无
ffffffffc0203306:	02053423          	sd	zero,40(a0)
        proc->mm = NULL;                    // 内存管理结构体：lab4中未使用
ffffffffc020330a:	02053823          	sd	zero,48(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 上下文清零
ffffffffc020330e:	03850513          	addi	a0,a0,56
ffffffffc0203312:	7b8000ef          	jal	ra,ffffffffc0203aca <memset>
        proc->tf = NULL;                    // trapframe：无

        // ========== 标志和属性 ==========
        proc->flags = 0;                    // 进程标志：无特殊标志
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空
ffffffffc0203316:	4641                	li	a2,16
        proc->tf = NULL;                    // trapframe：无
ffffffffc0203318:	0a043423          	sd	zero,168(s0)
        proc->flags = 0;                    // 进程标志：无特殊标志
ffffffffc020331c:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空
ffffffffc0203320:	4581                	li	a1,0
ffffffffc0203322:	0b440513          	addi	a0,s0,180
ffffffffc0203326:	7a4000ef          	jal	ra,ffffffffc0203aca <memset>

        // ========== 链表节点初始化 ==========
        list_init(&(proc->list_link));      // 进程链表节点初始化
ffffffffc020332a:	0c840713          	addi	a4,s0,200
        list_init(&(proc->hash_link));      // 哈希链表节点初始化
ffffffffc020332e:	0d840793          	addi	a5,s0,216
    elm->prev = elm->next = elm;
ffffffffc0203332:	e878                	sd	a4,208(s0)
ffffffffc0203334:	e478                	sd	a4,200(s0)
ffffffffc0203336:	f07c                	sd	a5,224(s0)
ffffffffc0203338:	ec7c                	sd	a5,216(s0)
    }

    return proc;
}
ffffffffc020333a:	60a2                	ld	ra,8(sp)
ffffffffc020333c:	8522                	mv	a0,s0
ffffffffc020333e:	6402                	ld	s0,0(sp)
ffffffffc0203340:	0141                	addi	sp,sp,16
ffffffffc0203342:	8082                	ret

ffffffffc0203344 <forkret>:
static void
forkret(void)
{
    // 调用forkrets恢复trapframe并返回
    // current->tf是在copy_thread中设置的trapframe
    forkrets(current->tf);
ffffffffc0203344:	0000a797          	auipc	a5,0xa
ffffffffc0203348:	1847b783          	ld	a5,388(a5) # ffffffffc020d4c8 <current>
ffffffffc020334c:	77c8                	ld	a0,168(a5)
ffffffffc020334e:	ae3fd06f          	j	ffffffffc0200e30 <forkrets>

ffffffffc0203352 <init_main>:
 * 该线程用于系统初始化后的工作，演示内核线程的基本功能。
 * 打印进程信息和传入的参数，然后退出。
 * ===================================================================== */
static int
init_main(void *arg)
{
ffffffffc0203352:	7179                	addi	sp,sp,-48
ffffffffc0203354:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc0203356:	0000a497          	auipc	s1,0xa
ffffffffc020335a:	0f248493          	addi	s1,s1,242 # ffffffffc020d448 <name.2>
{
ffffffffc020335e:	f022                	sd	s0,32(sp)
ffffffffc0203360:	e84a                	sd	s2,16(sp)
ffffffffc0203362:	842a                	mv	s0,a0
    // 打印当前进程（initproc）的信息
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
            current->pid, get_proc_name(current));
ffffffffc0203364:	0000a917          	auipc	s2,0xa
ffffffffc0203368:	16493903          	ld	s2,356(s2) # ffffffffc020d4c8 <current>
    memset(name, 0, sizeof(name));
ffffffffc020336c:	4641                	li	a2,16
ffffffffc020336e:	4581                	li	a1,0
ffffffffc0203370:	8526                	mv	a0,s1
{
ffffffffc0203372:	f406                	sd	ra,40(sp)
ffffffffc0203374:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
ffffffffc0203376:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc020337a:	750000ef          	jal	ra,ffffffffc0203aca <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020337e:	0b490593          	addi	a1,s2,180
ffffffffc0203382:	463d                	li	a2,15
ffffffffc0203384:	8526                	mv	a0,s1
ffffffffc0203386:	756000ef          	jal	ra,ffffffffc0203adc <memcpy>
ffffffffc020338a:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
ffffffffc020338c:	85ce                	mv	a1,s3
ffffffffc020338e:	00002517          	auipc	a0,0x2
ffffffffc0203392:	39a50513          	addi	a0,a0,922 # ffffffffc0205728 <default_pmm_manager+0x608>
ffffffffc0203396:	d4bfc0ef          	jal	ra,ffffffffc02000e0 <cprintf>

    // 打印传入的参数
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020339a:	85a2                	mv	a1,s0
ffffffffc020339c:	00002517          	auipc	a0,0x2
ffffffffc02033a0:	3b450513          	addi	a0,a0,948 # ffffffffc0205750 <default_pmm_manager+0x630>
ffffffffc02033a4:	d3dfc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc02033a8:	00002517          	auipc	a0,0x2
ffffffffc02033ac:	3b850513          	addi	a0,a0,952 # ffffffffc0205760 <default_pmm_manager+0x640>
ffffffffc02033b0:	d31fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>

    return 0;  // 线程正常退出
}
ffffffffc02033b4:	70a2                	ld	ra,40(sp)
ffffffffc02033b6:	7402                	ld	s0,32(sp)
ffffffffc02033b8:	64e2                	ld	s1,24(sp)
ffffffffc02033ba:	6942                	ld	s2,16(sp)
ffffffffc02033bc:	69a2                	ld	s3,8(sp)
ffffffffc02033be:	4501                	li	a0,0
ffffffffc02033c0:	6145                	addi	sp,sp,48
ffffffffc02033c2:	8082                	ret

ffffffffc02033c4 <proc_run>:
{
ffffffffc02033c4:	7179                	addi	sp,sp,-48
ffffffffc02033c6:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc02033c8:	0000a497          	auipc	s1,0xa
ffffffffc02033cc:	10048493          	addi	s1,s1,256 # ffffffffc020d4c8 <current>
ffffffffc02033d0:	6098                	ld	a4,0(s1)
{
ffffffffc02033d2:	f406                	sd	ra,40(sp)
ffffffffc02033d4:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc02033d6:	02a70863          	beq	a4,a0,ffffffffc0203406 <proc_run+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033da:	100027f3          	csrr	a5,sstatus
ffffffffc02033de:	8b89                	andi	a5,a5,2
    return 0;            // 返回false表示原本关闭
ffffffffc02033e0:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033e2:	ef8d                	bnez	a5,ffffffffc020341c <proc_run+0x58>
        lsatp(proc->pgdir);
ffffffffc02033e4:	6d1c                	ld	a5,24(a0)
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned int pgdir)
{
  write_csr(satp, SATP32_MODE | (pgdir >> RISCV_PGSHIFT));
ffffffffc02033e6:	800006b7          	lui	a3,0x80000
        current = proc;           // 更新当前进程指针
ffffffffc02033ea:	e088                	sd	a0,0(s1)
ffffffffc02033ec:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02033f0:	8fd5                	or	a5,a5,a3
ffffffffc02033f2:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));
ffffffffc02033f6:	03850593          	addi	a1,a0,56
ffffffffc02033fa:	03870513          	addi	a0,a4,56 # 1038 <kern_entry-0xffffffffc01fefc8>
ffffffffc02033fe:	e6bff0ef          	jal	ra,ffffffffc0203268 <switch_to>
    if (flag) {
ffffffffc0203402:	00091763          	bnez	s2,ffffffffc0203410 <proc_run+0x4c>
}
ffffffffc0203406:	70a2                	ld	ra,40(sp)
ffffffffc0203408:	7482                	ld	s1,32(sp)
ffffffffc020340a:	6962                	ld	s2,24(sp)
ffffffffc020340c:	6145                	addi	sp,sp,48
ffffffffc020340e:	8082                	ret
ffffffffc0203410:	70a2                	ld	ra,40(sp)
ffffffffc0203412:	7482                	ld	s1,32(sp)
ffffffffc0203414:	6962                	ld	s2,24(sp)
ffffffffc0203416:	6145                	addi	sp,sp,48
        intr_enable();   // 开启中断
ffffffffc0203418:	d18fd06f          	j	ffffffffc0200930 <intr_enable>
ffffffffc020341c:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc020341e:	d18fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        prev = current;           // 保存当前进程
ffffffffc0203422:	6098                	ld	a4,0(s1)
        return 1;        // 返回true表示原本开启
ffffffffc0203424:	6522                	ld	a0,8(sp)
ffffffffc0203426:	4905                	li	s2,1
ffffffffc0203428:	bf75                	j	ffffffffc02033e4 <proc_run+0x20>

ffffffffc020342a <do_fork>:
{
ffffffffc020342a:	7179                	addi	sp,sp,-48
ffffffffc020342c:	ec26                	sd	s1,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020342e:	0000a497          	auipc	s1,0xa
ffffffffc0203432:	0b248493          	addi	s1,s1,178 # ffffffffc020d4e0 <nr_process>
ffffffffc0203436:	4098                	lw	a4,0(s1)
{
ffffffffc0203438:	f406                	sd	ra,40(sp)
ffffffffc020343a:	f022                	sd	s0,32(sp)
ffffffffc020343c:	e84a                	sd	s2,16(sp)
ffffffffc020343e:	e44e                	sd	s3,8(sp)
ffffffffc0203440:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc0203442:	6785                	lui	a5,0x1
ffffffffc0203444:	1ef75b63          	bge	a4,a5,ffffffffc020363a <do_fork+0x210>
ffffffffc0203448:	892e                	mv	s2,a1
ffffffffc020344a:	89b2                	mv	s3,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc020344c:	e87ff0ef          	jal	ra,ffffffffc02032d2 <alloc_proc>
ffffffffc0203450:	842a                	mv	s0,a0
ffffffffc0203452:	1e050b63          	beqz	a0,ffffffffc0203648 <do_fork+0x21e>
    proc->parent = current;  // 设置父进程指针
ffffffffc0203456:	0000aa17          	auipc	s4,0xa
ffffffffc020345a:	072a0a13          	addi	s4,s4,114 # ffffffffc020d4c8 <current>
ffffffffc020345e:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203462:	4509                	li	a0,2
    proc->parent = current;  // 设置父进程指针
ffffffffc0203464:	f41c                	sd	a5,40(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203466:	cf5fe0ef          	jal	ra,ffffffffc020215a <alloc_pages>
    if (page != NULL)
ffffffffc020346a:	12050763          	beqz	a0,ffffffffc0203598 <do_fork+0x16e>
    return page - pages + nbase;
ffffffffc020346e:	0000a697          	auipc	a3,0xa
ffffffffc0203472:	0426b683          	ld	a3,66(a3) # ffffffffc020d4b0 <pages>
ffffffffc0203476:	40d506b3          	sub	a3,a0,a3
ffffffffc020347a:	8699                	srai	a3,a3,0x6
ffffffffc020347c:	00002517          	auipc	a0,0x2
ffffffffc0203480:	6a453503          	ld	a0,1700(a0) # ffffffffc0205b20 <nbase>
ffffffffc0203484:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0203486:	00c69793          	slli	a5,a3,0xc
ffffffffc020348a:	83b1                	srli	a5,a5,0xc
ffffffffc020348c:	0000a717          	auipc	a4,0xa
ffffffffc0203490:	01c73703          	ld	a4,28(a4) # ffffffffc020d4a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203494:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203496:	1ae7fe63          	bgeu	a5,a4,ffffffffc0203652 <do_fork+0x228>
    assert(current->mm == NULL);
ffffffffc020349a:	000a3783          	ld	a5,0(s4)
ffffffffc020349e:	0000a717          	auipc	a4,0xa
ffffffffc02034a2:	02273703          	ld	a4,34(a4) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc02034a6:	96ba                	add	a3,a3,a4
ffffffffc02034a8:	7b9c                	ld	a5,48(a5)
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02034aa:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc02034ac:	1a079f63          	bnez	a5,ffffffffc020366a <do_fork+0x240>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02034b0:	6789                	lui	a5,0x2
ffffffffc02034b2:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc02034b6:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc02034b8:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02034ba:	f454                	sd	a3,168(s0)
    *(proc->tf) = *tf;
ffffffffc02034bc:	87b6                	mv	a5,a3
ffffffffc02034be:	12098893          	addi	a7,s3,288
ffffffffc02034c2:	00063803          	ld	a6,0(a2)
ffffffffc02034c6:	6608                	ld	a0,8(a2)
ffffffffc02034c8:	6a0c                	ld	a1,16(a2)
ffffffffc02034ca:	6e18                	ld	a4,24(a2)
ffffffffc02034cc:	0107b023          	sd	a6,0(a5)
ffffffffc02034d0:	e788                	sd	a0,8(a5)
ffffffffc02034d2:	eb8c                	sd	a1,16(a5)
ffffffffc02034d4:	ef98                	sd	a4,24(a5)
ffffffffc02034d6:	02060613          	addi	a2,a2,32
ffffffffc02034da:	02078793          	addi	a5,a5,32
ffffffffc02034de:	ff1612e3          	bne	a2,a7,ffffffffc02034c2 <do_fork+0x98>
    proc->tf->gpr.a0 = 0;
ffffffffc02034e2:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02034e6:	12090c63          	beqz	s2,ffffffffc020361e <do_fork+0x1f4>
ffffffffc02034ea:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02034ee:	00000797          	auipc	a5,0x0
ffffffffc02034f2:	e5678793          	addi	a5,a5,-426 # ffffffffc0203344 <forkret>
ffffffffc02034f6:	fc1c                	sd	a5,56(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02034f8:	e034                	sd	a3,64(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034fa:	100027f3          	csrr	a5,sstatus
ffffffffc02034fe:	8b89                	andi	a5,a5,2
    return 0;            // 返回false表示原本关闭
ffffffffc0203500:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203502:	12079863          	bnez	a5,ffffffffc0203632 <do_fork+0x208>
    if (++last_pid >= MAX_PID)
ffffffffc0203506:	00006817          	auipc	a6,0x6
ffffffffc020350a:	b2280813          	addi	a6,a6,-1246 # ffffffffc0209028 <last_pid.1>
ffffffffc020350e:	00082783          	lw	a5,0(a6)
ffffffffc0203512:	6709                	lui	a4,0x2
ffffffffc0203514:	0017851b          	addiw	a0,a5,1
ffffffffc0203518:	00a82023          	sw	a0,0(a6)
ffffffffc020351c:	08e55a63          	bge	a0,a4,ffffffffc02035b0 <do_fork+0x186>
    if (last_pid >= next_safe)
ffffffffc0203520:	00006317          	auipc	t1,0x6
ffffffffc0203524:	b0c30313          	addi	t1,t1,-1268 # ffffffffc020902c <next_safe.0>
ffffffffc0203528:	00032783          	lw	a5,0(t1)
ffffffffc020352c:	0000a917          	auipc	s2,0xa
ffffffffc0203530:	f2c90913          	addi	s2,s2,-212 # ffffffffc020d458 <proc_list>
ffffffffc0203534:	08f55663          	bge	a0,a5,ffffffffc02035c0 <do_fork+0x196>
        proc->pid = get_pid();
ffffffffc0203538:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020353a:	45a9                	li	a1,10
ffffffffc020353c:	2501                	sext.w	a0,a0
ffffffffc020353e:	1c9000ef          	jal	ra,ffffffffc0203f06 <hash32>
ffffffffc0203542:	02051793          	slli	a5,a0,0x20
ffffffffc0203546:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020354a:	00006797          	auipc	a5,0x6
ffffffffc020354e:	efe78793          	addi	a5,a5,-258 # ffffffffc0209448 <hash_list>
ffffffffc0203552:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0203554:	6510                	ld	a2,8(a0)
ffffffffc0203556:	0d840793          	addi	a5,s0,216
ffffffffc020355a:	00893683          	ld	a3,8(s2)
        nr_process++;
ffffffffc020355e:	4098                	lw	a4,0(s1)
    prev->next = next->prev = elm;
ffffffffc0203560:	e21c                	sd	a5,0(a2)
ffffffffc0203562:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0203564:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc0203566:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc020356a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020356c:	e29c                	sd	a5,0(a3)
        nr_process++;
ffffffffc020356e:	2705                	addiw	a4,a4,1
ffffffffc0203570:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc0203574:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc0203576:	0d243423          	sd	s2,200(s0)
ffffffffc020357a:	c098                	sw	a4,0(s1)
    if (flag) {
ffffffffc020357c:	0a099363          	bnez	s3,ffffffffc0203622 <do_fork+0x1f8>
    wakeup_proc(proc);
ffffffffc0203580:	8522                	mv	a0,s0
ffffffffc0203582:	3de000ef          	jal	ra,ffffffffc0203960 <wakeup_proc>
    ret = proc->pid;
ffffffffc0203586:	4048                	lw	a0,4(s0)
}
ffffffffc0203588:	70a2                	ld	ra,40(sp)
ffffffffc020358a:	7402                	ld	s0,32(sp)
ffffffffc020358c:	64e2                	ld	s1,24(sp)
ffffffffc020358e:	6942                	ld	s2,16(sp)
ffffffffc0203590:	69a2                	ld	s3,8(sp)
ffffffffc0203592:	6a02                	ld	s4,0(sp)
ffffffffc0203594:	6145                	addi	sp,sp,48
ffffffffc0203596:	8082                	ret
    kfree(proc);       // 释放进程结构体
ffffffffc0203598:	8522                	mv	a0,s0
ffffffffc020359a:	fe5fd0ef          	jal	ra,ffffffffc020157e <kfree>
    return -E_NO_MEM;  // 内存分配失败
ffffffffc020359e:	5571                	li	a0,-4
}
ffffffffc02035a0:	70a2                	ld	ra,40(sp)
ffffffffc02035a2:	7402                	ld	s0,32(sp)
ffffffffc02035a4:	64e2                	ld	s1,24(sp)
ffffffffc02035a6:	6942                	ld	s2,16(sp)
ffffffffc02035a8:	69a2                	ld	s3,8(sp)
ffffffffc02035aa:	6a02                	ld	s4,0(sp)
ffffffffc02035ac:	6145                	addi	sp,sp,48
ffffffffc02035ae:	8082                	ret
        last_pid = 1;
ffffffffc02035b0:	4785                	li	a5,1
ffffffffc02035b2:	00f82023          	sw	a5,0(a6)
        goto inside;  // 跳转到内部检查逻辑
ffffffffc02035b6:	4505                	li	a0,1
ffffffffc02035b8:	00006317          	auipc	t1,0x6
ffffffffc02035bc:	a7430313          	addi	t1,t1,-1420 # ffffffffc020902c <next_safe.0>
    return listelm->next;
ffffffffc02035c0:	0000a917          	auipc	s2,0xa
ffffffffc02035c4:	e9890913          	addi	s2,s2,-360 # ffffffffc020d458 <proc_list>
ffffffffc02035c8:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;  // 重置安全边界
ffffffffc02035cc:	6789                	lui	a5,0x2
ffffffffc02035ce:	00f32023          	sw	a5,0(t1)
ffffffffc02035d2:	86aa                	mv	a3,a0
ffffffffc02035d4:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02035d6:	6e89                	lui	t4,0x2
ffffffffc02035d8:	072e0363          	beq	t3,s2,ffffffffc020363e <do_fork+0x214>
ffffffffc02035dc:	88ae                	mv	a7,a1
ffffffffc02035de:	87f2                	mv	a5,t3
ffffffffc02035e0:	6609                	lui	a2,0x2
ffffffffc02035e2:	a811                	j	ffffffffc02035f6 <do_fork+0x1cc>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02035e4:	00e6d663          	bge	a3,a4,ffffffffc02035f0 <do_fork+0x1c6>
ffffffffc02035e8:	00c75463          	bge	a4,a2,ffffffffc02035f0 <do_fork+0x1c6>
ffffffffc02035ec:	863a                	mv	a2,a4
ffffffffc02035ee:	4885                	li	a7,1
ffffffffc02035f0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02035f2:	01278d63          	beq	a5,s2,ffffffffc020360c <do_fork+0x1e2>
            if (proc->pid == last_pid)
ffffffffc02035f6:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc02035fa:	fed715e3          	bne	a4,a3,ffffffffc02035e4 <do_fork+0x1ba>
                if (++last_pid >= next_safe)
ffffffffc02035fe:	2685                	addiw	a3,a3,1
ffffffffc0203600:	02c6d463          	bge	a3,a2,ffffffffc0203628 <do_fork+0x1fe>
ffffffffc0203604:	679c                	ld	a5,8(a5)
ffffffffc0203606:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0203608:	ff2797e3          	bne	a5,s2,ffffffffc02035f6 <do_fork+0x1cc>
ffffffffc020360c:	c581                	beqz	a1,ffffffffc0203614 <do_fork+0x1ea>
ffffffffc020360e:	00d82023          	sw	a3,0(a6)
ffffffffc0203612:	8536                	mv	a0,a3
ffffffffc0203614:	f20882e3          	beqz	a7,ffffffffc0203538 <do_fork+0x10e>
ffffffffc0203618:	00c32023          	sw	a2,0(t1)
ffffffffc020361c:	bf31                	j	ffffffffc0203538 <do_fork+0x10e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020361e:	8936                	mv	s2,a3
ffffffffc0203620:	b5e9                	j	ffffffffc02034ea <do_fork+0xc0>
        intr_enable();   // 开启中断
ffffffffc0203622:	b0efd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0203626:	bfa9                	j	ffffffffc0203580 <do_fork+0x156>
                    if (last_pid >= MAX_PID)
ffffffffc0203628:	01d6c363          	blt	a3,t4,ffffffffc020362e <do_fork+0x204>
                        last_pid = 1;  // 回绕到1
ffffffffc020362c:	4685                	li	a3,1
                    goto repeat;  // 重新开始检查
ffffffffc020362e:	4585                	li	a1,1
ffffffffc0203630:	b765                	j	ffffffffc02035d8 <do_fork+0x1ae>
        intr_disable();  // 关闭中断
ffffffffc0203632:	b04fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;        // 返回true表示原本开启
ffffffffc0203636:	4985                	li	s3,1
ffffffffc0203638:	b5f9                	j	ffffffffc0203506 <do_fork+0xdc>
    int ret = -E_NO_FREE_PROC;         // 默认错误：进程数达到上限
ffffffffc020363a:	556d                	li	a0,-5
ffffffffc020363c:	b795                	j	ffffffffc02035a0 <do_fork+0x176>
ffffffffc020363e:	c599                	beqz	a1,ffffffffc020364c <do_fork+0x222>
ffffffffc0203640:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0203644:	8536                	mv	a0,a3
ffffffffc0203646:	bdcd                	j	ffffffffc0203538 <do_fork+0x10e>
    ret = -E_NO_MEM;  // 默认错误：内存不足
ffffffffc0203648:	5571                	li	a0,-4
    return ret;
ffffffffc020364a:	bf99                	j	ffffffffc02035a0 <do_fork+0x176>
    return last_pid;
ffffffffc020364c:	00082503          	lw	a0,0(a6)
ffffffffc0203650:	b5e5                	j	ffffffffc0203538 <do_fork+0x10e>
ffffffffc0203652:	00001617          	auipc	a2,0x1
ffffffffc0203656:	63660613          	addi	a2,a2,1590 # ffffffffc0204c88 <commands+0xae0>
ffffffffc020365a:	07100593          	li	a1,113
ffffffffc020365e:	00001517          	auipc	a0,0x1
ffffffffc0203662:	65250513          	addi	a0,a0,1618 # ffffffffc0204cb0 <commands+0xb08>
ffffffffc0203666:	b79fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(current->mm == NULL);
ffffffffc020366a:	00002697          	auipc	a3,0x2
ffffffffc020366e:	11668693          	addi	a3,a3,278 # ffffffffc0205780 <default_pmm_manager+0x660>
ffffffffc0203672:	00001617          	auipc	a2,0x1
ffffffffc0203676:	3f660613          	addi	a2,a2,1014 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc020367a:	29e00593          	li	a1,670
ffffffffc020367e:	00002517          	auipc	a0,0x2
ffffffffc0203682:	11a50513          	addi	a0,a0,282 # ffffffffc0205798 <default_pmm_manager+0x678>
ffffffffc0203686:	b59fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020368a <kernel_thread>:
{
ffffffffc020368a:	7129                	addi	sp,sp,-320
ffffffffc020368c:	fa22                	sd	s0,304(sp)
ffffffffc020368e:	f626                	sd	s1,296(sp)
ffffffffc0203690:	f24a                	sd	s2,288(sp)
ffffffffc0203692:	84ae                	mv	s1,a1
ffffffffc0203694:	892a                	mv	s2,a0
ffffffffc0203696:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0203698:	4581                	li	a1,0
ffffffffc020369a:	12000613          	li	a2,288
ffffffffc020369e:	850a                	mv	a0,sp
{
ffffffffc02036a0:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02036a2:	428000ef          	jal	ra,ffffffffc0203aca <memset>
    tf.gpr.s0 = (uintptr_t)fn;        // s0 = 线程函数地址
ffffffffc02036a6:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;       // s1 = 函数参数
ffffffffc02036a8:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02036aa:	100027f3          	csrr	a5,sstatus
ffffffffc02036ae:	edd7f793          	andi	a5,a5,-291
ffffffffc02036b2:	1207e793          	ori	a5,a5,288
ffffffffc02036b6:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036b8:	860a                	mv	a2,sp
ffffffffc02036ba:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02036be:	00000797          	auipc	a5,0x0
ffffffffc02036c2:	ba278793          	addi	a5,a5,-1118 # ffffffffc0203260 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036c6:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02036c8:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02036ca:	d61ff0ef          	jal	ra,ffffffffc020342a <do_fork>
}
ffffffffc02036ce:	70f2                	ld	ra,312(sp)
ffffffffc02036d0:	7452                	ld	s0,304(sp)
ffffffffc02036d2:	74b2                	ld	s1,296(sp)
ffffffffc02036d4:	7912                	ld	s2,288(sp)
ffffffffc02036d6:	6131                	addi	sp,sp,320
ffffffffc02036d8:	8082                	ret

ffffffffc02036da <do_exit>:
{
ffffffffc02036da:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02036dc:	00002617          	auipc	a2,0x2
ffffffffc02036e0:	0d460613          	addi	a2,a2,212 # ffffffffc02057b0 <default_pmm_manager+0x690>
ffffffffc02036e4:	38900593          	li	a1,905
ffffffffc02036e8:	00002517          	auipc	a0,0x2
ffffffffc02036ec:	0b050513          	addi	a0,a0,176 # ffffffffc0205798 <default_pmm_manager+0x678>
{
ffffffffc02036f0:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02036f2:	aedfc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02036f6 <proc_init>:
 * - PID为0，是系统中第一个进程
 * - 使用预先分配的bootstack作为内核栈
 * - 始终处于可运行状态
 * ===================================================================== */
void proc_init(void)
{
ffffffffc02036f6:	7179                	addi	sp,sp,-48
ffffffffc02036f8:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc02036fa:	0000a797          	auipc	a5,0xa
ffffffffc02036fe:	d5e78793          	addi	a5,a5,-674 # ffffffffc020d458 <proc_list>
ffffffffc0203702:	f406                	sd	ra,40(sp)
ffffffffc0203704:	f022                	sd	s0,32(sp)
ffffffffc0203706:	e84a                	sd	s2,16(sp)
ffffffffc0203708:	e44e                	sd	s3,8(sp)
ffffffffc020370a:	00006497          	auipc	s1,0x6
ffffffffc020370e:	d3e48493          	addi	s1,s1,-706 # ffffffffc0209448 <hash_list>
ffffffffc0203712:	e79c                	sd	a5,8(a5)
ffffffffc0203714:	e39c                	sd	a5,0(a5)
    // ========== 1. 初始化进程管理数据结构 ==========
    // 初始化进程链表（双向循环链表）
    list_init(&proc_list);

    // 初始化PID哈希表的所有桶
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0203716:	0000a717          	auipc	a4,0xa
ffffffffc020371a:	d3270713          	addi	a4,a4,-718 # ffffffffc020d448 <name.2>
ffffffffc020371e:	87a6                	mv	a5,s1
ffffffffc0203720:	e79c                	sd	a5,8(a5)
ffffffffc0203722:	e39c                	sd	a5,0(a5)
ffffffffc0203724:	07c1                	addi	a5,a5,16
ffffffffc0203726:	fef71de3          	bne	a4,a5,ffffffffc0203720 <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    // ========== 2. 创建idle进程 ==========
    if ((idleproc = alloc_proc()) == NULL)
ffffffffc020372a:	ba9ff0ef          	jal	ra,ffffffffc02032d2 <alloc_proc>
ffffffffc020372e:	0000a917          	auipc	s2,0xa
ffffffffc0203732:	da290913          	addi	s2,s2,-606 # ffffffffc020d4d0 <idleproc>
ffffffffc0203736:	00a93023          	sd	a0,0(s2)
ffffffffc020373a:	18050d63          	beqz	a0,ffffffffc02038d4 <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // ========== 3. 验证alloc_proc函数的正确性 ==========
    // 通过内存比较验证idleproc的各个字段是否正确初始化
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020373e:	07000513          	li	a0,112
ffffffffc0203742:	d8dfd0ef          	jal	ra,ffffffffc02014ce <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0203746:	07000613          	li	a2,112
ffffffffc020374a:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020374c:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020374e:	37c000ef          	jal	ra,ffffffffc0203aca <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0203752:	00093503          	ld	a0,0(s2)
ffffffffc0203756:	85a2                	mv	a1,s0
ffffffffc0203758:	07000613          	li	a2,112
ffffffffc020375c:	03850513          	addi	a0,a0,56
ffffffffc0203760:	394000ef          	jal	ra,ffffffffc0203af4 <memcmp>
ffffffffc0203764:	89aa                	mv	s3,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203766:	453d                	li	a0,15
ffffffffc0203768:	d67fd0ef          	jal	ra,ffffffffc02014ce <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020376c:	463d                	li	a2,15
ffffffffc020376e:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203770:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0203772:	358000ef          	jal	ra,ffffffffc0203aca <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0203776:	00093503          	ld	a0,0(s2)
ffffffffc020377a:	463d                	li	a2,15
ffffffffc020377c:	85a2                	mv	a1,s0
ffffffffc020377e:	0b450513          	addi	a0,a0,180
ffffffffc0203782:	372000ef          	jal	ra,ffffffffc0203af4 <memcmp>

    // 检查idleproc是否正确初始化
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
ffffffffc0203786:	00093783          	ld	a5,0(s2)
ffffffffc020378a:	0000a717          	auipc	a4,0xa
ffffffffc020378e:	d0e73703          	ld	a4,-754(a4) # ffffffffc020d498 <boot_pgdir_pa>
ffffffffc0203792:	6f94                	ld	a3,24(a5)
ffffffffc0203794:	0ee68463          	beq	a3,a4,ffffffffc020387c <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");
    }

    // ========== 4. 设置idle进程属性 ==========
    idleproc->pid = 0;                          // 设置PID为0
    idleproc->state = PROC_RUNNABLE;            // 设置为可运行状态
ffffffffc0203798:	4709                	li	a4,2
ffffffffc020379a:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
ffffffffc020379c:	00003717          	auipc	a4,0x3
ffffffffc02037a0:	86470713          	addi	a4,a4,-1948 # ffffffffc0206000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037a4:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
ffffffffc02037a8:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;                 // 需要立即调度
ffffffffc02037aa:	4705                	li	a4,1
ffffffffc02037ac:	d398                	sw	a4,32(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037ae:	4641                	li	a2,16
ffffffffc02037b0:	4581                	li	a1,0
ffffffffc02037b2:	8522                	mv	a0,s0
ffffffffc02037b4:	316000ef          	jal	ra,ffffffffc0203aca <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02037b8:	463d                	li	a2,15
ffffffffc02037ba:	00002597          	auipc	a1,0x2
ffffffffc02037be:	03e58593          	addi	a1,a1,62 # ffffffffc02057f8 <default_pmm_manager+0x6d8>
ffffffffc02037c2:	8522                	mv	a0,s0
ffffffffc02037c4:	318000ef          	jal	ra,ffffffffc0203adc <memcpy>
    set_proc_name(idleproc, "idle");            // 设置进程名为"idle"
    nr_process++;                               // 进程计数加1
ffffffffc02037c8:	0000a717          	auipc	a4,0xa
ffffffffc02037cc:	d1870713          	addi	a4,a4,-744 # ffffffffc020d4e0 <nr_process>
ffffffffc02037d0:	431c                	lw	a5,0(a4)

    // ========== 5. 设置当前进程为idleproc ==========
    current = idleproc;
ffffffffc02037d2:	00093683          	ld	a3,0(s2)

    // ========== 6. 创建init_main线程 ==========
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037d6:	4601                	li	a2,0
    nr_process++;                               // 进程计数加1
ffffffffc02037d8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037da:	00002597          	auipc	a1,0x2
ffffffffc02037de:	02658593          	addi	a1,a1,38 # ffffffffc0205800 <default_pmm_manager+0x6e0>
ffffffffc02037e2:	00000517          	auipc	a0,0x0
ffffffffc02037e6:	b7050513          	addi	a0,a0,-1168 # ffffffffc0203352 <init_main>
    nr_process++;                               // 进程计数加1
ffffffffc02037ea:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc02037ec:	0000a797          	auipc	a5,0xa
ffffffffc02037f0:	ccd7be23          	sd	a3,-804(a5) # ffffffffc020d4c8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037f4:	e97ff0ef          	jal	ra,ffffffffc020368a <kernel_thread>
ffffffffc02037f8:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc02037fa:	0ea05963          	blez	a0,ffffffffc02038ec <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID)
ffffffffc02037fe:	6789                	lui	a5,0x2
ffffffffc0203800:	fff5071b          	addiw	a4,a0,-1
ffffffffc0203804:	17f9                	addi	a5,a5,-2
ffffffffc0203806:	2501                	sext.w	a0,a0
ffffffffc0203808:	02e7e363          	bltu	a5,a4,ffffffffc020382e <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020380c:	45a9                	li	a1,10
ffffffffc020380e:	6f8000ef          	jal	ra,ffffffffc0203f06 <hash32>
ffffffffc0203812:	02051793          	slli	a5,a0,0x20
ffffffffc0203816:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020381a:	96a6                	add	a3,a3,s1
ffffffffc020381c:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc020381e:	a029                	j	ffffffffc0203828 <proc_init+0x132>
            if (proc->pid == pid)
ffffffffc0203820:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc0203824:	0a870563          	beq	a4,s0,ffffffffc02038ce <proc_init+0x1d8>
    return listelm->next;
ffffffffc0203828:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020382a:	fef69be3          	bne	a3,a5,ffffffffc0203820 <proc_init+0x12a>
    return NULL;
ffffffffc020382e:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203830:	0b478493          	addi	s1,a5,180
ffffffffc0203834:	4641                	li	a2,16
ffffffffc0203836:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    // ========== 7. 获取并命名init进程 ==========
    initproc = find_proc(pid);
ffffffffc0203838:	0000a417          	auipc	s0,0xa
ffffffffc020383c:	ca040413          	addi	s0,s0,-864 # ffffffffc020d4d8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203840:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0203842:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203844:	286000ef          	jal	ra,ffffffffc0203aca <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0203848:	463d                	li	a2,15
ffffffffc020384a:	00002597          	auipc	a1,0x2
ffffffffc020384e:	fe658593          	addi	a1,a1,-26 # ffffffffc0205830 <default_pmm_manager+0x710>
ffffffffc0203852:	8526                	mv	a0,s1
ffffffffc0203854:	288000ef          	jal	ra,ffffffffc0203adc <memcpy>
    set_proc_name(initproc, "init");

    // ========== 8. 验证初始化结果 ==========
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203858:	00093783          	ld	a5,0(s2)
ffffffffc020385c:	c7e1                	beqz	a5,ffffffffc0203924 <proc_init+0x22e>
ffffffffc020385e:	43dc                	lw	a5,4(a5)
ffffffffc0203860:	e3f1                	bnez	a5,ffffffffc0203924 <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203862:	601c                	ld	a5,0(s0)
ffffffffc0203864:	c3c5                	beqz	a5,ffffffffc0203904 <proc_init+0x20e>
ffffffffc0203866:	43d8                	lw	a4,4(a5)
ffffffffc0203868:	4785                	li	a5,1
ffffffffc020386a:	08f71d63          	bne	a4,a5,ffffffffc0203904 <proc_init+0x20e>
}
ffffffffc020386e:	70a2                	ld	ra,40(sp)
ffffffffc0203870:	7402                	ld	s0,32(sp)
ffffffffc0203872:	64e2                	ld	s1,24(sp)
ffffffffc0203874:	6942                	ld	s2,16(sp)
ffffffffc0203876:	69a2                	ld	s3,8(sp)
ffffffffc0203878:	6145                	addi	sp,sp,48
ffffffffc020387a:	8082                	ret
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
ffffffffc020387c:	77d8                	ld	a4,168(a5)
ffffffffc020387e:	ff09                	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->tf == NULL &&                 // trapframe为空
ffffffffc0203880:	f0099ce3          	bnez	s3,ffffffffc0203798 <proc_init+0xa2>
        idleproc->state == PROC_UNINIT &&       // 状态为未初始化
ffffffffc0203884:	6394                	ld	a3,0(a5)
ffffffffc0203886:	577d                	li	a4,-1
ffffffffc0203888:	1702                	slli	a4,a4,0x20
ffffffffc020388a:	f0e697e3          	bne	a3,a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->pid == -1 &&                  // PID为无效值
ffffffffc020388e:	4798                	lw	a4,8(a5)
ffffffffc0203890:	f00714e3          	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->runs == 0 &&                  // 运行次数为0
ffffffffc0203894:	6b98                	ld	a4,16(a5)
ffffffffc0203896:	f00711e3          	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->need_resched == 0 &&          // 不需要调度
ffffffffc020389a:	5398                	lw	a4,32(a5)
ffffffffc020389c:	2701                	sext.w	a4,a4
        idleproc->kstack == 0 &&                // 内核栈未分配
ffffffffc020389e:	ee071de3          	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->need_resched == 0 &&          // 不需要调度
ffffffffc02038a2:	7798                	ld	a4,40(a5)
ffffffffc02038a4:	ee071ae3          	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->parent == NULL &&             // 无父进程
ffffffffc02038a8:	7b98                	ld	a4,48(a5)
ffffffffc02038aa:	ee0717e3          	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        idleproc->mm == NULL &&                 // 无内存管理结构体
ffffffffc02038ae:	0b07a703          	lw	a4,176(a5)
ffffffffc02038b2:	8d59                	or	a0,a0,a4
ffffffffc02038b4:	0005071b          	sext.w	a4,a0
ffffffffc02038b8:	ee0710e3          	bnez	a4,ffffffffc0203798 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc02038bc:	00002517          	auipc	a0,0x2
ffffffffc02038c0:	f2450513          	addi	a0,a0,-220 # ffffffffc02057e0 <default_pmm_manager+0x6c0>
ffffffffc02038c4:	81dfc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    idleproc->pid = 0;                          // 设置PID为0
ffffffffc02038c8:	00093783          	ld	a5,0(s2)
ffffffffc02038cc:	b5f1                	j	ffffffffc0203798 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02038ce:	f2878793          	addi	a5,a5,-216
ffffffffc02038d2:	bfb9                	j	ffffffffc0203830 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc02038d4:	00002617          	auipc	a2,0x2
ffffffffc02038d8:	ef460613          	addi	a2,a2,-268 # ffffffffc02057c8 <default_pmm_manager+0x6a8>
ffffffffc02038dc:	3cf00593          	li	a1,975
ffffffffc02038e0:	00002517          	auipc	a0,0x2
ffffffffc02038e4:	eb850513          	addi	a0,a0,-328 # ffffffffc0205798 <default_pmm_manager+0x678>
ffffffffc02038e8:	8f7fc0ef          	jal	ra,ffffffffc02001de <__panic>
        panic("create init_main failed.\n");
ffffffffc02038ec:	00002617          	auipc	a2,0x2
ffffffffc02038f0:	f2460613          	addi	a2,a2,-220 # ffffffffc0205810 <default_pmm_manager+0x6f0>
ffffffffc02038f4:	3fc00593          	li	a1,1020
ffffffffc02038f8:	00002517          	auipc	a0,0x2
ffffffffc02038fc:	ea050513          	addi	a0,a0,-352 # ffffffffc0205798 <default_pmm_manager+0x678>
ffffffffc0203900:	8dffc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203904:	00002697          	auipc	a3,0x2
ffffffffc0203908:	f5c68693          	addi	a3,a3,-164 # ffffffffc0205860 <default_pmm_manager+0x740>
ffffffffc020390c:	00001617          	auipc	a2,0x1
ffffffffc0203910:	15c60613          	addi	a2,a2,348 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203914:	40500593          	li	a1,1029
ffffffffc0203918:	00002517          	auipc	a0,0x2
ffffffffc020391c:	e8050513          	addi	a0,a0,-384 # ffffffffc0205798 <default_pmm_manager+0x678>
ffffffffc0203920:	8bffc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203924:	00002697          	auipc	a3,0x2
ffffffffc0203928:	f1468693          	addi	a3,a3,-236 # ffffffffc0205838 <default_pmm_manager+0x718>
ffffffffc020392c:	00001617          	auipc	a2,0x1
ffffffffc0203930:	13c60613          	addi	a2,a2,316 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203934:	40400593          	li	a1,1028
ffffffffc0203938:	00002517          	auipc	a0,0x2
ffffffffc020393c:	e6050513          	addi	a0,a0,-416 # ffffffffc0205798 <default_pmm_manager+0x678>
ffffffffc0203940:	89ffc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203944 <cpu_idle>:
 * 3. 没有其他就绪进程时，idle进程会保持运行
 *
 * 这确保了系统在没有其他任务时不会"死机"，而是让CPU执行空闲循环。
 * ===================================================================== */
void cpu_idle(void)
{
ffffffffc0203944:	1141                	addi	sp,sp,-16
ffffffffc0203946:	e022                	sd	s0,0(sp)
ffffffffc0203948:	e406                	sd	ra,8(sp)
ffffffffc020394a:	0000a417          	auipc	s0,0xa
ffffffffc020394e:	b7e40413          	addi	s0,s0,-1154 # ffffffffc020d4c8 <current>
    while (1)  // 无限循环
    {
        // 检查是否需要重新调度
        if (current->need_resched)
ffffffffc0203952:	6018                	ld	a4,0(s0)
ffffffffc0203954:	531c                	lw	a5,32(a4)
ffffffffc0203956:	2781                	sext.w	a5,a5
ffffffffc0203958:	dff5                	beqz	a5,ffffffffc0203954 <cpu_idle+0x10>
        {
            // 调用调度器进行进程切换
            schedule();
ffffffffc020395a:	03a000ef          	jal	ra,ffffffffc0203994 <schedule>
ffffffffc020395e:	bfd5                	j	ffffffffc0203952 <cpu_idle+0xe>

ffffffffc0203960 <wakeup_proc>:
 * ===================================================================== */
void
wakeup_proc(struct proc_struct *proc) {
    // ========== 安全检查 ==========
    // 确保进程处于合理的状态：不能是僵尸进程，也不能是已在运行的进程
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203960:	411c                	lw	a5,0(a0)
ffffffffc0203962:	4705                	li	a4,1
ffffffffc0203964:	37f9                	addiw	a5,a5,-2
ffffffffc0203966:	00f77563          	bgeu	a4,a5,ffffffffc0203970 <wakeup_proc+0x10>

    // ========== 状态转换 ==========
    // 将进程状态从睡眠转换为可运行，等待调度器选中
    proc->state = PROC_RUNNABLE;
ffffffffc020396a:	4789                	li	a5,2
ffffffffc020396c:	c11c                	sw	a5,0(a0)
ffffffffc020396e:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0203970:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203972:	00002697          	auipc	a3,0x2
ffffffffc0203976:	f1668693          	addi	a3,a3,-234 # ffffffffc0205888 <default_pmm_manager+0x768>
ffffffffc020397a:	00001617          	auipc	a2,0x1
ffffffffc020397e:	0ee60613          	addi	a2,a2,238 # ffffffffc0204a68 <commands+0x8c0>
ffffffffc0203982:	05300593          	li	a1,83
ffffffffc0203986:	00002517          	auipc	a0,0x2
ffffffffc020398a:	f4250513          	addi	a0,a0,-190 # ffffffffc02058c8 <default_pmm_manager+0x7a8>
wakeup_proc(struct proc_struct *proc) {
ffffffffc020398e:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203990:	84ffc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203994 <schedule>:
 * 5. schedule()选择下一个进程，完成切换
 *
 * 这种设计实现了"抢占式多任务"：进程不能无限占用CPU。
 * ===================================================================== */
void
schedule(void) {
ffffffffc0203994:	1141                	addi	sp,sp,-16
ffffffffc0203996:	e406                	sd	ra,8(sp)
ffffffffc0203998:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020399a:	100027f3          	csrr	a5,sstatus
ffffffffc020399e:	8b89                	andi	a5,a5,2
ffffffffc02039a0:	4401                	li	s0,0
ffffffffc02039a2:	efbd                	bnez	a5,ffffffffc0203a20 <schedule+0x8c>
    // 调度是关键操作，不能被中断打断，否则可能导致数据结构不一致
    local_intr_save(intr_flag);
    {
        // ========== 2. 清除调度请求标志 ==========
        // 当前进程的调度请求已得到处理，重置标志
        current->need_resched = 0;
ffffffffc02039a4:	0000a897          	auipc	a7,0xa
ffffffffc02039a8:	b248b883          	ld	a7,-1244(a7) # ffffffffc020d4c8 <current>
ffffffffc02039ac:	0208a023          	sw	zero,32(a7)

        // ========== 3. 确定搜索起始点 ==========
        // 实现轮转调度的关键：从当前进程之后开始查找
        // 如果当前是idle进程，从链表头开始（避免idle进程连续执行）
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02039b0:	0000a517          	auipc	a0,0xa
ffffffffc02039b4:	b2053503          	ld	a0,-1248(a0) # ffffffffc020d4d0 <idleproc>
ffffffffc02039b8:	04a88e63          	beq	a7,a0,ffffffffc0203a14 <schedule+0x80>
ffffffffc02039bc:	0c888693          	addi	a3,a7,200
ffffffffc02039c0:	0000a617          	auipc	a2,0xa
ffffffffc02039c4:	a9860613          	addi	a2,a2,-1384 # ffffffffc020d458 <proc_list>
        le = last;
ffffffffc02039c8:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;   // 选中的下一个要执行的进程
ffffffffc02039ca:	4581                	li	a1,0
            // 获取链表中的下一个节点
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);

                // 检查进程状态：只有PROC_RUNNABLE的进程才能被调度
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039cc:	4809                	li	a6,2
ffffffffc02039ce:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02039d0:	00c78863          	beq	a5,a2,ffffffffc02039e0 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039d4:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02039d8:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02039dc:	03070163          	beq	a4,a6,ffffffffc02039fe <schedule+0x6a>
                    break;  // 找到目标进程，跳出循环
                }
            }
        } while (le != last);  // 确保只遍历一圈，避免无限循环
ffffffffc02039e0:	fef697e3          	bne	a3,a5,ffffffffc02039ce <schedule+0x3a>

        // ========== 5. 容错处理：确保始终有进程可执行 ==========
        // 如果没有找到可运行进程（理论上不太可能），选择idle进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02039e4:	ed89                	bnez	a1,ffffffffc02039fe <schedule+0x6a>
            next = idleproc;  // idle进程始终可用，作为最后的fallback
        }

        // ========== 6. 更新进程运行统计 ==========
        // 记录该进程被调度的次数，用于性能监控和调试
        next->runs ++;
ffffffffc02039e6:	451c                	lw	a5,8(a0)
ffffffffc02039e8:	2785                	addiw	a5,a5,1
ffffffffc02039ea:	c51c                	sw	a5,8(a0)

        // ========== 7. 执行进程切换 ==========
        if (next != current) {
ffffffffc02039ec:	00a88463          	beq	a7,a0,ffffffffc02039f4 <schedule+0x60>
            // 需要切换到不同的进程
            proc_run(next);
ffffffffc02039f0:	9d5ff0ef          	jal	ra,ffffffffc02033c4 <proc_run>
    if (flag) {
ffffffffc02039f4:	e819                	bnez	s0,ffffffffc0203a0a <schedule+0x76>
        // 如果选中进程就是当前进程，继续执行（不需要切换）
    }
    // ========== 8. 恢复中断状态 ==========
    // 调度完成，重新允许中断
    local_intr_restore(intr_flag);
}
ffffffffc02039f6:	60a2                	ld	ra,8(sp)
ffffffffc02039f8:	6402                	ld	s0,0(sp)
ffffffffc02039fa:	0141                	addi	sp,sp,16
ffffffffc02039fc:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02039fe:	4198                	lw	a4,0(a1)
ffffffffc0203a00:	4789                	li	a5,2
ffffffffc0203a02:	fef712e3          	bne	a4,a5,ffffffffc02039e6 <schedule+0x52>
ffffffffc0203a06:	852e                	mv	a0,a1
ffffffffc0203a08:	bff9                	j	ffffffffc02039e6 <schedule+0x52>
}
ffffffffc0203a0a:	6402                	ld	s0,0(sp)
ffffffffc0203a0c:	60a2                	ld	ra,8(sp)
ffffffffc0203a0e:	0141                	addi	sp,sp,16
        intr_enable();   // 开启中断
ffffffffc0203a10:	f21fc06f          	j	ffffffffc0200930 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203a14:	0000a617          	auipc	a2,0xa
ffffffffc0203a18:	a4460613          	addi	a2,a2,-1468 # ffffffffc020d458 <proc_list>
ffffffffc0203a1c:	86b2                	mv	a3,a2
ffffffffc0203a1e:	b76d                	j	ffffffffc02039c8 <schedule+0x34>
        intr_disable();  // 关闭中断
ffffffffc0203a20:	f17fc0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;        // 返回true表示原本开启
ffffffffc0203a24:	4405                	li	s0,1
ffffffffc0203a26:	bfbd                	j	ffffffffc02039a4 <schedule+0x10>

ffffffffc0203a28 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203a28:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203a2c:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203a2e:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203a30:	cb81                	beqz	a5,ffffffffc0203a40 <strlen+0x18>
        cnt ++;
ffffffffc0203a32:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203a34:	00a707b3          	add	a5,a4,a0
ffffffffc0203a38:	0007c783          	lbu	a5,0(a5)
ffffffffc0203a3c:	fbfd                	bnez	a5,ffffffffc0203a32 <strlen+0xa>
ffffffffc0203a3e:	8082                	ret
    }
    return cnt;
}
ffffffffc0203a40:	8082                	ret

ffffffffc0203a42 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203a42:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a44:	e589                	bnez	a1,ffffffffc0203a4e <strnlen+0xc>
ffffffffc0203a46:	a811                	j	ffffffffc0203a5a <strnlen+0x18>
        cnt ++;
ffffffffc0203a48:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a4a:	00f58863          	beq	a1,a5,ffffffffc0203a5a <strnlen+0x18>
ffffffffc0203a4e:	00f50733          	add	a4,a0,a5
ffffffffc0203a52:	00074703          	lbu	a4,0(a4)
ffffffffc0203a56:	fb6d                	bnez	a4,ffffffffc0203a48 <strnlen+0x6>
ffffffffc0203a58:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203a5a:	852e                	mv	a0,a1
ffffffffc0203a5c:	8082                	ret

ffffffffc0203a5e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203a5e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203a60:	0005c703          	lbu	a4,0(a1)
ffffffffc0203a64:	0785                	addi	a5,a5,1
ffffffffc0203a66:	0585                	addi	a1,a1,1
ffffffffc0203a68:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203a6c:	fb75                	bnez	a4,ffffffffc0203a60 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203a6e:	8082                	ret

ffffffffc0203a70 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a70:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a74:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a78:	cb89                	beqz	a5,ffffffffc0203a8a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203a7a:	0505                	addi	a0,a0,1
ffffffffc0203a7c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a7e:	fee789e3          	beq	a5,a4,ffffffffc0203a70 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a82:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203a86:	9d19                	subw	a0,a0,a4
ffffffffc0203a88:	8082                	ret
ffffffffc0203a8a:	4501                	li	a0,0
ffffffffc0203a8c:	bfed                	j	ffffffffc0203a86 <strcmp+0x16>

ffffffffc0203a8e <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203a8e:	c20d                	beqz	a2,ffffffffc0203ab0 <strncmp+0x22>
ffffffffc0203a90:	962e                	add	a2,a2,a1
ffffffffc0203a92:	a031                	j	ffffffffc0203a9e <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0203a94:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203a96:	00e79a63          	bne	a5,a4,ffffffffc0203aaa <strncmp+0x1c>
ffffffffc0203a9a:	00b60b63          	beq	a2,a1,ffffffffc0203ab0 <strncmp+0x22>
ffffffffc0203a9e:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0203aa2:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203aa4:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203aa8:	f7f5                	bnez	a5,ffffffffc0203a94 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203aaa:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0203aae:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ab0:	4501                	li	a0,0
ffffffffc0203ab2:	8082                	ret

ffffffffc0203ab4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203ab4:	00054783          	lbu	a5,0(a0)
ffffffffc0203ab8:	c799                	beqz	a5,ffffffffc0203ac6 <strchr+0x12>
        if (*s == c) {
ffffffffc0203aba:	00f58763          	beq	a1,a5,ffffffffc0203ac8 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203abe:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203ac2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203ac4:	fbfd                	bnez	a5,ffffffffc0203aba <strchr+0x6>
    }
    return NULL;
ffffffffc0203ac6:	4501                	li	a0,0
}
ffffffffc0203ac8:	8082                	ret

ffffffffc0203aca <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203aca:	ca01                	beqz	a2,ffffffffc0203ada <memset+0x10>
ffffffffc0203acc:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203ace:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203ad0:	0785                	addi	a5,a5,1
ffffffffc0203ad2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203ad6:	fec79de3          	bne	a5,a2,ffffffffc0203ad0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203ada:	8082                	ret

ffffffffc0203adc <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203adc:	ca19                	beqz	a2,ffffffffc0203af2 <memcpy+0x16>
ffffffffc0203ade:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203ae0:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203ae2:	0005c703          	lbu	a4,0(a1)
ffffffffc0203ae6:	0585                	addi	a1,a1,1
ffffffffc0203ae8:	0785                	addi	a5,a5,1
ffffffffc0203aea:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203aee:	fec59ae3          	bne	a1,a2,ffffffffc0203ae2 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203af2:	8082                	ret

ffffffffc0203af4 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0203af4:	c205                	beqz	a2,ffffffffc0203b14 <memcmp+0x20>
ffffffffc0203af6:	962e                	add	a2,a2,a1
ffffffffc0203af8:	a019                	j	ffffffffc0203afe <memcmp+0xa>
ffffffffc0203afa:	00c58d63          	beq	a1,a2,ffffffffc0203b14 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0203afe:	00054783          	lbu	a5,0(a0)
ffffffffc0203b02:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0203b06:	0505                	addi	a0,a0,1
ffffffffc0203b08:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0203b0a:	fee788e3          	beq	a5,a4,ffffffffc0203afa <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203b0e:	40e7853b          	subw	a0,a5,a4
ffffffffc0203b12:	8082                	ret
    }
    return 0;
ffffffffc0203b14:	4501                	li	a0,0
}
ffffffffc0203b16:	8082                	ret

ffffffffc0203b18 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203b18:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b1c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203b1e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b22:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203b24:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203b28:	f022                	sd	s0,32(sp)
ffffffffc0203b2a:	ec26                	sd	s1,24(sp)
ffffffffc0203b2c:	e84a                	sd	s2,16(sp)
ffffffffc0203b2e:	f406                	sd	ra,40(sp)
ffffffffc0203b30:	e44e                	sd	s3,8(sp)
ffffffffc0203b32:	84aa                	mv	s1,a0
ffffffffc0203b34:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203b36:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203b3a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203b3c:	03067e63          	bgeu	a2,a6,ffffffffc0203b78 <printnum+0x60>
ffffffffc0203b40:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203b42:	00805763          	blez	s0,ffffffffc0203b50 <printnum+0x38>
ffffffffc0203b46:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203b48:	85ca                	mv	a1,s2
ffffffffc0203b4a:	854e                	mv	a0,s3
ffffffffc0203b4c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203b4e:	fc65                	bnez	s0,ffffffffc0203b46 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b50:	1a02                	slli	s4,s4,0x20
ffffffffc0203b52:	00002797          	auipc	a5,0x2
ffffffffc0203b56:	d8e78793          	addi	a5,a5,-626 # ffffffffc02058e0 <default_pmm_manager+0x7c0>
ffffffffc0203b5a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203b5e:	9a3e                	add	s4,s4,a5
}
ffffffffc0203b60:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b62:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203b66:	70a2                	ld	ra,40(sp)
ffffffffc0203b68:	69a2                	ld	s3,8(sp)
ffffffffc0203b6a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b6c:	85ca                	mv	a1,s2
ffffffffc0203b6e:	87a6                	mv	a5,s1
}
ffffffffc0203b70:	6942                	ld	s2,16(sp)
ffffffffc0203b72:	64e2                	ld	s1,24(sp)
ffffffffc0203b74:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b76:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203b78:	03065633          	divu	a2,a2,a6
ffffffffc0203b7c:	8722                	mv	a4,s0
ffffffffc0203b7e:	f9bff0ef          	jal	ra,ffffffffc0203b18 <printnum>
ffffffffc0203b82:	b7f9                	j	ffffffffc0203b50 <printnum+0x38>

ffffffffc0203b84 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203b84:	7119                	addi	sp,sp,-128
ffffffffc0203b86:	f4a6                	sd	s1,104(sp)
ffffffffc0203b88:	f0ca                	sd	s2,96(sp)
ffffffffc0203b8a:	ecce                	sd	s3,88(sp)
ffffffffc0203b8c:	e8d2                	sd	s4,80(sp)
ffffffffc0203b8e:	e4d6                	sd	s5,72(sp)
ffffffffc0203b90:	e0da                	sd	s6,64(sp)
ffffffffc0203b92:	fc5e                	sd	s7,56(sp)
ffffffffc0203b94:	f06a                	sd	s10,32(sp)
ffffffffc0203b96:	fc86                	sd	ra,120(sp)
ffffffffc0203b98:	f8a2                	sd	s0,112(sp)
ffffffffc0203b9a:	f862                	sd	s8,48(sp)
ffffffffc0203b9c:	f466                	sd	s9,40(sp)
ffffffffc0203b9e:	ec6e                	sd	s11,24(sp)
ffffffffc0203ba0:	892a                	mv	s2,a0
ffffffffc0203ba2:	84ae                	mv	s1,a1
ffffffffc0203ba4:	8d32                	mv	s10,a2
ffffffffc0203ba6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ba8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203bac:	5b7d                	li	s6,-1
ffffffffc0203bae:	00002a97          	auipc	s5,0x2
ffffffffc0203bb2:	d5ea8a93          	addi	s5,s5,-674 # ffffffffc020590c <default_pmm_manager+0x7ec>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203bb6:	00002b97          	auipc	s7,0x2
ffffffffc0203bba:	f32b8b93          	addi	s7,s7,-206 # ffffffffc0205ae8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bbe:	000d4503          	lbu	a0,0(s10)
ffffffffc0203bc2:	001d0413          	addi	s0,s10,1
ffffffffc0203bc6:	01350a63          	beq	a0,s3,ffffffffc0203bda <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203bca:	c121                	beqz	a0,ffffffffc0203c0a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203bcc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bce:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203bd0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203bd2:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203bd6:	ff351ae3          	bne	a0,s3,ffffffffc0203bca <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bda:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203bde:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203be2:	4c81                	li	s9,0
ffffffffc0203be4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203be6:	5c7d                	li	s8,-1
ffffffffc0203be8:	5dfd                	li	s11,-1
ffffffffc0203bea:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203bee:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bf0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203bf4:	0ff5f593          	zext.b	a1,a1
ffffffffc0203bf8:	00140d13          	addi	s10,s0,1
ffffffffc0203bfc:	04b56263          	bltu	a0,a1,ffffffffc0203c40 <vprintfmt+0xbc>
ffffffffc0203c00:	058a                	slli	a1,a1,0x2
ffffffffc0203c02:	95d6                	add	a1,a1,s5
ffffffffc0203c04:	4194                	lw	a3,0(a1)
ffffffffc0203c06:	96d6                	add	a3,a3,s5
ffffffffc0203c08:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203c0a:	70e6                	ld	ra,120(sp)
ffffffffc0203c0c:	7446                	ld	s0,112(sp)
ffffffffc0203c0e:	74a6                	ld	s1,104(sp)
ffffffffc0203c10:	7906                	ld	s2,96(sp)
ffffffffc0203c12:	69e6                	ld	s3,88(sp)
ffffffffc0203c14:	6a46                	ld	s4,80(sp)
ffffffffc0203c16:	6aa6                	ld	s5,72(sp)
ffffffffc0203c18:	6b06                	ld	s6,64(sp)
ffffffffc0203c1a:	7be2                	ld	s7,56(sp)
ffffffffc0203c1c:	7c42                	ld	s8,48(sp)
ffffffffc0203c1e:	7ca2                	ld	s9,40(sp)
ffffffffc0203c20:	7d02                	ld	s10,32(sp)
ffffffffc0203c22:	6de2                	ld	s11,24(sp)
ffffffffc0203c24:	6109                	addi	sp,sp,128
ffffffffc0203c26:	8082                	ret
            padc = '0';
ffffffffc0203c28:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203c2a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c2e:	846a                	mv	s0,s10
ffffffffc0203c30:	00140d13          	addi	s10,s0,1
ffffffffc0203c34:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203c38:	0ff5f593          	zext.b	a1,a1
ffffffffc0203c3c:	fcb572e3          	bgeu	a0,a1,ffffffffc0203c00 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203c40:	85a6                	mv	a1,s1
ffffffffc0203c42:	02500513          	li	a0,37
ffffffffc0203c46:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203c48:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203c4c:	8d22                	mv	s10,s0
ffffffffc0203c4e:	f73788e3          	beq	a5,s3,ffffffffc0203bbe <vprintfmt+0x3a>
ffffffffc0203c52:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203c56:	1d7d                	addi	s10,s10,-1
ffffffffc0203c58:	ff379de3          	bne	a5,s3,ffffffffc0203c52 <vprintfmt+0xce>
ffffffffc0203c5c:	b78d                	j	ffffffffc0203bbe <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203c5e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203c62:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c66:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203c68:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203c6c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203c70:	02d86463          	bltu	a6,a3,ffffffffc0203c98 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203c74:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203c78:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203c7c:	0186873b          	addw	a4,a3,s8
ffffffffc0203c80:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203c84:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203c86:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203c8a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203c8c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203c90:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203c94:	fed870e3          	bgeu	a6,a3,ffffffffc0203c74 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0203c98:	f40ddce3          	bgez	s11,ffffffffc0203bf0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0203c9c:	8de2                	mv	s11,s8
ffffffffc0203c9e:	5c7d                	li	s8,-1
ffffffffc0203ca0:	bf81                	j	ffffffffc0203bf0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0203ca2:	fffdc693          	not	a3,s11
ffffffffc0203ca6:	96fd                	srai	a3,a3,0x3f
ffffffffc0203ca8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cac:	00144603          	lbu	a2,1(s0)
ffffffffc0203cb0:	2d81                	sext.w	s11,s11
ffffffffc0203cb2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203cb4:	bf35                	j	ffffffffc0203bf0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0203cb6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cba:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203cbe:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cc0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0203cc2:	bfd9                	j	ffffffffc0203c98 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0203cc4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203cc6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203cca:	01174463          	blt	a4,a7,ffffffffc0203cd2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0203cce:	1a088e63          	beqz	a7,ffffffffc0203e8a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0203cd2:	000a3603          	ld	a2,0(s4)
ffffffffc0203cd6:	46c1                	li	a3,16
ffffffffc0203cd8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203cda:	2781                	sext.w	a5,a5
ffffffffc0203cdc:	876e                	mv	a4,s11
ffffffffc0203cde:	85a6                	mv	a1,s1
ffffffffc0203ce0:	854a                	mv	a0,s2
ffffffffc0203ce2:	e37ff0ef          	jal	ra,ffffffffc0203b18 <printnum>
            break;
ffffffffc0203ce6:	bde1                	j	ffffffffc0203bbe <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ce8:	000a2503          	lw	a0,0(s4)
ffffffffc0203cec:	85a6                	mv	a1,s1
ffffffffc0203cee:	0a21                	addi	s4,s4,8
ffffffffc0203cf0:	9902                	jalr	s2
            break;
ffffffffc0203cf2:	b5f1                	j	ffffffffc0203bbe <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203cf4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203cf6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203cfa:	01174463          	blt	a4,a7,ffffffffc0203d02 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203cfe:	18088163          	beqz	a7,ffffffffc0203e80 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203d02:	000a3603          	ld	a2,0(s4)
ffffffffc0203d06:	46a9                	li	a3,10
ffffffffc0203d08:	8a2e                	mv	s4,a1
ffffffffc0203d0a:	bfc1                	j	ffffffffc0203cda <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d0c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203d10:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d12:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d14:	bdf1                	j	ffffffffc0203bf0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203d16:	85a6                	mv	a1,s1
ffffffffc0203d18:	02500513          	li	a0,37
ffffffffc0203d1c:	9902                	jalr	s2
            break;
ffffffffc0203d1e:	b545                	j	ffffffffc0203bbe <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d20:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0203d24:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d26:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d28:	b5e1                	j	ffffffffc0203bf0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0203d2a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203d2c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203d30:	01174463          	blt	a4,a7,ffffffffc0203d38 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0203d34:	14088163          	beqz	a7,ffffffffc0203e76 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0203d38:	000a3603          	ld	a2,0(s4)
ffffffffc0203d3c:	46a1                	li	a3,8
ffffffffc0203d3e:	8a2e                	mv	s4,a1
ffffffffc0203d40:	bf69                	j	ffffffffc0203cda <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0203d42:	03000513          	li	a0,48
ffffffffc0203d46:	85a6                	mv	a1,s1
ffffffffc0203d48:	e03e                	sd	a5,0(sp)
ffffffffc0203d4a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203d4c:	85a6                	mv	a1,s1
ffffffffc0203d4e:	07800513          	li	a0,120
ffffffffc0203d52:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d54:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203d56:	6782                	ld	a5,0(sp)
ffffffffc0203d58:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d5a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0203d5e:	bfb5                	j	ffffffffc0203cda <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d60:	000a3403          	ld	s0,0(s4)
ffffffffc0203d64:	008a0713          	addi	a4,s4,8
ffffffffc0203d68:	e03a                	sd	a4,0(sp)
ffffffffc0203d6a:	14040263          	beqz	s0,ffffffffc0203eae <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0203d6e:	0fb05763          	blez	s11,ffffffffc0203e5c <vprintfmt+0x2d8>
ffffffffc0203d72:	02d00693          	li	a3,45
ffffffffc0203d76:	0cd79163          	bne	a5,a3,ffffffffc0203e38 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d7a:	00044783          	lbu	a5,0(s0)
ffffffffc0203d7e:	0007851b          	sext.w	a0,a5
ffffffffc0203d82:	cf85                	beqz	a5,ffffffffc0203dba <vprintfmt+0x236>
ffffffffc0203d84:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d88:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d8c:	000c4563          	bltz	s8,ffffffffc0203d96 <vprintfmt+0x212>
ffffffffc0203d90:	3c7d                	addiw	s8,s8,-1
ffffffffc0203d92:	036c0263          	beq	s8,s6,ffffffffc0203db6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0203d96:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d98:	0e0c8e63          	beqz	s9,ffffffffc0203e94 <vprintfmt+0x310>
ffffffffc0203d9c:	3781                	addiw	a5,a5,-32
ffffffffc0203d9e:	0ef47b63          	bgeu	s0,a5,ffffffffc0203e94 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0203da2:	03f00513          	li	a0,63
ffffffffc0203da6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203da8:	000a4783          	lbu	a5,0(s4)
ffffffffc0203dac:	3dfd                	addiw	s11,s11,-1
ffffffffc0203dae:	0a05                	addi	s4,s4,1
ffffffffc0203db0:	0007851b          	sext.w	a0,a5
ffffffffc0203db4:	ffe1                	bnez	a5,ffffffffc0203d8c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0203db6:	01b05963          	blez	s11,ffffffffc0203dc8 <vprintfmt+0x244>
ffffffffc0203dba:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203dbc:	85a6                	mv	a1,s1
ffffffffc0203dbe:	02000513          	li	a0,32
ffffffffc0203dc2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203dc4:	fe0d9be3          	bnez	s11,ffffffffc0203dba <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203dc8:	6a02                	ld	s4,0(sp)
ffffffffc0203dca:	bbd5                	j	ffffffffc0203bbe <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203dcc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203dce:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0203dd2:	01174463          	blt	a4,a7,ffffffffc0203dda <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0203dd6:	08088d63          	beqz	a7,ffffffffc0203e70 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0203dda:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203dde:	0a044d63          	bltz	s0,ffffffffc0203e98 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0203de2:	8622                	mv	a2,s0
ffffffffc0203de4:	8a66                	mv	s4,s9
ffffffffc0203de6:	46a9                	li	a3,10
ffffffffc0203de8:	bdcd                	j	ffffffffc0203cda <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0203dea:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203dee:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203df0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203df2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203df6:	8fb5                	xor	a5,a5,a3
ffffffffc0203df8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203dfc:	02d74163          	blt	a4,a3,ffffffffc0203e1e <vprintfmt+0x29a>
ffffffffc0203e00:	00369793          	slli	a5,a3,0x3
ffffffffc0203e04:	97de                	add	a5,a5,s7
ffffffffc0203e06:	639c                	ld	a5,0(a5)
ffffffffc0203e08:	cb99                	beqz	a5,ffffffffc0203e1e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203e0a:	86be                	mv	a3,a5
ffffffffc0203e0c:	00000617          	auipc	a2,0x0
ffffffffc0203e10:	13c60613          	addi	a2,a2,316 # ffffffffc0203f48 <etext+0x2c>
ffffffffc0203e14:	85a6                	mv	a1,s1
ffffffffc0203e16:	854a                	mv	a0,s2
ffffffffc0203e18:	0ce000ef          	jal	ra,ffffffffc0203ee6 <printfmt>
ffffffffc0203e1c:	b34d                	j	ffffffffc0203bbe <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203e1e:	00002617          	auipc	a2,0x2
ffffffffc0203e22:	ae260613          	addi	a2,a2,-1310 # ffffffffc0205900 <default_pmm_manager+0x7e0>
ffffffffc0203e26:	85a6                	mv	a1,s1
ffffffffc0203e28:	854a                	mv	a0,s2
ffffffffc0203e2a:	0bc000ef          	jal	ra,ffffffffc0203ee6 <printfmt>
ffffffffc0203e2e:	bb41                	j	ffffffffc0203bbe <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203e30:	00002417          	auipc	s0,0x2
ffffffffc0203e34:	ac840413          	addi	s0,s0,-1336 # ffffffffc02058f8 <default_pmm_manager+0x7d8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e38:	85e2                	mv	a1,s8
ffffffffc0203e3a:	8522                	mv	a0,s0
ffffffffc0203e3c:	e43e                	sd	a5,8(sp)
ffffffffc0203e3e:	c05ff0ef          	jal	ra,ffffffffc0203a42 <strnlen>
ffffffffc0203e42:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203e46:	01b05b63          	blez	s11,ffffffffc0203e5c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0203e4a:	67a2                	ld	a5,8(sp)
ffffffffc0203e4c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e50:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203e52:	85a6                	mv	a1,s1
ffffffffc0203e54:	8552                	mv	a0,s4
ffffffffc0203e56:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e58:	fe0d9ce3          	bnez	s11,ffffffffc0203e50 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e5c:	00044783          	lbu	a5,0(s0)
ffffffffc0203e60:	00140a13          	addi	s4,s0,1
ffffffffc0203e64:	0007851b          	sext.w	a0,a5
ffffffffc0203e68:	d3a5                	beqz	a5,ffffffffc0203dc8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e6a:	05e00413          	li	s0,94
ffffffffc0203e6e:	bf39                	j	ffffffffc0203d8c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0203e70:	000a2403          	lw	s0,0(s4)
ffffffffc0203e74:	b7ad                	j	ffffffffc0203dde <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0203e76:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e7a:	46a1                	li	a3,8
ffffffffc0203e7c:	8a2e                	mv	s4,a1
ffffffffc0203e7e:	bdb1                	j	ffffffffc0203cda <vprintfmt+0x156>
ffffffffc0203e80:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e84:	46a9                	li	a3,10
ffffffffc0203e86:	8a2e                	mv	s4,a1
ffffffffc0203e88:	bd89                	j	ffffffffc0203cda <vprintfmt+0x156>
ffffffffc0203e8a:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e8e:	46c1                	li	a3,16
ffffffffc0203e90:	8a2e                	mv	s4,a1
ffffffffc0203e92:	b5a1                	j	ffffffffc0203cda <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0203e94:	9902                	jalr	s2
ffffffffc0203e96:	bf09                	j	ffffffffc0203da8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0203e98:	85a6                	mv	a1,s1
ffffffffc0203e9a:	02d00513          	li	a0,45
ffffffffc0203e9e:	e03e                	sd	a5,0(sp)
ffffffffc0203ea0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203ea2:	6782                	ld	a5,0(sp)
ffffffffc0203ea4:	8a66                	mv	s4,s9
ffffffffc0203ea6:	40800633          	neg	a2,s0
ffffffffc0203eaa:	46a9                	li	a3,10
ffffffffc0203eac:	b53d                	j	ffffffffc0203cda <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0203eae:	03b05163          	blez	s11,ffffffffc0203ed0 <vprintfmt+0x34c>
ffffffffc0203eb2:	02d00693          	li	a3,45
ffffffffc0203eb6:	f6d79de3          	bne	a5,a3,ffffffffc0203e30 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0203eba:	00002417          	auipc	s0,0x2
ffffffffc0203ebe:	a3e40413          	addi	s0,s0,-1474 # ffffffffc02058f8 <default_pmm_manager+0x7d8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ec2:	02800793          	li	a5,40
ffffffffc0203ec6:	02800513          	li	a0,40
ffffffffc0203eca:	00140a13          	addi	s4,s0,1
ffffffffc0203ece:	bd6d                	j	ffffffffc0203d88 <vprintfmt+0x204>
ffffffffc0203ed0:	00002a17          	auipc	s4,0x2
ffffffffc0203ed4:	a29a0a13          	addi	s4,s4,-1495 # ffffffffc02058f9 <default_pmm_manager+0x7d9>
ffffffffc0203ed8:	02800513          	li	a0,40
ffffffffc0203edc:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203ee0:	05e00413          	li	s0,94
ffffffffc0203ee4:	b565                	j	ffffffffc0203d8c <vprintfmt+0x208>

ffffffffc0203ee6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ee6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203ee8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203eec:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203eee:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ef0:	ec06                	sd	ra,24(sp)
ffffffffc0203ef2:	f83a                	sd	a4,48(sp)
ffffffffc0203ef4:	fc3e                	sd	a5,56(sp)
ffffffffc0203ef6:	e0c2                	sd	a6,64(sp)
ffffffffc0203ef8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203efa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203efc:	c89ff0ef          	jal	ra,ffffffffc0203b84 <vprintfmt>
}
ffffffffc0203f00:	60e2                	ld	ra,24(sp)
ffffffffc0203f02:	6161                	addi	sp,sp,80
ffffffffc0203f04:	8082                	ret

ffffffffc0203f06 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0203f06:	9e3707b7          	lui	a5,0x9e370
ffffffffc0203f0a:	2785                	addiw	a5,a5,1
ffffffffc0203f0c:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0203f10:	02000793          	li	a5,32
ffffffffc0203f14:	9f8d                	subw	a5,a5,a1
}
ffffffffc0203f16:	00f5553b          	srlw	a0,a0,a5
ffffffffc0203f1a:	8082                	ret
