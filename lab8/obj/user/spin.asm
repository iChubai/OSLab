
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	75a50513          	addi	a0,a0,1882 # 800788 <main+0xce>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	160000ef          	jal	8001a4 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	132000ef          	jal	80017e <vcprintf>
  800050:	00000517          	auipc	a0,0x0
  800054:	75850513          	addi	a0,a0,1880 # 8007a8 <main+0xee>
  800058:	14c000ef          	jal	8001a4 <cprintf>
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
  800074:	74050513          	addi	a0,a0,1856 # 8007b0 <main+0xf6>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	11e000ef          	jal	8001a4 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	0f0000ef          	jal	80017e <vcprintf>
  800092:	00000517          	auipc	a0,0x0
  800096:	71650513          	addi	a0,a0,1814 # 8007a8 <main+0xee>
  80009a:	10a000ef          	jal	8001a4 <cprintf>
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

00000000008000fc <sys_putc>:
  8000fc:	85aa                	mv	a1,a0
  8000fe:	4579                	li	a0,30
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
  80012a:	6aa50513          	addi	a0,a0,1706 # 8007d0 <main+0x116>
  80012e:	076000ef          	jal	8001a4 <cprintf>
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

0000000000800152 <yield>:
  800152:	b745                	j	8000f2 <sys_yield>

0000000000800154 <kill>:
  800154:	b74d                	j	8000f6 <sys_kill>

0000000000800156 <_start>:
  800156:	0ca000ef          	jal	800220 <umain>
  80015a:	a001                	j	80015a <_start+0x4>

000000000080015c <open>:
  80015c:	1582                	slli	a1,a1,0x20
  80015e:	9181                	srli	a1,a1,0x20
  800160:	b74d                	j	800102 <sys_open>

0000000000800162 <close>:
  800162:	b76d                	j	80010c <sys_close>

0000000000800164 <dup2>:
  800164:	bf45                	j	800114 <sys_dup>

0000000000800166 <cputch>:
  800166:	1101                	addi	sp,sp,-32
  800168:	ec06                	sd	ra,24(sp)
  80016a:	e42e                	sd	a1,8(sp)
  80016c:	f91ff0ef          	jal	8000fc <sys_putc>
  800170:	65a2                	ld	a1,8(sp)
  800172:	60e2                	ld	ra,24(sp)
  800174:	419c                	lw	a5,0(a1)
  800176:	2785                	addiw	a5,a5,1
  800178:	c19c                	sw	a5,0(a1)
  80017a:	6105                	addi	sp,sp,32
  80017c:	8082                	ret

000000000080017e <vcprintf>:
  80017e:	1101                	addi	sp,sp,-32
  800180:	872e                	mv	a4,a1
  800182:	75dd                	lui	a1,0xffff7
  800184:	86aa                	mv	a3,a0
  800186:	0070                	addi	a2,sp,12
  800188:	00000517          	auipc	a0,0x0
  80018c:	fde50513          	addi	a0,a0,-34 # 800166 <cputch>
  800190:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5de9>
  800194:	ec06                	sd	ra,24(sp)
  800196:	c602                	sw	zero,12(sp)
  800198:	188000ef          	jal	800320 <vprintfmt>
  80019c:	60e2                	ld	ra,24(sp)
  80019e:	4532                	lw	a0,12(sp)
  8001a0:	6105                	addi	sp,sp,32
  8001a2:	8082                	ret

00000000008001a4 <cprintf>:
  8001a4:	711d                	addi	sp,sp,-96
  8001a6:	02810313          	addi	t1,sp,40
  8001aa:	f42e                	sd	a1,40(sp)
  8001ac:	75dd                	lui	a1,0xffff7
  8001ae:	f832                	sd	a2,48(sp)
  8001b0:	fc36                	sd	a3,56(sp)
  8001b2:	e0ba                	sd	a4,64(sp)
  8001b4:	86aa                	mv	a3,a0
  8001b6:	0050                	addi	a2,sp,4
  8001b8:	00000517          	auipc	a0,0x0
  8001bc:	fae50513          	addi	a0,a0,-82 # 800166 <cputch>
  8001c0:	871a                	mv	a4,t1
  8001c2:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f5de9>
  8001c6:	ec06                	sd	ra,24(sp)
  8001c8:	e4be                	sd	a5,72(sp)
  8001ca:	e8c2                	sd	a6,80(sp)
  8001cc:	ecc6                	sd	a7,88(sp)
  8001ce:	c202                	sw	zero,4(sp)
  8001d0:	e41a                	sd	t1,8(sp)
  8001d2:	14e000ef          	jal	800320 <vprintfmt>
  8001d6:	60e2                	ld	ra,24(sp)
  8001d8:	4512                	lw	a0,4(sp)
  8001da:	6125                	addi	sp,sp,96
  8001dc:	8082                	ret

