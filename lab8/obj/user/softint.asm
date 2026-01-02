
obj/__user_softint.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__warn>:
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	02810313          	addi	t1,sp,40
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	64a50513          	addi	a0,a0,1610 # 800678 <main+0x38>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	0e6000ef          	jal	80012a <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0b8000ef          	jal	800104 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	62050513          	addi	a0,a0,1568 # 800670 <main+0x30>
  800058:	0d2000ef          	jal	80012a <cprintf>
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

00000000008000a4 <sys_putc>:
  8000a4:	85aa                	mv	a1,a0
  8000a6:	4579                	li	a0,30
  8000a8:	bf75                	j	800064 <syscall>

00000000008000aa <sys_open>:
  8000aa:	862e                	mv	a2,a1
  8000ac:	85aa                	mv	a1,a0
  8000ae:	06400513          	li	a0,100
  8000b2:	bf4d                	j	800064 <syscall>

00000000008000b4 <sys_close>:
  8000b4:	85aa                	mv	a1,a0
  8000b6:	06500513          	li	a0,101
  8000ba:	b76d                	j	800064 <syscall>

00000000008000bc <sys_dup>:
  8000bc:	862e                	mv	a2,a1
  8000be:	85aa                	mv	a1,a0
  8000c0:	08200513          	li	a0,130
  8000c4:	b745                	j	800064 <syscall>

00000000008000c6 <exit>:
  8000c6:	1141                	addi	sp,sp,-16
  8000c8:	e406                	sd	ra,8(sp)
  8000ca:	fd5ff0ef          	jal	80009e <sys_exit>
  8000ce:	00000517          	auipc	a0,0x0
  8000d2:	5ca50513          	addi	a0,a0,1482 # 800698 <main+0x58>
  8000d6:	054000ef          	jal	80012a <cprintf>
  8000da:	a001                	j	8000da <exit+0x14>

00000000008000dc <_start>:
  8000dc:	0ca000ef          	jal	8001a6 <umain>
  8000e0:	a001                	j	8000e0 <_start+0x4>

00000000008000e2 <open>:
  8000e2:	1582                	slli	a1,a1,0x20
  8000e4:	9181                	srli	a1,a1,0x20
  8000e6:	b7d1                	j	8000aa <sys_open>

00000000008000e8 <close>:
  8000e8:	b7f1                	j	8000b4 <sys_close>

00000000008000ea <dup2>:
  8000ea:	bfc9                	j	8000bc <sys_dup>

00000000008000ec <cputch>:
  8000ec:	1101                	addi	sp,sp,-32
  8000ee:	ec06                	sd	ra,24(sp)
  8000f0:	e42e                	sd	a1,8(sp)
  8000f2:	fb3ff0ef          	jal	8000a4 <sys_putc>
  8000f6:	65a2                	ld	a1,8(sp)
  8000f8:	60e2                	ld	ra,24(sp)
  8000fa:	419c                	lw	a5,0(a1)
  8000fc:	2785                	addiw	a5,a5,1
  8000fe:	c19c                	sw	a5,0(a1)
  800100:	6105                	addi	sp,sp,32
  800102:	8082                	ret

0000000000800104 <vcprintf>:
  800104:	1101                	addi	sp,sp,-32
  800106:	872e                	mv	a4,a1
  800108:	75dd                	lui	a1,0xffff7
  80010a:	86aa                	mv	a3,a0
  80010c:	0070                	addi	a2,sp,12
  80010e:	00000517          	auipc	a0,0x0
  800112:	fde50513          	addi	a0,a0,-34 # 8000ec <cputch>
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6059>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	c602                	sw	zero,12(sp)
  80011e:	188000ef          	jal	8002a6 <vprintfmt>
  800122:	60e2                	ld	ra,24(sp)
  800124:	4532                	lw	a0,12(sp)
  800126:	6105                	addi	sp,sp,32
  800128:	8082                	ret

