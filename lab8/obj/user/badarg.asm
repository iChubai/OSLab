
obj/__user_badarg.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	77250513          	addi	a0,a0,1906 # 8007a0 <main+0xee>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	158000ef          	jal	80019c <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	12a000ef          	jal	800176 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	77050513          	addi	a0,a0,1904 # 8007c0 <main+0x10e>
  800058:	144000ef          	jal	80019c <cprintf>
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
  800074:	75850513          	addi	a0,a0,1880 # 8007c8 <main+0x116>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	116000ef          	jal	80019c <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0e8000ef          	jal	800176 <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	72e50513          	addi	a0,a0,1838 # 8007c0 <main+0x10e>
  80009a:	102000ef          	jal	80019c <cprintf>
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

00000000008000ea <sys_wait>:
  8000ea:	862e                	mv	a2,a1
  8000ec:	85aa                	mv	a1,a0
  8000ee:	450d                	li	a0,3
  8000f0:	bf5d                	j	8000a6 <syscall>

00000000008000f2 <sys_yield>:
  8000f2:	4529                	li	a0,10
  8000f4:	bf4d                	j	8000a6 <syscall>

00000000008000f6 <sys_putc>:
  8000f6:	85aa                	mv	a1,a0
  8000f8:	4579                	li	a0,30
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
  800124:	6c850513          	addi	a0,a0,1736 # 8007e8 <main+0x136>
  800128:	074000ef          	jal	80019c <cprintf>
  80012c:	a001                	j	80012c <exit+0x14>

000000000080012e <fork>:
  80012e:	bf65                	j	8000e6 <sys_fork>

0000000000800130 <waitpid>:
  800130:	cd89                	beqz	a1,80014a <waitpid+0x1a>
  800132:	7179                	addi	sp,sp,-48
  800134:	e42e                	sd	a1,8(sp)
  800136:	082c                	addi	a1,sp,24
  800138:	f406                	sd	ra,40(sp)
  80013a:	fb1ff0ef          	jal	8000ea <sys_wait>
  80013e:	6762                	ld	a4,24(sp)
  800140:	67a2                	ld	a5,8(sp)
  800142:	70a2                	ld	ra,40(sp)
  800144:	c398                	sw	a4,0(a5)
  800146:	6145                	addi	sp,sp,48
  800148:	8082                	ret
  80014a:	b745                	j	8000ea <sys_wait>

000000000080014c <yield>:
  80014c:	b75d                	j	8000f2 <sys_yield>

000000000080014e <_start>:
  80014e:	0ca000ef          	jal	800218 <umain>
  800152:	a001                	j	800152 <_start+0x4>

0000000000800154 <open>:
  800154:	1582                	slli	a1,a1,0x20
  800156:	9181                	srli	a1,a1,0x20
  800158:	b755                	j	8000fc <sys_open>

000000000080015a <close>:
  80015a:	b775                	j	800106 <sys_close>

000000000080015c <dup2>:
  80015c:	bf4d                	j	80010e <sys_dup>

000000000080015e <cputch>:
  80015e:	1101                	addi	sp,sp,-32
  800160:	ec06                	sd	ra,24(sp)
  800162:	e42e                	sd	a1,8(sp)
  800164:	f93ff0ef          	jal	8000f6 <sys_putc>
  800168:	65a2                	ld	a1,8(sp)
  80016a:	60e2                	ld	ra,24(sp)
  80016c:	419c                	lw	a5,0(a1)
  80016e:	2785                	addiw	a5,a5,1
  800170:	c19c                	sw	a5,0(a1)
  800172:	6105                	addi	sp,sp,32
  800174:	8082                	ret

0000000000800176 <vcprintf>:
  800176:	1101                	addi	sp,sp,-32
  800178:	872e                	mv	a4,a1
  80017a:	75dd                	lui	a1,0xffff7
  80017c:	86aa                	mv	a3,a0
  80017e:	0070                	addi	a2,sp,12
  800180:	00000517          	auipc	a0,0x0
  800184:	fde50513          	addi	a0,a0,-34 # 80015e <cputch>
  800188:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5e41>
  80018c:	ec06                	sd	ra,24(sp)
  80018e:	c602                	sw	zero,12(sp)
  800190:	188000ef          	jal	800318 <vprintfmt>
  800194:	60e2                	ld	ra,24(sp)
  800196:	4532                	lw	a0,12(sp)
  800198:	6105                	addi	sp,sp,32
  80019a:	8082                	ret

