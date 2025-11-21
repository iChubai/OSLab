
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
ffffffffc0200062:	221030ef          	jal	ra,ffffffffc0203a82 <memset>
    dtb_init();
ffffffffc0200066:	452000ef          	jal	ra,ffffffffc02004b8 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	053000ef          	jal	ra,ffffffffc02008bc <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	e6a58593          	addi	a1,a1,-406 # ffffffffc0203ed8 <etext+0x4>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	e8250513          	addi	a0,a0,-382 # ffffffffc0203ef8 <etext+0x24>
ffffffffc020007e:	062000ef          	jal	ra,ffffffffc02000e0 <cprintf>

    print_kerninfo();
ffffffffc0200082:	1b8000ef          	jal	ra,ffffffffc020023a <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	552020ef          	jal	ra,ffffffffc02025d8 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	0a5000ef          	jal	ra,ffffffffc020092e <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	0af000ef          	jal	ra,ffffffffc020093c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	691000ef          	jal	ra,ffffffffc0200f22 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	618030ef          	jal	ra,ffffffffc02036ae <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	7ce000ef          	jal	ra,ffffffffc0200868 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	093000ef          	jal	ra,ffffffffc0200930 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	05b030ef          	jal	ra,ffffffffc02038fc <cpu_idle>

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
ffffffffc02000d4:	269030ef          	jal	ra,ffffffffc0203b3c <vprintfmt>
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
ffffffffc020010a:	233030ef          	jal	ra,ffffffffc0203b3c <vprintfmt>
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
ffffffffc0200144:	dc050513          	addi	a0,a0,-576 # ffffffffc0203f00 <etext+0x2c>
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
ffffffffc0200210:	cfc50513          	addi	a0,a0,-772 # ffffffffc0203f08 <etext+0x34>
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
ffffffffc0200226:	23e50513          	addi	a0,a0,574 # ffffffffc0205460 <default_pmm_manager+0x440>
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
ffffffffc0200240:	cec50513          	addi	a0,a0,-788 # ffffffffc0203f28 <etext+0x54>
{
ffffffffc0200244:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200246:	e9bff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020024a:	00000597          	auipc	a1,0x0
ffffffffc020024e:	e0058593          	addi	a1,a1,-512 # ffffffffc020004a <kern_init>
ffffffffc0200252:	00004517          	auipc	a0,0x4
ffffffffc0200256:	cf650513          	addi	a0,a0,-778 # ffffffffc0203f48 <etext+0x74>
ffffffffc020025a:	e87ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020025e:	00004597          	auipc	a1,0x4
ffffffffc0200262:	c7658593          	addi	a1,a1,-906 # ffffffffc0203ed4 <etext>
ffffffffc0200266:	00004517          	auipc	a0,0x4
ffffffffc020026a:	d0250513          	addi	a0,a0,-766 # ffffffffc0203f68 <etext+0x94>
ffffffffc020026e:	e73ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200272:	00009597          	auipc	a1,0x9
ffffffffc0200276:	dbe58593          	addi	a1,a1,-578 # ffffffffc0209030 <buf>
ffffffffc020027a:	00004517          	auipc	a0,0x4
ffffffffc020027e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0203f88 <etext+0xb4>
ffffffffc0200282:	e5fff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200286:	0000d597          	auipc	a1,0xd
ffffffffc020028a:	25e58593          	addi	a1,a1,606 # ffffffffc020d4e4 <end>
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	d1a50513          	addi	a0,a0,-742 # ffffffffc0203fa8 <etext+0xd4>
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
ffffffffc02002c0:	d0c50513          	addi	a0,a0,-756 # ffffffffc0203fc8 <etext+0xf4>
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
ffffffffc02002ce:	d2e60613          	addi	a2,a2,-722 # ffffffffc0203ff8 <etext+0x124>
ffffffffc02002d2:	04900593          	li	a1,73
ffffffffc02002d6:	00004517          	auipc	a0,0x4
ffffffffc02002da:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204010 <etext+0x13c>
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
ffffffffc02002ea:	d4260613          	addi	a2,a2,-702 # ffffffffc0204028 <etext+0x154>
ffffffffc02002ee:	00004597          	auipc	a1,0x4
ffffffffc02002f2:	d5a58593          	addi	a1,a1,-678 # ffffffffc0204048 <etext+0x174>
ffffffffc02002f6:	00004517          	auipc	a0,0x4
ffffffffc02002fa:	d5a50513          	addi	a0,a0,-678 # ffffffffc0204050 <etext+0x17c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200300:	de1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200304:	00004617          	auipc	a2,0x4
ffffffffc0200308:	d5c60613          	addi	a2,a2,-676 # ffffffffc0204060 <etext+0x18c>
ffffffffc020030c:	00004597          	auipc	a1,0x4
ffffffffc0200310:	d7c58593          	addi	a1,a1,-644 # ffffffffc0204088 <etext+0x1b4>
ffffffffc0200314:	00004517          	auipc	a0,0x4
ffffffffc0200318:	d3c50513          	addi	a0,a0,-708 # ffffffffc0204050 <etext+0x17c>
ffffffffc020031c:	dc5ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc0200320:	00004617          	auipc	a2,0x4
ffffffffc0200324:	d7860613          	addi	a2,a2,-648 # ffffffffc0204098 <etext+0x1c4>
ffffffffc0200328:	00004597          	auipc	a1,0x4
ffffffffc020032c:	d9058593          	addi	a1,a1,-624 # ffffffffc02040b8 <etext+0x1e4>
ffffffffc0200330:	00004517          	auipc	a0,0x4
ffffffffc0200334:	d2050513          	addi	a0,a0,-736 # ffffffffc0204050 <etext+0x17c>
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
ffffffffc020036e:	d5e50513          	addi	a0,a0,-674 # ffffffffc02040c8 <etext+0x1f4>
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
ffffffffc0200390:	d6450513          	addi	a0,a0,-668 # ffffffffc02040f0 <etext+0x21c>
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
ffffffffc02003b2:	db2c0c13          	addi	s8,s8,-590 # ffffffffc0204160 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003b6:	00004917          	auipc	s2,0x4
ffffffffc02003ba:	d6290913          	addi	s2,s2,-670 # ffffffffc0204118 <etext+0x244>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003be:	00004497          	auipc	s1,0x4
ffffffffc02003c2:	d6248493          	addi	s1,s1,-670 # ffffffffc0204120 <etext+0x24c>
        if (argc == MAXARGS - 1) {
ffffffffc02003c6:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003c8:	00004b17          	auipc	s6,0x4
ffffffffc02003cc:	d60b0b13          	addi	s6,s6,-672 # ffffffffc0204128 <etext+0x254>
        argv[argc ++] = buf;
ffffffffc02003d0:	00004a17          	auipc	s4,0x4
ffffffffc02003d4:	c78a0a13          	addi	s4,s4,-904 # ffffffffc0204048 <etext+0x174>
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
ffffffffc02003f6:	d6ed0d13          	addi	s10,s10,-658 # ffffffffc0204160 <commands>
        argv[argc ++] = buf;
ffffffffc02003fa:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	4401                	li	s0,0
ffffffffc02003fe:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200400:	628030ef          	jal	ra,ffffffffc0203a28 <strcmp>
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
ffffffffc0200414:	614030ef          	jal	ra,ffffffffc0203a28 <strcmp>
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
ffffffffc0200452:	61a030ef          	jal	ra,ffffffffc0203a6c <strchr>
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
ffffffffc0200490:	5dc030ef          	jal	ra,ffffffffc0203a6c <strchr>
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
ffffffffc02004ae:	c9e50513          	addi	a0,a0,-866 # ffffffffc0204148 <etext+0x274>
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
ffffffffc02004be:	cee50513          	addi	a0,a0,-786 # ffffffffc02041a8 <commands+0x48>
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
ffffffffc02004ec:	cd050513          	addi	a0,a0,-816 # ffffffffc02041b8 <commands+0x58>
ffffffffc02004f0:	bf1ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02004f4:	00009417          	auipc	s0,0x9
ffffffffc02004f8:	b1440413          	addi	s0,s0,-1260 # ffffffffc0209008 <boot_dtb>
ffffffffc02004fc:	600c                	ld	a1,0(s0)
ffffffffc02004fe:	00004517          	auipc	a0,0x4
ffffffffc0200502:	cca50513          	addi	a0,a0,-822 # ffffffffc02041c8 <commands+0x68>
ffffffffc0200506:	bdbff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020050a:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020050e:	00004517          	auipc	a0,0x4
ffffffffc0200512:	cd250513          	addi	a0,a0,-814 # ffffffffc02041e0 <commands+0x80>
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
ffffffffc02005cc:	c6890913          	addi	s2,s2,-920 # ffffffffc0204230 <commands+0xd0>
ffffffffc02005d0:	49bd                	li	s3,15
        switch (token) {
ffffffffc02005d2:	4d91                	li	s11,4
ffffffffc02005d4:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02005d6:	00004497          	auipc	s1,0x4
ffffffffc02005da:	c5248493          	addi	s1,s1,-942 # ffffffffc0204228 <commands+0xc8>
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
ffffffffc020062e:	c7e50513          	addi	a0,a0,-898 # ffffffffc02042a8 <commands+0x148>
ffffffffc0200632:	aafff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200636:	00004517          	auipc	a0,0x4
ffffffffc020063a:	caa50513          	addi	a0,a0,-854 # ffffffffc02042e0 <commands+0x180>
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
ffffffffc020067a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0204200 <commands+0xa0>
}
ffffffffc020067e:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200680:	b485                	j	ffffffffc02000e0 <cprintf>
                int name_len = strlen(name);
ffffffffc0200682:	8556                	mv	a0,s5
ffffffffc0200684:	35c030ef          	jal	ra,ffffffffc02039e0 <strlen>
ffffffffc0200688:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020068a:	4619                	li	a2,6
ffffffffc020068c:	85a6                	mv	a1,s1
ffffffffc020068e:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc0200690:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200692:	3b4030ef          	jal	ra,ffffffffc0203a46 <strncmp>
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
ffffffffc0200728:	300030ef          	jal	ra,ffffffffc0203a28 <strcmp>
ffffffffc020072c:	66a2                	ld	a3,8(sp)
ffffffffc020072e:	f94d                	bnez	a0,ffffffffc02006e0 <dtb_init+0x228>
ffffffffc0200730:	fb59f8e3          	bgeu	s3,s5,ffffffffc02006e0 <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200734:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200738:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020073c:	00004517          	auipc	a0,0x4
ffffffffc0200740:	afc50513          	addi	a0,a0,-1284 # ffffffffc0204238 <commands+0xd8>
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
ffffffffc020080e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0204258 <commands+0xf8>
ffffffffc0200812:	8cfff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200816:	014b5613          	srli	a2,s6,0x14
ffffffffc020081a:	85da                	mv	a1,s6
ffffffffc020081c:	00004517          	auipc	a0,0x4
ffffffffc0200820:	a5450513          	addi	a0,a0,-1452 # ffffffffc0204270 <commands+0x110>
ffffffffc0200824:	8bdff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200828:	008b05b3          	add	a1,s6,s0
ffffffffc020082c:	15fd                	addi	a1,a1,-1
ffffffffc020082e:	00004517          	auipc	a0,0x4
ffffffffc0200832:	a6250513          	addi	a0,a0,-1438 # ffffffffc0204290 <commands+0x130>
ffffffffc0200836:	8abff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("DTB init completed\n");
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	aa650513          	addi	a0,a0,-1370 # ffffffffc02042e0 <commands+0x180>
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
ffffffffc0200892:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02042f8 <commands+0x198>
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
#include <defs.h>
#include <intr.h>
#include <riscv.h>

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
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02008d4:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02008d6:	1101                	addi	sp,sp,-32
ffffffffc02008d8:	ec06                	sd	ra,24(sp)
ffffffffc02008da:	e42a                	sd	a0,8(sp)
        intr_disable();
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
        intr_enable();
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
        intr_disable();
ffffffffc020090e:	028000ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0200912:	4501                	li	a0,0
ffffffffc0200914:	4581                	li	a1,0
ffffffffc0200916:	4601                	li	a2,0
ffffffffc0200918:	4889                	li	a7,2
ffffffffc020091a:	00000073          	ecall
ffffffffc020091e:	2501                	sext.w	a0,a0
ffffffffc0200920:	e42a                	sd	a0,8(sp)
        intr_enable();
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
ffffffffc0200944:	3f478793          	addi	a5,a5,1012 # ffffffffc0200d34 <__alltraps>
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
ffffffffc0200962:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0204318 <commands+0x1b8>
{
ffffffffc0200966:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200968:	f78ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020096c:	640c                	ld	a1,8(s0)
ffffffffc020096e:	00004517          	auipc	a0,0x4
ffffffffc0200972:	9c250513          	addi	a0,a0,-1598 # ffffffffc0204330 <commands+0x1d0>
ffffffffc0200976:	f6aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020097a:	680c                	ld	a1,16(s0)
ffffffffc020097c:	00004517          	auipc	a0,0x4
ffffffffc0200980:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0204348 <commands+0x1e8>
ffffffffc0200984:	f5cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200988:	6c0c                	ld	a1,24(s0)
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0204360 <commands+0x200>
ffffffffc0200992:	f4eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200996:	700c                	ld	a1,32(s0)
ffffffffc0200998:	00004517          	auipc	a0,0x4
ffffffffc020099c:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204378 <commands+0x218>
ffffffffc02009a0:	f40ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02009a4:	740c                	ld	a1,40(s0)
ffffffffc02009a6:	00004517          	auipc	a0,0x4
ffffffffc02009aa:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0204390 <commands+0x230>
ffffffffc02009ae:	f32ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02009b2:	780c                	ld	a1,48(s0)
ffffffffc02009b4:	00004517          	auipc	a0,0x4
ffffffffc02009b8:	9f450513          	addi	a0,a0,-1548 # ffffffffc02043a8 <commands+0x248>
ffffffffc02009bc:	f24ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02009c0:	7c0c                	ld	a1,56(s0)
ffffffffc02009c2:	00004517          	auipc	a0,0x4
ffffffffc02009c6:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02043c0 <commands+0x260>
ffffffffc02009ca:	f16ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02009ce:	602c                	ld	a1,64(s0)
ffffffffc02009d0:	00004517          	auipc	a0,0x4
ffffffffc02009d4:	a0850513          	addi	a0,a0,-1528 # ffffffffc02043d8 <commands+0x278>
ffffffffc02009d8:	f08ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009dc:	642c                	ld	a1,72(s0)
ffffffffc02009de:	00004517          	auipc	a0,0x4
ffffffffc02009e2:	a1250513          	addi	a0,a0,-1518 # ffffffffc02043f0 <commands+0x290>
ffffffffc02009e6:	efaff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009ea:	682c                	ld	a1,80(s0)
ffffffffc02009ec:	00004517          	auipc	a0,0x4
ffffffffc02009f0:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0204408 <commands+0x2a8>
ffffffffc02009f4:	eecff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009f8:	6c2c                	ld	a1,88(s0)
ffffffffc02009fa:	00004517          	auipc	a0,0x4
ffffffffc02009fe:	a2650513          	addi	a0,a0,-1498 # ffffffffc0204420 <commands+0x2c0>
ffffffffc0200a02:	edeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200a06:	702c                	ld	a1,96(s0)
ffffffffc0200a08:	00004517          	auipc	a0,0x4
ffffffffc0200a0c:	a3050513          	addi	a0,a0,-1488 # ffffffffc0204438 <commands+0x2d8>
ffffffffc0200a10:	ed0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200a14:	742c                	ld	a1,104(s0)
ffffffffc0200a16:	00004517          	auipc	a0,0x4
ffffffffc0200a1a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0204450 <commands+0x2f0>
ffffffffc0200a1e:	ec2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200a22:	782c                	ld	a1,112(s0)
ffffffffc0200a24:	00004517          	auipc	a0,0x4
ffffffffc0200a28:	a4450513          	addi	a0,a0,-1468 # ffffffffc0204468 <commands+0x308>
ffffffffc0200a2c:	eb4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a30:	7c2c                	ld	a1,120(s0)
ffffffffc0200a32:	00004517          	auipc	a0,0x4
ffffffffc0200a36:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0204480 <commands+0x320>
ffffffffc0200a3a:	ea6ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a3e:	604c                	ld	a1,128(s0)
ffffffffc0200a40:	00004517          	auipc	a0,0x4
ffffffffc0200a44:	a5850513          	addi	a0,a0,-1448 # ffffffffc0204498 <commands+0x338>
ffffffffc0200a48:	e98ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a4c:	644c                	ld	a1,136(s0)
ffffffffc0200a4e:	00004517          	auipc	a0,0x4
ffffffffc0200a52:	a6250513          	addi	a0,a0,-1438 # ffffffffc02044b0 <commands+0x350>
ffffffffc0200a56:	e8aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a5a:	684c                	ld	a1,144(s0)
ffffffffc0200a5c:	00004517          	auipc	a0,0x4
ffffffffc0200a60:	a6c50513          	addi	a0,a0,-1428 # ffffffffc02044c8 <commands+0x368>
ffffffffc0200a64:	e7cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a68:	6c4c                	ld	a1,152(s0)
ffffffffc0200a6a:	00004517          	auipc	a0,0x4
ffffffffc0200a6e:	a7650513          	addi	a0,a0,-1418 # ffffffffc02044e0 <commands+0x380>
ffffffffc0200a72:	e6eff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a76:	704c                	ld	a1,160(s0)
ffffffffc0200a78:	00004517          	auipc	a0,0x4
ffffffffc0200a7c:	a8050513          	addi	a0,a0,-1408 # ffffffffc02044f8 <commands+0x398>
ffffffffc0200a80:	e60ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a84:	744c                	ld	a1,168(s0)
ffffffffc0200a86:	00004517          	auipc	a0,0x4
ffffffffc0200a8a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204510 <commands+0x3b0>
ffffffffc0200a8e:	e52ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a92:	784c                	ld	a1,176(s0)
ffffffffc0200a94:	00004517          	auipc	a0,0x4
ffffffffc0200a98:	a9450513          	addi	a0,a0,-1388 # ffffffffc0204528 <commands+0x3c8>
ffffffffc0200a9c:	e44ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200aa0:	7c4c                	ld	a1,184(s0)
ffffffffc0200aa2:	00004517          	auipc	a0,0x4
ffffffffc0200aa6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0204540 <commands+0x3e0>
ffffffffc0200aaa:	e36ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200aae:	606c                	ld	a1,192(s0)
ffffffffc0200ab0:	00004517          	auipc	a0,0x4
ffffffffc0200ab4:	aa850513          	addi	a0,a0,-1368 # ffffffffc0204558 <commands+0x3f8>
ffffffffc0200ab8:	e28ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200abc:	646c                	ld	a1,200(s0)
ffffffffc0200abe:	00004517          	auipc	a0,0x4
ffffffffc0200ac2:	ab250513          	addi	a0,a0,-1358 # ffffffffc0204570 <commands+0x410>
ffffffffc0200ac6:	e1aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200aca:	686c                	ld	a1,208(s0)
ffffffffc0200acc:	00004517          	auipc	a0,0x4
ffffffffc0200ad0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0204588 <commands+0x428>
ffffffffc0200ad4:	e0cff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200ad8:	6c6c                	ld	a1,216(s0)
ffffffffc0200ada:	00004517          	auipc	a0,0x4
ffffffffc0200ade:	ac650513          	addi	a0,a0,-1338 # ffffffffc02045a0 <commands+0x440>
ffffffffc0200ae2:	dfeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ae6:	706c                	ld	a1,224(s0)
ffffffffc0200ae8:	00004517          	auipc	a0,0x4
ffffffffc0200aec:	ad050513          	addi	a0,a0,-1328 # ffffffffc02045b8 <commands+0x458>
ffffffffc0200af0:	df0ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200af4:	746c                	ld	a1,232(s0)
ffffffffc0200af6:	00004517          	auipc	a0,0x4
ffffffffc0200afa:	ada50513          	addi	a0,a0,-1318 # ffffffffc02045d0 <commands+0x470>
ffffffffc0200afe:	de2ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200b02:	786c                	ld	a1,240(s0)
ffffffffc0200b04:	00004517          	auipc	a0,0x4
ffffffffc0200b08:	ae450513          	addi	a0,a0,-1308 # ffffffffc02045e8 <commands+0x488>
ffffffffc0200b0c:	dd4ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b10:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200b12:	6402                	ld	s0,0(sp)
ffffffffc0200b14:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200b16:	00004517          	auipc	a0,0x4
ffffffffc0200b1a:	aea50513          	addi	a0,a0,-1302 # ffffffffc0204600 <commands+0x4a0>
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
ffffffffc0200b30:	aec50513          	addi	a0,a0,-1300 # ffffffffc0204618 <commands+0x4b8>
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
ffffffffc0200b48:	aec50513          	addi	a0,a0,-1300 # ffffffffc0204630 <commands+0x4d0>
ffffffffc0200b4c:	d94ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b50:	10843583          	ld	a1,264(s0)
ffffffffc0200b54:	00004517          	auipc	a0,0x4
ffffffffc0200b58:	af450513          	addi	a0,a0,-1292 # ffffffffc0204648 <commands+0x4e8>
ffffffffc0200b5c:	d84ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200b60:	11043583          	ld	a1,272(s0)
ffffffffc0200b64:	00004517          	auipc	a0,0x4
ffffffffc0200b68:	afc50513          	addi	a0,a0,-1284 # ffffffffc0204660 <commands+0x500>
ffffffffc0200b6c:	d74ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b70:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b74:	6402                	ld	s0,0(sp)
ffffffffc0200b76:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b78:	00004517          	auipc	a0,0x4
ffffffffc0200b7c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204678 <commands+0x518>
}
ffffffffc0200b80:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b82:	d5eff06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0200b86 <interrupt_handler>:

extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200b86:	11853783          	ld	a5,280(a0)
ffffffffc0200b8a:	472d                	li	a4,11
ffffffffc0200b8c:	0786                	slli	a5,a5,0x1
ffffffffc0200b8e:	8385                	srli	a5,a5,0x1
ffffffffc0200b90:	08f76a63          	bltu	a4,a5,ffffffffc0200c24 <interrupt_handler+0x9e>
ffffffffc0200b94:	00004717          	auipc	a4,0x4
ffffffffc0200b98:	bac70713          	addi	a4,a4,-1108 # ffffffffc0204740 <commands+0x5e0>
ffffffffc0200b9c:	078a                	slli	a5,a5,0x2
ffffffffc0200b9e:	97ba                	add	a5,a5,a4
ffffffffc0200ba0:	439c                	lw	a5,0(a5)
ffffffffc0200ba2:	97ba                	add	a5,a5,a4
ffffffffc0200ba4:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200ba6:	00004517          	auipc	a0,0x4
ffffffffc0200baa:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02046f0 <commands+0x590>
ffffffffc0200bae:	d32ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200bb2:	00004517          	auipc	a0,0x4
ffffffffc0200bb6:	b1e50513          	addi	a0,a0,-1250 # ffffffffc02046d0 <commands+0x570>
ffffffffc0200bba:	d26ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200bbe:	00004517          	auipc	a0,0x4
ffffffffc0200bc2:	ad250513          	addi	a0,a0,-1326 # ffffffffc0204690 <commands+0x530>
ffffffffc0200bc6:	d1aff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200bca:	00004517          	auipc	a0,0x4
ffffffffc0200bce:	ae650513          	addi	a0,a0,-1306 # ffffffffc02046b0 <commands+0x550>
ffffffffc0200bd2:	d0eff06f          	j	ffffffffc02000e0 <cprintf>
{
ffffffffc0200bd6:	1141                	addi	sp,sp,-16
ffffffffc0200bd8:	e022                	sd	s0,0(sp)
ffffffffc0200bda:	e406                	sd	ra,8(sp)
    case IRQ_U_TIMER:
        cprintf("User software interrupt\n");
        break;
    case IRQ_S_TIMER:
        clock_set_next_event();
        ticks++;
ffffffffc0200bdc:	0000d417          	auipc	s0,0xd
ffffffffc0200be0:	8a440413          	addi	s0,s0,-1884 # ffffffffc020d480 <ticks>
        clock_set_next_event();
ffffffffc0200be4:	cbfff0ef          	jal	ra,ffffffffc02008a2 <clock_set_next_event>
        ticks++;
ffffffffc0200be8:	601c                	ld	a5,0(s0)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200bea:	06400713          	li	a4,100
        ticks++;
ffffffffc0200bee:	0785                	addi	a5,a5,1
ffffffffc0200bf0:	e01c                	sd	a5,0(s0)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200bf2:	601c                	ld	a5,0(s0)
ffffffffc0200bf4:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200bf8:	c79d                	beqz	a5,ffffffffc0200c26 <interrupt_handler+0xa0>
            print_ticks();
        }
        if (ticks == 10 * TICK_NUM) {
ffffffffc0200bfa:	6018                	ld	a4,0(s0)
ffffffffc0200bfc:	3e800793          	li	a5,1000
ffffffffc0200c00:	00f71863          	bne	a4,a5,ffffffffc0200c10 <interrupt_handler+0x8a>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c04:	4501                	li	a0,0
ffffffffc0200c06:	4581                	li	a1,0
ffffffffc0200c08:	4601                	li	a2,0
ffffffffc0200c0a:	48a1                	li	a7,8
ffffffffc0200c0c:	00000073          	ecall
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c10:	60a2                	ld	ra,8(sp)
ffffffffc0200c12:	6402                	ld	s0,0(sp)
ffffffffc0200c14:	0141                	addi	sp,sp,16
ffffffffc0200c16:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c18:	00004517          	auipc	a0,0x4
ffffffffc0200c1c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204720 <commands+0x5c0>
ffffffffc0200c20:	cc0ff06f          	j	ffffffffc02000e0 <cprintf>
        print_trapframe(tf);
ffffffffc0200c24:	b701                	j	ffffffffc0200b24 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c26:	06400593          	li	a1,100
ffffffffc0200c2a:	00004517          	auipc	a0,0x4
ffffffffc0200c2e:	ae650513          	addi	a0,a0,-1306 # ffffffffc0204710 <commands+0x5b0>
ffffffffc0200c32:	caeff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0200c36:	b7d1                	j	ffffffffc0200bfa <interrupt_handler+0x74>

ffffffffc0200c38 <exception_handler>:

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c38:	11853783          	ld	a5,280(a0)
{
ffffffffc0200c3c:	1141                	addi	sp,sp,-16
ffffffffc0200c3e:	e022                	sd	s0,0(sp)
ffffffffc0200c40:	e406                	sd	ra,8(sp)
ffffffffc0200c42:	473d                	li	a4,15
ffffffffc0200c44:	842a                	mv	s0,a0
ffffffffc0200c46:	0cf76b63          	bltu	a4,a5,ffffffffc0200d1c <exception_handler+0xe4>
ffffffffc0200c4a:	00004717          	auipc	a4,0x4
ffffffffc0200c4e:	cbe70713          	addi	a4,a4,-834 # ffffffffc0204908 <commands+0x7a8>
ffffffffc0200c52:	078a                	slli	a5,a5,0x2
ffffffffc0200c54:	97ba                	add	a5,a5,a4
ffffffffc0200c56:	439c                	lw	a5,0(a5)
ffffffffc0200c58:	97ba                	add	a5,a5,a4
ffffffffc0200c5a:	8782                	jr	a5
        break;
    case CAUSE_LOAD_PAGE_FAULT:
        cprintf("Load page fault\n");
        break;
    case CAUSE_STORE_PAGE_FAULT:
        cprintf("Store/AMO page fault\n");
ffffffffc0200c5c:	00004517          	auipc	a0,0x4
ffffffffc0200c60:	c9450513          	addi	a0,a0,-876 # ffffffffc02048f0 <commands+0x790>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c64:	6402                	ld	s0,0(sp)
ffffffffc0200c66:	60a2                	ld	ra,8(sp)
ffffffffc0200c68:	0141                	addi	sp,sp,16
        cprintf("Instruction access fault\n");
ffffffffc0200c6a:	c76ff06f          	j	ffffffffc02000e0 <cprintf>
        cprintf("Instruction address misaligned\n");
ffffffffc0200c6e:	00004517          	auipc	a0,0x4
ffffffffc0200c72:	b0250513          	addi	a0,a0,-1278 # ffffffffc0204770 <commands+0x610>
ffffffffc0200c76:	b7fd                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Instruction access fault\n");
ffffffffc0200c78:	00004517          	auipc	a0,0x4
ffffffffc0200c7c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0204790 <commands+0x630>
ffffffffc0200c80:	b7d5                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Illegal instruction\n");
ffffffffc0200c82:	00004517          	auipc	a0,0x4
ffffffffc0200c86:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02047b0 <commands+0x650>
ffffffffc0200c8a:	c56ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        tf->epc += 4;
ffffffffc0200c8e:	10843783          	ld	a5,264(s0)
ffffffffc0200c92:	0791                	addi	a5,a5,4
ffffffffc0200c94:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200c98:	60a2                	ld	ra,8(sp)
ffffffffc0200c9a:	6402                	ld	s0,0(sp)
ffffffffc0200c9c:	0141                	addi	sp,sp,16
ffffffffc0200c9e:	8082                	ret
        cprintf("Breakpoint\n");
ffffffffc0200ca0:	00004517          	auipc	a0,0x4
ffffffffc0200ca4:	b2850513          	addi	a0,a0,-1240 # ffffffffc02047c8 <commands+0x668>
ffffffffc0200ca8:	c38ff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        tf->epc += 4;
ffffffffc0200cac:	10843783          	ld	a5,264(s0)
ffffffffc0200cb0:	0791                	addi	a5,a5,4
ffffffffc0200cb2:	10f43423          	sd	a5,264(s0)
        break;
ffffffffc0200cb6:	b7cd                	j	ffffffffc0200c98 <exception_handler+0x60>
        cprintf("Load address misaligned\n");
ffffffffc0200cb8:	00004517          	auipc	a0,0x4
ffffffffc0200cbc:	b2050513          	addi	a0,a0,-1248 # ffffffffc02047d8 <commands+0x678>
ffffffffc0200cc0:	b755                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Load access fault\n");
ffffffffc0200cc2:	00004517          	auipc	a0,0x4
ffffffffc0200cc6:	b3650513          	addi	a0,a0,-1226 # ffffffffc02047f8 <commands+0x698>
ffffffffc0200cca:	bf69                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("AMO address misaligned\n");
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	b4450513          	addi	a0,a0,-1212 # ffffffffc0204810 <commands+0x6b0>
ffffffffc0200cd4:	bf41                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Store/AMO access fault\n");
ffffffffc0200cd6:	00004517          	auipc	a0,0x4
ffffffffc0200cda:	b5250513          	addi	a0,a0,-1198 # ffffffffc0204828 <commands+0x6c8>
ffffffffc0200cde:	b759                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Environment call from U-mode\n");
ffffffffc0200ce0:	00004517          	auipc	a0,0x4
ffffffffc0200ce4:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204840 <commands+0x6e0>
ffffffffc0200ce8:	bfb5                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Environment call from S-mode\n");
ffffffffc0200cea:	00004517          	auipc	a0,0x4
ffffffffc0200cee:	b7650513          	addi	a0,a0,-1162 # ffffffffc0204860 <commands+0x700>
ffffffffc0200cf2:	bf8d                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Environment call from H-mode\n");
ffffffffc0200cf4:	00004517          	auipc	a0,0x4
ffffffffc0200cf8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0204880 <commands+0x720>
ffffffffc0200cfc:	b7a5                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Environment call from M-mode\n");
ffffffffc0200cfe:	00004517          	auipc	a0,0x4
ffffffffc0200d02:	ba250513          	addi	a0,a0,-1118 # ffffffffc02048a0 <commands+0x740>
ffffffffc0200d06:	bfb9                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Instruction page fault\n");
ffffffffc0200d08:	00004517          	auipc	a0,0x4
ffffffffc0200d0c:	bb850513          	addi	a0,a0,-1096 # ffffffffc02048c0 <commands+0x760>
ffffffffc0200d10:	bf91                	j	ffffffffc0200c64 <exception_handler+0x2c>
        cprintf("Load page fault\n");
ffffffffc0200d12:	00004517          	auipc	a0,0x4
ffffffffc0200d16:	bc650513          	addi	a0,a0,-1082 # ffffffffc02048d8 <commands+0x778>
ffffffffc0200d1a:	b7a9                	j	ffffffffc0200c64 <exception_handler+0x2c>
        print_trapframe(tf);
ffffffffc0200d1c:	8522                	mv	a0,s0
}
ffffffffc0200d1e:	6402                	ld	s0,0(sp)
ffffffffc0200d20:	60a2                	ld	ra,8(sp)
ffffffffc0200d22:	0141                	addi	sp,sp,16
        print_trapframe(tf);
ffffffffc0200d24:	b501                	j	ffffffffc0200b24 <print_trapframe>

ffffffffc0200d26 <trap>:
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d26:	11853783          	ld	a5,280(a0)
ffffffffc0200d2a:	0007c363          	bltz	a5,ffffffffc0200d30 <trap+0xa>
        interrupt_handler(tf);
    }
    else
    {
        // exceptions
        exception_handler(tf);
ffffffffc0200d2e:	b729                	j	ffffffffc0200c38 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200d30:	bd99                	j	ffffffffc0200b86 <interrupt_handler>
	...

ffffffffc0200d34 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d34:	14011073          	csrw	sscratch,sp
ffffffffc0200d38:	712d                	addi	sp,sp,-288
ffffffffc0200d3a:	e406                	sd	ra,8(sp)
ffffffffc0200d3c:	ec0e                	sd	gp,24(sp)
ffffffffc0200d3e:	f012                	sd	tp,32(sp)
ffffffffc0200d40:	f416                	sd	t0,40(sp)
ffffffffc0200d42:	f81a                	sd	t1,48(sp)
ffffffffc0200d44:	fc1e                	sd	t2,56(sp)
ffffffffc0200d46:	e0a2                	sd	s0,64(sp)
ffffffffc0200d48:	e4a6                	sd	s1,72(sp)
ffffffffc0200d4a:	e8aa                	sd	a0,80(sp)
ffffffffc0200d4c:	ecae                	sd	a1,88(sp)
ffffffffc0200d4e:	f0b2                	sd	a2,96(sp)
ffffffffc0200d50:	f4b6                	sd	a3,104(sp)
ffffffffc0200d52:	f8ba                	sd	a4,112(sp)
ffffffffc0200d54:	fcbe                	sd	a5,120(sp)
ffffffffc0200d56:	e142                	sd	a6,128(sp)
ffffffffc0200d58:	e546                	sd	a7,136(sp)
ffffffffc0200d5a:	e94a                	sd	s2,144(sp)
ffffffffc0200d5c:	ed4e                	sd	s3,152(sp)
ffffffffc0200d5e:	f152                	sd	s4,160(sp)
ffffffffc0200d60:	f556                	sd	s5,168(sp)
ffffffffc0200d62:	f95a                	sd	s6,176(sp)
ffffffffc0200d64:	fd5e                	sd	s7,184(sp)
ffffffffc0200d66:	e1e2                	sd	s8,192(sp)
ffffffffc0200d68:	e5e6                	sd	s9,200(sp)
ffffffffc0200d6a:	e9ea                	sd	s10,208(sp)
ffffffffc0200d6c:	edee                	sd	s11,216(sp)
ffffffffc0200d6e:	f1f2                	sd	t3,224(sp)
ffffffffc0200d70:	f5f6                	sd	t4,232(sp)
ffffffffc0200d72:	f9fa                	sd	t5,240(sp)
ffffffffc0200d74:	fdfe                	sd	t6,248(sp)
ffffffffc0200d76:	14002473          	csrr	s0,sscratch
ffffffffc0200d7a:	100024f3          	csrr	s1,sstatus
ffffffffc0200d7e:	14102973          	csrr	s2,sepc
ffffffffc0200d82:	143029f3          	csrr	s3,stval
ffffffffc0200d86:	14202a73          	csrr	s4,scause
ffffffffc0200d8a:	e822                	sd	s0,16(sp)
ffffffffc0200d8c:	e226                	sd	s1,256(sp)
ffffffffc0200d8e:	e64a                	sd	s2,264(sp)
ffffffffc0200d90:	ea4e                	sd	s3,272(sp)
ffffffffc0200d92:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d94:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d96:	f91ff0ef          	jal	ra,ffffffffc0200d26 <trap>

ffffffffc0200d9a <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d9a:	6492                	ld	s1,256(sp)
ffffffffc0200d9c:	6932                	ld	s2,264(sp)
ffffffffc0200d9e:	10049073          	csrw	sstatus,s1
ffffffffc0200da2:	14191073          	csrw	sepc,s2
ffffffffc0200da6:	60a2                	ld	ra,8(sp)
ffffffffc0200da8:	61e2                	ld	gp,24(sp)
ffffffffc0200daa:	7202                	ld	tp,32(sp)
ffffffffc0200dac:	72a2                	ld	t0,40(sp)
ffffffffc0200dae:	7342                	ld	t1,48(sp)
ffffffffc0200db0:	73e2                	ld	t2,56(sp)
ffffffffc0200db2:	6406                	ld	s0,64(sp)
ffffffffc0200db4:	64a6                	ld	s1,72(sp)
ffffffffc0200db6:	6546                	ld	a0,80(sp)
ffffffffc0200db8:	65e6                	ld	a1,88(sp)
ffffffffc0200dba:	7606                	ld	a2,96(sp)
ffffffffc0200dbc:	76a6                	ld	a3,104(sp)
ffffffffc0200dbe:	7746                	ld	a4,112(sp)
ffffffffc0200dc0:	77e6                	ld	a5,120(sp)
ffffffffc0200dc2:	680a                	ld	a6,128(sp)
ffffffffc0200dc4:	68aa                	ld	a7,136(sp)
ffffffffc0200dc6:	694a                	ld	s2,144(sp)
ffffffffc0200dc8:	69ea                	ld	s3,152(sp)
ffffffffc0200dca:	7a0a                	ld	s4,160(sp)
ffffffffc0200dcc:	7aaa                	ld	s5,168(sp)
ffffffffc0200dce:	7b4a                	ld	s6,176(sp)
ffffffffc0200dd0:	7bea                	ld	s7,184(sp)
ffffffffc0200dd2:	6c0e                	ld	s8,192(sp)
ffffffffc0200dd4:	6cae                	ld	s9,200(sp)
ffffffffc0200dd6:	6d4e                	ld	s10,208(sp)
ffffffffc0200dd8:	6dee                	ld	s11,216(sp)
ffffffffc0200dda:	7e0e                	ld	t3,224(sp)
ffffffffc0200ddc:	7eae                	ld	t4,232(sp)
ffffffffc0200dde:	7f4e                	ld	t5,240(sp)
ffffffffc0200de0:	7fee                	ld	t6,248(sp)
ffffffffc0200de2:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    sret
ffffffffc0200de4:	10200073          	sret

ffffffffc0200de8 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200de8:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dea:	bf45                	j	ffffffffc0200d9a <__trapret>
	...

ffffffffc0200dee <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0200dee:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200df0:	00004697          	auipc	a3,0x4
ffffffffc0200df4:	b5868693          	addi	a3,a3,-1192 # ffffffffc0204948 <commands+0x7e8>
ffffffffc0200df8:	00004617          	auipc	a2,0x4
ffffffffc0200dfc:	b7060613          	addi	a2,a2,-1168 # ffffffffc0204968 <commands+0x808>
ffffffffc0200e00:	08800593          	li	a1,136
ffffffffc0200e04:	00004517          	auipc	a0,0x4
ffffffffc0200e08:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0204980 <commands+0x820>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0200e0c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200e0e:	bd0ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200e12 <find_vma>:
{
ffffffffc0200e12:	86aa                	mv	a3,a0
    if (mm != NULL)
ffffffffc0200e14:	c505                	beqz	a0,ffffffffc0200e3c <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200e16:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0200e18:	c501                	beqz	a0,ffffffffc0200e20 <find_vma+0xe>
ffffffffc0200e1a:	651c                	ld	a5,8(a0)
ffffffffc0200e1c:	02f5f263          	bgeu	a1,a5,ffffffffc0200e40 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e20:	669c                	ld	a5,8(a3)
            while ((le = list_next(le)) != list)
ffffffffc0200e22:	00f68d63          	beq	a3,a5,ffffffffc0200e3c <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0200e26:	fe87b703          	ld	a4,-24(a5) # 3ffe8 <kern_entry-0xffffffffc01c0018>
ffffffffc0200e2a:	00e5e663          	bltu	a1,a4,ffffffffc0200e36 <find_vma+0x24>
ffffffffc0200e2e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e32:	00e5ec63          	bltu	a1,a4,ffffffffc0200e4a <find_vma+0x38>
ffffffffc0200e36:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0200e38:	fef697e3          	bne	a3,a5,ffffffffc0200e26 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200e3c:	4501                	li	a0,0
}
ffffffffc0200e3e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0200e40:	691c                	ld	a5,16(a0)
ffffffffc0200e42:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200e20 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200e46:	ea88                	sd	a0,16(a3)
ffffffffc0200e48:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0200e4a:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200e4e:	ea88                	sd	a0,16(a3)
ffffffffc0200e50:	8082                	ret

ffffffffc0200e52 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200e52:	6590                	ld	a2,8(a1)
ffffffffc0200e54:	0105b803          	ld	a6,16(a1)
{
ffffffffc0200e58:	1141                	addi	sp,sp,-16
ffffffffc0200e5a:	e406                	sd	ra,8(sp)
ffffffffc0200e5c:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200e5e:	01066763          	bltu	a2,a6,ffffffffc0200e6c <insert_vma_struct+0x1a>
ffffffffc0200e62:	a085                	j	ffffffffc0200ec2 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0200e64:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200e68:	04e66863          	bltu	a2,a4,ffffffffc0200eb8 <insert_vma_struct+0x66>
ffffffffc0200e6c:	86be                	mv	a3,a5
ffffffffc0200e6e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0200e70:	fef51ae3          	bne	a0,a5,ffffffffc0200e64 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0200e74:	02a68463          	beq	a3,a0,ffffffffc0200e9c <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200e78:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200e7c:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200e80:	08e8f163          	bgeu	a7,a4,ffffffffc0200f02 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200e84:	04e66f63          	bltu	a2,a4,ffffffffc0200ee2 <insert_vma_struct+0x90>
    }
    if (le_next != list)
ffffffffc0200e88:	00f50a63          	beq	a0,a5,ffffffffc0200e9c <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0200e8c:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200e90:	05076963          	bltu	a4,a6,ffffffffc0200ee2 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200e94:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200e98:	02c77363          	bgeu	a4,a2,ffffffffc0200ebe <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0200e9c:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200e9e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200ea0:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200ea4:	e390                	sd	a2,0(a5)
ffffffffc0200ea6:	e690                	sd	a2,8(a3)
}
ffffffffc0200ea8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200eaa:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200eac:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0200eae:	0017079b          	addiw	a5,a4,1
ffffffffc0200eb2:	d11c                	sw	a5,32(a0)
}
ffffffffc0200eb4:	0141                	addi	sp,sp,16
ffffffffc0200eb6:	8082                	ret
    if (le_prev != list)
ffffffffc0200eb8:	fca690e3          	bne	a3,a0,ffffffffc0200e78 <insert_vma_struct+0x26>
ffffffffc0200ebc:	bfd1                	j	ffffffffc0200e90 <insert_vma_struct+0x3e>
ffffffffc0200ebe:	f31ff0ef          	jal	ra,ffffffffc0200dee <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	ace68693          	addi	a3,a3,-1330 # ffffffffc0204990 <commands+0x830>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0204968 <commands+0x808>
ffffffffc0200ed2:	08e00593          	li	a1,142
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0204980 <commands+0x820>
ffffffffc0200ede:	b00ff0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	aee68693          	addi	a3,a3,-1298 # ffffffffc02049d0 <commands+0x870>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	a7e60613          	addi	a2,a2,-1410 # ffffffffc0204968 <commands+0x808>
ffffffffc0200ef2:	08700593          	li	a1,135
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204980 <commands+0x820>
ffffffffc0200efe:	ae0ff0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	aae68693          	addi	a3,a3,-1362 # ffffffffc02049b0 <commands+0x850>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	a5e60613          	addi	a2,a2,-1442 # ffffffffc0204968 <commands+0x808>
ffffffffc0200f12:	08600593          	li	a1,134
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0204980 <commands+0x820>
ffffffffc0200f1e:	ac0ff0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0200f22 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0200f22:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f24:	03000513          	li	a0,48
{
ffffffffc0200f28:	fc06                	sd	ra,56(sp)
ffffffffc0200f2a:	f822                	sd	s0,48(sp)
ffffffffc0200f2c:	f426                	sd	s1,40(sp)
ffffffffc0200f2e:	f04a                	sd	s2,32(sp)
ffffffffc0200f30:	ec4e                	sd	s3,24(sp)
ffffffffc0200f32:	e852                	sd	s4,16(sp)
ffffffffc0200f34:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f36:	550000ef          	jal	ra,ffffffffc0201486 <kmalloc>
    if (mm != NULL)
ffffffffc0200f3a:	2e050f63          	beqz	a0,ffffffffc0201238 <vmm_init+0x316>
ffffffffc0200f3e:	84aa                	mv	s1,a0
    elm->prev = elm->next = elm;
ffffffffc0200f40:	e508                	sd	a0,8(a0)
ffffffffc0200f42:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200f44:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200f48:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200f4c:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0200f50:	02053423          	sd	zero,40(a0)
ffffffffc0200f54:	03200413          	li	s0,50
ffffffffc0200f58:	a811                	j	ffffffffc0200f6c <vmm_init+0x4a>
        vma->vm_start = vm_start;
ffffffffc0200f5a:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200f5c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200f5e:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i--)
ffffffffc0200f62:	146d                	addi	s0,s0,-5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200f64:	8526                	mv	a0,s1
ffffffffc0200f66:	eedff0ef          	jal	ra,ffffffffc0200e52 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0200f6a:	c80d                	beqz	s0,ffffffffc0200f9c <vmm_init+0x7a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f6c:	03000513          	li	a0,48
ffffffffc0200f70:	516000ef          	jal	ra,ffffffffc0201486 <kmalloc>
ffffffffc0200f74:	85aa                	mv	a1,a0
ffffffffc0200f76:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0200f7a:	f165                	bnez	a0,ffffffffc0200f5a <vmm_init+0x38>
        assert(vma != NULL);
ffffffffc0200f7c:	00004697          	auipc	a3,0x4
ffffffffc0200f80:	bec68693          	addi	a3,a3,-1044 # ffffffffc0204b68 <commands+0xa08>
ffffffffc0200f84:	00004617          	auipc	a2,0x4
ffffffffc0200f88:	9e460613          	addi	a2,a2,-1564 # ffffffffc0204968 <commands+0x808>
ffffffffc0200f8c:	0da00593          	li	a1,218
ffffffffc0200f90:	00004517          	auipc	a0,0x4
ffffffffc0200f94:	9f050513          	addi	a0,a0,-1552 # ffffffffc0204980 <commands+0x820>
ffffffffc0200f98:	a46ff0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc0200f9c:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200fa0:	1f900913          	li	s2,505
ffffffffc0200fa4:	a819                	j	ffffffffc0200fba <vmm_init+0x98>
        vma->vm_start = vm_start;
ffffffffc0200fa6:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200fa8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200faa:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200fae:	0415                	addi	s0,s0,5
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200fb0:	8526                	mv	a0,s1
ffffffffc0200fb2:	ea1ff0ef          	jal	ra,ffffffffc0200e52 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0200fb6:	03240a63          	beq	s0,s2,ffffffffc0200fea <vmm_init+0xc8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200fba:	03000513          	li	a0,48
ffffffffc0200fbe:	4c8000ef          	jal	ra,ffffffffc0201486 <kmalloc>
ffffffffc0200fc2:	85aa                	mv	a1,a0
ffffffffc0200fc4:	00240793          	addi	a5,s0,2
    if (vma != NULL)
ffffffffc0200fc8:	fd79                	bnez	a0,ffffffffc0200fa6 <vmm_init+0x84>
        assert(vma != NULL);
ffffffffc0200fca:	00004697          	auipc	a3,0x4
ffffffffc0200fce:	b9e68693          	addi	a3,a3,-1122 # ffffffffc0204b68 <commands+0xa08>
ffffffffc0200fd2:	00004617          	auipc	a2,0x4
ffffffffc0200fd6:	99660613          	addi	a2,a2,-1642 # ffffffffc0204968 <commands+0x808>
ffffffffc0200fda:	0e100593          	li	a1,225
ffffffffc0200fde:	00004517          	auipc	a0,0x4
ffffffffc0200fe2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0204980 <commands+0x820>
ffffffffc0200fe6:	9f8ff0ef          	jal	ra,ffffffffc02001de <__panic>
    return listelm->next;
ffffffffc0200fea:	649c                	ld	a5,8(s1)
ffffffffc0200fec:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0200fee:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0200ff2:	18f48363          	beq	s1,a5,ffffffffc0201178 <vmm_init+0x256>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200ff6:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200ffa:	ffe70693          	addi	a3,a4,-2
ffffffffc0200ffe:	10d61d63          	bne	a2,a3,ffffffffc0201118 <vmm_init+0x1f6>
ffffffffc0201002:	ff07b683          	ld	a3,-16(a5)
ffffffffc0201006:	10e69963          	bne	a3,a4,ffffffffc0201118 <vmm_init+0x1f6>
    for (i = 1; i <= step2; i++)
ffffffffc020100a:	0715                	addi	a4,a4,5
ffffffffc020100c:	679c                	ld	a5,8(a5)
ffffffffc020100e:	feb712e3          	bne	a4,a1,ffffffffc0200ff2 <vmm_init+0xd0>
ffffffffc0201012:	4a1d                	li	s4,7
ffffffffc0201014:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0201016:	1f900a93          	li	s5,505
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020101a:	85a2                	mv	a1,s0
ffffffffc020101c:	8526                	mv	a0,s1
ffffffffc020101e:	df5ff0ef          	jal	ra,ffffffffc0200e12 <find_vma>
ffffffffc0201022:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0201024:	18050a63          	beqz	a0,ffffffffc02011b8 <vmm_init+0x296>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0201028:	00140593          	addi	a1,s0,1
ffffffffc020102c:	8526                	mv	a0,s1
ffffffffc020102e:	de5ff0ef          	jal	ra,ffffffffc0200e12 <find_vma>
ffffffffc0201032:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0201034:	16050263          	beqz	a0,ffffffffc0201198 <vmm_init+0x276>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0201038:	85d2                	mv	a1,s4
ffffffffc020103a:	8526                	mv	a0,s1
ffffffffc020103c:	dd7ff0ef          	jal	ra,ffffffffc0200e12 <find_vma>
        assert(vma3 == NULL);
ffffffffc0201040:	18051c63          	bnez	a0,ffffffffc02011d8 <vmm_init+0x2b6>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0201044:	00340593          	addi	a1,s0,3
ffffffffc0201048:	8526                	mv	a0,s1
ffffffffc020104a:	dc9ff0ef          	jal	ra,ffffffffc0200e12 <find_vma>
        assert(vma4 == NULL);
ffffffffc020104e:	1c051563          	bnez	a0,ffffffffc0201218 <vmm_init+0x2f6>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0201052:	00440593          	addi	a1,s0,4
ffffffffc0201056:	8526                	mv	a0,s1
ffffffffc0201058:	dbbff0ef          	jal	ra,ffffffffc0200e12 <find_vma>
        assert(vma5 == NULL);
ffffffffc020105c:	18051e63          	bnez	a0,ffffffffc02011f8 <vmm_init+0x2d6>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0201060:	00893783          	ld	a5,8(s2)
ffffffffc0201064:	0c879a63          	bne	a5,s0,ffffffffc0201138 <vmm_init+0x216>
ffffffffc0201068:	01093783          	ld	a5,16(s2)
ffffffffc020106c:	0d479663          	bne	a5,s4,ffffffffc0201138 <vmm_init+0x216>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0201070:	0089b783          	ld	a5,8(s3)
ffffffffc0201074:	0e879263          	bne	a5,s0,ffffffffc0201158 <vmm_init+0x236>
ffffffffc0201078:	0109b783          	ld	a5,16(s3)
ffffffffc020107c:	0d479e63          	bne	a5,s4,ffffffffc0201158 <vmm_init+0x236>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0201080:	0415                	addi	s0,s0,5
ffffffffc0201082:	0a15                	addi	s4,s4,5
ffffffffc0201084:	f9541be3          	bne	s0,s5,ffffffffc020101a <vmm_init+0xf8>
ffffffffc0201088:	4411                	li	s0,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc020108a:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc020108c:	85a2                	mv	a1,s0
ffffffffc020108e:	8526                	mv	a0,s1
ffffffffc0201090:	d83ff0ef          	jal	ra,ffffffffc0200e12 <find_vma>
ffffffffc0201094:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL)
ffffffffc0201098:	c90d                	beqz	a0,ffffffffc02010ca <vmm_init+0x1a8>
        {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc020109a:	6914                	ld	a3,16(a0)
ffffffffc020109c:	6510                	ld	a2,8(a0)
ffffffffc020109e:	00004517          	auipc	a0,0x4
ffffffffc02010a2:	a5250513          	addi	a0,a0,-1454 # ffffffffc0204af0 <commands+0x990>
ffffffffc02010a6:	83aff0ef          	jal	ra,ffffffffc02000e0 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02010aa:	00004697          	auipc	a3,0x4
ffffffffc02010ae:	a6e68693          	addi	a3,a3,-1426 # ffffffffc0204b18 <commands+0x9b8>
ffffffffc02010b2:	00004617          	auipc	a2,0x4
ffffffffc02010b6:	8b660613          	addi	a2,a2,-1866 # ffffffffc0204968 <commands+0x808>
ffffffffc02010ba:	10700593          	li	a1,263
ffffffffc02010be:	00004517          	auipc	a0,0x4
ffffffffc02010c2:	8c250513          	addi	a0,a0,-1854 # ffffffffc0204980 <commands+0x820>
ffffffffc02010c6:	918ff0ef          	jal	ra,ffffffffc02001de <__panic>
    for (i = 4; i >= 0; i--)
ffffffffc02010ca:	147d                	addi	s0,s0,-1
ffffffffc02010cc:	fd2410e3          	bne	s0,s2,ffffffffc020108c <vmm_init+0x16a>
ffffffffc02010d0:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc02010d2:	00a48c63          	beq	s1,a0,ffffffffc02010ea <vmm_init+0x1c8>
    __list_del(listelm->prev, listelm->next);
ffffffffc02010d6:	6118                	ld	a4,0(a0)
ffffffffc02010d8:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02010da:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02010dc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010de:	e398                	sd	a4,0(a5)
ffffffffc02010e0:	456000ef          	jal	ra,ffffffffc0201536 <kfree>
    return listelm->next;
ffffffffc02010e4:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list)
ffffffffc02010e6:	fea498e3          	bne	s1,a0,ffffffffc02010d6 <vmm_init+0x1b4>
    kfree(mm); // kfree mm