000000000080012a <cprintf>:
  80012a:	711d                	addi	sp,sp,-96
  80012c:	02810313          	addi	t1,sp,40
  800130:	f42e                	sd	a1,40(sp)
  800132:	75dd                	lui	a1,0xffff7
  800134:	f832                	sd	a2,48(sp)
  800136:	fc36                	sd	a3,56(sp)
  800138:	e0ba                	sd	a4,64(sp)
  80013a:	86aa                	mv	a3,a0
  80013c:	0050                	addi	a2,sp,4
  80013e:	00000517          	auipc	a0,0x0
  800142:	fae50513          	addi	a0,a0,-82 # 8000ec <cputch>
  800146:	871a                	mv	a4,t1
  800148:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6059>
  80014c:	ec06                	sd	ra,24(sp)
  80014e:	e4be                	sd	a5,72(sp)
  800150:	e8c2                	sd	a6,80(sp)
  800152:	ecc6                	sd	a7,88(sp)
  800154:	c202                	sw	zero,4(sp)
  800156:	e41a                	sd	t1,8(sp)
  800158:	14e000ef          	jal	8002a6 <vprintfmt>
  80015c:	60e2                	ld	ra,24(sp)
  80015e:	4512                	lw	a0,4(sp)
  800160:	6125                	addi	sp,sp,96
  800162:	8082                	ret

0000000000800164 <initfd>:
  800164:	87ae                	mv	a5,a1
  800166:	1101                	addi	sp,sp,-32
  800168:	e822                	sd	s0,16(sp)
  80016a:	85b2                	mv	a1,a2
  80016c:	842a                	mv	s0,a0
  80016e:	853e                	mv	a0,a5
  800170:	ec06                	sd	ra,24(sp)
  800172:	f71ff0ef          	jal	8000e2 <open>
  800176:	87aa                	mv	a5,a0
  800178:	00054463          	bltz	a0,800180 <initfd+0x1c>
  80017c:	00851763          	bne	a0,s0,80018a <initfd+0x26>
  800180:	60e2                	ld	ra,24(sp)
  800182:	6442                	ld	s0,16(sp)
  800184:	853e                	mv	a0,a5
  800186:	6105                	addi	sp,sp,32
  800188:	8082                	ret
  80018a:	e42a                	sd	a0,8(sp)
  80018c:	8522                	mv	a0,s0
  80018e:	f5bff0ef          	jal	8000e8 <close>
  800192:	6522                	ld	a0,8(sp)
  800194:	85a2                	mv	a1,s0
  800196:	f55ff0ef          	jal	8000ea <dup2>
  80019a:	842a                	mv	s0,a0
  80019c:	6522                	ld	a0,8(sp)
  80019e:	f4bff0ef          	jal	8000e8 <close>
  8001a2:	87a2                	mv	a5,s0
  8001a4:	bff1                	j	800180 <initfd+0x1c>

00000000008001a6 <umain>:
  8001a6:	1101                	addi	sp,sp,-32
  8001a8:	e822                	sd	s0,16(sp)
  8001aa:	e426                	sd	s1,8(sp)
  8001ac:	842a                	mv	s0,a0
  8001ae:	84ae                	mv	s1,a1
  8001b0:	4601                	li	a2,0
  8001b2:	00000597          	auipc	a1,0x0
  8001b6:	4fe58593          	addi	a1,a1,1278 # 8006b0 <main+0x70>
  8001ba:	4501                	li	a0,0
  8001bc:	ec06                	sd	ra,24(sp)
  8001be:	fa7ff0ef          	jal	800164 <initfd>
  8001c2:	02054263          	bltz	a0,8001e6 <umain+0x40>
  8001c6:	4605                	li	a2,1
  8001c8:	8532                	mv	a0,a2
  8001ca:	00000597          	auipc	a1,0x0
  8001ce:	52658593          	addi	a1,a1,1318 # 8006f0 <main+0xb0>
  8001d2:	f93ff0ef          	jal	800164 <initfd>
  8001d6:	02054563          	bltz	a0,800200 <umain+0x5a>
  8001da:	85a6                	mv	a1,s1
  8001dc:	8522                	mv	a0,s0
  8001de:	462000ef          	jal	800640 <main>
  8001e2:	ee5ff0ef          	jal	8000c6 <exit>
  8001e6:	86aa                	mv	a3,a0
  8001e8:	00000617          	auipc	a2,0x0
  8001ec:	4d060613          	addi	a2,a2,1232 # 8006b8 <main+0x78>
  8001f0:	45e9                	li	a1,26
  8001f2:	00000517          	auipc	a0,0x0
  8001f6:	4e650513          	addi	a0,a0,1254 # 8006d8 <main+0x98>
  8001fa:	e27ff0ef          	jal	800020 <__warn>
  8001fe:	b7e1                	j	8001c6 <umain+0x20>
  800200:	86aa                	mv	a3,a0
  800202:	00000617          	auipc	a2,0x0
  800206:	4f660613          	addi	a2,a2,1270 # 8006f8 <main+0xb8>
  80020a:	45f5                	li	a1,29
  80020c:	00000517          	auipc	a0,0x0
  800210:	4cc50513          	addi	a0,a0,1228 # 8006d8 <main+0x98>
  800214:	e0dff0ef          	jal	800020 <__warn>
  800218:	b7c9                	j	8001da <umain+0x34>

