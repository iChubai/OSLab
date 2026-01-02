
obj/__user_sleep.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	73250513          	addi	a0,a0,1842 # 800760 <main+0x70>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	164000ef          	jal	8001a8 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	136000ef          	jal	800182 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	73050513          	addi	a0,a0,1840 # 800780 <main+0x90>
  800058:	150000ef          	jal	8001a8 <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0c0000ef          	jal	80011e <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00000517          	auipc	a0,0x0
  800074:	71850513          	addi	a0,a0,1816 # 800788 <main+0x98>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	122000ef          	jal	8001a8 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0f4000ef          	jal	800182 <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	6ee50513          	addi	a0,a0,1774 # 800780 <main+0x90>
  80009a:	10e000ef          	jal	8001a8 <cprintf>
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

00000000008000f2 <sys_putc>:
  8000f2:	85aa                	mv	a1,a0
  8000f4:	4579                	li	a0,30
  8000f6:	bf45                	j	8000a6 <syscall>

00000000008000f8 <sys_sleep>:
  8000f8:	85aa                	mv	a1,a0
  8000fa:	452d                	li	a0,11
  8000fc:	b76d                	j	8000a6 <syscall>

00000000008000fe <sys_gettime>:
  8000fe:	4545                	li	a0,17
  800100:	b75d                	j	8000a6 <syscall>

0000000000800102 <sys_open>:
  800102:	862e                	mv	a2,a1
  800104:	85aa                	mv	a1,a0
  800106:	06400513          	li	a0,100
  80010a:	bf71                	j	8000a6 <syscall>

000000000080010c <sys_close>:
  80010c:	85aa                	mv	a1,a0
  80010e:	06500513          	li	a0,101
  800112:	bf51                	j	8000a6 <syscall>

0000000000800114 <sys_dup>:
  800114:	862e                	mv	a2,a1
  800116:	85aa                	mv	a1,a0
  800118:	08200513          	li	a0,130
  80011c:	b769                	j	8000a6 <syscall>

000000000080011e <exit>:
  80011e:	1141                	addi	sp,sp,-16
  800120:	e406                	sd	ra,8(sp)
  800122:	fbfff0ef          	jal	8000e0 <sys_exit>
  800126:	00000517          	auipc	a0,0x0
  80012a:	68250513          	addi	a0,a0,1666 # 8007a8 <main+0xb8>
  80012e:	07a000ef          	jal	8001a8 <cprintf>
  800132:	a001                	j	800132 <exit+0x14>

0000000000800134 <fork>:
  800134:	bf4d                	j	8000e6 <sys_fork>

0000000000800136 <waitpid>:
  800136:	cd89                	beqz	a1,800150 <waitpid+0x1a>
  800138:	7179                	addi	sp,sp,-48
  80013a:	e42e                	sd	a1,8(sp)
  80013c:	082c                	addi	a1,sp,24
  80013e:	f406                	sd	ra,40(sp)
  800140:	fabff0ef          	jal	8000ea <sys_wait>
  800144:	6762                	ld	a4,24(sp)
  800146:	67a2                	ld	a5,8(sp)
  800148:	70a2                	ld	ra,40(sp)
  80014a:	c398                	sw	a4,0(a5)
  80014c:	6145                	addi	sp,sp,48
  80014e:	8082                	ret
  800150:	bf69                	j	8000ea <sys_wait>

0000000000800152 <gettime_msec>:
  800152:	b775                	j	8000fe <sys_gettime>

0000000000800154 <sleep>:
  800154:	1502                	slli	a0,a0,0x20
  800156:	9101                	srli	a0,a0,0x20
  800158:	b745                	j	8000f8 <sys_sleep>

000000000080015a <_start>:
  80015a:	0ca000ef          	jal	800224 <umain>
  80015e:	a001                	j	80015e <_start+0x4>

0000000000800160 <open>:
  800160:	1582                	slli	a1,a1,0x20
  800162:	9181                	srli	a1,a1,0x20
  800164:	bf79                	j	800102 <sys_open>

0000000000800166 <close>:
  800166:	b75d                	j	80010c <sys_close>

0000000000800168 <dup2>:
  800168:	b775                	j	800114 <sys_dup>

000000000080016a <cputch>:
  80016a:	1101                	addi	sp,sp,-32
  80016c:	ec06                	sd	ra,24(sp)
  80016e:	e42e                	sd	a1,8(sp)
  800170:	f83ff0ef          	jal	8000f2 <sys_putc>
  800174:	65a2                	ld	a1,8(sp)
  800176:	60e2                	ld	ra,24(sp)
  800178:	419c                	lw	a5,0(a1)
  80017a:	2785                	addiw	a5,a5,1
  80017c:	c19c                	sw	a5,0(a1)
  80017e:	6105                	addi	sp,sp,32
  800180:	8082                	ret

