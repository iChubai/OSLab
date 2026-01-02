
obj/__user_matrix.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00001517          	auipc	a0,0x1
  800032:	8d250513          	addi	a0,a0,-1838 # 800900 <main+0xc4>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	150000ef          	jal	800194 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	122000ef          	jal	80016e <vcprintf>
  800050:	00001517          	auipc	a0,0x1
  800054:	8d050513          	addi	a0,a0,-1840 # 800920 <main+0xe4>
  800058:	13c000ef          	jal	800194 <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0c4000ef          	jal	800122 <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00001517          	auipc	a0,0x1
  800074:	8b850513          	addi	a0,a0,-1864 # 800928 <main+0xec>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	10e000ef          	jal	800194 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0e0000ef          	jal	80016e <vcprintf>
  800092:	00001517          	auipc	a0,0x1
  800096:	88e50513          	addi	a0,a0,-1906 # 800920 <main+0xe4>
  80009a:	0fa000ef          	jal	800194 <cprintf>
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

00000000008000f6 <sys_kill>:
  8000f6:	85aa                	mv	a1,a0
  8000f8:	4531                	li	a0,12
  8000fa:	b775                	j	8000a6 <syscall>

00000000008000fc <sys_getpid>:
  8000fc:	4549                	li	a0,18
  8000fe:	b765                	j	8000a6 <syscall>

0000000000800100 <sys_putc>:
  800100:	85aa                	mv	a1,a0
  800102:	4579                	li	a0,30
  800104:	b74d                	j	8000a6 <syscall>

0000000000800106 <sys_open>:
  800106:	862e                	mv	a2,a1
  800108:	85aa                	mv	a1,a0
  80010a:	06400513          	li	a0,100
  80010e:	bf61                	j	8000a6 <syscall>

0000000000800110 <sys_close>:
  800110:	85aa                	mv	a1,a0
  800112:	06500513          	li	a0,101
  800116:	bf41                	j	8000a6 <syscall>

0000000000800118 <sys_dup>:
  800118:	862e                	mv	a2,a1
  80011a:	85aa                	mv	a1,a0
  80011c:	08200513          	li	a0,130
  800120:	b759                	j	8000a6 <syscall>

0000000000800122 <exit>:
  800122:	1141                	addi	sp,sp,-16
  800124:	e406                	sd	ra,8(sp)
  800126:	fbbff0ef          	jal	8000e0 <sys_exit>
  80012a:	00001517          	auipc	a0,0x1
  80012e:	81e50513          	addi	a0,a0,-2018 # 800948 <main+0x10c>
  800132:	062000ef          	jal	800194 <cprintf>
  800136:	a001                	j	800136 <exit+0x14>

0000000000800138 <fork>:
  800138:	b77d                	j	8000e6 <sys_fork>

000000000080013a <wait>:
  80013a:	4581                	li	a1,0
  80013c:	4501                	li	a0,0
  80013e:	b775                	j	8000ea <sys_wait>

0000000000800140 <yield>:
  800140:	bf4d                	j	8000f2 <sys_yield>

0000000000800142 <kill>:
  800142:	bf55                	j	8000f6 <sys_kill>

0000000000800144 <getpid>:
  800144:	bf65                	j	8000fc <sys_getpid>

0000000000800146 <_start>:
  800146:	0ca000ef          	jal	800210 <umain>
  80014a:	a001                	j	80014a <_start+0x4>

000000000080014c <open>:
  80014c:	1582                	slli	a1,a1,0x20
  80014e:	9181                	srli	a1,a1,0x20
  800150:	bf5d                	j	800106 <sys_open>

0000000000800152 <close>:
  800152:	bf7d                	j	800110 <sys_close>

0000000000800154 <dup2>:
  800154:	b7d1                	j	800118 <sys_dup>

0000000000800156 <cputch>:
  800156:	1101                	addi	sp,sp,-32
  800158:	ec06                	sd	ra,24(sp)
  80015a:	e42e                	sd	a1,8(sp)
  80015c:	fa5ff0ef          	jal	800100 <sys_putc>
  800160:	65a2                	ld	a1,8(sp)
  800162:	60e2                	ld	ra,24(sp)
  800164:	419c                	lw	a5,0(a1)
  800166:	2785                	addiw	a5,a5,1
  800168:	c19c                	sw	a5,0(a1)
  80016a:	6105                	addi	sp,sp,32
  80016c:	8082                	ret

000000000080016e <vcprintf>:
  80016e:	1101                	addi	sp,sp,-32
  800170:	872e                	mv	a4,a1
  800172:	75dd                	lui	a1,0xffff7
  800174:	86aa                	mv	a3,a0
  800176:	0070                	addi	a2,sp,12
  800178:	00000517          	auipc	a0,0x0
  80017c:	fde50513          	addi	a0,a0,-34 # 800156 <cputch>
  800180:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <mata+0xffffffffff7f57b1>
  800184:	ec06                	sd	ra,24(sp)
  800186:	c602                	sw	zero,12(sp)
  800188:	19a000ef          	jal	800322 <vprintfmt>
  80018c:	60e2                	ld	ra,24(sp)
  80018e:	4532                	lw	a0,12(sp)
  800190:	6105                	addi	sp,sp,32
  800192:	8082                	ret

