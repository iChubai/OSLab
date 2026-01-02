
obj/__user_forktree.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__warn>:
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	02810313          	addi	t1,sp,40
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	78a50513          	addi	a0,a0,1930 # 8007b8 <main+0x3a>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	0f8000ef          	jal	80013c <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0ca000ef          	jal	800116 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	7c050513          	addi	a0,a0,1984 # 800810 <main+0x92>
  800058:	0e4000ef          	jal	80013c <cprintf>
  80005c:	60e2                	ld	ra,24(sp)
  80005e:	6442                	ld	s0,16(sp)
  800060:	6161                	addi	sp,sp,80
  800062:	8082                	ret

0000000000800064 <syscall>:
  800064:	7175                	addi	sp,sp,-144
  800066:	08010313          	addi	t1,sp,128
  80006a:	e42a                	sd	a0,8(sp)
  80006c:	ecae                	sd	a1,88(sp)
  80006e:	f42e                	sd	a1,40(sp)
  800070:	f0b2                	sd	a2,96(sp)
  800072:	f832                	sd	a2,48(sp)
  800074:	f4b6                	sd	a3,104(sp)
  800076:	fc36                	sd	a3,56(sp)
  800078:	f8ba                	sd	a4,112(sp)
  80007a:	e0ba                	sd	a4,64(sp)
  80007c:	fcbe                	sd	a5,120(sp)
  80007e:	e4be                	sd	a5,72(sp)
  800080:	e142                	sd	a6,128(sp)
  800082:	e546                	sd	a7,136(sp)
  800084:	f01a                	sd	t1,32(sp)
  800086:	4522                	lw	a0,8(sp)
  800088:	55a2                	lw	a1,40(sp)
  80008a:	5642                	lw	a2,48(sp)
  80008c:	56e2                	lw	a3,56(sp)
  80008e:	4706                	lw	a4,64(sp)
  800090:	47a6                	lw	a5,72(sp)
  800092:	00000073          	ecall
  800096:	ce2a                	sw	a0,28(sp)
  800098:	4572                	lw	a0,28(sp)
  80009a:	6149                	addi	sp,sp,144
  80009c:	8082                	ret

000000000080009e <sys_exit>:
  80009e:	85aa                	mv	a1,a0
  8000a0:	4505                	li	a0,1
  8000a2:	b7c9                	j	800064 <syscall>

00000000008000a4 <sys_fork>:
  8000a4:	4509                	li	a0,2
  8000a6:	bf7d                	j	800064 <syscall>

00000000008000a8 <sys_yield>:
  8000a8:	4529                	li	a0,10
  8000aa:	bf6d                	j	800064 <syscall>

00000000008000ac <sys_getpid>:
  8000ac:	4549                	li	a0,18
  8000ae:	bf5d                	j	800064 <syscall>

00000000008000b0 <sys_putc>:
  8000b0:	85aa                	mv	a1,a0
  8000b2:	4579                	li	a0,30
  8000b4:	bf45                	j	800064 <syscall>

00000000008000b6 <sys_open>:
  8000b6:	862e                	mv	a2,a1
  8000b8:	85aa                	mv	a1,a0
  8000ba:	06400513          	li	a0,100
  8000be:	b75d                	j	800064 <syscall>

00000000008000c0 <sys_close>:
  8000c0:	85aa                	mv	a1,a0
  8000c2:	06500513          	li	a0,101
  8000c6:	bf79                	j	800064 <syscall>

00000000008000c8 <sys_dup>:
  8000c8:	862e                	mv	a2,a1
  8000ca:	85aa                	mv	a1,a0
  8000cc:	08200513          	li	a0,130
  8000d0:	bf51                	j	800064 <syscall>

00000000008000d2 <exit>:
  8000d2:	1141                	addi	sp,sp,-16
  8000d4:	e406                	sd	ra,8(sp)
  8000d6:	fc9ff0ef          	jal	80009e <sys_exit>
  8000da:	00000517          	auipc	a0,0x0
  8000de:	6fe50513          	addi	a0,a0,1790 # 8007d8 <main+0x5a>
  8000e2:	05a000ef          	jal	80013c <cprintf>
  8000e6:	a001                	j	8000e6 <exit+0x14>

00000000008000e8 <fork>:
  8000e8:	bf75                	j	8000a4 <sys_fork>

00000000008000ea <yield>:
  8000ea:	bf7d                	j	8000a8 <sys_yield>

00000000008000ec <getpid>:
  8000ec:	b7c1                	j	8000ac <sys_getpid>

00000000008000ee <_start>:
  8000ee:	0ca000ef          	jal	8001b8 <umain>
  8000f2:	a001                	j	8000f2 <_start+0x4>

00000000008000f4 <open>:
  8000f4:	1582                	slli	a1,a1,0x20
  8000f6:	9181                	srli	a1,a1,0x20
  8000f8:	bf7d                	j	8000b6 <sys_open>

00000000008000fa <close>:
  8000fa:	b7d9                	j	8000c0 <sys_close>

00000000008000fc <dup2>:
  8000fc:	b7f1                	j	8000c8 <sys_dup>

