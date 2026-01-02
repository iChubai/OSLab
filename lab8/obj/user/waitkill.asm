
obj/__user_waitkill.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	7da50513          	addi	a0,a0,2010 # 800808 <main+0xc0>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	166000ef          	jal	8001aa <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	138000ef          	jal	800184 <vcprintf>
  800050:	00001517          	auipc	a0,0x1
  800054:	a9050513          	addi	a0,a0,-1392 # 800ae0 <main+0x398>
  800058:	152000ef          	jal	8001aa <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0c4000ef          	jal	800122 <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00000517          	auipc	a0,0x0
  800074:	7b850513          	addi	a0,a0,1976 # 800828 <main+0xe0>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	124000ef          	jal	8001aa <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0f6000ef          	jal	800184 <vcprintf>
  800092:	00001517          	auipc	a0,0x1
  800096:	a4e50513          	addi	a0,a0,-1458 # 800ae0 <main+0x398>
  80009a:	110000ef          	jal	8001aa <cprintf>
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
  80012a:	00000517          	auipc	a0,0x0
  80012e:	71e50513          	addi	a0,a0,1822 # 800848 <main+0x100>
  800132:	078000ef          	jal	8001aa <cprintf>
  800136:	a001                	j	800136 <exit+0x14>

0000000000800138 <fork>:
  800138:	b77d                	j	8000e6 <sys_fork>

000000000080013a <waitpid>:
  80013a:	cd89                	beqz	a1,800154 <waitpid+0x1a>
  80013c:	7179                	addi	sp,sp,-48
  80013e:	e42e                	sd	a1,8(sp)
  800140:	082c                	addi	a1,sp,24
  800142:	f406                	sd	ra,40(sp)
  800144:	fa7ff0ef          	jal	8000ea <sys_wait>
  800148:	6762                	ld	a4,24(sp)
  80014a:	67a2                	ld	a5,8(sp)
  80014c:	70a2                	ld	ra,40(sp)
  80014e:	c398                	sw	a4,0(a5)
  800150:	6145                	addi	sp,sp,48
  800152:	8082                	ret
  800154:	bf59                	j	8000ea <sys_wait>

0000000000800156 <yield>:
  800156:	bf71                	j	8000f2 <sys_yield>

0000000000800158 <kill>:
  800158:	bf79                	j	8000f6 <sys_kill>

000000000080015a <getpid>:
  80015a:	b74d                	j	8000fc <sys_getpid>

000000000080015c <_start>:
  80015c:	0ca000ef          	jal	800226 <umain>
  800160:	a001                	j	800160 <_start+0x4>

0000000000800162 <open>:
  800162:	1582                	slli	a1,a1,0x20
  800164:	9181                	srli	a1,a1,0x20
  800166:	b745                	j	800106 <sys_open>

0000000000800168 <close>:
  800168:	b765                	j	800110 <sys_close>

000000000080016a <dup2>:
  80016a:	b77d                	j	800118 <sys_dup>

000000000080016c <cputch>:
  80016c:	1101                	addi	sp,sp,-32
  80016e:	ec06                	sd	ra,24(sp)
  800170:	e42e                	sd	a1,8(sp)
  800172:	f8fff0ef          	jal	800100 <sys_putc>
  800176:	65a2                	ld	a1,8(sp)
  800178:	60e2                	ld	ra,24(sp)
  80017a:	419c                	lw	a5,0(a1)
  80017c:	2785                	addiw	a5,a5,1
  80017e:	c19c                	sw	a5,0(a1)
  800180:	6105                	addi	sp,sp,32
  800182:	8082                	ret

0000000000800184 <vcprintf>:
  800184:	1101                	addi	sp,sp,-32
  800186:	872e                	mv	a4,a1
  800188:	75dd                	lui	a1,0xffff7
  80018a:	86aa                	mv	a3,a0
  80018c:	0070                	addi	a2,sp,12
  80018e:	00000517          	auipc	a0,0x0
  800192:	fde50513          	addi	a0,a0,-34 # 80016c <cputch>
  800196:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <parent+0xffffffffff7f5ad1>
  80019a:	ec06                	sd	ra,24(sp)
  80019c:	c602                	sw	zero,12(sp)
  80019e:	188000ef          	jal	800326 <vprintfmt>
  8001a2:	60e2                	ld	ra,24(sp)
  8001a4:	4532                	lw	a0,12(sp)
  8001a6:	6105                	addi	sp,sp,32
  8001a8:	8082                	ret