0000000000800182 <vcprintf>:
  800182:	1101                	addi	sp,sp,-32
  800184:	872e                	mv	a4,a1
  800186:	75dd                	lui	a1,0xffff7
  800188:	86aa                	mv	a3,a0
  80018a:	0070                	addi	a2,sp,12
  80018c:	00000517          	auipc	a0,0x0
  800190:	fde50513          	addi	a0,a0,-34 # 80016a <cputch>
  800194:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ea9>
  800198:	ec06                	sd	ra,24(sp)
  80019a:	c602                	sw	zero,12(sp)
  80019c:	188000ef          	jal	800324 <vprintfmt>
  8001a0:	60e2                	ld	ra,24(sp)
  8001a2:	4532                	lw	a0,12(sp)
  8001a4:	6105                	addi	sp,sp,32
  8001a6:	8082                	ret

00000000008001a8 <cprintf>:
  8001a8:	711d                	addi	sp,sp,-96
  8001aa:	02810313          	addi	t1,sp,40
  8001ae:	f42e                	sd	a1,40(sp)
  8001b0:	75dd                	lui	a1,0xffff7
  8001b2:	f832                	sd	a2,48(sp)
  8001b4:	fc36                	sd	a3,56(sp)
  8001b6:	e0ba                	sd	a4,64(sp)
  8001b8:	86aa                	mv	a3,a0
  8001ba:	0050                	addi	a2,sp,4
  8001bc:	00000517          	auipc	a0,0x0
  8001c0:	fae50513          	addi	a0,a0,-82 # 80016a <cputch>
  8001c4:	871a                	mv	a4,t1
  8001c6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ea9>
  8001ca:	ec06                	sd	ra,24(sp)
  8001cc:	e4be                	sd	a5,72(sp)
  8001ce:	e8c2                	sd	a6,80(sp)
  8001d0:	ecc6                	sd	a7,88(sp)
  8001d2:	c202                	sw	zero,4(sp)
  8001d4:	e41a                	sd	t1,8(sp)
  8001d6:	14e000ef          	jal	800324 <vprintfmt>
  8001da:	60e2                	ld	ra,24(sp)
  8001dc:	4512                	lw	a0,4(sp)
  8001de:	6125                	addi	sp,sp,96
  8001e0:	8082                	ret

00000000008001e2 <initfd>:
  8001e2:	87ae                	mv	a5,a1
  8001e4:	1101                	addi	sp,sp,-32
  8001e6:	e822                	sd	s0,16(sp)
  8001e8:	85b2                	mv	a1,a2
  8001ea:	842a                	mv	s0,a0
  8001ec:	853e                	mv	a0,a5
  8001ee:	ec06                	sd	ra,24(sp)
  8001f0:	f71ff0ef          	jal	800160 <open>
  8001f4:	87aa                	mv	a5,a0
  8001f6:	00054463          	bltz	a0,8001fe <initfd+0x1c>
  8001fa:	00851763          	bne	a0,s0,800208 <initfd+0x26>
  8001fe:	60e2                	ld	ra,24(sp)
  800200:	6442                	ld	s0,16(sp)
  800202:	853e                	mv	a0,a5
  800204:	6105                	addi	sp,sp,32
  800206:	8082                	ret
  800208:	e42a                	sd	a0,8(sp)
  80020a:	8522                	mv	a0,s0
  80020c:	f5bff0ef          	jal	800166 <close>
  800210:	6522                	ld	a0,8(sp)
  800212:	85a2                	mv	a1,s0
  800214:	f55ff0ef          	jal	800168 <dup2>
  800218:	842a                	mv	s0,a0
  80021a:	6522                	ld	a0,8(sp)
  80021c:	f4bff0ef          	jal	800166 <close>
  800220:	87a2                	mv	a5,s0
  800222:	bff1                	j	8001fe <initfd+0x1c>