00000000008000fe <cputch>:
  8000fe:	1101                	addi	sp,sp,-32
  800100:	ec06                	sd	ra,24(sp)
  800102:	e42e                	sd	a1,8(sp)
  800104:	fadff0ef          	jal	8000b0 <sys_putc>
  800108:	65a2                	ld	a1,8(sp)
  80010a:	60e2                	ld	ra,24(sp)
  80010c:	419c                	lw	a5,0(a1)
  80010e:	2785                	addiw	a5,a5,1
  800110:	c19c                	sw	a5,0(a1)
  800112:	6105                	addi	sp,sp,32
  800114:	8082                	ret

0000000000800116 <vcprintf>:
  800116:	1101                	addi	sp,sp,-32
  800118:	872e                	mv	a4,a1
  80011a:	75dd                	lui	a1,0xffff7
  80011c:	86aa                	mv	a3,a0
  80011e:	0070                	addi	a2,sp,12
  800120:	00000517          	auipc	a0,0x0
  800124:	fde50513          	addi	a0,a0,-34 # 8000fe <cputch>
  800128:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ef9>
  80012c:	ec06                	sd	ra,24(sp)
  80012e:	c602                	sw	zero,12(sp)
  800130:	1ba000ef          	jal	8002ea <vprintfmt>
  800134:	60e2                	ld	ra,24(sp)
  800136:	4532                	lw	a0,12(sp)
  800138:	6105                	addi	sp,sp,32
  80013a:	8082                	ret

000000000080013c <cprintf>:
  80013c:	711d                	addi	sp,sp,-96
  80013e:	02810313          	addi	t1,sp,40
  800142:	f42e                	sd	a1,40(sp)
  800144:	75dd                	lui	a1,0xffff7
  800146:	f832                	sd	a2,48(sp)
  800148:	fc36                	sd	a3,56(sp)
  80014a:	e0ba                	sd	a4,64(sp)
  80014c:	86aa                	mv	a3,a0
  80014e:	0050                	addi	a2,sp,4
  800150:	00000517          	auipc	a0,0x0
  800154:	fae50513          	addi	a0,a0,-82 # 8000fe <cputch>
  800158:	871a                	mv	a4,t1
  80015a:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ef9>
  80015e:	ec06                	sd	ra,24(sp)
  800160:	e4be                	sd	a5,72(sp)
  800162:	e8c2                	sd	a6,80(sp)
  800164:	ecc6                	sd	a7,88(sp)
  800166:	c202                	sw	zero,4(sp)
  800168:	e41a                	sd	t1,8(sp)
  80016a:	180000ef          	jal	8002ea <vprintfmt>
  80016e:	60e2                	ld	ra,24(sp)
  800170:	4512                	lw	a0,4(sp)
  800172:	6125                	addi	sp,sp,96
  800174:	8082                	ret

0000000000800176 <initfd>:
  800176:	87ae                	mv	a5,a1
  800178:	1101                	addi	sp,sp,-32
  80017a:	e822                	sd	s0,16(sp)
  80017c:	85b2                	mv	a1,a2
  80017e:	842a                	mv	s0,a0
  800180:	853e                	mv	a0,a5
  800182:	ec06                	sd	ra,24(sp)
  800184:	f71ff0ef          	jal	8000f4 <open>
  800188:	87aa                	mv	a5,a0
  80018a:	00054463          	bltz	a0,800192 <initfd+0x1c>
  80018e:	00851763          	bne	a0,s0,80019c <initfd+0x26>
  800192:	60e2                	ld	ra,24(sp)
  800194:	6442                	ld	s0,16(sp)
  800196:	853e                	mv	a0,a5
  800198:	6105                	addi	sp,sp,32
  80019a:	8082                	ret
  80019c:	e42a                	sd	a0,8(sp)
  80019e:	8522                	mv	a0,s0
  8001a0:	f5bff0ef          	jal	8000fa <close>
  8001a4:	6522                	ld	a0,8(sp)
  8001a6:	85a2                	mv	a1,s0
  8001a8:	f55ff0ef          	jal	8000fc <dup2>
  8001ac:	842a                	mv	s0,a0
  8001ae:	6522                	ld	a0,8(sp)
  8001b0:	f4bff0ef          	jal	8000fa <close>
  8001b4:	87a2                	mv	a5,s0
  8001b6:	bff1                	j	800192 <initfd+0x1c>

00000000008001b8 <umain>:
  8001b8:	1101                	addi	sp,sp,-32
  8001ba:	e822                	sd	s0,16(sp)
  8001bc:	e426                	sd	s1,8(sp)
  8001be:	842a                	mv	s0,a0
  8001c0:	84ae                	mv	s1,a1
  8001c2:	4601                	li	a2,0
  8001c4:	00000597          	auipc	a1,0x0
  8001c8:	62c58593          	addi	a1,a1,1580 # 8007f0 <main+0x72>
  8001cc:	4501                	li	a0,0
  8001ce:	ec06                	sd	ra,24(sp)
  8001d0:	fa7ff0ef          	jal	800176 <initfd>
  8001d4:	02054263          	bltz	a0,8001f8 <umain+0x40>
  8001d8:	4605                	li	a2,1
  8001da:	8532                	mv	a0,a2
  8001dc:	00000597          	auipc	a1,0x0
  8001e0:	65458593          	addi	a1,a1,1620 # 800830 <main+0xb2>
  8001e4:	f93ff0ef          	jal	800176 <initfd>
  8001e8:	02054563          	bltz	a0,800212 <umain+0x5a>
  8001ec:	85a6                	mv	a1,s1
  8001ee:	8522                	mv	a0,s0
  8001f0:	58e000ef          	jal	80077e <main>
  8001f4:	edfff0ef          	jal	8000d2 <exit>
  8001f8:	86aa                	mv	a3,a0
  8001fa:	00000617          	auipc	a2,0x0
  8001fe:	5fe60613          	addi	a2,a2,1534 # 8007f8 <main+0x7a>
  800202:	45e9                	li	a1,26
  800204:	00000517          	auipc	a0,0x0
  800208:	61450513          	addi	a0,a0,1556 # 800818 <main+0x9a>
  80020c:	e15ff0ef          	jal	800020 <__warn>
  800210:	b7e1                	j	8001d8 <umain+0x20>
  800212:	86aa                	mv	a3,a0
  800214:	00000617          	auipc	a2,0x0
  800218:	62460613          	addi	a2,a2,1572 # 800838 <main+0xba>
  80021c:	45f5                	li	a1,29
  80021e:	00000517          	auipc	a0,0x0
  800222:	5fa50513          	addi	a0,a0,1530 # 800818 <main+0x9a>
  800226:	dfbff0ef          	jal	800020 <__warn>
  80022a:	b7c9                	j	8001ec <umain+0x34>

