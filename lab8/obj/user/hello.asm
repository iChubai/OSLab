
obj/__user_hello.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__warn>:
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	02810313          	addi	t1,sp,40
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	67a50513          	addi	a0,a0,1658 # 8006a8 <main+0x62>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	0ec000ef          	jal	800130 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0be000ef          	jal	80010a <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	65050513          	addi	a0,a0,1616 # 8006a0 <main+0x5a>
  800058:	0d8000ef          	jal	800130 <cprintf>
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

00000000008000a4 <sys_getpid>:
  8000a4:	4549                	li	a0,18
  8000a6:	bf7d                	j	800064 <syscall>

00000000008000a8 <sys_putc>:
  8000a8:	85aa                	mv	a1,a0
  8000aa:	4579                	li	a0,30
  8000ac:	bf65                	j	800064 <syscall>

00000000008000ae <sys_open>:
  8000ae:	862e                	mv	a2,a1
  8000b0:	85aa                	mv	a1,a0
  8000b2:	06400513          	li	a0,100
  8000b6:	b77d                	j	800064 <syscall>

00000000008000b8 <sys_close>:
  8000b8:	85aa                	mv	a1,a0
  8000ba:	06500513          	li	a0,101
  8000be:	b75d                	j	800064 <syscall>

00000000008000c0 <sys_dup>:
  8000c0:	862e                	mv	a2,a1
  8000c2:	85aa                	mv	a1,a0
  8000c4:	08200513          	li	a0,130
  8000c8:	bf71                	j	800064 <syscall>

00000000008000ca <exit>:
  8000ca:	1141                	addi	sp,sp,-16
  8000cc:	e406                	sd	ra,8(sp)
  8000ce:	fd1ff0ef          	jal	80009e <sys_exit>
  8000d2:	00000517          	auipc	a0,0x0
  8000d6:	5f650513          	addi	a0,a0,1526 # 8006c8 <main+0x82>
  8000da:	056000ef          	jal	800130 <cprintf>
  8000de:	a001                	j	8000de <exit+0x14>

00000000008000e0 <getpid>:
  8000e0:	b7d1                	j	8000a4 <sys_getpid>

00000000008000e2 <_start>:
  8000e2:	0ca000ef          	jal	8001ac <umain>
  8000e6:	a001                	j	8000e6 <_start+0x4>

00000000008000e8 <open>:
  8000e8:	1582                	slli	a1,a1,0x20
  8000ea:	9181                	srli	a1,a1,0x20
  8000ec:	b7c9                	j	8000ae <sys_open>

00000000008000ee <close>:
  8000ee:	b7e9                	j	8000b8 <sys_close>

00000000008000f0 <dup2>:
  8000f0:	bfc1                	j	8000c0 <sys_dup>

00000000008000f2 <cputch>:
  8000f2:	1101                	addi	sp,sp,-32
  8000f4:	ec06                	sd	ra,24(sp)
  8000f6:	e42e                	sd	a1,8(sp)
  8000f8:	fb1ff0ef          	jal	8000a8 <sys_putc>
  8000fc:	65a2                	ld	a1,8(sp)
  8000fe:	60e2                	ld	ra,24(sp)
  800100:	419c                	lw	a5,0(a1)
  800102:	2785                	addiw	a5,a5,1
  800104:	c19c                	sw	a5,0(a1)
  800106:	6105                	addi	sp,sp,32
  800108:	8082                	ret

000000000080010a <vcprintf>:
  80010a:	1101                	addi	sp,sp,-32
  80010c:	872e                	mv	a4,a1
  80010e:	75dd                	lui	a1,0xffff7
  800110:	86aa                	mv	a3,a0
  800112:	0070                	addi	a2,sp,12
  800114:	00000517          	auipc	a0,0x0
  800118:	fde50513          	addi	a0,a0,-34 # 8000f2 <cputch>
  80011c:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ff1>
  800120:	ec06                	sd	ra,24(sp)
  800122:	c602                	sw	zero,12(sp)
  800124:	188000ef          	jal	8002ac <vprintfmt>
  800128:	60e2                	ld	ra,24(sp)
  80012a:	4532                	lw	a0,12(sp)
  80012c:	6105                	addi	sp,sp,32
  80012e:	8082                	ret

