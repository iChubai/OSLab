
obj/__user_forktest.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	71250513          	addi	a0,a0,1810 # 800740 <main+0xaa>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	13c000ef          	jal	800180 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	10e000ef          	jal	80015a <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	71050513          	addi	a0,a0,1808 # 800760 <main+0xca>
  800058:	128000ef          	jal	800180 <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0b6000ef          	jal	800114 <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00000517          	auipc	a0,0x0
  800074:	6f850513          	addi	a0,a0,1784 # 800768 <main+0xd2>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	0fa000ef          	jal	800180 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0cc000ef          	jal	80015a <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	6ce50513          	addi	a0,a0,1742 # 800760 <main+0xca>
  80009a:	0e6000ef          	jal	800180 <cprintf>
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

00000000008000f8 <sys_open>:
  8000f8:	862e                	mv	a2,a1
  8000fa:	85aa                	mv	a1,a0
  8000fc:	06400513          	li	a0,100
  800100:	b75d                	j	8000a6 <syscall>

0000000000800102 <sys_close>:
  800102:	85aa                	mv	a1,a0
  800104:	06500513          	li	a0,101
  800108:	bf79                	j	8000a6 <syscall>

000000000080010a <sys_dup>:
  80010a:	862e                	mv	a2,a1
  80010c:	85aa                	mv	a1,a0
  80010e:	08200513          	li	a0,130
  800112:	bf51                	j	8000a6 <syscall>

0000000000800114 <exit>:
  800114:	1141                	addi	sp,sp,-16
  800116:	e406                	sd	ra,8(sp)
  800118:	fc9ff0ef          	jal	8000e0 <sys_exit>
  80011c:	00000517          	auipc	a0,0x0
  800120:	66c50513          	addi	a0,a0,1644 # 800788 <main+0xf2>
  800124:	05c000ef          	jal	800180 <cprintf>
  800128:	a001                	j	800128 <exit+0x14>

000000000080012a <fork>:
  80012a:	bf75                	j	8000e6 <sys_fork>

000000000080012c <wait>:
  80012c:	4581                	li	a1,0
  80012e:	4501                	li	a0,0
  800130:	bf6d                	j	8000ea <sys_wait>

0000000000800132 <_start>:
  800132:	0ca000ef          	jal	8001fc <umain>
  800136:	a001                	j	800136 <_start+0x4>

0000000000800138 <open>:
  800138:	1582                	slli	a1,a1,0x20
  80013a:	9181                	srli	a1,a1,0x20
  80013c:	bf75                	j	8000f8 <sys_open>

000000000080013e <close>:
  80013e:	b7d1                	j	800102 <sys_close>

0000000000800140 <dup2>:
  800140:	b7e9                	j	80010a <sys_dup>

0000000000800142 <cputch>:
  800142:	1101                	addi	sp,sp,-32
  800144:	ec06                	sd	ra,24(sp)
  800146:	e42e                	sd	a1,8(sp)
  800148:	fabff0ef          	jal	8000f2 <sys_putc>
  80014c:	65a2                	ld	a1,8(sp)
  80014e:	60e2                	ld	ra,24(sp)
  800150:	419c                	lw	a5,0(a1)
  800152:	2785                	addiw	a5,a5,1
  800154:	c19c                	sw	a5,0(a1)
  800156:	6105                	addi	sp,sp,32
  800158:	8082                	ret

000000000080015a <vcprintf>:
  80015a:	1101                	addi	sp,sp,-32
  80015c:	872e                	mv	a4,a1
  80015e:	75dd                	lui	a1,0xffff7
  800160:	86aa                	mv	a3,a0
  800162:	0070                	addi	a2,sp,12
  800164:	00000517          	auipc	a0,0x0
  800168:	fde50513          	addi	a0,a0,-34 # 800142 <cputch>
  80016c:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ee9>
  800170:	ec06                	sd	ra,24(sp)
  800172:	c602                	sw	zero,12(sp)
  800174:	188000ef          	jal	8002fc <vprintfmt>
  800178:	60e2                	ld	ra,24(sp)
  80017a:	4532                	lw	a0,12(sp)
  80017c:	6105                	addi	sp,sp,32
  80017e:	8082                	ret

