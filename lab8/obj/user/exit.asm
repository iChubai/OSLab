
obj/__user_exit.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	7a250513          	addi	a0,a0,1954 # 8007d0 <main+0x118>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	15e000ef          	jal	8001a2 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	130000ef          	jal	80017c <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	7a050513          	addi	a0,a0,1952 # 8007f0 <main+0x138>
  800058:	14a000ef          	jal	8001a2 <cprintf>
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
  800074:	78850513          	addi	a0,a0,1928 # 8007f8 <main+0x140>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	11c000ef          	jal	8001a2 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0ee000ef          	jal	80017c <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	75e50513          	addi	a0,a0,1886 # 8007f0 <main+0x138>
  80009a:	108000ef          	jal	8001a2 <cprintf>
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
  800124:	6f850513          	addi	a0,a0,1784 # 800818 <main+0x160>
  800128:	07a000ef          	jal	8001a2 <cprintf>
  80012c:	a001                	j	80012c <exit+0x14>

000000000080012e <fork>:
  80012e:	bf65                	j	8000e6 <sys_fork>

0000000000800130 <wait>:
  800130:	4581                	li	a1,0
  800132:	4501                	li	a0,0
  800134:	bf5d                	j	8000ea <sys_wait>

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

0000000000800152 <yield>:
  800152:	b745                	j	8000f2 <sys_yield>

0000000000800154 <_start>:
  800154:	0ca000ef          	jal	80021e <umain>
  800158:	a001                	j	800158 <_start+0x4>

000000000080015a <open>:
  80015a:	1582                	slli	a1,a1,0x20
  80015c:	9181                	srli	a1,a1,0x20
  80015e:	bf79                	j	8000fc <sys_open>

0000000000800160 <close>:
  800160:	b75d                	j	800106 <sys_close>

0000000000800162 <dup2>:
  800162:	b775                	j	80010e <sys_dup>

0000000000800164 <cputch>:
  800164:	1101                	addi	sp,sp,-32
  800166:	ec06                	sd	ra,24(sp)
  800168:	e42e                	sd	a1,8(sp)
  80016a:	f8dff0ef          	jal	8000f6 <sys_putc>
  80016e:	65a2                	ld	a1,8(sp)
  800170:	60e2                	ld	ra,24(sp)
  800172:	419c                	lw	a5,0(a1)
  800174:	2785                	addiw	a5,a5,1
  800176:	c19c                	sw	a5,0(a1)
  800178:	6105                	addi	sp,sp,32
  80017a:	8082                	ret

000000000080017c <vcprintf>:
  80017c:	1101                	addi	sp,sp,-32
  80017e:	872e                	mv	a4,a1
  800180:	75dd                	lui	a1,0xffff7
  800182:	86aa                	mv	a3,a0
  800184:	0070                	addi	a2,sp,12
  800186:	00000517          	auipc	a0,0x0
  80018a:	fde50513          	addi	a0,a0,-34 # 800164 <cputch>
  80018e:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <magic+0xffffffffff7f5ad9>
  800192:	ec06                	sd	ra,24(sp)
  800194:	c602                	sw	zero,12(sp)
  800196:	188000ef          	jal	80031e <vprintfmt>
  80019a:	60e2                	ld	ra,24(sp)
  80019c:	4532                	lw	a0,12(sp)
  80019e:	6105                	addi	sp,sp,32
  8001a0:	8082                	ret

00000000008001a2 <cprintf>:
  8001a2:	711d                	addi	sp,sp,-96
  8001a4:	02810313          	addi	t1,sp,40
  8001a8:	f42e                	sd	a1,40(sp)
  8001aa:	75dd                	lui	a1,0xffff7
  8001ac:	f832                	sd	a2,48(sp)
  8001ae:	fc36                	sd	a3,56(sp)
  8001b0:	e0ba                	sd	a4,64(sp)
  8001b2:	86aa                	mv	a3,a0
  8001b4:	0050                	addi	a2,sp,4
  8001b6:	00000517          	auipc	a0,0x0
  8001ba:	fae50513          	addi	a0,a0,-82 # 800164 <cputch>
  8001be:	871a                	mv	a4,t1
  8001c0:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <magic+0xffffffffff7f5ad9>
  8001c4:	ec06                	sd	ra,24(sp)
  8001c6:	e4be                	sd	a5,72(sp)
  8001c8:	e8c2                	sd	a6,80(sp)
  8001ca:	ecc6                	sd	a7,88(sp)
  8001cc:	c202                	sw	zero,4(sp)
  8001ce:	e41a                	sd	t1,8(sp)
  8001d0:	14e000ef          	jal	80031e <vprintfmt>
  8001d4:	60e2                	ld	ra,24(sp)
  8001d6:	4512                	lw	a0,4(sp)
  8001d8:	6125                	addi	sp,sp,96
  8001da:	8082                	ret