ffffffffc02010ea:	8526                	mv	a0,s1
ffffffffc02010ec:	44a000ef          	jal	ra,ffffffffc0201536 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02010f0:	00004517          	auipc	a0,0x4
ffffffffc02010f4:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204b30 <commands+0x9d0>
ffffffffc02010f8:	fe9fe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc02010fc:	7442                	ld	s0,48(sp)
ffffffffc02010fe:	70e2                	ld	ra,56(sp)
ffffffffc0201100:	74a2                	ld	s1,40(sp)
ffffffffc0201102:	7902                	ld	s2,32(sp)
ffffffffc0201104:	69e2                	ld	s3,24(sp)
ffffffffc0201106:	6a42                	ld	s4,16(sp)
ffffffffc0201108:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020110a:	00004517          	auipc	a0,0x4
ffffffffc020110e:	a4650513          	addi	a0,a0,-1466 # ffffffffc0204b50 <commands+0x9f0>
}
ffffffffc0201112:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201114:	fcdfe06f          	j	ffffffffc02000e0 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201118:	00004697          	auipc	a3,0x4
ffffffffc020111c:	8f068693          	addi	a3,a3,-1808 # ffffffffc0204a08 <commands+0x8a8>
ffffffffc0201120:	00004617          	auipc	a2,0x4
ffffffffc0201124:	84860613          	addi	a2,a2,-1976 # ffffffffc0204968 <commands+0x808>
ffffffffc0201128:	0eb00593          	li	a1,235
ffffffffc020112c:	00004517          	auipc	a0,0x4
ffffffffc0201130:	85450513          	addi	a0,a0,-1964 # ffffffffc0204980 <commands+0x820>
ffffffffc0201134:	8aaff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0201138:	00004697          	auipc	a3,0x4
ffffffffc020113c:	95868693          	addi	a3,a3,-1704 # ffffffffc0204a90 <commands+0x930>
ffffffffc0201140:	00004617          	auipc	a2,0x4
ffffffffc0201144:	82860613          	addi	a2,a2,-2008 # ffffffffc0204968 <commands+0x808>
ffffffffc0201148:	0fc00593          	li	a1,252
ffffffffc020114c:	00004517          	auipc	a0,0x4
ffffffffc0201150:	83450513          	addi	a0,a0,-1996 # ffffffffc0204980 <commands+0x820>
ffffffffc0201154:	88aff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0201158:	00004697          	auipc	a3,0x4
ffffffffc020115c:	96868693          	addi	a3,a3,-1688 # ffffffffc0204ac0 <commands+0x960>
ffffffffc0201160:	00004617          	auipc	a2,0x4
ffffffffc0201164:	80860613          	addi	a2,a2,-2040 # ffffffffc0204968 <commands+0x808>
ffffffffc0201168:	0fd00593          	li	a1,253
ffffffffc020116c:	00004517          	auipc	a0,0x4
ffffffffc0201170:	81450513          	addi	a0,a0,-2028 # ffffffffc0204980 <commands+0x820>
ffffffffc0201174:	86aff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201178:	00004697          	auipc	a3,0x4
ffffffffc020117c:	87868693          	addi	a3,a3,-1928 # ffffffffc02049f0 <commands+0x890>
ffffffffc0201180:	00003617          	auipc	a2,0x3
ffffffffc0201184:	7e860613          	addi	a2,a2,2024 # ffffffffc0204968 <commands+0x808>
ffffffffc0201188:	0e900593          	li	a1,233
ffffffffc020118c:	00003517          	auipc	a0,0x3
ffffffffc0201190:	7f450513          	addi	a0,a0,2036 # ffffffffc0204980 <commands+0x820>
ffffffffc0201194:	84aff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma2 != NULL);
ffffffffc0201198:	00004697          	auipc	a3,0x4
ffffffffc020119c:	8b868693          	addi	a3,a3,-1864 # ffffffffc0204a50 <commands+0x8f0>
ffffffffc02011a0:	00003617          	auipc	a2,0x3
ffffffffc02011a4:	7c860613          	addi	a2,a2,1992 # ffffffffc0204968 <commands+0x808>
ffffffffc02011a8:	0f400593          	li	a1,244
ffffffffc02011ac:	00003517          	auipc	a0,0x3
ffffffffc02011b0:	7d450513          	addi	a0,a0,2004 # ffffffffc0204980 <commands+0x820>
ffffffffc02011b4:	82aff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma1 != NULL);
ffffffffc02011b8:	00004697          	auipc	a3,0x4
ffffffffc02011bc:	88868693          	addi	a3,a3,-1912 # ffffffffc0204a40 <commands+0x8e0>
ffffffffc02011c0:	00003617          	auipc	a2,0x3
ffffffffc02011c4:	7a860613          	addi	a2,a2,1960 # ffffffffc0204968 <commands+0x808>
ffffffffc02011c8:	0f200593          	li	a1,242
ffffffffc02011cc:	00003517          	auipc	a0,0x3
ffffffffc02011d0:	7b450513          	addi	a0,a0,1972 # ffffffffc0204980 <commands+0x820>
ffffffffc02011d4:	80aff0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma3 == NULL);
ffffffffc02011d8:	00004697          	auipc	a3,0x4
ffffffffc02011dc:	88868693          	addi	a3,a3,-1912 # ffffffffc0204a60 <commands+0x900>
ffffffffc02011e0:	00003617          	auipc	a2,0x3
ffffffffc02011e4:	78860613          	addi	a2,a2,1928 # ffffffffc0204968 <commands+0x808>
ffffffffc02011e8:	0f600593          	li	a1,246
ffffffffc02011ec:	00003517          	auipc	a0,0x3
ffffffffc02011f0:	79450513          	addi	a0,a0,1940 # ffffffffc0204980 <commands+0x820>
ffffffffc02011f4:	febfe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma5 == NULL);
ffffffffc02011f8:	00004697          	auipc	a3,0x4
ffffffffc02011fc:	88868693          	addi	a3,a3,-1912 # ffffffffc0204a80 <commands+0x920>
ffffffffc0201200:	00003617          	auipc	a2,0x3
ffffffffc0201204:	76860613          	addi	a2,a2,1896 # ffffffffc0204968 <commands+0x808>
ffffffffc0201208:	0fa00593          	li	a1,250
ffffffffc020120c:	00003517          	auipc	a0,0x3
ffffffffc0201210:	77450513          	addi	a0,a0,1908 # ffffffffc0204980 <commands+0x820>
ffffffffc0201214:	fcbfe0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(vma4 == NULL);
ffffffffc0201218:	00004697          	auipc	a3,0x4
ffffffffc020121c:	85868693          	addi	a3,a3,-1960 # ffffffffc0204a70 <commands+0x910>
ffffffffc0201220:	00003617          	auipc	a2,0x3
ffffffffc0201224:	74860613          	addi	a2,a2,1864 # ffffffffc0204968 <commands+0x808>
ffffffffc0201228:	0f800593          	li	a1,248
ffffffffc020122c:	00003517          	auipc	a0,0x3
ffffffffc0201230:	75450513          	addi	a0,a0,1876 # ffffffffc0204980 <commands+0x820>
ffffffffc0201234:	fabfe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(mm != NULL);
ffffffffc0201238:	00004697          	auipc	a3,0x4
ffffffffc020123c:	94068693          	addi	a3,a3,-1728 # ffffffffc0204b78 <commands+0xa18>
ffffffffc0201240:	00003617          	auipc	a2,0x3
ffffffffc0201244:	72860613          	addi	a2,a2,1832 # ffffffffc0204968 <commands+0x808>
ffffffffc0201248:	0d200593          	li	a1,210
ffffffffc020124c:	00003517          	auipc	a0,0x3
ffffffffc0201250:	73450513          	addi	a0,a0,1844 # ffffffffc0204980 <commands+0x820>
ffffffffc0201254:	f8bfe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201258 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201258:	c94d                	beqz	a0,ffffffffc020130a <slob_free+0xb2>
{
ffffffffc020125a:	1141                	addi	sp,sp,-16
ffffffffc020125c:	e022                	sd	s0,0(sp)
ffffffffc020125e:	e406                	sd	ra,8(sp)
ffffffffc0201260:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201262:	e9c1                	bnez	a1,ffffffffc02012f2 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201264:	100027f3          	csrr	a5,sstatus
ffffffffc0201268:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020126a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020126c:	ebd9                	bnez	a5,ffffffffc0201302 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020126e:	00008617          	auipc	a2,0x8
ffffffffc0201272:	db260613          	addi	a2,a2,-590 # ffffffffc0209020 <slobfree>
ffffffffc0201276:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201278:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020127a:	679c                	ld	a5,8(a5)
ffffffffc020127c:	02877a63          	bgeu	a4,s0,ffffffffc02012b0 <slob_free+0x58>
ffffffffc0201280:	00f46463          	bltu	s0,a5,ffffffffc0201288 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201284:	fef76ae3          	bltu	a4,a5,ffffffffc0201278 <slob_free+0x20>
			break;

	if (b + b->units == cur->next)
ffffffffc0201288:	400c                	lw	a1,0(s0)
ffffffffc020128a:	00459693          	slli	a3,a1,0x4
ffffffffc020128e:	96a2                	add	a3,a3,s0
ffffffffc0201290:	02d78a63          	beq	a5,a3,ffffffffc02012c4 <slob_free+0x6c>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201294:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201296:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc0201298:	00469793          	slli	a5,a3,0x4
ffffffffc020129c:	97ba                	add	a5,a5,a4
ffffffffc020129e:	02f40e63          	beq	s0,a5,ffffffffc02012da <slob_free+0x82>
	{
		cur->units += b->units;
		cur->next = b->next;
	}
	else
		cur->next = b;
ffffffffc02012a2:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02012a4:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02012a6:	e129                	bnez	a0,ffffffffc02012e8 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02012a8:	60a2                	ld	ra,8(sp)
ffffffffc02012aa:	6402                	ld	s0,0(sp)
ffffffffc02012ac:	0141                	addi	sp,sp,16
ffffffffc02012ae:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02012b0:	fcf764e3          	bltu	a4,a5,ffffffffc0201278 <slob_free+0x20>
ffffffffc02012b4:	fcf472e3          	bgeu	s0,a5,ffffffffc0201278 <slob_free+0x20>
	if (b + b->units == cur->next)
ffffffffc02012b8:	400c                	lw	a1,0(s0)
ffffffffc02012ba:	00459693          	slli	a3,a1,0x4
ffffffffc02012be:	96a2                	add	a3,a3,s0
ffffffffc02012c0:	fcd79ae3          	bne	a5,a3,ffffffffc0201294 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02012c4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02012c6:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02012c8:	9db5                	addw	a1,a1,a3
ffffffffc02012ca:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b)
ffffffffc02012cc:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02012ce:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b)
ffffffffc02012d0:	00469793          	slli	a5,a3,0x4
ffffffffc02012d4:	97ba                	add	a5,a5,a4
ffffffffc02012d6:	fcf416e3          	bne	s0,a5,ffffffffc02012a2 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02012da:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc02012dc:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc02012de:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc02012e0:	9ebd                	addw	a3,a3,a5
ffffffffc02012e2:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc02012e4:	e70c                	sd	a1,8(a4)
ffffffffc02012e6:	d169                	beqz	a0,ffffffffc02012a8 <slob_free+0x50>
}
ffffffffc02012e8:	6402                	ld	s0,0(sp)
ffffffffc02012ea:	60a2                	ld	ra,8(sp)
ffffffffc02012ec:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02012ee:	e42ff06f          	j	ffffffffc0200930 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc02012f2:	25bd                	addiw	a1,a1,15
ffffffffc02012f4:	8191                	srli	a1,a1,0x4
ffffffffc02012f6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012f8:	100027f3          	csrr	a5,sstatus
ffffffffc02012fc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02012fe:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201300:	d7bd                	beqz	a5,ffffffffc020126e <slob_free+0x16>
        intr_disable();
ffffffffc0201302:	e34ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc0201306:	4505                	li	a0,1
ffffffffc0201308:	b79d                	j	ffffffffc020126e <slob_free+0x16>
ffffffffc020130a:	8082                	ret

ffffffffc020130c <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc020130c:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020130e:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201310:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201314:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201316:	5fd000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
	if (!page)
ffffffffc020131a:	c91d                	beqz	a0,ffffffffc0201350 <__slob_get_free_pages.constprop.0+0x44>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc020131c:	0000c697          	auipc	a3,0xc
ffffffffc0201320:	1946b683          	ld	a3,404(a3) # ffffffffc020d4b0 <pages>
ffffffffc0201324:	8d15                	sub	a0,a0,a3
ffffffffc0201326:	8519                	srai	a0,a0,0x6
ffffffffc0201328:	00004697          	auipc	a3,0x4
ffffffffc020132c:	6f86b683          	ld	a3,1784(a3) # ffffffffc0205a20 <nbase>
ffffffffc0201330:	9536                	add	a0,a0,a3
}

static inline void *
page2kva(struct Page *page)
{
    return KADDR(page2pa(page));
ffffffffc0201332:	00c51793          	slli	a5,a0,0xc
ffffffffc0201336:	83b1                	srli	a5,a5,0xc
ffffffffc0201338:	0000c717          	auipc	a4,0xc
ffffffffc020133c:	17073703          	ld	a4,368(a4) # ffffffffc020d4a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201340:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201342:	00e7fa63          	bgeu	a5,a4,ffffffffc0201356 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201346:	0000c697          	auipc	a3,0xc
ffffffffc020134a:	17a6b683          	ld	a3,378(a3) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc020134e:	9536                	add	a0,a0,a3
}
ffffffffc0201350:	60a2                	ld	ra,8(sp)
ffffffffc0201352:	0141                	addi	sp,sp,16
ffffffffc0201354:	8082                	ret
ffffffffc0201356:	86aa                	mv	a3,a0
ffffffffc0201358:	00004617          	auipc	a2,0x4
ffffffffc020135c:	83060613          	addi	a2,a2,-2000 # ffffffffc0204b88 <commands+0xa28>
ffffffffc0201360:	07100593          	li	a1,113
ffffffffc0201364:	00004517          	auipc	a0,0x4
ffffffffc0201368:	84c50513          	addi	a0,a0,-1972 # ffffffffc0204bb0 <commands+0xa50>
ffffffffc020136c:	e73fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201370 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201370:	1101                	addi	sp,sp,-32
ffffffffc0201372:	ec06                	sd	ra,24(sp)
ffffffffc0201374:	e822                	sd	s0,16(sp)
ffffffffc0201376:	e426                	sd	s1,8(sp)
ffffffffc0201378:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc020137a:	01050713          	addi	a4,a0,16
ffffffffc020137e:	6785                	lui	a5,0x1
ffffffffc0201380:	0cf77363          	bgeu	a4,a5,ffffffffc0201446 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201384:	00f50493          	addi	s1,a0,15
ffffffffc0201388:	8091                	srli	s1,s1,0x4
ffffffffc020138a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020138c:	10002673          	csrr	a2,sstatus
ffffffffc0201390:	8a09                	andi	a2,a2,2
ffffffffc0201392:	e25d                	bnez	a2,ffffffffc0201438 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201394:	00008917          	auipc	s2,0x8
ffffffffc0201398:	c8c90913          	addi	s2,s2,-884 # ffffffffc0209020 <slobfree>
ffffffffc020139c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013a0:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta)
ffffffffc02013a2:	4398                	lw	a4,0(a5)
ffffffffc02013a4:	08975e63          	bge	a4,s1,ffffffffc0201440 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree)
ffffffffc02013a8:	00d78b63          	beq	a5,a3,ffffffffc02013be <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013ac:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02013ae:	4018                	lw	a4,0(s0)
ffffffffc02013b0:	02975a63          	bge	a4,s1,ffffffffc02013e4 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree)
ffffffffc02013b4:	00093683          	ld	a3,0(s2)
ffffffffc02013b8:	87a2                	mv	a5,s0
ffffffffc02013ba:	fed799e3          	bne	a5,a3,ffffffffc02013ac <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02013be:	ee31                	bnez	a2,ffffffffc020141a <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02013c0:	4501                	li	a0,0
ffffffffc02013c2:	f4bff0ef          	jal	ra,ffffffffc020130c <__slob_get_free_pages.constprop.0>
ffffffffc02013c6:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02013c8:	cd05                	beqz	a0,ffffffffc0201400 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc02013ca:	6585                	lui	a1,0x1
ffffffffc02013cc:	e8dff0ef          	jal	ra,ffffffffc0201258 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013d0:	10002673          	csrr	a2,sstatus
ffffffffc02013d4:	8a09                	andi	a2,a2,2
ffffffffc02013d6:	ee05                	bnez	a2,ffffffffc020140e <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02013d8:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02013dc:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta)
ffffffffc02013de:	4018                	lw	a4,0(s0)
ffffffffc02013e0:	fc974ae3          	blt	a4,s1,ffffffffc02013b4 <slob_alloc.constprop.0+0x44>
			if (cur->units == units)	/* exact fit? */
ffffffffc02013e4:	04e48763          	beq	s1,a4,ffffffffc0201432 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc02013e8:	00449693          	slli	a3,s1,0x4
ffffffffc02013ec:	96a2                	add	a3,a3,s0
ffffffffc02013ee:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02013f0:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc02013f2:	9f05                	subw	a4,a4,s1
ffffffffc02013f4:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02013f6:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02013f8:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc02013fa:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc02013fe:	e20d                	bnez	a2,ffffffffc0201420 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201400:	60e2                	ld	ra,24(sp)
ffffffffc0201402:	8522                	mv	a0,s0
ffffffffc0201404:	6442                	ld	s0,16(sp)
ffffffffc0201406:	64a2                	ld	s1,8(sp)
ffffffffc0201408:	6902                	ld	s2,0(sp)
ffffffffc020140a:	6105                	addi	sp,sp,32
ffffffffc020140c:	8082                	ret
        intr_disable();
ffffffffc020140e:	d28ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
			cur = slobfree;
ffffffffc0201412:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201416:	4605                	li	a2,1
ffffffffc0201418:	b7d1                	j	ffffffffc02013dc <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc020141a:	d16ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020141e:	b74d                	j	ffffffffc02013c0 <slob_alloc.constprop.0+0x50>
ffffffffc0201420:	d10ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
}
ffffffffc0201424:	60e2                	ld	ra,24(sp)
ffffffffc0201426:	8522                	mv	a0,s0
ffffffffc0201428:	6442                	ld	s0,16(sp)
ffffffffc020142a:	64a2                	ld	s1,8(sp)
ffffffffc020142c:	6902                	ld	s2,0(sp)
ffffffffc020142e:	6105                	addi	sp,sp,32
ffffffffc0201430:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201432:	6418                	ld	a4,8(s0)
ffffffffc0201434:	e798                	sd	a4,8(a5)
ffffffffc0201436:	b7d1                	j	ffffffffc02013fa <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201438:	cfeff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc020143c:	4605                	li	a2,1
ffffffffc020143e:	bf99                	j	ffffffffc0201394 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta)
ffffffffc0201440:	843e                	mv	s0,a5
ffffffffc0201442:	87b6                	mv	a5,a3
ffffffffc0201444:	b745                	j	ffffffffc02013e4 <slob_alloc.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201446:	00003697          	auipc	a3,0x3
ffffffffc020144a:	77a68693          	addi	a3,a3,1914 # ffffffffc0204bc0 <commands+0xa60>
ffffffffc020144e:	00003617          	auipc	a2,0x3
ffffffffc0201452:	51a60613          	addi	a2,a2,1306 # ffffffffc0204968 <commands+0x808>
ffffffffc0201456:	06300593          	li	a1,99
ffffffffc020145a:	00003517          	auipc	a0,0x3
ffffffffc020145e:	78650513          	addi	a0,a0,1926 # ffffffffc0204be0 <commands+0xa80>
ffffffffc0201462:	d7dfe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201466 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201466:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201468:	00003517          	auipc	a0,0x3
ffffffffc020146c:	79050513          	addi	a0,a0,1936 # ffffffffc0204bf8 <commands+0xa98>
{
ffffffffc0201470:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201472:	c6ffe0ef          	jal	ra,ffffffffc02000e0 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201476:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201478:	00003517          	auipc	a0,0x3
ffffffffc020147c:	79850513          	addi	a0,a0,1944 # ffffffffc0204c10 <commands+0xab0>
}
ffffffffc0201480:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201482:	c5ffe06f          	j	ffffffffc02000e0 <cprintf>

ffffffffc0201486 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201486:	1101                	addi	sp,sp,-32
ffffffffc0201488:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc020148a:	6905                	lui	s2,0x1
{
ffffffffc020148c:	e822                	sd	s0,16(sp)
ffffffffc020148e:	ec06                	sd	ra,24(sp)
ffffffffc0201490:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201492:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201496:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201498:	04a7f963          	bgeu	a5,a0,ffffffffc02014ea <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020149c:	4561                	li	a0,24
ffffffffc020149e:	ed3ff0ef          	jal	ra,ffffffffc0201370 <slob_alloc.constprop.0>
ffffffffc02014a2:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02014a4:	c929                	beqz	a0,ffffffffc02014f6 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc02014a6:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02014aa:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc02014ac:	00f95763          	bge	s2,a5,ffffffffc02014ba <kmalloc+0x34>
ffffffffc02014b0:	6705                	lui	a4,0x1
ffffffffc02014b2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02014b4:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc02014b6:	fef74ee3          	blt	a4,a5,ffffffffc02014b2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02014ba:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02014bc:	e51ff0ef          	jal	ra,ffffffffc020130c <__slob_get_free_pages.constprop.0>
ffffffffc02014c0:	e488                	sd	a0,8(s1)
ffffffffc02014c2:	842a                	mv	s0,a0
	if (bb->pages)
ffffffffc02014c4:	c525                	beqz	a0,ffffffffc020152c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02014c6:	100027f3          	csrr	a5,sstatus
ffffffffc02014ca:	8b89                	andi	a5,a5,2
ffffffffc02014cc:	ef8d                	bnez	a5,ffffffffc0201506 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc02014ce:	0000c797          	auipc	a5,0xc
ffffffffc02014d2:	fc278793          	addi	a5,a5,-62 # ffffffffc020d490 <bigblocks>
ffffffffc02014d6:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc02014d8:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02014da:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc02014dc:	60e2                	ld	ra,24(sp)
ffffffffc02014de:	8522                	mv	a0,s0
ffffffffc02014e0:	6442                	ld	s0,16(sp)
ffffffffc02014e2:	64a2                	ld	s1,8(sp)
ffffffffc02014e4:	6902                	ld	s2,0(sp)
ffffffffc02014e6:	6105                	addi	sp,sp,32
ffffffffc02014e8:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02014ea:	0541                	addi	a0,a0,16
ffffffffc02014ec:	e85ff0ef          	jal	ra,ffffffffc0201370 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc02014f0:	01050413          	addi	s0,a0,16
ffffffffc02014f4:	f565                	bnez	a0,ffffffffc02014dc <kmalloc+0x56>
ffffffffc02014f6:	4401                	li	s0,0
}
ffffffffc02014f8:	60e2                	ld	ra,24(sp)
ffffffffc02014fa:	8522                	mv	a0,s0
ffffffffc02014fc:	6442                	ld	s0,16(sp)
ffffffffc02014fe:	64a2                	ld	s1,8(sp)
ffffffffc0201500:	6902                	ld	s2,0(sp)
ffffffffc0201502:	6105                	addi	sp,sp,32
ffffffffc0201504:	8082                	ret
        intr_disable();
