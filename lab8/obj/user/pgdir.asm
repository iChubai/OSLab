
obj/__user_pgdir.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__warn>:
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	02810313          	addi	t1,sp,40
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	67a50513          	addi	a0,a0,1658 # 8006a8 <main+0x5c>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	0f2000ef          	jal	800136 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	0c4000ef          	jal	800110 <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	65050513          	addi	a0,a0,1616 # 8006a0 <main+0x54>
  800058:	0de000ef          	jal	800136 <cprintf>
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

00000000008000ae <sys_pgdir>:
  8000ae:	457d                	li	a0,31
  8000b0:	bf55                	j	800064 <syscall>

00000000008000b2 <sys_open>:
  8000b2:	862e                	mv	a2,a1
  8000b4:	85aa                	mv	a1,a0
  8000b6:	06400513          	li	a0,100
  8000ba:	b76d                	j	800064 <syscall>

00000000008000bc <sys_close>:
  8000bc:	85aa                	mv	a1,a0
  8000be:	06500513          	li	a0,101
  8000c2:	b74d                	j	800064 <syscall>

00000000008000c4 <sys_dup>:
  8000c4:	862e                	mv	a2,a1
  8000c6:	85aa                	mv	a1,a0
  8000c8:	08200513          	li	a0,130
  8000cc:	bf61                	j	800064 <syscall>

00000000008000ce <exit>:
  8000ce:	1141                	addi	sp,sp,-16
  8000d0:	e406                	sd	ra,8(sp)
  8000d2:	fcdff0ef          	jal	80009e <sys_exit>
  8000d6:	00000517          	auipc	a0,0x0
  8000da:	5f250513          	addi	a0,a0,1522 # 8006c8 <main+0x7c>
  8000de:	058000ef          	jal	800136 <cprintf>
  8000e2:	a001                	j	8000e2 <exit+0x14>

00000000008000e4 <getpid>:
  8000e4:	b7c1                	j	8000a4 <sys_getpid>

00000000008000e6 <print_pgdir>:
  8000e6:	b7e1                	j	8000ae <sys_pgdir>

00000000008000e8 <_start>:
  8000e8:	0ca000ef          	jal	8001b2 <umain>
  8000ec:	a001                	j	8000ec <_start+0x4>

00000000008000ee <open>:
  8000ee:	1582                	slli	a1,a1,0x20
  8000f0:	9181                	srli	a1,a1,0x20
  8000f2:	b7c1                	j	8000b2 <sys_open>

00000000008000f4 <close>:
  8000f4:	b7e1                	j	8000bc <sys_close>

00000000008000f6 <dup2>:
  8000f6:	b7f9                	j	8000c4 <sys_dup>

00000000008000f8 <cputch>:
  8000f8:	1101                	addi	sp,sp,-32
  8000fa:	ec06                	sd	ra,24(sp)
  8000fc:	e42e                	sd	a1,8(sp)
  8000fe:	fabff0ef          	jal	8000a8 <sys_putc>
  800102:	65a2                	ld	a1,8(sp)
  800104:	60e2                	ld	ra,24(sp)
  800106:	419c                	lw	a5,0(a1)
  800108:	2785                	addiw	a5,a5,1
  80010a:	c19c                	sw	a5,0(a1)
  80010c:	6105                	addi	sp,sp,32
  80010e:	8082                	ret

0000000000800110 <vcprintf>:
  800110:	1101                	addi	sp,sp,-32
  800112:	872e                	mv	a4,a1
  800114:	75dd                	lui	a1,0xffff7
  800116:	86aa                	mv	a3,a0
  800118:	0070                	addi	a2,sp,12
  80011a:	00000517          	auipc	a0,0x0
  80011e:	fde50513          	addi	a0,a0,-34 # 8000f8 <cputch>
  800122:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6001>
  800126:	ec06                	sd	ra,24(sp)
  800128:	c602                	sw	zero,12(sp)
  80012a:	188000ef          	jal	8002b2 <vprintfmt>
  80012e:	60e2                	ld	ra,24(sp)
  800130:	4532                	lw	a0,12(sp)
  800132:	6105                	addi	sp,sp,32
  800134:	8082                	ret

