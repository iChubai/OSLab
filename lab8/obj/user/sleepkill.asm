
obj/__user_sleepkill.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	6f250513          	addi	a0,a0,1778 # 800720 <main+0x84>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	142000ef          	jal	800186 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	114000ef          	jal	800160 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	6f050513          	addi	a0,a0,1776 # 800740 <main+0xa4>
  800058:	12e000ef          	jal	800186 <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0ba000ef          	jal	800118 <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00000517          	auipc	a0,0x0
  800074:	6d850513          	addi	a0,a0,1752 # 800748 <main+0xac>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	100000ef          	jal	800186 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0d2000ef          	jal	800160 <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	6ae50513          	addi	a0,a0,1710 # 800740 <main+0xa4>
  80009a:	0ec000ef          	jal	800186 <cprintf>
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

00000000008000e6 <sys_fork>:
  8000e6:	4509                	li	a0,2
  8000e8:	bf7d                	j	8000a6 <syscall>

00000000008000ea <sys_kill>:
  8000ea:	85aa                	mv	a1,a0
  8000ec:	4531                	li	a0,12
  8000ee:	bf65                	j	8000a6 <syscall>

00000000008000f0 <sys_putc>:
  8000f0:	85aa                	mv	a1,a0
  8000f2:	4579                	li	a0,30
  8000f4:	bf4d                	j	8000a6 <syscall>

00000000008000f6 <sys_sleep>:
  8000f6:	85aa                	mv	a1,a0
  8000f8:	452d                	li	a0,11
  8000fa:	b775                	j	8000a6 <syscall>

00000000008000fc <sys_open>:
  8000fc:	862e                	mv	a2,a1
  8000fe:	85aa                	mv	a1,a0
  800100:	06400513          	li	a0,100
  800104:	b74d                	j	8000a6 <syscall>

0000000000800106 <sys_close>:
  800106:	85aa                	mv	a1,a0
  800108:	06500513          	li	a0,101
  80010c:	bf69                	j	8000a6 <syscall>

000000000080010e <sys_dup>:
  80010e:	862e                	mv	a2,a1
  800110:	85aa                	mv	a1,a0
  800112:	08200513          	li	a0,130
  800116:	bf41                	j	8000a6 <syscall>

0000000000800118 <exit>:
  800118:	1141                	addi	sp,sp,-16
  80011a:	e406                	sd	ra,8(sp)
  80011c:	fc5ff0ef          	jal	8000e0 <sys_exit>
  800120:	00000517          	auipc	a0,0x0
  800124:	64850513          	addi	a0,a0,1608 # 800768 <main+0xcc>
  800128:	05e000ef          	jal	800186 <cprintf>
  80012c:	a001                	j	80012c <exit+0x14>

000000000080012e <fork>:
  80012e:	bf65                	j	8000e6 <sys_fork>

0000000000800130 <kill>:
  800130:	bf6d                	j	8000ea <sys_kill>

0000000000800132 <sleep>:
  800132:	1502                	slli	a0,a0,0x20
  800134:	9101                	srli	a0,a0,0x20
  800136:	b7c1                	j	8000f6 <sys_sleep>

0000000000800138 <_start>:
  800138:	0ca000ef          	jal	800202 <umain>
  80013c:	a001                	j	80013c <_start+0x4>

000000000080013e <open>:
  80013e:	1582                	slli	a1,a1,0x20
  800140:	9181                	srli	a1,a1,0x20
  800142:	bf6d                	j	8000fc <sys_open>

0000000000800144 <close>:
  800144:	b7c9                	j	800106 <sys_close>

0000000000800146 <dup2>:
  800146:	b7e1                	j	80010e <sys_dup>

0000000000800148 <cputch>:
  800148:	1101                	addi	sp,sp,-32
  80014a:	ec06                	sd	ra,24(sp)
  80014c:	e42e                	sd	a1,8(sp)
  80014e:	fa3ff0ef          	jal	8000f0 <sys_putc>
  800152:	65a2                	ld	a1,8(sp)
  800154:	60e2                	ld	ra,24(sp)
  800156:	419c                	lw	a5,0(a1)
  800158:	2785                	addiw	a5,a5,1
  80015a:	c19c                	sw	a5,0(a1)
  80015c:	6105                	addi	sp,sp,32
  80015e:	8082                	ret