0000000000800130 <cprintf>:
  800130:	711d                	addi	sp,sp,-96
  800132:	02810313          	addi	t1,sp,40
  800136:	f42e                	sd	a1,40(sp)
  800138:	75dd                	lui	a1,0xffff7
  80013a:	f832                	sd	a2,48(sp)
  80013c:	fc36                	sd	a3,56(sp)
  80013e:	e0ba                	sd	a4,64(sp)
  800140:	86aa                	mv	a3,a0
  800142:	0050                	addi	a2,sp,4
  800144:	00000517          	auipc	a0,0x0
  800148:	fae50513          	addi	a0,a0,-82 # 8000f2 <cputch>
  80014c:	871a                	mv	a4,t1
  80014e:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5ff1>
  800152:	ec06                	sd	ra,24(sp)
  800154:	e4be                	sd	a5,72(sp)
  800156:	e8c2                	sd	a6,80(sp)
  800158:	ecc6                	sd	a7,88(sp)
  80015a:	c202                	sw	zero,4(sp)
  80015c:	e41a                	sd	t1,8(sp)
  80015e:	14e000ef          	jal	8002ac <vprintfmt>
  800162:	60e2                	ld	ra,24(sp)
  800164:	4512                	lw	a0,4(sp)
  800166:	6125                	addi	sp,sp,96
  800168:	8082                	ret

000000000080016a <initfd>:
  80016a:	87ae                	mv	a5,a1
  80016c:	1101                	addi	sp,sp,-32
  80016e:	e822                	sd	s0,16(sp)
  800170:	85b2                	mv	a1,a2
  800172:	842a                	mv	s0,a0
  800174:	853e                	mv	a0,a5
  800176:	ec06                	sd	ra,24(sp)
  800178:	f71ff0ef          	jal	8000e8 <open>
  80017c:	87aa                	mv	a5,a0
  80017e:	00054463          	bltz	a0,800186 <initfd+0x1c>
  800182:	00851763          	bne	a0,s0,800190 <initfd+0x26>
  800186:	60e2                	ld	ra,24(sp)
  800188:	6442                	ld	s0,16(sp)
  80018a:	853e                	mv	a0,a5
  80018c:	6105                	addi	sp,sp,32
  80018e:	8082                	ret
  800190:	e42a                	sd	a0,8(sp)
  800192:	8522                	mv	a0,s0
  800194:	f5bff0ef          	jal	8000ee <close>
  800198:	6522                	ld	a0,8(sp)
  80019a:	85a2                	mv	a1,s0
  80019c:	f55ff0ef          	jal	8000f0 <dup2>
  8001a0:	842a                	mv	s0,a0
  8001a2:	6522                	ld	a0,8(sp)
  8001a4:	f4bff0ef          	jal	8000ee <close>
  8001a8:	87a2                	mv	a5,s0
  8001aa:	bff1                	j	800186 <initfd+0x1c>

00000000008001ac <umain>:
  8001ac:	1101                	addi	sp,sp,-32
  8001ae:	e822                	sd	s0,16(sp)
  8001b0:	e426                	sd	s1,8(sp)
  8001b2:	842a                	mv	s0,a0
  8001b4:	84ae                	mv	s1,a1
  8001b6:	4601                	li	a2,0
  8001b8:	00000597          	auipc	a1,0x0
  8001bc:	52858593          	addi	a1,a1,1320 # 8006e0 <main+0x9a>
  8001c0:	4501                	li	a0,0
  8001c2:	ec06                	sd	ra,24(sp)
  8001c4:	fa7ff0ef          	jal	80016a <initfd>
  8001c8:	02054263          	bltz	a0,8001ec <umain+0x40>
  8001cc:	4605                	li	a2,1
  8001ce:	8532                	mv	a0,a2
  8001d0:	00000597          	auipc	a1,0x0
  8001d4:	55058593          	addi	a1,a1,1360 # 800720 <main+0xda>
  8001d8:	f93ff0ef          	jal	80016a <initfd>
  8001dc:	02054563          	bltz	a0,800206 <umain+0x5a>
  8001e0:	85a6                	mv	a1,s1
  8001e2:	8522                	mv	a0,s0
  8001e4:	462000ef          	jal	800646 <main>
  8001e8:	ee3ff0ef          	jal	8000ca <exit>
  8001ec:	86aa                	mv	a3,a0
  8001ee:	00000617          	auipc	a2,0x0
  8001f2:	4fa60613          	addi	a2,a2,1274 # 8006e8 <main+0xa2>
  8001f6:	45e9                	li	a1,26
  8001f8:	00000517          	auipc	a0,0x0
  8001fc:	51050513          	addi	a0,a0,1296 # 800708 <main+0xc2>
  800200:	e21ff0ef          	jal	800020 <__warn>
  800204:	b7e1                	j	8001cc <umain+0x20>
  800206:	86aa                	mv	a3,a0
  800208:	00000617          	auipc	a2,0x0
  80020c:	52060613          	addi	a2,a2,1312 # 800728 <main+0xe2>
  800210:	45f5                	li	a1,29
  800212:	00000517          	auipc	a0,0x0
  800216:	4f650513          	addi	a0,a0,1270 # 800708 <main+0xc2>
  80021a:	e07ff0ef          	jal	800020 <__warn>
  80021e:	b7c9                	j	8001e0 <umain+0x34>