0000000000800224 <umain>:
  800224:	1101                	addi	sp,sp,-32
  800226:	e822                	sd	s0,16(sp)
  800228:	e426                	sd	s1,8(sp)
  80022a:	842a                	mv	s0,a0
  80022c:	84ae                	mv	s1,a1
  80022e:	4601                	li	a2,0
  800230:	00000597          	auipc	a1,0x0
  800234:	59058593          	addi	a1,a1,1424 # 8007c0 <main+0xd0>
  800238:	4501                	li	a0,0
  80023a:	ec06                	sd	ra,24(sp)
  80023c:	fa7ff0ef          	jal	8001e2 <initfd>
  800240:	02054263          	bltz	a0,800264 <umain+0x40>
  800244:	4605                	li	a2,1
  800246:	8532                	mv	a0,a2
  800248:	00000597          	auipc	a1,0x0
  80024c:	5b858593          	addi	a1,a1,1464 # 800800 <main+0x110>
  800250:	f93ff0ef          	jal	8001e2 <initfd>
  800254:	02054563          	bltz	a0,80027e <umain+0x5a>
  800258:	85a6                	mv	a1,s1
  80025a:	8522                	mv	a0,s0
  80025c:	494000ef          	jal	8006f0 <main>
  800260:	ebfff0ef          	jal	80011e <exit>
  800264:	86aa                	mv	a3,a0
  800266:	00000617          	auipc	a2,0x0
  80026a:	56260613          	addi	a2,a2,1378 # 8007c8 <main+0xd8>
  80026e:	45e9                	li	a1,26
  800270:	00000517          	auipc	a0,0x0
  800274:	57850513          	addi	a0,a0,1400 # 8007e8 <main+0xf8>
  800278:	debff0ef          	jal	800062 <__warn>
  80027c:	b7e1                	j	800244 <umain+0x20>
  80027e:	86aa                	mv	a3,a0
  800280:	00000617          	auipc	a2,0x0
  800284:	58860613          	addi	a2,a2,1416 # 800808 <main+0x118>
  800288:	45f5                	li	a1,29
  80028a:	00000517          	auipc	a0,0x0
  80028e:	55e50513          	addi	a0,a0,1374 # 8007e8 <main+0xf8>
  800292:	dd1ff0ef          	jal	800062 <__warn>
  800296:	b7c9                	j	800258 <umain+0x34>

0000000000800298 <strnlen>:
  800298:	4781                	li	a5,0
  80029a:	e589                	bnez	a1,8002a4 <strnlen+0xc>
  80029c:	a811                	j	8002b0 <strnlen+0x18>
  80029e:	0785                	addi	a5,a5,1
  8002a0:	00f58863          	beq	a1,a5,8002b0 <strnlen+0x18>
  8002a4:	00f50733          	add	a4,a0,a5
  8002a8:	00074703          	lbu	a4,0(a4)
  8002ac:	fb6d                	bnez	a4,80029e <strnlen+0x6>
  8002ae:	85be                	mv	a1,a5
  8002b0:	852e                	mv	a0,a1
  8002b2:	8082                	ret

00000000008002b4 <printnum>:
  8002b4:	7139                	addi	sp,sp,-64
  8002b6:	02071893          	slli	a7,a4,0x20
  8002ba:	f822                	sd	s0,48(sp)
  8002bc:	f426                	sd	s1,40(sp)
  8002be:	f04a                	sd	s2,32(sp)
  8002c0:	ec4e                	sd	s3,24(sp)
  8002c2:	e456                	sd	s5,8(sp)
  8002c4:	0208d893          	srli	a7,a7,0x20
  8002c8:	fc06                	sd	ra,56(sp)
  8002ca:	0316fab3          	remu	s5,a3,a7
  8002ce:	fff7841b          	addiw	s0,a5,-1
  8002d2:	84aa                	mv	s1,a0
  8002d4:	89ae                	mv	s3,a1
  8002d6:	8932                	mv	s2,a2
  8002d8:	0516f063          	bgeu	a3,a7,800318 <printnum+0x64>
  8002dc:	e852                	sd	s4,16(sp)
  8002de:	4705                	li	a4,1
  8002e0:	8a42                	mv	s4,a6
  8002e2:	00f75863          	bge	a4,a5,8002f2 <printnum+0x3e>
  8002e6:	864e                	mv	a2,s3
  8002e8:	85ca                	mv	a1,s2
  8002ea:	8552                	mv	a0,s4
  8002ec:	347d                	addiw	s0,s0,-1
  8002ee:	9482                	jalr	s1
  8002f0:	f87d                	bnez	s0,8002e6 <printnum+0x32>
  8002f2:	6a42                	ld	s4,16(sp)
  8002f4:	00000797          	auipc	a5,0x0
  8002f8:	53478793          	addi	a5,a5,1332 # 800828 <main+0x138>
  8002fc:	97d6                	add	a5,a5,s5
  8002fe:	7442                	ld	s0,48(sp)
  800300:	0007c503          	lbu	a0,0(a5)
  800304:	70e2                	ld	ra,56(sp)
  800306:	6aa2                	ld	s5,8(sp)
  800308:	864e                	mv	a2,s3
  80030a:	85ca                	mv	a1,s2
  80030c:	69e2                	ld	s3,24(sp)
  80030e:	7902                	ld	s2,32(sp)
  800310:	87a6                	mv	a5,s1
  800312:	74a2                	ld	s1,40(sp)
  800314:	6121                	addi	sp,sp,64
  800316:	8782                	jr	a5
  800318:	0316d6b3          	divu	a3,a3,a7
  80031c:	87a2                	mv	a5,s0
  80031e:	f97ff0ef          	jal	8002b4 <printnum>
  800322:	bfc9                	j	8002f4 <printnum+0x40>

