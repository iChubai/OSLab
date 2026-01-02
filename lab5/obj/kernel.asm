
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
ffffffffc020004a:	000a3517          	auipc	a0,0xa3
ffffffffc020004e:	05e50513          	addi	a0,a0,94 # ffffffffc02a30a8 <buf>
ffffffffc0200052:	000a7617          	auipc	a2,0xa7
ffffffffc0200056:	50660613          	addi	a2,a2,1286 # ffffffffc02a7558 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0209ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	482050ef          	jal	ffffffffc02054e4 <memset>
    dtb_init();
ffffffffc0200066:	490000ef          	jal	ffffffffc02004f6 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	027000ef          	jal	ffffffffc0200890 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	88258593          	addi	a1,a1,-1918 # ffffffffc02058f0 <etext>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	89a50513          	addi	a0,a0,-1894 # ffffffffc0205910 <etext+0x20>
ffffffffc020007e:	060000ef          	jal	ffffffffc02000de <cprintf>

    print_kerninfo();
ffffffffc0200082:	254000ef          	jal	ffffffffc02002d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	018030ef          	jal	ffffffffc020309e <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	079000ef          	jal	ffffffffc0200902 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	083000ef          	jal	ffffffffc0200910 <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	442010ef          	jal	ffffffffc02014d4 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	7e5040ef          	jal	ffffffffc020507a <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	7a2000ef          	jal	ffffffffc020083c <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	067000ef          	jal	ffffffffc0200904 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	178050ef          	jal	ffffffffc020521a <cpu_idle>

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
ffffffffc02000ac:	7e6000ef          	jal	ffffffffc0200892 <cons_putc>
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
ffffffffc02000d2:	4a2050ef          	jal	ffffffffc0205574 <vprintfmt>
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
ffffffffc0200106:	46e050ef          	jal	ffffffffc0205574 <vprintfmt>
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
ffffffffc0200112:	7800006f          	j	ffffffffc0200892 <cons_putc>

ffffffffc0200116 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc0200116:	1101                	addi	sp,sp,-32
ffffffffc0200118:	e822                	sd	s0,16(sp)
ffffffffc020011a:	ec06                	sd	ra,24(sp)
ffffffffc020011c:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc020011e:	00054503          	lbu	a0,0(a0)
ffffffffc0200122:	c51d                	beqz	a0,ffffffffc0200150 <cputs+0x3a>
ffffffffc0200124:	e426                	sd	s1,8(sp)
ffffffffc0200126:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc0200128:	4481                	li	s1,0
    cons_putc(c);
ffffffffc020012a:	768000ef          	jal	ffffffffc0200892 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc020012e:	00044503          	lbu	a0,0(s0)
ffffffffc0200132:	0405                	addi	s0,s0,1
ffffffffc0200134:	87a6                	mv	a5,s1
    (*cnt)++;
ffffffffc0200136:	2485                	addiw	s1,s1,1
    while ((c = *str++) != '\0')
ffffffffc0200138:	f96d                	bnez	a0,ffffffffc020012a <cputs+0x14>
    cons_putc(c);
ffffffffc020013a:	4529                	li	a0,10
    (*cnt)++;
ffffffffc020013c:	0027841b          	addiw	s0,a5,2
ffffffffc0200140:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc0200142:	750000ef          	jal	ffffffffc0200892 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200146:	60e2                	ld	ra,24(sp)
ffffffffc0200148:	8522                	mv	a0,s0
ffffffffc020014a:	6442                	ld	s0,16(sp)
ffffffffc020014c:	6105                	addi	sp,sp,32
ffffffffc020014e:	8082                	ret
    cons_putc(c);
ffffffffc0200150:	4529                	li	a0,10
ffffffffc0200152:	740000ef          	jal	ffffffffc0200892 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc0200156:	4405                	li	s0,1
}
ffffffffc0200158:	60e2                	ld	ra,24(sp)
ffffffffc020015a:	8522                	mv	a0,s0
ffffffffc020015c:	6442                	ld	s0,16(sp)
ffffffffc020015e:	6105                	addi	sp,sp,32
ffffffffc0200160:	8082                	ret

ffffffffc0200162 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc0200162:	1141                	addi	sp,sp,-16
ffffffffc0200164:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200166:	760000ef          	jal	ffffffffc02008c6 <cons_getc>
ffffffffc020016a:	dd75                	beqz	a0,ffffffffc0200166 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020016c:	60a2                	ld	ra,8(sp)
ffffffffc020016e:	0141                	addi	sp,sp,16
ffffffffc0200170:	8082                	ret

ffffffffc0200172 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200172:	7179                	addi	sp,sp,-48
ffffffffc0200174:	f406                	sd	ra,40(sp)
ffffffffc0200176:	f022                	sd	s0,32(sp)
ffffffffc0200178:	ec26                	sd	s1,24(sp)
ffffffffc020017a:	e84a                	sd	s2,16(sp)
ffffffffc020017c:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc020017e:	c901                	beqz	a0,ffffffffc020018e <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc0200180:	85aa                	mv	a1,a0
ffffffffc0200182:	00005517          	auipc	a0,0x5
ffffffffc0200186:	79650513          	addi	a0,a0,1942 # ffffffffc0205918 <etext+0x28>
ffffffffc020018a:	f55ff0ef          	jal	ffffffffc02000de <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc020018e:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200190:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc0200192:	000a3997          	auipc	s3,0xa3
ffffffffc0200196:	f1698993          	addi	s3,s3,-234 # ffffffffc02a30a8 <buf>
        c = getchar();
ffffffffc020019a:	fc9ff0ef          	jal	ffffffffc0200162 <getchar>
ffffffffc020019e:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc02001a0:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001a4:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02001a8:	ff650693          	addi	a3,a0,-10
ffffffffc02001ac:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02001b0:	02054963          	bltz	a0,ffffffffc02001e2 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001b4:	02a95f63          	bge	s2,a0,ffffffffc02001f2 <readline+0x80>
ffffffffc02001b8:	cf0d                	beqz	a4,ffffffffc02001f2 <readline+0x80>
            cputchar(c);
ffffffffc02001ba:	f59ff0ef          	jal	ffffffffc0200112 <cputchar>
            buf[i ++] = c;
ffffffffc02001be:	009987b3          	add	a5,s3,s1
ffffffffc02001c2:	00878023          	sb	s0,0(a5)
ffffffffc02001c6:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc02001c8:	f9bff0ef          	jal	ffffffffc0200162 <getchar>
ffffffffc02001cc:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc02001ce:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02001d2:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc02001d6:	ff650693          	addi	a3,a0,-10
ffffffffc02001da:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02001de:	fc055be3          	bgez	a0,ffffffffc02001b4 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc02001e2:	70a2                	ld	ra,40(sp)
ffffffffc02001e4:	7402                	ld	s0,32(sp)
ffffffffc02001e6:	64e2                	ld	s1,24(sp)
ffffffffc02001e8:	6942                	ld	s2,16(sp)
ffffffffc02001ea:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc02001ec:	4501                	li	a0,0
}
ffffffffc02001ee:	6145                	addi	sp,sp,48
ffffffffc02001f0:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc02001f2:	eb81                	bnez	a5,ffffffffc0200202 <readline+0x90>
            cputchar(c);
ffffffffc02001f4:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc02001f6:	00905663          	blez	s1,ffffffffc0200202 <readline+0x90>
            cputchar(c);
ffffffffc02001fa:	f19ff0ef          	jal	ffffffffc0200112 <cputchar>
            i --;
ffffffffc02001fe:	34fd                	addiw	s1,s1,-1
ffffffffc0200200:	bf69                	j	ffffffffc020019a <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0200202:	c291                	beqz	a3,ffffffffc0200206 <readline+0x94>
ffffffffc0200204:	fa59                	bnez	a2,ffffffffc020019a <readline+0x28>
            cputchar(c);
ffffffffc0200206:	8522                	mv	a0,s0
ffffffffc0200208:	f0bff0ef          	jal	ffffffffc0200112 <cputchar>
            buf[i] = '\0';
ffffffffc020020c:	000a3517          	auipc	a0,0xa3
ffffffffc0200210:	e9c50513          	addi	a0,a0,-356 # ffffffffc02a30a8 <buf>
ffffffffc0200214:	94aa                	add	s1,s1,a0
ffffffffc0200216:	00048023          	sb	zero,0(s1)
}
ffffffffc020021a:	70a2                	ld	ra,40(sp)
ffffffffc020021c:	7402                	ld	s0,32(sp)
ffffffffc020021e:	64e2                	ld	s1,24(sp)
ffffffffc0200220:	6942                	ld	s2,16(sp)
ffffffffc0200222:	69a2                	ld	s3,8(sp)
ffffffffc0200224:	6145                	addi	sp,sp,48
ffffffffc0200226:	8082                	ret

ffffffffc0200228 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc0200228:	000a7317          	auipc	t1,0xa7
ffffffffc020022c:	2a833303          	ld	t1,680(t1) # ffffffffc02a74d0 <is_panic>
{
ffffffffc0200230:	715d                	addi	sp,sp,-80
ffffffffc0200232:	ec06                	sd	ra,24(sp)
ffffffffc0200234:	f436                	sd	a3,40(sp)
ffffffffc0200236:	f83a                	sd	a4,48(sp)
ffffffffc0200238:	fc3e                	sd	a5,56(sp)
ffffffffc020023a:	e0c2                	sd	a6,64(sp)
ffffffffc020023c:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020023e:	02031e63          	bnez	t1,ffffffffc020027a <__panic+0x52>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200242:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200244:	103c                	addi	a5,sp,40
ffffffffc0200246:	e822                	sd	s0,16(sp)
ffffffffc0200248:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020024a:	862e                	mv	a2,a1
ffffffffc020024c:	85aa                	mv	a1,a0
ffffffffc020024e:	00005517          	auipc	a0,0x5
ffffffffc0200252:	6d250513          	addi	a0,a0,1746 # ffffffffc0205920 <etext+0x30>
    is_panic = 1;
ffffffffc0200256:	000a7697          	auipc	a3,0xa7
ffffffffc020025a:	26e6bd23          	sd	a4,634(a3) # ffffffffc02a74d0 <is_panic>
    va_start(ap, fmt);
ffffffffc020025e:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200260:	e7fff0ef          	jal	ffffffffc02000de <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200264:	65a2                	ld	a1,8(sp)
ffffffffc0200266:	8522                	mv	a0,s0
ffffffffc0200268:	e57ff0ef          	jal	ffffffffc02000be <vcprintf>
    cprintf("\n");
ffffffffc020026c:	00005517          	auipc	a0,0x5
ffffffffc0200270:	6d450513          	addi	a0,a0,1748 # ffffffffc0205940 <etext+0x50>
ffffffffc0200274:	e6bff0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc0200278:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	4581                	li	a1,0
ffffffffc020027e:	4601                	li	a2,0
ffffffffc0200280:	48a1                	li	a7,8
ffffffffc0200282:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc0200286:	684000ef          	jal	ffffffffc020090a <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc020028a:	4501                	li	a0,0
ffffffffc020028c:	14c000ef          	jal	ffffffffc02003d8 <kmonitor>
    while (1)
ffffffffc0200290:	bfed                	j	ffffffffc020028a <__panic+0x62>

ffffffffc0200292 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc0200292:	715d                	addi	sp,sp,-80
ffffffffc0200294:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200296:	02810313          	addi	t1,sp,40
{
ffffffffc020029a:	8432                	mv	s0,a2
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020029c:	862e                	mv	a2,a1
ffffffffc020029e:	85aa                	mv	a1,a0
ffffffffc02002a0:	00005517          	auipc	a0,0x5
ffffffffc02002a4:	6a850513          	addi	a0,a0,1704 # ffffffffc0205948 <etext+0x58>
{
ffffffffc02002a8:	ec06                	sd	ra,24(sp)
ffffffffc02002aa:	f436                	sd	a3,40(sp)
ffffffffc02002ac:	f83a                	sd	a4,48(sp)
ffffffffc02002ae:	fc3e                	sd	a5,56(sp)
ffffffffc02002b0:	e0c2                	sd	a6,64(sp)
ffffffffc02002b2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02002b4:	e41a                	sd	t1,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02002b6:	e29ff0ef          	jal	ffffffffc02000de <cprintf>
    vcprintf(fmt, ap);
ffffffffc02002ba:	65a2                	ld	a1,8(sp)
ffffffffc02002bc:	8522                	mv	a0,s0
ffffffffc02002be:	e01ff0ef          	jal	ffffffffc02000be <vcprintf>
    cprintf("\n");
ffffffffc02002c2:	00005517          	auipc	a0,0x5
ffffffffc02002c6:	67e50513          	addi	a0,a0,1662 # ffffffffc0205940 <etext+0x50>
ffffffffc02002ca:	e15ff0ef          	jal	ffffffffc02000de <cprintf>
    va_end(ap);
}
ffffffffc02002ce:	60e2                	ld	ra,24(sp)
ffffffffc02002d0:	6442                	ld	s0,16(sp)
ffffffffc02002d2:	6161                	addi	sp,sp,80
ffffffffc02002d4:	8082                	ret

ffffffffc02002d6 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02002d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02002d8:	00005517          	auipc	a0,0x5
ffffffffc02002dc:	69050513          	addi	a0,a0,1680 # ffffffffc0205968 <etext+0x78>
{
ffffffffc02002e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02002e2:	dfdff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02002e6:	00000597          	auipc	a1,0x0
ffffffffc02002ea:	d6458593          	addi	a1,a1,-668 # ffffffffc020004a <kern_init>
ffffffffc02002ee:	00005517          	auipc	a0,0x5
ffffffffc02002f2:	69a50513          	addi	a0,a0,1690 # ffffffffc0205988 <etext+0x98>
ffffffffc02002f6:	de9ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02002fa:	00005597          	auipc	a1,0x5
ffffffffc02002fe:	5f658593          	addi	a1,a1,1526 # ffffffffc02058f0 <etext>
ffffffffc0200302:	00005517          	auipc	a0,0x5
ffffffffc0200306:	6a650513          	addi	a0,a0,1702 # ffffffffc02059a8 <etext+0xb8>
ffffffffc020030a:	dd5ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020030e:	000a3597          	auipc	a1,0xa3
ffffffffc0200312:	d9a58593          	addi	a1,a1,-614 # ffffffffc02a30a8 <buf>
ffffffffc0200316:	00005517          	auipc	a0,0x5
ffffffffc020031a:	6b250513          	addi	a0,a0,1714 # ffffffffc02059c8 <etext+0xd8>
ffffffffc020031e:	dc1ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200322:	000a7597          	auipc	a1,0xa7
ffffffffc0200326:	23658593          	addi	a1,a1,566 # ffffffffc02a7558 <end>
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	6be50513          	addi	a0,a0,1726 # ffffffffc02059e8 <etext+0xf8>
ffffffffc0200332:	dadff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200336:	00000717          	auipc	a4,0x0
ffffffffc020033a:	d1470713          	addi	a4,a4,-748 # ffffffffc020004a <kern_init>
ffffffffc020033e:	000a7797          	auipc	a5,0xa7
ffffffffc0200342:	61978793          	addi	a5,a5,1561 # ffffffffc02a7957 <end+0x3ff>
ffffffffc0200346:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200348:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020034c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020034e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200352:	95be                	add	a1,a1,a5
ffffffffc0200354:	85a9                	srai	a1,a1,0xa
ffffffffc0200356:	00005517          	auipc	a0,0x5
ffffffffc020035a:	6b250513          	addi	a0,a0,1714 # ffffffffc0205a08 <etext+0x118>
}
ffffffffc020035e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200360:	bbbd                	j	ffffffffc02000de <cprintf>

ffffffffc0200362 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc0200362:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200364:	00005617          	auipc	a2,0x5
ffffffffc0200368:	6d460613          	addi	a2,a2,1748 # ffffffffc0205a38 <etext+0x148>
ffffffffc020036c:	04f00593          	li	a1,79
ffffffffc0200370:	00005517          	auipc	a0,0x5
ffffffffc0200374:	6e050513          	addi	a0,a0,1760 # ffffffffc0205a50 <etext+0x160>
{
ffffffffc0200378:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020037a:	eafff0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc020037e <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc020037e:	1101                	addi	sp,sp,-32
ffffffffc0200380:	e822                	sd	s0,16(sp)
ffffffffc0200382:	e426                	sd	s1,8(sp)
ffffffffc0200384:	ec06                	sd	ra,24(sp)
ffffffffc0200386:	00007417          	auipc	s0,0x7
ffffffffc020038a:	2aa40413          	addi	s0,s0,682 # ffffffffc0207630 <commands>
ffffffffc020038e:	00007497          	auipc	s1,0x7
ffffffffc0200392:	2ea48493          	addi	s1,s1,746 # ffffffffc0207678 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200396:	6410                	ld	a2,8(s0)
ffffffffc0200398:	600c                	ld	a1,0(s0)
ffffffffc020039a:	00005517          	auipc	a0,0x5
ffffffffc020039e:	6ce50513          	addi	a0,a0,1742 # ffffffffc0205a68 <etext+0x178>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003a2:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02003a4:	d3bff0ef          	jal	ffffffffc02000de <cprintf>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02003a8:	fe9417e3          	bne	s0,s1,ffffffffc0200396 <mon_help+0x18>
    }
    return 0;
}
ffffffffc02003ac:	60e2                	ld	ra,24(sp)
ffffffffc02003ae:	6442                	ld	s0,16(sp)
ffffffffc02003b0:	64a2                	ld	s1,8(sp)
ffffffffc02003b2:	4501                	li	a0,0
ffffffffc02003b4:	6105                	addi	sp,sp,32
ffffffffc02003b6:	8082                	ret

ffffffffc02003b8 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02003b8:	1141                	addi	sp,sp,-16
ffffffffc02003ba:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02003bc:	f1bff0ef          	jal	ffffffffc02002d6 <print_kerninfo>
    return 0;
}
ffffffffc02003c0:	60a2                	ld	ra,8(sp)
ffffffffc02003c2:	4501                	li	a0,0
ffffffffc02003c4:	0141                	addi	sp,sp,16
ffffffffc02003c6:	8082                	ret

ffffffffc02003c8 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02003c8:	1141                	addi	sp,sp,-16
ffffffffc02003ca:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02003cc:	f97ff0ef          	jal	ffffffffc0200362 <print_stackframe>
    return 0;
}
ffffffffc02003d0:	60a2                	ld	ra,8(sp)
ffffffffc02003d2:	4501                	li	a0,0
ffffffffc02003d4:	0141                	addi	sp,sp,16
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <kmonitor>:
{
ffffffffc02003d8:	7131                	addi	sp,sp,-192
ffffffffc02003da:	e952                	sd	s4,144(sp)
ffffffffc02003dc:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003de:	00005517          	auipc	a0,0x5
ffffffffc02003e2:	69a50513          	addi	a0,a0,1690 # ffffffffc0205a78 <etext+0x188>
{
ffffffffc02003e6:	fd06                	sd	ra,184(sp)
ffffffffc02003e8:	f922                	sd	s0,176(sp)
ffffffffc02003ea:	f526                	sd	s1,168(sp)
ffffffffc02003ec:	ed4e                	sd	s3,152(sp)
ffffffffc02003ee:	e556                	sd	s5,136(sp)
ffffffffc02003f0:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02003f2:	cedff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02003f6:	00005517          	auipc	a0,0x5
ffffffffc02003fa:	6aa50513          	addi	a0,a0,1706 # ffffffffc0205aa0 <etext+0x1b0>
ffffffffc02003fe:	ce1ff0ef          	jal	ffffffffc02000de <cprintf>
    if (tf != NULL)
ffffffffc0200402:	000a0563          	beqz	s4,ffffffffc020040c <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc0200406:	8552                	mv	a0,s4
ffffffffc0200408:	6f0000ef          	jal	ffffffffc0200af8 <print_trapframe>
ffffffffc020040c:	00007a97          	auipc	s5,0x7
ffffffffc0200410:	224a8a93          	addi	s5,s5,548 # ffffffffc0207630 <commands>
        if (argc == MAXARGS - 1)
ffffffffc0200414:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL)
ffffffffc0200416:	00005517          	auipc	a0,0x5
ffffffffc020041a:	6b250513          	addi	a0,a0,1714 # ffffffffc0205ac8 <etext+0x1d8>
ffffffffc020041e:	d55ff0ef          	jal	ffffffffc0200172 <readline>
ffffffffc0200422:	842a                	mv	s0,a0
ffffffffc0200424:	d96d                	beqz	a0,ffffffffc0200416 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200426:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020042a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020042c:	e99d                	bnez	a1,ffffffffc0200462 <kmonitor+0x8a>
    int argc = 0;
ffffffffc020042e:	8b26                	mv	s6,s1
    if (argc == 0)
ffffffffc0200430:	fe0b03e3          	beqz	s6,ffffffffc0200416 <kmonitor+0x3e>
ffffffffc0200434:	00007497          	auipc	s1,0x7
ffffffffc0200438:	1fc48493          	addi	s1,s1,508 # ffffffffc0207630 <commands>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020043c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc020043e:	6582                	ld	a1,0(sp)
ffffffffc0200440:	6088                	ld	a0,0(s1)
ffffffffc0200442:	034050ef          	jal	ffffffffc0205476 <strcmp>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200446:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200448:	c149                	beqz	a0,ffffffffc02004ca <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020044a:	2405                	addiw	s0,s0,1
ffffffffc020044c:	04e1                	addi	s1,s1,24
ffffffffc020044e:	fef418e3          	bne	s0,a5,ffffffffc020043e <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200452:	6582                	ld	a1,0(sp)
ffffffffc0200454:	00005517          	auipc	a0,0x5
ffffffffc0200458:	6a450513          	addi	a0,a0,1700 # ffffffffc0205af8 <etext+0x208>
ffffffffc020045c:	c83ff0ef          	jal	ffffffffc02000de <cprintf>
    return 0;
ffffffffc0200460:	bf5d                	j	ffffffffc0200416 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200462:	00005517          	auipc	a0,0x5
ffffffffc0200466:	66e50513          	addi	a0,a0,1646 # ffffffffc0205ad0 <etext+0x1e0>
ffffffffc020046a:	068050ef          	jal	ffffffffc02054d2 <strchr>
ffffffffc020046e:	c901                	beqz	a0,ffffffffc020047e <kmonitor+0xa6>
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc0200474:	00040023          	sb	zero,0(s0)
ffffffffc0200478:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020047a:	d9d5                	beqz	a1,ffffffffc020042e <kmonitor+0x56>
ffffffffc020047c:	b7dd                	j	ffffffffc0200462 <kmonitor+0x8a>
        if (*buf == '\0')
ffffffffc020047e:	00044783          	lbu	a5,0(s0)
ffffffffc0200482:	d7d5                	beqz	a5,ffffffffc020042e <kmonitor+0x56>
        if (argc == MAXARGS - 1)
ffffffffc0200484:	03348b63          	beq	s1,s3,ffffffffc02004ba <kmonitor+0xe2>
        argv[argc++] = buf;
ffffffffc0200488:	00349793          	slli	a5,s1,0x3
ffffffffc020048c:	978a                	add	a5,a5,sp
ffffffffc020048e:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200490:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc0200494:	2485                	addiw	s1,s1,1
ffffffffc0200496:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc0200498:	e591                	bnez	a1,ffffffffc02004a4 <kmonitor+0xcc>
ffffffffc020049a:	bf59                	j	ffffffffc0200430 <kmonitor+0x58>
ffffffffc020049c:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc02004a0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02004a2:	d5d1                	beqz	a1,ffffffffc020042e <kmonitor+0x56>
ffffffffc02004a4:	00005517          	auipc	a0,0x5
ffffffffc02004a8:	62c50513          	addi	a0,a0,1580 # ffffffffc0205ad0 <etext+0x1e0>
ffffffffc02004ac:	026050ef          	jal	ffffffffc02054d2 <strchr>
ffffffffc02004b0:	d575                	beqz	a0,ffffffffc020049c <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02004b2:	00044583          	lbu	a1,0(s0)
ffffffffc02004b6:	dda5                	beqz	a1,ffffffffc020042e <kmonitor+0x56>
ffffffffc02004b8:	b76d                	j	ffffffffc0200462 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02004ba:	45c1                	li	a1,16
ffffffffc02004bc:	00005517          	auipc	a0,0x5
ffffffffc02004c0:	61c50513          	addi	a0,a0,1564 # ffffffffc0205ad8 <etext+0x1e8>
ffffffffc02004c4:	c1bff0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc02004c8:	b7c1                	j	ffffffffc0200488 <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02004ca:	00141793          	slli	a5,s0,0x1
ffffffffc02004ce:	97a2                	add	a5,a5,s0
ffffffffc02004d0:	078e                	slli	a5,a5,0x3
ffffffffc02004d2:	97d6                	add	a5,a5,s5
ffffffffc02004d4:	6b9c                	ld	a5,16(a5)
ffffffffc02004d6:	fffb051b          	addiw	a0,s6,-1
ffffffffc02004da:	8652                	mv	a2,s4
ffffffffc02004dc:	002c                	addi	a1,sp,8
ffffffffc02004de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc02004e0:	f2055be3          	bgez	a0,ffffffffc0200416 <kmonitor+0x3e>
}
ffffffffc02004e4:	70ea                	ld	ra,184(sp)
ffffffffc02004e6:	744a                	ld	s0,176(sp)
ffffffffc02004e8:	74aa                	ld	s1,168(sp)
ffffffffc02004ea:	69ea                	ld	s3,152(sp)
ffffffffc02004ec:	6a4a                	ld	s4,144(sp)
ffffffffc02004ee:	6aaa                	ld	s5,136(sp)
ffffffffc02004f0:	6b0a                	ld	s6,128(sp)
ffffffffc02004f2:	6129                	addi	sp,sp,192
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02004f6:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc02004f8:	00005517          	auipc	a0,0x5
ffffffffc02004fc:	6a850513          	addi	a0,a0,1704 # ffffffffc0205ba0 <etext+0x2b0>
void dtb_init(void) {
ffffffffc0200500:	f406                	sd	ra,40(sp)
ffffffffc0200502:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200504:	bdbff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200508:	0000b597          	auipc	a1,0xb
ffffffffc020050c:	af85b583          	ld	a1,-1288(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc0200510:	00005517          	auipc	a0,0x5
ffffffffc0200514:	6a050513          	addi	a0,a0,1696 # ffffffffc0205bb0 <etext+0x2c0>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200518:	0000b417          	auipc	s0,0xb
ffffffffc020051c:	af040413          	addi	s0,s0,-1296 # ffffffffc020b008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200520:	bbfff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200524:	600c                	ld	a1,0(s0)
ffffffffc0200526:	00005517          	auipc	a0,0x5
ffffffffc020052a:	69a50513          	addi	a0,a0,1690 # ffffffffc0205bc0 <etext+0x2d0>
ffffffffc020052e:	bb1ff0ef          	jal	ffffffffc02000de <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200532:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200534:	00005517          	auipc	a0,0x5
ffffffffc0200538:	6a450513          	addi	a0,a0,1700 # ffffffffc0205bd8 <etext+0x2e8>
    if (boot_dtb == 0) {
ffffffffc020053c:	10070163          	beqz	a4,ffffffffc020063e <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200540:	57f5                	li	a5,-3
ffffffffc0200542:	07fa                	slli	a5,a5,0x1e
ffffffffc0200544:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200546:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc0200548:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020054c:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe38995>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200550:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200554:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200558:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020055c:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200560:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200564:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200566:	8e49                	or	a2,a2,a0
ffffffffc0200568:	0ff7f793          	zext.b	a5,a5
ffffffffc020056c:	8dd1                	or	a1,a1,a2
ffffffffc020056e:	07a2                	slli	a5,a5,0x8
ffffffffc0200570:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200572:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc0200576:	0cd59863          	bne	a1,a3,ffffffffc0200646 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020057a:	4710                	lw	a2,8(a4)
ffffffffc020057c:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020057e:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200580:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200584:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200588:	01865e1b          	srliw	t3,a2,0x18
ffffffffc020058c:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200590:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200594:	0186959b          	slliw	a1,a3,0x18
ffffffffc0200598:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020059c:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a0:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005a4:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02005a8:	01c56533          	or	a0,a0,t3
ffffffffc02005ac:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005b0:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005b4:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005b8:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005bc:	0ff6f693          	zext.b	a3,a3
ffffffffc02005c0:	8c49                	or	s0,s0,a0
ffffffffc02005c2:	0622                	slli	a2,a2,0x8
ffffffffc02005c4:	8fcd                	or	a5,a5,a1
ffffffffc02005c6:	06a2                	slli	a3,a3,0x8
ffffffffc02005c8:	8c51                	or	s0,s0,a2
ffffffffc02005ca:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005cc:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005ce:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005d0:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005d2:	9381                	srli	a5,a5,0x20
ffffffffc02005d4:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc02005d6:	4301                	li	t1,0
        switch (token) {
ffffffffc02005d8:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005da:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005dc:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc02005e0:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005e2:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e4:	0087579b          	srliw	a5,a4,0x8
ffffffffc02005e8:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ec:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f0:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005f4:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005f8:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005fc:	8ed1                	or	a3,a3,a2
ffffffffc02005fe:	0ff77713          	zext.b	a4,a4
ffffffffc0200602:	8fd5                	or	a5,a5,a3
ffffffffc0200604:	0722                	slli	a4,a4,0x8
ffffffffc0200606:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc0200608:	05178763          	beq	a5,a7,ffffffffc0200656 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020060c:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc020060e:	00f8e963          	bltu	a7,a5,ffffffffc0200620 <dtb_init+0x12a>
ffffffffc0200612:	07c78d63          	beq	a5,t3,ffffffffc020068c <dtb_init+0x196>
ffffffffc0200616:	4709                	li	a4,2
ffffffffc0200618:	00e79763          	bne	a5,a4,ffffffffc0200626 <dtb_init+0x130>
ffffffffc020061c:	4301                	li	t1,0
ffffffffc020061e:	b7d1                	j	ffffffffc02005e2 <dtb_init+0xec>
ffffffffc0200620:	4711                	li	a4,4
ffffffffc0200622:	fce780e3          	beq	a5,a4,ffffffffc02005e2 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200626:	00005517          	auipc	a0,0x5
ffffffffc020062a:	67a50513          	addi	a0,a0,1658 # ffffffffc0205ca0 <etext+0x3b0>
ffffffffc020062e:	ab1ff0ef          	jal	ffffffffc02000de <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200632:	64e2                	ld	s1,24(sp)
ffffffffc0200634:	6942                	ld	s2,16(sp)
ffffffffc0200636:	00005517          	auipc	a0,0x5
ffffffffc020063a:	6a250513          	addi	a0,a0,1698 # ffffffffc0205cd8 <etext+0x3e8>
}
ffffffffc020063e:	7402                	ld	s0,32(sp)
ffffffffc0200640:	70a2                	ld	ra,40(sp)
ffffffffc0200642:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200644:	bc69                	j	ffffffffc02000de <cprintf>
}
ffffffffc0200646:	7402                	ld	s0,32(sp)
ffffffffc0200648:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020064a:	00005517          	auipc	a0,0x5
ffffffffc020064e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0205bf8 <etext+0x308>
}
ffffffffc0200652:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200654:	b469                	j	ffffffffc02000de <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200656:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200658:	0087579b          	srliw	a5,a4,0x8
ffffffffc020065c:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200660:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200664:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200668:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066c:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200670:	8ed1                	or	a3,a3,a2
ffffffffc0200672:	0ff77713          	zext.b	a4,a4
ffffffffc0200676:	8fd5                	or	a5,a5,a3
ffffffffc0200678:	0722                	slli	a4,a4,0x8
ffffffffc020067a:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020067c:	04031463          	bnez	t1,ffffffffc02006c4 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200680:	1782                	slli	a5,a5,0x20
ffffffffc0200682:	9381                	srli	a5,a5,0x20
ffffffffc0200684:	043d                	addi	s0,s0,15
ffffffffc0200686:	943e                	add	s0,s0,a5
ffffffffc0200688:	9871                	andi	s0,s0,-4
                break;
ffffffffc020068a:	bfa1                	j	ffffffffc02005e2 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc020068c:	8522                	mv	a0,s0
ffffffffc020068e:	e01a                	sd	t1,0(sp)
ffffffffc0200690:	5a1040ef          	jal	ffffffffc0205430 <strlen>
ffffffffc0200694:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200696:	4619                	li	a2,6
ffffffffc0200698:	8522                	mv	a0,s0
ffffffffc020069a:	00005597          	auipc	a1,0x5
ffffffffc020069e:	58658593          	addi	a1,a1,1414 # ffffffffc0205c20 <etext+0x330>
ffffffffc02006a2:	609040ef          	jal	ffffffffc02054aa <strncmp>
ffffffffc02006a6:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006a8:	0411                	addi	s0,s0,4
ffffffffc02006aa:	0004879b          	sext.w	a5,s1
ffffffffc02006ae:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006b0:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006b4:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006b6:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02006ba:	00ff0837          	lui	a6,0xff0
ffffffffc02006be:	488d                	li	a7,3
ffffffffc02006c0:	4e05                	li	t3,1
ffffffffc02006c2:	b705                	j	ffffffffc02005e2 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006c4:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006c6:	00005597          	auipc	a1,0x5
ffffffffc02006ca:	56258593          	addi	a1,a1,1378 # ffffffffc0205c28 <etext+0x338>
ffffffffc02006ce:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d0:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006d4:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006d8:	0187169b          	slliw	a3,a4,0x18
ffffffffc02006dc:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e0:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006e4:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e8:	8ed1                	or	a3,a3,a2
ffffffffc02006ea:	0ff77713          	zext.b	a4,a4
ffffffffc02006ee:	0722                	slli	a4,a4,0x8
ffffffffc02006f0:	8d55                	or	a0,a0,a3
ffffffffc02006f2:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02006f4:	1502                	slli	a0,a0,0x20
ffffffffc02006f6:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f8:	954a                	add	a0,a0,s2
ffffffffc02006fa:	e01a                	sd	t1,0(sp)
ffffffffc02006fc:	57b040ef          	jal	ffffffffc0205476 <strcmp>
ffffffffc0200700:	67a2                	ld	a5,8(sp)
ffffffffc0200702:	473d                	li	a4,15
ffffffffc0200704:	6302                	ld	t1,0(sp)
ffffffffc0200706:	00ff0837          	lui	a6,0xff0
ffffffffc020070a:	488d                	li	a7,3
ffffffffc020070c:	4e05                	li	t3,1
ffffffffc020070e:	f6f779e3          	bgeu	a4,a5,ffffffffc0200680 <dtb_init+0x18a>
ffffffffc0200712:	f53d                	bnez	a0,ffffffffc0200680 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200714:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200718:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020071c:	00005517          	auipc	a0,0x5
ffffffffc0200720:	51450513          	addi	a0,a0,1300 # ffffffffc0205c30 <etext+0x340>
           fdt32_to_cpu(x >> 32);
ffffffffc0200724:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200728:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020072c:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200730:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200734:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200738:	0187959b          	slliw	a1,a5,0x18
ffffffffc020073c:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200740:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200744:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200748:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020074c:	01037333          	and	t1,t1,a6
ffffffffc0200750:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200754:	01e5e5b3          	or	a1,a1,t5
ffffffffc0200758:	0ff7f793          	zext.b	a5,a5
ffffffffc020075c:	01de6e33          	or	t3,t3,t4
ffffffffc0200760:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200764:	01067633          	and	a2,a2,a6
ffffffffc0200768:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020076c:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200770:	07a2                	slli	a5,a5,0x8
ffffffffc0200772:	0108d89b          	srliw	a7,a7,0x10
ffffffffc0200776:	0186df1b          	srliw	t5,a3,0x18
ffffffffc020077a:	01875e9b          	srliw	t4,a4,0x18
ffffffffc020077e:	8ddd                	or	a1,a1,a5
ffffffffc0200780:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200784:	0186979b          	slliw	a5,a3,0x18
ffffffffc0200788:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020078c:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200790:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200794:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200798:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020079c:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007a0:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a4:	08a2                	slli	a7,a7,0x8
ffffffffc02007a6:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007aa:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007ae:	0ff6f693          	zext.b	a3,a3
ffffffffc02007b2:	01de6833          	or	a6,t3,t4
ffffffffc02007b6:	0ff77713          	zext.b	a4,a4
ffffffffc02007ba:	01166633          	or	a2,a2,a7
ffffffffc02007be:	0067e7b3          	or	a5,a5,t1
ffffffffc02007c2:	06a2                	slli	a3,a3,0x8
ffffffffc02007c4:	01046433          	or	s0,s0,a6
ffffffffc02007c8:	0722                	slli	a4,a4,0x8
ffffffffc02007ca:	8fd5                	or	a5,a5,a3
ffffffffc02007cc:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc02007ce:	1582                	slli	a1,a1,0x20
ffffffffc02007d0:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007d2:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc02007d4:	9201                	srli	a2,a2,0x20
ffffffffc02007d6:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc02007d8:	1402                	slli	s0,s0,0x20
ffffffffc02007da:	00b7e4b3          	or	s1,a5,a1
ffffffffc02007de:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007e0:	8ffff0ef          	jal	ffffffffc02000de <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02007e4:	85a6                	mv	a1,s1
ffffffffc02007e6:	00005517          	auipc	a0,0x5
ffffffffc02007ea:	46a50513          	addi	a0,a0,1130 # ffffffffc0205c50 <etext+0x360>
ffffffffc02007ee:	8f1ff0ef          	jal	ffffffffc02000de <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02007f2:	01445613          	srli	a2,s0,0x14
ffffffffc02007f6:	85a2                	mv	a1,s0
ffffffffc02007f8:	00005517          	auipc	a0,0x5
ffffffffc02007fc:	47050513          	addi	a0,a0,1136 # ffffffffc0205c68 <etext+0x378>
ffffffffc0200800:	8dfff0ef          	jal	ffffffffc02000de <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200804:	009405b3          	add	a1,s0,s1
ffffffffc0200808:	15fd                	addi	a1,a1,-1
ffffffffc020080a:	00005517          	auipc	a0,0x5
ffffffffc020080e:	47e50513          	addi	a0,a0,1150 # ffffffffc0205c88 <etext+0x398>
ffffffffc0200812:	8cdff0ef          	jal	ffffffffc02000de <cprintf>
        memory_base = mem_base;
ffffffffc0200816:	000a7797          	auipc	a5,0xa7
ffffffffc020081a:	cc97b523          	sd	s1,-822(a5) # ffffffffc02a74e0 <memory_base>
        memory_size = mem_size;
ffffffffc020081e:	000a7797          	auipc	a5,0xa7
ffffffffc0200822:	ca87bd23          	sd	s0,-838(a5) # ffffffffc02a74d8 <memory_size>
ffffffffc0200826:	b531                	j	ffffffffc0200632 <dtb_init+0x13c>

ffffffffc0200828 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc0200828:	000a7517          	auipc	a0,0xa7
ffffffffc020082c:	cb853503          	ld	a0,-840(a0) # ffffffffc02a74e0 <memory_base>
ffffffffc0200830:	8082                	ret

ffffffffc0200832 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc0200832:	000a7517          	auipc	a0,0xa7
ffffffffc0200836:	ca653503          	ld	a0,-858(a0) # ffffffffc02a74d8 <memory_size>
ffffffffc020083a:	8082                	ret

ffffffffc020083c <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020083c:	67e1                	lui	a5,0x18
ffffffffc020083e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_cowtest_out_size+0xc4a8>
ffffffffc0200842:	000a7717          	auipc	a4,0xa7
ffffffffc0200846:	caf73323          	sd	a5,-858(a4) # ffffffffc02a74e8 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020084a:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020084e:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200850:	953e                	add	a0,a0,a5
ffffffffc0200852:	4601                	li	a2,0
ffffffffc0200854:	4881                	li	a7,0
ffffffffc0200856:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020085a:	02000793          	li	a5,32
ffffffffc020085e:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200862:	00005517          	auipc	a0,0x5
ffffffffc0200866:	48e50513          	addi	a0,a0,1166 # ffffffffc0205cf0 <etext+0x400>
    ticks = 0;
ffffffffc020086a:	000a7797          	auipc	a5,0xa7
ffffffffc020086e:	c807b323          	sd	zero,-890(a5) # ffffffffc02a74f0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200872:	86dff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200876 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200876:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020087a:	000a7797          	auipc	a5,0xa7
ffffffffc020087e:	c6e7b783          	ld	a5,-914(a5) # ffffffffc02a74e8 <timebase>
ffffffffc0200882:	4581                	li	a1,0
ffffffffc0200884:	4601                	li	a2,0
ffffffffc0200886:	953e                	add	a0,a0,a5
ffffffffc0200888:	4881                	li	a7,0
ffffffffc020088a:	00000073          	ecall
ffffffffc020088e:	8082                	ret

ffffffffc0200890 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200890:	8082                	ret

ffffffffc0200892 <cons_putc>:
#include <assert.h>

// __intr_save - 保存中断状态，如果中断开启则关闭并返回1
static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0200892:	100027f3          	csrr	a5,sstatus
ffffffffc0200896:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200898:	0ff57513          	zext.b	a0,a0
ffffffffc020089c:	e799                	bnez	a5,ffffffffc02008aa <cons_putc+0x18>
ffffffffc020089e:	4581                	li	a1,0
ffffffffc02008a0:	4601                	li	a2,0
ffffffffc02008a2:	4885                	li	a7,1
ffffffffc02008a4:	00000073          	ecall
}

// __intr_restore - 根据保存的状态恢复中断
static inline void __intr_restore(bool flag)
{
    if (flag)           // 如果原来中断是开启的
ffffffffc02008a8:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02008aa:	1101                	addi	sp,sp,-32
ffffffffc02008ac:	ec06                	sd	ra,24(sp)
ffffffffc02008ae:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc02008b0:	05a000ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc02008b4:	6522                	ld	a0,8(sp)
ffffffffc02008b6:	4581                	li	a1,0
ffffffffc02008b8:	4601                	li	a2,0
ffffffffc02008ba:	4885                	li	a7,1
ffffffffc02008bc:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02008c0:	60e2                	ld	ra,24(sp)
ffffffffc02008c2:	6105                	addi	sp,sp,32
    {
        intr_enable();  // 重新开启中断
ffffffffc02008c4:	a081                	j	ffffffffc0200904 <intr_enable>

ffffffffc02008c6 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02008c6:	100027f3          	csrr	a5,sstatus
ffffffffc02008ca:	8b89                	andi	a5,a5,2
ffffffffc02008cc:	eb89                	bnez	a5,ffffffffc02008de <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02008ce:	4501                	li	a0,0
ffffffffc02008d0:	4581                	li	a1,0
ffffffffc02008d2:	4601                	li	a2,0
ffffffffc02008d4:	4889                	li	a7,2
ffffffffc02008d6:	00000073          	ecall
ffffffffc02008da:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02008dc:	8082                	ret
int cons_getc(void) {
ffffffffc02008de:	1101                	addi	sp,sp,-32
ffffffffc02008e0:	ec06                	sd	ra,24(sp)
        intr_disable();  // 关闭中断
ffffffffc02008e2:	028000ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc02008e6:	4501                	li	a0,0
ffffffffc02008e8:	4581                	li	a1,0
ffffffffc02008ea:	4601                	li	a2,0
ffffffffc02008ec:	4889                	li	a7,2
ffffffffc02008ee:	00000073          	ecall
ffffffffc02008f2:	2501                	sext.w	a0,a0
ffffffffc02008f4:	e42a                	sd	a0,8(sp)
        intr_enable();  // 重新开启中断
ffffffffc02008f6:	00e000ef          	jal	ffffffffc0200904 <intr_enable>
}
ffffffffc02008fa:	60e2                	ld	ra,24(sp)
ffffffffc02008fc:	6522                	ld	a0,8(sp)
ffffffffc02008fe:	6105                	addi	sp,sp,32
ffffffffc0200900:	8082                	ret

ffffffffc0200902 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200902:	8082                	ret

ffffffffc0200904 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200904:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200908:	8082                	ret

ffffffffc020090a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020090a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020090e:	8082                	ret

ffffffffc0200910 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200910:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200914:	00000797          	auipc	a5,0x0
ffffffffc0200918:	6bc78793          	addi	a5,a5,1724 # ffffffffc0200fd0 <__alltraps>
ffffffffc020091c:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200920:	000407b7          	lui	a5,0x40
ffffffffc0200924:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200928:	8082                	ret

ffffffffc020092a <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020092a:	610c                	ld	a1,0(a0)
{
ffffffffc020092c:	1141                	addi	sp,sp,-16
ffffffffc020092e:	e022                	sd	s0,0(sp)
ffffffffc0200930:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200932:	00005517          	auipc	a0,0x5
ffffffffc0200936:	3de50513          	addi	a0,a0,990 # ffffffffc0205d10 <etext+0x420>
{
ffffffffc020093a:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020093c:	fa2ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200940:	640c                	ld	a1,8(s0)
ffffffffc0200942:	00005517          	auipc	a0,0x5
ffffffffc0200946:	3e650513          	addi	a0,a0,998 # ffffffffc0205d28 <etext+0x438>
ffffffffc020094a:	f94ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020094e:	680c                	ld	a1,16(s0)
ffffffffc0200950:	00005517          	auipc	a0,0x5
ffffffffc0200954:	3f050513          	addi	a0,a0,1008 # ffffffffc0205d40 <etext+0x450>
ffffffffc0200958:	f86ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020095c:	6c0c                	ld	a1,24(s0)
ffffffffc020095e:	00005517          	auipc	a0,0x5
ffffffffc0200962:	3fa50513          	addi	a0,a0,1018 # ffffffffc0205d58 <etext+0x468>
ffffffffc0200966:	f78ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020096a:	700c                	ld	a1,32(s0)
ffffffffc020096c:	00005517          	auipc	a0,0x5
ffffffffc0200970:	40450513          	addi	a0,a0,1028 # ffffffffc0205d70 <etext+0x480>
ffffffffc0200974:	f6aff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200978:	740c                	ld	a1,40(s0)
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	40e50513          	addi	a0,a0,1038 # ffffffffc0205d88 <etext+0x498>
ffffffffc0200982:	f5cff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200986:	780c                	ld	a1,48(s0)
ffffffffc0200988:	00005517          	auipc	a0,0x5
ffffffffc020098c:	41850513          	addi	a0,a0,1048 # ffffffffc0205da0 <etext+0x4b0>
ffffffffc0200990:	f4eff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200994:	7c0c                	ld	a1,56(s0)
ffffffffc0200996:	00005517          	auipc	a0,0x5
ffffffffc020099a:	42250513          	addi	a0,a0,1058 # ffffffffc0205db8 <etext+0x4c8>
ffffffffc020099e:	f40ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02009a2:	602c                	ld	a1,64(s0)
ffffffffc02009a4:	00005517          	auipc	a0,0x5
ffffffffc02009a8:	42c50513          	addi	a0,a0,1068 # ffffffffc0205dd0 <etext+0x4e0>
ffffffffc02009ac:	f32ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009b0:	642c                	ld	a1,72(s0)
ffffffffc02009b2:	00005517          	auipc	a0,0x5
ffffffffc02009b6:	43650513          	addi	a0,a0,1078 # ffffffffc0205de8 <etext+0x4f8>
ffffffffc02009ba:	f24ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009be:	682c                	ld	a1,80(s0)
ffffffffc02009c0:	00005517          	auipc	a0,0x5
ffffffffc02009c4:	44050513          	addi	a0,a0,1088 # ffffffffc0205e00 <etext+0x510>
ffffffffc02009c8:	f16ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009cc:	6c2c                	ld	a1,88(s0)
ffffffffc02009ce:	00005517          	auipc	a0,0x5
ffffffffc02009d2:	44a50513          	addi	a0,a0,1098 # ffffffffc0205e18 <etext+0x528>
ffffffffc02009d6:	f08ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009da:	702c                	ld	a1,96(s0)
ffffffffc02009dc:	00005517          	auipc	a0,0x5
ffffffffc02009e0:	45450513          	addi	a0,a0,1108 # ffffffffc0205e30 <etext+0x540>
ffffffffc02009e4:	efaff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009e8:	742c                	ld	a1,104(s0)
ffffffffc02009ea:	00005517          	auipc	a0,0x5
ffffffffc02009ee:	45e50513          	addi	a0,a0,1118 # ffffffffc0205e48 <etext+0x558>
ffffffffc02009f2:	eecff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009f6:	782c                	ld	a1,112(s0)
ffffffffc02009f8:	00005517          	auipc	a0,0x5
ffffffffc02009fc:	46850513          	addi	a0,a0,1128 # ffffffffc0205e60 <etext+0x570>
ffffffffc0200a00:	edeff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a04:	7c2c                	ld	a1,120(s0)
ffffffffc0200a06:	00005517          	auipc	a0,0x5
ffffffffc0200a0a:	47250513          	addi	a0,a0,1138 # ffffffffc0205e78 <etext+0x588>
ffffffffc0200a0e:	ed0ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a12:	604c                	ld	a1,128(s0)
ffffffffc0200a14:	00005517          	auipc	a0,0x5
ffffffffc0200a18:	47c50513          	addi	a0,a0,1148 # ffffffffc0205e90 <etext+0x5a0>
ffffffffc0200a1c:	ec2ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a20:	644c                	ld	a1,136(s0)
ffffffffc0200a22:	00005517          	auipc	a0,0x5
ffffffffc0200a26:	48650513          	addi	a0,a0,1158 # ffffffffc0205ea8 <etext+0x5b8>
ffffffffc0200a2a:	eb4ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a2e:	684c                	ld	a1,144(s0)
ffffffffc0200a30:	00005517          	auipc	a0,0x5
ffffffffc0200a34:	49050513          	addi	a0,a0,1168 # ffffffffc0205ec0 <etext+0x5d0>
ffffffffc0200a38:	ea6ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a3c:	6c4c                	ld	a1,152(s0)
ffffffffc0200a3e:	00005517          	auipc	a0,0x5
ffffffffc0200a42:	49a50513          	addi	a0,a0,1178 # ffffffffc0205ed8 <etext+0x5e8>
ffffffffc0200a46:	e98ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a4a:	704c                	ld	a1,160(s0)
ffffffffc0200a4c:	00005517          	auipc	a0,0x5
ffffffffc0200a50:	4a450513          	addi	a0,a0,1188 # ffffffffc0205ef0 <etext+0x600>
ffffffffc0200a54:	e8aff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a58:	744c                	ld	a1,168(s0)
ffffffffc0200a5a:	00005517          	auipc	a0,0x5
ffffffffc0200a5e:	4ae50513          	addi	a0,a0,1198 # ffffffffc0205f08 <etext+0x618>
ffffffffc0200a62:	e7cff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a66:	784c                	ld	a1,176(s0)
ffffffffc0200a68:	00005517          	auipc	a0,0x5
ffffffffc0200a6c:	4b850513          	addi	a0,a0,1208 # ffffffffc0205f20 <etext+0x630>
ffffffffc0200a70:	e6eff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a74:	7c4c                	ld	a1,184(s0)
ffffffffc0200a76:	00005517          	auipc	a0,0x5
ffffffffc0200a7a:	4c250513          	addi	a0,a0,1218 # ffffffffc0205f38 <etext+0x648>
ffffffffc0200a7e:	e60ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a82:	606c                	ld	a1,192(s0)
ffffffffc0200a84:	00005517          	auipc	a0,0x5
ffffffffc0200a88:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205f50 <etext+0x660>
ffffffffc0200a8c:	e52ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a90:	646c                	ld	a1,200(s0)
ffffffffc0200a92:	00005517          	auipc	a0,0x5
ffffffffc0200a96:	4d650513          	addi	a0,a0,1238 # ffffffffc0205f68 <etext+0x678>
ffffffffc0200a9a:	e44ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a9e:	686c                	ld	a1,208(s0)
ffffffffc0200aa0:	00005517          	auipc	a0,0x5
ffffffffc0200aa4:	4e050513          	addi	a0,a0,1248 # ffffffffc0205f80 <etext+0x690>
ffffffffc0200aa8:	e36ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aac:	6c6c                	ld	a1,216(s0)
ffffffffc0200aae:	00005517          	auipc	a0,0x5
ffffffffc0200ab2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0205f98 <etext+0x6a8>
ffffffffc0200ab6:	e28ff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200aba:	706c                	ld	a1,224(s0)
ffffffffc0200abc:	00005517          	auipc	a0,0x5
ffffffffc0200ac0:	4f450513          	addi	a0,a0,1268 # ffffffffc0205fb0 <etext+0x6c0>
ffffffffc0200ac4:	e1aff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200ac8:	746c                	ld	a1,232(s0)
ffffffffc0200aca:	00005517          	auipc	a0,0x5
ffffffffc0200ace:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205fc8 <etext+0x6d8>
ffffffffc0200ad2:	e0cff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200ad6:	786c                	ld	a1,240(s0)
ffffffffc0200ad8:	00005517          	auipc	a0,0x5
ffffffffc0200adc:	50850513          	addi	a0,a0,1288 # ffffffffc0205fe0 <etext+0x6f0>
ffffffffc0200ae0:	dfeff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae4:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200ae6:	6402                	ld	s0,0(sp)
ffffffffc0200ae8:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200aea:	00005517          	auipc	a0,0x5
ffffffffc0200aee:	50e50513          	addi	a0,a0,1294 # ffffffffc0205ff8 <etext+0x708>
}
ffffffffc0200af2:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200af4:	deaff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200af8 <print_trapframe>:
{
ffffffffc0200af8:	1141                	addi	sp,sp,-16
ffffffffc0200afa:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200afc:	85aa                	mv	a1,a0
{
ffffffffc0200afe:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b00:	00005517          	auipc	a0,0x5
ffffffffc0200b04:	51050513          	addi	a0,a0,1296 # ffffffffc0206010 <etext+0x720>
{
ffffffffc0200b08:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b0a:	dd4ff0ef          	jal	ffffffffc02000de <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b0e:	8522                	mv	a0,s0
ffffffffc0200b10:	e1bff0ef          	jal	ffffffffc020092a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b14:	10043583          	ld	a1,256(s0)
ffffffffc0200b18:	00005517          	auipc	a0,0x5
ffffffffc0200b1c:	51050513          	addi	a0,a0,1296 # ffffffffc0206028 <etext+0x738>
ffffffffc0200b20:	dbeff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b24:	10843583          	ld	a1,264(s0)
ffffffffc0200b28:	00005517          	auipc	a0,0x5
ffffffffc0200b2c:	51850513          	addi	a0,a0,1304 # ffffffffc0206040 <etext+0x750>
ffffffffc0200b30:	daeff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b34:	11043583          	ld	a1,272(s0)
ffffffffc0200b38:	00005517          	auipc	a0,0x5
ffffffffc0200b3c:	52050513          	addi	a0,a0,1312 # ffffffffc0206058 <etext+0x768>
ffffffffc0200b40:	d9eff0ef          	jal	ffffffffc02000de <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b44:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b48:	6402                	ld	s0,0(sp)
ffffffffc0200b4a:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b4c:	00005517          	auipc	a0,0x5
ffffffffc0200b50:	51c50513          	addi	a0,a0,1308 # ffffffffc0206068 <etext+0x778>
}
ffffffffc0200b54:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b56:	d88ff06f          	j	ffffffffc02000de <cprintf>

ffffffffc0200b5a <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200b5a:	11853783          	ld	a5,280(a0)
ffffffffc0200b5e:	472d                	li	a4,11
ffffffffc0200b60:	0786                	slli	a5,a5,0x1
ffffffffc0200b62:	8385                	srli	a5,a5,0x1
ffffffffc0200b64:	0cf76063          	bltu	a4,a5,ffffffffc0200c24 <interrupt_handler+0xca>
ffffffffc0200b68:	00007717          	auipc	a4,0x7
ffffffffc0200b6c:	b1070713          	addi	a4,a4,-1264 # ffffffffc0207678 <commands+0x48>
ffffffffc0200b70:	078a                	slli	a5,a5,0x2
ffffffffc0200b72:	97ba                	add	a5,a5,a4
ffffffffc0200b74:	439c                	lw	a5,0(a5)
ffffffffc0200b76:	97ba                	add	a5,a5,a4
ffffffffc0200b78:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200b7a:	00005517          	auipc	a0,0x5
ffffffffc0200b7e:	56650513          	addi	a0,a0,1382 # ffffffffc02060e0 <etext+0x7f0>
ffffffffc0200b82:	d5cff06f          	j	ffffffffc02000de <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b86:	00005517          	auipc	a0,0x5
ffffffffc0200b8a:	53a50513          	addi	a0,a0,1338 # ffffffffc02060c0 <etext+0x7d0>
ffffffffc0200b8e:	d50ff06f          	j	ffffffffc02000de <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b92:	00005517          	auipc	a0,0x5
ffffffffc0200b96:	4ee50513          	addi	a0,a0,1262 # ffffffffc0206080 <etext+0x790>
ffffffffc0200b9a:	d44ff06f          	j	ffffffffc02000de <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b9e:	00005517          	auipc	a0,0x5
ffffffffc0200ba2:	50250513          	addi	a0,a0,1282 # ffffffffc02060a0 <etext+0x7b0>
ffffffffc0200ba6:	d38ff06f          	j	ffffffffc02000de <cprintf>
{
ffffffffc0200baa:	1141                	addi	sp,sp,-16
ffffffffc0200bac:	e406                	sd	ra,8(sp)
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();
ffffffffc0200bae:	cc9ff0ef          	jal	ffffffffc0200876 <clock_set_next_event>
        ticks++;
ffffffffc0200bb2:	000a7797          	auipc	a5,0xa7
ffffffffc0200bb6:	93e78793          	addi	a5,a5,-1730 # ffffffffc02a74f0 <ticks>
ffffffffc0200bba:	6394                	ld	a3,0(a5)
        if (ticks % 100 == 0) {
ffffffffc0200bbc:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200bc0:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_cowtest_out_size+0x28f50097>
        ticks++;
ffffffffc0200bc4:	0685                	addi	a3,a3,1
ffffffffc0200bc6:	e394                	sd	a3,0(a5)
        if (ticks % 100 == 0) {
ffffffffc0200bc8:	6390                	ld	a2,0(a5)
ffffffffc0200bca:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200bce:	1702                	slli	a4,a4,0x20
ffffffffc0200bd0:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <_binary_obj___user_cowtest_out_size+0x5c2833cb>
ffffffffc0200bd4:	00265793          	srli	a5,a2,0x2
ffffffffc0200bd8:	9736                	add	a4,a4,a3
ffffffffc0200bda:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200bde:	06400593          	li	a1,100
ffffffffc0200be2:	8389                	srli	a5,a5,0x2
ffffffffc0200be4:	02b787b3          	mul	a5,a5,a1
ffffffffc0200be8:	02f60f63          	beq	a2,a5,ffffffffc0200c26 <interrupt_handler+0xcc>
            cprintf("100 ticks\n");
            num++;
            print_ticks();
        }
        current->need_resched = 1;
ffffffffc0200bec:	000a7797          	auipc	a5,0xa7
ffffffffc0200bf0:	9547b783          	ld	a5,-1708(a5) # ffffffffc02a7540 <current>
        if (num == 10) {
ffffffffc0200bf4:	000a7717          	auipc	a4,0xa7
ffffffffc0200bf8:	90472703          	lw	a4,-1788(a4) # ffffffffc02a74f8 <num>
        current->need_resched = 1;
ffffffffc0200bfc:	4685                	li	a3,1
ffffffffc0200bfe:	ef94                	sd	a3,24(a5)
        if (num == 10) {
ffffffffc0200c00:	47a9                	li	a5,10
ffffffffc0200c02:	00f71863          	bne	a4,a5,ffffffffc0200c12 <interrupt_handler+0xb8>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200c06:	4501                	li	a0,0
ffffffffc0200c08:	4581                	li	a1,0
ffffffffc0200c0a:	4601                	li	a2,0
ffffffffc0200c0c:	48a1                	li	a7,8
ffffffffc0200c0e:	00000073          	ecall
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c12:	60a2                	ld	ra,8(sp)
ffffffffc0200c14:	0141                	addi	sp,sp,16
ffffffffc0200c16:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c18:	00005517          	auipc	a0,0x5
ffffffffc0200c1c:	50850513          	addi	a0,a0,1288 # ffffffffc0206120 <etext+0x830>
ffffffffc0200c20:	cbeff06f          	j	ffffffffc02000de <cprintf>
        print_trapframe(tf);
ffffffffc0200c24:	bdd1                	j	ffffffffc0200af8 <print_trapframe>
            cprintf("100 ticks\n");
ffffffffc0200c26:	00005517          	auipc	a0,0x5
ffffffffc0200c2a:	4da50513          	addi	a0,a0,1242 # ffffffffc0206100 <etext+0x810>
ffffffffc0200c2e:	cb0ff0ef          	jal	ffffffffc02000de <cprintf>
            num++;
ffffffffc0200c32:	000a7797          	auipc	a5,0xa7
ffffffffc0200c36:	8c67a783          	lw	a5,-1850(a5) # ffffffffc02a74f8 <num>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c3a:	06400593          	li	a1,100
ffffffffc0200c3e:	00005517          	auipc	a0,0x5
ffffffffc0200c42:	4d250513          	addi	a0,a0,1234 # ffffffffc0206110 <etext+0x820>
            num++;
ffffffffc0200c46:	2785                	addiw	a5,a5,1
ffffffffc0200c48:	000a7717          	auipc	a4,0xa7
ffffffffc0200c4c:	8af72823          	sw	a5,-1872(a4) # ffffffffc02a74f8 <num>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c50:	c8eff0ef          	jal	ffffffffc02000de <cprintf>
}
ffffffffc0200c54:	bf61                	j	ffffffffc0200bec <interrupt_handler+0x92>

ffffffffc0200c56 <exception_handler>:
// exception_handler - 异常处理分发器，根据异常原因调用相应处理
// tf: trapframe指针，包含异常发生时的完整上下文信息
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)  // 根据异常原因(scause寄存器)进行分发
ffffffffc0200c56:	11853783          	ld	a5,280(a0)
ffffffffc0200c5a:	473d                	li	a4,15
ffffffffc0200c5c:	24f76563          	bltu	a4,a5,ffffffffc0200ea6 <exception_handler+0x250>
ffffffffc0200c60:	00007717          	auipc	a4,0x7
ffffffffc0200c64:	a4870713          	addi	a4,a4,-1464 # ffffffffc02076a8 <commands+0x78>
ffffffffc0200c68:	078a                	slli	a5,a5,0x2
ffffffffc0200c6a:	97ba                	add	a5,a5,a4
ffffffffc0200c6c:	439c                	lw	a5,0(a5)
{
ffffffffc0200c6e:	7179                	addi	sp,sp,-48
ffffffffc0200c70:	f406                	sd	ra,40(sp)
    switch (tf->cause)  // 根据异常原因(scause寄存器)进行分发
ffffffffc0200c72:	97ba                	add	a5,a5,a4
ffffffffc0200c74:	86aa                	mv	a3,a0
ffffffffc0200c76:	8782                	jr	a5
ffffffffc0200c78:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c7a:	00005517          	auipc	a0,0x5
ffffffffc0200c7e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206228 <etext+0x938>
ffffffffc0200c82:	c5cff0ef          	jal	ffffffffc02000de <cprintf>
        tf->epc += 4;
ffffffffc0200c86:	66a2                	ld	a3,8(sp)
ffffffffc0200c88:	1086b783          	ld	a5,264(a3)
    }
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c8c:	70a2                	ld	ra,40(sp)
        tf->epc += 4;
ffffffffc0200c8e:	0791                	addi	a5,a5,4
ffffffffc0200c90:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c94:	6145                	addi	sp,sp,48
        syscall();
ffffffffc0200c96:	71e0406f          	j	ffffffffc02053b4 <syscall>
}
ffffffffc0200c9a:	70a2                	ld	ra,40(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c9c:	00005517          	auipc	a0,0x5
ffffffffc0200ca0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206248 <etext+0x958>
}
ffffffffc0200ca4:	6145                	addi	sp,sp,48
        cprintf("Environment call from H-mode\n");
ffffffffc0200ca6:	c38ff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200caa:	70a2                	ld	ra,40(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200cac:	00005517          	auipc	a0,0x5
ffffffffc0200cb0:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206268 <etext+0x978>
}
ffffffffc0200cb4:	6145                	addi	sp,sp,48
        cprintf("Environment call from M-mode\n");
ffffffffc0200cb6:	c28ff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200cba:	70a2                	ld	ra,40(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200cbc:	00005517          	auipc	a0,0x5
ffffffffc0200cc0:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206288 <etext+0x998>
}
ffffffffc0200cc4:	6145                	addi	sp,sp,48
        cprintf("Instruction page fault\n");
ffffffffc0200cc6:	c18ff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200cca:	70a2                	ld	ra,40(sp)
        cprintf("Load page fault\n");
ffffffffc0200ccc:	00005517          	auipc	a0,0x5
ffffffffc0200cd0:	5d450513          	addi	a0,a0,1492 # ffffffffc02062a0 <etext+0x9b0>
}
ffffffffc0200cd4:	6145                	addi	sp,sp,48
        cprintf("Load page fault\n");
ffffffffc0200cd6:	c08ff06f          	j	ffffffffc02000de <cprintf>
        if (current != NULL && current->mm != NULL)
ffffffffc0200cda:	000a7797          	auipc	a5,0xa7
ffffffffc0200cde:	8667b783          	ld	a5,-1946(a5) # ffffffffc02a7540 <current>
ffffffffc0200ce2:	cb95                	beqz	a5,ffffffffc0200d16 <exception_handler+0xc0>
ffffffffc0200ce4:	779c                	ld	a5,40(a5)
ffffffffc0200ce6:	cb85                	beqz	a5,ffffffffc0200d16 <exception_handler+0xc0>
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200ce8:	11053683          	ld	a3,272(a0)
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200cec:	6f88                	ld	a0,24(a5)
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200cee:	77fd                	lui	a5,0xfffff
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200cf0:	00f6f5b3          	and	a1,a3,a5
ffffffffc0200cf4:	4601                	li	a2,0
ffffffffc0200cf6:	f022                	sd	s0,32(sp)
            uintptr_t va = ROUNDDOWN(tf->tval, PGSIZE);
ffffffffc0200cf8:	00f6f433          	and	s0,a3,a5
            pte_t *ptep = get_pte(current->mm->pgdir, va, 0);
ffffffffc0200cfc:	377010ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc0200d00:	87aa                	mv	a5,a0
            if (ptep != NULL && (*ptep & PTE_V) && (*ptep & PTE_COW))
ffffffffc0200d02:	c909                	beqz	a0,ffffffffc0200d14 <exception_handler+0xbe>
ffffffffc0200d04:	00053803          	ld	a6,0(a0)
ffffffffc0200d08:	20100693          	li	a3,513
ffffffffc0200d0c:	00d87633          	and	a2,a6,a3
ffffffffc0200d10:	0ad60a63          	beq	a2,a3,ffffffffc0200dc4 <exception_handler+0x16e>
ffffffffc0200d14:	7402                	ld	s0,32(sp)
}
ffffffffc0200d16:	70a2                	ld	ra,40(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200d18:	00005517          	auipc	a0,0x5
ffffffffc0200d1c:	62050513          	addi	a0,a0,1568 # ffffffffc0206338 <etext+0xa48>
}
ffffffffc0200d20:	6145                	addi	sp,sp,48
        cprintf("Store/AMO page fault\n");
ffffffffc0200d22:	bbcff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200d26:	70a2                	ld	ra,40(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200d28:	00005517          	auipc	a0,0x5
ffffffffc0200d2c:	41850513          	addi	a0,a0,1048 # ffffffffc0206140 <etext+0x850>
}
ffffffffc0200d30:	6145                	addi	sp,sp,48
        cprintf("Instruction address misaligned\n");
ffffffffc0200d32:	bacff06f          	j	ffffffffc02000de <cprintf>
ffffffffc0200d36:	e42a                	sd	a0,8(sp)
        cprintf("Breakpoint\n");
ffffffffc0200d38:	00005517          	auipc	a0,0x5
ffffffffc0200d3c:	46050513          	addi	a0,a0,1120 # ffffffffc0206198 <etext+0x8a8>
ffffffffc0200d40:	b9eff0ef          	jal	ffffffffc02000de <cprintf>
        if (tf->gpr.a7 == 10)        // 特殊标识，表示内核系统调用
ffffffffc0200d44:	66a2                	ld	a3,8(sp)
ffffffffc0200d46:	47a9                	li	a5,10
ffffffffc0200d48:	66d8                	ld	a4,136(a3)
ffffffffc0200d4a:	12f70c63          	beq	a4,a5,ffffffffc0200e82 <exception_handler+0x22c>
}
ffffffffc0200d4e:	70a2                	ld	ra,40(sp)
ffffffffc0200d50:	6145                	addi	sp,sp,48
ffffffffc0200d52:	8082                	ret
ffffffffc0200d54:	70a2                	ld	ra,40(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200d56:	00005517          	auipc	a0,0x5
ffffffffc0200d5a:	45250513          	addi	a0,a0,1106 # ffffffffc02061a8 <etext+0x8b8>
}
ffffffffc0200d5e:	6145                	addi	sp,sp,48
        cprintf("Load address misaligned\n");
ffffffffc0200d60:	b7eff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200d64:	70a2                	ld	ra,40(sp)
        cprintf("Load access fault\n");
ffffffffc0200d66:	00005517          	auipc	a0,0x5
ffffffffc0200d6a:	46250513          	addi	a0,a0,1122 # ffffffffc02061c8 <etext+0x8d8>
}
ffffffffc0200d6e:	6145                	addi	sp,sp,48
        cprintf("Load access fault\n");
ffffffffc0200d70:	b6eff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200d74:	70a2                	ld	ra,40(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200d76:	00005517          	auipc	a0,0x5
ffffffffc0200d7a:	49a50513          	addi	a0,a0,1178 # ffffffffc0206210 <etext+0x920>
}
ffffffffc0200d7e:	6145                	addi	sp,sp,48
        cprintf("Store/AMO access fault\n");
ffffffffc0200d80:	b5eff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200d84:	70a2                	ld	ra,40(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200d86:	00005517          	auipc	a0,0x5
ffffffffc0200d8a:	3da50513          	addi	a0,a0,986 # ffffffffc0206160 <etext+0x870>
}
ffffffffc0200d8e:	6145                	addi	sp,sp,48
        cprintf("Instruction access fault\n");
ffffffffc0200d90:	b4eff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200d94:	70a2                	ld	ra,40(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200d96:	00005517          	auipc	a0,0x5
ffffffffc0200d9a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206180 <etext+0x890>
}
ffffffffc0200d9e:	6145                	addi	sp,sp,48
        cprintf("Illegal instruction\n");
ffffffffc0200da0:	b3eff06f          	j	ffffffffc02000de <cprintf>
}
ffffffffc0200da4:	70a2                	ld	ra,40(sp)
ffffffffc0200da6:	6145                	addi	sp,sp,48
        print_trapframe(tf);
ffffffffc0200da8:	bb81                	j	ffffffffc0200af8 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200daa:	00005617          	auipc	a2,0x5
ffffffffc0200dae:	43660613          	addi	a2,a2,1078 # ffffffffc02061e0 <etext+0x8f0>
ffffffffc0200db2:	0cc00593          	li	a1,204
ffffffffc0200db6:	00005517          	auipc	a0,0x5
ffffffffc0200dba:	44250513          	addi	a0,a0,1090 # ffffffffc02061f8 <etext+0x908>
ffffffffc0200dbe:	f022                	sd	s0,32(sp)
ffffffffc0200dc0:	c68ff0ef          	jal	ffffffffc0200228 <__panic>
}

static inline struct Page *
pa2page(uintptr_t pa)
{
    if (PPN(pa) >= npage)
ffffffffc0200dc4:	000a6617          	auipc	a2,0xa6
ffffffffc0200dc8:	76463603          	ld	a2,1892(a2) # ffffffffc02a7528 <npage>
{
    if (!(pte & PTE_V))
    {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200dcc:	00281693          	slli	a3,a6,0x2
ffffffffc0200dd0:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage)
ffffffffc0200dd2:	10c6f063          	bgeu	a3,a2,ffffffffc0200ed2 <exception_handler+0x27c>
    return &pages[PPN(pa) - nbase];
ffffffffc0200dd6:	00007897          	auipc	a7,0x7
ffffffffc0200dda:	c6a8b883          	ld	a7,-918(a7) # ffffffffc0207a40 <nbase>
ffffffffc0200dde:	000a6617          	auipc	a2,0xa6
ffffffffc0200de2:	75263603          	ld	a2,1874(a2) # ffffffffc02a7530 <pages>
                if (page_ref(page) > 1)
ffffffffc0200de6:	4505                	li	a0,1
ffffffffc0200de8:	411686b3          	sub	a3,a3,a7
ffffffffc0200dec:	069a                	slli	a3,a3,0x6
ffffffffc0200dee:	9636                	add	a2,a2,a3
ffffffffc0200df0:	00062303          	lw	t1,0(a2)
ffffffffc0200df4:	0a655a63          	bge	a0,t1,ffffffffc0200ea8 <exception_handler+0x252>
ffffffffc0200df8:	e846                	sd	a7,16(sp)
ffffffffc0200dfa:	e442                	sd	a6,8(sp)
                    struct Page *npage = alloc_page();
ffffffffc0200dfc:	ec32                	sd	a2,24(sp)
ffffffffc0200dfe:	1cd010ef          	jal	ffffffffc02027ca <alloc_pages>
                    if (npage == NULL)
ffffffffc0200e02:	6822                	ld	a6,8(sp)
ffffffffc0200e04:	68c2                	ld	a7,16(sp)
ffffffffc0200e06:	6662                	ld	a2,24(sp)
                    struct Page *npage = alloc_page();
ffffffffc0200e08:	832a                	mv	t1,a0
                    if (npage == NULL)
ffffffffc0200e0a:	12050563          	beqz	a0,ffffffffc0200f34 <exception_handler+0x2de>
    return page - pages + nbase;
ffffffffc0200e0e:	000a6e17          	auipc	t3,0xa6
ffffffffc0200e12:	722e3e03          	ld	t3,1826(t3) # ffffffffc02a7530 <pages>
    return KADDR(page2pa(page));
ffffffffc0200e16:	55fd                	li	a1,-1
ffffffffc0200e18:	000a6517          	auipc	a0,0xa6
ffffffffc0200e1c:	71053503          	ld	a0,1808(a0) # ffffffffc02a7528 <npage>
    return page - pages + nbase;
ffffffffc0200e20:	41c307b3          	sub	a5,t1,t3
ffffffffc0200e24:	8799                	srai	a5,a5,0x6
ffffffffc0200e26:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc0200e28:	81b1                	srli	a1,a1,0xc
ffffffffc0200e2a:	00b7feb3          	and	t4,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e2e:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e32:	0eaef563          	bgeu	t4,a0,ffffffffc0200f1c <exception_handler+0x2c6>
    return page - pages + nbase;
ffffffffc0200e36:	41c607b3          	sub	a5,a2,t3
ffffffffc0200e3a:	8799                	srai	a5,a5,0x6
ffffffffc0200e3c:	97c6                	add	a5,a5,a7
    return KADDR(page2pa(page));
ffffffffc0200e3e:	8dfd                	and	a1,a1,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e40:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200e42:	0ca5f063          	bgeu	a1,a0,ffffffffc0200f02 <exception_handler+0x2ac>
ffffffffc0200e46:	000a6517          	auipc	a0,0xa6
ffffffffc0200e4a:	6da53503          	ld	a0,1754(a0) # ffffffffc02a7520 <va_pa_offset>
                    memcpy(page2kva(npage), page2kva(page), PGSIZE);
ffffffffc0200e4e:	6605                	lui	a2,0x1
ffffffffc0200e50:	e442                	sd	a6,8(sp)
ffffffffc0200e52:	00a785b3          	add	a1,a5,a0
ffffffffc0200e56:	9536                	add	a0,a0,a3
ffffffffc0200e58:	e81a                	sd	t1,16(sp)
ffffffffc0200e5a:	69c040ef          	jal	ffffffffc02054f6 <memcpy>
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e5e:	000a6797          	auipc	a5,0xa6
ffffffffc0200e62:	6e27b783          	ld	a5,1762(a5) # ffffffffc02a7540 <current>
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200e66:	6822                	ld	a6,8(sp)
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e68:	65c2                	ld	a1,16(sp)
ffffffffc0200e6a:	779c                	ld	a5,40(a5)
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200e6c:	01b87693          	andi	a3,a6,27
                    if (page_insert(current->mm->pgdir, npage, va, perm) != 0)
ffffffffc0200e70:	0046e693          	ori	a3,a3,4
ffffffffc0200e74:	6f88                	ld	a0,24(a5)
ffffffffc0200e76:	8622                	mv	a2,s0
ffffffffc0200e78:	130020ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc0200e7c:	e53d                	bnez	a0,ffffffffc0200eea <exception_handler+0x294>
ffffffffc0200e7e:	7402                	ld	s0,32(sp)
ffffffffc0200e80:	b5f9                	j	ffffffffc0200d4e <exception_handler+0xf8>
            tf->epc += 4;           // 跳过ebreak指令
ffffffffc0200e82:	1086b783          	ld	a5,264(a3)
ffffffffc0200e86:	0791                	addi	a5,a5,4
ffffffffc0200e88:	10f6b423          	sd	a5,264(a3)
            syscall();              // 执行系统调用
ffffffffc0200e8c:	528040ef          	jal	ffffffffc02053b4 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);  // 返回处理
ffffffffc0200e90:	000a6717          	auipc	a4,0xa6
ffffffffc0200e94:	6b073703          	ld	a4,1712(a4) # ffffffffc02a7540 <current>
ffffffffc0200e98:	6522                	ld	a0,8(sp)
}
ffffffffc0200e9a:	70a2                	ld	ra,40(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);  // 返回处理
ffffffffc0200e9c:	6b0c                	ld	a1,16(a4)
ffffffffc0200e9e:	6789                	lui	a5,0x2
ffffffffc0200ea0:	95be                	add	a1,a1,a5
}
ffffffffc0200ea2:	6145                	addi	sp,sp,48
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);  // 返回处理
ffffffffc0200ea4:	aaed                	j	ffffffffc020109e <kernel_execve_ret>
        print_trapframe(tf);
ffffffffc0200ea6:	b989                	j	ffffffffc0200af8 <print_trapframe>
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200ea8:	000a6717          	auipc	a4,0xa6
ffffffffc0200eac:	69873703          	ld	a4,1688(a4) # ffffffffc02a7540 <current>
    return page - pages + nbase;
ffffffffc0200eb0:	8699                	srai	a3,a3,0x6
ffffffffc0200eb2:	96c6                	add	a3,a3,a7
ffffffffc0200eb4:	7710                	ld	a2,40(a4)
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200eb6:	06aa                	slli	a3,a3,0xa
                    perm = (perm & ~PTE_COW) | PTE_W;
ffffffffc0200eb8:	01b87713          	andi	a4,a6,27
ffffffffc0200ebc:	8f55                	or	a4,a4,a3
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200ebe:	85a2                	mv	a1,s0
ffffffffc0200ec0:	7402                	ld	s0,32(sp)
ffffffffc0200ec2:	6e08                	ld	a0,24(a2)
}
ffffffffc0200ec4:	70a2                	ld	ra,40(sp)
ffffffffc0200ec6:	00576713          	ori	a4,a4,5
                    *ptep = pte_create(page2ppn(page), perm | PTE_V);
ffffffffc0200eca:	e398                	sd	a4,0(a5)
}
ffffffffc0200ecc:	6145                	addi	sp,sp,48
                    tlb_invalidate(current->mm->pgdir, va);
ffffffffc0200ece:	7930206f          	j	ffffffffc0203e60 <tlb_invalidate>
        panic("pa2page called with invalid pa");
ffffffffc0200ed2:	00005617          	auipc	a2,0x5
ffffffffc0200ed6:	3e660613          	addi	a2,a2,998 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc0200eda:	06b00593          	li	a1,107
ffffffffc0200ede:	00005517          	auipc	a0,0x5
ffffffffc0200ee2:	3fa50513          	addi	a0,a0,1018 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0200ee6:	b42ff0ef          	jal	ffffffffc0200228 <__panic>
                        panic("COW: insert fail\n");
ffffffffc0200eea:	00005617          	auipc	a2,0x5
ffffffffc0200eee:	43660613          	addi	a2,a2,1078 # ffffffffc0206320 <etext+0xa30>
ffffffffc0200ef2:	0fc00593          	li	a1,252
ffffffffc0200ef6:	00005517          	auipc	a0,0x5
ffffffffc0200efa:	30250513          	addi	a0,a0,770 # ffffffffc02061f8 <etext+0x908>
ffffffffc0200efe:	b2aff0ef          	jal	ffffffffc0200228 <__panic>
    return KADDR(page2pa(page));
ffffffffc0200f02:	86be                	mv	a3,a5
ffffffffc0200f04:	00005617          	auipc	a2,0x5
ffffffffc0200f08:	3f460613          	addi	a2,a2,1012 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0200f0c:	07300593          	li	a1,115
ffffffffc0200f10:	00005517          	auipc	a0,0x5
ffffffffc0200f14:	3c850513          	addi	a0,a0,968 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0200f18:	b10ff0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc0200f1c:	00005617          	auipc	a2,0x5
ffffffffc0200f20:	3dc60613          	addi	a2,a2,988 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0200f24:	07300593          	li	a1,115
ffffffffc0200f28:	00005517          	auipc	a0,0x5
ffffffffc0200f2c:	3b050513          	addi	a0,a0,944 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0200f30:	af8ff0ef          	jal	ffffffffc0200228 <__panic>
                        panic("COW: no mem\n");
ffffffffc0200f34:	00005617          	auipc	a2,0x5
ffffffffc0200f38:	3b460613          	addi	a2,a2,948 # ffffffffc02062e8 <etext+0x9f8>
ffffffffc0200f3c:	0f600593          	li	a1,246
ffffffffc0200f40:	00005517          	auipc	a0,0x5
ffffffffc0200f44:	2b850513          	addi	a0,a0,696 # ffffffffc02061f8 <etext+0x908>
ffffffffc0200f48:	ae0ff0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0200f4c <trap>:
// tf: 指向trapframe结构的指针，包含完整的异常上下文
void trap(struct trapframe *tf)
{
    // 根据异常类型进行分发处理
    // 如果当前进程不存在(系统初始化阶段)，直接处理异常
    if (current == NULL)
ffffffffc0200f4c:	000a6717          	auipc	a4,0xa6
ffffffffc0200f50:	5f473703          	ld	a4,1524(a4) # ffffffffc02a7540 <current>
    if ((intptr_t)tf->cause < 0)  // cause最高位为1，表示中断
ffffffffc0200f54:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200f58:	cf21                	beqz	a4,ffffffffc0200fb0 <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200f5a:	10053603          	ld	a2,256(a0)
        trap_dispatch(tf);
    }
    else
    {
        // 保存当前进程的旧trapframe指针
        struct trapframe *otf = current->tf;
ffffffffc0200f5e:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200f62:	1101                	addi	sp,sp,-32
ffffffffc0200f64:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200f66:	10067613          	andi	a2,a2,256
        // 设置当前进程的trapframe为新的异常上下文
        current->tf = tf;
ffffffffc0200f6a:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)  // cause最高位为1，表示中断
ffffffffc0200f6c:	e432                	sd	a2,8(sp)
ffffffffc0200f6e:	e042                	sd	a6,0(sp)
ffffffffc0200f70:	0205c763          	bltz	a1,ffffffffc0200f9e <trap+0x52>
        exception_handler(tf);
ffffffffc0200f74:	ce3ff0ef          	jal	ffffffffc0200c56 <exception_handler>
ffffffffc0200f78:	6622                	ld	a2,8(sp)
ffffffffc0200f7a:	6802                	ld	a6,0(sp)
ffffffffc0200f7c:	000a6697          	auipc	a3,0xa6
ffffffffc0200f80:	5c468693          	addi	a3,a3,1476 # ffffffffc02a7540 <current>
        // 判断异常是否发生在内核模式
        bool in_kernel = trap_in_kernel(tf);
        // 根据异常类型进行具体处理(系统调用、页面错误等)
        trap_dispatch(tf);
        // 恢复当前进程的原始trapframe
        current->tf = otf;
ffffffffc0200f84:	6298                	ld	a4,0(a3)
ffffffffc0200f86:	0b073023          	sd	a6,160(a4)
        // 如果异常发生在用户模式，需要进行进程状态检查
        if (!in_kernel)
ffffffffc0200f8a:	e619                	bnez	a2,ffffffffc0200f98 <trap+0x4c>
        {
            // 如果进程正在退出，终止进程
            if (current->flags & PF_EXITING)
ffffffffc0200f8c:	0b072783          	lw	a5,176(a4)
ffffffffc0200f90:	8b85                	andi	a5,a5,1
ffffffffc0200f92:	e79d                	bnez	a5,ffffffffc0200fc0 <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            // 如果进程需要调度，执行调度
            if (current->need_resched)
ffffffffc0200f94:	6f1c                	ld	a5,24(a4)
ffffffffc0200f96:	e38d                	bnez	a5,ffffffffc0200fb8 <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200f98:	60e2                	ld	ra,24(sp)
ffffffffc0200f9a:	6105                	addi	sp,sp,32
ffffffffc0200f9c:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200f9e:	bbdff0ef          	jal	ffffffffc0200b5a <interrupt_handler>
ffffffffc0200fa2:	6802                	ld	a6,0(sp)
ffffffffc0200fa4:	6622                	ld	a2,8(sp)
ffffffffc0200fa6:	000a6697          	auipc	a3,0xa6
ffffffffc0200faa:	59a68693          	addi	a3,a3,1434 # ffffffffc02a7540 <current>
ffffffffc0200fae:	bfd9                	j	ffffffffc0200f84 <trap+0x38>
    if ((intptr_t)tf->cause < 0)  // cause最高位为1，表示中断
ffffffffc0200fb0:	0005c363          	bltz	a1,ffffffffc0200fb6 <trap+0x6a>
        exception_handler(tf);
ffffffffc0200fb4:	b14d                	j	ffffffffc0200c56 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200fb6:	b655                	j	ffffffffc0200b5a <interrupt_handler>
}
ffffffffc0200fb8:	60e2                	ld	ra,24(sp)
ffffffffc0200fba:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200fbc:	30c0406f          	j	ffffffffc02052c8 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200fc0:	555d                	li	a0,-9
ffffffffc0200fc2:	602030ef          	jal	ffffffffc02045c4 <do_exit>
            if (current->need_resched)
ffffffffc0200fc6:	000a6717          	auipc	a4,0xa6
ffffffffc0200fca:	57a73703          	ld	a4,1402(a4) # ffffffffc02a7540 <current>
ffffffffc0200fce:	b7d9                	j	ffffffffc0200f94 <trap+0x48>

ffffffffc0200fd0 <__alltraps>:

    # __alltraps: 异常/中断统一入口点
    # 当发生异常/中断时，硬件自动跳转到此地址
    .globl __alltraps
__alltraps:
    SAVE_ALL                        # 保存所有上下文到trapframe
ffffffffc0200fd0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200fd4:	00011463          	bnez	sp,ffffffffc0200fdc <__alltraps+0xc>
ffffffffc0200fd8:	14002173          	csrr	sp,sscratch
ffffffffc0200fdc:	712d                	addi	sp,sp,-288
ffffffffc0200fde:	e002                	sd	zero,0(sp)
ffffffffc0200fe0:	e406                	sd	ra,8(sp)
ffffffffc0200fe2:	ec0e                	sd	gp,24(sp)
ffffffffc0200fe4:	f012                	sd	tp,32(sp)
ffffffffc0200fe6:	f416                	sd	t0,40(sp)
ffffffffc0200fe8:	f81a                	sd	t1,48(sp)
ffffffffc0200fea:	fc1e                	sd	t2,56(sp)
ffffffffc0200fec:	e0a2                	sd	s0,64(sp)
ffffffffc0200fee:	e4a6                	sd	s1,72(sp)
ffffffffc0200ff0:	e8aa                	sd	a0,80(sp)
ffffffffc0200ff2:	ecae                	sd	a1,88(sp)
ffffffffc0200ff4:	f0b2                	sd	a2,96(sp)
ffffffffc0200ff6:	f4b6                	sd	a3,104(sp)
ffffffffc0200ff8:	f8ba                	sd	a4,112(sp)
ffffffffc0200ffa:	fcbe                	sd	a5,120(sp)
ffffffffc0200ffc:	e142                	sd	a6,128(sp)
ffffffffc0200ffe:	e546                	sd	a7,136(sp)
ffffffffc0201000:	e94a                	sd	s2,144(sp)
ffffffffc0201002:	ed4e                	sd	s3,152(sp)
ffffffffc0201004:	f152                	sd	s4,160(sp)
ffffffffc0201006:	f556                	sd	s5,168(sp)
ffffffffc0201008:	f95a                	sd	s6,176(sp)
ffffffffc020100a:	fd5e                	sd	s7,184(sp)
ffffffffc020100c:	e1e2                	sd	s8,192(sp)
ffffffffc020100e:	e5e6                	sd	s9,200(sp)
ffffffffc0201010:	e9ea                	sd	s10,208(sp)
ffffffffc0201012:	edee                	sd	s11,216(sp)
ffffffffc0201014:	f1f2                	sd	t3,224(sp)
ffffffffc0201016:	f5f6                	sd	t4,232(sp)
ffffffffc0201018:	f9fa                	sd	t5,240(sp)
ffffffffc020101a:	fdfe                	sd	t6,248(sp)
ffffffffc020101c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0201020:	100024f3          	csrr	s1,sstatus
ffffffffc0201024:	14102973          	csrr	s2,sepc
ffffffffc0201028:	143029f3          	csrr	s3,stval
ffffffffc020102c:	14202a73          	csrr	s4,scause
ffffffffc0201030:	e822                	sd	s0,16(sp)
ffffffffc0201032:	e226                	sd	s1,256(sp)
ffffffffc0201034:	e64a                	sd	s2,264(sp)
ffffffffc0201036:	ea4e                	sd	s3,272(sp)
ffffffffc0201038:	ee52                	sd	s4,280(sp)

    move  a0, sp                    # a0 = 当前栈指针(指向trapframe)
ffffffffc020103a:	850a                	mv	a0,sp
    jal trap                        # 调用C函数trap()进行异常处理
ffffffffc020103c:	f11ff0ef          	jal	ffffffffc0200f4c <trap>

ffffffffc0201040 <__trapret>:

    # __trapret: 异常/中断返回点
    # 从异常处理返回到被中断的代码
    .globl __trapret
__trapret:
    RESTORE_ALL                     # 恢复所有上下文
ffffffffc0201040:	6492                	ld	s1,256(sp)
ffffffffc0201042:	6932                	ld	s2,264(sp)
ffffffffc0201044:	1004f413          	andi	s0,s1,256
ffffffffc0201048:	e401                	bnez	s0,ffffffffc0201050 <__trapret+0x10>
ffffffffc020104a:	1200                	addi	s0,sp,288
ffffffffc020104c:	14041073          	csrw	sscratch,s0
ffffffffc0201050:	10049073          	csrw	sstatus,s1
ffffffffc0201054:	14191073          	csrw	sepc,s2
ffffffffc0201058:	60a2                	ld	ra,8(sp)
ffffffffc020105a:	61e2                	ld	gp,24(sp)
ffffffffc020105c:	7202                	ld	tp,32(sp)
ffffffffc020105e:	72a2                	ld	t0,40(sp)
ffffffffc0201060:	7342                	ld	t1,48(sp)
ffffffffc0201062:	73e2                	ld	t2,56(sp)
ffffffffc0201064:	6406                	ld	s0,64(sp)
ffffffffc0201066:	64a6                	ld	s1,72(sp)
ffffffffc0201068:	6546                	ld	a0,80(sp)
ffffffffc020106a:	65e6                	ld	a1,88(sp)
ffffffffc020106c:	7606                	ld	a2,96(sp)
ffffffffc020106e:	76a6                	ld	a3,104(sp)
ffffffffc0201070:	7746                	ld	a4,112(sp)
ffffffffc0201072:	77e6                	ld	a5,120(sp)
ffffffffc0201074:	680a                	ld	a6,128(sp)
ffffffffc0201076:	68aa                	ld	a7,136(sp)
ffffffffc0201078:	694a                	ld	s2,144(sp)
ffffffffc020107a:	69ea                	ld	s3,152(sp)
ffffffffc020107c:	7a0a                	ld	s4,160(sp)
ffffffffc020107e:	7aaa                	ld	s5,168(sp)
ffffffffc0201080:	7b4a                	ld	s6,176(sp)
ffffffffc0201082:	7bea                	ld	s7,184(sp)
ffffffffc0201084:	6c0e                	ld	s8,192(sp)
ffffffffc0201086:	6cae                	ld	s9,200(sp)
ffffffffc0201088:	6d4e                	ld	s10,208(sp)
ffffffffc020108a:	6dee                	ld	s11,216(sp)
ffffffffc020108c:	7e0e                	ld	t3,224(sp)
ffffffffc020108e:	7eae                	ld	t4,232(sp)
ffffffffc0201090:	7f4e                	ld	t5,240(sp)
ffffffffc0201092:	7fee                	ld	t6,248(sp)
ffffffffc0201094:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret                            # 执行sret指令返回，恢复PC和状态
ffffffffc0201096:	10200073          	sret

ffffffffc020109a <forkrets>:
    # forkrets: fork系统调用子进程返回点
    # 子进程从fork返回时使用此入口
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0                    # 设置栈指针指向新的trapframe
ffffffffc020109a:	812a                	mv	sp,a0
    j __trapret                    # 跳转到通用返回处理
ffffffffc020109c:	b755                	j	ffffffffc0201040 <__trapret>

ffffffffc020109e <kernel_execve_ret>:
    # kernel_execve_ret: 内核execve系统调用返回处理
    # 处理execve后的上下文切换，复制trapframe到新位置
    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES     # 计算新trapframe位置(kstacktop向下36个寄存器)
ffffffffc020109e:	ee058593          	addi	a1,a1,-288

    // 复制trapframe: 从旧位置(a0)复制到新位置(a1)
    // 复制所有trapframe字段(36个64位字)
    LOAD s1, 35*REGBYTES(a0)     # scause
ffffffffc02010a2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc02010a6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)     # stval
ffffffffc02010aa:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc02010ae:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)     # sepc
ffffffffc02010b2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc02010b6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)     # sstatus
ffffffffc02010ba:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc02010be:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)     # t6
ffffffffc02010c2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc02010c4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)     # t5
ffffffffc02010c6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc02010c8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)     # t4
ffffffffc02010ca:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc02010cc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)     # t3
ffffffffc02010ce:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc02010d0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)     # s11
ffffffffc02010d2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc02010d4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)     # s10
ffffffffc02010d6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc02010d8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)     # s9
ffffffffc02010da:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc02010dc:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)     # s8
ffffffffc02010de:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc02010e0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)     # s7
ffffffffc02010e2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc02010e4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)     # s6
ffffffffc02010e6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc02010e8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)     # s5
ffffffffc02010ea:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc02010ec:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)     # s4
ffffffffc02010ee:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc02010f0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)     # s3
ffffffffc02010f2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc02010f4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)     # s2
ffffffffc02010f6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc02010f8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)     # a7
ffffffffc02010fa:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc02010fc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)     # a6
ffffffffc02010fe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0201100:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)     # a5
ffffffffc0201102:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201104:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)     # a4
ffffffffc0201106:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201108:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)     # a3
ffffffffc020110a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc020110c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)     # a2
ffffffffc020110e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0201110:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)     # a1
ffffffffc0201112:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0201114:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)     # a0
ffffffffc0201116:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0201118:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)      # s1
ffffffffc020111a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc020111c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)      # s0/fp
ffffffffc020111e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0201120:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)      # x7
ffffffffc0201122:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0201124:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)      # x6
ffffffffc0201126:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0201128:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)      # x5
ffffffffc020112a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc020112c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)      # tp
ffffffffc020112e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0201130:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)      # gp
ffffffffc0201132:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0201134:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)      # sp
ffffffffc0201136:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0201138:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)      # ra
ffffffffc020113a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc020113c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)      # x0 (zero)
ffffffffc020113e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0201140:	e184                	sd	s1,0(a1)

    // 设置新的栈指针并返回
    move sp, a1                  # 设置栈指针到新trapframe位置
ffffffffc0201142:	812e                	mv	sp,a1
ffffffffc0201144:	bdf5                	j	ffffffffc0201040 <__trapret>

ffffffffc0201146 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201146:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0201148:	00005697          	auipc	a3,0x5
ffffffffc020114c:	20868693          	addi	a3,a3,520 # ffffffffc0206350 <etext+0xa60>
ffffffffc0201150:	00005617          	auipc	a2,0x5
ffffffffc0201154:	22060613          	addi	a2,a2,544 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201158:	07400593          	li	a1,116
ffffffffc020115c:	00005517          	auipc	a0,0x5
ffffffffc0201160:	22c50513          	addi	a0,a0,556 # ffffffffc0206388 <etext+0xa98>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0201164:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0201166:	8c2ff0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc020116a <mm_create>:
{
ffffffffc020116a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020116c:	04000513          	li	a0,64
{
ffffffffc0201170:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201172:	1ad000ef          	jal	ffffffffc0201b1e <kmalloc>
    if (mm != NULL)
ffffffffc0201176:	cd19                	beqz	a0,ffffffffc0201194 <mm_create+0x2a>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201178:	e508                	sd	a0,8(a0)
ffffffffc020117a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;         // 清空缓存指针
ffffffffc020117c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;              // 清空页目录指针
ffffffffc0201180:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0201184:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0201188:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc020118c:	02052823          	sw	zero,48(a0)

// lock_init - 初始化自旋锁，初始状态为解锁(0)
static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc0201190:	02053c23          	sd	zero,56(a0)
}
ffffffffc0201194:	60a2                	ld	ra,8(sp)
ffffffffc0201196:	0141                	addi	sp,sp,16
ffffffffc0201198:	8082                	ret

ffffffffc020119a <find_vma>:
    if (mm != NULL)
ffffffffc020119a:	c505                	beqz	a0,ffffffffc02011c2 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc020119c:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020119e:	c781                	beqz	a5,ffffffffc02011a6 <find_vma+0xc>
ffffffffc02011a0:	6798                	ld	a4,8(a5)
ffffffffc02011a2:	02e5f363          	bgeu	a1,a4,ffffffffc02011c8 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02011a6:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc02011a8:	00f50d63          	beq	a0,a5,ffffffffc02011c2 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02011ac:	fe87b703          	ld	a4,-24(a5) # 1fe8 <_binary_obj___user_softint_out_size-0x6c20>
ffffffffc02011b0:	00e5e663          	bltu	a1,a4,ffffffffc02011bc <find_vma+0x22>
ffffffffc02011b4:	ff07b703          	ld	a4,-16(a5)
ffffffffc02011b8:	00e5ee63          	bltu	a1,a4,ffffffffc02011d4 <find_vma+0x3a>
ffffffffc02011bc:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02011be:	fef517e3          	bne	a0,a5,ffffffffc02011ac <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc02011c2:	4781                	li	a5,0
}
ffffffffc02011c4:	853e                	mv	a0,a5
ffffffffc02011c6:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02011c8:	6b98                	ld	a4,16(a5)
ffffffffc02011ca:	fce5fee3          	bgeu	a1,a4,ffffffffc02011a6 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02011ce:	e91c                	sd	a5,16(a0)
}
ffffffffc02011d0:	853e                	mv	a0,a5
ffffffffc02011d2:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02011d4:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc02011d6:	e91c                	sd	a5,16(a0)
ffffffffc02011d8:	bfe5                	j	ffffffffc02011d0 <find_vma+0x36>

ffffffffc02011da <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02011da:	6590                	ld	a2,8(a1)
ffffffffc02011dc:	0105b803          	ld	a6,16(a1)
{
ffffffffc02011e0:	1141                	addi	sp,sp,-16
ffffffffc02011e2:	e406                	sd	ra,8(sp)
ffffffffc02011e4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02011e6:	01066763          	bltu	a2,a6,ffffffffc02011f4 <insert_vma_struct+0x1a>
ffffffffc02011ea:	a8b9                	j	ffffffffc0201248 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02011ec:	fe87b703          	ld	a4,-24(a5)
ffffffffc02011f0:	04e66763          	bltu	a2,a4,ffffffffc020123e <insert_vma_struct+0x64>
ffffffffc02011f4:	86be                	mv	a3,a5
ffffffffc02011f6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02011f8:	fef51ae3          	bne	a0,a5,ffffffffc02011ec <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02011fc:	02a68463          	beq	a3,a0,ffffffffc0201224 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0201200:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201204:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201208:	08e8f063          	bgeu	a7,a4,ffffffffc0201288 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020120c:	04e66e63          	bltu	a2,a4,ffffffffc0201268 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc0201210:	00f50a63          	beq	a0,a5,ffffffffc0201224 <insert_vma_struct+0x4a>
ffffffffc0201214:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201218:	05076863          	bltu	a4,a6,ffffffffc0201268 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020121c:	ff07b603          	ld	a2,-16(a5)
ffffffffc0201220:	02c77263          	bgeu	a4,a2,ffffffffc0201244 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0201224:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0201226:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0201228:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020122c:	e390                	sd	a2,0(a5)
ffffffffc020122e:	e690                	sd	a2,8(a3)
}
ffffffffc0201230:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0201232:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0201234:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0201236:	2705                	addiw	a4,a4,1
ffffffffc0201238:	d118                	sw	a4,32(a0)
}
ffffffffc020123a:	0141                	addi	sp,sp,16
ffffffffc020123c:	8082                	ret
    if (le_prev != list)
ffffffffc020123e:	fca691e3          	bne	a3,a0,ffffffffc0201200 <insert_vma_struct+0x26>
ffffffffc0201242:	bfd9                	j	ffffffffc0201218 <insert_vma_struct+0x3e>
ffffffffc0201244:	f03ff0ef          	jal	ffffffffc0201146 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0201248:	00005697          	auipc	a3,0x5
ffffffffc020124c:	15068693          	addi	a3,a3,336 # ffffffffc0206398 <etext+0xaa8>
ffffffffc0201250:	00005617          	auipc	a2,0x5
ffffffffc0201254:	12060613          	addi	a2,a2,288 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201258:	07a00593          	li	a1,122
ffffffffc020125c:	00005517          	auipc	a0,0x5
ffffffffc0201260:	12c50513          	addi	a0,a0,300 # ffffffffc0206388 <etext+0xa98>
ffffffffc0201264:	fc5fe0ef          	jal	ffffffffc0200228 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0201268:	00005697          	auipc	a3,0x5
ffffffffc020126c:	17068693          	addi	a3,a3,368 # ffffffffc02063d8 <etext+0xae8>
ffffffffc0201270:	00005617          	auipc	a2,0x5
ffffffffc0201274:	10060613          	addi	a2,a2,256 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201278:	07300593          	li	a1,115
ffffffffc020127c:	00005517          	auipc	a0,0x5
ffffffffc0201280:	10c50513          	addi	a0,a0,268 # ffffffffc0206388 <etext+0xa98>
ffffffffc0201284:	fa5fe0ef          	jal	ffffffffc0200228 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0201288:	00005697          	auipc	a3,0x5
ffffffffc020128c:	13068693          	addi	a3,a3,304 # ffffffffc02063b8 <etext+0xac8>
ffffffffc0201290:	00005617          	auipc	a2,0x5
ffffffffc0201294:	0e060613          	addi	a2,a2,224 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201298:	07200593          	li	a1,114
ffffffffc020129c:	00005517          	auipc	a0,0x5
ffffffffc02012a0:	0ec50513          	addi	a0,a0,236 # ffffffffc0206388 <etext+0xa98>
ffffffffc02012a4:	f85fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02012a8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc02012a8:	591c                	lw	a5,48(a0)
{
ffffffffc02012aa:	1141                	addi	sp,sp,-16
ffffffffc02012ac:	e406                	sd	ra,8(sp)
ffffffffc02012ae:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02012b0:	e78d                	bnez	a5,ffffffffc02012da <mm_destroy+0x32>
ffffffffc02012b2:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02012b4:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02012b6:	00a40c63          	beq	s0,a0,ffffffffc02012ce <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02012ba:	6118                	ld	a4,0(a0)
ffffffffc02012bc:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02012be:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02012c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02012c2:	e398                	sd	a4,0(a5)
ffffffffc02012c4:	101000ef          	jal	ffffffffc0201bc4 <kfree>
    return listelm->next;
ffffffffc02012c8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02012ca:	fea418e3          	bne	s0,a0,ffffffffc02012ba <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02012ce:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02012d0:	6402                	ld	s0,0(sp)
ffffffffc02012d2:	60a2                	ld	ra,8(sp)
ffffffffc02012d4:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02012d6:	0ef0006f          	j	ffffffffc0201bc4 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02012da:	00005697          	auipc	a3,0x5
ffffffffc02012de:	11e68693          	addi	a3,a3,286 # ffffffffc02063f8 <etext+0xb08>
ffffffffc02012e2:	00005617          	auipc	a2,0x5
ffffffffc02012e6:	08e60613          	addi	a2,a2,142 # ffffffffc0206370 <etext+0xa80>
ffffffffc02012ea:	09e00593          	li	a1,158
ffffffffc02012ee:	00005517          	auipc	a0,0x5
ffffffffc02012f2:	09a50513          	addi	a0,a0,154 # ffffffffc0206388 <etext+0xa98>
ffffffffc02012f6:	f33fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02012fa <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02012fa:	6785                	lui	a5,0x1
ffffffffc02012fc:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7c09>
ffffffffc02012fe:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc0201300:	4785                	li	a5,1
{
ffffffffc0201302:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201304:	962e                	add	a2,a2,a1
ffffffffc0201306:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc0201308:	07fe                	slli	a5,a5,0x1f
{
ffffffffc020130a:	f822                	sd	s0,48(sp)
ffffffffc020130c:	f426                	sd	s1,40(sp)
ffffffffc020130e:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0201312:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0201316:	0785                	addi	a5,a5,1
ffffffffc0201318:	0084b633          	sltu	a2,s1,s0
ffffffffc020131c:	00f437b3          	sltu	a5,s0,a5
ffffffffc0201320:	00163613          	seqz	a2,a2
ffffffffc0201324:	0017b793          	seqz	a5,a5
{
ffffffffc0201328:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020132a:	8fd1                	or	a5,a5,a2
ffffffffc020132c:	ebbd                	bnez	a5,ffffffffc02013a2 <mm_map+0xa8>
ffffffffc020132e:	002007b7          	lui	a5,0x200
ffffffffc0201332:	06f4e863          	bltu	s1,a5,ffffffffc02013a2 <mm_map+0xa8>
ffffffffc0201336:	f04a                	sd	s2,32(sp)
ffffffffc0201338:	ec4e                	sd	s3,24(sp)
ffffffffc020133a:	e852                	sd	s4,16(sp)
ffffffffc020133c:	892a                	mv	s2,a0
ffffffffc020133e:	89ba                	mv	s3,a4
ffffffffc0201340:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0201342:	c135                	beqz	a0,ffffffffc02013a6 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0201344:	85a6                	mv	a1,s1
ffffffffc0201346:	e55ff0ef          	jal	ffffffffc020119a <find_vma>
ffffffffc020134a:	c501                	beqz	a0,ffffffffc0201352 <mm_map+0x58>
ffffffffc020134c:	651c                	ld	a5,8(a0)
ffffffffc020134e:	0487e763          	bltu	a5,s0,ffffffffc020139c <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201352:	03000513          	li	a0,48
ffffffffc0201356:	7c8000ef          	jal	ffffffffc0201b1e <kmalloc>
ffffffffc020135a:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020135c:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc020135e:	c59d                	beqz	a1,ffffffffc020138c <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc0201360:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc0201362:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0201364:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0201368:	854a                	mv	a0,s2
ffffffffc020136a:	e42e                	sd	a1,8(sp)
ffffffffc020136c:	e6fff0ef          	jal	ffffffffc02011da <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc0201370:	65a2                	ld	a1,8(sp)
ffffffffc0201372:	00098463          	beqz	s3,ffffffffc020137a <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc0201376:	00b9b023          	sd	a1,0(s3)
ffffffffc020137a:	7902                	ld	s2,32(sp)
ffffffffc020137c:	69e2                	ld	s3,24(sp)
ffffffffc020137e:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc0201380:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc0201382:	70e2                	ld	ra,56(sp)
ffffffffc0201384:	7442                	ld	s0,48(sp)
ffffffffc0201386:	74a2                	ld	s1,40(sp)
ffffffffc0201388:	6121                	addi	sp,sp,64
ffffffffc020138a:	8082                	ret
ffffffffc020138c:	70e2                	ld	ra,56(sp)
ffffffffc020138e:	7442                	ld	s0,48(sp)
ffffffffc0201390:	7902                	ld	s2,32(sp)
ffffffffc0201392:	69e2                	ld	s3,24(sp)
ffffffffc0201394:	6a42                	ld	s4,16(sp)
ffffffffc0201396:	74a2                	ld	s1,40(sp)
ffffffffc0201398:	6121                	addi	sp,sp,64
ffffffffc020139a:	8082                	ret
ffffffffc020139c:	7902                	ld	s2,32(sp)
ffffffffc020139e:	69e2                	ld	s3,24(sp)
ffffffffc02013a0:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc02013a2:	5575                	li	a0,-3
ffffffffc02013a4:	bff9                	j	ffffffffc0201382 <mm_map+0x88>
    assert(mm != NULL);
ffffffffc02013a6:	00005697          	auipc	a3,0x5
ffffffffc02013aa:	06a68693          	addi	a3,a3,106 # ffffffffc0206410 <etext+0xb20>
ffffffffc02013ae:	00005617          	auipc	a2,0x5
ffffffffc02013b2:	fc260613          	addi	a2,a2,-62 # ffffffffc0206370 <etext+0xa80>
ffffffffc02013b6:	0b300593          	li	a1,179
ffffffffc02013ba:	00005517          	auipc	a0,0x5
ffffffffc02013be:	fce50513          	addi	a0,a0,-50 # ffffffffc0206388 <etext+0xa98>
ffffffffc02013c2:	e67fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02013c6 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc02013c6:	7139                	addi	sp,sp,-64
ffffffffc02013c8:	fc06                	sd	ra,56(sp)
ffffffffc02013ca:	f822                	sd	s0,48(sp)
ffffffffc02013cc:	f426                	sd	s1,40(sp)
ffffffffc02013ce:	f04a                	sd	s2,32(sp)
ffffffffc02013d0:	ec4e                	sd	s3,24(sp)
ffffffffc02013d2:	e852                	sd	s4,16(sp)
ffffffffc02013d4:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02013d6:	c525                	beqz	a0,ffffffffc020143e <dup_mmap+0x78>
ffffffffc02013d8:	892a                	mv	s2,a0
ffffffffc02013da:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02013dc:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02013de:	c1a5                	beqz	a1,ffffffffc020143e <dup_mmap+0x78>
    return listelm->prev;
ffffffffc02013e0:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc02013e2:	04848c63          	beq	s1,s0,ffffffffc020143a <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013e6:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02013ea:	fe843a83          	ld	s5,-24(s0)
ffffffffc02013ee:	ff043a03          	ld	s4,-16(s0)
ffffffffc02013f2:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02013f6:	728000ef          	jal	ffffffffc0201b1e <kmalloc>
    if (vma != NULL)
ffffffffc02013fa:	c515                	beqz	a0,ffffffffc0201426 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02013fc:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02013fe:	01553423          	sd	s5,8(a0)
ffffffffc0201402:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201406:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc020140a:	854a                	mv	a0,s2
ffffffffc020140c:	dcfff0ef          	jal	ffffffffc02011da <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0201410:	ff043683          	ld	a3,-16(s0)
ffffffffc0201414:	fe843603          	ld	a2,-24(s0)
ffffffffc0201418:	6c8c                	ld	a1,24(s1)
ffffffffc020141a:	01893503          	ld	a0,24(s2)
ffffffffc020141e:	4701                	li	a4,0
ffffffffc0201420:	0c9020ef          	jal	ffffffffc0203ce8 <copy_range>
ffffffffc0201424:	dd55                	beqz	a0,ffffffffc02013e0 <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0201426:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0201428:	70e2                	ld	ra,56(sp)
ffffffffc020142a:	7442                	ld	s0,48(sp)
ffffffffc020142c:	74a2                	ld	s1,40(sp)
ffffffffc020142e:	7902                	ld	s2,32(sp)
ffffffffc0201430:	69e2                	ld	s3,24(sp)
ffffffffc0201432:	6a42                	ld	s4,16(sp)
ffffffffc0201434:	6aa2                	ld	s5,8(sp)
ffffffffc0201436:	6121                	addi	sp,sp,64
ffffffffc0201438:	8082                	ret
    return 0;
ffffffffc020143a:	4501                	li	a0,0
ffffffffc020143c:	b7f5                	j	ffffffffc0201428 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc020143e:	00005697          	auipc	a3,0x5
ffffffffc0201442:	fe268693          	addi	a3,a3,-30 # ffffffffc0206420 <etext+0xb30>
ffffffffc0201446:	00005617          	auipc	a2,0x5
ffffffffc020144a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0206370 <etext+0xa80>
ffffffffc020144e:	0cf00593          	li	a1,207
ffffffffc0201452:	00005517          	auipc	a0,0x5
ffffffffc0201456:	f3650513          	addi	a0,a0,-202 # ffffffffc0206388 <etext+0xa98>
ffffffffc020145a:	dcffe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc020145e <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc020145e:	1101                	addi	sp,sp,-32
ffffffffc0201460:	ec06                	sd	ra,24(sp)
ffffffffc0201462:	e822                	sd	s0,16(sp)
ffffffffc0201464:	e426                	sd	s1,8(sp)
ffffffffc0201466:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201468:	c531                	beqz	a0,ffffffffc02014b4 <exit_mmap+0x56>
ffffffffc020146a:	591c                	lw	a5,48(a0)
ffffffffc020146c:	84aa                	mv	s1,a0
ffffffffc020146e:	e3b9                	bnez	a5,ffffffffc02014b4 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0201470:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0201472:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0201476:	02850663          	beq	a0,s0,ffffffffc02014a2 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020147a:	ff043603          	ld	a2,-16(s0)
ffffffffc020147e:	fe843583          	ld	a1,-24(s0)
ffffffffc0201482:	854a                	mv	a0,s2
ffffffffc0201484:	6a0010ef          	jal	ffffffffc0202b24 <unmap_range>
ffffffffc0201488:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020148a:	fe8498e3          	bne	s1,s0,ffffffffc020147a <exit_mmap+0x1c>
ffffffffc020148e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0201490:	00848c63          	beq	s1,s0,ffffffffc02014a8 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201494:	ff043603          	ld	a2,-16(s0)
ffffffffc0201498:	fe843583          	ld	a1,-24(s0)
ffffffffc020149c:	854a                	mv	a0,s2
ffffffffc020149e:	7ba010ef          	jal	ffffffffc0202c58 <exit_range>
ffffffffc02014a2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02014a4:	fe8498e3          	bne	s1,s0,ffffffffc0201494 <exit_mmap+0x36>
    }
}
ffffffffc02014a8:	60e2                	ld	ra,24(sp)
ffffffffc02014aa:	6442                	ld	s0,16(sp)
ffffffffc02014ac:	64a2                	ld	s1,8(sp)
ffffffffc02014ae:	6902                	ld	s2,0(sp)
ffffffffc02014b0:	6105                	addi	sp,sp,32
ffffffffc02014b2:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02014b4:	00005697          	auipc	a3,0x5
ffffffffc02014b8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0206440 <etext+0xb50>
ffffffffc02014bc:	00005617          	auipc	a2,0x5
ffffffffc02014c0:	eb460613          	addi	a2,a2,-332 # ffffffffc0206370 <etext+0xa80>
ffffffffc02014c4:	0e800593          	li	a1,232
ffffffffc02014c8:	00005517          	auipc	a0,0x5
ffffffffc02014cc:	ec050513          	addi	a0,a0,-320 # ffffffffc0206388 <etext+0xa98>
ffffffffc02014d0:	d59fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02014d4 <vmm_init>:
}

// vmm_init - 初始化虚拟内存管理
// 目前主要用于检查虚拟内存管理机制的正确性
void vmm_init(void)
{
ffffffffc02014d4:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02014d6:	04000513          	li	a0,64
{
ffffffffc02014da:	f406                	sd	ra,40(sp)
ffffffffc02014dc:	f022                	sd	s0,32(sp)
ffffffffc02014de:	ec26                	sd	s1,24(sp)
ffffffffc02014e0:	e84a                	sd	s2,16(sp)
ffffffffc02014e2:	e44e                	sd	s3,8(sp)
ffffffffc02014e4:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02014e6:	638000ef          	jal	ffffffffc0201b1e <kmalloc>
    if (mm != NULL)
ffffffffc02014ea:	16050c63          	beqz	a0,ffffffffc0201662 <vmm_init+0x18e>
ffffffffc02014ee:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc02014f0:	e508                	sd	a0,8(a0)
ffffffffc02014f2:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;         // 清空缓存指针
ffffffffc02014f4:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;              // 清空页目录指针
ffffffffc02014f8:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02014fc:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0201500:	02053423          	sd	zero,40(a0)
ffffffffc0201504:	02052823          	sw	zero,48(a0)
ffffffffc0201508:	02053c23          	sd	zero,56(a0)
ffffffffc020150c:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0201510:	03000513          	li	a0,48
ffffffffc0201514:	60a000ef          	jal	ffffffffc0201b1e <kmalloc>
    if (vma != NULL)
ffffffffc0201518:	12050563          	beqz	a0,ffffffffc0201642 <vmm_init+0x16e>
        vma->vm_end = vm_end;
ffffffffc020151c:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0201520:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0201522:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0201526:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201528:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc020152a:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc020152c:	8522                	mv	a0,s0
ffffffffc020152e:	cadff0ef          	jal	ffffffffc02011da <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0201532:	fcf9                	bnez	s1,ffffffffc0201510 <vmm_init+0x3c>
ffffffffc0201534:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0201538:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020153c:	03000513          	li	a0,48
ffffffffc0201540:	5de000ef          	jal	ffffffffc0201b1e <kmalloc>
    if (vma != NULL)
ffffffffc0201544:	12050f63          	beqz	a0,ffffffffc0201682 <vmm_init+0x1ae>
        vma->vm_end = vm_end;
ffffffffc0201548:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc020154c:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc020154e:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0201552:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0201554:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0201556:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0201558:	8522                	mv	a0,s0
ffffffffc020155a:	c81ff0ef          	jal	ffffffffc02011da <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc020155e:	fd249fe3          	bne	s1,s2,ffffffffc020153c <vmm_init+0x68>
    return listelm->next;
ffffffffc0201562:	641c                	ld	a5,8(s0)
ffffffffc0201564:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0201566:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc020156a:	1ef40c63          	beq	s0,a5,ffffffffc0201762 <vmm_init+0x28e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020156e:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_cowtest_out_size+0x1f3df0>
ffffffffc0201572:	ffe70693          	addi	a3,a4,-2
ffffffffc0201576:	12d61663          	bne	a2,a3,ffffffffc02016a2 <vmm_init+0x1ce>
ffffffffc020157a:	ff07b683          	ld	a3,-16(a5)
ffffffffc020157e:	12e69263          	bne	a3,a4,ffffffffc02016a2 <vmm_init+0x1ce>
    for (i = 1; i <= step2; i++)
ffffffffc0201582:	0715                	addi	a4,a4,5
ffffffffc0201584:	679c                	ld	a5,8(a5)
ffffffffc0201586:	feb712e3          	bne	a4,a1,ffffffffc020156a <vmm_init+0x96>
ffffffffc020158a:	491d                	li	s2,7
ffffffffc020158c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc020158e:	85a6                	mv	a1,s1
ffffffffc0201590:	8522                	mv	a0,s0
ffffffffc0201592:	c09ff0ef          	jal	ffffffffc020119a <find_vma>
ffffffffc0201596:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0201598:	20050563          	beqz	a0,ffffffffc02017a2 <vmm_init+0x2ce>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc020159c:	00148593          	addi	a1,s1,1
ffffffffc02015a0:	8522                	mv	a0,s0
ffffffffc02015a2:	bf9ff0ef          	jal	ffffffffc020119a <find_vma>
ffffffffc02015a6:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02015a8:	1c050d63          	beqz	a0,ffffffffc0201782 <vmm_init+0x2ae>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc02015ac:	85ca                	mv	a1,s2
ffffffffc02015ae:	8522                	mv	a0,s0
ffffffffc02015b0:	bebff0ef          	jal	ffffffffc020119a <find_vma>
        assert(vma3 == NULL);
ffffffffc02015b4:	18051763          	bnez	a0,ffffffffc0201742 <vmm_init+0x26e>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc02015b8:	00348593          	addi	a1,s1,3
ffffffffc02015bc:	8522                	mv	a0,s0
ffffffffc02015be:	bddff0ef          	jal	ffffffffc020119a <find_vma>
        assert(vma4 == NULL);
ffffffffc02015c2:	16051063          	bnez	a0,ffffffffc0201722 <vmm_init+0x24e>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc02015c6:	00448593          	addi	a1,s1,4
ffffffffc02015ca:	8522                	mv	a0,s0
ffffffffc02015cc:	bcfff0ef          	jal	ffffffffc020119a <find_vma>
        assert(vma5 == NULL);
ffffffffc02015d0:	12051963          	bnez	a0,ffffffffc0201702 <vmm_init+0x22e>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02015d4:	008a3783          	ld	a5,8(s4)
ffffffffc02015d8:	10979563          	bne	a5,s1,ffffffffc02016e2 <vmm_init+0x20e>
ffffffffc02015dc:	010a3783          	ld	a5,16(s4)
ffffffffc02015e0:	11279163          	bne	a5,s2,ffffffffc02016e2 <vmm_init+0x20e>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02015e4:	0089b783          	ld	a5,8(s3)
ffffffffc02015e8:	0c979d63          	bne	a5,s1,ffffffffc02016c2 <vmm_init+0x1ee>
ffffffffc02015ec:	0109b783          	ld	a5,16(s3)
ffffffffc02015f0:	0d279963          	bne	a5,s2,ffffffffc02016c2 <vmm_init+0x1ee>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02015f4:	0495                	addi	s1,s1,5
ffffffffc02015f6:	1f900793          	li	a5,505
ffffffffc02015fa:	0915                	addi	s2,s2,5
ffffffffc02015fc:	f8f499e3          	bne	s1,a5,ffffffffc020158e <vmm_init+0xba>
ffffffffc0201600:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0201602:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0201604:	85a6                	mv	a1,s1
ffffffffc0201606:	8522                	mv	a0,s0
ffffffffc0201608:	b93ff0ef          	jal	ffffffffc020119a <find_vma>
        if (vma_below_5 != NULL)
ffffffffc020160c:	1a051b63          	bnez	a0,ffffffffc02017c2 <vmm_init+0x2ee>
    for (i = 4; i >= 0; i--)
ffffffffc0201610:	14fd                	addi	s1,s1,-1
ffffffffc0201612:	ff2499e3          	bne	s1,s2,ffffffffc0201604 <vmm_init+0x130>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0201616:	8522                	mv	a0,s0
ffffffffc0201618:	c91ff0ef          	jal	ffffffffc02012a8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020161c:	00005517          	auipc	a0,0x5
ffffffffc0201620:	f9450513          	addi	a0,a0,-108 # ffffffffc02065b0 <etext+0xcc0>
ffffffffc0201624:	abbfe0ef          	jal	ffffffffc02000de <cprintf>
}
ffffffffc0201628:	7402                	ld	s0,32(sp)
ffffffffc020162a:	70a2                	ld	ra,40(sp)
ffffffffc020162c:	64e2                	ld	s1,24(sp)
ffffffffc020162e:	6942                	ld	s2,16(sp)
ffffffffc0201630:	69a2                	ld	s3,8(sp)
ffffffffc0201632:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0201634:	00005517          	auipc	a0,0x5
ffffffffc0201638:	f9c50513          	addi	a0,a0,-100 # ffffffffc02065d0 <etext+0xce0>
}
ffffffffc020163c:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc020163e:	aa1fe06f          	j	ffffffffc02000de <cprintf>
        assert(vma != NULL);
ffffffffc0201642:	00005697          	auipc	a3,0x5
ffffffffc0201646:	e1e68693          	addi	a3,a3,-482 # ffffffffc0206460 <etext+0xb70>
ffffffffc020164a:	00005617          	auipc	a2,0x5
ffffffffc020164e:	d2660613          	addi	a2,a2,-730 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201652:	12c00593          	li	a1,300
ffffffffc0201656:	00005517          	auipc	a0,0x5
ffffffffc020165a:	d3250513          	addi	a0,a0,-718 # ffffffffc0206388 <etext+0xa98>
ffffffffc020165e:	bcbfe0ef          	jal	ffffffffc0200228 <__panic>
    assert(mm != NULL);
ffffffffc0201662:	00005697          	auipc	a3,0x5
ffffffffc0201666:	dae68693          	addi	a3,a3,-594 # ffffffffc0206410 <etext+0xb20>
ffffffffc020166a:	00005617          	auipc	a2,0x5
ffffffffc020166e:	d0660613          	addi	a2,a2,-762 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201672:	12400593          	li	a1,292
ffffffffc0201676:	00005517          	auipc	a0,0x5
ffffffffc020167a:	d1250513          	addi	a0,a0,-750 # ffffffffc0206388 <etext+0xa98>
ffffffffc020167e:	babfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma != NULL);
ffffffffc0201682:	00005697          	auipc	a3,0x5
ffffffffc0201686:	dde68693          	addi	a3,a3,-546 # ffffffffc0206460 <etext+0xb70>
ffffffffc020168a:	00005617          	auipc	a2,0x5
ffffffffc020168e:	ce660613          	addi	a2,a2,-794 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201692:	13300593          	li	a1,307
ffffffffc0201696:	00005517          	auipc	a0,0x5
ffffffffc020169a:	cf250513          	addi	a0,a0,-782 # ffffffffc0206388 <etext+0xa98>
ffffffffc020169e:	b8bfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02016a2:	00005697          	auipc	a3,0x5
ffffffffc02016a6:	de668693          	addi	a3,a3,-538 # ffffffffc0206488 <etext+0xb98>
ffffffffc02016aa:	00005617          	auipc	a2,0x5
ffffffffc02016ae:	cc660613          	addi	a2,a2,-826 # ffffffffc0206370 <etext+0xa80>
ffffffffc02016b2:	13d00593          	li	a1,317
ffffffffc02016b6:	00005517          	auipc	a0,0x5
ffffffffc02016ba:	cd250513          	addi	a0,a0,-814 # ffffffffc0206388 <etext+0xa98>
ffffffffc02016be:	b6bfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02016c2:	00005697          	auipc	a3,0x5
ffffffffc02016c6:	e7e68693          	addi	a3,a3,-386 # ffffffffc0206540 <etext+0xc50>
ffffffffc02016ca:	00005617          	auipc	a2,0x5
ffffffffc02016ce:	ca660613          	addi	a2,a2,-858 # ffffffffc0206370 <etext+0xa80>
ffffffffc02016d2:	14f00593          	li	a1,335
ffffffffc02016d6:	00005517          	auipc	a0,0x5
ffffffffc02016da:	cb250513          	addi	a0,a0,-846 # ffffffffc0206388 <etext+0xa98>
ffffffffc02016de:	b4bfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02016e2:	00005697          	auipc	a3,0x5
ffffffffc02016e6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0206510 <etext+0xc20>
ffffffffc02016ea:	00005617          	auipc	a2,0x5
ffffffffc02016ee:	c8660613          	addi	a2,a2,-890 # ffffffffc0206370 <etext+0xa80>
ffffffffc02016f2:	14e00593          	li	a1,334
ffffffffc02016f6:	00005517          	auipc	a0,0x5
ffffffffc02016fa:	c9250513          	addi	a0,a0,-878 # ffffffffc0206388 <etext+0xa98>
ffffffffc02016fe:	b2bfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma5 == NULL);
ffffffffc0201702:	00005697          	auipc	a3,0x5
ffffffffc0201706:	dfe68693          	addi	a3,a3,-514 # ffffffffc0206500 <etext+0xc10>
ffffffffc020170a:	00005617          	auipc	a2,0x5
ffffffffc020170e:	c6660613          	addi	a2,a2,-922 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201712:	14c00593          	li	a1,332
ffffffffc0201716:	00005517          	auipc	a0,0x5
ffffffffc020171a:	c7250513          	addi	a0,a0,-910 # ffffffffc0206388 <etext+0xa98>
ffffffffc020171e:	b0bfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma4 == NULL);
ffffffffc0201722:	00005697          	auipc	a3,0x5
ffffffffc0201726:	dce68693          	addi	a3,a3,-562 # ffffffffc02064f0 <etext+0xc00>
ffffffffc020172a:	00005617          	auipc	a2,0x5
ffffffffc020172e:	c4660613          	addi	a2,a2,-954 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201732:	14a00593          	li	a1,330
ffffffffc0201736:	00005517          	auipc	a0,0x5
ffffffffc020173a:	c5250513          	addi	a0,a0,-942 # ffffffffc0206388 <etext+0xa98>
ffffffffc020173e:	aebfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma3 == NULL);
ffffffffc0201742:	00005697          	auipc	a3,0x5
ffffffffc0201746:	d9e68693          	addi	a3,a3,-610 # ffffffffc02064e0 <etext+0xbf0>
ffffffffc020174a:	00005617          	auipc	a2,0x5
ffffffffc020174e:	c2660613          	addi	a2,a2,-986 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201752:	14800593          	li	a1,328
ffffffffc0201756:	00005517          	auipc	a0,0x5
ffffffffc020175a:	c3250513          	addi	a0,a0,-974 # ffffffffc0206388 <etext+0xa98>
ffffffffc020175e:	acbfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201762:	00005697          	auipc	a3,0x5
ffffffffc0201766:	d0e68693          	addi	a3,a3,-754 # ffffffffc0206470 <etext+0xb80>
ffffffffc020176a:	00005617          	auipc	a2,0x5
ffffffffc020176e:	c0660613          	addi	a2,a2,-1018 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201772:	13b00593          	li	a1,315
ffffffffc0201776:	00005517          	auipc	a0,0x5
ffffffffc020177a:	c1250513          	addi	a0,a0,-1006 # ffffffffc0206388 <etext+0xa98>
ffffffffc020177e:	aabfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma2 != NULL);
ffffffffc0201782:	00005697          	auipc	a3,0x5
ffffffffc0201786:	d4e68693          	addi	a3,a3,-690 # ffffffffc02064d0 <etext+0xbe0>
ffffffffc020178a:	00005617          	auipc	a2,0x5
ffffffffc020178e:	be660613          	addi	a2,a2,-1050 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201792:	14600593          	li	a1,326
ffffffffc0201796:	00005517          	auipc	a0,0x5
ffffffffc020179a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0206388 <etext+0xa98>
ffffffffc020179e:	a8bfe0ef          	jal	ffffffffc0200228 <__panic>
        assert(vma1 != NULL);
ffffffffc02017a2:	00005697          	auipc	a3,0x5
ffffffffc02017a6:	d1e68693          	addi	a3,a3,-738 # ffffffffc02064c0 <etext+0xbd0>
ffffffffc02017aa:	00005617          	auipc	a2,0x5
ffffffffc02017ae:	bc660613          	addi	a2,a2,-1082 # ffffffffc0206370 <etext+0xa80>
ffffffffc02017b2:	14400593          	li	a1,324
ffffffffc02017b6:	00005517          	auipc	a0,0x5
ffffffffc02017ba:	bd250513          	addi	a0,a0,-1070 # ffffffffc0206388 <etext+0xa98>
ffffffffc02017be:	a6bfe0ef          	jal	ffffffffc0200228 <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc02017c2:	6914                	ld	a3,16(a0)
ffffffffc02017c4:	6510                	ld	a2,8(a0)
ffffffffc02017c6:	0004859b          	sext.w	a1,s1
ffffffffc02017ca:	00005517          	auipc	a0,0x5
ffffffffc02017ce:	da650513          	addi	a0,a0,-602 # ffffffffc0206570 <etext+0xc80>
ffffffffc02017d2:	90dfe0ef          	jal	ffffffffc02000de <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc02017d6:	00005697          	auipc	a3,0x5
ffffffffc02017da:	dc268693          	addi	a3,a3,-574 # ffffffffc0206598 <etext+0xca8>
ffffffffc02017de:	00005617          	auipc	a2,0x5
ffffffffc02017e2:	b9260613          	addi	a2,a2,-1134 # ffffffffc0206370 <etext+0xa80>
ffffffffc02017e6:	15900593          	li	a1,345
ffffffffc02017ea:	00005517          	auipc	a0,0x5
ffffffffc02017ee:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0206388 <etext+0xa98>
ffffffffc02017f2:	a37fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02017f6 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc02017f6:	7179                	addi	sp,sp,-48
ffffffffc02017f8:	f022                	sd	s0,32(sp)
ffffffffc02017fa:	f406                	sd	ra,40(sp)
ffffffffc02017fc:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc02017fe:	c52d                	beqz	a0,ffffffffc0201868 <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0201800:	002007b7          	lui	a5,0x200
ffffffffc0201804:	04f5ed63          	bltu	a1,a5,ffffffffc020185e <user_mem_check+0x68>
ffffffffc0201808:	ec26                	sd	s1,24(sp)
ffffffffc020180a:	00c584b3          	add	s1,a1,a2
ffffffffc020180e:	0695ff63          	bgeu	a1,s1,ffffffffc020188c <user_mem_check+0x96>
ffffffffc0201812:	4785                	li	a5,1
ffffffffc0201814:	07fe                	slli	a5,a5,0x1f
ffffffffc0201816:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_cowtest_out_size+0x1f3e09>
ffffffffc0201818:	06f4fa63          	bgeu	s1,a5,ffffffffc020188c <user_mem_check+0x96>
ffffffffc020181c:	e84a                	sd	s2,16(sp)
ffffffffc020181e:	e44e                	sd	s3,8(sp)
ffffffffc0201820:	8936                	mv	s2,a3
ffffffffc0201822:	89aa                	mv	s3,a0
ffffffffc0201824:	a829                	j	ffffffffc020183e <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0201826:	6685                	lui	a3,0x1
ffffffffc0201828:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020182a:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc020182e:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0201830:	c685                	beqz	a3,ffffffffc0201858 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0201832:	c399                	beqz	a5,ffffffffc0201838 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0201834:	02e46263          	bltu	s0,a4,ffffffffc0201858 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0201838:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc020183a:	04947b63          	bgeu	s0,s1,ffffffffc0201890 <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc020183e:	85a2                	mv	a1,s0
ffffffffc0201840:	854e                	mv	a0,s3
ffffffffc0201842:	959ff0ef          	jal	ffffffffc020119a <find_vma>
ffffffffc0201846:	c909                	beqz	a0,ffffffffc0201858 <user_mem_check+0x62>
ffffffffc0201848:	6518                	ld	a4,8(a0)
ffffffffc020184a:	00e46763          	bltu	s0,a4,ffffffffc0201858 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc020184e:	4d1c                	lw	a5,24(a0)
ffffffffc0201850:	fc091be3          	bnez	s2,ffffffffc0201826 <user_mem_check+0x30>
ffffffffc0201854:	8b85                	andi	a5,a5,1
ffffffffc0201856:	f3ed                	bnez	a5,ffffffffc0201838 <user_mem_check+0x42>
ffffffffc0201858:	64e2                	ld	s1,24(sp)
ffffffffc020185a:	6942                	ld	s2,16(sp)
ffffffffc020185c:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc020185e:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201860:	70a2                	ld	ra,40(sp)
ffffffffc0201862:	7402                	ld	s0,32(sp)
ffffffffc0201864:	6145                	addi	sp,sp,48
ffffffffc0201866:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201868:	c02007b7          	lui	a5,0xc0200
ffffffffc020186c:	fef5eae3          	bltu	a1,a5,ffffffffc0201860 <user_mem_check+0x6a>
ffffffffc0201870:	c80007b7          	lui	a5,0xc8000
ffffffffc0201874:	962e                	add	a2,a2,a1
ffffffffc0201876:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d58aa9>
ffffffffc0201878:	00c5b433          	sltu	s0,a1,a2
ffffffffc020187c:	00f63633          	sltu	a2,a2,a5
ffffffffc0201880:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0201882:	00867533          	and	a0,a2,s0
ffffffffc0201886:	7402                	ld	s0,32(sp)
ffffffffc0201888:	6145                	addi	sp,sp,48
ffffffffc020188a:	8082                	ret
ffffffffc020188c:	64e2                	ld	s1,24(sp)
ffffffffc020188e:	bfc1                	j	ffffffffc020185e <user_mem_check+0x68>
ffffffffc0201890:	64e2                	ld	s1,24(sp)
ffffffffc0201892:	6942                	ld	s2,16(sp)
ffffffffc0201894:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0201896:	4505                	li	a0,1
ffffffffc0201898:	b7e1                	j	ffffffffc0201860 <user_mem_check+0x6a>

ffffffffc020189a <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020189a:	c531                	beqz	a0,ffffffffc02018e6 <slob_free+0x4c>
		return;

	if (size)
ffffffffc020189c:	e9b9                	bnez	a1,ffffffffc02018f2 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020189e:	100027f3          	csrr	a5,sstatus
ffffffffc02018a2:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc02018a4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02018a6:	efb1                	bnez	a5,ffffffffc0201902 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018a8:	000a1797          	auipc	a5,0xa1
ffffffffc02018ac:	7f07b783          	ld	a5,2032(a5) # ffffffffc02a3098 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018b0:	873e                	mv	a4,a5
ffffffffc02018b2:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018b4:	02a77a63          	bgeu	a4,a0,ffffffffc02018e8 <slob_free+0x4e>
ffffffffc02018b8:	00f56463          	bltu	a0,a5,ffffffffc02018c0 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018bc:	fef76ae3          	bltu	a4,a5,ffffffffc02018b0 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc02018c0:	4110                	lw	a2,0(a0)
ffffffffc02018c2:	00461693          	slli	a3,a2,0x4
ffffffffc02018c6:	96aa                	add	a3,a3,a0
ffffffffc02018c8:	0ad78463          	beq	a5,a3,ffffffffc0201970 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02018cc:	4310                	lw	a2,0(a4)
ffffffffc02018ce:	e51c                	sd	a5,8(a0)
ffffffffc02018d0:	00461693          	slli	a3,a2,0x4
ffffffffc02018d4:	96ba                	add	a3,a3,a4
ffffffffc02018d6:	08d50163          	beq	a0,a3,ffffffffc0201958 <slob_free+0xbe>
ffffffffc02018da:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc02018dc:	000a1797          	auipc	a5,0xa1
ffffffffc02018e0:	7ae7be23          	sd	a4,1980(a5) # ffffffffc02a3098 <slobfree>
    if (flag)           // 如果原来中断是开启的
ffffffffc02018e4:	e9a5                	bnez	a1,ffffffffc0201954 <slob_free+0xba>
ffffffffc02018e6:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018e8:	fcf574e3          	bgeu	a0,a5,ffffffffc02018b0 <slob_free+0x16>
ffffffffc02018ec:	fcf762e3          	bltu	a4,a5,ffffffffc02018b0 <slob_free+0x16>
ffffffffc02018f0:	bfc1                	j	ffffffffc02018c0 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc02018f2:	25bd                	addiw	a1,a1,15
ffffffffc02018f4:	8191                	srli	a1,a1,0x4
ffffffffc02018f6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02018f8:	100027f3          	csrr	a5,sstatus
ffffffffc02018fc:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc02018fe:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0201900:	d7c5                	beqz	a5,ffffffffc02018a8 <slob_free+0xe>
{
ffffffffc0201902:	1101                	addi	sp,sp,-32
ffffffffc0201904:	e42a                	sd	a0,8(sp)
ffffffffc0201906:	ec06                	sd	ra,24(sp)
        intr_disable();  // 关闭中断
ffffffffc0201908:	802ff0ef          	jal	ffffffffc020090a <intr_disable>
        return 1;        // 返回原状态：开启
ffffffffc020190c:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020190e:	000a1797          	auipc	a5,0xa1
ffffffffc0201912:	78a7b783          	ld	a5,1930(a5) # ffffffffc02a3098 <slobfree>
ffffffffc0201916:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201918:	873e                	mv	a4,a5
ffffffffc020191a:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020191c:	06a77663          	bgeu	a4,a0,ffffffffc0201988 <slob_free+0xee>
ffffffffc0201920:	00f56463          	bltu	a0,a5,ffffffffc0201928 <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201924:	fef76ae3          	bltu	a4,a5,ffffffffc0201918 <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201928:	4110                	lw	a2,0(a0)
ffffffffc020192a:	00461693          	slli	a3,a2,0x4
ffffffffc020192e:	96aa                	add	a3,a3,a0
ffffffffc0201930:	06d78363          	beq	a5,a3,ffffffffc0201996 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201934:	4310                	lw	a2,0(a4)
ffffffffc0201936:	e51c                	sd	a5,8(a0)
ffffffffc0201938:	00461693          	slli	a3,a2,0x4
ffffffffc020193c:	96ba                	add	a3,a3,a4
ffffffffc020193e:	06d50163          	beq	a0,a3,ffffffffc02019a0 <slob_free+0x106>
ffffffffc0201942:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201944:	000a1797          	auipc	a5,0xa1
ffffffffc0201948:	74e7ba23          	sd	a4,1876(a5) # ffffffffc02a3098 <slobfree>
    if (flag)           // 如果原来中断是开启的
ffffffffc020194c:	e1a9                	bnez	a1,ffffffffc020198e <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc020194e:	60e2                	ld	ra,24(sp)
ffffffffc0201950:	6105                	addi	sp,sp,32
ffffffffc0201952:	8082                	ret
        intr_enable();  // 重新开启中断
ffffffffc0201954:	fb1fe06f          	j	ffffffffc0200904 <intr_enable>
		cur->units += b->units;
ffffffffc0201958:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc020195a:	853e                	mv	a0,a5
ffffffffc020195c:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc020195e:	00c687bb          	addw	a5,a3,a2
ffffffffc0201962:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201964:	000a1797          	auipc	a5,0xa1
ffffffffc0201968:	72e7ba23          	sd	a4,1844(a5) # ffffffffc02a3098 <slobfree>
    if (flag)           // 如果原来中断是开启的
ffffffffc020196c:	ddad                	beqz	a1,ffffffffc02018e6 <slob_free+0x4c>
ffffffffc020196e:	b7dd                	j	ffffffffc0201954 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201970:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201972:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201974:	9eb1                	addw	a3,a3,a2
ffffffffc0201976:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201978:	4310                	lw	a2,0(a4)
ffffffffc020197a:	e51c                	sd	a5,8(a0)
ffffffffc020197c:	00461693          	slli	a3,a2,0x4
ffffffffc0201980:	96ba                	add	a3,a3,a4
ffffffffc0201982:	f4d51ce3          	bne	a0,a3,ffffffffc02018da <slob_free+0x40>
ffffffffc0201986:	bfc9                	j	ffffffffc0201958 <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201988:	f8f56ee3          	bltu	a0,a5,ffffffffc0201924 <slob_free+0x8a>
ffffffffc020198c:	b771                	j	ffffffffc0201918 <slob_free+0x7e>
}
ffffffffc020198e:	60e2                	ld	ra,24(sp)
ffffffffc0201990:	6105                	addi	sp,sp,32
        intr_enable();  // 重新开启中断
ffffffffc0201992:	f73fe06f          	j	ffffffffc0200904 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201996:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201998:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020199a:	9eb1                	addw	a3,a3,a2
ffffffffc020199c:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc020199e:	bf59                	j	ffffffffc0201934 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc02019a0:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc02019a2:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc02019a4:	00c687bb          	addw	a5,a3,a2
ffffffffc02019a8:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc02019aa:	bf61                	j	ffffffffc0201942 <slob_free+0xa8>

ffffffffc02019ac <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019ac:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019ae:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019b0:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02019b4:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc02019b6:	615000ef          	jal	ffffffffc02027ca <alloc_pages>
	if (!page)
ffffffffc02019ba:	c91d                	beqz	a0,ffffffffc02019f0 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc02019bc:	000a6697          	auipc	a3,0xa6
ffffffffc02019c0:	b746b683          	ld	a3,-1164(a3) # ffffffffc02a7530 <pages>
ffffffffc02019c4:	00006797          	auipc	a5,0x6
ffffffffc02019c8:	07c7b783          	ld	a5,124(a5) # ffffffffc0207a40 <nbase>
    return KADDR(page2pa(page));
ffffffffc02019cc:	000a6717          	auipc	a4,0xa6
ffffffffc02019d0:	b5c73703          	ld	a4,-1188(a4) # ffffffffc02a7528 <npage>
    return page - pages + nbase;
ffffffffc02019d4:	8d15                	sub	a0,a0,a3
ffffffffc02019d6:	8519                	srai	a0,a0,0x6
ffffffffc02019d8:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc02019da:	00c51793          	slli	a5,a0,0xc
ffffffffc02019de:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02019e0:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019e2:	00e7fa63          	bgeu	a5,a4,ffffffffc02019f6 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019e6:	000a6797          	auipc	a5,0xa6
ffffffffc02019ea:	b3a7b783          	ld	a5,-1222(a5) # ffffffffc02a7520 <va_pa_offset>
ffffffffc02019ee:	953e                	add	a0,a0,a5
}
ffffffffc02019f0:	60a2                	ld	ra,8(sp)
ffffffffc02019f2:	0141                	addi	sp,sp,16
ffffffffc02019f4:	8082                	ret
ffffffffc02019f6:	86aa                	mv	a3,a0
ffffffffc02019f8:	00005617          	auipc	a2,0x5
ffffffffc02019fc:	90060613          	addi	a2,a2,-1792 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0201a00:	07300593          	li	a1,115
ffffffffc0201a04:	00005517          	auipc	a0,0x5
ffffffffc0201a08:	8d450513          	addi	a0,a0,-1836 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0201a0c:	81dfe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0201a10 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201a10:	7179                	addi	sp,sp,-48
ffffffffc0201a12:	f406                	sd	ra,40(sp)
ffffffffc0201a14:	f022                	sd	s0,32(sp)
ffffffffc0201a16:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201a18:	01050713          	addi	a4,a0,16
ffffffffc0201a1c:	6785                	lui	a5,0x1
ffffffffc0201a1e:	0af77e63          	bgeu	a4,a5,ffffffffc0201ada <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201a22:	00f50413          	addi	s0,a0,15
ffffffffc0201a26:	8011                	srli	s0,s0,0x4
ffffffffc0201a28:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0201a2a:	100025f3          	csrr	a1,sstatus
ffffffffc0201a2e:	8989                	andi	a1,a1,2
ffffffffc0201a30:	edd1                	bnez	a1,ffffffffc0201acc <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201a32:	000a1497          	auipc	s1,0xa1
ffffffffc0201a36:	66648493          	addi	s1,s1,1638 # ffffffffc02a3098 <slobfree>
ffffffffc0201a3a:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a3c:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201a3e:	4314                	lw	a3,0(a4)
ffffffffc0201a40:	0886da63          	bge	a3,s0,ffffffffc0201ad4 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201a44:	00e60a63          	beq	a2,a4,ffffffffc0201a58 <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a48:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201a4a:	4394                	lw	a3,0(a5)
ffffffffc0201a4c:	0286d863          	bge	a3,s0,ffffffffc0201a7c <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201a50:	6090                	ld	a2,0(s1)
ffffffffc0201a52:	873e                	mv	a4,a5
ffffffffc0201a54:	fee61ae3          	bne	a2,a4,ffffffffc0201a48 <slob_alloc.constprop.0+0x38>
    if (flag)           // 如果原来中断是开启的
ffffffffc0201a58:	e9b1                	bnez	a1,ffffffffc0201aac <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a5a:	4501                	li	a0,0
ffffffffc0201a5c:	f51ff0ef          	jal	ffffffffc02019ac <__slob_get_free_pages.constprop.0>
ffffffffc0201a60:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201a62:	c915                	beqz	a0,ffffffffc0201a96 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a64:	6585                	lui	a1,0x1
ffffffffc0201a66:	e35ff0ef          	jal	ffffffffc020189a <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0201a6a:	100025f3          	csrr	a1,sstatus
ffffffffc0201a6e:	8989                	andi	a1,a1,2
ffffffffc0201a70:	e98d                	bnez	a1,ffffffffc0201aa2 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201a72:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201a74:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201a76:	4394                	lw	a3,0(a5)
ffffffffc0201a78:	fc86cce3          	blt	a3,s0,ffffffffc0201a50 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201a7c:	04d40563          	beq	s0,a3,ffffffffc0201ac6 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201a80:	00441613          	slli	a2,s0,0x4
ffffffffc0201a84:	963e                	add	a2,a2,a5
ffffffffc0201a86:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201a88:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201a8a:	9e81                	subw	a3,a3,s0
ffffffffc0201a8c:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201a8e:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201a90:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201a92:	e098                	sd	a4,0(s1)
    if (flag)           // 如果原来中断是开启的
ffffffffc0201a94:	ed99                	bnez	a1,ffffffffc0201ab2 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201a96:	70a2                	ld	ra,40(sp)
ffffffffc0201a98:	7402                	ld	s0,32(sp)
ffffffffc0201a9a:	64e2                	ld	s1,24(sp)
ffffffffc0201a9c:	853e                	mv	a0,a5
ffffffffc0201a9e:	6145                	addi	sp,sp,48
ffffffffc0201aa0:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc0201aa2:	e69fe0ef          	jal	ffffffffc020090a <intr_disable>
			cur = slobfree;
ffffffffc0201aa6:	6098                	ld	a4,0(s1)
        return 1;        // 返回原状态：开启
ffffffffc0201aa8:	4585                	li	a1,1
ffffffffc0201aaa:	b7e9                	j	ffffffffc0201a74 <slob_alloc.constprop.0+0x64>
        intr_enable();  // 重新开启中断
ffffffffc0201aac:	e59fe0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0201ab0:	b76d                	j	ffffffffc0201a5a <slob_alloc.constprop.0+0x4a>
ffffffffc0201ab2:	e43e                	sd	a5,8(sp)
ffffffffc0201ab4:	e51fe0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0201ab8:	67a2                	ld	a5,8(sp)
}
ffffffffc0201aba:	70a2                	ld	ra,40(sp)
ffffffffc0201abc:	7402                	ld	s0,32(sp)
ffffffffc0201abe:	64e2                	ld	s1,24(sp)
ffffffffc0201ac0:	853e                	mv	a0,a5
ffffffffc0201ac2:	6145                	addi	sp,sp,48
ffffffffc0201ac4:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201ac6:	6794                	ld	a3,8(a5)
ffffffffc0201ac8:	e714                	sd	a3,8(a4)
ffffffffc0201aca:	b7e1                	j	ffffffffc0201a92 <slob_alloc.constprop.0+0x82>
        intr_disable();  // 关闭中断
ffffffffc0201acc:	e3ffe0ef          	jal	ffffffffc020090a <intr_disable>
        return 1;        // 返回原状态：开启
ffffffffc0201ad0:	4585                	li	a1,1
ffffffffc0201ad2:	b785                	j	ffffffffc0201a32 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ad4:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201ad6:	8732                	mv	a4,a2
ffffffffc0201ad8:	b755                	j	ffffffffc0201a7c <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201ada:	00005697          	auipc	a3,0x5
ffffffffc0201ade:	b0e68693          	addi	a3,a3,-1266 # ffffffffc02065e8 <etext+0xcf8>
ffffffffc0201ae2:	00005617          	auipc	a2,0x5
ffffffffc0201ae6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0206370 <etext+0xa80>
ffffffffc0201aea:	06300593          	li	a1,99
ffffffffc0201aee:	00005517          	auipc	a0,0x5
ffffffffc0201af2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0206608 <etext+0xd18>
ffffffffc0201af6:	f32fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0201afa <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201afa:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201afc:	00005517          	auipc	a0,0x5
ffffffffc0201b00:	b2450513          	addi	a0,a0,-1244 # ffffffffc0206620 <etext+0xd30>
{
ffffffffc0201b04:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201b06:	dd8fe0ef          	jal	ffffffffc02000de <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201b0a:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b0c:	00005517          	auipc	a0,0x5
ffffffffc0201b10:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0206638 <etext+0xd48>
}
ffffffffc0201b14:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201b16:	dc8fe06f          	j	ffffffffc02000de <cprintf>

ffffffffc0201b1a <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201b1a:	4501                	li	a0,0
ffffffffc0201b1c:	8082                	ret

ffffffffc0201b1e <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b1e:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b20:	6685                	lui	a3,0x1
{
ffffffffc0201b22:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201b24:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x7c19>
ffffffffc0201b26:	04a6f963          	bgeu	a3,a0,ffffffffc0201b78 <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b2a:	e42a                	sd	a0,8(sp)
ffffffffc0201b2c:	4561                	li	a0,24
ffffffffc0201b2e:	e822                	sd	s0,16(sp)
ffffffffc0201b30:	ee1ff0ef          	jal	ffffffffc0201a10 <slob_alloc.constprop.0>
ffffffffc0201b34:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201b36:	c541                	beqz	a0,ffffffffc0201bbe <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201b38:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201b3a:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201b3c:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201b3e:	00f75763          	bge	a4,a5,ffffffffc0201b4c <kmalloc+0x2e>
ffffffffc0201b42:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201b46:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201b48:	fef74de3          	blt	a4,a5,ffffffffc0201b42 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201b4c:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b4e:	e5fff0ef          	jal	ffffffffc02019ac <__slob_get_free_pages.constprop.0>
ffffffffc0201b52:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201b54:	cd31                	beqz	a0,ffffffffc0201bb0 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0201b56:	100027f3          	csrr	a5,sstatus
ffffffffc0201b5a:	8b89                	andi	a5,a5,2
ffffffffc0201b5c:	eb85                	bnez	a5,ffffffffc0201b8c <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201b5e:	000a6797          	auipc	a5,0xa6
ffffffffc0201b62:	9a27b783          	ld	a5,-1630(a5) # ffffffffc02a7500 <bigblocks>
		bigblocks = bb;
ffffffffc0201b66:	000a6717          	auipc	a4,0xa6
ffffffffc0201b6a:	98873d23          	sd	s0,-1638(a4) # ffffffffc02a7500 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201b6e:	e81c                	sd	a5,16(s0)
    if (flag)           // 如果原来中断是开启的
ffffffffc0201b70:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201b72:	60e2                	ld	ra,24(sp)
ffffffffc0201b74:	6105                	addi	sp,sp,32
ffffffffc0201b76:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b78:	0541                	addi	a0,a0,16
ffffffffc0201b7a:	e97ff0ef          	jal	ffffffffc0201a10 <slob_alloc.constprop.0>
ffffffffc0201b7e:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b80:	0541                	addi	a0,a0,16
ffffffffc0201b82:	fbe5                	bnez	a5,ffffffffc0201b72 <kmalloc+0x54>
		return 0;
ffffffffc0201b84:	4501                	li	a0,0
}
ffffffffc0201b86:	60e2                	ld	ra,24(sp)
ffffffffc0201b88:	6105                	addi	sp,sp,32
ffffffffc0201b8a:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc0201b8c:	d7ffe0ef          	jal	ffffffffc020090a <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b90:	000a6797          	auipc	a5,0xa6
ffffffffc0201b94:	9707b783          	ld	a5,-1680(a5) # ffffffffc02a7500 <bigblocks>
		bigblocks = bb;
ffffffffc0201b98:	000a6717          	auipc	a4,0xa6
ffffffffc0201b9c:	96873423          	sd	s0,-1688(a4) # ffffffffc02a7500 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ba0:	e81c                	sd	a5,16(s0)
        intr_enable();  // 重新开启中断
ffffffffc0201ba2:	d63fe0ef          	jal	ffffffffc0200904 <intr_enable>
		return bb->pages;
ffffffffc0201ba6:	6408                	ld	a0,8(s0)
}
ffffffffc0201ba8:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201baa:	6442                	ld	s0,16(sp)
}
ffffffffc0201bac:	6105                	addi	sp,sp,32
ffffffffc0201bae:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bb0:	8522                	mv	a0,s0
ffffffffc0201bb2:	45e1                	li	a1,24
ffffffffc0201bb4:	ce7ff0ef          	jal	ffffffffc020189a <slob_free>
		return 0;
ffffffffc0201bb8:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bba:	6442                	ld	s0,16(sp)
ffffffffc0201bbc:	b7e9                	j	ffffffffc0201b86 <kmalloc+0x68>
ffffffffc0201bbe:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201bc0:	4501                	li	a0,0
ffffffffc0201bc2:	b7d1                	j	ffffffffc0201b86 <kmalloc+0x68>

ffffffffc0201bc4 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bc4:	c571                	beqz	a0,ffffffffc0201c90 <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201bc6:	03451793          	slli	a5,a0,0x34
ffffffffc0201bca:	e3e1                	bnez	a5,ffffffffc0201c8a <kfree+0xc6>
{
ffffffffc0201bcc:	1101                	addi	sp,sp,-32
ffffffffc0201bce:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0201bd0:	100027f3          	csrr	a5,sstatus
ffffffffc0201bd4:	8b89                	andi	a5,a5,2
ffffffffc0201bd6:	e7c1                	bnez	a5,ffffffffc0201c5e <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201bd8:	000a6797          	auipc	a5,0xa6
ffffffffc0201bdc:	9287b783          	ld	a5,-1752(a5) # ffffffffc02a7500 <bigblocks>
    return 0;           // 返回原状态：关闭
ffffffffc0201be0:	4581                	li	a1,0
ffffffffc0201be2:	cbad                	beqz	a5,ffffffffc0201c54 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201be4:	000a6617          	auipc	a2,0xa6
ffffffffc0201be8:	91c60613          	addi	a2,a2,-1764 # ffffffffc02a7500 <bigblocks>
ffffffffc0201bec:	a021                	j	ffffffffc0201bf4 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201bee:	01070613          	addi	a2,a4,16
ffffffffc0201bf2:	c3a5                	beqz	a5,ffffffffc0201c52 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201bf4:	6794                	ld	a3,8(a5)
ffffffffc0201bf6:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201bf8:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201bfa:	fea69ae3          	bne	a3,a0,ffffffffc0201bee <kfree+0x2a>
				*last = bb->next;
ffffffffc0201bfe:	e21c                	sd	a5,0(a2)
    if (flag)           // 如果原来中断是开启的
ffffffffc0201c00:	edb5                	bnez	a1,ffffffffc0201c7c <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201c02:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c06:	0af56263          	bltu	a0,a5,ffffffffc0201caa <kfree+0xe6>
ffffffffc0201c0a:	000a6797          	auipc	a5,0xa6
ffffffffc0201c0e:	9167b783          	ld	a5,-1770(a5) # ffffffffc02a7520 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201c12:	000a6697          	auipc	a3,0xa6
ffffffffc0201c16:	9166b683          	ld	a3,-1770(a3) # ffffffffc02a7528 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201c1a:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201c1c:	00c55793          	srli	a5,a0,0xc
ffffffffc0201c20:	06d7f963          	bgeu	a5,a3,ffffffffc0201c92 <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c24:	00006617          	auipc	a2,0x6
ffffffffc0201c28:	e1c63603          	ld	a2,-484(a2) # ffffffffc0207a40 <nbase>
ffffffffc0201c2c:	000a6517          	auipc	a0,0xa6
ffffffffc0201c30:	90453503          	ld	a0,-1788(a0) # ffffffffc02a7530 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201c34:	4314                	lw	a3,0(a4)
ffffffffc0201c36:	8f91                	sub	a5,a5,a2
ffffffffc0201c38:	079a                	slli	a5,a5,0x6
ffffffffc0201c3a:	4585                	li	a1,1
ffffffffc0201c3c:	953e                	add	a0,a0,a5
ffffffffc0201c3e:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201c42:	e03a                	sd	a4,0(sp)
ffffffffc0201c44:	3c1000ef          	jal	ffffffffc0202804 <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c48:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c4a:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c4c:	45e1                	li	a1,24
}
ffffffffc0201c4e:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c50:	b1a9                	j	ffffffffc020189a <slob_free>
ffffffffc0201c52:	e185                	bnez	a1,ffffffffc0201c72 <kfree+0xae>
}
ffffffffc0201c54:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c56:	1541                	addi	a0,a0,-16
ffffffffc0201c58:	4581                	li	a1,0
}
ffffffffc0201c5a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c5c:	b93d                	j	ffffffffc020189a <slob_free>
        intr_disable();  // 关闭中断
ffffffffc0201c5e:	e02a                	sd	a0,0(sp)
ffffffffc0201c60:	cabfe0ef          	jal	ffffffffc020090a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c64:	000a6797          	auipc	a5,0xa6
ffffffffc0201c68:	89c7b783          	ld	a5,-1892(a5) # ffffffffc02a7500 <bigblocks>
ffffffffc0201c6c:	6502                	ld	a0,0(sp)
        return 1;        // 返回原状态：开启
ffffffffc0201c6e:	4585                	li	a1,1
ffffffffc0201c70:	fbb5                	bnez	a5,ffffffffc0201be4 <kfree+0x20>
ffffffffc0201c72:	e02a                	sd	a0,0(sp)
        intr_enable();  // 重新开启中断
ffffffffc0201c74:	c91fe0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0201c78:	6502                	ld	a0,0(sp)
ffffffffc0201c7a:	bfe9                	j	ffffffffc0201c54 <kfree+0x90>
ffffffffc0201c7c:	e42a                	sd	a0,8(sp)
ffffffffc0201c7e:	e03a                	sd	a4,0(sp)
ffffffffc0201c80:	c85fe0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0201c84:	6522                	ld	a0,8(sp)
ffffffffc0201c86:	6702                	ld	a4,0(sp)
ffffffffc0201c88:	bfad                	j	ffffffffc0201c02 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c8a:	1541                	addi	a0,a0,-16
ffffffffc0201c8c:	4581                	li	a1,0
ffffffffc0201c8e:	b131                	j	ffffffffc020189a <slob_free>
ffffffffc0201c90:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c92:	00004617          	auipc	a2,0x4
ffffffffc0201c96:	62660613          	addi	a2,a2,1574 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc0201c9a:	06b00593          	li	a1,107
ffffffffc0201c9e:	00004517          	auipc	a0,0x4
ffffffffc0201ca2:	63a50513          	addi	a0,a0,1594 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0201ca6:	d82fe0ef          	jal	ffffffffc0200228 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201caa:	86aa                	mv	a3,a0
ffffffffc0201cac:	00005617          	auipc	a2,0x5
ffffffffc0201cb0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0206658 <etext+0xd68>
ffffffffc0201cb4:	07900593          	li	a1,121
ffffffffc0201cb8:	00004517          	auipc	a0,0x4
ffffffffc0201cbc:	62050513          	addi	a0,a0,1568 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0201cc0:	d68fe0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0201cc4 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201cc4:	000a1797          	auipc	a5,0xa1
ffffffffc0201cc8:	7e478793          	addi	a5,a5,2020 # ffffffffc02a34a8 <free_area>
ffffffffc0201ccc:	e79c                	sd	a5,8(a5)
ffffffffc0201cce:	e39c                	sd	a5,0(a5)
// default_init - 初始化默认物理内存管理器
// 初始化空闲链表和空闲页面计数器
default_init(void)
{
    list_init(&free_list);  // 初始化空闲页面链表
    nr_free = 0;           // 空闲页面数置0
ffffffffc0201cd0:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201cd4:	8082                	ret

ffffffffc0201cd6 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201cd6:	000a1517          	auipc	a0,0xa1
ffffffffc0201cda:	7e256503          	lwu	a0,2018(a0) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc0201cde:	8082                	ret

ffffffffc0201ce0 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0201ce0:	711d                	addi	sp,sp,-96
ffffffffc0201ce2:	e0ca                	sd	s2,64(sp)
    return listelm->next;
ffffffffc0201ce4:	000a1917          	auipc	s2,0xa1
ffffffffc0201ce8:	7c490913          	addi	s2,s2,1988 # ffffffffc02a34a8 <free_area>
ffffffffc0201cec:	00893783          	ld	a5,8(s2)
ffffffffc0201cf0:	ec86                	sd	ra,88(sp)
ffffffffc0201cf2:	e8a2                	sd	s0,80(sp)
ffffffffc0201cf4:	e4a6                	sd	s1,72(sp)
ffffffffc0201cf6:	fc4e                	sd	s3,56(sp)
ffffffffc0201cf8:	f852                	sd	s4,48(sp)
ffffffffc0201cfa:	f456                	sd	s5,40(sp)
ffffffffc0201cfc:	f05a                	sd	s6,32(sp)
ffffffffc0201cfe:	ec5e                	sd	s7,24(sp)
ffffffffc0201d00:	e862                	sd	s8,16(sp)
ffffffffc0201d02:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d04:	2f278363          	beq	a5,s2,ffffffffc0201fea <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0201d08:	4401                	li	s0,0
ffffffffc0201d0a:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201d0c:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201d10:	8b09                	andi	a4,a4,2
ffffffffc0201d12:	2e070063          	beqz	a4,ffffffffc0201ff2 <default_check+0x312>
        count++, total += p->property;
ffffffffc0201d16:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201d1a:	679c                	ld	a5,8(a5)
ffffffffc0201d1c:	2485                	addiw	s1,s1,1
ffffffffc0201d1e:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201d20:	ff2796e3          	bne	a5,s2,ffffffffc0201d0c <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0201d24:	89a2                	mv	s3,s0
ffffffffc0201d26:	317000ef          	jal	ffffffffc020283c <nr_free_pages>
ffffffffc0201d2a:	73351463          	bne	a0,s3,ffffffffc0202452 <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201d2e:	4505                	li	a0,1
ffffffffc0201d30:	29b000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201d34:	8a2a                	mv	s4,a0
ffffffffc0201d36:	44050e63          	beqz	a0,ffffffffc0202192 <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201d3a:	4505                	li	a0,1
ffffffffc0201d3c:	28f000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201d40:	89aa                	mv	s3,a0
ffffffffc0201d42:	72050863          	beqz	a0,ffffffffc0202472 <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201d46:	4505                	li	a0,1
ffffffffc0201d48:	283000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201d4c:	8aaa                	mv	s5,a0
ffffffffc0201d4e:	4c050263          	beqz	a0,ffffffffc0202212 <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201d52:	40a987b3          	sub	a5,s3,a0
ffffffffc0201d56:	40aa0733          	sub	a4,s4,a0
ffffffffc0201d5a:	0017b793          	seqz	a5,a5
ffffffffc0201d5e:	00173713          	seqz	a4,a4
ffffffffc0201d62:	8fd9                	or	a5,a5,a4
ffffffffc0201d64:	30079763          	bnez	a5,ffffffffc0202072 <default_check+0x392>
ffffffffc0201d68:	313a0563          	beq	s4,s3,ffffffffc0202072 <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201d6c:	000a2783          	lw	a5,0(s4)
ffffffffc0201d70:	2a079163          	bnez	a5,ffffffffc0202012 <default_check+0x332>
ffffffffc0201d74:	0009a783          	lw	a5,0(s3)
ffffffffc0201d78:	28079d63          	bnez	a5,ffffffffc0202012 <default_check+0x332>
ffffffffc0201d7c:	411c                	lw	a5,0(a0)
ffffffffc0201d7e:	28079a63          	bnez	a5,ffffffffc0202012 <default_check+0x332>
    return page - pages + nbase;
ffffffffc0201d82:	000a5797          	auipc	a5,0xa5
ffffffffc0201d86:	7ae7b783          	ld	a5,1966(a5) # ffffffffc02a7530 <pages>
ffffffffc0201d8a:	00006617          	auipc	a2,0x6
ffffffffc0201d8e:	cb663603          	ld	a2,-842(a2) # ffffffffc0207a40 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201d92:	000a5697          	auipc	a3,0xa5
ffffffffc0201d96:	7966b683          	ld	a3,1942(a3) # ffffffffc02a7528 <npage>
ffffffffc0201d9a:	40fa0733          	sub	a4,s4,a5
ffffffffc0201d9e:	8719                	srai	a4,a4,0x6
ffffffffc0201da0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201da2:	0732                	slli	a4,a4,0xc
ffffffffc0201da4:	06b2                	slli	a3,a3,0xc
ffffffffc0201da6:	2ad77663          	bgeu	a4,a3,ffffffffc0202052 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0201daa:	40f98733          	sub	a4,s3,a5
ffffffffc0201dae:	8719                	srai	a4,a4,0x6
ffffffffc0201db0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201db2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201db4:	4cd77f63          	bgeu	a4,a3,ffffffffc0202292 <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc0201db8:	40f507b3          	sub	a5,a0,a5
ffffffffc0201dbc:	8799                	srai	a5,a5,0x6
ffffffffc0201dbe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201dc0:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201dc2:	32d7f863          	bgeu	a5,a3,ffffffffc02020f2 <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc0201dc6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201dc8:	00093c03          	ld	s8,0(s2)
ffffffffc0201dcc:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0201dd0:	000a1b17          	auipc	s6,0xa1
ffffffffc0201dd4:	6e8b2b03          	lw	s6,1768(s6) # ffffffffc02a34b8 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0201dd8:	01293023          	sd	s2,0(s2)
ffffffffc0201ddc:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0201de0:	000a1797          	auipc	a5,0xa1
ffffffffc0201de4:	6c07ac23          	sw	zero,1752(a5) # ffffffffc02a34b8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201de8:	1e3000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201dec:	2e051363          	bnez	a0,ffffffffc02020d2 <default_check+0x3f2>
    free_page(p0);
ffffffffc0201df0:	8552                	mv	a0,s4
ffffffffc0201df2:	4585                	li	a1,1
ffffffffc0201df4:	211000ef          	jal	ffffffffc0202804 <free_pages>
    free_page(p1);
ffffffffc0201df8:	854e                	mv	a0,s3
ffffffffc0201dfa:	4585                	li	a1,1
ffffffffc0201dfc:	209000ef          	jal	ffffffffc0202804 <free_pages>
    free_page(p2);
ffffffffc0201e00:	8556                	mv	a0,s5
ffffffffc0201e02:	4585                	li	a1,1
ffffffffc0201e04:	201000ef          	jal	ffffffffc0202804 <free_pages>
    assert(nr_free == 3);
ffffffffc0201e08:	000a1717          	auipc	a4,0xa1
ffffffffc0201e0c:	6b072703          	lw	a4,1712(a4) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc0201e10:	478d                	li	a5,3
ffffffffc0201e12:	2af71063          	bne	a4,a5,ffffffffc02020b2 <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201e16:	4505                	li	a0,1
ffffffffc0201e18:	1b3000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201e1c:	89aa                	mv	s3,a0
ffffffffc0201e1e:	26050a63          	beqz	a0,ffffffffc0202092 <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201e22:	4505                	li	a0,1
ffffffffc0201e24:	1a7000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201e28:	8aaa                	mv	s5,a0
ffffffffc0201e2a:	3c050463          	beqz	a0,ffffffffc02021f2 <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201e2e:	4505                	li	a0,1
ffffffffc0201e30:	19b000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201e34:	8a2a                	mv	s4,a0
ffffffffc0201e36:	38050e63          	beqz	a0,ffffffffc02021d2 <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc0201e3a:	4505                	li	a0,1
ffffffffc0201e3c:	18f000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201e40:	36051963          	bnez	a0,ffffffffc02021b2 <default_check+0x4d2>
    free_page(p0);
ffffffffc0201e44:	4585                	li	a1,1
ffffffffc0201e46:	854e                	mv	a0,s3
ffffffffc0201e48:	1bd000ef          	jal	ffffffffc0202804 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201e4c:	00893783          	ld	a5,8(s2)
ffffffffc0201e50:	1f278163          	beq	a5,s2,ffffffffc0202032 <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc0201e54:	4505                	li	a0,1
ffffffffc0201e56:	175000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201e5a:	8caa                	mv	s9,a0
ffffffffc0201e5c:	30a99b63          	bne	s3,a0,ffffffffc0202172 <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc0201e60:	4505                	li	a0,1
ffffffffc0201e62:	169000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201e66:	2e051663          	bnez	a0,ffffffffc0202152 <default_check+0x472>
    assert(nr_free == 0);
ffffffffc0201e6a:	000a1797          	auipc	a5,0xa1
ffffffffc0201e6e:	64e7a783          	lw	a5,1614(a5) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc0201e72:	2c079063          	bnez	a5,ffffffffc0202132 <default_check+0x452>
    free_page(p);
ffffffffc0201e76:	8566                	mv	a0,s9
ffffffffc0201e78:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201e7a:	01893023          	sd	s8,0(s2)
ffffffffc0201e7e:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201e82:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201e86:	17f000ef          	jal	ffffffffc0202804 <free_pages>
    free_page(p1);
ffffffffc0201e8a:	8556                	mv	a0,s5
ffffffffc0201e8c:	4585                	li	a1,1
ffffffffc0201e8e:	177000ef          	jal	ffffffffc0202804 <free_pages>
    free_page(p2);
ffffffffc0201e92:	8552                	mv	a0,s4
ffffffffc0201e94:	4585                	li	a1,1
ffffffffc0201e96:	16f000ef          	jal	ffffffffc0202804 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201e9a:	4515                	li	a0,5
ffffffffc0201e9c:	12f000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201ea0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201ea2:	26050863          	beqz	a0,ffffffffc0202112 <default_check+0x432>
ffffffffc0201ea6:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc0201ea8:	8b89                	andi	a5,a5,2
ffffffffc0201eaa:	54079463          	bnez	a5,ffffffffc02023f2 <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201eae:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201eb0:	00093b83          	ld	s7,0(s2)
ffffffffc0201eb4:	00893b03          	ld	s6,8(s2)
ffffffffc0201eb8:	01293023          	sd	s2,0(s2)
ffffffffc0201ebc:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0201ec0:	10b000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201ec4:	50051763          	bnez	a0,ffffffffc02023d2 <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201ec8:	08098a13          	addi	s4,s3,128
ffffffffc0201ecc:	8552                	mv	a0,s4
ffffffffc0201ece:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201ed0:	000a1c17          	auipc	s8,0xa1
ffffffffc0201ed4:	5e8c2c03          	lw	s8,1512(s8) # ffffffffc02a34b8 <free_area+0x10>
    nr_free = 0;
ffffffffc0201ed8:	000a1797          	auipc	a5,0xa1
ffffffffc0201edc:	5e07a023          	sw	zero,1504(a5) # ffffffffc02a34b8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201ee0:	125000ef          	jal	ffffffffc0202804 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201ee4:	4511                	li	a0,4
ffffffffc0201ee6:	0e5000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201eea:	4c051463          	bnez	a0,ffffffffc02023b2 <default_check+0x6d2>
ffffffffc0201eee:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201ef2:	8b89                	andi	a5,a5,2
ffffffffc0201ef4:	48078f63          	beqz	a5,ffffffffc0202392 <default_check+0x6b2>
ffffffffc0201ef8:	0909a503          	lw	a0,144(s3)
ffffffffc0201efc:	478d                	li	a5,3
ffffffffc0201efe:	48f51a63          	bne	a0,a5,ffffffffc0202392 <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201f02:	0c9000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201f06:	8aaa                	mv	s5,a0
ffffffffc0201f08:	46050563          	beqz	a0,ffffffffc0202372 <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc0201f0c:	4505                	li	a0,1
ffffffffc0201f0e:	0bd000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201f12:	44051063          	bnez	a0,ffffffffc0202352 <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201f16:	415a1e63          	bne	s4,s5,ffffffffc0202332 <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201f1a:	4585                	li	a1,1
ffffffffc0201f1c:	854e                	mv	a0,s3
ffffffffc0201f1e:	0e7000ef          	jal	ffffffffc0202804 <free_pages>
    free_pages(p1, 3);
ffffffffc0201f22:	8552                	mv	a0,s4
ffffffffc0201f24:	458d                	li	a1,3
ffffffffc0201f26:	0df000ef          	jal	ffffffffc0202804 <free_pages>
ffffffffc0201f2a:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201f2e:	8b89                	andi	a5,a5,2
ffffffffc0201f30:	3e078163          	beqz	a5,ffffffffc0202312 <default_check+0x632>
ffffffffc0201f34:	0109aa83          	lw	s5,16(s3)
ffffffffc0201f38:	4785                	li	a5,1
ffffffffc0201f3a:	3cfa9c63          	bne	s5,a5,ffffffffc0202312 <default_check+0x632>
ffffffffc0201f3e:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201f42:	8b89                	andi	a5,a5,2
ffffffffc0201f44:	3a078763          	beqz	a5,ffffffffc02022f2 <default_check+0x612>
ffffffffc0201f48:	010a2703          	lw	a4,16(s4)
ffffffffc0201f4c:	478d                	li	a5,3
ffffffffc0201f4e:	3af71263          	bne	a4,a5,ffffffffc02022f2 <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201f52:	8556                	mv	a0,s5
ffffffffc0201f54:	077000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201f58:	36a99d63          	bne	s3,a0,ffffffffc02022d2 <default_check+0x5f2>
    free_page(p0);
ffffffffc0201f5c:	85d6                	mv	a1,s5
ffffffffc0201f5e:	0a7000ef          	jal	ffffffffc0202804 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201f62:	4509                	li	a0,2
ffffffffc0201f64:	067000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201f68:	34aa1563          	bne	s4,a0,ffffffffc02022b2 <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc0201f6c:	4589                	li	a1,2
ffffffffc0201f6e:	097000ef          	jal	ffffffffc0202804 <free_pages>
    free_page(p2);
ffffffffc0201f72:	04098513          	addi	a0,s3,64
ffffffffc0201f76:	85d6                	mv	a1,s5
ffffffffc0201f78:	08d000ef          	jal	ffffffffc0202804 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201f7c:	4515                	li	a0,5
ffffffffc0201f7e:	04d000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201f82:	89aa                	mv	s3,a0
ffffffffc0201f84:	48050763          	beqz	a0,ffffffffc0202412 <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc0201f88:	8556                	mv	a0,s5
ffffffffc0201f8a:	041000ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0201f8e:	2e051263          	bnez	a0,ffffffffc0202272 <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201f92:	000a1797          	auipc	a5,0xa1
ffffffffc0201f96:	5267a783          	lw	a5,1318(a5) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc0201f9a:	2a079c63          	bnez	a5,ffffffffc0202252 <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201f9e:	854e                	mv	a0,s3
ffffffffc0201fa0:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0201fa2:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0201fa6:	01793023          	sd	s7,0(s2)
ffffffffc0201faa:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0201fae:	057000ef          	jal	ffffffffc0202804 <free_pages>
    return listelm->next;
ffffffffc0201fb2:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fb6:	01278963          	beq	a5,s2,ffffffffc0201fc8 <default_check+0x2e8>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0201fba:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201fbe:	679c                	ld	a5,8(a5)
ffffffffc0201fc0:	34fd                	addiw	s1,s1,-1
ffffffffc0201fc2:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fc4:	ff279be3          	bne	a5,s2,ffffffffc0201fba <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc0201fc8:	26049563          	bnez	s1,ffffffffc0202232 <default_check+0x552>
    assert(total == 0);
ffffffffc0201fcc:	46041363          	bnez	s0,ffffffffc0202432 <default_check+0x752>
}
ffffffffc0201fd0:	60e6                	ld	ra,88(sp)
ffffffffc0201fd2:	6446                	ld	s0,80(sp)
ffffffffc0201fd4:	64a6                	ld	s1,72(sp)
ffffffffc0201fd6:	6906                	ld	s2,64(sp)
ffffffffc0201fd8:	79e2                	ld	s3,56(sp)
ffffffffc0201fda:	7a42                	ld	s4,48(sp)
ffffffffc0201fdc:	7aa2                	ld	s5,40(sp)
ffffffffc0201fde:	7b02                	ld	s6,32(sp)
ffffffffc0201fe0:	6be2                	ld	s7,24(sp)
ffffffffc0201fe2:	6c42                	ld	s8,16(sp)
ffffffffc0201fe4:	6ca2                	ld	s9,8(sp)
ffffffffc0201fe6:	6125                	addi	sp,sp,96
ffffffffc0201fe8:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201fea:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201fec:	4401                	li	s0,0
ffffffffc0201fee:	4481                	li	s1,0
ffffffffc0201ff0:	bb1d                	j	ffffffffc0201d26 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0201ff2:	00004697          	auipc	a3,0x4
ffffffffc0201ff6:	68e68693          	addi	a3,a3,1678 # ffffffffc0206680 <etext+0xd90>
ffffffffc0201ffa:	00004617          	auipc	a2,0x4
ffffffffc0201ffe:	37660613          	addi	a2,a2,886 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202002:	11700593          	li	a1,279
ffffffffc0202006:	00004517          	auipc	a0,0x4
ffffffffc020200a:	68a50513          	addi	a0,a0,1674 # ffffffffc0206690 <etext+0xda0>
ffffffffc020200e:	a1afe0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202012:	00004697          	auipc	a3,0x4
ffffffffc0202016:	73e68693          	addi	a3,a3,1854 # ffffffffc0206750 <etext+0xe60>
ffffffffc020201a:	00004617          	auipc	a2,0x4
ffffffffc020201e:	35660613          	addi	a2,a2,854 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202022:	0e300593          	li	a1,227
ffffffffc0202026:	00004517          	auipc	a0,0x4
ffffffffc020202a:	66a50513          	addi	a0,a0,1642 # ffffffffc0206690 <etext+0xda0>
ffffffffc020202e:	9fafe0ef          	jal	ffffffffc0200228 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202032:	00004697          	auipc	a3,0x4
ffffffffc0202036:	7e668693          	addi	a3,a3,2022 # ffffffffc0206818 <etext+0xf28>
ffffffffc020203a:	00004617          	auipc	a2,0x4
ffffffffc020203e:	33660613          	addi	a2,a2,822 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202042:	0fe00593          	li	a1,254
ffffffffc0202046:	00004517          	auipc	a0,0x4
ffffffffc020204a:	64a50513          	addi	a0,a0,1610 # ffffffffc0206690 <etext+0xda0>
ffffffffc020204e:	9dafe0ef          	jal	ffffffffc0200228 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202052:	00004697          	auipc	a3,0x4
ffffffffc0202056:	73e68693          	addi	a3,a3,1854 # ffffffffc0206790 <etext+0xea0>
ffffffffc020205a:	00004617          	auipc	a2,0x4
ffffffffc020205e:	31660613          	addi	a2,a2,790 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202062:	0e500593          	li	a1,229
ffffffffc0202066:	00004517          	auipc	a0,0x4
ffffffffc020206a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206690 <etext+0xda0>
ffffffffc020206e:	9bafe0ef          	jal	ffffffffc0200228 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202072:	00004697          	auipc	a3,0x4
ffffffffc0202076:	6b668693          	addi	a3,a3,1718 # ffffffffc0206728 <etext+0xe38>
ffffffffc020207a:	00004617          	auipc	a2,0x4
ffffffffc020207e:	2f660613          	addi	a2,a2,758 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202082:	0e200593          	li	a1,226
ffffffffc0202086:	00004517          	auipc	a0,0x4
ffffffffc020208a:	60a50513          	addi	a0,a0,1546 # ffffffffc0206690 <etext+0xda0>
ffffffffc020208e:	99afe0ef          	jal	ffffffffc0200228 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202092:	00004697          	auipc	a3,0x4
ffffffffc0202096:	63668693          	addi	a3,a3,1590 # ffffffffc02066c8 <etext+0xdd8>
ffffffffc020209a:	00004617          	auipc	a2,0x4
ffffffffc020209e:	2d660613          	addi	a2,a2,726 # ffffffffc0206370 <etext+0xa80>
ffffffffc02020a2:	0f700593          	li	a1,247
ffffffffc02020a6:	00004517          	auipc	a0,0x4
ffffffffc02020aa:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206690 <etext+0xda0>
ffffffffc02020ae:	97afe0ef          	jal	ffffffffc0200228 <__panic>
    assert(nr_free == 3);
ffffffffc02020b2:	00004697          	auipc	a3,0x4
ffffffffc02020b6:	75668693          	addi	a3,a3,1878 # ffffffffc0206808 <etext+0xf18>
ffffffffc02020ba:	00004617          	auipc	a2,0x4
ffffffffc02020be:	2b660613          	addi	a2,a2,694 # ffffffffc0206370 <etext+0xa80>
ffffffffc02020c2:	0f500593          	li	a1,245
ffffffffc02020c6:	00004517          	auipc	a0,0x4
ffffffffc02020ca:	5ca50513          	addi	a0,a0,1482 # ffffffffc0206690 <etext+0xda0>
ffffffffc02020ce:	95afe0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020d2:	00004697          	auipc	a3,0x4
ffffffffc02020d6:	71e68693          	addi	a3,a3,1822 # ffffffffc02067f0 <etext+0xf00>
ffffffffc02020da:	00004617          	auipc	a2,0x4
ffffffffc02020de:	29660613          	addi	a2,a2,662 # ffffffffc0206370 <etext+0xa80>
ffffffffc02020e2:	0f000593          	li	a1,240
ffffffffc02020e6:	00004517          	auipc	a0,0x4
ffffffffc02020ea:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206690 <etext+0xda0>
ffffffffc02020ee:	93afe0ef          	jal	ffffffffc0200228 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02020f2:	00004697          	auipc	a3,0x4
ffffffffc02020f6:	6de68693          	addi	a3,a3,1758 # ffffffffc02067d0 <etext+0xee0>
ffffffffc02020fa:	00004617          	auipc	a2,0x4
ffffffffc02020fe:	27660613          	addi	a2,a2,630 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202102:	0e700593          	li	a1,231
ffffffffc0202106:	00004517          	auipc	a0,0x4
ffffffffc020210a:	58a50513          	addi	a0,a0,1418 # ffffffffc0206690 <etext+0xda0>
ffffffffc020210e:	91afe0ef          	jal	ffffffffc0200228 <__panic>
    assert(p0 != NULL);
ffffffffc0202112:	00004697          	auipc	a3,0x4
ffffffffc0202116:	74e68693          	addi	a3,a3,1870 # ffffffffc0206860 <etext+0xf70>
ffffffffc020211a:	00004617          	auipc	a2,0x4
ffffffffc020211e:	25660613          	addi	a2,a2,598 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202122:	11f00593          	li	a1,287
ffffffffc0202126:	00004517          	auipc	a0,0x4
ffffffffc020212a:	56a50513          	addi	a0,a0,1386 # ffffffffc0206690 <etext+0xda0>
ffffffffc020212e:	8fafe0ef          	jal	ffffffffc0200228 <__panic>
    assert(nr_free == 0);
ffffffffc0202132:	00004697          	auipc	a3,0x4
ffffffffc0202136:	71e68693          	addi	a3,a3,1822 # ffffffffc0206850 <etext+0xf60>
ffffffffc020213a:	00004617          	auipc	a2,0x4
ffffffffc020213e:	23660613          	addi	a2,a2,566 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202142:	10400593          	li	a1,260
ffffffffc0202146:	00004517          	auipc	a0,0x4
ffffffffc020214a:	54a50513          	addi	a0,a0,1354 # ffffffffc0206690 <etext+0xda0>
ffffffffc020214e:	8dafe0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202152:	00004697          	auipc	a3,0x4
ffffffffc0202156:	69e68693          	addi	a3,a3,1694 # ffffffffc02067f0 <etext+0xf00>
ffffffffc020215a:	00004617          	auipc	a2,0x4
ffffffffc020215e:	21660613          	addi	a2,a2,534 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202162:	10200593          	li	a1,258
ffffffffc0202166:	00004517          	auipc	a0,0x4
ffffffffc020216a:	52a50513          	addi	a0,a0,1322 # ffffffffc0206690 <etext+0xda0>
ffffffffc020216e:	8bafe0ef          	jal	ffffffffc0200228 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202172:	00004697          	auipc	a3,0x4
ffffffffc0202176:	6be68693          	addi	a3,a3,1726 # ffffffffc0206830 <etext+0xf40>
ffffffffc020217a:	00004617          	auipc	a2,0x4
ffffffffc020217e:	1f660613          	addi	a2,a2,502 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202182:	10100593          	li	a1,257
ffffffffc0202186:	00004517          	auipc	a0,0x4
ffffffffc020218a:	50a50513          	addi	a0,a0,1290 # ffffffffc0206690 <etext+0xda0>
ffffffffc020218e:	89afe0ef          	jal	ffffffffc0200228 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202192:	00004697          	auipc	a3,0x4
ffffffffc0202196:	53668693          	addi	a3,a3,1334 # ffffffffc02066c8 <etext+0xdd8>
ffffffffc020219a:	00004617          	auipc	a2,0x4
ffffffffc020219e:	1d660613          	addi	a2,a2,470 # ffffffffc0206370 <etext+0xa80>
ffffffffc02021a2:	0de00593          	li	a1,222
ffffffffc02021a6:	00004517          	auipc	a0,0x4
ffffffffc02021aa:	4ea50513          	addi	a0,a0,1258 # ffffffffc0206690 <etext+0xda0>
ffffffffc02021ae:	87afe0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021b2:	00004697          	auipc	a3,0x4
ffffffffc02021b6:	63e68693          	addi	a3,a3,1598 # ffffffffc02067f0 <etext+0xf00>
ffffffffc02021ba:	00004617          	auipc	a2,0x4
ffffffffc02021be:	1b660613          	addi	a2,a2,438 # ffffffffc0206370 <etext+0xa80>
ffffffffc02021c2:	0fb00593          	li	a1,251
ffffffffc02021c6:	00004517          	auipc	a0,0x4
ffffffffc02021ca:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206690 <etext+0xda0>
ffffffffc02021ce:	85afe0ef          	jal	ffffffffc0200228 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02021d2:	00004697          	auipc	a3,0x4
ffffffffc02021d6:	53668693          	addi	a3,a3,1334 # ffffffffc0206708 <etext+0xe18>
ffffffffc02021da:	00004617          	auipc	a2,0x4
ffffffffc02021de:	19660613          	addi	a2,a2,406 # ffffffffc0206370 <etext+0xa80>
ffffffffc02021e2:	0f900593          	li	a1,249
ffffffffc02021e6:	00004517          	auipc	a0,0x4
ffffffffc02021ea:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206690 <etext+0xda0>
ffffffffc02021ee:	83afe0ef          	jal	ffffffffc0200228 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02021f2:	00004697          	auipc	a3,0x4
ffffffffc02021f6:	4f668693          	addi	a3,a3,1270 # ffffffffc02066e8 <etext+0xdf8>
ffffffffc02021fa:	00004617          	auipc	a2,0x4
ffffffffc02021fe:	17660613          	addi	a2,a2,374 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202202:	0f800593          	li	a1,248
ffffffffc0202206:	00004517          	auipc	a0,0x4
ffffffffc020220a:	48a50513          	addi	a0,a0,1162 # ffffffffc0206690 <etext+0xda0>
ffffffffc020220e:	81afe0ef          	jal	ffffffffc0200228 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202212:	00004697          	auipc	a3,0x4
ffffffffc0202216:	4f668693          	addi	a3,a3,1270 # ffffffffc0206708 <etext+0xe18>
ffffffffc020221a:	00004617          	auipc	a2,0x4
ffffffffc020221e:	15660613          	addi	a2,a2,342 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202222:	0e000593          	li	a1,224
ffffffffc0202226:	00004517          	auipc	a0,0x4
ffffffffc020222a:	46a50513          	addi	a0,a0,1130 # ffffffffc0206690 <etext+0xda0>
ffffffffc020222e:	ffbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(count == 0);
ffffffffc0202232:	00004697          	auipc	a3,0x4
ffffffffc0202236:	77e68693          	addi	a3,a3,1918 # ffffffffc02069b0 <etext+0x10c0>
ffffffffc020223a:	00004617          	auipc	a2,0x4
ffffffffc020223e:	13660613          	addi	a2,a2,310 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202242:	14d00593          	li	a1,333
ffffffffc0202246:	00004517          	auipc	a0,0x4
ffffffffc020224a:	44a50513          	addi	a0,a0,1098 # ffffffffc0206690 <etext+0xda0>
ffffffffc020224e:	fdbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(nr_free == 0);
ffffffffc0202252:	00004697          	auipc	a3,0x4
ffffffffc0202256:	5fe68693          	addi	a3,a3,1534 # ffffffffc0206850 <etext+0xf60>
ffffffffc020225a:	00004617          	auipc	a2,0x4
ffffffffc020225e:	11660613          	addi	a2,a2,278 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202262:	14100593          	li	a1,321
ffffffffc0202266:	00004517          	auipc	a0,0x4
ffffffffc020226a:	42a50513          	addi	a0,a0,1066 # ffffffffc0206690 <etext+0xda0>
ffffffffc020226e:	fbbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202272:	00004697          	auipc	a3,0x4
ffffffffc0202276:	57e68693          	addi	a3,a3,1406 # ffffffffc02067f0 <etext+0xf00>
ffffffffc020227a:	00004617          	auipc	a2,0x4
ffffffffc020227e:	0f660613          	addi	a2,a2,246 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202282:	13f00593          	li	a1,319
ffffffffc0202286:	00004517          	auipc	a0,0x4
ffffffffc020228a:	40a50513          	addi	a0,a0,1034 # ffffffffc0206690 <etext+0xda0>
ffffffffc020228e:	f9bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202292:	00004697          	auipc	a3,0x4
ffffffffc0202296:	51e68693          	addi	a3,a3,1310 # ffffffffc02067b0 <etext+0xec0>
ffffffffc020229a:	00004617          	auipc	a2,0x4
ffffffffc020229e:	0d660613          	addi	a2,a2,214 # ffffffffc0206370 <etext+0xa80>
ffffffffc02022a2:	0e600593          	li	a1,230
ffffffffc02022a6:	00004517          	auipc	a0,0x4
ffffffffc02022aa:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206690 <etext+0xda0>
ffffffffc02022ae:	f7bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02022b2:	00004697          	auipc	a3,0x4
ffffffffc02022b6:	6be68693          	addi	a3,a3,1726 # ffffffffc0206970 <etext+0x1080>
ffffffffc02022ba:	00004617          	auipc	a2,0x4
ffffffffc02022be:	0b660613          	addi	a2,a2,182 # ffffffffc0206370 <etext+0xa80>
ffffffffc02022c2:	13900593          	li	a1,313
ffffffffc02022c6:	00004517          	auipc	a0,0x4
ffffffffc02022ca:	3ca50513          	addi	a0,a0,970 # ffffffffc0206690 <etext+0xda0>
ffffffffc02022ce:	f5bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02022d2:	00004697          	auipc	a3,0x4
ffffffffc02022d6:	67e68693          	addi	a3,a3,1662 # ffffffffc0206950 <etext+0x1060>
ffffffffc02022da:	00004617          	auipc	a2,0x4
ffffffffc02022de:	09660613          	addi	a2,a2,150 # ffffffffc0206370 <etext+0xa80>
ffffffffc02022e2:	13700593          	li	a1,311
ffffffffc02022e6:	00004517          	auipc	a0,0x4
ffffffffc02022ea:	3aa50513          	addi	a0,a0,938 # ffffffffc0206690 <etext+0xda0>
ffffffffc02022ee:	f3bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02022f2:	00004697          	auipc	a3,0x4
ffffffffc02022f6:	63668693          	addi	a3,a3,1590 # ffffffffc0206928 <etext+0x1038>
ffffffffc02022fa:	00004617          	auipc	a2,0x4
ffffffffc02022fe:	07660613          	addi	a2,a2,118 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202302:	13500593          	li	a1,309
ffffffffc0202306:	00004517          	auipc	a0,0x4
ffffffffc020230a:	38a50513          	addi	a0,a0,906 # ffffffffc0206690 <etext+0xda0>
ffffffffc020230e:	f1bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202312:	00004697          	auipc	a3,0x4
ffffffffc0202316:	5ee68693          	addi	a3,a3,1518 # ffffffffc0206900 <etext+0x1010>
ffffffffc020231a:	00004617          	auipc	a2,0x4
ffffffffc020231e:	05660613          	addi	a2,a2,86 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202322:	13400593          	li	a1,308
ffffffffc0202326:	00004517          	auipc	a0,0x4
ffffffffc020232a:	36a50513          	addi	a0,a0,874 # ffffffffc0206690 <etext+0xda0>
ffffffffc020232e:	efbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202332:	00004697          	auipc	a3,0x4
ffffffffc0202336:	5be68693          	addi	a3,a3,1470 # ffffffffc02068f0 <etext+0x1000>
ffffffffc020233a:	00004617          	auipc	a2,0x4
ffffffffc020233e:	03660613          	addi	a2,a2,54 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202342:	12f00593          	li	a1,303
ffffffffc0202346:	00004517          	auipc	a0,0x4
ffffffffc020234a:	34a50513          	addi	a0,a0,842 # ffffffffc0206690 <etext+0xda0>
ffffffffc020234e:	edbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202352:	00004697          	auipc	a3,0x4
ffffffffc0202356:	49e68693          	addi	a3,a3,1182 # ffffffffc02067f0 <etext+0xf00>
ffffffffc020235a:	00004617          	auipc	a2,0x4
ffffffffc020235e:	01660613          	addi	a2,a2,22 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202362:	12e00593          	li	a1,302
ffffffffc0202366:	00004517          	auipc	a0,0x4
ffffffffc020236a:	32a50513          	addi	a0,a0,810 # ffffffffc0206690 <etext+0xda0>
ffffffffc020236e:	ebbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202372:	00004697          	auipc	a3,0x4
ffffffffc0202376:	55e68693          	addi	a3,a3,1374 # ffffffffc02068d0 <etext+0xfe0>
ffffffffc020237a:	00004617          	auipc	a2,0x4
ffffffffc020237e:	ff660613          	addi	a2,a2,-10 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202382:	12d00593          	li	a1,301
ffffffffc0202386:	00004517          	auipc	a0,0x4
ffffffffc020238a:	30a50513          	addi	a0,a0,778 # ffffffffc0206690 <etext+0xda0>
ffffffffc020238e:	e9bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202392:	00004697          	auipc	a3,0x4
ffffffffc0202396:	50e68693          	addi	a3,a3,1294 # ffffffffc02068a0 <etext+0xfb0>
ffffffffc020239a:	00004617          	auipc	a2,0x4
ffffffffc020239e:	fd660613          	addi	a2,a2,-42 # ffffffffc0206370 <etext+0xa80>
ffffffffc02023a2:	12c00593          	li	a1,300
ffffffffc02023a6:	00004517          	auipc	a0,0x4
ffffffffc02023aa:	2ea50513          	addi	a0,a0,746 # ffffffffc0206690 <etext+0xda0>
ffffffffc02023ae:	e7bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02023b2:	00004697          	auipc	a3,0x4
ffffffffc02023b6:	4d668693          	addi	a3,a3,1238 # ffffffffc0206888 <etext+0xf98>
ffffffffc02023ba:	00004617          	auipc	a2,0x4
ffffffffc02023be:	fb660613          	addi	a2,a2,-74 # ffffffffc0206370 <etext+0xa80>
ffffffffc02023c2:	12b00593          	li	a1,299
ffffffffc02023c6:	00004517          	auipc	a0,0x4
ffffffffc02023ca:	2ca50513          	addi	a0,a0,714 # ffffffffc0206690 <etext+0xda0>
ffffffffc02023ce:	e5bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02023d2:	00004697          	auipc	a3,0x4
ffffffffc02023d6:	41e68693          	addi	a3,a3,1054 # ffffffffc02067f0 <etext+0xf00>
ffffffffc02023da:	00004617          	auipc	a2,0x4
ffffffffc02023de:	f9660613          	addi	a2,a2,-106 # ffffffffc0206370 <etext+0xa80>
ffffffffc02023e2:	12500593          	li	a1,293
ffffffffc02023e6:	00004517          	auipc	a0,0x4
ffffffffc02023ea:	2aa50513          	addi	a0,a0,682 # ffffffffc0206690 <etext+0xda0>
ffffffffc02023ee:	e3bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(!PageProperty(p0));
ffffffffc02023f2:	00004697          	auipc	a3,0x4
ffffffffc02023f6:	47e68693          	addi	a3,a3,1150 # ffffffffc0206870 <etext+0xf80>
ffffffffc02023fa:	00004617          	auipc	a2,0x4
ffffffffc02023fe:	f7660613          	addi	a2,a2,-138 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202402:	12000593          	li	a1,288
ffffffffc0202406:	00004517          	auipc	a0,0x4
ffffffffc020240a:	28a50513          	addi	a0,a0,650 # ffffffffc0206690 <etext+0xda0>
ffffffffc020240e:	e1bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202412:	00004697          	auipc	a3,0x4
ffffffffc0202416:	57e68693          	addi	a3,a3,1406 # ffffffffc0206990 <etext+0x10a0>
ffffffffc020241a:	00004617          	auipc	a2,0x4
ffffffffc020241e:	f5660613          	addi	a2,a2,-170 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202422:	13e00593          	li	a1,318
ffffffffc0202426:	00004517          	auipc	a0,0x4
ffffffffc020242a:	26a50513          	addi	a0,a0,618 # ffffffffc0206690 <etext+0xda0>
ffffffffc020242e:	dfbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(total == 0);
ffffffffc0202432:	00004697          	auipc	a3,0x4
ffffffffc0202436:	58e68693          	addi	a3,a3,1422 # ffffffffc02069c0 <etext+0x10d0>
ffffffffc020243a:	00004617          	auipc	a2,0x4
ffffffffc020243e:	f3660613          	addi	a2,a2,-202 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202442:	14e00593          	li	a1,334
ffffffffc0202446:	00004517          	auipc	a0,0x4
ffffffffc020244a:	24a50513          	addi	a0,a0,586 # ffffffffc0206690 <etext+0xda0>
ffffffffc020244e:	ddbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202452:	00004697          	auipc	a3,0x4
ffffffffc0202456:	25668693          	addi	a3,a3,598 # ffffffffc02066a8 <etext+0xdb8>
ffffffffc020245a:	00004617          	auipc	a2,0x4
ffffffffc020245e:	f1660613          	addi	a2,a2,-234 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202462:	11a00593          	li	a1,282
ffffffffc0202466:	00004517          	auipc	a0,0x4
ffffffffc020246a:	22a50513          	addi	a0,a0,554 # ffffffffc0206690 <etext+0xda0>
ffffffffc020246e:	dbbfd0ef          	jal	ffffffffc0200228 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202472:	00004697          	auipc	a3,0x4
ffffffffc0202476:	27668693          	addi	a3,a3,630 # ffffffffc02066e8 <etext+0xdf8>
ffffffffc020247a:	00004617          	auipc	a2,0x4
ffffffffc020247e:	ef660613          	addi	a2,a2,-266 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202482:	0df00593          	li	a1,223
ffffffffc0202486:	00004517          	auipc	a0,0x4
ffffffffc020248a:	20a50513          	addi	a0,a0,522 # ffffffffc0206690 <etext+0xda0>
ffffffffc020248e:	d9bfd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0202492 <default_free_pages>:
{
ffffffffc0202492:	1141                	addi	sp,sp,-16
ffffffffc0202494:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202496:	14058663          	beqz	a1,ffffffffc02025e2 <default_free_pages+0x150>
    for (; p != base + n; p++)
ffffffffc020249a:	00659713          	slli	a4,a1,0x6
ffffffffc020249e:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;  // 起始页面指针
ffffffffc02024a2:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02024a4:	c30d                	beqz	a4,ffffffffc02024c6 <default_free_pages+0x34>
ffffffffc02024a6:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02024a8:	8b05                	andi	a4,a4,1
ffffffffc02024aa:	10071c63          	bnez	a4,ffffffffc02025c2 <default_free_pages+0x130>
ffffffffc02024ae:	6798                	ld	a4,8(a5)
ffffffffc02024b0:	8b09                	andi	a4,a4,2
ffffffffc02024b2:	10071863          	bnez	a4,ffffffffc02025c2 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc02024b6:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc02024ba:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02024be:	04078793          	addi	a5,a5,64
ffffffffc02024c2:	fed792e3          	bne	a5,a3,ffffffffc02024a6 <default_free_pages+0x14>
    base->property = n;
ffffffffc02024c6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02024c8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024cc:	4789                	li	a5,2
ffffffffc02024ce:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02024d2:	000a1717          	auipc	a4,0xa1
ffffffffc02024d6:	fe672703          	lw	a4,-26(a4) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc02024da:	000a1697          	auipc	a3,0xa1
ffffffffc02024de:	fce68693          	addi	a3,a3,-50 # ffffffffc02a34a8 <free_area>
    return list->next == list;
ffffffffc02024e2:	669c                	ld	a5,8(a3)
ffffffffc02024e4:	9f2d                	addw	a4,a4,a1
ffffffffc02024e6:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc02024e8:	0ad78163          	beq	a5,a3,ffffffffc020258a <default_free_pages+0xf8>
            struct Page *page = le2page(le, page_link);
ffffffffc02024ec:	fe878713          	addi	a4,a5,-24
ffffffffc02024f0:	4581                	li	a1,0
ffffffffc02024f2:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc02024f6:	00e56a63          	bltu	a0,a4,ffffffffc020250a <default_free_pages+0x78>
    return listelm->next;
ffffffffc02024fa:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02024fc:	04d70c63          	beq	a4,a3,ffffffffc0202554 <default_free_pages+0xc2>
    struct Page *p = base;  // 起始页面指针
ffffffffc0202500:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0202502:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0202506:	fee57ae3          	bgeu	a0,a4,ffffffffc02024fa <default_free_pages+0x68>
ffffffffc020250a:	c199                	beqz	a1,ffffffffc0202510 <default_free_pages+0x7e>
ffffffffc020250c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202510:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202512:	e390                	sd	a2,0(a5)
ffffffffc0202514:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0202516:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0202518:	f11c                	sd	a5,32(a0)
    if (le != &free_list)
ffffffffc020251a:	00d70d63          	beq	a4,a3,ffffffffc0202534 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020251e:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0202522:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0202526:	02059813          	slli	a6,a1,0x20
ffffffffc020252a:	01a85793          	srli	a5,a6,0x1a
ffffffffc020252e:	97b2                	add	a5,a5,a2
ffffffffc0202530:	02f50c63          	beq	a0,a5,ffffffffc0202568 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202534:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0202536:	00d78c63          	beq	a5,a3,ffffffffc020254e <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc020253a:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020253c:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc0202540:	02061593          	slli	a1,a2,0x20
ffffffffc0202544:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202548:	972a                	add	a4,a4,a0
ffffffffc020254a:	04e68c63          	beq	a3,a4,ffffffffc02025a2 <default_free_pages+0x110>
}
ffffffffc020254e:	60a2                	ld	ra,8(sp)
ffffffffc0202550:	0141                	addi	sp,sp,16
ffffffffc0202552:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202554:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202556:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202558:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020255a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020255c:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc020255e:	02d70f63          	beq	a4,a3,ffffffffc020259c <default_free_pages+0x10a>
ffffffffc0202562:	4585                	li	a1,1
    struct Page *p = base;  // 起始页面指针
ffffffffc0202564:	87ba                	mv	a5,a4
ffffffffc0202566:	bf71                	j	ffffffffc0202502 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202568:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020256a:	5875                	li	a6,-3
ffffffffc020256c:	9fad                	addw	a5,a5,a1
ffffffffc020256e:	fef72c23          	sw	a5,-8(a4)
ffffffffc0202572:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202576:	01853803          	ld	a6,24(a0)
ffffffffc020257a:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020257c:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc020257e:	00b83423          	sd	a1,8(a6) # fffffffffffff008 <end+0x3fd57ab0>
    return listelm->next;
ffffffffc0202582:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0202584:	0105b023          	sd	a6,0(a1) # 1000 <_binary_obj___user_softint_out_size-0x7c08>
ffffffffc0202588:	b77d                	j	ffffffffc0202536 <default_free_pages+0xa4>
}
ffffffffc020258a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020258c:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0202590:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202592:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0202594:	e398                	sd	a4,0(a5)
ffffffffc0202596:	e798                	sd	a4,8(a5)
}
ffffffffc0202598:	0141                	addi	sp,sp,16
ffffffffc020259a:	8082                	ret
ffffffffc020259c:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020259e:	873e                	mv	a4,a5
ffffffffc02025a0:	bfad                	j	ffffffffc020251a <default_free_pages+0x88>
            base->property += p->property;
ffffffffc02025a2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02025a6:	56f5                	li	a3,-3
ffffffffc02025a8:	9f31                	addw	a4,a4,a2
ffffffffc02025aa:	c918                	sw	a4,16(a0)
ffffffffc02025ac:	ff078713          	addi	a4,a5,-16
ffffffffc02025b0:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02025b4:	6398                	ld	a4,0(a5)
ffffffffc02025b6:	679c                	ld	a5,8(a5)
}
ffffffffc02025b8:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02025ba:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02025bc:	e398                	sd	a4,0(a5)
ffffffffc02025be:	0141                	addi	sp,sp,16
ffffffffc02025c0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02025c2:	00004697          	auipc	a3,0x4
ffffffffc02025c6:	41668693          	addi	a3,a3,1046 # ffffffffc02069d8 <etext+0x10e8>
ffffffffc02025ca:	00004617          	auipc	a2,0x4
ffffffffc02025ce:	da660613          	addi	a2,a2,-602 # ffffffffc0206370 <etext+0xa80>
ffffffffc02025d2:	09b00593          	li	a1,155
ffffffffc02025d6:	00004517          	auipc	a0,0x4
ffffffffc02025da:	0ba50513          	addi	a0,a0,186 # ffffffffc0206690 <etext+0xda0>
ffffffffc02025de:	c4bfd0ef          	jal	ffffffffc0200228 <__panic>
    assert(n > 0);
ffffffffc02025e2:	00004697          	auipc	a3,0x4
ffffffffc02025e6:	3ee68693          	addi	a3,a3,1006 # ffffffffc02069d0 <etext+0x10e0>
ffffffffc02025ea:	00004617          	auipc	a2,0x4
ffffffffc02025ee:	d8660613          	addi	a2,a2,-634 # ffffffffc0206370 <etext+0xa80>
ffffffffc02025f2:	09700593          	li	a1,151
ffffffffc02025f6:	00004517          	auipc	a0,0x4
ffffffffc02025fa:	09a50513          	addi	a0,a0,154 # ffffffffc0206690 <etext+0xda0>
ffffffffc02025fe:	c2bfd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0202602 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202602:	c951                	beqz	a0,ffffffffc0202696 <default_alloc_pages+0x94>
    if (n > nr_free)  // 检查是否有足够的空闲页面
ffffffffc0202604:	000a1597          	auipc	a1,0xa1
ffffffffc0202608:	eb45a583          	lw	a1,-332(a1) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc020260c:	86aa                	mv	a3,a0
ffffffffc020260e:	02059793          	slli	a5,a1,0x20
ffffffffc0202612:	9381                	srli	a5,a5,0x20
ffffffffc0202614:	00a7ef63          	bltu	a5,a0,ffffffffc0202632 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0202618:	000a1617          	auipc	a2,0xa1
ffffffffc020261c:	e9060613          	addi	a2,a2,-368 # ffffffffc02a34a8 <free_area>
ffffffffc0202620:	87b2                	mv	a5,a2
ffffffffc0202622:	a029                	j	ffffffffc020262c <default_alloc_pages+0x2a>
        if (p->property >= n)
ffffffffc0202624:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0202628:	00d77763          	bgeu	a4,a3,ffffffffc0202636 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc020262c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020262e:	fec79be3          	bne	a5,a2,ffffffffc0202624 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0202632:	4501                	li	a0,0
}
ffffffffc0202634:	8082                	ret
        if (page->property > n)
ffffffffc0202636:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc020263a:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020263e:	6798                	ld	a4,8(a5)
ffffffffc0202640:	02089313          	slli	t1,a7,0x20
ffffffffc0202644:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0202648:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020264c:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0202650:	fe878513          	addi	a0,a5,-24
        if (page->property > n)
ffffffffc0202654:	0266fa63          	bgeu	a3,t1,ffffffffc0202688 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0202658:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc020265c:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc0202660:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0202662:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202666:	00870313          	addi	t1,a4,8
ffffffffc020266a:	4889                	li	a7,2
ffffffffc020266c:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202670:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0202674:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc0202678:	0068b023          	sd	t1,0(a7)
ffffffffc020267c:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc0202680:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0202684:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0202688:	9d95                	subw	a1,a1,a3
ffffffffc020268a:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020268c:	5775                	li	a4,-3
ffffffffc020268e:	17c1                	addi	a5,a5,-16
ffffffffc0202690:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202694:	8082                	ret
{
ffffffffc0202696:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202698:	00004697          	auipc	a3,0x4
ffffffffc020269c:	33868693          	addi	a3,a3,824 # ffffffffc02069d0 <etext+0x10e0>
ffffffffc02026a0:	00004617          	auipc	a2,0x4
ffffffffc02026a4:	cd060613          	addi	a2,a2,-816 # ffffffffc0206370 <etext+0xa80>
ffffffffc02026a8:	07100593          	li	a1,113
ffffffffc02026ac:	00004517          	auipc	a0,0x4
ffffffffc02026b0:	fe450513          	addi	a0,a0,-28 # ffffffffc0206690 <etext+0xda0>
{
ffffffffc02026b4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026b6:	b73fd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02026ba <default_init_memmap>:
{
ffffffffc02026ba:	1141                	addi	sp,sp,-16
ffffffffc02026bc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02026be:	c9e1                	beqz	a1,ffffffffc020278e <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc02026c0:	00659713          	slli	a4,a1,0x6
ffffffffc02026c4:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02026c8:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02026ca:	cf11                	beqz	a4,ffffffffc02026e6 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02026cc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02026ce:	8b05                	andi	a4,a4,1
ffffffffc02026d0:	cf59                	beqz	a4,ffffffffc020276e <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02026d2:	0007a823          	sw	zero,16(a5)
ffffffffc02026d6:	0007b423          	sd	zero,8(a5)
ffffffffc02026da:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02026de:	04078793          	addi	a5,a5,64
ffffffffc02026e2:	fed795e3          	bne	a5,a3,ffffffffc02026cc <default_init_memmap+0x12>
    base->property = n;
ffffffffc02026e6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02026e8:	4789                	li	a5,2
ffffffffc02026ea:	00850713          	addi	a4,a0,8
ffffffffc02026ee:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02026f2:	000a1717          	auipc	a4,0xa1
ffffffffc02026f6:	dc672703          	lw	a4,-570(a4) # ffffffffc02a34b8 <free_area+0x10>
ffffffffc02026fa:	000a1697          	auipc	a3,0xa1
ffffffffc02026fe:	dae68693          	addi	a3,a3,-594 # ffffffffc02a34a8 <free_area>
    return list->next == list;
ffffffffc0202702:	669c                	ld	a5,8(a3)
ffffffffc0202704:	9f2d                	addw	a4,a4,a1
ffffffffc0202706:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc0202708:	04d78663          	beq	a5,a3,ffffffffc0202754 <default_init_memmap+0x9a>
            struct Page *page = le2page(le, page_link);
ffffffffc020270c:	fe878713          	addi	a4,a5,-24
ffffffffc0202710:	4581                	li	a1,0
ffffffffc0202712:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0202716:	00e56a63          	bltu	a0,a4,ffffffffc020272a <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020271a:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020271c:	02d70263          	beq	a4,a3,ffffffffc0202740 <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc0202720:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0202722:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0202726:	fee57ae3          	bgeu	a0,a4,ffffffffc020271a <default_init_memmap+0x60>
ffffffffc020272a:	c199                	beqz	a1,ffffffffc0202730 <default_init_memmap+0x76>
ffffffffc020272c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202730:	6398                	ld	a4,0(a5)
}
ffffffffc0202732:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202734:	e390                	sd	a2,0(a5)
ffffffffc0202736:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0202738:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc020273a:	f11c                	sd	a5,32(a0)
ffffffffc020273c:	0141                	addi	sp,sp,16
ffffffffc020273e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202740:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202742:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202744:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202746:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0202748:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc020274a:	00d70e63          	beq	a4,a3,ffffffffc0202766 <default_init_memmap+0xac>
ffffffffc020274e:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0202750:	87ba                	mv	a5,a4
ffffffffc0202752:	bfc1                	j	ffffffffc0202722 <default_init_memmap+0x68>
}
ffffffffc0202754:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0202756:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020275a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020275c:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc020275e:	e398                	sd	a4,0(a5)
ffffffffc0202760:	e798                	sd	a4,8(a5)
}
ffffffffc0202762:	0141                	addi	sp,sp,16
ffffffffc0202764:	8082                	ret
ffffffffc0202766:	60a2                	ld	ra,8(sp)
ffffffffc0202768:	e290                	sd	a2,0(a3)
ffffffffc020276a:	0141                	addi	sp,sp,16
ffffffffc020276c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020276e:	00004697          	auipc	a3,0x4
ffffffffc0202772:	29268693          	addi	a3,a3,658 # ffffffffc0206a00 <etext+0x1110>
ffffffffc0202776:	00004617          	auipc	a2,0x4
ffffffffc020277a:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0206370 <etext+0xa80>
ffffffffc020277e:	04e00593          	li	a1,78
ffffffffc0202782:	00004517          	auipc	a0,0x4
ffffffffc0202786:	f0e50513          	addi	a0,a0,-242 # ffffffffc0206690 <etext+0xda0>
ffffffffc020278a:	a9ffd0ef          	jal	ffffffffc0200228 <__panic>
    assert(n > 0);
ffffffffc020278e:	00004697          	auipc	a3,0x4
ffffffffc0202792:	24268693          	addi	a3,a3,578 # ffffffffc02069d0 <etext+0x10e0>
ffffffffc0202796:	00004617          	auipc	a2,0x4
ffffffffc020279a:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206370 <etext+0xa80>
ffffffffc020279e:	04a00593          	li	a1,74
ffffffffc02027a2:	00004517          	auipc	a0,0x4
ffffffffc02027a6:	eee50513          	addi	a0,a0,-274 # ffffffffc0206690 <etext+0xda0>
ffffffffc02027aa:	a7ffd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02027ae <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc02027ae:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02027b0:	00004617          	auipc	a2,0x4
ffffffffc02027b4:	b0860613          	addi	a2,a2,-1272 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc02027b8:	06b00593          	li	a1,107
ffffffffc02027bc:	00004517          	auipc	a0,0x4
ffffffffc02027c0:	b1c50513          	addi	a0,a0,-1252 # ffffffffc02062d8 <etext+0x9e8>
pa2page(uintptr_t pa)
ffffffffc02027c4:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02027c6:	a63fd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02027ca <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02027ca:	100027f3          	csrr	a5,sstatus
ffffffffc02027ce:	8b89                	andi	a5,a5,2
ffffffffc02027d0:	e799                	bnez	a5,ffffffffc02027de <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);  // 关闭中断，确保分配过程不被打断
    {
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc02027d2:	000a5797          	auipc	a5,0xa5
ffffffffc02027d6:	d367b783          	ld	a5,-714(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc02027da:	6f9c                	ld	a5,24(a5)
ffffffffc02027dc:	8782                	jr	a5
{
ffffffffc02027de:	1101                	addi	sp,sp,-32
ffffffffc02027e0:	ec06                	sd	ra,24(sp)
ffffffffc02027e2:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc02027e4:	926fe0ef          	jal	ffffffffc020090a <intr_disable>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc02027e8:	000a5797          	auipc	a5,0xa5
ffffffffc02027ec:	d207b783          	ld	a5,-736(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc02027f0:	6522                	ld	a0,8(sp)
ffffffffc02027f2:	6f9c                	ld	a5,24(a5)
ffffffffc02027f4:	9782                	jalr	a5
ffffffffc02027f6:	e42a                	sd	a0,8(sp)
        intr_enable();  // 重新开启中断
ffffffffc02027f8:	90cfe0ef          	jal	ffffffffc0200904 <intr_enable>
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
    return page;
}
ffffffffc02027fc:	60e2                	ld	ra,24(sp)
ffffffffc02027fe:	6522                	ld	a0,8(sp)
ffffffffc0202800:	6105                	addi	sp,sp,32
ffffffffc0202802:	8082                	ret

ffffffffc0202804 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0202804:	100027f3          	csrr	a5,sstatus
ffffffffc0202808:	8b89                	andi	a5,a5,2
ffffffffc020280a:	e799                	bnez	a5,ffffffffc0202818 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);  // 关闭中断，确保释放过程不被打断
    {
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc020280c:	000a5797          	auipc	a5,0xa5
ffffffffc0202810:	cfc7b783          	ld	a5,-772(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202814:	739c                	ld	a5,32(a5)
ffffffffc0202816:	8782                	jr	a5
{
ffffffffc0202818:	1101                	addi	sp,sp,-32
ffffffffc020281a:	ec06                	sd	ra,24(sp)
ffffffffc020281c:	e42e                	sd	a1,8(sp)
ffffffffc020281e:	e02a                	sd	a0,0(sp)
        intr_disable();  // 关闭中断
ffffffffc0202820:	8eafe0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202824:	000a5797          	auipc	a5,0xa5
ffffffffc0202828:	ce47b783          	ld	a5,-796(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc020282c:	65a2                	ld	a1,8(sp)
ffffffffc020282e:	6502                	ld	a0,0(sp)
ffffffffc0202830:	739c                	ld	a5,32(a5)
ffffffffc0202832:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
}
ffffffffc0202834:	60e2                	ld	ra,24(sp)
ffffffffc0202836:	6105                	addi	sp,sp,32
        intr_enable();  // 重新开启中断
ffffffffc0202838:	8ccfe06f          	j	ffffffffc0200904 <intr_enable>

ffffffffc020283c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020283c:	100027f3          	csrr	a5,sstatus
ffffffffc0202840:	8b89                	andi	a5,a5,2
ffffffffc0202842:	e799                	bnez	a5,ffffffffc0202850 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);  // 关闭中断，确保查询过程不被打断
    {
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc0202844:	000a5797          	auipc	a5,0xa5
ffffffffc0202848:	cc47b783          	ld	a5,-828(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc020284c:	779c                	ld	a5,40(a5)
ffffffffc020284e:	8782                	jr	a5
{
ffffffffc0202850:	1101                	addi	sp,sp,-32
ffffffffc0202852:	ec06                	sd	ra,24(sp)
        intr_disable();  // 关闭中断
ffffffffc0202854:	8b6fe0ef          	jal	ffffffffc020090a <intr_disable>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc0202858:	000a5797          	auipc	a5,0xa5
ffffffffc020285c:	cb07b783          	ld	a5,-848(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202860:	779c                	ld	a5,40(a5)
ffffffffc0202862:	9782                	jalr	a5
ffffffffc0202864:	e42a                	sd	a0,8(sp)
        intr_enable();  // 重新开启中断
ffffffffc0202866:	89efe0ef          	jal	ffffffffc0200904 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020286a:	60e2                	ld	ra,24(sp)
ffffffffc020286c:	6522                	ld	a0,8(sp)
ffffffffc020286e:	6105                	addi	sp,sp,32
ffffffffc0202870:	8082                	ret

ffffffffc0202872 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202872:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202876:	1ff7f793          	andi	a5,a5,511
ffffffffc020287a:	078e                	slli	a5,a5,0x3
ffffffffc020287c:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0202880:	6314                	ld	a3,0(a4)
{
ffffffffc0202882:	7139                	addi	sp,sp,-64
ffffffffc0202884:	f822                	sd	s0,48(sp)
ffffffffc0202886:	f426                	sd	s1,40(sp)
ffffffffc0202888:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc020288a:	0016f793          	andi	a5,a3,1
{
ffffffffc020288e:	842e                	mv	s0,a1
ffffffffc0202890:	8832                	mv	a6,a2
ffffffffc0202892:	000a5497          	auipc	s1,0xa5
ffffffffc0202896:	c9648493          	addi	s1,s1,-874 # ffffffffc02a7528 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc020289a:	ebd1                	bnez	a5,ffffffffc020292e <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020289c:	16060d63          	beqz	a2,ffffffffc0202a16 <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02028a0:	100027f3          	csrr	a5,sstatus
ffffffffc02028a4:	8b89                	andi	a5,a5,2
ffffffffc02028a6:	16079e63          	bnez	a5,ffffffffc0202a22 <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc02028aa:	000a5797          	auipc	a5,0xa5
ffffffffc02028ae:	c5e7b783          	ld	a5,-930(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc02028b2:	4505                	li	a0,1
ffffffffc02028b4:	e43a                	sd	a4,8(sp)
ffffffffc02028b6:	6f9c                	ld	a5,24(a5)
ffffffffc02028b8:	e832                	sd	a2,16(sp)
ffffffffc02028ba:	9782                	jalr	a5
ffffffffc02028bc:	6722                	ld	a4,8(sp)
ffffffffc02028be:	6842                	ld	a6,16(sp)
ffffffffc02028c0:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc02028c2:	14078a63          	beqz	a5,ffffffffc0202a16 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc02028c6:	000a5517          	auipc	a0,0xa5
ffffffffc02028ca:	c6a53503          	ld	a0,-918(a0) # ffffffffc02a7530 <pages>
ffffffffc02028ce:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02028d2:	000a5497          	auipc	s1,0xa5
ffffffffc02028d6:	c5648493          	addi	s1,s1,-938 # ffffffffc02a7528 <npage>
ffffffffc02028da:	40a78533          	sub	a0,a5,a0
ffffffffc02028de:	8519                	srai	a0,a0,0x6
ffffffffc02028e0:	9546                	add	a0,a0,a7
ffffffffc02028e2:	6090                	ld	a2,0(s1)
ffffffffc02028e4:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc02028e8:	4585                	li	a1,1
ffffffffc02028ea:	82b1                	srli	a3,a3,0xc
ffffffffc02028ec:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc02028ee:	0532                	slli	a0,a0,0xc
ffffffffc02028f0:	1ac6f763          	bgeu	a3,a2,ffffffffc0202a9e <get_pte+0x22c>
ffffffffc02028f4:	000a5697          	auipc	a3,0xa5
ffffffffc02028f8:	c2c6b683          	ld	a3,-980(a3) # ffffffffc02a7520 <va_pa_offset>
ffffffffc02028fc:	6605                	lui	a2,0x1
ffffffffc02028fe:	4581                	li	a1,0
ffffffffc0202900:	9536                	add	a0,a0,a3
ffffffffc0202902:	ec42                	sd	a6,24(sp)
ffffffffc0202904:	e83e                	sd	a5,16(sp)
ffffffffc0202906:	e43a                	sd	a4,8(sp)
ffffffffc0202908:	3dd020ef          	jal	ffffffffc02054e4 <memset>
    return page - pages + nbase;
ffffffffc020290c:	000a5697          	auipc	a3,0xa5
ffffffffc0202910:	c246b683          	ld	a3,-988(a3) # ffffffffc02a7530 <pages>
ffffffffc0202914:	67c2                	ld	a5,16(sp)
ffffffffc0202916:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020291a:	6722                	ld	a4,8(sp)
ffffffffc020291c:	40d786b3          	sub	a3,a5,a3
ffffffffc0202920:	8699                	srai	a3,a3,0x6
ffffffffc0202922:	96c6                	add	a3,a3,a7
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202924:	06aa                	slli	a3,a3,0xa
ffffffffc0202926:	6862                	ld	a6,24(sp)
ffffffffc0202928:	0116e693          	ori	a3,a3,17
ffffffffc020292c:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020292e:	c006f693          	andi	a3,a3,-1024
ffffffffc0202932:	6098                	ld	a4,0(s1)
ffffffffc0202934:	068a                	slli	a3,a3,0x2
ffffffffc0202936:	00c6d793          	srli	a5,a3,0xc
ffffffffc020293a:	14e7f663          	bgeu	a5,a4,ffffffffc0202a86 <get_pte+0x214>
ffffffffc020293e:	000a5897          	auipc	a7,0xa5
ffffffffc0202942:	be288893          	addi	a7,a7,-1054 # ffffffffc02a7520 <va_pa_offset>
ffffffffc0202946:	0008b603          	ld	a2,0(a7)
ffffffffc020294a:	01545793          	srli	a5,s0,0x15
ffffffffc020294e:	1ff7f793          	andi	a5,a5,511
ffffffffc0202952:	96b2                	add	a3,a3,a2
ffffffffc0202954:	078e                	slli	a5,a5,0x3
ffffffffc0202956:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0202958:	6394                	ld	a3,0(a5)
ffffffffc020295a:	0016f613          	andi	a2,a3,1
ffffffffc020295e:	e659                	bnez	a2,ffffffffc02029ec <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202960:	0a080b63          	beqz	a6,ffffffffc0202a16 <get_pte+0x1a4>
ffffffffc0202964:	10002773          	csrr	a4,sstatus
ffffffffc0202968:	8b09                	andi	a4,a4,2
ffffffffc020296a:	ef71                	bnez	a4,ffffffffc0202a46 <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc020296c:	000a5717          	auipc	a4,0xa5
ffffffffc0202970:	b9c73703          	ld	a4,-1124(a4) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202974:	4505                	li	a0,1
ffffffffc0202976:	e43e                	sd	a5,8(sp)
ffffffffc0202978:	6f18                	ld	a4,24(a4)
ffffffffc020297a:	9702                	jalr	a4
ffffffffc020297c:	67a2                	ld	a5,8(sp)
ffffffffc020297e:	872a                	mv	a4,a0
ffffffffc0202980:	000a5897          	auipc	a7,0xa5
ffffffffc0202984:	ba088893          	addi	a7,a7,-1120 # ffffffffc02a7520 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202988:	c759                	beqz	a4,ffffffffc0202a16 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc020298a:	000a5697          	auipc	a3,0xa5
ffffffffc020298e:	ba66b683          	ld	a3,-1114(a3) # ffffffffc02a7530 <pages>
ffffffffc0202992:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202996:	608c                	ld	a1,0(s1)
ffffffffc0202998:	40d706b3          	sub	a3,a4,a3
ffffffffc020299c:	8699                	srai	a3,a3,0x6
ffffffffc020299e:	96c2                	add	a3,a3,a6
ffffffffc02029a0:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc02029a4:	4505                	li	a0,1
ffffffffc02029a6:	8231                	srli	a2,a2,0xc
ffffffffc02029a8:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc02029aa:	06b2                	slli	a3,a3,0xc
ffffffffc02029ac:	10b67663          	bgeu	a2,a1,ffffffffc0202ab8 <get_pte+0x246>
ffffffffc02029b0:	0008b503          	ld	a0,0(a7)
ffffffffc02029b4:	6605                	lui	a2,0x1
ffffffffc02029b6:	4581                	li	a1,0
ffffffffc02029b8:	9536                	add	a0,a0,a3
ffffffffc02029ba:	e83a                	sd	a4,16(sp)
ffffffffc02029bc:	e43e                	sd	a5,8(sp)
ffffffffc02029be:	327020ef          	jal	ffffffffc02054e4 <memset>
    return page - pages + nbase;
ffffffffc02029c2:	000a5697          	auipc	a3,0xa5
ffffffffc02029c6:	b6e6b683          	ld	a3,-1170(a3) # ffffffffc02a7530 <pages>
ffffffffc02029ca:	6742                	ld	a4,16(sp)
ffffffffc02029cc:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02029d0:	67a2                	ld	a5,8(sp)
ffffffffc02029d2:	40d706b3          	sub	a3,a4,a3
ffffffffc02029d6:	8699                	srai	a3,a3,0x6
ffffffffc02029d8:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02029da:	06aa                	slli	a3,a3,0xa
ffffffffc02029dc:	0116e693          	ori	a3,a3,17
ffffffffc02029e0:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02029e2:	6098                	ld	a4,0(s1)
ffffffffc02029e4:	000a5897          	auipc	a7,0xa5
ffffffffc02029e8:	b3c88893          	addi	a7,a7,-1220 # ffffffffc02a7520 <va_pa_offset>
ffffffffc02029ec:	c006f693          	andi	a3,a3,-1024
ffffffffc02029f0:	068a                	slli	a3,a3,0x2
ffffffffc02029f2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02029f6:	06e7fc63          	bgeu	a5,a4,ffffffffc0202a6e <get_pte+0x1fc>
ffffffffc02029fa:	0008b783          	ld	a5,0(a7)
ffffffffc02029fe:	8031                	srli	s0,s0,0xc
ffffffffc0202a00:	1ff47413          	andi	s0,s0,511
ffffffffc0202a04:	040e                	slli	s0,s0,0x3
ffffffffc0202a06:	96be                	add	a3,a3,a5
}
ffffffffc0202a08:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202a0a:	00868533          	add	a0,a3,s0
}
ffffffffc0202a0e:	7442                	ld	s0,48(sp)
ffffffffc0202a10:	74a2                	ld	s1,40(sp)
ffffffffc0202a12:	6121                	addi	sp,sp,64
ffffffffc0202a14:	8082                	ret
ffffffffc0202a16:	70e2                	ld	ra,56(sp)
ffffffffc0202a18:	7442                	ld	s0,48(sp)
ffffffffc0202a1a:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0202a1c:	4501                	li	a0,0
}
ffffffffc0202a1e:	6121                	addi	sp,sp,64
ffffffffc0202a20:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc0202a22:	e83a                	sd	a4,16(sp)
ffffffffc0202a24:	ec32                	sd	a2,24(sp)
ffffffffc0202a26:	ee5fd0ef          	jal	ffffffffc020090a <intr_disable>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc0202a2a:	000a5797          	auipc	a5,0xa5
ffffffffc0202a2e:	ade7b783          	ld	a5,-1314(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202a32:	4505                	li	a0,1
ffffffffc0202a34:	6f9c                	ld	a5,24(a5)
ffffffffc0202a36:	9782                	jalr	a5
ffffffffc0202a38:	e42a                	sd	a0,8(sp)
        intr_enable();  // 重新开启中断
ffffffffc0202a3a:	ecbfd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0202a3e:	6862                	ld	a6,24(sp)
ffffffffc0202a40:	6742                	ld	a4,16(sp)
ffffffffc0202a42:	67a2                	ld	a5,8(sp)
ffffffffc0202a44:	bdbd                	j	ffffffffc02028c2 <get_pte+0x50>
        intr_disable();  // 关闭中断
ffffffffc0202a46:	e83e                	sd	a5,16(sp)
ffffffffc0202a48:	ec3fd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc0202a4c:	000a5717          	auipc	a4,0xa5
ffffffffc0202a50:	abc73703          	ld	a4,-1348(a4) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202a54:	4505                	li	a0,1
ffffffffc0202a56:	6f18                	ld	a4,24(a4)
ffffffffc0202a58:	9702                	jalr	a4
ffffffffc0202a5a:	e42a                	sd	a0,8(sp)
        intr_enable();  // 重新开启中断
ffffffffc0202a5c:	ea9fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0202a60:	6722                	ld	a4,8(sp)
ffffffffc0202a62:	67c2                	ld	a5,16(sp)
ffffffffc0202a64:	000a5897          	auipc	a7,0xa5
ffffffffc0202a68:	abc88893          	addi	a7,a7,-1348 # ffffffffc02a7520 <va_pa_offset>
ffffffffc0202a6c:	bf31                	j	ffffffffc0202988 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202a6e:	00004617          	auipc	a2,0x4
ffffffffc0202a72:	88a60613          	addi	a2,a2,-1910 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0202a76:	10000593          	li	a1,256
ffffffffc0202a7a:	00004517          	auipc	a0,0x4
ffffffffc0202a7e:	fae50513          	addi	a0,a0,-82 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202a82:	fa6fd0ef          	jal	ffffffffc0200228 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202a86:	00004617          	auipc	a2,0x4
ffffffffc0202a8a:	87260613          	addi	a2,a2,-1934 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0202a8e:	0f300593          	li	a1,243
ffffffffc0202a92:	00004517          	auipc	a0,0x4
ffffffffc0202a96:	f9650513          	addi	a0,a0,-106 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202a9a:	f8efd0ef          	jal	ffffffffc0200228 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202a9e:	86aa                	mv	a3,a0
ffffffffc0202aa0:	00004617          	auipc	a2,0x4
ffffffffc0202aa4:	85860613          	addi	a2,a2,-1960 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0202aa8:	0ef00593          	li	a1,239
ffffffffc0202aac:	00004517          	auipc	a0,0x4
ffffffffc0202ab0:	f7c50513          	addi	a0,a0,-132 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202ab4:	f74fd0ef          	jal	ffffffffc0200228 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202ab8:	00004617          	auipc	a2,0x4
ffffffffc0202abc:	84060613          	addi	a2,a2,-1984 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0202ac0:	0fd00593          	li	a1,253
ffffffffc0202ac4:	00004517          	auipc	a0,0x4
ffffffffc0202ac8:	f6450513          	addi	a0,a0,-156 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202acc:	f5cfd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0202ad0 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0202ad0:	1141                	addi	sp,sp,-16
ffffffffc0202ad2:	e022                	sd	s0,0(sp)
ffffffffc0202ad4:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ad6:	4601                	li	a2,0
{
ffffffffc0202ad8:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202ada:	d99ff0ef          	jal	ffffffffc0202872 <get_pte>
    if (ptep_store != NULL)
ffffffffc0202ade:	c011                	beqz	s0,ffffffffc0202ae2 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202ae0:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ae2:	c511                	beqz	a0,ffffffffc0202aee <get_page+0x1e>
ffffffffc0202ae4:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202ae6:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202ae8:	0017f713          	andi	a4,a5,1
ffffffffc0202aec:	e709                	bnez	a4,ffffffffc0202af6 <get_page+0x26>
}
ffffffffc0202aee:	60a2                	ld	ra,8(sp)
ffffffffc0202af0:	6402                	ld	s0,0(sp)
ffffffffc0202af2:	0141                	addi	sp,sp,16
ffffffffc0202af4:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202af6:	000a5717          	auipc	a4,0xa5
ffffffffc0202afa:	a3273703          	ld	a4,-1486(a4) # ffffffffc02a7528 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202afe:	078a                	slli	a5,a5,0x2
ffffffffc0202b00:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b02:	00e7ff63          	bgeu	a5,a4,ffffffffc0202b20 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b06:	000a5517          	auipc	a0,0xa5
ffffffffc0202b0a:	a2a53503          	ld	a0,-1494(a0) # ffffffffc02a7530 <pages>
ffffffffc0202b0e:	60a2                	ld	ra,8(sp)
ffffffffc0202b10:	6402                	ld	s0,0(sp)
ffffffffc0202b12:	079a                	slli	a5,a5,0x6
ffffffffc0202b14:	fe000737          	lui	a4,0xfe000
ffffffffc0202b18:	97ba                	add	a5,a5,a4
ffffffffc0202b1a:	953e                	add	a0,a0,a5
ffffffffc0202b1c:	0141                	addi	sp,sp,16
ffffffffc0202b1e:	8082                	ret
ffffffffc0202b20:	c8fff0ef          	jal	ffffffffc02027ae <pa2page.part.0>

ffffffffc0202b24 <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202b24:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b26:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202b2a:	e486                	sd	ra,72(sp)
ffffffffc0202b2c:	e0a2                	sd	s0,64(sp)
ffffffffc0202b2e:	fc26                	sd	s1,56(sp)
ffffffffc0202b30:	f84a                	sd	s2,48(sp)
ffffffffc0202b32:	f44e                	sd	s3,40(sp)
ffffffffc0202b34:	f052                	sd	s4,32(sp)
ffffffffc0202b36:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202b38:	03479713          	slli	a4,a5,0x34
ffffffffc0202b3c:	ef61                	bnez	a4,ffffffffc0202c14 <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc0202b3e:	00200a37          	lui	s4,0x200
ffffffffc0202b42:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202b46:	0145b733          	sltu	a4,a1,s4
ffffffffc0202b4a:	0017b793          	seqz	a5,a5
ffffffffc0202b4e:	8fd9                	or	a5,a5,a4
ffffffffc0202b50:	842e                	mv	s0,a1
ffffffffc0202b52:	84b2                	mv	s1,a2
ffffffffc0202b54:	e3e5                	bnez	a5,ffffffffc0202c34 <unmap_range+0x110>
ffffffffc0202b56:	4785                	li	a5,1
ffffffffc0202b58:	07fe                	slli	a5,a5,0x1f
ffffffffc0202b5a:	0785                	addi	a5,a5,1
ffffffffc0202b5c:	892a                	mv	s2,a0
ffffffffc0202b5e:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202b60:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc0202b64:	0cf67863          	bgeu	a2,a5,ffffffffc0202c34 <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202b68:	4601                	li	a2,0
ffffffffc0202b6a:	85a2                	mv	a1,s0
ffffffffc0202b6c:	854a                	mv	a0,s2
ffffffffc0202b6e:	d05ff0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc0202b72:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc0202b74:	cd31                	beqz	a0,ffffffffc0202bd0 <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc0202b76:	6118                	ld	a4,0(a0)
ffffffffc0202b78:	ef11                	bnez	a4,ffffffffc0202b94 <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202b7a:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202b7c:	c019                	beqz	s0,ffffffffc0202b82 <unmap_range+0x5e>
ffffffffc0202b7e:	fe9465e3          	bltu	s0,s1,ffffffffc0202b68 <unmap_range+0x44>
}
ffffffffc0202b82:	60a6                	ld	ra,72(sp)
ffffffffc0202b84:	6406                	ld	s0,64(sp)
ffffffffc0202b86:	74e2                	ld	s1,56(sp)
ffffffffc0202b88:	7942                	ld	s2,48(sp)
ffffffffc0202b8a:	79a2                	ld	s3,40(sp)
ffffffffc0202b8c:	7a02                	ld	s4,32(sp)
ffffffffc0202b8e:	6ae2                	ld	s5,24(sp)
ffffffffc0202b90:	6161                	addi	sp,sp,80
ffffffffc0202b92:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202b94:	00177693          	andi	a3,a4,1
ffffffffc0202b98:	d2ed                	beqz	a3,ffffffffc0202b7a <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc0202b9a:	000a5697          	auipc	a3,0xa5
ffffffffc0202b9e:	98e6b683          	ld	a3,-1650(a3) # ffffffffc02a7528 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ba2:	070a                	slli	a4,a4,0x2
ffffffffc0202ba4:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ba6:	0ad77763          	bgeu	a4,a3,ffffffffc0202c54 <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc0202baa:	000a5517          	auipc	a0,0xa5
ffffffffc0202bae:	98653503          	ld	a0,-1658(a0) # ffffffffc02a7530 <pages>
ffffffffc0202bb2:	071a                	slli	a4,a4,0x6
ffffffffc0202bb4:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202bb8:	9736                	add	a4,a4,a3
ffffffffc0202bba:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202bbc:	4118                	lw	a4,0(a0)
ffffffffc0202bbe:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd58aa7>
ffffffffc0202bc0:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202bc2:	cb19                	beqz	a4,ffffffffc0202bd8 <unmap_range+0xb4>
        *ptep = 0;
ffffffffc0202bc4:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202bc8:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202bcc:	944e                	add	s0,s0,s3
ffffffffc0202bce:	b77d                	j	ffffffffc0202b7c <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202bd0:	9452                	add	s0,s0,s4
ffffffffc0202bd2:	01547433          	and	s0,s0,s5
            continue;
ffffffffc0202bd6:	b75d                	j	ffffffffc0202b7c <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0202bd8:	10002773          	csrr	a4,sstatus
ffffffffc0202bdc:	8b09                	andi	a4,a4,2
ffffffffc0202bde:	eb19                	bnez	a4,ffffffffc0202bf4 <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202be0:	000a5717          	auipc	a4,0xa5
ffffffffc0202be4:	92873703          	ld	a4,-1752(a4) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202be8:	4585                	li	a1,1
ffffffffc0202bea:	e03e                	sd	a5,0(sp)
ffffffffc0202bec:	7318                	ld	a4,32(a4)
ffffffffc0202bee:	9702                	jalr	a4
    if (flag)           // 如果原来中断是开启的
ffffffffc0202bf0:	6782                	ld	a5,0(sp)
ffffffffc0202bf2:	bfc9                	j	ffffffffc0202bc4 <unmap_range+0xa0>
        intr_disable();  // 关闭中断
ffffffffc0202bf4:	e43e                	sd	a5,8(sp)
ffffffffc0202bf6:	e02a                	sd	a0,0(sp)
ffffffffc0202bf8:	d13fd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc0202bfc:	000a5717          	auipc	a4,0xa5
ffffffffc0202c00:	90c73703          	ld	a4,-1780(a4) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202c04:	6502                	ld	a0,0(sp)
ffffffffc0202c06:	4585                	li	a1,1
ffffffffc0202c08:	7318                	ld	a4,32(a4)
ffffffffc0202c0a:	9702                	jalr	a4
        intr_enable();  // 重新开启中断
ffffffffc0202c0c:	cf9fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0202c10:	67a2                	ld	a5,8(sp)
ffffffffc0202c12:	bf4d                	j	ffffffffc0202bc4 <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c14:	00004697          	auipc	a3,0x4
ffffffffc0202c18:	e2468693          	addi	a3,a3,-476 # ffffffffc0206a38 <etext+0x1148>
ffffffffc0202c1c:	00003617          	auipc	a2,0x3
ffffffffc0202c20:	75460613          	addi	a2,a2,1876 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202c24:	12600593          	li	a1,294
ffffffffc0202c28:	00004517          	auipc	a0,0x4
ffffffffc0202c2c:	e0050513          	addi	a0,a0,-512 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202c30:	df8fd0ef          	jal	ffffffffc0200228 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202c34:	00004697          	auipc	a3,0x4
ffffffffc0202c38:	e3468693          	addi	a3,a3,-460 # ffffffffc0206a68 <etext+0x1178>
ffffffffc0202c3c:	00003617          	auipc	a2,0x3
ffffffffc0202c40:	73460613          	addi	a2,a2,1844 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202c44:	12700593          	li	a1,295
ffffffffc0202c48:	00004517          	auipc	a0,0x4
ffffffffc0202c4c:	de050513          	addi	a0,a0,-544 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202c50:	dd8fd0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc0202c54:	b5bff0ef          	jal	ffffffffc02027ae <pa2page.part.0>

ffffffffc0202c58 <exit_range>:
{
ffffffffc0202c58:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c5a:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202c5e:	ed06                	sd	ra,152(sp)
ffffffffc0202c60:	e922                	sd	s0,144(sp)
ffffffffc0202c62:	e526                	sd	s1,136(sp)
ffffffffc0202c64:	e14a                	sd	s2,128(sp)
ffffffffc0202c66:	fcce                	sd	s3,120(sp)
ffffffffc0202c68:	f8d2                	sd	s4,112(sp)
ffffffffc0202c6a:	f4d6                	sd	s5,104(sp)
ffffffffc0202c6c:	f0da                	sd	s6,96(sp)
ffffffffc0202c6e:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202c70:	17d2                	slli	a5,a5,0x34
ffffffffc0202c72:	22079263          	bnez	a5,ffffffffc0202e96 <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc0202c76:	00200937          	lui	s2,0x200
ffffffffc0202c7a:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202c7e:	0125b733          	sltu	a4,a1,s2
ffffffffc0202c82:	0017b793          	seqz	a5,a5
ffffffffc0202c86:	8fd9                	or	a5,a5,a4
ffffffffc0202c88:	26079263          	bnez	a5,ffffffffc0202eec <exit_range+0x294>
ffffffffc0202c8c:	4785                	li	a5,1
ffffffffc0202c8e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202c90:	0785                	addi	a5,a5,1
ffffffffc0202c92:	24f67d63          	bgeu	a2,a5,ffffffffc0202eec <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202c96:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202c9a:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202c9e:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202ca0:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202ca2:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc0202ca6:	000a5a97          	auipc	s5,0xa5
ffffffffc0202caa:	882a8a93          	addi	s5,s5,-1918 # ffffffffc02a7528 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202cae:	400009b7          	lui	s3,0x40000
ffffffffc0202cb2:	a809                	j	ffffffffc0202cc4 <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc0202cb4:	013487b3          	add	a5,s1,s3
ffffffffc0202cb8:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202cbc:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc0202cbe:	c3f1                	beqz	a5,ffffffffc0202d82 <exit_range+0x12a>
ffffffffc0202cc0:	0cc7f163          	bgeu	a5,a2,ffffffffc0202d82 <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202cc4:	01e4d413          	srli	s0,s1,0x1e
ffffffffc0202cc8:	1ff47413          	andi	s0,s0,511
ffffffffc0202ccc:	040e                	slli	s0,s0,0x3
ffffffffc0202cce:	9452                	add	s0,s0,s4
ffffffffc0202cd0:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc0202cd4:	0018f793          	andi	a5,a7,1
ffffffffc0202cd8:	dff1                	beqz	a5,ffffffffc0202cb4 <exit_range+0x5c>
ffffffffc0202cda:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cde:	088a                	slli	a7,a7,0x2
ffffffffc0202ce0:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ce4:	20f8f263          	bgeu	a7,a5,ffffffffc0202ee8 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ce8:	fff802b7          	lui	t0,0xfff80
ffffffffc0202cec:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc0202cf0:	000803b7          	lui	t2,0x80
ffffffffc0202cf4:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cf8:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202cfc:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc0202cfe:	1cf77863          	bgeu	a4,a5,ffffffffc0202ece <exit_range+0x276>
ffffffffc0202d02:	000a5f97          	auipc	t6,0xa5
ffffffffc0202d06:	81ef8f93          	addi	t6,t6,-2018 # ffffffffc02a7520 <va_pa_offset>
ffffffffc0202d0a:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc0202d0e:	4e85                	li	t4,1
ffffffffc0202d10:	6b05                	lui	s6,0x1
ffffffffc0202d12:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202d14:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202d18:	01585713          	srli	a4,a6,0x15
ffffffffc0202d1c:	1ff77713          	andi	a4,a4,511
ffffffffc0202d20:	070e                	slli	a4,a4,0x3
ffffffffc0202d22:	9772                	add	a4,a4,t3
ffffffffc0202d24:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc0202d26:	0017f693          	andi	a3,a5,1
ffffffffc0202d2a:	e6bd                	bnez	a3,ffffffffc0202d98 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc0202d2c:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc0202d2e:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202d30:	00080863          	beqz	a6,ffffffffc0202d40 <exit_range+0xe8>
ffffffffc0202d34:	879a                	mv	a5,t1
ffffffffc0202d36:	00667363          	bgeu	a2,t1,ffffffffc0202d3c <exit_range+0xe4>
ffffffffc0202d3a:	87b2                	mv	a5,a2
ffffffffc0202d3c:	fcf86ee3          	bltu	a6,a5,ffffffffc0202d18 <exit_range+0xc0>
            if (free_pd0)
ffffffffc0202d40:	f60e8ae3          	beqz	t4,ffffffffc0202cb4 <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc0202d44:	000ab783          	ld	a5,0(s5)
ffffffffc0202d48:	1af8f063          	bgeu	a7,a5,ffffffffc0202ee8 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d4c:	000a4517          	auipc	a0,0xa4
ffffffffc0202d50:	7e453503          	ld	a0,2020(a0) # ffffffffc02a7530 <pages>
ffffffffc0202d54:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0202d56:	100027f3          	csrr	a5,sstatus
ffffffffc0202d5a:	8b89                	andi	a5,a5,2
ffffffffc0202d5c:	10079b63          	bnez	a5,ffffffffc0202e72 <exit_range+0x21a>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202d60:	000a4797          	auipc	a5,0xa4
ffffffffc0202d64:	7a87b783          	ld	a5,1960(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202d68:	4585                	li	a1,1
ffffffffc0202d6a:	e432                	sd	a2,8(sp)
ffffffffc0202d6c:	739c                	ld	a5,32(a5)
ffffffffc0202d6e:	9782                	jalr	a5
ffffffffc0202d70:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202d72:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc0202d76:	013487b3          	add	a5,s1,s3
ffffffffc0202d7a:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202d7e:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc0202d80:	f3a1                	bnez	a5,ffffffffc0202cc0 <exit_range+0x68>
}
ffffffffc0202d82:	60ea                	ld	ra,152(sp)
ffffffffc0202d84:	644a                	ld	s0,144(sp)
ffffffffc0202d86:	64aa                	ld	s1,136(sp)
ffffffffc0202d88:	690a                	ld	s2,128(sp)
ffffffffc0202d8a:	79e6                	ld	s3,120(sp)
ffffffffc0202d8c:	7a46                	ld	s4,112(sp)
ffffffffc0202d8e:	7aa6                	ld	s5,104(sp)
ffffffffc0202d90:	7b06                	ld	s6,96(sp)
ffffffffc0202d92:	6be6                	ld	s7,88(sp)
ffffffffc0202d94:	610d                	addi	sp,sp,160
ffffffffc0202d96:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202d98:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d9c:	078a                	slli	a5,a5,0x2
ffffffffc0202d9e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202da0:	14a7f463          	bgeu	a5,a0,ffffffffc0202ee8 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202da4:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc0202da6:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc0202daa:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202dae:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc0202db2:	10abf263          	bgeu	s7,a0,ffffffffc0202eb6 <exit_range+0x25e>
ffffffffc0202db6:	000fb783          	ld	a5,0(t6)
ffffffffc0202dba:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202dbc:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc0202dc0:	629c                	ld	a5,0(a3)
ffffffffc0202dc2:	8b85                	andi	a5,a5,1
ffffffffc0202dc4:	f7ad                	bnez	a5,ffffffffc0202d2e <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202dc6:	06a1                	addi	a3,a3,8
ffffffffc0202dc8:	fea69ce3          	bne	a3,a0,ffffffffc0202dc0 <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dcc:	000a4517          	auipc	a0,0xa4
ffffffffc0202dd0:	76453503          	ld	a0,1892(a0) # ffffffffc02a7530 <pages>
ffffffffc0202dd4:	952e                	add	a0,a0,a1
ffffffffc0202dd6:	100027f3          	csrr	a5,sstatus
ffffffffc0202dda:	8b89                	andi	a5,a5,2
ffffffffc0202ddc:	e3b9                	bnez	a5,ffffffffc0202e22 <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202dde:	000a4797          	auipc	a5,0xa4
ffffffffc0202de2:	72a7b783          	ld	a5,1834(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202de6:	4585                	li	a1,1
ffffffffc0202de8:	e0b2                	sd	a2,64(sp)
ffffffffc0202dea:	739c                	ld	a5,32(a5)
ffffffffc0202dec:	fc1a                	sd	t1,56(sp)
ffffffffc0202dee:	f846                	sd	a7,48(sp)
ffffffffc0202df0:	f47a                	sd	t5,40(sp)
ffffffffc0202df2:	f072                	sd	t3,32(sp)
ffffffffc0202df4:	ec76                	sd	t4,24(sp)
ffffffffc0202df6:	e842                	sd	a6,16(sp)
ffffffffc0202df8:	e43a                	sd	a4,8(sp)
ffffffffc0202dfa:	9782                	jalr	a5
    if (flag)           // 如果原来中断是开启的
ffffffffc0202dfc:	6722                	ld	a4,8(sp)
ffffffffc0202dfe:	6842                	ld	a6,16(sp)
ffffffffc0202e00:	6ee2                	ld	t4,24(sp)
ffffffffc0202e02:	7e02                	ld	t3,32(sp)
ffffffffc0202e04:	7f22                	ld	t5,40(sp)
ffffffffc0202e06:	78c2                	ld	a7,48(sp)
ffffffffc0202e08:	7362                	ld	t1,56(sp)
ffffffffc0202e0a:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202e0c:	fff802b7          	lui	t0,0xfff80
ffffffffc0202e10:	000803b7          	lui	t2,0x80
ffffffffc0202e14:	000a4f97          	auipc	t6,0xa4
ffffffffc0202e18:	70cf8f93          	addi	t6,t6,1804 # ffffffffc02a7520 <va_pa_offset>
ffffffffc0202e1c:	00073023          	sd	zero,0(a4)
ffffffffc0202e20:	b739                	j	ffffffffc0202d2e <exit_range+0xd6>
        intr_disable();  // 关闭中断
ffffffffc0202e22:	e4b2                	sd	a2,72(sp)
ffffffffc0202e24:	e09a                	sd	t1,64(sp)
ffffffffc0202e26:	fc46                	sd	a7,56(sp)
ffffffffc0202e28:	f47a                	sd	t5,40(sp)
ffffffffc0202e2a:	f072                	sd	t3,32(sp)
ffffffffc0202e2c:	ec76                	sd	t4,24(sp)
ffffffffc0202e2e:	e842                	sd	a6,16(sp)
ffffffffc0202e30:	e43a                	sd	a4,8(sp)
ffffffffc0202e32:	f82a                	sd	a0,48(sp)
ffffffffc0202e34:	ad7fd0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202e38:	000a4797          	auipc	a5,0xa4
ffffffffc0202e3c:	6d07b783          	ld	a5,1744(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202e40:	7542                	ld	a0,48(sp)
ffffffffc0202e42:	4585                	li	a1,1
ffffffffc0202e44:	739c                	ld	a5,32(a5)
ffffffffc0202e46:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc0202e48:	abdfd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0202e4c:	6722                	ld	a4,8(sp)
ffffffffc0202e4e:	6626                	ld	a2,72(sp)
ffffffffc0202e50:	6306                	ld	t1,64(sp)
ffffffffc0202e52:	78e2                	ld	a7,56(sp)
ffffffffc0202e54:	7f22                	ld	t5,40(sp)
ffffffffc0202e56:	7e02                	ld	t3,32(sp)
ffffffffc0202e58:	6ee2                	ld	t4,24(sp)
ffffffffc0202e5a:	6842                	ld	a6,16(sp)
ffffffffc0202e5c:	000a4f97          	auipc	t6,0xa4
ffffffffc0202e60:	6c4f8f93          	addi	t6,t6,1732 # ffffffffc02a7520 <va_pa_offset>
ffffffffc0202e64:	000803b7          	lui	t2,0x80
ffffffffc0202e68:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202e6c:	00073023          	sd	zero,0(a4)
ffffffffc0202e70:	bd7d                	j	ffffffffc0202d2e <exit_range+0xd6>
        intr_disable();  // 关闭中断
ffffffffc0202e72:	e832                	sd	a2,16(sp)
ffffffffc0202e74:	e42a                	sd	a0,8(sp)
ffffffffc0202e76:	a95fd0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202e7a:	000a4797          	auipc	a5,0xa4
ffffffffc0202e7e:	68e7b783          	ld	a5,1678(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202e82:	6522                	ld	a0,8(sp)
ffffffffc0202e84:	4585                	li	a1,1
ffffffffc0202e86:	739c                	ld	a5,32(a5)
ffffffffc0202e88:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc0202e8a:	a7bfd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0202e8e:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202e90:	00043023          	sd	zero,0(s0)
ffffffffc0202e94:	b5cd                	j	ffffffffc0202d76 <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202e96:	00004697          	auipc	a3,0x4
ffffffffc0202e9a:	ba268693          	addi	a3,a3,-1118 # ffffffffc0206a38 <etext+0x1148>
ffffffffc0202e9e:	00003617          	auipc	a2,0x3
ffffffffc0202ea2:	4d260613          	addi	a2,a2,1234 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202ea6:	13b00593          	li	a1,315
ffffffffc0202eaa:	00004517          	auipc	a0,0x4
ffffffffc0202eae:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202eb2:	b76fd0ef          	jal	ffffffffc0200228 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202eb6:	00003617          	auipc	a2,0x3
ffffffffc0202eba:	44260613          	addi	a2,a2,1090 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0202ebe:	07300593          	li	a1,115
ffffffffc0202ec2:	00003517          	auipc	a0,0x3
ffffffffc0202ec6:	41650513          	addi	a0,a0,1046 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0202eca:	b5efd0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc0202ece:	86f2                	mv	a3,t3
ffffffffc0202ed0:	00003617          	auipc	a2,0x3
ffffffffc0202ed4:	42860613          	addi	a2,a2,1064 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0202ed8:	07300593          	li	a1,115
ffffffffc0202edc:	00003517          	auipc	a0,0x3
ffffffffc0202ee0:	3fc50513          	addi	a0,a0,1020 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0202ee4:	b44fd0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc0202ee8:	8c7ff0ef          	jal	ffffffffc02027ae <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202eec:	00004697          	auipc	a3,0x4
ffffffffc0202ef0:	b7c68693          	addi	a3,a3,-1156 # ffffffffc0206a68 <etext+0x1178>
ffffffffc0202ef4:	00003617          	auipc	a2,0x3
ffffffffc0202ef8:	47c60613          	addi	a2,a2,1148 # ffffffffc0206370 <etext+0xa80>
ffffffffc0202efc:	13c00593          	li	a1,316
ffffffffc0202f00:	00004517          	auipc	a0,0x4
ffffffffc0202f04:	b2850513          	addi	a0,a0,-1240 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0202f08:	b20fd0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0202f0c <page_remove>:
{
ffffffffc0202f0c:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202f0e:	4601                	li	a2,0
{
ffffffffc0202f10:	e822                	sd	s0,16(sp)
ffffffffc0202f12:	ec06                	sd	ra,24(sp)
ffffffffc0202f14:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202f16:	95dff0ef          	jal	ffffffffc0202872 <get_pte>
    if (ptep != NULL)
ffffffffc0202f1a:	c511                	beqz	a0,ffffffffc0202f26 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc0202f1c:	6118                	ld	a4,0(a0)
ffffffffc0202f1e:	87aa                	mv	a5,a0
ffffffffc0202f20:	00177693          	andi	a3,a4,1
ffffffffc0202f24:	e689                	bnez	a3,ffffffffc0202f2e <page_remove+0x22>
}
ffffffffc0202f26:	60e2                	ld	ra,24(sp)
ffffffffc0202f28:	6442                	ld	s0,16(sp)
ffffffffc0202f2a:	6105                	addi	sp,sp,32
ffffffffc0202f2c:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202f2e:	000a4697          	auipc	a3,0xa4
ffffffffc0202f32:	5fa6b683          	ld	a3,1530(a3) # ffffffffc02a7528 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202f36:	070a                	slli	a4,a4,0x2
ffffffffc0202f38:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202f3a:	06d77563          	bgeu	a4,a3,ffffffffc0202fa4 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f3e:	000a4517          	auipc	a0,0xa4
ffffffffc0202f42:	5f253503          	ld	a0,1522(a0) # ffffffffc02a7530 <pages>
ffffffffc0202f46:	071a                	slli	a4,a4,0x6
ffffffffc0202f48:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202f4c:	9736                	add	a4,a4,a3
ffffffffc0202f4e:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202f50:	4118                	lw	a4,0(a0)
ffffffffc0202f52:	377d                	addiw	a4,a4,-1
ffffffffc0202f54:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202f56:	cb09                	beqz	a4,ffffffffc0202f68 <page_remove+0x5c>
        *ptep = 0;
ffffffffc0202f58:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202f5c:	12040073          	sfence.vma	s0
}
ffffffffc0202f60:	60e2                	ld	ra,24(sp)
ffffffffc0202f62:	6442                	ld	s0,16(sp)
ffffffffc0202f64:	6105                	addi	sp,sp,32
ffffffffc0202f66:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0202f68:	10002773          	csrr	a4,sstatus
ffffffffc0202f6c:	8b09                	andi	a4,a4,2
ffffffffc0202f6e:	eb19                	bnez	a4,ffffffffc0202f84 <page_remove+0x78>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0202f70:	000a4717          	auipc	a4,0xa4
ffffffffc0202f74:	59873703          	ld	a4,1432(a4) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202f78:	4585                	li	a1,1
ffffffffc0202f7a:	e03e                	sd	a5,0(sp)
ffffffffc0202f7c:	7318                	ld	a4,32(a4)
ffffffffc0202f7e:	9702                	jalr	a4
    if (flag)           // 如果原来中断是开启的
ffffffffc0202f80:	6782                	ld	a5,0(sp)
ffffffffc0202f82:	bfd9                	j	ffffffffc0202f58 <page_remove+0x4c>
        intr_disable();  // 关闭中断
ffffffffc0202f84:	e43e                	sd	a5,8(sp)
ffffffffc0202f86:	e02a                	sd	a0,0(sp)
ffffffffc0202f88:	983fd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc0202f8c:	000a4717          	auipc	a4,0xa4
ffffffffc0202f90:	57c73703          	ld	a4,1404(a4) # ffffffffc02a7508 <pmm_manager>
ffffffffc0202f94:	6502                	ld	a0,0(sp)
ffffffffc0202f96:	4585                	li	a1,1
ffffffffc0202f98:	7318                	ld	a4,32(a4)
ffffffffc0202f9a:	9702                	jalr	a4
        intr_enable();  // 重新开启中断
ffffffffc0202f9c:	969fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0202fa0:	67a2                	ld	a5,8(sp)
ffffffffc0202fa2:	bf5d                	j	ffffffffc0202f58 <page_remove+0x4c>
ffffffffc0202fa4:	80bff0ef          	jal	ffffffffc02027ae <pa2page.part.0>

ffffffffc0202fa8 <page_insert>:
{
ffffffffc0202fa8:	7139                	addi	sp,sp,-64
ffffffffc0202faa:	f426                	sd	s1,40(sp)
ffffffffc0202fac:	84b2                	mv	s1,a2
ffffffffc0202fae:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202fb0:	4605                	li	a2,1
{
ffffffffc0202fb2:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202fb4:	85a6                	mv	a1,s1
{
ffffffffc0202fb6:	fc06                	sd	ra,56(sp)
ffffffffc0202fb8:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202fba:	8b9ff0ef          	jal	ffffffffc0202872 <get_pte>
    if (ptep == NULL)
ffffffffc0202fbe:	cd61                	beqz	a0,ffffffffc0203096 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202fc0:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202fc2:	611c                	ld	a5,0(a0)
ffffffffc0202fc4:	66a2                	ld	a3,8(sp)
ffffffffc0202fc6:	0015861b          	addiw	a2,a1,1
ffffffffc0202fca:	c010                	sw	a2,0(s0)
ffffffffc0202fcc:	0017f613          	andi	a2,a5,1
ffffffffc0202fd0:	872a                	mv	a4,a0
ffffffffc0202fd2:	e61d                	bnez	a2,ffffffffc0203000 <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc0202fd4:	000a4617          	auipc	a2,0xa4
ffffffffc0202fd8:	55c63603          	ld	a2,1372(a2) # ffffffffc02a7530 <pages>
    return page - pages + nbase;
ffffffffc0202fdc:	8c11                	sub	s0,s0,a2
ffffffffc0202fde:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202fe0:	200007b7          	lui	a5,0x20000
ffffffffc0202fe4:	042a                	slli	s0,s0,0xa
ffffffffc0202fe6:	943e                	add	s0,s0,a5
ffffffffc0202fe8:	8ec1                	or	a3,a3,s0
ffffffffc0202fea:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202fee:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202ff0:	12048073          	sfence.vma	s1
    return 0;
ffffffffc0202ff4:	4501                	li	a0,0
}
ffffffffc0202ff6:	70e2                	ld	ra,56(sp)
ffffffffc0202ff8:	7442                	ld	s0,48(sp)
ffffffffc0202ffa:	74a2                	ld	s1,40(sp)
ffffffffc0202ffc:	6121                	addi	sp,sp,64
ffffffffc0202ffe:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0203000:	000a4617          	auipc	a2,0xa4
ffffffffc0203004:	52863603          	ld	a2,1320(a2) # ffffffffc02a7528 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0203008:	078a                	slli	a5,a5,0x2
ffffffffc020300a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020300c:	08c7f763          	bgeu	a5,a2,ffffffffc020309a <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203010:	000a4617          	auipc	a2,0xa4
ffffffffc0203014:	52063603          	ld	a2,1312(a2) # ffffffffc02a7530 <pages>
ffffffffc0203018:	fe000537          	lui	a0,0xfe000
ffffffffc020301c:	079a                	slli	a5,a5,0x6
ffffffffc020301e:	97aa                	add	a5,a5,a0
ffffffffc0203020:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc0203024:	00a40963          	beq	s0,a0,ffffffffc0203036 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc0203028:	411c                	lw	a5,0(a0)
ffffffffc020302a:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_cowtest_out_size+0x1fff3e07>
ffffffffc020302c:	c11c                	sw	a5,0(a0)
        if (page_ref(page) == 0)
ffffffffc020302e:	c791                	beqz	a5,ffffffffc020303a <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203030:	12048073          	sfence.vma	s1
}
ffffffffc0203034:	b765                	j	ffffffffc0202fdc <page_insert+0x34>
ffffffffc0203036:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc0203038:	b755                	j	ffffffffc0202fdc <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020303a:	100027f3          	csrr	a5,sstatus
ffffffffc020303e:	8b89                	andi	a5,a5,2
ffffffffc0203040:	e39d                	bnez	a5,ffffffffc0203066 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0203042:	000a4797          	auipc	a5,0xa4
ffffffffc0203046:	4c67b783          	ld	a5,1222(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc020304a:	4585                	li	a1,1
ffffffffc020304c:	e83a                	sd	a4,16(sp)
ffffffffc020304e:	739c                	ld	a5,32(a5)
ffffffffc0203050:	e436                	sd	a3,8(sp)
ffffffffc0203052:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203054:	000a4617          	auipc	a2,0xa4
ffffffffc0203058:	4dc63603          	ld	a2,1244(a2) # ffffffffc02a7530 <pages>
ffffffffc020305c:	66a2                	ld	a3,8(sp)
ffffffffc020305e:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203060:	12048073          	sfence.vma	s1
ffffffffc0203064:	bfa5                	j	ffffffffc0202fdc <page_insert+0x34>
        intr_disable();  // 关闭中断
ffffffffc0203066:	ec3a                	sd	a4,24(sp)
ffffffffc0203068:	e836                	sd	a3,16(sp)
ffffffffc020306a:	e42a                	sd	a0,8(sp)
ffffffffc020306c:	89ffd0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0203070:	000a4797          	auipc	a5,0xa4
ffffffffc0203074:	4987b783          	ld	a5,1176(a5) # ffffffffc02a7508 <pmm_manager>
ffffffffc0203078:	6522                	ld	a0,8(sp)
ffffffffc020307a:	4585                	li	a1,1
ffffffffc020307c:	739c                	ld	a5,32(a5)
ffffffffc020307e:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc0203080:	885fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203084:	000a4617          	auipc	a2,0xa4
ffffffffc0203088:	4ac63603          	ld	a2,1196(a2) # ffffffffc02a7530 <pages>
ffffffffc020308c:	6762                	ld	a4,24(sp)
ffffffffc020308e:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203090:	12048073          	sfence.vma	s1
ffffffffc0203094:	b7a1                	j	ffffffffc0202fdc <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc0203096:	5571                	li	a0,-4
ffffffffc0203098:	bfb9                	j	ffffffffc0202ff6 <page_insert+0x4e>
ffffffffc020309a:	f14ff0ef          	jal	ffffffffc02027ae <pa2page.part.0>

ffffffffc020309e <pmm_init>:
    pmm_manager = &default_pmm_manager;  // 设置默认内存管理器
ffffffffc020309e:	00004797          	auipc	a5,0x4
ffffffffc02030a2:	64a78793          	addi	a5,a5,1610 # ffffffffc02076e8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030a6:	638c                	ld	a1,0(a5)
{
ffffffffc02030a8:	7159                	addi	sp,sp,-112
ffffffffc02030aa:	f486                	sd	ra,104(sp)
ffffffffc02030ac:	e8ca                	sd	s2,80(sp)
ffffffffc02030ae:	e4ce                	sd	s3,72(sp)
ffffffffc02030b0:	f85a                	sd	s6,48(sp)
ffffffffc02030b2:	f0a2                	sd	s0,96(sp)
ffffffffc02030b4:	eca6                	sd	s1,88(sp)
ffffffffc02030b6:	e0d2                	sd	s4,64(sp)
ffffffffc02030b8:	fc56                	sd	s5,56(sp)
ffffffffc02030ba:	f45e                	sd	s7,40(sp)
ffffffffc02030bc:	f062                	sd	s8,32(sp)
ffffffffc02030be:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;  // 设置默认内存管理器
ffffffffc02030c0:	000a4b17          	auipc	s6,0xa4
ffffffffc02030c4:	448b0b13          	addi	s6,s6,1096 # ffffffffc02a7508 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030c8:	00004517          	auipc	a0,0x4
ffffffffc02030cc:	9b850513          	addi	a0,a0,-1608 # ffffffffc0206a80 <etext+0x1190>
    pmm_manager = &default_pmm_manager;  // 设置默认内存管理器
ffffffffc02030d0:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02030d4:	80afd0ef          	jal	ffffffffc02000de <cprintf>
    pmm_manager->init();                  // 初始化管理器
ffffffffc02030d8:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  // 设置虚拟地址到物理地址的偏移
ffffffffc02030dc:	000a4997          	auipc	s3,0xa4
ffffffffc02030e0:	44498993          	addi	s3,s3,1092 # ffffffffc02a7520 <va_pa_offset>
    pmm_manager->init();                  // 初始化管理器
ffffffffc02030e4:	679c                	ld	a5,8(a5)
ffffffffc02030e6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;  // 设置虚拟地址到物理地址的偏移
ffffffffc02030e8:	57f5                	li	a5,-3
ffffffffc02030ea:	07fa                	slli	a5,a5,0x1e
ffffffffc02030ec:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();  // 获取内存起始地址
ffffffffc02030f0:	f38fd0ef          	jal	ffffffffc0200828 <get_memory_base>
ffffffffc02030f4:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();   // 获取内存大小
ffffffffc02030f6:	f3cfd0ef          	jal	ffffffffc0200832 <get_memory_size>
    if (mem_size == 0)
ffffffffc02030fa:	70050e63          	beqz	a0,ffffffffc0203816 <pmm_init+0x778>
    uint64_t mem_end = mem_begin + mem_size;  // 计算内存结束地址
ffffffffc02030fe:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0203100:	00004517          	auipc	a0,0x4
ffffffffc0203104:	9b850513          	addi	a0,a0,-1608 # ffffffffc0206ab8 <etext+0x11c8>
ffffffffc0203108:	fd7fc0ef          	jal	ffffffffc02000de <cprintf>
    uint64_t mem_end = mem_begin + mem_size;  // 计算内存结束地址
ffffffffc020310c:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203110:	864a                	mv	a2,s2
ffffffffc0203112:	85a6                	mv	a1,s1
ffffffffc0203114:	fff40693          	addi	a3,s0,-1
ffffffffc0203118:	00004517          	auipc	a0,0x4
ffffffffc020311c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0206ad0 <etext+0x11e0>
ffffffffc0203120:	fbffc0ef          	jal	ffffffffc02000de <cprintf>
    if (maxpa > KERNTOP)
ffffffffc0203124:	c80007b7          	lui	a5,0xc8000
ffffffffc0203128:	8522                	mv	a0,s0
ffffffffc020312a:	5287ed63          	bltu	a5,s0,ffffffffc0203664 <pmm_init+0x5c6>
ffffffffc020312e:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203130:	000a5617          	auipc	a2,0xa5
ffffffffc0203134:	42760613          	addi	a2,a2,1063 # ffffffffc02a8557 <end+0xfff>
ffffffffc0203138:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc020313a:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020313c:	000a4b97          	auipc	s7,0xa4
ffffffffc0203140:	3f4b8b93          	addi	s7,s7,1012 # ffffffffc02a7530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203144:	000a4497          	auipc	s1,0xa4
ffffffffc0203148:	3e448493          	addi	s1,s1,996 # ffffffffc02a7528 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020314c:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc0203150:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203152:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203156:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203158:	02f50763          	beq	a0,a5,ffffffffc0203186 <pmm_init+0xe8>
ffffffffc020315c:	4701                	li	a4,0
ffffffffc020315e:	4585                	li	a1,1
ffffffffc0203160:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0203164:	00671793          	slli	a5,a4,0x6
ffffffffc0203168:	97b2                	add	a5,a5,a2
ffffffffc020316a:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_cowtest_out_size+0x73e10>
ffffffffc020316c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203170:	6088                	ld	a0,0(s1)
ffffffffc0203172:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203174:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0203178:	00d507b3          	add	a5,a0,a3
ffffffffc020317c:	fef764e3          	bltu	a4,a5,ffffffffc0203164 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203180:	079a                	slli	a5,a5,0x6
ffffffffc0203182:	00f606b3          	add	a3,a2,a5
ffffffffc0203186:	c02007b7          	lui	a5,0xc0200
ffffffffc020318a:	16f6eee3          	bltu	a3,a5,ffffffffc0203b06 <pmm_init+0xa68>
ffffffffc020318e:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0203192:	77fd                	lui	a5,0xfffff
ffffffffc0203194:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203196:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0203198:	4e86ed63          	bltu	a3,s0,ffffffffc0203692 <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020319c:	00004517          	auipc	a0,0x4
ffffffffc02031a0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0206af8 <etext+0x1208>
ffffffffc02031a4:	f3bfc0ef          	jal	ffffffffc02000de <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc02031a8:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02031ac:	000a4917          	auipc	s2,0xa4
ffffffffc02031b0:	36c90913          	addi	s2,s2,876 # ffffffffc02a7518 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02031b4:	7b9c                	ld	a5,48(a5)
ffffffffc02031b6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02031b8:	00004517          	auipc	a0,0x4
ffffffffc02031bc:	95850513          	addi	a0,a0,-1704 # ffffffffc0206b10 <etext+0x1220>
ffffffffc02031c0:	f1ffc0ef          	jal	ffffffffc02000de <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02031c4:	00007697          	auipc	a3,0x7
ffffffffc02031c8:	e3c68693          	addi	a3,a3,-452 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc02031cc:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02031d0:	c02007b7          	lui	a5,0xc0200
ffffffffc02031d4:	2af6eee3          	bltu	a3,a5,ffffffffc0203c90 <pmm_init+0xbf2>
ffffffffc02031d8:	0009b783          	ld	a5,0(s3)
ffffffffc02031dc:	8e9d                	sub	a3,a3,a5
ffffffffc02031de:	000a4797          	auipc	a5,0xa4
ffffffffc02031e2:	32d7b923          	sd	a3,818(a5) # ffffffffc02a7510 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02031e6:	100027f3          	csrr	a5,sstatus
ffffffffc02031ea:	8b89                	andi	a5,a5,2
ffffffffc02031ec:	48079963          	bnez	a5,ffffffffc020367e <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc02031f0:	000b3783          	ld	a5,0(s6)
ffffffffc02031f4:	779c                	ld	a5,40(a5)
ffffffffc02031f6:	9782                	jalr	a5
ffffffffc02031f8:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02031fa:	6098                	ld	a4,0(s1)
ffffffffc02031fc:	c80007b7          	lui	a5,0xc8000
ffffffffc0203200:	83b1                	srli	a5,a5,0xc
ffffffffc0203202:	66e7e663          	bltu	a5,a4,ffffffffc020386e <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0203206:	00093503          	ld	a0,0(s2)
ffffffffc020320a:	64050263          	beqz	a0,ffffffffc020384e <pmm_init+0x7b0>
ffffffffc020320e:	03451793          	slli	a5,a0,0x34
ffffffffc0203212:	62079e63          	bnez	a5,ffffffffc020384e <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203216:	4601                	li	a2,0
ffffffffc0203218:	4581                	li	a1,0
ffffffffc020321a:	8b7ff0ef          	jal	ffffffffc0202ad0 <get_page>
ffffffffc020321e:	240519e3          	bnez	a0,ffffffffc0203c70 <pmm_init+0xbd2>
ffffffffc0203222:	100027f3          	csrr	a5,sstatus
ffffffffc0203226:	8b89                	andi	a5,a5,2
ffffffffc0203228:	44079063          	bnez	a5,ffffffffc0203668 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc020322c:	000b3783          	ld	a5,0(s6)
ffffffffc0203230:	4505                	li	a0,1
ffffffffc0203232:	6f9c                	ld	a5,24(a5)
ffffffffc0203234:	9782                	jalr	a5
ffffffffc0203236:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203238:	00093503          	ld	a0,0(s2)
ffffffffc020323c:	4681                	li	a3,0
ffffffffc020323e:	4601                	li	a2,0
ffffffffc0203240:	85d2                	mv	a1,s4
ffffffffc0203242:	d67ff0ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc0203246:	280511e3          	bnez	a0,ffffffffc0203cc8 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020324a:	00093503          	ld	a0,0(s2)
ffffffffc020324e:	4601                	li	a2,0
ffffffffc0203250:	4581                	li	a1,0
ffffffffc0203252:	e20ff0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc0203256:	240509e3          	beqz	a0,ffffffffc0203ca8 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc020325a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc020325c:	0017f713          	andi	a4,a5,1
ffffffffc0203260:	58070f63          	beqz	a4,ffffffffc02037fe <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0203264:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203266:	078a                	slli	a5,a5,0x2
ffffffffc0203268:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020326a:	58e7f863          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc020326e:	000bb683          	ld	a3,0(s7)
ffffffffc0203272:	079a                	slli	a5,a5,0x6
ffffffffc0203274:	fe000637          	lui	a2,0xfe000
ffffffffc0203278:	97b2                	add	a5,a5,a2
ffffffffc020327a:	97b6                	add	a5,a5,a3
ffffffffc020327c:	14fa1ae3          	bne	s4,a5,ffffffffc0203bd0 <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc0203280:	000a2683          	lw	a3,0(s4) # 200000 <_binary_obj___user_cowtest_out_size+0x1f3e08>
ffffffffc0203284:	4785                	li	a5,1
ffffffffc0203286:	12f695e3          	bne	a3,a5,ffffffffc0203bb0 <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020328a:	00093503          	ld	a0,0(s2)
ffffffffc020328e:	77fd                	lui	a5,0xfffff
ffffffffc0203290:	6114                	ld	a3,0(a0)
ffffffffc0203292:	068a                	slli	a3,a3,0x2
ffffffffc0203294:	8efd                	and	a3,a3,a5
ffffffffc0203296:	00c6d613          	srli	a2,a3,0xc
ffffffffc020329a:	0ee67fe3          	bgeu	a2,a4,ffffffffc0203b98 <pmm_init+0xafa>
ffffffffc020329e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032a2:	96e2                	add	a3,a3,s8
ffffffffc02032a4:	0006ba83          	ld	s5,0(a3)
ffffffffc02032a8:	0a8a                	slli	s5,s5,0x2
ffffffffc02032aa:	00fafab3          	and	s5,s5,a5
ffffffffc02032ae:	00cad793          	srli	a5,s5,0xc
ffffffffc02032b2:	0ce7f6e3          	bgeu	a5,a4,ffffffffc0203b7e <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032b6:	4601                	li	a2,0
ffffffffc02032b8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032ba:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032bc:	db6ff0ef          	jal	ffffffffc0202872 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032c0:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032c2:	05851ee3          	bne	a0,s8,ffffffffc0203b1e <pmm_init+0xa80>
ffffffffc02032c6:	100027f3          	csrr	a5,sstatus
ffffffffc02032ca:	8b89                	andi	a5,a5,2
ffffffffc02032cc:	3e079b63          	bnez	a5,ffffffffc02036c2 <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc02032d0:	000b3783          	ld	a5,0(s6)
ffffffffc02032d4:	4505                	li	a0,1
ffffffffc02032d6:	6f9c                	ld	a5,24(a5)
ffffffffc02032d8:	9782                	jalr	a5
ffffffffc02032da:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032dc:	00093503          	ld	a0,0(s2)
ffffffffc02032e0:	46d1                	li	a3,20
ffffffffc02032e2:	6605                	lui	a2,0x1
ffffffffc02032e4:	85e2                	mv	a1,s8
ffffffffc02032e6:	cc3ff0ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc02032ea:	06051ae3          	bnez	a0,ffffffffc0203b5e <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032ee:	00093503          	ld	a0,0(s2)
ffffffffc02032f2:	4601                	li	a2,0
ffffffffc02032f4:	6585                	lui	a1,0x1
ffffffffc02032f6:	d7cff0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc02032fa:	040502e3          	beqz	a0,ffffffffc0203b3e <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc02032fe:	611c                	ld	a5,0(a0)
ffffffffc0203300:	0107f713          	andi	a4,a5,16
ffffffffc0203304:	7e070163          	beqz	a4,ffffffffc0203ae6 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0203308:	8b91                	andi	a5,a5,4
ffffffffc020330a:	7a078e63          	beqz	a5,ffffffffc0203ac6 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020330e:	00093503          	ld	a0,0(s2)
ffffffffc0203312:	611c                	ld	a5,0(a0)
ffffffffc0203314:	8bc1                	andi	a5,a5,16
ffffffffc0203316:	78078863          	beqz	a5,ffffffffc0203aa6 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc020331a:	000c2703          	lw	a4,0(s8)
ffffffffc020331e:	4785                	li	a5,1
ffffffffc0203320:	76f71363          	bne	a4,a5,ffffffffc0203a86 <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203324:	4681                	li	a3,0
ffffffffc0203326:	6605                	lui	a2,0x1
ffffffffc0203328:	85d2                	mv	a1,s4
ffffffffc020332a:	c7fff0ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc020332e:	72051c63          	bnez	a0,ffffffffc0203a66 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0203332:	000a2703          	lw	a4,0(s4)
ffffffffc0203336:	4789                	li	a5,2
ffffffffc0203338:	70f71763          	bne	a4,a5,ffffffffc0203a46 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc020333c:	000c2783          	lw	a5,0(s8)
ffffffffc0203340:	6e079363          	bnez	a5,ffffffffc0203a26 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203344:	00093503          	ld	a0,0(s2)
ffffffffc0203348:	4601                	li	a2,0
ffffffffc020334a:	6585                	lui	a1,0x1
ffffffffc020334c:	d26ff0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc0203350:	6a050b63          	beqz	a0,ffffffffc0203a06 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0203354:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0203356:	00177793          	andi	a5,a4,1
ffffffffc020335a:	4a078263          	beqz	a5,ffffffffc02037fe <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc020335e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203360:	00271793          	slli	a5,a4,0x2
ffffffffc0203364:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203366:	48d7fa63          	bgeu	a5,a3,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc020336a:	000bb683          	ld	a3,0(s7)
ffffffffc020336e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0203372:	97d6                	add	a5,a5,s5
ffffffffc0203374:	079a                	slli	a5,a5,0x6
ffffffffc0203376:	97b6                	add	a5,a5,a3
ffffffffc0203378:	66fa1763          	bne	s4,a5,ffffffffc02039e6 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc020337c:	8b41                	andi	a4,a4,16
ffffffffc020337e:	64071463          	bnez	a4,ffffffffc02039c6 <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0203382:	00093503          	ld	a0,0(s2)
ffffffffc0203386:	4581                	li	a1,0
ffffffffc0203388:	b85ff0ef          	jal	ffffffffc0202f0c <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020338c:	000a2c83          	lw	s9,0(s4)
ffffffffc0203390:	4785                	li	a5,1
ffffffffc0203392:	60fc9a63          	bne	s9,a5,ffffffffc02039a6 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0203396:	000c2783          	lw	a5,0(s8)
ffffffffc020339a:	5e079663          	bnez	a5,ffffffffc0203986 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc020339e:	00093503          	ld	a0,0(s2)
ffffffffc02033a2:	6585                	lui	a1,0x1
ffffffffc02033a4:	b69ff0ef          	jal	ffffffffc0202f0c <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02033a8:	000a2783          	lw	a5,0(s4)
ffffffffc02033ac:	52079d63          	bnez	a5,ffffffffc02038e6 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc02033b0:	000c2783          	lw	a5,0(s8)
ffffffffc02033b4:	50079963          	bnez	a5,ffffffffc02038c6 <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02033b8:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc02033bc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02033be:	000a3783          	ld	a5,0(s4)
ffffffffc02033c2:	078a                	slli	a5,a5,0x2
ffffffffc02033c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033c6:	42e7fa63          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02033ca:	000bb503          	ld	a0,0(s7)
ffffffffc02033ce:	97d6                	add	a5,a5,s5
ffffffffc02033d0:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc02033d2:	00f506b3          	add	a3,a0,a5
ffffffffc02033d6:	4294                	lw	a3,0(a3)
ffffffffc02033d8:	4d969763          	bne	a3,s9,ffffffffc02038a6 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc02033dc:	8799                	srai	a5,a5,0x6
ffffffffc02033de:	00080637          	lui	a2,0x80
ffffffffc02033e2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02033e4:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02033e8:	4ae7f363          	bgeu	a5,a4,ffffffffc020388e <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02033ec:	0009b783          	ld	a5,0(s3)
ffffffffc02033f0:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02033f2:	639c                	ld	a5,0(a5)
ffffffffc02033f4:	078a                	slli	a5,a5,0x2
ffffffffc02033f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02033f8:	40e7f163          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02033fc:	8f91                	sub	a5,a5,a2
ffffffffc02033fe:	079a                	slli	a5,a5,0x6
ffffffffc0203400:	953e                	add	a0,a0,a5
ffffffffc0203402:	100027f3          	csrr	a5,sstatus
ffffffffc0203406:	8b89                	andi	a5,a5,2
ffffffffc0203408:	30079863          	bnez	a5,ffffffffc0203718 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc020340c:	000b3783          	ld	a5,0(s6)
ffffffffc0203410:	4585                	li	a1,1
ffffffffc0203412:	739c                	ld	a5,32(a5)
ffffffffc0203414:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203416:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc020341a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020341c:	078a                	slli	a5,a5,0x2
ffffffffc020341e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203420:	3ce7fd63          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0203424:	000bb503          	ld	a0,0(s7)
ffffffffc0203428:	fe000737          	lui	a4,0xfe000
ffffffffc020342c:	079a                	slli	a5,a5,0x6
ffffffffc020342e:	97ba                	add	a5,a5,a4
ffffffffc0203430:	953e                	add	a0,a0,a5
ffffffffc0203432:	100027f3          	csrr	a5,sstatus
ffffffffc0203436:	8b89                	andi	a5,a5,2
ffffffffc0203438:	2c079463          	bnez	a5,ffffffffc0203700 <pmm_init+0x662>
ffffffffc020343c:	000b3783          	ld	a5,0(s6)
ffffffffc0203440:	4585                	li	a1,1
ffffffffc0203442:	739c                	ld	a5,32(a5)
ffffffffc0203444:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0203446:	00093783          	ld	a5,0(s2)
ffffffffc020344a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd57aa8>
    asm volatile("sfence.vma");
ffffffffc020344e:	12000073          	sfence.vma
ffffffffc0203452:	100027f3          	csrr	a5,sstatus
ffffffffc0203456:	8b89                	andi	a5,a5,2
ffffffffc0203458:	28079a63          	bnez	a5,ffffffffc02036ec <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc020345c:	000b3783          	ld	a5,0(s6)
ffffffffc0203460:	779c                	ld	a5,40(a5)
ffffffffc0203462:	9782                	jalr	a5
ffffffffc0203464:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203466:	4d441063          	bne	s0,s4,ffffffffc0203926 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020346a:	00004517          	auipc	a0,0x4
ffffffffc020346e:	9f650513          	addi	a0,a0,-1546 # ffffffffc0206e60 <etext+0x1570>
ffffffffc0203472:	c6dfc0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc0203476:	100027f3          	csrr	a5,sstatus
ffffffffc020347a:	8b89                	andi	a5,a5,2
ffffffffc020347c:	24079e63          	bnez	a5,ffffffffc02036d8 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc0203480:	000b3783          	ld	a5,0(s6)
ffffffffc0203484:	779c                	ld	a5,40(a5)
ffffffffc0203486:	9782                	jalr	a5
ffffffffc0203488:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020348a:	609c                	ld	a5,0(s1)
ffffffffc020348c:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203490:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0203492:	00c79713          	slli	a4,a5,0xc
ffffffffc0203496:	6a85                	lui	s5,0x1
ffffffffc0203498:	02e47c63          	bgeu	s0,a4,ffffffffc02034d0 <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020349c:	00c45713          	srli	a4,s0,0xc
ffffffffc02034a0:	30f77063          	bgeu	a4,a5,ffffffffc02037a0 <pmm_init+0x702>
ffffffffc02034a4:	0009b583          	ld	a1,0(s3)
ffffffffc02034a8:	00093503          	ld	a0,0(s2)
ffffffffc02034ac:	4601                	li	a2,0
ffffffffc02034ae:	95a2                	add	a1,a1,s0
ffffffffc02034b0:	bc2ff0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc02034b4:	32050363          	beqz	a0,ffffffffc02037da <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02034b8:	611c                	ld	a5,0(a0)
ffffffffc02034ba:	078a                	slli	a5,a5,0x2
ffffffffc02034bc:	0147f7b3          	and	a5,a5,s4
ffffffffc02034c0:	2e879d63          	bne	a5,s0,ffffffffc02037ba <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02034c4:	609c                	ld	a5,0(s1)
ffffffffc02034c6:	9456                	add	s0,s0,s5
ffffffffc02034c8:	00c79713          	slli	a4,a5,0xc
ffffffffc02034cc:	fce468e3          	bltu	s0,a4,ffffffffc020349c <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc02034d0:	00093783          	ld	a5,0(s2)
ffffffffc02034d4:	639c                	ld	a5,0(a5)
ffffffffc02034d6:	42079863          	bnez	a5,ffffffffc0203906 <pmm_init+0x868>
ffffffffc02034da:	100027f3          	csrr	a5,sstatus
ffffffffc02034de:	8b89                	andi	a5,a5,2
ffffffffc02034e0:	24079863          	bnez	a5,ffffffffc0203730 <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc02034e4:	000b3783          	ld	a5,0(s6)
ffffffffc02034e8:	4505                	li	a0,1
ffffffffc02034ea:	6f9c                	ld	a5,24(a5)
ffffffffc02034ec:	9782                	jalr	a5
ffffffffc02034ee:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02034f0:	00093503          	ld	a0,0(s2)
ffffffffc02034f4:	4699                	li	a3,6
ffffffffc02034f6:	10000613          	li	a2,256
ffffffffc02034fa:	85a2                	mv	a1,s0
ffffffffc02034fc:	aadff0ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc0203500:	46051363          	bnez	a0,ffffffffc0203966 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0203504:	4018                	lw	a4,0(s0)
ffffffffc0203506:	4785                	li	a5,1
ffffffffc0203508:	42f71f63          	bne	a4,a5,ffffffffc0203946 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020350c:	00093503          	ld	a0,0(s2)
ffffffffc0203510:	6605                	lui	a2,0x1
ffffffffc0203512:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7b08>
ffffffffc0203516:	4699                	li	a3,6
ffffffffc0203518:	85a2                	mv	a1,s0
ffffffffc020351a:	a8fff0ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc020351e:	72051963          	bnez	a0,ffffffffc0203c50 <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0203522:	4018                	lw	a4,0(s0)
ffffffffc0203524:	4789                	li	a5,2
ffffffffc0203526:	70f71563          	bne	a4,a5,ffffffffc0203c30 <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020352a:	00004597          	auipc	a1,0x4
ffffffffc020352e:	a7e58593          	addi	a1,a1,-1410 # ffffffffc0206fa8 <etext+0x16b8>
ffffffffc0203532:	10000513          	li	a0,256
ffffffffc0203536:	72f010ef          	jal	ffffffffc0205464 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020353a:	6585                	lui	a1,0x1
ffffffffc020353c:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7b08>
ffffffffc0203540:	10000513          	li	a0,256
ffffffffc0203544:	733010ef          	jal	ffffffffc0205476 <strcmp>
ffffffffc0203548:	6c051463          	bnez	a0,ffffffffc0203c10 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc020354c:	000bb683          	ld	a3,0(s7)
ffffffffc0203550:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0203554:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0203556:	40d406b3          	sub	a3,s0,a3
ffffffffc020355a:	8699                	srai	a3,a3,0x6
ffffffffc020355c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020355e:	00c69793          	slli	a5,a3,0xc
ffffffffc0203562:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203564:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203566:	32e7f463          	bgeu	a5,a4,ffffffffc020388e <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020356a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020356e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203572:	97b6                	add	a5,a5,a3
ffffffffc0203574:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_cowtest_out_size+0x73f08>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203578:	6b9010ef          	jal	ffffffffc0205430 <strlen>
ffffffffc020357c:	66051a63          	bnez	a0,ffffffffc0203bf0 <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0203580:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0203584:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203586:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd57aa8>
ffffffffc020358a:	078a                	slli	a5,a5,0x2
ffffffffc020358c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020358e:	26e7f663          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0203592:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0203596:	2ee7fc63          	bgeu	a5,a4,ffffffffc020388e <pmm_init+0x7f0>
ffffffffc020359a:	0009b783          	ld	a5,0(s3)
ffffffffc020359e:	00f689b3          	add	s3,a3,a5
ffffffffc02035a2:	100027f3          	csrr	a5,sstatus
ffffffffc02035a6:	8b89                	andi	a5,a5,2
ffffffffc02035a8:	1e079163          	bnez	a5,ffffffffc020378a <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc02035ac:	000b3783          	ld	a5,0(s6)
ffffffffc02035b0:	8522                	mv	a0,s0
ffffffffc02035b2:	4585                	li	a1,1
ffffffffc02035b4:	739c                	ld	a5,32(a5)
ffffffffc02035b6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035b8:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc02035bc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035be:	078a                	slli	a5,a5,0x2
ffffffffc02035c0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035c2:	22e7fc63          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02035c6:	000bb503          	ld	a0,0(s7)
ffffffffc02035ca:	fe000737          	lui	a4,0xfe000
ffffffffc02035ce:	079a                	slli	a5,a5,0x6
ffffffffc02035d0:	97ba                	add	a5,a5,a4
ffffffffc02035d2:	953e                	add	a0,a0,a5
ffffffffc02035d4:	100027f3          	csrr	a5,sstatus
ffffffffc02035d8:	8b89                	andi	a5,a5,2
ffffffffc02035da:	18079c63          	bnez	a5,ffffffffc0203772 <pmm_init+0x6d4>
ffffffffc02035de:	000b3783          	ld	a5,0(s6)
ffffffffc02035e2:	4585                	li	a1,1
ffffffffc02035e4:	739c                	ld	a5,32(a5)
ffffffffc02035e6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02035e8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02035ec:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02035ee:	078a                	slli	a5,a5,0x2
ffffffffc02035f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02035f2:	20e7f463          	bgeu	a5,a4,ffffffffc02037fa <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02035f6:	000bb503          	ld	a0,0(s7)
ffffffffc02035fa:	fe000737          	lui	a4,0xfe000
ffffffffc02035fe:	079a                	slli	a5,a5,0x6
ffffffffc0203600:	97ba                	add	a5,a5,a4
ffffffffc0203602:	953e                	add	a0,a0,a5
ffffffffc0203604:	100027f3          	csrr	a5,sstatus
ffffffffc0203608:	8b89                	andi	a5,a5,2
ffffffffc020360a:	14079863          	bnez	a5,ffffffffc020375a <pmm_init+0x6bc>
ffffffffc020360e:	000b3783          	ld	a5,0(s6)
ffffffffc0203612:	4585                	li	a1,1
ffffffffc0203614:	739c                	ld	a5,32(a5)
ffffffffc0203616:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0203618:	00093783          	ld	a5,0(s2)
ffffffffc020361c:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0203620:	12000073          	sfence.vma
ffffffffc0203624:	100027f3          	csrr	a5,sstatus
ffffffffc0203628:	8b89                	andi	a5,a5,2
ffffffffc020362a:	10079e63          	bnez	a5,ffffffffc0203746 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc020362e:	000b3783          	ld	a5,0(s6)
ffffffffc0203632:	779c                	ld	a5,40(a5)
ffffffffc0203634:	9782                	jalr	a5
ffffffffc0203636:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0203638:	1e8c1b63          	bne	s8,s0,ffffffffc020382e <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020363c:	00004517          	auipc	a0,0x4
ffffffffc0203640:	9e450513          	addi	a0,a0,-1564 # ffffffffc0207020 <etext+0x1730>
ffffffffc0203644:	a9bfc0ef          	jal	ffffffffc02000de <cprintf>
}
ffffffffc0203648:	7406                	ld	s0,96(sp)
ffffffffc020364a:	70a6                	ld	ra,104(sp)
ffffffffc020364c:	64e6                	ld	s1,88(sp)
ffffffffc020364e:	6946                	ld	s2,80(sp)
ffffffffc0203650:	69a6                	ld	s3,72(sp)
ffffffffc0203652:	6a06                	ld	s4,64(sp)
ffffffffc0203654:	7ae2                	ld	s5,56(sp)
ffffffffc0203656:	7b42                	ld	s6,48(sp)
ffffffffc0203658:	7ba2                	ld	s7,40(sp)
ffffffffc020365a:	7c02                	ld	s8,32(sp)
ffffffffc020365c:	6ce2                	ld	s9,24(sp)
ffffffffc020365e:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0203660:	c9afe06f          	j	ffffffffc0201afa <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0203664:	853e                	mv	a0,a5
ffffffffc0203666:	b4e1                	j	ffffffffc020312e <pmm_init+0x90>
        intr_disable();  // 关闭中断
ffffffffc0203668:	aa2fd0ef          	jal	ffffffffc020090a <intr_disable>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc020366c:	000b3783          	ld	a5,0(s6)
ffffffffc0203670:	4505                	li	a0,1
ffffffffc0203672:	6f9c                	ld	a5,24(a5)
ffffffffc0203674:	9782                	jalr	a5
ffffffffc0203676:	8a2a                	mv	s4,a0
        intr_enable();  // 重新开启中断
ffffffffc0203678:	a8cfd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc020367c:	be75                	j	ffffffffc0203238 <pmm_init+0x19a>
        intr_disable();  // 关闭中断
ffffffffc020367e:	a8cfd0ef          	jal	ffffffffc020090a <intr_disable>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc0203682:	000b3783          	ld	a5,0(s6)
ffffffffc0203686:	779c                	ld	a5,40(a5)
ffffffffc0203688:	9782                	jalr	a5
ffffffffc020368a:	842a                	mv	s0,a0
        intr_enable();  // 重新开启中断
ffffffffc020368c:	a78fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203690:	b6ad                	j	ffffffffc02031fa <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0203692:	6705                	lui	a4,0x1
ffffffffc0203694:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x7c09>
ffffffffc0203696:	96ba                	add	a3,a3,a4
ffffffffc0203698:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc020369a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020369e:	14a77e63          	bgeu	a4,a0,ffffffffc02037fa <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);   // 初始化内存映射
ffffffffc02036a2:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02036a6:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc02036a8:	071a                	slli	a4,a4,0x6
ffffffffc02036aa:	fe0007b7          	lui	a5,0xfe000
ffffffffc02036ae:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);   // 初始化内存映射
ffffffffc02036b0:	6a9c                	ld	a5,16(a3)
ffffffffc02036b2:	00c45593          	srli	a1,s0,0xc
ffffffffc02036b6:	00e60533          	add	a0,a2,a4
ffffffffc02036ba:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02036bc:	0009b583          	ld	a1,0(s3)
}
ffffffffc02036c0:	bcf1                	j	ffffffffc020319c <pmm_init+0xfe>
        intr_disable();  // 关闭中断
ffffffffc02036c2:	a48fd0ef          	jal	ffffffffc020090a <intr_disable>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc02036c6:	000b3783          	ld	a5,0(s6)
ffffffffc02036ca:	4505                	li	a0,1
ffffffffc02036cc:	6f9c                	ld	a5,24(a5)
ffffffffc02036ce:	9782                	jalr	a5
ffffffffc02036d0:	8c2a                	mv	s8,a0
        intr_enable();  // 重新开启中断
ffffffffc02036d2:	a32fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc02036d6:	b119                	j	ffffffffc02032dc <pmm_init+0x23e>
        intr_disable();  // 关闭中断
ffffffffc02036d8:	a32fd0ef          	jal	ffffffffc020090a <intr_disable>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc02036dc:	000b3783          	ld	a5,0(s6)
ffffffffc02036e0:	779c                	ld	a5,40(a5)
ffffffffc02036e2:	9782                	jalr	a5
ffffffffc02036e4:	8c2a                	mv	s8,a0
        intr_enable();  // 重新开启中断
ffffffffc02036e6:	a1efd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc02036ea:	b345                	j	ffffffffc020348a <pmm_init+0x3ec>
        intr_disable();  // 关闭中断
ffffffffc02036ec:	a1efd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc02036f0:	000b3783          	ld	a5,0(s6)
ffffffffc02036f4:	779c                	ld	a5,40(a5)
ffffffffc02036f6:	9782                	jalr	a5
ffffffffc02036f8:	8a2a                	mv	s4,a0
        intr_enable();  // 重新开启中断
ffffffffc02036fa:	a0afd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc02036fe:	b3a5                	j	ffffffffc0203466 <pmm_init+0x3c8>
ffffffffc0203700:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc0203702:	a08fd0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0203706:	000b3783          	ld	a5,0(s6)
ffffffffc020370a:	6522                	ld	a0,8(sp)
ffffffffc020370c:	4585                	li	a1,1
ffffffffc020370e:	739c                	ld	a5,32(a5)
ffffffffc0203710:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc0203712:	9f2fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203716:	bb05                	j	ffffffffc0203446 <pmm_init+0x3a8>
ffffffffc0203718:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc020371a:	9f0fd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc020371e:	000b3783          	ld	a5,0(s6)
ffffffffc0203722:	6522                	ld	a0,8(sp)
ffffffffc0203724:	4585                	li	a1,1
ffffffffc0203726:	739c                	ld	a5,32(a5)
ffffffffc0203728:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc020372a:	9dafd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc020372e:	b1e5                	j	ffffffffc0203416 <pmm_init+0x378>
        intr_disable();  // 关闭中断
ffffffffc0203730:	9dafd0ef          	jal	ffffffffc020090a <intr_disable>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc0203734:	000b3783          	ld	a5,0(s6)
ffffffffc0203738:	4505                	li	a0,1
ffffffffc020373a:	6f9c                	ld	a5,24(a5)
ffffffffc020373c:	9782                	jalr	a5
ffffffffc020373e:	842a                	mv	s0,a0
        intr_enable();  // 重新开启中断
ffffffffc0203740:	9c4fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203744:	b375                	j	ffffffffc02034f0 <pmm_init+0x452>
        intr_disable();  // 关闭中断
ffffffffc0203746:	9c4fd0ef          	jal	ffffffffc020090a <intr_disable>
        ret = pmm_manager->nr_free_pages();  // 调用具体查询算法
ffffffffc020374a:	000b3783          	ld	a5,0(s6)
ffffffffc020374e:	779c                	ld	a5,40(a5)
ffffffffc0203750:	9782                	jalr	a5
ffffffffc0203752:	842a                	mv	s0,a0
        intr_enable();  // 重新开启中断
ffffffffc0203754:	9b0fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203758:	b5c5                	j	ffffffffc0203638 <pmm_init+0x59a>
ffffffffc020375a:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc020375c:	9aefd0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0203760:	000b3783          	ld	a5,0(s6)
ffffffffc0203764:	6522                	ld	a0,8(sp)
ffffffffc0203766:	4585                	li	a1,1
ffffffffc0203768:	739c                	ld	a5,32(a5)
ffffffffc020376a:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc020376c:	998fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203770:	b565                	j	ffffffffc0203618 <pmm_init+0x57a>
ffffffffc0203772:	e42a                	sd	a0,8(sp)
        intr_disable();  // 关闭中断
ffffffffc0203774:	996fd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc0203778:	000b3783          	ld	a5,0(s6)
ffffffffc020377c:	6522                	ld	a0,8(sp)
ffffffffc020377e:	4585                	li	a1,1
ffffffffc0203780:	739c                	ld	a5,32(a5)
ffffffffc0203782:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc0203784:	980fd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203788:	b585                	j	ffffffffc02035e8 <pmm_init+0x54a>
        intr_disable();  // 关闭中断
ffffffffc020378a:	980fd0ef          	jal	ffffffffc020090a <intr_disable>
ffffffffc020378e:	000b3783          	ld	a5,0(s6)
ffffffffc0203792:	8522                	mv	a0,s0
ffffffffc0203794:	4585                	li	a1,1
ffffffffc0203796:	739c                	ld	a5,32(a5)
ffffffffc0203798:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc020379a:	96afd0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc020379e:	bd29                	j	ffffffffc02035b8 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02037a0:	86a2                	mv	a3,s0
ffffffffc02037a2:	00003617          	auipc	a2,0x3
ffffffffc02037a6:	b5660613          	addi	a2,a2,-1194 # ffffffffc02062f8 <etext+0xa08>
ffffffffc02037aa:	24000593          	li	a1,576
ffffffffc02037ae:	00003517          	auipc	a0,0x3
ffffffffc02037b2:	27a50513          	addi	a0,a0,634 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02037b6:	a73fc0ef          	jal	ffffffffc0200228 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02037ba:	00003697          	auipc	a3,0x3
ffffffffc02037be:	70668693          	addi	a3,a3,1798 # ffffffffc0206ec0 <etext+0x15d0>
ffffffffc02037c2:	00003617          	auipc	a2,0x3
ffffffffc02037c6:	bae60613          	addi	a2,a2,-1106 # ffffffffc0206370 <etext+0xa80>
ffffffffc02037ca:	24100593          	li	a1,577
ffffffffc02037ce:	00003517          	auipc	a0,0x3
ffffffffc02037d2:	25a50513          	addi	a0,a0,602 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02037d6:	a53fc0ef          	jal	ffffffffc0200228 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02037da:	00003697          	auipc	a3,0x3
ffffffffc02037de:	6a668693          	addi	a3,a3,1702 # ffffffffc0206e80 <etext+0x1590>
ffffffffc02037e2:	00003617          	auipc	a2,0x3
ffffffffc02037e6:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0206370 <etext+0xa80>
ffffffffc02037ea:	24000593          	li	a1,576
ffffffffc02037ee:	00003517          	auipc	a0,0x3
ffffffffc02037f2:	23a50513          	addi	a0,a0,570 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02037f6:	a33fc0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc02037fa:	fb5fe0ef          	jal	ffffffffc02027ae <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc02037fe:	00003617          	auipc	a2,0x3
ffffffffc0203802:	42260613          	addi	a2,a2,1058 # ffffffffc0206c20 <etext+0x1330>
ffffffffc0203806:	08100593          	li	a1,129
ffffffffc020380a:	00003517          	auipc	a0,0x3
ffffffffc020380e:	ace50513          	addi	a0,a0,-1330 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0203812:	a17fc0ef          	jal	ffffffffc0200228 <__panic>
        panic("DTB memory info not available");  // DTB中无内存信息
ffffffffc0203816:	00003617          	auipc	a2,0x3
ffffffffc020381a:	28260613          	addi	a2,a2,642 # ffffffffc0206a98 <etext+0x11a8>
ffffffffc020381e:	06700593          	li	a1,103
ffffffffc0203822:	00003517          	auipc	a0,0x3
ffffffffc0203826:	20650513          	addi	a0,a0,518 # ffffffffc0206a28 <etext+0x1138>
ffffffffc020382a:	9fffc0ef          	jal	ffffffffc0200228 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020382e:	00003697          	auipc	a3,0x3
ffffffffc0203832:	60a68693          	addi	a3,a3,1546 # ffffffffc0206e38 <etext+0x1548>
ffffffffc0203836:	00003617          	auipc	a2,0x3
ffffffffc020383a:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0206370 <etext+0xa80>
ffffffffc020383e:	25b00593          	li	a1,603
ffffffffc0203842:	00003517          	auipc	a0,0x3
ffffffffc0203846:	1e650513          	addi	a0,a0,486 # ffffffffc0206a28 <etext+0x1138>
ffffffffc020384a:	9dffc0ef          	jal	ffffffffc0200228 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020384e:	00003697          	auipc	a3,0x3
ffffffffc0203852:	30268693          	addi	a3,a3,770 # ffffffffc0206b50 <etext+0x1260>
ffffffffc0203856:	00003617          	auipc	a2,0x3
ffffffffc020385a:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0206370 <etext+0xa80>
ffffffffc020385e:	20200593          	li	a1,514
ffffffffc0203862:	00003517          	auipc	a0,0x3
ffffffffc0203866:	1c650513          	addi	a0,a0,454 # ffffffffc0206a28 <etext+0x1138>
ffffffffc020386a:	9bffc0ef          	jal	ffffffffc0200228 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020386e:	00003697          	auipc	a3,0x3
ffffffffc0203872:	2c268693          	addi	a3,a3,706 # ffffffffc0206b30 <etext+0x1240>
ffffffffc0203876:	00003617          	auipc	a2,0x3
ffffffffc020387a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0206370 <etext+0xa80>
ffffffffc020387e:	20100593          	li	a1,513
ffffffffc0203882:	00003517          	auipc	a0,0x3
ffffffffc0203886:	1a650513          	addi	a0,a0,422 # ffffffffc0206a28 <etext+0x1138>
ffffffffc020388a:	99ffc0ef          	jal	ffffffffc0200228 <__panic>
    return KADDR(page2pa(page));
ffffffffc020388e:	00003617          	auipc	a2,0x3
ffffffffc0203892:	a6a60613          	addi	a2,a2,-1430 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0203896:	07300593          	li	a1,115
ffffffffc020389a:	00003517          	auipc	a0,0x3
ffffffffc020389e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc02038a2:	987fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02038a6:	00003697          	auipc	a3,0x3
ffffffffc02038aa:	56268693          	addi	a3,a3,1378 # ffffffffc0206e08 <etext+0x1518>
ffffffffc02038ae:	00003617          	auipc	a2,0x3
ffffffffc02038b2:	ac260613          	addi	a2,a2,-1342 # ffffffffc0206370 <etext+0xa80>
ffffffffc02038b6:	22900593          	li	a1,553
ffffffffc02038ba:	00003517          	auipc	a0,0x3
ffffffffc02038be:	16e50513          	addi	a0,a0,366 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02038c2:	967fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02038c6:	00003697          	auipc	a3,0x3
ffffffffc02038ca:	4fa68693          	addi	a3,a3,1274 # ffffffffc0206dc0 <etext+0x14d0>
ffffffffc02038ce:	00003617          	auipc	a2,0x3
ffffffffc02038d2:	aa260613          	addi	a2,a2,-1374 # ffffffffc0206370 <etext+0xa80>
ffffffffc02038d6:	22700593          	li	a1,551
ffffffffc02038da:	00003517          	auipc	a0,0x3
ffffffffc02038de:	14e50513          	addi	a0,a0,334 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02038e2:	947fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02038e6:	00003697          	auipc	a3,0x3
ffffffffc02038ea:	50a68693          	addi	a3,a3,1290 # ffffffffc0206df0 <etext+0x1500>
ffffffffc02038ee:	00003617          	auipc	a2,0x3
ffffffffc02038f2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0206370 <etext+0xa80>
ffffffffc02038f6:	22600593          	li	a1,550
ffffffffc02038fa:	00003517          	auipc	a0,0x3
ffffffffc02038fe:	12e50513          	addi	a0,a0,302 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203902:	927fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0203906:	00003697          	auipc	a3,0x3
ffffffffc020390a:	5d268693          	addi	a3,a3,1490 # ffffffffc0206ed8 <etext+0x15e8>
ffffffffc020390e:	00003617          	auipc	a2,0x3
ffffffffc0203912:	a6260613          	addi	a2,a2,-1438 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203916:	24400593          	li	a1,580
ffffffffc020391a:	00003517          	auipc	a0,0x3
ffffffffc020391e:	10e50513          	addi	a0,a0,270 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203922:	907fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203926:	00003697          	auipc	a3,0x3
ffffffffc020392a:	51268693          	addi	a3,a3,1298 # ffffffffc0206e38 <etext+0x1548>
ffffffffc020392e:	00003617          	auipc	a2,0x3
ffffffffc0203932:	a4260613          	addi	a2,a2,-1470 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203936:	23100593          	li	a1,561
ffffffffc020393a:	00003517          	auipc	a0,0x3
ffffffffc020393e:	0ee50513          	addi	a0,a0,238 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203942:	8e7fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203946:	00003697          	auipc	a3,0x3
ffffffffc020394a:	5ea68693          	addi	a3,a3,1514 # ffffffffc0206f30 <etext+0x1640>
ffffffffc020394e:	00003617          	auipc	a2,0x3
ffffffffc0203952:	a2260613          	addi	a2,a2,-1502 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203956:	24900593          	li	a1,585
ffffffffc020395a:	00003517          	auipc	a0,0x3
ffffffffc020395e:	0ce50513          	addi	a0,a0,206 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203962:	8c7fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203966:	00003697          	auipc	a3,0x3
ffffffffc020396a:	58a68693          	addi	a3,a3,1418 # ffffffffc0206ef0 <etext+0x1600>
ffffffffc020396e:	00003617          	auipc	a2,0x3
ffffffffc0203972:	a0260613          	addi	a2,a2,-1534 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203976:	24800593          	li	a1,584
ffffffffc020397a:	00003517          	auipc	a0,0x3
ffffffffc020397e:	0ae50513          	addi	a0,a0,174 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203982:	8a7fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203986:	00003697          	auipc	a3,0x3
ffffffffc020398a:	43a68693          	addi	a3,a3,1082 # ffffffffc0206dc0 <etext+0x14d0>
ffffffffc020398e:	00003617          	auipc	a2,0x3
ffffffffc0203992:	9e260613          	addi	a2,a2,-1566 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203996:	22300593          	li	a1,547
ffffffffc020399a:	00003517          	auipc	a0,0x3
ffffffffc020399e:	08e50513          	addi	a0,a0,142 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02039a2:	887fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02039a6:	00003697          	auipc	a3,0x3
ffffffffc02039aa:	2ba68693          	addi	a3,a3,698 # ffffffffc0206c60 <etext+0x1370>
ffffffffc02039ae:	00003617          	auipc	a2,0x3
ffffffffc02039b2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0206370 <etext+0xa80>
ffffffffc02039b6:	22200593          	li	a1,546
ffffffffc02039ba:	00003517          	auipc	a0,0x3
ffffffffc02039be:	06e50513          	addi	a0,a0,110 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02039c2:	867fc0ef          	jal	ffffffffc0200228 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02039c6:	00003697          	auipc	a3,0x3
ffffffffc02039ca:	41268693          	addi	a3,a3,1042 # ffffffffc0206dd8 <etext+0x14e8>
ffffffffc02039ce:	00003617          	auipc	a2,0x3
ffffffffc02039d2:	9a260613          	addi	a2,a2,-1630 # ffffffffc0206370 <etext+0xa80>
ffffffffc02039d6:	21f00593          	li	a1,543
ffffffffc02039da:	00003517          	auipc	a0,0x3
ffffffffc02039de:	04e50513          	addi	a0,a0,78 # ffffffffc0206a28 <etext+0x1138>
ffffffffc02039e2:	847fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02039e6:	00003697          	auipc	a3,0x3
ffffffffc02039ea:	26268693          	addi	a3,a3,610 # ffffffffc0206c48 <etext+0x1358>
ffffffffc02039ee:	00003617          	auipc	a2,0x3
ffffffffc02039f2:	98260613          	addi	a2,a2,-1662 # ffffffffc0206370 <etext+0xa80>
ffffffffc02039f6:	21e00593          	li	a1,542
ffffffffc02039fa:	00003517          	auipc	a0,0x3
ffffffffc02039fe:	02e50513          	addi	a0,a0,46 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203a02:	827fc0ef          	jal	ffffffffc0200228 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203a06:	00003697          	auipc	a3,0x3
ffffffffc0203a0a:	2e268693          	addi	a3,a3,738 # ffffffffc0206ce8 <etext+0x13f8>
ffffffffc0203a0e:	00003617          	auipc	a2,0x3
ffffffffc0203a12:	96260613          	addi	a2,a2,-1694 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203a16:	21d00593          	li	a1,541
ffffffffc0203a1a:	00003517          	auipc	a0,0x3
ffffffffc0203a1e:	00e50513          	addi	a0,a0,14 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203a22:	807fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203a26:	00003697          	auipc	a3,0x3
ffffffffc0203a2a:	39a68693          	addi	a3,a3,922 # ffffffffc0206dc0 <etext+0x14d0>
ffffffffc0203a2e:	00003617          	auipc	a2,0x3
ffffffffc0203a32:	94260613          	addi	a2,a2,-1726 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203a36:	21c00593          	li	a1,540
ffffffffc0203a3a:	00003517          	auipc	a0,0x3
ffffffffc0203a3e:	fee50513          	addi	a0,a0,-18 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203a42:	fe6fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203a46:	00003697          	auipc	a3,0x3
ffffffffc0203a4a:	36268693          	addi	a3,a3,866 # ffffffffc0206da8 <etext+0x14b8>
ffffffffc0203a4e:	00003617          	auipc	a2,0x3
ffffffffc0203a52:	92260613          	addi	a2,a2,-1758 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203a56:	21b00593          	li	a1,539
ffffffffc0203a5a:	00003517          	auipc	a0,0x3
ffffffffc0203a5e:	fce50513          	addi	a0,a0,-50 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203a62:	fc6fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203a66:	00003697          	auipc	a3,0x3
ffffffffc0203a6a:	31268693          	addi	a3,a3,786 # ffffffffc0206d78 <etext+0x1488>
ffffffffc0203a6e:	00003617          	auipc	a2,0x3
ffffffffc0203a72:	90260613          	addi	a2,a2,-1790 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203a76:	21a00593          	li	a1,538
ffffffffc0203a7a:	00003517          	auipc	a0,0x3
ffffffffc0203a7e:	fae50513          	addi	a0,a0,-82 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203a82:	fa6fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203a86:	00003697          	auipc	a3,0x3
ffffffffc0203a8a:	2da68693          	addi	a3,a3,730 # ffffffffc0206d60 <etext+0x1470>
ffffffffc0203a8e:	00003617          	auipc	a2,0x3
ffffffffc0203a92:	8e260613          	addi	a2,a2,-1822 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203a96:	21800593          	li	a1,536
ffffffffc0203a9a:	00003517          	auipc	a0,0x3
ffffffffc0203a9e:	f8e50513          	addi	a0,a0,-114 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203aa2:	f86fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203aa6:	00003697          	auipc	a3,0x3
ffffffffc0203aaa:	29a68693          	addi	a3,a3,666 # ffffffffc0206d40 <etext+0x1450>
ffffffffc0203aae:	00003617          	auipc	a2,0x3
ffffffffc0203ab2:	8c260613          	addi	a2,a2,-1854 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203ab6:	21700593          	li	a1,535
ffffffffc0203aba:	00003517          	auipc	a0,0x3
ffffffffc0203abe:	f6e50513          	addi	a0,a0,-146 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203ac2:	f66fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203ac6:	00003697          	auipc	a3,0x3
ffffffffc0203aca:	26a68693          	addi	a3,a3,618 # ffffffffc0206d30 <etext+0x1440>
ffffffffc0203ace:	00003617          	auipc	a2,0x3
ffffffffc0203ad2:	8a260613          	addi	a2,a2,-1886 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203ad6:	21600593          	li	a1,534
ffffffffc0203ada:	00003517          	auipc	a0,0x3
ffffffffc0203ade:	f4e50513          	addi	a0,a0,-178 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203ae2:	f46fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203ae6:	00003697          	auipc	a3,0x3
ffffffffc0203aea:	23a68693          	addi	a3,a3,570 # ffffffffc0206d20 <etext+0x1430>
ffffffffc0203aee:	00003617          	auipc	a2,0x3
ffffffffc0203af2:	88260613          	addi	a2,a2,-1918 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203af6:	21500593          	li	a1,533
ffffffffc0203afa:	00003517          	auipc	a0,0x3
ffffffffc0203afe:	f2e50513          	addi	a0,a0,-210 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203b02:	f26fc0ef          	jal	ffffffffc0200228 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203b06:	00003617          	auipc	a2,0x3
ffffffffc0203b0a:	b5260613          	addi	a2,a2,-1198 # ffffffffc0206658 <etext+0xd68>
ffffffffc0203b0e:	08300593          	li	a1,131
ffffffffc0203b12:	00003517          	auipc	a0,0x3
ffffffffc0203b16:	f1650513          	addi	a0,a0,-234 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203b1a:	f0efc0ef          	jal	ffffffffc0200228 <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203b1e:	00003697          	auipc	a3,0x3
ffffffffc0203b22:	15a68693          	addi	a3,a3,346 # ffffffffc0206c78 <etext+0x1388>
ffffffffc0203b26:	00003617          	auipc	a2,0x3
ffffffffc0203b2a:	84a60613          	addi	a2,a2,-1974 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203b2e:	21000593          	li	a1,528
ffffffffc0203b32:	00003517          	auipc	a0,0x3
ffffffffc0203b36:	ef650513          	addi	a0,a0,-266 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203b3a:	eeefc0ef          	jal	ffffffffc0200228 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203b3e:	00003697          	auipc	a3,0x3
ffffffffc0203b42:	1aa68693          	addi	a3,a3,426 # ffffffffc0206ce8 <etext+0x13f8>
ffffffffc0203b46:	00003617          	auipc	a2,0x3
ffffffffc0203b4a:	82a60613          	addi	a2,a2,-2006 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203b4e:	21400593          	li	a1,532
ffffffffc0203b52:	00003517          	auipc	a0,0x3
ffffffffc0203b56:	ed650513          	addi	a0,a0,-298 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203b5a:	ecefc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203b5e:	00003697          	auipc	a3,0x3
ffffffffc0203b62:	14a68693          	addi	a3,a3,330 # ffffffffc0206ca8 <etext+0x13b8>
ffffffffc0203b66:	00003617          	auipc	a2,0x3
ffffffffc0203b6a:	80a60613          	addi	a2,a2,-2038 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203b6e:	21300593          	li	a1,531
ffffffffc0203b72:	00003517          	auipc	a0,0x3
ffffffffc0203b76:	eb650513          	addi	a0,a0,-330 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203b7a:	eaefc0ef          	jal	ffffffffc0200228 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203b7e:	86d6                	mv	a3,s5
ffffffffc0203b80:	00002617          	auipc	a2,0x2
ffffffffc0203b84:	77860613          	addi	a2,a2,1912 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0203b88:	20f00593          	li	a1,527
ffffffffc0203b8c:	00003517          	auipc	a0,0x3
ffffffffc0203b90:	e9c50513          	addi	a0,a0,-356 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203b94:	e94fc0ef          	jal	ffffffffc0200228 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203b98:	00002617          	auipc	a2,0x2
ffffffffc0203b9c:	76060613          	addi	a2,a2,1888 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0203ba0:	20e00593          	li	a1,526
ffffffffc0203ba4:	00003517          	auipc	a0,0x3
ffffffffc0203ba8:	e8450513          	addi	a0,a0,-380 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203bac:	e7cfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203bb0:	00003697          	auipc	a3,0x3
ffffffffc0203bb4:	0b068693          	addi	a3,a3,176 # ffffffffc0206c60 <etext+0x1370>
ffffffffc0203bb8:	00002617          	auipc	a2,0x2
ffffffffc0203bbc:	7b860613          	addi	a2,a2,1976 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203bc0:	20c00593          	li	a1,524
ffffffffc0203bc4:	00003517          	auipc	a0,0x3
ffffffffc0203bc8:	e6450513          	addi	a0,a0,-412 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203bcc:	e5cfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203bd0:	00003697          	auipc	a3,0x3
ffffffffc0203bd4:	07868693          	addi	a3,a3,120 # ffffffffc0206c48 <etext+0x1358>
ffffffffc0203bd8:	00002617          	auipc	a2,0x2
ffffffffc0203bdc:	79860613          	addi	a2,a2,1944 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203be0:	20b00593          	li	a1,523
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	e4450513          	addi	a0,a0,-444 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203bec:	e3cfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203bf0:	00003697          	auipc	a3,0x3
ffffffffc0203bf4:	40868693          	addi	a3,a3,1032 # ffffffffc0206ff8 <etext+0x1708>
ffffffffc0203bf8:	00002617          	auipc	a2,0x2
ffffffffc0203bfc:	77860613          	addi	a2,a2,1912 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203c00:	25200593          	li	a1,594
ffffffffc0203c04:	00003517          	auipc	a0,0x3
ffffffffc0203c08:	e2450513          	addi	a0,a0,-476 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203c0c:	e1cfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203c10:	00003697          	auipc	a3,0x3
ffffffffc0203c14:	3b068693          	addi	a3,a3,944 # ffffffffc0206fc0 <etext+0x16d0>
ffffffffc0203c18:	00002617          	auipc	a2,0x2
ffffffffc0203c1c:	75860613          	addi	a2,a2,1880 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203c20:	24f00593          	li	a1,591
ffffffffc0203c24:	00003517          	auipc	a0,0x3
ffffffffc0203c28:	e0450513          	addi	a0,a0,-508 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203c2c:	dfcfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203c30:	00003697          	auipc	a3,0x3
ffffffffc0203c34:	36068693          	addi	a3,a3,864 # ffffffffc0206f90 <etext+0x16a0>
ffffffffc0203c38:	00002617          	auipc	a2,0x2
ffffffffc0203c3c:	73860613          	addi	a2,a2,1848 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203c40:	24b00593          	li	a1,587
ffffffffc0203c44:	00003517          	auipc	a0,0x3
ffffffffc0203c48:	de450513          	addi	a0,a0,-540 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203c4c:	ddcfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203c50:	00003697          	auipc	a3,0x3
ffffffffc0203c54:	2f868693          	addi	a3,a3,760 # ffffffffc0206f48 <etext+0x1658>
ffffffffc0203c58:	00002617          	auipc	a2,0x2
ffffffffc0203c5c:	71860613          	addi	a2,a2,1816 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203c60:	24a00593          	li	a1,586
ffffffffc0203c64:	00003517          	auipc	a0,0x3
ffffffffc0203c68:	dc450513          	addi	a0,a0,-572 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203c6c:	dbcfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203c70:	00003697          	auipc	a3,0x3
ffffffffc0203c74:	f2068693          	addi	a3,a3,-224 # ffffffffc0206b90 <etext+0x12a0>
ffffffffc0203c78:	00002617          	auipc	a2,0x2
ffffffffc0203c7c:	6f860613          	addi	a2,a2,1784 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203c80:	20300593          	li	a1,515
ffffffffc0203c84:	00003517          	auipc	a0,0x3
ffffffffc0203c88:	da450513          	addi	a0,a0,-604 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203c8c:	d9cfc0ef          	jal	ffffffffc0200228 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203c90:	00003617          	auipc	a2,0x3
ffffffffc0203c94:	9c860613          	addi	a2,a2,-1592 # ffffffffc0206658 <etext+0xd68>
ffffffffc0203c98:	0cf00593          	li	a1,207
ffffffffc0203c9c:	00003517          	auipc	a0,0x3
ffffffffc0203ca0:	d8c50513          	addi	a0,a0,-628 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203ca4:	d84fc0ef          	jal	ffffffffc0200228 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203ca8:	00003697          	auipc	a3,0x3
ffffffffc0203cac:	f4868693          	addi	a3,a3,-184 # ffffffffc0206bf0 <etext+0x1300>
ffffffffc0203cb0:	00002617          	auipc	a2,0x2
ffffffffc0203cb4:	6c060613          	addi	a2,a2,1728 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203cb8:	20a00593          	li	a1,522
ffffffffc0203cbc:	00003517          	auipc	a0,0x3
ffffffffc0203cc0:	d6c50513          	addi	a0,a0,-660 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203cc4:	d64fc0ef          	jal	ffffffffc0200228 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203cc8:	00003697          	auipc	a3,0x3
ffffffffc0203ccc:	ef868693          	addi	a3,a3,-264 # ffffffffc0206bc0 <etext+0x12d0>
ffffffffc0203cd0:	00002617          	auipc	a2,0x2
ffffffffc0203cd4:	6a060613          	addi	a2,a2,1696 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203cd8:	20700593          	li	a1,519
ffffffffc0203cdc:	00003517          	auipc	a0,0x3
ffffffffc0203ce0:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203ce4:	d44fc0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0203ce8 <copy_range>:
{
ffffffffc0203ce8:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203cea:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203cee:	ec86                	sd	ra,88(sp)
ffffffffc0203cf0:	e8a2                	sd	s0,80(sp)
ffffffffc0203cf2:	e4a6                	sd	s1,72(sp)
ffffffffc0203cf4:	e0ca                	sd	s2,64(sp)
ffffffffc0203cf6:	fc4e                	sd	s3,56(sp)
ffffffffc0203cf8:	f852                	sd	s4,48(sp)
ffffffffc0203cfa:	f456                	sd	s5,40(sp)
ffffffffc0203cfc:	f05a                	sd	s6,32(sp)
ffffffffc0203cfe:	ec5e                	sd	s7,24(sp)
ffffffffc0203d00:	e862                	sd	s8,16(sp)
ffffffffc0203d02:	e466                	sd	s9,8(sp)
ffffffffc0203d04:	e06a                	sd	s10,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203d06:	03479713          	slli	a4,a5,0x34
ffffffffc0203d0a:	12071b63          	bnez	a4,ffffffffc0203e40 <copy_range+0x158>
    assert(USER_ACCESS(start, end));
ffffffffc0203d0e:	00200c37          	lui	s8,0x200
ffffffffc0203d12:	00d637b3          	sltu	a5,a2,a3
ffffffffc0203d16:	01863733          	sltu	a4,a2,s8
ffffffffc0203d1a:	0017b793          	seqz	a5,a5
ffffffffc0203d1e:	8fd9                	or	a5,a5,a4
ffffffffc0203d20:	8432                	mv	s0,a2
ffffffffc0203d22:	84b6                	mv	s1,a3
ffffffffc0203d24:	0e079e63          	bnez	a5,ffffffffc0203e20 <copy_range+0x138>
ffffffffc0203d28:	4785                	li	a5,1
ffffffffc0203d2a:	07fe                	slli	a5,a5,0x1f
ffffffffc0203d2c:	0785                	addi	a5,a5,1 # fffffffffe000001 <end+0x3dd58aa9>
ffffffffc0203d2e:	0ef6f963          	bgeu	a3,a5,ffffffffc0203e20 <copy_range+0x138>
ffffffffc0203d32:	8a2a                	mv	s4,a0
ffffffffc0203d34:	892e                	mv	s2,a1
ffffffffc0203d36:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc0203d38:	000a3b97          	auipc	s7,0xa3
ffffffffc0203d3c:	7f0b8b93          	addi	s7,s7,2032 # ffffffffc02a7528 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d40:	000a3b17          	auipc	s6,0xa3
ffffffffc0203d44:	7f0b0b13          	addi	s6,s6,2032 # ffffffffc02a7530 <pages>
ffffffffc0203d48:	fff80ab7          	lui	s5,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203d4c:	ffe00cb7          	lui	s9,0xffe00
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203d50:	4601                	li	a2,0
ffffffffc0203d52:	85a2                	mv	a1,s0
ffffffffc0203d54:	854a                	mv	a0,s2
ffffffffc0203d56:	b1dfe0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc0203d5a:	8d2a                	mv	s10,a0
        if (ptep == NULL)
ffffffffc0203d5c:	c935                	beqz	a0,ffffffffc0203dd0 <copy_range+0xe8>
        if (*ptep & PTE_V)
ffffffffc0203d5e:	611c                	ld	a5,0(a0)
ffffffffc0203d60:	8b85                	andi	a5,a5,1
ffffffffc0203d62:	e785                	bnez	a5,ffffffffc0203d8a <copy_range+0xa2>
        start += PGSIZE;
ffffffffc0203d64:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203d66:	c019                	beqz	s0,ffffffffc0203d6c <copy_range+0x84>
ffffffffc0203d68:	fe9464e3          	bltu	s0,s1,ffffffffc0203d50 <copy_range+0x68>
    return 0;
ffffffffc0203d6c:	4501                	li	a0,0
}
ffffffffc0203d6e:	60e6                	ld	ra,88(sp)
ffffffffc0203d70:	6446                	ld	s0,80(sp)
ffffffffc0203d72:	64a6                	ld	s1,72(sp)
ffffffffc0203d74:	6906                	ld	s2,64(sp)
ffffffffc0203d76:	79e2                	ld	s3,56(sp)
ffffffffc0203d78:	7a42                	ld	s4,48(sp)
ffffffffc0203d7a:	7aa2                	ld	s5,40(sp)
ffffffffc0203d7c:	7b02                	ld	s6,32(sp)
ffffffffc0203d7e:	6be2                	ld	s7,24(sp)
ffffffffc0203d80:	6c42                	ld	s8,16(sp)
ffffffffc0203d82:	6ca2                	ld	s9,8(sp)
ffffffffc0203d84:	6d02                	ld	s10,0(sp)
ffffffffc0203d86:	6125                	addi	sp,sp,96
ffffffffc0203d88:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0203d8a:	4605                	li	a2,1
ffffffffc0203d8c:	85a2                	mv	a1,s0
ffffffffc0203d8e:	8552                	mv	a0,s4
ffffffffc0203d90:	ae3fe0ef          	jal	ffffffffc0202872 <get_pte>
ffffffffc0203d94:	cd05                	beqz	a0,ffffffffc0203dcc <copy_range+0xe4>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203d96:	000d3683          	ld	a3,0(s10)
    if (!(pte & PTE_V))
ffffffffc0203d9a:	0016f793          	andi	a5,a3,1
ffffffffc0203d9e:	c7ad                	beqz	a5,ffffffffc0203e08 <copy_range+0x120>
    if (PPN(pa) >= npage)
ffffffffc0203da0:	000bb703          	ld	a4,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203da4:	00269793          	slli	a5,a3,0x2
ffffffffc0203da8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0203daa:	04e7f363          	bgeu	a5,a4,ffffffffc0203df0 <copy_range+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dae:	000b3583          	ld	a1,0(s6)
ffffffffc0203db2:	97d6                	add	a5,a5,s5
ffffffffc0203db4:	079a                	slli	a5,a5,0x6
ffffffffc0203db6:	95be                	add	a1,a1,a5
            if (perm & PTE_W)
ffffffffc0203db8:	0046f793          	andi	a5,a3,4
ffffffffc0203dbc:	ef91                	bnez	a5,ffffffffc0203dd8 <copy_range+0xf0>
            uint32_t perm = (*ptep & (PTE_USER | PTE_COW));
ffffffffc0203dbe:	21f6f693          	andi	a3,a3,543
            int ret = page_insert(to, page, start, perm);
ffffffffc0203dc2:	8622                	mv	a2,s0
ffffffffc0203dc4:	8552                	mv	a0,s4
ffffffffc0203dc6:	9e2ff0ef          	jal	ffffffffc0202fa8 <page_insert>
            if (ret != 0)
ffffffffc0203dca:	dd49                	beqz	a0,ffffffffc0203d64 <copy_range+0x7c>
                return -E_NO_MEM;
ffffffffc0203dcc:	5571                	li	a0,-4
ffffffffc0203dce:	b745                	j	ffffffffc0203d6e <copy_range+0x86>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203dd0:	9462                	add	s0,s0,s8
ffffffffc0203dd2:	01947433          	and	s0,s0,s9
            continue;
ffffffffc0203dd6:	bf41                	j	ffffffffc0203d66 <copy_range+0x7e>
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203dd8:	dfb6f793          	andi	a5,a3,-517
ffffffffc0203ddc:	2007e793          	ori	a5,a5,512
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0203de0:	8aed                	andi	a3,a3,27
                *ptep = (*ptep & ~PTE_W) | PTE_COW;
ffffffffc0203de2:	00fd3023          	sd	a5,0(s10)
                perm = (perm & ~PTE_W) | PTE_COW;
ffffffffc0203de6:	2006e693          	ori	a3,a3,512
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203dea:	12040073          	sfence.vma	s0
}
ffffffffc0203dee:	bfd1                	j	ffffffffc0203dc2 <copy_range+0xda>
        panic("pa2page called with invalid pa");
ffffffffc0203df0:	00002617          	auipc	a2,0x2
ffffffffc0203df4:	4c860613          	addi	a2,a2,1224 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc0203df8:	06b00593          	li	a1,107
ffffffffc0203dfc:	00002517          	auipc	a0,0x2
ffffffffc0203e00:	4dc50513          	addi	a0,a0,1244 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0203e04:	c24fc0ef          	jal	ffffffffc0200228 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203e08:	00003617          	auipc	a2,0x3
ffffffffc0203e0c:	e1860613          	addi	a2,a2,-488 # ffffffffc0206c20 <etext+0x1330>
ffffffffc0203e10:	08100593          	li	a1,129
ffffffffc0203e14:	00002517          	auipc	a0,0x2
ffffffffc0203e18:	4c450513          	addi	a0,a0,1220 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0203e1c:	c0cfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203e20:	00003697          	auipc	a3,0x3
ffffffffc0203e24:	c4868693          	addi	a3,a3,-952 # ffffffffc0206a68 <etext+0x1178>
ffffffffc0203e28:	00002617          	auipc	a2,0x2
ffffffffc0203e2c:	54860613          	addi	a2,a2,1352 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203e30:	18200593          	li	a1,386
ffffffffc0203e34:	00003517          	auipc	a0,0x3
ffffffffc0203e38:	bf450513          	addi	a0,a0,-1036 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203e3c:	becfc0ef          	jal	ffffffffc0200228 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203e40:	00003697          	auipc	a3,0x3
ffffffffc0203e44:	bf868693          	addi	a3,a3,-1032 # ffffffffc0206a38 <etext+0x1148>
ffffffffc0203e48:	00002617          	auipc	a2,0x2
ffffffffc0203e4c:	52860613          	addi	a2,a2,1320 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203e50:	18100593          	li	a1,385
ffffffffc0203e54:	00003517          	auipc	a0,0x3
ffffffffc0203e58:	bd450513          	addi	a0,a0,-1068 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203e5c:	bccfc0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0203e60 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203e60:	12058073          	sfence.vma	a1
}
ffffffffc0203e64:	8082                	ret

ffffffffc0203e66 <pgdir_alloc_page>:
{
ffffffffc0203e66:	7139                	addi	sp,sp,-64
ffffffffc0203e68:	f426                	sd	s1,40(sp)
ffffffffc0203e6a:	f04a                	sd	s2,32(sp)
ffffffffc0203e6c:	ec4e                	sd	s3,24(sp)
ffffffffc0203e6e:	fc06                	sd	ra,56(sp)
ffffffffc0203e70:	f822                	sd	s0,48(sp)
ffffffffc0203e72:	892a                	mv	s2,a0
ffffffffc0203e74:	84ae                	mv	s1,a1
ffffffffc0203e76:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0203e78:	100027f3          	csrr	a5,sstatus
ffffffffc0203e7c:	8b89                	andi	a5,a5,2
ffffffffc0203e7e:	ebb5                	bnez	a5,ffffffffc0203ef2 <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc0203e80:	000a3417          	auipc	s0,0xa3
ffffffffc0203e84:	68840413          	addi	s0,s0,1672 # ffffffffc02a7508 <pmm_manager>
ffffffffc0203e88:	601c                	ld	a5,0(s0)
ffffffffc0203e8a:	4505                	li	a0,1
ffffffffc0203e8c:	6f9c                	ld	a5,24(a5)
ffffffffc0203e8e:	9782                	jalr	a5
ffffffffc0203e90:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc0203e92:	c5b9                	beqz	a1,ffffffffc0203ee0 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203e94:	86ce                	mv	a3,s3
ffffffffc0203e96:	854a                	mv	a0,s2
ffffffffc0203e98:	8626                	mv	a2,s1
ffffffffc0203e9a:	e42e                	sd	a1,8(sp)
ffffffffc0203e9c:	90cff0ef          	jal	ffffffffc0202fa8 <page_insert>
ffffffffc0203ea0:	65a2                	ld	a1,8(sp)
ffffffffc0203ea2:	e515                	bnez	a0,ffffffffc0203ece <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc0203ea4:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc0203ea6:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc0203ea8:	4785                	li	a5,1
ffffffffc0203eaa:	02f70c63          	beq	a4,a5,ffffffffc0203ee2 <pgdir_alloc_page+0x7c>
ffffffffc0203eae:	00003697          	auipc	a3,0x3
ffffffffc0203eb2:	19268693          	addi	a3,a3,402 # ffffffffc0207040 <etext+0x1750>
ffffffffc0203eb6:	00002617          	auipc	a2,0x2
ffffffffc0203eba:	4ba60613          	addi	a2,a2,1210 # ffffffffc0206370 <etext+0xa80>
ffffffffc0203ebe:	1e800593          	li	a1,488
ffffffffc0203ec2:	00003517          	auipc	a0,0x3
ffffffffc0203ec6:	b6650513          	addi	a0,a0,-1178 # ffffffffc0206a28 <etext+0x1138>
ffffffffc0203eca:	b5efc0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc0203ece:	100027f3          	csrr	a5,sstatus
ffffffffc0203ed2:	8b89                	andi	a5,a5,2
ffffffffc0203ed4:	ef95                	bnez	a5,ffffffffc0203f10 <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0203ed6:	601c                	ld	a5,0(s0)
ffffffffc0203ed8:	852e                	mv	a0,a1
ffffffffc0203eda:	4585                	li	a1,1
ffffffffc0203edc:	739c                	ld	a5,32(a5)
ffffffffc0203ede:	9782                	jalr	a5
            return NULL;
ffffffffc0203ee0:	4581                	li	a1,0
}
ffffffffc0203ee2:	70e2                	ld	ra,56(sp)
ffffffffc0203ee4:	7442                	ld	s0,48(sp)
ffffffffc0203ee6:	74a2                	ld	s1,40(sp)
ffffffffc0203ee8:	7902                	ld	s2,32(sp)
ffffffffc0203eea:	69e2                	ld	s3,24(sp)
ffffffffc0203eec:	852e                	mv	a0,a1
ffffffffc0203eee:	6121                	addi	sp,sp,64
ffffffffc0203ef0:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc0203ef2:	a19fc0ef          	jal	ffffffffc020090a <intr_disable>
        page = pmm_manager->alloc_pages(n);  // 调用具体分配算法
ffffffffc0203ef6:	000a3417          	auipc	s0,0xa3
ffffffffc0203efa:	61240413          	addi	s0,s0,1554 # ffffffffc02a7508 <pmm_manager>
ffffffffc0203efe:	601c                	ld	a5,0(s0)
ffffffffc0203f00:	4505                	li	a0,1
ffffffffc0203f02:	6f9c                	ld	a5,24(a5)
ffffffffc0203f04:	9782                	jalr	a5
ffffffffc0203f06:	e42a                	sd	a0,8(sp)
        intr_enable();  // 重新开启中断
ffffffffc0203f08:	9fdfc0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203f0c:	65a2                	ld	a1,8(sp)
ffffffffc0203f0e:	b751                	j	ffffffffc0203e92 <pgdir_alloc_page+0x2c>
        intr_disable();  // 关闭中断
ffffffffc0203f10:	9fbfc0ef          	jal	ffffffffc020090a <intr_disable>
        pmm_manager->free_pages(base, n);  // 调用具体释放算法
ffffffffc0203f14:	601c                	ld	a5,0(s0)
ffffffffc0203f16:	6522                	ld	a0,8(sp)
ffffffffc0203f18:	4585                	li	a1,1
ffffffffc0203f1a:	739c                	ld	a5,32(a5)
ffffffffc0203f1c:	9782                	jalr	a5
        intr_enable();  // 重新开启中断
ffffffffc0203f1e:	9e7fc0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc0203f22:	bf7d                	j	ffffffffc0203ee0 <pgdir_alloc_page+0x7a>

ffffffffc0203f24 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203f24:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203f26:	9402                	jalr	s0

	jal do_exit
ffffffffc0203f28:	69c000ef          	jal	ffffffffc02045c4 <do_exit>

ffffffffc0203f2c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0203f2c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0203f30:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0203f34:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0203f36:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0203f38:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0203f3c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0203f40:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0203f44:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0203f48:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0203f4c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0203f50:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0203f54:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0203f58:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0203f5c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0203f60:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0203f64:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0203f68:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0203f6a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0203f6c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0203f70:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0203f74:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0203f78:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0203f7c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0203f80:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0203f84:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0203f88:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0203f8c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0203f90:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0203f94:	8082                	ret

ffffffffc0203f96 <alloc_proc>:
// alloc_proc - 分配并初始化进程控制块结构体
// 为新进程分配内存空间并初始化所有必要的字段
// 返回值: 成功返回指向新进程控制块的指针，失败返回NULL
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203f96:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203f98:	10800513          	li	a0,264
{
ffffffffc0203f9c:	e022                	sd	s0,0(sp)
ffffffffc0203f9e:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fa0:	b7ffd0ef          	jal	ffffffffc0201b1e <kmalloc>
ffffffffc0203fa4:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203fa6:	cd21                	beqz	a0,ffffffffc0203ffe <alloc_proc+0x68>
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */

        proc->state = PROC_UNINIT;
ffffffffc0203fa8:	57fd                	li	a5,-1
ffffffffc0203faa:	1782                	slli	a5,a5,0x20
ffffffffc0203fac:	e11c                	sd	a5,0(a0)
        proc->pid = -1;
        proc->runs = 0;
ffffffffc0203fae:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203fb2:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203fb6:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203fba:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0203fbe:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203fc2:	07000613          	li	a2,112
ffffffffc0203fc6:	4581                	li	a1,0
ffffffffc0203fc8:	03050513          	addi	a0,a0,48
ffffffffc0203fcc:	518010ef          	jal	ffffffffc02054e4 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fd0:	000a3797          	auipc	a5,0xa3
ffffffffc0203fd4:	5407b783          	ld	a5,1344(a5) # ffffffffc02a7510 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203fd8:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203fdc:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fe0:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203fe2:	0b440513          	addi	a0,s0,180
ffffffffc0203fe6:	4641                	li	a2,16
ffffffffc0203fe8:	4581                	li	a1,0
ffffffffc0203fea:	4fa010ef          	jal	ffffffffc02054e4 <memset>
        proc->wait_state = 0;
ffffffffc0203fee:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->yptr = proc->optr = NULL;
ffffffffc0203ff2:	10043023          	sd	zero,256(s0)
ffffffffc0203ff6:	0e043c23          	sd	zero,248(s0)
ffffffffc0203ffa:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc0203ffe:	60a2                	ld	ra,8(sp)
ffffffffc0204000:	8522                	mv	a0,s0
ffffffffc0204002:	6402                	ld	s0,0(sp)
ffffffffc0204004:	0141                	addi	sp,sp,16
ffffffffc0204006:	8082                	ret

ffffffffc0204008 <forkret>:
// 注意: forkret的地址在copy_thread函数中设置
//       switch_to执行后，当前进程将从这里开始执行
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204008:	000a3797          	auipc	a5,0xa3
ffffffffc020400c:	5387b783          	ld	a5,1336(a5) # ffffffffc02a7540 <current>
ffffffffc0204010:	73c8                	ld	a0,160(a5)
ffffffffc0204012:	888fd06f          	j	ffffffffc020109a <forkrets>

ffffffffc0204016 <user_main>:
// 返回值: 正常情况下不会返回，失败时会调用panic
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204016:	000a3797          	auipc	a5,0xa3
ffffffffc020401a:	52a7b783          	ld	a5,1322(a5) # ffffffffc02a7540 <current>
{
ffffffffc020401e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204020:	00003617          	auipc	a2,0x3
ffffffffc0204024:	03860613          	addi	a2,a2,56 # ffffffffc0207058 <etext+0x1768>
ffffffffc0204028:	43cc                	lw	a1,4(a5)
ffffffffc020402a:	00003517          	auipc	a0,0x3
ffffffffc020402e:	03650513          	addi	a0,a0,54 # ffffffffc0207060 <etext+0x1770>
{
ffffffffc0204032:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204034:	8aafc0ef          	jal	ffffffffc02000de <cprintf>
ffffffffc0204038:	3fe08797          	auipc	a5,0x3fe08
ffffffffc020403c:	1c078793          	addi	a5,a5,448 # c1f8 <_binary_obj___user_cowtest_out_size>
ffffffffc0204040:	e43e                	sd	a5,8(sp)
kernel_execve(const char *name, unsigned char *binary, size_t size)
ffffffffc0204042:	00003517          	auipc	a0,0x3
ffffffffc0204046:	01650513          	addi	a0,a0,22 # ffffffffc0207058 <etext+0x1768>
ffffffffc020404a:	00080797          	auipc	a5,0x80
ffffffffc020404e:	71678793          	addi	a5,a5,1814 # ffffffffc0284760 <_binary_obj___user_cowtest_out_start>
ffffffffc0204052:	f03e                	sd	a5,32(sp)
ffffffffc0204054:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204056:	e802                	sd	zero,16(sp)
ffffffffc0204058:	3d8010ef          	jal	ffffffffc0205430 <strlen>
ffffffffc020405c:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020405e:	4511                	li	a0,4
ffffffffc0204060:	55a2                	lw	a1,40(sp)
ffffffffc0204062:	4662                	lw	a2,24(sp)
ffffffffc0204064:	5682                	lw	a3,32(sp)
ffffffffc0204066:	4722                	lw	a4,8(sp)
ffffffffc0204068:	48a9                	li	a7,10
ffffffffc020406a:	9002                	ebreak
ffffffffc020406c:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020406e:	65c2                	ld	a1,16(sp)
ffffffffc0204070:	00003517          	auipc	a0,0x3
ffffffffc0204074:	01850513          	addi	a0,a0,24 # ffffffffc0207088 <etext+0x1798>
ffffffffc0204078:	866fc0ef          	jal	ffffffffc02000de <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc020407c:	00003617          	auipc	a2,0x3
ffffffffc0204080:	01c60613          	addi	a2,a2,28 # ffffffffc0207098 <etext+0x17a8>
ffffffffc0204084:	46000593          	li	a1,1120
ffffffffc0204088:	00003517          	auipc	a0,0x3
ffffffffc020408c:	03050513          	addi	a0,a0,48 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204090:	998fc0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0204094 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204094:	6d14                	ld	a3,24(a0)
{
ffffffffc0204096:	1141                	addi	sp,sp,-16
ffffffffc0204098:	e406                	sd	ra,8(sp)
ffffffffc020409a:	c02007b7          	lui	a5,0xc0200
ffffffffc020409e:	02f6ee63          	bltu	a3,a5,ffffffffc02040da <put_pgdir+0x46>
ffffffffc02040a2:	000a3717          	auipc	a4,0xa3
ffffffffc02040a6:	47e73703          	ld	a4,1150(a4) # ffffffffc02a7520 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02040aa:	000a3797          	auipc	a5,0xa3
ffffffffc02040ae:	47e7b783          	ld	a5,1150(a5) # ffffffffc02a7528 <npage>
    return pa2page(PADDR(kva));
ffffffffc02040b2:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02040b4:	82b1                	srli	a3,a3,0xc
ffffffffc02040b6:	02f6fe63          	bgeu	a3,a5,ffffffffc02040f2 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02040ba:	00004797          	auipc	a5,0x4
ffffffffc02040be:	9867b783          	ld	a5,-1658(a5) # ffffffffc0207a40 <nbase>
ffffffffc02040c2:	000a3517          	auipc	a0,0xa3
ffffffffc02040c6:	46e53503          	ld	a0,1134(a0) # ffffffffc02a7530 <pages>
}
ffffffffc02040ca:	60a2                	ld	ra,8(sp)
ffffffffc02040cc:	8e9d                	sub	a3,a3,a5
ffffffffc02040ce:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02040d0:	4585                	li	a1,1
ffffffffc02040d2:	9536                	add	a0,a0,a3
}
ffffffffc02040d4:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02040d6:	f2efe06f          	j	ffffffffc0202804 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02040da:	00002617          	auipc	a2,0x2
ffffffffc02040de:	57e60613          	addi	a2,a2,1406 # ffffffffc0206658 <etext+0xd68>
ffffffffc02040e2:	07900593          	li	a1,121
ffffffffc02040e6:	00002517          	auipc	a0,0x2
ffffffffc02040ea:	1f250513          	addi	a0,a0,498 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc02040ee:	93afc0ef          	jal	ffffffffc0200228 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02040f2:	00002617          	auipc	a2,0x2
ffffffffc02040f6:	1c660613          	addi	a2,a2,454 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc02040fa:	06b00593          	li	a1,107
ffffffffc02040fe:	00002517          	auipc	a0,0x2
ffffffffc0204102:	1da50513          	addi	a0,a0,474 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0204106:	922fc0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc020410a <proc_run>:
    if (proc != current)
ffffffffc020410a:	000a3697          	auipc	a3,0xa3
ffffffffc020410e:	4366b683          	ld	a3,1078(a3) # ffffffffc02a7540 <current>
ffffffffc0204112:	04a68663          	beq	a3,a0,ffffffffc020415e <proc_run+0x54>
{
ffffffffc0204116:	1101                	addi	sp,sp,-32
ffffffffc0204118:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020411a:	100027f3          	csrr	a5,sstatus
ffffffffc020411e:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc0204120:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0204122:	ef9d                	bnez	a5,ffffffffc0204160 <proc_run+0x56>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204124:	755c                	ld	a5,168(a0)
ffffffffc0204126:	577d                	li	a4,-1
ffffffffc0204128:	177e                	slli	a4,a4,0x3f
ffffffffc020412a:	83b1                	srli	a5,a5,0xc
ffffffffc020412c:	e032                	sd	a2,0(sp)
            current = proc;
ffffffffc020412e:	000a3597          	auipc	a1,0xa3
ffffffffc0204132:	40a5b923          	sd	a0,1042(a1) # ffffffffc02a7540 <current>
ffffffffc0204136:	8fd9                	or	a5,a5,a4
ffffffffc0204138:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma" ::: "memory");
ffffffffc020413c:	12000073          	sfence.vma
            switch_to(&(prev->context), &(proc->context));
ffffffffc0204140:	03050593          	addi	a1,a0,48
ffffffffc0204144:	03068513          	addi	a0,a3,48
ffffffffc0204148:	de5ff0ef          	jal	ffffffffc0203f2c <switch_to>
    if (flag)           // 如果原来中断是开启的
ffffffffc020414c:	6602                	ld	a2,0(sp)
ffffffffc020414e:	e601                	bnez	a2,ffffffffc0204156 <proc_run+0x4c>
}
ffffffffc0204150:	60e2                	ld	ra,24(sp)
ffffffffc0204152:	6105                	addi	sp,sp,32
ffffffffc0204154:	8082                	ret
ffffffffc0204156:	60e2                	ld	ra,24(sp)
ffffffffc0204158:	6105                	addi	sp,sp,32
        intr_enable();  // 重新开启中断
ffffffffc020415a:	faafc06f          	j	ffffffffc0200904 <intr_enable>
ffffffffc020415e:	8082                	ret
ffffffffc0204160:	e42a                	sd	a0,8(sp)
ffffffffc0204162:	e036                	sd	a3,0(sp)
        intr_disable();  // 关闭中断
ffffffffc0204164:	fa6fc0ef          	jal	ffffffffc020090a <intr_disable>
        return 1;        // 返回原状态：开启
ffffffffc0204168:	6522                	ld	a0,8(sp)
ffffffffc020416a:	6682                	ld	a3,0(sp)
ffffffffc020416c:	4605                	li	a2,1
ffffffffc020416e:	bf5d                	j	ffffffffc0204124 <proc_run+0x1a>

ffffffffc0204170 <do_fork>:
    if (nr_process >= MAX_PROCESS)
ffffffffc0204170:	000a3797          	auipc	a5,0xa3
ffffffffc0204174:	3c87a783          	lw	a5,968(a5) # ffffffffc02a7538 <nr_process>
{
ffffffffc0204178:	7159                	addi	sp,sp,-112
ffffffffc020417a:	e4ce                	sd	s3,72(sp)
ffffffffc020417c:	f486                	sd	ra,104(sp)
    if (nr_process >= MAX_PROCESS)
ffffffffc020417e:	6985                	lui	s3,0x1
ffffffffc0204180:	3737db63          	bge	a5,s3,ffffffffc02044f6 <do_fork+0x386>
ffffffffc0204184:	f0a2                	sd	s0,96(sp)
ffffffffc0204186:	eca6                	sd	s1,88(sp)
ffffffffc0204188:	e8ca                	sd	s2,80(sp)
ffffffffc020418a:	e86a                	sd	s10,16(sp)
ffffffffc020418c:	892e                	mv	s2,a1
ffffffffc020418e:	84b2                	mv	s1,a2
ffffffffc0204190:	8d2a                	mv	s10,a0
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204192:	e05ff0ef          	jal	ffffffffc0203f96 <alloc_proc>
ffffffffc0204196:	842a                	mv	s0,a0
ffffffffc0204198:	2e050c63          	beqz	a0,ffffffffc0204490 <do_fork+0x320>
ffffffffc020419c:	f45e                	sd	s7,40(sp)
    proc->parent = current;
ffffffffc020419e:	000a3b97          	auipc	s7,0xa3
ffffffffc02041a2:	3a2b8b93          	addi	s7,s7,930 # ffffffffc02a7540 <current>
ffffffffc02041a6:	000bb783          	ld	a5,0(s7)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041aa:	4509                	li	a0,2
    proc->parent = current;
ffffffffc02041ac:	f01c                	sd	a5,32(s0)
    current->wait_state = 0;
ffffffffc02041ae:	0e07a623          	sw	zero,236(a5)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041b2:	e18fe0ef          	jal	ffffffffc02027ca <alloc_pages>
    if (page != NULL)
ffffffffc02041b6:	2c050963          	beqz	a0,ffffffffc0204488 <do_fork+0x318>
ffffffffc02041ba:	e0d2                	sd	s4,64(sp)
    return page - pages + nbase;
ffffffffc02041bc:	000a3a17          	auipc	s4,0xa3
ffffffffc02041c0:	374a0a13          	addi	s4,s4,884 # ffffffffc02a7530 <pages>
ffffffffc02041c4:	000a3783          	ld	a5,0(s4)
ffffffffc02041c8:	fc56                	sd	s5,56(sp)
ffffffffc02041ca:	00004a97          	auipc	s5,0x4
ffffffffc02041ce:	876a8a93          	addi	s5,s5,-1930 # ffffffffc0207a40 <nbase>
ffffffffc02041d2:	000ab703          	ld	a4,0(s5)
ffffffffc02041d6:	40f506b3          	sub	a3,a0,a5
ffffffffc02041da:	f85a                	sd	s6,48(sp)
    return KADDR(page2pa(page));
ffffffffc02041dc:	000a3b17          	auipc	s6,0xa3
ffffffffc02041e0:	34cb0b13          	addi	s6,s6,844 # ffffffffc02a7528 <npage>
ffffffffc02041e4:	ec66                	sd	s9,24(sp)
    return page - pages + nbase;
ffffffffc02041e6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02041e8:	5cfd                	li	s9,-1
ffffffffc02041ea:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc02041ee:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02041f0:	00ccdc93          	srli	s9,s9,0xc
ffffffffc02041f4:	0196f633          	and	a2,a3,s9
ffffffffc02041f8:	f062                	sd	s8,32(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02041fa:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02041fc:	32f67763          	bgeu	a2,a5,ffffffffc020452a <do_fork+0x3ba>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204200:	000bb603          	ld	a2,0(s7)
ffffffffc0204204:	000a3b97          	auipc	s7,0xa3
ffffffffc0204208:	31cb8b93          	addi	s7,s7,796 # ffffffffc02a7520 <va_pa_offset>
ffffffffc020420c:	000bb783          	ld	a5,0(s7)
ffffffffc0204210:	02863c03          	ld	s8,40(a2)
ffffffffc0204214:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204216:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0204218:	020c0863          	beqz	s8,ffffffffc0204248 <do_fork+0xd8>
    if (clone_flags & CLONE_VM)
ffffffffc020421c:	100d7793          	andi	a5,s10,256
ffffffffc0204220:	18078863          	beqz	a5,ffffffffc02043b0 <do_fork+0x240>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204224:	030c2703          	lw	a4,48(s8) # 200030 <_binary_obj___user_cowtest_out_size+0x1f3e38>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204228:	018c3783          	ld	a5,24(s8)
ffffffffc020422c:	c02006b7          	lui	a3,0xc0200
ffffffffc0204230:	2705                	addiw	a4,a4,1
ffffffffc0204232:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0204236:	03843423          	sd	s8,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020423a:	30d7e463          	bltu	a5,a3,ffffffffc0204542 <do_fork+0x3d2>
ffffffffc020423e:	000bb703          	ld	a4,0(s7)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204242:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204244:	8f99                	sub	a5,a5,a4
ffffffffc0204246:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204248:	6789                	lui	a5,0x2
ffffffffc020424a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6d28>
ffffffffc020424e:	96be                	add	a3,a3,a5
ffffffffc0204250:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204252:	87b6                	mv	a5,a3
ffffffffc0204254:	12048713          	addi	a4,s1,288
ffffffffc0204258:	6890                	ld	a2,16(s1)
ffffffffc020425a:	6088                	ld	a0,0(s1)
ffffffffc020425c:	648c                	ld	a1,8(s1)
ffffffffc020425e:	eb90                	sd	a2,16(a5)
ffffffffc0204260:	e388                	sd	a0,0(a5)
ffffffffc0204262:	e78c                	sd	a1,8(a5)
ffffffffc0204264:	6c90                	ld	a2,24(s1)
ffffffffc0204266:	02048493          	addi	s1,s1,32
ffffffffc020426a:	02078793          	addi	a5,a5,32
ffffffffc020426e:	fec7bc23          	sd	a2,-8(a5)
ffffffffc0204272:	fee493e3          	bne	s1,a4,ffffffffc0204258 <do_fork+0xe8>
    proc->tf->gpr.a0 = 0;
ffffffffc0204276:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020427a:	22090163          	beqz	s2,ffffffffc020449c <do_fork+0x32c>
ffffffffc020427e:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204282:	00000797          	auipc	a5,0x0
ffffffffc0204286:	d8678793          	addi	a5,a5,-634 # ffffffffc0204008 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020428a:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020428c:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020428e:	100027f3          	csrr	a5,sstatus
ffffffffc0204292:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc0204294:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0204296:	22079263          	bnez	a5,ffffffffc02044ba <do_fork+0x34a>
    if (++last_pid >= MAX_PID)
ffffffffc020429a:	0009f517          	auipc	a0,0x9f
ffffffffc020429e:	e0a52503          	lw	a0,-502(a0) # ffffffffc02a30a4 <last_pid.1>
ffffffffc02042a2:	6789                	lui	a5,0x2
ffffffffc02042a4:	2505                	addiw	a0,a0,1
ffffffffc02042a6:	0009f717          	auipc	a4,0x9f
ffffffffc02042aa:	dea72f23          	sw	a0,-514(a4) # ffffffffc02a30a4 <last_pid.1>
ffffffffc02042ae:	22f55563          	bge	a0,a5,ffffffffc02044d8 <do_fork+0x368>
    if (last_pid >= next_safe)
ffffffffc02042b2:	0009f797          	auipc	a5,0x9f
ffffffffc02042b6:	dee7a783          	lw	a5,-530(a5) # ffffffffc02a30a0 <next_safe.0>
ffffffffc02042ba:	000a3497          	auipc	s1,0xa3
ffffffffc02042be:	20648493          	addi	s1,s1,518 # ffffffffc02a74c0 <proc_list>
ffffffffc02042c2:	06f54563          	blt	a0,a5,ffffffffc020432c <do_fork+0x1bc>
    return listelm->next;
ffffffffc02042c6:	000a3497          	auipc	s1,0xa3
ffffffffc02042ca:	1fa48493          	addi	s1,s1,506 # ffffffffc02a74c0 <proc_list>
ffffffffc02042ce:	0084b883          	ld	a7,8(s1)
        next_safe = MAX_PID;
ffffffffc02042d2:	6789                	lui	a5,0x2
ffffffffc02042d4:	0009f717          	auipc	a4,0x9f
ffffffffc02042d8:	dcf72623          	sw	a5,-564(a4) # ffffffffc02a30a0 <next_safe.0>
ffffffffc02042dc:	86aa                	mv	a3,a0
ffffffffc02042de:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02042e0:	04988063          	beq	a7,s1,ffffffffc0204320 <do_fork+0x1b0>
ffffffffc02042e4:	882e                	mv	a6,a1
ffffffffc02042e6:	87c6                	mv	a5,a7
ffffffffc02042e8:	6609                	lui	a2,0x2
ffffffffc02042ea:	a811                	j	ffffffffc02042fe <do_fork+0x18e>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042ec:	00e6d663          	bge	a3,a4,ffffffffc02042f8 <do_fork+0x188>
ffffffffc02042f0:	00c75463          	bge	a4,a2,ffffffffc02042f8 <do_fork+0x188>
                next_safe = proc->pid;
ffffffffc02042f4:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02042f6:	4805                	li	a6,1
ffffffffc02042f8:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02042fa:	00978d63          	beq	a5,s1,ffffffffc0204314 <do_fork+0x1a4>
            if (proc->pid == last_pid)
ffffffffc02042fe:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x6ccc>
ffffffffc0204302:	fed715e3          	bne	a4,a3,ffffffffc02042ec <do_fork+0x17c>
                if (++last_pid >= next_safe)
ffffffffc0204306:	2685                	addiw	a3,a3,1
ffffffffc0204308:	1ec6d163          	bge	a3,a2,ffffffffc02044ea <do_fork+0x37a>
ffffffffc020430c:	679c                	ld	a5,8(a5)
ffffffffc020430e:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204310:	fe9797e3          	bne	a5,s1,ffffffffc02042fe <do_fork+0x18e>
ffffffffc0204314:	00080663          	beqz	a6,ffffffffc0204320 <do_fork+0x1b0>
ffffffffc0204318:	0009f797          	auipc	a5,0x9f
ffffffffc020431c:	d8c7a423          	sw	a2,-632(a5) # ffffffffc02a30a0 <next_safe.0>
ffffffffc0204320:	c591                	beqz	a1,ffffffffc020432c <do_fork+0x1bc>
ffffffffc0204322:	0009f797          	auipc	a5,0x9f
ffffffffc0204326:	d8d7a123          	sw	a3,-638(a5) # ffffffffc02a30a4 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020432a:	8536                	mv	a0,a3
        proc->pid = get_pid();
ffffffffc020432c:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020432e:	45a9                	li	a1,10
ffffffffc0204330:	5aa010ef          	jal	ffffffffc02058da <hash32>
ffffffffc0204334:	02051793          	slli	a5,a0,0x20
ffffffffc0204338:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020433c:	0009f797          	auipc	a5,0x9f
ffffffffc0204340:	18478793          	addi	a5,a5,388 # ffffffffc02a34c0 <hash_list>
ffffffffc0204344:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204346:	6518                	ld	a4,8(a0)
ffffffffc0204348:	0d840793          	addi	a5,s0,216
ffffffffc020434c:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc020434e:	e31c                	sd	a5,0(a4)
ffffffffc0204350:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204352:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204354:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204358:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc020435a:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020435c:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc020435e:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204362:	7b74                	ld	a3,240(a4)
ffffffffc0204364:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc0204366:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204368:	e464                	sd	s1,200(s0)
ffffffffc020436a:	10d43023          	sd	a3,256(s0)
ffffffffc020436e:	c299                	beqz	a3,ffffffffc0204374 <do_fork+0x204>
        proc->optr->yptr = proc;
ffffffffc0204370:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc0204372:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc0204374:	000a3797          	auipc	a5,0xa3
ffffffffc0204378:	1c47a783          	lw	a5,452(a5) # ffffffffc02a7538 <nr_process>
    proc->parent->cptr = proc;
ffffffffc020437c:	fb60                	sd	s0,240(a4)
    nr_process++;
ffffffffc020437e:	2785                	addiw	a5,a5,1
ffffffffc0204380:	000a3717          	auipc	a4,0xa3
ffffffffc0204384:	1af72c23          	sw	a5,440(a4) # ffffffffc02a7538 <nr_process>
    if (flag)           // 如果原来中断是开启的
ffffffffc0204388:	14091e63          	bnez	s2,ffffffffc02044e4 <do_fork+0x374>
    wakeup_proc(proc);
ffffffffc020438c:	8522                	mv	a0,s0
ffffffffc020438e:	6a7000ef          	jal	ffffffffc0205234 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204392:	4048                	lw	a0,4(s0)
ffffffffc0204394:	64e6                	ld	s1,88(sp)
ffffffffc0204396:	7406                	ld	s0,96(sp)
ffffffffc0204398:	6946                	ld	s2,80(sp)
ffffffffc020439a:	6a06                	ld	s4,64(sp)
ffffffffc020439c:	7ae2                	ld	s5,56(sp)
ffffffffc020439e:	7b42                	ld	s6,48(sp)
ffffffffc02043a0:	7ba2                	ld	s7,40(sp)
ffffffffc02043a2:	7c02                	ld	s8,32(sp)
ffffffffc02043a4:	6ce2                	ld	s9,24(sp)
ffffffffc02043a6:	6d42                	ld	s10,16(sp)
}
ffffffffc02043a8:	70a6                	ld	ra,104(sp)
ffffffffc02043aa:	69a6                	ld	s3,72(sp)
ffffffffc02043ac:	6165                	addi	sp,sp,112
ffffffffc02043ae:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc02043b0:	e43a                	sd	a4,8(sp)
ffffffffc02043b2:	db9fc0ef          	jal	ffffffffc020116a <mm_create>
ffffffffc02043b6:	8d2a                	mv	s10,a0
ffffffffc02043b8:	c959                	beqz	a0,ffffffffc020444e <do_fork+0x2de>
    if ((page = alloc_page()) == NULL)
ffffffffc02043ba:	4505                	li	a0,1
ffffffffc02043bc:	c0efe0ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc02043c0:	c541                	beqz	a0,ffffffffc0204448 <do_fork+0x2d8>
    return page - pages + nbase;
ffffffffc02043c2:	000a3683          	ld	a3,0(s4)
ffffffffc02043c6:	6722                	ld	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc02043c8:	000b3783          	ld	a5,0(s6)
    return page - pages + nbase;
ffffffffc02043cc:	40d506b3          	sub	a3,a0,a3
ffffffffc02043d0:	8699                	srai	a3,a3,0x6
ffffffffc02043d2:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02043d4:	0196fcb3          	and	s9,a3,s9
    return page2ppn(page) << PGSHIFT;
ffffffffc02043d8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043da:	14fcf863          	bgeu	s9,a5,ffffffffc020452a <do_fork+0x3ba>
ffffffffc02043de:	000bb783          	ld	a5,0(s7)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02043e2:	000a3597          	auipc	a1,0xa3
ffffffffc02043e6:	1365b583          	ld	a1,310(a1) # ffffffffc02a7518 <boot_pgdir_va>
ffffffffc02043ea:	864e                	mv	a2,s3
ffffffffc02043ec:	00f689b3          	add	s3,a3,a5
ffffffffc02043f0:	854e                	mv	a0,s3
ffffffffc02043f2:	104010ef          	jal	ffffffffc02054f6 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02043f6:	038c0c93          	addi	s9,s8,56
    mm->pgdir = pgdir;
ffffffffc02043fa:	013d3c23          	sd	s3,24(s10)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02043fe:	4785                	li	a5,1
ffffffffc0204400:	40fcb7af          	amoor.d	a5,a5,(s9)

// lock - 获取自旋锁，忙等待直到获取成功
static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))  // 循环尝试获取锁
ffffffffc0204404:	03f79713          	slli	a4,a5,0x3f
ffffffffc0204408:	03f75793          	srli	a5,a4,0x3f
ffffffffc020440c:	4985                	li	s3,1
ffffffffc020440e:	cb91                	beqz	a5,ffffffffc0204422 <do_fork+0x2b2>
    {
        schedule();           // 获取失败时让出CPU
ffffffffc0204410:	6b9000ef          	jal	ffffffffc02052c8 <schedule>
ffffffffc0204414:	413cb7af          	amoor.d	a5,s3,(s9)
    while (!try_lock(lock))  // 循环尝试获取锁
ffffffffc0204418:	03f79713          	slli	a4,a5,0x3f
ffffffffc020441c:	03f75793          	srli	a5,a4,0x3f
ffffffffc0204420:	fbe5                	bnez	a5,ffffffffc0204410 <do_fork+0x2a0>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204422:	85e2                	mv	a1,s8
ffffffffc0204424:	856a                	mv	a0,s10
ffffffffc0204426:	fa1fc0ef          	jal	ffffffffc02013c6 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020442a:	57f9                	li	a5,-2
ffffffffc020442c:	60fcb7af          	amoand.d	a5,a5,(s9)
ffffffffc0204430:	8b85                	andi	a5,a5,1

// unlock - 释放自旋锁
static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))  // 原子清除位并返回原值
ffffffffc0204432:	12078563          	beqz	a5,ffffffffc020455c <do_fork+0x3ec>
    if ((mm = mm_create()) == NULL)
ffffffffc0204436:	8c6a                	mv	s8,s10
    if (ret != 0)
ffffffffc0204438:	de0506e3          	beqz	a0,ffffffffc0204224 <do_fork+0xb4>
    exit_mmap(mm);
ffffffffc020443c:	856a                	mv	a0,s10
ffffffffc020443e:	820fd0ef          	jal	ffffffffc020145e <exit_mmap>
    put_pgdir(mm);
ffffffffc0204442:	856a                	mv	a0,s10
ffffffffc0204444:	c51ff0ef          	jal	ffffffffc0204094 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204448:	856a                	mv	a0,s10
ffffffffc020444a:	e5ffc0ef          	jal	ffffffffc02012a8 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020444e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204450:	c02007b7          	lui	a5,0xc0200
ffffffffc0204454:	0af6ef63          	bltu	a3,a5,ffffffffc0204512 <do_fork+0x3a2>
ffffffffc0204458:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage)
ffffffffc020445c:	000b3703          	ld	a4,0(s6)
    return pa2page(PADDR(kva));
ffffffffc0204460:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204464:	83b1                	srli	a5,a5,0xc
ffffffffc0204466:	08e7fa63          	bgeu	a5,a4,ffffffffc02044fa <do_fork+0x38a>
    return &pages[PPN(pa) - nbase];
ffffffffc020446a:	000ab703          	ld	a4,0(s5)
ffffffffc020446e:	000a3503          	ld	a0,0(s4)
ffffffffc0204472:	4589                	li	a1,2
ffffffffc0204474:	8f99                	sub	a5,a5,a4
ffffffffc0204476:	079a                	slli	a5,a5,0x6
ffffffffc0204478:	953e                	add	a0,a0,a5
ffffffffc020447a:	b8afe0ef          	jal	ffffffffc0202804 <free_pages>
}
ffffffffc020447e:	6a06                	ld	s4,64(sp)
ffffffffc0204480:	7ae2                	ld	s5,56(sp)
ffffffffc0204482:	7b42                	ld	s6,48(sp)
ffffffffc0204484:	7c02                	ld	s8,32(sp)
ffffffffc0204486:	6ce2                	ld	s9,24(sp)
    kfree(proc);
ffffffffc0204488:	8522                	mv	a0,s0
ffffffffc020448a:	f3afd0ef          	jal	ffffffffc0201bc4 <kfree>
ffffffffc020448e:	7ba2                	ld	s7,40(sp)
ffffffffc0204490:	7406                	ld	s0,96(sp)
ffffffffc0204492:	64e6                	ld	s1,88(sp)
ffffffffc0204494:	6946                	ld	s2,80(sp)
ffffffffc0204496:	6d42                	ld	s10,16(sp)
    ret = -E_NO_MEM;
ffffffffc0204498:	5571                	li	a0,-4
    return ret;
ffffffffc020449a:	b739                	j	ffffffffc02043a8 <do_fork+0x238>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020449c:	8936                	mv	s2,a3
ffffffffc020449e:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044a2:	00000797          	auipc	a5,0x0
ffffffffc02044a6:	b6678793          	addi	a5,a5,-1178 # ffffffffc0204008 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044aa:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044ac:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02044ae:	100027f3          	csrr	a5,sstatus
ffffffffc02044b2:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc02044b4:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02044b6:	de0782e3          	beqz	a5,ffffffffc020429a <do_fork+0x12a>
        intr_disable();  // 关闭中断
ffffffffc02044ba:	c50fc0ef          	jal	ffffffffc020090a <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc02044be:	0009f517          	auipc	a0,0x9f
ffffffffc02044c2:	be652503          	lw	a0,-1050(a0) # ffffffffc02a30a4 <last_pid.1>
ffffffffc02044c6:	6789                	lui	a5,0x2
        return 1;        // 返回原状态：开启
ffffffffc02044c8:	4905                	li	s2,1
ffffffffc02044ca:	2505                	addiw	a0,a0,1
ffffffffc02044cc:	0009f717          	auipc	a4,0x9f
ffffffffc02044d0:	bca72c23          	sw	a0,-1064(a4) # ffffffffc02a30a4 <last_pid.1>
ffffffffc02044d4:	dcf54fe3          	blt	a0,a5,ffffffffc02042b2 <do_fork+0x142>
        last_pid = 1;
ffffffffc02044d8:	4505                	li	a0,1
ffffffffc02044da:	0009f797          	auipc	a5,0x9f
ffffffffc02044de:	bca7a523          	sw	a0,-1078(a5) # ffffffffc02a30a4 <last_pid.1>
        goto inside;
ffffffffc02044e2:	b3d5                	j	ffffffffc02042c6 <do_fork+0x156>
        intr_enable();  // 重新开启中断
ffffffffc02044e4:	c20fc0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc02044e8:	b555                	j	ffffffffc020438c <do_fork+0x21c>
                    if (last_pid >= MAX_PID)
ffffffffc02044ea:	6789                	lui	a5,0x2
ffffffffc02044ec:	00f6c363          	blt	a3,a5,ffffffffc02044f2 <do_fork+0x382>
                        last_pid = 1;
ffffffffc02044f0:	4685                	li	a3,1
                    goto repeat;
ffffffffc02044f2:	4585                	li	a1,1
ffffffffc02044f4:	b3f5                	j	ffffffffc02042e0 <do_fork+0x170>
    int ret = -E_NO_FREE_PROC;
ffffffffc02044f6:	556d                	li	a0,-5
ffffffffc02044f8:	bd45                	j	ffffffffc02043a8 <do_fork+0x238>
        panic("pa2page called with invalid pa");
ffffffffc02044fa:	00002617          	auipc	a2,0x2
ffffffffc02044fe:	dbe60613          	addi	a2,a2,-578 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc0204502:	06b00593          	li	a1,107
ffffffffc0204506:	00002517          	auipc	a0,0x2
ffffffffc020450a:	dd250513          	addi	a0,a0,-558 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc020450e:	d1bfb0ef          	jal	ffffffffc0200228 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204512:	00002617          	auipc	a2,0x2
ffffffffc0204516:	14660613          	addi	a2,a2,326 # ffffffffc0206658 <etext+0xd68>
ffffffffc020451a:	07900593          	li	a1,121
ffffffffc020451e:	00002517          	auipc	a0,0x2
ffffffffc0204522:	dba50513          	addi	a0,a0,-582 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0204526:	d03fb0ef          	jal	ffffffffc0200228 <__panic>
    return KADDR(page2pa(page));
ffffffffc020452a:	00002617          	auipc	a2,0x2
ffffffffc020452e:	dce60613          	addi	a2,a2,-562 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0204532:	07300593          	li	a1,115
ffffffffc0204536:	00002517          	auipc	a0,0x2
ffffffffc020453a:	da250513          	addi	a0,a0,-606 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc020453e:	cebfb0ef          	jal	ffffffffc0200228 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204542:	86be                	mv	a3,a5
ffffffffc0204544:	00002617          	auipc	a2,0x2
ffffffffc0204548:	11460613          	addi	a2,a2,276 # ffffffffc0206658 <etext+0xd68>
ffffffffc020454c:	1c600593          	li	a1,454
ffffffffc0204550:	00003517          	auipc	a0,0x3
ffffffffc0204554:	b6850513          	addi	a0,a0,-1176 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204558:	cd1fb0ef          	jal	ffffffffc0200228 <__panic>
    {
        panic("Unlock failed.\n");     // 解锁失败表示锁状态错误
ffffffffc020455c:	00003617          	auipc	a2,0x3
ffffffffc0204560:	b7460613          	addi	a2,a2,-1164 # ffffffffc02070d0 <etext+0x17e0>
ffffffffc0204564:	04600593          	li	a1,70
ffffffffc0204568:	00003517          	auipc	a0,0x3
ffffffffc020456c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02070e0 <etext+0x17f0>
ffffffffc0204570:	cb9fb0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0204574 <kernel_thread>:
{
ffffffffc0204574:	7129                	addi	sp,sp,-320
ffffffffc0204576:	fa22                	sd	s0,304(sp)
ffffffffc0204578:	f626                	sd	s1,296(sp)
ffffffffc020457a:	f24a                	sd	s2,288(sp)
ffffffffc020457c:	842a                	mv	s0,a0
ffffffffc020457e:	84ae                	mv	s1,a1
ffffffffc0204580:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204582:	850a                	mv	a0,sp
ffffffffc0204584:	12000613          	li	a2,288
ffffffffc0204588:	4581                	li	a1,0
{
ffffffffc020458a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020458c:	759000ef          	jal	ffffffffc02054e4 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204590:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204592:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204594:	100027f3          	csrr	a5,sstatus
ffffffffc0204598:	edd7f793          	andi	a5,a5,-291
ffffffffc020459c:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045a0:	860a                	mv	a2,sp
ffffffffc02045a2:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02045a6:	00000717          	auipc	a4,0x0
ffffffffc02045aa:	97e70713          	addi	a4,a4,-1666 # ffffffffc0203f24 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045ae:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02045b0:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02045b2:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045b4:	bbdff0ef          	jal	ffffffffc0204170 <do_fork>
}
ffffffffc02045b8:	70f2                	ld	ra,312(sp)
ffffffffc02045ba:	7452                	ld	s0,304(sp)
ffffffffc02045bc:	74b2                	ld	s1,296(sp)
ffffffffc02045be:	7912                	ld	s2,288(sp)
ffffffffc02045c0:	6131                	addi	sp,sp,320
ffffffffc02045c2:	8082                	ret

ffffffffc02045c4 <do_exit>:
{
ffffffffc02045c4:	7179                	addi	sp,sp,-48
ffffffffc02045c6:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc02045c8:	000a3417          	auipc	s0,0xa3
ffffffffc02045cc:	f7840413          	addi	s0,s0,-136 # ffffffffc02a7540 <current>
ffffffffc02045d0:	601c                	ld	a5,0(s0)
ffffffffc02045d2:	000a3717          	auipc	a4,0xa3
ffffffffc02045d6:	f7e73703          	ld	a4,-130(a4) # ffffffffc02a7550 <idleproc>
{
ffffffffc02045da:	f406                	sd	ra,40(sp)
ffffffffc02045dc:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc02045de:	0ce78d63          	beq	a5,a4,ffffffffc02046b8 <do_exit+0xf4>
    if (current == initproc)
ffffffffc02045e2:	000a3497          	auipc	s1,0xa3
ffffffffc02045e6:	f6648493          	addi	s1,s1,-154 # ffffffffc02a7548 <initproc>
ffffffffc02045ea:	6098                	ld	a4,0(s1)
ffffffffc02045ec:	e84a                	sd	s2,16(sp)
ffffffffc02045ee:	0ee78c63          	beq	a5,a4,ffffffffc02046e6 <do_exit+0x122>
ffffffffc02045f2:	892a                	mv	s2,a0
    struct mm_struct *mm = current->mm;
ffffffffc02045f4:	7788                	ld	a0,40(a5)
    if (mm != NULL)
ffffffffc02045f6:	c505                	beqz	a0,ffffffffc020461e <do_exit+0x5a>
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc02045f8:	000a3797          	auipc	a5,0xa3
ffffffffc02045fc:	f187b783          	ld	a5,-232(a5) # ffffffffc02a7510 <boot_pgdir_pa>
ffffffffc0204600:	577d                	li	a4,-1
ffffffffc0204602:	177e                	slli	a4,a4,0x3f
ffffffffc0204604:	83b1                	srli	a5,a5,0xc
ffffffffc0204606:	8fd9                	or	a5,a5,a4
ffffffffc0204608:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma" ::: "memory");
ffffffffc020460c:	12000073          	sfence.vma
    mm->mm_count -= 1;
ffffffffc0204610:	591c                	lw	a5,48(a0)
ffffffffc0204612:	37fd                	addiw	a5,a5,-1
ffffffffc0204614:	d91c                	sw	a5,48(a0)
        if (mm_count_dec(mm) == 0)
ffffffffc0204616:	cfd5                	beqz	a5,ffffffffc02046d2 <do_exit+0x10e>
        current->mm = NULL;
ffffffffc0204618:	601c                	ld	a5,0(s0)
ffffffffc020461a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020461e:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc0204620:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204624:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0204626:	100027f3          	csrr	a5,sstatus
ffffffffc020462a:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc020462c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020462e:	ebe1                	bnez	a5,ffffffffc02046fe <do_exit+0x13a>
        proc = current->parent;
ffffffffc0204630:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204632:	800007b7          	lui	a5,0x80000
ffffffffc0204636:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_cowtest_out_size+0xffffffff7fff3e09>
        proc = current->parent;
ffffffffc0204638:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc020463a:	0ec52703          	lw	a4,236(a0)
ffffffffc020463e:	0cf70463          	beq	a4,a5,ffffffffc0204706 <do_exit+0x142>
        while (current->cptr != NULL)
ffffffffc0204642:	6018                	ld	a4,0(s0)
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204644:	800005b7          	lui	a1,0x80000
ffffffffc0204648:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_cowtest_out_size+0xffffffff7fff3e09>
        while (current->cptr != NULL)
ffffffffc020464a:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020464c:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc020464e:	e789                	bnez	a5,ffffffffc0204658 <do_exit+0x94>
ffffffffc0204650:	a83d                	j	ffffffffc020468e <do_exit+0xca>
ffffffffc0204652:	6018                	ld	a4,0(s0)
ffffffffc0204654:	7b7c                	ld	a5,240(a4)
ffffffffc0204656:	cf85                	beqz	a5,ffffffffc020468e <do_exit+0xca>
            current->cptr = proc->optr;
ffffffffc0204658:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc020465c:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020465e:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc0204660:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204664:	7978                	ld	a4,240(a0)
ffffffffc0204666:	10e7b023          	sd	a4,256(a5)
ffffffffc020466a:	c311                	beqz	a4,ffffffffc020466e <do_exit+0xaa>
                initproc->cptr->yptr = proc;
ffffffffc020466c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc020466e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204670:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204672:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204674:	fcc71fe3          	bne	a4,a2,ffffffffc0204652 <do_exit+0x8e>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204678:	0ec52783          	lw	a5,236(a0)
ffffffffc020467c:	fcb79be3          	bne	a5,a1,ffffffffc0204652 <do_exit+0x8e>
                    wakeup_proc(initproc);
ffffffffc0204680:	3b5000ef          	jal	ffffffffc0205234 <wakeup_proc>
ffffffffc0204684:	800005b7          	lui	a1,0x80000
ffffffffc0204688:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_cowtest_out_size+0xffffffff7fff3e09>
ffffffffc020468a:	460d                	li	a2,3
ffffffffc020468c:	b7d9                	j	ffffffffc0204652 <do_exit+0x8e>
    if (flag)           // 如果原来中断是开启的
ffffffffc020468e:	02091263          	bnez	s2,ffffffffc02046b2 <do_exit+0xee>
    schedule();
ffffffffc0204692:	437000ef          	jal	ffffffffc02052c8 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204696:	601c                	ld	a5,0(s0)
ffffffffc0204698:	00003617          	auipc	a2,0x3
ffffffffc020469c:	a8060613          	addi	a2,a2,-1408 # ffffffffc0207118 <etext+0x1828>
ffffffffc02046a0:	28100593          	li	a1,641
ffffffffc02046a4:	43d4                	lw	a3,4(a5)
ffffffffc02046a6:	00003517          	auipc	a0,0x3
ffffffffc02046aa:	a1250513          	addi	a0,a0,-1518 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02046ae:	b7bfb0ef          	jal	ffffffffc0200228 <__panic>
        intr_enable();  // 重新开启中断
ffffffffc02046b2:	a52fc0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc02046b6:	bff1                	j	ffffffffc0204692 <do_exit+0xce>
        panic("idleproc exit.\n");
ffffffffc02046b8:	00003617          	auipc	a2,0x3
ffffffffc02046bc:	a4060613          	addi	a2,a2,-1472 # ffffffffc02070f8 <etext+0x1808>
ffffffffc02046c0:	24d00593          	li	a1,589
ffffffffc02046c4:	00003517          	auipc	a0,0x3
ffffffffc02046c8:	9f450513          	addi	a0,a0,-1548 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02046cc:	e84a                	sd	s2,16(sp)
ffffffffc02046ce:	b5bfb0ef          	jal	ffffffffc0200228 <__panic>
            exit_mmap(mm);
ffffffffc02046d2:	e42a                	sd	a0,8(sp)
ffffffffc02046d4:	d8bfc0ef          	jal	ffffffffc020145e <exit_mmap>
            put_pgdir(mm);
ffffffffc02046d8:	6522                	ld	a0,8(sp)
ffffffffc02046da:	9bbff0ef          	jal	ffffffffc0204094 <put_pgdir>
            mm_destroy(mm);
ffffffffc02046de:	6522                	ld	a0,8(sp)
ffffffffc02046e0:	bc9fc0ef          	jal	ffffffffc02012a8 <mm_destroy>
ffffffffc02046e4:	bf15                	j	ffffffffc0204618 <do_exit+0x54>
        panic("initproc exit.\n");
ffffffffc02046e6:	00003617          	auipc	a2,0x3
ffffffffc02046ea:	a2260613          	addi	a2,a2,-1502 # ffffffffc0207108 <etext+0x1818>
ffffffffc02046ee:	25100593          	li	a1,593
ffffffffc02046f2:	00003517          	auipc	a0,0x3
ffffffffc02046f6:	9c650513          	addi	a0,a0,-1594 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02046fa:	b2ffb0ef          	jal	ffffffffc0200228 <__panic>
        intr_disable();  // 关闭中断
ffffffffc02046fe:	a0cfc0ef          	jal	ffffffffc020090a <intr_disable>
        return 1;        // 返回原状态：开启
ffffffffc0204702:	4905                	li	s2,1
ffffffffc0204704:	b735                	j	ffffffffc0204630 <do_exit+0x6c>
            wakeup_proc(proc);
ffffffffc0204706:	32f000ef          	jal	ffffffffc0205234 <wakeup_proc>
ffffffffc020470a:	bf25                	j	ffffffffc0204642 <do_exit+0x7e>

ffffffffc020470c <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc020470c:	7179                	addi	sp,sp,-48
ffffffffc020470e:	ec26                	sd	s1,24(sp)
ffffffffc0204710:	e84a                	sd	s2,16(sp)
ffffffffc0204712:	e44e                	sd	s3,8(sp)
ffffffffc0204714:	f406                	sd	ra,40(sp)
ffffffffc0204716:	f022                	sd	s0,32(sp)
ffffffffc0204718:	84aa                	mv	s1,a0
ffffffffc020471a:	892e                	mv	s2,a1
ffffffffc020471c:	000a3997          	auipc	s3,0xa3
ffffffffc0204720:	e2498993          	addi	s3,s3,-476 # ffffffffc02a7540 <current>
    if (pid != 0)
ffffffffc0204724:	cd19                	beqz	a0,ffffffffc0204742 <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204726:	6789                	lui	a5,0x2
ffffffffc0204728:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6c0a>
ffffffffc020472a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020472e:	12e7f563          	bgeu	a5,a4,ffffffffc0204858 <do_wait.part.0+0x14c>
}
ffffffffc0204732:	70a2                	ld	ra,40(sp)
ffffffffc0204734:	7402                	ld	s0,32(sp)
ffffffffc0204736:	64e2                	ld	s1,24(sp)
ffffffffc0204738:	6942                	ld	s2,16(sp)
ffffffffc020473a:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc020473c:	5579                	li	a0,-2
}
ffffffffc020473e:	6145                	addi	sp,sp,48
ffffffffc0204740:	8082                	ret
        proc = current->cptr;
ffffffffc0204742:	0009b703          	ld	a4,0(s3)
ffffffffc0204746:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204748:	d46d                	beqz	s0,ffffffffc0204732 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020474a:	468d                	li	a3,3
ffffffffc020474c:	a021                	j	ffffffffc0204754 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020474e:	10043403          	ld	s0,256(s0)
ffffffffc0204752:	c075                	beqz	s0,ffffffffc0204836 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204754:	401c                	lw	a5,0(s0)
ffffffffc0204756:	fed79ce3          	bne	a5,a3,ffffffffc020474e <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc020475a:	000a3797          	auipc	a5,0xa3
ffffffffc020475e:	df67b783          	ld	a5,-522(a5) # ffffffffc02a7550 <idleproc>
ffffffffc0204762:	14878263          	beq	a5,s0,ffffffffc02048a6 <do_wait.part.0+0x19a>
ffffffffc0204766:	000a3797          	auipc	a5,0xa3
ffffffffc020476a:	de27b783          	ld	a5,-542(a5) # ffffffffc02a7548 <initproc>
ffffffffc020476e:	12f40c63          	beq	s0,a5,ffffffffc02048a6 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc0204772:	00090663          	beqz	s2,ffffffffc020477e <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc0204776:	0e842783          	lw	a5,232(s0)
ffffffffc020477a:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc020477e:	100027f3          	csrr	a5,sstatus
ffffffffc0204782:	8b89                	andi	a5,a5,2
    return 0;           // 返回原状态：关闭
ffffffffc0204784:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0204786:	10079963          	bnez	a5,ffffffffc0204898 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020478a:	6c74                	ld	a3,216(s0)
ffffffffc020478c:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc020478e:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc0204792:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204794:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204796:	6474                	ld	a3,200(s0)
ffffffffc0204798:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc020479a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020479c:	e314                	sd	a3,0(a4)
ffffffffc020479e:	c789                	beqz	a5,ffffffffc02047a8 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc02047a0:	7c78                	ld	a4,248(s0)
ffffffffc02047a2:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc02047a4:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc02047a8:	7c78                	ld	a4,248(s0)
ffffffffc02047aa:	c36d                	beqz	a4,ffffffffc020488c <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc02047ac:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc02047b0:	000a3797          	auipc	a5,0xa3
ffffffffc02047b4:	d887a783          	lw	a5,-632(a5) # ffffffffc02a7538 <nr_process>
ffffffffc02047b8:	37fd                	addiw	a5,a5,-1
ffffffffc02047ba:	000a3717          	auipc	a4,0xa3
ffffffffc02047be:	d6f72f23          	sw	a5,-642(a4) # ffffffffc02a7538 <nr_process>
    if (flag)           // 如果原来中断是开启的
ffffffffc02047c2:	e271                	bnez	a2,ffffffffc0204886 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02047c4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02047c6:	c02007b7          	lui	a5,0xc0200
ffffffffc02047ca:	10f6e663          	bltu	a3,a5,ffffffffc02048d6 <do_wait.part.0+0x1ca>
ffffffffc02047ce:	000a3717          	auipc	a4,0xa3
ffffffffc02047d2:	d5273703          	ld	a4,-686(a4) # ffffffffc02a7520 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02047d6:	000a3797          	auipc	a5,0xa3
ffffffffc02047da:	d527b783          	ld	a5,-686(a5) # ffffffffc02a7528 <npage>
    return pa2page(PADDR(kva));
ffffffffc02047de:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02047e0:	82b1                	srli	a3,a3,0xc
ffffffffc02047e2:	0cf6fe63          	bgeu	a3,a5,ffffffffc02048be <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc02047e6:	00003797          	auipc	a5,0x3
ffffffffc02047ea:	25a7b783          	ld	a5,602(a5) # ffffffffc0207a40 <nbase>
ffffffffc02047ee:	000a3517          	auipc	a0,0xa3
ffffffffc02047f2:	d4253503          	ld	a0,-702(a0) # ffffffffc02a7530 <pages>
ffffffffc02047f6:	4589                	li	a1,2
ffffffffc02047f8:	8e9d                	sub	a3,a3,a5
ffffffffc02047fa:	069a                	slli	a3,a3,0x6
ffffffffc02047fc:	9536                	add	a0,a0,a3
ffffffffc02047fe:	806fe0ef          	jal	ffffffffc0202804 <free_pages>
    kfree(proc);
ffffffffc0204802:	8522                	mv	a0,s0
ffffffffc0204804:	bc0fd0ef          	jal	ffffffffc0201bc4 <kfree>
}
ffffffffc0204808:	70a2                	ld	ra,40(sp)
ffffffffc020480a:	7402                	ld	s0,32(sp)
ffffffffc020480c:	64e2                	ld	s1,24(sp)
ffffffffc020480e:	6942                	ld	s2,16(sp)
ffffffffc0204810:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc0204812:	4501                	li	a0,0
}
ffffffffc0204814:	6145                	addi	sp,sp,48
ffffffffc0204816:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204818:	000a3997          	auipc	s3,0xa3
ffffffffc020481c:	d2898993          	addi	s3,s3,-728 # ffffffffc02a7540 <current>
ffffffffc0204820:	0009b703          	ld	a4,0(s3)
ffffffffc0204824:	f487b683          	ld	a3,-184(a5)
ffffffffc0204828:	f0e695e3          	bne	a3,a4,ffffffffc0204732 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020482c:	f287a603          	lw	a2,-216(a5)
ffffffffc0204830:	468d                	li	a3,3
ffffffffc0204832:	06d60063          	beq	a2,a3,ffffffffc0204892 <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc0204836:	800007b7          	lui	a5,0x80000
ffffffffc020483a:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_cowtest_out_size+0xffffffff7fff3e09>
        current->state = PROC_SLEEPING;
ffffffffc020483c:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc020483e:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc0204842:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc0204844:	285000ef          	jal	ffffffffc02052c8 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204848:	0009b783          	ld	a5,0(s3)
ffffffffc020484c:	0b07a783          	lw	a5,176(a5)
ffffffffc0204850:	8b85                	andi	a5,a5,1
ffffffffc0204852:	e7b9                	bnez	a5,ffffffffc02048a0 <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc0204854:	ee0487e3          	beqz	s1,ffffffffc0204742 <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204858:	45a9                	li	a1,10
ffffffffc020485a:	8526                	mv	a0,s1
ffffffffc020485c:	07e010ef          	jal	ffffffffc02058da <hash32>
ffffffffc0204860:	02051793          	slli	a5,a0,0x20
ffffffffc0204864:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204868:	0009f797          	auipc	a5,0x9f
ffffffffc020486c:	c5878793          	addi	a5,a5,-936 # ffffffffc02a34c0 <hash_list>
ffffffffc0204870:	953e                	add	a0,a0,a5
ffffffffc0204872:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204874:	a029                	j	ffffffffc020487e <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc0204876:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020487a:	f8970fe3          	beq	a4,s1,ffffffffc0204818 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc020487e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204880:	fef51be3          	bne	a0,a5,ffffffffc0204876 <do_wait.part.0+0x16a>
ffffffffc0204884:	b57d                	j	ffffffffc0204732 <do_wait.part.0+0x26>
        intr_enable();  // 重新开启中断
ffffffffc0204886:	87efc0ef          	jal	ffffffffc0200904 <intr_enable>
ffffffffc020488a:	bf2d                	j	ffffffffc02047c4 <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc020488c:	7018                	ld	a4,32(s0)
ffffffffc020488e:	fb7c                	sd	a5,240(a4)
ffffffffc0204890:	b705                	j	ffffffffc02047b0 <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204892:	f2878413          	addi	s0,a5,-216
ffffffffc0204896:	b5d1                	j	ffffffffc020475a <do_wait.part.0+0x4e>
        intr_disable();  // 关闭中断
ffffffffc0204898:	872fc0ef          	jal	ffffffffc020090a <intr_disable>
        return 1;        // 返回原状态：开启
ffffffffc020489c:	4605                	li	a2,1
ffffffffc020489e:	b5f5                	j	ffffffffc020478a <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc02048a0:	555d                	li	a0,-9
ffffffffc02048a2:	d23ff0ef          	jal	ffffffffc02045c4 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc02048a6:	00003617          	auipc	a2,0x3
ffffffffc02048aa:	89260613          	addi	a2,a2,-1902 # ffffffffc0207138 <etext+0x1848>
ffffffffc02048ae:	3f100593          	li	a1,1009
ffffffffc02048b2:	00003517          	auipc	a0,0x3
ffffffffc02048b6:	80650513          	addi	a0,a0,-2042 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02048ba:	96ffb0ef          	jal	ffffffffc0200228 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048be:	00002617          	auipc	a2,0x2
ffffffffc02048c2:	9fa60613          	addi	a2,a2,-1542 # ffffffffc02062b8 <etext+0x9c8>
ffffffffc02048c6:	06b00593          	li	a1,107
ffffffffc02048ca:	00002517          	auipc	a0,0x2
ffffffffc02048ce:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc02048d2:	957fb0ef          	jal	ffffffffc0200228 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02048d6:	00002617          	auipc	a2,0x2
ffffffffc02048da:	d8260613          	addi	a2,a2,-638 # ffffffffc0206658 <etext+0xd68>
ffffffffc02048de:	07900593          	li	a1,121
ffffffffc02048e2:	00002517          	auipc	a0,0x2
ffffffffc02048e6:	9f650513          	addi	a0,a0,-1546 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc02048ea:	93ffb0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02048ee <init_main>:
// 参数:
//   arg: 线程参数（未使用）
// 返回值: 成功返回0
static int
init_main(void *arg)
{
ffffffffc02048ee:	1141                	addi	sp,sp,-16
ffffffffc02048f0:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02048f2:	f4bfd0ef          	jal	ffffffffc020283c <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02048f6:	a24fd0ef          	jal	ffffffffc0201b1a <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02048fa:	4601                	li	a2,0
ffffffffc02048fc:	4581                	li	a1,0
ffffffffc02048fe:	fffff517          	auipc	a0,0xfffff
ffffffffc0204902:	71850513          	addi	a0,a0,1816 # ffffffffc0204016 <user_main>
ffffffffc0204906:	c6fff0ef          	jal	ffffffffc0204574 <kernel_thread>
    if (pid <= 0)
ffffffffc020490a:	00a04563          	bgtz	a0,ffffffffc0204914 <init_main+0x26>
ffffffffc020490e:	a071                	j	ffffffffc020499a <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204910:	1b9000ef          	jal	ffffffffc02052c8 <schedule>
    if (code_store != NULL)
ffffffffc0204914:	4581                	li	a1,0
ffffffffc0204916:	4501                	li	a0,0
ffffffffc0204918:	df5ff0ef          	jal	ffffffffc020470c <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc020491c:	d975                	beqz	a0,ffffffffc0204910 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020491e:	00003517          	auipc	a0,0x3
ffffffffc0204922:	85a50513          	addi	a0,a0,-1958 # ffffffffc0207178 <etext+0x1888>
ffffffffc0204926:	fb8fb0ef          	jal	ffffffffc02000de <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020492a:	000a3797          	auipc	a5,0xa3
ffffffffc020492e:	c1e7b783          	ld	a5,-994(a5) # ffffffffc02a7548 <initproc>
ffffffffc0204932:	7bf8                	ld	a4,240(a5)
ffffffffc0204934:	e339                	bnez	a4,ffffffffc020497a <init_main+0x8c>
ffffffffc0204936:	7ff8                	ld	a4,248(a5)
ffffffffc0204938:	e329                	bnez	a4,ffffffffc020497a <init_main+0x8c>
ffffffffc020493a:	1007b703          	ld	a4,256(a5)
ffffffffc020493e:	ef15                	bnez	a4,ffffffffc020497a <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204940:	000a3697          	auipc	a3,0xa3
ffffffffc0204944:	bf86a683          	lw	a3,-1032(a3) # ffffffffc02a7538 <nr_process>
ffffffffc0204948:	4709                	li	a4,2
ffffffffc020494a:	0ae69463          	bne	a3,a4,ffffffffc02049f2 <init_main+0x104>
ffffffffc020494e:	000a3697          	auipc	a3,0xa3
ffffffffc0204952:	b7268693          	addi	a3,a3,-1166 # ffffffffc02a74c0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204956:	6698                	ld	a4,8(a3)
ffffffffc0204958:	0c878793          	addi	a5,a5,200
ffffffffc020495c:	06f71b63          	bne	a4,a5,ffffffffc02049d2 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204960:	629c                	ld	a5,0(a3)
ffffffffc0204962:	04f71863          	bne	a4,a5,ffffffffc02049b2 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0204966:	00003517          	auipc	a0,0x3
ffffffffc020496a:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0207260 <etext+0x1970>
ffffffffc020496e:	f70fb0ef          	jal	ffffffffc02000de <cprintf>
    return 0;
}
ffffffffc0204972:	60a2                	ld	ra,8(sp)
ffffffffc0204974:	4501                	li	a0,0
ffffffffc0204976:	0141                	addi	sp,sp,16
ffffffffc0204978:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020497a:	00003697          	auipc	a3,0x3
ffffffffc020497e:	82668693          	addi	a3,a3,-2010 # ffffffffc02071a0 <etext+0x18b0>
ffffffffc0204982:	00002617          	auipc	a2,0x2
ffffffffc0204986:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206370 <etext+0xa80>
ffffffffc020498a:	47a00593          	li	a1,1146
ffffffffc020498e:	00002517          	auipc	a0,0x2
ffffffffc0204992:	72a50513          	addi	a0,a0,1834 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204996:	893fb0ef          	jal	ffffffffc0200228 <__panic>
        panic("create user_main failed.\n");
ffffffffc020499a:	00002617          	auipc	a2,0x2
ffffffffc020499e:	7be60613          	addi	a2,a2,1982 # ffffffffc0207158 <etext+0x1868>
ffffffffc02049a2:	47100593          	li	a1,1137
ffffffffc02049a6:	00002517          	auipc	a0,0x2
ffffffffc02049aa:	71250513          	addi	a0,a0,1810 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02049ae:	87bfb0ef          	jal	ffffffffc0200228 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02049b2:	00003697          	auipc	a3,0x3
ffffffffc02049b6:	87e68693          	addi	a3,a3,-1922 # ffffffffc0207230 <etext+0x1940>
ffffffffc02049ba:	00002617          	auipc	a2,0x2
ffffffffc02049be:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206370 <etext+0xa80>
ffffffffc02049c2:	47d00593          	li	a1,1149
ffffffffc02049c6:	00002517          	auipc	a0,0x2
ffffffffc02049ca:	6f250513          	addi	a0,a0,1778 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02049ce:	85bfb0ef          	jal	ffffffffc0200228 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02049d2:	00003697          	auipc	a3,0x3
ffffffffc02049d6:	82e68693          	addi	a3,a3,-2002 # ffffffffc0207200 <etext+0x1910>
ffffffffc02049da:	00002617          	auipc	a2,0x2
ffffffffc02049de:	99660613          	addi	a2,a2,-1642 # ffffffffc0206370 <etext+0xa80>
ffffffffc02049e2:	47c00593          	li	a1,1148
ffffffffc02049e6:	00002517          	auipc	a0,0x2
ffffffffc02049ea:	6d250513          	addi	a0,a0,1746 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02049ee:	83bfb0ef          	jal	ffffffffc0200228 <__panic>
    assert(nr_process == 2);
ffffffffc02049f2:	00002697          	auipc	a3,0x2
ffffffffc02049f6:	7fe68693          	addi	a3,a3,2046 # ffffffffc02071f0 <etext+0x1900>
ffffffffc02049fa:	00002617          	auipc	a2,0x2
ffffffffc02049fe:	97660613          	addi	a2,a2,-1674 # ffffffffc0206370 <etext+0xa80>
ffffffffc0204a02:	47b00593          	li	a1,1147
ffffffffc0204a06:	00002517          	auipc	a0,0x2
ffffffffc0204a0a:	6b250513          	addi	a0,a0,1714 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204a0e:	81bfb0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0204a12 <do_execve>:
{
ffffffffc0204a12:	7171                	addi	sp,sp,-176
ffffffffc0204a14:	f4de                	sd	s7,104(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204a16:	000a3b97          	auipc	s7,0xa3
ffffffffc0204a1a:	b2ab8b93          	addi	s7,s7,-1238 # ffffffffc02a7540 <current>
ffffffffc0204a1e:	000bb783          	ld	a5,0(s7)
{
ffffffffc0204a22:	e94a                	sd	s2,144(sp)
ffffffffc0204a24:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204a26:	0287b903          	ld	s2,40(a5)
{
ffffffffc0204a2a:	84ae                	mv	s1,a1
ffffffffc0204a2c:	e54e                	sd	s3,136(sp)
ffffffffc0204a2e:	ec32                	sd	a2,24(sp)
ffffffffc0204a30:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a32:	85aa                	mv	a1,a0
ffffffffc0204a34:	8626                	mv	a2,s1
ffffffffc0204a36:	854a                	mv	a0,s2
ffffffffc0204a38:	4681                	li	a3,0
{
ffffffffc0204a3a:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a3c:	dbbfc0ef          	jal	ffffffffc02017f6 <user_mem_check>
ffffffffc0204a40:	48050463          	beqz	a0,ffffffffc0204ec8 <do_execve+0x4b6>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204a44:	4641                	li	a2,16
ffffffffc0204a46:	1808                	addi	a0,sp,48
ffffffffc0204a48:	4581                	li	a1,0
ffffffffc0204a4a:	29b000ef          	jal	ffffffffc02054e4 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc0204a4e:	47bd                	li	a5,15
ffffffffc0204a50:	8626                	mv	a2,s1
ffffffffc0204a52:	1097e163          	bltu	a5,s1,ffffffffc0204b54 <do_execve+0x142>
    memcpy(local_name, name, len);
ffffffffc0204a56:	85ce                	mv	a1,s3
ffffffffc0204a58:	1808                	addi	a0,sp,48
ffffffffc0204a5a:	29d000ef          	jal	ffffffffc02054f6 <memcpy>
    if (mm != NULL)
ffffffffc0204a5e:	10090263          	beqz	s2,ffffffffc0204b62 <do_execve+0x150>
        cputs("mm != NULL");
ffffffffc0204a62:	00002517          	auipc	a0,0x2
ffffffffc0204a66:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0206410 <etext+0xb20>
ffffffffc0204a6a:	eacfb0ef          	jal	ffffffffc0200116 <cputs>
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204a6e:	000a3797          	auipc	a5,0xa3
ffffffffc0204a72:	aa27b783          	ld	a5,-1374(a5) # ffffffffc02a7510 <boot_pgdir_pa>
ffffffffc0204a76:	577d                	li	a4,-1
ffffffffc0204a78:	177e                	slli	a4,a4,0x3f
ffffffffc0204a7a:	83b1                	srli	a5,a5,0xc
ffffffffc0204a7c:	8fd9                	or	a5,a5,a4
ffffffffc0204a7e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma" ::: "memory");
ffffffffc0204a82:	12000073          	sfence.vma
ffffffffc0204a86:	03092783          	lw	a5,48(s2)
ffffffffc0204a8a:	37fd                	addiw	a5,a5,-1
ffffffffc0204a8c:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0204a90:	30078863          	beqz	a5,ffffffffc0204da0 <do_execve+0x38e>
        current->mm = NULL;
ffffffffc0204a94:	000bb783          	ld	a5,0(s7)
ffffffffc0204a98:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a9c:	ecefc0ef          	jal	ffffffffc020116a <mm_create>
ffffffffc0204aa0:	892a                	mv	s2,a0
ffffffffc0204aa2:	22050363          	beqz	a0,ffffffffc0204cc8 <do_execve+0x2b6>
    if ((page = alloc_page()) == NULL)
ffffffffc0204aa6:	4505                	li	a0,1
ffffffffc0204aa8:	d23fd0ef          	jal	ffffffffc02027ca <alloc_pages>
ffffffffc0204aac:	42050363          	beqz	a0,ffffffffc0204ed2 <do_execve+0x4c0>
    return page - pages + nbase;
ffffffffc0204ab0:	ece6                	sd	s9,88(sp)
ffffffffc0204ab2:	000a3c97          	auipc	s9,0xa3
ffffffffc0204ab6:	a7ec8c93          	addi	s9,s9,-1410 # ffffffffc02a7530 <pages>
ffffffffc0204aba:	000cb783          	ld	a5,0(s9)
ffffffffc0204abe:	f0e2                	sd	s8,96(sp)
ffffffffc0204ac0:	00003c17          	auipc	s8,0x3
ffffffffc0204ac4:	f80c3c03          	ld	s8,-128(s8) # ffffffffc0207a40 <nbase>
ffffffffc0204ac8:	40f506b3          	sub	a3,a0,a5
ffffffffc0204acc:	e8ea                	sd	s10,80(sp)
    return KADDR(page2pa(page));
ffffffffc0204ace:	000a3d17          	auipc	s10,0xa3
ffffffffc0204ad2:	a5ad0d13          	addi	s10,s10,-1446 # ffffffffc02a7528 <npage>
ffffffffc0204ad6:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc0204ad8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ada:	5b7d                	li	s6,-1
ffffffffc0204adc:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204ae0:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0204ae2:	00cb5713          	srli	a4,s6,0xc
ffffffffc0204ae6:	e83a                	sd	a4,16(sp)
ffffffffc0204ae8:	fcd6                	sd	s5,120(sp)
ffffffffc0204aea:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204aec:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204aee:	40f77563          	bgeu	a4,a5,ffffffffc0204ef8 <do_execve+0x4e6>
ffffffffc0204af2:	000a3a97          	auipc	s5,0xa3
ffffffffc0204af6:	a2ea8a93          	addi	s5,s5,-1490 # ffffffffc02a7520 <va_pa_offset>
ffffffffc0204afa:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204afe:	000a3597          	auipc	a1,0xa3
ffffffffc0204b02:	a1a5b583          	ld	a1,-1510(a1) # ffffffffc02a7518 <boot_pgdir_va>
ffffffffc0204b06:	6605                	lui	a2,0x1
ffffffffc0204b08:	00f684b3          	add	s1,a3,a5
ffffffffc0204b0c:	8526                	mv	a0,s1
ffffffffc0204b0e:	1e9000ef          	jal	ffffffffc02054f6 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204b12:	66e2                	ld	a3,24(sp)
ffffffffc0204b14:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204b18:	00993c23          	sd	s1,24(s2)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204b1c:	4298                	lw	a4,0(a3)
ffffffffc0204b1e:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_cowtest_out_size+0x464b8387>
ffffffffc0204b22:	06f70863          	beq	a4,a5,ffffffffc0204b92 <do_execve+0x180>
        ret = -E_INVAL_ELF;
ffffffffc0204b26:	54e1                	li	s1,-8
    put_pgdir(mm);          // 释放页目录表
ffffffffc0204b28:	854a                	mv	a0,s2
ffffffffc0204b2a:	d6aff0ef          	jal	ffffffffc0204094 <put_pgdir>
    goto bad_pgdir_cleanup_mm;
ffffffffc0204b2e:	7ae6                	ld	s5,120(sp)
ffffffffc0204b30:	7b46                	ld	s6,112(sp)
ffffffffc0204b32:	7c06                	ld	s8,96(sp)
ffffffffc0204b34:	6ce6                	ld	s9,88(sp)
ffffffffc0204b36:	6d46                	ld	s10,80(sp)
    mm_destroy(mm);         // 销毁内存管理结构
ffffffffc0204b38:	854a                	mv	a0,s2
ffffffffc0204b3a:	f6efc0ef          	jal	ffffffffc02012a8 <mm_destroy>
    do_exit(ret);
ffffffffc0204b3e:	8526                	mv	a0,s1
ffffffffc0204b40:	f122                	sd	s0,160(sp)
ffffffffc0204b42:	e152                	sd	s4,128(sp)
ffffffffc0204b44:	fcd6                	sd	s5,120(sp)
ffffffffc0204b46:	f8da                	sd	s6,112(sp)
ffffffffc0204b48:	f0e2                	sd	s8,96(sp)
ffffffffc0204b4a:	ece6                	sd	s9,88(sp)
ffffffffc0204b4c:	e8ea                	sd	s10,80(sp)
ffffffffc0204b4e:	e4ee                	sd	s11,72(sp)
ffffffffc0204b50:	a75ff0ef          	jal	ffffffffc02045c4 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc0204b54:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc0204b56:	85ce                	mv	a1,s3
ffffffffc0204b58:	1808                	addi	a0,sp,48
ffffffffc0204b5a:	19d000ef          	jal	ffffffffc02054f6 <memcpy>
    if (mm != NULL)
ffffffffc0204b5e:	f00912e3          	bnez	s2,ffffffffc0204a62 <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc0204b62:	000bb783          	ld	a5,0(s7)
ffffffffc0204b66:	779c                	ld	a5,40(a5)
ffffffffc0204b68:	db95                	beqz	a5,ffffffffc0204a9c <do_execve+0x8a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204b6a:	00002617          	auipc	a2,0x2
ffffffffc0204b6e:	71660613          	addi	a2,a2,1814 # ffffffffc0207280 <etext+0x1990>
ffffffffc0204b72:	29100593          	li	a1,657
ffffffffc0204b76:	00002517          	auipc	a0,0x2
ffffffffc0204b7a:	54250513          	addi	a0,a0,1346 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204b7e:	f122                	sd	s0,160(sp)
ffffffffc0204b80:	e152                	sd	s4,128(sp)
ffffffffc0204b82:	fcd6                	sd	s5,120(sp)
ffffffffc0204b84:	f8da                	sd	s6,112(sp)
ffffffffc0204b86:	f0e2                	sd	s8,96(sp)
ffffffffc0204b88:	ece6                	sd	s9,88(sp)
ffffffffc0204b8a:	e8ea                	sd	s10,80(sp)
ffffffffc0204b8c:	e4ee                	sd	s11,72(sp)
ffffffffc0204b8e:	e9afb0ef          	jal	ffffffffc0200228 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b92:	0386d703          	lhu	a4,56(a3)
ffffffffc0204b96:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204b98:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204b9c:	00371793          	slli	a5,a4,0x3
ffffffffc0204ba0:	8f99                	sub	a5,a5,a4
ffffffffc0204ba2:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204ba4:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204ba6:	97d2                	add	a5,a5,s4
ffffffffc0204ba8:	f122                	sd	s0,160(sp)
ffffffffc0204baa:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0204bac:	00fa7e63          	bgeu	s4,a5,ffffffffc0204bc8 <do_execve+0x1b6>
ffffffffc0204bb0:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204bb2:	000a2783          	lw	a5,0(s4)
ffffffffc0204bb6:	4705                	li	a4,1
ffffffffc0204bb8:	10e78a63          	beq	a5,a4,ffffffffc0204ccc <do_execve+0x2ba>
    for (; ph < ph_end; ph++)
ffffffffc0204bbc:	77a2                	ld	a5,40(sp)
ffffffffc0204bbe:	038a0a13          	addi	s4,s4,56
ffffffffc0204bc2:	fefa68e3          	bltu	s4,a5,ffffffffc0204bb2 <do_execve+0x1a0>
ffffffffc0204bc6:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204bc8:	4701                	li	a4,0
ffffffffc0204bca:	46ad                	li	a3,11
ffffffffc0204bcc:	00100637          	lui	a2,0x100
ffffffffc0204bd0:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204bd4:	854a                	mv	a0,s2
ffffffffc0204bd6:	f24fc0ef          	jal	ffffffffc02012fa <mm_map>
ffffffffc0204bda:	84aa                	mv	s1,a0
ffffffffc0204bdc:	1a051c63          	bnez	a0,ffffffffc0204d94 <do_execve+0x382>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204be0:	01893503          	ld	a0,24(s2)
ffffffffc0204be4:	467d                	li	a2,31
ffffffffc0204be6:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204bea:	a7cff0ef          	jal	ffffffffc0203e66 <pgdir_alloc_page>
ffffffffc0204bee:	3a050463          	beqz	a0,ffffffffc0204f96 <do_execve+0x584>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204bf2:	01893503          	ld	a0,24(s2)
ffffffffc0204bf6:	467d                	li	a2,31
ffffffffc0204bf8:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204bfc:	a6aff0ef          	jal	ffffffffc0203e66 <pgdir_alloc_page>
ffffffffc0204c00:	36050a63          	beqz	a0,ffffffffc0204f74 <do_execve+0x562>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c04:	01893503          	ld	a0,24(s2)
ffffffffc0204c08:	467d                	li	a2,31
ffffffffc0204c0a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204c0e:	a58ff0ef          	jal	ffffffffc0203e66 <pgdir_alloc_page>
ffffffffc0204c12:	34050063          	beqz	a0,ffffffffc0204f52 <do_execve+0x540>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c16:	01893503          	ld	a0,24(s2)
ffffffffc0204c1a:	467d                	li	a2,31
ffffffffc0204c1c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204c20:	a46ff0ef          	jal	ffffffffc0203e66 <pgdir_alloc_page>
ffffffffc0204c24:	30050663          	beqz	a0,ffffffffc0204f30 <do_execve+0x51e>
    mm->mm_count += 1;
ffffffffc0204c28:	03092783          	lw	a5,48(s2)
    current->mm = mm;                    // 设置进程的内存管理结构
ffffffffc0204c2c:	000bb603          	ld	a2,0(s7)
    current->pgdir = PADDR(mm->pgdir);   // 设置进程的页目录表物理地址
ffffffffc0204c30:	01893683          	ld	a3,24(s2)
ffffffffc0204c34:	2785                	addiw	a5,a5,1
ffffffffc0204c36:	02f92823          	sw	a5,48(s2)
    current->mm = mm;                    // 设置进程的内存管理结构
ffffffffc0204c3a:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_cowtest_out_size+0xf3e30>
    current->pgdir = PADDR(mm->pgdir);   // 设置进程的页目录表物理地址
ffffffffc0204c3e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c42:	2cf6ea63          	bltu	a3,a5,ffffffffc0204f16 <do_execve+0x504>
ffffffffc0204c46:	000ab703          	ld	a4,0(s5)
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204c4a:	57fd                	li	a5,-1
ffffffffc0204c4c:	17fe                	slli	a5,a5,0x3f
ffffffffc0204c4e:	8e99                	sub	a3,a3,a4
ffffffffc0204c50:	f654                	sd	a3,168(a2)
ffffffffc0204c52:	82b1                	srli	a3,a3,0xc
ffffffffc0204c54:	8edd                	or	a3,a3,a5
ffffffffc0204c56:	18069073          	csrw	satp,a3
  asm volatile("sfence.vma" ::: "memory");
ffffffffc0204c5a:	12000073          	sfence.vma
    struct trapframe *tf = current->tf;
ffffffffc0204c5e:	000bb783          	ld	a5,0(s7)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c62:	12000613          	li	a2,288
ffffffffc0204c66:	4581                	li	a1,0
    struct trapframe *tf = current->tf;
ffffffffc0204c68:	73c0                	ld	s0,160(a5)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c6a:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0204c6c:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c70:	075000ef          	jal	ffffffffc02054e4 <memset>
    tf->epc = elf->e_entry;              // 设置程序入口点(从ELF头获取)
ffffffffc0204c74:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c76:	000bb983          	ld	s3,0(s7)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204c7a:	edd97913          	andi	s2,s2,-291
    tf->epc = elf->e_entry;              // 设置程序入口点(从ELF头获取)
ffffffffc0204c7e:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;              // 设置用户栈顶指针
ffffffffc0204c80:	4785                	li	a5,1
ffffffffc0204c82:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204c84:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;              // 设置程序入口点(从ELF头获取)
ffffffffc0204c88:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;              // 设置用户栈顶指针
ffffffffc0204c8c:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~(SSTATUS_SPP | SSTATUS_SIE)) | SSTATUS_SPIE;
ffffffffc0204c8e:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c92:	4641                	li	a2,16
ffffffffc0204c94:	4581                	li	a1,0
ffffffffc0204c96:	0b498513          	addi	a0,s3,180
ffffffffc0204c9a:	04b000ef          	jal	ffffffffc02054e4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204c9e:	180c                	addi	a1,sp,48
ffffffffc0204ca0:	0b498513          	addi	a0,s3,180
ffffffffc0204ca4:	463d                	li	a2,15
ffffffffc0204ca6:	051000ef          	jal	ffffffffc02054f6 <memcpy>
ffffffffc0204caa:	740a                	ld	s0,160(sp)
ffffffffc0204cac:	6a0a                	ld	s4,128(sp)
ffffffffc0204cae:	7ae6                	ld	s5,120(sp)
ffffffffc0204cb0:	7b46                	ld	s6,112(sp)
ffffffffc0204cb2:	7c06                	ld	s8,96(sp)
ffffffffc0204cb4:	6ce6                	ld	s9,88(sp)
ffffffffc0204cb6:	6d46                	ld	s10,80(sp)
}
ffffffffc0204cb8:	70aa                	ld	ra,168(sp)
ffffffffc0204cba:	694a                	ld	s2,144(sp)
ffffffffc0204cbc:	69aa                	ld	s3,136(sp)
ffffffffc0204cbe:	7ba6                	ld	s7,104(sp)
ffffffffc0204cc0:	8526                	mv	a0,s1
ffffffffc0204cc2:	64ea                	ld	s1,152(sp)
ffffffffc0204cc4:	614d                	addi	sp,sp,176
ffffffffc0204cc6:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0204cc8:	54f1                	li	s1,-4
ffffffffc0204cca:	bd95                	j	ffffffffc0204b3e <do_execve+0x12c>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204ccc:	028a3603          	ld	a2,40(s4)
ffffffffc0204cd0:	020a3783          	ld	a5,32(s4)
ffffffffc0204cd4:	20f66363          	bltu	a2,a5,ffffffffc0204eda <do_execve+0x4c8>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204cd8:	004a2783          	lw	a5,4(s4)
ffffffffc0204cdc:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204ce0:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204ce4:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204ce6:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204ce8:	c6f1                	beqz	a3,ffffffffc0204db4 <do_execve+0x3a2>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204cea:	1c079763          	bnez	a5,ffffffffc0204eb8 <do_execve+0x4a6>
            perm |= (PTE_W | PTE_R); // 写权限(必须同时有读权限)
ffffffffc0204cee:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;    // 可写权限
ffffffffc0204cf0:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R); // 写权限(必须同时有读权限)
ffffffffc0204cf4:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0204cf6:	c709                	beqz	a4,ffffffffc0204d00 <do_execve+0x2ee>
            perm |= PTE_X;           // 执行权限
ffffffffc0204cf8:	67a2                	ld	a5,8(sp)
ffffffffc0204cfa:	0087e793          	ori	a5,a5,8
ffffffffc0204cfe:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204d00:	010a3583          	ld	a1,16(s4)
ffffffffc0204d04:	4701                	li	a4,0
ffffffffc0204d06:	854a                	mv	a0,s2
ffffffffc0204d08:	df2fc0ef          	jal	ffffffffc02012fa <mm_map>
ffffffffc0204d0c:	84aa                	mv	s1,a0
ffffffffc0204d0e:	1c051463          	bnez	a0,ffffffffc0204ed6 <do_execve+0x4c4>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204d12:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204d16:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204d1a:	77fd                	lui	a5,0xfffff
ffffffffc0204d1c:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc0204d20:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc0204d22:	1a9b7563          	bgeu	s6,s1,ffffffffc0204ecc <do_execve+0x4ba>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204d26:	008a3983          	ld	s3,8(s4)
ffffffffc0204d2a:	67e2                	ld	a5,24(sp)
ffffffffc0204d2c:	99be                	add	s3,s3,a5
ffffffffc0204d2e:	a881                	j	ffffffffc0204d7e <do_execve+0x36c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d30:	6785                	lui	a5,0x1
ffffffffc0204d32:	00f58db3          	add	s11,a1,a5
                size -= la - end;  // 调整大小以适应段边界
ffffffffc0204d36:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc0204d3a:	01b4e463          	bltu	s1,s11,ffffffffc0204d42 <do_execve+0x330>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d3e:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc0204d42:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204d46:	67c2                	ld	a5,16(sp)
ffffffffc0204d48:	000d3503          	ld	a0,0(s10)
    return page - pages + nbase;
ffffffffc0204d4c:	40d406b3          	sub	a3,s0,a3
ffffffffc0204d50:	8699                	srai	a3,a3,0x6
ffffffffc0204d52:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0204d54:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d58:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d5a:	18a87363          	bgeu	a6,a0,ffffffffc0204ee0 <do_execve+0x4ce>
ffffffffc0204d5e:	000ab503          	ld	a0,0(s5)
ffffffffc0204d62:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204d66:	e032                	sd	a2,0(sp)
ffffffffc0204d68:	9536                	add	a0,a0,a3
ffffffffc0204d6a:	952e                	add	a0,a0,a1
ffffffffc0204d6c:	85ce                	mv	a1,s3
ffffffffc0204d6e:	788000ef          	jal	ffffffffc02054f6 <memcpy>
            start += size, from += size;
ffffffffc0204d72:	6602                	ld	a2,0(sp)
ffffffffc0204d74:	9b32                	add	s6,s6,a2
ffffffffc0204d76:	99b2                	add	s3,s3,a2
        while (start < end)
ffffffffc0204d78:	049b7563          	bgeu	s6,s1,ffffffffc0204dc2 <do_execve+0x3b0>
ffffffffc0204d7c:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204d7e:	01893503          	ld	a0,24(s2)
ffffffffc0204d82:	6622                	ld	a2,8(sp)
ffffffffc0204d84:	e02e                	sd	a1,0(sp)
ffffffffc0204d86:	8e0ff0ef          	jal	ffffffffc0203e66 <pgdir_alloc_page>
ffffffffc0204d8a:	6582                	ld	a1,0(sp)
ffffffffc0204d8c:	842a                	mv	s0,a0
ffffffffc0204d8e:	f14d                	bnez	a0,ffffffffc0204d30 <do_execve+0x31e>
ffffffffc0204d90:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0204d92:	54f1                	li	s1,-4
    exit_mmap(mm);          // 清理虚拟内存区域映射
ffffffffc0204d94:	854a                	mv	a0,s2
ffffffffc0204d96:	ec8fc0ef          	jal	ffffffffc020145e <exit_mmap>
    goto bad_elf_cleanup_pgdir;
ffffffffc0204d9a:	740a                	ld	s0,160(sp)
ffffffffc0204d9c:	6a0a                	ld	s4,128(sp)
ffffffffc0204d9e:	b369                	j	ffffffffc0204b28 <do_execve+0x116>
            exit_mmap(mm);
ffffffffc0204da0:	854a                	mv	a0,s2
ffffffffc0204da2:	ebcfc0ef          	jal	ffffffffc020145e <exit_mmap>
            put_pgdir(mm);
ffffffffc0204da6:	854a                	mv	a0,s2
ffffffffc0204da8:	aecff0ef          	jal	ffffffffc0204094 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204dac:	854a                	mv	a0,s2
ffffffffc0204dae:	cfafc0ef          	jal	ffffffffc02012a8 <mm_destroy>
ffffffffc0204db2:	b1cd                	j	ffffffffc0204a94 <do_execve+0x82>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204db4:	0e078e63          	beqz	a5,ffffffffc0204eb0 <do_execve+0x49e>
            perm |= PTE_R;           // 读权限
ffffffffc0204db8:	47cd                	li	a5,19
            vm_flags |= VM_READ;     // 可读权限
ffffffffc0204dba:	00176693          	ori	a3,a4,1
            perm |= PTE_R;           // 读权限
ffffffffc0204dbe:	e43e                	sd	a5,8(sp)
ffffffffc0204dc0:	bf1d                	j	ffffffffc0204cf6 <do_execve+0x2e4>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204dc2:	010a3483          	ld	s1,16(s4)
ffffffffc0204dc6:	028a3683          	ld	a3,40(s4)
ffffffffc0204dca:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204dcc:	07bb7c63          	bgeu	s6,s11,ffffffffc0204e44 <do_execve+0x432>
            if (start == end)
ffffffffc0204dd0:	df6486e3          	beq	s1,s6,ffffffffc0204bbc <do_execve+0x1aa>
                size -= la - end;
ffffffffc0204dd4:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204dd8:	0fb4f563          	bgeu	s1,s11,ffffffffc0204ec2 <do_execve+0x4b0>
    return page - pages + nbase;
ffffffffc0204ddc:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204de0:	000d3603          	ld	a2,0(s10)
    return page - pages + nbase;
ffffffffc0204de4:	40d406b3          	sub	a3,s0,a3
ffffffffc0204de8:	8699                	srai	a3,a3,0x6
ffffffffc0204dea:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0204dec:	00c69593          	slli	a1,a3,0xc
ffffffffc0204df0:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204df2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204df4:	0ec5f663          	bgeu	a1,a2,ffffffffc0204ee0 <do_execve+0x4ce>
ffffffffc0204df8:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204dfc:	6505                	lui	a0,0x1
ffffffffc0204dfe:	955a                	add	a0,a0,s6
ffffffffc0204e00:	96b2                	add	a3,a3,a2
ffffffffc0204e02:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e06:	9536                	add	a0,a0,a3
ffffffffc0204e08:	864e                	mv	a2,s3
ffffffffc0204e0a:	4581                	li	a1,0
ffffffffc0204e0c:	6d8000ef          	jal	ffffffffc02054e4 <memset>
            start += size;
ffffffffc0204e10:	9b4e                	add	s6,s6,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204e12:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc0204e16:	01b4f463          	bgeu	s1,s11,ffffffffc0204e1e <do_execve+0x40c>
ffffffffc0204e1a:	db6481e3          	beq	s1,s6,ffffffffc0204bbc <do_execve+0x1aa>
ffffffffc0204e1e:	e299                	bnez	a3,ffffffffc0204e24 <do_execve+0x412>
ffffffffc0204e20:	03bb0263          	beq	s6,s11,ffffffffc0204e44 <do_execve+0x432>
ffffffffc0204e24:	00002697          	auipc	a3,0x2
ffffffffc0204e28:	48468693          	addi	a3,a3,1156 # ffffffffc02072a8 <etext+0x19b8>
ffffffffc0204e2c:	00001617          	auipc	a2,0x1
ffffffffc0204e30:	54460613          	addi	a2,a2,1348 # ffffffffc0206370 <etext+0xa80>
ffffffffc0204e34:	32100593          	li	a1,801
ffffffffc0204e38:	00002517          	auipc	a0,0x2
ffffffffc0204e3c:	28050513          	addi	a0,a0,640 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204e40:	be8fb0ef          	jal	ffffffffc0200228 <__panic>
        while (start < end)
ffffffffc0204e44:	d69b7ce3          	bgeu	s6,s1,ffffffffc0204bbc <do_execve+0x1aa>
ffffffffc0204e48:	56fd                	li	a3,-1
ffffffffc0204e4a:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204e4e:	f03e                	sd	a5,32(sp)
ffffffffc0204e50:	a0b9                	j	ffffffffc0204e9e <do_execve+0x48c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e52:	6785                	lui	a5,0x1
ffffffffc0204e54:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc0204e58:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204e5c:	0104e463          	bltu	s1,a6,ffffffffc0204e64 <do_execve+0x452>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e60:	416809b3          	sub	s3,a6,s6
    return page - pages + nbase;
ffffffffc0204e64:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc0204e68:	7782                	ld	a5,32(sp)
ffffffffc0204e6a:	000d3583          	ld	a1,0(s10)
    return page - pages + nbase;
ffffffffc0204e6e:	40d406b3          	sub	a3,s0,a3
ffffffffc0204e72:	8699                	srai	a3,a3,0x6
ffffffffc0204e74:	96e2                	add	a3,a3,s8
    return KADDR(page2pa(page));
ffffffffc0204e76:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e7a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e7c:	06b57263          	bgeu	a0,a1,ffffffffc0204ee0 <do_execve+0x4ce>
ffffffffc0204e80:	000ab583          	ld	a1,0(s5)
ffffffffc0204e84:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e88:	864e                	mv	a2,s3
ffffffffc0204e8a:	96ae                	add	a3,a3,a1
ffffffffc0204e8c:	9536                	add	a0,a0,a3
ffffffffc0204e8e:	4581                	li	a1,0
            start += size;
ffffffffc0204e90:	9b4e                	add	s6,s6,s3
ffffffffc0204e92:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e94:	650000ef          	jal	ffffffffc02054e4 <memset>
        while (start < end)
ffffffffc0204e98:	d29b72e3          	bgeu	s6,s1,ffffffffc0204bbc <do_execve+0x1aa>
ffffffffc0204e9c:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204e9e:	01893503          	ld	a0,24(s2)
ffffffffc0204ea2:	6622                	ld	a2,8(sp)
ffffffffc0204ea4:	85ee                	mv	a1,s11
ffffffffc0204ea6:	fc1fe0ef          	jal	ffffffffc0203e66 <pgdir_alloc_page>
ffffffffc0204eaa:	842a                	mv	s0,a0
ffffffffc0204eac:	f15d                	bnez	a0,ffffffffc0204e52 <do_execve+0x440>
ffffffffc0204eae:	b5cd                	j	ffffffffc0204d90 <do_execve+0x37e>
        vm_flags = 0, perm = PTE_U | PTE_V;  // 用户态可访问，页表项有效
ffffffffc0204eb0:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204eb2:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;  // 用户态可访问，页表项有效
ffffffffc0204eb4:	e43e                	sd	a5,8(sp)
ffffffffc0204eb6:	b581                	j	ffffffffc0204cf6 <do_execve+0x2e4>
            perm |= (PTE_W | PTE_R); // 写权限(必须同时有读权限)
ffffffffc0204eb8:	47dd                	li	a5,23
            vm_flags |= VM_READ;     // 可读权限
ffffffffc0204eba:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R); // 写权限(必须同时有读权限)
ffffffffc0204ebe:	e43e                	sd	a5,8(sp)
ffffffffc0204ec0:	bd1d                	j	ffffffffc0204cf6 <do_execve+0x2e4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204ec2:	416d89b3          	sub	s3,s11,s6
ffffffffc0204ec6:	bf19                	j	ffffffffc0204ddc <do_execve+0x3ca>
        return -E_INVAL;
ffffffffc0204ec8:	54f5                	li	s1,-3
ffffffffc0204eca:	b3fd                	j	ffffffffc0204cb8 <do_execve+0x2a6>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ecc:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc0204ece:	84da                	mv	s1,s6
ffffffffc0204ed0:	bddd                	j	ffffffffc0204dc6 <do_execve+0x3b4>
    int ret = -E_NO_MEM;
ffffffffc0204ed2:	54f1                	li	s1,-4
ffffffffc0204ed4:	b195                	j	ffffffffc0204b38 <do_execve+0x126>
ffffffffc0204ed6:	6da6                	ld	s11,72(sp)
ffffffffc0204ed8:	bd75                	j	ffffffffc0204d94 <do_execve+0x382>
            ret = -E_INVAL_ELF;
ffffffffc0204eda:	6da6                	ld	s11,72(sp)
ffffffffc0204edc:	54e1                	li	s1,-8
ffffffffc0204ede:	bd5d                	j	ffffffffc0204d94 <do_execve+0x382>
ffffffffc0204ee0:	00001617          	auipc	a2,0x1
ffffffffc0204ee4:	41860613          	addi	a2,a2,1048 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0204ee8:	07300593          	li	a1,115
ffffffffc0204eec:	00001517          	auipc	a0,0x1
ffffffffc0204ef0:	3ec50513          	addi	a0,a0,1004 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0204ef4:	b34fb0ef          	jal	ffffffffc0200228 <__panic>
ffffffffc0204ef8:	00001617          	auipc	a2,0x1
ffffffffc0204efc:	40060613          	addi	a2,a2,1024 # ffffffffc02062f8 <etext+0xa08>
ffffffffc0204f00:	07300593          	li	a1,115
ffffffffc0204f04:	00001517          	auipc	a0,0x1
ffffffffc0204f08:	3d450513          	addi	a0,a0,980 # ffffffffc02062d8 <etext+0x9e8>
ffffffffc0204f0c:	f122                	sd	s0,160(sp)
ffffffffc0204f0e:	e152                	sd	s4,128(sp)
ffffffffc0204f10:	e4ee                	sd	s11,72(sp)
ffffffffc0204f12:	b16fb0ef          	jal	ffffffffc0200228 <__panic>
    current->pgdir = PADDR(mm->pgdir);   // 设置进程的页目录表物理地址
ffffffffc0204f16:	00001617          	auipc	a2,0x1
ffffffffc0204f1a:	74260613          	addi	a2,a2,1858 # ffffffffc0206658 <etext+0xd68>
ffffffffc0204f1e:	34d00593          	li	a1,845
ffffffffc0204f22:	00002517          	auipc	a0,0x2
ffffffffc0204f26:	19650513          	addi	a0,a0,406 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204f2a:	e4ee                	sd	s11,72(sp)
ffffffffc0204f2c:	afcfb0ef          	jal	ffffffffc0200228 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f30:	00002697          	auipc	a3,0x2
ffffffffc0204f34:	49068693          	addi	a3,a3,1168 # ffffffffc02073c0 <etext+0x1ad0>
ffffffffc0204f38:	00001617          	auipc	a2,0x1
ffffffffc0204f3c:	43860613          	addi	a2,a2,1080 # ffffffffc0206370 <etext+0xa80>
ffffffffc0204f40:	34700593          	li	a1,839
ffffffffc0204f44:	00002517          	auipc	a0,0x2
ffffffffc0204f48:	17450513          	addi	a0,a0,372 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204f4c:	e4ee                	sd	s11,72(sp)
ffffffffc0204f4e:	adafb0ef          	jal	ffffffffc0200228 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f52:	00002697          	auipc	a3,0x2
ffffffffc0204f56:	42668693          	addi	a3,a3,1062 # ffffffffc0207378 <etext+0x1a88>
ffffffffc0204f5a:	00001617          	auipc	a2,0x1
ffffffffc0204f5e:	41660613          	addi	a2,a2,1046 # ffffffffc0206370 <etext+0xa80>
ffffffffc0204f62:	34600593          	li	a1,838
ffffffffc0204f66:	00002517          	auipc	a0,0x2
ffffffffc0204f6a:	15250513          	addi	a0,a0,338 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204f6e:	e4ee                	sd	s11,72(sp)
ffffffffc0204f70:	ab8fb0ef          	jal	ffffffffc0200228 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f74:	00002697          	auipc	a3,0x2
ffffffffc0204f78:	3bc68693          	addi	a3,a3,956 # ffffffffc0207330 <etext+0x1a40>
ffffffffc0204f7c:	00001617          	auipc	a2,0x1
ffffffffc0204f80:	3f460613          	addi	a2,a2,1012 # ffffffffc0206370 <etext+0xa80>
ffffffffc0204f84:	34500593          	li	a1,837
ffffffffc0204f88:	00002517          	auipc	a0,0x2
ffffffffc0204f8c:	13050513          	addi	a0,a0,304 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204f90:	e4ee                	sd	s11,72(sp)
ffffffffc0204f92:	a96fb0ef          	jal	ffffffffc0200228 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204f96:	00002697          	auipc	a3,0x2
ffffffffc0204f9a:	35268693          	addi	a3,a3,850 # ffffffffc02072e8 <etext+0x19f8>
ffffffffc0204f9e:	00001617          	auipc	a2,0x1
ffffffffc0204fa2:	3d260613          	addi	a2,a2,978 # ffffffffc0206370 <etext+0xa80>
ffffffffc0204fa6:	34400593          	li	a1,836
ffffffffc0204faa:	00002517          	auipc	a0,0x2
ffffffffc0204fae:	10e50513          	addi	a0,a0,270 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0204fb2:	e4ee                	sd	s11,72(sp)
ffffffffc0204fb4:	a74fb0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0204fb8 <do_yield>:
    current->need_resched = 1;  // 设置重调度标志
ffffffffc0204fb8:	000a2797          	auipc	a5,0xa2
ffffffffc0204fbc:	5887b783          	ld	a5,1416(a5) # ffffffffc02a7540 <current>
ffffffffc0204fc0:	4705                	li	a4,1
}
ffffffffc0204fc2:	4501                	li	a0,0
    current->need_resched = 1;  // 设置重调度标志
ffffffffc0204fc4:	ef98                	sd	a4,24(a5)
}
ffffffffc0204fc6:	8082                	ret

ffffffffc0204fc8 <do_wait>:
    if (code_store != NULL)
ffffffffc0204fc8:	c59d                	beqz	a1,ffffffffc0204ff6 <do_wait+0x2e>
{
ffffffffc0204fca:	1101                	addi	sp,sp,-32
ffffffffc0204fcc:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204fce:	000a2517          	auipc	a0,0xa2
ffffffffc0204fd2:	57253503          	ld	a0,1394(a0) # ffffffffc02a7540 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204fd6:	4685                	li	a3,1
ffffffffc0204fd8:	4611                	li	a2,4
ffffffffc0204fda:	7508                	ld	a0,40(a0)
{
ffffffffc0204fdc:	ec06                	sd	ra,24(sp)
ffffffffc0204fde:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204fe0:	817fc0ef          	jal	ffffffffc02017f6 <user_mem_check>
ffffffffc0204fe4:	6702                	ld	a4,0(sp)
ffffffffc0204fe6:	67a2                	ld	a5,8(sp)
ffffffffc0204fe8:	c909                	beqz	a0,ffffffffc0204ffa <do_wait+0x32>
}
ffffffffc0204fea:	60e2                	ld	ra,24(sp)
ffffffffc0204fec:	85be                	mv	a1,a5
ffffffffc0204fee:	853a                	mv	a0,a4
ffffffffc0204ff0:	6105                	addi	sp,sp,32
ffffffffc0204ff2:	f1aff06f          	j	ffffffffc020470c <do_wait.part.0>
ffffffffc0204ff6:	f16ff06f          	j	ffffffffc020470c <do_wait.part.0>
ffffffffc0204ffa:	60e2                	ld	ra,24(sp)
ffffffffc0204ffc:	5575                	li	a0,-3
ffffffffc0204ffe:	6105                	addi	sp,sp,32
ffffffffc0205000:	8082                	ret

ffffffffc0205002 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0205002:	6789                	lui	a5,0x2
ffffffffc0205004:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205008:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6c0a>
ffffffffc020500a:	06e7e463          	bltu	a5,a4,ffffffffc0205072 <do_kill+0x70>
{
ffffffffc020500e:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205010:	45a9                	li	a1,10
{
ffffffffc0205012:	ec06                	sd	ra,24(sp)
ffffffffc0205014:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205016:	0c5000ef          	jal	ffffffffc02058da <hash32>
ffffffffc020501a:	02051793          	slli	a5,a0,0x20
ffffffffc020501e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205022:	0009e797          	auipc	a5,0x9e
ffffffffc0205026:	49e78793          	addi	a5,a5,1182 # ffffffffc02a34c0 <hash_list>
ffffffffc020502a:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc020502c:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020502e:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0205030:	a029                	j	ffffffffc020503a <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0205032:	f2c52703          	lw	a4,-212(a0)
ffffffffc0205036:	00c70963          	beq	a4,a2,ffffffffc0205048 <do_kill+0x46>
ffffffffc020503a:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc020503c:	fea69be3          	bne	a3,a0,ffffffffc0205032 <do_kill+0x30>
}
ffffffffc0205040:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0205042:	5575                	li	a0,-3
}
ffffffffc0205044:	6105                	addi	sp,sp,32
ffffffffc0205046:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0205048:	fd852703          	lw	a4,-40(a0)
ffffffffc020504c:	00177693          	andi	a3,a4,1
ffffffffc0205050:	e29d                	bnez	a3,ffffffffc0205076 <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205052:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205054:	00176713          	ori	a4,a4,1
ffffffffc0205058:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc020505c:	0006c663          	bltz	a3,ffffffffc0205068 <do_kill+0x66>
            return 0;
ffffffffc0205060:	4501                	li	a0,0
}
ffffffffc0205062:	60e2                	ld	ra,24(sp)
ffffffffc0205064:	6105                	addi	sp,sp,32
ffffffffc0205066:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205068:	f2850513          	addi	a0,a0,-216
ffffffffc020506c:	1c8000ef          	jal	ffffffffc0205234 <wakeup_proc>
ffffffffc0205070:	bfc5                	j	ffffffffc0205060 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc0205072:	5575                	li	a0,-3
}
ffffffffc0205074:	8082                	ret
        return -E_KILLED;
ffffffffc0205076:	555d                	li	a0,-9
ffffffffc0205078:	b7ed                	j	ffffffffc0205062 <do_kill+0x60>

ffffffffc020507a <proc_init>:

// proc_init - 初始化进程管理系统
// 创建第一个内核线程idleproc（空闲进程）和第二个内核线程init_main
// 这是进程系统初始化的核心函数
void proc_init(void)
{
ffffffffc020507a:	1101                	addi	sp,sp,-32
ffffffffc020507c:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc020507e:	000a2797          	auipc	a5,0xa2
ffffffffc0205082:	44278793          	addi	a5,a5,1090 # ffffffffc02a74c0 <proc_list>
ffffffffc0205086:	ec06                	sd	ra,24(sp)
ffffffffc0205088:	e822                	sd	s0,16(sp)
ffffffffc020508a:	e04a                	sd	s2,0(sp)
ffffffffc020508c:	0009e497          	auipc	s1,0x9e
ffffffffc0205090:	43448493          	addi	s1,s1,1076 # ffffffffc02a34c0 <hash_list>
ffffffffc0205094:	e79c                	sd	a5,8(a5)
ffffffffc0205096:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205098:	000a2717          	auipc	a4,0xa2
ffffffffc020509c:	42870713          	addi	a4,a4,1064 # ffffffffc02a74c0 <proc_list>
ffffffffc02050a0:	87a6                	mv	a5,s1
ffffffffc02050a2:	e79c                	sd	a5,8(a5)
ffffffffc02050a4:	e39c                	sd	a5,0(a5)
ffffffffc02050a6:	07c1                	addi	a5,a5,16
ffffffffc02050a8:	fee79de3          	bne	a5,a4,ffffffffc02050a2 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02050ac:	eebfe0ef          	jal	ffffffffc0203f96 <alloc_proc>
ffffffffc02050b0:	000a2917          	auipc	s2,0xa2
ffffffffc02050b4:	4a090913          	addi	s2,s2,1184 # ffffffffc02a7550 <idleproc>
ffffffffc02050b8:	00a93023          	sd	a0,0(s2)
ffffffffc02050bc:	10050363          	beqz	a0,ffffffffc02051c2 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02050c0:	4789                	li	a5,2
ffffffffc02050c2:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02050c4:	00003797          	auipc	a5,0x3
ffffffffc02050c8:	f3c78793          	addi	a5,a5,-196 # ffffffffc0208000 <bootstack>
ffffffffc02050cc:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050ce:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc02050d2:	4785                	li	a5,1
ffffffffc02050d4:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050d6:	4641                	li	a2,16
ffffffffc02050d8:	8522                	mv	a0,s0
ffffffffc02050da:	4581                	li	a1,0
ffffffffc02050dc:	408000ef          	jal	ffffffffc02054e4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050e0:	8522                	mv	a0,s0
ffffffffc02050e2:	463d                	li	a2,15
ffffffffc02050e4:	00002597          	auipc	a1,0x2
ffffffffc02050e8:	33c58593          	addi	a1,a1,828 # ffffffffc0207420 <etext+0x1b30>
ffffffffc02050ec:	40a000ef          	jal	ffffffffc02054f6 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02050f0:	000a2797          	auipc	a5,0xa2
ffffffffc02050f4:	4487a783          	lw	a5,1096(a5) # ffffffffc02a7538 <nr_process>

    current = idleproc;
ffffffffc02050f8:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02050fc:	4601                	li	a2,0
    nr_process++;
ffffffffc02050fe:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205100:	4581                	li	a1,0
ffffffffc0205102:	fffff517          	auipc	a0,0xfffff
ffffffffc0205106:	7ec50513          	addi	a0,a0,2028 # ffffffffc02048ee <init_main>
    current = idleproc;
ffffffffc020510a:	000a2697          	auipc	a3,0xa2
ffffffffc020510e:	42e6bb23          	sd	a4,1078(a3) # ffffffffc02a7540 <current>
    nr_process++;
ffffffffc0205112:	000a2717          	auipc	a4,0xa2
ffffffffc0205116:	42f72323          	sw	a5,1062(a4) # ffffffffc02a7538 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020511a:	c5aff0ef          	jal	ffffffffc0204574 <kernel_thread>
ffffffffc020511e:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205120:	08a05563          	blez	a0,ffffffffc02051aa <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205124:	6789                	lui	a5,0x2
ffffffffc0205126:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6c0a>
ffffffffc0205128:	fff5071b          	addiw	a4,a0,-1
ffffffffc020512c:	02e7e463          	bltu	a5,a4,ffffffffc0205154 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205130:	45a9                	li	a1,10
ffffffffc0205132:	7a8000ef          	jal	ffffffffc02058da <hash32>
ffffffffc0205136:	02051713          	slli	a4,a0,0x20
ffffffffc020513a:	01c75793          	srli	a5,a4,0x1c
ffffffffc020513e:	00f486b3          	add	a3,s1,a5
ffffffffc0205142:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205144:	a029                	j	ffffffffc020514e <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc0205146:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020514a:	04870d63          	beq	a4,s0,ffffffffc02051a4 <proc_init+0x12a>
    return listelm->next;
ffffffffc020514e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205150:	fef69be3          	bne	a3,a5,ffffffffc0205146 <proc_init+0xcc>
    return NULL;
ffffffffc0205154:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205156:	0b478413          	addi	s0,a5,180
ffffffffc020515a:	4641                	li	a2,16
ffffffffc020515c:	4581                	li	a1,0
ffffffffc020515e:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205160:	000a2717          	auipc	a4,0xa2
ffffffffc0205164:	3ef73423          	sd	a5,1000(a4) # ffffffffc02a7548 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205168:	37c000ef          	jal	ffffffffc02054e4 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020516c:	8522                	mv	a0,s0
ffffffffc020516e:	463d                	li	a2,15
ffffffffc0205170:	00002597          	auipc	a1,0x2
ffffffffc0205174:	2d858593          	addi	a1,a1,728 # ffffffffc0207448 <etext+0x1b58>
ffffffffc0205178:	37e000ef          	jal	ffffffffc02054f6 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020517c:	00093783          	ld	a5,0(s2)
ffffffffc0205180:	cfad                	beqz	a5,ffffffffc02051fa <proc_init+0x180>
ffffffffc0205182:	43dc                	lw	a5,4(a5)
ffffffffc0205184:	ebbd                	bnez	a5,ffffffffc02051fa <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205186:	000a2797          	auipc	a5,0xa2
ffffffffc020518a:	3c27b783          	ld	a5,962(a5) # ffffffffc02a7548 <initproc>
ffffffffc020518e:	c7b1                	beqz	a5,ffffffffc02051da <proc_init+0x160>
ffffffffc0205190:	43d8                	lw	a4,4(a5)
ffffffffc0205192:	4785                	li	a5,1
ffffffffc0205194:	04f71363          	bne	a4,a5,ffffffffc02051da <proc_init+0x160>
}
ffffffffc0205198:	60e2                	ld	ra,24(sp)
ffffffffc020519a:	6442                	ld	s0,16(sp)
ffffffffc020519c:	64a2                	ld	s1,8(sp)
ffffffffc020519e:	6902                	ld	s2,0(sp)
ffffffffc02051a0:	6105                	addi	sp,sp,32
ffffffffc02051a2:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02051a4:	f2878793          	addi	a5,a5,-216
ffffffffc02051a8:	b77d                	j	ffffffffc0205156 <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc02051aa:	00002617          	auipc	a2,0x2
ffffffffc02051ae:	27e60613          	addi	a2,a2,638 # ffffffffc0207428 <etext+0x1b38>
ffffffffc02051b2:	4a100593          	li	a1,1185
ffffffffc02051b6:	00002517          	auipc	a0,0x2
ffffffffc02051ba:	f0250513          	addi	a0,a0,-254 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02051be:	86afb0ef          	jal	ffffffffc0200228 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02051c2:	00002617          	auipc	a2,0x2
ffffffffc02051c6:	24660613          	addi	a2,a2,582 # ffffffffc0207408 <etext+0x1b18>
ffffffffc02051ca:	49200593          	li	a1,1170
ffffffffc02051ce:	00002517          	auipc	a0,0x2
ffffffffc02051d2:	eea50513          	addi	a0,a0,-278 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02051d6:	852fb0ef          	jal	ffffffffc0200228 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02051da:	00002697          	auipc	a3,0x2
ffffffffc02051de:	29e68693          	addi	a3,a3,670 # ffffffffc0207478 <etext+0x1b88>
ffffffffc02051e2:	00001617          	auipc	a2,0x1
ffffffffc02051e6:	18e60613          	addi	a2,a2,398 # ffffffffc0206370 <etext+0xa80>
ffffffffc02051ea:	4a800593          	li	a1,1192
ffffffffc02051ee:	00002517          	auipc	a0,0x2
ffffffffc02051f2:	eca50513          	addi	a0,a0,-310 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc02051f6:	832fb0ef          	jal	ffffffffc0200228 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02051fa:	00002697          	auipc	a3,0x2
ffffffffc02051fe:	25668693          	addi	a3,a3,598 # ffffffffc0207450 <etext+0x1b60>
ffffffffc0205202:	00001617          	auipc	a2,0x1
ffffffffc0205206:	16e60613          	addi	a2,a2,366 # ffffffffc0206370 <etext+0xa80>
ffffffffc020520a:	4a700593          	li	a1,1191
ffffffffc020520e:	00002517          	auipc	a0,0x2
ffffffffc0205212:	eaa50513          	addi	a0,a0,-342 # ffffffffc02070b8 <etext+0x17c8>
ffffffffc0205216:	812fb0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc020521a <cpu_idle>:

// cpu_idle - 在kern_init结束时，第一个内核线程idleproc将执行以下工作
// 空闲进程的主要循环，不断检查是否有进程需要重新调度
void cpu_idle(void)
{
ffffffffc020521a:	1141                	addi	sp,sp,-16
ffffffffc020521c:	e022                	sd	s0,0(sp)
ffffffffc020521e:	e406                	sd	ra,8(sp)
ffffffffc0205220:	000a2417          	auipc	s0,0xa2
ffffffffc0205224:	32040413          	addi	s0,s0,800 # ffffffffc02a7540 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205228:	6018                	ld	a4,0(s0)
ffffffffc020522a:	6f1c                	ld	a5,24(a4)
ffffffffc020522c:	dffd                	beqz	a5,ffffffffc020522a <cpu_idle+0x10>
        {
            schedule();
ffffffffc020522e:	09a000ef          	jal	ffffffffc02052c8 <schedule>
ffffffffc0205232:	bfdd                	j	ffffffffc0205228 <cpu_idle+0xe>

ffffffffc0205234 <wakeup_proc>:

// wakeup_proc - 唤醒进程，将其状态设置为可运行
// 清除等待状态，确保进程可以被调度器选中
void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205234:	4118                	lw	a4,0(a0)
{
ffffffffc0205236:	1101                	addi	sp,sp,-32
ffffffffc0205238:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020523a:	478d                	li	a5,3
ffffffffc020523c:	06f70763          	beq	a4,a5,ffffffffc02052aa <wakeup_proc+0x76>
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc0205240:	100027f3          	csrr	a5,sstatus
ffffffffc0205244:	8b89                	andi	a5,a5,2
ffffffffc0205246:	eb91                	bnez	a5,ffffffffc020525a <wakeup_proc+0x26>
    bool intr_flag;
    local_intr_save(intr_flag);  // 关闭中断，确保操作原子性
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205248:	4789                	li	a5,2
ffffffffc020524a:	02f70763          	beq	a4,a5,ffffffffc0205278 <wakeup_proc+0x44>
        {
            warn("wakeup runnable process.\n");  // 警告：尝试唤醒已在运行的进程
        }
    }
    local_intr_restore(intr_flag);  // 恢复中断状态
}
ffffffffc020524e:	60e2                	ld	ra,24(sp)
            proc->state = PROC_RUNNABLE;  // 设置为可运行状态
ffffffffc0205250:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;         // 清除等待状态
ffffffffc0205252:	0e052623          	sw	zero,236(a0)
}
ffffffffc0205256:	6105                	addi	sp,sp,32
ffffffffc0205258:	8082                	ret
        intr_disable();  // 关闭中断
ffffffffc020525a:	e42a                	sd	a0,8(sp)
ffffffffc020525c:	eaefb0ef          	jal	ffffffffc020090a <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205260:	6522                	ld	a0,8(sp)
ffffffffc0205262:	4789                	li	a5,2
ffffffffc0205264:	4118                	lw	a4,0(a0)
ffffffffc0205266:	02f70663          	beq	a4,a5,ffffffffc0205292 <wakeup_proc+0x5e>
            proc->state = PROC_RUNNABLE;  // 设置为可运行状态
ffffffffc020526a:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;         // 清除等待状态
ffffffffc020526c:	0e052623          	sw	zero,236(a0)
}
ffffffffc0205270:	60e2                	ld	ra,24(sp)
ffffffffc0205272:	6105                	addi	sp,sp,32
        intr_enable();  // 重新开启中断
ffffffffc0205274:	e90fb06f          	j	ffffffffc0200904 <intr_enable>
ffffffffc0205278:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");  // 警告：尝试唤醒已在运行的进程
ffffffffc020527a:	00002617          	auipc	a2,0x2
ffffffffc020527e:	25e60613          	addi	a2,a2,606 # ffffffffc02074d8 <etext+0x1be8>
ffffffffc0205282:	45d9                	li	a1,22
ffffffffc0205284:	00002517          	auipc	a0,0x2
ffffffffc0205288:	23c50513          	addi	a0,a0,572 # ffffffffc02074c0 <etext+0x1bd0>
}
ffffffffc020528c:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");  // 警告：尝试唤醒已在运行的进程
ffffffffc020528e:	804fb06f          	j	ffffffffc0200292 <__warn>
ffffffffc0205292:	00002617          	auipc	a2,0x2
ffffffffc0205296:	24660613          	addi	a2,a2,582 # ffffffffc02074d8 <etext+0x1be8>
ffffffffc020529a:	45d9                	li	a1,22
ffffffffc020529c:	00002517          	auipc	a0,0x2
ffffffffc02052a0:	22450513          	addi	a0,a0,548 # ffffffffc02074c0 <etext+0x1bd0>
ffffffffc02052a4:	feffa0ef          	jal	ffffffffc0200292 <__warn>
    if (flag)           // 如果原来中断是开启的
ffffffffc02052a8:	b7e1                	j	ffffffffc0205270 <wakeup_proc+0x3c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052aa:	00002697          	auipc	a3,0x2
ffffffffc02052ae:	1f668693          	addi	a3,a3,502 # ffffffffc02074a0 <etext+0x1bb0>
ffffffffc02052b2:	00001617          	auipc	a2,0x1
ffffffffc02052b6:	0be60613          	addi	a2,a2,190 # ffffffffc0206370 <etext+0xa80>
ffffffffc02052ba:	45ad                	li	a1,11
ffffffffc02052bc:	00002517          	auipc	a0,0x2
ffffffffc02052c0:	20450513          	addi	a0,a0,516 # ffffffffc02074c0 <etext+0x1bd0>
ffffffffc02052c4:	f65fa0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc02052c8 <schedule>:

// schedule - 进程调度器，选择下一个要运行的进程
// 使用轮转调度算法，从当前进程开始扫描进程列表，寻找可运行进程
void schedule(void)
{
ffffffffc02052c8:	1101                	addi	sp,sp,-32
ffffffffc02052ca:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)  // 检查中断是否开启
ffffffffc02052cc:	100027f3          	csrr	a5,sstatus
ffffffffc02052d0:	8b89                	andi	a5,a5,2
ffffffffc02052d2:	4301                	li	t1,0
ffffffffc02052d4:	e3c1                	bnez	a5,ffffffffc0205354 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);  // 关闭中断，保护调度过程
    {
        current->need_resched = 0;  // 清除当前进程的重调度标志
ffffffffc02052d6:	000a2897          	auipc	a7,0xa2
ffffffffc02052da:	26a8b883          	ld	a7,618(a7) # ffffffffc02a7540 <current>
        // 从当前进程开始扫描，如果是idle进程则从列表头开始
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02052de:	000a2517          	auipc	a0,0xa2
ffffffffc02052e2:	27253503          	ld	a0,626(a0) # ffffffffc02a7550 <idleproc>
        current->need_resched = 0;  // 清除当前进程的重调度标志
ffffffffc02052e6:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02052ea:	04a88f63          	beq	a7,a0,ffffffffc0205348 <schedule+0x80>
ffffffffc02052ee:	0c888693          	addi	a3,a7,200
ffffffffc02052f2:	000a2617          	auipc	a2,0xa2
ffffffffc02052f6:	1ce60613          	addi	a2,a2,462 # ffffffffc02a74c0 <proc_list>
        le = last;
ffffffffc02052fa:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02052fc:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)  // 获取下一个进程
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)   // 找到可运行进程
ffffffffc02052fe:	4809                	li	a6,2
ffffffffc0205300:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)  // 获取下一个进程
ffffffffc0205302:	00c78863          	beq	a5,a2,ffffffffc0205312 <schedule+0x4a>
                if (next->state == PROC_RUNNABLE)   // 找到可运行进程
ffffffffc0205306:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020530a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)   // 找到可运行进程
ffffffffc020530e:	03070363          	beq	a4,a6,ffffffffc0205334 <schedule+0x6c>
                {
                    break;
                }
            }
        } while (le != last);  // 扫描完整个列表
ffffffffc0205312:	fef697e3          	bne	a3,a5,ffffffffc0205300 <schedule+0x38>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205316:	ed99                	bnez	a1,ffffffffc0205334 <schedule+0x6c>
        {
            next = idleproc;  // 没有可运行进程，使用idle进程
        }
        next->runs++;          // 增加运行次数统计
ffffffffc0205318:	451c                	lw	a5,8(a0)
ffffffffc020531a:	2785                	addiw	a5,a5,1
ffffffffc020531c:	c51c                	sw	a5,8(a0)
        if (next != current)   // 如果选择了不同进程
ffffffffc020531e:	00a88663          	beq	a7,a0,ffffffffc020532a <schedule+0x62>
ffffffffc0205322:	e41a                	sd	t1,8(sp)
        {
            proc_run(next);   // 执行进程切换
ffffffffc0205324:	de7fe0ef          	jal	ffffffffc020410a <proc_run>
ffffffffc0205328:	6322                	ld	t1,8(sp)
    if (flag)           // 如果原来中断是开启的
ffffffffc020532a:	00031b63          	bnez	t1,ffffffffc0205340 <schedule+0x78>
        }
    }
    local_intr_restore(intr_flag);  // 恢复中断
}
ffffffffc020532e:	60e2                	ld	ra,24(sp)
ffffffffc0205330:	6105                	addi	sp,sp,32
ffffffffc0205332:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc0205334:	4198                	lw	a4,0(a1)
ffffffffc0205336:	4789                	li	a5,2
ffffffffc0205338:	fef710e3          	bne	a4,a5,ffffffffc0205318 <schedule+0x50>
ffffffffc020533c:	852e                	mv	a0,a1
ffffffffc020533e:	bfe9                	j	ffffffffc0205318 <schedule+0x50>
}
ffffffffc0205340:	60e2                	ld	ra,24(sp)
ffffffffc0205342:	6105                	addi	sp,sp,32
        intr_enable();  // 重新开启中断
ffffffffc0205344:	dc0fb06f          	j	ffffffffc0200904 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205348:	000a2617          	auipc	a2,0xa2
ffffffffc020534c:	17860613          	addi	a2,a2,376 # ffffffffc02a74c0 <proc_list>
ffffffffc0205350:	86b2                	mv	a3,a2
ffffffffc0205352:	b765                	j	ffffffffc02052fa <schedule+0x32>
        intr_disable();  // 关闭中断
ffffffffc0205354:	db6fb0ef          	jal	ffffffffc020090a <intr_disable>
        return 1;        // 返回原状态：开启
ffffffffc0205358:	4305                	li	t1,1
ffffffffc020535a:	bfb5                	j	ffffffffc02052d6 <schedule+0xe>

ffffffffc020535c <sys_getpid>:
}

// sys_getpid - SYS_getpid系统调用处理：获取当前进程PID
static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020535c:	000a2797          	auipc	a5,0xa2
ffffffffc0205360:	1e47b783          	ld	a5,484(a5) # ffffffffc02a7540 <current>
}
ffffffffc0205364:	43c8                	lw	a0,4(a5)
ffffffffc0205366:	8082                	ret

ffffffffc0205368 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205368:	4501                	li	a0,0
ffffffffc020536a:	8082                	ret

ffffffffc020536c <sys_putc>:
    cputchar(c);
ffffffffc020536c:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020536e:	1141                	addi	sp,sp,-16
ffffffffc0205370:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205372:	da1fa0ef          	jal	ffffffffc0200112 <cputchar>
}
ffffffffc0205376:	60a2                	ld	ra,8(sp)
ffffffffc0205378:	4501                	li	a0,0
ffffffffc020537a:	0141                	addi	sp,sp,16
ffffffffc020537c:	8082                	ret

ffffffffc020537e <sys_kill>:
    return do_kill(pid);
ffffffffc020537e:	4108                	lw	a0,0(a0)
ffffffffc0205380:	c83ff06f          	j	ffffffffc0205002 <do_kill>

ffffffffc0205384 <sys_yield>:
    return do_yield();
ffffffffc0205384:	c35ff06f          	j	ffffffffc0204fb8 <do_yield>

ffffffffc0205388 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205388:	6d14                	ld	a3,24(a0)
ffffffffc020538a:	6910                	ld	a2,16(a0)
ffffffffc020538c:	650c                	ld	a1,8(a0)
ffffffffc020538e:	6108                	ld	a0,0(a0)
ffffffffc0205390:	e82ff06f          	j	ffffffffc0204a12 <do_execve>

ffffffffc0205394 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205394:	650c                	ld	a1,8(a0)
ffffffffc0205396:	4108                	lw	a0,0(a0)
ffffffffc0205398:	c31ff06f          	j	ffffffffc0204fc8 <do_wait>

ffffffffc020539c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020539c:	000a2797          	auipc	a5,0xa2
ffffffffc02053a0:	1a47b783          	ld	a5,420(a5) # ffffffffc02a7540 <current>
    return do_fork(0, stack, tf);
ffffffffc02053a4:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc02053a6:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc02053a8:	6a0c                	ld	a1,16(a2)
ffffffffc02053aa:	dc7fe06f          	j	ffffffffc0204170 <do_fork>

ffffffffc02053ae <sys_exit>:
    return do_exit(error_code);
ffffffffc02053ae:	4108                	lw	a0,0(a0)
ffffffffc02053b0:	a14ff06f          	j	ffffffffc02045c4 <do_exit>

ffffffffc02053b4 <syscall>:
#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

// syscall - 系统调用分发器，从trapframe提取参数并调用相应处理函数
void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc02053b4:	000a2697          	auipc	a3,0xa2
ffffffffc02053b8:	18c6b683          	ld	a3,396(a3) # ffffffffc02a7540 <current>
syscall(void) {
ffffffffc02053bc:	715d                	addi	sp,sp,-80
ffffffffc02053be:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc02053c0:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc02053c2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];              // 系统调用参数数组
    int num = tf->gpr.a0;         // 系统调用号从a0获取

    if (num >= 0 && num < NUM_SYSCALLS) {  // 检查系统调用号有效性
ffffffffc02053c4:	47fd                	li	a5,31
    int num = tf->gpr.a0;         // 系统调用号从a0获取
ffffffffc02053c6:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {  // 检查系统调用号有效性
ffffffffc02053c8:	02d7ec63          	bltu	a5,a3,ffffffffc0205400 <syscall+0x4c>
        if (syscalls[num] != NULL) {        // 检查处理函数是否存在
ffffffffc02053cc:	00002797          	auipc	a5,0x2
ffffffffc02053d0:	35478793          	addi	a5,a5,852 # ffffffffc0207720 <syscalls>
ffffffffc02053d4:	00369613          	slli	a2,a3,0x3
ffffffffc02053d8:	97b2                	add	a5,a5,a2
ffffffffc02053da:	639c                	ld	a5,0(a5)
ffffffffc02053dc:	c395                	beqz	a5,ffffffffc0205400 <syscall+0x4c>
            // 从trapframe提取参数到arg数组
            arg[0] = tf->gpr.a1;  // 第一个参数
ffffffffc02053de:	7028                	ld	a0,96(s0)
ffffffffc02053e0:	742c                	ld	a1,104(s0)
ffffffffc02053e2:	7830                	ld	a2,112(s0)
ffffffffc02053e4:	7c34                	ld	a3,120(s0)
ffffffffc02053e6:	6c38                	ld	a4,88(s0)
ffffffffc02053e8:	f02a                	sd	a0,32(sp)
ffffffffc02053ea:	f42e                	sd	a1,40(sp)
ffffffffc02053ec:	f832                	sd	a2,48(sp)
ffffffffc02053ee:	fc36                	sd	a3,56(sp)
ffffffffc02053f0:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;  // 第二个参数
            arg[2] = tf->gpr.a3;  // 第三个参数
            arg[3] = tf->gpr.a4;  // 第四个参数
            arg[4] = tf->gpr.a5;  // 第五个参数

            tf->gpr.a0 = syscalls[num](arg);  // 调用处理函数，返回值写入a0
ffffffffc02053f2:	0828                	addi	a0,sp,24
ffffffffc02053f4:	9782                	jalr	a5
    }
    // 无效系统调用，打印调试信息并panic
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02053f6:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);  // 调用处理函数，返回值写入a0
ffffffffc02053f8:	e828                	sd	a0,80(s0)
}
ffffffffc02053fa:	6406                	ld	s0,64(sp)
ffffffffc02053fc:	6161                	addi	sp,sp,80
ffffffffc02053fe:	8082                	ret
    print_trapframe(tf);
ffffffffc0205400:	8522                	mv	a0,s0
ffffffffc0205402:	e436                	sd	a3,8(sp)
ffffffffc0205404:	ef4fb0ef          	jal	ffffffffc0200af8 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205408:	000a2797          	auipc	a5,0xa2
ffffffffc020540c:	1387b783          	ld	a5,312(a5) # ffffffffc02a7540 <current>
ffffffffc0205410:	66a2                	ld	a3,8(sp)
ffffffffc0205412:	00002617          	auipc	a2,0x2
ffffffffc0205416:	0e660613          	addi	a2,a2,230 # ffffffffc02074f8 <etext+0x1c08>
ffffffffc020541a:	43d8                	lw	a4,4(a5)
ffffffffc020541c:	07000593          	li	a1,112
ffffffffc0205420:	0b478793          	addi	a5,a5,180
ffffffffc0205424:	00002517          	auipc	a0,0x2
ffffffffc0205428:	10450513          	addi	a0,a0,260 # ffffffffc0207528 <etext+0x1c38>
ffffffffc020542c:	dfdfa0ef          	jal	ffffffffc0200228 <__panic>

ffffffffc0205430 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0205430:	00054783          	lbu	a5,0(a0)
ffffffffc0205434:	cb81                	beqz	a5,ffffffffc0205444 <strlen+0x14>
    size_t cnt = 0;
ffffffffc0205436:	4781                	li	a5,0
        cnt ++;
ffffffffc0205438:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020543a:	00f50733          	add	a4,a0,a5
ffffffffc020543e:	00074703          	lbu	a4,0(a4)
ffffffffc0205442:	fb7d                	bnez	a4,ffffffffc0205438 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0205444:	853e                	mv	a0,a5
ffffffffc0205446:	8082                	ret

ffffffffc0205448 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205448:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020544a:	e589                	bnez	a1,ffffffffc0205454 <strnlen+0xc>
ffffffffc020544c:	a811                	j	ffffffffc0205460 <strnlen+0x18>
        cnt ++;
ffffffffc020544e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205450:	00f58863          	beq	a1,a5,ffffffffc0205460 <strnlen+0x18>
ffffffffc0205454:	00f50733          	add	a4,a0,a5
ffffffffc0205458:	00074703          	lbu	a4,0(a4)
ffffffffc020545c:	fb6d                	bnez	a4,ffffffffc020544e <strnlen+0x6>
ffffffffc020545e:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0205460:	852e                	mv	a0,a1
ffffffffc0205462:	8082                	ret

ffffffffc0205464 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0205464:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0205466:	0005c703          	lbu	a4,0(a1)
ffffffffc020546a:	0585                	addi	a1,a1,1
ffffffffc020546c:	0785                	addi	a5,a5,1
ffffffffc020546e:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0205472:	fb75                	bnez	a4,ffffffffc0205466 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0205474:	8082                	ret

ffffffffc0205476 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0205476:	00054783          	lbu	a5,0(a0)
ffffffffc020547a:	e791                	bnez	a5,ffffffffc0205486 <strcmp+0x10>
ffffffffc020547c:	a01d                	j	ffffffffc02054a2 <strcmp+0x2c>
ffffffffc020547e:	00054783          	lbu	a5,0(a0)
ffffffffc0205482:	cb99                	beqz	a5,ffffffffc0205498 <strcmp+0x22>
ffffffffc0205484:	0585                	addi	a1,a1,1
ffffffffc0205486:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc020548a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020548c:	fef709e3          	beq	a4,a5,ffffffffc020547e <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205490:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205494:	9d19                	subw	a0,a0,a4
ffffffffc0205496:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205498:	0015c703          	lbu	a4,1(a1)
ffffffffc020549c:	4501                	li	a0,0
}
ffffffffc020549e:	9d19                	subw	a0,a0,a4
ffffffffc02054a0:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02054a2:	0005c703          	lbu	a4,0(a1)
ffffffffc02054a6:	4501                	li	a0,0
ffffffffc02054a8:	b7f5                	j	ffffffffc0205494 <strcmp+0x1e>

ffffffffc02054aa <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02054aa:	ce01                	beqz	a2,ffffffffc02054c2 <strncmp+0x18>
ffffffffc02054ac:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02054b0:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02054b2:	cb91                	beqz	a5,ffffffffc02054c6 <strncmp+0x1c>
ffffffffc02054b4:	0005c703          	lbu	a4,0(a1)
ffffffffc02054b8:	00f71763          	bne	a4,a5,ffffffffc02054c6 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc02054bc:	0505                	addi	a0,a0,1
ffffffffc02054be:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02054c0:	f675                	bnez	a2,ffffffffc02054ac <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02054c2:	4501                	li	a0,0
ffffffffc02054c4:	8082                	ret
ffffffffc02054c6:	00054503          	lbu	a0,0(a0)
ffffffffc02054ca:	0005c783          	lbu	a5,0(a1)
ffffffffc02054ce:	9d1d                	subw	a0,a0,a5
}
ffffffffc02054d0:	8082                	ret

ffffffffc02054d2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02054d2:	a021                	j	ffffffffc02054da <strchr+0x8>
        if (*s == c) {
ffffffffc02054d4:	00f58763          	beq	a1,a5,ffffffffc02054e2 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc02054d8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02054da:	00054783          	lbu	a5,0(a0)
ffffffffc02054de:	fbfd                	bnez	a5,ffffffffc02054d4 <strchr+0x2>
    }
    return NULL;
ffffffffc02054e0:	4501                	li	a0,0
}
ffffffffc02054e2:	8082                	ret

ffffffffc02054e4 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02054e4:	ca01                	beqz	a2,ffffffffc02054f4 <memset+0x10>
ffffffffc02054e6:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02054e8:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02054ea:	0785                	addi	a5,a5,1
ffffffffc02054ec:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02054f0:	fef61de3          	bne	a2,a5,ffffffffc02054ea <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02054f4:	8082                	ret

ffffffffc02054f6 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02054f6:	ca19                	beqz	a2,ffffffffc020550c <memcpy+0x16>
ffffffffc02054f8:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02054fa:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02054fc:	0005c703          	lbu	a4,0(a1)
ffffffffc0205500:	0585                	addi	a1,a1,1
ffffffffc0205502:	0785                	addi	a5,a5,1
ffffffffc0205504:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205508:	feb61ae3          	bne	a2,a1,ffffffffc02054fc <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020550c:	8082                	ret

ffffffffc020550e <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020550e:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205510:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205514:	f022                	sd	s0,32(sp)
ffffffffc0205516:	ec26                	sd	s1,24(sp)
ffffffffc0205518:	e84a                	sd	s2,16(sp)
ffffffffc020551a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020551c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205520:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205522:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205526:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020552a:	84aa                	mv	s1,a0
ffffffffc020552c:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc020552e:	03067d63          	bgeu	a2,a6,ffffffffc0205568 <printnum+0x5a>
ffffffffc0205532:	e44e                	sd	s3,8(sp)
ffffffffc0205534:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0205536:	4785                	li	a5,1
ffffffffc0205538:	00e7d763          	bge	a5,a4,ffffffffc0205546 <printnum+0x38>
            putch(padc, putdat);
ffffffffc020553c:	85ca                	mv	a1,s2
ffffffffc020553e:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0205540:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205542:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205544:	fc65                	bnez	s0,ffffffffc020553c <printnum+0x2e>
ffffffffc0205546:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205548:	00002797          	auipc	a5,0x2
ffffffffc020554c:	ff878793          	addi	a5,a5,-8 # ffffffffc0207540 <etext+0x1c50>
ffffffffc0205550:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205552:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205554:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0205558:	70a2                	ld	ra,40(sp)
ffffffffc020555a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020555c:	85ca                	mv	a1,s2
ffffffffc020555e:	87a6                	mv	a5,s1
}
ffffffffc0205560:	6942                	ld	s2,16(sp)
ffffffffc0205562:	64e2                	ld	s1,24(sp)
ffffffffc0205564:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205566:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205568:	03065633          	divu	a2,a2,a6
ffffffffc020556c:	8722                	mv	a4,s0
ffffffffc020556e:	fa1ff0ef          	jal	ffffffffc020550e <printnum>
ffffffffc0205572:	bfd9                	j	ffffffffc0205548 <printnum+0x3a>

ffffffffc0205574 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205574:	7119                	addi	sp,sp,-128
ffffffffc0205576:	f4a6                	sd	s1,104(sp)
ffffffffc0205578:	f0ca                	sd	s2,96(sp)
ffffffffc020557a:	ecce                	sd	s3,88(sp)
ffffffffc020557c:	e8d2                	sd	s4,80(sp)
ffffffffc020557e:	e4d6                	sd	s5,72(sp)
ffffffffc0205580:	e0da                	sd	s6,64(sp)
ffffffffc0205582:	f862                	sd	s8,48(sp)
ffffffffc0205584:	fc86                	sd	ra,120(sp)
ffffffffc0205586:	f8a2                	sd	s0,112(sp)
ffffffffc0205588:	fc5e                	sd	s7,56(sp)
ffffffffc020558a:	f466                	sd	s9,40(sp)
ffffffffc020558c:	f06a                	sd	s10,32(sp)
ffffffffc020558e:	ec6e                	sd	s11,24(sp)
ffffffffc0205590:	84aa                	mv	s1,a0
ffffffffc0205592:	8c32                	mv	s8,a2
ffffffffc0205594:	8a36                	mv	s4,a3
ffffffffc0205596:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205598:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020559c:	05500b13          	li	s6,85
ffffffffc02055a0:	00002a97          	auipc	s5,0x2
ffffffffc02055a4:	280a8a93          	addi	s5,s5,640 # ffffffffc0207820 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02055a8:	000c4503          	lbu	a0,0(s8)
ffffffffc02055ac:	001c0413          	addi	s0,s8,1
ffffffffc02055b0:	01350a63          	beq	a0,s3,ffffffffc02055c4 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc02055b4:	cd0d                	beqz	a0,ffffffffc02055ee <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc02055b6:	85ca                	mv	a1,s2
ffffffffc02055b8:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02055ba:	00044503          	lbu	a0,0(s0)
ffffffffc02055be:	0405                	addi	s0,s0,1
ffffffffc02055c0:	ff351ae3          	bne	a0,s3,ffffffffc02055b4 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc02055c4:	5cfd                	li	s9,-1
ffffffffc02055c6:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc02055c8:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02055cc:	4b81                	li	s7,0
ffffffffc02055ce:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055d0:	00044683          	lbu	a3,0(s0)
ffffffffc02055d4:	00140c13          	addi	s8,s0,1
ffffffffc02055d8:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02055dc:	0ff5f593          	zext.b	a1,a1
ffffffffc02055e0:	02bb6663          	bltu	s6,a1,ffffffffc020560c <vprintfmt+0x98>
ffffffffc02055e4:	058a                	slli	a1,a1,0x2
ffffffffc02055e6:	95d6                	add	a1,a1,s5
ffffffffc02055e8:	4198                	lw	a4,0(a1)
ffffffffc02055ea:	9756                	add	a4,a4,s5
ffffffffc02055ec:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02055ee:	70e6                	ld	ra,120(sp)
ffffffffc02055f0:	7446                	ld	s0,112(sp)
ffffffffc02055f2:	74a6                	ld	s1,104(sp)
ffffffffc02055f4:	7906                	ld	s2,96(sp)
ffffffffc02055f6:	69e6                	ld	s3,88(sp)
ffffffffc02055f8:	6a46                	ld	s4,80(sp)
ffffffffc02055fa:	6aa6                	ld	s5,72(sp)
ffffffffc02055fc:	6b06                	ld	s6,64(sp)
ffffffffc02055fe:	7be2                	ld	s7,56(sp)
ffffffffc0205600:	7c42                	ld	s8,48(sp)
ffffffffc0205602:	7ca2                	ld	s9,40(sp)
ffffffffc0205604:	7d02                	ld	s10,32(sp)
ffffffffc0205606:	6de2                	ld	s11,24(sp)
ffffffffc0205608:	6109                	addi	sp,sp,128
ffffffffc020560a:	8082                	ret
            putch('%', putdat);
ffffffffc020560c:	85ca                	mv	a1,s2
ffffffffc020560e:	02500513          	li	a0,37
ffffffffc0205612:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0205614:	fff44783          	lbu	a5,-1(s0)
ffffffffc0205618:	02500713          	li	a4,37
ffffffffc020561c:	8c22                	mv	s8,s0
ffffffffc020561e:	f8e785e3          	beq	a5,a4,ffffffffc02055a8 <vprintfmt+0x34>
ffffffffc0205622:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0205626:	1c7d                	addi	s8,s8,-1
ffffffffc0205628:	fee79de3          	bne	a5,a4,ffffffffc0205622 <vprintfmt+0xae>
ffffffffc020562c:	bfb5                	j	ffffffffc02055a8 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc020562e:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0205632:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc0205634:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0205638:	fd06071b          	addiw	a4,a2,-48
ffffffffc020563c:	24e56a63          	bltu	a0,a4,ffffffffc0205890 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc0205640:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205642:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc0205644:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0205648:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020564c:	0197073b          	addw	a4,a4,s9
ffffffffc0205650:	0017171b          	slliw	a4,a4,0x1
ffffffffc0205654:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0205656:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020565a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020565c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0205660:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc0205664:	feb570e3          	bgeu	a0,a1,ffffffffc0205644 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0205668:	f60d54e3          	bgez	s10,ffffffffc02055d0 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc020566c:	8d66                	mv	s10,s9
ffffffffc020566e:	5cfd                	li	s9,-1
ffffffffc0205670:	b785                	j	ffffffffc02055d0 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205672:	8db6                	mv	s11,a3
ffffffffc0205674:	8462                	mv	s0,s8
ffffffffc0205676:	bfa9                	j	ffffffffc02055d0 <vprintfmt+0x5c>
ffffffffc0205678:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc020567a:	4b85                	li	s7,1
            goto reswitch;
ffffffffc020567c:	bf91                	j	ffffffffc02055d0 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc020567e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205680:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205684:	00f74463          	blt	a4,a5,ffffffffc020568c <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0205688:	1a078763          	beqz	a5,ffffffffc0205836 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc020568c:	000a3603          	ld	a2,0(s4)
ffffffffc0205690:	46c1                	li	a3,16
ffffffffc0205692:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205694:	000d879b          	sext.w	a5,s11
ffffffffc0205698:	876a                	mv	a4,s10
ffffffffc020569a:	85ca                	mv	a1,s2
ffffffffc020569c:	8526                	mv	a0,s1
ffffffffc020569e:	e71ff0ef          	jal	ffffffffc020550e <printnum>
            break;
ffffffffc02056a2:	b719                	j	ffffffffc02055a8 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc02056a4:	000a2503          	lw	a0,0(s4)
ffffffffc02056a8:	85ca                	mv	a1,s2
ffffffffc02056aa:	0a21                	addi	s4,s4,8
ffffffffc02056ac:	9482                	jalr	s1
            break;
ffffffffc02056ae:	bded                	j	ffffffffc02055a8 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02056b0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02056b2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02056b6:	00f74463          	blt	a4,a5,ffffffffc02056be <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02056ba:	16078963          	beqz	a5,ffffffffc020582c <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc02056be:	000a3603          	ld	a2,0(s4)
ffffffffc02056c2:	46a9                	li	a3,10
ffffffffc02056c4:	8a2e                	mv	s4,a1
ffffffffc02056c6:	b7f9                	j	ffffffffc0205694 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc02056c8:	85ca                	mv	a1,s2
ffffffffc02056ca:	03000513          	li	a0,48
ffffffffc02056ce:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc02056d0:	85ca                	mv	a1,s2
ffffffffc02056d2:	07800513          	li	a0,120
ffffffffc02056d6:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02056d8:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02056dc:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02056de:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02056e0:	bf55                	j	ffffffffc0205694 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc02056e2:	85ca                	mv	a1,s2
ffffffffc02056e4:	02500513          	li	a0,37
ffffffffc02056e8:	9482                	jalr	s1
            break;
ffffffffc02056ea:	bd7d                	j	ffffffffc02055a8 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02056ec:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056f0:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02056f2:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02056f4:	bf95                	j	ffffffffc0205668 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc02056f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02056f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02056fc:	00f74463          	blt	a4,a5,ffffffffc0205704 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0205700:	12078163          	beqz	a5,ffffffffc0205822 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc0205704:	000a3603          	ld	a2,0(s4)
ffffffffc0205708:	46a1                	li	a3,8
ffffffffc020570a:	8a2e                	mv	s4,a1
ffffffffc020570c:	b761                	j	ffffffffc0205694 <vprintfmt+0x120>
            if (width < 0)
ffffffffc020570e:	876a                	mv	a4,s10
ffffffffc0205710:	000d5363          	bgez	s10,ffffffffc0205716 <vprintfmt+0x1a2>
ffffffffc0205714:	4701                	li	a4,0
ffffffffc0205716:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020571a:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc020571c:	bd55                	j	ffffffffc02055d0 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc020571e:	000d841b          	sext.w	s0,s11
ffffffffc0205722:	fd340793          	addi	a5,s0,-45
ffffffffc0205726:	00f037b3          	snez	a5,a5
ffffffffc020572a:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020572e:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc0205732:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205734:	008a0793          	addi	a5,s4,8
ffffffffc0205738:	e43e                	sd	a5,8(sp)
ffffffffc020573a:	100d8c63          	beqz	s11,ffffffffc0205852 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc020573e:	12071363          	bnez	a4,ffffffffc0205864 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205742:	000dc783          	lbu	a5,0(s11)
ffffffffc0205746:	0007851b          	sext.w	a0,a5
ffffffffc020574a:	c78d                	beqz	a5,ffffffffc0205774 <vprintfmt+0x200>
ffffffffc020574c:	0d85                	addi	s11,s11,1
ffffffffc020574e:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205750:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205754:	000cc563          	bltz	s9,ffffffffc020575e <vprintfmt+0x1ea>
ffffffffc0205758:	3cfd                	addiw	s9,s9,-1
ffffffffc020575a:	008c8d63          	beq	s9,s0,ffffffffc0205774 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020575e:	020b9663          	bnez	s7,ffffffffc020578a <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0205762:	85ca                	mv	a1,s2
ffffffffc0205764:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205766:	000dc783          	lbu	a5,0(s11)
ffffffffc020576a:	0d85                	addi	s11,s11,1
ffffffffc020576c:	3d7d                	addiw	s10,s10,-1
ffffffffc020576e:	0007851b          	sext.w	a0,a5
ffffffffc0205772:	f3ed                	bnez	a5,ffffffffc0205754 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0205774:	01a05963          	blez	s10,ffffffffc0205786 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0205778:	85ca                	mv	a1,s2
ffffffffc020577a:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc020577e:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0205780:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0205782:	fe0d1be3          	bnez	s10,ffffffffc0205778 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205786:	6a22                	ld	s4,8(sp)
ffffffffc0205788:	b505                	j	ffffffffc02055a8 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020578a:	3781                	addiw	a5,a5,-32
ffffffffc020578c:	fcfa7be3          	bgeu	s4,a5,ffffffffc0205762 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0205790:	03f00513          	li	a0,63
ffffffffc0205794:	85ca                	mv	a1,s2
ffffffffc0205796:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205798:	000dc783          	lbu	a5,0(s11)
ffffffffc020579c:	0d85                	addi	s11,s11,1
ffffffffc020579e:	3d7d                	addiw	s10,s10,-1
ffffffffc02057a0:	0007851b          	sext.w	a0,a5
ffffffffc02057a4:	dbe1                	beqz	a5,ffffffffc0205774 <vprintfmt+0x200>
ffffffffc02057a6:	fa0cd9e3          	bgez	s9,ffffffffc0205758 <vprintfmt+0x1e4>
ffffffffc02057aa:	b7c5                	j	ffffffffc020578a <vprintfmt+0x216>
            if (err < 0) {
ffffffffc02057ac:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02057b0:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc02057b2:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02057b4:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc02057b8:	8fb9                	xor	a5,a5,a4
ffffffffc02057ba:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02057be:	02d64563          	blt	a2,a3,ffffffffc02057e8 <vprintfmt+0x274>
ffffffffc02057c2:	00002797          	auipc	a5,0x2
ffffffffc02057c6:	1b678793          	addi	a5,a5,438 # ffffffffc0207978 <error_string>
ffffffffc02057ca:	00369713          	slli	a4,a3,0x3
ffffffffc02057ce:	97ba                	add	a5,a5,a4
ffffffffc02057d0:	639c                	ld	a5,0(a5)
ffffffffc02057d2:	cb99                	beqz	a5,ffffffffc02057e8 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc02057d4:	86be                	mv	a3,a5
ffffffffc02057d6:	00000617          	auipc	a2,0x0
ffffffffc02057da:	14260613          	addi	a2,a2,322 # ffffffffc0205918 <etext+0x28>
ffffffffc02057de:	85ca                	mv	a1,s2
ffffffffc02057e0:	8526                	mv	a0,s1
ffffffffc02057e2:	0d8000ef          	jal	ffffffffc02058ba <printfmt>
ffffffffc02057e6:	b3c9                	j	ffffffffc02055a8 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02057e8:	00002617          	auipc	a2,0x2
ffffffffc02057ec:	d7860613          	addi	a2,a2,-648 # ffffffffc0207560 <etext+0x1c70>
ffffffffc02057f0:	85ca                	mv	a1,s2
ffffffffc02057f2:	8526                	mv	a0,s1
ffffffffc02057f4:	0c6000ef          	jal	ffffffffc02058ba <printfmt>
ffffffffc02057f8:	bb45                	j	ffffffffc02055a8 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02057fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057fc:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0205800:	00f74363          	blt	a4,a5,ffffffffc0205806 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc0205804:	cf81                	beqz	a5,ffffffffc020581c <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0205806:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020580a:	02044b63          	bltz	s0,ffffffffc0205840 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc020580e:	8622                	mv	a2,s0
ffffffffc0205810:	8a5e                	mv	s4,s7
ffffffffc0205812:	46a9                	li	a3,10
ffffffffc0205814:	b541                	j	ffffffffc0205694 <vprintfmt+0x120>
            lflag ++;
ffffffffc0205816:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205818:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc020581a:	bb5d                	j	ffffffffc02055d0 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc020581c:	000a2403          	lw	s0,0(s4)
ffffffffc0205820:	b7ed                	j	ffffffffc020580a <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0205822:	000a6603          	lwu	a2,0(s4)
ffffffffc0205826:	46a1                	li	a3,8
ffffffffc0205828:	8a2e                	mv	s4,a1
ffffffffc020582a:	b5ad                	j	ffffffffc0205694 <vprintfmt+0x120>
ffffffffc020582c:	000a6603          	lwu	a2,0(s4)
ffffffffc0205830:	46a9                	li	a3,10
ffffffffc0205832:	8a2e                	mv	s4,a1
ffffffffc0205834:	b585                	j	ffffffffc0205694 <vprintfmt+0x120>
ffffffffc0205836:	000a6603          	lwu	a2,0(s4)
ffffffffc020583a:	46c1                	li	a3,16
ffffffffc020583c:	8a2e                	mv	s4,a1
ffffffffc020583e:	bd99                	j	ffffffffc0205694 <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0205840:	85ca                	mv	a1,s2
ffffffffc0205842:	02d00513          	li	a0,45
ffffffffc0205846:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0205848:	40800633          	neg	a2,s0
ffffffffc020584c:	8a5e                	mv	s4,s7
ffffffffc020584e:	46a9                	li	a3,10
ffffffffc0205850:	b591                	j	ffffffffc0205694 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0205852:	e329                	bnez	a4,ffffffffc0205894 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205854:	02800793          	li	a5,40
ffffffffc0205858:	853e                	mv	a0,a5
ffffffffc020585a:	00002d97          	auipc	s11,0x2
ffffffffc020585e:	cffd8d93          	addi	s11,s11,-769 # ffffffffc0207559 <etext+0x1c69>
ffffffffc0205862:	b5f5                	j	ffffffffc020574e <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205864:	85e6                	mv	a1,s9
ffffffffc0205866:	856e                	mv	a0,s11
ffffffffc0205868:	be1ff0ef          	jal	ffffffffc0205448 <strnlen>
ffffffffc020586c:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0205870:	01a05863          	blez	s10,ffffffffc0205880 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0205874:	85ca                	mv	a1,s2
ffffffffc0205876:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205878:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc020587a:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020587c:	fe0d1ce3          	bnez	s10,ffffffffc0205874 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205880:	000dc783          	lbu	a5,0(s11)
ffffffffc0205884:	0007851b          	sext.w	a0,a5
ffffffffc0205888:	ec0792e3          	bnez	a5,ffffffffc020574c <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020588c:	6a22                	ld	s4,8(sp)
ffffffffc020588e:	bb29                	j	ffffffffc02055a8 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205890:	8462                	mv	s0,s8
ffffffffc0205892:	bbd9                	j	ffffffffc0205668 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205894:	85e6                	mv	a1,s9
ffffffffc0205896:	00002517          	auipc	a0,0x2
ffffffffc020589a:	cc250513          	addi	a0,a0,-830 # ffffffffc0207558 <etext+0x1c68>
ffffffffc020589e:	babff0ef          	jal	ffffffffc0205448 <strnlen>
ffffffffc02058a2:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02058a6:	02800793          	li	a5,40
                p = "(null)";
ffffffffc02058aa:	00002d97          	auipc	s11,0x2
ffffffffc02058ae:	caed8d93          	addi	s11,s11,-850 # ffffffffc0207558 <etext+0x1c68>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02058b2:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02058b4:	fda040e3          	bgtz	s10,ffffffffc0205874 <vprintfmt+0x300>
ffffffffc02058b8:	bd51                	j	ffffffffc020574c <vprintfmt+0x1d8>

ffffffffc02058ba <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02058ba:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02058bc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02058c0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02058c2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02058c4:	ec06                	sd	ra,24(sp)
ffffffffc02058c6:	f83a                	sd	a4,48(sp)
ffffffffc02058c8:	fc3e                	sd	a5,56(sp)
ffffffffc02058ca:	e0c2                	sd	a6,64(sp)
ffffffffc02058cc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02058ce:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02058d0:	ca5ff0ef          	jal	ffffffffc0205574 <vprintfmt>
}
ffffffffc02058d4:	60e2                	ld	ra,24(sp)
ffffffffc02058d6:	6161                	addi	sp,sp,80
ffffffffc02058d8:	8082                	ret

ffffffffc02058da <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02058da:	9e3707b7          	lui	a5,0x9e370
ffffffffc02058de:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_cowtest_out_size+0xffffffff9e363e09>
ffffffffc02058e0:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc02058e4:	02000513          	li	a0,32
ffffffffc02058e8:	9d0d                	subw	a0,a0,a1
}
ffffffffc02058ea:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02058ee:	8082                	ret