0000000000800220 <strnlen>:
  800220:	4781                	li	a5,0
  800222:	e589                	bnez	a1,80022c <strnlen+0xc>
  800224:	a811                	j	800238 <strnlen+0x18>
  800226:	0785                	addi	a5,a5,1
  800228:	00f58863          	beq	a1,a5,800238 <strnlen+0x18>
  80022c:	00f50733          	add	a4,a0,a5
  800230:	00074703          	lbu	a4,0(a4)
  800234:	fb6d                	bnez	a4,800226 <strnlen+0x6>
  800236:	85be                	mv	a1,a5
  800238:	852e                	mv	a0,a1
  80023a:	8082                	ret

000000000080023c <printnum>:
  80023c:	7139                	addi	sp,sp,-64
  80023e:	02071893          	slli	a7,a4,0x20
  800242:	f822                	sd	s0,48(sp)
  800244:	f426                	sd	s1,40(sp)
  800246:	f04a                	sd	s2,32(sp)
  800248:	ec4e                	sd	s3,24(sp)
  80024a:	e456                	sd	s5,8(sp)
  80024c:	0208d893          	srli	a7,a7,0x20
  800250:	fc06                	sd	ra,56(sp)
  800252:	0316fab3          	remu	s5,a3,a7
  800256:	fff7841b          	addiw	s0,a5,-1
  80025a:	84aa                	mv	s1,a0
  80025c:	89ae                	mv	s3,a1
  80025e:	8932                	mv	s2,a2
  800260:	0516f063          	bgeu	a3,a7,8002a0 <printnum+0x64>
  800264:	e852                	sd	s4,16(sp)
  800266:	4705                	li	a4,1
  800268:	8a42                	mv	s4,a6
  80026a:	00f75863          	bge	a4,a5,80027a <printnum+0x3e>
  80026e:	864e                	mv	a2,s3
  800270:	85ca                	mv	a1,s2
  800272:	8552                	mv	a0,s4
  800274:	347d                	addiw	s0,s0,-1
  800276:	9482                	jalr	s1
  800278:	f87d                	bnez	s0,80026e <printnum+0x32>
  80027a:	6a42                	ld	s4,16(sp)
  80027c:	00000797          	auipc	a5,0x0
  800280:	4cc78793          	addi	a5,a5,1228 # 800748 <main+0x102>
  800284:	97d6                	add	a5,a5,s5
  800286:	7442                	ld	s0,48(sp)
  800288:	0007c503          	lbu	a0,0(a5)
  80028c:	70e2                	ld	ra,56(sp)
  80028e:	6aa2                	ld	s5,8(sp)
  800290:	864e                	mv	a2,s3
  800292:	85ca                	mv	a1,s2
  800294:	69e2                	ld	s3,24(sp)
  800296:	7902                	ld	s2,32(sp)
  800298:	87a6                	mv	a5,s1
  80029a:	74a2                	ld	s1,40(sp)
  80029c:	6121                	addi	sp,sp,64
  80029e:	8782                	jr	a5
  8002a0:	0316d6b3          	divu	a3,a3,a7
  8002a4:	87a2                	mv	a5,s0
  8002a6:	f97ff0ef          	jal	80023c <printnum>
  8002aa:	bfc9                	j	80027c <printnum+0x40>