ffffffffc0201506:	c30ff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
		bb->next = bigblocks;
ffffffffc020150a:	0000c797          	auipc	a5,0xc
ffffffffc020150e:	f8678793          	addi	a5,a5,-122 # ffffffffc020d490 <bigblocks>
ffffffffc0201512:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201514:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201516:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201518:	c18ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
		return bb->pages;
ffffffffc020151c:	6480                	ld	s0,8(s1)
}
ffffffffc020151e:	60e2                	ld	ra,24(sp)
ffffffffc0201520:	64a2                	ld	s1,8(sp)
ffffffffc0201522:	8522                	mv	a0,s0
ffffffffc0201524:	6442                	ld	s0,16(sp)
ffffffffc0201526:	6902                	ld	s2,0(sp)
ffffffffc0201528:	6105                	addi	sp,sp,32
ffffffffc020152a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020152c:	45e1                	li	a1,24
ffffffffc020152e:	8526                	mv	a0,s1
ffffffffc0201530:	d29ff0ef          	jal	ra,ffffffffc0201258 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201534:	b765                	j	ffffffffc02014dc <kmalloc+0x56>

ffffffffc0201536 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201536:	c169                	beqz	a0,ffffffffc02015f8 <kfree+0xc2>
{
ffffffffc0201538:	1101                	addi	sp,sp,-32
ffffffffc020153a:	e822                	sd	s0,16(sp)
ffffffffc020153c:	ec06                	sd	ra,24(sp)
ffffffffc020153e:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201540:	03451793          	slli	a5,a0,0x34
ffffffffc0201544:	842a                	mv	s0,a0
ffffffffc0201546:	e3d9                	bnez	a5,ffffffffc02015cc <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201548:	100027f3          	csrr	a5,sstatus
ffffffffc020154c:	8b89                	andi	a5,a5,2
ffffffffc020154e:	e7d9                	bnez	a5,ffffffffc02015dc <kfree+0xa6>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201550:	0000c797          	auipc	a5,0xc
ffffffffc0201554:	f407b783          	ld	a5,-192(a5) # ffffffffc020d490 <bigblocks>
    return 0;
ffffffffc0201558:	4601                	li	a2,0
ffffffffc020155a:	cbad                	beqz	a5,ffffffffc02015cc <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc020155c:	0000c697          	auipc	a3,0xc
ffffffffc0201560:	f3468693          	addi	a3,a3,-204 # ffffffffc020d490 <bigblocks>
ffffffffc0201564:	a021                	j	ffffffffc020156c <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201566:	01048693          	addi	a3,s1,16
ffffffffc020156a:	c3a5                	beqz	a5,ffffffffc02015ca <kfree+0x94>
		{
			if (bb->pages == block)
ffffffffc020156c:	6798                	ld	a4,8(a5)
ffffffffc020156e:	84be                	mv	s1,a5
			{
				*last = bb->next;
ffffffffc0201570:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201572:	fe871ae3          	bne	a4,s0,ffffffffc0201566 <kfree+0x30>
				*last = bb->next;
ffffffffc0201576:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201578:	ee2d                	bnez	a2,ffffffffc02015f2 <kfree+0xbc>
}

static inline struct Page *
kva2page(void *kva)
{
    return pa2page(PADDR(kva));
ffffffffc020157a:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc020157e:	4098                	lw	a4,0(s1)
ffffffffc0201580:	08f46963          	bltu	s0,a5,ffffffffc0201612 <kfree+0xdc>
ffffffffc0201584:	0000c697          	auipc	a3,0xc
ffffffffc0201588:	f3c6b683          	ld	a3,-196(a3) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc020158c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage)
ffffffffc020158e:	8031                	srli	s0,s0,0xc
ffffffffc0201590:	0000c797          	auipc	a5,0xc
ffffffffc0201594:	f187b783          	ld	a5,-232(a5) # ffffffffc020d4a8 <npage>
ffffffffc0201598:	06f47163          	bgeu	s0,a5,ffffffffc02015fa <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc020159c:	00004517          	auipc	a0,0x4
ffffffffc02015a0:	48453503          	ld	a0,1156(a0) # ffffffffc0205a20 <nbase>
ffffffffc02015a4:	8c09                	sub	s0,s0,a0
ffffffffc02015a6:	041a                	slli	s0,s0,0x6
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc02015a8:	0000c517          	auipc	a0,0xc
ffffffffc02015ac:	f0853503          	ld	a0,-248(a0) # ffffffffc020d4b0 <pages>
ffffffffc02015b0:	4585                	li	a1,1
ffffffffc02015b2:	9522                	add	a0,a0,s0
ffffffffc02015b4:	00e595bb          	sllw	a1,a1,a4
ffffffffc02015b8:	399000ef          	jal	ra,ffffffffc0202150 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02015bc:	6442                	ld	s0,16(sp)
ffffffffc02015be:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02015c0:	8526                	mv	a0,s1
}
ffffffffc02015c2:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02015c4:	45e1                	li	a1,24
}
ffffffffc02015c6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02015c8:	b941                	j	ffffffffc0201258 <slob_free>
ffffffffc02015ca:	e20d                	bnez	a2,ffffffffc02015ec <kfree+0xb6>
ffffffffc02015cc:	ff040513          	addi	a0,s0,-16
}
ffffffffc02015d0:	6442                	ld	s0,16(sp)
ffffffffc02015d2:	60e2                	ld	ra,24(sp)
ffffffffc02015d4:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02015d6:	4581                	li	a1,0
}
ffffffffc02015d8:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02015da:	b9bd                	j	ffffffffc0201258 <slob_free>
        intr_disable();
ffffffffc02015dc:	b5aff0ef          	jal	ra,ffffffffc0200936 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02015e0:	0000c797          	auipc	a5,0xc
ffffffffc02015e4:	eb07b783          	ld	a5,-336(a5) # ffffffffc020d490 <bigblocks>
        return 1;
ffffffffc02015e8:	4605                	li	a2,1
ffffffffc02015ea:	fbad                	bnez	a5,ffffffffc020155c <kfree+0x26>
        intr_enable();
ffffffffc02015ec:	b44ff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02015f0:	bff1                	j	ffffffffc02015cc <kfree+0x96>
ffffffffc02015f2:	b3eff0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02015f6:	b751                	j	ffffffffc020157a <kfree+0x44>
ffffffffc02015f8:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02015fa:	00003617          	auipc	a2,0x3
ffffffffc02015fe:	65e60613          	addi	a2,a2,1630 # ffffffffc0204c58 <commands+0xaf8>
ffffffffc0201602:	06900593          	li	a1,105
ffffffffc0201606:	00003517          	auipc	a0,0x3
ffffffffc020160a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0204bb0 <commands+0xa50>
ffffffffc020160e:	bd1fe0ef          	jal	ra,ffffffffc02001de <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201612:	86a2                	mv	a3,s0
ffffffffc0201614:	00003617          	auipc	a2,0x3
ffffffffc0201618:	61c60613          	addi	a2,a2,1564 # ffffffffc0204c30 <commands+0xad0>
ffffffffc020161c:	07700593          	li	a1,119
ffffffffc0201620:	00003517          	auipc	a0,0x3
ffffffffc0201624:	59050513          	addi	a0,a0,1424 # ffffffffc0204bb0 <commands+0xa50>
ffffffffc0201628:	bb7fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020162c <default_init>:
    elm->prev = elm->next = elm;
ffffffffc020162c:	00008797          	auipc	a5,0x8
ffffffffc0201630:	e0478793          	addi	a5,a5,-508 # ffffffffc0209430 <free_area>
ffffffffc0201634:	e79c                	sd	a5,8(a5)
ffffffffc0201636:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201638:	0007a823          	sw	zero,16(a5)
}
ffffffffc020163c:	8082                	ret

ffffffffc020163e <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020163e:	00008517          	auipc	a0,0x8
ffffffffc0201642:	e0256503          	lwu	a0,-510(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc0201646:	8082                	ret

ffffffffc0201648 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201648:	715d                	addi	sp,sp,-80
ffffffffc020164a:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020164c:	00008417          	auipc	s0,0x8
ffffffffc0201650:	de440413          	addi	s0,s0,-540 # ffffffffc0209430 <free_area>
ffffffffc0201654:	641c                	ld	a5,8(s0)
ffffffffc0201656:	e486                	sd	ra,72(sp)
ffffffffc0201658:	fc26                	sd	s1,56(sp)
ffffffffc020165a:	f84a                	sd	s2,48(sp)
ffffffffc020165c:	f44e                	sd	s3,40(sp)
ffffffffc020165e:	f052                	sd	s4,32(sp)
ffffffffc0201660:	ec56                	sd	s5,24(sp)
ffffffffc0201662:	e85a                	sd	s6,16(sp)
ffffffffc0201664:	e45e                	sd	s7,8(sp)
ffffffffc0201666:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201668:	2a878d63          	beq	a5,s0,ffffffffc0201922 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020166c:	4481                	li	s1,0
ffffffffc020166e:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201670:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201674:	8b09                	andi	a4,a4,2
ffffffffc0201676:	2a070a63          	beqz	a4,ffffffffc020192a <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc020167a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020167e:	679c                	ld	a5,8(a5)
ffffffffc0201680:	2905                	addiw	s2,s2,1
ffffffffc0201682:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201684:	fe8796e3          	bne	a5,s0,ffffffffc0201670 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201688:	89a6                	mv	s3,s1
ffffffffc020168a:	307000ef          	jal	ra,ffffffffc0202190 <nr_free_pages>
ffffffffc020168e:	6f351e63          	bne	a0,s3,ffffffffc0201d8a <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201692:	4505                	li	a0,1
ffffffffc0201694:	27f000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201698:	8aaa                	mv	s5,a0
ffffffffc020169a:	42050863          	beqz	a0,ffffffffc0201aca <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020169e:	4505                	li	a0,1
ffffffffc02016a0:	273000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02016a4:	89aa                	mv	s3,a0
ffffffffc02016a6:	70050263          	beqz	a0,ffffffffc0201daa <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02016aa:	4505                	li	a0,1
ffffffffc02016ac:	267000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02016b0:	8a2a                	mv	s4,a0
ffffffffc02016b2:	48050c63          	beqz	a0,ffffffffc0201b4a <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02016b6:	293a8a63          	beq	s5,s3,ffffffffc020194a <default_check+0x302>
ffffffffc02016ba:	28aa8863          	beq	s5,a0,ffffffffc020194a <default_check+0x302>
ffffffffc02016be:	28a98663          	beq	s3,a0,ffffffffc020194a <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02016c2:	000aa783          	lw	a5,0(s5)
ffffffffc02016c6:	2a079263          	bnez	a5,ffffffffc020196a <default_check+0x322>
ffffffffc02016ca:	0009a783          	lw	a5,0(s3)
ffffffffc02016ce:	28079e63          	bnez	a5,ffffffffc020196a <default_check+0x322>
ffffffffc02016d2:	411c                	lw	a5,0(a0)
ffffffffc02016d4:	28079b63          	bnez	a5,ffffffffc020196a <default_check+0x322>
    return page - pages + nbase;
ffffffffc02016d8:	0000c797          	auipc	a5,0xc
ffffffffc02016dc:	dd87b783          	ld	a5,-552(a5) # ffffffffc020d4b0 <pages>
ffffffffc02016e0:	40fa8733          	sub	a4,s5,a5
ffffffffc02016e4:	00004617          	auipc	a2,0x4
ffffffffc02016e8:	33c63603          	ld	a2,828(a2) # ffffffffc0205a20 <nbase>
ffffffffc02016ec:	8719                	srai	a4,a4,0x6
ffffffffc02016ee:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02016f0:	0000c697          	auipc	a3,0xc
ffffffffc02016f4:	db86b683          	ld	a3,-584(a3) # ffffffffc020d4a8 <npage>
ffffffffc02016f8:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02016fa:	0732                	slli	a4,a4,0xc
ffffffffc02016fc:	28d77763          	bgeu	a4,a3,ffffffffc020198a <default_check+0x342>
    return page - pages + nbase;
ffffffffc0201700:	40f98733          	sub	a4,s3,a5
ffffffffc0201704:	8719                	srai	a4,a4,0x6
ffffffffc0201706:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201708:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020170a:	4cd77063          	bgeu	a4,a3,ffffffffc0201bca <default_check+0x582>
    return page - pages + nbase;
ffffffffc020170e:	40f507b3          	sub	a5,a0,a5
ffffffffc0201712:	8799                	srai	a5,a5,0x6
ffffffffc0201714:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201716:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201718:	30d7f963          	bgeu	a5,a3,ffffffffc0201a2a <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc020171c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020171e:	00043c03          	ld	s8,0(s0)
ffffffffc0201722:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201726:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020172a:	e400                	sd	s0,8(s0)
ffffffffc020172c:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc020172e:	00008797          	auipc	a5,0x8
ffffffffc0201732:	d007a923          	sw	zero,-750(a5) # ffffffffc0209440 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201736:	1dd000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc020173a:	2c051863          	bnez	a0,ffffffffc0201a0a <default_check+0x3c2>
    free_page(p0);
ffffffffc020173e:	4585                	li	a1,1
ffffffffc0201740:	8556                	mv	a0,s5
ffffffffc0201742:	20f000ef          	jal	ra,ffffffffc0202150 <free_pages>
    free_page(p1);
ffffffffc0201746:	4585                	li	a1,1
ffffffffc0201748:	854e                	mv	a0,s3
ffffffffc020174a:	207000ef          	jal	ra,ffffffffc0202150 <free_pages>
    free_page(p2);
ffffffffc020174e:	4585                	li	a1,1
ffffffffc0201750:	8552                	mv	a0,s4
ffffffffc0201752:	1ff000ef          	jal	ra,ffffffffc0202150 <free_pages>
    assert(nr_free == 3);
ffffffffc0201756:	4818                	lw	a4,16(s0)
ffffffffc0201758:	478d                	li	a5,3
ffffffffc020175a:	28f71863          	bne	a4,a5,ffffffffc02019ea <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020175e:	4505                	li	a0,1
ffffffffc0201760:	1b3000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201764:	89aa                	mv	s3,a0
ffffffffc0201766:	26050263          	beqz	a0,ffffffffc02019ca <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020176a:	4505                	li	a0,1
ffffffffc020176c:	1a7000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201770:	8aaa                	mv	s5,a0
ffffffffc0201772:	3a050c63          	beqz	a0,ffffffffc0201b2a <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201776:	4505                	li	a0,1
ffffffffc0201778:	19b000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc020177c:	8a2a                	mv	s4,a0
ffffffffc020177e:	38050663          	beqz	a0,ffffffffc0201b0a <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0201782:	4505                	li	a0,1
ffffffffc0201784:	18f000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201788:	36051163          	bnez	a0,ffffffffc0201aea <default_check+0x4a2>
    free_page(p0);
ffffffffc020178c:	4585                	li	a1,1
ffffffffc020178e:	854e                	mv	a0,s3
ffffffffc0201790:	1c1000ef          	jal	ra,ffffffffc0202150 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201794:	641c                	ld	a5,8(s0)
ffffffffc0201796:	20878a63          	beq	a5,s0,ffffffffc02019aa <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc020179a:	4505                	li	a0,1
ffffffffc020179c:	177000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02017a0:	30a99563          	bne	s3,a0,ffffffffc0201aaa <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc02017a4:	4505                	li	a0,1
ffffffffc02017a6:	16d000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02017aa:	2e051063          	bnez	a0,ffffffffc0201a8a <default_check+0x442>
    assert(nr_free == 0);
ffffffffc02017ae:	481c                	lw	a5,16(s0)
ffffffffc02017b0:	2a079d63          	bnez	a5,ffffffffc0201a6a <default_check+0x422>
    free_page(p);
ffffffffc02017b4:	854e                	mv	a0,s3
ffffffffc02017b6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02017b8:	01843023          	sd	s8,0(s0)
ffffffffc02017bc:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02017c0:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02017c4:	18d000ef          	jal	ra,ffffffffc0202150 <free_pages>
    free_page(p1);
ffffffffc02017c8:	4585                	li	a1,1
ffffffffc02017ca:	8556                	mv	a0,s5
ffffffffc02017cc:	185000ef          	jal	ra,ffffffffc0202150 <free_pages>
    free_page(p2);
ffffffffc02017d0:	4585                	li	a1,1
ffffffffc02017d2:	8552                	mv	a0,s4
ffffffffc02017d4:	17d000ef          	jal	ra,ffffffffc0202150 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02017d8:	4515                	li	a0,5
ffffffffc02017da:	139000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02017de:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02017e0:	26050563          	beqz	a0,ffffffffc0201a4a <default_check+0x402>
ffffffffc02017e4:	651c                	ld	a5,8(a0)
ffffffffc02017e6:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02017e8:	8b85                	andi	a5,a5,1
ffffffffc02017ea:	54079063          	bnez	a5,ffffffffc0201d2a <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02017ee:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02017f0:	00043b03          	ld	s6,0(s0)
ffffffffc02017f4:	00843a83          	ld	s5,8(s0)
ffffffffc02017f8:	e000                	sd	s0,0(s0)
ffffffffc02017fa:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02017fc:	117000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201800:	50051563          	bnez	a0,ffffffffc0201d0a <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201804:	08098a13          	addi	s4,s3,128
ffffffffc0201808:	8552                	mv	a0,s4
ffffffffc020180a:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020180c:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201810:	00008797          	auipc	a5,0x8
ffffffffc0201814:	c207a823          	sw	zero,-976(a5) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201818:	139000ef          	jal	ra,ffffffffc0202150 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020181c:	4511                	li	a0,4
ffffffffc020181e:	0f5000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201822:	4c051463          	bnez	a0,ffffffffc0201cea <default_check+0x6a2>
ffffffffc0201826:	0889b783          	ld	a5,136(s3)
ffffffffc020182a:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020182c:	8b85                	andi	a5,a5,1
ffffffffc020182e:	48078e63          	beqz	a5,ffffffffc0201cca <default_check+0x682>
ffffffffc0201832:	0909a703          	lw	a4,144(s3)
ffffffffc0201836:	478d                	li	a5,3
ffffffffc0201838:	48f71963          	bne	a4,a5,ffffffffc0201cca <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020183c:	450d                	li	a0,3
ffffffffc020183e:	0d5000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc0201842:	8c2a                	mv	s8,a0
ffffffffc0201844:	46050363          	beqz	a0,ffffffffc0201caa <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0201848:	4505                	li	a0,1
ffffffffc020184a:	0c9000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc020184e:	42051e63          	bnez	a0,ffffffffc0201c8a <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201852:	418a1c63          	bne	s4,s8,ffffffffc0201c6a <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201856:	4585                	li	a1,1
ffffffffc0201858:	854e                	mv	a0,s3
ffffffffc020185a:	0f7000ef          	jal	ra,ffffffffc0202150 <free_pages>
    free_pages(p1, 3);
ffffffffc020185e:	458d                	li	a1,3
ffffffffc0201860:	8552                	mv	a0,s4
ffffffffc0201862:	0ef000ef          	jal	ra,ffffffffc0202150 <free_pages>
ffffffffc0201866:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020186a:	04098c13          	addi	s8,s3,64
ffffffffc020186e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201870:	8b85                	andi	a5,a5,1
ffffffffc0201872:	3c078c63          	beqz	a5,ffffffffc0201c4a <default_check+0x602>
ffffffffc0201876:	0109a703          	lw	a4,16(s3)
ffffffffc020187a:	4785                	li	a5,1
ffffffffc020187c:	3cf71763          	bne	a4,a5,ffffffffc0201c4a <default_check+0x602>
ffffffffc0201880:	008a3783          	ld	a5,8(s4)
ffffffffc0201884:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201886:	8b85                	andi	a5,a5,1
ffffffffc0201888:	3a078163          	beqz	a5,ffffffffc0201c2a <default_check+0x5e2>
ffffffffc020188c:	010a2703          	lw	a4,16(s4)
ffffffffc0201890:	478d                	li	a5,3
ffffffffc0201892:	38f71c63          	bne	a4,a5,ffffffffc0201c2a <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201896:	4505                	li	a0,1
ffffffffc0201898:	07b000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc020189c:	36a99763          	bne	s3,a0,ffffffffc0201c0a <default_check+0x5c2>
    free_page(p0);
ffffffffc02018a0:	4585                	li	a1,1
ffffffffc02018a2:	0af000ef          	jal	ra,ffffffffc0202150 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02018a6:	4509                	li	a0,2
ffffffffc02018a8:	06b000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02018ac:	32aa1f63          	bne	s4,a0,ffffffffc0201bea <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02018b0:	4589                	li	a1,2
ffffffffc02018b2:	09f000ef          	jal	ra,ffffffffc0202150 <free_pages>
    free_page(p2);
ffffffffc02018b6:	4585                	li	a1,1
ffffffffc02018b8:	8562                	mv	a0,s8
ffffffffc02018ba:	097000ef          	jal	ra,ffffffffc0202150 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02018be:	4515                	li	a0,5
ffffffffc02018c0:	053000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02018c4:	89aa                	mv	s3,a0
ffffffffc02018c6:	48050263          	beqz	a0,ffffffffc0201d4a <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02018ca:	4505                	li	a0,1
ffffffffc02018cc:	047000ef          	jal	ra,ffffffffc0202112 <alloc_pages>
ffffffffc02018d0:	2c051d63          	bnez	a0,ffffffffc0201baa <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02018d4:	481c                	lw	a5,16(s0)
ffffffffc02018d6:	2a079a63          	bnez	a5,ffffffffc0201b8a <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02018da:	4595                	li	a1,5
ffffffffc02018dc:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02018de:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02018e2:	01643023          	sd	s6,0(s0)
ffffffffc02018e6:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02018ea:	067000ef          	jal	ra,ffffffffc0202150 <free_pages>
    return listelm->next;
ffffffffc02018ee:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02018f0:	00878963          	beq	a5,s0,ffffffffc0201902 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02018f4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02018f8:	679c                	ld	a5,8(a5)
ffffffffc02018fa:	397d                	addiw	s2,s2,-1
ffffffffc02018fc:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02018fe:	fe879be3          	bne	a5,s0,ffffffffc02018f4 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc0201902:	26091463          	bnez	s2,ffffffffc0201b6a <default_check+0x522>
    assert(total == 0);
ffffffffc0201906:	46049263          	bnez	s1,ffffffffc0201d6a <default_check+0x722>
}
ffffffffc020190a:	60a6                	ld	ra,72(sp)
ffffffffc020190c:	6406                	ld	s0,64(sp)
ffffffffc020190e:	74e2                	ld	s1,56(sp)
ffffffffc0201910:	7942                	ld	s2,48(sp)
ffffffffc0201912:	79a2                	ld	s3,40(sp)
ffffffffc0201914:	7a02                	ld	s4,32(sp)
ffffffffc0201916:	6ae2                	ld	s5,24(sp)
ffffffffc0201918:	6b42                	ld	s6,16(sp)
ffffffffc020191a:	6ba2                	ld	s7,8(sp)
ffffffffc020191c:	6c02                	ld	s8,0(sp)
ffffffffc020191e:	6161                	addi	sp,sp,80
ffffffffc0201920:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201922:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201924:	4481                	li	s1,0
ffffffffc0201926:	4901                	li	s2,0
ffffffffc0201928:	b38d                	j	ffffffffc020168a <default_check+0x42>
        assert(PageProperty(p));
ffffffffc020192a:	00003697          	auipc	a3,0x3
ffffffffc020192e:	34e68693          	addi	a3,a3,846 # ffffffffc0204c78 <commands+0xb18>
ffffffffc0201932:	00003617          	auipc	a2,0x3
ffffffffc0201936:	03660613          	addi	a2,a2,54 # ffffffffc0204968 <commands+0x808>
ffffffffc020193a:	0f000593          	li	a1,240
ffffffffc020193e:	00003517          	auipc	a0,0x3
ffffffffc0201942:	34a50513          	addi	a0,a0,842 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201946:	899fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020194a:	00003697          	auipc	a3,0x3
ffffffffc020194e:	3d668693          	addi	a3,a3,982 # ffffffffc0204d20 <commands+0xbc0>
ffffffffc0201952:	00003617          	auipc	a2,0x3
ffffffffc0201956:	01660613          	addi	a2,a2,22 # ffffffffc0204968 <commands+0x808>
ffffffffc020195a:	0bd00593          	li	a1,189
ffffffffc020195e:	00003517          	auipc	a0,0x3
ffffffffc0201962:	32a50513          	addi	a0,a0,810 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201966:	879fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020196a:	00003697          	auipc	a3,0x3
ffffffffc020196e:	3de68693          	addi	a3,a3,990 # ffffffffc0204d48 <commands+0xbe8>
ffffffffc0201972:	00003617          	auipc	a2,0x3
ffffffffc0201976:	ff660613          	addi	a2,a2,-10 # ffffffffc0204968 <commands+0x808>
ffffffffc020197a:	0be00593          	li	a1,190
ffffffffc020197e:	00003517          	auipc	a0,0x3
ffffffffc0201982:	30a50513          	addi	a0,a0,778 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201986:	859fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020198a:	00003697          	auipc	a3,0x3
ffffffffc020198e:	3fe68693          	addi	a3,a3,1022 # ffffffffc0204d88 <commands+0xc28>
ffffffffc0201992:	00003617          	auipc	a2,0x3
ffffffffc0201996:	fd660613          	addi	a2,a2,-42 # ffffffffc0204968 <commands+0x808>
ffffffffc020199a:	0c000593          	li	a1,192
ffffffffc020199e:	00003517          	auipc	a0,0x3
ffffffffc02019a2:	2ea50513          	addi	a0,a0,746 # ffffffffc0204c88 <commands+0xb28>
ffffffffc02019a6:	839fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(!list_empty(&free_list));
ffffffffc02019aa:	00003697          	auipc	a3,0x3
ffffffffc02019ae:	46668693          	addi	a3,a3,1126 # ffffffffc0204e10 <commands+0xcb0>
ffffffffc02019b2:	00003617          	auipc	a2,0x3
ffffffffc02019b6:	fb660613          	addi	a2,a2,-74 # ffffffffc0204968 <commands+0x808>
ffffffffc02019ba:	0d900593          	li	a1,217
ffffffffc02019be:	00003517          	auipc	a0,0x3
ffffffffc02019c2:	2ca50513          	addi	a0,a0,714 # ffffffffc0204c88 <commands+0xb28>
ffffffffc02019c6:	819fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02019ca:	00003697          	auipc	a3,0x3
ffffffffc02019ce:	2f668693          	addi	a3,a3,758 # ffffffffc0204cc0 <commands+0xb60>
ffffffffc02019d2:	00003617          	auipc	a2,0x3
ffffffffc02019d6:	f9660613          	addi	a2,a2,-106 # ffffffffc0204968 <commands+0x808>
ffffffffc02019da:	0d200593          	li	a1,210
ffffffffc02019de:	00003517          	auipc	a0,0x3
ffffffffc02019e2:	2aa50513          	addi	a0,a0,682 # ffffffffc0204c88 <commands+0xb28>
ffffffffc02019e6:	ff8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 3);
ffffffffc02019ea:	00003697          	auipc	a3,0x3
ffffffffc02019ee:	41668693          	addi	a3,a3,1046 # ffffffffc0204e00 <commands+0xca0>
ffffffffc02019f2:	00003617          	auipc	a2,0x3
ffffffffc02019f6:	f7660613          	addi	a2,a2,-138 # ffffffffc0204968 <commands+0x808>
ffffffffc02019fa:	0d000593          	li	a1,208
ffffffffc02019fe:	00003517          	auipc	a0,0x3
ffffffffc0201a02:	28a50513          	addi	a0,a0,650 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201a06:	fd8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201a0a:	00003697          	auipc	a3,0x3
ffffffffc0201a0e:	3de68693          	addi	a3,a3,990 # ffffffffc0204de8 <commands+0xc88>
ffffffffc0201a12:	00003617          	auipc	a2,0x3
ffffffffc0201a16:	f5660613          	addi	a2,a2,-170 # ffffffffc0204968 <commands+0x808>
ffffffffc0201a1a:	0cb00593          	li	a1,203
ffffffffc0201a1e:	00003517          	auipc	a0,0x3
ffffffffc0201a22:	26a50513          	addi	a0,a0,618 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201a26:	fb8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201a2a:	00003697          	auipc	a3,0x3
ffffffffc0201a2e:	39e68693          	addi	a3,a3,926 # ffffffffc0204dc8 <commands+0xc68>
ffffffffc0201a32:	00003617          	auipc	a2,0x3
ffffffffc0201a36:	f3660613          	addi	a2,a2,-202 # ffffffffc0204968 <commands+0x808>
ffffffffc0201a3a:	0c200593          	li	a1,194
ffffffffc0201a3e:	00003517          	auipc	a0,0x3
ffffffffc0201a42:	24a50513          	addi	a0,a0,586 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201a46:	f98fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 != NULL);
ffffffffc0201a4a:	00003697          	auipc	a3,0x3
ffffffffc0201a4e:	40e68693          	addi	a3,a3,1038 # ffffffffc0204e58 <commands+0xcf8>
ffffffffc0201a52:	00003617          	auipc	a2,0x3
ffffffffc0201a56:	f1660613          	addi	a2,a2,-234 # ffffffffc0204968 <commands+0x808>
ffffffffc0201a5a:	0f800593          	li	a1,248
ffffffffc0201a5e:	00003517          	auipc	a0,0x3
ffffffffc0201a62:	22a50513          	addi	a0,a0,554 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201a66:	f78fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 0);
ffffffffc0201a6a:	00003697          	auipc	a3,0x3
ffffffffc0201a6e:	3de68693          	addi	a3,a3,990 # ffffffffc0204e48 <commands+0xce8>
ffffffffc0201a72:	00003617          	auipc	a2,0x3
ffffffffc0201a76:	ef660613          	addi	a2,a2,-266 # ffffffffc0204968 <commands+0x808>
ffffffffc0201a7a:	0df00593          	li	a1,223
ffffffffc0201a7e:	00003517          	auipc	a0,0x3
ffffffffc0201a82:	20a50513          	addi	a0,a0,522 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201a86:	f58fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201a8a:	00003697          	auipc	a3,0x3
ffffffffc0201a8e:	35e68693          	addi	a3,a3,862 # ffffffffc0204de8 <commands+0xc88>
ffffffffc0201a92:	00003617          	auipc	a2,0x3
ffffffffc0201a96:	ed660613          	addi	a2,a2,-298 # ffffffffc0204968 <commands+0x808>
ffffffffc0201a9a:	0dd00593          	li	a1,221
ffffffffc0201a9e:	00003517          	auipc	a0,0x3
ffffffffc0201aa2:	1ea50513          	addi	a0,a0,490 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201aa6:	f38fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201aaa:	00003697          	auipc	a3,0x3
ffffffffc0201aae:	37e68693          	addi	a3,a3,894 # ffffffffc0204e28 <commands+0xcc8>
ffffffffc0201ab2:	00003617          	auipc	a2,0x3
ffffffffc0201ab6:	eb660613          	addi	a2,a2,-330 # ffffffffc0204968 <commands+0x808>
ffffffffc0201aba:	0dc00593          	li	a1,220
ffffffffc0201abe:	00003517          	auipc	a0,0x3
ffffffffc0201ac2:	1ca50513          	addi	a0,a0,458 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201ac6:	f18fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201aca:	00003697          	auipc	a3,0x3
ffffffffc0201ace:	1f668693          	addi	a3,a3,502 # ffffffffc0204cc0 <commands+0xb60>
ffffffffc0201ad2:	00003617          	auipc	a2,0x3
ffffffffc0201ad6:	e9660613          	addi	a2,a2,-362 # ffffffffc0204968 <commands+0x808>
ffffffffc0201ada:	0b900593          	li	a1,185
ffffffffc0201ade:	00003517          	auipc	a0,0x3
ffffffffc0201ae2:	1aa50513          	addi	a0,a0,426 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201ae6:	ef8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201aea:	00003697          	auipc	a3,0x3
ffffffffc0201aee:	2fe68693          	addi	a3,a3,766 # ffffffffc0204de8 <commands+0xc88>
ffffffffc0201af2:	00003617          	auipc	a2,0x3
ffffffffc0201af6:	e7660613          	addi	a2,a2,-394 # ffffffffc0204968 <commands+0x808>
ffffffffc0201afa:	0d600593          	li	a1,214
ffffffffc0201afe:	00003517          	auipc	a0,0x3
ffffffffc0201b02:	18a50513          	addi	a0,a0,394 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201b06:	ed8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b0a:	00003697          	auipc	a3,0x3
ffffffffc0201b0e:	1f668693          	addi	a3,a3,502 # ffffffffc0204d00 <commands+0xba0>
ffffffffc0201b12:	00003617          	auipc	a2,0x3
ffffffffc0201b16:	e5660613          	addi	a2,a2,-426 # ffffffffc0204968 <commands+0x808>
ffffffffc0201b1a:	0d400593          	li	a1,212
ffffffffc0201b1e:	00003517          	auipc	a0,0x3
ffffffffc0201b22:	16a50513          	addi	a0,a0,362 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201b26:	eb8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201b2a:	00003697          	auipc	a3,0x3
ffffffffc0201b2e:	1b668693          	addi	a3,a3,438 # ffffffffc0204ce0 <commands+0xb80>
ffffffffc0201b32:	00003617          	auipc	a2,0x3
ffffffffc0201b36:	e3660613          	addi	a2,a2,-458 # ffffffffc0204968 <commands+0x808>
ffffffffc0201b3a:	0d300593          	li	a1,211
ffffffffc0201b3e:	00003517          	auipc	a0,0x3
ffffffffc0201b42:	14a50513          	addi	a0,a0,330 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201b46:	e98fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201b4a:	00003697          	auipc	a3,0x3
ffffffffc0201b4e:	1b668693          	addi	a3,a3,438 # ffffffffc0204d00 <commands+0xba0>
ffffffffc0201b52:	00003617          	auipc	a2,0x3
ffffffffc0201b56:	e1660613          	addi	a2,a2,-490 # ffffffffc0204968 <commands+0x808>
ffffffffc0201b5a:	0bb00593          	li	a1,187
ffffffffc0201b5e:	00003517          	auipc	a0,0x3
ffffffffc0201b62:	12a50513          	addi	a0,a0,298 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201b66:	e78fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(count == 0);
ffffffffc0201b6a:	00003697          	auipc	a3,0x3
ffffffffc0201b6e:	43e68693          	addi	a3,a3,1086 # ffffffffc0204fa8 <commands+0xe48>
ffffffffc0201b72:	00003617          	auipc	a2,0x3
ffffffffc0201b76:	df660613          	addi	a2,a2,-522 # ffffffffc0204968 <commands+0x808>
ffffffffc0201b7a:	12500593          	li	a1,293
ffffffffc0201b7e:	00003517          	auipc	a0,0x3
ffffffffc0201b82:	10a50513          	addi	a0,a0,266 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201b86:	e58fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free == 0);
ffffffffc0201b8a:	00003697          	auipc	a3,0x3
ffffffffc0201b8e:	2be68693          	addi	a3,a3,702 # ffffffffc0204e48 <commands+0xce8>
ffffffffc0201b92:	00003617          	auipc	a2,0x3
ffffffffc0201b96:	dd660613          	addi	a2,a2,-554 # ffffffffc0204968 <commands+0x808>
ffffffffc0201b9a:	11a00593          	li	a1,282
ffffffffc0201b9e:	00003517          	auipc	a0,0x3
ffffffffc0201ba2:	0ea50513          	addi	a0,a0,234 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201ba6:	e38fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201baa:	00003697          	auipc	a3,0x3
ffffffffc0201bae:	23e68693          	addi	a3,a3,574 # ffffffffc0204de8 <commands+0xc88>
ffffffffc0201bb2:	00003617          	auipc	a2,0x3
ffffffffc0201bb6:	db660613          	addi	a2,a2,-586 # ffffffffc0204968 <commands+0x808>
ffffffffc0201bba:	11800593          	li	a1,280
ffffffffc0201bbe:	00003517          	auipc	a0,0x3
ffffffffc0201bc2:	0ca50513          	addi	a0,a0,202 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201bc6:	e18fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201bca:	00003697          	auipc	a3,0x3
ffffffffc0201bce:	1de68693          	addi	a3,a3,478 # ffffffffc0204da8 <commands+0xc48>
ffffffffc0201bd2:	00003617          	auipc	a2,0x3
ffffffffc0201bd6:	d9660613          	addi	a2,a2,-618 # ffffffffc0204968 <commands+0x808>
ffffffffc0201bda:	0c100593          	li	a1,193
ffffffffc0201bde:	00003517          	auipc	a0,0x3
ffffffffc0201be2:	0aa50513          	addi	a0,a0,170 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201be6:	df8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201bea:	00003697          	auipc	a3,0x3
ffffffffc0201bee:	37e68693          	addi	a3,a3,894 # ffffffffc0204f68 <commands+0xe08>
ffffffffc0201bf2:	00003617          	auipc	a2,0x3
ffffffffc0201bf6:	d7660613          	addi	a2,a2,-650 # ffffffffc0204968 <commands+0x808>
ffffffffc0201bfa:	11200593          	li	a1,274
ffffffffc0201bfe:	00003517          	auipc	a0,0x3
ffffffffc0201c02:	08a50513          	addi	a0,a0,138 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201c06:	dd8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201c0a:	00003697          	auipc	a3,0x3
ffffffffc0201c0e:	33e68693          	addi	a3,a3,830 # ffffffffc0204f48 <commands+0xde8>
ffffffffc0201c12:	00003617          	auipc	a2,0x3
ffffffffc0201c16:	d5660613          	addi	a2,a2,-682 # ffffffffc0204968 <commands+0x808>
ffffffffc0201c1a:	11000593          	li	a1,272
ffffffffc0201c1e:	00003517          	auipc	a0,0x3
ffffffffc0201c22:	06a50513          	addi	a0,a0,106 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201c26:	db8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201c2a:	00003697          	auipc	a3,0x3
ffffffffc0201c2e:	2f668693          	addi	a3,a3,758 # ffffffffc0204f20 <commands+0xdc0>
ffffffffc0201c32:	00003617          	auipc	a2,0x3
ffffffffc0201c36:	d3660613          	addi	a2,a2,-714 # ffffffffc0204968 <commands+0x808>
ffffffffc0201c3a:	10e00593          	li	a1,270
ffffffffc0201c3e:	00003517          	auipc	a0,0x3
ffffffffc0201c42:	04a50513          	addi	a0,a0,74 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201c46:	d98fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201c4a:	00003697          	auipc	a3,0x3
ffffffffc0201c4e:	2ae68693          	addi	a3,a3,686 # ffffffffc0204ef8 <commands+0xd98>
ffffffffc0201c52:	00003617          	auipc	a2,0x3
ffffffffc0201c56:	d1660613          	addi	a2,a2,-746 # ffffffffc0204968 <commands+0x808>
ffffffffc0201c5a:	10d00593          	li	a1,269
ffffffffc0201c5e:	00003517          	auipc	a0,0x3
ffffffffc0201c62:	02a50513          	addi	a0,a0,42 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201c66:	d78fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201c6a:	00003697          	auipc	a3,0x3
ffffffffc0201c6e:	27e68693          	addi	a3,a3,638 # ffffffffc0204ee8 <commands+0xd88>
ffffffffc0201c72:	00003617          	auipc	a2,0x3
ffffffffc0201c76:	cf660613          	addi	a2,a2,-778 # ffffffffc0204968 <commands+0x808>
ffffffffc0201c7a:	10800593          	li	a1,264
ffffffffc0201c7e:	00003517          	auipc	a0,0x3
ffffffffc0201c82:	00a50513          	addi	a0,a0,10 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201c86:	d58fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201c8a:	00003697          	auipc	a3,0x3
ffffffffc0201c8e:	15e68693          	addi	a3,a3,350 # ffffffffc0204de8 <commands+0xc88>
ffffffffc0201c92:	00003617          	auipc	a2,0x3
ffffffffc0201c96:	cd660613          	addi	a2,a2,-810 # ffffffffc0204968 <commands+0x808>
ffffffffc0201c9a:	10700593          	li	a1,263
ffffffffc0201c9e:	00003517          	auipc	a0,0x3
ffffffffc0201ca2:	fea50513          	addi	a0,a0,-22 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201ca6:	d38fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201caa:	00003697          	auipc	a3,0x3
ffffffffc0201cae:	21e68693          	addi	a3,a3,542 # ffffffffc0204ec8 <commands+0xd68>
ffffffffc0201cb2:	00003617          	auipc	a2,0x3
ffffffffc0201cb6:	cb660613          	addi	a2,a2,-842 # ffffffffc0204968 <commands+0x808>
ffffffffc0201cba:	10600593          	li	a1,262
ffffffffc0201cbe:	00003517          	auipc	a0,0x3
ffffffffc0201cc2:	fca50513          	addi	a0,a0,-54 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201cc6:	d18fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201cca:	00003697          	auipc	a3,0x3
ffffffffc0201cce:	1ce68693          	addi	a3,a3,462 # ffffffffc0204e98 <commands+0xd38>
ffffffffc0201cd2:	00003617          	auipc	a2,0x3
ffffffffc0201cd6:	c9660613          	addi	a2,a2,-874 # ffffffffc0204968 <commands+0x808>
ffffffffc0201cda:	10500593          	li	a1,261
ffffffffc0201cde:	00003517          	auipc	a0,0x3
ffffffffc0201ce2:	faa50513          	addi	a0,a0,-86 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201ce6:	cf8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201cea:	00003697          	auipc	a3,0x3
ffffffffc0201cee:	19668693          	addi	a3,a3,406 # ffffffffc0204e80 <commands+0xd20>
ffffffffc0201cf2:	00003617          	auipc	a2,0x3
ffffffffc0201cf6:	c7660613          	addi	a2,a2,-906 # ffffffffc0204968 <commands+0x808>
ffffffffc0201cfa:	10400593          	li	a1,260
ffffffffc0201cfe:	00003517          	auipc	a0,0x3
ffffffffc0201d02:	f8a50513          	addi	a0,a0,-118 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201d06:	cd8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201d0a:	00003697          	auipc	a3,0x3
ffffffffc0201d0e:	0de68693          	addi	a3,a3,222 # ffffffffc0204de8 <commands+0xc88>
ffffffffc0201d12:	00003617          	auipc	a2,0x3
ffffffffc0201d16:	c5660613          	addi	a2,a2,-938 # ffffffffc0204968 <commands+0x808>
ffffffffc0201d1a:	0fe00593          	li	a1,254
ffffffffc0201d1e:	00003517          	auipc	a0,0x3
ffffffffc0201d22:	f6a50513          	addi	a0,a0,-150 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201d26:	cb8fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(!PageProperty(p0));
ffffffffc0201d2a:	00003697          	auipc	a3,0x3
ffffffffc0201d2e:	13e68693          	addi	a3,a3,318 # ffffffffc0204e68 <commands+0xd08>
ffffffffc0201d32:	00003617          	auipc	a2,0x3
ffffffffc0201d36:	c3660613          	addi	a2,a2,-970 # ffffffffc0204968 <commands+0x808>
ffffffffc0201d3a:	0f900593          	li	a1,249
ffffffffc0201d3e:	00003517          	auipc	a0,0x3
ffffffffc0201d42:	f4a50513          	addi	a0,a0,-182 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201d46:	c98fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201d4a:	00003697          	auipc	a3,0x3
ffffffffc0201d4e:	23e68693          	addi	a3,a3,574 # ffffffffc0204f88 <commands+0xe28>
ffffffffc0201d52:	00003617          	auipc	a2,0x3
ffffffffc0201d56:	c1660613          	addi	a2,a2,-1002 # ffffffffc0204968 <commands+0x808>
ffffffffc0201d5a:	11700593          	li	a1,279
ffffffffc0201d5e:	00003517          	auipc	a0,0x3
ffffffffc0201d62:	f2a50513          	addi	a0,a0,-214 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201d66:	c78fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(total == 0);
ffffffffc0201d6a:	00003697          	auipc	a3,0x3
ffffffffc0201d6e:	24e68693          	addi	a3,a3,590 # ffffffffc0204fb8 <commands+0xe58>
ffffffffc0201d72:	00003617          	auipc	a2,0x3
ffffffffc0201d76:	bf660613          	addi	a2,a2,-1034 # ffffffffc0204968 <commands+0x808>
ffffffffc0201d7a:	12600593          	li	a1,294
ffffffffc0201d7e:	00003517          	auipc	a0,0x3
ffffffffc0201d82:	f0a50513          	addi	a0,a0,-246 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201d86:	c58fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(total == nr_free_pages());
ffffffffc0201d8a:	00003697          	auipc	a3,0x3
ffffffffc0201d8e:	f1668693          	addi	a3,a3,-234 # ffffffffc0204ca0 <commands+0xb40>
ffffffffc0201d92:	00003617          	auipc	a2,0x3
ffffffffc0201d96:	bd660613          	addi	a2,a2,-1066 # ffffffffc0204968 <commands+0x808>
ffffffffc0201d9a:	0f300593          	li	a1,243
ffffffffc0201d9e:	00003517          	auipc	a0,0x3
ffffffffc0201da2:	eea50513          	addi	a0,a0,-278 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201da6:	c38fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201daa:	00003697          	auipc	a3,0x3
ffffffffc0201dae:	f3668693          	addi	a3,a3,-202 # ffffffffc0204ce0 <commands+0xb80>
ffffffffc0201db2:	00003617          	auipc	a2,0x3
ffffffffc0201db6:	bb660613          	addi	a2,a2,-1098 # ffffffffc0204968 <commands+0x808>
ffffffffc0201dba:	0ba00593          	li	a1,186
ffffffffc0201dbe:	00003517          	auipc	a0,0x3
ffffffffc0201dc2:	eca50513          	addi	a0,a0,-310 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201dc6:	c18fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201dca <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201dca:	1141                	addi	sp,sp,-16
ffffffffc0201dcc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201dce:	14058463          	beqz	a1,ffffffffc0201f16 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0201dd2:	00659693          	slli	a3,a1,0x6
ffffffffc0201dd6:	96aa                	add	a3,a3,a0
ffffffffc0201dd8:	87aa                	mv	a5,a0
ffffffffc0201dda:	02d50263          	beq	a0,a3,ffffffffc0201dfe <default_free_pages+0x34>
ffffffffc0201dde:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201de0:	8b05                	andi	a4,a4,1
ffffffffc0201de2:	10071a63          	bnez	a4,ffffffffc0201ef6 <default_free_pages+0x12c>
ffffffffc0201de6:	6798                	ld	a4,8(a5)
ffffffffc0201de8:	8b09                	andi	a4,a4,2
ffffffffc0201dea:	10071663          	bnez	a4,ffffffffc0201ef6 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201dee:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201df2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201df6:	04078793          	addi	a5,a5,64
ffffffffc0201dfa:	fed792e3          	bne	a5,a3,ffffffffc0201dde <default_free_pages+0x14>
    base->property = n;