0000000000800324 <vprintfmt>:
  800324:	7119                	addi	sp,sp,-128
  800326:	f4a6                	sd	s1,104(sp)
  800328:	f0ca                	sd	s2,96(sp)
  80032a:	ecce                	sd	s3,88(sp)
  80032c:	e8d2                	sd	s4,80(sp)
  80032e:	e4d6                	sd	s5,72(sp)
  800330:	e0da                	sd	s6,64(sp)
  800332:	fc5e                	sd	s7,56(sp)
  800334:	f466                	sd	s9,40(sp)
  800336:	fc86                	sd	ra,120(sp)
  800338:	f8a2                	sd	s0,112(sp)
  80033a:	f862                	sd	s8,48(sp)
  80033c:	f06a                	sd	s10,32(sp)
  80033e:	ec6e                	sd	s11,24(sp)
  800340:	84aa                	mv	s1,a0
  800342:	8cb6                	mv	s9,a3
  800344:	8aba                	mv	s5,a4
  800346:	89ae                	mv	s3,a1
  800348:	8932                	mv	s2,a2
  80034a:	02500a13          	li	s4,37
  80034e:	05500b93          	li	s7,85
  800352:	00000b17          	auipc	s6,0x0
  800356:	786b0b13          	addi	s6,s6,1926 # 800ad8 <main+0x3e8>
  80035a:	000cc503          	lbu	a0,0(s9)
  80035e:	001c8413          	addi	s0,s9,1
  800362:	01450b63          	beq	a0,s4,800378 <vprintfmt+0x54>
  800366:	cd15                	beqz	a0,8003a2 <vprintfmt+0x7e>
  800368:	864e                	mv	a2,s3
  80036a:	85ca                	mv	a1,s2
  80036c:	9482                	jalr	s1
  80036e:	00044503          	lbu	a0,0(s0)
  800372:	0405                	addi	s0,s0,1
  800374:	ff4519e3          	bne	a0,s4,800366 <vprintfmt+0x42>
  800378:	5d7d                	li	s10,-1
  80037a:	8dea                	mv	s11,s10
  80037c:	02000813          	li	a6,32
  800380:	4c01                	li	s8,0
  800382:	4581                	li	a1,0
  800384:	00044703          	lbu	a4,0(s0)
  800388:	00140c93          	addi	s9,s0,1
  80038c:	fdd7061b          	addiw	a2,a4,-35
  800390:	0ff67613          	zext.b	a2,a2
  800394:	02cbe663          	bltu	s7,a2,8003c0 <vprintfmt+0x9c>
  800398:	060a                	slli	a2,a2,0x2
  80039a:	965a                	add	a2,a2,s6
  80039c:	421c                	lw	a5,0(a2)
  80039e:	97da                	add	a5,a5,s6
  8003a0:	8782                	jr	a5
  8003a2:	70e6                	ld	ra,120(sp)
  8003a4:	7446                	ld	s0,112(sp)
  8003a6:	74a6                	ld	s1,104(sp)
  8003a8:	7906                	ld	s2,96(sp)
  8003aa:	69e6                	ld	s3,88(sp)
  8003ac:	6a46                	ld	s4,80(sp)
  8003ae:	6aa6                	ld	s5,72(sp)
  8003b0:	6b06                	ld	s6,64(sp)
  8003b2:	7be2                	ld	s7,56(sp)
  8003b4:	7c42                	ld	s8,48(sp)
  8003b6:	7ca2                	ld	s9,40(sp)
  8003b8:	7d02                	ld	s10,32(sp)
  8003ba:	6de2                	ld	s11,24(sp)
  8003bc:	6109                	addi	sp,sp,128
  8003be:	8082                	ret
  8003c0:	864e                	mv	a2,s3
  8003c2:	85ca                	mv	a1,s2
  8003c4:	02500513          	li	a0,37
  8003c8:	9482                	jalr	s1
  8003ca:	fff44783          	lbu	a5,-1(s0)
  8003ce:	02500713          	li	a4,37
  8003d2:	8ca2                	mv	s9,s0
  8003d4:	f8e783e3          	beq	a5,a4,80035a <vprintfmt+0x36>
  8003d8:	ffecc783          	lbu	a5,-2(s9)
  8003dc:	1cfd                	addi	s9,s9,-1
  8003de:	fee79de3          	bne	a5,a4,8003d8 <vprintfmt+0xb4>
  8003e2:	bfa5                	j	80035a <vprintfmt+0x36>
  8003e4:	00144683          	lbu	a3,1(s0)
  8003e8:	4525                	li	a0,9
  8003ea:	fd070d1b          	addiw	s10,a4,-48
  8003ee:	fd06879b          	addiw	a5,a3,-48
  8003f2:	28f56063          	bltu	a0,a5,800672 <vprintfmt+0x34e>
  8003f6:	2681                	sext.w	a3,a3
  8003f8:	8466                	mv	s0,s9
  8003fa:	002d179b          	slliw	a5,s10,0x2
  8003fe:	00144703          	lbu	a4,1(s0)
  800402:	01a787bb          	addw	a5,a5,s10
  800406:	0017979b          	slliw	a5,a5,0x1
  80040a:	9fb5                	addw	a5,a5,a3
  80040c:	fd07061b          	addiw	a2,a4,-48
  800410:	0405                	addi	s0,s0,1
  800412:	fd078d1b          	addiw	s10,a5,-48
  800416:	0007069b          	sext.w	a3,a4
  80041a:	fec570e3          	bgeu	a0,a2,8003fa <vprintfmt+0xd6>
  80041e:	f60dd3e3          	bgez	s11,800384 <vprintfmt+0x60>
  800422:	8dea                	mv	s11,s10
  800424:	5d7d                	li	s10,-1
  800426:	bfb9                	j	800384 <vprintfmt+0x60>
  800428:	883a                	mv	a6,a4
  80042a:	8466                	mv	s0,s9
  80042c:	bfa1                	j	800384 <vprintfmt+0x60>
  80042e:	8466                	mv	s0,s9
  800430:	4c05                	li	s8,1
  800432:	bf89                	j	800384 <vprintfmt+0x60>
  800434:	4785                	li	a5,1
  800436:	008a8613          	addi	a2,s5,8
  80043a:	00b7c463          	blt	a5,a1,800442 <vprintfmt+0x11e>
  80043e:	1c058363          	beqz	a1,800604 <vprintfmt+0x2e0>
  800442:	000ab683          	ld	a3,0(s5)
  800446:	4741                	li	a4,16
  800448:	8ab2                	mv	s5,a2
  80044a:	2801                	sext.w	a6,a6
  80044c:	87ee                	mv	a5,s11
  80044e:	864a                	mv	a2,s2
  800450:	85ce                	mv	a1,s3
  800452:	8526                	mv	a0,s1
  800454:	e61ff0ef          	jal	8002b4 <printnum>
  800458:	b709                	j	80035a <vprintfmt+0x36>
  80045a:	000aa503          	lw	a0,0(s5)
  80045e:	864e                	mv	a2,s3
  800460:	85ca                	mv	a1,s2
  800462:	9482                	jalr	s1
  800464:	0aa1                	addi	s5,s5,8
  800466:	bdd5                	j	80035a <vprintfmt+0x36>
  800468:	4785                	li	a5,1
  80046a:	008a8613          	addi	a2,s5,8
  80046e:	00b7c463          	blt	a5,a1,800476 <vprintfmt+0x152>
  800472:	18058463          	beqz	a1,8005fa <vprintfmt+0x2d6>
  800476:	000ab683          	ld	a3,0(s5)
  80047a:	4729                	li	a4,10
  80047c:	8ab2                	mv	s5,a2
  80047e:	b7f1                	j	80044a <vprintfmt+0x126>
  800480:	864e                	mv	a2,s3
  800482:	85ca                	mv	a1,s2
  800484:	03000513          	li	a0,48
  800488:	e042                	sd	a6,0(sp)
  80048a:	9482                	jalr	s1
  80048c:	864e                	mv	a2,s3
  80048e:	85ca                	mv	a1,s2
  800490:	07800513          	li	a0,120
  800494:	9482                	jalr	s1
  800496:	000ab683          	ld	a3,0(s5)
  80049a:	6802                	ld	a6,0(sp)
  80049c:	4741                	li	a4,16
  80049e:	0aa1                	addi	s5,s5,8
  8004a0:	b76d                	j	80044a <vprintfmt+0x126>
  8004a2:	864e                	mv	a2,s3
  8004a4:	85ca                	mv	a1,s2
  8004a6:	02500513          	li	a0,37
  8004aa:	9482                	jalr	s1
  8004ac:	b57d                	j	80035a <vprintfmt+0x36>
  8004ae:	000aad03          	lw	s10,0(s5)
  8004b2:	8466                	mv	s0,s9
  8004b4:	0aa1                	addi	s5,s5,8
  8004b6:	b7a5                	j	80041e <vprintfmt+0xfa>
  8004b8:	4785                	li	a5,1
  8004ba:	008a8613          	addi	a2,s5,8
  8004be:	00b7c463          	blt	a5,a1,8004c6 <vprintfmt+0x1a2>
  8004c2:	12058763          	beqz	a1,8005f0 <vprintfmt+0x2cc>
  8004c6:	000ab683          	ld	a3,0(s5)
  8004ca:	4721                	li	a4,8
  8004cc:	8ab2                	mv	s5,a2
  8004ce:	bfb5                	j	80044a <vprintfmt+0x126>
  8004d0:	87ee                	mv	a5,s11
  8004d2:	000dd363          	bgez	s11,8004d8 <vprintfmt+0x1b4>
  8004d6:	4781                	li	a5,0
  8004d8:	00078d9b          	sext.w	s11,a5
  8004dc:	8466                	mv	s0,s9
  8004de:	b55d                	j	800384 <vprintfmt+0x60>
  8004e0:	0008041b          	sext.w	s0,a6
  8004e4:	fd340793          	addi	a5,s0,-45
  8004e8:	01b02733          	sgtz	a4,s11
  8004ec:	00f037b3          	snez	a5,a5
  8004f0:	8ff9                	and	a5,a5,a4
  8004f2:	000ab703          	ld	a4,0(s5)
  8004f6:	008a8693          	addi	a3,s5,8
  8004fa:	e436                	sd	a3,8(sp)
  8004fc:	12070563          	beqz	a4,800626 <vprintfmt+0x302>
  800500:	12079d63          	bnez	a5,80063a <vprintfmt+0x316>
  800504:	00074783          	lbu	a5,0(a4)
  800508:	0007851b          	sext.w	a0,a5
  80050c:	c78d                	beqz	a5,800536 <vprintfmt+0x212>
  80050e:	00170a93          	addi	s5,a4,1
  800512:	547d                	li	s0,-1
  800514:	000d4563          	bltz	s10,80051e <vprintfmt+0x1fa>
  800518:	3d7d                	addiw	s10,s10,-1
  80051a:	008d0e63          	beq	s10,s0,800536 <vprintfmt+0x212>
  80051e:	020c1863          	bnez	s8,80054e <vprintfmt+0x22a>
  800522:	864e                	mv	a2,s3
  800524:	85ca                	mv	a1,s2
  800526:	9482                	jalr	s1
  800528:	000ac783          	lbu	a5,0(s5)
  80052c:	0a85                	addi	s5,s5,1
  80052e:	3dfd                	addiw	s11,s11,-1
  800530:	0007851b          	sext.w	a0,a5
  800534:	f3e5                	bnez	a5,800514 <vprintfmt+0x1f0>
  800536:	01b05a63          	blez	s11,80054a <vprintfmt+0x226>
  80053a:	864e                	mv	a2,s3
  80053c:	85ca                	mv	a1,s2
  80053e:	02000513          	li	a0,32
  800542:	3dfd                	addiw	s11,s11,-1
  800544:	9482                	jalr	s1
  800546:	fe0d9ae3          	bnez	s11,80053a <vprintfmt+0x216>
  80054a:	6aa2                	ld	s5,8(sp)
  80054c:	b539                	j	80035a <vprintfmt+0x36>
  80054e:	3781                	addiw	a5,a5,-32
  800550:	05e00713          	li	a4,94
  800554:	fcf777e3          	bgeu	a4,a5,800522 <vprintfmt+0x1fe>
  800558:	03f00513          	li	a0,63
  80055c:	864e                	mv	a2,s3
  80055e:	85ca                	mv	a1,s2
  800560:	9482                	jalr	s1
  800562:	000ac783          	lbu	a5,0(s5)
  800566:	0a85                	addi	s5,s5,1
  800568:	3dfd                	addiw	s11,s11,-1
  80056a:	0007851b          	sext.w	a0,a5
  80056e:	d7e1                	beqz	a5,800536 <vprintfmt+0x212>
  800570:	fa0d54e3          	bgez	s10,800518 <vprintfmt+0x1f4>
  800574:	bfe9                	j	80054e <vprintfmt+0x22a>
  800576:	000aa783          	lw	a5,0(s5)
  80057a:	46e1                	li	a3,24
  80057c:	0aa1                	addi	s5,s5,8
  80057e:	41f7d71b          	sraiw	a4,a5,0x1f
  800582:	8fb9                	xor	a5,a5,a4
  800584:	40e7873b          	subw	a4,a5,a4
  800588:	02e6c663          	blt	a3,a4,8005b4 <vprintfmt+0x290>
  80058c:	00000797          	auipc	a5,0x0
  800590:	6a478793          	addi	a5,a5,1700 # 800c30 <error_string>
  800594:	00371693          	slli	a3,a4,0x3
  800598:	97b6                	add	a5,a5,a3
  80059a:	639c                	ld	a5,0(a5)
  80059c:	cf81                	beqz	a5,8005b4 <vprintfmt+0x290>
  80059e:	873e                	mv	a4,a5
  8005a0:	00000697          	auipc	a3,0x0
  8005a4:	2b868693          	addi	a3,a3,696 # 800858 <main+0x168>
  8005a8:	864a                	mv	a2,s2
  8005aa:	85ce                	mv	a1,s3
  8005ac:	8526                	mv	a0,s1
  8005ae:	0f2000ef          	jal	8006a0 <printfmt>
  8005b2:	b365                	j	80035a <vprintfmt+0x36>
  8005b4:	00000697          	auipc	a3,0x0
  8005b8:	29468693          	addi	a3,a3,660 # 800848 <main+0x158>
  8005bc:	864a                	mv	a2,s2
  8005be:	85ce                	mv	a1,s3
  8005c0:	8526                	mv	a0,s1
  8005c2:	0de000ef          	jal	8006a0 <printfmt>
  8005c6:	bb51                	j	80035a <vprintfmt+0x36>
  8005c8:	4785                	li	a5,1
  8005ca:	008a8c13          	addi	s8,s5,8
  8005ce:	00b7c363          	blt	a5,a1,8005d4 <vprintfmt+0x2b0>
  8005d2:	cd81                	beqz	a1,8005ea <vprintfmt+0x2c6>
  8005d4:	000ab403          	ld	s0,0(s5)
  8005d8:	02044b63          	bltz	s0,80060e <vprintfmt+0x2ea>
  8005dc:	86a2                	mv	a3,s0
  8005de:	8ae2                	mv	s5,s8
  8005e0:	4729                	li	a4,10
  8005e2:	b5a5                	j	80044a <vprintfmt+0x126>
  8005e4:	2585                	addiw	a1,a1,1
  8005e6:	8466                	mv	s0,s9
  8005e8:	bb71                	j	800384 <vprintfmt+0x60>
  8005ea:	000aa403          	lw	s0,0(s5)
  8005ee:	b7ed                	j	8005d8 <vprintfmt+0x2b4>
  8005f0:	000ae683          	lwu	a3,0(s5)
  8005f4:	4721                	li	a4,8
  8005f6:	8ab2                	mv	s5,a2
  8005f8:	bd89                	j	80044a <vprintfmt+0x126>
  8005fa:	000ae683          	lwu	a3,0(s5)
  8005fe:	4729                	li	a4,10
  800600:	8ab2                	mv	s5,a2
  800602:	b5a1                	j	80044a <vprintfmt+0x126>
  800604:	000ae683          	lwu	a3,0(s5)
  800608:	4741                	li	a4,16
  80060a:	8ab2                	mv	s5,a2
  80060c:	bd3d                	j	80044a <vprintfmt+0x126>
  80060e:	864e                	mv	a2,s3
  800610:	85ca                	mv	a1,s2
  800612:	02d00513          	li	a0,45
  800616:	e042                	sd	a6,0(sp)
  800618:	9482                	jalr	s1
  80061a:	6802                	ld	a6,0(sp)
  80061c:	408006b3          	neg	a3,s0
  800620:	8ae2                	mv	s5,s8
  800622:	4729                	li	a4,10
  800624:	b51d                	j	80044a <vprintfmt+0x126>
  800626:	eba1                	bnez	a5,800676 <vprintfmt+0x352>
  800628:	02800793          	li	a5,40
  80062c:	853e                	mv	a0,a5
  80062e:	00000a97          	auipc	s5,0x0
  800632:	213a8a93          	addi	s5,s5,531 # 800841 <main+0x151>
  800636:	547d                	li	s0,-1
  800638:	bdf1                	j	800514 <vprintfmt+0x1f0>
  80063a:	853a                	mv	a0,a4
  80063c:	85ea                	mv	a1,s10
  80063e:	e03a                	sd	a4,0(sp)
  800640:	c59ff0ef          	jal	800298 <strnlen>
  800644:	40ad8dbb          	subw	s11,s11,a0
  800648:	6702                	ld	a4,0(sp)
  80064a:	01b05b63          	blez	s11,800660 <vprintfmt+0x33c>
  80064e:	864e                	mv	a2,s3
  800650:	85ca                	mv	a1,s2
  800652:	8522                	mv	a0,s0
  800654:	e03a                	sd	a4,0(sp)
  800656:	3dfd                	addiw	s11,s11,-1
  800658:	9482                	jalr	s1
  80065a:	6702                	ld	a4,0(sp)
  80065c:	fe0d99e3          	bnez	s11,80064e <vprintfmt+0x32a>
  800660:	00074783          	lbu	a5,0(a4)
  800664:	0007851b          	sext.w	a0,a5
  800668:	ee0781e3          	beqz	a5,80054a <vprintfmt+0x226>
  80066c:	00170a93          	addi	s5,a4,1
  800670:	b54d                	j	800512 <vprintfmt+0x1ee>
  800672:	8466                	mv	s0,s9
  800674:	b36d                	j	80041e <vprintfmt+0xfa>
  800676:	85ea                	mv	a1,s10
  800678:	00000517          	auipc	a0,0x0
  80067c:	1c850513          	addi	a0,a0,456 # 800840 <main+0x150>
  800680:	c19ff0ef          	jal	800298 <strnlen>
  800684:	40ad8dbb          	subw	s11,s11,a0
  800688:	02800793          	li	a5,40
  80068c:	00000717          	auipc	a4,0x0
  800690:	1b470713          	addi	a4,a4,436 # 800840 <main+0x150>
  800694:	853e                	mv	a0,a5
  800696:	fbb04ce3          	bgtz	s11,80064e <vprintfmt+0x32a>
  80069a:	00170a93          	addi	s5,a4,1
  80069e:	bd95                	j	800512 <vprintfmt+0x1ee>

