
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00014297          	auipc	t0,0x14
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0214000 <boot_hartid>
ffffffffc020000c:	00014297          	auipc	t0,0x14
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0214008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02132b7          	lui	t0,0xc0213
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0213137          	lui	sp,0xc0213
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
ffffffffc020004a:	00091517          	auipc	a0,0x91
ffffffffc020004e:	01650513          	addi	a0,a0,22 # ffffffffc0291060 <buf>
ffffffffc0200052:	00097617          	auipc	a2,0x97
ffffffffc0200056:	8be60613          	addi	a2,a2,-1858 # ffffffffc0296910 <end>
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0212ff0 <bootstack+0x1ff0>
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
ffffffffc0200060:	e406                	sd	ra,8(sp)
ffffffffc0200062:	3840b0ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0200066:	149000ef          	jal	ffffffffc02009ae <cons_init>
ffffffffc020006a:	0000c597          	auipc	a1,0xc
ffffffffc020006e:	86e58593          	addi	a1,a1,-1938 # ffffffffc020b8d8 <etext+0x2>
ffffffffc0200072:	0000c517          	auipc	a0,0xc
ffffffffc0200076:	88650513          	addi	a0,a0,-1914 # ffffffffc020b8f8 <etext+0x22>
ffffffffc020007a:	0ae000ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020007e:	25c000ef          	jal	ffffffffc02002da <print_kerninfo>
ffffffffc0200082:	478000ef          	jal	ffffffffc02004fa <dtb_init>
ffffffffc0200086:	2fe030ef          	jal	ffffffffc0203384 <pmm_init>
ffffffffc020008a:	25b000ef          	jal	ffffffffc0200ae4 <pic_init>
ffffffffc020008e:	47b000ef          	jal	ffffffffc0200d08 <idt_init>
ffffffffc0200092:	560010ef          	jal	ffffffffc02015f2 <vmm_init>
ffffffffc0200096:	2f0070ef          	jal	ffffffffc0207386 <sched_init>
ffffffffc020009a:	04a070ef          	jal	ffffffffc02070e4 <proc_init>
ffffffffc020009e:	249000ef          	jal	ffffffffc0200ae6 <ide_init>
ffffffffc02000a2:	009050ef          	jal	ffffffffc02058aa <fs_init>
ffffffffc02000a6:	0bf000ef          	jal	ffffffffc0200964 <clock_init>
ffffffffc02000aa:	453000ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc02000ae:	20a070ef          	jal	ffffffffc02072b8 <cpu_idle>

ffffffffc02000b2 <strdup>:
ffffffffc02000b2:	7179                	addi	sp,sp,-48
ffffffffc02000b4:	f406                	sd	ra,40(sp)
ffffffffc02000b6:	f022                	sd	s0,32(sp)
ffffffffc02000b8:	ec26                	sd	s1,24(sp)
ffffffffc02000ba:	84aa                	mv	s1,a0
ffffffffc02000bc:	2760b0ef          	jal	ffffffffc020b332 <strlen>
ffffffffc02000c0:	842a                	mv	s0,a0
ffffffffc02000c2:	0505                	addi	a0,a0,1
ffffffffc02000c4:	479010ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc02000c8:	87aa                	mv	a5,a0
ffffffffc02000ca:	c911                	beqz	a0,ffffffffc02000de <strdup+0x2c>
ffffffffc02000cc:	8622                	mv	a2,s0
ffffffffc02000ce:	85a6                	mv	a1,s1
ffffffffc02000d0:	e42a                	sd	a0,8(sp)
ffffffffc02000d2:	3640b0ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc02000d6:	67a2                	ld	a5,8(sp)
ffffffffc02000d8:	943e                	add	s0,s0,a5
ffffffffc02000da:	00040023          	sb	zero,0(s0)
ffffffffc02000de:	70a2                	ld	ra,40(sp)
ffffffffc02000e0:	7402                	ld	s0,32(sp)
ffffffffc02000e2:	64e2                	ld	s1,24(sp)
ffffffffc02000e4:	853e                	mv	a0,a5
ffffffffc02000e6:	6145                	addi	sp,sp,48
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputch>:
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	ec06                	sd	ra,24(sp)
ffffffffc02000ee:	e42e                	sd	a1,8(sp)
ffffffffc02000f0:	0cd000ef          	jal	ffffffffc02009bc <cons_putc>
ffffffffc02000f4:	65a2                	ld	a1,8(sp)
ffffffffc02000f6:	60e2                	ld	ra,24(sp)
ffffffffc02000f8:	419c                	lw	a5,0(a1)
ffffffffc02000fa:	2785                	addiw	a5,a5,1
ffffffffc02000fc:	c19c                	sw	a5,0(a1)
ffffffffc02000fe:	6105                	addi	sp,sp,32
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <vcprintf>:
ffffffffc0200102:	1101                	addi	sp,sp,-32
ffffffffc0200104:	872e                	mv	a4,a1
ffffffffc0200106:	75dd                	lui	a1,0xffff7
ffffffffc0200108:	86aa                	mv	a3,a0
ffffffffc020010a:	0070                	addi	a2,sp,12
ffffffffc020010c:	00000517          	auipc	a0,0x0
ffffffffc0200110:	fde50513          	addi	a0,a0,-34 # ffffffffc02000ea <cputch>
ffffffffc0200114:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0200118:	ec06                	sd	ra,24(sp)
ffffffffc020011a:	c602                	sw	zero,12(sp)
ffffffffc020011c:	3bc0b0ef          	jal	ffffffffc020b4d8 <vprintfmt>
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	4532                	lw	a0,12(sp)
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret

ffffffffc0200128 <cprintf>:
ffffffffc0200128:	711d                	addi	sp,sp,-96
ffffffffc020012a:	02810313          	addi	t1,sp,40
ffffffffc020012e:	f42e                	sd	a1,40(sp)
ffffffffc0200130:	75dd                	lui	a1,0xffff7
ffffffffc0200132:	f832                	sd	a2,48(sp)
ffffffffc0200134:	fc36                	sd	a3,56(sp)
ffffffffc0200136:	e0ba                	sd	a4,64(sp)
ffffffffc0200138:	86aa                	mv	a3,a0
ffffffffc020013a:	0050                	addi	a2,sp,4
ffffffffc020013c:	00000517          	auipc	a0,0x0
ffffffffc0200140:	fae50513          	addi	a0,a0,-82 # ffffffffc02000ea <cputch>
ffffffffc0200144:	871a                	mv	a4,t1
ffffffffc0200146:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020014a:	ec06                	sd	ra,24(sp)
ffffffffc020014c:	e4be                	sd	a5,72(sp)
ffffffffc020014e:	e8c2                	sd	a6,80(sp)
ffffffffc0200150:	ecc6                	sd	a7,88(sp)
ffffffffc0200152:	c202                	sw	zero,4(sp)
ffffffffc0200154:	e41a                	sd	t1,8(sp)
ffffffffc0200156:	3820b0ef          	jal	ffffffffc020b4d8 <vprintfmt>
ffffffffc020015a:	60e2                	ld	ra,24(sp)
ffffffffc020015c:	4512                	lw	a0,4(sp)
ffffffffc020015e:	6125                	addi	sp,sp,96
ffffffffc0200160:	8082                	ret

ffffffffc0200162 <cputchar>:
ffffffffc0200162:	05b0006f          	j	ffffffffc02009bc <cons_putc>

ffffffffc0200166 <getchar>:
ffffffffc0200166:	1141                	addi	sp,sp,-16
ffffffffc0200168:	e406                	sd	ra,8(sp)
ffffffffc020016a:	0bb000ef          	jal	ffffffffc0200a24 <cons_getc>
ffffffffc020016e:	dd75                	beqz	a0,ffffffffc020016a <getchar+0x4>
ffffffffc0200170:	60a2                	ld	ra,8(sp)
ffffffffc0200172:	0141                	addi	sp,sp,16
ffffffffc0200174:	8082                	ret

ffffffffc0200176 <readline>:
ffffffffc0200176:	7179                	addi	sp,sp,-48
ffffffffc0200178:	f406                	sd	ra,40(sp)
ffffffffc020017a:	f022                	sd	s0,32(sp)
ffffffffc020017c:	ec26                	sd	s1,24(sp)
ffffffffc020017e:	e84a                	sd	s2,16(sp)
ffffffffc0200180:	e44e                	sd	s3,8(sp)
ffffffffc0200182:	c901                	beqz	a0,ffffffffc0200192 <readline+0x1c>
ffffffffc0200184:	85aa                	mv	a1,a0
ffffffffc0200186:	0000b517          	auipc	a0,0xb
ffffffffc020018a:	77a50513          	addi	a0,a0,1914 # ffffffffc020b900 <etext+0x2a>
ffffffffc020018e:	f9bff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200192:	4481                	li	s1,0
ffffffffc0200194:	497d                	li	s2,31
ffffffffc0200196:	00091997          	auipc	s3,0x91
ffffffffc020019a:	eca98993          	addi	s3,s3,-310 # ffffffffc0291060 <buf>
ffffffffc020019e:	fc9ff0ef          	jal	ffffffffc0200166 <getchar>
ffffffffc02001a2:	842a                	mv	s0,a0
ffffffffc02001a4:	ff850793          	addi	a5,a0,-8
ffffffffc02001a8:	3ff4a713          	slti	a4,s1,1023
ffffffffc02001ac:	ff650693          	addi	a3,a0,-10
ffffffffc02001b0:	ff350613          	addi	a2,a0,-13
ffffffffc02001b4:	02054963          	bltz	a0,ffffffffc02001e6 <readline+0x70>
ffffffffc02001b8:	02a95f63          	bge	s2,a0,ffffffffc02001f6 <readline+0x80>
ffffffffc02001bc:	cf0d                	beqz	a4,ffffffffc02001f6 <readline+0x80>
ffffffffc02001be:	fa5ff0ef          	jal	ffffffffc0200162 <cputchar>
ffffffffc02001c2:	009987b3          	add	a5,s3,s1
ffffffffc02001c6:	00878023          	sb	s0,0(a5)
ffffffffc02001ca:	2485                	addiw	s1,s1,1
ffffffffc02001cc:	f9bff0ef          	jal	ffffffffc0200166 <getchar>
ffffffffc02001d0:	842a                	mv	s0,a0
ffffffffc02001d2:	ff850793          	addi	a5,a0,-8
ffffffffc02001d6:	3ff4a713          	slti	a4,s1,1023
ffffffffc02001da:	ff650693          	addi	a3,a0,-10
ffffffffc02001de:	ff350613          	addi	a2,a0,-13
ffffffffc02001e2:	fc055be3          	bgez	a0,ffffffffc02001b8 <readline+0x42>
ffffffffc02001e6:	70a2                	ld	ra,40(sp)
ffffffffc02001e8:	7402                	ld	s0,32(sp)
ffffffffc02001ea:	64e2                	ld	s1,24(sp)
ffffffffc02001ec:	6942                	ld	s2,16(sp)
ffffffffc02001ee:	69a2                	ld	s3,8(sp)
ffffffffc02001f0:	4501                	li	a0,0
ffffffffc02001f2:	6145                	addi	sp,sp,48
ffffffffc02001f4:	8082                	ret
ffffffffc02001f6:	eb81                	bnez	a5,ffffffffc0200206 <readline+0x90>
ffffffffc02001f8:	4521                	li	a0,8
ffffffffc02001fa:	00905663          	blez	s1,ffffffffc0200206 <readline+0x90>
ffffffffc02001fe:	f65ff0ef          	jal	ffffffffc0200162 <cputchar>
ffffffffc0200202:	34fd                	addiw	s1,s1,-1
ffffffffc0200204:	bf69                	j	ffffffffc020019e <readline+0x28>
ffffffffc0200206:	c291                	beqz	a3,ffffffffc020020a <readline+0x94>
ffffffffc0200208:	fa59                	bnez	a2,ffffffffc020019e <readline+0x28>
ffffffffc020020a:	8522                	mv	a0,s0
ffffffffc020020c:	f57ff0ef          	jal	ffffffffc0200162 <cputchar>
ffffffffc0200210:	00091517          	auipc	a0,0x91
ffffffffc0200214:	e5050513          	addi	a0,a0,-432 # ffffffffc0291060 <buf>
ffffffffc0200218:	94aa                	add	s1,s1,a0
ffffffffc020021a:	00048023          	sb	zero,0(s1)
ffffffffc020021e:	70a2                	ld	ra,40(sp)
ffffffffc0200220:	7402                	ld	s0,32(sp)
ffffffffc0200222:	64e2                	ld	s1,24(sp)
ffffffffc0200224:	6942                	ld	s2,16(sp)
ffffffffc0200226:	69a2                	ld	s3,8(sp)
ffffffffc0200228:	6145                	addi	sp,sp,48
ffffffffc020022a:	8082                	ret

ffffffffc020022c <__panic>:
ffffffffc020022c:	00096317          	auipc	t1,0x96
ffffffffc0200230:	63c33303          	ld	t1,1596(t1) # ffffffffc0296868 <is_panic>
ffffffffc0200234:	715d                	addi	sp,sp,-80
ffffffffc0200236:	ec06                	sd	ra,24(sp)
ffffffffc0200238:	f436                	sd	a3,40(sp)
ffffffffc020023a:	f83a                	sd	a4,48(sp)
ffffffffc020023c:	fc3e                	sd	a5,56(sp)
ffffffffc020023e:	e0c2                	sd	a6,64(sp)
ffffffffc0200240:	e4c6                	sd	a7,72(sp)
ffffffffc0200242:	02031e63          	bnez	t1,ffffffffc020027e <__panic+0x52>
ffffffffc0200246:	4705                	li	a4,1
ffffffffc0200248:	103c                	addi	a5,sp,40
ffffffffc020024a:	e822                	sd	s0,16(sp)
ffffffffc020024c:	8432                	mv	s0,a2
ffffffffc020024e:	862e                	mv	a2,a1
ffffffffc0200250:	85aa                	mv	a1,a0
ffffffffc0200252:	0000b517          	auipc	a0,0xb
ffffffffc0200256:	6b650513          	addi	a0,a0,1718 # ffffffffc020b908 <etext+0x32>
ffffffffc020025a:	00096697          	auipc	a3,0x96
ffffffffc020025e:	60e6b723          	sd	a4,1550(a3) # ffffffffc0296868 <is_panic>
ffffffffc0200262:	e43e                	sd	a5,8(sp)
ffffffffc0200264:	ec5ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200268:	65a2                	ld	a1,8(sp)
ffffffffc020026a:	8522                	mv	a0,s0
ffffffffc020026c:	e97ff0ef          	jal	ffffffffc0200102 <vcprintf>
ffffffffc0200270:	0000b517          	auipc	a0,0xb
ffffffffc0200274:	6b850513          	addi	a0,a0,1720 # ffffffffc020b928 <etext+0x52>
ffffffffc0200278:	eb1ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020027c:	6442                	ld	s0,16(sp)
ffffffffc020027e:	4501                	li	a0,0
ffffffffc0200280:	4581                	li	a1,0
ffffffffc0200282:	4601                	li	a2,0
ffffffffc0200284:	48a1                	li	a7,8
ffffffffc0200286:	00000073          	ecall
ffffffffc020028a:	279000ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc020028e:	4501                	li	a0,0
ffffffffc0200290:	14c000ef          	jal	ffffffffc02003dc <kmonitor>
ffffffffc0200294:	bfed                	j	ffffffffc020028e <__panic+0x62>

ffffffffc0200296 <__warn>:
ffffffffc0200296:	715d                	addi	sp,sp,-80
ffffffffc0200298:	e822                	sd	s0,16(sp)
ffffffffc020029a:	02810313          	addi	t1,sp,40
ffffffffc020029e:	8432                	mv	s0,a2
ffffffffc02002a0:	862e                	mv	a2,a1
ffffffffc02002a2:	85aa                	mv	a1,a0
ffffffffc02002a4:	0000b517          	auipc	a0,0xb
ffffffffc02002a8:	68c50513          	addi	a0,a0,1676 # ffffffffc020b930 <etext+0x5a>
ffffffffc02002ac:	ec06                	sd	ra,24(sp)
ffffffffc02002ae:	f436                	sd	a3,40(sp)
ffffffffc02002b0:	f83a                	sd	a4,48(sp)
ffffffffc02002b2:	fc3e                	sd	a5,56(sp)
ffffffffc02002b4:	e0c2                	sd	a6,64(sp)
ffffffffc02002b6:	e4c6                	sd	a7,72(sp)
ffffffffc02002b8:	e41a                	sd	t1,8(sp)
ffffffffc02002ba:	e6fff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02002be:	65a2                	ld	a1,8(sp)
ffffffffc02002c0:	8522                	mv	a0,s0
ffffffffc02002c2:	e41ff0ef          	jal	ffffffffc0200102 <vcprintf>
ffffffffc02002c6:	0000b517          	auipc	a0,0xb
ffffffffc02002ca:	66250513          	addi	a0,a0,1634 # ffffffffc020b928 <etext+0x52>
ffffffffc02002ce:	e5bff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02002d2:	60e2                	ld	ra,24(sp)
ffffffffc02002d4:	6442                	ld	s0,16(sp)
ffffffffc02002d6:	6161                	addi	sp,sp,80
ffffffffc02002d8:	8082                	ret

ffffffffc02002da <print_kerninfo>:
ffffffffc02002da:	1141                	addi	sp,sp,-16
ffffffffc02002dc:	0000b517          	auipc	a0,0xb
ffffffffc02002e0:	67450513          	addi	a0,a0,1652 # ffffffffc020b950 <etext+0x7a>
ffffffffc02002e4:	e406                	sd	ra,8(sp)
ffffffffc02002e6:	e43ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02002ea:	00000597          	auipc	a1,0x0
ffffffffc02002ee:	d6058593          	addi	a1,a1,-672 # ffffffffc020004a <kern_init>
ffffffffc02002f2:	0000b517          	auipc	a0,0xb
ffffffffc02002f6:	67e50513          	addi	a0,a0,1662 # ffffffffc020b970 <etext+0x9a>
ffffffffc02002fa:	e2fff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02002fe:	0000b597          	auipc	a1,0xb
ffffffffc0200302:	5d858593          	addi	a1,a1,1496 # ffffffffc020b8d6 <etext>
ffffffffc0200306:	0000b517          	auipc	a0,0xb
ffffffffc020030a:	68a50513          	addi	a0,a0,1674 # ffffffffc020b990 <etext+0xba>
ffffffffc020030e:	e1bff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200312:	00091597          	auipc	a1,0x91
ffffffffc0200316:	d4e58593          	addi	a1,a1,-690 # ffffffffc0291060 <buf>
ffffffffc020031a:	0000b517          	auipc	a0,0xb
ffffffffc020031e:	69650513          	addi	a0,a0,1686 # ffffffffc020b9b0 <etext+0xda>
ffffffffc0200322:	e07ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200326:	00096597          	auipc	a1,0x96
ffffffffc020032a:	5ea58593          	addi	a1,a1,1514 # ffffffffc0296910 <end>
ffffffffc020032e:	0000b517          	auipc	a0,0xb
ffffffffc0200332:	6a250513          	addi	a0,a0,1698 # ffffffffc020b9d0 <etext+0xfa>
ffffffffc0200336:	df3ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020033a:	00000717          	auipc	a4,0x0
ffffffffc020033e:	d1070713          	addi	a4,a4,-752 # ffffffffc020004a <kern_init>
ffffffffc0200342:	00097797          	auipc	a5,0x97
ffffffffc0200346:	9cd78793          	addi	a5,a5,-1587 # ffffffffc0296d0f <end+0x3ff>
ffffffffc020034a:	8f99                	sub	a5,a5,a4
ffffffffc020034c:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200350:	60a2                	ld	ra,8(sp)
ffffffffc0200352:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200356:	95be                	add	a1,a1,a5
ffffffffc0200358:	85a9                	srai	a1,a1,0xa
ffffffffc020035a:	0000b517          	auipc	a0,0xb
ffffffffc020035e:	69650513          	addi	a0,a0,1686 # ffffffffc020b9f0 <etext+0x11a>
ffffffffc0200362:	0141                	addi	sp,sp,16
ffffffffc0200364:	b3d1                	j	ffffffffc0200128 <cprintf>

ffffffffc0200366 <print_stackframe>:
ffffffffc0200366:	1141                	addi	sp,sp,-16
ffffffffc0200368:	0000b617          	auipc	a2,0xb
ffffffffc020036c:	6b860613          	addi	a2,a2,1720 # ffffffffc020ba20 <etext+0x14a>
ffffffffc0200370:	04e00593          	li	a1,78
ffffffffc0200374:	0000b517          	auipc	a0,0xb
ffffffffc0200378:	6c450513          	addi	a0,a0,1732 # ffffffffc020ba38 <etext+0x162>
ffffffffc020037c:	e406                	sd	ra,8(sp)
ffffffffc020037e:	eafff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200382 <mon_help>:
ffffffffc0200382:	1101                	addi	sp,sp,-32
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	e426                	sd	s1,8(sp)
ffffffffc0200388:	ec06                	sd	ra,24(sp)
ffffffffc020038a:	0000f417          	auipc	s0,0xf
ffffffffc020038e:	b6640413          	addi	s0,s0,-1178 # ffffffffc020eef0 <commands>
ffffffffc0200392:	0000f497          	auipc	s1,0xf
ffffffffc0200396:	ba648493          	addi	s1,s1,-1114 # ffffffffc020ef38 <commands+0x48>
ffffffffc020039a:	6410                	ld	a2,8(s0)
ffffffffc020039c:	600c                	ld	a1,0(s0)
ffffffffc020039e:	0000b517          	auipc	a0,0xb
ffffffffc02003a2:	6b250513          	addi	a0,a0,1714 # ffffffffc020ba50 <etext+0x17a>
ffffffffc02003a6:	0461                	addi	s0,s0,24
ffffffffc02003a8:	d81ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02003ac:	fe9417e3          	bne	s0,s1,ffffffffc020039a <mon_help+0x18>
ffffffffc02003b0:	60e2                	ld	ra,24(sp)
ffffffffc02003b2:	6442                	ld	s0,16(sp)
ffffffffc02003b4:	64a2                	ld	s1,8(sp)
ffffffffc02003b6:	4501                	li	a0,0
ffffffffc02003b8:	6105                	addi	sp,sp,32
ffffffffc02003ba:	8082                	ret

ffffffffc02003bc <mon_kerninfo>:
ffffffffc02003bc:	1141                	addi	sp,sp,-16
ffffffffc02003be:	e406                	sd	ra,8(sp)
ffffffffc02003c0:	f1bff0ef          	jal	ffffffffc02002da <print_kerninfo>
ffffffffc02003c4:	60a2                	ld	ra,8(sp)
ffffffffc02003c6:	4501                	li	a0,0
ffffffffc02003c8:	0141                	addi	sp,sp,16
ffffffffc02003ca:	8082                	ret

ffffffffc02003cc <mon_backtrace>:
ffffffffc02003cc:	1141                	addi	sp,sp,-16
ffffffffc02003ce:	e406                	sd	ra,8(sp)
ffffffffc02003d0:	f97ff0ef          	jal	ffffffffc0200366 <print_stackframe>
ffffffffc02003d4:	60a2                	ld	ra,8(sp)
ffffffffc02003d6:	4501                	li	a0,0
ffffffffc02003d8:	0141                	addi	sp,sp,16
ffffffffc02003da:	8082                	ret

ffffffffc02003dc <kmonitor>:
ffffffffc02003dc:	7131                	addi	sp,sp,-192
ffffffffc02003de:	e952                	sd	s4,144(sp)
ffffffffc02003e0:	8a2a                	mv	s4,a0
ffffffffc02003e2:	0000b517          	auipc	a0,0xb
ffffffffc02003e6:	67e50513          	addi	a0,a0,1662 # ffffffffc020ba60 <etext+0x18a>
ffffffffc02003ea:	fd06                	sd	ra,184(sp)
ffffffffc02003ec:	f922                	sd	s0,176(sp)
ffffffffc02003ee:	f526                	sd	s1,168(sp)
ffffffffc02003f0:	ed4e                	sd	s3,152(sp)
ffffffffc02003f2:	e556                	sd	s5,136(sp)
ffffffffc02003f4:	e15a                	sd	s6,128(sp)
ffffffffc02003f6:	d33ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02003fa:	0000b517          	auipc	a0,0xb
ffffffffc02003fe:	68e50513          	addi	a0,a0,1678 # ffffffffc020ba88 <etext+0x1b2>
ffffffffc0200402:	d27ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200406:	000a0563          	beqz	s4,ffffffffc0200410 <kmonitor+0x34>
ffffffffc020040a:	8552                	mv	a0,s4
ffffffffc020040c:	2e5000ef          	jal	ffffffffc0200ef0 <print_trapframe>
ffffffffc0200410:	0000fa97          	auipc	s5,0xf
ffffffffc0200414:	ae0a8a93          	addi	s5,s5,-1312 # ffffffffc020eef0 <commands>
ffffffffc0200418:	49bd                	li	s3,15
ffffffffc020041a:	0000b517          	auipc	a0,0xb
ffffffffc020041e:	69650513          	addi	a0,a0,1686 # ffffffffc020bab0 <etext+0x1da>
ffffffffc0200422:	d55ff0ef          	jal	ffffffffc0200176 <readline>
ffffffffc0200426:	842a                	mv	s0,a0
ffffffffc0200428:	d96d                	beqz	a0,ffffffffc020041a <kmonitor+0x3e>
ffffffffc020042a:	00054583          	lbu	a1,0(a0)
ffffffffc020042e:	4481                	li	s1,0
ffffffffc0200430:	e99d                	bnez	a1,ffffffffc0200466 <kmonitor+0x8a>
ffffffffc0200432:	8b26                	mv	s6,s1
ffffffffc0200434:	fe0b03e3          	beqz	s6,ffffffffc020041a <kmonitor+0x3e>
ffffffffc0200438:	0000f497          	auipc	s1,0xf
ffffffffc020043c:	ab848493          	addi	s1,s1,-1352 # ffffffffc020eef0 <commands>
ffffffffc0200440:	4401                	li	s0,0
ffffffffc0200442:	6582                	ld	a1,0(sp)
ffffffffc0200444:	6088                	ld	a0,0(s1)
ffffffffc0200446:	7330a0ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc020044a:	478d                	li	a5,3
ffffffffc020044c:	c149                	beqz	a0,ffffffffc02004ce <kmonitor+0xf2>
ffffffffc020044e:	2405                	addiw	s0,s0,1
ffffffffc0200450:	04e1                	addi	s1,s1,24
ffffffffc0200452:	fef418e3          	bne	s0,a5,ffffffffc0200442 <kmonitor+0x66>
ffffffffc0200456:	6582                	ld	a1,0(sp)
ffffffffc0200458:	0000b517          	auipc	a0,0xb
ffffffffc020045c:	68850513          	addi	a0,a0,1672 # ffffffffc020bae0 <etext+0x20a>
ffffffffc0200460:	cc9ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200464:	bf5d                	j	ffffffffc020041a <kmonitor+0x3e>
ffffffffc0200466:	0000b517          	auipc	a0,0xb
ffffffffc020046a:	65250513          	addi	a0,a0,1618 # ffffffffc020bab8 <etext+0x1e2>
ffffffffc020046e:	7670a0ef          	jal	ffffffffc020b3d4 <strchr>
ffffffffc0200472:	c901                	beqz	a0,ffffffffc0200482 <kmonitor+0xa6>
ffffffffc0200474:	00144583          	lbu	a1,1(s0)
ffffffffc0200478:	00040023          	sb	zero,0(s0)
ffffffffc020047c:	0405                	addi	s0,s0,1
ffffffffc020047e:	d9d5                	beqz	a1,ffffffffc0200432 <kmonitor+0x56>
ffffffffc0200480:	b7dd                	j	ffffffffc0200466 <kmonitor+0x8a>
ffffffffc0200482:	00044783          	lbu	a5,0(s0)
ffffffffc0200486:	d7d5                	beqz	a5,ffffffffc0200432 <kmonitor+0x56>
ffffffffc0200488:	03348b63          	beq	s1,s3,ffffffffc02004be <kmonitor+0xe2>
ffffffffc020048c:	00349793          	slli	a5,s1,0x3
ffffffffc0200490:	978a                	add	a5,a5,sp
ffffffffc0200492:	e380                	sd	s0,0(a5)
ffffffffc0200494:	00044583          	lbu	a1,0(s0)
ffffffffc0200498:	2485                	addiw	s1,s1,1
ffffffffc020049a:	8b26                	mv	s6,s1
ffffffffc020049c:	e591                	bnez	a1,ffffffffc02004a8 <kmonitor+0xcc>
ffffffffc020049e:	bf59                	j	ffffffffc0200434 <kmonitor+0x58>
ffffffffc02004a0:	00144583          	lbu	a1,1(s0)
ffffffffc02004a4:	0405                	addi	s0,s0,1
ffffffffc02004a6:	d5d1                	beqz	a1,ffffffffc0200432 <kmonitor+0x56>
ffffffffc02004a8:	0000b517          	auipc	a0,0xb
ffffffffc02004ac:	61050513          	addi	a0,a0,1552 # ffffffffc020bab8 <etext+0x1e2>
ffffffffc02004b0:	7250a0ef          	jal	ffffffffc020b3d4 <strchr>
ffffffffc02004b4:	d575                	beqz	a0,ffffffffc02004a0 <kmonitor+0xc4>
ffffffffc02004b6:	00044583          	lbu	a1,0(s0)
ffffffffc02004ba:	dda5                	beqz	a1,ffffffffc0200432 <kmonitor+0x56>
ffffffffc02004bc:	b76d                	j	ffffffffc0200466 <kmonitor+0x8a>
ffffffffc02004be:	45c1                	li	a1,16
ffffffffc02004c0:	0000b517          	auipc	a0,0xb
ffffffffc02004c4:	60050513          	addi	a0,a0,1536 # ffffffffc020bac0 <etext+0x1ea>
ffffffffc02004c8:	c61ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02004cc:	b7c1                	j	ffffffffc020048c <kmonitor+0xb0>
ffffffffc02004ce:	00141793          	slli	a5,s0,0x1
ffffffffc02004d2:	97a2                	add	a5,a5,s0
ffffffffc02004d4:	078e                	slli	a5,a5,0x3
ffffffffc02004d6:	97d6                	add	a5,a5,s5
ffffffffc02004d8:	6b9c                	ld	a5,16(a5)
ffffffffc02004da:	fffb051b          	addiw	a0,s6,-1
ffffffffc02004de:	8652                	mv	a2,s4
ffffffffc02004e0:	002c                	addi	a1,sp,8
ffffffffc02004e2:	9782                	jalr	a5
ffffffffc02004e4:	f2055be3          	bgez	a0,ffffffffc020041a <kmonitor+0x3e>
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
ffffffffc02004fa:	7179                	addi	sp,sp,-48
ffffffffc02004fc:	0000b517          	auipc	a0,0xb
ffffffffc0200500:	68c50513          	addi	a0,a0,1676 # ffffffffc020bb88 <etext+0x2b2>
ffffffffc0200504:	f406                	sd	ra,40(sp)
ffffffffc0200506:	f022                	sd	s0,32(sp)
ffffffffc0200508:	c21ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020050c:	00014597          	auipc	a1,0x14
ffffffffc0200510:	af45b583          	ld	a1,-1292(a1) # ffffffffc0214000 <boot_hartid>
ffffffffc0200514:	0000b517          	auipc	a0,0xb
ffffffffc0200518:	68450513          	addi	a0,a0,1668 # ffffffffc020bb98 <etext+0x2c2>
ffffffffc020051c:	00014417          	auipc	s0,0x14
ffffffffc0200520:	aec40413          	addi	s0,s0,-1300 # ffffffffc0214008 <boot_dtb>
ffffffffc0200524:	c05ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200528:	600c                	ld	a1,0(s0)
ffffffffc020052a:	0000b517          	auipc	a0,0xb
ffffffffc020052e:	67e50513          	addi	a0,a0,1662 # ffffffffc020bba8 <etext+0x2d2>
ffffffffc0200532:	bf7ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200536:	6018                	ld	a4,0(s0)
ffffffffc0200538:	0000b517          	auipc	a0,0xb
ffffffffc020053c:	68850513          	addi	a0,a0,1672 # ffffffffc020bbc0 <etext+0x2ea>
ffffffffc0200540:	10070163          	beqz	a4,ffffffffc0200642 <dtb_init+0x148>
ffffffffc0200544:	57f5                	li	a5,-3
ffffffffc0200546:	07fa                	slli	a5,a5,0x1e
ffffffffc0200548:	973e                	add	a4,a4,a5
ffffffffc020054a:	431c                	lw	a5,0(a4)
ffffffffc020054c:	d00e06b7          	lui	a3,0xd00e0
ffffffffc0200550:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe495dd>
ffffffffc0200554:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200558:	0187961b          	slliw	a2,a5,0x18
ffffffffc020055c:	0187d51b          	srliw	a0,a5,0x18
ffffffffc0200560:	0ff5f593          	zext.b	a1,a1
ffffffffc0200564:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200568:	05c2                	slli	a1,a1,0x10
ffffffffc020056a:	8e49                	or	a2,a2,a0
ffffffffc020056c:	0ff7f793          	zext.b	a5,a5
ffffffffc0200570:	8dd1                	or	a1,a1,a2
ffffffffc0200572:	07a2                	slli	a5,a5,0x8
ffffffffc0200574:	8ddd                	or	a1,a1,a5
ffffffffc0200576:	00ff0837          	lui	a6,0xff0
ffffffffc020057a:	0cd59863          	bne	a1,a3,ffffffffc020064a <dtb_init+0x150>
ffffffffc020057e:	4710                	lw	a2,8(a4)
ffffffffc0200580:	4754                	lw	a3,12(a4)
ffffffffc0200582:	e84a                	sd	s2,16(sp)
ffffffffc0200584:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200588:	0086d79b          	srliw	a5,a3,0x8
ffffffffc020058c:	01865e1b          	srliw	t3,a2,0x18
ffffffffc0200590:	0186d89b          	srliw	a7,a3,0x18
ffffffffc0200594:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200598:	0186959b          	slliw	a1,a3,0x18
ffffffffc020059c:	0104141b          	slliw	s0,s0,0x10
ffffffffc02005a0:	0106561b          	srliw	a2,a2,0x10
ffffffffc02005a4:	0107979b          	slliw	a5,a5,0x10
ffffffffc02005a8:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02005ac:	01c56533          	or	a0,a0,t3
ffffffffc02005b0:	0115e5b3          	or	a1,a1,a7
ffffffffc02005b4:	01047433          	and	s0,s0,a6
ffffffffc02005b8:	0ff67613          	zext.b	a2,a2
ffffffffc02005bc:	0107f7b3          	and	a5,a5,a6
ffffffffc02005c0:	0ff6f693          	zext.b	a3,a3
ffffffffc02005c4:	8c49                	or	s0,s0,a0
ffffffffc02005c6:	0622                	slli	a2,a2,0x8
ffffffffc02005c8:	8fcd                	or	a5,a5,a1
ffffffffc02005ca:	06a2                	slli	a3,a3,0x8
ffffffffc02005cc:	8c51                	or	s0,s0,a2
ffffffffc02005ce:	8fd5                	or	a5,a5,a3
ffffffffc02005d0:	1402                	slli	s0,s0,0x20
ffffffffc02005d2:	1782                	slli	a5,a5,0x20
ffffffffc02005d4:	9001                	srli	s0,s0,0x20
ffffffffc02005d6:	9381                	srli	a5,a5,0x20
ffffffffc02005d8:	ec26                	sd	s1,24(sp)
ffffffffc02005da:	4301                	li	t1,0
ffffffffc02005dc:	488d                	li	a7,3
ffffffffc02005de:	943a                	add	s0,s0,a4
ffffffffc02005e0:	00e78933          	add	s2,a5,a4
ffffffffc02005e4:	4e05                	li	t3,1
ffffffffc02005e6:	4018                	lw	a4,0(s0)
ffffffffc02005e8:	0087579b          	srliw	a5,a4,0x8
ffffffffc02005ec:	0187169b          	slliw	a3,a4,0x18
ffffffffc02005f0:	0187561b          	srliw	a2,a4,0x18
ffffffffc02005f4:	0107979b          	slliw	a5,a5,0x10
ffffffffc02005f8:	0107571b          	srliw	a4,a4,0x10
ffffffffc02005fc:	0107f7b3          	and	a5,a5,a6
ffffffffc0200600:	8ed1                	or	a3,a3,a2
ffffffffc0200602:	0ff77713          	zext.b	a4,a4
ffffffffc0200606:	8fd5                	or	a5,a5,a3
ffffffffc0200608:	0722                	slli	a4,a4,0x8
ffffffffc020060a:	8fd9                	or	a5,a5,a4
ffffffffc020060c:	05178763          	beq	a5,a7,ffffffffc020065a <dtb_init+0x160>
ffffffffc0200610:	0411                	addi	s0,s0,4
ffffffffc0200612:	00f8e963          	bltu	a7,a5,ffffffffc0200624 <dtb_init+0x12a>
ffffffffc0200616:	07c78d63          	beq	a5,t3,ffffffffc0200690 <dtb_init+0x196>
ffffffffc020061a:	4709                	li	a4,2
ffffffffc020061c:	00e79763          	bne	a5,a4,ffffffffc020062a <dtb_init+0x130>
ffffffffc0200620:	4301                	li	t1,0
ffffffffc0200622:	b7d1                	j	ffffffffc02005e6 <dtb_init+0xec>
ffffffffc0200624:	4711                	li	a4,4
ffffffffc0200626:	fce780e3          	beq	a5,a4,ffffffffc02005e6 <dtb_init+0xec>
ffffffffc020062a:	0000b517          	auipc	a0,0xb
ffffffffc020062e:	65e50513          	addi	a0,a0,1630 # ffffffffc020bc88 <etext+0x3b2>
ffffffffc0200632:	af7ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200636:	64e2                	ld	s1,24(sp)
ffffffffc0200638:	6942                	ld	s2,16(sp)
ffffffffc020063a:	0000b517          	auipc	a0,0xb
ffffffffc020063e:	68650513          	addi	a0,a0,1670 # ffffffffc020bcc0 <etext+0x3ea>
ffffffffc0200642:	7402                	ld	s0,32(sp)
ffffffffc0200644:	70a2                	ld	ra,40(sp)
ffffffffc0200646:	6145                	addi	sp,sp,48
ffffffffc0200648:	b4c5                	j	ffffffffc0200128 <cprintf>
ffffffffc020064a:	7402                	ld	s0,32(sp)
ffffffffc020064c:	70a2                	ld	ra,40(sp)
ffffffffc020064e:	0000b517          	auipc	a0,0xb
ffffffffc0200652:	59250513          	addi	a0,a0,1426 # ffffffffc020bbe0 <etext+0x30a>
ffffffffc0200656:	6145                	addi	sp,sp,48
ffffffffc0200658:	bcc1                	j	ffffffffc0200128 <cprintf>
ffffffffc020065a:	4058                	lw	a4,4(s0)
ffffffffc020065c:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200660:	0187169b          	slliw	a3,a4,0x18
ffffffffc0200664:	0187561b          	srliw	a2,a4,0x18
ffffffffc0200668:	0107979b          	slliw	a5,a5,0x10
ffffffffc020066c:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200670:	0107f7b3          	and	a5,a5,a6
ffffffffc0200674:	8ed1                	or	a3,a3,a2
ffffffffc0200676:	0ff77713          	zext.b	a4,a4
ffffffffc020067a:	8fd5                	or	a5,a5,a3
ffffffffc020067c:	0722                	slli	a4,a4,0x8
ffffffffc020067e:	8fd9                	or	a5,a5,a4
ffffffffc0200680:	04031463          	bnez	t1,ffffffffc02006c8 <dtb_init+0x1ce>
ffffffffc0200684:	1782                	slli	a5,a5,0x20
ffffffffc0200686:	9381                	srli	a5,a5,0x20
ffffffffc0200688:	043d                	addi	s0,s0,15
ffffffffc020068a:	943e                	add	s0,s0,a5
ffffffffc020068c:	9871                	andi	s0,s0,-4
ffffffffc020068e:	bfa1                	j	ffffffffc02005e6 <dtb_init+0xec>
ffffffffc0200690:	8522                	mv	a0,s0
ffffffffc0200692:	e01a                	sd	t1,0(sp)
ffffffffc0200694:	49f0a0ef          	jal	ffffffffc020b332 <strlen>
ffffffffc0200698:	84aa                	mv	s1,a0
ffffffffc020069a:	4619                	li	a2,6
ffffffffc020069c:	8522                	mv	a0,s0
ffffffffc020069e:	0000b597          	auipc	a1,0xb
ffffffffc02006a2:	56a58593          	addi	a1,a1,1386 # ffffffffc020bc08 <etext+0x332>
ffffffffc02006a6:	5070a0ef          	jal	ffffffffc020b3ac <strncmp>
ffffffffc02006aa:	6302                	ld	t1,0(sp)
ffffffffc02006ac:	0411                	addi	s0,s0,4
ffffffffc02006ae:	0004879b          	sext.w	a5,s1
ffffffffc02006b2:	943e                	add	s0,s0,a5
ffffffffc02006b4:	00153513          	seqz	a0,a0
ffffffffc02006b8:	9871                	andi	s0,s0,-4
ffffffffc02006ba:	00a36333          	or	t1,t1,a0
ffffffffc02006be:	00ff0837          	lui	a6,0xff0
ffffffffc02006c2:	488d                	li	a7,3
ffffffffc02006c4:	4e05                	li	t3,1
ffffffffc02006c6:	b705                	j	ffffffffc02005e6 <dtb_init+0xec>
ffffffffc02006c8:	4418                	lw	a4,8(s0)
ffffffffc02006ca:	0000b597          	auipc	a1,0xb
ffffffffc02006ce:	54658593          	addi	a1,a1,1350 # ffffffffc020bc10 <etext+0x33a>
ffffffffc02006d2:	e43e                	sd	a5,8(sp)
ffffffffc02006d4:	0087551b          	srliw	a0,a4,0x8
ffffffffc02006d8:	0187561b          	srliw	a2,a4,0x18
ffffffffc02006dc:	0187169b          	slliw	a3,a4,0x18
ffffffffc02006e0:	0105151b          	slliw	a0,a0,0x10
ffffffffc02006e4:	0107571b          	srliw	a4,a4,0x10
ffffffffc02006e8:	01057533          	and	a0,a0,a6
ffffffffc02006ec:	8ed1                	or	a3,a3,a2
ffffffffc02006ee:	0ff77713          	zext.b	a4,a4
ffffffffc02006f2:	0722                	slli	a4,a4,0x8
ffffffffc02006f4:	8d55                	or	a0,a0,a3
ffffffffc02006f6:	8d59                	or	a0,a0,a4
ffffffffc02006f8:	1502                	slli	a0,a0,0x20
ffffffffc02006fa:	9101                	srli	a0,a0,0x20
ffffffffc02006fc:	954a                	add	a0,a0,s2
ffffffffc02006fe:	e01a                	sd	t1,0(sp)
ffffffffc0200700:	4790a0ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc0200704:	67a2                	ld	a5,8(sp)
ffffffffc0200706:	473d                	li	a4,15
ffffffffc0200708:	6302                	ld	t1,0(sp)
ffffffffc020070a:	00ff0837          	lui	a6,0xff0
ffffffffc020070e:	488d                	li	a7,3
ffffffffc0200710:	4e05                	li	t3,1
ffffffffc0200712:	f6f779e3          	bgeu	a4,a5,ffffffffc0200684 <dtb_init+0x18a>
ffffffffc0200716:	f53d                	bnez	a0,ffffffffc0200684 <dtb_init+0x18a>
ffffffffc0200718:	00c43683          	ld	a3,12(s0)
ffffffffc020071c:	01443703          	ld	a4,20(s0)
ffffffffc0200720:	0000b517          	auipc	a0,0xb
ffffffffc0200724:	4f850513          	addi	a0,a0,1272 # ffffffffc020bc18 <etext+0x342>
ffffffffc0200728:	4206d793          	srai	a5,a3,0x20
ffffffffc020072c:	0087d31b          	srliw	t1,a5,0x8
ffffffffc0200730:	00871f93          	slli	t6,a4,0x8
ffffffffc0200734:	42075893          	srai	a7,a4,0x20
ffffffffc0200738:	0187df1b          	srliw	t5,a5,0x18
ffffffffc020073c:	0187959b          	slliw	a1,a5,0x18
ffffffffc0200740:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200744:	0107d79b          	srliw	a5,a5,0x10
ffffffffc0200748:	420fd613          	srai	a2,t6,0x20
ffffffffc020074c:	0188de9b          	srliw	t4,a7,0x18
ffffffffc0200750:	01037333          	and	t1,t1,a6
ffffffffc0200754:	01889e1b          	slliw	t3,a7,0x18
ffffffffc0200758:	01e5e5b3          	or	a1,a1,t5
ffffffffc020075c:	0ff7f793          	zext.b	a5,a5
ffffffffc0200760:	01de6e33          	or	t3,t3,t4
ffffffffc0200764:	0065e5b3          	or	a1,a1,t1
ffffffffc0200768:	01067633          	and	a2,a2,a6
ffffffffc020076c:	0086d31b          	srliw	t1,a3,0x8
ffffffffc0200770:	0087541b          	srliw	s0,a4,0x8
ffffffffc0200774:	07a2                	slli	a5,a5,0x8
ffffffffc0200776:	0108d89b          	srliw	a7,a7,0x10
ffffffffc020077a:	0186df1b          	srliw	t5,a3,0x18
ffffffffc020077e:	01875e9b          	srliw	t4,a4,0x18
ffffffffc0200782:	8ddd                	or	a1,a1,a5
ffffffffc0200784:	01c66633          	or	a2,a2,t3
ffffffffc0200788:	0186979b          	slliw	a5,a3,0x18
ffffffffc020078c:	01871e1b          	slliw	t3,a4,0x18
ffffffffc0200790:	0ff8f893          	zext.b	a7,a7
ffffffffc0200794:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200798:	0106d69b          	srliw	a3,a3,0x10
ffffffffc020079c:	0104141b          	slliw	s0,s0,0x10
ffffffffc02007a0:	0107571b          	srliw	a4,a4,0x10
ffffffffc02007a4:	01037333          	and	t1,t1,a6
ffffffffc02007a8:	08a2                	slli	a7,a7,0x8
ffffffffc02007aa:	01e7e7b3          	or	a5,a5,t5
ffffffffc02007ae:	01047433          	and	s0,s0,a6
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
ffffffffc02007d2:	1582                	slli	a1,a1,0x20
ffffffffc02007d4:	1602                	slli	a2,a2,0x20
ffffffffc02007d6:	1782                	slli	a5,a5,0x20
ffffffffc02007d8:	9201                	srli	a2,a2,0x20
ffffffffc02007da:	9181                	srli	a1,a1,0x20
ffffffffc02007dc:	1402                	slli	s0,s0,0x20
ffffffffc02007de:	00b7e4b3          	or	s1,a5,a1
ffffffffc02007e2:	8c51                	or	s0,s0,a2
ffffffffc02007e4:	945ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02007e8:	85a6                	mv	a1,s1
ffffffffc02007ea:	0000b517          	auipc	a0,0xb
ffffffffc02007ee:	44e50513          	addi	a0,a0,1102 # ffffffffc020bc38 <etext+0x362>
ffffffffc02007f2:	937ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02007f6:	01445613          	srli	a2,s0,0x14
ffffffffc02007fa:	85a2                	mv	a1,s0
ffffffffc02007fc:	0000b517          	auipc	a0,0xb
ffffffffc0200800:	45450513          	addi	a0,a0,1108 # ffffffffc020bc50 <etext+0x37a>
ffffffffc0200804:	925ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200808:	009405b3          	add	a1,s0,s1
ffffffffc020080c:	15fd                	addi	a1,a1,-1
ffffffffc020080e:	0000b517          	auipc	a0,0xb
ffffffffc0200812:	46250513          	addi	a0,a0,1122 # ffffffffc020bc70 <etext+0x39a>
ffffffffc0200816:	913ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020081a:	00096797          	auipc	a5,0x96
ffffffffc020081e:	0497bf23          	sd	s1,94(a5) # ffffffffc0296878 <memory_base>
ffffffffc0200822:	00096797          	auipc	a5,0x96
ffffffffc0200826:	0487b723          	sd	s0,78(a5) # ffffffffc0296870 <memory_size>
ffffffffc020082a:	b531                	j	ffffffffc0200636 <dtb_init+0x13c>

ffffffffc020082c <get_memory_base>:
ffffffffc020082c:	00096517          	auipc	a0,0x96
ffffffffc0200830:	04c53503          	ld	a0,76(a0) # ffffffffc0296878 <memory_base>
ffffffffc0200834:	8082                	ret

ffffffffc0200836 <get_memory_size>:
ffffffffc0200836:	00096517          	auipc	a0,0x96
ffffffffc020083a:	03a53503          	ld	a0,58(a0) # ffffffffc0296870 <memory_size>
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <ramdisk_write>:
ffffffffc0200840:	00856783          	lwu	a5,8(a0)
ffffffffc0200844:	1141                	addi	sp,sp,-16
ffffffffc0200846:	e406                	sd	ra,8(sp)
ffffffffc0200848:	8f8d                	sub	a5,a5,a1
ffffffffc020084a:	8732                	mv	a4,a2
ffffffffc020084c:	00f6f363          	bgeu	a3,a5,ffffffffc0200852 <ramdisk_write+0x12>
ffffffffc0200850:	87b6                	mv	a5,a3
ffffffffc0200852:	6914                	ld	a3,16(a0)
ffffffffc0200854:	00959513          	slli	a0,a1,0x9
ffffffffc0200858:	00979613          	slli	a2,a5,0x9
ffffffffc020085c:	9536                	add	a0,a0,a3
ffffffffc020085e:	85ba                	mv	a1,a4
ffffffffc0200860:	3d70a0ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0200864:	60a2                	ld	ra,8(sp)
ffffffffc0200866:	4501                	li	a0,0
ffffffffc0200868:	0141                	addi	sp,sp,16
ffffffffc020086a:	8082                	ret

ffffffffc020086c <ramdisk_read>:
ffffffffc020086c:	00856783          	lwu	a5,8(a0)
ffffffffc0200870:	1141                	addi	sp,sp,-16
ffffffffc0200872:	e406                	sd	ra,8(sp)
ffffffffc0200874:	8f8d                	sub	a5,a5,a1
ffffffffc0200876:	872a                	mv	a4,a0
ffffffffc0200878:	8532                	mv	a0,a2
ffffffffc020087a:	00f6f363          	bgeu	a3,a5,ffffffffc0200880 <ramdisk_read+0x14>
ffffffffc020087e:	87b6                	mv	a5,a3
ffffffffc0200880:	6b18                	ld	a4,16(a4)
ffffffffc0200882:	05a6                	slli	a1,a1,0x9
ffffffffc0200884:	00979613          	slli	a2,a5,0x9
ffffffffc0200888:	95ba                	add	a1,a1,a4
ffffffffc020088a:	3ad0a0ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc020088e:	60a2                	ld	ra,8(sp)
ffffffffc0200890:	4501                	li	a0,0
ffffffffc0200892:	0141                	addi	sp,sp,16
ffffffffc0200894:	8082                	ret

ffffffffc0200896 <ramdisk_init>:
ffffffffc0200896:	7179                	addi	sp,sp,-48
ffffffffc0200898:	f022                	sd	s0,32(sp)
ffffffffc020089a:	ec26                	sd	s1,24(sp)
ffffffffc020089c:	842e                	mv	s0,a1
ffffffffc020089e:	84aa                	mv	s1,a0
ffffffffc02008a0:	05000613          	li	a2,80
ffffffffc02008a4:	852e                	mv	a0,a1
ffffffffc02008a6:	4581                	li	a1,0
ffffffffc02008a8:	f406                	sd	ra,40(sp)
ffffffffc02008aa:	33d0a0ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc02008ae:	4785                	li	a5,1
ffffffffc02008b0:	06f48a63          	beq	s1,a5,ffffffffc0200924 <ramdisk_init+0x8e>
ffffffffc02008b4:	4789                	li	a5,2
ffffffffc02008b6:	00090617          	auipc	a2,0x90
ffffffffc02008ba:	75a60613          	addi	a2,a2,1882 # ffffffffc0291010 <arena>
ffffffffc02008be:	0001b597          	auipc	a1,0x1b
ffffffffc02008c2:	45258593          	addi	a1,a1,1106 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc02008c6:	08f49363          	bne	s1,a5,ffffffffc020094c <ramdisk_init+0xb6>
ffffffffc02008ca:	06c58763          	beq	a1,a2,ffffffffc0200938 <ramdisk_init+0xa2>
ffffffffc02008ce:	40b604b3          	sub	s1,a2,a1
ffffffffc02008d2:	86a6                	mv	a3,s1
ffffffffc02008d4:	167d                	addi	a2,a2,-1
ffffffffc02008d6:	0000b517          	auipc	a0,0xb
ffffffffc02008da:	41a50513          	addi	a0,a0,1050 # ffffffffc020bcf0 <etext+0x41a>
ffffffffc02008de:	e42e                	sd	a1,8(sp)
ffffffffc02008e0:	849ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02008e4:	65a2                	ld	a1,8(sp)
ffffffffc02008e6:	57fd                	li	a5,-1
ffffffffc02008e8:	1782                	slli	a5,a5,0x20
ffffffffc02008ea:	0094d69b          	srliw	a3,s1,0x9
ffffffffc02008ee:	0785                	addi	a5,a5,1
ffffffffc02008f0:	e80c                	sd	a1,16(s0)
ffffffffc02008f2:	e01c                	sd	a5,0(s0)
ffffffffc02008f4:	c414                	sw	a3,8(s0)
ffffffffc02008f6:	02040513          	addi	a0,s0,32
ffffffffc02008fa:	0000b597          	auipc	a1,0xb
ffffffffc02008fe:	44e58593          	addi	a1,a1,1102 # ffffffffc020bd48 <etext+0x472>
ffffffffc0200902:	2650a0ef          	jal	ffffffffc020b366 <strcpy>
ffffffffc0200906:	00000717          	auipc	a4,0x0
ffffffffc020090a:	f6670713          	addi	a4,a4,-154 # ffffffffc020086c <ramdisk_read>
ffffffffc020090e:	00000797          	auipc	a5,0x0
ffffffffc0200912:	f3278793          	addi	a5,a5,-206 # ffffffffc0200840 <ramdisk_write>
ffffffffc0200916:	70a2                	ld	ra,40(sp)
ffffffffc0200918:	e038                	sd	a4,64(s0)
ffffffffc020091a:	e43c                	sd	a5,72(s0)
ffffffffc020091c:	7402                	ld	s0,32(sp)
ffffffffc020091e:	64e2                	ld	s1,24(sp)
ffffffffc0200920:	6145                	addi	sp,sp,48
ffffffffc0200922:	8082                	ret
ffffffffc0200924:	0001b617          	auipc	a2,0x1b
ffffffffc0200928:	3ec60613          	addi	a2,a2,1004 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc020092c:	00013597          	auipc	a1,0x13
ffffffffc0200930:	6e458593          	addi	a1,a1,1764 # ffffffffc0214010 <_binary_bin_swap_img_start>
ffffffffc0200934:	f8c59de3          	bne	a1,a2,ffffffffc02008ce <ramdisk_init+0x38>
ffffffffc0200938:	7402                	ld	s0,32(sp)
ffffffffc020093a:	70a2                	ld	ra,40(sp)
ffffffffc020093c:	64e2                	ld	s1,24(sp)
ffffffffc020093e:	0000b517          	auipc	a0,0xb
ffffffffc0200942:	39a50513          	addi	a0,a0,922 # ffffffffc020bcd8 <etext+0x402>
ffffffffc0200946:	6145                	addi	sp,sp,48
ffffffffc0200948:	fe0ff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc020094c:	0000b617          	auipc	a2,0xb
ffffffffc0200950:	3cc60613          	addi	a2,a2,972 # ffffffffc020bd18 <etext+0x442>
ffffffffc0200954:	03200593          	li	a1,50
ffffffffc0200958:	0000b517          	auipc	a0,0xb
ffffffffc020095c:	3d850513          	addi	a0,a0,984 # ffffffffc020bd30 <etext+0x45a>
ffffffffc0200960:	8cdff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200964 <clock_init>:
ffffffffc0200964:	02000793          	li	a5,32
ffffffffc0200968:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc020096c:	c0102573          	rdtime	a0
ffffffffc0200970:	67e1                	lui	a5,0x18
ffffffffc0200972:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200976:	953e                	add	a0,a0,a5
ffffffffc0200978:	4581                	li	a1,0
ffffffffc020097a:	4601                	li	a2,0
ffffffffc020097c:	4881                	li	a7,0
ffffffffc020097e:	00000073          	ecall
ffffffffc0200982:	0000b517          	auipc	a0,0xb
ffffffffc0200986:	3d650513          	addi	a0,a0,982 # ffffffffc020bd58 <etext+0x482>
ffffffffc020098a:	00096797          	auipc	a5,0x96
ffffffffc020098e:	ee07bb23          	sd	zero,-266(a5) # ffffffffc0296880 <ticks>
ffffffffc0200992:	f96ff06f          	j	ffffffffc0200128 <cprintf>

ffffffffc0200996 <clock_set_next_event>:
ffffffffc0200996:	c0102573          	rdtime	a0
ffffffffc020099a:	67e1                	lui	a5,0x18
ffffffffc020099c:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc02009a0:	953e                	add	a0,a0,a5
ffffffffc02009a2:	4581                	li	a1,0
ffffffffc02009a4:	4601                	li	a2,0
ffffffffc02009a6:	4881                	li	a7,0
ffffffffc02009a8:	00000073          	ecall
ffffffffc02009ac:	8082                	ret

ffffffffc02009ae <cons_init>:
ffffffffc02009ae:	4501                	li	a0,0
ffffffffc02009b0:	4581                	li	a1,0
ffffffffc02009b2:	4601                	li	a2,0
ffffffffc02009b4:	4889                	li	a7,2
ffffffffc02009b6:	00000073          	ecall
ffffffffc02009ba:	8082                	ret

ffffffffc02009bc <cons_putc>:
ffffffffc02009bc:	1101                	addi	sp,sp,-32
ffffffffc02009be:	ec06                	sd	ra,24(sp)
ffffffffc02009c0:	100027f3          	csrr	a5,sstatus
ffffffffc02009c4:	8b89                	andi	a5,a5,2
ffffffffc02009c6:	ef95                	bnez	a5,ffffffffc0200a02 <cons_putc+0x46>
ffffffffc02009c8:	47a1                	li	a5,8
ffffffffc02009ca:	00f50a63          	beq	a0,a5,ffffffffc02009de <cons_putc+0x22>
ffffffffc02009ce:	4581                	li	a1,0
ffffffffc02009d0:	4601                	li	a2,0
ffffffffc02009d2:	4885                	li	a7,1
ffffffffc02009d4:	00000073          	ecall
ffffffffc02009d8:	60e2                	ld	ra,24(sp)
ffffffffc02009da:	6105                	addi	sp,sp,32
ffffffffc02009dc:	8082                	ret
ffffffffc02009de:	4781                	li	a5,0
ffffffffc02009e0:	4521                	li	a0,8
ffffffffc02009e2:	4581                	li	a1,0
ffffffffc02009e4:	4601                	li	a2,0
ffffffffc02009e6:	4885                	li	a7,1
ffffffffc02009e8:	00000073          	ecall
ffffffffc02009ec:	02000513          	li	a0,32
ffffffffc02009f0:	00000073          	ecall
ffffffffc02009f4:	4521                	li	a0,8
ffffffffc02009f6:	00000073          	ecall
ffffffffc02009fa:	dff9                	beqz	a5,ffffffffc02009d8 <cons_putc+0x1c>
ffffffffc02009fc:	60e2                	ld	ra,24(sp)
ffffffffc02009fe:	6105                	addi	sp,sp,32
ffffffffc0200a00:	acf5                	j	ffffffffc0200cfc <intr_enable>
ffffffffc0200a02:	e42a                	sd	a0,8(sp)
ffffffffc0200a04:	2fe000ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0200a08:	6522                	ld	a0,8(sp)
ffffffffc0200a0a:	47a1                	li	a5,8
ffffffffc0200a0c:	00f50a63          	beq	a0,a5,ffffffffc0200a20 <cons_putc+0x64>
ffffffffc0200a10:	4581                	li	a1,0
ffffffffc0200a12:	4601                	li	a2,0
ffffffffc0200a14:	4885                	li	a7,1
ffffffffc0200a16:	00000073          	ecall
ffffffffc0200a1a:	60e2                	ld	ra,24(sp)
ffffffffc0200a1c:	6105                	addi	sp,sp,32
ffffffffc0200a1e:	acf9                	j	ffffffffc0200cfc <intr_enable>
ffffffffc0200a20:	4785                	li	a5,1
ffffffffc0200a22:	bf7d                	j	ffffffffc02009e0 <cons_putc+0x24>

ffffffffc0200a24 <cons_getc>:
ffffffffc0200a24:	1101                	addi	sp,sp,-32
ffffffffc0200a26:	ec06                	sd	ra,24(sp)
ffffffffc0200a28:	100027f3          	csrr	a5,sstatus
ffffffffc0200a2c:	8b89                	andi	a5,a5,2
ffffffffc0200a2e:	4801                	li	a6,0
ffffffffc0200a30:	e7d5                	bnez	a5,ffffffffc0200adc <cons_getc+0xb8>
ffffffffc0200a32:	00091697          	auipc	a3,0x91
ffffffffc0200a36:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0291460 <cons>
ffffffffc0200a3a:	07f00713          	li	a4,127
ffffffffc0200a3e:	4501                	li	a0,0
ffffffffc0200a40:	4581                	li	a1,0
ffffffffc0200a42:	4601                	li	a2,0
ffffffffc0200a44:	4889                	li	a7,2
ffffffffc0200a46:	00000073          	ecall
ffffffffc0200a4a:	0005079b          	sext.w	a5,a0
ffffffffc0200a4e:	0207cd63          	bltz	a5,ffffffffc0200a88 <cons_getc+0x64>
ffffffffc0200a52:	02e78963          	beq	a5,a4,ffffffffc0200a84 <cons_getc+0x60>
ffffffffc0200a56:	d7e5                	beqz	a5,ffffffffc0200a3e <cons_getc+0x1a>
ffffffffc0200a58:	00091797          	auipc	a5,0x91
ffffffffc0200a5c:	c0c7a783          	lw	a5,-1012(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc0200a60:	20000593          	li	a1,512
ffffffffc0200a64:	02079613          	slli	a2,a5,0x20
ffffffffc0200a68:	9201                	srli	a2,a2,0x20
ffffffffc0200a6a:	2785                	addiw	a5,a5,1
ffffffffc0200a6c:	9636                	add	a2,a2,a3
ffffffffc0200a6e:	20f6a223          	sw	a5,516(a3)
ffffffffc0200a72:	00a60023          	sb	a0,0(a2)
ffffffffc0200a76:	fcb794e3          	bne	a5,a1,ffffffffc0200a3e <cons_getc+0x1a>
ffffffffc0200a7a:	00091797          	auipc	a5,0x91
ffffffffc0200a7e:	be07a523          	sw	zero,-1046(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc0200a82:	bf75                	j	ffffffffc0200a3e <cons_getc+0x1a>
ffffffffc0200a84:	4521                	li	a0,8
ffffffffc0200a86:	bfc9                	j	ffffffffc0200a58 <cons_getc+0x34>
ffffffffc0200a88:	00091797          	auipc	a5,0x91
ffffffffc0200a8c:	bd87a783          	lw	a5,-1064(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc0200a90:	00091717          	auipc	a4,0x91
ffffffffc0200a94:	bd472703          	lw	a4,-1068(a4) # ffffffffc0291664 <cons+0x204>
ffffffffc0200a98:	4501                	li	a0,0
ffffffffc0200a9a:	00f70f63          	beq	a4,a5,ffffffffc0200ab8 <cons_getc+0x94>
ffffffffc0200a9e:	02079713          	slli	a4,a5,0x20
ffffffffc0200aa2:	9301                	srli	a4,a4,0x20
ffffffffc0200aa4:	2785                	addiw	a5,a5,1
ffffffffc0200aa6:	20f6a023          	sw	a5,512(a3)
ffffffffc0200aaa:	96ba                	add	a3,a3,a4
ffffffffc0200aac:	20000713          	li	a4,512
ffffffffc0200ab0:	0006c503          	lbu	a0,0(a3)
ffffffffc0200ab4:	00e78763          	beq	a5,a4,ffffffffc0200ac2 <cons_getc+0x9e>
ffffffffc0200ab8:	00081b63          	bnez	a6,ffffffffc0200ace <cons_getc+0xaa>
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	6105                	addi	sp,sp,32
ffffffffc0200ac0:	8082                	ret
ffffffffc0200ac2:	00091797          	auipc	a5,0x91
ffffffffc0200ac6:	b807af23          	sw	zero,-1122(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc0200aca:	fe0809e3          	beqz	a6,ffffffffc0200abc <cons_getc+0x98>
ffffffffc0200ace:	e42a                	sd	a0,8(sp)
ffffffffc0200ad0:	22c000ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0200ad4:	60e2                	ld	ra,24(sp)
ffffffffc0200ad6:	6522                	ld	a0,8(sp)
ffffffffc0200ad8:	6105                	addi	sp,sp,32
ffffffffc0200ada:	8082                	ret
ffffffffc0200adc:	226000ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0200ae0:	4805                	li	a6,1
ffffffffc0200ae2:	bf81                	j	ffffffffc0200a32 <cons_getc+0xe>

ffffffffc0200ae4 <pic_init>:
ffffffffc0200ae4:	8082                	ret

ffffffffc0200ae6 <ide_init>:
ffffffffc0200ae6:	1141                	addi	sp,sp,-16
ffffffffc0200ae8:	00091597          	auipc	a1,0x91
ffffffffc0200aec:	bd058593          	addi	a1,a1,-1072 # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200af0:	4505                	li	a0,1
ffffffffc0200af2:	00091797          	auipc	a5,0x91
ffffffffc0200af6:	b607ab23          	sw	zero,-1162(a5) # ffffffffc0291668 <ide_devices>
ffffffffc0200afa:	00091797          	auipc	a5,0x91
ffffffffc0200afe:	ba07af23          	sw	zero,-1090(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200b02:	00091797          	auipc	a5,0x91
ffffffffc0200b06:	c007a323          	sw	zero,-1018(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200b0a:	00091797          	auipc	a5,0x91
ffffffffc0200b0e:	c407a723          	sw	zero,-946(a5) # ffffffffc0291758 <ide_devices+0xf0>
ffffffffc0200b12:	e406                	sd	ra,8(sp)
ffffffffc0200b14:	d83ff0ef          	jal	ffffffffc0200896 <ramdisk_init>
ffffffffc0200b18:	00091797          	auipc	a5,0x91
ffffffffc0200b1c:	ba07a783          	lw	a5,-1120(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc0200b20:	c385                	beqz	a5,ffffffffc0200b40 <ide_init+0x5a>
ffffffffc0200b22:	00091597          	auipc	a1,0x91
ffffffffc0200b26:	be658593          	addi	a1,a1,-1050 # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200b2a:	4509                	li	a0,2
ffffffffc0200b2c:	d6bff0ef          	jal	ffffffffc0200896 <ramdisk_init>
ffffffffc0200b30:	00091797          	auipc	a5,0x91
ffffffffc0200b34:	bd87a783          	lw	a5,-1064(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200b38:	c39d                	beqz	a5,ffffffffc0200b5e <ide_init+0x78>
ffffffffc0200b3a:	60a2                	ld	ra,8(sp)
ffffffffc0200b3c:	0141                	addi	sp,sp,16
ffffffffc0200b3e:	8082                	ret
ffffffffc0200b40:	0000b697          	auipc	a3,0xb
ffffffffc0200b44:	23868693          	addi	a3,a3,568 # ffffffffc020bd78 <etext+0x4a2>
ffffffffc0200b48:	0000b617          	auipc	a2,0xb
ffffffffc0200b4c:	24860613          	addi	a2,a2,584 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0200b50:	45c5                	li	a1,17
ffffffffc0200b52:	0000b517          	auipc	a0,0xb
ffffffffc0200b56:	25650513          	addi	a0,a0,598 # ffffffffc020bda8 <etext+0x4d2>
ffffffffc0200b5a:	ed2ff0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0200b5e:	0000b697          	auipc	a3,0xb
ffffffffc0200b62:	26268693          	addi	a3,a3,610 # ffffffffc020bdc0 <etext+0x4ea>
ffffffffc0200b66:	0000b617          	auipc	a2,0xb
ffffffffc0200b6a:	22a60613          	addi	a2,a2,554 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0200b6e:	45d1                	li	a1,20
ffffffffc0200b70:	0000b517          	auipc	a0,0xb
ffffffffc0200b74:	23850513          	addi	a0,a0,568 # ffffffffc020bda8 <etext+0x4d2>
ffffffffc0200b78:	eb4ff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200b7c <ide_device_valid>:
ffffffffc0200b7c:	478d                	li	a5,3
ffffffffc0200b7e:	00a7ef63          	bltu	a5,a0,ffffffffc0200b9c <ide_device_valid+0x20>
ffffffffc0200b82:	00251793          	slli	a5,a0,0x2
ffffffffc0200b86:	97aa                	add	a5,a5,a0
ffffffffc0200b88:	00091717          	auipc	a4,0x91
ffffffffc0200b8c:	ae070713          	addi	a4,a4,-1312 # ffffffffc0291668 <ide_devices>
ffffffffc0200b90:	0792                	slli	a5,a5,0x4
ffffffffc0200b92:	97ba                	add	a5,a5,a4
ffffffffc0200b94:	4388                	lw	a0,0(a5)
ffffffffc0200b96:	00a03533          	snez	a0,a0
ffffffffc0200b9a:	8082                	ret
ffffffffc0200b9c:	4501                	li	a0,0
ffffffffc0200b9e:	8082                	ret

ffffffffc0200ba0 <ide_device_size>:
ffffffffc0200ba0:	478d                	li	a5,3
ffffffffc0200ba2:	02a7e163          	bltu	a5,a0,ffffffffc0200bc4 <ide_device_size+0x24>
ffffffffc0200ba6:	00251793          	slli	a5,a0,0x2
ffffffffc0200baa:	97aa                	add	a5,a5,a0
ffffffffc0200bac:	00091717          	auipc	a4,0x91
ffffffffc0200bb0:	abc70713          	addi	a4,a4,-1348 # ffffffffc0291668 <ide_devices>
ffffffffc0200bb4:	0792                	slli	a5,a5,0x4
ffffffffc0200bb6:	97ba                	add	a5,a5,a4
ffffffffc0200bb8:	4398                	lw	a4,0(a5)
ffffffffc0200bba:	4501                	li	a0,0
ffffffffc0200bbc:	c709                	beqz	a4,ffffffffc0200bc6 <ide_device_size+0x26>
ffffffffc0200bbe:	0087e503          	lwu	a0,8(a5)
ffffffffc0200bc2:	8082                	ret
ffffffffc0200bc4:	4501                	li	a0,0
ffffffffc0200bc6:	8082                	ret

ffffffffc0200bc8 <ide_read_secs>:
ffffffffc0200bc8:	1141                	addi	sp,sp,-16
ffffffffc0200bca:	e406                	sd	ra,8(sp)
ffffffffc0200bcc:	0816b793          	sltiu	a5,a3,129
ffffffffc0200bd0:	cba9                	beqz	a5,ffffffffc0200c22 <ide_read_secs+0x5a>
ffffffffc0200bd2:	478d                	li	a5,3
ffffffffc0200bd4:	0005081b          	sext.w	a6,a0
ffffffffc0200bd8:	04a7e563          	bltu	a5,a0,ffffffffc0200c22 <ide_read_secs+0x5a>
ffffffffc0200bdc:	00281793          	slli	a5,a6,0x2
ffffffffc0200be0:	97c2                	add	a5,a5,a6
ffffffffc0200be2:	0792                	slli	a5,a5,0x4
ffffffffc0200be4:	00091817          	auipc	a6,0x91
ffffffffc0200be8:	a8480813          	addi	a6,a6,-1404 # ffffffffc0291668 <ide_devices>
ffffffffc0200bec:	97c2                	add	a5,a5,a6
ffffffffc0200bee:	0007a883          	lw	a7,0(a5)
ffffffffc0200bf2:	02088863          	beqz	a7,ffffffffc0200c22 <ide_read_secs+0x5a>
ffffffffc0200bf6:	100008b7          	lui	a7,0x10000
ffffffffc0200bfa:	0515f463          	bgeu	a1,a7,ffffffffc0200c42 <ide_read_secs+0x7a>
ffffffffc0200bfe:	1582                	slli	a1,a1,0x20
ffffffffc0200c00:	9181                	srli	a1,a1,0x20
ffffffffc0200c02:	00d58733          	add	a4,a1,a3
ffffffffc0200c06:	02e8ee63          	bltu	a7,a4,ffffffffc0200c42 <ide_read_secs+0x7a>
ffffffffc0200c0a:	00251713          	slli	a4,a0,0x2
ffffffffc0200c0e:	0407b883          	ld	a7,64(a5)
ffffffffc0200c12:	60a2                	ld	ra,8(sp)
ffffffffc0200c14:	00a707b3          	add	a5,a4,a0
ffffffffc0200c18:	0792                	slli	a5,a5,0x4
ffffffffc0200c1a:	00f80533          	add	a0,a6,a5
ffffffffc0200c1e:	0141                	addi	sp,sp,16
ffffffffc0200c20:	8882                	jr	a7
ffffffffc0200c22:	0000b697          	auipc	a3,0xb
ffffffffc0200c26:	1b668693          	addi	a3,a3,438 # ffffffffc020bdd8 <etext+0x502>
ffffffffc0200c2a:	0000b617          	auipc	a2,0xb
ffffffffc0200c2e:	16660613          	addi	a2,a2,358 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0200c32:	02200593          	li	a1,34
ffffffffc0200c36:	0000b517          	auipc	a0,0xb
ffffffffc0200c3a:	17250513          	addi	a0,a0,370 # ffffffffc020bda8 <etext+0x4d2>
ffffffffc0200c3e:	deeff0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0200c42:	0000b697          	auipc	a3,0xb
ffffffffc0200c46:	1be68693          	addi	a3,a3,446 # ffffffffc020be00 <etext+0x52a>
ffffffffc0200c4a:	0000b617          	auipc	a2,0xb
ffffffffc0200c4e:	14660613          	addi	a2,a2,326 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0200c52:	02300593          	li	a1,35
ffffffffc0200c56:	0000b517          	auipc	a0,0xb
ffffffffc0200c5a:	15250513          	addi	a0,a0,338 # ffffffffc020bda8 <etext+0x4d2>
ffffffffc0200c5e:	dceff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200c62 <ide_write_secs>:
ffffffffc0200c62:	1141                	addi	sp,sp,-16
ffffffffc0200c64:	e406                	sd	ra,8(sp)
ffffffffc0200c66:	0816b793          	sltiu	a5,a3,129
ffffffffc0200c6a:	cba9                	beqz	a5,ffffffffc0200cbc <ide_write_secs+0x5a>
ffffffffc0200c6c:	478d                	li	a5,3
ffffffffc0200c6e:	0005081b          	sext.w	a6,a0
ffffffffc0200c72:	04a7e563          	bltu	a5,a0,ffffffffc0200cbc <ide_write_secs+0x5a>
ffffffffc0200c76:	00281793          	slli	a5,a6,0x2
ffffffffc0200c7a:	97c2                	add	a5,a5,a6
ffffffffc0200c7c:	0792                	slli	a5,a5,0x4
ffffffffc0200c7e:	00091817          	auipc	a6,0x91
ffffffffc0200c82:	9ea80813          	addi	a6,a6,-1558 # ffffffffc0291668 <ide_devices>
ffffffffc0200c86:	97c2                	add	a5,a5,a6
ffffffffc0200c88:	0007a883          	lw	a7,0(a5)
ffffffffc0200c8c:	02088863          	beqz	a7,ffffffffc0200cbc <ide_write_secs+0x5a>
ffffffffc0200c90:	100008b7          	lui	a7,0x10000
ffffffffc0200c94:	0515f463          	bgeu	a1,a7,ffffffffc0200cdc <ide_write_secs+0x7a>
ffffffffc0200c98:	1582                	slli	a1,a1,0x20
ffffffffc0200c9a:	9181                	srli	a1,a1,0x20
ffffffffc0200c9c:	00d58733          	add	a4,a1,a3
ffffffffc0200ca0:	02e8ee63          	bltu	a7,a4,ffffffffc0200cdc <ide_write_secs+0x7a>
ffffffffc0200ca4:	00251713          	slli	a4,a0,0x2
ffffffffc0200ca8:	0487b883          	ld	a7,72(a5)
ffffffffc0200cac:	60a2                	ld	ra,8(sp)
ffffffffc0200cae:	00a707b3          	add	a5,a4,a0
ffffffffc0200cb2:	0792                	slli	a5,a5,0x4
ffffffffc0200cb4:	00f80533          	add	a0,a6,a5
ffffffffc0200cb8:	0141                	addi	sp,sp,16
ffffffffc0200cba:	8882                	jr	a7
ffffffffc0200cbc:	0000b697          	auipc	a3,0xb
ffffffffc0200cc0:	11c68693          	addi	a3,a3,284 # ffffffffc020bdd8 <etext+0x502>
ffffffffc0200cc4:	0000b617          	auipc	a2,0xb
ffffffffc0200cc8:	0cc60613          	addi	a2,a2,204 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0200ccc:	02900593          	li	a1,41
ffffffffc0200cd0:	0000b517          	auipc	a0,0xb
ffffffffc0200cd4:	0d850513          	addi	a0,a0,216 # ffffffffc020bda8 <etext+0x4d2>
ffffffffc0200cd8:	d54ff0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0200cdc:	0000b697          	auipc	a3,0xb
ffffffffc0200ce0:	12468693          	addi	a3,a3,292 # ffffffffc020be00 <etext+0x52a>
ffffffffc0200ce4:	0000b617          	auipc	a2,0xb
ffffffffc0200ce8:	0ac60613          	addi	a2,a2,172 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0200cec:	02a00593          	li	a1,42
ffffffffc0200cf0:	0000b517          	auipc	a0,0xb
ffffffffc0200cf4:	0b850513          	addi	a0,a0,184 # ffffffffc020bda8 <etext+0x4d2>
ffffffffc0200cf8:	d34ff0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0200cfc <intr_enable>:
ffffffffc0200cfc:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200d00:	8082                	ret

ffffffffc0200d02 <intr_disable>:
ffffffffc0200d02:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200d06:	8082                	ret

ffffffffc0200d08 <idt_init>:
ffffffffc0200d08:	14005073          	csrwi	sscratch,0
ffffffffc0200d0c:	00000797          	auipc	a5,0x0
ffffffffc0200d10:	47c78793          	addi	a5,a5,1148 # ffffffffc0201188 <__alltraps>
ffffffffc0200d14:	10579073          	csrw	stvec,a5
ffffffffc0200d18:	000407b7          	lui	a5,0x40
ffffffffc0200d1c:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200d20:	8082                	ret

ffffffffc0200d22 <print_regs>:
ffffffffc0200d22:	610c                	ld	a1,0(a0)
ffffffffc0200d24:	1141                	addi	sp,sp,-16
ffffffffc0200d26:	e022                	sd	s0,0(sp)
ffffffffc0200d28:	842a                	mv	s0,a0
ffffffffc0200d2a:	0000b517          	auipc	a0,0xb
ffffffffc0200d2e:	11650513          	addi	a0,a0,278 # ffffffffc020be40 <etext+0x56a>
ffffffffc0200d32:	e406                	sd	ra,8(sp)
ffffffffc0200d34:	bf4ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d38:	640c                	ld	a1,8(s0)
ffffffffc0200d3a:	0000b517          	auipc	a0,0xb
ffffffffc0200d3e:	11e50513          	addi	a0,a0,286 # ffffffffc020be58 <etext+0x582>
ffffffffc0200d42:	be6ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d46:	680c                	ld	a1,16(s0)
ffffffffc0200d48:	0000b517          	auipc	a0,0xb
ffffffffc0200d4c:	12850513          	addi	a0,a0,296 # ffffffffc020be70 <etext+0x59a>
ffffffffc0200d50:	bd8ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d54:	6c0c                	ld	a1,24(s0)
ffffffffc0200d56:	0000b517          	auipc	a0,0xb
ffffffffc0200d5a:	13250513          	addi	a0,a0,306 # ffffffffc020be88 <etext+0x5b2>
ffffffffc0200d5e:	bcaff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d62:	700c                	ld	a1,32(s0)
ffffffffc0200d64:	0000b517          	auipc	a0,0xb
ffffffffc0200d68:	13c50513          	addi	a0,a0,316 # ffffffffc020bea0 <etext+0x5ca>
ffffffffc0200d6c:	bbcff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d70:	740c                	ld	a1,40(s0)
ffffffffc0200d72:	0000b517          	auipc	a0,0xb
ffffffffc0200d76:	14650513          	addi	a0,a0,326 # ffffffffc020beb8 <etext+0x5e2>
ffffffffc0200d7a:	baeff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d7e:	780c                	ld	a1,48(s0)
ffffffffc0200d80:	0000b517          	auipc	a0,0xb
ffffffffc0200d84:	15050513          	addi	a0,a0,336 # ffffffffc020bed0 <etext+0x5fa>
ffffffffc0200d88:	ba0ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d8c:	7c0c                	ld	a1,56(s0)
ffffffffc0200d8e:	0000b517          	auipc	a0,0xb
ffffffffc0200d92:	15a50513          	addi	a0,a0,346 # ffffffffc020bee8 <etext+0x612>
ffffffffc0200d96:	b92ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200d9a:	602c                	ld	a1,64(s0)
ffffffffc0200d9c:	0000b517          	auipc	a0,0xb
ffffffffc0200da0:	16450513          	addi	a0,a0,356 # ffffffffc020bf00 <etext+0x62a>
ffffffffc0200da4:	b84ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200da8:	642c                	ld	a1,72(s0)
ffffffffc0200daa:	0000b517          	auipc	a0,0xb
ffffffffc0200dae:	16e50513          	addi	a0,a0,366 # ffffffffc020bf18 <etext+0x642>
ffffffffc0200db2:	b76ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200db6:	682c                	ld	a1,80(s0)
ffffffffc0200db8:	0000b517          	auipc	a0,0xb
ffffffffc0200dbc:	17850513          	addi	a0,a0,376 # ffffffffc020bf30 <etext+0x65a>
ffffffffc0200dc0:	b68ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200dc4:	6c2c                	ld	a1,88(s0)
ffffffffc0200dc6:	0000b517          	auipc	a0,0xb
ffffffffc0200dca:	18250513          	addi	a0,a0,386 # ffffffffc020bf48 <etext+0x672>
ffffffffc0200dce:	b5aff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200dd2:	702c                	ld	a1,96(s0)
ffffffffc0200dd4:	0000b517          	auipc	a0,0xb
ffffffffc0200dd8:	18c50513          	addi	a0,a0,396 # ffffffffc020bf60 <etext+0x68a>
ffffffffc0200ddc:	b4cff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200de0:	742c                	ld	a1,104(s0)
ffffffffc0200de2:	0000b517          	auipc	a0,0xb
ffffffffc0200de6:	19650513          	addi	a0,a0,406 # ffffffffc020bf78 <etext+0x6a2>
ffffffffc0200dea:	b3eff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200dee:	782c                	ld	a1,112(s0)
ffffffffc0200df0:	0000b517          	auipc	a0,0xb
ffffffffc0200df4:	1a050513          	addi	a0,a0,416 # ffffffffc020bf90 <etext+0x6ba>
ffffffffc0200df8:	b30ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200dfc:	7c2c                	ld	a1,120(s0)
ffffffffc0200dfe:	0000b517          	auipc	a0,0xb
ffffffffc0200e02:	1aa50513          	addi	a0,a0,426 # ffffffffc020bfa8 <etext+0x6d2>
ffffffffc0200e06:	b22ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e0a:	604c                	ld	a1,128(s0)
ffffffffc0200e0c:	0000b517          	auipc	a0,0xb
ffffffffc0200e10:	1b450513          	addi	a0,a0,436 # ffffffffc020bfc0 <etext+0x6ea>
ffffffffc0200e14:	b14ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e18:	644c                	ld	a1,136(s0)
ffffffffc0200e1a:	0000b517          	auipc	a0,0xb
ffffffffc0200e1e:	1be50513          	addi	a0,a0,446 # ffffffffc020bfd8 <etext+0x702>
ffffffffc0200e22:	b06ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e26:	684c                	ld	a1,144(s0)
ffffffffc0200e28:	0000b517          	auipc	a0,0xb
ffffffffc0200e2c:	1c850513          	addi	a0,a0,456 # ffffffffc020bff0 <etext+0x71a>
ffffffffc0200e30:	af8ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e34:	6c4c                	ld	a1,152(s0)
ffffffffc0200e36:	0000b517          	auipc	a0,0xb
ffffffffc0200e3a:	1d250513          	addi	a0,a0,466 # ffffffffc020c008 <etext+0x732>
ffffffffc0200e3e:	aeaff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e42:	704c                	ld	a1,160(s0)
ffffffffc0200e44:	0000b517          	auipc	a0,0xb
ffffffffc0200e48:	1dc50513          	addi	a0,a0,476 # ffffffffc020c020 <etext+0x74a>
ffffffffc0200e4c:	adcff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e50:	744c                	ld	a1,168(s0)
ffffffffc0200e52:	0000b517          	auipc	a0,0xb
ffffffffc0200e56:	1e650513          	addi	a0,a0,486 # ffffffffc020c038 <etext+0x762>
ffffffffc0200e5a:	aceff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e5e:	784c                	ld	a1,176(s0)
ffffffffc0200e60:	0000b517          	auipc	a0,0xb
ffffffffc0200e64:	1f050513          	addi	a0,a0,496 # ffffffffc020c050 <etext+0x77a>
ffffffffc0200e68:	ac0ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e6c:	7c4c                	ld	a1,184(s0)
ffffffffc0200e6e:	0000b517          	auipc	a0,0xb
ffffffffc0200e72:	1fa50513          	addi	a0,a0,506 # ffffffffc020c068 <etext+0x792>
ffffffffc0200e76:	ab2ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e7a:	606c                	ld	a1,192(s0)
ffffffffc0200e7c:	0000b517          	auipc	a0,0xb
ffffffffc0200e80:	20450513          	addi	a0,a0,516 # ffffffffc020c080 <etext+0x7aa>
ffffffffc0200e84:	aa4ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e88:	646c                	ld	a1,200(s0)
ffffffffc0200e8a:	0000b517          	auipc	a0,0xb
ffffffffc0200e8e:	20e50513          	addi	a0,a0,526 # ffffffffc020c098 <etext+0x7c2>
ffffffffc0200e92:	a96ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200e96:	686c                	ld	a1,208(s0)
ffffffffc0200e98:	0000b517          	auipc	a0,0xb
ffffffffc0200e9c:	21850513          	addi	a0,a0,536 # ffffffffc020c0b0 <etext+0x7da>
ffffffffc0200ea0:	a88ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200ea4:	6c6c                	ld	a1,216(s0)
ffffffffc0200ea6:	0000b517          	auipc	a0,0xb
ffffffffc0200eaa:	22250513          	addi	a0,a0,546 # ffffffffc020c0c8 <etext+0x7f2>
ffffffffc0200eae:	a7aff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200eb2:	706c                	ld	a1,224(s0)
ffffffffc0200eb4:	0000b517          	auipc	a0,0xb
ffffffffc0200eb8:	22c50513          	addi	a0,a0,556 # ffffffffc020c0e0 <etext+0x80a>
ffffffffc0200ebc:	a6cff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200ec0:	746c                	ld	a1,232(s0)
ffffffffc0200ec2:	0000b517          	auipc	a0,0xb
ffffffffc0200ec6:	23650513          	addi	a0,a0,566 # ffffffffc020c0f8 <etext+0x822>
ffffffffc0200eca:	a5eff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200ece:	786c                	ld	a1,240(s0)
ffffffffc0200ed0:	0000b517          	auipc	a0,0xb
ffffffffc0200ed4:	24050513          	addi	a0,a0,576 # ffffffffc020c110 <etext+0x83a>
ffffffffc0200ed8:	a50ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200edc:	7c6c                	ld	a1,248(s0)
ffffffffc0200ede:	6402                	ld	s0,0(sp)
ffffffffc0200ee0:	60a2                	ld	ra,8(sp)
ffffffffc0200ee2:	0000b517          	auipc	a0,0xb
ffffffffc0200ee6:	24650513          	addi	a0,a0,582 # ffffffffc020c128 <etext+0x852>
ffffffffc0200eea:	0141                	addi	sp,sp,16
ffffffffc0200eec:	a3cff06f          	j	ffffffffc0200128 <cprintf>

ffffffffc0200ef0 <print_trapframe>:
ffffffffc0200ef0:	1141                	addi	sp,sp,-16
ffffffffc0200ef2:	e022                	sd	s0,0(sp)
ffffffffc0200ef4:	85aa                	mv	a1,a0
ffffffffc0200ef6:	842a                	mv	s0,a0
ffffffffc0200ef8:	0000b517          	auipc	a0,0xb
ffffffffc0200efc:	24850513          	addi	a0,a0,584 # ffffffffc020c140 <etext+0x86a>
ffffffffc0200f00:	e406                	sd	ra,8(sp)
ffffffffc0200f02:	a26ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200f06:	8522                	mv	a0,s0
ffffffffc0200f08:	e1bff0ef          	jal	ffffffffc0200d22 <print_regs>
ffffffffc0200f0c:	10043583          	ld	a1,256(s0)
ffffffffc0200f10:	0000b517          	auipc	a0,0xb
ffffffffc0200f14:	24850513          	addi	a0,a0,584 # ffffffffc020c158 <etext+0x882>
ffffffffc0200f18:	a10ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200f1c:	10843583          	ld	a1,264(s0)
ffffffffc0200f20:	0000b517          	auipc	a0,0xb
ffffffffc0200f24:	25050513          	addi	a0,a0,592 # ffffffffc020c170 <etext+0x89a>
ffffffffc0200f28:	a00ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200f2c:	11043583          	ld	a1,272(s0)
ffffffffc0200f30:	0000b517          	auipc	a0,0xb
ffffffffc0200f34:	25850513          	addi	a0,a0,600 # ffffffffc020c188 <etext+0x8b2>
ffffffffc0200f38:	9f0ff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0200f3c:	11843583          	ld	a1,280(s0)
ffffffffc0200f40:	6402                	ld	s0,0(sp)
ffffffffc0200f42:	60a2                	ld	ra,8(sp)
ffffffffc0200f44:	0000b517          	auipc	a0,0xb
ffffffffc0200f48:	25450513          	addi	a0,a0,596 # ffffffffc020c198 <etext+0x8c2>
ffffffffc0200f4c:	0141                	addi	sp,sp,16
ffffffffc0200f4e:	9daff06f          	j	ffffffffc0200128 <cprintf>

ffffffffc0200f52 <interrupt_handler>:
ffffffffc0200f52:	11853783          	ld	a5,280(a0)
ffffffffc0200f56:	472d                	li	a4,11
ffffffffc0200f58:	0786                	slli	a5,a5,0x1
ffffffffc0200f5a:	8385                	srli	a5,a5,0x1
ffffffffc0200f5c:	08f76063          	bltu	a4,a5,ffffffffc0200fdc <interrupt_handler+0x8a>
ffffffffc0200f60:	0000e717          	auipc	a4,0xe
ffffffffc0200f64:	fd870713          	addi	a4,a4,-40 # ffffffffc020ef38 <commands+0x48>
ffffffffc0200f68:	078a                	slli	a5,a5,0x2
ffffffffc0200f6a:	97ba                	add	a5,a5,a4
ffffffffc0200f6c:	439c                	lw	a5,0(a5)
ffffffffc0200f6e:	97ba                	add	a5,a5,a4
ffffffffc0200f70:	8782                	jr	a5
ffffffffc0200f72:	0000b517          	auipc	a0,0xb
ffffffffc0200f76:	29e50513          	addi	a0,a0,670 # ffffffffc020c210 <etext+0x93a>
ffffffffc0200f7a:	9aeff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0200f7e:	0000b517          	auipc	a0,0xb
ffffffffc0200f82:	27250513          	addi	a0,a0,626 # ffffffffc020c1f0 <etext+0x91a>
ffffffffc0200f86:	9a2ff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0200f8a:	0000b517          	auipc	a0,0xb
ffffffffc0200f8e:	22650513          	addi	a0,a0,550 # ffffffffc020c1b0 <etext+0x8da>
ffffffffc0200f92:	996ff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0200f96:	0000b517          	auipc	a0,0xb
ffffffffc0200f9a:	23a50513          	addi	a0,a0,570 # ffffffffc020c1d0 <etext+0x8fa>
ffffffffc0200f9e:	98aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0200fa2:	1141                	addi	sp,sp,-16
ffffffffc0200fa4:	e406                	sd	ra,8(sp)
ffffffffc0200fa6:	9f1ff0ef          	jal	ffffffffc0200996 <clock_set_next_event>
ffffffffc0200faa:	00096797          	auipc	a5,0x96
ffffffffc0200fae:	8d67b783          	ld	a5,-1834(a5) # ffffffffc0296880 <ticks>
ffffffffc0200fb2:	0785                	addi	a5,a5,1
ffffffffc0200fb4:	00096717          	auipc	a4,0x96
ffffffffc0200fb8:	8cf73623          	sd	a5,-1844(a4) # ffffffffc0296880 <ticks>
ffffffffc0200fbc:	720060ef          	jal	ffffffffc02076dc <run_timer_list>
ffffffffc0200fc0:	a65ff0ef          	jal	ffffffffc0200a24 <cons_getc>
ffffffffc0200fc4:	60a2                	ld	ra,8(sp)
ffffffffc0200fc6:	0ff57513          	zext.b	a0,a0
ffffffffc0200fca:	0141                	addi	sp,sp,16
ffffffffc0200fcc:	17f0706f          	j	ffffffffc020894a <dev_stdin_write>
ffffffffc0200fd0:	0000b517          	auipc	a0,0xb
ffffffffc0200fd4:	26050513          	addi	a0,a0,608 # ffffffffc020c230 <etext+0x95a>
ffffffffc0200fd8:	950ff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0200fdc:	bf11                	j	ffffffffc0200ef0 <print_trapframe>

ffffffffc0200fde <exception_handler>:
ffffffffc0200fde:	11853783          	ld	a5,280(a0)
ffffffffc0200fe2:	473d                	li	a4,15
ffffffffc0200fe4:	10f76e63          	bltu	a4,a5,ffffffffc0201100 <exception_handler+0x122>
ffffffffc0200fe8:	0000e717          	auipc	a4,0xe
ffffffffc0200fec:	f8070713          	addi	a4,a4,-128 # ffffffffc020ef68 <commands+0x78>
ffffffffc0200ff0:	078a                	slli	a5,a5,0x2
ffffffffc0200ff2:	97ba                	add	a5,a5,a4
ffffffffc0200ff4:	439c                	lw	a5,0(a5)
ffffffffc0200ff6:	1101                	addi	sp,sp,-32
ffffffffc0200ff8:	ec06                	sd	ra,24(sp)
ffffffffc0200ffa:	97ba                	add	a5,a5,a4
ffffffffc0200ffc:	86aa                	mv	a3,a0
ffffffffc0200ffe:	8782                	jr	a5
ffffffffc0201000:	e42a                	sd	a0,8(sp)
ffffffffc0201002:	0000b517          	auipc	a0,0xb
ffffffffc0201006:	33650513          	addi	a0,a0,822 # ffffffffc020c338 <etext+0xa62>
ffffffffc020100a:	91eff0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020100e:	66a2                	ld	a3,8(sp)
ffffffffc0201010:	1086b783          	ld	a5,264(a3)
ffffffffc0201014:	60e2                	ld	ra,24(sp)
ffffffffc0201016:	0791                	addi	a5,a5,4
ffffffffc0201018:	10f6b423          	sd	a5,264(a3)
ffffffffc020101c:	6105                	addi	sp,sp,32
ffffffffc020101e:	1f90606f          	j	ffffffffc0207a16 <syscall>
ffffffffc0201022:	60e2                	ld	ra,24(sp)
ffffffffc0201024:	0000b517          	auipc	a0,0xb
ffffffffc0201028:	33450513          	addi	a0,a0,820 # ffffffffc020c358 <etext+0xa82>
ffffffffc020102c:	6105                	addi	sp,sp,32
ffffffffc020102e:	8faff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201032:	60e2                	ld	ra,24(sp)
ffffffffc0201034:	0000b517          	auipc	a0,0xb
ffffffffc0201038:	34450513          	addi	a0,a0,836 # ffffffffc020c378 <etext+0xaa2>
ffffffffc020103c:	6105                	addi	sp,sp,32
ffffffffc020103e:	8eaff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201042:	60e2                	ld	ra,24(sp)
ffffffffc0201044:	0000b517          	auipc	a0,0xb
ffffffffc0201048:	35450513          	addi	a0,a0,852 # ffffffffc020c398 <etext+0xac2>
ffffffffc020104c:	6105                	addi	sp,sp,32
ffffffffc020104e:	8daff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201052:	60e2                	ld	ra,24(sp)
ffffffffc0201054:	0000b517          	auipc	a0,0xb
ffffffffc0201058:	35c50513          	addi	a0,a0,860 # ffffffffc020c3b0 <etext+0xada>
ffffffffc020105c:	6105                	addi	sp,sp,32
ffffffffc020105e:	8caff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201062:	60e2                	ld	ra,24(sp)
ffffffffc0201064:	0000b517          	auipc	a0,0xb
ffffffffc0201068:	36450513          	addi	a0,a0,868 # ffffffffc020c3c8 <etext+0xaf2>
ffffffffc020106c:	6105                	addi	sp,sp,32
ffffffffc020106e:	8baff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201072:	60e2                	ld	ra,24(sp)
ffffffffc0201074:	0000b517          	auipc	a0,0xb
ffffffffc0201078:	1dc50513          	addi	a0,a0,476 # ffffffffc020c250 <etext+0x97a>
ffffffffc020107c:	6105                	addi	sp,sp,32
ffffffffc020107e:	8aaff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201082:	60e2                	ld	ra,24(sp)
ffffffffc0201084:	0000b517          	auipc	a0,0xb
ffffffffc0201088:	1ec50513          	addi	a0,a0,492 # ffffffffc020c270 <etext+0x99a>
ffffffffc020108c:	6105                	addi	sp,sp,32
ffffffffc020108e:	89aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201092:	60e2                	ld	ra,24(sp)
ffffffffc0201094:	0000b517          	auipc	a0,0xb
ffffffffc0201098:	1fc50513          	addi	a0,a0,508 # ffffffffc020c290 <etext+0x9ba>
ffffffffc020109c:	6105                	addi	sp,sp,32
ffffffffc020109e:	88aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc02010a2:	60e2                	ld	ra,24(sp)
ffffffffc02010a4:	0000b517          	auipc	a0,0xb
ffffffffc02010a8:	20450513          	addi	a0,a0,516 # ffffffffc020c2a8 <etext+0x9d2>
ffffffffc02010ac:	6105                	addi	sp,sp,32
ffffffffc02010ae:	87aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc02010b2:	60e2                	ld	ra,24(sp)
ffffffffc02010b4:	0000b517          	auipc	a0,0xb
ffffffffc02010b8:	20450513          	addi	a0,a0,516 # ffffffffc020c2b8 <etext+0x9e2>
ffffffffc02010bc:	6105                	addi	sp,sp,32
ffffffffc02010be:	86aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc02010c2:	60e2                	ld	ra,24(sp)
ffffffffc02010c4:	0000b517          	auipc	a0,0xb
ffffffffc02010c8:	21450513          	addi	a0,a0,532 # ffffffffc020c2d8 <etext+0xa02>
ffffffffc02010cc:	6105                	addi	sp,sp,32
ffffffffc02010ce:	85aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc02010d2:	60e2                	ld	ra,24(sp)
ffffffffc02010d4:	0000b517          	auipc	a0,0xb
ffffffffc02010d8:	24c50513          	addi	a0,a0,588 # ffffffffc020c320 <etext+0xa4a>
ffffffffc02010dc:	6105                	addi	sp,sp,32
ffffffffc02010de:	84aff06f          	j	ffffffffc0200128 <cprintf>
ffffffffc02010e2:	60e2                	ld	ra,24(sp)
ffffffffc02010e4:	6105                	addi	sp,sp,32
ffffffffc02010e6:	b529                	j	ffffffffc0200ef0 <print_trapframe>
ffffffffc02010e8:	0000b617          	auipc	a2,0xb
ffffffffc02010ec:	20860613          	addi	a2,a2,520 # ffffffffc020c2f0 <etext+0xa1a>
ffffffffc02010f0:	0b300593          	li	a1,179
ffffffffc02010f4:	0000b517          	auipc	a0,0xb
ffffffffc02010f8:	21450513          	addi	a0,a0,532 # ffffffffc020c308 <etext+0xa32>
ffffffffc02010fc:	930ff0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201100:	bbc5                	j	ffffffffc0200ef0 <print_trapframe>

ffffffffc0201102 <trap>:
ffffffffc0201102:	00095717          	auipc	a4,0x95
ffffffffc0201106:	7c673703          	ld	a4,1990(a4) # ffffffffc02968c8 <current>
ffffffffc020110a:	11853583          	ld	a1,280(a0)
ffffffffc020110e:	cf21                	beqz	a4,ffffffffc0201166 <trap+0x64>
ffffffffc0201110:	10053603          	ld	a2,256(a0)
ffffffffc0201114:	0a073803          	ld	a6,160(a4)
ffffffffc0201118:	1101                	addi	sp,sp,-32
ffffffffc020111a:	ec06                	sd	ra,24(sp)
ffffffffc020111c:	10067613          	andi	a2,a2,256
ffffffffc0201120:	f348                	sd	a0,160(a4)
ffffffffc0201122:	e432                	sd	a2,8(sp)
ffffffffc0201124:	e042                	sd	a6,0(sp)
ffffffffc0201126:	0205c763          	bltz	a1,ffffffffc0201154 <trap+0x52>
ffffffffc020112a:	eb5ff0ef          	jal	ffffffffc0200fde <exception_handler>
ffffffffc020112e:	6622                	ld	a2,8(sp)
ffffffffc0201130:	6802                	ld	a6,0(sp)
ffffffffc0201132:	00095697          	auipc	a3,0x95
ffffffffc0201136:	79668693          	addi	a3,a3,1942 # ffffffffc02968c8 <current>
ffffffffc020113a:	6298                	ld	a4,0(a3)
ffffffffc020113c:	0b073023          	sd	a6,160(a4)
ffffffffc0201140:	e619                	bnez	a2,ffffffffc020114e <trap+0x4c>
ffffffffc0201142:	0b072783          	lw	a5,176(a4)
ffffffffc0201146:	8b85                	andi	a5,a5,1
ffffffffc0201148:	e79d                	bnez	a5,ffffffffc0201176 <trap+0x74>
ffffffffc020114a:	6f1c                	ld	a5,24(a4)
ffffffffc020114c:	e38d                	bnez	a5,ffffffffc020116e <trap+0x6c>
ffffffffc020114e:	60e2                	ld	ra,24(sp)
ffffffffc0201150:	6105                	addi	sp,sp,32
ffffffffc0201152:	8082                	ret
ffffffffc0201154:	dffff0ef          	jal	ffffffffc0200f52 <interrupt_handler>
ffffffffc0201158:	6802                	ld	a6,0(sp)
ffffffffc020115a:	6622                	ld	a2,8(sp)
ffffffffc020115c:	00095697          	auipc	a3,0x95
ffffffffc0201160:	76c68693          	addi	a3,a3,1900 # ffffffffc02968c8 <current>
ffffffffc0201164:	bfd9                	j	ffffffffc020113a <trap+0x38>
ffffffffc0201166:	0005c363          	bltz	a1,ffffffffc020116c <trap+0x6a>
ffffffffc020116a:	bd95                	j	ffffffffc0200fde <exception_handler>
ffffffffc020116c:	b3dd                	j	ffffffffc0200f52 <interrupt_handler>
ffffffffc020116e:	60e2                	ld	ra,24(sp)
ffffffffc0201170:	6105                	addi	sp,sp,32
ffffffffc0201172:	3600606f          	j	ffffffffc02074d2 <schedule>
ffffffffc0201176:	555d                	li	a0,-9
ffffffffc0201178:	024050ef          	jal	ffffffffc020619c <do_exit>
ffffffffc020117c:	00095717          	auipc	a4,0x95
ffffffffc0201180:	74c73703          	ld	a4,1868(a4) # ffffffffc02968c8 <current>
ffffffffc0201184:	b7d9                	j	ffffffffc020114a <trap+0x48>
	...

ffffffffc0201188 <__alltraps>:
ffffffffc0201188:	14011173          	csrrw	sp,sscratch,sp
ffffffffc020118c:	00011463          	bnez	sp,ffffffffc0201194 <__alltraps+0xc>
ffffffffc0201190:	14002173          	csrr	sp,sscratch
ffffffffc0201194:	712d                	addi	sp,sp,-288
ffffffffc0201196:	e002                	sd	zero,0(sp)
ffffffffc0201198:	e406                	sd	ra,8(sp)
ffffffffc020119a:	ec0e                	sd	gp,24(sp)
ffffffffc020119c:	f012                	sd	tp,32(sp)
ffffffffc020119e:	f416                	sd	t0,40(sp)
ffffffffc02011a0:	f81a                	sd	t1,48(sp)
ffffffffc02011a2:	fc1e                	sd	t2,56(sp)
ffffffffc02011a4:	e0a2                	sd	s0,64(sp)
ffffffffc02011a6:	e4a6                	sd	s1,72(sp)
ffffffffc02011a8:	e8aa                	sd	a0,80(sp)
ffffffffc02011aa:	ecae                	sd	a1,88(sp)
ffffffffc02011ac:	f0b2                	sd	a2,96(sp)
ffffffffc02011ae:	f4b6                	sd	a3,104(sp)
ffffffffc02011b0:	f8ba                	sd	a4,112(sp)
ffffffffc02011b2:	fcbe                	sd	a5,120(sp)
ffffffffc02011b4:	e142                	sd	a6,128(sp)
ffffffffc02011b6:	e546                	sd	a7,136(sp)
ffffffffc02011b8:	e94a                	sd	s2,144(sp)
ffffffffc02011ba:	ed4e                	sd	s3,152(sp)
ffffffffc02011bc:	f152                	sd	s4,160(sp)
ffffffffc02011be:	f556                	sd	s5,168(sp)
ffffffffc02011c0:	f95a                	sd	s6,176(sp)
ffffffffc02011c2:	fd5e                	sd	s7,184(sp)
ffffffffc02011c4:	e1e2                	sd	s8,192(sp)
ffffffffc02011c6:	e5e6                	sd	s9,200(sp)
ffffffffc02011c8:	e9ea                	sd	s10,208(sp)
ffffffffc02011ca:	edee                	sd	s11,216(sp)
ffffffffc02011cc:	f1f2                	sd	t3,224(sp)
ffffffffc02011ce:	f5f6                	sd	t4,232(sp)
ffffffffc02011d0:	f9fa                	sd	t5,240(sp)
ffffffffc02011d2:	fdfe                	sd	t6,248(sp)
ffffffffc02011d4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02011d8:	100024f3          	csrr	s1,sstatus
ffffffffc02011dc:	14102973          	csrr	s2,sepc
ffffffffc02011e0:	143029f3          	csrr	s3,stval
ffffffffc02011e4:	14202a73          	csrr	s4,scause
ffffffffc02011e8:	e822                	sd	s0,16(sp)
ffffffffc02011ea:	e226                	sd	s1,256(sp)
ffffffffc02011ec:	e64a                	sd	s2,264(sp)
ffffffffc02011ee:	ea4e                	sd	s3,272(sp)
ffffffffc02011f0:	ee52                	sd	s4,280(sp)
ffffffffc02011f2:	850a                	mv	a0,sp
ffffffffc02011f4:	f0fff0ef          	jal	ffffffffc0201102 <trap>

ffffffffc02011f8 <__trapret>:
ffffffffc02011f8:	6492                	ld	s1,256(sp)
ffffffffc02011fa:	6932                	ld	s2,264(sp)
ffffffffc02011fc:	1004f413          	andi	s0,s1,256
ffffffffc0201200:	e401                	bnez	s0,ffffffffc0201208 <__trapret+0x10>
ffffffffc0201202:	1200                	addi	s0,sp,288
ffffffffc0201204:	14041073          	csrw	sscratch,s0
ffffffffc0201208:	10049073          	csrw	sstatus,s1
ffffffffc020120c:	14191073          	csrw	sepc,s2
ffffffffc0201210:	60a2                	ld	ra,8(sp)
ffffffffc0201212:	61e2                	ld	gp,24(sp)
ffffffffc0201214:	7202                	ld	tp,32(sp)
ffffffffc0201216:	72a2                	ld	t0,40(sp)
ffffffffc0201218:	7342                	ld	t1,48(sp)
ffffffffc020121a:	73e2                	ld	t2,56(sp)
ffffffffc020121c:	6406                	ld	s0,64(sp)
ffffffffc020121e:	64a6                	ld	s1,72(sp)
ffffffffc0201220:	6546                	ld	a0,80(sp)
ffffffffc0201222:	65e6                	ld	a1,88(sp)
ffffffffc0201224:	7606                	ld	a2,96(sp)
ffffffffc0201226:	76a6                	ld	a3,104(sp)
ffffffffc0201228:	7746                	ld	a4,112(sp)
ffffffffc020122a:	77e6                	ld	a5,120(sp)
ffffffffc020122c:	680a                	ld	a6,128(sp)
ffffffffc020122e:	68aa                	ld	a7,136(sp)
ffffffffc0201230:	694a                	ld	s2,144(sp)
ffffffffc0201232:	69ea                	ld	s3,152(sp)
ffffffffc0201234:	7a0a                	ld	s4,160(sp)
ffffffffc0201236:	7aaa                	ld	s5,168(sp)
ffffffffc0201238:	7b4a                	ld	s6,176(sp)
ffffffffc020123a:	7bea                	ld	s7,184(sp)
ffffffffc020123c:	6c0e                	ld	s8,192(sp)
ffffffffc020123e:	6cae                	ld	s9,200(sp)
ffffffffc0201240:	6d4e                	ld	s10,208(sp)
ffffffffc0201242:	6dee                	ld	s11,216(sp)
ffffffffc0201244:	7e0e                	ld	t3,224(sp)
ffffffffc0201246:	7eae                	ld	t4,232(sp)
ffffffffc0201248:	7f4e                	ld	t5,240(sp)
ffffffffc020124a:	7fee                	ld	t6,248(sp)
ffffffffc020124c:	6142                	ld	sp,16(sp)
ffffffffc020124e:	10200073          	sret

ffffffffc0201252 <forkrets>:
ffffffffc0201252:	812a                	mv	sp,a0
ffffffffc0201254:	b755                	j	ffffffffc02011f8 <__trapret>

ffffffffc0201256 <check_vma_overlap.part.0>:
ffffffffc0201256:	1141                	addi	sp,sp,-16
ffffffffc0201258:	0000b697          	auipc	a3,0xb
ffffffffc020125c:	18868693          	addi	a3,a3,392 # ffffffffc020c3e0 <etext+0xb0a>
ffffffffc0201260:	0000b617          	auipc	a2,0xb
ffffffffc0201264:	b3060613          	addi	a2,a2,-1232 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201268:	07400593          	li	a1,116
ffffffffc020126c:	0000b517          	auipc	a0,0xb
ffffffffc0201270:	19450513          	addi	a0,a0,404 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201274:	e406                	sd	ra,8(sp)
ffffffffc0201276:	fb7fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020127a <mm_create>:
ffffffffc020127a:	1101                	addi	sp,sp,-32
ffffffffc020127c:	05800513          	li	a0,88
ffffffffc0201280:	ec06                	sd	ra,24(sp)
ffffffffc0201282:	2bb000ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0201286:	87aa                	mv	a5,a0
ffffffffc0201288:	c505                	beqz	a0,ffffffffc02012b0 <mm_create+0x36>
ffffffffc020128a:	e788                	sd	a0,8(a5)
ffffffffc020128c:	e388                	sd	a0,0(a5)
ffffffffc020128e:	00053823          	sd	zero,16(a0)
ffffffffc0201292:	00053c23          	sd	zero,24(a0)
ffffffffc0201296:	02052023          	sw	zero,32(a0)
ffffffffc020129a:	02053423          	sd	zero,40(a0)
ffffffffc020129e:	02052823          	sw	zero,48(a0)
ffffffffc02012a2:	4585                	li	a1,1
ffffffffc02012a4:	03850513          	addi	a0,a0,56
ffffffffc02012a8:	e43e                	sd	a5,8(sp)
ffffffffc02012aa:	522030ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc02012ae:	67a2                	ld	a5,8(sp)
ffffffffc02012b0:	60e2                	ld	ra,24(sp)
ffffffffc02012b2:	853e                	mv	a0,a5
ffffffffc02012b4:	6105                	addi	sp,sp,32
ffffffffc02012b6:	8082                	ret

ffffffffc02012b8 <find_vma>:
ffffffffc02012b8:	c505                	beqz	a0,ffffffffc02012e0 <find_vma+0x28>
ffffffffc02012ba:	691c                	ld	a5,16(a0)
ffffffffc02012bc:	c781                	beqz	a5,ffffffffc02012c4 <find_vma+0xc>
ffffffffc02012be:	6798                	ld	a4,8(a5)
ffffffffc02012c0:	02e5f363          	bgeu	a1,a4,ffffffffc02012e6 <find_vma+0x2e>
ffffffffc02012c4:	651c                	ld	a5,8(a0)
ffffffffc02012c6:	00f50d63          	beq	a0,a5,ffffffffc02012e0 <find_vma+0x28>
ffffffffc02012ca:	fe87b703          	ld	a4,-24(a5)
ffffffffc02012ce:	00e5e663          	bltu	a1,a4,ffffffffc02012da <find_vma+0x22>
ffffffffc02012d2:	ff07b703          	ld	a4,-16(a5)
ffffffffc02012d6:	00e5ee63          	bltu	a1,a4,ffffffffc02012f2 <find_vma+0x3a>
ffffffffc02012da:	679c                	ld	a5,8(a5)
ffffffffc02012dc:	fef517e3          	bne	a0,a5,ffffffffc02012ca <find_vma+0x12>
ffffffffc02012e0:	4781                	li	a5,0
ffffffffc02012e2:	853e                	mv	a0,a5
ffffffffc02012e4:	8082                	ret
ffffffffc02012e6:	6b98                	ld	a4,16(a5)
ffffffffc02012e8:	fce5fee3          	bgeu	a1,a4,ffffffffc02012c4 <find_vma+0xc>
ffffffffc02012ec:	e91c                	sd	a5,16(a0)
ffffffffc02012ee:	853e                	mv	a0,a5
ffffffffc02012f0:	8082                	ret
ffffffffc02012f2:	1781                	addi	a5,a5,-32
ffffffffc02012f4:	e91c                	sd	a5,16(a0)
ffffffffc02012f6:	bfe5                	j	ffffffffc02012ee <find_vma+0x36>

ffffffffc02012f8 <insert_vma_struct>:
ffffffffc02012f8:	6590                	ld	a2,8(a1)
ffffffffc02012fa:	0105b803          	ld	a6,16(a1)
ffffffffc02012fe:	1141                	addi	sp,sp,-16
ffffffffc0201300:	e406                	sd	ra,8(sp)
ffffffffc0201302:	87aa                	mv	a5,a0
ffffffffc0201304:	01066763          	bltu	a2,a6,ffffffffc0201312 <insert_vma_struct+0x1a>
ffffffffc0201308:	a8b9                	j	ffffffffc0201366 <insert_vma_struct+0x6e>
ffffffffc020130a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020130e:	04e66763          	bltu	a2,a4,ffffffffc020135c <insert_vma_struct+0x64>
ffffffffc0201312:	86be                	mv	a3,a5
ffffffffc0201314:	679c                	ld	a5,8(a5)
ffffffffc0201316:	fef51ae3          	bne	a0,a5,ffffffffc020130a <insert_vma_struct+0x12>
ffffffffc020131a:	02a68463          	beq	a3,a0,ffffffffc0201342 <insert_vma_struct+0x4a>
ffffffffc020131e:	ff06b703          	ld	a4,-16(a3)
ffffffffc0201322:	fe86b883          	ld	a7,-24(a3)
ffffffffc0201326:	08e8f063          	bgeu	a7,a4,ffffffffc02013a6 <insert_vma_struct+0xae>
ffffffffc020132a:	04e66e63          	bltu	a2,a4,ffffffffc0201386 <insert_vma_struct+0x8e>
ffffffffc020132e:	00f50a63          	beq	a0,a5,ffffffffc0201342 <insert_vma_struct+0x4a>
ffffffffc0201332:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201336:	05076863          	bltu	a4,a6,ffffffffc0201386 <insert_vma_struct+0x8e>
ffffffffc020133a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020133e:	02c77263          	bgeu	a4,a2,ffffffffc0201362 <insert_vma_struct+0x6a>
ffffffffc0201342:	5118                	lw	a4,32(a0)
ffffffffc0201344:	e188                	sd	a0,0(a1)
ffffffffc0201346:	02058613          	addi	a2,a1,32
ffffffffc020134a:	e390                	sd	a2,0(a5)
ffffffffc020134c:	e690                	sd	a2,8(a3)
ffffffffc020134e:	60a2                	ld	ra,8(sp)
ffffffffc0201350:	f59c                	sd	a5,40(a1)
ffffffffc0201352:	f194                	sd	a3,32(a1)
ffffffffc0201354:	2705                	addiw	a4,a4,1
ffffffffc0201356:	d118                	sw	a4,32(a0)
ffffffffc0201358:	0141                	addi	sp,sp,16
ffffffffc020135a:	8082                	ret
ffffffffc020135c:	fca691e3          	bne	a3,a0,ffffffffc020131e <insert_vma_struct+0x26>
ffffffffc0201360:	bfd9                	j	ffffffffc0201336 <insert_vma_struct+0x3e>
ffffffffc0201362:	ef5ff0ef          	jal	ffffffffc0201256 <check_vma_overlap.part.0>
ffffffffc0201366:	0000b697          	auipc	a3,0xb
ffffffffc020136a:	0aa68693          	addi	a3,a3,170 # ffffffffc020c410 <etext+0xb3a>
ffffffffc020136e:	0000b617          	auipc	a2,0xb
ffffffffc0201372:	a2260613          	addi	a2,a2,-1502 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201376:	07a00593          	li	a1,122
ffffffffc020137a:	0000b517          	auipc	a0,0xb
ffffffffc020137e:	08650513          	addi	a0,a0,134 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201382:	eabfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201386:	0000b697          	auipc	a3,0xb
ffffffffc020138a:	0ca68693          	addi	a3,a3,202 # ffffffffc020c450 <etext+0xb7a>
ffffffffc020138e:	0000b617          	auipc	a2,0xb
ffffffffc0201392:	a0260613          	addi	a2,a2,-1534 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201396:	07300593          	li	a1,115
ffffffffc020139a:	0000b517          	auipc	a0,0xb
ffffffffc020139e:	06650513          	addi	a0,a0,102 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02013a2:	e8bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02013a6:	0000b697          	auipc	a3,0xb
ffffffffc02013aa:	08a68693          	addi	a3,a3,138 # ffffffffc020c430 <etext+0xb5a>
ffffffffc02013ae:	0000b617          	auipc	a2,0xb
ffffffffc02013b2:	9e260613          	addi	a2,a2,-1566 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02013b6:	07200593          	li	a1,114
ffffffffc02013ba:	0000b517          	auipc	a0,0xb
ffffffffc02013be:	04650513          	addi	a0,a0,70 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02013c2:	e6bfe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02013c6 <mm_destroy>:
ffffffffc02013c6:	591c                	lw	a5,48(a0)
ffffffffc02013c8:	1141                	addi	sp,sp,-16
ffffffffc02013ca:	e406                	sd	ra,8(sp)
ffffffffc02013cc:	e022                	sd	s0,0(sp)
ffffffffc02013ce:	e78d                	bnez	a5,ffffffffc02013f8 <mm_destroy+0x32>
ffffffffc02013d0:	842a                	mv	s0,a0
ffffffffc02013d2:	6508                	ld	a0,8(a0)
ffffffffc02013d4:	00a40c63          	beq	s0,a0,ffffffffc02013ec <mm_destroy+0x26>
ffffffffc02013d8:	6118                	ld	a4,0(a0)
ffffffffc02013da:	651c                	ld	a5,8(a0)
ffffffffc02013dc:	1501                	addi	a0,a0,-32
ffffffffc02013de:	e71c                	sd	a5,8(a4)
ffffffffc02013e0:	e398                	sd	a4,0(a5)
ffffffffc02013e2:	201000ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc02013e6:	6408                	ld	a0,8(s0)
ffffffffc02013e8:	fea418e3          	bne	s0,a0,ffffffffc02013d8 <mm_destroy+0x12>
ffffffffc02013ec:	8522                	mv	a0,s0
ffffffffc02013ee:	6402                	ld	s0,0(sp)
ffffffffc02013f0:	60a2                	ld	ra,8(sp)
ffffffffc02013f2:	0141                	addi	sp,sp,16
ffffffffc02013f4:	1ef0006f          	j	ffffffffc0201de2 <kfree>
ffffffffc02013f8:	0000b697          	auipc	a3,0xb
ffffffffc02013fc:	07868693          	addi	a3,a3,120 # ffffffffc020c470 <etext+0xb9a>
ffffffffc0201400:	0000b617          	auipc	a2,0xb
ffffffffc0201404:	99060613          	addi	a2,a2,-1648 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201408:	09e00593          	li	a1,158
ffffffffc020140c:	0000b517          	auipc	a0,0xb
ffffffffc0201410:	ff450513          	addi	a0,a0,-12 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201414:	e19fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201418 <mm_map>:
ffffffffc0201418:	6785                	lui	a5,0x1
ffffffffc020141a:	17fd                	addi	a5,a5,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020141c:	963e                	add	a2,a2,a5
ffffffffc020141e:	4785                	li	a5,1
ffffffffc0201420:	7139                	addi	sp,sp,-64
ffffffffc0201422:	962e                	add	a2,a2,a1
ffffffffc0201424:	787d                	lui	a6,0xfffff
ffffffffc0201426:	07fe                	slli	a5,a5,0x1f
ffffffffc0201428:	f822                	sd	s0,48(sp)
ffffffffc020142a:	f426                	sd	s1,40(sp)
ffffffffc020142c:	01067433          	and	s0,a2,a6
ffffffffc0201430:	0105f4b3          	and	s1,a1,a6
ffffffffc0201434:	0785                	addi	a5,a5,1
ffffffffc0201436:	0084b633          	sltu	a2,s1,s0
ffffffffc020143a:	00f437b3          	sltu	a5,s0,a5
ffffffffc020143e:	00163613          	seqz	a2,a2
ffffffffc0201442:	0017b793          	seqz	a5,a5
ffffffffc0201446:	fc06                	sd	ra,56(sp)
ffffffffc0201448:	8fd1                	or	a5,a5,a2
ffffffffc020144a:	ebbd                	bnez	a5,ffffffffc02014c0 <mm_map+0xa8>
ffffffffc020144c:	002007b7          	lui	a5,0x200
ffffffffc0201450:	06f4e863          	bltu	s1,a5,ffffffffc02014c0 <mm_map+0xa8>
ffffffffc0201454:	f04a                	sd	s2,32(sp)
ffffffffc0201456:	ec4e                	sd	s3,24(sp)
ffffffffc0201458:	e852                	sd	s4,16(sp)
ffffffffc020145a:	892a                	mv	s2,a0
ffffffffc020145c:	89ba                	mv	s3,a4
ffffffffc020145e:	8a36                	mv	s4,a3
ffffffffc0201460:	c135                	beqz	a0,ffffffffc02014c4 <mm_map+0xac>
ffffffffc0201462:	85a6                	mv	a1,s1
ffffffffc0201464:	e55ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc0201468:	c501                	beqz	a0,ffffffffc0201470 <mm_map+0x58>
ffffffffc020146a:	651c                	ld	a5,8(a0)
ffffffffc020146c:	0487e763          	bltu	a5,s0,ffffffffc02014ba <mm_map+0xa2>
ffffffffc0201470:	03000513          	li	a0,48
ffffffffc0201474:	0c9000ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0201478:	85aa                	mv	a1,a0
ffffffffc020147a:	5571                	li	a0,-4
ffffffffc020147c:	c59d                	beqz	a1,ffffffffc02014aa <mm_map+0x92>
ffffffffc020147e:	e584                	sd	s1,8(a1)
ffffffffc0201480:	e980                	sd	s0,16(a1)
ffffffffc0201482:	0145ac23          	sw	s4,24(a1)
ffffffffc0201486:	854a                	mv	a0,s2
ffffffffc0201488:	e42e                	sd	a1,8(sp)
ffffffffc020148a:	e6fff0ef          	jal	ffffffffc02012f8 <insert_vma_struct>
ffffffffc020148e:	65a2                	ld	a1,8(sp)
ffffffffc0201490:	00098463          	beqz	s3,ffffffffc0201498 <mm_map+0x80>
ffffffffc0201494:	00b9b023          	sd	a1,0(s3)
ffffffffc0201498:	7902                	ld	s2,32(sp)
ffffffffc020149a:	69e2                	ld	s3,24(sp)
ffffffffc020149c:	6a42                	ld	s4,16(sp)
ffffffffc020149e:	4501                	li	a0,0
ffffffffc02014a0:	70e2                	ld	ra,56(sp)
ffffffffc02014a2:	7442                	ld	s0,48(sp)
ffffffffc02014a4:	74a2                	ld	s1,40(sp)
ffffffffc02014a6:	6121                	addi	sp,sp,64
ffffffffc02014a8:	8082                	ret
ffffffffc02014aa:	70e2                	ld	ra,56(sp)
ffffffffc02014ac:	7442                	ld	s0,48(sp)
ffffffffc02014ae:	7902                	ld	s2,32(sp)
ffffffffc02014b0:	69e2                	ld	s3,24(sp)
ffffffffc02014b2:	6a42                	ld	s4,16(sp)
ffffffffc02014b4:	74a2                	ld	s1,40(sp)
ffffffffc02014b6:	6121                	addi	sp,sp,64
ffffffffc02014b8:	8082                	ret
ffffffffc02014ba:	7902                	ld	s2,32(sp)
ffffffffc02014bc:	69e2                	ld	s3,24(sp)
ffffffffc02014be:	6a42                	ld	s4,16(sp)
ffffffffc02014c0:	5575                	li	a0,-3
ffffffffc02014c2:	bff9                	j	ffffffffc02014a0 <mm_map+0x88>
ffffffffc02014c4:	0000b697          	auipc	a3,0xb
ffffffffc02014c8:	fc468693          	addi	a3,a3,-60 # ffffffffc020c488 <etext+0xbb2>
ffffffffc02014cc:	0000b617          	auipc	a2,0xb
ffffffffc02014d0:	8c460613          	addi	a2,a2,-1852 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02014d4:	0b300593          	li	a1,179
ffffffffc02014d8:	0000b517          	auipc	a0,0xb
ffffffffc02014dc:	f2850513          	addi	a0,a0,-216 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02014e0:	d4dfe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02014e4 <dup_mmap>:
ffffffffc02014e4:	7139                	addi	sp,sp,-64
ffffffffc02014e6:	fc06                	sd	ra,56(sp)
ffffffffc02014e8:	f822                	sd	s0,48(sp)
ffffffffc02014ea:	f426                	sd	s1,40(sp)
ffffffffc02014ec:	f04a                	sd	s2,32(sp)
ffffffffc02014ee:	ec4e                	sd	s3,24(sp)
ffffffffc02014f0:	e852                	sd	s4,16(sp)
ffffffffc02014f2:	e456                	sd	s5,8(sp)
ffffffffc02014f4:	c525                	beqz	a0,ffffffffc020155c <dup_mmap+0x78>
ffffffffc02014f6:	892a                	mv	s2,a0
ffffffffc02014f8:	84ae                	mv	s1,a1
ffffffffc02014fa:	842e                	mv	s0,a1
ffffffffc02014fc:	c1a5                	beqz	a1,ffffffffc020155c <dup_mmap+0x78>
ffffffffc02014fe:	6000                	ld	s0,0(s0)
ffffffffc0201500:	04848c63          	beq	s1,s0,ffffffffc0201558 <dup_mmap+0x74>
ffffffffc0201504:	03000513          	li	a0,48
ffffffffc0201508:	fe843a83          	ld	s5,-24(s0)
ffffffffc020150c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0201510:	ff842983          	lw	s3,-8(s0)
ffffffffc0201514:	029000ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0201518:	c515                	beqz	a0,ffffffffc0201544 <dup_mmap+0x60>
ffffffffc020151a:	85aa                	mv	a1,a0
ffffffffc020151c:	01553423          	sd	s5,8(a0)
ffffffffc0201520:	01453823          	sd	s4,16(a0)
ffffffffc0201524:	01352c23          	sw	s3,24(a0)
ffffffffc0201528:	854a                	mv	a0,s2
ffffffffc020152a:	dcfff0ef          	jal	ffffffffc02012f8 <insert_vma_struct>
ffffffffc020152e:	ff043683          	ld	a3,-16(s0)
ffffffffc0201532:	fe843603          	ld	a2,-24(s0)
ffffffffc0201536:	6c8c                	ld	a1,24(s1)
ffffffffc0201538:	01893503          	ld	a0,24(s2)
ffffffffc020153c:	4701                	li	a4,0
ffffffffc020153e:	459020ef          	jal	ffffffffc0204196 <copy_range>
ffffffffc0201542:	dd55                	beqz	a0,ffffffffc02014fe <dup_mmap+0x1a>
ffffffffc0201544:	5571                	li	a0,-4
ffffffffc0201546:	70e2                	ld	ra,56(sp)
ffffffffc0201548:	7442                	ld	s0,48(sp)
ffffffffc020154a:	74a2                	ld	s1,40(sp)
ffffffffc020154c:	7902                	ld	s2,32(sp)
ffffffffc020154e:	69e2                	ld	s3,24(sp)
ffffffffc0201550:	6a42                	ld	s4,16(sp)
ffffffffc0201552:	6aa2                	ld	s5,8(sp)
ffffffffc0201554:	6121                	addi	sp,sp,64
ffffffffc0201556:	8082                	ret
ffffffffc0201558:	4501                	li	a0,0
ffffffffc020155a:	b7f5                	j	ffffffffc0201546 <dup_mmap+0x62>
ffffffffc020155c:	0000b697          	auipc	a3,0xb
ffffffffc0201560:	f3c68693          	addi	a3,a3,-196 # ffffffffc020c498 <etext+0xbc2>
ffffffffc0201564:	0000b617          	auipc	a2,0xb
ffffffffc0201568:	82c60613          	addi	a2,a2,-2004 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020156c:	0cf00593          	li	a1,207
ffffffffc0201570:	0000b517          	auipc	a0,0xb
ffffffffc0201574:	e9050513          	addi	a0,a0,-368 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201578:	cb5fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020157c <exit_mmap>:
ffffffffc020157c:	1101                	addi	sp,sp,-32
ffffffffc020157e:	ec06                	sd	ra,24(sp)
ffffffffc0201580:	e822                	sd	s0,16(sp)
ffffffffc0201582:	e426                	sd	s1,8(sp)
ffffffffc0201584:	e04a                	sd	s2,0(sp)
ffffffffc0201586:	c531                	beqz	a0,ffffffffc02015d2 <exit_mmap+0x56>
ffffffffc0201588:	591c                	lw	a5,48(a0)
ffffffffc020158a:	84aa                	mv	s1,a0
ffffffffc020158c:	e3b9                	bnez	a5,ffffffffc02015d2 <exit_mmap+0x56>
ffffffffc020158e:	6500                	ld	s0,8(a0)
ffffffffc0201590:	01853903          	ld	s2,24(a0)
ffffffffc0201594:	02850663          	beq	a0,s0,ffffffffc02015c0 <exit_mmap+0x44>
ffffffffc0201598:	ff043603          	ld	a2,-16(s0)
ffffffffc020159c:	fe843583          	ld	a1,-24(s0)
ffffffffc02015a0:	854a                	mv	a0,s2
ffffffffc02015a2:	069010ef          	jal	ffffffffc0202e0a <unmap_range>
ffffffffc02015a6:	6400                	ld	s0,8(s0)
ffffffffc02015a8:	fe8498e3          	bne	s1,s0,ffffffffc0201598 <exit_mmap+0x1c>
ffffffffc02015ac:	6400                	ld	s0,8(s0)
ffffffffc02015ae:	00848c63          	beq	s1,s0,ffffffffc02015c6 <exit_mmap+0x4a>
ffffffffc02015b2:	ff043603          	ld	a2,-16(s0)
ffffffffc02015b6:	fe843583          	ld	a1,-24(s0)
ffffffffc02015ba:	854a                	mv	a0,s2
ffffffffc02015bc:	183010ef          	jal	ffffffffc0202f3e <exit_range>
ffffffffc02015c0:	6400                	ld	s0,8(s0)
ffffffffc02015c2:	fe8498e3          	bne	s1,s0,ffffffffc02015b2 <exit_mmap+0x36>
ffffffffc02015c6:	60e2                	ld	ra,24(sp)
ffffffffc02015c8:	6442                	ld	s0,16(sp)
ffffffffc02015ca:	64a2                	ld	s1,8(sp)
ffffffffc02015cc:	6902                	ld	s2,0(sp)
ffffffffc02015ce:	6105                	addi	sp,sp,32
ffffffffc02015d0:	8082                	ret
ffffffffc02015d2:	0000b697          	auipc	a3,0xb
ffffffffc02015d6:	ee668693          	addi	a3,a3,-282 # ffffffffc020c4b8 <etext+0xbe2>
ffffffffc02015da:	0000a617          	auipc	a2,0xa
ffffffffc02015de:	7b660613          	addi	a2,a2,1974 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02015e2:	0e800593          	li	a1,232
ffffffffc02015e6:	0000b517          	auipc	a0,0xb
ffffffffc02015ea:	e1a50513          	addi	a0,a0,-486 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02015ee:	c3ffe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02015f2 <vmm_init>:
ffffffffc02015f2:	7179                	addi	sp,sp,-48
ffffffffc02015f4:	05800513          	li	a0,88
ffffffffc02015f8:	f406                	sd	ra,40(sp)
ffffffffc02015fa:	f022                	sd	s0,32(sp)
ffffffffc02015fc:	ec26                	sd	s1,24(sp)
ffffffffc02015fe:	e84a                	sd	s2,16(sp)
ffffffffc0201600:	e44e                	sd	s3,8(sp)
ffffffffc0201602:	e052                	sd	s4,0(sp)
ffffffffc0201604:	738000ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0201608:	16050f63          	beqz	a0,ffffffffc0201786 <vmm_init+0x194>
ffffffffc020160c:	e508                	sd	a0,8(a0)
ffffffffc020160e:	e108                	sd	a0,0(a0)
ffffffffc0201610:	00053823          	sd	zero,16(a0)
ffffffffc0201614:	00053c23          	sd	zero,24(a0)
ffffffffc0201618:	02052023          	sw	zero,32(a0)
ffffffffc020161c:	02053423          	sd	zero,40(a0)
ffffffffc0201620:	02052823          	sw	zero,48(a0)
ffffffffc0201624:	842a                	mv	s0,a0
ffffffffc0201626:	4585                	li	a1,1
ffffffffc0201628:	03850513          	addi	a0,a0,56
ffffffffc020162c:	1a0030ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc0201630:	03200493          	li	s1,50
ffffffffc0201634:	03000513          	li	a0,48
ffffffffc0201638:	704000ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020163c:	12050563          	beqz	a0,ffffffffc0201766 <vmm_init+0x174>
ffffffffc0201640:	00248793          	addi	a5,s1,2
ffffffffc0201644:	e504                	sd	s1,8(a0)
ffffffffc0201646:	00052c23          	sw	zero,24(a0)
ffffffffc020164a:	e91c                	sd	a5,16(a0)
ffffffffc020164c:	85aa                	mv	a1,a0
ffffffffc020164e:	14ed                	addi	s1,s1,-5
ffffffffc0201650:	8522                	mv	a0,s0
ffffffffc0201652:	ca7ff0ef          	jal	ffffffffc02012f8 <insert_vma_struct>
ffffffffc0201656:	fcf9                	bnez	s1,ffffffffc0201634 <vmm_init+0x42>
ffffffffc0201658:	03700493          	li	s1,55
ffffffffc020165c:	1f900913          	li	s2,505
ffffffffc0201660:	03000513          	li	a0,48
ffffffffc0201664:	6d8000ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0201668:	12050f63          	beqz	a0,ffffffffc02017a6 <vmm_init+0x1b4>
ffffffffc020166c:	00248793          	addi	a5,s1,2
ffffffffc0201670:	e504                	sd	s1,8(a0)
ffffffffc0201672:	00052c23          	sw	zero,24(a0)
ffffffffc0201676:	e91c                	sd	a5,16(a0)
ffffffffc0201678:	85aa                	mv	a1,a0
ffffffffc020167a:	0495                	addi	s1,s1,5
ffffffffc020167c:	8522                	mv	a0,s0
ffffffffc020167e:	c7bff0ef          	jal	ffffffffc02012f8 <insert_vma_struct>
ffffffffc0201682:	fd249fe3          	bne	s1,s2,ffffffffc0201660 <vmm_init+0x6e>
ffffffffc0201686:	641c                	ld	a5,8(s0)
ffffffffc0201688:	471d                	li	a4,7
ffffffffc020168a:	1fb00593          	li	a1,507
ffffffffc020168e:	1ef40c63          	beq	s0,a5,ffffffffc0201886 <vmm_init+0x294>
ffffffffc0201692:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_bin_sfs_img_size+0x18ace8>
ffffffffc0201696:	ffe70693          	addi	a3,a4,-2
ffffffffc020169a:	12d61663          	bne	a2,a3,ffffffffc02017c6 <vmm_init+0x1d4>
ffffffffc020169e:	ff07b683          	ld	a3,-16(a5)
ffffffffc02016a2:	12e69263          	bne	a3,a4,ffffffffc02017c6 <vmm_init+0x1d4>
ffffffffc02016a6:	0715                	addi	a4,a4,5
ffffffffc02016a8:	679c                	ld	a5,8(a5)
ffffffffc02016aa:	feb712e3          	bne	a4,a1,ffffffffc020168e <vmm_init+0x9c>
ffffffffc02016ae:	491d                	li	s2,7
ffffffffc02016b0:	4495                	li	s1,5
ffffffffc02016b2:	85a6                	mv	a1,s1
ffffffffc02016b4:	8522                	mv	a0,s0
ffffffffc02016b6:	c03ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc02016ba:	8a2a                	mv	s4,a0
ffffffffc02016bc:	20050563          	beqz	a0,ffffffffc02018c6 <vmm_init+0x2d4>
ffffffffc02016c0:	00148593          	addi	a1,s1,1
ffffffffc02016c4:	8522                	mv	a0,s0
ffffffffc02016c6:	bf3ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc02016ca:	89aa                	mv	s3,a0
ffffffffc02016cc:	1c050d63          	beqz	a0,ffffffffc02018a6 <vmm_init+0x2b4>
ffffffffc02016d0:	85ca                	mv	a1,s2
ffffffffc02016d2:	8522                	mv	a0,s0
ffffffffc02016d4:	be5ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc02016d8:	18051763          	bnez	a0,ffffffffc0201866 <vmm_init+0x274>
ffffffffc02016dc:	00348593          	addi	a1,s1,3
ffffffffc02016e0:	8522                	mv	a0,s0
ffffffffc02016e2:	bd7ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc02016e6:	16051063          	bnez	a0,ffffffffc0201846 <vmm_init+0x254>
ffffffffc02016ea:	00448593          	addi	a1,s1,4
ffffffffc02016ee:	8522                	mv	a0,s0
ffffffffc02016f0:	bc9ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc02016f4:	12051963          	bnez	a0,ffffffffc0201826 <vmm_init+0x234>
ffffffffc02016f8:	008a3783          	ld	a5,8(s4)
ffffffffc02016fc:	10979563          	bne	a5,s1,ffffffffc0201806 <vmm_init+0x214>
ffffffffc0201700:	010a3783          	ld	a5,16(s4)
ffffffffc0201704:	11279163          	bne	a5,s2,ffffffffc0201806 <vmm_init+0x214>
ffffffffc0201708:	0089b783          	ld	a5,8(s3)
ffffffffc020170c:	0c979d63          	bne	a5,s1,ffffffffc02017e6 <vmm_init+0x1f4>
ffffffffc0201710:	0109b783          	ld	a5,16(s3)
ffffffffc0201714:	0d279963          	bne	a5,s2,ffffffffc02017e6 <vmm_init+0x1f4>
ffffffffc0201718:	0495                	addi	s1,s1,5
ffffffffc020171a:	1f900793          	li	a5,505
ffffffffc020171e:	0915                	addi	s2,s2,5
ffffffffc0201720:	f8f499e3          	bne	s1,a5,ffffffffc02016b2 <vmm_init+0xc0>
ffffffffc0201724:	4491                	li	s1,4
ffffffffc0201726:	597d                	li	s2,-1
ffffffffc0201728:	85a6                	mv	a1,s1
ffffffffc020172a:	8522                	mv	a0,s0
ffffffffc020172c:	b8dff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc0201730:	1a051b63          	bnez	a0,ffffffffc02018e6 <vmm_init+0x2f4>
ffffffffc0201734:	14fd                	addi	s1,s1,-1
ffffffffc0201736:	ff2499e3          	bne	s1,s2,ffffffffc0201728 <vmm_init+0x136>
ffffffffc020173a:	8522                	mv	a0,s0
ffffffffc020173c:	c8bff0ef          	jal	ffffffffc02013c6 <mm_destroy>
ffffffffc0201740:	0000b517          	auipc	a0,0xb
ffffffffc0201744:	ee850513          	addi	a0,a0,-280 # ffffffffc020c628 <etext+0xd52>
ffffffffc0201748:	9e1fe0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020174c:	7402                	ld	s0,32(sp)
ffffffffc020174e:	70a2                	ld	ra,40(sp)
ffffffffc0201750:	64e2                	ld	s1,24(sp)
ffffffffc0201752:	6942                	ld	s2,16(sp)
ffffffffc0201754:	69a2                	ld	s3,8(sp)
ffffffffc0201756:	6a02                	ld	s4,0(sp)
ffffffffc0201758:	0000b517          	auipc	a0,0xb
ffffffffc020175c:	ef050513          	addi	a0,a0,-272 # ffffffffc020c648 <etext+0xd72>
ffffffffc0201760:	6145                	addi	sp,sp,48
ffffffffc0201762:	9c7fe06f          	j	ffffffffc0200128 <cprintf>
ffffffffc0201766:	0000b697          	auipc	a3,0xb
ffffffffc020176a:	d7268693          	addi	a3,a3,-654 # ffffffffc020c4d8 <etext+0xc02>
ffffffffc020176e:	0000a617          	auipc	a2,0xa
ffffffffc0201772:	62260613          	addi	a2,a2,1570 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201776:	12c00593          	li	a1,300
ffffffffc020177a:	0000b517          	auipc	a0,0xb
ffffffffc020177e:	c8650513          	addi	a0,a0,-890 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201782:	aabfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201786:	0000b697          	auipc	a3,0xb
ffffffffc020178a:	d0268693          	addi	a3,a3,-766 # ffffffffc020c488 <etext+0xbb2>
ffffffffc020178e:	0000a617          	auipc	a2,0xa
ffffffffc0201792:	60260613          	addi	a2,a2,1538 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201796:	12400593          	li	a1,292
ffffffffc020179a:	0000b517          	auipc	a0,0xb
ffffffffc020179e:	c6650513          	addi	a0,a0,-922 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02017a2:	a8bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02017a6:	0000b697          	auipc	a3,0xb
ffffffffc02017aa:	d3268693          	addi	a3,a3,-718 # ffffffffc020c4d8 <etext+0xc02>
ffffffffc02017ae:	0000a617          	auipc	a2,0xa
ffffffffc02017b2:	5e260613          	addi	a2,a2,1506 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02017b6:	13300593          	li	a1,307
ffffffffc02017ba:	0000b517          	auipc	a0,0xb
ffffffffc02017be:	c4650513          	addi	a0,a0,-954 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02017c2:	a6bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02017c6:	0000b697          	auipc	a3,0xb
ffffffffc02017ca:	d3a68693          	addi	a3,a3,-710 # ffffffffc020c500 <etext+0xc2a>
ffffffffc02017ce:	0000a617          	auipc	a2,0xa
ffffffffc02017d2:	5c260613          	addi	a2,a2,1474 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02017d6:	13d00593          	li	a1,317
ffffffffc02017da:	0000b517          	auipc	a0,0xb
ffffffffc02017de:	c2650513          	addi	a0,a0,-986 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02017e2:	a4bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02017e6:	0000b697          	auipc	a3,0xb
ffffffffc02017ea:	dd268693          	addi	a3,a3,-558 # ffffffffc020c5b8 <etext+0xce2>
ffffffffc02017ee:	0000a617          	auipc	a2,0xa
ffffffffc02017f2:	5a260613          	addi	a2,a2,1442 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02017f6:	14f00593          	li	a1,335
ffffffffc02017fa:	0000b517          	auipc	a0,0xb
ffffffffc02017fe:	c0650513          	addi	a0,a0,-1018 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201802:	a2bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201806:	0000b697          	auipc	a3,0xb
ffffffffc020180a:	d8268693          	addi	a3,a3,-638 # ffffffffc020c588 <etext+0xcb2>
ffffffffc020180e:	0000a617          	auipc	a2,0xa
ffffffffc0201812:	58260613          	addi	a2,a2,1410 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201816:	14e00593          	li	a1,334
ffffffffc020181a:	0000b517          	auipc	a0,0xb
ffffffffc020181e:	be650513          	addi	a0,a0,-1050 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201822:	a0bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201826:	0000b697          	auipc	a3,0xb
ffffffffc020182a:	d5268693          	addi	a3,a3,-686 # ffffffffc020c578 <etext+0xca2>
ffffffffc020182e:	0000a617          	auipc	a2,0xa
ffffffffc0201832:	56260613          	addi	a2,a2,1378 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201836:	14c00593          	li	a1,332
ffffffffc020183a:	0000b517          	auipc	a0,0xb
ffffffffc020183e:	bc650513          	addi	a0,a0,-1082 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201842:	9ebfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201846:	0000b697          	auipc	a3,0xb
ffffffffc020184a:	d2268693          	addi	a3,a3,-734 # ffffffffc020c568 <etext+0xc92>
ffffffffc020184e:	0000a617          	auipc	a2,0xa
ffffffffc0201852:	54260613          	addi	a2,a2,1346 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201856:	14a00593          	li	a1,330
ffffffffc020185a:	0000b517          	auipc	a0,0xb
ffffffffc020185e:	ba650513          	addi	a0,a0,-1114 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201862:	9cbfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201866:	0000b697          	auipc	a3,0xb
ffffffffc020186a:	cf268693          	addi	a3,a3,-782 # ffffffffc020c558 <etext+0xc82>
ffffffffc020186e:	0000a617          	auipc	a2,0xa
ffffffffc0201872:	52260613          	addi	a2,a2,1314 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201876:	14800593          	li	a1,328
ffffffffc020187a:	0000b517          	auipc	a0,0xb
ffffffffc020187e:	b8650513          	addi	a0,a0,-1146 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201882:	9abfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201886:	0000b697          	auipc	a3,0xb
ffffffffc020188a:	c6268693          	addi	a3,a3,-926 # ffffffffc020c4e8 <etext+0xc12>
ffffffffc020188e:	0000a617          	auipc	a2,0xa
ffffffffc0201892:	50260613          	addi	a2,a2,1282 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201896:	13b00593          	li	a1,315
ffffffffc020189a:	0000b517          	auipc	a0,0xb
ffffffffc020189e:	b6650513          	addi	a0,a0,-1178 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02018a2:	98bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02018a6:	0000b697          	auipc	a3,0xb
ffffffffc02018aa:	ca268693          	addi	a3,a3,-862 # ffffffffc020c548 <etext+0xc72>
ffffffffc02018ae:	0000a617          	auipc	a2,0xa
ffffffffc02018b2:	4e260613          	addi	a2,a2,1250 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02018b6:	14600593          	li	a1,326
ffffffffc02018ba:	0000b517          	auipc	a0,0xb
ffffffffc02018be:	b4650513          	addi	a0,a0,-1210 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02018c2:	96bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02018c6:	0000b697          	auipc	a3,0xb
ffffffffc02018ca:	c7268693          	addi	a3,a3,-910 # ffffffffc020c538 <etext+0xc62>
ffffffffc02018ce:	0000a617          	auipc	a2,0xa
ffffffffc02018d2:	4c260613          	addi	a2,a2,1218 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02018d6:	14400593          	li	a1,324
ffffffffc02018da:	0000b517          	auipc	a0,0xb
ffffffffc02018de:	b2650513          	addi	a0,a0,-1242 # ffffffffc020c400 <etext+0xb2a>
ffffffffc02018e2:	94bfe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02018e6:	6914                	ld	a3,16(a0)
ffffffffc02018e8:	6510                	ld	a2,8(a0)
ffffffffc02018ea:	0004859b          	sext.w	a1,s1
ffffffffc02018ee:	0000b517          	auipc	a0,0xb
ffffffffc02018f2:	cfa50513          	addi	a0,a0,-774 # ffffffffc020c5e8 <etext+0xd12>
ffffffffc02018f6:	833fe0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02018fa:	0000b697          	auipc	a3,0xb
ffffffffc02018fe:	d1668693          	addi	a3,a3,-746 # ffffffffc020c610 <etext+0xd3a>
ffffffffc0201902:	0000a617          	auipc	a2,0xa
ffffffffc0201906:	48e60613          	addi	a2,a2,1166 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020190a:	15900593          	li	a1,345
ffffffffc020190e:	0000b517          	auipc	a0,0xb
ffffffffc0201912:	af250513          	addi	a0,a0,-1294 # ffffffffc020c400 <etext+0xb2a>
ffffffffc0201916:	917fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020191a <user_mem_check>:
ffffffffc020191a:	7179                	addi	sp,sp,-48
ffffffffc020191c:	f022                	sd	s0,32(sp)
ffffffffc020191e:	f406                	sd	ra,40(sp)
ffffffffc0201920:	842e                	mv	s0,a1
ffffffffc0201922:	c52d                	beqz	a0,ffffffffc020198c <user_mem_check+0x72>
ffffffffc0201924:	002007b7          	lui	a5,0x200
ffffffffc0201928:	04f5ed63          	bltu	a1,a5,ffffffffc0201982 <user_mem_check+0x68>
ffffffffc020192c:	ec26                	sd	s1,24(sp)
ffffffffc020192e:	00c584b3          	add	s1,a1,a2
ffffffffc0201932:	0695ff63          	bgeu	a1,s1,ffffffffc02019b0 <user_mem_check+0x96>
ffffffffc0201936:	4785                	li	a5,1
ffffffffc0201938:	07fe                	slli	a5,a5,0x1f
ffffffffc020193a:	0785                	addi	a5,a5,1 # 200001 <_binary_bin_sfs_img_size+0x18ad01>
ffffffffc020193c:	06f4fa63          	bgeu	s1,a5,ffffffffc02019b0 <user_mem_check+0x96>
ffffffffc0201940:	e84a                	sd	s2,16(sp)
ffffffffc0201942:	e44e                	sd	s3,8(sp)
ffffffffc0201944:	8936                	mv	s2,a3
ffffffffc0201946:	89aa                	mv	s3,a0
ffffffffc0201948:	a829                	j	ffffffffc0201962 <user_mem_check+0x48>
ffffffffc020194a:	6685                	lui	a3,0x1
ffffffffc020194c:	9736                	add	a4,a4,a3
ffffffffc020194e:	0027f693          	andi	a3,a5,2
ffffffffc0201952:	8ba1                	andi	a5,a5,8
ffffffffc0201954:	c685                	beqz	a3,ffffffffc020197c <user_mem_check+0x62>
ffffffffc0201956:	c399                	beqz	a5,ffffffffc020195c <user_mem_check+0x42>
ffffffffc0201958:	02e46263          	bltu	s0,a4,ffffffffc020197c <user_mem_check+0x62>
ffffffffc020195c:	6900                	ld	s0,16(a0)
ffffffffc020195e:	04947b63          	bgeu	s0,s1,ffffffffc02019b4 <user_mem_check+0x9a>
ffffffffc0201962:	85a2                	mv	a1,s0
ffffffffc0201964:	854e                	mv	a0,s3
ffffffffc0201966:	953ff0ef          	jal	ffffffffc02012b8 <find_vma>
ffffffffc020196a:	c909                	beqz	a0,ffffffffc020197c <user_mem_check+0x62>
ffffffffc020196c:	6518                	ld	a4,8(a0)
ffffffffc020196e:	00e46763          	bltu	s0,a4,ffffffffc020197c <user_mem_check+0x62>
ffffffffc0201972:	4d1c                	lw	a5,24(a0)
ffffffffc0201974:	fc091be3          	bnez	s2,ffffffffc020194a <user_mem_check+0x30>
ffffffffc0201978:	8b85                	andi	a5,a5,1
ffffffffc020197a:	f3ed                	bnez	a5,ffffffffc020195c <user_mem_check+0x42>
ffffffffc020197c:	64e2                	ld	s1,24(sp)
ffffffffc020197e:	6942                	ld	s2,16(sp)
ffffffffc0201980:	69a2                	ld	s3,8(sp)
ffffffffc0201982:	4501                	li	a0,0
ffffffffc0201984:	70a2                	ld	ra,40(sp)
ffffffffc0201986:	7402                	ld	s0,32(sp)
ffffffffc0201988:	6145                	addi	sp,sp,48
ffffffffc020198a:	8082                	ret
ffffffffc020198c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201990:	fef5eae3          	bltu	a1,a5,ffffffffc0201984 <user_mem_check+0x6a>
ffffffffc0201994:	c80007b7          	lui	a5,0xc8000
ffffffffc0201998:	962e                	add	a2,a2,a1
ffffffffc020199a:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d696f1>
ffffffffc020199c:	00c5b433          	sltu	s0,a1,a2
ffffffffc02019a0:	00f63633          	sltu	a2,a2,a5
ffffffffc02019a4:	70a2                	ld	ra,40(sp)
ffffffffc02019a6:	00867533          	and	a0,a2,s0
ffffffffc02019aa:	7402                	ld	s0,32(sp)
ffffffffc02019ac:	6145                	addi	sp,sp,48
ffffffffc02019ae:	8082                	ret
ffffffffc02019b0:	64e2                	ld	s1,24(sp)
ffffffffc02019b2:	bfc1                	j	ffffffffc0201982 <user_mem_check+0x68>
ffffffffc02019b4:	64e2                	ld	s1,24(sp)
ffffffffc02019b6:	6942                	ld	s2,16(sp)
ffffffffc02019b8:	69a2                	ld	s3,8(sp)
ffffffffc02019ba:	4505                	li	a0,1
ffffffffc02019bc:	b7e1                	j	ffffffffc0201984 <user_mem_check+0x6a>

ffffffffc02019be <copy_from_user>:
ffffffffc02019be:	7179                	addi	sp,sp,-48
ffffffffc02019c0:	f022                	sd	s0,32(sp)
ffffffffc02019c2:	8432                	mv	s0,a2
ffffffffc02019c4:	ec26                	sd	s1,24(sp)
ffffffffc02019c6:	8636                	mv	a2,a3
ffffffffc02019c8:	84ae                	mv	s1,a1
ffffffffc02019ca:	86ba                	mv	a3,a4
ffffffffc02019cc:	85a2                	mv	a1,s0
ffffffffc02019ce:	f406                	sd	ra,40(sp)
ffffffffc02019d0:	e032                	sd	a2,0(sp)
ffffffffc02019d2:	f49ff0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc02019d6:	87aa                	mv	a5,a0
ffffffffc02019d8:	c901                	beqz	a0,ffffffffc02019e8 <copy_from_user+0x2a>
ffffffffc02019da:	6602                	ld	a2,0(sp)
ffffffffc02019dc:	e42a                	sd	a0,8(sp)
ffffffffc02019de:	85a2                	mv	a1,s0
ffffffffc02019e0:	8526                	mv	a0,s1
ffffffffc02019e2:	255090ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc02019e6:	67a2                	ld	a5,8(sp)
ffffffffc02019e8:	70a2                	ld	ra,40(sp)
ffffffffc02019ea:	7402                	ld	s0,32(sp)
ffffffffc02019ec:	64e2                	ld	s1,24(sp)
ffffffffc02019ee:	853e                	mv	a0,a5
ffffffffc02019f0:	6145                	addi	sp,sp,48
ffffffffc02019f2:	8082                	ret

ffffffffc02019f4 <copy_to_user>:
ffffffffc02019f4:	7179                	addi	sp,sp,-48
ffffffffc02019f6:	f022                	sd	s0,32(sp)
ffffffffc02019f8:	8436                	mv	s0,a3
ffffffffc02019fa:	e84a                	sd	s2,16(sp)
ffffffffc02019fc:	4685                	li	a3,1
ffffffffc02019fe:	8932                	mv	s2,a2
ffffffffc0201a00:	8622                	mv	a2,s0
ffffffffc0201a02:	ec26                	sd	s1,24(sp)
ffffffffc0201a04:	f406                	sd	ra,40(sp)
ffffffffc0201a06:	84ae                	mv	s1,a1
ffffffffc0201a08:	f13ff0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc0201a0c:	87aa                	mv	a5,a0
ffffffffc0201a0e:	c901                	beqz	a0,ffffffffc0201a1e <copy_to_user+0x2a>
ffffffffc0201a10:	e42a                	sd	a0,8(sp)
ffffffffc0201a12:	8622                	mv	a2,s0
ffffffffc0201a14:	85ca                	mv	a1,s2
ffffffffc0201a16:	8526                	mv	a0,s1
ffffffffc0201a18:	21f090ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0201a1c:	67a2                	ld	a5,8(sp)
ffffffffc0201a1e:	70a2                	ld	ra,40(sp)
ffffffffc0201a20:	7402                	ld	s0,32(sp)
ffffffffc0201a22:	64e2                	ld	s1,24(sp)
ffffffffc0201a24:	6942                	ld	s2,16(sp)
ffffffffc0201a26:	853e                	mv	a0,a5
ffffffffc0201a28:	6145                	addi	sp,sp,48
ffffffffc0201a2a:	8082                	ret

ffffffffc0201a2c <copy_string>:
ffffffffc0201a2c:	7139                	addi	sp,sp,-64
ffffffffc0201a2e:	e852                	sd	s4,16(sp)
ffffffffc0201a30:	6a05                	lui	s4,0x1
ffffffffc0201a32:	9a32                	add	s4,s4,a2
ffffffffc0201a34:	77fd                	lui	a5,0xfffff
ffffffffc0201a36:	00fa7a33          	and	s4,s4,a5
ffffffffc0201a3a:	f426                	sd	s1,40(sp)
ffffffffc0201a3c:	f04a                	sd	s2,32(sp)
ffffffffc0201a3e:	e456                	sd	s5,8(sp)
ffffffffc0201a40:	e05a                	sd	s6,0(sp)
ffffffffc0201a42:	fc06                	sd	ra,56(sp)
ffffffffc0201a44:	f822                	sd	s0,48(sp)
ffffffffc0201a46:	ec4e                	sd	s3,24(sp)
ffffffffc0201a48:	84b2                	mv	s1,a2
ffffffffc0201a4a:	8aae                	mv	s5,a1
ffffffffc0201a4c:	8936                	mv	s2,a3
ffffffffc0201a4e:	8b2a                	mv	s6,a0
ffffffffc0201a50:	40ca0a33          	sub	s4,s4,a2
ffffffffc0201a54:	a015                	j	ffffffffc0201a78 <copy_string+0x4c>
ffffffffc0201a56:	0f5090ef          	jal	ffffffffc020b34a <strnlen>
ffffffffc0201a5a:	87aa                	mv	a5,a0
ffffffffc0201a5c:	8622                	mv	a2,s0
ffffffffc0201a5e:	85a6                	mv	a1,s1
ffffffffc0201a60:	8556                	mv	a0,s5
ffffffffc0201a62:	0487e663          	bltu	a5,s0,ffffffffc0201aae <copy_string+0x82>
ffffffffc0201a66:	032a7863          	bgeu	s4,s2,ffffffffc0201a96 <copy_string+0x6a>
ffffffffc0201a6a:	1cd090ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0201a6e:	9aa2                	add	s5,s5,s0
ffffffffc0201a70:	94a2                	add	s1,s1,s0
ffffffffc0201a72:	40890933          	sub	s2,s2,s0
ffffffffc0201a76:	6a05                	lui	s4,0x1
ffffffffc0201a78:	4681                	li	a3,0
ffffffffc0201a7a:	85a6                	mv	a1,s1
ffffffffc0201a7c:	855a                	mv	a0,s6
ffffffffc0201a7e:	844a                	mv	s0,s2
ffffffffc0201a80:	012a7363          	bgeu	s4,s2,ffffffffc0201a86 <copy_string+0x5a>
ffffffffc0201a84:	8452                	mv	s0,s4
ffffffffc0201a86:	8622                	mv	a2,s0
ffffffffc0201a88:	e93ff0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc0201a8c:	89aa                	mv	s3,a0
ffffffffc0201a8e:	85a2                	mv	a1,s0
ffffffffc0201a90:	8526                	mv	a0,s1
ffffffffc0201a92:	fc0992e3          	bnez	s3,ffffffffc0201a56 <copy_string+0x2a>
ffffffffc0201a96:	4981                	li	s3,0
ffffffffc0201a98:	70e2                	ld	ra,56(sp)
ffffffffc0201a9a:	7442                	ld	s0,48(sp)
ffffffffc0201a9c:	74a2                	ld	s1,40(sp)
ffffffffc0201a9e:	7902                	ld	s2,32(sp)
ffffffffc0201aa0:	6a42                	ld	s4,16(sp)
ffffffffc0201aa2:	6aa2                	ld	s5,8(sp)
ffffffffc0201aa4:	6b02                	ld	s6,0(sp)
ffffffffc0201aa6:	854e                	mv	a0,s3
ffffffffc0201aa8:	69e2                	ld	s3,24(sp)
ffffffffc0201aaa:	6121                	addi	sp,sp,64
ffffffffc0201aac:	8082                	ret
ffffffffc0201aae:	00178613          	addi	a2,a5,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc0201ab2:	185090ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0201ab6:	b7cd                	j	ffffffffc0201a98 <copy_string+0x6c>

ffffffffc0201ab8 <slob_free>:
ffffffffc0201ab8:	c531                	beqz	a0,ffffffffc0201b04 <slob_free+0x4c>
ffffffffc0201aba:	e9b9                	bnez	a1,ffffffffc0201b10 <slob_free+0x58>
ffffffffc0201abc:	100027f3          	csrr	a5,sstatus
ffffffffc0201ac0:	8b89                	andi	a5,a5,2
ffffffffc0201ac2:	4581                	li	a1,0
ffffffffc0201ac4:	efb1                	bnez	a5,ffffffffc0201b20 <slob_free+0x68>
ffffffffc0201ac6:	0008f797          	auipc	a5,0x8f
ffffffffc0201aca:	58a7b783          	ld	a5,1418(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201ace:	873e                	mv	a4,a5
ffffffffc0201ad0:	679c                	ld	a5,8(a5)
ffffffffc0201ad2:	02a77a63          	bgeu	a4,a0,ffffffffc0201b06 <slob_free+0x4e>
ffffffffc0201ad6:	00f56463          	bltu	a0,a5,ffffffffc0201ade <slob_free+0x26>
ffffffffc0201ada:	fef76ae3          	bltu	a4,a5,ffffffffc0201ace <slob_free+0x16>
ffffffffc0201ade:	4110                	lw	a2,0(a0)
ffffffffc0201ae0:	00461693          	slli	a3,a2,0x4
ffffffffc0201ae4:	96aa                	add	a3,a3,a0
ffffffffc0201ae6:	0ad78463          	beq	a5,a3,ffffffffc0201b8e <slob_free+0xd6>
ffffffffc0201aea:	4310                	lw	a2,0(a4)
ffffffffc0201aec:	e51c                	sd	a5,8(a0)
ffffffffc0201aee:	00461693          	slli	a3,a2,0x4
ffffffffc0201af2:	96ba                	add	a3,a3,a4
ffffffffc0201af4:	08d50163          	beq	a0,a3,ffffffffc0201b76 <slob_free+0xbe>
ffffffffc0201af8:	e708                	sd	a0,8(a4)
ffffffffc0201afa:	0008f797          	auipc	a5,0x8f
ffffffffc0201afe:	54e7bb23          	sd	a4,1366(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201b02:	e9a5                	bnez	a1,ffffffffc0201b72 <slob_free+0xba>
ffffffffc0201b04:	8082                	ret
ffffffffc0201b06:	fcf574e3          	bgeu	a0,a5,ffffffffc0201ace <slob_free+0x16>
ffffffffc0201b0a:	fcf762e3          	bltu	a4,a5,ffffffffc0201ace <slob_free+0x16>
ffffffffc0201b0e:	bfc1                	j	ffffffffc0201ade <slob_free+0x26>
ffffffffc0201b10:	25bd                	addiw	a1,a1,15
ffffffffc0201b12:	8191                	srli	a1,a1,0x4
ffffffffc0201b14:	c10c                	sw	a1,0(a0)
ffffffffc0201b16:	100027f3          	csrr	a5,sstatus
ffffffffc0201b1a:	8b89                	andi	a5,a5,2
ffffffffc0201b1c:	4581                	li	a1,0
ffffffffc0201b1e:	d7c5                	beqz	a5,ffffffffc0201ac6 <slob_free+0xe>
ffffffffc0201b20:	1101                	addi	sp,sp,-32
ffffffffc0201b22:	e42a                	sd	a0,8(sp)
ffffffffc0201b24:	ec06                	sd	ra,24(sp)
ffffffffc0201b26:	9dcff0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0201b2a:	6522                	ld	a0,8(sp)
ffffffffc0201b2c:	0008f797          	auipc	a5,0x8f
ffffffffc0201b30:	5247b783          	ld	a5,1316(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201b34:	4585                	li	a1,1
ffffffffc0201b36:	873e                	mv	a4,a5
ffffffffc0201b38:	679c                	ld	a5,8(a5)
ffffffffc0201b3a:	06a77663          	bgeu	a4,a0,ffffffffc0201ba6 <slob_free+0xee>
ffffffffc0201b3e:	00f56463          	bltu	a0,a5,ffffffffc0201b46 <slob_free+0x8e>
ffffffffc0201b42:	fef76ae3          	bltu	a4,a5,ffffffffc0201b36 <slob_free+0x7e>
ffffffffc0201b46:	4110                	lw	a2,0(a0)
ffffffffc0201b48:	00461693          	slli	a3,a2,0x4
ffffffffc0201b4c:	96aa                	add	a3,a3,a0
ffffffffc0201b4e:	06d78363          	beq	a5,a3,ffffffffc0201bb4 <slob_free+0xfc>
ffffffffc0201b52:	4310                	lw	a2,0(a4)
ffffffffc0201b54:	e51c                	sd	a5,8(a0)
ffffffffc0201b56:	00461693          	slli	a3,a2,0x4
ffffffffc0201b5a:	96ba                	add	a3,a3,a4
ffffffffc0201b5c:	06d50163          	beq	a0,a3,ffffffffc0201bbe <slob_free+0x106>
ffffffffc0201b60:	e708                	sd	a0,8(a4)
ffffffffc0201b62:	0008f797          	auipc	a5,0x8f
ffffffffc0201b66:	4ee7b723          	sd	a4,1262(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201b6a:	e1a9                	bnez	a1,ffffffffc0201bac <slob_free+0xf4>
ffffffffc0201b6c:	60e2                	ld	ra,24(sp)
ffffffffc0201b6e:	6105                	addi	sp,sp,32
ffffffffc0201b70:	8082                	ret
ffffffffc0201b72:	98aff06f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc0201b76:	4114                	lw	a3,0(a0)
ffffffffc0201b78:	853e                	mv	a0,a5
ffffffffc0201b7a:	e708                	sd	a0,8(a4)
ffffffffc0201b7c:	00c687bb          	addw	a5,a3,a2
ffffffffc0201b80:	c31c                	sw	a5,0(a4)
ffffffffc0201b82:	0008f797          	auipc	a5,0x8f
ffffffffc0201b86:	4ce7b723          	sd	a4,1230(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201b8a:	ddad                	beqz	a1,ffffffffc0201b04 <slob_free+0x4c>
ffffffffc0201b8c:	b7dd                	j	ffffffffc0201b72 <slob_free+0xba>
ffffffffc0201b8e:	4394                	lw	a3,0(a5)
ffffffffc0201b90:	679c                	ld	a5,8(a5)
ffffffffc0201b92:	9eb1                	addw	a3,a3,a2
ffffffffc0201b94:	c114                	sw	a3,0(a0)
ffffffffc0201b96:	4310                	lw	a2,0(a4)
ffffffffc0201b98:	e51c                	sd	a5,8(a0)
ffffffffc0201b9a:	00461693          	slli	a3,a2,0x4
ffffffffc0201b9e:	96ba                	add	a3,a3,a4
ffffffffc0201ba0:	f4d51ce3          	bne	a0,a3,ffffffffc0201af8 <slob_free+0x40>
ffffffffc0201ba4:	bfc9                	j	ffffffffc0201b76 <slob_free+0xbe>
ffffffffc0201ba6:	f8f56ee3          	bltu	a0,a5,ffffffffc0201b42 <slob_free+0x8a>
ffffffffc0201baa:	b771                	j	ffffffffc0201b36 <slob_free+0x7e>
ffffffffc0201bac:	60e2                	ld	ra,24(sp)
ffffffffc0201bae:	6105                	addi	sp,sp,32
ffffffffc0201bb0:	94cff06f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc0201bb4:	4394                	lw	a3,0(a5)
ffffffffc0201bb6:	679c                	ld	a5,8(a5)
ffffffffc0201bb8:	9eb1                	addw	a3,a3,a2
ffffffffc0201bba:	c114                	sw	a3,0(a0)
ffffffffc0201bbc:	bf59                	j	ffffffffc0201b52 <slob_free+0x9a>
ffffffffc0201bbe:	4114                	lw	a3,0(a0)
ffffffffc0201bc0:	853e                	mv	a0,a5
ffffffffc0201bc2:	00c687bb          	addw	a5,a3,a2
ffffffffc0201bc6:	c31c                	sw	a5,0(a4)
ffffffffc0201bc8:	bf61                	j	ffffffffc0201b60 <slob_free+0xa8>

ffffffffc0201bca <__slob_get_free_pages.constprop.0>:
ffffffffc0201bca:	4785                	li	a5,1
ffffffffc0201bcc:	1141                	addi	sp,sp,-16
ffffffffc0201bce:	00a7953b          	sllw	a0,a5,a0
ffffffffc0201bd2:	e406                	sd	ra,8(sp)
ffffffffc0201bd4:	615000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0201bd8:	c91d                	beqz	a0,ffffffffc0201c0e <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0201bda:	00095697          	auipc	a3,0x95
ffffffffc0201bde:	cde6b683          	ld	a3,-802(a3) # ffffffffc02968b8 <pages>
ffffffffc0201be2:	0000e797          	auipc	a5,0xe
ffffffffc0201be6:	fce7b783          	ld	a5,-50(a5) # ffffffffc020fbb0 <nbase>
ffffffffc0201bea:	00095717          	auipc	a4,0x95
ffffffffc0201bee:	cc673703          	ld	a4,-826(a4) # ffffffffc02968b0 <npage>
ffffffffc0201bf2:	8d15                	sub	a0,a0,a3
ffffffffc0201bf4:	8519                	srai	a0,a0,0x6
ffffffffc0201bf6:	953e                	add	a0,a0,a5
ffffffffc0201bf8:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bfc:	83b1                	srli	a5,a5,0xc
ffffffffc0201bfe:	0532                	slli	a0,a0,0xc
ffffffffc0201c00:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c14 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201c04:	00095797          	auipc	a5,0x95
ffffffffc0201c08:	ca47b783          	ld	a5,-860(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0201c0c:	953e                	add	a0,a0,a5
ffffffffc0201c0e:	60a2                	ld	ra,8(sp)
ffffffffc0201c10:	0141                	addi	sp,sp,16
ffffffffc0201c12:	8082                	ret
ffffffffc0201c14:	86aa                	mv	a3,a0
ffffffffc0201c16:	0000b617          	auipc	a2,0xb
ffffffffc0201c1a:	a4a60613          	addi	a2,a2,-1462 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0201c1e:	07100593          	li	a1,113
ffffffffc0201c22:	0000b517          	auipc	a0,0xb
ffffffffc0201c26:	a6650513          	addi	a0,a0,-1434 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0201c2a:	e02fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201c2e <slob_alloc.constprop.0>:
ffffffffc0201c2e:	7179                	addi	sp,sp,-48
ffffffffc0201c30:	f406                	sd	ra,40(sp)
ffffffffc0201c32:	f022                	sd	s0,32(sp)
ffffffffc0201c34:	ec26                	sd	s1,24(sp)
ffffffffc0201c36:	01050713          	addi	a4,a0,16
ffffffffc0201c3a:	6785                	lui	a5,0x1
ffffffffc0201c3c:	0af77e63          	bgeu	a4,a5,ffffffffc0201cf8 <slob_alloc.constprop.0+0xca>
ffffffffc0201c40:	00f50413          	addi	s0,a0,15
ffffffffc0201c44:	8011                	srli	s0,s0,0x4
ffffffffc0201c46:	2401                	sext.w	s0,s0
ffffffffc0201c48:	100025f3          	csrr	a1,sstatus
ffffffffc0201c4c:	8989                	andi	a1,a1,2
ffffffffc0201c4e:	edd1                	bnez	a1,ffffffffc0201cea <slob_alloc.constprop.0+0xbc>
ffffffffc0201c50:	0008f497          	auipc	s1,0x8f
ffffffffc0201c54:	40048493          	addi	s1,s1,1024 # ffffffffc0291050 <slobfree>
ffffffffc0201c58:	6090                	ld	a2,0(s1)
ffffffffc0201c5a:	6618                	ld	a4,8(a2)
ffffffffc0201c5c:	4314                	lw	a3,0(a4)
ffffffffc0201c5e:	0886da63          	bge	a3,s0,ffffffffc0201cf2 <slob_alloc.constprop.0+0xc4>
ffffffffc0201c62:	00e60a63          	beq	a2,a4,ffffffffc0201c76 <slob_alloc.constprop.0+0x48>
ffffffffc0201c66:	671c                	ld	a5,8(a4)
ffffffffc0201c68:	4394                	lw	a3,0(a5)
ffffffffc0201c6a:	0286d863          	bge	a3,s0,ffffffffc0201c9a <slob_alloc.constprop.0+0x6c>
ffffffffc0201c6e:	6090                	ld	a2,0(s1)
ffffffffc0201c70:	873e                	mv	a4,a5
ffffffffc0201c72:	fee61ae3          	bne	a2,a4,ffffffffc0201c66 <slob_alloc.constprop.0+0x38>
ffffffffc0201c76:	e9b1                	bnez	a1,ffffffffc0201cca <slob_alloc.constprop.0+0x9c>
ffffffffc0201c78:	4501                	li	a0,0
ffffffffc0201c7a:	f51ff0ef          	jal	ffffffffc0201bca <__slob_get_free_pages.constprop.0>
ffffffffc0201c7e:	87aa                	mv	a5,a0
ffffffffc0201c80:	c915                	beqz	a0,ffffffffc0201cb4 <slob_alloc.constprop.0+0x86>
ffffffffc0201c82:	6585                	lui	a1,0x1
ffffffffc0201c84:	e35ff0ef          	jal	ffffffffc0201ab8 <slob_free>
ffffffffc0201c88:	100025f3          	csrr	a1,sstatus
ffffffffc0201c8c:	8989                	andi	a1,a1,2
ffffffffc0201c8e:	e98d                	bnez	a1,ffffffffc0201cc0 <slob_alloc.constprop.0+0x92>
ffffffffc0201c90:	6098                	ld	a4,0(s1)
ffffffffc0201c92:	671c                	ld	a5,8(a4)
ffffffffc0201c94:	4394                	lw	a3,0(a5)
ffffffffc0201c96:	fc86cce3          	blt	a3,s0,ffffffffc0201c6e <slob_alloc.constprop.0+0x40>
ffffffffc0201c9a:	04d40563          	beq	s0,a3,ffffffffc0201ce4 <slob_alloc.constprop.0+0xb6>
ffffffffc0201c9e:	00441613          	slli	a2,s0,0x4
ffffffffc0201ca2:	963e                	add	a2,a2,a5
ffffffffc0201ca4:	e710                	sd	a2,8(a4)
ffffffffc0201ca6:	6788                	ld	a0,8(a5)
ffffffffc0201ca8:	9e81                	subw	a3,a3,s0
ffffffffc0201caa:	c214                	sw	a3,0(a2)
ffffffffc0201cac:	e608                	sd	a0,8(a2)
ffffffffc0201cae:	c380                	sw	s0,0(a5)
ffffffffc0201cb0:	e098                	sd	a4,0(s1)
ffffffffc0201cb2:	ed99                	bnez	a1,ffffffffc0201cd0 <slob_alloc.constprop.0+0xa2>
ffffffffc0201cb4:	70a2                	ld	ra,40(sp)
ffffffffc0201cb6:	7402                	ld	s0,32(sp)
ffffffffc0201cb8:	64e2                	ld	s1,24(sp)
ffffffffc0201cba:	853e                	mv	a0,a5
ffffffffc0201cbc:	6145                	addi	sp,sp,48
ffffffffc0201cbe:	8082                	ret
ffffffffc0201cc0:	842ff0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0201cc4:	6098                	ld	a4,0(s1)
ffffffffc0201cc6:	4585                	li	a1,1
ffffffffc0201cc8:	b7e9                	j	ffffffffc0201c92 <slob_alloc.constprop.0+0x64>
ffffffffc0201cca:	832ff0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0201cce:	b76d                	j	ffffffffc0201c78 <slob_alloc.constprop.0+0x4a>
ffffffffc0201cd0:	e43e                	sd	a5,8(sp)
ffffffffc0201cd2:	82aff0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0201cd6:	67a2                	ld	a5,8(sp)
ffffffffc0201cd8:	70a2                	ld	ra,40(sp)
ffffffffc0201cda:	7402                	ld	s0,32(sp)
ffffffffc0201cdc:	64e2                	ld	s1,24(sp)
ffffffffc0201cde:	853e                	mv	a0,a5
ffffffffc0201ce0:	6145                	addi	sp,sp,48
ffffffffc0201ce2:	8082                	ret
ffffffffc0201ce4:	6794                	ld	a3,8(a5)
ffffffffc0201ce6:	e714                	sd	a3,8(a4)
ffffffffc0201ce8:	b7e1                	j	ffffffffc0201cb0 <slob_alloc.constprop.0+0x82>
ffffffffc0201cea:	818ff0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0201cee:	4585                	li	a1,1
ffffffffc0201cf0:	b785                	j	ffffffffc0201c50 <slob_alloc.constprop.0+0x22>
ffffffffc0201cf2:	87ba                	mv	a5,a4
ffffffffc0201cf4:	8732                	mv	a4,a2
ffffffffc0201cf6:	b755                	j	ffffffffc0201c9a <slob_alloc.constprop.0+0x6c>
ffffffffc0201cf8:	0000b697          	auipc	a3,0xb
ffffffffc0201cfc:	9a068693          	addi	a3,a3,-1632 # ffffffffc020c698 <etext+0xdc2>
ffffffffc0201d00:	0000a617          	auipc	a2,0xa
ffffffffc0201d04:	09060613          	addi	a2,a2,144 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0201d08:	06300593          	li	a1,99
ffffffffc0201d0c:	0000b517          	auipc	a0,0xb
ffffffffc0201d10:	9ac50513          	addi	a0,a0,-1620 # ffffffffc020c6b8 <etext+0xde2>
ffffffffc0201d14:	d18fe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201d18 <kmalloc_init>:
ffffffffc0201d18:	1141                	addi	sp,sp,-16
ffffffffc0201d1a:	0000b517          	auipc	a0,0xb
ffffffffc0201d1e:	9b650513          	addi	a0,a0,-1610 # ffffffffc020c6d0 <etext+0xdfa>
ffffffffc0201d22:	e406                	sd	ra,8(sp)
ffffffffc0201d24:	c04fe0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0201d28:	60a2                	ld	ra,8(sp)
ffffffffc0201d2a:	0000b517          	auipc	a0,0xb
ffffffffc0201d2e:	9be50513          	addi	a0,a0,-1602 # ffffffffc020c6e8 <etext+0xe12>
ffffffffc0201d32:	0141                	addi	sp,sp,16
ffffffffc0201d34:	bf4fe06f          	j	ffffffffc0200128 <cprintf>

ffffffffc0201d38 <kallocated>:
ffffffffc0201d38:	4501                	li	a0,0
ffffffffc0201d3a:	8082                	ret

ffffffffc0201d3c <kmalloc>:
ffffffffc0201d3c:	1101                	addi	sp,sp,-32
ffffffffc0201d3e:	6685                	lui	a3,0x1
ffffffffc0201d40:	ec06                	sd	ra,24(sp)
ffffffffc0201d42:	16bd                	addi	a3,a3,-17 # fef <_binary_bin_swap_img_size-0x6d11>
ffffffffc0201d44:	04a6f963          	bgeu	a3,a0,ffffffffc0201d96 <kmalloc+0x5a>
ffffffffc0201d48:	e42a                	sd	a0,8(sp)
ffffffffc0201d4a:	4561                	li	a0,24
ffffffffc0201d4c:	e822                	sd	s0,16(sp)
ffffffffc0201d4e:	ee1ff0ef          	jal	ffffffffc0201c2e <slob_alloc.constprop.0>
ffffffffc0201d52:	842a                	mv	s0,a0
ffffffffc0201d54:	c541                	beqz	a0,ffffffffc0201ddc <kmalloc+0xa0>
ffffffffc0201d56:	47a2                	lw	a5,8(sp)
ffffffffc0201d58:	6705                	lui	a4,0x1
ffffffffc0201d5a:	4501                	li	a0,0
ffffffffc0201d5c:	00f75763          	bge	a4,a5,ffffffffc0201d6a <kmalloc+0x2e>
ffffffffc0201d60:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0201d64:	2505                	addiw	a0,a0,1
ffffffffc0201d66:	fef74de3          	blt	a4,a5,ffffffffc0201d60 <kmalloc+0x24>
ffffffffc0201d6a:	c008                	sw	a0,0(s0)
ffffffffc0201d6c:	e5fff0ef          	jal	ffffffffc0201bca <__slob_get_free_pages.constprop.0>
ffffffffc0201d70:	e408                	sd	a0,8(s0)
ffffffffc0201d72:	cd31                	beqz	a0,ffffffffc0201dce <kmalloc+0x92>
ffffffffc0201d74:	100027f3          	csrr	a5,sstatus
ffffffffc0201d78:	8b89                	andi	a5,a5,2
ffffffffc0201d7a:	eb85                	bnez	a5,ffffffffc0201daa <kmalloc+0x6e>
ffffffffc0201d7c:	00095797          	auipc	a5,0x95
ffffffffc0201d80:	b0c7b783          	ld	a5,-1268(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0201d84:	00095717          	auipc	a4,0x95
ffffffffc0201d88:	b0873223          	sd	s0,-1276(a4) # ffffffffc0296888 <bigblocks>
ffffffffc0201d8c:	e81c                	sd	a5,16(s0)
ffffffffc0201d8e:	6442                	ld	s0,16(sp)
ffffffffc0201d90:	60e2                	ld	ra,24(sp)
ffffffffc0201d92:	6105                	addi	sp,sp,32
ffffffffc0201d94:	8082                	ret
ffffffffc0201d96:	0541                	addi	a0,a0,16
ffffffffc0201d98:	e97ff0ef          	jal	ffffffffc0201c2e <slob_alloc.constprop.0>
ffffffffc0201d9c:	87aa                	mv	a5,a0
ffffffffc0201d9e:	0541                	addi	a0,a0,16
ffffffffc0201da0:	fbe5                	bnez	a5,ffffffffc0201d90 <kmalloc+0x54>
ffffffffc0201da2:	4501                	li	a0,0
ffffffffc0201da4:	60e2                	ld	ra,24(sp)
ffffffffc0201da6:	6105                	addi	sp,sp,32
ffffffffc0201da8:	8082                	ret
ffffffffc0201daa:	f59fe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0201dae:	00095797          	auipc	a5,0x95
ffffffffc0201db2:	ada7b783          	ld	a5,-1318(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0201db6:	00095717          	auipc	a4,0x95
ffffffffc0201dba:	ac873923          	sd	s0,-1326(a4) # ffffffffc0296888 <bigblocks>
ffffffffc0201dbe:	e81c                	sd	a5,16(s0)
ffffffffc0201dc0:	f3dfe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0201dc4:	6408                	ld	a0,8(s0)
ffffffffc0201dc6:	60e2                	ld	ra,24(sp)
ffffffffc0201dc8:	6442                	ld	s0,16(sp)
ffffffffc0201dca:	6105                	addi	sp,sp,32
ffffffffc0201dcc:	8082                	ret
ffffffffc0201dce:	8522                	mv	a0,s0
ffffffffc0201dd0:	45e1                	li	a1,24
ffffffffc0201dd2:	ce7ff0ef          	jal	ffffffffc0201ab8 <slob_free>
ffffffffc0201dd6:	4501                	li	a0,0
ffffffffc0201dd8:	6442                	ld	s0,16(sp)
ffffffffc0201dda:	b7e9                	j	ffffffffc0201da4 <kmalloc+0x68>
ffffffffc0201ddc:	6442                	ld	s0,16(sp)
ffffffffc0201dde:	4501                	li	a0,0
ffffffffc0201de0:	b7d1                	j	ffffffffc0201da4 <kmalloc+0x68>

ffffffffc0201de2 <kfree>:
ffffffffc0201de2:	c571                	beqz	a0,ffffffffc0201eae <kfree+0xcc>
ffffffffc0201de4:	03451793          	slli	a5,a0,0x34
ffffffffc0201de8:	e3e1                	bnez	a5,ffffffffc0201ea8 <kfree+0xc6>
ffffffffc0201dea:	1101                	addi	sp,sp,-32
ffffffffc0201dec:	ec06                	sd	ra,24(sp)
ffffffffc0201dee:	100027f3          	csrr	a5,sstatus
ffffffffc0201df2:	8b89                	andi	a5,a5,2
ffffffffc0201df4:	e7c1                	bnez	a5,ffffffffc0201e7c <kfree+0x9a>
ffffffffc0201df6:	00095797          	auipc	a5,0x95
ffffffffc0201dfa:	a927b783          	ld	a5,-1390(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0201dfe:	4581                	li	a1,0
ffffffffc0201e00:	cbad                	beqz	a5,ffffffffc0201e72 <kfree+0x90>
ffffffffc0201e02:	00095617          	auipc	a2,0x95
ffffffffc0201e06:	a8660613          	addi	a2,a2,-1402 # ffffffffc0296888 <bigblocks>
ffffffffc0201e0a:	a021                	j	ffffffffc0201e12 <kfree+0x30>
ffffffffc0201e0c:	01070613          	addi	a2,a4,16
ffffffffc0201e10:	c3a5                	beqz	a5,ffffffffc0201e70 <kfree+0x8e>
ffffffffc0201e12:	6794                	ld	a3,8(a5)
ffffffffc0201e14:	873e                	mv	a4,a5
ffffffffc0201e16:	6b9c                	ld	a5,16(a5)
ffffffffc0201e18:	fea69ae3          	bne	a3,a0,ffffffffc0201e0c <kfree+0x2a>
ffffffffc0201e1c:	e21c                	sd	a5,0(a2)
ffffffffc0201e1e:	edb5                	bnez	a1,ffffffffc0201e9a <kfree+0xb8>
ffffffffc0201e20:	c02007b7          	lui	a5,0xc0200
ffffffffc0201e24:	0af56263          	bltu	a0,a5,ffffffffc0201ec8 <kfree+0xe6>
ffffffffc0201e28:	00095797          	auipc	a5,0x95
ffffffffc0201e2c:	a807b783          	ld	a5,-1408(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0201e30:	00095697          	auipc	a3,0x95
ffffffffc0201e34:	a806b683          	ld	a3,-1408(a3) # ffffffffc02968b0 <npage>
ffffffffc0201e38:	8d1d                	sub	a0,a0,a5
ffffffffc0201e3a:	00c55793          	srli	a5,a0,0xc
ffffffffc0201e3e:	06d7f963          	bgeu	a5,a3,ffffffffc0201eb0 <kfree+0xce>
ffffffffc0201e42:	0000e617          	auipc	a2,0xe
ffffffffc0201e46:	d6e63603          	ld	a2,-658(a2) # ffffffffc020fbb0 <nbase>
ffffffffc0201e4a:	00095517          	auipc	a0,0x95
ffffffffc0201e4e:	a6e53503          	ld	a0,-1426(a0) # ffffffffc02968b8 <pages>
ffffffffc0201e52:	4314                	lw	a3,0(a4)
ffffffffc0201e54:	8f91                	sub	a5,a5,a2
ffffffffc0201e56:	079a                	slli	a5,a5,0x6
ffffffffc0201e58:	4585                	li	a1,1
ffffffffc0201e5a:	953e                	add	a0,a0,a5
ffffffffc0201e5c:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201e60:	e03a                	sd	a4,0(sp)
ffffffffc0201e62:	3c1000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0201e66:	6502                	ld	a0,0(sp)
ffffffffc0201e68:	60e2                	ld	ra,24(sp)
ffffffffc0201e6a:	45e1                	li	a1,24
ffffffffc0201e6c:	6105                	addi	sp,sp,32
ffffffffc0201e6e:	b1a9                	j	ffffffffc0201ab8 <slob_free>
ffffffffc0201e70:	e185                	bnez	a1,ffffffffc0201e90 <kfree+0xae>
ffffffffc0201e72:	60e2                	ld	ra,24(sp)
ffffffffc0201e74:	1541                	addi	a0,a0,-16
ffffffffc0201e76:	4581                	li	a1,0
ffffffffc0201e78:	6105                	addi	sp,sp,32
ffffffffc0201e7a:	b93d                	j	ffffffffc0201ab8 <slob_free>
ffffffffc0201e7c:	e02a                	sd	a0,0(sp)
ffffffffc0201e7e:	e85fe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0201e82:	00095797          	auipc	a5,0x95
ffffffffc0201e86:	a067b783          	ld	a5,-1530(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0201e8a:	6502                	ld	a0,0(sp)
ffffffffc0201e8c:	4585                	li	a1,1
ffffffffc0201e8e:	fbb5                	bnez	a5,ffffffffc0201e02 <kfree+0x20>
ffffffffc0201e90:	e02a                	sd	a0,0(sp)
ffffffffc0201e92:	e6bfe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0201e96:	6502                	ld	a0,0(sp)
ffffffffc0201e98:	bfe9                	j	ffffffffc0201e72 <kfree+0x90>
ffffffffc0201e9a:	e42a                	sd	a0,8(sp)
ffffffffc0201e9c:	e03a                	sd	a4,0(sp)
ffffffffc0201e9e:	e5ffe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0201ea2:	6522                	ld	a0,8(sp)
ffffffffc0201ea4:	6702                	ld	a4,0(sp)
ffffffffc0201ea6:	bfad                	j	ffffffffc0201e20 <kfree+0x3e>
ffffffffc0201ea8:	1541                	addi	a0,a0,-16
ffffffffc0201eaa:	4581                	li	a1,0
ffffffffc0201eac:	b131                	j	ffffffffc0201ab8 <slob_free>
ffffffffc0201eae:	8082                	ret
ffffffffc0201eb0:	0000b617          	auipc	a2,0xb
ffffffffc0201eb4:	88060613          	addi	a2,a2,-1920 # ffffffffc020c730 <etext+0xe5a>
ffffffffc0201eb8:	06900593          	li	a1,105
ffffffffc0201ebc:	0000a517          	auipc	a0,0xa
ffffffffc0201ec0:	7cc50513          	addi	a0,a0,1996 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0201ec4:	b68fe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0201ec8:	86aa                	mv	a3,a0
ffffffffc0201eca:	0000b617          	auipc	a2,0xb
ffffffffc0201ece:	83e60613          	addi	a2,a2,-1986 # ffffffffc020c708 <etext+0xe32>
ffffffffc0201ed2:	07700593          	li	a1,119
ffffffffc0201ed6:	0000a517          	auipc	a0,0xa
ffffffffc0201eda:	7b250513          	addi	a0,a0,1970 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0201ede:	b4efe0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0201ee2 <default_init>:
ffffffffc0201ee2:	00090797          	auipc	a5,0x90
ffffffffc0201ee6:	8c678793          	addi	a5,a5,-1850 # ffffffffc02917a8 <free_area>
ffffffffc0201eea:	e79c                	sd	a5,8(a5)
ffffffffc0201eec:	e39c                	sd	a5,0(a5)
ffffffffc0201eee:	0007a823          	sw	zero,16(a5)
ffffffffc0201ef2:	8082                	ret

ffffffffc0201ef4 <default_nr_free_pages>:
ffffffffc0201ef4:	00090517          	auipc	a0,0x90
ffffffffc0201ef8:	8c456503          	lwu	a0,-1852(a0) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201efc:	8082                	ret

ffffffffc0201efe <default_check>:
ffffffffc0201efe:	711d                	addi	sp,sp,-96
ffffffffc0201f00:	e0ca                	sd	s2,64(sp)
ffffffffc0201f02:	00090917          	auipc	s2,0x90
ffffffffc0201f06:	8a690913          	addi	s2,s2,-1882 # ffffffffc02917a8 <free_area>
ffffffffc0201f0a:	00893783          	ld	a5,8(s2)
ffffffffc0201f0e:	ec86                	sd	ra,88(sp)
ffffffffc0201f10:	e8a2                	sd	s0,80(sp)
ffffffffc0201f12:	e4a6                	sd	s1,72(sp)
ffffffffc0201f14:	fc4e                	sd	s3,56(sp)
ffffffffc0201f16:	f852                	sd	s4,48(sp)
ffffffffc0201f18:	f456                	sd	s5,40(sp)
ffffffffc0201f1a:	f05a                	sd	s6,32(sp)
ffffffffc0201f1c:	ec5e                	sd	s7,24(sp)
ffffffffc0201f1e:	e862                	sd	s8,16(sp)
ffffffffc0201f20:	e466                	sd	s9,8(sp)
ffffffffc0201f22:	2f278363          	beq	a5,s2,ffffffffc0202208 <default_check+0x30a>
ffffffffc0201f26:	4401                	li	s0,0
ffffffffc0201f28:	4481                	li	s1,0
ffffffffc0201f2a:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201f2e:	8b09                	andi	a4,a4,2
ffffffffc0201f30:	2e070063          	beqz	a4,ffffffffc0202210 <default_check+0x312>
ffffffffc0201f34:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201f38:	679c                	ld	a5,8(a5)
ffffffffc0201f3a:	2485                	addiw	s1,s1,1
ffffffffc0201f3c:	9c39                	addw	s0,s0,a4
ffffffffc0201f3e:	ff2796e3          	bne	a5,s2,ffffffffc0201f2a <default_check+0x2c>
ffffffffc0201f42:	89a2                	mv	s3,s0
ffffffffc0201f44:	317000ef          	jal	ffffffffc0202a5a <nr_free_pages>
ffffffffc0201f48:	73351463          	bne	a0,s3,ffffffffc0202670 <default_check+0x772>
ffffffffc0201f4c:	4505                	li	a0,1
ffffffffc0201f4e:	29b000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0201f52:	8a2a                	mv	s4,a0
ffffffffc0201f54:	44050e63          	beqz	a0,ffffffffc02023b0 <default_check+0x4b2>
ffffffffc0201f58:	4505                	li	a0,1
ffffffffc0201f5a:	28f000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0201f5e:	89aa                	mv	s3,a0
ffffffffc0201f60:	72050863          	beqz	a0,ffffffffc0202690 <default_check+0x792>
ffffffffc0201f64:	4505                	li	a0,1
ffffffffc0201f66:	283000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0201f6a:	8aaa                	mv	s5,a0
ffffffffc0201f6c:	4c050263          	beqz	a0,ffffffffc0202430 <default_check+0x532>
ffffffffc0201f70:	40a987b3          	sub	a5,s3,a0
ffffffffc0201f74:	40aa0733          	sub	a4,s4,a0
ffffffffc0201f78:	0017b793          	seqz	a5,a5
ffffffffc0201f7c:	00173713          	seqz	a4,a4
ffffffffc0201f80:	8fd9                	or	a5,a5,a4
ffffffffc0201f82:	30079763          	bnez	a5,ffffffffc0202290 <default_check+0x392>
ffffffffc0201f86:	313a0563          	beq	s4,s3,ffffffffc0202290 <default_check+0x392>
ffffffffc0201f8a:	000a2783          	lw	a5,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0201f8e:	2a079163          	bnez	a5,ffffffffc0202230 <default_check+0x332>
ffffffffc0201f92:	0009a783          	lw	a5,0(s3)
ffffffffc0201f96:	28079d63          	bnez	a5,ffffffffc0202230 <default_check+0x332>
ffffffffc0201f9a:	411c                	lw	a5,0(a0)
ffffffffc0201f9c:	28079a63          	bnez	a5,ffffffffc0202230 <default_check+0x332>
ffffffffc0201fa0:	00095797          	auipc	a5,0x95
ffffffffc0201fa4:	9187b783          	ld	a5,-1768(a5) # ffffffffc02968b8 <pages>
ffffffffc0201fa8:	0000e617          	auipc	a2,0xe
ffffffffc0201fac:	c0863603          	ld	a2,-1016(a2) # ffffffffc020fbb0 <nbase>
ffffffffc0201fb0:	00095697          	auipc	a3,0x95
ffffffffc0201fb4:	9006b683          	ld	a3,-1792(a3) # ffffffffc02968b0 <npage>
ffffffffc0201fb8:	40fa0733          	sub	a4,s4,a5
ffffffffc0201fbc:	8719                	srai	a4,a4,0x6
ffffffffc0201fbe:	9732                	add	a4,a4,a2
ffffffffc0201fc0:	0732                	slli	a4,a4,0xc
ffffffffc0201fc2:	06b2                	slli	a3,a3,0xc
ffffffffc0201fc4:	2ad77663          	bgeu	a4,a3,ffffffffc0202270 <default_check+0x372>
ffffffffc0201fc8:	40f98733          	sub	a4,s3,a5
ffffffffc0201fcc:	8719                	srai	a4,a4,0x6
ffffffffc0201fce:	9732                	add	a4,a4,a2
ffffffffc0201fd0:	0732                	slli	a4,a4,0xc
ffffffffc0201fd2:	4cd77f63          	bgeu	a4,a3,ffffffffc02024b0 <default_check+0x5b2>
ffffffffc0201fd6:	40f507b3          	sub	a5,a0,a5
ffffffffc0201fda:	8799                	srai	a5,a5,0x6
ffffffffc0201fdc:	97b2                	add	a5,a5,a2
ffffffffc0201fde:	07b2                	slli	a5,a5,0xc
ffffffffc0201fe0:	32d7f863          	bgeu	a5,a3,ffffffffc0202310 <default_check+0x412>
ffffffffc0201fe4:	4505                	li	a0,1
ffffffffc0201fe6:	00093c03          	ld	s8,0(s2)
ffffffffc0201fea:	00893b83          	ld	s7,8(s2)
ffffffffc0201fee:	0008fb17          	auipc	s6,0x8f
ffffffffc0201ff2:	7cab2b03          	lw	s6,1994(s6) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201ff6:	01293023          	sd	s2,0(s2)
ffffffffc0201ffa:	01293423          	sd	s2,8(s2)
ffffffffc0201ffe:	0008f797          	auipc	a5,0x8f
ffffffffc0202002:	7a07ad23          	sw	zero,1978(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0202006:	1e3000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc020200a:	2e051363          	bnez	a0,ffffffffc02022f0 <default_check+0x3f2>
ffffffffc020200e:	8552                	mv	a0,s4
ffffffffc0202010:	4585                	li	a1,1
ffffffffc0202012:	211000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202016:	854e                	mv	a0,s3
ffffffffc0202018:	4585                	li	a1,1
ffffffffc020201a:	209000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc020201e:	8556                	mv	a0,s5
ffffffffc0202020:	4585                	li	a1,1
ffffffffc0202022:	201000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202026:	0008f717          	auipc	a4,0x8f
ffffffffc020202a:	79272703          	lw	a4,1938(a4) # ffffffffc02917b8 <free_area+0x10>
ffffffffc020202e:	478d                	li	a5,3
ffffffffc0202030:	2af71063          	bne	a4,a5,ffffffffc02022d0 <default_check+0x3d2>
ffffffffc0202034:	4505                	li	a0,1
ffffffffc0202036:	1b3000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc020203a:	89aa                	mv	s3,a0
ffffffffc020203c:	26050a63          	beqz	a0,ffffffffc02022b0 <default_check+0x3b2>
ffffffffc0202040:	4505                	li	a0,1
ffffffffc0202042:	1a7000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202046:	8aaa                	mv	s5,a0
ffffffffc0202048:	3c050463          	beqz	a0,ffffffffc0202410 <default_check+0x512>
ffffffffc020204c:	4505                	li	a0,1
ffffffffc020204e:	19b000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202052:	8a2a                	mv	s4,a0
ffffffffc0202054:	38050e63          	beqz	a0,ffffffffc02023f0 <default_check+0x4f2>
ffffffffc0202058:	4505                	li	a0,1
ffffffffc020205a:	18f000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc020205e:	36051963          	bnez	a0,ffffffffc02023d0 <default_check+0x4d2>
ffffffffc0202062:	4585                	li	a1,1
ffffffffc0202064:	854e                	mv	a0,s3
ffffffffc0202066:	1bd000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc020206a:	00893783          	ld	a5,8(s2)
ffffffffc020206e:	1f278163          	beq	a5,s2,ffffffffc0202250 <default_check+0x352>
ffffffffc0202072:	4505                	li	a0,1
ffffffffc0202074:	175000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202078:	8caa                	mv	s9,a0
ffffffffc020207a:	30a99b63          	bne	s3,a0,ffffffffc0202390 <default_check+0x492>
ffffffffc020207e:	4505                	li	a0,1
ffffffffc0202080:	169000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202084:	2e051663          	bnez	a0,ffffffffc0202370 <default_check+0x472>
ffffffffc0202088:	0008f797          	auipc	a5,0x8f
ffffffffc020208c:	7307a783          	lw	a5,1840(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0202090:	2c079063          	bnez	a5,ffffffffc0202350 <default_check+0x452>
ffffffffc0202094:	8566                	mv	a0,s9
ffffffffc0202096:	4585                	li	a1,1
ffffffffc0202098:	01893023          	sd	s8,0(s2)
ffffffffc020209c:	01793423          	sd	s7,8(s2)
ffffffffc02020a0:	01692823          	sw	s6,16(s2)
ffffffffc02020a4:	17f000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc02020a8:	8556                	mv	a0,s5
ffffffffc02020aa:	4585                	li	a1,1
ffffffffc02020ac:	177000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc02020b0:	8552                	mv	a0,s4
ffffffffc02020b2:	4585                	li	a1,1
ffffffffc02020b4:	16f000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc02020b8:	4515                	li	a0,5
ffffffffc02020ba:	12f000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc02020be:	89aa                	mv	s3,a0
ffffffffc02020c0:	26050863          	beqz	a0,ffffffffc0202330 <default_check+0x432>
ffffffffc02020c4:	651c                	ld	a5,8(a0)
ffffffffc02020c6:	8b89                	andi	a5,a5,2
ffffffffc02020c8:	54079463          	bnez	a5,ffffffffc0202610 <default_check+0x712>
ffffffffc02020cc:	4505                	li	a0,1
ffffffffc02020ce:	00093b83          	ld	s7,0(s2)
ffffffffc02020d2:	00893b03          	ld	s6,8(s2)
ffffffffc02020d6:	01293023          	sd	s2,0(s2)
ffffffffc02020da:	01293423          	sd	s2,8(s2)
ffffffffc02020de:	10b000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc02020e2:	50051763          	bnez	a0,ffffffffc02025f0 <default_check+0x6f2>
ffffffffc02020e6:	08098a13          	addi	s4,s3,128
ffffffffc02020ea:	8552                	mv	a0,s4
ffffffffc02020ec:	458d                	li	a1,3
ffffffffc02020ee:	0008fc17          	auipc	s8,0x8f
ffffffffc02020f2:	6cac2c03          	lw	s8,1738(s8) # ffffffffc02917b8 <free_area+0x10>
ffffffffc02020f6:	0008f797          	auipc	a5,0x8f
ffffffffc02020fa:	6c07a123          	sw	zero,1730(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc02020fe:	125000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202102:	4511                	li	a0,4
ffffffffc0202104:	0e5000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202108:	4c051463          	bnez	a0,ffffffffc02025d0 <default_check+0x6d2>
ffffffffc020210c:	0889b783          	ld	a5,136(s3)
ffffffffc0202110:	8b89                	andi	a5,a5,2
ffffffffc0202112:	48078f63          	beqz	a5,ffffffffc02025b0 <default_check+0x6b2>
ffffffffc0202116:	0909a503          	lw	a0,144(s3)
ffffffffc020211a:	478d                	li	a5,3
ffffffffc020211c:	48f51a63          	bne	a0,a5,ffffffffc02025b0 <default_check+0x6b2>
ffffffffc0202120:	0c9000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202124:	8aaa                	mv	s5,a0
ffffffffc0202126:	46050563          	beqz	a0,ffffffffc0202590 <default_check+0x692>
ffffffffc020212a:	4505                	li	a0,1
ffffffffc020212c:	0bd000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202130:	44051063          	bnez	a0,ffffffffc0202570 <default_check+0x672>
ffffffffc0202134:	415a1e63          	bne	s4,s5,ffffffffc0202550 <default_check+0x652>
ffffffffc0202138:	4585                	li	a1,1
ffffffffc020213a:	854e                	mv	a0,s3
ffffffffc020213c:	0e7000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202140:	8552                	mv	a0,s4
ffffffffc0202142:	458d                	li	a1,3
ffffffffc0202144:	0df000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202148:	0089b783          	ld	a5,8(s3)
ffffffffc020214c:	8b89                	andi	a5,a5,2
ffffffffc020214e:	3e078163          	beqz	a5,ffffffffc0202530 <default_check+0x632>
ffffffffc0202152:	0109aa83          	lw	s5,16(s3)
ffffffffc0202156:	4785                	li	a5,1
ffffffffc0202158:	3cfa9c63          	bne	s5,a5,ffffffffc0202530 <default_check+0x632>
ffffffffc020215c:	008a3783          	ld	a5,8(s4)
ffffffffc0202160:	8b89                	andi	a5,a5,2
ffffffffc0202162:	3a078763          	beqz	a5,ffffffffc0202510 <default_check+0x612>
ffffffffc0202166:	010a2703          	lw	a4,16(s4)
ffffffffc020216a:	478d                	li	a5,3
ffffffffc020216c:	3af71263          	bne	a4,a5,ffffffffc0202510 <default_check+0x612>
ffffffffc0202170:	8556                	mv	a0,s5
ffffffffc0202172:	077000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202176:	36a99d63          	bne	s3,a0,ffffffffc02024f0 <default_check+0x5f2>
ffffffffc020217a:	85d6                	mv	a1,s5
ffffffffc020217c:	0a7000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202180:	4509                	li	a0,2
ffffffffc0202182:	067000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0202186:	34aa1563          	bne	s4,a0,ffffffffc02024d0 <default_check+0x5d2>
ffffffffc020218a:	4589                	li	a1,2
ffffffffc020218c:	097000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0202190:	04098513          	addi	a0,s3,64
ffffffffc0202194:	85d6                	mv	a1,s5
ffffffffc0202196:	08d000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc020219a:	4515                	li	a0,5
ffffffffc020219c:	04d000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc02021a0:	89aa                	mv	s3,a0
ffffffffc02021a2:	48050763          	beqz	a0,ffffffffc0202630 <default_check+0x732>
ffffffffc02021a6:	8556                	mv	a0,s5
ffffffffc02021a8:	041000ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc02021ac:	2e051263          	bnez	a0,ffffffffc0202490 <default_check+0x592>
ffffffffc02021b0:	0008f797          	auipc	a5,0x8f
ffffffffc02021b4:	6087a783          	lw	a5,1544(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc02021b8:	2a079c63          	bnez	a5,ffffffffc0202470 <default_check+0x572>
ffffffffc02021bc:	854e                	mv	a0,s3
ffffffffc02021be:	4595                	li	a1,5
ffffffffc02021c0:	01892823          	sw	s8,16(s2)
ffffffffc02021c4:	01793023          	sd	s7,0(s2)
ffffffffc02021c8:	01693423          	sd	s6,8(s2)
ffffffffc02021cc:	057000ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc02021d0:	00893783          	ld	a5,8(s2)
ffffffffc02021d4:	01278963          	beq	a5,s2,ffffffffc02021e6 <default_check+0x2e8>
ffffffffc02021d8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02021dc:	679c                	ld	a5,8(a5)
ffffffffc02021de:	34fd                	addiw	s1,s1,-1
ffffffffc02021e0:	9c19                	subw	s0,s0,a4
ffffffffc02021e2:	ff279be3          	bne	a5,s2,ffffffffc02021d8 <default_check+0x2da>
ffffffffc02021e6:	26049563          	bnez	s1,ffffffffc0202450 <default_check+0x552>
ffffffffc02021ea:	46041363          	bnez	s0,ffffffffc0202650 <default_check+0x752>
ffffffffc02021ee:	60e6                	ld	ra,88(sp)
ffffffffc02021f0:	6446                	ld	s0,80(sp)
ffffffffc02021f2:	64a6                	ld	s1,72(sp)
ffffffffc02021f4:	6906                	ld	s2,64(sp)
ffffffffc02021f6:	79e2                	ld	s3,56(sp)
ffffffffc02021f8:	7a42                	ld	s4,48(sp)
ffffffffc02021fa:	7aa2                	ld	s5,40(sp)
ffffffffc02021fc:	7b02                	ld	s6,32(sp)
ffffffffc02021fe:	6be2                	ld	s7,24(sp)
ffffffffc0202200:	6c42                	ld	s8,16(sp)
ffffffffc0202202:	6ca2                	ld	s9,8(sp)
ffffffffc0202204:	6125                	addi	sp,sp,96
ffffffffc0202206:	8082                	ret
ffffffffc0202208:	4981                	li	s3,0
ffffffffc020220a:	4401                	li	s0,0
ffffffffc020220c:	4481                	li	s1,0
ffffffffc020220e:	bb1d                	j	ffffffffc0201f44 <default_check+0x46>
ffffffffc0202210:	0000a697          	auipc	a3,0xa
ffffffffc0202214:	54068693          	addi	a3,a3,1344 # ffffffffc020c750 <etext+0xe7a>
ffffffffc0202218:	0000a617          	auipc	a2,0xa
ffffffffc020221c:	b7860613          	addi	a2,a2,-1160 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202220:	0ef00593          	li	a1,239
ffffffffc0202224:	0000a517          	auipc	a0,0xa
ffffffffc0202228:	53c50513          	addi	a0,a0,1340 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020222c:	800fe0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202230:	0000a697          	auipc	a3,0xa
ffffffffc0202234:	5f068693          	addi	a3,a3,1520 # ffffffffc020c820 <etext+0xf4a>
ffffffffc0202238:	0000a617          	auipc	a2,0xa
ffffffffc020223c:	b5860613          	addi	a2,a2,-1192 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202240:	0bd00593          	li	a1,189
ffffffffc0202244:	0000a517          	auipc	a0,0xa
ffffffffc0202248:	51c50513          	addi	a0,a0,1308 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020224c:	fe1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202250:	0000a697          	auipc	a3,0xa
ffffffffc0202254:	69868693          	addi	a3,a3,1688 # ffffffffc020c8e8 <etext+0x1012>
ffffffffc0202258:	0000a617          	auipc	a2,0xa
ffffffffc020225c:	b3860613          	addi	a2,a2,-1224 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202260:	0d800593          	li	a1,216
ffffffffc0202264:	0000a517          	auipc	a0,0xa
ffffffffc0202268:	4fc50513          	addi	a0,a0,1276 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020226c:	fc1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202270:	0000a697          	auipc	a3,0xa
ffffffffc0202274:	5f068693          	addi	a3,a3,1520 # ffffffffc020c860 <etext+0xf8a>
ffffffffc0202278:	0000a617          	auipc	a2,0xa
ffffffffc020227c:	b1860613          	addi	a2,a2,-1256 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202280:	0bf00593          	li	a1,191
ffffffffc0202284:	0000a517          	auipc	a0,0xa
ffffffffc0202288:	4dc50513          	addi	a0,a0,1244 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020228c:	fa1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202290:	0000a697          	auipc	a3,0xa
ffffffffc0202294:	56868693          	addi	a3,a3,1384 # ffffffffc020c7f8 <etext+0xf22>
ffffffffc0202298:	0000a617          	auipc	a2,0xa
ffffffffc020229c:	af860613          	addi	a2,a2,-1288 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02022a0:	0bc00593          	li	a1,188
ffffffffc02022a4:	0000a517          	auipc	a0,0xa
ffffffffc02022a8:	4bc50513          	addi	a0,a0,1212 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02022ac:	f81fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02022b0:	0000a697          	auipc	a3,0xa
ffffffffc02022b4:	4e868693          	addi	a3,a3,1256 # ffffffffc020c798 <etext+0xec2>
ffffffffc02022b8:	0000a617          	auipc	a2,0xa
ffffffffc02022bc:	ad860613          	addi	a2,a2,-1320 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02022c0:	0d100593          	li	a1,209
ffffffffc02022c4:	0000a517          	auipc	a0,0xa
ffffffffc02022c8:	49c50513          	addi	a0,a0,1180 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02022cc:	f61fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02022d0:	0000a697          	auipc	a3,0xa
ffffffffc02022d4:	60868693          	addi	a3,a3,1544 # ffffffffc020c8d8 <etext+0x1002>
ffffffffc02022d8:	0000a617          	auipc	a2,0xa
ffffffffc02022dc:	ab860613          	addi	a2,a2,-1352 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02022e0:	0cf00593          	li	a1,207
ffffffffc02022e4:	0000a517          	auipc	a0,0xa
ffffffffc02022e8:	47c50513          	addi	a0,a0,1148 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02022ec:	f41fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02022f0:	0000a697          	auipc	a3,0xa
ffffffffc02022f4:	5d068693          	addi	a3,a3,1488 # ffffffffc020c8c0 <etext+0xfea>
ffffffffc02022f8:	0000a617          	auipc	a2,0xa
ffffffffc02022fc:	a9860613          	addi	a2,a2,-1384 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202300:	0ca00593          	li	a1,202
ffffffffc0202304:	0000a517          	auipc	a0,0xa
ffffffffc0202308:	45c50513          	addi	a0,a0,1116 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020230c:	f21fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202310:	0000a697          	auipc	a3,0xa
ffffffffc0202314:	59068693          	addi	a3,a3,1424 # ffffffffc020c8a0 <etext+0xfca>
ffffffffc0202318:	0000a617          	auipc	a2,0xa
ffffffffc020231c:	a7860613          	addi	a2,a2,-1416 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202320:	0c100593          	li	a1,193
ffffffffc0202324:	0000a517          	auipc	a0,0xa
ffffffffc0202328:	43c50513          	addi	a0,a0,1084 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020232c:	f01fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202330:	0000a697          	auipc	a3,0xa
ffffffffc0202334:	60068693          	addi	a3,a3,1536 # ffffffffc020c930 <etext+0x105a>
ffffffffc0202338:	0000a617          	auipc	a2,0xa
ffffffffc020233c:	a5860613          	addi	a2,a2,-1448 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202340:	0f700593          	li	a1,247
ffffffffc0202344:	0000a517          	auipc	a0,0xa
ffffffffc0202348:	41c50513          	addi	a0,a0,1052 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020234c:	ee1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202350:	0000a697          	auipc	a3,0xa
ffffffffc0202354:	5d068693          	addi	a3,a3,1488 # ffffffffc020c920 <etext+0x104a>
ffffffffc0202358:	0000a617          	auipc	a2,0xa
ffffffffc020235c:	a3860613          	addi	a2,a2,-1480 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202360:	0de00593          	li	a1,222
ffffffffc0202364:	0000a517          	auipc	a0,0xa
ffffffffc0202368:	3fc50513          	addi	a0,a0,1020 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020236c:	ec1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202370:	0000a697          	auipc	a3,0xa
ffffffffc0202374:	55068693          	addi	a3,a3,1360 # ffffffffc020c8c0 <etext+0xfea>
ffffffffc0202378:	0000a617          	auipc	a2,0xa
ffffffffc020237c:	a1860613          	addi	a2,a2,-1512 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202380:	0dc00593          	li	a1,220
ffffffffc0202384:	0000a517          	auipc	a0,0xa
ffffffffc0202388:	3dc50513          	addi	a0,a0,988 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020238c:	ea1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202390:	0000a697          	auipc	a3,0xa
ffffffffc0202394:	57068693          	addi	a3,a3,1392 # ffffffffc020c900 <etext+0x102a>
ffffffffc0202398:	0000a617          	auipc	a2,0xa
ffffffffc020239c:	9f860613          	addi	a2,a2,-1544 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02023a0:	0db00593          	li	a1,219
ffffffffc02023a4:	0000a517          	auipc	a0,0xa
ffffffffc02023a8:	3bc50513          	addi	a0,a0,956 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02023ac:	e81fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02023b0:	0000a697          	auipc	a3,0xa
ffffffffc02023b4:	3e868693          	addi	a3,a3,1000 # ffffffffc020c798 <etext+0xec2>
ffffffffc02023b8:	0000a617          	auipc	a2,0xa
ffffffffc02023bc:	9d860613          	addi	a2,a2,-1576 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02023c0:	0b800593          	li	a1,184
ffffffffc02023c4:	0000a517          	auipc	a0,0xa
ffffffffc02023c8:	39c50513          	addi	a0,a0,924 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02023cc:	e61fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02023d0:	0000a697          	auipc	a3,0xa
ffffffffc02023d4:	4f068693          	addi	a3,a3,1264 # ffffffffc020c8c0 <etext+0xfea>
ffffffffc02023d8:	0000a617          	auipc	a2,0xa
ffffffffc02023dc:	9b860613          	addi	a2,a2,-1608 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02023e0:	0d500593          	li	a1,213
ffffffffc02023e4:	0000a517          	auipc	a0,0xa
ffffffffc02023e8:	37c50513          	addi	a0,a0,892 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02023ec:	e41fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02023f0:	0000a697          	auipc	a3,0xa
ffffffffc02023f4:	3e868693          	addi	a3,a3,1000 # ffffffffc020c7d8 <etext+0xf02>
ffffffffc02023f8:	0000a617          	auipc	a2,0xa
ffffffffc02023fc:	99860613          	addi	a2,a2,-1640 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202400:	0d300593          	li	a1,211
ffffffffc0202404:	0000a517          	auipc	a0,0xa
ffffffffc0202408:	35c50513          	addi	a0,a0,860 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020240c:	e21fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202410:	0000a697          	auipc	a3,0xa
ffffffffc0202414:	3a868693          	addi	a3,a3,936 # ffffffffc020c7b8 <etext+0xee2>
ffffffffc0202418:	0000a617          	auipc	a2,0xa
ffffffffc020241c:	97860613          	addi	a2,a2,-1672 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202420:	0d200593          	li	a1,210
ffffffffc0202424:	0000a517          	auipc	a0,0xa
ffffffffc0202428:	33c50513          	addi	a0,a0,828 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020242c:	e01fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202430:	0000a697          	auipc	a3,0xa
ffffffffc0202434:	3a868693          	addi	a3,a3,936 # ffffffffc020c7d8 <etext+0xf02>
ffffffffc0202438:	0000a617          	auipc	a2,0xa
ffffffffc020243c:	95860613          	addi	a2,a2,-1704 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202440:	0ba00593          	li	a1,186
ffffffffc0202444:	0000a517          	auipc	a0,0xa
ffffffffc0202448:	31c50513          	addi	a0,a0,796 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020244c:	de1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202450:	0000a697          	auipc	a3,0xa
ffffffffc0202454:	63068693          	addi	a3,a3,1584 # ffffffffc020ca80 <etext+0x11aa>
ffffffffc0202458:	0000a617          	auipc	a2,0xa
ffffffffc020245c:	93860613          	addi	a2,a2,-1736 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202460:	12400593          	li	a1,292
ffffffffc0202464:	0000a517          	auipc	a0,0xa
ffffffffc0202468:	2fc50513          	addi	a0,a0,764 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020246c:	dc1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202470:	0000a697          	auipc	a3,0xa
ffffffffc0202474:	4b068693          	addi	a3,a3,1200 # ffffffffc020c920 <etext+0x104a>
ffffffffc0202478:	0000a617          	auipc	a2,0xa
ffffffffc020247c:	91860613          	addi	a2,a2,-1768 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202480:	11900593          	li	a1,281
ffffffffc0202484:	0000a517          	auipc	a0,0xa
ffffffffc0202488:	2dc50513          	addi	a0,a0,732 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020248c:	da1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202490:	0000a697          	auipc	a3,0xa
ffffffffc0202494:	43068693          	addi	a3,a3,1072 # ffffffffc020c8c0 <etext+0xfea>
ffffffffc0202498:	0000a617          	auipc	a2,0xa
ffffffffc020249c:	8f860613          	addi	a2,a2,-1800 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02024a0:	11700593          	li	a1,279
ffffffffc02024a4:	0000a517          	auipc	a0,0xa
ffffffffc02024a8:	2bc50513          	addi	a0,a0,700 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02024ac:	d81fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02024b0:	0000a697          	auipc	a3,0xa
ffffffffc02024b4:	3d068693          	addi	a3,a3,976 # ffffffffc020c880 <etext+0xfaa>
ffffffffc02024b8:	0000a617          	auipc	a2,0xa
ffffffffc02024bc:	8d860613          	addi	a2,a2,-1832 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02024c0:	0c000593          	li	a1,192
ffffffffc02024c4:	0000a517          	auipc	a0,0xa
ffffffffc02024c8:	29c50513          	addi	a0,a0,668 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02024cc:	d61fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02024d0:	0000a697          	auipc	a3,0xa
ffffffffc02024d4:	57068693          	addi	a3,a3,1392 # ffffffffc020ca40 <etext+0x116a>
ffffffffc02024d8:	0000a617          	auipc	a2,0xa
ffffffffc02024dc:	8b860613          	addi	a2,a2,-1864 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02024e0:	11100593          	li	a1,273
ffffffffc02024e4:	0000a517          	auipc	a0,0xa
ffffffffc02024e8:	27c50513          	addi	a0,a0,636 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02024ec:	d41fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02024f0:	0000a697          	auipc	a3,0xa
ffffffffc02024f4:	53068693          	addi	a3,a3,1328 # ffffffffc020ca20 <etext+0x114a>
ffffffffc02024f8:	0000a617          	auipc	a2,0xa
ffffffffc02024fc:	89860613          	addi	a2,a2,-1896 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202500:	10f00593          	li	a1,271
ffffffffc0202504:	0000a517          	auipc	a0,0xa
ffffffffc0202508:	25c50513          	addi	a0,a0,604 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020250c:	d21fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202510:	0000a697          	auipc	a3,0xa
ffffffffc0202514:	4e868693          	addi	a3,a3,1256 # ffffffffc020c9f8 <etext+0x1122>
ffffffffc0202518:	0000a617          	auipc	a2,0xa
ffffffffc020251c:	87860613          	addi	a2,a2,-1928 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202520:	10d00593          	li	a1,269
ffffffffc0202524:	0000a517          	auipc	a0,0xa
ffffffffc0202528:	23c50513          	addi	a0,a0,572 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020252c:	d01fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202530:	0000a697          	auipc	a3,0xa
ffffffffc0202534:	4a068693          	addi	a3,a3,1184 # ffffffffc020c9d0 <etext+0x10fa>
ffffffffc0202538:	0000a617          	auipc	a2,0xa
ffffffffc020253c:	85860613          	addi	a2,a2,-1960 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202540:	10c00593          	li	a1,268
ffffffffc0202544:	0000a517          	auipc	a0,0xa
ffffffffc0202548:	21c50513          	addi	a0,a0,540 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020254c:	ce1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202550:	0000a697          	auipc	a3,0xa
ffffffffc0202554:	47068693          	addi	a3,a3,1136 # ffffffffc020c9c0 <etext+0x10ea>
ffffffffc0202558:	0000a617          	auipc	a2,0xa
ffffffffc020255c:	83860613          	addi	a2,a2,-1992 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202560:	10700593          	li	a1,263
ffffffffc0202564:	0000a517          	auipc	a0,0xa
ffffffffc0202568:	1fc50513          	addi	a0,a0,508 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020256c:	cc1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202570:	0000a697          	auipc	a3,0xa
ffffffffc0202574:	35068693          	addi	a3,a3,848 # ffffffffc020c8c0 <etext+0xfea>
ffffffffc0202578:	0000a617          	auipc	a2,0xa
ffffffffc020257c:	81860613          	addi	a2,a2,-2024 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202580:	10600593          	li	a1,262
ffffffffc0202584:	0000a517          	auipc	a0,0xa
ffffffffc0202588:	1dc50513          	addi	a0,a0,476 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020258c:	ca1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202590:	0000a697          	auipc	a3,0xa
ffffffffc0202594:	41068693          	addi	a3,a3,1040 # ffffffffc020c9a0 <etext+0x10ca>
ffffffffc0202598:	00009617          	auipc	a2,0x9
ffffffffc020259c:	7f860613          	addi	a2,a2,2040 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02025a0:	10500593          	li	a1,261
ffffffffc02025a4:	0000a517          	auipc	a0,0xa
ffffffffc02025a8:	1bc50513          	addi	a0,a0,444 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02025ac:	c81fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02025b0:	0000a697          	auipc	a3,0xa
ffffffffc02025b4:	3c068693          	addi	a3,a3,960 # ffffffffc020c970 <etext+0x109a>
ffffffffc02025b8:	00009617          	auipc	a2,0x9
ffffffffc02025bc:	7d860613          	addi	a2,a2,2008 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02025c0:	10400593          	li	a1,260
ffffffffc02025c4:	0000a517          	auipc	a0,0xa
ffffffffc02025c8:	19c50513          	addi	a0,a0,412 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02025cc:	c61fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02025d0:	0000a697          	auipc	a3,0xa
ffffffffc02025d4:	38868693          	addi	a3,a3,904 # ffffffffc020c958 <etext+0x1082>
ffffffffc02025d8:	00009617          	auipc	a2,0x9
ffffffffc02025dc:	7b860613          	addi	a2,a2,1976 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02025e0:	10300593          	li	a1,259
ffffffffc02025e4:	0000a517          	auipc	a0,0xa
ffffffffc02025e8:	17c50513          	addi	a0,a0,380 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02025ec:	c41fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02025f0:	0000a697          	auipc	a3,0xa
ffffffffc02025f4:	2d068693          	addi	a3,a3,720 # ffffffffc020c8c0 <etext+0xfea>
ffffffffc02025f8:	00009617          	auipc	a2,0x9
ffffffffc02025fc:	79860613          	addi	a2,a2,1944 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202600:	0fd00593          	li	a1,253
ffffffffc0202604:	0000a517          	auipc	a0,0xa
ffffffffc0202608:	15c50513          	addi	a0,a0,348 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020260c:	c21fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202610:	0000a697          	auipc	a3,0xa
ffffffffc0202614:	33068693          	addi	a3,a3,816 # ffffffffc020c940 <etext+0x106a>
ffffffffc0202618:	00009617          	auipc	a2,0x9
ffffffffc020261c:	77860613          	addi	a2,a2,1912 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202620:	0f800593          	li	a1,248
ffffffffc0202624:	0000a517          	auipc	a0,0xa
ffffffffc0202628:	13c50513          	addi	a0,a0,316 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020262c:	c01fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202630:	0000a697          	auipc	a3,0xa
ffffffffc0202634:	43068693          	addi	a3,a3,1072 # ffffffffc020ca60 <etext+0x118a>
ffffffffc0202638:	00009617          	auipc	a2,0x9
ffffffffc020263c:	75860613          	addi	a2,a2,1880 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202640:	11600593          	li	a1,278
ffffffffc0202644:	0000a517          	auipc	a0,0xa
ffffffffc0202648:	11c50513          	addi	a0,a0,284 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020264c:	be1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202650:	0000a697          	auipc	a3,0xa
ffffffffc0202654:	44068693          	addi	a3,a3,1088 # ffffffffc020ca90 <etext+0x11ba>
ffffffffc0202658:	00009617          	auipc	a2,0x9
ffffffffc020265c:	73860613          	addi	a2,a2,1848 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202660:	12500593          	li	a1,293
ffffffffc0202664:	0000a517          	auipc	a0,0xa
ffffffffc0202668:	0fc50513          	addi	a0,a0,252 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020266c:	bc1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202670:	0000a697          	auipc	a3,0xa
ffffffffc0202674:	10868693          	addi	a3,a3,264 # ffffffffc020c778 <etext+0xea2>
ffffffffc0202678:	00009617          	auipc	a2,0x9
ffffffffc020267c:	71860613          	addi	a2,a2,1816 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202680:	0f200593          	li	a1,242
ffffffffc0202684:	0000a517          	auipc	a0,0xa
ffffffffc0202688:	0dc50513          	addi	a0,a0,220 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020268c:	ba1fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202690:	0000a697          	auipc	a3,0xa
ffffffffc0202694:	12868693          	addi	a3,a3,296 # ffffffffc020c7b8 <etext+0xee2>
ffffffffc0202698:	00009617          	auipc	a2,0x9
ffffffffc020269c:	6f860613          	addi	a2,a2,1784 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02026a0:	0b900593          	li	a1,185
ffffffffc02026a4:	0000a517          	auipc	a0,0xa
ffffffffc02026a8:	0bc50513          	addi	a0,a0,188 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02026ac:	b81fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02026b0 <default_free_pages>:
ffffffffc02026b0:	1141                	addi	sp,sp,-16
ffffffffc02026b2:	e406                	sd	ra,8(sp)
ffffffffc02026b4:	14058663          	beqz	a1,ffffffffc0202800 <default_free_pages+0x150>
ffffffffc02026b8:	00659713          	slli	a4,a1,0x6
ffffffffc02026bc:	00e506b3          	add	a3,a0,a4
ffffffffc02026c0:	87aa                	mv	a5,a0
ffffffffc02026c2:	c30d                	beqz	a4,ffffffffc02026e4 <default_free_pages+0x34>
ffffffffc02026c4:	6798                	ld	a4,8(a5)
ffffffffc02026c6:	8b05                	andi	a4,a4,1
ffffffffc02026c8:	10071c63          	bnez	a4,ffffffffc02027e0 <default_free_pages+0x130>
ffffffffc02026cc:	6798                	ld	a4,8(a5)
ffffffffc02026ce:	8b09                	andi	a4,a4,2
ffffffffc02026d0:	10071863          	bnez	a4,ffffffffc02027e0 <default_free_pages+0x130>
ffffffffc02026d4:	0007b423          	sd	zero,8(a5)
ffffffffc02026d8:	0007a023          	sw	zero,0(a5)
ffffffffc02026dc:	04078793          	addi	a5,a5,64
ffffffffc02026e0:	fed792e3          	bne	a5,a3,ffffffffc02026c4 <default_free_pages+0x14>
ffffffffc02026e4:	c90c                	sw	a1,16(a0)
ffffffffc02026e6:	00850893          	addi	a7,a0,8
ffffffffc02026ea:	4789                	li	a5,2
ffffffffc02026ec:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc02026f0:	0008f717          	auipc	a4,0x8f
ffffffffc02026f4:	0c872703          	lw	a4,200(a4) # ffffffffc02917b8 <free_area+0x10>
ffffffffc02026f8:	0008f697          	auipc	a3,0x8f
ffffffffc02026fc:	0b068693          	addi	a3,a3,176 # ffffffffc02917a8 <free_area>
ffffffffc0202700:	669c                	ld	a5,8(a3)
ffffffffc0202702:	9f2d                	addw	a4,a4,a1
ffffffffc0202704:	ca98                	sw	a4,16(a3)
ffffffffc0202706:	0ad78163          	beq	a5,a3,ffffffffc02027a8 <default_free_pages+0xf8>
ffffffffc020270a:	fe878713          	addi	a4,a5,-24
ffffffffc020270e:	4581                	li	a1,0
ffffffffc0202710:	01850613          	addi	a2,a0,24
ffffffffc0202714:	00e56a63          	bltu	a0,a4,ffffffffc0202728 <default_free_pages+0x78>
ffffffffc0202718:	6798                	ld	a4,8(a5)
ffffffffc020271a:	04d70c63          	beq	a4,a3,ffffffffc0202772 <default_free_pages+0xc2>
ffffffffc020271e:	87ba                	mv	a5,a4
ffffffffc0202720:	fe878713          	addi	a4,a5,-24
ffffffffc0202724:	fee57ae3          	bgeu	a0,a4,ffffffffc0202718 <default_free_pages+0x68>
ffffffffc0202728:	c199                	beqz	a1,ffffffffc020272e <default_free_pages+0x7e>
ffffffffc020272a:	0106b023          	sd	a6,0(a3)
ffffffffc020272e:	6398                	ld	a4,0(a5)
ffffffffc0202730:	e390                	sd	a2,0(a5)
ffffffffc0202732:	e710                	sd	a2,8(a4)
ffffffffc0202734:	ed18                	sd	a4,24(a0)
ffffffffc0202736:	f11c                	sd	a5,32(a0)
ffffffffc0202738:	00d70d63          	beq	a4,a3,ffffffffc0202752 <default_free_pages+0xa2>
ffffffffc020273c:	ff872583          	lw	a1,-8(a4)
ffffffffc0202740:	fe870613          	addi	a2,a4,-24
ffffffffc0202744:	02059813          	slli	a6,a1,0x20
ffffffffc0202748:	01a85793          	srli	a5,a6,0x1a
ffffffffc020274c:	97b2                	add	a5,a5,a2
ffffffffc020274e:	02f50c63          	beq	a0,a5,ffffffffc0202786 <default_free_pages+0xd6>
ffffffffc0202752:	711c                	ld	a5,32(a0)
ffffffffc0202754:	00d78c63          	beq	a5,a3,ffffffffc020276c <default_free_pages+0xbc>
ffffffffc0202758:	4910                	lw	a2,16(a0)
ffffffffc020275a:	fe878693          	addi	a3,a5,-24
ffffffffc020275e:	02061593          	slli	a1,a2,0x20
ffffffffc0202762:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202766:	972a                	add	a4,a4,a0
ffffffffc0202768:	04e68c63          	beq	a3,a4,ffffffffc02027c0 <default_free_pages+0x110>
ffffffffc020276c:	60a2                	ld	ra,8(sp)
ffffffffc020276e:	0141                	addi	sp,sp,16
ffffffffc0202770:	8082                	ret
ffffffffc0202772:	e790                	sd	a2,8(a5)
ffffffffc0202774:	f114                	sd	a3,32(a0)
ffffffffc0202776:	6798                	ld	a4,8(a5)
ffffffffc0202778:	ed1c                	sd	a5,24(a0)
ffffffffc020277a:	8832                	mv	a6,a2
ffffffffc020277c:	02d70f63          	beq	a4,a3,ffffffffc02027ba <default_free_pages+0x10a>
ffffffffc0202780:	4585                	li	a1,1
ffffffffc0202782:	87ba                	mv	a5,a4
ffffffffc0202784:	bf71                	j	ffffffffc0202720 <default_free_pages+0x70>
ffffffffc0202786:	491c                	lw	a5,16(a0)
ffffffffc0202788:	5875                	li	a6,-3
ffffffffc020278a:	9fad                	addw	a5,a5,a1
ffffffffc020278c:	fef72c23          	sw	a5,-8(a4)
ffffffffc0202790:	6108b02f          	amoand.d	zero,a6,(a7)
ffffffffc0202794:	01853803          	ld	a6,24(a0)
ffffffffc0202798:	710c                	ld	a1,32(a0)
ffffffffc020279a:	8532                	mv	a0,a2
ffffffffc020279c:	00b83423          	sd	a1,8(a6) # fffffffffffff008 <end+0x3fd686f8>
ffffffffc02027a0:	671c                	ld	a5,8(a4)
ffffffffc02027a2:	0105b023          	sd	a6,0(a1) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc02027a6:	b77d                	j	ffffffffc0202754 <default_free_pages+0xa4>
ffffffffc02027a8:	60a2                	ld	ra,8(sp)
ffffffffc02027aa:	01850713          	addi	a4,a0,24
ffffffffc02027ae:	f11c                	sd	a5,32(a0)
ffffffffc02027b0:	ed1c                	sd	a5,24(a0)
ffffffffc02027b2:	e398                	sd	a4,0(a5)
ffffffffc02027b4:	e798                	sd	a4,8(a5)
ffffffffc02027b6:	0141                	addi	sp,sp,16
ffffffffc02027b8:	8082                	ret
ffffffffc02027ba:	e290                	sd	a2,0(a3)
ffffffffc02027bc:	873e                	mv	a4,a5
ffffffffc02027be:	bfad                	j	ffffffffc0202738 <default_free_pages+0x88>
ffffffffc02027c0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02027c4:	56f5                	li	a3,-3
ffffffffc02027c6:	9f31                	addw	a4,a4,a2
ffffffffc02027c8:	c918                	sw	a4,16(a0)
ffffffffc02027ca:	ff078713          	addi	a4,a5,-16
ffffffffc02027ce:	60d7302f          	amoand.d	zero,a3,(a4)
ffffffffc02027d2:	6398                	ld	a4,0(a5)
ffffffffc02027d4:	679c                	ld	a5,8(a5)
ffffffffc02027d6:	60a2                	ld	ra,8(sp)
ffffffffc02027d8:	e71c                	sd	a5,8(a4)
ffffffffc02027da:	e398                	sd	a4,0(a5)
ffffffffc02027dc:	0141                	addi	sp,sp,16
ffffffffc02027de:	8082                	ret
ffffffffc02027e0:	0000a697          	auipc	a3,0xa
ffffffffc02027e4:	2c868693          	addi	a3,a3,712 # ffffffffc020caa8 <etext+0x11d2>
ffffffffc02027e8:	00009617          	auipc	a2,0x9
ffffffffc02027ec:	5a860613          	addi	a2,a2,1448 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02027f0:	08200593          	li	a1,130
ffffffffc02027f4:	0000a517          	auipc	a0,0xa
ffffffffc02027f8:	f6c50513          	addi	a0,a0,-148 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02027fc:	a31fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202800:	0000a697          	auipc	a3,0xa
ffffffffc0202804:	2a068693          	addi	a3,a3,672 # ffffffffc020caa0 <etext+0x11ca>
ffffffffc0202808:	00009617          	auipc	a2,0x9
ffffffffc020280c:	58860613          	addi	a2,a2,1416 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202810:	07f00593          	li	a1,127
ffffffffc0202814:	0000a517          	auipc	a0,0xa
ffffffffc0202818:	f4c50513          	addi	a0,a0,-180 # ffffffffc020c760 <etext+0xe8a>
ffffffffc020281c:	a11fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0202820 <default_alloc_pages>:
ffffffffc0202820:	c951                	beqz	a0,ffffffffc02028b4 <default_alloc_pages+0x94>
ffffffffc0202822:	0008f597          	auipc	a1,0x8f
ffffffffc0202826:	f965a583          	lw	a1,-106(a1) # ffffffffc02917b8 <free_area+0x10>
ffffffffc020282a:	86aa                	mv	a3,a0
ffffffffc020282c:	02059793          	slli	a5,a1,0x20
ffffffffc0202830:	9381                	srli	a5,a5,0x20
ffffffffc0202832:	00a7ef63          	bltu	a5,a0,ffffffffc0202850 <default_alloc_pages+0x30>
ffffffffc0202836:	0008f617          	auipc	a2,0x8f
ffffffffc020283a:	f7260613          	addi	a2,a2,-142 # ffffffffc02917a8 <free_area>
ffffffffc020283e:	87b2                	mv	a5,a2
ffffffffc0202840:	a029                	j	ffffffffc020284a <default_alloc_pages+0x2a>
ffffffffc0202842:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0202846:	00d77763          	bgeu	a4,a3,ffffffffc0202854 <default_alloc_pages+0x34>
ffffffffc020284a:	679c                	ld	a5,8(a5)
ffffffffc020284c:	fec79be3          	bne	a5,a2,ffffffffc0202842 <default_alloc_pages+0x22>
ffffffffc0202850:	4501                	li	a0,0
ffffffffc0202852:	8082                	ret
ffffffffc0202854:	ff87a883          	lw	a7,-8(a5)
ffffffffc0202858:	0007b803          	ld	a6,0(a5)
ffffffffc020285c:	6798                	ld	a4,8(a5)
ffffffffc020285e:	02089313          	slli	t1,a7,0x20
ffffffffc0202862:	02035313          	srli	t1,t1,0x20
ffffffffc0202866:	00e83423          	sd	a4,8(a6)
ffffffffc020286a:	01073023          	sd	a6,0(a4)
ffffffffc020286e:	fe878513          	addi	a0,a5,-24
ffffffffc0202872:	0266fa63          	bgeu	a3,t1,ffffffffc02028a6 <default_alloc_pages+0x86>
ffffffffc0202876:	00669713          	slli	a4,a3,0x6
ffffffffc020287a:	40d888bb          	subw	a7,a7,a3
ffffffffc020287e:	972a                	add	a4,a4,a0
ffffffffc0202880:	01172823          	sw	a7,16(a4)
ffffffffc0202884:	00870313          	addi	t1,a4,8
ffffffffc0202888:	4889                	li	a7,2
ffffffffc020288a:	4113302f          	amoor.d	zero,a7,(t1)
ffffffffc020288e:	00883883          	ld	a7,8(a6)
ffffffffc0202892:	01870313          	addi	t1,a4,24
ffffffffc0202896:	0068b023          	sd	t1,0(a7) # 10000000 <_binary_bin_sfs_img_size+0xff8ad00>
ffffffffc020289a:	00683423          	sd	t1,8(a6)
ffffffffc020289e:	03173023          	sd	a7,32(a4)
ffffffffc02028a2:	01073c23          	sd	a6,24(a4)
ffffffffc02028a6:	9d95                	subw	a1,a1,a3
ffffffffc02028a8:	ca0c                	sw	a1,16(a2)
ffffffffc02028aa:	5775                	li	a4,-3
ffffffffc02028ac:	17c1                	addi	a5,a5,-16
ffffffffc02028ae:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02028b2:	8082                	ret
ffffffffc02028b4:	1141                	addi	sp,sp,-16
ffffffffc02028b6:	0000a697          	auipc	a3,0xa
ffffffffc02028ba:	1ea68693          	addi	a3,a3,490 # ffffffffc020caa0 <etext+0x11ca>
ffffffffc02028be:	00009617          	auipc	a2,0x9
ffffffffc02028c2:	4d260613          	addi	a2,a2,1234 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02028c6:	06100593          	li	a1,97
ffffffffc02028ca:	0000a517          	auipc	a0,0xa
ffffffffc02028ce:	e9650513          	addi	a0,a0,-362 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02028d2:	e406                	sd	ra,8(sp)
ffffffffc02028d4:	959fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02028d8 <default_init_memmap>:
ffffffffc02028d8:	1141                	addi	sp,sp,-16
ffffffffc02028da:	e406                	sd	ra,8(sp)
ffffffffc02028dc:	c9e1                	beqz	a1,ffffffffc02029ac <default_init_memmap+0xd4>
ffffffffc02028de:	00659713          	slli	a4,a1,0x6
ffffffffc02028e2:	00e506b3          	add	a3,a0,a4
ffffffffc02028e6:	87aa                	mv	a5,a0
ffffffffc02028e8:	cf11                	beqz	a4,ffffffffc0202904 <default_init_memmap+0x2c>
ffffffffc02028ea:	6798                	ld	a4,8(a5)
ffffffffc02028ec:	8b05                	andi	a4,a4,1
ffffffffc02028ee:	cf59                	beqz	a4,ffffffffc020298c <default_init_memmap+0xb4>
ffffffffc02028f0:	0007a823          	sw	zero,16(a5)
ffffffffc02028f4:	0007b423          	sd	zero,8(a5)
ffffffffc02028f8:	0007a023          	sw	zero,0(a5)
ffffffffc02028fc:	04078793          	addi	a5,a5,64
ffffffffc0202900:	fed795e3          	bne	a5,a3,ffffffffc02028ea <default_init_memmap+0x12>
ffffffffc0202904:	c90c                	sw	a1,16(a0)
ffffffffc0202906:	4789                	li	a5,2
ffffffffc0202908:	00850713          	addi	a4,a0,8
ffffffffc020290c:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0202910:	0008f717          	auipc	a4,0x8f
ffffffffc0202914:	ea872703          	lw	a4,-344(a4) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0202918:	0008f697          	auipc	a3,0x8f
ffffffffc020291c:	e9068693          	addi	a3,a3,-368 # ffffffffc02917a8 <free_area>
ffffffffc0202920:	669c                	ld	a5,8(a3)
ffffffffc0202922:	9f2d                	addw	a4,a4,a1
ffffffffc0202924:	ca98                	sw	a4,16(a3)
ffffffffc0202926:	04d78663          	beq	a5,a3,ffffffffc0202972 <default_init_memmap+0x9a>
ffffffffc020292a:	fe878713          	addi	a4,a5,-24
ffffffffc020292e:	4581                	li	a1,0
ffffffffc0202930:	01850613          	addi	a2,a0,24
ffffffffc0202934:	00e56a63          	bltu	a0,a4,ffffffffc0202948 <default_init_memmap+0x70>
ffffffffc0202938:	6798                	ld	a4,8(a5)
ffffffffc020293a:	02d70263          	beq	a4,a3,ffffffffc020295e <default_init_memmap+0x86>
ffffffffc020293e:	87ba                	mv	a5,a4
ffffffffc0202940:	fe878713          	addi	a4,a5,-24
ffffffffc0202944:	fee57ae3          	bgeu	a0,a4,ffffffffc0202938 <default_init_memmap+0x60>
ffffffffc0202948:	c199                	beqz	a1,ffffffffc020294e <default_init_memmap+0x76>
ffffffffc020294a:	0106b023          	sd	a6,0(a3)
ffffffffc020294e:	6398                	ld	a4,0(a5)
ffffffffc0202950:	60a2                	ld	ra,8(sp)
ffffffffc0202952:	e390                	sd	a2,0(a5)
ffffffffc0202954:	e710                	sd	a2,8(a4)
ffffffffc0202956:	ed18                	sd	a4,24(a0)
ffffffffc0202958:	f11c                	sd	a5,32(a0)
ffffffffc020295a:	0141                	addi	sp,sp,16
ffffffffc020295c:	8082                	ret
ffffffffc020295e:	e790                	sd	a2,8(a5)
ffffffffc0202960:	f114                	sd	a3,32(a0)
ffffffffc0202962:	6798                	ld	a4,8(a5)
ffffffffc0202964:	ed1c                	sd	a5,24(a0)
ffffffffc0202966:	8832                	mv	a6,a2
ffffffffc0202968:	00d70e63          	beq	a4,a3,ffffffffc0202984 <default_init_memmap+0xac>
ffffffffc020296c:	4585                	li	a1,1
ffffffffc020296e:	87ba                	mv	a5,a4
ffffffffc0202970:	bfc1                	j	ffffffffc0202940 <default_init_memmap+0x68>
ffffffffc0202972:	60a2                	ld	ra,8(sp)
ffffffffc0202974:	01850713          	addi	a4,a0,24
ffffffffc0202978:	f11c                	sd	a5,32(a0)
ffffffffc020297a:	ed1c                	sd	a5,24(a0)
ffffffffc020297c:	e398                	sd	a4,0(a5)
ffffffffc020297e:	e798                	sd	a4,8(a5)
ffffffffc0202980:	0141                	addi	sp,sp,16
ffffffffc0202982:	8082                	ret
ffffffffc0202984:	60a2                	ld	ra,8(sp)
ffffffffc0202986:	e290                	sd	a2,0(a3)
ffffffffc0202988:	0141                	addi	sp,sp,16
ffffffffc020298a:	8082                	ret
ffffffffc020298c:	0000a697          	auipc	a3,0xa
ffffffffc0202990:	14468693          	addi	a3,a3,324 # ffffffffc020cad0 <etext+0x11fa>
ffffffffc0202994:	00009617          	auipc	a2,0x9
ffffffffc0202998:	3fc60613          	addi	a2,a2,1020 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020299c:	04800593          	li	a1,72
ffffffffc02029a0:	0000a517          	auipc	a0,0xa
ffffffffc02029a4:	dc050513          	addi	a0,a0,-576 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02029a8:	885fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02029ac:	0000a697          	auipc	a3,0xa
ffffffffc02029b0:	0f468693          	addi	a3,a3,244 # ffffffffc020caa0 <etext+0x11ca>
ffffffffc02029b4:	00009617          	auipc	a2,0x9
ffffffffc02029b8:	3dc60613          	addi	a2,a2,988 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02029bc:	04500593          	li	a1,69
ffffffffc02029c0:	0000a517          	auipc	a0,0xa
ffffffffc02029c4:	da050513          	addi	a0,a0,-608 # ffffffffc020c760 <etext+0xe8a>
ffffffffc02029c8:	865fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02029cc <pa2page.part.0>:
ffffffffc02029cc:	1141                	addi	sp,sp,-16
ffffffffc02029ce:	0000a617          	auipc	a2,0xa
ffffffffc02029d2:	d6260613          	addi	a2,a2,-670 # ffffffffc020c730 <etext+0xe5a>
ffffffffc02029d6:	06900593          	li	a1,105
ffffffffc02029da:	0000a517          	auipc	a0,0xa
ffffffffc02029de:	cae50513          	addi	a0,a0,-850 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02029e2:	e406                	sd	ra,8(sp)
ffffffffc02029e4:	849fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02029e8 <alloc_pages>:
ffffffffc02029e8:	100027f3          	csrr	a5,sstatus
ffffffffc02029ec:	8b89                	andi	a5,a5,2
ffffffffc02029ee:	e799                	bnez	a5,ffffffffc02029fc <alloc_pages+0x14>
ffffffffc02029f0:	00094797          	auipc	a5,0x94
ffffffffc02029f4:	ea07b783          	ld	a5,-352(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02029f8:	6f9c                	ld	a5,24(a5)
ffffffffc02029fa:	8782                	jr	a5
ffffffffc02029fc:	1101                	addi	sp,sp,-32
ffffffffc02029fe:	ec06                	sd	ra,24(sp)
ffffffffc0202a00:	e42a                	sd	a0,8(sp)
ffffffffc0202a02:	b00fe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0202a06:	00094797          	auipc	a5,0x94
ffffffffc0202a0a:	e8a7b783          	ld	a5,-374(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202a0e:	6522                	ld	a0,8(sp)
ffffffffc0202a10:	6f9c                	ld	a5,24(a5)
ffffffffc0202a12:	9782                	jalr	a5
ffffffffc0202a14:	e42a                	sd	a0,8(sp)
ffffffffc0202a16:	ae6fe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0202a1a:	60e2                	ld	ra,24(sp)
ffffffffc0202a1c:	6522                	ld	a0,8(sp)
ffffffffc0202a1e:	6105                	addi	sp,sp,32
ffffffffc0202a20:	8082                	ret

ffffffffc0202a22 <free_pages>:
ffffffffc0202a22:	100027f3          	csrr	a5,sstatus
ffffffffc0202a26:	8b89                	andi	a5,a5,2
ffffffffc0202a28:	e799                	bnez	a5,ffffffffc0202a36 <free_pages+0x14>
ffffffffc0202a2a:	00094797          	auipc	a5,0x94
ffffffffc0202a2e:	e667b783          	ld	a5,-410(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202a32:	739c                	ld	a5,32(a5)
ffffffffc0202a34:	8782                	jr	a5
ffffffffc0202a36:	1101                	addi	sp,sp,-32
ffffffffc0202a38:	ec06                	sd	ra,24(sp)
ffffffffc0202a3a:	e42e                	sd	a1,8(sp)
ffffffffc0202a3c:	e02a                	sd	a0,0(sp)
ffffffffc0202a3e:	ac4fe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0202a42:	00094797          	auipc	a5,0x94
ffffffffc0202a46:	e4e7b783          	ld	a5,-434(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202a4a:	65a2                	ld	a1,8(sp)
ffffffffc0202a4c:	6502                	ld	a0,0(sp)
ffffffffc0202a4e:	739c                	ld	a5,32(a5)
ffffffffc0202a50:	9782                	jalr	a5
ffffffffc0202a52:	60e2                	ld	ra,24(sp)
ffffffffc0202a54:	6105                	addi	sp,sp,32
ffffffffc0202a56:	aa6fe06f          	j	ffffffffc0200cfc <intr_enable>

ffffffffc0202a5a <nr_free_pages>:
ffffffffc0202a5a:	100027f3          	csrr	a5,sstatus
ffffffffc0202a5e:	8b89                	andi	a5,a5,2
ffffffffc0202a60:	e799                	bnez	a5,ffffffffc0202a6e <nr_free_pages+0x14>
ffffffffc0202a62:	00094797          	auipc	a5,0x94
ffffffffc0202a66:	e2e7b783          	ld	a5,-466(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202a6a:	779c                	ld	a5,40(a5)
ffffffffc0202a6c:	8782                	jr	a5
ffffffffc0202a6e:	1101                	addi	sp,sp,-32
ffffffffc0202a70:	ec06                	sd	ra,24(sp)
ffffffffc0202a72:	a90fe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0202a76:	00094797          	auipc	a5,0x94
ffffffffc0202a7a:	e1a7b783          	ld	a5,-486(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202a7e:	779c                	ld	a5,40(a5)
ffffffffc0202a80:	9782                	jalr	a5
ffffffffc0202a82:	e42a                	sd	a0,8(sp)
ffffffffc0202a84:	a78fe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0202a88:	60e2                	ld	ra,24(sp)
ffffffffc0202a8a:	6522                	ld	a0,8(sp)
ffffffffc0202a8c:	6105                	addi	sp,sp,32
ffffffffc0202a8e:	8082                	ret

ffffffffc0202a90 <get_pte>:
ffffffffc0202a90:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202a94:	1ff7f793          	andi	a5,a5,511
ffffffffc0202a98:	078e                	slli	a5,a5,0x3
ffffffffc0202a9a:	00f50733          	add	a4,a0,a5
ffffffffc0202a9e:	6314                	ld	a3,0(a4)
ffffffffc0202aa0:	7139                	addi	sp,sp,-64
ffffffffc0202aa2:	f822                	sd	s0,48(sp)
ffffffffc0202aa4:	f426                	sd	s1,40(sp)
ffffffffc0202aa6:	fc06                	sd	ra,56(sp)
ffffffffc0202aa8:	0016f793          	andi	a5,a3,1
ffffffffc0202aac:	842e                	mv	s0,a1
ffffffffc0202aae:	8832                	mv	a6,a2
ffffffffc0202ab0:	00094497          	auipc	s1,0x94
ffffffffc0202ab4:	e0048493          	addi	s1,s1,-512 # ffffffffc02968b0 <npage>
ffffffffc0202ab8:	ebd1                	bnez	a5,ffffffffc0202b4c <get_pte+0xbc>
ffffffffc0202aba:	16060d63          	beqz	a2,ffffffffc0202c34 <get_pte+0x1a4>
ffffffffc0202abe:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac2:	8b89                	andi	a5,a5,2
ffffffffc0202ac4:	16079e63          	bnez	a5,ffffffffc0202c40 <get_pte+0x1b0>
ffffffffc0202ac8:	00094797          	auipc	a5,0x94
ffffffffc0202acc:	dc87b783          	ld	a5,-568(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202ad0:	4505                	li	a0,1
ffffffffc0202ad2:	e43a                	sd	a4,8(sp)
ffffffffc0202ad4:	6f9c                	ld	a5,24(a5)
ffffffffc0202ad6:	e832                	sd	a2,16(sp)
ffffffffc0202ad8:	9782                	jalr	a5
ffffffffc0202ada:	6722                	ld	a4,8(sp)
ffffffffc0202adc:	6842                	ld	a6,16(sp)
ffffffffc0202ade:	87aa                	mv	a5,a0
ffffffffc0202ae0:	14078a63          	beqz	a5,ffffffffc0202c34 <get_pte+0x1a4>
ffffffffc0202ae4:	00094517          	auipc	a0,0x94
ffffffffc0202ae8:	dd453503          	ld	a0,-556(a0) # ffffffffc02968b8 <pages>
ffffffffc0202aec:	000808b7          	lui	a7,0x80
ffffffffc0202af0:	00094497          	auipc	s1,0x94
ffffffffc0202af4:	dc048493          	addi	s1,s1,-576 # ffffffffc02968b0 <npage>
ffffffffc0202af8:	40a78533          	sub	a0,a5,a0
ffffffffc0202afc:	8519                	srai	a0,a0,0x6
ffffffffc0202afe:	9546                	add	a0,a0,a7
ffffffffc0202b00:	6090                	ld	a2,0(s1)
ffffffffc0202b02:	00c51693          	slli	a3,a0,0xc
ffffffffc0202b06:	4585                	li	a1,1
ffffffffc0202b08:	82b1                	srli	a3,a3,0xc
ffffffffc0202b0a:	c38c                	sw	a1,0(a5)
ffffffffc0202b0c:	0532                	slli	a0,a0,0xc
ffffffffc0202b0e:	1ac6f763          	bgeu	a3,a2,ffffffffc0202cbc <get_pte+0x22c>
ffffffffc0202b12:	00094697          	auipc	a3,0x94
ffffffffc0202b16:	d966b683          	ld	a3,-618(a3) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202b1a:	6605                	lui	a2,0x1
ffffffffc0202b1c:	4581                	li	a1,0
ffffffffc0202b1e:	9536                	add	a0,a0,a3
ffffffffc0202b20:	ec42                	sd	a6,24(sp)
ffffffffc0202b22:	e83e                	sd	a5,16(sp)
ffffffffc0202b24:	e43a                	sd	a4,8(sp)
ffffffffc0202b26:	0c1080ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0202b2a:	00094697          	auipc	a3,0x94
ffffffffc0202b2e:	d8e6b683          	ld	a3,-626(a3) # ffffffffc02968b8 <pages>
ffffffffc0202b32:	67c2                	ld	a5,16(sp)
ffffffffc0202b34:	000808b7          	lui	a7,0x80
ffffffffc0202b38:	6722                	ld	a4,8(sp)
ffffffffc0202b3a:	40d786b3          	sub	a3,a5,a3
ffffffffc0202b3e:	8699                	srai	a3,a3,0x6
ffffffffc0202b40:	96c6                	add	a3,a3,a7
ffffffffc0202b42:	06aa                	slli	a3,a3,0xa
ffffffffc0202b44:	6862                	ld	a6,24(sp)
ffffffffc0202b46:	0116e693          	ori	a3,a3,17
ffffffffc0202b4a:	e314                	sd	a3,0(a4)
ffffffffc0202b4c:	c006f693          	andi	a3,a3,-1024
ffffffffc0202b50:	6098                	ld	a4,0(s1)
ffffffffc0202b52:	068a                	slli	a3,a3,0x2
ffffffffc0202b54:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202b58:	14e7f663          	bgeu	a5,a4,ffffffffc0202ca4 <get_pte+0x214>
ffffffffc0202b5c:	00094897          	auipc	a7,0x94
ffffffffc0202b60:	d4c88893          	addi	a7,a7,-692 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202b64:	0008b603          	ld	a2,0(a7)
ffffffffc0202b68:	01545793          	srli	a5,s0,0x15
ffffffffc0202b6c:	1ff7f793          	andi	a5,a5,511
ffffffffc0202b70:	96b2                	add	a3,a3,a2
ffffffffc0202b72:	078e                	slli	a5,a5,0x3
ffffffffc0202b74:	97b6                	add	a5,a5,a3
ffffffffc0202b76:	6394                	ld	a3,0(a5)
ffffffffc0202b78:	0016f613          	andi	a2,a3,1
ffffffffc0202b7c:	e659                	bnez	a2,ffffffffc0202c0a <get_pte+0x17a>
ffffffffc0202b7e:	0a080b63          	beqz	a6,ffffffffc0202c34 <get_pte+0x1a4>
ffffffffc0202b82:	10002773          	csrr	a4,sstatus
ffffffffc0202b86:	8b09                	andi	a4,a4,2
ffffffffc0202b88:	ef71                	bnez	a4,ffffffffc0202c64 <get_pte+0x1d4>
ffffffffc0202b8a:	00094717          	auipc	a4,0x94
ffffffffc0202b8e:	d0673703          	ld	a4,-762(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc0202b92:	4505                	li	a0,1
ffffffffc0202b94:	e43e                	sd	a5,8(sp)
ffffffffc0202b96:	6f18                	ld	a4,24(a4)
ffffffffc0202b98:	9702                	jalr	a4
ffffffffc0202b9a:	67a2                	ld	a5,8(sp)
ffffffffc0202b9c:	872a                	mv	a4,a0
ffffffffc0202b9e:	00094897          	auipc	a7,0x94
ffffffffc0202ba2:	d0a88893          	addi	a7,a7,-758 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202ba6:	c759                	beqz	a4,ffffffffc0202c34 <get_pte+0x1a4>
ffffffffc0202ba8:	00094697          	auipc	a3,0x94
ffffffffc0202bac:	d106b683          	ld	a3,-752(a3) # ffffffffc02968b8 <pages>
ffffffffc0202bb0:	00080837          	lui	a6,0x80
ffffffffc0202bb4:	608c                	ld	a1,0(s1)
ffffffffc0202bb6:	40d706b3          	sub	a3,a4,a3
ffffffffc0202bba:	8699                	srai	a3,a3,0x6
ffffffffc0202bbc:	96c2                	add	a3,a3,a6
ffffffffc0202bbe:	00c69613          	slli	a2,a3,0xc
ffffffffc0202bc2:	4505                	li	a0,1
ffffffffc0202bc4:	8231                	srli	a2,a2,0xc
ffffffffc0202bc6:	c308                	sw	a0,0(a4)
ffffffffc0202bc8:	06b2                	slli	a3,a3,0xc
ffffffffc0202bca:	10b67663          	bgeu	a2,a1,ffffffffc0202cd6 <get_pte+0x246>
ffffffffc0202bce:	0008b503          	ld	a0,0(a7)
ffffffffc0202bd2:	6605                	lui	a2,0x1
ffffffffc0202bd4:	4581                	li	a1,0
ffffffffc0202bd6:	9536                	add	a0,a0,a3
ffffffffc0202bd8:	e83a                	sd	a4,16(sp)
ffffffffc0202bda:	e43e                	sd	a5,8(sp)
ffffffffc0202bdc:	00b080ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0202be0:	00094697          	auipc	a3,0x94
ffffffffc0202be4:	cd86b683          	ld	a3,-808(a3) # ffffffffc02968b8 <pages>
ffffffffc0202be8:	6742                	ld	a4,16(sp)
ffffffffc0202bea:	00080837          	lui	a6,0x80
ffffffffc0202bee:	67a2                	ld	a5,8(sp)
ffffffffc0202bf0:	40d706b3          	sub	a3,a4,a3
ffffffffc0202bf4:	8699                	srai	a3,a3,0x6
ffffffffc0202bf6:	96c2                	add	a3,a3,a6
ffffffffc0202bf8:	06aa                	slli	a3,a3,0xa
ffffffffc0202bfa:	0116e693          	ori	a3,a3,17
ffffffffc0202bfe:	e394                	sd	a3,0(a5)
ffffffffc0202c00:	6098                	ld	a4,0(s1)
ffffffffc0202c02:	00094897          	auipc	a7,0x94
ffffffffc0202c06:	ca688893          	addi	a7,a7,-858 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202c0a:	c006f693          	andi	a3,a3,-1024
ffffffffc0202c0e:	068a                	slli	a3,a3,0x2
ffffffffc0202c10:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202c14:	06e7fc63          	bgeu	a5,a4,ffffffffc0202c8c <get_pte+0x1fc>
ffffffffc0202c18:	0008b783          	ld	a5,0(a7)
ffffffffc0202c1c:	8031                	srli	s0,s0,0xc
ffffffffc0202c1e:	1ff47413          	andi	s0,s0,511
ffffffffc0202c22:	040e                	slli	s0,s0,0x3
ffffffffc0202c24:	96be                	add	a3,a3,a5
ffffffffc0202c26:	70e2                	ld	ra,56(sp)
ffffffffc0202c28:	00868533          	add	a0,a3,s0
ffffffffc0202c2c:	7442                	ld	s0,48(sp)
ffffffffc0202c2e:	74a2                	ld	s1,40(sp)
ffffffffc0202c30:	6121                	addi	sp,sp,64
ffffffffc0202c32:	8082                	ret
ffffffffc0202c34:	70e2                	ld	ra,56(sp)
ffffffffc0202c36:	7442                	ld	s0,48(sp)
ffffffffc0202c38:	74a2                	ld	s1,40(sp)
ffffffffc0202c3a:	4501                	li	a0,0
ffffffffc0202c3c:	6121                	addi	sp,sp,64
ffffffffc0202c3e:	8082                	ret
ffffffffc0202c40:	e83a                	sd	a4,16(sp)
ffffffffc0202c42:	ec32                	sd	a2,24(sp)
ffffffffc0202c44:	8befe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0202c48:	00094797          	auipc	a5,0x94
ffffffffc0202c4c:	c487b783          	ld	a5,-952(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202c50:	4505                	li	a0,1
ffffffffc0202c52:	6f9c                	ld	a5,24(a5)
ffffffffc0202c54:	9782                	jalr	a5
ffffffffc0202c56:	e42a                	sd	a0,8(sp)
ffffffffc0202c58:	8a4fe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0202c5c:	6862                	ld	a6,24(sp)
ffffffffc0202c5e:	6742                	ld	a4,16(sp)
ffffffffc0202c60:	67a2                	ld	a5,8(sp)
ffffffffc0202c62:	bdbd                	j	ffffffffc0202ae0 <get_pte+0x50>
ffffffffc0202c64:	e83e                	sd	a5,16(sp)
ffffffffc0202c66:	89cfe0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0202c6a:	00094717          	auipc	a4,0x94
ffffffffc0202c6e:	c2673703          	ld	a4,-986(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc0202c72:	4505                	li	a0,1
ffffffffc0202c74:	6f18                	ld	a4,24(a4)
ffffffffc0202c76:	9702                	jalr	a4
ffffffffc0202c78:	e42a                	sd	a0,8(sp)
ffffffffc0202c7a:	882fe0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0202c7e:	6722                	ld	a4,8(sp)
ffffffffc0202c80:	67c2                	ld	a5,16(sp)
ffffffffc0202c82:	00094897          	auipc	a7,0x94
ffffffffc0202c86:	c2688893          	addi	a7,a7,-986 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202c8a:	bf31                	j	ffffffffc0202ba6 <get_pte+0x116>
ffffffffc0202c8c:	0000a617          	auipc	a2,0xa
ffffffffc0202c90:	9d460613          	addi	a2,a2,-1580 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0202c94:	13200593          	li	a1,306
ffffffffc0202c98:	0000a517          	auipc	a0,0xa
ffffffffc0202c9c:	e6050513          	addi	a0,a0,-416 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202ca0:	d8cfd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202ca4:	0000a617          	auipc	a2,0xa
ffffffffc0202ca8:	9bc60613          	addi	a2,a2,-1604 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0202cac:	12500593          	li	a1,293
ffffffffc0202cb0:	0000a517          	auipc	a0,0xa
ffffffffc0202cb4:	e4850513          	addi	a0,a0,-440 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202cb8:	d74fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202cbc:	86aa                	mv	a3,a0
ffffffffc0202cbe:	0000a617          	auipc	a2,0xa
ffffffffc0202cc2:	9a260613          	addi	a2,a2,-1630 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0202cc6:	12100593          	li	a1,289
ffffffffc0202cca:	0000a517          	auipc	a0,0xa
ffffffffc0202cce:	e2e50513          	addi	a0,a0,-466 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202cd2:	d5afd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202cd6:	0000a617          	auipc	a2,0xa
ffffffffc0202cda:	98a60613          	addi	a2,a2,-1654 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0202cde:	12f00593          	li	a1,303
ffffffffc0202ce2:	0000a517          	auipc	a0,0xa
ffffffffc0202ce6:	e1650513          	addi	a0,a0,-490 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202cea:	d42fd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0202cee <boot_map_segment>:
ffffffffc0202cee:	7139                	addi	sp,sp,-64
ffffffffc0202cf0:	f04a                	sd	s2,32(sp)
ffffffffc0202cf2:	6905                	lui	s2,0x1
ffffffffc0202cf4:	00d5c833          	xor	a6,a1,a3
ffffffffc0202cf8:	fff90793          	addi	a5,s2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0202cfc:	fc06                	sd	ra,56(sp)
ffffffffc0202cfe:	00f87833          	and	a6,a6,a5
ffffffffc0202d02:	08081563          	bnez	a6,ffffffffc0202d8c <boot_map_segment+0x9e>
ffffffffc0202d06:	f426                	sd	s1,40(sp)
ffffffffc0202d08:	963e                	add	a2,a2,a5
ffffffffc0202d0a:	00f5f4b3          	and	s1,a1,a5
ffffffffc0202d0e:	94b2                	add	s1,s1,a2
ffffffffc0202d10:	80b1                	srli	s1,s1,0xc
ffffffffc0202d12:	c8a1                	beqz	s1,ffffffffc0202d62 <boot_map_segment+0x74>
ffffffffc0202d14:	77fd                	lui	a5,0xfffff
ffffffffc0202d16:	00176713          	ori	a4,a4,1
ffffffffc0202d1a:	f822                	sd	s0,48(sp)
ffffffffc0202d1c:	e852                	sd	s4,16(sp)
ffffffffc0202d1e:	8efd                	and	a3,a3,a5
ffffffffc0202d20:	02071a13          	slli	s4,a4,0x20
ffffffffc0202d24:	00f5f433          	and	s0,a1,a5
ffffffffc0202d28:	ec4e                	sd	s3,24(sp)
ffffffffc0202d2a:	e456                	sd	s5,8(sp)
ffffffffc0202d2c:	89aa                	mv	s3,a0
ffffffffc0202d2e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0202d32:	40868ab3          	sub	s5,a3,s0
ffffffffc0202d36:	4605                	li	a2,1
ffffffffc0202d38:	85a2                	mv	a1,s0
ffffffffc0202d3a:	854e                	mv	a0,s3
ffffffffc0202d3c:	d55ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc0202d40:	c515                	beqz	a0,ffffffffc0202d6c <boot_map_segment+0x7e>
ffffffffc0202d42:	008a87b3          	add	a5,s5,s0
ffffffffc0202d46:	83b1                	srli	a5,a5,0xc
ffffffffc0202d48:	07aa                	slli	a5,a5,0xa
ffffffffc0202d4a:	0147e7b3          	or	a5,a5,s4
ffffffffc0202d4e:	0017e793          	ori	a5,a5,1
ffffffffc0202d52:	14fd                	addi	s1,s1,-1
ffffffffc0202d54:	e11c                	sd	a5,0(a0)
ffffffffc0202d56:	944a                	add	s0,s0,s2
ffffffffc0202d58:	fcf9                	bnez	s1,ffffffffc0202d36 <boot_map_segment+0x48>
ffffffffc0202d5a:	7442                	ld	s0,48(sp)
ffffffffc0202d5c:	69e2                	ld	s3,24(sp)
ffffffffc0202d5e:	6a42                	ld	s4,16(sp)
ffffffffc0202d60:	6aa2                	ld	s5,8(sp)
ffffffffc0202d62:	70e2                	ld	ra,56(sp)
ffffffffc0202d64:	74a2                	ld	s1,40(sp)
ffffffffc0202d66:	7902                	ld	s2,32(sp)
ffffffffc0202d68:	6121                	addi	sp,sp,64
ffffffffc0202d6a:	8082                	ret
ffffffffc0202d6c:	0000a697          	auipc	a3,0xa
ffffffffc0202d70:	db468693          	addi	a3,a3,-588 # ffffffffc020cb20 <etext+0x124a>
ffffffffc0202d74:	00009617          	auipc	a2,0x9
ffffffffc0202d78:	01c60613          	addi	a2,a2,28 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202d7c:	09c00593          	li	a1,156
ffffffffc0202d80:	0000a517          	auipc	a0,0xa
ffffffffc0202d84:	d7850513          	addi	a0,a0,-648 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202d88:	ca4fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202d8c:	0000a697          	auipc	a3,0xa
ffffffffc0202d90:	d7c68693          	addi	a3,a3,-644 # ffffffffc020cb08 <etext+0x1232>
ffffffffc0202d94:	00009617          	auipc	a2,0x9
ffffffffc0202d98:	ffc60613          	addi	a2,a2,-4 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202d9c:	09500593          	li	a1,149
ffffffffc0202da0:	0000a517          	auipc	a0,0xa
ffffffffc0202da4:	d5850513          	addi	a0,a0,-680 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202da8:	f822                	sd	s0,48(sp)
ffffffffc0202daa:	f426                	sd	s1,40(sp)
ffffffffc0202dac:	ec4e                	sd	s3,24(sp)
ffffffffc0202dae:	e852                	sd	s4,16(sp)
ffffffffc0202db0:	e456                	sd	s5,8(sp)
ffffffffc0202db2:	c7afd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0202db6 <get_page>:
ffffffffc0202db6:	1141                	addi	sp,sp,-16
ffffffffc0202db8:	e022                	sd	s0,0(sp)
ffffffffc0202dba:	8432                	mv	s0,a2
ffffffffc0202dbc:	4601                	li	a2,0
ffffffffc0202dbe:	e406                	sd	ra,8(sp)
ffffffffc0202dc0:	cd1ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc0202dc4:	c011                	beqz	s0,ffffffffc0202dc8 <get_page+0x12>
ffffffffc0202dc6:	e008                	sd	a0,0(s0)
ffffffffc0202dc8:	c511                	beqz	a0,ffffffffc0202dd4 <get_page+0x1e>
ffffffffc0202dca:	611c                	ld	a5,0(a0)
ffffffffc0202dcc:	4501                	li	a0,0
ffffffffc0202dce:	0017f713          	andi	a4,a5,1
ffffffffc0202dd2:	e709                	bnez	a4,ffffffffc0202ddc <get_page+0x26>
ffffffffc0202dd4:	60a2                	ld	ra,8(sp)
ffffffffc0202dd6:	6402                	ld	s0,0(sp)
ffffffffc0202dd8:	0141                	addi	sp,sp,16
ffffffffc0202dda:	8082                	ret
ffffffffc0202ddc:	00094717          	auipc	a4,0x94
ffffffffc0202de0:	ad473703          	ld	a4,-1324(a4) # ffffffffc02968b0 <npage>
ffffffffc0202de4:	078a                	slli	a5,a5,0x2
ffffffffc0202de6:	83b1                	srli	a5,a5,0xc
ffffffffc0202de8:	00e7ff63          	bgeu	a5,a4,ffffffffc0202e06 <get_page+0x50>
ffffffffc0202dec:	00094517          	auipc	a0,0x94
ffffffffc0202df0:	acc53503          	ld	a0,-1332(a0) # ffffffffc02968b8 <pages>
ffffffffc0202df4:	60a2                	ld	ra,8(sp)
ffffffffc0202df6:	6402                	ld	s0,0(sp)
ffffffffc0202df8:	079a                	slli	a5,a5,0x6
ffffffffc0202dfa:	fe000737          	lui	a4,0xfe000
ffffffffc0202dfe:	97ba                	add	a5,a5,a4
ffffffffc0202e00:	953e                	add	a0,a0,a5
ffffffffc0202e02:	0141                	addi	sp,sp,16
ffffffffc0202e04:	8082                	ret
ffffffffc0202e06:	bc7ff0ef          	jal	ffffffffc02029cc <pa2page.part.0>

ffffffffc0202e0a <unmap_range>:
ffffffffc0202e0a:	715d                	addi	sp,sp,-80
ffffffffc0202e0c:	00c5e7b3          	or	a5,a1,a2
ffffffffc0202e10:	e486                	sd	ra,72(sp)
ffffffffc0202e12:	e0a2                	sd	s0,64(sp)
ffffffffc0202e14:	fc26                	sd	s1,56(sp)
ffffffffc0202e16:	f84a                	sd	s2,48(sp)
ffffffffc0202e18:	f44e                	sd	s3,40(sp)
ffffffffc0202e1a:	f052                	sd	s4,32(sp)
ffffffffc0202e1c:	ec56                	sd	s5,24(sp)
ffffffffc0202e1e:	03479713          	slli	a4,a5,0x34
ffffffffc0202e22:	ef61                	bnez	a4,ffffffffc0202efa <unmap_range+0xf0>
ffffffffc0202e24:	00200a37          	lui	s4,0x200
ffffffffc0202e28:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202e2c:	0145b733          	sltu	a4,a1,s4
ffffffffc0202e30:	0017b793          	seqz	a5,a5
ffffffffc0202e34:	8fd9                	or	a5,a5,a4
ffffffffc0202e36:	842e                	mv	s0,a1
ffffffffc0202e38:	84b2                	mv	s1,a2
ffffffffc0202e3a:	e3e5                	bnez	a5,ffffffffc0202f1a <unmap_range+0x110>
ffffffffc0202e3c:	4785                	li	a5,1
ffffffffc0202e3e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202e40:	0785                	addi	a5,a5,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc0202e42:	892a                	mv	s2,a0
ffffffffc0202e44:	6985                	lui	s3,0x1
ffffffffc0202e46:	ffe00ab7          	lui	s5,0xffe00
ffffffffc0202e4a:	0cf67863          	bgeu	a2,a5,ffffffffc0202f1a <unmap_range+0x110>
ffffffffc0202e4e:	4601                	li	a2,0
ffffffffc0202e50:	85a2                	mv	a1,s0
ffffffffc0202e52:	854a                	mv	a0,s2
ffffffffc0202e54:	c3dff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc0202e58:	87aa                	mv	a5,a0
ffffffffc0202e5a:	cd31                	beqz	a0,ffffffffc0202eb6 <unmap_range+0xac>
ffffffffc0202e5c:	6118                	ld	a4,0(a0)
ffffffffc0202e5e:	ef11                	bnez	a4,ffffffffc0202e7a <unmap_range+0x70>
ffffffffc0202e60:	944e                	add	s0,s0,s3
ffffffffc0202e62:	c019                	beqz	s0,ffffffffc0202e68 <unmap_range+0x5e>
ffffffffc0202e64:	fe9465e3          	bltu	s0,s1,ffffffffc0202e4e <unmap_range+0x44>
ffffffffc0202e68:	60a6                	ld	ra,72(sp)
ffffffffc0202e6a:	6406                	ld	s0,64(sp)
ffffffffc0202e6c:	74e2                	ld	s1,56(sp)
ffffffffc0202e6e:	7942                	ld	s2,48(sp)
ffffffffc0202e70:	79a2                	ld	s3,40(sp)
ffffffffc0202e72:	7a02                	ld	s4,32(sp)
ffffffffc0202e74:	6ae2                	ld	s5,24(sp)
ffffffffc0202e76:	6161                	addi	sp,sp,80
ffffffffc0202e78:	8082                	ret
ffffffffc0202e7a:	00177693          	andi	a3,a4,1
ffffffffc0202e7e:	d2ed                	beqz	a3,ffffffffc0202e60 <unmap_range+0x56>
ffffffffc0202e80:	00094697          	auipc	a3,0x94
ffffffffc0202e84:	a306b683          	ld	a3,-1488(a3) # ffffffffc02968b0 <npage>
ffffffffc0202e88:	070a                	slli	a4,a4,0x2
ffffffffc0202e8a:	8331                	srli	a4,a4,0xc
ffffffffc0202e8c:	0ad77763          	bgeu	a4,a3,ffffffffc0202f3a <unmap_range+0x130>
ffffffffc0202e90:	00094517          	auipc	a0,0x94
ffffffffc0202e94:	a2853503          	ld	a0,-1496(a0) # ffffffffc02968b8 <pages>
ffffffffc0202e98:	071a                	slli	a4,a4,0x6
ffffffffc0202e9a:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202e9e:	9736                	add	a4,a4,a3
ffffffffc0202ea0:	953a                	add	a0,a0,a4
ffffffffc0202ea2:	4118                	lw	a4,0(a0)
ffffffffc0202ea4:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd696ef>
ffffffffc0202ea6:	c118                	sw	a4,0(a0)
ffffffffc0202ea8:	cb19                	beqz	a4,ffffffffc0202ebe <unmap_range+0xb4>
ffffffffc0202eaa:	0007b023          	sd	zero,0(a5)
ffffffffc0202eae:	12040073          	sfence.vma	s0
ffffffffc0202eb2:	944e                	add	s0,s0,s3
ffffffffc0202eb4:	b77d                	j	ffffffffc0202e62 <unmap_range+0x58>
ffffffffc0202eb6:	9452                	add	s0,s0,s4
ffffffffc0202eb8:	01547433          	and	s0,s0,s5
ffffffffc0202ebc:	b75d                	j	ffffffffc0202e62 <unmap_range+0x58>
ffffffffc0202ebe:	10002773          	csrr	a4,sstatus
ffffffffc0202ec2:	8b09                	andi	a4,a4,2
ffffffffc0202ec4:	eb19                	bnez	a4,ffffffffc0202eda <unmap_range+0xd0>
ffffffffc0202ec6:	00094717          	auipc	a4,0x94
ffffffffc0202eca:	9ca73703          	ld	a4,-1590(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc0202ece:	4585                	li	a1,1
ffffffffc0202ed0:	e03e                	sd	a5,0(sp)
ffffffffc0202ed2:	7318                	ld	a4,32(a4)
ffffffffc0202ed4:	9702                	jalr	a4
ffffffffc0202ed6:	6782                	ld	a5,0(sp)
ffffffffc0202ed8:	bfc9                	j	ffffffffc0202eaa <unmap_range+0xa0>
ffffffffc0202eda:	e43e                	sd	a5,8(sp)
ffffffffc0202edc:	e02a                	sd	a0,0(sp)
ffffffffc0202ede:	e25fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0202ee2:	00094717          	auipc	a4,0x94
ffffffffc0202ee6:	9ae73703          	ld	a4,-1618(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc0202eea:	6502                	ld	a0,0(sp)
ffffffffc0202eec:	4585                	li	a1,1
ffffffffc0202eee:	7318                	ld	a4,32(a4)
ffffffffc0202ef0:	9702                	jalr	a4
ffffffffc0202ef2:	e0bfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0202ef6:	67a2                	ld	a5,8(sp)
ffffffffc0202ef8:	bf4d                	j	ffffffffc0202eaa <unmap_range+0xa0>
ffffffffc0202efa:	0000a697          	auipc	a3,0xa
ffffffffc0202efe:	c3668693          	addi	a3,a3,-970 # ffffffffc020cb30 <etext+0x125a>
ffffffffc0202f02:	00009617          	auipc	a2,0x9
ffffffffc0202f06:	e8e60613          	addi	a2,a2,-370 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202f0a:	15a00593          	li	a1,346
ffffffffc0202f0e:	0000a517          	auipc	a0,0xa
ffffffffc0202f12:	bea50513          	addi	a0,a0,-1046 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202f16:	b16fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202f1a:	0000a697          	auipc	a3,0xa
ffffffffc0202f1e:	c4668693          	addi	a3,a3,-954 # ffffffffc020cb60 <etext+0x128a>
ffffffffc0202f22:	00009617          	auipc	a2,0x9
ffffffffc0202f26:	e6e60613          	addi	a2,a2,-402 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0202f2a:	15b00593          	li	a1,347
ffffffffc0202f2e:	0000a517          	auipc	a0,0xa
ffffffffc0202f32:	bca50513          	addi	a0,a0,-1078 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0202f36:	af6fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0202f3a:	a93ff0ef          	jal	ffffffffc02029cc <pa2page.part.0>

ffffffffc0202f3e <exit_range>:
ffffffffc0202f3e:	7135                	addi	sp,sp,-160
ffffffffc0202f40:	00c5e7b3          	or	a5,a1,a2
ffffffffc0202f44:	ed06                	sd	ra,152(sp)
ffffffffc0202f46:	e922                	sd	s0,144(sp)
ffffffffc0202f48:	e526                	sd	s1,136(sp)
ffffffffc0202f4a:	e14a                	sd	s2,128(sp)
ffffffffc0202f4c:	fcce                	sd	s3,120(sp)
ffffffffc0202f4e:	f8d2                	sd	s4,112(sp)
ffffffffc0202f50:	f4d6                	sd	s5,104(sp)
ffffffffc0202f52:	f0da                	sd	s6,96(sp)
ffffffffc0202f54:	ecde                	sd	s7,88(sp)
ffffffffc0202f56:	17d2                	slli	a5,a5,0x34
ffffffffc0202f58:	22079263          	bnez	a5,ffffffffc020317c <exit_range+0x23e>
ffffffffc0202f5c:	00200937          	lui	s2,0x200
ffffffffc0202f60:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202f64:	0125b733          	sltu	a4,a1,s2
ffffffffc0202f68:	0017b793          	seqz	a5,a5
ffffffffc0202f6c:	8fd9                	or	a5,a5,a4
ffffffffc0202f6e:	26079263          	bnez	a5,ffffffffc02031d2 <exit_range+0x294>
ffffffffc0202f72:	4785                	li	a5,1
ffffffffc0202f74:	07fe                	slli	a5,a5,0x1f
ffffffffc0202f76:	0785                	addi	a5,a5,1
ffffffffc0202f78:	24f67d63          	bgeu	a2,a5,ffffffffc02031d2 <exit_range+0x294>
ffffffffc0202f7c:	c00004b7          	lui	s1,0xc0000
ffffffffc0202f80:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202f84:	8a2a                	mv	s4,a0
ffffffffc0202f86:	8ced                	and	s1,s1,a1
ffffffffc0202f88:	00f5f833          	and	a6,a1,a5
ffffffffc0202f8c:	00094a97          	auipc	s5,0x94
ffffffffc0202f90:	924a8a93          	addi	s5,s5,-1756 # ffffffffc02968b0 <npage>
ffffffffc0202f94:	400009b7          	lui	s3,0x40000
ffffffffc0202f98:	a809                	j	ffffffffc0202faa <exit_range+0x6c>
ffffffffc0202f9a:	013487b3          	add	a5,s1,s3
ffffffffc0202f9e:	400004b7          	lui	s1,0x40000
ffffffffc0202fa2:	8826                	mv	a6,s1
ffffffffc0202fa4:	c3f1                	beqz	a5,ffffffffc0203068 <exit_range+0x12a>
ffffffffc0202fa6:	0cc7f163          	bgeu	a5,a2,ffffffffc0203068 <exit_range+0x12a>
ffffffffc0202faa:	01e4d413          	srli	s0,s1,0x1e
ffffffffc0202fae:	1ff47413          	andi	s0,s0,511
ffffffffc0202fb2:	040e                	slli	s0,s0,0x3
ffffffffc0202fb4:	9452                	add	s0,s0,s4
ffffffffc0202fb6:	00043883          	ld	a7,0(s0)
ffffffffc0202fba:	0018f793          	andi	a5,a7,1
ffffffffc0202fbe:	dff1                	beqz	a5,ffffffffc0202f9a <exit_range+0x5c>
ffffffffc0202fc0:	000ab783          	ld	a5,0(s5)
ffffffffc0202fc4:	088a                	slli	a7,a7,0x2
ffffffffc0202fc6:	00c8d893          	srli	a7,a7,0xc
ffffffffc0202fca:	20f8f263          	bgeu	a7,a5,ffffffffc02031ce <exit_range+0x290>
ffffffffc0202fce:	fff802b7          	lui	t0,0xfff80
ffffffffc0202fd2:	00588f33          	add	t5,a7,t0
ffffffffc0202fd6:	000803b7          	lui	t2,0x80
ffffffffc0202fda:	007f0733          	add	a4,t5,t2
ffffffffc0202fde:	00c71e13          	slli	t3,a4,0xc
ffffffffc0202fe2:	0f1a                	slli	t5,t5,0x6
ffffffffc0202fe4:	1cf77863          	bgeu	a4,a5,ffffffffc02031b4 <exit_range+0x276>
ffffffffc0202fe8:	00094f97          	auipc	t6,0x94
ffffffffc0202fec:	8c0f8f93          	addi	t6,t6,-1856 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202ff0:	000fb783          	ld	a5,0(t6)
ffffffffc0202ff4:	4e85                	li	t4,1
ffffffffc0202ff6:	6b05                	lui	s6,0x1
ffffffffc0202ff8:	9e3e                	add	t3,t3,a5
ffffffffc0202ffa:	01348333          	add	t1,s1,s3
ffffffffc0202ffe:	01585713          	srli	a4,a6,0x15
ffffffffc0203002:	1ff77713          	andi	a4,a4,511
ffffffffc0203006:	070e                	slli	a4,a4,0x3
ffffffffc0203008:	9772                	add	a4,a4,t3
ffffffffc020300a:	631c                	ld	a5,0(a4)
ffffffffc020300c:	0017f693          	andi	a3,a5,1
ffffffffc0203010:	e6bd                	bnez	a3,ffffffffc020307e <exit_range+0x140>
ffffffffc0203012:	4e81                	li	t4,0
ffffffffc0203014:	984a                	add	a6,a6,s2
ffffffffc0203016:	00080863          	beqz	a6,ffffffffc0203026 <exit_range+0xe8>
ffffffffc020301a:	879a                	mv	a5,t1
ffffffffc020301c:	00667363          	bgeu	a2,t1,ffffffffc0203022 <exit_range+0xe4>
ffffffffc0203020:	87b2                	mv	a5,a2
ffffffffc0203022:	fcf86ee3          	bltu	a6,a5,ffffffffc0202ffe <exit_range+0xc0>
ffffffffc0203026:	f60e8ae3          	beqz	t4,ffffffffc0202f9a <exit_range+0x5c>
ffffffffc020302a:	000ab783          	ld	a5,0(s5)
ffffffffc020302e:	1af8f063          	bgeu	a7,a5,ffffffffc02031ce <exit_range+0x290>
ffffffffc0203032:	00094517          	auipc	a0,0x94
ffffffffc0203036:	88653503          	ld	a0,-1914(a0) # ffffffffc02968b8 <pages>
ffffffffc020303a:	957a                	add	a0,a0,t5
ffffffffc020303c:	100027f3          	csrr	a5,sstatus
ffffffffc0203040:	8b89                	andi	a5,a5,2
ffffffffc0203042:	10079b63          	bnez	a5,ffffffffc0203158 <exit_range+0x21a>
ffffffffc0203046:	00094797          	auipc	a5,0x94
ffffffffc020304a:	84a7b783          	ld	a5,-1974(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc020304e:	4585                	li	a1,1
ffffffffc0203050:	e432                	sd	a2,8(sp)
ffffffffc0203052:	739c                	ld	a5,32(a5)
ffffffffc0203054:	9782                	jalr	a5
ffffffffc0203056:	6622                	ld	a2,8(sp)
ffffffffc0203058:	00043023          	sd	zero,0(s0)
ffffffffc020305c:	013487b3          	add	a5,s1,s3
ffffffffc0203060:	400004b7          	lui	s1,0x40000
ffffffffc0203064:	8826                	mv	a6,s1
ffffffffc0203066:	f3a1                	bnez	a5,ffffffffc0202fa6 <exit_range+0x68>
ffffffffc0203068:	60ea                	ld	ra,152(sp)
ffffffffc020306a:	644a                	ld	s0,144(sp)
ffffffffc020306c:	64aa                	ld	s1,136(sp)
ffffffffc020306e:	690a                	ld	s2,128(sp)
ffffffffc0203070:	79e6                	ld	s3,120(sp)
ffffffffc0203072:	7a46                	ld	s4,112(sp)
ffffffffc0203074:	7aa6                	ld	s5,104(sp)
ffffffffc0203076:	7b06                	ld	s6,96(sp)
ffffffffc0203078:	6be6                	ld	s7,88(sp)
ffffffffc020307a:	610d                	addi	sp,sp,160
ffffffffc020307c:	8082                	ret
ffffffffc020307e:	000ab503          	ld	a0,0(s5)
ffffffffc0203082:	078a                	slli	a5,a5,0x2
ffffffffc0203084:	83b1                	srli	a5,a5,0xc
ffffffffc0203086:	14a7f463          	bgeu	a5,a0,ffffffffc02031ce <exit_range+0x290>
ffffffffc020308a:	9796                	add	a5,a5,t0
ffffffffc020308c:	00778bb3          	add	s7,a5,t2
ffffffffc0203090:	00679593          	slli	a1,a5,0x6
ffffffffc0203094:	00cb9693          	slli	a3,s7,0xc
ffffffffc0203098:	10abf263          	bgeu	s7,a0,ffffffffc020319c <exit_range+0x25e>
ffffffffc020309c:	000fb783          	ld	a5,0(t6)
ffffffffc02030a0:	96be                	add	a3,a3,a5
ffffffffc02030a2:	01668533          	add	a0,a3,s6
ffffffffc02030a6:	629c                	ld	a5,0(a3)
ffffffffc02030a8:	8b85                	andi	a5,a5,1
ffffffffc02030aa:	f7ad                	bnez	a5,ffffffffc0203014 <exit_range+0xd6>
ffffffffc02030ac:	06a1                	addi	a3,a3,8
ffffffffc02030ae:	fea69ce3          	bne	a3,a0,ffffffffc02030a6 <exit_range+0x168>
ffffffffc02030b2:	00094517          	auipc	a0,0x94
ffffffffc02030b6:	80653503          	ld	a0,-2042(a0) # ffffffffc02968b8 <pages>
ffffffffc02030ba:	952e                	add	a0,a0,a1
ffffffffc02030bc:	100027f3          	csrr	a5,sstatus
ffffffffc02030c0:	8b89                	andi	a5,a5,2
ffffffffc02030c2:	e3b9                	bnez	a5,ffffffffc0203108 <exit_range+0x1ca>
ffffffffc02030c4:	00093797          	auipc	a5,0x93
ffffffffc02030c8:	7cc7b783          	ld	a5,1996(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02030cc:	4585                	li	a1,1
ffffffffc02030ce:	e0b2                	sd	a2,64(sp)
ffffffffc02030d0:	739c                	ld	a5,32(a5)
ffffffffc02030d2:	fc1a                	sd	t1,56(sp)
ffffffffc02030d4:	f846                	sd	a7,48(sp)
ffffffffc02030d6:	f47a                	sd	t5,40(sp)
ffffffffc02030d8:	f072                	sd	t3,32(sp)
ffffffffc02030da:	ec76                	sd	t4,24(sp)
ffffffffc02030dc:	e842                	sd	a6,16(sp)
ffffffffc02030de:	e43a                	sd	a4,8(sp)
ffffffffc02030e0:	9782                	jalr	a5
ffffffffc02030e2:	6722                	ld	a4,8(sp)
ffffffffc02030e4:	6842                	ld	a6,16(sp)
ffffffffc02030e6:	6ee2                	ld	t4,24(sp)
ffffffffc02030e8:	7e02                	ld	t3,32(sp)
ffffffffc02030ea:	7f22                	ld	t5,40(sp)
ffffffffc02030ec:	78c2                	ld	a7,48(sp)
ffffffffc02030ee:	7362                	ld	t1,56(sp)
ffffffffc02030f0:	6606                	ld	a2,64(sp)
ffffffffc02030f2:	fff802b7          	lui	t0,0xfff80
ffffffffc02030f6:	000803b7          	lui	t2,0x80
ffffffffc02030fa:	00093f97          	auipc	t6,0x93
ffffffffc02030fe:	7aef8f93          	addi	t6,t6,1966 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0203102:	00073023          	sd	zero,0(a4)
ffffffffc0203106:	b739                	j	ffffffffc0203014 <exit_range+0xd6>
ffffffffc0203108:	e4b2                	sd	a2,72(sp)
ffffffffc020310a:	e09a                	sd	t1,64(sp)
ffffffffc020310c:	fc46                	sd	a7,56(sp)
ffffffffc020310e:	f47a                	sd	t5,40(sp)
ffffffffc0203110:	f072                	sd	t3,32(sp)
ffffffffc0203112:	ec76                	sd	t4,24(sp)
ffffffffc0203114:	e842                	sd	a6,16(sp)
ffffffffc0203116:	e43a                	sd	a4,8(sp)
ffffffffc0203118:	f82a                	sd	a0,48(sp)
ffffffffc020311a:	be9fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc020311e:	00093797          	auipc	a5,0x93
ffffffffc0203122:	7727b783          	ld	a5,1906(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0203126:	7542                	ld	a0,48(sp)
ffffffffc0203128:	4585                	li	a1,1
ffffffffc020312a:	739c                	ld	a5,32(a5)
ffffffffc020312c:	9782                	jalr	a5
ffffffffc020312e:	bcffd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203132:	6722                	ld	a4,8(sp)
ffffffffc0203134:	6626                	ld	a2,72(sp)
ffffffffc0203136:	6306                	ld	t1,64(sp)
ffffffffc0203138:	78e2                	ld	a7,56(sp)
ffffffffc020313a:	7f22                	ld	t5,40(sp)
ffffffffc020313c:	7e02                	ld	t3,32(sp)
ffffffffc020313e:	6ee2                	ld	t4,24(sp)
ffffffffc0203140:	6842                	ld	a6,16(sp)
ffffffffc0203142:	00093f97          	auipc	t6,0x93
ffffffffc0203146:	766f8f93          	addi	t6,t6,1894 # ffffffffc02968a8 <va_pa_offset>
ffffffffc020314a:	000803b7          	lui	t2,0x80
ffffffffc020314e:	fff802b7          	lui	t0,0xfff80
ffffffffc0203152:	00073023          	sd	zero,0(a4)
ffffffffc0203156:	bd7d                	j	ffffffffc0203014 <exit_range+0xd6>
ffffffffc0203158:	e832                	sd	a2,16(sp)
ffffffffc020315a:	e42a                	sd	a0,8(sp)
ffffffffc020315c:	ba7fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203160:	00093797          	auipc	a5,0x93
ffffffffc0203164:	7307b783          	ld	a5,1840(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0203168:	6522                	ld	a0,8(sp)
ffffffffc020316a:	4585                	li	a1,1
ffffffffc020316c:	739c                	ld	a5,32(a5)
ffffffffc020316e:	9782                	jalr	a5
ffffffffc0203170:	b8dfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203174:	6642                	ld	a2,16(sp)
ffffffffc0203176:	00043023          	sd	zero,0(s0)
ffffffffc020317a:	b5cd                	j	ffffffffc020305c <exit_range+0x11e>
ffffffffc020317c:	0000a697          	auipc	a3,0xa
ffffffffc0203180:	9b468693          	addi	a3,a3,-1612 # ffffffffc020cb30 <etext+0x125a>
ffffffffc0203184:	00009617          	auipc	a2,0x9
ffffffffc0203188:	c0c60613          	addi	a2,a2,-1012 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020318c:	16f00593          	li	a1,367
ffffffffc0203190:	0000a517          	auipc	a0,0xa
ffffffffc0203194:	96850513          	addi	a0,a0,-1688 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203198:	894fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020319c:	00009617          	auipc	a2,0x9
ffffffffc02031a0:	4c460613          	addi	a2,a2,1220 # ffffffffc020c660 <etext+0xd8a>
ffffffffc02031a4:	07100593          	li	a1,113
ffffffffc02031a8:	00009517          	auipc	a0,0x9
ffffffffc02031ac:	4e050513          	addi	a0,a0,1248 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02031b0:	87cfd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02031b4:	86f2                	mv	a3,t3
ffffffffc02031b6:	00009617          	auipc	a2,0x9
ffffffffc02031ba:	4aa60613          	addi	a2,a2,1194 # ffffffffc020c660 <etext+0xd8a>
ffffffffc02031be:	07100593          	li	a1,113
ffffffffc02031c2:	00009517          	auipc	a0,0x9
ffffffffc02031c6:	4c650513          	addi	a0,a0,1222 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02031ca:	862fd0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02031ce:	ffeff0ef          	jal	ffffffffc02029cc <pa2page.part.0>
ffffffffc02031d2:	0000a697          	auipc	a3,0xa
ffffffffc02031d6:	98e68693          	addi	a3,a3,-1650 # ffffffffc020cb60 <etext+0x128a>
ffffffffc02031da:	00009617          	auipc	a2,0x9
ffffffffc02031de:	bb660613          	addi	a2,a2,-1098 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02031e2:	17000593          	li	a1,368
ffffffffc02031e6:	0000a517          	auipc	a0,0xa
ffffffffc02031ea:	91250513          	addi	a0,a0,-1774 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02031ee:	83efd0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02031f2 <page_remove>:
ffffffffc02031f2:	1101                	addi	sp,sp,-32
ffffffffc02031f4:	4601                	li	a2,0
ffffffffc02031f6:	e822                	sd	s0,16(sp)
ffffffffc02031f8:	ec06                	sd	ra,24(sp)
ffffffffc02031fa:	842e                	mv	s0,a1
ffffffffc02031fc:	895ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc0203200:	c511                	beqz	a0,ffffffffc020320c <page_remove+0x1a>
ffffffffc0203202:	6118                	ld	a4,0(a0)
ffffffffc0203204:	87aa                	mv	a5,a0
ffffffffc0203206:	00177693          	andi	a3,a4,1
ffffffffc020320a:	e689                	bnez	a3,ffffffffc0203214 <page_remove+0x22>
ffffffffc020320c:	60e2                	ld	ra,24(sp)
ffffffffc020320e:	6442                	ld	s0,16(sp)
ffffffffc0203210:	6105                	addi	sp,sp,32
ffffffffc0203212:	8082                	ret
ffffffffc0203214:	00093697          	auipc	a3,0x93
ffffffffc0203218:	69c6b683          	ld	a3,1692(a3) # ffffffffc02968b0 <npage>
ffffffffc020321c:	070a                	slli	a4,a4,0x2
ffffffffc020321e:	8331                	srli	a4,a4,0xc
ffffffffc0203220:	06d77563          	bgeu	a4,a3,ffffffffc020328a <page_remove+0x98>
ffffffffc0203224:	00093517          	auipc	a0,0x93
ffffffffc0203228:	69453503          	ld	a0,1684(a0) # ffffffffc02968b8 <pages>
ffffffffc020322c:	071a                	slli	a4,a4,0x6
ffffffffc020322e:	fe0006b7          	lui	a3,0xfe000
ffffffffc0203232:	9736                	add	a4,a4,a3
ffffffffc0203234:	953a                	add	a0,a0,a4
ffffffffc0203236:	4118                	lw	a4,0(a0)
ffffffffc0203238:	377d                	addiw	a4,a4,-1
ffffffffc020323a:	c118                	sw	a4,0(a0)
ffffffffc020323c:	cb09                	beqz	a4,ffffffffc020324e <page_remove+0x5c>
ffffffffc020323e:	0007b023          	sd	zero,0(a5)
ffffffffc0203242:	12040073          	sfence.vma	s0
ffffffffc0203246:	60e2                	ld	ra,24(sp)
ffffffffc0203248:	6442                	ld	s0,16(sp)
ffffffffc020324a:	6105                	addi	sp,sp,32
ffffffffc020324c:	8082                	ret
ffffffffc020324e:	10002773          	csrr	a4,sstatus
ffffffffc0203252:	8b09                	andi	a4,a4,2
ffffffffc0203254:	eb19                	bnez	a4,ffffffffc020326a <page_remove+0x78>
ffffffffc0203256:	00093717          	auipc	a4,0x93
ffffffffc020325a:	63a73703          	ld	a4,1594(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc020325e:	4585                	li	a1,1
ffffffffc0203260:	e03e                	sd	a5,0(sp)
ffffffffc0203262:	7318                	ld	a4,32(a4)
ffffffffc0203264:	9702                	jalr	a4
ffffffffc0203266:	6782                	ld	a5,0(sp)
ffffffffc0203268:	bfd9                	j	ffffffffc020323e <page_remove+0x4c>
ffffffffc020326a:	e43e                	sd	a5,8(sp)
ffffffffc020326c:	e02a                	sd	a0,0(sp)
ffffffffc020326e:	a95fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203272:	00093717          	auipc	a4,0x93
ffffffffc0203276:	61e73703          	ld	a4,1566(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc020327a:	6502                	ld	a0,0(sp)
ffffffffc020327c:	4585                	li	a1,1
ffffffffc020327e:	7318                	ld	a4,32(a4)
ffffffffc0203280:	9702                	jalr	a4
ffffffffc0203282:	a7bfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203286:	67a2                	ld	a5,8(sp)
ffffffffc0203288:	bf5d                	j	ffffffffc020323e <page_remove+0x4c>
ffffffffc020328a:	f42ff0ef          	jal	ffffffffc02029cc <pa2page.part.0>

ffffffffc020328e <page_insert>:
ffffffffc020328e:	7139                	addi	sp,sp,-64
ffffffffc0203290:	f426                	sd	s1,40(sp)
ffffffffc0203292:	84b2                	mv	s1,a2
ffffffffc0203294:	f822                	sd	s0,48(sp)
ffffffffc0203296:	4605                	li	a2,1
ffffffffc0203298:	842e                	mv	s0,a1
ffffffffc020329a:	85a6                	mv	a1,s1
ffffffffc020329c:	fc06                	sd	ra,56(sp)
ffffffffc020329e:	e436                	sd	a3,8(sp)
ffffffffc02032a0:	ff0ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc02032a4:	cd61                	beqz	a0,ffffffffc020337c <page_insert+0xee>
ffffffffc02032a6:	400c                	lw	a1,0(s0)
ffffffffc02032a8:	611c                	ld	a5,0(a0)
ffffffffc02032aa:	66a2                	ld	a3,8(sp)
ffffffffc02032ac:	0015861b          	addiw	a2,a1,1
ffffffffc02032b0:	c010                	sw	a2,0(s0)
ffffffffc02032b2:	0017f613          	andi	a2,a5,1
ffffffffc02032b6:	872a                	mv	a4,a0
ffffffffc02032b8:	e61d                	bnez	a2,ffffffffc02032e6 <page_insert+0x58>
ffffffffc02032ba:	00093617          	auipc	a2,0x93
ffffffffc02032be:	5fe63603          	ld	a2,1534(a2) # ffffffffc02968b8 <pages>
ffffffffc02032c2:	8c11                	sub	s0,s0,a2
ffffffffc02032c4:	8419                	srai	s0,s0,0x6
ffffffffc02032c6:	200007b7          	lui	a5,0x20000
ffffffffc02032ca:	042a                	slli	s0,s0,0xa
ffffffffc02032cc:	943e                	add	s0,s0,a5
ffffffffc02032ce:	8ec1                	or	a3,a3,s0
ffffffffc02032d0:	0016e693          	ori	a3,a3,1
ffffffffc02032d4:	e314                	sd	a3,0(a4)
ffffffffc02032d6:	12048073          	sfence.vma	s1
ffffffffc02032da:	4501                	li	a0,0
ffffffffc02032dc:	70e2                	ld	ra,56(sp)
ffffffffc02032de:	7442                	ld	s0,48(sp)
ffffffffc02032e0:	74a2                	ld	s1,40(sp)
ffffffffc02032e2:	6121                	addi	sp,sp,64
ffffffffc02032e4:	8082                	ret
ffffffffc02032e6:	00093617          	auipc	a2,0x93
ffffffffc02032ea:	5ca63603          	ld	a2,1482(a2) # ffffffffc02968b0 <npage>
ffffffffc02032ee:	078a                	slli	a5,a5,0x2
ffffffffc02032f0:	83b1                	srli	a5,a5,0xc
ffffffffc02032f2:	08c7f763          	bgeu	a5,a2,ffffffffc0203380 <page_insert+0xf2>
ffffffffc02032f6:	00093617          	auipc	a2,0x93
ffffffffc02032fa:	5c263603          	ld	a2,1474(a2) # ffffffffc02968b8 <pages>
ffffffffc02032fe:	fe000537          	lui	a0,0xfe000
ffffffffc0203302:	079a                	slli	a5,a5,0x6
ffffffffc0203304:	97aa                	add	a5,a5,a0
ffffffffc0203306:	00f60533          	add	a0,a2,a5
ffffffffc020330a:	00a40963          	beq	s0,a0,ffffffffc020331c <page_insert+0x8e>
ffffffffc020330e:	411c                	lw	a5,0(a0)
ffffffffc0203310:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_bin_sfs_img_size+0x1ff8acff>
ffffffffc0203312:	c11c                	sw	a5,0(a0)
ffffffffc0203314:	c791                	beqz	a5,ffffffffc0203320 <page_insert+0x92>
ffffffffc0203316:	12048073          	sfence.vma	s1
ffffffffc020331a:	b765                	j	ffffffffc02032c2 <page_insert+0x34>
ffffffffc020331c:	c00c                	sw	a1,0(s0)
ffffffffc020331e:	b755                	j	ffffffffc02032c2 <page_insert+0x34>
ffffffffc0203320:	100027f3          	csrr	a5,sstatus
ffffffffc0203324:	8b89                	andi	a5,a5,2
ffffffffc0203326:	e39d                	bnez	a5,ffffffffc020334c <page_insert+0xbe>
ffffffffc0203328:	00093797          	auipc	a5,0x93
ffffffffc020332c:	5687b783          	ld	a5,1384(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0203330:	4585                	li	a1,1
ffffffffc0203332:	e83a                	sd	a4,16(sp)
ffffffffc0203334:	739c                	ld	a5,32(a5)
ffffffffc0203336:	e436                	sd	a3,8(sp)
ffffffffc0203338:	9782                	jalr	a5
ffffffffc020333a:	00093617          	auipc	a2,0x93
ffffffffc020333e:	57e63603          	ld	a2,1406(a2) # ffffffffc02968b8 <pages>
ffffffffc0203342:	66a2                	ld	a3,8(sp)
ffffffffc0203344:	6742                	ld	a4,16(sp)
ffffffffc0203346:	12048073          	sfence.vma	s1
ffffffffc020334a:	bfa5                	j	ffffffffc02032c2 <page_insert+0x34>
ffffffffc020334c:	ec3a                	sd	a4,24(sp)
ffffffffc020334e:	e836                	sd	a3,16(sp)
ffffffffc0203350:	e42a                	sd	a0,8(sp)
ffffffffc0203352:	9b1fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203356:	00093797          	auipc	a5,0x93
ffffffffc020335a:	53a7b783          	ld	a5,1338(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc020335e:	6522                	ld	a0,8(sp)
ffffffffc0203360:	4585                	li	a1,1
ffffffffc0203362:	739c                	ld	a5,32(a5)
ffffffffc0203364:	9782                	jalr	a5
ffffffffc0203366:	997fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020336a:	00093617          	auipc	a2,0x93
ffffffffc020336e:	54e63603          	ld	a2,1358(a2) # ffffffffc02968b8 <pages>
ffffffffc0203372:	6762                	ld	a4,24(sp)
ffffffffc0203374:	66c2                	ld	a3,16(sp)
ffffffffc0203376:	12048073          	sfence.vma	s1
ffffffffc020337a:	b7a1                	j	ffffffffc02032c2 <page_insert+0x34>
ffffffffc020337c:	5571                	li	a0,-4
ffffffffc020337e:	bfb9                	j	ffffffffc02032dc <page_insert+0x4e>
ffffffffc0203380:	e4cff0ef          	jal	ffffffffc02029cc <pa2page.part.0>

ffffffffc0203384 <pmm_init>:
ffffffffc0203384:	0000c797          	auipc	a5,0xc
ffffffffc0203388:	c2478793          	addi	a5,a5,-988 # ffffffffc020efa8 <default_pmm_manager>
ffffffffc020338c:	638c                	ld	a1,0(a5)
ffffffffc020338e:	7159                	addi	sp,sp,-112
ffffffffc0203390:	f486                	sd	ra,104(sp)
ffffffffc0203392:	e8ca                	sd	s2,80(sp)
ffffffffc0203394:	e4ce                	sd	s3,72(sp)
ffffffffc0203396:	f85a                	sd	s6,48(sp)
ffffffffc0203398:	f0a2                	sd	s0,96(sp)
ffffffffc020339a:	eca6                	sd	s1,88(sp)
ffffffffc020339c:	e0d2                	sd	s4,64(sp)
ffffffffc020339e:	fc56                	sd	s5,56(sp)
ffffffffc02033a0:	f45e                	sd	s7,40(sp)
ffffffffc02033a2:	f062                	sd	s8,32(sp)
ffffffffc02033a4:	ec66                	sd	s9,24(sp)
ffffffffc02033a6:	00093b17          	auipc	s6,0x93
ffffffffc02033aa:	4eab0b13          	addi	s6,s6,1258 # ffffffffc0296890 <pmm_manager>
ffffffffc02033ae:	00009517          	auipc	a0,0x9
ffffffffc02033b2:	7ca50513          	addi	a0,a0,1994 # ffffffffc020cb78 <etext+0x12a2>
ffffffffc02033b6:	00fb3023          	sd	a5,0(s6)
ffffffffc02033ba:	d6ffc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02033be:	000b3783          	ld	a5,0(s6)
ffffffffc02033c2:	00093997          	auipc	s3,0x93
ffffffffc02033c6:	4e698993          	addi	s3,s3,1254 # ffffffffc02968a8 <va_pa_offset>
ffffffffc02033ca:	679c                	ld	a5,8(a5)
ffffffffc02033cc:	9782                	jalr	a5
ffffffffc02033ce:	57f5                	li	a5,-3
ffffffffc02033d0:	07fa                	slli	a5,a5,0x1e
ffffffffc02033d2:	00f9b023          	sd	a5,0(s3)
ffffffffc02033d6:	c56fd0ef          	jal	ffffffffc020082c <get_memory_base>
ffffffffc02033da:	892a                	mv	s2,a0
ffffffffc02033dc:	c5afd0ef          	jal	ffffffffc0200836 <get_memory_size>
ffffffffc02033e0:	460506e3          	beqz	a0,ffffffffc020404c <pmm_init+0xcc8>
ffffffffc02033e4:	84aa                	mv	s1,a0
ffffffffc02033e6:	00009517          	auipc	a0,0x9
ffffffffc02033ea:	7ca50513          	addi	a0,a0,1994 # ffffffffc020cbb0 <etext+0x12da>
ffffffffc02033ee:	d3bfc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02033f2:	00990433          	add	s0,s2,s1
ffffffffc02033f6:	864a                	mv	a2,s2
ffffffffc02033f8:	85a6                	mv	a1,s1
ffffffffc02033fa:	fff40693          	addi	a3,s0,-1
ffffffffc02033fe:	00009517          	auipc	a0,0x9
ffffffffc0203402:	7ca50513          	addi	a0,a0,1994 # ffffffffc020cbc8 <etext+0x12f2>
ffffffffc0203406:	d23fc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020340a:	c80007b7          	lui	a5,0xc8000
ffffffffc020340e:	8522                	mv	a0,s0
ffffffffc0203410:	6887e263          	bltu	a5,s0,ffffffffc0203a94 <pmm_init+0x710>
ffffffffc0203414:	77fd                	lui	a5,0xfffff
ffffffffc0203416:	00094617          	auipc	a2,0x94
ffffffffc020341a:	4f960613          	addi	a2,a2,1273 # ffffffffc029790f <end+0xfff>
ffffffffc020341e:	8e7d                	and	a2,a2,a5
ffffffffc0203420:	8131                	srli	a0,a0,0xc
ffffffffc0203422:	00093b97          	auipc	s7,0x93
ffffffffc0203426:	496b8b93          	addi	s7,s7,1174 # ffffffffc02968b8 <pages>
ffffffffc020342a:	00093497          	auipc	s1,0x93
ffffffffc020342e:	48648493          	addi	s1,s1,1158 # ffffffffc02968b0 <npage>
ffffffffc0203432:	00cbb023          	sd	a2,0(s7)
ffffffffc0203436:	e088                	sd	a0,0(s1)
ffffffffc0203438:	000807b7          	lui	a5,0x80
ffffffffc020343c:	86b2                	mv	a3,a2
ffffffffc020343e:	02f50763          	beq	a0,a5,ffffffffc020346c <pmm_init+0xe8>
ffffffffc0203442:	4701                	li	a4,0
ffffffffc0203444:	4585                	li	a1,1
ffffffffc0203446:	fff806b7          	lui	a3,0xfff80
ffffffffc020344a:	00671793          	slli	a5,a4,0x6
ffffffffc020344e:	97b2                	add	a5,a5,a2
ffffffffc0203450:	07a1                	addi	a5,a5,8 # 80008 <_binary_bin_sfs_img_size+0xad08>
ffffffffc0203452:	40b7b02f          	amoor.d	zero,a1,(a5)
ffffffffc0203456:	6088                	ld	a0,0(s1)
ffffffffc0203458:	0705                	addi	a4,a4,1
ffffffffc020345a:	000bb603          	ld	a2,0(s7)
ffffffffc020345e:	00d507b3          	add	a5,a0,a3
ffffffffc0203462:	fef764e3          	bltu	a4,a5,ffffffffc020344a <pmm_init+0xc6>
ffffffffc0203466:	079a                	slli	a5,a5,0x6
ffffffffc0203468:	00f606b3          	add	a3,a2,a5
ffffffffc020346c:	c02007b7          	lui	a5,0xc0200
ffffffffc0203470:	36f6ede3          	bltu	a3,a5,ffffffffc0203fea <pmm_init+0xc66>
ffffffffc0203474:	0009b583          	ld	a1,0(s3)
ffffffffc0203478:	77fd                	lui	a5,0xfffff
ffffffffc020347a:	8c7d                	and	s0,s0,a5
ffffffffc020347c:	8e8d                	sub	a3,a3,a1
ffffffffc020347e:	6486ed63          	bltu	a3,s0,ffffffffc0203ad8 <pmm_init+0x754>
ffffffffc0203482:	00009517          	auipc	a0,0x9
ffffffffc0203486:	76e50513          	addi	a0,a0,1902 # ffffffffc020cbf0 <etext+0x131a>
ffffffffc020348a:	c9ffc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020348e:	000b3783          	ld	a5,0(s6)
ffffffffc0203492:	7b9c                	ld	a5,48(a5)
ffffffffc0203494:	9782                	jalr	a5
ffffffffc0203496:	00009517          	auipc	a0,0x9
ffffffffc020349a:	77250513          	addi	a0,a0,1906 # ffffffffc020cc08 <etext+0x1332>
ffffffffc020349e:	c8bfc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02034a2:	100027f3          	csrr	a5,sstatus
ffffffffc02034a6:	8b89                	andi	a5,a5,2
ffffffffc02034a8:	60079d63          	bnez	a5,ffffffffc0203ac2 <pmm_init+0x73e>
ffffffffc02034ac:	000b3783          	ld	a5,0(s6)
ffffffffc02034b0:	4505                	li	a0,1
ffffffffc02034b2:	6f9c                	ld	a5,24(a5)
ffffffffc02034b4:	9782                	jalr	a5
ffffffffc02034b6:	842a                	mv	s0,a0
ffffffffc02034b8:	36040ee3          	beqz	s0,ffffffffc0204034 <pmm_init+0xcb0>
ffffffffc02034bc:	000bb703          	ld	a4,0(s7)
ffffffffc02034c0:	000807b7          	lui	a5,0x80
ffffffffc02034c4:	5a7d                	li	s4,-1
ffffffffc02034c6:	40e406b3          	sub	a3,s0,a4
ffffffffc02034ca:	8699                	srai	a3,a3,0x6
ffffffffc02034cc:	6098                	ld	a4,0(s1)
ffffffffc02034ce:	96be                	add	a3,a3,a5
ffffffffc02034d0:	00ca5793          	srli	a5,s4,0xc
ffffffffc02034d4:	8ff5                	and	a5,a5,a3
ffffffffc02034d6:	06b2                	slli	a3,a3,0xc
ffffffffc02034d8:	32e7f5e3          	bgeu	a5,a4,ffffffffc0204002 <pmm_init+0xc7e>
ffffffffc02034dc:	0009b783          	ld	a5,0(s3)
ffffffffc02034e0:	6605                	lui	a2,0x1
ffffffffc02034e2:	4581                	li	a1,0
ffffffffc02034e4:	00f68433          	add	s0,a3,a5
ffffffffc02034e8:	8522                	mv	a0,s0
ffffffffc02034ea:	6fd070ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc02034ee:	0009b683          	ld	a3,0(s3)
ffffffffc02034f2:	00009917          	auipc	s2,0x9
ffffffffc02034f6:	3e390913          	addi	s2,s2,995 # ffffffffc020c8d5 <etext+0xfff>
ffffffffc02034fa:	77fd                	lui	a5,0xfffff
ffffffffc02034fc:	c0200ab7          	lui	s5,0xc0200
ffffffffc0203500:	00f97933          	and	s2,s2,a5
ffffffffc0203504:	3fe00637          	lui	a2,0x3fe00
ffffffffc0203508:	40da86b3          	sub	a3,s5,a3
ffffffffc020350c:	8522                	mv	a0,s0
ffffffffc020350e:	964a                	add	a2,a2,s2
ffffffffc0203510:	85d6                	mv	a1,s5
ffffffffc0203512:	4729                	li	a4,10
ffffffffc0203514:	fdaff0ef          	jal	ffffffffc0202cee <boot_map_segment>
ffffffffc0203518:	435962e3          	bltu	s2,s5,ffffffffc020413c <pmm_init+0xdb8>
ffffffffc020351c:	0009b683          	ld	a3,0(s3)
ffffffffc0203520:	c8000637          	lui	a2,0xc8000
ffffffffc0203524:	41260633          	sub	a2,a2,s2
ffffffffc0203528:	40d906b3          	sub	a3,s2,a3
ffffffffc020352c:	85ca                	mv	a1,s2
ffffffffc020352e:	4719                	li	a4,6
ffffffffc0203530:	8522                	mv	a0,s0
ffffffffc0203532:	00093917          	auipc	s2,0x93
ffffffffc0203536:	36e90913          	addi	s2,s2,878 # ffffffffc02968a0 <boot_pgdir_va>
ffffffffc020353a:	fb4ff0ef          	jal	ffffffffc0202cee <boot_map_segment>
ffffffffc020353e:	00893023          	sd	s0,0(s2)
ffffffffc0203542:	2d546ce3          	bltu	s0,s5,ffffffffc020401a <pmm_init+0xc96>
ffffffffc0203546:	0009b783          	ld	a5,0(s3)
ffffffffc020354a:	1a7e                	slli	s4,s4,0x3f
ffffffffc020354c:	8c1d                	sub	s0,s0,a5
ffffffffc020354e:	00c45793          	srli	a5,s0,0xc
ffffffffc0203552:	00093717          	auipc	a4,0x93
ffffffffc0203556:	34873323          	sd	s0,838(a4) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc020355a:	0147e7b3          	or	a5,a5,s4
ffffffffc020355e:	18079073          	csrw	satp,a5
ffffffffc0203562:	12000073          	sfence.vma
ffffffffc0203566:	00009517          	auipc	a0,0x9
ffffffffc020356a:	6e250513          	addi	a0,a0,1762 # ffffffffc020cc48 <etext+0x1372>
ffffffffc020356e:	bbbfc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0203572:	0000e717          	auipc	a4,0xe
ffffffffc0203576:	a8e70713          	addi	a4,a4,-1394 # ffffffffc0211000 <bootstack>
ffffffffc020357a:	0000e797          	auipc	a5,0xe
ffffffffc020357e:	a8678793          	addi	a5,a5,-1402 # ffffffffc0211000 <bootstack>
ffffffffc0203582:	48f70163          	beq	a4,a5,ffffffffc0203a04 <pmm_init+0x680>
ffffffffc0203586:	100027f3          	csrr	a5,sstatus
ffffffffc020358a:	8b89                	andi	a5,a5,2
ffffffffc020358c:	52079163          	bnez	a5,ffffffffc0203aae <pmm_init+0x72a>
ffffffffc0203590:	000b3783          	ld	a5,0(s6)
ffffffffc0203594:	779c                	ld	a5,40(a5)
ffffffffc0203596:	9782                	jalr	a5
ffffffffc0203598:	842a                	mv	s0,a0
ffffffffc020359a:	6098                	ld	a4,0(s1)
ffffffffc020359c:	c80007b7          	lui	a5,0xc8000
ffffffffc02035a0:	83b1                	srli	a5,a5,0xc
ffffffffc02035a2:	30e7e1e3          	bltu	a5,a4,ffffffffc02040a4 <pmm_init+0xd20>
ffffffffc02035a6:	00093503          	ld	a0,0(s2)
ffffffffc02035aa:	2c050de3          	beqz	a0,ffffffffc0204084 <pmm_init+0xd00>
ffffffffc02035ae:	03451793          	slli	a5,a0,0x34
ffffffffc02035b2:	2c0799e3          	bnez	a5,ffffffffc0204084 <pmm_init+0xd00>
ffffffffc02035b6:	4601                	li	a2,0
ffffffffc02035b8:	4581                	li	a1,0
ffffffffc02035ba:	ffcff0ef          	jal	ffffffffc0202db6 <get_page>
ffffffffc02035be:	2a0513e3          	bnez	a0,ffffffffc0204064 <pmm_init+0xce0>
ffffffffc02035c2:	100027f3          	csrr	a5,sstatus
ffffffffc02035c6:	8b89                	andi	a5,a5,2
ffffffffc02035c8:	4c079863          	bnez	a5,ffffffffc0203a98 <pmm_init+0x714>
ffffffffc02035cc:	000b3783          	ld	a5,0(s6)
ffffffffc02035d0:	4505                	li	a0,1
ffffffffc02035d2:	6f9c                	ld	a5,24(a5)
ffffffffc02035d4:	9782                	jalr	a5
ffffffffc02035d6:	8a2a                	mv	s4,a0
ffffffffc02035d8:	00093503          	ld	a0,0(s2)
ffffffffc02035dc:	4681                	li	a3,0
ffffffffc02035de:	4601                	li	a2,0
ffffffffc02035e0:	85d2                	mv	a1,s4
ffffffffc02035e2:	cadff0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc02035e6:	32051be3          	bnez	a0,ffffffffc020411c <pmm_init+0xd98>
ffffffffc02035ea:	00093503          	ld	a0,0(s2)
ffffffffc02035ee:	4601                	li	a2,0
ffffffffc02035f0:	4581                	li	a1,0
ffffffffc02035f2:	c9eff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc02035f6:	300503e3          	beqz	a0,ffffffffc02040fc <pmm_init+0xd78>
ffffffffc02035fa:	611c                	ld	a5,0(a0)
ffffffffc02035fc:	0017f713          	andi	a4,a5,1
ffffffffc0203600:	2e0702e3          	beqz	a4,ffffffffc02040e4 <pmm_init+0xd60>
ffffffffc0203604:	6090                	ld	a2,0(s1)
ffffffffc0203606:	078a                	slli	a5,a5,0x2
ffffffffc0203608:	83b1                	srli	a5,a5,0xc
ffffffffc020360a:	62c7fb63          	bgeu	a5,a2,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc020360e:	000bb703          	ld	a4,0(s7)
ffffffffc0203612:	079a                	slli	a5,a5,0x6
ffffffffc0203614:	fe0006b7          	lui	a3,0xfe000
ffffffffc0203618:	97b6                	add	a5,a5,a3
ffffffffc020361a:	97ba                	add	a5,a5,a4
ffffffffc020361c:	64fa1463          	bne	s4,a5,ffffffffc0203c64 <pmm_init+0x8e0>
ffffffffc0203620:	000a2703          	lw	a4,0(s4) # 200000 <_binary_bin_sfs_img_size+0x18ad00>
ffffffffc0203624:	4785                	li	a5,1
ffffffffc0203626:	78f71863          	bne	a4,a5,ffffffffc0203db6 <pmm_init+0xa32>
ffffffffc020362a:	00093503          	ld	a0,0(s2)
ffffffffc020362e:	77fd                	lui	a5,0xfffff
ffffffffc0203630:	6114                	ld	a3,0(a0)
ffffffffc0203632:	068a                	slli	a3,a3,0x2
ffffffffc0203634:	8efd                	and	a3,a3,a5
ffffffffc0203636:	00c6d713          	srli	a4,a3,0xc
ffffffffc020363a:	76c77263          	bgeu	a4,a2,ffffffffc0203d9e <pmm_init+0xa1a>
ffffffffc020363e:	0009bc03          	ld	s8,0(s3)
ffffffffc0203642:	96e2                	add	a3,a3,s8
ffffffffc0203644:	0006ba83          	ld	s5,0(a3) # fffffffffe000000 <end+0x3dd696f0>
ffffffffc0203648:	0a8a                	slli	s5,s5,0x2
ffffffffc020364a:	00fafab3          	and	s5,s5,a5
ffffffffc020364e:	00cad793          	srli	a5,s5,0xc
ffffffffc0203652:	72c7f963          	bgeu	a5,a2,ffffffffc0203d84 <pmm_init+0xa00>
ffffffffc0203656:	4601                	li	a2,0
ffffffffc0203658:	6585                	lui	a1,0x1
ffffffffc020365a:	9c56                	add	s8,s8,s5
ffffffffc020365c:	c34ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc0203660:	0c21                	addi	s8,s8,8
ffffffffc0203662:	6d851163          	bne	a0,s8,ffffffffc0203d24 <pmm_init+0x9a0>
ffffffffc0203666:	100027f3          	csrr	a5,sstatus
ffffffffc020366a:	8b89                	andi	a5,a5,2
ffffffffc020366c:	48079e63          	bnez	a5,ffffffffc0203b08 <pmm_init+0x784>
ffffffffc0203670:	000b3783          	ld	a5,0(s6)
ffffffffc0203674:	4505                	li	a0,1
ffffffffc0203676:	6f9c                	ld	a5,24(a5)
ffffffffc0203678:	9782                	jalr	a5
ffffffffc020367a:	8c2a                	mv	s8,a0
ffffffffc020367c:	00093503          	ld	a0,0(s2)
ffffffffc0203680:	46d1                	li	a3,20
ffffffffc0203682:	6605                	lui	a2,0x1
ffffffffc0203684:	85e2                	mv	a1,s8
ffffffffc0203686:	c09ff0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc020368a:	6c051d63          	bnez	a0,ffffffffc0203d64 <pmm_init+0x9e0>
ffffffffc020368e:	00093503          	ld	a0,0(s2)
ffffffffc0203692:	4601                	li	a2,0
ffffffffc0203694:	6585                	lui	a1,0x1
ffffffffc0203696:	bfaff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc020369a:	6a050563          	beqz	a0,ffffffffc0203d44 <pmm_init+0x9c0>
ffffffffc020369e:	611c                	ld	a5,0(a0)
ffffffffc02036a0:	0107f713          	andi	a4,a5,16
ffffffffc02036a4:	5a070063          	beqz	a4,ffffffffc0203c44 <pmm_init+0x8c0>
ffffffffc02036a8:	8b91                	andi	a5,a5,4
ffffffffc02036aa:	60078d63          	beqz	a5,ffffffffc0203cc4 <pmm_init+0x940>
ffffffffc02036ae:	00093503          	ld	a0,0(s2)
ffffffffc02036b2:	611c                	ld	a5,0(a0)
ffffffffc02036b4:	8bc1                	andi	a5,a5,16
ffffffffc02036b6:	5e078763          	beqz	a5,ffffffffc0203ca4 <pmm_init+0x920>
ffffffffc02036ba:	000c2703          	lw	a4,0(s8)
ffffffffc02036be:	4785                	li	a5,1
ffffffffc02036c0:	64f71263          	bne	a4,a5,ffffffffc0203d04 <pmm_init+0x980>
ffffffffc02036c4:	4681                	li	a3,0
ffffffffc02036c6:	6605                	lui	a2,0x1
ffffffffc02036c8:	85d2                	mv	a1,s4
ffffffffc02036ca:	bc5ff0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc02036ce:	60051b63          	bnez	a0,ffffffffc0203ce4 <pmm_init+0x960>
ffffffffc02036d2:	000a2703          	lw	a4,0(s4)
ffffffffc02036d6:	4789                	li	a5,2
ffffffffc02036d8:	28f71fe3          	bne	a4,a5,ffffffffc0204176 <pmm_init+0xdf2>
ffffffffc02036dc:	000c2783          	lw	a5,0(s8)
ffffffffc02036e0:	26079be3          	bnez	a5,ffffffffc0204156 <pmm_init+0xdd2>
ffffffffc02036e4:	00093503          	ld	a0,0(s2)
ffffffffc02036e8:	4601                	li	a2,0
ffffffffc02036ea:	6585                	lui	a1,0x1
ffffffffc02036ec:	ba4ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc02036f0:	58050a63          	beqz	a0,ffffffffc0203c84 <pmm_init+0x900>
ffffffffc02036f4:	6118                	ld	a4,0(a0)
ffffffffc02036f6:	00177793          	andi	a5,a4,1
ffffffffc02036fa:	1e0785e3          	beqz	a5,ffffffffc02040e4 <pmm_init+0xd60>
ffffffffc02036fe:	6094                	ld	a3,0(s1)
ffffffffc0203700:	00271793          	slli	a5,a4,0x2
ffffffffc0203704:	83b1                	srli	a5,a5,0xc
ffffffffc0203706:	52d7fd63          	bgeu	a5,a3,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc020370a:	000bb683          	ld	a3,0(s7)
ffffffffc020370e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0203712:	97d6                	add	a5,a5,s5
ffffffffc0203714:	079a                	slli	a5,a5,0x6
ffffffffc0203716:	97b6                	add	a5,a5,a3
ffffffffc0203718:	0afa19e3          	bne	s4,a5,ffffffffc0203fca <pmm_init+0xc46>
ffffffffc020371c:	8b41                	andi	a4,a4,16
ffffffffc020371e:	080716e3          	bnez	a4,ffffffffc0203faa <pmm_init+0xc26>
ffffffffc0203722:	00093503          	ld	a0,0(s2)
ffffffffc0203726:	4581                	li	a1,0
ffffffffc0203728:	acbff0ef          	jal	ffffffffc02031f2 <page_remove>
ffffffffc020372c:	000a2c83          	lw	s9,0(s4)
ffffffffc0203730:	4785                	li	a5,1
ffffffffc0203732:	04fc9ce3          	bne	s9,a5,ffffffffc0203f8a <pmm_init+0xc06>
ffffffffc0203736:	000c2783          	lw	a5,0(s8)
ffffffffc020373a:	020798e3          	bnez	a5,ffffffffc0203f6a <pmm_init+0xbe6>
ffffffffc020373e:	00093503          	ld	a0,0(s2)
ffffffffc0203742:	6585                	lui	a1,0x1
ffffffffc0203744:	aafff0ef          	jal	ffffffffc02031f2 <page_remove>
ffffffffc0203748:	000a2783          	lw	a5,0(s4)
ffffffffc020374c:	7e079f63          	bnez	a5,ffffffffc0203f4a <pmm_init+0xbc6>
ffffffffc0203750:	000c2783          	lw	a5,0(s8)
ffffffffc0203754:	7c079b63          	bnez	a5,ffffffffc0203f2a <pmm_init+0xba6>
ffffffffc0203758:	00093a03          	ld	s4,0(s2)
ffffffffc020375c:	6098                	ld	a4,0(s1)
ffffffffc020375e:	000a3783          	ld	a5,0(s4)
ffffffffc0203762:	078a                	slli	a5,a5,0x2
ffffffffc0203764:	83b1                	srli	a5,a5,0xc
ffffffffc0203766:	4ce7fd63          	bgeu	a5,a4,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc020376a:	000bb503          	ld	a0,0(s7)
ffffffffc020376e:	97d6                	add	a5,a5,s5
ffffffffc0203770:	079a                	slli	a5,a5,0x6
ffffffffc0203772:	00f506b3          	add	a3,a0,a5
ffffffffc0203776:	4294                	lw	a3,0(a3)
ffffffffc0203778:	79969963          	bne	a3,s9,ffffffffc0203f0a <pmm_init+0xb86>
ffffffffc020377c:	8799                	srai	a5,a5,0x6
ffffffffc020377e:	00080637          	lui	a2,0x80
ffffffffc0203782:	97b2                	add	a5,a5,a2
ffffffffc0203784:	00c79693          	slli	a3,a5,0xc
ffffffffc0203788:	06e7fde3          	bgeu	a5,a4,ffffffffc0204002 <pmm_init+0xc7e>
ffffffffc020378c:	0009b783          	ld	a5,0(s3)
ffffffffc0203790:	97b6                	add	a5,a5,a3
ffffffffc0203792:	639c                	ld	a5,0(a5)
ffffffffc0203794:	078a                	slli	a5,a5,0x2
ffffffffc0203796:	83b1                	srli	a5,a5,0xc
ffffffffc0203798:	4ae7f463          	bgeu	a5,a4,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc020379c:	8f91                	sub	a5,a5,a2
ffffffffc020379e:	079a                	slli	a5,a5,0x6
ffffffffc02037a0:	953e                	add	a0,a0,a5
ffffffffc02037a2:	100027f3          	csrr	a5,sstatus
ffffffffc02037a6:	8b89                	andi	a5,a5,2
ffffffffc02037a8:	3a079b63          	bnez	a5,ffffffffc0203b5e <pmm_init+0x7da>
ffffffffc02037ac:	000b3783          	ld	a5,0(s6)
ffffffffc02037b0:	4585                	li	a1,1
ffffffffc02037b2:	739c                	ld	a5,32(a5)
ffffffffc02037b4:	9782                	jalr	a5
ffffffffc02037b6:	000a3783          	ld	a5,0(s4)
ffffffffc02037ba:	6098                	ld	a4,0(s1)
ffffffffc02037bc:	078a                	slli	a5,a5,0x2
ffffffffc02037be:	83b1                	srli	a5,a5,0xc
ffffffffc02037c0:	48e7f063          	bgeu	a5,a4,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc02037c4:	000bb503          	ld	a0,0(s7)
ffffffffc02037c8:	fe000737          	lui	a4,0xfe000
ffffffffc02037cc:	079a                	slli	a5,a5,0x6
ffffffffc02037ce:	97ba                	add	a5,a5,a4
ffffffffc02037d0:	953e                	add	a0,a0,a5
ffffffffc02037d2:	100027f3          	csrr	a5,sstatus
ffffffffc02037d6:	8b89                	andi	a5,a5,2
ffffffffc02037d8:	36079763          	bnez	a5,ffffffffc0203b46 <pmm_init+0x7c2>
ffffffffc02037dc:	000b3783          	ld	a5,0(s6)
ffffffffc02037e0:	4585                	li	a1,1
ffffffffc02037e2:	739c                	ld	a5,32(a5)
ffffffffc02037e4:	9782                	jalr	a5
ffffffffc02037e6:	00093783          	ld	a5,0(s2)
ffffffffc02037ea:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc02037ee:	12000073          	sfence.vma
ffffffffc02037f2:	100027f3          	csrr	a5,sstatus
ffffffffc02037f6:	8b89                	andi	a5,a5,2
ffffffffc02037f8:	32079d63          	bnez	a5,ffffffffc0203b32 <pmm_init+0x7ae>
ffffffffc02037fc:	000b3783          	ld	a5,0(s6)
ffffffffc0203800:	779c                	ld	a5,40(a5)
ffffffffc0203802:	9782                	jalr	a5
ffffffffc0203804:	8a2a                	mv	s4,a0
ffffffffc0203806:	6f441263          	bne	s0,s4,ffffffffc0203eea <pmm_init+0xb66>
ffffffffc020380a:	00009517          	auipc	a0,0x9
ffffffffc020380e:	7be50513          	addi	a0,a0,1982 # ffffffffc020cfc8 <etext+0x16f2>
ffffffffc0203812:	917fc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0203816:	100027f3          	csrr	a5,sstatus
ffffffffc020381a:	8b89                	andi	a5,a5,2
ffffffffc020381c:	30079163          	bnez	a5,ffffffffc0203b1e <pmm_init+0x79a>
ffffffffc0203820:	000b3783          	ld	a5,0(s6)
ffffffffc0203824:	779c                	ld	a5,40(a5)
ffffffffc0203826:	9782                	jalr	a5
ffffffffc0203828:	8c2a                	mv	s8,a0
ffffffffc020382a:	609c                	ld	a5,0(s1)
ffffffffc020382c:	c0200437          	lui	s0,0xc0200
ffffffffc0203830:	7a7d                	lui	s4,0xfffff
ffffffffc0203832:	00c79713          	slli	a4,a5,0xc
ffffffffc0203836:	6a85                	lui	s5,0x1
ffffffffc0203838:	02e47c63          	bgeu	s0,a4,ffffffffc0203870 <pmm_init+0x4ec>
ffffffffc020383c:	00c45713          	srli	a4,s0,0xc
ffffffffc0203840:	3af77363          	bgeu	a4,a5,ffffffffc0203be6 <pmm_init+0x862>
ffffffffc0203844:	0009b583          	ld	a1,0(s3)
ffffffffc0203848:	00093503          	ld	a0,0(s2)
ffffffffc020384c:	4601                	li	a2,0
ffffffffc020384e:	95a2                	add	a1,a1,s0
ffffffffc0203850:	a40ff0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc0203854:	3c050663          	beqz	a0,ffffffffc0203c20 <pmm_init+0x89c>
ffffffffc0203858:	611c                	ld	a5,0(a0)
ffffffffc020385a:	078a                	slli	a5,a5,0x2
ffffffffc020385c:	0147f7b3          	and	a5,a5,s4
ffffffffc0203860:	3a879063          	bne	a5,s0,ffffffffc0203c00 <pmm_init+0x87c>
ffffffffc0203864:	609c                	ld	a5,0(s1)
ffffffffc0203866:	9456                	add	s0,s0,s5
ffffffffc0203868:	00c79713          	slli	a4,a5,0xc
ffffffffc020386c:	fce468e3          	bltu	s0,a4,ffffffffc020383c <pmm_init+0x4b8>
ffffffffc0203870:	00093783          	ld	a5,0(s2)
ffffffffc0203874:	639c                	ld	a5,0(a5)
ffffffffc0203876:	5c079a63          	bnez	a5,ffffffffc0203e4a <pmm_init+0xac6>
ffffffffc020387a:	100027f3          	csrr	a5,sstatus
ffffffffc020387e:	8b89                	andi	a5,a5,2
ffffffffc0203880:	30079663          	bnez	a5,ffffffffc0203b8c <pmm_init+0x808>
ffffffffc0203884:	000b3783          	ld	a5,0(s6)
ffffffffc0203888:	4505                	li	a0,1
ffffffffc020388a:	6f9c                	ld	a5,24(a5)
ffffffffc020388c:	9782                	jalr	a5
ffffffffc020388e:	842a                	mv	s0,a0
ffffffffc0203890:	00093503          	ld	a0,0(s2)
ffffffffc0203894:	4699                	li	a3,6
ffffffffc0203896:	10000613          	li	a2,256
ffffffffc020389a:	85a2                	mv	a1,s0
ffffffffc020389c:	9f3ff0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc02038a0:	5e051563          	bnez	a0,ffffffffc0203e8a <pmm_init+0xb06>
ffffffffc02038a4:	4018                	lw	a4,0(s0)
ffffffffc02038a6:	4785                	li	a5,1
ffffffffc02038a8:	62f71163          	bne	a4,a5,ffffffffc0203eca <pmm_init+0xb46>
ffffffffc02038ac:	00093503          	ld	a0,0(s2)
ffffffffc02038b0:	6605                	lui	a2,0x1
ffffffffc02038b2:	10060613          	addi	a2,a2,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc02038b6:	4699                	li	a3,6
ffffffffc02038b8:	85a2                	mv	a1,s0
ffffffffc02038ba:	9d5ff0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc02038be:	5e051663          	bnez	a0,ffffffffc0203eaa <pmm_init+0xb26>
ffffffffc02038c2:	4018                	lw	a4,0(s0)
ffffffffc02038c4:	4789                	li	a5,2
ffffffffc02038c6:	54f71263          	bne	a4,a5,ffffffffc0203e0a <pmm_init+0xa86>
ffffffffc02038ca:	0000a597          	auipc	a1,0xa
ffffffffc02038ce:	84658593          	addi	a1,a1,-1978 # ffffffffc020d110 <etext+0x183a>
ffffffffc02038d2:	10000513          	li	a0,256
ffffffffc02038d6:	291070ef          	jal	ffffffffc020b366 <strcpy>
ffffffffc02038da:	6585                	lui	a1,0x1
ffffffffc02038dc:	10058593          	addi	a1,a1,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc02038e0:	10000513          	li	a0,256
ffffffffc02038e4:	295070ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc02038e8:	7c051e63          	bnez	a0,ffffffffc02040c4 <pmm_init+0xd40>
ffffffffc02038ec:	000bb683          	ld	a3,0(s7)
ffffffffc02038f0:	000807b7          	lui	a5,0x80
ffffffffc02038f4:	6098                	ld	a4,0(s1)
ffffffffc02038f6:	40d406b3          	sub	a3,s0,a3
ffffffffc02038fa:	8699                	srai	a3,a3,0x6
ffffffffc02038fc:	96be                	add	a3,a3,a5
ffffffffc02038fe:	00c69793          	slli	a5,a3,0xc
ffffffffc0203902:	83b1                	srli	a5,a5,0xc
ffffffffc0203904:	06b2                	slli	a3,a3,0xc
ffffffffc0203906:	6ee7fe63          	bgeu	a5,a4,ffffffffc0204002 <pmm_init+0xc7e>
ffffffffc020390a:	0009b783          	ld	a5,0(s3)
ffffffffc020390e:	10000513          	li	a0,256
ffffffffc0203912:	97b6                	add	a5,a5,a3
ffffffffc0203914:	10078023          	sb	zero,256(a5) # 80100 <_binary_bin_sfs_img_size+0xae00>
ffffffffc0203918:	21b070ef          	jal	ffffffffc020b332 <strlen>
ffffffffc020391c:	54051763          	bnez	a0,ffffffffc0203e6a <pmm_init+0xae6>
ffffffffc0203920:	00093a03          	ld	s4,0(s2)
ffffffffc0203924:	6098                	ld	a4,0(s1)
ffffffffc0203926:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc020392a:	078a                	slli	a5,a5,0x2
ffffffffc020392c:	83b1                	srli	a5,a5,0xc
ffffffffc020392e:	30e7f963          	bgeu	a5,a4,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc0203932:	00c79693          	slli	a3,a5,0xc
ffffffffc0203936:	6ce7f663          	bgeu	a5,a4,ffffffffc0204002 <pmm_init+0xc7e>
ffffffffc020393a:	0009b783          	ld	a5,0(s3)
ffffffffc020393e:	00f689b3          	add	s3,a3,a5
ffffffffc0203942:	100027f3          	csrr	a5,sstatus
ffffffffc0203946:	8b89                	andi	a5,a5,2
ffffffffc0203948:	22079763          	bnez	a5,ffffffffc0203b76 <pmm_init+0x7f2>
ffffffffc020394c:	000b3783          	ld	a5,0(s6)
ffffffffc0203950:	8522                	mv	a0,s0
ffffffffc0203952:	4585                	li	a1,1
ffffffffc0203954:	739c                	ld	a5,32(a5)
ffffffffc0203956:	9782                	jalr	a5
ffffffffc0203958:	0009b783          	ld	a5,0(s3)
ffffffffc020395c:	6098                	ld	a4,0(s1)
ffffffffc020395e:	078a                	slli	a5,a5,0x2
ffffffffc0203960:	83b1                	srli	a5,a5,0xc
ffffffffc0203962:	2ce7ff63          	bgeu	a5,a4,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc0203966:	000bb503          	ld	a0,0(s7)
ffffffffc020396a:	fe000737          	lui	a4,0xfe000
ffffffffc020396e:	079a                	slli	a5,a5,0x6
ffffffffc0203970:	97ba                	add	a5,a5,a4
ffffffffc0203972:	953e                	add	a0,a0,a5
ffffffffc0203974:	100027f3          	csrr	a5,sstatus
ffffffffc0203978:	8b89                	andi	a5,a5,2
ffffffffc020397a:	24079a63          	bnez	a5,ffffffffc0203bce <pmm_init+0x84a>
ffffffffc020397e:	000b3783          	ld	a5,0(s6)
ffffffffc0203982:	4585                	li	a1,1
ffffffffc0203984:	739c                	ld	a5,32(a5)
ffffffffc0203986:	9782                	jalr	a5
ffffffffc0203988:	000a3783          	ld	a5,0(s4)
ffffffffc020398c:	6098                	ld	a4,0(s1)
ffffffffc020398e:	078a                	slli	a5,a5,0x2
ffffffffc0203990:	83b1                	srli	a5,a5,0xc
ffffffffc0203992:	2ae7f763          	bgeu	a5,a4,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc0203996:	000bb503          	ld	a0,0(s7)
ffffffffc020399a:	fe000737          	lui	a4,0xfe000
ffffffffc020399e:	079a                	slli	a5,a5,0x6
ffffffffc02039a0:	97ba                	add	a5,a5,a4
ffffffffc02039a2:	953e                	add	a0,a0,a5
ffffffffc02039a4:	100027f3          	csrr	a5,sstatus
ffffffffc02039a8:	8b89                	andi	a5,a5,2
ffffffffc02039aa:	20079663          	bnez	a5,ffffffffc0203bb6 <pmm_init+0x832>
ffffffffc02039ae:	000b3783          	ld	a5,0(s6)
ffffffffc02039b2:	4585                	li	a1,1
ffffffffc02039b4:	739c                	ld	a5,32(a5)
ffffffffc02039b6:	9782                	jalr	a5
ffffffffc02039b8:	00093783          	ld	a5,0(s2)
ffffffffc02039bc:	0007b023          	sd	zero,0(a5)
ffffffffc02039c0:	12000073          	sfence.vma
ffffffffc02039c4:	100027f3          	csrr	a5,sstatus
ffffffffc02039c8:	8b89                	andi	a5,a5,2
ffffffffc02039ca:	1c079c63          	bnez	a5,ffffffffc0203ba2 <pmm_init+0x81e>
ffffffffc02039ce:	000b3783          	ld	a5,0(s6)
ffffffffc02039d2:	779c                	ld	a5,40(a5)
ffffffffc02039d4:	9782                	jalr	a5
ffffffffc02039d6:	842a                	mv	s0,a0
ffffffffc02039d8:	448c1963          	bne	s8,s0,ffffffffc0203e2a <pmm_init+0xaa6>
ffffffffc02039dc:	00009517          	auipc	a0,0x9
ffffffffc02039e0:	7ac50513          	addi	a0,a0,1964 # ffffffffc020d188 <etext+0x18b2>
ffffffffc02039e4:	f44fc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02039e8:	7406                	ld	s0,96(sp)
ffffffffc02039ea:	70a6                	ld	ra,104(sp)
ffffffffc02039ec:	64e6                	ld	s1,88(sp)
ffffffffc02039ee:	6946                	ld	s2,80(sp)
ffffffffc02039f0:	69a6                	ld	s3,72(sp)
ffffffffc02039f2:	6a06                	ld	s4,64(sp)
ffffffffc02039f4:	7ae2                	ld	s5,56(sp)
ffffffffc02039f6:	7b42                	ld	s6,48(sp)
ffffffffc02039f8:	7ba2                	ld	s7,40(sp)
ffffffffc02039fa:	7c02                	ld	s8,32(sp)
ffffffffc02039fc:	6ce2                	ld	s9,24(sp)
ffffffffc02039fe:	6165                	addi	sp,sp,112
ffffffffc0203a00:	b18fe06f          	j	ffffffffc0201d18 <kmalloc_init>
ffffffffc0203a04:	0000f797          	auipc	a5,0xf
ffffffffc0203a08:	5fc78793          	addi	a5,a5,1532 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0203a0c:	0000f717          	auipc	a4,0xf
ffffffffc0203a10:	5f470713          	addi	a4,a4,1524 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0203a14:	b6f719e3          	bne	a4,a5,ffffffffc0203586 <pmm_init+0x202>
ffffffffc0203a18:	6605                	lui	a2,0x1
ffffffffc0203a1a:	4581                	li	a1,0
ffffffffc0203a1c:	853a                	mv	a0,a4
ffffffffc0203a1e:	1c9070ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0203a22:	0000d797          	auipc	a5,0xd
ffffffffc0203a26:	5c078ea3          	sb	zero,1501(a5) # ffffffffc0210fff <bootstackguard+0xfff>
ffffffffc0203a2a:	0000c797          	auipc	a5,0xc
ffffffffc0203a2e:	5c078b23          	sb	zero,1494(a5) # ffffffffc0210000 <bootstackguard>
ffffffffc0203a32:	0000c797          	auipc	a5,0xc
ffffffffc0203a36:	5ce78793          	addi	a5,a5,1486 # ffffffffc0210000 <bootstackguard>
ffffffffc0203a3a:	3b57eb63          	bltu	a5,s5,ffffffffc0203df0 <pmm_init+0xa6c>
ffffffffc0203a3e:	0009b683          	ld	a3,0(s3)
ffffffffc0203a42:	00093503          	ld	a0,0(s2)
ffffffffc0203a46:	0000c597          	auipc	a1,0xc
ffffffffc0203a4a:	5ba58593          	addi	a1,a1,1466 # ffffffffc0210000 <bootstackguard>
ffffffffc0203a4e:	40d586b3          	sub	a3,a1,a3
ffffffffc0203a52:	4701                	li	a4,0
ffffffffc0203a54:	6605                	lui	a2,0x1
ffffffffc0203a56:	a98ff0ef          	jal	ffffffffc0202cee <boot_map_segment>
ffffffffc0203a5a:	0000f797          	auipc	a5,0xf
ffffffffc0203a5e:	5a678793          	addi	a5,a5,1446 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0203a62:	3757ea63          	bltu	a5,s5,ffffffffc0203dd6 <pmm_init+0xa52>
ffffffffc0203a66:	0009b683          	ld	a3,0(s3)
ffffffffc0203a6a:	00093503          	ld	a0,0(s2)
ffffffffc0203a6e:	0000f597          	auipc	a1,0xf
ffffffffc0203a72:	59258593          	addi	a1,a1,1426 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0203a76:	40d586b3          	sub	a3,a1,a3
ffffffffc0203a7a:	4701                	li	a4,0
ffffffffc0203a7c:	6605                	lui	a2,0x1
ffffffffc0203a7e:	a70ff0ef          	jal	ffffffffc0202cee <boot_map_segment>
ffffffffc0203a82:	12000073          	sfence.vma
ffffffffc0203a86:	00009517          	auipc	a0,0x9
ffffffffc0203a8a:	1ea50513          	addi	a0,a0,490 # ffffffffc020cc70 <etext+0x139a>
ffffffffc0203a8e:	e9afc0ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0203a92:	bcd5                	j	ffffffffc0203586 <pmm_init+0x202>
ffffffffc0203a94:	853e                	mv	a0,a5
ffffffffc0203a96:	babd                	j	ffffffffc0203414 <pmm_init+0x90>
ffffffffc0203a98:	a6afd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203a9c:	000b3783          	ld	a5,0(s6)
ffffffffc0203aa0:	4505                	li	a0,1
ffffffffc0203aa2:	6f9c                	ld	a5,24(a5)
ffffffffc0203aa4:	9782                	jalr	a5
ffffffffc0203aa6:	8a2a                	mv	s4,a0
ffffffffc0203aa8:	a54fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203aac:	b635                	j	ffffffffc02035d8 <pmm_init+0x254>
ffffffffc0203aae:	a54fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203ab2:	000b3783          	ld	a5,0(s6)
ffffffffc0203ab6:	779c                	ld	a5,40(a5)
ffffffffc0203ab8:	9782                	jalr	a5
ffffffffc0203aba:	842a                	mv	s0,a0
ffffffffc0203abc:	a40fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203ac0:	bce9                	j	ffffffffc020359a <pmm_init+0x216>
ffffffffc0203ac2:	a40fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203ac6:	000b3783          	ld	a5,0(s6)
ffffffffc0203aca:	4505                	li	a0,1
ffffffffc0203acc:	6f9c                	ld	a5,24(a5)
ffffffffc0203ace:	9782                	jalr	a5
ffffffffc0203ad0:	842a                	mv	s0,a0
ffffffffc0203ad2:	a2afd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203ad6:	b2cd                	j	ffffffffc02034b8 <pmm_init+0x134>
ffffffffc0203ad8:	6705                	lui	a4,0x1
ffffffffc0203ada:	177d                	addi	a4,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0203adc:	96ba                	add	a3,a3,a4
ffffffffc0203ade:	8ff5                	and	a5,a5,a3
ffffffffc0203ae0:	00c7d713          	srli	a4,a5,0xc
ffffffffc0203ae4:	14a77e63          	bgeu	a4,a0,ffffffffc0203c40 <pmm_init+0x8bc>
ffffffffc0203ae8:	000b3683          	ld	a3,0(s6)
ffffffffc0203aec:	8c1d                	sub	s0,s0,a5
ffffffffc0203aee:	071a                	slli	a4,a4,0x6
ffffffffc0203af0:	fe0007b7          	lui	a5,0xfe000
ffffffffc0203af4:	973e                	add	a4,a4,a5
ffffffffc0203af6:	6a9c                	ld	a5,16(a3)
ffffffffc0203af8:	00c45593          	srli	a1,s0,0xc
ffffffffc0203afc:	00e60533          	add	a0,a2,a4
ffffffffc0203b00:	9782                	jalr	a5
ffffffffc0203b02:	0009b583          	ld	a1,0(s3)
ffffffffc0203b06:	bab5                	j	ffffffffc0203482 <pmm_init+0xfe>
ffffffffc0203b08:	9fafd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b0c:	000b3783          	ld	a5,0(s6)
ffffffffc0203b10:	4505                	li	a0,1
ffffffffc0203b12:	6f9c                	ld	a5,24(a5)
ffffffffc0203b14:	9782                	jalr	a5
ffffffffc0203b16:	8c2a                	mv	s8,a0
ffffffffc0203b18:	9e4fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203b1c:	b685                	j	ffffffffc020367c <pmm_init+0x2f8>
ffffffffc0203b1e:	9e4fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b22:	000b3783          	ld	a5,0(s6)
ffffffffc0203b26:	779c                	ld	a5,40(a5)
ffffffffc0203b28:	9782                	jalr	a5
ffffffffc0203b2a:	8c2a                	mv	s8,a0
ffffffffc0203b2c:	9d0fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203b30:	b9ed                	j	ffffffffc020382a <pmm_init+0x4a6>
ffffffffc0203b32:	9d0fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b36:	000b3783          	ld	a5,0(s6)
ffffffffc0203b3a:	779c                	ld	a5,40(a5)
ffffffffc0203b3c:	9782                	jalr	a5
ffffffffc0203b3e:	8a2a                	mv	s4,a0
ffffffffc0203b40:	9bcfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203b44:	b1c9                	j	ffffffffc0203806 <pmm_init+0x482>
ffffffffc0203b46:	e42a                	sd	a0,8(sp)
ffffffffc0203b48:	9bafd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b4c:	000b3783          	ld	a5,0(s6)
ffffffffc0203b50:	6522                	ld	a0,8(sp)
ffffffffc0203b52:	4585                	li	a1,1
ffffffffc0203b54:	739c                	ld	a5,32(a5)
ffffffffc0203b56:	9782                	jalr	a5
ffffffffc0203b58:	9a4fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203b5c:	b169                	j	ffffffffc02037e6 <pmm_init+0x462>
ffffffffc0203b5e:	e42a                	sd	a0,8(sp)
ffffffffc0203b60:	9a2fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b64:	000b3783          	ld	a5,0(s6)
ffffffffc0203b68:	6522                	ld	a0,8(sp)
ffffffffc0203b6a:	4585                	li	a1,1
ffffffffc0203b6c:	739c                	ld	a5,32(a5)
ffffffffc0203b6e:	9782                	jalr	a5
ffffffffc0203b70:	98cfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203b74:	b189                	j	ffffffffc02037b6 <pmm_init+0x432>
ffffffffc0203b76:	98cfd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b7a:	000b3783          	ld	a5,0(s6)
ffffffffc0203b7e:	8522                	mv	a0,s0
ffffffffc0203b80:	4585                	li	a1,1
ffffffffc0203b82:	739c                	ld	a5,32(a5)
ffffffffc0203b84:	9782                	jalr	a5
ffffffffc0203b86:	976fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203b8a:	b3f9                	j	ffffffffc0203958 <pmm_init+0x5d4>
ffffffffc0203b8c:	976fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203b90:	000b3783          	ld	a5,0(s6)
ffffffffc0203b94:	4505                	li	a0,1
ffffffffc0203b96:	6f9c                	ld	a5,24(a5)
ffffffffc0203b98:	9782                	jalr	a5
ffffffffc0203b9a:	842a                	mv	s0,a0
ffffffffc0203b9c:	960fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203ba0:	b9c5                	j	ffffffffc0203890 <pmm_init+0x50c>
ffffffffc0203ba2:	960fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203ba6:	000b3783          	ld	a5,0(s6)
ffffffffc0203baa:	779c                	ld	a5,40(a5)
ffffffffc0203bac:	9782                	jalr	a5
ffffffffc0203bae:	842a                	mv	s0,a0
ffffffffc0203bb0:	94cfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203bb4:	b515                	j	ffffffffc02039d8 <pmm_init+0x654>
ffffffffc0203bb6:	e42a                	sd	a0,8(sp)
ffffffffc0203bb8:	94afd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203bbc:	000b3783          	ld	a5,0(s6)
ffffffffc0203bc0:	6522                	ld	a0,8(sp)
ffffffffc0203bc2:	4585                	li	a1,1
ffffffffc0203bc4:	739c                	ld	a5,32(a5)
ffffffffc0203bc6:	9782                	jalr	a5
ffffffffc0203bc8:	934fd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203bcc:	b3f5                	j	ffffffffc02039b8 <pmm_init+0x634>
ffffffffc0203bce:	e42a                	sd	a0,8(sp)
ffffffffc0203bd0:	932fd0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0203bd4:	000b3783          	ld	a5,0(s6)
ffffffffc0203bd8:	6522                	ld	a0,8(sp)
ffffffffc0203bda:	4585                	li	a1,1
ffffffffc0203bdc:	739c                	ld	a5,32(a5)
ffffffffc0203bde:	9782                	jalr	a5
ffffffffc0203be0:	91cfd0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0203be4:	b355                	j	ffffffffc0203988 <pmm_init+0x604>
ffffffffc0203be6:	86a2                	mv	a3,s0
ffffffffc0203be8:	00009617          	auipc	a2,0x9
ffffffffc0203bec:	a7860613          	addi	a2,a2,-1416 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0203bf0:	28800593          	li	a1,648
ffffffffc0203bf4:	00009517          	auipc	a0,0x9
ffffffffc0203bf8:	f0450513          	addi	a0,a0,-252 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203bfc:	e30fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203c00:	00009697          	auipc	a3,0x9
ffffffffc0203c04:	42868693          	addi	a3,a3,1064 # ffffffffc020d028 <etext+0x1752>
ffffffffc0203c08:	00008617          	auipc	a2,0x8
ffffffffc0203c0c:	18860613          	addi	a2,a2,392 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203c10:	28900593          	li	a1,649
ffffffffc0203c14:	00009517          	auipc	a0,0x9
ffffffffc0203c18:	ee450513          	addi	a0,a0,-284 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203c1c:	e10fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203c20:	00009697          	auipc	a3,0x9
ffffffffc0203c24:	3c868693          	addi	a3,a3,968 # ffffffffc020cfe8 <etext+0x1712>
ffffffffc0203c28:	00008617          	auipc	a2,0x8
ffffffffc0203c2c:	16860613          	addi	a2,a2,360 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203c30:	28800593          	li	a1,648
ffffffffc0203c34:	00009517          	auipc	a0,0x9
ffffffffc0203c38:	ec450513          	addi	a0,a0,-316 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203c3c:	df0fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203c40:	d8dfe0ef          	jal	ffffffffc02029cc <pa2page.part.0>
ffffffffc0203c44:	00009697          	auipc	a3,0x9
ffffffffc0203c48:	24468693          	addi	a3,a3,580 # ffffffffc020ce88 <etext+0x15b2>
ffffffffc0203c4c:	00008617          	auipc	a2,0x8
ffffffffc0203c50:	14460613          	addi	a2,a2,324 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203c54:	25d00593          	li	a1,605
ffffffffc0203c58:	00009517          	auipc	a0,0x9
ffffffffc0203c5c:	ea050513          	addi	a0,a0,-352 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203c60:	dccfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203c64:	00009697          	auipc	a3,0x9
ffffffffc0203c68:	14c68693          	addi	a3,a3,332 # ffffffffc020cdb0 <etext+0x14da>
ffffffffc0203c6c:	00008617          	auipc	a2,0x8
ffffffffc0203c70:	12460613          	addi	a2,a2,292 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203c74:	25300593          	li	a1,595
ffffffffc0203c78:	00009517          	auipc	a0,0x9
ffffffffc0203c7c:	e8050513          	addi	a0,a0,-384 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203c80:	dacfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203c84:	00009697          	auipc	a3,0x9
ffffffffc0203c88:	1cc68693          	addi	a3,a3,460 # ffffffffc020ce50 <etext+0x157a>
ffffffffc0203c8c:	00008617          	auipc	a2,0x8
ffffffffc0203c90:	10460613          	addi	a2,a2,260 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203c94:	26500593          	li	a1,613
ffffffffc0203c98:	00009517          	auipc	a0,0x9
ffffffffc0203c9c:	e6050513          	addi	a0,a0,-416 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203ca0:	d8cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203ca4:	00009697          	auipc	a3,0x9
ffffffffc0203ca8:	20468693          	addi	a3,a3,516 # ffffffffc020cea8 <etext+0x15d2>
ffffffffc0203cac:	00008617          	auipc	a2,0x8
ffffffffc0203cb0:	0e460613          	addi	a2,a2,228 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203cb4:	25f00593          	li	a1,607
ffffffffc0203cb8:	00009517          	auipc	a0,0x9
ffffffffc0203cbc:	e4050513          	addi	a0,a0,-448 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203cc0:	d6cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203cc4:	00009697          	auipc	a3,0x9
ffffffffc0203cc8:	1d468693          	addi	a3,a3,468 # ffffffffc020ce98 <etext+0x15c2>
ffffffffc0203ccc:	00008617          	auipc	a2,0x8
ffffffffc0203cd0:	0c460613          	addi	a2,a2,196 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203cd4:	25e00593          	li	a1,606
ffffffffc0203cd8:	00009517          	auipc	a0,0x9
ffffffffc0203cdc:	e2050513          	addi	a0,a0,-480 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203ce0:	d4cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203ce4:	00009697          	auipc	a3,0x9
ffffffffc0203ce8:	1fc68693          	addi	a3,a3,508 # ffffffffc020cee0 <etext+0x160a>
ffffffffc0203cec:	00008617          	auipc	a2,0x8
ffffffffc0203cf0:	0a460613          	addi	a2,a2,164 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203cf4:	26200593          	li	a1,610
ffffffffc0203cf8:	00009517          	auipc	a0,0x9
ffffffffc0203cfc:	e0050513          	addi	a0,a0,-512 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203d00:	d2cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203d04:	00009697          	auipc	a3,0x9
ffffffffc0203d08:	1c468693          	addi	a3,a3,452 # ffffffffc020cec8 <etext+0x15f2>
ffffffffc0203d0c:	00008617          	auipc	a2,0x8
ffffffffc0203d10:	08460613          	addi	a2,a2,132 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203d14:	26000593          	li	a1,608
ffffffffc0203d18:	00009517          	auipc	a0,0x9
ffffffffc0203d1c:	de050513          	addi	a0,a0,-544 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203d20:	d0cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203d24:	00009697          	auipc	a3,0x9
ffffffffc0203d28:	0bc68693          	addi	a3,a3,188 # ffffffffc020cde0 <etext+0x150a>
ffffffffc0203d2c:	00008617          	auipc	a2,0x8
ffffffffc0203d30:	06460613          	addi	a2,a2,100 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203d34:	25800593          	li	a1,600
ffffffffc0203d38:	00009517          	auipc	a0,0x9
ffffffffc0203d3c:	dc050513          	addi	a0,a0,-576 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203d40:	cecfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203d44:	00009697          	auipc	a3,0x9
ffffffffc0203d48:	10c68693          	addi	a3,a3,268 # ffffffffc020ce50 <etext+0x157a>
ffffffffc0203d4c:	00008617          	auipc	a2,0x8
ffffffffc0203d50:	04460613          	addi	a2,a2,68 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203d54:	25c00593          	li	a1,604
ffffffffc0203d58:	00009517          	auipc	a0,0x9
ffffffffc0203d5c:	da050513          	addi	a0,a0,-608 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203d60:	cccfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203d64:	00009697          	auipc	a3,0x9
ffffffffc0203d68:	0ac68693          	addi	a3,a3,172 # ffffffffc020ce10 <etext+0x153a>
ffffffffc0203d6c:	00008617          	auipc	a2,0x8
ffffffffc0203d70:	02460613          	addi	a2,a2,36 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203d74:	25b00593          	li	a1,603
ffffffffc0203d78:	00009517          	auipc	a0,0x9
ffffffffc0203d7c:	d8050513          	addi	a0,a0,-640 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203d80:	cacfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203d84:	86d6                	mv	a3,s5
ffffffffc0203d86:	00009617          	auipc	a2,0x9
ffffffffc0203d8a:	8da60613          	addi	a2,a2,-1830 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0203d8e:	25700593          	li	a1,599
ffffffffc0203d92:	00009517          	auipc	a0,0x9
ffffffffc0203d96:	d6650513          	addi	a0,a0,-666 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203d9a:	c92fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203d9e:	00009617          	auipc	a2,0x9
ffffffffc0203da2:	8c260613          	addi	a2,a2,-1854 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0203da6:	25600593          	li	a1,598
ffffffffc0203daa:	00009517          	auipc	a0,0x9
ffffffffc0203dae:	d4e50513          	addi	a0,a0,-690 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203db2:	c7afc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203db6:	00009697          	auipc	a3,0x9
ffffffffc0203dba:	01268693          	addi	a3,a3,18 # ffffffffc020cdc8 <etext+0x14f2>
ffffffffc0203dbe:	00008617          	auipc	a2,0x8
ffffffffc0203dc2:	fd260613          	addi	a2,a2,-46 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203dc6:	25400593          	li	a1,596
ffffffffc0203dca:	00009517          	auipc	a0,0x9
ffffffffc0203dce:	d2e50513          	addi	a0,a0,-722 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203dd2:	c5afc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203dd6:	86be                	mv	a3,a5
ffffffffc0203dd8:	00009617          	auipc	a2,0x9
ffffffffc0203ddc:	93060613          	addi	a2,a2,-1744 # ffffffffc020c708 <etext+0xe32>
ffffffffc0203de0:	0dc00593          	li	a1,220
ffffffffc0203de4:	00009517          	auipc	a0,0x9
ffffffffc0203de8:	d1450513          	addi	a0,a0,-748 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203dec:	c40fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203df0:	86be                	mv	a3,a5
ffffffffc0203df2:	00009617          	auipc	a2,0x9
ffffffffc0203df6:	91660613          	addi	a2,a2,-1770 # ffffffffc020c708 <etext+0xe32>
ffffffffc0203dfa:	0db00593          	li	a1,219
ffffffffc0203dfe:	00009517          	auipc	a0,0x9
ffffffffc0203e02:	cfa50513          	addi	a0,a0,-774 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203e06:	c26fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203e0a:	00009697          	auipc	a3,0x9
ffffffffc0203e0e:	2ee68693          	addi	a3,a3,750 # ffffffffc020d0f8 <etext+0x1822>
ffffffffc0203e12:	00008617          	auipc	a2,0x8
ffffffffc0203e16:	f7e60613          	addi	a2,a2,-130 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203e1a:	29300593          	li	a1,659
ffffffffc0203e1e:	00009517          	auipc	a0,0x9
ffffffffc0203e22:	cda50513          	addi	a0,a0,-806 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203e26:	c06fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203e2a:	00009697          	auipc	a3,0x9
ffffffffc0203e2e:	17668693          	addi	a3,a3,374 # ffffffffc020cfa0 <etext+0x16ca>
ffffffffc0203e32:	00008617          	auipc	a2,0x8
ffffffffc0203e36:	f5e60613          	addi	a2,a2,-162 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203e3a:	2a300593          	li	a1,675
ffffffffc0203e3e:	00009517          	auipc	a0,0x9
ffffffffc0203e42:	cba50513          	addi	a0,a0,-838 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203e46:	be6fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203e4a:	00009697          	auipc	a3,0x9
ffffffffc0203e4e:	1f668693          	addi	a3,a3,502 # ffffffffc020d040 <etext+0x176a>
ffffffffc0203e52:	00008617          	auipc	a2,0x8
ffffffffc0203e56:	f3e60613          	addi	a2,a2,-194 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203e5a:	28c00593          	li	a1,652
ffffffffc0203e5e:	00009517          	auipc	a0,0x9
ffffffffc0203e62:	c9a50513          	addi	a0,a0,-870 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203e66:	bc6fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203e6a:	00009697          	auipc	a3,0x9
ffffffffc0203e6e:	2f668693          	addi	a3,a3,758 # ffffffffc020d160 <etext+0x188a>
ffffffffc0203e72:	00008617          	auipc	a2,0x8
ffffffffc0203e76:	f1e60613          	addi	a2,a2,-226 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203e7a:	29a00593          	li	a1,666
ffffffffc0203e7e:	00009517          	auipc	a0,0x9
ffffffffc0203e82:	c7a50513          	addi	a0,a0,-902 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203e86:	ba6fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203e8a:	00009697          	auipc	a3,0x9
ffffffffc0203e8e:	1ce68693          	addi	a3,a3,462 # ffffffffc020d058 <etext+0x1782>
ffffffffc0203e92:	00008617          	auipc	a2,0x8
ffffffffc0203e96:	efe60613          	addi	a2,a2,-258 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203e9a:	29000593          	li	a1,656
ffffffffc0203e9e:	00009517          	auipc	a0,0x9
ffffffffc0203ea2:	c5a50513          	addi	a0,a0,-934 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203ea6:	b86fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203eaa:	00009697          	auipc	a3,0x9
ffffffffc0203eae:	20668693          	addi	a3,a3,518 # ffffffffc020d0b0 <etext+0x17da>
ffffffffc0203eb2:	00008617          	auipc	a2,0x8
ffffffffc0203eb6:	ede60613          	addi	a2,a2,-290 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203eba:	29200593          	li	a1,658
ffffffffc0203ebe:	00009517          	auipc	a0,0x9
ffffffffc0203ec2:	c3a50513          	addi	a0,a0,-966 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203ec6:	b66fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203eca:	00009697          	auipc	a3,0x9
ffffffffc0203ece:	1ce68693          	addi	a3,a3,462 # ffffffffc020d098 <etext+0x17c2>
ffffffffc0203ed2:	00008617          	auipc	a2,0x8
ffffffffc0203ed6:	ebe60613          	addi	a2,a2,-322 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203eda:	29100593          	li	a1,657
ffffffffc0203ede:	00009517          	auipc	a0,0x9
ffffffffc0203ee2:	c1a50513          	addi	a0,a0,-998 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203ee6:	b46fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203eea:	00009697          	auipc	a3,0x9
ffffffffc0203eee:	0b668693          	addi	a3,a3,182 # ffffffffc020cfa0 <etext+0x16ca>
ffffffffc0203ef2:	00008617          	auipc	a2,0x8
ffffffffc0203ef6:	e9e60613          	addi	a2,a2,-354 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203efa:	27900593          	li	a1,633
ffffffffc0203efe:	00009517          	auipc	a0,0x9
ffffffffc0203f02:	bfa50513          	addi	a0,a0,-1030 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203f06:	b26fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203f0a:	00009697          	auipc	a3,0x9
ffffffffc0203f0e:	06668693          	addi	a3,a3,102 # ffffffffc020cf70 <etext+0x169a>
ffffffffc0203f12:	00008617          	auipc	a2,0x8
ffffffffc0203f16:	e7e60613          	addi	a2,a2,-386 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203f1a:	27100593          	li	a1,625
ffffffffc0203f1e:	00009517          	auipc	a0,0x9
ffffffffc0203f22:	bda50513          	addi	a0,a0,-1062 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203f26:	b06fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203f2a:	00009697          	auipc	a3,0x9
ffffffffc0203f2e:	ffe68693          	addi	a3,a3,-2 # ffffffffc020cf28 <etext+0x1652>
ffffffffc0203f32:	00008617          	auipc	a2,0x8
ffffffffc0203f36:	e5e60613          	addi	a2,a2,-418 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203f3a:	26f00593          	li	a1,623
ffffffffc0203f3e:	00009517          	auipc	a0,0x9
ffffffffc0203f42:	bba50513          	addi	a0,a0,-1094 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203f46:	ae6fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203f4a:	00009697          	auipc	a3,0x9
ffffffffc0203f4e:	00e68693          	addi	a3,a3,14 # ffffffffc020cf58 <etext+0x1682>
ffffffffc0203f52:	00008617          	auipc	a2,0x8
ffffffffc0203f56:	e3e60613          	addi	a2,a2,-450 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203f5a:	26e00593          	li	a1,622
ffffffffc0203f5e:	00009517          	auipc	a0,0x9
ffffffffc0203f62:	b9a50513          	addi	a0,a0,-1126 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203f66:	ac6fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203f6a:	00009697          	auipc	a3,0x9
ffffffffc0203f6e:	fbe68693          	addi	a3,a3,-66 # ffffffffc020cf28 <etext+0x1652>
ffffffffc0203f72:	00008617          	auipc	a2,0x8
ffffffffc0203f76:	e1e60613          	addi	a2,a2,-482 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203f7a:	26b00593          	li	a1,619
ffffffffc0203f7e:	00009517          	auipc	a0,0x9
ffffffffc0203f82:	b7a50513          	addi	a0,a0,-1158 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203f86:	aa6fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203f8a:	00009697          	auipc	a3,0x9
ffffffffc0203f8e:	e3e68693          	addi	a3,a3,-450 # ffffffffc020cdc8 <etext+0x14f2>
ffffffffc0203f92:	00008617          	auipc	a2,0x8
ffffffffc0203f96:	dfe60613          	addi	a2,a2,-514 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203f9a:	26a00593          	li	a1,618
ffffffffc0203f9e:	00009517          	auipc	a0,0x9
ffffffffc0203fa2:	b5a50513          	addi	a0,a0,-1190 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203fa6:	a86fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203faa:	00009697          	auipc	a3,0x9
ffffffffc0203fae:	f9668693          	addi	a3,a3,-106 # ffffffffc020cf40 <etext+0x166a>
ffffffffc0203fb2:	00008617          	auipc	a2,0x8
ffffffffc0203fb6:	dde60613          	addi	a2,a2,-546 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203fba:	26700593          	li	a1,615
ffffffffc0203fbe:	00009517          	auipc	a0,0x9
ffffffffc0203fc2:	b3a50513          	addi	a0,a0,-1222 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203fc6:	a66fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203fca:	00009697          	auipc	a3,0x9
ffffffffc0203fce:	de668693          	addi	a3,a3,-538 # ffffffffc020cdb0 <etext+0x14da>
ffffffffc0203fd2:	00008617          	auipc	a2,0x8
ffffffffc0203fd6:	dbe60613          	addi	a2,a2,-578 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0203fda:	26600593          	li	a1,614
ffffffffc0203fde:	00009517          	auipc	a0,0x9
ffffffffc0203fe2:	b1a50513          	addi	a0,a0,-1254 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203fe6:	a46fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0203fea:	00008617          	auipc	a2,0x8
ffffffffc0203fee:	71e60613          	addi	a2,a2,1822 # ffffffffc020c708 <etext+0xe32>
ffffffffc0203ff2:	08100593          	li	a1,129
ffffffffc0203ff6:	00009517          	auipc	a0,0x9
ffffffffc0203ffa:	b0250513          	addi	a0,a0,-1278 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0203ffe:	a2efc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204002:	00008617          	auipc	a2,0x8
ffffffffc0204006:	65e60613          	addi	a2,a2,1630 # ffffffffc020c660 <etext+0xd8a>
ffffffffc020400a:	07100593          	li	a1,113
ffffffffc020400e:	00008517          	auipc	a0,0x8
ffffffffc0204012:	67a50513          	addi	a0,a0,1658 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0204016:	a16fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020401a:	86a2                	mv	a3,s0
ffffffffc020401c:	00008617          	auipc	a2,0x8
ffffffffc0204020:	6ec60613          	addi	a2,a2,1772 # ffffffffc020c708 <etext+0xe32>
ffffffffc0204024:	0ca00593          	li	a1,202
ffffffffc0204028:	00009517          	auipc	a0,0x9
ffffffffc020402c:	ad050513          	addi	a0,a0,-1328 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204030:	9fcfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204034:	00009617          	auipc	a2,0x9
ffffffffc0204038:	bf460613          	addi	a2,a2,-1036 # ffffffffc020cc28 <etext+0x1352>
ffffffffc020403c:	0aa00593          	li	a1,170
ffffffffc0204040:	00009517          	auipc	a0,0x9
ffffffffc0204044:	ab850513          	addi	a0,a0,-1352 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204048:	9e4fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020404c:	00009617          	auipc	a2,0x9
ffffffffc0204050:	b4460613          	addi	a2,a2,-1212 # ffffffffc020cb90 <etext+0x12ba>
ffffffffc0204054:	06500593          	li	a1,101
ffffffffc0204058:	00009517          	auipc	a0,0x9
ffffffffc020405c:	aa050513          	addi	a0,a0,-1376 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204060:	9ccfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204064:	00009697          	auipc	a3,0x9
ffffffffc0204068:	c9468693          	addi	a3,a3,-876 # ffffffffc020ccf8 <etext+0x1422>
ffffffffc020406c:	00008617          	auipc	a2,0x8
ffffffffc0204070:	d2460613          	addi	a2,a2,-732 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204074:	24b00593          	li	a1,587
ffffffffc0204078:	00009517          	auipc	a0,0x9
ffffffffc020407c:	a8050513          	addi	a0,a0,-1408 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204080:	9acfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204084:	00009697          	auipc	a3,0x9
ffffffffc0204088:	c3468693          	addi	a3,a3,-972 # ffffffffc020ccb8 <etext+0x13e2>
ffffffffc020408c:	00008617          	auipc	a2,0x8
ffffffffc0204090:	d0460613          	addi	a2,a2,-764 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204094:	24a00593          	li	a1,586
ffffffffc0204098:	00009517          	auipc	a0,0x9
ffffffffc020409c:	a6050513          	addi	a0,a0,-1440 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02040a0:	98cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02040a4:	00009697          	auipc	a3,0x9
ffffffffc02040a8:	bf468693          	addi	a3,a3,-1036 # ffffffffc020cc98 <etext+0x13c2>
ffffffffc02040ac:	00008617          	auipc	a2,0x8
ffffffffc02040b0:	ce460613          	addi	a2,a2,-796 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02040b4:	24900593          	li	a1,585
ffffffffc02040b8:	00009517          	auipc	a0,0x9
ffffffffc02040bc:	a4050513          	addi	a0,a0,-1472 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02040c0:	96cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02040c4:	00009697          	auipc	a3,0x9
ffffffffc02040c8:	06468693          	addi	a3,a3,100 # ffffffffc020d128 <etext+0x1852>
ffffffffc02040cc:	00008617          	auipc	a2,0x8
ffffffffc02040d0:	cc460613          	addi	a2,a2,-828 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02040d4:	29700593          	li	a1,663
ffffffffc02040d8:	00009517          	auipc	a0,0x9
ffffffffc02040dc:	a2050513          	addi	a0,a0,-1504 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02040e0:	94cfc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02040e4:	00009617          	auipc	a2,0x9
ffffffffc02040e8:	ca460613          	addi	a2,a2,-860 # ffffffffc020cd88 <etext+0x14b2>
ffffffffc02040ec:	07f00593          	li	a1,127
ffffffffc02040f0:	00008517          	auipc	a0,0x8
ffffffffc02040f4:	59850513          	addi	a0,a0,1432 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02040f8:	934fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02040fc:	00009697          	auipc	a3,0x9
ffffffffc0204100:	c5c68693          	addi	a3,a3,-932 # ffffffffc020cd58 <etext+0x1482>
ffffffffc0204104:	00008617          	auipc	a2,0x8
ffffffffc0204108:	c8c60613          	addi	a2,a2,-884 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020410c:	25200593          	li	a1,594
ffffffffc0204110:	00009517          	auipc	a0,0x9
ffffffffc0204114:	9e850513          	addi	a0,a0,-1560 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204118:	914fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020411c:	00009697          	auipc	a3,0x9
ffffffffc0204120:	c0c68693          	addi	a3,a3,-1012 # ffffffffc020cd28 <etext+0x1452>
ffffffffc0204124:	00008617          	auipc	a2,0x8
ffffffffc0204128:	c6c60613          	addi	a2,a2,-916 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020412c:	24f00593          	li	a1,591
ffffffffc0204130:	00009517          	auipc	a0,0x9
ffffffffc0204134:	9c850513          	addi	a0,a0,-1592 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204138:	8f4fc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020413c:	86ca                	mv	a3,s2
ffffffffc020413e:	00008617          	auipc	a2,0x8
ffffffffc0204142:	5ca60613          	addi	a2,a2,1482 # ffffffffc020c708 <etext+0xe32>
ffffffffc0204146:	0c600593          	li	a1,198
ffffffffc020414a:	00009517          	auipc	a0,0x9
ffffffffc020414e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204152:	8dafc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204156:	00009697          	auipc	a3,0x9
ffffffffc020415a:	dd268693          	addi	a3,a3,-558 # ffffffffc020cf28 <etext+0x1652>
ffffffffc020415e:	00008617          	auipc	a2,0x8
ffffffffc0204162:	c3260613          	addi	a2,a2,-974 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204166:	26400593          	li	a1,612
ffffffffc020416a:	00009517          	auipc	a0,0x9
ffffffffc020416e:	98e50513          	addi	a0,a0,-1650 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204172:	8bafc0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204176:	00009697          	auipc	a3,0x9
ffffffffc020417a:	d9a68693          	addi	a3,a3,-614 # ffffffffc020cf10 <etext+0x163a>
ffffffffc020417e:	00008617          	auipc	a2,0x8
ffffffffc0204182:	c1260613          	addi	a2,a2,-1006 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204186:	26300593          	li	a1,611
ffffffffc020418a:	00009517          	auipc	a0,0x9
ffffffffc020418e:	96e50513          	addi	a0,a0,-1682 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204192:	89afc0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204196 <copy_range>:
ffffffffc0204196:	7159                	addi	sp,sp,-112
ffffffffc0204198:	00d667b3          	or	a5,a2,a3
ffffffffc020419c:	f486                	sd	ra,104(sp)
ffffffffc020419e:	f0a2                	sd	s0,96(sp)
ffffffffc02041a0:	eca6                	sd	s1,88(sp)
ffffffffc02041a2:	e8ca                	sd	s2,80(sp)
ffffffffc02041a4:	e4ce                	sd	s3,72(sp)
ffffffffc02041a6:	e0d2                	sd	s4,64(sp)
ffffffffc02041a8:	fc56                	sd	s5,56(sp)
ffffffffc02041aa:	f85a                	sd	s6,48(sp)
ffffffffc02041ac:	f45e                	sd	s7,40(sp)
ffffffffc02041ae:	f062                	sd	s8,32(sp)
ffffffffc02041b0:	ec66                	sd	s9,24(sp)
ffffffffc02041b2:	e86a                	sd	s10,16(sp)
ffffffffc02041b4:	e46e                	sd	s11,8(sp)
ffffffffc02041b6:	03479713          	slli	a4,a5,0x34
ffffffffc02041ba:	20071f63          	bnez	a4,ffffffffc02043d8 <copy_range+0x242>
ffffffffc02041be:	002007b7          	lui	a5,0x200
ffffffffc02041c2:	00d63733          	sltu	a4,a2,a3
ffffffffc02041c6:	00f637b3          	sltu	a5,a2,a5
ffffffffc02041ca:	00173713          	seqz	a4,a4
ffffffffc02041ce:	8fd9                	or	a5,a5,a4
ffffffffc02041d0:	8432                	mv	s0,a2
ffffffffc02041d2:	8936                	mv	s2,a3
ffffffffc02041d4:	1e079263          	bnez	a5,ffffffffc02043b8 <copy_range+0x222>
ffffffffc02041d8:	4785                	li	a5,1
ffffffffc02041da:	07fe                	slli	a5,a5,0x1f
ffffffffc02041dc:	0785                	addi	a5,a5,1 # 200001 <_binary_bin_sfs_img_size+0x18ad01>
ffffffffc02041de:	1cf6fd63          	bgeu	a3,a5,ffffffffc02043b8 <copy_range+0x222>
ffffffffc02041e2:	5b7d                	li	s6,-1
ffffffffc02041e4:	8baa                	mv	s7,a0
ffffffffc02041e6:	8a2e                	mv	s4,a1
ffffffffc02041e8:	6a85                	lui	s5,0x1
ffffffffc02041ea:	00cb5b13          	srli	s6,s6,0xc
ffffffffc02041ee:	00092c97          	auipc	s9,0x92
ffffffffc02041f2:	6c2c8c93          	addi	s9,s9,1730 # ffffffffc02968b0 <npage>
ffffffffc02041f6:	00092c17          	auipc	s8,0x92
ffffffffc02041fa:	6c2c0c13          	addi	s8,s8,1730 # ffffffffc02968b8 <pages>
ffffffffc02041fe:	fff80d37          	lui	s10,0xfff80
ffffffffc0204202:	4601                	li	a2,0
ffffffffc0204204:	85a2                	mv	a1,s0
ffffffffc0204206:	8552                	mv	a0,s4
ffffffffc0204208:	889fe0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc020420c:	84aa                	mv	s1,a0
ffffffffc020420e:	0e050a63          	beqz	a0,ffffffffc0204302 <copy_range+0x16c>
ffffffffc0204212:	611c                	ld	a5,0(a0)
ffffffffc0204214:	8b85                	andi	a5,a5,1
ffffffffc0204216:	e78d                	bnez	a5,ffffffffc0204240 <copy_range+0xaa>
ffffffffc0204218:	9456                	add	s0,s0,s5
ffffffffc020421a:	c019                	beqz	s0,ffffffffc0204220 <copy_range+0x8a>
ffffffffc020421c:	ff2463e3          	bltu	s0,s2,ffffffffc0204202 <copy_range+0x6c>
ffffffffc0204220:	4501                	li	a0,0
ffffffffc0204222:	70a6                	ld	ra,104(sp)
ffffffffc0204224:	7406                	ld	s0,96(sp)
ffffffffc0204226:	64e6                	ld	s1,88(sp)
ffffffffc0204228:	6946                	ld	s2,80(sp)
ffffffffc020422a:	69a6                	ld	s3,72(sp)
ffffffffc020422c:	6a06                	ld	s4,64(sp)
ffffffffc020422e:	7ae2                	ld	s5,56(sp)
ffffffffc0204230:	7b42                	ld	s6,48(sp)
ffffffffc0204232:	7ba2                	ld	s7,40(sp)
ffffffffc0204234:	7c02                	ld	s8,32(sp)
ffffffffc0204236:	6ce2                	ld	s9,24(sp)
ffffffffc0204238:	6d42                	ld	s10,16(sp)
ffffffffc020423a:	6da2                	ld	s11,8(sp)
ffffffffc020423c:	6165                	addi	sp,sp,112
ffffffffc020423e:	8082                	ret
ffffffffc0204240:	4605                	li	a2,1
ffffffffc0204242:	85a2                	mv	a1,s0
ffffffffc0204244:	855e                	mv	a0,s7
ffffffffc0204246:	84bfe0ef          	jal	ffffffffc0202a90 <get_pte>
ffffffffc020424a:	c165                	beqz	a0,ffffffffc020432a <copy_range+0x194>
ffffffffc020424c:	0004b983          	ld	s3,0(s1)
ffffffffc0204250:	0019f793          	andi	a5,s3,1
ffffffffc0204254:	14078663          	beqz	a5,ffffffffc02043a0 <copy_range+0x20a>
ffffffffc0204258:	000cb703          	ld	a4,0(s9)
ffffffffc020425c:	00299793          	slli	a5,s3,0x2
ffffffffc0204260:	83b1                	srli	a5,a5,0xc
ffffffffc0204262:	12e7f363          	bgeu	a5,a4,ffffffffc0204388 <copy_range+0x1f2>
ffffffffc0204266:	000c3483          	ld	s1,0(s8)
ffffffffc020426a:	97ea                	add	a5,a5,s10
ffffffffc020426c:	079a                	slli	a5,a5,0x6
ffffffffc020426e:	94be                	add	s1,s1,a5
ffffffffc0204270:	100027f3          	csrr	a5,sstatus
ffffffffc0204274:	8b89                	andi	a5,a5,2
ffffffffc0204276:	efc9                	bnez	a5,ffffffffc0204310 <copy_range+0x17a>
ffffffffc0204278:	00092797          	auipc	a5,0x92
ffffffffc020427c:	6187b783          	ld	a5,1560(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0204280:	4505                	li	a0,1
ffffffffc0204282:	6f9c                	ld	a5,24(a5)
ffffffffc0204284:	9782                	jalr	a5
ffffffffc0204286:	8daa                	mv	s11,a0
ffffffffc0204288:	c0e5                	beqz	s1,ffffffffc0204368 <copy_range+0x1d2>
ffffffffc020428a:	0a0d8f63          	beqz	s11,ffffffffc0204348 <copy_range+0x1b2>
ffffffffc020428e:	000c3783          	ld	a5,0(s8)
ffffffffc0204292:	00080637          	lui	a2,0x80
ffffffffc0204296:	000cb703          	ld	a4,0(s9)
ffffffffc020429a:	40f486b3          	sub	a3,s1,a5
ffffffffc020429e:	8699                	srai	a3,a3,0x6
ffffffffc02042a0:	96b2                	add	a3,a3,a2
ffffffffc02042a2:	0166f5b3          	and	a1,a3,s6
ffffffffc02042a6:	06b2                	slli	a3,a3,0xc
ffffffffc02042a8:	08e5f463          	bgeu	a1,a4,ffffffffc0204330 <copy_range+0x19a>
ffffffffc02042ac:	40fd87b3          	sub	a5,s11,a5
ffffffffc02042b0:	8799                	srai	a5,a5,0x6
ffffffffc02042b2:	97b2                	add	a5,a5,a2
ffffffffc02042b4:	0167f633          	and	a2,a5,s6
ffffffffc02042b8:	07b2                	slli	a5,a5,0xc
ffffffffc02042ba:	06e67a63          	bgeu	a2,a4,ffffffffc020432e <copy_range+0x198>
ffffffffc02042be:	00092517          	auipc	a0,0x92
ffffffffc02042c2:	5ea53503          	ld	a0,1514(a0) # ffffffffc02968a8 <va_pa_offset>
ffffffffc02042c6:	6605                	lui	a2,0x1
ffffffffc02042c8:	00a685b3          	add	a1,a3,a0
ffffffffc02042cc:	953e                	add	a0,a0,a5
ffffffffc02042ce:	168070ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc02042d2:	01f9f693          	andi	a3,s3,31
ffffffffc02042d6:	85ee                	mv	a1,s11
ffffffffc02042d8:	8622                	mv	a2,s0
ffffffffc02042da:	855e                	mv	a0,s7
ffffffffc02042dc:	fb3fe0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc02042e0:	dd05                	beqz	a0,ffffffffc0204218 <copy_range+0x82>
ffffffffc02042e2:	00009697          	auipc	a3,0x9
ffffffffc02042e6:	ee668693          	addi	a3,a3,-282 # ffffffffc020d1c8 <etext+0x18f2>
ffffffffc02042ea:	00008617          	auipc	a2,0x8
ffffffffc02042ee:	aa660613          	addi	a2,a2,-1370 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02042f2:	1e700593          	li	a1,487
ffffffffc02042f6:	00009517          	auipc	a0,0x9
ffffffffc02042fa:	80250513          	addi	a0,a0,-2046 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02042fe:	f2ffb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204302:	002007b7          	lui	a5,0x200
ffffffffc0204306:	97a2                	add	a5,a5,s0
ffffffffc0204308:	ffe00437          	lui	s0,0xffe00
ffffffffc020430c:	8c7d                	and	s0,s0,a5
ffffffffc020430e:	b731                	j	ffffffffc020421a <copy_range+0x84>
ffffffffc0204310:	9f3fc0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0204314:	00092797          	auipc	a5,0x92
ffffffffc0204318:	57c7b783          	ld	a5,1404(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc020431c:	4505                	li	a0,1
ffffffffc020431e:	6f9c                	ld	a5,24(a5)
ffffffffc0204320:	9782                	jalr	a5
ffffffffc0204322:	8daa                	mv	s11,a0
ffffffffc0204324:	9d9fc0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0204328:	b785                	j	ffffffffc0204288 <copy_range+0xf2>
ffffffffc020432a:	5571                	li	a0,-4
ffffffffc020432c:	bddd                	j	ffffffffc0204222 <copy_range+0x8c>
ffffffffc020432e:	86be                	mv	a3,a5
ffffffffc0204330:	00008617          	auipc	a2,0x8
ffffffffc0204334:	33060613          	addi	a2,a2,816 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0204338:	07100593          	li	a1,113
ffffffffc020433c:	00008517          	auipc	a0,0x8
ffffffffc0204340:	34c50513          	addi	a0,a0,844 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0204344:	ee9fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204348:	00009697          	auipc	a3,0x9
ffffffffc020434c:	e7068693          	addi	a3,a3,-400 # ffffffffc020d1b8 <etext+0x18e2>
ffffffffc0204350:	00008617          	auipc	a2,0x8
ffffffffc0204354:	a4060613          	addi	a2,a2,-1472 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204358:	1cf00593          	li	a1,463
ffffffffc020435c:	00008517          	auipc	a0,0x8
ffffffffc0204360:	79c50513          	addi	a0,a0,1948 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204364:	ec9fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204368:	00009697          	auipc	a3,0x9
ffffffffc020436c:	e4068693          	addi	a3,a3,-448 # ffffffffc020d1a8 <etext+0x18d2>
ffffffffc0204370:	00008617          	auipc	a2,0x8
ffffffffc0204374:	a2060613          	addi	a2,a2,-1504 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204378:	1ce00593          	li	a1,462
ffffffffc020437c:	00008517          	auipc	a0,0x8
ffffffffc0204380:	77c50513          	addi	a0,a0,1916 # ffffffffc020caf8 <etext+0x1222>
ffffffffc0204384:	ea9fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204388:	00008617          	auipc	a2,0x8
ffffffffc020438c:	3a860613          	addi	a2,a2,936 # ffffffffc020c730 <etext+0xe5a>
ffffffffc0204390:	06900593          	li	a1,105
ffffffffc0204394:	00008517          	auipc	a0,0x8
ffffffffc0204398:	2f450513          	addi	a0,a0,756 # ffffffffc020c688 <etext+0xdb2>
ffffffffc020439c:	e91fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02043a0:	00009617          	auipc	a2,0x9
ffffffffc02043a4:	9e860613          	addi	a2,a2,-1560 # ffffffffc020cd88 <etext+0x14b2>
ffffffffc02043a8:	07f00593          	li	a1,127
ffffffffc02043ac:	00008517          	auipc	a0,0x8
ffffffffc02043b0:	2dc50513          	addi	a0,a0,732 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02043b4:	e79fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02043b8:	00008697          	auipc	a3,0x8
ffffffffc02043bc:	7a868693          	addi	a3,a3,1960 # ffffffffc020cb60 <etext+0x128a>
ffffffffc02043c0:	00008617          	auipc	a2,0x8
ffffffffc02043c4:	9d060613          	addi	a2,a2,-1584 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02043c8:	1b600593          	li	a1,438
ffffffffc02043cc:	00008517          	auipc	a0,0x8
ffffffffc02043d0:	72c50513          	addi	a0,a0,1836 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02043d4:	e59fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02043d8:	00008697          	auipc	a3,0x8
ffffffffc02043dc:	75868693          	addi	a3,a3,1880 # ffffffffc020cb30 <etext+0x125a>
ffffffffc02043e0:	00008617          	auipc	a2,0x8
ffffffffc02043e4:	9b060613          	addi	a2,a2,-1616 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02043e8:	1b500593          	li	a1,437
ffffffffc02043ec:	00008517          	auipc	a0,0x8
ffffffffc02043f0:	70c50513          	addi	a0,a0,1804 # ffffffffc020caf8 <etext+0x1222>
ffffffffc02043f4:	e39fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02043f8 <pgdir_alloc_page>:
ffffffffc02043f8:	7139                	addi	sp,sp,-64
ffffffffc02043fa:	f426                	sd	s1,40(sp)
ffffffffc02043fc:	f04a                	sd	s2,32(sp)
ffffffffc02043fe:	ec4e                	sd	s3,24(sp)
ffffffffc0204400:	fc06                	sd	ra,56(sp)
ffffffffc0204402:	f822                	sd	s0,48(sp)
ffffffffc0204404:	892a                	mv	s2,a0
ffffffffc0204406:	84ae                	mv	s1,a1
ffffffffc0204408:	89b2                	mv	s3,a2
ffffffffc020440a:	100027f3          	csrr	a5,sstatus
ffffffffc020440e:	8b89                	andi	a5,a5,2
ffffffffc0204410:	ebb5                	bnez	a5,ffffffffc0204484 <pgdir_alloc_page+0x8c>
ffffffffc0204412:	00092417          	auipc	s0,0x92
ffffffffc0204416:	47e40413          	addi	s0,s0,1150 # ffffffffc0296890 <pmm_manager>
ffffffffc020441a:	601c                	ld	a5,0(s0)
ffffffffc020441c:	4505                	li	a0,1
ffffffffc020441e:	6f9c                	ld	a5,24(a5)
ffffffffc0204420:	9782                	jalr	a5
ffffffffc0204422:	85aa                	mv	a1,a0
ffffffffc0204424:	c5b9                	beqz	a1,ffffffffc0204472 <pgdir_alloc_page+0x7a>
ffffffffc0204426:	86ce                	mv	a3,s3
ffffffffc0204428:	854a                	mv	a0,s2
ffffffffc020442a:	8626                	mv	a2,s1
ffffffffc020442c:	e42e                	sd	a1,8(sp)
ffffffffc020442e:	e61fe0ef          	jal	ffffffffc020328e <page_insert>
ffffffffc0204432:	65a2                	ld	a1,8(sp)
ffffffffc0204434:	e515                	bnez	a0,ffffffffc0204460 <pgdir_alloc_page+0x68>
ffffffffc0204436:	4198                	lw	a4,0(a1)
ffffffffc0204438:	fd84                	sd	s1,56(a1)
ffffffffc020443a:	4785                	li	a5,1
ffffffffc020443c:	02f70c63          	beq	a4,a5,ffffffffc0204474 <pgdir_alloc_page+0x7c>
ffffffffc0204440:	00009697          	auipc	a3,0x9
ffffffffc0204444:	d9868693          	addi	a3,a3,-616 # ffffffffc020d1d8 <etext+0x1902>
ffffffffc0204448:	00008617          	auipc	a2,0x8
ffffffffc020444c:	94860613          	addi	a2,a2,-1720 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204450:	23000593          	li	a1,560
ffffffffc0204454:	00008517          	auipc	a0,0x8
ffffffffc0204458:	6a450513          	addi	a0,a0,1700 # ffffffffc020caf8 <etext+0x1222>
ffffffffc020445c:	dd1fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204460:	100027f3          	csrr	a5,sstatus
ffffffffc0204464:	8b89                	andi	a5,a5,2
ffffffffc0204466:	ef95                	bnez	a5,ffffffffc02044a2 <pgdir_alloc_page+0xaa>
ffffffffc0204468:	601c                	ld	a5,0(s0)
ffffffffc020446a:	852e                	mv	a0,a1
ffffffffc020446c:	4585                	li	a1,1
ffffffffc020446e:	739c                	ld	a5,32(a5)
ffffffffc0204470:	9782                	jalr	a5
ffffffffc0204472:	4581                	li	a1,0
ffffffffc0204474:	70e2                	ld	ra,56(sp)
ffffffffc0204476:	7442                	ld	s0,48(sp)
ffffffffc0204478:	74a2                	ld	s1,40(sp)
ffffffffc020447a:	7902                	ld	s2,32(sp)
ffffffffc020447c:	69e2                	ld	s3,24(sp)
ffffffffc020447e:	852e                	mv	a0,a1
ffffffffc0204480:	6121                	addi	sp,sp,64
ffffffffc0204482:	8082                	ret
ffffffffc0204484:	87ffc0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0204488:	00092417          	auipc	s0,0x92
ffffffffc020448c:	40840413          	addi	s0,s0,1032 # ffffffffc0296890 <pmm_manager>
ffffffffc0204490:	601c                	ld	a5,0(s0)
ffffffffc0204492:	4505                	li	a0,1
ffffffffc0204494:	6f9c                	ld	a5,24(a5)
ffffffffc0204496:	9782                	jalr	a5
ffffffffc0204498:	e42a                	sd	a0,8(sp)
ffffffffc020449a:	863fc0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020449e:	65a2                	ld	a1,8(sp)
ffffffffc02044a0:	b751                	j	ffffffffc0204424 <pgdir_alloc_page+0x2c>
ffffffffc02044a2:	861fc0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc02044a6:	601c                	ld	a5,0(s0)
ffffffffc02044a8:	6522                	ld	a0,8(sp)
ffffffffc02044aa:	4585                	li	a1,1
ffffffffc02044ac:	739c                	ld	a5,32(a5)
ffffffffc02044ae:	9782                	jalr	a5
ffffffffc02044b0:	84dfc0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc02044b4:	bf7d                	j	ffffffffc0204472 <pgdir_alloc_page+0x7a>

ffffffffc02044b6 <wait_queue_init>:
ffffffffc02044b6:	e508                	sd	a0,8(a0)
ffffffffc02044b8:	e108                	sd	a0,0(a0)
ffffffffc02044ba:	8082                	ret

ffffffffc02044bc <wait_queue_del>:
ffffffffc02044bc:	7198                	ld	a4,32(a1)
ffffffffc02044be:	01858793          	addi	a5,a1,24
ffffffffc02044c2:	00e78b63          	beq	a5,a4,ffffffffc02044d8 <wait_queue_del+0x1c>
ffffffffc02044c6:	6994                	ld	a3,16(a1)
ffffffffc02044c8:	00a69863          	bne	a3,a0,ffffffffc02044d8 <wait_queue_del+0x1c>
ffffffffc02044cc:	6d94                	ld	a3,24(a1)
ffffffffc02044ce:	e698                	sd	a4,8(a3)
ffffffffc02044d0:	e314                	sd	a3,0(a4)
ffffffffc02044d2:	f19c                	sd	a5,32(a1)
ffffffffc02044d4:	ed9c                	sd	a5,24(a1)
ffffffffc02044d6:	8082                	ret
ffffffffc02044d8:	1141                	addi	sp,sp,-16
ffffffffc02044da:	00009697          	auipc	a3,0x9
ffffffffc02044de:	d6668693          	addi	a3,a3,-666 # ffffffffc020d240 <etext+0x196a>
ffffffffc02044e2:	00008617          	auipc	a2,0x8
ffffffffc02044e6:	8ae60613          	addi	a2,a2,-1874 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02044ea:	45f1                	li	a1,28
ffffffffc02044ec:	00009517          	auipc	a0,0x9
ffffffffc02044f0:	d3c50513          	addi	a0,a0,-708 # ffffffffc020d228 <etext+0x1952>
ffffffffc02044f4:	e406                	sd	ra,8(sp)
ffffffffc02044f6:	d37fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02044fa <wait_queue_first>:
ffffffffc02044fa:	651c                	ld	a5,8(a0)
ffffffffc02044fc:	00f50563          	beq	a0,a5,ffffffffc0204506 <wait_queue_first+0xc>
ffffffffc0204500:	fe878513          	addi	a0,a5,-24
ffffffffc0204504:	8082                	ret
ffffffffc0204506:	4501                	li	a0,0
ffffffffc0204508:	8082                	ret

ffffffffc020450a <wait_queue_empty>:
ffffffffc020450a:	651c                	ld	a5,8(a0)
ffffffffc020450c:	40a78533          	sub	a0,a5,a0
ffffffffc0204510:	00153513          	seqz	a0,a0
ffffffffc0204514:	8082                	ret

ffffffffc0204516 <wait_in_queue>:
ffffffffc0204516:	711c                	ld	a5,32(a0)
ffffffffc0204518:	0561                	addi	a0,a0,24
ffffffffc020451a:	40a78533          	sub	a0,a5,a0
ffffffffc020451e:	00a03533          	snez	a0,a0
ffffffffc0204522:	8082                	ret

ffffffffc0204524 <wakeup_wait>:
ffffffffc0204524:	e689                	bnez	a3,ffffffffc020452e <wakeup_wait+0xa>
ffffffffc0204526:	6188                	ld	a0,0(a1)
ffffffffc0204528:	c590                	sw	a2,8(a1)
ffffffffc020452a:	6b10206f          	j	ffffffffc02073da <wakeup_proc>
ffffffffc020452e:	7198                	ld	a4,32(a1)
ffffffffc0204530:	01858793          	addi	a5,a1,24
ffffffffc0204534:	00e78e63          	beq	a5,a4,ffffffffc0204550 <wakeup_wait+0x2c>
ffffffffc0204538:	6994                	ld	a3,16(a1)
ffffffffc020453a:	00d51b63          	bne	a0,a3,ffffffffc0204550 <wakeup_wait+0x2c>
ffffffffc020453e:	6d94                	ld	a3,24(a1)
ffffffffc0204540:	6188                	ld	a0,0(a1)
ffffffffc0204542:	e698                	sd	a4,8(a3)
ffffffffc0204544:	e314                	sd	a3,0(a4)
ffffffffc0204546:	f19c                	sd	a5,32(a1)
ffffffffc0204548:	ed9c                	sd	a5,24(a1)
ffffffffc020454a:	c590                	sw	a2,8(a1)
ffffffffc020454c:	68f0206f          	j	ffffffffc02073da <wakeup_proc>
ffffffffc0204550:	1141                	addi	sp,sp,-16
ffffffffc0204552:	00009697          	auipc	a3,0x9
ffffffffc0204556:	cee68693          	addi	a3,a3,-786 # ffffffffc020d240 <etext+0x196a>
ffffffffc020455a:	00008617          	auipc	a2,0x8
ffffffffc020455e:	83660613          	addi	a2,a2,-1994 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204562:	45f1                	li	a1,28
ffffffffc0204564:	00009517          	auipc	a0,0x9
ffffffffc0204568:	cc450513          	addi	a0,a0,-828 # ffffffffc020d228 <etext+0x1952>
ffffffffc020456c:	e406                	sd	ra,8(sp)
ffffffffc020456e:	cbffb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204572 <wakeup_queue>:
ffffffffc0204572:	651c                	ld	a5,8(a0)
ffffffffc0204574:	0aa78763          	beq	a5,a0,ffffffffc0204622 <wakeup_queue+0xb0>
ffffffffc0204578:	1101                	addi	sp,sp,-32
ffffffffc020457a:	e822                	sd	s0,16(sp)
ffffffffc020457c:	e426                	sd	s1,8(sp)
ffffffffc020457e:	e04a                	sd	s2,0(sp)
ffffffffc0204580:	ec06                	sd	ra,24(sp)
ffffffffc0204582:	892e                	mv	s2,a1
ffffffffc0204584:	84aa                	mv	s1,a0
ffffffffc0204586:	fe878413          	addi	s0,a5,-24
ffffffffc020458a:	ee29                	bnez	a2,ffffffffc02045e4 <wakeup_queue+0x72>
ffffffffc020458c:	6008                	ld	a0,0(s0)
ffffffffc020458e:	01242423          	sw	s2,8(s0)
ffffffffc0204592:	649020ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc0204596:	701c                	ld	a5,32(s0)
ffffffffc0204598:	01840713          	addi	a4,s0,24
ffffffffc020459c:	02e78463          	beq	a5,a4,ffffffffc02045c4 <wakeup_queue+0x52>
ffffffffc02045a0:	6818                	ld	a4,16(s0)
ffffffffc02045a2:	02e49163          	bne	s1,a4,ffffffffc02045c4 <wakeup_queue+0x52>
ffffffffc02045a6:	06f48863          	beq	s1,a5,ffffffffc0204616 <wakeup_queue+0xa4>
ffffffffc02045aa:	fe87b503          	ld	a0,-24(a5)
ffffffffc02045ae:	ff27a823          	sw	s2,-16(a5)
ffffffffc02045b2:	fe878413          	addi	s0,a5,-24
ffffffffc02045b6:	625020ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc02045ba:	701c                	ld	a5,32(s0)
ffffffffc02045bc:	01840713          	addi	a4,s0,24
ffffffffc02045c0:	fee790e3          	bne	a5,a4,ffffffffc02045a0 <wakeup_queue+0x2e>
ffffffffc02045c4:	00009697          	auipc	a3,0x9
ffffffffc02045c8:	c7c68693          	addi	a3,a3,-900 # ffffffffc020d240 <etext+0x196a>
ffffffffc02045cc:	00007617          	auipc	a2,0x7
ffffffffc02045d0:	7c460613          	addi	a2,a2,1988 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02045d4:	02200593          	li	a1,34
ffffffffc02045d8:	00009517          	auipc	a0,0x9
ffffffffc02045dc:	c5050513          	addi	a0,a0,-944 # ffffffffc020d228 <etext+0x1952>
ffffffffc02045e0:	c4dfb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02045e4:	6798                	ld	a4,8(a5)
ffffffffc02045e6:	00e79863          	bne	a5,a4,ffffffffc02045f6 <wakeup_queue+0x84>
ffffffffc02045ea:	a82d                	j	ffffffffc0204624 <wakeup_queue+0xb2>
ffffffffc02045ec:	6418                	ld	a4,8(s0)
ffffffffc02045ee:	87a2                	mv	a5,s0
ffffffffc02045f0:	1421                	addi	s0,s0,-24
ffffffffc02045f2:	02e78963          	beq	a5,a4,ffffffffc0204624 <wakeup_queue+0xb2>
ffffffffc02045f6:	6814                	ld	a3,16(s0)
ffffffffc02045f8:	02d49663          	bne	s1,a3,ffffffffc0204624 <wakeup_queue+0xb2>
ffffffffc02045fc:	6c14                	ld	a3,24(s0)
ffffffffc02045fe:	6008                	ld	a0,0(s0)
ffffffffc0204600:	e698                	sd	a4,8(a3)
ffffffffc0204602:	e314                	sd	a3,0(a4)
ffffffffc0204604:	f01c                	sd	a5,32(s0)
ffffffffc0204606:	ec1c                	sd	a5,24(s0)
ffffffffc0204608:	01242423          	sw	s2,8(s0)
ffffffffc020460c:	5cf020ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc0204610:	6480                	ld	s0,8(s1)
ffffffffc0204612:	fc849de3          	bne	s1,s0,ffffffffc02045ec <wakeup_queue+0x7a>
ffffffffc0204616:	60e2                	ld	ra,24(sp)
ffffffffc0204618:	6442                	ld	s0,16(sp)
ffffffffc020461a:	64a2                	ld	s1,8(sp)
ffffffffc020461c:	6902                	ld	s2,0(sp)
ffffffffc020461e:	6105                	addi	sp,sp,32
ffffffffc0204620:	8082                	ret
ffffffffc0204622:	8082                	ret
ffffffffc0204624:	00009697          	auipc	a3,0x9
ffffffffc0204628:	c1c68693          	addi	a3,a3,-996 # ffffffffc020d240 <etext+0x196a>
ffffffffc020462c:	00007617          	auipc	a2,0x7
ffffffffc0204630:	76460613          	addi	a2,a2,1892 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204634:	45f1                	li	a1,28
ffffffffc0204636:	00009517          	auipc	a0,0x9
ffffffffc020463a:	bf250513          	addi	a0,a0,-1038 # ffffffffc020d228 <etext+0x1952>
ffffffffc020463e:	beffb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204642 <wait_current_set>:
ffffffffc0204642:	00092797          	auipc	a5,0x92
ffffffffc0204646:	2867b783          	ld	a5,646(a5) # ffffffffc02968c8 <current>
ffffffffc020464a:	c39d                	beqz	a5,ffffffffc0204670 <wait_current_set+0x2e>
ffffffffc020464c:	80000737          	lui	a4,0x80000
ffffffffc0204650:	c598                	sw	a4,8(a1)
ffffffffc0204652:	01858713          	addi	a4,a1,24
ffffffffc0204656:	ed98                	sd	a4,24(a1)
ffffffffc0204658:	e19c                	sd	a5,0(a1)
ffffffffc020465a:	0ec7a623          	sw	a2,236(a5)
ffffffffc020465e:	4605                	li	a2,1
ffffffffc0204660:	6114                	ld	a3,0(a0)
ffffffffc0204662:	c390                	sw	a2,0(a5)
ffffffffc0204664:	e988                	sd	a0,16(a1)
ffffffffc0204666:	e118                	sd	a4,0(a0)
ffffffffc0204668:	e698                	sd	a4,8(a3)
ffffffffc020466a:	ed94                	sd	a3,24(a1)
ffffffffc020466c:	f188                	sd	a0,32(a1)
ffffffffc020466e:	8082                	ret
ffffffffc0204670:	1141                	addi	sp,sp,-16
ffffffffc0204672:	00009697          	auipc	a3,0x9
ffffffffc0204676:	c0e68693          	addi	a3,a3,-1010 # ffffffffc020d280 <etext+0x19aa>
ffffffffc020467a:	00007617          	auipc	a2,0x7
ffffffffc020467e:	71660613          	addi	a2,a2,1814 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204682:	07400593          	li	a1,116
ffffffffc0204686:	00009517          	auipc	a0,0x9
ffffffffc020468a:	ba250513          	addi	a0,a0,-1118 # ffffffffc020d228 <etext+0x1952>
ffffffffc020468e:	e406                	sd	ra,8(sp)
ffffffffc0204690:	b9dfb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204694 <__down.constprop.0>:
ffffffffc0204694:	711d                	addi	sp,sp,-96
ffffffffc0204696:	ec86                	sd	ra,88(sp)
ffffffffc0204698:	100027f3          	csrr	a5,sstatus
ffffffffc020469c:	8b89                	andi	a5,a5,2
ffffffffc020469e:	eba1                	bnez	a5,ffffffffc02046ee <__down.constprop.0+0x5a>
ffffffffc02046a0:	411c                	lw	a5,0(a0)
ffffffffc02046a2:	00f05863          	blez	a5,ffffffffc02046b2 <__down.constprop.0+0x1e>
ffffffffc02046a6:	37fd                	addiw	a5,a5,-1
ffffffffc02046a8:	c11c                	sw	a5,0(a0)
ffffffffc02046aa:	60e6                	ld	ra,88(sp)
ffffffffc02046ac:	4501                	li	a0,0
ffffffffc02046ae:	6125                	addi	sp,sp,96
ffffffffc02046b0:	8082                	ret
ffffffffc02046b2:	0521                	addi	a0,a0,8
ffffffffc02046b4:	082c                	addi	a1,sp,24
ffffffffc02046b6:	10000613          	li	a2,256
ffffffffc02046ba:	e8a2                	sd	s0,80(sp)
ffffffffc02046bc:	e4a6                	sd	s1,72(sp)
ffffffffc02046be:	0820                	addi	s0,sp,24
ffffffffc02046c0:	84aa                	mv	s1,a0
ffffffffc02046c2:	f81ff0ef          	jal	ffffffffc0204642 <wait_current_set>
ffffffffc02046c6:	60d020ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc02046ca:	100027f3          	csrr	a5,sstatus
ffffffffc02046ce:	8b89                	andi	a5,a5,2
ffffffffc02046d0:	efa9                	bnez	a5,ffffffffc020472a <__down.constprop.0+0x96>
ffffffffc02046d2:	8522                	mv	a0,s0
ffffffffc02046d4:	e43ff0ef          	jal	ffffffffc0204516 <wait_in_queue>
ffffffffc02046d8:	e521                	bnez	a0,ffffffffc0204720 <__down.constprop.0+0x8c>
ffffffffc02046da:	5502                	lw	a0,32(sp)
ffffffffc02046dc:	10000793          	li	a5,256
ffffffffc02046e0:	6446                	ld	s0,80(sp)
ffffffffc02046e2:	64a6                	ld	s1,72(sp)
ffffffffc02046e4:	fcf503e3          	beq	a0,a5,ffffffffc02046aa <__down.constprop.0+0x16>
ffffffffc02046e8:	60e6                	ld	ra,88(sp)
ffffffffc02046ea:	6125                	addi	sp,sp,96
ffffffffc02046ec:	8082                	ret
ffffffffc02046ee:	e42a                	sd	a0,8(sp)
ffffffffc02046f0:	e12fc0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc02046f4:	6522                	ld	a0,8(sp)
ffffffffc02046f6:	411c                	lw	a5,0(a0)
ffffffffc02046f8:	00f05763          	blez	a5,ffffffffc0204706 <__down.constprop.0+0x72>
ffffffffc02046fc:	37fd                	addiw	a5,a5,-1
ffffffffc02046fe:	c11c                	sw	a5,0(a0)
ffffffffc0204700:	dfcfc0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0204704:	b75d                	j	ffffffffc02046aa <__down.constprop.0+0x16>
ffffffffc0204706:	0521                	addi	a0,a0,8
ffffffffc0204708:	082c                	addi	a1,sp,24
ffffffffc020470a:	10000613          	li	a2,256
ffffffffc020470e:	e8a2                	sd	s0,80(sp)
ffffffffc0204710:	e4a6                	sd	s1,72(sp)
ffffffffc0204712:	0820                	addi	s0,sp,24
ffffffffc0204714:	84aa                	mv	s1,a0
ffffffffc0204716:	f2dff0ef          	jal	ffffffffc0204642 <wait_current_set>
ffffffffc020471a:	de2fc0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020471e:	b765                	j	ffffffffc02046c6 <__down.constprop.0+0x32>
ffffffffc0204720:	85a2                	mv	a1,s0
ffffffffc0204722:	8526                	mv	a0,s1
ffffffffc0204724:	d99ff0ef          	jal	ffffffffc02044bc <wait_queue_del>
ffffffffc0204728:	bf4d                	j	ffffffffc02046da <__down.constprop.0+0x46>
ffffffffc020472a:	dd8fc0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc020472e:	8522                	mv	a0,s0
ffffffffc0204730:	de7ff0ef          	jal	ffffffffc0204516 <wait_in_queue>
ffffffffc0204734:	e501                	bnez	a0,ffffffffc020473c <__down.constprop.0+0xa8>
ffffffffc0204736:	dc6fc0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020473a:	b745                	j	ffffffffc02046da <__down.constprop.0+0x46>
ffffffffc020473c:	85a2                	mv	a1,s0
ffffffffc020473e:	8526                	mv	a0,s1
ffffffffc0204740:	d7dff0ef          	jal	ffffffffc02044bc <wait_queue_del>
ffffffffc0204744:	bfcd                	j	ffffffffc0204736 <__down.constprop.0+0xa2>

ffffffffc0204746 <__up.constprop.0>:
ffffffffc0204746:	1101                	addi	sp,sp,-32
ffffffffc0204748:	e426                	sd	s1,8(sp)
ffffffffc020474a:	ec06                	sd	ra,24(sp)
ffffffffc020474c:	e822                	sd	s0,16(sp)
ffffffffc020474e:	e04a                	sd	s2,0(sp)
ffffffffc0204750:	84aa                	mv	s1,a0
ffffffffc0204752:	100027f3          	csrr	a5,sstatus
ffffffffc0204756:	8b89                	andi	a5,a5,2
ffffffffc0204758:	4901                	li	s2,0
ffffffffc020475a:	e7b1                	bnez	a5,ffffffffc02047a6 <__up.constprop.0+0x60>
ffffffffc020475c:	00848413          	addi	s0,s1,8
ffffffffc0204760:	8522                	mv	a0,s0
ffffffffc0204762:	d99ff0ef          	jal	ffffffffc02044fa <wait_queue_first>
ffffffffc0204766:	cd05                	beqz	a0,ffffffffc020479e <__up.constprop.0+0x58>
ffffffffc0204768:	6118                	ld	a4,0(a0)
ffffffffc020476a:	10000793          	li	a5,256
ffffffffc020476e:	0ec72603          	lw	a2,236(a4) # ffffffff800000ec <_binary_bin_sfs_img_size+0xffffffff7ff8adec>
ffffffffc0204772:	02f61e63          	bne	a2,a5,ffffffffc02047ae <__up.constprop.0+0x68>
ffffffffc0204776:	85aa                	mv	a1,a0
ffffffffc0204778:	4685                	li	a3,1
ffffffffc020477a:	8522                	mv	a0,s0
ffffffffc020477c:	da9ff0ef          	jal	ffffffffc0204524 <wakeup_wait>
ffffffffc0204780:	00091863          	bnez	s2,ffffffffc0204790 <__up.constprop.0+0x4a>
ffffffffc0204784:	60e2                	ld	ra,24(sp)
ffffffffc0204786:	6442                	ld	s0,16(sp)
ffffffffc0204788:	64a2                	ld	s1,8(sp)
ffffffffc020478a:	6902                	ld	s2,0(sp)
ffffffffc020478c:	6105                	addi	sp,sp,32
ffffffffc020478e:	8082                	ret
ffffffffc0204790:	6442                	ld	s0,16(sp)
ffffffffc0204792:	60e2                	ld	ra,24(sp)
ffffffffc0204794:	64a2                	ld	s1,8(sp)
ffffffffc0204796:	6902                	ld	s2,0(sp)
ffffffffc0204798:	6105                	addi	sp,sp,32
ffffffffc020479a:	d62fc06f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc020479e:	409c                	lw	a5,0(s1)
ffffffffc02047a0:	2785                	addiw	a5,a5,1
ffffffffc02047a2:	c09c                	sw	a5,0(s1)
ffffffffc02047a4:	bff1                	j	ffffffffc0204780 <__up.constprop.0+0x3a>
ffffffffc02047a6:	d5cfc0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc02047aa:	4905                	li	s2,1
ffffffffc02047ac:	bf45                	j	ffffffffc020475c <__up.constprop.0+0x16>
ffffffffc02047ae:	00009697          	auipc	a3,0x9
ffffffffc02047b2:	ae268693          	addi	a3,a3,-1310 # ffffffffc020d290 <etext+0x19ba>
ffffffffc02047b6:	00007617          	auipc	a2,0x7
ffffffffc02047ba:	5da60613          	addi	a2,a2,1498 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02047be:	45e5                	li	a1,25
ffffffffc02047c0:	00009517          	auipc	a0,0x9
ffffffffc02047c4:	af850513          	addi	a0,a0,-1288 # ffffffffc020d2b8 <etext+0x19e2>
ffffffffc02047c8:	a65fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02047cc <sem_init>:
ffffffffc02047cc:	c10c                	sw	a1,0(a0)
ffffffffc02047ce:	0521                	addi	a0,a0,8
ffffffffc02047d0:	ce7ff06f          	j	ffffffffc02044b6 <wait_queue_init>

ffffffffc02047d4 <up>:
ffffffffc02047d4:	f73ff06f          	j	ffffffffc0204746 <__up.constprop.0>

ffffffffc02047d8 <down>:
ffffffffc02047d8:	1141                	addi	sp,sp,-16
ffffffffc02047da:	e406                	sd	ra,8(sp)
ffffffffc02047dc:	eb9ff0ef          	jal	ffffffffc0204694 <__down.constprop.0>
ffffffffc02047e0:	e501                	bnez	a0,ffffffffc02047e8 <down+0x10>
ffffffffc02047e2:	60a2                	ld	ra,8(sp)
ffffffffc02047e4:	0141                	addi	sp,sp,16
ffffffffc02047e6:	8082                	ret
ffffffffc02047e8:	00009697          	auipc	a3,0x9
ffffffffc02047ec:	ae068693          	addi	a3,a3,-1312 # ffffffffc020d2c8 <etext+0x19f2>
ffffffffc02047f0:	00007617          	auipc	a2,0x7
ffffffffc02047f4:	5a060613          	addi	a2,a2,1440 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02047f8:	04000593          	li	a1,64
ffffffffc02047fc:	00009517          	auipc	a0,0x9
ffffffffc0204800:	abc50513          	addi	a0,a0,-1348 # ffffffffc020d2b8 <etext+0x19e2>
ffffffffc0204804:	a29fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204808 <copy_path>:
ffffffffc0204808:	7139                	addi	sp,sp,-64
ffffffffc020480a:	f04a                	sd	s2,32(sp)
ffffffffc020480c:	00092917          	auipc	s2,0x92
ffffffffc0204810:	0bc90913          	addi	s2,s2,188 # ffffffffc02968c8 <current>
ffffffffc0204814:	00093783          	ld	a5,0(s2)
ffffffffc0204818:	e852                	sd	s4,16(sp)
ffffffffc020481a:	8a2a                	mv	s4,a0
ffffffffc020481c:	6505                	lui	a0,0x1
ffffffffc020481e:	f426                	sd	s1,40(sp)
ffffffffc0204820:	ec4e                	sd	s3,24(sp)
ffffffffc0204822:	fc06                	sd	ra,56(sp)
ffffffffc0204824:	7784                	ld	s1,40(a5)
ffffffffc0204826:	89ae                	mv	s3,a1
ffffffffc0204828:	d14fd0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020482c:	c92d                	beqz	a0,ffffffffc020489e <copy_path+0x96>
ffffffffc020482e:	f822                	sd	s0,48(sp)
ffffffffc0204830:	842a                	mv	s0,a0
ffffffffc0204832:	c0b1                	beqz	s1,ffffffffc0204876 <copy_path+0x6e>
ffffffffc0204834:	03848513          	addi	a0,s1,56
ffffffffc0204838:	fa1ff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc020483c:	00093783          	ld	a5,0(s2)
ffffffffc0204840:	c399                	beqz	a5,ffffffffc0204846 <copy_path+0x3e>
ffffffffc0204842:	43dc                	lw	a5,4(a5)
ffffffffc0204844:	c8bc                	sw	a5,80(s1)
ffffffffc0204846:	864e                	mv	a2,s3
ffffffffc0204848:	6685                	lui	a3,0x1
ffffffffc020484a:	85a2                	mv	a1,s0
ffffffffc020484c:	8526                	mv	a0,s1
ffffffffc020484e:	9defd0ef          	jal	ffffffffc0201a2c <copy_string>
ffffffffc0204852:	cd1d                	beqz	a0,ffffffffc0204890 <copy_path+0x88>
ffffffffc0204854:	03848513          	addi	a0,s1,56
ffffffffc0204858:	f7dff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020485c:	0404a823          	sw	zero,80(s1)
ffffffffc0204860:	008a3023          	sd	s0,0(s4)
ffffffffc0204864:	7442                	ld	s0,48(sp)
ffffffffc0204866:	4501                	li	a0,0
ffffffffc0204868:	70e2                	ld	ra,56(sp)
ffffffffc020486a:	74a2                	ld	s1,40(sp)
ffffffffc020486c:	7902                	ld	s2,32(sp)
ffffffffc020486e:	69e2                	ld	s3,24(sp)
ffffffffc0204870:	6a42                	ld	s4,16(sp)
ffffffffc0204872:	6121                	addi	sp,sp,64
ffffffffc0204874:	8082                	ret
ffffffffc0204876:	85aa                	mv	a1,a0
ffffffffc0204878:	864e                	mv	a2,s3
ffffffffc020487a:	6685                	lui	a3,0x1
ffffffffc020487c:	4501                	li	a0,0
ffffffffc020487e:	9aefd0ef          	jal	ffffffffc0201a2c <copy_string>
ffffffffc0204882:	fd79                	bnez	a0,ffffffffc0204860 <copy_path+0x58>
ffffffffc0204884:	8522                	mv	a0,s0
ffffffffc0204886:	d5cfd0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020488a:	5575                	li	a0,-3
ffffffffc020488c:	7442                	ld	s0,48(sp)
ffffffffc020488e:	bfe9                	j	ffffffffc0204868 <copy_path+0x60>
ffffffffc0204890:	03848513          	addi	a0,s1,56
ffffffffc0204894:	f41ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204898:	0404a823          	sw	zero,80(s1)
ffffffffc020489c:	b7e5                	j	ffffffffc0204884 <copy_path+0x7c>
ffffffffc020489e:	5571                	li	a0,-4
ffffffffc02048a0:	b7e1                	j	ffffffffc0204868 <copy_path+0x60>

ffffffffc02048a2 <sysfile_open>:
ffffffffc02048a2:	7179                	addi	sp,sp,-48
ffffffffc02048a4:	f022                	sd	s0,32(sp)
ffffffffc02048a6:	842e                	mv	s0,a1
ffffffffc02048a8:	85aa                	mv	a1,a0
ffffffffc02048aa:	0828                	addi	a0,sp,24
ffffffffc02048ac:	f406                	sd	ra,40(sp)
ffffffffc02048ae:	f5bff0ef          	jal	ffffffffc0204808 <copy_path>
ffffffffc02048b2:	87aa                	mv	a5,a0
ffffffffc02048b4:	ed09                	bnez	a0,ffffffffc02048ce <sysfile_open+0x2c>
ffffffffc02048b6:	6762                	ld	a4,24(sp)
ffffffffc02048b8:	85a2                	mv	a1,s0
ffffffffc02048ba:	853a                	mv	a0,a4
ffffffffc02048bc:	e43a                	sd	a4,8(sp)
ffffffffc02048be:	7e8000ef          	jal	ffffffffc02050a6 <file_open>
ffffffffc02048c2:	6722                	ld	a4,8(sp)
ffffffffc02048c4:	e42a                	sd	a0,8(sp)
ffffffffc02048c6:	853a                	mv	a0,a4
ffffffffc02048c8:	d1afd0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc02048cc:	67a2                	ld	a5,8(sp)
ffffffffc02048ce:	70a2                	ld	ra,40(sp)
ffffffffc02048d0:	7402                	ld	s0,32(sp)
ffffffffc02048d2:	853e                	mv	a0,a5
ffffffffc02048d4:	6145                	addi	sp,sp,48
ffffffffc02048d6:	8082                	ret

ffffffffc02048d8 <sysfile_close>:
ffffffffc02048d8:	0e90006f          	j	ffffffffc02051c0 <file_close>

ffffffffc02048dc <sysfile_read>:
ffffffffc02048dc:	7119                	addi	sp,sp,-128
ffffffffc02048de:	f466                	sd	s9,40(sp)
ffffffffc02048e0:	fc86                	sd	ra,120(sp)
ffffffffc02048e2:	4c81                	li	s9,0
ffffffffc02048e4:	e611                	bnez	a2,ffffffffc02048f0 <sysfile_read+0x14>
ffffffffc02048e6:	70e6                	ld	ra,120(sp)
ffffffffc02048e8:	8566                	mv	a0,s9
ffffffffc02048ea:	7ca2                	ld	s9,40(sp)
ffffffffc02048ec:	6109                	addi	sp,sp,128
ffffffffc02048ee:	8082                	ret
ffffffffc02048f0:	f862                	sd	s8,48(sp)
ffffffffc02048f2:	00092c17          	auipc	s8,0x92
ffffffffc02048f6:	fd6c0c13          	addi	s8,s8,-42 # ffffffffc02968c8 <current>
ffffffffc02048fa:	000c3783          	ld	a5,0(s8)
ffffffffc02048fe:	f8a2                	sd	s0,112(sp)
ffffffffc0204900:	f0ca                	sd	s2,96(sp)
ffffffffc0204902:	8432                	mv	s0,a2
ffffffffc0204904:	892e                	mv	s2,a1
ffffffffc0204906:	4601                	li	a2,0
ffffffffc0204908:	4585                	li	a1,1
ffffffffc020490a:	f4a6                	sd	s1,104(sp)
ffffffffc020490c:	e8d2                	sd	s4,80(sp)
ffffffffc020490e:	7784                	ld	s1,40(a5)
ffffffffc0204910:	8a2a                	mv	s4,a0
ffffffffc0204912:	740000ef          	jal	ffffffffc0205052 <file_testfd>
ffffffffc0204916:	c969                	beqz	a0,ffffffffc02049e8 <sysfile_read+0x10c>
ffffffffc0204918:	6505                	lui	a0,0x1
ffffffffc020491a:	ecce                	sd	s3,88(sp)
ffffffffc020491c:	c20fd0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0204920:	89aa                	mv	s3,a0
ffffffffc0204922:	c971                	beqz	a0,ffffffffc02049f6 <sysfile_read+0x11a>
ffffffffc0204924:	e4d6                	sd	s5,72(sp)
ffffffffc0204926:	e0da                	sd	s6,64(sp)
ffffffffc0204928:	6a85                	lui	s5,0x1
ffffffffc020492a:	4b01                	li	s6,0
ffffffffc020492c:	09546863          	bltu	s0,s5,ffffffffc02049bc <sysfile_read+0xe0>
ffffffffc0204930:	6785                	lui	a5,0x1
ffffffffc0204932:	863e                	mv	a2,a5
ffffffffc0204934:	0834                	addi	a3,sp,24
ffffffffc0204936:	85ce                	mv	a1,s3
ffffffffc0204938:	8552                	mv	a0,s4
ffffffffc020493a:	ec3e                	sd	a5,24(sp)
ffffffffc020493c:	0dd000ef          	jal	ffffffffc0205218 <file_read>
ffffffffc0204940:	66e2                	ld	a3,24(sp)
ffffffffc0204942:	8caa                	mv	s9,a0
ffffffffc0204944:	e68d                	bnez	a3,ffffffffc020496e <sysfile_read+0x92>
ffffffffc0204946:	854e                	mv	a0,s3
ffffffffc0204948:	c9afd0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020494c:	000b0463          	beqz	s6,ffffffffc0204954 <sysfile_read+0x78>
ffffffffc0204950:	000b0c9b          	sext.w	s9,s6
ffffffffc0204954:	7446                	ld	s0,112(sp)
ffffffffc0204956:	70e6                	ld	ra,120(sp)
ffffffffc0204958:	74a6                	ld	s1,104(sp)
ffffffffc020495a:	7906                	ld	s2,96(sp)
ffffffffc020495c:	69e6                	ld	s3,88(sp)
ffffffffc020495e:	6a46                	ld	s4,80(sp)
ffffffffc0204960:	6aa6                	ld	s5,72(sp)
ffffffffc0204962:	6b06                	ld	s6,64(sp)
ffffffffc0204964:	7c42                	ld	s8,48(sp)
ffffffffc0204966:	8566                	mv	a0,s9
ffffffffc0204968:	7ca2                	ld	s9,40(sp)
ffffffffc020496a:	6109                	addi	sp,sp,128
ffffffffc020496c:	8082                	ret
ffffffffc020496e:	c899                	beqz	s1,ffffffffc0204984 <sysfile_read+0xa8>
ffffffffc0204970:	03848513          	addi	a0,s1,56
ffffffffc0204974:	e65ff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0204978:	000c3783          	ld	a5,0(s8)
ffffffffc020497c:	66e2                	ld	a3,24(sp)
ffffffffc020497e:	c399                	beqz	a5,ffffffffc0204984 <sysfile_read+0xa8>
ffffffffc0204980:	43dc                	lw	a5,4(a5)
ffffffffc0204982:	c8bc                	sw	a5,80(s1)
ffffffffc0204984:	864e                	mv	a2,s3
ffffffffc0204986:	85ca                	mv	a1,s2
ffffffffc0204988:	8526                	mv	a0,s1
ffffffffc020498a:	86afd0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc020498e:	c915                	beqz	a0,ffffffffc02049c2 <sysfile_read+0xe6>
ffffffffc0204990:	67e2                	ld	a5,24(sp)
ffffffffc0204992:	06f46a63          	bltu	s0,a5,ffffffffc0204a06 <sysfile_read+0x12a>
ffffffffc0204996:	9b3e                	add	s6,s6,a5
ffffffffc0204998:	c889                	beqz	s1,ffffffffc02049aa <sysfile_read+0xce>
ffffffffc020499a:	03848513          	addi	a0,s1,56
ffffffffc020499e:	e43e                	sd	a5,8(sp)
ffffffffc02049a0:	e35ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc02049a4:	67a2                	ld	a5,8(sp)
ffffffffc02049a6:	0404a823          	sw	zero,80(s1)
ffffffffc02049aa:	f80c9ee3          	bnez	s9,ffffffffc0204946 <sysfile_read+0x6a>
ffffffffc02049ae:	6762                	ld	a4,24(sp)
ffffffffc02049b0:	db59                	beqz	a4,ffffffffc0204946 <sysfile_read+0x6a>
ffffffffc02049b2:	8c1d                	sub	s0,s0,a5
ffffffffc02049b4:	d849                	beqz	s0,ffffffffc0204946 <sysfile_read+0x6a>
ffffffffc02049b6:	993e                	add	s2,s2,a5
ffffffffc02049b8:	f7547ce3          	bgeu	s0,s5,ffffffffc0204930 <sysfile_read+0x54>
ffffffffc02049bc:	87a2                	mv	a5,s0
ffffffffc02049be:	8622                	mv	a2,s0
ffffffffc02049c0:	bf95                	j	ffffffffc0204934 <sysfile_read+0x58>
ffffffffc02049c2:	000c8a63          	beqz	s9,ffffffffc02049d6 <sysfile_read+0xfa>
ffffffffc02049c6:	d0c1                	beqz	s1,ffffffffc0204946 <sysfile_read+0x6a>
ffffffffc02049c8:	03848513          	addi	a0,s1,56
ffffffffc02049cc:	e09ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc02049d0:	0404a823          	sw	zero,80(s1)
ffffffffc02049d4:	bf8d                	j	ffffffffc0204946 <sysfile_read+0x6a>
ffffffffc02049d6:	c499                	beqz	s1,ffffffffc02049e4 <sysfile_read+0x108>
ffffffffc02049d8:	03848513          	addi	a0,s1,56
ffffffffc02049dc:	df9ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc02049e0:	0404a823          	sw	zero,80(s1)
ffffffffc02049e4:	5cf5                	li	s9,-3
ffffffffc02049e6:	b785                	j	ffffffffc0204946 <sysfile_read+0x6a>
ffffffffc02049e8:	7446                	ld	s0,112(sp)
ffffffffc02049ea:	74a6                	ld	s1,104(sp)
ffffffffc02049ec:	7906                	ld	s2,96(sp)
ffffffffc02049ee:	6a46                	ld	s4,80(sp)
ffffffffc02049f0:	7c42                	ld	s8,48(sp)
ffffffffc02049f2:	5cf5                	li	s9,-3
ffffffffc02049f4:	bdcd                	j	ffffffffc02048e6 <sysfile_read+0xa>
ffffffffc02049f6:	7446                	ld	s0,112(sp)
ffffffffc02049f8:	74a6                	ld	s1,104(sp)
ffffffffc02049fa:	7906                	ld	s2,96(sp)
ffffffffc02049fc:	69e6                	ld	s3,88(sp)
ffffffffc02049fe:	6a46                	ld	s4,80(sp)
ffffffffc0204a00:	7c42                	ld	s8,48(sp)
ffffffffc0204a02:	5cf1                	li	s9,-4
ffffffffc0204a04:	b5cd                	j	ffffffffc02048e6 <sysfile_read+0xa>
ffffffffc0204a06:	00009697          	auipc	a3,0x9
ffffffffc0204a0a:	8d268693          	addi	a3,a3,-1838 # ffffffffc020d2d8 <etext+0x1a02>
ffffffffc0204a0e:	00007617          	auipc	a2,0x7
ffffffffc0204a12:	38260613          	addi	a2,a2,898 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204a16:	05500593          	li	a1,85
ffffffffc0204a1a:	00009517          	auipc	a0,0x9
ffffffffc0204a1e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc020d2e8 <etext+0x1a12>
ffffffffc0204a22:	fc5e                	sd	s7,56(sp)
ffffffffc0204a24:	809fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204a28 <sysfile_write>:
ffffffffc0204a28:	e601                	bnez	a2,ffffffffc0204a30 <sysfile_write+0x8>
ffffffffc0204a2a:	4701                	li	a4,0
ffffffffc0204a2c:	853a                	mv	a0,a4
ffffffffc0204a2e:	8082                	ret
ffffffffc0204a30:	7159                	addi	sp,sp,-112
ffffffffc0204a32:	f062                	sd	s8,32(sp)
ffffffffc0204a34:	00092c17          	auipc	s8,0x92
ffffffffc0204a38:	e94c0c13          	addi	s8,s8,-364 # ffffffffc02968c8 <current>
ffffffffc0204a3c:	000c3783          	ld	a5,0(s8)
ffffffffc0204a40:	f0a2                	sd	s0,96(sp)
ffffffffc0204a42:	eca6                	sd	s1,88(sp)
ffffffffc0204a44:	8432                	mv	s0,a2
ffffffffc0204a46:	84ae                	mv	s1,a1
ffffffffc0204a48:	4605                	li	a2,1
ffffffffc0204a4a:	4581                	li	a1,0
ffffffffc0204a4c:	e8ca                	sd	s2,80(sp)
ffffffffc0204a4e:	e0d2                	sd	s4,64(sp)
ffffffffc0204a50:	f486                	sd	ra,104(sp)
ffffffffc0204a52:	0287b903          	ld	s2,40(a5) # 1028 <_binary_bin_swap_img_size-0x6cd8>
ffffffffc0204a56:	8a2a                	mv	s4,a0
ffffffffc0204a58:	5fa000ef          	jal	ffffffffc0205052 <file_testfd>
ffffffffc0204a5c:	c969                	beqz	a0,ffffffffc0204b2e <sysfile_write+0x106>
ffffffffc0204a5e:	6505                	lui	a0,0x1
ffffffffc0204a60:	e4ce                	sd	s3,72(sp)
ffffffffc0204a62:	adafd0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0204a66:	89aa                	mv	s3,a0
ffffffffc0204a68:	c569                	beqz	a0,ffffffffc0204b32 <sysfile_write+0x10a>
ffffffffc0204a6a:	fc56                	sd	s5,56(sp)
ffffffffc0204a6c:	f45e                	sd	s7,40(sp)
ffffffffc0204a6e:	4a81                	li	s5,0
ffffffffc0204a70:	6b85                	lui	s7,0x1
ffffffffc0204a72:	86a2                	mv	a3,s0
ffffffffc0204a74:	008bf363          	bgeu	s7,s0,ffffffffc0204a7a <sysfile_write+0x52>
ffffffffc0204a78:	6685                	lui	a3,0x1
ffffffffc0204a7a:	ec36                	sd	a3,24(sp)
ffffffffc0204a7c:	04090e63          	beqz	s2,ffffffffc0204ad8 <sysfile_write+0xb0>
ffffffffc0204a80:	03890513          	addi	a0,s2,56
ffffffffc0204a84:	d55ff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0204a88:	000c3783          	ld	a5,0(s8)
ffffffffc0204a8c:	c781                	beqz	a5,ffffffffc0204a94 <sysfile_write+0x6c>
ffffffffc0204a8e:	43dc                	lw	a5,4(a5)
ffffffffc0204a90:	04f92823          	sw	a5,80(s2)
ffffffffc0204a94:	66e2                	ld	a3,24(sp)
ffffffffc0204a96:	4701                	li	a4,0
ffffffffc0204a98:	8626                	mv	a2,s1
ffffffffc0204a9a:	85ce                	mv	a1,s3
ffffffffc0204a9c:	854a                	mv	a0,s2
ffffffffc0204a9e:	f21fc0ef          	jal	ffffffffc02019be <copy_from_user>
ffffffffc0204aa2:	ed3d                	bnez	a0,ffffffffc0204b20 <sysfile_write+0xf8>
ffffffffc0204aa4:	03890513          	addi	a0,s2,56
ffffffffc0204aa8:	d2dff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204aac:	04092823          	sw	zero,80(s2)
ffffffffc0204ab0:	5775                	li	a4,-3
ffffffffc0204ab2:	854e                	mv	a0,s3
ffffffffc0204ab4:	e43a                	sd	a4,8(sp)
ffffffffc0204ab6:	b2cfd0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0204aba:	6722                	ld	a4,8(sp)
ffffffffc0204abc:	040a9c63          	bnez	s5,ffffffffc0204b14 <sysfile_write+0xec>
ffffffffc0204ac0:	69a6                	ld	s3,72(sp)
ffffffffc0204ac2:	7ae2                	ld	s5,56(sp)
ffffffffc0204ac4:	7ba2                	ld	s7,40(sp)
ffffffffc0204ac6:	70a6                	ld	ra,104(sp)
ffffffffc0204ac8:	7406                	ld	s0,96(sp)
ffffffffc0204aca:	64e6                	ld	s1,88(sp)
ffffffffc0204acc:	6946                	ld	s2,80(sp)
ffffffffc0204ace:	6a06                	ld	s4,64(sp)
ffffffffc0204ad0:	7c02                	ld	s8,32(sp)
ffffffffc0204ad2:	853a                	mv	a0,a4
ffffffffc0204ad4:	6165                	addi	sp,sp,112
ffffffffc0204ad6:	8082                	ret
ffffffffc0204ad8:	4701                	li	a4,0
ffffffffc0204ada:	8626                	mv	a2,s1
ffffffffc0204adc:	85ce                	mv	a1,s3
ffffffffc0204ade:	4501                	li	a0,0
ffffffffc0204ae0:	edffc0ef          	jal	ffffffffc02019be <copy_from_user>
ffffffffc0204ae4:	d571                	beqz	a0,ffffffffc0204ab0 <sysfile_write+0x88>
ffffffffc0204ae6:	6662                	ld	a2,24(sp)
ffffffffc0204ae8:	0834                	addi	a3,sp,24
ffffffffc0204aea:	85ce                	mv	a1,s3
ffffffffc0204aec:	8552                	mv	a0,s4
ffffffffc0204aee:	019000ef          	jal	ffffffffc0205306 <file_write>
ffffffffc0204af2:	67e2                	ld	a5,24(sp)
ffffffffc0204af4:	872a                	mv	a4,a0
ffffffffc0204af6:	dfd5                	beqz	a5,ffffffffc0204ab2 <sysfile_write+0x8a>
ffffffffc0204af8:	04f46063          	bltu	s0,a5,ffffffffc0204b38 <sysfile_write+0x110>
ffffffffc0204afc:	9abe                	add	s5,s5,a5
ffffffffc0204afe:	f955                	bnez	a0,ffffffffc0204ab2 <sysfile_write+0x8a>
ffffffffc0204b00:	8c1d                	sub	s0,s0,a5
ffffffffc0204b02:	94be                	add	s1,s1,a5
ffffffffc0204b04:	f43d                	bnez	s0,ffffffffc0204a72 <sysfile_write+0x4a>
ffffffffc0204b06:	854e                	mv	a0,s3
ffffffffc0204b08:	e43a                	sd	a4,8(sp)
ffffffffc0204b0a:	ad8fd0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0204b0e:	6722                	ld	a4,8(sp)
ffffffffc0204b10:	fa0a88e3          	beqz	s5,ffffffffc0204ac0 <sysfile_write+0x98>
ffffffffc0204b14:	000a871b          	sext.w	a4,s5
ffffffffc0204b18:	69a6                	ld	s3,72(sp)
ffffffffc0204b1a:	7ae2                	ld	s5,56(sp)
ffffffffc0204b1c:	7ba2                	ld	s7,40(sp)
ffffffffc0204b1e:	b765                	j	ffffffffc0204ac6 <sysfile_write+0x9e>
ffffffffc0204b20:	03890513          	addi	a0,s2,56
ffffffffc0204b24:	cb1ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204b28:	04092823          	sw	zero,80(s2)
ffffffffc0204b2c:	bf6d                	j	ffffffffc0204ae6 <sysfile_write+0xbe>
ffffffffc0204b2e:	5775                	li	a4,-3
ffffffffc0204b30:	bf59                	j	ffffffffc0204ac6 <sysfile_write+0x9e>
ffffffffc0204b32:	69a6                	ld	s3,72(sp)
ffffffffc0204b34:	5771                	li	a4,-4
ffffffffc0204b36:	bf41                	j	ffffffffc0204ac6 <sysfile_write+0x9e>
ffffffffc0204b38:	00008697          	auipc	a3,0x8
ffffffffc0204b3c:	7a068693          	addi	a3,a3,1952 # ffffffffc020d2d8 <etext+0x1a02>
ffffffffc0204b40:	00007617          	auipc	a2,0x7
ffffffffc0204b44:	25060613          	addi	a2,a2,592 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204b48:	08a00593          	li	a1,138
ffffffffc0204b4c:	00008517          	auipc	a0,0x8
ffffffffc0204b50:	79c50513          	addi	a0,a0,1948 # ffffffffc020d2e8 <etext+0x1a12>
ffffffffc0204b54:	f85a                	sd	s6,48(sp)
ffffffffc0204b56:	ed6fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204b5a <sysfile_seek>:
ffffffffc0204b5a:	09b0006f          	j	ffffffffc02053f4 <file_seek>

ffffffffc0204b5e <sysfile_fstat>:
ffffffffc0204b5e:	715d                	addi	sp,sp,-80
ffffffffc0204b60:	f84a                	sd	s2,48(sp)
ffffffffc0204b62:	00092917          	auipc	s2,0x92
ffffffffc0204b66:	d6690913          	addi	s2,s2,-666 # ffffffffc02968c8 <current>
ffffffffc0204b6a:	00093783          	ld	a5,0(s2)
ffffffffc0204b6e:	f44e                	sd	s3,40(sp)
ffffffffc0204b70:	89ae                	mv	s3,a1
ffffffffc0204b72:	858a                	mv	a1,sp
ffffffffc0204b74:	e0a2                	sd	s0,64(sp)
ffffffffc0204b76:	fc26                	sd	s1,56(sp)
ffffffffc0204b78:	e486                	sd	ra,72(sp)
ffffffffc0204b7a:	7784                	ld	s1,40(a5)
ffffffffc0204b7c:	19d000ef          	jal	ffffffffc0205518 <file_fstat>
ffffffffc0204b80:	842a                	mv	s0,a0
ffffffffc0204b82:	e915                	bnez	a0,ffffffffc0204bb6 <sysfile_fstat+0x58>
ffffffffc0204b84:	c0a9                	beqz	s1,ffffffffc0204bc6 <sysfile_fstat+0x68>
ffffffffc0204b86:	03848513          	addi	a0,s1,56
ffffffffc0204b8a:	c4fff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0204b8e:	00093783          	ld	a5,0(s2)
ffffffffc0204b92:	c399                	beqz	a5,ffffffffc0204b98 <sysfile_fstat+0x3a>
ffffffffc0204b94:	43dc                	lw	a5,4(a5)
ffffffffc0204b96:	c8bc                	sw	a5,80(s1)
ffffffffc0204b98:	860a                	mv	a2,sp
ffffffffc0204b9a:	85ce                	mv	a1,s3
ffffffffc0204b9c:	02000693          	li	a3,32
ffffffffc0204ba0:	8526                	mv	a0,s1
ffffffffc0204ba2:	e53fc0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc0204ba6:	e111                	bnez	a0,ffffffffc0204baa <sysfile_fstat+0x4c>
ffffffffc0204ba8:	5475                	li	s0,-3
ffffffffc0204baa:	03848513          	addi	a0,s1,56
ffffffffc0204bae:	c27ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204bb2:	0404a823          	sw	zero,80(s1)
ffffffffc0204bb6:	60a6                	ld	ra,72(sp)
ffffffffc0204bb8:	8522                	mv	a0,s0
ffffffffc0204bba:	6406                	ld	s0,64(sp)
ffffffffc0204bbc:	74e2                	ld	s1,56(sp)
ffffffffc0204bbe:	7942                	ld	s2,48(sp)
ffffffffc0204bc0:	79a2                	ld	s3,40(sp)
ffffffffc0204bc2:	6161                	addi	sp,sp,80
ffffffffc0204bc4:	8082                	ret
ffffffffc0204bc6:	860a                	mv	a2,sp
ffffffffc0204bc8:	85ce                	mv	a1,s3
ffffffffc0204bca:	02000693          	li	a3,32
ffffffffc0204bce:	e27fc0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc0204bd2:	f175                	bnez	a0,ffffffffc0204bb6 <sysfile_fstat+0x58>
ffffffffc0204bd4:	5475                	li	s0,-3
ffffffffc0204bd6:	60a6                	ld	ra,72(sp)
ffffffffc0204bd8:	8522                	mv	a0,s0
ffffffffc0204bda:	6406                	ld	s0,64(sp)
ffffffffc0204bdc:	74e2                	ld	s1,56(sp)
ffffffffc0204bde:	7942                	ld	s2,48(sp)
ffffffffc0204be0:	79a2                	ld	s3,40(sp)
ffffffffc0204be2:	6161                	addi	sp,sp,80
ffffffffc0204be4:	8082                	ret

ffffffffc0204be6 <sysfile_fsync>:
ffffffffc0204be6:	1eb0006f          	j	ffffffffc02055d0 <file_fsync>

ffffffffc0204bea <sysfile_getcwd>:
ffffffffc0204bea:	c1d5                	beqz	a1,ffffffffc0204c8e <sysfile_getcwd+0xa4>
ffffffffc0204bec:	00092717          	auipc	a4,0x92
ffffffffc0204bf0:	cdc73703          	ld	a4,-804(a4) # ffffffffc02968c8 <current>
ffffffffc0204bf4:	711d                	addi	sp,sp,-96
ffffffffc0204bf6:	e8a2                	sd	s0,80(sp)
ffffffffc0204bf8:	7700                	ld	s0,40(a4)
ffffffffc0204bfa:	e4a6                	sd	s1,72(sp)
ffffffffc0204bfc:	e0ca                	sd	s2,64(sp)
ffffffffc0204bfe:	ec86                	sd	ra,88(sp)
ffffffffc0204c00:	892a                	mv	s2,a0
ffffffffc0204c02:	84ae                	mv	s1,a1
ffffffffc0204c04:	c039                	beqz	s0,ffffffffc0204c4a <sysfile_getcwd+0x60>
ffffffffc0204c06:	03840513          	addi	a0,s0,56
ffffffffc0204c0a:	bcfff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0204c0e:	00092797          	auipc	a5,0x92
ffffffffc0204c12:	cba7b783          	ld	a5,-838(a5) # ffffffffc02968c8 <current>
ffffffffc0204c16:	c399                	beqz	a5,ffffffffc0204c1c <sysfile_getcwd+0x32>
ffffffffc0204c18:	43dc                	lw	a5,4(a5)
ffffffffc0204c1a:	c83c                	sw	a5,80(s0)
ffffffffc0204c1c:	4685                	li	a3,1
ffffffffc0204c1e:	8626                	mv	a2,s1
ffffffffc0204c20:	85ca                	mv	a1,s2
ffffffffc0204c22:	8522                	mv	a0,s0
ffffffffc0204c24:	cf7fc0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc0204c28:	57f5                	li	a5,-3
ffffffffc0204c2a:	e921                	bnez	a0,ffffffffc0204c7a <sysfile_getcwd+0x90>
ffffffffc0204c2c:	03840513          	addi	a0,s0,56
ffffffffc0204c30:	e43e                	sd	a5,8(sp)
ffffffffc0204c32:	ba3ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204c36:	67a2                	ld	a5,8(sp)
ffffffffc0204c38:	04042823          	sw	zero,80(s0)
ffffffffc0204c3c:	60e6                	ld	ra,88(sp)
ffffffffc0204c3e:	6446                	ld	s0,80(sp)
ffffffffc0204c40:	64a6                	ld	s1,72(sp)
ffffffffc0204c42:	6906                	ld	s2,64(sp)
ffffffffc0204c44:	853e                	mv	a0,a5
ffffffffc0204c46:	6125                	addi	sp,sp,96
ffffffffc0204c48:	8082                	ret
ffffffffc0204c4a:	862e                	mv	a2,a1
ffffffffc0204c4c:	4685                	li	a3,1
ffffffffc0204c4e:	85aa                	mv	a1,a0
ffffffffc0204c50:	4501                	li	a0,0
ffffffffc0204c52:	cc9fc0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc0204c56:	57f5                	li	a5,-3
ffffffffc0204c58:	d175                	beqz	a0,ffffffffc0204c3c <sysfile_getcwd+0x52>
ffffffffc0204c5a:	8626                	mv	a2,s1
ffffffffc0204c5c:	85ca                	mv	a1,s2
ffffffffc0204c5e:	4681                	li	a3,0
ffffffffc0204c60:	0808                	addi	a0,sp,16
ffffffffc0204c62:	39b000ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc0204c66:	35c030ef          	jal	ffffffffc0207fc2 <vfs_getcwd>
ffffffffc0204c6a:	60e6                	ld	ra,88(sp)
ffffffffc0204c6c:	6446                	ld	s0,80(sp)
ffffffffc0204c6e:	87aa                	mv	a5,a0
ffffffffc0204c70:	64a6                	ld	s1,72(sp)
ffffffffc0204c72:	6906                	ld	s2,64(sp)
ffffffffc0204c74:	853e                	mv	a0,a5
ffffffffc0204c76:	6125                	addi	sp,sp,96
ffffffffc0204c78:	8082                	ret
ffffffffc0204c7a:	8626                	mv	a2,s1
ffffffffc0204c7c:	85ca                	mv	a1,s2
ffffffffc0204c7e:	4681                	li	a3,0
ffffffffc0204c80:	0808                	addi	a0,sp,16
ffffffffc0204c82:	37b000ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc0204c86:	33c030ef          	jal	ffffffffc0207fc2 <vfs_getcwd>
ffffffffc0204c8a:	87aa                	mv	a5,a0
ffffffffc0204c8c:	b745                	j	ffffffffc0204c2c <sysfile_getcwd+0x42>
ffffffffc0204c8e:	57f5                	li	a5,-3
ffffffffc0204c90:	853e                	mv	a0,a5
ffffffffc0204c92:	8082                	ret

ffffffffc0204c94 <sysfile_getdirentry>:
ffffffffc0204c94:	7139                	addi	sp,sp,-64
ffffffffc0204c96:	ec4e                	sd	s3,24(sp)
ffffffffc0204c98:	00092997          	auipc	s3,0x92
ffffffffc0204c9c:	c3098993          	addi	s3,s3,-976 # ffffffffc02968c8 <current>
ffffffffc0204ca0:	0009b783          	ld	a5,0(s3)
ffffffffc0204ca4:	f04a                	sd	s2,32(sp)
ffffffffc0204ca6:	892a                	mv	s2,a0
ffffffffc0204ca8:	10800513          	li	a0,264
ffffffffc0204cac:	f426                	sd	s1,40(sp)
ffffffffc0204cae:	e852                	sd	s4,16(sp)
ffffffffc0204cb0:	fc06                	sd	ra,56(sp)
ffffffffc0204cb2:	7784                	ld	s1,40(a5)
ffffffffc0204cb4:	8a2e                	mv	s4,a1
ffffffffc0204cb6:	886fd0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0204cba:	c179                	beqz	a0,ffffffffc0204d80 <sysfile_getdirentry+0xec>
ffffffffc0204cbc:	f822                	sd	s0,48(sp)
ffffffffc0204cbe:	842a                	mv	s0,a0
ffffffffc0204cc0:	c8d1                	beqz	s1,ffffffffc0204d54 <sysfile_getdirentry+0xc0>
ffffffffc0204cc2:	03848513          	addi	a0,s1,56
ffffffffc0204cc6:	b13ff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0204cca:	0009b783          	ld	a5,0(s3)
ffffffffc0204cce:	c399                	beqz	a5,ffffffffc0204cd4 <sysfile_getdirentry+0x40>
ffffffffc0204cd0:	43dc                	lw	a5,4(a5)
ffffffffc0204cd2:	c8bc                	sw	a5,80(s1)
ffffffffc0204cd4:	4705                	li	a4,1
ffffffffc0204cd6:	46a1                	li	a3,8
ffffffffc0204cd8:	8652                	mv	a2,s4
ffffffffc0204cda:	85a2                	mv	a1,s0
ffffffffc0204cdc:	8526                	mv	a0,s1
ffffffffc0204cde:	ce1fc0ef          	jal	ffffffffc02019be <copy_from_user>
ffffffffc0204ce2:	e505                	bnez	a0,ffffffffc0204d0a <sysfile_getdirentry+0x76>
ffffffffc0204ce4:	03848513          	addi	a0,s1,56
ffffffffc0204ce8:	aedff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204cec:	0404a823          	sw	zero,80(s1)
ffffffffc0204cf0:	5975                	li	s2,-3
ffffffffc0204cf2:	8522                	mv	a0,s0
ffffffffc0204cf4:	8eefd0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0204cf8:	7442                	ld	s0,48(sp)
ffffffffc0204cfa:	70e2                	ld	ra,56(sp)
ffffffffc0204cfc:	74a2                	ld	s1,40(sp)
ffffffffc0204cfe:	69e2                	ld	s3,24(sp)
ffffffffc0204d00:	6a42                	ld	s4,16(sp)
ffffffffc0204d02:	854a                	mv	a0,s2
ffffffffc0204d04:	7902                	ld	s2,32(sp)
ffffffffc0204d06:	6121                	addi	sp,sp,64
ffffffffc0204d08:	8082                	ret
ffffffffc0204d0a:	03848513          	addi	a0,s1,56
ffffffffc0204d0e:	ac7ff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204d12:	854a                	mv	a0,s2
ffffffffc0204d14:	0404a823          	sw	zero,80(s1)
ffffffffc0204d18:	85a2                	mv	a1,s0
ffffffffc0204d1a:	161000ef          	jal	ffffffffc020567a <file_getdirentry>
ffffffffc0204d1e:	892a                	mv	s2,a0
ffffffffc0204d20:	f969                	bnez	a0,ffffffffc0204cf2 <sysfile_getdirentry+0x5e>
ffffffffc0204d22:	03848513          	addi	a0,s1,56
ffffffffc0204d26:	ab3ff0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0204d2a:	0009b783          	ld	a5,0(s3)
ffffffffc0204d2e:	c399                	beqz	a5,ffffffffc0204d34 <sysfile_getdirentry+0xa0>
ffffffffc0204d30:	43dc                	lw	a5,4(a5)
ffffffffc0204d32:	c8bc                	sw	a5,80(s1)
ffffffffc0204d34:	85d2                	mv	a1,s4
ffffffffc0204d36:	10800693          	li	a3,264
ffffffffc0204d3a:	8622                	mv	a2,s0
ffffffffc0204d3c:	8526                	mv	a0,s1
ffffffffc0204d3e:	cb7fc0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc0204d42:	e111                	bnez	a0,ffffffffc0204d46 <sysfile_getdirentry+0xb2>
ffffffffc0204d44:	5975                	li	s2,-3
ffffffffc0204d46:	03848513          	addi	a0,s1,56
ffffffffc0204d4a:	a8bff0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0204d4e:	0404a823          	sw	zero,80(s1)
ffffffffc0204d52:	b745                	j	ffffffffc0204cf2 <sysfile_getdirentry+0x5e>
ffffffffc0204d54:	85aa                	mv	a1,a0
ffffffffc0204d56:	4705                	li	a4,1
ffffffffc0204d58:	46a1                	li	a3,8
ffffffffc0204d5a:	8652                	mv	a2,s4
ffffffffc0204d5c:	4501                	li	a0,0
ffffffffc0204d5e:	c61fc0ef          	jal	ffffffffc02019be <copy_from_user>
ffffffffc0204d62:	d559                	beqz	a0,ffffffffc0204cf0 <sysfile_getdirentry+0x5c>
ffffffffc0204d64:	854a                	mv	a0,s2
ffffffffc0204d66:	85a2                	mv	a1,s0
ffffffffc0204d68:	113000ef          	jal	ffffffffc020567a <file_getdirentry>
ffffffffc0204d6c:	892a                	mv	s2,a0
ffffffffc0204d6e:	f151                	bnez	a0,ffffffffc0204cf2 <sysfile_getdirentry+0x5e>
ffffffffc0204d70:	85d2                	mv	a1,s4
ffffffffc0204d72:	10800693          	li	a3,264
ffffffffc0204d76:	8622                	mv	a2,s0
ffffffffc0204d78:	c7dfc0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc0204d7c:	f93d                	bnez	a0,ffffffffc0204cf2 <sysfile_getdirentry+0x5e>
ffffffffc0204d7e:	bf8d                	j	ffffffffc0204cf0 <sysfile_getdirentry+0x5c>
ffffffffc0204d80:	5971                	li	s2,-4
ffffffffc0204d82:	bfa5                	j	ffffffffc0204cfa <sysfile_getdirentry+0x66>

ffffffffc0204d84 <sysfile_dup>:
ffffffffc0204d84:	1e50006f          	j	ffffffffc0205768 <file_dup>

ffffffffc0204d88 <get_fd_array.part.0>:
ffffffffc0204d88:	1141                	addi	sp,sp,-16
ffffffffc0204d8a:	00008697          	auipc	a3,0x8
ffffffffc0204d8e:	57668693          	addi	a3,a3,1398 # ffffffffc020d300 <etext+0x1a2a>
ffffffffc0204d92:	00007617          	auipc	a2,0x7
ffffffffc0204d96:	ffe60613          	addi	a2,a2,-2 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204d9a:	45d1                	li	a1,20
ffffffffc0204d9c:	00008517          	auipc	a0,0x8
ffffffffc0204da0:	59450513          	addi	a0,a0,1428 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204da4:	e406                	sd	ra,8(sp)
ffffffffc0204da6:	c86fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204daa <fd_array_alloc>:
ffffffffc0204daa:	00092797          	auipc	a5,0x92
ffffffffc0204dae:	b1e7b783          	ld	a5,-1250(a5) # ffffffffc02968c8 <current>
ffffffffc0204db2:	1141                	addi	sp,sp,-16
ffffffffc0204db4:	e406                	sd	ra,8(sp)
ffffffffc0204db6:	1487b783          	ld	a5,328(a5)
ffffffffc0204dba:	cfb9                	beqz	a5,ffffffffc0204e18 <fd_array_alloc+0x6e>
ffffffffc0204dbc:	4b98                	lw	a4,16(a5)
ffffffffc0204dbe:	04e05d63          	blez	a4,ffffffffc0204e18 <fd_array_alloc+0x6e>
ffffffffc0204dc2:	775d                	lui	a4,0xffff7
ffffffffc0204dc4:	ad970713          	addi	a4,a4,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0204dc8:	679c                	ld	a5,8(a5)
ffffffffc0204dca:	02e50763          	beq	a0,a4,ffffffffc0204df8 <fd_array_alloc+0x4e>
ffffffffc0204dce:	04700713          	li	a4,71
ffffffffc0204dd2:	04a76163          	bltu	a4,a0,ffffffffc0204e14 <fd_array_alloc+0x6a>
ffffffffc0204dd6:	00351713          	slli	a4,a0,0x3
ffffffffc0204dda:	8f09                	sub	a4,a4,a0
ffffffffc0204ddc:	070e                	slli	a4,a4,0x3
ffffffffc0204dde:	97ba                	add	a5,a5,a4
ffffffffc0204de0:	4398                	lw	a4,0(a5)
ffffffffc0204de2:	e71d                	bnez	a4,ffffffffc0204e10 <fd_array_alloc+0x66>
ffffffffc0204de4:	5b88                	lw	a0,48(a5)
ffffffffc0204de6:	e91d                	bnez	a0,ffffffffc0204e1c <fd_array_alloc+0x72>
ffffffffc0204de8:	4705                	li	a4,1
ffffffffc0204dea:	0207b423          	sd	zero,40(a5)
ffffffffc0204dee:	c398                	sw	a4,0(a5)
ffffffffc0204df0:	e19c                	sd	a5,0(a1)
ffffffffc0204df2:	60a2                	ld	ra,8(sp)
ffffffffc0204df4:	0141                	addi	sp,sp,16
ffffffffc0204df6:	8082                	ret
ffffffffc0204df8:	7ff78693          	addi	a3,a5,2047
ffffffffc0204dfc:	7c168693          	addi	a3,a3,1985
ffffffffc0204e00:	4398                	lw	a4,0(a5)
ffffffffc0204e02:	d36d                	beqz	a4,ffffffffc0204de4 <fd_array_alloc+0x3a>
ffffffffc0204e04:	03878793          	addi	a5,a5,56
ffffffffc0204e08:	fed79ce3          	bne	a5,a3,ffffffffc0204e00 <fd_array_alloc+0x56>
ffffffffc0204e0c:	5529                	li	a0,-22
ffffffffc0204e0e:	b7d5                	j	ffffffffc0204df2 <fd_array_alloc+0x48>
ffffffffc0204e10:	5545                	li	a0,-15
ffffffffc0204e12:	b7c5                	j	ffffffffc0204df2 <fd_array_alloc+0x48>
ffffffffc0204e14:	5575                	li	a0,-3
ffffffffc0204e16:	bff1                	j	ffffffffc0204df2 <fd_array_alloc+0x48>
ffffffffc0204e18:	f71ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>
ffffffffc0204e1c:	00008697          	auipc	a3,0x8
ffffffffc0204e20:	52468693          	addi	a3,a3,1316 # ffffffffc020d340 <etext+0x1a6a>
ffffffffc0204e24:	00007617          	auipc	a2,0x7
ffffffffc0204e28:	f6c60613          	addi	a2,a2,-148 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204e2c:	03b00593          	li	a1,59
ffffffffc0204e30:	00008517          	auipc	a0,0x8
ffffffffc0204e34:	50050513          	addi	a0,a0,1280 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204e38:	bf4fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204e3c <fd_array_free>:
ffffffffc0204e3c:	4118                	lw	a4,0(a0)
ffffffffc0204e3e:	1101                	addi	sp,sp,-32
ffffffffc0204e40:	ec06                	sd	ra,24(sp)
ffffffffc0204e42:	4685                	li	a3,1
ffffffffc0204e44:	ffd77613          	andi	a2,a4,-3
ffffffffc0204e48:	04d61763          	bne	a2,a3,ffffffffc0204e96 <fd_array_free+0x5a>
ffffffffc0204e4c:	5914                	lw	a3,48(a0)
ffffffffc0204e4e:	87aa                	mv	a5,a0
ffffffffc0204e50:	e29d                	bnez	a3,ffffffffc0204e76 <fd_array_free+0x3a>
ffffffffc0204e52:	468d                	li	a3,3
ffffffffc0204e54:	00d70763          	beq	a4,a3,ffffffffc0204e62 <fd_array_free+0x26>
ffffffffc0204e58:	60e2                	ld	ra,24(sp)
ffffffffc0204e5a:	0007a023          	sw	zero,0(a5)
ffffffffc0204e5e:	6105                	addi	sp,sp,32
ffffffffc0204e60:	8082                	ret
ffffffffc0204e62:	7508                	ld	a0,40(a0)
ffffffffc0204e64:	e43e                	sd	a5,8(sp)
ffffffffc0204e66:	047030ef          	jal	ffffffffc02086ac <vfs_close>
ffffffffc0204e6a:	67a2                	ld	a5,8(sp)
ffffffffc0204e6c:	60e2                	ld	ra,24(sp)
ffffffffc0204e6e:	0007a023          	sw	zero,0(a5)
ffffffffc0204e72:	6105                	addi	sp,sp,32
ffffffffc0204e74:	8082                	ret
ffffffffc0204e76:	00008697          	auipc	a3,0x8
ffffffffc0204e7a:	4ca68693          	addi	a3,a3,1226 # ffffffffc020d340 <etext+0x1a6a>
ffffffffc0204e7e:	00007617          	auipc	a2,0x7
ffffffffc0204e82:	f1260613          	addi	a2,a2,-238 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204e86:	04500593          	li	a1,69
ffffffffc0204e8a:	00008517          	auipc	a0,0x8
ffffffffc0204e8e:	4a650513          	addi	a0,a0,1190 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204e92:	b9afb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204e96:	00008697          	auipc	a3,0x8
ffffffffc0204e9a:	4e268693          	addi	a3,a3,1250 # ffffffffc020d378 <etext+0x1aa2>
ffffffffc0204e9e:	00007617          	auipc	a2,0x7
ffffffffc0204ea2:	ef260613          	addi	a2,a2,-270 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204ea6:	04400593          	li	a1,68
ffffffffc0204eaa:	00008517          	auipc	a0,0x8
ffffffffc0204eae:	48650513          	addi	a0,a0,1158 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204eb2:	b7afb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204eb6 <fd_array_release>:
ffffffffc0204eb6:	411c                	lw	a5,0(a0)
ffffffffc0204eb8:	1141                	addi	sp,sp,-16
ffffffffc0204eba:	e406                	sd	ra,8(sp)
ffffffffc0204ebc:	4685                	li	a3,1
ffffffffc0204ebe:	37f9                	addiw	a5,a5,-2
ffffffffc0204ec0:	02f6ef63          	bltu	a3,a5,ffffffffc0204efe <fd_array_release+0x48>
ffffffffc0204ec4:	591c                	lw	a5,48(a0)
ffffffffc0204ec6:	00f05c63          	blez	a5,ffffffffc0204ede <fd_array_release+0x28>
ffffffffc0204eca:	37fd                	addiw	a5,a5,-1
ffffffffc0204ecc:	d91c                	sw	a5,48(a0)
ffffffffc0204ece:	c781                	beqz	a5,ffffffffc0204ed6 <fd_array_release+0x20>
ffffffffc0204ed0:	60a2                	ld	ra,8(sp)
ffffffffc0204ed2:	0141                	addi	sp,sp,16
ffffffffc0204ed4:	8082                	ret
ffffffffc0204ed6:	60a2                	ld	ra,8(sp)
ffffffffc0204ed8:	0141                	addi	sp,sp,16
ffffffffc0204eda:	f63ff06f          	j	ffffffffc0204e3c <fd_array_free>
ffffffffc0204ede:	00008697          	auipc	a3,0x8
ffffffffc0204ee2:	50a68693          	addi	a3,a3,1290 # ffffffffc020d3e8 <etext+0x1b12>
ffffffffc0204ee6:	00007617          	auipc	a2,0x7
ffffffffc0204eea:	eaa60613          	addi	a2,a2,-342 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204eee:	05600593          	li	a1,86
ffffffffc0204ef2:	00008517          	auipc	a0,0x8
ffffffffc0204ef6:	43e50513          	addi	a0,a0,1086 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204efa:	b32fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204efe:	00008697          	auipc	a3,0x8
ffffffffc0204f02:	4b268693          	addi	a3,a3,1202 # ffffffffc020d3b0 <etext+0x1ada>
ffffffffc0204f06:	00007617          	auipc	a2,0x7
ffffffffc0204f0a:	e8a60613          	addi	a2,a2,-374 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204f0e:	05500593          	li	a1,85
ffffffffc0204f12:	00008517          	auipc	a0,0x8
ffffffffc0204f16:	41e50513          	addi	a0,a0,1054 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204f1a:	b12fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204f1e <fd_array_open.part.0>:
ffffffffc0204f1e:	1141                	addi	sp,sp,-16
ffffffffc0204f20:	00008697          	auipc	a3,0x8
ffffffffc0204f24:	4e068693          	addi	a3,a3,1248 # ffffffffc020d400 <etext+0x1b2a>
ffffffffc0204f28:	00007617          	auipc	a2,0x7
ffffffffc0204f2c:	e6860613          	addi	a2,a2,-408 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204f30:	05f00593          	li	a1,95
ffffffffc0204f34:	00008517          	auipc	a0,0x8
ffffffffc0204f38:	3fc50513          	addi	a0,a0,1020 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204f3c:	e406                	sd	ra,8(sp)
ffffffffc0204f3e:	aeefb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204f42 <fd_array_init>:
ffffffffc0204f42:	4781                	li	a5,0
ffffffffc0204f44:	04800713          	li	a4,72
ffffffffc0204f48:	cd1c                	sw	a5,24(a0)
ffffffffc0204f4a:	02052823          	sw	zero,48(a0)
ffffffffc0204f4e:	00052023          	sw	zero,0(a0)
ffffffffc0204f52:	2785                	addiw	a5,a5,1
ffffffffc0204f54:	03850513          	addi	a0,a0,56
ffffffffc0204f58:	fee798e3          	bne	a5,a4,ffffffffc0204f48 <fd_array_init+0x6>
ffffffffc0204f5c:	8082                	ret

ffffffffc0204f5e <fd_array_close>:
ffffffffc0204f5e:	4114                	lw	a3,0(a0)
ffffffffc0204f60:	1101                	addi	sp,sp,-32
ffffffffc0204f62:	ec06                	sd	ra,24(sp)
ffffffffc0204f64:	4789                	li	a5,2
ffffffffc0204f66:	04f69863          	bne	a3,a5,ffffffffc0204fb6 <fd_array_close+0x58>
ffffffffc0204f6a:	591c                	lw	a5,48(a0)
ffffffffc0204f6c:	872a                	mv	a4,a0
ffffffffc0204f6e:	02f05463          	blez	a5,ffffffffc0204f96 <fd_array_close+0x38>
ffffffffc0204f72:	37fd                	addiw	a5,a5,-1
ffffffffc0204f74:	468d                	li	a3,3
ffffffffc0204f76:	d91c                	sw	a5,48(a0)
ffffffffc0204f78:	c114                	sw	a3,0(a0)
ffffffffc0204f7a:	c781                	beqz	a5,ffffffffc0204f82 <fd_array_close+0x24>
ffffffffc0204f7c:	60e2                	ld	ra,24(sp)
ffffffffc0204f7e:	6105                	addi	sp,sp,32
ffffffffc0204f80:	8082                	ret
ffffffffc0204f82:	7508                	ld	a0,40(a0)
ffffffffc0204f84:	e43a                	sd	a4,8(sp)
ffffffffc0204f86:	726030ef          	jal	ffffffffc02086ac <vfs_close>
ffffffffc0204f8a:	6722                	ld	a4,8(sp)
ffffffffc0204f8c:	60e2                	ld	ra,24(sp)
ffffffffc0204f8e:	00072023          	sw	zero,0(a4)
ffffffffc0204f92:	6105                	addi	sp,sp,32
ffffffffc0204f94:	8082                	ret
ffffffffc0204f96:	00008697          	auipc	a3,0x8
ffffffffc0204f9a:	45268693          	addi	a3,a3,1106 # ffffffffc020d3e8 <etext+0x1b12>
ffffffffc0204f9e:	00007617          	auipc	a2,0x7
ffffffffc0204fa2:	df260613          	addi	a2,a2,-526 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204fa6:	06800593          	li	a1,104
ffffffffc0204faa:	00008517          	auipc	a0,0x8
ffffffffc0204fae:	38650513          	addi	a0,a0,902 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204fb2:	a7afb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0204fb6:	00008697          	auipc	a3,0x8
ffffffffc0204fba:	3a268693          	addi	a3,a3,930 # ffffffffc020d358 <etext+0x1a82>
ffffffffc0204fbe:	00007617          	auipc	a2,0x7
ffffffffc0204fc2:	dd260613          	addi	a2,a2,-558 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0204fc6:	06700593          	li	a1,103
ffffffffc0204fca:	00008517          	auipc	a0,0x8
ffffffffc0204fce:	36650513          	addi	a0,a0,870 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0204fd2:	a5afb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0204fd6 <fd_array_dup>:
ffffffffc0204fd6:	4118                	lw	a4,0(a0)
ffffffffc0204fd8:	1101                	addi	sp,sp,-32
ffffffffc0204fda:	ec06                	sd	ra,24(sp)
ffffffffc0204fdc:	e822                	sd	s0,16(sp)
ffffffffc0204fde:	e426                	sd	s1,8(sp)
ffffffffc0204fe0:	e04a                	sd	s2,0(sp)
ffffffffc0204fe2:	4785                	li	a5,1
ffffffffc0204fe4:	04f71563          	bne	a4,a5,ffffffffc020502e <fd_array_dup+0x58>
ffffffffc0204fe8:	0005a903          	lw	s2,0(a1)
ffffffffc0204fec:	4789                	li	a5,2
ffffffffc0204fee:	04f91063          	bne	s2,a5,ffffffffc020502e <fd_array_dup+0x58>
ffffffffc0204ff2:	719c                	ld	a5,32(a1)
ffffffffc0204ff4:	7584                	ld	s1,40(a1)
ffffffffc0204ff6:	842a                	mv	s0,a0
ffffffffc0204ff8:	f11c                	sd	a5,32(a0)
ffffffffc0204ffa:	699c                	ld	a5,16(a1)
ffffffffc0204ffc:	6598                	ld	a4,8(a1)
ffffffffc0204ffe:	8526                	mv	a0,s1
ffffffffc0205000:	e81c                	sd	a5,16(s0)
ffffffffc0205002:	e418                	sd	a4,8(s0)
ffffffffc0205004:	2d2030ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0205008:	8526                	mv	a0,s1
ffffffffc020500a:	2d6030ef          	jal	ffffffffc02082e0 <inode_open_inc>
ffffffffc020500e:	401c                	lw	a5,0(s0)
ffffffffc0205010:	f404                	sd	s1,40(s0)
ffffffffc0205012:	17fd                	addi	a5,a5,-1
ffffffffc0205014:	ef8d                	bnez	a5,ffffffffc020504e <fd_array_dup+0x78>
ffffffffc0205016:	cc85                	beqz	s1,ffffffffc020504e <fd_array_dup+0x78>
ffffffffc0205018:	581c                	lw	a5,48(s0)
ffffffffc020501a:	01242023          	sw	s2,0(s0)
ffffffffc020501e:	60e2                	ld	ra,24(sp)
ffffffffc0205020:	2785                	addiw	a5,a5,1
ffffffffc0205022:	d81c                	sw	a5,48(s0)
ffffffffc0205024:	6442                	ld	s0,16(sp)
ffffffffc0205026:	64a2                	ld	s1,8(sp)
ffffffffc0205028:	6902                	ld	s2,0(sp)
ffffffffc020502a:	6105                	addi	sp,sp,32
ffffffffc020502c:	8082                	ret
ffffffffc020502e:	00008697          	auipc	a3,0x8
ffffffffc0205032:	40268693          	addi	a3,a3,1026 # ffffffffc020d430 <etext+0x1b5a>
ffffffffc0205036:	00007617          	auipc	a2,0x7
ffffffffc020503a:	d5a60613          	addi	a2,a2,-678 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020503e:	07300593          	li	a1,115
ffffffffc0205042:	00008517          	auipc	a0,0x8
ffffffffc0205046:	2ee50513          	addi	a0,a0,750 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc020504a:	9e2fb0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020504e:	ed1ff0ef          	jal	ffffffffc0204f1e <fd_array_open.part.0>

ffffffffc0205052 <file_testfd>:
ffffffffc0205052:	04700793          	li	a5,71
ffffffffc0205056:	04a7e263          	bltu	a5,a0,ffffffffc020509a <file_testfd+0x48>
ffffffffc020505a:	00092797          	auipc	a5,0x92
ffffffffc020505e:	86e7b783          	ld	a5,-1938(a5) # ffffffffc02968c8 <current>
ffffffffc0205062:	1487b783          	ld	a5,328(a5)
ffffffffc0205066:	cf85                	beqz	a5,ffffffffc020509e <file_testfd+0x4c>
ffffffffc0205068:	4b98                	lw	a4,16(a5)
ffffffffc020506a:	02e05a63          	blez	a4,ffffffffc020509e <file_testfd+0x4c>
ffffffffc020506e:	6798                	ld	a4,8(a5)
ffffffffc0205070:	00351793          	slli	a5,a0,0x3
ffffffffc0205074:	8f89                	sub	a5,a5,a0
ffffffffc0205076:	078e                	slli	a5,a5,0x3
ffffffffc0205078:	97ba                	add	a5,a5,a4
ffffffffc020507a:	4394                	lw	a3,0(a5)
ffffffffc020507c:	4709                	li	a4,2
ffffffffc020507e:	00e69e63          	bne	a3,a4,ffffffffc020509a <file_testfd+0x48>
ffffffffc0205082:	4f98                	lw	a4,24(a5)
ffffffffc0205084:	00a71b63          	bne	a4,a0,ffffffffc020509a <file_testfd+0x48>
ffffffffc0205088:	c199                	beqz	a1,ffffffffc020508e <file_testfd+0x3c>
ffffffffc020508a:	6788                	ld	a0,8(a5)
ffffffffc020508c:	c901                	beqz	a0,ffffffffc020509c <file_testfd+0x4a>
ffffffffc020508e:	4505                	li	a0,1
ffffffffc0205090:	c611                	beqz	a2,ffffffffc020509c <file_testfd+0x4a>
ffffffffc0205092:	6b88                	ld	a0,16(a5)
ffffffffc0205094:	00a03533          	snez	a0,a0
ffffffffc0205098:	8082                	ret
ffffffffc020509a:	4501                	li	a0,0
ffffffffc020509c:	8082                	ret
ffffffffc020509e:	1141                	addi	sp,sp,-16
ffffffffc02050a0:	e406                	sd	ra,8(sp)
ffffffffc02050a2:	ce7ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc02050a6 <file_open>:
ffffffffc02050a6:	0035f793          	andi	a5,a1,3
ffffffffc02050aa:	470d                	li	a4,3
ffffffffc02050ac:	0ee78563          	beq	a5,a4,ffffffffc0205196 <file_open+0xf0>
ffffffffc02050b0:	078e                	slli	a5,a5,0x3
ffffffffc02050b2:	0000a717          	auipc	a4,0xa
ffffffffc02050b6:	f2e70713          	addi	a4,a4,-210 # ffffffffc020efe0 <CSWTCH.79>
ffffffffc02050ba:	0000a697          	auipc	a3,0xa
ffffffffc02050be:	f3e68693          	addi	a3,a3,-194 # ffffffffc020eff8 <CSWTCH.78>
ffffffffc02050c2:	96be                	add	a3,a3,a5
ffffffffc02050c4:	97ba                	add	a5,a5,a4
ffffffffc02050c6:	7159                	addi	sp,sp,-112
ffffffffc02050c8:	639c                	ld	a5,0(a5)
ffffffffc02050ca:	6298                	ld	a4,0(a3)
ffffffffc02050cc:	eca6                	sd	s1,88(sp)
ffffffffc02050ce:	84aa                	mv	s1,a0
ffffffffc02050d0:	755d                	lui	a0,0xffff7
ffffffffc02050d2:	f0a2                	sd	s0,96(sp)
ffffffffc02050d4:	ad950513          	addi	a0,a0,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc02050d8:	842e                	mv	s0,a1
ffffffffc02050da:	080c                	addi	a1,sp,16
ffffffffc02050dc:	e8ca                	sd	s2,80(sp)
ffffffffc02050de:	e4ce                	sd	s3,72(sp)
ffffffffc02050e0:	f486                	sd	ra,104(sp)
ffffffffc02050e2:	89be                	mv	s3,a5
ffffffffc02050e4:	893a                	mv	s2,a4
ffffffffc02050e6:	cc5ff0ef          	jal	ffffffffc0204daa <fd_array_alloc>
ffffffffc02050ea:	87aa                	mv	a5,a0
ffffffffc02050ec:	c909                	beqz	a0,ffffffffc02050fe <file_open+0x58>
ffffffffc02050ee:	70a6                	ld	ra,104(sp)
ffffffffc02050f0:	7406                	ld	s0,96(sp)
ffffffffc02050f2:	64e6                	ld	s1,88(sp)
ffffffffc02050f4:	6946                	ld	s2,80(sp)
ffffffffc02050f6:	69a6                	ld	s3,72(sp)
ffffffffc02050f8:	853e                	mv	a0,a5
ffffffffc02050fa:	6165                	addi	sp,sp,112
ffffffffc02050fc:	8082                	ret
ffffffffc02050fe:	8526                	mv	a0,s1
ffffffffc0205100:	0830                	addi	a2,sp,24
ffffffffc0205102:	85a2                	mv	a1,s0
ffffffffc0205104:	3d2030ef          	jal	ffffffffc02084d6 <vfs_open>
ffffffffc0205108:	6742                	ld	a4,16(sp)
ffffffffc020510a:	e141                	bnez	a0,ffffffffc020518a <file_open+0xe4>
ffffffffc020510c:	02073023          	sd	zero,32(a4)
ffffffffc0205110:	02047593          	andi	a1,s0,32
ffffffffc0205114:	c98d                	beqz	a1,ffffffffc0205146 <file_open+0xa0>
ffffffffc0205116:	6562                	ld	a0,24(sp)
ffffffffc0205118:	c541                	beqz	a0,ffffffffc02051a0 <file_open+0xfa>
ffffffffc020511a:	793c                	ld	a5,112(a0)
ffffffffc020511c:	c3d1                	beqz	a5,ffffffffc02051a0 <file_open+0xfa>
ffffffffc020511e:	779c                	ld	a5,40(a5)
ffffffffc0205120:	c3c1                	beqz	a5,ffffffffc02051a0 <file_open+0xfa>
ffffffffc0205122:	00008597          	auipc	a1,0x8
ffffffffc0205126:	39658593          	addi	a1,a1,918 # ffffffffc020d4b8 <etext+0x1be2>
ffffffffc020512a:	e43a                	sd	a4,8(sp)
ffffffffc020512c:	e02a                	sd	a0,0(sp)
ffffffffc020512e:	1bc030ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0205132:	6502                	ld	a0,0(sp)
ffffffffc0205134:	100c                	addi	a1,sp,32
ffffffffc0205136:	793c                	ld	a5,112(a0)
ffffffffc0205138:	6562                	ld	a0,24(sp)
ffffffffc020513a:	779c                	ld	a5,40(a5)
ffffffffc020513c:	9782                	jalr	a5
ffffffffc020513e:	6722                	ld	a4,8(sp)
ffffffffc0205140:	e91d                	bnez	a0,ffffffffc0205176 <file_open+0xd0>
ffffffffc0205142:	77e2                	ld	a5,56(sp)
ffffffffc0205144:	f31c                	sd	a5,32(a4)
ffffffffc0205146:	66e2                	ld	a3,24(sp)
ffffffffc0205148:	431c                	lw	a5,0(a4)
ffffffffc020514a:	01273423          	sd	s2,8(a4)
ffffffffc020514e:	01373823          	sd	s3,16(a4)
ffffffffc0205152:	f714                	sd	a3,40(a4)
ffffffffc0205154:	17fd                	addi	a5,a5,-1
ffffffffc0205156:	e3b9                	bnez	a5,ffffffffc020519c <file_open+0xf6>
ffffffffc0205158:	c2b1                	beqz	a3,ffffffffc020519c <file_open+0xf6>
ffffffffc020515a:	5b1c                	lw	a5,48(a4)
ffffffffc020515c:	70a6                	ld	ra,104(sp)
ffffffffc020515e:	7406                	ld	s0,96(sp)
ffffffffc0205160:	2785                	addiw	a5,a5,1
ffffffffc0205162:	db1c                	sw	a5,48(a4)
ffffffffc0205164:	4f1c                	lw	a5,24(a4)
ffffffffc0205166:	4689                	li	a3,2
ffffffffc0205168:	c314                	sw	a3,0(a4)
ffffffffc020516a:	64e6                	ld	s1,88(sp)
ffffffffc020516c:	6946                	ld	s2,80(sp)
ffffffffc020516e:	69a6                	ld	s3,72(sp)
ffffffffc0205170:	853e                	mv	a0,a5
ffffffffc0205172:	6165                	addi	sp,sp,112
ffffffffc0205174:	8082                	ret
ffffffffc0205176:	e42a                	sd	a0,8(sp)
ffffffffc0205178:	6562                	ld	a0,24(sp)
ffffffffc020517a:	e03a                	sd	a4,0(sp)
ffffffffc020517c:	530030ef          	jal	ffffffffc02086ac <vfs_close>
ffffffffc0205180:	6502                	ld	a0,0(sp)
ffffffffc0205182:	cbbff0ef          	jal	ffffffffc0204e3c <fd_array_free>
ffffffffc0205186:	67a2                	ld	a5,8(sp)
ffffffffc0205188:	b79d                	j	ffffffffc02050ee <file_open+0x48>
ffffffffc020518a:	e02a                	sd	a0,0(sp)
ffffffffc020518c:	853a                	mv	a0,a4
ffffffffc020518e:	cafff0ef          	jal	ffffffffc0204e3c <fd_array_free>
ffffffffc0205192:	6782                	ld	a5,0(sp)
ffffffffc0205194:	bfa9                	j	ffffffffc02050ee <file_open+0x48>
ffffffffc0205196:	57f5                	li	a5,-3
ffffffffc0205198:	853e                	mv	a0,a5
ffffffffc020519a:	8082                	ret
ffffffffc020519c:	d83ff0ef          	jal	ffffffffc0204f1e <fd_array_open.part.0>
ffffffffc02051a0:	00008697          	auipc	a3,0x8
ffffffffc02051a4:	2c868693          	addi	a3,a3,712 # ffffffffc020d468 <etext+0x1b92>
ffffffffc02051a8:	00007617          	auipc	a2,0x7
ffffffffc02051ac:	be860613          	addi	a2,a2,-1048 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02051b0:	0b500593          	li	a1,181
ffffffffc02051b4:	00008517          	auipc	a0,0x8
ffffffffc02051b8:	17c50513          	addi	a0,a0,380 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc02051bc:	870fb0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02051c0 <file_close>:
ffffffffc02051c0:	04700793          	li	a5,71
ffffffffc02051c4:	04a7e663          	bltu	a5,a0,ffffffffc0205210 <file_close+0x50>
ffffffffc02051c8:	00091717          	auipc	a4,0x91
ffffffffc02051cc:	70073703          	ld	a4,1792(a4) # ffffffffc02968c8 <current>
ffffffffc02051d0:	1141                	addi	sp,sp,-16
ffffffffc02051d2:	e406                	sd	ra,8(sp)
ffffffffc02051d4:	14873703          	ld	a4,328(a4)
ffffffffc02051d8:	87aa                	mv	a5,a0
ffffffffc02051da:	cf0d                	beqz	a4,ffffffffc0205214 <file_close+0x54>
ffffffffc02051dc:	4b14                	lw	a3,16(a4)
ffffffffc02051de:	02d05b63          	blez	a3,ffffffffc0205214 <file_close+0x54>
ffffffffc02051e2:	6708                	ld	a0,8(a4)
ffffffffc02051e4:	00379713          	slli	a4,a5,0x3
ffffffffc02051e8:	8f1d                	sub	a4,a4,a5
ffffffffc02051ea:	070e                	slli	a4,a4,0x3
ffffffffc02051ec:	953a                	add	a0,a0,a4
ffffffffc02051ee:	4114                	lw	a3,0(a0)
ffffffffc02051f0:	4709                	li	a4,2
ffffffffc02051f2:	00e69b63          	bne	a3,a4,ffffffffc0205208 <file_close+0x48>
ffffffffc02051f6:	4d18                	lw	a4,24(a0)
ffffffffc02051f8:	00f71863          	bne	a4,a5,ffffffffc0205208 <file_close+0x48>
ffffffffc02051fc:	d63ff0ef          	jal	ffffffffc0204f5e <fd_array_close>
ffffffffc0205200:	60a2                	ld	ra,8(sp)
ffffffffc0205202:	4501                	li	a0,0
ffffffffc0205204:	0141                	addi	sp,sp,16
ffffffffc0205206:	8082                	ret
ffffffffc0205208:	60a2                	ld	ra,8(sp)
ffffffffc020520a:	5575                	li	a0,-3
ffffffffc020520c:	0141                	addi	sp,sp,16
ffffffffc020520e:	8082                	ret
ffffffffc0205210:	5575                	li	a0,-3
ffffffffc0205212:	8082                	ret
ffffffffc0205214:	b75ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc0205218 <file_read>:
ffffffffc0205218:	711d                	addi	sp,sp,-96
ffffffffc020521a:	ec86                	sd	ra,88(sp)
ffffffffc020521c:	e0ca                	sd	s2,64(sp)
ffffffffc020521e:	0006b023          	sd	zero,0(a3)
ffffffffc0205222:	04700793          	li	a5,71
ffffffffc0205226:	0aa7ec63          	bltu	a5,a0,ffffffffc02052de <file_read+0xc6>
ffffffffc020522a:	00091797          	auipc	a5,0x91
ffffffffc020522e:	69e7b783          	ld	a5,1694(a5) # ffffffffc02968c8 <current>
ffffffffc0205232:	e4a6                	sd	s1,72(sp)
ffffffffc0205234:	e8a2                	sd	s0,80(sp)
ffffffffc0205236:	1487b783          	ld	a5,328(a5)
ffffffffc020523a:	fc4e                	sd	s3,56(sp)
ffffffffc020523c:	84b6                	mv	s1,a3
ffffffffc020523e:	c3f1                	beqz	a5,ffffffffc0205302 <file_read+0xea>
ffffffffc0205240:	4b98                	lw	a4,16(a5)
ffffffffc0205242:	0ce05063          	blez	a4,ffffffffc0205302 <file_read+0xea>
ffffffffc0205246:	6780                	ld	s0,8(a5)
ffffffffc0205248:	00351793          	slli	a5,a0,0x3
ffffffffc020524c:	8f89                	sub	a5,a5,a0
ffffffffc020524e:	078e                	slli	a5,a5,0x3
ffffffffc0205250:	943e                	add	s0,s0,a5
ffffffffc0205252:	00042983          	lw	s3,0(s0)
ffffffffc0205256:	4789                	li	a5,2
ffffffffc0205258:	06f99a63          	bne	s3,a5,ffffffffc02052cc <file_read+0xb4>
ffffffffc020525c:	4c1c                	lw	a5,24(s0)
ffffffffc020525e:	06a79763          	bne	a5,a0,ffffffffc02052cc <file_read+0xb4>
ffffffffc0205262:	641c                	ld	a5,8(s0)
ffffffffc0205264:	c7a5                	beqz	a5,ffffffffc02052cc <file_read+0xb4>
ffffffffc0205266:	581c                	lw	a5,48(s0)
ffffffffc0205268:	7014                	ld	a3,32(s0)
ffffffffc020526a:	0808                	addi	a0,sp,16
ffffffffc020526c:	2785                	addiw	a5,a5,1
ffffffffc020526e:	d81c                	sw	a5,48(s0)
ffffffffc0205270:	58c000ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc0205274:	892a                	mv	s2,a0
ffffffffc0205276:	7408                	ld	a0,40(s0)
ffffffffc0205278:	c52d                	beqz	a0,ffffffffc02052e2 <file_read+0xca>
ffffffffc020527a:	793c                	ld	a5,112(a0)
ffffffffc020527c:	c3bd                	beqz	a5,ffffffffc02052e2 <file_read+0xca>
ffffffffc020527e:	6f9c                	ld	a5,24(a5)
ffffffffc0205280:	c3ad                	beqz	a5,ffffffffc02052e2 <file_read+0xca>
ffffffffc0205282:	00008597          	auipc	a1,0x8
ffffffffc0205286:	28e58593          	addi	a1,a1,654 # ffffffffc020d510 <etext+0x1c3a>
ffffffffc020528a:	e42a                	sd	a0,8(sp)
ffffffffc020528c:	05e030ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0205290:	6522                	ld	a0,8(sp)
ffffffffc0205292:	85ca                	mv	a1,s2
ffffffffc0205294:	793c                	ld	a5,112(a0)
ffffffffc0205296:	7408                	ld	a0,40(s0)
ffffffffc0205298:	6f9c                	ld	a5,24(a5)
ffffffffc020529a:	9782                	jalr	a5
ffffffffc020529c:	01093783          	ld	a5,16(s2)
ffffffffc02052a0:	01893683          	ld	a3,24(s2)
ffffffffc02052a4:	4018                	lw	a4,0(s0)
ffffffffc02052a6:	892a                	mv	s2,a0
ffffffffc02052a8:	8f95                	sub	a5,a5,a3
ffffffffc02052aa:	01371563          	bne	a4,s3,ffffffffc02052b4 <file_read+0x9c>
ffffffffc02052ae:	7018                	ld	a4,32(s0)
ffffffffc02052b0:	973e                	add	a4,a4,a5
ffffffffc02052b2:	f018                	sd	a4,32(s0)
ffffffffc02052b4:	e09c                	sd	a5,0(s1)
ffffffffc02052b6:	8522                	mv	a0,s0
ffffffffc02052b8:	bffff0ef          	jal	ffffffffc0204eb6 <fd_array_release>
ffffffffc02052bc:	6446                	ld	s0,80(sp)
ffffffffc02052be:	64a6                	ld	s1,72(sp)
ffffffffc02052c0:	79e2                	ld	s3,56(sp)
ffffffffc02052c2:	60e6                	ld	ra,88(sp)
ffffffffc02052c4:	854a                	mv	a0,s2
ffffffffc02052c6:	6906                	ld	s2,64(sp)
ffffffffc02052c8:	6125                	addi	sp,sp,96
ffffffffc02052ca:	8082                	ret
ffffffffc02052cc:	6446                	ld	s0,80(sp)
ffffffffc02052ce:	60e6                	ld	ra,88(sp)
ffffffffc02052d0:	5975                	li	s2,-3
ffffffffc02052d2:	64a6                	ld	s1,72(sp)
ffffffffc02052d4:	79e2                	ld	s3,56(sp)
ffffffffc02052d6:	854a                	mv	a0,s2
ffffffffc02052d8:	6906                	ld	s2,64(sp)
ffffffffc02052da:	6125                	addi	sp,sp,96
ffffffffc02052dc:	8082                	ret
ffffffffc02052de:	5975                	li	s2,-3
ffffffffc02052e0:	b7cd                	j	ffffffffc02052c2 <file_read+0xaa>
ffffffffc02052e2:	00008697          	auipc	a3,0x8
ffffffffc02052e6:	1de68693          	addi	a3,a3,478 # ffffffffc020d4c0 <etext+0x1bea>
ffffffffc02052ea:	00007617          	auipc	a2,0x7
ffffffffc02052ee:	aa660613          	addi	a2,a2,-1370 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02052f2:	0de00593          	li	a1,222
ffffffffc02052f6:	00008517          	auipc	a0,0x8
ffffffffc02052fa:	03a50513          	addi	a0,a0,58 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc02052fe:	f2ffa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0205302:	a87ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc0205306 <file_write>:
ffffffffc0205306:	711d                	addi	sp,sp,-96
ffffffffc0205308:	ec86                	sd	ra,88(sp)
ffffffffc020530a:	e0ca                	sd	s2,64(sp)
ffffffffc020530c:	0006b023          	sd	zero,0(a3)
ffffffffc0205310:	04700793          	li	a5,71
ffffffffc0205314:	0aa7ec63          	bltu	a5,a0,ffffffffc02053cc <file_write+0xc6>
ffffffffc0205318:	00091797          	auipc	a5,0x91
ffffffffc020531c:	5b07b783          	ld	a5,1456(a5) # ffffffffc02968c8 <current>
ffffffffc0205320:	e4a6                	sd	s1,72(sp)
ffffffffc0205322:	e8a2                	sd	s0,80(sp)
ffffffffc0205324:	1487b783          	ld	a5,328(a5)
ffffffffc0205328:	fc4e                	sd	s3,56(sp)
ffffffffc020532a:	84b6                	mv	s1,a3
ffffffffc020532c:	c3f1                	beqz	a5,ffffffffc02053f0 <file_write+0xea>
ffffffffc020532e:	4b98                	lw	a4,16(a5)
ffffffffc0205330:	0ce05063          	blez	a4,ffffffffc02053f0 <file_write+0xea>
ffffffffc0205334:	6780                	ld	s0,8(a5)
ffffffffc0205336:	00351793          	slli	a5,a0,0x3
ffffffffc020533a:	8f89                	sub	a5,a5,a0
ffffffffc020533c:	078e                	slli	a5,a5,0x3
ffffffffc020533e:	943e                	add	s0,s0,a5
ffffffffc0205340:	00042983          	lw	s3,0(s0)
ffffffffc0205344:	4789                	li	a5,2
ffffffffc0205346:	06f99a63          	bne	s3,a5,ffffffffc02053ba <file_write+0xb4>
ffffffffc020534a:	4c1c                	lw	a5,24(s0)
ffffffffc020534c:	06a79763          	bne	a5,a0,ffffffffc02053ba <file_write+0xb4>
ffffffffc0205350:	681c                	ld	a5,16(s0)
ffffffffc0205352:	c7a5                	beqz	a5,ffffffffc02053ba <file_write+0xb4>
ffffffffc0205354:	581c                	lw	a5,48(s0)
ffffffffc0205356:	7014                	ld	a3,32(s0)
ffffffffc0205358:	0808                	addi	a0,sp,16
ffffffffc020535a:	2785                	addiw	a5,a5,1
ffffffffc020535c:	d81c                	sw	a5,48(s0)
ffffffffc020535e:	49e000ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc0205362:	892a                	mv	s2,a0
ffffffffc0205364:	7408                	ld	a0,40(s0)
ffffffffc0205366:	c52d                	beqz	a0,ffffffffc02053d0 <file_write+0xca>
ffffffffc0205368:	793c                	ld	a5,112(a0)
ffffffffc020536a:	c3bd                	beqz	a5,ffffffffc02053d0 <file_write+0xca>
ffffffffc020536c:	739c                	ld	a5,32(a5)
ffffffffc020536e:	c3ad                	beqz	a5,ffffffffc02053d0 <file_write+0xca>
ffffffffc0205370:	00008597          	auipc	a1,0x8
ffffffffc0205374:	1f858593          	addi	a1,a1,504 # ffffffffc020d568 <etext+0x1c92>
ffffffffc0205378:	e42a                	sd	a0,8(sp)
ffffffffc020537a:	771020ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020537e:	6522                	ld	a0,8(sp)
ffffffffc0205380:	85ca                	mv	a1,s2
ffffffffc0205382:	793c                	ld	a5,112(a0)
ffffffffc0205384:	7408                	ld	a0,40(s0)
ffffffffc0205386:	739c                	ld	a5,32(a5)
ffffffffc0205388:	9782                	jalr	a5
ffffffffc020538a:	01093783          	ld	a5,16(s2)
ffffffffc020538e:	01893683          	ld	a3,24(s2)
ffffffffc0205392:	4018                	lw	a4,0(s0)
ffffffffc0205394:	892a                	mv	s2,a0
ffffffffc0205396:	8f95                	sub	a5,a5,a3
ffffffffc0205398:	01371563          	bne	a4,s3,ffffffffc02053a2 <file_write+0x9c>
ffffffffc020539c:	7018                	ld	a4,32(s0)
ffffffffc020539e:	973e                	add	a4,a4,a5
ffffffffc02053a0:	f018                	sd	a4,32(s0)
ffffffffc02053a2:	e09c                	sd	a5,0(s1)
ffffffffc02053a4:	8522                	mv	a0,s0
ffffffffc02053a6:	b11ff0ef          	jal	ffffffffc0204eb6 <fd_array_release>
ffffffffc02053aa:	6446                	ld	s0,80(sp)
ffffffffc02053ac:	64a6                	ld	s1,72(sp)
ffffffffc02053ae:	79e2                	ld	s3,56(sp)
ffffffffc02053b0:	60e6                	ld	ra,88(sp)
ffffffffc02053b2:	854a                	mv	a0,s2
ffffffffc02053b4:	6906                	ld	s2,64(sp)
ffffffffc02053b6:	6125                	addi	sp,sp,96
ffffffffc02053b8:	8082                	ret
ffffffffc02053ba:	6446                	ld	s0,80(sp)
ffffffffc02053bc:	60e6                	ld	ra,88(sp)
ffffffffc02053be:	5975                	li	s2,-3
ffffffffc02053c0:	64a6                	ld	s1,72(sp)
ffffffffc02053c2:	79e2                	ld	s3,56(sp)
ffffffffc02053c4:	854a                	mv	a0,s2
ffffffffc02053c6:	6906                	ld	s2,64(sp)
ffffffffc02053c8:	6125                	addi	sp,sp,96
ffffffffc02053ca:	8082                	ret
ffffffffc02053cc:	5975                	li	s2,-3
ffffffffc02053ce:	b7cd                	j	ffffffffc02053b0 <file_write+0xaa>
ffffffffc02053d0:	00008697          	auipc	a3,0x8
ffffffffc02053d4:	14868693          	addi	a3,a3,328 # ffffffffc020d518 <etext+0x1c42>
ffffffffc02053d8:	00007617          	auipc	a2,0x7
ffffffffc02053dc:	9b860613          	addi	a2,a2,-1608 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02053e0:	0f800593          	li	a1,248
ffffffffc02053e4:	00008517          	auipc	a0,0x8
ffffffffc02053e8:	f4c50513          	addi	a0,a0,-180 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc02053ec:	e41fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02053f0:	999ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc02053f4 <file_seek>:
ffffffffc02053f4:	7139                	addi	sp,sp,-64
ffffffffc02053f6:	fc06                	sd	ra,56(sp)
ffffffffc02053f8:	f426                	sd	s1,40(sp)
ffffffffc02053fa:	04700793          	li	a5,71
ffffffffc02053fe:	0ca7e563          	bltu	a5,a0,ffffffffc02054c8 <file_seek+0xd4>
ffffffffc0205402:	00091797          	auipc	a5,0x91
ffffffffc0205406:	4c67b783          	ld	a5,1222(a5) # ffffffffc02968c8 <current>
ffffffffc020540a:	f822                	sd	s0,48(sp)
ffffffffc020540c:	1487b783          	ld	a5,328(a5)
ffffffffc0205410:	c3e9                	beqz	a5,ffffffffc02054d2 <file_seek+0xde>
ffffffffc0205412:	4b98                	lw	a4,16(a5)
ffffffffc0205414:	0ae05f63          	blez	a4,ffffffffc02054d2 <file_seek+0xde>
ffffffffc0205418:	6780                	ld	s0,8(a5)
ffffffffc020541a:	00351793          	slli	a5,a0,0x3
ffffffffc020541e:	8f89                	sub	a5,a5,a0
ffffffffc0205420:	078e                	slli	a5,a5,0x3
ffffffffc0205422:	943e                	add	s0,s0,a5
ffffffffc0205424:	4018                	lw	a4,0(s0)
ffffffffc0205426:	4789                	li	a5,2
ffffffffc0205428:	0af71263          	bne	a4,a5,ffffffffc02054cc <file_seek+0xd8>
ffffffffc020542c:	4c1c                	lw	a5,24(s0)
ffffffffc020542e:	f04a                	sd	s2,32(sp)
ffffffffc0205430:	08a79863          	bne	a5,a0,ffffffffc02054c0 <file_seek+0xcc>
ffffffffc0205434:	581c                	lw	a5,48(s0)
ffffffffc0205436:	4685                	li	a3,1
ffffffffc0205438:	892e                	mv	s2,a1
ffffffffc020543a:	2785                	addiw	a5,a5,1
ffffffffc020543c:	d81c                	sw	a5,48(s0)
ffffffffc020543e:	06d60d63          	beq	a2,a3,ffffffffc02054b8 <file_seek+0xc4>
ffffffffc0205442:	04e60463          	beq	a2,a4,ffffffffc020548a <file_seek+0x96>
ffffffffc0205446:	54f5                	li	s1,-3
ffffffffc0205448:	e61d                	bnez	a2,ffffffffc0205476 <file_seek+0x82>
ffffffffc020544a:	7404                	ld	s1,40(s0)
ffffffffc020544c:	c4d1                	beqz	s1,ffffffffc02054d8 <file_seek+0xe4>
ffffffffc020544e:	78bc                	ld	a5,112(s1)
ffffffffc0205450:	c7c1                	beqz	a5,ffffffffc02054d8 <file_seek+0xe4>
ffffffffc0205452:	6fbc                	ld	a5,88(a5)
ffffffffc0205454:	c3d1                	beqz	a5,ffffffffc02054d8 <file_seek+0xe4>
ffffffffc0205456:	8526                	mv	a0,s1
ffffffffc0205458:	00008597          	auipc	a1,0x8
ffffffffc020545c:	16858593          	addi	a1,a1,360 # ffffffffc020d5c0 <etext+0x1cea>
ffffffffc0205460:	68b020ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0205464:	78bc                	ld	a5,112(s1)
ffffffffc0205466:	7408                	ld	a0,40(s0)
ffffffffc0205468:	85ca                	mv	a1,s2
ffffffffc020546a:	6fbc                	ld	a5,88(a5)
ffffffffc020546c:	9782                	jalr	a5
ffffffffc020546e:	84aa                	mv	s1,a0
ffffffffc0205470:	e119                	bnez	a0,ffffffffc0205476 <file_seek+0x82>
ffffffffc0205472:	03243023          	sd	s2,32(s0)
ffffffffc0205476:	8522                	mv	a0,s0
ffffffffc0205478:	a3fff0ef          	jal	ffffffffc0204eb6 <fd_array_release>
ffffffffc020547c:	7442                	ld	s0,48(sp)
ffffffffc020547e:	7902                	ld	s2,32(sp)
ffffffffc0205480:	70e2                	ld	ra,56(sp)
ffffffffc0205482:	8526                	mv	a0,s1
ffffffffc0205484:	74a2                	ld	s1,40(sp)
ffffffffc0205486:	6121                	addi	sp,sp,64
ffffffffc0205488:	8082                	ret
ffffffffc020548a:	7404                	ld	s1,40(s0)
ffffffffc020548c:	c4b5                	beqz	s1,ffffffffc02054f8 <file_seek+0x104>
ffffffffc020548e:	78bc                	ld	a5,112(s1)
ffffffffc0205490:	c7a5                	beqz	a5,ffffffffc02054f8 <file_seek+0x104>
ffffffffc0205492:	779c                	ld	a5,40(a5)
ffffffffc0205494:	c3b5                	beqz	a5,ffffffffc02054f8 <file_seek+0x104>
ffffffffc0205496:	8526                	mv	a0,s1
ffffffffc0205498:	00008597          	auipc	a1,0x8
ffffffffc020549c:	02058593          	addi	a1,a1,32 # ffffffffc020d4b8 <etext+0x1be2>
ffffffffc02054a0:	64b020ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02054a4:	78bc                	ld	a5,112(s1)
ffffffffc02054a6:	7408                	ld	a0,40(s0)
ffffffffc02054a8:	858a                	mv	a1,sp
ffffffffc02054aa:	779c                	ld	a5,40(a5)
ffffffffc02054ac:	9782                	jalr	a5
ffffffffc02054ae:	84aa                	mv	s1,a0
ffffffffc02054b0:	f179                	bnez	a0,ffffffffc0205476 <file_seek+0x82>
ffffffffc02054b2:	67e2                	ld	a5,24(sp)
ffffffffc02054b4:	993e                	add	s2,s2,a5
ffffffffc02054b6:	bf51                	j	ffffffffc020544a <file_seek+0x56>
ffffffffc02054b8:	701c                	ld	a5,32(s0)
ffffffffc02054ba:	00f58933          	add	s2,a1,a5
ffffffffc02054be:	b771                	j	ffffffffc020544a <file_seek+0x56>
ffffffffc02054c0:	7442                	ld	s0,48(sp)
ffffffffc02054c2:	7902                	ld	s2,32(sp)
ffffffffc02054c4:	54f5                	li	s1,-3
ffffffffc02054c6:	bf6d                	j	ffffffffc0205480 <file_seek+0x8c>
ffffffffc02054c8:	54f5                	li	s1,-3
ffffffffc02054ca:	bf5d                	j	ffffffffc0205480 <file_seek+0x8c>
ffffffffc02054cc:	7442                	ld	s0,48(sp)
ffffffffc02054ce:	54f5                	li	s1,-3
ffffffffc02054d0:	bf45                	j	ffffffffc0205480 <file_seek+0x8c>
ffffffffc02054d2:	f04a                	sd	s2,32(sp)
ffffffffc02054d4:	8b5ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>
ffffffffc02054d8:	00008697          	auipc	a3,0x8
ffffffffc02054dc:	09868693          	addi	a3,a3,152 # ffffffffc020d570 <etext+0x1c9a>
ffffffffc02054e0:	00007617          	auipc	a2,0x7
ffffffffc02054e4:	8b060613          	addi	a2,a2,-1872 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02054e8:	11a00593          	li	a1,282
ffffffffc02054ec:	00008517          	auipc	a0,0x8
ffffffffc02054f0:	e4450513          	addi	a0,a0,-444 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc02054f4:	d39fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02054f8:	00008697          	auipc	a3,0x8
ffffffffc02054fc:	f7068693          	addi	a3,a3,-144 # ffffffffc020d468 <etext+0x1b92>
ffffffffc0205500:	00007617          	auipc	a2,0x7
ffffffffc0205504:	89060613          	addi	a2,a2,-1904 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0205508:	11200593          	li	a1,274
ffffffffc020550c:	00008517          	auipc	a0,0x8
ffffffffc0205510:	e2450513          	addi	a0,a0,-476 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0205514:	d19fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0205518 <file_fstat>:
ffffffffc0205518:	7179                	addi	sp,sp,-48
ffffffffc020551a:	f406                	sd	ra,40(sp)
ffffffffc020551c:	f022                	sd	s0,32(sp)
ffffffffc020551e:	04700793          	li	a5,71
ffffffffc0205522:	08a7e363          	bltu	a5,a0,ffffffffc02055a8 <file_fstat+0x90>
ffffffffc0205526:	00091797          	auipc	a5,0x91
ffffffffc020552a:	3a27b783          	ld	a5,930(a5) # ffffffffc02968c8 <current>
ffffffffc020552e:	ec26                	sd	s1,24(sp)
ffffffffc0205530:	84ae                	mv	s1,a1
ffffffffc0205532:	1487b783          	ld	a5,328(a5)
ffffffffc0205536:	cbd9                	beqz	a5,ffffffffc02055cc <file_fstat+0xb4>
ffffffffc0205538:	4b98                	lw	a4,16(a5)
ffffffffc020553a:	08e05963          	blez	a4,ffffffffc02055cc <file_fstat+0xb4>
ffffffffc020553e:	6780                	ld	s0,8(a5)
ffffffffc0205540:	00351793          	slli	a5,a0,0x3
ffffffffc0205544:	8f89                	sub	a5,a5,a0
ffffffffc0205546:	078e                	slli	a5,a5,0x3
ffffffffc0205548:	943e                	add	s0,s0,a5
ffffffffc020554a:	4018                	lw	a4,0(s0)
ffffffffc020554c:	4789                	li	a5,2
ffffffffc020554e:	04f71663          	bne	a4,a5,ffffffffc020559a <file_fstat+0x82>
ffffffffc0205552:	4c1c                	lw	a5,24(s0)
ffffffffc0205554:	04a79363          	bne	a5,a0,ffffffffc020559a <file_fstat+0x82>
ffffffffc0205558:	581c                	lw	a5,48(s0)
ffffffffc020555a:	7408                	ld	a0,40(s0)
ffffffffc020555c:	2785                	addiw	a5,a5,1
ffffffffc020555e:	d81c                	sw	a5,48(s0)
ffffffffc0205560:	c531                	beqz	a0,ffffffffc02055ac <file_fstat+0x94>
ffffffffc0205562:	793c                	ld	a5,112(a0)
ffffffffc0205564:	c7a1                	beqz	a5,ffffffffc02055ac <file_fstat+0x94>
ffffffffc0205566:	779c                	ld	a5,40(a5)
ffffffffc0205568:	c3b1                	beqz	a5,ffffffffc02055ac <file_fstat+0x94>
ffffffffc020556a:	00008597          	auipc	a1,0x8
ffffffffc020556e:	f4e58593          	addi	a1,a1,-178 # ffffffffc020d4b8 <etext+0x1be2>
ffffffffc0205572:	e42a                	sd	a0,8(sp)
ffffffffc0205574:	577020ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0205578:	6522                	ld	a0,8(sp)
ffffffffc020557a:	85a6                	mv	a1,s1
ffffffffc020557c:	793c                	ld	a5,112(a0)
ffffffffc020557e:	7408                	ld	a0,40(s0)
ffffffffc0205580:	779c                	ld	a5,40(a5)
ffffffffc0205582:	9782                	jalr	a5
ffffffffc0205584:	87aa                	mv	a5,a0
ffffffffc0205586:	8522                	mv	a0,s0
ffffffffc0205588:	843e                	mv	s0,a5
ffffffffc020558a:	92dff0ef          	jal	ffffffffc0204eb6 <fd_array_release>
ffffffffc020558e:	64e2                	ld	s1,24(sp)
ffffffffc0205590:	70a2                	ld	ra,40(sp)
ffffffffc0205592:	8522                	mv	a0,s0
ffffffffc0205594:	7402                	ld	s0,32(sp)
ffffffffc0205596:	6145                	addi	sp,sp,48
ffffffffc0205598:	8082                	ret
ffffffffc020559a:	5475                	li	s0,-3
ffffffffc020559c:	70a2                	ld	ra,40(sp)
ffffffffc020559e:	8522                	mv	a0,s0
ffffffffc02055a0:	7402                	ld	s0,32(sp)
ffffffffc02055a2:	64e2                	ld	s1,24(sp)
ffffffffc02055a4:	6145                	addi	sp,sp,48
ffffffffc02055a6:	8082                	ret
ffffffffc02055a8:	5475                	li	s0,-3
ffffffffc02055aa:	b7dd                	j	ffffffffc0205590 <file_fstat+0x78>
ffffffffc02055ac:	00008697          	auipc	a3,0x8
ffffffffc02055b0:	ebc68693          	addi	a3,a3,-324 # ffffffffc020d468 <etext+0x1b92>
ffffffffc02055b4:	00006617          	auipc	a2,0x6
ffffffffc02055b8:	7dc60613          	addi	a2,a2,2012 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02055bc:	12c00593          	li	a1,300
ffffffffc02055c0:	00008517          	auipc	a0,0x8
ffffffffc02055c4:	d7050513          	addi	a0,a0,-656 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc02055c8:	c65fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02055cc:	fbcff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc02055d0 <file_fsync>:
ffffffffc02055d0:	1101                	addi	sp,sp,-32
ffffffffc02055d2:	ec06                	sd	ra,24(sp)
ffffffffc02055d4:	e822                	sd	s0,16(sp)
ffffffffc02055d6:	04700793          	li	a5,71
ffffffffc02055da:	06a7e863          	bltu	a5,a0,ffffffffc020564a <file_fsync+0x7a>
ffffffffc02055de:	00091797          	auipc	a5,0x91
ffffffffc02055e2:	2ea7b783          	ld	a5,746(a5) # ffffffffc02968c8 <current>
ffffffffc02055e6:	1487b783          	ld	a5,328(a5)
ffffffffc02055ea:	c7d1                	beqz	a5,ffffffffc0205676 <file_fsync+0xa6>
ffffffffc02055ec:	4b98                	lw	a4,16(a5)
ffffffffc02055ee:	08e05463          	blez	a4,ffffffffc0205676 <file_fsync+0xa6>
ffffffffc02055f2:	6780                	ld	s0,8(a5)
ffffffffc02055f4:	00351793          	slli	a5,a0,0x3
ffffffffc02055f8:	8f89                	sub	a5,a5,a0
ffffffffc02055fa:	078e                	slli	a5,a5,0x3
ffffffffc02055fc:	943e                	add	s0,s0,a5
ffffffffc02055fe:	4018                	lw	a4,0(s0)
ffffffffc0205600:	4789                	li	a5,2
ffffffffc0205602:	04f71463          	bne	a4,a5,ffffffffc020564a <file_fsync+0x7a>
ffffffffc0205606:	4c1c                	lw	a5,24(s0)
ffffffffc0205608:	04a79163          	bne	a5,a0,ffffffffc020564a <file_fsync+0x7a>
ffffffffc020560c:	581c                	lw	a5,48(s0)
ffffffffc020560e:	7408                	ld	a0,40(s0)
ffffffffc0205610:	2785                	addiw	a5,a5,1
ffffffffc0205612:	d81c                	sw	a5,48(s0)
ffffffffc0205614:	c129                	beqz	a0,ffffffffc0205656 <file_fsync+0x86>
ffffffffc0205616:	793c                	ld	a5,112(a0)
ffffffffc0205618:	cf9d                	beqz	a5,ffffffffc0205656 <file_fsync+0x86>
ffffffffc020561a:	7b9c                	ld	a5,48(a5)
ffffffffc020561c:	cf8d                	beqz	a5,ffffffffc0205656 <file_fsync+0x86>
ffffffffc020561e:	00008597          	auipc	a1,0x8
ffffffffc0205622:	ffa58593          	addi	a1,a1,-6 # ffffffffc020d618 <etext+0x1d42>
ffffffffc0205626:	e42a                	sd	a0,8(sp)
ffffffffc0205628:	4c3020ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020562c:	6522                	ld	a0,8(sp)
ffffffffc020562e:	793c                	ld	a5,112(a0)
ffffffffc0205630:	7408                	ld	a0,40(s0)
ffffffffc0205632:	7b9c                	ld	a5,48(a5)
ffffffffc0205634:	9782                	jalr	a5
ffffffffc0205636:	87aa                	mv	a5,a0
ffffffffc0205638:	8522                	mv	a0,s0
ffffffffc020563a:	843e                	mv	s0,a5
ffffffffc020563c:	87bff0ef          	jal	ffffffffc0204eb6 <fd_array_release>
ffffffffc0205640:	60e2                	ld	ra,24(sp)
ffffffffc0205642:	8522                	mv	a0,s0
ffffffffc0205644:	6442                	ld	s0,16(sp)
ffffffffc0205646:	6105                	addi	sp,sp,32
ffffffffc0205648:	8082                	ret
ffffffffc020564a:	5475                	li	s0,-3
ffffffffc020564c:	60e2                	ld	ra,24(sp)
ffffffffc020564e:	8522                	mv	a0,s0
ffffffffc0205650:	6442                	ld	s0,16(sp)
ffffffffc0205652:	6105                	addi	sp,sp,32
ffffffffc0205654:	8082                	ret
ffffffffc0205656:	00008697          	auipc	a3,0x8
ffffffffc020565a:	f7268693          	addi	a3,a3,-142 # ffffffffc020d5c8 <etext+0x1cf2>
ffffffffc020565e:	00006617          	auipc	a2,0x6
ffffffffc0205662:	73260613          	addi	a2,a2,1842 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0205666:	13a00593          	li	a1,314
ffffffffc020566a:	00008517          	auipc	a0,0x8
ffffffffc020566e:	cc650513          	addi	a0,a0,-826 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc0205672:	bbbfa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0205676:	f12ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc020567a <file_getdirentry>:
ffffffffc020567a:	715d                	addi	sp,sp,-80
ffffffffc020567c:	e486                	sd	ra,72(sp)
ffffffffc020567e:	f84a                	sd	s2,48(sp)
ffffffffc0205680:	04700793          	li	a5,71
ffffffffc0205684:	0aa7e963          	bltu	a5,a0,ffffffffc0205736 <file_getdirentry+0xbc>
ffffffffc0205688:	00091797          	auipc	a5,0x91
ffffffffc020568c:	2407b783          	ld	a5,576(a5) # ffffffffc02968c8 <current>
ffffffffc0205690:	fc26                	sd	s1,56(sp)
ffffffffc0205692:	e0a2                	sd	s0,64(sp)
ffffffffc0205694:	1487b783          	ld	a5,328(a5)
ffffffffc0205698:	84ae                	mv	s1,a1
ffffffffc020569a:	c7e1                	beqz	a5,ffffffffc0205762 <file_getdirentry+0xe8>
ffffffffc020569c:	4b98                	lw	a4,16(a5)
ffffffffc020569e:	0ce05263          	blez	a4,ffffffffc0205762 <file_getdirentry+0xe8>
ffffffffc02056a2:	6780                	ld	s0,8(a5)
ffffffffc02056a4:	00351793          	slli	a5,a0,0x3
ffffffffc02056a8:	8f89                	sub	a5,a5,a0
ffffffffc02056aa:	078e                	slli	a5,a5,0x3
ffffffffc02056ac:	943e                	add	s0,s0,a5
ffffffffc02056ae:	4018                	lw	a4,0(s0)
ffffffffc02056b0:	4789                	li	a5,2
ffffffffc02056b2:	08f71463          	bne	a4,a5,ffffffffc020573a <file_getdirentry+0xc0>
ffffffffc02056b6:	4c1c                	lw	a5,24(s0)
ffffffffc02056b8:	f44e                	sd	s3,40(sp)
ffffffffc02056ba:	06a79963          	bne	a5,a0,ffffffffc020572c <file_getdirentry+0xb2>
ffffffffc02056be:	581c                	lw	a5,48(s0)
ffffffffc02056c0:	6194                	ld	a3,0(a1)
ffffffffc02056c2:	10000613          	li	a2,256
ffffffffc02056c6:	2785                	addiw	a5,a5,1
ffffffffc02056c8:	d81c                	sw	a5,48(s0)
ffffffffc02056ca:	05a1                	addi	a1,a1,8
ffffffffc02056cc:	850a                	mv	a0,sp
ffffffffc02056ce:	12e000ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc02056d2:	02843903          	ld	s2,40(s0)
ffffffffc02056d6:	89aa                	mv	s3,a0
ffffffffc02056d8:	06090563          	beqz	s2,ffffffffc0205742 <file_getdirentry+0xc8>
ffffffffc02056dc:	07093783          	ld	a5,112(s2)
ffffffffc02056e0:	c3ad                	beqz	a5,ffffffffc0205742 <file_getdirentry+0xc8>
ffffffffc02056e2:	63bc                	ld	a5,64(a5)
ffffffffc02056e4:	cfb9                	beqz	a5,ffffffffc0205742 <file_getdirentry+0xc8>
ffffffffc02056e6:	854a                	mv	a0,s2
ffffffffc02056e8:	00008597          	auipc	a1,0x8
ffffffffc02056ec:	f9058593          	addi	a1,a1,-112 # ffffffffc020d678 <etext+0x1da2>
ffffffffc02056f0:	3fb020ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02056f4:	07093783          	ld	a5,112(s2)
ffffffffc02056f8:	7408                	ld	a0,40(s0)
ffffffffc02056fa:	85ce                	mv	a1,s3
ffffffffc02056fc:	63bc                	ld	a5,64(a5)
ffffffffc02056fe:	9782                	jalr	a5
ffffffffc0205700:	892a                	mv	s2,a0
ffffffffc0205702:	cd01                	beqz	a0,ffffffffc020571a <file_getdirentry+0xa0>
ffffffffc0205704:	8522                	mv	a0,s0
ffffffffc0205706:	fb0ff0ef          	jal	ffffffffc0204eb6 <fd_array_release>
ffffffffc020570a:	6406                	ld	s0,64(sp)
ffffffffc020570c:	74e2                	ld	s1,56(sp)
ffffffffc020570e:	79a2                	ld	s3,40(sp)
ffffffffc0205710:	60a6                	ld	ra,72(sp)
ffffffffc0205712:	854a                	mv	a0,s2
ffffffffc0205714:	7942                	ld	s2,48(sp)
ffffffffc0205716:	6161                	addi	sp,sp,80
ffffffffc0205718:	8082                	ret
ffffffffc020571a:	609c                	ld	a5,0(s1)
ffffffffc020571c:	0109b683          	ld	a3,16(s3)
ffffffffc0205720:	0189b703          	ld	a4,24(s3)
ffffffffc0205724:	97b6                	add	a5,a5,a3
ffffffffc0205726:	8f99                	sub	a5,a5,a4
ffffffffc0205728:	e09c                	sd	a5,0(s1)
ffffffffc020572a:	bfe9                	j	ffffffffc0205704 <file_getdirentry+0x8a>
ffffffffc020572c:	6406                	ld	s0,64(sp)
ffffffffc020572e:	74e2                	ld	s1,56(sp)
ffffffffc0205730:	79a2                	ld	s3,40(sp)
ffffffffc0205732:	5975                	li	s2,-3
ffffffffc0205734:	bff1                	j	ffffffffc0205710 <file_getdirentry+0x96>
ffffffffc0205736:	5975                	li	s2,-3
ffffffffc0205738:	bfe1                	j	ffffffffc0205710 <file_getdirentry+0x96>
ffffffffc020573a:	6406                	ld	s0,64(sp)
ffffffffc020573c:	74e2                	ld	s1,56(sp)
ffffffffc020573e:	5975                	li	s2,-3
ffffffffc0205740:	bfc1                	j	ffffffffc0205710 <file_getdirentry+0x96>
ffffffffc0205742:	00008697          	auipc	a3,0x8
ffffffffc0205746:	ede68693          	addi	a3,a3,-290 # ffffffffc020d620 <etext+0x1d4a>
ffffffffc020574a:	00006617          	auipc	a2,0x6
ffffffffc020574e:	64660613          	addi	a2,a2,1606 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0205752:	14a00593          	li	a1,330
ffffffffc0205756:	00008517          	auipc	a0,0x8
ffffffffc020575a:	bda50513          	addi	a0,a0,-1062 # ffffffffc020d330 <etext+0x1a5a>
ffffffffc020575e:	acffa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0205762:	f44e                	sd	s3,40(sp)
ffffffffc0205764:	e24ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc0205768 <file_dup>:
ffffffffc0205768:	04700713          	li	a4,71
ffffffffc020576c:	06a76263          	bltu	a4,a0,ffffffffc02057d0 <file_dup+0x68>
ffffffffc0205770:	00091717          	auipc	a4,0x91
ffffffffc0205774:	15873703          	ld	a4,344(a4) # ffffffffc02968c8 <current>
ffffffffc0205778:	7179                	addi	sp,sp,-48
ffffffffc020577a:	f406                	sd	ra,40(sp)
ffffffffc020577c:	14873703          	ld	a4,328(a4)
ffffffffc0205780:	f022                	sd	s0,32(sp)
ffffffffc0205782:	87aa                	mv	a5,a0
ffffffffc0205784:	852e                	mv	a0,a1
ffffffffc0205786:	c739                	beqz	a4,ffffffffc02057d4 <file_dup+0x6c>
ffffffffc0205788:	4b14                	lw	a3,16(a4)
ffffffffc020578a:	04d05563          	blez	a3,ffffffffc02057d4 <file_dup+0x6c>
ffffffffc020578e:	6700                	ld	s0,8(a4)
ffffffffc0205790:	00379713          	slli	a4,a5,0x3
ffffffffc0205794:	8f1d                	sub	a4,a4,a5
ffffffffc0205796:	070e                	slli	a4,a4,0x3
ffffffffc0205798:	943a                	add	s0,s0,a4
ffffffffc020579a:	4014                	lw	a3,0(s0)
ffffffffc020579c:	4709                	li	a4,2
ffffffffc020579e:	02e69463          	bne	a3,a4,ffffffffc02057c6 <file_dup+0x5e>
ffffffffc02057a2:	4c18                	lw	a4,24(s0)
ffffffffc02057a4:	02f71163          	bne	a4,a5,ffffffffc02057c6 <file_dup+0x5e>
ffffffffc02057a8:	082c                	addi	a1,sp,24
ffffffffc02057aa:	e00ff0ef          	jal	ffffffffc0204daa <fd_array_alloc>
ffffffffc02057ae:	e901                	bnez	a0,ffffffffc02057be <file_dup+0x56>
ffffffffc02057b0:	6562                	ld	a0,24(sp)
ffffffffc02057b2:	85a2                	mv	a1,s0
ffffffffc02057b4:	e42a                	sd	a0,8(sp)
ffffffffc02057b6:	821ff0ef          	jal	ffffffffc0204fd6 <fd_array_dup>
ffffffffc02057ba:	6522                	ld	a0,8(sp)
ffffffffc02057bc:	4d08                	lw	a0,24(a0)
ffffffffc02057be:	70a2                	ld	ra,40(sp)
ffffffffc02057c0:	7402                	ld	s0,32(sp)
ffffffffc02057c2:	6145                	addi	sp,sp,48
ffffffffc02057c4:	8082                	ret
ffffffffc02057c6:	70a2                	ld	ra,40(sp)
ffffffffc02057c8:	7402                	ld	s0,32(sp)
ffffffffc02057ca:	5575                	li	a0,-3
ffffffffc02057cc:	6145                	addi	sp,sp,48
ffffffffc02057ce:	8082                	ret
ffffffffc02057d0:	5575                	li	a0,-3
ffffffffc02057d2:	8082                	ret
ffffffffc02057d4:	db4ff0ef          	jal	ffffffffc0204d88 <get_fd_array.part.0>

ffffffffc02057d8 <iobuf_skip.part.0>:
ffffffffc02057d8:	1141                	addi	sp,sp,-16
ffffffffc02057da:	00008697          	auipc	a3,0x8
ffffffffc02057de:	eae68693          	addi	a3,a3,-338 # ffffffffc020d688 <etext+0x1db2>
ffffffffc02057e2:	00006617          	auipc	a2,0x6
ffffffffc02057e6:	5ae60613          	addi	a2,a2,1454 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02057ea:	04a00593          	li	a1,74
ffffffffc02057ee:	00008517          	auipc	a0,0x8
ffffffffc02057f2:	eb250513          	addi	a0,a0,-334 # ffffffffc020d6a0 <etext+0x1dca>
ffffffffc02057f6:	e406                	sd	ra,8(sp)
ffffffffc02057f8:	a35fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc02057fc <iobuf_init>:
ffffffffc02057fc:	e10c                	sd	a1,0(a0)
ffffffffc02057fe:	e514                	sd	a3,8(a0)
ffffffffc0205800:	ed10                	sd	a2,24(a0)
ffffffffc0205802:	e910                	sd	a2,16(a0)
ffffffffc0205804:	8082                	ret

ffffffffc0205806 <iobuf_move>:
ffffffffc0205806:	6d1c                	ld	a5,24(a0)
ffffffffc0205808:	88aa                	mv	a7,a0
ffffffffc020580a:	8832                	mv	a6,a2
ffffffffc020580c:	00f67363          	bgeu	a2,a5,ffffffffc0205812 <iobuf_move+0xc>
ffffffffc0205810:	87b2                	mv	a5,a2
ffffffffc0205812:	cfa1                	beqz	a5,ffffffffc020586a <iobuf_move+0x64>
ffffffffc0205814:	7179                	addi	sp,sp,-48
ffffffffc0205816:	f406                	sd	ra,40(sp)
ffffffffc0205818:	0008b503          	ld	a0,0(a7)
ffffffffc020581c:	cea9                	beqz	a3,ffffffffc0205876 <iobuf_move+0x70>
ffffffffc020581e:	863e                	mv	a2,a5
ffffffffc0205820:	ec3a                	sd	a4,24(sp)
ffffffffc0205822:	e846                	sd	a7,16(sp)
ffffffffc0205824:	e442                	sd	a6,8(sp)
ffffffffc0205826:	e03e                	sd	a5,0(sp)
ffffffffc0205828:	3d1050ef          	jal	ffffffffc020b3f8 <memmove>
ffffffffc020582c:	68c2                	ld	a7,16(sp)
ffffffffc020582e:	6782                	ld	a5,0(sp)
ffffffffc0205830:	6822                	ld	a6,8(sp)
ffffffffc0205832:	0188b683          	ld	a3,24(a7)
ffffffffc0205836:	6762                	ld	a4,24(sp)
ffffffffc0205838:	04f6e763          	bltu	a3,a5,ffffffffc0205886 <iobuf_move+0x80>
ffffffffc020583c:	0008b583          	ld	a1,0(a7)
ffffffffc0205840:	0088b603          	ld	a2,8(a7)
ffffffffc0205844:	8e9d                	sub	a3,a3,a5
ffffffffc0205846:	95be                	add	a1,a1,a5
ffffffffc0205848:	963e                	add	a2,a2,a5
ffffffffc020584a:	00d8bc23          	sd	a3,24(a7)
ffffffffc020584e:	00b8b023          	sd	a1,0(a7)
ffffffffc0205852:	00c8b423          	sd	a2,8(a7)
ffffffffc0205856:	40f80833          	sub	a6,a6,a5
ffffffffc020585a:	c311                	beqz	a4,ffffffffc020585e <iobuf_move+0x58>
ffffffffc020585c:	e31c                	sd	a5,0(a4)
ffffffffc020585e:	02081263          	bnez	a6,ffffffffc0205882 <iobuf_move+0x7c>
ffffffffc0205862:	4501                	li	a0,0
ffffffffc0205864:	70a2                	ld	ra,40(sp)
ffffffffc0205866:	6145                	addi	sp,sp,48
ffffffffc0205868:	8082                	ret
ffffffffc020586a:	c311                	beqz	a4,ffffffffc020586e <iobuf_move+0x68>
ffffffffc020586c:	e31c                	sd	a5,0(a4)
ffffffffc020586e:	00081863          	bnez	a6,ffffffffc020587e <iobuf_move+0x78>
ffffffffc0205872:	4501                	li	a0,0
ffffffffc0205874:	8082                	ret
ffffffffc0205876:	86ae                	mv	a3,a1
ffffffffc0205878:	85aa                	mv	a1,a0
ffffffffc020587a:	8536                	mv	a0,a3
ffffffffc020587c:	b74d                	j	ffffffffc020581e <iobuf_move+0x18>
ffffffffc020587e:	5571                	li	a0,-4
ffffffffc0205880:	8082                	ret
ffffffffc0205882:	5571                	li	a0,-4
ffffffffc0205884:	b7c5                	j	ffffffffc0205864 <iobuf_move+0x5e>
ffffffffc0205886:	f53ff0ef          	jal	ffffffffc02057d8 <iobuf_skip.part.0>

ffffffffc020588a <iobuf_skip>:
ffffffffc020588a:	6d1c                	ld	a5,24(a0)
ffffffffc020588c:	00b7eb63          	bltu	a5,a1,ffffffffc02058a2 <iobuf_skip+0x18>
ffffffffc0205890:	6114                	ld	a3,0(a0)
ffffffffc0205892:	6518                	ld	a4,8(a0)
ffffffffc0205894:	8f8d                	sub	a5,a5,a1
ffffffffc0205896:	96ae                	add	a3,a3,a1
ffffffffc0205898:	972e                	add	a4,a4,a1
ffffffffc020589a:	ed1c                	sd	a5,24(a0)
ffffffffc020589c:	e114                	sd	a3,0(a0)
ffffffffc020589e:	e518                	sd	a4,8(a0)
ffffffffc02058a0:	8082                	ret
ffffffffc02058a2:	1141                	addi	sp,sp,-16
ffffffffc02058a4:	e406                	sd	ra,8(sp)
ffffffffc02058a6:	f33ff0ef          	jal	ffffffffc02057d8 <iobuf_skip.part.0>

ffffffffc02058aa <fs_init>:
ffffffffc02058aa:	1141                	addi	sp,sp,-16
ffffffffc02058ac:	e406                	sd	ra,8(sp)
ffffffffc02058ae:	639020ef          	jal	ffffffffc02086e6 <vfs_init>
ffffffffc02058b2:	06b030ef          	jal	ffffffffc020911c <dev_init>
ffffffffc02058b6:	60a2                	ld	ra,8(sp)
ffffffffc02058b8:	0141                	addi	sp,sp,16
ffffffffc02058ba:	0a30306f          	j	ffffffffc020915c <sfs_init>

ffffffffc02058be <fs_cleanup>:
ffffffffc02058be:	3640206f          	j	ffffffffc0207c22 <vfs_cleanup>

ffffffffc02058c2 <lock_files>:
ffffffffc02058c2:	0561                	addi	a0,a0,24
ffffffffc02058c4:	f15fe06f          	j	ffffffffc02047d8 <down>

ffffffffc02058c8 <unlock_files>:
ffffffffc02058c8:	0561                	addi	a0,a0,24
ffffffffc02058ca:	f0bfe06f          	j	ffffffffc02047d4 <up>

ffffffffc02058ce <files_create>:
ffffffffc02058ce:	1141                	addi	sp,sp,-16
ffffffffc02058d0:	6505                	lui	a0,0x1
ffffffffc02058d2:	e022                	sd	s0,0(sp)
ffffffffc02058d4:	e406                	sd	ra,8(sp)
ffffffffc02058d6:	c66fc0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc02058da:	842a                	mv	s0,a0
ffffffffc02058dc:	cd19                	beqz	a0,ffffffffc02058fa <files_create+0x2c>
ffffffffc02058de:	03050793          	addi	a5,a0,48 # 1030 <_binary_bin_swap_img_size-0x6cd0>
ffffffffc02058e2:	e51c                	sd	a5,8(a0)
ffffffffc02058e4:	00053023          	sd	zero,0(a0)
ffffffffc02058e8:	00052823          	sw	zero,16(a0)
ffffffffc02058ec:	4585                	li	a1,1
ffffffffc02058ee:	0561                	addi	a0,a0,24
ffffffffc02058f0:	eddfe0ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc02058f4:	6408                	ld	a0,8(s0)
ffffffffc02058f6:	e4cff0ef          	jal	ffffffffc0204f42 <fd_array_init>
ffffffffc02058fa:	60a2                	ld	ra,8(sp)
ffffffffc02058fc:	8522                	mv	a0,s0
ffffffffc02058fe:	6402                	ld	s0,0(sp)
ffffffffc0205900:	0141                	addi	sp,sp,16
ffffffffc0205902:	8082                	ret

ffffffffc0205904 <files_destroy>:
ffffffffc0205904:	7179                	addi	sp,sp,-48
ffffffffc0205906:	f406                	sd	ra,40(sp)
ffffffffc0205908:	f022                	sd	s0,32(sp)
ffffffffc020590a:	ec26                	sd	s1,24(sp)
ffffffffc020590c:	e84a                	sd	s2,16(sp)
ffffffffc020590e:	e44e                	sd	s3,8(sp)
ffffffffc0205910:	c52d                	beqz	a0,ffffffffc020597a <files_destroy+0x76>
ffffffffc0205912:	491c                	lw	a5,16(a0)
ffffffffc0205914:	89aa                	mv	s3,a0
ffffffffc0205916:	e3b5                	bnez	a5,ffffffffc020597a <files_destroy+0x76>
ffffffffc0205918:	6108                	ld	a0,0(a0)
ffffffffc020591a:	c119                	beqz	a0,ffffffffc0205920 <files_destroy+0x1c>
ffffffffc020591c:	289020ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc0205920:	0089b403          	ld	s0,8(s3)
ffffffffc0205924:	4909                	li	s2,2
ffffffffc0205926:	7ff40493          	addi	s1,s0,2047
ffffffffc020592a:	7c148493          	addi	s1,s1,1985
ffffffffc020592e:	401c                	lw	a5,0(s0)
ffffffffc0205930:	03278063          	beq	a5,s2,ffffffffc0205950 <files_destroy+0x4c>
ffffffffc0205934:	e39d                	bnez	a5,ffffffffc020595a <files_destroy+0x56>
ffffffffc0205936:	03840413          	addi	s0,s0,56
ffffffffc020593a:	fe941ae3          	bne	s0,s1,ffffffffc020592e <files_destroy+0x2a>
ffffffffc020593e:	7402                	ld	s0,32(sp)
ffffffffc0205940:	70a2                	ld	ra,40(sp)
ffffffffc0205942:	64e2                	ld	s1,24(sp)
ffffffffc0205944:	6942                	ld	s2,16(sp)
ffffffffc0205946:	854e                	mv	a0,s3
ffffffffc0205948:	69a2                	ld	s3,8(sp)
ffffffffc020594a:	6145                	addi	sp,sp,48
ffffffffc020594c:	c96fc06f          	j	ffffffffc0201de2 <kfree>
ffffffffc0205950:	8522                	mv	a0,s0
ffffffffc0205952:	e0cff0ef          	jal	ffffffffc0204f5e <fd_array_close>
ffffffffc0205956:	401c                	lw	a5,0(s0)
ffffffffc0205958:	bff1                	j	ffffffffc0205934 <files_destroy+0x30>
ffffffffc020595a:	00008697          	auipc	a3,0x8
ffffffffc020595e:	d9668693          	addi	a3,a3,-618 # ffffffffc020d6f0 <etext+0x1e1a>
ffffffffc0205962:	00006617          	auipc	a2,0x6
ffffffffc0205966:	42e60613          	addi	a2,a2,1070 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020596a:	03d00593          	li	a1,61
ffffffffc020596e:	00008517          	auipc	a0,0x8
ffffffffc0205972:	d7250513          	addi	a0,a0,-654 # ffffffffc020d6e0 <etext+0x1e0a>
ffffffffc0205976:	8b7fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc020597a:	00008697          	auipc	a3,0x8
ffffffffc020597e:	d3668693          	addi	a3,a3,-714 # ffffffffc020d6b0 <etext+0x1dda>
ffffffffc0205982:	00006617          	auipc	a2,0x6
ffffffffc0205986:	40e60613          	addi	a2,a2,1038 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020598a:	03300593          	li	a1,51
ffffffffc020598e:	00008517          	auipc	a0,0x8
ffffffffc0205992:	d5250513          	addi	a0,a0,-686 # ffffffffc020d6e0 <etext+0x1e0a>
ffffffffc0205996:	897fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020599a <files_closeall>:
ffffffffc020599a:	1101                	addi	sp,sp,-32
ffffffffc020599c:	ec06                	sd	ra,24(sp)
ffffffffc020599e:	e822                	sd	s0,16(sp)
ffffffffc02059a0:	e426                	sd	s1,8(sp)
ffffffffc02059a2:	e04a                	sd	s2,0(sp)
ffffffffc02059a4:	c129                	beqz	a0,ffffffffc02059e6 <files_closeall+0x4c>
ffffffffc02059a6:	491c                	lw	a5,16(a0)
ffffffffc02059a8:	02f05f63          	blez	a5,ffffffffc02059e6 <files_closeall+0x4c>
ffffffffc02059ac:	6500                	ld	s0,8(a0)
ffffffffc02059ae:	4909                	li	s2,2
ffffffffc02059b0:	7ff40493          	addi	s1,s0,2047
ffffffffc02059b4:	7c148493          	addi	s1,s1,1985
ffffffffc02059b8:	07040413          	addi	s0,s0,112
ffffffffc02059bc:	a029                	j	ffffffffc02059c6 <files_closeall+0x2c>
ffffffffc02059be:	03840413          	addi	s0,s0,56
ffffffffc02059c2:	00940c63          	beq	s0,s1,ffffffffc02059da <files_closeall+0x40>
ffffffffc02059c6:	401c                	lw	a5,0(s0)
ffffffffc02059c8:	ff279be3          	bne	a5,s2,ffffffffc02059be <files_closeall+0x24>
ffffffffc02059cc:	8522                	mv	a0,s0
ffffffffc02059ce:	03840413          	addi	s0,s0,56
ffffffffc02059d2:	d8cff0ef          	jal	ffffffffc0204f5e <fd_array_close>
ffffffffc02059d6:	fe9418e3          	bne	s0,s1,ffffffffc02059c6 <files_closeall+0x2c>
ffffffffc02059da:	60e2                	ld	ra,24(sp)
ffffffffc02059dc:	6442                	ld	s0,16(sp)
ffffffffc02059de:	64a2                	ld	s1,8(sp)
ffffffffc02059e0:	6902                	ld	s2,0(sp)
ffffffffc02059e2:	6105                	addi	sp,sp,32
ffffffffc02059e4:	8082                	ret
ffffffffc02059e6:	00008697          	auipc	a3,0x8
ffffffffc02059ea:	91a68693          	addi	a3,a3,-1766 # ffffffffc020d300 <etext+0x1a2a>
ffffffffc02059ee:	00006617          	auipc	a2,0x6
ffffffffc02059f2:	3a260613          	addi	a2,a2,930 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02059f6:	04500593          	li	a1,69
ffffffffc02059fa:	00008517          	auipc	a0,0x8
ffffffffc02059fe:	ce650513          	addi	a0,a0,-794 # ffffffffc020d6e0 <etext+0x1e0a>
ffffffffc0205a02:	82bfa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0205a06 <dup_files>:
ffffffffc0205a06:	7179                	addi	sp,sp,-48
ffffffffc0205a08:	f406                	sd	ra,40(sp)
ffffffffc0205a0a:	f022                	sd	s0,32(sp)
ffffffffc0205a0c:	ec26                	sd	s1,24(sp)
ffffffffc0205a0e:	e84a                	sd	s2,16(sp)
ffffffffc0205a10:	e44e                	sd	s3,8(sp)
ffffffffc0205a12:	e052                	sd	s4,0(sp)
ffffffffc0205a14:	c52d                	beqz	a0,ffffffffc0205a7e <dup_files+0x78>
ffffffffc0205a16:	842e                	mv	s0,a1
ffffffffc0205a18:	c1bd                	beqz	a1,ffffffffc0205a7e <dup_files+0x78>
ffffffffc0205a1a:	491c                	lw	a5,16(a0)
ffffffffc0205a1c:	84aa                	mv	s1,a0
ffffffffc0205a1e:	e3c1                	bnez	a5,ffffffffc0205a9e <dup_files+0x98>
ffffffffc0205a20:	499c                	lw	a5,16(a1)
ffffffffc0205a22:	06f05e63          	blez	a5,ffffffffc0205a9e <dup_files+0x98>
ffffffffc0205a26:	6188                	ld	a0,0(a1)
ffffffffc0205a28:	e088                	sd	a0,0(s1)
ffffffffc0205a2a:	c119                	beqz	a0,ffffffffc0205a30 <dup_files+0x2a>
ffffffffc0205a2c:	0ab020ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0205a30:	6400                	ld	s0,8(s0)
ffffffffc0205a32:	6484                	ld	s1,8(s1)
ffffffffc0205a34:	4989                	li	s3,2
ffffffffc0205a36:	7ff40913          	addi	s2,s0,2047
ffffffffc0205a3a:	7c190913          	addi	s2,s2,1985
ffffffffc0205a3e:	4a05                	li	s4,1
ffffffffc0205a40:	a039                	j	ffffffffc0205a4e <dup_files+0x48>
ffffffffc0205a42:	03840413          	addi	s0,s0,56
ffffffffc0205a46:	03848493          	addi	s1,s1,56
ffffffffc0205a4a:	03240163          	beq	s0,s2,ffffffffc0205a6c <dup_files+0x66>
ffffffffc0205a4e:	401c                	lw	a5,0(s0)
ffffffffc0205a50:	ff3799e3          	bne	a5,s3,ffffffffc0205a42 <dup_files+0x3c>
ffffffffc0205a54:	0144a023          	sw	s4,0(s1)
ffffffffc0205a58:	85a2                	mv	a1,s0
ffffffffc0205a5a:	8526                	mv	a0,s1
ffffffffc0205a5c:	03840413          	addi	s0,s0,56
ffffffffc0205a60:	d76ff0ef          	jal	ffffffffc0204fd6 <fd_array_dup>
ffffffffc0205a64:	03848493          	addi	s1,s1,56
ffffffffc0205a68:	ff2413e3          	bne	s0,s2,ffffffffc0205a4e <dup_files+0x48>
ffffffffc0205a6c:	70a2                	ld	ra,40(sp)
ffffffffc0205a6e:	7402                	ld	s0,32(sp)
ffffffffc0205a70:	64e2                	ld	s1,24(sp)
ffffffffc0205a72:	6942                	ld	s2,16(sp)
ffffffffc0205a74:	69a2                	ld	s3,8(sp)
ffffffffc0205a76:	6a02                	ld	s4,0(sp)
ffffffffc0205a78:	4501                	li	a0,0
ffffffffc0205a7a:	6145                	addi	sp,sp,48
ffffffffc0205a7c:	8082                	ret
ffffffffc0205a7e:	00007697          	auipc	a3,0x7
ffffffffc0205a82:	a1a68693          	addi	a3,a3,-1510 # ffffffffc020c498 <etext+0xbc2>
ffffffffc0205a86:	00006617          	auipc	a2,0x6
ffffffffc0205a8a:	30a60613          	addi	a2,a2,778 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0205a8e:	05300593          	li	a1,83
ffffffffc0205a92:	00008517          	auipc	a0,0x8
ffffffffc0205a96:	c4e50513          	addi	a0,a0,-946 # ffffffffc020d6e0 <etext+0x1e0a>
ffffffffc0205a9a:	f92fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0205a9e:	00008697          	auipc	a3,0x8
ffffffffc0205aa2:	c6a68693          	addi	a3,a3,-918 # ffffffffc020d708 <etext+0x1e32>
ffffffffc0205aa6:	00006617          	auipc	a2,0x6
ffffffffc0205aaa:	2ea60613          	addi	a2,a2,746 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0205aae:	05400593          	li	a1,84
ffffffffc0205ab2:	00008517          	auipc	a0,0x8
ffffffffc0205ab6:	c2e50513          	addi	a0,a0,-978 # ffffffffc020d6e0 <etext+0x1e0a>
ffffffffc0205aba:	f72fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0205abe <kernel_thread_entry>:
ffffffffc0205abe:	8526                	mv	a0,s1
ffffffffc0205ac0:	9402                	jalr	s0
ffffffffc0205ac2:	6da000ef          	jal	ffffffffc020619c <do_exit>

ffffffffc0205ac6 <switch_to>:
ffffffffc0205ac6:	00153023          	sd	ra,0(a0)
ffffffffc0205aca:	00253423          	sd	sp,8(a0)
ffffffffc0205ace:	e900                	sd	s0,16(a0)
ffffffffc0205ad0:	ed04                	sd	s1,24(a0)
ffffffffc0205ad2:	03253023          	sd	s2,32(a0)
ffffffffc0205ad6:	03353423          	sd	s3,40(a0)
ffffffffc0205ada:	03453823          	sd	s4,48(a0)
ffffffffc0205ade:	03553c23          	sd	s5,56(a0)
ffffffffc0205ae2:	05653023          	sd	s6,64(a0)
ffffffffc0205ae6:	05753423          	sd	s7,72(a0)
ffffffffc0205aea:	05853823          	sd	s8,80(a0)
ffffffffc0205aee:	05953c23          	sd	s9,88(a0)
ffffffffc0205af2:	07a53023          	sd	s10,96(a0)
ffffffffc0205af6:	07b53423          	sd	s11,104(a0)
ffffffffc0205afa:	0005b083          	ld	ra,0(a1)
ffffffffc0205afe:	0085b103          	ld	sp,8(a1)
ffffffffc0205b02:	6980                	ld	s0,16(a1)
ffffffffc0205b04:	6d84                	ld	s1,24(a1)
ffffffffc0205b06:	0205b903          	ld	s2,32(a1)
ffffffffc0205b0a:	0285b983          	ld	s3,40(a1)
ffffffffc0205b0e:	0305ba03          	ld	s4,48(a1)
ffffffffc0205b12:	0385ba83          	ld	s5,56(a1)
ffffffffc0205b16:	0405bb03          	ld	s6,64(a1)
ffffffffc0205b1a:	0485bb83          	ld	s7,72(a1)
ffffffffc0205b1e:	0505bc03          	ld	s8,80(a1)
ffffffffc0205b22:	0585bc83          	ld	s9,88(a1)
ffffffffc0205b26:	0605bd03          	ld	s10,96(a1)
ffffffffc0205b2a:	0685bd83          	ld	s11,104(a1)
ffffffffc0205b2e:	8082                	ret

ffffffffc0205b30 <alloc_proc>:
ffffffffc0205b30:	1141                	addi	sp,sp,-16
ffffffffc0205b32:	15000513          	li	a0,336
ffffffffc0205b36:	e022                	sd	s0,0(sp)
ffffffffc0205b38:	e406                	sd	ra,8(sp)
ffffffffc0205b3a:	a02fc0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0205b3e:	842a                	mv	s0,a0
ffffffffc0205b40:	c151                	beqz	a0,ffffffffc0205bc4 <alloc_proc+0x94>
ffffffffc0205b42:	57fd                	li	a5,-1
ffffffffc0205b44:	1782                	slli	a5,a5,0x20
ffffffffc0205b46:	e11c                	sd	a5,0(a0)
ffffffffc0205b48:	00052423          	sw	zero,8(a0)
ffffffffc0205b4c:	00053823          	sd	zero,16(a0)
ffffffffc0205b50:	00053c23          	sd	zero,24(a0)
ffffffffc0205b54:	02053023          	sd	zero,32(a0)
ffffffffc0205b58:	02053423          	sd	zero,40(a0)
ffffffffc0205b5c:	07000613          	li	a2,112
ffffffffc0205b60:	4581                	li	a1,0
ffffffffc0205b62:	03050513          	addi	a0,a0,48
ffffffffc0205b66:	081050ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0205b6a:	00091797          	auipc	a5,0x91
ffffffffc0205b6e:	d2e7b783          	ld	a5,-722(a5) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc0205b72:	0a043023          	sd	zero,160(s0)
ffffffffc0205b76:	0a042823          	sw	zero,176(s0)
ffffffffc0205b7a:	f45c                	sd	a5,168(s0)
ffffffffc0205b7c:	0b440513          	addi	a0,s0,180
ffffffffc0205b80:	4641                	li	a2,16
ffffffffc0205b82:	4581                	li	a1,0
ffffffffc0205b84:	063050ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0205b88:	4785                	li	a5,1
ffffffffc0205b8a:	11040713          	addi	a4,s0,272
ffffffffc0205b8e:	1782                	slli	a5,a5,0x20
ffffffffc0205b90:	0e042623          	sw	zero,236(s0)
ffffffffc0205b94:	0e043c23          	sd	zero,248(s0)
ffffffffc0205b98:	10043023          	sd	zero,256(s0)
ffffffffc0205b9c:	0e043823          	sd	zero,240(s0)
ffffffffc0205ba0:	10043423          	sd	zero,264(s0)
ffffffffc0205ba4:	12042023          	sw	zero,288(s0)
ffffffffc0205ba8:	12043423          	sd	zero,296(s0)
ffffffffc0205bac:	12043c23          	sd	zero,312(s0)
ffffffffc0205bb0:	12043823          	sd	zero,304(s0)
ffffffffc0205bb4:	14043423          	sd	zero,328(s0)
ffffffffc0205bb8:	14f43023          	sd	a5,320(s0)
ffffffffc0205bbc:	10e43c23          	sd	a4,280(s0)
ffffffffc0205bc0:	10e43823          	sd	a4,272(s0)
ffffffffc0205bc4:	60a2                	ld	ra,8(sp)
ffffffffc0205bc6:	8522                	mv	a0,s0
ffffffffc0205bc8:	6402                	ld	s0,0(sp)
ffffffffc0205bca:	0141                	addi	sp,sp,16
ffffffffc0205bcc:	8082                	ret

ffffffffc0205bce <forkret>:
ffffffffc0205bce:	00091797          	auipc	a5,0x91
ffffffffc0205bd2:	cfa7b783          	ld	a5,-774(a5) # ffffffffc02968c8 <current>
ffffffffc0205bd6:	73c8                	ld	a0,160(a5)
ffffffffc0205bd8:	e7afb06f          	j	ffffffffc0201252 <forkrets>

ffffffffc0205bdc <put_pgdir.isra.0>:
ffffffffc0205bdc:	1141                	addi	sp,sp,-16
ffffffffc0205bde:	e406                	sd	ra,8(sp)
ffffffffc0205be0:	c02007b7          	lui	a5,0xc0200
ffffffffc0205be4:	02f56f63          	bltu	a0,a5,ffffffffc0205c22 <put_pgdir.isra.0+0x46>
ffffffffc0205be8:	00091797          	auipc	a5,0x91
ffffffffc0205bec:	cc07b783          	ld	a5,-832(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0205bf0:	00091717          	auipc	a4,0x91
ffffffffc0205bf4:	cc073703          	ld	a4,-832(a4) # ffffffffc02968b0 <npage>
ffffffffc0205bf8:	8d1d                	sub	a0,a0,a5
ffffffffc0205bfa:	00c55793          	srli	a5,a0,0xc
ffffffffc0205bfe:	02e7ff63          	bgeu	a5,a4,ffffffffc0205c3c <put_pgdir.isra.0+0x60>
ffffffffc0205c02:	0000a717          	auipc	a4,0xa
ffffffffc0205c06:	fae73703          	ld	a4,-82(a4) # ffffffffc020fbb0 <nbase>
ffffffffc0205c0a:	00091517          	auipc	a0,0x91
ffffffffc0205c0e:	cae53503          	ld	a0,-850(a0) # ffffffffc02968b8 <pages>
ffffffffc0205c12:	60a2                	ld	ra,8(sp)
ffffffffc0205c14:	8f99                	sub	a5,a5,a4
ffffffffc0205c16:	079a                	slli	a5,a5,0x6
ffffffffc0205c18:	4585                	li	a1,1
ffffffffc0205c1a:	953e                	add	a0,a0,a5
ffffffffc0205c1c:	0141                	addi	sp,sp,16
ffffffffc0205c1e:	e05fc06f          	j	ffffffffc0202a22 <free_pages>
ffffffffc0205c22:	86aa                	mv	a3,a0
ffffffffc0205c24:	00007617          	auipc	a2,0x7
ffffffffc0205c28:	ae460613          	addi	a2,a2,-1308 # ffffffffc020c708 <etext+0xe32>
ffffffffc0205c2c:	07700593          	li	a1,119
ffffffffc0205c30:	00007517          	auipc	a0,0x7
ffffffffc0205c34:	a5850513          	addi	a0,a0,-1448 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0205c38:	df4fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0205c3c:	00007617          	auipc	a2,0x7
ffffffffc0205c40:	af460613          	addi	a2,a2,-1292 # ffffffffc020c730 <etext+0xe5a>
ffffffffc0205c44:	06900593          	li	a1,105
ffffffffc0205c48:	00007517          	auipc	a0,0x7
ffffffffc0205c4c:	a4050513          	addi	a0,a0,-1472 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0205c50:	ddcfa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0205c54 <setup_pgdir>:
ffffffffc0205c54:	1101                	addi	sp,sp,-32
ffffffffc0205c56:	e426                	sd	s1,8(sp)
ffffffffc0205c58:	84aa                	mv	s1,a0
ffffffffc0205c5a:	4505                	li	a0,1
ffffffffc0205c5c:	ec06                	sd	ra,24(sp)
ffffffffc0205c5e:	d8bfc0ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0205c62:	cd29                	beqz	a0,ffffffffc0205cbc <setup_pgdir+0x68>
ffffffffc0205c64:	00091697          	auipc	a3,0x91
ffffffffc0205c68:	c546b683          	ld	a3,-940(a3) # ffffffffc02968b8 <pages>
ffffffffc0205c6c:	0000a797          	auipc	a5,0xa
ffffffffc0205c70:	f447b783          	ld	a5,-188(a5) # ffffffffc020fbb0 <nbase>
ffffffffc0205c74:	00091717          	auipc	a4,0x91
ffffffffc0205c78:	c3c73703          	ld	a4,-964(a4) # ffffffffc02968b0 <npage>
ffffffffc0205c7c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205c80:	8699                	srai	a3,a3,0x6
ffffffffc0205c82:	96be                	add	a3,a3,a5
ffffffffc0205c84:	00c69793          	slli	a5,a3,0xc
ffffffffc0205c88:	e822                	sd	s0,16(sp)
ffffffffc0205c8a:	83b1                	srli	a5,a5,0xc
ffffffffc0205c8c:	06b2                	slli	a3,a3,0xc
ffffffffc0205c8e:	02e7f963          	bgeu	a5,a4,ffffffffc0205cc0 <setup_pgdir+0x6c>
ffffffffc0205c92:	00091797          	auipc	a5,0x91
ffffffffc0205c96:	c167b783          	ld	a5,-1002(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0205c9a:	00091597          	auipc	a1,0x91
ffffffffc0205c9e:	c065b583          	ld	a1,-1018(a1) # ffffffffc02968a0 <boot_pgdir_va>
ffffffffc0205ca2:	6605                	lui	a2,0x1
ffffffffc0205ca4:	00f68433          	add	s0,a3,a5
ffffffffc0205ca8:	8522                	mv	a0,s0
ffffffffc0205caa:	78c050ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0205cae:	ec80                	sd	s0,24(s1)
ffffffffc0205cb0:	6442                	ld	s0,16(sp)
ffffffffc0205cb2:	4501                	li	a0,0
ffffffffc0205cb4:	60e2                	ld	ra,24(sp)
ffffffffc0205cb6:	64a2                	ld	s1,8(sp)
ffffffffc0205cb8:	6105                	addi	sp,sp,32
ffffffffc0205cba:	8082                	ret
ffffffffc0205cbc:	5571                	li	a0,-4
ffffffffc0205cbe:	bfdd                	j	ffffffffc0205cb4 <setup_pgdir+0x60>
ffffffffc0205cc0:	00007617          	auipc	a2,0x7
ffffffffc0205cc4:	9a060613          	addi	a2,a2,-1632 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0205cc8:	07100593          	li	a1,113
ffffffffc0205ccc:	00007517          	auipc	a0,0x7
ffffffffc0205cd0:	9bc50513          	addi	a0,a0,-1604 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0205cd4:	d58fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc0205cd8 <proc_run>:
ffffffffc0205cd8:	00091697          	auipc	a3,0x91
ffffffffc0205cdc:	bf06b683          	ld	a3,-1040(a3) # ffffffffc02968c8 <current>
ffffffffc0205ce0:	04a68663          	beq	a3,a0,ffffffffc0205d2c <proc_run+0x54>
ffffffffc0205ce4:	1101                	addi	sp,sp,-32
ffffffffc0205ce6:	ec06                	sd	ra,24(sp)
ffffffffc0205ce8:	100027f3          	csrr	a5,sstatus
ffffffffc0205cec:	8b89                	andi	a5,a5,2
ffffffffc0205cee:	4601                	li	a2,0
ffffffffc0205cf0:	ef9d                	bnez	a5,ffffffffc0205d2e <proc_run+0x56>
ffffffffc0205cf2:	755c                	ld	a5,168(a0)
ffffffffc0205cf4:	577d                	li	a4,-1
ffffffffc0205cf6:	177e                	slli	a4,a4,0x3f
ffffffffc0205cf8:	83b1                	srli	a5,a5,0xc
ffffffffc0205cfa:	e032                	sd	a2,0(sp)
ffffffffc0205cfc:	00091597          	auipc	a1,0x91
ffffffffc0205d00:	bca5b623          	sd	a0,-1076(a1) # ffffffffc02968c8 <current>
ffffffffc0205d04:	8fd9                	or	a5,a5,a4
ffffffffc0205d06:	18079073          	csrw	satp,a5
ffffffffc0205d0a:	12000073          	sfence.vma
ffffffffc0205d0e:	03050593          	addi	a1,a0,48
ffffffffc0205d12:	03068513          	addi	a0,a3,48
ffffffffc0205d16:	db1ff0ef          	jal	ffffffffc0205ac6 <switch_to>
ffffffffc0205d1a:	6602                	ld	a2,0(sp)
ffffffffc0205d1c:	e601                	bnez	a2,ffffffffc0205d24 <proc_run+0x4c>
ffffffffc0205d1e:	60e2                	ld	ra,24(sp)
ffffffffc0205d20:	6105                	addi	sp,sp,32
ffffffffc0205d22:	8082                	ret
ffffffffc0205d24:	60e2                	ld	ra,24(sp)
ffffffffc0205d26:	6105                	addi	sp,sp,32
ffffffffc0205d28:	fd5fa06f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc0205d2c:	8082                	ret
ffffffffc0205d2e:	e42a                	sd	a0,8(sp)
ffffffffc0205d30:	e036                	sd	a3,0(sp)
ffffffffc0205d32:	fd1fa0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0205d36:	6522                	ld	a0,8(sp)
ffffffffc0205d38:	6682                	ld	a3,0(sp)
ffffffffc0205d3a:	4605                	li	a2,1
ffffffffc0205d3c:	bf5d                	j	ffffffffc0205cf2 <proc_run+0x1a>

ffffffffc0205d3e <do_fork>:
ffffffffc0205d3e:	00091717          	auipc	a4,0x91
ffffffffc0205d42:	b8272703          	lw	a4,-1150(a4) # ffffffffc02968c0 <nr_process>
ffffffffc0205d46:	6785                	lui	a5,0x1
ffffffffc0205d48:	36f75363          	bge	a4,a5,ffffffffc02060ae <do_fork+0x370>
ffffffffc0205d4c:	7119                	addi	sp,sp,-128
ffffffffc0205d4e:	f8a2                	sd	s0,112(sp)
ffffffffc0205d50:	f4a6                	sd	s1,104(sp)
ffffffffc0205d52:	f0ca                	sd	s2,96(sp)
ffffffffc0205d54:	ecce                	sd	s3,88(sp)
ffffffffc0205d56:	fc86                	sd	ra,120(sp)
ffffffffc0205d58:	892e                	mv	s2,a1
ffffffffc0205d5a:	84b2                	mv	s1,a2
ffffffffc0205d5c:	89aa                	mv	s3,a0
ffffffffc0205d5e:	dd3ff0ef          	jal	ffffffffc0205b30 <alloc_proc>
ffffffffc0205d62:	842a                	mv	s0,a0
ffffffffc0205d64:	2a050063          	beqz	a0,ffffffffc0206004 <do_fork+0x2c6>
ffffffffc0205d68:	f466                	sd	s9,40(sp)
ffffffffc0205d6a:	00091c97          	auipc	s9,0x91
ffffffffc0205d6e:	b5ec8c93          	addi	s9,s9,-1186 # ffffffffc02968c8 <current>
ffffffffc0205d72:	000cb783          	ld	a5,0(s9)
ffffffffc0205d76:	4509                	li	a0,2
ffffffffc0205d78:	f01c                	sd	a5,32(s0)
ffffffffc0205d7a:	0e07a623          	sw	zero,236(a5) # 10ec <_binary_bin_swap_img_size-0x6c14>
ffffffffc0205d7e:	c6bfc0ef          	jal	ffffffffc02029e8 <alloc_pages>
ffffffffc0205d82:	26050d63          	beqz	a0,ffffffffc0205ffc <do_fork+0x2be>
ffffffffc0205d86:	e4d6                	sd	s5,72(sp)
ffffffffc0205d88:	00091a97          	auipc	s5,0x91
ffffffffc0205d8c:	b30a8a93          	addi	s5,s5,-1232 # ffffffffc02968b8 <pages>
ffffffffc0205d90:	000ab783          	ld	a5,0(s5)
ffffffffc0205d94:	e8d2                	sd	s4,80(sp)
ffffffffc0205d96:	0000aa17          	auipc	s4,0xa
ffffffffc0205d9a:	e1aa3a03          	ld	s4,-486(s4) # ffffffffc020fbb0 <nbase>
ffffffffc0205d9e:	40f506b3          	sub	a3,a0,a5
ffffffffc0205da2:	e0da                	sd	s6,64(sp)
ffffffffc0205da4:	8699                	srai	a3,a3,0x6
ffffffffc0205da6:	00091b17          	auipc	s6,0x91
ffffffffc0205daa:	b0ab0b13          	addi	s6,s6,-1270 # ffffffffc02968b0 <npage>
ffffffffc0205dae:	96d2                	add	a3,a3,s4
ffffffffc0205db0:	000b3703          	ld	a4,0(s6)
ffffffffc0205db4:	00c69793          	slli	a5,a3,0xc
ffffffffc0205db8:	fc5e                	sd	s7,56(sp)
ffffffffc0205dba:	f862                	sd	s8,48(sp)
ffffffffc0205dbc:	83b1                	srli	a5,a5,0xc
ffffffffc0205dbe:	06b2                	slli	a3,a3,0xc
ffffffffc0205dc0:	34e7fa63          	bgeu	a5,a4,ffffffffc0206114 <do_fork+0x3d6>
ffffffffc0205dc4:	000cb703          	ld	a4,0(s9)
ffffffffc0205dc8:	00091b97          	auipc	s7,0x91
ffffffffc0205dcc:	ae0b8b93          	addi	s7,s7,-1312 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0205dd0:	000bb783          	ld	a5,0(s7)
ffffffffc0205dd4:	02873c03          	ld	s8,40(a4)
ffffffffc0205dd8:	96be                	add	a3,a3,a5
ffffffffc0205dda:	e814                	sd	a3,16(s0)
ffffffffc0205ddc:	020c0a63          	beqz	s8,ffffffffc0205e10 <do_fork+0xd2>
ffffffffc0205de0:	1009f793          	andi	a5,s3,256
ffffffffc0205de4:	1c078363          	beqz	a5,ffffffffc0205faa <do_fork+0x26c>
ffffffffc0205de8:	030c2703          	lw	a4,48(s8)
ffffffffc0205dec:	018c3783          	ld	a5,24(s8)
ffffffffc0205df0:	c02006b7          	lui	a3,0xc0200
ffffffffc0205df4:	2705                	addiw	a4,a4,1
ffffffffc0205df6:	02ec2823          	sw	a4,48(s8)
ffffffffc0205dfa:	03843423          	sd	s8,40(s0)
ffffffffc0205dfe:	2cd7ee63          	bltu	a5,a3,ffffffffc02060da <do_fork+0x39c>
ffffffffc0205e02:	000bb603          	ld	a2,0(s7)
ffffffffc0205e06:	000cb703          	ld	a4,0(s9)
ffffffffc0205e0a:	6814                	ld	a3,16(s0)
ffffffffc0205e0c:	8f91                	sub	a5,a5,a2
ffffffffc0205e0e:	f45c                	sd	a5,168(s0)
ffffffffc0205e10:	6789                	lui	a5,0x2
ffffffffc0205e12:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0205e16:	96be                	add	a3,a3,a5
ffffffffc0205e18:	f054                	sd	a3,160(s0)
ffffffffc0205e1a:	87b6                	mv	a5,a3
ffffffffc0205e1c:	12048613          	addi	a2,s1,288
ffffffffc0205e20:	688c                	ld	a1,16(s1)
ffffffffc0205e22:	0004b803          	ld	a6,0(s1)
ffffffffc0205e26:	6488                	ld	a0,8(s1)
ffffffffc0205e28:	eb8c                	sd	a1,16(a5)
ffffffffc0205e2a:	0107b023          	sd	a6,0(a5)
ffffffffc0205e2e:	e788                	sd	a0,8(a5)
ffffffffc0205e30:	6c8c                	ld	a1,24(s1)
ffffffffc0205e32:	02048493          	addi	s1,s1,32
ffffffffc0205e36:	02078793          	addi	a5,a5,32
ffffffffc0205e3a:	feb7bc23          	sd	a1,-8(a5)
ffffffffc0205e3e:	fec491e3          	bne	s1,a2,ffffffffc0205e20 <do_fork+0xe2>
ffffffffc0205e42:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
ffffffffc0205e46:	1c090163          	beqz	s2,ffffffffc0206008 <do_fork+0x2ca>
ffffffffc0205e4a:	14873483          	ld	s1,328(a4)
ffffffffc0205e4e:	00000797          	auipc	a5,0x0
ffffffffc0205e52:	d8078793          	addi	a5,a5,-640 # ffffffffc0205bce <forkret>
ffffffffc0205e56:	0126b823          	sd	s2,16(a3)
ffffffffc0205e5a:	fc14                	sd	a3,56(s0)
ffffffffc0205e5c:	f81c                	sd	a5,48(s0)
ffffffffc0205e5e:	24048c63          	beqz	s1,ffffffffc02060b6 <do_fork+0x378>
ffffffffc0205e62:	03499793          	slli	a5,s3,0x34
ffffffffc0205e66:	0007cd63          	bltz	a5,ffffffffc0205e80 <do_fork+0x142>
ffffffffc0205e6a:	a65ff0ef          	jal	ffffffffc02058ce <files_create>
ffffffffc0205e6e:	892a                	mv	s2,a0
ffffffffc0205e70:	20050163          	beqz	a0,ffffffffc0206072 <do_fork+0x334>
ffffffffc0205e74:	85a6                	mv	a1,s1
ffffffffc0205e76:	b91ff0ef          	jal	ffffffffc0205a06 <dup_files>
ffffffffc0205e7a:	84ca                	mv	s1,s2
ffffffffc0205e7c:	1e051863          	bnez	a0,ffffffffc020606c <do_fork+0x32e>
ffffffffc0205e80:	489c                	lw	a5,16(s1)
ffffffffc0205e82:	2785                	addiw	a5,a5,1
ffffffffc0205e84:	c89c                	sw	a5,16(s1)
ffffffffc0205e86:	14943423          	sd	s1,328(s0)
ffffffffc0205e8a:	100027f3          	csrr	a5,sstatus
ffffffffc0205e8e:	8b89                	andi	a5,a5,2
ffffffffc0205e90:	1c079a63          	bnez	a5,ffffffffc0206064 <do_fork+0x326>
ffffffffc0205e94:	4901                	li	s2,0
ffffffffc0205e96:	0008b517          	auipc	a0,0x8b
ffffffffc0205e9a:	1c652503          	lw	a0,454(a0) # ffffffffc029105c <last_pid.1>
ffffffffc0205e9e:	6789                	lui	a5,0x2
ffffffffc0205ea0:	2505                	addiw	a0,a0,1
ffffffffc0205ea2:	0008b717          	auipc	a4,0x8b
ffffffffc0205ea6:	1aa72d23          	sw	a0,442(a4) # ffffffffc029105c <last_pid.1>
ffffffffc0205eaa:	16f55163          	bge	a0,a5,ffffffffc020600c <do_fork+0x2ce>
ffffffffc0205eae:	0008b797          	auipc	a5,0x8b
ffffffffc0205eb2:	1aa7a783          	lw	a5,426(a5) # ffffffffc0291058 <next_safe.0>
ffffffffc0205eb6:	00090497          	auipc	s1,0x90
ffffffffc0205eba:	90a48493          	addi	s1,s1,-1782 # ffffffffc02957c0 <proc_list>
ffffffffc0205ebe:	06f54563          	blt	a0,a5,ffffffffc0205f28 <do_fork+0x1ea>
ffffffffc0205ec2:	00090497          	auipc	s1,0x90
ffffffffc0205ec6:	8fe48493          	addi	s1,s1,-1794 # ffffffffc02957c0 <proc_list>
ffffffffc0205eca:	0084b883          	ld	a7,8(s1)
ffffffffc0205ece:	6789                	lui	a5,0x2
ffffffffc0205ed0:	0008b717          	auipc	a4,0x8b
ffffffffc0205ed4:	18f72423          	sw	a5,392(a4) # ffffffffc0291058 <next_safe.0>
ffffffffc0205ed8:	86aa                	mv	a3,a0
ffffffffc0205eda:	4581                	li	a1,0
ffffffffc0205edc:	04988063          	beq	a7,s1,ffffffffc0205f1c <do_fork+0x1de>
ffffffffc0205ee0:	882e                	mv	a6,a1
ffffffffc0205ee2:	87c6                	mv	a5,a7
ffffffffc0205ee4:	6609                	lui	a2,0x2
ffffffffc0205ee6:	a811                	j	ffffffffc0205efa <do_fork+0x1bc>
ffffffffc0205ee8:	00e6d663          	bge	a3,a4,ffffffffc0205ef4 <do_fork+0x1b6>
ffffffffc0205eec:	00c75463          	bge	a4,a2,ffffffffc0205ef4 <do_fork+0x1b6>
ffffffffc0205ef0:	863a                	mv	a2,a4
ffffffffc0205ef2:	4805                	li	a6,1
ffffffffc0205ef4:	679c                	ld	a5,8(a5)
ffffffffc0205ef6:	00978d63          	beq	a5,s1,ffffffffc0205f10 <do_fork+0x1d2>
ffffffffc0205efa:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_bin_swap_img_size-0x5dc4>
ffffffffc0205efe:	fed715e3          	bne	a4,a3,ffffffffc0205ee8 <do_fork+0x1aa>
ffffffffc0205f02:	2685                	addiw	a3,a3,1
ffffffffc0205f04:	14c6da63          	bge	a3,a2,ffffffffc0206058 <do_fork+0x31a>
ffffffffc0205f08:	679c                	ld	a5,8(a5)
ffffffffc0205f0a:	4585                	li	a1,1
ffffffffc0205f0c:	fe9797e3          	bne	a5,s1,ffffffffc0205efa <do_fork+0x1bc>
ffffffffc0205f10:	00080663          	beqz	a6,ffffffffc0205f1c <do_fork+0x1de>
ffffffffc0205f14:	0008b797          	auipc	a5,0x8b
ffffffffc0205f18:	14c7a223          	sw	a2,324(a5) # ffffffffc0291058 <next_safe.0>
ffffffffc0205f1c:	c591                	beqz	a1,ffffffffc0205f28 <do_fork+0x1ea>
ffffffffc0205f1e:	0008b797          	auipc	a5,0x8b
ffffffffc0205f22:	12d7af23          	sw	a3,318(a5) # ffffffffc029105c <last_pid.1>
ffffffffc0205f26:	8536                	mv	a0,a3
ffffffffc0205f28:	c048                	sw	a0,4(s0)
ffffffffc0205f2a:	45a9                	li	a1,10
ffffffffc0205f2c:	195050ef          	jal	ffffffffc020b8c0 <hash32>
ffffffffc0205f30:	02051793          	slli	a5,a0,0x20
ffffffffc0205f34:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205f38:	0008c797          	auipc	a5,0x8c
ffffffffc0205f3c:	88878793          	addi	a5,a5,-1912 # ffffffffc02917c0 <hash_list>
ffffffffc0205f40:	953e                	add	a0,a0,a5
ffffffffc0205f42:	6518                	ld	a4,8(a0)
ffffffffc0205f44:	0d840793          	addi	a5,s0,216
ffffffffc0205f48:	6490                	ld	a2,8(s1)
ffffffffc0205f4a:	e31c                	sd	a5,0(a4)
ffffffffc0205f4c:	e51c                	sd	a5,8(a0)
ffffffffc0205f4e:	f078                	sd	a4,224(s0)
ffffffffc0205f50:	0c840793          	addi	a5,s0,200
ffffffffc0205f54:	7018                	ld	a4,32(s0)
ffffffffc0205f56:	ec68                	sd	a0,216(s0)
ffffffffc0205f58:	e21c                	sd	a5,0(a2)
ffffffffc0205f5a:	0e043c23          	sd	zero,248(s0)
ffffffffc0205f5e:	7b74                	ld	a3,240(a4)
ffffffffc0205f60:	e49c                	sd	a5,8(s1)
ffffffffc0205f62:	e870                	sd	a2,208(s0)
ffffffffc0205f64:	e464                	sd	s1,200(s0)
ffffffffc0205f66:	10d43023          	sd	a3,256(s0)
ffffffffc0205f6a:	c299                	beqz	a3,ffffffffc0205f70 <do_fork+0x232>
ffffffffc0205f6c:	fee0                	sd	s0,248(a3)
ffffffffc0205f6e:	7018                	ld	a4,32(s0)
ffffffffc0205f70:	00091797          	auipc	a5,0x91
ffffffffc0205f74:	9507a783          	lw	a5,-1712(a5) # ffffffffc02968c0 <nr_process>
ffffffffc0205f78:	fb60                	sd	s0,240(a4)
ffffffffc0205f7a:	2785                	addiw	a5,a5,1
ffffffffc0205f7c:	00091717          	auipc	a4,0x91
ffffffffc0205f80:	94f72223          	sw	a5,-1724(a4) # ffffffffc02968c0 <nr_process>
ffffffffc0205f84:	08091a63          	bnez	s2,ffffffffc0206018 <do_fork+0x2da>
ffffffffc0205f88:	8522                	mv	a0,s0
ffffffffc0205f8a:	450010ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc0205f8e:	4048                	lw	a0,4(s0)
ffffffffc0205f90:	6a46                	ld	s4,80(sp)
ffffffffc0205f92:	6aa6                	ld	s5,72(sp)
ffffffffc0205f94:	6b06                	ld	s6,64(sp)
ffffffffc0205f96:	7be2                	ld	s7,56(sp)
ffffffffc0205f98:	7c42                	ld	s8,48(sp)
ffffffffc0205f9a:	7ca2                	ld	s9,40(sp)
ffffffffc0205f9c:	70e6                	ld	ra,120(sp)
ffffffffc0205f9e:	7446                	ld	s0,112(sp)
ffffffffc0205fa0:	74a6                	ld	s1,104(sp)
ffffffffc0205fa2:	7906                	ld	s2,96(sp)
ffffffffc0205fa4:	69e6                	ld	s3,88(sp)
ffffffffc0205fa6:	6109                	addi	sp,sp,128
ffffffffc0205fa8:	8082                	ret
ffffffffc0205faa:	f06a                	sd	s10,32(sp)
ffffffffc0205fac:	acefb0ef          	jal	ffffffffc020127a <mm_create>
ffffffffc0205fb0:	8d2a                	mv	s10,a0
ffffffffc0205fb2:	10050063          	beqz	a0,ffffffffc02060b2 <do_fork+0x374>
ffffffffc0205fb6:	c9fff0ef          	jal	ffffffffc0205c54 <setup_pgdir>
ffffffffc0205fba:	c135                	beqz	a0,ffffffffc020601e <do_fork+0x2e0>
ffffffffc0205fbc:	856a                	mv	a0,s10
ffffffffc0205fbe:	c08fb0ef          	jal	ffffffffc02013c6 <mm_destroy>
ffffffffc0205fc2:	7d02                	ld	s10,32(sp)
ffffffffc0205fc4:	6814                	ld	a3,16(s0)
ffffffffc0205fc6:	c02007b7          	lui	a5,0xc0200
ffffffffc0205fca:	16f6e363          	bltu	a3,a5,ffffffffc0206130 <do_fork+0x3f2>
ffffffffc0205fce:	000bb783          	ld	a5,0(s7)
ffffffffc0205fd2:	000b3703          	ld	a4,0(s6)
ffffffffc0205fd6:	40f687b3          	sub	a5,a3,a5
ffffffffc0205fda:	83b1                	srli	a5,a5,0xc
ffffffffc0205fdc:	10e7fe63          	bgeu	a5,a4,ffffffffc02060f8 <do_fork+0x3ba>
ffffffffc0205fe0:	000ab503          	ld	a0,0(s5)
ffffffffc0205fe4:	414787b3          	sub	a5,a5,s4
ffffffffc0205fe8:	079a                	slli	a5,a5,0x6
ffffffffc0205fea:	953e                	add	a0,a0,a5
ffffffffc0205fec:	4589                	li	a1,2
ffffffffc0205fee:	a35fc0ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc0205ff2:	6a46                	ld	s4,80(sp)
ffffffffc0205ff4:	6aa6                	ld	s5,72(sp)
ffffffffc0205ff6:	6b06                	ld	s6,64(sp)
ffffffffc0205ff8:	7be2                	ld	s7,56(sp)
ffffffffc0205ffa:	7c42                	ld	s8,48(sp)
ffffffffc0205ffc:	8522                	mv	a0,s0
ffffffffc0205ffe:	de5fb0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0206002:	7ca2                	ld	s9,40(sp)
ffffffffc0206004:	5571                	li	a0,-4
ffffffffc0206006:	bf59                	j	ffffffffc0205f9c <do_fork+0x25e>
ffffffffc0206008:	8936                	mv	s2,a3
ffffffffc020600a:	b581                	j	ffffffffc0205e4a <do_fork+0x10c>
ffffffffc020600c:	4505                	li	a0,1
ffffffffc020600e:	0008b797          	auipc	a5,0x8b
ffffffffc0206012:	04a7a723          	sw	a0,78(a5) # ffffffffc029105c <last_pid.1>
ffffffffc0206016:	b575                	j	ffffffffc0205ec2 <do_fork+0x184>
ffffffffc0206018:	ce5fa0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020601c:	b7b5                	j	ffffffffc0205f88 <do_fork+0x24a>
ffffffffc020601e:	038c0793          	addi	a5,s8,56
ffffffffc0206022:	853e                	mv	a0,a5
ffffffffc0206024:	e43e                	sd	a5,8(sp)
ffffffffc0206026:	ec6e                	sd	s11,24(sp)
ffffffffc0206028:	fb0fe0ef          	jal	ffffffffc02047d8 <down>
ffffffffc020602c:	000cb783          	ld	a5,0(s9)
ffffffffc0206030:	c781                	beqz	a5,ffffffffc0206038 <do_fork+0x2fa>
ffffffffc0206032:	43dc                	lw	a5,4(a5)
ffffffffc0206034:	04fc2823          	sw	a5,80(s8)
ffffffffc0206038:	85e2                	mv	a1,s8
ffffffffc020603a:	856a                	mv	a0,s10
ffffffffc020603c:	ca8fb0ef          	jal	ffffffffc02014e4 <dup_mmap>
ffffffffc0206040:	8daa                	mv	s11,a0
ffffffffc0206042:	6522                	ld	a0,8(sp)
ffffffffc0206044:	f90fe0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0206048:	040c2823          	sw	zero,80(s8)
ffffffffc020604c:	8c6a                	mv	s8,s10
ffffffffc020604e:	040d9763          	bnez	s11,ffffffffc020609c <do_fork+0x35e>
ffffffffc0206052:	7d02                	ld	s10,32(sp)
ffffffffc0206054:	6de2                	ld	s11,24(sp)
ffffffffc0206056:	bb49                	j	ffffffffc0205de8 <do_fork+0xaa>
ffffffffc0206058:	6789                	lui	a5,0x2
ffffffffc020605a:	00f6c363          	blt	a3,a5,ffffffffc0206060 <do_fork+0x322>
ffffffffc020605e:	4685                	li	a3,1
ffffffffc0206060:	4585                	li	a1,1
ffffffffc0206062:	bdad                	j	ffffffffc0205edc <do_fork+0x19e>
ffffffffc0206064:	c9ffa0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0206068:	4905                	li	s2,1
ffffffffc020606a:	b535                	j	ffffffffc0205e96 <do_fork+0x158>
ffffffffc020606c:	854a                	mv	a0,s2
ffffffffc020606e:	897ff0ef          	jal	ffffffffc0205904 <files_destroy>
ffffffffc0206072:	7408                	ld	a0,40(s0)
ffffffffc0206074:	d921                	beqz	a0,ffffffffc0205fc4 <do_fork+0x286>
ffffffffc0206076:	591c                	lw	a5,48(a0)
ffffffffc0206078:	37fd                	addiw	a5,a5,-1 # 1fff <_binary_bin_swap_img_size-0x5d01>
ffffffffc020607a:	d91c                	sw	a5,48(a0)
ffffffffc020607c:	c781                	beqz	a5,ffffffffc0206084 <do_fork+0x346>
ffffffffc020607e:	02043423          	sd	zero,40(s0)
ffffffffc0206082:	b789                	j	ffffffffc0205fc4 <do_fork+0x286>
ffffffffc0206084:	cf8fb0ef          	jal	ffffffffc020157c <exit_mmap>
ffffffffc0206088:	741c                	ld	a5,40(s0)
ffffffffc020608a:	6f88                	ld	a0,24(a5)
ffffffffc020608c:	b51ff0ef          	jal	ffffffffc0205bdc <put_pgdir.isra.0>
ffffffffc0206090:	7408                	ld	a0,40(s0)
ffffffffc0206092:	b34fb0ef          	jal	ffffffffc02013c6 <mm_destroy>
ffffffffc0206096:	02043423          	sd	zero,40(s0)
ffffffffc020609a:	b72d                	j	ffffffffc0205fc4 <do_fork+0x286>
ffffffffc020609c:	856a                	mv	a0,s10
ffffffffc020609e:	cdefb0ef          	jal	ffffffffc020157c <exit_mmap>
ffffffffc02060a2:	018d3503          	ld	a0,24(s10) # fffffffffff80018 <end+0x3fce9708>
ffffffffc02060a6:	b37ff0ef          	jal	ffffffffc0205bdc <put_pgdir.isra.0>
ffffffffc02060aa:	6de2                	ld	s11,24(sp)
ffffffffc02060ac:	bf01                	j	ffffffffc0205fbc <do_fork+0x27e>
ffffffffc02060ae:	556d                	li	a0,-5
ffffffffc02060b0:	8082                	ret
ffffffffc02060b2:	7d02                	ld	s10,32(sp)
ffffffffc02060b4:	bf01                	j	ffffffffc0205fc4 <do_fork+0x286>
ffffffffc02060b6:	00007697          	auipc	a3,0x7
ffffffffc02060ba:	69a68693          	addi	a3,a3,1690 # ffffffffc020d750 <etext+0x1e7a>
ffffffffc02060be:	00006617          	auipc	a2,0x6
ffffffffc02060c2:	cd260613          	addi	a2,a2,-814 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02060c6:	1cc00593          	li	a1,460
ffffffffc02060ca:	00007517          	auipc	a0,0x7
ffffffffc02060ce:	66e50513          	addi	a0,a0,1646 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02060d2:	f06a                	sd	s10,32(sp)
ffffffffc02060d4:	ec6e                	sd	s11,24(sp)
ffffffffc02060d6:	956fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02060da:	86be                	mv	a3,a5
ffffffffc02060dc:	00006617          	auipc	a2,0x6
ffffffffc02060e0:	62c60613          	addi	a2,a2,1580 # ffffffffc020c708 <etext+0xe32>
ffffffffc02060e4:	1ac00593          	li	a1,428
ffffffffc02060e8:	00007517          	auipc	a0,0x7
ffffffffc02060ec:	65050513          	addi	a0,a0,1616 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02060f0:	f06a                	sd	s10,32(sp)
ffffffffc02060f2:	ec6e                	sd	s11,24(sp)
ffffffffc02060f4:	938fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc02060f8:	00006617          	auipc	a2,0x6
ffffffffc02060fc:	63860613          	addi	a2,a2,1592 # ffffffffc020c730 <etext+0xe5a>
ffffffffc0206100:	06900593          	li	a1,105
ffffffffc0206104:	00006517          	auipc	a0,0x6
ffffffffc0206108:	58450513          	addi	a0,a0,1412 # ffffffffc020c688 <etext+0xdb2>
ffffffffc020610c:	f06a                	sd	s10,32(sp)
ffffffffc020610e:	ec6e                	sd	s11,24(sp)
ffffffffc0206110:	91cfa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206114:	00006617          	auipc	a2,0x6
ffffffffc0206118:	54c60613          	addi	a2,a2,1356 # ffffffffc020c660 <etext+0xd8a>
ffffffffc020611c:	07100593          	li	a1,113
ffffffffc0206120:	00006517          	auipc	a0,0x6
ffffffffc0206124:	56850513          	addi	a0,a0,1384 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0206128:	f06a                	sd	s10,32(sp)
ffffffffc020612a:	ec6e                	sd	s11,24(sp)
ffffffffc020612c:	900fa0ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206130:	00006617          	auipc	a2,0x6
ffffffffc0206134:	5d860613          	addi	a2,a2,1496 # ffffffffc020c708 <etext+0xe32>
ffffffffc0206138:	07700593          	li	a1,119
ffffffffc020613c:	00006517          	auipc	a0,0x6
ffffffffc0206140:	54c50513          	addi	a0,a0,1356 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0206144:	f06a                	sd	s10,32(sp)
ffffffffc0206146:	ec6e                	sd	s11,24(sp)
ffffffffc0206148:	8e4fa0ef          	jal	ffffffffc020022c <__panic>

ffffffffc020614c <kernel_thread>:
ffffffffc020614c:	7129                	addi	sp,sp,-320
ffffffffc020614e:	fa22                	sd	s0,304(sp)
ffffffffc0206150:	f626                	sd	s1,296(sp)
ffffffffc0206152:	f24a                	sd	s2,288(sp)
ffffffffc0206154:	842a                	mv	s0,a0
ffffffffc0206156:	84ae                	mv	s1,a1
ffffffffc0206158:	8932                	mv	s2,a2
ffffffffc020615a:	850a                	mv	a0,sp
ffffffffc020615c:	12000613          	li	a2,288
ffffffffc0206160:	4581                	li	a1,0
ffffffffc0206162:	fe06                	sd	ra,312(sp)
ffffffffc0206164:	282050ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0206168:	e0a2                	sd	s0,64(sp)
ffffffffc020616a:	e4a6                	sd	s1,72(sp)
ffffffffc020616c:	100027f3          	csrr	a5,sstatus
ffffffffc0206170:	edd7f793          	andi	a5,a5,-291
ffffffffc0206174:	1207e793          	ori	a5,a5,288
ffffffffc0206178:	860a                	mv	a2,sp
ffffffffc020617a:	10096513          	ori	a0,s2,256
ffffffffc020617e:	00000717          	auipc	a4,0x0
ffffffffc0206182:	94070713          	addi	a4,a4,-1728 # ffffffffc0205abe <kernel_thread_entry>
ffffffffc0206186:	4581                	li	a1,0
ffffffffc0206188:	e23e                	sd	a5,256(sp)
ffffffffc020618a:	e63a                	sd	a4,264(sp)
ffffffffc020618c:	bb3ff0ef          	jal	ffffffffc0205d3e <do_fork>
ffffffffc0206190:	70f2                	ld	ra,312(sp)
ffffffffc0206192:	7452                	ld	s0,304(sp)
ffffffffc0206194:	74b2                	ld	s1,296(sp)
ffffffffc0206196:	7912                	ld	s2,288(sp)
ffffffffc0206198:	6131                	addi	sp,sp,320
ffffffffc020619a:	8082                	ret

ffffffffc020619c <do_exit>:
ffffffffc020619c:	7179                	addi	sp,sp,-48
ffffffffc020619e:	f022                	sd	s0,32(sp)
ffffffffc02061a0:	00090417          	auipc	s0,0x90
ffffffffc02061a4:	72840413          	addi	s0,s0,1832 # ffffffffc02968c8 <current>
ffffffffc02061a8:	601c                	ld	a5,0(s0)
ffffffffc02061aa:	00090717          	auipc	a4,0x90
ffffffffc02061ae:	72e73703          	ld	a4,1838(a4) # ffffffffc02968d8 <idleproc>
ffffffffc02061b2:	f406                	sd	ra,40(sp)
ffffffffc02061b4:	ec26                	sd	s1,24(sp)
ffffffffc02061b6:	0ee78763          	beq	a5,a4,ffffffffc02062a4 <do_exit+0x108>
ffffffffc02061ba:	00090497          	auipc	s1,0x90
ffffffffc02061be:	71648493          	addi	s1,s1,1814 # ffffffffc02968d0 <initproc>
ffffffffc02061c2:	6098                	ld	a4,0(s1)
ffffffffc02061c4:	e84a                	sd	s2,16(sp)
ffffffffc02061c6:	10e78863          	beq	a5,a4,ffffffffc02062d6 <do_exit+0x13a>
ffffffffc02061ca:	7798                	ld	a4,40(a5)
ffffffffc02061cc:	892a                	mv	s2,a0
ffffffffc02061ce:	cb0d                	beqz	a4,ffffffffc0206200 <do_exit+0x64>
ffffffffc02061d0:	00090797          	auipc	a5,0x90
ffffffffc02061d4:	6c87b783          	ld	a5,1736(a5) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc02061d8:	56fd                	li	a3,-1
ffffffffc02061da:	16fe                	slli	a3,a3,0x3f
ffffffffc02061dc:	83b1                	srli	a5,a5,0xc
ffffffffc02061de:	8fd5                	or	a5,a5,a3
ffffffffc02061e0:	18079073          	csrw	satp,a5
ffffffffc02061e4:	5b1c                	lw	a5,48(a4)
ffffffffc02061e6:	37fd                	addiw	a5,a5,-1
ffffffffc02061e8:	db1c                	sw	a5,48(a4)
ffffffffc02061ea:	cbf1                	beqz	a5,ffffffffc02062be <do_exit+0x122>
ffffffffc02061ec:	601c                	ld	a5,0(s0)
ffffffffc02061ee:	1487b503          	ld	a0,328(a5)
ffffffffc02061f2:	0207b423          	sd	zero,40(a5)
ffffffffc02061f6:	c509                	beqz	a0,ffffffffc0206200 <do_exit+0x64>
ffffffffc02061f8:	491c                	lw	a5,16(a0)
ffffffffc02061fa:	37fd                	addiw	a5,a5,-1
ffffffffc02061fc:	c91c                	sw	a5,16(a0)
ffffffffc02061fe:	c3c5                	beqz	a5,ffffffffc020629e <do_exit+0x102>
ffffffffc0206200:	601c                	ld	a5,0(s0)
ffffffffc0206202:	470d                	li	a4,3
ffffffffc0206204:	0f27a423          	sw	s2,232(a5)
ffffffffc0206208:	c398                	sw	a4,0(a5)
ffffffffc020620a:	100027f3          	csrr	a5,sstatus
ffffffffc020620e:	8b89                	andi	a5,a5,2
ffffffffc0206210:	4901                	li	s2,0
ffffffffc0206212:	0c079e63          	bnez	a5,ffffffffc02062ee <do_exit+0x152>
ffffffffc0206216:	6018                	ld	a4,0(s0)
ffffffffc0206218:	800007b7          	lui	a5,0x80000
ffffffffc020621c:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc020621e:	7308                	ld	a0,32(a4)
ffffffffc0206220:	0ec52703          	lw	a4,236(a0)
ffffffffc0206224:	0cf70963          	beq	a4,a5,ffffffffc02062f6 <do_exit+0x15a>
ffffffffc0206228:	6018                	ld	a4,0(s0)
ffffffffc020622a:	7b7c                	ld	a5,240(a4)
ffffffffc020622c:	c7a1                	beqz	a5,ffffffffc0206274 <do_exit+0xd8>
ffffffffc020622e:	800005b7          	lui	a1,0x80000
ffffffffc0206232:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc0206234:	460d                	li	a2,3
ffffffffc0206236:	a021                	j	ffffffffc020623e <do_exit+0xa2>
ffffffffc0206238:	6018                	ld	a4,0(s0)
ffffffffc020623a:	7b7c                	ld	a5,240(a4)
ffffffffc020623c:	cf85                	beqz	a5,ffffffffc0206274 <do_exit+0xd8>
ffffffffc020623e:	1007b683          	ld	a3,256(a5)
ffffffffc0206242:	6088                	ld	a0,0(s1)
ffffffffc0206244:	fb74                	sd	a3,240(a4)
ffffffffc0206246:	0e07bc23          	sd	zero,248(a5)
ffffffffc020624a:	7978                	ld	a4,240(a0)
ffffffffc020624c:	10e7b023          	sd	a4,256(a5)
ffffffffc0206250:	c311                	beqz	a4,ffffffffc0206254 <do_exit+0xb8>
ffffffffc0206252:	ff7c                	sd	a5,248(a4)
ffffffffc0206254:	4398                	lw	a4,0(a5)
ffffffffc0206256:	f388                	sd	a0,32(a5)
ffffffffc0206258:	f97c                	sd	a5,240(a0)
ffffffffc020625a:	fcc71fe3          	bne	a4,a2,ffffffffc0206238 <do_exit+0x9c>
ffffffffc020625e:	0ec52783          	lw	a5,236(a0)
ffffffffc0206262:	fcb79be3          	bne	a5,a1,ffffffffc0206238 <do_exit+0x9c>
ffffffffc0206266:	174010ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc020626a:	800005b7          	lui	a1,0x80000
ffffffffc020626e:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc0206270:	460d                	li	a2,3
ffffffffc0206272:	b7d9                	j	ffffffffc0206238 <do_exit+0x9c>
ffffffffc0206274:	02091263          	bnez	s2,ffffffffc0206298 <do_exit+0xfc>
ffffffffc0206278:	25a010ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc020627c:	601c                	ld	a5,0(s0)
ffffffffc020627e:	00007617          	auipc	a2,0x7
ffffffffc0206282:	50a60613          	addi	a2,a2,1290 # ffffffffc020d788 <etext+0x1eb2>
ffffffffc0206286:	29f00593          	li	a1,671
ffffffffc020628a:	43d4                	lw	a3,4(a5)
ffffffffc020628c:	00007517          	auipc	a0,0x7
ffffffffc0206290:	4ac50513          	addi	a0,a0,1196 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206294:	f99f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206298:	a65fa0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020629c:	bff1                	j	ffffffffc0206278 <do_exit+0xdc>
ffffffffc020629e:	e66ff0ef          	jal	ffffffffc0205904 <files_destroy>
ffffffffc02062a2:	bfb9                	j	ffffffffc0206200 <do_exit+0x64>
ffffffffc02062a4:	00007617          	auipc	a2,0x7
ffffffffc02062a8:	4c460613          	addi	a2,a2,1220 # ffffffffc020d768 <etext+0x1e92>
ffffffffc02062ac:	26a00593          	li	a1,618
ffffffffc02062b0:	00007517          	auipc	a0,0x7
ffffffffc02062b4:	48850513          	addi	a0,a0,1160 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02062b8:	e84a                	sd	s2,16(sp)
ffffffffc02062ba:	f73f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02062be:	853a                	mv	a0,a4
ffffffffc02062c0:	e43a                	sd	a4,8(sp)
ffffffffc02062c2:	abafb0ef          	jal	ffffffffc020157c <exit_mmap>
ffffffffc02062c6:	6722                	ld	a4,8(sp)
ffffffffc02062c8:	6f08                	ld	a0,24(a4)
ffffffffc02062ca:	913ff0ef          	jal	ffffffffc0205bdc <put_pgdir.isra.0>
ffffffffc02062ce:	6522                	ld	a0,8(sp)
ffffffffc02062d0:	8f6fb0ef          	jal	ffffffffc02013c6 <mm_destroy>
ffffffffc02062d4:	bf21                	j	ffffffffc02061ec <do_exit+0x50>
ffffffffc02062d6:	00007617          	auipc	a2,0x7
ffffffffc02062da:	4a260613          	addi	a2,a2,1186 # ffffffffc020d778 <etext+0x1ea2>
ffffffffc02062de:	26e00593          	li	a1,622
ffffffffc02062e2:	00007517          	auipc	a0,0x7
ffffffffc02062e6:	45650513          	addi	a0,a0,1110 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02062ea:	f43f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02062ee:	a15fa0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc02062f2:	4905                	li	s2,1
ffffffffc02062f4:	b70d                	j	ffffffffc0206216 <do_exit+0x7a>
ffffffffc02062f6:	0e4010ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc02062fa:	b73d                	j	ffffffffc0206228 <do_exit+0x8c>

ffffffffc02062fc <do_wait.part.0>:
ffffffffc02062fc:	7179                	addi	sp,sp,-48
ffffffffc02062fe:	ec26                	sd	s1,24(sp)
ffffffffc0206300:	e84a                	sd	s2,16(sp)
ffffffffc0206302:	e44e                	sd	s3,8(sp)
ffffffffc0206304:	f406                	sd	ra,40(sp)
ffffffffc0206306:	f022                	sd	s0,32(sp)
ffffffffc0206308:	84aa                	mv	s1,a0
ffffffffc020630a:	892e                	mv	s2,a1
ffffffffc020630c:	00090997          	auipc	s3,0x90
ffffffffc0206310:	5bc98993          	addi	s3,s3,1468 # ffffffffc02968c8 <current>
ffffffffc0206314:	cd19                	beqz	a0,ffffffffc0206332 <do_wait.part.0+0x36>
ffffffffc0206316:	6789                	lui	a5,0x2
ffffffffc0206318:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_bin_swap_img_size-0x5d02>
ffffffffc020631a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020631e:	12e7f563          	bgeu	a5,a4,ffffffffc0206448 <do_wait.part.0+0x14c>
ffffffffc0206322:	70a2                	ld	ra,40(sp)
ffffffffc0206324:	7402                	ld	s0,32(sp)
ffffffffc0206326:	64e2                	ld	s1,24(sp)
ffffffffc0206328:	6942                	ld	s2,16(sp)
ffffffffc020632a:	69a2                	ld	s3,8(sp)
ffffffffc020632c:	5579                	li	a0,-2
ffffffffc020632e:	6145                	addi	sp,sp,48
ffffffffc0206330:	8082                	ret
ffffffffc0206332:	0009b703          	ld	a4,0(s3)
ffffffffc0206336:	7b60                	ld	s0,240(a4)
ffffffffc0206338:	d46d                	beqz	s0,ffffffffc0206322 <do_wait.part.0+0x26>
ffffffffc020633a:	468d                	li	a3,3
ffffffffc020633c:	a021                	j	ffffffffc0206344 <do_wait.part.0+0x48>
ffffffffc020633e:	10043403          	ld	s0,256(s0)
ffffffffc0206342:	c075                	beqz	s0,ffffffffc0206426 <do_wait.part.0+0x12a>
ffffffffc0206344:	401c                	lw	a5,0(s0)
ffffffffc0206346:	fed79ce3          	bne	a5,a3,ffffffffc020633e <do_wait.part.0+0x42>
ffffffffc020634a:	00090797          	auipc	a5,0x90
ffffffffc020634e:	58e7b783          	ld	a5,1422(a5) # ffffffffc02968d8 <idleproc>
ffffffffc0206352:	14878263          	beq	a5,s0,ffffffffc0206496 <do_wait.part.0+0x19a>
ffffffffc0206356:	00090797          	auipc	a5,0x90
ffffffffc020635a:	57a7b783          	ld	a5,1402(a5) # ffffffffc02968d0 <initproc>
ffffffffc020635e:	12f40c63          	beq	s0,a5,ffffffffc0206496 <do_wait.part.0+0x19a>
ffffffffc0206362:	00090663          	beqz	s2,ffffffffc020636e <do_wait.part.0+0x72>
ffffffffc0206366:	0e842783          	lw	a5,232(s0)
ffffffffc020636a:	00f92023          	sw	a5,0(s2)
ffffffffc020636e:	100027f3          	csrr	a5,sstatus
ffffffffc0206372:	8b89                	andi	a5,a5,2
ffffffffc0206374:	4601                	li	a2,0
ffffffffc0206376:	10079963          	bnez	a5,ffffffffc0206488 <do_wait.part.0+0x18c>
ffffffffc020637a:	6c74                	ld	a3,216(s0)
ffffffffc020637c:	7078                	ld	a4,224(s0)
ffffffffc020637e:	10043783          	ld	a5,256(s0)
ffffffffc0206382:	e698                	sd	a4,8(a3)
ffffffffc0206384:	e314                	sd	a3,0(a4)
ffffffffc0206386:	6474                	ld	a3,200(s0)
ffffffffc0206388:	6878                	ld	a4,208(s0)
ffffffffc020638a:	e698                	sd	a4,8(a3)
ffffffffc020638c:	e314                	sd	a3,0(a4)
ffffffffc020638e:	c789                	beqz	a5,ffffffffc0206398 <do_wait.part.0+0x9c>
ffffffffc0206390:	7c78                	ld	a4,248(s0)
ffffffffc0206392:	fff8                	sd	a4,248(a5)
ffffffffc0206394:	10043783          	ld	a5,256(s0)
ffffffffc0206398:	7c78                	ld	a4,248(s0)
ffffffffc020639a:	c36d                	beqz	a4,ffffffffc020647c <do_wait.part.0+0x180>
ffffffffc020639c:	10f73023          	sd	a5,256(a4)
ffffffffc02063a0:	00090797          	auipc	a5,0x90
ffffffffc02063a4:	5207a783          	lw	a5,1312(a5) # ffffffffc02968c0 <nr_process>
ffffffffc02063a8:	37fd                	addiw	a5,a5,-1
ffffffffc02063aa:	00090717          	auipc	a4,0x90
ffffffffc02063ae:	50f72b23          	sw	a5,1302(a4) # ffffffffc02968c0 <nr_process>
ffffffffc02063b2:	e271                	bnez	a2,ffffffffc0206476 <do_wait.part.0+0x17a>
ffffffffc02063b4:	6814                	ld	a3,16(s0)
ffffffffc02063b6:	c02007b7          	lui	a5,0xc0200
ffffffffc02063ba:	10f6e663          	bltu	a3,a5,ffffffffc02064c6 <do_wait.part.0+0x1ca>
ffffffffc02063be:	00090717          	auipc	a4,0x90
ffffffffc02063c2:	4ea73703          	ld	a4,1258(a4) # ffffffffc02968a8 <va_pa_offset>
ffffffffc02063c6:	00090797          	auipc	a5,0x90
ffffffffc02063ca:	4ea7b783          	ld	a5,1258(a5) # ffffffffc02968b0 <npage>
ffffffffc02063ce:	8e99                	sub	a3,a3,a4
ffffffffc02063d0:	82b1                	srli	a3,a3,0xc
ffffffffc02063d2:	0cf6fe63          	bgeu	a3,a5,ffffffffc02064ae <do_wait.part.0+0x1b2>
ffffffffc02063d6:	00009797          	auipc	a5,0x9
ffffffffc02063da:	7da7b783          	ld	a5,2010(a5) # ffffffffc020fbb0 <nbase>
ffffffffc02063de:	00090517          	auipc	a0,0x90
ffffffffc02063e2:	4da53503          	ld	a0,1242(a0) # ffffffffc02968b8 <pages>
ffffffffc02063e6:	4589                	li	a1,2
ffffffffc02063e8:	8e9d                	sub	a3,a3,a5
ffffffffc02063ea:	069a                	slli	a3,a3,0x6
ffffffffc02063ec:	9536                	add	a0,a0,a3
ffffffffc02063ee:	e34fc0ef          	jal	ffffffffc0202a22 <free_pages>
ffffffffc02063f2:	8522                	mv	a0,s0
ffffffffc02063f4:	9effb0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc02063f8:	70a2                	ld	ra,40(sp)
ffffffffc02063fa:	7402                	ld	s0,32(sp)
ffffffffc02063fc:	64e2                	ld	s1,24(sp)
ffffffffc02063fe:	6942                	ld	s2,16(sp)
ffffffffc0206400:	69a2                	ld	s3,8(sp)
ffffffffc0206402:	4501                	li	a0,0
ffffffffc0206404:	6145                	addi	sp,sp,48
ffffffffc0206406:	8082                	ret
ffffffffc0206408:	00090997          	auipc	s3,0x90
ffffffffc020640c:	4c098993          	addi	s3,s3,1216 # ffffffffc02968c8 <current>
ffffffffc0206410:	0009b703          	ld	a4,0(s3)
ffffffffc0206414:	f487b683          	ld	a3,-184(a5)
ffffffffc0206418:	f0e695e3          	bne	a3,a4,ffffffffc0206322 <do_wait.part.0+0x26>
ffffffffc020641c:	f287a603          	lw	a2,-216(a5)
ffffffffc0206420:	468d                	li	a3,3
ffffffffc0206422:	06d60063          	beq	a2,a3,ffffffffc0206482 <do_wait.part.0+0x186>
ffffffffc0206426:	800007b7          	lui	a5,0x80000
ffffffffc020642a:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc020642c:	4685                	li	a3,1
ffffffffc020642e:	0ef72623          	sw	a5,236(a4)
ffffffffc0206432:	c314                	sw	a3,0(a4)
ffffffffc0206434:	09e010ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc0206438:	0009b783          	ld	a5,0(s3)
ffffffffc020643c:	0b07a783          	lw	a5,176(a5)
ffffffffc0206440:	8b85                	andi	a5,a5,1
ffffffffc0206442:	e7b9                	bnez	a5,ffffffffc0206490 <do_wait.part.0+0x194>
ffffffffc0206444:	ee0487e3          	beqz	s1,ffffffffc0206332 <do_wait.part.0+0x36>
ffffffffc0206448:	45a9                	li	a1,10
ffffffffc020644a:	8526                	mv	a0,s1
ffffffffc020644c:	474050ef          	jal	ffffffffc020b8c0 <hash32>
ffffffffc0206450:	02051793          	slli	a5,a0,0x20
ffffffffc0206454:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0206458:	0008b797          	auipc	a5,0x8b
ffffffffc020645c:	36878793          	addi	a5,a5,872 # ffffffffc02917c0 <hash_list>
ffffffffc0206460:	953e                	add	a0,a0,a5
ffffffffc0206462:	87aa                	mv	a5,a0
ffffffffc0206464:	a029                	j	ffffffffc020646e <do_wait.part.0+0x172>
ffffffffc0206466:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020646a:	f8970fe3          	beq	a4,s1,ffffffffc0206408 <do_wait.part.0+0x10c>
ffffffffc020646e:	679c                	ld	a5,8(a5)
ffffffffc0206470:	fef51be3          	bne	a0,a5,ffffffffc0206466 <do_wait.part.0+0x16a>
ffffffffc0206474:	b57d                	j	ffffffffc0206322 <do_wait.part.0+0x26>
ffffffffc0206476:	887fa0ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020647a:	bf2d                	j	ffffffffc02063b4 <do_wait.part.0+0xb8>
ffffffffc020647c:	7018                	ld	a4,32(s0)
ffffffffc020647e:	fb7c                	sd	a5,240(a4)
ffffffffc0206480:	b705                	j	ffffffffc02063a0 <do_wait.part.0+0xa4>
ffffffffc0206482:	f2878413          	addi	s0,a5,-216
ffffffffc0206486:	b5d1                	j	ffffffffc020634a <do_wait.part.0+0x4e>
ffffffffc0206488:	87bfa0ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc020648c:	4605                	li	a2,1
ffffffffc020648e:	b5f5                	j	ffffffffc020637a <do_wait.part.0+0x7e>
ffffffffc0206490:	555d                	li	a0,-9
ffffffffc0206492:	d0bff0ef          	jal	ffffffffc020619c <do_exit>
ffffffffc0206496:	00007617          	auipc	a2,0x7
ffffffffc020649a:	31260613          	addi	a2,a2,786 # ffffffffc020d7a8 <etext+0x1ed2>
ffffffffc020649e:	45700593          	li	a1,1111
ffffffffc02064a2:	00007517          	auipc	a0,0x7
ffffffffc02064a6:	29650513          	addi	a0,a0,662 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02064aa:	d83f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02064ae:	00006617          	auipc	a2,0x6
ffffffffc02064b2:	28260613          	addi	a2,a2,642 # ffffffffc020c730 <etext+0xe5a>
ffffffffc02064b6:	06900593          	li	a1,105
ffffffffc02064ba:	00006517          	auipc	a0,0x6
ffffffffc02064be:	1ce50513          	addi	a0,a0,462 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02064c2:	d6bf90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02064c6:	00006617          	auipc	a2,0x6
ffffffffc02064ca:	24260613          	addi	a2,a2,578 # ffffffffc020c708 <etext+0xe32>
ffffffffc02064ce:	07700593          	li	a1,119
ffffffffc02064d2:	00006517          	auipc	a0,0x6
ffffffffc02064d6:	1b650513          	addi	a0,a0,438 # ffffffffc020c688 <etext+0xdb2>
ffffffffc02064da:	d53f90ef          	jal	ffffffffc020022c <__panic>

ffffffffc02064de <init_main>:
ffffffffc02064de:	1141                	addi	sp,sp,-16
ffffffffc02064e0:	00007517          	auipc	a0,0x7
ffffffffc02064e4:	2e850513          	addi	a0,a0,744 # ffffffffc020d7c8 <etext+0x1ef2>
ffffffffc02064e8:	e406                	sd	ra,8(sp)
ffffffffc02064ea:	216020ef          	jal	ffffffffc0208700 <vfs_set_bootfs>
ffffffffc02064ee:	e179                	bnez	a0,ffffffffc02065b4 <init_main+0xd6>
ffffffffc02064f0:	d6afc0ef          	jal	ffffffffc0202a5a <nr_free_pages>
ffffffffc02064f4:	845fb0ef          	jal	ffffffffc0201d38 <kallocated>
ffffffffc02064f8:	4601                	li	a2,0
ffffffffc02064fa:	4581                	li	a1,0
ffffffffc02064fc:	00001517          	auipc	a0,0x1
ffffffffc0206500:	a9250513          	addi	a0,a0,-1390 # ffffffffc0206f8e <user_main>
ffffffffc0206504:	c49ff0ef          	jal	ffffffffc020614c <kernel_thread>
ffffffffc0206508:	00a04563          	bgtz	a0,ffffffffc0206512 <init_main+0x34>
ffffffffc020650c:	a841                	j	ffffffffc020659c <init_main+0xbe>
ffffffffc020650e:	7c5000ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc0206512:	4581                	li	a1,0
ffffffffc0206514:	4501                	li	a0,0
ffffffffc0206516:	de7ff0ef          	jal	ffffffffc02062fc <do_wait.part.0>
ffffffffc020651a:	d975                	beqz	a0,ffffffffc020650e <init_main+0x30>
ffffffffc020651c:	ba2ff0ef          	jal	ffffffffc02058be <fs_cleanup>
ffffffffc0206520:	00007517          	auipc	a0,0x7
ffffffffc0206524:	2f050513          	addi	a0,a0,752 # ffffffffc020d810 <etext+0x1f3a>
ffffffffc0206528:	c01f90ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020652c:	00090797          	auipc	a5,0x90
ffffffffc0206530:	3a47b783          	ld	a5,932(a5) # ffffffffc02968d0 <initproc>
ffffffffc0206534:	7bf8                	ld	a4,240(a5)
ffffffffc0206536:	e339                	bnez	a4,ffffffffc020657c <init_main+0x9e>
ffffffffc0206538:	7ff8                	ld	a4,248(a5)
ffffffffc020653a:	e329                	bnez	a4,ffffffffc020657c <init_main+0x9e>
ffffffffc020653c:	1007b703          	ld	a4,256(a5)
ffffffffc0206540:	ef15                	bnez	a4,ffffffffc020657c <init_main+0x9e>
ffffffffc0206542:	00090697          	auipc	a3,0x90
ffffffffc0206546:	37e6a683          	lw	a3,894(a3) # ffffffffc02968c0 <nr_process>
ffffffffc020654a:	4709                	li	a4,2
ffffffffc020654c:	0ce69163          	bne	a3,a4,ffffffffc020660e <init_main+0x130>
ffffffffc0206550:	0008f717          	auipc	a4,0x8f
ffffffffc0206554:	27070713          	addi	a4,a4,624 # ffffffffc02957c0 <proc_list>
ffffffffc0206558:	6714                	ld	a3,8(a4)
ffffffffc020655a:	0c878793          	addi	a5,a5,200
ffffffffc020655e:	08d79863          	bne	a5,a3,ffffffffc02065ee <init_main+0x110>
ffffffffc0206562:	6318                	ld	a4,0(a4)
ffffffffc0206564:	06e79563          	bne	a5,a4,ffffffffc02065ce <init_main+0xf0>
ffffffffc0206568:	00007517          	auipc	a0,0x7
ffffffffc020656c:	39050513          	addi	a0,a0,912 # ffffffffc020d8f8 <etext+0x2022>
ffffffffc0206570:	bb9f90ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0206574:	60a2                	ld	ra,8(sp)
ffffffffc0206576:	4501                	li	a0,0
ffffffffc0206578:	0141                	addi	sp,sp,16
ffffffffc020657a:	8082                	ret
ffffffffc020657c:	00007697          	auipc	a3,0x7
ffffffffc0206580:	2bc68693          	addi	a3,a3,700 # ffffffffc020d838 <etext+0x1f62>
ffffffffc0206584:	00006617          	auipc	a2,0x6
ffffffffc0206588:	80c60613          	addi	a2,a2,-2036 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020658c:	4cd00593          	li	a1,1229
ffffffffc0206590:	00007517          	auipc	a0,0x7
ffffffffc0206594:	1a850513          	addi	a0,a0,424 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206598:	c95f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc020659c:	00007617          	auipc	a2,0x7
ffffffffc02065a0:	25460613          	addi	a2,a2,596 # ffffffffc020d7f0 <etext+0x1f1a>
ffffffffc02065a4:	4c000593          	li	a1,1216
ffffffffc02065a8:	00007517          	auipc	a0,0x7
ffffffffc02065ac:	19050513          	addi	a0,a0,400 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02065b0:	c7df90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02065b4:	86aa                	mv	a3,a0
ffffffffc02065b6:	00007617          	auipc	a2,0x7
ffffffffc02065ba:	21a60613          	addi	a2,a2,538 # ffffffffc020d7d0 <etext+0x1efa>
ffffffffc02065be:	4b800593          	li	a1,1208
ffffffffc02065c2:	00007517          	auipc	a0,0x7
ffffffffc02065c6:	17650513          	addi	a0,a0,374 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02065ca:	c63f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02065ce:	00007697          	auipc	a3,0x7
ffffffffc02065d2:	2fa68693          	addi	a3,a3,762 # ffffffffc020d8c8 <etext+0x1ff2>
ffffffffc02065d6:	00005617          	auipc	a2,0x5
ffffffffc02065da:	7ba60613          	addi	a2,a2,1978 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02065de:	4d000593          	li	a1,1232
ffffffffc02065e2:	00007517          	auipc	a0,0x7
ffffffffc02065e6:	15650513          	addi	a0,a0,342 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02065ea:	c43f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02065ee:	00007697          	auipc	a3,0x7
ffffffffc02065f2:	2aa68693          	addi	a3,a3,682 # ffffffffc020d898 <etext+0x1fc2>
ffffffffc02065f6:	00005617          	auipc	a2,0x5
ffffffffc02065fa:	79a60613          	addi	a2,a2,1946 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02065fe:	4cf00593          	li	a1,1231
ffffffffc0206602:	00007517          	auipc	a0,0x7
ffffffffc0206606:	13650513          	addi	a0,a0,310 # ffffffffc020d738 <etext+0x1e62>
ffffffffc020660a:	c23f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc020660e:	00007697          	auipc	a3,0x7
ffffffffc0206612:	27a68693          	addi	a3,a3,634 # ffffffffc020d888 <etext+0x1fb2>
ffffffffc0206616:	00005617          	auipc	a2,0x5
ffffffffc020661a:	77a60613          	addi	a2,a2,1914 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020661e:	4ce00593          	li	a1,1230
ffffffffc0206622:	00007517          	auipc	a0,0x7
ffffffffc0206626:	11650513          	addi	a0,a0,278 # ffffffffc020d738 <etext+0x1e62>
ffffffffc020662a:	c03f90ef          	jal	ffffffffc020022c <__panic>

ffffffffc020662e <do_execve>:
ffffffffc020662e:	cc010113          	addi	sp,sp,-832
ffffffffc0206632:	31413823          	sd	s4,784(sp)
ffffffffc0206636:	32113c23          	sd	ra,824(sp)
ffffffffc020663a:	32913423          	sd	s1,808(sp)
ffffffffc020663e:	fff58a1b          	addiw	s4,a1,-1
ffffffffc0206642:	47fd                	li	a5,31
ffffffffc0206644:	6947e863          	bltu	a5,s4,ffffffffc0206cd4 <do_execve+0x6a6>
ffffffffc0206648:	33213023          	sd	s2,800(sp)
ffffffffc020664c:	00090917          	auipc	s2,0x90
ffffffffc0206650:	27c90913          	addi	s2,s2,636 # ffffffffc02968c8 <current>
ffffffffc0206654:	00093783          	ld	a5,0(s2)
ffffffffc0206658:	31613023          	sd	s6,768(sp)
ffffffffc020665c:	2f813823          	sd	s8,752(sp)
ffffffffc0206660:	0287bb03          	ld	s6,40(a5)
ffffffffc0206664:	2db13c23          	sd	s11,728(sp)
ffffffffc0206668:	8c32                	mv	s8,a2
ffffffffc020666a:	84aa                	mv	s1,a0
ffffffffc020666c:	8dae                	mv	s11,a1
ffffffffc020666e:	0088                	addi	a0,sp,64
ffffffffc0206670:	4641                	li	a2,16
ffffffffc0206672:	4581                	li	a1,0
ffffffffc0206674:	573040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0206678:	000b0c63          	beqz	s6,ffffffffc0206690 <do_execve+0x62>
ffffffffc020667c:	038b0513          	addi	a0,s6,56
ffffffffc0206680:	958fe0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0206684:	00093783          	ld	a5,0(s2)
ffffffffc0206688:	c781                	beqz	a5,ffffffffc0206690 <do_execve+0x62>
ffffffffc020668a:	43dc                	lw	a5,4(a5)
ffffffffc020668c:	04fb2823          	sw	a5,80(s6)
ffffffffc0206690:	1c048363          	beqz	s1,ffffffffc0206856 <do_execve+0x228>
ffffffffc0206694:	8626                	mv	a2,s1
ffffffffc0206696:	46c1                	li	a3,16
ffffffffc0206698:	008c                	addi	a1,sp,64
ffffffffc020669a:	855a                	mv	a0,s6
ffffffffc020669c:	b90fb0ef          	jal	ffffffffc0201a2c <copy_string>
ffffffffc02066a0:	60050a63          	beqz	a0,ffffffffc0206cb4 <do_execve+0x686>
ffffffffc02066a4:	31513423          	sd	s5,776(sp)
ffffffffc02066a8:	003d9793          	slli	a5,s11,0x3
ffffffffc02066ac:	863e                	mv	a2,a5
ffffffffc02066ae:	4681                	li	a3,0
ffffffffc02066b0:	85e2                	mv	a1,s8
ffffffffc02066b2:	855a                	mv	a0,s6
ffffffffc02066b4:	e83e                	sd	a5,16(sp)
ffffffffc02066b6:	8ae2                	mv	s5,s8
ffffffffc02066b8:	a62fb0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc02066bc:	76050063          	beqz	a0,ffffffffc0206e1c <do_execve+0x7ee>
ffffffffc02066c0:	31313c23          	sd	s3,792(sp)
ffffffffc02066c4:	2f713c23          	sd	s7,760(sp)
ffffffffc02066c8:	4981                	li	s3,0
ffffffffc02066ca:	0c810b93          	addi	s7,sp,200
ffffffffc02066ce:	6505                	lui	a0,0x1
ffffffffc02066d0:	e6cfb0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc02066d4:	84aa                	mv	s1,a0
ffffffffc02066d6:	10050063          	beqz	a0,ffffffffc02067d6 <do_execve+0x1a8>
ffffffffc02066da:	000ab603          	ld	a2,0(s5)
ffffffffc02066de:	85aa                	mv	a1,a0
ffffffffc02066e0:	6685                	lui	a3,0x1
ffffffffc02066e2:	855a                	mv	a0,s6
ffffffffc02066e4:	b48fb0ef          	jal	ffffffffc0201a2c <copy_string>
ffffffffc02066e8:	16050263          	beqz	a0,ffffffffc020684c <do_execve+0x21e>
ffffffffc02066ec:	009bb023          	sd	s1,0(s7)
ffffffffc02066f0:	2985                	addiw	s3,s3,1
ffffffffc02066f2:	0ba1                	addi	s7,s7,8
ffffffffc02066f4:	0aa1                	addi	s5,s5,8
ffffffffc02066f6:	fd3d9ce3          	bne	s11,s3,ffffffffc02066ce <do_execve+0xa0>
ffffffffc02066fa:	32813823          	sd	s0,816(sp)
ffffffffc02066fe:	2f913423          	sd	s9,744(sp)
ffffffffc0206702:	2fa13023          	sd	s10,736(sp)
ffffffffc0206706:	000c3483          	ld	s1,0(s8)
ffffffffc020670a:	080b0963          	beqz	s6,ffffffffc020679c <do_execve+0x16e>
ffffffffc020670e:	038b0513          	addi	a0,s6,56
ffffffffc0206712:	8c2fe0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0206716:	00093783          	ld	a5,0(s2)
ffffffffc020671a:	040b2823          	sw	zero,80(s6)
ffffffffc020671e:	1487b503          	ld	a0,328(a5)
ffffffffc0206722:	a78ff0ef          	jal	ffffffffc020599a <files_closeall>
ffffffffc0206726:	8526                	mv	a0,s1
ffffffffc0206728:	4581                	li	a1,0
ffffffffc020672a:	978fe0ef          	jal	ffffffffc02048a2 <sysfile_open>
ffffffffc020672e:	89aa                	mv	s3,a0
ffffffffc0206730:	7c054663          	bltz	a0,ffffffffc0206efc <do_execve+0x8ce>
ffffffffc0206734:	00090797          	auipc	a5,0x90
ffffffffc0206738:	1647b783          	ld	a5,356(a5) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc020673c:	577d                	li	a4,-1
ffffffffc020673e:	177e                	slli	a4,a4,0x3f
ffffffffc0206740:	83b1                	srli	a5,a5,0xc
ffffffffc0206742:	8fd9                	or	a5,a5,a4
ffffffffc0206744:	18079073          	csrw	satp,a5
ffffffffc0206748:	030b2783          	lw	a5,48(s6)
ffffffffc020674c:	37fd                	addiw	a5,a5,-1
ffffffffc020674e:	02fb2823          	sw	a5,48(s6)
ffffffffc0206752:	1a078a63          	beqz	a5,ffffffffc0206906 <do_execve+0x2d8>
ffffffffc0206756:	00093783          	ld	a5,0(s2)
ffffffffc020675a:	0207b423          	sd	zero,40(a5)
ffffffffc020675e:	b1dfa0ef          	jal	ffffffffc020127a <mm_create>
ffffffffc0206762:	8aaa                	mv	s5,a0
ffffffffc0206764:	18050463          	beqz	a0,ffffffffc02068ec <do_execve+0x2be>
ffffffffc0206768:	cecff0ef          	jal	ffffffffc0205c54 <setup_pgdir>
ffffffffc020676c:	10051363          	bnez	a0,ffffffffc0206872 <do_execve+0x244>
ffffffffc0206770:	4601                	li	a2,0
ffffffffc0206772:	4581                	li	a1,0
ffffffffc0206774:	854e                	mv	a0,s3
ffffffffc0206776:	be4fe0ef          	jal	ffffffffc0204b5a <sysfile_seek>
ffffffffc020677a:	e42a                	sd	a0,8(sp)
ffffffffc020677c:	14050763          	beqz	a0,ffffffffc02068ca <do_execve+0x29c>
ffffffffc0206780:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206784:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206788:	0c010c13          	addi	s8,sp,192
ffffffffc020678c:	1938                	addi	a4,sp,184
ffffffffc020678e:	018ab503          	ld	a0,24(s5)
ffffffffc0206792:	ec3a                	sd	a4,24(sp)
ffffffffc0206794:	c48ff0ef          	jal	ffffffffc0205bdc <put_pgdir.isra.0>
ffffffffc0206798:	6762                	ld	a4,24(sp)
ffffffffc020679a:	a0ed                	j	ffffffffc0206884 <do_execve+0x256>
ffffffffc020679c:	00093783          	ld	a5,0(s2)
ffffffffc02067a0:	1487b503          	ld	a0,328(a5)
ffffffffc02067a4:	9f6ff0ef          	jal	ffffffffc020599a <files_closeall>
ffffffffc02067a8:	8526                	mv	a0,s1
ffffffffc02067aa:	4581                	li	a1,0
ffffffffc02067ac:	8f6fe0ef          	jal	ffffffffc02048a2 <sysfile_open>
ffffffffc02067b0:	89aa                	mv	s3,a0
ffffffffc02067b2:	10054363          	bltz	a0,ffffffffc02068b8 <do_execve+0x28a>
ffffffffc02067b6:	00093783          	ld	a5,0(s2)
ffffffffc02067ba:	779c                	ld	a5,40(a5)
ffffffffc02067bc:	d3cd                	beqz	a5,ffffffffc020675e <do_execve+0x130>
ffffffffc02067be:	00007617          	auipc	a2,0x7
ffffffffc02067c2:	16a60613          	addi	a2,a2,362 # ffffffffc020d928 <etext+0x2052>
ffffffffc02067c6:	2d200593          	li	a1,722
ffffffffc02067ca:	00007517          	auipc	a0,0x7
ffffffffc02067ce:	f6e50513          	addi	a0,a0,-146 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02067d2:	a5bf90ef          	jal	ffffffffc020022c <__panic>
ffffffffc02067d6:	54f1                	li	s1,-4
ffffffffc02067d8:	48098e63          	beqz	s3,ffffffffc0206c74 <do_execve+0x646>
ffffffffc02067dc:	00399793          	slli	a5,s3,0x3
ffffffffc02067e0:	39fd                	addiw	s3,s3,-1
ffffffffc02067e2:	0b810913          	addi	s2,sp,184
ffffffffc02067e6:	02099713          	slli	a4,s3,0x20
ffffffffc02067ea:	32813823          	sd	s0,816(sp)
ffffffffc02067ee:	01d75993          	srli	s3,a4,0x1d
ffffffffc02067f2:	993e                	add	s2,s2,a5
ffffffffc02067f4:	0180                	addi	s0,sp,192
ffffffffc02067f6:	41390933          	sub	s2,s2,s3
ffffffffc02067fa:	943e                	add	s0,s0,a5
ffffffffc02067fc:	6008                	ld	a0,0(s0)
ffffffffc02067fe:	1461                	addi	s0,s0,-8
ffffffffc0206800:	de2fb0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0206804:	ff241ce3          	bne	s0,s2,ffffffffc02067fc <do_execve+0x1ce>
ffffffffc0206808:	33013403          	ld	s0,816(sp)
ffffffffc020680c:	31813983          	ld	s3,792(sp)
ffffffffc0206810:	2f813b83          	ld	s7,760(sp)
ffffffffc0206814:	000b0863          	beqz	s6,ffffffffc0206824 <do_execve+0x1f6>
ffffffffc0206818:	038b0513          	addi	a0,s6,56
ffffffffc020681c:	fb9fd0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0206820:	040b2823          	sw	zero,80(s6)
ffffffffc0206824:	32013903          	ld	s2,800(sp)
ffffffffc0206828:	30813a83          	ld	s5,776(sp)
ffffffffc020682c:	30013b03          	ld	s6,768(sp)
ffffffffc0206830:	2f013c03          	ld	s8,752(sp)
ffffffffc0206834:	2d813d83          	ld	s11,728(sp)
ffffffffc0206838:	33813083          	ld	ra,824(sp)
ffffffffc020683c:	31013a03          	ld	s4,784(sp)
ffffffffc0206840:	8526                	mv	a0,s1
ffffffffc0206842:	32813483          	ld	s1,808(sp)
ffffffffc0206846:	34010113          	addi	sp,sp,832
ffffffffc020684a:	8082                	ret
ffffffffc020684c:	8526                	mv	a0,s1
ffffffffc020684e:	d94fb0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0206852:	54f5                	li	s1,-3
ffffffffc0206854:	b751                	j	ffffffffc02067d8 <do_execve+0x1aa>
ffffffffc0206856:	00093783          	ld	a5,0(s2)
ffffffffc020685a:	00007617          	auipc	a2,0x7
ffffffffc020685e:	0be60613          	addi	a2,a2,190 # ffffffffc020d918 <etext+0x2042>
ffffffffc0206862:	45c1                	li	a1,16
ffffffffc0206864:	43d4                	lw	a3,4(a5)
ffffffffc0206866:	0088                	addi	a0,sp,64
ffffffffc0206868:	31513423          	sd	s5,776(sp)
ffffffffc020686c:	006050ef          	jal	ffffffffc020b872 <snprintf>
ffffffffc0206870:	bd25                	j	ffffffffc02066a8 <do_execve+0x7a>
ffffffffc0206872:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206876:	57f1                	li	a5,-4
ffffffffc0206878:	020bdb93          	srli	s7,s7,0x20
ffffffffc020687c:	e43e                	sd	a5,8(sp)
ffffffffc020687e:	0c010c13          	addi	s8,sp,192
ffffffffc0206882:	1938                	addi	a4,sp,184
ffffffffc0206884:	8556                	mv	a0,s5
ffffffffc0206886:	ec3a                	sd	a4,24(sp)
ffffffffc0206888:	b3ffa0ef          	jal	ffffffffc02013c6 <mm_destroy>
ffffffffc020688c:	854e                	mv	a0,s3
ffffffffc020688e:	84afe0ef          	jal	ffffffffc02048d8 <sysfile_close>
ffffffffc0206892:	6762                	ld	a4,24(sp)
ffffffffc0206894:	67c2                	ld	a5,16(sp)
ffffffffc0206896:	003b9813          	slli	a6,s7,0x3
ffffffffc020689a:	973e                	add	a4,a4,a5
ffffffffc020689c:	410704b3          	sub	s1,a4,a6
ffffffffc02068a0:	00fc0d33          	add	s10,s8,a5
ffffffffc02068a4:	000d3503          	ld	a0,0(s10)
ffffffffc02068a8:	1d61                	addi	s10,s10,-8
ffffffffc02068aa:	d38fb0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc02068ae:	ffa49be3          	bne	s1,s10,ffffffffc02068a4 <do_execve+0x276>
ffffffffc02068b2:	6522                	ld	a0,8(sp)
ffffffffc02068b4:	8e9ff0ef          	jal	ffffffffc020619c <do_exit>
ffffffffc02068b8:	020a1b93          	slli	s7,s4,0x20
ffffffffc02068bc:	020bdb93          	srli	s7,s7,0x20
ffffffffc02068c0:	e42a                	sd	a0,8(sp)
ffffffffc02068c2:	0c010c13          	addi	s8,sp,192
ffffffffc02068c6:	1938                	addi	a4,sp,184
ffffffffc02068c8:	b7f1                	j	ffffffffc0206894 <do_execve+0x266>
ffffffffc02068ca:	04000613          	li	a2,64
ffffffffc02068ce:	012c                	addi	a1,sp,136
ffffffffc02068d0:	854e                	mv	a0,s3
ffffffffc02068d2:	80afe0ef          	jal	ffffffffc02048dc <sysfile_read>
ffffffffc02068d6:	04000793          	li	a5,64
ffffffffc02068da:	04f50163          	beq	a0,a5,ffffffffc020691c <do_execve+0x2ee>
ffffffffc02068de:	0005079b          	sext.w	a5,a0
ffffffffc02068e2:	00054363          	bltz	a0,ffffffffc02068e8 <do_execve+0x2ba>
ffffffffc02068e6:	57fd                	li	a5,-1
ffffffffc02068e8:	e43e                	sd	a5,8(sp)
ffffffffc02068ea:	bd59                	j	ffffffffc0206780 <do_execve+0x152>
ffffffffc02068ec:	854e                	mv	a0,s3
ffffffffc02068ee:	febfd0ef          	jal	ffffffffc02048d8 <sysfile_close>
ffffffffc02068f2:	020a1b93          	slli	s7,s4,0x20
ffffffffc02068f6:	57f1                	li	a5,-4
ffffffffc02068f8:	020bdb93          	srli	s7,s7,0x20
ffffffffc02068fc:	0c010c13          	addi	s8,sp,192
ffffffffc0206900:	1938                	addi	a4,sp,184
ffffffffc0206902:	e43e                	sd	a5,8(sp)
ffffffffc0206904:	bf41                	j	ffffffffc0206894 <do_execve+0x266>
ffffffffc0206906:	855a                	mv	a0,s6
ffffffffc0206908:	c75fa0ef          	jal	ffffffffc020157c <exit_mmap>
ffffffffc020690c:	018b3503          	ld	a0,24(s6)
ffffffffc0206910:	accff0ef          	jal	ffffffffc0205bdc <put_pgdir.isra.0>
ffffffffc0206914:	855a                	mv	a0,s6
ffffffffc0206916:	ab1fa0ef          	jal	ffffffffc02013c6 <mm_destroy>
ffffffffc020691a:	bd35                	j	ffffffffc0206756 <do_execve+0x128>
ffffffffc020691c:	472a                	lw	a4,136(sp)
ffffffffc020691e:	464c47b7          	lui	a5,0x464c4
ffffffffc0206922:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_bin_sfs_img_size+0x4644f27f>
ffffffffc0206926:	32f71d63          	bne	a4,a5,ffffffffc0206c60 <do_execve+0x632>
ffffffffc020692a:	0c015783          	lhu	a5,192(sp)
ffffffffc020692e:	4b01                	li	s6,0
ffffffffc0206930:	c7ad                	beqz	a5,ffffffffc020699a <do_execve+0x36c>
ffffffffc0206932:	fc6e                	sd	s11,56(sp)
ffffffffc0206934:	75aa                	ld	a1,168(sp)
ffffffffc0206936:	4601                	li	a2,0
ffffffffc0206938:	854e                	mv	a0,s3
ffffffffc020693a:	95da                	add	a1,a1,s6
ffffffffc020693c:	a1efe0ef          	jal	ffffffffc0204b5a <sysfile_seek>
ffffffffc0206940:	22051d63          	bnez	a0,ffffffffc0206b7a <do_execve+0x54c>
ffffffffc0206944:	03800613          	li	a2,56
ffffffffc0206948:	088c                	addi	a1,sp,80
ffffffffc020694a:	854e                	mv	a0,s3
ffffffffc020694c:	f91fd0ef          	jal	ffffffffc02048dc <sysfile_read>
ffffffffc0206950:	03800793          	li	a5,56
ffffffffc0206954:	02f50563          	beq	a0,a5,ffffffffc020697e <do_execve+0x350>
ffffffffc0206958:	0005049b          	sext.w	s1,a0
ffffffffc020695c:	00054363          	bltz	a0,ffffffffc0206962 <do_execve+0x334>
ffffffffc0206960:	54fd                	li	s1,-1
ffffffffc0206962:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206966:	020bdb93          	srli	s7,s7,0x20
ffffffffc020696a:	0c010c13          	addi	s8,sp,192
ffffffffc020696e:	1938                	addi	a4,sp,184
ffffffffc0206970:	8556                	mv	a0,s5
ffffffffc0206972:	ec3a                	sd	a4,24(sp)
ffffffffc0206974:	c09fa0ef          	jal	ffffffffc020157c <exit_mmap>
ffffffffc0206978:	6762                	ld	a4,24(sp)
ffffffffc020697a:	e426                	sd	s1,8(sp)
ffffffffc020697c:	bd09                	j	ffffffffc020678e <do_execve+0x160>
ffffffffc020697e:	47c6                	lw	a5,80(sp)
ffffffffc0206980:	4705                	li	a4,1
ffffffffc0206982:	20e78563          	beq	a5,a4,ffffffffc0206b8c <do_execve+0x55e>
ffffffffc0206986:	6722                	ld	a4,8(sp)
ffffffffc0206988:	0c015783          	lhu	a5,192(sp)
ffffffffc020698c:	038b0b13          	addi	s6,s6,56
ffffffffc0206990:	2705                	addiw	a4,a4,1
ffffffffc0206992:	e43a                	sd	a4,8(sp)
ffffffffc0206994:	faf740e3          	blt	a4,a5,ffffffffc0206934 <do_execve+0x306>
ffffffffc0206998:	7de2                	ld	s11,56(sp)
ffffffffc020699a:	4701                	li	a4,0
ffffffffc020699c:	46ad                	li	a3,11
ffffffffc020699e:	00100637          	lui	a2,0x100
ffffffffc02069a2:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02069a6:	8556                	mv	a0,s5
ffffffffc02069a8:	a71fa0ef          	jal	ffffffffc0201418 <mm_map>
ffffffffc02069ac:	84aa                	mv	s1,a0
ffffffffc02069ae:	f955                	bnez	a0,ffffffffc0206962 <do_execve+0x334>
ffffffffc02069b0:	018ab503          	ld	a0,24(s5)
ffffffffc02069b4:	467d                	li	a2,31
ffffffffc02069b6:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02069ba:	a3ffd0ef          	jal	ffffffffc02043f8 <pgdir_alloc_page>
ffffffffc02069be:	5a050863          	beqz	a0,ffffffffc0206f6e <do_execve+0x940>
ffffffffc02069c2:	018ab503          	ld	a0,24(s5)
ffffffffc02069c6:	467d                	li	a2,31
ffffffffc02069c8:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02069cc:	a2dfd0ef          	jal	ffffffffc02043f8 <pgdir_alloc_page>
ffffffffc02069d0:	56050f63          	beqz	a0,ffffffffc0206f4e <do_execve+0x920>
ffffffffc02069d4:	018ab503          	ld	a0,24(s5)
ffffffffc02069d8:	467d                	li	a2,31
ffffffffc02069da:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02069de:	a1bfd0ef          	jal	ffffffffc02043f8 <pgdir_alloc_page>
ffffffffc02069e2:	54050663          	beqz	a0,ffffffffc0206f2e <do_execve+0x900>
ffffffffc02069e6:	018ab503          	ld	a0,24(s5)
ffffffffc02069ea:	467d                	li	a2,31
ffffffffc02069ec:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02069f0:	a09fd0ef          	jal	ffffffffc02043f8 <pgdir_alloc_page>
ffffffffc02069f4:	50050d63          	beqz	a0,ffffffffc0206f0e <do_execve+0x8e0>
ffffffffc02069f8:	030aa783          	lw	a5,48(s5)
ffffffffc02069fc:	00093703          	ld	a4,0(s2)
ffffffffc0206a00:	018ab683          	ld	a3,24(s5)
ffffffffc0206a04:	2785                	addiw	a5,a5,1
ffffffffc0206a06:	02faa823          	sw	a5,48(s5)
ffffffffc0206a0a:	03573423          	sd	s5,40(a4)
ffffffffc0206a0e:	c02007b7          	lui	a5,0xc0200
ffffffffc0206a12:	46f6ef63          	bltu	a3,a5,ffffffffc0206e90 <do_execve+0x862>
ffffffffc0206a16:	00090617          	auipc	a2,0x90
ffffffffc0206a1a:	e9263603          	ld	a2,-366(a2) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206a1e:	57fd                	li	a5,-1
ffffffffc0206a20:	17fe                	slli	a5,a5,0x3f
ffffffffc0206a22:	8e91                	sub	a3,a3,a2
ffffffffc0206a24:	f754                	sd	a3,168(a4)
ffffffffc0206a26:	82b1                	srli	a3,a3,0xc
ffffffffc0206a28:	8fd5                	or	a5,a5,a3
ffffffffc0206a2a:	18079073          	csrw	satp,a5
ffffffffc0206a2e:	67c2                	ld	a5,16(sp)
ffffffffc0206a30:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206a34:	1938                	addi	a4,sp,184
ffffffffc0206a36:	0c010c13          	addi	s8,sp,192
ffffffffc0206a3a:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206a3e:	00fc0a33          	add	s4,s8,a5
ffffffffc0206a42:	00f70b33          	add	s6,a4,a5
ffffffffc0206a46:	4585                	li	a1,1
ffffffffc0206a48:	7ff007b7          	lui	a5,0x7ff00
ffffffffc0206a4c:	003b9693          	slli	a3,s7,0x3
ffffffffc0206a50:	03b0                	addi	a2,sp,456
ffffffffc0206a52:	97ae                	add	a5,a5,a1
ffffffffc0206a54:	e44e                	sd	s3,8(sp)
ffffffffc0206a56:	f426                	sd	s1,40(sp)
ffffffffc0206a58:	8cde                	mv	s9,s7
ffffffffc0206a5a:	00d60433          	add	s0,a2,a3
ffffffffc0206a5e:	40db0b33          	sub	s6,s6,a3
ffffffffc0206a62:	ec3e                	sd	a5,24(sp)
ffffffffc0206a64:	7ff00d37          	lui	s10,0x7ff00
ffffffffc0206a68:	f052                	sd	s4,32(sp)
ffffffffc0206a6a:	89d2                	mv	s3,s4
ffffffffc0206a6c:	01f59493          	slli	s1,a1,0x1f
ffffffffc0206a70:	8bba                	mv	s7,a4
ffffffffc0206a72:	0009ba03          	ld	s4,0(s3)
ffffffffc0206a76:	8552                	mv	a0,s4
ffffffffc0206a78:	0bb040ef          	jal	ffffffffc020b332 <strlen>
ffffffffc0206a7c:	67e2                	ld	a5,24(sp)
ffffffffc0206a7e:	97aa                	add	a5,a5,a0
ffffffffc0206a80:	3cf4e963          	bltu	s1,a5,ffffffffc0206e52 <do_execve+0x824>
ffffffffc0206a84:	00150693          	addi	a3,a0,1
ffffffffc0206a88:	8c95                	sub	s1,s1,a3
ffffffffc0206a8a:	8652                	mv	a2,s4
ffffffffc0206a8c:	85a6                	mv	a1,s1
ffffffffc0206a8e:	8556                	mv	a0,s5
ffffffffc0206a90:	f65fa0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc0206a94:	3e050963          	beqz	a0,ffffffffc0206e86 <do_execve+0x858>
ffffffffc0206a98:	e004                	sd	s1,0(s0)
ffffffffc0206a9a:	19e1                	addi	s3,s3,-8
ffffffffc0206a9c:	1461                	addi	s0,s0,-8
ffffffffc0206a9e:	fd699ae3          	bne	s3,s6,ffffffffc0206a72 <do_execve+0x444>
ffffffffc0206aa2:	67c2                	ld	a5,16(sp)
ffffffffc0206aa4:	03b0                	addi	a2,sp,456
ffffffffc0206aa6:	ff84f593          	andi	a1,s1,-8
ffffffffc0206aaa:	00878693          	addi	a3,a5,8 # 7ff00008 <_binary_bin_sfs_img_size+0x7fe8ad08>
ffffffffc0206aae:	963e                	add	a2,a2,a5
ffffffffc0206ab0:	40d58433          	sub	s0,a1,a3
ffffffffc0206ab4:	00063023          	sd	zero,0(a2)
ffffffffc0206ab8:	875e                	mv	a4,s7
ffffffffc0206aba:	7a02                	ld	s4,32(sp)
ffffffffc0206abc:	69a2                	ld	s3,8(sp)
ffffffffc0206abe:	74a2                	ld	s1,40(sp)
ffffffffc0206ac0:	8be6                	mv	s7,s9
ffffffffc0206ac2:	39a46b63          	bltu	s0,s10,ffffffffc0206e58 <do_execve+0x82a>
ffffffffc0206ac6:	03b0                	addi	a2,sp,456
ffffffffc0206ac8:	85a2                	mv	a1,s0
ffffffffc0206aca:	8556                	mv	a0,s5
ffffffffc0206acc:	e43a                	sd	a4,8(sp)
ffffffffc0206ace:	f27fa0ef          	jal	ffffffffc02019f4 <copy_to_user>
ffffffffc0206ad2:	6722                	ld	a4,8(sp)
ffffffffc0206ad4:	3a050c63          	beqz	a0,ffffffffc0206e8c <do_execve+0x85e>
ffffffffc0206ad8:	00093783          	ld	a5,0(s2)
ffffffffc0206adc:	12000613          	li	a2,288
ffffffffc0206ae0:	4581                	li	a1,0
ffffffffc0206ae2:	0a07ba83          	ld	s5,160(a5)
ffffffffc0206ae6:	100abc03          	ld	s8,256(s5)
ffffffffc0206aea:	8556                	mv	a0,s5
ffffffffc0206aec:	0fb040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0206af0:	770a                	ld	a4,160(sp)
ffffffffc0206af2:	eddc7793          	andi	a5,s8,-291
ffffffffc0206af6:	0207e793          	ori	a5,a5,32
ffffffffc0206afa:	10fab023          	sd	a5,256(s5)
ffffffffc0206afe:	008ab823          	sd	s0,16(s5)
ffffffffc0206b02:	05bab823          	sd	s11,80(s5)
ffffffffc0206b06:	048abc23          	sd	s0,88(s5)
ffffffffc0206b0a:	854e                	mv	a0,s3
ffffffffc0206b0c:	10eab423          	sd	a4,264(s5)
ffffffffc0206b10:	dc9fd0ef          	jal	ffffffffc02048d8 <sysfile_close>
ffffffffc0206b14:	000a3503          	ld	a0,0(s4)
ffffffffc0206b18:	1a61                	addi	s4,s4,-8
ffffffffc0206b1a:	ac8fb0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0206b1e:	ff6a1be3          	bne	s4,s6,ffffffffc0206b14 <do_execve+0x4e6>
ffffffffc0206b22:	00093403          	ld	s0,0(s2)
ffffffffc0206b26:	4641                	li	a2,16
ffffffffc0206b28:	4581                	li	a1,0
ffffffffc0206b2a:	0b440413          	addi	s0,s0,180
ffffffffc0206b2e:	8522                	mv	a0,s0
ffffffffc0206b30:	0b7040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0206b34:	008c                	addi	a1,sp,64
ffffffffc0206b36:	8522                	mv	a0,s0
ffffffffc0206b38:	463d                	li	a2,15
ffffffffc0206b3a:	0fd040ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0206b3e:	33813083          	ld	ra,824(sp)
ffffffffc0206b42:	33013403          	ld	s0,816(sp)
ffffffffc0206b46:	32013903          	ld	s2,800(sp)
ffffffffc0206b4a:	31813983          	ld	s3,792(sp)
ffffffffc0206b4e:	30813a83          	ld	s5,776(sp)
ffffffffc0206b52:	30013b03          	ld	s6,768(sp)
ffffffffc0206b56:	2f813b83          	ld	s7,760(sp)
ffffffffc0206b5a:	2f013c03          	ld	s8,752(sp)
ffffffffc0206b5e:	2e813c83          	ld	s9,744(sp)
ffffffffc0206b62:	2e013d03          	ld	s10,736(sp)
ffffffffc0206b66:	2d813d83          	ld	s11,728(sp)
ffffffffc0206b6a:	31013a03          	ld	s4,784(sp)
ffffffffc0206b6e:	8526                	mv	a0,s1
ffffffffc0206b70:	32813483          	ld	s1,808(sp)
ffffffffc0206b74:	34010113          	addi	sp,sp,832
ffffffffc0206b78:	8082                	ret
ffffffffc0206b7a:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206b7e:	84aa                	mv	s1,a0
ffffffffc0206b80:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206b84:	0c010c13          	addi	s8,sp,192
ffffffffc0206b88:	1938                	addi	a4,sp,184
ffffffffc0206b8a:	b3dd                	j	ffffffffc0206970 <do_execve+0x342>
ffffffffc0206b8c:	7666                	ld	a2,120(sp)
ffffffffc0206b8e:	77c6                	ld	a5,112(sp)
ffffffffc0206b90:	2af66863          	bltu	a2,a5,ffffffffc0206e40 <do_execve+0x812>
ffffffffc0206b94:	47d6                	lw	a5,84(sp)
ffffffffc0206b96:	0027971b          	slliw	a4,a5,0x2
ffffffffc0206b9a:	0027f693          	andi	a3,a5,2
ffffffffc0206b9e:	8b11                	andi	a4,a4,4
ffffffffc0206ba0:	8b91                	andi	a5,a5,4
ffffffffc0206ba2:	c2e5                	beqz	a3,ffffffffc0206c82 <do_execve+0x654>
ffffffffc0206ba4:	24079f63          	bnez	a5,ffffffffc0206e02 <do_execve+0x7d4>
ffffffffc0206ba8:	47dd                	li	a5,23
ffffffffc0206baa:	00276693          	ori	a3,a4,2
ffffffffc0206bae:	ec3e                	sd	a5,24(sp)
ffffffffc0206bb0:	c709                	beqz	a4,ffffffffc0206bba <do_execve+0x58c>
ffffffffc0206bb2:	67e2                	ld	a5,24(sp)
ffffffffc0206bb4:	0087e793          	ori	a5,a5,8
ffffffffc0206bb8:	ec3e                	sd	a5,24(sp)
ffffffffc0206bba:	7586                	ld	a1,96(sp)
ffffffffc0206bbc:	4701                	li	a4,0
ffffffffc0206bbe:	8556                	mv	a0,s5
ffffffffc0206bc0:	859fa0ef          	jal	ffffffffc0201418 <mm_map>
ffffffffc0206bc4:	f95d                	bnez	a0,ffffffffc0206b7a <do_execve+0x54c>
ffffffffc0206bc6:	7486                	ld	s1,96(sp)
ffffffffc0206bc8:	7846                	ld	a6,112(sp)
ffffffffc0206bca:	77fd                	lui	a5,0xfffff
ffffffffc0206bcc:	00f4fcb3          	and	s9,s1,a5
ffffffffc0206bd0:	01048d33          	add	s10,s1,a6
ffffffffc0206bd4:	27a4f263          	bgeu	s1,s10,ffffffffc0206e38 <do_execve+0x80a>
ffffffffc0206bd8:	5bfd                	li	s7,-1
ffffffffc0206bda:	00cbd793          	srli	a5,s7,0xc
ffffffffc0206bde:	f03e                	sd	a5,32(sp)
ffffffffc0206be0:	00090d97          	auipc	s11,0x90
ffffffffc0206be4:	cd8d8d93          	addi	s11,s11,-808 # ffffffffc02968b8 <pages>
ffffffffc0206be8:	f85a                	sd	s6,48(sp)
ffffffffc0206bea:	f452                	sd	s4,40(sp)
ffffffffc0206bec:	018ab503          	ld	a0,24(s5)
ffffffffc0206bf0:	6662                	ld	a2,24(sp)
ffffffffc0206bf2:	85e6                	mv	a1,s9
ffffffffc0206bf4:	805fd0ef          	jal	ffffffffc02043f8 <pgdir_alloc_page>
ffffffffc0206bf8:	8b2a                	mv	s6,a0
ffffffffc0206bfa:	cd79                	beqz	a0,ffffffffc0206cd8 <do_execve+0x6aa>
ffffffffc0206bfc:	6785                	lui	a5,0x1
ffffffffc0206bfe:	00fc8433          	add	s0,s9,a5
ffffffffc0206c02:	409d0a33          	sub	s4,s10,s1
ffffffffc0206c06:	008d6463          	bltu	s10,s0,ffffffffc0206c0e <do_execve+0x5e0>
ffffffffc0206c0a:	40940a33          	sub	s4,s0,s1
ffffffffc0206c0e:	000db783          	ld	a5,0(s11)
ffffffffc0206c12:	00009597          	auipc	a1,0x9
ffffffffc0206c16:	f9e5b583          	ld	a1,-98(a1) # ffffffffc020fbb0 <nbase>
ffffffffc0206c1a:	7702                	ld	a4,32(sp)
ffffffffc0206c1c:	40fb07b3          	sub	a5,s6,a5
ffffffffc0206c20:	8799                	srai	a5,a5,0x6
ffffffffc0206c22:	00090617          	auipc	a2,0x90
ffffffffc0206c26:	c8e63603          	ld	a2,-882(a2) # ffffffffc02968b0 <npage>
ffffffffc0206c2a:	97ae                	add	a5,a5,a1
ffffffffc0206c2c:	00e7f5b3          	and	a1,a5,a4
ffffffffc0206c30:	00c79b93          	slli	s7,a5,0xc
ffffffffc0206c34:	26c5fa63          	bgeu	a1,a2,ffffffffc0206ea8 <do_execve+0x87a>
ffffffffc0206c38:	65e6                	ld	a1,88(sp)
ffffffffc0206c3a:	7786                	ld	a5,96(sp)
ffffffffc0206c3c:	4601                	li	a2,0
ffffffffc0206c3e:	854e                	mv	a0,s3
ffffffffc0206c40:	8d9d                	sub	a1,a1,a5
ffffffffc0206c42:	95a6                	add	a1,a1,s1
ffffffffc0206c44:	00090c17          	auipc	s8,0x90
ffffffffc0206c48:	c64c3c03          	ld	s8,-924(s8) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206c4c:	f0ffd0ef          	jal	ffffffffc0204b5a <sysfile_seek>
ffffffffc0206c50:	c121                	beqz	a0,ffffffffc0206c90 <do_execve+0x662>
ffffffffc0206c52:	02816b83          	lwu	s7,40(sp)
ffffffffc0206c56:	84aa                	mv	s1,a0
ffffffffc0206c58:	0c010c13          	addi	s8,sp,192
ffffffffc0206c5c:	1938                	addi	a4,sp,184
ffffffffc0206c5e:	bb09                	j	ffffffffc0206970 <do_execve+0x342>
ffffffffc0206c60:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206c64:	57e1                	li	a5,-8
ffffffffc0206c66:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206c6a:	e43e                	sd	a5,8(sp)
ffffffffc0206c6c:	0c010c13          	addi	s8,sp,192
ffffffffc0206c70:	1938                	addi	a4,sp,184
ffffffffc0206c72:	be31                	j	ffffffffc020678e <do_execve+0x160>
ffffffffc0206c74:	31813983          	ld	s3,792(sp)
ffffffffc0206c78:	2f813b83          	ld	s7,760(sp)
ffffffffc0206c7c:	b80b1ee3          	bnez	s6,ffffffffc0206818 <do_execve+0x1ea>
ffffffffc0206c80:	b655                	j	ffffffffc0206824 <do_execve+0x1f6>
ffffffffc0206c82:	18078563          	beqz	a5,ffffffffc0206e0c <do_execve+0x7de>
ffffffffc0206c86:	47cd                	li	a5,19
ffffffffc0206c88:	00176693          	ori	a3,a4,1
ffffffffc0206c8c:	ec3e                	sd	a5,24(sp)
ffffffffc0206c8e:	b70d                	j	ffffffffc0206bb0 <do_execve+0x582>
ffffffffc0206c90:	018b85b3          	add	a1,s7,s8
ffffffffc0206c94:	41948cb3          	sub	s9,s1,s9
ffffffffc0206c98:	95e6                	add	a1,a1,s9
ffffffffc0206c9a:	8652                	mv	a2,s4
ffffffffc0206c9c:	854e                	mv	a0,s3
ffffffffc0206c9e:	c3ffd0ef          	jal	ffffffffc02048dc <sysfile_read>
ffffffffc0206ca2:	00aa0463          	beq	s4,a0,ffffffffc0206caa <do_execve+0x67c>
ffffffffc0206ca6:	7a22                	ld	s4,40(sp)
ffffffffc0206ca8:	b945                	j	ffffffffc0206958 <do_execve+0x32a>
ffffffffc0206caa:	94d2                	add	s1,s1,s4
ffffffffc0206cac:	05a4f063          	bgeu	s1,s10,ffffffffc0206cec <do_execve+0x6be>
ffffffffc0206cb0:	8ca2                	mv	s9,s0
ffffffffc0206cb2:	bf2d                	j	ffffffffc0206bec <do_execve+0x5be>
ffffffffc0206cb4:	160b0863          	beqz	s6,ffffffffc0206e24 <do_execve+0x7f6>
ffffffffc0206cb8:	038b0513          	addi	a0,s6,56
ffffffffc0206cbc:	b19fd0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0206cc0:	040b2823          	sw	zero,80(s6)
ffffffffc0206cc4:	32013903          	ld	s2,800(sp)
ffffffffc0206cc8:	30013b03          	ld	s6,768(sp)
ffffffffc0206ccc:	2f013c03          	ld	s8,752(sp)
ffffffffc0206cd0:	2d813d83          	ld	s11,728(sp)
ffffffffc0206cd4:	54f5                	li	s1,-3
ffffffffc0206cd6:	b68d                	j	ffffffffc0206838 <do_execve+0x20a>
ffffffffc0206cd8:	7a22                	ld	s4,40(sp)
ffffffffc0206cda:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206cde:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206ce2:	54f1                	li	s1,-4
ffffffffc0206ce4:	0c010c13          	addi	s8,sp,192
ffffffffc0206ce8:	1938                	addi	a4,sp,184
ffffffffc0206cea:	b159                	j	ffffffffc0206970 <do_execve+0x342>
ffffffffc0206cec:	8bda                	mv	s7,s6
ffffffffc0206cee:	7a22                	ld	s4,40(sp)
ffffffffc0206cf0:	7b42                	ld	s6,48(sp)
ffffffffc0206cf2:	7d86                	ld	s11,96(sp)
ffffffffc0206cf4:	8c22                	mv	s8,s0
ffffffffc0206cf6:	7666                	ld	a2,120(sp)
ffffffffc0206cf8:	9db2                	add	s11,s11,a2
ffffffffc0206cfa:	0784f963          	bgeu	s1,s8,ffffffffc0206d6c <do_execve+0x73e>
ffffffffc0206cfe:	c9b484e3          	beq	s1,s11,ffffffffc0206986 <do_execve+0x358>
ffffffffc0206d02:	409d8433          	sub	s0,s11,s1
ffffffffc0206d06:	018de463          	bltu	s11,s8,ffffffffc0206d0e <do_execve+0x6e0>
ffffffffc0206d0a:	409c0433          	sub	s0,s8,s1
ffffffffc0206d0e:	00090517          	auipc	a0,0x90
ffffffffc0206d12:	baa53503          	ld	a0,-1110(a0) # ffffffffc02968b8 <pages>
ffffffffc0206d16:	00009617          	auipc	a2,0x9
ffffffffc0206d1a:	e9a63603          	ld	a2,-358(a2) # ffffffffc020fbb0 <nbase>
ffffffffc0206d1e:	00090597          	auipc	a1,0x90
ffffffffc0206d22:	b925b583          	ld	a1,-1134(a1) # ffffffffc02968b0 <npage>
ffffffffc0206d26:	40ab86b3          	sub	a3,s7,a0
ffffffffc0206d2a:	8699                	srai	a3,a3,0x6
ffffffffc0206d2c:	96b2                	add	a3,a3,a2
ffffffffc0206d2e:	00c69613          	slli	a2,a3,0xc
ffffffffc0206d32:	8231                	srli	a2,a2,0xc
ffffffffc0206d34:	06b2                	slli	a3,a3,0xc
ffffffffc0206d36:	18b67763          	bgeu	a2,a1,ffffffffc0206ec4 <do_execve+0x896>
ffffffffc0206d3a:	00090617          	auipc	a2,0x90
ffffffffc0206d3e:	b6e63603          	ld	a2,-1170(a2) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206d42:	6505                	lui	a0,0x1
ffffffffc0206d44:	9526                	add	a0,a0,s1
ffffffffc0206d46:	96b2                	add	a3,a3,a2
ffffffffc0206d48:	41850533          	sub	a0,a0,s8
ffffffffc0206d4c:	9536                	add	a0,a0,a3
ffffffffc0206d4e:	8622                	mv	a2,s0
ffffffffc0206d50:	4581                	li	a1,0
ffffffffc0206d52:	694040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0206d56:	94a2                	add	s1,s1,s0
ffffffffc0206d58:	018db6b3          	sltu	a3,s11,s8
ffffffffc0206d5c:	018df463          	bgeu	s11,s8,ffffffffc0206d64 <do_execve+0x736>
ffffffffc0206d60:	c29d83e3          	beq	s11,s1,ffffffffc0206986 <do_execve+0x358>
ffffffffc0206d64:	16069c63          	bnez	a3,ffffffffc0206edc <do_execve+0x8ae>
ffffffffc0206d68:	17849a63          	bne	s1,s8,ffffffffc0206edc <do_execve+0x8ae>
ffffffffc0206d6c:	c1b4fde3          	bgeu	s1,s11,ffffffffc0206986 <do_execve+0x358>
ffffffffc0206d70:	547d                	li	s0,-1
ffffffffc0206d72:	6785                	lui	a5,0x1
ffffffffc0206d74:	f45a                	sd	s6,40(sp)
ffffffffc0206d76:	00fd8d33          	add	s10,s11,a5
ffffffffc0206d7a:	8b26                	mv	s6,s1
ffffffffc0206d7c:	8031                	srli	s0,s0,0xc
ffffffffc0206d7e:	64e2                	ld	s1,24(sp)
ffffffffc0206d80:	00090c97          	auipc	s9,0x90
ffffffffc0206d84:	b38c8c93          	addi	s9,s9,-1224 # ffffffffc02968b8 <pages>
ffffffffc0206d88:	00090b97          	auipc	s7,0x90
ffffffffc0206d8c:	b28b8b93          	addi	s7,s7,-1240 # ffffffffc02968b0 <npage>
ffffffffc0206d90:	f04e                	sd	s3,32(sp)
ffffffffc0206d92:	ec52                	sd	s4,24(sp)
ffffffffc0206d94:	a8a9                	j	ffffffffc0206dee <do_execve+0x7c0>
ffffffffc0206d96:	6785                	lui	a5,0x1
ffffffffc0206d98:	00fc0a33          	add	s4,s8,a5
ffffffffc0206d9c:	416a09b3          	sub	s3,s4,s6
ffffffffc0206da0:	018df663          	bgeu	s11,s8,ffffffffc0206dac <do_execve+0x77e>
ffffffffc0206da4:	013d0633          	add	a2,s10,s3
ffffffffc0206da8:	414609b3          	sub	s3,a2,s4
ffffffffc0206dac:	000cb783          	ld	a5,0(s9)
ffffffffc0206db0:	00009817          	auipc	a6,0x9
ffffffffc0206db4:	e0083803          	ld	a6,-512(a6) # ffffffffc020fbb0 <nbase>
ffffffffc0206db8:	000bb583          	ld	a1,0(s7)
ffffffffc0206dbc:	40f507b3          	sub	a5,a0,a5
ffffffffc0206dc0:	8799                	srai	a5,a5,0x6
ffffffffc0206dc2:	97c2                	add	a5,a5,a6
ffffffffc0206dc4:	0087f533          	and	a0,a5,s0
ffffffffc0206dc8:	07b2                	slli	a5,a5,0xc
ffffffffc0206dca:	0eb57c63          	bgeu	a0,a1,ffffffffc0206ec2 <do_execve+0x894>
ffffffffc0206dce:	00090597          	auipc	a1,0x90
ffffffffc0206dd2:	ada5b583          	ld	a1,-1318(a1) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206dd6:	418b0533          	sub	a0,s6,s8
ffffffffc0206dda:	864e                	mv	a2,s3
ffffffffc0206ddc:	97ae                	add	a5,a5,a1
ffffffffc0206dde:	953e                	add	a0,a0,a5
ffffffffc0206de0:	4581                	li	a1,0
ffffffffc0206de2:	9b4e                	add	s6,s6,s3
ffffffffc0206de4:	602040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0206de8:	03bb7663          	bgeu	s6,s11,ffffffffc0206e14 <do_execve+0x7e6>
ffffffffc0206dec:	8c52                	mv	s8,s4
ffffffffc0206dee:	018ab503          	ld	a0,24(s5)
ffffffffc0206df2:	8626                	mv	a2,s1
ffffffffc0206df4:	85e2                	mv	a1,s8
ffffffffc0206df6:	e02fd0ef          	jal	ffffffffc02043f8 <pgdir_alloc_page>
ffffffffc0206dfa:	fd51                	bnez	a0,ffffffffc0206d96 <do_execve+0x768>
ffffffffc0206dfc:	7982                	ld	s3,32(sp)
ffffffffc0206dfe:	6a62                	ld	s4,24(sp)
ffffffffc0206e00:	bde9                	j	ffffffffc0206cda <do_execve+0x6ac>
ffffffffc0206e02:	47dd                	li	a5,23
ffffffffc0206e04:	00376693          	ori	a3,a4,3
ffffffffc0206e08:	ec3e                	sd	a5,24(sp)
ffffffffc0206e0a:	b35d                	j	ffffffffc0206bb0 <do_execve+0x582>
ffffffffc0206e0c:	47c5                	li	a5,17
ffffffffc0206e0e:	86ba                	mv	a3,a4
ffffffffc0206e10:	ec3e                	sd	a5,24(sp)
ffffffffc0206e12:	bb79                	j	ffffffffc0206bb0 <do_execve+0x582>
ffffffffc0206e14:	7982                	ld	s3,32(sp)
ffffffffc0206e16:	7b22                	ld	s6,40(sp)
ffffffffc0206e18:	6a62                	ld	s4,24(sp)
ffffffffc0206e1a:	b6b5                	j	ffffffffc0206986 <do_execve+0x358>
ffffffffc0206e1c:	54f5                	li	s1,-3
ffffffffc0206e1e:	9e0b1de3          	bnez	s6,ffffffffc0206818 <do_execve+0x1ea>
ffffffffc0206e22:	b409                	j	ffffffffc0206824 <do_execve+0x1f6>
ffffffffc0206e24:	32013903          	ld	s2,800(sp)
ffffffffc0206e28:	30013b03          	ld	s6,768(sp)
ffffffffc0206e2c:	2f013c03          	ld	s8,752(sp)
ffffffffc0206e30:	2d813d83          	ld	s11,728(sp)
ffffffffc0206e34:	54f5                	li	s1,-3
ffffffffc0206e36:	b409                	j	ffffffffc0206838 <do_execve+0x20a>
ffffffffc0206e38:	8c66                	mv	s8,s9
ffffffffc0206e3a:	8da6                	mv	s11,s1
ffffffffc0206e3c:	4b81                	li	s7,0
ffffffffc0206e3e:	bd65                	j	ffffffffc0206cf6 <do_execve+0x6c8>
ffffffffc0206e40:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206e44:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206e48:	54e1                	li	s1,-8
ffffffffc0206e4a:	0c010c13          	addi	s8,sp,192
ffffffffc0206e4e:	1938                	addi	a4,sp,184
ffffffffc0206e50:	b605                	j	ffffffffc0206970 <do_execve+0x342>
ffffffffc0206e52:	69a2                	ld	s3,8(sp)
ffffffffc0206e54:	875e                	mv	a4,s7
ffffffffc0206e56:	8be6                	mv	s7,s9
ffffffffc0206e58:	54f1                	li	s1,-4
ffffffffc0206e5a:	00090597          	auipc	a1,0x90
ffffffffc0206e5e:	a3e5b583          	ld	a1,-1474(a1) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc0206e62:	567d                	li	a2,-1
ffffffffc0206e64:	167e                	slli	a2,a2,0x3f
ffffffffc0206e66:	00c5d693          	srli	a3,a1,0xc
ffffffffc0206e6a:	8ed1                	or	a3,a3,a2
ffffffffc0206e6c:	18069073          	csrw	satp,a3
ffffffffc0206e70:	030aa683          	lw	a3,48(s5)
ffffffffc0206e74:	00093603          	ld	a2,0(s2)
ffffffffc0206e78:	36fd                	addiw	a3,a3,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0206e7a:	02063423          	sd	zero,40(a2)
ffffffffc0206e7e:	f64c                	sd	a1,168(a2)
ffffffffc0206e80:	02daa823          	sw	a3,48(s5)
ffffffffc0206e84:	b4f5                	j	ffffffffc0206970 <do_execve+0x342>
ffffffffc0206e86:	69a2                	ld	s3,8(sp)
ffffffffc0206e88:	875e                	mv	a4,s7
ffffffffc0206e8a:	8be6                	mv	s7,s9
ffffffffc0206e8c:	54f5                	li	s1,-3
ffffffffc0206e8e:	b7f1                	j	ffffffffc0206e5a <do_execve+0x82c>
ffffffffc0206e90:	00006617          	auipc	a2,0x6
ffffffffc0206e94:	87860613          	addi	a2,a2,-1928 # ffffffffc020c708 <etext+0xe32>
ffffffffc0206e98:	35e00593          	li	a1,862
ffffffffc0206e9c:	00007517          	auipc	a0,0x7
ffffffffc0206ea0:	89c50513          	addi	a0,a0,-1892 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206ea4:	b88f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206ea8:	86de                	mv	a3,s7
ffffffffc0206eaa:	00005617          	auipc	a2,0x5
ffffffffc0206eae:	7b660613          	addi	a2,a2,1974 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0206eb2:	07100593          	li	a1,113
ffffffffc0206eb6:	00005517          	auipc	a0,0x5
ffffffffc0206eba:	7d250513          	addi	a0,a0,2002 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0206ebe:	b6ef90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206ec2:	86be                	mv	a3,a5
ffffffffc0206ec4:	00005617          	auipc	a2,0x5
ffffffffc0206ec8:	79c60613          	addi	a2,a2,1948 # ffffffffc020c660 <etext+0xd8a>
ffffffffc0206ecc:	07100593          	li	a1,113
ffffffffc0206ed0:	00005517          	auipc	a0,0x5
ffffffffc0206ed4:	7b850513          	addi	a0,a0,1976 # ffffffffc020c688 <etext+0xdb2>
ffffffffc0206ed8:	b54f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206edc:	00007697          	auipc	a3,0x7
ffffffffc0206ee0:	a7468693          	addi	a3,a3,-1420 # ffffffffc020d950 <etext+0x207a>
ffffffffc0206ee4:	00005617          	auipc	a2,0x5
ffffffffc0206ee8:	eac60613          	addi	a2,a2,-340 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0206eec:	33d00593          	li	a1,829
ffffffffc0206ef0:	00007517          	auipc	a0,0x7
ffffffffc0206ef4:	84850513          	addi	a0,a0,-1976 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206ef8:	b34f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206efc:	020a1b93          	slli	s7,s4,0x20
ffffffffc0206f00:	e42a                	sd	a0,8(sp)
ffffffffc0206f02:	020bdb93          	srli	s7,s7,0x20
ffffffffc0206f06:	0c010c13          	addi	s8,sp,192
ffffffffc0206f0a:	1938                	addi	a4,sp,184
ffffffffc0206f0c:	b261                	j	ffffffffc0206894 <do_execve+0x266>
ffffffffc0206f0e:	00007697          	auipc	a3,0x7
ffffffffc0206f12:	b5a68693          	addi	a3,a3,-1190 # ffffffffc020da68 <etext+0x2192>
ffffffffc0206f16:	00005617          	auipc	a2,0x5
ffffffffc0206f1a:	e7a60613          	addi	a2,a2,-390 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0206f1e:	35a00593          	li	a1,858
ffffffffc0206f22:	00007517          	auipc	a0,0x7
ffffffffc0206f26:	81650513          	addi	a0,a0,-2026 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206f2a:	b02f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206f2e:	00007697          	auipc	a3,0x7
ffffffffc0206f32:	af268693          	addi	a3,a3,-1294 # ffffffffc020da20 <etext+0x214a>
ffffffffc0206f36:	00005617          	auipc	a2,0x5
ffffffffc0206f3a:	e5a60613          	addi	a2,a2,-422 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0206f3e:	35900593          	li	a1,857
ffffffffc0206f42:	00006517          	auipc	a0,0x6
ffffffffc0206f46:	7f650513          	addi	a0,a0,2038 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206f4a:	ae2f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206f4e:	00007697          	auipc	a3,0x7
ffffffffc0206f52:	a8a68693          	addi	a3,a3,-1398 # ffffffffc020d9d8 <etext+0x2102>
ffffffffc0206f56:	00005617          	auipc	a2,0x5
ffffffffc0206f5a:	e3a60613          	addi	a2,a2,-454 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0206f5e:	35800593          	li	a1,856
ffffffffc0206f62:	00006517          	auipc	a0,0x6
ffffffffc0206f66:	7d650513          	addi	a0,a0,2006 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206f6a:	ac2f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc0206f6e:	00007697          	auipc	a3,0x7
ffffffffc0206f72:	a2268693          	addi	a3,a3,-1502 # ffffffffc020d990 <etext+0x20ba>
ffffffffc0206f76:	00005617          	auipc	a2,0x5
ffffffffc0206f7a:	e1a60613          	addi	a2,a2,-486 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0206f7e:	35700593          	li	a1,855
ffffffffc0206f82:	00006517          	auipc	a0,0x6
ffffffffc0206f86:	7b650513          	addi	a0,a0,1974 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0206f8a:	aa2f90ef          	jal	ffffffffc020022c <__panic>

ffffffffc0206f8e <user_main>:
ffffffffc0206f8e:	7179                	addi	sp,sp,-48
ffffffffc0206f90:	e84a                	sd	s2,16(sp)
ffffffffc0206f92:	00090917          	auipc	s2,0x90
ffffffffc0206f96:	93690913          	addi	s2,s2,-1738 # ffffffffc02968c8 <current>
ffffffffc0206f9a:	00093783          	ld	a5,0(s2)
ffffffffc0206f9e:	00007617          	auipc	a2,0x7
ffffffffc0206fa2:	b1260613          	addi	a2,a2,-1262 # ffffffffc020dab0 <etext+0x21da>
ffffffffc0206fa6:	00007517          	auipc	a0,0x7
ffffffffc0206faa:	b1250513          	addi	a0,a0,-1262 # ffffffffc020dab8 <etext+0x21e2>
ffffffffc0206fae:	43cc                	lw	a1,4(a5)
ffffffffc0206fb0:	f406                	sd	ra,40(sp)
ffffffffc0206fb2:	f022                	sd	s0,32(sp)
ffffffffc0206fb4:	ec26                	sd	s1,24(sp)
ffffffffc0206fb6:	e402                	sd	zero,8(sp)
ffffffffc0206fb8:	e032                	sd	a2,0(sp)
ffffffffc0206fba:	96ef90ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0206fbe:	6782                	ld	a5,0(sp)
ffffffffc0206fc0:	cfb9                	beqz	a5,ffffffffc020701e <user_main+0x90>
ffffffffc0206fc2:	003c                	addi	a5,sp,8
ffffffffc0206fc4:	4401                	li	s0,0
ffffffffc0206fc6:	6398                	ld	a4,0(a5)
ffffffffc0206fc8:	07a1                	addi	a5,a5,8 # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc0206fca:	0405                	addi	s0,s0,1
ffffffffc0206fcc:	ff6d                	bnez	a4,ffffffffc0206fc6 <user_main+0x38>
ffffffffc0206fce:	00093703          	ld	a4,0(s2)
ffffffffc0206fd2:	6789                	lui	a5,0x2
ffffffffc0206fd4:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0206fd8:	6b04                	ld	s1,16(a4)
ffffffffc0206fda:	734c                	ld	a1,160(a4)
ffffffffc0206fdc:	12000613          	li	a2,288
ffffffffc0206fe0:	94be                	add	s1,s1,a5
ffffffffc0206fe2:	8526                	mv	a0,s1
ffffffffc0206fe4:	452040ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0206fe8:	00093783          	ld	a5,0(s2)
ffffffffc0206fec:	0004059b          	sext.w	a1,s0
ffffffffc0206ff0:	860a                	mv	a2,sp
ffffffffc0206ff2:	f3c4                	sd	s1,160(a5)
ffffffffc0206ff4:	00007517          	auipc	a0,0x7
ffffffffc0206ff8:	abc50513          	addi	a0,a0,-1348 # ffffffffc020dab0 <etext+0x21da>
ffffffffc0206ffc:	e32ff0ef          	jal	ffffffffc020662e <do_execve>
ffffffffc0207000:	8126                	mv	sp,s1
ffffffffc0207002:	9f6fa06f          	j	ffffffffc02011f8 <__trapret>
ffffffffc0207006:	00007617          	auipc	a2,0x7
ffffffffc020700a:	ada60613          	addi	a2,a2,-1318 # ffffffffc020dae0 <etext+0x220a>
ffffffffc020700e:	4ae00593          	li	a1,1198
ffffffffc0207012:	00006517          	auipc	a0,0x6
ffffffffc0207016:	72650513          	addi	a0,a0,1830 # ffffffffc020d738 <etext+0x1e62>
ffffffffc020701a:	a12f90ef          	jal	ffffffffc020022c <__panic>
ffffffffc020701e:	4401                	li	s0,0
ffffffffc0207020:	b77d                	j	ffffffffc0206fce <user_main+0x40>

ffffffffc0207022 <do_yield>:
ffffffffc0207022:	00090797          	auipc	a5,0x90
ffffffffc0207026:	8a67b783          	ld	a5,-1882(a5) # ffffffffc02968c8 <current>
ffffffffc020702a:	4705                	li	a4,1
ffffffffc020702c:	4501                	li	a0,0
ffffffffc020702e:	ef98                	sd	a4,24(a5)
ffffffffc0207030:	8082                	ret

ffffffffc0207032 <do_wait>:
ffffffffc0207032:	c59d                	beqz	a1,ffffffffc0207060 <do_wait+0x2e>
ffffffffc0207034:	1101                	addi	sp,sp,-32
ffffffffc0207036:	e02a                	sd	a0,0(sp)
ffffffffc0207038:	00090517          	auipc	a0,0x90
ffffffffc020703c:	89053503          	ld	a0,-1904(a0) # ffffffffc02968c8 <current>
ffffffffc0207040:	4685                	li	a3,1
ffffffffc0207042:	4611                	li	a2,4
ffffffffc0207044:	7508                	ld	a0,40(a0)
ffffffffc0207046:	ec06                	sd	ra,24(sp)
ffffffffc0207048:	e42e                	sd	a1,8(sp)
ffffffffc020704a:	8d1fa0ef          	jal	ffffffffc020191a <user_mem_check>
ffffffffc020704e:	6702                	ld	a4,0(sp)
ffffffffc0207050:	67a2                	ld	a5,8(sp)
ffffffffc0207052:	c909                	beqz	a0,ffffffffc0207064 <do_wait+0x32>
ffffffffc0207054:	60e2                	ld	ra,24(sp)
ffffffffc0207056:	85be                	mv	a1,a5
ffffffffc0207058:	853a                	mv	a0,a4
ffffffffc020705a:	6105                	addi	sp,sp,32
ffffffffc020705c:	aa0ff06f          	j	ffffffffc02062fc <do_wait.part.0>
ffffffffc0207060:	a9cff06f          	j	ffffffffc02062fc <do_wait.part.0>
ffffffffc0207064:	60e2                	ld	ra,24(sp)
ffffffffc0207066:	5575                	li	a0,-3
ffffffffc0207068:	6105                	addi	sp,sp,32
ffffffffc020706a:	8082                	ret

ffffffffc020706c <do_kill>:
ffffffffc020706c:	6789                	lui	a5,0x2
ffffffffc020706e:	fff5071b          	addiw	a4,a0,-1
ffffffffc0207072:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_bin_swap_img_size-0x5d02>
ffffffffc0207074:	06e7e463          	bltu	a5,a4,ffffffffc02070dc <do_kill+0x70>
ffffffffc0207078:	1101                	addi	sp,sp,-32
ffffffffc020707a:	45a9                	li	a1,10
ffffffffc020707c:	ec06                	sd	ra,24(sp)
ffffffffc020707e:	e42a                	sd	a0,8(sp)
ffffffffc0207080:	041040ef          	jal	ffffffffc020b8c0 <hash32>
ffffffffc0207084:	02051793          	slli	a5,a0,0x20
ffffffffc0207088:	01c7d693          	srli	a3,a5,0x1c
ffffffffc020708c:	0008a797          	auipc	a5,0x8a
ffffffffc0207090:	73478793          	addi	a5,a5,1844 # ffffffffc02917c0 <hash_list>
ffffffffc0207094:	96be                	add	a3,a3,a5
ffffffffc0207096:	6622                	ld	a2,8(sp)
ffffffffc0207098:	8536                	mv	a0,a3
ffffffffc020709a:	a029                	j	ffffffffc02070a4 <do_kill+0x38>
ffffffffc020709c:	f2c52703          	lw	a4,-212(a0)
ffffffffc02070a0:	00c70963          	beq	a4,a2,ffffffffc02070b2 <do_kill+0x46>
ffffffffc02070a4:	6508                	ld	a0,8(a0)
ffffffffc02070a6:	fea69be3          	bne	a3,a0,ffffffffc020709c <do_kill+0x30>
ffffffffc02070aa:	60e2                	ld	ra,24(sp)
ffffffffc02070ac:	5575                	li	a0,-3
ffffffffc02070ae:	6105                	addi	sp,sp,32
ffffffffc02070b0:	8082                	ret
ffffffffc02070b2:	fd852703          	lw	a4,-40(a0)
ffffffffc02070b6:	00177693          	andi	a3,a4,1
ffffffffc02070ba:	e29d                	bnez	a3,ffffffffc02070e0 <do_kill+0x74>
ffffffffc02070bc:	4954                	lw	a3,20(a0)
ffffffffc02070be:	00176713          	ori	a4,a4,1
ffffffffc02070c2:	fce52c23          	sw	a4,-40(a0)
ffffffffc02070c6:	0006c663          	bltz	a3,ffffffffc02070d2 <do_kill+0x66>
ffffffffc02070ca:	4501                	li	a0,0
ffffffffc02070cc:	60e2                	ld	ra,24(sp)
ffffffffc02070ce:	6105                	addi	sp,sp,32
ffffffffc02070d0:	8082                	ret
ffffffffc02070d2:	f2850513          	addi	a0,a0,-216
ffffffffc02070d6:	304000ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc02070da:	bfc5                	j	ffffffffc02070ca <do_kill+0x5e>
ffffffffc02070dc:	5575                	li	a0,-3
ffffffffc02070de:	8082                	ret
ffffffffc02070e0:	555d                	li	a0,-9
ffffffffc02070e2:	b7ed                	j	ffffffffc02070cc <do_kill+0x60>

ffffffffc02070e4 <proc_init>:
ffffffffc02070e4:	1101                	addi	sp,sp,-32
ffffffffc02070e6:	e426                	sd	s1,8(sp)
ffffffffc02070e8:	0008e797          	auipc	a5,0x8e
ffffffffc02070ec:	6d878793          	addi	a5,a5,1752 # ffffffffc02957c0 <proc_list>
ffffffffc02070f0:	ec06                	sd	ra,24(sp)
ffffffffc02070f2:	e822                	sd	s0,16(sp)
ffffffffc02070f4:	e04a                	sd	s2,0(sp)
ffffffffc02070f6:	0008a497          	auipc	s1,0x8a
ffffffffc02070fa:	6ca48493          	addi	s1,s1,1738 # ffffffffc02917c0 <hash_list>
ffffffffc02070fe:	e79c                	sd	a5,8(a5)
ffffffffc0207100:	e39c                	sd	a5,0(a5)
ffffffffc0207102:	0008e717          	auipc	a4,0x8e
ffffffffc0207106:	6be70713          	addi	a4,a4,1726 # ffffffffc02957c0 <proc_list>
ffffffffc020710a:	87a6                	mv	a5,s1
ffffffffc020710c:	e79c                	sd	a5,8(a5)
ffffffffc020710e:	e39c                	sd	a5,0(a5)
ffffffffc0207110:	07c1                	addi	a5,a5,16
ffffffffc0207112:	fee79de3          	bne	a5,a4,ffffffffc020710c <proc_init+0x28>
ffffffffc0207116:	a1bfe0ef          	jal	ffffffffc0205b30 <alloc_proc>
ffffffffc020711a:	0008f917          	auipc	s2,0x8f
ffffffffc020711e:	7be90913          	addi	s2,s2,1982 # ffffffffc02968d8 <idleproc>
ffffffffc0207122:	00a93023          	sd	a0,0(s2)
ffffffffc0207126:	842a                	mv	s0,a0
ffffffffc0207128:	12050c63          	beqz	a0,ffffffffc0207260 <proc_init+0x17c>
ffffffffc020712c:	4689                	li	a3,2
ffffffffc020712e:	0000a717          	auipc	a4,0xa
ffffffffc0207132:	ed270713          	addi	a4,a4,-302 # ffffffffc0211000 <bootstack>
ffffffffc0207136:	4785                	li	a5,1
ffffffffc0207138:	e114                	sd	a3,0(a0)
ffffffffc020713a:	e918                	sd	a4,16(a0)
ffffffffc020713c:	ed1c                	sd	a5,24(a0)
ffffffffc020713e:	f90fe0ef          	jal	ffffffffc02058ce <files_create>
ffffffffc0207142:	14a43423          	sd	a0,328(s0)
ffffffffc0207146:	10050163          	beqz	a0,ffffffffc0207248 <proc_init+0x164>
ffffffffc020714a:	00093403          	ld	s0,0(s2)
ffffffffc020714e:	4641                	li	a2,16
ffffffffc0207150:	4581                	li	a1,0
ffffffffc0207152:	14843703          	ld	a4,328(s0)
ffffffffc0207156:	0b440413          	addi	s0,s0,180
ffffffffc020715a:	8522                	mv	a0,s0
ffffffffc020715c:	4b1c                	lw	a5,16(a4)
ffffffffc020715e:	2785                	addiw	a5,a5,1
ffffffffc0207160:	cb1c                	sw	a5,16(a4)
ffffffffc0207162:	284040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0207166:	8522                	mv	a0,s0
ffffffffc0207168:	463d                	li	a2,15
ffffffffc020716a:	00007597          	auipc	a1,0x7
ffffffffc020716e:	9d658593          	addi	a1,a1,-1578 # ffffffffc020db40 <etext+0x226a>
ffffffffc0207172:	2c4040ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0207176:	0008f797          	auipc	a5,0x8f
ffffffffc020717a:	74a7a783          	lw	a5,1866(a5) # ffffffffc02968c0 <nr_process>
ffffffffc020717e:	00093703          	ld	a4,0(s2)
ffffffffc0207182:	4601                	li	a2,0
ffffffffc0207184:	2785                	addiw	a5,a5,1
ffffffffc0207186:	4581                	li	a1,0
ffffffffc0207188:	fffff517          	auipc	a0,0xfffff
ffffffffc020718c:	35650513          	addi	a0,a0,854 # ffffffffc02064de <init_main>
ffffffffc0207190:	0008f697          	auipc	a3,0x8f
ffffffffc0207194:	72e6bc23          	sd	a4,1848(a3) # ffffffffc02968c8 <current>
ffffffffc0207198:	0008f717          	auipc	a4,0x8f
ffffffffc020719c:	72f72423          	sw	a5,1832(a4) # ffffffffc02968c0 <nr_process>
ffffffffc02071a0:	fadfe0ef          	jal	ffffffffc020614c <kernel_thread>
ffffffffc02071a4:	842a                	mv	s0,a0
ffffffffc02071a6:	08a05563          	blez	a0,ffffffffc0207230 <proc_init+0x14c>
ffffffffc02071aa:	6789                	lui	a5,0x2
ffffffffc02071ac:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_bin_swap_img_size-0x5d02>
ffffffffc02071ae:	fff5071b          	addiw	a4,a0,-1
ffffffffc02071b2:	02e7e463          	bltu	a5,a4,ffffffffc02071da <proc_init+0xf6>
ffffffffc02071b6:	45a9                	li	a1,10
ffffffffc02071b8:	708040ef          	jal	ffffffffc020b8c0 <hash32>
ffffffffc02071bc:	02051713          	slli	a4,a0,0x20
ffffffffc02071c0:	01c75793          	srli	a5,a4,0x1c
ffffffffc02071c4:	00f486b3          	add	a3,s1,a5
ffffffffc02071c8:	87b6                	mv	a5,a3
ffffffffc02071ca:	a029                	j	ffffffffc02071d4 <proc_init+0xf0>
ffffffffc02071cc:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02071d0:	04870d63          	beq	a4,s0,ffffffffc020722a <proc_init+0x146>
ffffffffc02071d4:	679c                	ld	a5,8(a5)
ffffffffc02071d6:	fef69be3          	bne	a3,a5,ffffffffc02071cc <proc_init+0xe8>
ffffffffc02071da:	4781                	li	a5,0
ffffffffc02071dc:	0b478413          	addi	s0,a5,180
ffffffffc02071e0:	4641                	li	a2,16
ffffffffc02071e2:	4581                	li	a1,0
ffffffffc02071e4:	8522                	mv	a0,s0
ffffffffc02071e6:	0008f717          	auipc	a4,0x8f
ffffffffc02071ea:	6ef73523          	sd	a5,1770(a4) # ffffffffc02968d0 <initproc>
ffffffffc02071ee:	1f8040ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc02071f2:	8522                	mv	a0,s0
ffffffffc02071f4:	463d                	li	a2,15
ffffffffc02071f6:	00007597          	auipc	a1,0x7
ffffffffc02071fa:	97258593          	addi	a1,a1,-1678 # ffffffffc020db68 <etext+0x2292>
ffffffffc02071fe:	238040ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc0207202:	00093783          	ld	a5,0(s2)
ffffffffc0207206:	cbc9                	beqz	a5,ffffffffc0207298 <proc_init+0x1b4>
ffffffffc0207208:	43dc                	lw	a5,4(a5)
ffffffffc020720a:	e7d9                	bnez	a5,ffffffffc0207298 <proc_init+0x1b4>
ffffffffc020720c:	0008f797          	auipc	a5,0x8f
ffffffffc0207210:	6c47b783          	ld	a5,1732(a5) # ffffffffc02968d0 <initproc>
ffffffffc0207214:	c3b5                	beqz	a5,ffffffffc0207278 <proc_init+0x194>
ffffffffc0207216:	43d8                	lw	a4,4(a5)
ffffffffc0207218:	4785                	li	a5,1
ffffffffc020721a:	04f71f63          	bne	a4,a5,ffffffffc0207278 <proc_init+0x194>
ffffffffc020721e:	60e2                	ld	ra,24(sp)
ffffffffc0207220:	6442                	ld	s0,16(sp)
ffffffffc0207222:	64a2                	ld	s1,8(sp)
ffffffffc0207224:	6902                	ld	s2,0(sp)
ffffffffc0207226:	6105                	addi	sp,sp,32
ffffffffc0207228:	8082                	ret
ffffffffc020722a:	f2878793          	addi	a5,a5,-216
ffffffffc020722e:	b77d                	j	ffffffffc02071dc <proc_init+0xf8>
ffffffffc0207230:	00007617          	auipc	a2,0x7
ffffffffc0207234:	91860613          	addi	a2,a2,-1768 # ffffffffc020db48 <etext+0x2272>
ffffffffc0207238:	4fa00593          	li	a1,1274
ffffffffc020723c:	00006517          	auipc	a0,0x6
ffffffffc0207240:	4fc50513          	addi	a0,a0,1276 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0207244:	fe9f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207248:	00007617          	auipc	a2,0x7
ffffffffc020724c:	8d060613          	addi	a2,a2,-1840 # ffffffffc020db18 <etext+0x2242>
ffffffffc0207250:	4ee00593          	li	a1,1262
ffffffffc0207254:	00006517          	auipc	a0,0x6
ffffffffc0207258:	4e450513          	addi	a0,a0,1252 # ffffffffc020d738 <etext+0x1e62>
ffffffffc020725c:	fd1f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207260:	00007617          	auipc	a2,0x7
ffffffffc0207264:	8a060613          	addi	a2,a2,-1888 # ffffffffc020db00 <etext+0x222a>
ffffffffc0207268:	4e400593          	li	a1,1252
ffffffffc020726c:	00006517          	auipc	a0,0x6
ffffffffc0207270:	4cc50513          	addi	a0,a0,1228 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0207274:	fb9f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207278:	00007697          	auipc	a3,0x7
ffffffffc020727c:	92068693          	addi	a3,a3,-1760 # ffffffffc020db98 <etext+0x22c2>
ffffffffc0207280:	00005617          	auipc	a2,0x5
ffffffffc0207284:	b1060613          	addi	a2,a2,-1264 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207288:	50100593          	li	a1,1281
ffffffffc020728c:	00006517          	auipc	a0,0x6
ffffffffc0207290:	4ac50513          	addi	a0,a0,1196 # ffffffffc020d738 <etext+0x1e62>
ffffffffc0207294:	f99f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207298:	00007697          	auipc	a3,0x7
ffffffffc020729c:	8d868693          	addi	a3,a3,-1832 # ffffffffc020db70 <etext+0x229a>
ffffffffc02072a0:	00005617          	auipc	a2,0x5
ffffffffc02072a4:	af060613          	addi	a2,a2,-1296 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02072a8:	50000593          	li	a1,1280
ffffffffc02072ac:	00006517          	auipc	a0,0x6
ffffffffc02072b0:	48c50513          	addi	a0,a0,1164 # ffffffffc020d738 <etext+0x1e62>
ffffffffc02072b4:	f79f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc02072b8 <cpu_idle>:
ffffffffc02072b8:	1141                	addi	sp,sp,-16
ffffffffc02072ba:	e022                	sd	s0,0(sp)
ffffffffc02072bc:	e406                	sd	ra,8(sp)
ffffffffc02072be:	0008f417          	auipc	s0,0x8f
ffffffffc02072c2:	60a40413          	addi	s0,s0,1546 # ffffffffc02968c8 <current>
ffffffffc02072c6:	6018                	ld	a4,0(s0)
ffffffffc02072c8:	6f1c                	ld	a5,24(a4)
ffffffffc02072ca:	dffd                	beqz	a5,ffffffffc02072c8 <cpu_idle+0x10>
ffffffffc02072cc:	206000ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc02072d0:	bfdd                	j	ffffffffc02072c6 <cpu_idle+0xe>

ffffffffc02072d2 <lab6_set_priority>:
ffffffffc02072d2:	1101                	addi	sp,sp,-32
ffffffffc02072d4:	85aa                	mv	a1,a0
ffffffffc02072d6:	e42a                	sd	a0,8(sp)
ffffffffc02072d8:	00007517          	auipc	a0,0x7
ffffffffc02072dc:	8e850513          	addi	a0,a0,-1816 # ffffffffc020dbc0 <etext+0x22ea>
ffffffffc02072e0:	ec06                	sd	ra,24(sp)
ffffffffc02072e2:	e47f80ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02072e6:	65a2                	ld	a1,8(sp)
ffffffffc02072e8:	0008f717          	auipc	a4,0x8f
ffffffffc02072ec:	5e073703          	ld	a4,1504(a4) # ffffffffc02968c8 <current>
ffffffffc02072f0:	4785                	li	a5,1
ffffffffc02072f2:	c191                	beqz	a1,ffffffffc02072f6 <lab6_set_priority+0x24>
ffffffffc02072f4:	87ae                	mv	a5,a1
ffffffffc02072f6:	60e2                	ld	ra,24(sp)
ffffffffc02072f8:	14f72223          	sw	a5,324(a4)
ffffffffc02072fc:	6105                	addi	sp,sp,32
ffffffffc02072fe:	8082                	ret

ffffffffc0207300 <do_sleep>:
ffffffffc0207300:	c531                	beqz	a0,ffffffffc020734c <do_sleep+0x4c>
ffffffffc0207302:	7139                	addi	sp,sp,-64
ffffffffc0207304:	fc06                	sd	ra,56(sp)
ffffffffc0207306:	f822                	sd	s0,48(sp)
ffffffffc0207308:	100027f3          	csrr	a5,sstatus
ffffffffc020730c:	8b89                	andi	a5,a5,2
ffffffffc020730e:	e3a9                	bnez	a5,ffffffffc0207350 <do_sleep+0x50>
ffffffffc0207310:	0008f797          	auipc	a5,0x8f
ffffffffc0207314:	5b87b783          	ld	a5,1464(a5) # ffffffffc02968c8 <current>
ffffffffc0207318:	1014                	addi	a3,sp,32
ffffffffc020731a:	80000737          	lui	a4,0x80000
ffffffffc020731e:	c82a                	sw	a0,16(sp)
ffffffffc0207320:	f436                	sd	a3,40(sp)
ffffffffc0207322:	f036                	sd	a3,32(sp)
ffffffffc0207324:	ec3e                	sd	a5,24(sp)
ffffffffc0207326:	4685                	li	a3,1
ffffffffc0207328:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_bin_sfs_img_size+0xffffffff7ff8ad02>
ffffffffc020732a:	0808                	addi	a0,sp,16
ffffffffc020732c:	c394                	sw	a3,0(a5)
ffffffffc020732e:	0ee7a623          	sw	a4,236(a5)
ffffffffc0207332:	842a                	mv	s0,a0
ffffffffc0207334:	254000ef          	jal	ffffffffc0207588 <add_timer>
ffffffffc0207338:	19a000ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc020733c:	8522                	mv	a0,s0
ffffffffc020733e:	310000ef          	jal	ffffffffc020764e <del_timer>
ffffffffc0207342:	70e2                	ld	ra,56(sp)
ffffffffc0207344:	7442                	ld	s0,48(sp)
ffffffffc0207346:	4501                	li	a0,0
ffffffffc0207348:	6121                	addi	sp,sp,64
ffffffffc020734a:	8082                	ret
ffffffffc020734c:	4501                	li	a0,0
ffffffffc020734e:	8082                	ret
ffffffffc0207350:	e42a                	sd	a0,8(sp)
ffffffffc0207352:	9b1f90ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0207356:	0008f797          	auipc	a5,0x8f
ffffffffc020735a:	5727b783          	ld	a5,1394(a5) # ffffffffc02968c8 <current>
ffffffffc020735e:	6522                	ld	a0,8(sp)
ffffffffc0207360:	1014                	addi	a3,sp,32
ffffffffc0207362:	80000737          	lui	a4,0x80000
ffffffffc0207366:	c82a                	sw	a0,16(sp)
ffffffffc0207368:	f436                	sd	a3,40(sp)
ffffffffc020736a:	f036                	sd	a3,32(sp)
ffffffffc020736c:	ec3e                	sd	a5,24(sp)
ffffffffc020736e:	4685                	li	a3,1
ffffffffc0207370:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_bin_sfs_img_size+0xffffffff7ff8ad02>
ffffffffc0207372:	0808                	addi	a0,sp,16
ffffffffc0207374:	c394                	sw	a3,0(a5)
ffffffffc0207376:	0ee7a623          	sw	a4,236(a5)
ffffffffc020737a:	842a                	mv	s0,a0
ffffffffc020737c:	20c000ef          	jal	ffffffffc0207588 <add_timer>
ffffffffc0207380:	97df90ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0207384:	bf55                	j	ffffffffc0207338 <do_sleep+0x38>

ffffffffc0207386 <sched_init>:
ffffffffc0207386:	0008a797          	auipc	a5,0x8a
ffffffffc020738a:	c9a78793          	addi	a5,a5,-870 # ffffffffc0291020 <default_sched_class>
ffffffffc020738e:	1141                	addi	sp,sp,-16
ffffffffc0207390:	6794                	ld	a3,8(a5)
ffffffffc0207392:	0008f717          	auipc	a4,0x8f
ffffffffc0207396:	54f73b23          	sd	a5,1366(a4) # ffffffffc02968e8 <sched_class>
ffffffffc020739a:	e406                	sd	ra,8(sp)
ffffffffc020739c:	0008e797          	auipc	a5,0x8e
ffffffffc02073a0:	45478793          	addi	a5,a5,1108 # ffffffffc02957f0 <timer_list>
ffffffffc02073a4:	0008e717          	auipc	a4,0x8e
ffffffffc02073a8:	42c70713          	addi	a4,a4,1068 # ffffffffc02957d0 <__rq>
ffffffffc02073ac:	4615                	li	a2,5
ffffffffc02073ae:	e79c                	sd	a5,8(a5)
ffffffffc02073b0:	e39c                	sd	a5,0(a5)
ffffffffc02073b2:	853a                	mv	a0,a4
ffffffffc02073b4:	cb50                	sw	a2,20(a4)
ffffffffc02073b6:	0008f797          	auipc	a5,0x8f
ffffffffc02073ba:	52e7b523          	sd	a4,1322(a5) # ffffffffc02968e0 <rq>
ffffffffc02073be:	9682                	jalr	a3
ffffffffc02073c0:	0008f797          	auipc	a5,0x8f
ffffffffc02073c4:	5287b783          	ld	a5,1320(a5) # ffffffffc02968e8 <sched_class>
ffffffffc02073c8:	60a2                	ld	ra,8(sp)
ffffffffc02073ca:	00007517          	auipc	a0,0x7
ffffffffc02073ce:	80e50513          	addi	a0,a0,-2034 # ffffffffc020dbd8 <etext+0x2302>
ffffffffc02073d2:	638c                	ld	a1,0(a5)
ffffffffc02073d4:	0141                	addi	sp,sp,16
ffffffffc02073d6:	d53f806f          	j	ffffffffc0200128 <cprintf>

ffffffffc02073da <wakeup_proc>:
ffffffffc02073da:	4118                	lw	a4,0(a0)
ffffffffc02073dc:	1101                	addi	sp,sp,-32
ffffffffc02073de:	ec06                	sd	ra,24(sp)
ffffffffc02073e0:	478d                	li	a5,3
ffffffffc02073e2:	0cf70863          	beq	a4,a5,ffffffffc02074b2 <wakeup_proc+0xd8>
ffffffffc02073e6:	85aa                	mv	a1,a0
ffffffffc02073e8:	100027f3          	csrr	a5,sstatus
ffffffffc02073ec:	8b89                	andi	a5,a5,2
ffffffffc02073ee:	e3b1                	bnez	a5,ffffffffc0207432 <wakeup_proc+0x58>
ffffffffc02073f0:	4789                	li	a5,2
ffffffffc02073f2:	08f70563          	beq	a4,a5,ffffffffc020747c <wakeup_proc+0xa2>
ffffffffc02073f6:	0008f717          	auipc	a4,0x8f
ffffffffc02073fa:	4d273703          	ld	a4,1234(a4) # ffffffffc02968c8 <current>
ffffffffc02073fe:	0e052623          	sw	zero,236(a0)
ffffffffc0207402:	c11c                	sw	a5,0(a0)
ffffffffc0207404:	02e50463          	beq	a0,a4,ffffffffc020742c <wakeup_proc+0x52>
ffffffffc0207408:	0008f797          	auipc	a5,0x8f
ffffffffc020740c:	4d07b783          	ld	a5,1232(a5) # ffffffffc02968d8 <idleproc>
ffffffffc0207410:	00f50e63          	beq	a0,a5,ffffffffc020742c <wakeup_proc+0x52>
ffffffffc0207414:	0008f797          	auipc	a5,0x8f
ffffffffc0207418:	4d47b783          	ld	a5,1236(a5) # ffffffffc02968e8 <sched_class>
ffffffffc020741c:	60e2                	ld	ra,24(sp)
ffffffffc020741e:	0008f517          	auipc	a0,0x8f
ffffffffc0207422:	4c253503          	ld	a0,1218(a0) # ffffffffc02968e0 <rq>
ffffffffc0207426:	6b9c                	ld	a5,16(a5)
ffffffffc0207428:	6105                	addi	sp,sp,32
ffffffffc020742a:	8782                	jr	a5
ffffffffc020742c:	60e2                	ld	ra,24(sp)
ffffffffc020742e:	6105                	addi	sp,sp,32
ffffffffc0207430:	8082                	ret
ffffffffc0207432:	e42a                	sd	a0,8(sp)
ffffffffc0207434:	8cff90ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0207438:	65a2                	ld	a1,8(sp)
ffffffffc020743a:	4789                	li	a5,2
ffffffffc020743c:	4198                	lw	a4,0(a1)
ffffffffc020743e:	04f70d63          	beq	a4,a5,ffffffffc0207498 <wakeup_proc+0xbe>
ffffffffc0207442:	0008f717          	auipc	a4,0x8f
ffffffffc0207446:	48673703          	ld	a4,1158(a4) # ffffffffc02968c8 <current>
ffffffffc020744a:	0e05a623          	sw	zero,236(a1)
ffffffffc020744e:	c19c                	sw	a5,0(a1)
ffffffffc0207450:	02e58263          	beq	a1,a4,ffffffffc0207474 <wakeup_proc+0x9a>
ffffffffc0207454:	0008f797          	auipc	a5,0x8f
ffffffffc0207458:	4847b783          	ld	a5,1156(a5) # ffffffffc02968d8 <idleproc>
ffffffffc020745c:	00f58c63          	beq	a1,a5,ffffffffc0207474 <wakeup_proc+0x9a>
ffffffffc0207460:	0008f797          	auipc	a5,0x8f
ffffffffc0207464:	4887b783          	ld	a5,1160(a5) # ffffffffc02968e8 <sched_class>
ffffffffc0207468:	0008f517          	auipc	a0,0x8f
ffffffffc020746c:	47853503          	ld	a0,1144(a0) # ffffffffc02968e0 <rq>
ffffffffc0207470:	6b9c                	ld	a5,16(a5)
ffffffffc0207472:	9782                	jalr	a5
ffffffffc0207474:	60e2                	ld	ra,24(sp)
ffffffffc0207476:	6105                	addi	sp,sp,32
ffffffffc0207478:	885f906f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc020747c:	60e2                	ld	ra,24(sp)
ffffffffc020747e:	00006617          	auipc	a2,0x6
ffffffffc0207482:	7aa60613          	addi	a2,a2,1962 # ffffffffc020dc28 <etext+0x2352>
ffffffffc0207486:	05200593          	li	a1,82
ffffffffc020748a:	00006517          	auipc	a0,0x6
ffffffffc020748e:	78650513          	addi	a0,a0,1926 # ffffffffc020dc10 <etext+0x233a>
ffffffffc0207492:	6105                	addi	sp,sp,32
ffffffffc0207494:	e03f806f          	j	ffffffffc0200296 <__warn>
ffffffffc0207498:	00006617          	auipc	a2,0x6
ffffffffc020749c:	79060613          	addi	a2,a2,1936 # ffffffffc020dc28 <etext+0x2352>
ffffffffc02074a0:	05200593          	li	a1,82
ffffffffc02074a4:	00006517          	auipc	a0,0x6
ffffffffc02074a8:	76c50513          	addi	a0,a0,1900 # ffffffffc020dc10 <etext+0x233a>
ffffffffc02074ac:	debf80ef          	jal	ffffffffc0200296 <__warn>
ffffffffc02074b0:	b7d1                	j	ffffffffc0207474 <wakeup_proc+0x9a>
ffffffffc02074b2:	00006697          	auipc	a3,0x6
ffffffffc02074b6:	73e68693          	addi	a3,a3,1854 # ffffffffc020dbf0 <etext+0x231a>
ffffffffc02074ba:	00005617          	auipc	a2,0x5
ffffffffc02074be:	8d660613          	addi	a2,a2,-1834 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02074c2:	04300593          	li	a1,67
ffffffffc02074c6:	00006517          	auipc	a0,0x6
ffffffffc02074ca:	74a50513          	addi	a0,a0,1866 # ffffffffc020dc10 <etext+0x233a>
ffffffffc02074ce:	d5ff80ef          	jal	ffffffffc020022c <__panic>

ffffffffc02074d2 <schedule>:
ffffffffc02074d2:	7139                	addi	sp,sp,-64
ffffffffc02074d4:	fc06                	sd	ra,56(sp)
ffffffffc02074d6:	f822                	sd	s0,48(sp)
ffffffffc02074d8:	f426                	sd	s1,40(sp)
ffffffffc02074da:	f04a                	sd	s2,32(sp)
ffffffffc02074dc:	ec4e                	sd	s3,24(sp)
ffffffffc02074de:	100027f3          	csrr	a5,sstatus
ffffffffc02074e2:	8b89                	andi	a5,a5,2
ffffffffc02074e4:	4981                	li	s3,0
ffffffffc02074e6:	efc9                	bnez	a5,ffffffffc0207580 <schedule+0xae>
ffffffffc02074e8:	0008f417          	auipc	s0,0x8f
ffffffffc02074ec:	3e040413          	addi	s0,s0,992 # ffffffffc02968c8 <current>
ffffffffc02074f0:	600c                	ld	a1,0(s0)
ffffffffc02074f2:	4789                	li	a5,2
ffffffffc02074f4:	0008f497          	auipc	s1,0x8f
ffffffffc02074f8:	3ec48493          	addi	s1,s1,1004 # ffffffffc02968e0 <rq>
ffffffffc02074fc:	4198                	lw	a4,0(a1)
ffffffffc02074fe:	0005bc23          	sd	zero,24(a1)
ffffffffc0207502:	0008f917          	auipc	s2,0x8f
ffffffffc0207506:	3e690913          	addi	s2,s2,998 # ffffffffc02968e8 <sched_class>
ffffffffc020750a:	04f70f63          	beq	a4,a5,ffffffffc0207568 <schedule+0x96>
ffffffffc020750e:	00093783          	ld	a5,0(s2)
ffffffffc0207512:	6088                	ld	a0,0(s1)
ffffffffc0207514:	739c                	ld	a5,32(a5)
ffffffffc0207516:	9782                	jalr	a5
ffffffffc0207518:	85aa                	mv	a1,a0
ffffffffc020751a:	c131                	beqz	a0,ffffffffc020755e <schedule+0x8c>
ffffffffc020751c:	00093783          	ld	a5,0(s2)
ffffffffc0207520:	6088                	ld	a0,0(s1)
ffffffffc0207522:	e42e                	sd	a1,8(sp)
ffffffffc0207524:	6f9c                	ld	a5,24(a5)
ffffffffc0207526:	9782                	jalr	a5
ffffffffc0207528:	65a2                	ld	a1,8(sp)
ffffffffc020752a:	459c                	lw	a5,8(a1)
ffffffffc020752c:	6018                	ld	a4,0(s0)
ffffffffc020752e:	2785                	addiw	a5,a5,1
ffffffffc0207530:	c59c                	sw	a5,8(a1)
ffffffffc0207532:	00b70563          	beq	a4,a1,ffffffffc020753c <schedule+0x6a>
ffffffffc0207536:	852e                	mv	a0,a1
ffffffffc0207538:	fa0fe0ef          	jal	ffffffffc0205cd8 <proc_run>
ffffffffc020753c:	00099963          	bnez	s3,ffffffffc020754e <schedule+0x7c>
ffffffffc0207540:	70e2                	ld	ra,56(sp)
ffffffffc0207542:	7442                	ld	s0,48(sp)
ffffffffc0207544:	74a2                	ld	s1,40(sp)
ffffffffc0207546:	7902                	ld	s2,32(sp)
ffffffffc0207548:	69e2                	ld	s3,24(sp)
ffffffffc020754a:	6121                	addi	sp,sp,64
ffffffffc020754c:	8082                	ret
ffffffffc020754e:	7442                	ld	s0,48(sp)
ffffffffc0207550:	70e2                	ld	ra,56(sp)
ffffffffc0207552:	74a2                	ld	s1,40(sp)
ffffffffc0207554:	7902                	ld	s2,32(sp)
ffffffffc0207556:	69e2                	ld	s3,24(sp)
ffffffffc0207558:	6121                	addi	sp,sp,64
ffffffffc020755a:	fa2f906f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc020755e:	0008f597          	auipc	a1,0x8f
ffffffffc0207562:	37a5b583          	ld	a1,890(a1) # ffffffffc02968d8 <idleproc>
ffffffffc0207566:	b7d1                	j	ffffffffc020752a <schedule+0x58>
ffffffffc0207568:	0008f797          	auipc	a5,0x8f
ffffffffc020756c:	3707b783          	ld	a5,880(a5) # ffffffffc02968d8 <idleproc>
ffffffffc0207570:	f8f58fe3          	beq	a1,a5,ffffffffc020750e <schedule+0x3c>
ffffffffc0207574:	00093783          	ld	a5,0(s2)
ffffffffc0207578:	6088                	ld	a0,0(s1)
ffffffffc020757a:	6b9c                	ld	a5,16(a5)
ffffffffc020757c:	9782                	jalr	a5
ffffffffc020757e:	bf41                	j	ffffffffc020750e <schedule+0x3c>
ffffffffc0207580:	f82f90ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0207584:	4985                	li	s3,1
ffffffffc0207586:	b78d                	j	ffffffffc02074e8 <schedule+0x16>

ffffffffc0207588 <add_timer>:
ffffffffc0207588:	1101                	addi	sp,sp,-32
ffffffffc020758a:	ec06                	sd	ra,24(sp)
ffffffffc020758c:	100027f3          	csrr	a5,sstatus
ffffffffc0207590:	8b89                	andi	a5,a5,2
ffffffffc0207592:	4801                	li	a6,0
ffffffffc0207594:	e7bd                	bnez	a5,ffffffffc0207602 <add_timer+0x7a>
ffffffffc0207596:	4118                	lw	a4,0(a0)
ffffffffc0207598:	cb3d                	beqz	a4,ffffffffc020760e <add_timer+0x86>
ffffffffc020759a:	651c                	ld	a5,8(a0)
ffffffffc020759c:	cbad                	beqz	a5,ffffffffc020760e <add_timer+0x86>
ffffffffc020759e:	6d1c                	ld	a5,24(a0)
ffffffffc02075a0:	01050593          	addi	a1,a0,16
ffffffffc02075a4:	08f59563          	bne	a1,a5,ffffffffc020762e <add_timer+0xa6>
ffffffffc02075a8:	0008e617          	auipc	a2,0x8e
ffffffffc02075ac:	24860613          	addi	a2,a2,584 # ffffffffc02957f0 <timer_list>
ffffffffc02075b0:	661c                	ld	a5,8(a2)
ffffffffc02075b2:	00c79863          	bne	a5,a2,ffffffffc02075c2 <add_timer+0x3a>
ffffffffc02075b6:	a805                	j	ffffffffc02075e6 <add_timer+0x5e>
ffffffffc02075b8:	679c                	ld	a5,8(a5)
ffffffffc02075ba:	9f15                	subw	a4,a4,a3
ffffffffc02075bc:	c118                	sw	a4,0(a0)
ffffffffc02075be:	02c78463          	beq	a5,a2,ffffffffc02075e6 <add_timer+0x5e>
ffffffffc02075c2:	ff07a683          	lw	a3,-16(a5)
ffffffffc02075c6:	fed779e3          	bgeu	a4,a3,ffffffffc02075b8 <add_timer+0x30>
ffffffffc02075ca:	9e99                	subw	a3,a3,a4
ffffffffc02075cc:	6398                	ld	a4,0(a5)
ffffffffc02075ce:	fed7a823          	sw	a3,-16(a5)
ffffffffc02075d2:	e38c                	sd	a1,0(a5)
ffffffffc02075d4:	e70c                	sd	a1,8(a4)
ffffffffc02075d6:	e918                	sd	a4,16(a0)
ffffffffc02075d8:	ed1c                	sd	a5,24(a0)
ffffffffc02075da:	02080163          	beqz	a6,ffffffffc02075fc <add_timer+0x74>
ffffffffc02075de:	60e2                	ld	ra,24(sp)
ffffffffc02075e0:	6105                	addi	sp,sp,32
ffffffffc02075e2:	f1af906f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc02075e6:	0008e797          	auipc	a5,0x8e
ffffffffc02075ea:	20a78793          	addi	a5,a5,522 # ffffffffc02957f0 <timer_list>
ffffffffc02075ee:	6398                	ld	a4,0(a5)
ffffffffc02075f0:	e38c                	sd	a1,0(a5)
ffffffffc02075f2:	e70c                	sd	a1,8(a4)
ffffffffc02075f4:	e918                	sd	a4,16(a0)
ffffffffc02075f6:	ed1c                	sd	a5,24(a0)
ffffffffc02075f8:	fe0813e3          	bnez	a6,ffffffffc02075de <add_timer+0x56>
ffffffffc02075fc:	60e2                	ld	ra,24(sp)
ffffffffc02075fe:	6105                	addi	sp,sp,32
ffffffffc0207600:	8082                	ret
ffffffffc0207602:	e42a                	sd	a0,8(sp)
ffffffffc0207604:	efef90ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0207608:	6522                	ld	a0,8(sp)
ffffffffc020760a:	4805                	li	a6,1
ffffffffc020760c:	b769                	j	ffffffffc0207596 <add_timer+0xe>
ffffffffc020760e:	00006697          	auipc	a3,0x6
ffffffffc0207612:	63a68693          	addi	a3,a3,1594 # ffffffffc020dc48 <etext+0x2372>
ffffffffc0207616:	00004617          	auipc	a2,0x4
ffffffffc020761a:	77a60613          	addi	a2,a2,1914 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020761e:	07a00593          	li	a1,122
ffffffffc0207622:	00006517          	auipc	a0,0x6
ffffffffc0207626:	5ee50513          	addi	a0,a0,1518 # ffffffffc020dc10 <etext+0x233a>
ffffffffc020762a:	c03f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc020762e:	00006697          	auipc	a3,0x6
ffffffffc0207632:	64a68693          	addi	a3,a3,1610 # ffffffffc020dc78 <etext+0x23a2>
ffffffffc0207636:	00004617          	auipc	a2,0x4
ffffffffc020763a:	75a60613          	addi	a2,a2,1882 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020763e:	07b00593          	li	a1,123
ffffffffc0207642:	00006517          	auipc	a0,0x6
ffffffffc0207646:	5ce50513          	addi	a0,a0,1486 # ffffffffc020dc10 <etext+0x233a>
ffffffffc020764a:	be3f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc020764e <del_timer>:
ffffffffc020764e:	100027f3          	csrr	a5,sstatus
ffffffffc0207652:	8b89                	andi	a5,a5,2
ffffffffc0207654:	ef95                	bnez	a5,ffffffffc0207690 <del_timer+0x42>
ffffffffc0207656:	6d1c                	ld	a5,24(a0)
ffffffffc0207658:	01050713          	addi	a4,a0,16
ffffffffc020765c:	4601                	li	a2,0
ffffffffc020765e:	02f70863          	beq	a4,a5,ffffffffc020768e <del_timer+0x40>
ffffffffc0207662:	0008e597          	auipc	a1,0x8e
ffffffffc0207666:	18e58593          	addi	a1,a1,398 # ffffffffc02957f0 <timer_list>
ffffffffc020766a:	4114                	lw	a3,0(a0)
ffffffffc020766c:	00b78863          	beq	a5,a1,ffffffffc020767c <del_timer+0x2e>
ffffffffc0207670:	c691                	beqz	a3,ffffffffc020767c <del_timer+0x2e>
ffffffffc0207672:	ff07a583          	lw	a1,-16(a5)
ffffffffc0207676:	9ead                	addw	a3,a3,a1
ffffffffc0207678:	fed7a823          	sw	a3,-16(a5)
ffffffffc020767c:	6914                	ld	a3,16(a0)
ffffffffc020767e:	e69c                	sd	a5,8(a3)
ffffffffc0207680:	e394                	sd	a3,0(a5)
ffffffffc0207682:	ed18                	sd	a4,24(a0)
ffffffffc0207684:	e918                	sd	a4,16(a0)
ffffffffc0207686:	e211                	bnez	a2,ffffffffc020768a <del_timer+0x3c>
ffffffffc0207688:	8082                	ret
ffffffffc020768a:	e72f906f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc020768e:	8082                	ret
ffffffffc0207690:	1101                	addi	sp,sp,-32
ffffffffc0207692:	e42a                	sd	a0,8(sp)
ffffffffc0207694:	ec06                	sd	ra,24(sp)
ffffffffc0207696:	e6cf90ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc020769a:	6522                	ld	a0,8(sp)
ffffffffc020769c:	4605                	li	a2,1
ffffffffc020769e:	6d1c                	ld	a5,24(a0)
ffffffffc02076a0:	01050713          	addi	a4,a0,16
ffffffffc02076a4:	02f70863          	beq	a4,a5,ffffffffc02076d4 <del_timer+0x86>
ffffffffc02076a8:	0008e597          	auipc	a1,0x8e
ffffffffc02076ac:	14858593          	addi	a1,a1,328 # ffffffffc02957f0 <timer_list>
ffffffffc02076b0:	4114                	lw	a3,0(a0)
ffffffffc02076b2:	00b78863          	beq	a5,a1,ffffffffc02076c2 <del_timer+0x74>
ffffffffc02076b6:	c691                	beqz	a3,ffffffffc02076c2 <del_timer+0x74>
ffffffffc02076b8:	ff07a583          	lw	a1,-16(a5)
ffffffffc02076bc:	9ead                	addw	a3,a3,a1
ffffffffc02076be:	fed7a823          	sw	a3,-16(a5)
ffffffffc02076c2:	6914                	ld	a3,16(a0)
ffffffffc02076c4:	e69c                	sd	a5,8(a3)
ffffffffc02076c6:	e394                	sd	a3,0(a5)
ffffffffc02076c8:	ed18                	sd	a4,24(a0)
ffffffffc02076ca:	e918                	sd	a4,16(a0)
ffffffffc02076cc:	e601                	bnez	a2,ffffffffc02076d4 <del_timer+0x86>
ffffffffc02076ce:	60e2                	ld	ra,24(sp)
ffffffffc02076d0:	6105                	addi	sp,sp,32
ffffffffc02076d2:	8082                	ret
ffffffffc02076d4:	60e2                	ld	ra,24(sp)
ffffffffc02076d6:	6105                	addi	sp,sp,32
ffffffffc02076d8:	e24f906f          	j	ffffffffc0200cfc <intr_enable>

ffffffffc02076dc <run_timer_list>:
ffffffffc02076dc:	7179                	addi	sp,sp,-48
ffffffffc02076de:	f406                	sd	ra,40(sp)
ffffffffc02076e0:	f022                	sd	s0,32(sp)
ffffffffc02076e2:	e44e                	sd	s3,8(sp)
ffffffffc02076e4:	e052                	sd	s4,0(sp)
ffffffffc02076e6:	100027f3          	csrr	a5,sstatus
ffffffffc02076ea:	8b89                	andi	a5,a5,2
ffffffffc02076ec:	0e079b63          	bnez	a5,ffffffffc02077e2 <run_timer_list+0x106>
ffffffffc02076f0:	0008e997          	auipc	s3,0x8e
ffffffffc02076f4:	10098993          	addi	s3,s3,256 # ffffffffc02957f0 <timer_list>
ffffffffc02076f8:	0089b403          	ld	s0,8(s3)
ffffffffc02076fc:	4a01                	li	s4,0
ffffffffc02076fe:	0d340463          	beq	s0,s3,ffffffffc02077c6 <run_timer_list+0xea>
ffffffffc0207702:	ff042783          	lw	a5,-16(s0)
ffffffffc0207706:	12078763          	beqz	a5,ffffffffc0207834 <run_timer_list+0x158>
ffffffffc020770a:	e84a                	sd	s2,16(sp)
ffffffffc020770c:	37fd                	addiw	a5,a5,-1
ffffffffc020770e:	fef42823          	sw	a5,-16(s0)
ffffffffc0207712:	ff040913          	addi	s2,s0,-16
ffffffffc0207716:	efb1                	bnez	a5,ffffffffc0207772 <run_timer_list+0x96>
ffffffffc0207718:	ec26                	sd	s1,24(sp)
ffffffffc020771a:	a005                	j	ffffffffc020773a <run_timer_list+0x5e>
ffffffffc020771c:	0e07dc63          	bgez	a5,ffffffffc0207814 <run_timer_list+0x138>
ffffffffc0207720:	8526                	mv	a0,s1
ffffffffc0207722:	cb9ff0ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc0207726:	854a                	mv	a0,s2
ffffffffc0207728:	f27ff0ef          	jal	ffffffffc020764e <del_timer>
ffffffffc020772c:	05340263          	beq	s0,s3,ffffffffc0207770 <run_timer_list+0x94>
ffffffffc0207730:	ff042783          	lw	a5,-16(s0)
ffffffffc0207734:	ff040913          	addi	s2,s0,-16
ffffffffc0207738:	ef85                	bnez	a5,ffffffffc0207770 <run_timer_list+0x94>
ffffffffc020773a:	00893483          	ld	s1,8(s2)
ffffffffc020773e:	6400                	ld	s0,8(s0)
ffffffffc0207740:	0ec4a783          	lw	a5,236(s1)
ffffffffc0207744:	ffe1                	bnez	a5,ffffffffc020771c <run_timer_list+0x40>
ffffffffc0207746:	40d4                	lw	a3,4(s1)
ffffffffc0207748:	00006617          	auipc	a2,0x6
ffffffffc020774c:	59860613          	addi	a2,a2,1432 # ffffffffc020dce0 <etext+0x240a>
ffffffffc0207750:	0ba00593          	li	a1,186
ffffffffc0207754:	00006517          	auipc	a0,0x6
ffffffffc0207758:	4bc50513          	addi	a0,a0,1212 # ffffffffc020dc10 <etext+0x233a>
ffffffffc020775c:	b3bf80ef          	jal	ffffffffc0200296 <__warn>
ffffffffc0207760:	8526                	mv	a0,s1
ffffffffc0207762:	c79ff0ef          	jal	ffffffffc02073da <wakeup_proc>
ffffffffc0207766:	854a                	mv	a0,s2
ffffffffc0207768:	ee7ff0ef          	jal	ffffffffc020764e <del_timer>
ffffffffc020776c:	fd3412e3          	bne	s0,s3,ffffffffc0207730 <run_timer_list+0x54>
ffffffffc0207770:	64e2                	ld	s1,24(sp)
ffffffffc0207772:	0008f597          	auipc	a1,0x8f
ffffffffc0207776:	1565b583          	ld	a1,342(a1) # ffffffffc02968c8 <current>
ffffffffc020777a:	cd85                	beqz	a1,ffffffffc02077b2 <run_timer_list+0xd6>
ffffffffc020777c:	0008f797          	auipc	a5,0x8f
ffffffffc0207780:	15c7b783          	ld	a5,348(a5) # ffffffffc02968d8 <idleproc>
ffffffffc0207784:	02f58563          	beq	a1,a5,ffffffffc02077ae <run_timer_list+0xd2>
ffffffffc0207788:	6942                	ld	s2,16(sp)
ffffffffc020778a:	0008f797          	auipc	a5,0x8f
ffffffffc020778e:	15e7b783          	ld	a5,350(a5) # ffffffffc02968e8 <sched_class>
ffffffffc0207792:	0008f517          	auipc	a0,0x8f
ffffffffc0207796:	14e53503          	ld	a0,334(a0) # ffffffffc02968e0 <rq>
ffffffffc020779a:	779c                	ld	a5,40(a5)
ffffffffc020779c:	9782                	jalr	a5
ffffffffc020779e:	000a1d63          	bnez	s4,ffffffffc02077b8 <run_timer_list+0xdc>
ffffffffc02077a2:	70a2                	ld	ra,40(sp)
ffffffffc02077a4:	7402                	ld	s0,32(sp)
ffffffffc02077a6:	69a2                	ld	s3,8(sp)
ffffffffc02077a8:	6a02                	ld	s4,0(sp)
ffffffffc02077aa:	6145                	addi	sp,sp,48
ffffffffc02077ac:	8082                	ret
ffffffffc02077ae:	4785                	li	a5,1
ffffffffc02077b0:	ed9c                	sd	a5,24(a1)
ffffffffc02077b2:	6942                	ld	s2,16(sp)
ffffffffc02077b4:	fe0a07e3          	beqz	s4,ffffffffc02077a2 <run_timer_list+0xc6>
ffffffffc02077b8:	7402                	ld	s0,32(sp)
ffffffffc02077ba:	70a2                	ld	ra,40(sp)
ffffffffc02077bc:	69a2                	ld	s3,8(sp)
ffffffffc02077be:	6a02                	ld	s4,0(sp)
ffffffffc02077c0:	6145                	addi	sp,sp,48
ffffffffc02077c2:	d3af906f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc02077c6:	0008f597          	auipc	a1,0x8f
ffffffffc02077ca:	1025b583          	ld	a1,258(a1) # ffffffffc02968c8 <current>
ffffffffc02077ce:	d9f1                	beqz	a1,ffffffffc02077a2 <run_timer_list+0xc6>
ffffffffc02077d0:	0008f797          	auipc	a5,0x8f
ffffffffc02077d4:	1087b783          	ld	a5,264(a5) # ffffffffc02968d8 <idleproc>
ffffffffc02077d8:	fab799e3          	bne	a5,a1,ffffffffc020778a <run_timer_list+0xae>
ffffffffc02077dc:	4705                	li	a4,1
ffffffffc02077de:	ef98                	sd	a4,24(a5)
ffffffffc02077e0:	b7c9                	j	ffffffffc02077a2 <run_timer_list+0xc6>
ffffffffc02077e2:	0008e997          	auipc	s3,0x8e
ffffffffc02077e6:	00e98993          	addi	s3,s3,14 # ffffffffc02957f0 <timer_list>
ffffffffc02077ea:	d18f90ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc02077ee:	0089b403          	ld	s0,8(s3)
ffffffffc02077f2:	4a05                	li	s4,1
ffffffffc02077f4:	f13417e3          	bne	s0,s3,ffffffffc0207702 <run_timer_list+0x26>
ffffffffc02077f8:	0008f597          	auipc	a1,0x8f
ffffffffc02077fc:	0d05b583          	ld	a1,208(a1) # ffffffffc02968c8 <current>
ffffffffc0207800:	ddc5                	beqz	a1,ffffffffc02077b8 <run_timer_list+0xdc>
ffffffffc0207802:	0008f797          	auipc	a5,0x8f
ffffffffc0207806:	0d67b783          	ld	a5,214(a5) # ffffffffc02968d8 <idleproc>
ffffffffc020780a:	f8f590e3          	bne	a1,a5,ffffffffc020778a <run_timer_list+0xae>
ffffffffc020780e:	0145bc23          	sd	s4,24(a1)
ffffffffc0207812:	b75d                	j	ffffffffc02077b8 <run_timer_list+0xdc>
ffffffffc0207814:	00006697          	auipc	a3,0x6
ffffffffc0207818:	4a468693          	addi	a3,a3,1188 # ffffffffc020dcb8 <etext+0x23e2>
ffffffffc020781c:	00004617          	auipc	a2,0x4
ffffffffc0207820:	57460613          	addi	a2,a2,1396 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207824:	0b600593          	li	a1,182
ffffffffc0207828:	00006517          	auipc	a0,0x6
ffffffffc020782c:	3e850513          	addi	a0,a0,1000 # ffffffffc020dc10 <etext+0x233a>
ffffffffc0207830:	9fdf80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207834:	00006697          	auipc	a3,0x6
ffffffffc0207838:	46c68693          	addi	a3,a3,1132 # ffffffffc020dca0 <etext+0x23ca>
ffffffffc020783c:	00004617          	auipc	a2,0x4
ffffffffc0207840:	55460613          	addi	a2,a2,1364 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207844:	0ae00593          	li	a1,174
ffffffffc0207848:	00006517          	auipc	a0,0x6
ffffffffc020784c:	3c850513          	addi	a0,a0,968 # ffffffffc020dc10 <etext+0x233a>
ffffffffc0207850:	ec26                	sd	s1,24(sp)
ffffffffc0207852:	e84a                	sd	s2,16(sp)
ffffffffc0207854:	9d9f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207858 <RR_init>:
ffffffffc0207858:	e508                	sd	a0,8(a0)
ffffffffc020785a:	e108                	sd	a0,0(a0)
ffffffffc020785c:	00052823          	sw	zero,16(a0)
ffffffffc0207860:	00053c23          	sd	zero,24(a0)
ffffffffc0207864:	8082                	ret

ffffffffc0207866 <RR_pick_next>:
ffffffffc0207866:	651c                	ld	a5,8(a0)
ffffffffc0207868:	00f50563          	beq	a0,a5,ffffffffc0207872 <RR_pick_next+0xc>
ffffffffc020786c:	ef078513          	addi	a0,a5,-272
ffffffffc0207870:	8082                	ret
ffffffffc0207872:	4501                	li	a0,0
ffffffffc0207874:	8082                	ret

ffffffffc0207876 <RR_proc_tick>:
ffffffffc0207876:	1205a783          	lw	a5,288(a1)
ffffffffc020787a:	00f05563          	blez	a5,ffffffffc0207884 <RR_proc_tick+0xe>
ffffffffc020787e:	37fd                	addiw	a5,a5,-1
ffffffffc0207880:	12f5a023          	sw	a5,288(a1)
ffffffffc0207884:	e399                	bnez	a5,ffffffffc020788a <RR_proc_tick+0x14>
ffffffffc0207886:	4785                	li	a5,1
ffffffffc0207888:	ed9c                	sd	a5,24(a1)
ffffffffc020788a:	8082                	ret

ffffffffc020788c <RR_dequeue>:
ffffffffc020788c:	1185b703          	ld	a4,280(a1)
ffffffffc0207890:	11058793          	addi	a5,a1,272
ffffffffc0207894:	02e78263          	beq	a5,a4,ffffffffc02078b8 <RR_dequeue+0x2c>
ffffffffc0207898:	1085b683          	ld	a3,264(a1)
ffffffffc020789c:	00a69e63          	bne	a3,a0,ffffffffc02078b8 <RR_dequeue+0x2c>
ffffffffc02078a0:	1105b503          	ld	a0,272(a1)
ffffffffc02078a4:	4a90                	lw	a2,16(a3)
ffffffffc02078a6:	e518                	sd	a4,8(a0)
ffffffffc02078a8:	e308                	sd	a0,0(a4)
ffffffffc02078aa:	10f5bc23          	sd	a5,280(a1)
ffffffffc02078ae:	10f5b823          	sd	a5,272(a1)
ffffffffc02078b2:	367d                	addiw	a2,a2,-1
ffffffffc02078b4:	ca90                	sw	a2,16(a3)
ffffffffc02078b6:	8082                	ret
ffffffffc02078b8:	1141                	addi	sp,sp,-16
ffffffffc02078ba:	00006697          	auipc	a3,0x6
ffffffffc02078be:	44668693          	addi	a3,a3,1094 # ffffffffc020dd00 <etext+0x242a>
ffffffffc02078c2:	00004617          	auipc	a2,0x4
ffffffffc02078c6:	4ce60613          	addi	a2,a2,1230 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02078ca:	03d00593          	li	a1,61
ffffffffc02078ce:	00006517          	auipc	a0,0x6
ffffffffc02078d2:	46a50513          	addi	a0,a0,1130 # ffffffffc020dd38 <etext+0x2462>
ffffffffc02078d6:	e406                	sd	ra,8(sp)
ffffffffc02078d8:	955f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc02078dc <RR_enqueue>:
ffffffffc02078dc:	1185b703          	ld	a4,280(a1)
ffffffffc02078e0:	11058793          	addi	a5,a1,272
ffffffffc02078e4:	02e79d63          	bne	a5,a4,ffffffffc020791e <RR_enqueue+0x42>
ffffffffc02078e8:	6118                	ld	a4,0(a0)
ffffffffc02078ea:	1205a683          	lw	a3,288(a1)
ffffffffc02078ee:	e11c                	sd	a5,0(a0)
ffffffffc02078f0:	e71c                	sd	a5,8(a4)
ffffffffc02078f2:	10e5b823          	sd	a4,272(a1)
ffffffffc02078f6:	10a5bc23          	sd	a0,280(a1)
ffffffffc02078fa:	495c                	lw	a5,20(a0)
ffffffffc02078fc:	ea89                	bnez	a3,ffffffffc020790e <RR_enqueue+0x32>
ffffffffc02078fe:	12f5a023          	sw	a5,288(a1)
ffffffffc0207902:	491c                	lw	a5,16(a0)
ffffffffc0207904:	10a5b423          	sd	a0,264(a1)
ffffffffc0207908:	2785                	addiw	a5,a5,1
ffffffffc020790a:	c91c                	sw	a5,16(a0)
ffffffffc020790c:	8082                	ret
ffffffffc020790e:	fed7c8e3          	blt	a5,a3,ffffffffc02078fe <RR_enqueue+0x22>
ffffffffc0207912:	491c                	lw	a5,16(a0)
ffffffffc0207914:	10a5b423          	sd	a0,264(a1)
ffffffffc0207918:	2785                	addiw	a5,a5,1
ffffffffc020791a:	c91c                	sw	a5,16(a0)
ffffffffc020791c:	8082                	ret
ffffffffc020791e:	1141                	addi	sp,sp,-16
ffffffffc0207920:	00006697          	auipc	a3,0x6
ffffffffc0207924:	43868693          	addi	a3,a3,1080 # ffffffffc020dd58 <etext+0x2482>
ffffffffc0207928:	00004617          	auipc	a2,0x4
ffffffffc020792c:	46860613          	addi	a2,a2,1128 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207930:	02900593          	li	a1,41
ffffffffc0207934:	00006517          	auipc	a0,0x6
ffffffffc0207938:	40450513          	addi	a0,a0,1028 # ffffffffc020dd38 <etext+0x2462>
ffffffffc020793c:	e406                	sd	ra,8(sp)
ffffffffc020793e:	8eff80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207942 <sys_getpid>:
ffffffffc0207942:	0008f797          	auipc	a5,0x8f
ffffffffc0207946:	f867b783          	ld	a5,-122(a5) # ffffffffc02968c8 <current>
ffffffffc020794a:	43c8                	lw	a0,4(a5)
ffffffffc020794c:	8082                	ret

ffffffffc020794e <sys_pgdir>:
ffffffffc020794e:	4501                	li	a0,0
ffffffffc0207950:	8082                	ret

ffffffffc0207952 <sys_gettime>:
ffffffffc0207952:	0008f797          	auipc	a5,0x8f
ffffffffc0207956:	f2e7b783          	ld	a5,-210(a5) # ffffffffc0296880 <ticks>
ffffffffc020795a:	0027951b          	slliw	a0,a5,0x2
ffffffffc020795e:	9d3d                	addw	a0,a0,a5
ffffffffc0207960:	0015151b          	slliw	a0,a0,0x1
ffffffffc0207964:	8082                	ret

ffffffffc0207966 <sys_lab6_set_priority>:
ffffffffc0207966:	4108                	lw	a0,0(a0)
ffffffffc0207968:	1141                	addi	sp,sp,-16
ffffffffc020796a:	e406                	sd	ra,8(sp)
ffffffffc020796c:	967ff0ef          	jal	ffffffffc02072d2 <lab6_set_priority>
ffffffffc0207970:	60a2                	ld	ra,8(sp)
ffffffffc0207972:	4501                	li	a0,0
ffffffffc0207974:	0141                	addi	sp,sp,16
ffffffffc0207976:	8082                	ret

ffffffffc0207978 <sys_dup>:
ffffffffc0207978:	450c                	lw	a1,8(a0)
ffffffffc020797a:	4108                	lw	a0,0(a0)
ffffffffc020797c:	c08fd06f          	j	ffffffffc0204d84 <sysfile_dup>

ffffffffc0207980 <sys_getdirentry>:
ffffffffc0207980:	650c                	ld	a1,8(a0)
ffffffffc0207982:	4108                	lw	a0,0(a0)
ffffffffc0207984:	b10fd06f          	j	ffffffffc0204c94 <sysfile_getdirentry>

ffffffffc0207988 <sys_getcwd>:
ffffffffc0207988:	650c                	ld	a1,8(a0)
ffffffffc020798a:	6108                	ld	a0,0(a0)
ffffffffc020798c:	a5efd06f          	j	ffffffffc0204bea <sysfile_getcwd>

ffffffffc0207990 <sys_fsync>:
ffffffffc0207990:	4108                	lw	a0,0(a0)
ffffffffc0207992:	a54fd06f          	j	ffffffffc0204be6 <sysfile_fsync>

ffffffffc0207996 <sys_fstat>:
ffffffffc0207996:	650c                	ld	a1,8(a0)
ffffffffc0207998:	4108                	lw	a0,0(a0)
ffffffffc020799a:	9c4fd06f          	j	ffffffffc0204b5e <sysfile_fstat>

ffffffffc020799e <sys_seek>:
ffffffffc020799e:	4910                	lw	a2,16(a0)
ffffffffc02079a0:	650c                	ld	a1,8(a0)
ffffffffc02079a2:	4108                	lw	a0,0(a0)
ffffffffc02079a4:	9b6fd06f          	j	ffffffffc0204b5a <sysfile_seek>

ffffffffc02079a8 <sys_write>:
ffffffffc02079a8:	6910                	ld	a2,16(a0)
ffffffffc02079aa:	650c                	ld	a1,8(a0)
ffffffffc02079ac:	4108                	lw	a0,0(a0)
ffffffffc02079ae:	87afd06f          	j	ffffffffc0204a28 <sysfile_write>

ffffffffc02079b2 <sys_read>:
ffffffffc02079b2:	6910                	ld	a2,16(a0)
ffffffffc02079b4:	650c                	ld	a1,8(a0)
ffffffffc02079b6:	4108                	lw	a0,0(a0)
ffffffffc02079b8:	f25fc06f          	j	ffffffffc02048dc <sysfile_read>

ffffffffc02079bc <sys_close>:
ffffffffc02079bc:	4108                	lw	a0,0(a0)
ffffffffc02079be:	f1bfc06f          	j	ffffffffc02048d8 <sysfile_close>

ffffffffc02079c2 <sys_open>:
ffffffffc02079c2:	450c                	lw	a1,8(a0)
ffffffffc02079c4:	6108                	ld	a0,0(a0)
ffffffffc02079c6:	eddfc06f          	j	ffffffffc02048a2 <sysfile_open>

ffffffffc02079ca <sys_putc>:
ffffffffc02079ca:	4108                	lw	a0,0(a0)
ffffffffc02079cc:	1141                	addi	sp,sp,-16
ffffffffc02079ce:	e406                	sd	ra,8(sp)
ffffffffc02079d0:	f92f80ef          	jal	ffffffffc0200162 <cputchar>
ffffffffc02079d4:	60a2                	ld	ra,8(sp)
ffffffffc02079d6:	4501                	li	a0,0
ffffffffc02079d8:	0141                	addi	sp,sp,16
ffffffffc02079da:	8082                	ret

ffffffffc02079dc <sys_kill>:
ffffffffc02079dc:	4108                	lw	a0,0(a0)
ffffffffc02079de:	e8eff06f          	j	ffffffffc020706c <do_kill>

ffffffffc02079e2 <sys_sleep>:
ffffffffc02079e2:	4108                	lw	a0,0(a0)
ffffffffc02079e4:	91dff06f          	j	ffffffffc0207300 <do_sleep>

ffffffffc02079e8 <sys_yield>:
ffffffffc02079e8:	e3aff06f          	j	ffffffffc0207022 <do_yield>

ffffffffc02079ec <sys_exec>:
ffffffffc02079ec:	6910                	ld	a2,16(a0)
ffffffffc02079ee:	450c                	lw	a1,8(a0)
ffffffffc02079f0:	6108                	ld	a0,0(a0)
ffffffffc02079f2:	c3dfe06f          	j	ffffffffc020662e <do_execve>

ffffffffc02079f6 <sys_wait>:
ffffffffc02079f6:	650c                	ld	a1,8(a0)
ffffffffc02079f8:	4108                	lw	a0,0(a0)
ffffffffc02079fa:	e38ff06f          	j	ffffffffc0207032 <do_wait>

ffffffffc02079fe <sys_fork>:
ffffffffc02079fe:	0008f797          	auipc	a5,0x8f
ffffffffc0207a02:	eca7b783          	ld	a5,-310(a5) # ffffffffc02968c8 <current>
ffffffffc0207a06:	4501                	li	a0,0
ffffffffc0207a08:	73d0                	ld	a2,160(a5)
ffffffffc0207a0a:	6a0c                	ld	a1,16(a2)
ffffffffc0207a0c:	b32fe06f          	j	ffffffffc0205d3e <do_fork>

ffffffffc0207a10 <sys_exit>:
ffffffffc0207a10:	4108                	lw	a0,0(a0)
ffffffffc0207a12:	f8afe06f          	j	ffffffffc020619c <do_exit>

ffffffffc0207a16 <syscall>:
ffffffffc0207a16:	0008f697          	auipc	a3,0x8f
ffffffffc0207a1a:	eb26b683          	ld	a3,-334(a3) # ffffffffc02968c8 <current>
ffffffffc0207a1e:	715d                	addi	sp,sp,-80
ffffffffc0207a20:	e0a2                	sd	s0,64(sp)
ffffffffc0207a22:	72c0                	ld	s0,160(a3)
ffffffffc0207a24:	e486                	sd	ra,72(sp)
ffffffffc0207a26:	0ff00793          	li	a5,255
ffffffffc0207a2a:	4834                	lw	a3,80(s0)
ffffffffc0207a2c:	02d7ec63          	bltu	a5,a3,ffffffffc0207a64 <syscall+0x4e>
ffffffffc0207a30:	00007797          	auipc	a5,0x7
ffffffffc0207a34:	5e078793          	addi	a5,a5,1504 # ffffffffc020f010 <syscalls>
ffffffffc0207a38:	00369613          	slli	a2,a3,0x3
ffffffffc0207a3c:	97b2                	add	a5,a5,a2
ffffffffc0207a3e:	639c                	ld	a5,0(a5)
ffffffffc0207a40:	c395                	beqz	a5,ffffffffc0207a64 <syscall+0x4e>
ffffffffc0207a42:	7028                	ld	a0,96(s0)
ffffffffc0207a44:	742c                	ld	a1,104(s0)
ffffffffc0207a46:	7830                	ld	a2,112(s0)
ffffffffc0207a48:	7c34                	ld	a3,120(s0)
ffffffffc0207a4a:	6c38                	ld	a4,88(s0)
ffffffffc0207a4c:	f02a                	sd	a0,32(sp)
ffffffffc0207a4e:	f42e                	sd	a1,40(sp)
ffffffffc0207a50:	f832                	sd	a2,48(sp)
ffffffffc0207a52:	fc36                	sd	a3,56(sp)
ffffffffc0207a54:	ec3a                	sd	a4,24(sp)
ffffffffc0207a56:	0828                	addi	a0,sp,24
ffffffffc0207a58:	9782                	jalr	a5
ffffffffc0207a5a:	60a6                	ld	ra,72(sp)
ffffffffc0207a5c:	e828                	sd	a0,80(s0)
ffffffffc0207a5e:	6406                	ld	s0,64(sp)
ffffffffc0207a60:	6161                	addi	sp,sp,80
ffffffffc0207a62:	8082                	ret
ffffffffc0207a64:	8522                	mv	a0,s0
ffffffffc0207a66:	e436                	sd	a3,8(sp)
ffffffffc0207a68:	c88f90ef          	jal	ffffffffc0200ef0 <print_trapframe>
ffffffffc0207a6c:	0008f797          	auipc	a5,0x8f
ffffffffc0207a70:	e5c7b783          	ld	a5,-420(a5) # ffffffffc02968c8 <current>
ffffffffc0207a74:	66a2                	ld	a3,8(sp)
ffffffffc0207a76:	00006617          	auipc	a2,0x6
ffffffffc0207a7a:	31260613          	addi	a2,a2,786 # ffffffffc020dd88 <etext+0x24b2>
ffffffffc0207a7e:	43d8                	lw	a4,4(a5)
ffffffffc0207a80:	0d800593          	li	a1,216
ffffffffc0207a84:	0b478793          	addi	a5,a5,180
ffffffffc0207a88:	00006517          	auipc	a0,0x6
ffffffffc0207a8c:	33050513          	addi	a0,a0,816 # ffffffffc020ddb8 <etext+0x24e2>
ffffffffc0207a90:	f9cf80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207a94 <vfs_do_add>:
ffffffffc0207a94:	7139                	addi	sp,sp,-64
ffffffffc0207a96:	fc06                	sd	ra,56(sp)
ffffffffc0207a98:	f822                	sd	s0,48(sp)
ffffffffc0207a9a:	e852                	sd	s4,16(sp)
ffffffffc0207a9c:	e456                	sd	s5,8(sp)
ffffffffc0207a9e:	e05a                	sd	s6,0(sp)
ffffffffc0207aa0:	10050f63          	beqz	a0,ffffffffc0207bbe <vfs_do_add+0x12a>
ffffffffc0207aa4:	00d5e7b3          	or	a5,a1,a3
ffffffffc0207aa8:	842a                	mv	s0,a0
ffffffffc0207aaa:	8a2e                	mv	s4,a1
ffffffffc0207aac:	8b32                	mv	s6,a2
ffffffffc0207aae:	8ab6                	mv	s5,a3
ffffffffc0207ab0:	cb89                	beqz	a5,ffffffffc0207ac2 <vfs_do_add+0x2e>
ffffffffc0207ab2:	0e058363          	beqz	a1,ffffffffc0207b98 <vfs_do_add+0x104>
ffffffffc0207ab6:	4db8                	lw	a4,88(a1)
ffffffffc0207ab8:	6785                	lui	a5,0x1
ffffffffc0207aba:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207abe:	0cf71d63          	bne	a4,a5,ffffffffc0207b98 <vfs_do_add+0x104>
ffffffffc0207ac2:	8522                	mv	a0,s0
ffffffffc0207ac4:	06f030ef          	jal	ffffffffc020b332 <strlen>
ffffffffc0207ac8:	47fd                	li	a5,31
ffffffffc0207aca:	0ca7e263          	bltu	a5,a0,ffffffffc0207b8e <vfs_do_add+0xfa>
ffffffffc0207ace:	8522                	mv	a0,s0
ffffffffc0207ad0:	f426                	sd	s1,40(sp)
ffffffffc0207ad2:	de0f80ef          	jal	ffffffffc02000b2 <strdup>
ffffffffc0207ad6:	84aa                	mv	s1,a0
ffffffffc0207ad8:	cd4d                	beqz	a0,ffffffffc0207b92 <vfs_do_add+0xfe>
ffffffffc0207ada:	03000513          	li	a0,48
ffffffffc0207ade:	ec4e                	sd	s3,24(sp)
ffffffffc0207ae0:	a5cfa0ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0207ae4:	89aa                	mv	s3,a0
ffffffffc0207ae6:	c935                	beqz	a0,ffffffffc0207b5a <vfs_do_add+0xc6>
ffffffffc0207ae8:	f04a                	sd	s2,32(sp)
ffffffffc0207aea:	0008e517          	auipc	a0,0x8e
ffffffffc0207aee:	d1650513          	addi	a0,a0,-746 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207af2:	0008e917          	auipc	s2,0x8e
ffffffffc0207af6:	d2690913          	addi	s2,s2,-730 # ffffffffc0295818 <vdev_list>
ffffffffc0207afa:	cdffc0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0207afe:	844a                	mv	s0,s2
ffffffffc0207b00:	a039                	j	ffffffffc0207b0e <vfs_do_add+0x7a>
ffffffffc0207b02:	fe043503          	ld	a0,-32(s0)
ffffffffc0207b06:	85a6                	mv	a1,s1
ffffffffc0207b08:	071030ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc0207b0c:	c52d                	beqz	a0,ffffffffc0207b76 <vfs_do_add+0xe2>
ffffffffc0207b0e:	6400                	ld	s0,8(s0)
ffffffffc0207b10:	ff2419e3          	bne	s0,s2,ffffffffc0207b02 <vfs_do_add+0x6e>
ffffffffc0207b14:	6418                	ld	a4,8(s0)
ffffffffc0207b16:	02098793          	addi	a5,s3,32
ffffffffc0207b1a:	0099b023          	sd	s1,0(s3)
ffffffffc0207b1e:	0149b423          	sd	s4,8(s3)
ffffffffc0207b22:	0159bc23          	sd	s5,24(s3)
ffffffffc0207b26:	0169b823          	sd	s6,16(s3)
ffffffffc0207b2a:	e31c                	sd	a5,0(a4)
ffffffffc0207b2c:	0289b023          	sd	s0,32(s3)
ffffffffc0207b30:	02e9b423          	sd	a4,40(s3)
ffffffffc0207b34:	0008e517          	auipc	a0,0x8e
ffffffffc0207b38:	ccc50513          	addi	a0,a0,-820 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207b3c:	e41c                	sd	a5,8(s0)
ffffffffc0207b3e:	c97fc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0207b42:	74a2                	ld	s1,40(sp)
ffffffffc0207b44:	7902                	ld	s2,32(sp)
ffffffffc0207b46:	69e2                	ld	s3,24(sp)
ffffffffc0207b48:	4401                	li	s0,0
ffffffffc0207b4a:	70e2                	ld	ra,56(sp)
ffffffffc0207b4c:	8522                	mv	a0,s0
ffffffffc0207b4e:	7442                	ld	s0,48(sp)
ffffffffc0207b50:	6a42                	ld	s4,16(sp)
ffffffffc0207b52:	6aa2                	ld	s5,8(sp)
ffffffffc0207b54:	6b02                	ld	s6,0(sp)
ffffffffc0207b56:	6121                	addi	sp,sp,64
ffffffffc0207b58:	8082                	ret
ffffffffc0207b5a:	5471                	li	s0,-4
ffffffffc0207b5c:	8526                	mv	a0,s1
ffffffffc0207b5e:	a84fa0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0207b62:	70e2                	ld	ra,56(sp)
ffffffffc0207b64:	8522                	mv	a0,s0
ffffffffc0207b66:	7442                	ld	s0,48(sp)
ffffffffc0207b68:	74a2                	ld	s1,40(sp)
ffffffffc0207b6a:	69e2                	ld	s3,24(sp)
ffffffffc0207b6c:	6a42                	ld	s4,16(sp)
ffffffffc0207b6e:	6aa2                	ld	s5,8(sp)
ffffffffc0207b70:	6b02                	ld	s6,0(sp)
ffffffffc0207b72:	6121                	addi	sp,sp,64
ffffffffc0207b74:	8082                	ret
ffffffffc0207b76:	0008e517          	auipc	a0,0x8e
ffffffffc0207b7a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207b7e:	c57fc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0207b82:	854e                	mv	a0,s3
ffffffffc0207b84:	a5efa0ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0207b88:	5425                	li	s0,-23
ffffffffc0207b8a:	7902                	ld	s2,32(sp)
ffffffffc0207b8c:	bfc1                	j	ffffffffc0207b5c <vfs_do_add+0xc8>
ffffffffc0207b8e:	5451                	li	s0,-12
ffffffffc0207b90:	bf6d                	j	ffffffffc0207b4a <vfs_do_add+0xb6>
ffffffffc0207b92:	74a2                	ld	s1,40(sp)
ffffffffc0207b94:	5471                	li	s0,-4
ffffffffc0207b96:	bf55                	j	ffffffffc0207b4a <vfs_do_add+0xb6>
ffffffffc0207b98:	00006697          	auipc	a3,0x6
ffffffffc0207b9c:	26068693          	addi	a3,a3,608 # ffffffffc020ddf8 <etext+0x2522>
ffffffffc0207ba0:	00004617          	auipc	a2,0x4
ffffffffc0207ba4:	1f060613          	addi	a2,a2,496 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207ba8:	08f00593          	li	a1,143
ffffffffc0207bac:	00006517          	auipc	a0,0x6
ffffffffc0207bb0:	23450513          	addi	a0,a0,564 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207bb4:	f426                	sd	s1,40(sp)
ffffffffc0207bb6:	f04a                	sd	s2,32(sp)
ffffffffc0207bb8:	ec4e                	sd	s3,24(sp)
ffffffffc0207bba:	e72f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207bbe:	00006697          	auipc	a3,0x6
ffffffffc0207bc2:	21268693          	addi	a3,a3,530 # ffffffffc020ddd0 <etext+0x24fa>
ffffffffc0207bc6:	00004617          	auipc	a2,0x4
ffffffffc0207bca:	1ca60613          	addi	a2,a2,458 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207bce:	08e00593          	li	a1,142
ffffffffc0207bd2:	00006517          	auipc	a0,0x6
ffffffffc0207bd6:	20e50513          	addi	a0,a0,526 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207bda:	f426                	sd	s1,40(sp)
ffffffffc0207bdc:	f04a                	sd	s2,32(sp)
ffffffffc0207bde:	ec4e                	sd	s3,24(sp)
ffffffffc0207be0:	e4cf80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207be4 <find_mount.part.0>:
ffffffffc0207be4:	1141                	addi	sp,sp,-16
ffffffffc0207be6:	00006697          	auipc	a3,0x6
ffffffffc0207bea:	1ea68693          	addi	a3,a3,490 # ffffffffc020ddd0 <etext+0x24fa>
ffffffffc0207bee:	00004617          	auipc	a2,0x4
ffffffffc0207bf2:	1a260613          	addi	a2,a2,418 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207bf6:	0cd00593          	li	a1,205
ffffffffc0207bfa:	00006517          	auipc	a0,0x6
ffffffffc0207bfe:	1e650513          	addi	a0,a0,486 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207c02:	e406                	sd	ra,8(sp)
ffffffffc0207c04:	e28f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207c08 <vfs_devlist_init>:
ffffffffc0207c08:	0008e797          	auipc	a5,0x8e
ffffffffc0207c0c:	c1078793          	addi	a5,a5,-1008 # ffffffffc0295818 <vdev_list>
ffffffffc0207c10:	4585                	li	a1,1
ffffffffc0207c12:	0008e517          	auipc	a0,0x8e
ffffffffc0207c16:	bee50513          	addi	a0,a0,-1042 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207c1a:	e79c                	sd	a5,8(a5)
ffffffffc0207c1c:	e39c                	sd	a5,0(a5)
ffffffffc0207c1e:	baffc06f          	j	ffffffffc02047cc <sem_init>

ffffffffc0207c22 <vfs_cleanup>:
ffffffffc0207c22:	1101                	addi	sp,sp,-32
ffffffffc0207c24:	e426                	sd	s1,8(sp)
ffffffffc0207c26:	0008e497          	auipc	s1,0x8e
ffffffffc0207c2a:	bf248493          	addi	s1,s1,-1038 # ffffffffc0295818 <vdev_list>
ffffffffc0207c2e:	649c                	ld	a5,8(s1)
ffffffffc0207c30:	ec06                	sd	ra,24(sp)
ffffffffc0207c32:	02978f63          	beq	a5,s1,ffffffffc0207c70 <vfs_cleanup+0x4e>
ffffffffc0207c36:	0008e517          	auipc	a0,0x8e
ffffffffc0207c3a:	bca50513          	addi	a0,a0,-1078 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207c3e:	e822                	sd	s0,16(sp)
ffffffffc0207c40:	b99fc0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0207c44:	6480                	ld	s0,8(s1)
ffffffffc0207c46:	00940b63          	beq	s0,s1,ffffffffc0207c5c <vfs_cleanup+0x3a>
ffffffffc0207c4a:	ff043783          	ld	a5,-16(s0)
ffffffffc0207c4e:	853e                	mv	a0,a5
ffffffffc0207c50:	c399                	beqz	a5,ffffffffc0207c56 <vfs_cleanup+0x34>
ffffffffc0207c52:	6bfc                	ld	a5,208(a5)
ffffffffc0207c54:	9782                	jalr	a5
ffffffffc0207c56:	6400                	ld	s0,8(s0)
ffffffffc0207c58:	fe9419e3          	bne	s0,s1,ffffffffc0207c4a <vfs_cleanup+0x28>
ffffffffc0207c5c:	6442                	ld	s0,16(sp)
ffffffffc0207c5e:	60e2                	ld	ra,24(sp)
ffffffffc0207c60:	64a2                	ld	s1,8(sp)
ffffffffc0207c62:	0008e517          	auipc	a0,0x8e
ffffffffc0207c66:	b9e50513          	addi	a0,a0,-1122 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207c6a:	6105                	addi	sp,sp,32
ffffffffc0207c6c:	b69fc06f          	j	ffffffffc02047d4 <up>
ffffffffc0207c70:	60e2                	ld	ra,24(sp)
ffffffffc0207c72:	64a2                	ld	s1,8(sp)
ffffffffc0207c74:	6105                	addi	sp,sp,32
ffffffffc0207c76:	8082                	ret

ffffffffc0207c78 <vfs_get_root>:
ffffffffc0207c78:	7179                	addi	sp,sp,-48
ffffffffc0207c7a:	f406                	sd	ra,40(sp)
ffffffffc0207c7c:	c949                	beqz	a0,ffffffffc0207d0e <vfs_get_root+0x96>
ffffffffc0207c7e:	e84a                	sd	s2,16(sp)
ffffffffc0207c80:	0008e917          	auipc	s2,0x8e
ffffffffc0207c84:	b9890913          	addi	s2,s2,-1128 # ffffffffc0295818 <vdev_list>
ffffffffc0207c88:	00893783          	ld	a5,8(s2)
ffffffffc0207c8c:	ec26                	sd	s1,24(sp)
ffffffffc0207c8e:	07278e63          	beq	a5,s2,ffffffffc0207d0a <vfs_get_root+0x92>
ffffffffc0207c92:	e44e                	sd	s3,8(sp)
ffffffffc0207c94:	89aa                	mv	s3,a0
ffffffffc0207c96:	0008e517          	auipc	a0,0x8e
ffffffffc0207c9a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207c9e:	f022                	sd	s0,32(sp)
ffffffffc0207ca0:	e052                	sd	s4,0(sp)
ffffffffc0207ca2:	844a                	mv	s0,s2
ffffffffc0207ca4:	8a2e                	mv	s4,a1
ffffffffc0207ca6:	b33fc0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0207caa:	a801                	j	ffffffffc0207cba <vfs_get_root+0x42>
ffffffffc0207cac:	fe043583          	ld	a1,-32(s0)
ffffffffc0207cb0:	854e                	mv	a0,s3
ffffffffc0207cb2:	6c6030ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc0207cb6:	84aa                	mv	s1,a0
ffffffffc0207cb8:	c505                	beqz	a0,ffffffffc0207ce0 <vfs_get_root+0x68>
ffffffffc0207cba:	6400                	ld	s0,8(s0)
ffffffffc0207cbc:	ff2418e3          	bne	s0,s2,ffffffffc0207cac <vfs_get_root+0x34>
ffffffffc0207cc0:	54cd                	li	s1,-13
ffffffffc0207cc2:	0008e517          	auipc	a0,0x8e
ffffffffc0207cc6:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207cca:	b0bfc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0207cce:	7402                	ld	s0,32(sp)
ffffffffc0207cd0:	69a2                	ld	s3,8(sp)
ffffffffc0207cd2:	6a02                	ld	s4,0(sp)
ffffffffc0207cd4:	70a2                	ld	ra,40(sp)
ffffffffc0207cd6:	6942                	ld	s2,16(sp)
ffffffffc0207cd8:	8526                	mv	a0,s1
ffffffffc0207cda:	64e2                	ld	s1,24(sp)
ffffffffc0207cdc:	6145                	addi	sp,sp,48
ffffffffc0207cde:	8082                	ret
ffffffffc0207ce0:	ff043503          	ld	a0,-16(s0)
ffffffffc0207ce4:	c519                	beqz	a0,ffffffffc0207cf2 <vfs_get_root+0x7a>
ffffffffc0207ce6:	617c                	ld	a5,192(a0)
ffffffffc0207ce8:	9782                	jalr	a5
ffffffffc0207cea:	c519                	beqz	a0,ffffffffc0207cf8 <vfs_get_root+0x80>
ffffffffc0207cec:	00aa3023          	sd	a0,0(s4)
ffffffffc0207cf0:	bfc9                	j	ffffffffc0207cc2 <vfs_get_root+0x4a>
ffffffffc0207cf2:	ff843783          	ld	a5,-8(s0)
ffffffffc0207cf6:	c399                	beqz	a5,ffffffffc0207cfc <vfs_get_root+0x84>
ffffffffc0207cf8:	54c9                	li	s1,-14
ffffffffc0207cfa:	b7e1                	j	ffffffffc0207cc2 <vfs_get_root+0x4a>
ffffffffc0207cfc:	fe843503          	ld	a0,-24(s0)
ffffffffc0207d00:	5d6000ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0207d04:	fe843503          	ld	a0,-24(s0)
ffffffffc0207d08:	b7cd                	j	ffffffffc0207cea <vfs_get_root+0x72>
ffffffffc0207d0a:	54cd                	li	s1,-13
ffffffffc0207d0c:	b7e1                	j	ffffffffc0207cd4 <vfs_get_root+0x5c>
ffffffffc0207d0e:	00006697          	auipc	a3,0x6
ffffffffc0207d12:	0c268693          	addi	a3,a3,194 # ffffffffc020ddd0 <etext+0x24fa>
ffffffffc0207d16:	00004617          	auipc	a2,0x4
ffffffffc0207d1a:	07a60613          	addi	a2,a2,122 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207d1e:	04500593          	li	a1,69
ffffffffc0207d22:	00006517          	auipc	a0,0x6
ffffffffc0207d26:	0be50513          	addi	a0,a0,190 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207d2a:	f022                	sd	s0,32(sp)
ffffffffc0207d2c:	ec26                	sd	s1,24(sp)
ffffffffc0207d2e:	e84a                	sd	s2,16(sp)
ffffffffc0207d30:	e44e                	sd	s3,8(sp)
ffffffffc0207d32:	e052                	sd	s4,0(sp)
ffffffffc0207d34:	cf8f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207d38 <vfs_get_devname>:
ffffffffc0207d38:	0008e697          	auipc	a3,0x8e
ffffffffc0207d3c:	ae068693          	addi	a3,a3,-1312 # ffffffffc0295818 <vdev_list>
ffffffffc0207d40:	87b6                	mv	a5,a3
ffffffffc0207d42:	e511                	bnez	a0,ffffffffc0207d4e <vfs_get_devname+0x16>
ffffffffc0207d44:	a829                	j	ffffffffc0207d5e <vfs_get_devname+0x26>
ffffffffc0207d46:	ff07b703          	ld	a4,-16(a5)
ffffffffc0207d4a:	00a70763          	beq	a4,a0,ffffffffc0207d58 <vfs_get_devname+0x20>
ffffffffc0207d4e:	679c                	ld	a5,8(a5)
ffffffffc0207d50:	fed79be3          	bne	a5,a3,ffffffffc0207d46 <vfs_get_devname+0xe>
ffffffffc0207d54:	4501                	li	a0,0
ffffffffc0207d56:	8082                	ret
ffffffffc0207d58:	fe07b503          	ld	a0,-32(a5)
ffffffffc0207d5c:	8082                	ret
ffffffffc0207d5e:	1141                	addi	sp,sp,-16
ffffffffc0207d60:	00006697          	auipc	a3,0x6
ffffffffc0207d64:	0f868693          	addi	a3,a3,248 # ffffffffc020de58 <etext+0x2582>
ffffffffc0207d68:	00004617          	auipc	a2,0x4
ffffffffc0207d6c:	02860613          	addi	a2,a2,40 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207d70:	06a00593          	li	a1,106
ffffffffc0207d74:	00006517          	auipc	a0,0x6
ffffffffc0207d78:	06c50513          	addi	a0,a0,108 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207d7c:	e406                	sd	ra,8(sp)
ffffffffc0207d7e:	caef80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207d82 <vfs_add_dev>:
ffffffffc0207d82:	86b2                	mv	a3,a2
ffffffffc0207d84:	4601                	li	a2,0
ffffffffc0207d86:	d0fff06f          	j	ffffffffc0207a94 <vfs_do_add>

ffffffffc0207d8a <vfs_mount>:
ffffffffc0207d8a:	7179                	addi	sp,sp,-48
ffffffffc0207d8c:	e84a                	sd	s2,16(sp)
ffffffffc0207d8e:	892a                	mv	s2,a0
ffffffffc0207d90:	0008e517          	auipc	a0,0x8e
ffffffffc0207d94:	a7050513          	addi	a0,a0,-1424 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207d98:	e44e                	sd	s3,8(sp)
ffffffffc0207d9a:	f406                	sd	ra,40(sp)
ffffffffc0207d9c:	f022                	sd	s0,32(sp)
ffffffffc0207d9e:	ec26                	sd	s1,24(sp)
ffffffffc0207da0:	89ae                	mv	s3,a1
ffffffffc0207da2:	a37fc0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0207da6:	0c090a63          	beqz	s2,ffffffffc0207e7a <vfs_mount+0xf0>
ffffffffc0207daa:	0008e497          	auipc	s1,0x8e
ffffffffc0207dae:	a6e48493          	addi	s1,s1,-1426 # ffffffffc0295818 <vdev_list>
ffffffffc0207db2:	6480                	ld	s0,8(s1)
ffffffffc0207db4:	00941663          	bne	s0,s1,ffffffffc0207dc0 <vfs_mount+0x36>
ffffffffc0207db8:	a8ad                	j	ffffffffc0207e32 <vfs_mount+0xa8>
ffffffffc0207dba:	6400                	ld	s0,8(s0)
ffffffffc0207dbc:	06940b63          	beq	s0,s1,ffffffffc0207e32 <vfs_mount+0xa8>
ffffffffc0207dc0:	ff843783          	ld	a5,-8(s0)
ffffffffc0207dc4:	dbfd                	beqz	a5,ffffffffc0207dba <vfs_mount+0x30>
ffffffffc0207dc6:	fe043503          	ld	a0,-32(s0)
ffffffffc0207dca:	85ca                	mv	a1,s2
ffffffffc0207dcc:	5ac030ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc0207dd0:	f56d                	bnez	a0,ffffffffc0207dba <vfs_mount+0x30>
ffffffffc0207dd2:	ff043783          	ld	a5,-16(s0)
ffffffffc0207dd6:	e3a5                	bnez	a5,ffffffffc0207e36 <vfs_mount+0xac>
ffffffffc0207dd8:	fe043783          	ld	a5,-32(s0)
ffffffffc0207ddc:	cfbd                	beqz	a5,ffffffffc0207e5a <vfs_mount+0xd0>
ffffffffc0207dde:	ff843783          	ld	a5,-8(s0)
ffffffffc0207de2:	cfa5                	beqz	a5,ffffffffc0207e5a <vfs_mount+0xd0>
ffffffffc0207de4:	fe843503          	ld	a0,-24(s0)
ffffffffc0207de8:	c929                	beqz	a0,ffffffffc0207e3a <vfs_mount+0xb0>
ffffffffc0207dea:	4d38                	lw	a4,88(a0)
ffffffffc0207dec:	6785                	lui	a5,0x1
ffffffffc0207dee:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207df2:	04f71463          	bne	a4,a5,ffffffffc0207e3a <vfs_mount+0xb0>
ffffffffc0207df6:	ff040593          	addi	a1,s0,-16
ffffffffc0207dfa:	9982                	jalr	s3
ffffffffc0207dfc:	84aa                	mv	s1,a0
ffffffffc0207dfe:	ed01                	bnez	a0,ffffffffc0207e16 <vfs_mount+0x8c>
ffffffffc0207e00:	ff043783          	ld	a5,-16(s0)
ffffffffc0207e04:	cfad                	beqz	a5,ffffffffc0207e7e <vfs_mount+0xf4>
ffffffffc0207e06:	fe043583          	ld	a1,-32(s0)
ffffffffc0207e0a:	00006517          	auipc	a0,0x6
ffffffffc0207e0e:	0de50513          	addi	a0,a0,222 # ffffffffc020dee8 <etext+0x2612>
ffffffffc0207e12:	b16f80ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc0207e16:	0008e517          	auipc	a0,0x8e
ffffffffc0207e1a:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0295800 <vdev_list_sem>
ffffffffc0207e1e:	9b7fc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0207e22:	70a2                	ld	ra,40(sp)
ffffffffc0207e24:	7402                	ld	s0,32(sp)
ffffffffc0207e26:	6942                	ld	s2,16(sp)
ffffffffc0207e28:	69a2                	ld	s3,8(sp)
ffffffffc0207e2a:	8526                	mv	a0,s1
ffffffffc0207e2c:	64e2                	ld	s1,24(sp)
ffffffffc0207e2e:	6145                	addi	sp,sp,48
ffffffffc0207e30:	8082                	ret
ffffffffc0207e32:	54cd                	li	s1,-13
ffffffffc0207e34:	b7cd                	j	ffffffffc0207e16 <vfs_mount+0x8c>
ffffffffc0207e36:	54c5                	li	s1,-15
ffffffffc0207e38:	bff9                	j	ffffffffc0207e16 <vfs_mount+0x8c>
ffffffffc0207e3a:	00006697          	auipc	a3,0x6
ffffffffc0207e3e:	05e68693          	addi	a3,a3,94 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0207e42:	00004617          	auipc	a2,0x4
ffffffffc0207e46:	f4e60613          	addi	a2,a2,-178 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207e4a:	0ed00593          	li	a1,237
ffffffffc0207e4e:	00006517          	auipc	a0,0x6
ffffffffc0207e52:	f9250513          	addi	a0,a0,-110 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207e56:	bd6f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207e5a:	00006697          	auipc	a3,0x6
ffffffffc0207e5e:	00e68693          	addi	a3,a3,14 # ffffffffc020de68 <etext+0x2592>
ffffffffc0207e62:	00004617          	auipc	a2,0x4
ffffffffc0207e66:	f2e60613          	addi	a2,a2,-210 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207e6a:	0eb00593          	li	a1,235
ffffffffc0207e6e:	00006517          	auipc	a0,0x6
ffffffffc0207e72:	f7250513          	addi	a0,a0,-142 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207e76:	bb6f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0207e7a:	d6bff0ef          	jal	ffffffffc0207be4 <find_mount.part.0>
ffffffffc0207e7e:	00006697          	auipc	a3,0x6
ffffffffc0207e82:	05268693          	addi	a3,a3,82 # ffffffffc020ded0 <etext+0x25fa>
ffffffffc0207e86:	00004617          	auipc	a2,0x4
ffffffffc0207e8a:	f0a60613          	addi	a2,a2,-246 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207e8e:	0ef00593          	li	a1,239
ffffffffc0207e92:	00006517          	auipc	a0,0x6
ffffffffc0207e96:	f4e50513          	addi	a0,a0,-178 # ffffffffc020dde0 <etext+0x250a>
ffffffffc0207e9a:	b92f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207e9e <vfs_get_curdir>:
ffffffffc0207e9e:	0008f797          	auipc	a5,0x8f
ffffffffc0207ea2:	a2a7b783          	ld	a5,-1494(a5) # ffffffffc02968c8 <current>
ffffffffc0207ea6:	1101                	addi	sp,sp,-32
ffffffffc0207ea8:	e822                	sd	s0,16(sp)
ffffffffc0207eaa:	1487b783          	ld	a5,328(a5)
ffffffffc0207eae:	ec06                	sd	ra,24(sp)
ffffffffc0207eb0:	6380                	ld	s0,0(a5)
ffffffffc0207eb2:	cc09                	beqz	s0,ffffffffc0207ecc <vfs_get_curdir+0x2e>
ffffffffc0207eb4:	e426                	sd	s1,8(sp)
ffffffffc0207eb6:	84aa                	mv	s1,a0
ffffffffc0207eb8:	8522                	mv	a0,s0
ffffffffc0207eba:	41c000ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0207ebe:	e080                	sd	s0,0(s1)
ffffffffc0207ec0:	64a2                	ld	s1,8(sp)
ffffffffc0207ec2:	4501                	li	a0,0
ffffffffc0207ec4:	60e2                	ld	ra,24(sp)
ffffffffc0207ec6:	6442                	ld	s0,16(sp)
ffffffffc0207ec8:	6105                	addi	sp,sp,32
ffffffffc0207eca:	8082                	ret
ffffffffc0207ecc:	5541                	li	a0,-16
ffffffffc0207ece:	bfdd                	j	ffffffffc0207ec4 <vfs_get_curdir+0x26>

ffffffffc0207ed0 <vfs_set_curdir>:
ffffffffc0207ed0:	7139                	addi	sp,sp,-64
ffffffffc0207ed2:	f04a                	sd	s2,32(sp)
ffffffffc0207ed4:	0008f917          	auipc	s2,0x8f
ffffffffc0207ed8:	9f490913          	addi	s2,s2,-1548 # ffffffffc02968c8 <current>
ffffffffc0207edc:	00093783          	ld	a5,0(s2)
ffffffffc0207ee0:	f822                	sd	s0,48(sp)
ffffffffc0207ee2:	842a                	mv	s0,a0
ffffffffc0207ee4:	1487b503          	ld	a0,328(a5)
ffffffffc0207ee8:	fc06                	sd	ra,56(sp)
ffffffffc0207eea:	f426                	sd	s1,40(sp)
ffffffffc0207eec:	9d7fd0ef          	jal	ffffffffc02058c2 <lock_files>
ffffffffc0207ef0:	00093783          	ld	a5,0(s2)
ffffffffc0207ef4:	1487b503          	ld	a0,328(a5)
ffffffffc0207ef8:	611c                	ld	a5,0(a0)
ffffffffc0207efa:	06f40a63          	beq	s0,a5,ffffffffc0207f6e <vfs_set_curdir+0x9e>
ffffffffc0207efe:	c02d                	beqz	s0,ffffffffc0207f60 <vfs_set_curdir+0x90>
ffffffffc0207f00:	7838                	ld	a4,112(s0)
ffffffffc0207f02:	cb25                	beqz	a4,ffffffffc0207f72 <vfs_set_curdir+0xa2>
ffffffffc0207f04:	6b38                	ld	a4,80(a4)
ffffffffc0207f06:	c735                	beqz	a4,ffffffffc0207f72 <vfs_set_curdir+0xa2>
ffffffffc0207f08:	00006597          	auipc	a1,0x6
ffffffffc0207f0c:	05858593          	addi	a1,a1,88 # ffffffffc020df60 <etext+0x268a>
ffffffffc0207f10:	8522                	mv	a0,s0
ffffffffc0207f12:	e43e                	sd	a5,8(sp)
ffffffffc0207f14:	3d6000ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0207f18:	7838                	ld	a4,112(s0)
ffffffffc0207f1a:	086c                	addi	a1,sp,28
ffffffffc0207f1c:	8522                	mv	a0,s0
ffffffffc0207f1e:	6b38                	ld	a4,80(a4)
ffffffffc0207f20:	9702                	jalr	a4
ffffffffc0207f22:	84aa                	mv	s1,a0
ffffffffc0207f24:	e909                	bnez	a0,ffffffffc0207f36 <vfs_set_curdir+0x66>
ffffffffc0207f26:	4772                	lw	a4,28(sp)
ffffffffc0207f28:	4609                	li	a2,2
ffffffffc0207f2a:	54b9                	li	s1,-18
ffffffffc0207f2c:	40c75693          	srai	a3,a4,0xc
ffffffffc0207f30:	8a9d                	andi	a3,a3,7
ffffffffc0207f32:	00c68f63          	beq	a3,a2,ffffffffc0207f50 <vfs_set_curdir+0x80>
ffffffffc0207f36:	00093783          	ld	a5,0(s2)
ffffffffc0207f3a:	1487b503          	ld	a0,328(a5)
ffffffffc0207f3e:	98bfd0ef          	jal	ffffffffc02058c8 <unlock_files>
ffffffffc0207f42:	70e2                	ld	ra,56(sp)
ffffffffc0207f44:	7442                	ld	s0,48(sp)
ffffffffc0207f46:	7902                	ld	s2,32(sp)
ffffffffc0207f48:	8526                	mv	a0,s1
ffffffffc0207f4a:	74a2                	ld	s1,40(sp)
ffffffffc0207f4c:	6121                	addi	sp,sp,64
ffffffffc0207f4e:	8082                	ret
ffffffffc0207f50:	8522                	mv	a0,s0
ffffffffc0207f52:	384000ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0207f56:	00093703          	ld	a4,0(s2)
ffffffffc0207f5a:	67a2                	ld	a5,8(sp)
ffffffffc0207f5c:	14873503          	ld	a0,328(a4)
ffffffffc0207f60:	e100                	sd	s0,0(a0)
ffffffffc0207f62:	4481                	li	s1,0
ffffffffc0207f64:	dfe9                	beqz	a5,ffffffffc0207f3e <vfs_set_curdir+0x6e>
ffffffffc0207f66:	853e                	mv	a0,a5
ffffffffc0207f68:	43c000ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc0207f6c:	b7e9                	j	ffffffffc0207f36 <vfs_set_curdir+0x66>
ffffffffc0207f6e:	4481                	li	s1,0
ffffffffc0207f70:	b7f9                	j	ffffffffc0207f3e <vfs_set_curdir+0x6e>
ffffffffc0207f72:	00006697          	auipc	a3,0x6
ffffffffc0207f76:	f8668693          	addi	a3,a3,-122 # ffffffffc020def8 <etext+0x2622>
ffffffffc0207f7a:	00004617          	auipc	a2,0x4
ffffffffc0207f7e:	e1660613          	addi	a2,a2,-490 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0207f82:	04300593          	li	a1,67
ffffffffc0207f86:	00006517          	auipc	a0,0x6
ffffffffc0207f8a:	fc250513          	addi	a0,a0,-62 # ffffffffc020df48 <etext+0x2672>
ffffffffc0207f8e:	a9ef80ef          	jal	ffffffffc020022c <__panic>

ffffffffc0207f92 <vfs_chdir>:
ffffffffc0207f92:	7179                	addi	sp,sp,-48
ffffffffc0207f94:	082c                	addi	a1,sp,24
ffffffffc0207f96:	f406                	sd	ra,40(sp)
ffffffffc0207f98:	20c000ef          	jal	ffffffffc02081a4 <vfs_lookup>
ffffffffc0207f9c:	87aa                	mv	a5,a0
ffffffffc0207f9e:	c509                	beqz	a0,ffffffffc0207fa8 <vfs_chdir+0x16>
ffffffffc0207fa0:	70a2                	ld	ra,40(sp)
ffffffffc0207fa2:	853e                	mv	a0,a5
ffffffffc0207fa4:	6145                	addi	sp,sp,48
ffffffffc0207fa6:	8082                	ret
ffffffffc0207fa8:	6562                	ld	a0,24(sp)
ffffffffc0207faa:	f27ff0ef          	jal	ffffffffc0207ed0 <vfs_set_curdir>
ffffffffc0207fae:	87aa                	mv	a5,a0
ffffffffc0207fb0:	6562                	ld	a0,24(sp)
ffffffffc0207fb2:	e43e                	sd	a5,8(sp)
ffffffffc0207fb4:	3f0000ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc0207fb8:	67a2                	ld	a5,8(sp)
ffffffffc0207fba:	70a2                	ld	ra,40(sp)
ffffffffc0207fbc:	853e                	mv	a0,a5
ffffffffc0207fbe:	6145                	addi	sp,sp,48
ffffffffc0207fc0:	8082                	ret

ffffffffc0207fc2 <vfs_getcwd>:
ffffffffc0207fc2:	0008f797          	auipc	a5,0x8f
ffffffffc0207fc6:	9067b783          	ld	a5,-1786(a5) # ffffffffc02968c8 <current>
ffffffffc0207fca:	7179                	addi	sp,sp,-48
ffffffffc0207fcc:	ec26                	sd	s1,24(sp)
ffffffffc0207fce:	1487b783          	ld	a5,328(a5)
ffffffffc0207fd2:	f406                	sd	ra,40(sp)
ffffffffc0207fd4:	f022                	sd	s0,32(sp)
ffffffffc0207fd6:	6384                	ld	s1,0(a5)
ffffffffc0207fd8:	c0c1                	beqz	s1,ffffffffc0208058 <vfs_getcwd+0x96>
ffffffffc0207fda:	e84a                	sd	s2,16(sp)
ffffffffc0207fdc:	892a                	mv	s2,a0
ffffffffc0207fde:	8526                	mv	a0,s1
ffffffffc0207fe0:	2f6000ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0207fe4:	74a8                	ld	a0,104(s1)
ffffffffc0207fe6:	c93d                	beqz	a0,ffffffffc020805c <vfs_getcwd+0x9a>
ffffffffc0207fe8:	d51ff0ef          	jal	ffffffffc0207d38 <vfs_get_devname>
ffffffffc0207fec:	842a                	mv	s0,a0
ffffffffc0207fee:	344030ef          	jal	ffffffffc020b332 <strlen>
ffffffffc0207ff2:	862a                	mv	a2,a0
ffffffffc0207ff4:	85a2                	mv	a1,s0
ffffffffc0207ff6:	854a                	mv	a0,s2
ffffffffc0207ff8:	4701                	li	a4,0
ffffffffc0207ffa:	4685                	li	a3,1
ffffffffc0207ffc:	80bfd0ef          	jal	ffffffffc0205806 <iobuf_move>
ffffffffc0208000:	842a                	mv	s0,a0
ffffffffc0208002:	c919                	beqz	a0,ffffffffc0208018 <vfs_getcwd+0x56>
ffffffffc0208004:	8526                	mv	a0,s1
ffffffffc0208006:	39e000ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020800a:	6942                	ld	s2,16(sp)
ffffffffc020800c:	70a2                	ld	ra,40(sp)
ffffffffc020800e:	8522                	mv	a0,s0
ffffffffc0208010:	7402                	ld	s0,32(sp)
ffffffffc0208012:	64e2                	ld	s1,24(sp)
ffffffffc0208014:	6145                	addi	sp,sp,48
ffffffffc0208016:	8082                	ret
ffffffffc0208018:	4685                	li	a3,1
ffffffffc020801a:	03a00793          	li	a5,58
ffffffffc020801e:	8636                	mv	a2,a3
ffffffffc0208020:	4701                	li	a4,0
ffffffffc0208022:	00f10593          	addi	a1,sp,15
ffffffffc0208026:	854a                	mv	a0,s2
ffffffffc0208028:	00f107a3          	sb	a5,15(sp)
ffffffffc020802c:	fdafd0ef          	jal	ffffffffc0205806 <iobuf_move>
ffffffffc0208030:	842a                	mv	s0,a0
ffffffffc0208032:	f969                	bnez	a0,ffffffffc0208004 <vfs_getcwd+0x42>
ffffffffc0208034:	78bc                	ld	a5,112(s1)
ffffffffc0208036:	c3b9                	beqz	a5,ffffffffc020807c <vfs_getcwd+0xba>
ffffffffc0208038:	7f9c                	ld	a5,56(a5)
ffffffffc020803a:	c3a9                	beqz	a5,ffffffffc020807c <vfs_getcwd+0xba>
ffffffffc020803c:	00006597          	auipc	a1,0x6
ffffffffc0208040:	f9c58593          	addi	a1,a1,-100 # ffffffffc020dfd8 <etext+0x2702>
ffffffffc0208044:	8526                	mv	a0,s1
ffffffffc0208046:	2a4000ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020804a:	78bc                	ld	a5,112(s1)
ffffffffc020804c:	85ca                	mv	a1,s2
ffffffffc020804e:	8526                	mv	a0,s1
ffffffffc0208050:	7f9c                	ld	a5,56(a5)
ffffffffc0208052:	9782                	jalr	a5
ffffffffc0208054:	842a                	mv	s0,a0
ffffffffc0208056:	b77d                	j	ffffffffc0208004 <vfs_getcwd+0x42>
ffffffffc0208058:	5441                	li	s0,-16
ffffffffc020805a:	bf4d                	j	ffffffffc020800c <vfs_getcwd+0x4a>
ffffffffc020805c:	00006697          	auipc	a3,0x6
ffffffffc0208060:	f0c68693          	addi	a3,a3,-244 # ffffffffc020df68 <etext+0x2692>
ffffffffc0208064:	00004617          	auipc	a2,0x4
ffffffffc0208068:	d2c60613          	addi	a2,a2,-724 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020806c:	06e00593          	li	a1,110
ffffffffc0208070:	00006517          	auipc	a0,0x6
ffffffffc0208074:	ed850513          	addi	a0,a0,-296 # ffffffffc020df48 <etext+0x2672>
ffffffffc0208078:	9b4f80ef          	jal	ffffffffc020022c <__panic>
ffffffffc020807c:	00006697          	auipc	a3,0x6
ffffffffc0208080:	f0468693          	addi	a3,a3,-252 # ffffffffc020df80 <etext+0x26aa>
ffffffffc0208084:	00004617          	auipc	a2,0x4
ffffffffc0208088:	d0c60613          	addi	a2,a2,-756 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020808c:	07800593          	li	a1,120
ffffffffc0208090:	00006517          	auipc	a0,0x6
ffffffffc0208094:	eb850513          	addi	a0,a0,-328 # ffffffffc020df48 <etext+0x2672>
ffffffffc0208098:	994f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc020809c <get_device>:
ffffffffc020809c:	00054e03          	lbu	t3,0(a0)
ffffffffc02080a0:	020e0463          	beqz	t3,ffffffffc02080c8 <get_device+0x2c>
ffffffffc02080a4:	00150693          	addi	a3,a0,1
ffffffffc02080a8:	8736                	mv	a4,a3
ffffffffc02080aa:	87f2                	mv	a5,t3
ffffffffc02080ac:	4801                	li	a6,0
ffffffffc02080ae:	03a00893          	li	a7,58
ffffffffc02080b2:	02f00313          	li	t1,47
ffffffffc02080b6:	01178d63          	beq	a5,a7,ffffffffc02080d0 <get_device+0x34>
ffffffffc02080ba:	02678f63          	beq	a5,t1,ffffffffc02080f8 <get_device+0x5c>
ffffffffc02080be:	00074783          	lbu	a5,0(a4)
ffffffffc02080c2:	0705                	addi	a4,a4,1
ffffffffc02080c4:	2805                	addiw	a6,a6,1
ffffffffc02080c6:	fbe5                	bnez	a5,ffffffffc02080b6 <get_device+0x1a>
ffffffffc02080c8:	e188                	sd	a0,0(a1)
ffffffffc02080ca:	8532                	mv	a0,a2
ffffffffc02080cc:	dd3ff06f          	j	ffffffffc0207e9e <vfs_get_curdir>
ffffffffc02080d0:	02080663          	beqz	a6,ffffffffc02080fc <get_device+0x60>
ffffffffc02080d4:	01050733          	add	a4,a0,a6
ffffffffc02080d8:	010687b3          	add	a5,a3,a6
ffffffffc02080dc:	00070023          	sb	zero,0(a4)
ffffffffc02080e0:	02f00813          	li	a6,47
ffffffffc02080e4:	86be                	mv	a3,a5
ffffffffc02080e6:	0007c703          	lbu	a4,0(a5)
ffffffffc02080ea:	0785                	addi	a5,a5,1
ffffffffc02080ec:	ff070ce3          	beq	a4,a6,ffffffffc02080e4 <get_device+0x48>
ffffffffc02080f0:	e194                	sd	a3,0(a1)
ffffffffc02080f2:	85b2                	mv	a1,a2
ffffffffc02080f4:	b85ff06f          	j	ffffffffc0207c78 <vfs_get_root>
ffffffffc02080f8:	fc0818e3          	bnez	a6,ffffffffc02080c8 <get_device+0x2c>
ffffffffc02080fc:	7139                	addi	sp,sp,-64
ffffffffc02080fe:	f822                	sd	s0,48(sp)
ffffffffc0208100:	f426                	sd	s1,40(sp)
ffffffffc0208102:	fc06                	sd	ra,56(sp)
ffffffffc0208104:	02f00793          	li	a5,47
ffffffffc0208108:	8432                	mv	s0,a2
ffffffffc020810a:	84ae                	mv	s1,a1
ffffffffc020810c:	04fe0563          	beq	t3,a5,ffffffffc0208156 <get_device+0xba>
ffffffffc0208110:	03a00793          	li	a5,58
ffffffffc0208114:	06fe1863          	bne	t3,a5,ffffffffc0208184 <get_device+0xe8>
ffffffffc0208118:	0828                	addi	a0,sp,24
ffffffffc020811a:	e436                	sd	a3,8(sp)
ffffffffc020811c:	d83ff0ef          	jal	ffffffffc0207e9e <vfs_get_curdir>
ffffffffc0208120:	e515                	bnez	a0,ffffffffc020814c <get_device+0xb0>
ffffffffc0208122:	67e2                	ld	a5,24(sp)
ffffffffc0208124:	77a8                	ld	a0,104(a5)
ffffffffc0208126:	cd1d                	beqz	a0,ffffffffc0208164 <get_device+0xc8>
ffffffffc0208128:	617c                	ld	a5,192(a0)
ffffffffc020812a:	9782                	jalr	a5
ffffffffc020812c:	87aa                	mv	a5,a0
ffffffffc020812e:	6562                	ld	a0,24(sp)
ffffffffc0208130:	e01c                	sd	a5,0(s0)
ffffffffc0208132:	272000ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc0208136:	66a2                	ld	a3,8(sp)
ffffffffc0208138:	02f00713          	li	a4,47
ffffffffc020813c:	a011                	j	ffffffffc0208140 <get_device+0xa4>
ffffffffc020813e:	0685                	addi	a3,a3,1
ffffffffc0208140:	0006c783          	lbu	a5,0(a3)
ffffffffc0208144:	fee78de3          	beq	a5,a4,ffffffffc020813e <get_device+0xa2>
ffffffffc0208148:	e094                	sd	a3,0(s1)
ffffffffc020814a:	4501                	li	a0,0
ffffffffc020814c:	70e2                	ld	ra,56(sp)
ffffffffc020814e:	7442                	ld	s0,48(sp)
ffffffffc0208150:	74a2                	ld	s1,40(sp)
ffffffffc0208152:	6121                	addi	sp,sp,64
ffffffffc0208154:	8082                	ret
ffffffffc0208156:	8532                	mv	a0,a2
ffffffffc0208158:	e436                	sd	a3,8(sp)
ffffffffc020815a:	61e000ef          	jal	ffffffffc0208778 <vfs_get_bootfs>
ffffffffc020815e:	66a2                	ld	a3,8(sp)
ffffffffc0208160:	dd61                	beqz	a0,ffffffffc0208138 <get_device+0x9c>
ffffffffc0208162:	b7ed                	j	ffffffffc020814c <get_device+0xb0>
ffffffffc0208164:	00006697          	auipc	a3,0x6
ffffffffc0208168:	e0468693          	addi	a3,a3,-508 # ffffffffc020df68 <etext+0x2692>
ffffffffc020816c:	00004617          	auipc	a2,0x4
ffffffffc0208170:	c2460613          	addi	a2,a2,-988 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208174:	03900593          	li	a1,57
ffffffffc0208178:	00006517          	auipc	a0,0x6
ffffffffc020817c:	e8050513          	addi	a0,a0,-384 # ffffffffc020dff8 <etext+0x2722>
ffffffffc0208180:	8acf80ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208184:	00006697          	auipc	a3,0x6
ffffffffc0208188:	e6468693          	addi	a3,a3,-412 # ffffffffc020dfe8 <etext+0x2712>
ffffffffc020818c:	00004617          	auipc	a2,0x4
ffffffffc0208190:	c0460613          	addi	a2,a2,-1020 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208194:	03300593          	li	a1,51
ffffffffc0208198:	00006517          	auipc	a0,0x6
ffffffffc020819c:	e6050513          	addi	a0,a0,-416 # ffffffffc020dff8 <etext+0x2722>
ffffffffc02081a0:	88cf80ef          	jal	ffffffffc020022c <__panic>

ffffffffc02081a4 <vfs_lookup>:
ffffffffc02081a4:	7139                	addi	sp,sp,-64
ffffffffc02081a6:	f822                	sd	s0,48(sp)
ffffffffc02081a8:	1030                	addi	a2,sp,40
ffffffffc02081aa:	842e                	mv	s0,a1
ffffffffc02081ac:	082c                	addi	a1,sp,24
ffffffffc02081ae:	fc06                	sd	ra,56(sp)
ffffffffc02081b0:	ec2a                	sd	a0,24(sp)
ffffffffc02081b2:	eebff0ef          	jal	ffffffffc020809c <get_device>
ffffffffc02081b6:	87aa                	mv	a5,a0
ffffffffc02081b8:	e121                	bnez	a0,ffffffffc02081f8 <vfs_lookup+0x54>
ffffffffc02081ba:	6762                	ld	a4,24(sp)
ffffffffc02081bc:	7522                	ld	a0,40(sp)
ffffffffc02081be:	00074683          	lbu	a3,0(a4)
ffffffffc02081c2:	c2a1                	beqz	a3,ffffffffc0208202 <vfs_lookup+0x5e>
ffffffffc02081c4:	c529                	beqz	a0,ffffffffc020820e <vfs_lookup+0x6a>
ffffffffc02081c6:	793c                	ld	a5,112(a0)
ffffffffc02081c8:	c3b9                	beqz	a5,ffffffffc020820e <vfs_lookup+0x6a>
ffffffffc02081ca:	7bbc                	ld	a5,112(a5)
ffffffffc02081cc:	c3a9                	beqz	a5,ffffffffc020820e <vfs_lookup+0x6a>
ffffffffc02081ce:	00006597          	auipc	a1,0x6
ffffffffc02081d2:	e9258593          	addi	a1,a1,-366 # ffffffffc020e060 <etext+0x278a>
ffffffffc02081d6:	e83a                	sd	a4,16(sp)
ffffffffc02081d8:	e42a                	sd	a0,8(sp)
ffffffffc02081da:	110000ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02081de:	6522                	ld	a0,8(sp)
ffffffffc02081e0:	65c2                	ld	a1,16(sp)
ffffffffc02081e2:	8622                	mv	a2,s0
ffffffffc02081e4:	793c                	ld	a5,112(a0)
ffffffffc02081e6:	7522                	ld	a0,40(sp)
ffffffffc02081e8:	7bbc                	ld	a5,112(a5)
ffffffffc02081ea:	9782                	jalr	a5
ffffffffc02081ec:	87aa                	mv	a5,a0
ffffffffc02081ee:	7522                	ld	a0,40(sp)
ffffffffc02081f0:	e43e                	sd	a5,8(sp)
ffffffffc02081f2:	1b2000ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc02081f6:	67a2                	ld	a5,8(sp)
ffffffffc02081f8:	70e2                	ld	ra,56(sp)
ffffffffc02081fa:	7442                	ld	s0,48(sp)
ffffffffc02081fc:	853e                	mv	a0,a5
ffffffffc02081fe:	6121                	addi	sp,sp,64
ffffffffc0208200:	8082                	ret
ffffffffc0208202:	e008                	sd	a0,0(s0)
ffffffffc0208204:	70e2                	ld	ra,56(sp)
ffffffffc0208206:	7442                	ld	s0,48(sp)
ffffffffc0208208:	853e                	mv	a0,a5
ffffffffc020820a:	6121                	addi	sp,sp,64
ffffffffc020820c:	8082                	ret
ffffffffc020820e:	00006697          	auipc	a3,0x6
ffffffffc0208212:	e0268693          	addi	a3,a3,-510 # ffffffffc020e010 <etext+0x273a>
ffffffffc0208216:	00004617          	auipc	a2,0x4
ffffffffc020821a:	b7a60613          	addi	a2,a2,-1158 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020821e:	04f00593          	li	a1,79
ffffffffc0208222:	00006517          	auipc	a0,0x6
ffffffffc0208226:	dd650513          	addi	a0,a0,-554 # ffffffffc020dff8 <etext+0x2722>
ffffffffc020822a:	802f80ef          	jal	ffffffffc020022c <__panic>

ffffffffc020822e <vfs_lookup_parent>:
ffffffffc020822e:	7139                	addi	sp,sp,-64
ffffffffc0208230:	f822                	sd	s0,48(sp)
ffffffffc0208232:	f426                	sd	s1,40(sp)
ffffffffc0208234:	8432                	mv	s0,a2
ffffffffc0208236:	84ae                	mv	s1,a1
ffffffffc0208238:	0830                	addi	a2,sp,24
ffffffffc020823a:	002c                	addi	a1,sp,8
ffffffffc020823c:	fc06                	sd	ra,56(sp)
ffffffffc020823e:	e42a                	sd	a0,8(sp)
ffffffffc0208240:	e5dff0ef          	jal	ffffffffc020809c <get_device>
ffffffffc0208244:	e509                	bnez	a0,ffffffffc020824e <vfs_lookup_parent+0x20>
ffffffffc0208246:	6722                	ld	a4,8(sp)
ffffffffc0208248:	67e2                	ld	a5,24(sp)
ffffffffc020824a:	e018                	sd	a4,0(s0)
ffffffffc020824c:	e09c                	sd	a5,0(s1)
ffffffffc020824e:	70e2                	ld	ra,56(sp)
ffffffffc0208250:	7442                	ld	s0,48(sp)
ffffffffc0208252:	74a2                	ld	s1,40(sp)
ffffffffc0208254:	6121                	addi	sp,sp,64
ffffffffc0208256:	8082                	ret

ffffffffc0208258 <__alloc_inode>:
ffffffffc0208258:	1141                	addi	sp,sp,-16
ffffffffc020825a:	e022                	sd	s0,0(sp)
ffffffffc020825c:	842a                	mv	s0,a0
ffffffffc020825e:	07800513          	li	a0,120
ffffffffc0208262:	e406                	sd	ra,8(sp)
ffffffffc0208264:	ad9f90ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0208268:	c111                	beqz	a0,ffffffffc020826c <__alloc_inode+0x14>
ffffffffc020826a:	cd20                	sw	s0,88(a0)
ffffffffc020826c:	60a2                	ld	ra,8(sp)
ffffffffc020826e:	6402                	ld	s0,0(sp)
ffffffffc0208270:	0141                	addi	sp,sp,16
ffffffffc0208272:	8082                	ret

ffffffffc0208274 <inode_init>:
ffffffffc0208274:	4785                	li	a5,1
ffffffffc0208276:	06052023          	sw	zero,96(a0)
ffffffffc020827a:	f92c                	sd	a1,112(a0)
ffffffffc020827c:	f530                	sd	a2,104(a0)
ffffffffc020827e:	cd7c                	sw	a5,92(a0)
ffffffffc0208280:	8082                	ret

ffffffffc0208282 <inode_kill>:
ffffffffc0208282:	4d78                	lw	a4,92(a0)
ffffffffc0208284:	1141                	addi	sp,sp,-16
ffffffffc0208286:	e406                	sd	ra,8(sp)
ffffffffc0208288:	e719                	bnez	a4,ffffffffc0208296 <inode_kill+0x14>
ffffffffc020828a:	513c                	lw	a5,96(a0)
ffffffffc020828c:	e78d                	bnez	a5,ffffffffc02082b6 <inode_kill+0x34>
ffffffffc020828e:	60a2                	ld	ra,8(sp)
ffffffffc0208290:	0141                	addi	sp,sp,16
ffffffffc0208292:	b51f906f          	j	ffffffffc0201de2 <kfree>
ffffffffc0208296:	00006697          	auipc	a3,0x6
ffffffffc020829a:	dd268693          	addi	a3,a3,-558 # ffffffffc020e068 <etext+0x2792>
ffffffffc020829e:	00004617          	auipc	a2,0x4
ffffffffc02082a2:	af260613          	addi	a2,a2,-1294 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02082a6:	02900593          	li	a1,41
ffffffffc02082aa:	00006517          	auipc	a0,0x6
ffffffffc02082ae:	dde50513          	addi	a0,a0,-546 # ffffffffc020e088 <etext+0x27b2>
ffffffffc02082b2:	f7bf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc02082b6:	00006697          	auipc	a3,0x6
ffffffffc02082ba:	dea68693          	addi	a3,a3,-534 # ffffffffc020e0a0 <etext+0x27ca>
ffffffffc02082be:	00004617          	auipc	a2,0x4
ffffffffc02082c2:	ad260613          	addi	a2,a2,-1326 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02082c6:	02a00593          	li	a1,42
ffffffffc02082ca:	00006517          	auipc	a0,0x6
ffffffffc02082ce:	dbe50513          	addi	a0,a0,-578 # ffffffffc020e088 <etext+0x27b2>
ffffffffc02082d2:	f5bf70ef          	jal	ffffffffc020022c <__panic>

ffffffffc02082d6 <inode_ref_inc>:
ffffffffc02082d6:	4d7c                	lw	a5,92(a0)
ffffffffc02082d8:	2785                	addiw	a5,a5,1
ffffffffc02082da:	cd7c                	sw	a5,92(a0)
ffffffffc02082dc:	853e                	mv	a0,a5
ffffffffc02082de:	8082                	ret

ffffffffc02082e0 <inode_open_inc>:
ffffffffc02082e0:	513c                	lw	a5,96(a0)
ffffffffc02082e2:	2785                	addiw	a5,a5,1
ffffffffc02082e4:	d13c                	sw	a5,96(a0)
ffffffffc02082e6:	853e                	mv	a0,a5
ffffffffc02082e8:	8082                	ret

ffffffffc02082ea <inode_check>:
ffffffffc02082ea:	1141                	addi	sp,sp,-16
ffffffffc02082ec:	e406                	sd	ra,8(sp)
ffffffffc02082ee:	c91d                	beqz	a0,ffffffffc0208324 <inode_check+0x3a>
ffffffffc02082f0:	793c                	ld	a5,112(a0)
ffffffffc02082f2:	cb8d                	beqz	a5,ffffffffc0208324 <inode_check+0x3a>
ffffffffc02082f4:	6398                	ld	a4,0(a5)
ffffffffc02082f6:	4625d7b7          	lui	a5,0x4625d
ffffffffc02082fa:	0786                	slli	a5,a5,0x1
ffffffffc02082fc:	47678793          	addi	a5,a5,1142 # 4625d476 <_binary_bin_sfs_img_size+0x461e8176>
ffffffffc0208300:	08f71263          	bne	a4,a5,ffffffffc0208384 <inode_check+0x9a>
ffffffffc0208304:	4d74                	lw	a3,92(a0)
ffffffffc0208306:	5138                	lw	a4,96(a0)
ffffffffc0208308:	04e6ce63          	blt	a3,a4,ffffffffc0208364 <inode_check+0x7a>
ffffffffc020830c:	01f7579b          	srliw	a5,a4,0x1f
ffffffffc0208310:	ebb1                	bnez	a5,ffffffffc0208364 <inode_check+0x7a>
ffffffffc0208312:	67c1                	lui	a5,0x10
ffffffffc0208314:	17fd                	addi	a5,a5,-1 # ffff <_binary_bin_swap_img_size+0x82ff>
ffffffffc0208316:	02d7c763          	blt	a5,a3,ffffffffc0208344 <inode_check+0x5a>
ffffffffc020831a:	02e7c563          	blt	a5,a4,ffffffffc0208344 <inode_check+0x5a>
ffffffffc020831e:	60a2                	ld	ra,8(sp)
ffffffffc0208320:	0141                	addi	sp,sp,16
ffffffffc0208322:	8082                	ret
ffffffffc0208324:	00006697          	auipc	a3,0x6
ffffffffc0208328:	d9c68693          	addi	a3,a3,-612 # ffffffffc020e0c0 <etext+0x27ea>
ffffffffc020832c:	00004617          	auipc	a2,0x4
ffffffffc0208330:	a6460613          	addi	a2,a2,-1436 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208334:	06e00593          	li	a1,110
ffffffffc0208338:	00006517          	auipc	a0,0x6
ffffffffc020833c:	d5050513          	addi	a0,a0,-688 # ffffffffc020e088 <etext+0x27b2>
ffffffffc0208340:	eedf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208344:	00006697          	auipc	a3,0x6
ffffffffc0208348:	dfc68693          	addi	a3,a3,-516 # ffffffffc020e140 <etext+0x286a>
ffffffffc020834c:	00004617          	auipc	a2,0x4
ffffffffc0208350:	a4460613          	addi	a2,a2,-1468 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208354:	07200593          	li	a1,114
ffffffffc0208358:	00006517          	auipc	a0,0x6
ffffffffc020835c:	d3050513          	addi	a0,a0,-720 # ffffffffc020e088 <etext+0x27b2>
ffffffffc0208360:	ecdf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208364:	00006697          	auipc	a3,0x6
ffffffffc0208368:	dac68693          	addi	a3,a3,-596 # ffffffffc020e110 <etext+0x283a>
ffffffffc020836c:	00004617          	auipc	a2,0x4
ffffffffc0208370:	a2460613          	addi	a2,a2,-1500 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208374:	07100593          	li	a1,113
ffffffffc0208378:	00006517          	auipc	a0,0x6
ffffffffc020837c:	d1050513          	addi	a0,a0,-752 # ffffffffc020e088 <etext+0x27b2>
ffffffffc0208380:	eadf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208384:	00006697          	auipc	a3,0x6
ffffffffc0208388:	d6468693          	addi	a3,a3,-668 # ffffffffc020e0e8 <etext+0x2812>
ffffffffc020838c:	00004617          	auipc	a2,0x4
ffffffffc0208390:	a0460613          	addi	a2,a2,-1532 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208394:	06f00593          	li	a1,111
ffffffffc0208398:	00006517          	auipc	a0,0x6
ffffffffc020839c:	cf050513          	addi	a0,a0,-784 # ffffffffc020e088 <etext+0x27b2>
ffffffffc02083a0:	e8df70ef          	jal	ffffffffc020022c <__panic>

ffffffffc02083a4 <inode_ref_dec>:
ffffffffc02083a4:	4d7c                	lw	a5,92(a0)
ffffffffc02083a6:	7179                	addi	sp,sp,-48
ffffffffc02083a8:	f406                	sd	ra,40(sp)
ffffffffc02083aa:	06f05b63          	blez	a5,ffffffffc0208420 <inode_ref_dec+0x7c>
ffffffffc02083ae:	37fd                	addiw	a5,a5,-1
ffffffffc02083b0:	cd7c                	sw	a5,92(a0)
ffffffffc02083b2:	e795                	bnez	a5,ffffffffc02083de <inode_ref_dec+0x3a>
ffffffffc02083b4:	7934                	ld	a3,112(a0)
ffffffffc02083b6:	c6a9                	beqz	a3,ffffffffc0208400 <inode_ref_dec+0x5c>
ffffffffc02083b8:	66b4                	ld	a3,72(a3)
ffffffffc02083ba:	c2b9                	beqz	a3,ffffffffc0208400 <inode_ref_dec+0x5c>
ffffffffc02083bc:	00006597          	auipc	a1,0x6
ffffffffc02083c0:	e3458593          	addi	a1,a1,-460 # ffffffffc020e1f0 <etext+0x291a>
ffffffffc02083c4:	e83e                	sd	a5,16(sp)
ffffffffc02083c6:	ec2a                	sd	a0,24(sp)
ffffffffc02083c8:	e436                	sd	a3,8(sp)
ffffffffc02083ca:	f21ff0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02083ce:	6562                	ld	a0,24(sp)
ffffffffc02083d0:	66a2                	ld	a3,8(sp)
ffffffffc02083d2:	9682                	jalr	a3
ffffffffc02083d4:	00f50713          	addi	a4,a0,15
ffffffffc02083d8:	67c2                	ld	a5,16(sp)
ffffffffc02083da:	c311                	beqz	a4,ffffffffc02083de <inode_ref_dec+0x3a>
ffffffffc02083dc:	e509                	bnez	a0,ffffffffc02083e6 <inode_ref_dec+0x42>
ffffffffc02083de:	70a2                	ld	ra,40(sp)
ffffffffc02083e0:	853e                	mv	a0,a5
ffffffffc02083e2:	6145                	addi	sp,sp,48
ffffffffc02083e4:	8082                	ret
ffffffffc02083e6:	85aa                	mv	a1,a0
ffffffffc02083e8:	00006517          	auipc	a0,0x6
ffffffffc02083ec:	e1050513          	addi	a0,a0,-496 # ffffffffc020e1f8 <etext+0x2922>
ffffffffc02083f0:	e43e                	sd	a5,8(sp)
ffffffffc02083f2:	d37f70ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc02083f6:	67a2                	ld	a5,8(sp)
ffffffffc02083f8:	70a2                	ld	ra,40(sp)
ffffffffc02083fa:	853e                	mv	a0,a5
ffffffffc02083fc:	6145                	addi	sp,sp,48
ffffffffc02083fe:	8082                	ret
ffffffffc0208400:	00006697          	auipc	a3,0x6
ffffffffc0208404:	da068693          	addi	a3,a3,-608 # ffffffffc020e1a0 <etext+0x28ca>
ffffffffc0208408:	00004617          	auipc	a2,0x4
ffffffffc020840c:	98860613          	addi	a2,a2,-1656 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208410:	04400593          	li	a1,68
ffffffffc0208414:	00006517          	auipc	a0,0x6
ffffffffc0208418:	c7450513          	addi	a0,a0,-908 # ffffffffc020e088 <etext+0x27b2>
ffffffffc020841c:	e11f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208420:	00006697          	auipc	a3,0x6
ffffffffc0208424:	d6068693          	addi	a3,a3,-672 # ffffffffc020e180 <etext+0x28aa>
ffffffffc0208428:	00004617          	auipc	a2,0x4
ffffffffc020842c:	96860613          	addi	a2,a2,-1688 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208430:	03f00593          	li	a1,63
ffffffffc0208434:	00006517          	auipc	a0,0x6
ffffffffc0208438:	c5450513          	addi	a0,a0,-940 # ffffffffc020e088 <etext+0x27b2>
ffffffffc020843c:	df1f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208440 <inode_open_dec>:
ffffffffc0208440:	513c                	lw	a5,96(a0)
ffffffffc0208442:	7179                	addi	sp,sp,-48
ffffffffc0208444:	f406                	sd	ra,40(sp)
ffffffffc0208446:	06f05863          	blez	a5,ffffffffc02084b6 <inode_open_dec+0x76>
ffffffffc020844a:	37fd                	addiw	a5,a5,-1
ffffffffc020844c:	d13c                	sw	a5,96(a0)
ffffffffc020844e:	e39d                	bnez	a5,ffffffffc0208474 <inode_open_dec+0x34>
ffffffffc0208450:	7934                	ld	a3,112(a0)
ffffffffc0208452:	c2b1                	beqz	a3,ffffffffc0208496 <inode_open_dec+0x56>
ffffffffc0208454:	6a94                	ld	a3,16(a3)
ffffffffc0208456:	c2a1                	beqz	a3,ffffffffc0208496 <inode_open_dec+0x56>
ffffffffc0208458:	00006597          	auipc	a1,0x6
ffffffffc020845c:	e3058593          	addi	a1,a1,-464 # ffffffffc020e288 <etext+0x29b2>
ffffffffc0208460:	e83e                	sd	a5,16(sp)
ffffffffc0208462:	ec2a                	sd	a0,24(sp)
ffffffffc0208464:	e436                	sd	a3,8(sp)
ffffffffc0208466:	e85ff0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020846a:	6562                	ld	a0,24(sp)
ffffffffc020846c:	66a2                	ld	a3,8(sp)
ffffffffc020846e:	9682                	jalr	a3
ffffffffc0208470:	67c2                	ld	a5,16(sp)
ffffffffc0208472:	e509                	bnez	a0,ffffffffc020847c <inode_open_dec+0x3c>
ffffffffc0208474:	70a2                	ld	ra,40(sp)
ffffffffc0208476:	853e                	mv	a0,a5
ffffffffc0208478:	6145                	addi	sp,sp,48
ffffffffc020847a:	8082                	ret
ffffffffc020847c:	85aa                	mv	a1,a0
ffffffffc020847e:	00006517          	auipc	a0,0x6
ffffffffc0208482:	e1250513          	addi	a0,a0,-494 # ffffffffc020e290 <etext+0x29ba>
ffffffffc0208486:	e43e                	sd	a5,8(sp)
ffffffffc0208488:	ca1f70ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020848c:	67a2                	ld	a5,8(sp)
ffffffffc020848e:	70a2                	ld	ra,40(sp)
ffffffffc0208490:	853e                	mv	a0,a5
ffffffffc0208492:	6145                	addi	sp,sp,48
ffffffffc0208494:	8082                	ret
ffffffffc0208496:	00006697          	auipc	a3,0x6
ffffffffc020849a:	da268693          	addi	a3,a3,-606 # ffffffffc020e238 <etext+0x2962>
ffffffffc020849e:	00004617          	auipc	a2,0x4
ffffffffc02084a2:	8f260613          	addi	a2,a2,-1806 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02084a6:	06100593          	li	a1,97
ffffffffc02084aa:	00006517          	auipc	a0,0x6
ffffffffc02084ae:	bde50513          	addi	a0,a0,-1058 # ffffffffc020e088 <etext+0x27b2>
ffffffffc02084b2:	d7bf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc02084b6:	00006697          	auipc	a3,0x6
ffffffffc02084ba:	d6268693          	addi	a3,a3,-670 # ffffffffc020e218 <etext+0x2942>
ffffffffc02084be:	00004617          	auipc	a2,0x4
ffffffffc02084c2:	8d260613          	addi	a2,a2,-1838 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02084c6:	05c00593          	li	a1,92
ffffffffc02084ca:	00006517          	auipc	a0,0x6
ffffffffc02084ce:	bbe50513          	addi	a0,a0,-1090 # ffffffffc020e088 <etext+0x27b2>
ffffffffc02084d2:	d5bf70ef          	jal	ffffffffc020022c <__panic>

ffffffffc02084d6 <vfs_open>:
ffffffffc02084d6:	7159                	addi	sp,sp,-112
ffffffffc02084d8:	f486                	sd	ra,104(sp)
ffffffffc02084da:	e0d2                	sd	s4,64(sp)
ffffffffc02084dc:	0035f793          	andi	a5,a1,3
ffffffffc02084e0:	10078363          	beqz	a5,ffffffffc02085e6 <vfs_open+0x110>
ffffffffc02084e4:	470d                	li	a4,3
ffffffffc02084e6:	12e78163          	beq	a5,a4,ffffffffc0208608 <vfs_open+0x132>
ffffffffc02084ea:	f0a2                	sd	s0,96(sp)
ffffffffc02084ec:	eca6                	sd	s1,88(sp)
ffffffffc02084ee:	e8ca                	sd	s2,80(sp)
ffffffffc02084f0:	e4ce                	sd	s3,72(sp)
ffffffffc02084f2:	fc56                	sd	s5,56(sp)
ffffffffc02084f4:	f85a                	sd	s6,48(sp)
ffffffffc02084f6:	0105fa13          	andi	s4,a1,16
ffffffffc02084fa:	842e                	mv	s0,a1
ffffffffc02084fc:	00447793          	andi	a5,s0,4
ffffffffc0208500:	8b32                	mv	s6,a2
ffffffffc0208502:	082c                	addi	a1,sp,24
ffffffffc0208504:	00345613          	srli	a2,s0,0x3
ffffffffc0208508:	8abe                	mv	s5,a5
ffffffffc020850a:	0027d493          	srli	s1,a5,0x2
ffffffffc020850e:	892a                	mv	s2,a0
ffffffffc0208510:	00167993          	andi	s3,a2,1
ffffffffc0208514:	c91ff0ef          	jal	ffffffffc02081a4 <vfs_lookup>
ffffffffc0208518:	87aa                	mv	a5,a0
ffffffffc020851a:	c175                	beqz	a0,ffffffffc02085fe <vfs_open+0x128>
ffffffffc020851c:	01050713          	addi	a4,a0,16
ffffffffc0208520:	eb45                	bnez	a4,ffffffffc02085d0 <vfs_open+0xfa>
ffffffffc0208522:	c4dd                	beqz	s1,ffffffffc02085d0 <vfs_open+0xfa>
ffffffffc0208524:	854a                	mv	a0,s2
ffffffffc0208526:	1010                	addi	a2,sp,32
ffffffffc0208528:	102c                	addi	a1,sp,40
ffffffffc020852a:	d05ff0ef          	jal	ffffffffc020822e <vfs_lookup_parent>
ffffffffc020852e:	87aa                	mv	a5,a0
ffffffffc0208530:	e145                	bnez	a0,ffffffffc02085d0 <vfs_open+0xfa>
ffffffffc0208532:	7522                	ld	a0,40(sp)
ffffffffc0208534:	14050c63          	beqz	a0,ffffffffc020868c <vfs_open+0x1b6>
ffffffffc0208538:	793c                	ld	a5,112(a0)
ffffffffc020853a:	14078963          	beqz	a5,ffffffffc020868c <vfs_open+0x1b6>
ffffffffc020853e:	77bc                	ld	a5,104(a5)
ffffffffc0208540:	14078663          	beqz	a5,ffffffffc020868c <vfs_open+0x1b6>
ffffffffc0208544:	00006597          	auipc	a1,0x6
ffffffffc0208548:	dd458593          	addi	a1,a1,-556 # ffffffffc020e318 <etext+0x2a42>
ffffffffc020854c:	e42a                	sd	a0,8(sp)
ffffffffc020854e:	d9dff0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0208552:	6522                	ld	a0,8(sp)
ffffffffc0208554:	7582                	ld	a1,32(sp)
ffffffffc0208556:	0834                	addi	a3,sp,24
ffffffffc0208558:	793c                	ld	a5,112(a0)
ffffffffc020855a:	7522                	ld	a0,40(sp)
ffffffffc020855c:	864e                	mv	a2,s3
ffffffffc020855e:	77bc                	ld	a5,104(a5)
ffffffffc0208560:	9782                	jalr	a5
ffffffffc0208562:	6562                	ld	a0,24(sp)
ffffffffc0208564:	10050463          	beqz	a0,ffffffffc020866c <vfs_open+0x196>
ffffffffc0208568:	793c                	ld	a5,112(a0)
ffffffffc020856a:	c3e9                	beqz	a5,ffffffffc020862c <vfs_open+0x156>
ffffffffc020856c:	679c                	ld	a5,8(a5)
ffffffffc020856e:	cfdd                	beqz	a5,ffffffffc020862c <vfs_open+0x156>
ffffffffc0208570:	00006597          	auipc	a1,0x6
ffffffffc0208574:	e1058593          	addi	a1,a1,-496 # ffffffffc020e380 <etext+0x2aaa>
ffffffffc0208578:	e42a                	sd	a0,8(sp)
ffffffffc020857a:	d71ff0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020857e:	6522                	ld	a0,8(sp)
ffffffffc0208580:	85a2                	mv	a1,s0
ffffffffc0208582:	793c                	ld	a5,112(a0)
ffffffffc0208584:	6562                	ld	a0,24(sp)
ffffffffc0208586:	679c                	ld	a5,8(a5)
ffffffffc0208588:	9782                	jalr	a5
ffffffffc020858a:	87aa                	mv	a5,a0
ffffffffc020858c:	e43e                	sd	a5,8(sp)
ffffffffc020858e:	6562                	ld	a0,24(sp)
ffffffffc0208590:	e3d1                	bnez	a5,ffffffffc0208614 <vfs_open+0x13e>
ffffffffc0208592:	d4fff0ef          	jal	ffffffffc02082e0 <inode_open_inc>
ffffffffc0208596:	014ae733          	or	a4,s5,s4
ffffffffc020859a:	67a2                	ld	a5,8(sp)
ffffffffc020859c:	c71d                	beqz	a4,ffffffffc02085ca <vfs_open+0xf4>
ffffffffc020859e:	6462                	ld	s0,24(sp)
ffffffffc02085a0:	c455                	beqz	s0,ffffffffc020864c <vfs_open+0x176>
ffffffffc02085a2:	7838                	ld	a4,112(s0)
ffffffffc02085a4:	c745                	beqz	a4,ffffffffc020864c <vfs_open+0x176>
ffffffffc02085a6:	7338                	ld	a4,96(a4)
ffffffffc02085a8:	c355                	beqz	a4,ffffffffc020864c <vfs_open+0x176>
ffffffffc02085aa:	8522                	mv	a0,s0
ffffffffc02085ac:	00006597          	auipc	a1,0x6
ffffffffc02085b0:	e3458593          	addi	a1,a1,-460 # ffffffffc020e3e0 <etext+0x2b0a>
ffffffffc02085b4:	e43e                	sd	a5,8(sp)
ffffffffc02085b6:	d35ff0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02085ba:	7838                	ld	a4,112(s0)
ffffffffc02085bc:	6562                	ld	a0,24(sp)
ffffffffc02085be:	4581                	li	a1,0
ffffffffc02085c0:	7338                	ld	a4,96(a4)
ffffffffc02085c2:	9702                	jalr	a4
ffffffffc02085c4:	67a2                	ld	a5,8(sp)
ffffffffc02085c6:	842a                	mv	s0,a0
ffffffffc02085c8:	e931                	bnez	a0,ffffffffc020861c <vfs_open+0x146>
ffffffffc02085ca:	6762                	ld	a4,24(sp)
ffffffffc02085cc:	00eb3023          	sd	a4,0(s6)
ffffffffc02085d0:	7406                	ld	s0,96(sp)
ffffffffc02085d2:	64e6                	ld	s1,88(sp)
ffffffffc02085d4:	6946                	ld	s2,80(sp)
ffffffffc02085d6:	69a6                	ld	s3,72(sp)
ffffffffc02085d8:	7ae2                	ld	s5,56(sp)
ffffffffc02085da:	7b42                	ld	s6,48(sp)
ffffffffc02085dc:	70a6                	ld	ra,104(sp)
ffffffffc02085de:	6a06                	ld	s4,64(sp)
ffffffffc02085e0:	853e                	mv	a0,a5
ffffffffc02085e2:	6165                	addi	sp,sp,112
ffffffffc02085e4:	8082                	ret
ffffffffc02085e6:	0105f713          	andi	a4,a1,16
ffffffffc02085ea:	8a3a                	mv	s4,a4
ffffffffc02085ec:	57f5                	li	a5,-3
ffffffffc02085ee:	f77d                	bnez	a4,ffffffffc02085dc <vfs_open+0x106>
ffffffffc02085f0:	f0a2                	sd	s0,96(sp)
ffffffffc02085f2:	eca6                	sd	s1,88(sp)
ffffffffc02085f4:	e8ca                	sd	s2,80(sp)
ffffffffc02085f6:	e4ce                	sd	s3,72(sp)
ffffffffc02085f8:	fc56                	sd	s5,56(sp)
ffffffffc02085fa:	f85a                	sd	s6,48(sp)
ffffffffc02085fc:	bdfd                	j	ffffffffc02084fa <vfs_open+0x24>
ffffffffc02085fe:	f60982e3          	beqz	s3,ffffffffc0208562 <vfs_open+0x8c>
ffffffffc0208602:	d0a5                	beqz	s1,ffffffffc0208562 <vfs_open+0x8c>
ffffffffc0208604:	57a5                	li	a5,-23
ffffffffc0208606:	b7e9                	j	ffffffffc02085d0 <vfs_open+0xfa>
ffffffffc0208608:	70a6                	ld	ra,104(sp)
ffffffffc020860a:	57f5                	li	a5,-3
ffffffffc020860c:	6a06                	ld	s4,64(sp)
ffffffffc020860e:	853e                	mv	a0,a5
ffffffffc0208610:	6165                	addi	sp,sp,112
ffffffffc0208612:	8082                	ret
ffffffffc0208614:	d91ff0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc0208618:	67a2                	ld	a5,8(sp)
ffffffffc020861a:	bf5d                	j	ffffffffc02085d0 <vfs_open+0xfa>
ffffffffc020861c:	6562                	ld	a0,24(sp)
ffffffffc020861e:	e23ff0ef          	jal	ffffffffc0208440 <inode_open_dec>
ffffffffc0208622:	6562                	ld	a0,24(sp)
ffffffffc0208624:	d81ff0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc0208628:	87a2                	mv	a5,s0
ffffffffc020862a:	b75d                	j	ffffffffc02085d0 <vfs_open+0xfa>
ffffffffc020862c:	00006697          	auipc	a3,0x6
ffffffffc0208630:	d0468693          	addi	a3,a3,-764 # ffffffffc020e330 <etext+0x2a5a>
ffffffffc0208634:	00003617          	auipc	a2,0x3
ffffffffc0208638:	75c60613          	addi	a2,a2,1884 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020863c:	03300593          	li	a1,51
ffffffffc0208640:	00006517          	auipc	a0,0x6
ffffffffc0208644:	cc050513          	addi	a0,a0,-832 # ffffffffc020e300 <etext+0x2a2a>
ffffffffc0208648:	be5f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc020864c:	00006697          	auipc	a3,0x6
ffffffffc0208650:	d3c68693          	addi	a3,a3,-708 # ffffffffc020e388 <etext+0x2ab2>
ffffffffc0208654:	00003617          	auipc	a2,0x3
ffffffffc0208658:	73c60613          	addi	a2,a2,1852 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020865c:	03a00593          	li	a1,58
ffffffffc0208660:	00006517          	auipc	a0,0x6
ffffffffc0208664:	ca050513          	addi	a0,a0,-864 # ffffffffc020e300 <etext+0x2a2a>
ffffffffc0208668:	bc5f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc020866c:	00006697          	auipc	a3,0x6
ffffffffc0208670:	cb468693          	addi	a3,a3,-844 # ffffffffc020e320 <etext+0x2a4a>
ffffffffc0208674:	00003617          	auipc	a2,0x3
ffffffffc0208678:	71c60613          	addi	a2,a2,1820 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020867c:	03100593          	li	a1,49
ffffffffc0208680:	00006517          	auipc	a0,0x6
ffffffffc0208684:	c8050513          	addi	a0,a0,-896 # ffffffffc020e300 <etext+0x2a2a>
ffffffffc0208688:	ba5f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc020868c:	00006697          	auipc	a3,0x6
ffffffffc0208690:	c2468693          	addi	a3,a3,-988 # ffffffffc020e2b0 <etext+0x29da>
ffffffffc0208694:	00003617          	auipc	a2,0x3
ffffffffc0208698:	6fc60613          	addi	a2,a2,1788 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020869c:	02c00593          	li	a1,44
ffffffffc02086a0:	00006517          	auipc	a0,0x6
ffffffffc02086a4:	c6050513          	addi	a0,a0,-928 # ffffffffc020e300 <etext+0x2a2a>
ffffffffc02086a8:	b85f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc02086ac <vfs_close>:
ffffffffc02086ac:	1141                	addi	sp,sp,-16
ffffffffc02086ae:	e406                	sd	ra,8(sp)
ffffffffc02086b0:	e022                	sd	s0,0(sp)
ffffffffc02086b2:	842a                	mv	s0,a0
ffffffffc02086b4:	d8dff0ef          	jal	ffffffffc0208440 <inode_open_dec>
ffffffffc02086b8:	8522                	mv	a0,s0
ffffffffc02086ba:	cebff0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc02086be:	60a2                	ld	ra,8(sp)
ffffffffc02086c0:	6402                	ld	s0,0(sp)
ffffffffc02086c2:	4501                	li	a0,0
ffffffffc02086c4:	0141                	addi	sp,sp,16
ffffffffc02086c6:	8082                	ret

ffffffffc02086c8 <__alloc_fs>:
ffffffffc02086c8:	1141                	addi	sp,sp,-16
ffffffffc02086ca:	e022                	sd	s0,0(sp)
ffffffffc02086cc:	842a                	mv	s0,a0
ffffffffc02086ce:	0d800513          	li	a0,216
ffffffffc02086d2:	e406                	sd	ra,8(sp)
ffffffffc02086d4:	e68f90ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc02086d8:	c119                	beqz	a0,ffffffffc02086de <__alloc_fs+0x16>
ffffffffc02086da:	0a852823          	sw	s0,176(a0)
ffffffffc02086de:	60a2                	ld	ra,8(sp)
ffffffffc02086e0:	6402                	ld	s0,0(sp)
ffffffffc02086e2:	0141                	addi	sp,sp,16
ffffffffc02086e4:	8082                	ret

ffffffffc02086e6 <vfs_init>:
ffffffffc02086e6:	1141                	addi	sp,sp,-16
ffffffffc02086e8:	4585                	li	a1,1
ffffffffc02086ea:	0008d517          	auipc	a0,0x8d
ffffffffc02086ee:	13e50513          	addi	a0,a0,318 # ffffffffc0295828 <bootfs_sem>
ffffffffc02086f2:	e406                	sd	ra,8(sp)
ffffffffc02086f4:	8d8fc0ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc02086f8:	60a2                	ld	ra,8(sp)
ffffffffc02086fa:	0141                	addi	sp,sp,16
ffffffffc02086fc:	d0cff06f          	j	ffffffffc0207c08 <vfs_devlist_init>

ffffffffc0208700 <vfs_set_bootfs>:
ffffffffc0208700:	7179                	addi	sp,sp,-48
ffffffffc0208702:	f022                	sd	s0,32(sp)
ffffffffc0208704:	f406                	sd	ra,40(sp)
ffffffffc0208706:	ec02                	sd	zero,24(sp)
ffffffffc0208708:	842a                	mv	s0,a0
ffffffffc020870a:	c515                	beqz	a0,ffffffffc0208736 <vfs_set_bootfs+0x36>
ffffffffc020870c:	03a00593          	li	a1,58
ffffffffc0208710:	4c5020ef          	jal	ffffffffc020b3d4 <strchr>
ffffffffc0208714:	c125                	beqz	a0,ffffffffc0208774 <vfs_set_bootfs+0x74>
ffffffffc0208716:	00154783          	lbu	a5,1(a0)
ffffffffc020871a:	efa9                	bnez	a5,ffffffffc0208774 <vfs_set_bootfs+0x74>
ffffffffc020871c:	8522                	mv	a0,s0
ffffffffc020871e:	875ff0ef          	jal	ffffffffc0207f92 <vfs_chdir>
ffffffffc0208722:	c509                	beqz	a0,ffffffffc020872c <vfs_set_bootfs+0x2c>
ffffffffc0208724:	70a2                	ld	ra,40(sp)
ffffffffc0208726:	7402                	ld	s0,32(sp)
ffffffffc0208728:	6145                	addi	sp,sp,48
ffffffffc020872a:	8082                	ret
ffffffffc020872c:	0828                	addi	a0,sp,24
ffffffffc020872e:	f70ff0ef          	jal	ffffffffc0207e9e <vfs_get_curdir>
ffffffffc0208732:	f96d                	bnez	a0,ffffffffc0208724 <vfs_set_bootfs+0x24>
ffffffffc0208734:	6462                	ld	s0,24(sp)
ffffffffc0208736:	0008d517          	auipc	a0,0x8d
ffffffffc020873a:	0f250513          	addi	a0,a0,242 # ffffffffc0295828 <bootfs_sem>
ffffffffc020873e:	89afc0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0208742:	0008e797          	auipc	a5,0x8e
ffffffffc0208746:	1ae7b783          	ld	a5,430(a5) # ffffffffc02968f0 <bootfs_node>
ffffffffc020874a:	0008d517          	auipc	a0,0x8d
ffffffffc020874e:	0de50513          	addi	a0,a0,222 # ffffffffc0295828 <bootfs_sem>
ffffffffc0208752:	0008e717          	auipc	a4,0x8e
ffffffffc0208756:	18873f23          	sd	s0,414(a4) # ffffffffc02968f0 <bootfs_node>
ffffffffc020875a:	e43e                	sd	a5,8(sp)
ffffffffc020875c:	878fc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0208760:	67a2                	ld	a5,8(sp)
ffffffffc0208762:	c781                	beqz	a5,ffffffffc020876a <vfs_set_bootfs+0x6a>
ffffffffc0208764:	853e                	mv	a0,a5
ffffffffc0208766:	c3fff0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020876a:	70a2                	ld	ra,40(sp)
ffffffffc020876c:	7402                	ld	s0,32(sp)
ffffffffc020876e:	4501                	li	a0,0
ffffffffc0208770:	6145                	addi	sp,sp,48
ffffffffc0208772:	8082                	ret
ffffffffc0208774:	5575                	li	a0,-3
ffffffffc0208776:	b77d                	j	ffffffffc0208724 <vfs_set_bootfs+0x24>

ffffffffc0208778 <vfs_get_bootfs>:
ffffffffc0208778:	1101                	addi	sp,sp,-32
ffffffffc020877a:	e426                	sd	s1,8(sp)
ffffffffc020877c:	0008e497          	auipc	s1,0x8e
ffffffffc0208780:	17448493          	addi	s1,s1,372 # ffffffffc02968f0 <bootfs_node>
ffffffffc0208784:	609c                	ld	a5,0(s1)
ffffffffc0208786:	ec06                	sd	ra,24(sp)
ffffffffc0208788:	c3b1                	beqz	a5,ffffffffc02087cc <vfs_get_bootfs+0x54>
ffffffffc020878a:	e822                	sd	s0,16(sp)
ffffffffc020878c:	842a                	mv	s0,a0
ffffffffc020878e:	0008d517          	auipc	a0,0x8d
ffffffffc0208792:	09a50513          	addi	a0,a0,154 # ffffffffc0295828 <bootfs_sem>
ffffffffc0208796:	842fc0ef          	jal	ffffffffc02047d8 <down>
ffffffffc020879a:	6084                	ld	s1,0(s1)
ffffffffc020879c:	c08d                	beqz	s1,ffffffffc02087be <vfs_get_bootfs+0x46>
ffffffffc020879e:	8526                	mv	a0,s1
ffffffffc02087a0:	b37ff0ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc02087a4:	0008d517          	auipc	a0,0x8d
ffffffffc02087a8:	08450513          	addi	a0,a0,132 # ffffffffc0295828 <bootfs_sem>
ffffffffc02087ac:	828fc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc02087b0:	60e2                	ld	ra,24(sp)
ffffffffc02087b2:	e004                	sd	s1,0(s0)
ffffffffc02087b4:	6442                	ld	s0,16(sp)
ffffffffc02087b6:	64a2                	ld	s1,8(sp)
ffffffffc02087b8:	4501                	li	a0,0
ffffffffc02087ba:	6105                	addi	sp,sp,32
ffffffffc02087bc:	8082                	ret
ffffffffc02087be:	0008d517          	auipc	a0,0x8d
ffffffffc02087c2:	06a50513          	addi	a0,a0,106 # ffffffffc0295828 <bootfs_sem>
ffffffffc02087c6:	80efc0ef          	jal	ffffffffc02047d4 <up>
ffffffffc02087ca:	6442                	ld	s0,16(sp)
ffffffffc02087cc:	60e2                	ld	ra,24(sp)
ffffffffc02087ce:	64a2                	ld	s1,8(sp)
ffffffffc02087d0:	5541                	li	a0,-16
ffffffffc02087d2:	6105                	addi	sp,sp,32
ffffffffc02087d4:	8082                	ret

ffffffffc02087d6 <stdin_open>:
ffffffffc02087d6:	e199                	bnez	a1,ffffffffc02087dc <stdin_open+0x6>
ffffffffc02087d8:	4501                	li	a0,0
ffffffffc02087da:	8082                	ret
ffffffffc02087dc:	5575                	li	a0,-3
ffffffffc02087de:	8082                	ret

ffffffffc02087e0 <stdin_close>:
ffffffffc02087e0:	4501                	li	a0,0
ffffffffc02087e2:	8082                	ret

ffffffffc02087e4 <stdin_ioctl>:
ffffffffc02087e4:	5575                	li	a0,-3
ffffffffc02087e6:	8082                	ret

ffffffffc02087e8 <stdin_io>:
ffffffffc02087e8:	14061f63          	bnez	a2,ffffffffc0208946 <stdin_io+0x15e>
ffffffffc02087ec:	7175                	addi	sp,sp,-144
ffffffffc02087ee:	ecd6                	sd	s5,88(sp)
ffffffffc02087f0:	e8da                	sd	s6,80(sp)
ffffffffc02087f2:	e4de                	sd	s7,72(sp)
ffffffffc02087f4:	0185bb03          	ld	s6,24(a1)
ffffffffc02087f8:	0005bb83          	ld	s7,0(a1)
ffffffffc02087fc:	e506                	sd	ra,136(sp)
ffffffffc02087fe:	e122                	sd	s0,128(sp)
ffffffffc0208800:	8aae                	mv	s5,a1
ffffffffc0208802:	100027f3          	csrr	a5,sstatus
ffffffffc0208806:	8b89                	andi	a5,a5,2
ffffffffc0208808:	12079663          	bnez	a5,ffffffffc0208934 <stdin_io+0x14c>
ffffffffc020880c:	4401                	li	s0,0
ffffffffc020880e:	120b0a63          	beqz	s6,ffffffffc0208942 <stdin_io+0x15a>
ffffffffc0208812:	f8ca                	sd	s2,112(sp)
ffffffffc0208814:	0008e917          	auipc	s2,0x8e
ffffffffc0208818:	0ec90913          	addi	s2,s2,236 # ffffffffc0296900 <p_rpos>
ffffffffc020881c:	00093783          	ld	a5,0(s2)
ffffffffc0208820:	fca6                	sd	s1,120(sp)
ffffffffc0208822:	6705                	lui	a4,0x1
ffffffffc0208824:	800004b7          	lui	s1,0x80000
ffffffffc0208828:	f4ce                	sd	s3,104(sp)
ffffffffc020882a:	f0d2                	sd	s4,96(sp)
ffffffffc020882c:	e0e2                	sd	s8,64(sp)
ffffffffc020882e:	0491                	addi	s1,s1,4 # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc0208830:	fff70c13          	addi	s8,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0208834:	4a01                	li	s4,0
ffffffffc0208836:	0008e997          	auipc	s3,0x8e
ffffffffc020883a:	0c298993          	addi	s3,s3,194 # ffffffffc02968f8 <p_wpos>
ffffffffc020883e:	0009b703          	ld	a4,0(s3)
ffffffffc0208842:	02e7d763          	bge	a5,a4,ffffffffc0208870 <stdin_io+0x88>
ffffffffc0208846:	a045                	j	ffffffffc02088e6 <stdin_io+0xfe>
ffffffffc0208848:	c8bfe0ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc020884c:	100027f3          	csrr	a5,sstatus
ffffffffc0208850:	8b89                	andi	a5,a5,2
ffffffffc0208852:	4401                	li	s0,0
ffffffffc0208854:	e3b1                	bnez	a5,ffffffffc0208898 <stdin_io+0xb0>
ffffffffc0208856:	0828                	addi	a0,sp,24
ffffffffc0208858:	cbffb0ef          	jal	ffffffffc0204516 <wait_in_queue>
ffffffffc020885c:	e529                	bnez	a0,ffffffffc02088a6 <stdin_io+0xbe>
ffffffffc020885e:	5782                	lw	a5,32(sp)
ffffffffc0208860:	04979d63          	bne	a5,s1,ffffffffc02088ba <stdin_io+0xd2>
ffffffffc0208864:	00093783          	ld	a5,0(s2)
ffffffffc0208868:	0009b703          	ld	a4,0(s3)
ffffffffc020886c:	06e7cd63          	blt	a5,a4,ffffffffc02088e6 <stdin_io+0xfe>
ffffffffc0208870:	80000637          	lui	a2,0x80000
ffffffffc0208874:	0611                	addi	a2,a2,4 # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc0208876:	082c                	addi	a1,sp,24
ffffffffc0208878:	0008d517          	auipc	a0,0x8d
ffffffffc020887c:	fc850513          	addi	a0,a0,-56 # ffffffffc0295840 <__wait_queue>
ffffffffc0208880:	dc3fb0ef          	jal	ffffffffc0204642 <wait_current_set>
ffffffffc0208884:	d071                	beqz	s0,ffffffffc0208848 <stdin_io+0x60>
ffffffffc0208886:	c76f80ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020888a:	c49fe0ef          	jal	ffffffffc02074d2 <schedule>
ffffffffc020888e:	100027f3          	csrr	a5,sstatus
ffffffffc0208892:	8b89                	andi	a5,a5,2
ffffffffc0208894:	4401                	li	s0,0
ffffffffc0208896:	d3e1                	beqz	a5,ffffffffc0208856 <stdin_io+0x6e>
ffffffffc0208898:	c6af80ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc020889c:	0828                	addi	a0,sp,24
ffffffffc020889e:	4405                	li	s0,1
ffffffffc02088a0:	c77fb0ef          	jal	ffffffffc0204516 <wait_in_queue>
ffffffffc02088a4:	dd4d                	beqz	a0,ffffffffc020885e <stdin_io+0x76>
ffffffffc02088a6:	082c                	addi	a1,sp,24
ffffffffc02088a8:	0008d517          	auipc	a0,0x8d
ffffffffc02088ac:	f9850513          	addi	a0,a0,-104 # ffffffffc0295840 <__wait_queue>
ffffffffc02088b0:	c0dfb0ef          	jal	ffffffffc02044bc <wait_queue_del>
ffffffffc02088b4:	5782                	lw	a5,32(sp)
ffffffffc02088b6:	fa9787e3          	beq	a5,s1,ffffffffc0208864 <stdin_io+0x7c>
ffffffffc02088ba:	000a051b          	sext.w	a0,s4
ffffffffc02088be:	e42d                	bnez	s0,ffffffffc0208928 <stdin_io+0x140>
ffffffffc02088c0:	c519                	beqz	a0,ffffffffc02088ce <stdin_io+0xe6>
ffffffffc02088c2:	018ab783          	ld	a5,24(s5)
ffffffffc02088c6:	414787b3          	sub	a5,a5,s4
ffffffffc02088ca:	00fabc23          	sd	a5,24(s5)
ffffffffc02088ce:	74e6                	ld	s1,120(sp)
ffffffffc02088d0:	7946                	ld	s2,112(sp)
ffffffffc02088d2:	79a6                	ld	s3,104(sp)
ffffffffc02088d4:	7a06                	ld	s4,96(sp)
ffffffffc02088d6:	6c06                	ld	s8,64(sp)
ffffffffc02088d8:	60aa                	ld	ra,136(sp)
ffffffffc02088da:	640a                	ld	s0,128(sp)
ffffffffc02088dc:	6ae6                	ld	s5,88(sp)
ffffffffc02088de:	6b46                	ld	s6,80(sp)
ffffffffc02088e0:	6ba6                	ld	s7,72(sp)
ffffffffc02088e2:	6149                	addi	sp,sp,144
ffffffffc02088e4:	8082                	ret
ffffffffc02088e6:	43f7d693          	srai	a3,a5,0x3f
ffffffffc02088ea:	92d1                	srli	a3,a3,0x34
ffffffffc02088ec:	00d78733          	add	a4,a5,a3
ffffffffc02088f0:	01877733          	and	a4,a4,s8
ffffffffc02088f4:	8f15                	sub	a4,a4,a3
ffffffffc02088f6:	0008d697          	auipc	a3,0x8d
ffffffffc02088fa:	f5a68693          	addi	a3,a3,-166 # ffffffffc0295850 <stdin_buffer>
ffffffffc02088fe:	9736                	add	a4,a4,a3
ffffffffc0208900:	00074683          	lbu	a3,0(a4)
ffffffffc0208904:	0785                	addi	a5,a5,1
ffffffffc0208906:	014b8733          	add	a4,s7,s4
ffffffffc020890a:	001a051b          	addiw	a0,s4,1
ffffffffc020890e:	00f93023          	sd	a5,0(s2)
ffffffffc0208912:	00d70023          	sb	a3,0(a4)
ffffffffc0208916:	0a05                	addi	s4,s4,1
ffffffffc0208918:	f36a63e3          	bltu	s4,s6,ffffffffc020883e <stdin_io+0x56>
ffffffffc020891c:	d05d                	beqz	s0,ffffffffc02088c2 <stdin_io+0xda>
ffffffffc020891e:	e42a                	sd	a0,8(sp)
ffffffffc0208920:	bdcf80ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0208924:	6522                	ld	a0,8(sp)
ffffffffc0208926:	bf71                	j	ffffffffc02088c2 <stdin_io+0xda>
ffffffffc0208928:	e42a                	sd	a0,8(sp)
ffffffffc020892a:	bd2f80ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc020892e:	6522                	ld	a0,8(sp)
ffffffffc0208930:	f949                	bnez	a0,ffffffffc02088c2 <stdin_io+0xda>
ffffffffc0208932:	bf71                	j	ffffffffc02088ce <stdin_io+0xe6>
ffffffffc0208934:	bcef80ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc0208938:	4405                	li	s0,1
ffffffffc020893a:	ec0b1ce3          	bnez	s6,ffffffffc0208812 <stdin_io+0x2a>
ffffffffc020893e:	bbef80ef          	jal	ffffffffc0200cfc <intr_enable>
ffffffffc0208942:	4501                	li	a0,0
ffffffffc0208944:	bf51                	j	ffffffffc02088d8 <stdin_io+0xf0>
ffffffffc0208946:	5575                	li	a0,-3
ffffffffc0208948:	8082                	ret

ffffffffc020894a <dev_stdin_write>:
ffffffffc020894a:	e111                	bnez	a0,ffffffffc020894e <dev_stdin_write+0x4>
ffffffffc020894c:	8082                	ret
ffffffffc020894e:	1101                	addi	sp,sp,-32
ffffffffc0208950:	ec06                	sd	ra,24(sp)
ffffffffc0208952:	e822                	sd	s0,16(sp)
ffffffffc0208954:	100027f3          	csrr	a5,sstatus
ffffffffc0208958:	8b89                	andi	a5,a5,2
ffffffffc020895a:	4401                	li	s0,0
ffffffffc020895c:	e3c1                	bnez	a5,ffffffffc02089dc <dev_stdin_write+0x92>
ffffffffc020895e:	0008e717          	auipc	a4,0x8e
ffffffffc0208962:	f9a73703          	ld	a4,-102(a4) # ffffffffc02968f8 <p_wpos>
ffffffffc0208966:	6585                	lui	a1,0x1
ffffffffc0208968:	fff58613          	addi	a2,a1,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020896c:	43f75693          	srai	a3,a4,0x3f
ffffffffc0208970:	92d1                	srli	a3,a3,0x34
ffffffffc0208972:	00d707b3          	add	a5,a4,a3
ffffffffc0208976:	8ff1                	and	a5,a5,a2
ffffffffc0208978:	0008e617          	auipc	a2,0x8e
ffffffffc020897c:	f8863603          	ld	a2,-120(a2) # ffffffffc0296900 <p_rpos>
ffffffffc0208980:	8f95                	sub	a5,a5,a3
ffffffffc0208982:	0008d697          	auipc	a3,0x8d
ffffffffc0208986:	ece68693          	addi	a3,a3,-306 # ffffffffc0295850 <stdin_buffer>
ffffffffc020898a:	97b6                	add	a5,a5,a3
ffffffffc020898c:	00a78023          	sb	a0,0(a5)
ffffffffc0208990:	40c707b3          	sub	a5,a4,a2
ffffffffc0208994:	00b7d763          	bge	a5,a1,ffffffffc02089a2 <dev_stdin_write+0x58>
ffffffffc0208998:	0705                	addi	a4,a4,1
ffffffffc020899a:	0008e797          	auipc	a5,0x8e
ffffffffc020899e:	f4e7bf23          	sd	a4,-162(a5) # ffffffffc02968f8 <p_wpos>
ffffffffc02089a2:	0008d517          	auipc	a0,0x8d
ffffffffc02089a6:	e9e50513          	addi	a0,a0,-354 # ffffffffc0295840 <__wait_queue>
ffffffffc02089aa:	b61fb0ef          	jal	ffffffffc020450a <wait_queue_empty>
ffffffffc02089ae:	c919                	beqz	a0,ffffffffc02089c4 <dev_stdin_write+0x7a>
ffffffffc02089b0:	e409                	bnez	s0,ffffffffc02089ba <dev_stdin_write+0x70>
ffffffffc02089b2:	60e2                	ld	ra,24(sp)
ffffffffc02089b4:	6442                	ld	s0,16(sp)
ffffffffc02089b6:	6105                	addi	sp,sp,32
ffffffffc02089b8:	8082                	ret
ffffffffc02089ba:	6442                	ld	s0,16(sp)
ffffffffc02089bc:	60e2                	ld	ra,24(sp)
ffffffffc02089be:	6105                	addi	sp,sp,32
ffffffffc02089c0:	b3cf806f          	j	ffffffffc0200cfc <intr_enable>
ffffffffc02089c4:	800005b7          	lui	a1,0x80000
ffffffffc02089c8:	0591                	addi	a1,a1,4 # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc02089ca:	4605                	li	a2,1
ffffffffc02089cc:	0008d517          	auipc	a0,0x8d
ffffffffc02089d0:	e7450513          	addi	a0,a0,-396 # ffffffffc0295840 <__wait_queue>
ffffffffc02089d4:	b9ffb0ef          	jal	ffffffffc0204572 <wakeup_queue>
ffffffffc02089d8:	dc69                	beqz	s0,ffffffffc02089b2 <dev_stdin_write+0x68>
ffffffffc02089da:	b7c5                	j	ffffffffc02089ba <dev_stdin_write+0x70>
ffffffffc02089dc:	e42a                	sd	a0,8(sp)
ffffffffc02089de:	b24f80ef          	jal	ffffffffc0200d02 <intr_disable>
ffffffffc02089e2:	6522                	ld	a0,8(sp)
ffffffffc02089e4:	4405                	li	s0,1
ffffffffc02089e6:	bfa5                	j	ffffffffc020895e <dev_stdin_write+0x14>

ffffffffc02089e8 <dev_init_stdin>:
ffffffffc02089e8:	1101                	addi	sp,sp,-32
ffffffffc02089ea:	ec06                	sd	ra,24(sp)
ffffffffc02089ec:	744000ef          	jal	ffffffffc0209130 <dev_create_inode>
ffffffffc02089f0:	c935                	beqz	a0,ffffffffc0208a64 <dev_init_stdin+0x7c>
ffffffffc02089f2:	4d38                	lw	a4,88(a0)
ffffffffc02089f4:	6785                	lui	a5,0x1
ffffffffc02089f6:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02089fa:	08f71e63          	bne	a4,a5,ffffffffc0208a96 <dev_init_stdin+0xae>
ffffffffc02089fe:	4785                	li	a5,1
ffffffffc0208a00:	e51c                	sd	a5,8(a0)
ffffffffc0208a02:	00000797          	auipc	a5,0x0
ffffffffc0208a06:	dd478793          	addi	a5,a5,-556 # ffffffffc02087d6 <stdin_open>
ffffffffc0208a0a:	e91c                	sd	a5,16(a0)
ffffffffc0208a0c:	00000797          	auipc	a5,0x0
ffffffffc0208a10:	dd478793          	addi	a5,a5,-556 # ffffffffc02087e0 <stdin_close>
ffffffffc0208a14:	ed1c                	sd	a5,24(a0)
ffffffffc0208a16:	00000797          	auipc	a5,0x0
ffffffffc0208a1a:	dd278793          	addi	a5,a5,-558 # ffffffffc02087e8 <stdin_io>
ffffffffc0208a1e:	f11c                	sd	a5,32(a0)
ffffffffc0208a20:	00000797          	auipc	a5,0x0
ffffffffc0208a24:	dc478793          	addi	a5,a5,-572 # ffffffffc02087e4 <stdin_ioctl>
ffffffffc0208a28:	f51c                	sd	a5,40(a0)
ffffffffc0208a2a:	00053023          	sd	zero,0(a0)
ffffffffc0208a2e:	e42a                	sd	a0,8(sp)
ffffffffc0208a30:	0008d517          	auipc	a0,0x8d
ffffffffc0208a34:	e1050513          	addi	a0,a0,-496 # ffffffffc0295840 <__wait_queue>
ffffffffc0208a38:	0008e797          	auipc	a5,0x8e
ffffffffc0208a3c:	ec07b023          	sd	zero,-320(a5) # ffffffffc02968f8 <p_wpos>
ffffffffc0208a40:	0008e797          	auipc	a5,0x8e
ffffffffc0208a44:	ec07b023          	sd	zero,-320(a5) # ffffffffc0296900 <p_rpos>
ffffffffc0208a48:	a6ffb0ef          	jal	ffffffffc02044b6 <wait_queue_init>
ffffffffc0208a4c:	65a2                	ld	a1,8(sp)
ffffffffc0208a4e:	4601                	li	a2,0
ffffffffc0208a50:	00006517          	auipc	a0,0x6
ffffffffc0208a54:	9e050513          	addi	a0,a0,-1568 # ffffffffc020e430 <etext+0x2b5a>
ffffffffc0208a58:	b2aff0ef          	jal	ffffffffc0207d82 <vfs_add_dev>
ffffffffc0208a5c:	e105                	bnez	a0,ffffffffc0208a7c <dev_init_stdin+0x94>
ffffffffc0208a5e:	60e2                	ld	ra,24(sp)
ffffffffc0208a60:	6105                	addi	sp,sp,32
ffffffffc0208a62:	8082                	ret
ffffffffc0208a64:	00006617          	auipc	a2,0x6
ffffffffc0208a68:	98c60613          	addi	a2,a2,-1652 # ffffffffc020e3f0 <etext+0x2b1a>
ffffffffc0208a6c:	07500593          	li	a1,117
ffffffffc0208a70:	00006517          	auipc	a0,0x6
ffffffffc0208a74:	9a050513          	addi	a0,a0,-1632 # ffffffffc020e410 <etext+0x2b3a>
ffffffffc0208a78:	fb4f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208a7c:	86aa                	mv	a3,a0
ffffffffc0208a7e:	00006617          	auipc	a2,0x6
ffffffffc0208a82:	9ba60613          	addi	a2,a2,-1606 # ffffffffc020e438 <etext+0x2b62>
ffffffffc0208a86:	07b00593          	li	a1,123
ffffffffc0208a8a:	00006517          	auipc	a0,0x6
ffffffffc0208a8e:	98650513          	addi	a0,a0,-1658 # ffffffffc020e410 <etext+0x2b3a>
ffffffffc0208a92:	f9af70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208a96:	00005697          	auipc	a3,0x5
ffffffffc0208a9a:	40268693          	addi	a3,a3,1026 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0208a9e:	00003617          	auipc	a2,0x3
ffffffffc0208aa2:	2f260613          	addi	a2,a2,754 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208aa6:	07700593          	li	a1,119
ffffffffc0208aaa:	00006517          	auipc	a0,0x6
ffffffffc0208aae:	96650513          	addi	a0,a0,-1690 # ffffffffc020e410 <etext+0x2b3a>
ffffffffc0208ab2:	f7af70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208ab6 <disk0_open>:
ffffffffc0208ab6:	4501                	li	a0,0
ffffffffc0208ab8:	8082                	ret

ffffffffc0208aba <disk0_close>:
ffffffffc0208aba:	4501                	li	a0,0
ffffffffc0208abc:	8082                	ret

ffffffffc0208abe <disk0_ioctl>:
ffffffffc0208abe:	5531                	li	a0,-20
ffffffffc0208ac0:	8082                	ret

ffffffffc0208ac2 <disk0_io>:
ffffffffc0208ac2:	711d                	addi	sp,sp,-96
ffffffffc0208ac4:	6594                	ld	a3,8(a1)
ffffffffc0208ac6:	e8a2                	sd	s0,80(sp)
ffffffffc0208ac8:	6d80                	ld	s0,24(a1)
ffffffffc0208aca:	6785                	lui	a5,0x1
ffffffffc0208acc:	17fd                	addi	a5,a5,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0208ace:	0086e733          	or	a4,a3,s0
ffffffffc0208ad2:	ec86                	sd	ra,88(sp)
ffffffffc0208ad4:	8f7d                	and	a4,a4,a5
ffffffffc0208ad6:	14071663          	bnez	a4,ffffffffc0208c22 <disk0_io+0x160>
ffffffffc0208ada:	e0ca                	sd	s2,64(sp)
ffffffffc0208adc:	43f6d913          	srai	s2,a3,0x3f
ffffffffc0208ae0:	00f97933          	and	s2,s2,a5
ffffffffc0208ae4:	9936                	add	s2,s2,a3
ffffffffc0208ae6:	40c95913          	srai	s2,s2,0xc
ffffffffc0208aea:	00c45793          	srli	a5,s0,0xc
ffffffffc0208aee:	0127873b          	addw	a4,a5,s2
ffffffffc0208af2:	6114                	ld	a3,0(a0)
ffffffffc0208af4:	1702                	slli	a4,a4,0x20
ffffffffc0208af6:	9301                	srli	a4,a4,0x20
ffffffffc0208af8:	2901                	sext.w	s2,s2
ffffffffc0208afa:	2781                	sext.w	a5,a5
ffffffffc0208afc:	12e6e063          	bltu	a3,a4,ffffffffc0208c1c <disk0_io+0x15a>
ffffffffc0208b00:	e799                	bnez	a5,ffffffffc0208b0e <disk0_io+0x4c>
ffffffffc0208b02:	6906                	ld	s2,64(sp)
ffffffffc0208b04:	4501                	li	a0,0
ffffffffc0208b06:	60e6                	ld	ra,88(sp)
ffffffffc0208b08:	6446                	ld	s0,80(sp)
ffffffffc0208b0a:	6125                	addi	sp,sp,96
ffffffffc0208b0c:	8082                	ret
ffffffffc0208b0e:	0008e517          	auipc	a0,0x8e
ffffffffc0208b12:	d4250513          	addi	a0,a0,-702 # ffffffffc0296850 <disk0_sem>
ffffffffc0208b16:	e4a6                	sd	s1,72(sp)
ffffffffc0208b18:	f852                	sd	s4,48(sp)
ffffffffc0208b1a:	f456                	sd	s5,40(sp)
ffffffffc0208b1c:	84b2                	mv	s1,a2
ffffffffc0208b1e:	8aae                	mv	s5,a1
ffffffffc0208b20:	0008ea17          	auipc	s4,0x8e
ffffffffc0208b24:	de8a0a13          	addi	s4,s4,-536 # ffffffffc0296908 <disk0_buffer>
ffffffffc0208b28:	cb1fb0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0208b2c:	000a3603          	ld	a2,0(s4)
ffffffffc0208b30:	e8ad                	bnez	s1,ffffffffc0208ba2 <disk0_io+0xe0>
ffffffffc0208b32:	e862                	sd	s8,16(sp)
ffffffffc0208b34:	fc4e                	sd	s3,56(sp)
ffffffffc0208b36:	ec5e                	sd	s7,24(sp)
ffffffffc0208b38:	6c11                	lui	s8,0x4
ffffffffc0208b3a:	a029                	j	ffffffffc0208b44 <disk0_io+0x82>
ffffffffc0208b3c:	000a3603          	ld	a2,0(s4)
ffffffffc0208b40:	0129893b          	addw	s2,s3,s2
ffffffffc0208b44:	84a2                	mv	s1,s0
ffffffffc0208b46:	008c7363          	bgeu	s8,s0,ffffffffc0208b4c <disk0_io+0x8a>
ffffffffc0208b4a:	6491                	lui	s1,0x4
ffffffffc0208b4c:	00c4d993          	srli	s3,s1,0xc
ffffffffc0208b50:	2981                	sext.w	s3,s3
ffffffffc0208b52:	00399b9b          	slliw	s7,s3,0x3
ffffffffc0208b56:	020b9693          	slli	a3,s7,0x20
ffffffffc0208b5a:	9281                	srli	a3,a3,0x20
ffffffffc0208b5c:	0039159b          	slliw	a1,s2,0x3
ffffffffc0208b60:	4509                	li	a0,2
ffffffffc0208b62:	866f80ef          	jal	ffffffffc0200bc8 <ide_read_secs>
ffffffffc0208b66:	e16d                	bnez	a0,ffffffffc0208c48 <disk0_io+0x186>
ffffffffc0208b68:	000a3583          	ld	a1,0(s4)
ffffffffc0208b6c:	0038                	addi	a4,sp,8
ffffffffc0208b6e:	4685                	li	a3,1
ffffffffc0208b70:	8626                	mv	a2,s1
ffffffffc0208b72:	8556                	mv	a0,s5
ffffffffc0208b74:	c93fc0ef          	jal	ffffffffc0205806 <iobuf_move>
ffffffffc0208b78:	67a2                	ld	a5,8(sp)
ffffffffc0208b7a:	0a979663          	bne	a5,s1,ffffffffc0208c26 <disk0_io+0x164>
ffffffffc0208b7e:	03449793          	slli	a5,s1,0x34
ffffffffc0208b82:	e3d5                	bnez	a5,ffffffffc0208c26 <disk0_io+0x164>
ffffffffc0208b84:	8c05                	sub	s0,s0,s1
ffffffffc0208b86:	f85d                	bnez	s0,ffffffffc0208b3c <disk0_io+0x7a>
ffffffffc0208b88:	79e2                	ld	s3,56(sp)
ffffffffc0208b8a:	6be2                	ld	s7,24(sp)
ffffffffc0208b8c:	6c42                	ld	s8,16(sp)
ffffffffc0208b8e:	0008e517          	auipc	a0,0x8e
ffffffffc0208b92:	cc250513          	addi	a0,a0,-830 # ffffffffc0296850 <disk0_sem>
ffffffffc0208b96:	c3ffb0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0208b9a:	64a6                	ld	s1,72(sp)
ffffffffc0208b9c:	7a42                	ld	s4,48(sp)
ffffffffc0208b9e:	7aa2                	ld	s5,40(sp)
ffffffffc0208ba0:	b78d                	j	ffffffffc0208b02 <disk0_io+0x40>
ffffffffc0208ba2:	f05a                	sd	s6,32(sp)
ffffffffc0208ba4:	a029                	j	ffffffffc0208bae <disk0_io+0xec>
ffffffffc0208ba6:	000a3603          	ld	a2,0(s4)
ffffffffc0208baa:	0124893b          	addw	s2,s1,s2
ffffffffc0208bae:	85b2                	mv	a1,a2
ffffffffc0208bb0:	0038                	addi	a4,sp,8
ffffffffc0208bb2:	4681                	li	a3,0
ffffffffc0208bb4:	6611                	lui	a2,0x4
ffffffffc0208bb6:	8556                	mv	a0,s5
ffffffffc0208bb8:	c4ffc0ef          	jal	ffffffffc0205806 <iobuf_move>
ffffffffc0208bbc:	67a2                	ld	a5,8(sp)
ffffffffc0208bbe:	fff78713          	addi	a4,a5,-1
ffffffffc0208bc2:	02877a63          	bgeu	a4,s0,ffffffffc0208bf6 <disk0_io+0x134>
ffffffffc0208bc6:	03479713          	slli	a4,a5,0x34
ffffffffc0208bca:	e715                	bnez	a4,ffffffffc0208bf6 <disk0_io+0x134>
ffffffffc0208bcc:	83b1                	srli	a5,a5,0xc
ffffffffc0208bce:	0007849b          	sext.w	s1,a5
ffffffffc0208bd2:	00349b1b          	slliw	s6,s1,0x3
ffffffffc0208bd6:	000a3603          	ld	a2,0(s4)
ffffffffc0208bda:	020b1693          	slli	a3,s6,0x20
ffffffffc0208bde:	9281                	srli	a3,a3,0x20
ffffffffc0208be0:	0039159b          	slliw	a1,s2,0x3
ffffffffc0208be4:	4509                	li	a0,2
ffffffffc0208be6:	87cf80ef          	jal	ffffffffc0200c62 <ide_write_secs>
ffffffffc0208bea:	e151                	bnez	a0,ffffffffc0208c6e <disk0_io+0x1ac>
ffffffffc0208bec:	67a2                	ld	a5,8(sp)
ffffffffc0208bee:	8c1d                	sub	s0,s0,a5
ffffffffc0208bf0:	f85d                	bnez	s0,ffffffffc0208ba6 <disk0_io+0xe4>
ffffffffc0208bf2:	7b02                	ld	s6,32(sp)
ffffffffc0208bf4:	bf69                	j	ffffffffc0208b8e <disk0_io+0xcc>
ffffffffc0208bf6:	00006697          	auipc	a3,0x6
ffffffffc0208bfa:	86268693          	addi	a3,a3,-1950 # ffffffffc020e458 <etext+0x2b82>
ffffffffc0208bfe:	00003617          	auipc	a2,0x3
ffffffffc0208c02:	19260613          	addi	a2,a2,402 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208c06:	05700593          	li	a1,87
ffffffffc0208c0a:	00006517          	auipc	a0,0x6
ffffffffc0208c0e:	88e50513          	addi	a0,a0,-1906 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208c12:	fc4e                	sd	s3,56(sp)
ffffffffc0208c14:	ec5e                	sd	s7,24(sp)
ffffffffc0208c16:	e862                	sd	s8,16(sp)
ffffffffc0208c18:	e14f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208c1c:	6906                	ld	s2,64(sp)
ffffffffc0208c1e:	5575                	li	a0,-3
ffffffffc0208c20:	b5dd                	j	ffffffffc0208b06 <disk0_io+0x44>
ffffffffc0208c22:	5575                	li	a0,-3
ffffffffc0208c24:	b5cd                	j	ffffffffc0208b06 <disk0_io+0x44>
ffffffffc0208c26:	00006697          	auipc	a3,0x6
ffffffffc0208c2a:	92a68693          	addi	a3,a3,-1750 # ffffffffc020e550 <etext+0x2c7a>
ffffffffc0208c2e:	00003617          	auipc	a2,0x3
ffffffffc0208c32:	16260613          	addi	a2,a2,354 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208c36:	06200593          	li	a1,98
ffffffffc0208c3a:	00006517          	auipc	a0,0x6
ffffffffc0208c3e:	85e50513          	addi	a0,a0,-1954 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208c42:	f05a                	sd	s6,32(sp)
ffffffffc0208c44:	de8f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208c48:	88aa                	mv	a7,a0
ffffffffc0208c4a:	885e                	mv	a6,s7
ffffffffc0208c4c:	87ce                	mv	a5,s3
ffffffffc0208c4e:	0039171b          	slliw	a4,s2,0x3
ffffffffc0208c52:	86ca                	mv	a3,s2
ffffffffc0208c54:	00006617          	auipc	a2,0x6
ffffffffc0208c58:	8b460613          	addi	a2,a2,-1868 # ffffffffc020e508 <etext+0x2c32>
ffffffffc0208c5c:	02d00593          	li	a1,45
ffffffffc0208c60:	00006517          	auipc	a0,0x6
ffffffffc0208c64:	83850513          	addi	a0,a0,-1992 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208c68:	f05a                	sd	s6,32(sp)
ffffffffc0208c6a:	dc2f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208c6e:	88aa                	mv	a7,a0
ffffffffc0208c70:	885a                	mv	a6,s6
ffffffffc0208c72:	87a6                	mv	a5,s1
ffffffffc0208c74:	0039171b          	slliw	a4,s2,0x3
ffffffffc0208c78:	86ca                	mv	a3,s2
ffffffffc0208c7a:	00006617          	auipc	a2,0x6
ffffffffc0208c7e:	83e60613          	addi	a2,a2,-1986 # ffffffffc020e4b8 <etext+0x2be2>
ffffffffc0208c82:	03700593          	li	a1,55
ffffffffc0208c86:	00006517          	auipc	a0,0x6
ffffffffc0208c8a:	81250513          	addi	a0,a0,-2030 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208c8e:	fc4e                	sd	s3,56(sp)
ffffffffc0208c90:	ec5e                	sd	s7,24(sp)
ffffffffc0208c92:	e862                	sd	s8,16(sp)
ffffffffc0208c94:	d98f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208c98 <dev_init_disk0>:
ffffffffc0208c98:	1101                	addi	sp,sp,-32
ffffffffc0208c9a:	ec06                	sd	ra,24(sp)
ffffffffc0208c9c:	e822                	sd	s0,16(sp)
ffffffffc0208c9e:	e426                	sd	s1,8(sp)
ffffffffc0208ca0:	490000ef          	jal	ffffffffc0209130 <dev_create_inode>
ffffffffc0208ca4:	c541                	beqz	a0,ffffffffc0208d2c <dev_init_disk0+0x94>
ffffffffc0208ca6:	4d38                	lw	a4,88(a0)
ffffffffc0208ca8:	6785                	lui	a5,0x1
ffffffffc0208caa:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208cae:	842a                	mv	s0,a0
ffffffffc0208cb0:	6485                	lui	s1,0x1
ffffffffc0208cb2:	0cf71e63          	bne	a4,a5,ffffffffc0208d8e <dev_init_disk0+0xf6>
ffffffffc0208cb6:	4509                	li	a0,2
ffffffffc0208cb8:	ec5f70ef          	jal	ffffffffc0200b7c <ide_device_valid>
ffffffffc0208cbc:	cd4d                	beqz	a0,ffffffffc0208d76 <dev_init_disk0+0xde>
ffffffffc0208cbe:	4509                	li	a0,2
ffffffffc0208cc0:	ee1f70ef          	jal	ffffffffc0200ba0 <ide_device_size>
ffffffffc0208cc4:	00000797          	auipc	a5,0x0
ffffffffc0208cc8:	dfa78793          	addi	a5,a5,-518 # ffffffffc0208abe <disk0_ioctl>
ffffffffc0208ccc:	00000617          	auipc	a2,0x0
ffffffffc0208cd0:	dea60613          	addi	a2,a2,-534 # ffffffffc0208ab6 <disk0_open>
ffffffffc0208cd4:	00000697          	auipc	a3,0x0
ffffffffc0208cd8:	de668693          	addi	a3,a3,-538 # ffffffffc0208aba <disk0_close>
ffffffffc0208cdc:	00000717          	auipc	a4,0x0
ffffffffc0208ce0:	de670713          	addi	a4,a4,-538 # ffffffffc0208ac2 <disk0_io>
ffffffffc0208ce4:	810d                	srli	a0,a0,0x3
ffffffffc0208ce6:	f41c                	sd	a5,40(s0)
ffffffffc0208ce8:	e008                	sd	a0,0(s0)
ffffffffc0208cea:	e810                	sd	a2,16(s0)
ffffffffc0208cec:	ec14                	sd	a3,24(s0)
ffffffffc0208cee:	f018                	sd	a4,32(s0)
ffffffffc0208cf0:	4585                	li	a1,1
ffffffffc0208cf2:	0008e517          	auipc	a0,0x8e
ffffffffc0208cf6:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0296850 <disk0_sem>
ffffffffc0208cfa:	e404                	sd	s1,8(s0)
ffffffffc0208cfc:	ad1fb0ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc0208d00:	6511                	lui	a0,0x4
ffffffffc0208d02:	83af90ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0208d06:	0008e797          	auipc	a5,0x8e
ffffffffc0208d0a:	c0a7b123          	sd	a0,-1022(a5) # ffffffffc0296908 <disk0_buffer>
ffffffffc0208d0e:	c921                	beqz	a0,ffffffffc0208d5e <dev_init_disk0+0xc6>
ffffffffc0208d10:	85a2                	mv	a1,s0
ffffffffc0208d12:	4605                	li	a2,1
ffffffffc0208d14:	00006517          	auipc	a0,0x6
ffffffffc0208d18:	8cc50513          	addi	a0,a0,-1844 # ffffffffc020e5e0 <etext+0x2d0a>
ffffffffc0208d1c:	866ff0ef          	jal	ffffffffc0207d82 <vfs_add_dev>
ffffffffc0208d20:	e115                	bnez	a0,ffffffffc0208d44 <dev_init_disk0+0xac>
ffffffffc0208d22:	60e2                	ld	ra,24(sp)
ffffffffc0208d24:	6442                	ld	s0,16(sp)
ffffffffc0208d26:	64a2                	ld	s1,8(sp)
ffffffffc0208d28:	6105                	addi	sp,sp,32
ffffffffc0208d2a:	8082                	ret
ffffffffc0208d2c:	00006617          	auipc	a2,0x6
ffffffffc0208d30:	85460613          	addi	a2,a2,-1964 # ffffffffc020e580 <etext+0x2caa>
ffffffffc0208d34:	08700593          	li	a1,135
ffffffffc0208d38:	00005517          	auipc	a0,0x5
ffffffffc0208d3c:	76050513          	addi	a0,a0,1888 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208d40:	cecf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208d44:	86aa                	mv	a3,a0
ffffffffc0208d46:	00006617          	auipc	a2,0x6
ffffffffc0208d4a:	8a260613          	addi	a2,a2,-1886 # ffffffffc020e5e8 <etext+0x2d12>
ffffffffc0208d4e:	08d00593          	li	a1,141
ffffffffc0208d52:	00005517          	auipc	a0,0x5
ffffffffc0208d56:	74650513          	addi	a0,a0,1862 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208d5a:	cd2f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208d5e:	00006617          	auipc	a2,0x6
ffffffffc0208d62:	86260613          	addi	a2,a2,-1950 # ffffffffc020e5c0 <etext+0x2cea>
ffffffffc0208d66:	07f00593          	li	a1,127
ffffffffc0208d6a:	00005517          	auipc	a0,0x5
ffffffffc0208d6e:	72e50513          	addi	a0,a0,1838 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208d72:	cbaf70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208d76:	00006617          	auipc	a2,0x6
ffffffffc0208d7a:	82a60613          	addi	a2,a2,-2006 # ffffffffc020e5a0 <etext+0x2cca>
ffffffffc0208d7e:	07300593          	li	a1,115
ffffffffc0208d82:	00005517          	auipc	a0,0x5
ffffffffc0208d86:	71650513          	addi	a0,a0,1814 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208d8a:	ca2f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208d8e:	00005697          	auipc	a3,0x5
ffffffffc0208d92:	10a68693          	addi	a3,a3,266 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0208d96:	00003617          	auipc	a2,0x3
ffffffffc0208d9a:	ffa60613          	addi	a2,a2,-6 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208d9e:	08900593          	li	a1,137
ffffffffc0208da2:	00005517          	auipc	a0,0x5
ffffffffc0208da6:	6f650513          	addi	a0,a0,1782 # ffffffffc020e498 <etext+0x2bc2>
ffffffffc0208daa:	c82f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208dae <stdout_open>:
ffffffffc0208dae:	4785                	li	a5,1
ffffffffc0208db0:	00f59463          	bne	a1,a5,ffffffffc0208db8 <stdout_open+0xa>
ffffffffc0208db4:	4501                	li	a0,0
ffffffffc0208db6:	8082                	ret
ffffffffc0208db8:	5575                	li	a0,-3
ffffffffc0208dba:	8082                	ret

ffffffffc0208dbc <stdout_close>:
ffffffffc0208dbc:	4501                	li	a0,0
ffffffffc0208dbe:	8082                	ret

ffffffffc0208dc0 <stdout_ioctl>:
ffffffffc0208dc0:	5575                	li	a0,-3
ffffffffc0208dc2:	8082                	ret

ffffffffc0208dc4 <stdout_io>:
ffffffffc0208dc4:	ca15                	beqz	a2,ffffffffc0208df8 <stdout_io+0x34>
ffffffffc0208dc6:	6d9c                	ld	a5,24(a1)
ffffffffc0208dc8:	c795                	beqz	a5,ffffffffc0208df4 <stdout_io+0x30>
ffffffffc0208dca:	1101                	addi	sp,sp,-32
ffffffffc0208dcc:	e822                	sd	s0,16(sp)
ffffffffc0208dce:	6180                	ld	s0,0(a1)
ffffffffc0208dd0:	e426                	sd	s1,8(sp)
ffffffffc0208dd2:	ec06                	sd	ra,24(sp)
ffffffffc0208dd4:	84ae                	mv	s1,a1
ffffffffc0208dd6:	00044503          	lbu	a0,0(s0)
ffffffffc0208dda:	0405                	addi	s0,s0,1
ffffffffc0208ddc:	b86f70ef          	jal	ffffffffc0200162 <cputchar>
ffffffffc0208de0:	6c9c                	ld	a5,24(s1)
ffffffffc0208de2:	17fd                	addi	a5,a5,-1
ffffffffc0208de4:	ec9c                	sd	a5,24(s1)
ffffffffc0208de6:	fbe5                	bnez	a5,ffffffffc0208dd6 <stdout_io+0x12>
ffffffffc0208de8:	60e2                	ld	ra,24(sp)
ffffffffc0208dea:	6442                	ld	s0,16(sp)
ffffffffc0208dec:	64a2                	ld	s1,8(sp)
ffffffffc0208dee:	4501                	li	a0,0
ffffffffc0208df0:	6105                	addi	sp,sp,32
ffffffffc0208df2:	8082                	ret
ffffffffc0208df4:	4501                	li	a0,0
ffffffffc0208df6:	8082                	ret
ffffffffc0208df8:	5575                	li	a0,-3
ffffffffc0208dfa:	8082                	ret

ffffffffc0208dfc <dev_init_stdout>:
ffffffffc0208dfc:	1141                	addi	sp,sp,-16
ffffffffc0208dfe:	e406                	sd	ra,8(sp)
ffffffffc0208e00:	330000ef          	jal	ffffffffc0209130 <dev_create_inode>
ffffffffc0208e04:	c939                	beqz	a0,ffffffffc0208e5a <dev_init_stdout+0x5e>
ffffffffc0208e06:	4d38                	lw	a4,88(a0)
ffffffffc0208e08:	6785                	lui	a5,0x1
ffffffffc0208e0a:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208e0e:	06f71f63          	bne	a4,a5,ffffffffc0208e8c <dev_init_stdout+0x90>
ffffffffc0208e12:	4785                	li	a5,1
ffffffffc0208e14:	e51c                	sd	a5,8(a0)
ffffffffc0208e16:	00000797          	auipc	a5,0x0
ffffffffc0208e1a:	f9878793          	addi	a5,a5,-104 # ffffffffc0208dae <stdout_open>
ffffffffc0208e1e:	e91c                	sd	a5,16(a0)
ffffffffc0208e20:	00000797          	auipc	a5,0x0
ffffffffc0208e24:	f9c78793          	addi	a5,a5,-100 # ffffffffc0208dbc <stdout_close>
ffffffffc0208e28:	ed1c                	sd	a5,24(a0)
ffffffffc0208e2a:	00000797          	auipc	a5,0x0
ffffffffc0208e2e:	f9a78793          	addi	a5,a5,-102 # ffffffffc0208dc4 <stdout_io>
ffffffffc0208e32:	f11c                	sd	a5,32(a0)
ffffffffc0208e34:	00000797          	auipc	a5,0x0
ffffffffc0208e38:	f8c78793          	addi	a5,a5,-116 # ffffffffc0208dc0 <stdout_ioctl>
ffffffffc0208e3c:	f51c                	sd	a5,40(a0)
ffffffffc0208e3e:	00053023          	sd	zero,0(a0)
ffffffffc0208e42:	85aa                	mv	a1,a0
ffffffffc0208e44:	4601                	li	a2,0
ffffffffc0208e46:	00006517          	auipc	a0,0x6
ffffffffc0208e4a:	80250513          	addi	a0,a0,-2046 # ffffffffc020e648 <etext+0x2d72>
ffffffffc0208e4e:	f35fe0ef          	jal	ffffffffc0207d82 <vfs_add_dev>
ffffffffc0208e52:	e105                	bnez	a0,ffffffffc0208e72 <dev_init_stdout+0x76>
ffffffffc0208e54:	60a2                	ld	ra,8(sp)
ffffffffc0208e56:	0141                	addi	sp,sp,16
ffffffffc0208e58:	8082                	ret
ffffffffc0208e5a:	00005617          	auipc	a2,0x5
ffffffffc0208e5e:	7ae60613          	addi	a2,a2,1966 # ffffffffc020e608 <etext+0x2d32>
ffffffffc0208e62:	03700593          	li	a1,55
ffffffffc0208e66:	00005517          	auipc	a0,0x5
ffffffffc0208e6a:	7c250513          	addi	a0,a0,1986 # ffffffffc020e628 <etext+0x2d52>
ffffffffc0208e6e:	bbef70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208e72:	86aa                	mv	a3,a0
ffffffffc0208e74:	00005617          	auipc	a2,0x5
ffffffffc0208e78:	7dc60613          	addi	a2,a2,2012 # ffffffffc020e650 <etext+0x2d7a>
ffffffffc0208e7c:	03d00593          	li	a1,61
ffffffffc0208e80:	00005517          	auipc	a0,0x5
ffffffffc0208e84:	7a850513          	addi	a0,a0,1960 # ffffffffc020e628 <etext+0x2d52>
ffffffffc0208e88:	ba4f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208e8c:	00005697          	auipc	a3,0x5
ffffffffc0208e90:	00c68693          	addi	a3,a3,12 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0208e94:	00003617          	auipc	a2,0x3
ffffffffc0208e98:	efc60613          	addi	a2,a2,-260 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208e9c:	03900593          	li	a1,57
ffffffffc0208ea0:	00005517          	auipc	a0,0x5
ffffffffc0208ea4:	78850513          	addi	a0,a0,1928 # ffffffffc020e628 <etext+0x2d52>
ffffffffc0208ea8:	b84f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208eac <dev_lookup>:
ffffffffc0208eac:	0005c703          	lbu	a4,0(a1)
ffffffffc0208eb0:	ef11                	bnez	a4,ffffffffc0208ecc <dev_lookup+0x20>
ffffffffc0208eb2:	1101                	addi	sp,sp,-32
ffffffffc0208eb4:	ec06                	sd	ra,24(sp)
ffffffffc0208eb6:	e032                	sd	a2,0(sp)
ffffffffc0208eb8:	e42a                	sd	a0,8(sp)
ffffffffc0208eba:	c1cff0ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc0208ebe:	6602                	ld	a2,0(sp)
ffffffffc0208ec0:	67a2                	ld	a5,8(sp)
ffffffffc0208ec2:	60e2                	ld	ra,24(sp)
ffffffffc0208ec4:	4501                	li	a0,0
ffffffffc0208ec6:	e21c                	sd	a5,0(a2)
ffffffffc0208ec8:	6105                	addi	sp,sp,32
ffffffffc0208eca:	8082                	ret
ffffffffc0208ecc:	5541                	li	a0,-16
ffffffffc0208ece:	8082                	ret

ffffffffc0208ed0 <dev_fstat>:
ffffffffc0208ed0:	1101                	addi	sp,sp,-32
ffffffffc0208ed2:	e822                	sd	s0,16(sp)
ffffffffc0208ed4:	e426                	sd	s1,8(sp)
ffffffffc0208ed6:	842a                	mv	s0,a0
ffffffffc0208ed8:	84ae                	mv	s1,a1
ffffffffc0208eda:	852e                	mv	a0,a1
ffffffffc0208edc:	02000613          	li	a2,32
ffffffffc0208ee0:	4581                	li	a1,0
ffffffffc0208ee2:	ec06                	sd	ra,24(sp)
ffffffffc0208ee4:	502020ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0208ee8:	c429                	beqz	s0,ffffffffc0208f32 <dev_fstat+0x62>
ffffffffc0208eea:	783c                	ld	a5,112(s0)
ffffffffc0208eec:	c3b9                	beqz	a5,ffffffffc0208f32 <dev_fstat+0x62>
ffffffffc0208eee:	6bbc                	ld	a5,80(a5)
ffffffffc0208ef0:	c3a9                	beqz	a5,ffffffffc0208f32 <dev_fstat+0x62>
ffffffffc0208ef2:	00005597          	auipc	a1,0x5
ffffffffc0208ef6:	06e58593          	addi	a1,a1,110 # ffffffffc020df60 <etext+0x268a>
ffffffffc0208efa:	8522                	mv	a0,s0
ffffffffc0208efc:	beeff0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0208f00:	783c                	ld	a5,112(s0)
ffffffffc0208f02:	85a6                	mv	a1,s1
ffffffffc0208f04:	8522                	mv	a0,s0
ffffffffc0208f06:	6bbc                	ld	a5,80(a5)
ffffffffc0208f08:	9782                	jalr	a5
ffffffffc0208f0a:	ed19                	bnez	a0,ffffffffc0208f28 <dev_fstat+0x58>
ffffffffc0208f0c:	4c38                	lw	a4,88(s0)
ffffffffc0208f0e:	6785                	lui	a5,0x1
ffffffffc0208f10:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f14:	02f71f63          	bne	a4,a5,ffffffffc0208f52 <dev_fstat+0x82>
ffffffffc0208f18:	6018                	ld	a4,0(s0)
ffffffffc0208f1a:	641c                	ld	a5,8(s0)
ffffffffc0208f1c:	4685                	li	a3,1
ffffffffc0208f1e:	e898                	sd	a4,16(s1)
ffffffffc0208f20:	02e787b3          	mul	a5,a5,a4
ffffffffc0208f24:	e494                	sd	a3,8(s1)
ffffffffc0208f26:	ec9c                	sd	a5,24(s1)
ffffffffc0208f28:	60e2                	ld	ra,24(sp)
ffffffffc0208f2a:	6442                	ld	s0,16(sp)
ffffffffc0208f2c:	64a2                	ld	s1,8(sp)
ffffffffc0208f2e:	6105                	addi	sp,sp,32
ffffffffc0208f30:	8082                	ret
ffffffffc0208f32:	00005697          	auipc	a3,0x5
ffffffffc0208f36:	fc668693          	addi	a3,a3,-58 # ffffffffc020def8 <etext+0x2622>
ffffffffc0208f3a:	00003617          	auipc	a2,0x3
ffffffffc0208f3e:	e5660613          	addi	a2,a2,-426 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208f42:	04200593          	li	a1,66
ffffffffc0208f46:	00005517          	auipc	a0,0x5
ffffffffc0208f4a:	72a50513          	addi	a0,a0,1834 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc0208f4e:	adef70ef          	jal	ffffffffc020022c <__panic>
ffffffffc0208f52:	00005697          	auipc	a3,0x5
ffffffffc0208f56:	f4668693          	addi	a3,a3,-186 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0208f5a:	00003617          	auipc	a2,0x3
ffffffffc0208f5e:	e3660613          	addi	a2,a2,-458 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208f62:	04500593          	li	a1,69
ffffffffc0208f66:	00005517          	auipc	a0,0x5
ffffffffc0208f6a:	70a50513          	addi	a0,a0,1802 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc0208f6e:	abef70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208f72 <dev_ioctl>:
ffffffffc0208f72:	c909                	beqz	a0,ffffffffc0208f84 <dev_ioctl+0x12>
ffffffffc0208f74:	4d34                	lw	a3,88(a0)
ffffffffc0208f76:	6705                	lui	a4,0x1
ffffffffc0208f78:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f7c:	00e69463          	bne	a3,a4,ffffffffc0208f84 <dev_ioctl+0x12>
ffffffffc0208f80:	751c                	ld	a5,40(a0)
ffffffffc0208f82:	8782                	jr	a5
ffffffffc0208f84:	1141                	addi	sp,sp,-16
ffffffffc0208f86:	00005697          	auipc	a3,0x5
ffffffffc0208f8a:	f1268693          	addi	a3,a3,-238 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0208f8e:	00003617          	auipc	a2,0x3
ffffffffc0208f92:	e0260613          	addi	a2,a2,-510 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208f96:	03500593          	li	a1,53
ffffffffc0208f9a:	00005517          	auipc	a0,0x5
ffffffffc0208f9e:	6d650513          	addi	a0,a0,1750 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc0208fa2:	e406                	sd	ra,8(sp)
ffffffffc0208fa4:	a88f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208fa8 <dev_tryseek>:
ffffffffc0208fa8:	c51d                	beqz	a0,ffffffffc0208fd6 <dev_tryseek+0x2e>
ffffffffc0208faa:	4d38                	lw	a4,88(a0)
ffffffffc0208fac:	6785                	lui	a5,0x1
ffffffffc0208fae:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208fb2:	02f71263          	bne	a4,a5,ffffffffc0208fd6 <dev_tryseek+0x2e>
ffffffffc0208fb6:	611c                	ld	a5,0(a0)
ffffffffc0208fb8:	cf89                	beqz	a5,ffffffffc0208fd2 <dev_tryseek+0x2a>
ffffffffc0208fba:	6518                	ld	a4,8(a0)
ffffffffc0208fbc:	02e5f6b3          	remu	a3,a1,a4
ffffffffc0208fc0:	ea89                	bnez	a3,ffffffffc0208fd2 <dev_tryseek+0x2a>
ffffffffc0208fc2:	0005c863          	bltz	a1,ffffffffc0208fd2 <dev_tryseek+0x2a>
ffffffffc0208fc6:	02e787b3          	mul	a5,a5,a4
ffffffffc0208fca:	4501                	li	a0,0
ffffffffc0208fcc:	00f5f363          	bgeu	a1,a5,ffffffffc0208fd2 <dev_tryseek+0x2a>
ffffffffc0208fd0:	8082                	ret
ffffffffc0208fd2:	5575                	li	a0,-3
ffffffffc0208fd4:	8082                	ret
ffffffffc0208fd6:	1141                	addi	sp,sp,-16
ffffffffc0208fd8:	00005697          	auipc	a3,0x5
ffffffffc0208fdc:	ec068693          	addi	a3,a3,-320 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0208fe0:	00003617          	auipc	a2,0x3
ffffffffc0208fe4:	db060613          	addi	a2,a2,-592 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0208fe8:	05f00593          	li	a1,95
ffffffffc0208fec:	00005517          	auipc	a0,0x5
ffffffffc0208ff0:	68450513          	addi	a0,a0,1668 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc0208ff4:	e406                	sd	ra,8(sp)
ffffffffc0208ff6:	a36f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0208ffa <dev_gettype>:
ffffffffc0208ffa:	cd11                	beqz	a0,ffffffffc0209016 <dev_gettype+0x1c>
ffffffffc0208ffc:	4d38                	lw	a4,88(a0)
ffffffffc0208ffe:	6785                	lui	a5,0x1
ffffffffc0209000:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0209004:	00f71963          	bne	a4,a5,ffffffffc0209016 <dev_gettype+0x1c>
ffffffffc0209008:	6118                	ld	a4,0(a0)
ffffffffc020900a:	6791                	lui	a5,0x4
ffffffffc020900c:	c311                	beqz	a4,ffffffffc0209010 <dev_gettype+0x16>
ffffffffc020900e:	6795                	lui	a5,0x5
ffffffffc0209010:	c19c                	sw	a5,0(a1)
ffffffffc0209012:	4501                	li	a0,0
ffffffffc0209014:	8082                	ret
ffffffffc0209016:	1141                	addi	sp,sp,-16
ffffffffc0209018:	00005697          	auipc	a3,0x5
ffffffffc020901c:	e8068693          	addi	a3,a3,-384 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0209020:	00003617          	auipc	a2,0x3
ffffffffc0209024:	d7060613          	addi	a2,a2,-656 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209028:	05300593          	li	a1,83
ffffffffc020902c:	00005517          	auipc	a0,0x5
ffffffffc0209030:	64450513          	addi	a0,a0,1604 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc0209034:	e406                	sd	ra,8(sp)
ffffffffc0209036:	9f6f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc020903a <dev_write>:
ffffffffc020903a:	c911                	beqz	a0,ffffffffc020904e <dev_write+0x14>
ffffffffc020903c:	4d34                	lw	a3,88(a0)
ffffffffc020903e:	6705                	lui	a4,0x1
ffffffffc0209040:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0209044:	00e69563          	bne	a3,a4,ffffffffc020904e <dev_write+0x14>
ffffffffc0209048:	711c                	ld	a5,32(a0)
ffffffffc020904a:	4605                	li	a2,1
ffffffffc020904c:	8782                	jr	a5
ffffffffc020904e:	1141                	addi	sp,sp,-16
ffffffffc0209050:	00005697          	auipc	a3,0x5
ffffffffc0209054:	e4868693          	addi	a3,a3,-440 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0209058:	00003617          	auipc	a2,0x3
ffffffffc020905c:	d3860613          	addi	a2,a2,-712 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209060:	02c00593          	li	a1,44
ffffffffc0209064:	00005517          	auipc	a0,0x5
ffffffffc0209068:	60c50513          	addi	a0,a0,1548 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc020906c:	e406                	sd	ra,8(sp)
ffffffffc020906e:	9bef70ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209072 <dev_read>:
ffffffffc0209072:	c911                	beqz	a0,ffffffffc0209086 <dev_read+0x14>
ffffffffc0209074:	4d34                	lw	a3,88(a0)
ffffffffc0209076:	6705                	lui	a4,0x1
ffffffffc0209078:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020907c:	00e69563          	bne	a3,a4,ffffffffc0209086 <dev_read+0x14>
ffffffffc0209080:	711c                	ld	a5,32(a0)
ffffffffc0209082:	4601                	li	a2,0
ffffffffc0209084:	8782                	jr	a5
ffffffffc0209086:	1141                	addi	sp,sp,-16
ffffffffc0209088:	00005697          	auipc	a3,0x5
ffffffffc020908c:	e1068693          	addi	a3,a3,-496 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0209090:	00003617          	auipc	a2,0x3
ffffffffc0209094:	d0060613          	addi	a2,a2,-768 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209098:	02300593          	li	a1,35
ffffffffc020909c:	00005517          	auipc	a0,0x5
ffffffffc02090a0:	5d450513          	addi	a0,a0,1492 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc02090a4:	e406                	sd	ra,8(sp)
ffffffffc02090a6:	986f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc02090aa <dev_close>:
ffffffffc02090aa:	c909                	beqz	a0,ffffffffc02090bc <dev_close+0x12>
ffffffffc02090ac:	4d34                	lw	a3,88(a0)
ffffffffc02090ae:	6705                	lui	a4,0x1
ffffffffc02090b0:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02090b4:	00e69463          	bne	a3,a4,ffffffffc02090bc <dev_close+0x12>
ffffffffc02090b8:	6d1c                	ld	a5,24(a0)
ffffffffc02090ba:	8782                	jr	a5
ffffffffc02090bc:	1141                	addi	sp,sp,-16
ffffffffc02090be:	00005697          	auipc	a3,0x5
ffffffffc02090c2:	dda68693          	addi	a3,a3,-550 # ffffffffc020de98 <etext+0x25c2>
ffffffffc02090c6:	00003617          	auipc	a2,0x3
ffffffffc02090ca:	cca60613          	addi	a2,a2,-822 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02090ce:	45e9                	li	a1,26
ffffffffc02090d0:	00005517          	auipc	a0,0x5
ffffffffc02090d4:	5a050513          	addi	a0,a0,1440 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc02090d8:	e406                	sd	ra,8(sp)
ffffffffc02090da:	952f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc02090de <dev_open>:
ffffffffc02090de:	03c5f793          	andi	a5,a1,60
ffffffffc02090e2:	eb91                	bnez	a5,ffffffffc02090f6 <dev_open+0x18>
ffffffffc02090e4:	c919                	beqz	a0,ffffffffc02090fa <dev_open+0x1c>
ffffffffc02090e6:	4d34                	lw	a3,88(a0)
ffffffffc02090e8:	6785                	lui	a5,0x1
ffffffffc02090ea:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02090ee:	00f69663          	bne	a3,a5,ffffffffc02090fa <dev_open+0x1c>
ffffffffc02090f2:	691c                	ld	a5,16(a0)
ffffffffc02090f4:	8782                	jr	a5
ffffffffc02090f6:	5575                	li	a0,-3
ffffffffc02090f8:	8082                	ret
ffffffffc02090fa:	1141                	addi	sp,sp,-16
ffffffffc02090fc:	00005697          	auipc	a3,0x5
ffffffffc0209100:	d9c68693          	addi	a3,a3,-612 # ffffffffc020de98 <etext+0x25c2>
ffffffffc0209104:	00003617          	auipc	a2,0x3
ffffffffc0209108:	c8c60613          	addi	a2,a2,-884 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020910c:	45c5                	li	a1,17
ffffffffc020910e:	00005517          	auipc	a0,0x5
ffffffffc0209112:	56250513          	addi	a0,a0,1378 # ffffffffc020e670 <etext+0x2d9a>
ffffffffc0209116:	e406                	sd	ra,8(sp)
ffffffffc0209118:	914f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc020911c <dev_init>:
ffffffffc020911c:	1141                	addi	sp,sp,-16
ffffffffc020911e:	e406                	sd	ra,8(sp)
ffffffffc0209120:	8c9ff0ef          	jal	ffffffffc02089e8 <dev_init_stdin>
ffffffffc0209124:	cd9ff0ef          	jal	ffffffffc0208dfc <dev_init_stdout>
ffffffffc0209128:	60a2                	ld	ra,8(sp)
ffffffffc020912a:	0141                	addi	sp,sp,16
ffffffffc020912c:	b6dff06f          	j	ffffffffc0208c98 <dev_init_disk0>

ffffffffc0209130 <dev_create_inode>:
ffffffffc0209130:	6505                	lui	a0,0x1
ffffffffc0209132:	1101                	addi	sp,sp,-32
ffffffffc0209134:	23450513          	addi	a0,a0,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0209138:	ec06                	sd	ra,24(sp)
ffffffffc020913a:	91eff0ef          	jal	ffffffffc0208258 <__alloc_inode>
ffffffffc020913e:	87aa                	mv	a5,a0
ffffffffc0209140:	c911                	beqz	a0,ffffffffc0209154 <dev_create_inode+0x24>
ffffffffc0209142:	4601                	li	a2,0
ffffffffc0209144:	00006597          	auipc	a1,0x6
ffffffffc0209148:	6cc58593          	addi	a1,a1,1740 # ffffffffc020f810 <dev_node_ops>
ffffffffc020914c:	e42a                	sd	a0,8(sp)
ffffffffc020914e:	926ff0ef          	jal	ffffffffc0208274 <inode_init>
ffffffffc0209152:	67a2                	ld	a5,8(sp)
ffffffffc0209154:	60e2                	ld	ra,24(sp)
ffffffffc0209156:	853e                	mv	a0,a5
ffffffffc0209158:	6105                	addi	sp,sp,32
ffffffffc020915a:	8082                	ret

ffffffffc020915c <sfs_init>:
ffffffffc020915c:	1141                	addi	sp,sp,-16
ffffffffc020915e:	00005517          	auipc	a0,0x5
ffffffffc0209162:	48250513          	addi	a0,a0,1154 # ffffffffc020e5e0 <etext+0x2d0a>
ffffffffc0209166:	e406                	sd	ra,8(sp)
ffffffffc0209168:	403010ef          	jal	ffffffffc020ad6a <sfs_mount>
ffffffffc020916c:	e501                	bnez	a0,ffffffffc0209174 <sfs_init+0x18>
ffffffffc020916e:	60a2                	ld	ra,8(sp)
ffffffffc0209170:	0141                	addi	sp,sp,16
ffffffffc0209172:	8082                	ret
ffffffffc0209174:	86aa                	mv	a3,a0
ffffffffc0209176:	00005617          	auipc	a2,0x5
ffffffffc020917a:	51260613          	addi	a2,a2,1298 # ffffffffc020e688 <etext+0x2db2>
ffffffffc020917e:	45c1                	li	a1,16
ffffffffc0209180:	00005517          	auipc	a0,0x5
ffffffffc0209184:	52850513          	addi	a0,a0,1320 # ffffffffc020e6a8 <etext+0x2dd2>
ffffffffc0209188:	8a4f70ef          	jal	ffffffffc020022c <__panic>

ffffffffc020918c <lock_sfs_fs>:
ffffffffc020918c:	05050513          	addi	a0,a0,80
ffffffffc0209190:	e48fb06f          	j	ffffffffc02047d8 <down>

ffffffffc0209194 <lock_sfs_io>:
ffffffffc0209194:	06850513          	addi	a0,a0,104
ffffffffc0209198:	e40fb06f          	j	ffffffffc02047d8 <down>

ffffffffc020919c <unlock_sfs_fs>:
ffffffffc020919c:	05050513          	addi	a0,a0,80
ffffffffc02091a0:	e34fb06f          	j	ffffffffc02047d4 <up>

ffffffffc02091a4 <unlock_sfs_io>:
ffffffffc02091a4:	06850513          	addi	a0,a0,104
ffffffffc02091a8:	e2cfb06f          	j	ffffffffc02047d4 <up>

ffffffffc02091ac <sfs_opendir>:
ffffffffc02091ac:	0235f593          	andi	a1,a1,35
ffffffffc02091b0:	e199                	bnez	a1,ffffffffc02091b6 <sfs_opendir+0xa>
ffffffffc02091b2:	4501                	li	a0,0
ffffffffc02091b4:	8082                	ret
ffffffffc02091b6:	553d                	li	a0,-17
ffffffffc02091b8:	8082                	ret

ffffffffc02091ba <sfs_openfile>:
ffffffffc02091ba:	4501                	li	a0,0
ffffffffc02091bc:	8082                	ret

ffffffffc02091be <sfs_gettype>:
ffffffffc02091be:	1141                	addi	sp,sp,-16
ffffffffc02091c0:	e406                	sd	ra,8(sp)
ffffffffc02091c2:	c529                	beqz	a0,ffffffffc020920c <sfs_gettype+0x4e>
ffffffffc02091c4:	4d38                	lw	a4,88(a0)
ffffffffc02091c6:	6785                	lui	a5,0x1
ffffffffc02091c8:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02091cc:	04f71063          	bne	a4,a5,ffffffffc020920c <sfs_gettype+0x4e>
ffffffffc02091d0:	6118                	ld	a4,0(a0)
ffffffffc02091d2:	4789                	li	a5,2
ffffffffc02091d4:	00475683          	lhu	a3,4(a4)
ffffffffc02091d8:	02f68463          	beq	a3,a5,ffffffffc0209200 <sfs_gettype+0x42>
ffffffffc02091dc:	478d                	li	a5,3
ffffffffc02091de:	00f68b63          	beq	a3,a5,ffffffffc02091f4 <sfs_gettype+0x36>
ffffffffc02091e2:	4705                	li	a4,1
ffffffffc02091e4:	6785                	lui	a5,0x1
ffffffffc02091e6:	04e69363          	bne	a3,a4,ffffffffc020922c <sfs_gettype+0x6e>
ffffffffc02091ea:	60a2                	ld	ra,8(sp)
ffffffffc02091ec:	c19c                	sw	a5,0(a1)
ffffffffc02091ee:	4501                	li	a0,0
ffffffffc02091f0:	0141                	addi	sp,sp,16
ffffffffc02091f2:	8082                	ret
ffffffffc02091f4:	60a2                	ld	ra,8(sp)
ffffffffc02091f6:	678d                	lui	a5,0x3
ffffffffc02091f8:	c19c                	sw	a5,0(a1)
ffffffffc02091fa:	4501                	li	a0,0
ffffffffc02091fc:	0141                	addi	sp,sp,16
ffffffffc02091fe:	8082                	ret
ffffffffc0209200:	60a2                	ld	ra,8(sp)
ffffffffc0209202:	6789                	lui	a5,0x2
ffffffffc0209204:	c19c                	sw	a5,0(a1)
ffffffffc0209206:	4501                	li	a0,0
ffffffffc0209208:	0141                	addi	sp,sp,16
ffffffffc020920a:	8082                	ret
ffffffffc020920c:	00005697          	auipc	a3,0x5
ffffffffc0209210:	4b468693          	addi	a3,a3,1204 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc0209214:	00003617          	auipc	a2,0x3
ffffffffc0209218:	b7c60613          	addi	a2,a2,-1156 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020921c:	38800593          	li	a1,904
ffffffffc0209220:	00005517          	auipc	a0,0x5
ffffffffc0209224:	4d850513          	addi	a0,a0,1240 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209228:	804f70ef          	jal	ffffffffc020022c <__panic>
ffffffffc020922c:	00005617          	auipc	a2,0x5
ffffffffc0209230:	4e460613          	addi	a2,a2,1252 # ffffffffc020e710 <etext+0x2e3a>
ffffffffc0209234:	39400593          	li	a1,916
ffffffffc0209238:	00005517          	auipc	a0,0x5
ffffffffc020923c:	4c050513          	addi	a0,a0,1216 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209240:	fedf60ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209244 <sfs_fsync>:
ffffffffc0209244:	7530                	ld	a2,104(a0)
ffffffffc0209246:	7179                	addi	sp,sp,-48
ffffffffc0209248:	f406                	sd	ra,40(sp)
ffffffffc020924a:	ca2d                	beqz	a2,ffffffffc02092bc <sfs_fsync+0x78>
ffffffffc020924c:	0b062703          	lw	a4,176(a2)
ffffffffc0209250:	e735                	bnez	a4,ffffffffc02092bc <sfs_fsync+0x78>
ffffffffc0209252:	4d34                	lw	a3,88(a0)
ffffffffc0209254:	6705                	lui	a4,0x1
ffffffffc0209256:	23570713          	addi	a4,a4,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020925a:	08e69263          	bne	a3,a4,ffffffffc02092de <sfs_fsync+0x9a>
ffffffffc020925e:	6914                	ld	a3,16(a0)
ffffffffc0209260:	4701                	li	a4,0
ffffffffc0209262:	e689                	bnez	a3,ffffffffc020926c <sfs_fsync+0x28>
ffffffffc0209264:	70a2                	ld	ra,40(sp)
ffffffffc0209266:	853a                	mv	a0,a4
ffffffffc0209268:	6145                	addi	sp,sp,48
ffffffffc020926a:	8082                	ret
ffffffffc020926c:	f022                	sd	s0,32(sp)
ffffffffc020926e:	e42a                	sd	a0,8(sp)
ffffffffc0209270:	02050413          	addi	s0,a0,32
ffffffffc0209274:	02050513          	addi	a0,a0,32
ffffffffc0209278:	ec3a                	sd	a4,24(sp)
ffffffffc020927a:	e832                	sd	a2,16(sp)
ffffffffc020927c:	d5cfb0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0209280:	67a2                	ld	a5,8(sp)
ffffffffc0209282:	6762                	ld	a4,24(sp)
ffffffffc0209284:	6b94                	ld	a3,16(a5)
ffffffffc0209286:	ea99                	bnez	a3,ffffffffc020929c <sfs_fsync+0x58>
ffffffffc0209288:	8522                	mv	a0,s0
ffffffffc020928a:	e43a                	sd	a4,8(sp)
ffffffffc020928c:	d48fb0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0209290:	6722                	ld	a4,8(sp)
ffffffffc0209292:	7402                	ld	s0,32(sp)
ffffffffc0209294:	70a2                	ld	ra,40(sp)
ffffffffc0209296:	853a                	mv	a0,a4
ffffffffc0209298:	6145                	addi	sp,sp,48
ffffffffc020929a:	8082                	ret
ffffffffc020929c:	4794                	lw	a3,8(a5)
ffffffffc020929e:	638c                	ld	a1,0(a5)
ffffffffc02092a0:	6542                	ld	a0,16(sp)
ffffffffc02092a2:	4701                	li	a4,0
ffffffffc02092a4:	0007b823          	sd	zero,16(a5) # 2010 <_binary_bin_swap_img_size-0x5cf0>
ffffffffc02092a8:	04000613          	li	a2,64
ffffffffc02092ac:	6d3010ef          	jal	ffffffffc020b17e <sfs_wbuf>
ffffffffc02092b0:	872a                	mv	a4,a0
ffffffffc02092b2:	d979                	beqz	a0,ffffffffc0209288 <sfs_fsync+0x44>
ffffffffc02092b4:	67a2                	ld	a5,8(sp)
ffffffffc02092b6:	4685                	li	a3,1
ffffffffc02092b8:	eb94                	sd	a3,16(a5)
ffffffffc02092ba:	b7f9                	j	ffffffffc0209288 <sfs_fsync+0x44>
ffffffffc02092bc:	00005697          	auipc	a3,0x5
ffffffffc02092c0:	46c68693          	addi	a3,a3,1132 # ffffffffc020e728 <etext+0x2e52>
ffffffffc02092c4:	00003617          	auipc	a2,0x3
ffffffffc02092c8:	acc60613          	addi	a2,a2,-1332 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02092cc:	2cc00593          	li	a1,716
ffffffffc02092d0:	00005517          	auipc	a0,0x5
ffffffffc02092d4:	42850513          	addi	a0,a0,1064 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02092d8:	f022                	sd	s0,32(sp)
ffffffffc02092da:	f53f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc02092de:	00005697          	auipc	a3,0x5
ffffffffc02092e2:	3e268693          	addi	a3,a3,994 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc02092e6:	00003617          	auipc	a2,0x3
ffffffffc02092ea:	aaa60613          	addi	a2,a2,-1366 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02092ee:	2cd00593          	li	a1,717
ffffffffc02092f2:	00005517          	auipc	a0,0x5
ffffffffc02092f6:	40650513          	addi	a0,a0,1030 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02092fa:	f022                	sd	s0,32(sp)
ffffffffc02092fc:	f31f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209300 <sfs_fstat>:
ffffffffc0209300:	1101                	addi	sp,sp,-32
ffffffffc0209302:	e822                	sd	s0,16(sp)
ffffffffc0209304:	e426                	sd	s1,8(sp)
ffffffffc0209306:	842a                	mv	s0,a0
ffffffffc0209308:	84ae                	mv	s1,a1
ffffffffc020930a:	852e                	mv	a0,a1
ffffffffc020930c:	02000613          	li	a2,32
ffffffffc0209310:	4581                	li	a1,0
ffffffffc0209312:	ec06                	sd	ra,24(sp)
ffffffffc0209314:	0d2020ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc0209318:	c439                	beqz	s0,ffffffffc0209366 <sfs_fstat+0x66>
ffffffffc020931a:	783c                	ld	a5,112(s0)
ffffffffc020931c:	c7a9                	beqz	a5,ffffffffc0209366 <sfs_fstat+0x66>
ffffffffc020931e:	6bbc                	ld	a5,80(a5)
ffffffffc0209320:	c3b9                	beqz	a5,ffffffffc0209366 <sfs_fstat+0x66>
ffffffffc0209322:	00005597          	auipc	a1,0x5
ffffffffc0209326:	c3e58593          	addi	a1,a1,-962 # ffffffffc020df60 <etext+0x268a>
ffffffffc020932a:	8522                	mv	a0,s0
ffffffffc020932c:	fbffe0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0209330:	783c                	ld	a5,112(s0)
ffffffffc0209332:	85a6                	mv	a1,s1
ffffffffc0209334:	8522                	mv	a0,s0
ffffffffc0209336:	6bbc                	ld	a5,80(a5)
ffffffffc0209338:	9782                	jalr	a5
ffffffffc020933a:	e10d                	bnez	a0,ffffffffc020935c <sfs_fstat+0x5c>
ffffffffc020933c:	4c38                	lw	a4,88(s0)
ffffffffc020933e:	6785                	lui	a5,0x1
ffffffffc0209340:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209344:	04f71163          	bne	a4,a5,ffffffffc0209386 <sfs_fstat+0x86>
ffffffffc0209348:	601c                	ld	a5,0(s0)
ffffffffc020934a:	0067d683          	lhu	a3,6(a5)
ffffffffc020934e:	0087e703          	lwu	a4,8(a5)
ffffffffc0209352:	0007e783          	lwu	a5,0(a5)
ffffffffc0209356:	e494                	sd	a3,8(s1)
ffffffffc0209358:	e898                	sd	a4,16(s1)
ffffffffc020935a:	ec9c                	sd	a5,24(s1)
ffffffffc020935c:	60e2                	ld	ra,24(sp)
ffffffffc020935e:	6442                	ld	s0,16(sp)
ffffffffc0209360:	64a2                	ld	s1,8(sp)
ffffffffc0209362:	6105                	addi	sp,sp,32
ffffffffc0209364:	8082                	ret
ffffffffc0209366:	00005697          	auipc	a3,0x5
ffffffffc020936a:	b9268693          	addi	a3,a3,-1134 # ffffffffc020def8 <etext+0x2622>
ffffffffc020936e:	00003617          	auipc	a2,0x3
ffffffffc0209372:	a2260613          	addi	a2,a2,-1502 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209376:	2bd00593          	li	a1,701
ffffffffc020937a:	00005517          	auipc	a0,0x5
ffffffffc020937e:	37e50513          	addi	a0,a0,894 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209382:	eabf60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209386:	00005697          	auipc	a3,0x5
ffffffffc020938a:	33a68693          	addi	a3,a3,826 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020938e:	00003617          	auipc	a2,0x3
ffffffffc0209392:	a0260613          	addi	a2,a2,-1534 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209396:	2c000593          	li	a1,704
ffffffffc020939a:	00005517          	auipc	a0,0x5
ffffffffc020939e:	35e50513          	addi	a0,a0,862 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02093a2:	e8bf60ef          	jal	ffffffffc020022c <__panic>

ffffffffc02093a6 <sfs_tryseek>:
ffffffffc02093a6:	08000737          	lui	a4,0x8000
ffffffffc02093aa:	04e5f863          	bgeu	a1,a4,ffffffffc02093fa <sfs_tryseek+0x54>
ffffffffc02093ae:	1101                	addi	sp,sp,-32
ffffffffc02093b0:	ec06                	sd	ra,24(sp)
ffffffffc02093b2:	c531                	beqz	a0,ffffffffc02093fe <sfs_tryseek+0x58>
ffffffffc02093b4:	4d30                	lw	a2,88(a0)
ffffffffc02093b6:	6685                	lui	a3,0x1
ffffffffc02093b8:	23568693          	addi	a3,a3,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02093bc:	04d61163          	bne	a2,a3,ffffffffc02093fe <sfs_tryseek+0x58>
ffffffffc02093c0:	6114                	ld	a3,0(a0)
ffffffffc02093c2:	0006e683          	lwu	a3,0(a3)
ffffffffc02093c6:	02b6d663          	bge	a3,a1,ffffffffc02093f2 <sfs_tryseek+0x4c>
ffffffffc02093ca:	7934                	ld	a3,112(a0)
ffffffffc02093cc:	caa9                	beqz	a3,ffffffffc020941e <sfs_tryseek+0x78>
ffffffffc02093ce:	72b4                	ld	a3,96(a3)
ffffffffc02093d0:	c6b9                	beqz	a3,ffffffffc020941e <sfs_tryseek+0x78>
ffffffffc02093d2:	e02e                	sd	a1,0(sp)
ffffffffc02093d4:	00005597          	auipc	a1,0x5
ffffffffc02093d8:	00c58593          	addi	a1,a1,12 # ffffffffc020e3e0 <etext+0x2b0a>
ffffffffc02093dc:	e42a                	sd	a0,8(sp)
ffffffffc02093de:	f0dfe0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02093e2:	67a2                	ld	a5,8(sp)
ffffffffc02093e4:	6582                	ld	a1,0(sp)
ffffffffc02093e6:	60e2                	ld	ra,24(sp)
ffffffffc02093e8:	7bb4                	ld	a3,112(a5)
ffffffffc02093ea:	853e                	mv	a0,a5
ffffffffc02093ec:	72bc                	ld	a5,96(a3)
ffffffffc02093ee:	6105                	addi	sp,sp,32
ffffffffc02093f0:	8782                	jr	a5
ffffffffc02093f2:	60e2                	ld	ra,24(sp)
ffffffffc02093f4:	4501                	li	a0,0
ffffffffc02093f6:	6105                	addi	sp,sp,32
ffffffffc02093f8:	8082                	ret
ffffffffc02093fa:	5575                	li	a0,-3
ffffffffc02093fc:	8082                	ret
ffffffffc02093fe:	00005697          	auipc	a3,0x5
ffffffffc0209402:	2c268693          	addi	a3,a3,706 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc0209406:	00003617          	auipc	a2,0x3
ffffffffc020940a:	98a60613          	addi	a2,a2,-1654 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020940e:	39f00593          	li	a1,927
ffffffffc0209412:	00005517          	auipc	a0,0x5
ffffffffc0209416:	2e650513          	addi	a0,a0,742 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020941a:	e13f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020941e:	00005697          	auipc	a3,0x5
ffffffffc0209422:	f6a68693          	addi	a3,a3,-150 # ffffffffc020e388 <etext+0x2ab2>
ffffffffc0209426:	00003617          	auipc	a2,0x3
ffffffffc020942a:	96a60613          	addi	a2,a2,-1686 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020942e:	3a100593          	li	a1,929
ffffffffc0209432:	00005517          	auipc	a0,0x5
ffffffffc0209436:	2c650513          	addi	a0,a0,710 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020943a:	df3f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc020943e <sfs_close>:
ffffffffc020943e:	1141                	addi	sp,sp,-16
ffffffffc0209440:	e406                	sd	ra,8(sp)
ffffffffc0209442:	e022                	sd	s0,0(sp)
ffffffffc0209444:	c11d                	beqz	a0,ffffffffc020946a <sfs_close+0x2c>
ffffffffc0209446:	793c                	ld	a5,112(a0)
ffffffffc0209448:	842a                	mv	s0,a0
ffffffffc020944a:	c385                	beqz	a5,ffffffffc020946a <sfs_close+0x2c>
ffffffffc020944c:	7b9c                	ld	a5,48(a5)
ffffffffc020944e:	cf91                	beqz	a5,ffffffffc020946a <sfs_close+0x2c>
ffffffffc0209450:	00004597          	auipc	a1,0x4
ffffffffc0209454:	1c858593          	addi	a1,a1,456 # ffffffffc020d618 <etext+0x1d42>
ffffffffc0209458:	e93fe0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020945c:	783c                	ld	a5,112(s0)
ffffffffc020945e:	8522                	mv	a0,s0
ffffffffc0209460:	6402                	ld	s0,0(sp)
ffffffffc0209462:	60a2                	ld	ra,8(sp)
ffffffffc0209464:	7b9c                	ld	a5,48(a5)
ffffffffc0209466:	0141                	addi	sp,sp,16
ffffffffc0209468:	8782                	jr	a5
ffffffffc020946a:	00004697          	auipc	a3,0x4
ffffffffc020946e:	15e68693          	addi	a3,a3,350 # ffffffffc020d5c8 <etext+0x1cf2>
ffffffffc0209472:	00003617          	auipc	a2,0x3
ffffffffc0209476:	91e60613          	addi	a2,a2,-1762 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020947a:	21c00593          	li	a1,540
ffffffffc020947e:	00005517          	auipc	a0,0x5
ffffffffc0209482:	27a50513          	addi	a0,a0,634 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209486:	da7f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc020948a <sfs_io.part.0>:
ffffffffc020948a:	1141                	addi	sp,sp,-16
ffffffffc020948c:	00005697          	auipc	a3,0x5
ffffffffc0209490:	23468693          	addi	a3,a3,564 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc0209494:	00003617          	auipc	a2,0x3
ffffffffc0209498:	8fc60613          	addi	a2,a2,-1796 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020949c:	29c00593          	li	a1,668
ffffffffc02094a0:	00005517          	auipc	a0,0x5
ffffffffc02094a4:	25850513          	addi	a0,a0,600 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02094a8:	e406                	sd	ra,8(sp)
ffffffffc02094aa:	d83f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc02094ae <sfs_block_free>:
ffffffffc02094ae:	1101                	addi	sp,sp,-32
ffffffffc02094b0:	e822                	sd	s0,16(sp)
ffffffffc02094b2:	e426                	sd	s1,8(sp)
ffffffffc02094b4:	ec06                	sd	ra,24(sp)
ffffffffc02094b6:	84ae                	mv	s1,a1
ffffffffc02094b8:	842a                	mv	s0,a0
ffffffffc02094ba:	c595                	beqz	a1,ffffffffc02094e6 <sfs_block_free+0x38>
ffffffffc02094bc:	415c                	lw	a5,4(a0)
ffffffffc02094be:	02f5f463          	bgeu	a1,a5,ffffffffc02094e6 <sfs_block_free+0x38>
ffffffffc02094c2:	7d08                	ld	a0,56(a0)
ffffffffc02094c4:	27b010ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc02094c8:	ed0d                	bnez	a0,ffffffffc0209502 <sfs_block_free+0x54>
ffffffffc02094ca:	7c08                	ld	a0,56(s0)
ffffffffc02094cc:	85a6                	mv	a1,s1
ffffffffc02094ce:	299010ef          	jal	ffffffffc020af66 <bitmap_free>
ffffffffc02094d2:	441c                	lw	a5,8(s0)
ffffffffc02094d4:	4705                	li	a4,1
ffffffffc02094d6:	60e2                	ld	ra,24(sp)
ffffffffc02094d8:	2785                	addiw	a5,a5,1
ffffffffc02094da:	e038                	sd	a4,64(s0)
ffffffffc02094dc:	c41c                	sw	a5,8(s0)
ffffffffc02094de:	6442                	ld	s0,16(sp)
ffffffffc02094e0:	64a2                	ld	s1,8(sp)
ffffffffc02094e2:	6105                	addi	sp,sp,32
ffffffffc02094e4:	8082                	ret
ffffffffc02094e6:	4054                	lw	a3,4(s0)
ffffffffc02094e8:	8726                	mv	a4,s1
ffffffffc02094ea:	00005617          	auipc	a2,0x5
ffffffffc02094ee:	26e60613          	addi	a2,a2,622 # ffffffffc020e758 <etext+0x2e82>
ffffffffc02094f2:	05300593          	li	a1,83
ffffffffc02094f6:	00005517          	auipc	a0,0x5
ffffffffc02094fa:	20250513          	addi	a0,a0,514 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02094fe:	d2ff60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209502:	00005697          	auipc	a3,0x5
ffffffffc0209506:	28e68693          	addi	a3,a3,654 # ffffffffc020e790 <etext+0x2eba>
ffffffffc020950a:	00003617          	auipc	a2,0x3
ffffffffc020950e:	88660613          	addi	a2,a2,-1914 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209512:	06a00593          	li	a1,106
ffffffffc0209516:	00005517          	auipc	a0,0x5
ffffffffc020951a:	1e250513          	addi	a0,a0,482 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020951e:	d0ff60ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209522 <sfs_reclaim>:
ffffffffc0209522:	1101                	addi	sp,sp,-32
ffffffffc0209524:	e426                	sd	s1,8(sp)
ffffffffc0209526:	7524                	ld	s1,104(a0)
ffffffffc0209528:	ec06                	sd	ra,24(sp)
ffffffffc020952a:	e822                	sd	s0,16(sp)
ffffffffc020952c:	e04a                	sd	s2,0(sp)
ffffffffc020952e:	0e048963          	beqz	s1,ffffffffc0209620 <sfs_reclaim+0xfe>
ffffffffc0209532:	0b04a783          	lw	a5,176(s1) # 10b0 <_binary_bin_swap_img_size-0x6c50>
ffffffffc0209536:	0e079563          	bnez	a5,ffffffffc0209620 <sfs_reclaim+0xfe>
ffffffffc020953a:	4d38                	lw	a4,88(a0)
ffffffffc020953c:	6785                	lui	a5,0x1
ffffffffc020953e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209542:	842a                	mv	s0,a0
ffffffffc0209544:	10f71e63          	bne	a4,a5,ffffffffc0209660 <sfs_reclaim+0x13e>
ffffffffc0209548:	8526                	mv	a0,s1
ffffffffc020954a:	c43ff0ef          	jal	ffffffffc020918c <lock_sfs_fs>
ffffffffc020954e:	4c1c                	lw	a5,24(s0)
ffffffffc0209550:	0ef05863          	blez	a5,ffffffffc0209640 <sfs_reclaim+0x11e>
ffffffffc0209554:	37fd                	addiw	a5,a5,-1
ffffffffc0209556:	cc1c                	sw	a5,24(s0)
ffffffffc0209558:	ebd9                	bnez	a5,ffffffffc02095ee <sfs_reclaim+0xcc>
ffffffffc020955a:	05c42903          	lw	s2,92(s0)
ffffffffc020955e:	08091863          	bnez	s2,ffffffffc02095ee <sfs_reclaim+0xcc>
ffffffffc0209562:	601c                	ld	a5,0(s0)
ffffffffc0209564:	0067d783          	lhu	a5,6(a5)
ffffffffc0209568:	e785                	bnez	a5,ffffffffc0209590 <sfs_reclaim+0x6e>
ffffffffc020956a:	783c                	ld	a5,112(s0)
ffffffffc020956c:	10078a63          	beqz	a5,ffffffffc0209680 <sfs_reclaim+0x15e>
ffffffffc0209570:	73bc                	ld	a5,96(a5)
ffffffffc0209572:	10078763          	beqz	a5,ffffffffc0209680 <sfs_reclaim+0x15e>
ffffffffc0209576:	00005597          	auipc	a1,0x5
ffffffffc020957a:	e6a58593          	addi	a1,a1,-406 # ffffffffc020e3e0 <etext+0x2b0a>
ffffffffc020957e:	8522                	mv	a0,s0
ffffffffc0209580:	d6bfe0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc0209584:	783c                	ld	a5,112(s0)
ffffffffc0209586:	8522                	mv	a0,s0
ffffffffc0209588:	4581                	li	a1,0
ffffffffc020958a:	73bc                	ld	a5,96(a5)
ffffffffc020958c:	9782                	jalr	a5
ffffffffc020958e:	e559                	bnez	a0,ffffffffc020961c <sfs_reclaim+0xfa>
ffffffffc0209590:	681c                	ld	a5,16(s0)
ffffffffc0209592:	c39d                	beqz	a5,ffffffffc02095b8 <sfs_reclaim+0x96>
ffffffffc0209594:	783c                	ld	a5,112(s0)
ffffffffc0209596:	10078563          	beqz	a5,ffffffffc02096a0 <sfs_reclaim+0x17e>
ffffffffc020959a:	7b9c                	ld	a5,48(a5)
ffffffffc020959c:	10078263          	beqz	a5,ffffffffc02096a0 <sfs_reclaim+0x17e>
ffffffffc02095a0:	8522                	mv	a0,s0
ffffffffc02095a2:	00004597          	auipc	a1,0x4
ffffffffc02095a6:	07658593          	addi	a1,a1,118 # ffffffffc020d618 <etext+0x1d42>
ffffffffc02095aa:	d41fe0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc02095ae:	783c                	ld	a5,112(s0)
ffffffffc02095b0:	8522                	mv	a0,s0
ffffffffc02095b2:	7b9c                	ld	a5,48(a5)
ffffffffc02095b4:	9782                	jalr	a5
ffffffffc02095b6:	e13d                	bnez	a0,ffffffffc020961c <sfs_reclaim+0xfa>
ffffffffc02095b8:	7c18                	ld	a4,56(s0)
ffffffffc02095ba:	603c                	ld	a5,64(s0)
ffffffffc02095bc:	8526                	mv	a0,s1
ffffffffc02095be:	e71c                	sd	a5,8(a4)
ffffffffc02095c0:	e398                	sd	a4,0(a5)
ffffffffc02095c2:	6438                	ld	a4,72(s0)
ffffffffc02095c4:	683c                	ld	a5,80(s0)
ffffffffc02095c6:	e71c                	sd	a5,8(a4)
ffffffffc02095c8:	e398                	sd	a4,0(a5)
ffffffffc02095ca:	bd3ff0ef          	jal	ffffffffc020919c <unlock_sfs_fs>
ffffffffc02095ce:	6008                	ld	a0,0(s0)
ffffffffc02095d0:	00655783          	lhu	a5,6(a0)
ffffffffc02095d4:	cb85                	beqz	a5,ffffffffc0209604 <sfs_reclaim+0xe2>
ffffffffc02095d6:	80df80ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc02095da:	8522                	mv	a0,s0
ffffffffc02095dc:	ca7fe0ef          	jal	ffffffffc0208282 <inode_kill>
ffffffffc02095e0:	60e2                	ld	ra,24(sp)
ffffffffc02095e2:	6442                	ld	s0,16(sp)
ffffffffc02095e4:	64a2                	ld	s1,8(sp)
ffffffffc02095e6:	854a                	mv	a0,s2
ffffffffc02095e8:	6902                	ld	s2,0(sp)
ffffffffc02095ea:	6105                	addi	sp,sp,32
ffffffffc02095ec:	8082                	ret
ffffffffc02095ee:	5945                	li	s2,-15
ffffffffc02095f0:	8526                	mv	a0,s1
ffffffffc02095f2:	babff0ef          	jal	ffffffffc020919c <unlock_sfs_fs>
ffffffffc02095f6:	60e2                	ld	ra,24(sp)
ffffffffc02095f8:	6442                	ld	s0,16(sp)
ffffffffc02095fa:	64a2                	ld	s1,8(sp)
ffffffffc02095fc:	854a                	mv	a0,s2
ffffffffc02095fe:	6902                	ld	s2,0(sp)
ffffffffc0209600:	6105                	addi	sp,sp,32
ffffffffc0209602:	8082                	ret
ffffffffc0209604:	440c                	lw	a1,8(s0)
ffffffffc0209606:	8526                	mv	a0,s1
ffffffffc0209608:	ea7ff0ef          	jal	ffffffffc02094ae <sfs_block_free>
ffffffffc020960c:	6008                	ld	a0,0(s0)
ffffffffc020960e:	5d4c                	lw	a1,60(a0)
ffffffffc0209610:	d1f9                	beqz	a1,ffffffffc02095d6 <sfs_reclaim+0xb4>
ffffffffc0209612:	8526                	mv	a0,s1
ffffffffc0209614:	e9bff0ef          	jal	ffffffffc02094ae <sfs_block_free>
ffffffffc0209618:	6008                	ld	a0,0(s0)
ffffffffc020961a:	bf75                	j	ffffffffc02095d6 <sfs_reclaim+0xb4>
ffffffffc020961c:	892a                	mv	s2,a0
ffffffffc020961e:	bfc9                	j	ffffffffc02095f0 <sfs_reclaim+0xce>
ffffffffc0209620:	00005697          	auipc	a3,0x5
ffffffffc0209624:	10868693          	addi	a3,a3,264 # ffffffffc020e728 <etext+0x2e52>
ffffffffc0209628:	00002617          	auipc	a2,0x2
ffffffffc020962c:	76860613          	addi	a2,a2,1896 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209630:	35d00593          	li	a1,861
ffffffffc0209634:	00005517          	auipc	a0,0x5
ffffffffc0209638:	0c450513          	addi	a0,a0,196 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020963c:	bf1f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209640:	00005697          	auipc	a3,0x5
ffffffffc0209644:	17068693          	addi	a3,a3,368 # ffffffffc020e7b0 <etext+0x2eda>
ffffffffc0209648:	00002617          	auipc	a2,0x2
ffffffffc020964c:	74860613          	addi	a2,a2,1864 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209650:	36300593          	li	a1,867
ffffffffc0209654:	00005517          	auipc	a0,0x5
ffffffffc0209658:	0a450513          	addi	a0,a0,164 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020965c:	bd1f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209660:	00005697          	auipc	a3,0x5
ffffffffc0209664:	06068693          	addi	a3,a3,96 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc0209668:	00002617          	auipc	a2,0x2
ffffffffc020966c:	72860613          	addi	a2,a2,1832 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209670:	35e00593          	li	a1,862
ffffffffc0209674:	00005517          	auipc	a0,0x5
ffffffffc0209678:	08450513          	addi	a0,a0,132 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020967c:	bb1f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209680:	00005697          	auipc	a3,0x5
ffffffffc0209684:	d0868693          	addi	a3,a3,-760 # ffffffffc020e388 <etext+0x2ab2>
ffffffffc0209688:	00002617          	auipc	a2,0x2
ffffffffc020968c:	70860613          	addi	a2,a2,1800 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209690:	36800593          	li	a1,872
ffffffffc0209694:	00005517          	auipc	a0,0x5
ffffffffc0209698:	06450513          	addi	a0,a0,100 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020969c:	b91f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc02096a0:	00004697          	auipc	a3,0x4
ffffffffc02096a4:	f2868693          	addi	a3,a3,-216 # ffffffffc020d5c8 <etext+0x1cf2>
ffffffffc02096a8:	00002617          	auipc	a2,0x2
ffffffffc02096ac:	6e860613          	addi	a2,a2,1768 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02096b0:	36d00593          	li	a1,877
ffffffffc02096b4:	00005517          	auipc	a0,0x5
ffffffffc02096b8:	04450513          	addi	a0,a0,68 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02096bc:	b71f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc02096c0 <sfs_block_alloc>:
ffffffffc02096c0:	1101                	addi	sp,sp,-32
ffffffffc02096c2:	e822                	sd	s0,16(sp)
ffffffffc02096c4:	842a                	mv	s0,a0
ffffffffc02096c6:	7d08                	ld	a0,56(a0)
ffffffffc02096c8:	e426                	sd	s1,8(sp)
ffffffffc02096ca:	ec06                	sd	ra,24(sp)
ffffffffc02096cc:	84ae                	mv	s1,a1
ffffffffc02096ce:	7fe010ef          	jal	ffffffffc020aecc <bitmap_alloc>
ffffffffc02096d2:	e90d                	bnez	a0,ffffffffc0209704 <sfs_block_alloc+0x44>
ffffffffc02096d4:	441c                	lw	a5,8(s0)
ffffffffc02096d6:	cbb5                	beqz	a5,ffffffffc020974a <sfs_block_alloc+0x8a>
ffffffffc02096d8:	37fd                	addiw	a5,a5,-1
ffffffffc02096da:	c41c                	sw	a5,8(s0)
ffffffffc02096dc:	408c                	lw	a1,0(s1)
ffffffffc02096de:	4605                	li	a2,1
ffffffffc02096e0:	e030                	sd	a2,64(s0)
ffffffffc02096e2:	c595                	beqz	a1,ffffffffc020970e <sfs_block_alloc+0x4e>
ffffffffc02096e4:	405c                	lw	a5,4(s0)
ffffffffc02096e6:	02f5f463          	bgeu	a1,a5,ffffffffc020970e <sfs_block_alloc+0x4e>
ffffffffc02096ea:	7c08                	ld	a0,56(s0)
ffffffffc02096ec:	053010ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc02096f0:	4605                	li	a2,1
ffffffffc02096f2:	ed05                	bnez	a0,ffffffffc020972a <sfs_block_alloc+0x6a>
ffffffffc02096f4:	8522                	mv	a0,s0
ffffffffc02096f6:	6442                	ld	s0,16(sp)
ffffffffc02096f8:	408c                	lw	a1,0(s1)
ffffffffc02096fa:	60e2                	ld	ra,24(sp)
ffffffffc02096fc:	64a2                	ld	s1,8(sp)
ffffffffc02096fe:	6105                	addi	sp,sp,32
ffffffffc0209700:	3d30106f          	j	ffffffffc020b2d2 <sfs_clear_block>
ffffffffc0209704:	60e2                	ld	ra,24(sp)
ffffffffc0209706:	6442                	ld	s0,16(sp)
ffffffffc0209708:	64a2                	ld	s1,8(sp)
ffffffffc020970a:	6105                	addi	sp,sp,32
ffffffffc020970c:	8082                	ret
ffffffffc020970e:	4054                	lw	a3,4(s0)
ffffffffc0209710:	872e                	mv	a4,a1
ffffffffc0209712:	00005617          	auipc	a2,0x5
ffffffffc0209716:	04660613          	addi	a2,a2,70 # ffffffffc020e758 <etext+0x2e82>
ffffffffc020971a:	05300593          	li	a1,83
ffffffffc020971e:	00005517          	auipc	a0,0x5
ffffffffc0209722:	fda50513          	addi	a0,a0,-38 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209726:	b07f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020972a:	00005697          	auipc	a3,0x5
ffffffffc020972e:	0be68693          	addi	a3,a3,190 # ffffffffc020e7e8 <etext+0x2f12>
ffffffffc0209732:	00002617          	auipc	a2,0x2
ffffffffc0209736:	65e60613          	addi	a2,a2,1630 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020973a:	06100593          	li	a1,97
ffffffffc020973e:	00005517          	auipc	a0,0x5
ffffffffc0209742:	fba50513          	addi	a0,a0,-70 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209746:	ae7f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020974a:	00005697          	auipc	a3,0x5
ffffffffc020974e:	07e68693          	addi	a3,a3,126 # ffffffffc020e7c8 <etext+0x2ef2>
ffffffffc0209752:	00002617          	auipc	a2,0x2
ffffffffc0209756:	63e60613          	addi	a2,a2,1598 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020975a:	05f00593          	li	a1,95
ffffffffc020975e:	00005517          	auipc	a0,0x5
ffffffffc0209762:	f9a50513          	addi	a0,a0,-102 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209766:	ac7f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc020976a <sfs_bmap_load_nolock>:
ffffffffc020976a:	711d                	addi	sp,sp,-96
ffffffffc020976c:	e4a6                	sd	s1,72(sp)
ffffffffc020976e:	6184                	ld	s1,0(a1)
ffffffffc0209770:	e0ca                	sd	s2,64(sp)
ffffffffc0209772:	ec86                	sd	ra,88(sp)
ffffffffc0209774:	0084a903          	lw	s2,8(s1)
ffffffffc0209778:	e8a2                	sd	s0,80(sp)
ffffffffc020977a:	fc4e                	sd	s3,56(sp)
ffffffffc020977c:	f852                	sd	s4,48(sp)
ffffffffc020977e:	1ac96663          	bltu	s2,a2,ffffffffc020992a <sfs_bmap_load_nolock+0x1c0>
ffffffffc0209782:	47ad                	li	a5,11
ffffffffc0209784:	882e                	mv	a6,a1
ffffffffc0209786:	8432                	mv	s0,a2
ffffffffc0209788:	8a36                	mv	s4,a3
ffffffffc020978a:	89aa                	mv	s3,a0
ffffffffc020978c:	04c7f963          	bgeu	a5,a2,ffffffffc02097de <sfs_bmap_load_nolock+0x74>
ffffffffc0209790:	ff46079b          	addiw	a5,a2,-12
ffffffffc0209794:	3ff00713          	li	a4,1023
ffffffffc0209798:	f456                	sd	s5,40(sp)
ffffffffc020979a:	1af76a63          	bltu	a4,a5,ffffffffc020994e <sfs_bmap_load_nolock+0x1e4>
ffffffffc020979e:	03c4a883          	lw	a7,60(s1)
ffffffffc02097a2:	02079713          	slli	a4,a5,0x20
ffffffffc02097a6:	01e75793          	srli	a5,a4,0x1e
ffffffffc02097aa:	ce02                	sw	zero,28(sp)
ffffffffc02097ac:	cc46                	sw	a7,24(sp)
ffffffffc02097ae:	8abe                	mv	s5,a5
ffffffffc02097b0:	12089063          	bnez	a7,ffffffffc02098d0 <sfs_bmap_load_nolock+0x166>
ffffffffc02097b4:	08c90c63          	beq	s2,a2,ffffffffc020984c <sfs_bmap_load_nolock+0xe2>
ffffffffc02097b8:	7aa2                	ld	s5,40(sp)
ffffffffc02097ba:	4581                	li	a1,0
ffffffffc02097bc:	0049a683          	lw	a3,4(s3)
ffffffffc02097c0:	f456                	sd	s5,40(sp)
ffffffffc02097c2:	f05a                	sd	s6,32(sp)
ffffffffc02097c4:	872e                	mv	a4,a1
ffffffffc02097c6:	00005617          	auipc	a2,0x5
ffffffffc02097ca:	f9260613          	addi	a2,a2,-110 # ffffffffc020e758 <etext+0x2e82>
ffffffffc02097ce:	05300593          	li	a1,83
ffffffffc02097d2:	00005517          	auipc	a0,0x5
ffffffffc02097d6:	f2650513          	addi	a0,a0,-218 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02097da:	a53f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc02097de:	02061793          	slli	a5,a2,0x20
ffffffffc02097e2:	01e7d713          	srli	a4,a5,0x1e
ffffffffc02097e6:	9726                	add	a4,a4,s1
ffffffffc02097e8:	474c                	lw	a1,12(a4)
ffffffffc02097ea:	ca2e                	sw	a1,20(sp)
ffffffffc02097ec:	e581                	bnez	a1,ffffffffc02097f4 <sfs_bmap_load_nolock+0x8a>
ffffffffc02097ee:	0cc90063          	beq	s2,a2,ffffffffc02098ae <sfs_bmap_load_nolock+0x144>
ffffffffc02097f2:	d5e1                	beqz	a1,ffffffffc02097ba <sfs_bmap_load_nolock+0x50>
ffffffffc02097f4:	0049a683          	lw	a3,4(s3)
ffffffffc02097f8:	16d5f863          	bgeu	a1,a3,ffffffffc0209968 <sfs_bmap_load_nolock+0x1fe>
ffffffffc02097fc:	0389b503          	ld	a0,56(s3)
ffffffffc0209800:	73e010ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc0209804:	18051763          	bnez	a0,ffffffffc0209992 <sfs_bmap_load_nolock+0x228>
ffffffffc0209808:	45d2                	lw	a1,20(sp)
ffffffffc020980a:	0049a783          	lw	a5,4(s3)
ffffffffc020980e:	d5d5                	beqz	a1,ffffffffc02097ba <sfs_bmap_load_nolock+0x50>
ffffffffc0209810:	faf5f6e3          	bgeu	a1,a5,ffffffffc02097bc <sfs_bmap_load_nolock+0x52>
ffffffffc0209814:	0389b503          	ld	a0,56(s3)
ffffffffc0209818:	e02e                	sd	a1,0(sp)
ffffffffc020981a:	724010ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc020981e:	6582                	ld	a1,0(sp)
ffffffffc0209820:	14051763          	bnez	a0,ffffffffc020996e <sfs_bmap_load_nolock+0x204>
ffffffffc0209824:	02890063          	beq	s2,s0,ffffffffc0209844 <sfs_bmap_load_nolock+0xda>
ffffffffc0209828:	000a0463          	beqz	s4,ffffffffc0209830 <sfs_bmap_load_nolock+0xc6>
ffffffffc020982c:	00ba2023          	sw	a1,0(s4)
ffffffffc0209830:	4781                	li	a5,0
ffffffffc0209832:	6446                	ld	s0,80(sp)
ffffffffc0209834:	60e6                	ld	ra,88(sp)
ffffffffc0209836:	79e2                	ld	s3,56(sp)
ffffffffc0209838:	7a42                	ld	s4,48(sp)
ffffffffc020983a:	64a6                	ld	s1,72(sp)
ffffffffc020983c:	6906                	ld	s2,64(sp)
ffffffffc020983e:	853e                	mv	a0,a5
ffffffffc0209840:	6125                	addi	sp,sp,96
ffffffffc0209842:	8082                	ret
ffffffffc0209844:	449c                	lw	a5,8(s1)
ffffffffc0209846:	2785                	addiw	a5,a5,1
ffffffffc0209848:	c49c                	sw	a5,8(s1)
ffffffffc020984a:	bff9                	j	ffffffffc0209828 <sfs_bmap_load_nolock+0xbe>
ffffffffc020984c:	082c                	addi	a1,sp,24
ffffffffc020984e:	e046                	sd	a7,0(sp)
ffffffffc0209850:	e442                	sd	a6,8(sp)
ffffffffc0209852:	e6fff0ef          	jal	ffffffffc02096c0 <sfs_block_alloc>
ffffffffc0209856:	87aa                	mv	a5,a0
ffffffffc0209858:	ed5d                	bnez	a0,ffffffffc0209916 <sfs_bmap_load_nolock+0x1ac>
ffffffffc020985a:	6882                	ld	a7,0(sp)
ffffffffc020985c:	6822                	ld	a6,8(sp)
ffffffffc020985e:	f05a                	sd	s6,32(sp)
ffffffffc0209860:	01c10b13          	addi	s6,sp,28
ffffffffc0209864:	85da                	mv	a1,s6
ffffffffc0209866:	854e                	mv	a0,s3
ffffffffc0209868:	e046                	sd	a7,0(sp)
ffffffffc020986a:	e442                	sd	a6,8(sp)
ffffffffc020986c:	e55ff0ef          	jal	ffffffffc02096c0 <sfs_block_alloc>
ffffffffc0209870:	6882                	ld	a7,0(sp)
ffffffffc0209872:	87aa                	mv	a5,a0
ffffffffc0209874:	e959                	bnez	a0,ffffffffc020990a <sfs_bmap_load_nolock+0x1a0>
ffffffffc0209876:	46e2                	lw	a3,24(sp)
ffffffffc0209878:	85da                	mv	a1,s6
ffffffffc020987a:	8756                	mv	a4,s5
ffffffffc020987c:	4611                	li	a2,4
ffffffffc020987e:	854e                	mv	a0,s3
ffffffffc0209880:	e046                	sd	a7,0(sp)
ffffffffc0209882:	0fd010ef          	jal	ffffffffc020b17e <sfs_wbuf>
ffffffffc0209886:	45f2                	lw	a1,28(sp)
ffffffffc0209888:	6882                	ld	a7,0(sp)
ffffffffc020988a:	e92d                	bnez	a0,ffffffffc02098fc <sfs_bmap_load_nolock+0x192>
ffffffffc020988c:	5cd8                	lw	a4,60(s1)
ffffffffc020988e:	47e2                	lw	a5,24(sp)
ffffffffc0209890:	6822                	ld	a6,8(sp)
ffffffffc0209892:	ca2e                	sw	a1,20(sp)
ffffffffc0209894:	00f70863          	beq	a4,a5,ffffffffc02098a4 <sfs_bmap_load_nolock+0x13a>
ffffffffc0209898:	10071f63          	bnez	a4,ffffffffc02099b6 <sfs_bmap_load_nolock+0x24c>
ffffffffc020989c:	dcdc                	sw	a5,60(s1)
ffffffffc020989e:	4785                	li	a5,1
ffffffffc02098a0:	00f83823          	sd	a5,16(a6)
ffffffffc02098a4:	7aa2                	ld	s5,40(sp)
ffffffffc02098a6:	7b02                	ld	s6,32(sp)
ffffffffc02098a8:	f00589e3          	beqz	a1,ffffffffc02097ba <sfs_bmap_load_nolock+0x50>
ffffffffc02098ac:	b7a1                	j	ffffffffc02097f4 <sfs_bmap_load_nolock+0x8a>
ffffffffc02098ae:	084c                	addi	a1,sp,20
ffffffffc02098b0:	e03a                	sd	a4,0(sp)
ffffffffc02098b2:	e442                	sd	a6,8(sp)
ffffffffc02098b4:	e0dff0ef          	jal	ffffffffc02096c0 <sfs_block_alloc>
ffffffffc02098b8:	87aa                	mv	a5,a0
ffffffffc02098ba:	fd25                	bnez	a0,ffffffffc0209832 <sfs_bmap_load_nolock+0xc8>
ffffffffc02098bc:	45d2                	lw	a1,20(sp)
ffffffffc02098be:	6702                	ld	a4,0(sp)
ffffffffc02098c0:	6822                	ld	a6,8(sp)
ffffffffc02098c2:	4785                	li	a5,1
ffffffffc02098c4:	c74c                	sw	a1,12(a4)
ffffffffc02098c6:	00f83823          	sd	a5,16(a6)
ffffffffc02098ca:	ee0588e3          	beqz	a1,ffffffffc02097ba <sfs_bmap_load_nolock+0x50>
ffffffffc02098ce:	b71d                	j	ffffffffc02097f4 <sfs_bmap_load_nolock+0x8a>
ffffffffc02098d0:	e02e                	sd	a1,0(sp)
ffffffffc02098d2:	873e                	mv	a4,a5
ffffffffc02098d4:	086c                	addi	a1,sp,28
ffffffffc02098d6:	86c6                	mv	a3,a7
ffffffffc02098d8:	4611                	li	a2,4
ffffffffc02098da:	f05a                	sd	s6,32(sp)
ffffffffc02098dc:	e446                	sd	a7,8(sp)
ffffffffc02098de:	021010ef          	jal	ffffffffc020b0fe <sfs_rbuf>
ffffffffc02098e2:	01c10b13          	addi	s6,sp,28
ffffffffc02098e6:	87aa                	mv	a5,a0
ffffffffc02098e8:	e505                	bnez	a0,ffffffffc0209910 <sfs_bmap_load_nolock+0x1a6>
ffffffffc02098ea:	45f2                	lw	a1,28(sp)
ffffffffc02098ec:	6802                	ld	a6,0(sp)
ffffffffc02098ee:	00891463          	bne	s2,s0,ffffffffc02098f6 <sfs_bmap_load_nolock+0x18c>
ffffffffc02098f2:	68a2                	ld	a7,8(sp)
ffffffffc02098f4:	d9a5                	beqz	a1,ffffffffc0209864 <sfs_bmap_load_nolock+0xfa>
ffffffffc02098f6:	5cd8                	lw	a4,60(s1)
ffffffffc02098f8:	47e2                	lw	a5,24(sp)
ffffffffc02098fa:	bf61                	j	ffffffffc0209892 <sfs_bmap_load_nolock+0x128>
ffffffffc02098fc:	e42a                	sd	a0,8(sp)
ffffffffc02098fe:	854e                	mv	a0,s3
ffffffffc0209900:	e046                	sd	a7,0(sp)
ffffffffc0209902:	badff0ef          	jal	ffffffffc02094ae <sfs_block_free>
ffffffffc0209906:	6882                	ld	a7,0(sp)
ffffffffc0209908:	67a2                	ld	a5,8(sp)
ffffffffc020990a:	45e2                	lw	a1,24(sp)
ffffffffc020990c:	00b89763          	bne	a7,a1,ffffffffc020991a <sfs_bmap_load_nolock+0x1b0>
ffffffffc0209910:	7aa2                	ld	s5,40(sp)
ffffffffc0209912:	7b02                	ld	s6,32(sp)
ffffffffc0209914:	bf39                	j	ffffffffc0209832 <sfs_bmap_load_nolock+0xc8>
ffffffffc0209916:	7aa2                	ld	s5,40(sp)
ffffffffc0209918:	bf29                	j	ffffffffc0209832 <sfs_bmap_load_nolock+0xc8>
ffffffffc020991a:	854e                	mv	a0,s3
ffffffffc020991c:	e03e                	sd	a5,0(sp)
ffffffffc020991e:	b91ff0ef          	jal	ffffffffc02094ae <sfs_block_free>
ffffffffc0209922:	6782                	ld	a5,0(sp)
ffffffffc0209924:	7aa2                	ld	s5,40(sp)
ffffffffc0209926:	7b02                	ld	s6,32(sp)
ffffffffc0209928:	b729                	j	ffffffffc0209832 <sfs_bmap_load_nolock+0xc8>
ffffffffc020992a:	00005697          	auipc	a3,0x5
ffffffffc020992e:	ee668693          	addi	a3,a3,-282 # ffffffffc020e810 <etext+0x2f3a>
ffffffffc0209932:	00002617          	auipc	a2,0x2
ffffffffc0209936:	45e60613          	addi	a2,a2,1118 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020993a:	16400593          	li	a1,356
ffffffffc020993e:	00005517          	auipc	a0,0x5
ffffffffc0209942:	dba50513          	addi	a0,a0,-582 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209946:	f456                	sd	s5,40(sp)
ffffffffc0209948:	f05a                	sd	s6,32(sp)
ffffffffc020994a:	8e3f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020994e:	00005617          	auipc	a2,0x5
ffffffffc0209952:	ef260613          	addi	a2,a2,-270 # ffffffffc020e840 <etext+0x2f6a>
ffffffffc0209956:	11e00593          	li	a1,286
ffffffffc020995a:	00005517          	auipc	a0,0x5
ffffffffc020995e:	d9e50513          	addi	a0,a0,-610 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209962:	f05a                	sd	s6,32(sp)
ffffffffc0209964:	8c9f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209968:	f456                	sd	s5,40(sp)
ffffffffc020996a:	f05a                	sd	s6,32(sp)
ffffffffc020996c:	bda1                	j	ffffffffc02097c4 <sfs_bmap_load_nolock+0x5a>
ffffffffc020996e:	00005697          	auipc	a3,0x5
ffffffffc0209972:	e2268693          	addi	a3,a3,-478 # ffffffffc020e790 <etext+0x2eba>
ffffffffc0209976:	00002617          	auipc	a2,0x2
ffffffffc020997a:	41a60613          	addi	a2,a2,1050 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020997e:	16b00593          	li	a1,363
ffffffffc0209982:	00005517          	auipc	a0,0x5
ffffffffc0209986:	d7650513          	addi	a0,a0,-650 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020998a:	f456                	sd	s5,40(sp)
ffffffffc020998c:	f05a                	sd	s6,32(sp)
ffffffffc020998e:	89ff60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209992:	00005697          	auipc	a3,0x5
ffffffffc0209996:	ede68693          	addi	a3,a3,-290 # ffffffffc020e870 <etext+0x2f9a>
ffffffffc020999a:	00002617          	auipc	a2,0x2
ffffffffc020999e:	3f660613          	addi	a2,a2,1014 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02099a2:	12100593          	li	a1,289
ffffffffc02099a6:	00005517          	auipc	a0,0x5
ffffffffc02099aa:	d5250513          	addi	a0,a0,-686 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02099ae:	f456                	sd	s5,40(sp)
ffffffffc02099b0:	f05a                	sd	s6,32(sp)
ffffffffc02099b2:	87bf60ef          	jal	ffffffffc020022c <__panic>
ffffffffc02099b6:	00005697          	auipc	a3,0x5
ffffffffc02099ba:	e7268693          	addi	a3,a3,-398 # ffffffffc020e828 <etext+0x2f52>
ffffffffc02099be:	00002617          	auipc	a2,0x2
ffffffffc02099c2:	3d260613          	addi	a2,a2,978 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc02099c6:	11800593          	li	a1,280
ffffffffc02099ca:	00005517          	auipc	a0,0x5
ffffffffc02099ce:	d2e50513          	addi	a0,a0,-722 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc02099d2:	85bf60ef          	jal	ffffffffc020022c <__panic>

ffffffffc02099d6 <sfs_io_nolock>:
ffffffffc02099d6:	7175                	addi	sp,sp,-144
ffffffffc02099d8:	f4ce                	sd	s3,104(sp)
ffffffffc02099da:	89ae                	mv	s3,a1
ffffffffc02099dc:	618c                	ld	a1,0(a1)
ffffffffc02099de:	e506                	sd	ra,136(sp)
ffffffffc02099e0:	4809                	li	a6,2
ffffffffc02099e2:	0045d883          	lhu	a7,4(a1)
ffffffffc02099e6:	e122                	sd	s0,128(sp)
ffffffffc02099e8:	fca6                	sd	s1,120(sp)
ffffffffc02099ea:	f8ca                	sd	s2,112(sp)
ffffffffc02099ec:	1d088163          	beq	a7,a6,ffffffffc0209bae <sfs_io_nolock+0x1d8>
ffffffffc02099f0:	6304                	ld	s1,0(a4)
ffffffffc02099f2:	893a                	mv	s2,a4
ffffffffc02099f4:	00093023          	sd	zero,0(s2)
ffffffffc02099f8:	08000737          	lui	a4,0x8000
ffffffffc02099fc:	8436                	mv	s0,a3
ffffffffc02099fe:	94b6                	add	s1,s1,a3
ffffffffc0209a00:	8836                	mv	a6,a3
ffffffffc0209a02:	1ae6f463          	bgeu	a3,a4,ffffffffc0209baa <sfs_io_nolock+0x1d4>
ffffffffc0209a06:	1ad4c263          	blt	s1,a3,ffffffffc0209baa <sfs_io_nolock+0x1d4>
ffffffffc0209a0a:	ecd6                	sd	s5,88(sp)
ffffffffc0209a0c:	8aaa                	mv	s5,a0
ffffffffc0209a0e:	4501                	li	a0,0
ffffffffc0209a10:	0e968b63          	beq	a3,s1,ffffffffc0209b06 <sfs_io_nolock+0x130>
ffffffffc0209a14:	e4de                	sd	s7,72(sp)
ffffffffc0209a16:	fc66                	sd	s9,56(sp)
ffffffffc0209a18:	f86a                	sd	s10,48(sp)
ffffffffc0209a1a:	8bb2                	mv	s7,a2
ffffffffc0209a1c:	00977363          	bgeu	a4,s1,ffffffffc0209a22 <sfs_io_nolock+0x4c>
ffffffffc0209a20:	84ba                	mv	s1,a4
ffffffffc0209a22:	cbdd                	beqz	a5,ffffffffc0209ad8 <sfs_io_nolock+0x102>
ffffffffc0209a24:	f0d2                	sd	s4,96(sp)
ffffffffc0209a26:	e8da                	sd	s6,80(sp)
ffffffffc0209a28:	e0e2                	sd	s8,64(sp)
ffffffffc0209a2a:	00001d17          	auipc	s10,0x1
ffffffffc0209a2e:	672d0d13          	addi	s10,s10,1650 # ffffffffc020b09c <sfs_wblock>
ffffffffc0209a32:	00001c97          	auipc	s9,0x1
ffffffffc0209a36:	74cc8c93          	addi	s9,s9,1868 # ffffffffc020b17e <sfs_wbuf>
ffffffffc0209a3a:	6605                	lui	a2,0x1
ffffffffc0209a3c:	40c45693          	srai	a3,s0,0xc
ffffffffc0209a40:	fff60713          	addi	a4,a2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0209a44:	40c4d793          	srai	a5,s1,0xc
ffffffffc0209a48:	9f95                	subw	a5,a5,a3
ffffffffc0209a4a:	40848a33          	sub	s4,s1,s0
ffffffffc0209a4e:	8f61                	and	a4,a4,s0
ffffffffc0209a50:	00068b1b          	sext.w	s6,a3
ffffffffc0209a54:	88be                	mv	a7,a5
ffffffffc0209a56:	8c52                	mv	s8,s4
ffffffffc0209a58:	c35d                	beqz	a4,ffffffffc0209afe <sfs_io_nolock+0x128>
ffffffffc0209a5a:	efd5                	bnez	a5,ffffffffc0209b16 <sfs_io_nolock+0x140>
ffffffffc0209a5c:	1074                	addi	a3,sp,44
ffffffffc0209a5e:	865a                	mv	a2,s6
ffffffffc0209a60:	85ce                	mv	a1,s3
ffffffffc0209a62:	8556                	mv	a0,s5
ffffffffc0209a64:	e442                	sd	a6,8(sp)
ffffffffc0209a66:	ec3e                	sd	a5,24(sp)
ffffffffc0209a68:	e83a                	sd	a4,16(sp)
ffffffffc0209a6a:	d01ff0ef          	jal	ffffffffc020976a <sfs_bmap_load_nolock>
ffffffffc0209a6e:	6822                	ld	a6,8(sp)
ffffffffc0209a70:	10051d63          	bnez	a0,ffffffffc0209b8a <sfs_io_nolock+0x1b4>
ffffffffc0209a74:	56b2                	lw	a3,44(sp)
ffffffffc0209a76:	6742                	ld	a4,16(sp)
ffffffffc0209a78:	8652                	mv	a2,s4
ffffffffc0209a7a:	85de                	mv	a1,s7
ffffffffc0209a7c:	8556                	mv	a0,s5
ffffffffc0209a7e:	9c82                	jalr	s9
ffffffffc0209a80:	6822                	ld	a6,8(sp)
ffffffffc0209a82:	10051463          	bnez	a0,ffffffffc0209b8a <sfs_io_nolock+0x1b4>
ffffffffc0209a86:	67e2                	ld	a5,24(sp)
ffffffffc0209a88:	9bd2                	add	s7,s7,s4
ffffffffc0209a8a:	2b05                	addiw	s6,s6,1
ffffffffc0209a8c:	c789                	beqz	a5,ffffffffc0209a96 <sfs_io_nolock+0xc0>
ffffffffc0209a8e:	fff7889b          	addiw	a7,a5,-1
ffffffffc0209a92:	08089563          	bnez	a7,ffffffffc0209b1c <sfs_io_nolock+0x146>
ffffffffc0209a96:	0b8a6c63          	bltu	s4,s8,ffffffffc0209b4e <sfs_io_nolock+0x178>
ffffffffc0209a9a:	01440833          	add	a6,s0,s4
ffffffffc0209a9e:	4501                	li	a0,0
ffffffffc0209aa0:	0009b783          	ld	a5,0(s3)
ffffffffc0209aa4:	01493023          	sd	s4,0(s2)
ffffffffc0209aa8:	0007e703          	lwu	a4,0(a5)
ffffffffc0209aac:	01077863          	bgeu	a4,a6,ffffffffc0209abc <sfs_io_nolock+0xe6>
ffffffffc0209ab0:	0144043b          	addw	s0,s0,s4
ffffffffc0209ab4:	c380                	sw	s0,0(a5)
ffffffffc0209ab6:	4785                	li	a5,1
ffffffffc0209ab8:	00f9b823          	sd	a5,16(s3)
ffffffffc0209abc:	7a06                	ld	s4,96(sp)
ffffffffc0209abe:	6ae6                	ld	s5,88(sp)
ffffffffc0209ac0:	6b46                	ld	s6,80(sp)
ffffffffc0209ac2:	6ba6                	ld	s7,72(sp)
ffffffffc0209ac4:	6c06                	ld	s8,64(sp)
ffffffffc0209ac6:	7ce2                	ld	s9,56(sp)
ffffffffc0209ac8:	7d42                	ld	s10,48(sp)
ffffffffc0209aca:	640a                	ld	s0,128(sp)
ffffffffc0209acc:	60aa                	ld	ra,136(sp)
ffffffffc0209ace:	74e6                	ld	s1,120(sp)
ffffffffc0209ad0:	7946                	ld	s2,112(sp)
ffffffffc0209ad2:	79a6                	ld	s3,104(sp)
ffffffffc0209ad4:	6149                	addi	sp,sp,144
ffffffffc0209ad6:	8082                	ret
ffffffffc0209ad8:	0005e783          	lwu	a5,0(a1)
ffffffffc0209adc:	4501                	li	a0,0
ffffffffc0209ade:	0af45863          	bge	s0,a5,ffffffffc0209b8e <sfs_io_nolock+0x1b8>
ffffffffc0209ae2:	f0d2                	sd	s4,96(sp)
ffffffffc0209ae4:	e8da                	sd	s6,80(sp)
ffffffffc0209ae6:	e0e2                	sd	s8,64(sp)
ffffffffc0209ae8:	0897c763          	blt	a5,s1,ffffffffc0209b76 <sfs_io_nolock+0x1a0>
ffffffffc0209aec:	00001d17          	auipc	s10,0x1
ffffffffc0209af0:	54ed0d13          	addi	s10,s10,1358 # ffffffffc020b03a <sfs_rblock>
ffffffffc0209af4:	00001c97          	auipc	s9,0x1
ffffffffc0209af8:	60ac8c93          	addi	s9,s9,1546 # ffffffffc020b0fe <sfs_rbuf>
ffffffffc0209afc:	bf3d                	j	ffffffffc0209a3a <sfs_io_nolock+0x64>
ffffffffc0209afe:	4a01                	li	s4,0
ffffffffc0209b00:	f8088be3          	beqz	a7,ffffffffc0209a96 <sfs_io_nolock+0xc0>
ffffffffc0209b04:	a821                	j	ffffffffc0209b1c <sfs_io_nolock+0x146>
ffffffffc0209b06:	640a                	ld	s0,128(sp)
ffffffffc0209b08:	60aa                	ld	ra,136(sp)
ffffffffc0209b0a:	6ae6                	ld	s5,88(sp)
ffffffffc0209b0c:	74e6                	ld	s1,120(sp)
ffffffffc0209b0e:	7946                	ld	s2,112(sp)
ffffffffc0209b10:	79a6                	ld	s3,104(sp)
ffffffffc0209b12:	6149                	addi	sp,sp,144
ffffffffc0209b14:	8082                	ret
ffffffffc0209b16:	40e60a33          	sub	s4,a2,a4
ffffffffc0209b1a:	b789                	j	ffffffffc0209a5c <sfs_io_nolock+0x86>
ffffffffc0209b1c:	1074                	addi	a3,sp,44
ffffffffc0209b1e:	865a                	mv	a2,s6
ffffffffc0209b20:	85ce                	mv	a1,s3
ffffffffc0209b22:	8556                	mv	a0,s5
ffffffffc0209b24:	e446                	sd	a7,8(sp)
ffffffffc0209b26:	c45ff0ef          	jal	ffffffffc020976a <sfs_bmap_load_nolock>
ffffffffc0209b2a:	ed2d                	bnez	a0,ffffffffc0209ba4 <sfs_io_nolock+0x1ce>
ffffffffc0209b2c:	5632                	lw	a2,44(sp)
ffffffffc0209b2e:	66a2                	ld	a3,8(sp)
ffffffffc0209b30:	85de                	mv	a1,s7
ffffffffc0209b32:	8556                	mv	a0,s5
ffffffffc0209b34:	9d02                	jalr	s10
ffffffffc0209b36:	68a2                	ld	a7,8(sp)
ffffffffc0209b38:	e535                	bnez	a0,ffffffffc0209ba4 <sfs_io_nolock+0x1ce>
ffffffffc0209b3a:	00c8979b          	slliw	a5,a7,0xc
ffffffffc0209b3e:	1782                	slli	a5,a5,0x20
ffffffffc0209b40:	9381                	srli	a5,a5,0x20
ffffffffc0209b42:	9a3e                	add	s4,s4,a5
ffffffffc0209b44:	011b0b3b          	addw	s6,s6,a7
ffffffffc0209b48:	9bbe                	add	s7,s7,a5
ffffffffc0209b4a:	f58a78e3          	bgeu	s4,s8,ffffffffc0209a9a <sfs_io_nolock+0xc4>
ffffffffc0209b4e:	865a                	mv	a2,s6
ffffffffc0209b50:	1074                	addi	a3,sp,44
ffffffffc0209b52:	85ce                	mv	a1,s3
ffffffffc0209b54:	8556                	mv	a0,s5
ffffffffc0209b56:	c15ff0ef          	jal	ffffffffc020976a <sfs_bmap_load_nolock>
ffffffffc0209b5a:	e529                	bnez	a0,ffffffffc0209ba4 <sfs_io_nolock+0x1ce>
ffffffffc0209b5c:	56b2                	lw	a3,44(sp)
ffffffffc0209b5e:	85de                	mv	a1,s7
ffffffffc0209b60:	8556                	mv	a0,s5
ffffffffc0209b62:	4701                	li	a4,0
ffffffffc0209b64:	414c0633          	sub	a2,s8,s4
ffffffffc0209b68:	9c82                	jalr	s9
ffffffffc0209b6a:	01440833          	add	a6,s0,s4
ffffffffc0209b6e:	f90d                	bnez	a0,ffffffffc0209aa0 <sfs_io_nolock+0xca>
ffffffffc0209b70:	8826                	mv	a6,s1
ffffffffc0209b72:	8a62                	mv	s4,s8
ffffffffc0209b74:	b735                	j	ffffffffc0209aa0 <sfs_io_nolock+0xca>
ffffffffc0209b76:	84be                	mv	s1,a5
ffffffffc0209b78:	00001d17          	auipc	s10,0x1
ffffffffc0209b7c:	4c2d0d13          	addi	s10,s10,1218 # ffffffffc020b03a <sfs_rblock>
ffffffffc0209b80:	00001c97          	auipc	s9,0x1
ffffffffc0209b84:	57ec8c93          	addi	s9,s9,1406 # ffffffffc020b0fe <sfs_rbuf>
ffffffffc0209b88:	bd4d                	j	ffffffffc0209a3a <sfs_io_nolock+0x64>
ffffffffc0209b8a:	4a01                	li	s4,0
ffffffffc0209b8c:	bf11                	j	ffffffffc0209aa0 <sfs_io_nolock+0xca>
ffffffffc0209b8e:	640a                	ld	s0,128(sp)
ffffffffc0209b90:	60aa                	ld	ra,136(sp)
ffffffffc0209b92:	6ae6                	ld	s5,88(sp)
ffffffffc0209b94:	6ba6                	ld	s7,72(sp)
ffffffffc0209b96:	7ce2                	ld	s9,56(sp)
ffffffffc0209b98:	7d42                	ld	s10,48(sp)
ffffffffc0209b9a:	74e6                	ld	s1,120(sp)
ffffffffc0209b9c:	7946                	ld	s2,112(sp)
ffffffffc0209b9e:	79a6                	ld	s3,104(sp)
ffffffffc0209ba0:	6149                	addi	sp,sp,144
ffffffffc0209ba2:	8082                	ret
ffffffffc0209ba4:	01440833          	add	a6,s0,s4
ffffffffc0209ba8:	bde5                	j	ffffffffc0209aa0 <sfs_io_nolock+0xca>
ffffffffc0209baa:	5575                	li	a0,-3
ffffffffc0209bac:	bf39                	j	ffffffffc0209aca <sfs_io_nolock+0xf4>
ffffffffc0209bae:	00005697          	auipc	a3,0x5
ffffffffc0209bb2:	cea68693          	addi	a3,a3,-790 # ffffffffc020e898 <etext+0x2fc2>
ffffffffc0209bb6:	00002617          	auipc	a2,0x2
ffffffffc0209bba:	1da60613          	addi	a2,a2,474 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209bbe:	22b00593          	li	a1,555
ffffffffc0209bc2:	00005517          	auipc	a0,0x5
ffffffffc0209bc6:	b3650513          	addi	a0,a0,-1226 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209bca:	f0d2                	sd	s4,96(sp)
ffffffffc0209bcc:	ecd6                	sd	s5,88(sp)
ffffffffc0209bce:	e8da                	sd	s6,80(sp)
ffffffffc0209bd0:	e4de                	sd	s7,72(sp)
ffffffffc0209bd2:	e0e2                	sd	s8,64(sp)
ffffffffc0209bd4:	fc66                	sd	s9,56(sp)
ffffffffc0209bd6:	f86a                	sd	s10,48(sp)
ffffffffc0209bd8:	e54f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209bdc <sfs_read>:
ffffffffc0209bdc:	7139                	addi	sp,sp,-64
ffffffffc0209bde:	f04a                	sd	s2,32(sp)
ffffffffc0209be0:	06853903          	ld	s2,104(a0)
ffffffffc0209be4:	fc06                	sd	ra,56(sp)
ffffffffc0209be6:	f822                	sd	s0,48(sp)
ffffffffc0209be8:	f426                	sd	s1,40(sp)
ffffffffc0209bea:	ec4e                	sd	s3,24(sp)
ffffffffc0209bec:	04090e63          	beqz	s2,ffffffffc0209c48 <sfs_read+0x6c>
ffffffffc0209bf0:	0b092783          	lw	a5,176(s2)
ffffffffc0209bf4:	ebb1                	bnez	a5,ffffffffc0209c48 <sfs_read+0x6c>
ffffffffc0209bf6:	4d38                	lw	a4,88(a0)
ffffffffc0209bf8:	6785                	lui	a5,0x1
ffffffffc0209bfa:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209bfe:	842a                	mv	s0,a0
ffffffffc0209c00:	06f71463          	bne	a4,a5,ffffffffc0209c68 <sfs_read+0x8c>
ffffffffc0209c04:	02050993          	addi	s3,a0,32
ffffffffc0209c08:	854e                	mv	a0,s3
ffffffffc0209c0a:	84ae                	mv	s1,a1
ffffffffc0209c0c:	bcdfa0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0209c10:	6c9c                	ld	a5,24(s1)
ffffffffc0209c12:	6494                	ld	a3,8(s1)
ffffffffc0209c14:	6090                	ld	a2,0(s1)
ffffffffc0209c16:	85a2                	mv	a1,s0
ffffffffc0209c18:	e43e                	sd	a5,8(sp)
ffffffffc0209c1a:	854a                	mv	a0,s2
ffffffffc0209c1c:	0038                	addi	a4,sp,8
ffffffffc0209c1e:	4781                	li	a5,0
ffffffffc0209c20:	db7ff0ef          	jal	ffffffffc02099d6 <sfs_io_nolock>
ffffffffc0209c24:	65a2                	ld	a1,8(sp)
ffffffffc0209c26:	842a                	mv	s0,a0
ffffffffc0209c28:	ed81                	bnez	a1,ffffffffc0209c40 <sfs_read+0x64>
ffffffffc0209c2a:	854e                	mv	a0,s3
ffffffffc0209c2c:	ba9fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0209c30:	70e2                	ld	ra,56(sp)
ffffffffc0209c32:	8522                	mv	a0,s0
ffffffffc0209c34:	7442                	ld	s0,48(sp)
ffffffffc0209c36:	74a2                	ld	s1,40(sp)
ffffffffc0209c38:	7902                	ld	s2,32(sp)
ffffffffc0209c3a:	69e2                	ld	s3,24(sp)
ffffffffc0209c3c:	6121                	addi	sp,sp,64
ffffffffc0209c3e:	8082                	ret
ffffffffc0209c40:	8526                	mv	a0,s1
ffffffffc0209c42:	c49fb0ef          	jal	ffffffffc020588a <iobuf_skip>
ffffffffc0209c46:	b7d5                	j	ffffffffc0209c2a <sfs_read+0x4e>
ffffffffc0209c48:	00005697          	auipc	a3,0x5
ffffffffc0209c4c:	ae068693          	addi	a3,a3,-1312 # ffffffffc020e728 <etext+0x2e52>
ffffffffc0209c50:	00002617          	auipc	a2,0x2
ffffffffc0209c54:	14060613          	addi	a2,a2,320 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209c58:	29b00593          	li	a1,667
ffffffffc0209c5c:	00005517          	auipc	a0,0x5
ffffffffc0209c60:	a9c50513          	addi	a0,a0,-1380 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209c64:	dc8f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209c68:	823ff0ef          	jal	ffffffffc020948a <sfs_io.part.0>

ffffffffc0209c6c <sfs_write>:
ffffffffc0209c6c:	7139                	addi	sp,sp,-64
ffffffffc0209c6e:	f04a                	sd	s2,32(sp)
ffffffffc0209c70:	06853903          	ld	s2,104(a0)
ffffffffc0209c74:	fc06                	sd	ra,56(sp)
ffffffffc0209c76:	f822                	sd	s0,48(sp)
ffffffffc0209c78:	f426                	sd	s1,40(sp)
ffffffffc0209c7a:	ec4e                	sd	s3,24(sp)
ffffffffc0209c7c:	04090e63          	beqz	s2,ffffffffc0209cd8 <sfs_write+0x6c>
ffffffffc0209c80:	0b092783          	lw	a5,176(s2)
ffffffffc0209c84:	ebb1                	bnez	a5,ffffffffc0209cd8 <sfs_write+0x6c>
ffffffffc0209c86:	4d38                	lw	a4,88(a0)
ffffffffc0209c88:	6785                	lui	a5,0x1
ffffffffc0209c8a:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209c8e:	842a                	mv	s0,a0
ffffffffc0209c90:	06f71463          	bne	a4,a5,ffffffffc0209cf8 <sfs_write+0x8c>
ffffffffc0209c94:	02050993          	addi	s3,a0,32
ffffffffc0209c98:	854e                	mv	a0,s3
ffffffffc0209c9a:	84ae                	mv	s1,a1
ffffffffc0209c9c:	b3dfa0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0209ca0:	6c9c                	ld	a5,24(s1)
ffffffffc0209ca2:	6494                	ld	a3,8(s1)
ffffffffc0209ca4:	6090                	ld	a2,0(s1)
ffffffffc0209ca6:	85a2                	mv	a1,s0
ffffffffc0209ca8:	e43e                	sd	a5,8(sp)
ffffffffc0209caa:	854a                	mv	a0,s2
ffffffffc0209cac:	0038                	addi	a4,sp,8
ffffffffc0209cae:	4785                	li	a5,1
ffffffffc0209cb0:	d27ff0ef          	jal	ffffffffc02099d6 <sfs_io_nolock>
ffffffffc0209cb4:	65a2                	ld	a1,8(sp)
ffffffffc0209cb6:	842a                	mv	s0,a0
ffffffffc0209cb8:	ed81                	bnez	a1,ffffffffc0209cd0 <sfs_write+0x64>
ffffffffc0209cba:	854e                	mv	a0,s3
ffffffffc0209cbc:	b19fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0209cc0:	70e2                	ld	ra,56(sp)
ffffffffc0209cc2:	8522                	mv	a0,s0
ffffffffc0209cc4:	7442                	ld	s0,48(sp)
ffffffffc0209cc6:	74a2                	ld	s1,40(sp)
ffffffffc0209cc8:	7902                	ld	s2,32(sp)
ffffffffc0209cca:	69e2                	ld	s3,24(sp)
ffffffffc0209ccc:	6121                	addi	sp,sp,64
ffffffffc0209cce:	8082                	ret
ffffffffc0209cd0:	8526                	mv	a0,s1
ffffffffc0209cd2:	bb9fb0ef          	jal	ffffffffc020588a <iobuf_skip>
ffffffffc0209cd6:	b7d5                	j	ffffffffc0209cba <sfs_write+0x4e>
ffffffffc0209cd8:	00005697          	auipc	a3,0x5
ffffffffc0209cdc:	a5068693          	addi	a3,a3,-1456 # ffffffffc020e728 <etext+0x2e52>
ffffffffc0209ce0:	00002617          	auipc	a2,0x2
ffffffffc0209ce4:	0b060613          	addi	a2,a2,176 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209ce8:	29b00593          	li	a1,667
ffffffffc0209cec:	00005517          	auipc	a0,0x5
ffffffffc0209cf0:	a0c50513          	addi	a0,a0,-1524 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209cf4:	d38f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209cf8:	f92ff0ef          	jal	ffffffffc020948a <sfs_io.part.0>

ffffffffc0209cfc <sfs_dirent_read_nolock>:
ffffffffc0209cfc:	619c                	ld	a5,0(a1)
ffffffffc0209cfe:	7139                	addi	sp,sp,-64
ffffffffc0209d00:	f426                	sd	s1,40(sp)
ffffffffc0209d02:	84b6                	mv	s1,a3
ffffffffc0209d04:	0047d683          	lhu	a3,4(a5)
ffffffffc0209d08:	fc06                	sd	ra,56(sp)
ffffffffc0209d0a:	f822                	sd	s0,48(sp)
ffffffffc0209d0c:	4709                	li	a4,2
ffffffffc0209d0e:	04e69963          	bne	a3,a4,ffffffffc0209d60 <sfs_dirent_read_nolock+0x64>
ffffffffc0209d12:	479c                	lw	a5,8(a5)
ffffffffc0209d14:	04f67663          	bgeu	a2,a5,ffffffffc0209d60 <sfs_dirent_read_nolock+0x64>
ffffffffc0209d18:	0874                	addi	a3,sp,28
ffffffffc0209d1a:	842a                	mv	s0,a0
ffffffffc0209d1c:	a4fff0ef          	jal	ffffffffc020976a <sfs_bmap_load_nolock>
ffffffffc0209d20:	c511                	beqz	a0,ffffffffc0209d2c <sfs_dirent_read_nolock+0x30>
ffffffffc0209d22:	70e2                	ld	ra,56(sp)
ffffffffc0209d24:	7442                	ld	s0,48(sp)
ffffffffc0209d26:	74a2                	ld	s1,40(sp)
ffffffffc0209d28:	6121                	addi	sp,sp,64
ffffffffc0209d2a:	8082                	ret
ffffffffc0209d2c:	45f2                	lw	a1,28(sp)
ffffffffc0209d2e:	c9a9                	beqz	a1,ffffffffc0209d80 <sfs_dirent_read_nolock+0x84>
ffffffffc0209d30:	405c                	lw	a5,4(s0)
ffffffffc0209d32:	04f5f763          	bgeu	a1,a5,ffffffffc0209d80 <sfs_dirent_read_nolock+0x84>
ffffffffc0209d36:	7c08                	ld	a0,56(s0)
ffffffffc0209d38:	e42e                	sd	a1,8(sp)
ffffffffc0209d3a:	204010ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc0209d3e:	ed39                	bnez	a0,ffffffffc0209d9c <sfs_dirent_read_nolock+0xa0>
ffffffffc0209d40:	66a2                	ld	a3,8(sp)
ffffffffc0209d42:	8522                	mv	a0,s0
ffffffffc0209d44:	4701                	li	a4,0
ffffffffc0209d46:	10400613          	li	a2,260
ffffffffc0209d4a:	85a6                	mv	a1,s1
ffffffffc0209d4c:	3b2010ef          	jal	ffffffffc020b0fe <sfs_rbuf>
ffffffffc0209d50:	f969                	bnez	a0,ffffffffc0209d22 <sfs_dirent_read_nolock+0x26>
ffffffffc0209d52:	100481a3          	sb	zero,259(s1)
ffffffffc0209d56:	70e2                	ld	ra,56(sp)
ffffffffc0209d58:	7442                	ld	s0,48(sp)
ffffffffc0209d5a:	74a2                	ld	s1,40(sp)
ffffffffc0209d5c:	6121                	addi	sp,sp,64
ffffffffc0209d5e:	8082                	ret
ffffffffc0209d60:	00005697          	auipc	a3,0x5
ffffffffc0209d64:	b5868693          	addi	a3,a3,-1192 # ffffffffc020e8b8 <etext+0x2fe2>
ffffffffc0209d68:	00002617          	auipc	a2,0x2
ffffffffc0209d6c:	02860613          	addi	a2,a2,40 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209d70:	18e00593          	li	a1,398
ffffffffc0209d74:	00005517          	auipc	a0,0x5
ffffffffc0209d78:	98450513          	addi	a0,a0,-1660 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209d7c:	cb0f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209d80:	4054                	lw	a3,4(s0)
ffffffffc0209d82:	872e                	mv	a4,a1
ffffffffc0209d84:	00005617          	auipc	a2,0x5
ffffffffc0209d88:	9d460613          	addi	a2,a2,-1580 # ffffffffc020e758 <etext+0x2e82>
ffffffffc0209d8c:	05300593          	li	a1,83
ffffffffc0209d90:	00005517          	auipc	a0,0x5
ffffffffc0209d94:	96850513          	addi	a0,a0,-1688 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209d98:	c94f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209d9c:	00005697          	auipc	a3,0x5
ffffffffc0209da0:	9f468693          	addi	a3,a3,-1548 # ffffffffc020e790 <etext+0x2eba>
ffffffffc0209da4:	00002617          	auipc	a2,0x2
ffffffffc0209da8:	fec60613          	addi	a2,a2,-20 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209dac:	19500593          	li	a1,405
ffffffffc0209db0:	00005517          	auipc	a0,0x5
ffffffffc0209db4:	94850513          	addi	a0,a0,-1720 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209db8:	c74f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209dbc <sfs_getdirentry>:
ffffffffc0209dbc:	715d                	addi	sp,sp,-80
ffffffffc0209dbe:	f052                	sd	s4,32(sp)
ffffffffc0209dc0:	8a2a                	mv	s4,a0
ffffffffc0209dc2:	10400513          	li	a0,260
ffffffffc0209dc6:	e85a                	sd	s6,16(sp)
ffffffffc0209dc8:	e486                	sd	ra,72(sp)
ffffffffc0209dca:	e0a2                	sd	s0,64(sp)
ffffffffc0209dcc:	8b2e                	mv	s6,a1
ffffffffc0209dce:	f6ff70ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc0209dd2:	0e050963          	beqz	a0,ffffffffc0209ec4 <sfs_getdirentry+0x108>
ffffffffc0209dd6:	ec56                	sd	s5,24(sp)
ffffffffc0209dd8:	068a3a83          	ld	s5,104(s4)
ffffffffc0209ddc:	0e0a8663          	beqz	s5,ffffffffc0209ec8 <sfs_getdirentry+0x10c>
ffffffffc0209de0:	0b0aa783          	lw	a5,176(s5)
ffffffffc0209de4:	0e079263          	bnez	a5,ffffffffc0209ec8 <sfs_getdirentry+0x10c>
ffffffffc0209de8:	058a2703          	lw	a4,88(s4)
ffffffffc0209dec:	6785                	lui	a5,0x1
ffffffffc0209dee:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209df2:	10f71063          	bne	a4,a5,ffffffffc0209ef2 <sfs_getdirentry+0x136>
ffffffffc0209df6:	f44e                	sd	s3,40(sp)
ffffffffc0209df8:	57fd                	li	a5,-1
ffffffffc0209dfa:	008b3983          	ld	s3,8(s6)
ffffffffc0209dfe:	17fe                	slli	a5,a5,0x3f
ffffffffc0209e00:	0ff78793          	addi	a5,a5,255
ffffffffc0209e04:	00f9f7b3          	and	a5,s3,a5
ffffffffc0209e08:	e3d5                	bnez	a5,ffffffffc0209eac <sfs_getdirentry+0xf0>
ffffffffc0209e0a:	000a3783          	ld	a5,0(s4)
ffffffffc0209e0e:	0089d993          	srli	s3,s3,0x8
ffffffffc0209e12:	2981                	sext.w	s3,s3
ffffffffc0209e14:	479c                	lw	a5,8(a5)
ffffffffc0209e16:	0b37e163          	bltu	a5,s3,ffffffffc0209eb8 <sfs_getdirentry+0xfc>
ffffffffc0209e1a:	f84a                	sd	s2,48(sp)
ffffffffc0209e1c:	892a                	mv	s2,a0
ffffffffc0209e1e:	020a0513          	addi	a0,s4,32
ffffffffc0209e22:	e45e                	sd	s7,8(sp)
ffffffffc0209e24:	9b5fa0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0209e28:	000a3783          	ld	a5,0(s4)
ffffffffc0209e2c:	0087ab83          	lw	s7,8(a5)
ffffffffc0209e30:	07705c63          	blez	s7,ffffffffc0209ea8 <sfs_getdirentry+0xec>
ffffffffc0209e34:	fc26                	sd	s1,56(sp)
ffffffffc0209e36:	4481                	li	s1,0
ffffffffc0209e38:	a811                	j	ffffffffc0209e4c <sfs_getdirentry+0x90>
ffffffffc0209e3a:	00092783          	lw	a5,0(s2)
ffffffffc0209e3e:	c781                	beqz	a5,ffffffffc0209e46 <sfs_getdirentry+0x8a>
ffffffffc0209e40:	02098463          	beqz	s3,ffffffffc0209e68 <sfs_getdirentry+0xac>
ffffffffc0209e44:	39fd                	addiw	s3,s3,-1
ffffffffc0209e46:	2485                	addiw	s1,s1,1
ffffffffc0209e48:	049b8d63          	beq	s7,s1,ffffffffc0209ea2 <sfs_getdirentry+0xe6>
ffffffffc0209e4c:	86ca                	mv	a3,s2
ffffffffc0209e4e:	8626                	mv	a2,s1
ffffffffc0209e50:	85d2                	mv	a1,s4
ffffffffc0209e52:	8556                	mv	a0,s5
ffffffffc0209e54:	ea9ff0ef          	jal	ffffffffc0209cfc <sfs_dirent_read_nolock>
ffffffffc0209e58:	842a                	mv	s0,a0
ffffffffc0209e5a:	d165                	beqz	a0,ffffffffc0209e3a <sfs_getdirentry+0x7e>
ffffffffc0209e5c:	74e2                	ld	s1,56(sp)
ffffffffc0209e5e:	020a0513          	addi	a0,s4,32
ffffffffc0209e62:	973fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0209e66:	a005                	j	ffffffffc0209e86 <sfs_getdirentry+0xca>
ffffffffc0209e68:	020a0513          	addi	a0,s4,32
ffffffffc0209e6c:	969fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc0209e70:	855a                	mv	a0,s6
ffffffffc0209e72:	00490593          	addi	a1,s2,4
ffffffffc0209e76:	4701                	li	a4,0
ffffffffc0209e78:	4685                	li	a3,1
ffffffffc0209e7a:	10000613          	li	a2,256
ffffffffc0209e7e:	989fb0ef          	jal	ffffffffc0205806 <iobuf_move>
ffffffffc0209e82:	74e2                	ld	s1,56(sp)
ffffffffc0209e84:	842a                	mv	s0,a0
ffffffffc0209e86:	854a                	mv	a0,s2
ffffffffc0209e88:	f5bf70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0209e8c:	7942                	ld	s2,48(sp)
ffffffffc0209e8e:	79a2                	ld	s3,40(sp)
ffffffffc0209e90:	6ae2                	ld	s5,24(sp)
ffffffffc0209e92:	6ba2                	ld	s7,8(sp)
ffffffffc0209e94:	60a6                	ld	ra,72(sp)
ffffffffc0209e96:	8522                	mv	a0,s0
ffffffffc0209e98:	6406                	ld	s0,64(sp)
ffffffffc0209e9a:	7a02                	ld	s4,32(sp)
ffffffffc0209e9c:	6b42                	ld	s6,16(sp)
ffffffffc0209e9e:	6161                	addi	sp,sp,80
ffffffffc0209ea0:	8082                	ret
ffffffffc0209ea2:	74e2                	ld	s1,56(sp)
ffffffffc0209ea4:	5441                	li	s0,-16
ffffffffc0209ea6:	bf65                	j	ffffffffc0209e5e <sfs_getdirentry+0xa2>
ffffffffc0209ea8:	5441                	li	s0,-16
ffffffffc0209eaa:	bf55                	j	ffffffffc0209e5e <sfs_getdirentry+0xa2>
ffffffffc0209eac:	f37f70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0209eb0:	5475                	li	s0,-3
ffffffffc0209eb2:	79a2                	ld	s3,40(sp)
ffffffffc0209eb4:	6ae2                	ld	s5,24(sp)
ffffffffc0209eb6:	bff9                	j	ffffffffc0209e94 <sfs_getdirentry+0xd8>
ffffffffc0209eb8:	f2bf70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc0209ebc:	5441                	li	s0,-16
ffffffffc0209ebe:	79a2                	ld	s3,40(sp)
ffffffffc0209ec0:	6ae2                	ld	s5,24(sp)
ffffffffc0209ec2:	bfc9                	j	ffffffffc0209e94 <sfs_getdirentry+0xd8>
ffffffffc0209ec4:	5471                	li	s0,-4
ffffffffc0209ec6:	b7f9                	j	ffffffffc0209e94 <sfs_getdirentry+0xd8>
ffffffffc0209ec8:	00005697          	auipc	a3,0x5
ffffffffc0209ecc:	86068693          	addi	a3,a3,-1952 # ffffffffc020e728 <etext+0x2e52>
ffffffffc0209ed0:	00002617          	auipc	a2,0x2
ffffffffc0209ed4:	ec060613          	addi	a2,a2,-320 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209ed8:	33f00593          	li	a1,831
ffffffffc0209edc:	00005517          	auipc	a0,0x5
ffffffffc0209ee0:	81c50513          	addi	a0,a0,-2020 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209ee4:	fc26                	sd	s1,56(sp)
ffffffffc0209ee6:	f84a                	sd	s2,48(sp)
ffffffffc0209ee8:	f44e                	sd	s3,40(sp)
ffffffffc0209eea:	e45e                	sd	s7,8(sp)
ffffffffc0209eec:	e062                	sd	s8,0(sp)
ffffffffc0209eee:	b3ef60ef          	jal	ffffffffc020022c <__panic>
ffffffffc0209ef2:	00004697          	auipc	a3,0x4
ffffffffc0209ef6:	7ce68693          	addi	a3,a3,1998 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc0209efa:	00002617          	auipc	a2,0x2
ffffffffc0209efe:	e9660613          	addi	a2,a2,-362 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc0209f02:	34000593          	li	a1,832
ffffffffc0209f06:	00004517          	auipc	a0,0x4
ffffffffc0209f0a:	7f250513          	addi	a0,a0,2034 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc0209f0e:	fc26                	sd	s1,56(sp)
ffffffffc0209f10:	f84a                	sd	s2,48(sp)
ffffffffc0209f12:	f44e                	sd	s3,40(sp)
ffffffffc0209f14:	e45e                	sd	s7,8(sp)
ffffffffc0209f16:	e062                	sd	s8,0(sp)
ffffffffc0209f18:	b14f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc0209f1c <sfs_truncfile>:
ffffffffc0209f1c:	080007b7          	lui	a5,0x8000
ffffffffc0209f20:	1ab7eb63          	bltu	a5,a1,ffffffffc020a0d6 <sfs_truncfile+0x1ba>
ffffffffc0209f24:	7159                	addi	sp,sp,-112
ffffffffc0209f26:	e0d2                	sd	s4,64(sp)
ffffffffc0209f28:	06853a03          	ld	s4,104(a0)
ffffffffc0209f2c:	e8ca                	sd	s2,80(sp)
ffffffffc0209f2e:	e4ce                	sd	s3,72(sp)
ffffffffc0209f30:	f486                	sd	ra,104(sp)
ffffffffc0209f32:	f0a2                	sd	s0,96(sp)
ffffffffc0209f34:	fc56                	sd	s5,56(sp)
ffffffffc0209f36:	892a                	mv	s2,a0
ffffffffc0209f38:	89ae                	mv	s3,a1
ffffffffc0209f3a:	1a0a0163          	beqz	s4,ffffffffc020a0dc <sfs_truncfile+0x1c0>
ffffffffc0209f3e:	0b0a2783          	lw	a5,176(s4)
ffffffffc0209f42:	18079d63          	bnez	a5,ffffffffc020a0dc <sfs_truncfile+0x1c0>
ffffffffc0209f46:	4d38                	lw	a4,88(a0)
ffffffffc0209f48:	6785                	lui	a5,0x1
ffffffffc0209f4a:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209f4e:	6405                	lui	s0,0x1
ffffffffc0209f50:	1cf71963          	bne	a4,a5,ffffffffc020a122 <sfs_truncfile+0x206>
ffffffffc0209f54:	00053a83          	ld	s5,0(a0)
ffffffffc0209f58:	147d                	addi	s0,s0,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0209f5a:	942e                	add	s0,s0,a1
ffffffffc0209f5c:	000ae783          	lwu	a5,0(s5)
ffffffffc0209f60:	8031                	srli	s0,s0,0xc
ffffffffc0209f62:	2401                	sext.w	s0,s0
ffffffffc0209f64:	02b79063          	bne	a5,a1,ffffffffc0209f84 <sfs_truncfile+0x68>
ffffffffc0209f68:	008aa703          	lw	a4,8(s5)
ffffffffc0209f6c:	4781                	li	a5,0
ffffffffc0209f6e:	1c871c63          	bne	a4,s0,ffffffffc020a146 <sfs_truncfile+0x22a>
ffffffffc0209f72:	70a6                	ld	ra,104(sp)
ffffffffc0209f74:	7406                	ld	s0,96(sp)
ffffffffc0209f76:	6946                	ld	s2,80(sp)
ffffffffc0209f78:	69a6                	ld	s3,72(sp)
ffffffffc0209f7a:	6a06                	ld	s4,64(sp)
ffffffffc0209f7c:	7ae2                	ld	s5,56(sp)
ffffffffc0209f7e:	853e                	mv	a0,a5
ffffffffc0209f80:	6165                	addi	sp,sp,112
ffffffffc0209f82:	8082                	ret
ffffffffc0209f84:	02050513          	addi	a0,a0,32
ffffffffc0209f88:	eca6                	sd	s1,88(sp)
ffffffffc0209f8a:	84ffa0ef          	jal	ffffffffc02047d8 <down>
ffffffffc0209f8e:	008aa483          	lw	s1,8(s5)
ffffffffc0209f92:	0c84e363          	bltu	s1,s0,ffffffffc020a058 <sfs_truncfile+0x13c>
ffffffffc0209f96:	0c947e63          	bgeu	s0,s1,ffffffffc020a072 <sfs_truncfile+0x156>
ffffffffc0209f9a:	48ad                	li	a7,11
ffffffffc0209f9c:	4305                	li	t1,1
ffffffffc0209f9e:	a895                	j	ffffffffc020a012 <sfs_truncfile+0xf6>
ffffffffc0209fa0:	37cd                	addiw	a5,a5,-13
ffffffffc0209fa2:	3ff00693          	li	a3,1023
ffffffffc0209fa6:	04f6ef63          	bltu	a3,a5,ffffffffc020a004 <sfs_truncfile+0xe8>
ffffffffc0209faa:	03c82683          	lw	a3,60(a6)
ffffffffc0209fae:	cab9                	beqz	a3,ffffffffc020a004 <sfs_truncfile+0xe8>
ffffffffc0209fb0:	004a2603          	lw	a2,4(s4)
ffffffffc0209fb4:	1ac6fb63          	bgeu	a3,a2,ffffffffc020a16a <sfs_truncfile+0x24e>
ffffffffc0209fb8:	038a3503          	ld	a0,56(s4)
ffffffffc0209fbc:	85b6                	mv	a1,a3
ffffffffc0209fbe:	e436                	sd	a3,8(sp)
ffffffffc0209fc0:	e842                	sd	a6,16(sp)
ffffffffc0209fc2:	ec3e                	sd	a5,24(sp)
ffffffffc0209fc4:	77b000ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc0209fc8:	66a2                	ld	a3,8(sp)
ffffffffc0209fca:	6842                	ld	a6,16(sp)
ffffffffc0209fcc:	67e2                	ld	a5,24(sp)
ffffffffc0209fce:	1a051d63          	bnez	a0,ffffffffc020a188 <sfs_truncfile+0x26c>
ffffffffc0209fd2:	02079613          	slli	a2,a5,0x20
ffffffffc0209fd6:	01e65713          	srli	a4,a2,0x1e
ffffffffc0209fda:	102c                	addi	a1,sp,40
ffffffffc0209fdc:	4611                	li	a2,4
ffffffffc0209fde:	8552                	mv	a0,s4
ffffffffc0209fe0:	ec42                	sd	a6,24(sp)
ffffffffc0209fe2:	e83a                	sd	a4,16(sp)
ffffffffc0209fe4:	e436                	sd	a3,8(sp)
ffffffffc0209fe6:	d602                	sw	zero,44(sp)
ffffffffc0209fe8:	116010ef          	jal	ffffffffc020b0fe <sfs_rbuf>
ffffffffc0209fec:	87aa                	mv	a5,a0
ffffffffc0209fee:	e941                	bnez	a0,ffffffffc020a07e <sfs_truncfile+0x162>
ffffffffc0209ff0:	57a2                	lw	a5,40(sp)
ffffffffc0209ff2:	66a2                	ld	a3,8(sp)
ffffffffc0209ff4:	6742                	ld	a4,16(sp)
ffffffffc0209ff6:	6862                	ld	a6,24(sp)
ffffffffc0209ff8:	48ad                	li	a7,11
ffffffffc0209ffa:	4305                	li	t1,1
ffffffffc0209ffc:	ebd5                	bnez	a5,ffffffffc020a0b0 <sfs_truncfile+0x194>
ffffffffc0209ffe:	00882703          	lw	a4,8(a6)
ffffffffc020a002:	377d                	addiw	a4,a4,-1 # 7ffffff <_binary_bin_sfs_img_size+0x7f8acff>
ffffffffc020a004:	00e82423          	sw	a4,8(a6)
ffffffffc020a008:	00693823          	sd	t1,16(s2)
ffffffffc020a00c:	34fd                	addiw	s1,s1,-1
ffffffffc020a00e:	04940e63          	beq	s0,s1,ffffffffc020a06a <sfs_truncfile+0x14e>
ffffffffc020a012:	00093803          	ld	a6,0(s2)
ffffffffc020a016:	00882783          	lw	a5,8(a6)
ffffffffc020a01a:	0e078363          	beqz	a5,ffffffffc020a100 <sfs_truncfile+0x1e4>
ffffffffc020a01e:	fff7871b          	addiw	a4,a5,-1
ffffffffc020a022:	f6e8efe3          	bltu	a7,a4,ffffffffc0209fa0 <sfs_truncfile+0x84>
ffffffffc020a026:	02071693          	slli	a3,a4,0x20
ffffffffc020a02a:	01e6d793          	srli	a5,a3,0x1e
ffffffffc020a02e:	97c2                	add	a5,a5,a6
ffffffffc020a030:	47cc                	lw	a1,12(a5)
ffffffffc020a032:	d9e9                	beqz	a1,ffffffffc020a004 <sfs_truncfile+0xe8>
ffffffffc020a034:	8552                	mv	a0,s4
ffffffffc020a036:	e83e                	sd	a5,16(sp)
ffffffffc020a038:	e442                	sd	a6,8(sp)
ffffffffc020a03a:	c74ff0ef          	jal	ffffffffc02094ae <sfs_block_free>
ffffffffc020a03e:	67c2                	ld	a5,16(sp)
ffffffffc020a040:	6822                	ld	a6,8(sp)
ffffffffc020a042:	48ad                	li	a7,11
ffffffffc020a044:	0007a623          	sw	zero,12(a5)
ffffffffc020a048:	00882703          	lw	a4,8(a6)
ffffffffc020a04c:	4305                	li	t1,1
ffffffffc020a04e:	377d                	addiw	a4,a4,-1
ffffffffc020a050:	bf55                	j	ffffffffc020a004 <sfs_truncfile+0xe8>
ffffffffc020a052:	2485                	addiw	s1,s1,1
ffffffffc020a054:	00940b63          	beq	s0,s1,ffffffffc020a06a <sfs_truncfile+0x14e>
ffffffffc020a058:	4681                	li	a3,0
ffffffffc020a05a:	8626                	mv	a2,s1
ffffffffc020a05c:	85ca                	mv	a1,s2
ffffffffc020a05e:	8552                	mv	a0,s4
ffffffffc020a060:	f0aff0ef          	jal	ffffffffc020976a <sfs_bmap_load_nolock>
ffffffffc020a064:	87aa                	mv	a5,a0
ffffffffc020a066:	d575                	beqz	a0,ffffffffc020a052 <sfs_truncfile+0x136>
ffffffffc020a068:	a819                	j	ffffffffc020a07e <sfs_truncfile+0x162>
ffffffffc020a06a:	008aa783          	lw	a5,8(s5)
ffffffffc020a06e:	02879063          	bne	a5,s0,ffffffffc020a08e <sfs_truncfile+0x172>
ffffffffc020a072:	4785                	li	a5,1
ffffffffc020a074:	013aa023          	sw	s3,0(s5)
ffffffffc020a078:	00f93823          	sd	a5,16(s2)
ffffffffc020a07c:	4781                	li	a5,0
ffffffffc020a07e:	02090513          	addi	a0,s2,32
ffffffffc020a082:	e43e                	sd	a5,8(sp)
ffffffffc020a084:	f50fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a088:	67a2                	ld	a5,8(sp)
ffffffffc020a08a:	64e6                	ld	s1,88(sp)
ffffffffc020a08c:	b5dd                	j	ffffffffc0209f72 <sfs_truncfile+0x56>
ffffffffc020a08e:	00005697          	auipc	a3,0x5
ffffffffc020a092:	8e268693          	addi	a3,a3,-1822 # ffffffffc020e970 <etext+0x309a>
ffffffffc020a096:	00002617          	auipc	a2,0x2
ffffffffc020a09a:	cfa60613          	addi	a2,a2,-774 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a09e:	3cf00593          	li	a1,975
ffffffffc020a0a2:	00004517          	auipc	a0,0x4
ffffffffc020a0a6:	65650513          	addi	a0,a0,1622 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a0aa:	f85a                	sd	s6,48(sp)
ffffffffc020a0ac:	980f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a0b0:	4611                	li	a2,4
ffffffffc020a0b2:	106c                	addi	a1,sp,44
ffffffffc020a0b4:	8552                	mv	a0,s4
ffffffffc020a0b6:	e442                	sd	a6,8(sp)
ffffffffc020a0b8:	0c6010ef          	jal	ffffffffc020b17e <sfs_wbuf>
ffffffffc020a0bc:	87aa                	mv	a5,a0
ffffffffc020a0be:	f161                	bnez	a0,ffffffffc020a07e <sfs_truncfile+0x162>
ffffffffc020a0c0:	55a2                	lw	a1,40(sp)
ffffffffc020a0c2:	8552                	mv	a0,s4
ffffffffc020a0c4:	beaff0ef          	jal	ffffffffc02094ae <sfs_block_free>
ffffffffc020a0c8:	6822                	ld	a6,8(sp)
ffffffffc020a0ca:	4305                	li	t1,1
ffffffffc020a0cc:	48ad                	li	a7,11
ffffffffc020a0ce:	00882703          	lw	a4,8(a6)
ffffffffc020a0d2:	377d                	addiw	a4,a4,-1
ffffffffc020a0d4:	bf05                	j	ffffffffc020a004 <sfs_truncfile+0xe8>
ffffffffc020a0d6:	57f5                	li	a5,-3
ffffffffc020a0d8:	853e                	mv	a0,a5
ffffffffc020a0da:	8082                	ret
ffffffffc020a0dc:	00004697          	auipc	a3,0x4
ffffffffc020a0e0:	64c68693          	addi	a3,a3,1612 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020a0e4:	00002617          	auipc	a2,0x2
ffffffffc020a0e8:	cac60613          	addi	a2,a2,-852 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a0ec:	3ae00593          	li	a1,942
ffffffffc020a0f0:	00004517          	auipc	a0,0x4
ffffffffc020a0f4:	60850513          	addi	a0,a0,1544 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a0f8:	eca6                	sd	s1,88(sp)
ffffffffc020a0fa:	f85a                	sd	s6,48(sp)
ffffffffc020a0fc:	930f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a100:	00005697          	auipc	a3,0x5
ffffffffc020a104:	82068693          	addi	a3,a3,-2016 # ffffffffc020e920 <etext+0x304a>
ffffffffc020a108:	00002617          	auipc	a2,0x2
ffffffffc020a10c:	c8860613          	addi	a2,a2,-888 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a110:	17b00593          	li	a1,379
ffffffffc020a114:	00004517          	auipc	a0,0x4
ffffffffc020a118:	5e450513          	addi	a0,a0,1508 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a11c:	f85a                	sd	s6,48(sp)
ffffffffc020a11e:	90ef60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a122:	00004697          	auipc	a3,0x4
ffffffffc020a126:	59e68693          	addi	a3,a3,1438 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020a12a:	00002617          	auipc	a2,0x2
ffffffffc020a12e:	c6660613          	addi	a2,a2,-922 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a132:	3af00593          	li	a1,943
ffffffffc020a136:	00004517          	auipc	a0,0x4
ffffffffc020a13a:	5c250513          	addi	a0,a0,1474 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a13e:	eca6                	sd	s1,88(sp)
ffffffffc020a140:	f85a                	sd	s6,48(sp)
ffffffffc020a142:	8eaf60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a146:	00004697          	auipc	a3,0x4
ffffffffc020a14a:	7c268693          	addi	a3,a3,1986 # ffffffffc020e908 <etext+0x3032>
ffffffffc020a14e:	00002617          	auipc	a2,0x2
ffffffffc020a152:	c4260613          	addi	a2,a2,-958 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a156:	3b600593          	li	a1,950
ffffffffc020a15a:	00004517          	auipc	a0,0x4
ffffffffc020a15e:	59e50513          	addi	a0,a0,1438 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a162:	eca6                	sd	s1,88(sp)
ffffffffc020a164:	f85a                	sd	s6,48(sp)
ffffffffc020a166:	8c6f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a16a:	8736                	mv	a4,a3
ffffffffc020a16c:	05300593          	li	a1,83
ffffffffc020a170:	86b2                	mv	a3,a2
ffffffffc020a172:	00004517          	auipc	a0,0x4
ffffffffc020a176:	58650513          	addi	a0,a0,1414 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a17a:	00004617          	auipc	a2,0x4
ffffffffc020a17e:	5de60613          	addi	a2,a2,1502 # ffffffffc020e758 <etext+0x2e82>
ffffffffc020a182:	f85a                	sd	s6,48(sp)
ffffffffc020a184:	8a8f60ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a188:	00004697          	auipc	a3,0x4
ffffffffc020a18c:	7b068693          	addi	a3,a3,1968 # ffffffffc020e938 <etext+0x3062>
ffffffffc020a190:	00002617          	auipc	a2,0x2
ffffffffc020a194:	c0060613          	addi	a2,a2,-1024 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a198:	12b00593          	li	a1,299
ffffffffc020a19c:	00004517          	auipc	a0,0x4
ffffffffc020a1a0:	55c50513          	addi	a0,a0,1372 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a1a4:	f85a                	sd	s6,48(sp)
ffffffffc020a1a6:	886f60ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a1aa <sfs_load_inode>:
ffffffffc020a1aa:	7139                	addi	sp,sp,-64
ffffffffc020a1ac:	fc06                	sd	ra,56(sp)
ffffffffc020a1ae:	f822                	sd	s0,48(sp)
ffffffffc020a1b0:	f426                	sd	s1,40(sp)
ffffffffc020a1b2:	f04a                	sd	s2,32(sp)
ffffffffc020a1b4:	84b2                	mv	s1,a2
ffffffffc020a1b6:	892a                	mv	s2,a0
ffffffffc020a1b8:	ec4e                	sd	s3,24(sp)
ffffffffc020a1ba:	89ae                	mv	s3,a1
ffffffffc020a1bc:	fd1fe0ef          	jal	ffffffffc020918c <lock_sfs_fs>
ffffffffc020a1c0:	8526                	mv	a0,s1
ffffffffc020a1c2:	45a9                	li	a1,10
ffffffffc020a1c4:	0a893403          	ld	s0,168(s2)
ffffffffc020a1c8:	6f8010ef          	jal	ffffffffc020b8c0 <hash32>
ffffffffc020a1cc:	02051793          	slli	a5,a0,0x20
ffffffffc020a1d0:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020a1d4:	00a406b3          	add	a3,s0,a0
ffffffffc020a1d8:	87b6                	mv	a5,a3
ffffffffc020a1da:	a029                	j	ffffffffc020a1e4 <sfs_load_inode+0x3a>
ffffffffc020a1dc:	fc07a703          	lw	a4,-64(a5)
ffffffffc020a1e0:	10970563          	beq	a4,s1,ffffffffc020a2ea <sfs_load_inode+0x140>
ffffffffc020a1e4:	679c                	ld	a5,8(a5)
ffffffffc020a1e6:	fef69be3          	bne	a3,a5,ffffffffc020a1dc <sfs_load_inode+0x32>
ffffffffc020a1ea:	04000513          	li	a0,64
ffffffffc020a1ee:	b4ff70ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020a1f2:	87aa                	mv	a5,a0
ffffffffc020a1f4:	10050b63          	beqz	a0,ffffffffc020a30a <sfs_load_inode+0x160>
ffffffffc020a1f8:	14048f63          	beqz	s1,ffffffffc020a356 <sfs_load_inode+0x1ac>
ffffffffc020a1fc:	00492703          	lw	a4,4(s2)
ffffffffc020a200:	14e4fb63          	bgeu	s1,a4,ffffffffc020a356 <sfs_load_inode+0x1ac>
ffffffffc020a204:	03893503          	ld	a0,56(s2)
ffffffffc020a208:	85a6                	mv	a1,s1
ffffffffc020a20a:	e43e                	sd	a5,8(sp)
ffffffffc020a20c:	533000ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc020a210:	16051263          	bnez	a0,ffffffffc020a374 <sfs_load_inode+0x1ca>
ffffffffc020a214:	65a2                	ld	a1,8(sp)
ffffffffc020a216:	4701                	li	a4,0
ffffffffc020a218:	86a6                	mv	a3,s1
ffffffffc020a21a:	04000613          	li	a2,64
ffffffffc020a21e:	854a                	mv	a0,s2
ffffffffc020a220:	6df000ef          	jal	ffffffffc020b0fe <sfs_rbuf>
ffffffffc020a224:	67a2                	ld	a5,8(sp)
ffffffffc020a226:	842a                	mv	s0,a0
ffffffffc020a228:	0e051e63          	bnez	a0,ffffffffc020a324 <sfs_load_inode+0x17a>
ffffffffc020a22c:	0067d703          	lhu	a4,6(a5)
ffffffffc020a230:	10070363          	beqz	a4,ffffffffc020a336 <sfs_load_inode+0x18c>
ffffffffc020a234:	6505                	lui	a0,0x1
ffffffffc020a236:	23550513          	addi	a0,a0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a23a:	e43e                	sd	a5,8(sp)
ffffffffc020a23c:	81cfe0ef          	jal	ffffffffc0208258 <__alloc_inode>
ffffffffc020a240:	67a2                	ld	a5,8(sp)
ffffffffc020a242:	842a                	mv	s0,a0
ffffffffc020a244:	cd79                	beqz	a0,ffffffffc020a322 <sfs_load_inode+0x178>
ffffffffc020a246:	0047d683          	lhu	a3,4(a5)
ffffffffc020a24a:	4705                	li	a4,1
ffffffffc020a24c:	0ee68063          	beq	a3,a4,ffffffffc020a32c <sfs_load_inode+0x182>
ffffffffc020a250:	4709                	li	a4,2
ffffffffc020a252:	00005597          	auipc	a1,0x5
ffffffffc020a256:	6be58593          	addi	a1,a1,1726 # ffffffffc020f910 <sfs_node_dirops>
ffffffffc020a25a:	16e69d63          	bne	a3,a4,ffffffffc020a3d4 <sfs_load_inode+0x22a>
ffffffffc020a25e:	864a                	mv	a2,s2
ffffffffc020a260:	8522                	mv	a0,s0
ffffffffc020a262:	e43e                	sd	a5,8(sp)
ffffffffc020a264:	810fe0ef          	jal	ffffffffc0208274 <inode_init>
ffffffffc020a268:	4c34                	lw	a3,88(s0)
ffffffffc020a26a:	6705                	lui	a4,0x1
ffffffffc020a26c:	23570713          	addi	a4,a4,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a270:	67a2                	ld	a5,8(sp)
ffffffffc020a272:	14e69163          	bne	a3,a4,ffffffffc020a3b4 <sfs_load_inode+0x20a>
ffffffffc020a276:	4585                	li	a1,1
ffffffffc020a278:	e01c                	sd	a5,0(s0)
ffffffffc020a27a:	c404                	sw	s1,8(s0)
ffffffffc020a27c:	00043823          	sd	zero,16(s0)
ffffffffc020a280:	cc0c                	sw	a1,24(s0)
ffffffffc020a282:	02040513          	addi	a0,s0,32
ffffffffc020a286:	e436                	sd	a3,8(sp)
ffffffffc020a288:	d44fa0ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc020a28c:	4c3c                	lw	a5,88(s0)
ffffffffc020a28e:	66a2                	ld	a3,8(sp)
ffffffffc020a290:	10d79263          	bne	a5,a3,ffffffffc020a394 <sfs_load_inode+0x1ea>
ffffffffc020a294:	0a093703          	ld	a4,160(s2)
ffffffffc020a298:	03840793          	addi	a5,s0,56
ffffffffc020a29c:	4408                	lw	a0,8(s0)
ffffffffc020a29e:	e31c                	sd	a5,0(a4)
ffffffffc020a2a0:	0af93023          	sd	a5,160(s2)
ffffffffc020a2a4:	09890793          	addi	a5,s2,152
ffffffffc020a2a8:	e038                	sd	a4,64(s0)
ffffffffc020a2aa:	fc1c                	sd	a5,56(s0)
ffffffffc020a2ac:	45a9                	li	a1,10
ffffffffc020a2ae:	0a893483          	ld	s1,168(s2)
ffffffffc020a2b2:	60e010ef          	jal	ffffffffc020b8c0 <hash32>
ffffffffc020a2b6:	02051713          	slli	a4,a0,0x20
ffffffffc020a2ba:	01c75793          	srli	a5,a4,0x1c
ffffffffc020a2be:	97a6                	add	a5,a5,s1
ffffffffc020a2c0:	6798                	ld	a4,8(a5)
ffffffffc020a2c2:	04840693          	addi	a3,s0,72
ffffffffc020a2c6:	e314                	sd	a3,0(a4)
ffffffffc020a2c8:	e794                	sd	a3,8(a5)
ffffffffc020a2ca:	e838                	sd	a4,80(s0)
ffffffffc020a2cc:	e43c                	sd	a5,72(s0)
ffffffffc020a2ce:	854a                	mv	a0,s2
ffffffffc020a2d0:	ecdfe0ef          	jal	ffffffffc020919c <unlock_sfs_fs>
ffffffffc020a2d4:	0089b023          	sd	s0,0(s3)
ffffffffc020a2d8:	4401                	li	s0,0
ffffffffc020a2da:	70e2                	ld	ra,56(sp)
ffffffffc020a2dc:	8522                	mv	a0,s0
ffffffffc020a2de:	7442                	ld	s0,48(sp)
ffffffffc020a2e0:	74a2                	ld	s1,40(sp)
ffffffffc020a2e2:	7902                	ld	s2,32(sp)
ffffffffc020a2e4:	69e2                	ld	s3,24(sp)
ffffffffc020a2e6:	6121                	addi	sp,sp,64
ffffffffc020a2e8:	8082                	ret
ffffffffc020a2ea:	fb878413          	addi	s0,a5,-72
ffffffffc020a2ee:	8522                	mv	a0,s0
ffffffffc020a2f0:	e43e                	sd	a5,8(sp)
ffffffffc020a2f2:	fe5fd0ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc020a2f6:	4705                	li	a4,1
ffffffffc020a2f8:	67a2                	ld	a5,8(sp)
ffffffffc020a2fa:	fce51ae3          	bne	a0,a4,ffffffffc020a2ce <sfs_load_inode+0x124>
ffffffffc020a2fe:	fd07a703          	lw	a4,-48(a5)
ffffffffc020a302:	2705                	addiw	a4,a4,1
ffffffffc020a304:	fce7a823          	sw	a4,-48(a5)
ffffffffc020a308:	b7d9                	j	ffffffffc020a2ce <sfs_load_inode+0x124>
ffffffffc020a30a:	5471                	li	s0,-4
ffffffffc020a30c:	854a                	mv	a0,s2
ffffffffc020a30e:	e8ffe0ef          	jal	ffffffffc020919c <unlock_sfs_fs>
ffffffffc020a312:	70e2                	ld	ra,56(sp)
ffffffffc020a314:	8522                	mv	a0,s0
ffffffffc020a316:	7442                	ld	s0,48(sp)
ffffffffc020a318:	74a2                	ld	s1,40(sp)
ffffffffc020a31a:	7902                	ld	s2,32(sp)
ffffffffc020a31c:	69e2                	ld	s3,24(sp)
ffffffffc020a31e:	6121                	addi	sp,sp,64
ffffffffc020a320:	8082                	ret
ffffffffc020a322:	5471                	li	s0,-4
ffffffffc020a324:	853e                	mv	a0,a5
ffffffffc020a326:	abdf70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a32a:	b7cd                	j	ffffffffc020a30c <sfs_load_inode+0x162>
ffffffffc020a32c:	00005597          	auipc	a1,0x5
ffffffffc020a330:	56458593          	addi	a1,a1,1380 # ffffffffc020f890 <sfs_node_fileops>
ffffffffc020a334:	b72d                	j	ffffffffc020a25e <sfs_load_inode+0xb4>
ffffffffc020a336:	00004697          	auipc	a3,0x4
ffffffffc020a33a:	65268693          	addi	a3,a3,1618 # ffffffffc020e988 <etext+0x30b2>
ffffffffc020a33e:	00002617          	auipc	a2,0x2
ffffffffc020a342:	a5260613          	addi	a2,a2,-1454 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a346:	0ad00593          	li	a1,173
ffffffffc020a34a:	00004517          	auipc	a0,0x4
ffffffffc020a34e:	3ae50513          	addi	a0,a0,942 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a352:	edbf50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a356:	00492683          	lw	a3,4(s2)
ffffffffc020a35a:	8726                	mv	a4,s1
ffffffffc020a35c:	00004617          	auipc	a2,0x4
ffffffffc020a360:	3fc60613          	addi	a2,a2,1020 # ffffffffc020e758 <etext+0x2e82>
ffffffffc020a364:	05300593          	li	a1,83
ffffffffc020a368:	00004517          	auipc	a0,0x4
ffffffffc020a36c:	39050513          	addi	a0,a0,912 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a370:	ebdf50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a374:	00004697          	auipc	a3,0x4
ffffffffc020a378:	41c68693          	addi	a3,a3,1052 # ffffffffc020e790 <etext+0x2eba>
ffffffffc020a37c:	00002617          	auipc	a2,0x2
ffffffffc020a380:	a1460613          	addi	a2,a2,-1516 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a384:	0a800593          	li	a1,168
ffffffffc020a388:	00004517          	auipc	a0,0x4
ffffffffc020a38c:	37050513          	addi	a0,a0,880 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a390:	e9df50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a394:	00004697          	auipc	a3,0x4
ffffffffc020a398:	32c68693          	addi	a3,a3,812 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020a39c:	00002617          	auipc	a2,0x2
ffffffffc020a3a0:	9f460613          	addi	a2,a2,-1548 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a3a4:	0b100593          	li	a1,177
ffffffffc020a3a8:	00004517          	auipc	a0,0x4
ffffffffc020a3ac:	35050513          	addi	a0,a0,848 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a3b0:	e7df50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a3b4:	00004697          	auipc	a3,0x4
ffffffffc020a3b8:	30c68693          	addi	a3,a3,780 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020a3bc:	00002617          	auipc	a2,0x2
ffffffffc020a3c0:	9d460613          	addi	a2,a2,-1580 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a3c4:	07700593          	li	a1,119
ffffffffc020a3c8:	00004517          	auipc	a0,0x4
ffffffffc020a3cc:	33050513          	addi	a0,a0,816 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a3d0:	e5df50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a3d4:	00004617          	auipc	a2,0x4
ffffffffc020a3d8:	33c60613          	addi	a2,a2,828 # ffffffffc020e710 <etext+0x2e3a>
ffffffffc020a3dc:	02e00593          	li	a1,46
ffffffffc020a3e0:	00004517          	auipc	a0,0x4
ffffffffc020a3e4:	31850513          	addi	a0,a0,792 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a3e8:	e45f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a3ec <sfs_lookup_once.constprop.0>:
ffffffffc020a3ec:	711d                	addi	sp,sp,-96
ffffffffc020a3ee:	f852                	sd	s4,48(sp)
ffffffffc020a3f0:	8a2a                	mv	s4,a0
ffffffffc020a3f2:	02058513          	addi	a0,a1,32
ffffffffc020a3f6:	ec86                	sd	ra,88(sp)
ffffffffc020a3f8:	e0ca                	sd	s2,64(sp)
ffffffffc020a3fa:	f456                	sd	s5,40(sp)
ffffffffc020a3fc:	e862                	sd	s8,16(sp)
ffffffffc020a3fe:	8ab2                	mv	s5,a2
ffffffffc020a400:	892e                	mv	s2,a1
ffffffffc020a402:	8c36                	mv	s8,a3
ffffffffc020a404:	bd4fa0ef          	jal	ffffffffc02047d8 <down>
ffffffffc020a408:	8556                	mv	a0,s5
ffffffffc020a40a:	729000ef          	jal	ffffffffc020b332 <strlen>
ffffffffc020a40e:	0ff00793          	li	a5,255
ffffffffc020a412:	0aa7e963          	bltu	a5,a0,ffffffffc020a4c4 <sfs_lookup_once.constprop.0+0xd8>
ffffffffc020a416:	10400513          	li	a0,260
ffffffffc020a41a:	e4a6                	sd	s1,72(sp)
ffffffffc020a41c:	921f70ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020a420:	84aa                	mv	s1,a0
ffffffffc020a422:	c959                	beqz	a0,ffffffffc020a4b8 <sfs_lookup_once.constprop.0+0xcc>
ffffffffc020a424:	00093783          	ld	a5,0(s2)
ffffffffc020a428:	fc4e                	sd	s3,56(sp)
ffffffffc020a42a:	0087a983          	lw	s3,8(a5)
ffffffffc020a42e:	05305d63          	blez	s3,ffffffffc020a488 <sfs_lookup_once.constprop.0+0x9c>
ffffffffc020a432:	e8a2                	sd	s0,80(sp)
ffffffffc020a434:	4401                	li	s0,0
ffffffffc020a436:	a821                	j	ffffffffc020a44e <sfs_lookup_once.constprop.0+0x62>
ffffffffc020a438:	409c                	lw	a5,0(s1)
ffffffffc020a43a:	c799                	beqz	a5,ffffffffc020a448 <sfs_lookup_once.constprop.0+0x5c>
ffffffffc020a43c:	00448593          	addi	a1,s1,4
ffffffffc020a440:	8556                	mv	a0,s5
ffffffffc020a442:	737000ef          	jal	ffffffffc020b378 <strcmp>
ffffffffc020a446:	c139                	beqz	a0,ffffffffc020a48c <sfs_lookup_once.constprop.0+0xa0>
ffffffffc020a448:	2405                	addiw	s0,s0,1
ffffffffc020a44a:	02898e63          	beq	s3,s0,ffffffffc020a486 <sfs_lookup_once.constprop.0+0x9a>
ffffffffc020a44e:	86a6                	mv	a3,s1
ffffffffc020a450:	8622                	mv	a2,s0
ffffffffc020a452:	85ca                	mv	a1,s2
ffffffffc020a454:	8552                	mv	a0,s4
ffffffffc020a456:	8a7ff0ef          	jal	ffffffffc0209cfc <sfs_dirent_read_nolock>
ffffffffc020a45a:	87aa                	mv	a5,a0
ffffffffc020a45c:	dd71                	beqz	a0,ffffffffc020a438 <sfs_lookup_once.constprop.0+0x4c>
ffffffffc020a45e:	6446                	ld	s0,80(sp)
ffffffffc020a460:	8526                	mv	a0,s1
ffffffffc020a462:	e43e                	sd	a5,8(sp)
ffffffffc020a464:	97ff70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a468:	02090513          	addi	a0,s2,32
ffffffffc020a46c:	b68fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a470:	67a2                	ld	a5,8(sp)
ffffffffc020a472:	79e2                	ld	s3,56(sp)
ffffffffc020a474:	60e6                	ld	ra,88(sp)
ffffffffc020a476:	64a6                	ld	s1,72(sp)
ffffffffc020a478:	6906                	ld	s2,64(sp)
ffffffffc020a47a:	7a42                	ld	s4,48(sp)
ffffffffc020a47c:	7aa2                	ld	s5,40(sp)
ffffffffc020a47e:	6c42                	ld	s8,16(sp)
ffffffffc020a480:	853e                	mv	a0,a5
ffffffffc020a482:	6125                	addi	sp,sp,96
ffffffffc020a484:	8082                	ret
ffffffffc020a486:	6446                	ld	s0,80(sp)
ffffffffc020a488:	57c1                	li	a5,-16
ffffffffc020a48a:	bfd9                	j	ffffffffc020a460 <sfs_lookup_once.constprop.0+0x74>
ffffffffc020a48c:	8526                	mv	a0,s1
ffffffffc020a48e:	4080                	lw	s0,0(s1)
ffffffffc020a490:	953f70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a494:	02090513          	addi	a0,s2,32
ffffffffc020a498:	b3cfa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a49c:	8622                	mv	a2,s0
ffffffffc020a49e:	6446                	ld	s0,80(sp)
ffffffffc020a4a0:	64a6                	ld	s1,72(sp)
ffffffffc020a4a2:	79e2                	ld	s3,56(sp)
ffffffffc020a4a4:	60e6                	ld	ra,88(sp)
ffffffffc020a4a6:	6906                	ld	s2,64(sp)
ffffffffc020a4a8:	7aa2                	ld	s5,40(sp)
ffffffffc020a4aa:	85e2                	mv	a1,s8
ffffffffc020a4ac:	8552                	mv	a0,s4
ffffffffc020a4ae:	6c42                	ld	s8,16(sp)
ffffffffc020a4b0:	7a42                	ld	s4,48(sp)
ffffffffc020a4b2:	6125                	addi	sp,sp,96
ffffffffc020a4b4:	cf7ff06f          	j	ffffffffc020a1aa <sfs_load_inode>
ffffffffc020a4b8:	02090513          	addi	a0,s2,32
ffffffffc020a4bc:	b18fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a4c0:	57f1                	li	a5,-4
ffffffffc020a4c2:	bf4d                	j	ffffffffc020a474 <sfs_lookup_once.constprop.0+0x88>
ffffffffc020a4c4:	00004697          	auipc	a3,0x4
ffffffffc020a4c8:	4dc68693          	addi	a3,a3,1244 # ffffffffc020e9a0 <etext+0x30ca>
ffffffffc020a4cc:	00002617          	auipc	a2,0x2
ffffffffc020a4d0:	8c460613          	addi	a2,a2,-1852 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a4d4:	1ba00593          	li	a1,442
ffffffffc020a4d8:	00004517          	auipc	a0,0x4
ffffffffc020a4dc:	22050513          	addi	a0,a0,544 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a4e0:	e8a2                	sd	s0,80(sp)
ffffffffc020a4e2:	e4a6                	sd	s1,72(sp)
ffffffffc020a4e4:	fc4e                	sd	s3,56(sp)
ffffffffc020a4e6:	f05a                	sd	s6,32(sp)
ffffffffc020a4e8:	ec5e                	sd	s7,24(sp)
ffffffffc020a4ea:	d43f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a4ee <sfs_namefile>:
ffffffffc020a4ee:	6d9c                	ld	a5,24(a1)
ffffffffc020a4f0:	7175                	addi	sp,sp,-144
ffffffffc020a4f2:	f86a                	sd	s10,48(sp)
ffffffffc020a4f4:	e506                	sd	ra,136(sp)
ffffffffc020a4f6:	f46e                	sd	s11,40(sp)
ffffffffc020a4f8:	4d09                	li	s10,2
ffffffffc020a4fa:	1afd7763          	bgeu	s10,a5,ffffffffc020a6a8 <sfs_namefile+0x1ba>
ffffffffc020a4fe:	f4ce                	sd	s3,104(sp)
ffffffffc020a500:	89aa                	mv	s3,a0
ffffffffc020a502:	10400513          	li	a0,260
ffffffffc020a506:	fca6                	sd	s1,120(sp)
ffffffffc020a508:	e42e                	sd	a1,8(sp)
ffffffffc020a50a:	833f70ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020a50e:	84aa                	mv	s1,a0
ffffffffc020a510:	18050a63          	beqz	a0,ffffffffc020a6a4 <sfs_namefile+0x1b6>
ffffffffc020a514:	f0d2                	sd	s4,96(sp)
ffffffffc020a516:	0689ba03          	ld	s4,104(s3)
ffffffffc020a51a:	1e0a0c63          	beqz	s4,ffffffffc020a712 <sfs_namefile+0x224>
ffffffffc020a51e:	0b0a2783          	lw	a5,176(s4)
ffffffffc020a522:	1e079863          	bnez	a5,ffffffffc020a712 <sfs_namefile+0x224>
ffffffffc020a526:	0589a703          	lw	a4,88(s3)
ffffffffc020a52a:	6785                	lui	a5,0x1
ffffffffc020a52c:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a530:	e03a                	sd	a4,0(sp)
ffffffffc020a532:	e122                	sd	s0,128(sp)
ffffffffc020a534:	f8ca                	sd	s2,112(sp)
ffffffffc020a536:	ecd6                	sd	s5,88(sp)
ffffffffc020a538:	e8da                	sd	s6,80(sp)
ffffffffc020a53a:	e4de                	sd	s7,72(sp)
ffffffffc020a53c:	e0e2                	sd	s8,64(sp)
ffffffffc020a53e:	1af71963          	bne	a4,a5,ffffffffc020a6f0 <sfs_namefile+0x202>
ffffffffc020a542:	6722                	ld	a4,8(sp)
ffffffffc020a544:	854e                	mv	a0,s3
ffffffffc020a546:	8b4e                	mv	s6,s3
ffffffffc020a548:	6f1c                	ld	a5,24(a4)
ffffffffc020a54a:	00073a83          	ld	s5,0(a4)
ffffffffc020a54e:	ffe78c13          	addi	s8,a5,-2
ffffffffc020a552:	9abe                	add	s5,s5,a5
ffffffffc020a554:	d83fd0ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc020a558:	0834                	addi	a3,sp,24
ffffffffc020a55a:	00004617          	auipc	a2,0x4
ffffffffc020a55e:	46e60613          	addi	a2,a2,1134 # ffffffffc020e9c8 <etext+0x30f2>
ffffffffc020a562:	85da                	mv	a1,s6
ffffffffc020a564:	8552                	mv	a0,s4
ffffffffc020a566:	e87ff0ef          	jal	ffffffffc020a3ec <sfs_lookup_once.constprop.0>
ffffffffc020a56a:	8daa                	mv	s11,a0
ffffffffc020a56c:	e94d                	bnez	a0,ffffffffc020a61e <sfs_namefile+0x130>
ffffffffc020a56e:	854e                	mv	a0,s3
ffffffffc020a570:	008b2903          	lw	s2,8(s6)
ffffffffc020a574:	e31fd0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020a578:	6462                	ld	s0,24(sp)
ffffffffc020a57a:	0f340563          	beq	s0,s3,ffffffffc020a664 <sfs_namefile+0x176>
ffffffffc020a57e:	14040863          	beqz	s0,ffffffffc020a6ce <sfs_namefile+0x1e0>
ffffffffc020a582:	4c38                	lw	a4,88(s0)
ffffffffc020a584:	6782                	ld	a5,0(sp)
ffffffffc020a586:	14f71463          	bne	a4,a5,ffffffffc020a6ce <sfs_namefile+0x1e0>
ffffffffc020a58a:	4418                	lw	a4,8(s0)
ffffffffc020a58c:	13270063          	beq	a4,s2,ffffffffc020a6ac <sfs_namefile+0x1be>
ffffffffc020a590:	6018                	ld	a4,0(s0)
ffffffffc020a592:	00475703          	lhu	a4,4(a4)
ffffffffc020a596:	11a71b63          	bne	a4,s10,ffffffffc020a6ac <sfs_namefile+0x1be>
ffffffffc020a59a:	02040b93          	addi	s7,s0,32
ffffffffc020a59e:	855e                	mv	a0,s7
ffffffffc020a5a0:	a38fa0ef          	jal	ffffffffc02047d8 <down>
ffffffffc020a5a4:	6018                	ld	a4,0(s0)
ffffffffc020a5a6:	00872983          	lw	s3,8(a4)
ffffffffc020a5aa:	0b305763          	blez	s3,ffffffffc020a658 <sfs_namefile+0x16a>
ffffffffc020a5ae:	8b22                	mv	s6,s0
ffffffffc020a5b0:	a039                	j	ffffffffc020a5be <sfs_namefile+0xd0>
ffffffffc020a5b2:	4098                	lw	a4,0(s1)
ffffffffc020a5b4:	01270e63          	beq	a4,s2,ffffffffc020a5d0 <sfs_namefile+0xe2>
ffffffffc020a5b8:	2d85                	addiw	s11,s11,1
ffffffffc020a5ba:	09b98763          	beq	s3,s11,ffffffffc020a648 <sfs_namefile+0x15a>
ffffffffc020a5be:	86a6                	mv	a3,s1
ffffffffc020a5c0:	866e                	mv	a2,s11
ffffffffc020a5c2:	85a2                	mv	a1,s0
ffffffffc020a5c4:	8552                	mv	a0,s4
ffffffffc020a5c6:	f36ff0ef          	jal	ffffffffc0209cfc <sfs_dirent_read_nolock>
ffffffffc020a5ca:	872a                	mv	a4,a0
ffffffffc020a5cc:	d17d                	beqz	a0,ffffffffc020a5b2 <sfs_namefile+0xc4>
ffffffffc020a5ce:	a8b5                	j	ffffffffc020a64a <sfs_namefile+0x15c>
ffffffffc020a5d0:	855e                	mv	a0,s7
ffffffffc020a5d2:	a02fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a5d6:	00448513          	addi	a0,s1,4
ffffffffc020a5da:	559000ef          	jal	ffffffffc020b332 <strlen>
ffffffffc020a5de:	00150793          	addi	a5,a0,1
ffffffffc020a5e2:	0afc6e63          	bltu	s8,a5,ffffffffc020a69e <sfs_namefile+0x1b0>
ffffffffc020a5e6:	fff54913          	not	s2,a0
ffffffffc020a5ea:	862a                	mv	a2,a0
ffffffffc020a5ec:	00448593          	addi	a1,s1,4
ffffffffc020a5f0:	012a8533          	add	a0,s5,s2
ffffffffc020a5f4:	40fc0c33          	sub	s8,s8,a5
ffffffffc020a5f8:	63f000ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc020a5fc:	02f00793          	li	a5,47
ffffffffc020a600:	fefa8fa3          	sb	a5,-1(s5)
ffffffffc020a604:	0834                	addi	a3,sp,24
ffffffffc020a606:	00004617          	auipc	a2,0x4
ffffffffc020a60a:	3c260613          	addi	a2,a2,962 # ffffffffc020e9c8 <etext+0x30f2>
ffffffffc020a60e:	85da                	mv	a1,s6
ffffffffc020a610:	8552                	mv	a0,s4
ffffffffc020a612:	ddbff0ef          	jal	ffffffffc020a3ec <sfs_lookup_once.constprop.0>
ffffffffc020a616:	89a2                	mv	s3,s0
ffffffffc020a618:	9aca                	add	s5,s5,s2
ffffffffc020a61a:	8daa                	mv	s11,a0
ffffffffc020a61c:	d929                	beqz	a0,ffffffffc020a56e <sfs_namefile+0x80>
ffffffffc020a61e:	854e                	mv	a0,s3
ffffffffc020a620:	d85fd0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020a624:	8526                	mv	a0,s1
ffffffffc020a626:	fbcf70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a62a:	640a                	ld	s0,128(sp)
ffffffffc020a62c:	74e6                	ld	s1,120(sp)
ffffffffc020a62e:	7946                	ld	s2,112(sp)
ffffffffc020a630:	79a6                	ld	s3,104(sp)
ffffffffc020a632:	7a06                	ld	s4,96(sp)
ffffffffc020a634:	6ae6                	ld	s5,88(sp)
ffffffffc020a636:	6b46                	ld	s6,80(sp)
ffffffffc020a638:	6ba6                	ld	s7,72(sp)
ffffffffc020a63a:	6c06                	ld	s8,64(sp)
ffffffffc020a63c:	60aa                	ld	ra,136(sp)
ffffffffc020a63e:	7d42                	ld	s10,48(sp)
ffffffffc020a640:	856e                	mv	a0,s11
ffffffffc020a642:	7da2                	ld	s11,40(sp)
ffffffffc020a644:	6149                	addi	sp,sp,144
ffffffffc020a646:	8082                	ret
ffffffffc020a648:	5741                	li	a4,-16
ffffffffc020a64a:	855e                	mv	a0,s7
ffffffffc020a64c:	e03a                	sd	a4,0(sp)
ffffffffc020a64e:	89a2                	mv	s3,s0
ffffffffc020a650:	984fa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a654:	6d82                	ld	s11,0(sp)
ffffffffc020a656:	b7e1                	j	ffffffffc020a61e <sfs_namefile+0x130>
ffffffffc020a658:	855e                	mv	a0,s7
ffffffffc020a65a:	97afa0ef          	jal	ffffffffc02047d4 <up>
ffffffffc020a65e:	89a2                	mv	s3,s0
ffffffffc020a660:	5dc1                	li	s11,-16
ffffffffc020a662:	bf75                	j	ffffffffc020a61e <sfs_namefile+0x130>
ffffffffc020a664:	854e                	mv	a0,s3
ffffffffc020a666:	d3ffd0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020a66a:	6922                	ld	s2,8(sp)
ffffffffc020a66c:	85d6                	mv	a1,s5
ffffffffc020a66e:	01893403          	ld	s0,24(s2)
ffffffffc020a672:	00093503          	ld	a0,0(s2)
ffffffffc020a676:	1479                	addi	s0,s0,-2
ffffffffc020a678:	41840433          	sub	s0,s0,s8
ffffffffc020a67c:	8622                	mv	a2,s0
ffffffffc020a67e:	0505                	addi	a0,a0,1
ffffffffc020a680:	579000ef          	jal	ffffffffc020b3f8 <memmove>
ffffffffc020a684:	02f00713          	li	a4,47
ffffffffc020a688:	fee50fa3          	sb	a4,-1(a0)
ffffffffc020a68c:	00850733          	add	a4,a0,s0
ffffffffc020a690:	00070023          	sb	zero,0(a4)
ffffffffc020a694:	854a                	mv	a0,s2
ffffffffc020a696:	85a2                	mv	a1,s0
ffffffffc020a698:	9f2fb0ef          	jal	ffffffffc020588a <iobuf_skip>
ffffffffc020a69c:	b761                	j	ffffffffc020a624 <sfs_namefile+0x136>
ffffffffc020a69e:	89a2                	mv	s3,s0
ffffffffc020a6a0:	5df1                	li	s11,-4
ffffffffc020a6a2:	bfb5                	j	ffffffffc020a61e <sfs_namefile+0x130>
ffffffffc020a6a4:	74e6                	ld	s1,120(sp)
ffffffffc020a6a6:	79a6                	ld	s3,104(sp)
ffffffffc020a6a8:	5df1                	li	s11,-4
ffffffffc020a6aa:	bf49                	j	ffffffffc020a63c <sfs_namefile+0x14e>
ffffffffc020a6ac:	00004697          	auipc	a3,0x4
ffffffffc020a6b0:	32468693          	addi	a3,a3,804 # ffffffffc020e9d0 <etext+0x30fa>
ffffffffc020a6b4:	00001617          	auipc	a2,0x1
ffffffffc020a6b8:	6dc60613          	addi	a2,a2,1756 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a6bc:	2fe00593          	li	a1,766
ffffffffc020a6c0:	00004517          	auipc	a0,0x4
ffffffffc020a6c4:	03850513          	addi	a0,a0,56 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a6c8:	fc66                	sd	s9,56(sp)
ffffffffc020a6ca:	b63f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a6ce:	00004697          	auipc	a3,0x4
ffffffffc020a6d2:	ff268693          	addi	a3,a3,-14 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020a6d6:	00001617          	auipc	a2,0x1
ffffffffc020a6da:	6ba60613          	addi	a2,a2,1722 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a6de:	2fd00593          	li	a1,765
ffffffffc020a6e2:	00004517          	auipc	a0,0x4
ffffffffc020a6e6:	01650513          	addi	a0,a0,22 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a6ea:	fc66                	sd	s9,56(sp)
ffffffffc020a6ec:	b41f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a6f0:	00004697          	auipc	a3,0x4
ffffffffc020a6f4:	fd068693          	addi	a3,a3,-48 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020a6f8:	00001617          	auipc	a2,0x1
ffffffffc020a6fc:	69860613          	addi	a2,a2,1688 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a700:	2ea00593          	li	a1,746
ffffffffc020a704:	00004517          	auipc	a0,0x4
ffffffffc020a708:	ff450513          	addi	a0,a0,-12 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a70c:	fc66                	sd	s9,56(sp)
ffffffffc020a70e:	b1ff50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a712:	00004697          	auipc	a3,0x4
ffffffffc020a716:	01668693          	addi	a3,a3,22 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020a71a:	00001617          	auipc	a2,0x1
ffffffffc020a71e:	67660613          	addi	a2,a2,1654 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a722:	2e900593          	li	a1,745
ffffffffc020a726:	00004517          	auipc	a0,0x4
ffffffffc020a72a:	fd250513          	addi	a0,a0,-46 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a72e:	e122                	sd	s0,128(sp)
ffffffffc020a730:	f8ca                	sd	s2,112(sp)
ffffffffc020a732:	ecd6                	sd	s5,88(sp)
ffffffffc020a734:	e8da                	sd	s6,80(sp)
ffffffffc020a736:	e4de                	sd	s7,72(sp)
ffffffffc020a738:	e0e2                	sd	s8,64(sp)
ffffffffc020a73a:	fc66                	sd	s9,56(sp)
ffffffffc020a73c:	af1f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a740 <sfs_lookup>:
ffffffffc020a740:	7139                	addi	sp,sp,-64
ffffffffc020a742:	f426                	sd	s1,40(sp)
ffffffffc020a744:	7524                	ld	s1,104(a0)
ffffffffc020a746:	fc06                	sd	ra,56(sp)
ffffffffc020a748:	f822                	sd	s0,48(sp)
ffffffffc020a74a:	f04a                	sd	s2,32(sp)
ffffffffc020a74c:	c4b5                	beqz	s1,ffffffffc020a7b8 <sfs_lookup+0x78>
ffffffffc020a74e:	0b04a783          	lw	a5,176(s1)
ffffffffc020a752:	e3bd                	bnez	a5,ffffffffc020a7b8 <sfs_lookup+0x78>
ffffffffc020a754:	0005c783          	lbu	a5,0(a1)
ffffffffc020a758:	c3c5                	beqz	a5,ffffffffc020a7f8 <sfs_lookup+0xb8>
ffffffffc020a75a:	fd178793          	addi	a5,a5,-47
ffffffffc020a75e:	cfc9                	beqz	a5,ffffffffc020a7f8 <sfs_lookup+0xb8>
ffffffffc020a760:	842a                	mv	s0,a0
ffffffffc020a762:	8932                	mv	s2,a2
ffffffffc020a764:	e42e                	sd	a1,8(sp)
ffffffffc020a766:	b71fd0ef          	jal	ffffffffc02082d6 <inode_ref_inc>
ffffffffc020a76a:	4c38                	lw	a4,88(s0)
ffffffffc020a76c:	6785                	lui	a5,0x1
ffffffffc020a76e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a772:	06f71363          	bne	a4,a5,ffffffffc020a7d8 <sfs_lookup+0x98>
ffffffffc020a776:	6018                	ld	a4,0(s0)
ffffffffc020a778:	4789                	li	a5,2
ffffffffc020a77a:	00475703          	lhu	a4,4(a4)
ffffffffc020a77e:	02f71863          	bne	a4,a5,ffffffffc020a7ae <sfs_lookup+0x6e>
ffffffffc020a782:	6622                	ld	a2,8(sp)
ffffffffc020a784:	85a2                	mv	a1,s0
ffffffffc020a786:	8526                	mv	a0,s1
ffffffffc020a788:	0834                	addi	a3,sp,24
ffffffffc020a78a:	c63ff0ef          	jal	ffffffffc020a3ec <sfs_lookup_once.constprop.0>
ffffffffc020a78e:	87aa                	mv	a5,a0
ffffffffc020a790:	8522                	mv	a0,s0
ffffffffc020a792:	843e                	mv	s0,a5
ffffffffc020a794:	c11fd0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020a798:	e401                	bnez	s0,ffffffffc020a7a0 <sfs_lookup+0x60>
ffffffffc020a79a:	67e2                	ld	a5,24(sp)
ffffffffc020a79c:	00f93023          	sd	a5,0(s2)
ffffffffc020a7a0:	70e2                	ld	ra,56(sp)
ffffffffc020a7a2:	8522                	mv	a0,s0
ffffffffc020a7a4:	7442                	ld	s0,48(sp)
ffffffffc020a7a6:	74a2                	ld	s1,40(sp)
ffffffffc020a7a8:	7902                	ld	s2,32(sp)
ffffffffc020a7aa:	6121                	addi	sp,sp,64
ffffffffc020a7ac:	8082                	ret
ffffffffc020a7ae:	8522                	mv	a0,s0
ffffffffc020a7b0:	bf5fd0ef          	jal	ffffffffc02083a4 <inode_ref_dec>
ffffffffc020a7b4:	5439                	li	s0,-18
ffffffffc020a7b6:	b7ed                	j	ffffffffc020a7a0 <sfs_lookup+0x60>
ffffffffc020a7b8:	00004697          	auipc	a3,0x4
ffffffffc020a7bc:	f7068693          	addi	a3,a3,-144 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020a7c0:	00001617          	auipc	a2,0x1
ffffffffc020a7c4:	5d060613          	addi	a2,a2,1488 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a7c8:	3df00593          	li	a1,991
ffffffffc020a7cc:	00004517          	auipc	a0,0x4
ffffffffc020a7d0:	f2c50513          	addi	a0,a0,-212 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a7d4:	a59f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a7d8:	00004697          	auipc	a3,0x4
ffffffffc020a7dc:	ee868693          	addi	a3,a3,-280 # ffffffffc020e6c0 <etext+0x2dea>
ffffffffc020a7e0:	00001617          	auipc	a2,0x1
ffffffffc020a7e4:	5b060613          	addi	a2,a2,1456 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a7e8:	3e200593          	li	a1,994
ffffffffc020a7ec:	00004517          	auipc	a0,0x4
ffffffffc020a7f0:	f0c50513          	addi	a0,a0,-244 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a7f4:	a39f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a7f8:	00004697          	auipc	a3,0x4
ffffffffc020a7fc:	21068693          	addi	a3,a3,528 # ffffffffc020ea08 <etext+0x3132>
ffffffffc020a800:	00001617          	auipc	a2,0x1
ffffffffc020a804:	59060613          	addi	a2,a2,1424 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a808:	3e000593          	li	a1,992
ffffffffc020a80c:	00004517          	auipc	a0,0x4
ffffffffc020a810:	eec50513          	addi	a0,a0,-276 # ffffffffc020e6f8 <etext+0x2e22>
ffffffffc020a814:	a19f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a818 <sfs_unmount>:
ffffffffc020a818:	1141                	addi	sp,sp,-16
ffffffffc020a81a:	e406                	sd	ra,8(sp)
ffffffffc020a81c:	e022                	sd	s0,0(sp)
ffffffffc020a81e:	cd1d                	beqz	a0,ffffffffc020a85c <sfs_unmount+0x44>
ffffffffc020a820:	0b052783          	lw	a5,176(a0)
ffffffffc020a824:	842a                	mv	s0,a0
ffffffffc020a826:	eb9d                	bnez	a5,ffffffffc020a85c <sfs_unmount+0x44>
ffffffffc020a828:	7158                	ld	a4,160(a0)
ffffffffc020a82a:	09850793          	addi	a5,a0,152
ffffffffc020a82e:	02f71563          	bne	a4,a5,ffffffffc020a858 <sfs_unmount+0x40>
ffffffffc020a832:	613c                	ld	a5,64(a0)
ffffffffc020a834:	e7a1                	bnez	a5,ffffffffc020a87c <sfs_unmount+0x64>
ffffffffc020a836:	7d08                	ld	a0,56(a0)
ffffffffc020a838:	77e000ef          	jal	ffffffffc020afb6 <bitmap_destroy>
ffffffffc020a83c:	6428                	ld	a0,72(s0)
ffffffffc020a83e:	da4f70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a842:	7448                	ld	a0,168(s0)
ffffffffc020a844:	d9ef70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a848:	8522                	mv	a0,s0
ffffffffc020a84a:	d98f70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020a84e:	4501                	li	a0,0
ffffffffc020a850:	60a2                	ld	ra,8(sp)
ffffffffc020a852:	6402                	ld	s0,0(sp)
ffffffffc020a854:	0141                	addi	sp,sp,16
ffffffffc020a856:	8082                	ret
ffffffffc020a858:	5545                	li	a0,-15
ffffffffc020a85a:	bfdd                	j	ffffffffc020a850 <sfs_unmount+0x38>
ffffffffc020a85c:	00004697          	auipc	a3,0x4
ffffffffc020a860:	ecc68693          	addi	a3,a3,-308 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020a864:	00001617          	auipc	a2,0x1
ffffffffc020a868:	52c60613          	addi	a2,a2,1324 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a86c:	04100593          	li	a1,65
ffffffffc020a870:	00004517          	auipc	a0,0x4
ffffffffc020a874:	1b850513          	addi	a0,a0,440 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020a878:	9b5f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a87c:	00004697          	auipc	a3,0x4
ffffffffc020a880:	1c468693          	addi	a3,a3,452 # ffffffffc020ea40 <etext+0x316a>
ffffffffc020a884:	00001617          	auipc	a2,0x1
ffffffffc020a888:	50c60613          	addi	a2,a2,1292 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a88c:	04500593          	li	a1,69
ffffffffc020a890:	00004517          	auipc	a0,0x4
ffffffffc020a894:	19850513          	addi	a0,a0,408 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020a898:	995f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a89c <sfs_cleanup>:
ffffffffc020a89c:	1101                	addi	sp,sp,-32
ffffffffc020a89e:	ec06                	sd	ra,24(sp)
ffffffffc020a8a0:	e426                	sd	s1,8(sp)
ffffffffc020a8a2:	c13d                	beqz	a0,ffffffffc020a908 <sfs_cleanup+0x6c>
ffffffffc020a8a4:	0b052783          	lw	a5,176(a0)
ffffffffc020a8a8:	84aa                	mv	s1,a0
ffffffffc020a8aa:	efb9                	bnez	a5,ffffffffc020a908 <sfs_cleanup+0x6c>
ffffffffc020a8ac:	4158                	lw	a4,4(a0)
ffffffffc020a8ae:	4514                	lw	a3,8(a0)
ffffffffc020a8b0:	00c50593          	addi	a1,a0,12
ffffffffc020a8b4:	00004517          	auipc	a0,0x4
ffffffffc020a8b8:	1a450513          	addi	a0,a0,420 # ffffffffc020ea58 <etext+0x3182>
ffffffffc020a8bc:	40d7063b          	subw	a2,a4,a3
ffffffffc020a8c0:	e822                	sd	s0,16(sp)
ffffffffc020a8c2:	867f50ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020a8c6:	02000413          	li	s0,32
ffffffffc020a8ca:	a019                	j	ffffffffc020a8d0 <sfs_cleanup+0x34>
ffffffffc020a8cc:	347d                	addiw	s0,s0,-1
ffffffffc020a8ce:	c811                	beqz	s0,ffffffffc020a8e2 <sfs_cleanup+0x46>
ffffffffc020a8d0:	7cdc                	ld	a5,184(s1)
ffffffffc020a8d2:	8526                	mv	a0,s1
ffffffffc020a8d4:	9782                	jalr	a5
ffffffffc020a8d6:	f97d                	bnez	a0,ffffffffc020a8cc <sfs_cleanup+0x30>
ffffffffc020a8d8:	6442                	ld	s0,16(sp)
ffffffffc020a8da:	60e2                	ld	ra,24(sp)
ffffffffc020a8dc:	64a2                	ld	s1,8(sp)
ffffffffc020a8de:	6105                	addi	sp,sp,32
ffffffffc020a8e0:	8082                	ret
ffffffffc020a8e2:	6442                	ld	s0,16(sp)
ffffffffc020a8e4:	60e2                	ld	ra,24(sp)
ffffffffc020a8e6:	00c48693          	addi	a3,s1,12
ffffffffc020a8ea:	64a2                	ld	s1,8(sp)
ffffffffc020a8ec:	872a                	mv	a4,a0
ffffffffc020a8ee:	00004617          	auipc	a2,0x4
ffffffffc020a8f2:	18a60613          	addi	a2,a2,394 # ffffffffc020ea78 <etext+0x31a2>
ffffffffc020a8f6:	05f00593          	li	a1,95
ffffffffc020a8fa:	00004517          	auipc	a0,0x4
ffffffffc020a8fe:	12e50513          	addi	a0,a0,302 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020a902:	6105                	addi	sp,sp,32
ffffffffc020a904:	993f506f          	j	ffffffffc0200296 <__warn>
ffffffffc020a908:	00004697          	auipc	a3,0x4
ffffffffc020a90c:	e2068693          	addi	a3,a3,-480 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020a910:	00001617          	auipc	a2,0x1
ffffffffc020a914:	48060613          	addi	a2,a2,1152 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a918:	05400593          	li	a1,84
ffffffffc020a91c:	00004517          	auipc	a0,0x4
ffffffffc020a920:	10c50513          	addi	a0,a0,268 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020a924:	e822                	sd	s0,16(sp)
ffffffffc020a926:	e04a                	sd	s2,0(sp)
ffffffffc020a928:	905f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020a92c <sfs_sync>:
ffffffffc020a92c:	7179                	addi	sp,sp,-48
ffffffffc020a92e:	f406                	sd	ra,40(sp)
ffffffffc020a930:	e44e                	sd	s3,8(sp)
ffffffffc020a932:	c94d                	beqz	a0,ffffffffc020a9e4 <sfs_sync+0xb8>
ffffffffc020a934:	0b052783          	lw	a5,176(a0)
ffffffffc020a938:	89aa                	mv	s3,a0
ffffffffc020a93a:	e7cd                	bnez	a5,ffffffffc020a9e4 <sfs_sync+0xb8>
ffffffffc020a93c:	f022                	sd	s0,32(sp)
ffffffffc020a93e:	e84a                	sd	s2,16(sp)
ffffffffc020a940:	84dfe0ef          	jal	ffffffffc020918c <lock_sfs_fs>
ffffffffc020a944:	0a09b403          	ld	s0,160(s3)
ffffffffc020a948:	09898913          	addi	s2,s3,152
ffffffffc020a94c:	02890663          	beq	s2,s0,ffffffffc020a978 <sfs_sync+0x4c>
ffffffffc020a950:	7c1c                	ld	a5,56(s0)
ffffffffc020a952:	cbad                	beqz	a5,ffffffffc020a9c4 <sfs_sync+0x98>
ffffffffc020a954:	7b9c                	ld	a5,48(a5)
ffffffffc020a956:	c7bd                	beqz	a5,ffffffffc020a9c4 <sfs_sync+0x98>
ffffffffc020a958:	fc840513          	addi	a0,s0,-56
ffffffffc020a95c:	00003597          	auipc	a1,0x3
ffffffffc020a960:	cbc58593          	addi	a1,a1,-836 # ffffffffc020d618 <etext+0x1d42>
ffffffffc020a964:	987fd0ef          	jal	ffffffffc02082ea <inode_check>
ffffffffc020a968:	7c1c                	ld	a5,56(s0)
ffffffffc020a96a:	fc840513          	addi	a0,s0,-56
ffffffffc020a96e:	7b9c                	ld	a5,48(a5)
ffffffffc020a970:	9782                	jalr	a5
ffffffffc020a972:	6400                	ld	s0,8(s0)
ffffffffc020a974:	fc891ee3          	bne	s2,s0,ffffffffc020a950 <sfs_sync+0x24>
ffffffffc020a978:	854e                	mv	a0,s3
ffffffffc020a97a:	823fe0ef          	jal	ffffffffc020919c <unlock_sfs_fs>
ffffffffc020a97e:	0409b783          	ld	a5,64(s3)
ffffffffc020a982:	4501                	li	a0,0
ffffffffc020a984:	e799                	bnez	a5,ffffffffc020a992 <sfs_sync+0x66>
ffffffffc020a986:	7402                	ld	s0,32(sp)
ffffffffc020a988:	70a2                	ld	ra,40(sp)
ffffffffc020a98a:	6942                	ld	s2,16(sp)
ffffffffc020a98c:	69a2                	ld	s3,8(sp)
ffffffffc020a98e:	6145                	addi	sp,sp,48
ffffffffc020a990:	8082                	ret
ffffffffc020a992:	0409b023          	sd	zero,64(s3)
ffffffffc020a996:	854e                	mv	a0,s3
ffffffffc020a998:	07b000ef          	jal	ffffffffc020b212 <sfs_sync_super>
ffffffffc020a99c:	c911                	beqz	a0,ffffffffc020a9b0 <sfs_sync+0x84>
ffffffffc020a99e:	7402                	ld	s0,32(sp)
ffffffffc020a9a0:	70a2                	ld	ra,40(sp)
ffffffffc020a9a2:	4785                	li	a5,1
ffffffffc020a9a4:	04f9b023          	sd	a5,64(s3)
ffffffffc020a9a8:	6942                	ld	s2,16(sp)
ffffffffc020a9aa:	69a2                	ld	s3,8(sp)
ffffffffc020a9ac:	6145                	addi	sp,sp,48
ffffffffc020a9ae:	8082                	ret
ffffffffc020a9b0:	854e                	mv	a0,s3
ffffffffc020a9b2:	0a7000ef          	jal	ffffffffc020b258 <sfs_sync_freemap>
ffffffffc020a9b6:	f565                	bnez	a0,ffffffffc020a99e <sfs_sync+0x72>
ffffffffc020a9b8:	7402                	ld	s0,32(sp)
ffffffffc020a9ba:	70a2                	ld	ra,40(sp)
ffffffffc020a9bc:	6942                	ld	s2,16(sp)
ffffffffc020a9be:	69a2                	ld	s3,8(sp)
ffffffffc020a9c0:	6145                	addi	sp,sp,48
ffffffffc020a9c2:	8082                	ret
ffffffffc020a9c4:	00003697          	auipc	a3,0x3
ffffffffc020a9c8:	c0468693          	addi	a3,a3,-1020 # ffffffffc020d5c8 <etext+0x1cf2>
ffffffffc020a9cc:	00001617          	auipc	a2,0x1
ffffffffc020a9d0:	3c460613          	addi	a2,a2,964 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a9d4:	45ed                	li	a1,27
ffffffffc020a9d6:	00004517          	auipc	a0,0x4
ffffffffc020a9da:	05250513          	addi	a0,a0,82 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020a9de:	ec26                	sd	s1,24(sp)
ffffffffc020a9e0:	84df50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020a9e4:	00004697          	auipc	a3,0x4
ffffffffc020a9e8:	d4468693          	addi	a3,a3,-700 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020a9ec:	00001617          	auipc	a2,0x1
ffffffffc020a9f0:	3a460613          	addi	a2,a2,932 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020a9f4:	45d5                	li	a1,21
ffffffffc020a9f6:	00004517          	auipc	a0,0x4
ffffffffc020a9fa:	03250513          	addi	a0,a0,50 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020a9fe:	f022                	sd	s0,32(sp)
ffffffffc020aa00:	ec26                	sd	s1,24(sp)
ffffffffc020aa02:	e84a                	sd	s2,16(sp)
ffffffffc020aa04:	829f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020aa08 <sfs_get_root>:
ffffffffc020aa08:	1101                	addi	sp,sp,-32
ffffffffc020aa0a:	ec06                	sd	ra,24(sp)
ffffffffc020aa0c:	cd09                	beqz	a0,ffffffffc020aa26 <sfs_get_root+0x1e>
ffffffffc020aa0e:	0b052783          	lw	a5,176(a0)
ffffffffc020aa12:	eb91                	bnez	a5,ffffffffc020aa26 <sfs_get_root+0x1e>
ffffffffc020aa14:	4605                	li	a2,1
ffffffffc020aa16:	002c                	addi	a1,sp,8
ffffffffc020aa18:	f92ff0ef          	jal	ffffffffc020a1aa <sfs_load_inode>
ffffffffc020aa1c:	e50d                	bnez	a0,ffffffffc020aa46 <sfs_get_root+0x3e>
ffffffffc020aa1e:	60e2                	ld	ra,24(sp)
ffffffffc020aa20:	6522                	ld	a0,8(sp)
ffffffffc020aa22:	6105                	addi	sp,sp,32
ffffffffc020aa24:	8082                	ret
ffffffffc020aa26:	00004697          	auipc	a3,0x4
ffffffffc020aa2a:	d0268693          	addi	a3,a3,-766 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020aa2e:	00001617          	auipc	a2,0x1
ffffffffc020aa32:	36260613          	addi	a2,a2,866 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020aa36:	03600593          	li	a1,54
ffffffffc020aa3a:	00004517          	auipc	a0,0x4
ffffffffc020aa3e:	fee50513          	addi	a0,a0,-18 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020aa42:	feaf50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020aa46:	86aa                	mv	a3,a0
ffffffffc020aa48:	00004617          	auipc	a2,0x4
ffffffffc020aa4c:	05060613          	addi	a2,a2,80 # ffffffffc020ea98 <etext+0x31c2>
ffffffffc020aa50:	03700593          	li	a1,55
ffffffffc020aa54:	00004517          	auipc	a0,0x4
ffffffffc020aa58:	fd450513          	addi	a0,a0,-44 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020aa5c:	fd0f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020aa60 <sfs_do_mount>:
ffffffffc020aa60:	7171                	addi	sp,sp,-176
ffffffffc020aa62:	e54e                	sd	s3,136(sp)
ffffffffc020aa64:	00853983          	ld	s3,8(a0)
ffffffffc020aa68:	f506                	sd	ra,168(sp)
ffffffffc020aa6a:	6785                	lui	a5,0x1
ffffffffc020aa6c:	26f99a63          	bne	s3,a5,ffffffffc020ace0 <sfs_do_mount+0x280>
ffffffffc020aa70:	ed26                	sd	s1,152(sp)
ffffffffc020aa72:	84aa                	mv	s1,a0
ffffffffc020aa74:	4501                	li	a0,0
ffffffffc020aa76:	f122                	sd	s0,160(sp)
ffffffffc020aa78:	f4de                	sd	s7,104(sp)
ffffffffc020aa7a:	8bae                	mv	s7,a1
ffffffffc020aa7c:	c4dfd0ef          	jal	ffffffffc02086c8 <__alloc_fs>
ffffffffc020aa80:	842a                	mv	s0,a0
ffffffffc020aa82:	26050663          	beqz	a0,ffffffffc020acee <sfs_do_mount+0x28e>
ffffffffc020aa86:	e152                	sd	s4,128(sp)
ffffffffc020aa88:	0b052a03          	lw	s4,176(a0)
ffffffffc020aa8c:	e94a                	sd	s2,144(sp)
ffffffffc020aa8e:	280a1763          	bnez	s4,ffffffffc020ad1c <sfs_do_mount+0x2bc>
ffffffffc020aa92:	f904                	sd	s1,48(a0)
ffffffffc020aa94:	854e                	mv	a0,s3
ffffffffc020aa96:	aa6f70ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020aa9a:	e428                	sd	a0,72(s0)
ffffffffc020aa9c:	892a                	mv	s2,a0
ffffffffc020aa9e:	16050863          	beqz	a0,ffffffffc020ac0e <sfs_do_mount+0x1ae>
ffffffffc020aaa2:	864e                	mv	a2,s3
ffffffffc020aaa4:	4681                	li	a3,0
ffffffffc020aaa6:	85ca                	mv	a1,s2
ffffffffc020aaa8:	1008                	addi	a0,sp,32
ffffffffc020aaaa:	d53fa0ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc020aaae:	709c                	ld	a5,32(s1)
ffffffffc020aab0:	85aa                	mv	a1,a0
ffffffffc020aab2:	4601                	li	a2,0
ffffffffc020aab4:	8526                	mv	a0,s1
ffffffffc020aab6:	9782                	jalr	a5
ffffffffc020aab8:	89aa                	mv	s3,a0
ffffffffc020aaba:	12051a63          	bnez	a0,ffffffffc020abee <sfs_do_mount+0x18e>
ffffffffc020aabe:	00092583          	lw	a1,0(s2)
ffffffffc020aac2:	2f8dc637          	lui	a2,0x2f8dc
ffffffffc020aac6:	e2a60613          	addi	a2,a2,-470 # 2f8dbe2a <_binary_bin_sfs_img_size+0x2f866b2a>
ffffffffc020aaca:	14c59d63          	bne	a1,a2,ffffffffc020ac24 <sfs_do_mount+0x1c4>
ffffffffc020aace:	00492783          	lw	a5,4(s2)
ffffffffc020aad2:	6090                	ld	a2,0(s1)
ffffffffc020aad4:	02079713          	slli	a4,a5,0x20
ffffffffc020aad8:	9301                	srli	a4,a4,0x20
ffffffffc020aada:	12e66c63          	bltu	a2,a4,ffffffffc020ac12 <sfs_do_mount+0x1b2>
ffffffffc020aade:	e4ee                	sd	s11,72(sp)
ffffffffc020aae0:	01892503          	lw	a0,24(s2)
ffffffffc020aae4:	00892e03          	lw	t3,8(s2)
ffffffffc020aae8:	00c92303          	lw	t1,12(s2)
ffffffffc020aaec:	01092883          	lw	a7,16(s2)
ffffffffc020aaf0:	01492803          	lw	a6,20(s2)
ffffffffc020aaf4:	01c92603          	lw	a2,28(s2)
ffffffffc020aaf8:	02092683          	lw	a3,32(s2)
ffffffffc020aafc:	02492703          	lw	a4,36(s2)
ffffffffc020ab00:	020905a3          	sb	zero,43(s2)
ffffffffc020ab04:	cc08                	sw	a0,24(s0)
ffffffffc020ab06:	01c42423          	sw	t3,8(s0)
ffffffffc020ab0a:	00642623          	sw	t1,12(s0)
ffffffffc020ab0e:	01142823          	sw	a7,16(s0)
ffffffffc020ab12:	01042a23          	sw	a6,20(s0)
ffffffffc020ab16:	cc50                	sw	a2,28(s0)
ffffffffc020ab18:	d014                	sw	a3,32(s0)
ffffffffc020ab1a:	d058                	sw	a4,36(s0)
ffffffffc020ab1c:	c00c                	sw	a1,0(s0)
ffffffffc020ab1e:	c05c                	sw	a5,4(s0)
ffffffffc020ab20:	02892783          	lw	a5,40(s2)
ffffffffc020ab24:	6511                	lui	a0,0x4
ffffffffc020ab26:	d41c                	sw	a5,40(s0)
ffffffffc020ab28:	a14f70ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020ab2c:	f448                	sd	a0,168(s0)
ffffffffc020ab2e:	87aa                	mv	a5,a0
ffffffffc020ab30:	8daa                	mv	s11,a0
ffffffffc020ab32:	1a050963          	beqz	a0,ffffffffc020ace4 <sfs_do_mount+0x284>
ffffffffc020ab36:	6711                	lui	a4,0x4
ffffffffc020ab38:	fcd6                	sd	s5,120(sp)
ffffffffc020ab3a:	ece6                	sd	s9,88(sp)
ffffffffc020ab3c:	e8ea                	sd	s10,80(sp)
ffffffffc020ab3e:	972a                	add	a4,a4,a0
ffffffffc020ab40:	e79c                	sd	a5,8(a5)
ffffffffc020ab42:	e39c                	sd	a5,0(a5)
ffffffffc020ab44:	07c1                	addi	a5,a5,16 # 1010 <_binary_bin_swap_img_size-0x6cf0>
ffffffffc020ab46:	fee79de3          	bne	a5,a4,ffffffffc020ab40 <sfs_do_mount+0xe0>
ffffffffc020ab4a:	00496783          	lwu	a5,4(s2)
ffffffffc020ab4e:	6721                	lui	a4,0x8
ffffffffc020ab50:	fff70a93          	addi	s5,a4,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc020ab54:	97d6                	add	a5,a5,s5
ffffffffc020ab56:	7761                	lui	a4,0xffff8
ffffffffc020ab58:	8ff9                	and	a5,a5,a4
ffffffffc020ab5a:	0007851b          	sext.w	a0,a5
ffffffffc020ab5e:	00078c9b          	sext.w	s9,a5
ffffffffc020ab62:	238000ef          	jal	ffffffffc020ad9a <bitmap_create>
ffffffffc020ab66:	fc08                	sd	a0,56(s0)
ffffffffc020ab68:	8d2a                	mv	s10,a0
ffffffffc020ab6a:	16050963          	beqz	a0,ffffffffc020acdc <sfs_do_mount+0x27c>
ffffffffc020ab6e:	00492783          	lw	a5,4(s2)
ffffffffc020ab72:	082c                	addi	a1,sp,24
ffffffffc020ab74:	e43e                	sd	a5,8(sp)
ffffffffc020ab76:	45a000ef          	jal	ffffffffc020afd0 <bitmap_getdata>
ffffffffc020ab7a:	16050f63          	beqz	a0,ffffffffc020acf8 <sfs_do_mount+0x298>
ffffffffc020ab7e:	00816783          	lwu	a5,8(sp)
ffffffffc020ab82:	66e2                	ld	a3,24(sp)
ffffffffc020ab84:	97d6                	add	a5,a5,s5
ffffffffc020ab86:	83bd                	srli	a5,a5,0xf
ffffffffc020ab88:	00c7971b          	slliw	a4,a5,0xc
ffffffffc020ab8c:	1702                	slli	a4,a4,0x20
ffffffffc020ab8e:	9301                	srli	a4,a4,0x20
ffffffffc020ab90:	16d71463          	bne	a4,a3,ffffffffc020acf8 <sfs_do_mount+0x298>
ffffffffc020ab94:	f0e2                	sd	s8,96(sp)
ffffffffc020ab96:	00c79713          	slli	a4,a5,0xc
ffffffffc020ab9a:	00e50c33          	add	s8,a0,a4
ffffffffc020ab9e:	8aaa                	mv	s5,a0
ffffffffc020aba0:	cbd9                	beqz	a5,ffffffffc020ac36 <sfs_do_mount+0x1d6>
ffffffffc020aba2:	6789                	lui	a5,0x2
ffffffffc020aba4:	f8da                	sd	s6,112(sp)
ffffffffc020aba6:	40a78b3b          	subw	s6,a5,a0
ffffffffc020abaa:	a029                	j	ffffffffc020abb4 <sfs_do_mount+0x154>
ffffffffc020abac:	6785                	lui	a5,0x1
ffffffffc020abae:	9abe                	add	s5,s5,a5
ffffffffc020abb0:	098a8263          	beq	s5,s8,ffffffffc020ac34 <sfs_do_mount+0x1d4>
ffffffffc020abb4:	015b06bb          	addw	a3,s6,s5
ffffffffc020abb8:	1682                	slli	a3,a3,0x20
ffffffffc020abba:	6605                	lui	a2,0x1
ffffffffc020abbc:	85d6                	mv	a1,s5
ffffffffc020abbe:	9281                	srli	a3,a3,0x20
ffffffffc020abc0:	1008                	addi	a0,sp,32
ffffffffc020abc2:	c3bfa0ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc020abc6:	709c                	ld	a5,32(s1)
ffffffffc020abc8:	85aa                	mv	a1,a0
ffffffffc020abca:	4601                	li	a2,0
ffffffffc020abcc:	8526                	mv	a0,s1
ffffffffc020abce:	9782                	jalr	a5
ffffffffc020abd0:	dd71                	beqz	a0,ffffffffc020abac <sfs_do_mount+0x14c>
ffffffffc020abd2:	e42a                	sd	a0,8(sp)
ffffffffc020abd4:	856a                	mv	a0,s10
ffffffffc020abd6:	3e0000ef          	jal	ffffffffc020afb6 <bitmap_destroy>
ffffffffc020abda:	69a2                	ld	s3,8(sp)
ffffffffc020abdc:	7b46                	ld	s6,112(sp)
ffffffffc020abde:	7c06                	ld	s8,96(sp)
ffffffffc020abe0:	856e                	mv	a0,s11
ffffffffc020abe2:	a00f70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020abe6:	7ae6                	ld	s5,120(sp)
ffffffffc020abe8:	6ce6                	ld	s9,88(sp)
ffffffffc020abea:	6d46                	ld	s10,80(sp)
ffffffffc020abec:	6da6                	ld	s11,72(sp)
ffffffffc020abee:	854a                	mv	a0,s2
ffffffffc020abf0:	9f2f70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020abf4:	8522                	mv	a0,s0
ffffffffc020abf6:	9ecf70ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020abfa:	740a                	ld	s0,160(sp)
ffffffffc020abfc:	64ea                	ld	s1,152(sp)
ffffffffc020abfe:	694a                	ld	s2,144(sp)
ffffffffc020ac00:	6a0a                	ld	s4,128(sp)
ffffffffc020ac02:	7ba6                	ld	s7,104(sp)
ffffffffc020ac04:	70aa                	ld	ra,168(sp)
ffffffffc020ac06:	854e                	mv	a0,s3
ffffffffc020ac08:	69aa                	ld	s3,136(sp)
ffffffffc020ac0a:	614d                	addi	sp,sp,176
ffffffffc020ac0c:	8082                	ret
ffffffffc020ac0e:	59f1                	li	s3,-4
ffffffffc020ac10:	b7d5                	j	ffffffffc020abf4 <sfs_do_mount+0x194>
ffffffffc020ac12:	85be                	mv	a1,a5
ffffffffc020ac14:	00004517          	auipc	a0,0x4
ffffffffc020ac18:	edc50513          	addi	a0,a0,-292 # ffffffffc020eaf0 <etext+0x321a>
ffffffffc020ac1c:	d0cf50ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020ac20:	59f5                	li	s3,-3
ffffffffc020ac22:	b7f1                	j	ffffffffc020abee <sfs_do_mount+0x18e>
ffffffffc020ac24:	00004517          	auipc	a0,0x4
ffffffffc020ac28:	e9450513          	addi	a0,a0,-364 # ffffffffc020eab8 <etext+0x31e2>
ffffffffc020ac2c:	cfcf50ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020ac30:	59f5                	li	s3,-3
ffffffffc020ac32:	bf75                	j	ffffffffc020abee <sfs_do_mount+0x18e>
ffffffffc020ac34:	7b46                	ld	s6,112(sp)
ffffffffc020ac36:	00442903          	lw	s2,4(s0)
ffffffffc020ac3a:	0a0c8863          	beqz	s9,ffffffffc020acea <sfs_do_mount+0x28a>
ffffffffc020ac3e:	4481                	li	s1,0
ffffffffc020ac40:	85a6                	mv	a1,s1
ffffffffc020ac42:	856a                	mv	a0,s10
ffffffffc020ac44:	2fa000ef          	jal	ffffffffc020af3e <bitmap_test>
ffffffffc020ac48:	c111                	beqz	a0,ffffffffc020ac4c <sfs_do_mount+0x1ec>
ffffffffc020ac4a:	2a05                	addiw	s4,s4,1
ffffffffc020ac4c:	2485                	addiw	s1,s1,1
ffffffffc020ac4e:	fe9c99e3          	bne	s9,s1,ffffffffc020ac40 <sfs_do_mount+0x1e0>
ffffffffc020ac52:	441c                	lw	a5,8(s0)
ffffffffc020ac54:	0f479a63          	bne	a5,s4,ffffffffc020ad48 <sfs_do_mount+0x2e8>
ffffffffc020ac58:	05040513          	addi	a0,s0,80
ffffffffc020ac5c:	04043023          	sd	zero,64(s0)
ffffffffc020ac60:	4585                	li	a1,1
ffffffffc020ac62:	b6bf90ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc020ac66:	06840513          	addi	a0,s0,104
ffffffffc020ac6a:	4585                	li	a1,1
ffffffffc020ac6c:	b61f90ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc020ac70:	08040513          	addi	a0,s0,128
ffffffffc020ac74:	4585                	li	a1,1
ffffffffc020ac76:	b57f90ef          	jal	ffffffffc02047cc <sem_init>
ffffffffc020ac7a:	09840793          	addi	a5,s0,152
ffffffffc020ac7e:	4149063b          	subw	a2,s2,s4
ffffffffc020ac82:	f05c                	sd	a5,160(s0)
ffffffffc020ac84:	ec5c                	sd	a5,152(s0)
ffffffffc020ac86:	874a                	mv	a4,s2
ffffffffc020ac88:	86d2                	mv	a3,s4
ffffffffc020ac8a:	00c40593          	addi	a1,s0,12
ffffffffc020ac8e:	00004517          	auipc	a0,0x4
ffffffffc020ac92:	ef250513          	addi	a0,a0,-270 # ffffffffc020eb80 <etext+0x32aa>
ffffffffc020ac96:	c92f50ef          	jal	ffffffffc0200128 <cprintf>
ffffffffc020ac9a:	00000617          	auipc	a2,0x0
ffffffffc020ac9e:	c9260613          	addi	a2,a2,-878 # ffffffffc020a92c <sfs_sync>
ffffffffc020aca2:	00000697          	auipc	a3,0x0
ffffffffc020aca6:	d6668693          	addi	a3,a3,-666 # ffffffffc020aa08 <sfs_get_root>
ffffffffc020acaa:	00000717          	auipc	a4,0x0
ffffffffc020acae:	b6e70713          	addi	a4,a4,-1170 # ffffffffc020a818 <sfs_unmount>
ffffffffc020acb2:	00000797          	auipc	a5,0x0
ffffffffc020acb6:	bea78793          	addi	a5,a5,-1046 # ffffffffc020a89c <sfs_cleanup>
ffffffffc020acba:	fc50                	sd	a2,184(s0)
ffffffffc020acbc:	e074                	sd	a3,192(s0)
ffffffffc020acbe:	e478                	sd	a4,200(s0)
ffffffffc020acc0:	e87c                	sd	a5,208(s0)
ffffffffc020acc2:	008bb023          	sd	s0,0(s7)
ffffffffc020acc6:	64ea                	ld	s1,152(sp)
ffffffffc020acc8:	740a                	ld	s0,160(sp)
ffffffffc020acca:	694a                	ld	s2,144(sp)
ffffffffc020accc:	6a0a                	ld	s4,128(sp)
ffffffffc020acce:	7ae6                	ld	s5,120(sp)
ffffffffc020acd0:	7ba6                	ld	s7,104(sp)
ffffffffc020acd2:	7c06                	ld	s8,96(sp)
ffffffffc020acd4:	6ce6                	ld	s9,88(sp)
ffffffffc020acd6:	6d46                	ld	s10,80(sp)
ffffffffc020acd8:	6da6                	ld	s11,72(sp)
ffffffffc020acda:	b72d                	j	ffffffffc020ac04 <sfs_do_mount+0x1a4>
ffffffffc020acdc:	59f1                	li	s3,-4
ffffffffc020acde:	b709                	j	ffffffffc020abe0 <sfs_do_mount+0x180>
ffffffffc020ace0:	59c9                	li	s3,-14
ffffffffc020ace2:	b70d                	j	ffffffffc020ac04 <sfs_do_mount+0x1a4>
ffffffffc020ace4:	6da6                	ld	s11,72(sp)
ffffffffc020ace6:	59f1                	li	s3,-4
ffffffffc020ace8:	b719                	j	ffffffffc020abee <sfs_do_mount+0x18e>
ffffffffc020acea:	4a01                	li	s4,0
ffffffffc020acec:	b79d                	j	ffffffffc020ac52 <sfs_do_mount+0x1f2>
ffffffffc020acee:	740a                	ld	s0,160(sp)
ffffffffc020acf0:	64ea                	ld	s1,152(sp)
ffffffffc020acf2:	7ba6                	ld	s7,104(sp)
ffffffffc020acf4:	59f1                	li	s3,-4
ffffffffc020acf6:	b739                	j	ffffffffc020ac04 <sfs_do_mount+0x1a4>
ffffffffc020acf8:	00004697          	auipc	a3,0x4
ffffffffc020acfc:	e2868693          	addi	a3,a3,-472 # ffffffffc020eb20 <etext+0x324a>
ffffffffc020ad00:	00001617          	auipc	a2,0x1
ffffffffc020ad04:	09060613          	addi	a2,a2,144 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020ad08:	08300593          	li	a1,131
ffffffffc020ad0c:	00004517          	auipc	a0,0x4
ffffffffc020ad10:	d1c50513          	addi	a0,a0,-740 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020ad14:	f8da                	sd	s6,112(sp)
ffffffffc020ad16:	f0e2                	sd	s8,96(sp)
ffffffffc020ad18:	d14f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020ad1c:	00004697          	auipc	a3,0x4
ffffffffc020ad20:	a0c68693          	addi	a3,a3,-1524 # ffffffffc020e728 <etext+0x2e52>
ffffffffc020ad24:	00001617          	auipc	a2,0x1
ffffffffc020ad28:	06c60613          	addi	a2,a2,108 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020ad2c:	0a300593          	li	a1,163
ffffffffc020ad30:	00004517          	auipc	a0,0x4
ffffffffc020ad34:	cf850513          	addi	a0,a0,-776 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020ad38:	fcd6                	sd	s5,120(sp)
ffffffffc020ad3a:	f8da                	sd	s6,112(sp)
ffffffffc020ad3c:	f0e2                	sd	s8,96(sp)
ffffffffc020ad3e:	ece6                	sd	s9,88(sp)
ffffffffc020ad40:	e8ea                	sd	s10,80(sp)
ffffffffc020ad42:	e4ee                	sd	s11,72(sp)
ffffffffc020ad44:	ce8f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020ad48:	00004697          	auipc	a3,0x4
ffffffffc020ad4c:	e0868693          	addi	a3,a3,-504 # ffffffffc020eb50 <etext+0x327a>
ffffffffc020ad50:	00001617          	auipc	a2,0x1
ffffffffc020ad54:	04060613          	addi	a2,a2,64 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020ad58:	0e000593          	li	a1,224
ffffffffc020ad5c:	00004517          	auipc	a0,0x4
ffffffffc020ad60:	ccc50513          	addi	a0,a0,-820 # ffffffffc020ea28 <etext+0x3152>
ffffffffc020ad64:	f8da                	sd	s6,112(sp)
ffffffffc020ad66:	cc6f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020ad6a <sfs_mount>:
ffffffffc020ad6a:	00000597          	auipc	a1,0x0
ffffffffc020ad6e:	cf658593          	addi	a1,a1,-778 # ffffffffc020aa60 <sfs_do_mount>
ffffffffc020ad72:	818fd06f          	j	ffffffffc0207d8a <vfs_mount>

ffffffffc020ad76 <bitmap_translate.part.0>:
ffffffffc020ad76:	1141                	addi	sp,sp,-16
ffffffffc020ad78:	00004697          	auipc	a3,0x4
ffffffffc020ad7c:	e2868693          	addi	a3,a3,-472 # ffffffffc020eba0 <etext+0x32ca>
ffffffffc020ad80:	00001617          	auipc	a2,0x1
ffffffffc020ad84:	01060613          	addi	a2,a2,16 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020ad88:	04c00593          	li	a1,76
ffffffffc020ad8c:	00004517          	auipc	a0,0x4
ffffffffc020ad90:	e2c50513          	addi	a0,a0,-468 # ffffffffc020ebb8 <etext+0x32e2>
ffffffffc020ad94:	e406                	sd	ra,8(sp)
ffffffffc020ad96:	c96f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020ad9a <bitmap_create>:
ffffffffc020ad9a:	7139                	addi	sp,sp,-64
ffffffffc020ad9c:	fc06                	sd	ra,56(sp)
ffffffffc020ad9e:	f822                	sd	s0,48(sp)
ffffffffc020ada0:	f426                	sd	s1,40(sp)
ffffffffc020ada2:	c179                	beqz	a0,ffffffffc020ae68 <bitmap_create+0xce>
ffffffffc020ada4:	842a                	mv	s0,a0
ffffffffc020ada6:	4541                	li	a0,16
ffffffffc020ada8:	f95f60ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020adac:	84aa                	mv	s1,a0
ffffffffc020adae:	c555                	beqz	a0,ffffffffc020ae5a <bitmap_create+0xc0>
ffffffffc020adb0:	e852                	sd	s4,16(sp)
ffffffffc020adb2:	02041a13          	slli	s4,s0,0x20
ffffffffc020adb6:	020a5a13          	srli	s4,s4,0x20
ffffffffc020adba:	f04a                	sd	s2,32(sp)
ffffffffc020adbc:	01fa0913          	addi	s2,s4,31
ffffffffc020adc0:	ec4e                	sd	s3,24(sp)
ffffffffc020adc2:	00595993          	srli	s3,s2,0x5
ffffffffc020adc6:	00299613          	slli	a2,s3,0x2
ffffffffc020adca:	8532                	mv	a0,a2
ffffffffc020adcc:	e432                	sd	a2,8(sp)
ffffffffc020adce:	f6ff60ef          	jal	ffffffffc0201d3c <kmalloc>
ffffffffc020add2:	6622                	ld	a2,8(sp)
ffffffffc020add4:	cd2d                	beqz	a0,ffffffffc020ae4e <bitmap_create+0xb4>
ffffffffc020add6:	c080                	sw	s0,0(s1)
ffffffffc020add8:	0134a223          	sw	s3,4(s1)
ffffffffc020addc:	0ff00593          	li	a1,255
ffffffffc020ade0:	606000ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc020ade4:	4785                	li	a5,1
ffffffffc020ade6:	1796                	slli	a5,a5,0x25
ffffffffc020ade8:	1781                	addi	a5,a5,-32
ffffffffc020adea:	e488                	sd	a0,8(s1)
ffffffffc020adec:	00f97933          	and	s2,s2,a5
ffffffffc020adf0:	052a0663          	beq	s4,s2,ffffffffc020ae3c <bitmap_create+0xa2>
ffffffffc020adf4:	39fd                	addiw	s3,s3,-1
ffffffffc020adf6:	0054571b          	srliw	a4,s0,0x5
ffffffffc020adfa:	0b371963          	bne	a4,s3,ffffffffc020aeac <bitmap_create+0x112>
ffffffffc020adfe:	0057179b          	slliw	a5,a4,0x5
ffffffffc020ae02:	40f407bb          	subw	a5,s0,a5
ffffffffc020ae06:	fff7861b          	addiw	a2,a5,-1
ffffffffc020ae0a:	46f9                	li	a3,30
ffffffffc020ae0c:	08c6e063          	bltu	a3,a2,ffffffffc020ae8c <bitmap_create+0xf2>
ffffffffc020ae10:	070a                	slli	a4,a4,0x2
ffffffffc020ae12:	953a                	add	a0,a0,a4
ffffffffc020ae14:	4118                	lw	a4,0(a0)
ffffffffc020ae16:	4585                	li	a1,1
ffffffffc020ae18:	02000613          	li	a2,32
ffffffffc020ae1c:	00f596bb          	sllw	a3,a1,a5
ffffffffc020ae20:	2785                	addiw	a5,a5,1
ffffffffc020ae22:	8f35                	xor	a4,a4,a3
ffffffffc020ae24:	fec79ce3          	bne	a5,a2,ffffffffc020ae1c <bitmap_create+0x82>
ffffffffc020ae28:	7442                	ld	s0,48(sp)
ffffffffc020ae2a:	70e2                	ld	ra,56(sp)
ffffffffc020ae2c:	c118                	sw	a4,0(a0)
ffffffffc020ae2e:	7902                	ld	s2,32(sp)
ffffffffc020ae30:	69e2                	ld	s3,24(sp)
ffffffffc020ae32:	6a42                	ld	s4,16(sp)
ffffffffc020ae34:	8526                	mv	a0,s1
ffffffffc020ae36:	74a2                	ld	s1,40(sp)
ffffffffc020ae38:	6121                	addi	sp,sp,64
ffffffffc020ae3a:	8082                	ret
ffffffffc020ae3c:	7442                	ld	s0,48(sp)
ffffffffc020ae3e:	70e2                	ld	ra,56(sp)
ffffffffc020ae40:	7902                	ld	s2,32(sp)
ffffffffc020ae42:	69e2                	ld	s3,24(sp)
ffffffffc020ae44:	6a42                	ld	s4,16(sp)
ffffffffc020ae46:	8526                	mv	a0,s1
ffffffffc020ae48:	74a2                	ld	s1,40(sp)
ffffffffc020ae4a:	6121                	addi	sp,sp,64
ffffffffc020ae4c:	8082                	ret
ffffffffc020ae4e:	8526                	mv	a0,s1
ffffffffc020ae50:	f93f60ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020ae54:	7902                	ld	s2,32(sp)
ffffffffc020ae56:	69e2                	ld	s3,24(sp)
ffffffffc020ae58:	6a42                	ld	s4,16(sp)
ffffffffc020ae5a:	7442                	ld	s0,48(sp)
ffffffffc020ae5c:	70e2                	ld	ra,56(sp)
ffffffffc020ae5e:	4481                	li	s1,0
ffffffffc020ae60:	8526                	mv	a0,s1
ffffffffc020ae62:	74a2                	ld	s1,40(sp)
ffffffffc020ae64:	6121                	addi	sp,sp,64
ffffffffc020ae66:	8082                	ret
ffffffffc020ae68:	00004697          	auipc	a3,0x4
ffffffffc020ae6c:	d6868693          	addi	a3,a3,-664 # ffffffffc020ebd0 <etext+0x32fa>
ffffffffc020ae70:	00001617          	auipc	a2,0x1
ffffffffc020ae74:	f2060613          	addi	a2,a2,-224 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020ae78:	45d5                	li	a1,21
ffffffffc020ae7a:	00004517          	auipc	a0,0x4
ffffffffc020ae7e:	d3e50513          	addi	a0,a0,-706 # ffffffffc020ebb8 <etext+0x32e2>
ffffffffc020ae82:	f04a                	sd	s2,32(sp)
ffffffffc020ae84:	ec4e                	sd	s3,24(sp)
ffffffffc020ae86:	e852                	sd	s4,16(sp)
ffffffffc020ae88:	ba4f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020ae8c:	00004697          	auipc	a3,0x4
ffffffffc020ae90:	d8468693          	addi	a3,a3,-636 # ffffffffc020ec10 <etext+0x333a>
ffffffffc020ae94:	00001617          	auipc	a2,0x1
ffffffffc020ae98:	efc60613          	addi	a2,a2,-260 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020ae9c:	02b00593          	li	a1,43
ffffffffc020aea0:	00004517          	auipc	a0,0x4
ffffffffc020aea4:	d1850513          	addi	a0,a0,-744 # ffffffffc020ebb8 <etext+0x32e2>
ffffffffc020aea8:	b84f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020aeac:	00004697          	auipc	a3,0x4
ffffffffc020aeb0:	d4c68693          	addi	a3,a3,-692 # ffffffffc020ebf8 <etext+0x3322>
ffffffffc020aeb4:	00001617          	auipc	a2,0x1
ffffffffc020aeb8:	edc60613          	addi	a2,a2,-292 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020aebc:	02a00593          	li	a1,42
ffffffffc020aec0:	00004517          	auipc	a0,0x4
ffffffffc020aec4:	cf850513          	addi	a0,a0,-776 # ffffffffc020ebb8 <etext+0x32e2>
ffffffffc020aec8:	b64f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020aecc <bitmap_alloc>:
ffffffffc020aecc:	4150                	lw	a2,4(a0)
ffffffffc020aece:	c229                	beqz	a2,ffffffffc020af10 <bitmap_alloc+0x44>
ffffffffc020aed0:	6518                	ld	a4,8(a0)
ffffffffc020aed2:	4781                	li	a5,0
ffffffffc020aed4:	a029                	j	ffffffffc020aede <bitmap_alloc+0x12>
ffffffffc020aed6:	2785                	addiw	a5,a5,1
ffffffffc020aed8:	0711                	addi	a4,a4,4
ffffffffc020aeda:	02f60b63          	beq	a2,a5,ffffffffc020af10 <bitmap_alloc+0x44>
ffffffffc020aede:	4314                	lw	a3,0(a4)
ffffffffc020aee0:	dafd                	beqz	a3,ffffffffc020aed6 <bitmap_alloc+0xa>
ffffffffc020aee2:	0016f613          	andi	a2,a3,1
ffffffffc020aee6:	ea29                	bnez	a2,ffffffffc020af38 <bitmap_alloc+0x6c>
ffffffffc020aee8:	02000893          	li	a7,32
ffffffffc020aeec:	4305                	li	t1,1
ffffffffc020aeee:	2605                	addiw	a2,a2,1
ffffffffc020aef0:	03160263          	beq	a2,a7,ffffffffc020af14 <bitmap_alloc+0x48>
ffffffffc020aef4:	00c3153b          	sllw	a0,t1,a2
ffffffffc020aef8:	00a6f833          	and	a6,a3,a0
ffffffffc020aefc:	fe0809e3          	beqz	a6,ffffffffc020aeee <bitmap_alloc+0x22>
ffffffffc020af00:	8ea9                	xor	a3,a3,a0
ffffffffc020af02:	0057979b          	slliw	a5,a5,0x5
ffffffffc020af06:	c314                	sw	a3,0(a4)
ffffffffc020af08:	9fb1                	addw	a5,a5,a2
ffffffffc020af0a:	c19c                	sw	a5,0(a1)
ffffffffc020af0c:	4501                	li	a0,0
ffffffffc020af0e:	8082                	ret
ffffffffc020af10:	5571                	li	a0,-4
ffffffffc020af12:	8082                	ret
ffffffffc020af14:	1141                	addi	sp,sp,-16
ffffffffc020af16:	00004697          	auipc	a3,0x4
ffffffffc020af1a:	d2268693          	addi	a3,a3,-734 # ffffffffc020ec38 <etext+0x3362>
ffffffffc020af1e:	00001617          	auipc	a2,0x1
ffffffffc020af22:	e7260613          	addi	a2,a2,-398 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020af26:	04300593          	li	a1,67
ffffffffc020af2a:	00004517          	auipc	a0,0x4
ffffffffc020af2e:	c8e50513          	addi	a0,a0,-882 # ffffffffc020ebb8 <etext+0x32e2>
ffffffffc020af32:	e406                	sd	ra,8(sp)
ffffffffc020af34:	af8f50ef          	jal	ffffffffc020022c <__panic>
ffffffffc020af38:	8532                	mv	a0,a2
ffffffffc020af3a:	4601                	li	a2,0
ffffffffc020af3c:	b7d1                	j	ffffffffc020af00 <bitmap_alloc+0x34>

ffffffffc020af3e <bitmap_test>:
ffffffffc020af3e:	411c                	lw	a5,0(a0)
ffffffffc020af40:	00f5ff63          	bgeu	a1,a5,ffffffffc020af5e <bitmap_test+0x20>
ffffffffc020af44:	651c                	ld	a5,8(a0)
ffffffffc020af46:	0055d71b          	srliw	a4,a1,0x5
ffffffffc020af4a:	070a                	slli	a4,a4,0x2
ffffffffc020af4c:	97ba                	add	a5,a5,a4
ffffffffc020af4e:	439c                	lw	a5,0(a5)
ffffffffc020af50:	4505                	li	a0,1
ffffffffc020af52:	00b5153b          	sllw	a0,a0,a1
ffffffffc020af56:	8d7d                	and	a0,a0,a5
ffffffffc020af58:	1502                	slli	a0,a0,0x20
ffffffffc020af5a:	9101                	srli	a0,a0,0x20
ffffffffc020af5c:	8082                	ret
ffffffffc020af5e:	1141                	addi	sp,sp,-16
ffffffffc020af60:	e406                	sd	ra,8(sp)
ffffffffc020af62:	e15ff0ef          	jal	ffffffffc020ad76 <bitmap_translate.part.0>

ffffffffc020af66 <bitmap_free>:
ffffffffc020af66:	411c                	lw	a5,0(a0)
ffffffffc020af68:	1141                	addi	sp,sp,-16
ffffffffc020af6a:	e406                	sd	ra,8(sp)
ffffffffc020af6c:	02f5f363          	bgeu	a1,a5,ffffffffc020af92 <bitmap_free+0x2c>
ffffffffc020af70:	651c                	ld	a5,8(a0)
ffffffffc020af72:	0055d71b          	srliw	a4,a1,0x5
ffffffffc020af76:	070a                	slli	a4,a4,0x2
ffffffffc020af78:	97ba                	add	a5,a5,a4
ffffffffc020af7a:	4394                	lw	a3,0(a5)
ffffffffc020af7c:	4705                	li	a4,1
ffffffffc020af7e:	00b715bb          	sllw	a1,a4,a1
ffffffffc020af82:	00b6f733          	and	a4,a3,a1
ffffffffc020af86:	eb01                	bnez	a4,ffffffffc020af96 <bitmap_free+0x30>
ffffffffc020af88:	60a2                	ld	ra,8(sp)
ffffffffc020af8a:	8ecd                	or	a3,a3,a1
ffffffffc020af8c:	c394                	sw	a3,0(a5)
ffffffffc020af8e:	0141                	addi	sp,sp,16
ffffffffc020af90:	8082                	ret
ffffffffc020af92:	de5ff0ef          	jal	ffffffffc020ad76 <bitmap_translate.part.0>
ffffffffc020af96:	00004697          	auipc	a3,0x4
ffffffffc020af9a:	caa68693          	addi	a3,a3,-854 # ffffffffc020ec40 <etext+0x336a>
ffffffffc020af9e:	00001617          	auipc	a2,0x1
ffffffffc020afa2:	df260613          	addi	a2,a2,-526 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020afa6:	05f00593          	li	a1,95
ffffffffc020afaa:	00004517          	auipc	a0,0x4
ffffffffc020afae:	c0e50513          	addi	a0,a0,-1010 # ffffffffc020ebb8 <etext+0x32e2>
ffffffffc020afb2:	a7af50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020afb6 <bitmap_destroy>:
ffffffffc020afb6:	1141                	addi	sp,sp,-16
ffffffffc020afb8:	e022                	sd	s0,0(sp)
ffffffffc020afba:	842a                	mv	s0,a0
ffffffffc020afbc:	6508                	ld	a0,8(a0)
ffffffffc020afbe:	e406                	sd	ra,8(sp)
ffffffffc020afc0:	e23f60ef          	jal	ffffffffc0201de2 <kfree>
ffffffffc020afc4:	8522                	mv	a0,s0
ffffffffc020afc6:	6402                	ld	s0,0(sp)
ffffffffc020afc8:	60a2                	ld	ra,8(sp)
ffffffffc020afca:	0141                	addi	sp,sp,16
ffffffffc020afcc:	e17f606f          	j	ffffffffc0201de2 <kfree>

ffffffffc020afd0 <bitmap_getdata>:
ffffffffc020afd0:	c589                	beqz	a1,ffffffffc020afda <bitmap_getdata+0xa>
ffffffffc020afd2:	00456783          	lwu	a5,4(a0)
ffffffffc020afd6:	078a                	slli	a5,a5,0x2
ffffffffc020afd8:	e19c                	sd	a5,0(a1)
ffffffffc020afda:	6508                	ld	a0,8(a0)
ffffffffc020afdc:	8082                	ret

ffffffffc020afde <sfs_rwblock_nolock>:
ffffffffc020afde:	7139                	addi	sp,sp,-64
ffffffffc020afe0:	f822                	sd	s0,48(sp)
ffffffffc020afe2:	f426                	sd	s1,40(sp)
ffffffffc020afe4:	fc06                	sd	ra,56(sp)
ffffffffc020afe6:	842a                	mv	s0,a0
ffffffffc020afe8:	84b6                	mv	s1,a3
ffffffffc020afea:	e219                	bnez	a2,ffffffffc020aff0 <sfs_rwblock_nolock+0x12>
ffffffffc020afec:	8b05                	andi	a4,a4,1
ffffffffc020afee:	e71d                	bnez	a4,ffffffffc020b01c <sfs_rwblock_nolock+0x3e>
ffffffffc020aff0:	405c                	lw	a5,4(s0)
ffffffffc020aff2:	02f67563          	bgeu	a2,a5,ffffffffc020b01c <sfs_rwblock_nolock+0x3e>
ffffffffc020aff6:	00c6161b          	slliw	a2,a2,0xc
ffffffffc020affa:	02061693          	slli	a3,a2,0x20
ffffffffc020affe:	9281                	srli	a3,a3,0x20
ffffffffc020b000:	6605                	lui	a2,0x1
ffffffffc020b002:	850a                	mv	a0,sp
ffffffffc020b004:	ff8fa0ef          	jal	ffffffffc02057fc <iobuf_init>
ffffffffc020b008:	85aa                	mv	a1,a0
ffffffffc020b00a:	7808                	ld	a0,48(s0)
ffffffffc020b00c:	8626                	mv	a2,s1
ffffffffc020b00e:	7118                	ld	a4,32(a0)
ffffffffc020b010:	9702                	jalr	a4
ffffffffc020b012:	70e2                	ld	ra,56(sp)
ffffffffc020b014:	7442                	ld	s0,48(sp)
ffffffffc020b016:	74a2                	ld	s1,40(sp)
ffffffffc020b018:	6121                	addi	sp,sp,64
ffffffffc020b01a:	8082                	ret
ffffffffc020b01c:	00004697          	auipc	a3,0x4
ffffffffc020b020:	c3468693          	addi	a3,a3,-972 # ffffffffc020ec50 <etext+0x337a>
ffffffffc020b024:	00001617          	auipc	a2,0x1
ffffffffc020b028:	d6c60613          	addi	a2,a2,-660 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020b02c:	45d5                	li	a1,21
ffffffffc020b02e:	00004517          	auipc	a0,0x4
ffffffffc020b032:	c5a50513          	addi	a0,a0,-934 # ffffffffc020ec88 <etext+0x33b2>
ffffffffc020b036:	9f6f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020b03a <sfs_rblock>:
ffffffffc020b03a:	7139                	addi	sp,sp,-64
ffffffffc020b03c:	ec4e                	sd	s3,24(sp)
ffffffffc020b03e:	89b6                	mv	s3,a3
ffffffffc020b040:	f822                	sd	s0,48(sp)
ffffffffc020b042:	f04a                	sd	s2,32(sp)
ffffffffc020b044:	e852                	sd	s4,16(sp)
ffffffffc020b046:	fc06                	sd	ra,56(sp)
ffffffffc020b048:	f426                	sd	s1,40(sp)
ffffffffc020b04a:	892e                	mv	s2,a1
ffffffffc020b04c:	8432                	mv	s0,a2
ffffffffc020b04e:	8a2a                	mv	s4,a0
ffffffffc020b050:	944fe0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b054:	02098763          	beqz	s3,ffffffffc020b082 <sfs_rblock+0x48>
ffffffffc020b058:	e456                	sd	s5,8(sp)
ffffffffc020b05a:	013409bb          	addw	s3,s0,s3
ffffffffc020b05e:	6a85                	lui	s5,0x1
ffffffffc020b060:	a021                	j	ffffffffc020b068 <sfs_rblock+0x2e>
ffffffffc020b062:	9956                	add	s2,s2,s5
ffffffffc020b064:	01340e63          	beq	s0,s3,ffffffffc020b080 <sfs_rblock+0x46>
ffffffffc020b068:	8622                	mv	a2,s0
ffffffffc020b06a:	4705                	li	a4,1
ffffffffc020b06c:	4681                	li	a3,0
ffffffffc020b06e:	85ca                	mv	a1,s2
ffffffffc020b070:	8552                	mv	a0,s4
ffffffffc020b072:	f6dff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b076:	84aa                	mv	s1,a0
ffffffffc020b078:	2405                	addiw	s0,s0,1
ffffffffc020b07a:	d565                	beqz	a0,ffffffffc020b062 <sfs_rblock+0x28>
ffffffffc020b07c:	6aa2                	ld	s5,8(sp)
ffffffffc020b07e:	a019                	j	ffffffffc020b084 <sfs_rblock+0x4a>
ffffffffc020b080:	6aa2                	ld	s5,8(sp)
ffffffffc020b082:	4481                	li	s1,0
ffffffffc020b084:	8552                	mv	a0,s4
ffffffffc020b086:	91efe0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b08a:	70e2                	ld	ra,56(sp)
ffffffffc020b08c:	7442                	ld	s0,48(sp)
ffffffffc020b08e:	7902                	ld	s2,32(sp)
ffffffffc020b090:	69e2                	ld	s3,24(sp)
ffffffffc020b092:	6a42                	ld	s4,16(sp)
ffffffffc020b094:	8526                	mv	a0,s1
ffffffffc020b096:	74a2                	ld	s1,40(sp)
ffffffffc020b098:	6121                	addi	sp,sp,64
ffffffffc020b09a:	8082                	ret

ffffffffc020b09c <sfs_wblock>:
ffffffffc020b09c:	7139                	addi	sp,sp,-64
ffffffffc020b09e:	ec4e                	sd	s3,24(sp)
ffffffffc020b0a0:	89b6                	mv	s3,a3
ffffffffc020b0a2:	f822                	sd	s0,48(sp)
ffffffffc020b0a4:	f04a                	sd	s2,32(sp)
ffffffffc020b0a6:	e852                	sd	s4,16(sp)
ffffffffc020b0a8:	fc06                	sd	ra,56(sp)
ffffffffc020b0aa:	f426                	sd	s1,40(sp)
ffffffffc020b0ac:	892e                	mv	s2,a1
ffffffffc020b0ae:	8432                	mv	s0,a2
ffffffffc020b0b0:	8a2a                	mv	s4,a0
ffffffffc020b0b2:	8e2fe0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b0b6:	02098763          	beqz	s3,ffffffffc020b0e4 <sfs_wblock+0x48>
ffffffffc020b0ba:	e456                	sd	s5,8(sp)
ffffffffc020b0bc:	013409bb          	addw	s3,s0,s3
ffffffffc020b0c0:	6a85                	lui	s5,0x1
ffffffffc020b0c2:	a021                	j	ffffffffc020b0ca <sfs_wblock+0x2e>
ffffffffc020b0c4:	9956                	add	s2,s2,s5
ffffffffc020b0c6:	01340e63          	beq	s0,s3,ffffffffc020b0e2 <sfs_wblock+0x46>
ffffffffc020b0ca:	4705                	li	a4,1
ffffffffc020b0cc:	8622                	mv	a2,s0
ffffffffc020b0ce:	86ba                	mv	a3,a4
ffffffffc020b0d0:	85ca                	mv	a1,s2
ffffffffc020b0d2:	8552                	mv	a0,s4
ffffffffc020b0d4:	f0bff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b0d8:	84aa                	mv	s1,a0
ffffffffc020b0da:	2405                	addiw	s0,s0,1
ffffffffc020b0dc:	d565                	beqz	a0,ffffffffc020b0c4 <sfs_wblock+0x28>
ffffffffc020b0de:	6aa2                	ld	s5,8(sp)
ffffffffc020b0e0:	a019                	j	ffffffffc020b0e6 <sfs_wblock+0x4a>
ffffffffc020b0e2:	6aa2                	ld	s5,8(sp)
ffffffffc020b0e4:	4481                	li	s1,0
ffffffffc020b0e6:	8552                	mv	a0,s4
ffffffffc020b0e8:	8bcfe0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b0ec:	70e2                	ld	ra,56(sp)
ffffffffc020b0ee:	7442                	ld	s0,48(sp)
ffffffffc020b0f0:	7902                	ld	s2,32(sp)
ffffffffc020b0f2:	69e2                	ld	s3,24(sp)
ffffffffc020b0f4:	6a42                	ld	s4,16(sp)
ffffffffc020b0f6:	8526                	mv	a0,s1
ffffffffc020b0f8:	74a2                	ld	s1,40(sp)
ffffffffc020b0fa:	6121                	addi	sp,sp,64
ffffffffc020b0fc:	8082                	ret

ffffffffc020b0fe <sfs_rbuf>:
ffffffffc020b0fe:	7179                	addi	sp,sp,-48
ffffffffc020b100:	f406                	sd	ra,40(sp)
ffffffffc020b102:	f022                	sd	s0,32(sp)
ffffffffc020b104:	ec26                	sd	s1,24(sp)
ffffffffc020b106:	e84a                	sd	s2,16(sp)
ffffffffc020b108:	e44e                	sd	s3,8(sp)
ffffffffc020b10a:	e052                	sd	s4,0(sp)
ffffffffc020b10c:	6785                	lui	a5,0x1
ffffffffc020b10e:	04f77863          	bgeu	a4,a5,ffffffffc020b15e <sfs_rbuf+0x60>
ffffffffc020b112:	84ba                	mv	s1,a4
ffffffffc020b114:	9732                	add	a4,a4,a2
ffffffffc020b116:	04e7e463          	bltu	a5,a4,ffffffffc020b15e <sfs_rbuf+0x60>
ffffffffc020b11a:	8936                	mv	s2,a3
ffffffffc020b11c:	842a                	mv	s0,a0
ffffffffc020b11e:	89ae                	mv	s3,a1
ffffffffc020b120:	8a32                	mv	s4,a2
ffffffffc020b122:	872fe0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b126:	642c                	ld	a1,72(s0)
ffffffffc020b128:	864a                	mv	a2,s2
ffffffffc020b12a:	8522                	mv	a0,s0
ffffffffc020b12c:	4705                	li	a4,1
ffffffffc020b12e:	4681                	li	a3,0
ffffffffc020b130:	eafff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b134:	892a                	mv	s2,a0
ffffffffc020b136:	cd09                	beqz	a0,ffffffffc020b150 <sfs_rbuf+0x52>
ffffffffc020b138:	8522                	mv	a0,s0
ffffffffc020b13a:	86afe0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b13e:	70a2                	ld	ra,40(sp)
ffffffffc020b140:	7402                	ld	s0,32(sp)
ffffffffc020b142:	64e2                	ld	s1,24(sp)
ffffffffc020b144:	69a2                	ld	s3,8(sp)
ffffffffc020b146:	6a02                	ld	s4,0(sp)
ffffffffc020b148:	854a                	mv	a0,s2
ffffffffc020b14a:	6942                	ld	s2,16(sp)
ffffffffc020b14c:	6145                	addi	sp,sp,48
ffffffffc020b14e:	8082                	ret
ffffffffc020b150:	642c                	ld	a1,72(s0)
ffffffffc020b152:	8652                	mv	a2,s4
ffffffffc020b154:	854e                	mv	a0,s3
ffffffffc020b156:	95a6                	add	a1,a1,s1
ffffffffc020b158:	2de000ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc020b15c:	bff1                	j	ffffffffc020b138 <sfs_rbuf+0x3a>
ffffffffc020b15e:	00004697          	auipc	a3,0x4
ffffffffc020b162:	b4268693          	addi	a3,a3,-1214 # ffffffffc020eca0 <etext+0x33ca>
ffffffffc020b166:	00001617          	auipc	a2,0x1
ffffffffc020b16a:	c2a60613          	addi	a2,a2,-982 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020b16e:	05500593          	li	a1,85
ffffffffc020b172:	00004517          	auipc	a0,0x4
ffffffffc020b176:	b1650513          	addi	a0,a0,-1258 # ffffffffc020ec88 <etext+0x33b2>
ffffffffc020b17a:	8b2f50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020b17e <sfs_wbuf>:
ffffffffc020b17e:	7139                	addi	sp,sp,-64
ffffffffc020b180:	fc06                	sd	ra,56(sp)
ffffffffc020b182:	f822                	sd	s0,48(sp)
ffffffffc020b184:	f426                	sd	s1,40(sp)
ffffffffc020b186:	f04a                	sd	s2,32(sp)
ffffffffc020b188:	ec4e                	sd	s3,24(sp)
ffffffffc020b18a:	e852                	sd	s4,16(sp)
ffffffffc020b18c:	e456                	sd	s5,8(sp)
ffffffffc020b18e:	6785                	lui	a5,0x1
ffffffffc020b190:	06f77163          	bgeu	a4,a5,ffffffffc020b1f2 <sfs_wbuf+0x74>
ffffffffc020b194:	893a                	mv	s2,a4
ffffffffc020b196:	9732                	add	a4,a4,a2
ffffffffc020b198:	04e7ed63          	bltu	a5,a4,ffffffffc020b1f2 <sfs_wbuf+0x74>
ffffffffc020b19c:	89b6                	mv	s3,a3
ffffffffc020b19e:	84aa                	mv	s1,a0
ffffffffc020b1a0:	8a2e                	mv	s4,a1
ffffffffc020b1a2:	8ab2                	mv	s5,a2
ffffffffc020b1a4:	ff1fd0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b1a8:	64ac                	ld	a1,72(s1)
ffffffffc020b1aa:	864e                	mv	a2,s3
ffffffffc020b1ac:	8526                	mv	a0,s1
ffffffffc020b1ae:	4705                	li	a4,1
ffffffffc020b1b0:	4681                	li	a3,0
ffffffffc020b1b2:	e2dff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b1b6:	842a                	mv	s0,a0
ffffffffc020b1b8:	cd11                	beqz	a0,ffffffffc020b1d4 <sfs_wbuf+0x56>
ffffffffc020b1ba:	8526                	mv	a0,s1
ffffffffc020b1bc:	fe9fd0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b1c0:	70e2                	ld	ra,56(sp)
ffffffffc020b1c2:	8522                	mv	a0,s0
ffffffffc020b1c4:	7442                	ld	s0,48(sp)
ffffffffc020b1c6:	74a2                	ld	s1,40(sp)
ffffffffc020b1c8:	7902                	ld	s2,32(sp)
ffffffffc020b1ca:	69e2                	ld	s3,24(sp)
ffffffffc020b1cc:	6a42                	ld	s4,16(sp)
ffffffffc020b1ce:	6aa2                	ld	s5,8(sp)
ffffffffc020b1d0:	6121                	addi	sp,sp,64
ffffffffc020b1d2:	8082                	ret
ffffffffc020b1d4:	64a8                	ld	a0,72(s1)
ffffffffc020b1d6:	8656                	mv	a2,s5
ffffffffc020b1d8:	85d2                	mv	a1,s4
ffffffffc020b1da:	954a                	add	a0,a0,s2
ffffffffc020b1dc:	25a000ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc020b1e0:	64ac                	ld	a1,72(s1)
ffffffffc020b1e2:	4705                	li	a4,1
ffffffffc020b1e4:	864e                	mv	a2,s3
ffffffffc020b1e6:	8526                	mv	a0,s1
ffffffffc020b1e8:	86ba                	mv	a3,a4
ffffffffc020b1ea:	df5ff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b1ee:	842a                	mv	s0,a0
ffffffffc020b1f0:	b7e9                	j	ffffffffc020b1ba <sfs_wbuf+0x3c>
ffffffffc020b1f2:	00004697          	auipc	a3,0x4
ffffffffc020b1f6:	aae68693          	addi	a3,a3,-1362 # ffffffffc020eca0 <etext+0x33ca>
ffffffffc020b1fa:	00001617          	auipc	a2,0x1
ffffffffc020b1fe:	b9660613          	addi	a2,a2,-1130 # ffffffffc020bd90 <etext+0x4ba>
ffffffffc020b202:	06b00593          	li	a1,107
ffffffffc020b206:	00004517          	auipc	a0,0x4
ffffffffc020b20a:	a8250513          	addi	a0,a0,-1406 # ffffffffc020ec88 <etext+0x33b2>
ffffffffc020b20e:	81ef50ef          	jal	ffffffffc020022c <__panic>

ffffffffc020b212 <sfs_sync_super>:
ffffffffc020b212:	1101                	addi	sp,sp,-32
ffffffffc020b214:	ec06                	sd	ra,24(sp)
ffffffffc020b216:	e822                	sd	s0,16(sp)
ffffffffc020b218:	e426                	sd	s1,8(sp)
ffffffffc020b21a:	842a                	mv	s0,a0
ffffffffc020b21c:	f79fd0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b220:	6428                	ld	a0,72(s0)
ffffffffc020b222:	6605                	lui	a2,0x1
ffffffffc020b224:	4581                	li	a1,0
ffffffffc020b226:	1c0000ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc020b22a:	6428                	ld	a0,72(s0)
ffffffffc020b22c:	85a2                	mv	a1,s0
ffffffffc020b22e:	02c00613          	li	a2,44
ffffffffc020b232:	204000ef          	jal	ffffffffc020b436 <memcpy>
ffffffffc020b236:	642c                	ld	a1,72(s0)
ffffffffc020b238:	8522                	mv	a0,s0
ffffffffc020b23a:	4701                	li	a4,0
ffffffffc020b23c:	4685                	li	a3,1
ffffffffc020b23e:	4601                	li	a2,0
ffffffffc020b240:	d9fff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b244:	84aa                	mv	s1,a0
ffffffffc020b246:	8522                	mv	a0,s0
ffffffffc020b248:	f5dfd0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b24c:	60e2                	ld	ra,24(sp)
ffffffffc020b24e:	6442                	ld	s0,16(sp)
ffffffffc020b250:	8526                	mv	a0,s1
ffffffffc020b252:	64a2                	ld	s1,8(sp)
ffffffffc020b254:	6105                	addi	sp,sp,32
ffffffffc020b256:	8082                	ret

ffffffffc020b258 <sfs_sync_freemap>:
ffffffffc020b258:	7139                	addi	sp,sp,-64
ffffffffc020b25a:	ec4e                	sd	s3,24(sp)
ffffffffc020b25c:	e852                	sd	s4,16(sp)
ffffffffc020b25e:	00456983          	lwu	s3,4(a0)
ffffffffc020b262:	8a2a                	mv	s4,a0
ffffffffc020b264:	7d08                	ld	a0,56(a0)
ffffffffc020b266:	67a1                	lui	a5,0x8
ffffffffc020b268:	17fd                	addi	a5,a5,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc020b26a:	4581                	li	a1,0
ffffffffc020b26c:	f822                	sd	s0,48(sp)
ffffffffc020b26e:	fc06                	sd	ra,56(sp)
ffffffffc020b270:	f426                	sd	s1,40(sp)
ffffffffc020b272:	99be                	add	s3,s3,a5
ffffffffc020b274:	d5dff0ef          	jal	ffffffffc020afd0 <bitmap_getdata>
ffffffffc020b278:	00f9d993          	srli	s3,s3,0xf
ffffffffc020b27c:	842a                	mv	s0,a0
ffffffffc020b27e:	8552                	mv	a0,s4
ffffffffc020b280:	f15fd0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b284:	02098b63          	beqz	s3,ffffffffc020b2ba <sfs_sync_freemap+0x62>
ffffffffc020b288:	09b2                	slli	s3,s3,0xc
ffffffffc020b28a:	f04a                	sd	s2,32(sp)
ffffffffc020b28c:	e456                	sd	s5,8(sp)
ffffffffc020b28e:	99a2                	add	s3,s3,s0
ffffffffc020b290:	4909                	li	s2,2
ffffffffc020b292:	6a85                	lui	s5,0x1
ffffffffc020b294:	a021                	j	ffffffffc020b29c <sfs_sync_freemap+0x44>
ffffffffc020b296:	2905                	addiw	s2,s2,1
ffffffffc020b298:	01340f63          	beq	s0,s3,ffffffffc020b2b6 <sfs_sync_freemap+0x5e>
ffffffffc020b29c:	4705                	li	a4,1
ffffffffc020b29e:	85a2                	mv	a1,s0
ffffffffc020b2a0:	86ba                	mv	a3,a4
ffffffffc020b2a2:	864a                	mv	a2,s2
ffffffffc020b2a4:	8552                	mv	a0,s4
ffffffffc020b2a6:	d39ff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b2aa:	84aa                	mv	s1,a0
ffffffffc020b2ac:	9456                	add	s0,s0,s5
ffffffffc020b2ae:	d565                	beqz	a0,ffffffffc020b296 <sfs_sync_freemap+0x3e>
ffffffffc020b2b0:	7902                	ld	s2,32(sp)
ffffffffc020b2b2:	6aa2                	ld	s5,8(sp)
ffffffffc020b2b4:	a021                	j	ffffffffc020b2bc <sfs_sync_freemap+0x64>
ffffffffc020b2b6:	7902                	ld	s2,32(sp)
ffffffffc020b2b8:	6aa2                	ld	s5,8(sp)
ffffffffc020b2ba:	4481                	li	s1,0
ffffffffc020b2bc:	8552                	mv	a0,s4
ffffffffc020b2be:	ee7fd0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b2c2:	70e2                	ld	ra,56(sp)
ffffffffc020b2c4:	7442                	ld	s0,48(sp)
ffffffffc020b2c6:	69e2                	ld	s3,24(sp)
ffffffffc020b2c8:	6a42                	ld	s4,16(sp)
ffffffffc020b2ca:	8526                	mv	a0,s1
ffffffffc020b2cc:	74a2                	ld	s1,40(sp)
ffffffffc020b2ce:	6121                	addi	sp,sp,64
ffffffffc020b2d0:	8082                	ret

ffffffffc020b2d2 <sfs_clear_block>:
ffffffffc020b2d2:	7179                	addi	sp,sp,-48
ffffffffc020b2d4:	f022                	sd	s0,32(sp)
ffffffffc020b2d6:	e84a                	sd	s2,16(sp)
ffffffffc020b2d8:	e44e                	sd	s3,8(sp)
ffffffffc020b2da:	f406                	sd	ra,40(sp)
ffffffffc020b2dc:	89b2                	mv	s3,a2
ffffffffc020b2de:	ec26                	sd	s1,24(sp)
ffffffffc020b2e0:	842e                	mv	s0,a1
ffffffffc020b2e2:	892a                	mv	s2,a0
ffffffffc020b2e4:	eb1fd0ef          	jal	ffffffffc0209194 <lock_sfs_io>
ffffffffc020b2e8:	04893503          	ld	a0,72(s2)
ffffffffc020b2ec:	6605                	lui	a2,0x1
ffffffffc020b2ee:	4581                	li	a1,0
ffffffffc020b2f0:	0f6000ef          	jal	ffffffffc020b3e6 <memset>
ffffffffc020b2f4:	02098d63          	beqz	s3,ffffffffc020b32e <sfs_clear_block+0x5c>
ffffffffc020b2f8:	013409bb          	addw	s3,s0,s3
ffffffffc020b2fc:	a019                	j	ffffffffc020b302 <sfs_clear_block+0x30>
ffffffffc020b2fe:	03340863          	beq	s0,s3,ffffffffc020b32e <sfs_clear_block+0x5c>
ffffffffc020b302:	04893583          	ld	a1,72(s2)
ffffffffc020b306:	4705                	li	a4,1
ffffffffc020b308:	8622                	mv	a2,s0
ffffffffc020b30a:	86ba                	mv	a3,a4
ffffffffc020b30c:	854a                	mv	a0,s2
ffffffffc020b30e:	cd1ff0ef          	jal	ffffffffc020afde <sfs_rwblock_nolock>
ffffffffc020b312:	84aa                	mv	s1,a0
ffffffffc020b314:	2405                	addiw	s0,s0,1
ffffffffc020b316:	d565                	beqz	a0,ffffffffc020b2fe <sfs_clear_block+0x2c>
ffffffffc020b318:	854a                	mv	a0,s2
ffffffffc020b31a:	e8bfd0ef          	jal	ffffffffc02091a4 <unlock_sfs_io>
ffffffffc020b31e:	70a2                	ld	ra,40(sp)
ffffffffc020b320:	7402                	ld	s0,32(sp)
ffffffffc020b322:	6942                	ld	s2,16(sp)
ffffffffc020b324:	69a2                	ld	s3,8(sp)
ffffffffc020b326:	8526                	mv	a0,s1
ffffffffc020b328:	64e2                	ld	s1,24(sp)
ffffffffc020b32a:	6145                	addi	sp,sp,48
ffffffffc020b32c:	8082                	ret
ffffffffc020b32e:	4481                	li	s1,0
ffffffffc020b330:	b7e5                	j	ffffffffc020b318 <sfs_clear_block+0x46>

ffffffffc020b332 <strlen>:
ffffffffc020b332:	00054783          	lbu	a5,0(a0)
ffffffffc020b336:	cb81                	beqz	a5,ffffffffc020b346 <strlen+0x14>
ffffffffc020b338:	4781                	li	a5,0
ffffffffc020b33a:	0785                	addi	a5,a5,1
ffffffffc020b33c:	00f50733          	add	a4,a0,a5
ffffffffc020b340:	00074703          	lbu	a4,0(a4)
ffffffffc020b344:	fb7d                	bnez	a4,ffffffffc020b33a <strlen+0x8>
ffffffffc020b346:	853e                	mv	a0,a5
ffffffffc020b348:	8082                	ret

ffffffffc020b34a <strnlen>:
ffffffffc020b34a:	4781                	li	a5,0
ffffffffc020b34c:	e589                	bnez	a1,ffffffffc020b356 <strnlen+0xc>
ffffffffc020b34e:	a811                	j	ffffffffc020b362 <strnlen+0x18>
ffffffffc020b350:	0785                	addi	a5,a5,1
ffffffffc020b352:	00f58863          	beq	a1,a5,ffffffffc020b362 <strnlen+0x18>
ffffffffc020b356:	00f50733          	add	a4,a0,a5
ffffffffc020b35a:	00074703          	lbu	a4,0(a4)
ffffffffc020b35e:	fb6d                	bnez	a4,ffffffffc020b350 <strnlen+0x6>
ffffffffc020b360:	85be                	mv	a1,a5
ffffffffc020b362:	852e                	mv	a0,a1
ffffffffc020b364:	8082                	ret

ffffffffc020b366 <strcpy>:
ffffffffc020b366:	87aa                	mv	a5,a0
ffffffffc020b368:	0005c703          	lbu	a4,0(a1)
ffffffffc020b36c:	0585                	addi	a1,a1,1
ffffffffc020b36e:	0785                	addi	a5,a5,1
ffffffffc020b370:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b374:	fb75                	bnez	a4,ffffffffc020b368 <strcpy+0x2>
ffffffffc020b376:	8082                	ret

ffffffffc020b378 <strcmp>:
ffffffffc020b378:	00054783          	lbu	a5,0(a0)
ffffffffc020b37c:	e791                	bnez	a5,ffffffffc020b388 <strcmp+0x10>
ffffffffc020b37e:	a01d                	j	ffffffffc020b3a4 <strcmp+0x2c>
ffffffffc020b380:	00054783          	lbu	a5,0(a0)
ffffffffc020b384:	cb99                	beqz	a5,ffffffffc020b39a <strcmp+0x22>
ffffffffc020b386:	0585                	addi	a1,a1,1
ffffffffc020b388:	0005c703          	lbu	a4,0(a1)
ffffffffc020b38c:	0505                	addi	a0,a0,1
ffffffffc020b38e:	fef709e3          	beq	a4,a5,ffffffffc020b380 <strcmp+0x8>
ffffffffc020b392:	0007851b          	sext.w	a0,a5
ffffffffc020b396:	9d19                	subw	a0,a0,a4
ffffffffc020b398:	8082                	ret
ffffffffc020b39a:	0015c703          	lbu	a4,1(a1)
ffffffffc020b39e:	4501                	li	a0,0
ffffffffc020b3a0:	9d19                	subw	a0,a0,a4
ffffffffc020b3a2:	8082                	ret
ffffffffc020b3a4:	0005c703          	lbu	a4,0(a1)
ffffffffc020b3a8:	4501                	li	a0,0
ffffffffc020b3aa:	b7f5                	j	ffffffffc020b396 <strcmp+0x1e>

ffffffffc020b3ac <strncmp>:
ffffffffc020b3ac:	ce01                	beqz	a2,ffffffffc020b3c4 <strncmp+0x18>
ffffffffc020b3ae:	00054783          	lbu	a5,0(a0)
ffffffffc020b3b2:	167d                	addi	a2,a2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020b3b4:	cb91                	beqz	a5,ffffffffc020b3c8 <strncmp+0x1c>
ffffffffc020b3b6:	0005c703          	lbu	a4,0(a1)
ffffffffc020b3ba:	00f71763          	bne	a4,a5,ffffffffc020b3c8 <strncmp+0x1c>
ffffffffc020b3be:	0505                	addi	a0,a0,1
ffffffffc020b3c0:	0585                	addi	a1,a1,1
ffffffffc020b3c2:	f675                	bnez	a2,ffffffffc020b3ae <strncmp+0x2>
ffffffffc020b3c4:	4501                	li	a0,0
ffffffffc020b3c6:	8082                	ret
ffffffffc020b3c8:	00054503          	lbu	a0,0(a0)
ffffffffc020b3cc:	0005c783          	lbu	a5,0(a1)
ffffffffc020b3d0:	9d1d                	subw	a0,a0,a5
ffffffffc020b3d2:	8082                	ret

ffffffffc020b3d4 <strchr>:
ffffffffc020b3d4:	a021                	j	ffffffffc020b3dc <strchr+0x8>
ffffffffc020b3d6:	00f58763          	beq	a1,a5,ffffffffc020b3e4 <strchr+0x10>
ffffffffc020b3da:	0505                	addi	a0,a0,1
ffffffffc020b3dc:	00054783          	lbu	a5,0(a0)
ffffffffc020b3e0:	fbfd                	bnez	a5,ffffffffc020b3d6 <strchr+0x2>
ffffffffc020b3e2:	4501                	li	a0,0
ffffffffc020b3e4:	8082                	ret

ffffffffc020b3e6 <memset>:
ffffffffc020b3e6:	ca01                	beqz	a2,ffffffffc020b3f6 <memset+0x10>
ffffffffc020b3e8:	962a                	add	a2,a2,a0
ffffffffc020b3ea:	87aa                	mv	a5,a0
ffffffffc020b3ec:	0785                	addi	a5,a5,1
ffffffffc020b3ee:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020b3f2:	fef61de3          	bne	a2,a5,ffffffffc020b3ec <memset+0x6>
ffffffffc020b3f6:	8082                	ret

ffffffffc020b3f8 <memmove>:
ffffffffc020b3f8:	02a5f163          	bgeu	a1,a0,ffffffffc020b41a <memmove+0x22>
ffffffffc020b3fc:	00c587b3          	add	a5,a1,a2
ffffffffc020b400:	00f57d63          	bgeu	a0,a5,ffffffffc020b41a <memmove+0x22>
ffffffffc020b404:	c61d                	beqz	a2,ffffffffc020b432 <memmove+0x3a>
ffffffffc020b406:	962a                	add	a2,a2,a0
ffffffffc020b408:	fff7c703          	lbu	a4,-1(a5)
ffffffffc020b40c:	17fd                	addi	a5,a5,-1
ffffffffc020b40e:	167d                	addi	a2,a2,-1
ffffffffc020b410:	00e60023          	sb	a4,0(a2)
ffffffffc020b414:	fef59ae3          	bne	a1,a5,ffffffffc020b408 <memmove+0x10>
ffffffffc020b418:	8082                	ret
ffffffffc020b41a:	00c586b3          	add	a3,a1,a2
ffffffffc020b41e:	87aa                	mv	a5,a0
ffffffffc020b420:	ca11                	beqz	a2,ffffffffc020b434 <memmove+0x3c>
ffffffffc020b422:	0005c703          	lbu	a4,0(a1)
ffffffffc020b426:	0585                	addi	a1,a1,1
ffffffffc020b428:	0785                	addi	a5,a5,1
ffffffffc020b42a:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b42e:	feb69ae3          	bne	a3,a1,ffffffffc020b422 <memmove+0x2a>
ffffffffc020b432:	8082                	ret
ffffffffc020b434:	8082                	ret

ffffffffc020b436 <memcpy>:
ffffffffc020b436:	ca19                	beqz	a2,ffffffffc020b44c <memcpy+0x16>
ffffffffc020b438:	962e                	add	a2,a2,a1
ffffffffc020b43a:	87aa                	mv	a5,a0
ffffffffc020b43c:	0005c703          	lbu	a4,0(a1)
ffffffffc020b440:	0585                	addi	a1,a1,1
ffffffffc020b442:	0785                	addi	a5,a5,1
ffffffffc020b444:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b448:	feb61ae3          	bne	a2,a1,ffffffffc020b43c <memcpy+0x6>
ffffffffc020b44c:	8082                	ret

ffffffffc020b44e <printnum>:
ffffffffc020b44e:	7139                	addi	sp,sp,-64
ffffffffc020b450:	02071893          	slli	a7,a4,0x20
ffffffffc020b454:	f822                	sd	s0,48(sp)
ffffffffc020b456:	f426                	sd	s1,40(sp)
ffffffffc020b458:	f04a                	sd	s2,32(sp)
ffffffffc020b45a:	ec4e                	sd	s3,24(sp)
ffffffffc020b45c:	e456                	sd	s5,8(sp)
ffffffffc020b45e:	0208d893          	srli	a7,a7,0x20
ffffffffc020b462:	fc06                	sd	ra,56(sp)
ffffffffc020b464:	0316fab3          	remu	s5,a3,a7
ffffffffc020b468:	fff7841b          	addiw	s0,a5,-1
ffffffffc020b46c:	84aa                	mv	s1,a0
ffffffffc020b46e:	89ae                	mv	s3,a1
ffffffffc020b470:	8932                	mv	s2,a2
ffffffffc020b472:	0516f063          	bgeu	a3,a7,ffffffffc020b4b2 <printnum+0x64>
ffffffffc020b476:	e852                	sd	s4,16(sp)
ffffffffc020b478:	4705                	li	a4,1
ffffffffc020b47a:	8a42                	mv	s4,a6
ffffffffc020b47c:	00f75863          	bge	a4,a5,ffffffffc020b48c <printnum+0x3e>
ffffffffc020b480:	864e                	mv	a2,s3
ffffffffc020b482:	85ca                	mv	a1,s2
ffffffffc020b484:	8552                	mv	a0,s4
ffffffffc020b486:	347d                	addiw	s0,s0,-1
ffffffffc020b488:	9482                	jalr	s1
ffffffffc020b48a:	f87d                	bnez	s0,ffffffffc020b480 <printnum+0x32>
ffffffffc020b48c:	6a42                	ld	s4,16(sp)
ffffffffc020b48e:	00004797          	auipc	a5,0x4
ffffffffc020b492:	85a78793          	addi	a5,a5,-1958 # ffffffffc020ece8 <etext+0x3412>
ffffffffc020b496:	97d6                	add	a5,a5,s5
ffffffffc020b498:	7442                	ld	s0,48(sp)
ffffffffc020b49a:	0007c503          	lbu	a0,0(a5)
ffffffffc020b49e:	70e2                	ld	ra,56(sp)
ffffffffc020b4a0:	6aa2                	ld	s5,8(sp)
ffffffffc020b4a2:	864e                	mv	a2,s3
ffffffffc020b4a4:	85ca                	mv	a1,s2
ffffffffc020b4a6:	69e2                	ld	s3,24(sp)
ffffffffc020b4a8:	7902                	ld	s2,32(sp)
ffffffffc020b4aa:	87a6                	mv	a5,s1
ffffffffc020b4ac:	74a2                	ld	s1,40(sp)
ffffffffc020b4ae:	6121                	addi	sp,sp,64
ffffffffc020b4b0:	8782                	jr	a5
ffffffffc020b4b2:	0316d6b3          	divu	a3,a3,a7
ffffffffc020b4b6:	87a2                	mv	a5,s0
ffffffffc020b4b8:	f97ff0ef          	jal	ffffffffc020b44e <printnum>
ffffffffc020b4bc:	bfc9                	j	ffffffffc020b48e <printnum+0x40>

ffffffffc020b4be <sprintputch>:
ffffffffc020b4be:	499c                	lw	a5,16(a1)
ffffffffc020b4c0:	6198                	ld	a4,0(a1)
ffffffffc020b4c2:	6594                	ld	a3,8(a1)
ffffffffc020b4c4:	2785                	addiw	a5,a5,1
ffffffffc020b4c6:	c99c                	sw	a5,16(a1)
ffffffffc020b4c8:	00d77763          	bgeu	a4,a3,ffffffffc020b4d6 <sprintputch+0x18>
ffffffffc020b4cc:	00170793          	addi	a5,a4,1
ffffffffc020b4d0:	e19c                	sd	a5,0(a1)
ffffffffc020b4d2:	00a70023          	sb	a0,0(a4)
ffffffffc020b4d6:	8082                	ret

ffffffffc020b4d8 <vprintfmt>:
ffffffffc020b4d8:	7119                	addi	sp,sp,-128
ffffffffc020b4da:	f4a6                	sd	s1,104(sp)
ffffffffc020b4dc:	f0ca                	sd	s2,96(sp)
ffffffffc020b4de:	ecce                	sd	s3,88(sp)
ffffffffc020b4e0:	e8d2                	sd	s4,80(sp)
ffffffffc020b4e2:	e4d6                	sd	s5,72(sp)
ffffffffc020b4e4:	e0da                	sd	s6,64(sp)
ffffffffc020b4e6:	fc5e                	sd	s7,56(sp)
ffffffffc020b4e8:	f466                	sd	s9,40(sp)
ffffffffc020b4ea:	fc86                	sd	ra,120(sp)
ffffffffc020b4ec:	f8a2                	sd	s0,112(sp)
ffffffffc020b4ee:	f862                	sd	s8,48(sp)
ffffffffc020b4f0:	f06a                	sd	s10,32(sp)
ffffffffc020b4f2:	ec6e                	sd	s11,24(sp)
ffffffffc020b4f4:	84aa                	mv	s1,a0
ffffffffc020b4f6:	8cb6                	mv	s9,a3
ffffffffc020b4f8:	8aba                	mv	s5,a4
ffffffffc020b4fa:	89ae                	mv	s3,a1
ffffffffc020b4fc:	8932                	mv	s2,a2
ffffffffc020b4fe:	02500a13          	li	s4,37
ffffffffc020b502:	05500b93          	li	s7,85
ffffffffc020b506:	00004b17          	auipc	s6,0x4
ffffffffc020b50a:	48ab0b13          	addi	s6,s6,1162 # ffffffffc020f990 <sfs_node_dirops+0x80>
ffffffffc020b50e:	000cc503          	lbu	a0,0(s9)
ffffffffc020b512:	001c8413          	addi	s0,s9,1
ffffffffc020b516:	01450b63          	beq	a0,s4,ffffffffc020b52c <vprintfmt+0x54>
ffffffffc020b51a:	cd15                	beqz	a0,ffffffffc020b556 <vprintfmt+0x7e>
ffffffffc020b51c:	864e                	mv	a2,s3
ffffffffc020b51e:	85ca                	mv	a1,s2
ffffffffc020b520:	9482                	jalr	s1
ffffffffc020b522:	00044503          	lbu	a0,0(s0)
ffffffffc020b526:	0405                	addi	s0,s0,1
ffffffffc020b528:	ff4519e3          	bne	a0,s4,ffffffffc020b51a <vprintfmt+0x42>
ffffffffc020b52c:	5d7d                	li	s10,-1
ffffffffc020b52e:	8dea                	mv	s11,s10
ffffffffc020b530:	02000813          	li	a6,32
ffffffffc020b534:	4c01                	li	s8,0
ffffffffc020b536:	4581                	li	a1,0
ffffffffc020b538:	00044703          	lbu	a4,0(s0)
ffffffffc020b53c:	00140c93          	addi	s9,s0,1
ffffffffc020b540:	fdd7061b          	addiw	a2,a4,-35
ffffffffc020b544:	0ff67613          	zext.b	a2,a2
ffffffffc020b548:	02cbe663          	bltu	s7,a2,ffffffffc020b574 <vprintfmt+0x9c>
ffffffffc020b54c:	060a                	slli	a2,a2,0x2
ffffffffc020b54e:	965a                	add	a2,a2,s6
ffffffffc020b550:	421c                	lw	a5,0(a2)
ffffffffc020b552:	97da                	add	a5,a5,s6
ffffffffc020b554:	8782                	jr	a5
ffffffffc020b556:	70e6                	ld	ra,120(sp)
ffffffffc020b558:	7446                	ld	s0,112(sp)
ffffffffc020b55a:	74a6                	ld	s1,104(sp)
ffffffffc020b55c:	7906                	ld	s2,96(sp)
ffffffffc020b55e:	69e6                	ld	s3,88(sp)
ffffffffc020b560:	6a46                	ld	s4,80(sp)
ffffffffc020b562:	6aa6                	ld	s5,72(sp)
ffffffffc020b564:	6b06                	ld	s6,64(sp)
ffffffffc020b566:	7be2                	ld	s7,56(sp)
ffffffffc020b568:	7c42                	ld	s8,48(sp)
ffffffffc020b56a:	7ca2                	ld	s9,40(sp)
ffffffffc020b56c:	7d02                	ld	s10,32(sp)
ffffffffc020b56e:	6de2                	ld	s11,24(sp)
ffffffffc020b570:	6109                	addi	sp,sp,128
ffffffffc020b572:	8082                	ret
ffffffffc020b574:	864e                	mv	a2,s3
ffffffffc020b576:	85ca                	mv	a1,s2
ffffffffc020b578:	02500513          	li	a0,37
ffffffffc020b57c:	9482                	jalr	s1
ffffffffc020b57e:	fff44783          	lbu	a5,-1(s0)
ffffffffc020b582:	02500713          	li	a4,37
ffffffffc020b586:	8ca2                	mv	s9,s0
ffffffffc020b588:	f8e783e3          	beq	a5,a4,ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b58c:	ffecc783          	lbu	a5,-2(s9)
ffffffffc020b590:	1cfd                	addi	s9,s9,-1
ffffffffc020b592:	fee79de3          	bne	a5,a4,ffffffffc020b58c <vprintfmt+0xb4>
ffffffffc020b596:	bfa5                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b598:	00144683          	lbu	a3,1(s0)
ffffffffc020b59c:	4525                	li	a0,9
ffffffffc020b59e:	fd070d1b          	addiw	s10,a4,-48
ffffffffc020b5a2:	fd06879b          	addiw	a5,a3,-48
ffffffffc020b5a6:	28f56063          	bltu	a0,a5,ffffffffc020b826 <vprintfmt+0x34e>
ffffffffc020b5aa:	2681                	sext.w	a3,a3
ffffffffc020b5ac:	8466                	mv	s0,s9
ffffffffc020b5ae:	002d179b          	slliw	a5,s10,0x2
ffffffffc020b5b2:	00144703          	lbu	a4,1(s0)
ffffffffc020b5b6:	01a787bb          	addw	a5,a5,s10
ffffffffc020b5ba:	0017979b          	slliw	a5,a5,0x1
ffffffffc020b5be:	9fb5                	addw	a5,a5,a3
ffffffffc020b5c0:	fd07061b          	addiw	a2,a4,-48
ffffffffc020b5c4:	0405                	addi	s0,s0,1
ffffffffc020b5c6:	fd078d1b          	addiw	s10,a5,-48
ffffffffc020b5ca:	0007069b          	sext.w	a3,a4
ffffffffc020b5ce:	fec570e3          	bgeu	a0,a2,ffffffffc020b5ae <vprintfmt+0xd6>
ffffffffc020b5d2:	f60dd3e3          	bgez	s11,ffffffffc020b538 <vprintfmt+0x60>
ffffffffc020b5d6:	8dea                	mv	s11,s10
ffffffffc020b5d8:	5d7d                	li	s10,-1
ffffffffc020b5da:	bfb9                	j	ffffffffc020b538 <vprintfmt+0x60>
ffffffffc020b5dc:	883a                	mv	a6,a4
ffffffffc020b5de:	8466                	mv	s0,s9
ffffffffc020b5e0:	bfa1                	j	ffffffffc020b538 <vprintfmt+0x60>
ffffffffc020b5e2:	8466                	mv	s0,s9
ffffffffc020b5e4:	4c05                	li	s8,1
ffffffffc020b5e6:	bf89                	j	ffffffffc020b538 <vprintfmt+0x60>
ffffffffc020b5e8:	4785                	li	a5,1
ffffffffc020b5ea:	008a8613          	addi	a2,s5,8 # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc020b5ee:	00b7c463          	blt	a5,a1,ffffffffc020b5f6 <vprintfmt+0x11e>
ffffffffc020b5f2:	1c058363          	beqz	a1,ffffffffc020b7b8 <vprintfmt+0x2e0>
ffffffffc020b5f6:	000ab683          	ld	a3,0(s5)
ffffffffc020b5fa:	4741                	li	a4,16
ffffffffc020b5fc:	8ab2                	mv	s5,a2
ffffffffc020b5fe:	2801                	sext.w	a6,a6
ffffffffc020b600:	87ee                	mv	a5,s11
ffffffffc020b602:	864a                	mv	a2,s2
ffffffffc020b604:	85ce                	mv	a1,s3
ffffffffc020b606:	8526                	mv	a0,s1
ffffffffc020b608:	e47ff0ef          	jal	ffffffffc020b44e <printnum>
ffffffffc020b60c:	b709                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b60e:	000aa503          	lw	a0,0(s5)
ffffffffc020b612:	864e                	mv	a2,s3
ffffffffc020b614:	85ca                	mv	a1,s2
ffffffffc020b616:	9482                	jalr	s1
ffffffffc020b618:	0aa1                	addi	s5,s5,8
ffffffffc020b61a:	bdd5                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b61c:	4785                	li	a5,1
ffffffffc020b61e:	008a8613          	addi	a2,s5,8
ffffffffc020b622:	00b7c463          	blt	a5,a1,ffffffffc020b62a <vprintfmt+0x152>
ffffffffc020b626:	18058463          	beqz	a1,ffffffffc020b7ae <vprintfmt+0x2d6>
ffffffffc020b62a:	000ab683          	ld	a3,0(s5)
ffffffffc020b62e:	4729                	li	a4,10
ffffffffc020b630:	8ab2                	mv	s5,a2
ffffffffc020b632:	b7f1                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b634:	864e                	mv	a2,s3
ffffffffc020b636:	85ca                	mv	a1,s2
ffffffffc020b638:	03000513          	li	a0,48
ffffffffc020b63c:	e042                	sd	a6,0(sp)
ffffffffc020b63e:	9482                	jalr	s1
ffffffffc020b640:	864e                	mv	a2,s3
ffffffffc020b642:	85ca                	mv	a1,s2
ffffffffc020b644:	07800513          	li	a0,120
ffffffffc020b648:	9482                	jalr	s1
ffffffffc020b64a:	000ab683          	ld	a3,0(s5)
ffffffffc020b64e:	6802                	ld	a6,0(sp)
ffffffffc020b650:	4741                	li	a4,16
ffffffffc020b652:	0aa1                	addi	s5,s5,8
ffffffffc020b654:	b76d                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b656:	864e                	mv	a2,s3
ffffffffc020b658:	85ca                	mv	a1,s2
ffffffffc020b65a:	02500513          	li	a0,37
ffffffffc020b65e:	9482                	jalr	s1
ffffffffc020b660:	b57d                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b662:	000aad03          	lw	s10,0(s5)
ffffffffc020b666:	8466                	mv	s0,s9
ffffffffc020b668:	0aa1                	addi	s5,s5,8
ffffffffc020b66a:	b7a5                	j	ffffffffc020b5d2 <vprintfmt+0xfa>
ffffffffc020b66c:	4785                	li	a5,1
ffffffffc020b66e:	008a8613          	addi	a2,s5,8
ffffffffc020b672:	00b7c463          	blt	a5,a1,ffffffffc020b67a <vprintfmt+0x1a2>
ffffffffc020b676:	12058763          	beqz	a1,ffffffffc020b7a4 <vprintfmt+0x2cc>
ffffffffc020b67a:	000ab683          	ld	a3,0(s5)
ffffffffc020b67e:	4721                	li	a4,8
ffffffffc020b680:	8ab2                	mv	s5,a2
ffffffffc020b682:	bfb5                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b684:	87ee                	mv	a5,s11
ffffffffc020b686:	000dd363          	bgez	s11,ffffffffc020b68c <vprintfmt+0x1b4>
ffffffffc020b68a:	4781                	li	a5,0
ffffffffc020b68c:	00078d9b          	sext.w	s11,a5
ffffffffc020b690:	8466                	mv	s0,s9
ffffffffc020b692:	b55d                	j	ffffffffc020b538 <vprintfmt+0x60>
ffffffffc020b694:	0008041b          	sext.w	s0,a6
ffffffffc020b698:	fd340793          	addi	a5,s0,-45
ffffffffc020b69c:	01b02733          	sgtz	a4,s11
ffffffffc020b6a0:	00f037b3          	snez	a5,a5
ffffffffc020b6a4:	8ff9                	and	a5,a5,a4
ffffffffc020b6a6:	000ab703          	ld	a4,0(s5)
ffffffffc020b6aa:	008a8693          	addi	a3,s5,8
ffffffffc020b6ae:	e436                	sd	a3,8(sp)
ffffffffc020b6b0:	12070563          	beqz	a4,ffffffffc020b7da <vprintfmt+0x302>
ffffffffc020b6b4:	12079d63          	bnez	a5,ffffffffc020b7ee <vprintfmt+0x316>
ffffffffc020b6b8:	00074783          	lbu	a5,0(a4)
ffffffffc020b6bc:	0007851b          	sext.w	a0,a5
ffffffffc020b6c0:	c78d                	beqz	a5,ffffffffc020b6ea <vprintfmt+0x212>
ffffffffc020b6c2:	00170a93          	addi	s5,a4,1
ffffffffc020b6c6:	547d                	li	s0,-1
ffffffffc020b6c8:	000d4563          	bltz	s10,ffffffffc020b6d2 <vprintfmt+0x1fa>
ffffffffc020b6cc:	3d7d                	addiw	s10,s10,-1
ffffffffc020b6ce:	008d0e63          	beq	s10,s0,ffffffffc020b6ea <vprintfmt+0x212>
ffffffffc020b6d2:	020c1863          	bnez	s8,ffffffffc020b702 <vprintfmt+0x22a>
ffffffffc020b6d6:	864e                	mv	a2,s3
ffffffffc020b6d8:	85ca                	mv	a1,s2
ffffffffc020b6da:	9482                	jalr	s1
ffffffffc020b6dc:	000ac783          	lbu	a5,0(s5)
ffffffffc020b6e0:	0a85                	addi	s5,s5,1
ffffffffc020b6e2:	3dfd                	addiw	s11,s11,-1
ffffffffc020b6e4:	0007851b          	sext.w	a0,a5
ffffffffc020b6e8:	f3e5                	bnez	a5,ffffffffc020b6c8 <vprintfmt+0x1f0>
ffffffffc020b6ea:	01b05a63          	blez	s11,ffffffffc020b6fe <vprintfmt+0x226>
ffffffffc020b6ee:	864e                	mv	a2,s3
ffffffffc020b6f0:	85ca                	mv	a1,s2
ffffffffc020b6f2:	02000513          	li	a0,32
ffffffffc020b6f6:	3dfd                	addiw	s11,s11,-1
ffffffffc020b6f8:	9482                	jalr	s1
ffffffffc020b6fa:	fe0d9ae3          	bnez	s11,ffffffffc020b6ee <vprintfmt+0x216>
ffffffffc020b6fe:	6aa2                	ld	s5,8(sp)
ffffffffc020b700:	b539                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b702:	3781                	addiw	a5,a5,-32
ffffffffc020b704:	05e00713          	li	a4,94
ffffffffc020b708:	fcf777e3          	bgeu	a4,a5,ffffffffc020b6d6 <vprintfmt+0x1fe>
ffffffffc020b70c:	03f00513          	li	a0,63
ffffffffc020b710:	864e                	mv	a2,s3
ffffffffc020b712:	85ca                	mv	a1,s2
ffffffffc020b714:	9482                	jalr	s1
ffffffffc020b716:	000ac783          	lbu	a5,0(s5)
ffffffffc020b71a:	0a85                	addi	s5,s5,1
ffffffffc020b71c:	3dfd                	addiw	s11,s11,-1
ffffffffc020b71e:	0007851b          	sext.w	a0,a5
ffffffffc020b722:	d7e1                	beqz	a5,ffffffffc020b6ea <vprintfmt+0x212>
ffffffffc020b724:	fa0d54e3          	bgez	s10,ffffffffc020b6cc <vprintfmt+0x1f4>
ffffffffc020b728:	bfe9                	j	ffffffffc020b702 <vprintfmt+0x22a>
ffffffffc020b72a:	000aa783          	lw	a5,0(s5)
ffffffffc020b72e:	46e1                	li	a3,24
ffffffffc020b730:	0aa1                	addi	s5,s5,8
ffffffffc020b732:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020b736:	8fb9                	xor	a5,a5,a4
ffffffffc020b738:	40e7873b          	subw	a4,a5,a4
ffffffffc020b73c:	02e6c663          	blt	a3,a4,ffffffffc020b768 <vprintfmt+0x290>
ffffffffc020b740:	00004797          	auipc	a5,0x4
ffffffffc020b744:	3a878793          	addi	a5,a5,936 # ffffffffc020fae8 <error_string>
ffffffffc020b748:	00371693          	slli	a3,a4,0x3
ffffffffc020b74c:	97b6                	add	a5,a5,a3
ffffffffc020b74e:	639c                	ld	a5,0(a5)
ffffffffc020b750:	cf81                	beqz	a5,ffffffffc020b768 <vprintfmt+0x290>
ffffffffc020b752:	873e                	mv	a4,a5
ffffffffc020b754:	00000697          	auipc	a3,0x0
ffffffffc020b758:	1ac68693          	addi	a3,a3,428 # ffffffffc020b900 <etext+0x2a>
ffffffffc020b75c:	864a                	mv	a2,s2
ffffffffc020b75e:	85ce                	mv	a1,s3
ffffffffc020b760:	8526                	mv	a0,s1
ffffffffc020b762:	0f2000ef          	jal	ffffffffc020b854 <printfmt>
ffffffffc020b766:	b365                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b768:	00003697          	auipc	a3,0x3
ffffffffc020b76c:	5a068693          	addi	a3,a3,1440 # ffffffffc020ed08 <etext+0x3432>
ffffffffc020b770:	864a                	mv	a2,s2
ffffffffc020b772:	85ce                	mv	a1,s3
ffffffffc020b774:	8526                	mv	a0,s1
ffffffffc020b776:	0de000ef          	jal	ffffffffc020b854 <printfmt>
ffffffffc020b77a:	bb51                	j	ffffffffc020b50e <vprintfmt+0x36>
ffffffffc020b77c:	4785                	li	a5,1
ffffffffc020b77e:	008a8c13          	addi	s8,s5,8
ffffffffc020b782:	00b7c363          	blt	a5,a1,ffffffffc020b788 <vprintfmt+0x2b0>
ffffffffc020b786:	cd81                	beqz	a1,ffffffffc020b79e <vprintfmt+0x2c6>
ffffffffc020b788:	000ab403          	ld	s0,0(s5)
ffffffffc020b78c:	02044b63          	bltz	s0,ffffffffc020b7c2 <vprintfmt+0x2ea>
ffffffffc020b790:	86a2                	mv	a3,s0
ffffffffc020b792:	8ae2                	mv	s5,s8
ffffffffc020b794:	4729                	li	a4,10
ffffffffc020b796:	b5a5                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b798:	2585                	addiw	a1,a1,1
ffffffffc020b79a:	8466                	mv	s0,s9
ffffffffc020b79c:	bb71                	j	ffffffffc020b538 <vprintfmt+0x60>
ffffffffc020b79e:	000aa403          	lw	s0,0(s5)
ffffffffc020b7a2:	b7ed                	j	ffffffffc020b78c <vprintfmt+0x2b4>
ffffffffc020b7a4:	000ae683          	lwu	a3,0(s5)
ffffffffc020b7a8:	4721                	li	a4,8
ffffffffc020b7aa:	8ab2                	mv	s5,a2
ffffffffc020b7ac:	bd89                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b7ae:	000ae683          	lwu	a3,0(s5)
ffffffffc020b7b2:	4729                	li	a4,10
ffffffffc020b7b4:	8ab2                	mv	s5,a2
ffffffffc020b7b6:	b5a1                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b7b8:	000ae683          	lwu	a3,0(s5)
ffffffffc020b7bc:	4741                	li	a4,16
ffffffffc020b7be:	8ab2                	mv	s5,a2
ffffffffc020b7c0:	bd3d                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b7c2:	864e                	mv	a2,s3
ffffffffc020b7c4:	85ca                	mv	a1,s2
ffffffffc020b7c6:	02d00513          	li	a0,45
ffffffffc020b7ca:	e042                	sd	a6,0(sp)
ffffffffc020b7cc:	9482                	jalr	s1
ffffffffc020b7ce:	6802                	ld	a6,0(sp)
ffffffffc020b7d0:	408006b3          	neg	a3,s0
ffffffffc020b7d4:	8ae2                	mv	s5,s8
ffffffffc020b7d6:	4729                	li	a4,10
ffffffffc020b7d8:	b51d                	j	ffffffffc020b5fe <vprintfmt+0x126>
ffffffffc020b7da:	eba1                	bnez	a5,ffffffffc020b82a <vprintfmt+0x352>
ffffffffc020b7dc:	02800793          	li	a5,40
ffffffffc020b7e0:	853e                	mv	a0,a5
ffffffffc020b7e2:	00003a97          	auipc	s5,0x3
ffffffffc020b7e6:	51fa8a93          	addi	s5,s5,1311 # ffffffffc020ed01 <etext+0x342b>
ffffffffc020b7ea:	547d                	li	s0,-1
ffffffffc020b7ec:	bdf1                	j	ffffffffc020b6c8 <vprintfmt+0x1f0>
ffffffffc020b7ee:	853a                	mv	a0,a4
ffffffffc020b7f0:	85ea                	mv	a1,s10
ffffffffc020b7f2:	e03a                	sd	a4,0(sp)
ffffffffc020b7f4:	b57ff0ef          	jal	ffffffffc020b34a <strnlen>
ffffffffc020b7f8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020b7fc:	6702                	ld	a4,0(sp)
ffffffffc020b7fe:	01b05b63          	blez	s11,ffffffffc020b814 <vprintfmt+0x33c>
ffffffffc020b802:	864e                	mv	a2,s3
ffffffffc020b804:	85ca                	mv	a1,s2
ffffffffc020b806:	8522                	mv	a0,s0
ffffffffc020b808:	e03a                	sd	a4,0(sp)
ffffffffc020b80a:	3dfd                	addiw	s11,s11,-1
ffffffffc020b80c:	9482                	jalr	s1
ffffffffc020b80e:	6702                	ld	a4,0(sp)
ffffffffc020b810:	fe0d99e3          	bnez	s11,ffffffffc020b802 <vprintfmt+0x32a>
ffffffffc020b814:	00074783          	lbu	a5,0(a4)
ffffffffc020b818:	0007851b          	sext.w	a0,a5
ffffffffc020b81c:	ee0781e3          	beqz	a5,ffffffffc020b6fe <vprintfmt+0x226>
ffffffffc020b820:	00170a93          	addi	s5,a4,1
ffffffffc020b824:	b54d                	j	ffffffffc020b6c6 <vprintfmt+0x1ee>
ffffffffc020b826:	8466                	mv	s0,s9
ffffffffc020b828:	b36d                	j	ffffffffc020b5d2 <vprintfmt+0xfa>
ffffffffc020b82a:	85ea                	mv	a1,s10
ffffffffc020b82c:	00003517          	auipc	a0,0x3
ffffffffc020b830:	4d450513          	addi	a0,a0,1236 # ffffffffc020ed00 <etext+0x342a>
ffffffffc020b834:	b17ff0ef          	jal	ffffffffc020b34a <strnlen>
ffffffffc020b838:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020b83c:	02800793          	li	a5,40
ffffffffc020b840:	00003717          	auipc	a4,0x3
ffffffffc020b844:	4c070713          	addi	a4,a4,1216 # ffffffffc020ed00 <etext+0x342a>
ffffffffc020b848:	853e                	mv	a0,a5
ffffffffc020b84a:	fbb04ce3          	bgtz	s11,ffffffffc020b802 <vprintfmt+0x32a>
ffffffffc020b84e:	00170a93          	addi	s5,a4,1
ffffffffc020b852:	bd95                	j	ffffffffc020b6c6 <vprintfmt+0x1ee>

ffffffffc020b854 <printfmt>:
ffffffffc020b854:	7139                	addi	sp,sp,-64
ffffffffc020b856:	02010313          	addi	t1,sp,32
ffffffffc020b85a:	f03a                	sd	a4,32(sp)
ffffffffc020b85c:	871a                	mv	a4,t1
ffffffffc020b85e:	ec06                	sd	ra,24(sp)
ffffffffc020b860:	f43e                	sd	a5,40(sp)
ffffffffc020b862:	f842                	sd	a6,48(sp)
ffffffffc020b864:	fc46                	sd	a7,56(sp)
ffffffffc020b866:	e41a                	sd	t1,8(sp)
ffffffffc020b868:	c71ff0ef          	jal	ffffffffc020b4d8 <vprintfmt>
ffffffffc020b86c:	60e2                	ld	ra,24(sp)
ffffffffc020b86e:	6121                	addi	sp,sp,64
ffffffffc020b870:	8082                	ret

ffffffffc020b872 <snprintf>:
ffffffffc020b872:	711d                	addi	sp,sp,-96
ffffffffc020b874:	15fd                	addi	a1,a1,-1
ffffffffc020b876:	95aa                	add	a1,a1,a0
ffffffffc020b878:	03810313          	addi	t1,sp,56
ffffffffc020b87c:	f406                	sd	ra,40(sp)
ffffffffc020b87e:	e82e                	sd	a1,16(sp)
ffffffffc020b880:	e42a                	sd	a0,8(sp)
ffffffffc020b882:	fc36                	sd	a3,56(sp)
ffffffffc020b884:	e0ba                	sd	a4,64(sp)
ffffffffc020b886:	e4be                	sd	a5,72(sp)
ffffffffc020b888:	e8c2                	sd	a6,80(sp)
ffffffffc020b88a:	ecc6                	sd	a7,88(sp)
ffffffffc020b88c:	cc02                	sw	zero,24(sp)
ffffffffc020b88e:	e01a                	sd	t1,0(sp)
ffffffffc020b890:	c515                	beqz	a0,ffffffffc020b8bc <snprintf+0x4a>
ffffffffc020b892:	02a5e563          	bltu	a1,a0,ffffffffc020b8bc <snprintf+0x4a>
ffffffffc020b896:	75dd                	lui	a1,0xffff7
ffffffffc020b898:	86b2                	mv	a3,a2
ffffffffc020b89a:	00000517          	auipc	a0,0x0
ffffffffc020b89e:	c2450513          	addi	a0,a0,-988 # ffffffffc020b4be <sprintputch>
ffffffffc020b8a2:	871a                	mv	a4,t1
ffffffffc020b8a4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020b8a8:	0030                	addi	a2,sp,8
ffffffffc020b8aa:	c2fff0ef          	jal	ffffffffc020b4d8 <vprintfmt>
ffffffffc020b8ae:	67a2                	ld	a5,8(sp)
ffffffffc020b8b0:	00078023          	sb	zero,0(a5)
ffffffffc020b8b4:	4562                	lw	a0,24(sp)
ffffffffc020b8b6:	70a2                	ld	ra,40(sp)
ffffffffc020b8b8:	6125                	addi	sp,sp,96
ffffffffc020b8ba:	8082                	ret
ffffffffc020b8bc:	5575                	li	a0,-3
ffffffffc020b8be:	bfe5                	j	ffffffffc020b8b6 <snprintf+0x44>

ffffffffc020b8c0 <hash32>:
ffffffffc020b8c0:	9e3707b7          	lui	a5,0x9e370
ffffffffc020b8c4:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_bin_sfs_img_size+0xffffffff9e2fad01>
ffffffffc020b8c6:	02a787bb          	mulw	a5,a5,a0
ffffffffc020b8ca:	02000513          	li	a0,32
ffffffffc020b8ce:	9d0d                	subw	a0,a0,a1
ffffffffc020b8d0:	00a7d53b          	srlw	a0,a5,a0
ffffffffc020b8d4:	8082                	ret