000000000080022c <strlen>:
  80022c:	00054783          	lbu	a5,0(a0)
  800230:	cb81                	beqz	a5,800240 <strlen+0x14>
  800232:	4781                	li	a5,0
  800234:	0785                	addi	a5,a5,1
  800236:	00f50733          	add	a4,a0,a5
  80023a:	00074703          	lbu	a4,0(a4)
  80023e:	fb7d                	bnez	a4,800234 <strlen+0x8>
  800240:	853e                	mv	a0,a5
  800242:	8082                	ret

0000000000800244 <strnlen>:
  800244:	4781                	li	a5,0
  800246:	e589                	bnez	a1,800250 <strnlen+0xc>
  800248:	a811                	j	80025c <strnlen+0x18>
  80024a:	0785                	addi	a5,a5,1
  80024c:	00f58863          	beq	a1,a5,80025c <strnlen+0x18>
  800250:	00f50733          	add	a4,a0,a5
  800254:	00074703          	lbu	a4,0(a4)
  800258:	fb6d                	bnez	a4,80024a <strnlen+0x6>
  80025a:	85be                	mv	a1,a5
  80025c:	852e                	mv	a0,a1
  80025e:	8082                	ret

0000000000800260 <printnum>:
  800260:	7139                	addi	sp,sp,-64
  800262:	02071893          	slli	a7,a4,0x20
  800266:	f822                	sd	s0,48(sp)
  800268:	f426                	sd	s1,40(sp)
  80026a:	f04a                	sd	s2,32(sp)
  80026c:	ec4e                	sd	s3,24(sp)
  80026e:	e456                	sd	s5,8(sp)
  800270:	0208d893          	srli	a7,a7,0x20
  800274:	fc06                	sd	ra,56(sp)
  800276:	0316fab3          	remu	s5,a3,a7
  80027a:	fff7841b          	addiw	s0,a5,-1
  80027e:	84aa                	mv	s1,a0
  800280:	89ae                	mv	s3,a1
  800282:	8932                	mv	s2,a2
  800284:	0516f063          	bgeu	a3,a7,8002c4 <printnum+0x64>
  800288:	e852                	sd	s4,16(sp)
  80028a:	4705                	li	a4,1
  80028c:	8a42                	mv	s4,a6
  80028e:	00f75863          	bge	a4,a5,80029e <printnum+0x3e>
  800292:	864e                	mv	a2,s3
  800294:	85ca                	mv	a1,s2
  800296:	8552                	mv	a0,s4
  800298:	347d                	addiw	s0,s0,-1
  80029a:	9482                	jalr	s1
  80029c:	f87d                	bnez	s0,800292 <printnum+0x32>
  80029e:	6a42                	ld	s4,16(sp)
  8002a0:	00000797          	auipc	a5,0x0
  8002a4:	5b878793          	addi	a5,a5,1464 # 800858 <main+0xda>
  8002a8:	97d6                	add	a5,a5,s5
  8002aa:	7442                	ld	s0,48(sp)
  8002ac:	0007c503          	lbu	a0,0(a5)
  8002b0:	70e2                	ld	ra,56(sp)
  8002b2:	6aa2                	ld	s5,8(sp)
  8002b4:	864e                	mv	a2,s3
  8002b6:	85ca                	mv	a1,s2
  8002b8:	69e2                	ld	s3,24(sp)
  8002ba:	7902                	ld	s2,32(sp)
  8002bc:	87a6                	mv	a5,s1
  8002be:	74a2                	ld	s1,40(sp)
  8002c0:	6121                	addi	sp,sp,64
  8002c2:	8782                	jr	a5
  8002c4:	0316d6b3          	divu	a3,a3,a7
  8002c8:	87a2                	mv	a5,s0
  8002ca:	f97ff0ef          	jal	800260 <printnum>
  8002ce:	bfc9                	j	8002a0 <printnum+0x40>

00000000008002d0 <sprintputch>:
  8002d0:	499c                	lw	a5,16(a1)
  8002d2:	6198                	ld	a4,0(a1)
  8002d4:	6594                	ld	a3,8(a1)
  8002d6:	2785                	addiw	a5,a5,1
  8002d8:	c99c                	sw	a5,16(a1)
  8002da:	00d77763          	bgeu	a4,a3,8002e8 <sprintputch+0x18>
  8002de:	00170793          	addi	a5,a4,1
  8002e2:	e19c                	sd	a5,0(a1)
  8002e4:	00a70023          	sb	a0,0(a4)
  8002e8:	8082                	ret