0000000000800136 <cprintf>:
  800136:	711d                	addi	sp,sp,-96
  800138:	02810313          	addi	t1,sp,40
  80013c:	f42e                	sd	a1,40(sp)
  80013e:	75dd                	lui	a1,0xffff7
  800140:	f832                	sd	a2,48(sp)
  800142:	fc36                	sd	a3,56(sp)
  800144:	e0ba                	sd	a4,64(sp)
  800146:	86aa                	mv	a3,a0
  800148:	0050                	addi	a2,sp,4
  80014a:	00000517          	auipc	a0,0x0
  80014e:	fae50513          	addi	a0,a0,-82 # 8000f8 <cputch>
  800152:	871a                	mv	a4,t1
  800154:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6001>
  800158:	ec06                	sd	ra,24(sp)
  80015a:	e4be                	sd	a5,72(sp)
  80015c:	e8c2                	sd	a6,80(sp)
  80015e:	ecc6                	sd	a7,88(sp)
  800160:	c202                	sw	zero,4(sp)
  800162:	e41a                	sd	t1,8(sp)
  800164:	14e000ef          	jal	8002b2 <vprintfmt>
  800168:	60e2                	ld	ra,24(sp)
  80016a:	4512                	lw	a0,4(sp)
  80016c:	6125                	addi	sp,sp,96
  80016e:	8082                	ret

0000000000800170 <initfd>:
  800170:	87ae                	mv	a5,a1
  800172:	1101                	addi	sp,sp,-32
  800174:	e822                	sd	s0,16(sp)
  800176:	85b2                	mv	a1,a2
  800178:	842a                	mv	s0,a0
  80017a:	853e                	mv	a0,a5
  80017c:	ec06                	sd	ra,24(sp)
  80017e:	f71ff0ef          	jal	8000ee <open>
  800182:	87aa                	mv	a5,a0
  800184:	00054463          	bltz	a0,80018c <initfd+0x1c>
  800188:	00851763          	bne	a0,s0,800196 <initfd+0x26>
  80018c:	60e2                	ld	ra,24(sp)
  80018e:	6442                	ld	s0,16(sp)
  800190:	853e                	mv	a0,a5
  800192:	6105                	addi	sp,sp,32
  800194:	8082                	ret
  800196:	e42a                	sd	a0,8(sp)
  800198:	8522                	mv	a0,s0
  80019a:	f5bff0ef          	jal	8000f4 <close>
  80019e:	6522                	ld	a0,8(sp)
  8001a0:	85a2                	mv	a1,s0
  8001a2:	f55ff0ef          	jal	8000f6 <dup2>
  8001a6:	842a                	mv	s0,a0
  8001a8:	6522                	ld	a0,8(sp)
  8001aa:	f4bff0ef          	jal	8000f4 <close>
  8001ae:	87a2                	mv	a5,s0
  8001b0:	bff1                	j	80018c <initfd+0x1c>

00000000008001b2 <umain>:
  8001b2:	1101                	addi	sp,sp,-32
  8001b4:	e822                	sd	s0,16(sp)
  8001b6:	e426                	sd	s1,8(sp)
  8001b8:	842a                	mv	s0,a0
  8001ba:	84ae                	mv	s1,a1
  8001bc:	4601                	li	a2,0
  8001be:	00000597          	auipc	a1,0x0
  8001c2:	52258593          	addi	a1,a1,1314 # 8006e0 <main+0x94>
  8001c6:	4501                	li	a0,0
  8001c8:	ec06                	sd	ra,24(sp)
  8001ca:	fa7ff0ef          	jal	800170 <initfd>
  8001ce:	02054263          	bltz	a0,8001f2 <umain+0x40>
  8001d2:	4605                	li	a2,1
  8001d4:	8532                	mv	a0,a2
  8001d6:	00000597          	auipc	a1,0x0
  8001da:	54a58593          	addi	a1,a1,1354 # 800720 <main+0xd4>
  8001de:	f93ff0ef          	jal	800170 <initfd>
  8001e2:	02054563          	bltz	a0,80020c <umain+0x5a>
  8001e6:	85a6                	mv	a1,s1
  8001e8:	8522                	mv	a0,s0
  8001ea:	462000ef          	jal	80064c <main>
  8001ee:	ee1ff0ef          	jal	8000ce <exit>
  8001f2:	86aa                	mv	a3,a0
  8001f4:	00000617          	auipc	a2,0x0
  8001f8:	4f460613          	addi	a2,a2,1268 # 8006e8 <main+0x9c>
  8001fc:	45e9                	li	a1,26
  8001fe:	00000517          	auipc	a0,0x0
  800202:	50a50513          	addi	a0,a0,1290 # 800708 <main+0xbc>
  800206:	e1bff0ef          	jal	800020 <__warn>
  80020a:	b7e1                	j	8001d2 <umain+0x20>
  80020c:	86aa                	mv	a3,a0
  80020e:	00000617          	auipc	a2,0x0
  800212:	51a60613          	addi	a2,a2,1306 # 800728 <main+0xdc>
  800216:	45f5                	li	a1,29
  800218:	00000517          	auipc	a0,0x0
  80021c:	4f050513          	addi	a0,a0,1264 # 800708 <main+0xbc>
  800220:	e01ff0ef          	jal	800020 <__warn>
  800224:	b7c9                	j	8001e6 <umain+0x34>