00000000008002ac <vprintfmt>:
  8002ac:	7119                	addi	sp,sp,-128
  8002ae:	f4a6                	sd	s1,104(sp)
  8002b0:	f0ca                	sd	s2,96(sp)
  8002b2:	ecce                	sd	s3,88(sp)
  8002b4:	e8d2                	sd	s4,80(sp)
  8002b6:	e4d6                	sd	s5,72(sp)
  8002b8:	e0da                	sd	s6,64(sp)
  8002ba:	fc5e                	sd	s7,56(sp)
  8002bc:	f466                	sd	s9,40(sp)
  8002be:	fc86                	sd	ra,120(sp)
  8002c0:	f8a2                	sd	s0,112(sp)
  8002c2:	f862                	sd	s8,48(sp)
  8002c4:	f06a                	sd	s10,32(sp)
  8002c6:	ec6e                	sd	s11,24(sp)
  8002c8:	84aa                	mv	s1,a0
  8002ca:	8cb6                	mv	s9,a3
  8002cc:	8aba                	mv	s5,a4
  8002ce:	89ae                	mv	s3,a1
  8002d0:	8932                	mv	s2,a2
  8002d2:	02500a13          	li	s4,37
  8002d6:	05500b93          	li	s7,85
  8002da:	00000b17          	auipc	s6,0x0
  8002de:	6b6b0b13          	addi	s6,s6,1718 # 800990 <main+0x34a>
  8002e2:	000cc503          	lbu	a0,0(s9)
  8002e6:	001c8413          	addi	s0,s9,1
  8002ea:	01450b63          	beq	a0,s4,800300 <vprintfmt+0x54>
  8002ee:	cd15                	beqz	a0,80032a <vprintfmt+0x7e>
  8002f0:	864e                	mv	a2,s3
  8002f2:	85ca                	mv	a1,s2
  8002f4:	9482                	jalr	s1
  8002f6:	00044503          	lbu	a0,0(s0)
  8002fa:	0405                	addi	s0,s0,1
  8002fc:	ff4519e3          	bne	a0,s4,8002ee <vprintfmt+0x42>
  800300:	5d7d                	li	s10,-1
  800302:	8dea                	mv	s11,s10
  800304:	02000813          	li	a6,32
  800308:	4c01                	li	s8,0
  80030a:	4581                	li	a1,0
  80030c:	00044703          	lbu	a4,0(s0)
  800310:	00140c93          	addi	s9,s0,1
  800314:	fdd7061b          	addiw	a2,a4,-35
  800318:	0ff67613          	zext.b	a2,a2
  80031c:	02cbe663          	bltu	s7,a2,800348 <vprintfmt+0x9c>
  800320:	060a                	slli	a2,a2,0x2
  800322:	965a                	add	a2,a2,s6
  800324:	421c                	lw	a5,0(a2)
  800326:	97da                	add	a5,a5,s6
  800328:	8782                	jr	a5
  80032a:	70e6                	ld	ra,120(sp)
  80032c:	7446                	ld	s0,112(sp)
  80032e:	74a6                	ld	s1,104(sp)
  800330:	7906                	ld	s2,96(sp)
  800332:	69e6                	ld	s3,88(sp)
  800334:	6a46                	ld	s4,80(sp)
  800336:	6aa6                	ld	s5,72(sp)
  800338:	6b06                	ld	s6,64(sp)
  80033a:	7be2                	ld	s7,56(sp)
  80033c:	7c42                	ld	s8,48(sp)
  80033e:	7ca2                	ld	s9,40(sp)
  800340:	7d02                	ld	s10,32(sp)
  800342:	6de2                	ld	s11,24(sp)
  800344:	6109                	addi	sp,sp,128
  800346:	8082                	ret
  800348:	864e                	mv	a2,s3
  80034a:	85ca                	mv	a1,s2
  80034c:	02500513          	li	a0,37
  800350:	9482                	jalr	s1
  800352:	fff44783          	lbu	a5,-1(s0)
  800356:	02500713          	li	a4,37
  80035a:	8ca2                	mv	s9,s0
  80035c:	f8e783e3          	beq	a5,a4,8002e2 <vprintfmt+0x36>
  800360:	ffecc783          	lbu	a5,-2(s9)
  800364:	1cfd                	addi	s9,s9,-1
  800366:	fee79de3          	bne	a5,a4,800360 <vprintfmt+0xb4>
  80036a:	bfa5                	j	8002e2 <vprintfmt+0x36>
  80036c:	00144683          	lbu	a3,1(s0)
  800370:	4525                	li	a0,9
  800372:	fd070d1b          	addiw	s10,a4,-48
  800376:	fd06879b          	addiw	a5,a3,-48
  80037a:	28f56063          	bltu	a0,a5,8005fa <vprintfmt+0x34e>
  80037e:	2681                	sext.w	a3,a3
  800380:	8466                	mv	s0,s9
  800382:	002d179b          	slliw	a5,s10,0x2
  800386:	00144703          	lbu	a4,1(s0)
  80038a:	01a787bb          	addw	a5,a5,s10
  80038e:	0017979b          	slliw	a5,a5,0x1
  800392:	9fb5                	addw	a5,a5,a3
  800394:	fd07061b          	addiw	a2,a4,-48
  800398:	0405                	addi	s0,s0,1
  80039a:	fd078d1b          	addiw	s10,a5,-48
  80039e:	0007069b          	sext.w	a3,a4
  8003a2:	fec570e3          	bgeu	a0,a2,800382 <vprintfmt+0xd6>
  8003a6:	f60dd3e3          	bgez	s11,80030c <vprintfmt+0x60>
  8003aa:	8dea                	mv	s11,s10
  8003ac:	5d7d                	li	s10,-1
  8003ae:	bfb9                	j	80030c <vprintfmt+0x60>
  8003b0:	883a                	mv	a6,a4
  8003b2:	8466                	mv	s0,s9
  8003b4:	bfa1                	j	80030c <vprintfmt+0x60>
  8003b6:	8466                	mv	s0,s9
  8003b8:	4c05                	li	s8,1
  8003ba:	bf89                	j	80030c <vprintfmt+0x60>
  8003bc:	4785                	li	a5,1
  8003be:	008a8613          	addi	a2,s5,8
  8003c2:	00b7c463          	blt	a5,a1,8003ca <vprintfmt+0x11e>
  8003c6:	1c058363          	beqz	a1,80058c <vprintfmt+0x2e0>
  8003ca:	000ab683          	ld	a3,0(s5)
  8003ce:	4741                	li	a4,16
  8003d0:	8ab2                	mv	s5,a2
  8003d2:	2801                	sext.w	a6,a6
  8003d4:	87ee                	mv	a5,s11
  8003d6:	864a                	mv	a2,s2
  8003d8:	85ce                	mv	a1,s3
  8003da:	8526                	mv	a0,s1
  8003dc:	e61ff0ef          	jal	80023c <printnum>
  8003e0:	b709                	j	8002e2 <vprintfmt+0x36>
  8003e2:	000aa503          	lw	a0,0(s5)
  8003e6:	864e                	mv	a2,s3
  8003e8:	85ca                	mv	a1,s2
  8003ea:	9482                	jalr	s1
  8003ec:	0aa1                	addi	s5,s5,8
  8003ee:	bdd5                	j	8002e2 <vprintfmt+0x36>
  8003f0:	4785                	li	a5,1
  8003f2:	008a8613          	addi	a2,s5,8
  8003f6:	00b7c463          	blt	a5,a1,8003fe <vprintfmt+0x152>
  8003fa:	18058463          	beqz	a1,800582 <vprintfmt+0x2d6>
  8003fe:	000ab683          	ld	a3,0(s5)
  800402:	4729                	li	a4,10
  800404:	8ab2                	mv	s5,a2
  800406:	b7f1                	j	8003d2 <vprintfmt+0x126>
  800408:	864e                	mv	a2,s3
  80040a:	85ca                	mv	a1,s2
  80040c:	03000513          	li	a0,48
  800410:	e042                	sd	a6,0(sp)
  800412:	9482                	jalr	s1
  800414:	864e                	mv	a2,s3
  800416:	85ca                	mv	a1,s2
  800418:	07800513          	li	a0,120
  80041c:	9482                	jalr	s1
  80041e:	000ab683          	ld	a3,0(s5)
  800422:	6802                	ld	a6,0(sp)
  800424:	4741                	li	a4,16
  800426:	0aa1                	addi	s5,s5,8
  800428:	b76d                	j	8003d2 <vprintfmt+0x126>
  80042a:	864e                	mv	a2,s3
  80042c:	85ca                	mv	a1,s2
  80042e:	02500513          	li	a0,37
  800432:	9482                	jalr	s1
  800434:	b57d                	j	8002e2 <vprintfmt+0x36>
  800436:	000aad03          	lw	s10,0(s5)
  80043a:	8466                	mv	s0,s9
  80043c:	0aa1                	addi	s5,s5,8
  80043e:	b7a5                	j	8003a6 <vprintfmt+0xfa>
  800440:	4785                	li	a5,1
  800442:	008a8613          	addi	a2,s5,8
  800446:	00b7c463          	blt	a5,a1,80044e <vprintfmt+0x1a2>
  80044a:	12058763          	beqz	a1,800578 <vprintfmt+0x2cc>
  80044e:	000ab683          	ld	a3,0(s5)
  800452:	4721                	li	a4,8
  800454:	8ab2                	mv	s5,a2
  800456:	bfb5                	j	8003d2 <vprintfmt+0x126>
  800458:	87ee                	mv	a5,s11
  80045a:	000dd363          	bgez	s11,800460 <vprintfmt+0x1b4>
  80045e:	4781                	li	a5,0
  800460:	00078d9b          	sext.w	s11,a5
  800464:	8466                	mv	s0,s9
  800466:	b55d                	j	80030c <vprintfmt+0x60>
  800468:	0008041b          	sext.w	s0,a6
  80046c:	fd340793          	addi	a5,s0,-45
  800470:	01b02733          	sgtz	a4,s11
  800474:	00f037b3          	snez	a5,a5
  800478:	8ff9                	and	a5,a5,a4
  80047a:	000ab703          	ld	a4,0(s5)
  80047e:	008a8693          	addi	a3,s5,8
  800482:	e436                	sd	a3,8(sp)
  800484:	12070563          	beqz	a4,8005ae <vprintfmt+0x302>
  800488:	12079d63          	bnez	a5,8005c2 <vprintfmt+0x316>
  80048c:	00074783          	lbu	a5,0(a4)
  800490:	0007851b          	sext.w	a0,a5
  800494:	c78d                	beqz	a5,8004be <vprintfmt+0x212>
  800496:	00170a93          	addi	s5,a4,1
  80049a:	547d                	li	s0,-1
  80049c:	000d4563          	bltz	s10,8004a6 <vprintfmt+0x1fa>
  8004a0:	3d7d                	addiw	s10,s10,-1
  8004a2:	008d0e63          	beq	s10,s0,8004be <vprintfmt+0x212>
  8004a6:	020c1863          	bnez	s8,8004d6 <vprintfmt+0x22a>
  8004aa:	864e                	mv	a2,s3
  8004ac:	85ca                	mv	a1,s2
  8004ae:	9482                	jalr	s1
  8004b0:	000ac783          	lbu	a5,0(s5)
  8004b4:	0a85                	addi	s5,s5,1
  8004b6:	3dfd                	addiw	s11,s11,-1
  8004b8:	0007851b          	sext.w	a0,a5
  8004bc:	f3e5                	bnez	a5,80049c <vprintfmt+0x1f0>
  8004be:	01b05a63          	blez	s11,8004d2 <vprintfmt+0x226>
  8004c2:	864e                	mv	a2,s3
  8004c4:	85ca                	mv	a1,s2
  8004c6:	02000513          	li	a0,32
  8004ca:	3dfd                	addiw	s11,s11,-1
  8004cc:	9482                	jalr	s1
  8004ce:	fe0d9ae3          	bnez	s11,8004c2 <vprintfmt+0x216>
  8004d2:	6aa2                	ld	s5,8(sp)
  8004d4:	b539                	j	8002e2 <vprintfmt+0x36>
  8004d6:	3781                	addiw	a5,a5,-32
  8004d8:	05e00713          	li	a4,94
  8004dc:	fcf777e3          	bgeu	a4,a5,8004aa <vprintfmt+0x1fe>
  8004e0:	03f00513          	li	a0,63
  8004e4:	864e                	mv	a2,s3
  8004e6:	85ca                	mv	a1,s2
  8004e8:	9482                	jalr	s1
  8004ea:	000ac783          	lbu	a5,0(s5)
  8004ee:	0a85                	addi	s5,s5,1
  8004f0:	3dfd                	addiw	s11,s11,-1
  8004f2:	0007851b          	sext.w	a0,a5
  8004f6:	d7e1                	beqz	a5,8004be <vprintfmt+0x212>
  8004f8:	fa0d54e3          	bgez	s10,8004a0 <vprintfmt+0x1f4>
  8004fc:	bfe9                	j	8004d6 <vprintfmt+0x22a>
  8004fe:	000aa783          	lw	a5,0(s5)
  800502:	46e1                	li	a3,24
  800504:	0aa1                	addi	s5,s5,8
  800506:	41f7d71b          	sraiw	a4,a5,0x1f
  80050a:	8fb9                	xor	a5,a5,a4
  80050c:	40e7873b          	subw	a4,a5,a4
  800510:	02e6c663          	blt	a3,a4,80053c <vprintfmt+0x290>
  800514:	00000797          	auipc	a5,0x0
  800518:	5d478793          	addi	a5,a5,1492 # 800ae8 <error_string>
  80051c:	00371693          	slli	a3,a4,0x3
  800520:	97b6                	add	a5,a5,a3
  800522:	639c                	ld	a5,0(a5)
  800524:	cf81                	beqz	a5,80053c <vprintfmt+0x290>
  800526:	873e                	mv	a4,a5
  800528:	00000697          	auipc	a3,0x0
  80052c:	25068693          	addi	a3,a3,592 # 800778 <main+0x132>
  800530:	864a                	mv	a2,s2
  800532:	85ce                	mv	a1,s3
  800534:	8526                	mv	a0,s1
  800536:	0f2000ef          	jal	800628 <printfmt>
  80053a:	b365                	j	8002e2 <vprintfmt+0x36>
  80053c:	00000697          	auipc	a3,0x0
  800540:	22c68693          	addi	a3,a3,556 # 800768 <main+0x122>
  800544:	864a                	mv	a2,s2
  800546:	85ce                	mv	a1,s3
  800548:	8526                	mv	a0,s1
  80054a:	0de000ef          	jal	800628 <printfmt>
  80054e:	bb51                	j	8002e2 <vprintfmt+0x36>
  800550:	4785                	li	a5,1
  800552:	008a8c13          	addi	s8,s5,8
  800556:	00b7c363          	blt	a5,a1,80055c <vprintfmt+0x2b0>
  80055a:	cd81                	beqz	a1,800572 <vprintfmt+0x2c6>
  80055c:	000ab403          	ld	s0,0(s5)
  800560:	02044b63          	bltz	s0,800596 <vprintfmt+0x2ea>
  800564:	86a2                	mv	a3,s0
  800566:	8ae2                	mv	s5,s8
  800568:	4729                	li	a4,10
  80056a:	b5a5                	j	8003d2 <vprintfmt+0x126>
  80056c:	2585                	addiw	a1,a1,1
  80056e:	8466                	mv	s0,s9
  800570:	bb71                	j	80030c <vprintfmt+0x60>
  800572:	000aa403          	lw	s0,0(s5)
  800576:	b7ed                	j	800560 <vprintfmt+0x2b4>
  800578:	000ae683          	lwu	a3,0(s5)
  80057c:	4721                	li	a4,8
  80057e:	8ab2                	mv	s5,a2
  800580:	bd89                	j	8003d2 <vprintfmt+0x126>
  800582:	000ae683          	lwu	a3,0(s5)
  800586:	4729                	li	a4,10
  800588:	8ab2                	mv	s5,a2
  80058a:	b5a1                	j	8003d2 <vprintfmt+0x126>
  80058c:	000ae683          	lwu	a3,0(s5)
  800590:	4741                	li	a4,16
  800592:	8ab2                	mv	s5,a2
  800594:	bd3d                	j	8003d2 <vprintfmt+0x126>
  800596:	864e                	mv	a2,s3
  800598:	85ca                	mv	a1,s2
  80059a:	02d00513          	li	a0,45
  80059e:	e042                	sd	a6,0(sp)
  8005a0:	9482                	jalr	s1
  8005a2:	6802                	ld	a6,0(sp)
  8005a4:	408006b3          	neg	a3,s0
  8005a8:	8ae2                	mv	s5,s8
  8005aa:	4729                	li	a4,10
  8005ac:	b51d                	j	8003d2 <vprintfmt+0x126>
  8005ae:	eba1                	bnez	a5,8005fe <vprintfmt+0x352>
  8005b0:	02800793          	li	a5,40
  8005b4:	853e                	mv	a0,a5
  8005b6:	00000a97          	auipc	s5,0x0
  8005ba:	1aba8a93          	addi	s5,s5,427 # 800761 <main+0x11b>
  8005be:	547d                	li	s0,-1
  8005c0:	bdf1                	j	80049c <vprintfmt+0x1f0>
  8005c2:	853a                	mv	a0,a4
  8005c4:	85ea                	mv	a1,s10
  8005c6:	e03a                	sd	a4,0(sp)
  8005c8:	c59ff0ef          	jal	800220 <strnlen>
  8005cc:	40ad8dbb          	subw	s11,s11,a0
  8005d0:	6702                	ld	a4,0(sp)
  8005d2:	01b05b63          	blez	s11,8005e8 <vprintfmt+0x33c>
  8005d6:	864e                	mv	a2,s3
  8005d8:	85ca                	mv	a1,s2
  8005da:	8522                	mv	a0,s0
  8005dc:	e03a                	sd	a4,0(sp)
  8005de:	3dfd                	addiw	s11,s11,-1
  8005e0:	9482                	jalr	s1
  8005e2:	6702                	ld	a4,0(sp)
  8005e4:	fe0d99e3          	bnez	s11,8005d6 <vprintfmt+0x32a>
  8005e8:	00074783          	lbu	a5,0(a4)
  8005ec:	0007851b          	sext.w	a0,a5
  8005f0:	ee0781e3          	beqz	a5,8004d2 <vprintfmt+0x226>
  8005f4:	00170a93          	addi	s5,a4,1
  8005f8:	b54d                	j	80049a <vprintfmt+0x1ee>
  8005fa:	8466                	mv	s0,s9
  8005fc:	b36d                	j	8003a6 <vprintfmt+0xfa>
  8005fe:	85ea                	mv	a1,s10
  800600:	00000517          	auipc	a0,0x0
  800604:	16050513          	addi	a0,a0,352 # 800760 <main+0x11a>
  800608:	c19ff0ef          	jal	800220 <strnlen>
  80060c:	40ad8dbb          	subw	s11,s11,a0
  800610:	02800793          	li	a5,40
  800614:	00000717          	auipc	a4,0x0
  800618:	14c70713          	addi	a4,a4,332 # 800760 <main+0x11a>
  80061c:	853e                	mv	a0,a5
  80061e:	fbb04ce3          	bgtz	s11,8005d6 <vprintfmt+0x32a>
  800622:	00170a93          	addi	s5,a4,1
  800626:	bd95                	j	80049a <vprintfmt+0x1ee>