00000000008006a0 <printfmt>:
  8006a0:	7139                	addi	sp,sp,-64
  8006a2:	02010313          	addi	t1,sp,32
  8006a6:	f03a                	sd	a4,32(sp)
  8006a8:	871a                	mv	a4,t1
  8006aa:	ec06                	sd	ra,24(sp)
  8006ac:	f43e                	sd	a5,40(sp)
  8006ae:	f842                	sd	a6,48(sp)
  8006b0:	fc46                	sd	a7,56(sp)
  8006b2:	e41a                	sd	t1,8(sp)
  8006b4:	c71ff0ef          	jal	800324 <vprintfmt>
  8006b8:	60e2                	ld	ra,24(sp)
  8006ba:	6121                	addi	sp,sp,64
  8006bc:	8082                	ret

00000000008006be <sleepy>:
  8006be:	1101                	addi	sp,sp,-32
  8006c0:	e822                	sd	s0,16(sp)
  8006c2:	e426                	sd	s1,8(sp)
  8006c4:	ec06                	sd	ra,24(sp)
  8006c6:	4401                	li	s0,0
  8006c8:	44a9                	li	s1,10
  8006ca:	06400513          	li	a0,100
  8006ce:	a87ff0ef          	jal	800154 <sleep>
  8006d2:	2405                	addiw	s0,s0,1
  8006d4:	85a2                	mv	a1,s0
  8006d6:	06400613          	li	a2,100
  8006da:	00000517          	auipc	a0,0x0
  8006de:	35e50513          	addi	a0,a0,862 # 800a38 <main+0x348>
  8006e2:	ac7ff0ef          	jal	8001a8 <cprintf>
  8006e6:	fe9412e3          	bne	s0,s1,8006ca <sleepy+0xc>
  8006ea:	4501                	li	a0,0
  8006ec:	a33ff0ef          	jal	80011e <exit>