0000000000800160 <vcprintf>:
  800160:	1101                	addi	sp,sp,-32
  800162:	872e                	mv	a4,a1
  800164:	75dd                	lui	a1,0xffff7
  800166:	86aa                	mv	a3,a0
  800168:	0070                	addi	a2,sp,12
  80016a:	00000517          	auipc	a0,0x0
  80016e:	fde50513          	addi	a0,a0,-34 # 800148 <cputch>
  800172:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5f29>
  800176:	ec06                	sd	ra,24(sp)
  800178:	c602                	sw	zero,12(sp)
  80017a:	188000ef          	jal	800302 <vprintfmt>
  80017e:	60e2                	ld	ra,24(sp)
  800180:	4532                	lw	a0,12(sp)
  800182:	6105                	addi	sp,sp,32
  800184:	8082                	ret

0000000000800186 <cprintf>:
  800186:	711d                	addi	sp,sp,-96
  800188:	02810313          	addi	t1,sp,40
  80018c:	f42e                	sd	a1,40(sp)
  80018e:	75dd                	lui	a1,0xffff7
  800190:	f832                	sd	a2,48(sp)
  800192:	fc36                	sd	a3,56(sp)
  800194:	e0ba                	sd	a4,64(sp)
  800196:	86aa                	mv	a3,a0
  800198:	0050                	addi	a2,sp,4
  80019a:	00000517          	auipc	a0,0x0
  80019e:	fae50513          	addi	a0,a0,-82 # 800148 <cputch>
  8001a2:	871a                	mv	a4,t1
  8001a4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5f29>
  8001a8:	ec06                	sd	ra,24(sp)
  8001aa:	e4be                	sd	a5,72(sp)
  8001ac:	e8c2                	sd	a6,80(sp)
  8001ae:	ecc6                	sd	a7,88(sp)
  8001b0:	c202                	sw	zero,4(sp)
  8001b2:	e41a                	sd	t1,8(sp)
  8001b4:	14e000ef          	jal	800302 <vprintfmt>
  8001b8:	60e2                	ld	ra,24(sp)
  8001ba:	4512                	lw	a0,4(sp)
  8001bc:	6125                	addi	sp,sp,96
  8001be:	8082                	ret

00000000008001c0 <initfd>:
  8001c0:	87ae                	mv	a5,a1
  8001c2:	1101                	addi	sp,sp,-32
  8001c4:	e822                	sd	s0,16(sp)
  8001c6:	85b2                	mv	a1,a2
  8001c8:	842a                	mv	s0,a0
  8001ca:	853e                	mv	a0,a5
  8001cc:	ec06                	sd	ra,24(sp)
  8001ce:	f71ff0ef          	jal	80013e <open>
  8001d2:	87aa                	mv	a5,a0
  8001d4:	00054463          	bltz	a0,8001dc <initfd+0x1c>
  8001d8:	00851763          	bne	a0,s0,8001e6 <initfd+0x26>
  8001dc:	60e2                	ld	ra,24(sp)
  8001de:	6442                	ld	s0,16(sp)
  8001e0:	853e                	mv	a0,a5
  8001e2:	6105                	addi	sp,sp,32
  8001e4:	8082                	ret
  8001e6:	e42a                	sd	a0,8(sp)
  8001e8:	8522                	mv	a0,s0
  8001ea:	f5bff0ef          	jal	800144 <close>
  8001ee:	6522                	ld	a0,8(sp)
  8001f0:	85a2                	mv	a1,s0
  8001f2:	f55ff0ef          	jal	800146 <dup2>
  8001f6:	842a                	mv	s0,a0
  8001f8:	6522                	ld	a0,8(sp)
  8001fa:	f4bff0ef          	jal	800144 <close>
  8001fe:	87a2                	mv	a5,s0
  800200:	bff1                	j	8001dc <initfd+0x1c>