0000000000800180 <cprintf>:
  800180:	711d                	addi	sp,sp,-96
  800182:	02810313          	addi	t1,sp,40
  800186:	f42e                	sd	a1,40(sp)
  800188:	75dd                	lui	a1,0xffff7
  80018a:	f832                	sd	a2,48(sp)
  80018c:	fc36                	sd	a3,56(sp)
  80018e:	e0ba                	sd	a4,64(sp)
  800190:	86aa                	mv	a3,a0
  800192:	0050                	addi	a2,sp,4
  800194:	00000517          	auipc	a0,0x0
  800198:	fae50513          	addi	a0,a0,-82 # 800142 <cputch>
  80019c:	871a                	mv	a4,t1
  80019e:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ee9>
  8001a2:	ec06                	sd	ra,24(sp)
  8001a4:	e4be                	sd	a5,72(sp)
  8001a6:	e8c2                	sd	a6,80(sp)
  8001a8:	ecc6                	sd	a7,88(sp)
  8001aa:	c202                	sw	zero,4(sp)
  8001ac:	e41a                	sd	t1,8(sp)
  8001ae:	14e000ef          	jal	8002fc <vprintfmt>
  8001b2:	60e2                	ld	ra,24(sp)
  8001b4:	4512                	lw	a0,4(sp)
  8001b6:	6125                	addi	sp,sp,96
  8001b8:	8082                	ret

00000000008001ba <initfd>:
  8001ba:	87ae                	mv	a5,a1
  8001bc:	1101                	addi	sp,sp,-32
  8001be:	e822                	sd	s0,16(sp)
  8001c0:	85b2                	mv	a1,a2
  8001c2:	842a                	mv	s0,a0
  8001c4:	853e                	mv	a0,a5
  8001c6:	ec06                	sd	ra,24(sp)
  8001c8:	f71ff0ef          	jal	800138 <open>
  8001cc:	87aa                	mv	a5,a0
  8001ce:	00054463          	bltz	a0,8001d6 <initfd+0x1c>
  8001d2:	00851763          	bne	a0,s0,8001e0 <initfd+0x26>
  8001d6:	60e2                	ld	ra,24(sp)
  8001d8:	6442                	ld	s0,16(sp)
  8001da:	853e                	mv	a0,a5
  8001dc:	6105                	addi	sp,sp,32
  8001de:	8082                	ret
  8001e0:	e42a                	sd	a0,8(sp)
  8001e2:	8522                	mv	a0,s0
  8001e4:	f5bff0ef          	jal	80013e <close>
  8001e8:	6522                	ld	a0,8(sp)
  8001ea:	85a2                	mv	a1,s0
  8001ec:	f55ff0ef          	jal	800140 <dup2>
  8001f0:	842a                	mv	s0,a0
  8001f2:	6522                	ld	a0,8(sp)
  8001f4:	f4bff0ef          	jal	80013e <close>
  8001f8:	87a2                	mv	a5,s0
  8001fa:	bff1                	j	8001d6 <initfd+0x1c>

00000000008001fc <umain>:
  8001fc:	1101                	addi	sp,sp,-32
  8001fe:	e822                	sd	s0,16(sp)
  800200:	e426                	sd	s1,8(sp)
  800202:	842a                	mv	s0,a0
  800204:	84ae                	mv	s1,a1
  800206:	4601                	li	a2,0
  800208:	00000597          	auipc	a1,0x0
  80020c:	59858593          	addi	a1,a1,1432 # 8007a0 <main+0x10a>
  800210:	4501                	li	a0,0
  800212:	ec06                	sd	ra,24(sp)
  800214:	fa7ff0ef          	jal	8001ba <initfd>
  800218:	02054263          	bltz	a0,80023c <umain+0x40>
  80021c:	4605                	li	a2,1
  80021e:	8532                	mv	a0,a2
  800220:	00000597          	auipc	a1,0x0
  800224:	5c058593          	addi	a1,a1,1472 # 8007e0 <main+0x14a>
  800228:	f93ff0ef          	jal	8001ba <initfd>
  80022c:	02054563          	bltz	a0,800256 <umain+0x5a>
  800230:	85a6                	mv	a1,s1
  800232:	8522                	mv	a0,s0
  800234:	462000ef          	jal	800696 <main>
  800238:	eddff0ef          	jal	800114 <exit>
  80023c:	86aa                	mv	a3,a0
  80023e:	00000617          	auipc	a2,0x0
  800242:	56a60613          	addi	a2,a2,1386 # 8007a8 <main+0x112>
  800246:	45e9                	li	a1,26
  800248:	00000517          	auipc	a0,0x0
  80024c:	58050513          	addi	a0,a0,1408 # 8007c8 <main+0x132>
  800250:	e13ff0ef          	jal	800062 <__warn>
  800254:	b7e1                	j	80021c <umain+0x20>
  800256:	86aa                	mv	a3,a0
  800258:	00000617          	auipc	a2,0x0
  80025c:	59060613          	addi	a2,a2,1424 # 8007e8 <main+0x152>
  800260:	45f5                	li	a1,29
  800262:	00000517          	auipc	a0,0x0
  800266:	56650513          	addi	a0,a0,1382 # 8007c8 <main+0x132>
  80026a:	df9ff0ef          	jal	800062 <__warn>
  80026e:	b7c9                	j	800230 <umain+0x34>