00000000008001aa <cprintf>:
  8001aa:	711d                	addi	sp,sp,-96
  8001ac:	02810313          	addi	t1,sp,40
  8001b0:	f42e                	sd	a1,40(sp)
  8001b2:	75dd                	lui	a1,0xffff7
  8001b4:	f832                	sd	a2,48(sp)
  8001b6:	fc36                	sd	a3,56(sp)
  8001b8:	e0ba                	sd	a4,64(sp)
  8001ba:	86aa                	mv	a3,a0
  8001bc:	0050                	addi	a2,sp,4
  8001be:	00000517          	auipc	a0,0x0
  8001c2:	fae50513          	addi	a0,a0,-82 # 80016c <cputch>
  8001c6:	871a                	mv	a4,t1
  8001c8:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <parent+0xffffffffff7f5ad1>
  8001cc:	ec06                	sd	ra,24(sp)
  8001ce:	e4be                	sd	a5,72(sp)
  8001d0:	e8c2                	sd	a6,80(sp)
  8001d2:	ecc6                	sd	a7,88(sp)
  8001d4:	c202                	sw	zero,4(sp)
  8001d6:	e41a                	sd	t1,8(sp)
  8001d8:	14e000ef          	jal	800326 <vprintfmt>
  8001dc:	60e2                	ld	ra,24(sp)
  8001de:	4512                	lw	a0,4(sp)
  8001e0:	6125                	addi	sp,sp,96
  8001e2:	8082                	ret

00000000008001e4 <initfd>:
  8001e4:	87ae                	mv	a5,a1
  8001e6:	1101                	addi	sp,sp,-32
  8001e8:	e822                	sd	s0,16(sp)
  8001ea:	85b2                	mv	a1,a2
  8001ec:	842a                	mv	s0,a0
  8001ee:	853e                	mv	a0,a5
  8001f0:	ec06                	sd	ra,24(sp)
  8001f2:	f71ff0ef          	jal	800162 <open>
  8001f6:	87aa                	mv	a5,a0
  8001f8:	00054463          	bltz	a0,800200 <initfd+0x1c>
  8001fc:	00851763          	bne	a0,s0,80020a <initfd+0x26>
  800200:	60e2                	ld	ra,24(sp)
  800202:	6442                	ld	s0,16(sp)
  800204:	853e                	mv	a0,a5
  800206:	6105                	addi	sp,sp,32
  800208:	8082                	ret
  80020a:	e42a                	sd	a0,8(sp)
  80020c:	8522                	mv	a0,s0
  80020e:	f5bff0ef          	jal	800168 <close>
  800212:	6522                	ld	a0,8(sp)
  800214:	85a2                	mv	a1,s0
  800216:	f55ff0ef          	jal	80016a <dup2>
  80021a:	842a                	mv	s0,a0
  80021c:	6522                	ld	a0,8(sp)
  80021e:	f4bff0ef          	jal	800168 <close>
  800222:	87a2                	mv	a5,s0
  800224:	bff1                	j	800200 <initfd+0x1c>

0000000000800226 <umain>:
  800226:	1101                	addi	sp,sp,-32
  800228:	e822                	sd	s0,16(sp)
  80022a:	e426                	sd	s1,8(sp)
  80022c:	842a                	mv	s0,a0
  80022e:	84ae                	mv	s1,a1
  800230:	4601                	li	a2,0
  800232:	00000597          	auipc	a1,0x0
  800236:	62e58593          	addi	a1,a1,1582 # 800860 <main+0x118>
  80023a:	4501                	li	a0,0
  80023c:	ec06                	sd	ra,24(sp)
  80023e:	fa7ff0ef          	jal	8001e4 <initfd>
  800242:	02054263          	bltz	a0,800266 <umain+0x40>
  800246:	4605                	li	a2,1
  800248:	8532                	mv	a0,a2
  80024a:	00000597          	auipc	a1,0x0
  80024e:	65658593          	addi	a1,a1,1622 # 8008a0 <main+0x158>
  800252:	f93ff0ef          	jal	8001e4 <initfd>
  800256:	02054563          	bltz	a0,800280 <umain+0x5a>
  80025a:	85a6                	mv	a1,s1
  80025c:	8522                	mv	a0,s0
  80025e:	4ea000ef          	jal	800748 <main>
  800262:	ec1ff0ef          	jal	800122 <exit>
  800266:	86aa                	mv	a3,a0
  800268:	00000617          	auipc	a2,0x0
  80026c:	60060613          	addi	a2,a2,1536 # 800868 <main+0x120>
  800270:	45e9                	li	a1,26
  800272:	00000517          	auipc	a0,0x0
  800276:	61650513          	addi	a0,a0,1558 # 800888 <main+0x140>
  80027a:	de9ff0ef          	jal	800062 <__warn>
  80027e:	b7e1                	j	800246 <umain+0x20>
  800280:	86aa                	mv	a3,a0
  800282:	00000617          	auipc	a2,0x0
  800286:	62660613          	addi	a2,a2,1574 # 8008a8 <main+0x160>
  80028a:	45f5                	li	a1,29
  80028c:	00000517          	auipc	a0,0x0
  800290:	5fc50513          	addi	a0,a0,1532 # 800888 <main+0x140>
  800294:	dcfff0ef          	jal	800062 <__warn>
  800298:	b7c9                	j	80025a <umain+0x34>