00000000008001de <initfd>:
  8001de:	87ae                	mv	a5,a1
  8001e0:	1101                	addi	sp,sp,-32
  8001e2:	e822                	sd	s0,16(sp)
  8001e4:	85b2                	mv	a1,a2
  8001e6:	842a                	mv	s0,a0
  8001e8:	853e                	mv	a0,a5
  8001ea:	ec06                	sd	ra,24(sp)
  8001ec:	f71ff0ef          	jal	80015c <open>
  8001f0:	87aa                	mv	a5,a0
  8001f2:	00054463          	bltz	a0,8001fa <initfd+0x1c>
  8001f6:	00851763          	bne	a0,s0,800204 <initfd+0x26>
  8001fa:	60e2                	ld	ra,24(sp)
  8001fc:	6442                	ld	s0,16(sp)
  8001fe:	853e                	mv	a0,a5
  800200:	6105                	addi	sp,sp,32
  800202:	8082                	ret
  800204:	e42a                	sd	a0,8(sp)
  800206:	8522                	mv	a0,s0
  800208:	f5bff0ef          	jal	800162 <close>
  80020c:	6522                	ld	a0,8(sp)
  80020e:	85a2                	mv	a1,s0
  800210:	f55ff0ef          	jal	800164 <dup2>
  800214:	842a                	mv	s0,a0
  800216:	6522                	ld	a0,8(sp)
  800218:	f4bff0ef          	jal	800162 <close>
  80021c:	87a2                	mv	a5,s0
  80021e:	bff1                	j	8001fa <initfd+0x1c>

0000000000800220 <umain>:
  800220:	1101                	addi	sp,sp,-32
  800222:	e822                	sd	s0,16(sp)
  800224:	e426                	sd	s1,8(sp)
  800226:	842a                	mv	s0,a0
  800228:	84ae                	mv	s1,a1
  80022a:	4601                	li	a2,0
  80022c:	00000597          	auipc	a1,0x0
  800230:	5bc58593          	addi	a1,a1,1468 # 8007e8 <main+0x12e>
  800234:	4501                	li	a0,0
  800236:	ec06                	sd	ra,24(sp)
  800238:	fa7ff0ef          	jal	8001de <initfd>
  80023c:	02054263          	bltz	a0,800260 <umain+0x40>
  800240:	4605                	li	a2,1
  800242:	8532                	mv	a0,a2
  800244:	00000597          	auipc	a1,0x0
  800248:	5e458593          	addi	a1,a1,1508 # 800828 <main+0x16e>
  80024c:	f93ff0ef          	jal	8001de <initfd>
  800250:	02054563          	bltz	a0,80027a <umain+0x5a>
  800254:	85a6                	mv	a1,s1
  800256:	8522                	mv	a0,s0
  800258:	462000ef          	jal	8006ba <main>
  80025c:	ec3ff0ef          	jal	80011e <exit>
  800260:	86aa                	mv	a3,a0
  800262:	00000617          	auipc	a2,0x0
  800266:	58e60613          	addi	a2,a2,1422 # 8007f0 <main+0x136>
  80026a:	45e9                	li	a1,26
  80026c:	00000517          	auipc	a0,0x0
  800270:	5a450513          	addi	a0,a0,1444 # 800810 <main+0x156>
  800274:	defff0ef          	jal	800062 <__warn>
  800278:	b7e1                	j	800240 <umain+0x20>
  80027a:	86aa                	mv	a3,a0
  80027c:	00000617          	auipc	a2,0x0
  800280:	5b460613          	addi	a2,a2,1460 # 800830 <main+0x176>
  800284:	45f5                	li	a1,29
  800286:	00000517          	auipc	a0,0x0
  80028a:	58a50513          	addi	a0,a0,1418 # 800810 <main+0x156>
  80028e:	dd5ff0ef          	jal	800062 <__warn>
  800292:	b7c9                	j	800254 <umain+0x34>

0000000000800294 <strnlen>:
  800294:	4781                	li	a5,0
  800296:	e589                	bnez	a1,8002a0 <strnlen+0xc>
  800298:	a811                	j	8002ac <strnlen+0x18>
  80029a:	0785                	addi	a5,a5,1
  80029c:	00f58863          	beq	a1,a5,8002ac <strnlen+0x18>
  8002a0:	00f50733          	add	a4,a0,a5
  8002a4:	00074703          	lbu	a4,0(a4)
  8002a8:	fb6d                	bnez	a4,80029a <strnlen+0x6>
  8002aa:	85be                	mv	a1,a5
  8002ac:	852e                	mv	a0,a1
  8002ae:	8082                	ret