0000000000800270 <strnlen>:
  800270:	4781                	li	a5,0
  800272:	e589                	bnez	a1,80027c <strnlen+0xc>
  800274:	a811                	j	800288 <strnlen+0x18>
  800276:	0785                	addi	a5,a5,1
  800278:	00f58863          	beq	a1,a5,800288 <strnlen+0x18>
  80027c:	00f50733          	add	a4,a0,a5
  800280:	00074703          	lbu	a4,0(a4)
  800284:	fb6d                	bnez	a4,800276 <strnlen+0x6>
  800286:	85be                	mv	a1,a5
  800288:	852e                	mv	a0,a1
  80028a:	8082                	ret

000000000080028c <printnum>:
  80028c:	7139                	addi	sp,sp,-64
  80028e:	02071893          	slli	a7,a4,0x20
  800292:	f822                	sd	s0,48(sp)
  800294:	f426                	sd	s1,40(sp)
  800296:	f04a                	sd	s2,32(sp)
  800298:	ec4e                	sd	s3,24(sp)
  80029a:	e456                	sd	s5,8(sp)
  80029c:	0208d893          	srli	a7,a7,0x20
  8002a0:	fc06                	sd	ra,56(sp)
  8002a2:	0316fab3          	remu	s5,a3,a7
  8002a6:	fff7841b          	addiw	s0,a5,-1
  8002aa:	84aa                	mv	s1,a0
  8002ac:	89ae                	mv	s3,a1
  8002ae:	8932                	mv	s2,a2
  8002b0:	0516f063          	bgeu	a3,a7,8002f0 <printnum+0x64>
  8002b4:	e852                	sd	s4,16(sp)
  8002b6:	4705                	li	a4,1
  8002b8:	8a42                	mv	s4,a6
  8002ba:	00f75863          	bge	a4,a5,8002ca <printnum+0x3e>
  8002be:	864e                	mv	a2,s3
  8002c0:	85ca                	mv	a1,s2
  8002c2:	8552                	mv	a0,s4
  8002c4:	347d                	addiw	s0,s0,-1
  8002c6:	9482                	jalr	s1
  8002c8:	f87d                	bnez	s0,8002be <printnum+0x32>
  8002ca:	6a42                	ld	s4,16(sp)
  8002cc:	00000797          	auipc	a5,0x0
  8002d0:	53c78793          	addi	a5,a5,1340 # 800808 <main+0x172>
  8002d4:	97d6                	add	a5,a5,s5
  8002d6:	7442                	ld	s0,48(sp)
  8002d8:	0007c503          	lbu	a0,0(a5)
  8002dc:	70e2                	ld	ra,56(sp)
  8002de:	6aa2                	ld	s5,8(sp)
  8002e0:	864e                	mv	a2,s3
  8002e2:	85ca                	mv	a1,s2
  8002e4:	69e2                	ld	s3,24(sp)
  8002e6:	7902                	ld	s2,32(sp)
  8002e8:	87a6                	mv	a5,s1
  8002ea:	74a2                	ld	s1,40(sp)
  8002ec:	6121                	addi	sp,sp,64
  8002ee:	8782                	jr	a5
  8002f0:	0316d6b3          	divu	a3,a3,a7
  8002f4:	87a2                	mv	a5,s0
  8002f6:	f97ff0ef          	jal	80028c <printnum>
  8002fa:	bfc9                	j	8002cc <printnum+0x40>