0000000000800194 <cprintf>:
  800194:	711d                	addi	sp,sp,-96
  800196:	02810313          	addi	t1,sp,40
  80019a:	f42e                	sd	a1,40(sp)
  80019c:	75dd                	lui	a1,0xffff7
  80019e:	f832                	sd	a2,48(sp)
  8001a0:	fc36                	sd	a3,56(sp)
  8001a2:	e0ba                	sd	a4,64(sp)
  8001a4:	86aa                	mv	a3,a0
  8001a6:	0050                	addi	a2,sp,4
  8001a8:	00000517          	auipc	a0,0x0
  8001ac:	fae50513          	addi	a0,a0,-82 # 800156 <cputch>
  8001b0:	871a                	mv	a4,t1
  8001b2:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <mata+0xffffffffff7f57b1>
  8001b6:	ec06                	sd	ra,24(sp)
  8001b8:	e4be                	sd	a5,72(sp)
  8001ba:	e8c2                	sd	a6,80(sp)
  8001bc:	ecc6                	sd	a7,88(sp)
  8001be:	c202                	sw	zero,4(sp)
  8001c0:	e41a                	sd	t1,8(sp)
  8001c2:	160000ef          	jal	800322 <vprintfmt>
  8001c6:	60e2                	ld	ra,24(sp)
  8001c8:	4512                	lw	a0,4(sp)
  8001ca:	6125                	addi	sp,sp,96
  8001cc:	8082                	ret

00000000008001ce <initfd>:
  8001ce:	87ae                	mv	a5,a1
  8001d0:	1101                	addi	sp,sp,-32
  8001d2:	e822                	sd	s0,16(sp)
  8001d4:	85b2                	mv	a1,a2
  8001d6:	842a                	mv	s0,a0
  8001d8:	853e                	mv	a0,a5
  8001da:	ec06                	sd	ra,24(sp)
  8001dc:	f71ff0ef          	jal	80014c <open>
  8001e0:	87aa                	mv	a5,a0
  8001e2:	00054463          	bltz	a0,8001ea <initfd+0x1c>
  8001e6:	00851763          	bne	a0,s0,8001f4 <initfd+0x26>
  8001ea:	60e2                	ld	ra,24(sp)
  8001ec:	6442                	ld	s0,16(sp)
  8001ee:	853e                	mv	a0,a5
  8001f0:	6105                	addi	sp,sp,32
  8001f2:	8082                	ret
  8001f4:	e42a                	sd	a0,8(sp)
  8001f6:	8522                	mv	a0,s0
  8001f8:	f5bff0ef          	jal	800152 <close>
  8001fc:	6522                	ld	a0,8(sp)
  8001fe:	85a2                	mv	a1,s0
  800200:	f55ff0ef          	jal	800154 <dup2>
  800204:	842a                	mv	s0,a0
  800206:	6522                	ld	a0,8(sp)
  800208:	f4bff0ef          	jal	800152 <close>
  80020c:	87a2                	mv	a5,s0
  80020e:	bff1                	j	8001ea <initfd+0x1c>

0000000000800210 <umain>:
  800210:	1101                	addi	sp,sp,-32
  800212:	e822                	sd	s0,16(sp)
  800214:	e426                	sd	s1,8(sp)
  800216:	842a                	mv	s0,a0
  800218:	84ae                	mv	s1,a1
  80021a:	4601                	li	a2,0
  80021c:	00000597          	auipc	a1,0x0
  800220:	74458593          	addi	a1,a1,1860 # 800960 <main+0x124>
  800224:	4501                	li	a0,0
  800226:	ec06                	sd	ra,24(sp)
  800228:	fa7ff0ef          	jal	8001ce <initfd>
  80022c:	02054263          	bltz	a0,800250 <umain+0x40>
  800230:	4605                	li	a2,1
  800232:	8532                	mv	a0,a2
  800234:	00000597          	auipc	a1,0x0
  800238:	76c58593          	addi	a1,a1,1900 # 8009a0 <main+0x164>
  80023c:	f93ff0ef          	jal	8001ce <initfd>
  800240:	02054563          	bltz	a0,80026a <umain+0x5a>
  800244:	85a6                	mv	a1,s1
  800246:	8522                	mv	a0,s0
  800248:	5f4000ef          	jal	80083c <main>
  80024c:	ed7ff0ef          	jal	800122 <exit>
  800250:	86aa                	mv	a3,a0
  800252:	00000617          	auipc	a2,0x0
  800256:	71660613          	addi	a2,a2,1814 # 800968 <main+0x12c>
  80025a:	45e9                	li	a1,26
  80025c:	00000517          	auipc	a0,0x0
  800260:	72c50513          	addi	a0,a0,1836 # 800988 <main+0x14c>
  800264:	dffff0ef          	jal	800062 <__warn>
  800268:	b7e1                	j	800230 <umain+0x20>
  80026a:	86aa                	mv	a3,a0
  80026c:	00000617          	auipc	a2,0x0
  800270:	73c60613          	addi	a2,a2,1852 # 8009a8 <main+0x16c>
  800274:	45f5                	li	a1,29
  800276:	00000517          	auipc	a0,0x0
  80027a:	71250513          	addi	a0,a0,1810 # 800988 <main+0x14c>
  80027e:	de5ff0ef          	jal	800062 <__warn>
  800282:	b7c9                	j	800244 <umain+0x34>

0000000000800284 <strnlen>:
  800284:	4781                	li	a5,0
  800286:	e589                	bnez	a1,800290 <strnlen+0xc>
  800288:	a811                	j	80029c <strnlen+0x18>
  80028a:	0785                	addi	a5,a5,1
  80028c:	00f58863          	beq	a1,a5,80029c <strnlen+0x18>
  800290:	00f50733          	add	a4,a0,a5
  800294:	00074703          	lbu	a4,0(a4)
  800298:	fb6d                	bnez	a4,80028a <strnlen+0x6>
  80029a:	85be                	mv	a1,a5
  80029c:	852e                	mv	a0,a1
  80029e:	8082                	ret

00000000008002a0 <memset>:
  8002a0:	ca01                	beqz	a2,8002b0 <memset+0x10>
  8002a2:	962a                	add	a2,a2,a0
  8002a4:	87aa                	mv	a5,a0
  8002a6:	0785                	addi	a5,a5,1
  8002a8:	feb78fa3          	sb	a1,-1(a5)
  8002ac:	fef61de3          	bne	a2,a5,8002a6 <memset+0x6>
  8002b0:	8082                	ret