0000000000800628 <printfmt>:
  800628:	7139                	addi	sp,sp,-64
  80062a:	02010313          	addi	t1,sp,32
  80062e:	f03a                	sd	a4,32(sp)
  800630:	871a                	mv	a4,t1
  800632:	ec06                	sd	ra,24(sp)
  800634:	f43e                	sd	a5,40(sp)
  800636:	f842                	sd	a6,48(sp)
  800638:	fc46                	sd	a7,56(sp)
  80063a:	e41a                	sd	t1,8(sp)
  80063c:	c71ff0ef          	jal	8002ac <vprintfmt>
  800640:	60e2                	ld	ra,24(sp)
  800642:	6121                	addi	sp,sp,64
  800644:	8082                	ret

0000000000800646 <main>:
  800646:	1141                	addi	sp,sp,-16
  800648:	00000517          	auipc	a0,0x0
  80064c:	31050513          	addi	a0,a0,784 # 800958 <main+0x312>
  800650:	e406                	sd	ra,8(sp)
  800652:	adfff0ef          	jal	800130 <cprintf>
  800656:	a8bff0ef          	jal	8000e0 <getpid>
  80065a:	85aa                	mv	a1,a0
  80065c:	00000517          	auipc	a0,0x0
  800660:	30c50513          	addi	a0,a0,780 # 800968 <main+0x322>
  800664:	acdff0ef          	jal	800130 <cprintf>
  800668:	00000517          	auipc	a0,0x0
  80066c:	31850513          	addi	a0,a0,792 # 800980 <main+0x33a>
  800670:	ac1ff0ef          	jal	800130 <cprintf>
  800674:	60a2                	ld	ra,8(sp)
  800676:	4501                	li	a0,0
  800678:	0141                	addi	sp,sp,16
  80067a:	8082                	ret