0000000000800202 <umain>:
  800202:	1101                	addi	sp,sp,-32
  800204:	e822                	sd	s0,16(sp)
  800206:	e426                	sd	s1,8(sp)
  800208:	842a                	mv	s0,a0
  80020a:	84ae                	mv	s1,a1
  80020c:	4601                	li	a2,0
  80020e:	00000597          	auipc	a1,0x0
  800212:	57258593          	addi	a1,a1,1394 # 800780 <main+0xe4>
  800216:	4501                	li	a0,0
  800218:	ec06                	sd	ra,24(sp)
  80021a:	fa7ff0ef          	jal	8001c0 <initfd>
  80021e:	02054263          	bltz	a0,800242 <umain+0x40>
  800222:	4605                	li	a2,1
  800224:	8532                	mv	a0,a2
  800226:	00000597          	auipc	a1,0x0
  80022a:	59a58593          	addi	a1,a1,1434 # 8007c0 <main+0x124>
  80022e:	f93ff0ef          	jal	8001c0 <initfd>
  800232:	02054563          	bltz	a0,80025c <umain+0x5a>
  800236:	85a6                	mv	a1,s1
  800238:	8522                	mv	a0,s0
  80023a:	462000ef          	jal	80069c <main>
  80023e:	edbff0ef          	jal	800118 <exit>
  800242:	86aa                	mv	a3,a0
  800244:	00000617          	auipc	a2,0x0
  800248:	54460613          	addi	a2,a2,1348 # 800788 <main+0xec>
  80024c:	45e9                	li	a1,26
  80024e:	00000517          	auipc	a0,0x0
  800252:	55a50513          	addi	a0,a0,1370 # 8007a8 <main+0x10c>
  800256:	e0dff0ef          	jal	800062 <__warn>
  80025a:	b7e1                	j	800222 <umain+0x20>
  80025c:	86aa                	mv	a3,a0
  80025e:	00000617          	auipc	a2,0x0
  800262:	56a60613          	addi	a2,a2,1386 # 8007c8 <main+0x12c>
  800266:	45f5                	li	a1,29
  800268:	00000517          	auipc	a0,0x0
  80026c:	54050513          	addi	a0,a0,1344 # 8007a8 <main+0x10c>
  800270:	df3ff0ef          	jal	800062 <__warn>
  800274:	b7c9                	j	800236 <umain+0x34>

0000000000800276 <strnlen>:
  800276:	4781                	li	a5,0
  800278:	e589                	bnez	a1,800282 <strnlen+0xc>
  80027a:	a811                	j	80028e <strnlen+0x18>
  80027c:	0785                	addi	a5,a5,1
  80027e:	00f58863          	beq	a1,a5,80028e <strnlen+0x18>
  800282:	00f50733          	add	a4,a0,a5
  800286:	00074703          	lbu	a4,0(a4)
  80028a:	fb6d                	bnez	a4,80027c <strnlen+0x6>
  80028c:	85be                	mv	a1,a5
  80028e:	852e                	mv	a0,a1
  800290:	8082                	ret

0000000000800292 <printnum>:
  800292:	7139                	addi	sp,sp,-64
  800294:	02071893          	slli	a7,a4,0x20
  800298:	f822                	sd	s0,48(sp)
  80029a:	f426                	sd	s1,40(sp)
  80029c:	f04a                	sd	s2,32(sp)
  80029e:	ec4e                	sd	s3,24(sp)
  8002a0:	e456                	sd	s5,8(sp)
  8002a2:	0208d893          	srli	a7,a7,0x20
  8002a6:	fc06                	sd	ra,56(sp)
  8002a8:	0316fab3          	remu	s5,a3,a7
  8002ac:	fff7841b          	addiw	s0,a5,-1
  8002b0:	84aa                	mv	s1,a0
  8002b2:	89ae                	mv	s3,a1
  8002b4:	8932                	mv	s2,a2
  8002b6:	0516f063          	bgeu	a3,a7,8002f6 <printnum+0x64>
  8002ba:	e852                	sd	s4,16(sp)
  8002bc:	4705                	li	a4,1
  8002be:	8a42                	mv	s4,a6
  8002c0:	00f75863          	bge	a4,a5,8002d0 <printnum+0x3e>
  8002c4:	864e                	mv	a2,s3
  8002c6:	85ca                	mv	a1,s2
  8002c8:	8552                	mv	a0,s4
  8002ca:	347d                	addiw	s0,s0,-1
  8002cc:	9482                	jalr	s1
  8002ce:	f87d                	bnez	s0,8002c4 <printnum+0x32>
  8002d0:	6a42                	ld	s4,16(sp)
  8002d2:	00000797          	auipc	a5,0x0
  8002d6:	51678793          	addi	a5,a5,1302 # 8007e8 <main+0x14c>
  8002da:	97d6                	add	a5,a5,s5
  8002dc:	7442                	ld	s0,48(sp)
  8002de:	0007c503          	lbu	a0,0(a5)
  8002e2:	70e2                	ld	ra,56(sp)
  8002e4:	6aa2                	ld	s5,8(sp)
  8002e6:	864e                	mv	a2,s3
  8002e8:	85ca                	mv	a1,s2
  8002ea:	69e2                	ld	s3,24(sp)
  8002ec:	7902                	ld	s2,32(sp)
  8002ee:	87a6                	mv	a5,s1
  8002f0:	74a2                	ld	s1,40(sp)
  8002f2:	6121                	addi	sp,sp,64
  8002f4:	8782                	jr	a5
  8002f6:	0316d6b3          	divu	a3,a3,a7
  8002fa:	87a2                	mv	a5,s0
  8002fc:	f97ff0ef          	jal	800292 <printnum>
  800300:	bfc9                	j	8002d2 <printnum+0x40>