00000000008001dc <initfd>:
  8001dc:	87ae                	mv	a5,a1
  8001de:	1101                	addi	sp,sp,-32
  8001e0:	e822                	sd	s0,16(sp)
  8001e2:	85b2                	mv	a1,a2
  8001e4:	842a                	mv	s0,a0
  8001e6:	853e                	mv	a0,a5
  8001e8:	ec06                	sd	ra,24(sp)
  8001ea:	f71ff0ef          	jal	80015a <open>
  8001ee:	87aa                	mv	a5,a0
  8001f0:	00054463          	bltz	a0,8001f8 <initfd+0x1c>
  8001f4:	00851763          	bne	a0,s0,800202 <initfd+0x26>
  8001f8:	60e2                	ld	ra,24(sp)
  8001fa:	6442                	ld	s0,16(sp)
  8001fc:	853e                	mv	a0,a5
  8001fe:	6105                	addi	sp,sp,32
  800200:	8082                	ret
  800202:	e42a                	sd	a0,8(sp)
  800204:	8522                	mv	a0,s0
  800206:	f5bff0ef          	jal	800160 <close>
  80020a:	6522                	ld	a0,8(sp)
  80020c:	85a2                	mv	a1,s0
  80020e:	f55ff0ef          	jal	800162 <dup2>
  800212:	842a                	mv	s0,a0
  800214:	6522                	ld	a0,8(sp)
  800216:	f4bff0ef          	jal	800160 <close>
  80021a:	87a2                	mv	a5,s0
  80021c:	bff1                	j	8001f8 <initfd+0x1c>

000000000080021e <umain>:
  80021e:	1101                	addi	sp,sp,-32
  800220:	e822                	sd	s0,16(sp)
  800222:	e426                	sd	s1,8(sp)
  800224:	842a                	mv	s0,a0
  800226:	84ae                	mv	s1,a1
  800228:	4601                	li	a2,0
  80022a:	00000597          	auipc	a1,0x0
  80022e:	60658593          	addi	a1,a1,1542 # 800830 <main+0x178>
  800232:	4501                	li	a0,0
  800234:	ec06                	sd	ra,24(sp)
  800236:	fa7ff0ef          	jal	8001dc <initfd>
  80023a:	02054263          	bltz	a0,80025e <umain+0x40>
  80023e:	4605                	li	a2,1
  800240:	8532                	mv	a0,a2
  800242:	00000597          	auipc	a1,0x0
  800246:	62e58593          	addi	a1,a1,1582 # 800870 <main+0x1b8>
  80024a:	f93ff0ef          	jal	8001dc <initfd>
  80024e:	02054563          	bltz	a0,800278 <umain+0x5a>
  800252:	85a6                	mv	a1,s1
  800254:	8522                	mv	a0,s0
  800256:	462000ef          	jal	8006b8 <main>
  80025a:	ebfff0ef          	jal	800118 <exit>
  80025e:	86aa                	mv	a3,a0
  800260:	00000617          	auipc	a2,0x0
  800264:	5d860613          	addi	a2,a2,1496 # 800838 <main+0x180>
  800268:	45e9                	li	a1,26
  80026a:	00000517          	auipc	a0,0x0
  80026e:	5ee50513          	addi	a0,a0,1518 # 800858 <main+0x1a0>
  800272:	df1ff0ef          	jal	800062 <__warn>
  800276:	b7e1                	j	80023e <umain+0x20>
  800278:	86aa                	mv	a3,a0
  80027a:	00000617          	auipc	a2,0x0
  80027e:	5fe60613          	addi	a2,a2,1534 # 800878 <main+0x1c0>
  800282:	45f5                	li	a1,29
  800284:	00000517          	auipc	a0,0x0
  800288:	5d450513          	addi	a0,a0,1492 # 800858 <main+0x1a0>
  80028c:	dd7ff0ef          	jal	800062 <__warn>
  800290:	b7c9                	j	800252 <umain+0x34>

0000000000800292 <strnlen>:
  800292:	4781                	li	a5,0
  800294:	e589                	bnez	a1,80029e <strnlen+0xc>
  800296:	a811                	j	8002aa <strnlen+0x18>
  800298:	0785                	addi	a5,a5,1
  80029a:	00f58863          	beq	a1,a5,8002aa <strnlen+0x18>
  80029e:	00f50733          	add	a4,a0,a5
  8002a2:	00074703          	lbu	a4,0(a4)
  8002a6:	fb6d                	bnez	a4,800298 <strnlen+0x6>
  8002a8:	85be                	mv	a1,a5
  8002aa:	852e                	mv	a0,a1
  8002ac:	8082                	ret