ffffffffc0201dfe:	2581                	sext.w	a1,a1
ffffffffc0201e00:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201e02:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201e06:	4789                	li	a5,2
ffffffffc0201e08:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201e0c:	00007697          	auipc	a3,0x7
ffffffffc0201e10:	62468693          	addi	a3,a3,1572 # ffffffffc0209430 <free_area>
ffffffffc0201e14:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201e16:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201e18:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201e1c:	9db9                	addw	a1,a1,a4
ffffffffc0201e1e:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201e20:	0ad78463          	beq	a5,a3,ffffffffc0201ec8 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0201e24:	fe878713          	addi	a4,a5,-24
ffffffffc0201e28:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201e2c:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201e2e:	00e56a63          	bltu	a0,a4,ffffffffc0201e42 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201e32:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201e34:	04d70c63          	beq	a4,a3,ffffffffc0201e8c <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0201e38:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201e3a:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201e3e:	fee57ae3          	bgeu	a0,a4,ffffffffc0201e32 <default_free_pages+0x68>
ffffffffc0201e42:	c199                	beqz	a1,ffffffffc0201e48 <default_free_pages+0x7e>
ffffffffc0201e44:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201e48:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201e4a:	e390                	sd	a2,0(a5)
ffffffffc0201e4c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201e4e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201e50:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201e52:	00d70d63          	beq	a4,a3,ffffffffc0201e6c <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201e56:	ff872583          	lw	a1,-8(a4) # ff8 <kern_entry-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0201e5a:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201e5e:	02059813          	slli	a6,a1,0x20
ffffffffc0201e62:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201e66:	97b2                	add	a5,a5,a2
ffffffffc0201e68:	02f50c63          	beq	a0,a5,ffffffffc0201ea0 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201e6c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201e6e:	00d78c63          	beq	a5,a3,ffffffffc0201e86 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201e72:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201e74:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201e78:	02061593          	slli	a1,a2,0x20
ffffffffc0201e7c:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201e80:	972a                	add	a4,a4,a0
ffffffffc0201e82:	04e68a63          	beq	a3,a4,ffffffffc0201ed6 <default_free_pages+0x10c>
}
ffffffffc0201e86:	60a2                	ld	ra,8(sp)
ffffffffc0201e88:	0141                	addi	sp,sp,16
ffffffffc0201e8a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201e8c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201e8e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201e90:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201e92:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201e94:	02d70763          	beq	a4,a3,ffffffffc0201ec2 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0201e98:	8832                	mv	a6,a2
ffffffffc0201e9a:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201e9c:	87ba                	mv	a5,a4
ffffffffc0201e9e:	bf71                	j	ffffffffc0201e3a <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201ea0:	491c                	lw	a5,16(a0)
ffffffffc0201ea2:	9dbd                	addw	a1,a1,a5
ffffffffc0201ea4:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201ea8:	57f5                	li	a5,-3
ffffffffc0201eaa:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201eae:	01853803          	ld	a6,24(a0)
ffffffffc0201eb2:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201eb4:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201eb6:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0201eba:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201ebc:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0201ec0:	b77d                	j	ffffffffc0201e6e <default_free_pages+0xa4>
ffffffffc0201ec2:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201ec4:	873e                	mv	a4,a5
ffffffffc0201ec6:	bf41                	j	ffffffffc0201e56 <default_free_pages+0x8c>
}
ffffffffc0201ec8:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201eca:	e390                	sd	a2,0(a5)
ffffffffc0201ecc:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201ece:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201ed0:	ed1c                	sd	a5,24(a0)
ffffffffc0201ed2:	0141                	addi	sp,sp,16
ffffffffc0201ed4:	8082                	ret
            base->property += p->property;
ffffffffc0201ed6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201eda:	ff078693          	addi	a3,a5,-16
ffffffffc0201ede:	9e39                	addw	a2,a2,a4
ffffffffc0201ee0:	c910                	sw	a2,16(a0)
ffffffffc0201ee2:	5775                	li	a4,-3
ffffffffc0201ee4:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ee8:	6398                	ld	a4,0(a5)
ffffffffc0201eea:	679c                	ld	a5,8(a5)
}
ffffffffc0201eec:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201eee:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201ef0:	e398                	sd	a4,0(a5)
ffffffffc0201ef2:	0141                	addi	sp,sp,16
ffffffffc0201ef4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201ef6:	00003697          	auipc	a3,0x3
ffffffffc0201efa:	0da68693          	addi	a3,a3,218 # ffffffffc0204fd0 <commands+0xe70>
ffffffffc0201efe:	00003617          	auipc	a2,0x3
ffffffffc0201f02:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0204968 <commands+0x808>
ffffffffc0201f06:	08300593          	li	a1,131
ffffffffc0201f0a:	00003517          	auipc	a0,0x3
ffffffffc0201f0e:	d7e50513          	addi	a0,a0,-642 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201f12:	accfe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(n > 0);
ffffffffc0201f16:	00003697          	auipc	a3,0x3
ffffffffc0201f1a:	0b268693          	addi	a3,a3,178 # ffffffffc0204fc8 <commands+0xe68>
ffffffffc0201f1e:	00003617          	auipc	a2,0x3
ffffffffc0201f22:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0204968 <commands+0x808>
ffffffffc0201f26:	08000593          	li	a1,128
ffffffffc0201f2a:	00003517          	auipc	a0,0x3
ffffffffc0201f2e:	d5e50513          	addi	a0,a0,-674 # ffffffffc0204c88 <commands+0xb28>
ffffffffc0201f32:	aacfe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201f36 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201f36:	c941                	beqz	a0,ffffffffc0201fc6 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0201f38:	00007597          	auipc	a1,0x7
ffffffffc0201f3c:	4f858593          	addi	a1,a1,1272 # ffffffffc0209430 <free_area>
ffffffffc0201f40:	0105a803          	lw	a6,16(a1)
ffffffffc0201f44:	872a                	mv	a4,a0
ffffffffc0201f46:	02081793          	slli	a5,a6,0x20
ffffffffc0201f4a:	9381                	srli	a5,a5,0x20
ffffffffc0201f4c:	00a7ee63          	bltu	a5,a0,ffffffffc0201f68 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201f50:	87ae                	mv	a5,a1
ffffffffc0201f52:	a801                	j	ffffffffc0201f62 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201f54:	ff87a683          	lw	a3,-8(a5)
ffffffffc0201f58:	02069613          	slli	a2,a3,0x20
ffffffffc0201f5c:	9201                	srli	a2,a2,0x20
ffffffffc0201f5e:	00e67763          	bgeu	a2,a4,ffffffffc0201f6c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201f62:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201f64:	feb798e3          	bne	a5,a1,ffffffffc0201f54 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201f68:	4501                	li	a0,0
}
ffffffffc0201f6a:	8082                	ret
    return listelm->prev;
ffffffffc0201f6c:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201f70:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201f74:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0201f78:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201f7c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201f80:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201f84:	02c77863          	bgeu	a4,a2,ffffffffc0201fb4 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0201f88:	071a                	slli	a4,a4,0x6
ffffffffc0201f8a:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201f8c:	41c686bb          	subw	a3,a3,t3
ffffffffc0201f90:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201f92:	00870613          	addi	a2,a4,8
ffffffffc0201f96:	4689                	li	a3,2
ffffffffc0201f98:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201f9c:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201fa0:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201fa4:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201fa8:	e290                	sd	a2,0(a3)
ffffffffc0201faa:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201fae:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201fb0:	01173c23          	sd	a7,24(a4)
ffffffffc0201fb4:	41c8083b          	subw	a6,a6,t3
ffffffffc0201fb8:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201fbc:	5775                	li	a4,-3
ffffffffc0201fbe:	17c1                	addi	a5,a5,-16
ffffffffc0201fc0:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201fc4:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201fc6:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201fc8:	00003697          	auipc	a3,0x3
ffffffffc0201fcc:	00068693          	mv	a3,a3
ffffffffc0201fd0:	00003617          	auipc	a2,0x3
ffffffffc0201fd4:	99860613          	addi	a2,a2,-1640 # ffffffffc0204968 <commands+0x808>
ffffffffc0201fd8:	06200593          	li	a1,98
ffffffffc0201fdc:	00003517          	auipc	a0,0x3
ffffffffc0201fe0:	cac50513          	addi	a0,a0,-852 # ffffffffc0204c88 <commands+0xb28>
default_alloc_pages(size_t n) {
ffffffffc0201fe4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201fe6:	9f8fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0201fea <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201fea:	1141                	addi	sp,sp,-16
ffffffffc0201fec:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201fee:	c5f1                	beqz	a1,ffffffffc02020ba <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0201ff0:	00659693          	slli	a3,a1,0x6
ffffffffc0201ff4:	96aa                	add	a3,a3,a0
ffffffffc0201ff6:	87aa                	mv	a5,a0
ffffffffc0201ff8:	00d50f63          	beq	a0,a3,ffffffffc0202016 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201ffc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201ffe:	8b05                	andi	a4,a4,1
ffffffffc0202000:	cf49                	beqz	a4,ffffffffc020209a <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0202002:	0007a823          	sw	zero,16(a5)
ffffffffc0202006:	0007b423          	sd	zero,8(a5)
ffffffffc020200a:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020200e:	04078793          	addi	a5,a5,64
ffffffffc0202012:	fed795e3          	bne	a5,a3,ffffffffc0201ffc <default_init_memmap+0x12>
    base->property = n;
ffffffffc0202016:	2581                	sext.w	a1,a1
ffffffffc0202018:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020201a:	4789                	li	a5,2
ffffffffc020201c:	00850713          	addi	a4,a0,8
ffffffffc0202020:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202024:	00007697          	auipc	a3,0x7
ffffffffc0202028:	40c68693          	addi	a3,a3,1036 # ffffffffc0209430 <free_area>
ffffffffc020202c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020202e:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202030:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202034:	9db9                	addw	a1,a1,a4
ffffffffc0202036:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202038:	04d78a63          	beq	a5,a3,ffffffffc020208c <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc020203c:	fe878713          	addi	a4,a5,-24
ffffffffc0202040:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202044:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202046:	00e56a63          	bltu	a0,a4,ffffffffc020205a <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020204a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020204c:	02d70263          	beq	a4,a3,ffffffffc0202070 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0202050:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202052:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202056:	fee57ae3          	bgeu	a0,a4,ffffffffc020204a <default_init_memmap+0x60>
ffffffffc020205a:	c199                	beqz	a1,ffffffffc0202060 <default_init_memmap+0x76>
ffffffffc020205c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202060:	6398                	ld	a4,0(a5)
}
ffffffffc0202062:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202064:	e390                	sd	a2,0(a5)
ffffffffc0202066:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202068:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020206a:	ed18                	sd	a4,24(a0)
ffffffffc020206c:	0141                	addi	sp,sp,16
ffffffffc020206e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202070:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202072:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202074:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202076:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202078:	00d70663          	beq	a4,a3,ffffffffc0202084 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020207c:	8832                	mv	a6,a2
ffffffffc020207e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202080:	87ba                	mv	a5,a4
ffffffffc0202082:	bfc1                	j	ffffffffc0202052 <default_init_memmap+0x68>
}
ffffffffc0202084:	60a2                	ld	ra,8(sp)
ffffffffc0202086:	e290                	sd	a2,0(a3)
ffffffffc0202088:	0141                	addi	sp,sp,16
ffffffffc020208a:	8082                	ret
ffffffffc020208c:	60a2                	ld	ra,8(sp)
ffffffffc020208e:	e390                	sd	a2,0(a5)
ffffffffc0202090:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202092:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202094:	ed1c                	sd	a5,24(a0)
ffffffffc0202096:	0141                	addi	sp,sp,16
ffffffffc0202098:	8082                	ret
        assert(PageReserved(p));