00000000008002b2 <printnum>:
  8002b2:	7139                	addi	sp,sp,-64
  8002b4:	02071893          	slli	a7,a4,0x20
  8002b8:	f822                	sd	s0,48(sp)
  8002ba:	f426                	sd	s1,40(sp)
  8002bc:	f04a                	sd	s2,32(sp)
  8002be:	ec4e                	sd	s3,24(sp)
  8002c0:	e456                	sd	s5,8(sp)
  8002c2:	0208d893          	srli	a7,a7,0x20
  8002c6:	fc06                	sd	ra,56(sp)
  8002c8:	0316fab3          	remu	s5,a3,a7
  8002cc:	fff7841b          	addiw	s0,a5,-1
  8002d0:	84aa                	mv	s1,a0
  8002d2:	89ae                	mv	s3,a1
  8002d4:	8932                	mv	s2,a2
  8002d6:	0516f063          	bgeu	a3,a7,800316 <printnum+0x64>
  8002da:	e852                	sd	s4,16(sp)
  8002dc:	4705                	li	a4,1
  8002de:	8a42                	mv	s4,a6
  8002e0:	00f75863          	bge	a4,a5,8002f0 <printnum+0x3e>
  8002e4:	864e                	mv	a2,s3
  8002e6:	85ca                	mv	a1,s2
  8002e8:	8552                	mv	a0,s4
  8002ea:	347d                	addiw	s0,s0,-1
  8002ec:	9482                	jalr	s1
  8002ee:	f87d                	bnez	s0,8002e4 <printnum+0x32>
  8002f0:	6a42                	ld	s4,16(sp)
  8002f2:	00000797          	auipc	a5,0x0
  8002f6:	6d678793          	addi	a5,a5,1750 # 8009c8 <main+0x18c>
  8002fa:	97d6                	add	a5,a5,s5
  8002fc:	7442                	ld	s0,48(sp)
  8002fe:	0007c503          	lbu	a0,0(a5)
  800302:	70e2                	ld	ra,56(sp)
  800304:	6aa2                	ld	s5,8(sp)
  800306:	864e                	mv	a2,s3
  800308:	85ca                	mv	a1,s2
  80030a:	69e2                	ld	s3,24(sp)
  80030c:	7902                	ld	s2,32(sp)
  80030e:	87a6                	mv	a5,s1
  800310:	74a2                	ld	s1,40(sp)
  800312:	6121                	addi	sp,sp,64
  800314:	8782                	jr	a5
  800316:	0316d6b3          	divu	a3,a3,a7
  80031a:	87a2                	mv	a5,s0
  80031c:	f97ff0ef          	jal	8002b2 <printnum>
  800320:	bfc9                	j	8002f2 <printnum+0x40>

