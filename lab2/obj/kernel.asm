
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00008297          	auipc	t0,0x8
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0208000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00008297          	auipc	t0,0x8
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0208008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02042b7          	lui	t0,0xc0204
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
    #nop # 插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0208137          	lui	sp,0xc0208

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
ffffffffc020004c:	00005517          	auipc	a0,0x5
ffffffffc0200050:	fb450513          	addi	a0,a0,-76 # ffffffffc0205000 <boot_page_table_sv39+0x1000>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07e58593          	addi	a1,a1,126 # ffffffffc02000d8 <kern_init>
ffffffffc0200062:	00005517          	auipc	a0,0x5
ffffffffc0200066:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205020 <boot_page_table_sv39+0x1020>
ffffffffc020006a:	0e2000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00002597          	auipc	a1,0x2
ffffffffc0200072:	a0058593          	addi	a1,a1,-1536 # ffffffffc0201a6e <etext>
ffffffffc0200076:	00005517          	auipc	a0,0x5
ffffffffc020007a:	fca50513          	addi	a0,a0,-54 # ffffffffc0205040 <boot_page_table_sv39+0x1040>
ffffffffc020007e:	0ce000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00008597          	auipc	a1,0x8
ffffffffc0200086:	f9e58593          	addi	a1,a1,-98 # ffffffffc0208020 <caches>
ffffffffc020008a:	00005517          	auipc	a0,0x5
ffffffffc020008e:	fd650513          	addi	a0,a0,-42 # ffffffffc0205060 <boot_page_table_sv39+0x1060>
ffffffffc0200092:	0ba000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	0000a597          	auipc	a1,0xa
ffffffffc020009a:	0aa58593          	addi	a1,a1,170 # ffffffffc020a140 <end>
ffffffffc020009e:	00005517          	auipc	a0,0x5
ffffffffc02000a2:	fe250513          	addi	a0,a0,-30 # ffffffffc0205080 <boot_page_table_sv39+0x1080>
ffffffffc02000a6:	0a6000ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	0000a597          	auipc	a1,0xa
ffffffffc02000ae:	49558593          	addi	a1,a1,1173 # ffffffffc020a53f <end+0x3ff>
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
ffffffffc02000cc:	00005517          	auipc	a0,0x5
ffffffffc02000d0:	fd450513          	addi	a0,a0,-44 # ffffffffc02050a0 <boot_page_table_sv39+0x10a0>
}
ffffffffc02000d4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d6:	a89d                	j	ffffffffc020014c <cprintf>

ffffffffc02000d8 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d8:	00008517          	auipc	a0,0x8
ffffffffc02000dc:	f4850513          	addi	a0,a0,-184 # ffffffffc0208020 <caches>
ffffffffc02000e0:	0000a617          	auipc	a2,0xa
ffffffffc02000e4:	06060613          	addi	a2,a2,96 # ffffffffc020a140 <end>
int kern_init(void) {
ffffffffc02000e8:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000ea:	8e09                	sub	a2,a2,a0
ffffffffc02000ec:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ee:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000f0:	564010ef          	jal	ra,ffffffffc0201654 <memset>
    dtb_init();
ffffffffc02000f4:	122000ef          	jal	ra,ffffffffc0200216 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f8:	4ce000ef          	jal	ra,ffffffffc02005c6 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fc:	00005517          	auipc	a0,0x5
ffffffffc0200100:	fd450513          	addi	a0,a0,-44 # ffffffffc02050d0 <boot_page_table_sv39+0x10d0>
ffffffffc0200104:	07e000ef          	jal	ra,ffffffffc0200182 <cputs>

    print_kerninfo();
ffffffffc0200108:	f43ff0ef          	jal	ra,ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010c:	4e8000ef          	jal	ra,ffffffffc02005f4 <pmm_init>

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
ffffffffc0200140:	592010ef          	jal	ra,ffffffffc02016d2 <vprintfmt>
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
ffffffffc020014e:	02810313          	addi	t1,sp,40 # ffffffffc0208028 <caches+0x8>
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
ffffffffc0200176:	55c010ef          	jal	ra,ffffffffc02016d2 <vprintfmt>
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
ffffffffc02001c2:	0000a317          	auipc	t1,0xa
ffffffffc02001c6:	f3630313          	addi	t1,t1,-202 # ffffffffc020a0f8 <is_panic>
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
ffffffffc02001f2:	00005517          	auipc	a0,0x5
ffffffffc02001f6:	efe50513          	addi	a0,a0,-258 # ffffffffc02050f0 <boot_page_table_sv39+0x10f0>
    va_start(ap, fmt);
ffffffffc02001fa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001fc:	f51ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200200:	65a2                	ld	a1,8(sp)
ffffffffc0200202:	8522                	mv	a0,s0
ffffffffc0200204:	f29ff0ef          	jal	ra,ffffffffc020012c <vcprintf>
    cprintf("\n");
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	ec050513          	addi	a0,a0,-320 # ffffffffc02050c8 <boot_page_table_sv39+0x10c8>
ffffffffc0200210:	f3dff0ef          	jal	ra,ffffffffc020014c <cprintf>
ffffffffc0200214:	b7f9                	j	ffffffffc02001e2 <__panic+0x20>

ffffffffc0200216 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200216:	7119                	addi	sp,sp,-128
    cprintf("DTB Init\n");
ffffffffc0200218:	00005517          	auipc	a0,0x5
ffffffffc020021c:	ef850513          	addi	a0,a0,-264 # ffffffffc0205110 <boot_page_table_sv39+0x1110>
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
ffffffffc020023e:	00008597          	auipc	a1,0x8
ffffffffc0200242:	dc25b583          	ld	a1,-574(a1) # ffffffffc0208000 <boot_hartid>
ffffffffc0200246:	00005517          	auipc	a0,0x5
ffffffffc020024a:	eda50513          	addi	a0,a0,-294 # ffffffffc0205120 <boot_page_table_sv39+0x1120>
ffffffffc020024e:	effff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200252:	00008417          	auipc	s0,0x8
ffffffffc0200256:	db640413          	addi	s0,s0,-586 # ffffffffc0208008 <boot_dtb>
ffffffffc020025a:	600c                	ld	a1,0(s0)
ffffffffc020025c:	00005517          	auipc	a0,0x5
ffffffffc0200260:	ed450513          	addi	a0,a0,-300 # ffffffffc0205130 <boot_page_table_sv39+0x1130>
ffffffffc0200264:	ee9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200268:	00043a03          	ld	s4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00005517          	auipc	a0,0x5
ffffffffc0200270:	edc50513          	addi	a0,a0,-292 # ffffffffc0205148 <boot_page_table_sv39+0x1148>
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
ffffffffc02002b4:	eed78793          	addi	a5,a5,-275 # ffffffffd00dfeed <end+0xfed5dad>
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
ffffffffc0200326:	00005917          	auipc	s2,0x5
ffffffffc020032a:	e7290913          	addi	s2,s2,-398 # ffffffffc0205198 <boot_page_table_sv39+0x1198>
ffffffffc020032e:	49bd                	li	s3,15
        switch (token) {
ffffffffc0200330:	4d91                	li	s11,4
ffffffffc0200332:	4d05                	li	s10,1
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200334:	00005497          	auipc	s1,0x5
ffffffffc0200338:	e5c48493          	addi	s1,s1,-420 # ffffffffc0205190 <boot_page_table_sv39+0x1190>
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
ffffffffc0200388:	00005517          	auipc	a0,0x5
ffffffffc020038c:	e8850513          	addi	a0,a0,-376 # ffffffffc0205210 <boot_page_table_sv39+0x1210>
ffffffffc0200390:	dbdff0ef          	jal	ra,ffffffffc020014c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200394:	00005517          	auipc	a0,0x5
ffffffffc0200398:	eb450513          	addi	a0,a0,-332 # ffffffffc0205248 <boot_page_table_sv39+0x1248>
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
ffffffffc02003d4:	00005517          	auipc	a0,0x5
ffffffffc02003d8:	d9450513          	addi	a0,a0,-620 # ffffffffc0205168 <boot_page_table_sv39+0x1168>
}
ffffffffc02003dc:	6109                	addi	sp,sp,128
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003de:	b3bd                	j	ffffffffc020014c <cprintf>
                int name_len = strlen(name);
ffffffffc02003e0:	8556                	mv	a0,s5
ffffffffc02003e2:	1f8010ef          	jal	ra,ffffffffc02015da <strlen>
ffffffffc02003e6:	8a2a                	mv	s4,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	4619                	li	a2,6
ffffffffc02003ea:	85a6                	mv	a1,s1
ffffffffc02003ec:	8556                	mv	a0,s5
                int name_len = strlen(name);
ffffffffc02003ee:	2a01                	sext.w	s4,s4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003f0:	23e010ef          	jal	ra,ffffffffc020162e <strncmp>
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
ffffffffc0200486:	18a010ef          	jal	ra,ffffffffc0201610 <strcmp>
ffffffffc020048a:	66a2                	ld	a3,8(sp)
ffffffffc020048c:	f94d                	bnez	a0,ffffffffc020043e <dtb_init+0x228>
ffffffffc020048e:	fb59f8e3          	bgeu	s3,s5,ffffffffc020043e <dtb_init+0x228>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200492:	00ca3783          	ld	a5,12(s4)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200496:	014a3703          	ld	a4,20(s4)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020049a:	00005517          	auipc	a0,0x5
ffffffffc020049e:	d0650513          	addi	a0,a0,-762 # ffffffffc02051a0 <boot_page_table_sv39+0x11a0>
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
ffffffffc0200568:	00005517          	auipc	a0,0x5
ffffffffc020056c:	c5850513          	addi	a0,a0,-936 # ffffffffc02051c0 <boot_page_table_sv39+0x11c0>
ffffffffc0200570:	bddff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200574:	014b5613          	srli	a2,s6,0x14
ffffffffc0200578:	85da                	mv	a1,s6
ffffffffc020057a:	00005517          	auipc	a0,0x5
ffffffffc020057e:	c5e50513          	addi	a0,a0,-930 # ffffffffc02051d8 <boot_page_table_sv39+0x11d8>
ffffffffc0200582:	bcbff0ef          	jal	ra,ffffffffc020014c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200586:	008b05b3          	add	a1,s6,s0
ffffffffc020058a:	15fd                	addi	a1,a1,-1
ffffffffc020058c:	00005517          	auipc	a0,0x5
ffffffffc0200590:	c6c50513          	addi	a0,a0,-916 # ffffffffc02051f8 <boot_page_table_sv39+0x11f8>
ffffffffc0200594:	bb9ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    cprintf("DTB init completed\n");
ffffffffc0200598:	00005517          	auipc	a0,0x5
ffffffffc020059c:	cb050513          	addi	a0,a0,-848 # ffffffffc0205248 <boot_page_table_sv39+0x1248>
        memory_base = mem_base;
ffffffffc02005a0:	0000a797          	auipc	a5,0xa
ffffffffc02005a4:	b687b023          	sd	s0,-1184(a5) # ffffffffc020a100 <memory_base>
        memory_size = mem_size;
ffffffffc02005a8:	0000a797          	auipc	a5,0xa
ffffffffc02005ac:	b767b023          	sd	s6,-1184(a5) # ffffffffc020a108 <memory_size>
    cprintf("DTB init completed\n");
ffffffffc02005b0:	b3f5                	j	ffffffffc020039c <dtb_init+0x186>

ffffffffc02005b2 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02005b2:	0000a517          	auipc	a0,0xa
ffffffffc02005b6:	b4e53503          	ld	a0,-1202(a0) # ffffffffc020a100 <memory_base>
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005bc:	0000a517          	auipc	a0,0xa
ffffffffc02005c0:	b4c53503          	ld	a0,-1204(a0) # ffffffffc020a108 <memory_size>
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
ffffffffc02005cc:	4880106f          	j	ffffffffc0201a54 <sbi_console_putchar>

ffffffffc02005d0 <alloc_pages>:
 * 
 * @param n 要分配的页面数量
 * @return 分配成功返回起始Page结构体指针，失败返回NULL
 */
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02005d0:	0000a797          	auipc	a5,0xa
ffffffffc02005d4:	b507b783          	ld	a5,-1200(a5) # ffffffffc020a120 <pmm_manager>
ffffffffc02005d8:	6f9c                	ld	a5,24(a5)
ffffffffc02005da:	8782                	jr	a5

ffffffffc02005dc <free_pages>:
 * 
 * @param base 要释放页面的起始Page结构体
 * @param n    要释放的页面数量
 */
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc02005dc:	0000a797          	auipc	a5,0xa
ffffffffc02005e0:	b447b783          	ld	a5,-1212(a5) # ffffffffc020a120 <pmm_manager>
ffffffffc02005e4:	739c                	ld	a5,32(a5)
ffffffffc02005e6:	8782                	jr	a5

ffffffffc02005e8 <nr_free_pages>:
 * 调用具体PMM管理器的nr_free_pages方法来获取当前空闲内存的大小。
 * 
 * @return 当前空闲页面的数量
 */
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
ffffffffc02005e8:	0000a797          	auipc	a5,0xa
ffffffffc02005ec:	b387b783          	ld	a5,-1224(a5) # ffffffffc020a120 <pmm_manager>
ffffffffc02005f0:	779c                	ld	a5,40(a5)
ffffffffc02005f2:	8782                	jr	a5

ffffffffc02005f4 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;        // 选择内存管理算法 - Select memory management algorithm
ffffffffc02005f4:	00005797          	auipc	a5,0x5
ffffffffc02005f8:	17478793          	addi	a5,a5,372 # ffffffffc0205768 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005fc:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02005fe:	7179                	addi	sp,sp,-48
ffffffffc0200600:	f022                	sd	s0,32(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200602:	00005517          	auipc	a0,0x5
ffffffffc0200606:	c5e50513          	addi	a0,a0,-930 # ffffffffc0205260 <boot_page_table_sv39+0x1260>
    pmm_manager = &best_fit_pmm_manager;        // 选择内存管理算法 - Select memory management algorithm
ffffffffc020060a:	0000a417          	auipc	s0,0xa
ffffffffc020060e:	b1640413          	addi	s0,s0,-1258 # ffffffffc020a120 <pmm_manager>
void pmm_init(void) {
ffffffffc0200612:	f406                	sd	ra,40(sp)
ffffffffc0200614:	ec26                	sd	s1,24(sp)
ffffffffc0200616:	e44e                	sd	s3,8(sp)
ffffffffc0200618:	e84a                	sd	s2,16(sp)
ffffffffc020061a:	e052                	sd	s4,0(sp)
    pmm_manager = &best_fit_pmm_manager;        // 选择内存管理算法 - Select memory management algorithm
ffffffffc020061c:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020061e:	b2fff0ef          	jal	ra,ffffffffc020014c <cprintf>
    pmm_manager->init();                        // 初始化选定的管理器 - Initialize selected manager
ffffffffc0200622:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200624:	0000a497          	auipc	s1,0xa
ffffffffc0200628:	b1448493          	addi	s1,s1,-1260 # ffffffffc020a138 <va_pa_offset>
    pmm_manager->init();                        // 初始化选定的管理器 - Initialize selected manager
ffffffffc020062c:	679c                	ld	a5,8(a5)
ffffffffc020062e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200630:	57f5                	li	a5,-3
ffffffffc0200632:	07fa                	slli	a5,a5,0x1e
ffffffffc0200634:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();     // 内存起始物理地址 - Memory start physical address
ffffffffc0200636:	f7dff0ef          	jal	ra,ffffffffc02005b2 <get_memory_base>
ffffffffc020063a:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();     // 内存总大小 - Total memory size
ffffffffc020063c:	f81ff0ef          	jal	ra,ffffffffc02005bc <get_memory_size>
    if (mem_size == 0) {
ffffffffc0200640:	16050063          	beqz	a0,ffffffffc02007a0 <pmm_init+0x1ac>
    uint64_t mem_end   = mem_begin + mem_size;  // 内存结束物理地址 - Memory end physical address
ffffffffc0200644:	892a                	mv	s2,a0
    cprintf("physcial memory map:\n");
ffffffffc0200646:	00005517          	auipc	a0,0x5
ffffffffc020064a:	c6250513          	addi	a0,a0,-926 # ffffffffc02052a8 <boot_page_table_sv39+0x12a8>
ffffffffc020064e:	affff0ef          	jal	ra,ffffffffc020014c <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;  // 内存结束物理地址 - Memory end physical address
ffffffffc0200652:	01298a33          	add	s4,s3,s2
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin, mem_end - 1);
ffffffffc0200656:	864e                	mv	a2,s3
ffffffffc0200658:	fffa0693          	addi	a3,s4,-1
ffffffffc020065c:	85ca                	mv	a1,s2
ffffffffc020065e:	00005517          	auipc	a0,0x5
ffffffffc0200662:	c6250513          	addi	a0,a0,-926 # ffffffffc02052c0 <boot_page_table_sv39+0x12c0>
ffffffffc0200666:	ae7ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;                     // 总页面数 - Total page count
ffffffffc020066a:	c80007b7          	lui	a5,0xc8000
ffffffffc020066e:	8652                	mv	a2,s4
ffffffffc0200670:	0d47e763          	bltu	a5,s4,ffffffffc020073e <pmm_init+0x14a>
ffffffffc0200674:	0000b797          	auipc	a5,0xb
ffffffffc0200678:	acb78793          	addi	a5,a5,-1333 # ffffffffc020b13f <end+0xfff>
ffffffffc020067c:	757d                	lui	a0,0xfffff
ffffffffc020067e:	8d7d                	and	a0,a0,a5
ffffffffc0200680:	8231                	srli	a2,a2,0xc
ffffffffc0200682:	0000a797          	auipc	a5,0xa
ffffffffc0200686:	a8c7b723          	sd	a2,-1394(a5) # ffffffffc020a110 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020068a:	0000a797          	auipc	a5,0xa
ffffffffc020068e:	a8a7b723          	sd	a0,-1394(a5) # ffffffffc020a118 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200692:	000807b7          	lui	a5,0x80
ffffffffc0200696:	002005b7          	lui	a1,0x200
ffffffffc020069a:	02f60563          	beq	a2,a5,ffffffffc02006c4 <pmm_init+0xd0>
ffffffffc020069e:	00261593          	slli	a1,a2,0x2
ffffffffc02006a2:	00c586b3          	add	a3,a1,a2
ffffffffc02006a6:	fec007b7          	lui	a5,0xfec00
ffffffffc02006aa:	97aa                	add	a5,a5,a0
ffffffffc02006ac:	068e                	slli	a3,a3,0x3
ffffffffc02006ae:	96be                	add	a3,a3,a5
ffffffffc02006b0:	87aa                	mv	a5,a0
        SetPageReserved(pages + i);
ffffffffc02006b2:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006b4:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f5ee8>
        SetPageReserved(pages + i);
ffffffffc02006b8:	00176713          	ori	a4,a4,1
ffffffffc02006bc:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02006c0:	fef699e3          	bne	a3,a5,ffffffffc02006b2 <pmm_init+0xbe>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006c4:	95b2                	add	a1,a1,a2
ffffffffc02006c6:	fec006b7          	lui	a3,0xfec00
ffffffffc02006ca:	96aa                	add	a3,a3,a0
ffffffffc02006cc:	058e                	slli	a1,a1,0x3
ffffffffc02006ce:	96ae                	add	a3,a3,a1
ffffffffc02006d0:	c02007b7          	lui	a5,0xc0200
ffffffffc02006d4:	0af6ea63          	bltu	a3,a5,ffffffffc0200788 <pmm_init+0x194>
ffffffffc02006d8:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);       // 向下对齐到页边界 - Round down to page boundary
ffffffffc02006da:	77fd                	lui	a5,0xfffff
ffffffffc02006dc:	00fa75b3          	and	a1,s4,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02006e0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02006e2:	06b6e163          	bltu	a3,a1,ffffffffc0200744 <pmm_init+0x150>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02006e6:	601c                	ld	a5,0(s0)
ffffffffc02006e8:	7b9c                	ld	a5,48(a5)
ffffffffc02006ea:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	c5c50513          	addi	a0,a0,-932 # ffffffffc0205348 <boot_page_table_sv39+0x1348>
ffffffffc02006f4:	a59ff0ef          	jal	ra,ffffffffc020014c <cprintf>
    slub_init();
ffffffffc02006f8:	1d0000ef          	jal	ra,ffffffffc02008c8 <slub_init>
    slub_check();
ffffffffc02006fc:	474000ef          	jal	ra,ffffffffc0200b70 <slub_check>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200700:	00004597          	auipc	a1,0x4
ffffffffc0200704:	90058593          	addi	a1,a1,-1792 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc0200708:	0000a797          	auipc	a5,0xa
ffffffffc020070c:	a2b7b423          	sd	a1,-1496(a5) # ffffffffc020a130 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200710:	c02007b7          	lui	a5,0xc0200
ffffffffc0200714:	0af5e263          	bltu	a1,a5,ffffffffc02007b8 <pmm_init+0x1c4>
ffffffffc0200718:	6090                	ld	a2,0(s1)
}
ffffffffc020071a:	7402                	ld	s0,32(sp)
ffffffffc020071c:	70a2                	ld	ra,40(sp)
ffffffffc020071e:	64e2                	ld	s1,24(sp)
ffffffffc0200720:	6942                	ld	s2,16(sp)
ffffffffc0200722:	69a2                	ld	s3,8(sp)
ffffffffc0200724:	6a02                	ld	s4,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200726:	40c58633          	sub	a2,a1,a2
ffffffffc020072a:	0000a797          	auipc	a5,0xa
ffffffffc020072e:	9ec7bf23          	sd	a2,-1538(a5) # ffffffffc020a128 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	c3650513          	addi	a0,a0,-970 # ffffffffc0205368 <boot_page_table_sv39+0x1368>
}
ffffffffc020073a:	6145                	addi	sp,sp,48
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020073c:	bc01                	j	ffffffffc020014c <cprintf>
    npage = maxpa / PGSIZE;                     // 总页面数 - Total page count
