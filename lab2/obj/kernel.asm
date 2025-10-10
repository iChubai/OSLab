
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
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d828293          	addi	t0,t0,216 # ffffffffc02000d8 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00002517          	auipc	a0,0x2
ffffffffc0200050:	d2c50513          	addi	a0,a0,-724 # ffffffffc0201d78 <etext+0x4>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00002517          	auipc	a0,0x2
ffffffffc0200066:	d3650513          	addi	a0,a0,-714 # ffffffffc0201d98 <etext+0x24>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	d0658593          	addi	a1,a1,-762 # ffffffffc0201d74 <etext>
ffffffffc0200076:	00002517          	auipc	a0,0x2
ffffffffc020007a:	d4250513          	addi	a0,a0,-702 # ffffffffc0201db8 <etext+0x44>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9e58593          	addi	a1,a1,-98 # ffffffffc0206020 <caches>
ffffffffc020008a:	00002517          	auipc	a0,0x2
ffffffffc020008e:	d4e50513          	addi	a0,a0,-690 # ffffffffc0201dd8 <etext+0x64>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00008597          	auipc	a1,0x8
ffffffffc020009a:	26258593          	addi	a1,a1,610 # ffffffffc02082f8 <end>
ffffffffc020009e:	00002517          	auipc	a0,0x2
ffffffffc02000a2:	d5a50513          	addi	a0,a0,-678 # ffffffffc0201df8 <etext+0x84>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00008597          	auipc	a1,0x8
ffffffffc02000ae:	64d58593          	addi	a1,a1,1613 # ffffffffc02086f7 <end+0x3ff>
ffffffffc02000b2:	00000797          	auipc	a5,0x0
ffffffffc02000b6:	02678793          	addi	a5,a5,38 # ffffffffc02000d8 <kern_init>
ffffffffc02000ba:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000be:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c8:	95be                	add	a1,a1,a5
ffffffffc02000ca:	85a9                	srai	a1,a1,0xa
ffffffffc02000cc:	00002517          	auipc	a0,0x2
ffffffffc02000d0:	d4c50513          	addi	a0,a0,-692 # ffffffffc0201e18 <etext+0xa4>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00006517          	auipc	a0,0x6
ffffffffc02000dc:	f4850513          	addi	a0,a0,-184 # ffffffffc0206020 <caches>
ffffffffc02000e0:	00008617          	auipc	a2,0x8
ffffffffc02000e4:	21860613          	addi	a2,a2,536 # ffffffffc02082f8 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	06b010ef          	jal	ra,ffffffffc020195a <memset>
    dtb_init();
ffffffffc02000f4:	122000ef          	jal	ra,ffffffffc0200216 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	4ce000ef          	jal	ra,ffffffffc02005c6 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00002517          	auipc	a0,0x2
ffffffffc0200100:	d4c50513          	addi	a0,a0,-692 # ffffffffc0201e48 <etext+0xd4>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	4dc000ef          	jal	ra,ffffffffc02005e8 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc0200110:	a001                	j	ffffffffc0200110 <kern_init+0x38>

ffffffffc0200112 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200112:	1141                	addi	sp,sp,-16
ffffffffc0200114:	e022                	sd	s0,0(sp)
ffffffffc0200116:	e406                	sd	ra,8(sp)
ffffffffc0200118:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020011a:	4ae000ef          	jal	ra,ffffffffc02005c8 <cons_putc>
    (*cnt) ++;
ffffffffc020011e:	401c                	lw	a5,0(s0)
}
ffffffffc0200120:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200122:	2785                	addiw	a5,a5,1
ffffffffc0200124:	c01c                	sw	a5,0(s0)
}
ffffffffc0200126:	6402                	ld	s0,0(sp)
ffffffffc0200128:	0141                	addi	sp,sp,16
ffffffffc020012a:	8082                	ret

ffffffffc020012c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012c:	1101                	addi	sp,sp,-32
ffffffffc020012e:	862a                	mv	a2,a0
ffffffffc0200130:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200132:	00000517          	auipc	a0,0x0
ffffffffc0200136:	fe050513          	addi	a0,a0,-32 # ffffffffc0200112 <cputch>
ffffffffc020013a:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013c:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013e:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200140:	099010ef          	jal	ra,ffffffffc02019d8 <vprintfmt>
    return cnt;
}
ffffffffc0200144:	60e2                	ld	ra,24(sp)
ffffffffc0200146:	4532                	lw	a0,12(sp)
ffffffffc0200148:	6105                	addi	sp,sp,32
ffffffffc020014a:	8082                	ret

ffffffffc020014c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200152:	8e2a                	mv	t3,a0
ffffffffc0200154:	f42e                	sd	a1,40(sp)
ffffffffc0200156:	f832                	sd	a2,48(sp)
ffffffffc0200158:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb850513          	addi	a0,a0,-72 # ffffffffc0200112 <cputch>
ffffffffc0200162:	004c                	addi	a1,sp,4
ffffffffc0200164:	869a                	mv	a3,t1
ffffffffc0200166:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc0200168:	ec06                	sd	ra,24(sp)
ffffffffc020016a:	e0ba                	sd	a4,64(sp)
ffffffffc020016c:	e4be                	sd	a5,72(sp)
ffffffffc020016e:	e8c2                	sd	a6,80(sp)
ffffffffc0200170:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc0200172:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc0200174:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200176:	063010ef          	jal	ra,ffffffffc02019d8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc020017a:	60e2                	ld	ra,24(sp)
ffffffffc020017c:	4512                	lw	a0,4(sp)
ffffffffc020017e:	6125                	addi	sp,sp,96
ffffffffc0200180:	8082                	ret

ffffffffc0200182 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200182:	1101                	addi	sp,sp,-32
ffffffffc0200184:	e822                	sd	s0,16(sp)
ffffffffc0200186:	ec06                	sd	ra,24(sp)
ffffffffc0200188:	e426                	sd	s1,8(sp)
ffffffffc020018a:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020018c:	00054503          	lbu	a0,0(a0)
ffffffffc0200190:	c51d                	beqz	a0,ffffffffc02001be <cputs+0x3c>
ffffffffc0200192:	0405                	addi	s0,s0,1
ffffffffc0200194:	4485                	li	s1,1
ffffffffc0200196:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200198:	430000ef          	jal	ra,ffffffffc02005c8 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020019c:	00044503          	lbu	a0,0(s0)
ffffffffc02001a0:	008487bb          	addw	a5,s1,s0
ffffffffc02001a4:	0405                	addi	s0,s0,1
ffffffffc02001a6:	f96d                	bnez	a0,ffffffffc0200198 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a8:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ac:	4529                	li	a0,10
ffffffffc02001ae:	41a000ef          	jal	ra,ffffffffc02005c8 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b2:	60e2                	ld	ra,24(sp)
ffffffffc02001b4:	8522                	mv	a0,s0
ffffffffc02001b6:	6442                	ld	s0,16(sp)
ffffffffc02001b8:	64a2                	ld	s1,8(sp)
ffffffffc02001ba:	6105                	addi	sp,sp,32
ffffffffc02001bc:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001be:	4405                	li	s0,1
ffffffffc02001c0:	b7f5                	j	ffffffffc02001ac <cputs+0x2a>