000000000080029a <strnlen>:
  80029a:	4781                	li	a5,0
  80029c:	e589                	bnez	a1,8002a6 <strnlen+0xc>
  80029e:	a811                	j	8002b2 <strnlen+0x18>
  8002a0:	0785                	addi	a5,a5,1
  8002a2:	00f58863          	beq	a1,a5,8002b2 <strnlen+0x18>
  8002a6:	00f50733          	add	a4,a0,a5
  8002aa:	00074703          	lbu	a4,0(a4)
  8002ae:	fb6d                	bnez	a4,8002a0 <strnlen+0x6>
  8002b0:	85be                	mv	a1,a5
  8002b2:	852e                	mv	a0,a1
  8002b4:	8082                	ret

00000000008002b6 <printnum>:
  8002b6:	7139                	addi	sp,sp,-64
  8002b8:	02071893          	slli	a7,a4,0x20
  8002bc:	f822                	sd	s0,48(sp)
  8002be:	f426                	sd	s1,40(sp)
  8002c0:	f04a                	sd	s2,32(sp)
  8002c2:	ec4e                	sd	s3,24(sp)
  8002c4:	e456                	sd	s5,8(sp)
  8002c6:	0208d893          	srli	a7,a7,0x20
  8002ca:	fc06                	sd	ra,56(sp)
  8002cc:	0316fab3          	remu	s5,a3,a7
  8002d0:	fff7841b          	addiw	s0,a5,-1
  8002d4:	84aa                	mv	s1,a0
  8002d6:	89ae                	mv	s3,a1
  8002d8:	8932                	mv	s2,a2
  8002da:	0516f063          	bgeu	a3,a7,80031a <printnum+0x64>
  8002de:	e852                	sd	s4,16(sp)
  8002e0:	4705                	li	a4,1
  8002e2:	8a42                	mv	s4,a6
  8002e4:	00f75863          	bge	a4,a5,8002f4 <printnum+0x3e>
  8002e8:	864e                	mv	a2,s3
  8002ea:	85ca                	mv	a1,s2
  8002ec:	8552                	mv	a0,s4
  8002ee:	347d                	addiw	s0,s0,-1
  8002f0:	9482                	jalr	s1
  8002f2:	f87d                	bnez	s0,8002e8 <printnum+0x32>
  8002f4:	6a42                	ld	s4,16(sp)
  8002f6:	00000797          	auipc	a5,0x0
  8002fa:	5d278793          	addi	a5,a5,1490 # 8008c8 <main+0x180>
  8002fe:	97d6                	add	a5,a5,s5
  800300:	7442                	ld	s0,48(sp)
  800302:	0007c503          	lbu	a0,0(a5)
  800306:	70e2                	ld	ra,56(sp)
  800308:	6aa2                	ld	s5,8(sp)
  80030a:	864e                	mv	a2,s3
  80030c:	85ca                	mv	a1,s2
  80030e:	69e2                	ld	s3,24(sp)
  800310:	7902                	ld	s2,32(sp)
  800312:	87a6                	mv	a5,s1
  800314:	74a2                	ld	s1,40(sp)
  800316:	6121                	addi	sp,sp,64
  800318:	8782                	jr	a5
  80031a:	0316d6b3          	divu	a3,a3,a7
  80031e:	87a2                	mv	a5,s0
  800320:	f97ff0ef          	jal	8002b6 <printnum>
  800324:	bfc9                	j	8002f6 <printnum+0x40>