00000000008002b0 <printnum>:
  8002b0:	7139                	addi	sp,sp,-64
  8002b2:	02071893          	slli	a7,a4,0x20
  8002b6:	f822                	sd	s0,48(sp)
  8002b8:	f426                	sd	s1,40(sp)
  8002ba:	f04a                	sd	s2,32(sp)
  8002bc:	ec4e                	sd	s3,24(sp)
  8002be:	e456                	sd	s5,8(sp)
  8002c0:	0208d893          	srli	a7,a7,0x20
  8002c4:	fc06                	sd	ra,56(sp)
  8002c6:	0316fab3          	remu	s5,a3,a7
  8002ca:	fff7841b          	addiw	s0,a5,-1
  8002ce:	84aa                	mv	s1,a0
  8002d0:	89ae                	mv	s3,a1
  8002d2:	8932                	mv	s2,a2
  8002d4:	0516f063          	bgeu	a3,a7,800314 <printnum+0x64>
  8002d8:	e852                	sd	s4,16(sp)
  8002da:	4705                	li	a4,1
  8002dc:	8a42                	mv	s4,a6
  8002de:	00f75863          	bge	a4,a5,8002ee <printnum+0x3e>
  8002e2:	864e                	mv	a2,s3
  8002e4:	85ca                	mv	a1,s2
  8002e6:	8552                	mv	a0,s4
  8002e8:	347d                	addiw	s0,s0,-1
  8002ea:	9482                	jalr	s1
  8002ec:	f87d                	bnez	s0,8002e2 <printnum+0x32>
  8002ee:	6a42                	ld	s4,16(sp)
  8002f0:	00000797          	auipc	a5,0x0
  8002f4:	56078793          	addi	a5,a5,1376 # 800850 <main+0x196>
  8002f8:	97d6                	add	a5,a5,s5
  8002fa:	7442                	ld	s0,48(sp)
  8002fc:	0007c503          	lbu	a0,0(a5)
  800300:	70e2                	ld	ra,56(sp)
  800302:	6aa2                	ld	s5,8(sp)
  800304:	864e                	mv	a2,s3
  800306:	85ca                	mv	a1,s2
  800308:	69e2                	ld	s3,24(sp)
  80030a:	7902                	ld	s2,32(sp)
  80030c:	87a6                	mv	a5,s1
  80030e:	74a2                	ld	s1,40(sp)
  800310:	6121                	addi	sp,sp,64
  800312:	8782                	jr	a5
  800314:	0316d6b3          	divu	a3,a3,a7
  800318:	87a2                	mv	a5,s0
  80031a:	f97ff0ef          	jal	8002b0 <printnum>
  80031e:	bfc9                	j	8002f0 <printnum+0x40>