00000000008002ea <vprintfmt>:
  8002ea:	7119                	addi	sp,sp,-128
  8002ec:	f4a6                	sd	s1,104(sp)
  8002ee:	f0ca                	sd	s2,96(sp)
  8002f0:	ecce                	sd	s3,88(sp)
  8002f2:	e8d2                	sd	s4,80(sp)
  8002f4:	e4d6                	sd	s5,72(sp)
  8002f6:	e0da                	sd	s6,64(sp)
  8002f8:	fc5e                	sd	s7,56(sp)
  8002fa:	f466                	sd	s9,40(sp)
  8002fc:	fc86                	sd	ra,120(sp)
  8002fe:	f8a2                	sd	s0,112(sp)
  800300:	f862                	sd	s8,48(sp)
  800302:	f06a                	sd	s10,32(sp)
  800304:	ec6e                	sd	s11,24(sp)
  800306:	84aa                	mv	s1,a0
  800308:	8cb6                	mv	s9,a3
  80030a:	8aba                	mv	s5,a4
  80030c:	89ae                	mv	s3,a1
  80030e:	8932                	mv	s2,a2
  800310:	02500a13          	li	s4,37
  800314:	05500b93          	li	s7,85
  800318:	00000b17          	auipc	s6,0x0
  80031c:	770b0b13          	addi	s6,s6,1904 # 800a88 <main+0x30a>
  800320:	000cc503          	lbu	a0,0(s9)
  800324:	001c8413          	addi	s0,s9,1
  800328:	01450b63          	beq	a0,s4,80033e <vprintfmt+0x54>
  80032c:	cd15                	beqz	a0,800368 <vprintfmt+0x7e>
  80032e:	864e                	mv	a2,s3
  800330:	85ca                	mv	a1,s2
  800332:	9482                	jalr	s1
  800334:	00044503          	lbu	a0,0(s0)
  800338:	0405                	addi	s0,s0,1
  80033a:	ff4519e3          	bne	a0,s4,80032c <vprintfmt+0x42>
  80033e:	5d7d                	li	s10,-1
  800340:	8dea                	mv	s11,s10
  800342:	02000813          	li	a6,32
  800346:	4c01                	li	s8,0
  800348:	4581                	li	a1,0
  80034a:	00044703          	lbu	a4,0(s0)
  80034e:	00140c93          	addi	s9,s0,1
  800352:	fdd7061b          	addiw	a2,a4,-35
  800356:	0ff67613          	zext.b	a2,a2
  80035a:	02cbe663          	bltu	s7,a2,800386 <vprintfmt+0x9c>
  80035e:	060a                	slli	a2,a2,0x2
  800360:	965a                	add	a2,a2,s6
  800362:	421c                	lw	a5,0(a2)
  800364:	97da                	add	a5,a5,s6
  800366:	8782                	jr	a5
  800368:	70e6                	ld	ra,120(sp)
  80036a:	7446                	ld	s0,112(sp)
  80036c:	74a6                	ld	s1,104(sp)
  80036e:	7906                	ld	s2,96(sp)
  800370:	69e6                	ld	s3,88(sp)
  800372:	6a46                	ld	s4,80(sp)
  800374:	6aa6                	ld	s5,72(sp)
  800376:	6b06                	ld	s6,64(sp)
  800378:	7be2                	ld	s7,56(sp)
  80037a:	7c42                	ld	s8,48(sp)
  80037c:	7ca2                	ld	s9,40(sp)
  80037e:	7d02                	ld	s10,32(sp)
  800380:	6de2                	ld	s11,24(sp)
  800382:	6109                	addi	sp,sp,128
  800384:	8082                	ret
  800386:	864e                	mv	a2,s3
  800388:	85ca                	mv	a1,s2
  80038a:	02500513          	li	a0,37
  80038e:	9482                	jalr	s1
  800390:	fff44783          	lbu	a5,-1(s0)
  800394:	02500713          	li	a4,37
  800398:	8ca2                	mv	s9,s0
  80039a:	f8e783e3          	beq	a5,a4,800320 <vprintfmt+0x36>
  80039e:	ffecc783          	lbu	a5,-2(s9)
  8003a2:	1cfd                	addi	s9,s9,-1
  8003a4:	fee79de3          	bne	a5,a4,80039e <vprintfmt+0xb4>
  8003a8:	bfa5                	j	800320 <vprintfmt+0x36>
  8003aa:	00144683          	lbu	a3,1(s0)
  8003ae:	4525                	li	a0,9
  8003b0:	fd070d1b          	addiw	s10,a4,-48
  8003b4:	fd06879b          	addiw	a5,a3,-48
  8003b8:	28f56063          	bltu	a0,a5,800638 <vprintfmt+0x34e>
  8003bc:	2681                	sext.w	a3,a3
  8003be:	8466                	mv	s0,s9
  8003c0:	002d179b          	slliw	a5,s10,0x2
  8003c4:	00144703          	lbu	a4,1(s0)
  8003c8:	01a787bb          	addw	a5,a5,s10
  8003cc:	0017979b          	slliw	a5,a5,0x1
  8003d0:	9fb5                	addw	a5,a5,a3
  8003d2:	fd07061b          	addiw	a2,a4,-48
  8003d6:	0405                	addi	s0,s0,1
  8003d8:	fd078d1b          	addiw	s10,a5,-48
  8003dc:	0007069b          	sext.w	a3,a4
  8003e0:	fec570e3          	bgeu	a0,a2,8003c0 <vprintfmt+0xd6>
  8003e4:	f60dd3e3          	bgez	s11,80034a <vprintfmt+0x60>
  8003e8:	8dea                	mv	s11,s10
  8003ea:	5d7d                	li	s10,-1
  8003ec:	bfb9                	j	80034a <vprintfmt+0x60>
  8003ee:	883a                	mv	a6,a4
  8003f0:	8466                	mv	s0,s9
  8003f2:	bfa1                	j	80034a <vprintfmt+0x60>
  8003f4:	8466                	mv	s0,s9
  8003f6:	4c05                	li	s8,1
  8003f8:	bf89                	j	80034a <vprintfmt+0x60>
  8003fa:	4785                	li	a5,1
  8003fc:	008a8613          	addi	a2,s5,8
  800400:	00b7c463          	blt	a5,a1,800408 <vprintfmt+0x11e>
  800404:	1c058363          	beqz	a1,8005ca <vprintfmt+0x2e0>
  800408:	000ab683          	ld	a3,0(s5)
  80040c:	4741                	li	a4,16
  80040e:	8ab2                	mv	s5,a2
  800410:	2801                	sext.w	a6,a6
  800412:	87ee                	mv	a5,s11
  800414:	864a                	mv	a2,s2
  800416:	85ce                	mv	a1,s3
  800418:	8526                	mv	a0,s1
  80041a:	e47ff0ef          	jal	800260 <printnum>
  80041e:	b709                	j	800320 <vprintfmt+0x36>
  800420:	000aa503          	lw	a0,0(s5)
  800424:	864e                	mv	a2,s3
  800426:	85ca                	mv	a1,s2
  800428:	9482                	jalr	s1
  80042a:	0aa1                	addi	s5,s5,8
  80042c:	bdd5                	j	800320 <vprintfmt+0x36>
  80042e:	4785                	li	a5,1
  800430:	008a8613          	addi	a2,s5,8
  800434:	00b7c463          	blt	a5,a1,80043c <vprintfmt+0x152>
  800438:	18058463          	beqz	a1,8005c0 <vprintfmt+0x2d6>
  80043c:	000ab683          	ld	a3,0(s5)
  800440:	4729                	li	a4,10
  800442:	8ab2                	mv	s5,a2
  800444:	b7f1                	j	800410 <vprintfmt+0x126>
  800446:	864e                	mv	a2,s3
  800448:	85ca                	mv	a1,s2
  80044a:	03000513          	li	a0,48
  80044e:	e042                	sd	a6,0(sp)
  800450:	9482                	jalr	s1
  800452:	864e                	mv	a2,s3
  800454:	85ca                	mv	a1,s2
  800456:	07800513          	li	a0,120
  80045a:	9482                	jalr	s1
  80045c:	000ab683          	ld	a3,0(s5)
  800460:	6802                	ld	a6,0(sp)
  800462:	4741                	li	a4,16
  800464:	0aa1                	addi	s5,s5,8
  800466:	b76d                	j	800410 <vprintfmt+0x126>
  800468:	864e                	mv	a2,s3
  80046a:	85ca                	mv	a1,s2
  80046c:	02500513          	li	a0,37
  800470:	9482                	jalr	s1
  800472:	b57d                	j	800320 <vprintfmt+0x36>
  800474:	000aad03          	lw	s10,0(s5)
  800478:	8466                	mv	s0,s9
  80047a:	0aa1                	addi	s5,s5,8
  80047c:	b7a5                	j	8003e4 <vprintfmt+0xfa>
  80047e:	4785                	li	a5,1
  800480:	008a8613          	addi	a2,s5,8
  800484:	00b7c463          	blt	a5,a1,80048c <vprintfmt+0x1a2>
  800488:	12058763          	beqz	a1,8005b6 <vprintfmt+0x2cc>
  80048c:	000ab683          	ld	a3,0(s5)
  800490:	4721                	li	a4,8
  800492:	8ab2                	mv	s5,a2
  800494:	bfb5                	j	800410 <vprintfmt+0x126>
  800496:	87ee                	mv	a5,s11
  800498:	000dd363          	bgez	s11,80049e <vprintfmt+0x1b4>
  80049c:	4781                	li	a5,0
  80049e:	00078d9b          	sext.w	s11,a5
  8004a2:	8466                	mv	s0,s9
  8004a4:	b55d                	j	80034a <vprintfmt+0x60>
  8004a6:	0008041b          	sext.w	s0,a6
  8004aa:	fd340793          	addi	a5,s0,-45
  8004ae:	01b02733          	sgtz	a4,s11
  8004b2:	00f037b3          	snez	a5,a5
  8004b6:	8ff9                	and	a5,a5,a4
  8004b8:	000ab703          	ld	a4,0(s5)
  8004bc:	008a8693          	addi	a3,s5,8
  8004c0:	e436                	sd	a3,8(sp)
  8004c2:	12070563          	beqz	a4,8005ec <vprintfmt+0x302>
  8004c6:	12079d63          	bnez	a5,800600 <vprintfmt+0x316>
  8004ca:	00074783          	lbu	a5,0(a4)
  8004ce:	0007851b          	sext.w	a0,a5
  8004d2:	c78d                	beqz	a5,8004fc <vprintfmt+0x212>
  8004d4:	00170a93          	addi	s5,a4,1
  8004d8:	547d                	li	s0,-1
  8004da:	000d4563          	bltz	s10,8004e4 <vprintfmt+0x1fa>
  8004de:	3d7d                	addiw	s10,s10,-1
  8004e0:	008d0e63          	beq	s10,s0,8004fc <vprintfmt+0x212>
  8004e4:	020c1863          	bnez	s8,800514 <vprintfmt+0x22a>
  8004e8:	864e                	mv	a2,s3
  8004ea:	85ca                	mv	a1,s2
  8004ec:	9482                	jalr	s1
  8004ee:	000ac783          	lbu	a5,0(s5)
  8004f2:	0a85                	addi	s5,s5,1
  8004f4:	3dfd                	addiw	s11,s11,-1
  8004f6:	0007851b          	sext.w	a0,a5
  8004fa:	f3e5                	bnez	a5,8004da <vprintfmt+0x1f0>
  8004fc:	01b05a63          	blez	s11,800510 <vprintfmt+0x226>
  800500:	864e                	mv	a2,s3
  800502:	85ca                	mv	a1,s2
  800504:	02000513          	li	a0,32
  800508:	3dfd                	addiw	s11,s11,-1
  80050a:	9482                	jalr	s1
  80050c:	fe0d9ae3          	bnez	s11,800500 <vprintfmt+0x216>
  800510:	6aa2                	ld	s5,8(sp)
  800512:	b539                	j	800320 <vprintfmt+0x36>
  800514:	3781                	addiw	a5,a5,-32
  800516:	05e00713          	li	a4,94
  80051a:	fcf777e3          	bgeu	a4,a5,8004e8 <vprintfmt+0x1fe>
  80051e:	03f00513          	li	a0,63
  800522:	864e                	mv	a2,s3
  800524:	85ca                	mv	a1,s2
  800526:	9482                	jalr	s1
  800528:	000ac783          	lbu	a5,0(s5)
  80052c:	0a85                	addi	s5,s5,1
  80052e:	3dfd                	addiw	s11,s11,-1
  800530:	0007851b          	sext.w	a0,a5
  800534:	d7e1                	beqz	a5,8004fc <vprintfmt+0x212>
  800536:	fa0d54e3          	bgez	s10,8004de <vprintfmt+0x1f4>
  80053a:	bfe9                	j	800514 <vprintfmt+0x22a>
  80053c:	000aa783          	lw	a5,0(s5)
  800540:	46e1                	li	a3,24
  800542:	0aa1                	addi	s5,s5,8
  800544:	41f7d71b          	sraiw	a4,a5,0x1f
  800548:	8fb9                	xor	a5,a5,a4
  80054a:	40e7873b          	subw	a4,a5,a4
  80054e:	02e6c663          	blt	a3,a4,80057a <vprintfmt+0x290>
  800552:	00000797          	auipc	a5,0x0
  800556:	68e78793          	addi	a5,a5,1678 # 800be0 <error_string>
  80055a:	00371693          	slli	a3,a4,0x3
  80055e:	97b6                	add	a5,a5,a3
  800560:	639c                	ld	a5,0(a5)
  800562:	cf81                	beqz	a5,80057a <vprintfmt+0x290>
  800564:	873e                	mv	a4,a5
  800566:	00000697          	auipc	a3,0x0
  80056a:	32268693          	addi	a3,a3,802 # 800888 <main+0x10a>
  80056e:	864a                	mv	a2,s2
  800570:	85ce                	mv	a1,s3
  800572:	8526                	mv	a0,s1
  800574:	0f2000ef          	jal	800666 <printfmt>
  800578:	b365                	j	800320 <vprintfmt+0x36>
  80057a:	00000697          	auipc	a3,0x0
  80057e:	2fe68693          	addi	a3,a3,766 # 800878 <main+0xfa>
  800582:	864a                	mv	a2,s2
  800584:	85ce                	mv	a1,s3
  800586:	8526                	mv	a0,s1
  800588:	0de000ef          	jal	800666 <printfmt>
  80058c:	bb51                	j	800320 <vprintfmt+0x36>
  80058e:	4785                	li	a5,1
  800590:	008a8c13          	addi	s8,s5,8
  800594:	00b7c363          	blt	a5,a1,80059a <vprintfmt+0x2b0>
  800598:	cd81                	beqz	a1,8005b0 <vprintfmt+0x2c6>
  80059a:	000ab403          	ld	s0,0(s5)
  80059e:	02044b63          	bltz	s0,8005d4 <vprintfmt+0x2ea>
  8005a2:	86a2                	mv	a3,s0
  8005a4:	8ae2                	mv	s5,s8
  8005a6:	4729                	li	a4,10
  8005a8:	b5a5                	j	800410 <vprintfmt+0x126>
  8005aa:	2585                	addiw	a1,a1,1
  8005ac:	8466                	mv	s0,s9
  8005ae:	bb71                	j	80034a <vprintfmt+0x60>
  8005b0:	000aa403          	lw	s0,0(s5)
  8005b4:	b7ed                	j	80059e <vprintfmt+0x2b4>
  8005b6:	000ae683          	lwu	a3,0(s5)
  8005ba:	4721                	li	a4,8
  8005bc:	8ab2                	mv	s5,a2
  8005be:	bd89                	j	800410 <vprintfmt+0x126>
  8005c0:	000ae683          	lwu	a3,0(s5)
  8005c4:	4729                	li	a4,10
  8005c6:	8ab2                	mv	s5,a2
  8005c8:	b5a1                	j	800410 <vprintfmt+0x126>
  8005ca:	000ae683          	lwu	a3,0(s5)
  8005ce:	4741                	li	a4,16
  8005d0:	8ab2                	mv	s5,a2
  8005d2:	bd3d                	j	800410 <vprintfmt+0x126>
  8005d4:	864e                	mv	a2,s3
  8005d6:	85ca                	mv	a1,s2
  8005d8:	02d00513          	li	a0,45
  8005dc:	e042                	sd	a6,0(sp)
  8005de:	9482                	jalr	s1
  8005e0:	6802                	ld	a6,0(sp)
  8005e2:	408006b3          	neg	a3,s0
  8005e6:	8ae2                	mv	s5,s8
  8005e8:	4729                	li	a4,10
  8005ea:	b51d                	j	800410 <vprintfmt+0x126>
  8005ec:	eba1                	bnez	a5,80063c <vprintfmt+0x352>
  8005ee:	02800793          	li	a5,40
  8005f2:	853e                	mv	a0,a5
  8005f4:	00000a97          	auipc	s5,0x0
  8005f8:	27da8a93          	addi	s5,s5,637 # 800871 <main+0xf3>
  8005fc:	547d                	li	s0,-1
  8005fe:	bdf1                	j	8004da <vprintfmt+0x1f0>
  800600:	853a                	mv	a0,a4
  800602:	85ea                	mv	a1,s10
  800604:	e03a                	sd	a4,0(sp)
  800606:	c3fff0ef          	jal	800244 <strnlen>
  80060a:	40ad8dbb          	subw	s11,s11,a0
  80060e:	6702                	ld	a4,0(sp)
  800610:	01b05b63          	blez	s11,800626 <vprintfmt+0x33c>
  800614:	864e                	mv	a2,s3
  800616:	85ca                	mv	a1,s2
  800618:	8522                	mv	a0,s0
  80061a:	e03a                	sd	a4,0(sp)
  80061c:	3dfd                	addiw	s11,s11,-1
  80061e:	9482                	jalr	s1
  800620:	6702                	ld	a4,0(sp)
  800622:	fe0d99e3          	bnez	s11,800614 <vprintfmt+0x32a>
  800626:	00074783          	lbu	a5,0(a4)
  80062a:	0007851b          	sext.w	a0,a5
  80062e:	ee0781e3          	beqz	a5,800510 <vprintfmt+0x226>
  800632:	00170a93          	addi	s5,a4,1
  800636:	b54d                	j	8004d8 <vprintfmt+0x1ee>
  800638:	8466                	mv	s0,s9
  80063a:	b36d                	j	8003e4 <vprintfmt+0xfa>
  80063c:	85ea                	mv	a1,s10
  80063e:	00000517          	auipc	a0,0x0
  800642:	23250513          	addi	a0,a0,562 # 800870 <main+0xf2>
  800646:	bffff0ef          	jal	800244 <strnlen>
  80064a:	40ad8dbb          	subw	s11,s11,a0
  80064e:	02800793          	li	a5,40
  800652:	00000717          	auipc	a4,0x0
  800656:	21e70713          	addi	a4,a4,542 # 800870 <main+0xf2>
  80065a:	853e                	mv	a0,a5
  80065c:	fbb04ce3          	bgtz	s11,800614 <vprintfmt+0x32a>
  800660:	00170a93          	addi	s5,a4,1
  800664:	bd95                	j	8004d8 <vprintfmt+0x1ee>