0000000000800326 <vprintfmt>:
  800326:	7119                	addi	sp,sp,-128
  800328:	f4a6                	sd	s1,104(sp)
  80032a:	f0ca                	sd	s2,96(sp)
  80032c:	ecce                	sd	s3,88(sp)
  80032e:	e8d2                	sd	s4,80(sp)
  800330:	e4d6                	sd	s5,72(sp)
  800332:	e0da                	sd	s6,64(sp)
  800334:	fc5e                	sd	s7,56(sp)
  800336:	f466                	sd	s9,40(sp)
  800338:	fc86                	sd	ra,120(sp)
  80033a:	f8a2                	sd	s0,112(sp)
  80033c:	f862                	sd	s8,48(sp)
  80033e:	f06a                	sd	s10,32(sp)
  800340:	ec6e                	sd	s11,24(sp)
  800342:	84aa                	mv	s1,a0
  800344:	8cb6                	mv	s9,a3
  800346:	8aba                	mv	s5,a4
  800348:	89ae                	mv	s3,a1
  80034a:	8932                	mv	s2,a2
  80034c:	02500a13          	li	s4,37
  800350:	05500b93          	li	s7,85
  800354:	00001b17          	auipc	s6,0x1
  800358:	840b0b13          	addi	s6,s6,-1984 # 800b94 <main+0x44c>
  80035c:	000cc503          	lbu	a0,0(s9)
  800360:	001c8413          	addi	s0,s9,1
  800364:	01450b63          	beq	a0,s4,80037a <vprintfmt+0x54>
  800368:	cd15                	beqz	a0,8003a4 <vprintfmt+0x7e>
  80036a:	864e                	mv	a2,s3
  80036c:	85ca                	mv	a1,s2
  80036e:	9482                	jalr	s1
  800370:	00044503          	lbu	a0,0(s0)
  800374:	0405                	addi	s0,s0,1
  800376:	ff4519e3          	bne	a0,s4,800368 <vprintfmt+0x42>
  80037a:	5d7d                	li	s10,-1
  80037c:	8dea                	mv	s11,s10
  80037e:	02000813          	li	a6,32
  800382:	4c01                	li	s8,0
  800384:	4581                	li	a1,0
  800386:	00044703          	lbu	a4,0(s0)
  80038a:	00140c93          	addi	s9,s0,1
  80038e:	fdd7061b          	addiw	a2,a4,-35
  800392:	0ff67613          	zext.b	a2,a2
  800396:	02cbe663          	bltu	s7,a2,8003c2 <vprintfmt+0x9c>
  80039a:	060a                	slli	a2,a2,0x2
  80039c:	965a                	add	a2,a2,s6
  80039e:	421c                	lw	a5,0(a2)
  8003a0:	97da                	add	a5,a5,s6
  8003a2:	8782                	jr	a5
  8003a4:	70e6                	ld	ra,120(sp)
  8003a6:	7446                	ld	s0,112(sp)
  8003a8:	74a6                	ld	s1,104(sp)
  8003aa:	7906                	ld	s2,96(sp)
  8003ac:	69e6                	ld	s3,88(sp)
  8003ae:	6a46                	ld	s4,80(sp)
  8003b0:	6aa6                	ld	s5,72(sp)
  8003b2:	6b06                	ld	s6,64(sp)
  8003b4:	7be2                	ld	s7,56(sp)
  8003b6:	7c42                	ld	s8,48(sp)
  8003b8:	7ca2                	ld	s9,40(sp)
  8003ba:	7d02                	ld	s10,32(sp)
  8003bc:	6de2                	ld	s11,24(sp)
  8003be:	6109                	addi	sp,sp,128
  8003c0:	8082                	ret
  8003c2:	864e                	mv	a2,s3
  8003c4:	85ca                	mv	a1,s2
  8003c6:	02500513          	li	a0,37
  8003ca:	9482                	jalr	s1
  8003cc:	fff44783          	lbu	a5,-1(s0)
  8003d0:	02500713          	li	a4,37
  8003d4:	8ca2                	mv	s9,s0
  8003d6:	f8e783e3          	beq	a5,a4,80035c <vprintfmt+0x36>
  8003da:	ffecc783          	lbu	a5,-2(s9)
  8003de:	1cfd                	addi	s9,s9,-1
  8003e0:	fee79de3          	bne	a5,a4,8003da <vprintfmt+0xb4>
  8003e4:	bfa5                	j	80035c <vprintfmt+0x36>
  8003e6:	00144683          	lbu	a3,1(s0)
  8003ea:	4525                	li	a0,9
  8003ec:	fd070d1b          	addiw	s10,a4,-48
  8003f0:	fd06879b          	addiw	a5,a3,-48
  8003f4:	28f56063          	bltu	a0,a5,800674 <vprintfmt+0x34e>
  8003f8:	2681                	sext.w	a3,a3
  8003fa:	8466                	mv	s0,s9
  8003fc:	002d179b          	slliw	a5,s10,0x2
  800400:	00144703          	lbu	a4,1(s0)
  800404:	01a787bb          	addw	a5,a5,s10
  800408:	0017979b          	slliw	a5,a5,0x1
  80040c:	9fb5                	addw	a5,a5,a3
  80040e:	fd07061b          	addiw	a2,a4,-48
  800412:	0405                	addi	s0,s0,1
  800414:	fd078d1b          	addiw	s10,a5,-48
  800418:	0007069b          	sext.w	a3,a4
  80041c:	fec570e3          	bgeu	a0,a2,8003fc <vprintfmt+0xd6>
  800420:	f60dd3e3          	bgez	s11,800386 <vprintfmt+0x60>
  800424:	8dea                	mv	s11,s10
  800426:	5d7d                	li	s10,-1
  800428:	bfb9                	j	800386 <vprintfmt+0x60>
  80042a:	883a                	mv	a6,a4
  80042c:	8466                	mv	s0,s9
  80042e:	bfa1                	j	800386 <vprintfmt+0x60>
  800430:	8466                	mv	s0,s9
  800432:	4c05                	li	s8,1
  800434:	bf89                	j	800386 <vprintfmt+0x60>
  800436:	4785                	li	a5,1
  800438:	008a8613          	addi	a2,s5,8
  80043c:	00b7c463          	blt	a5,a1,800444 <vprintfmt+0x11e>
  800440:	1c058363          	beqz	a1,800606 <vprintfmt+0x2e0>
  800444:	000ab683          	ld	a3,0(s5)
  800448:	4741                	li	a4,16
  80044a:	8ab2                	mv	s5,a2
  80044c:	2801                	sext.w	a6,a6
  80044e:	87ee                	mv	a5,s11
  800450:	864a                	mv	a2,s2
  800452:	85ce                	mv	a1,s3
  800454:	8526                	mv	a0,s1
  800456:	e61ff0ef          	jal	8002b6 <printnum>
  80045a:	b709                	j	80035c <vprintfmt+0x36>
  80045c:	000aa503          	lw	a0,0(s5)
  800460:	864e                	mv	a2,s3
  800462:	85ca                	mv	a1,s2
  800464:	9482                	jalr	s1
  800466:	0aa1                	addi	s5,s5,8
  800468:	bdd5                	j	80035c <vprintfmt+0x36>
  80046a:	4785                	li	a5,1
  80046c:	008a8613          	addi	a2,s5,8
  800470:	00b7c463          	blt	a5,a1,800478 <vprintfmt+0x152>
  800474:	18058463          	beqz	a1,8005fc <vprintfmt+0x2d6>
  800478:	000ab683          	ld	a3,0(s5)
  80047c:	4729                	li	a4,10
  80047e:	8ab2                	mv	s5,a2
  800480:	b7f1                	j	80044c <vprintfmt+0x126>
  800482:	864e                	mv	a2,s3
  800484:	85ca                	mv	a1,s2
  800486:	03000513          	li	a0,48
  80048a:	e042                	sd	a6,0(sp)
  80048c:	9482                	jalr	s1
  80048e:	864e                	mv	a2,s3
  800490:	85ca                	mv	a1,s2
  800492:	07800513          	li	a0,120
  800496:	9482                	jalr	s1
  800498:	000ab683          	ld	a3,0(s5)
  80049c:	6802                	ld	a6,0(sp)
  80049e:	4741                	li	a4,16
  8004a0:	0aa1                	addi	s5,s5,8
  8004a2:	b76d                	j	80044c <vprintfmt+0x126>
  8004a4:	864e                	mv	a2,s3
  8004a6:	85ca                	mv	a1,s2
  8004a8:	02500513          	li	a0,37
  8004ac:	9482                	jalr	s1
  8004ae:	b57d                	j	80035c <vprintfmt+0x36>
  8004b0:	000aad03          	lw	s10,0(s5)
  8004b4:	8466                	mv	s0,s9
  8004b6:	0aa1                	addi	s5,s5,8
  8004b8:	b7a5                	j	800420 <vprintfmt+0xfa>
  8004ba:	4785                	li	a5,1
  8004bc:	008a8613          	addi	a2,s5,8
  8004c0:	00b7c463          	blt	a5,a1,8004c8 <vprintfmt+0x1a2>
  8004c4:	12058763          	beqz	a1,8005f2 <vprintfmt+0x2cc>
  8004c8:	000ab683          	ld	a3,0(s5)
  8004cc:	4721                	li	a4,8
  8004ce:	8ab2                	mv	s5,a2
  8004d0:	bfb5                	j	80044c <vprintfmt+0x126>
  8004d2:	87ee                	mv	a5,s11
  8004d4:	000dd363          	bgez	s11,8004da <vprintfmt+0x1b4>
  8004d8:	4781                	li	a5,0
  8004da:	00078d9b          	sext.w	s11,a5
  8004de:	8466                	mv	s0,s9
  8004e0:	b55d                	j	800386 <vprintfmt+0x60>
  8004e2:	0008041b          	sext.w	s0,a6
  8004e6:	fd340793          	addi	a5,s0,-45
  8004ea:	01b02733          	sgtz	a4,s11
  8004ee:	00f037b3          	snez	a5,a5
  8004f2:	8ff9                	and	a5,a5,a4
  8004f4:	000ab703          	ld	a4,0(s5)
  8004f8:	008a8693          	addi	a3,s5,8
  8004fc:	e436                	sd	a3,8(sp)
  8004fe:	12070563          	beqz	a4,800628 <vprintfmt+0x302>
  800502:	12079d63          	bnez	a5,80063c <vprintfmt+0x316>
  800506:	00074783          	lbu	a5,0(a4)
  80050a:	0007851b          	sext.w	a0,a5
  80050e:	c78d                	beqz	a5,800538 <vprintfmt+0x212>
  800510:	00170a93          	addi	s5,a4,1
  800514:	547d                	li	s0,-1
  800516:	000d4563          	bltz	s10,800520 <vprintfmt+0x1fa>
  80051a:	3d7d                	addiw	s10,s10,-1
  80051c:	008d0e63          	beq	s10,s0,800538 <vprintfmt+0x212>
  800520:	020c1863          	bnez	s8,800550 <vprintfmt+0x22a>
  800524:	864e                	mv	a2,s3
  800526:	85ca                	mv	a1,s2
  800528:	9482                	jalr	s1
  80052a:	000ac783          	lbu	a5,0(s5)
  80052e:	0a85                	addi	s5,s5,1
  800530:	3dfd                	addiw	s11,s11,-1
  800532:	0007851b          	sext.w	a0,a5
  800536:	f3e5                	bnez	a5,800516 <vprintfmt+0x1f0>
  800538:	01b05a63          	blez	s11,80054c <vprintfmt+0x226>
  80053c:	864e                	mv	a2,s3
  80053e:	85ca                	mv	a1,s2
  800540:	02000513          	li	a0,32
  800544:	3dfd                	addiw	s11,s11,-1
  800546:	9482                	jalr	s1
  800548:	fe0d9ae3          	bnez	s11,80053c <vprintfmt+0x216>
  80054c:	6aa2                	ld	s5,8(sp)
  80054e:	b539                	j	80035c <vprintfmt+0x36>
  800550:	3781                	addiw	a5,a5,-32
  800552:	05e00713          	li	a4,94
  800556:	fcf777e3          	bgeu	a4,a5,800524 <vprintfmt+0x1fe>
  80055a:	03f00513          	li	a0,63
  80055e:	864e                	mv	a2,s3
  800560:	85ca                	mv	a1,s2
  800562:	9482                	jalr	s1
  800564:	000ac783          	lbu	a5,0(s5)
  800568:	0a85                	addi	s5,s5,1
  80056a:	3dfd                	addiw	s11,s11,-1
  80056c:	0007851b          	sext.w	a0,a5
  800570:	d7e1                	beqz	a5,800538 <vprintfmt+0x212>
  800572:	fa0d54e3          	bgez	s10,80051a <vprintfmt+0x1f4>
  800576:	bfe9                	j	800550 <vprintfmt+0x22a>
  800578:	000aa783          	lw	a5,0(s5)
  80057c:	46e1                	li	a3,24
  80057e:	0aa1                	addi	s5,s5,8
  800580:	41f7d71b          	sraiw	a4,a5,0x1f
  800584:	8fb9                	xor	a5,a5,a4
  800586:	40e7873b          	subw	a4,a5,a4
  80058a:	02e6c663          	blt	a3,a4,8005b6 <vprintfmt+0x290>
  80058e:	00000797          	auipc	a5,0x0
  800592:	76278793          	addi	a5,a5,1890 # 800cf0 <error_string>
  800596:	00371693          	slli	a3,a4,0x3
  80059a:	97b6                	add	a5,a5,a3
  80059c:	639c                	ld	a5,0(a5)
  80059e:	cf81                	beqz	a5,8005b6 <vprintfmt+0x290>
  8005a0:	873e                	mv	a4,a5
  8005a2:	00000697          	auipc	a3,0x0
  8005a6:	35668693          	addi	a3,a3,854 # 8008f8 <main+0x1b0>
  8005aa:	864a                	mv	a2,s2
  8005ac:	85ce                	mv	a1,s3
  8005ae:	8526                	mv	a0,s1
  8005b0:	0f2000ef          	jal	8006a2 <printfmt>
  8005b4:	b365                	j	80035c <vprintfmt+0x36>
  8005b6:	00000697          	auipc	a3,0x0
  8005ba:	33268693          	addi	a3,a3,818 # 8008e8 <main+0x1a0>
  8005be:	864a                	mv	a2,s2
  8005c0:	85ce                	mv	a1,s3
  8005c2:	8526                	mv	a0,s1
  8005c4:	0de000ef          	jal	8006a2 <printfmt>
  8005c8:	bb51                	j	80035c <vprintfmt+0x36>
  8005ca:	4785                	li	a5,1
  8005cc:	008a8c13          	addi	s8,s5,8
  8005d0:	00b7c363          	blt	a5,a1,8005d6 <vprintfmt+0x2b0>
  8005d4:	cd81                	beqz	a1,8005ec <vprintfmt+0x2c6>
  8005d6:	000ab403          	ld	s0,0(s5)
  8005da:	02044b63          	bltz	s0,800610 <vprintfmt+0x2ea>
  8005de:	86a2                	mv	a3,s0
  8005e0:	8ae2                	mv	s5,s8
  8005e2:	4729                	li	a4,10
  8005e4:	b5a5                	j	80044c <vprintfmt+0x126>
  8005e6:	2585                	addiw	a1,a1,1
  8005e8:	8466                	mv	s0,s9
  8005ea:	bb71                	j	800386 <vprintfmt+0x60>
  8005ec:	000aa403          	lw	s0,0(s5)
  8005f0:	b7ed                	j	8005da <vprintfmt+0x2b4>
  8005f2:	000ae683          	lwu	a3,0(s5)
  8005f6:	4721                	li	a4,8
  8005f8:	8ab2                	mv	s5,a2
  8005fa:	bd89                	j	80044c <vprintfmt+0x126>
  8005fc:	000ae683          	lwu	a3,0(s5)
  800600:	4729                	li	a4,10
  800602:	8ab2                	mv	s5,a2
  800604:	b5a1                	j	80044c <vprintfmt+0x126>
  800606:	000ae683          	lwu	a3,0(s5)
  80060a:	4741                	li	a4,16
  80060c:	8ab2                	mv	s5,a2
  80060e:	bd3d                	j	80044c <vprintfmt+0x126>
  800610:	864e                	mv	a2,s3
  800612:	85ca                	mv	a1,s2
  800614:	02d00513          	li	a0,45
  800618:	e042                	sd	a6,0(sp)
  80061a:	9482                	jalr	s1
  80061c:	6802                	ld	a6,0(sp)
  80061e:	408006b3          	neg	a3,s0
  800622:	8ae2                	mv	s5,s8
  800624:	4729                	li	a4,10
  800626:	b51d                	j	80044c <vprintfmt+0x126>
  800628:	eba1                	bnez	a5,800678 <vprintfmt+0x352>
  80062a:	02800793          	li	a5,40
  80062e:	853e                	mv	a0,a5
  800630:	00000a97          	auipc	s5,0x0
  800634:	2b1a8a93          	addi	s5,s5,689 # 8008e1 <main+0x199>
  800638:	547d                	li	s0,-1
  80063a:	bdf1                	j	800516 <vprintfmt+0x1f0>
  80063c:	853a                	mv	a0,a4
  80063e:	85ea                	mv	a1,s10
  800640:	e03a                	sd	a4,0(sp)
  800642:	c59ff0ef          	jal	80029a <strnlen>
  800646:	40ad8dbb          	subw	s11,s11,a0
  80064a:	6702                	ld	a4,0(sp)
  80064c:	01b05b63          	blez	s11,800662 <vprintfmt+0x33c>
  800650:	864e                	mv	a2,s3
  800652:	85ca                	mv	a1,s2
  800654:	8522                	mv	a0,s0
  800656:	e03a                	sd	a4,0(sp)
  800658:	3dfd                	addiw	s11,s11,-1
  80065a:	9482                	jalr	s1
  80065c:	6702                	ld	a4,0(sp)
  80065e:	fe0d99e3          	bnez	s11,800650 <vprintfmt+0x32a>
  800662:	00074783          	lbu	a5,0(a4)
  800666:	0007851b          	sext.w	a0,a5
  80066a:	ee0781e3          	beqz	a5,80054c <vprintfmt+0x226>
  80066e:	00170a93          	addi	s5,a4,1
  800672:	b54d                	j	800514 <vprintfmt+0x1ee>
  800674:	8466                	mv	s0,s9
  800676:	b36d                	j	800420 <vprintfmt+0xfa>
  800678:	85ea                	mv	a1,s10
  80067a:	00000517          	auipc	a0,0x0
  80067e:	26650513          	addi	a0,a0,614 # 8008e0 <main+0x198>
  800682:	c19ff0ef          	jal	80029a <strnlen>
  800686:	40ad8dbb          	subw	s11,s11,a0
  80068a:	02800793          	li	a5,40
  80068e:	00000717          	auipc	a4,0x0
  800692:	25270713          	addi	a4,a4,594 # 8008e0 <main+0x198>
  800696:	853e                	mv	a0,a5
  800698:	fbb04ce3          	bgtz	s11,800650 <vprintfmt+0x32a>
  80069c:	00170a93          	addi	s5,a4,1
  8006a0:	bd95                	j	800514 <vprintfmt+0x1ee>