0000000000800322 <vprintfmt>:
  800322:	7119                	addi	sp,sp,-128
  800324:	f4a6                	sd	s1,104(sp)
  800326:	f0ca                	sd	s2,96(sp)
  800328:	ecce                	sd	s3,88(sp)
  80032a:	e8d2                	sd	s4,80(sp)
  80032c:	e4d6                	sd	s5,72(sp)
  80032e:	e0da                	sd	s6,64(sp)
  800330:	fc5e                	sd	s7,56(sp)
  800332:	f466                	sd	s9,40(sp)
  800334:	fc86                	sd	ra,120(sp)
  800336:	f8a2                	sd	s0,112(sp)
  800338:	f862                	sd	s8,48(sp)
  80033a:	f06a                	sd	s10,32(sp)
  80033c:	ec6e                	sd	s11,24(sp)
  80033e:	84aa                	mv	s1,a0
  800340:	8cb6                	mv	s9,a3
  800342:	8aba                	mv	s5,a4
  800344:	89ae                	mv	s3,a1
  800346:	8932                	mv	s2,a2
  800348:	02500a13          	li	s4,37
  80034c:	05500b93          	li	s7,85
  800350:	00001b17          	auipc	s6,0x1
  800354:	908b0b13          	addi	s6,s6,-1784 # 800c58 <main+0x41c>
  800358:	000cc503          	lbu	a0,0(s9)
  80035c:	001c8413          	addi	s0,s9,1
  800360:	01450b63          	beq	a0,s4,800376 <vprintfmt+0x54>
  800364:	cd15                	beqz	a0,8003a0 <vprintfmt+0x7e>
  800366:	864e                	mv	a2,s3
  800368:	85ca                	mv	a1,s2
  80036a:	9482                	jalr	s1
  80036c:	00044503          	lbu	a0,0(s0)
  800370:	0405                	addi	s0,s0,1
  800372:	ff4519e3          	bne	a0,s4,800364 <vprintfmt+0x42>
  800376:	5d7d                	li	s10,-1
  800378:	8dea                	mv	s11,s10
  80037a:	02000813          	li	a6,32
  80037e:	4c01                	li	s8,0
  800380:	4581                	li	a1,0
  800382:	00044703          	lbu	a4,0(s0)
  800386:	00140c93          	addi	s9,s0,1
  80038a:	fdd7061b          	addiw	a2,a4,-35
  80038e:	0ff67613          	zext.b	a2,a2
  800392:	02cbe663          	bltu	s7,a2,8003be <vprintfmt+0x9c>
  800396:	060a                	slli	a2,a2,0x2
  800398:	965a                	add	a2,a2,s6
  80039a:	421c                	lw	a5,0(a2)
  80039c:	97da                	add	a5,a5,s6
  80039e:	8782                	jr	a5
  8003a0:	70e6                	ld	ra,120(sp)
  8003a2:	7446                	ld	s0,112(sp)
  8003a4:	74a6                	ld	s1,104(sp)
  8003a6:	7906                	ld	s2,96(sp)
  8003a8:	69e6                	ld	s3,88(sp)
  8003aa:	6a46                	ld	s4,80(sp)
  8003ac:	6aa6                	ld	s5,72(sp)
  8003ae:	6b06                	ld	s6,64(sp)
  8003b0:	7be2                	ld	s7,56(sp)
  8003b2:	7c42                	ld	s8,48(sp)
  8003b4:	7ca2                	ld	s9,40(sp)
  8003b6:	7d02                	ld	s10,32(sp)
  8003b8:	6de2                	ld	s11,24(sp)
  8003ba:	6109                	addi	sp,sp,128
  8003bc:	8082                	ret
  8003be:	864e                	mv	a2,s3
  8003c0:	85ca                	mv	a1,s2
  8003c2:	02500513          	li	a0,37
  8003c6:	9482                	jalr	s1
  8003c8:	fff44783          	lbu	a5,-1(s0)
  8003cc:	02500713          	li	a4,37
  8003d0:	8ca2                	mv	s9,s0
  8003d2:	f8e783e3          	beq	a5,a4,800358 <vprintfmt+0x36>
  8003d6:	ffecc783          	lbu	a5,-2(s9)
  8003da:	1cfd                	addi	s9,s9,-1
  8003dc:	fee79de3          	bne	a5,a4,8003d6 <vprintfmt+0xb4>
  8003e0:	bfa5                	j	800358 <vprintfmt+0x36>
  8003e2:	00144683          	lbu	a3,1(s0)
  8003e6:	4525                	li	a0,9
  8003e8:	fd070d1b          	addiw	s10,a4,-48
  8003ec:	fd06879b          	addiw	a5,a3,-48
  8003f0:	28f56063          	bltu	a0,a5,800670 <vprintfmt+0x34e>
  8003f4:	2681                	sext.w	a3,a3
  8003f6:	8466                	mv	s0,s9
  8003f8:	002d179b          	slliw	a5,s10,0x2
  8003fc:	00144703          	lbu	a4,1(s0)
  800400:	01a787bb          	addw	a5,a5,s10
  800404:	0017979b          	slliw	a5,a5,0x1
  800408:	9fb5                	addw	a5,a5,a3
  80040a:	fd07061b          	addiw	a2,a4,-48
  80040e:	0405                	addi	s0,s0,1
  800410:	fd078d1b          	addiw	s10,a5,-48
  800414:	0007069b          	sext.w	a3,a4
  800418:	fec570e3          	bgeu	a0,a2,8003f8 <vprintfmt+0xd6>
  80041c:	f60dd3e3          	bgez	s11,800382 <vprintfmt+0x60>
  800420:	8dea                	mv	s11,s10
  800422:	5d7d                	li	s10,-1
  800424:	bfb9                	j	800382 <vprintfmt+0x60>
  800426:	883a                	mv	a6,a4
  800428:	8466                	mv	s0,s9
  80042a:	bfa1                	j	800382 <vprintfmt+0x60>
  80042c:	8466                	mv	s0,s9
  80042e:	4c05                	li	s8,1
  800430:	bf89                	j	800382 <vprintfmt+0x60>
  800432:	4785                	li	a5,1
  800434:	008a8613          	addi	a2,s5,8
  800438:	00b7c463          	blt	a5,a1,800440 <vprintfmt+0x11e>
  80043c:	1c058363          	beqz	a1,800602 <vprintfmt+0x2e0>
  800440:	000ab683          	ld	a3,0(s5)
  800444:	4741                	li	a4,16
  800446:	8ab2                	mv	s5,a2
  800448:	2801                	sext.w	a6,a6
  80044a:	87ee                	mv	a5,s11
  80044c:	864a                	mv	a2,s2
  80044e:	85ce                	mv	a1,s3
  800450:	8526                	mv	a0,s1
  800452:	e61ff0ef          	jal	8002b2 <printnum>
  800456:	b709                	j	800358 <vprintfmt+0x36>
  800458:	000aa503          	lw	a0,0(s5)
  80045c:	864e                	mv	a2,s3
  80045e:	85ca                	mv	a1,s2
  800460:	9482                	jalr	s1
  800462:	0aa1                	addi	s5,s5,8
  800464:	bdd5                	j	800358 <vprintfmt+0x36>
  800466:	4785                	li	a5,1
  800468:	008a8613          	addi	a2,s5,8
  80046c:	00b7c463          	blt	a5,a1,800474 <vprintfmt+0x152>
  800470:	18058463          	beqz	a1,8005f8 <vprintfmt+0x2d6>
  800474:	000ab683          	ld	a3,0(s5)
  800478:	4729                	li	a4,10
  80047a:	8ab2                	mv	s5,a2
  80047c:	b7f1                	j	800448 <vprintfmt+0x126>
  80047e:	864e                	mv	a2,s3
  800480:	85ca                	mv	a1,s2
  800482:	03000513          	li	a0,48
  800486:	e042                	sd	a6,0(sp)
  800488:	9482                	jalr	s1
  80048a:	864e                	mv	a2,s3
  80048c:	85ca                	mv	a1,s2
  80048e:	07800513          	li	a0,120
  800492:	9482                	jalr	s1
  800494:	000ab683          	ld	a3,0(s5)
  800498:	6802                	ld	a6,0(sp)
  80049a:	4741                	li	a4,16
  80049c:	0aa1                	addi	s5,s5,8
  80049e:	b76d                	j	800448 <vprintfmt+0x126>
  8004a0:	864e                	mv	a2,s3
  8004a2:	85ca                	mv	a1,s2
  8004a4:	02500513          	li	a0,37
  8004a8:	9482                	jalr	s1
  8004aa:	b57d                	j	800358 <vprintfmt+0x36>
  8004ac:	000aad03          	lw	s10,0(s5)
  8004b0:	8466                	mv	s0,s9
  8004b2:	0aa1                	addi	s5,s5,8
  8004b4:	b7a5                	j	80041c <vprintfmt+0xfa>
  8004b6:	4785                	li	a5,1
  8004b8:	008a8613          	addi	a2,s5,8
  8004bc:	00b7c463          	blt	a5,a1,8004c4 <vprintfmt+0x1a2>
  8004c0:	12058763          	beqz	a1,8005ee <vprintfmt+0x2cc>
  8004c4:	000ab683          	ld	a3,0(s5)
  8004c8:	4721                	li	a4,8
  8004ca:	8ab2                	mv	s5,a2
  8004cc:	bfb5                	j	800448 <vprintfmt+0x126>
  8004ce:	87ee                	mv	a5,s11
  8004d0:	000dd363          	bgez	s11,8004d6 <vprintfmt+0x1b4>
  8004d4:	4781                	li	a5,0
  8004d6:	00078d9b          	sext.w	s11,a5
  8004da:	8466                	mv	s0,s9
  8004dc:	b55d                	j	800382 <vprintfmt+0x60>
  8004de:	0008041b          	sext.w	s0,a6
  8004e2:	fd340793          	addi	a5,s0,-45
  8004e6:	01b02733          	sgtz	a4,s11
  8004ea:	00f037b3          	snez	a5,a5
  8004ee:	8ff9                	and	a5,a5,a4
  8004f0:	000ab703          	ld	a4,0(s5)
  8004f4:	008a8693          	addi	a3,s5,8
  8004f8:	e436                	sd	a3,8(sp)
  8004fa:	12070563          	beqz	a4,800624 <vprintfmt+0x302>
  8004fe:	12079d63          	bnez	a5,800638 <vprintfmt+0x316>
  800502:	00074783          	lbu	a5,0(a4)
  800506:	0007851b          	sext.w	a0,a5
  80050a:	c78d                	beqz	a5,800534 <vprintfmt+0x212>
  80050c:	00170a93          	addi	s5,a4,1
  800510:	547d                	li	s0,-1
  800512:	000d4563          	bltz	s10,80051c <vprintfmt+0x1fa>
  800516:	3d7d                	addiw	s10,s10,-1
  800518:	008d0e63          	beq	s10,s0,800534 <vprintfmt+0x212>
  80051c:	020c1863          	bnez	s8,80054c <vprintfmt+0x22a>
  800520:	864e                	mv	a2,s3
  800522:	85ca                	mv	a1,s2
  800524:	9482                	jalr	s1
  800526:	000ac783          	lbu	a5,0(s5)
  80052a:	0a85                	addi	s5,s5,1
  80052c:	3dfd                	addiw	s11,s11,-1
  80052e:	0007851b          	sext.w	a0,a5
  800532:	f3e5                	bnez	a5,800512 <vprintfmt+0x1f0>
  800534:	01b05a63          	blez	s11,800548 <vprintfmt+0x226>
  800538:	864e                	mv	a2,s3
  80053a:	85ca                	mv	a1,s2
  80053c:	02000513          	li	a0,32
  800540:	3dfd                	addiw	s11,s11,-1
  800542:	9482                	jalr	s1
  800544:	fe0d9ae3          	bnez	s11,800538 <vprintfmt+0x216>
  800548:	6aa2                	ld	s5,8(sp)
  80054a:	b539                	j	800358 <vprintfmt+0x36>
  80054c:	3781                	addiw	a5,a5,-32
  80054e:	05e00713          	li	a4,94
  800552:	fcf777e3          	bgeu	a4,a5,800520 <vprintfmt+0x1fe>
  800556:	03f00513          	li	a0,63
  80055a:	864e                	mv	a2,s3
  80055c:	85ca                	mv	a1,s2
  80055e:	9482                	jalr	s1
  800560:	000ac783          	lbu	a5,0(s5)
  800564:	0a85                	addi	s5,s5,1
  800566:	3dfd                	addiw	s11,s11,-1
  800568:	0007851b          	sext.w	a0,a5
  80056c:	d7e1                	beqz	a5,800534 <vprintfmt+0x212>
  80056e:	fa0d54e3          	bgez	s10,800516 <vprintfmt+0x1f4>
  800572:	bfe9                	j	80054c <vprintfmt+0x22a>
  800574:	000aa783          	lw	a5,0(s5)
  800578:	46e1                	li	a3,24
  80057a:	0aa1                	addi	s5,s5,8
  80057c:	41f7d71b          	sraiw	a4,a5,0x1f
  800580:	8fb9                	xor	a5,a5,a4
  800582:	40e7873b          	subw	a4,a5,a4
  800586:	02e6c663          	blt	a3,a4,8005b2 <vprintfmt+0x290>
  80058a:	00001797          	auipc	a5,0x1
  80058e:	82678793          	addi	a5,a5,-2010 # 800db0 <error_string>
  800592:	00371693          	slli	a3,a4,0x3
  800596:	97b6                	add	a5,a5,a3
  800598:	639c                	ld	a5,0(a5)
  80059a:	cf81                	beqz	a5,8005b2 <vprintfmt+0x290>
  80059c:	873e                	mv	a4,a5
  80059e:	00000697          	auipc	a3,0x0
  8005a2:	45a68693          	addi	a3,a3,1114 # 8009f8 <main+0x1bc>
  8005a6:	864a                	mv	a2,s2
  8005a8:	85ce                	mv	a1,s3
  8005aa:	8526                	mv	a0,s1
  8005ac:	0f2000ef          	jal	80069e <printfmt>
  8005b0:	b365                	j	800358 <vprintfmt+0x36>
  8005b2:	00000697          	auipc	a3,0x0
  8005b6:	43668693          	addi	a3,a3,1078 # 8009e8 <main+0x1ac>
  8005ba:	864a                	mv	a2,s2
  8005bc:	85ce                	mv	a1,s3
  8005be:	8526                	mv	a0,s1
  8005c0:	0de000ef          	jal	80069e <printfmt>
  8005c4:	bb51                	j	800358 <vprintfmt+0x36>
  8005c6:	4785                	li	a5,1
  8005c8:	008a8c13          	addi	s8,s5,8
  8005cc:	00b7c363          	blt	a5,a1,8005d2 <vprintfmt+0x2b0>
  8005d0:	cd81                	beqz	a1,8005e8 <vprintfmt+0x2c6>
  8005d2:	000ab403          	ld	s0,0(s5)
  8005d6:	02044b63          	bltz	s0,80060c <vprintfmt+0x2ea>
  8005da:	86a2                	mv	a3,s0
  8005dc:	8ae2                	mv	s5,s8
  8005de:	4729                	li	a4,10
  8005e0:	b5a5                	j	800448 <vprintfmt+0x126>
  8005e2:	2585                	addiw	a1,a1,1
  8005e4:	8466                	mv	s0,s9
  8005e6:	bb71                	j	800382 <vprintfmt+0x60>
  8005e8:	000aa403          	lw	s0,0(s5)
  8005ec:	b7ed                	j	8005d6 <vprintfmt+0x2b4>
  8005ee:	000ae683          	lwu	a3,0(s5)
  8005f2:	4721                	li	a4,8
  8005f4:	8ab2                	mv	s5,a2
  8005f6:	bd89                	j	800448 <vprintfmt+0x126>
  8005f8:	000ae683          	lwu	a3,0(s5)
  8005fc:	4729                	li	a4,10
  8005fe:	8ab2                	mv	s5,a2
  800600:	b5a1                	j	800448 <vprintfmt+0x126>
  800602:	000ae683          	lwu	a3,0(s5)
  800606:	4741                	li	a4,16
  800608:	8ab2                	mv	s5,a2
  80060a:	bd3d                	j	800448 <vprintfmt+0x126>
  80060c:	864e                	mv	a2,s3
  80060e:	85ca                	mv	a1,s2
  800610:	02d00513          	li	a0,45
  800614:	e042                	sd	a6,0(sp)
  800616:	9482                	jalr	s1
  800618:	6802                	ld	a6,0(sp)
  80061a:	408006b3          	neg	a3,s0
  80061e:	8ae2                	mv	s5,s8
  800620:	4729                	li	a4,10
  800622:	b51d                	j	800448 <vprintfmt+0x126>
  800624:	eba1                	bnez	a5,800674 <vprintfmt+0x352>
  800626:	02800793          	li	a5,40
  80062a:	853e                	mv	a0,a5
  80062c:	00000a97          	auipc	s5,0x0
  800630:	3b5a8a93          	addi	s5,s5,949 # 8009e1 <main+0x1a5>
  800634:	547d                	li	s0,-1
  800636:	bdf1                	j	800512 <vprintfmt+0x1f0>
  800638:	853a                	mv	a0,a4
  80063a:	85ea                	mv	a1,s10
  80063c:	e03a                	sd	a4,0(sp)
  80063e:	c47ff0ef          	jal	800284 <strnlen>
  800642:	40ad8dbb          	subw	s11,s11,a0
  800646:	6702                	ld	a4,0(sp)
  800648:	01b05b63          	blez	s11,80065e <vprintfmt+0x33c>
  80064c:	864e                	mv	a2,s3
  80064e:	85ca                	mv	a1,s2
  800650:	8522                	mv	a0,s0
  800652:	e03a                	sd	a4,0(sp)
  800654:	3dfd                	addiw	s11,s11,-1
  800656:	9482                	jalr	s1
  800658:	6702                	ld	a4,0(sp)
  80065a:	fe0d99e3          	bnez	s11,80064c <vprintfmt+0x32a>
  80065e:	00074783          	lbu	a5,0(a4)
  800662:	0007851b          	sext.w	a0,a5
  800666:	ee0781e3          	beqz	a5,800548 <vprintfmt+0x226>
  80066a:	00170a93          	addi	s5,a4,1
  80066e:	b54d                	j	800510 <vprintfmt+0x1ee>
  800670:	8466                	mv	s0,s9
  800672:	b36d                	j	80041c <vprintfmt+0xfa>
  800674:	85ea                	mv	a1,s10
  800676:	00000517          	auipc	a0,0x0
  80067a:	36a50513          	addi	a0,a0,874 # 8009e0 <main+0x1a4>
  80067e:	c07ff0ef          	jal	800284 <strnlen>
  800682:	40ad8dbb          	subw	s11,s11,a0
  800686:	02800793          	li	a5,40
  80068a:	00000717          	auipc	a4,0x0
  80068e:	35670713          	addi	a4,a4,854 # 8009e0 <main+0x1a4>
  800692:	853e                	mv	a0,a5
  800694:	fbb04ce3          	bgtz	s11,80064c <vprintfmt+0x32a>
  800698:	00170a93          	addi	s5,a4,1
  80069c:	bd95                	j	800510 <vprintfmt+0x1ee>