000000000080019c <cprintf>:
  80019c:	711d                	addi	sp,sp,-96
  80019e:	02810313          	addi	t1,sp,40
  8001a2:	f42e                	sd	a1,40(sp)
  8001a4:	75dd                	lui	a1,0xffff7
  8001a6:	f832                	sd	a2,48(sp)
  8001a8:	fc36                	sd	a3,56(sp)
  8001aa:	e0ba                	sd	a4,64(sp)
  8001ac:	86aa                	mv	a3,a0
  8001ae:	0050                	addi	a2,sp,4
  8001b0:	00000517          	auipc	a0,0x0
  8001b4:	fae50513          	addi	a0,a0,-82 # 80015e <cputch>
  8001b8:	871a                	mv	a4,t1
  8001ba:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5e41>
  8001be:	ec06                	sd	ra,24(sp)
  8001c0:	e4be                	sd	a5,72(sp)
  8001c2:	e8c2                	sd	a6,80(sp)
  8001c4:	ecc6                	sd	a7,88(sp)
  8001c6:	c202                	sw	zero,4(sp)
  8001c8:	e41a                	sd	t1,8(sp)
  8001ca:	14e000ef          	jal	800318 <vprintfmt>
  8001ce:	60e2                	ld	ra,24(sp)
  8001d0:	4512                	lw	a0,4(sp)
  8001d2:	6125                	addi	sp,sp,96
  8001d4:	8082                	ret

00000000008001d6 <initfd>:
  8001d6:	87ae                	mv	a5,a1
  8001d8:	1101                	addi	sp,sp,-32
  8001da:	e822                	sd	s0,16(sp)
  8001dc:	85b2                	mv	a1,a2
  8001de:	842a                	mv	s0,a0
  8001e0:	853e                	mv	a0,a5
  8001e2:	ec06                	sd	ra,24(sp)
  8001e4:	f71ff0ef          	jal	800154 <open>
  8001e8:	87aa                	mv	a5,a0
  8001ea:	00054463          	bltz	a0,8001f2 <initfd+0x1c>
  8001ee:	00851763          	bne	a0,s0,8001fc <initfd+0x26>
  8001f2:	60e2                	ld	ra,24(sp)
  8001f4:	6442                	ld	s0,16(sp)
  8001f6:	853e                	mv	a0,a5
  8001f8:	6105                	addi	sp,sp,32
  8001fa:	8082                	ret
  8001fc:	e42a                	sd	a0,8(sp)
  8001fe:	8522                	mv	a0,s0
  800200:	f5bff0ef          	jal	80015a <close>
  800204:	6522                	ld	a0,8(sp)
  800206:	85a2                	mv	a1,s0
  800208:	f55ff0ef          	jal	80015c <dup2>
  80020c:	842a                	mv	s0,a0
  80020e:	6522                	ld	a0,8(sp)
  800210:	f4bff0ef          	jal	80015a <close>
  800214:	87a2                	mv	a5,s0
  800216:	bff1                	j	8001f2 <initfd+0x1c>

0000000000800218 <umain>:
  800218:	1101                	addi	sp,sp,-32
  80021a:	e822                	sd	s0,16(sp)
  80021c:	e426                	sd	s1,8(sp)
  80021e:	842a                	mv	s0,a0
  800220:	84ae                	mv	s1,a1
  800222:	4601                	li	a2,0
  800224:	00000597          	auipc	a1,0x0
  800228:	5dc58593          	addi	a1,a1,1500 # 800800 <main+0x14e>
  80022c:	4501                	li	a0,0
  80022e:	ec06                	sd	ra,24(sp)
  800230:	fa7ff0ef          	jal	8001d6 <initfd>
  800234:	02054263          	bltz	a0,800258 <umain+0x40>
  800238:	4605                	li	a2,1
  80023a:	8532                	mv	a0,a2
  80023c:	00000597          	auipc	a1,0x0
  800240:	60458593          	addi	a1,a1,1540 # 800840 <main+0x18e>
  800244:	f93ff0ef          	jal	8001d6 <initfd>
  800248:	02054563          	bltz	a0,800272 <umain+0x5a>
  80024c:	85a6                	mv	a1,s1
  80024e:	8522                	mv	a0,s0
  800250:	462000ef          	jal	8006b2 <main>
  800254:	ec5ff0ef          	jal	800118 <exit>
  800258:	86aa                	mv	a3,a0
  80025a:	00000617          	auipc	a2,0x0
  80025e:	5ae60613          	addi	a2,a2,1454 # 800808 <main+0x156>
  800262:	45e9                	li	a1,26
  800264:	00000517          	auipc	a0,0x0
  800268:	5c450513          	addi	a0,a0,1476 # 800828 <main+0x176>
  80026c:	df7ff0ef          	jal	800062 <__warn>
  800270:	b7e1                	j	800238 <umain+0x20>
  800272:	86aa                	mv	a3,a0
  800274:	00000617          	auipc	a2,0x0
  800278:	5d460613          	addi	a2,a2,1492 # 800848 <main+0x196>
  80027c:	45f5                	li	a1,29
  80027e:	00000517          	auipc	a0,0x0
  800282:	5aa50513          	addi	a0,a0,1450 # 800828 <main+0x176>
  800286:	dddff0ef          	jal	800062 <__warn>
  80028a:	b7c9                	j	80024c <umain+0x34>