0000000000800226 <strnlen>:
  800226:	4781                	li	a5,0
  800228:	e589                	bnez	a1,800232 <strnlen+0xc>
  80022a:	a811                	j	80023e <strnlen+0x18>
  80022c:	0785                	addi	a5,a5,1
  80022e:	00f58863          	beq	a1,a5,80023e <strnlen+0x18>
  800232:	00f50733          	add	a4,a0,a5
  800236:	00074703          	lbu	a4,0(a4)
  80023a:	fb6d                	bnez	a4,80022c <strnlen+0x6>
  80023c:	85be                	mv	a1,a5
  80023e:	852e                	mv	a0,a1
  800240:	8082                	ret

0000000000800242 <printnum>:
  800242:	7139                	addi	sp,sp,-64
  800244:	02071893          	slli	a7,a4,0x20
  800248:	f822                	sd	s0,48(sp)
  80024a:	f426                	sd	s1,40(sp)
  80024c:	f04a                	sd	s2,32(sp)
  80024e:	ec4e                	sd	s3,24(sp)
  800250:	e456                	sd	s5,8(sp)
  800252:	0208d893          	srli	a7,a7,0x20
  800256:	fc06                	sd	ra,56(sp)
  800258:	0316fab3          	remu	s5,a3,a7
  80025c:	fff7841b          	addiw	s0,a5,-1
  800260:	84aa                	mv	s1,a0
  800262:	89ae                	mv	s3,a1
  800264:	8932                	mv	s2,a2
  800266:	0516f063          	bgeu	a3,a7,8002a6 <printnum+0x64>
  80026a:	e852                	sd	s4,16(sp)
  80026c:	4705                	li	a4,1
  80026e:	8a42                	mv	s4,a6
  800270:	00f75863          	bge	a4,a5,800280 <printnum+0x3e>
  800274:	864e                	mv	a2,s3
  800276:	85ca                	mv	a1,s2
  800278:	8552                	mv	a0,s4
  80027a:	347d                	addiw	s0,s0,-1
  80027c:	9482                	jalr	s1
  80027e:	f87d                	bnez	s0,800274 <printnum+0x32>
  800280:	6a42                	ld	s4,16(sp)
  800282:	00000797          	auipc	a5,0x0
  800286:	4c678793          	addi	a5,a5,1222 # 800748 <main+0xfc>
  80028a:	97d6                	add	a5,a5,s5
  80028c:	7442                	ld	s0,48(sp)
  80028e:	0007c503          	lbu	a0,0(a5)
  800292:	70e2                	ld	ra,56(sp)
  800294:	6aa2                	ld	s5,8(sp)
  800296:	864e                	mv	a2,s3
  800298:	85ca                	mv	a1,s2
  80029a:	69e2                	ld	s3,24(sp)
  80029c:	7902                	ld	s2,32(sp)
  80029e:	87a6                	mv	a5,s1
  8002a0:	74a2                	ld	s1,40(sp)
  8002a2:	6121                	addi	sp,sp,64
  8002a4:	8782                	jr	a5
  8002a6:	0316d6b3          	divu	a3,a3,a7
  8002aa:	87a2                	mv	a5,s0
  8002ac:	f97ff0ef          	jal	800242 <printnum>
  8002b0:	bfc9                	j	800282 <printnum+0x40>