000000000080069e <printfmt>:
  80069e:	7139                	addi	sp,sp,-64
  8006a0:	02010313          	addi	t1,sp,32
  8006a4:	f03a                	sd	a4,32(sp)
  8006a6:	871a                	mv	a4,t1
  8006a8:	ec06                	sd	ra,24(sp)
  8006aa:	f43e                	sd	a5,40(sp)
  8006ac:	f842                	sd	a6,48(sp)
  8006ae:	fc46                	sd	a7,56(sp)
  8006b0:	e41a                	sd	t1,8(sp)
  8006b2:	c71ff0ef          	jal	800322 <vprintfmt>
  8006b6:	60e2                	ld	ra,24(sp)
  8006b8:	6121                	addi	sp,sp,64
  8006ba:	8082                	ret

00000000008006bc <rand>:
  8006bc:	002ef7b7          	lui	a5,0x2ef
  8006c0:	00001717          	auipc	a4,0x1
  8006c4:	94073703          	ld	a4,-1728(a4) # 801000 <next>
  8006c8:	76778793          	addi	a5,a5,1895 # 2ef767 <__panic-0x5108b9>
  8006cc:	07b6                	slli	a5,a5,0xd
  8006ce:	66d78793          	addi	a5,a5,1645
  8006d2:	02f70733          	mul	a4,a4,a5
  8006d6:	4785                	li	a5,1
  8006d8:	1786                	slli	a5,a5,0x21
  8006da:	0795                	addi	a5,a5,5
  8006dc:	072d                	addi	a4,a4,11
  8006de:	0742                	slli	a4,a4,0x10
  8006e0:	8341                	srli	a4,a4,0x10
  8006e2:	00c75513          	srli	a0,a4,0xc
  8006e6:	02f537b3          	mulhu	a5,a0,a5
  8006ea:	00001697          	auipc	a3,0x1
  8006ee:	90e6bb23          	sd	a4,-1770(a3) # 801000 <next>
  8006f2:	40f50733          	sub	a4,a0,a5
  8006f6:	8305                	srli	a4,a4,0x1
  8006f8:	97ba                	add	a5,a5,a4
  8006fa:	83f9                	srli	a5,a5,0x1e
  8006fc:	01f79713          	slli	a4,a5,0x1f
  800700:	40f707b3          	sub	a5,a4,a5
  800704:	8d1d                	sub	a0,a0,a5
  800706:	2505                	addiw	a0,a0,1
  800708:	8082                	ret