ffffffffc020073e:	c8000637          	lui	a2,0xc8000
ffffffffc0200742:	bf0d                	j	ffffffffc0200674 <pmm_init+0x80>
    mem_begin = ROUNDUP(freemem, PGSIZE);       // 向上对齐到页边界 - Round up to page boundary
ffffffffc0200744:	6705                	lui	a4,0x1
ffffffffc0200746:	177d                	addi	a4,a4,-1
ffffffffc0200748:	96ba                	add	a3,a3,a4
ffffffffc020074a:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020074c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200750:	02c7f063          	bgeu	a5,a2,ffffffffc0200770 <pmm_init+0x17c>
    pmm_manager->init_memmap(base, n);
ffffffffc0200754:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200756:	fff80737          	lui	a4,0xfff80
ffffffffc020075a:	973e                	add	a4,a4,a5
ffffffffc020075c:	00271793          	slli	a5,a4,0x2
ffffffffc0200760:	97ba                	add	a5,a5,a4
ffffffffc0200762:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200764:	8d95                	sub	a1,a1,a3
ffffffffc0200766:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200768:	81b1                	srli	a1,a1,0xc
ffffffffc020076a:	953e                	add	a0,a0,a5
ffffffffc020076c:	9702                	jalr	a4
}
ffffffffc020076e:	bfa5                	j	ffffffffc02006e6 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc0200770:	00005617          	auipc	a2,0x5
ffffffffc0200774:	ba860613          	addi	a2,a2,-1112 # ffffffffc0205318 <boot_page_table_sv39+0x1318>
ffffffffc0200778:	08500593          	li	a1,133
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0205338 <boot_page_table_sv39+0x1338>
ffffffffc0200784:	a3fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200788:	00005617          	auipc	a2,0x5
ffffffffc020078c:	b6860613          	addi	a2,a2,-1176 # ffffffffc02052f0 <boot_page_table_sv39+0x12f0>
ffffffffc0200790:	09700593          	li	a1,151
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	b0450513          	addi	a0,a0,-1276 # ffffffffc0205298 <boot_page_table_sv39+0x1298>
ffffffffc020079c:	a27ff0ef          	jal	ra,ffffffffc02001c2 <__panic>
        panic("DTB memory info not available");
ffffffffc02007a0:	00005617          	auipc	a2,0x5
ffffffffc02007a4:	ad860613          	addi	a2,a2,-1320 # ffffffffc0205278 <boot_page_table_sv39+0x1278>
ffffffffc02007a8:	07c00593          	li	a1,124
ffffffffc02007ac:	00005517          	auipc	a0,0x5
ffffffffc02007b0:	aec50513          	addi	a0,a0,-1300 # ffffffffc0205298 <boot_page_table_sv39+0x1298>
ffffffffc02007b4:	a0fff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02007b8:	86ae                	mv	a3,a1
ffffffffc02007ba:	00005617          	auipc	a2,0x5
ffffffffc02007be:	b3660613          	addi	a2,a2,-1226 # ffffffffc02052f0 <boot_page_table_sv39+0x12f0>
ffffffffc02007c2:	0b900593          	li	a1,185
ffffffffc02007c6:	00005517          	auipc	a0,0x5
ffffffffc02007ca:	ad250513          	addi	a0,a0,-1326 # ffffffffc0205298 <boot_page_table_sv39+0x1298>
ffffffffc02007ce:	9f5ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02007d2 <free_in_list>:
 * @param list_head 链表头指针的地址
 * @param cache     目标缓存
 * @param ptr       要释放的对象指针
 * @return 找到并释放返回1，未找到返回0
 */
static int free_in_list(slab_page_t **list_head, kmem_cache_t *cache, void *ptr) {
ffffffffc02007d2:	1141                	addi	sp,sp,-16
ffffffffc02007d4:	e022                	sd	s0,0(sp)
    // 遍历链表寻找包含该地址的页面 - Traverse list to find page containing the address
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc02007d6:	6100                	ld	s0,0(a0)
static int free_in_list(slab_page_t **list_head, kmem_cache_t *cache, void *ptr) {
ffffffffc02007d8:	e406                	sd	ra,8(sp)
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc02007da:	c821                	beqz	s0,ffffffffc020082a <free_in_list+0x58>
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;    // 页面起始虚拟地址 - Page start virtual address
        uintptr_t end  = base + PGSIZE;                                 // 页面结束虚拟地址 - Page end virtual address
ffffffffc02007dc:	fff406b7          	lui	a3,0xfff40
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;    // 页面起始虚拟地址 - Page start virtual address
ffffffffc02007e0:	5875                	li	a6,-3
        uintptr_t end  = base + PGSIZE;                                 // 页面结束虚拟地址 - Page end virtual address
ffffffffc02007e2:	0685                	addi	a3,a3,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007e4:	0000ae17          	auipc	t3,0xa
ffffffffc02007e8:	934e3e03          	ld	t3,-1740(t3) # ffffffffc020a118 <pages>
ffffffffc02007ec:	00005317          	auipc	t1,0x5
ffffffffc02007f0:	1fc33303          	ld	t1,508(t1) # ffffffffc02059e8 <nbase>
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc02007f4:	4e81                	li	t4,0
ffffffffc02007f6:	00005897          	auipc	a7,0x5
ffffffffc02007fa:	1fa8b883          	ld	a7,506(a7) # ffffffffc02059f0 <nbase+0x8>
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;    // 页面起始虚拟地址 - Page start virtual address
ffffffffc02007fe:	087a                	slli	a6,a6,0x1e
        uintptr_t end  = base + PGSIZE;                                 // 页面结束虚拟地址 - Page end virtual address
ffffffffc0200800:	06b2                	slli	a3,a3,0xc
ffffffffc0200802:	a011                	j	ffffffffc0200806 <free_in_list+0x34>
ffffffffc0200804:	843e                	mv	s0,a5
ffffffffc0200806:	601c                	ld	a5,0(s0)
ffffffffc0200808:	41c787b3          	sub	a5,a5,t3
ffffffffc020080c:	878d                	srai	a5,a5,0x3
ffffffffc020080e:	031787b3          	mul	a5,a5,a7
ffffffffc0200812:	979a                	add	a5,a5,t1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200814:	07b2                	slli	a5,a5,0xc
        uintptr_t base = page2pa(sp->page) + PHYSICAL_MEMORY_OFFSET;    // 页面起始虚拟地址 - Page start virtual address
ffffffffc0200816:	01078733          	add	a4,a5,a6
        uintptr_t end  = base + PGSIZE;                                 // 页面结束虚拟地址 - Page end virtual address
ffffffffc020081a:	97b6                	add	a5,a5,a3
        
        // 检查地址是否在此页面范围内 - Check if address is within this page range
        if ((uintptr_t)ptr >= base && (uintptr_t)ptr < end) {
ffffffffc020081c:	00e66463          	bltu	a2,a4,ffffffffc0200824 <free_in_list+0x52>
ffffffffc0200820:	00f66a63          	bltu	a2,a5,ffffffffc0200834 <free_in_list+0x62>
    for (slab_page_t *sp = *list_head, *prev = NULL; sp != NULL; prev = sp, sp = sp->next) {
ffffffffc0200824:	6c1c                	ld	a5,24(s0)
ffffffffc0200826:	8ea2                	mv	t4,s0
ffffffffc0200828:	fff1                	bnez	a5,ffffffffc0200804 <free_in_list+0x32>
            }
            return 1;  // 成功释放 - Successfully freed
        }
    }
    return 0;  // 未找到 - Not found
}
ffffffffc020082a:	60a2                	ld	ra,8(sp)
ffffffffc020082c:	6402                	ld	s0,0(sp)
    return 0;  // 未找到 - Not found
ffffffffc020082e:	4501                	li	a0,0
}
ffffffffc0200830:	0141                	addi	sp,sp,16
ffffffffc0200832:	8082                	ret
            *(void **)ptr = sp->free_head;              // 在对象开头存储原链表头 - Store original list head at object start
ffffffffc0200834:	6414                	ld	a3,8(s0)
            if (sp->inuse > 0) sp->inuse--;             // 减少使用计数 - Decrease usage count
ffffffffc0200836:	481c                	lw	a5,16(s0)
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc0200838:	01058713          	addi	a4,a1,16
            *(void **)ptr = sp->free_head;              // 在对象开头存储原链表头 - Store original list head at object start
ffffffffc020083c:	e214                	sd	a3,0(a2)
            sp->free_head = ptr;                        // 更新链表头为当前对象 - Update list head to current object
ffffffffc020083e:	e410                	sd	a2,8(s0)
            if (sp->inuse > 0) sp->inuse--;             // 减少使用计数 - Decrease usage count