0000000000800302 <vprintfmt>:
  800302:	7119                	addi	sp,sp,-128
  800304:	f4a6                	sd	s1,104(sp)
  800306:	f0ca                	sd	s2,96(sp)
  800308:	ecce                	sd	s3,88(sp)
  80030a:	e8d2                	sd	s4,80(sp)
  80030c:	e4d6                	sd	s5,72(sp)
  80030e:	e0da                	sd	s6,64(sp)
  800310:	fc5e                	sd	s7,56(sp)
  800312:	f466                	sd	s9,40(sp)
  800314:	fc86                	sd	ra,120(sp)
  800316:	f8a2                	sd	s0,112(sp)
  800318:	f862                	sd	s8,48(sp)
  80031a:	f06a                	sd	s10,32(sp)
  80031c:	ec6e                	sd	s11,24(sp)
  80031e:	84aa                	mv	s1,a0
  800320:	8cb6                	mv	s9,a3
  800322:	8aba                	mv	s5,a4
  800324:	89ae                	mv	s3,a1
  800326:	8932                	mv	s2,a2
  800328:	02500a13          	li	s4,37
  80032c:	05500b93          	li	s7,85
  800330:	00000b17          	auipc	s6,0x0
  800334:	724b0b13          	addi	s6,s6,1828 # 800a54 <main+0x3b8>
  800338:	000cc503          	lbu	a0,0(s9)
  80033c:	001c8413          	addi	s0,s9,1
  800340:	01450b63          	beq	a0,s4,800356 <vprintfmt+0x54>
  800344:	cd15                	beqz	a0,800380 <vprintfmt+0x7e>
  800346:	864e                	mv	a2,s3
  800348:	85ca                	mv	a1,s2
  80034a:	9482                	jalr	s1
  80034c:	00044503          	lbu	a0,0(s0)
  800350:	0405                	addi	s0,s0,1
  800352:	ff4519e3          	bne	a0,s4,800344 <vprintfmt+0x42>
  800356:	5d7d                	li	s10,-1
  800358:	8dea                	mv	s11,s10
  80035a:	02000813          	li	a6,32
  80035e:	4c01                	li	s8,0
  800360:	4581                	li	a1,0
  800362:	00044703          	lbu	a4,0(s0)
  800366:	00140c93          	addi	s9,s0,1
  80036a:	fdd7061b          	addiw	a2,a4,-35
  80036e:	0ff67613          	zext.b	a2,a2
  800372:	02cbe663          	bltu	s7,a2,80039e <vprintfmt+0x9c>
  800376:	060a                	slli	a2,a2,0x2
  800378:	965a                	add	a2,a2,s6
  80037a:	421c                	lw	a5,0(a2)
  80037c:	97da                	add	a5,a5,s6
  80037e:	8782                	jr	a5
  800380:	70e6                	ld	ra,120(sp)
  800382:	7446                	ld	s0,112(sp)
  800384:	74a6                	ld	s1,104(sp)
  800386:	7906                	ld	s2,96(sp)
  800388:	69e6                	ld	s3,88(sp)
  80038a:	6a46                	ld	s4,80(sp)
  80038c:	6aa6                	ld	s5,72(sp)
  80038e:	6b06                	ld	s6,64(sp)
  800390:	7be2                	ld	s7,56(sp)
  800392:	7c42                	ld	s8,48(sp)
  800394:	7ca2                	ld	s9,40(sp)
  800396:	7d02                	ld	s10,32(sp)
  800398:	6de2                	ld	s11,24(sp)
  80039a:	6109                	addi	sp,sp,128
  80039c:	8082                	ret
  80039e:	864e                	mv	a2,s3
  8003a0:	85ca                	mv	a1,s2
  8003a2:	02500513          	li	a0,37
  8003a6:	9482                	jalr	s1
  8003a8:	fff44783          	lbu	a5,-1(s0)
  8003ac:	02500713          	li	a4,37
  8003b0:	8ca2                	mv	s9,s0
  8003b2:	f8e783e3          	beq	a5,a4,800338 <vprintfmt+0x36>
  8003b6:	ffecc783          	lbu	a5,-2(s9)
  8003ba:	1cfd                	addi	s9,s9,-1
  8003bc:	fee79de3          	bne	a5,a4,8003b6 <vprintfmt+0xb4>
  8003c0:	bfa5                	j	800338 <vprintfmt+0x36>
  8003c2:	00144683          	lbu	a3,1(s0)
  8003c6:	4525                	li	a0,9
  8003c8:	fd070d1b          	addiw	s10,a4,-48
  8003cc:	fd06879b          	addiw	a5,a3,-48
  8003d0:	28f56063          	bltu	a0,a5,800650 <vprintfmt+0x34e>
  8003d4:	2681                	sext.w	a3,a3
  8003d6:	8466                	mv	s0,s9
  8003d8:	002d179b          	slliw	a5,s10,0x2
  8003dc:	00144703          	lbu	a4,1(s0)
  8003e0:	01a787bb          	addw	a5,a5,s10
  8003e4:	0017979b          	slliw	a5,a5,0x1
  8003e8:	9fb5                	addw	a5,a5,a3
  8003ea:	fd07061b          	addiw	a2,a4,-48
  8003ee:	0405                	addi	s0,s0,1
  8003f0:	fd078d1b          	addiw	s10,a5,-48
  8003f4:	0007069b          	sext.w	a3,a4
  8003f8:	fec570e3          	bgeu	a0,a2,8003d8 <vprintfmt+0xd6>
  8003fc:	f60dd3e3          	bgez	s11,800362 <vprintfmt+0x60>
  800400:	8dea                	mv	s11,s10
  800402:	5d7d                	li	s10,-1
  800404:	bfb9                	j	800362 <vprintfmt+0x60>
  800406:	883a                	mv	a6,a4
  800408:	8466                	mv	s0,s9
  80040a:	bfa1                	j	800362 <vprintfmt+0x60>
  80040c:	8466                	mv	s0,s9
  80040e:	4c05                	li	s8,1
  800410:	bf89                	j	800362 <vprintfmt+0x60>
  800412:	4785                	li	a5,1
  800414:	008a8613          	addi	a2,s5,8
  800418:	00b7c463          	blt	a5,a1,800420 <vprintfmt+0x11e>
  80041c:	1c058363          	beqz	a1,8005e2 <vprintfmt+0x2e0>
  800420:	000ab683          	ld	a3,0(s5)
  800424:	4741                	li	a4,16
  800426:	8ab2                	mv	s5,a2
  800428:	2801                	sext.w	a6,a6
  80042a:	87ee                	mv	a5,s11
  80042c:	864a                	mv	a2,s2
  80042e:	85ce                	mv	a1,s3
  800430:	8526                	mv	a0,s1
  800432:	e61ff0ef          	jal	800292 <printnum>
  800436:	b709                	j	800338 <vprintfmt+0x36>
  800438:	000aa503          	lw	a0,0(s5)
  80043c:	864e                	mv	a2,s3
  80043e:	85ca                	mv	a1,s2
  800440:	9482                	jalr	s1
  800442:	0aa1                	addi	s5,s5,8
  800444:	bdd5                	j	800338 <vprintfmt+0x36>
  800446:	4785                	li	a5,1
  800448:	008a8613          	addi	a2,s5,8
  80044c:	00b7c463          	blt	a5,a1,800454 <vprintfmt+0x152>
  800450:	18058463          	beqz	a1,8005d8 <vprintfmt+0x2d6>
  800454:	000ab683          	ld	a3,0(s5)
  800458:	4729                	li	a4,10
  80045a:	8ab2                	mv	s5,a2
  80045c:	b7f1                	j	800428 <vprintfmt+0x126>
  80045e:	864e                	mv	a2,s3
  800460:	85ca                	mv	a1,s2
  800462:	03000513          	li	a0,48
  800466:	e042                	sd	a6,0(sp)
  800468:	9482                	jalr	s1
  80046a:	864e                	mv	a2,s3
  80046c:	85ca                	mv	a1,s2
  80046e:	07800513          	li	a0,120
  800472:	9482                	jalr	s1
  800474:	000ab683          	ld	a3,0(s5)
  800478:	6802                	ld	a6,0(sp)
  80047a:	4741                	li	a4,16
  80047c:	0aa1                	addi	s5,s5,8
  80047e:	b76d                	j	800428 <vprintfmt+0x126>
  800480:	864e                	mv	a2,s3
  800482:	85ca                	mv	a1,s2
  800484:	02500513          	li	a0,37
  800488:	9482                	jalr	s1
  80048a:	b57d                	j	800338 <vprintfmt+0x36>
  80048c:	000aad03          	lw	s10,0(s5)
  800490:	8466                	mv	s0,s9
  800492:	0aa1                	addi	s5,s5,8
  800494:	b7a5                	j	8003fc <vprintfmt+0xfa>
  800496:	4785                	li	a5,1
  800498:	008a8613          	addi	a2,s5,8
  80049c:	00b7c463          	blt	a5,a1,8004a4 <vprintfmt+0x1a2>
  8004a0:	12058763          	beqz	a1,8005ce <vprintfmt+0x2cc>
  8004a4:	000ab683          	ld	a3,0(s5)
  8004a8:	4721                	li	a4,8
  8004aa:	8ab2                	mv	s5,a2
  8004ac:	bfb5                	j	800428 <vprintfmt+0x126>
  8004ae:	87ee                	mv	a5,s11
  8004b0:	000dd363          	bgez	s11,8004b6 <vprintfmt+0x1b4>
  8004b4:	4781                	li	a5,0
  8004b6:	00078d9b          	sext.w	s11,a5
  8004ba:	8466                	mv	s0,s9
  8004bc:	b55d                	j	800362 <vprintfmt+0x60>
  8004be:	0008041b          	sext.w	s0,a6
  8004c2:	fd340793          	addi	a5,s0,-45
  8004c6:	01b02733          	sgtz	a4,s11
  8004ca:	00f037b3          	snez	a5,a5
  8004ce:	8ff9                	and	a5,a5,a4
  8004d0:	000ab703          	ld	a4,0(s5)
  8004d4:	008a8693          	addi	a3,s5,8
  8004d8:	e436                	sd	a3,8(sp)
  8004da:	12070563          	beqz	a4,800604 <vprintfmt+0x302>
  8004de:	12079d63          	bnez	a5,800618 <vprintfmt+0x316>
  8004e2:	00074783          	lbu	a5,0(a4)
  8004e6:	0007851b          	sext.w	a0,a5
  8004ea:	c78d                	beqz	a5,800514 <vprintfmt+0x212>
  8004ec:	00170a93          	addi	s5,a4,1
  8004f0:	547d                	li	s0,-1
  8004f2:	000d4563          	bltz	s10,8004fc <vprintfmt+0x1fa>
  8004f6:	3d7d                	addiw	s10,s10,-1
  8004f8:	008d0e63          	beq	s10,s0,800514 <vprintfmt+0x212>
  8004fc:	020c1863          	bnez	s8,80052c <vprintfmt+0x22a>
  800500:	864e                	mv	a2,s3
  800502:	85ca                	mv	a1,s2
  800504:	9482                	jalr	s1
  800506:	000ac783          	lbu	a5,0(s5)
  80050a:	0a85                	addi	s5,s5,1
  80050c:	3dfd                	addiw	s11,s11,-1
  80050e:	0007851b          	sext.w	a0,a5
  800512:	f3e5                	bnez	a5,8004f2 <vprintfmt+0x1f0>
  800514:	01b05a63          	blez	s11,800528 <vprintfmt+0x226>
  800518:	864e                	mv	a2,s3
  80051a:	85ca                	mv	a1,s2
  80051c:	02000513          	li	a0,32
  800520:	3dfd                	addiw	s11,s11,-1
  800522:	9482                	jalr	s1
  800524:	fe0d9ae3          	bnez	s11,800518 <vprintfmt+0x216>
  800528:	6aa2                	ld	s5,8(sp)
  80052a:	b539                	j	800338 <vprintfmt+0x36>
  80052c:	3781                	addiw	a5,a5,-32
  80052e:	05e00713          	li	a4,94
  800532:	fcf777e3          	bgeu	a4,a5,800500 <vprintfmt+0x1fe>
  800536:	03f00513          	li	a0,63
  80053a:	864e                	mv	a2,s3
  80053c:	85ca                	mv	a1,s2
  80053e:	9482                	jalr	s1
  800540:	000ac783          	lbu	a5,0(s5)
  800544:	0a85                	addi	s5,s5,1
  800546:	3dfd                	addiw	s11,s11,-1
  800548:	0007851b          	sext.w	a0,a5
  80054c:	d7e1                	beqz	a5,800514 <vprintfmt+0x212>
  80054e:	fa0d54e3          	bgez	s10,8004f6 <vprintfmt+0x1f4>
  800552:	bfe9                	j	80052c <vprintfmt+0x22a>
  800554:	000aa783          	lw	a5,0(s5)
  800558:	46e1                	li	a3,24
  80055a:	0aa1                	addi	s5,s5,8
  80055c:	41f7d71b          	sraiw	a4,a5,0x1f
  800560:	8fb9                	xor	a5,a5,a4
  800562:	40e7873b          	subw	a4,a5,a4
  800566:	02e6c663          	blt	a3,a4,800592 <vprintfmt+0x290>
  80056a:	00000797          	auipc	a5,0x0
  80056e:	64678793          	addi	a5,a5,1606 # 800bb0 <error_string>
  800572:	00371693          	slli	a3,a4,0x3
  800576:	97b6                	add	a5,a5,a3
  800578:	639c                	ld	a5,0(a5)
  80057a:	cf81                	beqz	a5,800592 <vprintfmt+0x290>
  80057c:	873e                	mv	a4,a5
  80057e:	00000697          	auipc	a3,0x0
  800582:	29a68693          	addi	a3,a3,666 # 800818 <main+0x17c>
  800586:	864a                	mv	a2,s2
  800588:	85ce                	mv	a1,s3
  80058a:	8526                	mv	a0,s1
  80058c:	0f2000ef          	jal	80067e <printfmt>
  800590:	b365                	j	800338 <vprintfmt+0x36>
  800592:	00000697          	auipc	a3,0x0
  800596:	27668693          	addi	a3,a3,630 # 800808 <main+0x16c>
  80059a:	864a                	mv	a2,s2
  80059c:	85ce                	mv	a1,s3
  80059e:	8526                	mv	a0,s1
  8005a0:	0de000ef          	jal	80067e <printfmt>
  8005a4:	bb51                	j	800338 <vprintfmt+0x36>
  8005a6:	4785                	li	a5,1
  8005a8:	008a8c13          	addi	s8,s5,8
  8005ac:	00b7c363          	blt	a5,a1,8005b2 <vprintfmt+0x2b0>
  8005b0:	cd81                	beqz	a1,8005c8 <vprintfmt+0x2c6>
  8005b2:	000ab403          	ld	s0,0(s5)
  8005b6:	02044b63          	bltz	s0,8005ec <vprintfmt+0x2ea>
  8005ba:	86a2                	mv	a3,s0
  8005bc:	8ae2                	mv	s5,s8
  8005be:	4729                	li	a4,10
  8005c0:	b5a5                	j	800428 <vprintfmt+0x126>
  8005c2:	2585                	addiw	a1,a1,1
  8005c4:	8466                	mv	s0,s9
  8005c6:	bb71                	j	800362 <vprintfmt+0x60>
  8005c8:	000aa403          	lw	s0,0(s5)
  8005cc:	b7ed                	j	8005b6 <vprintfmt+0x2b4>
  8005ce:	000ae683          	lwu	a3,0(s5)
  8005d2:	4721                	li	a4,8
  8005d4:	8ab2                	mv	s5,a2
  8005d6:	bd89                	j	800428 <vprintfmt+0x126>
  8005d8:	000ae683          	lwu	a3,0(s5)
  8005dc:	4729                	li	a4,10
  8005de:	8ab2                	mv	s5,a2
  8005e0:	b5a1                	j	800428 <vprintfmt+0x126>
  8005e2:	000ae683          	lwu	a3,0(s5)
  8005e6:	4741                	li	a4,16
  8005e8:	8ab2                	mv	s5,a2
  8005ea:	bd3d                	j	800428 <vprintfmt+0x126>
  8005ec:	864e                	mv	a2,s3
  8005ee:	85ca                	mv	a1,s2
  8005f0:	02d00513          	li	a0,45
  8005f4:	e042                	sd	a6,0(sp)
  8005f6:	9482                	jalr	s1
  8005f8:	6802                	ld	a6,0(sp)
  8005fa:	408006b3          	neg	a3,s0
  8005fe:	8ae2                	mv	s5,s8
  800600:	4729                	li	a4,10
  800602:	b51d                	j	800428 <vprintfmt+0x126>
  800604:	eba1                	bnez	a5,800654 <vprintfmt+0x352>
  800606:	02800793          	li	a5,40
  80060a:	853e                	mv	a0,a5
  80060c:	00000a97          	auipc	s5,0x0
  800610:	1f5a8a93          	addi	s5,s5,501 # 800801 <main+0x165>
  800614:	547d                	li	s0,-1
  800616:	bdf1                	j	8004f2 <vprintfmt+0x1f0>
  800618:	853a                	mv	a0,a4
  80061a:	85ea                	mv	a1,s10
  80061c:	e03a                	sd	a4,0(sp)
  80061e:	c59ff0ef          	jal	800276 <strnlen>
  800622:	40ad8dbb          	subw	s11,s11,a0
  800626:	6702                	ld	a4,0(sp)
  800628:	01b05b63          	blez	s11,80063e <vprintfmt+0x33c>
  80062c:	864e                	mv	a2,s3
  80062e:	85ca                	mv	a1,s2
  800630:	8522                	mv	a0,s0
  800632:	e03a                	sd	a4,0(sp)
  800634:	3dfd                	addiw	s11,s11,-1
  800636:	9482                	jalr	s1
  800638:	6702                	ld	a4,0(sp)
  80063a:	fe0d99e3          	bnez	s11,80062c <vprintfmt+0x32a>
  80063e:	00074783          	lbu	a5,0(a4)
  800642:	0007851b          	sext.w	a0,a5
  800646:	ee0781e3          	beqz	a5,800528 <vprintfmt+0x226>
  80064a:	00170a93          	addi	s5,a4,1
  80064e:	b54d                	j	8004f0 <vprintfmt+0x1ee>
  800650:	8466                	mv	s0,s9
  800652:	b36d                	j	8003fc <vprintfmt+0xfa>
  800654:	85ea                	mv	a1,s10
  800656:	00000517          	auipc	a0,0x0
  80065a:	1aa50513          	addi	a0,a0,426 # 800800 <main+0x164>
  80065e:	c19ff0ef          	jal	800276 <strnlen>
  800662:	40ad8dbb          	subw	s11,s11,a0
  800666:	02800793          	li	a5,40
  80066a:	00000717          	auipc	a4,0x0
  80066e:	19670713          	addi	a4,a4,406 # 800800 <main+0x164>
  800672:	853e                	mv	a0,a5
  800674:	fbb04ce3          	bgtz	s11,80062c <vprintfmt+0x32a>
  800678:	00170a93          	addi	s5,a4,1
  80067c:	bd95                	j	8004f0 <vprintfmt+0x1ee>