ffffffffc020209a:	00003697          	auipc	a3,0x3
ffffffffc020209e:	f5e68693          	addi	a3,a3,-162 # ffffffffc0204ff8 <commands+0xe98>
ffffffffc02020a2:	00003617          	auipc	a2,0x3
ffffffffc02020a6:	8c660613          	addi	a2,a2,-1850 # ffffffffc0204968 <commands+0x808>
ffffffffc02020aa:	04900593          	li	a1,73
ffffffffc02020ae:	00003517          	auipc	a0,0x3
ffffffffc02020b2:	bda50513          	addi	a0,a0,-1062 # ffffffffc0204c88 <commands+0xb28>
ffffffffc02020b6:	928fe0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(n > 0);
ffffffffc02020ba:	00003697          	auipc	a3,0x3
ffffffffc02020be:	f0e68693          	addi	a3,a3,-242 # ffffffffc0204fc8 <commands+0xe68>
ffffffffc02020c2:	00003617          	auipc	a2,0x3
ffffffffc02020c6:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204968 <commands+0x808>
ffffffffc02020ca:	04600593          	li	a1,70
ffffffffc02020ce:	00003517          	auipc	a0,0x3
ffffffffc02020d2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0204c88 <commands+0xb28>
ffffffffc02020d6:	908fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02020da <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc02020da:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02020dc:	00003617          	auipc	a2,0x3
ffffffffc02020e0:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0204c58 <commands+0xaf8>
ffffffffc02020e4:	06900593          	li	a1,105
ffffffffc02020e8:	00003517          	auipc	a0,0x3
ffffffffc02020ec:	ac850513          	addi	a0,a0,-1336 # ffffffffc0204bb0 <commands+0xa50>
pa2page(uintptr_t pa)
ffffffffc02020f0:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02020f2:	8ecfe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02020f6 <pte2page.part.0>:
pte2page(pte_t pte)
ffffffffc02020f6:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02020f8:	00003617          	auipc	a2,0x3
ffffffffc02020fc:	f6060613          	addi	a2,a2,-160 # ffffffffc0205058 <default_pmm_manager+0x38>
ffffffffc0202100:	07f00593          	li	a1,127
ffffffffc0202104:	00003517          	auipc	a0,0x3
ffffffffc0202108:	aac50513          	addi	a0,a0,-1364 # ffffffffc0204bb0 <commands+0xa50>
pte2page(pte_t pte)
ffffffffc020210c:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc020210e:	8d0fe0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0202112 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202112:	100027f3          	csrr	a5,sstatus
ffffffffc0202116:	8b89                	andi	a5,a5,2
ffffffffc0202118:	e799                	bnez	a5,ffffffffc0202126 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020211a:	0000b797          	auipc	a5,0xb
ffffffffc020211e:	39e7b783          	ld	a5,926(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202122:	6f9c                	ld	a5,24(a5)
ffffffffc0202124:	8782                	jr	a5
{
ffffffffc0202126:	1141                	addi	sp,sp,-16
ffffffffc0202128:	e406                	sd	ra,8(sp)
ffffffffc020212a:	e022                	sd	s0,0(sp)
ffffffffc020212c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020212e:	809fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202132:	0000b797          	auipc	a5,0xb
ffffffffc0202136:	3867b783          	ld	a5,902(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020213a:	6f9c                	ld	a5,24(a5)
ffffffffc020213c:	8522                	mv	a0,s0
ffffffffc020213e:	9782                	jalr	a5
ffffffffc0202140:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202142:	feefe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0202146:	60a2                	ld	ra,8(sp)
ffffffffc0202148:	8522                	mv	a0,s0
ffffffffc020214a:	6402                	ld	s0,0(sp)
ffffffffc020214c:	0141                	addi	sp,sp,16
ffffffffc020214e:	8082                	ret

ffffffffc0202150 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202150:	100027f3          	csrr	a5,sstatus
ffffffffc0202154:	8b89                	andi	a5,a5,2
ffffffffc0202156:	e799                	bnez	a5,ffffffffc0202164 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202158:	0000b797          	auipc	a5,0xb
ffffffffc020215c:	3607b783          	ld	a5,864(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202160:	739c                	ld	a5,32(a5)
ffffffffc0202162:	8782                	jr	a5
{
ffffffffc0202164:	1101                	addi	sp,sp,-32
ffffffffc0202166:	ec06                	sd	ra,24(sp)
ffffffffc0202168:	e822                	sd	s0,16(sp)
ffffffffc020216a:	e426                	sd	s1,8(sp)
ffffffffc020216c:	842a                	mv	s0,a0
ffffffffc020216e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202170:	fc6fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202174:	0000b797          	auipc	a5,0xb
ffffffffc0202178:	3447b783          	ld	a5,836(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020217c:	739c                	ld	a5,32(a5)
ffffffffc020217e:	85a6                	mv	a1,s1
ffffffffc0202180:	8522                	mv	a0,s0
ffffffffc0202182:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202184:	6442                	ld	s0,16(sp)
ffffffffc0202186:	60e2                	ld	ra,24(sp)
ffffffffc0202188:	64a2                	ld	s1,8(sp)
ffffffffc020218a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020218c:	fa4fe06f          	j	ffffffffc0200930 <intr_enable>

ffffffffc0202190 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202190:	100027f3          	csrr	a5,sstatus
ffffffffc0202194:	8b89                	andi	a5,a5,2
ffffffffc0202196:	e799                	bnez	a5,ffffffffc02021a4 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0202198:	0000b797          	auipc	a5,0xb
ffffffffc020219c:	3207b783          	ld	a5,800(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02021a0:	779c                	ld	a5,40(a5)
ffffffffc02021a2:	8782                	jr	a5
{
ffffffffc02021a4:	1141                	addi	sp,sp,-16
ffffffffc02021a6:	e406                	sd	ra,8(sp)
ffffffffc02021a8:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02021aa:	f8cfe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02021ae:	0000b797          	auipc	a5,0xb
ffffffffc02021b2:	30a7b783          	ld	a5,778(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02021b6:	779c                	ld	a5,40(a5)
ffffffffc02021b8:	9782                	jalr	a5
ffffffffc02021ba:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021bc:	f74fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02021c0:	60a2                	ld	ra,8(sp)
ffffffffc02021c2:	8522                	mv	a0,s0
ffffffffc02021c4:	6402                	ld	s0,0(sp)
ffffffffc02021c6:	0141                	addi	sp,sp,16
ffffffffc02021c8:	8082                	ret

ffffffffc02021ca <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02021ca:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02021ce:	1ff7f793          	andi	a5,a5,511
{
ffffffffc02021d2:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02021d4:	078e                	slli	a5,a5,0x3
{
ffffffffc02021d6:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02021d8:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc02021dc:	6094                	ld	a3,0(s1)
{
ffffffffc02021de:	f04a                	sd	s2,32(sp)
ffffffffc02021e0:	ec4e                	sd	s3,24(sp)
ffffffffc02021e2:	e852                	sd	s4,16(sp)
ffffffffc02021e4:	fc06                	sd	ra,56(sp)
ffffffffc02021e6:	f822                	sd	s0,48(sp)
ffffffffc02021e8:	e456                	sd	s5,8(sp)
ffffffffc02021ea:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc02021ec:	0016f793          	andi	a5,a3,1
{
ffffffffc02021f0:	892e                	mv	s2,a1
ffffffffc02021f2:	8a32                	mv	s4,a2
ffffffffc02021f4:	0000b997          	auipc	s3,0xb
ffffffffc02021f8:	2b498993          	addi	s3,s3,692 # ffffffffc020d4a8 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc02021fc:	efbd                	bnez	a5,ffffffffc020227a <get_pte+0xb0>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02021fe:	14060c63          	beqz	a2,ffffffffc0202356 <get_pte+0x18c>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202202:	100027f3          	csrr	a5,sstatus
ffffffffc0202206:	8b89                	andi	a5,a5,2
ffffffffc0202208:	14079963          	bnez	a5,ffffffffc020235a <get_pte+0x190>
        page = pmm_manager->alloc_pages(n);
ffffffffc020220c:	0000b797          	auipc	a5,0xb
ffffffffc0202210:	2ac7b783          	ld	a5,684(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202214:	6f9c                	ld	a5,24(a5)
ffffffffc0202216:	4505                	li	a0,1
ffffffffc0202218:	9782                	jalr	a5
ffffffffc020221a:	842a                	mv	s0,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020221c:	12040d63          	beqz	s0,ffffffffc0202356 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc0202220:	0000bb17          	auipc	s6,0xb
ffffffffc0202224:	290b0b13          	addi	s6,s6,656 # ffffffffc020d4b0 <pages>
ffffffffc0202228:	000b3503          	ld	a0,0(s6)
ffffffffc020222c:	00080ab7          	lui	s5,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202230:	0000b997          	auipc	s3,0xb
ffffffffc0202234:	27898993          	addi	s3,s3,632 # ffffffffc020d4a8 <npage>
ffffffffc0202238:	40a40533          	sub	a0,s0,a0
ffffffffc020223c:	8519                	srai	a0,a0,0x6
ffffffffc020223e:	9556                	add	a0,a0,s5
ffffffffc0202240:	0009b703          	ld	a4,0(s3)
ffffffffc0202244:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202248:	4685                	li	a3,1
ffffffffc020224a:	c014                	sw	a3,0(s0)
ffffffffc020224c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020224e:	0532                	slli	a0,a0,0xc
ffffffffc0202250:	16e7f763          	bgeu	a5,a4,ffffffffc02023be <get_pte+0x1f4>
ffffffffc0202254:	0000b797          	auipc	a5,0xb
ffffffffc0202258:	26c7b783          	ld	a5,620(a5) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc020225c:	6605                	lui	a2,0x1
ffffffffc020225e:	4581                	li	a1,0
ffffffffc0202260:	953e                	add	a0,a0,a5
ffffffffc0202262:	021010ef          	jal	ra,ffffffffc0203a82 <memset>
    return page - pages + nbase;
ffffffffc0202266:	000b3683          	ld	a3,0(s6)
ffffffffc020226a:	40d406b3          	sub	a3,s0,a3
ffffffffc020226e:	8699                	srai	a3,a3,0x6
ffffffffc0202270:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202272:	06aa                	slli	a3,a3,0xa
ffffffffc0202274:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202278:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020227a:	77fd                	lui	a5,0xfffff
ffffffffc020227c:	068a                	slli	a3,a3,0x2
ffffffffc020227e:	0009b703          	ld	a4,0(s3)
ffffffffc0202282:	8efd                	and	a3,a3,a5
ffffffffc0202284:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202288:	10e7ff63          	bgeu	a5,a4,ffffffffc02023a6 <get_pte+0x1dc>
ffffffffc020228c:	0000ba97          	auipc	s5,0xb
ffffffffc0202290:	234a8a93          	addi	s5,s5,564 # ffffffffc020d4c0 <va_pa_offset>
ffffffffc0202294:	000ab403          	ld	s0,0(s5)
ffffffffc0202298:	01595793          	srli	a5,s2,0x15
ffffffffc020229c:	1ff7f793          	andi	a5,a5,511
ffffffffc02022a0:	96a2                	add	a3,a3,s0
ffffffffc02022a2:	00379413          	slli	s0,a5,0x3
ffffffffc02022a6:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V))
ffffffffc02022a8:	6014                	ld	a3,0(s0)
ffffffffc02022aa:	0016f793          	andi	a5,a3,1
ffffffffc02022ae:	ebad                	bnez	a5,ffffffffc0202320 <get_pte+0x156>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02022b0:	0a0a0363          	beqz	s4,ffffffffc0202356 <get_pte+0x18c>
ffffffffc02022b4:	100027f3          	csrr	a5,sstatus
ffffffffc02022b8:	8b89                	andi	a5,a5,2
ffffffffc02022ba:	efcd                	bnez	a5,ffffffffc0202374 <get_pte+0x1aa>
        page = pmm_manager->alloc_pages(n);
ffffffffc02022bc:	0000b797          	auipc	a5,0xb
ffffffffc02022c0:	1fc7b783          	ld	a5,508(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02022c4:	6f9c                	ld	a5,24(a5)
ffffffffc02022c6:	4505                	li	a0,1
ffffffffc02022c8:	9782                	jalr	a5
ffffffffc02022ca:	84aa                	mv	s1,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02022cc:	c4c9                	beqz	s1,ffffffffc0202356 <get_pte+0x18c>
    return page - pages + nbase;
ffffffffc02022ce:	0000bb17          	auipc	s6,0xb
ffffffffc02022d2:	1e2b0b13          	addi	s6,s6,482 # ffffffffc020d4b0 <pages>
ffffffffc02022d6:	000b3503          	ld	a0,0(s6)
ffffffffc02022da:	00080a37          	lui	s4,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02022de:	0009b703          	ld	a4,0(s3)
ffffffffc02022e2:	40a48533          	sub	a0,s1,a0
ffffffffc02022e6:	8519                	srai	a0,a0,0x6
ffffffffc02022e8:	9552                	add	a0,a0,s4
ffffffffc02022ea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02022ee:	4685                	li	a3,1
ffffffffc02022f0:	c094                	sw	a3,0(s1)
ffffffffc02022f2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02022f4:	0532                	slli	a0,a0,0xc
ffffffffc02022f6:	0ee7f163          	bgeu	a5,a4,ffffffffc02023d8 <get_pte+0x20e>
ffffffffc02022fa:	000ab783          	ld	a5,0(s5)
ffffffffc02022fe:	6605                	lui	a2,0x1
ffffffffc0202300:	4581                	li	a1,0
ffffffffc0202302:	953e                	add	a0,a0,a5
ffffffffc0202304:	77e010ef          	jal	ra,ffffffffc0203a82 <memset>
    return page - pages + nbase;
ffffffffc0202308:	000b3683          	ld	a3,0(s6)
ffffffffc020230c:	40d486b3          	sub	a3,s1,a3
ffffffffc0202310:	8699                	srai	a3,a3,0x6
ffffffffc0202312:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202314:	06aa                	slli	a3,a3,0xa
ffffffffc0202316:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020231a:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020231c:	0009b703          	ld	a4,0(s3)
ffffffffc0202320:	068a                	slli	a3,a3,0x2
ffffffffc0202322:	757d                	lui	a0,0xfffff
ffffffffc0202324:	8ee9                	and	a3,a3,a0
ffffffffc0202326:	00c6d793          	srli	a5,a3,0xc
ffffffffc020232a:	06e7f263          	bgeu	a5,a4,ffffffffc020238e <get_pte+0x1c4>
ffffffffc020232e:	000ab503          	ld	a0,0(s5)
ffffffffc0202332:	00c95913          	srli	s2,s2,0xc
ffffffffc0202336:	1ff97913          	andi	s2,s2,511
ffffffffc020233a:	96aa                	add	a3,a3,a0
ffffffffc020233c:	00391513          	slli	a0,s2,0x3
ffffffffc0202340:	9536                	add	a0,a0,a3
}
ffffffffc0202342:	70e2                	ld	ra,56(sp)
ffffffffc0202344:	7442                	ld	s0,48(sp)
ffffffffc0202346:	74a2                	ld	s1,40(sp)
ffffffffc0202348:	7902                	ld	s2,32(sp)
ffffffffc020234a:	69e2                	ld	s3,24(sp)
ffffffffc020234c:	6a42                	ld	s4,16(sp)
ffffffffc020234e:	6aa2                	ld	s5,8(sp)
ffffffffc0202350:	6b02                	ld	s6,0(sp)
ffffffffc0202352:	6121                	addi	sp,sp,64
ffffffffc0202354:	8082                	ret
            return NULL;
ffffffffc0202356:	4501                	li	a0,0
ffffffffc0202358:	b7ed                	j	ffffffffc0202342 <get_pte+0x178>
        intr_disable();
ffffffffc020235a:	ddcfe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020235e:	0000b797          	auipc	a5,0xb
ffffffffc0202362:	15a7b783          	ld	a5,346(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202366:	6f9c                	ld	a5,24(a5)
ffffffffc0202368:	4505                	li	a0,1
ffffffffc020236a:	9782                	jalr	a5
ffffffffc020236c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020236e:	dc2fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202372:	b56d                	j	ffffffffc020221c <get_pte+0x52>
        intr_disable();
ffffffffc0202374:	dc2fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202378:	0000b797          	auipc	a5,0xb
ffffffffc020237c:	1407b783          	ld	a5,320(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc0202380:	6f9c                	ld	a5,24(a5)
ffffffffc0202382:	4505                	li	a0,1
ffffffffc0202384:	9782                	jalr	a5
ffffffffc0202386:	84aa                	mv	s1,a0
        intr_enable();
ffffffffc0202388:	da8fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc020238c:	b781                	j	ffffffffc02022cc <get_pte+0x102>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020238e:	00002617          	auipc	a2,0x2
ffffffffc0202392:	7fa60613          	addi	a2,a2,2042 # ffffffffc0204b88 <commands+0xa28>
ffffffffc0202396:	0fb00593          	li	a1,251
ffffffffc020239a:	00003517          	auipc	a0,0x3
ffffffffc020239e:	ce650513          	addi	a0,a0,-794 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02023a2:	e3dfd0ef          	jal	ra,ffffffffc02001de <__panic>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02023a6:	00002617          	auipc	a2,0x2
ffffffffc02023aa:	7e260613          	addi	a2,a2,2018 # ffffffffc0204b88 <commands+0xa28>
ffffffffc02023ae:	0ee00593          	li	a1,238
ffffffffc02023b2:	00003517          	auipc	a0,0x3
ffffffffc02023b6:	cce50513          	addi	a0,a0,-818 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02023ba:	e25fd0ef          	jal	ra,ffffffffc02001de <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02023be:	86aa                	mv	a3,a0
ffffffffc02023c0:	00002617          	auipc	a2,0x2
ffffffffc02023c4:	7c860613          	addi	a2,a2,1992 # ffffffffc0204b88 <commands+0xa28>
ffffffffc02023c8:	0eb00593          	li	a1,235
ffffffffc02023cc:	00003517          	auipc	a0,0x3
ffffffffc02023d0:	cb450513          	addi	a0,a0,-844 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02023d4:	e0bfd0ef          	jal	ra,ffffffffc02001de <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02023d8:	86aa                	mv	a3,a0
ffffffffc02023da:	00002617          	auipc	a2,0x2
ffffffffc02023de:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204b88 <commands+0xa28>
ffffffffc02023e2:	0f800593          	li	a1,248
ffffffffc02023e6:	00003517          	auipc	a0,0x3
ffffffffc02023ea:	c9a50513          	addi	a0,a0,-870 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02023ee:	df1fd0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02023f2 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02023f2:	1141                	addi	sp,sp,-16
ffffffffc02023f4:	e022                	sd	s0,0(sp)
ffffffffc02023f6:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023f8:	4601                	li	a2,0
{
ffffffffc02023fa:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023fc:	dcfff0ef          	jal	ra,ffffffffc02021ca <get_pte>
    if (ptep_store != NULL)
ffffffffc0202400:	c011                	beqz	s0,ffffffffc0202404 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202402:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202404:	c511                	beqz	a0,ffffffffc0202410 <get_page+0x1e>
ffffffffc0202406:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202408:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020240a:	0017f713          	andi	a4,a5,1
ffffffffc020240e:	e709                	bnez	a4,ffffffffc0202418 <get_page+0x26>
}
ffffffffc0202410:	60a2                	ld	ra,8(sp)
ffffffffc0202412:	6402                	ld	s0,0(sp)
ffffffffc0202414:	0141                	addi	sp,sp,16
ffffffffc0202416:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202418:	078a                	slli	a5,a5,0x2
ffffffffc020241a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020241c:	0000b717          	auipc	a4,0xb
ffffffffc0202420:	08c73703          	ld	a4,140(a4) # ffffffffc020d4a8 <npage>
ffffffffc0202424:	00e7ff63          	bgeu	a5,a4,ffffffffc0202442 <get_page+0x50>
ffffffffc0202428:	60a2                	ld	ra,8(sp)
ffffffffc020242a:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc020242c:	fff80537          	lui	a0,0xfff80
ffffffffc0202430:	97aa                	add	a5,a5,a0
ffffffffc0202432:	079a                	slli	a5,a5,0x6
ffffffffc0202434:	0000b517          	auipc	a0,0xb
ffffffffc0202438:	07c53503          	ld	a0,124(a0) # ffffffffc020d4b0 <pages>
ffffffffc020243c:	953e                	add	a0,a0,a5
ffffffffc020243e:	0141                	addi	sp,sp,16
ffffffffc0202440:	8082                	ret
ffffffffc0202442:	c99ff0ef          	jal	ra,ffffffffc02020da <pa2page.part.0>

ffffffffc0202446 <page_remove>:
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la)
{
ffffffffc0202446:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202448:	4601                	li	a2,0
{
ffffffffc020244a:	ec26                	sd	s1,24(sp)
ffffffffc020244c:	f406                	sd	ra,40(sp)
ffffffffc020244e:	f022                	sd	s0,32(sp)
ffffffffc0202450:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202452:	d79ff0ef          	jal	ra,ffffffffc02021ca <get_pte>
    if (ptep != NULL)
ffffffffc0202456:	c511                	beqz	a0,ffffffffc0202462 <page_remove+0x1c>
    if (*ptep & PTE_V)
ffffffffc0202458:	611c                	ld	a5,0(a0)
ffffffffc020245a:	842a                	mv	s0,a0
ffffffffc020245c:	0017f713          	andi	a4,a5,1
ffffffffc0202460:	e711                	bnez	a4,ffffffffc020246c <page_remove+0x26>
    {
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202462:	70a2                	ld	ra,40(sp)
ffffffffc0202464:	7402                	ld	s0,32(sp)
ffffffffc0202466:	64e2                	ld	s1,24(sp)
ffffffffc0202468:	6145                	addi	sp,sp,48
ffffffffc020246a:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020246c:	078a                	slli	a5,a5,0x2
ffffffffc020246e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202470:	0000b717          	auipc	a4,0xb
ffffffffc0202474:	03873703          	ld	a4,56(a4) # ffffffffc020d4a8 <npage>
ffffffffc0202478:	06e7f363          	bgeu	a5,a4,ffffffffc02024de <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020247c:	fff80537          	lui	a0,0xfff80
ffffffffc0202480:	97aa                	add	a5,a5,a0
ffffffffc0202482:	079a                	slli	a5,a5,0x6
ffffffffc0202484:	0000b517          	auipc	a0,0xb
ffffffffc0202488:	02c53503          	ld	a0,44(a0) # ffffffffc020d4b0 <pages>
ffffffffc020248c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020248e:	411c                	lw	a5,0(a0)
ffffffffc0202490:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202494:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202496:	cb11                	beqz	a4,ffffffffc02024aa <page_remove+0x64>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202498:	00043023          	sd	zero,0(s0)
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020249c:	12048073          	sfence.vma	s1
}
ffffffffc02024a0:	70a2                	ld	ra,40(sp)
ffffffffc02024a2:	7402                	ld	s0,32(sp)
ffffffffc02024a4:	64e2                	ld	s1,24(sp)
ffffffffc02024a6:	6145                	addi	sp,sp,48
ffffffffc02024a8:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02024aa:	100027f3          	csrr	a5,sstatus
ffffffffc02024ae:	8b89                	andi	a5,a5,2
ffffffffc02024b0:	eb89                	bnez	a5,ffffffffc02024c2 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc02024b2:	0000b797          	auipc	a5,0xb
ffffffffc02024b6:	0067b783          	ld	a5,6(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02024ba:	739c                	ld	a5,32(a5)
ffffffffc02024bc:	4585                	li	a1,1
ffffffffc02024be:	9782                	jalr	a5
    if (flag) {
ffffffffc02024c0:	bfe1                	j	ffffffffc0202498 <page_remove+0x52>
        intr_disable();
ffffffffc02024c2:	e42a                	sd	a0,8(sp)
ffffffffc02024c4:	c72fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc02024c8:	0000b797          	auipc	a5,0xb
ffffffffc02024cc:	ff07b783          	ld	a5,-16(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02024d0:	739c                	ld	a5,32(a5)
ffffffffc02024d2:	6522                	ld	a0,8(sp)
ffffffffc02024d4:	4585                	li	a1,1
ffffffffc02024d6:	9782                	jalr	a5
        intr_enable();
ffffffffc02024d8:	c58fe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02024dc:	bf75                	j	ffffffffc0202498 <page_remove+0x52>
ffffffffc02024de:	bfdff0ef          	jal	ra,ffffffffc02020da <pa2page.part.0>

ffffffffc02024e2 <page_insert>:
{
ffffffffc02024e2:	7139                	addi	sp,sp,-64
ffffffffc02024e4:	e852                	sd	s4,16(sp)
ffffffffc02024e6:	8a32                	mv	s4,a2
ffffffffc02024e8:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024ea:	4605                	li	a2,1
{
ffffffffc02024ec:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024ee:	85d2                	mv	a1,s4
{
ffffffffc02024f0:	f426                	sd	s1,40(sp)
ffffffffc02024f2:	fc06                	sd	ra,56(sp)
ffffffffc02024f4:	f04a                	sd	s2,32(sp)
ffffffffc02024f6:	ec4e                	sd	s3,24(sp)
ffffffffc02024f8:	e456                	sd	s5,8(sp)
ffffffffc02024fa:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024fc:	ccfff0ef          	jal	ra,ffffffffc02021ca <get_pte>
    if (ptep == NULL)
ffffffffc0202500:	c961                	beqz	a0,ffffffffc02025d0 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202502:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202504:	611c                	ld	a5,0(a0)
ffffffffc0202506:	89aa                	mv	s3,a0
ffffffffc0202508:	0016871b          	addiw	a4,a3,1
ffffffffc020250c:	c018                	sw	a4,0(s0)
ffffffffc020250e:	0017f713          	andi	a4,a5,1
ffffffffc0202512:	ef05                	bnez	a4,ffffffffc020254a <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202514:	0000b717          	auipc	a4,0xb
ffffffffc0202518:	f9c73703          	ld	a4,-100(a4) # ffffffffc020d4b0 <pages>
ffffffffc020251c:	8c19                	sub	s0,s0,a4
ffffffffc020251e:	000807b7          	lui	a5,0x80
ffffffffc0202522:	8419                	srai	s0,s0,0x6
ffffffffc0202524:	943e                	add	s0,s0,a5
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202526:	042a                	slli	s0,s0,0xa
ffffffffc0202528:	8cc1                	or	s1,s1,s0
ffffffffc020252a:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020252e:	0099b023          	sd	s1,0(s3)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202532:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202536:	4501                	li	a0,0
}
ffffffffc0202538:	70e2                	ld	ra,56(sp)
ffffffffc020253a:	7442                	ld	s0,48(sp)
ffffffffc020253c:	74a2                	ld	s1,40(sp)
ffffffffc020253e:	7902                	ld	s2,32(sp)
ffffffffc0202540:	69e2                	ld	s3,24(sp)
ffffffffc0202542:	6a42                	ld	s4,16(sp)
ffffffffc0202544:	6aa2                	ld	s5,8(sp)
ffffffffc0202546:	6121                	addi	sp,sp,64
ffffffffc0202548:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020254a:	078a                	slli	a5,a5,0x2
ffffffffc020254c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020254e:	0000b717          	auipc	a4,0xb
ffffffffc0202552:	f5a73703          	ld	a4,-166(a4) # ffffffffc020d4a8 <npage>
ffffffffc0202556:	06e7ff63          	bgeu	a5,a4,ffffffffc02025d4 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc020255a:	0000ba97          	auipc	s5,0xb
ffffffffc020255e:	f56a8a93          	addi	s5,s5,-170 # ffffffffc020d4b0 <pages>
ffffffffc0202562:	000ab703          	ld	a4,0(s5)
ffffffffc0202566:	fff80937          	lui	s2,0xfff80
ffffffffc020256a:	993e                	add	s2,s2,a5
ffffffffc020256c:	091a                	slli	s2,s2,0x6
ffffffffc020256e:	993a                	add	s2,s2,a4
        if (p == page)
ffffffffc0202570:	01240c63          	beq	s0,s2,ffffffffc0202588 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202574:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd72b1c>
ffffffffc0202578:	fff7869b          	addiw	a3,a5,-1
ffffffffc020257c:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202580:	c691                	beqz	a3,ffffffffc020258c <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202582:	120a0073          	sfence.vma	s4
}
ffffffffc0202586:	bf59                	j	ffffffffc020251c <page_insert+0x3a>
ffffffffc0202588:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020258a:	bf49                	j	ffffffffc020251c <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020258c:	100027f3          	csrr	a5,sstatus
ffffffffc0202590:	8b89                	andi	a5,a5,2
ffffffffc0202592:	ef91                	bnez	a5,ffffffffc02025ae <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202594:	0000b797          	auipc	a5,0xb
ffffffffc0202598:	f247b783          	ld	a5,-220(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc020259c:	739c                	ld	a5,32(a5)
ffffffffc020259e:	4585                	li	a1,1
ffffffffc02025a0:	854a                	mv	a0,s2
ffffffffc02025a2:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02025a4:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025a8:	120a0073          	sfence.vma	s4
ffffffffc02025ac:	bf85                	j	ffffffffc020251c <page_insert+0x3a>
        intr_disable();
ffffffffc02025ae:	b88fe0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025b2:	0000b797          	auipc	a5,0xb
ffffffffc02025b6:	f067b783          	ld	a5,-250(a5) # ffffffffc020d4b8 <pmm_manager>
ffffffffc02025ba:	739c                	ld	a5,32(a5)
ffffffffc02025bc:	4585                	li	a1,1
ffffffffc02025be:	854a                	mv	a0,s2
ffffffffc02025c0:	9782                	jalr	a5
        intr_enable();
ffffffffc02025c2:	b6efe0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02025c6:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ca:	120a0073          	sfence.vma	s4
ffffffffc02025ce:	b7b9                	j	ffffffffc020251c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02025d0:	5571                	li	a0,-4
ffffffffc02025d2:	b79d                	j	ffffffffc0202538 <page_insert+0x56>
ffffffffc02025d4:	b07ff0ef          	jal	ra,ffffffffc02020da <pa2page.part.0>

ffffffffc02025d8 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02025d8:	00003797          	auipc	a5,0x3
ffffffffc02025dc:	a4878793          	addi	a5,a5,-1464 # ffffffffc0205020 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025e0:	638c                	ld	a1,0(a5)
{
ffffffffc02025e2:	7159                	addi	sp,sp,-112
ffffffffc02025e4:	f85a                	sd	s6,48(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0205090 <default_pmm_manager+0x70>
    pmm_manager = &default_pmm_manager;
ffffffffc02025ee:	0000bb17          	auipc	s6,0xb
ffffffffc02025f2:	ecab0b13          	addi	s6,s6,-310 # ffffffffc020d4b8 <pmm_manager>
{
ffffffffc02025f6:	f486                	sd	ra,104(sp)
ffffffffc02025f8:	e8ca                	sd	s2,80(sp)
ffffffffc02025fa:	e4ce                	sd	s3,72(sp)
ffffffffc02025fc:	f0a2                	sd	s0,96(sp)
ffffffffc02025fe:	eca6                	sd	s1,88(sp)
ffffffffc0202600:	e0d2                	sd	s4,64(sp)
ffffffffc0202602:	fc56                	sd	s5,56(sp)
ffffffffc0202604:	f45e                	sd	s7,40(sp)
ffffffffc0202606:	f062                	sd	s8,32(sp)
ffffffffc0202608:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020260a:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020260e:	ad3fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    pmm_manager->init();
ffffffffc0202612:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202616:	0000b997          	auipc	s3,0xb
ffffffffc020261a:	eaa98993          	addi	s3,s3,-342 # ffffffffc020d4c0 <va_pa_offset>
    pmm_manager->init();
ffffffffc020261e:	679c                	ld	a5,8(a5)
ffffffffc0202620:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202622:	57f5                	li	a5,-3
ffffffffc0202624:	07fa                	slli	a5,a5,0x1e
ffffffffc0202626:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc020262a:	a2afe0ef          	jal	ra,ffffffffc0200854 <get_memory_base>
ffffffffc020262e:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0202630:	a2efe0ef          	jal	ra,ffffffffc020085e <get_memory_size>
    if (mem_size == 0) {
ffffffffc0202634:	200505e3          	beqz	a0,ffffffffc020303e <pmm_init+0xa66>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0202638:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc020263a:	00003517          	auipc	a0,0x3
ffffffffc020263e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02050c8 <default_pmm_manager+0xa8>
ffffffffc0202642:	a9ffd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0202646:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020264a:	fff40693          	addi	a3,s0,-1
ffffffffc020264e:	864a                	mv	a2,s2
ffffffffc0202650:	85a6                	mv	a1,s1
ffffffffc0202652:	00003517          	auipc	a0,0x3
ffffffffc0202656:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02050e0 <default_pmm_manager+0xc0>
ffffffffc020265a:	a87fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020265e:	c8000737          	lui	a4,0xc8000
ffffffffc0202662:	87a2                	mv	a5,s0
ffffffffc0202664:	54876163          	bltu	a4,s0,ffffffffc0202ba6 <pmm_init+0x5ce>
ffffffffc0202668:	757d                	lui	a0,0xfffff
ffffffffc020266a:	0000c617          	auipc	a2,0xc
ffffffffc020266e:	e7960613          	addi	a2,a2,-391 # ffffffffc020e4e3 <end+0xfff>
ffffffffc0202672:	8e69                	and	a2,a2,a0
ffffffffc0202674:	0000b497          	auipc	s1,0xb
ffffffffc0202678:	e3448493          	addi	s1,s1,-460 # ffffffffc020d4a8 <npage>
ffffffffc020267c:	00c7d513          	srli	a0,a5,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202680:	0000bb97          	auipc	s7,0xb
ffffffffc0202684:	e30b8b93          	addi	s7,s7,-464 # ffffffffc020d4b0 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202688:	e088                	sd	a0,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020268a:	00cbb023          	sd	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020268e:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202692:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202694:	02f50863          	beq	a0,a5,ffffffffc02026c4 <pmm_init+0xec>
ffffffffc0202698:	4781                	li	a5,0
ffffffffc020269a:	4585                	li	a1,1
ffffffffc020269c:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02026a0:	00679513          	slli	a0,a5,0x6
ffffffffc02026a4:	9532                	add	a0,a0,a2
ffffffffc02026a6:	00850713          	addi	a4,a0,8 # fffffffffffff008 <end+0x3fdf1b24>
ffffffffc02026aa:	40b7302f          	amoor.d	zero,a1,(a4)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026ae:	6088                	ld	a0,0(s1)
ffffffffc02026b0:	0785                	addi	a5,a5,1
        SetPageReserved(pages + i);
ffffffffc02026b2:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02026b6:	00d50733          	add	a4,a0,a3
ffffffffc02026ba:	fee7e3e3          	bltu	a5,a4,ffffffffc02026a0 <pmm_init+0xc8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026be:	071a                	slli	a4,a4,0x6
ffffffffc02026c0:	00e606b3          	add	a3,a2,a4
ffffffffc02026c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02026c8:	2ef6ece3          	bltu	a3,a5,ffffffffc02031c0 <pmm_init+0xbe8>
ffffffffc02026cc:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02026d0:	77fd                	lui	a5,0xfffff
ffffffffc02026d2:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026d4:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc02026d6:	5086eb63          	bltu	a3,s0,ffffffffc0202bec <pmm_init+0x614>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02026da:	00003517          	auipc	a0,0x3
ffffffffc02026de:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0205108 <default_pmm_manager+0xe8>
ffffffffc02026e2:	9fffd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02026e6:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02026ea:	0000b917          	auipc	s2,0xb
ffffffffc02026ee:	db690913          	addi	s2,s2,-586 # ffffffffc020d4a0 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02026f2:	7b9c                	ld	a5,48(a5)
ffffffffc02026f4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02026f6:	00003517          	auipc	a0,0x3
ffffffffc02026fa:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0205120 <default_pmm_manager+0x100>
ffffffffc02026fe:	9e3fd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202702:	00006697          	auipc	a3,0x6
ffffffffc0202706:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc020270a:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020270e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202712:	28f6ebe3          	bltu	a3,a5,ffffffffc02031a8 <pmm_init+0xbd0>
ffffffffc0202716:	0009b783          	ld	a5,0(s3)
ffffffffc020271a:	8e9d                	sub	a3,a3,a5
ffffffffc020271c:	0000b797          	auipc	a5,0xb
ffffffffc0202720:	d6d7be23          	sd	a3,-644(a5) # ffffffffc020d498 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202724:	100027f3          	csrr	a5,sstatus
ffffffffc0202728:	8b89                	andi	a5,a5,2
ffffffffc020272a:	4a079763          	bnez	a5,ffffffffc0202bd8 <pmm_init+0x600>
        ret = pmm_manager->nr_free_pages();
ffffffffc020272e:	000b3783          	ld	a5,0(s6)
ffffffffc0202732:	779c                	ld	a5,40(a5)
ffffffffc0202734:	9782                	jalr	a5
ffffffffc0202736:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202738:	6098                	ld	a4,0(s1)
ffffffffc020273a:	c80007b7          	lui	a5,0xc8000
ffffffffc020273e:	83b1                	srli	a5,a5,0xc
ffffffffc0202740:	66e7e363          	bltu	a5,a4,ffffffffc0202da6 <pmm_init+0x7ce>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202744:	00093503          	ld	a0,0(s2)
ffffffffc0202748:	62050f63          	beqz	a0,ffffffffc0202d86 <pmm_init+0x7ae>
ffffffffc020274c:	03451793          	slli	a5,a0,0x34
ffffffffc0202750:	62079b63          	bnez	a5,ffffffffc0202d86 <pmm_init+0x7ae>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202754:	4601                	li	a2,0
ffffffffc0202756:	4581                	li	a1,0
ffffffffc0202758:	c9bff0ef          	jal	ra,ffffffffc02023f2 <get_page>
ffffffffc020275c:	60051563          	bnez	a0,ffffffffc0202d66 <pmm_init+0x78e>
ffffffffc0202760:	100027f3          	csrr	a5,sstatus
ffffffffc0202764:	8b89                	andi	a5,a5,2
ffffffffc0202766:	44079e63          	bnez	a5,ffffffffc0202bc2 <pmm_init+0x5ea>
        page = pmm_manager->alloc_pages(n);
ffffffffc020276a:	000b3783          	ld	a5,0(s6)
ffffffffc020276e:	4505                	li	a0,1
ffffffffc0202770:	6f9c                	ld	a5,24(a5)
ffffffffc0202772:	9782                	jalr	a5
ffffffffc0202774:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202776:	00093503          	ld	a0,0(s2)
ffffffffc020277a:	4681                	li	a3,0
ffffffffc020277c:	4601                	li	a2,0
ffffffffc020277e:	85d2                	mv	a1,s4
ffffffffc0202780:	d63ff0ef          	jal	ra,ffffffffc02024e2 <page_insert>
ffffffffc0202784:	26051ae3          	bnez	a0,ffffffffc02031f8 <pmm_init+0xc20>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202788:	00093503          	ld	a0,0(s2)
ffffffffc020278c:	4601                	li	a2,0
ffffffffc020278e:	4581                	li	a1,0
ffffffffc0202790:	a3bff0ef          	jal	ra,ffffffffc02021ca <get_pte>
ffffffffc0202794:	240502e3          	beqz	a0,ffffffffc02031d8 <pmm_init+0xc00>
    assert(pte2page(*ptep) == p1);
ffffffffc0202798:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc020279a:	0017f713          	andi	a4,a5,1
ffffffffc020279e:	5a070263          	beqz	a4,ffffffffc0202d42 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc02027a2:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027a4:	078a                	slli	a5,a5,0x2
ffffffffc02027a6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027a8:	58e7fb63          	bgeu	a5,a4,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ac:	000bb683          	ld	a3,0(s7)
ffffffffc02027b0:	fff80637          	lui	a2,0xfff80
ffffffffc02027b4:	97b2                	add	a5,a5,a2
ffffffffc02027b6:	079a                	slli	a5,a5,0x6
ffffffffc02027b8:	97b6                	add	a5,a5,a3
ffffffffc02027ba:	14fa17e3          	bne	s4,a5,ffffffffc0203108 <pmm_init+0xb30>
    assert(page_ref(p1) == 1);
ffffffffc02027be:	000a2683          	lw	a3,0(s4) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc02027c2:	4785                	li	a5,1
ffffffffc02027c4:	12f692e3          	bne	a3,a5,ffffffffc02030e8 <pmm_init+0xb10>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02027c8:	00093503          	ld	a0,0(s2)
ffffffffc02027cc:	77fd                	lui	a5,0xfffff
ffffffffc02027ce:	6114                	ld	a3,0(a0)
ffffffffc02027d0:	068a                	slli	a3,a3,0x2
ffffffffc02027d2:	8efd                	and	a3,a3,a5
ffffffffc02027d4:	00c6d613          	srli	a2,a3,0xc
ffffffffc02027d8:	0ee67ce3          	bgeu	a2,a4,ffffffffc02030d0 <pmm_init+0xaf8>
ffffffffc02027dc:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027e0:	96e2                	add	a3,a3,s8
ffffffffc02027e2:	0006ba83          	ld	s5,0(a3)
ffffffffc02027e6:	0a8a                	slli	s5,s5,0x2
ffffffffc02027e8:	00fafab3          	and	s5,s5,a5
ffffffffc02027ec:	00cad793          	srli	a5,s5,0xc
ffffffffc02027f0:	0ce7f3e3          	bgeu	a5,a4,ffffffffc02030b6 <pmm_init+0xade>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02027f4:	4601                	li	a2,0
ffffffffc02027f6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027f8:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02027fa:	9d1ff0ef          	jal	ra,ffffffffc02021ca <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02027fe:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202800:	55551363          	bne	a0,s5,ffffffffc0202d46 <pmm_init+0x76e>
ffffffffc0202804:	100027f3          	csrr	a5,sstatus
ffffffffc0202808:	8b89                	andi	a5,a5,2
ffffffffc020280a:	3a079163          	bnez	a5,ffffffffc0202bac <pmm_init+0x5d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc020280e:	000b3783          	ld	a5,0(s6)
ffffffffc0202812:	4505                	li	a0,1
ffffffffc0202814:	6f9c                	ld	a5,24(a5)
ffffffffc0202816:	9782                	jalr	a5
ffffffffc0202818:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020281a:	00093503          	ld	a0,0(s2)
ffffffffc020281e:	46d1                	li	a3,20
ffffffffc0202820:	6605                	lui	a2,0x1
ffffffffc0202822:	85e2                	mv	a1,s8
ffffffffc0202824:	cbfff0ef          	jal	ra,ffffffffc02024e2 <page_insert>
ffffffffc0202828:	060517e3          	bnez	a0,ffffffffc0203096 <pmm_init+0xabe>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020282c:	00093503          	ld	a0,0(s2)
ffffffffc0202830:	4601                	li	a2,0
ffffffffc0202832:	6585                	lui	a1,0x1
ffffffffc0202834:	997ff0ef          	jal	ra,ffffffffc02021ca <get_pte>
ffffffffc0202838:	02050fe3          	beqz	a0,ffffffffc0203076 <pmm_init+0xa9e>
    assert(*ptep & PTE_U);
ffffffffc020283c:	611c                	ld	a5,0(a0)
ffffffffc020283e:	0107f713          	andi	a4,a5,16
ffffffffc0202842:	7c070e63          	beqz	a4,ffffffffc020301e <pmm_init+0xa46>
    assert(*ptep & PTE_W);
ffffffffc0202846:	8b91                	andi	a5,a5,4
ffffffffc0202848:	7a078b63          	beqz	a5,ffffffffc0202ffe <pmm_init+0xa26>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020284c:	00093503          	ld	a0,0(s2)
ffffffffc0202850:	611c                	ld	a5,0(a0)
ffffffffc0202852:	8bc1                	andi	a5,a5,16
ffffffffc0202854:	78078563          	beqz	a5,ffffffffc0202fde <pmm_init+0xa06>
    assert(page_ref(p2) == 1);
ffffffffc0202858:	000c2703          	lw	a4,0(s8) # ff0000 <kern_entry-0xffffffffbf210000>
ffffffffc020285c:	4785                	li	a5,1
ffffffffc020285e:	76f71063          	bne	a4,a5,ffffffffc0202fbe <pmm_init+0x9e6>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202862:	4681                	li	a3,0
ffffffffc0202864:	6605                	lui	a2,0x1
ffffffffc0202866:	85d2                	mv	a1,s4
ffffffffc0202868:	c7bff0ef          	jal	ra,ffffffffc02024e2 <page_insert>
ffffffffc020286c:	72051963          	bnez	a0,ffffffffc0202f9e <pmm_init+0x9c6>
    assert(page_ref(p1) == 2);
ffffffffc0202870:	000a2703          	lw	a4,0(s4)
ffffffffc0202874:	4789                	li	a5,2
ffffffffc0202876:	70f71463          	bne	a4,a5,ffffffffc0202f7e <pmm_init+0x9a6>
    assert(page_ref(p2) == 0);
ffffffffc020287a:	000c2783          	lw	a5,0(s8)
ffffffffc020287e:	6e079063          	bnez	a5,ffffffffc0202f5e <pmm_init+0x986>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202882:	00093503          	ld	a0,0(s2)
ffffffffc0202886:	4601                	li	a2,0
ffffffffc0202888:	6585                	lui	a1,0x1
ffffffffc020288a:	941ff0ef          	jal	ra,ffffffffc02021ca <get_pte>
ffffffffc020288e:	6a050863          	beqz	a0,ffffffffc0202f3e <pmm_init+0x966>
    assert(pte2page(*ptep) == p1);
ffffffffc0202892:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202894:	00177793          	andi	a5,a4,1
ffffffffc0202898:	4a078563          	beqz	a5,ffffffffc0202d42 <pmm_init+0x76a>
    if (PPN(pa) >= npage)
ffffffffc020289c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020289e:	00271793          	slli	a5,a4,0x2
ffffffffc02028a2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02028a4:	48d7fd63          	bgeu	a5,a3,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc02028a8:	000bb683          	ld	a3,0(s7)
ffffffffc02028ac:	fff80ab7          	lui	s5,0xfff80
ffffffffc02028b0:	97d6                	add	a5,a5,s5
ffffffffc02028b2:	079a                	slli	a5,a5,0x6
ffffffffc02028b4:	97b6                	add	a5,a5,a3
ffffffffc02028b6:	66fa1463          	bne	s4,a5,ffffffffc0202f1e <pmm_init+0x946>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028ba:	8b41                	andi	a4,a4,16
ffffffffc02028bc:	64071163          	bnez	a4,ffffffffc0202efe <pmm_init+0x926>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc02028c0:	00093503          	ld	a0,0(s2)
ffffffffc02028c4:	4581                	li	a1,0
ffffffffc02028c6:	b81ff0ef          	jal	ra,ffffffffc0202446 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02028ca:	000a2c83          	lw	s9,0(s4)
ffffffffc02028ce:	4785                	li	a5,1
ffffffffc02028d0:	60fc9763          	bne	s9,a5,ffffffffc0202ede <pmm_init+0x906>
    assert(page_ref(p2) == 0);
ffffffffc02028d4:	000c2783          	lw	a5,0(s8)
ffffffffc02028d8:	5e079363          	bnez	a5,ffffffffc0202ebe <pmm_init+0x8e6>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc02028dc:	00093503          	ld	a0,0(s2)
ffffffffc02028e0:	6585                	lui	a1,0x1
ffffffffc02028e2:	b65ff0ef          	jal	ra,ffffffffc0202446 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02028e6:	000a2783          	lw	a5,0(s4)
ffffffffc02028ea:	52079a63          	bnez	a5,ffffffffc0202e1e <pmm_init+0x846>
    assert(page_ref(p2) == 0);
ffffffffc02028ee:	000c2783          	lw	a5,0(s8)
ffffffffc02028f2:	50079663          	bnez	a5,ffffffffc0202dfe <pmm_init+0x826>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02028f6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc02028fa:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028fc:	000a3683          	ld	a3,0(s4)
ffffffffc0202900:	068a                	slli	a3,a3,0x2
ffffffffc0202902:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202904:	42b6fd63          	bgeu	a3,a1,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202908:	000bb503          	ld	a0,0(s7)
ffffffffc020290c:	96d6                	add	a3,a3,s5
ffffffffc020290e:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc0202910:	00d507b3          	add	a5,a0,a3
ffffffffc0202914:	439c                	lw	a5,0(a5)
ffffffffc0202916:	4d979463          	bne	a5,s9,ffffffffc0202dde <pmm_init+0x806>
    return page - pages + nbase;
ffffffffc020291a:	8699                	srai	a3,a3,0x6
ffffffffc020291c:	00080637          	lui	a2,0x80
ffffffffc0202920:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202922:	00c69713          	slli	a4,a3,0xc
ffffffffc0202926:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202928:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020292a:	48b77e63          	bgeu	a4,a1,ffffffffc0202dc6 <pmm_init+0x7ee>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020292e:	0009b703          	ld	a4,0(s3)
ffffffffc0202932:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0202934:	629c                	ld	a5,0(a3)
ffffffffc0202936:	078a                	slli	a5,a5,0x2
ffffffffc0202938:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020293a:	40b7f263          	bgeu	a5,a1,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc020293e:	8f91                	sub	a5,a5,a2
ffffffffc0202940:	079a                	slli	a5,a5,0x6
ffffffffc0202942:	953e                	add	a0,a0,a5
ffffffffc0202944:	100027f3          	csrr	a5,sstatus
ffffffffc0202948:	8b89                	andi	a5,a5,2
ffffffffc020294a:	30079963          	bnez	a5,ffffffffc0202c5c <pmm_init+0x684>
        pmm_manager->free_pages(base, n);
ffffffffc020294e:	000b3783          	ld	a5,0(s6)
ffffffffc0202952:	4585                	li	a1,1
ffffffffc0202954:	739c                	ld	a5,32(a5)
ffffffffc0202956:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202958:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc020295c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020295e:	078a                	slli	a5,a5,0x2
ffffffffc0202960:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202962:	3ce7fe63          	bgeu	a5,a4,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202966:	000bb503          	ld	a0,0(s7)
ffffffffc020296a:	fff80737          	lui	a4,0xfff80
ffffffffc020296e:	97ba                	add	a5,a5,a4
ffffffffc0202970:	079a                	slli	a5,a5,0x6
ffffffffc0202972:	953e                	add	a0,a0,a5
ffffffffc0202974:	100027f3          	csrr	a5,sstatus
ffffffffc0202978:	8b89                	andi	a5,a5,2
ffffffffc020297a:	2c079563          	bnez	a5,ffffffffc0202c44 <pmm_init+0x66c>
ffffffffc020297e:	000b3783          	ld	a5,0(s6)
ffffffffc0202982:	4585                	li	a1,1
ffffffffc0202984:	739c                	ld	a5,32(a5)
ffffffffc0202986:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202988:	00093783          	ld	a5,0(s2)
ffffffffc020298c:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b1c>
    asm volatile("sfence.vma");
ffffffffc0202990:	12000073          	sfence.vma
ffffffffc0202994:	100027f3          	csrr	a5,sstatus
ffffffffc0202998:	8b89                	andi	a5,a5,2
ffffffffc020299a:	28079b63          	bnez	a5,ffffffffc0202c30 <pmm_init+0x658>
        ret = pmm_manager->nr_free_pages();
ffffffffc020299e:	000b3783          	ld	a5,0(s6)
ffffffffc02029a2:	779c                	ld	a5,40(a5)
ffffffffc02029a4:	9782                	jalr	a5
ffffffffc02029a6:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc02029a8:	4b441b63          	bne	s0,s4,ffffffffc0202e5e <pmm_init+0x886>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029ac:	00003517          	auipc	a0,0x3
ffffffffc02029b0:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0205448 <default_pmm_manager+0x428>
ffffffffc02029b4:	f2cfd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
ffffffffc02029b8:	100027f3          	csrr	a5,sstatus
ffffffffc02029bc:	8b89                	andi	a5,a5,2
ffffffffc02029be:	24079f63          	bnez	a5,ffffffffc0202c1c <pmm_init+0x644>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029c2:	000b3783          	ld	a5,0(s6)
ffffffffc02029c6:	779c                	ld	a5,40(a5)
ffffffffc02029c8:	9782                	jalr	a5
ffffffffc02029ca:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029cc:	6098                	ld	a4,0(s1)
ffffffffc02029ce:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029d2:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02029d4:	00c71793          	slli	a5,a4,0xc
ffffffffc02029d8:	6a05                	lui	s4,0x1
ffffffffc02029da:	02f47c63          	bgeu	s0,a5,ffffffffc0202a12 <pmm_init+0x43a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029de:	00c45793          	srli	a5,s0,0xc
ffffffffc02029e2:	00093503          	ld	a0,0(s2)
ffffffffc02029e6:	2ee7ff63          	bgeu	a5,a4,ffffffffc0202ce4 <pmm_init+0x70c>
ffffffffc02029ea:	0009b583          	ld	a1,0(s3)
ffffffffc02029ee:	4601                	li	a2,0
ffffffffc02029f0:	95a2                	add	a1,a1,s0
ffffffffc02029f2:	fd8ff0ef          	jal	ra,ffffffffc02021ca <get_pte>
ffffffffc02029f6:	32050463          	beqz	a0,ffffffffc0202d1e <pmm_init+0x746>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029fa:	611c                	ld	a5,0(a0)
ffffffffc02029fc:	078a                	slli	a5,a5,0x2
ffffffffc02029fe:	0157f7b3          	and	a5,a5,s5
ffffffffc0202a02:	2e879e63          	bne	a5,s0,ffffffffc0202cfe <pmm_init+0x726>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202a06:	6098                	ld	a4,0(s1)
ffffffffc0202a08:	9452                	add	s0,s0,s4
ffffffffc0202a0a:	00c71793          	slli	a5,a4,0xc
ffffffffc0202a0e:	fcf468e3          	bltu	s0,a5,ffffffffc02029de <pmm_init+0x406>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202a12:	00093783          	ld	a5,0(s2)
ffffffffc0202a16:	639c                	ld	a5,0(a5)
ffffffffc0202a18:	42079363          	bnez	a5,ffffffffc0202e3e <pmm_init+0x866>
ffffffffc0202a1c:	100027f3          	csrr	a5,sstatus
ffffffffc0202a20:	8b89                	andi	a5,a5,2
ffffffffc0202a22:	24079963          	bnez	a5,ffffffffc0202c74 <pmm_init+0x69c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a26:	000b3783          	ld	a5,0(s6)
ffffffffc0202a2a:	4505                	li	a0,1
ffffffffc0202a2c:	6f9c                	ld	a5,24(a5)
ffffffffc0202a2e:	9782                	jalr	a5
ffffffffc0202a30:	8a2a                	mv	s4,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a32:	00093503          	ld	a0,0(s2)
ffffffffc0202a36:	4699                	li	a3,6
ffffffffc0202a38:	10000613          	li	a2,256
ffffffffc0202a3c:	85d2                	mv	a1,s4
ffffffffc0202a3e:	aa5ff0ef          	jal	ra,ffffffffc02024e2 <page_insert>
ffffffffc0202a42:	44051e63          	bnez	a0,ffffffffc0202e9e <pmm_init+0x8c6>
    assert(page_ref(p) == 1);
ffffffffc0202a46:	000a2703          	lw	a4,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202a4a:	4785                	li	a5,1
ffffffffc0202a4c:	42f71963          	bne	a4,a5,ffffffffc0202e7e <pmm_init+0x8a6>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a50:	00093503          	ld	a0,0(s2)
ffffffffc0202a54:	6405                	lui	s0,0x1
ffffffffc0202a56:	4699                	li	a3,6
ffffffffc0202a58:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202a5c:	85d2                	mv	a1,s4
ffffffffc0202a5e:	a85ff0ef          	jal	ra,ffffffffc02024e2 <page_insert>
ffffffffc0202a62:	72051363          	bnez	a0,ffffffffc0203188 <pmm_init+0xbb0>
    assert(page_ref(p) == 2);
ffffffffc0202a66:	000a2703          	lw	a4,0(s4)
ffffffffc0202a6a:	4789                	li	a5,2
ffffffffc0202a6c:	6ef71e63          	bne	a4,a5,ffffffffc0203168 <pmm_init+0xb90>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a70:	00003597          	auipc	a1,0x3
ffffffffc0202a74:	b2058593          	addi	a1,a1,-1248 # ffffffffc0205590 <default_pmm_manager+0x570>
ffffffffc0202a78:	10000513          	li	a0,256
ffffffffc0202a7c:	79b000ef          	jal	ra,ffffffffc0203a16 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a80:	10040593          	addi	a1,s0,256
ffffffffc0202a84:	10000513          	li	a0,256
ffffffffc0202a88:	7a1000ef          	jal	ra,ffffffffc0203a28 <strcmp>
ffffffffc0202a8c:	6a051e63          	bnez	a0,ffffffffc0203148 <pmm_init+0xb70>
    return page - pages + nbase;
ffffffffc0202a90:	000bb683          	ld	a3,0(s7)
ffffffffc0202a94:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a98:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0202a9a:	40da06b3          	sub	a3,s4,a3
ffffffffc0202a9e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202aa0:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202aa2:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202aa4:	8031                	srli	s0,s0,0xc
ffffffffc0202aa6:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aaa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aac:	30f77d63          	bgeu	a4,a5,ffffffffc0202dc6 <pmm_init+0x7ee>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ab0:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ab4:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ab8:	96be                	add	a3,a3,a5
ffffffffc0202aba:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202abe:	723000ef          	jal	ra,ffffffffc02039e0 <strlen>
ffffffffc0202ac2:	66051363          	bnez	a0,ffffffffc0203128 <pmm_init+0xb50>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202ac6:	00093a83          	ld	s5,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202aca:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202acc:	000ab683          	ld	a3,0(s5) # fffffffffffff000 <end+0x3fdf1b1c>
ffffffffc0202ad0:	068a                	slli	a3,a3,0x2
ffffffffc0202ad2:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ad4:	26f6f563          	bgeu	a3,a5,ffffffffc0202d3e <pmm_init+0x766>
    return KADDR(page2pa(page));
ffffffffc0202ad8:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ada:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202adc:	2ef47563          	bgeu	s0,a5,ffffffffc0202dc6 <pmm_init+0x7ee>
ffffffffc0202ae0:	0009b403          	ld	s0,0(s3)
ffffffffc0202ae4:	9436                	add	s0,s0,a3
ffffffffc0202ae6:	100027f3          	csrr	a5,sstatus
ffffffffc0202aea:	8b89                	andi	a5,a5,2
ffffffffc0202aec:	1e079163          	bnez	a5,ffffffffc0202cce <pmm_init+0x6f6>
        pmm_manager->free_pages(base, n);
ffffffffc0202af0:	000b3783          	ld	a5,0(s6)
ffffffffc0202af4:	4585                	li	a1,1
ffffffffc0202af6:	8552                	mv	a0,s4
ffffffffc0202af8:	739c                	ld	a5,32(a5)
ffffffffc0202afa:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202afc:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage)
ffffffffc0202afe:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b00:	078a                	slli	a5,a5,0x2
ffffffffc0202b02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b04:	22e7fd63          	bgeu	a5,a4,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b08:	000bb503          	ld	a0,0(s7)
ffffffffc0202b0c:	fff80737          	lui	a4,0xfff80
ffffffffc0202b10:	97ba                	add	a5,a5,a4
ffffffffc0202b12:	079a                	slli	a5,a5,0x6
ffffffffc0202b14:	953e                	add	a0,a0,a5
ffffffffc0202b16:	100027f3          	csrr	a5,sstatus
ffffffffc0202b1a:	8b89                	andi	a5,a5,2
ffffffffc0202b1c:	18079d63          	bnez	a5,ffffffffc0202cb6 <pmm_init+0x6de>
ffffffffc0202b20:	000b3783          	ld	a5,0(s6)
ffffffffc0202b24:	4585                	li	a1,1
ffffffffc0202b26:	739c                	ld	a5,32(a5)
ffffffffc0202b28:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b2a:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage)
ffffffffc0202b2e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b30:	078a                	slli	a5,a5,0x2
ffffffffc0202b32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b34:	20e7f563          	bgeu	a5,a4,ffffffffc0202d3e <pmm_init+0x766>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b38:	000bb503          	ld	a0,0(s7)
ffffffffc0202b3c:	fff80737          	lui	a4,0xfff80
ffffffffc0202b40:	97ba                	add	a5,a5,a4
ffffffffc0202b42:	079a                	slli	a5,a5,0x6
ffffffffc0202b44:	953e                	add	a0,a0,a5
ffffffffc0202b46:	100027f3          	csrr	a5,sstatus
ffffffffc0202b4a:	8b89                	andi	a5,a5,2
ffffffffc0202b4c:	14079963          	bnez	a5,ffffffffc0202c9e <pmm_init+0x6c6>
ffffffffc0202b50:	000b3783          	ld	a5,0(s6)
ffffffffc0202b54:	4585                	li	a1,1
ffffffffc0202b56:	739c                	ld	a5,32(a5)
ffffffffc0202b58:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202b5a:	00093783          	ld	a5,0(s2)
ffffffffc0202b5e:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202b62:	12000073          	sfence.vma
ffffffffc0202b66:	100027f3          	csrr	a5,sstatus
ffffffffc0202b6a:	8b89                	andi	a5,a5,2
ffffffffc0202b6c:	10079f63          	bnez	a5,ffffffffc0202c8a <pmm_init+0x6b2>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b70:	000b3783          	ld	a5,0(s6)
ffffffffc0202b74:	779c                	ld	a5,40(a5)
ffffffffc0202b76:	9782                	jalr	a5
ffffffffc0202b78:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202b7a:	4c8c1e63          	bne	s8,s0,ffffffffc0203056 <pmm_init+0xa7e>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b7e:	00003517          	auipc	a0,0x3
ffffffffc0202b82:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0205608 <default_pmm_manager+0x5e8>
ffffffffc0202b86:	d5afd0ef          	jal	ra,ffffffffc02000e0 <cprintf>
}
ffffffffc0202b8a:	7406                	ld	s0,96(sp)
ffffffffc0202b8c:	70a6                	ld	ra,104(sp)
ffffffffc0202b8e:	64e6                	ld	s1,88(sp)
ffffffffc0202b90:	6946                	ld	s2,80(sp)
ffffffffc0202b92:	69a6                	ld	s3,72(sp)
ffffffffc0202b94:	6a06                	ld	s4,64(sp)
ffffffffc0202b96:	7ae2                	ld	s5,56(sp)
ffffffffc0202b98:	7b42                	ld	s6,48(sp)
ffffffffc0202b9a:	7ba2                	ld	s7,40(sp)
ffffffffc0202b9c:	7c02                	ld	s8,32(sp)
ffffffffc0202b9e:	6ce2                	ld	s9,24(sp)
ffffffffc0202ba0:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202ba2:	8c5fe06f          	j	ffffffffc0201466 <kmalloc_init>
    npage = maxpa / PGSIZE;
ffffffffc0202ba6:	c80007b7          	lui	a5,0xc8000
ffffffffc0202baa:	bc7d                	j	ffffffffc0202668 <pmm_init+0x90>
        intr_disable();
ffffffffc0202bac:	d8bfd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202bb0:	000b3783          	ld	a5,0(s6)
ffffffffc0202bb4:	4505                	li	a0,1
ffffffffc0202bb6:	6f9c                	ld	a5,24(a5)
ffffffffc0202bb8:	9782                	jalr	a5
ffffffffc0202bba:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202bbc:	d75fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202bc0:	b9a9                	j	ffffffffc020281a <pmm_init+0x242>
        intr_disable();
ffffffffc0202bc2:	d75fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202bc6:	000b3783          	ld	a5,0(s6)
ffffffffc0202bca:	4505                	li	a0,1
ffffffffc0202bcc:	6f9c                	ld	a5,24(a5)
ffffffffc0202bce:	9782                	jalr	a5
ffffffffc0202bd0:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202bd2:	d5ffd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202bd6:	b645                	j	ffffffffc0202776 <pmm_init+0x19e>
        intr_disable();
ffffffffc0202bd8:	d5ffd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bdc:	000b3783          	ld	a5,0(s6)
ffffffffc0202be0:	779c                	ld	a5,40(a5)
ffffffffc0202be2:	9782                	jalr	a5
ffffffffc0202be4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202be6:	d4bfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202bea:	b6b9                	j	ffffffffc0202738 <pmm_init+0x160>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202bec:	6705                	lui	a4,0x1
ffffffffc0202bee:	177d                	addi	a4,a4,-1
ffffffffc0202bf0:	96ba                	add	a3,a3,a4
ffffffffc0202bf2:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202bf4:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202bf8:	14a77363          	bgeu	a4,a0,ffffffffc0202d3e <pmm_init+0x766>
    pmm_manager->init_memmap(base, n);
ffffffffc0202bfc:	000b3683          	ld	a3,0(s6)
    return &pages[PPN(pa) - nbase];
ffffffffc0202c00:	fff80537          	lui	a0,0xfff80
ffffffffc0202c04:	972a                	add	a4,a4,a0
ffffffffc0202c06:	6a94                	ld	a3,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c08:	8c1d                	sub	s0,s0,a5
ffffffffc0202c0a:	00671513          	slli	a0,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202c0e:	00c45593          	srli	a1,s0,0xc
ffffffffc0202c12:	9532                	add	a0,a0,a2
ffffffffc0202c14:	9682                	jalr	a3
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202c16:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202c1a:	b4c1                	j	ffffffffc02026da <pmm_init+0x102>
        intr_disable();
ffffffffc0202c1c:	d1bfd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c20:	000b3783          	ld	a5,0(s6)
ffffffffc0202c24:	779c                	ld	a5,40(a5)
ffffffffc0202c26:	9782                	jalr	a5
ffffffffc0202c28:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202c2a:	d07fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c2e:	bb79                	j	ffffffffc02029cc <pmm_init+0x3f4>
        intr_disable();
ffffffffc0202c30:	d07fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202c34:	000b3783          	ld	a5,0(s6)
ffffffffc0202c38:	779c                	ld	a5,40(a5)
ffffffffc0202c3a:	9782                	jalr	a5
ffffffffc0202c3c:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202c3e:	cf3fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c42:	b39d                	j	ffffffffc02029a8 <pmm_init+0x3d0>
ffffffffc0202c44:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202c46:	cf1fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202c4a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c4e:	6522                	ld	a0,8(sp)
ffffffffc0202c50:	4585                	li	a1,1
ffffffffc0202c52:	739c                	ld	a5,32(a5)
ffffffffc0202c54:	9782                	jalr	a5
        intr_enable();
ffffffffc0202c56:	cdbfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c5a:	b33d                	j	ffffffffc0202988 <pmm_init+0x3b0>
ffffffffc0202c5c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202c5e:	cd9fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202c62:	000b3783          	ld	a5,0(s6)
ffffffffc0202c66:	6522                	ld	a0,8(sp)
ffffffffc0202c68:	4585                	li	a1,1
ffffffffc0202c6a:	739c                	ld	a5,32(a5)
ffffffffc0202c6c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202c6e:	cc3fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c72:	b1dd                	j	ffffffffc0202958 <pmm_init+0x380>
        intr_disable();
ffffffffc0202c74:	cc3fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c78:	000b3783          	ld	a5,0(s6)
ffffffffc0202c7c:	4505                	li	a0,1
ffffffffc0202c7e:	6f9c                	ld	a5,24(a5)
ffffffffc0202c80:	9782                	jalr	a5
ffffffffc0202c82:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202c84:	cadfd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c88:	b36d                	j	ffffffffc0202a32 <pmm_init+0x45a>
        intr_disable();
ffffffffc0202c8a:	cadfd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c8e:	000b3783          	ld	a5,0(s6)
ffffffffc0202c92:	779c                	ld	a5,40(a5)
ffffffffc0202c94:	9782                	jalr	a5
ffffffffc0202c96:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202c98:	c99fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202c9c:	bdf9                	j	ffffffffc0202b7a <pmm_init+0x5a2>
ffffffffc0202c9e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ca0:	c97fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ca4:	000b3783          	ld	a5,0(s6)
ffffffffc0202ca8:	6522                	ld	a0,8(sp)
ffffffffc0202caa:	4585                	li	a1,1
ffffffffc0202cac:	739c                	ld	a5,32(a5)
ffffffffc0202cae:	9782                	jalr	a5
        intr_enable();
ffffffffc0202cb0:	c81fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202cb4:	b55d                	j	ffffffffc0202b5a <pmm_init+0x582>
ffffffffc0202cb6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202cb8:	c7ffd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202cbc:	000b3783          	ld	a5,0(s6)
ffffffffc0202cc0:	6522                	ld	a0,8(sp)
ffffffffc0202cc2:	4585                	li	a1,1
ffffffffc0202cc4:	739c                	ld	a5,32(a5)
ffffffffc0202cc6:	9782                	jalr	a5
        intr_enable();
ffffffffc0202cc8:	c69fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202ccc:	bdb9                	j	ffffffffc0202b2a <pmm_init+0x552>
        intr_disable();
ffffffffc0202cce:	c69fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
ffffffffc0202cd2:	000b3783          	ld	a5,0(s6)
ffffffffc0202cd6:	4585                	li	a1,1
ffffffffc0202cd8:	8552                	mv	a0,s4
ffffffffc0202cda:	739c                	ld	a5,32(a5)
ffffffffc0202cdc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202cde:	c53fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc0202ce2:	bd29                	j	ffffffffc0202afc <pmm_init+0x524>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202ce4:	86a2                	mv	a3,s0
ffffffffc0202ce6:	00002617          	auipc	a2,0x2
ffffffffc0202cea:	ea260613          	addi	a2,a2,-350 # ffffffffc0204b88 <commands+0xa28>
ffffffffc0202cee:	1a400593          	li	a1,420
ffffffffc0202cf2:	00002517          	auipc	a0,0x2
ffffffffc0202cf6:	38e50513          	addi	a0,a0,910 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202cfa:	ce4fd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202cfe:	00002697          	auipc	a3,0x2
ffffffffc0202d02:	7aa68693          	addi	a3,a3,1962 # ffffffffc02054a8 <default_pmm_manager+0x488>
ffffffffc0202d06:	00002617          	auipc	a2,0x2
ffffffffc0202d0a:	c6260613          	addi	a2,a2,-926 # ffffffffc0204968 <commands+0x808>
ffffffffc0202d0e:	1a500593          	li	a1,421
ffffffffc0202d12:	00002517          	auipc	a0,0x2
ffffffffc0202d16:	36e50513          	addi	a0,a0,878 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202d1a:	cc4fd0ef          	jal	ra,ffffffffc02001de <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d1e:	00002697          	auipc	a3,0x2
ffffffffc0202d22:	74a68693          	addi	a3,a3,1866 # ffffffffc0205468 <default_pmm_manager+0x448>
ffffffffc0202d26:	00002617          	auipc	a2,0x2
ffffffffc0202d2a:	c4260613          	addi	a2,a2,-958 # ffffffffc0204968 <commands+0x808>
ffffffffc0202d2e:	1a400593          	li	a1,420
ffffffffc0202d32:	00002517          	auipc	a0,0x2
ffffffffc0202d36:	34e50513          	addi	a0,a0,846 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202d3a:	ca4fd0ef          	jal	ra,ffffffffc02001de <__panic>
ffffffffc0202d3e:	b9cff0ef          	jal	ra,ffffffffc02020da <pa2page.part.0>
ffffffffc0202d42:	bb4ff0ef          	jal	ra,ffffffffc02020f6 <pte2page.part.0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202d46:	00002697          	auipc	a3,0x2
ffffffffc0202d4a:	51a68693          	addi	a3,a3,1306 # ffffffffc0205260 <default_pmm_manager+0x240>
ffffffffc0202d4e:	00002617          	auipc	a2,0x2
ffffffffc0202d52:	c1a60613          	addi	a2,a2,-998 # ffffffffc0204968 <commands+0x808>
ffffffffc0202d56:	17400593          	li	a1,372
ffffffffc0202d5a:	00002517          	auipc	a0,0x2
ffffffffc0202d5e:	32650513          	addi	a0,a0,806 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202d62:	c7cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202d66:	00002697          	auipc	a3,0x2
ffffffffc0202d6a:	43a68693          	addi	a3,a3,1082 # ffffffffc02051a0 <default_pmm_manager+0x180>
ffffffffc0202d6e:	00002617          	auipc	a2,0x2
ffffffffc0202d72:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0204968 <commands+0x808>
ffffffffc0202d76:	16700593          	li	a1,359
ffffffffc0202d7a:	00002517          	auipc	a0,0x2
ffffffffc0202d7e:	30650513          	addi	a0,a0,774 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202d82:	c5cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202d86:	00002697          	auipc	a3,0x2
ffffffffc0202d8a:	3da68693          	addi	a3,a3,986 # ffffffffc0205160 <default_pmm_manager+0x140>
ffffffffc0202d8e:	00002617          	auipc	a2,0x2
ffffffffc0202d92:	bda60613          	addi	a2,a2,-1062 # ffffffffc0204968 <commands+0x808>
ffffffffc0202d96:	16600593          	li	a1,358
ffffffffc0202d9a:	00002517          	auipc	a0,0x2
ffffffffc0202d9e:	2e650513          	addi	a0,a0,742 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202da2:	c3cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202da6:	00002697          	auipc	a3,0x2
ffffffffc0202daa:	39a68693          	addi	a3,a3,922 # ffffffffc0205140 <default_pmm_manager+0x120>
ffffffffc0202dae:	00002617          	auipc	a2,0x2
ffffffffc0202db2:	bba60613          	addi	a2,a2,-1094 # ffffffffc0204968 <commands+0x808>
ffffffffc0202db6:	16500593          	li	a1,357
ffffffffc0202dba:	00002517          	auipc	a0,0x2
ffffffffc0202dbe:	2c650513          	addi	a0,a0,710 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202dc2:	c1cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dc6:	00002617          	auipc	a2,0x2
ffffffffc0202dca:	dc260613          	addi	a2,a2,-574 # ffffffffc0204b88 <commands+0xa28>
ffffffffc0202dce:	07100593          	li	a1,113
ffffffffc0202dd2:	00002517          	auipc	a0,0x2
ffffffffc0202dd6:	dde50513          	addi	a0,a0,-546 # ffffffffc0204bb0 <commands+0xa50>
ffffffffc0202dda:	c04fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202dde:	00002697          	auipc	a3,0x2
ffffffffc0202de2:	61268693          	addi	a3,a3,1554 # ffffffffc02053f0 <default_pmm_manager+0x3d0>
ffffffffc0202de6:	00002617          	auipc	a2,0x2
ffffffffc0202dea:	b8260613          	addi	a2,a2,-1150 # ffffffffc0204968 <commands+0x808>
ffffffffc0202dee:	18d00593          	li	a1,397
ffffffffc0202df2:	00002517          	auipc	a0,0x2
ffffffffc0202df6:	28e50513          	addi	a0,a0,654 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202dfa:	be4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dfe:	00002697          	auipc	a3,0x2
ffffffffc0202e02:	5aa68693          	addi	a3,a3,1450 # ffffffffc02053a8 <default_pmm_manager+0x388>
ffffffffc0202e06:	00002617          	auipc	a2,0x2
ffffffffc0202e0a:	b6260613          	addi	a2,a2,-1182 # ffffffffc0204968 <commands+0x808>
ffffffffc0202e0e:	18b00593          	li	a1,395
ffffffffc0202e12:	00002517          	auipc	a0,0x2
ffffffffc0202e16:	26e50513          	addi	a0,a0,622 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202e1a:	bc4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e1e:	00002697          	auipc	a3,0x2
ffffffffc0202e22:	5ba68693          	addi	a3,a3,1466 # ffffffffc02053d8 <default_pmm_manager+0x3b8>
ffffffffc0202e26:	00002617          	auipc	a2,0x2
ffffffffc0202e2a:	b4260613          	addi	a2,a2,-1214 # ffffffffc0204968 <commands+0x808>
ffffffffc0202e2e:	18a00593          	li	a1,394
ffffffffc0202e32:	00002517          	auipc	a0,0x2
ffffffffc0202e36:	24e50513          	addi	a0,a0,590 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202e3a:	ba4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0202e3e:	00002697          	auipc	a3,0x2
ffffffffc0202e42:	68268693          	addi	a3,a3,1666 # ffffffffc02054c0 <default_pmm_manager+0x4a0>
ffffffffc0202e46:	00002617          	auipc	a2,0x2
ffffffffc0202e4a:	b2260613          	addi	a2,a2,-1246 # ffffffffc0204968 <commands+0x808>
ffffffffc0202e4e:	1a800593          	li	a1,424
ffffffffc0202e52:	00002517          	auipc	a0,0x2
ffffffffc0202e56:	22e50513          	addi	a0,a0,558 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202e5a:	b84fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202e5e:	00002697          	auipc	a3,0x2
ffffffffc0202e62:	5c268693          	addi	a3,a3,1474 # ffffffffc0205420 <default_pmm_manager+0x400>
ffffffffc0202e66:	00002617          	auipc	a2,0x2
ffffffffc0202e6a:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204968 <commands+0x808>
ffffffffc0202e6e:	19500593          	li	a1,405
ffffffffc0202e72:	00002517          	auipc	a0,0x2
ffffffffc0202e76:	20e50513          	addi	a0,a0,526 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202e7a:	b64fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e7e:	00002697          	auipc	a3,0x2
ffffffffc0202e82:	69a68693          	addi	a3,a3,1690 # ffffffffc0205518 <default_pmm_manager+0x4f8>
ffffffffc0202e86:	00002617          	auipc	a2,0x2
ffffffffc0202e8a:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204968 <commands+0x808>
ffffffffc0202e8e:	1ad00593          	li	a1,429
ffffffffc0202e92:	00002517          	auipc	a0,0x2
ffffffffc0202e96:	1ee50513          	addi	a0,a0,494 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202e9a:	b44fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202e9e:	00002697          	auipc	a3,0x2
ffffffffc0202ea2:	63a68693          	addi	a3,a3,1594 # ffffffffc02054d8 <default_pmm_manager+0x4b8>
ffffffffc0202ea6:	00002617          	auipc	a2,0x2
ffffffffc0202eaa:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204968 <commands+0x808>
ffffffffc0202eae:	1ac00593          	li	a1,428
ffffffffc0202eb2:	00002517          	auipc	a0,0x2
ffffffffc0202eb6:	1ce50513          	addi	a0,a0,462 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202eba:	b24fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202ebe:	00002697          	auipc	a3,0x2
ffffffffc0202ec2:	4ea68693          	addi	a3,a3,1258 # ffffffffc02053a8 <default_pmm_manager+0x388>
ffffffffc0202ec6:	00002617          	auipc	a2,0x2
ffffffffc0202eca:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204968 <commands+0x808>
ffffffffc0202ece:	18700593          	li	a1,391
ffffffffc0202ed2:	00002517          	auipc	a0,0x2
ffffffffc0202ed6:	1ae50513          	addi	a0,a0,430 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202eda:	b04fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ede:	00002697          	auipc	a3,0x2
ffffffffc0202ee2:	36a68693          	addi	a3,a3,874 # ffffffffc0205248 <default_pmm_manager+0x228>
ffffffffc0202ee6:	00002617          	auipc	a2,0x2
ffffffffc0202eea:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204968 <commands+0x808>
ffffffffc0202eee:	18600593          	li	a1,390
ffffffffc0202ef2:	00002517          	auipc	a0,0x2
ffffffffc0202ef6:	18e50513          	addi	a0,a0,398 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202efa:	ae4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202efe:	00002697          	auipc	a3,0x2
ffffffffc0202f02:	4c268693          	addi	a3,a3,1218 # ffffffffc02053c0 <default_pmm_manager+0x3a0>
ffffffffc0202f06:	00002617          	auipc	a2,0x2
ffffffffc0202f0a:	a6260613          	addi	a2,a2,-1438 # ffffffffc0204968 <commands+0x808>
ffffffffc0202f0e:	18300593          	li	a1,387
ffffffffc0202f12:	00002517          	auipc	a0,0x2
ffffffffc0202f16:	16e50513          	addi	a0,a0,366 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202f1a:	ac4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f1e:	00002697          	auipc	a3,0x2
ffffffffc0202f22:	31268693          	addi	a3,a3,786 # ffffffffc0205230 <default_pmm_manager+0x210>
ffffffffc0202f26:	00002617          	auipc	a2,0x2
ffffffffc0202f2a:	a4260613          	addi	a2,a2,-1470 # ffffffffc0204968 <commands+0x808>
ffffffffc0202f2e:	18200593          	li	a1,386
ffffffffc0202f32:	00002517          	auipc	a0,0x2
ffffffffc0202f36:	14e50513          	addi	a0,a0,334 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202f3a:	aa4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202f3e:	00002697          	auipc	a3,0x2
ffffffffc0202f42:	39268693          	addi	a3,a3,914 # ffffffffc02052d0 <default_pmm_manager+0x2b0>
ffffffffc0202f46:	00002617          	auipc	a2,0x2
ffffffffc0202f4a:	a2260613          	addi	a2,a2,-1502 # ffffffffc0204968 <commands+0x808>
ffffffffc0202f4e:	18100593          	li	a1,385
ffffffffc0202f52:	00002517          	auipc	a0,0x2
ffffffffc0202f56:	12e50513          	addi	a0,a0,302 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202f5a:	a84fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f5e:	00002697          	auipc	a3,0x2
ffffffffc0202f62:	44a68693          	addi	a3,a3,1098 # ffffffffc02053a8 <default_pmm_manager+0x388>
ffffffffc0202f66:	00002617          	auipc	a2,0x2
ffffffffc0202f6a:	a0260613          	addi	a2,a2,-1534 # ffffffffc0204968 <commands+0x808>
ffffffffc0202f6e:	18000593          	li	a1,384
ffffffffc0202f72:	00002517          	auipc	a0,0x2
ffffffffc0202f76:	10e50513          	addi	a0,a0,270 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202f7a:	a64fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202f7e:	00002697          	auipc	a3,0x2
ffffffffc0202f82:	41268693          	addi	a3,a3,1042 # ffffffffc0205390 <default_pmm_manager+0x370>
ffffffffc0202f86:	00002617          	auipc	a2,0x2
ffffffffc0202f8a:	9e260613          	addi	a2,a2,-1566 # ffffffffc0204968 <commands+0x808>
ffffffffc0202f8e:	17f00593          	li	a1,383
ffffffffc0202f92:	00002517          	auipc	a0,0x2
ffffffffc0202f96:	0ee50513          	addi	a0,a0,238 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202f9a:	a44fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202f9e:	00002697          	auipc	a3,0x2
ffffffffc0202fa2:	3c268693          	addi	a3,a3,962 # ffffffffc0205360 <default_pmm_manager+0x340>
ffffffffc0202fa6:	00002617          	auipc	a2,0x2
ffffffffc0202faa:	9c260613          	addi	a2,a2,-1598 # ffffffffc0204968 <commands+0x808>
ffffffffc0202fae:	17e00593          	li	a1,382
ffffffffc0202fb2:	00002517          	auipc	a0,0x2
ffffffffc0202fb6:	0ce50513          	addi	a0,a0,206 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202fba:	a24fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202fbe:	00002697          	auipc	a3,0x2
ffffffffc0202fc2:	38a68693          	addi	a3,a3,906 # ffffffffc0205348 <default_pmm_manager+0x328>
ffffffffc0202fc6:	00002617          	auipc	a2,0x2
ffffffffc0202fca:	9a260613          	addi	a2,a2,-1630 # ffffffffc0204968 <commands+0x808>
ffffffffc0202fce:	17c00593          	li	a1,380
ffffffffc0202fd2:	00002517          	auipc	a0,0x2
ffffffffc0202fd6:	0ae50513          	addi	a0,a0,174 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202fda:	a04fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202fde:	00002697          	auipc	a3,0x2
ffffffffc0202fe2:	34a68693          	addi	a3,a3,842 # ffffffffc0205328 <default_pmm_manager+0x308>
ffffffffc0202fe6:	00002617          	auipc	a2,0x2
ffffffffc0202fea:	98260613          	addi	a2,a2,-1662 # ffffffffc0204968 <commands+0x808>
ffffffffc0202fee:	17b00593          	li	a1,379
ffffffffc0202ff2:	00002517          	auipc	a0,0x2
ffffffffc0202ff6:	08e50513          	addi	a0,a0,142 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0202ffa:	9e4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202ffe:	00002697          	auipc	a3,0x2
ffffffffc0203002:	31a68693          	addi	a3,a3,794 # ffffffffc0205318 <default_pmm_manager+0x2f8>
ffffffffc0203006:	00002617          	auipc	a2,0x2
ffffffffc020300a:	96260613          	addi	a2,a2,-1694 # ffffffffc0204968 <commands+0x808>
ffffffffc020300e:	17a00593          	li	a1,378
ffffffffc0203012:	00002517          	auipc	a0,0x2
ffffffffc0203016:	06e50513          	addi	a0,a0,110 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc020301a:	9c4fd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(*ptep & PTE_U);
ffffffffc020301e:	00002697          	auipc	a3,0x2
ffffffffc0203022:	2ea68693          	addi	a3,a3,746 # ffffffffc0205308 <default_pmm_manager+0x2e8>
ffffffffc0203026:	00002617          	auipc	a2,0x2
ffffffffc020302a:	94260613          	addi	a2,a2,-1726 # ffffffffc0204968 <commands+0x808>
ffffffffc020302e:	17900593          	li	a1,377
ffffffffc0203032:	00002517          	auipc	a0,0x2
ffffffffc0203036:	04e50513          	addi	a0,a0,78 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc020303a:	9a4fd0ef          	jal	ra,ffffffffc02001de <__panic>
        panic("DTB memory info not available");
ffffffffc020303e:	00002617          	auipc	a2,0x2
ffffffffc0203042:	06a60613          	addi	a2,a2,106 # ffffffffc02050a8 <default_pmm_manager+0x88>
ffffffffc0203046:	06400593          	li	a1,100
ffffffffc020304a:	00002517          	auipc	a0,0x2
ffffffffc020304e:	03650513          	addi	a0,a0,54 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203052:	98cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203056:	00002697          	auipc	a3,0x2
ffffffffc020305a:	3ca68693          	addi	a3,a3,970 # ffffffffc0205420 <default_pmm_manager+0x400>
ffffffffc020305e:	00002617          	auipc	a2,0x2
ffffffffc0203062:	90a60613          	addi	a2,a2,-1782 # ffffffffc0204968 <commands+0x808>
ffffffffc0203066:	1bf00593          	li	a1,447
ffffffffc020306a:	00002517          	auipc	a0,0x2
ffffffffc020306e:	01650513          	addi	a0,a0,22 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203072:	96cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203076:	00002697          	auipc	a3,0x2
ffffffffc020307a:	25a68693          	addi	a3,a3,602 # ffffffffc02052d0 <default_pmm_manager+0x2b0>
ffffffffc020307e:	00002617          	auipc	a2,0x2
ffffffffc0203082:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0204968 <commands+0x808>
ffffffffc0203086:	17800593          	li	a1,376
ffffffffc020308a:	00002517          	auipc	a0,0x2
ffffffffc020308e:	ff650513          	addi	a0,a0,-10 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203092:	94cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203096:	00002697          	auipc	a3,0x2
ffffffffc020309a:	1fa68693          	addi	a3,a3,506 # ffffffffc0205290 <default_pmm_manager+0x270>
ffffffffc020309e:	00002617          	auipc	a2,0x2
ffffffffc02030a2:	8ca60613          	addi	a2,a2,-1846 # ffffffffc0204968 <commands+0x808>
ffffffffc02030a6:	17700593          	li	a1,375
ffffffffc02030aa:	00002517          	auipc	a0,0x2
ffffffffc02030ae:	fd650513          	addi	a0,a0,-42 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02030b2:	92cfd0ef          	jal	ra,ffffffffc02001de <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02030b6:	86d6                	mv	a3,s5
ffffffffc02030b8:	00002617          	auipc	a2,0x2
ffffffffc02030bc:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204b88 <commands+0xa28>
ffffffffc02030c0:	17300593          	li	a1,371
ffffffffc02030c4:	00002517          	auipc	a0,0x2
ffffffffc02030c8:	fbc50513          	addi	a0,a0,-68 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02030cc:	912fd0ef          	jal	ra,ffffffffc02001de <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02030d0:	00002617          	auipc	a2,0x2
ffffffffc02030d4:	ab860613          	addi	a2,a2,-1352 # ffffffffc0204b88 <commands+0xa28>
ffffffffc02030d8:	17200593          	li	a1,370
ffffffffc02030dc:	00002517          	auipc	a0,0x2
ffffffffc02030e0:	fa450513          	addi	a0,a0,-92 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02030e4:	8fafd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02030e8:	00002697          	auipc	a3,0x2
ffffffffc02030ec:	16068693          	addi	a3,a3,352 # ffffffffc0205248 <default_pmm_manager+0x228>
ffffffffc02030f0:	00002617          	auipc	a2,0x2
ffffffffc02030f4:	87860613          	addi	a2,a2,-1928 # ffffffffc0204968 <commands+0x808>
ffffffffc02030f8:	17000593          	li	a1,368
ffffffffc02030fc:	00002517          	auipc	a0,0x2
ffffffffc0203100:	f8450513          	addi	a0,a0,-124 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203104:	8dafd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203108:	00002697          	auipc	a3,0x2
ffffffffc020310c:	12868693          	addi	a3,a3,296 # ffffffffc0205230 <default_pmm_manager+0x210>
ffffffffc0203110:	00002617          	auipc	a2,0x2
ffffffffc0203114:	85860613          	addi	a2,a2,-1960 # ffffffffc0204968 <commands+0x808>
ffffffffc0203118:	16f00593          	li	a1,367
ffffffffc020311c:	00002517          	auipc	a0,0x2
ffffffffc0203120:	f6450513          	addi	a0,a0,-156 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203124:	8bafd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203128:	00002697          	auipc	a3,0x2
ffffffffc020312c:	4b868693          	addi	a3,a3,1208 # ffffffffc02055e0 <default_pmm_manager+0x5c0>
ffffffffc0203130:	00002617          	auipc	a2,0x2
ffffffffc0203134:	83860613          	addi	a2,a2,-1992 # ffffffffc0204968 <commands+0x808>
ffffffffc0203138:	1b600593          	li	a1,438
ffffffffc020313c:	00002517          	auipc	a0,0x2
ffffffffc0203140:	f4450513          	addi	a0,a0,-188 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203144:	89afd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203148:	00002697          	auipc	a3,0x2
ffffffffc020314c:	46068693          	addi	a3,a3,1120 # ffffffffc02055a8 <default_pmm_manager+0x588>
ffffffffc0203150:	00002617          	auipc	a2,0x2
ffffffffc0203154:	81860613          	addi	a2,a2,-2024 # ffffffffc0204968 <commands+0x808>
ffffffffc0203158:	1b300593          	li	a1,435
ffffffffc020315c:	00002517          	auipc	a0,0x2
ffffffffc0203160:	f2450513          	addi	a0,a0,-220 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203164:	87afd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203168:	00002697          	auipc	a3,0x2
ffffffffc020316c:	41068693          	addi	a3,a3,1040 # ffffffffc0205578 <default_pmm_manager+0x558>
ffffffffc0203170:	00001617          	auipc	a2,0x1
ffffffffc0203174:	7f860613          	addi	a2,a2,2040 # ffffffffc0204968 <commands+0x808>
ffffffffc0203178:	1af00593          	li	a1,431
ffffffffc020317c:	00002517          	auipc	a0,0x2
ffffffffc0203180:	f0450513          	addi	a0,a0,-252 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203184:	85afd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203188:	00002697          	auipc	a3,0x2
ffffffffc020318c:	3a868693          	addi	a3,a3,936 # ffffffffc0205530 <default_pmm_manager+0x510>
ffffffffc0203190:	00001617          	auipc	a2,0x1
ffffffffc0203194:	7d860613          	addi	a2,a2,2008 # ffffffffc0204968 <commands+0x808>
ffffffffc0203198:	1ae00593          	li	a1,430
ffffffffc020319c:	00002517          	auipc	a0,0x2
ffffffffc02031a0:	ee450513          	addi	a0,a0,-284 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02031a4:	83afd0ef          	jal	ra,ffffffffc02001de <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02031a8:	00002617          	auipc	a2,0x2
ffffffffc02031ac:	a8860613          	addi	a2,a2,-1400 # ffffffffc0204c30 <commands+0xad0>
ffffffffc02031b0:	0cb00593          	li	a1,203
ffffffffc02031b4:	00002517          	auipc	a0,0x2
ffffffffc02031b8:	ecc50513          	addi	a0,a0,-308 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02031bc:	822fd0ef          	jal	ra,ffffffffc02001de <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02031c0:	00002617          	auipc	a2,0x2
ffffffffc02031c4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204c30 <commands+0xad0>
ffffffffc02031c8:	08000593          	li	a1,128
ffffffffc02031cc:	00002517          	auipc	a0,0x2
ffffffffc02031d0:	eb450513          	addi	a0,a0,-332 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02031d4:	80afd0ef          	jal	ra,ffffffffc02001de <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02031d8:	00002697          	auipc	a3,0x2
ffffffffc02031dc:	02868693          	addi	a3,a3,40 # ffffffffc0205200 <default_pmm_manager+0x1e0>
ffffffffc02031e0:	00001617          	auipc	a2,0x1
ffffffffc02031e4:	78860613          	addi	a2,a2,1928 # ffffffffc0204968 <commands+0x808>
ffffffffc02031e8:	16e00593          	li	a1,366
ffffffffc02031ec:	00002517          	auipc	a0,0x2
ffffffffc02031f0:	e9450513          	addi	a0,a0,-364 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc02031f4:	febfc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02031f8:	00002697          	auipc	a3,0x2
ffffffffc02031fc:	fd868693          	addi	a3,a3,-40 # ffffffffc02051d0 <default_pmm_manager+0x1b0>
ffffffffc0203200:	00001617          	auipc	a2,0x1
ffffffffc0203204:	76860613          	addi	a2,a2,1896 # ffffffffc0204968 <commands+0x808>
ffffffffc0203208:	16b00593          	li	a1,363
ffffffffc020320c:	00002517          	auipc	a0,0x2
ffffffffc0203210:	e7450513          	addi	a0,a0,-396 # ffffffffc0205080 <default_pmm_manager+0x60>
ffffffffc0203214:	fcbfc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203218 <kernel_thread_entry>:
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)

	# ========== 设置函数参数 ==========
	# 将s1寄存器中的参数移动到a0（第一个参数寄存器）
	move a0, s1
ffffffffc0203218:	8526                	mv	a0,s1

	# ========== 调用线程函数 ==========
	# 跳转到s0寄存器中保存的函数地址
	# jalr指令会将返回地址保存到ra寄存器
	jalr s0
ffffffffc020321a:	9402                	jalr	s0

	# ========== 线程函数返回，终止线程 ==========
	# 线程函数执行完毕，调用do_exit终止当前线程
	# 传递退出码0表示正常退出
	jal do_exit
ffffffffc020321c:	476000ef          	jal	ra,ffffffffc0203692 <do_exit>

ffffffffc0203220 <switch_to>:
switch_to:
    # ========== 保存当前进程(from)的上下文 ==========
    # 将当前CPU中的寄存器值保存到from->context结构体中

    # 保存返回地址寄存器 (context.ra)
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203220:	00153023          	sd	ra,0(a0)

    # 保存栈指针寄存器 (context.sp)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203224:	00253423          	sd	sp,8(a0)

    # 保存保存寄存器s0-s11 (context.s0 ~ context.s11)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203228:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020322a:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc020322c:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203230:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203234:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203238:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc020323c:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203240:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203244:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203248:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc020324c:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203250:	07b53423          	sd	s11,104(a0)

    # ========== 恢复目标进程(to)的上下文 ==========
    # 从to->context结构体中恢复寄存器值到CPU

    # 恢复返回地址寄存器
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203254:	0005b083          	ld	ra,0(a1)

    # 恢复栈指针寄存器
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203258:	0085b103          	ld	sp,8(a1)

    # 恢复保存寄存器s0-s11
    LOAD s0, 2*REGBYTES(a1)
ffffffffc020325c:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020325e:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203260:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203264:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203268:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc020326c:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203270:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203274:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203278:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc020327c:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203280:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203284:	0685bd83          	ld	s11,104(a1)

    # ========== 返回到目标进程 ==========
    # ret指令相当于"jalr x0, ra, 0"，跳转到ra指向的地址
    # 对于目标进程，ra指向了切换发生前的执行点
    ret
ffffffffc0203288:	8082                	ret

ffffffffc020328a <alloc_proc>:
 * - list_link: 进程链表节点，初始化为空链表
 * - hash_link: 哈希链表节点，初始化为空链表
 * ===================================================================== */
static struct proc_struct *
alloc_proc(void)
{
ffffffffc020328a:	1141                	addi	sp,sp,-16
    // 从内核堆中分配进程结构体内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020328c:	0e800513          	li	a0,232
{
ffffffffc0203290:	e022                	sd	s0,0(sp)
ffffffffc0203292:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203294:	9f2fe0ef          	jal	ra,ffffffffc0201486 <kmalloc>
ffffffffc0203298:	842a                	mv	s0,a0

    if (proc != NULL)
ffffffffc020329a:	cd21                	beqz	a0,ffffffffc02032f2 <alloc_proc+0x68>
    {
        // LAB4:EXERCISE1 - 进程结构体字段初始化
        // 以下字段需要按照规范进行初始化：

        // ========== 进程状态和标识 ==========
        proc->state = PROC_UNINIT;          // 进程状态：未初始化
ffffffffc020329c:	57fd                	li	a5,-1
ffffffffc020329e:	1782                	slli	a5,a5,0x20
ffffffffc02032a0:	e11c                	sd	a5,0(a0)
        proc->pid = -1;                     // 进程ID：无效值，待分配
        proc->runs = 0;                     // 运行次数计数器：初始为0

        // ========== 内存管理相关 ==========
        proc->kstack = 0;                   // 内核栈地址：待分配
        proc->pgdir = boot_pgdir_pa;        // 页目录：使用引导时的页目录
ffffffffc02032a2:	0000a797          	auipc	a5,0xa
ffffffffc02032a6:	1f67b783          	ld	a5,502(a5) # ffffffffc020d498 <boot_pgdir_pa>
ffffffffc02032aa:	ed1c                	sd	a5,24(a0)
        // ========== 进程关系 ==========
        proc->parent = NULL;                // 父进程：无
        proc->mm = NULL;                    // 内存管理结构体：lab4中未使用

        // ========== 执行上下文 ==========
        memset(&(proc->context), 0, sizeof(struct context)); // 上下文清零
ffffffffc02032ac:	07000613          	li	a2,112
ffffffffc02032b0:	4581                	li	a1,0
        proc->runs = 0;                     // 运行次数计数器：初始为0
ffffffffc02032b2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                   // 内核栈地址：待分配
ffffffffc02032b6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;             // 重新调度标志：不需要
ffffffffc02032ba:	02052023          	sw	zero,32(a0)
        proc->parent = NULL;                // 父进程：无
ffffffffc02032be:	02053423          	sd	zero,40(a0)
        proc->mm = NULL;                    // 内存管理结构体：lab4中未使用
ffffffffc02032c2:	02053823          	sd	zero,48(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 上下文清零
ffffffffc02032c6:	03850513          	addi	a0,a0,56
ffffffffc02032ca:	7b8000ef          	jal	ra,ffffffffc0203a82 <memset>
        proc->tf = NULL;                    // trapframe：无

        // ========== 标志和属性 ==========
        proc->flags = 0;                    // 进程标志：无特殊标志
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空
ffffffffc02032ce:	4641                	li	a2,16
        proc->tf = NULL;                    // trapframe：无
ffffffffc02032d0:	0a043423          	sd	zero,168(s0)
        proc->flags = 0;                    // 进程标志：无特殊标志
ffffffffc02032d4:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, sizeof(proc->name)); // 进程名称：清空
ffffffffc02032d8:	4581                	li	a1,0
ffffffffc02032da:	0b440513          	addi	a0,s0,180
ffffffffc02032de:	7a4000ef          	jal	ra,ffffffffc0203a82 <memset>

        // ========== 链表节点初始化 ==========
        list_init(&(proc->list_link));      // 进程链表节点初始化
ffffffffc02032e2:	0c840713          	addi	a4,s0,200
        list_init(&(proc->hash_link));      // 哈希链表节点初始化
ffffffffc02032e6:	0d840793          	addi	a5,s0,216
    elm->prev = elm->next = elm;
ffffffffc02032ea:	e878                	sd	a4,208(s0)
ffffffffc02032ec:	e478                	sd	a4,200(s0)
ffffffffc02032ee:	f07c                	sd	a5,224(s0)
ffffffffc02032f0:	ec7c                	sd	a5,216(s0)
    }

    return proc;
}
ffffffffc02032f2:	60a2                	ld	ra,8(sp)
ffffffffc02032f4:	8522                	mv	a0,s0
ffffffffc02032f6:	6402                	ld	s0,0(sp)
ffffffffc02032f8:	0141                	addi	sp,sp,16
ffffffffc02032fa:	8082                	ret

ffffffffc02032fc <forkret>:
static void
forkret(void)
{
    // 调用forkrets恢复trapframe并返回
    // current->tf是在copy_thread中设置的trapframe
    forkrets(current->tf);
ffffffffc02032fc:	0000a797          	auipc	a5,0xa
ffffffffc0203300:	1cc7b783          	ld	a5,460(a5) # ffffffffc020d4c8 <current>
ffffffffc0203304:	77c8                	ld	a0,168(a5)
ffffffffc0203306:	ae3fd06f          	j	ffffffffc0200de8 <forkrets>

ffffffffc020330a <init_main>:
 * 该线程用于系统初始化后的工作，演示内核线程的基本功能。
 * 打印进程信息和传入的参数，然后退出。
 * ===================================================================== */
static int
init_main(void *arg)
{
ffffffffc020330a:	7179                	addi	sp,sp,-48
ffffffffc020330c:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc020330e:	0000a497          	auipc	s1,0xa
ffffffffc0203312:	13a48493          	addi	s1,s1,314 # ffffffffc020d448 <name.2>
{
ffffffffc0203316:	f022                	sd	s0,32(sp)
ffffffffc0203318:	e84a                	sd	s2,16(sp)
ffffffffc020331a:	842a                	mv	s0,a0
    // 打印当前进程（initproc）的信息
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
            current->pid, get_proc_name(current));
ffffffffc020331c:	0000a917          	auipc	s2,0xa
ffffffffc0203320:	1ac93903          	ld	s2,428(s2) # ffffffffc020d4c8 <current>
    memset(name, 0, sizeof(name));
ffffffffc0203324:	4641                	li	a2,16
ffffffffc0203326:	4581                	li	a1,0
ffffffffc0203328:	8526                	mv	a0,s1
{
ffffffffc020332a:	f406                	sd	ra,40(sp)
ffffffffc020332c:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
ffffffffc020332e:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc0203332:	750000ef          	jal	ra,ffffffffc0203a82 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0203336:	0b490593          	addi	a1,s2,180
ffffffffc020333a:	463d                	li	a2,15
ffffffffc020333c:	8526                	mv	a0,s1
ffffffffc020333e:	756000ef          	jal	ra,ffffffffc0203a94 <memcpy>
ffffffffc0203342:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n",
ffffffffc0203344:	85ce                	mv	a1,s3
ffffffffc0203346:	00002517          	auipc	a0,0x2
ffffffffc020334a:	2e250513          	addi	a0,a0,738 # ffffffffc0205628 <default_pmm_manager+0x608>
ffffffffc020334e:	d93fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>

    // 打印传入的参数
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc0203352:	85a2                	mv	a1,s0
ffffffffc0203354:	00002517          	auipc	a0,0x2
ffffffffc0203358:	2fc50513          	addi	a0,a0,764 # ffffffffc0205650 <default_pmm_manager+0x630>
ffffffffc020335c:	d85fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0203360:	00002517          	auipc	a0,0x2
ffffffffc0203364:	30050513          	addi	a0,a0,768 # ffffffffc0205660 <default_pmm_manager+0x640>
ffffffffc0203368:	d79fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>

    return 0;  // 线程正常退出
}
ffffffffc020336c:	70a2                	ld	ra,40(sp)
ffffffffc020336e:	7402                	ld	s0,32(sp)
ffffffffc0203370:	64e2                	ld	s1,24(sp)
ffffffffc0203372:	6942                	ld	s2,16(sp)
ffffffffc0203374:	69a2                	ld	s3,8(sp)
ffffffffc0203376:	4501                	li	a0,0
ffffffffc0203378:	6145                	addi	sp,sp,48
ffffffffc020337a:	8082                	ret

ffffffffc020337c <proc_run>:
{
ffffffffc020337c:	7179                	addi	sp,sp,-48
ffffffffc020337e:	f026                	sd	s1,32(sp)
    if (proc != current)
ffffffffc0203380:	0000a497          	auipc	s1,0xa
ffffffffc0203384:	14848493          	addi	s1,s1,328 # ffffffffc020d4c8 <current>
ffffffffc0203388:	6098                	ld	a4,0(s1)
{
ffffffffc020338a:	f406                	sd	ra,40(sp)
ffffffffc020338c:	ec4a                	sd	s2,24(sp)
    if (proc != current)
ffffffffc020338e:	02a70863          	beq	a4,a0,ffffffffc02033be <proc_run+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203392:	100027f3          	csrr	a5,sstatus
ffffffffc0203396:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203398:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020339a:	ef8d                	bnez	a5,ffffffffc02033d4 <proc_run+0x58>
        lsatp(proc->pgdir);
ffffffffc020339c:	6d1c                	ld	a5,24(a0)
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned int pgdir)
{
  write_csr(satp, SATP32_MODE | (pgdir >> RISCV_PGSHIFT));
ffffffffc020339e:	800006b7          	lui	a3,0x80000
        current = proc;           // 更新当前进程指针
ffffffffc02033a2:	e088                	sd	a0,0(s1)
ffffffffc02033a4:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02033a8:	8fd5                	or	a5,a5,a3
ffffffffc02033aa:	18079073          	csrw	satp,a5
        switch_to(&(prev->context), &(proc->context));
ffffffffc02033ae:	03850593          	addi	a1,a0,56
ffffffffc02033b2:	03870513          	addi	a0,a4,56 # 1038 <kern_entry-0xffffffffc01fefc8>
ffffffffc02033b6:	e6bff0ef          	jal	ra,ffffffffc0203220 <switch_to>
    if (flag) {
ffffffffc02033ba:	00091763          	bnez	s2,ffffffffc02033c8 <proc_run+0x4c>
}
ffffffffc02033be:	70a2                	ld	ra,40(sp)
ffffffffc02033c0:	7482                	ld	s1,32(sp)
ffffffffc02033c2:	6962                	ld	s2,24(sp)
ffffffffc02033c4:	6145                	addi	sp,sp,48
ffffffffc02033c6:	8082                	ret
ffffffffc02033c8:	70a2                	ld	ra,40(sp)
ffffffffc02033ca:	7482                	ld	s1,32(sp)
ffffffffc02033cc:	6962                	ld	s2,24(sp)
ffffffffc02033ce:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc02033d0:	d60fd06f          	j	ffffffffc0200930 <intr_enable>
ffffffffc02033d4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02033d6:	d60fd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        prev = current;           // 保存当前进程
ffffffffc02033da:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc02033dc:	6522                	ld	a0,8(sp)
ffffffffc02033de:	4905                	li	s2,1
ffffffffc02033e0:	bf75                	j	ffffffffc020339c <proc_run+0x20>

ffffffffc02033e2 <do_fork>:
{
ffffffffc02033e2:	7179                	addi	sp,sp,-48
ffffffffc02033e4:	ec26                	sd	s1,24(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02033e6:	0000a497          	auipc	s1,0xa
ffffffffc02033ea:	0fa48493          	addi	s1,s1,250 # ffffffffc020d4e0 <nr_process>
ffffffffc02033ee:	4098                	lw	a4,0(s1)
{
ffffffffc02033f0:	f406                	sd	ra,40(sp)
ffffffffc02033f2:	f022                	sd	s0,32(sp)
ffffffffc02033f4:	e84a                	sd	s2,16(sp)
ffffffffc02033f6:	e44e                	sd	s3,8(sp)
ffffffffc02033f8:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc02033fa:	6785                	lui	a5,0x1
ffffffffc02033fc:	1ef75b63          	bge	a4,a5,ffffffffc02035f2 <do_fork+0x210>
ffffffffc0203400:	892e                	mv	s2,a1
ffffffffc0203402:	89b2                	mv	s3,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0203404:	e87ff0ef          	jal	ra,ffffffffc020328a <alloc_proc>
ffffffffc0203408:	842a                	mv	s0,a0
ffffffffc020340a:	1e050b63          	beqz	a0,ffffffffc0203600 <do_fork+0x21e>
    proc->parent = current;  // 设置父进程指针
ffffffffc020340e:	0000aa17          	auipc	s4,0xa
ffffffffc0203412:	0baa0a13          	addi	s4,s4,186 # ffffffffc020d4c8 <current>
ffffffffc0203416:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020341a:	4509                	li	a0,2
    proc->parent = current;  // 设置父进程指针
ffffffffc020341c:	f41c                	sd	a5,40(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020341e:	cf5fe0ef          	jal	ra,ffffffffc0202112 <alloc_pages>
    if (page != NULL)
ffffffffc0203422:	12050763          	beqz	a0,ffffffffc0203550 <do_fork+0x16e>
    return page - pages + nbase;
ffffffffc0203426:	0000a697          	auipc	a3,0xa
ffffffffc020342a:	08a6b683          	ld	a3,138(a3) # ffffffffc020d4b0 <pages>
ffffffffc020342e:	40d506b3          	sub	a3,a0,a3
ffffffffc0203432:	8699                	srai	a3,a3,0x6
ffffffffc0203434:	00002517          	auipc	a0,0x2
ffffffffc0203438:	5ec53503          	ld	a0,1516(a0) # ffffffffc0205a20 <nbase>
ffffffffc020343c:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc020343e:	00c69793          	slli	a5,a3,0xc
ffffffffc0203442:	83b1                	srli	a5,a5,0xc
ffffffffc0203444:	0000a717          	auipc	a4,0xa
ffffffffc0203448:	06473703          	ld	a4,100(a4) # ffffffffc020d4a8 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc020344c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020344e:	1ae7fe63          	bgeu	a5,a4,ffffffffc020360a <do_fork+0x228>
    assert(current->mm == NULL);
ffffffffc0203452:	000a3783          	ld	a5,0(s4)
ffffffffc0203456:	0000a717          	auipc	a4,0xa
ffffffffc020345a:	06a73703          	ld	a4,106(a4) # ffffffffc020d4c0 <va_pa_offset>
ffffffffc020345e:	96ba                	add	a3,a3,a4
ffffffffc0203460:	7b9c                	ld	a5,48(a5)
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203462:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc0203464:	1a079f63          	bnez	a5,ffffffffc0203622 <do_fork+0x240>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203468:	6789                	lui	a5,0x2
ffffffffc020346a:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc020346e:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0203470:	864e                	mv	a2,s3
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203472:	f454                	sd	a3,168(s0)
    *(proc->tf) = *tf;
ffffffffc0203474:	87b6                	mv	a5,a3
ffffffffc0203476:	12098893          	addi	a7,s3,288
ffffffffc020347a:	00063803          	ld	a6,0(a2)
ffffffffc020347e:	6608                	ld	a0,8(a2)
ffffffffc0203480:	6a0c                	ld	a1,16(a2)
ffffffffc0203482:	6e18                	ld	a4,24(a2)
ffffffffc0203484:	0107b023          	sd	a6,0(a5)
ffffffffc0203488:	e788                	sd	a0,8(a5)
ffffffffc020348a:	eb8c                	sd	a1,16(a5)
ffffffffc020348c:	ef98                	sd	a4,24(a5)
ffffffffc020348e:	02060613          	addi	a2,a2,32
ffffffffc0203492:	02078793          	addi	a5,a5,32
ffffffffc0203496:	ff1612e3          	bne	a2,a7,ffffffffc020347a <do_fork+0x98>
    proc->tf->gpr.a0 = 0;
ffffffffc020349a:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020349e:	12090c63          	beqz	s2,ffffffffc02035d6 <do_fork+0x1f4>
ffffffffc02034a2:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02034a6:	00000797          	auipc	a5,0x0
ffffffffc02034aa:	e5678793          	addi	a5,a5,-426 # ffffffffc02032fc <forkret>
ffffffffc02034ae:	fc1c                	sd	a5,56(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02034b0:	e034                	sd	a3,64(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034b2:	100027f3          	csrr	a5,sstatus
ffffffffc02034b6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02034b8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034ba:	12079863          	bnez	a5,ffffffffc02035ea <do_fork+0x208>
    if (++last_pid >= MAX_PID)
ffffffffc02034be:	00006817          	auipc	a6,0x6
ffffffffc02034c2:	b6a80813          	addi	a6,a6,-1174 # ffffffffc0209028 <last_pid.1>
ffffffffc02034c6:	00082783          	lw	a5,0(a6)
ffffffffc02034ca:	6709                	lui	a4,0x2
ffffffffc02034cc:	0017851b          	addiw	a0,a5,1
ffffffffc02034d0:	00a82023          	sw	a0,0(a6)
ffffffffc02034d4:	08e55a63          	bge	a0,a4,ffffffffc0203568 <do_fork+0x186>
    if (last_pid >= next_safe)
ffffffffc02034d8:	00006317          	auipc	t1,0x6
ffffffffc02034dc:	b5430313          	addi	t1,t1,-1196 # ffffffffc020902c <next_safe.0>
ffffffffc02034e0:	00032783          	lw	a5,0(t1)
ffffffffc02034e4:	0000a917          	auipc	s2,0xa
ffffffffc02034e8:	f7490913          	addi	s2,s2,-140 # ffffffffc020d458 <proc_list>
ffffffffc02034ec:	08f55663          	bge	a0,a5,ffffffffc0203578 <do_fork+0x196>
        proc->pid = get_pid();
ffffffffc02034f0:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02034f2:	45a9                	li	a1,10
ffffffffc02034f4:	2501                	sext.w	a0,a0
ffffffffc02034f6:	1c9000ef          	jal	ra,ffffffffc0203ebe <hash32>
ffffffffc02034fa:	02051793          	slli	a5,a0,0x20
ffffffffc02034fe:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0203502:	00006797          	auipc	a5,0x6
ffffffffc0203506:	f4678793          	addi	a5,a5,-186 # ffffffffc0209448 <hash_list>
ffffffffc020350a:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020350c:	6510                	ld	a2,8(a0)
ffffffffc020350e:	0d840793          	addi	a5,s0,216
ffffffffc0203512:	00893683          	ld	a3,8(s2)
        nr_process++;
ffffffffc0203516:	4098                	lw	a4,0(s1)
    prev->next = next->prev = elm;
ffffffffc0203518:	e21c                	sd	a5,0(a2)
ffffffffc020351a:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc020351c:	f070                	sd	a2,224(s0)
        list_add(&proc_list, &(proc->list_link));
ffffffffc020351e:	0c840793          	addi	a5,s0,200
    elm->prev = prev;
ffffffffc0203522:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0203524:	e29c                	sd	a5,0(a3)
        nr_process++;
ffffffffc0203526:	2705                	addiw	a4,a4,1
ffffffffc0203528:	00f93423          	sd	a5,8(s2)
    elm->next = next;
ffffffffc020352c:	e874                	sd	a3,208(s0)
    elm->prev = prev;
ffffffffc020352e:	0d243423          	sd	s2,200(s0)
ffffffffc0203532:	c098                	sw	a4,0(s1)
    if (flag) {
ffffffffc0203534:	0a099363          	bnez	s3,ffffffffc02035da <do_fork+0x1f8>
    wakeup_proc(proc);
ffffffffc0203538:	8522                	mv	a0,s0
ffffffffc020353a:	3de000ef          	jal	ra,ffffffffc0203918 <wakeup_proc>
    ret = proc->pid;
ffffffffc020353e:	4048                	lw	a0,4(s0)
}
ffffffffc0203540:	70a2                	ld	ra,40(sp)
ffffffffc0203542:	7402                	ld	s0,32(sp)
ffffffffc0203544:	64e2                	ld	s1,24(sp)
ffffffffc0203546:	6942                	ld	s2,16(sp)
ffffffffc0203548:	69a2                	ld	s3,8(sp)
ffffffffc020354a:	6a02                	ld	s4,0(sp)
ffffffffc020354c:	6145                	addi	sp,sp,48
ffffffffc020354e:	8082                	ret
    kfree(proc);       // 释放进程结构体
ffffffffc0203550:	8522                	mv	a0,s0
ffffffffc0203552:	fe5fd0ef          	jal	ra,ffffffffc0201536 <kfree>
    return -E_NO_MEM;  // 内存分配失败
ffffffffc0203556:	5571                	li	a0,-4
}
ffffffffc0203558:	70a2                	ld	ra,40(sp)
ffffffffc020355a:	7402                	ld	s0,32(sp)
ffffffffc020355c:	64e2                	ld	s1,24(sp)
ffffffffc020355e:	6942                	ld	s2,16(sp)
ffffffffc0203560:	69a2                	ld	s3,8(sp)
ffffffffc0203562:	6a02                	ld	s4,0(sp)
ffffffffc0203564:	6145                	addi	sp,sp,48
ffffffffc0203566:	8082                	ret
        last_pid = 1;
ffffffffc0203568:	4785                	li	a5,1
ffffffffc020356a:	00f82023          	sw	a5,0(a6)
        goto inside;  // 跳转到内部检查逻辑
ffffffffc020356e:	4505                	li	a0,1
ffffffffc0203570:	00006317          	auipc	t1,0x6
ffffffffc0203574:	abc30313          	addi	t1,t1,-1348 # ffffffffc020902c <next_safe.0>
    return listelm->next;
ffffffffc0203578:	0000a917          	auipc	s2,0xa
ffffffffc020357c:	ee090913          	addi	s2,s2,-288 # ffffffffc020d458 <proc_list>
ffffffffc0203580:	00893e03          	ld	t3,8(s2)
        next_safe = MAX_PID;  // 重置安全边界
ffffffffc0203584:	6789                	lui	a5,0x2
ffffffffc0203586:	00f32023          	sw	a5,0(t1)
ffffffffc020358a:	86aa                	mv	a3,a0
ffffffffc020358c:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020358e:	6e89                	lui	t4,0x2
ffffffffc0203590:	072e0363          	beq	t3,s2,ffffffffc02035f6 <do_fork+0x214>
ffffffffc0203594:	88ae                	mv	a7,a1
ffffffffc0203596:	87f2                	mv	a5,t3
ffffffffc0203598:	6609                	lui	a2,0x2
ffffffffc020359a:	a811                	j	ffffffffc02035ae <do_fork+0x1cc>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020359c:	00e6d663          	bge	a3,a4,ffffffffc02035a8 <do_fork+0x1c6>
ffffffffc02035a0:	00c75463          	bge	a4,a2,ffffffffc02035a8 <do_fork+0x1c6>
ffffffffc02035a4:	863a                	mv	a2,a4
ffffffffc02035a6:	4885                	li	a7,1
ffffffffc02035a8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02035aa:	01278d63          	beq	a5,s2,ffffffffc02035c4 <do_fork+0x1e2>
            if (proc->pid == last_pid)
ffffffffc02035ae:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc02035b2:	fed715e3          	bne	a4,a3,ffffffffc020359c <do_fork+0x1ba>
                if (++last_pid >= next_safe)
ffffffffc02035b6:	2685                	addiw	a3,a3,1
ffffffffc02035b8:	02c6d463          	bge	a3,a2,ffffffffc02035e0 <do_fork+0x1fe>
ffffffffc02035bc:	679c                	ld	a5,8(a5)
ffffffffc02035be:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02035c0:	ff2797e3          	bne	a5,s2,ffffffffc02035ae <do_fork+0x1cc>
ffffffffc02035c4:	c581                	beqz	a1,ffffffffc02035cc <do_fork+0x1ea>
ffffffffc02035c6:	00d82023          	sw	a3,0(a6)
ffffffffc02035ca:	8536                	mv	a0,a3
ffffffffc02035cc:	f20882e3          	beqz	a7,ffffffffc02034f0 <do_fork+0x10e>
ffffffffc02035d0:	00c32023          	sw	a2,0(t1)
ffffffffc02035d4:	bf31                	j	ffffffffc02034f0 <do_fork+0x10e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02035d6:	8936                	mv	s2,a3
ffffffffc02035d8:	b5e9                	j	ffffffffc02034a2 <do_fork+0xc0>
        intr_enable();
ffffffffc02035da:	b56fd0ef          	jal	ra,ffffffffc0200930 <intr_enable>
ffffffffc02035de:	bfa9                	j	ffffffffc0203538 <do_fork+0x156>
                    if (last_pid >= MAX_PID)
ffffffffc02035e0:	01d6c363          	blt	a3,t4,ffffffffc02035e6 <do_fork+0x204>
                        last_pid = 1;  // 回绕到1
ffffffffc02035e4:	4685                	li	a3,1
                    goto repeat;  // 重新开始检查
ffffffffc02035e6:	4585                	li	a1,1
ffffffffc02035e8:	b765                	j	ffffffffc0203590 <do_fork+0x1ae>
        intr_disable();
ffffffffc02035ea:	b4cfd0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc02035ee:	4985                	li	s3,1
ffffffffc02035f0:	b5f9                	j	ffffffffc02034be <do_fork+0xdc>
    int ret = -E_NO_FREE_PROC;         // 默认错误：进程数达到上限
ffffffffc02035f2:	556d                	li	a0,-5
ffffffffc02035f4:	b795                	j	ffffffffc0203558 <do_fork+0x176>
ffffffffc02035f6:	c599                	beqz	a1,ffffffffc0203604 <do_fork+0x222>
ffffffffc02035f8:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02035fc:	8536                	mv	a0,a3
ffffffffc02035fe:	bdcd                	j	ffffffffc02034f0 <do_fork+0x10e>
    ret = -E_NO_MEM;  // 默认错误：内存不足
ffffffffc0203600:	5571                	li	a0,-4
    return ret;
ffffffffc0203602:	bf99                	j	ffffffffc0203558 <do_fork+0x176>
    return last_pid;
ffffffffc0203604:	00082503          	lw	a0,0(a6)
ffffffffc0203608:	b5e5                	j	ffffffffc02034f0 <do_fork+0x10e>
ffffffffc020360a:	00001617          	auipc	a2,0x1
ffffffffc020360e:	57e60613          	addi	a2,a2,1406 # ffffffffc0204b88 <commands+0xa28>
ffffffffc0203612:	07100593          	li	a1,113
ffffffffc0203616:	00001517          	auipc	a0,0x1
ffffffffc020361a:	59a50513          	addi	a0,a0,1434 # ffffffffc0204bb0 <commands+0xa50>
ffffffffc020361e:	bc1fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(current->mm == NULL);
ffffffffc0203622:	00002697          	auipc	a3,0x2
ffffffffc0203626:	05e68693          	addi	a3,a3,94 # ffffffffc0205680 <default_pmm_manager+0x660>
ffffffffc020362a:	00001617          	auipc	a2,0x1
ffffffffc020362e:	33e60613          	addi	a2,a2,830 # ffffffffc0204968 <commands+0x808>
ffffffffc0203632:	25600593          	li	a1,598
ffffffffc0203636:	00002517          	auipc	a0,0x2
ffffffffc020363a:	06250513          	addi	a0,a0,98 # ffffffffc0205698 <default_pmm_manager+0x678>
ffffffffc020363e:	ba1fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc0203642 <kernel_thread>:
{
ffffffffc0203642:	7129                	addi	sp,sp,-320
ffffffffc0203644:	fa22                	sd	s0,304(sp)
ffffffffc0203646:	f626                	sd	s1,296(sp)
ffffffffc0203648:	f24a                	sd	s2,288(sp)
ffffffffc020364a:	84ae                	mv	s1,a1
ffffffffc020364c:	892a                	mv	s2,a0
ffffffffc020364e:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0203650:	4581                	li	a1,0
ffffffffc0203652:	12000613          	li	a2,288
ffffffffc0203656:	850a                	mv	a0,sp
{
ffffffffc0203658:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020365a:	428000ef          	jal	ra,ffffffffc0203a82 <memset>
    tf.gpr.s0 = (uintptr_t)fn;        // s0 = 线程函数地址
ffffffffc020365e:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;       // s1 = 函数参数
ffffffffc0203660:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0203662:	100027f3          	csrr	a5,sstatus
ffffffffc0203666:	edd7f793          	andi	a5,a5,-291
ffffffffc020366a:	1207e793          	ori	a5,a5,288
ffffffffc020366e:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203670:	860a                	mv	a2,sp
ffffffffc0203672:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203676:	00000797          	auipc	a5,0x0
ffffffffc020367a:	ba278793          	addi	a5,a5,-1118 # ffffffffc0203218 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020367e:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203680:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0203682:	d61ff0ef          	jal	ra,ffffffffc02033e2 <do_fork>
}
ffffffffc0203686:	70f2                	ld	ra,312(sp)
ffffffffc0203688:	7452                	ld	s0,304(sp)
ffffffffc020368a:	74b2                	ld	s1,296(sp)
ffffffffc020368c:	7912                	ld	s2,288(sp)
ffffffffc020368e:	6131                	addi	sp,sp,320
ffffffffc0203690:	8082                	ret

ffffffffc0203692 <do_exit>:
{
ffffffffc0203692:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc0203694:	00002617          	auipc	a2,0x2
ffffffffc0203698:	01c60613          	addi	a2,a2,28 # ffffffffc02056b0 <default_pmm_manager+0x690>
ffffffffc020369c:	30a00593          	li	a1,778
ffffffffc02036a0:	00002517          	auipc	a0,0x2
ffffffffc02036a4:	ff850513          	addi	a0,a0,-8 # ffffffffc0205698 <default_pmm_manager+0x678>
{
ffffffffc02036a8:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02036aa:	b35fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02036ae <proc_init>:
 * - PID为0，是系统中第一个进程
 * - 使用预先分配的bootstack作为内核栈
 * - 始终处于可运行状态
 * ===================================================================== */
void proc_init(void)
{
ffffffffc02036ae:	7179                	addi	sp,sp,-48
ffffffffc02036b0:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc02036b2:	0000a797          	auipc	a5,0xa
ffffffffc02036b6:	da678793          	addi	a5,a5,-602 # ffffffffc020d458 <proc_list>
ffffffffc02036ba:	f406                	sd	ra,40(sp)
ffffffffc02036bc:	f022                	sd	s0,32(sp)
ffffffffc02036be:	e84a                	sd	s2,16(sp)
ffffffffc02036c0:	e44e                	sd	s3,8(sp)
ffffffffc02036c2:	00006497          	auipc	s1,0x6
ffffffffc02036c6:	d8648493          	addi	s1,s1,-634 # ffffffffc0209448 <hash_list>
ffffffffc02036ca:	e79c                	sd	a5,8(a5)
ffffffffc02036cc:	e39c                	sd	a5,0(a5)
    // ========== 1. 初始化进程管理数据结构 ==========
    // 初始化进程链表（双向循环链表）
    list_init(&proc_list);

    // 初始化PID哈希表的所有桶
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc02036ce:	0000a717          	auipc	a4,0xa
ffffffffc02036d2:	d7a70713          	addi	a4,a4,-646 # ffffffffc020d448 <name.2>
ffffffffc02036d6:	87a6                	mv	a5,s1
ffffffffc02036d8:	e79c                	sd	a5,8(a5)
ffffffffc02036da:	e39c                	sd	a5,0(a5)
ffffffffc02036dc:	07c1                	addi	a5,a5,16
ffffffffc02036de:	fef71de3          	bne	a4,a5,ffffffffc02036d8 <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    // ========== 2. 创建idle进程 ==========
    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02036e2:	ba9ff0ef          	jal	ra,ffffffffc020328a <alloc_proc>
ffffffffc02036e6:	0000a917          	auipc	s2,0xa
ffffffffc02036ea:	dea90913          	addi	s2,s2,-534 # ffffffffc020d4d0 <idleproc>
ffffffffc02036ee:	00a93023          	sd	a0,0(s2)
ffffffffc02036f2:	18050d63          	beqz	a0,ffffffffc020388c <proc_init+0x1de>
        panic("cannot alloc idleproc.\n");
    }

    // ========== 3. 验证alloc_proc函数的正确性 ==========
    // 通过内存比较验证idleproc的各个字段是否正确初始化
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc02036f6:	07000513          	li	a0,112
ffffffffc02036fa:	d8dfd0ef          	jal	ra,ffffffffc0201486 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc02036fe:	07000613          	li	a2,112
ffffffffc0203702:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc0203704:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0203706:	37c000ef          	jal	ra,ffffffffc0203a82 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020370a:	00093503          	ld	a0,0(s2)
ffffffffc020370e:	85a2                	mv	a1,s0
ffffffffc0203710:	07000613          	li	a2,112
ffffffffc0203714:	03850513          	addi	a0,a0,56
ffffffffc0203718:	394000ef          	jal	ra,ffffffffc0203aac <memcmp>
ffffffffc020371c:	89aa                	mv	s3,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc020371e:	453d                	li	a0,15
ffffffffc0203720:	d67fd0ef          	jal	ra,ffffffffc0201486 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0203724:	463d                	li	a2,15
ffffffffc0203726:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203728:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020372a:	358000ef          	jal	ra,ffffffffc0203a82 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020372e:	00093503          	ld	a0,0(s2)
ffffffffc0203732:	463d                	li	a2,15
ffffffffc0203734:	85a2                	mv	a1,s0
ffffffffc0203736:	0b450513          	addi	a0,a0,180
ffffffffc020373a:	372000ef          	jal	ra,ffffffffc0203aac <memcmp>

    // 检查idleproc是否正确初始化
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
ffffffffc020373e:	00093783          	ld	a5,0(s2)
ffffffffc0203742:	0000a717          	auipc	a4,0xa
ffffffffc0203746:	d5673703          	ld	a4,-682(a4) # ffffffffc020d498 <boot_pgdir_pa>
ffffffffc020374a:	6f94                	ld	a3,24(a5)
ffffffffc020374c:	0ee68463          	beq	a3,a4,ffffffffc0203834 <proc_init+0x186>
        cprintf("alloc_proc() correct!\n");
    }

    // ========== 4. 设置idle进程属性 ==========
    idleproc->pid = 0;                          // 设置PID为0
    idleproc->state = PROC_RUNNABLE;            // 设置为可运行状态
ffffffffc0203750:	4709                	li	a4,2
ffffffffc0203752:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
ffffffffc0203754:	00003717          	auipc	a4,0x3
ffffffffc0203758:	8ac70713          	addi	a4,a4,-1876 # ffffffffc0206000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020375c:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;    // 使用预分配的bootstack
ffffffffc0203760:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;                 // 需要立即调度
ffffffffc0203762:	4705                	li	a4,1
ffffffffc0203764:	d398                	sw	a4,32(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203766:	4641                	li	a2,16
ffffffffc0203768:	4581                	li	a1,0
ffffffffc020376a:	8522                	mv	a0,s0
ffffffffc020376c:	316000ef          	jal	ra,ffffffffc0203a82 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0203770:	463d                	li	a2,15
ffffffffc0203772:	00002597          	auipc	a1,0x2
ffffffffc0203776:	f8658593          	addi	a1,a1,-122 # ffffffffc02056f8 <default_pmm_manager+0x6d8>
ffffffffc020377a:	8522                	mv	a0,s0
ffffffffc020377c:	318000ef          	jal	ra,ffffffffc0203a94 <memcpy>
    set_proc_name(idleproc, "idle");            // 设置进程名为"idle"
    nr_process++;                               // 进程计数加1
ffffffffc0203780:	0000a717          	auipc	a4,0xa
ffffffffc0203784:	d6070713          	addi	a4,a4,-672 # ffffffffc020d4e0 <nr_process>
ffffffffc0203788:	431c                	lw	a5,0(a4)

    // ========== 5. 设置当前进程为idleproc ==========
    current = idleproc;
ffffffffc020378a:	00093683          	ld	a3,0(s2)

    // ========== 6. 创建init_main线程 ==========
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020378e:	4601                	li	a2,0
    nr_process++;                               // 进程计数加1
ffffffffc0203790:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0203792:	00002597          	auipc	a1,0x2
ffffffffc0203796:	f6e58593          	addi	a1,a1,-146 # ffffffffc0205700 <default_pmm_manager+0x6e0>
ffffffffc020379a:	00000517          	auipc	a0,0x0
ffffffffc020379e:	b7050513          	addi	a0,a0,-1168 # ffffffffc020330a <init_main>
    nr_process++;                               // 进程计数加1
ffffffffc02037a2:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc02037a4:	0000a797          	auipc	a5,0xa
ffffffffc02037a8:	d2d7b223          	sd	a3,-732(a5) # ffffffffc020d4c8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02037ac:	e97ff0ef          	jal	ra,ffffffffc0203642 <kernel_thread>
ffffffffc02037b0:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc02037b2:	0ea05963          	blez	a0,ffffffffc02038a4 <proc_init+0x1f6>
    if (0 < pid && pid < MAX_PID)
ffffffffc02037b6:	6789                	lui	a5,0x2
ffffffffc02037b8:	fff5071b          	addiw	a4,a0,-1
ffffffffc02037bc:	17f9                	addi	a5,a5,-2
ffffffffc02037be:	2501                	sext.w	a0,a0
ffffffffc02037c0:	02e7e363          	bltu	a5,a4,ffffffffc02037e6 <proc_init+0x138>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02037c4:	45a9                	li	a1,10
ffffffffc02037c6:	6f8000ef          	jal	ra,ffffffffc0203ebe <hash32>
ffffffffc02037ca:	02051793          	slli	a5,a0,0x20
ffffffffc02037ce:	01c7d693          	srli	a3,a5,0x1c
ffffffffc02037d2:	96a6                	add	a3,a3,s1
ffffffffc02037d4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc02037d6:	a029                	j	ffffffffc02037e0 <proc_init+0x132>
            if (proc->pid == pid)
ffffffffc02037d8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02037dc:	0a870563          	beq	a4,s0,ffffffffc0203886 <proc_init+0x1d8>
    return listelm->next;
ffffffffc02037e0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02037e2:	fef69be3          	bne	a3,a5,ffffffffc02037d8 <proc_init+0x12a>
    return NULL;
ffffffffc02037e6:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037e8:	0b478493          	addi	s1,a5,180
ffffffffc02037ec:	4641                	li	a2,16
ffffffffc02037ee:	4581                	li	a1,0
    {
        panic("create init_main failed.\n");
    }

    // ========== 7. 获取并命名init进程 ==========
    initproc = find_proc(pid);
ffffffffc02037f0:	0000a417          	auipc	s0,0xa
ffffffffc02037f4:	ce840413          	addi	s0,s0,-792 # ffffffffc020d4d8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037f8:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02037fa:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02037fc:	286000ef          	jal	ra,ffffffffc0203a82 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0203800:	463d                	li	a2,15
ffffffffc0203802:	00002597          	auipc	a1,0x2
ffffffffc0203806:	f2e58593          	addi	a1,a1,-210 # ffffffffc0205730 <default_pmm_manager+0x710>
ffffffffc020380a:	8526                	mv	a0,s1
ffffffffc020380c:	288000ef          	jal	ra,ffffffffc0203a94 <memcpy>
    set_proc_name(initproc, "init");

    // ========== 8. 验证初始化结果 ==========
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203810:	00093783          	ld	a5,0(s2)
ffffffffc0203814:	c7e1                	beqz	a5,ffffffffc02038dc <proc_init+0x22e>
ffffffffc0203816:	43dc                	lw	a5,4(a5)
ffffffffc0203818:	e3f1                	bnez	a5,ffffffffc02038dc <proc_init+0x22e>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020381a:	601c                	ld	a5,0(s0)
ffffffffc020381c:	c3c5                	beqz	a5,ffffffffc02038bc <proc_init+0x20e>
ffffffffc020381e:	43d8                	lw	a4,4(a5)
ffffffffc0203820:	4785                	li	a5,1
ffffffffc0203822:	08f71d63          	bne	a4,a5,ffffffffc02038bc <proc_init+0x20e>
}
ffffffffc0203826:	70a2                	ld	ra,40(sp)
ffffffffc0203828:	7402                	ld	s0,32(sp)
ffffffffc020382a:	64e2                	ld	s1,24(sp)
ffffffffc020382c:	6942                	ld	s2,16(sp)
ffffffffc020382e:	69a2                	ld	s3,8(sp)
ffffffffc0203830:	6145                	addi	sp,sp,48
ffffffffc0203832:	8082                	ret
    if (idleproc->pgdir == boot_pgdir_pa &&     // 页目录正确
ffffffffc0203834:	77d8                	ld	a4,168(a5)
ffffffffc0203836:	ff09                	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->tf == NULL &&                 // trapframe为空
ffffffffc0203838:	f0099ce3          	bnez	s3,ffffffffc0203750 <proc_init+0xa2>
        idleproc->state == PROC_UNINIT &&       // 状态为未初始化
ffffffffc020383c:	6394                	ld	a3,0(a5)
ffffffffc020383e:	577d                	li	a4,-1
ffffffffc0203840:	1702                	slli	a4,a4,0x20
ffffffffc0203842:	f0e697e3          	bne	a3,a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->pid == -1 &&                  // PID为无效值
ffffffffc0203846:	4798                	lw	a4,8(a5)
ffffffffc0203848:	f00714e3          	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->runs == 0 &&                  // 运行次数为0
ffffffffc020384c:	6b98                	ld	a4,16(a5)
ffffffffc020384e:	f00711e3          	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->need_resched == 0 &&          // 不需要调度
ffffffffc0203852:	5398                	lw	a4,32(a5)
ffffffffc0203854:	2701                	sext.w	a4,a4
        idleproc->kstack == 0 &&                // 内核栈未分配
ffffffffc0203856:	ee071de3          	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->need_resched == 0 &&          // 不需要调度
ffffffffc020385a:	7798                	ld	a4,40(a5)
ffffffffc020385c:	ee071ae3          	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->parent == NULL &&             // 无父进程
ffffffffc0203860:	7b98                	ld	a4,48(a5)
ffffffffc0203862:	ee0717e3          	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        idleproc->mm == NULL &&                 // 无内存管理结构体
ffffffffc0203866:	0b07a703          	lw	a4,176(a5)
ffffffffc020386a:	8d59                	or	a0,a0,a4
ffffffffc020386c:	0005071b          	sext.w	a4,a0
ffffffffc0203870:	ee0710e3          	bnez	a4,ffffffffc0203750 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");
ffffffffc0203874:	00002517          	auipc	a0,0x2
ffffffffc0203878:	e6c50513          	addi	a0,a0,-404 # ffffffffc02056e0 <default_pmm_manager+0x6c0>
ffffffffc020387c:	865fc0ef          	jal	ra,ffffffffc02000e0 <cprintf>
    idleproc->pid = 0;                          // 设置PID为0
ffffffffc0203880:	00093783          	ld	a5,0(s2)
ffffffffc0203884:	b5f1                	j	ffffffffc0203750 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0203886:	f2878793          	addi	a5,a5,-216
ffffffffc020388a:	bfb9                	j	ffffffffc02037e8 <proc_init+0x13a>
        panic("cannot alloc idleproc.\n");
ffffffffc020388c:	00002617          	auipc	a2,0x2
ffffffffc0203890:	e3c60613          	addi	a2,a2,-452 # ffffffffc02056c8 <default_pmm_manager+0x6a8>
ffffffffc0203894:	35000593          	li	a1,848
ffffffffc0203898:	00002517          	auipc	a0,0x2
ffffffffc020389c:	e0050513          	addi	a0,a0,-512 # ffffffffc0205698 <default_pmm_manager+0x678>
ffffffffc02038a0:	93ffc0ef          	jal	ra,ffffffffc02001de <__panic>
        panic("create init_main failed.\n");
ffffffffc02038a4:	00002617          	auipc	a2,0x2
ffffffffc02038a8:	e6c60613          	addi	a2,a2,-404 # ffffffffc0205710 <default_pmm_manager+0x6f0>
ffffffffc02038ac:	37d00593          	li	a1,893
ffffffffc02038b0:	00002517          	auipc	a0,0x2
ffffffffc02038b4:	de850513          	addi	a0,a0,-536 # ffffffffc0205698 <default_pmm_manager+0x678>
ffffffffc02038b8:	927fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02038bc:	00002697          	auipc	a3,0x2
ffffffffc02038c0:	ea468693          	addi	a3,a3,-348 # ffffffffc0205760 <default_pmm_manager+0x740>
ffffffffc02038c4:	00001617          	auipc	a2,0x1
ffffffffc02038c8:	0a460613          	addi	a2,a2,164 # ffffffffc0204968 <commands+0x808>
ffffffffc02038cc:	38600593          	li	a1,902
ffffffffc02038d0:	00002517          	auipc	a0,0x2
ffffffffc02038d4:	dc850513          	addi	a0,a0,-568 # ffffffffc0205698 <default_pmm_manager+0x678>
ffffffffc02038d8:	907fc0ef          	jal	ra,ffffffffc02001de <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02038dc:	00002697          	auipc	a3,0x2
ffffffffc02038e0:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205738 <default_pmm_manager+0x718>
ffffffffc02038e4:	00001617          	auipc	a2,0x1
ffffffffc02038e8:	08460613          	addi	a2,a2,132 # ffffffffc0204968 <commands+0x808>
ffffffffc02038ec:	38500593          	li	a1,901
ffffffffc02038f0:	00002517          	auipc	a0,0x2
ffffffffc02038f4:	da850513          	addi	a0,a0,-600 # ffffffffc0205698 <default_pmm_manager+0x678>
ffffffffc02038f8:	8e7fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc02038fc <cpu_idle>:
 * 3. 没有其他就绪进程时，idle进程会保持运行
 *
 * 这确保了系统在没有其他任务时不会"死机"，而是让CPU执行空闲循环。
 * ===================================================================== */
void cpu_idle(void)
{
ffffffffc02038fc:	1141                	addi	sp,sp,-16
ffffffffc02038fe:	e022                	sd	s0,0(sp)
ffffffffc0203900:	e406                	sd	ra,8(sp)
ffffffffc0203902:	0000a417          	auipc	s0,0xa
ffffffffc0203906:	bc640413          	addi	s0,s0,-1082 # ffffffffc020d4c8 <current>
    while (1)  // 无限循环
    {
        // 检查是否需要重新调度
        if (current->need_resched)
ffffffffc020390a:	6018                	ld	a4,0(s0)
ffffffffc020390c:	531c                	lw	a5,32(a4)
ffffffffc020390e:	2781                	sext.w	a5,a5
ffffffffc0203910:	dff5                	beqz	a5,ffffffffc020390c <cpu_idle+0x10>
        {
            // 调用调度器进行进程切换
            schedule();
ffffffffc0203912:	03a000ef          	jal	ra,ffffffffc020394c <schedule>
ffffffffc0203916:	bfd5                	j	ffffffffc020390a <cpu_idle+0xe>

ffffffffc0203918 <wakeup_proc>:
 * - 不能重复唤醒已在可运行状态的进程
 * ===================================================================== */
void
wakeup_proc(struct proc_struct *proc) {
    // 断言：确保进程不在僵尸状态或可运行状态
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203918:	411c                	lw	a5,0(a0)
ffffffffc020391a:	4705                	li	a4,1
ffffffffc020391c:	37f9                	addiw	a5,a5,-2
ffffffffc020391e:	00f77563          	bgeu	a4,a5,ffffffffc0203928 <wakeup_proc+0x10>

    // 设置进程为可运行状态
    proc->state = PROC_RUNNABLE;
ffffffffc0203922:	4789                	li	a5,2
ffffffffc0203924:	c11c                	sw	a5,0(a0)
ffffffffc0203926:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0203928:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020392a:	00002697          	auipc	a3,0x2
ffffffffc020392e:	e5e68693          	addi	a3,a3,-418 # ffffffffc0205788 <default_pmm_manager+0x768>
ffffffffc0203932:	00001617          	auipc	a2,0x1
ffffffffc0203936:	03660613          	addi	a2,a2,54 # ffffffffc0204968 <commands+0x808>
ffffffffc020393a:	02700593          	li	a1,39
ffffffffc020393e:	00002517          	auipc	a0,0x2
ffffffffc0203942:	e8a50513          	addi	a0,a0,-374 # ffffffffc02057c8 <default_pmm_manager+0x7a8>
wakeup_proc(struct proc_struct *proc) {
ffffffffc0203946:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0203948:	897fc0ef          	jal	ra,ffffffffc02001de <__panic>

ffffffffc020394c <schedule>:
 * - 采用轮转方式：每个进程都有平等的机会获得CPU
 * - 优先级相同的进程按链表顺序轮流执行
 * - idle进程作为fallback，确保系统不会没有可执行进程
 * ===================================================================== */
void
schedule(void) {
ffffffffc020394c:	1141                	addi	sp,sp,-16
ffffffffc020394e:	e406                	sd	ra,8(sp)
ffffffffc0203950:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203952:	100027f3          	csrr	a5,sstatus
ffffffffc0203956:	8b89                	andi	a5,a5,2
ffffffffc0203958:	4401                	li	s0,0
ffffffffc020395a:	efbd                	bnez	a5,ffffffffc02039d8 <schedule+0x8c>

    // 关闭中断，保证调度过程的原子性
    local_intr_save(intr_flag);
    {
        // 清除当前进程的重新调度标志
        current->need_resched = 0;
ffffffffc020395c:	0000a897          	auipc	a7,0xa
ffffffffc0203960:	b6c8b883          	ld	a7,-1172(a7) # ffffffffc020d4c8 <current>
ffffffffc0203964:	0208a023          	sw	zero,32(a7)

        // ========== 确定查找起始点 ==========
        // 如果当前是idle进程，从链表头开始查找
        // 否则从当前进程的下一个开始查找（实现轮转调度）
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203968:	0000a517          	auipc	a0,0xa
ffffffffc020396c:	b6853503          	ld	a0,-1176(a0) # ffffffffc020d4d0 <idleproc>
ffffffffc0203970:	04a88e63          	beq	a7,a0,ffffffffc02039cc <schedule+0x80>
ffffffffc0203974:	0c888693          	addi	a3,a7,200
ffffffffc0203978:	0000a617          	auipc	a2,0xa
ffffffffc020397c:	ae060613          	addi	a2,a2,-1312 # ffffffffc020d458 <proc_list>
        le = last;
ffffffffc0203980:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;   // 选中的下一个进程
ffffffffc0203982:	4581                	li	a1,0
            // 获取下一个链表节点
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);

                // 找到第一个可运行状态的进程
                if (next->state == PROC_RUNNABLE) {
ffffffffc0203984:	4809                	li	a6,2
ffffffffc0203986:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0203988:	00c78863          	beq	a5,a2,ffffffffc0203998 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020398c:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0203990:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0203994:	03070163          	beq	a4,a6,ffffffffc02039b6 <schedule+0x6a>
                    break;  // 找到目标，跳出循环
                }
            }
        } while (le != last);  // 遍历完一圈后停止
ffffffffc0203998:	fef697e3          	bne	a3,a5,ffffffffc0203986 <schedule+0x3a>

        // ========== 处理未找到可运行进程的情况 ==========
        // 如果没找到可运行进程或者找到的进程状态不对，选择idle进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020399c:	ed89                	bnez	a1,ffffffffc02039b6 <schedule+0x6a>
            next = idleproc;
        }

        // ========== 更新进程运行统计 ==========
        next->runs ++;  // 增加选中进程的运行次数计数
ffffffffc020399e:	451c                	lw	a5,8(a0)
ffffffffc02039a0:	2785                	addiw	a5,a5,1
ffffffffc02039a2:	c51c                	sw	a5,8(a0)

        // ========== 执行进程切换 ==========
        if (next != current) {
ffffffffc02039a4:	00a88463          	beq	a7,a0,ffffffffc02039ac <schedule+0x60>
            proc_run(next);  // 切换到选中进程
ffffffffc02039a8:	9d5ff0ef          	jal	ra,ffffffffc020337c <proc_run>
    if (flag) {
ffffffffc02039ac:	e819                	bnez	s0,ffffffffc02039c2 <schedule+0x76>
        }
        // 如果选中进程就是当前进程，则继续执行（不需要切换）
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);
}
ffffffffc02039ae:	60a2                	ld	ra,8(sp)
ffffffffc02039b0:	6402                	ld	s0,0(sp)
ffffffffc02039b2:	0141                	addi	sp,sp,16
ffffffffc02039b4:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02039b6:	4198                	lw	a4,0(a1)
ffffffffc02039b8:	4789                	li	a5,2
ffffffffc02039ba:	fef712e3          	bne	a4,a5,ffffffffc020399e <schedule+0x52>
ffffffffc02039be:	852e                	mv	a0,a1
ffffffffc02039c0:	bff9                	j	ffffffffc020399e <schedule+0x52>
}
ffffffffc02039c2:	6402                	ld	s0,0(sp)
ffffffffc02039c4:	60a2                	ld	ra,8(sp)
ffffffffc02039c6:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02039c8:	f69fc06f          	j	ffffffffc0200930 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02039cc:	0000a617          	auipc	a2,0xa
ffffffffc02039d0:	a8c60613          	addi	a2,a2,-1396 # ffffffffc020d458 <proc_list>
ffffffffc02039d4:	86b2                	mv	a3,a2
ffffffffc02039d6:	b76d                	j	ffffffffc0203980 <schedule+0x34>
        intr_disable();
ffffffffc02039d8:	f5ffc0ef          	jal	ra,ffffffffc0200936 <intr_disable>
        return 1;
ffffffffc02039dc:	4405                	li	s0,1
ffffffffc02039de:	bfbd                	j	ffffffffc020395c <schedule+0x10>

ffffffffc02039e0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02039e0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02039e4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02039e6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02039e8:	cb81                	beqz	a5,ffffffffc02039f8 <strlen+0x18>
        cnt ++;
ffffffffc02039ea:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02039ec:	00a707b3          	add	a5,a4,a0
ffffffffc02039f0:	0007c783          	lbu	a5,0(a5)
ffffffffc02039f4:	fbfd                	bnez	a5,ffffffffc02039ea <strlen+0xa>
ffffffffc02039f6:	8082                	ret
    }
    return cnt;
}
ffffffffc02039f8:	8082                	ret

ffffffffc02039fa <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02039fa:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02039fc:	e589                	bnez	a1,ffffffffc0203a06 <strnlen+0xc>
ffffffffc02039fe:	a811                	j	ffffffffc0203a12 <strnlen+0x18>
        cnt ++;
ffffffffc0203a00:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203a02:	00f58863          	beq	a1,a5,ffffffffc0203a12 <strnlen+0x18>
ffffffffc0203a06:	00f50733          	add	a4,a0,a5
ffffffffc0203a0a:	00074703          	lbu	a4,0(a4)
ffffffffc0203a0e:	fb6d                	bnez	a4,ffffffffc0203a00 <strnlen+0x6>
ffffffffc0203a10:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203a12:	852e                	mv	a0,a1
ffffffffc0203a14:	8082                	ret

ffffffffc0203a16 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203a16:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203a18:	0005c703          	lbu	a4,0(a1)
ffffffffc0203a1c:	0785                	addi	a5,a5,1
ffffffffc0203a1e:	0585                	addi	a1,a1,1
ffffffffc0203a20:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203a24:	fb75                	bnez	a4,ffffffffc0203a18 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203a26:	8082                	ret

ffffffffc0203a28 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a28:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a2c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a30:	cb89                	beqz	a5,ffffffffc0203a42 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203a32:	0505                	addi	a0,a0,1
ffffffffc0203a34:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203a36:	fee789e3          	beq	a5,a4,ffffffffc0203a28 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a3a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203a3e:	9d19                	subw	a0,a0,a4
ffffffffc0203a40:	8082                	ret
ffffffffc0203a42:	4501                	li	a0,0
ffffffffc0203a44:	bfed                	j	ffffffffc0203a3e <strcmp+0x16>

ffffffffc0203a46 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203a46:	c20d                	beqz	a2,ffffffffc0203a68 <strncmp+0x22>
ffffffffc0203a48:	962e                	add	a2,a2,a1
ffffffffc0203a4a:	a031                	j	ffffffffc0203a56 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0203a4c:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203a4e:	00e79a63          	bne	a5,a4,ffffffffc0203a62 <strncmp+0x1c>
ffffffffc0203a52:	00b60b63          	beq	a2,a1,ffffffffc0203a68 <strncmp+0x22>
ffffffffc0203a56:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0203a5a:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203a5c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0203a60:	f7f5                	bnez	a5,ffffffffc0203a4c <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a62:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0203a66:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203a68:	4501                	li	a0,0
ffffffffc0203a6a:	8082                	ret

ffffffffc0203a6c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203a6c:	00054783          	lbu	a5,0(a0)
ffffffffc0203a70:	c799                	beqz	a5,ffffffffc0203a7e <strchr+0x12>
        if (*s == c) {
ffffffffc0203a72:	00f58763          	beq	a1,a5,ffffffffc0203a80 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0203a76:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0203a7a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203a7c:	fbfd                	bnez	a5,ffffffffc0203a72 <strchr+0x6>
    }
    return NULL;
ffffffffc0203a7e:	4501                	li	a0,0
}
ffffffffc0203a80:	8082                	ret

ffffffffc0203a82 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203a82:	ca01                	beqz	a2,ffffffffc0203a92 <memset+0x10>
ffffffffc0203a84:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203a86:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203a88:	0785                	addi	a5,a5,1
ffffffffc0203a8a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203a8e:	fec79de3          	bne	a5,a2,ffffffffc0203a88 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203a92:	8082                	ret

ffffffffc0203a94 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203a94:	ca19                	beqz	a2,ffffffffc0203aaa <memcpy+0x16>
ffffffffc0203a96:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203a98:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203a9a:	0005c703          	lbu	a4,0(a1)
ffffffffc0203a9e:	0585                	addi	a1,a1,1
ffffffffc0203aa0:	0785                	addi	a5,a5,1
ffffffffc0203aa2:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203aa6:	fec59ae3          	bne	a1,a2,ffffffffc0203a9a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203aaa:	8082                	ret

ffffffffc0203aac <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0203aac:	c205                	beqz	a2,ffffffffc0203acc <memcmp+0x20>
ffffffffc0203aae:	962e                	add	a2,a2,a1
ffffffffc0203ab0:	a019                	j	ffffffffc0203ab6 <memcmp+0xa>
ffffffffc0203ab2:	00c58d63          	beq	a1,a2,ffffffffc0203acc <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0203ab6:	00054783          	lbu	a5,0(a0)
ffffffffc0203aba:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0203abe:	0505                	addi	a0,a0,1
ffffffffc0203ac0:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0203ac2:	fee788e3          	beq	a5,a4,ffffffffc0203ab2 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ac6:	40e7853b          	subw	a0,a5,a4
ffffffffc0203aca:	8082                	ret
    }
    return 0;
ffffffffc0203acc:	4501                	li	a0,0
}
ffffffffc0203ace:	8082                	ret

ffffffffc0203ad0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203ad0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ad4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203ad6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ada:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203adc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203ae0:	f022                	sd	s0,32(sp)
ffffffffc0203ae2:	ec26                	sd	s1,24(sp)
ffffffffc0203ae4:	e84a                	sd	s2,16(sp)
ffffffffc0203ae6:	f406                	sd	ra,40(sp)
ffffffffc0203ae8:	e44e                	sd	s3,8(sp)
ffffffffc0203aea:	84aa                	mv	s1,a0
ffffffffc0203aec:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203aee:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203af2:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203af4:	03067e63          	bgeu	a2,a6,ffffffffc0203b30 <printnum+0x60>
ffffffffc0203af8:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203afa:	00805763          	blez	s0,ffffffffc0203b08 <printnum+0x38>
ffffffffc0203afe:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203b00:	85ca                	mv	a1,s2
ffffffffc0203b02:	854e                	mv	a0,s3
ffffffffc0203b04:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203b06:	fc65                	bnez	s0,ffffffffc0203afe <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b08:	1a02                	slli	s4,s4,0x20
ffffffffc0203b0a:	00002797          	auipc	a5,0x2
ffffffffc0203b0e:	cd678793          	addi	a5,a5,-810 # ffffffffc02057e0 <default_pmm_manager+0x7c0>
ffffffffc0203b12:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203b16:	9a3e                	add	s4,s4,a5
}
ffffffffc0203b18:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b1a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203b1e:	70a2                	ld	ra,40(sp)
ffffffffc0203b20:	69a2                	ld	s3,8(sp)
ffffffffc0203b22:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b24:	85ca                	mv	a1,s2
ffffffffc0203b26:	87a6                	mv	a5,s1
}
ffffffffc0203b28:	6942                	ld	s2,16(sp)
ffffffffc0203b2a:	64e2                	ld	s1,24(sp)
ffffffffc0203b2c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203b2e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203b30:	03065633          	divu	a2,a2,a6
ffffffffc0203b34:	8722                	mv	a4,s0
ffffffffc0203b36:	f9bff0ef          	jal	ra,ffffffffc0203ad0 <printnum>
ffffffffc0203b3a:	b7f9                	j	ffffffffc0203b08 <printnum+0x38>

ffffffffc0203b3c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203b3c:	7119                	addi	sp,sp,-128
ffffffffc0203b3e:	f4a6                	sd	s1,104(sp)
ffffffffc0203b40:	f0ca                	sd	s2,96(sp)
ffffffffc0203b42:	ecce                	sd	s3,88(sp)
ffffffffc0203b44:	e8d2                	sd	s4,80(sp)
ffffffffc0203b46:	e4d6                	sd	s5,72(sp)
ffffffffc0203b48:	e0da                	sd	s6,64(sp)
ffffffffc0203b4a:	fc5e                	sd	s7,56(sp)
ffffffffc0203b4c:	f06a                	sd	s10,32(sp)
ffffffffc0203b4e:	fc86                	sd	ra,120(sp)
ffffffffc0203b50:	f8a2                	sd	s0,112(sp)
ffffffffc0203b52:	f862                	sd	s8,48(sp)
ffffffffc0203b54:	f466                	sd	s9,40(sp)
ffffffffc0203b56:	ec6e                	sd	s11,24(sp)
ffffffffc0203b58:	892a                	mv	s2,a0
ffffffffc0203b5a:	84ae                	mv	s1,a1
ffffffffc0203b5c:	8d32                	mv	s10,a2
ffffffffc0203b5e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203b60:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203b64:	5b7d                	li	s6,-1
ffffffffc0203b66:	00002a97          	auipc	s5,0x2
ffffffffc0203b6a:	ca6a8a93          	addi	s5,s5,-858 # ffffffffc020580c <default_pmm_manager+0x7ec>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203b6e:	00002b97          	auipc	s7,0x2
ffffffffc0203b72:	e7ab8b93          	addi	s7,s7,-390 # ffffffffc02059e8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203b76:	000d4503          	lbu	a0,0(s10)
ffffffffc0203b7a:	001d0413          	addi	s0,s10,1
ffffffffc0203b7e:	01350a63          	beq	a0,s3,ffffffffc0203b92 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0203b82:	c121                	beqz	a0,ffffffffc0203bc2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0203b84:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203b86:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203b88:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203b8a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203b8e:	ff351ae3          	bne	a0,s3,ffffffffc0203b82 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203b92:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203b96:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203b9a:	4c81                	li	s9,0
ffffffffc0203b9c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0203b9e:	5c7d                	li	s8,-1
ffffffffc0203ba0:	5dfd                	li	s11,-1
ffffffffc0203ba2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ba6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ba8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203bac:	0ff5f593          	zext.b	a1,a1
ffffffffc0203bb0:	00140d13          	addi	s10,s0,1
ffffffffc0203bb4:	04b56263          	bltu	a0,a1,ffffffffc0203bf8 <vprintfmt+0xbc>
ffffffffc0203bb8:	058a                	slli	a1,a1,0x2
ffffffffc0203bba:	95d6                	add	a1,a1,s5
ffffffffc0203bbc:	4194                	lw	a3,0(a1)
ffffffffc0203bbe:	96d6                	add	a3,a3,s5
ffffffffc0203bc0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203bc2:	70e6                	ld	ra,120(sp)
ffffffffc0203bc4:	7446                	ld	s0,112(sp)
ffffffffc0203bc6:	74a6                	ld	s1,104(sp)
ffffffffc0203bc8:	7906                	ld	s2,96(sp)
ffffffffc0203bca:	69e6                	ld	s3,88(sp)
ffffffffc0203bcc:	6a46                	ld	s4,80(sp)
ffffffffc0203bce:	6aa6                	ld	s5,72(sp)
ffffffffc0203bd0:	6b06                	ld	s6,64(sp)
ffffffffc0203bd2:	7be2                	ld	s7,56(sp)
ffffffffc0203bd4:	7c42                	ld	s8,48(sp)
ffffffffc0203bd6:	7ca2                	ld	s9,40(sp)
ffffffffc0203bd8:	7d02                	ld	s10,32(sp)
ffffffffc0203bda:	6de2                	ld	s11,24(sp)
ffffffffc0203bdc:	6109                	addi	sp,sp,128
ffffffffc0203bde:	8082                	ret
            padc = '0';
ffffffffc0203be0:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0203be2:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203be6:	846a                	mv	s0,s10
ffffffffc0203be8:	00140d13          	addi	s10,s0,1
ffffffffc0203bec:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0203bf0:	0ff5f593          	zext.b	a1,a1
ffffffffc0203bf4:	fcb572e3          	bgeu	a0,a1,ffffffffc0203bb8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0203bf8:	85a6                	mv	a1,s1
ffffffffc0203bfa:	02500513          	li	a0,37
ffffffffc0203bfe:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203c00:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203c04:	8d22                	mv	s10,s0
ffffffffc0203c06:	f73788e3          	beq	a5,s3,ffffffffc0203b76 <vprintfmt+0x3a>
ffffffffc0203c0a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0203c0e:	1d7d                	addi	s10,s10,-1
ffffffffc0203c10:	ff379de3          	bne	a5,s3,ffffffffc0203c0a <vprintfmt+0xce>
ffffffffc0203c14:	b78d                	j	ffffffffc0203b76 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0203c16:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0203c1a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c1e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203c20:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203c24:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203c28:	02d86463          	bltu	a6,a3,ffffffffc0203c50 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0203c2c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203c30:	002c169b          	slliw	a3,s8,0x2
ffffffffc0203c34:	0186873b          	addw	a4,a3,s8
ffffffffc0203c38:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203c3c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0203c3e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203c42:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203c44:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0203c48:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203c4c:	fed870e3          	bgeu	a6,a3,ffffffffc0203c2c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0203c50:	f40ddce3          	bgez	s11,ffffffffc0203ba8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0203c54:	8de2                	mv	s11,s8
ffffffffc0203c56:	5c7d                	li	s8,-1
ffffffffc0203c58:	bf81                	j	ffffffffc0203ba8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0203c5a:	fffdc693          	not	a3,s11
ffffffffc0203c5e:	96fd                	srai	a3,a3,0x3f
ffffffffc0203c60:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c64:	00144603          	lbu	a2,1(s0)
ffffffffc0203c68:	2d81                	sext.w	s11,s11
ffffffffc0203c6a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203c6c:	bf35                	j	ffffffffc0203ba8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0203c6e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c72:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203c76:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c78:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0203c7a:	bfd9                	j	ffffffffc0203c50 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0203c7c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203c7e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203c82:	01174463          	blt	a4,a7,ffffffffc0203c8a <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0203c86:	1a088e63          	beqz	a7,ffffffffc0203e42 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0203c8a:	000a3603          	ld	a2,0(s4)
ffffffffc0203c8e:	46c1                	li	a3,16
ffffffffc0203c90:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203c92:	2781                	sext.w	a5,a5
ffffffffc0203c94:	876e                	mv	a4,s11
ffffffffc0203c96:	85a6                	mv	a1,s1
ffffffffc0203c98:	854a                	mv	a0,s2
ffffffffc0203c9a:	e37ff0ef          	jal	ra,ffffffffc0203ad0 <printnum>
            break;
ffffffffc0203c9e:	bde1                	j	ffffffffc0203b76 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ca0:	000a2503          	lw	a0,0(s4)
ffffffffc0203ca4:	85a6                	mv	a1,s1
ffffffffc0203ca6:	0a21                	addi	s4,s4,8
ffffffffc0203ca8:	9902                	jalr	s2
            break;
ffffffffc0203caa:	b5f1                	j	ffffffffc0203b76 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203cac:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203cae:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203cb2:	01174463          	blt	a4,a7,ffffffffc0203cba <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0203cb6:	18088163          	beqz	a7,ffffffffc0203e38 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0203cba:	000a3603          	ld	a2,0(s4)
ffffffffc0203cbe:	46a9                	li	a3,10
ffffffffc0203cc0:	8a2e                	mv	s4,a1
ffffffffc0203cc2:	bfc1                	j	ffffffffc0203c92 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cc4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203cc8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cca:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ccc:	bdf1                	j	ffffffffc0203ba8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0203cce:	85a6                	mv	a1,s1
ffffffffc0203cd0:	02500513          	li	a0,37
ffffffffc0203cd4:	9902                	jalr	s2
            break;
ffffffffc0203cd6:	b545                	j	ffffffffc0203b76 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cd8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0203cdc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cde:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ce0:	b5e1                	j	ffffffffc0203ba8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0203ce2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203ce4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203ce8:	01174463          	blt	a4,a7,ffffffffc0203cf0 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0203cec:	14088163          	beqz	a7,ffffffffc0203e2e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0203cf0:	000a3603          	ld	a2,0(s4)
ffffffffc0203cf4:	46a1                	li	a3,8
ffffffffc0203cf6:	8a2e                	mv	s4,a1
ffffffffc0203cf8:	bf69                	j	ffffffffc0203c92 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0203cfa:	03000513          	li	a0,48
ffffffffc0203cfe:	85a6                	mv	a1,s1
ffffffffc0203d00:	e03e                	sd	a5,0(sp)
ffffffffc0203d02:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203d04:	85a6                	mv	a1,s1
ffffffffc0203d06:	07800513          	li	a0,120
ffffffffc0203d0a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d0c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203d0e:	6782                	ld	a5,0(sp)
ffffffffc0203d10:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203d12:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0203d16:	bfb5                	j	ffffffffc0203c92 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d18:	000a3403          	ld	s0,0(s4)
ffffffffc0203d1c:	008a0713          	addi	a4,s4,8
ffffffffc0203d20:	e03a                	sd	a4,0(sp)
ffffffffc0203d22:	14040263          	beqz	s0,ffffffffc0203e66 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0203d26:	0fb05763          	blez	s11,ffffffffc0203e14 <vprintfmt+0x2d8>
ffffffffc0203d2a:	02d00693          	li	a3,45
ffffffffc0203d2e:	0cd79163          	bne	a5,a3,ffffffffc0203df0 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d32:	00044783          	lbu	a5,0(s0)
ffffffffc0203d36:	0007851b          	sext.w	a0,a5
ffffffffc0203d3a:	cf85                	beqz	a5,ffffffffc0203d72 <vprintfmt+0x236>
ffffffffc0203d3c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d40:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d44:	000c4563          	bltz	s8,ffffffffc0203d4e <vprintfmt+0x212>
ffffffffc0203d48:	3c7d                	addiw	s8,s8,-1
ffffffffc0203d4a:	036c0263          	beq	s8,s6,ffffffffc0203d6e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0203d4e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203d50:	0e0c8e63          	beqz	s9,ffffffffc0203e4c <vprintfmt+0x310>
ffffffffc0203d54:	3781                	addiw	a5,a5,-32
ffffffffc0203d56:	0ef47b63          	bgeu	s0,a5,ffffffffc0203e4c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0203d5a:	03f00513          	li	a0,63
ffffffffc0203d5e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203d60:	000a4783          	lbu	a5,0(s4)
ffffffffc0203d64:	3dfd                	addiw	s11,s11,-1
ffffffffc0203d66:	0a05                	addi	s4,s4,1
ffffffffc0203d68:	0007851b          	sext.w	a0,a5
ffffffffc0203d6c:	ffe1                	bnez	a5,ffffffffc0203d44 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0203d6e:	01b05963          	blez	s11,ffffffffc0203d80 <vprintfmt+0x244>
ffffffffc0203d72:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203d74:	85a6                	mv	a1,s1
ffffffffc0203d76:	02000513          	li	a0,32
ffffffffc0203d7a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203d7c:	fe0d9be3          	bnez	s11,ffffffffc0203d72 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203d80:	6a02                	ld	s4,0(sp)
ffffffffc0203d82:	bbd5                	j	ffffffffc0203b76 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203d84:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203d86:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0203d8a:	01174463          	blt	a4,a7,ffffffffc0203d92 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0203d8e:	08088d63          	beqz	a7,ffffffffc0203e28 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0203d92:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203d96:	0a044d63          	bltz	s0,ffffffffc0203e50 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0203d9a:	8622                	mv	a2,s0
ffffffffc0203d9c:	8a66                	mv	s4,s9
ffffffffc0203d9e:	46a9                	li	a3,10
ffffffffc0203da0:	bdcd                	j	ffffffffc0203c92 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0203da2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203da6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203da8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203daa:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203dae:	8fb5                	xor	a5,a5,a3
ffffffffc0203db0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203db4:	02d74163          	blt	a4,a3,ffffffffc0203dd6 <vprintfmt+0x29a>
ffffffffc0203db8:	00369793          	slli	a5,a3,0x3
ffffffffc0203dbc:	97de                	add	a5,a5,s7
ffffffffc0203dbe:	639c                	ld	a5,0(a5)
ffffffffc0203dc0:	cb99                	beqz	a5,ffffffffc0203dd6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203dc2:	86be                	mv	a3,a5
ffffffffc0203dc4:	00000617          	auipc	a2,0x0
ffffffffc0203dc8:	13c60613          	addi	a2,a2,316 # ffffffffc0203f00 <etext+0x2c>
ffffffffc0203dcc:	85a6                	mv	a1,s1
ffffffffc0203dce:	854a                	mv	a0,s2
ffffffffc0203dd0:	0ce000ef          	jal	ra,ffffffffc0203e9e <printfmt>
ffffffffc0203dd4:	b34d                	j	ffffffffc0203b76 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203dd6:	00002617          	auipc	a2,0x2
ffffffffc0203dda:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0205800 <default_pmm_manager+0x7e0>
ffffffffc0203dde:	85a6                	mv	a1,s1
ffffffffc0203de0:	854a                	mv	a0,s2
ffffffffc0203de2:	0bc000ef          	jal	ra,ffffffffc0203e9e <printfmt>
ffffffffc0203de6:	bb41                	j	ffffffffc0203b76 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203de8:	00002417          	auipc	s0,0x2
ffffffffc0203dec:	a1040413          	addi	s0,s0,-1520 # ffffffffc02057f8 <default_pmm_manager+0x7d8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203df0:	85e2                	mv	a1,s8
ffffffffc0203df2:	8522                	mv	a0,s0
ffffffffc0203df4:	e43e                	sd	a5,8(sp)
ffffffffc0203df6:	c05ff0ef          	jal	ra,ffffffffc02039fa <strnlen>
ffffffffc0203dfa:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203dfe:	01b05b63          	blez	s11,ffffffffc0203e14 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0203e02:	67a2                	ld	a5,8(sp)
ffffffffc0203e04:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e08:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203e0a:	85a6                	mv	a1,s1
ffffffffc0203e0c:	8552                	mv	a0,s4
ffffffffc0203e0e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203e10:	fe0d9ce3          	bnez	s11,ffffffffc0203e08 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e14:	00044783          	lbu	a5,0(s0)
ffffffffc0203e18:	00140a13          	addi	s4,s0,1
ffffffffc0203e1c:	0007851b          	sext.w	a0,a5
ffffffffc0203e20:	d3a5                	beqz	a5,ffffffffc0203d80 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e22:	05e00413          	li	s0,94
ffffffffc0203e26:	bf39                	j	ffffffffc0203d44 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0203e28:	000a2403          	lw	s0,0(s4)
ffffffffc0203e2c:	b7ad                	j	ffffffffc0203d96 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0203e2e:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e32:	46a1                	li	a3,8
ffffffffc0203e34:	8a2e                	mv	s4,a1
ffffffffc0203e36:	bdb1                	j	ffffffffc0203c92 <vprintfmt+0x156>
ffffffffc0203e38:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e3c:	46a9                	li	a3,10
ffffffffc0203e3e:	8a2e                	mv	s4,a1
ffffffffc0203e40:	bd89                	j	ffffffffc0203c92 <vprintfmt+0x156>
ffffffffc0203e42:	000a6603          	lwu	a2,0(s4)
ffffffffc0203e46:	46c1                	li	a3,16
ffffffffc0203e48:	8a2e                	mv	s4,a1
ffffffffc0203e4a:	b5a1                	j	ffffffffc0203c92 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0203e4c:	9902                	jalr	s2
ffffffffc0203e4e:	bf09                	j	ffffffffc0203d60 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0203e50:	85a6                	mv	a1,s1
ffffffffc0203e52:	02d00513          	li	a0,45
ffffffffc0203e56:	e03e                	sd	a5,0(sp)
ffffffffc0203e58:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203e5a:	6782                	ld	a5,0(sp)
ffffffffc0203e5c:	8a66                	mv	s4,s9
ffffffffc0203e5e:	40800633          	neg	a2,s0
ffffffffc0203e62:	46a9                	li	a3,10
ffffffffc0203e64:	b53d                	j	ffffffffc0203c92 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0203e66:	03b05163          	blez	s11,ffffffffc0203e88 <vprintfmt+0x34c>
ffffffffc0203e6a:	02d00693          	li	a3,45
ffffffffc0203e6e:	f6d79de3          	bne	a5,a3,ffffffffc0203de8 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0203e72:	00002417          	auipc	s0,0x2
ffffffffc0203e76:	98640413          	addi	s0,s0,-1658 # ffffffffc02057f8 <default_pmm_manager+0x7d8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e7a:	02800793          	li	a5,40
ffffffffc0203e7e:	02800513          	li	a0,40
ffffffffc0203e82:	00140a13          	addi	s4,s0,1
ffffffffc0203e86:	bd6d                	j	ffffffffc0203d40 <vprintfmt+0x204>
ffffffffc0203e88:	00002a17          	auipc	s4,0x2
ffffffffc0203e8c:	971a0a13          	addi	s4,s4,-1679 # ffffffffc02057f9 <default_pmm_manager+0x7d9>
ffffffffc0203e90:	02800513          	li	a0,40
ffffffffc0203e94:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e98:	05e00413          	li	s0,94
ffffffffc0203e9c:	b565                	j	ffffffffc0203d44 <vprintfmt+0x208>

ffffffffc0203e9e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203e9e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203ea0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ea4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203ea6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203ea8:	ec06                	sd	ra,24(sp)
ffffffffc0203eaa:	f83a                	sd	a4,48(sp)
ffffffffc0203eac:	fc3e                	sd	a5,56(sp)
ffffffffc0203eae:	e0c2                	sd	a6,64(sp)
ffffffffc0203eb0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203eb2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203eb4:	c89ff0ef          	jal	ra,ffffffffc0203b3c <vprintfmt>
}
ffffffffc0203eb8:	60e2                	ld	ra,24(sp)
ffffffffc0203eba:	6161                	addi	sp,sp,80
ffffffffc0203ebc:	8082                	ret

ffffffffc0203ebe <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0203ebe:	9e3707b7          	lui	a5,0x9e370
ffffffffc0203ec2:	2785                	addiw	a5,a5,1
ffffffffc0203ec4:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0203ec8:	02000793          	li	a5,32
ffffffffc0203ecc:	9f8d                	subw	a5,a5,a1
}
ffffffffc0203ece:	00f5553b          	srlw	a0,a0,a5
ffffffffc0203ed2:	8082                	ret