00000000008006f0 <main>:
  8006f0:	1101                	addi	sp,sp,-32
  8006f2:	e822                	sd	s0,16(sp)
  8006f4:	ec06                	sd	ra,24(sp)
  8006f6:	a5dff0ef          	jal	800152 <gettime_msec>
  8006fa:	842a                	mv	s0,a0
  8006fc:	a39ff0ef          	jal	800134 <fork>
  800700:	cd21                	beqz	a0,800758 <main+0x68>
  800702:	006c                	addi	a1,sp,12
  800704:	a33ff0ef          	jal	800136 <waitpid>
  800708:	47b2                	lw	a5,12(sp)
  80070a:	8d5d                	or	a0,a0,a5
  80070c:	2501                	sext.w	a0,a0
  80070e:	e515                	bnez	a0,80073a <main+0x4a>
  800710:	a43ff0ef          	jal	800152 <gettime_msec>
  800714:	408505bb          	subw	a1,a0,s0
  800718:	00000517          	auipc	a0,0x0
  80071c:	39850513          	addi	a0,a0,920 # 800ab0 <main+0x3c0>
  800720:	a89ff0ef          	jal	8001a8 <cprintf>
  800724:	00000517          	auipc	a0,0x0
  800728:	3a450513          	addi	a0,a0,932 # 800ac8 <main+0x3d8>
  80072c:	a7dff0ef          	jal	8001a8 <cprintf>
  800730:	60e2                	ld	ra,24(sp)
  800732:	6442                	ld	s0,16(sp)
  800734:	4501                	li	a0,0
  800736:	6105                	addi	sp,sp,32
  800738:	8082                	ret
  80073a:	00000697          	auipc	a3,0x0
  80073e:	31668693          	addi	a3,a3,790 # 800a50 <main+0x360>
  800742:	00000617          	auipc	a2,0x0
  800746:	34660613          	addi	a2,a2,838 # 800a88 <main+0x398>
  80074a:	45dd                	li	a1,23
  80074c:	00000517          	auipc	a0,0x0
  800750:	35450513          	addi	a0,a0,852 # 800aa0 <main+0x3b0>
  800754:	8cdff0ef          	jal	800020 <__panic>
  800758:	f67ff0ef          	jal	8006be <sleepy>