ffffffffc0200840:	cb99                	beqz	a5,ffffffffc0200856 <free_in_list+0x84>
ffffffffc0200842:	37fd                	addiw	a5,a5,-1
ffffffffc0200844:	c81c                	sw	a5,16(s0)
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc0200846:	04e50463          	beq	a0,a4,ffffffffc020088e <free_in_list+0xbc>
            if (sp->inuse == 0 && sp->capacity > 0) {
ffffffffc020084a:	cb81                	beqz	a5,ffffffffc020085a <free_in_list+0x88>
            return 1;  // 成功释放 - Successfully freed
ffffffffc020084c:	4505                	li	a0,1
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
ffffffffc0200850:	6402                	ld	s0,0(sp)
ffffffffc0200852:	0141                	addi	sp,sp,16
ffffffffc0200854:	8082                	ret
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc0200856:	04e50a63          	beq	a0,a4,ffffffffc02008aa <free_in_list+0xd8>
ffffffffc020085a:	4858                	lw	a4,20(s0)
            if (sp->inuse == 0 && sp->capacity > 0) {
ffffffffc020085c:	2701                	sext.w	a4,a4
ffffffffc020085e:	d77d                	beqz	a4,ffffffffc020084c <free_in_list+0x7a>
                if (list_head == &cache->partial) {
ffffffffc0200860:	05a1                	addi	a1,a1,8
ffffffffc0200862:	04b50963          	beq	a0,a1,ffffffffc02008b4 <free_in_list+0xe2>
                free_page(sp->page);                    // 释放物理页面 - Free physical page
ffffffffc0200866:	6008                	ld	a0,0(s0)
ffffffffc0200868:	4585                	li	a1,1
ffffffffc020086a:	d73ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    sp->next = (slab_page_t *)(uintptr_t)sp_freelist_head;  // 链接到空闲链表 - Link to free list
ffffffffc020086e:	00007717          	auipc	a4,0x7
ffffffffc0200872:	7a270713          	addi	a4,a4,1954 # ffffffffc0208010 <sp_freelist_head>
ffffffffc0200876:	4314                	lw	a3,0(a4)
    int idx = (int)(sp - sp_pool);                  // 计算描述符在池中的索引 - Calculate descriptor index in pool
ffffffffc0200878:	00008797          	auipc	a5,0x8
ffffffffc020087c:	86878793          	addi	a5,a5,-1944 # ffffffffc02080e0 <sp_pool>
ffffffffc0200880:	40f407b3          	sub	a5,s0,a5
ffffffffc0200884:	8795                	srai	a5,a5,0x5
    sp->next = (slab_page_t *)(uintptr_t)sp_freelist_head;  // 链接到空闲链表 - Link to free list
ffffffffc0200886:	ec14                	sd	a3,24(s0)
    int idx = (int)(sp - sp_pool);                  // 计算描述符在池中的索引 - Calculate descriptor index in pool
ffffffffc0200888:	c31c                	sw	a5,0(a4)
            return 1;  // 成功释放 - Successfully freed
ffffffffc020088a:	4505                	li	a0,1
ffffffffc020088c:	b7c9                	j	ffffffffc020084e <free_in_list+0x7c>
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc020088e:	4858                	lw	a4,20(s0)
ffffffffc0200890:	fae7fde3          	bgeu	a5,a4,ffffffffc020084a <free_in_list+0x78>
                if (prev) prev->next = sp->next; 
ffffffffc0200894:	6c18                	ld	a4,24(s0)
ffffffffc0200896:	020e8563          	beqz	t4,ffffffffc02008c0 <free_in_list+0xee>
ffffffffc020089a:	00eebc23          	sd	a4,24(t4)
                sp->next = cache->partial;
ffffffffc020089e:	6598                	ld	a4,8(a1)
ffffffffc02008a0:	ec18                	sd	a4,24(s0)
                cache->partial = sp;
ffffffffc02008a2:	e580                	sd	s0,8(a1)
            if (sp->inuse == 0 && sp->capacity > 0) {
ffffffffc02008a4:	dfd5                	beqz	a5,ffffffffc0200860 <free_in_list+0x8e>
            return 1;  // 成功释放 - Successfully freed
ffffffffc02008a6:	4505                	li	a0,1
ffffffffc02008a8:	b75d                	j	ffffffffc020084e <free_in_list+0x7c>
            if (list_head == &cache->full && sp->inuse < sp->capacity) {
ffffffffc02008aa:	4858                	lw	a4,20(s0)
ffffffffc02008ac:	0007069b          	sext.w	a3,a4
ffffffffc02008b0:	f2f5                	bnez	a3,ffffffffc0200894 <free_in_list+0xc2>
ffffffffc02008b2:	b76d                	j	ffffffffc020085c <free_in_list+0x8a>
                    if (prev) prev->next = sp->next; 
ffffffffc02008b4:	6c1c                	ld	a5,24(s0)
ffffffffc02008b6:	000e8763          	beqz	t4,ffffffffc02008c4 <free_in_list+0xf2>
ffffffffc02008ba:	00febc23          	sd	a5,24(t4)
ffffffffc02008be:	b765                	j	ffffffffc0200866 <free_in_list+0x94>
                else *list_head = sp->next;
ffffffffc02008c0:	e118                	sd	a4,0(a0)
ffffffffc02008c2:	bff1                	j	ffffffffc020089e <free_in_list+0xcc>
                    else *list_head = sp->next;
ffffffffc02008c4:	e11c                	sd	a5,0(a0)
ffffffffc02008c6:	b745                	j	ffffffffc0200866 <free_in_list+0x94>

ffffffffc02008c8 <slub_init>:
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
ffffffffc02008c8:	0000a797          	auipc	a5,0xa
ffffffffc02008cc:	81078793          	addi	a5,a5,-2032 # ffffffffc020a0d8 <sp_pool+0x1ff8>
void slub_init(void) {
ffffffffc02008d0:	567d                	li	a2,-1
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
ffffffffc02008d2:	0ff00713          	li	a4,255
ffffffffc02008d6:	55fd                	li	a1,-1
ffffffffc02008d8:	a011                	j	ffffffffc02008dc <slub_init+0x14>
ffffffffc02008da:	8736                	mv	a4,a3
        sp_pool[i].next = (slab_page_t *)(uintptr_t)sp_freelist_head;
ffffffffc02008dc:	e390                	sd	a2,0(a5)
    for (int i = SLUB_SP_MAX - 1; i >= 0; i--) {
ffffffffc02008de:	fff7069b          	addiw	a3,a4,-1
ffffffffc02008e2:	863a                	mv	a2,a4
ffffffffc02008e4:	1781                	addi	a5,a5,-32
ffffffffc02008e6:	feb69ae3          	bne	a3,a1,ffffffffc02008da <slub_init+0x12>
ffffffffc02008ea:	00007797          	auipc	a5,0x7
ffffffffc02008ee:	7207a323          	sw	zero,1830(a5) # ffffffffc0208010 <sp_freelist_head>
ffffffffc02008f2:	00007797          	auipc	a5,0x7
ffffffffc02008f6:	72e78793          	addi	a5,a5,1838 # ffffffffc0208020 <caches>
ffffffffc02008fa:	00005717          	auipc	a4,0x5
ffffffffc02008fe:	afe70713          	addi	a4,a4,-1282 # ffffffffc02053f8 <class_sizes>
ffffffffc0200902:	00007617          	auipc	a2,0x7
ffffffffc0200906:	7de60613          	addi	a2,a2,2014 # ffffffffc02080e0 <sp_pool>
ffffffffc020090a:	46c1                	li	a3,16
ffffffffc020090c:	a011                	j	ffffffffc0200910 <slub_init+0x48>
        caches[i].object_size = class_sizes[i];     // 设置对象大小 - Set object size
ffffffffc020090e:	6314                	ld	a3,0(a4)
ffffffffc0200910:	e394                	sd	a3,0(a5)
        caches[i].partial = NULL;                   // 初始时无部分空闲页面 - Initially no partial pages
ffffffffc0200912:	0007b423          	sd	zero,8(a5)
        caches[i].full = NULL;                      // 初始时无全满页面 - Initially no full pages
ffffffffc0200916:	0007b823          	sd	zero,16(a5)
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc020091a:	07e1                	addi	a5,a5,24
ffffffffc020091c:	0721                	addi	a4,a4,8
ffffffffc020091e:	fec798e3          	bne	a5,a2,ffffffffc020090e <slub_init+0x46>
}
ffffffffc0200922:	8082                	ret

ffffffffc0200924 <kmalloc>:
void *kmalloc(size_t size) {
ffffffffc0200924:	711d                	addi	sp,sp,-96
ffffffffc0200926:	e0ca                	sd	s2,64(sp)
ffffffffc0200928:	f05a                	sd	s6,32(sp)
ffffffffc020092a:	ec86                	sd	ra,88(sp)
ffffffffc020092c:	e8a2                	sd	s0,80(sp)
ffffffffc020092e:	e4a6                	sd	s1,72(sp)
ffffffffc0200930:	fc4e                	sd	s3,56(sp)
ffffffffc0200932:	f852                	sd	s4,48(sp)
ffffffffc0200934:	f456                	sd	s5,40(sp)
ffffffffc0200936:	ec5e                	sd	s7,24(sp)
ffffffffc0200938:	e862                	sd	s8,16(sp)
ffffffffc020093a:	e466                	sd	s9,8(sp)
ffffffffc020093c:	e06a                	sd	s10,0(sp)
    size = size < sizeof(void*) ? sizeof(void*) : size;
ffffffffc020093e:	47a1                	li	a5,8
void *kmalloc(size_t size) {
ffffffffc0200940:	892a                	mv	s2,a0
    size = size < sizeof(void*) ? sizeof(void*) : size;
ffffffffc0200942:	4b21                	li	s6,8
ffffffffc0200944:	00f56363          	bltu	a0,a5,ffffffffc020094a <kmalloc+0x26>
ffffffffc0200948:	8b2a                	mv	s6,a0
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc020094a:	59f5                	li	s3,-3
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc020094c:	4ba1                	li	s7,8
    if (cache->partial == NULL) {
ffffffffc020094e:	00007c17          	auipc	s8,0x7
ffffffffc0200952:	6d2c0c13          	addi	s8,s8,1746 # ffffffffc0208020 <caches>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200956:	00009d17          	auipc	s10,0x9
ffffffffc020095a:	7c2d0d13          	addi	s10,s10,1986 # ffffffffc020a118 <pages>
ffffffffc020095e:	00005a17          	auipc	s4,0x5
ffffffffc0200962:	092a3a03          	ld	s4,146(s4) # ffffffffc02059f0 <nbase+0x8>
ffffffffc0200966:	00005c97          	auipc	s9,0x5
ffffffffc020096a:	082c8c93          	addi	s9,s9,130 # ffffffffc02059e8 <nbase>
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc020096e:	09fa                	slli	s3,s3,0x1e
void *kmalloc(size_t size) {
ffffffffc0200970:	4741                	li	a4,16
ffffffffc0200972:	00005797          	auipc	a5,0x5
ffffffffc0200976:	a8678793          	addi	a5,a5,-1402 # ffffffffc02053f8 <class_sizes>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc020097a:	4401                	li	s0,0
        if (class_sizes[i] >= size) return i;
ffffffffc020097c:	01677963          	bgeu	a4,s6,ffffffffc020098e <kmalloc+0x6a>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200980:	2405                	addiw	s0,s0,1
ffffffffc0200982:	07a1                	addi	a5,a5,8
ffffffffc0200984:	0f740863          	beq	s0,s7,ffffffffc0200a74 <kmalloc+0x150>
        if (class_sizes[i] >= size) return i;
ffffffffc0200988:	6398                	ld	a4,0(a5)
ffffffffc020098a:	ff676be3          	bltu	a4,s6,ffffffffc0200980 <kmalloc+0x5c>
    if (cache->partial == NULL) {
ffffffffc020098e:	00141493          	slli	s1,s0,0x1
ffffffffc0200992:	00848ab3          	add	s5,s1,s0
ffffffffc0200996:	0a8e                	slli	s5,s5,0x3
ffffffffc0200998:	9ae2                	add	s5,s5,s8
ffffffffc020099a:	008ab783          	ld	a5,8(s5)
ffffffffc020099e:	cf81                	beqz	a5,ffffffffc02009b6 <kmalloc+0x92>
    void *obj = sp->free_head;
ffffffffc02009a0:	6788                	ld	a0,8(a5)
    if (obj == NULL) {
ffffffffc02009a2:	e54d                	bnez	a0,ffffffffc0200a4c <kmalloc+0x128>
        cache->partial = sp->next;
ffffffffc02009a4:	9426                	add	s0,s0,s1
ffffffffc02009a6:	040e                	slli	s0,s0,0x3
ffffffffc02009a8:	6f94                	ld	a3,24(a5)
ffffffffc02009aa:	9462                	add	s0,s0,s8
        sp->next = cache->full;
ffffffffc02009ac:	6818                	ld	a4,16(s0)
        cache->partial = sp->next;
ffffffffc02009ae:	e414                	sd	a3,8(s0)
        sp->next = cache->full;
ffffffffc02009b0:	ef98                	sd	a4,24(a5)
        cache->full = sp;
ffffffffc02009b2:	e81c                	sd	a5,16(s0)
        return kmalloc(size);  // 递归重试 - Recursive retry
ffffffffc02009b4:	bf75                	j	ffffffffc0200970 <kmalloc+0x4c>
    struct Page *pg = alloc_page();
ffffffffc02009b6:	4505                	li	a0,1
ffffffffc02009b8:	c19ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc02009bc:	862a                	mv	a2,a0
    if (pg == NULL) return NULL;
ffffffffc02009be:	12050463          	beqz	a0,ffffffffc0200ae6 <kmalloc+0x1c2>
ffffffffc02009c2:	000d3783          	ld	a5,0(s10)
ffffffffc02009c6:	000cb683          	ld	a3,0(s9)
    size_t obj_size = cache->object_size;
ffffffffc02009ca:	000ab803          	ld	a6,0(s5)
ffffffffc02009ce:	40f507b3          	sub	a5,a0,a5
ffffffffc02009d2:	878d                	srai	a5,a5,0x3
ffffffffc02009d4:	034787b3          	mul	a5,a5,s4
    size_t objs = PGSIZE / obj_size;                // 计算页面可容纳的对象数 - Calculate objects per page
ffffffffc02009d8:	6705                	lui	a4,0x1
ffffffffc02009da:	97b6                	add	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02009dc:	07b2                	slli	a5,a5,0xc
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc02009de:	97ce                	add	a5,a5,s3
    size_t objs = PGSIZE / obj_size;                // 计算页面可容纳的对象数 - Calculate objects per page
ffffffffc02009e0:	030755b3          	divu	a1,a4,a6
    void *mem = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc02009e4:	88be                	mv	a7,a5
    if (objs == 0) {
ffffffffc02009e6:	11076263          	bltu	a4,a6,ffffffffc0200aea <kmalloc+0x1c6>
    void *head = NULL;
ffffffffc02009ea:	4701                	li	a4,0
    for (size_t i = 0; i < objs; i++) {
ffffffffc02009ec:	4681                	li	a3,0
        *slot = head;                               // 在对象开头存储下一个空闲对象指针 - Store next free object pointer at object start
ffffffffc02009ee:	e398                	sd	a4,0(a5)
    for (size_t i = 0; i < objs; i++) {
ffffffffc02009f0:	0685                	addi	a3,a3,1
        void **slot = (void **)((char *)mem + i * obj_size);    // 当前对象位置 - Current object location
ffffffffc02009f2:	873e                	mv	a4,a5
    for (size_t i = 0; i < objs; i++) {
ffffffffc02009f4:	97c2                	add	a5,a5,a6
ffffffffc02009f6:	feb6ece3          	bltu	a3,a1,ffffffffc02009ee <kmalloc+0xca>
ffffffffc02009fa:	6705                	lui	a4,0x1
ffffffffc02009fc:	4781                	li	a5,0
ffffffffc02009fe:	01076463          	bltu	a4,a6,ffffffffc0200a06 <kmalloc+0xe2>
ffffffffc0200a02:	fff58793          	addi	a5,a1,-1
    if (sp_freelist_head < 0) return NULL;          // 池已空 - Pool is empty
ffffffffc0200a06:	00007517          	auipc	a0,0x7
ffffffffc0200a0a:	60a50513          	addi	a0,a0,1546 # ffffffffc0208010 <sp_freelist_head>
ffffffffc0200a0e:	03078733          	mul	a4,a5,a6
ffffffffc0200a12:	411c                	lw	a5,0(a0)
ffffffffc0200a14:	98ba                	add	a7,a7,a4
ffffffffc0200a16:	0c07c463          	bltz	a5,ffffffffc0200ade <kmalloc+0x1ba>
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;  // 更新链表头 - Update list head
ffffffffc0200a1a:	00007697          	auipc	a3,0x7
ffffffffc0200a1e:	6c668693          	addi	a3,a3,1734 # ffffffffc02080e0 <sp_pool>
ffffffffc0200a22:	0796                	slli	a5,a5,0x5
ffffffffc0200a24:	97b6                	add	a5,a5,a3
    sp->next = cache->partial;                     // 插入到部分空闲链表 - Insert into partial list
ffffffffc0200a26:	00848733          	add	a4,s1,s0
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;  // 更新链表头 - Update list head
ffffffffc0200a2a:	0187b803          	ld	a6,24(a5)
    sp->next = cache->partial;                     // 插入到部分空闲链表 - Insert into partial list
ffffffffc0200a2e:	070e                	slli	a4,a4,0x3
ffffffffc0200a30:	9762                	add	a4,a4,s8
ffffffffc0200a32:	6714                	ld	a3,8(a4)
    sp->free_head = head;                          // 设置空闲链表头 - Set free list head
ffffffffc0200a34:	0117b423          	sd	a7,8(a5)
    sp_freelist_head = (int)(uintptr_t)sp_pool[idx].next;  // 更新链表头 - Update list head
ffffffffc0200a38:	01052023          	sw	a6,0(a0)
    void *obj = sp->free_head;
ffffffffc0200a3c:	6788                	ld	a0,8(a5)
    sp->page = pg;                                  // 关联物理页面 - Associate physical page
ffffffffc0200a3e:	e390                	sd	a2,0(a5)
    sp->inuse = 0;                                 // 初始时无对象被使用 - Initially no objects in use
ffffffffc0200a40:	0007a823          	sw	zero,16(a5)
    sp->capacity = (unsigned int)objs;             // 设置容量 - Set capacity
ffffffffc0200a44:	cbcc                	sw	a1,20(a5)
    sp->next = cache->partial;                     // 插入到部分空闲链表 - Insert into partial list
ffffffffc0200a46:	ef94                	sd	a3,24(a5)
    cache->partial = sp;
ffffffffc0200a48:	e71c                	sd	a5,8(a4)
    if (obj == NULL) {
ffffffffc0200a4a:	dd29                	beqz	a0,ffffffffc02009a4 <kmalloc+0x80>
    sp->inuse++;                                // 增加使用计数 - Increment usage count
ffffffffc0200a4c:	4b98                	lw	a4,16(a5)
    sp->free_head = *(void **)obj;              // 更新空闲链表头 - Update free list head
ffffffffc0200a4e:	6114                	ld	a3,0(a0)
    if (sp->inuse == sp->capacity) {
ffffffffc0200a50:	4bd0                	lw	a2,20(a5)
    sp->inuse++;                                // 增加使用计数 - Increment usage count
ffffffffc0200a52:	2705                	addiw	a4,a4,1
    sp->free_head = *(void **)obj;              // 更新空闲链表头 - Update free list head
ffffffffc0200a54:	e794                	sd	a3,8(a5)
    sp->inuse++;                                // 增加使用计数 - Increment usage count
ffffffffc0200a56:	cb98                	sw	a4,16(a5)
ffffffffc0200a58:	0007069b          	sext.w	a3,a4
    if (sp->inuse == sp->capacity) {
ffffffffc0200a5c:	06d61363          	bne	a2,a3,ffffffffc0200ac2 <kmalloc+0x19e>
        cache->partial = sp->next;
ffffffffc0200a60:	00848733          	add	a4,s1,s0
ffffffffc0200a64:	070e                	slli	a4,a4,0x3
ffffffffc0200a66:	6f90                	ld	a2,24(a5)
ffffffffc0200a68:	9762                	add	a4,a4,s8
        sp->next = cache->full;
ffffffffc0200a6a:	6b14                	ld	a3,16(a4)
        cache->partial = sp->next;
ffffffffc0200a6c:	e710                	sd	a2,8(a4)
        sp->next = cache->full;
ffffffffc0200a6e:	ef94                	sd	a3,24(a5)
        cache->full = sp;
ffffffffc0200a70:	eb1c                	sd	a5,16(a4)
ffffffffc0200a72:	a881                	j	ffffffffc0200ac2 <kmalloc+0x19e>
    return (x + a - 1) & ~(a - 1);
ffffffffc0200a74:	6405                	lui	s0,0x1
ffffffffc0200a76:	043d                	addi	s0,s0,15
ffffffffc0200a78:	944a                	add	s0,s0,s2
        size_t pages_need = bytes / PGSIZE;
ffffffffc0200a7a:	8031                	srli	s0,s0,0xc
        struct Page *pg = alloc_pages(pages_need);
ffffffffc0200a7c:	8522                	mv	a0,s0
ffffffffc0200a7e:	b53ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
        if (pg == NULL) return NULL;
ffffffffc0200a82:	c135                	beqz	a0,ffffffffc0200ae6 <kmalloc+0x1c2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a84:	00009797          	auipc	a5,0x9
ffffffffc0200a88:	6947b783          	ld	a5,1684(a5) # ffffffffc020a118 <pages>
ffffffffc0200a8c:	40f507b3          	sub	a5,a0,a5
ffffffffc0200a90:	00005717          	auipc	a4,0x5
ffffffffc0200a94:	f6073703          	ld	a4,-160(a4) # ffffffffc02059f0 <nbase+0x8>
ffffffffc0200a98:	878d                	srai	a5,a5,0x3
ffffffffc0200a9a:	02e787b3          	mul	a5,a5,a4
ffffffffc0200a9e:	00005717          	auipc	a4,0x5
ffffffffc0200aa2:	f4a73703          	ld	a4,-182(a4) # ffffffffc02059e8 <nbase>
ffffffffc0200aa6:	97ba                	add	a5,a5,a4
        void *kva = (void *)(page2pa(pg) + PHYSICAL_MEMORY_OFFSET);
ffffffffc0200aa8:	5775                	li	a4,-3
ffffffffc0200aaa:	077a                	slli	a4,a4,0x1e
    return page2ppn(page) << PGSHIFT;
ffffffffc0200aac:	07b2                	slli	a5,a5,0xc
ffffffffc0200aae:	97ba                	add	a5,a5,a4
        hdr->magic = LARGE_MAGIC;               // 设置魔数 - Set magic number
ffffffffc0200ab0:	4c524737          	lui	a4,0x4c524
ffffffffc0200ab4:	74c70713          	addi	a4,a4,1868 # 4c52474c <kern_entry-0xffffffff73cdb8b4>
        hdr->page = pg;                         // 记录起始页面 - Record starting page
ffffffffc0200ab8:	e788                	sd	a0,8(a5)
        hdr->magic = LARGE_MAGIC;               // 设置魔数 - Set magic number
ffffffffc0200aba:	c398                	sw	a4,0(a5)
        hdr->pages = (uint32_t)pages_need;      // 记录页面数 - Record page count
ffffffffc0200abc:	c3c0                	sw	s0,4(a5)
        return (void *)((char *)kva + sizeof(large_hdr_t));
ffffffffc0200abe:	01078513          	addi	a0,a5,16
}
ffffffffc0200ac2:	60e6                	ld	ra,88(sp)
ffffffffc0200ac4:	6446                	ld	s0,80(sp)
ffffffffc0200ac6:	64a6                	ld	s1,72(sp)
ffffffffc0200ac8:	6906                	ld	s2,64(sp)
ffffffffc0200aca:	79e2                	ld	s3,56(sp)
ffffffffc0200acc:	7a42                	ld	s4,48(sp)
ffffffffc0200ace:	7aa2                	ld	s5,40(sp)
ffffffffc0200ad0:	7b02                	ld	s6,32(sp)
ffffffffc0200ad2:	6be2                	ld	s7,24(sp)
ffffffffc0200ad4:	6c42                	ld	s8,16(sp)
ffffffffc0200ad6:	6ca2                	ld	s9,8(sp)
ffffffffc0200ad8:	6d02                	ld	s10,0(sp)
ffffffffc0200ada:	6125                	addi	sp,sp,96
ffffffffc0200adc:	8082                	ret
        free_page(pg);
ffffffffc0200ade:	4585                	li	a1,1
ffffffffc0200ae0:	8532                	mv	a0,a2
ffffffffc0200ae2:	afbff0ef          	jal	ra,ffffffffc02005dc <free_pages>
        if (new_slab_page(cache) == NULL) return NULL;
ffffffffc0200ae6:	4501                	li	a0,0
ffffffffc0200ae8:	bfe9                	j	ffffffffc0200ac2 <kmalloc+0x19e>
        free_page(pg);
ffffffffc0200aea:	4585                	li	a1,1
ffffffffc0200aec:	af1ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
        if (new_slab_page(cache) == NULL) return NULL;
ffffffffc0200af0:	4501                	li	a0,0
ffffffffc0200af2:	bfc1                	j	ffffffffc0200ac2 <kmalloc+0x19e>

ffffffffc0200af4 <kfree>:
 * - 如果不在SLAB中，尝试作为大对象释放
 * 
 * @param ptr 要释放的内存指针，允许为NULL
 */
void kfree(void *ptr) {
    if (ptr == NULL) return;  // 允许释放NULL指针 - Allow freeing NULL pointer
ffffffffc0200af4:	cd2d                	beqz	a0,ffffffffc0200b6e <kfree+0x7a>
void kfree(void *ptr) {
ffffffffc0200af6:	1101                	addi	sp,sp,-32
ffffffffc0200af8:	e822                	sd	s0,16(sp)
ffffffffc0200afa:	e426                	sd	s1,8(sp)
ffffffffc0200afc:	e04a                	sd	s2,0(sp)
ffffffffc0200afe:	ec06                	sd	ra,24(sp)
ffffffffc0200b00:	84aa                	mv	s1,a0
ffffffffc0200b02:	00007417          	auipc	s0,0x7
ffffffffc0200b06:	51e40413          	addi	s0,s0,1310 # ffffffffc0208020 <caches>
ffffffffc0200b0a:	00007917          	auipc	s2,0x7
ffffffffc0200b0e:	5d690913          	addi	s2,s2,1494 # ffffffffc02080e0 <sp_pool>
    
    // 尝试在所有SLAB缓存中释放 - Try to free in all SLAB caches
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
        // 先尝试部分空闲链表 - Try partial list first
        if (free_in_list(&caches[i].partial, &caches[i], ptr)) return;
ffffffffc0200b12:	85a2                	mv	a1,s0
ffffffffc0200b14:	8626                	mv	a2,s1
ffffffffc0200b16:	00840513          	addi	a0,s0,8
ffffffffc0200b1a:	cb9ff0ef          	jal	ra,ffffffffc02007d2 <free_in_list>
ffffffffc0200b1e:	87aa                	mv	a5,a0
        
        // 再尝试全满链表 - Then try full list
        if (free_in_list(&caches[i].full, &caches[i], ptr)) return;
ffffffffc0200b20:	85a2                	mv	a1,s0
ffffffffc0200b22:	01040513          	addi	a0,s0,16
ffffffffc0200b26:	8626                	mv	a2,s1
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200b28:	0461                	addi	s0,s0,24
        if (free_in_list(&caches[i].partial, &caches[i], ptr)) return;
ffffffffc0200b2a:	ef91                	bnez	a5,ffffffffc0200b46 <kfree+0x52>
        if (free_in_list(&caches[i].full, &caches[i], ptr)) return;
ffffffffc0200b2c:	ca7ff0ef          	jal	ra,ffffffffc02007d2 <free_in_list>
ffffffffc0200b30:	e919                	bnez	a0,ffffffffc0200b46 <kfree+0x52>
    for (int i = 0; i < SLUB_NUM_CLASSES; i++) {
ffffffffc0200b32:	fe8910e3          	bne	s2,s0,ffffffffc0200b12 <kfree+0x1e>
    
    // 如果不在SLAB中，尝试作为大对象释放 - If not in SLAB, try to free as large object
    large_hdr_t *hdr = (large_hdr_t *)((char *)ptr - sizeof(large_hdr_t));
    
    // 验证大对象头部的有效性 - Validate large object header
    if (hdr->magic == LARGE_MAGIC && hdr->page != NULL && hdr->pages > 0) {
ffffffffc0200b36:	ff04a703          	lw	a4,-16(s1)
ffffffffc0200b3a:	4c5247b7          	lui	a5,0x4c524
ffffffffc0200b3e:	74c78793          	addi	a5,a5,1868 # 4c52474c <kern_entry-0xffffffff73cdb8b4>
ffffffffc0200b42:	00f70863          	beq	a4,a5,ffffffffc0200b52 <kfree+0x5e>
        free_pages(hdr->page, hdr->pages);      // 释放页面 - Free pages
    }
    // 注意：如果既不是SLAB对象也不是有效的大对象，则可能是无效指针，此处选择静默忽略
    // Note: If neither SLAB object nor valid large object, might be invalid pointer, silently ignore here
}
ffffffffc0200b46:	60e2                	ld	ra,24(sp)
ffffffffc0200b48:	6442                	ld	s0,16(sp)
ffffffffc0200b4a:	64a2                	ld	s1,8(sp)
ffffffffc0200b4c:	6902                	ld	s2,0(sp)
ffffffffc0200b4e:	6105                	addi	sp,sp,32
ffffffffc0200b50:	8082                	ret
    if (hdr->magic == LARGE_MAGIC && hdr->page != NULL && hdr->pages > 0) {
ffffffffc0200b52:	ff84b503          	ld	a0,-8(s1)
ffffffffc0200b56:	d965                	beqz	a0,ffffffffc0200b46 <kfree+0x52>
ffffffffc0200b58:	ff44a583          	lw	a1,-12(s1)
ffffffffc0200b5c:	d5ed                	beqz	a1,ffffffffc0200b46 <kfree+0x52>
}
ffffffffc0200b5e:	6442                	ld	s0,16(sp)
ffffffffc0200b60:	60e2                	ld	ra,24(sp)
ffffffffc0200b62:	64a2                	ld	s1,8(sp)
ffffffffc0200b64:	6902                	ld	s2,0(sp)
        free_pages(hdr->page, hdr->pages);      // 释放页面 - Free pages
ffffffffc0200b66:	1582                	slli	a1,a1,0x20
ffffffffc0200b68:	9181                	srli	a1,a1,0x20
}
ffffffffc0200b6a:	6105                	addi	sp,sp,32
        free_pages(hdr->page, hdr->pages);      // 释放页面 - Free pages
ffffffffc0200b6c:	bc85                	j	ffffffffc02005dc <free_pages>
ffffffffc0200b6e:	8082                	ret

ffffffffc0200b70 <slub_check>:
 * @brief SLUB分配器自检 - SLUB allocator self-check
 * 
 * 执行基本的分配和释放测试，验证SLUB分配器的正确性。
 * 测试包括不同大小的对象分配和释放。
 */
void slub_check(void) {
ffffffffc0200b70:	1101                	addi	sp,sp,-32
    // 测试不同大小的分配 - Test allocation of different sizes
    void *a = kmalloc(24);      // 小对象，应使用32字节类别 - Small object, should use 32-byte class
ffffffffc0200b72:	4561                	li	a0,24
void slub_check(void) {
ffffffffc0200b74:	ec06                	sd	ra,24(sp)
ffffffffc0200b76:	e822                	sd	s0,16(sp)
ffffffffc0200b78:	e04a                	sd	s2,0(sp)
ffffffffc0200b7a:	e426                	sd	s1,8(sp)
    void *a = kmalloc(24);      // 小对象，应使用32字节类别 - Small object, should use 32-byte class
ffffffffc0200b7c:	da9ff0ef          	jal	ra,ffffffffc0200924 <kmalloc>
ffffffffc0200b80:	842a                	mv	s0,a0
    void *b = kmalloc(200);     // 中等对象，应使用256字节类别 - Medium object, should use 256-byte class
ffffffffc0200b82:	0c800513          	li	a0,200
ffffffffc0200b86:	d9fff0ef          	jal	ra,ffffffffc0200924 <kmalloc>
ffffffffc0200b8a:	892a                	mv	s2,a0
    void *c = kmalloc(1024);    // 大对象，应使用1024字节类别 - Large object, should use 1024-byte class
ffffffffc0200b8c:	40000513          	li	a0,1024
ffffffffc0200b90:	d95ff0ef          	jal	ra,ffffffffc0200924 <kmalloc>
    
    // 验证分配成功 - Verify allocation success
    assert(a != NULL && b != NULL && c != NULL);
ffffffffc0200b94:	c015                	beqz	s0,ffffffffc0200bb8 <slub_check+0x48>
ffffffffc0200b96:	02090163          	beqz	s2,ffffffffc0200bb8 <slub_check+0x48>
ffffffffc0200b9a:	84aa                	mv	s1,a0
ffffffffc0200b9c:	cd11                	beqz	a0,ffffffffc0200bb8 <slub_check+0x48>
    
    // 测试释放 - Test freeing
    kfree(a);
ffffffffc0200b9e:	8522                	mv	a0,s0
ffffffffc0200ba0:	f55ff0ef          	jal	ra,ffffffffc0200af4 <kfree>
    kfree(b); 
ffffffffc0200ba4:	854a                	mv	a0,s2
ffffffffc0200ba6:	f4fff0ef          	jal	ra,ffffffffc0200af4 <kfree>
    kfree(c);
    
    // 注意：这是一个基础测试，实际使用中可能需要更全面的测试
    // Note: This is a basic test, actual usage might need more comprehensive testing
}
ffffffffc0200baa:	6442                	ld	s0,16(sp)
ffffffffc0200bac:	60e2                	ld	ra,24(sp)
ffffffffc0200bae:	6902                	ld	s2,0(sp)
    kfree(c);
ffffffffc0200bb0:	8526                	mv	a0,s1
}
ffffffffc0200bb2:	64a2                	ld	s1,8(sp)
ffffffffc0200bb4:	6105                	addi	sp,sp,32
    kfree(c);
ffffffffc0200bb6:	bf3d                	j	ffffffffc0200af4 <kfree>
    assert(a != NULL && b != NULL && c != NULL);
ffffffffc0200bb8:	00004697          	auipc	a3,0x4
ffffffffc0200bbc:	7f068693          	addi	a3,a3,2032 # ffffffffc02053a8 <boot_page_table_sv39+0x13a8>
ffffffffc0200bc0:	00005617          	auipc	a2,0x5
ffffffffc0200bc4:	81060613          	addi	a2,a2,-2032 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200bc8:	18c00593          	li	a1,396
ffffffffc0200bcc:	00005517          	auipc	a0,0x5
ffffffffc0200bd0:	81c50513          	addi	a0,a0,-2020 # ffffffffc02053e8 <boot_page_table_sv39+0x13e8>
ffffffffc0200bd4:	deeff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200bd8 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200bd8:	00009797          	auipc	a5,0x9
ffffffffc0200bdc:	50878793          	addi	a5,a5,1288 # ffffffffc020a0e0 <free_area>
ffffffffc0200be0:	e79c                	sd	a5,8(a5)
ffffffffc0200be2:	e39c                	sd	a5,0(a5)
 * Initialize the free list and reset free page counter to zero.
 */
static void
best_fit_init(void) {
    list_init(&free_list);              // 初始化空闲链表 - Initialize free list
    nr_free = 0;                        // 清零空闲页数 - Reset free page count
ffffffffc0200be4:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200be8:	8082                	ret

ffffffffc0200bea <best_fit_nr_free_pages>:
 * @return 当前空闲页面的总数
 */
static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200bea:	00009517          	auipc	a0,0x9
ffffffffc0200bee:	50656503          	lwu	a0,1286(a0) # ffffffffc020a0f0 <free_area+0x10>
ffffffffc0200bf2:	8082                	ret

ffffffffc0200bf4 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200bf4:	cd49                	beqz	a0,ffffffffc0200c8e <best_fit_alloc_pages+0x9a>
    if (n > nr_free) {
ffffffffc0200bf6:	00009617          	auipc	a2,0x9
ffffffffc0200bfa:	4ea60613          	addi	a2,a2,1258 # ffffffffc020a0e0 <free_area>
ffffffffc0200bfe:	01062803          	lw	a6,16(a2)
ffffffffc0200c02:	86aa                	mv	a3,a0
ffffffffc0200c04:	02081793          	slli	a5,a6,0x20
ffffffffc0200c08:	9381                	srli	a5,a5,0x20
ffffffffc0200c0a:	08a7e063          	bltu	a5,a0,ffffffffc0200c8a <best_fit_alloc_pages+0x96>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200c0e:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;      // 初始化为不可能的大小 - Initialize to impossible size
ffffffffc0200c10:	0018059b          	addiw	a1,a6,1
ffffffffc0200c14:	1582                	slli	a1,a1,0x20
ffffffffc0200c16:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;           // 最佳匹配的页面 - Best matched page
ffffffffc0200c18:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c1a:	06c78763          	beq	a5,a2,ffffffffc0200c88 <best_fit_alloc_pages+0x94>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200c1e:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200c22:	00d76763          	bltu	a4,a3,ffffffffc0200c30 <best_fit_alloc_pages+0x3c>
ffffffffc0200c26:	00b77563          	bgeu	a4,a1,ffffffffc0200c30 <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200c2a:	fe878513          	addi	a0,a5,-24
ffffffffc0200c2e:	85ba                	mv	a1,a4
ffffffffc0200c30:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c32:	fec796e3          	bne	a5,a2,ffffffffc0200c1e <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200c36:	c929                	beqz	a0,ffffffffc0200c88 <best_fit_alloc_pages+0x94>
        if (page->property > n) {
ffffffffc0200c38:	01052883          	lw	a7,16(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200c3c:	6d18                	ld	a4,24(a0)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c3e:	710c                	ld	a1,32(a0)
ffffffffc0200c40:	02089793          	slli	a5,a7,0x20
ffffffffc0200c44:	9381                	srli	a5,a5,0x20
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c46:	e70c                	sd	a1,8(a4)
    next->prev = prev;
ffffffffc0200c48:	e198                	sd	a4,0(a1)
            p->property = page->property - n;   // 设置剩余部分的大小 - Set size of remaining part
ffffffffc0200c4a:	0006831b          	sext.w	t1,a3
        if (page->property > n) {
ffffffffc0200c4e:	02f6f563          	bgeu	a3,a5,ffffffffc0200c78 <best_fit_alloc_pages+0x84>
            struct Page *p = page + n;          // 剩余部分的起始页面 - Start of remaining part
ffffffffc0200c52:	00269793          	slli	a5,a3,0x2
ffffffffc0200c56:	97b6                	add	a5,a5,a3
ffffffffc0200c58:	078e                	slli	a5,a5,0x3
ffffffffc0200c5a:	97aa                	add	a5,a5,a0
            SetPageProperty(p);                 // 设置剩余部分为空闲块头 - Mark remaining part as free block head
ffffffffc0200c5c:	6794                	ld	a3,8(a5)
            p->property = page->property - n;   // 设置剩余部分的大小 - Set size of remaining part
ffffffffc0200c5e:	406888bb          	subw	a7,a7,t1
ffffffffc0200c62:	0117a823          	sw	a7,16(a5)
            SetPageProperty(p);                 // 设置剩余部分为空闲块头 - Mark remaining part as free block head
ffffffffc0200c66:	0026e693          	ori	a3,a3,2
ffffffffc0200c6a:	e794                	sd	a3,8(a5)
            list_add(prev, &(p->page_link));    // 将剩余部分插入空闲链表 - Insert remaining part into free list
ffffffffc0200c6c:	01878693          	addi	a3,a5,24
    prev->next = next->prev = elm;
ffffffffc0200c70:	e194                	sd	a3,0(a1)
ffffffffc0200c72:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc0200c74:	f38c                	sd	a1,32(a5)
    elm->prev = prev;
ffffffffc0200c76:	ef98                	sd	a4,24(a5)
        ClearPageProperty(page);                // 清除分配页面的属性标志 - Clear property flag of allocated pages
ffffffffc0200c78:	651c                	ld	a5,8(a0)
        nr_free -= n;                           // 减少空闲页计数 - Decrease free page count
ffffffffc0200c7a:	4068083b          	subw	a6,a6,t1
ffffffffc0200c7e:	01062823          	sw	a6,16(a2)
        ClearPageProperty(page);                // 清除分配页面的属性标志 - Clear property flag of allocated pages
ffffffffc0200c82:	9bf5                	andi	a5,a5,-3
ffffffffc0200c84:	e51c                	sd	a5,8(a0)
ffffffffc0200c86:	8082                	ret
}
ffffffffc0200c88:	8082                	ret
        return NULL;
ffffffffc0200c8a:	4501                	li	a0,0
ffffffffc0200c8c:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200c8e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c90:	00004697          	auipc	a3,0x4
ffffffffc0200c94:	7a868693          	addi	a3,a3,1960 # ffffffffc0205438 <class_sizes+0x40>
ffffffffc0200c98:	00004617          	auipc	a2,0x4
ffffffffc0200c9c:	73860613          	addi	a2,a2,1848 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200ca0:	08300593          	li	a1,131
ffffffffc0200ca4:	00004517          	auipc	a0,0x4
ffffffffc0200ca8:	79c50513          	addi	a0,a0,1948 # ffffffffc0205440 <class_sizes+0x48>
best_fit_alloc_pages(size_t n) {
ffffffffc0200cac:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cae:	d14ff0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc0200cb2 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200cb2:	715d                	addi	sp,sp,-80
ffffffffc0200cb4:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200cb6:	00009417          	auipc	s0,0x9
ffffffffc0200cba:	42a40413          	addi	s0,s0,1066 # ffffffffc020a0e0 <free_area>
ffffffffc0200cbe:	641c                	ld	a5,8(s0)
ffffffffc0200cc0:	e486                	sd	ra,72(sp)
ffffffffc0200cc2:	fc26                	sd	s1,56(sp)
ffffffffc0200cc4:	f84a                	sd	s2,48(sp)
ffffffffc0200cc6:	f44e                	sd	s3,40(sp)
ffffffffc0200cc8:	f052                	sd	s4,32(sp)
ffffffffc0200cca:	ec56                	sd	s5,24(sp)
ffffffffc0200ccc:	e85a                	sd	s6,16(sp)
ffffffffc0200cce:	e45e                	sd	s7,8(sp)
ffffffffc0200cd0:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cd2:	26878963          	beq	a5,s0,ffffffffc0200f44 <best_fit_check+0x292>
    int count = 0, total = 0;
ffffffffc0200cd6:	4481                	li	s1,0
ffffffffc0200cd8:	4901                	li	s2,0
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200cda:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200cde:	8b09                	andi	a4,a4,2
ffffffffc0200ce0:	26070663          	beqz	a4,ffffffffc0200f4c <best_fit_check+0x29a>
        count ++, total += p->property;
ffffffffc0200ce4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ce8:	679c                	ld	a5,8(a5)
ffffffffc0200cea:	2905                	addiw	s2,s2,1
ffffffffc0200cec:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cee:	fe8796e3          	bne	a5,s0,ffffffffc0200cda <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200cf2:	89a6                	mv	s3,s1
ffffffffc0200cf4:	8f5ff0ef          	jal	ra,ffffffffc02005e8 <nr_free_pages>
ffffffffc0200cf8:	33351a63          	bne	a0,s3,ffffffffc020102c <best_fit_check+0x37a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cfc:	4505                	li	a0,1
ffffffffc0200cfe:	8d3ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200d02:	8a2a                	mv	s4,a0
ffffffffc0200d04:	36050463          	beqz	a0,ffffffffc020106c <best_fit_check+0x3ba>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d08:	4505                	li	a0,1
ffffffffc0200d0a:	8c7ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200d0e:	89aa                	mv	s3,a0
ffffffffc0200d10:	32050e63          	beqz	a0,ffffffffc020104c <best_fit_check+0x39a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d14:	4505                	li	a0,1
ffffffffc0200d16:	8bbff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200d1a:	8aaa                	mv	s5,a0
ffffffffc0200d1c:	2c050863          	beqz	a0,ffffffffc0200fec <best_fit_check+0x33a>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d20:	253a0663          	beq	s4,s3,ffffffffc0200f6c <best_fit_check+0x2ba>
ffffffffc0200d24:	24aa0463          	beq	s4,a0,ffffffffc0200f6c <best_fit_check+0x2ba>
ffffffffc0200d28:	24a98263          	beq	s3,a0,ffffffffc0200f6c <best_fit_check+0x2ba>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d2c:	000a2783          	lw	a5,0(s4)
ffffffffc0200d30:	24079e63          	bnez	a5,ffffffffc0200f8c <best_fit_check+0x2da>
ffffffffc0200d34:	0009a783          	lw	a5,0(s3)
ffffffffc0200d38:	24079a63          	bnez	a5,ffffffffc0200f8c <best_fit_check+0x2da>
ffffffffc0200d3c:	411c                	lw	a5,0(a0)
ffffffffc0200d3e:	24079763          	bnez	a5,ffffffffc0200f8c <best_fit_check+0x2da>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d42:	00009797          	auipc	a5,0x9
ffffffffc0200d46:	3d67b783          	ld	a5,982(a5) # ffffffffc020a118 <pages>
ffffffffc0200d4a:	40fa0733          	sub	a4,s4,a5
ffffffffc0200d4e:	870d                	srai	a4,a4,0x3
ffffffffc0200d50:	00005597          	auipc	a1,0x5
ffffffffc0200d54:	ca05b583          	ld	a1,-864(a1) # ffffffffc02059f0 <nbase+0x8>
ffffffffc0200d58:	02b70733          	mul	a4,a4,a1
ffffffffc0200d5c:	00005617          	auipc	a2,0x5
ffffffffc0200d60:	c8c63603          	ld	a2,-884(a2) # ffffffffc02059e8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200d64:	00009697          	auipc	a3,0x9
ffffffffc0200d68:	3ac6b683          	ld	a3,940(a3) # ffffffffc020a110 <npage>
ffffffffc0200d6c:	06b2                	slli	a3,a3,0xc
ffffffffc0200d6e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d70:	0732                	slli	a4,a4,0xc
ffffffffc0200d72:	22d77d63          	bgeu	a4,a3,ffffffffc0200fac <best_fit_check+0x2fa>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d76:	40f98733          	sub	a4,s3,a5
ffffffffc0200d7a:	870d                	srai	a4,a4,0x3
ffffffffc0200d7c:	02b70733          	mul	a4,a4,a1
ffffffffc0200d80:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d82:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200d84:	3ed77463          	bgeu	a4,a3,ffffffffc020116c <best_fit_check+0x4ba>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d88:	40f507b3          	sub	a5,a0,a5
ffffffffc0200d8c:	878d                	srai	a5,a5,0x3
ffffffffc0200d8e:	02b787b3          	mul	a5,a5,a1
ffffffffc0200d92:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d94:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200d96:	3ad7fb63          	bgeu	a5,a3,ffffffffc020114c <best_fit_check+0x49a>
    assert(alloc_page() == NULL);
ffffffffc0200d9a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d9c:	00043c03          	ld	s8,0(s0)
ffffffffc0200da0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200da4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200da8:	e400                	sd	s0,8(s0)
ffffffffc0200daa:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200dac:	00009797          	auipc	a5,0x9
ffffffffc0200db0:	3407a223          	sw	zero,836(a5) # ffffffffc020a0f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200db4:	81dff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200db8:	36051a63          	bnez	a0,ffffffffc020112c <best_fit_check+0x47a>
    free_page(p0);
ffffffffc0200dbc:	4585                	li	a1,1
ffffffffc0200dbe:	8552                	mv	a0,s4
ffffffffc0200dc0:	81dff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200dc4:	4585                	li	a1,1
ffffffffc0200dc6:	854e                	mv	a0,s3
ffffffffc0200dc8:	815ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200dcc:	4585                	li	a1,1
ffffffffc0200dce:	8556                	mv	a0,s5
ffffffffc0200dd0:	80dff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(nr_free == 3);
ffffffffc0200dd4:	4818                	lw	a4,16(s0)
ffffffffc0200dd6:	478d                	li	a5,3
ffffffffc0200dd8:	32f71a63          	bne	a4,a5,ffffffffc020110c <best_fit_check+0x45a>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ddc:	4505                	li	a0,1
ffffffffc0200dde:	ff2ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200de2:	89aa                	mv	s3,a0
ffffffffc0200de4:	30050463          	beqz	a0,ffffffffc02010ec <best_fit_check+0x43a>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200de8:	4505                	li	a0,1
ffffffffc0200dea:	fe6ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200dee:	8aaa                	mv	s5,a0
ffffffffc0200df0:	2c050e63          	beqz	a0,ffffffffc02010cc <best_fit_check+0x41a>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200df4:	4505                	li	a0,1
ffffffffc0200df6:	fdaff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200dfa:	8a2a                	mv	s4,a0
ffffffffc0200dfc:	2a050863          	beqz	a0,ffffffffc02010ac <best_fit_check+0x3fa>
    assert(alloc_page() == NULL);
ffffffffc0200e00:	4505                	li	a0,1
ffffffffc0200e02:	fceff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e06:	28051363          	bnez	a0,ffffffffc020108c <best_fit_check+0x3da>
    free_page(p0);
ffffffffc0200e0a:	4585                	li	a1,1
ffffffffc0200e0c:	854e                	mv	a0,s3
ffffffffc0200e0e:	fceff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200e12:	641c                	ld	a5,8(s0)
ffffffffc0200e14:	1a878c63          	beq	a5,s0,ffffffffc0200fcc <best_fit_check+0x31a>
    assert((p = alloc_page()) == p0);
ffffffffc0200e18:	4505                	li	a0,1
ffffffffc0200e1a:	fb6ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e1e:	52a99763          	bne	s3,a0,ffffffffc020134c <best_fit_check+0x69a>
    assert(alloc_page() == NULL);
ffffffffc0200e22:	4505                	li	a0,1
ffffffffc0200e24:	facff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e28:	50051263          	bnez	a0,ffffffffc020132c <best_fit_check+0x67a>
    assert(nr_free == 0);
ffffffffc0200e2c:	481c                	lw	a5,16(s0)
ffffffffc0200e2e:	4c079f63          	bnez	a5,ffffffffc020130c <best_fit_check+0x65a>
    free_page(p);
ffffffffc0200e32:	854e                	mv	a0,s3
ffffffffc0200e34:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200e36:	01843023          	sd	s8,0(s0)
ffffffffc0200e3a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200e3e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200e42:	f9aff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p1);
ffffffffc0200e46:	4585                	li	a1,1
ffffffffc0200e48:	8556                	mv	a0,s5
ffffffffc0200e4a:	f92ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_page(p2);
ffffffffc0200e4e:	4585                	li	a1,1
ffffffffc0200e50:	8552                	mv	a0,s4
ffffffffc0200e52:	f8aff0ef          	jal	ra,ffffffffc02005dc <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200e56:	4515                	li	a0,5
ffffffffc0200e58:	f78ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e5c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200e5e:	48050763          	beqz	a0,ffffffffc02012ec <best_fit_check+0x63a>
    assert(!PageProperty(p0));
ffffffffc0200e62:	651c                	ld	a5,8(a0)
ffffffffc0200e64:	8b89                	andi	a5,a5,2
ffffffffc0200e66:	46079363          	bnez	a5,ffffffffc02012cc <best_fit_check+0x61a>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200e6a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200e6c:	00043b03          	ld	s6,0(s0)
ffffffffc0200e70:	00843a83          	ld	s5,8(s0)
ffffffffc0200e74:	e000                	sd	s0,0(s0)
ffffffffc0200e76:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200e78:	f58ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200e7c:	42051863          	bnez	a0,ffffffffc02012ac <best_fit_check+0x5fa>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200e80:	4589                	li	a1,2
ffffffffc0200e82:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200e86:	01042b83          	lw	s7,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200e8a:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200e8e:	00009797          	auipc	a5,0x9
ffffffffc0200e92:	2607a123          	sw	zero,610(a5) # ffffffffc020a0f0 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200e96:	f46ff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200e9a:	8562                	mv	a0,s8
ffffffffc0200e9c:	4585                	li	a1,1
ffffffffc0200e9e:	f3eff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ea2:	4511                	li	a0,4
ffffffffc0200ea4:	f2cff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ea8:	3e051263          	bnez	a0,ffffffffc020128c <best_fit_check+0x5da>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200eac:	0309b783          	ld	a5,48(s3)
ffffffffc0200eb0:	8b89                	andi	a5,a5,2
ffffffffc0200eb2:	3a078d63          	beqz	a5,ffffffffc020126c <best_fit_check+0x5ba>
ffffffffc0200eb6:	0389a703          	lw	a4,56(s3)
ffffffffc0200eba:	4789                	li	a5,2
ffffffffc0200ebc:	3af71863          	bne	a4,a5,ffffffffc020126c <best_fit_check+0x5ba>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200ec0:	4505                	li	a0,1
ffffffffc0200ec2:	f0eff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ec6:	8a2a                	mv	s4,a0
ffffffffc0200ec8:	38050263          	beqz	a0,ffffffffc020124c <best_fit_check+0x59a>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ecc:	4509                	li	a0,2
ffffffffc0200ece:	f02ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ed2:	34050d63          	beqz	a0,ffffffffc020122c <best_fit_check+0x57a>
    assert(p0 + 4 == p1);
ffffffffc0200ed6:	334c1b63          	bne	s8,s4,ffffffffc020120c <best_fit_check+0x55a>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200eda:	854e                	mv	a0,s3
ffffffffc0200edc:	4595                	li	a1,5
ffffffffc0200ede:	efeff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200ee2:	4515                	li	a0,5
ffffffffc0200ee4:	eecff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ee8:	89aa                	mv	s3,a0
ffffffffc0200eea:	30050163          	beqz	a0,ffffffffc02011ec <best_fit_check+0x53a>
    assert(alloc_page() == NULL);
ffffffffc0200eee:	4505                	li	a0,1
ffffffffc0200ef0:	ee0ff0ef          	jal	ra,ffffffffc02005d0 <alloc_pages>
ffffffffc0200ef4:	2c051c63          	bnez	a0,ffffffffc02011cc <best_fit_check+0x51a>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200ef8:	481c                	lw	a5,16(s0)
ffffffffc0200efa:	2a079963          	bnez	a5,ffffffffc02011ac <best_fit_check+0x4fa>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200efe:	4595                	li	a1,5
ffffffffc0200f00:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200f02:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200f06:	01643023          	sd	s6,0(s0)
ffffffffc0200f0a:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200f0e:	eceff0ef          	jal	ra,ffffffffc02005dc <free_pages>
    return listelm->next;
ffffffffc0200f12:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f14:	00878963          	beq	a5,s0,ffffffffc0200f26 <best_fit_check+0x274>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200f18:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f1c:	679c                	ld	a5,8(a5)
ffffffffc0200f1e:	397d                	addiw	s2,s2,-1
ffffffffc0200f20:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f22:	fe879be3          	bne	a5,s0,ffffffffc0200f18 <best_fit_check+0x266>
    }
    assert(count == 0);
ffffffffc0200f26:	26091363          	bnez	s2,ffffffffc020118c <best_fit_check+0x4da>
    assert(total == 0);
ffffffffc0200f2a:	e0ed                	bnez	s1,ffffffffc020100c <best_fit_check+0x35a>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200f2c:	60a6                	ld	ra,72(sp)
ffffffffc0200f2e:	6406                	ld	s0,64(sp)
ffffffffc0200f30:	74e2                	ld	s1,56(sp)
ffffffffc0200f32:	7942                	ld	s2,48(sp)
ffffffffc0200f34:	79a2                	ld	s3,40(sp)
ffffffffc0200f36:	7a02                	ld	s4,32(sp)
ffffffffc0200f38:	6ae2                	ld	s5,24(sp)
ffffffffc0200f3a:	6b42                	ld	s6,16(sp)
ffffffffc0200f3c:	6ba2                	ld	s7,8(sp)
ffffffffc0200f3e:	6c02                	ld	s8,0(sp)
ffffffffc0200f40:	6161                	addi	sp,sp,80
ffffffffc0200f42:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200f44:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200f46:	4481                	li	s1,0
ffffffffc0200f48:	4901                	li	s2,0
ffffffffc0200f4a:	b36d                	j	ffffffffc0200cf4 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200f4c:	00004697          	auipc	a3,0x4
ffffffffc0200f50:	50c68693          	addi	a3,a3,1292 # ffffffffc0205458 <class_sizes+0x60>
ffffffffc0200f54:	00004617          	auipc	a2,0x4
ffffffffc0200f58:	47c60613          	addi	a2,a2,1148 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200f5c:	13900593          	li	a1,313
ffffffffc0200f60:	00004517          	auipc	a0,0x4
ffffffffc0200f64:	4e050513          	addi	a0,a0,1248 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0200f68:	a5aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f6c:	00004697          	auipc	a3,0x4
ffffffffc0200f70:	57c68693          	addi	a3,a3,1404 # ffffffffc02054e8 <class_sizes+0xf0>
ffffffffc0200f74:	00004617          	auipc	a2,0x4
ffffffffc0200f78:	45c60613          	addi	a2,a2,1116 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200f7c:	10500593          	li	a1,261
ffffffffc0200f80:	00004517          	auipc	a0,0x4
ffffffffc0200f84:	4c050513          	addi	a0,a0,1216 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0200f88:	a3aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f8c:	00004697          	auipc	a3,0x4
ffffffffc0200f90:	58468693          	addi	a3,a3,1412 # ffffffffc0205510 <class_sizes+0x118>
ffffffffc0200f94:	00004617          	auipc	a2,0x4
ffffffffc0200f98:	43c60613          	addi	a2,a2,1084 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200f9c:	10600593          	li	a1,262
ffffffffc0200fa0:	00004517          	auipc	a0,0x4
ffffffffc0200fa4:	4a050513          	addi	a0,a0,1184 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0200fa8:	a1aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fac:	00004697          	auipc	a3,0x4
ffffffffc0200fb0:	5a468693          	addi	a3,a3,1444 # ffffffffc0205550 <class_sizes+0x158>
ffffffffc0200fb4:	00004617          	auipc	a2,0x4
ffffffffc0200fb8:	41c60613          	addi	a2,a2,1052 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200fbc:	10800593          	li	a1,264
ffffffffc0200fc0:	00004517          	auipc	a0,0x4
ffffffffc0200fc4:	48050513          	addi	a0,a0,1152 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0200fc8:	9faff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200fcc:	00004697          	auipc	a3,0x4
ffffffffc0200fd0:	60c68693          	addi	a3,a3,1548 # ffffffffc02055d8 <class_sizes+0x1e0>
ffffffffc0200fd4:	00004617          	auipc	a2,0x4
ffffffffc0200fd8:	3fc60613          	addi	a2,a2,1020 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200fdc:	12100593          	li	a1,289
ffffffffc0200fe0:	00004517          	auipc	a0,0x4
ffffffffc0200fe4:	46050513          	addi	a0,a0,1120 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0200fe8:	9daff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fec:	00004697          	auipc	a3,0x4
ffffffffc0200ff0:	4dc68693          	addi	a3,a3,1244 # ffffffffc02054c8 <class_sizes+0xd0>
ffffffffc0200ff4:	00004617          	auipc	a2,0x4
ffffffffc0200ff8:	3dc60613          	addi	a2,a2,988 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc0200ffc:	10300593          	li	a1,259
ffffffffc0201000:	00004517          	auipc	a0,0x4
ffffffffc0201004:	44050513          	addi	a0,a0,1088 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201008:	9baff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total == 0);
ffffffffc020100c:	00004697          	auipc	a3,0x4
ffffffffc0201010:	6fc68693          	addi	a3,a3,1788 # ffffffffc0205708 <class_sizes+0x310>
ffffffffc0201014:	00004617          	auipc	a2,0x4
ffffffffc0201018:	3bc60613          	addi	a2,a2,956 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020101c:	17b00593          	li	a1,379
ffffffffc0201020:	00004517          	auipc	a0,0x4
ffffffffc0201024:	42050513          	addi	a0,a0,1056 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201028:	99aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(total == nr_free_pages());
ffffffffc020102c:	00004697          	auipc	a3,0x4
ffffffffc0201030:	43c68693          	addi	a3,a3,1084 # ffffffffc0205468 <class_sizes+0x70>
ffffffffc0201034:	00004617          	auipc	a2,0x4
ffffffffc0201038:	39c60613          	addi	a2,a2,924 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020103c:	13c00593          	li	a1,316
ffffffffc0201040:	00004517          	auipc	a0,0x4
ffffffffc0201044:	40050513          	addi	a0,a0,1024 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201048:	97aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020104c:	00004697          	auipc	a3,0x4
ffffffffc0201050:	45c68693          	addi	a3,a3,1116 # ffffffffc02054a8 <class_sizes+0xb0>
ffffffffc0201054:	00004617          	auipc	a2,0x4
ffffffffc0201058:	37c60613          	addi	a2,a2,892 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020105c:	10200593          	li	a1,258
ffffffffc0201060:	00004517          	auipc	a0,0x4
ffffffffc0201064:	3e050513          	addi	a0,a0,992 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201068:	95aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020106c:	00004697          	auipc	a3,0x4
ffffffffc0201070:	41c68693          	addi	a3,a3,1052 # ffffffffc0205488 <class_sizes+0x90>
ffffffffc0201074:	00004617          	auipc	a2,0x4
ffffffffc0201078:	35c60613          	addi	a2,a2,860 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020107c:	10100593          	li	a1,257
ffffffffc0201080:	00004517          	auipc	a0,0x4
ffffffffc0201084:	3c050513          	addi	a0,a0,960 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201088:	93aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020108c:	00004697          	auipc	a3,0x4
ffffffffc0201090:	52468693          	addi	a3,a3,1316 # ffffffffc02055b0 <class_sizes+0x1b8>
ffffffffc0201094:	00004617          	auipc	a2,0x4
ffffffffc0201098:	33c60613          	addi	a2,a2,828 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020109c:	11e00593          	li	a1,286
ffffffffc02010a0:	00004517          	auipc	a0,0x4
ffffffffc02010a4:	3a050513          	addi	a0,a0,928 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02010a8:	91aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010ac:	00004697          	auipc	a3,0x4
ffffffffc02010b0:	41c68693          	addi	a3,a3,1052 # ffffffffc02054c8 <class_sizes+0xd0>
ffffffffc02010b4:	00004617          	auipc	a2,0x4
ffffffffc02010b8:	31c60613          	addi	a2,a2,796 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02010bc:	11c00593          	li	a1,284
ffffffffc02010c0:	00004517          	auipc	a0,0x4
ffffffffc02010c4:	38050513          	addi	a0,a0,896 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02010c8:	8faff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010cc:	00004697          	auipc	a3,0x4
ffffffffc02010d0:	3dc68693          	addi	a3,a3,988 # ffffffffc02054a8 <class_sizes+0xb0>
ffffffffc02010d4:	00004617          	auipc	a2,0x4
ffffffffc02010d8:	2fc60613          	addi	a2,a2,764 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02010dc:	11b00593          	li	a1,283
ffffffffc02010e0:	00004517          	auipc	a0,0x4
ffffffffc02010e4:	36050513          	addi	a0,a0,864 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02010e8:	8daff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010ec:	00004697          	auipc	a3,0x4
ffffffffc02010f0:	39c68693          	addi	a3,a3,924 # ffffffffc0205488 <class_sizes+0x90>
ffffffffc02010f4:	00004617          	auipc	a2,0x4
ffffffffc02010f8:	2dc60613          	addi	a2,a2,732 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02010fc:	11a00593          	li	a1,282
ffffffffc0201100:	00004517          	auipc	a0,0x4
ffffffffc0201104:	34050513          	addi	a0,a0,832 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201108:	8baff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free == 3);
ffffffffc020110c:	00004697          	auipc	a3,0x4
ffffffffc0201110:	4bc68693          	addi	a3,a3,1212 # ffffffffc02055c8 <class_sizes+0x1d0>
ffffffffc0201114:	00004617          	auipc	a2,0x4
ffffffffc0201118:	2bc60613          	addi	a2,a2,700 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020111c:	11800593          	li	a1,280
ffffffffc0201120:	00004517          	auipc	a0,0x4
ffffffffc0201124:	32050513          	addi	a0,a0,800 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201128:	89aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020112c:	00004697          	auipc	a3,0x4
ffffffffc0201130:	48468693          	addi	a3,a3,1156 # ffffffffc02055b0 <class_sizes+0x1b8>
ffffffffc0201134:	00004617          	auipc	a2,0x4
ffffffffc0201138:	29c60613          	addi	a2,a2,668 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020113c:	11300593          	li	a1,275
ffffffffc0201140:	00004517          	auipc	a0,0x4
ffffffffc0201144:	30050513          	addi	a0,a0,768 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201148:	87aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020114c:	00004697          	auipc	a3,0x4
ffffffffc0201150:	44468693          	addi	a3,a3,1092 # ffffffffc0205590 <class_sizes+0x198>
ffffffffc0201154:	00004617          	auipc	a2,0x4
ffffffffc0201158:	27c60613          	addi	a2,a2,636 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020115c:	10a00593          	li	a1,266
ffffffffc0201160:	00004517          	auipc	a0,0x4
ffffffffc0201164:	2e050513          	addi	a0,a0,736 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201168:	85aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020116c:	00004697          	auipc	a3,0x4
ffffffffc0201170:	40468693          	addi	a3,a3,1028 # ffffffffc0205570 <class_sizes+0x178>
ffffffffc0201174:	00004617          	auipc	a2,0x4
ffffffffc0201178:	25c60613          	addi	a2,a2,604 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020117c:	10900593          	li	a1,265
ffffffffc0201180:	00004517          	auipc	a0,0x4
ffffffffc0201184:	2c050513          	addi	a0,a0,704 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201188:	83aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(count == 0);
ffffffffc020118c:	00004697          	auipc	a3,0x4
ffffffffc0201190:	56c68693          	addi	a3,a3,1388 # ffffffffc02056f8 <class_sizes+0x300>
ffffffffc0201194:	00004617          	auipc	a2,0x4
ffffffffc0201198:	23c60613          	addi	a2,a2,572 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020119c:	17a00593          	li	a1,378
ffffffffc02011a0:	00004517          	auipc	a0,0x4
ffffffffc02011a4:	2a050513          	addi	a0,a0,672 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02011a8:	81aff0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free == 0);
ffffffffc02011ac:	00004697          	auipc	a3,0x4
ffffffffc02011b0:	46468693          	addi	a3,a3,1124 # ffffffffc0205610 <class_sizes+0x218>
ffffffffc02011b4:	00004617          	auipc	a2,0x4
ffffffffc02011b8:	21c60613          	addi	a2,a2,540 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02011bc:	16f00593          	li	a1,367
ffffffffc02011c0:	00004517          	auipc	a0,0x4
ffffffffc02011c4:	28050513          	addi	a0,a0,640 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02011c8:	ffbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011cc:	00004697          	auipc	a3,0x4
ffffffffc02011d0:	3e468693          	addi	a3,a3,996 # ffffffffc02055b0 <class_sizes+0x1b8>
ffffffffc02011d4:	00004617          	auipc	a2,0x4
ffffffffc02011d8:	1fc60613          	addi	a2,a2,508 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02011dc:	16900593          	li	a1,361
ffffffffc02011e0:	00004517          	auipc	a0,0x4
ffffffffc02011e4:	26050513          	addi	a0,a0,608 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02011e8:	fdbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011ec:	00004697          	auipc	a3,0x4
ffffffffc02011f0:	4ec68693          	addi	a3,a3,1260 # ffffffffc02056d8 <class_sizes+0x2e0>
ffffffffc02011f4:	00004617          	auipc	a2,0x4
ffffffffc02011f8:	1dc60613          	addi	a2,a2,476 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02011fc:	16800593          	li	a1,360
ffffffffc0201200:	00004517          	auipc	a0,0x4
ffffffffc0201204:	24050513          	addi	a0,a0,576 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201208:	fbbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 + 4 == p1);
ffffffffc020120c:	00004697          	auipc	a3,0x4
ffffffffc0201210:	4bc68693          	addi	a3,a3,1212 # ffffffffc02056c8 <class_sizes+0x2d0>
ffffffffc0201214:	00004617          	auipc	a2,0x4
ffffffffc0201218:	1bc60613          	addi	a2,a2,444 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020121c:	16000593          	li	a1,352
ffffffffc0201220:	00004517          	auipc	a0,0x4
ffffffffc0201224:	22050513          	addi	a0,a0,544 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201228:	f9bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc020122c:	00004697          	auipc	a3,0x4
ffffffffc0201230:	48468693          	addi	a3,a3,1156 # ffffffffc02056b0 <class_sizes+0x2b8>
ffffffffc0201234:	00004617          	auipc	a2,0x4
ffffffffc0201238:	19c60613          	addi	a2,a2,412 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020123c:	15f00593          	li	a1,351
ffffffffc0201240:	00004517          	auipc	a0,0x4
ffffffffc0201244:	20050513          	addi	a0,a0,512 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201248:	f7bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020124c:	00004697          	auipc	a3,0x4
ffffffffc0201250:	44468693          	addi	a3,a3,1092 # ffffffffc0205690 <class_sizes+0x298>
ffffffffc0201254:	00004617          	auipc	a2,0x4
ffffffffc0201258:	17c60613          	addi	a2,a2,380 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020125c:	15e00593          	li	a1,350
ffffffffc0201260:	00004517          	auipc	a0,0x4
ffffffffc0201264:	1e050513          	addi	a0,a0,480 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201268:	f5bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020126c:	00004697          	auipc	a3,0x4
ffffffffc0201270:	3f468693          	addi	a3,a3,1012 # ffffffffc0205660 <class_sizes+0x268>
ffffffffc0201274:	00004617          	auipc	a2,0x4
ffffffffc0201278:	15c60613          	addi	a2,a2,348 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020127c:	15c00593          	li	a1,348
ffffffffc0201280:	00004517          	auipc	a0,0x4
ffffffffc0201284:	1c050513          	addi	a0,a0,448 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201288:	f3bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020128c:	00004697          	auipc	a3,0x4
ffffffffc0201290:	3bc68693          	addi	a3,a3,956 # ffffffffc0205648 <class_sizes+0x250>
ffffffffc0201294:	00004617          	auipc	a2,0x4
ffffffffc0201298:	13c60613          	addi	a2,a2,316 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020129c:	15b00593          	li	a1,347
ffffffffc02012a0:	00004517          	auipc	a0,0x4
ffffffffc02012a4:	1a050513          	addi	a0,a0,416 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02012a8:	f1bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012ac:	00004697          	auipc	a3,0x4
ffffffffc02012b0:	30468693          	addi	a3,a3,772 # ffffffffc02055b0 <class_sizes+0x1b8>
ffffffffc02012b4:	00004617          	auipc	a2,0x4
ffffffffc02012b8:	11c60613          	addi	a2,a2,284 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02012bc:	14f00593          	li	a1,335
ffffffffc02012c0:	00004517          	auipc	a0,0x4
ffffffffc02012c4:	18050513          	addi	a0,a0,384 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02012c8:	efbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012cc:	00004697          	auipc	a3,0x4
ffffffffc02012d0:	36468693          	addi	a3,a3,868 # ffffffffc0205630 <class_sizes+0x238>
ffffffffc02012d4:	00004617          	auipc	a2,0x4
ffffffffc02012d8:	0fc60613          	addi	a2,a2,252 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02012dc:	14600593          	li	a1,326
ffffffffc02012e0:	00004517          	auipc	a0,0x4
ffffffffc02012e4:	16050513          	addi	a0,a0,352 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02012e8:	edbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(p0 != NULL);
ffffffffc02012ec:	00004697          	auipc	a3,0x4
ffffffffc02012f0:	33468693          	addi	a3,a3,820 # ffffffffc0205620 <class_sizes+0x228>
ffffffffc02012f4:	00004617          	auipc	a2,0x4
ffffffffc02012f8:	0dc60613          	addi	a2,a2,220 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02012fc:	14500593          	li	a1,325
ffffffffc0201300:	00004517          	auipc	a0,0x4
ffffffffc0201304:	14050513          	addi	a0,a0,320 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201308:	ebbfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(nr_free == 0);
ffffffffc020130c:	00004697          	auipc	a3,0x4
ffffffffc0201310:	30468693          	addi	a3,a3,772 # ffffffffc0205610 <class_sizes+0x218>
ffffffffc0201314:	00004617          	auipc	a2,0x4
ffffffffc0201318:	0bc60613          	addi	a2,a2,188 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020131c:	12700593          	li	a1,295
ffffffffc0201320:	00004517          	auipc	a0,0x4
ffffffffc0201324:	12050513          	addi	a0,a0,288 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201328:	e9bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020132c:	00004697          	auipc	a3,0x4
ffffffffc0201330:	28468693          	addi	a3,a3,644 # ffffffffc02055b0 <class_sizes+0x1b8>
ffffffffc0201334:	00004617          	auipc	a2,0x4
ffffffffc0201338:	09c60613          	addi	a2,a2,156 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020133c:	12500593          	li	a1,293
ffffffffc0201340:	00004517          	auipc	a0,0x4
ffffffffc0201344:	10050513          	addi	a0,a0,256 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201348:	e7bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020134c:	00004697          	auipc	a3,0x4
ffffffffc0201350:	2a468693          	addi	a3,a3,676 # ffffffffc02055f0 <class_sizes+0x1f8>
ffffffffc0201354:	00004617          	auipc	a2,0x4
ffffffffc0201358:	07c60613          	addi	a2,a2,124 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc020135c:	12400593          	li	a1,292
ffffffffc0201360:	00004517          	auipc	a0,0x4
ffffffffc0201364:	0e050513          	addi	a0,a0,224 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc0201368:	e5bfe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc020136c <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc020136c:	1141                	addi	sp,sp,-16
ffffffffc020136e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201370:	14058c63          	beqz	a1,ffffffffc02014c8 <best_fit_free_pages+0x15c>
    for (; p != base + n; p ++) {
ffffffffc0201374:	00259693          	slli	a3,a1,0x2
ffffffffc0201378:	96ae                	add	a3,a3,a1
ffffffffc020137a:	068e                	slli	a3,a3,0x3
ffffffffc020137c:	96aa                	add	a3,a3,a0
ffffffffc020137e:	87aa                	mv	a5,a0
ffffffffc0201380:	00d50e63          	beq	a0,a3,ffffffffc020139c <best_fit_free_pages+0x30>
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面可以被释放 - Ensure pages can be freed
ffffffffc0201384:	6798                	ld	a4,8(a5)
ffffffffc0201386:	8b0d                	andi	a4,a4,3
ffffffffc0201388:	12071063          	bnez	a4,ffffffffc02014a8 <best_fit_free_pages+0x13c>
        p->flags = 0;                                 // 清空标志位 - Clear flag bits
ffffffffc020138c:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201390:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201394:	02878793          	addi	a5,a5,40
ffffffffc0201398:	fed796e3          	bne	a5,a3,ffffffffc0201384 <best_fit_free_pages+0x18>
    SetPageProperty(base);                           // 设置属性标志 - Set property flag
ffffffffc020139c:	00853883          	ld	a7,8(a0)
    nr_free += n;                                    // 增加空闲页计数 - Increment free page count
ffffffffc02013a0:	00009697          	auipc	a3,0x9
ffffffffc02013a4:	d4068693          	addi	a3,a3,-704 # ffffffffc020a0e0 <free_area>
ffffffffc02013a8:	4a98                	lw	a4,16(a3)
    base->property = n;                              // 记录块大小 - Record block size
ffffffffc02013aa:	2581                	sext.w	a1,a1
    SetPageProperty(base);                           // 设置属性标志 - Set property flag
ffffffffc02013ac:	0028e613          	ori	a2,a7,2
    return list->next == list;
ffffffffc02013b0:	669c                	ld	a5,8(a3)
    base->property = n;                              // 记录块大小 - Record block size
ffffffffc02013b2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);                           // 设置属性标志 - Set property flag
ffffffffc02013b4:	e510                	sd	a2,8(a0)
    nr_free += n;                                    // 增加空闲页计数 - Increment free page count
ffffffffc02013b6:	9f2d                	addw	a4,a4,a1
ffffffffc02013b8:	ca98                	sw	a4,16(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02013ba:	01850613          	addi	a2,a0,24
    if (list_empty(&free_list)) {
ffffffffc02013be:	0ad78b63          	beq	a5,a3,ffffffffc0201474 <best_fit_free_pages+0x108>
            struct Page* page = le2page(le, page_link);
ffffffffc02013c2:	fe878713          	addi	a4,a5,-24
ffffffffc02013c6:	0006b303          	ld	t1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013ca:	4801                	li	a6,0
            if (base < page) {
ffffffffc02013cc:	00e56a63          	bltu	a0,a4,ffffffffc02013e0 <best_fit_free_pages+0x74>
    return listelm->next;
ffffffffc02013d0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013d2:	06d70563          	beq	a4,a3,ffffffffc020143c <best_fit_free_pages+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02013d6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013d8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013dc:	fee57ae3          	bgeu	a0,a4,ffffffffc02013d0 <best_fit_free_pages+0x64>
ffffffffc02013e0:	00080463          	beqz	a6,ffffffffc02013e8 <best_fit_free_pages+0x7c>
ffffffffc02013e4:	0066b023          	sd	t1,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013e8:	0007b803          	ld	a6,0(a5)
    prev->next = next->prev = elm;
ffffffffc02013ec:	e390                	sd	a2,0(a5)
ffffffffc02013ee:	00c83423          	sd	a2,8(a6)
    elm->next = next;
ffffffffc02013f2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02013f4:	01053c23          	sd	a6,24(a0)
    if (le != &free_list) {
ffffffffc02013f8:	02d80463          	beq	a6,a3,ffffffffc0201420 <best_fit_free_pages+0xb4>
        if (p + p->property == base) {
ffffffffc02013fc:	ff882e03          	lw	t3,-8(a6)
        p = le2page(le, page_link);
ffffffffc0201400:	fe880313          	addi	t1,a6,-24
        if (p + p->property == base) {
ffffffffc0201404:	020e1613          	slli	a2,t3,0x20
ffffffffc0201408:	9201                	srli	a2,a2,0x20
ffffffffc020140a:	00261713          	slli	a4,a2,0x2
ffffffffc020140e:	9732                	add	a4,a4,a2
ffffffffc0201410:	070e                	slli	a4,a4,0x3
ffffffffc0201412:	971a                	add	a4,a4,t1
ffffffffc0201414:	02e50e63          	beq	a0,a4,ffffffffc0201450 <best_fit_free_pages+0xe4>
    if (le != &free_list) {
ffffffffc0201418:	00d78f63          	beq	a5,a3,ffffffffc0201436 <best_fit_free_pages+0xca>
ffffffffc020141c:	fe878713          	addi	a4,a5,-24
        if (base + base->property == p) {
ffffffffc0201420:	490c                	lw	a1,16(a0)
ffffffffc0201422:	02059613          	slli	a2,a1,0x20
ffffffffc0201426:	9201                	srli	a2,a2,0x20
ffffffffc0201428:	00261693          	slli	a3,a2,0x2
ffffffffc020142c:	96b2                	add	a3,a3,a2
ffffffffc020142e:	068e                	slli	a3,a3,0x3
ffffffffc0201430:	96aa                	add	a3,a3,a0
ffffffffc0201432:	04d70863          	beq	a4,a3,ffffffffc0201482 <best_fit_free_pages+0x116>
}
ffffffffc0201436:	60a2                	ld	ra,8(sp)
ffffffffc0201438:	0141                	addi	sp,sp,16
ffffffffc020143a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020143c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020143e:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201440:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201442:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201444:	02d70463          	beq	a4,a3,ffffffffc020146c <best_fit_free_pages+0x100>
    prev->next = next->prev = elm;
ffffffffc0201448:	8332                	mv	t1,a2
ffffffffc020144a:	4805                	li	a6,1
    for (; p != base + n; p ++) {
ffffffffc020144c:	87ba                	mv	a5,a4
ffffffffc020144e:	b769                	j	ffffffffc02013d8 <best_fit_free_pages+0x6c>
            p->property += base->property;      // 合并块大小 - Merge block sizes
ffffffffc0201450:	01c585bb          	addw	a1,a1,t3
ffffffffc0201454:	feb82c23          	sw	a1,-8(a6)
            ClearPageProperty(base);            // 清除当前块的头标志 - Clear head flag of current block
ffffffffc0201458:	ffd8f893          	andi	a7,a7,-3
ffffffffc020145c:	01153423          	sd	a7,8(a0)
    prev->next = next;
ffffffffc0201460:	00f83423          	sd	a5,8(a6)
    next->prev = prev;
ffffffffc0201464:	0107b023          	sd	a6,0(a5)
            base = p;                           // 更新base指针 - Update base pointer
ffffffffc0201468:	851a                	mv	a0,t1
ffffffffc020146a:	b77d                	j	ffffffffc0201418 <best_fit_free_pages+0xac>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020146c:	883e                	mv	a6,a5
ffffffffc020146e:	e290                	sd	a2,0(a3)
ffffffffc0201470:	87b6                	mv	a5,a3
ffffffffc0201472:	b769                	j	ffffffffc02013fc <best_fit_free_pages+0x90>
}
ffffffffc0201474:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201476:	e390                	sd	a2,0(a5)
ffffffffc0201478:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020147a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020147c:	ed1c                	sd	a5,24(a0)
ffffffffc020147e:	0141                	addi	sp,sp,16
ffffffffc0201480:	8082                	ret
            base->property += p->property;      // 合并块大小 - Merge block sizes
ffffffffc0201482:	ff87a683          	lw	a3,-8(a5)
            ClearPageProperty(p);               // 清除后面块的头标志 - Clear head flag of next block
ffffffffc0201486:	ff07b703          	ld	a4,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020148a:	0007b803          	ld	a6,0(a5)
ffffffffc020148e:	6790                	ld	a2,8(a5)
            base->property += p->property;      // 合并块大小 - Merge block sizes
ffffffffc0201490:	9db5                	addw	a1,a1,a3
ffffffffc0201492:	c90c                	sw	a1,16(a0)
            ClearPageProperty(p);               // 清除后面块的头标志 - Clear head flag of next block
ffffffffc0201494:	9b75                	andi	a4,a4,-3
ffffffffc0201496:	fee7b823          	sd	a4,-16(a5)
}
ffffffffc020149a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020149c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02014a0:	01063023          	sd	a6,0(a2)
ffffffffc02014a4:	0141                	addi	sp,sp,16
ffffffffc02014a6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面可以被释放 - Ensure pages can be freed
ffffffffc02014a8:	00004697          	auipc	a3,0x4
ffffffffc02014ac:	27068693          	addi	a3,a3,624 # ffffffffc0205718 <class_sizes+0x320>
ffffffffc02014b0:	00004617          	auipc	a2,0x4
ffffffffc02014b4:	f2060613          	addi	a2,a2,-224 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02014b8:	0bd00593          	li	a1,189
ffffffffc02014bc:	00004517          	auipc	a0,0x4
ffffffffc02014c0:	f8450513          	addi	a0,a0,-124 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02014c4:	cfffe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	f7068693          	addi	a3,a3,-144 # ffffffffc0205438 <class_sizes+0x40>
ffffffffc02014d0:	00004617          	auipc	a2,0x4
ffffffffc02014d4:	f0060613          	addi	a2,a2,-256 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02014d8:	0b800593          	li	a1,184
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	f6450513          	addi	a0,a0,-156 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02014e4:	cdffe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02014e8 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02014e8:	1141                	addi	sp,sp,-16
ffffffffc02014ea:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014ec:	c5f9                	beqz	a1,ffffffffc02015ba <best_fit_init_memmap+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02014ee:	00259693          	slli	a3,a1,0x2
ffffffffc02014f2:	96ae                	add	a3,a3,a1
ffffffffc02014f4:	068e                	slli	a3,a3,0x3
ffffffffc02014f6:	96aa                	add	a3,a3,a0
ffffffffc02014f8:	87aa                	mv	a5,a0
ffffffffc02014fa:	00d50f63          	beq	a0,a3,ffffffffc0201518 <best_fit_init_memmap+0x30>
        assert(PageReserved(p));        // 确保页面之前是保留状态 - Ensure page was reserved
ffffffffc02014fe:	6798                	ld	a4,8(a5)
ffffffffc0201500:	8b05                	andi	a4,a4,1
ffffffffc0201502:	cf41                	beqz	a4,ffffffffc020159a <best_fit_init_memmap+0xb2>
        p->flags = 0;                   // 清空标志位 - Clear flags
ffffffffc0201504:	0007b423          	sd	zero,8(a5)
        p->property = 0;                // 清空属性 - Clear property
ffffffffc0201508:	0007a823          	sw	zero,16(a5)
ffffffffc020150c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201510:	02878793          	addi	a5,a5,40
ffffffffc0201514:	fed795e3          	bne	a5,a3,ffffffffc02014fe <best_fit_init_memmap+0x16>
    SetPageProperty(base);              // 设置页面属性标志 - Set page property flag
ffffffffc0201518:	6510                	ld	a2,8(a0)
    nr_free += n;                       // 增加空闲页计数 - Increment free page count
ffffffffc020151a:	00009697          	auipc	a3,0x9
ffffffffc020151e:	bc668693          	addi	a3,a3,-1082 # ffffffffc020a0e0 <free_area>
ffffffffc0201522:	4a98                	lw	a4,16(a3)
    base->property = n;                 // 头页面记录整个块的大小 - Head page records the size of entire block
ffffffffc0201524:	2581                	sext.w	a1,a1
    SetPageProperty(base);              // 设置页面属性标志 - Set page property flag
ffffffffc0201526:	00266613          	ori	a2,a2,2
    return list->next == list;
ffffffffc020152a:	669c                	ld	a5,8(a3)
    base->property = n;                 // 头页面记录整个块的大小 - Head page records the size of entire block
ffffffffc020152c:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);              // 设置页面属性标志 - Set page property flag
ffffffffc020152e:	e510                	sd	a2,8(a0)
    nr_free += n;                       // 增加空闲页计数 - Increment free page count
ffffffffc0201530:	9db9                	addw	a1,a1,a4
ffffffffc0201532:	ca8c                	sw	a1,16(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201534:	01850613          	addi	a2,a0,24
    if (list_empty(&free_list)) {
ffffffffc0201538:	04d78a63          	beq	a5,a3,ffffffffc020158c <best_fit_init_memmap+0xa4>
            struct Page* page = le2page(le, page_link);
ffffffffc020153c:	fe878713          	addi	a4,a5,-24
ffffffffc0201540:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201544:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201546:	00e56a63          	bltu	a0,a4,ffffffffc020155a <best_fit_init_memmap+0x72>
    return listelm->next;
ffffffffc020154a:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020154c:	02d70263          	beq	a4,a3,ffffffffc0201570 <best_fit_init_memmap+0x88>
    for (; p != base + n; p ++) {
ffffffffc0201550:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201552:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201556:	fee57ae3          	bgeu	a0,a4,ffffffffc020154a <best_fit_init_memmap+0x62>
ffffffffc020155a:	c199                	beqz	a1,ffffffffc0201560 <best_fit_init_memmap+0x78>
ffffffffc020155c:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201560:	6398                	ld	a4,0(a5)
}
ffffffffc0201562:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201564:	e390                	sd	a2,0(a5)
ffffffffc0201566:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201568:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020156a:	ed18                	sd	a4,24(a0)
ffffffffc020156c:	0141                	addi	sp,sp,16
ffffffffc020156e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201570:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201572:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201574:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201576:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201578:	00d70663          	beq	a4,a3,ffffffffc0201584 <best_fit_init_memmap+0x9c>
    prev->next = next->prev = elm;
ffffffffc020157c:	8832                	mv	a6,a2
ffffffffc020157e:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201580:	87ba                	mv	a5,a4
ffffffffc0201582:	bfc1                	j	ffffffffc0201552 <best_fit_init_memmap+0x6a>
}
ffffffffc0201584:	60a2                	ld	ra,8(sp)
ffffffffc0201586:	e290                	sd	a2,0(a3)
ffffffffc0201588:	0141                	addi	sp,sp,16
ffffffffc020158a:	8082                	ret
ffffffffc020158c:	60a2                	ld	ra,8(sp)
ffffffffc020158e:	e390                	sd	a2,0(a5)
ffffffffc0201590:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201592:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201594:	ed1c                	sd	a5,24(a0)
ffffffffc0201596:	0141                	addi	sp,sp,16
ffffffffc0201598:	8082                	ret
        assert(PageReserved(p));        // 确保页面之前是保留状态 - Ensure page was reserved
ffffffffc020159a:	00004697          	auipc	a3,0x4
ffffffffc020159e:	1a668693          	addi	a3,a3,422 # ffffffffc0205740 <class_sizes+0x348>
ffffffffc02015a2:	00004617          	auipc	a2,0x4
ffffffffc02015a6:	e2e60613          	addi	a2,a2,-466 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02015aa:	05400593          	li	a1,84
ffffffffc02015ae:	00004517          	auipc	a0,0x4
ffffffffc02015b2:	e9250513          	addi	a0,a0,-366 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02015b6:	c0dfe0ef          	jal	ra,ffffffffc02001c2 <__panic>
    assert(n > 0);
ffffffffc02015ba:	00004697          	auipc	a3,0x4
ffffffffc02015be:	e7e68693          	addi	a3,a3,-386 # ffffffffc0205438 <class_sizes+0x40>
ffffffffc02015c2:	00004617          	auipc	a2,0x4
ffffffffc02015c6:	e0e60613          	addi	a2,a2,-498 # ffffffffc02053d0 <boot_page_table_sv39+0x13d0>
ffffffffc02015ca:	04f00593          	li	a1,79
ffffffffc02015ce:	00004517          	auipc	a0,0x4
ffffffffc02015d2:	e7250513          	addi	a0,a0,-398 # ffffffffc0205440 <class_sizes+0x48>
ffffffffc02015d6:	bedfe0ef          	jal	ra,ffffffffc02001c2 <__panic>

ffffffffc02015da <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02015da:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02015de:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02015e0:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02015e2:	cb81                	beqz	a5,ffffffffc02015f2 <strlen+0x18>
        cnt ++;
ffffffffc02015e4:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02015e6:	00a707b3          	add	a5,a4,a0
ffffffffc02015ea:	0007c783          	lbu	a5,0(a5)
ffffffffc02015ee:	fbfd                	bnez	a5,ffffffffc02015e4 <strlen+0xa>
ffffffffc02015f0:	8082                	ret
    }
    return cnt;
}
ffffffffc02015f2:	8082                	ret

ffffffffc02015f4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02015f4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015f6:	e589                	bnez	a1,ffffffffc0201600 <strnlen+0xc>
ffffffffc02015f8:	a811                	j	ffffffffc020160c <strnlen+0x18>
        cnt ++;
ffffffffc02015fa:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02015fc:	00f58863          	beq	a1,a5,ffffffffc020160c <strnlen+0x18>
ffffffffc0201600:	00f50733          	add	a4,a0,a5
ffffffffc0201604:	00074703          	lbu	a4,0(a4)
ffffffffc0201608:	fb6d                	bnez	a4,ffffffffc02015fa <strnlen+0x6>
ffffffffc020160a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020160c:	852e                	mv	a0,a1
ffffffffc020160e:	8082                	ret

ffffffffc0201610 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201610:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201614:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201618:	cb89                	beqz	a5,ffffffffc020162a <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020161a:	0505                	addi	a0,a0,1
ffffffffc020161c:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020161e:	fee789e3          	beq	a5,a4,ffffffffc0201610 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201622:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201626:	9d19                	subw	a0,a0,a4
ffffffffc0201628:	8082                	ret
ffffffffc020162a:	4501                	li	a0,0
ffffffffc020162c:	bfed                	j	ffffffffc0201626 <strcmp+0x16>

ffffffffc020162e <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020162e:	c20d                	beqz	a2,ffffffffc0201650 <strncmp+0x22>
ffffffffc0201630:	962e                	add	a2,a2,a1
ffffffffc0201632:	a031                	j	ffffffffc020163e <strncmp+0x10>
        n --, s1 ++, s2 ++;
ffffffffc0201634:	0505                	addi	a0,a0,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201636:	00e79a63          	bne	a5,a4,ffffffffc020164a <strncmp+0x1c>
ffffffffc020163a:	00b60b63          	beq	a2,a1,ffffffffc0201650 <strncmp+0x22>
ffffffffc020163e:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201642:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201644:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0201648:	f7f5                	bnez	a5,ffffffffc0201634 <strncmp+0x6>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020164a:	40e7853b          	subw	a0,a5,a4
}
ffffffffc020164e:	8082                	ret
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201650:	4501                	li	a0,0
ffffffffc0201652:	8082                	ret

ffffffffc0201654 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201654:	ca01                	beqz	a2,ffffffffc0201664 <memset+0x10>
ffffffffc0201656:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201658:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020165a:	0785                	addi	a5,a5,1
ffffffffc020165c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201660:	fec79de3          	bne	a5,a2,ffffffffc020165a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201664:	8082                	ret

ffffffffc0201666 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201666:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020166a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020166c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201670:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201672:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201676:	f022                	sd	s0,32(sp)
ffffffffc0201678:	ec26                	sd	s1,24(sp)
ffffffffc020167a:	e84a                	sd	s2,16(sp)
ffffffffc020167c:	f406                	sd	ra,40(sp)
ffffffffc020167e:	e44e                	sd	s3,8(sp)
ffffffffc0201680:	84aa                	mv	s1,a0
ffffffffc0201682:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201684:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201688:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020168a:	03067e63          	bgeu	a2,a6,ffffffffc02016c6 <printnum+0x60>
ffffffffc020168e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201690:	00805763          	blez	s0,ffffffffc020169e <printnum+0x38>
ffffffffc0201694:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201696:	85ca                	mv	a1,s2
ffffffffc0201698:	854e                	mv	a0,s3
ffffffffc020169a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020169c:	fc65                	bnez	s0,ffffffffc0201694 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020169e:	1a02                	slli	s4,s4,0x20
ffffffffc02016a0:	00004797          	auipc	a5,0x4
ffffffffc02016a4:	10078793          	addi	a5,a5,256 # ffffffffc02057a0 <best_fit_pmm_manager+0x38>
ffffffffc02016a8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02016ac:	9a3e                	add	s4,s4,a5
}
ffffffffc02016ae:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016b0:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02016b4:	70a2                	ld	ra,40(sp)
ffffffffc02016b6:	69a2                	ld	s3,8(sp)
ffffffffc02016b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016ba:	85ca                	mv	a1,s2
ffffffffc02016bc:	87a6                	mv	a5,s1
}
ffffffffc02016be:	6942                	ld	s2,16(sp)
ffffffffc02016c0:	64e2                	ld	s1,24(sp)
ffffffffc02016c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02016c4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02016c6:	03065633          	divu	a2,a2,a6
ffffffffc02016ca:	8722                	mv	a4,s0
ffffffffc02016cc:	f9bff0ef          	jal	ra,ffffffffc0201666 <printnum>
ffffffffc02016d0:	b7f9                	j	ffffffffc020169e <printnum+0x38>

ffffffffc02016d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02016d2:	7119                	addi	sp,sp,-128
ffffffffc02016d4:	f4a6                	sd	s1,104(sp)
ffffffffc02016d6:	f0ca                	sd	s2,96(sp)
ffffffffc02016d8:	ecce                	sd	s3,88(sp)
ffffffffc02016da:	e8d2                	sd	s4,80(sp)
ffffffffc02016dc:	e4d6                	sd	s5,72(sp)
ffffffffc02016de:	e0da                	sd	s6,64(sp)
ffffffffc02016e0:	fc5e                	sd	s7,56(sp)
ffffffffc02016e2:	f06a                	sd	s10,32(sp)
ffffffffc02016e4:	fc86                	sd	ra,120(sp)
ffffffffc02016e6:	f8a2                	sd	s0,112(sp)
ffffffffc02016e8:	f862                	sd	s8,48(sp)
ffffffffc02016ea:	f466                	sd	s9,40(sp)
ffffffffc02016ec:	ec6e                	sd	s11,24(sp)
ffffffffc02016ee:	892a                	mv	s2,a0
ffffffffc02016f0:	84ae                	mv	s1,a1
ffffffffc02016f2:	8d32                	mv	s10,a2
ffffffffc02016f4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016f6:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016fa:	5b7d                	li	s6,-1
ffffffffc02016fc:	00004a97          	auipc	s5,0x4
ffffffffc0201700:	0d8a8a93          	addi	s5,s5,216 # ffffffffc02057d4 <best_fit_pmm_manager+0x6c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201704:	00004b97          	auipc	s7,0x4
ffffffffc0201708:	2acb8b93          	addi	s7,s7,684 # ffffffffc02059b0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020170c:	000d4503          	lbu	a0,0(s10)
ffffffffc0201710:	001d0413          	addi	s0,s10,1
ffffffffc0201714:	01350a63          	beq	a0,s3,ffffffffc0201728 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201718:	c121                	beqz	a0,ffffffffc0201758 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020171a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020171c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020171e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201720:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201724:	ff351ae3          	bne	a0,s3,ffffffffc0201718 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201728:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020172c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201730:	4c81                	li	s9,0
ffffffffc0201732:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201734:	5c7d                	li	s8,-1
ffffffffc0201736:	5dfd                	li	s11,-1
ffffffffc0201738:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020173c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020173e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201742:	0ff5f593          	zext.b	a1,a1
ffffffffc0201746:	00140d13          	addi	s10,s0,1
ffffffffc020174a:	04b56263          	bltu	a0,a1,ffffffffc020178e <vprintfmt+0xbc>
ffffffffc020174e:	058a                	slli	a1,a1,0x2
ffffffffc0201750:	95d6                	add	a1,a1,s5
ffffffffc0201752:	4194                	lw	a3,0(a1)
ffffffffc0201754:	96d6                	add	a3,a3,s5
ffffffffc0201756:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201758:	70e6                	ld	ra,120(sp)
ffffffffc020175a:	7446                	ld	s0,112(sp)
ffffffffc020175c:	74a6                	ld	s1,104(sp)
ffffffffc020175e:	7906                	ld	s2,96(sp)
ffffffffc0201760:	69e6                	ld	s3,88(sp)
ffffffffc0201762:	6a46                	ld	s4,80(sp)
ffffffffc0201764:	6aa6                	ld	s5,72(sp)
ffffffffc0201766:	6b06                	ld	s6,64(sp)
ffffffffc0201768:	7be2                	ld	s7,56(sp)
ffffffffc020176a:	7c42                	ld	s8,48(sp)
ffffffffc020176c:	7ca2                	ld	s9,40(sp)
ffffffffc020176e:	7d02                	ld	s10,32(sp)
ffffffffc0201770:	6de2                	ld	s11,24(sp)
ffffffffc0201772:	6109                	addi	sp,sp,128
ffffffffc0201774:	8082                	ret
            padc = '0';
ffffffffc0201776:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201778:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020177c:	846a                	mv	s0,s10
ffffffffc020177e:	00140d13          	addi	s10,s0,1
ffffffffc0201782:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201786:	0ff5f593          	zext.b	a1,a1
ffffffffc020178a:	fcb572e3          	bgeu	a0,a1,ffffffffc020174e <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020178e:	85a6                	mv	a1,s1
ffffffffc0201790:	02500513          	li	a0,37
ffffffffc0201794:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201796:	fff44783          	lbu	a5,-1(s0)
ffffffffc020179a:	8d22                	mv	s10,s0
ffffffffc020179c:	f73788e3          	beq	a5,s3,ffffffffc020170c <vprintfmt+0x3a>
ffffffffc02017a0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02017a4:	1d7d                	addi	s10,s10,-1
ffffffffc02017a6:	ff379de3          	bne	a5,s3,ffffffffc02017a0 <vprintfmt+0xce>
ffffffffc02017aa:	b78d                	j	ffffffffc020170c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02017ac:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02017b0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017b4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02017b6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02017ba:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017be:	02d86463          	bltu	a6,a3,ffffffffc02017e6 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02017c2:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02017c6:	002c169b          	slliw	a3,s8,0x2
ffffffffc02017ca:	0186873b          	addw	a4,a3,s8
ffffffffc02017ce:	0017171b          	slliw	a4,a4,0x1
ffffffffc02017d2:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02017d4:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02017d8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02017da:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02017de:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02017e2:	fed870e3          	bgeu	a6,a3,ffffffffc02017c2 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02017e6:	f40ddce3          	bgez	s11,ffffffffc020173e <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02017ea:	8de2                	mv	s11,s8
ffffffffc02017ec:	5c7d                	li	s8,-1
ffffffffc02017ee:	bf81                	j	ffffffffc020173e <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02017f0:	fffdc693          	not	a3,s11
ffffffffc02017f4:	96fd                	srai	a3,a3,0x3f
ffffffffc02017f6:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017fa:	00144603          	lbu	a2,1(s0)
ffffffffc02017fe:	2d81                	sext.w	s11,s11
ffffffffc0201800:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201802:	bf35                	j	ffffffffc020173e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201804:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201808:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020180c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020180e:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201810:	bfd9                	j	ffffffffc02017e6 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201812:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201814:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201818:	01174463          	blt	a4,a7,ffffffffc0201820 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020181c:	1a088e63          	beqz	a7,ffffffffc02019d8 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201820:	000a3603          	ld	a2,0(s4)
ffffffffc0201824:	46c1                	li	a3,16
ffffffffc0201826:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201828:	2781                	sext.w	a5,a5
ffffffffc020182a:	876e                	mv	a4,s11
ffffffffc020182c:	85a6                	mv	a1,s1
ffffffffc020182e:	854a                	mv	a0,s2
ffffffffc0201830:	e37ff0ef          	jal	ra,ffffffffc0201666 <printnum>
            break;
ffffffffc0201834:	bde1                	j	ffffffffc020170c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201836:	000a2503          	lw	a0,0(s4)
ffffffffc020183a:	85a6                	mv	a1,s1
ffffffffc020183c:	0a21                	addi	s4,s4,8
ffffffffc020183e:	9902                	jalr	s2
            break;
ffffffffc0201840:	b5f1                	j	ffffffffc020170c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201842:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201844:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201848:	01174463          	blt	a4,a7,ffffffffc0201850 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020184c:	18088163          	beqz	a7,ffffffffc02019ce <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201850:	000a3603          	ld	a2,0(s4)
ffffffffc0201854:	46a9                	li	a3,10
ffffffffc0201856:	8a2e                	mv	s4,a1
ffffffffc0201858:	bfc1                	j	ffffffffc0201828 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020185a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020185e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201860:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201862:	bdf1                	j	ffffffffc020173e <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201864:	85a6                	mv	a1,s1
ffffffffc0201866:	02500513          	li	a0,37
ffffffffc020186a:	9902                	jalr	s2
            break;
ffffffffc020186c:	b545                	j	ffffffffc020170c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020186e:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201872:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201874:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201876:	b5e1                	j	ffffffffc020173e <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201878:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020187a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020187e:	01174463          	blt	a4,a7,ffffffffc0201886 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201882:	14088163          	beqz	a7,ffffffffc02019c4 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201886:	000a3603          	ld	a2,0(s4)
ffffffffc020188a:	46a1                	li	a3,8
ffffffffc020188c:	8a2e                	mv	s4,a1
ffffffffc020188e:	bf69                	j	ffffffffc0201828 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201890:	03000513          	li	a0,48
ffffffffc0201894:	85a6                	mv	a1,s1
ffffffffc0201896:	e03e                	sd	a5,0(sp)
ffffffffc0201898:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020189a:	85a6                	mv	a1,s1
ffffffffc020189c:	07800513          	li	a0,120
ffffffffc02018a0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018a2:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02018a4:	6782                	ld	a5,0(sp)
ffffffffc02018a6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02018a8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02018ac:	bfb5                	j	ffffffffc0201828 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02018ae:	000a3403          	ld	s0,0(s4)
ffffffffc02018b2:	008a0713          	addi	a4,s4,8
ffffffffc02018b6:	e03a                	sd	a4,0(sp)
ffffffffc02018b8:	14040263          	beqz	s0,ffffffffc02019fc <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02018bc:	0fb05763          	blez	s11,ffffffffc02019aa <vprintfmt+0x2d8>
ffffffffc02018c0:	02d00693          	li	a3,45
ffffffffc02018c4:	0cd79163          	bne	a5,a3,ffffffffc0201986 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018c8:	00044783          	lbu	a5,0(s0)
ffffffffc02018cc:	0007851b          	sext.w	a0,a5
ffffffffc02018d0:	cf85                	beqz	a5,ffffffffc0201908 <vprintfmt+0x236>
ffffffffc02018d2:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018d6:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018da:	000c4563          	bltz	s8,ffffffffc02018e4 <vprintfmt+0x212>
ffffffffc02018de:	3c7d                	addiw	s8,s8,-1
ffffffffc02018e0:	036c0263          	beq	s8,s6,ffffffffc0201904 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02018e4:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018e6:	0e0c8e63          	beqz	s9,ffffffffc02019e2 <vprintfmt+0x310>
ffffffffc02018ea:	3781                	addiw	a5,a5,-32
ffffffffc02018ec:	0ef47b63          	bgeu	s0,a5,ffffffffc02019e2 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02018f0:	03f00513          	li	a0,63
ffffffffc02018f4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018f6:	000a4783          	lbu	a5,0(s4)
ffffffffc02018fa:	3dfd                	addiw	s11,s11,-1
ffffffffc02018fc:	0a05                	addi	s4,s4,1
ffffffffc02018fe:	0007851b          	sext.w	a0,a5
ffffffffc0201902:	ffe1                	bnez	a5,ffffffffc02018da <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201904:	01b05963          	blez	s11,ffffffffc0201916 <vprintfmt+0x244>
ffffffffc0201908:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020190a:	85a6                	mv	a1,s1
ffffffffc020190c:	02000513          	li	a0,32
ffffffffc0201910:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201912:	fe0d9be3          	bnez	s11,ffffffffc0201908 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201916:	6a02                	ld	s4,0(sp)
ffffffffc0201918:	bbd5                	j	ffffffffc020170c <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020191a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020191c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201920:	01174463          	blt	a4,a7,ffffffffc0201928 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201924:	08088d63          	beqz	a7,ffffffffc02019be <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201928:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020192c:	0a044d63          	bltz	s0,ffffffffc02019e6 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201930:	8622                	mv	a2,s0
ffffffffc0201932:	8a66                	mv	s4,s9
ffffffffc0201934:	46a9                	li	a3,10
ffffffffc0201936:	bdcd                	j	ffffffffc0201828 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201938:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020193c:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020193e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201940:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201944:	8fb5                	xor	a5,a5,a3
ffffffffc0201946:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020194a:	02d74163          	blt	a4,a3,ffffffffc020196c <vprintfmt+0x29a>
ffffffffc020194e:	00369793          	slli	a5,a3,0x3
ffffffffc0201952:	97de                	add	a5,a5,s7
ffffffffc0201954:	639c                	ld	a5,0(a5)
ffffffffc0201956:	cb99                	beqz	a5,ffffffffc020196c <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201958:	86be                	mv	a3,a5
ffffffffc020195a:	00004617          	auipc	a2,0x4
ffffffffc020195e:	e7660613          	addi	a2,a2,-394 # ffffffffc02057d0 <best_fit_pmm_manager+0x68>
ffffffffc0201962:	85a6                	mv	a1,s1
ffffffffc0201964:	854a                	mv	a0,s2
ffffffffc0201966:	0ce000ef          	jal	ra,ffffffffc0201a34 <printfmt>
ffffffffc020196a:	b34d                	j	ffffffffc020170c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020196c:	00004617          	auipc	a2,0x4
ffffffffc0201970:	e5460613          	addi	a2,a2,-428 # ffffffffc02057c0 <best_fit_pmm_manager+0x58>
ffffffffc0201974:	85a6                	mv	a1,s1
ffffffffc0201976:	854a                	mv	a0,s2
ffffffffc0201978:	0bc000ef          	jal	ra,ffffffffc0201a34 <printfmt>
ffffffffc020197c:	bb41                	j	ffffffffc020170c <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020197e:	00004417          	auipc	s0,0x4
ffffffffc0201982:	e3a40413          	addi	s0,s0,-454 # ffffffffc02057b8 <best_fit_pmm_manager+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201986:	85e2                	mv	a1,s8
ffffffffc0201988:	8522                	mv	a0,s0
ffffffffc020198a:	e43e                	sd	a5,8(sp)
ffffffffc020198c:	c69ff0ef          	jal	ra,ffffffffc02015f4 <strnlen>
ffffffffc0201990:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201994:	01b05b63          	blez	s11,ffffffffc02019aa <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201998:	67a2                	ld	a5,8(sp)
ffffffffc020199a:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020199e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02019a0:	85a6                	mv	a1,s1
ffffffffc02019a2:	8552                	mv	a0,s4
ffffffffc02019a4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02019a6:	fe0d9ce3          	bnez	s11,ffffffffc020199e <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019aa:	00044783          	lbu	a5,0(s0)
ffffffffc02019ae:	00140a13          	addi	s4,s0,1
ffffffffc02019b2:	0007851b          	sext.w	a0,a5
ffffffffc02019b6:	d3a5                	beqz	a5,ffffffffc0201916 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019b8:	05e00413          	li	s0,94
ffffffffc02019bc:	bf39                	j	ffffffffc02018da <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02019be:	000a2403          	lw	s0,0(s4)
ffffffffc02019c2:	b7ad                	j	ffffffffc020192c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02019c4:	000a6603          	lwu	a2,0(s4)
ffffffffc02019c8:	46a1                	li	a3,8
ffffffffc02019ca:	8a2e                	mv	s4,a1
ffffffffc02019cc:	bdb1                	j	ffffffffc0201828 <vprintfmt+0x156>
ffffffffc02019ce:	000a6603          	lwu	a2,0(s4)
ffffffffc02019d2:	46a9                	li	a3,10
ffffffffc02019d4:	8a2e                	mv	s4,a1
ffffffffc02019d6:	bd89                	j	ffffffffc0201828 <vprintfmt+0x156>
ffffffffc02019d8:	000a6603          	lwu	a2,0(s4)
ffffffffc02019dc:	46c1                	li	a3,16
ffffffffc02019de:	8a2e                	mv	s4,a1
ffffffffc02019e0:	b5a1                	j	ffffffffc0201828 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02019e2:	9902                	jalr	s2
ffffffffc02019e4:	bf09                	j	ffffffffc02018f6 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02019e6:	85a6                	mv	a1,s1
ffffffffc02019e8:	02d00513          	li	a0,45
ffffffffc02019ec:	e03e                	sd	a5,0(sp)
ffffffffc02019ee:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02019f0:	6782                	ld	a5,0(sp)
ffffffffc02019f2:	8a66                	mv	s4,s9
ffffffffc02019f4:	40800633          	neg	a2,s0
ffffffffc02019f8:	46a9                	li	a3,10
ffffffffc02019fa:	b53d                	j	ffffffffc0201828 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02019fc:	03b05163          	blez	s11,ffffffffc0201a1e <vprintfmt+0x34c>
ffffffffc0201a00:	02d00693          	li	a3,45
ffffffffc0201a04:	f6d79de3          	bne	a5,a3,ffffffffc020197e <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201a08:	00004417          	auipc	s0,0x4
ffffffffc0201a0c:	db040413          	addi	s0,s0,-592 # ffffffffc02057b8 <best_fit_pmm_manager+0x50>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a10:	02800793          	li	a5,40
ffffffffc0201a14:	02800513          	li	a0,40
ffffffffc0201a18:	00140a13          	addi	s4,s0,1
ffffffffc0201a1c:	bd6d                	j	ffffffffc02018d6 <vprintfmt+0x204>
ffffffffc0201a1e:	00004a17          	auipc	s4,0x4
ffffffffc0201a22:	d9ba0a13          	addi	s4,s4,-613 # ffffffffc02057b9 <best_fit_pmm_manager+0x51>
ffffffffc0201a26:	02800513          	li	a0,40
ffffffffc0201a2a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201a2e:	05e00413          	li	s0,94
ffffffffc0201a32:	b565                	j	ffffffffc02018da <vprintfmt+0x208>

ffffffffc0201a34 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a34:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201a36:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a3a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a3c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201a3e:	ec06                	sd	ra,24(sp)
ffffffffc0201a40:	f83a                	sd	a4,48(sp)
ffffffffc0201a42:	fc3e                	sd	a5,56(sp)
ffffffffc0201a44:	e0c2                	sd	a6,64(sp)
ffffffffc0201a46:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a48:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a4a:	c89ff0ef          	jal	ra,ffffffffc02016d2 <vprintfmt>
}
ffffffffc0201a4e:	60e2                	ld	ra,24(sp)
ffffffffc0201a50:	6161                	addi	sp,sp,80
ffffffffc0201a52:	8082                	ret

ffffffffc0201a54 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201a54:	4781                	li	a5,0
ffffffffc0201a56:	00006717          	auipc	a4,0x6
ffffffffc0201a5a:	5c273703          	ld	a4,1474(a4) # ffffffffc0208018 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201a5e:	88ba                	mv	a7,a4
ffffffffc0201a60:	852a                	mv	a0,a0
ffffffffc0201a62:	85be                	mv	a1,a5
ffffffffc0201a64:	863e                	mv	a2,a5
ffffffffc0201a66:	00000073          	ecall
ffffffffc0201a6a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201a6c:	8082                	ret