0000000000800666 <printfmt>:
  800666:	7139                	addi	sp,sp,-64
  800668:	02010313          	addi	t1,sp,32
  80066c:	f03a                	sd	a4,32(sp)
  80066e:	871a                	mv	a4,t1
  800670:	ec06                	sd	ra,24(sp)
  800672:	f43e                	sd	a5,40(sp)
  800674:	f842                	sd	a6,48(sp)
  800676:	fc46                	sd	a7,56(sp)
  800678:	e41a                	sd	t1,8(sp)
  80067a:	c71ff0ef          	jal	8002ea <vprintfmt>
  80067e:	60e2                	ld	ra,24(sp)
  800680:	6121                	addi	sp,sp,64
  800682:	8082                	ret

0000000000800684 <snprintf>:
  800684:	711d                	addi	sp,sp,-96
  800686:	15fd                	addi	a1,a1,-1
  800688:	95aa                	add	a1,a1,a0
  80068a:	03810313          	addi	t1,sp,56
  80068e:	f406                	sd	ra,40(sp)
  800690:	e82e                	sd	a1,16(sp)
  800692:	e42a                	sd	a0,8(sp)
  800694:	fc36                	sd	a3,56(sp)
  800696:	e0ba                	sd	a4,64(sp)
  800698:	e4be                	sd	a5,72(sp)
  80069a:	e8c2                	sd	a6,80(sp)
  80069c:	ecc6                	sd	a7,88(sp)
  80069e:	cc02                	sw	zero,24(sp)
  8006a0:	e01a                	sd	t1,0(sp)
  8006a2:	c515                	beqz	a0,8006ce <snprintf+0x4a>
  8006a4:	02a5e563          	bltu	a1,a0,8006ce <snprintf+0x4a>
  8006a8:	75dd                	lui	a1,0xffff7
  8006aa:	86b2                	mv	a3,a2
  8006ac:	00000517          	auipc	a0,0x0
  8006b0:	c2450513          	addi	a0,a0,-988 # 8002d0 <sprintputch>
  8006b4:	871a                	mv	a4,t1
  8006b6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ef9>
  8006ba:	0030                	addi	a2,sp,8
  8006bc:	c2fff0ef          	jal	8002ea <vprintfmt>
  8006c0:	67a2                	ld	a5,8(sp)
  8006c2:	00078023          	sb	zero,0(a5)
  8006c6:	4562                	lw	a0,24(sp)
  8006c8:	70a2                	ld	ra,40(sp)
  8006ca:	6125                	addi	sp,sp,96
  8006cc:	8082                	ret
  8006ce:	5575                	li	a0,-3
  8006d0:	bfe5                	j	8006c8 <snprintf+0x44>