ffffffffc02001c2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c2:	00008317          	auipc	t1,0x8
ffffffffc02001c6:	0e630313          	addi	t1,t1,230 # ffffffffc02082a8 <is_panic>
ffffffffc02001ca:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001ce:	715d                	addi	sp,sp,-80
ffffffffc02001d0:	ec06                	sd	ra,24(sp)
ffffffffc02001d2:	e822                	sd	s0,16(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	000e0363          	beqz	t3,ffffffffc02001e4 <__panic+0x22>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x20>
    is_panic = 1;
ffffffffc02001e4:	4785                	li	a5,1
ffffffffc02001e6:	00f32023          	sw	a5,0(t1)
    va_start(ap, fmt);
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001ee:	862e                	mv	a2,a1
ffffffffc02001f0:	85aa                	mv	a1,a0
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	c7650513          	addi	a0,a0,-906 # ffffffffc0201e68 <etext+0xf4>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00002517          	auipc	a0,0x2
ffffffffc020020c:	c3850513          	addi	a0,a0,-968 # ffffffffc0201e40 <etext+0xcc>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200216:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200218:	00002517          	auipc	a0,0x2
ffffffffc020021c:	c7050513          	addi	a0,a0,-912 # ffffffffc0201e88 <etext+0x114>
void dtb_init(void) {
ffffffffc0200220:	fc86                	sd	ra,120(sp)
ffffffffc0200222:	f8a2                	sd	s0,112(sp)
ffffffffc0200224:	e8d2                	sd	s4,80(sp)
ffffffffc0200226:	f4a6                	sd	s1,104(sp)
ffffffffc0200228:	f0ca                	sd	s2,96(sp)
ffffffffc020022a:	ecce                	sd	s3,88(sp)
ffffffffc020022c:	e4d6                	sd	s5,72(sp)
ffffffffc020022e:	e0da                	sd	s6,64(sp)
ffffffffc0200230:	fc5e                	sd	s7,56(sp)
ffffffffc0200232:	f862                	sd	s8,48(sp)
ffffffffc0200234:	f466                	sd	s9,40(sp)
ffffffffc0200236:	f06a                	sd	s10,32(sp)
ffffffffc0200238:	ec6e                	sd	s11,24(sp)
    cprintf("DTB Init\n");
ffffffffc020023a:	f13ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020023e:	00006597          	auipc	a1,0x6
ffffffffc0200242:	dc25b583          	ld	a1,-574(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200246:	00002517          	auipc	a0,0x2
ffffffffc020024a:	c5250513          	addi	a0,a0,-942 # ffffffffc0201e98 <etext+0x124>
ffffffffc020024e:	effff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200252:	00006417          	auipc	s0,0x6
ffffffffc0200256:	db640413          	addi	s0,s0,-586 # ffffffffc0206008 <boot_dtb>
ffffffffc020025a:	600c                	ld	a1,0(s0)
ffffffffc020025c:	00002517          	auipc	a0,0x2
ffffffffc0200260:	c4c50513          	addi	a0,a0,-948 # ffffffffc0201ea8 <etext+0x134>
ffffffffc0200264:	ee9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200268:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	c5450513          	addi	a0,a0,-940 # ffffffffc0201ec0 <etext+0x14c>
    if (boot_dtb == 0) {
ffffffffc0200274:	120a0463          	beqz	s4,ffffffffc020039c <dtb_init+0x186>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200278:	57f5                	li	a5,-3
ffffffffc020027a:	07fa                	slli	a5,a5,0x1e
ffffffffc020027c:	00fa0733          	add	a4,s4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200280:	431c                	lw	a5,0(a4)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200282:	00ff0637          	lui	a2,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200286:	6b41                	lui	s6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200288:	0087d59b          	srliw	a1,a5,0x8
ffffffffc020028c:	0187969b          	slliw	a3,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200290:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200294:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200298:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020029c:	8df1                	and	a1,a1,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029e:	8ec9                	or	a3,a3,a0
ffffffffc02002a0:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002a4:	1b7d                	addi	s6,s6,-1
ffffffffc02002a6:	0167f7b3          	and	a5,a5,s6
ffffffffc02002aa:	8dd5                	or	a1,a1,a3
ffffffffc02002ac:	8ddd                	or	a1,a1,a5
    if (magic != 0xd00dfeed) {
ffffffffc02002ae:	d00e07b7          	lui	a5,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002b2:	2581                	sext.w	a1,a1
    if (magic != 0xd00dfeed) {
ffffffffc02002b4:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed7bf5>
ffffffffc02002b8:	10f59163          	bne	a1,a5,ffffffffc02003ba <dtb_init+0x1a4>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002bc:	471c                	lw	a5,8(a4)
ffffffffc02002be:	4754                	lw	a3,12(a4)
    int in_memory_node = 0;
ffffffffc02002c0:	4c81                	li	s9,0
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002c2:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02002c6:	0086d51b          	srliw	a0,a3,0x8
ffffffffc02002ca:	0186941b          	slliw	s0,a3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ce:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002d2:	01879a1b          	slliw	s4,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d6:	0187d81b          	srliw	a6,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002da:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002de:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e2:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e6:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ea:	8d71                	and	a0,a0,a2
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ec:	01146433          	or	s0,s0,a7
ffffffffc02002f0:	0086969b          	slliw	a3,a3,0x8
ffffffffc02002f4:	010a6a33          	or	s4,s4,a6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f8:	8e6d                	and	a2,a2,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002fa:	0087979b          	slliw	a5,a5,0x8
ffffffffc02002fe:	8c49                	or	s0,s0,a0
ffffffffc0200300:	0166f6b3          	and	a3,a3,s6
ffffffffc0200304:	00ca6a33          	or	s4,s4,a2
ffffffffc0200308:	0167f7b3          	and	a5,a5,s6
ffffffffc020030c:	8c55                	or	s0,s0,a3
ffffffffc020030e:	00fa6a33          	or	s4,s4,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200312:	1402                	slli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200314:	1a02                	slli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200316:	9001                	srli	s0,s0,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200318:	020a5a13          	srli	s4,s4,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020031c:	943a                	add	s0,s0,a4
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020031e:	9a3a                	add	s4,s4,a4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200320:	00ff0c37          	lui	s8,0xff0
        switch (token) {
ffffffffc0200324:	4b8d                	li	s7,3
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200326:	00002917          	auipc	s2,0x2
ffffffffc020032a:	bea90913          	addi	s2,s2,-1046 # ffffffffc0201f10 <etext+0x19c>
ffffffffc020032e:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200330:	4d91                	li	s11,4
ffffffffc0200332:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200334:	00002497          	auipc	s1,0x2
ffffffffc0200338:	bd448493          	addi	s1,s1,-1068 # ffffffffc0201f08 <etext+0x194>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020033c:	000a2703          	lw	a4,0(s4)
ffffffffc0200340:	004a0a93          	addi	s5,s4,4
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200344:	0087569b          	srliw	a3,a4,0x8
ffffffffc0200348:	0187179b          	slliw	a5,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020034c:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200350:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200354:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200358:	8fd1                	or	a5,a5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020035a:	0186f6b3          	and	a3,a3,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020035e:	0087171b          	slliw	a4,a4,0x8
ffffffffc0200362:	8fd5                	or	a5,a5,a3
ffffffffc0200364:	00eb7733          	and	a4,s6,a4
ffffffffc0200368:	8fd9                	or	a5,a5,a4
ffffffffc020036a:	2781                	sext.w	a5,a5
        switch (token) {
ffffffffc020036c:	09778c63          	beq	a5,s7,ffffffffc0200404 <dtb_init+0x1ee>
ffffffffc0200370:	00fbea63          	bltu	s7,a5,ffffffffc0200384 <dtb_init+0x16e>
ffffffffc0200374:	07a78663          	beq	a5,s10,ffffffffc02003e0 <dtb_init+0x1ca>
ffffffffc0200378:	4709                	li	a4,2
ffffffffc020037a:	00e79763          	bne	a5,a4,ffffffffc0200388 <dtb_init+0x172>
ffffffffc020037e:	4c81                	li	s9,0
ffffffffc0200380:	8a56                	mv	s4,s5
ffffffffc0200382:	bf6d                	j	ffffffffc020033c <dtb_init+0x126>
ffffffffc0200384:	ffb78ee3          	beq	a5,s11,ffffffffc0200380 <dtb_init+0x16a>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200388:	00002517          	auipc	a0,0x2
ffffffffc020038c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0201f88 <etext+0x214>
ffffffffc0200390:	dbdff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200394:	00002517          	auipc	a0,0x2
ffffffffc0200398:	c2c50513          	addi	a0,a0,-980 # ffffffffc0201fc0 <etext+0x24c>
}
ffffffffc020039c:	7446                	ld	s0,112(sp)
ffffffffc020039e:	70e6                	ld	ra,120(sp)
ffffffffc02003a0:	74a6                	ld	s1,104(sp)
ffffffffc02003a2:	7906                	ld	s2,96(sp)
ffffffffc02003a4:	69e6                	ld	s3,88(sp)
ffffffffc02003a6:	6a46                	ld	s4,80(sp)
ffffffffc02003a8:	6aa6                	ld	s5,72(sp)
ffffffffc02003aa:	6b06                	ld	s6,64(sp)
ffffffffc02003ac:	7be2                	ld	s7,56(sp)
ffffffffc02003ae:	7c42                	ld	s8,48(sp)
ffffffffc02003b0:	7ca2                	ld	s9,40(sp)
ffffffffc02003b2:	7d02                	ld	s10,32(sp)
ffffffffc02003b4:	6de2                	ld	s11,24(sp)
ffffffffc02003b6:	6109                	addi	sp,sp,128
    cprintf("DTB init completed\n");
ffffffffc02003b8:	bb51                	j	ffffffffc020014c <cprintf>
}
ffffffffc02003ba:	7446                	ld	s0,112(sp)
ffffffffc02003bc:	70e6                	ld	ra,120(sp)
ffffffffc02003be:	74a6                	ld	s1,104(sp)
ffffffffc02003c0:	7906                	ld	s2,96(sp)
ffffffffc02003c2:	69e6                	ld	s3,88(sp)
ffffffffc02003c4:	6a46                	ld	s4,80(sp)
ffffffffc02003c6:	6aa6                	ld	s5,72(sp)
ffffffffc02003c8:	6b06                	ld	s6,64(sp)
ffffffffc02003ca:	7be2                	ld	s7,56(sp)
ffffffffc02003cc:	7c42                	ld	s8,48(sp)
ffffffffc02003ce:	7ca2                	ld	s9,40(sp)
ffffffffc02003d0:	7d02                	ld	s10,32(sp)
ffffffffc02003d2:	6de2                	ld	s11,24(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003d4:	00002517          	auipc	a0,0x2
ffffffffc02003d8:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0201ee0 <etext+0x16c>
}
ffffffffc02003dc:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	b3bd                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003e0:	8556                	mv	a0,s5
ffffffffc02003e2:	4fe010ef          	jal	ra,ffffffffc02018e0 <strlen>
ffffffffc02003e6:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	4619                	li	a2,6
ffffffffc02003ea:	85a6                	mv	a1,s1
ffffffffc02003ec:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003ee:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f0:	544010ef          	jal	ra,ffffffffc0201934 <strncmp>
ffffffffc02003f4:	e111                	bnez	a0,ffffffffc02003f8 <dtb_init+0x1e2>
                    in_memory_node = 1;
ffffffffc02003f6:	4c85                	li	s9,1
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003f8:	0a91                	addi	s5,s5,4
ffffffffc02003fa:	9ad2                	add	s5,s5,s4
ffffffffc02003fc:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc0200400:	8a56                	mv	s4,s5
ffffffffc0200402:	bf2d                	j	ffffffffc020033c <dtb_init+0x126>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200404:	004a2783          	lw	a5,4(s4)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200408:	00ca0693          	addi	a3,s4,12
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020040c:	0087d71b          	srliw	a4,a5,0x8
ffffffffc0200410:	01879a9b          	slliw	s5,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200414:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200418:	0107171b          	slliw	a4,a4,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041c:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200420:	00caeab3          	or	s5,s5,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200424:	01877733          	and	a4,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200428:	0087979b          	slliw	a5,a5,0x8
ffffffffc020042c:	00eaeab3          	or	s5,s5,a4
ffffffffc0200430:	00fb77b3          	and	a5,s6,a5
ffffffffc0200434:	00faeab3          	or	s5,s5,a5
ffffffffc0200438:	2a81                	sext.w	s5,s5
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020043a:	000c9c63          	bnez	s9,ffffffffc0200452 <dtb_init+0x23c>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc020043e:	1a82                	slli	s5,s5,0x20
ffffffffc0200440:	00368793          	addi	a5,a3,3
ffffffffc0200444:	020ada93          	srli	s5,s5,0x20
ffffffffc0200448:	9abe                	add	s5,s5,a5
ffffffffc020044a:	ffcafa93          	andi	s5,s5,-4
        switch (token) {
ffffffffc020044e:	8a56                	mv	s4,s5
ffffffffc0200450:	b5f5                	j	ffffffffc020033c <dtb_init+0x126>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200452:	008a2783          	lw	a5,8(s4)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200456:	85ca                	mv	a1,s2
ffffffffc0200458:	e436                	sd	a3,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020045a:	0087d51b          	srliw	a0,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020045e:	0187d61b          	srliw	a2,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200462:	0187971b          	slliw	a4,a5,0x18
ffffffffc0200466:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020046a:	0107d79b          	srliw	a5,a5,0x10
ffffffffc020046e:	8f51                	or	a4,a4,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200470:	01857533          	and	a0,a0,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200474:	0087979b          	slliw	a5,a5,0x8
ffffffffc0200478:	8d59                	or	a0,a0,a4
ffffffffc020047a:	00fb77b3          	and	a5,s6,a5
ffffffffc020047e:	8d5d                	or	a0,a0,a5
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200480:	1502                	slli	a0,a0,0x20
ffffffffc0200482:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200484:	9522                	add	a0,a0,s0
ffffffffc0200486:	490010ef          	jal	ra,ffffffffc0201916 <strcmp>
ffffffffc020048a:	66a2                	ld	a3,8(sp)
ffffffffc020048c:	f94d                	bnez	a0,ffffffffc020043e <dtb_init+0x228>
ffffffffc020048e:	fb59f8e3          	bgeu	s3,s5,ffffffffc020043e <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200492:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200496:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020049a:	00002517          	auipc	a0,0x2
ffffffffc020049e:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0201f18 <etext+0x1a4>
           fdt32_to_cpu(x >> 32);
ffffffffc02004a2:	4207d613          	srai	a2,a5,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a6:	0087d31b          	srliw	t1,a5,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02004aa:	42075593          	srai	a1,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ae:	0187de1b          	srliw	t3,a5,0x18
ffffffffc02004b2:	0186581b          	srliw	a6,a2,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b6:	0187941b          	slliw	s0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ba:	0107d89b          	srliw	a7,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004be:	0187d693          	srli	a3,a5,0x18
ffffffffc02004c2:	01861f1b          	slliw	t5,a2,0x18
ffffffffc02004c6:	0087579b          	srliw	a5,a4,0x8
ffffffffc02004ca:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0106561b          	srliw	a2,a2,0x10
ffffffffc02004d2:	010f6f33          	or	t5,t5,a6
ffffffffc02004d6:	0187529b          	srliw	t0,a4,0x18
ffffffffc02004da:	0185df9b          	srliw	t6,a1,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004de:	01837333          	and	t1,t1,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e2:	01c46433          	or	s0,s0,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e6:	0186f6b3          	and	a3,a3,s8
ffffffffc02004ea:	01859e1b          	slliw	t3,a1,0x18
ffffffffc02004ee:	01871e9b          	slliw	t4,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004f2:	0107581b          	srliw	a6,a4,0x10
ffffffffc02004f6:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004fa:	8361                	srli	a4,a4,0x18
ffffffffc02004fc:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200500:	0105d59b          	srliw	a1,a1,0x10
ffffffffc0200504:	01e6e6b3          	or	a3,a3,t5
ffffffffc0200508:	00cb7633          	and	a2,s6,a2
ffffffffc020050c:	0088181b          	slliw	a6,a6,0x8
ffffffffc0200510:	0085959b          	slliw	a1,a1,0x8
ffffffffc0200514:	00646433          	or	s0,s0,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200518:	0187f7b3          	and	a5,a5,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020051c:	01fe6333          	or	t1,t3,t6
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200520:	01877c33          	and	s8,a4,s8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200524:	0088989b          	slliw	a7,a7,0x8
ffffffffc0200528:	011b78b3          	and	a7,s6,a7
ffffffffc020052c:	005eeeb3          	or	t4,t4,t0
ffffffffc0200530:	00c6e733          	or	a4,a3,a2
ffffffffc0200534:	006c6c33          	or	s8,s8,t1
ffffffffc0200538:	010b76b3          	and	a3,s6,a6
ffffffffc020053c:	00bb7b33          	and	s6,s6,a1
ffffffffc0200540:	01d7e7b3          	or	a5,a5,t4
ffffffffc0200544:	016c6b33          	or	s6,s8,s6
ffffffffc0200548:	01146433          	or	s0,s0,a7
ffffffffc020054c:	8fd5                	or	a5,a5,a3
           fdt32_to_cpu(x >> 32);
ffffffffc020054e:	1702                	slli	a4,a4,0x20
ffffffffc0200550:	1b02                	slli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200552:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200554:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200556:	1402                	slli	s0,s0,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200558:	020b5b13          	srli	s6,s6,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020055c:	0167eb33          	or	s6,a5,s6
ffffffffc0200560:	8c59                	or	s0,s0,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200562:	bebff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200566:	85a2                	mv	a1,s0
ffffffffc0200568:	00002517          	auipc	a0,0x2
ffffffffc020056c:	9d050513          	addi	a0,a0,-1584 # ffffffffc0201f38 <etext+0x1c4>
ffffffffc0200570:	bddff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200574:	014b5613          	srli	a2,s6,0x14
ffffffffc0200578:	85da                	mv	a1,s6
ffffffffc020057a:	00002517          	auipc	a0,0x2
ffffffffc020057e:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201f50 <etext+0x1dc>
ffffffffc0200582:	bcbff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200586:	008b05b3          	add	a1,s6,s0
ffffffffc020058a:	15fd                	addi	a1,a1,-1
ffffffffc020058c:	00002517          	auipc	a0,0x2
ffffffffc0200590:	9e450513          	addi	a0,a0,-1564 # ffffffffc0201f70 <etext+0x1fc>
ffffffffc0200594:	bb9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	a2850513          	addi	a0,a0,-1496 # ffffffffc0201fc0 <etext+0x24c>
        memory_base = mem_base;
ffffffffc02005a0:	00008797          	auipc	a5,0x8
ffffffffc02005a4:	d087b823          	sd	s0,-752(a5) # ffffffffc02082b0 <memory_base>
        memory_size = mem_size;
ffffffffc02005a8:	00008797          	auipc	a5,0x8
ffffffffc02005ac:	d167b823          	sd	s6,-752(a5) # ffffffffc02082b8 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005b0:	b3f5                	j	ffffffffc020039c <dtb_init+0x186>

ffffffffc02005b2 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005b2:	00008517          	auipc	a0,0x8
ffffffffc02005b6:	cfe53503          	ld	a0,-770(a0) # ffffffffc02082b0 <memory_base>
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005bc:	00008517          	auipc	a0,0x8
ffffffffc02005c0:	cfc53503          	ld	a0,-772(a0) # ffffffffc02082b8 <memory_size>
ffffffffc02005c4:	8082                	ret

ffffffffc02005c6 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02005c6:	8082                	ret

ffffffffc02005c8 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc02005c8:	0ff57513          	zext.b	a0,a0
ffffffffc02005cc:	78e0106f          	j	ffffffffc0201d5a <sbi_console_putchar>

ffffffffc02005d0 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	00008797          	auipc	a5,0x8
ffffffffc02005d4:	d007b783          	ld	a5,-768(a5) # ffffffffc02082d0 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	00008797          	auipc	a5,0x8
ffffffffc02005e0:	cf47b783          	ld	a5,-780(a5) # ffffffffc02082d0 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005e8:	00002797          	auipc	a5,0x2
ffffffffc02005ec:	f5878793          	addi	a5,a5,-168 # ffffffffc0202540 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005f0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02005f2:	7179                	addi	sp,sp,-48
ffffffffc02005f4:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005f6:	00002517          	auipc	a0,0x2
ffffffffc02005fa:	9e250513          	addi	a0,a0,-1566 # ffffffffc0201fd8 <etext+0x264>
    pmm_manager = &buddy_pmm_manager;
ffffffffc02005fe:	00008417          	auipc	s0,0x8
ffffffffc0200602:	cd240413          	addi	s0,s0,-814 # ffffffffc02082d0 <pmm_manager>
void pmm_init(void) {
ffffffffc0200606:	f406                	sd	ra,40(sp)
ffffffffc0200608:	ec26                	sd	s1,24(sp)
ffffffffc020060a:	e44e                	sd	s3,8(sp)
ffffffffc020060c:	e84a                	sd	s2,16(sp)
ffffffffc020060e:	e052                	sd	s4,0(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200610:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200612:	b3bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();
ffffffffc0200616:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200618:	00008497          	auipc	s1,0x8
ffffffffc020061c:	cd048493          	addi	s1,s1,-816 # ffffffffc02082e8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200620:	679c                	ld	a5,8(a5)
ffffffffc0200622:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200624:	57f5                	li	a5,-3
ffffffffc0200626:	07fa                	slli	a5,a5,0x1e
ffffffffc0200628:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc020062a:	f89ff0ef          	jal	ra,ffffffffc02005b2 <get_memory_base>
ffffffffc020062e:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0200630:	f8dff0ef          	jal	ra,ffffffffc02005bc <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200634:	16050063          	beqz	a0,ffffffffc0200794 <pmm_init+0x1ac>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200638:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc020063a:	00002517          	auipc	a0,0x2
ffffffffc020063e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0202020 <etext+0x2ac>
ffffffffc0200642:	b0bff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0200646:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc020064a:	864e                	mv	a2,s3
ffffffffc020064c:	fffa0693          	addi	a3,s4,-1
ffffffffc0200650:	85ca                	mv	a1,s2
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	9e650513          	addi	a0,a0,-1562 # ffffffffc0202038 <etext+0x2c4>
ffffffffc020065a:	af3ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc020065e:	c80007b7          	lui	a5,0xc8000
ffffffffc0200662:	8652                	mv	a2,s4
ffffffffc0200664:	0d47e763          	bltu	a5,s4,ffffffffc0200732 <pmm_init+0x14a>
ffffffffc0200668:	00009797          	auipc	a5,0x9
ffffffffc020066c:	c8f78793          	addi	a5,a5,-881 # ffffffffc02092f7 <end+0xfff>
ffffffffc0200670:	757d                	lui	a0,0xfffff
ffffffffc0200672:	8d7d                	and	a0,a0,a5
ffffffffc0200674:	8231                	srli	a2,a2,0xc
ffffffffc0200676:	00008797          	auipc	a5,0x8
ffffffffc020067a:	c4c7b523          	sd	a2,-950(a5) # ffffffffc02082c0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020067e:	00008797          	auipc	a5,0x8
ffffffffc0200682:	c4a7b523          	sd	a0,-950(a5) # ffffffffc02082c8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200686:	000807b7          	lui	a5,0x80
ffffffffc020068a:	002005b7          	lui	a1,0x200
ffffffffc020068e:	02f60563          	beq	a2,a5,ffffffffc02006b8 <pmm_init+0xd0>
ffffffffc0200692:	00261593          	slli	a1,a2,0x2
ffffffffc0200696:	00c586b3          	add	a3,a1,a2
ffffffffc020069a:	fec007b7          	lui	a5,0xfec00
ffffffffc020069e:	97aa                	add	a5,a5,a0
ffffffffc02006a0:	068e                	slli	a3,a3,0x3
ffffffffc02006a2:	96be                	add	a3,a3,a5
ffffffffc02006a4:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc02006a6:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006a8:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f7d30>
        SetPageReserved(pages + i);
ffffffffc02006ac:	00176713          	ori	a4,a4,1
ffffffffc02006b0:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006b4:	fef699e3          	bne	a3,a5,ffffffffc02006a6 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006b8:	95b2                	add	a1,a1,a2
ffffffffc02006ba:	fec006b7          	lui	a3,0xfec00
ffffffffc02006be:	96aa                	add	a3,a3,a0
ffffffffc02006c0:	058e                	slli	a1,a1,0x3
ffffffffc02006c2:	96ae                	add	a3,a3,a1
ffffffffc02006c4:	c02007b7          	lui	a5,0xc0200
ffffffffc02006c8:	0af6ea63          	bltu	a3,a5,ffffffffc020077c <pmm_init+0x194>
ffffffffc02006cc:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02006ce:	77fd                	lui	a5,0xfffff
ffffffffc02006d0:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006d4:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006d6:	06b6e163          	bltu	a3,a1,ffffffffc0200738 <pmm_init+0x150>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02006da:	601c                	ld	a5,0(s0)
ffffffffc02006dc:	7b9c                	ld	a5,48(a5)
ffffffffc02006de:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9e050513          	addi	a0,a0,-1568 # ffffffffc02020c0 <etext+0x34c>
ffffffffc02006e8:	a65ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_init();
ffffffffc02006ec:	1d0000ef          	jal	ra,ffffffffc02008bc <slub_init>
    slub_check();
ffffffffc02006f0:	474000ef          	jal	ra,ffffffffc0200b64 <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02006f4:	00005597          	auipc	a1,0x5
ffffffffc02006f8:	90c58593          	addi	a1,a1,-1780 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02006fc:	00008797          	auipc	a5,0x8
ffffffffc0200700:	beb7b223          	sd	a1,-1052(a5) # ffffffffc02082e0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200704:	c02007b7          	lui	a5,0xc0200
ffffffffc0200708:	0af5e263          	bltu	a1,a5,ffffffffc02007ac <pmm_init+0x1c4>
ffffffffc020070c:	6090                	ld	a2,0(s1)
}
ffffffffc020070e:	7402                	ld	s0,32(sp)
ffffffffc0200710:	70a2                	ld	ra,40(sp)
ffffffffc0200712:	64e2                	ld	s1,24(sp)
ffffffffc0200714:	6942                	ld	s2,16(sp)
ffffffffc0200716:	69a2                	ld	s3,8(sp)
ffffffffc0200718:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020071a:	40c58633          	sub	a2,a1,a2
ffffffffc020071e:	00008797          	auipc	a5,0x8
ffffffffc0200722:	bac7bd23          	sd	a2,-1094(a5) # ffffffffc02082d8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200726:	00002517          	auipc	a0,0x2
ffffffffc020072a:	9ba50513          	addi	a0,a0,-1606 # ffffffffc02020e0 <etext+0x36c>
}
ffffffffc020072e:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200730:	bc31                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;
ffffffffc0200732:	c8000637          	lui	a2,0xc8000
ffffffffc0200736:	bf0d                	j	ffffffffc0200668 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200738:	6705                	lui	a4,0x1
ffffffffc020073a:	177d                	addi	a4,a4,-1
ffffffffc020073c:	96ba                	add	a3,a3,a4
ffffffffc020073e:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200740:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200744:	02c7f063          	bgeu	a5,a2,ffffffffc0200764 <pmm_init+0x17c>
    pmm_manager->init_memmap(base, n);
ffffffffc0200748:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020074a:	fff80737          	lui	a4,0xfff80
ffffffffc020074e:	973e                	add	a4,a4,a5
ffffffffc0200750:	00271793          	slli	a5,a4,0x2
ffffffffc0200754:	97ba                	add	a5,a5,a4
ffffffffc0200756:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200758:	8d95                	sub	a1,a1,a3
ffffffffc020075a:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020075c:	81b1                	srli	a1,a1,0xc
ffffffffc020075e:	953e                	add	a0,a0,a5
ffffffffc0200760:	9702                	jalr	a4
}
ffffffffc0200762:	bfa5                	j	ffffffffc02006da <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200764:	00002617          	auipc	a2,0x2
ffffffffc0200768:	92c60613          	addi	a2,a2,-1748 # ffffffffc0202090 <etext+0x31c>
ffffffffc020076c:	06a00593          	li	a1,106
ffffffffc0200770:	00002517          	auipc	a0,0x2
ffffffffc0200774:	94050513          	addi	a0,a0,-1728 # ffffffffc02020b0 <etext+0x33c>
ffffffffc0200778:	a4bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020077c:	00002617          	auipc	a2,0x2
ffffffffc0200780:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0202068 <etext+0x2f4>
ffffffffc0200784:	06000593          	li	a1,96
ffffffffc0200788:	00002517          	auipc	a0,0x2
ffffffffc020078c:	88850513          	addi	a0,a0,-1912 # ffffffffc0202010 <etext+0x29c>
ffffffffc0200790:	a33ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc0200794:	00002617          	auipc	a2,0x2
ffffffffc0200798:	85c60613          	addi	a2,a2,-1956 # ffffffffc0201ff0 <etext+0x27c>
ffffffffc020079c:	04800593          	li	a1,72
ffffffffc02007a0:	00002517          	auipc	a0,0x2
ffffffffc02007a4:	87050513          	addi	a0,a0,-1936 # ffffffffc0202010 <etext+0x29c>
ffffffffc02007a8:	a1bff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007ac:	86ae                	mv	a3,a1
ffffffffc02007ae:	00002617          	auipc	a2,0x2
ffffffffc02007b2:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0202068 <etext+0x2f4>
ffffffffc02007b6:	07f00593          	li	a1,127
ffffffffc02007ba:	00002517          	auipc	a0,0x2
ffffffffc02007be:	85650513          	addi	a0,a0,-1962 # ffffffffc0202010 <etext+0x29c>
ffffffffc02007c2:	a01ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007c6 <free_in_list>:
        cache->full = sp;
    }
    return obj;
}

static int free_in_list(slab_page_t **list_head, kmem_cache_t *cache, void *ptr) {
ffffffffc02007c6:	1141                	addi	sp,sp,-16
ffffffffc02007c8:	e022                	sd	s0,0(sp)
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc02007ca:	6100                	ld	s0,0(a0)
static int free_in_list(slab_page_t **list_head, kmem_cache_t *cache, void *ptr) {
ffffffffc02007cc:	e406                	sd	ra,8(sp)
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc02007ce:	c821                	beqz	s0,ffffffffc020081e <free_in_list+0x58>
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;
        uintptr_t end  = base + PGSIZE;
ffffffffc02007d0:	fff406b7          	lui	a3,0xfff40
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;
ffffffffc02007d4:	5875                	li	a6,-3
        uintptr_t end  = base + PGSIZE;
ffffffffc02007d6:	0685                	addi	a3,a3,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007d8:	00008e17          	auipc	t3,0x8
ffffffffc02007dc:	af0e3e03          	ld	t3,-1296(t3) # ffffffffc02082c8 <pages>
ffffffffc02007e0:	00002317          	auipc	t1,0x2
ffffffffc02007e4:	fe033303          	ld	t1,-32(t1) # ffffffffc02027c0 <nbase>
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc02007e8:	4e81                	li	t4,0
ffffffffc02007ea:	00002897          	auipc	a7,0x2
ffffffffc02007ee:	fde8b883          	ld	a7,-34(a7) # ffffffffc02027c8 <nbase+0x8>
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;
ffffffffc02007f2:	087a                	slli	a6,a6,0x1e
        uintptr_t end  = base + PGSIZE;
ffffffffc02007f4:	06b2                	slli	a3,a3,0xc
ffffffffc02007f6:	a011                	j	ffffffffc02007fa <free_in_list+0x34>
ffffffffc02007f8:	843e                	mv	s0,a5
ffffffffc02007fa:	601c                	ld	a5,0(s0)
ffffffffc02007fc:	41c787b3          	sub	a5,a5,t3
ffffffffc0200800:	878d                	srai	a5,a5,0x3
ffffffffc0200802:	031787b3          	mul	a5,a5,a7
ffffffffc0200806:	979a                	add	a5,a5,t1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200808:	07b2                	slli	a5,a5,0xc
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;
ffffffffc020080a:	01078733          	add	a4,a5,a6
        uintptr_t end  = base + PGSIZE;
ffffffffc020080e:	97b6                	add	a5,a5,a3
        if ((uintptr_t)ptr >= base && (uintptr_t)ptr < end) {
ffffffffc0200810:	00e66463          	bltu	a2,a4,ffffffffc0200818 <free_in_list+0x52>
ffffffffc0200814:	00f66a63          	bltu	a2,a5,ffffffffc0200828 <free_in_list+0x62>
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc0200818:	6c1c                	ld	a5,24(s0)
ffffffffc020081a:	8ea2                	mv	t4,s0
ffffffffc020081c:	fff1                	bnez	a5,ffffffffc02007f8 <free_in_list+0x32>
            }
            return 1;
        }
    }
    return 0;
}
ffffffffc020081e:	60a2                	ld	ra,8(sp)
ffffffffc0200820:	6402                	ld	s0,0(sp)
    return 0;
ffffffffc0200822:	4501                	li	a0,0
}
ffffffffc0200824:	0141                	addi	sp,sp,16
ffffffffc0200826:	8082                	ret
            *(void **)ptr = sp->free_head;
ffffffffc0200828:	6414                	ld	a3,8(s0)
            if (sp->inuse > 0) sp->inuse--;
ffffffffc020082a:	481c                	lw	a5,16(s0)
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc020082c:	01058713          	addi	a4,a1,16
            *(void **)ptr = sp->free_head;
ffffffffc0200830:	e214                	sd	a3,0(a2)
            sp->free_head = ptr;
ffffffffc0200832:	e410                	sd	a2,8(s0)
            if (sp->inuse > 0) sp->inuse--;
ffffffffc0200834:	cb99                	beqz	a5,ffffffffc020084a <free_in_list+0x84>
ffffffffc0200836:	37fd                	addiw	a5,a5,-1
ffffffffc0200838:	c81c                	sw	a5,16(s0)
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc020083a:	04e50463          	beq	a0,a4,ffffffffc0200882 <free_in_list+0xbc>
            if (sp->inuse == 0 && sp->capacity > 0) {
ffffffffc020083e:	cb81                	beqz	a5,ffffffffc020084e <free_in_list+0x88>
            return 1;
ffffffffc0200840:	4505                	li	a0,1
}
ffffffffc0200842:	60a2                	ld	ra,8(sp)
ffffffffc0200844:	6402                	ld	s0,0(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc020084a:	04e50a63          	beq	a0,a4,ffffffffc020089e <free_in_list+0xd8>
ffffffffc020084e:	4858                	lw	a4,20(s0)
            if (sp->inuse == 0 && sp->capacity > 0) {
ffffffffc0200850:	2701                	sext.w	a4,a4
ffffffffc0200852:	d77d                	beqz	a4,ffffffffc0200840 <free_in_list+0x7a>
                if (list_head == &cache->partial) {
ffffffffc0200854:	05a1                	addi	a1,a1,8
ffffffffc0200856:	04b50963          	beq	a0,a1,ffffffffc02008a8 <free_in_list+0xe2>
                free_page(sp->page);
ffffffffc020085a:	6008                	ld	a0,0(s0)
ffffffffc020085c:	4585                	li	a1,1
ffffffffc020085e:	d7fff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    sp->next = (slab_page_t *)(uintptr_t)sp_freelist_head;
ffffffffc0200862:	00005717          	auipc	a4,0x5
ffffffffc0200866:	7ae70713          	addi	a4,a4,1966 # ffffffffc0206010 <sp_freelist_head>
ffffffffc020086a:	4314                	lw	a3,0(a4)
    int idx = (int)(sp - sp_pool);
ffffffffc020086c:	00006797          	auipc	a5,0x6
ffffffffc0200870:	87478793          	addi	a5,a5,-1932 # ffffffffc02060e0 <sp_pool>
ffffffffc0200874:	40f407b3          	sub	a5,s0,a5
ffffffffc0200878:	8795                	srai	a5,a5,0x5
    sp->next = (slab_page_t *)(uintptr_t)sp_freelist_head;
ffffffffc020087a:	ec14                	sd	a3,24(s0)
    int idx = (int)(sp - sp_pool);
ffffffffc020087c:	c31c                	sw	a5,0(a4)
            return 1;
ffffffffc020087e:	4505                	li	a0,1
ffffffffc0200880:	b7c9                	j	ffffffffc0200842 <free_in_list+0x7c>
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc0200882:	4858                	lw	a4,20(s0)
ffffffffc0200884:	fae7fde3          	bgeu	a5,a4,ffffffffc020083e <free_in_list+0x78>
                if (prev) prev->next = sp->next; else *list_head = sp->next;
ffffffffc0200888:	6c18                	ld	a4,24(s0)
ffffffffc020088a:	020e8563          	beqz	t4,ffffffffc02008b4 <free_in_list+0xee>
ffffffffc020088e:	00eebc23          	sd	a4,24(t4)
                sp->next = cache->partial;
ffffffffc0200892:	6598                	ld	a4,8(a1)
ffffffffc0200894:	ec18                	sd	a4,24(s0)
                cache->partial = sp;
ffffffffc0200896:	e580                	sd	s0,8(a1)
            if (sp->inuse == 0 && sp->capacity > 0) {
ffffffffc0200898:	dfd5                	beqz	a5,ffffffffc0200854 <free_in_list+0x8e>
            return 1;
ffffffffc020089a:	4505                	li	a0,1
ffffffffc020089c:	b75d                	j	ffffffffc0200842 <free_in_list+0x7c>
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc020089e:	4858                	lw	a4,20(s0)
ffffffffc02008a0:	0007069b          	sext.w	a3,a4
ffffffffc02008a4:	f2f5                	bnez	a3,ffffffffc0200888 <free_in_list+0xc2>
ffffffffc02008a6:	b76d                	j	ffffffffc0200850 <free_in_list+0x8a>
                    if (prev) prev->next = sp->next; else *list_head = sp->next;
ffffffffc02008a8:	6c1c                	ld	a5,24(s0)
ffffffffc02008aa:	000e8763          	beqz	t4,ffffffffc02008b8 <free_in_list+0xf2>
ffffffffc02008ae:	00febc23          	sd	a5,24(t4)
ffffffffc02008b2:	b765                	j	ffffffffc020085a <free_in_list+0x94>
                if (prev) prev->next = sp->next; else *list_head = sp->next;
ffffffffc02008b4:	e118                	sd	a4,0(a0)
ffffffffc02008b6:	bff1                	j	ffffffffc0200892 <free_in_list+0xcc>
                    if (prev) prev->next = sp->next; else *list_head = sp->next;
ffffffffc02008b8:	e11c                	sd	a5,0(a0)
ffffffffc02008ba:	b745                	j	ffffffffc020085a <free_in_list+0x94>

ffffffffc02008bc <slub_init>:
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
ffffffffc02008bc:	00008797          	auipc	a5,0x8
ffffffffc02008c0:	81c78793          	addi	a5,a5,-2020 # ffffffffc02080d8 <sp_pool+0x1ff8>
void slub_init(void) {
ffffffffc02008c4:	567d                	li	a2,-1
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
ffffffffc02008c6:	0ff00713          	li	a4,255
ffffffffc02008ca:	55fd                	li	a1,-1
ffffffffc02008cc:	a011                	j	ffffffffc02008d0 <slub_init+0x14>
ffffffffc02008ce:	8736                	mv	a4,a3
        sp_pool[i].next = (slab_page_t *)(uintptr_t)sp_freelist_head;
ffffffffc02008d0:	e390                	sd	a2,0(a5)
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
ffffffffc02008d2:	fff7069b          	addiw	a3,a4,-1
ffffffffc02008d6:	863a                	mv	a2,a4
ffffffffc02008d8:	1781                	addi	a5,a5,-32
ffffffffc02008da:	feb69ae3          	bne	a3,a1,ffffffffc02008ce <slub_init+0x12>
ffffffffc02008de:	00005797          	auipc	a5,0x5
ffffffffc02008e2:	7207a923          	sw	zero,1842(a5) # ffffffffc0206010 <sp_freelist_head>
ffffffffc02008e6:	00005797          	auipc	a5,0x5
ffffffffc02008ea:	73a78793          	addi	a5,a5,1850 # ffffffffc0206020 <caches>
ffffffffc02008ee:	00002717          	auipc	a4,0x2
ffffffffc02008f2:	88270713          	addi	a4,a4,-1918 # ffffffffc0202170 <class_sizes>
ffffffffc02008f6:	00005617          	auipc	a2,0x5
ffffffffc02008fa:	7ea60613          	addi	a2,a2,2026 # ffffffffc02060e0 <sp_pool>
ffffffffc02008fe:	46c1                	li	a3,16
ffffffffc0200900:	a011                	j	ffffffffc0200904 <slub_init+0x48>
        caches[i].object_size = class_sizes[i];
ffffffffc0200902:	6314                	ld	a3,0(a4)
ffffffffc0200904:	e394                	sd	a3,0(a5)
        caches[i].partial = NULL;
ffffffffc0200906:	0007b423          	sd	zero,8(a5)
        caches[i].full = NULL;
ffffffffc020090a:	0007b823          	sd	zero,16(a5)
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc020090e:	07e1                	addi	a5,a5,24
ffffffffc0200910:	0721                	addi	a4,a4,8
ffffffffc0200912:	fec798e3          	bne	a5,a2,ffffffffc0200902 <slub_init+0x46>
}
ffffffffc0200916:	8082                	ret

ffffffffc0200918 <kmalloc>:
void *kmalloc(size_t size) {
ffffffffc0200918:	711d                	addi	sp,sp,-96
ffffffffc020091a:	e0ca                	sd	s2,64(sp)
ffffffffc020091c:	f05a                	sd	s6,32(sp)
ffffffffc020091e:	ec86                	sd	ra,88(sp)
ffffffffc0200920:	e8a2                	sd	s0,80(sp)
ffffffffc0200922:	e4a6                	sd	s1,72(sp)
ffffffffc0200924:	fc4e                	sd	s3,56(sp)
ffffffffc0200926:	f852                	sd	s4,48(sp)
ffffffffc0200928:	f456                	sd	s5,40(sp)
ffffffffc020092a:	ec5e                	sd	s7,24(sp)
ffffffffc020092c:	e862                	sd	s8,16(sp)
ffffffffc020092e:	e466                	sd	s9,8(sp)
ffffffffc0200930:	e06a                	sd	s10,0(sp)
    size = size < sizeof(void*) ? sizeof(void*) : size;
ffffffffc0200932:	47a1                	li	a5,8
void *kmalloc(size_t size) {
ffffffffc0200934:	892a                	mv	s2,a0
    size = size < sizeof(void*) ? sizeof(void*) : size;
ffffffffc0200936:	4b21                	li	s6,8
ffffffffc0200938:	00f56363          	bltu	a0,a5,ffffffffc020093e <kmalloc+0x26>
ffffffffc020093c:	8b2a                	mv	s6,a0
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc020093e:	59f5                	li	s3,-3
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200940:	4ba1                	li	s7,8
    if (cache->partial == NULL) {
ffffffffc0200942:	00005c17          	auipc	s8,0x5
ffffffffc0200946:	6dec0c13          	addi	s8,s8,1758 # ffffffffc0206020 <caches>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020094a:	00008d17          	auipc	s10,0x8
ffffffffc020094e:	97ed0d13          	addi	s10,s10,-1666 # ffffffffc02082c8 <pages>
ffffffffc0200952:	00002a17          	auipc	s4,0x2
ffffffffc0200956:	e76a3a03          	ld	s4,-394(s4) # ffffffffc02027c8 <nbase+0x8>
ffffffffc020095a:	00002c97          	auipc	s9,0x2
ffffffffc020095e:	e66c8c93          	addi	s9,s9,-410 # ffffffffc02027c0 <nbase>
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc0200962:	09fa                	slli	s3,s3,0x1e
void *kmalloc(size_t size) {
ffffffffc0200964:	4741                	li	a4,16
ffffffffc0200966:	00002797          	auipc	a5,0x2
ffffffffc020096a:	80a78793          	addi	a5,a5,-2038 # ffffffffc0202170 <class_sizes>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc020096e:	4401                	li	s0,0
        if (class_sizes[i] >= size) return i;
ffffffffc0200970:	01677963          	bgeu	a4,s6,ffffffffc0200982 <kmalloc+0x6a>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200974:	2405                	addiw	s0,s0,1
ffffffffc0200976:	07a1                	addi	a5,a5,8
ffffffffc0200978:	0f740863          	beq	s0,s7,ffffffffc0200a68 <kmalloc+0x150>
        if (class_sizes[i] >= size) return i;
ffffffffc020097c:	6398                	ld	a4,0(a5)
ffffffffc020097e:	ff676be3          	bltu	a4,s6,ffffffffc0200974 <kmalloc+0x5c>
    if (cache->partial == NULL) {
ffffffffc0200982:	00141493          	slli	s1,s0,0x1
ffffffffc0200986:	00848ab3          	add	s5,s1,s0
ffffffffc020098a:	0a8e                	slli	s5,s5,0x3
ffffffffc020098c:	9ae2                	add	s5,s5,s8
ffffffffc020098e:	008ab783          	ld	a5,8(s5)
ffffffffc0200992:	cf81                	beqz	a5,ffffffffc02009aa <kmalloc+0x92>
    void *obj = sp->free_head;
ffffffffc0200994:	6788                	ld	a0,8(a5)
    if (obj == NULL) {
ffffffffc0200996:	e54d                	bnez	a0,ffffffffc0200a40 <kmalloc+0x128>
        cache->partial = sp->next;
ffffffffc0200998:	9426                	add	s0,s0,s1
ffffffffc020099a:	040e                	slli	s0,s0,0x3
ffffffffc020099c:	6f94                	ld	a3,24(a5)
ffffffffc020099e:	9462                	add	s0,s0,s8
        sp->next = cache->full;
ffffffffc02009a0:	6818                	ld	a4,16(s0)
        cache->partial = sp->next;
ffffffffc02009a2:	e414                	sd	a3,8(s0)
        sp->next = cache->full;
ffffffffc02009a4:	ef98                	sd	a4,24(a5)
        cache->full = sp;
ffffffffc02009a6:	e81c                	sd	a5,16(s0)
        return kmalloc(size);
ffffffffc02009a8:	bf75                	j	ffffffffc0200964 <kmalloc+0x4c>
    struct Page *pg = alloc_page();
ffffffffc02009aa:	4505                	li	a0,1
ffffffffc02009ac:	c25ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc02009b0:	862a                	mv	a2,a0
    if (pg == NULL) return NULL;
ffffffffc02009b2:	12050463          	beqz	a0,ffffffffc0200ada <kmalloc+0x1c2>
ffffffffc02009b6:	000d3783          	ld	a5,0(s10)
ffffffffc02009ba:	000cb683          	ld	a3,0(s9)
    size_t obj_size = cache->object_size;
ffffffffc02009be:	000ab803          	ld	a6,0(s5)
ffffffffc02009c2:	40f507b3          	sub	a5,a0,a5
ffffffffc02009c6:	878d                	srai	a5,a5,0x3
ffffffffc02009c8:	034787b3          	mul	a5,a5,s4
    size_t objs = PGSIZE / obj_size;
ffffffffc02009cc:	6705                	lui	a4,0x1
ffffffffc02009ce:	97b6                	add	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02009d0:	07b2                	slli	a5,a5,0xc
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc02009d2:	97ce                	add	a5,a5,s3
    size_t objs = PGSIZE / obj_size;
ffffffffc02009d4:	030755b3          	divu	a1,a4,a6
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc02009d8:	88be                	mv	a7,a5
    if (objs == 0) {
ffffffffc02009da:	11076263          	bltu	a4,a6,ffffffffc0200ade <kmalloc+0x1c6>
    void *head = NULL;
ffffffffc02009de:	4701                	li	a4,0
    for (size_t i = 0; i < objs; i++) {
ffffffffc02009e0:	4681                	li	a3,0
        *slot = head;
ffffffffc02009e2:	e398                	sd	a4,0(a5)
    for (size_t i = 0; i < objs; i++) {
ffffffffc02009e4:	0685                	addi	a3,a3,1
        void **slot = (void **)((char *)mem + i * obj_size);
ffffffffc02009e6:	873e                	mv	a4,a5
    for (size_t i = 0; i < objs; i++) {
ffffffffc02009e8:	97c2                	add	a5,a5,a6
ffffffffc02009ea:	feb6ece3          	bltu	a3,a1,ffffffffc02009e2 <kmalloc+0xca>
ffffffffc02009ee:	6705                	lui	a4,0x1
ffffffffc02009f0:	4781                	li	a5,0
ffffffffc02009f2:	01076463          	bltu	a4,a6,ffffffffc02009fa <kmalloc+0xe2>
ffffffffc02009f6:	fff58793          	addi	a5,a1,-1
    if (sp_freelist_head < 0) return NULL;
ffffffffc02009fa:	00005517          	auipc	a0,0x5
ffffffffc02009fe:	61650513          	addi	a0,a0,1558 # ffffffffc0206010 <sp_freelist_head>
ffffffffc0200a02:	03078733          	mul	a4,a5,a6
ffffffffc0200a06:	411c                	lw	a5,0(a0)
ffffffffc0200a08:	98ba                	add	a7,a7,a4
ffffffffc0200a0a:	0c07c463          	bltz	a5,ffffffffc0200ad2 <kmalloc+0x1ba>
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;
ffffffffc0200a0e:	00005697          	auipc	a3,0x5
ffffffffc0200a12:	6d268693          	addi	a3,a3,1746 # ffffffffc02060e0 <sp_pool>
ffffffffc0200a16:	0796                	slli	a5,a5,0x5
ffffffffc0200a18:	97b6                	add	a5,a5,a3
    sp->next = cache->partial;
ffffffffc0200a1a:	00848733          	add	a4,s1,s0
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;
ffffffffc0200a1e:	0187b803          	ld	a6,24(a5)
    sp->next = cache->partial;
ffffffffc0200a22:	070e                	slli	a4,a4,0x3
ffffffffc0200a24:	9762                	add	a4,a4,s8
ffffffffc0200a26:	6714                	ld	a3,8(a4)
    sp->free_head = head;
ffffffffc0200a28:	0117b423          	sd	a7,8(a5)
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;
ffffffffc0200a2c:	01052023          	sw	a6,0(a0)
    void *obj = sp->free_head;
ffffffffc0200a30:	6788                	ld	a0,8(a5)
    sp->page = pg;
ffffffffc0200a32:	e390                	sd	a2,0(a5)
    sp->inuse = 0;
ffffffffc0200a34:	0007a823          	sw	zero,16(a5)
    sp->capacity = (unsigned int)objs;
ffffffffc0200a38:	cbcc                	sw	a1,20(a5)
    sp->next = cache->partial;
ffffffffc0200a3a:	ef94                	sd	a3,24(a5)
    cache->partial = sp;
ffffffffc0200a3c:	e71c                	sd	a5,8(a4)
    if (obj == NULL) {
ffffffffc0200a3e:	dd29                	beqz	a0,ffffffffc0200998 <kmalloc+0x80>
    sp->inuse++;
ffffffffc0200a40:	4b98                	lw	a4,16(a5)
    sp->free_head = *(void **)obj;
ffffffffc0200a42:	6114                	ld	a3,0(a0)
    if (sp->inuse == sp->capacity) {
ffffffffc0200a44:	4bd0                	lw	a2,20(a5)
    sp->inuse++;
ffffffffc0200a46:	2705                	addiw	a4,a4,1
    sp->free_head = *(void **)obj;
ffffffffc0200a48:	e794                	sd	a3,8(a5)
    sp->inuse++;
ffffffffc0200a4a:	cb98                	sw	a4,16(a5)
ffffffffc0200a4c:	0007069b          	sext.w	a3,a4
    if (sp->inuse == sp->capacity) {
ffffffffc0200a50:	06d61363          	bne	a2,a3,ffffffffc0200ab6 <kmalloc+0x19e>
        cache->partial = sp->next;
ffffffffc0200a54:	00848733          	add	a4,s1,s0
ffffffffc0200a58:	070e                	slli	a4,a4,0x3
ffffffffc0200a5a:	6f90                	ld	a2,24(a5)
ffffffffc0200a5c:	9762                	add	a4,a4,s8
        sp->next = cache->full;
ffffffffc0200a5e:	6b14                	ld	a3,16(a4)
        cache->partial = sp->next;
ffffffffc0200a60:	e710                	sd	a2,8(a4)
        sp->next = cache->full;
ffffffffc0200a62:	ef94                	sd	a3,24(a5)
        cache->full = sp;
ffffffffc0200a64:	eb1c                	sd	a5,16(a4)
ffffffffc0200a66:	a881                	j	ffffffffc0200ab6 <kmalloc+0x19e>
    return (x + a - 1) & ~(a - 1);
ffffffffc0200a68:	6405                	lui	s0,0x1
ffffffffc0200a6a:	147d                	addi	s0,s0,-1
ffffffffc0200a6c:	944a                	add	s0,s0,s2
        size_t pages_need = bytes / PGSIZE;
ffffffffc0200a6e:	8031                	srli	s0,s0,0xc
        struct Page *pg = alloc_pages(pages_need);
ffffffffc0200a70:	8522                	mv	a0,s0
ffffffffc0200a72:	b5fff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
        if (pg == NULL) return NULL;
ffffffffc0200a76:	c135                	beqz	a0,ffffffffc0200ada <kmalloc+0x1c2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a78:	00008797          	auipc	a5,0x8
ffffffffc0200a7c:	8507b783          	ld	a5,-1968(a5) # ffffffffc02082c8 <pages>
ffffffffc0200a80:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a84:	00002717          	auipc	a4,0x2
ffffffffc0200a88:	d4473703          	ld	a4,-700(a4) # ffffffffc02027c8 <nbase+0x8>
ffffffffc0200a8c:	878d                	srai	a5,a5,0x3
ffffffffc0200a8e:	02e787b3          	mul	a5,a5,a4
ffffffffc0200a92:	00002717          	auipc	a4,0x2
ffffffffc0200a96:	d2e73703          	ld	a4,-722(a4) # ffffffffc02027c0 <nbase>
ffffffffc0200a9a:	97ba                	add	a5,a5,a4
        void *kva = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc0200a9c:	5775                	li	a4,-3
ffffffffc0200a9e:	077a                	slli	a4,a4,0x1e
    return page2ppn(page) << PGSHIFT;
ffffffffc0200aa0:	07b2                	slli	a5,a5,0xc
ffffffffc0200aa2:	97ba                	add	a5,a5,a4
        hdr->magic = LARGE_MAGIC;
ffffffffc0200aa4:	4c524737          	lui	a4,0x4c524
ffffffffc0200aa8:	74c70713          	addi	a4,a4,1868 # 4c52474c <kern_entry-0xffffffff73cdb8b4>
        hdr->page = pg;
ffffffffc0200aac:	e788                	sd	a0,8(a5)
        hdr->magic = LARGE_MAGIC;
ffffffffc0200aae:	c398                	sw	a4,0(a5)
        hdr->pages = (uint32_t)pages_need;
ffffffffc0200ab0:	c3c0                	sw	s0,4(a5)
        return (void *)((char *)kva + sizeof(large_hdr_t));
ffffffffc0200ab2:	01078513          	addi	a0,a5,16
}
ffffffffc0200ab6:	60e6                	ld	ra,88(sp)
ffffffffc0200ab8:	6446                	ld	s0,80(sp)
ffffffffc0200aba:	64a6                	ld	s1,72(sp)
ffffffffc0200abc:	6906                	ld	s2,64(sp)
ffffffffc0200abe:	79e2                	ld	s3,56(sp)
ffffffffc0200ac0:	7a42                	ld	s4,48(sp)
ffffffffc0200ac2:	7aa2                	ld	s5,40(sp)
ffffffffc0200ac4:	7b02                	ld	s6,32(sp)
ffffffffc0200ac6:	6be2                	ld	s7,24(sp)
ffffffffc0200ac8:	6c42                	ld	s8,16(sp)
ffffffffc0200aca:	6ca2                	ld	s9,8(sp)
ffffffffc0200acc:	6d02                	ld	s10,0(sp)
ffffffffc0200ace:	6125                	addi	sp,sp,96
ffffffffc0200ad0:	8082                	ret
        free_page(pg);
ffffffffc0200ad2:	4585                	li	a1,1
ffffffffc0200ad4:	8532                	mv	a0,a2
ffffffffc0200ad6:	b07ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
        if (new_slab_page(cache) == NULL) return NULL;
ffffffffc0200ada:	4501                	li	a0,0
ffffffffc0200adc:	bfe9                	j	ffffffffc0200ab6 <kmalloc+0x19e>
        free_page(pg);
ffffffffc0200ade:	4585                	li	a1,1
ffffffffc0200ae0:	afdff0ef          	jal	ra,ffffffffc02005dc <free_pages>
        if (new_slab_page(cache) == NULL) return NULL;
ffffffffc0200ae4:	4501                	li	a0,0
ffffffffc0200ae6:	bfc1                	j	ffffffffc0200ab6 <kmalloc+0x19e>

ffffffffc0200ae8 <kfree>:

void kfree(void *ptr) {
    if (ptr == NULL) return;
ffffffffc0200ae8:	cd2d                	beqz	a0,ffffffffc0200b62 <kfree+0x7a>
void kfree(void *ptr) {
ffffffffc0200aea:	1101                	addi	sp,sp,-32
ffffffffc0200aec:	e822                	sd	s0,16(sp)
ffffffffc0200aee:	e426                	sd	s1,8(sp)
ffffffffc0200af0:	e04a                	sd	s2,0(sp)
ffffffffc0200af2:	ec06                	sd	ra,24(sp)
ffffffffc0200af4:	84aa                	mv	s1,a0
ffffffffc0200af6:	00005417          	auipc	s0,0x5
ffffffffc0200afa:	52a40413          	addi	s0,s0,1322 # ffffffffc0206020 <caches>
ffffffffc0200afe:	00005917          	auipc	s2,0x5
ffffffffc0200b02:	5e290913          	addi	s2,s2,1506 # ffffffffc02060e0 <sp_pool>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        if (free_in_list(&caches[i].partial, &caches[i], ptr)) return;
ffffffffc0200b06:	85a2                	mv	a1,s0
ffffffffc0200b08:	8626                	mv	a2,s1
ffffffffc0200b0a:	00840513          	addi	a0,s0,8
ffffffffc0200b0e:	cb9ff0ef          	jal	ra,ffffffffc02007c6 <free_in_list>
ffffffffc0200b12:	87aa                	mv	a5,a0
        if (free_in_list(&caches[i].full, &caches[i], ptr)) return;
ffffffffc0200b14:	85a2                	mv	a1,s0
ffffffffc0200b16:	01040513          	addi	a0,s0,16
ffffffffc0200b1a:	8626                	mv	a2,s1
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200b1c:	0461                	addi	s0,s0,24
        if (free_in_list(&caches[i].partial, &caches[i], ptr)) return;
ffffffffc0200b1e:	ef91                	bnez	a5,ffffffffc0200b3a <kfree+0x52>
        if (free_in_list(&caches[i].full, &caches[i], ptr)) return;
ffffffffc0200b20:	ca7ff0ef          	jal	ra,ffffffffc02007c6 <free_in_list>
ffffffffc0200b24:	e919                	bnez	a0,ffffffffc0200b3a <kfree+0x52>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200b26:	fe8910e3          	bne	s2,s0,ffffffffc0200b06 <kfree+0x1e>
    }
    large_hdr_t *hdr = (large_hdr_t *)((char *)ptr - sizeof(large_hdr_t));
    if (hdr->magic == LARGE_MAGIC && hdr->page != NULL && hdr->pages > 0) {
ffffffffc0200b2a:	ff04a703          	lw	a4,-16(s1)
ffffffffc0200b2e:	4c5247b7          	lui	a5,0x4c524
ffffffffc0200b32:	74c78793          	addi	a5,a5,1868 # 4c52474c <kern_entry-0xffffffff73cdb8b4>
ffffffffc0200b36:	00f70863          	beq	a4,a5,ffffffffc0200b46 <kfree+0x5e>
        free_pages(hdr->page, hdr->pages);
    }
}
ffffffffc0200b3a:	60e2                	ld	ra,24(sp)
ffffffffc0200b3c:	6442                	ld	s0,16(sp)
ffffffffc0200b3e:	64a2                	ld	s1,8(sp)
ffffffffc0200b40:	6902                	ld	s2,0(sp)
ffffffffc0200b42:	6105                	addi	sp,sp,32
ffffffffc0200b44:	8082                	ret
    if (hdr->magic == LARGE_MAGIC && hdr->page != NULL && hdr->pages > 0) {
ffffffffc0200b46:	ff84b503          	ld	a0,-8(s1)
ffffffffc0200b4a:	d965                	beqz	a0,ffffffffc0200b3a <kfree+0x52>
ffffffffc0200b4c:	ff44a583          	lw	a1,-12(s1)
ffffffffc0200b50:	d5ed                	beqz	a1,ffffffffc0200b3a <kfree+0x52>
}
ffffffffc0200b52:	6442                	ld	s0,16(sp)
ffffffffc0200b54:	60e2                	ld	ra,24(sp)
ffffffffc0200b56:	64a2                	ld	s1,8(sp)
ffffffffc0200b58:	6902                	ld	s2,0(sp)
        free_pages(hdr->page, hdr->pages);
ffffffffc0200b5a:	1582                	slli	a1,a1,0x20
ffffffffc0200b5c:	9181                	srli	a1,a1,0x20
}
ffffffffc0200b5e:	6105                	addi	sp,sp,32
        free_pages(hdr->page, hdr->pages);
ffffffffc0200b60:	bcb5                	j	ffffffffc02005dc <free_pages>
ffffffffc0200b62:	8082                	ret

ffffffffc0200b64 <slub_check>:

void slub_check(void) {
ffffffffc0200b64:	1101                	addi	sp,sp,-32
    void *a = kmalloc(24);
ffffffffc0200b66:	4561                	li	a0,24
void slub_check(void) {
ffffffffc0200b68:	ec06                	sd	ra,24(sp)
ffffffffc0200b6a:	e822                	sd	s0,16(sp)
ffffffffc0200b6c:	e04a                	sd	s2,0(sp)
ffffffffc0200b6e:	e426                	sd	s1,8(sp)
    void *a = kmalloc(24);
ffffffffc0200b70:	da9ff0ef          	jal	ra,ffffffffc0200918 <kmalloc>
ffffffffc0200b74:	842a                	mv	s0,a0
    void *b = kmalloc(200);
ffffffffc0200b76:	0c800513          	li	a0,200
ffffffffc0200b7a:	d9fff0ef          	jal	ra,ffffffffc0200918 <kmalloc>
ffffffffc0200b7e:	892a                	mv	s2,a0
    void *c = kmalloc(1024);
ffffffffc0200b80:	40000513          	li	a0,1024
ffffffffc0200b84:	d95ff0ef          	jal	ra,ffffffffc0200918 <kmalloc>
    assert(a != NULL && b != NULL && c != NULL);
ffffffffc0200b88:	c015                	beqz	s0,ffffffffc0200bac <slub_check+0x48>
ffffffffc0200b8a:	02090163          	beqz	s2,ffffffffc0200bac <slub_check+0x48>
ffffffffc0200b8e:	84aa                	mv	s1,a0
ffffffffc0200b90:	cd11                	beqz	a0,ffffffffc0200bac <slub_check+0x48>
    kfree(a);
ffffffffc0200b92:	8522                	mv	a0,s0
ffffffffc0200b94:	f55ff0ef          	jal	ra,ffffffffc0200ae8 <kfree>
    kfree(b);
ffffffffc0200b98:	854a                	mv	a0,s2
ffffffffc0200b9a:	f4fff0ef          	jal	ra,ffffffffc0200ae8 <kfree>
    kfree(c);
}
ffffffffc0200b9e:	6442                	ld	s0,16(sp)
ffffffffc0200ba0:	60e2                	ld	ra,24(sp)
ffffffffc0200ba2:	6902                	ld	s2,0(sp)
    kfree(c);
ffffffffc0200ba4:	8526                	mv	a0,s1
}
ffffffffc0200ba6:	64a2                	ld	s1,8(sp)
ffffffffc0200ba8:	6105                	addi	sp,sp,32
    kfree(c);
ffffffffc0200baa:	bf3d                	j	ffffffffc0200ae8 <kfree>
    assert(a != NULL && b != NULL && c != NULL);
ffffffffc0200bac:	00001697          	auipc	a3,0x1
ffffffffc0200bb0:	57468693          	addi	a3,a3,1396 # ffffffffc0202120 <etext+0x3ac>
ffffffffc0200bb4:	00001617          	auipc	a2,0x1
ffffffffc0200bb8:	59460613          	addi	a2,a2,1428 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0200bbc:	0c400593          	li	a1,196
ffffffffc0200bc0:	00001517          	auipc	a0,0x1
ffffffffc0200bc4:	5a050513          	addi	a0,a0,1440 # ffffffffc0202160 <etext+0x3ec>
ffffffffc0200bc8:	dfaff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200bcc <insert_region>:
static size_t buddy_total_free = 0;

#define order_free_list(order) (buddy_area[(order)].free_list)
#define order_nr_free(order)   (buddy_area[(order)].nr_free)

static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc0200bcc:	00007e97          	auipc	t4,0x7
ffffffffc0200bd0:	6fcebe83          	ld	t4,1788(t4) # ffffffffc02082c8 <pages>
ffffffffc0200bd4:	41d50533          	sub	a0,a0,t4
ffffffffc0200bd8:	850d                	srai	a0,a0,0x3
ffffffffc0200bda:	00002f17          	auipc	t5,0x2
ffffffffc0200bde:	beef3f03          	ld	t5,-1042(t5) # ffffffffc02027c8 <nbase+0x8>
ffffffffc0200be2:	03e50533          	mul	a0,a0,t5
 * Insert and merge a contiguous region [base, base+n) into buddy free lists.
 * Greedy split into maximal aligned blocks at each step, then coalesce upward.
 */
static void insert_region(struct Page *base, size_t n) {
    size_t idx = page_index(base);
    while (n > 0) {
ffffffffc0200be6:	12058f63          	beqz	a1,ffffffffc0200d24 <insert_region+0x158>
static void insert_region(struct Page *base, size_t n) {
ffffffffc0200bea:	1101                	addi	sp,sp,-32
ffffffffc0200bec:	ec22                	sd	s0,24(sp)
ffffffffc0200bee:	e826                	sd	s1,16(sp)
ffffffffc0200bf0:	e44a                	sd	s2,8(sp)
ffffffffc0200bf2:	e04e                	sd	s3,0(sp)
ffffffffc0200bf4:	00007e17          	auipc	t3,0x7
ffffffffc0200bf8:	4ece0e13          	addi	t3,t3,1260 # ffffffffc02080e0 <buddy_area>
ffffffffc0200bfc:	4885                	li	a7,1
ffffffffc0200bfe:	4349                	li	t1,18
        unsigned int order = 0;
        size_t max_fit = 1;
ffffffffc0200c00:	4705                	li	a4,1
        unsigned int order = 0;
ffffffffc0200c02:	4781                	li	a5,0
        while (order < BUDDY_MAX_ORDER) {
            size_t blk = order_block_pages(order + 1);
            if (blk > n) break;
            if ((idx & (blk - 1)) != 0) break;
ffffffffc0200c04:	0007861b          	sext.w	a2,a5
            size_t blk = order_block_pages(order + 1);
ffffffffc0200c08:	2785                	addiw	a5,a5,1
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0200c0a:	883a                	mv	a6,a4
ffffffffc0200c0c:	00f89733          	sll	a4,a7,a5
            if ((idx & (blk - 1)) != 0) break;
ffffffffc0200c10:	fff70693          	addi	a3,a4,-1
ffffffffc0200c14:	8ee9                	and	a3,a3,a0
            if (blk > n) break;
ffffffffc0200c16:	02e5e363          	bltu	a1,a4,ffffffffc0200c3c <insert_region+0x70>
            if ((idx & (blk - 1)) != 0) break;
ffffffffc0200c1a:	e28d                	bnez	a3,ffffffffc0200c3c <insert_region+0x70>
        while (order < BUDDY_MAX_ORDER) {
ffffffffc0200c1c:	fe6794e3          	bne	a5,t1,ffffffffc0200c04 <insert_region+0x38>
static inline struct Page *index_to_page(size_t idx) { return pages + idx; }
ffffffffc0200c20:	00251793          	slli	a5,a0,0x2
ffffffffc0200c24:	97aa                	add	a5,a5,a0
ffffffffc0200c26:	078e                	slli	a5,a5,0x3
ffffffffc0200c28:	97f6                	add	a5,a5,t4
ffffffffc0200c2a:	4649                	li	a2,18
ffffffffc0200c2c:	00040fb7          	lui	t6,0x40
ffffffffc0200c30:	1b000693          	li	a3,432
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0200c34:	00040837          	lui	a6,0x40
ffffffffc0200c38:	42c9                	li	t0,18
ffffffffc0200c3a:	a8a1                	j	ffffffffc0200c92 <insert_region+0xc6>
static inline struct Page *index_to_page(size_t idx) { return pages + idx; }
ffffffffc0200c3c:	00251793          	slli	a5,a0,0x2
ffffffffc0200c40:	97aa                	add	a5,a5,a0
ffffffffc0200c42:	078e                	slli	a5,a5,0x3
static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc0200c44:	4037d293          	srai	t0,a5,0x3
ffffffffc0200c48:	03e282b3          	mul	t0,t0,t5
ffffffffc0200c4c:	02061693          	slli	a3,a2,0x20
ffffffffc0200c50:	9281                	srli	a3,a3,0x20
ffffffffc0200c52:	00169713          	slli	a4,a3,0x1
ffffffffc0200c56:	9736                	add	a4,a4,a3
ffffffffc0200c58:	070e                	slli	a4,a4,0x3
static inline struct Page *index_to_page(size_t idx) { return pages + idx; }
ffffffffc0200c5a:	97f6                	add	a5,a5,t4
    while (order < BUDDY_MAX_ORDER) {
ffffffffc0200c5c:	00ee06b3          	add	a3,t3,a4
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0200c60:	00c89fb3          	sll	t6,a7,a2
        size_t buddy_idx = idx ^ order_block_pages(order);
ffffffffc0200c64:	005fc3b3          	xor	t2,t6,t0
static inline struct Page *index_to_page(size_t idx) { return pages + idx; }
ffffffffc0200c68:	00239713          	slli	a4,t2,0x2
ffffffffc0200c6c:	971e                	add	a4,a4,t2
ffffffffc0200c6e:	070e                	slli	a4,a4,0x3
ffffffffc0200c70:	9776                	add	a4,a4,t4
        if (PageProperty(buddy_head) && buddy_head->property == order) {
ffffffffc0200c72:	6700                	ld	s0,8(a4)
            order_nr_free(order) -= order_block_pages(order);
ffffffffc0200c74:	2f81                	sext.w	t6,t6
        if (PageProperty(buddy_head) && buddy_head->property == order) {
ffffffffc0200c76:	00247493          	andi	s1,s0,2
ffffffffc0200c7a:	c481                	beqz	s1,ffffffffc0200c82 <insert_region+0xb6>
ffffffffc0200c7c:	4b04                	lw	s1,16(a4)
ffffffffc0200c7e:	06c48163          	beq	s1,a2,ffffffffc0200ce0 <insert_region+0x114>
ffffffffc0200c82:	02061293          	slli	t0,a2,0x20
ffffffffc0200c86:	0202d293          	srli	t0,t0,0x20
ffffffffc0200c8a:	00129693          	slli	a3,t0,0x1
ffffffffc0200c8e:	9696                	add	a3,a3,t0
ffffffffc0200c90:	068e                	slli	a3,a3,0x3
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c92:	00129713          	slli	a4,t0,0x1
ffffffffc0200c96:	9716                	add	a4,a4,t0
ffffffffc0200c98:	070e                	slli	a4,a4,0x3
    SetPageProperty(base);
ffffffffc0200c9a:	0087b283          	ld	t0,8(a5)
ffffffffc0200c9e:	9772                	add	a4,a4,t3
ffffffffc0200ca0:	00873383          	ld	t2,8(a4)
ffffffffc0200ca4:	0022e293          	ori	t0,t0,2
    base->property = order;
ffffffffc0200ca8:	cb90                	sw	a2,16(a5)
    SetPageProperty(base);
ffffffffc0200caa:	0057b423          	sd	t0,8(a5)
    order_nr_free(order) += order_block_pages(order);
ffffffffc0200cae:	4b10                	lw	a2,16(a4)
    list_add(&order_free_list(order), &(base->page_link));
ffffffffc0200cb0:	01878293          	addi	t0,a5,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200cb4:	0053b023          	sd	t0,0(t2)
ffffffffc0200cb8:	00573423          	sd	t0,8(a4)
ffffffffc0200cbc:	96f2                	add	a3,a3,t3
    elm->next = next;
ffffffffc0200cbe:	0277b023          	sd	t2,32(a5)
    elm->prev = prev;
ffffffffc0200cc2:	ef94                	sd	a3,24(a5)
    order_nr_free(order) += order_block_pages(order);
ffffffffc0200cc4:	01f60fbb          	addw	t6,a2,t6
ffffffffc0200cc8:	01f72823          	sw	t6,16(a4)
            order++;
            max_fit = blk;
        }
        try_coalesce_and_insert(index_to_page(idx), order);
        idx += max_fit;
        n   -= max_fit;
ffffffffc0200ccc:	410585b3          	sub	a1,a1,a6
        idx += max_fit;
ffffffffc0200cd0:	9542                	add	a0,a0,a6
    while (n > 0) {
ffffffffc0200cd2:	f59d                	bnez	a1,ffffffffc0200c00 <insert_region+0x34>
    }
}
ffffffffc0200cd4:	6462                	ld	s0,24(sp)
ffffffffc0200cd6:	64c2                	ld	s1,16(sp)
ffffffffc0200cd8:	6922                	ld	s2,8(sp)
ffffffffc0200cda:	6982                	ld	s3,0(sp)
ffffffffc0200cdc:	6105                	addi	sp,sp,32
ffffffffc0200cde:	8082                	ret
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ce0:	01873983          	ld	s3,24(a4)
ffffffffc0200ce4:	02073903          	ld	s2,32(a4)
            order_nr_free(order) -= order_block_pages(order);
ffffffffc0200ce8:	4a84                	lw	s1,16(a3)
            ClearPageProperty(buddy_head);
ffffffffc0200cea:	9875                	andi	s0,s0,-3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200cec:	0129b423          	sd	s2,8(s3)
    next->prev = prev;
ffffffffc0200cf0:	01393023          	sd	s3,0(s2)
            order_nr_free(order) -= order_block_pages(order);
ffffffffc0200cf4:	41f48fbb          	subw	t6,s1,t6
ffffffffc0200cf8:	01f6a823          	sw	t6,16(a3)
            ClearPageProperty(buddy_head);
ffffffffc0200cfc:	e700                	sd	s0,8(a4)
            buddy_head->property = 0;
ffffffffc0200cfe:	00072823          	sw	zero,16(a4)
            order++;
ffffffffc0200d02:	2605                	addiw	a2,a2,1
            if (buddy_idx < idx) {
ffffffffc0200d04:	0053f463          	bgeu	t2,t0,ffffffffc0200d0c <insert_region+0x140>
ffffffffc0200d08:	829e                	mv	t0,t2
ffffffffc0200d0a:	87ba                	mv	a5,a4
    while (order < BUDDY_MAX_ORDER) {
ffffffffc0200d0c:	06e1                	addi	a3,a3,24
ffffffffc0200d0e:	f46619e3          	bne	a2,t1,ffffffffc0200c60 <insert_region+0x94>
ffffffffc0200d12:	02061293          	slli	t0,a2,0x20
ffffffffc0200d16:	00040fb7          	lui	t6,0x40
ffffffffc0200d1a:	1b000693          	li	a3,432
ffffffffc0200d1e:	0202d293          	srli	t0,t0,0x20
ffffffffc0200d22:	bf85                	j	ffffffffc0200c92 <insert_region+0xc6>
ffffffffc0200d24:	8082                	ret

ffffffffc0200d26 <buddy_init>:
        insert_region(suffix, suffix_pages);
    }
}

static void buddy_init(void) {
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200d26:	00007797          	auipc	a5,0x7
ffffffffc0200d2a:	3ba78793          	addi	a5,a5,954 # ffffffffc02080e0 <buddy_area>
ffffffffc0200d2e:	00007717          	auipc	a4,0x7
ffffffffc0200d32:	57a70713          	addi	a4,a4,1402 # ffffffffc02082a8 <is_panic>
    elm->prev = elm->next = elm;
ffffffffc0200d36:	e79c                	sd	a5,8(a5)
ffffffffc0200d38:	e39c                	sd	a5,0(a5)
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
ffffffffc0200d3a:	0007a823          	sw	zero,16(a5)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200d3e:	07e1                	addi	a5,a5,24
ffffffffc0200d40:	fee79be3          	bne	a5,a4,ffffffffc0200d36 <buddy_init+0x10>
    }
    buddy_total_free = 0;
ffffffffc0200d44:	00007797          	auipc	a5,0x7
ffffffffc0200d48:	5a07b623          	sd	zero,1452(a5) # ffffffffc02082f0 <buddy_total_free>
}
ffffffffc0200d4c:	8082                	ret

ffffffffc0200d4e <buddy_nr_free_pages>:
    }
    insert_region(base, n);
    buddy_total_free += n;
}

static size_t buddy_nr_free_pages(void) { return buddy_total_free; }
ffffffffc0200d4e:	00007517          	auipc	a0,0x7
ffffffffc0200d52:	5a253503          	ld	a0,1442(a0) # ffffffffc02082f0 <buddy_total_free>
ffffffffc0200d56:	8082                	ret

ffffffffc0200d58 <buddy_check>:
    free_page(p1);
    free_page(p2);
    (void)total_store;
}

static void buddy_check(void) {
ffffffffc0200d58:	da010113          	addi	sp,sp,-608
ffffffffc0200d5c:	24813823          	sd	s0,592(sp)
ffffffffc0200d60:	00007417          	auipc	s0,0x7
ffffffffc0200d64:	38040413          	addi	s0,s0,896 # ffffffffc02080e0 <buddy_area>
ffffffffc0200d68:	24113c23          	sd	ra,600(sp)
ffffffffc0200d6c:	24913423          	sd	s1,584(sp)
ffffffffc0200d70:	25213023          	sd	s2,576(sp)
ffffffffc0200d74:	23313c23          	sd	s3,568(sp)
ffffffffc0200d78:	23413823          	sd	s4,560(sp)
ffffffffc0200d7c:	23513423          	sd	s5,552(sp)
ffffffffc0200d80:	23613023          	sd	s6,544(sp)
ffffffffc0200d84:	21713c23          	sd	s7,536(sp)
ffffffffc0200d88:	21813823          	sd	s8,528(sp)
ffffffffc0200d8c:	21913423          	sd	s9,520(sp)
ffffffffc0200d90:	21a13023          	sd	s10,512(sp)
ffffffffc0200d94:	ffee                	sd	s11,504(sp)
ffffffffc0200d96:	8622                	mv	a2,s0
    size_t total = 0;
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200d98:	4581                	li	a1,0
    size_t total = 0;
ffffffffc0200d9a:	4681                	li	a3,0
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0200d9c:	4885                	li	a7,1
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200d9e:	484d                	li	a6,19
    return listelm->next;
ffffffffc0200da0:	661c                	ld	a5,8(a2)
        list_entry_t *le = &order_free_list(i);
        while ((le = list_next(le)) != &order_free_list(i)) {
ffffffffc0200da2:	02c78163          	beq	a5,a2,ffffffffc0200dc4 <buddy_check+0x6c>
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0200da6:	00b89533          	sll	a0,a7,a1
            struct Page *p = le2page(le, page_link);
            assert(PageProperty(p));
ffffffffc0200daa:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200dae:	8b09                	andi	a4,a4,2
ffffffffc0200db0:	4a070b63          	beqz	a4,ffffffffc0201266 <buddy_check+0x50e>
            assert(p->property == i);
ffffffffc0200db4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200db8:	48b71763          	bne	a4,a1,ffffffffc0201246 <buddy_check+0x4ee>
ffffffffc0200dbc:	679c                	ld	a5,8(a5)
            total += order_block_pages(i);
ffffffffc0200dbe:	96aa                	add	a3,a3,a0
        while ((le = list_next(le)) != &order_free_list(i)) {
ffffffffc0200dc0:	fec795e3          	bne	a5,a2,ffffffffc0200daa <buddy_check+0x52>
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200dc4:	2585                	addiw	a1,a1,1
ffffffffc0200dc6:	0661                	addi	a2,a2,24
ffffffffc0200dc8:	fd059ce3          	bne	a1,a6,ffffffffc0200da0 <buddy_check+0x48>
static size_t buddy_nr_free_pages(void) { return buddy_total_free; }
ffffffffc0200dcc:	00007497          	auipc	s1,0x7
ffffffffc0200dd0:	52448493          	addi	s1,s1,1316 # ffffffffc02082f0 <buddy_total_free>
        }
    }
    assert(total == buddy_nr_free_pages());
ffffffffc0200dd4:	609c                	ld	a5,0(s1)
ffffffffc0200dd6:	7cf69863          	bne	a3,a5,ffffffffc02015a6 <buddy_check+0x84e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dda:	4505                	li	a0,1
ffffffffc0200ddc:	ff4ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200de0:	8baa                	mv	s7,a0
ffffffffc0200de2:	060502e3          	beqz	a0,ffffffffc0201646 <buddy_check+0x8ee>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200de6:	4505                	li	a0,1
ffffffffc0200de8:	fe8ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200dec:	8b2a                	mv	s6,a0
ffffffffc0200dee:	6a050c63          	beqz	a0,ffffffffc02014a6 <buddy_check+0x74e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200df2:	4505                	li	a0,1
ffffffffc0200df4:	fdcff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200df8:	89aa                	mv	s3,a0
ffffffffc0200dfa:	000506e3          	beqz	a0,ffffffffc0201606 <buddy_check+0x8ae>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200dfe:	7f6b8463          	beq	s7,s6,ffffffffc02015e6 <buddy_check+0x88e>
ffffffffc0200e02:	7eab8263          	beq	s7,a0,ffffffffc02015e6 <buddy_check+0x88e>
ffffffffc0200e06:	7eab0063          	beq	s6,a0,ffffffffc02015e6 <buddy_check+0x88e>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e0a:	000ba783          	lw	a5,0(s7)
ffffffffc0200e0e:	7a079c63          	bnez	a5,ffffffffc02015c6 <buddy_check+0x86e>
ffffffffc0200e12:	000b2783          	lw	a5,0(s6) # 10000 <kern_entry-0xffffffffc01f0000>
ffffffffc0200e16:	7a079863          	bnez	a5,ffffffffc02015c6 <buddy_check+0x86e>
ffffffffc0200e1a:	411c                	lw	a5,0(a0)
ffffffffc0200e1c:	7a079563          	bnez	a5,ffffffffc02015c6 <buddy_check+0x86e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e20:	00007797          	auipc	a5,0x7
ffffffffc0200e24:	4a878793          	addi	a5,a5,1192 # ffffffffc02082c8 <pages>
ffffffffc0200e28:	639c                	ld	a5,0(a5)
ffffffffc0200e2a:	00002c97          	auipc	s9,0x2
ffffffffc0200e2e:	99ecbc83          	ld	s9,-1634(s9) # ffffffffc02027c8 <nbase+0x8>
ffffffffc0200e32:	00002617          	auipc	a2,0x2
ffffffffc0200e36:	98e63603          	ld	a2,-1650(a2) # ffffffffc02027c0 <nbase>
ffffffffc0200e3a:	40fb8733          	sub	a4,s7,a5
ffffffffc0200e3e:	870d                	srai	a4,a4,0x3
ffffffffc0200e40:	03970733          	mul	a4,a4,s9
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e44:	00007697          	auipc	a3,0x7
ffffffffc0200e48:	47c6b683          	ld	a3,1148(a3) # ffffffffc02082c0 <npage>
ffffffffc0200e4c:	06b2                	slli	a3,a3,0xc
ffffffffc0200e4e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e50:	0732                	slli	a4,a4,0xc
ffffffffc0200e52:	44d77a63          	bgeu	a4,a3,ffffffffc02012a6 <buddy_check+0x54e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e56:	40fb0733          	sub	a4,s6,a5
ffffffffc0200e5a:	870d                	srai	a4,a4,0x3
ffffffffc0200e5c:	03970733          	mul	a4,a4,s9
ffffffffc0200e60:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e62:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e64:	72d77163          	bgeu	a4,a3,ffffffffc0201586 <buddy_check+0x82e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200e68:	40f507b3          	sub	a5,a0,a5
ffffffffc0200e6c:	878d                	srai	a5,a5,0x3
ffffffffc0200e6e:	039787b3          	mul	a5,a5,s9
ffffffffc0200e72:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e74:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e76:	6ed7f863          	bgeu	a5,a3,ffffffffc0201566 <buddy_check+0x80e>
ffffffffc0200e7a:	02810913          	addi	s2,sp,40
ffffffffc0200e7e:	00007a17          	auipc	s4,0x7
ffffffffc0200e82:	42aa0a13          	addi	s4,s4,1066 # ffffffffc02082a8 <is_panic>
ffffffffc0200e86:	874a                	mv	a4,s2
ffffffffc0200e88:	00007797          	auipc	a5,0x7
ffffffffc0200e8c:	25878793          	addi	a5,a5,600 # ffffffffc02080e0 <buddy_area>
        saved[i] = buddy_area[i];
ffffffffc0200e90:	638c                	ld	a1,0(a5)
ffffffffc0200e92:	6790                	ld	a2,8(a5)
ffffffffc0200e94:	6b94                	ld	a3,16(a5)
ffffffffc0200e96:	e30c                	sd	a1,0(a4)
ffffffffc0200e98:	e710                	sd	a2,8(a4)
ffffffffc0200e9a:	eb14                	sd	a3,16(a4)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200e9c:	07e1                	addi	a5,a5,24
ffffffffc0200e9e:	0761                	addi	a4,a4,24
ffffffffc0200ea0:	ff4798e3          	bne	a5,s4,ffffffffc0200e90 <buddy_check+0x138>
    size_t total_saved = buddy_total_free;
ffffffffc0200ea4:	0004ba83          	ld	s5,0(s1)
ffffffffc0200ea8:	00007797          	auipc	a5,0x7
ffffffffc0200eac:	23878793          	addi	a5,a5,568 # ffffffffc02080e0 <buddy_area>
    elm->prev = elm->next = elm;
ffffffffc0200eb0:	e79c                	sd	a5,8(a5)
ffffffffc0200eb2:	e39c                	sd	a5,0(a5)
        order_nr_free(i) = 0;
ffffffffc0200eb4:	0007a823          	sw	zero,16(a5)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200eb8:	07e1                	addi	a5,a5,24
ffffffffc0200eba:	ff479be3          	bne	a5,s4,ffffffffc0200eb0 <buddy_check+0x158>
    assert(alloc_page() == NULL);
ffffffffc0200ebe:	4505                	li	a0,1
    buddy_total_free = 0;
ffffffffc0200ec0:	00007797          	auipc	a5,0x7
ffffffffc0200ec4:	4207b823          	sd	zero,1072(a5) # ffffffffc02082f0 <buddy_total_free>
    assert(alloc_page() == NULL);
ffffffffc0200ec8:	f08ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ecc:	66051d63          	bnez	a0,ffffffffc0201546 <buddy_check+0x7ee>
    free_page(p0);
ffffffffc0200ed0:	4585                	li	a1,1
ffffffffc0200ed2:	855e                	mv	a0,s7
ffffffffc0200ed4:	f08ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200ed8:	4585                	li	a1,1
ffffffffc0200eda:	855a                	mv	a0,s6
ffffffffc0200edc:	f00ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200ee0:	4585                	li	a1,1
ffffffffc0200ee2:	854e                	mv	a0,s3
ffffffffc0200ee4:	ef8ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(buddy_total_free == 3);
ffffffffc0200ee8:	6098                	ld	a4,0(s1)
ffffffffc0200eea:	478d                	li	a5,3
ffffffffc0200eec:	62f71d63          	bne	a4,a5,ffffffffc0201526 <buddy_check+0x7ce>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ef0:	4505                	li	a0,1
ffffffffc0200ef2:	edeff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ef6:	8baa                	mv	s7,a0
ffffffffc0200ef8:	60050763          	beqz	a0,ffffffffc0201506 <buddy_check+0x7ae>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200efc:	4505                	li	a0,1
ffffffffc0200efe:	ed2ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f02:	8b2a                	mv	s6,a0
ffffffffc0200f04:	5e050163          	beqz	a0,ffffffffc02014e6 <buddy_check+0x78e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f08:	4505                	li	a0,1
ffffffffc0200f0a:	ec6ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f0e:	89aa                	mv	s3,a0
ffffffffc0200f10:	5a050b63          	beqz	a0,ffffffffc02014c6 <buddy_check+0x76e>
    assert(alloc_page() == NULL);
ffffffffc0200f14:	4505                	li	a0,1
ffffffffc0200f16:	ebaff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f1a:	74051663          	bnez	a0,ffffffffc0201666 <buddy_check+0x90e>
    free_page(p0);
ffffffffc0200f1e:	4585                	li	a1,1
ffffffffc0200f20:	855e                	mv	a0,s7
ffffffffc0200f22:	ebaff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(buddy_total_free >= 1);
ffffffffc0200f26:	609c                	ld	a5,0(s1)
ffffffffc0200f28:	54078f63          	beqz	a5,ffffffffc0201486 <buddy_check+0x72e>
    assert((p = alloc_page()) == p0);
ffffffffc0200f2c:	4505                	li	a0,1
ffffffffc0200f2e:	ea2ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f32:	8c2a                	mv	s8,a0
ffffffffc0200f34:	52ab9963          	bne	s7,a0,ffffffffc0201466 <buddy_check+0x70e>
    assert(alloc_page() == NULL);
ffffffffc0200f38:	4505                	li	a0,1
ffffffffc0200f3a:	e96ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200f3e:	50051463          	bnez	a0,ffffffffc0201446 <buddy_check+0x6ee>
    assert(buddy_total_free == 0);
ffffffffc0200f42:	6098                	ld	a4,0(s1)
ffffffffc0200f44:	1b8c                	addi	a1,sp,496
ffffffffc0200f46:	00007797          	auipc	a5,0x7
ffffffffc0200f4a:	19a78793          	addi	a5,a5,410 # ffffffffc02080e0 <buddy_area>
ffffffffc0200f4e:	4c071c63          	bnez	a4,ffffffffc0201426 <buddy_check+0x6ce>
        order_free_list(i) = saved[i].free_list;
ffffffffc0200f52:	00093603          	ld	a2,0(s2)
ffffffffc0200f56:	00893683          	ld	a3,8(s2)
        order_nr_free(i) = saved[i].nr_free;
ffffffffc0200f5a:	01092703          	lw	a4,16(s2)
        order_free_list(i) = saved[i].free_list;
ffffffffc0200f5e:	e390                	sd	a2,0(a5)
ffffffffc0200f60:	e794                	sd	a3,8(a5)
        order_nr_free(i) = saved[i].nr_free;
ffffffffc0200f62:	cb98                	sw	a4,16(a5)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200f64:	0961                	addi	s2,s2,24
ffffffffc0200f66:	07e1                	addi	a5,a5,24
ffffffffc0200f68:	ff2595e3          	bne	a1,s2,ffffffffc0200f52 <buddy_check+0x1fa>
    free_page(p);
ffffffffc0200f6c:	4585                	li	a1,1
ffffffffc0200f6e:	8562                	mv	a0,s8
    buddy_total_free = total_saved;
ffffffffc0200f70:	0154b023          	sd	s5,0(s1)
    free_page(p);
ffffffffc0200f74:	e68ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200f78:	4585                	li	a1,1
ffffffffc0200f7a:	855a                	mv	a0,s6
ffffffffc0200f7c:	e60ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200f80:	854e                	mv	a0,s3
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	e58ff0ef          	jal	ra,ffffffffc02005dc <free_pages>

    basic_check();

    size_t before = buddy_nr_free_pages();
    struct Page *q = alloc_pages(3);
ffffffffc0200f88:	450d                	li	a0,3
static size_t buddy_nr_free_pages(void) { return buddy_total_free; }
ffffffffc0200f8a:	0004b983          	ld	s3,0(s1)
    struct Page *q = alloc_pages(3);
ffffffffc0200f8e:	e42ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
    assert(q != NULL);
ffffffffc0200f92:	46050a63          	beqz	a0,ffffffffc0201406 <buddy_check+0x6ae>
    assert(buddy_nr_free_pages() + 3 == before);
ffffffffc0200f96:	0004b903          	ld	s2,0(s1)
ffffffffc0200f9a:	090d                	addi	s2,s2,3
ffffffffc0200f9c:	45391563          	bne	s2,s3,ffffffffc02013e6 <buddy_check+0x68e>
    free_pages(q, 3);
ffffffffc0200fa0:	458d                	li	a1,3
ffffffffc0200fa2:	e3aff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(buddy_nr_free_pages() == before);
ffffffffc0200fa6:	0004b983          	ld	s3,0(s1)
ffffffffc0200faa:	41299e63          	bne	s3,s2,ffffffffc02013c6 <buddy_check+0x66e>

    struct Page *r = alloc_pages(8);
ffffffffc0200fae:	4521                	li	a0,8
ffffffffc0200fb0:	e20ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200fb4:	892a                	mv	s2,a0
    assert(r != NULL);
ffffffffc0200fb6:	3e050863          	beqz	a0,ffffffffc02013a6 <buddy_check+0x64e>
    struct Page *r2 = r + 3;
    free_pages(r2, 5);
ffffffffc0200fba:	4595                	li	a1,5
ffffffffc0200fbc:	07850513          	addi	a0,a0,120
ffffffffc0200fc0:	e1cff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(r, 3);
ffffffffc0200fc4:	458d                	li	a1,3
ffffffffc0200fc6:	854a                	mv	a0,s2
ffffffffc0200fc8:	e14ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
static size_t buddy_nr_free_pages(void) { return buddy_total_free; }
ffffffffc0200fcc:	609c                	ld	a5,0(s1)
ffffffffc0200fce:	e43e                	sd	a5,8(sp)

    assert(buddy_nr_free_pages() == before);
ffffffffc0200fd0:	3b379b63          	bne	a5,s3,ffffffffc0201386 <buddy_check+0x62e>

    // extra: isolated mini arena tests
    size_t g_before = buddy_nr_free_pages();
    struct Page *arena = alloc_pages(32);
ffffffffc0200fd4:	02000513          	li	a0,32
ffffffffc0200fd8:	df8ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200fdc:	89aa                	mv	s3,a0
    assert(arena != NULL);
ffffffffc0200fde:	38050463          	beqz	a0,ffffffffc0201366 <buddy_check+0x60e>
ffffffffc0200fe2:	02810d93          	addi	s11,sp,40
ffffffffc0200fe6:	876e                	mv	a4,s11
ffffffffc0200fe8:	00007797          	auipc	a5,0x7
ffffffffc0200fec:	0f878793          	addi	a5,a5,248 # ffffffffc02080e0 <buddy_area>
    buddy_area_t saved2[BUDDY_MAX_ORDER + 1];
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        saved2[i] = buddy_area[i];
ffffffffc0200ff0:	638c                	ld	a1,0(a5)
ffffffffc0200ff2:	6790                	ld	a2,8(a5)
ffffffffc0200ff4:	6b94                	ld	a3,16(a5)
ffffffffc0200ff6:	e30c                	sd	a1,0(a4)
ffffffffc0200ff8:	e710                	sd	a2,8(a4)
ffffffffc0200ffa:	eb14                	sd	a3,16(a4)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0200ffc:	07e1                	addi	a5,a5,24
ffffffffc0200ffe:	0761                	addi	a4,a4,24
ffffffffc0201000:	ff4798e3          	bne	a5,s4,ffffffffc0200ff0 <buddy_check+0x298>
    }
    size_t saved_total2 = buddy_total_free;
ffffffffc0201004:	609c                	ld	a5,0(s1)
ffffffffc0201006:	e83e                	sd	a5,16(sp)
ffffffffc0201008:	00007797          	auipc	a5,0x7
ffffffffc020100c:	0d878793          	addi	a5,a5,216 # ffffffffc02080e0 <buddy_area>
ffffffffc0201010:	e79c                	sd	a5,8(a5)
ffffffffc0201012:	e39c                	sd	a5,0(a5)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        list_init(&order_free_list(i));
        order_nr_free(i) = 0;
ffffffffc0201014:	0007a823          	sw	zero,16(a5)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0201018:	07e1                	addi	a5,a5,24
ffffffffc020101a:	ff479be3          	bne	a5,s4,ffffffffc0201010 <buddy_check+0x2b8>
    }
    buddy_total_free = 0;
    insert_region(arena, 32);
ffffffffc020101e:	02000593          	li	a1,32
ffffffffc0201022:	854e                	mv	a0,s3
ffffffffc0201024:	ba9ff0ef          	jal	ra,ffffffffc0200bcc <insert_region>
    buddy_total_free = 32;
ffffffffc0201028:	02000793          	li	a5,32

    struct Page *b0 = alloc_pages(4);
ffffffffc020102c:	4511                	li	a0,4
    buddy_total_free = 32;
ffffffffc020102e:	e09c                	sd	a5,0(s1)
    struct Page *b0 = alloc_pages(4);
ffffffffc0201030:	da0ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201034:	892a                	mv	s2,a0
    struct Page *b1 = alloc_pages(4);
ffffffffc0201036:	4511                	li	a0,4
ffffffffc0201038:	d98ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc020103c:	8d2a                	mv	s10,a0
    struct Page *b2 = alloc_pages(4);
ffffffffc020103e:	4511                	li	a0,4
ffffffffc0201040:	d90ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201044:	87aa                	mv	a5,a0
    struct Page *b3 = alloc_pages(4);
ffffffffc0201046:	4511                	li	a0,4
    struct Page *b2 = alloc_pages(4);
ffffffffc0201048:	8a3e                	mv	s4,a5
ffffffffc020104a:	ec3e                	sd	a5,24(sp)
    struct Page *b3 = alloc_pages(4);
ffffffffc020104c:	d84ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201050:	8c2a                	mv	s8,a0
    assert(b0 && b1 && b2 && b3);
ffffffffc0201052:	2e090a63          	beqz	s2,ffffffffc0201346 <buddy_check+0x5ee>
ffffffffc0201056:	2e0d0863          	beqz	s10,ffffffffc0201346 <buddy_check+0x5ee>
ffffffffc020105a:	2e0a0663          	beqz	s4,ffffffffc0201346 <buddy_check+0x5ee>
ffffffffc020105e:	2e050463          	beqz	a0,ffffffffc0201346 <buddy_check+0x5ee>
    struct Page *d0 = alloc_pages(4);
ffffffffc0201062:	4511                	li	a0,4
ffffffffc0201064:	d6cff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201068:	8baa                	mv	s7,a0
    struct Page *d1 = alloc_pages(4);
ffffffffc020106a:	4511                	li	a0,4
ffffffffc020106c:	d64ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201070:	8b2a                	mv	s6,a0
    struct Page *d2 = alloc_pages(4);
ffffffffc0201072:	4511                	li	a0,4
ffffffffc0201074:	d5cff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201078:	8aaa                	mv	s5,a0
    struct Page *d3 = alloc_pages(4);
ffffffffc020107a:	4511                	li	a0,4
ffffffffc020107c:	d54ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201080:	8a2a                	mv	s4,a0
    assert(d0 && d1 && d2 && d3);
ffffffffc0201082:	2a0b8263          	beqz	s7,ffffffffc0201326 <buddy_check+0x5ce>
ffffffffc0201086:	2a0b0063          	beqz	s6,ffffffffc0201326 <buddy_check+0x5ce>
ffffffffc020108a:	280a8e63          	beqz	s5,ffffffffc0201326 <buddy_check+0x5ce>
ffffffffc020108e:	28050c63          	beqz	a0,ffffffffc0201326 <buddy_check+0x5ce>
    free_pages(b0 + 1, 2);
ffffffffc0201092:	02890513          	addi	a0,s2,40
ffffffffc0201096:	4589                	li	a1,2
ffffffffc0201098:	d44ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(alloc_pages(3) == NULL);
ffffffffc020109c:	450d                	li	a0,3
ffffffffc020109e:	d32ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc02010a2:	26051263          	bnez	a0,ffffffffc0201306 <buddy_check+0x5ae>
    struct Page *t = alloc_pages(3);
ffffffffc02010a6:	450d                	li	a0,3
ffffffffc02010a8:	d28ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
    assert(t == NULL);
ffffffffc02010ac:	22051d63          	bnez	a0,ffffffffc02012e6 <buddy_check+0x58e>
    free_page(b0);
ffffffffc02010b0:	4585                	li	a1,1
ffffffffc02010b2:	854a                	mv	a0,s2
ffffffffc02010b4:	d28ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(b0 + 3);
ffffffffc02010b8:	07890513          	addi	a0,s2,120
ffffffffc02010bc:	4585                	li	a1,1
ffffffffc02010be:	d1eff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    struct Page *p4 = alloc_pages(4);
ffffffffc02010c2:	4511                	li	a0,4
ffffffffc02010c4:	d0cff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
    assert(p4 == b0);
ffffffffc02010c8:	1ea91f63          	bne	s2,a0,ffffffffc02012c6 <buddy_check+0x56e>
    free_pages(p4, 4);
ffffffffc02010cc:	4591                	li	a1,4
ffffffffc02010ce:	d0eff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(b1, 4);
ffffffffc02010d2:	4591                	li	a1,4
ffffffffc02010d4:	856a                	mv	a0,s10
ffffffffc02010d6:	d06ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(b2, 4);
ffffffffc02010da:	6562                	ld	a0,24(sp)
ffffffffc02010dc:	4591                	li	a1,4
ffffffffc02010de:	cfeff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(b3, 4);
ffffffffc02010e2:	4591                	li	a1,4
ffffffffc02010e4:	8562                	mv	a0,s8
ffffffffc02010e6:	cf6ff0ef          	jal	ra,ffffffffc02005dc <free_pages>

    free_pages(d0, 4);
ffffffffc02010ea:	4591                	li	a1,4
ffffffffc02010ec:	855e                	mv	a0,s7
ffffffffc02010ee:	ceeff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(d1, 4);
ffffffffc02010f2:	4591                	li	a1,4
ffffffffc02010f4:	855a                	mv	a0,s6
ffffffffc02010f6:	ce6ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(d2, 4);
ffffffffc02010fa:	4591                	li	a1,4
ffffffffc02010fc:	8556                	mv	a0,s5
ffffffffc02010fe:	cdeff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(d3, 4);
ffffffffc0201102:	4591                	li	a1,4
ffffffffc0201104:	8552                	mv	a0,s4
ffffffffc0201106:	cd6ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    struct Page *c0 = alloc_pages(8);
ffffffffc020110a:	4521                	li	a0,8
ffffffffc020110c:	cc4ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0201110:	892a                	mv	s2,a0
    assert(c0 != NULL);
ffffffffc0201112:	50050a63          	beqz	a0,ffffffffc0201626 <buddy_check+0x8ce>
    free_pages(c0, 4);
ffffffffc0201116:	4591                	li	a1,4
ffffffffc0201118:	cc4ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(c0 + 4, 4);
ffffffffc020111c:	0a090513          	addi	a0,s2,160
ffffffffc0201120:	4591                	li	a1,4
ffffffffc0201122:	cbaff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    struct Page *c = alloc_pages(8);
ffffffffc0201126:	4521                	li	a0,8
ffffffffc0201128:	ca8ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
    assert(c == c0);
ffffffffc020112c:	14a91d63          	bne	s2,a0,ffffffffc0201286 <buddy_check+0x52e>
    free_pages(c, 8);
ffffffffc0201130:	45a1                	li	a1,8
ffffffffc0201132:	caaff0ef          	jal	ra,ffffffffc02005dc <free_pages>
static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc0201136:	00007797          	auipc	a5,0x7
ffffffffc020113a:	19278793          	addi	a5,a5,402 # ffffffffc02082c8 <pages>
ffffffffc020113e:	638c                	ld	a1,0(a5)
ffffffffc0201140:	00007617          	auipc	a2,0x7
ffffffffc0201144:	fa060613          	addi	a2,a2,-96 # ffffffffc02080e0 <buddy_area>

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc0201148:	4e81                	li	t4,0
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc020114a:	4f85                	li	t6,1
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc020114c:	4f4d                	li	t5,19
    return listelm->next;
ffffffffc020114e:	00863e03          	ld	t3,8(a2)
        list_entry_t *le = &order_free_list(i);
        for (list_entry_t *a = list_next(le); a != le; a = list_next(a)) {
ffffffffc0201152:	05c60763          	beq	a2,t3,ffffffffc02011a0 <buddy_check+0x448>
            struct Page *pa = le2page(a, page_link);
            size_t idxa = page_index(pa);
            size_t bs = order_block_pages(i);
            size_t bidx = idxa ^ bs;
            for (list_entry_t *b = list_next(le); b != le; b = list_next(b)) {
                struct Page *pb = le2page(b, page_link);
ffffffffc0201156:	fe8e0313          	addi	t1,t3,-24
static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc020115a:	40b30333          	sub	t1,t1,a1
ffffffffc020115e:	40335313          	srai	t1,t1,0x3
ffffffffc0201162:	03930333          	mul	t1,t1,s9
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0201166:	01df92b3          	sll	t0,t6,t4
static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc020116a:	8572                	mv	a0,t3
            struct Page *pa = le2page(a, page_link);
ffffffffc020116c:	fe850693          	addi	a3,a0,-24
static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc0201170:	8e8d                	sub	a3,a3,a1
ffffffffc0201172:	868d                	srai	a3,a3,0x3
ffffffffc0201174:	039686b3          	mul	a3,a3,s9
            size_t bidx = idxa ^ bs;
ffffffffc0201178:	0056c6b3          	xor	a3,a3,t0
                size_t idxb = page_index(pb);
                assert(!(idxb == bidx));
ffffffffc020117c:	0a668563          	beq	a3,t1,ffffffffc0201226 <buddy_check+0x4ce>
ffffffffc0201180:	8772                	mv	a4,t3
ffffffffc0201182:	a809                	j	ffffffffc0201194 <buddy_check+0x43c>
                struct Page *pb = le2page(b, page_link);
ffffffffc0201184:	fe870793          	addi	a5,a4,-24
static inline size_t page_index(struct Page *p) { return (size_t)(p - pages); }
ffffffffc0201188:	8f8d                	sub	a5,a5,a1
ffffffffc020118a:	878d                	srai	a5,a5,0x3
ffffffffc020118c:	039787b3          	mul	a5,a5,s9
                assert(!(idxb == bidx));
ffffffffc0201190:	08f68b63          	beq	a3,a5,ffffffffc0201226 <buddy_check+0x4ce>
ffffffffc0201194:	6718                	ld	a4,8(a4)
            for (list_entry_t *b = list_next(le); b != le; b = list_next(b)) {
ffffffffc0201196:	fec717e3          	bne	a4,a2,ffffffffc0201184 <buddy_check+0x42c>
ffffffffc020119a:	6508                	ld	a0,8(a0)
        for (list_entry_t *a = list_next(le); a != le; a = list_next(a)) {
ffffffffc020119c:	fcc518e3          	bne	a0,a2,ffffffffc020116c <buddy_check+0x414>
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc02011a0:	2e85                	addiw	t4,t4,1
ffffffffc02011a2:	0661                	addi	a2,a2,24
ffffffffc02011a4:	fbee95e3          	bne	t4,t5,ffffffffc020114e <buddy_check+0x3f6>
ffffffffc02011a8:	04100913          	li	s2,65
ffffffffc02011ac:	a021                	j	ffffffffc02011b4 <buddy_check+0x45c>
    }

    struct Page *drain[64];
    size_t dn = 0;
    struct Page *u;
    while ((u = alloc_pages(1)) != NULL && dn < 64) {
ffffffffc02011ae:	197d                	addi	s2,s2,-1
ffffffffc02011b0:	00090663          	beqz	s2,ffffffffc02011bc <buddy_check+0x464>
ffffffffc02011b4:	4505                	li	a0,1
ffffffffc02011b6:	c1aff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc02011ba:	f975                	bnez	a0,ffffffffc02011ae <buddy_check+0x456>
ffffffffc02011bc:	1b9c                	addi	a5,sp,496
        drain[dn++] = u;
    }

    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
        order_free_list(i) = saved2[i].free_list;
ffffffffc02011be:	000db603          	ld	a2,0(s11)
ffffffffc02011c2:	008db683          	ld	a3,8(s11)
        order_nr_free(i) = saved2[i].nr_free;
ffffffffc02011c6:	010da703          	lw	a4,16(s11)
        order_free_list(i) = saved2[i].free_list;
ffffffffc02011ca:	e010                	sd	a2,0(s0)
ffffffffc02011cc:	e414                	sd	a3,8(s0)
        order_nr_free(i) = saved2[i].nr_free;
ffffffffc02011ce:	c818                	sw	a4,16(s0)
    for (unsigned int i = 0; i <= BUDDY_MAX_ORDER; i++) {
ffffffffc02011d0:	0de1                	addi	s11,s11,24
ffffffffc02011d2:	0461                	addi	s0,s0,24
ffffffffc02011d4:	ffb795e3          	bne	a5,s11,ffffffffc02011be <buddy_check+0x466>
    }
    buddy_total_free = saved_total2;
ffffffffc02011d8:	67c2                	ld	a5,16(sp)

    free_pages(arena, 32);
ffffffffc02011da:	02000593          	li	a1,32
ffffffffc02011de:	854e                	mv	a0,s3
    buddy_total_free = saved_total2;
ffffffffc02011e0:	e09c                	sd	a5,0(s1)
    free_pages(arena, 32);
ffffffffc02011e2:	bfaff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(buddy_nr_free_pages() == g_before);
ffffffffc02011e6:	609c                	ld	a5,0(s1)
ffffffffc02011e8:	6722                	ld	a4,8(sp)
ffffffffc02011ea:	48f71e63          	bne	a4,a5,ffffffffc0201686 <buddy_check+0x92e>
}
ffffffffc02011ee:	25813083          	ld	ra,600(sp)
ffffffffc02011f2:	25013403          	ld	s0,592(sp)
ffffffffc02011f6:	24813483          	ld	s1,584(sp)
ffffffffc02011fa:	24013903          	ld	s2,576(sp)
ffffffffc02011fe:	23813983          	ld	s3,568(sp)
ffffffffc0201202:	23013a03          	ld	s4,560(sp)
ffffffffc0201206:	22813a83          	ld	s5,552(sp)
ffffffffc020120a:	22013b03          	ld	s6,544(sp)
ffffffffc020120e:	21813b83          	ld	s7,536(sp)
ffffffffc0201212:	21013c03          	ld	s8,528(sp)
ffffffffc0201216:	20813c83          	ld	s9,520(sp)
ffffffffc020121a:	20013d03          	ld	s10,512(sp)
ffffffffc020121e:	7dfe                	ld	s11,504(sp)
ffffffffc0201220:	26010113          	addi	sp,sp,608
ffffffffc0201224:	8082                	ret
                assert(!(idxb == bidx));
ffffffffc0201226:	00001697          	auipc	a3,0x1
ffffffffc020122a:	28a68693          	addi	a3,a3,650 # ffffffffc02024b0 <class_sizes+0x340>
ffffffffc020122e:	00001617          	auipc	a2,0x1
ffffffffc0201232:	f1a60613          	addi	a2,a2,-230 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201236:	15c00593          	li	a1,348
ffffffffc020123a:	00001517          	auipc	a0,0x1
ffffffffc020123e:	f8650513          	addi	a0,a0,-122 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201242:	f81fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(p->property == i);
ffffffffc0201246:	00001697          	auipc	a3,0x1
ffffffffc020124a:	f9268693          	addi	a3,a3,-110 # ffffffffc02021d8 <class_sizes+0x68>
ffffffffc020124e:	00001617          	auipc	a2,0x1
ffffffffc0201252:	efa60613          	addi	a2,a2,-262 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201256:	10700593          	li	a1,263
ffffffffc020125a:	00001517          	auipc	a0,0x1
ffffffffc020125e:	f6650513          	addi	a0,a0,-154 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201262:	f61fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
            assert(PageProperty(p));
ffffffffc0201266:	00001697          	auipc	a3,0x1
ffffffffc020126a:	f4a68693          	addi	a3,a3,-182 # ffffffffc02021b0 <class_sizes+0x40>
ffffffffc020126e:	00001617          	auipc	a2,0x1
ffffffffc0201272:	eda60613          	addi	a2,a2,-294 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201276:	10600593          	li	a1,262
ffffffffc020127a:	00001517          	auipc	a0,0x1
ffffffffc020127e:	f4650513          	addi	a0,a0,-186 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201282:	f41fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(c == c0);
ffffffffc0201286:	00001697          	auipc	a3,0x1
ffffffffc020128a:	22268693          	addi	a3,a3,546 # ffffffffc02024a8 <class_sizes+0x338>
ffffffffc020128e:	00001617          	auipc	a2,0x1
ffffffffc0201292:	eba60613          	addi	a2,a2,-326 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201296:	14f00593          	li	a1,335
ffffffffc020129a:	00001517          	auipc	a0,0x1
ffffffffc020129e:	f2650513          	addi	a0,a0,-218 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02012a2:	f21fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02012a6:	00001697          	auipc	a3,0x1
ffffffffc02012aa:	03268693          	addi	a3,a3,50 # ffffffffc02022d8 <class_sizes+0x168>
ffffffffc02012ae:	00001617          	auipc	a2,0x1
ffffffffc02012b2:	e9a60613          	addi	a2,a2,-358 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02012b6:	0cd00593          	li	a1,205
ffffffffc02012ba:	00001517          	auipc	a0,0x1
ffffffffc02012be:	f0650513          	addi	a0,a0,-250 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02012c2:	f01fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p4 == b0);
ffffffffc02012c6:	00001697          	auipc	a3,0x1
ffffffffc02012ca:	1c268693          	addi	a3,a3,450 # ffffffffc0202488 <class_sizes+0x318>
ffffffffc02012ce:	00001617          	auipc	a2,0x1
ffffffffc02012d2:	e7a60613          	addi	a2,a2,-390 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02012d6:	14000593          	li	a1,320
ffffffffc02012da:	00001517          	auipc	a0,0x1
ffffffffc02012de:	ee650513          	addi	a0,a0,-282 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02012e2:	ee1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(t == NULL);
ffffffffc02012e6:	00001697          	auipc	a3,0x1
ffffffffc02012ea:	19268693          	addi	a3,a3,402 # ffffffffc0202478 <class_sizes+0x308>
ffffffffc02012ee:	00001617          	auipc	a2,0x1
ffffffffc02012f2:	e5a60613          	addi	a2,a2,-422 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02012f6:	13c00593          	li	a1,316
ffffffffc02012fa:	00001517          	auipc	a0,0x1
ffffffffc02012fe:	ec650513          	addi	a0,a0,-314 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201302:	ec1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_pages(3) == NULL);
ffffffffc0201306:	00001697          	auipc	a3,0x1
ffffffffc020130a:	15a68693          	addi	a3,a3,346 # ffffffffc0202460 <class_sizes+0x2f0>
ffffffffc020130e:	00001617          	auipc	a2,0x1
ffffffffc0201312:	e3a60613          	addi	a2,a2,-454 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201316:	13a00593          	li	a1,314
ffffffffc020131a:	00001517          	auipc	a0,0x1
ffffffffc020131e:	ea650513          	addi	a0,a0,-346 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201322:	ea1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(d0 && d1 && d2 && d3);
ffffffffc0201326:	00001697          	auipc	a3,0x1
ffffffffc020132a:	12268693          	addi	a3,a3,290 # ffffffffc0202448 <class_sizes+0x2d8>
ffffffffc020132e:	00001617          	auipc	a2,0x1
ffffffffc0201332:	e1a60613          	addi	a2,a2,-486 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201336:	13800593          	li	a1,312
ffffffffc020133a:	00001517          	auipc	a0,0x1
ffffffffc020133e:	e8650513          	addi	a0,a0,-378 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201342:	e81fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(b0 && b1 && b2 && b3);
ffffffffc0201346:	00001697          	auipc	a3,0x1
ffffffffc020134a:	0ea68693          	addi	a3,a3,234 # ffffffffc0202430 <class_sizes+0x2c0>
ffffffffc020134e:	00001617          	auipc	a2,0x1
ffffffffc0201352:	dfa60613          	addi	a2,a2,-518 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201356:	13300593          	li	a1,307
ffffffffc020135a:	00001517          	auipc	a0,0x1
ffffffffc020135e:	e6650513          	addi	a0,a0,-410 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201362:	e61fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(arena != NULL);
ffffffffc0201366:	00001697          	auipc	a3,0x1
ffffffffc020136a:	0ba68693          	addi	a3,a3,186 # ffffffffc0202420 <class_sizes+0x2b0>
ffffffffc020136e:	00001617          	auipc	a2,0x1
ffffffffc0201372:	dda60613          	addi	a2,a2,-550 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201376:	12100593          	li	a1,289
ffffffffc020137a:	00001517          	auipc	a0,0x1
ffffffffc020137e:	e4650513          	addi	a0,a0,-442 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201382:	e41fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == before);
ffffffffc0201386:	00001697          	auipc	a3,0x1
ffffffffc020138a:	06a68693          	addi	a3,a3,106 # ffffffffc02023f0 <class_sizes+0x280>
ffffffffc020138e:	00001617          	auipc	a2,0x1
ffffffffc0201392:	dba60613          	addi	a2,a2,-582 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201396:	11c00593          	li	a1,284
ffffffffc020139a:	00001517          	auipc	a0,0x1
ffffffffc020139e:	e2650513          	addi	a0,a0,-474 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02013a2:	e21fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(r != NULL);
ffffffffc02013a6:	00001697          	auipc	a3,0x1
ffffffffc02013aa:	06a68693          	addi	a3,a3,106 # ffffffffc0202410 <class_sizes+0x2a0>
ffffffffc02013ae:	00001617          	auipc	a2,0x1
ffffffffc02013b2:	d9a60613          	addi	a2,a2,-614 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02013b6:	11700593          	li	a1,279
ffffffffc02013ba:	00001517          	auipc	a0,0x1
ffffffffc02013be:	e0650513          	addi	a0,a0,-506 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02013c2:	e01fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == before);
ffffffffc02013c6:	00001697          	auipc	a3,0x1
ffffffffc02013ca:	02a68693          	addi	a3,a3,42 # ffffffffc02023f0 <class_sizes+0x280>
ffffffffc02013ce:	00001617          	auipc	a2,0x1
ffffffffc02013d2:	d7a60613          	addi	a2,a2,-646 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02013d6:	11400593          	li	a1,276
ffffffffc02013da:	00001517          	auipc	a0,0x1
ffffffffc02013de:	de650513          	addi	a0,a0,-538 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02013e2:	de1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() + 3 == before);
ffffffffc02013e6:	00001697          	auipc	a3,0x1
ffffffffc02013ea:	fe268693          	addi	a3,a3,-30 # ffffffffc02023c8 <class_sizes+0x258>
ffffffffc02013ee:	00001617          	auipc	a2,0x1
ffffffffc02013f2:	d5a60613          	addi	a2,a2,-678 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02013f6:	11200593          	li	a1,274
ffffffffc02013fa:	00001517          	auipc	a0,0x1
ffffffffc02013fe:	dc650513          	addi	a0,a0,-570 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201402:	dc1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(q != NULL);
ffffffffc0201406:	00001697          	auipc	a3,0x1
ffffffffc020140a:	fb268693          	addi	a3,a3,-78 # ffffffffc02023b8 <class_sizes+0x248>
ffffffffc020140e:	00001617          	auipc	a2,0x1
ffffffffc0201412:	d3a60613          	addi	a2,a2,-710 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201416:	11100593          	li	a1,273
ffffffffc020141a:	00001517          	auipc	a0,0x1
ffffffffc020141e:	da650513          	addi	a0,a0,-602 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201422:	da1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_total_free == 0);
ffffffffc0201426:	00001697          	auipc	a3,0x1
ffffffffc020142a:	f7a68693          	addi	a3,a3,-134 # ffffffffc02023a0 <class_sizes+0x230>
ffffffffc020142e:	00001617          	auipc	a2,0x1
ffffffffc0201432:	d1a60613          	addi	a2,a2,-742 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201436:	0f200593          	li	a1,242
ffffffffc020143a:	00001517          	auipc	a0,0x1
ffffffffc020143e:	d8650513          	addi	a0,a0,-634 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201442:	d81fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201446:	00001697          	auipc	a3,0x1
ffffffffc020144a:	ef268693          	addi	a3,a3,-270 # ffffffffc0202338 <class_sizes+0x1c8>
ffffffffc020144e:	00001617          	auipc	a2,0x1
ffffffffc0201452:	cfa60613          	addi	a2,a2,-774 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201456:	0f000593          	li	a1,240
ffffffffc020145a:	00001517          	auipc	a0,0x1
ffffffffc020145e:	d6650513          	addi	a0,a0,-666 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201462:	d61fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201466:	00001697          	auipc	a3,0x1
ffffffffc020146a:	f1a68693          	addi	a3,a3,-230 # ffffffffc0202380 <class_sizes+0x210>
ffffffffc020146e:	00001617          	auipc	a2,0x1
ffffffffc0201472:	cda60613          	addi	a2,a2,-806 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201476:	0ef00593          	li	a1,239
ffffffffc020147a:	00001517          	auipc	a0,0x1
ffffffffc020147e:	d4650513          	addi	a0,a0,-698 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201482:	d41fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_total_free >= 1);
ffffffffc0201486:	00001697          	auipc	a3,0x1
ffffffffc020148a:	ee268693          	addi	a3,a3,-286 # ffffffffc0202368 <class_sizes+0x1f8>
ffffffffc020148e:	00001617          	auipc	a2,0x1
ffffffffc0201492:	cba60613          	addi	a2,a2,-838 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201496:	0ec00593          	li	a1,236
ffffffffc020149a:	00001517          	auipc	a0,0x1
ffffffffc020149e:	d2650513          	addi	a0,a0,-730 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02014a2:	d21fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014a6:	00001697          	auipc	a3,0x1
ffffffffc02014aa:	d8a68693          	addi	a3,a3,-630 # ffffffffc0202230 <class_sizes+0xc0>
ffffffffc02014ae:	00001617          	auipc	a2,0x1
ffffffffc02014b2:	c9a60613          	addi	a2,a2,-870 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02014b6:	0c700593          	li	a1,199
ffffffffc02014ba:	00001517          	auipc	a0,0x1
ffffffffc02014be:	d0650513          	addi	a0,a0,-762 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02014c2:	d01fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014c6:	00001697          	auipc	a3,0x1
ffffffffc02014ca:	d8a68693          	addi	a3,a3,-630 # ffffffffc0202250 <class_sizes+0xe0>
ffffffffc02014ce:	00001617          	auipc	a2,0x1
ffffffffc02014d2:	c7a60613          	addi	a2,a2,-902 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02014d6:	0e700593          	li	a1,231
ffffffffc02014da:	00001517          	auipc	a0,0x1
ffffffffc02014de:	ce650513          	addi	a0,a0,-794 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02014e2:	ce1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014e6:	00001697          	auipc	a3,0x1
ffffffffc02014ea:	d4a68693          	addi	a3,a3,-694 # ffffffffc0202230 <class_sizes+0xc0>
ffffffffc02014ee:	00001617          	auipc	a2,0x1
ffffffffc02014f2:	c5a60613          	addi	a2,a2,-934 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02014f6:	0e600593          	li	a1,230
ffffffffc02014fa:	00001517          	auipc	a0,0x1
ffffffffc02014fe:	cc650513          	addi	a0,a0,-826 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201502:	cc1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201506:	00001697          	auipc	a3,0x1
ffffffffc020150a:	d0a68693          	addi	a3,a3,-758 # ffffffffc0202210 <class_sizes+0xa0>
ffffffffc020150e:	00001617          	auipc	a2,0x1
ffffffffc0201512:	c3a60613          	addi	a2,a2,-966 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201516:	0e500593          	li	a1,229
ffffffffc020151a:	00001517          	auipc	a0,0x1
ffffffffc020151e:	ca650513          	addi	a0,a0,-858 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201522:	ca1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_total_free == 3);
ffffffffc0201526:	00001697          	auipc	a3,0x1
ffffffffc020152a:	e2a68693          	addi	a3,a3,-470 # ffffffffc0202350 <class_sizes+0x1e0>
ffffffffc020152e:	00001617          	auipc	a2,0x1
ffffffffc0201532:	c1a60613          	addi	a2,a2,-998 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201536:	0e300593          	li	a1,227
ffffffffc020153a:	00001517          	auipc	a0,0x1
ffffffffc020153e:	c8650513          	addi	a0,a0,-890 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201542:	c81fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201546:	00001697          	auipc	a3,0x1
ffffffffc020154a:	df268693          	addi	a3,a3,-526 # ffffffffc0202338 <class_sizes+0x1c8>
ffffffffc020154e:	00001617          	auipc	a2,0x1
ffffffffc0201552:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201556:	0de00593          	li	a1,222
ffffffffc020155a:	00001517          	auipc	a0,0x1
ffffffffc020155e:	c6650513          	addi	a0,a0,-922 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201562:	c61fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201566:	00001697          	auipc	a3,0x1
ffffffffc020156a:	db268693          	addi	a3,a3,-590 # ffffffffc0202318 <class_sizes+0x1a8>
ffffffffc020156e:	00001617          	auipc	a2,0x1
ffffffffc0201572:	bda60613          	addi	a2,a2,-1062 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201576:	0cf00593          	li	a1,207
ffffffffc020157a:	00001517          	auipc	a0,0x1
ffffffffc020157e:	c4650513          	addi	a0,a0,-954 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201582:	c41fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201586:	00001697          	auipc	a3,0x1
ffffffffc020158a:	d7268693          	addi	a3,a3,-654 # ffffffffc02022f8 <class_sizes+0x188>
ffffffffc020158e:	00001617          	auipc	a2,0x1
ffffffffc0201592:	bba60613          	addi	a2,a2,-1094 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201596:	0ce00593          	li	a1,206
ffffffffc020159a:	00001517          	auipc	a0,0x1
ffffffffc020159e:	c2650513          	addi	a0,a0,-986 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02015a2:	c21fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total == buddy_nr_free_pages());
ffffffffc02015a6:	00001697          	auipc	a3,0x1
ffffffffc02015aa:	c4a68693          	addi	a3,a3,-950 # ffffffffc02021f0 <class_sizes+0x80>
ffffffffc02015ae:	00001617          	auipc	a2,0x1
ffffffffc02015b2:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02015b6:	10b00593          	li	a1,267
ffffffffc02015ba:	00001517          	auipc	a0,0x1
ffffffffc02015be:	c0650513          	addi	a0,a0,-1018 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02015c2:	c01fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02015c6:	00001697          	auipc	a3,0x1
ffffffffc02015ca:	cd268693          	addi	a3,a3,-814 # ffffffffc0202298 <class_sizes+0x128>
ffffffffc02015ce:	00001617          	auipc	a2,0x1
ffffffffc02015d2:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02015d6:	0cb00593          	li	a1,203
ffffffffc02015da:	00001517          	auipc	a0,0x1
ffffffffc02015de:	be650513          	addi	a0,a0,-1050 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02015e2:	be1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02015e6:	00001697          	auipc	a3,0x1
ffffffffc02015ea:	c8a68693          	addi	a3,a3,-886 # ffffffffc0202270 <class_sizes+0x100>
ffffffffc02015ee:	00001617          	auipc	a2,0x1
ffffffffc02015f2:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02015f6:	0ca00593          	li	a1,202
ffffffffc02015fa:	00001517          	auipc	a0,0x1
ffffffffc02015fe:	bc650513          	addi	a0,a0,-1082 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201602:	bc1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201606:	00001697          	auipc	a3,0x1
ffffffffc020160a:	c4a68693          	addi	a3,a3,-950 # ffffffffc0202250 <class_sizes+0xe0>
ffffffffc020160e:	00001617          	auipc	a2,0x1
ffffffffc0201612:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201616:	0c800593          	li	a1,200
ffffffffc020161a:	00001517          	auipc	a0,0x1
ffffffffc020161e:	ba650513          	addi	a0,a0,-1114 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201622:	ba1fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(c0 != NULL);
ffffffffc0201626:	00001697          	auipc	a3,0x1
ffffffffc020162a:	e7268693          	addi	a3,a3,-398 # ffffffffc0202498 <class_sizes+0x328>
ffffffffc020162e:	00001617          	auipc	a2,0x1
ffffffffc0201632:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201636:	14b00593          	li	a1,331
ffffffffc020163a:	00001517          	auipc	a0,0x1
ffffffffc020163e:	b8650513          	addi	a0,a0,-1146 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201642:	b81fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201646:	00001697          	auipc	a3,0x1
ffffffffc020164a:	bca68693          	addi	a3,a3,-1078 # ffffffffc0202210 <class_sizes+0xa0>
ffffffffc020164e:	00001617          	auipc	a2,0x1
ffffffffc0201652:	afa60613          	addi	a2,a2,-1286 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201656:	0c600593          	li	a1,198
ffffffffc020165a:	00001517          	auipc	a0,0x1
ffffffffc020165e:	b6650513          	addi	a0,a0,-1178 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201662:	b61fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201666:	00001697          	auipc	a3,0x1
ffffffffc020166a:	cd268693          	addi	a3,a3,-814 # ffffffffc0202338 <class_sizes+0x1c8>
ffffffffc020166e:	00001617          	auipc	a2,0x1
ffffffffc0201672:	ada60613          	addi	a2,a2,-1318 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201676:	0e900593          	li	a1,233
ffffffffc020167a:	00001517          	auipc	a0,0x1
ffffffffc020167e:	b4650513          	addi	a0,a0,-1210 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc0201682:	b41fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(buddy_nr_free_pages() == g_before);
ffffffffc0201686:	00001697          	auipc	a3,0x1
ffffffffc020168a:	e3a68693          	addi	a3,a3,-454 # ffffffffc02024c0 <class_sizes+0x350>
ffffffffc020168e:	00001617          	auipc	a2,0x1
ffffffffc0201692:	aba60613          	addi	a2,a2,-1350 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201696:	16f00593          	li	a1,367
ffffffffc020169a:	00001517          	auipc	a0,0x1
ffffffffc020169e:	b2650513          	addi	a0,a0,-1242 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02016a2:	b21fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02016a6 <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc02016a6:	1141                	addi	sp,sp,-16
ffffffffc02016a8:	e406                	sd	ra,8(sp)
ffffffffc02016aa:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc02016ac:	c1bd                	beqz	a1,ffffffffc0201712 <buddy_free_pages+0x6c>
    for (; p != base + n; p++) {
ffffffffc02016ae:	00259693          	slli	a3,a1,0x2
ffffffffc02016b2:	96ae                	add	a3,a3,a1
ffffffffc02016b4:	068e                	slli	a3,a3,0x3
ffffffffc02016b6:	96aa                	add	a3,a3,a0
ffffffffc02016b8:	842e                	mv	s0,a1
ffffffffc02016ba:	87aa                	mv	a5,a0
ffffffffc02016bc:	00d50d63          	beq	a0,a3,ffffffffc02016d6 <buddy_free_pages+0x30>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016c0:	6798                	ld	a4,8(a5)
ffffffffc02016c2:	8b0d                	andi	a4,a4,3
ffffffffc02016c4:	e71d                	bnez	a4,ffffffffc02016f2 <buddy_free_pages+0x4c>
        p->flags = 0;
ffffffffc02016c6:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02016ca:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc02016ce:	02878793          	addi	a5,a5,40
ffffffffc02016d2:	fed797e3          	bne	a5,a3,ffffffffc02016c0 <buddy_free_pages+0x1a>
    insert_region(base, n);
ffffffffc02016d6:	85a2                	mv	a1,s0
ffffffffc02016d8:	cf4ff0ef          	jal	ra,ffffffffc0200bcc <insert_region>
    buddy_total_free += n;
ffffffffc02016dc:	00007717          	auipc	a4,0x7
ffffffffc02016e0:	c1470713          	addi	a4,a4,-1004 # ffffffffc02082f0 <buddy_total_free>
ffffffffc02016e4:	631c                	ld	a5,0(a4)
}
ffffffffc02016e6:	60a2                	ld	ra,8(sp)
    buddy_total_free += n;
ffffffffc02016e8:	97a2                	add	a5,a5,s0
}
ffffffffc02016ea:	6402                	ld	s0,0(sp)
    buddy_total_free += n;
ffffffffc02016ec:	e31c                	sd	a5,0(a4)
}
ffffffffc02016ee:	0141                	addi	sp,sp,16
ffffffffc02016f0:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016f2:	00001697          	auipc	a3,0x1
ffffffffc02016f6:	dfe68693          	addi	a3,a3,-514 # ffffffffc02024f0 <class_sizes+0x380>
ffffffffc02016fa:	00001617          	auipc	a2,0x1
ffffffffc02016fe:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201702:	0b900593          	li	a1,185
ffffffffc0201706:	00001517          	auipc	a0,0x1
ffffffffc020170a:	aba50513          	addi	a0,a0,-1350 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc020170e:	ab5fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc0201712:	00001697          	auipc	a3,0x1
ffffffffc0201716:	dd668693          	addi	a3,a3,-554 # ffffffffc02024e8 <class_sizes+0x378>
ffffffffc020171a:	00001617          	auipc	a2,0x1
ffffffffc020171e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201722:	0b600593          	li	a1,182
ffffffffc0201726:	00001517          	auipc	a0,0x1
ffffffffc020172a:	a9a50513          	addi	a0,a0,-1382 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc020172e:	a95fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201732 <buddy_alloc_pages>:
static struct Page *buddy_alloc_pages(size_t n) {
ffffffffc0201732:	7179                	addi	sp,sp,-48
ffffffffc0201734:	f406                	sd	ra,40(sp)
ffffffffc0201736:	f022                	sd	s0,32(sp)
ffffffffc0201738:	ec26                	sd	s1,24(sp)
ffffffffc020173a:	e84a                	sd	s2,16(sp)
ffffffffc020173c:	e44e                	sd	s3,8(sp)
    assert(n > 0);
ffffffffc020173e:	c96d                	beqz	a0,ffffffffc0201830 <buddy_alloc_pages+0xfe>
    if (n > buddy_total_free) {
ffffffffc0201740:	00007997          	auipc	s3,0x7
ffffffffc0201744:	bb098993          	addi	s3,s3,-1104 # ffffffffc02082f0 <buddy_total_free>
ffffffffc0201748:	0009b903          	ld	s2,0(s3)
ffffffffc020174c:	84aa                	mv	s1,a0
ffffffffc020174e:	04a96463          	bltu	s2,a0,ffffffffc0201796 <buddy_alloc_pages+0x64>
    while ((order_block_pages(want_order) < n) && want_order < BUDDY_MAX_ORDER) {
ffffffffc0201752:	4785                	li	a5,1
    unsigned int want_order = 0;
ffffffffc0201754:	4581                	li	a1,0
    while ((order_block_pages(want_order) < n) && want_order < BUDDY_MAX_ORDER) {
ffffffffc0201756:	00f50c63          	beq	a0,a5,ffffffffc020176e <buddy_alloc_pages+0x3c>
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc020175a:	4705                	li	a4,1
    while ((order_block_pages(want_order) < n) && want_order < BUDDY_MAX_ORDER) {
ffffffffc020175c:	46c9                	li	a3,18
ffffffffc020175e:	a019                	j	ffffffffc0201764 <buddy_alloc_pages+0x32>
ffffffffc0201760:	00d58763          	beq	a1,a3,ffffffffc020176e <buddy_alloc_pages+0x3c>
        want_order++;
ffffffffc0201764:	2585                	addiw	a1,a1,1
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc0201766:	00b717b3          	sll	a5,a4,a1
    while ((order_block_pages(want_order) < n) && want_order < BUDDY_MAX_ORDER) {
ffffffffc020176a:	fe97ebe3          	bltu	a5,s1,ffffffffc0201760 <buddy_alloc_pages+0x2e>
ffffffffc020176e:	02059713          	slli	a4,a1,0x20
ffffffffc0201772:	9301                	srli	a4,a4,0x20
ffffffffc0201774:	00171793          	slli	a5,a4,0x1
ffffffffc0201778:	97ba                	add	a5,a5,a4
ffffffffc020177a:	00007617          	auipc	a2,0x7
ffffffffc020177e:	96660613          	addi	a2,a2,-1690 # ffffffffc02080e0 <buddy_area>
ffffffffc0201782:	078e                	slli	a5,a5,0x3
ffffffffc0201784:	97b2                	add	a5,a5,a2
    while (found_order <= BUDDY_MAX_ORDER && list_empty(&order_free_list(found_order))) {
ffffffffc0201786:	46cd                	li	a3,19
    return list->next == list;
ffffffffc0201788:	6798                	ld	a4,8(a5)
ffffffffc020178a:	00f71f63          	bne	a4,a5,ffffffffc02017a8 <buddy_alloc_pages+0x76>
        found_order++;
ffffffffc020178e:	2585                	addiw	a1,a1,1
    while (found_order <= BUDDY_MAX_ORDER && list_empty(&order_free_list(found_order))) {
ffffffffc0201790:	07e1                	addi	a5,a5,24
ffffffffc0201792:	fed59be3          	bne	a1,a3,ffffffffc0201788 <buddy_alloc_pages+0x56>
        return NULL;
ffffffffc0201796:	4401                	li	s0,0
}
ffffffffc0201798:	70a2                	ld	ra,40(sp)
ffffffffc020179a:	8522                	mv	a0,s0
ffffffffc020179c:	7402                	ld	s0,32(sp)
ffffffffc020179e:	64e2                	ld	s1,24(sp)
ffffffffc02017a0:	6942                	ld	s2,16(sp)
ffffffffc02017a2:	69a2                	ld	s3,8(sp)
ffffffffc02017a4:	6145                	addi	sp,sp,48
ffffffffc02017a6:	8082                	ret
    order_nr_free(found_order) -= order_block_pages(found_order);
ffffffffc02017a8:	02059693          	slli	a3,a1,0x20
ffffffffc02017ac:	9281                	srli	a3,a3,0x20
ffffffffc02017ae:	00169793          	slli	a5,a3,0x1
ffffffffc02017b2:	97b6                	add	a5,a5,a3
ffffffffc02017b4:	078e                	slli	a5,a5,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc02017b6:	00073883          	ld	a7,0(a4)
ffffffffc02017ba:	00873803          	ld	a6,8(a4)
ffffffffc02017be:	963e                	add	a2,a2,a5
ffffffffc02017c0:	4a08                	lw	a0,16(a2)
    ClearPageProperty(block);
ffffffffc02017c2:	ff073683          	ld	a3,-16(a4)
static inline size_t order_block_pages(size_t order) { return ((size_t)1u << order); }
ffffffffc02017c6:	4785                	li	a5,1
    prev->next = next;
ffffffffc02017c8:	0108b423          	sd	a6,8(a7)
ffffffffc02017cc:	00b795b3          	sll	a1,a5,a1
    next->prev = prev;
ffffffffc02017d0:	01183023          	sd	a7,0(a6) # 40000 <kern_entry-0xffffffffc01c0000>
    order_nr_free(found_order) -= order_block_pages(found_order);
ffffffffc02017d4:	40b507bb          	subw	a5,a0,a1
ffffffffc02017d8:	ca1c                	sw	a5,16(a2)
    ClearPageProperty(block);
ffffffffc02017da:	ffd6f793          	andi	a5,a3,-3
ffffffffc02017de:	fef73823          	sd	a5,-16(a4)
    block->property = 0;
ffffffffc02017e2:	fe072c23          	sw	zero,-8(a4)
    struct Page *block = le2page(le, page_link);
ffffffffc02017e6:	fe870413          	addi	s0,a4,-24
    if (n < s) {
ffffffffc02017ea:	02b4ea63          	bltu	s1,a1,ffffffffc020181e <buddy_alloc_pages+0xec>
    unsigned int want_order = 0;
ffffffffc02017ee:	87a2                	mv	a5,s0
ffffffffc02017f0:	4681                	li	a3,0
        ClearPageProperty(p);
ffffffffc02017f2:	6798                	ld	a4,8(a5)
        p->property = 0;
ffffffffc02017f4:	0007a823          	sw	zero,16(a5)
    for (size_t i = 0; i < n; i++, p++) {
ffffffffc02017f8:	0685                	addi	a3,a3,1
        ClearPageProperty(p);
ffffffffc02017fa:	9b75                	andi	a4,a4,-3
ffffffffc02017fc:	e798                	sd	a4,8(a5)
    for (size_t i = 0; i < n; i++, p++) {
ffffffffc02017fe:	02878793          	addi	a5,a5,40
ffffffffc0201802:	fed498e3          	bne	s1,a3,ffffffffc02017f2 <buddy_alloc_pages+0xc0>
}
ffffffffc0201806:	70a2                	ld	ra,40(sp)
ffffffffc0201808:	8522                	mv	a0,s0
ffffffffc020180a:	7402                	ld	s0,32(sp)
    buddy_total_free -= n;
ffffffffc020180c:	409904b3          	sub	s1,s2,s1
ffffffffc0201810:	0099b023          	sd	s1,0(s3)
}
ffffffffc0201814:	6942                	ld	s2,16(sp)
ffffffffc0201816:	64e2                	ld	s1,24(sp)
ffffffffc0201818:	69a2                	ld	s3,8(sp)
ffffffffc020181a:	6145                	addi	sp,sp,48
ffffffffc020181c:	8082                	ret
        struct Page *suffix = base + n;
ffffffffc020181e:	00249513          	slli	a0,s1,0x2
ffffffffc0201822:	9526                	add	a0,a0,s1
ffffffffc0201824:	050e                	slli	a0,a0,0x3
        insert_region(suffix, suffix_pages);
ffffffffc0201826:	8d85                	sub	a1,a1,s1
ffffffffc0201828:	9522                	add	a0,a0,s0
ffffffffc020182a:	ba2ff0ef          	jal	ra,ffffffffc0200bcc <insert_region>
ffffffffc020182e:	b7c1                	j	ffffffffc02017ee <buddy_alloc_pages+0xbc>
    assert(n > 0);
ffffffffc0201830:	00001697          	auipc	a3,0x1
ffffffffc0201834:	cb868693          	addi	a3,a3,-840 # ffffffffc02024e8 <class_sizes+0x378>
ffffffffc0201838:	00001617          	auipc	a2,0x1
ffffffffc020183c:	91060613          	addi	a2,a2,-1776 # ffffffffc0202148 <etext+0x3d4>
ffffffffc0201840:	08f00593          	li	a1,143
ffffffffc0201844:	00001517          	auipc	a0,0x1
ffffffffc0201848:	97c50513          	addi	a0,a0,-1668 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc020184c:	977fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0201850 <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0201850:	1141                	addi	sp,sp,-16
ffffffffc0201852:	e406                	sd	ra,8(sp)
ffffffffc0201854:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0201856:	c5ad                	beqz	a1,ffffffffc02018c0 <buddy_init_memmap+0x70>
    for (; p != base + n; p++) {
ffffffffc0201858:	00259693          	slli	a3,a1,0x2
ffffffffc020185c:	96ae                	add	a3,a3,a1
ffffffffc020185e:	068e                	slli	a3,a3,0x3
ffffffffc0201860:	96aa                	add	a3,a3,a0
ffffffffc0201862:	842e                	mv	s0,a1
ffffffffc0201864:	87aa                	mv	a5,a0
ffffffffc0201866:	00d50f63          	beq	a0,a3,ffffffffc0201884 <buddy_init_memmap+0x34>
        assert(PageReserved(p));
ffffffffc020186a:	6798                	ld	a4,8(a5)
ffffffffc020186c:	8b05                	andi	a4,a4,1
ffffffffc020186e:	cb0d                	beqz	a4,ffffffffc02018a0 <buddy_init_memmap+0x50>
        p->flags = 0;
ffffffffc0201870:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201874:	0007a823          	sw	zero,16(a5)
ffffffffc0201878:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc020187c:	02878793          	addi	a5,a5,40
ffffffffc0201880:	fed795e3          	bne	a5,a3,ffffffffc020186a <buddy_init_memmap+0x1a>
    insert_region(base, n);
ffffffffc0201884:	85a2                	mv	a1,s0
ffffffffc0201886:	b46ff0ef          	jal	ra,ffffffffc0200bcc <insert_region>
    buddy_total_free += n;
ffffffffc020188a:	00007717          	auipc	a4,0x7
ffffffffc020188e:	a6670713          	addi	a4,a4,-1434 # ffffffffc02082f0 <buddy_total_free>
ffffffffc0201892:	631c                	ld	a5,0(a4)
}
ffffffffc0201894:	60a2                	ld	ra,8(sp)
    buddy_total_free += n;
ffffffffc0201896:	97a2                	add	a5,a5,s0
}
ffffffffc0201898:	6402                	ld	s0,0(sp)
    buddy_total_free += n;
ffffffffc020189a:	e31c                	sd	a5,0(a4)
}
ffffffffc020189c:	0141                	addi	sp,sp,16
ffffffffc020189e:	8082                	ret
        assert(PageReserved(p));
ffffffffc02018a0:	00001697          	auipc	a3,0x1
ffffffffc02018a4:	c7868693          	addi	a3,a3,-904 # ffffffffc0202518 <class_sizes+0x3a8>
ffffffffc02018a8:	00001617          	auipc	a2,0x1
ffffffffc02018ac:	8a060613          	addi	a2,a2,-1888 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02018b0:	08500593          	li	a1,133
ffffffffc02018b4:	00001517          	auipc	a0,0x1
ffffffffc02018b8:	90c50513          	addi	a0,a0,-1780 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02018bc:	907fe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02018c0:	00001697          	auipc	a3,0x1
ffffffffc02018c4:	c2868693          	addi	a3,a3,-984 # ffffffffc02024e8 <class_sizes+0x378>
ffffffffc02018c8:	00001617          	auipc	a2,0x1
ffffffffc02018cc:	88060613          	addi	a2,a2,-1920 # ffffffffc0202148 <etext+0x3d4>
ffffffffc02018d0:	08200593          	li	a1,130
ffffffffc02018d4:	00001517          	auipc	a0,0x1
ffffffffc02018d8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02021c0 <class_sizes+0x50>
ffffffffc02018dc:	8e7fe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02018e0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02018e0:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02018e4:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02018e6:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02018e8:	cb81                	beqz	a5,ffffffffc02018f8 <strlen+0x18>
        cnt ++;
ffffffffc02018ea:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02018ec:	00a707b3          	add	a5,a4,a0
ffffffffc02018f0:	0007c783          	lbu	a5,0(a5)
ffffffffc02018f4:	fbfd                	bnez	a5,ffffffffc02018ea <strlen+0xa>
ffffffffc02018f6:	8082                	ret
    }
    return cnt;
}
ffffffffc02018f8:	8082                	ret

ffffffffc02018fa <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02018fa:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02018fc:	e589                	bnez	a1,ffffffffc0201906 <strnlen+0xc>
ffffffffc02018fe:	a811                	j	ffffffffc0201912 <strnlen+0x18>
        cnt ++;
ffffffffc0201900:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201902:	00f58863          	beq	a1,a5,ffffffffc0201912 <strnlen+0x18>
ffffffffc0201906:	00f50733          	add	a4,a0,a5
ffffffffc020190a:	00074703          	lbu	a4,0(a4)
ffffffffc020190e:	fb6d                	bnez	a4,ffffffffc0201900 <strnlen+0x6>
ffffffffc0201910:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201912:	852e                	mv	a0,a1
ffffffffc0201914:	8082                	ret

ffffffffc0201916 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201916:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020191a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020191e:	cb89                	beqz	a5,ffffffffc0201930 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201920:	0505                	addi	a0,a0,1
ffffffffc0201922:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201924:	fee789e3          	beq	a5,a4,ffffffffc0201916 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201928:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020192c:	9d19                	subw	a0,a0,a4
ffffffffc020192e:	8082                	ret
ffffffffc0201930:	4501                	li	a0,0
ffffffffc0201932:	bfed                	j	ffffffffc020192c <strcmp+0x16>

ffffffffc0201934 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201934:	c20d                	beqz	a2,ffffffffc0201956 <strncmp+0x22>
ffffffffc0201936:	962e                	add	a2,a2,a1
ffffffffc0201938:	a031                	j	ffffffffc0201944 <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc020193a:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020193c:	00e79a63          	bne	a5,a4,ffffffffc0201950 <strncmp+0x1c>
ffffffffc0201940:	00b60b63          	beq	a2,a1,ffffffffc0201956 <strncmp+0x22>
ffffffffc0201944:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201948:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020194a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020194e:	f7f5                	bnez	a5,ffffffffc020193a <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201950:	40e7853b          	subw	a0,a5,a4
}
ffffffffc0201954:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201956:	4501                	li	a0,0
ffffffffc0201958:	8082                	ret

ffffffffc020195a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020195a:	ca01                	beqz	a2,ffffffffc020196a <memset+0x10>
ffffffffc020195c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020195e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201960:	0785                	addi	a5,a5,1
ffffffffc0201962:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201966:	fec79de3          	bne	a5,a2,ffffffffc0201960 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020196a:	8082                	ret

ffffffffc020196c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020196c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201970:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201972:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201976:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201978:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020197c:	f022                	sd	s0,32(sp)
ffffffffc020197e:	ec26                	sd	s1,24(sp)
ffffffffc0201980:	e84a                	sd	s2,16(sp)
ffffffffc0201982:	f406                	sd	ra,40(sp)
ffffffffc0201984:	e44e                	sd	s3,8(sp)
ffffffffc0201986:	84aa                	mv	s1,a0
ffffffffc0201988:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020198a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020198e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201990:	03067e63          	bgeu	a2,a6,ffffffffc02019cc <printnum+0x60>
ffffffffc0201994:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201996:	00805763          	blez	s0,ffffffffc02019a4 <printnum+0x38>
ffffffffc020199a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020199c:	85ca                	mv	a1,s2
ffffffffc020199e:	854e                	mv	a0,s3
ffffffffc02019a0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02019a2:	fc65                	bnez	s0,ffffffffc020199a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019a4:	1a02                	slli	s4,s4,0x20
ffffffffc02019a6:	00001797          	auipc	a5,0x1
ffffffffc02019aa:	bd278793          	addi	a5,a5,-1070 # ffffffffc0202578 <buddy_pmm_manager+0x38>
ffffffffc02019ae:	020a5a13          	srli	s4,s4,0x20
ffffffffc02019b2:	9a3e                	add	s4,s4,a5
}
ffffffffc02019b4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019b6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02019ba:	70a2                	ld	ra,40(sp)
ffffffffc02019bc:	69a2                	ld	s3,8(sp)
ffffffffc02019be:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019c0:	85ca                	mv	a1,s2
ffffffffc02019c2:	87a6                	mv	a5,s1
}
ffffffffc02019c4:	6942                	ld	s2,16(sp)
ffffffffc02019c6:	64e2                	ld	s1,24(sp)
ffffffffc02019c8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019ca:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02019cc:	03065633          	divu	a2,a2,a6
ffffffffc02019d0:	8722                	mv	a4,s0
ffffffffc02019d2:	f9bff0ef          	jal	ra,ffffffffc020196c <printnum>
ffffffffc02019d6:	b7f9                	j	ffffffffc02019a4 <printnum+0x38>

ffffffffc02019d8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02019d8:	7119                	addi	sp,sp,-128
ffffffffc02019da:	f4a6                	sd	s1,104(sp)
ffffffffc02019dc:	f0ca                	sd	s2,96(sp)
ffffffffc02019de:	ecce                	sd	s3,88(sp)
ffffffffc02019e0:	e8d2                	sd	s4,80(sp)
ffffffffc02019e2:	e4d6                	sd	s5,72(sp)
ffffffffc02019e4:	e0da                	sd	s6,64(sp)
ffffffffc02019e6:	fc5e                	sd	s7,56(sp)
ffffffffc02019e8:	f06a                	sd	s10,32(sp)
ffffffffc02019ea:	fc86                	sd	ra,120(sp)
ffffffffc02019ec:	f8a2                	sd	s0,112(sp)
ffffffffc02019ee:	f862                	sd	s8,48(sp)
ffffffffc02019f0:	f466                	sd	s9,40(sp)
ffffffffc02019f2:	ec6e                	sd	s11,24(sp)
ffffffffc02019f4:	892a                	mv	s2,a0
ffffffffc02019f6:	84ae                	mv	s1,a1
ffffffffc02019f8:	8d32                	mv	s10,a2
ffffffffc02019fa:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02019fc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201a00:	5b7d                	li	s6,-1
ffffffffc0201a02:	00001a97          	auipc	s5,0x1
ffffffffc0201a06:	baaa8a93          	addi	s5,s5,-1110 # ffffffffc02025ac <buddy_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a0a:	00001b97          	auipc	s7,0x1
ffffffffc0201a0e:	d7eb8b93          	addi	s7,s7,-642 # ffffffffc0202788 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a12:	000d4503          	lbu	a0,0(s10)
ffffffffc0201a16:	001d0413          	addi	s0,s10,1
ffffffffc0201a1a:	01350a63          	beq	a0,s3,ffffffffc0201a2e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201a1e:	c121                	beqz	a0,ffffffffc0201a5e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201a20:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a22:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201a24:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a26:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201a2a:	ff351ae3          	bne	a0,s3,ffffffffc0201a1e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a2e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201a32:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201a36:	4c81                	li	s9,0
ffffffffc0201a38:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201a3a:	5c7d                	li	s8,-1
ffffffffc0201a3c:	5dfd                	li	s11,-1
ffffffffc0201a3e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201a42:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a44:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201a48:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a4c:	00140d13          	addi	s10,s0,1
ffffffffc0201a50:	04b56263          	bltu	a0,a1,ffffffffc0201a94 <vprintfmt+0xbc>
ffffffffc0201a54:	058a                	slli	a1,a1,0x2
ffffffffc0201a56:	95d6                	add	a1,a1,s5
ffffffffc0201a58:	4194                	lw	a3,0(a1)
ffffffffc0201a5a:	96d6                	add	a3,a3,s5
ffffffffc0201a5c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201a5e:	70e6                	ld	ra,120(sp)
ffffffffc0201a60:	7446                	ld	s0,112(sp)
ffffffffc0201a62:	74a6                	ld	s1,104(sp)
ffffffffc0201a64:	7906                	ld	s2,96(sp)
ffffffffc0201a66:	69e6                	ld	s3,88(sp)
ffffffffc0201a68:	6a46                	ld	s4,80(sp)
ffffffffc0201a6a:	6aa6                	ld	s5,72(sp)
ffffffffc0201a6c:	6b06                	ld	s6,64(sp)
ffffffffc0201a6e:	7be2                	ld	s7,56(sp)
ffffffffc0201a70:	7c42                	ld	s8,48(sp)
ffffffffc0201a72:	7ca2                	ld	s9,40(sp)
ffffffffc0201a74:	7d02                	ld	s10,32(sp)
ffffffffc0201a76:	6de2                	ld	s11,24(sp)
ffffffffc0201a78:	6109                	addi	sp,sp,128
ffffffffc0201a7a:	8082                	ret
            padc = '0';
ffffffffc0201a7c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201a7e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a82:	846a                	mv	s0,s10
ffffffffc0201a84:	00140d13          	addi	s10,s0,1
ffffffffc0201a88:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201a8c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a90:	fcb572e3          	bgeu	a0,a1,ffffffffc0201a54 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201a94:	85a6                	mv	a1,s1
ffffffffc0201a96:	02500513          	li	a0,37
ffffffffc0201a9a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201a9c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201aa0:	8d22                	mv	s10,s0
ffffffffc0201aa2:	f73788e3          	beq	a5,s3,ffffffffc0201a12 <vprintfmt+0x3a>
ffffffffc0201aa6:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201aaa:	1d7d                	addi	s10,s10,-1
ffffffffc0201aac:	ff379de3          	bne	a5,s3,ffffffffc0201aa6 <vprintfmt+0xce>
ffffffffc0201ab0:	b78d                	j	ffffffffc0201a12 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201ab2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201ab6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aba:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201abc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201ac0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201ac4:	02d86463          	bltu	a6,a3,ffffffffc0201aec <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201ac8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201acc:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201ad0:	0186873b          	addw	a4,a3,s8
ffffffffc0201ad4:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201ad8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201ada:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201ade:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201ae0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201ae4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201ae8:	fed870e3          	bgeu	a6,a3,ffffffffc0201ac8 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201aec:	f40ddce3          	bgez	s11,ffffffffc0201a44 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201af0:	8de2                	mv	s11,s8
ffffffffc0201af2:	5c7d                	li	s8,-1
ffffffffc0201af4:	bf81                	j	ffffffffc0201a44 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0201af6:	fffdc693          	not	a3,s11
ffffffffc0201afa:	96fd                	srai	a3,a3,0x3f
ffffffffc0201afc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b00:	00144603          	lbu	a2,1(s0)
ffffffffc0201b04:	2d81                	sext.w	s11,s11
ffffffffc0201b06:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b08:	bf35                	j	ffffffffc0201a44 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201b0a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b0e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201b12:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b14:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201b16:	bfd9                	j	ffffffffc0201aec <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201b18:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b1a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b1e:	01174463          	blt	a4,a7,ffffffffc0201b26 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201b22:	1a088e63          	beqz	a7,ffffffffc0201cde <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201b26:	000a3603          	ld	a2,0(s4)
ffffffffc0201b2a:	46c1                	li	a3,16
ffffffffc0201b2c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201b2e:	2781                	sext.w	a5,a5
ffffffffc0201b30:	876e                	mv	a4,s11
ffffffffc0201b32:	85a6                	mv	a1,s1
ffffffffc0201b34:	854a                	mv	a0,s2
ffffffffc0201b36:	e37ff0ef          	jal	ra,ffffffffc020196c <printnum>
            break;
ffffffffc0201b3a:	bde1                	j	ffffffffc0201a12 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b3c:	000a2503          	lw	a0,0(s4)
ffffffffc0201b40:	85a6                	mv	a1,s1
ffffffffc0201b42:	0a21                	addi	s4,s4,8
ffffffffc0201b44:	9902                	jalr	s2
            break;
ffffffffc0201b46:	b5f1                	j	ffffffffc0201a12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201b48:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b4a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b4e:	01174463          	blt	a4,a7,ffffffffc0201b56 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201b52:	18088163          	beqz	a7,ffffffffc0201cd4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201b56:	000a3603          	ld	a2,0(s4)
ffffffffc0201b5a:	46a9                	li	a3,10
ffffffffc0201b5c:	8a2e                	mv	s4,a1
ffffffffc0201b5e:	bfc1                	j	ffffffffc0201b2e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b60:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201b64:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b66:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b68:	bdf1                	j	ffffffffc0201a44 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201b6a:	85a6                	mv	a1,s1
ffffffffc0201b6c:	02500513          	li	a0,37
ffffffffc0201b70:	9902                	jalr	s2
            break;
ffffffffc0201b72:	b545                	j	ffffffffc0201a12 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b74:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201b78:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b7a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201b7c:	b5e1                	j	ffffffffc0201a44 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201b7e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201b80:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201b84:	01174463          	blt	a4,a7,ffffffffc0201b8c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201b88:	14088163          	beqz	a7,ffffffffc0201cca <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201b8c:	000a3603          	ld	a2,0(s4)
ffffffffc0201b90:	46a1                	li	a3,8
ffffffffc0201b92:	8a2e                	mv	s4,a1
ffffffffc0201b94:	bf69                	j	ffffffffc0201b2e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201b96:	03000513          	li	a0,48
ffffffffc0201b9a:	85a6                	mv	a1,s1
ffffffffc0201b9c:	e03e                	sd	a5,0(sp)
ffffffffc0201b9e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201ba0:	85a6                	mv	a1,s1
ffffffffc0201ba2:	07800513          	li	a0,120
ffffffffc0201ba6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201ba8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201baa:	6782                	ld	a5,0(sp)
ffffffffc0201bac:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201bae:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201bb2:	bfb5                	j	ffffffffc0201b2e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201bb4:	000a3403          	ld	s0,0(s4)
ffffffffc0201bb8:	008a0713          	addi	a4,s4,8
ffffffffc0201bbc:	e03a                	sd	a4,0(sp)
ffffffffc0201bbe:	14040263          	beqz	s0,ffffffffc0201d02 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201bc2:	0fb05763          	blez	s11,ffffffffc0201cb0 <vprintfmt+0x2d8>
ffffffffc0201bc6:	02d00693          	li	a3,45
ffffffffc0201bca:	0cd79163          	bne	a5,a3,ffffffffc0201c8c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bce:	00044783          	lbu	a5,0(s0)
ffffffffc0201bd2:	0007851b          	sext.w	a0,a5
ffffffffc0201bd6:	cf85                	beqz	a5,ffffffffc0201c0e <vprintfmt+0x236>
ffffffffc0201bd8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bdc:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201be0:	000c4563          	bltz	s8,ffffffffc0201bea <vprintfmt+0x212>
ffffffffc0201be4:	3c7d                	addiw	s8,s8,-1
ffffffffc0201be6:	036c0263          	beq	s8,s6,ffffffffc0201c0a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201bea:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bec:	0e0c8e63          	beqz	s9,ffffffffc0201ce8 <vprintfmt+0x310>
ffffffffc0201bf0:	3781                	addiw	a5,a5,-32
ffffffffc0201bf2:	0ef47b63          	bgeu	s0,a5,ffffffffc0201ce8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0201bf6:	03f00513          	li	a0,63
ffffffffc0201bfa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bfc:	000a4783          	lbu	a5,0(s4)
ffffffffc0201c00:	3dfd                	addiw	s11,s11,-1
ffffffffc0201c02:	0a05                	addi	s4,s4,1
ffffffffc0201c04:	0007851b          	sext.w	a0,a5
ffffffffc0201c08:	ffe1                	bnez	a5,ffffffffc0201be0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201c0a:	01b05963          	blez	s11,ffffffffc0201c1c <vprintfmt+0x244>
ffffffffc0201c0e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201c10:	85a6                	mv	a1,s1
ffffffffc0201c12:	02000513          	li	a0,32
ffffffffc0201c16:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201c18:	fe0d9be3          	bnez	s11,ffffffffc0201c0e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c1c:	6a02                	ld	s4,0(sp)
ffffffffc0201c1e:	bbd5                	j	ffffffffc0201a12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201c20:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c22:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201c26:	01174463          	blt	a4,a7,ffffffffc0201c2e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201c2a:	08088d63          	beqz	a7,ffffffffc0201cc4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201c2e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c32:	0a044d63          	bltz	s0,ffffffffc0201cec <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201c36:	8622                	mv	a2,s0
ffffffffc0201c38:	8a66                	mv	s4,s9
ffffffffc0201c3a:	46a9                	li	a3,10
ffffffffc0201c3c:	bdcd                	j	ffffffffc0201b2e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201c3e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c42:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201c44:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201c46:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201c4a:	8fb5                	xor	a5,a5,a3
ffffffffc0201c4c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c50:	02d74163          	blt	a4,a3,ffffffffc0201c72 <vprintfmt+0x29a>
ffffffffc0201c54:	00369793          	slli	a5,a3,0x3
ffffffffc0201c58:	97de                	add	a5,a5,s7
ffffffffc0201c5a:	639c                	ld	a5,0(a5)
ffffffffc0201c5c:	cb99                	beqz	a5,ffffffffc0201c72 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201c5e:	86be                	mv	a3,a5
ffffffffc0201c60:	00001617          	auipc	a2,0x1
ffffffffc0201c64:	94860613          	addi	a2,a2,-1720 # ffffffffc02025a8 <buddy_pmm_manager+0x68>
ffffffffc0201c68:	85a6                	mv	a1,s1
ffffffffc0201c6a:	854a                	mv	a0,s2
ffffffffc0201c6c:	0ce000ef          	jal	ra,ffffffffc0201d3a <printfmt>
ffffffffc0201c70:	b34d                	j	ffffffffc0201a12 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201c72:	00001617          	auipc	a2,0x1
ffffffffc0201c76:	92660613          	addi	a2,a2,-1754 # ffffffffc0202598 <buddy_pmm_manager+0x58>
ffffffffc0201c7a:	85a6                	mv	a1,s1
ffffffffc0201c7c:	854a                	mv	a0,s2
ffffffffc0201c7e:	0bc000ef          	jal	ra,ffffffffc0201d3a <printfmt>
ffffffffc0201c82:	bb41                	j	ffffffffc0201a12 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201c84:	00001417          	auipc	s0,0x1
ffffffffc0201c88:	90c40413          	addi	s0,s0,-1780 # ffffffffc0202590 <buddy_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201c8c:	85e2                	mv	a1,s8
ffffffffc0201c8e:	8522                	mv	a0,s0
ffffffffc0201c90:	e43e                	sd	a5,8(sp)
ffffffffc0201c92:	c69ff0ef          	jal	ra,ffffffffc02018fa <strnlen>
ffffffffc0201c96:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201c9a:	01b05b63          	blez	s11,ffffffffc0201cb0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201c9e:	67a2                	ld	a5,8(sp)
ffffffffc0201ca0:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201ca4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201ca6:	85a6                	mv	a1,s1
ffffffffc0201ca8:	8552                	mv	a0,s4
ffffffffc0201caa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cac:	fe0d9ce3          	bnez	s11,ffffffffc0201ca4 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cb0:	00044783          	lbu	a5,0(s0)
ffffffffc0201cb4:	00140a13          	addi	s4,s0,1
ffffffffc0201cb8:	0007851b          	sext.w	a0,a5
ffffffffc0201cbc:	d3a5                	beqz	a5,ffffffffc0201c1c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201cbe:	05e00413          	li	s0,94
ffffffffc0201cc2:	bf39                	j	ffffffffc0201be0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201cc4:	000a2403          	lw	s0,0(s4)
ffffffffc0201cc8:	b7ad                	j	ffffffffc0201c32 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201cca:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cce:	46a1                	li	a3,8
ffffffffc0201cd0:	8a2e                	mv	s4,a1
ffffffffc0201cd2:	bdb1                	j	ffffffffc0201b2e <vprintfmt+0x156>
ffffffffc0201cd4:	000a6603          	lwu	a2,0(s4)
ffffffffc0201cd8:	46a9                	li	a3,10
ffffffffc0201cda:	8a2e                	mv	s4,a1
ffffffffc0201cdc:	bd89                	j	ffffffffc0201b2e <vprintfmt+0x156>
ffffffffc0201cde:	000a6603          	lwu	a2,0(s4)
ffffffffc0201ce2:	46c1                	li	a3,16
ffffffffc0201ce4:	8a2e                	mv	s4,a1
ffffffffc0201ce6:	b5a1                	j	ffffffffc0201b2e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201ce8:	9902                	jalr	s2
ffffffffc0201cea:	bf09                	j	ffffffffc0201bfc <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201cec:	85a6                	mv	a1,s1
ffffffffc0201cee:	02d00513          	li	a0,45
ffffffffc0201cf2:	e03e                	sd	a5,0(sp)
ffffffffc0201cf4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201cf6:	6782                	ld	a5,0(sp)
ffffffffc0201cf8:	8a66                	mv	s4,s9
ffffffffc0201cfa:	40800633          	neg	a2,s0
ffffffffc0201cfe:	46a9                	li	a3,10
ffffffffc0201d00:	b53d                	j	ffffffffc0201b2e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201d02:	03b05163          	blez	s11,ffffffffc0201d24 <vprintfmt+0x34c>
ffffffffc0201d06:	02d00693          	li	a3,45
ffffffffc0201d0a:	f6d79de3          	bne	a5,a3,ffffffffc0201c84 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201d0e:	00001417          	auipc	s0,0x1
ffffffffc0201d12:	88240413          	addi	s0,s0,-1918 # ffffffffc0202590 <buddy_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d16:	02800793          	li	a5,40
ffffffffc0201d1a:	02800513          	li	a0,40
ffffffffc0201d1e:	00140a13          	addi	s4,s0,1
ffffffffc0201d22:	bd6d                	j	ffffffffc0201bdc <vprintfmt+0x204>
ffffffffc0201d24:	00001a17          	auipc	s4,0x1
ffffffffc0201d28:	86da0a13          	addi	s4,s4,-1939 # ffffffffc0202591 <buddy_pmm_manager+0x51>
ffffffffc0201d2c:	02800513          	li	a0,40
ffffffffc0201d30:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201d34:	05e00413          	li	s0,94
ffffffffc0201d38:	b565                	j	ffffffffc0201be0 <vprintfmt+0x208>

ffffffffc0201d3a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d3a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201d3c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d40:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d42:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d44:	ec06                	sd	ra,24(sp)
ffffffffc0201d46:	f83a                	sd	a4,48(sp)
ffffffffc0201d48:	fc3e                	sd	a5,56(sp)
ffffffffc0201d4a:	e0c2                	sd	a6,64(sp)
ffffffffc0201d4c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201d4e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d50:	c89ff0ef          	jal	ra,ffffffffc02019d8 <vprintfmt>
}
ffffffffc0201d54:	60e2                	ld	ra,24(sp)
ffffffffc0201d56:	6161                	addi	sp,sp,80
ffffffffc0201d58:	8082                	ret

ffffffffc0201d5a <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201d5a:	4781                	li	a5,0
ffffffffc0201d5c:	00004717          	auipc	a4,0x4
ffffffffc0201d60:	2bc73703          	ld	a4,700(a4) # ffffffffc0206018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201d64:	88ba                	mv	a7,a4
ffffffffc0201d66:	852a                	mv	a0,a0
ffffffffc0201d68:	85be                	mv	a1,a5
ffffffffc0201d6a:	863e                	mv	a2,a5
ffffffffc0201d6c:	00000073          	ecall
ffffffffc0201d70:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201d72:	8082                	ret