0000000000800320 <vprintfmt>:
  800320:	7119                	addi	sp,sp,-128
  800322:	f4a6                	sd	s1,104(sp)
  800324:	f0ca                	sd	s2,96(sp)
  800326:	ecce                	sd	s3,88(sp)
  800328:	e8d2                	sd	s4,80(sp)
  80032a:	e4d6                	sd	s5,72(sp)
  80032c:	e0da                	sd	s6,64(sp)
  80032e:	fc5e                	sd	s7,56(sp)
  800330:	f466                	sd	s9,40(sp)
  800332:	fc86                	sd	ra,120(sp)
  800334:	f8a2                	sd	s0,112(sp)
  800336:	f862                	sd	s8,48(sp)
  800338:	f06a                	sd	s10,32(sp)
  80033a:	ec6e                	sd	s11,24(sp)
  80033c:	84aa                	mv	s1,a0
  80033e:	8cb6                	mv	s9,a3
  800340:	8aba                	mv	s5,a4
  800342:	89ae                	mv	s3,a1
  800344:	8932                	mv	s2,a2
  800346:	02500a13          	li	s4,37
  80034a:	05500b93          	li	s7,85
  80034e:	00001b17          	auipc	s6,0x1
  800352:	84ab0b13          	addi	s6,s6,-1974 # 800b98 <main+0x4de>
  800356:	000cc503          	lbu	a0,0(s9)
  80035a:	001c8413          	addi	s0,s9,1
  80035e:	01450b63          	beq	a0,s4,800374 <vprintfmt+0x54>
  800362:	cd15                	beqz	a0,80039e <vprintfmt+0x7e>
  800364:	864e                	mv	a2,s3
  800366:	85ca                	mv	a1,s2
  800368:	9482                	jalr	s1
  80036a:	00044503          	lbu	a0,0(s0)
  80036e:	0405                	addi	s0,s0,1
  800370:	ff4519e3          	bne	a0,s4,800362 <vprintfmt+0x42>
  800374:	5d7d                	li	s10,-1
  800376:	8dea                	mv	s11,s10
  800378:	02000813          	li	a6,32
  80037c:	4c01                	li	s8,0
  80037e:	4581                	li	a1,0
  800380:	00044703          	lbu	a4,0(s0)
  800384:	00140c93          	addi	s9,s0,1
  800388:	fdd7061b          	addiw	a2,a4,-35
  80038c:	0ff67613          	zext.b	a2,a2
  800390:	02cbe663          	bltu	s7,a2,8003bc <vprintfmt+0x9c>
  800394:	060a                	slli	a2,a2,0x2
  800396:	965a                	add	a2,a2,s6
  800398:	421c                	lw	a5,0(a2)
  80039a:	97da                	add	a5,a5,s6
  80039c:	8782                	jr	a5
  80039e:	70e6                	ld	ra,120(sp)
  8003a0:	7446                	ld	s0,112(sp)
  8003a2:	74a6                	ld	s1,104(sp)
  8003a4:	7906                	ld	s2,96(sp)
  8003a6:	69e6                	ld	s3,88(sp)
  8003a8:	6a46                	ld	s4,80(sp)
  8003aa:	6aa6                	ld	s5,72(sp)
  8003ac:	6b06                	ld	s6,64(sp)
  8003ae:	7be2                	ld	s7,56(sp)
  8003b0:	7c42                	ld	s8,48(sp)
  8003b2:	7ca2                	ld	s9,40(sp)
  8003b4:	7d02                	ld	s10,32(sp)
  8003b6:	6de2                	ld	s11,24(sp)
  8003b8:	6109                	addi	sp,sp,128
  8003ba:	8082                	ret
  8003bc:	864e                	mv	a2,s3
  8003be:	85ca                	mv	a1,s2
  8003c0:	02500513          	li	a0,37
  8003c4:	9482                	jalr	s1
  8003c6:	fff44783          	lbu	a5,-1(s0)
  8003ca:	02500713          	li	a4,37
  8003ce:	8ca2                	mv	s9,s0
  8003d0:	f8e783e3          	beq	a5,a4,800356 <vprintfmt+0x36>
  8003d4:	ffecc783          	lbu	a5,-2(s9)
  8003d8:	1cfd                	addi	s9,s9,-1
  8003da:	fee79de3          	bne	a5,a4,8003d4 <vprintfmt+0xb4>
  8003de:	bfa5                	j	800356 <vprintfmt+0x36>
  8003e0:	00144683          	lbu	a3,1(s0)
  8003e4:	4525                	li	a0,9
  8003e6:	fd070d1b          	addiw	s10,a4,-48
  8003ea:	fd06879b          	addiw	a5,a3,-48
  8003ee:	28f56063          	bltu	a0,a5,80066e <vprintfmt+0x34e>
  8003f2:	2681                	sext.w	a3,a3
  8003f4:	8466                	mv	s0,s9
  8003f6:	002d179b          	slliw	a5,s10,0x2
  8003fa:	00144703          	lbu	a4,1(s0)
  8003fe:	01a787bb          	addw	a5,a5,s10
  800402:	0017979b          	slliw	a5,a5,0x1
  800406:	9fb5                	addw	a5,a5,a3
  800408:	fd07061b          	addiw	a2,a4,-48
  80040c:	0405                	addi	s0,s0,1
  80040e:	fd078d1b          	addiw	s10,a5,-48
  800412:	0007069b          	sext.w	a3,a4
  800416:	fec570e3          	bgeu	a0,a2,8003f6 <vprintfmt+0xd6>
  80041a:	f60dd3e3          	bgez	s11,800380 <vprintfmt+0x60>
  80041e:	8dea                	mv	s11,s10
  800420:	5d7d                	li	s10,-1
  800422:	bfb9                	j	800380 <vprintfmt+0x60>
  800424:	883a                	mv	a6,a4
  800426:	8466                	mv	s0,s9
  800428:	bfa1                	j	800380 <vprintfmt+0x60>
  80042a:	8466                	mv	s0,s9
  80042c:	4c05                	li	s8,1
  80042e:	bf89                	j	800380 <vprintfmt+0x60>
  800430:	4785                	li	a5,1
  800432:	008a8613          	addi	a2,s5,8
  800436:	00b7c463          	blt	a5,a1,80043e <vprintfmt+0x11e>
  80043a:	1c058363          	beqz	a1,800600 <vprintfmt+0x2e0>
  80043e:	000ab683          	ld	a3,0(s5)
  800442:	4741                	li	a4,16
  800444:	8ab2                	mv	s5,a2
  800446:	2801                	sext.w	a6,a6
  800448:	87ee                	mv	a5,s11
  80044a:	864a                	mv	a2,s2
  80044c:	85ce                	mv	a1,s3
  80044e:	8526                	mv	a0,s1
  800450:	e61ff0ef          	jal	8002b0 <printnum>
  800454:	b709                	j	800356 <vprintfmt+0x36>
  800456:	000aa503          	lw	a0,0(s5)
  80045a:	864e                	mv	a2,s3
  80045c:	85ca                	mv	a1,s2
  80045e:	9482                	jalr	s1
  800460:	0aa1                	addi	s5,s5,8
  800462:	bdd5                	j	800356 <vprintfmt+0x36>
  800464:	4785                	li	a5,1
  800466:	008a8613          	addi	a2,s5,8
  80046a:	00b7c463          	blt	a5,a1,800472 <vprintfmt+0x152>
  80046e:	18058463          	beqz	a1,8005f6 <vprintfmt+0x2d6>
  800472:	000ab683          	ld	a3,0(s5)
  800476:	4729                	li	a4,10
  800478:	8ab2                	mv	s5,a2
  80047a:	b7f1                	j	800446 <vprintfmt+0x126>
  80047c:	864e                	mv	a2,s3
  80047e:	85ca                	mv	a1,s2
  800480:	03000513          	li	a0,48
  800484:	e042                	sd	a6,0(sp)
  800486:	9482                	jalr	s1
  800488:	864e                	mv	a2,s3
  80048a:	85ca                	mv	a1,s2
  80048c:	07800513          	li	a0,120
  800490:	9482                	jalr	s1
  800492:	000ab683          	ld	a3,0(s5)
  800496:	6802                	ld	a6,0(sp)
  800498:	4741                	li	a4,16
  80049a:	0aa1                	addi	s5,s5,8
  80049c:	b76d                	j	800446 <vprintfmt+0x126>
  80049e:	864e                	mv	a2,s3
  8004a0:	85ca                	mv	a1,s2
  8004a2:	02500513          	li	a0,37
  8004a6:	9482                	jalr	s1
  8004a8:	b57d                	j	800356 <vprintfmt+0x36>
  8004aa:	000aad03          	lw	s10,0(s5)
  8004ae:	8466                	mv	s0,s9
  8004b0:	0aa1                	addi	s5,s5,8
  8004b2:	b7a5                	j	80041a <vprintfmt+0xfa>
  8004b4:	4785                	li	a5,1
  8004b6:	008a8613          	addi	a2,s5,8
  8004ba:	00b7c463          	blt	a5,a1,8004c2 <vprintfmt+0x1a2>
  8004be:	12058763          	beqz	a1,8005ec <vprintfmt+0x2cc>
  8004c2:	000ab683          	ld	a3,0(s5)
  8004c6:	4721                	li	a4,8
  8004c8:	8ab2                	mv	s5,a2
  8004ca:	bfb5                	j	800446 <vprintfmt+0x126>
  8004cc:	87ee                	mv	a5,s11
  8004ce:	000dd363          	bgez	s11,8004d4 <vprintfmt+0x1b4>
  8004d2:	4781                	li	a5,0
  8004d4:	00078d9b          	sext.w	s11,a5
  8004d8:	8466                	mv	s0,s9
  8004da:	b55d                	j	800380 <vprintfmt+0x60>
  8004dc:	0008041b          	sext.w	s0,a6
  8004e0:	fd340793          	addi	a5,s0,-45
  8004e4:	01b02733          	sgtz	a4,s11
  8004e8:	00f037b3          	snez	a5,a5
  8004ec:	8ff9                	and	a5,a5,a4
  8004ee:	000ab703          	ld	a4,0(s5)
  8004f2:	008a8693          	addi	a3,s5,8
  8004f6:	e436                	sd	a3,8(sp)
  8004f8:	12070563          	beqz	a4,800622 <vprintfmt+0x302>
  8004fc:	12079d63          	bnez	a5,800636 <vprintfmt+0x316>
  800500:	00074783          	lbu	a5,0(a4)
  800504:	0007851b          	sext.w	a0,a5
  800508:	c78d                	beqz	a5,800532 <vprintfmt+0x212>
  80050a:	00170a93          	addi	s5,a4,1
  80050e:	547d                	li	s0,-1
  800510:	000d4563          	bltz	s10,80051a <vprintfmt+0x1fa>
  800514:	3d7d                	addiw	s10,s10,-1
  800516:	008d0e63          	beq	s10,s0,800532 <vprintfmt+0x212>
  80051a:	020c1863          	bnez	s8,80054a <vprintfmt+0x22a>
  80051e:	864e                	mv	a2,s3
  800520:	85ca                	mv	a1,s2
  800522:	9482                	jalr	s1
  800524:	000ac783          	lbu	a5,0(s5)
  800528:	0a85                	addi	s5,s5,1
  80052a:	3dfd                	addiw	s11,s11,-1
  80052c:	0007851b          	sext.w	a0,a5
  800530:	f3e5                	bnez	a5,800510 <vprintfmt+0x1f0>
  800532:	01b05a63          	blez	s11,800546 <vprintfmt+0x226>
  800536:	864e                	mv	a2,s3
  800538:	85ca                	mv	a1,s2
  80053a:	02000513          	li	a0,32
  80053e:	3dfd                	addiw	s11,s11,-1
  800540:	9482                	jalr	s1
  800542:	fe0d9ae3          	bnez	s11,800536 <vprintfmt+0x216>
  800546:	6aa2                	ld	s5,8(sp)
  800548:	b539                	j	800356 <vprintfmt+0x36>
  80054a:	3781                	addiw	a5,a5,-32
  80054c:	05e00713          	li	a4,94
  800550:	fcf777e3          	bgeu	a4,a5,80051e <vprintfmt+0x1fe>
  800554:	03f00513          	li	a0,63
  800558:	864e                	mv	a2,s3
  80055a:	85ca                	mv	a1,s2
  80055c:	9482                	jalr	s1
  80055e:	000ac783          	lbu	a5,0(s5)
  800562:	0a85                	addi	s5,s5,1
  800564:	3dfd                	addiw	s11,s11,-1
  800566:	0007851b          	sext.w	a0,a5
  80056a:	d7e1                	beqz	a5,800532 <vprintfmt+0x212>
  80056c:	fa0d54e3          	bgez	s10,800514 <vprintfmt+0x1f4>
  800570:	bfe9                	j	80054a <vprintfmt+0x22a>
  800572:	000aa783          	lw	a5,0(s5)
  800576:	46e1                	li	a3,24
  800578:	0aa1                	addi	s5,s5,8
  80057a:	41f7d71b          	sraiw	a4,a5,0x1f
  80057e:	8fb9                	xor	a5,a5,a4
  800580:	40e7873b          	subw	a4,a5,a4
  800584:	02e6c663          	blt	a3,a4,8005b0 <vprintfmt+0x290>
  800588:	00000797          	auipc	a5,0x0
  80058c:	76878793          	addi	a5,a5,1896 # 800cf0 <error_string>
  800590:	00371693          	slli	a3,a4,0x3
  800594:	97b6                	add	a5,a5,a3
  800596:	639c                	ld	a5,0(a5)
  800598:	cf81                	beqz	a5,8005b0 <vprintfmt+0x290>
  80059a:	873e                	mv	a4,a5
  80059c:	00000697          	auipc	a3,0x0
  8005a0:	2e468693          	addi	a3,a3,740 # 800880 <main+0x1c6>
  8005a4:	864a                	mv	a2,s2
  8005a6:	85ce                	mv	a1,s3
  8005a8:	8526                	mv	a0,s1
  8005aa:	0f2000ef          	jal	80069c <printfmt>
  8005ae:	b365                	j	800356 <vprintfmt+0x36>
  8005b0:	00000697          	auipc	a3,0x0
  8005b4:	2c068693          	addi	a3,a3,704 # 800870 <main+0x1b6>
  8005b8:	864a                	mv	a2,s2
  8005ba:	85ce                	mv	a1,s3
  8005bc:	8526                	mv	a0,s1
  8005be:	0de000ef          	jal	80069c <printfmt>
  8005c2:	bb51                	j	800356 <vprintfmt+0x36>
  8005c4:	4785                	li	a5,1
  8005c6:	008a8c13          	addi	s8,s5,8
  8005ca:	00b7c363          	blt	a5,a1,8005d0 <vprintfmt+0x2b0>
  8005ce:	cd81                	beqz	a1,8005e6 <vprintfmt+0x2c6>
  8005d0:	000ab403          	ld	s0,0(s5)
  8005d4:	02044b63          	bltz	s0,80060a <vprintfmt+0x2ea>
  8005d8:	86a2                	mv	a3,s0
  8005da:	8ae2                	mv	s5,s8
  8005dc:	4729                	li	a4,10
  8005de:	b5a5                	j	800446 <vprintfmt+0x126>
  8005e0:	2585                	addiw	a1,a1,1
  8005e2:	8466                	mv	s0,s9
  8005e4:	bb71                	j	800380 <vprintfmt+0x60>
  8005e6:	000aa403          	lw	s0,0(s5)
  8005ea:	b7ed                	j	8005d4 <vprintfmt+0x2b4>
  8005ec:	000ae683          	lwu	a3,0(s5)
  8005f0:	4721                	li	a4,8
  8005f2:	8ab2                	mv	s5,a2
  8005f4:	bd89                	j	800446 <vprintfmt+0x126>
  8005f6:	000ae683          	lwu	a3,0(s5)
  8005fa:	4729                	li	a4,10
  8005fc:	8ab2                	mv	s5,a2
  8005fe:	b5a1                	j	800446 <vprintfmt+0x126>
  800600:	000ae683          	lwu	a3,0(s5)
  800604:	4741                	li	a4,16
  800606:	8ab2                	mv	s5,a2
  800608:	bd3d                	j	800446 <vprintfmt+0x126>
  80060a:	864e                	mv	a2,s3
  80060c:	85ca                	mv	a1,s2
  80060e:	02d00513          	li	a0,45
  800612:	e042                	sd	a6,0(sp)
  800614:	9482                	jalr	s1
  800616:	6802                	ld	a6,0(sp)
  800618:	408006b3          	neg	a3,s0
  80061c:	8ae2                	mv	s5,s8
  80061e:	4729                	li	a4,10
  800620:	b51d                	j	800446 <vprintfmt+0x126>
  800622:	eba1                	bnez	a5,800672 <vprintfmt+0x352>
  800624:	02800793          	li	a5,40
  800628:	853e                	mv	a0,a5
  80062a:	00000a97          	auipc	s5,0x0
  80062e:	23fa8a93          	addi	s5,s5,575 # 800869 <main+0x1af>
  800632:	547d                	li	s0,-1
  800634:	bdf1                	j	800510 <vprintfmt+0x1f0>
  800636:	853a                	mv	a0,a4
  800638:	85ea                	mv	a1,s10
  80063a:	e03a                	sd	a4,0(sp)
  80063c:	c59ff0ef          	jal	800294 <strnlen>
  800640:	40ad8dbb          	subw	s11,s11,a0
  800644:	6702                	ld	a4,0(sp)
  800646:	01b05b63          	blez	s11,80065c <vprintfmt+0x33c>
  80064a:	864e                	mv	a2,s3
  80064c:	85ca                	mv	a1,s2
  80064e:	8522                	mv	a0,s0
  800650:	e03a                	sd	a4,0(sp)
  800652:	3dfd                	addiw	s11,s11,-1
  800654:	9482                	jalr	s1
  800656:	6702                	ld	a4,0(sp)
  800658:	fe0d99e3          	bnez	s11,80064a <vprintfmt+0x32a>
  80065c:	00074783          	lbu	a5,0(a4)
  800660:	0007851b          	sext.w	a0,a5
  800664:	ee0781e3          	beqz	a5,800546 <vprintfmt+0x226>
  800668:	00170a93          	addi	s5,a4,1
  80066c:	b54d                	j	80050e <vprintfmt+0x1ee>
  80066e:	8466                	mv	s0,s9
  800670:	b36d                	j	80041a <vprintfmt+0xfa>
  800672:	85ea                	mv	a1,s10
  800674:	00000517          	auipc	a0,0x0
  800678:	1f450513          	addi	a0,a0,500 # 800868 <main+0x1ae>
  80067c:	c19ff0ef          	jal	800294 <strnlen>
  800680:	40ad8dbb          	subw	s11,s11,a0
  800684:	02800793          	li	a5,40
  800688:	00000717          	auipc	a4,0x0
  80068c:	1e070713          	addi	a4,a4,480 # 800868 <main+0x1ae>
  800690:	853e                	mv	a0,a5
  800692:	fbb04ce3          	bgtz	s11,80064a <vprintfmt+0x32a>
  800696:	00170a93          	addi	s5,a4,1
  80069a:	bd95                	j	80050e <vprintfmt+0x1ee>