000000000080028c <strnlen>:
  80028c:	4781                	li	a5,0
  80028e:	e589                	bnez	a1,800298 <strnlen+0xc>
  800290:	a811                	j	8002a4 <strnlen+0x18>
  800292:	0785                	addi	a5,a5,1
  800294:	00f58863          	beq	a1,a5,8002a4 <strnlen+0x18>
  800298:	00f50733          	add	a4,a0,a5
  80029c:	00074703          	lbu	a4,0(a4)
  8002a0:	fb6d                	bnez	a4,800292 <strnlen+0x6>
  8002a2:	85be                	mv	a1,a5
  8002a4:	852e                	mv	a0,a1
  8002a6:	8082                	ret

00000000008002a8 <printnum>:
  8002a8:	7139                	addi	sp,sp,-64
  8002aa:	02071893          	slli	a7,a4,0x20
  8002ae:	f822                	sd	s0,48(sp)
  8002b0:	f426                	sd	s1,40(sp)
  8002b2:	f04a                	sd	s2,32(sp)
  8002b4:	ec4e                	sd	s3,24(sp)
  8002b6:	e456                	sd	s5,8(sp)
  8002b8:	0208d893          	srli	a7,a7,0x20
  8002bc:	fc06                	sd	ra,56(sp)
  8002be:	0316fab3          	remu	s5,a3,a7
  8002c2:	fff7841b          	addiw	s0,a5,-1
  8002c6:	84aa                	mv	s1,a0
  8002c8:	89ae                	mv	s3,a1
  8002ca:	8932                	mv	s2,a2
  8002cc:	0516f063          	bgeu	a3,a7,80030c <printnum+0x64>
  8002d0:	e852                	sd	s4,16(sp)
  8002d2:	4705                	li	a4,1
  8002d4:	8a42                	mv	s4,a6
  8002d6:	00f75863          	bge	a4,a5,8002e6 <printnum+0x3e>
  8002da:	864e                	mv	a2,s3
  8002dc:	85ca                	mv	a1,s2
  8002de:	8552                	mv	a0,s4
  8002e0:	347d                	addiw	s0,s0,-1
  8002e2:	9482                	jalr	s1
  8002e4:	f87d                	bnez	s0,8002da <printnum+0x32>
  8002e6:	6a42                	ld	s4,16(sp)
  8002e8:	00000797          	auipc	a5,0x0
  8002ec:	58078793          	addi	a5,a5,1408 # 800868 <main+0x1b6>
  8002f0:	97d6                	add	a5,a5,s5
  8002f2:	7442                	ld	s0,48(sp)
  8002f4:	0007c503          	lbu	a0,0(a5)
  8002f8:	70e2                	ld	ra,56(sp)
  8002fa:	6aa2                	ld	s5,8(sp)
  8002fc:	864e                	mv	a2,s3
  8002fe:	85ca                	mv	a1,s2
  800300:	69e2                	ld	s3,24(sp)
  800302:	7902                	ld	s2,32(sp)
  800304:	87a6                	mv	a5,s1
  800306:	74a2                	ld	s1,40(sp)
  800308:	6121                	addi	sp,sp,64
  80030a:	8782                	jr	a5
  80030c:	0316d6b3          	divu	a3,a3,a7
  800310:	87a2                	mv	a5,s0
  800312:	f97ff0ef          	jal	8002a8 <printnum>
  800316:	bfc9                	j	8002e8 <printnum+0x40>