000000000080021a <strnlen>:
  80021a:	4781                	li	a5,0
  80021c:	e589                	bnez	a1,800226 <strnlen+0xc>
  80021e:	a811                	j	800232 <strnlen+0x18>
  800220:	0785                	addi	a5,a5,1
  800222:	00f58863          	beq	a1,a5,800232 <strnlen+0x18>
  800226:	00f50733          	add	a4,a0,a5
  80022a:	00074703          	lbu	a4,0(a4)
  80022e:	fb6d                	bnez	a4,800220 <strnlen+0x6>
  800230:	85be                	mv	a1,a5
  800232:	852e                	mv	a0,a1
  800234:	8082                	ret

0000000000800236 <printnum>:
  800236:	7139                	addi	sp,sp,-64
  800238:	02071893          	slli	a7,a4,0x20
  80023c:	f822                	sd	s0,48(sp)
  80023e:	f426                	sd	s1,40(sp)
  800240:	f04a                	sd	s2,32(sp)
  800242:	ec4e                	sd	s3,24(sp)
  800244:	e456                	sd	s5,8(sp)
  800246:	0208d893          	srli	a7,a7,0x20
  80024a:	fc06                	sd	ra,56(sp)
  80024c:	0316fab3          	remu	s5,a3,a7
  800250:	fff7841b          	addiw	s0,a5,-1
  800254:	84aa                	mv	s1,a0
  800256:	89ae                	mv	s3,a1
  800258:	8932                	mv	s2,a2
  80025a:	0516f063          	bgeu	a3,a7,80029a <printnum+0x64>
  80025e:	e852                	sd	s4,16(sp)
  800260:	4705                	li	a4,1
  800262:	8a42                	mv	s4,a6
  800264:	00f75863          	bge	a4,a5,800274 <printnum+0x3e>
  800268:	864e                	mv	a2,s3
  80026a:	85ca                	mv	a1,s2
  80026c:	8552                	mv	a0,s4
  80026e:	347d                	addiw	s0,s0,-1
  800270:	9482                	jalr	s1
  800272:	f87d                	bnez	s0,800268 <printnum+0x32>
  800274:	6a42                	ld	s4,16(sp)
  800276:	00000797          	auipc	a5,0x0
  80027a:	4a278793          	addi	a5,a5,1186 # 800718 <main+0xd8>
  80027e:	97d6                	add	a5,a5,s5
  800280:	7442                	ld	s0,48(sp)
  800282:	0007c503          	lbu	a0,0(a5)
  800286:	70e2                	ld	ra,56(sp)
  800288:	6aa2                	ld	s5,8(sp)
  80028a:	864e                	mv	a2,s3
  80028c:	85ca                	mv	a1,s2
  80028e:	69e2                	ld	s3,24(sp)
  800290:	7902                	ld	s2,32(sp)
  800292:	87a6                	mv	a5,s1
  800294:	74a2                	ld	s1,40(sp)
  800296:	6121                	addi	sp,sp,64
  800298:	8782                	jr	a5
  80029a:	0316d6b3          	divu	a3,a3,a7
  80029e:	87a2                	mv	a5,s0
  8002a0:	f97ff0ef          	jal	800236 <printnum>
  8002a4:	bfc9                	j	800276 <printnum+0x40>