000000000080070a <srand>:
  80070a:	1502                	slli	a0,a0,0x20
  80070c:	9101                	srli	a0,a0,0x20
  80070e:	00001797          	auipc	a5,0x1
  800712:	8ea7b923          	sd	a0,-1806(a5) # 801000 <next>
  800716:	8082                	ret

0000000000800718 <work>:
  800718:	1101                	addi	sp,sp,-32
  80071a:	e822                	sd	s0,16(sp)
  80071c:	e426                	sd	s1,8(sp)
  80071e:	ec06                	sd	ra,24(sp)
  800720:	84aa                	mv	s1,a0
  800722:	00001617          	auipc	a2,0x1
  800726:	a9e60613          	addi	a2,a2,-1378 # 8011c0 <matb+0x28>
  80072a:	00001417          	auipc	s0,0x1
  80072e:	c2640413          	addi	s0,s0,-986 # 801350 <mata+0x28>
  800732:	00001597          	auipc	a1,0x1
  800736:	bf658593          	addi	a1,a1,-1034 # 801328 <mata>
  80073a:	4685                	li	a3,1
  80073c:	fd860793          	addi	a5,a2,-40
  800740:	872e                	mv	a4,a1
  800742:	c394                	sw	a3,0(a5)
  800744:	c314                	sw	a3,0(a4)
  800746:	0791                	addi	a5,a5,4
  800748:	0711                	addi	a4,a4,4
  80074a:	fec79ce3          	bne	a5,a2,800742 <work+0x2a>
  80074e:	02878613          	addi	a2,a5,40
  800752:	02858593          	addi	a1,a1,40
  800756:	fe8613e3          	bne	a2,s0,80073c <work+0x24>
  80075a:	9e7ff0ef          	jal	800140 <yield>
  80075e:	9e7ff0ef          	jal	800144 <getpid>
  800762:	85aa                	mv	a1,a0
  800764:	8626                	mv	a2,s1
  800766:	00000517          	auipc	a0,0x0
  80076a:	47250513          	addi	a0,a0,1138 # 800bd8 <main+0x39c>
  80076e:	a27ff0ef          	jal	800194 <cprintf>
  800772:	c8cd                	beqz	s1,800824 <work+0x10c>
  800774:	34fd                	addiw	s1,s1,-1
  800776:	00001f17          	auipc	t5,0x1
  80077a:	bb2f0f13          	addi	t5,t5,-1102 # 801328 <mata>
  80077e:	00001e97          	auipc	t4,0x1
  800782:	d3ae8e93          	addi	t4,t4,-710 # 8014b8 <mata+0x190>
  800786:	5ffd                	li	t6,-1
  800788:	00001317          	auipc	t1,0x1
  80078c:	88030313          	addi	t1,t1,-1920 # 801008 <matc>
  800790:	8e1a                	mv	t3,t1
  800792:	00001897          	auipc	a7,0x1
  800796:	b9688893          	addi	a7,a7,-1130 # 801328 <mata>
  80079a:	00001517          	auipc	a0,0x1
  80079e:	b8e50513          	addi	a0,a0,-1138 # 801328 <mata>
  8007a2:	8872                	mv	a6,t3
  8007a4:	e7050793          	addi	a5,a0,-400
  8007a8:	86c6                	mv	a3,a7
  8007aa:	4601                	li	a2,0
  8007ac:	428c                	lw	a1,0(a3)
  8007ae:	4398                	lw	a4,0(a5)
  8007b0:	02878793          	addi	a5,a5,40
  8007b4:	0691                	addi	a3,a3,4
  8007b6:	02b7073b          	mulw	a4,a4,a1
  8007ba:	9e39                	addw	a2,a2,a4
  8007bc:	fea798e3          	bne	a5,a0,8007ac <work+0x94>
  8007c0:	00c82023          	sw	a2,0(a6)
  8007c4:	00478513          	addi	a0,a5,4
  8007c8:	0811                	addi	a6,a6,4
  8007ca:	fc851de3          	bne	a0,s0,8007a4 <work+0x8c>
  8007ce:	02888893          	addi	a7,a7,40
  8007d2:	028e0e13          	addi	t3,t3,40
  8007d6:	fd1e92e3          	bne	t4,a7,80079a <work+0x82>
  8007da:	00001597          	auipc	a1,0x1
  8007de:	85658593          	addi	a1,a1,-1962 # 801030 <matc+0x28>
  8007e2:	00001817          	auipc	a6,0x1
  8007e6:	b4680813          	addi	a6,a6,-1210 # 801328 <mata>
  8007ea:	00001517          	auipc	a0,0x1
  8007ee:	9ae50513          	addi	a0,a0,-1618 # 801198 <matb>
  8007f2:	86aa                	mv	a3,a0
  8007f4:	8742                	mv	a4,a6
  8007f6:	879a                	mv	a5,t1
  8007f8:	6390                	ld	a2,0(a5)
  8007fa:	07a1                	addi	a5,a5,8
  8007fc:	06a1                	addi	a3,a3,8
  8007fe:	fec6bc23          	sd	a2,-8(a3)
  800802:	e310                	sd	a2,0(a4)
  800804:	0721                	addi	a4,a4,8
  800806:	feb799e3          	bne	a5,a1,8007f8 <work+0xe0>
  80080a:	02850513          	addi	a0,a0,40
  80080e:	02830313          	addi	t1,t1,40
  800812:	02880813          	addi	a6,a6,40
  800816:	02878593          	addi	a1,a5,40
  80081a:	fcaf1ce3          	bne	t5,a0,8007f2 <work+0xda>
  80081e:	34fd                	addiw	s1,s1,-1
  800820:	f7f494e3          	bne	s1,t6,800788 <work+0x70>
  800824:	921ff0ef          	jal	800144 <getpid>
  800828:	85aa                	mv	a1,a0
  80082a:	00000517          	auipc	a0,0x0
  80082e:	3ce50513          	addi	a0,a0,974 # 800bf8 <main+0x3bc>
  800832:	963ff0ef          	jal	800194 <cprintf>
  800836:	4501                	li	a0,0
  800838:	8ebff0ef          	jal	800122 <exit>