00000000008006d2 <forktree>:
  8006d2:	1101                	addi	sp,sp,-32
  8006d4:	ec06                	sd	ra,24(sp)
  8006d6:	e822                	sd	s0,16(sp)
  8006d8:	842a                	mv	s0,a0
  8006da:	a13ff0ef          	jal	8000ec <getpid>
  8006de:	85aa                	mv	a1,a0
  8006e0:	8622                	mv	a2,s0
  8006e2:	00000517          	auipc	a0,0x0
  8006e6:	38650513          	addi	a0,a0,902 # 800a68 <main+0x2ea>
  8006ea:	a53ff0ef          	jal	80013c <cprintf>
  8006ee:	8522                	mv	a0,s0
  8006f0:	b3dff0ef          	jal	80022c <strlen>
  8006f4:	4789                	li	a5,2
  8006f6:	00a7f963          	bgeu	a5,a0,800708 <forktree+0x36>
  8006fa:	8522                	mv	a0,s0
  8006fc:	6442                	ld	s0,16(sp)
  8006fe:	60e2                	ld	ra,24(sp)
  800700:	03100593          	li	a1,49
  800704:	6105                	addi	sp,sp,32
  800706:	a03d                	j	800734 <forkchild>
  800708:	03000713          	li	a4,48
  80070c:	86a2                	mv	a3,s0
  80070e:	00000617          	auipc	a2,0x0
  800712:	37260613          	addi	a2,a2,882 # 800a80 <main+0x302>
  800716:	4591                	li	a1,4
  800718:	0028                	addi	a0,sp,8
  80071a:	f6bff0ef          	jal	800684 <snprintf>
  80071e:	9cbff0ef          	jal	8000e8 <fork>
  800722:	fd61                	bnez	a0,8006fa <forktree+0x28>
  800724:	0028                	addi	a0,sp,8
  800726:	fadff0ef          	jal	8006d2 <forktree>
  80072a:	9c1ff0ef          	jal	8000ea <yield>
  80072e:	4501                	li	a0,0
  800730:	9a3ff0ef          	jal	8000d2 <exit>