00000000008002ae <printnum>:
  8002ae:	7139                	addi	sp,sp,-64
  8002b0:	02071893          	slli	a7,a4,0x20
  8002b4:	f822                	sd	s0,48(sp)
  8002b6:	f426                	sd	s1,40(sp)
  8002b8:	f04a                	sd	s2,32(sp)
  8002ba:	ec4e                	sd	s3,24(sp)
  8002bc:	e456                	sd	s5,8(sp)
  8002be:	0208d893          	srli	a7,a7,0x20
  8002c2:	fc06                	sd	ra,56(sp)
  8002c4:	0316fab3          	remu	s5,a3,a7
  8002c8:	fff7841b          	addiw	s0,a5,-1
  8002cc:	84aa                	mv	s1,a0
  8002ce:	89ae                	mv	s3,a1
  8002d0:	8932                	mv	s2,a2
  8002d2:	0516f063          	bgeu	a3,a7,800312 <printnum+0x64>
  8002d6:	e852                	sd	s4,16(sp)
  8002d8:	4705                	li	a4,1
  8002da:	8a42                	mv	s4,a6
  8002dc:	00f75863          	bge	a4,a5,8002ec <printnum+0x3e>
  8002e0:	864e                	mv	a2,s3
  8002e2:	85ca                	mv	a1,s2
  8002e4:	8552                	mv	a0,s4
  8002e6:	347d                	addiw	s0,s0,-1
  8002e8:	9482                	jalr	s1
  8002ea:	f87d                	bnez	s0,8002e0 <printnum+0x32>
  8002ec:	6a42                	ld	s4,16(sp)
  8002ee:	00000797          	auipc	a5,0x0
  8002f2:	5aa78793          	addi	a5,a5,1450 # 800898 <main+0x1e0>
  8002f6:	97d6                	add	a5,a5,s5
  8002f8:	7442                	ld	s0,48(sp)
  8002fa:	0007c503          	lbu	a0,0(a5)
  8002fe:	70e2                	ld	ra,56(sp)
  800300:	6aa2                	ld	s5,8(sp)
  800302:	864e                	mv	a2,s3
  800304:	85ca                	mv	a1,s2
  800306:	69e2                	ld	s3,24(sp)
  800308:	7902                	ld	s2,32(sp)
  80030a:	87a6                	mv	a5,s1
  80030c:	74a2                	ld	s1,40(sp)
  80030e:	6121                	addi	sp,sp,64
  800310:	8782                	jr	a5
  800312:	0316d6b3          	divu	a3,a3,a7
  800316:	87a2                	mv	a5,s0
  800318:	f97ff0ef          	jal	8002ae <printnum>
  80031c:	bfc9                	j	8002ee <printnum+0x40>