000000000080083c <main>:
  80083c:	7175                	addi	sp,sp,-144
  80083e:	f4ce                	sd	s3,104(sp)
  800840:	0028                	addi	a0,sp,8
  800842:	05400613          	li	a2,84
  800846:	4581                	li	a1,0
  800848:	00810993          	addi	s3,sp,8
  80084c:	e122                	sd	s0,128(sp)
  80084e:	fca6                	sd	s1,120(sp)
  800850:	f8ca                	sd	s2,112(sp)
  800852:	e506                	sd	ra,136(sp)
  800854:	84ce                	mv	s1,s3
  800856:	a4bff0ef          	jal	8002a0 <memset>
  80085a:	4401                	li	s0,0
  80085c:	4955                	li	s2,21
  80085e:	8dbff0ef          	jal	800138 <fork>
  800862:	c088                	sw	a0,0(s1)
  800864:	cd25                	beqz	a0,8008dc <main+0xa0>
  800866:	04054563          	bltz	a0,8008b0 <main+0x74>
  80086a:	2405                	addiw	s0,s0,1
  80086c:	0491                	addi	s1,s1,4
  80086e:	ff2418e3          	bne	s0,s2,80085e <main+0x22>
  800872:	00000517          	auipc	a0,0x0
  800876:	39650513          	addi	a0,a0,918 # 800c08 <main+0x3cc>
  80087a:	91bff0ef          	jal	800194 <cprintf>
  80087e:	8bdff0ef          	jal	80013a <wait>
  800882:	e10d                	bnez	a0,8008a4 <main+0x68>
  800884:	347d                	addiw	s0,s0,-1
  800886:	fc65                	bnez	s0,80087e <main+0x42>
  800888:	00000517          	auipc	a0,0x0
  80088c:	3a050513          	addi	a0,a0,928 # 800c28 <main+0x3ec>
  800890:	905ff0ef          	jal	800194 <cprintf>
  800894:	60aa                	ld	ra,136(sp)
  800896:	640a                	ld	s0,128(sp)
  800898:	74e6                	ld	s1,120(sp)
  80089a:	7946                	ld	s2,112(sp)
  80089c:	79a6                	ld	s3,104(sp)
  80089e:	4501                	li	a0,0
  8008a0:	6149                	addi	sp,sp,144
  8008a2:	8082                	ret
  8008a4:	00000517          	auipc	a0,0x0
  8008a8:	37450513          	addi	a0,a0,884 # 800c18 <main+0x3dc>
  8008ac:	8e9ff0ef          	jal	800194 <cprintf>
  8008b0:	08e0                	addi	s0,sp,92
  8008b2:	0009a503          	lw	a0,0(s3)
  8008b6:	00a05463          	blez	a0,8008be <main+0x82>
  8008ba:	889ff0ef          	jal	800142 <kill>
  8008be:	0991                	addi	s3,s3,4
  8008c0:	fe8999e3          	bne	s3,s0,8008b2 <main+0x76>
  8008c4:	00000617          	auipc	a2,0x0
  8008c8:	37460613          	addi	a2,a2,884 # 800c38 <main+0x3fc>
  8008cc:	05200593          	li	a1,82
  8008d0:	00000517          	auipc	a0,0x0
  8008d4:	37850513          	addi	a0,a0,888 # 800c48 <main+0x40c>
  8008d8:	f48ff0ef          	jal	800020 <__panic>
  8008dc:	0284053b          	mulw	a0,s0,s0
  8008e0:	e2bff0ef          	jal	80070a <srand>
  8008e4:	dd9ff0ef          	jal	8006bc <rand>
  8008e8:	47d5                	li	a5,21
  8008ea:	02f577bb          	remuw	a5,a0,a5
  8008ee:	06400513          	li	a0,100
  8008f2:	02f787bb          	mulw	a5,a5,a5
  8008f6:	27a9                	addiw	a5,a5,10
  8008f8:	02f5053b          	mulw	a0,a0,a5
  8008fc:	e1dff0ef          	jal	800718 <work>