0000000000800318 <vprintfmt>:
  800318:	7119                	addi	sp,sp,-128
  80031a:	f4a6                	sd	s1,104(sp)
  80031c:	f0ca                	sd	s2,96(sp)
  80031e:	ecce                	sd	s3,88(sp)
  800320:	e8d2                	sd	s4,80(sp)
  800322:	e4d6                	sd	s5,72(sp)
  800324:	e0da                	sd	s6,64(sp)
  800326:	fc5e                	sd	s7,56(sp)
  800328:	f466                	sd	s9,40(sp)
  80032a:	fc86                	sd	ra,120(sp)
  80032c:	f8a2                	sd	s0,112(sp)
  80032e:	f862                	sd	s8,48(sp)
  800330:	f06a                	sd	s10,32(sp)
  800332:	ec6e                	sd	s11,24(sp)
  800334:	84aa                	mv	s1,a0
  800336:	8cb6                	mv	s9,a3
  800338:	8aba                	mv	s5,a4
  80033a:	89ae                	mv	s3,a1
  80033c:	8932                	mv	s2,a2
  80033e:	02500a13          	li	s4,37
  800342:	05500b93          	li	s7,85
  800346:	00000b17          	auipc	s6,0x0
  80034a:	7fab0b13          	addi	s6,s6,2042 # 800b40 <main+0x48e>
  80034e:	000cc503          	lbu	a0,0(s9)
  800352:	001c8413          	addi	s0,s9,1
  800356:	01450b63          	beq	a0,s4,80036c <vprintfmt+0x54>
  80035a:	cd15                	beqz	a0,800396 <vprintfmt+0x7e>
  80035c:	864e                	mv	a2,s3
  80035e:	85ca                	mv	a1,s2
  800360:	9482                	jalr	s1
  800362:	00044503          	lbu	a0,0(s0)
  800366:	0405                	addi	s0,s0,1
  800368:	ff4519e3          	bne	a0,s4,80035a <vprintfmt+0x42>
  80036c:	5d7d                	li	s10,-1
  80036e:	8dea                	mv	s11,s10
  800370:	02000813          	li	a6,32
  800374:	4c01                	li	s8,0
  800376:	4581                	li	a1,0
  800378:	00044703          	lbu	a4,0(s0)
  80037c:	00140c93          	addi	s9,s0,1
  800380:	fdd7061b          	addiw	a2,a4,-35
  800384:	0ff67613          	zext.b	a2,a2
  800388:	02cbe663          	bltu	s7,a2,8003b4 <vprintfmt+0x9c>
  80038c:	060a                	slli	a2,a2,0x2
  80038e:	965a                	add	a2,a2,s6
  800390:	421c                	lw	a5,0(a2)
  800392:	97da                	add	a5,a5,s6
  800394:	8782                	jr	a5
  800396:	70e6                	ld	ra,120(sp)
  800398:	7446                	ld	s0,112(sp)
  80039a:	74a6                	ld	s1,104(sp)
  80039c:	7906                	ld	s2,96(sp)
  80039e:	69e6                	ld	s3,88(sp)
  8003a0:	6a46                	ld	s4,80(sp)
  8003a2:	6aa6                	ld	s5,72(sp)
  8003a4:	6b06                	ld	s6,64(sp)
  8003a6:	7be2                	ld	s7,56(sp)
  8003a8:	7c42                	ld	s8,48(sp)
  8003aa:	7ca2                	ld	s9,40(sp)
  8003ac:	7d02                	ld	s10,32(sp)
  8003ae:	6de2                	ld	s11,24(sp)
  8003b0:	6109                	addi	sp,sp,128
  8003b2:	8082                	ret
  8003b4:	864e                	mv	a2,s3
  8003b6:	85ca                	mv	a1,s2
  8003b8:	02500513          	li	a0,37
  8003bc:	9482                	jalr	s1
  8003be:	fff44783          	lbu	a5,-1(s0)
  8003c2:	02500713          	li	a4,37
  8003c6:	8ca2                	mv	s9,s0
  8003c8:	f8e783e3          	beq	a5,a4,80034e <vprintfmt+0x36>
  8003cc:	ffecc783          	lbu	a5,-2(s9)
  8003d0:	1cfd                	addi	s9,s9,-1
  8003d2:	fee79de3          	bne	a5,a4,8003cc <vprintfmt+0xb4>
  8003d6:	bfa5                	j	80034e <vprintfmt+0x36>
  8003d8:	00144683          	lbu	a3,1(s0)
  8003dc:	4525                	li	a0,9
  8003de:	fd070d1b          	addiw	s10,a4,-48
  8003e2:	fd06879b          	addiw	a5,a3,-48
  8003e6:	28f56063          	bltu	a0,a5,800666 <vprintfmt+0x34e>
  8003ea:	2681                	sext.w	a3,a3
  8003ec:	8466                	mv	s0,s9
  8003ee:	002d179b          	slliw	a5,s10,0x2
  8003f2:	00144703          	lbu	a4,1(s0)
  8003f6:	01a787bb          	addw	a5,a5,s10
  8003fa:	0017979b          	slliw	a5,a5,0x1
  8003fe:	9fb5                	addw	a5,a5,a3
  800400:	fd07061b          	addiw	a2,a4,-48
  800404:	0405                	addi	s0,s0,1
  800406:	fd078d1b          	addiw	s10,a5,-48
  80040a:	0007069b          	sext.w	a3,a4
  80040e:	fec570e3          	bgeu	a0,a2,8003ee <vprintfmt+0xd6>
  800412:	f60dd3e3          	bgez	s11,800378 <vprintfmt+0x60>
  800416:	8dea                	mv	s11,s10
  800418:	5d7d                	li	s10,-1
  80041a:	bfb9                	j	800378 <vprintfmt+0x60>
  80041c:	883a                	mv	a6,a4
  80041e:	8466                	mv	s0,s9
  800420:	bfa1                	j	800378 <vprintfmt+0x60>
  800422:	8466                	mv	s0,s9
  800424:	4c05                	li	s8,1
  800426:	bf89                	j	800378 <vprintfmt+0x60>
  800428:	4785                	li	a5,1
  80042a:	008a8613          	addi	a2,s5,8
  80042e:	00b7c463          	blt	a5,a1,800436 <vprintfmt+0x11e>
  800432:	1c058363          	beqz	a1,8005f8 <vprintfmt+0x2e0>
  800436:	000ab683          	ld	a3,0(s5)
  80043a:	4741                	li	a4,16
  80043c:	8ab2                	mv	s5,a2
  80043e:	2801                	sext.w	a6,a6
  800440:	87ee                	mv	a5,s11
  800442:	864a                	mv	a2,s2
  800444:	85ce                	mv	a1,s3
  800446:	8526                	mv	a0,s1
  800448:	e61ff0ef          	jal	8002a8 <printnum>
  80044c:	b709                	j	80034e <vprintfmt+0x36>
  80044e:	000aa503          	lw	a0,0(s5)
  800452:	864e                	mv	a2,s3
  800454:	85ca                	mv	a1,s2
  800456:	9482                	jalr	s1
  800458:	0aa1                	addi	s5,s5,8
  80045a:	bdd5                	j	80034e <vprintfmt+0x36>
  80045c:	4785                	li	a5,1
  80045e:	008a8613          	addi	a2,s5,8
  800462:	00b7c463          	blt	a5,a1,80046a <vprintfmt+0x152>
  800466:	18058463          	beqz	a1,8005ee <vprintfmt+0x2d6>
  80046a:	000ab683          	ld	a3,0(s5)
  80046e:	4729                	li	a4,10
  800470:	8ab2                	mv	s5,a2
  800472:	b7f1                	j	80043e <vprintfmt+0x126>
  800474:	864e                	mv	a2,s3
  800476:	85ca                	mv	a1,s2
  800478:	03000513          	li	a0,48
  80047c:	e042                	sd	a6,0(sp)
  80047e:	9482                	jalr	s1
  800480:	864e                	mv	a2,s3
  800482:	85ca                	mv	a1,s2
  800484:	07800513          	li	a0,120
  800488:	9482                	jalr	s1
  80048a:	000ab683          	ld	a3,0(s5)
  80048e:	6802                	ld	a6,0(sp)
  800490:	4741                	li	a4,16
  800492:	0aa1                	addi	s5,s5,8
  800494:	b76d                	j	80043e <vprintfmt+0x126>
  800496:	864e                	mv	a2,s3
  800498:	85ca                	mv	a1,s2
  80049a:	02500513          	li	a0,37
  80049e:	9482                	jalr	s1
  8004a0:	b57d                	j	80034e <vprintfmt+0x36>
  8004a2:	000aad03          	lw	s10,0(s5)
  8004a6:	8466                	mv	s0,s9
  8004a8:	0aa1                	addi	s5,s5,8
  8004aa:	b7a5                	j	800412 <vprintfmt+0xfa>
  8004ac:	4785                	li	a5,1
  8004ae:	008a8613          	addi	a2,s5,8
  8004b2:	00b7c463          	blt	a5,a1,8004ba <vprintfmt+0x1a2>
  8004b6:	12058763          	beqz	a1,8005e4 <vprintfmt+0x2cc>
  8004ba:	000ab683          	ld	a3,0(s5)
  8004be:	4721                	li	a4,8
  8004c0:	8ab2                	mv	s5,a2
  8004c2:	bfb5                	j	80043e <vprintfmt+0x126>
  8004c4:	87ee                	mv	a5,s11
  8004c6:	000dd363          	bgez	s11,8004cc <vprintfmt+0x1b4>
  8004ca:	4781                	li	a5,0
  8004cc:	00078d9b          	sext.w	s11,a5
  8004d0:	8466                	mv	s0,s9
  8004d2:	b55d                	j	800378 <vprintfmt+0x60>
  8004d4:	0008041b          	sext.w	s0,a6
  8004d8:	fd340793          	addi	a5,s0,-45
  8004dc:	01b02733          	sgtz	a4,s11
  8004e0:	00f037b3          	snez	a5,a5
  8004e4:	8ff9                	and	a5,a5,a4
  8004e6:	000ab703          	ld	a4,0(s5)
  8004ea:	008a8693          	addi	a3,s5,8
  8004ee:	e436                	sd	a3,8(sp)
  8004f0:	12070563          	beqz	a4,80061a <vprintfmt+0x302>
  8004f4:	12079d63          	bnez	a5,80062e <vprintfmt+0x316>
  8004f8:	00074783          	lbu	a5,0(a4)
  8004fc:	0007851b          	sext.w	a0,a5
  800500:	c78d                	beqz	a5,80052a <vprintfmt+0x212>
  800502:	00170a93          	addi	s5,a4,1
  800506:	547d                	li	s0,-1
  800508:	000d4563          	bltz	s10,800512 <vprintfmt+0x1fa>
  80050c:	3d7d                	addiw	s10,s10,-1
  80050e:	008d0e63          	beq	s10,s0,80052a <vprintfmt+0x212>
  800512:	020c1863          	bnez	s8,800542 <vprintfmt+0x22a>
  800516:	864e                	mv	a2,s3
  800518:	85ca                	mv	a1,s2
  80051a:	9482                	jalr	s1
  80051c:	000ac783          	lbu	a5,0(s5)
  800520:	0a85                	addi	s5,s5,1
  800522:	3dfd                	addiw	s11,s11,-1
  800524:	0007851b          	sext.w	a0,a5
  800528:	f3e5                	bnez	a5,800508 <vprintfmt+0x1f0>
  80052a:	01b05a63          	blez	s11,80053e <vprintfmt+0x226>
  80052e:	864e                	mv	a2,s3
  800530:	85ca                	mv	a1,s2
  800532:	02000513          	li	a0,32
  800536:	3dfd                	addiw	s11,s11,-1
  800538:	9482                	jalr	s1
  80053a:	fe0d9ae3          	bnez	s11,80052e <vprintfmt+0x216>
  80053e:	6aa2                	ld	s5,8(sp)
  800540:	b539                	j	80034e <vprintfmt+0x36>
  800542:	3781                	addiw	a5,a5,-32
  800544:	05e00713          	li	a4,94
  800548:	fcf777e3          	bgeu	a4,a5,800516 <vprintfmt+0x1fe>
  80054c:	03f00513          	li	a0,63
  800550:	864e                	mv	a2,s3
  800552:	85ca                	mv	a1,s2
  800554:	9482                	jalr	s1
  800556:	000ac783          	lbu	a5,0(s5)
  80055a:	0a85                	addi	s5,s5,1
  80055c:	3dfd                	addiw	s11,s11,-1
  80055e:	0007851b          	sext.w	a0,a5
  800562:	d7e1                	beqz	a5,80052a <vprintfmt+0x212>
  800564:	fa0d54e3          	bgez	s10,80050c <vprintfmt+0x1f4>
  800568:	bfe9                	j	800542 <vprintfmt+0x22a>
  80056a:	000aa783          	lw	a5,0(s5)
  80056e:	46e1                	li	a3,24
  800570:	0aa1                	addi	s5,s5,8
  800572:	41f7d71b          	sraiw	a4,a5,0x1f
  800576:	8fb9                	xor	a5,a5,a4
  800578:	40e7873b          	subw	a4,a5,a4
  80057c:	02e6c663          	blt	a3,a4,8005a8 <vprintfmt+0x290>
  800580:	00000797          	auipc	a5,0x0
  800584:	71878793          	addi	a5,a5,1816 # 800c98 <error_string>
  800588:	00371693          	slli	a3,a4,0x3
  80058c:	97b6                	add	a5,a5,a3
  80058e:	639c                	ld	a5,0(a5)
  800590:	cf81                	beqz	a5,8005a8 <vprintfmt+0x290>
  800592:	873e                	mv	a4,a5
  800594:	00000697          	auipc	a3,0x0
  800598:	30468693          	addi	a3,a3,772 # 800898 <main+0x1e6>
  80059c:	864a                	mv	a2,s2
  80059e:	85ce                	mv	a1,s3
  8005a0:	8526                	mv	a0,s1
  8005a2:	0f2000ef          	jal	800694 <printfmt>
  8005a6:	b365                	j	80034e <vprintfmt+0x36>
  8005a8:	00000697          	auipc	a3,0x0
  8005ac:	2e068693          	addi	a3,a3,736 # 800888 <main+0x1d6>
  8005b0:	864a                	mv	a2,s2
  8005b2:	85ce                	mv	a1,s3
  8005b4:	8526                	mv	a0,s1
  8005b6:	0de000ef          	jal	800694 <printfmt>
  8005ba:	bb51                	j	80034e <vprintfmt+0x36>
  8005bc:	4785                	li	a5,1
  8005be:	008a8c13          	addi	s8,s5,8
  8005c2:	00b7c363          	blt	a5,a1,8005c8 <vprintfmt+0x2b0>
  8005c6:	cd81                	beqz	a1,8005de <vprintfmt+0x2c6>
  8005c8:	000ab403          	ld	s0,0(s5)
  8005cc:	02044b63          	bltz	s0,800602 <vprintfmt+0x2ea>
  8005d0:	86a2                	mv	a3,s0
  8005d2:	8ae2                	mv	s5,s8
  8005d4:	4729                	li	a4,10
  8005d6:	b5a5                	j	80043e <vprintfmt+0x126>
  8005d8:	2585                	addiw	a1,a1,1
  8005da:	8466                	mv	s0,s9
  8005dc:	bb71                	j	800378 <vprintfmt+0x60>
  8005de:	000aa403          	lw	s0,0(s5)
  8005e2:	b7ed                	j	8005cc <vprintfmt+0x2b4>
  8005e4:	000ae683          	lwu	a3,0(s5)
  8005e8:	4721                	li	a4,8
  8005ea:	8ab2                	mv	s5,a2
  8005ec:	bd89                	j	80043e <vprintfmt+0x126>
  8005ee:	000ae683          	lwu	a3,0(s5)
  8005f2:	4729                	li	a4,10
  8005f4:	8ab2                	mv	s5,a2
  8005f6:	b5a1                	j	80043e <vprintfmt+0x126>
  8005f8:	000ae683          	lwu	a3,0(s5)
  8005fc:	4741                	li	a4,16
  8005fe:	8ab2                	mv	s5,a2
  800600:	bd3d                	j	80043e <vprintfmt+0x126>
  800602:	864e                	mv	a2,s3
  800604:	85ca                	mv	a1,s2
  800606:	02d00513          	li	a0,45
  80060a:	e042                	sd	a6,0(sp)
  80060c:	9482                	jalr	s1
  80060e:	6802                	ld	a6,0(sp)
  800610:	408006b3          	neg	a3,s0
  800614:	8ae2                	mv	s5,s8
  800616:	4729                	li	a4,10
  800618:	b51d                	j	80043e <vprintfmt+0x126>
  80061a:	eba1                	bnez	a5,80066a <vprintfmt+0x352>
  80061c:	02800793          	li	a5,40
  800620:	853e                	mv	a0,a5
  800622:	00000a97          	auipc	s5,0x0
  800626:	25fa8a93          	addi	s5,s5,607 # 800881 <main+0x1cf>
  80062a:	547d                	li	s0,-1
  80062c:	bdf1                	j	800508 <vprintfmt+0x1f0>
  80062e:	853a                	mv	a0,a4
  800630:	85ea                	mv	a1,s10
  800632:	e03a                	sd	a4,0(sp)
  800634:	c59ff0ef          	jal	80028c <strnlen>
  800638:	40ad8dbb          	subw	s11,s11,a0
  80063c:	6702                	ld	a4,0(sp)
  80063e:	01b05b63          	blez	s11,800654 <vprintfmt+0x33c>
  800642:	864e                	mv	a2,s3
  800644:	85ca                	mv	a1,s2
  800646:	8522                	mv	a0,s0
  800648:	e03a                	sd	a4,0(sp)
  80064a:	3dfd                	addiw	s11,s11,-1
  80064c:	9482                	jalr	s1
  80064e:	6702                	ld	a4,0(sp)
  800650:	fe0d99e3          	bnez	s11,800642 <vprintfmt+0x32a>
  800654:	00074783          	lbu	a5,0(a4)
  800658:	0007851b          	sext.w	a0,a5
  80065c:	ee0781e3          	beqz	a5,80053e <vprintfmt+0x226>
  800660:	00170a93          	addi	s5,a4,1
  800664:	b54d                	j	800506 <vprintfmt+0x1ee>
  800666:	8466                	mv	s0,s9
  800668:	b36d                	j	800412 <vprintfmt+0xfa>
  80066a:	85ea                	mv	a1,s10
  80066c:	00000517          	auipc	a0,0x0
  800670:	21450513          	addi	a0,a0,532 # 800880 <main+0x1ce>
  800674:	c19ff0ef          	jal	80028c <strnlen>
  800678:	40ad8dbb          	subw	s11,s11,a0
  80067c:	02800793          	li	a5,40
  800680:	00000717          	auipc	a4,0x0
  800684:	20070713          	addi	a4,a4,512 # 800880 <main+0x1ce>
  800688:	853e                	mv	a0,a5
  80068a:	fbb04ce3          	bgtz	s11,800642 <vprintfmt+0x32a>
  80068e:	00170a93          	addi	s5,a4,1
  800692:	bd95                	j	800506 <vprintfmt+0x1ee>