00000000008002fc <vprintfmt>:
  8002fc:	7119                	addi	sp,sp,-128
  8002fe:	f4a6                	sd	s1,104(sp)
  800300:	f0ca                	sd	s2,96(sp)
  800302:	ecce                	sd	s3,88(sp)
  800304:	e8d2                	sd	s4,80(sp)
  800306:	e4d6                	sd	s5,72(sp)
  800308:	e0da                	sd	s6,64(sp)
  80030a:	fc5e                	sd	s7,56(sp)
  80030c:	f466                	sd	s9,40(sp)
  80030e:	fc86                	sd	ra,120(sp)
  800310:	f8a2                	sd	s0,112(sp)
  800312:	f862                	sd	s8,48(sp)
  800314:	f06a                	sd	s10,32(sp)
  800316:	ec6e                	sd	s11,24(sp)
  800318:	84aa                	mv	s1,a0
  80031a:	8cb6                	mv	s9,a3
  80031c:	8aba                	mv	s5,a4
  80031e:	89ae                	mv	s3,a1
  800320:	8932                	mv	s2,a2
  800322:	02500a13          	li	s4,37
  800326:	05500b93          	li	s7,85
  80032a:	00000b17          	auipc	s6,0x0
  80032e:	76eb0b13          	addi	s6,s6,1902 # 800a98 <main+0x402>
  800332:	000cc503          	lbu	a0,0(s9)
  800336:	001c8413          	addi	s0,s9,1
  80033a:	01450b63          	beq	a0,s4,800350 <vprintfmt+0x54>
  80033e:	cd15                	beqz	a0,80037a <vprintfmt+0x7e>
  800340:	864e                	mv	a2,s3
  800342:	85ca                	mv	a1,s2
  800344:	9482                	jalr	s1
  800346:	00044503          	lbu	a0,0(s0)
  80034a:	0405                	addi	s0,s0,1
  80034c:	ff4519e3          	bne	a0,s4,80033e <vprintfmt+0x42>
  800350:	5d7d                	li	s10,-1
  800352:	8dea                	mv	s11,s10
  800354:	02000813          	li	a6,32
  800358:	4c01                	li	s8,0
  80035a:	4581                	li	a1,0
  80035c:	00044703          	lbu	a4,0(s0)
  800360:	00140c93          	addi	s9,s0,1
  800364:	fdd7061b          	addiw	a2,a4,-35
  800368:	0ff67613          	zext.b	a2,a2
  80036c:	02cbe663          	bltu	s7,a2,800398 <vprintfmt+0x9c>
  800370:	060a                	slli	a2,a2,0x2
  800372:	965a                	add	a2,a2,s6
  800374:	421c                	lw	a5,0(a2)
  800376:	97da                	add	a5,a5,s6
  800378:	8782                	jr	a5
  80037a:	70e6                	ld	ra,120(sp)
  80037c:	7446                	ld	s0,112(sp)
  80037e:	74a6                	ld	s1,104(sp)
  800380:	7906                	ld	s2,96(sp)
  800382:	69e6                	ld	s3,88(sp)
  800384:	6a46                	ld	s4,80(sp)
  800386:	6aa6                	ld	s5,72(sp)
  800388:	6b06                	ld	s6,64(sp)
  80038a:	7be2                	ld	s7,56(sp)
  80038c:	7c42                	ld	s8,48(sp)
  80038e:	7ca2                	ld	s9,40(sp)
  800390:	7d02                	ld	s10,32(sp)
  800392:	6de2                	ld	s11,24(sp)
  800394:	6109                	addi	sp,sp,128
  800396:	8082                	ret
  800398:	864e                	mv	a2,s3
  80039a:	85ca                	mv	a1,s2
  80039c:	02500513          	li	a0,37
  8003a0:	9482                	jalr	s1
  8003a2:	fff44783          	lbu	a5,-1(s0)
  8003a6:	02500713          	li	a4,37
  8003aa:	8ca2                	mv	s9,s0
  8003ac:	f8e783e3          	beq	a5,a4,800332 <vprintfmt+0x36>
  8003b0:	ffecc783          	lbu	a5,-2(s9)
  8003b4:	1cfd                	addi	s9,s9,-1
  8003b6:	fee79de3          	bne	a5,a4,8003b0 <vprintfmt+0xb4>
  8003ba:	bfa5                	j	800332 <vprintfmt+0x36>
  8003bc:	00144683          	lbu	a3,1(s0)
  8003c0:	4525                	li	a0,9
  8003c2:	fd070d1b          	addiw	s10,a4,-48
  8003c6:	fd06879b          	addiw	a5,a3,-48
  8003ca:	28f56063          	bltu	a0,a5,80064a <vprintfmt+0x34e>
  8003ce:	2681                	sext.w	a3,a3
  8003d0:	8466                	mv	s0,s9
  8003d2:	002d179b          	slliw	a5,s10,0x2
  8003d6:	00144703          	lbu	a4,1(s0)
  8003da:	01a787bb          	addw	a5,a5,s10
  8003de:	0017979b          	slliw	a5,a5,0x1
  8003e2:	9fb5                	addw	a5,a5,a3
  8003e4:	fd07061b          	addiw	a2,a4,-48
  8003e8:	0405                	addi	s0,s0,1
  8003ea:	fd078d1b          	addiw	s10,a5,-48
  8003ee:	0007069b          	sext.w	a3,a4
  8003f2:	fec570e3          	bgeu	a0,a2,8003d2 <vprintfmt+0xd6>
  8003f6:	f60dd3e3          	bgez	s11,80035c <vprintfmt+0x60>
  8003fa:	8dea                	mv	s11,s10
  8003fc:	5d7d                	li	s10,-1
  8003fe:	bfb9                	j	80035c <vprintfmt+0x60>
  800400:	883a                	mv	a6,a4
  800402:	8466                	mv	s0,s9
  800404:	bfa1                	j	80035c <vprintfmt+0x60>
  800406:	8466                	mv	s0,s9
  800408:	4c05                	li	s8,1
  80040a:	bf89                	j	80035c <vprintfmt+0x60>
  80040c:	4785                	li	a5,1
  80040e:	008a8613          	addi	a2,s5,8
  800412:	00b7c463          	blt	a5,a1,80041a <vprintfmt+0x11e>
  800416:	1c058363          	beqz	a1,8005dc <vprintfmt+0x2e0>
  80041a:	000ab683          	ld	a3,0(s5)
  80041e:	4741                	li	a4,16
  800420:	8ab2                	mv	s5,a2
  800422:	2801                	sext.w	a6,a6
  800424:	87ee                	mv	a5,s11
  800426:	864a                	mv	a2,s2
  800428:	85ce                	mv	a1,s3
  80042a:	8526                	mv	a0,s1
  80042c:	e61ff0ef          	jal	80028c <printnum>
  800430:	b709                	j	800332 <vprintfmt+0x36>
  800432:	000aa503          	lw	a0,0(s5)
  800436:	864e                	mv	a2,s3
  800438:	85ca                	mv	a1,s2
  80043a:	9482                	jalr	s1
  80043c:	0aa1                	addi	s5,s5,8
  80043e:	bdd5                	j	800332 <vprintfmt+0x36>
  800440:	4785                	li	a5,1
  800442:	008a8613          	addi	a2,s5,8
  800446:	00b7c463          	blt	a5,a1,80044e <vprintfmt+0x152>
  80044a:	18058463          	beqz	a1,8005d2 <vprintfmt+0x2d6>
  80044e:	000ab683          	ld	a3,0(s5)
  800452:	4729                	li	a4,10
  800454:	8ab2                	mv	s5,a2
  800456:	b7f1                	j	800422 <vprintfmt+0x126>
  800458:	864e                	mv	a2,s3
  80045a:	85ca                	mv	a1,s2
  80045c:	03000513          	li	a0,48
  800460:	e042                	sd	a6,0(sp)
  800462:	9482                	jalr	s1
  800464:	864e                	mv	a2,s3
  800466:	85ca                	mv	a1,s2
  800468:	07800513          	li	a0,120
  80046c:	9482                	jalr	s1
  80046e:	000ab683          	ld	a3,0(s5)
  800472:	6802                	ld	a6,0(sp)
  800474:	4741                	li	a4,16
  800476:	0aa1                	addi	s5,s5,8
  800478:	b76d                	j	800422 <vprintfmt+0x126>
  80047a:	864e                	mv	a2,s3
  80047c:	85ca                	mv	a1,s2
  80047e:	02500513          	li	a0,37
  800482:	9482                	jalr	s1
  800484:	b57d                	j	800332 <vprintfmt+0x36>
  800486:	000aad03          	lw	s10,0(s5)
  80048a:	8466                	mv	s0,s9
  80048c:	0aa1                	addi	s5,s5,8
  80048e:	b7a5                	j	8003f6 <vprintfmt+0xfa>
  800490:	4785                	li	a5,1
  800492:	008a8613          	addi	a2,s5,8
  800496:	00b7c463          	blt	a5,a1,80049e <vprintfmt+0x1a2>
  80049a:	12058763          	beqz	a1,8005c8 <vprintfmt+0x2cc>
  80049e:	000ab683          	ld	a3,0(s5)
  8004a2:	4721                	li	a4,8
  8004a4:	8ab2                	mv	s5,a2
  8004a6:	bfb5                	j	800422 <vprintfmt+0x126>
  8004a8:	87ee                	mv	a5,s11
  8004aa:	000dd363          	bgez	s11,8004b0 <vprintfmt+0x1b4>
  8004ae:	4781                	li	a5,0
  8004b0:	00078d9b          	sext.w	s11,a5
  8004b4:	8466                	mv	s0,s9
  8004b6:	b55d                	j	80035c <vprintfmt+0x60>
  8004b8:	0008041b          	sext.w	s0,a6
  8004bc:	fd340793          	addi	a5,s0,-45
  8004c0:	01b02733          	sgtz	a4,s11
  8004c4:	00f037b3          	snez	a5,a5
  8004c8:	8ff9                	and	a5,a5,a4
  8004ca:	000ab703          	ld	a4,0(s5)
  8004ce:	008a8693          	addi	a3,s5,8
  8004d2:	e436                	sd	a3,8(sp)
  8004d4:	12070563          	beqz	a4,8005fe <vprintfmt+0x302>
  8004d8:	12079d63          	bnez	a5,800612 <vprintfmt+0x316>
  8004dc:	00074783          	lbu	a5,0(a4)
  8004e0:	0007851b          	sext.w	a0,a5
  8004e4:	c78d                	beqz	a5,80050e <vprintfmt+0x212>
  8004e6:	00170a93          	addi	s5,a4,1
  8004ea:	547d                	li	s0,-1
  8004ec:	000d4563          	bltz	s10,8004f6 <vprintfmt+0x1fa>
  8004f0:	3d7d                	addiw	s10,s10,-1
  8004f2:	008d0e63          	beq	s10,s0,80050e <vprintfmt+0x212>
  8004f6:	020c1863          	bnez	s8,800526 <vprintfmt+0x22a>
  8004fa:	864e                	mv	a2,s3
  8004fc:	85ca                	mv	a1,s2
  8004fe:	9482                	jalr	s1
  800500:	000ac783          	lbu	a5,0(s5)
  800504:	0a85                	addi	s5,s5,1
  800506:	3dfd                	addiw	s11,s11,-1
  800508:	0007851b          	sext.w	a0,a5
  80050c:	f3e5                	bnez	a5,8004ec <vprintfmt+0x1f0>
  80050e:	01b05a63          	blez	s11,800522 <vprintfmt+0x226>
  800512:	864e                	mv	a2,s3
  800514:	85ca                	mv	a1,s2
  800516:	02000513          	li	a0,32
  80051a:	3dfd                	addiw	s11,s11,-1
  80051c:	9482                	jalr	s1
  80051e:	fe0d9ae3          	bnez	s11,800512 <vprintfmt+0x216>
  800522:	6aa2                	ld	s5,8(sp)
  800524:	b539                	j	800332 <vprintfmt+0x36>
  800526:	3781                	addiw	a5,a5,-32
  800528:	05e00713          	li	a4,94
  80052c:	fcf777e3          	bgeu	a4,a5,8004fa <vprintfmt+0x1fe>
  800530:	03f00513          	li	a0,63
  800534:	864e                	mv	a2,s3
  800536:	85ca                	mv	a1,s2
  800538:	9482                	jalr	s1
  80053a:	000ac783          	lbu	a5,0(s5)
  80053e:	0a85                	addi	s5,s5,1
  800540:	3dfd                	addiw	s11,s11,-1
  800542:	0007851b          	sext.w	a0,a5
  800546:	d7e1                	beqz	a5,80050e <vprintfmt+0x212>
  800548:	fa0d54e3          	bgez	s10,8004f0 <vprintfmt+0x1f4>
  80054c:	bfe9                	j	800526 <vprintfmt+0x22a>
  80054e:	000aa783          	lw	a5,0(s5)
  800552:	46e1                	li	a3,24
  800554:	0aa1                	addi	s5,s5,8
  800556:	41f7d71b          	sraiw	a4,a5,0x1f
  80055a:	8fb9                	xor	a5,a5,a4
  80055c:	40e7873b          	subw	a4,a5,a4
  800560:	02e6c663          	blt	a3,a4,80058c <vprintfmt+0x290>
  800564:	00000797          	auipc	a5,0x0
  800568:	68c78793          	addi	a5,a5,1676 # 800bf0 <error_string>
  80056c:	00371693          	slli	a3,a4,0x3
  800570:	97b6                	add	a5,a5,a3
  800572:	639c                	ld	a5,0(a5)
  800574:	cf81                	beqz	a5,80058c <vprintfmt+0x290>
  800576:	873e                	mv	a4,a5
  800578:	00000697          	auipc	a3,0x0
  80057c:	2c068693          	addi	a3,a3,704 # 800838 <main+0x1a2>
  800580:	864a                	mv	a2,s2
  800582:	85ce                	mv	a1,s3
  800584:	8526                	mv	a0,s1
  800586:	0f2000ef          	jal	800678 <printfmt>
  80058a:	b365                	j	800332 <vprintfmt+0x36>
  80058c:	00000697          	auipc	a3,0x0
  800590:	29c68693          	addi	a3,a3,668 # 800828 <main+0x192>
  800594:	864a                	mv	a2,s2
  800596:	85ce                	mv	a1,s3
  800598:	8526                	mv	a0,s1
  80059a:	0de000ef          	jal	800678 <printfmt>
  80059e:	bb51                	j	800332 <vprintfmt+0x36>
  8005a0:	4785                	li	a5,1
  8005a2:	008a8c13          	addi	s8,s5,8
  8005a6:	00b7c363          	blt	a5,a1,8005ac <vprintfmt+0x2b0>
  8005aa:	cd81                	beqz	a1,8005c2 <vprintfmt+0x2c6>
  8005ac:	000ab403          	ld	s0,0(s5)
  8005b0:	02044b63          	bltz	s0,8005e6 <vprintfmt+0x2ea>
  8005b4:	86a2                	mv	a3,s0
  8005b6:	8ae2                	mv	s5,s8
  8005b8:	4729                	li	a4,10
  8005ba:	b5a5                	j	800422 <vprintfmt+0x126>
  8005bc:	2585                	addiw	a1,a1,1
  8005be:	8466                	mv	s0,s9
  8005c0:	bb71                	j	80035c <vprintfmt+0x60>
  8005c2:	000aa403          	lw	s0,0(s5)
  8005c6:	b7ed                	j	8005b0 <vprintfmt+0x2b4>
  8005c8:	000ae683          	lwu	a3,0(s5)
  8005cc:	4721                	li	a4,8
  8005ce:	8ab2                	mv	s5,a2
  8005d0:	bd89                	j	800422 <vprintfmt+0x126>
  8005d2:	000ae683          	lwu	a3,0(s5)
  8005d6:	4729                	li	a4,10
  8005d8:	8ab2                	mv	s5,a2
  8005da:	b5a1                	j	800422 <vprintfmt+0x126>
  8005dc:	000ae683          	lwu	a3,0(s5)
  8005e0:	4741                	li	a4,16
  8005e2:	8ab2                	mv	s5,a2
  8005e4:	bd3d                	j	800422 <vprintfmt+0x126>
  8005e6:	864e                	mv	a2,s3
  8005e8:	85ca                	mv	a1,s2
  8005ea:	02d00513          	li	a0,45
  8005ee:	e042                	sd	a6,0(sp)
  8005f0:	9482                	jalr	s1
  8005f2:	6802                	ld	a6,0(sp)
  8005f4:	408006b3          	neg	a3,s0
  8005f8:	8ae2                	mv	s5,s8
  8005fa:	4729                	li	a4,10
  8005fc:	b51d                	j	800422 <vprintfmt+0x126>
  8005fe:	eba1                	bnez	a5,80064e <vprintfmt+0x352>
  800600:	02800793          	li	a5,40
  800604:	853e                	mv	a0,a5
  800606:	00000a97          	auipc	s5,0x0
  80060a:	21ba8a93          	addi	s5,s5,539 # 800821 <main+0x18b>
  80060e:	547d                	li	s0,-1
  800610:	bdf1                	j	8004ec <vprintfmt+0x1f0>
  800612:	853a                	mv	a0,a4
  800614:	85ea                	mv	a1,s10
  800616:	e03a                	sd	a4,0(sp)
  800618:	c59ff0ef          	jal	800270 <strnlen>
  80061c:	40ad8dbb          	subw	s11,s11,a0
  800620:	6702                	ld	a4,0(sp)
  800622:	01b05b63          	blez	s11,800638 <vprintfmt+0x33c>
  800626:	864e                	mv	a2,s3
  800628:	85ca                	mv	a1,s2
  80062a:	8522                	mv	a0,s0
  80062c:	e03a                	sd	a4,0(sp)
  80062e:	3dfd                	addiw	s11,s11,-1
  800630:	9482                	jalr	s1
  800632:	6702                	ld	a4,0(sp)
  800634:	fe0d99e3          	bnez	s11,800626 <vprintfmt+0x32a>
  800638:	00074783          	lbu	a5,0(a4)
  80063c:	0007851b          	sext.w	a0,a5
  800640:	ee0781e3          	beqz	a5,800522 <vprintfmt+0x226>
  800644:	00170a93          	addi	s5,a4,1
  800648:	b54d                	j	8004ea <vprintfmt+0x1ee>
  80064a:	8466                	mv	s0,s9
  80064c:	b36d                	j	8003f6 <vprintfmt+0xfa>
  80064e:	85ea                	mv	a1,s10
  800650:	00000517          	auipc	a0,0x0
  800654:	1d050513          	addi	a0,a0,464 # 800820 <main+0x18a>
  800658:	c19ff0ef          	jal	800270 <strnlen>
  80065c:	40ad8dbb          	subw	s11,s11,a0
  800660:	02800793          	li	a5,40
  800664:	00000717          	auipc	a4,0x0
  800668:	1bc70713          	addi	a4,a4,444 # 800820 <main+0x18a>
  80066c:	853e                	mv	a0,a5
  80066e:	fbb04ce3          	bgtz	s11,800626 <vprintfmt+0x32a>
  800672:	00170a93          	addi	s5,a4,1
  800676:	bd95                	j	8004ea <vprintfmt+0x1ee>