0000000000800734 <forkchild>:
  800734:	7179                	addi	sp,sp,-48
  800736:	f022                	sd	s0,32(sp)
  800738:	ec26                	sd	s1,24(sp)
  80073a:	f406                	sd	ra,40(sp)
  80073c:	84ae                	mv	s1,a1
  80073e:	842a                	mv	s0,a0
  800740:	aedff0ef          	jal	80022c <strlen>
  800744:	4789                	li	a5,2
  800746:	00a7f763          	bgeu	a5,a0,800754 <forkchild+0x20>
  80074a:	70a2                	ld	ra,40(sp)
  80074c:	7402                	ld	s0,32(sp)
  80074e:	64e2                	ld	s1,24(sp)
  800750:	6145                	addi	sp,sp,48
  800752:	8082                	ret
  800754:	8726                	mv	a4,s1
  800756:	86a2                	mv	a3,s0
  800758:	00000617          	auipc	a2,0x0
  80075c:	32860613          	addi	a2,a2,808 # 800a80 <main+0x302>
  800760:	4591                	li	a1,4
  800762:	0028                	addi	a0,sp,8
  800764:	f21ff0ef          	jal	800684 <snprintf>
  800768:	981ff0ef          	jal	8000e8 <fork>
  80076c:	fd79                	bnez	a0,80074a <forkchild+0x16>
  80076e:	0028                	addi	a0,sp,8
  800770:	f63ff0ef          	jal	8006d2 <forktree>
  800774:	977ff0ef          	jal	8000ea <yield>
  800778:	4501                	li	a0,0
  80077a:	959ff0ef          	jal	8000d2 <exit>

000000000080077e <main>:
  80077e:	1141                	addi	sp,sp,-16
  800780:	00000517          	auipc	a0,0x0
  800784:	2f850513          	addi	a0,a0,760 # 800a78 <main+0x2fa>
  800788:	e406                	sd	ra,8(sp)
  80078a:	f49ff0ef          	jal	8006d2 <forktree>
  80078e:	60a2                	ld	ra,8(sp)
  800790:	4501                	li	a0,0
  800792:	0141                	addi	sp,sp,16
  800794:	8082                	ret