00000000008006a2 <printfmt>:
  8006a2:	7139                	addi	sp,sp,-64
  8006a4:	02010313          	addi	t1,sp,32
  8006a8:	f03a                	sd	a4,32(sp)
  8006aa:	871a                	mv	a4,t1
  8006ac:	ec06                	sd	ra,24(sp)
  8006ae:	f43e                	sd	a5,40(sp)
  8006b0:	f842                	sd	a6,48(sp)
  8006b2:	fc46                	sd	a7,56(sp)
  8006b4:	e41a                	sd	t1,8(sp)
  8006b6:	c71ff0ef          	jal	800326 <vprintfmt>
  8006ba:	60e2                	ld	ra,24(sp)
  8006bc:	6121                	addi	sp,sp,64
  8006be:	8082                	ret

00000000008006c0 <do_yield>:
  8006c0:	1141                	addi	sp,sp,-16
  8006c2:	e406                	sd	ra,8(sp)
  8006c4:	a93ff0ef          	jal	800156 <yield>
  8006c8:	a8fff0ef          	jal	800156 <yield>
  8006cc:	a8bff0ef          	jal	800156 <yield>
  8006d0:	a87ff0ef          	jal	800156 <yield>
  8006d4:	a83ff0ef          	jal	800156 <yield>
  8006d8:	60a2                	ld	ra,8(sp)
  8006da:	0141                	addi	sp,sp,16
  8006dc:	bcad                	j	800156 <yield>