00000000008002a6 <vprintfmt>:
  8002a6:	7119                	addi	sp,sp,-128
  8002a8:	f4a6                	sd	s1,104(sp)
  8002aa:	f0ca                	sd	s2,96(sp)
  8002ac:	ecce                	sd	s3,88(sp)
  8002ae:	e8d2                	sd	s4,80(sp)
  8002b0:	e4d6                	sd	s5,72(sp)
  8002b2:	e0da                	sd	s6,64(sp)
  8002b4:	fc5e                	sd	s7,56(sp)
  8002b6:	f466                	sd	s9,40(sp)
  8002b8:	fc86                	sd	ra,120(sp)
  8002ba:	f8a2                	sd	s0,112(sp)
  8002bc:	f862                	sd	s8,48(sp)
  8002be:	f06a                	sd	s10,32(sp)
  8002c0:	ec6e                	sd	s11,24(sp)
  8002c2:	84aa                	mv	s1,a0
  8002c4:	8cb6                	mv	s9,a3
  8002c6:	8aba                	mv	s5,a4
  8002c8:	89ae                	mv	s3,a1
  8002ca:	8932                	mv	s2,a2
  8002cc:	02500a13          	li	s4,37
  8002d0:	05500b93          	li	s7,85
  8002d4:	00000b17          	auipc	s6,0x0
  8002d8:	654b0b13          	addi	s6,s6,1620 # 800928 <main+0x2e8>
  8002dc:	000cc503          	lbu	a0,0(s9)
  8002e0:	001c8413          	addi	s0,s9,1
  8002e4:	01450b63          	beq	a0,s4,8002fa <vprintfmt+0x54>
  8002e8:	cd15                	beqz	a0,800324 <vprintfmt+0x7e>
  8002ea:	864e                	mv	a2,s3
  8002ec:	85ca                	mv	a1,s2
  8002ee:	9482                	jalr	s1
  8002f0:	00044503          	lbu	a0,0(s0)
  8002f4:	0405                	addi	s0,s0,1
  8002f6:	ff4519e3          	bne	a0,s4,8002e8 <vprintfmt+0x42>
  8002fa:	5d7d                	li	s10,-1
  8002fc:	8dea                	mv	s11,s10
  8002fe:	02000813          	li	a6,32
  800302:	4c01                	li	s8,0
  800304:	4581                	li	a1,0
  800306:	00044703          	lbu	a4,0(s0)
  80030a:	00140c93          	addi	s9,s0,1
  80030e:	fdd7061b          	addiw	a2,a4,-35
  800312:	0ff67613          	zext.b	a2,a2
  800316:	02cbe663          	bltu	s7,a2,800342 <vprintfmt+0x9c>
  80031a:	060a                	slli	a2,a2,0x2
  80031c:	965a                	add	a2,a2,s6
  80031e:	421c                	lw	a5,0(a2)
  800320:	97da                	add	a5,a5,s6
  800322:	8782                	jr	a5
  800324:	70e6                	ld	ra,120(sp)
  800326:	7446                	ld	s0,112(sp)
  800328:	74a6                	ld	s1,104(sp)
  80032a:	7906                	ld	s2,96(sp)
  80032c:	69e6                	ld	s3,88(sp)
  80032e:	6a46                	ld	s4,80(sp)
  800330:	6aa6                	ld	s5,72(sp)
  800332:	6b06                	ld	s6,64(sp)
  800334:	7be2                	ld	s7,56(sp)
  800336:	7c42                	ld	s8,48(sp)
  800338:	7ca2                	ld	s9,40(sp)
  80033a:	7d02                	ld	s10,32(sp)
  80033c:	6de2                	ld	s11,24(sp)
  80033e:	6109                	addi	sp,sp,128
  800340:	8082                	ret
  800342:	864e                	mv	a2,s3
  800344:	85ca                	mv	a1,s2
  800346:	02500513          	li	a0,37
  80034a:	9482                	jalr	s1
  80034c:	fff44783          	lbu	a5,-1(s0)
  800350:	02500713          	li	a4,37
  800354:	8ca2                	mv	s9,s0
  800356:	f8e783e3          	beq	a5,a4,8002dc <vprintfmt+0x36>
  80035a:	ffecc783          	lbu	a5,-2(s9)
  80035e:	1cfd                	addi	s9,s9,-1
  800360:	fee79de3          	bne	a5,a4,80035a <vprintfmt+0xb4>
  800364:	bfa5                	j	8002dc <vprintfmt+0x36>
  800366:	00144683          	lbu	a3,1(s0)
  80036a:	4525                	li	a0,9
  80036c:	fd070d1b          	addiw	s10,a4,-48
  800370:	fd06879b          	addiw	a5,a3,-48
  800374:	28f56063          	bltu	a0,a5,8005f4 <vprintfmt+0x34e>
  800378:	2681                	sext.w	a3,a3
  80037a:	8466                	mv	s0,s9
  80037c:	002d179b          	slliw	a5,s10,0x2
  800380:	00144703          	lbu	a4,1(s0)
  800384:	01a787bb          	addw	a5,a5,s10
  800388:	0017979b          	slliw	a5,a5,0x1
  80038c:	9fb5                	addw	a5,a5,a3
  80038e:	fd07061b          	addiw	a2,a4,-48
  800392:	0405                	addi	s0,s0,1
  800394:	fd078d1b          	addiw	s10,a5,-48
  800398:	0007069b          	sext.w	a3,a4
  80039c:	fec570e3          	bgeu	a0,a2,80037c <vprintfmt+0xd6>
  8003a0:	f60dd3e3          	bgez	s11,800306 <vprintfmt+0x60>
  8003a4:	8dea                	mv	s11,s10
  8003a6:	5d7d                	li	s10,-1
  8003a8:	bfb9                	j	800306 <vprintfmt+0x60>
  8003aa:	883a                	mv	a6,a4
  8003ac:	8466                	mv	s0,s9
  8003ae:	bfa1                	j	800306 <vprintfmt+0x60>
  8003b0:	8466                	mv	s0,s9
  8003b2:	4c05                	li	s8,1
  8003b4:	bf89                	j	800306 <vprintfmt+0x60>
  8003b6:	4785                	li	a5,1
  8003b8:	008a8613          	addi	a2,s5,8
  8003bc:	00b7c463          	blt	a5,a1,8003c4 <vprintfmt+0x11e>
  8003c0:	1c058363          	beqz	a1,800586 <vprintfmt+0x2e0>
  8003c4:	000ab683          	ld	a3,0(s5)
  8003c8:	4741                	li	a4,16
  8003ca:	8ab2                	mv	s5,a2
  8003cc:	2801                	sext.w	a6,a6
  8003ce:	87ee                	mv	a5,s11
  8003d0:	864a                	mv	a2,s2
  8003d2:	85ce                	mv	a1,s3
  8003d4:	8526                	mv	a0,s1
  8003d6:	e61ff0ef          	jal	800236 <printnum>
  8003da:	b709                	j	8002dc <vprintfmt+0x36>
  8003dc:	000aa503          	lw	a0,0(s5)
  8003e0:	864e                	mv	a2,s3
  8003e2:	85ca                	mv	a1,s2
  8003e4:	9482                	jalr	s1
  8003e6:	0aa1                	addi	s5,s5,8
  8003e8:	bdd5                	j	8002dc <vprintfmt+0x36>
  8003ea:	4785                	li	a5,1
  8003ec:	008a8613          	addi	a2,s5,8
  8003f0:	00b7c463          	blt	a5,a1,8003f8 <vprintfmt+0x152>
  8003f4:	18058463          	beqz	a1,80057c <vprintfmt+0x2d6>
  8003f8:	000ab683          	ld	a3,0(s5)
  8003fc:	4729                	li	a4,10
  8003fe:	8ab2                	mv	s5,a2
  800400:	b7f1                	j	8003cc <vprintfmt+0x126>
  800402:	864e                	mv	a2,s3
  800404:	85ca                	mv	a1,s2
  800406:	03000513          	li	a0,48
  80040a:	e042                	sd	a6,0(sp)
  80040c:	9482                	jalr	s1
  80040e:	864e                	mv	a2,s3
  800410:	85ca                	mv	a1,s2
  800412:	07800513          	li	a0,120
  800416:	9482                	jalr	s1
  800418:	000ab683          	ld	a3,0(s5)
  80041c:	6802                	ld	a6,0(sp)
  80041e:	4741                	li	a4,16
  800420:	0aa1                	addi	s5,s5,8
  800422:	b76d                	j	8003cc <vprintfmt+0x126>
  800424:	864e                	mv	a2,s3
  800426:	85ca                	mv	a1,s2
  800428:	02500513          	li	a0,37
  80042c:	9482                	jalr	s1
  80042e:	b57d                	j	8002dc <vprintfmt+0x36>
  800430:	000aad03          	lw	s10,0(s5)
  800434:	8466                	mv	s0,s9
  800436:	0aa1                	addi	s5,s5,8
  800438:	b7a5                	j	8003a0 <vprintfmt+0xfa>
  80043a:	4785                	li	a5,1
  80043c:	008a8613          	addi	a2,s5,8
  800440:	00b7c463          	blt	a5,a1,800448 <vprintfmt+0x1a2>
  800444:	12058763          	beqz	a1,800572 <vprintfmt+0x2cc>
  800448:	000ab683          	ld	a3,0(s5)
  80044c:	4721                	li	a4,8
  80044e:	8ab2                	mv	s5,a2
  800450:	bfb5                	j	8003cc <vprintfmt+0x126>
  800452:	87ee                	mv	a5,s11
  800454:	000dd363          	bgez	s11,80045a <vprintfmt+0x1b4>
  800458:	4781                	li	a5,0
  80045a:	00078d9b          	sext.w	s11,a5
  80045e:	8466                	mv	s0,s9
  800460:	b55d                	j	800306 <vprintfmt+0x60>
  800462:	0008041b          	sext.w	s0,a6
  800466:	fd340793          	addi	a5,s0,-45
  80046a:	01b02733          	sgtz	a4,s11
  80046e:	00f037b3          	snez	a5,a5
  800472:	8ff9                	and	a5,a5,a4
  800474:	000ab703          	ld	a4,0(s5)
  800478:	008a8693          	addi	a3,s5,8
  80047c:	e436                	sd	a3,8(sp)
  80047e:	12070563          	beqz	a4,8005a8 <vprintfmt+0x302>
  800482:	12079d63          	bnez	a5,8005bc <vprintfmt+0x316>
  800486:	00074783          	lbu	a5,0(a4)
  80048a:	0007851b          	sext.w	a0,a5
  80048e:	c78d                	beqz	a5,8004b8 <vprintfmt+0x212>
  800490:	00170a93          	addi	s5,a4,1
  800494:	547d                	li	s0,-1
  800496:	000d4563          	bltz	s10,8004a0 <vprintfmt+0x1fa>
  80049a:	3d7d                	addiw	s10,s10,-1
  80049c:	008d0e63          	beq	s10,s0,8004b8 <vprintfmt+0x212>
  8004a0:	020c1863          	bnez	s8,8004d0 <vprintfmt+0x22a>
  8004a4:	864e                	mv	a2,s3
  8004a6:	85ca                	mv	a1,s2
  8004a8:	9482                	jalr	s1
  8004aa:	000ac783          	lbu	a5,0(s5)
  8004ae:	0a85                	addi	s5,s5,1
  8004b0:	3dfd                	addiw	s11,s11,-1
  8004b2:	0007851b          	sext.w	a0,a5
  8004b6:	f3e5                	bnez	a5,800496 <vprintfmt+0x1f0>
  8004b8:	01b05a63          	blez	s11,8004cc <vprintfmt+0x226>
  8004bc:	864e                	mv	a2,s3
  8004be:	85ca                	mv	a1,s2
  8004c0:	02000513          	li	a0,32
  8004c4:	3dfd                	addiw	s11,s11,-1
  8004c6:	9482                	jalr	s1
  8004c8:	fe0d9ae3          	bnez	s11,8004bc <vprintfmt+0x216>
  8004cc:	6aa2                	ld	s5,8(sp)
  8004ce:	b539                	j	8002dc <vprintfmt+0x36>
  8004d0:	3781                	addiw	a5,a5,-32
  8004d2:	05e00713          	li	a4,94
  8004d6:	fcf777e3          	bgeu	a4,a5,8004a4 <vprintfmt+0x1fe>
  8004da:	03f00513          	li	a0,63
  8004de:	864e                	mv	a2,s3
  8004e0:	85ca                	mv	a1,s2
  8004e2:	9482                	jalr	s1
  8004e4:	000ac783          	lbu	a5,0(s5)
  8004e8:	0a85                	addi	s5,s5,1
  8004ea:	3dfd                	addiw	s11,s11,-1
  8004ec:	0007851b          	sext.w	a0,a5
  8004f0:	d7e1                	beqz	a5,8004b8 <vprintfmt+0x212>
  8004f2:	fa0d54e3          	bgez	s10,80049a <vprintfmt+0x1f4>
  8004f6:	bfe9                	j	8004d0 <vprintfmt+0x22a>
  8004f8:	000aa783          	lw	a5,0(s5)
  8004fc:	46e1                	li	a3,24
  8004fe:	0aa1                	addi	s5,s5,8
  800500:	41f7d71b          	sraiw	a4,a5,0x1f
  800504:	8fb9                	xor	a5,a5,a4
  800506:	40e7873b          	subw	a4,a5,a4
  80050a:	02e6c663          	blt	a3,a4,800536 <vprintfmt+0x290>
  80050e:	00000797          	auipc	a5,0x0
  800512:	57278793          	addi	a5,a5,1394 # 800a80 <error_string>
  800516:	00371693          	slli	a3,a4,0x3
  80051a:	97b6                	add	a5,a5,a3
  80051c:	639c                	ld	a5,0(a5)
  80051e:	cf81                	beqz	a5,800536 <vprintfmt+0x290>
  800520:	873e                	mv	a4,a5
  800522:	00000697          	auipc	a3,0x0
  800526:	22668693          	addi	a3,a3,550 # 800748 <main+0x108>
  80052a:	864a                	mv	a2,s2
  80052c:	85ce                	mv	a1,s3
  80052e:	8526                	mv	a0,s1
  800530:	0f2000ef          	jal	800622 <printfmt>
  800534:	b365                	j	8002dc <vprintfmt+0x36>
  800536:	00000697          	auipc	a3,0x0
  80053a:	20268693          	addi	a3,a3,514 # 800738 <main+0xf8>
  80053e:	864a                	mv	a2,s2
  800540:	85ce                	mv	a1,s3
  800542:	8526                	mv	a0,s1
  800544:	0de000ef          	jal	800622 <printfmt>
  800548:	bb51                	j	8002dc <vprintfmt+0x36>
  80054a:	4785                	li	a5,1
  80054c:	008a8c13          	addi	s8,s5,8
  800550:	00b7c363          	blt	a5,a1,800556 <vprintfmt+0x2b0>
  800554:	cd81                	beqz	a1,80056c <vprintfmt+0x2c6>
  800556:	000ab403          	ld	s0,0(s5)
  80055a:	02044b63          	bltz	s0,800590 <vprintfmt+0x2ea>
  80055e:	86a2                	mv	a3,s0
  800560:	8ae2                	mv	s5,s8
  800562:	4729                	li	a4,10
  800564:	b5a5                	j	8003cc <vprintfmt+0x126>
  800566:	2585                	addiw	a1,a1,1
  800568:	8466                	mv	s0,s9
  80056a:	bb71                	j	800306 <vprintfmt+0x60>
  80056c:	000aa403          	lw	s0,0(s5)
  800570:	b7ed                	j	80055a <vprintfmt+0x2b4>
  800572:	000ae683          	lwu	a3,0(s5)
  800576:	4721                	li	a4,8
  800578:	8ab2                	mv	s5,a2
  80057a:	bd89                	j	8003cc <vprintfmt+0x126>
  80057c:	000ae683          	lwu	a3,0(s5)
  800580:	4729                	li	a4,10
  800582:	8ab2                	mv	s5,a2
  800584:	b5a1                	j	8003cc <vprintfmt+0x126>
  800586:	000ae683          	lwu	a3,0(s5)
  80058a:	4741                	li	a4,16
  80058c:	8ab2                	mv	s5,a2
  80058e:	bd3d                	j	8003cc <vprintfmt+0x126>
  800590:	864e                	mv	a2,s3
  800592:	85ca                	mv	a1,s2
  800594:	02d00513          	li	a0,45
  800598:	e042                	sd	a6,0(sp)
  80059a:	9482                	jalr	s1
  80059c:	6802                	ld	a6,0(sp)
  80059e:	408006b3          	neg	a3,s0
  8005a2:	8ae2                	mv	s5,s8
  8005a4:	4729                	li	a4,10
  8005a6:	b51d                	j	8003cc <vprintfmt+0x126>
  8005a8:	eba1                	bnez	a5,8005f8 <vprintfmt+0x352>
  8005aa:	02800793          	li	a5,40
  8005ae:	853e                	mv	a0,a5
  8005b0:	00000a97          	auipc	s5,0x0
  8005b4:	181a8a93          	addi	s5,s5,385 # 800731 <main+0xf1>
  8005b8:	547d                	li	s0,-1
  8005ba:	bdf1                	j	800496 <vprintfmt+0x1f0>
  8005bc:	853a                	mv	a0,a4
  8005be:	85ea                	mv	a1,s10
  8005c0:	e03a                	sd	a4,0(sp)
  8005c2:	c59ff0ef          	jal	80021a <strnlen>
  8005c6:	40ad8dbb          	subw	s11,s11,a0
  8005ca:	6702                	ld	a4,0(sp)
  8005cc:	01b05b63          	blez	s11,8005e2 <vprintfmt+0x33c>
  8005d0:	864e                	mv	a2,s3
  8005d2:	85ca                	mv	a1,s2
  8005d4:	8522                	mv	a0,s0
  8005d6:	e03a                	sd	a4,0(sp)
  8005d8:	3dfd                	addiw	s11,s11,-1
  8005da:	9482                	jalr	s1
  8005dc:	6702                	ld	a4,0(sp)
  8005de:	fe0d99e3          	bnez	s11,8005d0 <vprintfmt+0x32a>
  8005e2:	00074783          	lbu	a5,0(a4)
  8005e6:	0007851b          	sext.w	a0,a5
  8005ea:	ee0781e3          	beqz	a5,8004cc <vprintfmt+0x226>
  8005ee:	00170a93          	addi	s5,a4,1
  8005f2:	b54d                	j	800494 <vprintfmt+0x1ee>
  8005f4:	8466                	mv	s0,s9
  8005f6:	b36d                	j	8003a0 <vprintfmt+0xfa>
  8005f8:	85ea                	mv	a1,s10
  8005fa:	00000517          	auipc	a0,0x0
  8005fe:	13650513          	addi	a0,a0,310 # 800730 <main+0xf0>
  800602:	c19ff0ef          	jal	80021a <strnlen>
  800606:	40ad8dbb          	subw	s11,s11,a0
  80060a:	02800793          	li	a5,40
  80060e:	00000717          	auipc	a4,0x0
  800612:	12270713          	addi	a4,a4,290 # 800730 <main+0xf0>
  800616:	853e                	mv	a0,a5
  800618:	fbb04ce3          	bgtz	s11,8005d0 <vprintfmt+0x32a>
  80061c:	00170a93          	addi	s5,a4,1
  800620:	bd95                	j	800494 <vprintfmt+0x1ee>

0000000000800622 <printfmt>:
  800622:	7139                	addi	sp,sp,-64
  800624:	02010313          	addi	t1,sp,32
  800628:	f03a                	sd	a4,32(sp)
  80062a:	871a                	mv	a4,t1
  80062c:	ec06                	sd	ra,24(sp)
  80062e:	f43e                	sd	a5,40(sp)
  800630:	f842                	sd	a6,48(sp)
  800632:	fc46                	sd	a7,56(sp)
  800634:	e41a                	sd	t1,8(sp)
  800636:	c71ff0ef          	jal	8002a6 <vprintfmt>
  80063a:	60e2                	ld	ra,24(sp)
  80063c:	6121                	addi	sp,sp,64
  80063e:	8082                	ret

0000000000800640 <main>:
  800640:	1141                	addi	sp,sp,-16
  800642:	4501                	li	a0,0
  800644:	e406                	sd	ra,8(sp)
  800646:	a81ff0ef          	jal	8000c6 <exit>