0000000000800694 <printfmt>:
  800694:	7139                	addi	sp,sp,-64
  800696:	02010313          	addi	t1,sp,32
  80069a:	f03a                	sd	a4,32(sp)
  80069c:	871a                	mv	a4,t1
  80069e:	ec06                	sd	ra,24(sp)
  8006a0:	f43e                	sd	a5,40(sp)
  8006a2:	f842                	sd	a6,48(sp)
  8006a4:	fc46                	sd	a7,56(sp)
  8006a6:	e41a                	sd	t1,8(sp)
  8006a8:	c71ff0ef          	jal	800318 <vprintfmt>
  8006ac:	60e2                	ld	ra,24(sp)
  8006ae:	6121                	addi	sp,sp,64
  8006b0:	8082                	ret

00000000008006b2 <main>:
  8006b2:	1101                	addi	sp,sp,-32
  8006b4:	ec06                	sd	ra,24(sp)
  8006b6:	e822                	sd	s0,16(sp)
  8006b8:	a77ff0ef          	jal	80012e <fork>
  8006bc:	c169                	beqz	a0,80077e <main+0xcc>
  8006be:	842a                	mv	s0,a0
  8006c0:	0aa05063          	blez	a0,800760 <main+0xae>
  8006c4:	4581                	li	a1,0
  8006c6:	557d                	li	a0,-1
  8006c8:	a69ff0ef          	jal	800130 <waitpid>
  8006cc:	c93d                	beqz	a0,800742 <main+0x90>
  8006ce:	458d                	li	a1,3
  8006d0:	05fa                	slli	a1,a1,0x1e
  8006d2:	8522                	mv	a0,s0
  8006d4:	a5dff0ef          	jal	800130 <waitpid>
  8006d8:	c531                	beqz	a0,800724 <main+0x72>
  8006da:	8522                	mv	a0,s0
  8006dc:	006c                	addi	a1,sp,12
  8006de:	a53ff0ef          	jal	800130 <waitpid>
  8006e2:	e115                	bnez	a0,800706 <main+0x54>
  8006e4:	4732                	lw	a4,12(sp)
  8006e6:	67b1                	lui	a5,0xc
  8006e8:	eaf78793          	addi	a5,a5,-337 # beaf <__panic-0x7f4171>
  8006ec:	00f71d63          	bne	a4,a5,800706 <main+0x54>
  8006f0:	00000517          	auipc	a0,0x0
  8006f4:	44050513          	addi	a0,a0,1088 # 800b30 <main+0x47e>
  8006f8:	aa5ff0ef          	jal	80019c <cprintf>
  8006fc:	60e2                	ld	ra,24(sp)
  8006fe:	6442                	ld	s0,16(sp)
  800700:	4501                	li	a0,0
  800702:	6105                	addi	sp,sp,32
  800704:	8082                	ret
  800706:	00000697          	auipc	a3,0x0
  80070a:	3f268693          	addi	a3,a3,1010 # 800af8 <main+0x446>
  80070e:	00000617          	auipc	a2,0x0
  800712:	38260613          	addi	a2,a2,898 # 800a90 <main+0x3de>
  800716:	45c9                	li	a1,18
  800718:	00000517          	auipc	a0,0x0
  80071c:	39050513          	addi	a0,a0,912 # 800aa8 <main+0x3f6>
  800720:	901ff0ef          	jal	800020 <__panic>
  800724:	00000697          	auipc	a3,0x0
  800728:	3ac68693          	addi	a3,a3,940 # 800ad0 <main+0x41e>
  80072c:	00000617          	auipc	a2,0x0
  800730:	36460613          	addi	a2,a2,868 # 800a90 <main+0x3de>
  800734:	45c5                	li	a1,17
  800736:	00000517          	auipc	a0,0x0
  80073a:	37250513          	addi	a0,a0,882 # 800aa8 <main+0x3f6>
  80073e:	8e3ff0ef          	jal	800020 <__panic>
  800742:	00000697          	auipc	a3,0x0
  800746:	37668693          	addi	a3,a3,886 # 800ab8 <main+0x406>
  80074a:	00000617          	auipc	a2,0x0
  80074e:	34660613          	addi	a2,a2,838 # 800a90 <main+0x3de>
  800752:	45c1                	li	a1,16
  800754:	00000517          	auipc	a0,0x0
  800758:	35450513          	addi	a0,a0,852 # 800aa8 <main+0x3f6>
  80075c:	8c5ff0ef          	jal	800020 <__panic>
  800760:	00000697          	auipc	a3,0x0
  800764:	32868693          	addi	a3,a3,808 # 800a88 <main+0x3d6>
  800768:	00000617          	auipc	a2,0x0
  80076c:	32860613          	addi	a2,a2,808 # 800a90 <main+0x3de>
  800770:	45bd                	li	a1,15
  800772:	00000517          	auipc	a0,0x0
  800776:	33650513          	addi	a0,a0,822 # 800aa8 <main+0x3f6>
  80077a:	8a7ff0ef          	jal	800020 <__panic>
  80077e:	00000517          	auipc	a0,0x0
  800782:	2fa50513          	addi	a0,a0,762 # 800a78 <main+0x3c6>
  800786:	a17ff0ef          	jal	80019c <cprintf>
  80078a:	4429                	li	s0,10
  80078c:	347d                	addiw	s0,s0,-1
  80078e:	9bfff0ef          	jal	80014c <yield>
  800792:	fc6d                	bnez	s0,80078c <main+0xda>
  800794:	6531                	lui	a0,0xc
  800796:	eaf50513          	addi	a0,a0,-337 # beaf <__panic-0x7f4171>
  80079a:	97fff0ef          	jal	800118 <exit>