000000000080069c <printfmt>:
  80069c:	7139                	addi	sp,sp,-64
  80069e:	02010313          	addi	t1,sp,32
  8006a2:	f03a                	sd	a4,32(sp)
  8006a4:	871a                	mv	a4,t1
  8006a6:	ec06                	sd	ra,24(sp)
  8006a8:	f43e                	sd	a5,40(sp)
  8006aa:	f842                	sd	a6,48(sp)
  8006ac:	fc46                	sd	a7,56(sp)
  8006ae:	e41a                	sd	t1,8(sp)
  8006b0:	c71ff0ef          	jal	800320 <vprintfmt>
  8006b4:	60e2                	ld	ra,24(sp)
  8006b6:	6121                	addi	sp,sp,64
  8006b8:	8082                	ret

00000000008006ba <main>:
  8006ba:	1141                	addi	sp,sp,-16
  8006bc:	00000517          	auipc	a0,0x0
  8006c0:	3a450513          	addi	a0,a0,932 # 800a60 <main+0x3a6>
  8006c4:	e406                	sd	ra,8(sp)
  8006c6:	e022                	sd	s0,0(sp)
  8006c8:	addff0ef          	jal	8001a4 <cprintf>
  8006cc:	a69ff0ef          	jal	800134 <fork>
  8006d0:	e901                	bnez	a0,8006e0 <main+0x26>
  8006d2:	00000517          	auipc	a0,0x0
  8006d6:	3b650513          	addi	a0,a0,950 # 800a88 <main+0x3ce>
  8006da:	acbff0ef          	jal	8001a4 <cprintf>
  8006de:	a001                	j	8006de <main+0x24>
  8006e0:	842a                	mv	s0,a0
  8006e2:	00000517          	auipc	a0,0x0
  8006e6:	3c650513          	addi	a0,a0,966 # 800aa8 <main+0x3ee>
  8006ea:	abbff0ef          	jal	8001a4 <cprintf>
  8006ee:	a65ff0ef          	jal	800152 <yield>
  8006f2:	a61ff0ef          	jal	800152 <yield>
  8006f6:	a5dff0ef          	jal	800152 <yield>
  8006fa:	00000517          	auipc	a0,0x0
  8006fe:	3d650513          	addi	a0,a0,982 # 800ad0 <main+0x416>
  800702:	aa3ff0ef          	jal	8001a4 <cprintf>
  800706:	8522                	mv	a0,s0
  800708:	a4dff0ef          	jal	800154 <kill>
  80070c:	ed31                	bnez	a0,800768 <main+0xae>
  80070e:	4581                	li	a1,0
  800710:	00000517          	auipc	a0,0x0
  800714:	42850513          	addi	a0,a0,1064 # 800b38 <main+0x47e>
  800718:	a8dff0ef          	jal	8001a4 <cprintf>
  80071c:	8522                	mv	a0,s0
  80071e:	4581                	li	a1,0
  800720:	a17ff0ef          	jal	800136 <waitpid>
  800724:	e11d                	bnez	a0,80074a <main+0x90>
  800726:	4581                	li	a1,0
  800728:	00000517          	auipc	a0,0x0
  80072c:	44850513          	addi	a0,a0,1096 # 800b70 <main+0x4b6>
  800730:	a75ff0ef          	jal	8001a4 <cprintf>
  800734:	00000517          	auipc	a0,0x0
  800738:	45450513          	addi	a0,a0,1108 # 800b88 <main+0x4ce>
  80073c:	a69ff0ef          	jal	8001a4 <cprintf>
  800740:	60a2                	ld	ra,8(sp)
  800742:	6402                	ld	s0,0(sp)
  800744:	4501                	li	a0,0
  800746:	0141                	addi	sp,sp,16
  800748:	8082                	ret
  80074a:	00000697          	auipc	a3,0x0
  80074e:	40668693          	addi	a3,a3,1030 # 800b50 <main+0x496>
  800752:	00000617          	auipc	a2,0x0
  800756:	3be60613          	addi	a2,a2,958 # 800b10 <main+0x456>
  80075a:	45dd                	li	a1,23
  80075c:	00000517          	auipc	a0,0x0
  800760:	3cc50513          	addi	a0,a0,972 # 800b28 <main+0x46e>
  800764:	8bdff0ef          	jal	800020 <__panic>
  800768:	00000697          	auipc	a3,0x0
  80076c:	39068693          	addi	a3,a3,912 # 800af8 <main+0x43e>
  800770:	00000617          	auipc	a2,0x0
  800774:	3a060613          	addi	a2,a2,928 # 800b10 <main+0x456>
  800778:	45d1                	li	a1,20
  80077a:	00000517          	auipc	a0,0x0
  80077e:	3ae50513          	addi	a0,a0,942 # 800b28 <main+0x46e>
  800782:	89fff0ef          	jal	800020 <__panic>