00000000008002b2 <vprintfmt>:
  8002b2:	7119                	addi	sp,sp,-128
  8002b4:	f4a6                	sd	s1,104(sp)
  8002b6:	f0ca                	sd	s2,96(sp)
  8002b8:	ecce                	sd	s3,88(sp)
  8002ba:	e8d2                	sd	s4,80(sp)
  8002bc:	e4d6                	sd	s5,72(sp)
  8002be:	e0da                	sd	s6,64(sp)
  8002c0:	fc5e                	sd	s7,56(sp)
  8002c2:	f466                	sd	s9,40(sp)
  8002c4:	fc86                	sd	ra,120(sp)
  8002c6:	f8a2                	sd	s0,112(sp)
  8002c8:	f862                	sd	s8,48(sp)
  8002ca:	f06a                	sd	s10,32(sp)
  8002cc:	ec6e                	sd	s11,24(sp)
  8002ce:	84aa                	mv	s1,a0
  8002d0:	8cb6                	mv	s9,a3
  8002d2:	8aba                	mv	s5,a4
  8002d4:	89ae                	mv	s3,a1
  8002d6:	8932                	mv	s2,a2
  8002d8:	02500a13          	li	s4,37
  8002dc:	05500b93          	li	s7,85
  8002e0:	00000b17          	auipc	s6,0x0
  8002e4:	6a0b0b13          	addi	s6,s6,1696 # 800980 <main+0x334>
  8002e8:	000cc503          	lbu	a0,0(s9)
  8002ec:	001c8413          	addi	s0,s9,1
  8002f0:	01450b63          	beq	a0,s4,800306 <vprintfmt+0x54>
  8002f4:	cd15                	beqz	a0,800330 <vprintfmt+0x7e>
  8002f6:	864e                	mv	a2,s3
  8002f8:	85ca                	mv	a1,s2
  8002fa:	9482                	jalr	s1
  8002fc:	00044503          	lbu	a0,0(s0)
  800300:	0405                	addi	s0,s0,1
  800302:	ff4519e3          	bne	a0,s4,8002f4 <vprintfmt+0x42>
  800306:	5d7d                	li	s10,-1
  800308:	8dea                	mv	s11,s10
  80030a:	02000813          	li	a6,32
  80030e:	4c01                	li	s8,0
  800310:	4581                	li	a1,0
  800312:	00044703          	lbu	a4,0(s0)
  800316:	00140c93          	addi	s9,s0,1
  80031a:	fdd7061b          	addiw	a2,a4,-35
  80031e:	0ff67613          	zext.b	a2,a2
  800322:	02cbe663          	bltu	s7,a2,80034e <vprintfmt+0x9c>
  800326:	060a                	slli	a2,a2,0x2
  800328:	965a                	add	a2,a2,s6
  80032a:	421c                	lw	a5,0(a2)
  80032c:	97da                	add	a5,a5,s6
  80032e:	8782                	jr	a5
  800330:	70e6                	ld	ra,120(sp)
  800332:	7446                	ld	s0,112(sp)
  800334:	74a6                	ld	s1,104(sp)
  800336:	7906                	ld	s2,96(sp)
  800338:	69e6                	ld	s3,88(sp)
  80033a:	6a46                	ld	s4,80(sp)
  80033c:	6aa6                	ld	s5,72(sp)
  80033e:	6b06                	ld	s6,64(sp)
  800340:	7be2                	ld	s7,56(sp)
  800342:	7c42                	ld	s8,48(sp)
  800344:	7ca2                	ld	s9,40(sp)
  800346:	7d02                	ld	s10,32(sp)
  800348:	6de2                	ld	s11,24(sp)
  80034a:	6109                	addi	sp,sp,128
  80034c:	8082                	ret
  80034e:	864e                	mv	a2,s3
  800350:	85ca                	mv	a1,s2
  800352:	02500513          	li	a0,37
  800356:	9482                	jalr	s1
  800358:	fff44783          	lbu	a5,-1(s0)
  80035c:	02500713          	li	a4,37
  800360:	8ca2                	mv	s9,s0
  800362:	f8e783e3          	beq	a5,a4,8002e8 <vprintfmt+0x36>
  800366:	ffecc783          	lbu	a5,-2(s9)
  80036a:	1cfd                	addi	s9,s9,-1
  80036c:	fee79de3          	bne	a5,a4,800366 <vprintfmt+0xb4>
  800370:	bfa5                	j	8002e8 <vprintfmt+0x36>
  800372:	00144683          	lbu	a3,1(s0)
  800376:	4525                	li	a0,9
  800378:	fd070d1b          	addiw	s10,a4,-48
  80037c:	fd06879b          	addiw	a5,a3,-48
  800380:	28f56063          	bltu	a0,a5,800600 <vprintfmt+0x34e>
  800384:	2681                	sext.w	a3,a3
  800386:	8466                	mv	s0,s9
  800388:	002d179b          	slliw	a5,s10,0x2
  80038c:	00144703          	lbu	a4,1(s0)
  800390:	01a787bb          	addw	a5,a5,s10
  800394:	0017979b          	slliw	a5,a5,0x1
  800398:	9fb5                	addw	a5,a5,a3
  80039a:	fd07061b          	addiw	a2,a4,-48
  80039e:	0405                	addi	s0,s0,1
  8003a0:	fd078d1b          	addiw	s10,a5,-48
  8003a4:	0007069b          	sext.w	a3,a4
  8003a8:	fec570e3          	bgeu	a0,a2,800388 <vprintfmt+0xd6>
  8003ac:	f60dd3e3          	bgez	s11,800312 <vprintfmt+0x60>
  8003b0:	8dea                	mv	s11,s10
  8003b2:	5d7d                	li	s10,-1
  8003b4:	bfb9                	j	800312 <vprintfmt+0x60>
  8003b6:	883a                	mv	a6,a4
  8003b8:	8466                	mv	s0,s9
  8003ba:	bfa1                	j	800312 <vprintfmt+0x60>
  8003bc:	8466                	mv	s0,s9
  8003be:	4c05                	li	s8,1
  8003c0:	bf89                	j	800312 <vprintfmt+0x60>
  8003c2:	4785                	li	a5,1
  8003c4:	008a8613          	addi	a2,s5,8
  8003c8:	00b7c463          	blt	a5,a1,8003d0 <vprintfmt+0x11e>
  8003cc:	1c058363          	beqz	a1,800592 <vprintfmt+0x2e0>
  8003d0:	000ab683          	ld	a3,0(s5)
  8003d4:	4741                	li	a4,16
  8003d6:	8ab2                	mv	s5,a2
  8003d8:	2801                	sext.w	a6,a6
  8003da:	87ee                	mv	a5,s11
  8003dc:	864a                	mv	a2,s2
  8003de:	85ce                	mv	a1,s3
  8003e0:	8526                	mv	a0,s1
  8003e2:	e61ff0ef          	jal	800242 <printnum>
  8003e6:	b709                	j	8002e8 <vprintfmt+0x36>
  8003e8:	000aa503          	lw	a0,0(s5)
  8003ec:	864e                	mv	a2,s3
  8003ee:	85ca                	mv	a1,s2
  8003f0:	9482                	jalr	s1
  8003f2:	0aa1                	addi	s5,s5,8
  8003f4:	bdd5                	j	8002e8 <vprintfmt+0x36>
  8003f6:	4785                	li	a5,1
  8003f8:	008a8613          	addi	a2,s5,8
  8003fc:	00b7c463          	blt	a5,a1,800404 <vprintfmt+0x152>
  800400:	18058463          	beqz	a1,800588 <vprintfmt+0x2d6>
  800404:	000ab683          	ld	a3,0(s5)
  800408:	4729                	li	a4,10
  80040a:	8ab2                	mv	s5,a2
  80040c:	b7f1                	j	8003d8 <vprintfmt+0x126>
  80040e:	864e                	mv	a2,s3
  800410:	85ca                	mv	a1,s2
  800412:	03000513          	li	a0,48
  800416:	e042                	sd	a6,0(sp)
  800418:	9482                	jalr	s1
  80041a:	864e                	mv	a2,s3
  80041c:	85ca                	mv	a1,s2
  80041e:	07800513          	li	a0,120
  800422:	9482                	jalr	s1
  800424:	000ab683          	ld	a3,0(s5)
  800428:	6802                	ld	a6,0(sp)
  80042a:	4741                	li	a4,16
  80042c:	0aa1                	addi	s5,s5,8
  80042e:	b76d                	j	8003d8 <vprintfmt+0x126>
  800430:	864e                	mv	a2,s3
  800432:	85ca                	mv	a1,s2
  800434:	02500513          	li	a0,37
  800438:	9482                	jalr	s1
  80043a:	b57d                	j	8002e8 <vprintfmt+0x36>
  80043c:	000aad03          	lw	s10,0(s5)
  800440:	8466                	mv	s0,s9
  800442:	0aa1                	addi	s5,s5,8
  800444:	b7a5                	j	8003ac <vprintfmt+0xfa>
  800446:	4785                	li	a5,1
  800448:	008a8613          	addi	a2,s5,8
  80044c:	00b7c463          	blt	a5,a1,800454 <vprintfmt+0x1a2>
  800450:	12058763          	beqz	a1,80057e <vprintfmt+0x2cc>
  800454:	000ab683          	ld	a3,0(s5)
  800458:	4721                	li	a4,8
  80045a:	8ab2                	mv	s5,a2
  80045c:	bfb5                	j	8003d8 <vprintfmt+0x126>
  80045e:	87ee                	mv	a5,s11
  800460:	000dd363          	bgez	s11,800466 <vprintfmt+0x1b4>
  800464:	4781                	li	a5,0
  800466:	00078d9b          	sext.w	s11,a5
  80046a:	8466                	mv	s0,s9
  80046c:	b55d                	j	800312 <vprintfmt+0x60>
  80046e:	0008041b          	sext.w	s0,a6
  800472:	fd340793          	addi	a5,s0,-45
  800476:	01b02733          	sgtz	a4,s11
  80047a:	00f037b3          	snez	a5,a5
  80047e:	8ff9                	and	a5,a5,a4
  800480:	000ab703          	ld	a4,0(s5)
  800484:	008a8693          	addi	a3,s5,8
  800488:	e436                	sd	a3,8(sp)
  80048a:	12070563          	beqz	a4,8005b4 <vprintfmt+0x302>
  80048e:	12079d63          	bnez	a5,8005c8 <vprintfmt+0x316>
  800492:	00074783          	lbu	a5,0(a4)
  800496:	0007851b          	sext.w	a0,a5
  80049a:	c78d                	beqz	a5,8004c4 <vprintfmt+0x212>
  80049c:	00170a93          	addi	s5,a4,1
  8004a0:	547d                	li	s0,-1
  8004a2:	000d4563          	bltz	s10,8004ac <vprintfmt+0x1fa>
  8004a6:	3d7d                	addiw	s10,s10,-1
  8004a8:	008d0e63          	beq	s10,s0,8004c4 <vprintfmt+0x212>
  8004ac:	020c1863          	bnez	s8,8004dc <vprintfmt+0x22a>
  8004b0:	864e                	mv	a2,s3
  8004b2:	85ca                	mv	a1,s2
  8004b4:	9482                	jalr	s1
  8004b6:	000ac783          	lbu	a5,0(s5)
  8004ba:	0a85                	addi	s5,s5,1
  8004bc:	3dfd                	addiw	s11,s11,-1
  8004be:	0007851b          	sext.w	a0,a5
  8004c2:	f3e5                	bnez	a5,8004a2 <vprintfmt+0x1f0>
  8004c4:	01b05a63          	blez	s11,8004d8 <vprintfmt+0x226>
  8004c8:	864e                	mv	a2,s3
  8004ca:	85ca                	mv	a1,s2
  8004cc:	02000513          	li	a0,32
  8004d0:	3dfd                	addiw	s11,s11,-1
  8004d2:	9482                	jalr	s1
  8004d4:	fe0d9ae3          	bnez	s11,8004c8 <vprintfmt+0x216>
  8004d8:	6aa2                	ld	s5,8(sp)
  8004da:	b539                	j	8002e8 <vprintfmt+0x36>
  8004dc:	3781                	addiw	a5,a5,-32
  8004de:	05e00713          	li	a4,94
  8004e2:	fcf777e3          	bgeu	a4,a5,8004b0 <vprintfmt+0x1fe>
  8004e6:	03f00513          	li	a0,63
  8004ea:	864e                	mv	a2,s3
  8004ec:	85ca                	mv	a1,s2
  8004ee:	9482                	jalr	s1
  8004f0:	000ac783          	lbu	a5,0(s5)
  8004f4:	0a85                	addi	s5,s5,1
  8004f6:	3dfd                	addiw	s11,s11,-1
  8004f8:	0007851b          	sext.w	a0,a5
  8004fc:	d7e1                	beqz	a5,8004c4 <vprintfmt+0x212>
  8004fe:	fa0d54e3          	bgez	s10,8004a6 <vprintfmt+0x1f4>
  800502:	bfe9                	j	8004dc <vprintfmt+0x22a>
  800504:	000aa783          	lw	a5,0(s5)
  800508:	46e1                	li	a3,24
  80050a:	0aa1                	addi	s5,s5,8
  80050c:	41f7d71b          	sraiw	a4,a5,0x1f
  800510:	8fb9                	xor	a5,a5,a4
  800512:	40e7873b          	subw	a4,a5,a4
  800516:	02e6c663          	blt	a3,a4,800542 <vprintfmt+0x290>
  80051a:	00000797          	auipc	a5,0x0
  80051e:	5be78793          	addi	a5,a5,1470 # 800ad8 <error_string>
  800522:	00371693          	slli	a3,a4,0x3
  800526:	97b6                	add	a5,a5,a3
  800528:	639c                	ld	a5,0(a5)
  80052a:	cf81                	beqz	a5,800542 <vprintfmt+0x290>
  80052c:	873e                	mv	a4,a5
  80052e:	00000697          	auipc	a3,0x0
  800532:	24a68693          	addi	a3,a3,586 # 800778 <main+0x12c>
  800536:	864a                	mv	a2,s2
  800538:	85ce                	mv	a1,s3
  80053a:	8526                	mv	a0,s1
  80053c:	0f2000ef          	jal	80062e <printfmt>
  800540:	b365                	j	8002e8 <vprintfmt+0x36>
  800542:	00000697          	auipc	a3,0x0
  800546:	22668693          	addi	a3,a3,550 # 800768 <main+0x11c>
  80054a:	864a                	mv	a2,s2
  80054c:	85ce                	mv	a1,s3
  80054e:	8526                	mv	a0,s1
  800550:	0de000ef          	jal	80062e <printfmt>
  800554:	bb51                	j	8002e8 <vprintfmt+0x36>
  800556:	4785                	li	a5,1
  800558:	008a8c13          	addi	s8,s5,8
  80055c:	00b7c363          	blt	a5,a1,800562 <vprintfmt+0x2b0>
  800560:	cd81                	beqz	a1,800578 <vprintfmt+0x2c6>
  800562:	000ab403          	ld	s0,0(s5)
  800566:	02044b63          	bltz	s0,80059c <vprintfmt+0x2ea>
  80056a:	86a2                	mv	a3,s0
  80056c:	8ae2                	mv	s5,s8
  80056e:	4729                	li	a4,10
  800570:	b5a5                	j	8003d8 <vprintfmt+0x126>
  800572:	2585                	addiw	a1,a1,1
  800574:	8466                	mv	s0,s9
  800576:	bb71                	j	800312 <vprintfmt+0x60>
  800578:	000aa403          	lw	s0,0(s5)
  80057c:	b7ed                	j	800566 <vprintfmt+0x2b4>
  80057e:	000ae683          	lwu	a3,0(s5)
  800582:	4721                	li	a4,8
  800584:	8ab2                	mv	s5,a2
  800586:	bd89                	j	8003d8 <vprintfmt+0x126>
  800588:	000ae683          	lwu	a3,0(s5)
  80058c:	4729                	li	a4,10
  80058e:	8ab2                	mv	s5,a2
  800590:	b5a1                	j	8003d8 <vprintfmt+0x126>
  800592:	000ae683          	lwu	a3,0(s5)
  800596:	4741                	li	a4,16
  800598:	8ab2                	mv	s5,a2
  80059a:	bd3d                	j	8003d8 <vprintfmt+0x126>
  80059c:	864e                	mv	a2,s3
  80059e:	85ca                	mv	a1,s2
  8005a0:	02d00513          	li	a0,45
  8005a4:	e042                	sd	a6,0(sp)
  8005a6:	9482                	jalr	s1
  8005a8:	6802                	ld	a6,0(sp)
  8005aa:	408006b3          	neg	a3,s0
  8005ae:	8ae2                	mv	s5,s8
  8005b0:	4729                	li	a4,10
  8005b2:	b51d                	j	8003d8 <vprintfmt+0x126>
  8005b4:	eba1                	bnez	a5,800604 <vprintfmt+0x352>
  8005b6:	02800793          	li	a5,40
  8005ba:	853e                	mv	a0,a5
  8005bc:	00000a97          	auipc	s5,0x0
  8005c0:	1a5a8a93          	addi	s5,s5,421 # 800761 <main+0x115>
  8005c4:	547d                	li	s0,-1
  8005c6:	bdf1                	j	8004a2 <vprintfmt+0x1f0>
  8005c8:	853a                	mv	a0,a4
  8005ca:	85ea                	mv	a1,s10
  8005cc:	e03a                	sd	a4,0(sp)
  8005ce:	c59ff0ef          	jal	800226 <strnlen>
  8005d2:	40ad8dbb          	subw	s11,s11,a0
  8005d6:	6702                	ld	a4,0(sp)
  8005d8:	01b05b63          	blez	s11,8005ee <vprintfmt+0x33c>
  8005dc:	864e                	mv	a2,s3
  8005de:	85ca                	mv	a1,s2
  8005e0:	8522                	mv	a0,s0
  8005e2:	e03a                	sd	a4,0(sp)
  8005e4:	3dfd                	addiw	s11,s11,-1
  8005e6:	9482                	jalr	s1
  8005e8:	6702                	ld	a4,0(sp)
  8005ea:	fe0d99e3          	bnez	s11,8005dc <vprintfmt+0x32a>
  8005ee:	00074783          	lbu	a5,0(a4)
  8005f2:	0007851b          	sext.w	a0,a5
  8005f6:	ee0781e3          	beqz	a5,8004d8 <vprintfmt+0x226>
  8005fa:	00170a93          	addi	s5,a4,1
  8005fe:	b54d                	j	8004a0 <vprintfmt+0x1ee>
  800600:	8466                	mv	s0,s9
  800602:	b36d                	j	8003ac <vprintfmt+0xfa>
  800604:	85ea                	mv	a1,s10
  800606:	00000517          	auipc	a0,0x0
  80060a:	15a50513          	addi	a0,a0,346 # 800760 <main+0x114>
  80060e:	c19ff0ef          	jal	800226 <strnlen>
  800612:	40ad8dbb          	subw	s11,s11,a0
  800616:	02800793          	li	a5,40
  80061a:	00000717          	auipc	a4,0x0
  80061e:	14670713          	addi	a4,a4,326 # 800760 <main+0x114>
  800622:	853e                	mv	a0,a5
  800624:	fbb04ce3          	bgtz	s11,8005dc <vprintfmt+0x32a>
  800628:	00170a93          	addi	s5,a4,1
  80062c:	bd95                	j	8004a0 <vprintfmt+0x1ee>