00000000008006de <loop>:
  8006de:	1141                	addi	sp,sp,-16
  8006e0:	00000517          	auipc	a0,0x0
  8006e4:	3f850513          	addi	a0,a0,1016 # 800ad8 <main+0x390>
  8006e8:	e406                	sd	ra,8(sp)
  8006ea:	ac1ff0ef          	jal	8001aa <cprintf>
  8006ee:	a001                	j	8006ee <loop+0x10>

00000000008006f0 <work>:
  8006f0:	1141                	addi	sp,sp,-16
  8006f2:	00000517          	auipc	a0,0x0
  8006f6:	3f650513          	addi	a0,a0,1014 # 800ae8 <main+0x3a0>
  8006fa:	e406                	sd	ra,8(sp)
  8006fc:	aafff0ef          	jal	8001aa <cprintf>
  800700:	fc1ff0ef          	jal	8006c0 <do_yield>
  800704:	00001517          	auipc	a0,0x1
  800708:	90452503          	lw	a0,-1788(a0) # 801008 <parent>
  80070c:	a4dff0ef          	jal	800158 <kill>
  800710:	e105                	bnez	a0,800730 <work+0x40>
  800712:	00000517          	auipc	a0,0x0
  800716:	3e650513          	addi	a0,a0,998 # 800af8 <main+0x3b0>
  80071a:	a91ff0ef          	jal	8001aa <cprintf>
  80071e:	fa3ff0ef          	jal	8006c0 <do_yield>
  800722:	00001517          	auipc	a0,0x1
  800726:	8e252503          	lw	a0,-1822(a0) # 801004 <pid1>
  80072a:	a2fff0ef          	jal	800158 <kill>
  80072e:	c501                	beqz	a0,800736 <work+0x46>
  800730:	557d                	li	a0,-1
  800732:	9f1ff0ef          	jal	800122 <exit>
  800736:	00000517          	auipc	a0,0x0
  80073a:	3da50513          	addi	a0,a0,986 # 800b10 <main+0x3c8>
  80073e:	a6dff0ef          	jal	8001aa <cprintf>
  800742:	4501                	li	a0,0
  800744:	9dfff0ef          	jal	800122 <exit>

