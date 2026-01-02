
obj/__user_badsegment.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	67250513          	addi	a0,a0,1650 # 8006a0 <main+0x1e>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	128000ef          	jal	80016c <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0fa000ef          	jal	800146 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	67050513          	addi	a0,a0,1648 # 8006c0 <main+0x3e>
  800058:	114000ef          	jal	80016c <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0aa000ef          	jal	800108 <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00000517          	auipc	a0,0x0
  800074:	65850513          	addi	a0,a0,1624 # 8006c8 <main+0x46>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	0e6000ef          	jal	80016c <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0b8000ef          	jal	800146 <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	62e50513          	addi	a0,a0,1582 # 8006c0 <main+0x3e>
  80009a:	0d2000ef          	jal	80016c <cprintf>
  80009e:	60e2                	ld	ra,24(sp)
  8000a0:	6442                	ld	s0,16(sp)
  8000a2:	6161                	addi	sp,sp,80
  8000a4:	8082                	ret

00000000008000a6 <syscall>:
  8000a6:	7175                	addi	sp,sp,-144
  8000a8:	08010313          	addi	t1,sp,128
  8000ac:	e42a                	sd	a0,8(sp)
  8000ae:	ecae                	sd	a1,88(sp)
  8000b0:	f42e                	sd	a1,40(sp)
  8000b2:	f0b2                	sd	a2,96(sp)
  8000b4:	f832                	sd	a2,48(sp)
  8000b6:	f4b6                	sd	a3,104(sp)
  8000b8:	fc36                	sd	a3,56(sp)
  8000ba:	f8ba                	sd	a4,112(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	fcbe                	sd	a5,120(sp)
  8000c0:	e4be                	sd	a5,72(sp)
  8000c2:	e142                	sd	a6,128(sp)
  8000c4:	e546                	sd	a7,136(sp)
  8000c6:	f01a                	sd	t1,32(sp)
  8000c8:	4522                	lw	a0,8(sp)
  8000ca:	55a2                	lw	a1,40(sp)
  8000cc:	5642                	lw	a2,48(sp)
  8000ce:	56e2                	lw	a3,56(sp)
  8000d0:	4706                	lw	a4,64(sp)
  8000d2:	47a6                	lw	a5,72(sp)
  8000d4:	00000073          	ecall
  8000d8:	ce2a                	sw	a0,28(sp)
  8000da:	4572                	lw	a0,28(sp)
  8000dc:	6149                	addi	sp,sp,144
  8000de:	8082                	ret

00000000008000e0 <sys_exit>:
  8000e0:	85aa                	mv	a1,a0
  8000e2:	4505                	li	a0,1
  8000e4:	b7c9                	j	8000a6 <syscall>

00000000008000e6 <sys_putc>:
  8000e6:	85aa                	mv	a1,a0
  8000e8:	4579                	li	a0,30
  8000ea:	bf75                	j	8000a6 <syscall>

00000000008000ec <sys_open>:
  8000ec:	862e                	mv	a2,a1
  8000ee:	85aa                	mv	a1,a0
  8000f0:	06400513          	li	a0,100
  8000f4:	bf4d                	j	8000a6 <syscall>

00000000008000f6 <sys_close>:
  8000f6:	85aa                	mv	a1,a0
  8000f8:	06500513          	li	a0,101
  8000fc:	b76d                	j	8000a6 <syscall>

00000000008000fe <sys_dup>:
  8000fe:	862e                	mv	a2,a1
  800100:	85aa                	mv	a1,a0
  800102:	08200513          	li	a0,130
  800106:	b745                	j	8000a6 <syscall>

0000000000800108 <exit>:
  800108:	1141                	addi	sp,sp,-16
  80010a:	e406                	sd	ra,8(sp)
  80010c:	fd5ff0ef          	jal	8000e0 <sys_exit>
  800110:	00000517          	auipc	a0,0x0
  800114:	5d850513          	addi	a0,a0,1496 # 8006e8 <main+0x66>
  800118:	054000ef          	jal	80016c <cprintf>
  80011c:	a001                	j	80011c <exit+0x14>

000000000080011e <_start>:
  80011e:	0ca000ef          	jal	8001e8 <umain>
  800122:	a001                	j	800122 <_start+0x4>

0000000000800124 <open>:
  800124:	1582                	slli	a1,a1,0x20
  800126:	9181                	srli	a1,a1,0x20
  800128:	b7d1                	j	8000ec <sys_open>

000000000080012a <close>:
  80012a:	b7f1                	j	8000f6 <sys_close>

000000000080012c <dup2>:
  80012c:	bfc9                	j	8000fe <sys_dup>

000000000080012e <cputch>:
  80012e:	1101                	addi	sp,sp,-32
  800130:	ec06                	sd	ra,24(sp)
  800132:	e42e                	sd	a1,8(sp)
  800134:	fb3ff0ef          	jal	8000e6 <sys_putc>
  800138:	65a2                	ld	a1,8(sp)
  80013a:	60e2                	ld	ra,24(sp)
  80013c:	419c                	lw	a5,0(a1)
  80013e:	2785                	addiw	a5,a5,1
  800140:	c19c                	sw	a5,0(a1)
  800142:	6105                	addi	sp,sp,32
  800144:	8082                	ret

0000000000800146 <vcprintf>:
  800146:	1101                	addi	sp,sp,-32
  800148:	872e                	mv	a4,a1
  80014a:	75dd                	lui	a1,0xffff7
  80014c:	86aa                	mv	a3,a0
  80014e:	0070                	addi	a2,sp,12
  800150:	00000517          	auipc	a0,0x0
  800154:	fde50513          	addi	a0,a0,-34 # 80012e <cputch>
  800158:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5fe1>
  80015c:	ec06                	sd	ra,24(sp)
  80015e:	c602                	sw	zero,12(sp)
  800160:	188000ef          	jal	8002e8 <vprintfmt>
  800164:	60e2                	ld	ra,24(sp)
  800166:	4532                	lw	a0,12(sp)
  800168:	6105                	addi	sp,sp,32
  80016a:	8082                	ret

000000000080016c <cprintf>:
  80016c:	711d                	addi	sp,sp,-96
  80016e:	02810313          	addi	t1,sp,40
  800172:	f42e                	sd	a1,40(sp)
  800174:	75dd                	lui	a1,0xffff7
  800176:	f832                	sd	a2,48(sp)
  800178:	fc36                	sd	a3,56(sp)
  80017a:	e0ba                	sd	a4,64(sp)
  80017c:	86aa                	mv	a3,a0
  80017e:	0050                	addi	a2,sp,4
  800180:	00000517          	auipc	a0,0x0
  800184:	fae50513          	addi	a0,a0,-82 # 80012e <cputch>
  800188:	871a                	mv	a4,t1
  80018a:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5fe1>
  80018e:	ec06                	sd	ra,24(sp)
  800190:	e4be                	sd	a5,72(sp)
  800192:	e8c2                	sd	a6,80(sp)
  800194:	ecc6                	sd	a7,88(sp)
  800196:	c202                	sw	zero,4(sp)
  800198:	e41a                	sd	t1,8(sp)
  80019a:	14e000ef          	jal	8002e8 <vprintfmt>
  80019e:	60e2                	ld	ra,24(sp)
  8001a0:	4512                	lw	a0,4(sp)
  8001a2:	6125                	addi	sp,sp,96
  8001a4:	8082                	ret

00000000008001a6 <initfd>:
  8001a6:	87ae                	mv	a5,a1
  8001a8:	1101                	addi	sp,sp,-32
  8001aa:	e822                	sd	s0,16(sp)
  8001ac:	85b2                	mv	a1,a2
  8001ae:	842a                	mv	s0,a0
  8001b0:	853e                	mv	a0,a5
  8001b2:	ec06                	sd	ra,24(sp)
  8001b4:	f71ff0ef          	jal	800124 <open>
  8001b8:	87aa                	mv	a5,a0
  8001ba:	00054463          	bltz	a0,8001c2 <initfd+0x1c>
  8001be:	00851763          	bne	a0,s0,8001cc <initfd+0x26>
  8001c2:	60e2                	ld	ra,24(sp)
  8001c4:	6442                	ld	s0,16(sp)
  8001c6:	853e                	mv	a0,a5
  8001c8:	6105                	addi	sp,sp,32
  8001ca:	8082                	ret
  8001cc:	e42a                	sd	a0,8(sp)
  8001ce:	8522                	mv	a0,s0
  8001d0:	f5bff0ef          	jal	80012a <close>
  8001d4:	6522                	ld	a0,8(sp)
  8001d6:	85a2                	mv	a1,s0
  8001d8:	f55ff0ef          	jal	80012c <dup2>
  8001dc:	842a                	mv	s0,a0
  8001de:	6522                	ld	a0,8(sp)
  8001e0:	f4bff0ef          	jal	80012a <close>
  8001e4:	87a2                	mv	a5,s0
  8001e6:	bff1                	j	8001c2 <initfd+0x1c>

00000000008001e8 <umain>:
  8001e8:	1101                	addi	sp,sp,-32
  8001ea:	e822                	sd	s0,16(sp)
  8001ec:	e426                	sd	s1,8(sp)
  8001ee:	842a                	mv	s0,a0
  8001f0:	84ae                	mv	s1,a1
  8001f2:	4601                	li	a2,0
  8001f4:	00000597          	auipc	a1,0x0
  8001f8:	50c58593          	addi	a1,a1,1292 # 800700 <main+0x7e>
  8001fc:	4501                	li	a0,0
  8001fe:	ec06                	sd	ra,24(sp)
  800200:	fa7ff0ef          	jal	8001a6 <initfd>
  800204:	02054263          	bltz	a0,800228 <umain+0x40>
  800208:	4605                	li	a2,1
  80020a:	8532                	mv	a0,a2
  80020c:	00000597          	auipc	a1,0x0
  800210:	53458593          	addi	a1,a1,1332 # 800740 <main+0xbe>
  800214:	f93ff0ef          	jal	8001a6 <initfd>
  800218:	02054563          	bltz	a0,800242 <umain+0x5a>
  80021c:	85a6                	mv	a1,s1
  80021e:	8522                	mv	a0,s0
  800220:	462000ef          	jal	800682 <main>
  800224:	ee5ff0ef          	jal	800108 <exit>
  800228:	86aa                	mv	a3,a0
  80022a:	00000617          	auipc	a2,0x0
  80022e:	4de60613          	addi	a2,a2,1246 # 800708 <main+0x86>
  800232:	45e9                	li	a1,26
  800234:	00000517          	auipc	a0,0x0
  800238:	4f450513          	addi	a0,a0,1268 # 800728 <main+0xa6>
  80023c:	e27ff0ef          	jal	800062 <__warn>
  800240:	b7e1                	j	800208 <umain+0x20>
  800242:	86aa                	mv	a3,a0
  800244:	00000617          	auipc	a2,0x0
  800248:	50460613          	addi	a2,a2,1284 # 800748 <main+0xc6>
  80024c:	45f5                	li	a1,29
  80024e:	00000517          	auipc	a0,0x0
  800252:	4da50513          	addi	a0,a0,1242 # 800728 <main+0xa6>
  800256:	e0dff0ef          	jal	800062 <__warn>
  80025a:	b7c9                	j	80021c <umain+0x34>

000000000080025c <strnlen>:
  80025c:	4781                	li	a5,0
  80025e:	e589                	bnez	a1,800268 <strnlen+0xc>
  800260:	a811                	j	800274 <strnlen+0x18>
  800262:	0785                	addi	a5,a5,1
  800264:	00f58863          	beq	a1,a5,800274 <strnlen+0x18>
  800268:	00f50733          	add	a4,a0,a5
  80026c:	00074703          	lbu	a4,0(a4)
  800270:	fb6d                	bnez	a4,800262 <strnlen+0x6>
  800272:	85be                	mv	a1,a5
  800274:	852e                	mv	a0,a1
  800276:	8082                	ret

0000000000800278 <printnum>:
  800278:	7139                	addi	sp,sp,-64
  80027a:	02071893          	slli	a7,a4,0x20
  80027e:	f822                	sd	s0,48(sp)
  800280:	f426                	sd	s1,40(sp)
  800282:	f04a                	sd	s2,32(sp)
  800284:	ec4e                	sd	s3,24(sp)
  800286:	e456                	sd	s5,8(sp)
  800288:	0208d893          	srli	a7,a7,0x20
  80028c:	fc06                	sd	ra,56(sp)
  80028e:	0316fab3          	remu	s5,a3,a7
  800292:	fff7841b          	addiw	s0,a5,-1
  800296:	84aa                	mv	s1,a0
  800298:	89ae                	mv	s3,a1
  80029a:	8932                	mv	s2,a2
  80029c:	0516f063          	bgeu	a3,a7,8002dc <printnum+0x64>
  8002a0:	e852                	sd	s4,16(sp)
  8002a2:	4705                	li	a4,1
  8002a4:	8a42                	mv	s4,a6
  8002a6:	00f75863          	bge	a4,a5,8002b6 <printnum+0x3e>
  8002aa:	864e                	mv	a2,s3
  8002ac:	85ca                	mv	a1,s2
  8002ae:	8552                	mv	a0,s4
  8002b0:	347d                	addiw	s0,s0,-1
  8002b2:	9482                	jalr	s1
  8002b4:	f87d                	bnez	s0,8002aa <printnum+0x32>
  8002b6:	6a42                	ld	s4,16(sp)
  8002b8:	00000797          	auipc	a5,0x0
  8002bc:	4b078793          	addi	a5,a5,1200 # 800768 <main+0xe6>
  8002c0:	97d6                	add	a5,a5,s5
  8002c2:	7442                	ld	s0,48(sp)
  8002c4:	0007c503          	lbu	a0,0(a5)
  8002c8:	70e2                	ld	ra,56(sp)
  8002ca:	6aa2                	ld	s5,8(sp)
  8002cc:	864e                	mv	a2,s3
  8002ce:	85ca                	mv	a1,s2
  8002d0:	69e2                	ld	s3,24(sp)
  8002d2:	7902                	ld	s2,32(sp)
  8002d4:	87a6                	mv	a5,s1
  8002d6:	74a2                	ld	s1,40(sp)
  8002d8:	6121                	addi	sp,sp,64
  8002da:	8782                	jr	a5
  8002dc:	0316d6b3          	divu	a3,a3,a7
  8002e0:	87a2                	mv	a5,s0
  8002e2:	f97ff0ef          	jal	800278 <printnum>
  8002e6:	bfc9                	j	8002b8 <printnum+0x40>

00000000008002e8 <vprintfmt>:
  8002e8:	7119                	addi	sp,sp,-128
  8002ea:	f4a6                	sd	s1,104(sp)
  8002ec:	f0ca                	sd	s2,96(sp)
  8002ee:	ecce                	sd	s3,88(sp)
  8002f0:	e8d2                	sd	s4,80(sp)
  8002f2:	e4d6                	sd	s5,72(sp)
  8002f4:	e0da                	sd	s6,64(sp)
  8002f6:	fc5e                	sd	s7,56(sp)
  8002f8:	f466                	sd	s9,40(sp)
  8002fa:	fc86                	sd	ra,120(sp)
  8002fc:	f8a2                	sd	s0,112(sp)
  8002fe:	f862                	sd	s8,48(sp)
  800300:	f06a                	sd	s10,32(sp)
  800302:	ec6e                	sd	s11,24(sp)
  800304:	84aa                	mv	s1,a0
  800306:	8cb6                	mv	s9,a3
  800308:	8aba                	mv	s5,a4
  80030a:	89ae                	mv	s3,a1
  80030c:	8932                	mv	s2,a2
  80030e:	02500a13          	li	s4,37
  800312:	05500b93          	li	s7,85
  800316:	00000b17          	auipc	s6,0x0
  80031a:	686b0b13          	addi	s6,s6,1670 # 80099c <main+0x31a>
  80031e:	000cc503          	lbu	a0,0(s9)
  800322:	001c8413          	addi	s0,s9,1
  800326:	01450b63          	beq	a0,s4,80033c <vprintfmt+0x54>
  80032a:	cd15                	beqz	a0,800366 <vprintfmt+0x7e>
  80032c:	864e                	mv	a2,s3
  80032e:	85ca                	mv	a1,s2
  800330:	9482                	jalr	s1
  800332:	00044503          	lbu	a0,0(s0)
  800336:	0405                	addi	s0,s0,1
  800338:	ff4519e3          	bne	a0,s4,80032a <vprintfmt+0x42>
  80033c:	5d7d                	li	s10,-1
  80033e:	8dea                	mv	s11,s10
  800340:	02000813          	li	a6,32
  800344:	4c01                	li	s8,0
  800346:	4581                	li	a1,0
  800348:	00044703          	lbu	a4,0(s0)
  80034c:	00140c93          	addi	s9,s0,1
  800350:	fdd7061b          	addiw	a2,a4,-35
  800354:	0ff67613          	zext.b	a2,a2
  800358:	02cbe663          	bltu	s7,a2,800384 <vprintfmt+0x9c>
  80035c:	060a                	slli	a2,a2,0x2
  80035e:	965a                	add	a2,a2,s6
  800360:	421c                	lw	a5,0(a2)
  800362:	97da                	add	a5,a5,s6
  800364:	8782                	jr	a5
  800366:	70e6                	ld	ra,120(sp)
  800368:	7446                	ld	s0,112(sp)
  80036a:	74a6                	ld	s1,104(sp)
  80036c:	7906                	ld	s2,96(sp)
  80036e:	69e6                	ld	s3,88(sp)
  800370:	6a46                	ld	s4,80(sp)
  800372:	6aa6                	ld	s5,72(sp)
  800374:	6b06                	ld	s6,64(sp)
  800376:	7be2                	ld	s7,56(sp)
  800378:	7c42                	ld	s8,48(sp)
  80037a:	7ca2                	ld	s9,40(sp)
  80037c:	7d02                	ld	s10,32(sp)
  80037e:	6de2                	ld	s11,24(sp)
  800380:	6109                	addi	sp,sp,128
  800382:	8082                	ret
  800384:	864e                	mv	a2,s3
  800386:	85ca                	mv	a1,s2
  800388:	02500513          	li	a0,37
  80038c:	9482                	jalr	s1
  80038e:	fff44783          	lbu	a5,-1(s0)
  800392:	02500713          	li	a4,37
  800396:	8ca2                	mv	s9,s0
  800398:	f8e783e3          	beq	a5,a4,80031e <vprintfmt+0x36>
  80039c:	ffecc783          	lbu	a5,-2(s9)
  8003a0:	1cfd                	addi	s9,s9,-1
  8003a2:	fee79de3          	bne	a5,a4,80039c <vprintfmt+0xb4>
  8003a6:	bfa5                	j	80031e <vprintfmt+0x36>
  8003a8:	00144683          	lbu	a3,1(s0)
  8003ac:	4525                	li	a0,9
  8003ae:	fd070d1b          	addiw	s10,a4,-48
  8003b2:	fd06879b          	addiw	a5,a3,-48
  8003b6:	28f56063          	bltu	a0,a5,800636 <vprintfmt+0x34e>
  8003ba:	2681                	sext.w	a3,a3
  8003bc:	8466                	mv	s0,s9
  8003be:	002d179b          	slliw	a5,s10,0x2
  8003c2:	00144703          	lbu	a4,1(s0)
  8003c6:	01a787bb          	addw	a5,a5,s10
  8003ca:	0017979b          	slliw	a5,a5,0x1
  8003ce:	9fb5                	addw	a5,a5,a3
  8003d0:	fd07061b          	addiw	a2,a4,-48
  8003d4:	0405                	addi	s0,s0,1
  8003d6:	fd078d1b          	addiw	s10,a5,-48
  8003da:	0007069b          	sext.w	a3,a4
  8003de:	fec570e3          	bgeu	a0,a2,8003be <vprintfmt+0xd6>
  8003e2:	f60dd3e3          	bgez	s11,800348 <vprintfmt+0x60>
  8003e6:	8dea                	mv	s11,s10
  8003e8:	5d7d                	li	s10,-1
  8003ea:	bfb9                	j	800348 <vprintfmt+0x60>
  8003ec:	883a                	mv	a6,a4
  8003ee:	8466                	mv	s0,s9
  8003f0:	bfa1                	j	800348 <vprintfmt+0x60>
  8003f2:	8466                	mv	s0,s9
  8003f4:	4c05                	li	s8,1
  8003f6:	bf89                	j	800348 <vprintfmt+0x60>
  8003f8:	4785                	li	a5,1
  8003fa:	008a8613          	addi	a2,s5,8
  8003fe:	00b7c463          	blt	a5,a1,800406 <vprintfmt+0x11e>
  800402:	1c058363          	beqz	a1,8005c8 <vprintfmt+0x2e0>
  800406:	000ab683          	ld	a3,0(s5)
  80040a:	4741                	li	a4,16
  80040c:	8ab2                	mv	s5,a2
  80040e:	2801                	sext.w	a6,a6
  800410:	87ee                	mv	a5,s11
  800412:	864a                	mv	a2,s2
  800414:	85ce                	mv	a1,s3
  800416:	8526                	mv	a0,s1
  800418:	e61ff0ef          	jal	800278 <printnum>
  80041c:	b709                	j	80031e <vprintfmt+0x36>
  80041e:	000aa503          	lw	a0,0(s5)
  800422:	864e                	mv	a2,s3
  800424:	85ca                	mv	a1,s2
  800426:	9482                	jalr	s1
  800428:	0aa1                	addi	s5,s5,8
  80042a:	bdd5                	j	80031e <vprintfmt+0x36>
  80042c:	4785                	li	a5,1
  80042e:	008a8613          	addi	a2,s5,8
  800432:	00b7c463          	blt	a5,a1,80043a <vprintfmt+0x152>
  800436:	18058463          	beqz	a1,8005be <vprintfmt+0x2d6>
  80043a:	000ab683          	ld	a3,0(s5)
  80043e:	4729                	li	a4,10
  800440:	8ab2                	mv	s5,a2
  800442:	b7f1                	j	80040e <vprintfmt+0x126>
  800444:	864e                	mv	a2,s3
  800446:	85ca                	mv	a1,s2
  800448:	03000513          	li	a0,48
  80044c:	e042                	sd	a6,0(sp)
  80044e:	9482                	jalr	s1
  800450:	864e                	mv	a2,s3
  800452:	85ca                	mv	a1,s2
  800454:	07800513          	li	a0,120
  800458:	9482                	jalr	s1
  80045a:	000ab683          	ld	a3,0(s5)
  80045e:	6802                	ld	a6,0(sp)
  800460:	4741                	li	a4,16
  800462:	0aa1                	addi	s5,s5,8
  800464:	b76d                	j	80040e <vprintfmt+0x126>
  800466:	864e                	mv	a2,s3
  800468:	85ca                	mv	a1,s2
  80046a:	02500513          	li	a0,37
  80046e:	9482                	jalr	s1
  800470:	b57d                	j	80031e <vprintfmt+0x36>
  800472:	000aad03          	lw	s10,0(s5)
  800476:	8466                	mv	s0,s9
  800478:	0aa1                	addi	s5,s5,8
  80047a:	b7a5                	j	8003e2 <vprintfmt+0xfa>
  80047c:	4785                	li	a5,1
  80047e:	008a8613          	addi	a2,s5,8
  800482:	00b7c463          	blt	a5,a1,80048a <vprintfmt+0x1a2>
  800486:	12058763          	beqz	a1,8005b4 <vprintfmt+0x2cc>
  80048a:	000ab683          	ld	a3,0(s5)
  80048e:	4721                	li	a4,8
  800490:	8ab2                	mv	s5,a2
  800492:	bfb5                	j	80040e <vprintfmt+0x126>
  800494:	87ee                	mv	a5,s11
  800496:	000dd363          	bgez	s11,80049c <vprintfmt+0x1b4>
  80049a:	4781                	li	a5,0
  80049c:	00078d9b          	sext.w	s11,a5
  8004a0:	8466                	mv	s0,s9
  8004a2:	b55d                	j	800348 <vprintfmt+0x60>
  8004a4:	0008041b          	sext.w	s0,a6
  8004a8:	fd340793          	addi	a5,s0,-45
  8004ac:	01b02733          	sgtz	a4,s11
  8004b0:	00f037b3          	snez	a5,a5
  8004b4:	8ff9                	and	a5,a5,a4
  8004b6:	000ab703          	ld	a4,0(s5)
  8004ba:	008a8693          	addi	a3,s5,8
  8004be:	e436                	sd	a3,8(sp)
  8004c0:	12070563          	beqz	a4,8005ea <vprintfmt+0x302>
  8004c4:	12079d63          	bnez	a5,8005fe <vprintfmt+0x316>
  8004c8:	00074783          	lbu	a5,0(a4)
  8004cc:	0007851b          	sext.w	a0,a5
  8004d0:	c78d                	beqz	a5,8004fa <vprintfmt+0x212>
  8004d2:	00170a93          	addi	s5,a4,1
  8004d6:	547d                	li	s0,-1
  8004d8:	000d4563          	bltz	s10,8004e2 <vprintfmt+0x1fa>
  8004dc:	3d7d                	addiw	s10,s10,-1
  8004de:	008d0e63          	beq	s10,s0,8004fa <vprintfmt+0x212>
  8004e2:	020c1863          	bnez	s8,800512 <vprintfmt+0x22a>
  8004e6:	864e                	mv	a2,s3
  8004e8:	85ca                	mv	a1,s2
  8004ea:	9482                	jalr	s1
  8004ec:	000ac783          	lbu	a5,0(s5)
  8004f0:	0a85                	addi	s5,s5,1
  8004f2:	3dfd                	addiw	s11,s11,-1
  8004f4:	0007851b          	sext.w	a0,a5
  8004f8:	f3e5                	bnez	a5,8004d8 <vprintfmt+0x1f0>
  8004fa:	01b05a63          	blez	s11,80050e <vprintfmt+0x226>
  8004fe:	864e                	mv	a2,s3
  800500:	85ca                	mv	a1,s2
  800502:	02000513          	li	a0,32
  800506:	3dfd                	addiw	s11,s11,-1
  800508:	9482                	jalr	s1
  80050a:	fe0d9ae3          	bnez	s11,8004fe <vprintfmt+0x216>
  80050e:	6aa2                	ld	s5,8(sp)
  800510:	b539                	j	80031e <vprintfmt+0x36>
  800512:	3781                	addiw	a5,a5,-32
  800514:	05e00713          	li	a4,94
  800518:	fcf777e3          	bgeu	a4,a5,8004e6 <vprintfmt+0x1fe>
  80051c:	03f00513          	li	a0,63
  800520:	864e                	mv	a2,s3
  800522:	85ca                	mv	a1,s2
  800524:	9482                	jalr	s1
  800526:	000ac783          	lbu	a5,0(s5)
  80052a:	0a85                	addi	s5,s5,1
  80052c:	3dfd                	addiw	s11,s11,-1
  80052e:	0007851b          	sext.w	a0,a5
  800532:	d7e1                	beqz	a5,8004fa <vprintfmt+0x212>
  800534:	fa0d54e3          	bgez	s10,8004dc <vprintfmt+0x1f4>
  800538:	bfe9                	j	800512 <vprintfmt+0x22a>
  80053a:	000aa783          	lw	a5,0(s5)
  80053e:	46e1                	li	a3,24
  800540:	0aa1                	addi	s5,s5,8
  800542:	41f7d71b          	sraiw	a4,a5,0x1f
  800546:	8fb9                	xor	a5,a5,a4
  800548:	40e7873b          	subw	a4,a5,a4
  80054c:	02e6c663          	blt	a3,a4,800578 <vprintfmt+0x290>
  800550:	00000797          	auipc	a5,0x0
  800554:	5a878793          	addi	a5,a5,1448 # 800af8 <error_string>
  800558:	00371693          	slli	a3,a4,0x3
  80055c:	97b6                	add	a5,a5,a3
  80055e:	639c                	ld	a5,0(a5)
  800560:	cf81                	beqz	a5,800578 <vprintfmt+0x290>
  800562:	873e                	mv	a4,a5
  800564:	00000697          	auipc	a3,0x0
  800568:	23468693          	addi	a3,a3,564 # 800798 <main+0x116>
  80056c:	864a                	mv	a2,s2
  80056e:	85ce                	mv	a1,s3
  800570:	8526                	mv	a0,s1
  800572:	0f2000ef          	jal	800664 <printfmt>
  800576:	b365                	j	80031e <vprintfmt+0x36>
  800578:	00000697          	auipc	a3,0x0
  80057c:	21068693          	addi	a3,a3,528 # 800788 <main+0x106>
  800580:	864a                	mv	a2,s2
  800582:	85ce                	mv	a1,s3
  800584:	8526                	mv	a0,s1
  800586:	0de000ef          	jal	800664 <printfmt>
  80058a:	bb51                	j	80031e <vprintfmt+0x36>
  80058c:	4785                	li	a5,1
  80058e:	008a8c13          	addi	s8,s5,8
  800592:	00b7c363          	blt	a5,a1,800598 <vprintfmt+0x2b0>
  800596:	cd81                	beqz	a1,8005ae <vprintfmt+0x2c6>
  800598:	000ab403          	ld	s0,0(s5)
  80059c:	02044b63          	bltz	s0,8005d2 <vprintfmt+0x2ea>
  8005a0:	86a2                	mv	a3,s0
  8005a2:	8ae2                	mv	s5,s8
  8005a4:	4729                	li	a4,10
  8005a6:	b5a5                	j	80040e <vprintfmt+0x126>
  8005a8:	2585                	addiw	a1,a1,1
  8005aa:	8466                	mv	s0,s9
  8005ac:	bb71                	j	800348 <vprintfmt+0x60>
  8005ae:	000aa403          	lw	s0,0(s5)
  8005b2:	b7ed                	j	80059c <vprintfmt+0x2b4>
  8005b4:	000ae683          	lwu	a3,0(s5)
  8005b8:	4721                	li	a4,8
  8005ba:	8ab2                	mv	s5,a2
  8005bc:	bd89                	j	80040e <vprintfmt+0x126>
  8005be:	000ae683          	lwu	a3,0(s5)
  8005c2:	4729                	li	a4,10
  8005c4:	8ab2                	mv	s5,a2
  8005c6:	b5a1                	j	80040e <vprintfmt+0x126>
  8005c8:	000ae683          	lwu	a3,0(s5)
  8005cc:	4741                	li	a4,16
  8005ce:	8ab2                	mv	s5,a2
  8005d0:	bd3d                	j	80040e <vprintfmt+0x126>
  8005d2:	864e                	mv	a2,s3
  8005d4:	85ca                	mv	a1,s2
  8005d6:	02d00513          	li	a0,45
  8005da:	e042                	sd	a6,0(sp)
  8005dc:	9482                	jalr	s1
  8005de:	6802                	ld	a6,0(sp)
  8005e0:	408006b3          	neg	a3,s0
  8005e4:	8ae2                	mv	s5,s8
  8005e6:	4729                	li	a4,10
  8005e8:	b51d                	j	80040e <vprintfmt+0x126>
  8005ea:	eba1                	bnez	a5,80063a <vprintfmt+0x352>
  8005ec:	02800793          	li	a5,40
  8005f0:	853e                	mv	a0,a5
  8005f2:	00000a97          	auipc	s5,0x0
  8005f6:	18fa8a93          	addi	s5,s5,399 # 800781 <main+0xff>
  8005fa:	547d                	li	s0,-1
  8005fc:	bdf1                	j	8004d8 <vprintfmt+0x1f0>
  8005fe:	853a                	mv	a0,a4
  800600:	85ea                	mv	a1,s10
  800602:	e03a                	sd	a4,0(sp)
  800604:	c59ff0ef          	jal	80025c <strnlen>
  800608:	40ad8dbb          	subw	s11,s11,a0
  80060c:	6702                	ld	a4,0(sp)
  80060e:	01b05b63          	blez	s11,800624 <vprintfmt+0x33c>
  800612:	864e                	mv	a2,s3
  800614:	85ca                	mv	a1,s2
  800616:	8522                	mv	a0,s0
  800618:	e03a                	sd	a4,0(sp)
  80061a:	3dfd                	addiw	s11,s11,-1
  80061c:	9482                	jalr	s1
  80061e:	6702                	ld	a4,0(sp)
  800620:	fe0d99e3          	bnez	s11,800612 <vprintfmt+0x32a>
  800624:	00074783          	lbu	a5,0(a4)
  800628:	0007851b          	sext.w	a0,a5
  80062c:	ee0781e3          	beqz	a5,80050e <vprintfmt+0x226>
  800630:	00170a93          	addi	s5,a4,1
  800634:	b54d                	j	8004d6 <vprintfmt+0x1ee>
  800636:	8466                	mv	s0,s9
  800638:	b36d                	j	8003e2 <vprintfmt+0xfa>
  80063a:	85ea                	mv	a1,s10
  80063c:	00000517          	auipc	a0,0x0
  800640:	14450513          	addi	a0,a0,324 # 800780 <main+0xfe>
  800644:	c19ff0ef          	jal	80025c <strnlen>
  800648:	40ad8dbb          	subw	s11,s11,a0
  80064c:	02800793          	li	a5,40
  800650:	00000717          	auipc	a4,0x0
  800654:	13070713          	addi	a4,a4,304 # 800780 <main+0xfe>
  800658:	853e                	mv	a0,a5
  80065a:	fbb04ce3          	bgtz	s11,800612 <vprintfmt+0x32a>
  80065e:	00170a93          	addi	s5,a4,1
  800662:	bd95                	j	8004d6 <vprintfmt+0x1ee>

0000000000800664 <printfmt>:
  800664:	7139                	addi	sp,sp,-64
  800666:	02010313          	addi	t1,sp,32
  80066a:	f03a                	sd	a4,32(sp)
  80066c:	871a                	mv	a4,t1
  80066e:	ec06                	sd	ra,24(sp)
  800670:	f43e                	sd	a5,40(sp)
  800672:	f842                	sd	a6,48(sp)
  800674:	fc46                	sd	a7,56(sp)
  800676:	e41a                	sd	t1,8(sp)
  800678:	c71ff0ef          	jal	8002e8 <vprintfmt>
  80067c:	60e2                	ld	ra,24(sp)
  80067e:	6121                	addi	sp,sp,64
  800680:	8082                	ret

0000000000800682 <main>:
  800682:	1141                	addi	sp,sp,-16
  800684:	00000617          	auipc	a2,0x0
  800688:	2f460613          	addi	a2,a2,756 # 800978 <main+0x2f6>
  80068c:	45a5                	li	a1,9
  80068e:	00000517          	auipc	a0,0x0
  800692:	2fa50513          	addi	a0,a0,762 # 800988 <main+0x306>
  800696:	e406                	sd	ra,8(sp)
  800698:	989ff0ef          	jal	800020 <__panic>