000000000080062e <printfmt>:
  80062e:	7139                	addi	sp,sp,-64
  800630:	02010313          	addi	t1,sp,32
  800634:	f03a                	sd	a4,32(sp)
  800636:	871a                	mv	a4,t1
  800638:	ec06                	sd	ra,24(sp)
  80063a:	f43e                	sd	a5,40(sp)
  80063c:	f842                	sd	a6,48(sp)
  80063e:	fc46                	sd	a7,56(sp)
  800640:	e41a                	sd	t1,8(sp)
  800642:	c71ff0ef          	jal	8002b2 <vprintfmt>
  800646:	60e2                	ld	ra,24(sp)
  800648:	6121                	addi	sp,sp,64
  80064a:	8082                	ret

000000000080064c <main>:
  80064c:	1141                	addi	sp,sp,-16
  80064e:	e406                	sd	ra,8(sp)
  800650:	a95ff0ef          	jal	8000e4 <getpid>
  800654:	85aa                	mv	a1,a0
  800656:	00000517          	auipc	a0,0x0
  80065a:	30250513          	addi	a0,a0,770 # 800958 <main+0x30c>
  80065e:	ad9ff0ef          	jal	800136 <cprintf>
  800662:	a85ff0ef          	jal	8000e6 <print_pgdir>
  800666:	00000517          	auipc	a0,0x0
  80066a:	30a50513          	addi	a0,a0,778 # 800970 <main+0x324>
  80066e:	ac9ff0ef          	jal	800136 <cprintf>
  800672:	60a2                	ld	ra,8(sp)
  800674:	4501                	li	a0,0
  800676:	0141                	addi	sp,sp,16
  800678:	8082                	ret