0000000000800748 <main>:
  800748:	1141                	addi	sp,sp,-16
  80074a:	e406                	sd	ra,8(sp)
  80074c:	a0fff0ef          	jal	80015a <getpid>
  800750:	00001797          	auipc	a5,0x1
  800754:	8aa7ac23          	sw	a0,-1864(a5) # 801008 <parent>
  800758:	9e1ff0ef          	jal	800138 <fork>
  80075c:	00001797          	auipc	a5,0x1
  800760:	8aa7a423          	sw	a0,-1880(a5) # 801004 <pid1>
  800764:	c92d                	beqz	a0,8007d6 <main+0x8e>
  800766:	04a05863          	blez	a0,8007b6 <main+0x6e>
  80076a:	9cfff0ef          	jal	800138 <fork>
  80076e:	00001797          	auipc	a5,0x1
  800772:	88a7a923          	sw	a0,-1902(a5) # 801000 <pid2>
  800776:	c541                	beqz	a0,8007fe <main+0xb6>
  800778:	06a05163          	blez	a0,8007da <main+0x92>
  80077c:	00000517          	auipc	a0,0x0
  800780:	3e450513          	addi	a0,a0,996 # 800b60 <main+0x418>
  800784:	a27ff0ef          	jal	8001aa <cprintf>
  800788:	00001517          	auipc	a0,0x1
  80078c:	87c52503          	lw	a0,-1924(a0) # 801004 <pid1>
  800790:	4581                	li	a1,0
  800792:	9a9ff0ef          	jal	80013a <waitpid>
  800796:	00001697          	auipc	a3,0x1
  80079a:	86e6a683          	lw	a3,-1938(a3) # 801004 <pid1>
  80079e:	00000617          	auipc	a2,0x0
  8007a2:	3d260613          	addi	a2,a2,978 # 800b70 <main+0x428>
  8007a6:	03400593          	li	a1,52
  8007aa:	00000517          	auipc	a0,0x0
  8007ae:	3a650513          	addi	a0,a0,934 # 800b50 <main+0x408>
  8007b2:	86fff0ef          	jal	800020 <__panic>
  8007b6:	00000697          	auipc	a3,0x0
  8007ba:	37268693          	addi	a3,a3,882 # 800b28 <main+0x3e0>
  8007be:	00000617          	auipc	a2,0x0
  8007c2:	37a60613          	addi	a2,a2,890 # 800b38 <main+0x3f0>
  8007c6:	02c00593          	li	a1,44
  8007ca:	00000517          	auipc	a0,0x0
  8007ce:	38650513          	addi	a0,a0,902 # 800b50 <main+0x408>
  8007d2:	84fff0ef          	jal	800020 <__panic>
  8007d6:	f09ff0ef          	jal	8006de <loop>
  8007da:	00001517          	auipc	a0,0x1
  8007de:	82a52503          	lw	a0,-2006(a0) # 801004 <pid1>
  8007e2:	977ff0ef          	jal	800158 <kill>
  8007e6:	00000617          	auipc	a2,0x0
  8007ea:	3a260613          	addi	a2,a2,930 # 800b88 <main+0x440>
  8007ee:	03900593          	li	a1,57
  8007f2:	00000517          	auipc	a0,0x0
  8007f6:	35e50513          	addi	a0,a0,862 # 800b50 <main+0x408>
  8007fa:	827ff0ef          	jal	800020 <__panic>
  8007fe:	ef3ff0ef          	jal	8006f0 <work>