0000000000800678 <printfmt>:
  800678:	7139                	addi	sp,sp,-64
  80067a:	02010313          	addi	t1,sp,32
  80067e:	f03a                	sd	a4,32(sp)
  800680:	871a                	mv	a4,t1
  800682:	ec06                	sd	ra,24(sp)
  800684:	f43e                	sd	a5,40(sp)
  800686:	f842                	sd	a6,48(sp)
  800688:	fc46                	sd	a7,56(sp)
  80068a:	e41a                	sd	t1,8(sp)
  80068c:	c71ff0ef          	jal	8002fc <vprintfmt>
  800690:	60e2                	ld	ra,24(sp)
  800692:	6121                	addi	sp,sp,64
  800694:	8082                	ret

0000000000800696 <main>:
  800696:	1101                	addi	sp,sp,-32
  800698:	e822                	sd	s0,16(sp)
  80069a:	e426                	sd	s1,8(sp)
  80069c:	ec06                	sd	ra,24(sp)
  80069e:	4401                	li	s0,0
  8006a0:	02000493          	li	s1,32
  8006a4:	a87ff0ef          	jal	80012a <fork>
  8006a8:	c915                	beqz	a0,8006dc <main+0x46>
  8006aa:	04a05e63          	blez	a0,800706 <main+0x70>
  8006ae:	2405                	addiw	s0,s0,1
  8006b0:	fe941ae3          	bne	s0,s1,8006a4 <main+0xe>
  8006b4:	a79ff0ef          	jal	80012c <wait>
  8006b8:	ed05                	bnez	a0,8006f0 <main+0x5a>
  8006ba:	347d                	addiw	s0,s0,-1
  8006bc:	fc65                	bnez	s0,8006b4 <main+0x1e>
  8006be:	a6fff0ef          	jal	80012c <wait>
  8006c2:	c12d                	beqz	a0,800724 <main+0x8e>
  8006c4:	00000517          	auipc	a0,0x0
  8006c8:	3c450513          	addi	a0,a0,964 # 800a88 <main+0x3f2>
  8006cc:	ab5ff0ef          	jal	800180 <cprintf>
  8006d0:	60e2                	ld	ra,24(sp)
  8006d2:	6442                	ld	s0,16(sp)
  8006d4:	64a2                	ld	s1,8(sp)
  8006d6:	4501                	li	a0,0
  8006d8:	6105                	addi	sp,sp,32
  8006da:	8082                	ret
  8006dc:	85a2                	mv	a1,s0
  8006de:	00000517          	auipc	a0,0x0
  8006e2:	33a50513          	addi	a0,a0,826 # 800a18 <main+0x382>
  8006e6:	a9bff0ef          	jal	800180 <cprintf>
  8006ea:	4501                	li	a0,0
  8006ec:	a29ff0ef          	jal	800114 <exit>
  8006f0:	00000617          	auipc	a2,0x0
  8006f4:	36860613          	addi	a2,a2,872 # 800a58 <main+0x3c2>
  8006f8:	45dd                	li	a1,23
  8006fa:	00000517          	auipc	a0,0x0
  8006fe:	34e50513          	addi	a0,a0,846 # 800a48 <main+0x3b2>
  800702:	91fff0ef          	jal	800020 <__panic>
  800706:	00000697          	auipc	a3,0x0
  80070a:	32268693          	addi	a3,a3,802 # 800a28 <main+0x392>
  80070e:	00000617          	auipc	a2,0x0
  800712:	32260613          	addi	a2,a2,802 # 800a30 <main+0x39a>
  800716:	45b9                	li	a1,14
  800718:	00000517          	auipc	a0,0x0
  80071c:	33050513          	addi	a0,a0,816 # 800a48 <main+0x3b2>
  800720:	901ff0ef          	jal	800020 <__panic>
  800724:	00000617          	auipc	a2,0x0
  800728:	34c60613          	addi	a2,a2,844 # 800a70 <main+0x3da>
  80072c:	45f1                	li	a1,28
  80072e:	00000517          	auipc	a0,0x0
  800732:	31a50513          	addi	a0,a0,794 # 800a48 <main+0x3b2>
  800736:	8ebff0ef          	jal	800020 <__panic>