000000000080031e <vprintfmt>:
  80031e:	7119                	addi	sp,sp,-128
  800320:	f4a6                	sd	s1,104(sp)
  800322:	f0ca                	sd	s2,96(sp)
  800324:	ecce                	sd	s3,88(sp)
  800326:	e8d2                	sd	s4,80(sp)
  800328:	e4d6                	sd	s5,72(sp)
  80032a:	e0da                	sd	s6,64(sp)
  80032c:	fc5e                	sd	s7,56(sp)
  80032e:	f466                	sd	s9,40(sp)
  800330:	fc86                	sd	ra,120(sp)
  800332:	f8a2                	sd	s0,112(sp)
  800334:	f862                	sd	s8,48(sp)
  800336:	f06a                	sd	s10,32(sp)
  800338:	ec6e                	sd	s11,24(sp)
  80033a:	84aa                	mv	s1,a0
  80033c:	8cb6                	mv	s9,a3
  80033e:	8aba                	mv	s5,a4
  800340:	89ae                	mv	s3,a1
  800342:	8932                	mv	s2,a2
  800344:	02500a13          	li	s4,37
  800348:	05500b93          	li	s7,85
  80034c:	00001b17          	auipc	s6,0x1
  800350:	888b0b13          	addi	s6,s6,-1912 # 800bd4 <main+0x51c>
  800354:	000cc503          	lbu	a0,0(s9)
  800358:	001c8413          	addi	s0,s9,1
  80035c:	01450b63          	beq	a0,s4,800372 <vprintfmt+0x54>
  800360:	cd15                	beqz	a0,80039c <vprintfmt+0x7e>
  800362:	864e                	mv	a2,s3
  800364:	85ca                	mv	a1,s2
  800366:	9482                	jalr	s1
  800368:	00044503          	lbu	a0,0(s0)
  80036c:	0405                	addi	s0,s0,1
  80036e:	ff4519e3          	bne	a0,s4,800360 <vprintfmt+0x42>
  800372:	5d7d                	li	s10,-1
  800374:	8dea                	mv	s11,s10
  800376:	02000813          	li	a6,32
  80037a:	4c01                	li	s8,0
  80037c:	4581                	li	a1,0
  80037e:	00044703          	lbu	a4,0(s0)
  800382:	00140c93          	addi	s9,s0,1
  800386:	fdd7061b          	addiw	a2,a4,-35
  80038a:	0ff67613          	zext.b	a2,a2
  80038e:	02cbe663          	bltu	s7,a2,8003ba <vprintfmt+0x9c>
  800392:	060a                	slli	a2,a2,0x2
  800394:	965a                	add	a2,a2,s6
  800396:	421c                	lw	a5,0(a2)
  800398:	97da                	add	a5,a5,s6
  80039a:	8782                	jr	a5
  80039c:	70e6                	ld	ra,120(sp)
  80039e:	7446                	ld	s0,112(sp)
  8003a0:	74a6                	ld	s1,104(sp)
  8003a2:	7906                	ld	s2,96(sp)
  8003a4:	69e6                	ld	s3,88(sp)
  8003a6:	6a46                	ld	s4,80(sp)
  8003a8:	6aa6                	ld	s5,72(sp)
  8003aa:	6b06                	ld	s6,64(sp)
  8003ac:	7be2                	ld	s7,56(sp)
  8003ae:	7c42                	ld	s8,48(sp)
  8003b0:	7ca2                	ld	s9,40(sp)
  8003b2:	7d02                	ld	s10,32(sp)
  8003b4:	6de2                	ld	s11,24(sp)
  8003b6:	6109                	addi	sp,sp,128
  8003b8:	8082                	ret
  8003ba:	864e                	mv	a2,s3
  8003bc:	85ca                	mv	a1,s2
  8003be:	02500513          	li	a0,37
  8003c2:	9482                	jalr	s1
  8003c4:	fff44783          	lbu	a5,-1(s0)
  8003c8:	02500713          	li	a4,37
  8003cc:	8ca2                	mv	s9,s0
  8003ce:	f8e783e3          	beq	a5,a4,800354 <vprintfmt+0x36>
  8003d2:	ffecc783          	lbu	a5,-2(s9)
  8003d6:	1cfd                	addi	s9,s9,-1
  8003d8:	fee79de3          	bne	a5,a4,8003d2 <vprintfmt+0xb4>
  8003dc:	bfa5                	j	800354 <vprintfmt+0x36>
  8003de:	00144683          	lbu	a3,1(s0)
  8003e2:	4525                	li	a0,9
  8003e4:	fd070d1b          	addiw	s10,a4,-48
  8003e8:	fd06879b          	addiw	a5,a3,-48
  8003ec:	28f56063          	bltu	a0,a5,80066c <vprintfmt+0x34e>
  8003f0:	2681                	sext.w	a3,a3
  8003f2:	8466                	mv	s0,s9
  8003f4:	002d179b          	slliw	a5,s10,0x2
  8003f8:	00144703          	lbu	a4,1(s0)
  8003fc:	01a787bb          	addw	a5,a5,s10
  800400:	0017979b          	slliw	a5,a5,0x1
  800404:	9fb5                	addw	a5,a5,a3
  800406:	fd07061b          	addiw	a2,a4,-48
  80040a:	0405                	addi	s0,s0,1
  80040c:	fd078d1b          	addiw	s10,a5,-48
  800410:	0007069b          	sext.w	a3,a4
  800414:	fec570e3          	bgeu	a0,a2,8003f4 <vprintfmt+0xd6>
  800418:	f60dd3e3          	bgez	s11,80037e <vprintfmt+0x60>
  80041c:	8dea                	mv	s11,s10
  80041e:	5d7d                	li	s10,-1
  800420:	bfb9                	j	80037e <vprintfmt+0x60>
  800422:	883a                	mv	a6,a4
  800424:	8466                	mv	s0,s9
  800426:	bfa1                	j	80037e <vprintfmt+0x60>
  800428:	8466                	mv	s0,s9
  80042a:	4c05                	li	s8,1
  80042c:	bf89                	j	80037e <vprintfmt+0x60>
  80042e:	4785                	li	a5,1
  800430:	008a8613          	addi	a2,s5,8
  800434:	00b7c463          	blt	a5,a1,80043c <vprintfmt+0x11e>
  800438:	1c058363          	beqz	a1,8005fe <vprintfmt+0x2e0>
  80043c:	000ab683          	ld	a3,0(s5)
  800440:	4741                	li	a4,16
  800442:	8ab2                	mv	s5,a2
  800444:	2801                	sext.w	a6,a6
  800446:	87ee                	mv	a5,s11
  800448:	864a                	mv	a2,s2
  80044a:	85ce                	mv	a1,s3
  80044c:	8526                	mv	a0,s1
  80044e:	e61ff0ef          	jal	8002ae <printnum>
  800452:	b709                	j	800354 <vprintfmt+0x36>
  800454:	000aa503          	lw	a0,0(s5)
  800458:	864e                	mv	a2,s3
  80045a:	85ca                	mv	a1,s2
  80045c:	9482                	jalr	s1
  80045e:	0aa1                	addi	s5,s5,8
  800460:	bdd5                	j	800354 <vprintfmt+0x36>
  800462:	4785                	li	a5,1
  800464:	008a8613          	addi	a2,s5,8
  800468:	00b7c463          	blt	a5,a1,800470 <vprintfmt+0x152>
  80046c:	18058463          	beqz	a1,8005f4 <vprintfmt+0x2d6>
  800470:	000ab683          	ld	a3,0(s5)
  800474:	4729                	li	a4,10
  800476:	8ab2                	mv	s5,a2
  800478:	b7f1                	j	800444 <vprintfmt+0x126>
  80047a:	864e                	mv	a2,s3
  80047c:	85ca                	mv	a1,s2
  80047e:	03000513          	li	a0,48
  800482:	e042                	sd	a6,0(sp)
  800484:	9482                	jalr	s1
  800486:	864e                	mv	a2,s3
  800488:	85ca                	mv	a1,s2
  80048a:	07800513          	li	a0,120
  80048e:	9482                	jalr	s1
  800490:	000ab683          	ld	a3,0(s5)
  800494:	6802                	ld	a6,0(sp)
  800496:	4741                	li	a4,16
  800498:	0aa1                	addi	s5,s5,8
  80049a:	b76d                	j	800444 <vprintfmt+0x126>
  80049c:	864e                	mv	a2,s3
  80049e:	85ca                	mv	a1,s2
  8004a0:	02500513          	li	a0,37
  8004a4:	9482                	jalr	s1
  8004a6:	b57d                	j	800354 <vprintfmt+0x36>
  8004a8:	000aad03          	lw	s10,0(s5)
  8004ac:	8466                	mv	s0,s9
  8004ae:	0aa1                	addi	s5,s5,8
  8004b0:	b7a5                	j	800418 <vprintfmt+0xfa>
  8004b2:	4785                	li	a5,1
  8004b4:	008a8613          	addi	a2,s5,8
  8004b8:	00b7c463          	blt	a5,a1,8004c0 <vprintfmt+0x1a2>
  8004bc:	12058763          	beqz	a1,8005ea <vprintfmt+0x2cc>
  8004c0:	000ab683          	ld	a3,0(s5)
  8004c4:	4721                	li	a4,8
  8004c6:	8ab2                	mv	s5,a2
  8004c8:	bfb5                	j	800444 <vprintfmt+0x126>
  8004ca:	87ee                	mv	a5,s11
  8004cc:	000dd363          	bgez	s11,8004d2 <vprintfmt+0x1b4>
  8004d0:	4781                	li	a5,0
  8004d2:	00078d9b          	sext.w	s11,a5
  8004d6:	8466                	mv	s0,s9
  8004d8:	b55d                	j	80037e <vprintfmt+0x60>
  8004da:	0008041b          	sext.w	s0,a6
  8004de:	fd340793          	addi	a5,s0,-45
  8004e2:	01b02733          	sgtz	a4,s11
  8004e6:	00f037b3          	snez	a5,a5
  8004ea:	8ff9                	and	a5,a5,a4
  8004ec:	000ab703          	ld	a4,0(s5)
  8004f0:	008a8693          	addi	a3,s5,8
  8004f4:	e436                	sd	a3,8(sp)
  8004f6:	12070563          	beqz	a4,800620 <vprintfmt+0x302>
  8004fa:	12079d63          	bnez	a5,800634 <vprintfmt+0x316>
  8004fe:	00074783          	lbu	a5,0(a4)
  800502:	0007851b          	sext.w	a0,a5
  800506:	c78d                	beqz	a5,800530 <vprintfmt+0x212>
  800508:	00170a93          	addi	s5,a4,1
  80050c:	547d                	li	s0,-1
  80050e:	000d4563          	bltz	s10,800518 <vprintfmt+0x1fa>
  800512:	3d7d                	addiw	s10,s10,-1
  800514:	008d0e63          	beq	s10,s0,800530 <vprintfmt+0x212>
  800518:	020c1863          	bnez	s8,800548 <vprintfmt+0x22a>
  80051c:	864e                	mv	a2,s3
  80051e:	85ca                	mv	a1,s2
  800520:	9482                	jalr	s1
  800522:	000ac783          	lbu	a5,0(s5)
  800526:	0a85                	addi	s5,s5,1
  800528:	3dfd                	addiw	s11,s11,-1
  80052a:	0007851b          	sext.w	a0,a5
  80052e:	f3e5                	bnez	a5,80050e <vprintfmt+0x1f0>
  800530:	01b05a63          	blez	s11,800544 <vprintfmt+0x226>
  800534:	864e                	mv	a2,s3
  800536:	85ca                	mv	a1,s2
  800538:	02000513          	li	a0,32
  80053c:	3dfd                	addiw	s11,s11,-1
  80053e:	9482                	jalr	s1
  800540:	fe0d9ae3          	bnez	s11,800534 <vprintfmt+0x216>
  800544:	6aa2                	ld	s5,8(sp)
  800546:	b539                	j	800354 <vprintfmt+0x36>
  800548:	3781                	addiw	a5,a5,-32
  80054a:	05e00713          	li	a4,94
  80054e:	fcf777e3          	bgeu	a4,a5,80051c <vprintfmt+0x1fe>
  800552:	03f00513          	li	a0,63
  800556:	864e                	mv	a2,s3
  800558:	85ca                	mv	a1,s2
  80055a:	9482                	jalr	s1
  80055c:	000ac783          	lbu	a5,0(s5)
  800560:	0a85                	addi	s5,s5,1
  800562:	3dfd                	addiw	s11,s11,-1
  800564:	0007851b          	sext.w	a0,a5
  800568:	d7e1                	beqz	a5,800530 <vprintfmt+0x212>
  80056a:	fa0d54e3          	bgez	s10,800512 <vprintfmt+0x1f4>
  80056e:	bfe9                	j	800548 <vprintfmt+0x22a>
  800570:	000aa783          	lw	a5,0(s5)
  800574:	46e1                	li	a3,24
  800576:	0aa1                	addi	s5,s5,8
  800578:	41f7d71b          	sraiw	a4,a5,0x1f
  80057c:	8fb9                	xor	a5,a5,a4
  80057e:	40e7873b          	subw	a4,a5,a4
  800582:	02e6c663          	blt	a3,a4,8005ae <vprintfmt+0x290>
  800586:	00000797          	auipc	a5,0x0
  80058a:	7aa78793          	addi	a5,a5,1962 # 800d30 <error_string>
  80058e:	00371693          	slli	a3,a4,0x3
  800592:	97b6                	add	a5,a5,a3
  800594:	639c                	ld	a5,0(a5)
  800596:	cf81                	beqz	a5,8005ae <vprintfmt+0x290>
  800598:	873e                	mv	a4,a5
  80059a:	00000697          	auipc	a3,0x0
  80059e:	32e68693          	addi	a3,a3,814 # 8008c8 <main+0x210>
  8005a2:	864a                	mv	a2,s2
  8005a4:	85ce                	mv	a1,s3
  8005a6:	8526                	mv	a0,s1
  8005a8:	0f2000ef          	jal	80069a <printfmt>
  8005ac:	b365                	j	800354 <vprintfmt+0x36>
  8005ae:	00000697          	auipc	a3,0x0
  8005b2:	30a68693          	addi	a3,a3,778 # 8008b8 <main+0x200>
  8005b6:	864a                	mv	a2,s2
  8005b8:	85ce                	mv	a1,s3
  8005ba:	8526                	mv	a0,s1
  8005bc:	0de000ef          	jal	80069a <printfmt>
  8005c0:	bb51                	j	800354 <vprintfmt+0x36>
  8005c2:	4785                	li	a5,1
  8005c4:	008a8c13          	addi	s8,s5,8
  8005c8:	00b7c363          	blt	a5,a1,8005ce <vprintfmt+0x2b0>
  8005cc:	cd81                	beqz	a1,8005e4 <vprintfmt+0x2c6>
  8005ce:	000ab403          	ld	s0,0(s5)
  8005d2:	02044b63          	bltz	s0,800608 <vprintfmt+0x2ea>
  8005d6:	86a2                	mv	a3,s0
  8005d8:	8ae2                	mv	s5,s8
  8005da:	4729                	li	a4,10
  8005dc:	b5a5                	j	800444 <vprintfmt+0x126>
  8005de:	2585                	addiw	a1,a1,1
  8005e0:	8466                	mv	s0,s9
  8005e2:	bb71                	j	80037e <vprintfmt+0x60>
  8005e4:	000aa403          	lw	s0,0(s5)
  8005e8:	b7ed                	j	8005d2 <vprintfmt+0x2b4>
  8005ea:	000ae683          	lwu	a3,0(s5)
  8005ee:	4721                	li	a4,8
  8005f0:	8ab2                	mv	s5,a2
  8005f2:	bd89                	j	800444 <vprintfmt+0x126>
  8005f4:	000ae683          	lwu	a3,0(s5)
  8005f8:	4729                	li	a4,10
  8005fa:	8ab2                	mv	s5,a2
  8005fc:	b5a1                	j	800444 <vprintfmt+0x126>
  8005fe:	000ae683          	lwu	a3,0(s5)
  800602:	4741                	li	a4,16
  800604:	8ab2                	mv	s5,a2
  800606:	bd3d                	j	800444 <vprintfmt+0x126>
  800608:	864e                	mv	a2,s3
  80060a:	85ca                	mv	a1,s2
  80060c:	02d00513          	li	a0,45
  800610:	e042                	sd	a6,0(sp)
  800612:	9482                	jalr	s1
  800614:	6802                	ld	a6,0(sp)
  800616:	408006b3          	neg	a3,s0
  80061a:	8ae2                	mv	s5,s8
  80061c:	4729                	li	a4,10
  80061e:	b51d                	j	800444 <vprintfmt+0x126>
  800620:	eba1                	bnez	a5,800670 <vprintfmt+0x352>
  800622:	02800793          	li	a5,40
  800626:	853e                	mv	a0,a5
  800628:	00000a97          	auipc	s5,0x0
  80062c:	289a8a93          	addi	s5,s5,649 # 8008b1 <main+0x1f9>
  800630:	547d                	li	s0,-1
  800632:	bdf1                	j	80050e <vprintfmt+0x1f0>
  800634:	853a                	mv	a0,a4
  800636:	85ea                	mv	a1,s10
  800638:	e03a                	sd	a4,0(sp)
  80063a:	c59ff0ef          	jal	800292 <strnlen>
  80063e:	40ad8dbb          	subw	s11,s11,a0
  800642:	6702                	ld	a4,0(sp)
  800644:	01b05b63          	blez	s11,80065a <vprintfmt+0x33c>
  800648:	864e                	mv	a2,s3
  80064a:	85ca                	mv	a1,s2
  80064c:	8522                	mv	a0,s0
  80064e:	e03a                	sd	a4,0(sp)
  800650:	3dfd                	addiw	s11,s11,-1
  800652:	9482                	jalr	s1
  800654:	6702                	ld	a4,0(sp)
  800656:	fe0d99e3          	bnez	s11,800648 <vprintfmt+0x32a>
  80065a:	00074783          	lbu	a5,0(a4)
  80065e:	0007851b          	sext.w	a0,a5
  800662:	ee0781e3          	beqz	a5,800544 <vprintfmt+0x226>
  800666:	00170a93          	addi	s5,a4,1
  80066a:	b54d                	j	80050c <vprintfmt+0x1ee>
  80066c:	8466                	mv	s0,s9
  80066e:	b36d                	j	800418 <vprintfmt+0xfa>
  800670:	85ea                	mv	a1,s10
  800672:	00000517          	auipc	a0,0x0
  800676:	23e50513          	addi	a0,a0,574 # 8008b0 <main+0x1f8>
  80067a:	c19ff0ef          	jal	800292 <strnlen>
  80067e:	40ad8dbb          	subw	s11,s11,a0
  800682:	02800793          	li	a5,40
  800686:	00000717          	auipc	a4,0x0
  80068a:	22a70713          	addi	a4,a4,554 # 8008b0 <main+0x1f8>
  80068e:	853e                	mv	a0,a5
  800690:	fbb04ce3          	bgtz	s11,800648 <vprintfmt+0x32a>
  800694:	00170a93          	addi	s5,a4,1
  800698:	bd95                	j	80050c <vprintfmt+0x1ee>