000000000080067e <printfmt>:
  80067e:	7139                	addi	sp,sp,-64
  800680:	02010313          	addi	t1,sp,32
  800684:	f03a                	sd	a4,32(sp)
  800686:	871a                	mv	a4,t1
  800688:	ec06                	sd	ra,24(sp)
  80068a:	f43e                	sd	a5,40(sp)
  80068c:	f842                	sd	a6,48(sp)
  80068e:	fc46                	sd	a7,56(sp)
  800690:	e41a                	sd	t1,8(sp)
  800692:	c71ff0ef          	jal	800302 <vprintfmt>
  800696:	60e2                	ld	ra,24(sp)
  800698:	6121                	addi	sp,sp,64
  80069a:	8082                	ret

000000000080069c <main>:
  80069c:	1141                	addi	sp,sp,-16
  80069e:	e406                	sd	ra,8(sp)
  8006a0:	e022                	sd	s0,0(sp)
  8006a2:	a8dff0ef          	jal	80012e <fork>
  8006a6:	c51d                	beqz	a0,8006d4 <main+0x38>
  8006a8:	842a                	mv	s0,a0
  8006aa:	04a05c63          	blez	a0,800702 <main+0x66>
  8006ae:	06400513          	li	a0,100
  8006b2:	a81ff0ef          	jal	800132 <sleep>
  8006b6:	8522                	mv	a0,s0
  8006b8:	a79ff0ef          	jal	800130 <kill>
  8006bc:	e505                	bnez	a0,8006e4 <main+0x48>
  8006be:	00000517          	auipc	a0,0x0
  8006c2:	38250513          	addi	a0,a0,898 # 800a40 <main+0x3a4>
  8006c6:	ac1ff0ef          	jal	800186 <cprintf>
  8006ca:	60a2                	ld	ra,8(sp)
  8006cc:	6402                	ld	s0,0(sp)
  8006ce:	4501                	li	a0,0
  8006d0:	0141                	addi	sp,sp,16
  8006d2:	8082                	ret
  8006d4:	557d                	li	a0,-1
  8006d6:	a5dff0ef          	jal	800132 <sleep>
  8006da:	6539                	lui	a0,0xe
  8006dc:	ead50513          	addi	a0,a0,-339 # dead <__panic-0x7f2173>
  8006e0:	a39ff0ef          	jal	800118 <exit>
  8006e4:	00000697          	auipc	a3,0x0
  8006e8:	34c68693          	addi	a3,a3,844 # 800a30 <main+0x394>
  8006ec:	00000617          	auipc	a2,0x0
  8006f0:	31460613          	addi	a2,a2,788 # 800a00 <main+0x364>
  8006f4:	45b9                	li	a1,14
  8006f6:	00000517          	auipc	a0,0x0
  8006fa:	32250513          	addi	a0,a0,802 # 800a18 <main+0x37c>
  8006fe:	923ff0ef          	jal	800020 <__panic>
  800702:	00000697          	auipc	a3,0x0
  800706:	2f668693          	addi	a3,a3,758 # 8009f8 <main+0x35c>
  80070a:	00000617          	auipc	a2,0x0
  80070e:	2f660613          	addi	a2,a2,758 # 800a00 <main+0x364>
  800712:	45ad                	li	a1,11
  800714:	00000517          	auipc	a0,0x0
  800718:	30450513          	addi	a0,a0,772 # 800a18 <main+0x37c>
  80071c:	905ff0ef          	jal	800020 <__panic>