000000000080069a <printfmt>:
  80069a:	7139                	addi	sp,sp,-64
  80069c:	02010313          	addi	t1,sp,32
  8006a0:	f03a                	sd	a4,32(sp)
  8006a2:	871a                	mv	a4,t1
  8006a4:	ec06                	sd	ra,24(sp)
  8006a6:	f43e                	sd	a5,40(sp)
  8006a8:	f842                	sd	a6,48(sp)
  8006aa:	fc46                	sd	a7,56(sp)
  8006ac:	e41a                	sd	t1,8(sp)
  8006ae:	c71ff0ef          	jal	80031e <vprintfmt>
  8006b2:	60e2                	ld	ra,24(sp)
  8006b4:	6121                	addi	sp,sp,64
  8006b6:	8082                	ret

00000000008006b8 <main>:
  8006b8:	1101                	addi	sp,sp,-32
  8006ba:	00000517          	auipc	a0,0x0
  8006be:	3ee50513          	addi	a0,a0,1006 # 800aa8 <main+0x3f0>
  8006c2:	ec06                	sd	ra,24(sp)
  8006c4:	e822                	sd	s0,16(sp)
  8006c6:	addff0ef          	jal	8001a2 <cprintf>
  8006ca:	a65ff0ef          	jal	80012e <fork>
  8006ce:	c561                	beqz	a0,800796 <main+0xde>
  8006d0:	842a                	mv	s0,a0
  8006d2:	85aa                	mv	a1,a0
  8006d4:	00000517          	auipc	a0,0x0
  8006d8:	41450513          	addi	a0,a0,1044 # 800ae8 <main+0x430>
  8006dc:	ac7ff0ef          	jal	8001a2 <cprintf>
  8006e0:	08805c63          	blez	s0,800778 <main+0xc0>
  8006e4:	00000517          	auipc	a0,0x0
  8006e8:	45c50513          	addi	a0,a0,1116 # 800b40 <main+0x488>
  8006ec:	ab7ff0ef          	jal	8001a2 <cprintf>
  8006f0:	006c                	addi	a1,sp,12
  8006f2:	8522                	mv	a0,s0
  8006f4:	a43ff0ef          	jal	800136 <waitpid>
  8006f8:	e131                	bnez	a0,80073c <main+0x84>
  8006fa:	4732                	lw	a4,12(sp)
  8006fc:	00001797          	auipc	a5,0x1
  800700:	9047a783          	lw	a5,-1788(a5) # 801000 <magic>
  800704:	02f71c63          	bne	a4,a5,80073c <main+0x84>
  800708:	006c                	addi	a1,sp,12
  80070a:	8522                	mv	a0,s0
  80070c:	a2bff0ef          	jal	800136 <waitpid>
  800710:	c529                	beqz	a0,80075a <main+0xa2>
  800712:	a1fff0ef          	jal	800130 <wait>
  800716:	c131                	beqz	a0,80075a <main+0xa2>
  800718:	85a2                	mv	a1,s0
  80071a:	00000517          	auipc	a0,0x0
  80071e:	49e50513          	addi	a0,a0,1182 # 800bb8 <main+0x500>
  800722:	a81ff0ef          	jal	8001a2 <cprintf>
  800726:	00000517          	auipc	a0,0x0
  80072a:	4a250513          	addi	a0,a0,1186 # 800bc8 <main+0x510>
  80072e:	a75ff0ef          	jal	8001a2 <cprintf>
  800732:	60e2                	ld	ra,24(sp)
  800734:	6442                	ld	s0,16(sp)
  800736:	4501                	li	a0,0
  800738:	6105                	addi	sp,sp,32
  80073a:	8082                	ret
  80073c:	00000697          	auipc	a3,0x0
  800740:	42468693          	addi	a3,a3,1060 # 800b60 <main+0x4a8>
  800744:	00000617          	auipc	a2,0x0
  800748:	3d460613          	addi	a2,a2,980 # 800b18 <main+0x460>
  80074c:	45ed                	li	a1,27
  80074e:	00000517          	auipc	a0,0x0
  800752:	3e250513          	addi	a0,a0,994 # 800b30 <main+0x478>
  800756:	8cbff0ef          	jal	800020 <__panic>
  80075a:	00000697          	auipc	a3,0x0
  80075e:	43668693          	addi	a3,a3,1078 # 800b90 <main+0x4d8>
  800762:	00000617          	auipc	a2,0x0
  800766:	3b660613          	addi	a2,a2,950 # 800b18 <main+0x460>
  80076a:	45f1                	li	a1,28
  80076c:	00000517          	auipc	a0,0x0
  800770:	3c450513          	addi	a0,a0,964 # 800b30 <main+0x478>
  800774:	8adff0ef          	jal	800020 <__panic>
  800778:	00000697          	auipc	a3,0x0
  80077c:	39868693          	addi	a3,a3,920 # 800b10 <main+0x458>
  800780:	00000617          	auipc	a2,0x0
  800784:	39860613          	addi	a2,a2,920 # 800b18 <main+0x460>
  800788:	45e1                	li	a1,24
  80078a:	00000517          	auipc	a0,0x0
  80078e:	3a650513          	addi	a0,a0,934 # 800b30 <main+0x478>
  800792:	88fff0ef          	jal	800020 <__panic>
  800796:	00000517          	auipc	a0,0x0
  80079a:	33a50513          	addi	a0,a0,826 # 800ad0 <main+0x418>
  80079e:	a05ff0ef          	jal	8001a2 <cprintf>
  8007a2:	9b1ff0ef          	jal	800152 <yield>
  8007a6:	9adff0ef          	jal	800152 <yield>
  8007aa:	9a9ff0ef          	jal	800152 <yield>
  8007ae:	9a5ff0ef          	jal	800152 <yield>
  8007b2:	9a1ff0ef          	jal	800152 <yield>
  8007b6:	99dff0ef          	jal	800152 <yield>
  8007ba:	999ff0ef          	jal	800152 <yield>
  8007be:	00001517          	auipc	a0,0x1
  8007c2:	84252503          	lw	a0,-1982(a0) # 801000 <magic>
  8007c6:	953ff0ef          	jal	800118 <exit>
