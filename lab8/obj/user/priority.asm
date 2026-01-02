
obj/__user_priority.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00001517          	auipc	a0,0x1
  800032:	86250513          	addi	a0,a0,-1950 # 800890 <main+0x1b0>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	174000ef          	jal	8001b8 <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	146000ef          	jal	800192 <vcprintf>
  800050:	00001517          	auipc	a0,0x1
  800054:	86050513          	addi	a0,a0,-1952 # 8008b0 <main+0x1d0>
  800058:	160000ef          	jal	8001b8 <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0cc000ef          	jal	80012a <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00001517          	auipc	a0,0x1
  800074:	84850513          	addi	a0,a0,-1976 # 8008b8 <main+0x1d8>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	132000ef          	jal	8001b8 <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	104000ef          	jal	800192 <vcprintf>
  800092:	00001517          	auipc	a0,0x1
  800096:	81e50513          	addi	a0,a0,-2018 # 8008b0 <main+0x1d0>
  80009a:	11e000ef          	jal	8001b8 <cprintf>
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

00000000008000f2 <sys_kill>:
  8000f2:	85aa                	mv	a1,a0
  8000f4:	4531                	li	a0,12
  8000f6:	bf45                	j	8000a6 <syscall>

00000000008000f8 <sys_getpid>:
  8000f8:	4549                	li	a0,18
  8000fa:	b775                	j	8000a6 <syscall>

00000000008000fc <sys_putc>:
  8000fc:	85aa                	mv	a1,a0
  8000fe:	4579                	li	a0,30
  800100:	b75d                	j	8000a6 <syscall>

0000000000800102 <sys_lab6_set_priority>:
  800102:	85aa                	mv	a1,a0
  800104:	0ff00513          	li	a0,255
  800108:	bf79                	j	8000a6 <syscall>

000000000080010a <sys_gettime>:
  80010a:	4545                	li	a0,17
  80010c:	bf69                	j	8000a6 <syscall>

000000000080010e <sys_open>:
  80010e:	862e                	mv	a2,a1
  800110:	85aa                	mv	a1,a0
  800112:	06400513          	li	a0,100
  800116:	bf41                	j	8000a6 <syscall>

0000000000800118 <sys_close>:
  800118:	85aa                	mv	a1,a0
  80011a:	06500513          	li	a0,101
  80011e:	b761                	j	8000a6 <syscall>

0000000000800120 <sys_dup>:
  800120:	862e                	mv	a2,a1
  800122:	85aa                	mv	a1,a0
  800124:	08200513          	li	a0,130
  800128:	bfbd                	j	8000a6 <syscall>

000000000080012a <exit>:
  80012a:	1141                	addi	sp,sp,-16
  80012c:	e406                	sd	ra,8(sp)
  80012e:	fb3ff0ef          	jal	8000e0 <sys_exit>
  800132:	00000517          	auipc	a0,0x0
  800136:	7a650513          	addi	a0,a0,1958 # 8008d8 <main+0x1f8>
  80013a:	07e000ef          	jal	8001b8 <cprintf>
  80013e:	a001                	j	80013e <exit+0x14>

0000000000800140 <fork>:
  800140:	b75d                	j	8000e6 <sys_fork>

0000000000800142 <waitpid>:
  800142:	cd89                	beqz	a1,80015c <waitpid+0x1a>
  800144:	7179                	addi	sp,sp,-48
  800146:	e42e                	sd	a1,8(sp)
  800148:	082c                	addi	a1,sp,24
  80014a:	f406                	sd	ra,40(sp)
  80014c:	f9fff0ef          	jal	8000ea <sys_wait>
  800150:	6762                	ld	a4,24(sp)
  800152:	67a2                	ld	a5,8(sp)
  800154:	70a2                	ld	ra,40(sp)
  800156:	c398                	sw	a4,0(a5)
  800158:	6145                	addi	sp,sp,48
  80015a:	8082                	ret
  80015c:	b779                	j	8000ea <sys_wait>

000000000080015e <kill>:
  80015e:	bf51                	j	8000f2 <sys_kill>

0000000000800160 <getpid>:
  800160:	bf61                	j	8000f8 <sys_getpid>

0000000000800162 <gettime_msec>:
  800162:	b765                	j	80010a <sys_gettime>

0000000000800164 <lab6_set_priority>:
  800164:	1502                	slli	a0,a0,0x20
  800166:	9101                	srli	a0,a0,0x20
  800168:	bf69                	j	800102 <sys_lab6_set_priority>

000000000080016a <_start>:
  80016a:	0ca000ef          	jal	800234 <umain>
  80016e:	a001                	j	80016e <_start+0x4>

0000000000800170 <open>:
  800170:	1582                	slli	a1,a1,0x20
  800172:	9181                	srli	a1,a1,0x20
  800174:	bf69                	j	80010e <sys_open>

0000000000800176 <close>:
  800176:	b74d                	j	800118 <sys_close>

0000000000800178 <dup2>:
  800178:	b765                	j	800120 <sys_dup>

000000000080017a <cputch>:
  80017a:	1101                	addi	sp,sp,-32
  80017c:	ec06                	sd	ra,24(sp)
  80017e:	e42e                	sd	a1,8(sp)
  800180:	f7dff0ef          	jal	8000fc <sys_putc>
  800184:	65a2                	ld	a1,8(sp)
  800186:	60e2                	ld	ra,24(sp)
  800188:	419c                	lw	a5,0(a1)
  80018a:	2785                	addiw	a5,a5,1
  80018c:	c19c                	sw	a5,0(a1)
  80018e:	6105                	addi	sp,sp,32
  800190:	8082                	ret

0000000000800192 <vcprintf>:
  800192:	1101                	addi	sp,sp,-32
  800194:	872e                	mv	a4,a1
  800196:	75dd                	lui	a1,0xffff7
  800198:	86aa                	mv	a3,a0
  80019a:	0070                	addi	a2,sp,12
  80019c:	00000517          	auipc	a0,0x0
  8001a0:	fde50513          	addi	a0,a0,-34 # 80017a <cputch>
  8001a4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <acc+0xffffffffff7f5aa9>
  8001a8:	ec06                	sd	ra,24(sp)
  8001aa:	c602                	sw	zero,12(sp)
  8001ac:	19a000ef          	jal	800346 <vprintfmt>
  8001b0:	60e2                	ld	ra,24(sp)
  8001b2:	4532                	lw	a0,12(sp)
  8001b4:	6105                	addi	sp,sp,32
  8001b6:	8082                	ret

00000000008001b8 <cprintf>:
  8001b8:	711d                	addi	sp,sp,-96
  8001ba:	02810313          	addi	t1,sp,40
  8001be:	f42e                	sd	a1,40(sp)
  8001c0:	75dd                	lui	a1,0xffff7
  8001c2:	f832                	sd	a2,48(sp)
  8001c4:	fc36                	sd	a3,56(sp)
  8001c6:	e0ba                	sd	a4,64(sp)
  8001c8:	86aa                	mv	a3,a0
  8001ca:	0050                	addi	a2,sp,4
  8001cc:	00000517          	auipc	a0,0x0
  8001d0:	fae50513          	addi	a0,a0,-82 # 80017a <cputch>
  8001d4:	871a                	mv	a4,t1
  8001d6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <acc+0xffffffffff7f5aa9>
  8001da:	ec06                	sd	ra,24(sp)
  8001dc:	e4be                	sd	a5,72(sp)
  8001de:	e8c2                	sd	a6,80(sp)
  8001e0:	ecc6                	sd	a7,88(sp)
  8001e2:	c202                	sw	zero,4(sp)
  8001e4:	e41a                	sd	t1,8(sp)
  8001e6:	160000ef          	jal	800346 <vprintfmt>
  8001ea:	60e2                	ld	ra,24(sp)
  8001ec:	4512                	lw	a0,4(sp)
  8001ee:	6125                	addi	sp,sp,96
  8001f0:	8082                	ret

00000000008001f2 <initfd>:
  8001f2:	87ae                	mv	a5,a1
  8001f4:	1101                	addi	sp,sp,-32
  8001f6:	e822                	sd	s0,16(sp)
  8001f8:	85b2                	mv	a1,a2
  8001fa:	842a                	mv	s0,a0
  8001fc:	853e                	mv	a0,a5
  8001fe:	ec06                	sd	ra,24(sp)
  800200:	f71ff0ef          	jal	800170 <open>
  800204:	87aa                	mv	a5,a0
  800206:	00054463          	bltz	a0,80020e <initfd+0x1c>
  80020a:	00851763          	bne	a0,s0,800218 <initfd+0x26>
  80020e:	60e2                	ld	ra,24(sp)
  800210:	6442                	ld	s0,16(sp)
  800212:	853e                	mv	a0,a5
  800214:	6105                	addi	sp,sp,32
  800216:	8082                	ret
  800218:	e42a                	sd	a0,8(sp)
  80021a:	8522                	mv	a0,s0
  80021c:	f5bff0ef          	jal	800176 <close>
  800220:	6522                	ld	a0,8(sp)
  800222:	85a2                	mv	a1,s0
  800224:	f55ff0ef          	jal	800178 <dup2>
  800228:	842a                	mv	s0,a0
  80022a:	6522                	ld	a0,8(sp)
  80022c:	f4bff0ef          	jal	800176 <close>
  800230:	87a2                	mv	a5,s0
  800232:	bff1                	j	80020e <initfd+0x1c>

0000000000800234 <umain>:
  800234:	1101                	addi	sp,sp,-32
  800236:	e822                	sd	s0,16(sp)
  800238:	e426                	sd	s1,8(sp)
  80023a:	842a                	mv	s0,a0
  80023c:	84ae                	mv	s1,a1
  80023e:	4601                	li	a2,0
  800240:	00000597          	auipc	a1,0x0
  800244:	6b058593          	addi	a1,a1,1712 # 8008f0 <main+0x210>
  800248:	4501                	li	a0,0
  80024a:	ec06                	sd	ra,24(sp)
  80024c:	fa7ff0ef          	jal	8001f2 <initfd>
  800250:	02054263          	bltz	a0,800274 <umain+0x40>
  800254:	4605                	li	a2,1
  800256:	8532                	mv	a0,a2
  800258:	00000597          	auipc	a1,0x0
  80025c:	6d858593          	addi	a1,a1,1752 # 800930 <main+0x250>
  800260:	f93ff0ef          	jal	8001f2 <initfd>
  800264:	02054563          	bltz	a0,80028e <umain+0x5a>
  800268:	85a6                	mv	a1,s1
  80026a:	8522                	mv	a0,s0
  80026c:	474000ef          	jal	8006e0 <main>
  800270:	ebbff0ef          	jal	80012a <exit>
  800274:	86aa                	mv	a3,a0
  800276:	00000617          	auipc	a2,0x0
  80027a:	68260613          	addi	a2,a2,1666 # 8008f8 <main+0x218>
  80027e:	45e9                	li	a1,26
  800280:	00000517          	auipc	a0,0x0
  800284:	69850513          	addi	a0,a0,1688 # 800918 <main+0x238>
  800288:	ddbff0ef          	jal	800062 <__warn>
  80028c:	b7e1                	j	800254 <umain+0x20>
  80028e:	86aa                	mv	a3,a0
  800290:	00000617          	auipc	a2,0x0
  800294:	6a860613          	addi	a2,a2,1704 # 800938 <main+0x258>
  800298:	45f5                	li	a1,29
  80029a:	00000517          	auipc	a0,0x0
  80029e:	67e50513          	addi	a0,a0,1662 # 800918 <main+0x238>
  8002a2:	dc1ff0ef          	jal	800062 <__warn>
  8002a6:	b7c9                	j	800268 <umain+0x34>

00000000008002a8 <strnlen>:
  8002a8:	4781                	li	a5,0
  8002aa:	e589                	bnez	a1,8002b4 <strnlen+0xc>
  8002ac:	a811                	j	8002c0 <strnlen+0x18>
  8002ae:	0785                	addi	a5,a5,1
  8002b0:	00f58863          	beq	a1,a5,8002c0 <strnlen+0x18>
  8002b4:	00f50733          	add	a4,a0,a5
  8002b8:	00074703          	lbu	a4,0(a4)
  8002bc:	fb6d                	bnez	a4,8002ae <strnlen+0x6>
  8002be:	85be                	mv	a1,a5
  8002c0:	852e                	mv	a0,a1
  8002c2:	8082                	ret

00000000008002c4 <memset>:
  8002c4:	ca01                	beqz	a2,8002d4 <memset+0x10>
  8002c6:	962a                	add	a2,a2,a0
  8002c8:	87aa                	mv	a5,a0
  8002ca:	0785                	addi	a5,a5,1
  8002cc:	feb78fa3          	sb	a1,-1(a5)
  8002d0:	fef61de3          	bne	a2,a5,8002ca <memset+0x6>
  8002d4:	8082                	ret

00000000008002d6 <printnum>:
  8002d6:	7139                	addi	sp,sp,-64
  8002d8:	02071893          	slli	a7,a4,0x20
  8002dc:	f822                	sd	s0,48(sp)
  8002de:	f426                	sd	s1,40(sp)
  8002e0:	f04a                	sd	s2,32(sp)
  8002e2:	ec4e                	sd	s3,24(sp)
  8002e4:	e456                	sd	s5,8(sp)
  8002e6:	0208d893          	srli	a7,a7,0x20
  8002ea:	fc06                	sd	ra,56(sp)
  8002ec:	0316fab3          	remu	s5,a3,a7
  8002f0:	fff7841b          	addiw	s0,a5,-1
  8002f4:	84aa                	mv	s1,a0
  8002f6:	89ae                	mv	s3,a1
  8002f8:	8932                	mv	s2,a2
  8002fa:	0516f063          	bgeu	a3,a7,80033a <printnum+0x64>
  8002fe:	e852                	sd	s4,16(sp)
  800300:	4705                	li	a4,1
  800302:	8a42                	mv	s4,a6
  800304:	00f75863          	bge	a4,a5,800314 <printnum+0x3e>
  800308:	864e                	mv	a2,s3
  80030a:	85ca                	mv	a1,s2
  80030c:	8552                	mv	a0,s4
  80030e:	347d                	addiw	s0,s0,-1
  800310:	9482                	jalr	s1
  800312:	f87d                	bnez	s0,800308 <printnum+0x32>
  800314:	6a42                	ld	s4,16(sp)
  800316:	00000797          	auipc	a5,0x0
  80031a:	64278793          	addi	a5,a5,1602 # 800958 <main+0x278>
  80031e:	97d6                	add	a5,a5,s5
  800320:	7442                	ld	s0,48(sp)
  800322:	0007c503          	lbu	a0,0(a5)
  800326:	70e2                	ld	ra,56(sp)
  800328:	6aa2                	ld	s5,8(sp)
  80032a:	864e                	mv	a2,s3
  80032c:	85ca                	mv	a1,s2
  80032e:	69e2                	ld	s3,24(sp)
  800330:	7902                	ld	s2,32(sp)
  800332:	87a6                	mv	a5,s1
  800334:	74a2                	ld	s1,40(sp)
  800336:	6121                	addi	sp,sp,64
  800338:	8782                	jr	a5
  80033a:	0316d6b3          	divu	a3,a3,a7
  80033e:	87a2                	mv	a5,s0
  800340:	f97ff0ef          	jal	8002d6 <printnum>
  800344:	bfc9                	j	800316 <printnum+0x40>

0000000000800346 <vprintfmt>:
  800346:	7119                	addi	sp,sp,-128
  800348:	f4a6                	sd	s1,104(sp)
  80034a:	f0ca                	sd	s2,96(sp)
  80034c:	ecce                	sd	s3,88(sp)
  80034e:	e8d2                	sd	s4,80(sp)
  800350:	e4d6                	sd	s5,72(sp)
  800352:	e0da                	sd	s6,64(sp)
  800354:	fc5e                	sd	s7,56(sp)
  800356:	f466                	sd	s9,40(sp)
  800358:	fc86                	sd	ra,120(sp)
  80035a:	f8a2                	sd	s0,112(sp)
  80035c:	f862                	sd	s8,48(sp)
  80035e:	f06a                	sd	s10,32(sp)
  800360:	ec6e                	sd	s11,24(sp)
  800362:	84aa                	mv	s1,a0
  800364:	8cb6                	mv	s9,a3
  800366:	8aba                	mv	s5,a4
  800368:	89ae                	mv	s3,a1
  80036a:	8932                	mv	s2,a2
  80036c:	02500a13          	li	s4,37
  800370:	05500b93          	li	s7,85
  800374:	00001b17          	auipc	s6,0x1
  800378:	8bcb0b13          	addi	s6,s6,-1860 # 800c30 <main+0x550>
  80037c:	000cc503          	lbu	a0,0(s9)
  800380:	001c8413          	addi	s0,s9,1
  800384:	01450b63          	beq	a0,s4,80039a <vprintfmt+0x54>
  800388:	cd15                	beqz	a0,8003c4 <vprintfmt+0x7e>
  80038a:	864e                	mv	a2,s3
  80038c:	85ca                	mv	a1,s2
  80038e:	9482                	jalr	s1
  800390:	00044503          	lbu	a0,0(s0)
  800394:	0405                	addi	s0,s0,1
  800396:	ff4519e3          	bne	a0,s4,800388 <vprintfmt+0x42>
  80039a:	5d7d                	li	s10,-1
  80039c:	8dea                	mv	s11,s10
  80039e:	02000813          	li	a6,32
  8003a2:	4c01                	li	s8,0
  8003a4:	4581                	li	a1,0
  8003a6:	00044703          	lbu	a4,0(s0)
  8003aa:	00140c93          	addi	s9,s0,1
  8003ae:	fdd7061b          	addiw	a2,a4,-35
  8003b2:	0ff67613          	zext.b	a2,a2
  8003b6:	02cbe663          	bltu	s7,a2,8003e2 <vprintfmt+0x9c>
  8003ba:	060a                	slli	a2,a2,0x2
  8003bc:	965a                	add	a2,a2,s6
  8003be:	421c                	lw	a5,0(a2)
  8003c0:	97da                	add	a5,a5,s6
  8003c2:	8782                	jr	a5
  8003c4:	70e6                	ld	ra,120(sp)
  8003c6:	7446                	ld	s0,112(sp)
  8003c8:	74a6                	ld	s1,104(sp)
  8003ca:	7906                	ld	s2,96(sp)
  8003cc:	69e6                	ld	s3,88(sp)
  8003ce:	6a46                	ld	s4,80(sp)
  8003d0:	6aa6                	ld	s5,72(sp)
  8003d2:	6b06                	ld	s6,64(sp)
  8003d4:	7be2                	ld	s7,56(sp)
  8003d6:	7c42                	ld	s8,48(sp)
  8003d8:	7ca2                	ld	s9,40(sp)
  8003da:	7d02                	ld	s10,32(sp)
  8003dc:	6de2                	ld	s11,24(sp)
  8003de:	6109                	addi	sp,sp,128
  8003e0:	8082                	ret
  8003e2:	864e                	mv	a2,s3
  8003e4:	85ca                	mv	a1,s2
  8003e6:	02500513          	li	a0,37
  8003ea:	9482                	jalr	s1
  8003ec:	fff44783          	lbu	a5,-1(s0)
  8003f0:	02500713          	li	a4,37
  8003f4:	8ca2                	mv	s9,s0
  8003f6:	f8e783e3          	beq	a5,a4,80037c <vprintfmt+0x36>
  8003fa:	ffecc783          	lbu	a5,-2(s9)
  8003fe:	1cfd                	addi	s9,s9,-1
  800400:	fee79de3          	bne	a5,a4,8003fa <vprintfmt+0xb4>
  800404:	bfa5                	j	80037c <vprintfmt+0x36>
  800406:	00144683          	lbu	a3,1(s0)
  80040a:	4525                	li	a0,9
  80040c:	fd070d1b          	addiw	s10,a4,-48
  800410:	fd06879b          	addiw	a5,a3,-48
  800414:	28f56063          	bltu	a0,a5,800694 <vprintfmt+0x34e>
  800418:	2681                	sext.w	a3,a3
  80041a:	8466                	mv	s0,s9
  80041c:	002d179b          	slliw	a5,s10,0x2
  800420:	00144703          	lbu	a4,1(s0)
  800424:	01a787bb          	addw	a5,a5,s10
  800428:	0017979b          	slliw	a5,a5,0x1
  80042c:	9fb5                	addw	a5,a5,a3
  80042e:	fd07061b          	addiw	a2,a4,-48
  800432:	0405                	addi	s0,s0,1
  800434:	fd078d1b          	addiw	s10,a5,-48
  800438:	0007069b          	sext.w	a3,a4
  80043c:	fec570e3          	bgeu	a0,a2,80041c <vprintfmt+0xd6>
  800440:	f60dd3e3          	bgez	s11,8003a6 <vprintfmt+0x60>
  800444:	8dea                	mv	s11,s10
  800446:	5d7d                	li	s10,-1
  800448:	bfb9                	j	8003a6 <vprintfmt+0x60>
  80044a:	883a                	mv	a6,a4
  80044c:	8466                	mv	s0,s9
  80044e:	bfa1                	j	8003a6 <vprintfmt+0x60>
  800450:	8466                	mv	s0,s9
  800452:	4c05                	li	s8,1
  800454:	bf89                	j	8003a6 <vprintfmt+0x60>
  800456:	4785                	li	a5,1
  800458:	008a8613          	addi	a2,s5,8
  80045c:	00b7c463          	blt	a5,a1,800464 <vprintfmt+0x11e>
  800460:	1c058363          	beqz	a1,800626 <vprintfmt+0x2e0>
  800464:	000ab683          	ld	a3,0(s5)
  800468:	4741                	li	a4,16
  80046a:	8ab2                	mv	s5,a2
  80046c:	2801                	sext.w	a6,a6
  80046e:	87ee                	mv	a5,s11
  800470:	864a                	mv	a2,s2
  800472:	85ce                	mv	a1,s3
  800474:	8526                	mv	a0,s1
  800476:	e61ff0ef          	jal	8002d6 <printnum>
  80047a:	b709                	j	80037c <vprintfmt+0x36>
  80047c:	000aa503          	lw	a0,0(s5)
  800480:	864e                	mv	a2,s3
  800482:	85ca                	mv	a1,s2
  800484:	9482                	jalr	s1
  800486:	0aa1                	addi	s5,s5,8
  800488:	bdd5                	j	80037c <vprintfmt+0x36>
  80048a:	4785                	li	a5,1
  80048c:	008a8613          	addi	a2,s5,8
  800490:	00b7c463          	blt	a5,a1,800498 <vprintfmt+0x152>
  800494:	18058463          	beqz	a1,80061c <vprintfmt+0x2d6>
  800498:	000ab683          	ld	a3,0(s5)
  80049c:	4729                	li	a4,10
  80049e:	8ab2                	mv	s5,a2
  8004a0:	b7f1                	j	80046c <vprintfmt+0x126>
  8004a2:	864e                	mv	a2,s3
  8004a4:	85ca                	mv	a1,s2
  8004a6:	03000513          	li	a0,48
  8004aa:	e042                	sd	a6,0(sp)
  8004ac:	9482                	jalr	s1
  8004ae:	864e                	mv	a2,s3
  8004b0:	85ca                	mv	a1,s2
  8004b2:	07800513          	li	a0,120
  8004b6:	9482                	jalr	s1
  8004b8:	000ab683          	ld	a3,0(s5)
  8004bc:	6802                	ld	a6,0(sp)
  8004be:	4741                	li	a4,16
  8004c0:	0aa1                	addi	s5,s5,8
  8004c2:	b76d                	j	80046c <vprintfmt+0x126>
  8004c4:	864e                	mv	a2,s3
  8004c6:	85ca                	mv	a1,s2
  8004c8:	02500513          	li	a0,37
  8004cc:	9482                	jalr	s1
  8004ce:	b57d                	j	80037c <vprintfmt+0x36>
  8004d0:	000aad03          	lw	s10,0(s5)
  8004d4:	8466                	mv	s0,s9
  8004d6:	0aa1                	addi	s5,s5,8
  8004d8:	b7a5                	j	800440 <vprintfmt+0xfa>
  8004da:	4785                	li	a5,1
  8004dc:	008a8613          	addi	a2,s5,8
  8004e0:	00b7c463          	blt	a5,a1,8004e8 <vprintfmt+0x1a2>
  8004e4:	12058763          	beqz	a1,800612 <vprintfmt+0x2cc>
  8004e8:	000ab683          	ld	a3,0(s5)
  8004ec:	4721                	li	a4,8
  8004ee:	8ab2                	mv	s5,a2
  8004f0:	bfb5                	j	80046c <vprintfmt+0x126>
  8004f2:	87ee                	mv	a5,s11
  8004f4:	000dd363          	bgez	s11,8004fa <vprintfmt+0x1b4>
  8004f8:	4781                	li	a5,0
  8004fa:	00078d9b          	sext.w	s11,a5
  8004fe:	8466                	mv	s0,s9
  800500:	b55d                	j	8003a6 <vprintfmt+0x60>
  800502:	0008041b          	sext.w	s0,a6
  800506:	fd340793          	addi	a5,s0,-45
  80050a:	01b02733          	sgtz	a4,s11
  80050e:	00f037b3          	snez	a5,a5
  800512:	8ff9                	and	a5,a5,a4
  800514:	000ab703          	ld	a4,0(s5)
  800518:	008a8693          	addi	a3,s5,8
  80051c:	e436                	sd	a3,8(sp)
  80051e:	12070563          	beqz	a4,800648 <vprintfmt+0x302>
  800522:	12079d63          	bnez	a5,80065c <vprintfmt+0x316>
  800526:	00074783          	lbu	a5,0(a4)
  80052a:	0007851b          	sext.w	a0,a5
  80052e:	c78d                	beqz	a5,800558 <vprintfmt+0x212>
  800530:	00170a93          	addi	s5,a4,1
  800534:	547d                	li	s0,-1
  800536:	000d4563          	bltz	s10,800540 <vprintfmt+0x1fa>
  80053a:	3d7d                	addiw	s10,s10,-1
  80053c:	008d0e63          	beq	s10,s0,800558 <vprintfmt+0x212>
  800540:	020c1863          	bnez	s8,800570 <vprintfmt+0x22a>
  800544:	864e                	mv	a2,s3
  800546:	85ca                	mv	a1,s2
  800548:	9482                	jalr	s1
  80054a:	000ac783          	lbu	a5,0(s5)
  80054e:	0a85                	addi	s5,s5,1
  800550:	3dfd                	addiw	s11,s11,-1
  800552:	0007851b          	sext.w	a0,a5
  800556:	f3e5                	bnez	a5,800536 <vprintfmt+0x1f0>
  800558:	01b05a63          	blez	s11,80056c <vprintfmt+0x226>
  80055c:	864e                	mv	a2,s3
  80055e:	85ca                	mv	a1,s2
  800560:	02000513          	li	a0,32
  800564:	3dfd                	addiw	s11,s11,-1
  800566:	9482                	jalr	s1
  800568:	fe0d9ae3          	bnez	s11,80055c <vprintfmt+0x216>
  80056c:	6aa2                	ld	s5,8(sp)
  80056e:	b539                	j	80037c <vprintfmt+0x36>
  800570:	3781                	addiw	a5,a5,-32
  800572:	05e00713          	li	a4,94
  800576:	fcf777e3          	bgeu	a4,a5,800544 <vprintfmt+0x1fe>
  80057a:	03f00513          	li	a0,63
  80057e:	864e                	mv	a2,s3
  800580:	85ca                	mv	a1,s2
  800582:	9482                	jalr	s1
  800584:	000ac783          	lbu	a5,0(s5)
  800588:	0a85                	addi	s5,s5,1
  80058a:	3dfd                	addiw	s11,s11,-1
  80058c:	0007851b          	sext.w	a0,a5
  800590:	d7e1                	beqz	a5,800558 <vprintfmt+0x212>
  800592:	fa0d54e3          	bgez	s10,80053a <vprintfmt+0x1f4>
  800596:	bfe9                	j	800570 <vprintfmt+0x22a>
  800598:	000aa783          	lw	a5,0(s5)
  80059c:	46e1                	li	a3,24
  80059e:	0aa1                	addi	s5,s5,8
  8005a0:	41f7d71b          	sraiw	a4,a5,0x1f
  8005a4:	8fb9                	xor	a5,a5,a4
  8005a6:	40e7873b          	subw	a4,a5,a4
  8005aa:	02e6c663          	blt	a3,a4,8005d6 <vprintfmt+0x290>
  8005ae:	00000797          	auipc	a5,0x0
  8005b2:	7da78793          	addi	a5,a5,2010 # 800d88 <error_string>
  8005b6:	00371693          	slli	a3,a4,0x3
  8005ba:	97b6                	add	a5,a5,a3
  8005bc:	639c                	ld	a5,0(a5)
  8005be:	cf81                	beqz	a5,8005d6 <vprintfmt+0x290>
  8005c0:	873e                	mv	a4,a5
  8005c2:	00000697          	auipc	a3,0x0
  8005c6:	3c668693          	addi	a3,a3,966 # 800988 <main+0x2a8>
  8005ca:	864a                	mv	a2,s2
  8005cc:	85ce                	mv	a1,s3
  8005ce:	8526                	mv	a0,s1
  8005d0:	0f2000ef          	jal	8006c2 <printfmt>
  8005d4:	b365                	j	80037c <vprintfmt+0x36>
  8005d6:	00000697          	auipc	a3,0x0
  8005da:	3a268693          	addi	a3,a3,930 # 800978 <main+0x298>
  8005de:	864a                	mv	a2,s2
  8005e0:	85ce                	mv	a1,s3
  8005e2:	8526                	mv	a0,s1
  8005e4:	0de000ef          	jal	8006c2 <printfmt>
  8005e8:	bb51                	j	80037c <vprintfmt+0x36>
  8005ea:	4785                	li	a5,1
  8005ec:	008a8c13          	addi	s8,s5,8
  8005f0:	00b7c363          	blt	a5,a1,8005f6 <vprintfmt+0x2b0>
  8005f4:	cd81                	beqz	a1,80060c <vprintfmt+0x2c6>
  8005f6:	000ab403          	ld	s0,0(s5)
  8005fa:	02044b63          	bltz	s0,800630 <vprintfmt+0x2ea>
  8005fe:	86a2                	mv	a3,s0
  800600:	8ae2                	mv	s5,s8
  800602:	4729                	li	a4,10
  800604:	b5a5                	j	80046c <vprintfmt+0x126>
  800606:	2585                	addiw	a1,a1,1
  800608:	8466                	mv	s0,s9
  80060a:	bb71                	j	8003a6 <vprintfmt+0x60>
  80060c:	000aa403          	lw	s0,0(s5)
  800610:	b7ed                	j	8005fa <vprintfmt+0x2b4>
  800612:	000ae683          	lwu	a3,0(s5)
  800616:	4721                	li	a4,8
  800618:	8ab2                	mv	s5,a2
  80061a:	bd89                	j	80046c <vprintfmt+0x126>
  80061c:	000ae683          	lwu	a3,0(s5)
  800620:	4729                	li	a4,10
  800622:	8ab2                	mv	s5,a2
  800624:	b5a1                	j	80046c <vprintfmt+0x126>
  800626:	000ae683          	lwu	a3,0(s5)
  80062a:	4741                	li	a4,16
  80062c:	8ab2                	mv	s5,a2
  80062e:	bd3d                	j	80046c <vprintfmt+0x126>
  800630:	864e                	mv	a2,s3
  800632:	85ca                	mv	a1,s2
  800634:	02d00513          	li	a0,45
  800638:	e042                	sd	a6,0(sp)
  80063a:	9482                	jalr	s1
  80063c:	6802                	ld	a6,0(sp)
  80063e:	408006b3          	neg	a3,s0
  800642:	8ae2                	mv	s5,s8
  800644:	4729                	li	a4,10
  800646:	b51d                	j	80046c <vprintfmt+0x126>
  800648:	eba1                	bnez	a5,800698 <vprintfmt+0x352>
  80064a:	02800793          	li	a5,40
  80064e:	853e                	mv	a0,a5
  800650:	00000a97          	auipc	s5,0x0
  800654:	321a8a93          	addi	s5,s5,801 # 800971 <main+0x291>
  800658:	547d                	li	s0,-1
  80065a:	bdf1                	j	800536 <vprintfmt+0x1f0>
  80065c:	853a                	mv	a0,a4
  80065e:	85ea                	mv	a1,s10
  800660:	e03a                	sd	a4,0(sp)
  800662:	c47ff0ef          	jal	8002a8 <strnlen>
  800666:	40ad8dbb          	subw	s11,s11,a0
  80066a:	6702                	ld	a4,0(sp)
  80066c:	01b05b63          	blez	s11,800682 <vprintfmt+0x33c>
  800670:	864e                	mv	a2,s3
  800672:	85ca                	mv	a1,s2
  800674:	8522                	mv	a0,s0
  800676:	e03a                	sd	a4,0(sp)
  800678:	3dfd                	addiw	s11,s11,-1
  80067a:	9482                	jalr	s1
  80067c:	6702                	ld	a4,0(sp)
  80067e:	fe0d99e3          	bnez	s11,800670 <vprintfmt+0x32a>
  800682:	00074783          	lbu	a5,0(a4)
  800686:	0007851b          	sext.w	a0,a5
  80068a:	ee0781e3          	beqz	a5,80056c <vprintfmt+0x226>
  80068e:	00170a93          	addi	s5,a4,1
  800692:	b54d                	j	800534 <vprintfmt+0x1ee>
  800694:	8466                	mv	s0,s9
  800696:	b36d                	j	800440 <vprintfmt+0xfa>
  800698:	85ea                	mv	a1,s10
  80069a:	00000517          	auipc	a0,0x0
  80069e:	2d650513          	addi	a0,a0,726 # 800970 <main+0x290>
  8006a2:	c07ff0ef          	jal	8002a8 <strnlen>
  8006a6:	40ad8dbb          	subw	s11,s11,a0
  8006aa:	02800793          	li	a5,40
  8006ae:	00000717          	auipc	a4,0x0
  8006b2:	2c270713          	addi	a4,a4,706 # 800970 <main+0x290>
  8006b6:	853e                	mv	a0,a5
  8006b8:	fbb04ce3          	bgtz	s11,800670 <vprintfmt+0x32a>
  8006bc:	00170a93          	addi	s5,a4,1
  8006c0:	bd95                	j	800534 <vprintfmt+0x1ee>

00000000008006c2 <printfmt>:
  8006c2:	7139                	addi	sp,sp,-64
  8006c4:	02010313          	addi	t1,sp,32
  8006c8:	f03a                	sd	a4,32(sp)
  8006ca:	871a                	mv	a4,t1
  8006cc:	ec06                	sd	ra,24(sp)
  8006ce:	f43e                	sd	a5,40(sp)
  8006d0:	f842                	sd	a6,48(sp)
  8006d2:	fc46                	sd	a7,56(sp)
  8006d4:	e41a                	sd	t1,8(sp)
  8006d6:	c71ff0ef          	jal	800346 <vprintfmt>
  8006da:	60e2                	ld	ra,24(sp)
  8006dc:	6121                	addi	sp,sp,64
  8006de:	8082                	ret

00000000008006e0 <main>:
  8006e0:	715d                	addi	sp,sp,-80
  8006e2:	4651                	li	a2,20
  8006e4:	4581                	li	a1,0
  8006e6:	00001517          	auipc	a0,0x1
  8006ea:	91a50513          	addi	a0,a0,-1766 # 801000 <pids>
  8006ee:	e486                	sd	ra,72(sp)
  8006f0:	e0a2                	sd	s0,64(sp)
  8006f2:	fc26                	sd	s1,56(sp)
  8006f4:	f84a                	sd	s2,48(sp)
  8006f6:	f44e                	sd	s3,40(sp)
  8006f8:	f052                	sd	s4,32(sp)
  8006fa:	ec56                	sd	s5,24(sp)
  8006fc:	bc9ff0ef          	jal	8002c4 <memset>
  800700:	4519                	li	a0,6
  800702:	00001a97          	auipc	s5,0x1
  800706:	92ea8a93          	addi	s5,s5,-1746 # 801030 <acc>
  80070a:	00001497          	auipc	s1,0x1
  80070e:	8f648493          	addi	s1,s1,-1802 # 801000 <pids>
  800712:	a53ff0ef          	jal	800164 <lab6_set_priority>
  800716:	89d6                	mv	s3,s5
  800718:	8926                	mv	s2,s1
  80071a:	4401                	li	s0,0
  80071c:	4a15                	li	s4,5
  80071e:	0009a023          	sw	zero,0(s3)
  800722:	a1fff0ef          	jal	800140 <fork>
  800726:	00a92023          	sw	a0,0(s2)
  80072a:	c561                	beqz	a0,8007f2 <main+0x112>
  80072c:	12054863          	bltz	a0,80085c <main+0x17c>
  800730:	2405                	addiw	s0,s0,1
  800732:	0991                	addi	s3,s3,4
  800734:	0911                	addi	s2,s2,4
  800736:	ff4414e3          	bne	s0,s4,80071e <main+0x3e>
  80073a:	00000517          	auipc	a0,0x0
  80073e:	44e50513          	addi	a0,a0,1102 # 800b88 <main+0x4a8>
  800742:	00001917          	auipc	s2,0x1
  800746:	8d690913          	addi	s2,s2,-1834 # 801018 <status>
  80074a:	a6fff0ef          	jal	8001b8 <cprintf>
  80074e:	844a                	mv	s0,s2
  800750:	00001997          	auipc	s3,0x1
  800754:	8dc98993          	addi	s3,s3,-1828 # 80102c <status+0x14>
  800758:	4088                	lw	a0,0(s1)
  80075a:	85a2                	mv	a1,s0
  80075c:	00042023          	sw	zero,0(s0)
  800760:	9e3ff0ef          	jal	800142 <waitpid>
  800764:	0004aa03          	lw	s4,0(s1)
  800768:	00042a83          	lw	s5,0(s0)
  80076c:	9f7ff0ef          	jal	800162 <gettime_msec>
  800770:	86aa                	mv	a3,a0
  800772:	8656                	mv	a2,s5
  800774:	85d2                	mv	a1,s4
  800776:	00000517          	auipc	a0,0x0
  80077a:	43a50513          	addi	a0,a0,1082 # 800bb0 <main+0x4d0>
  80077e:	0411                	addi	s0,s0,4
  800780:	a39ff0ef          	jal	8001b8 <cprintf>
  800784:	0491                	addi	s1,s1,4
  800786:	fd3419e3          	bne	s0,s3,800758 <main+0x78>
  80078a:	00000517          	auipc	a0,0x0
  80078e:	44650513          	addi	a0,a0,1094 # 800bd0 <main+0x4f0>
  800792:	a27ff0ef          	jal	8001b8 <cprintf>
  800796:	00000517          	auipc	a0,0x0
  80079a:	45250513          	addi	a0,a0,1106 # 800be8 <main+0x508>
  80079e:	a1bff0ef          	jal	8001b8 <cprintf>
  8007a2:	00092783          	lw	a5,0(s2)
  8007a6:	00001717          	auipc	a4,0x1
  8007aa:	87272703          	lw	a4,-1934(a4) # 801018 <status>
  8007ae:	00000517          	auipc	a0,0x0
  8007b2:	45a50513          	addi	a0,a0,1114 # 800c08 <main+0x528>
  8007b6:	0017979b          	slliw	a5,a5,0x1
  8007ba:	02e7c7bb          	divw	a5,a5,a4
  8007be:	0911                	addi	s2,s2,4
  8007c0:	2785                	addiw	a5,a5,1
  8007c2:	01f7d59b          	srliw	a1,a5,0x1f
  8007c6:	9dbd                	addw	a1,a1,a5
  8007c8:	8585                	srai	a1,a1,0x1
  8007ca:	9efff0ef          	jal	8001b8 <cprintf>
  8007ce:	fd391ae3          	bne	s2,s3,8007a2 <main+0xc2>
  8007d2:	00000517          	auipc	a0,0x0
  8007d6:	0de50513          	addi	a0,a0,222 # 8008b0 <main+0x1d0>
  8007da:	9dfff0ef          	jal	8001b8 <cprintf>
  8007de:	60a6                	ld	ra,72(sp)
  8007e0:	6406                	ld	s0,64(sp)
  8007e2:	74e2                	ld	s1,56(sp)
  8007e4:	7942                	ld	s2,48(sp)
  8007e6:	79a2                	ld	s3,40(sp)
  8007e8:	7a02                	ld	s4,32(sp)
  8007ea:	6ae2                	ld	s5,24(sp)
  8007ec:	4501                	li	a0,0
  8007ee:	6161                	addi	sp,sp,80
  8007f0:	8082                	ret
  8007f2:	0014051b          	addiw	a0,s0,1
  8007f6:	040a                	slli	s0,s0,0x2
  8007f8:	9aa2                	add	s5,s5,s0
  8007fa:	6489                	lui	s1,0x2
  8007fc:	6405                	lui	s0,0x1
  8007fe:	967ff0ef          	jal	800164 <lab6_set_priority>
  800802:	fa04041b          	addiw	s0,s0,-96 # fa0 <__panic-0x7ff080>
  800806:	000aa023          	sw	zero,0(s5)
  80080a:	71048493          	addi	s1,s1,1808 # 2710 <__panic-0x7fd910>
  80080e:	000aa683          	lw	a3,0(s5)
  800812:	2685                	addiw	a3,a3,1
  800814:	0c800713          	li	a4,200
  800818:	47b2                	lw	a5,12(sp)
  80081a:	377d                	addiw	a4,a4,-1
  80081c:	0017b793          	seqz	a5,a5
  800820:	c63e                	sw	a5,12(sp)
  800822:	fb7d                	bnez	a4,800818 <main+0x138>
  800824:	0286f7bb          	remuw	a5,a3,s0
  800828:	c399                	beqz	a5,80082e <main+0x14e>
  80082a:	2685                	addiw	a3,a3,1
  80082c:	b7e5                	j	800814 <main+0x134>
  80082e:	00daa023          	sw	a3,0(s5)
  800832:	931ff0ef          	jal	800162 <gettime_msec>
  800836:	892a                	mv	s2,a0
  800838:	fca4dbe3          	bge	s1,a0,80080e <main+0x12e>
  80083c:	925ff0ef          	jal	800160 <getpid>
  800840:	000aa603          	lw	a2,0(s5)
  800844:	85aa                	mv	a1,a0
  800846:	86ca                	mv	a3,s2
  800848:	00000517          	auipc	a0,0x0
  80084c:	32050513          	addi	a0,a0,800 # 800b68 <main+0x488>
  800850:	969ff0ef          	jal	8001b8 <cprintf>
  800854:	000aa503          	lw	a0,0(s5)
  800858:	8d3ff0ef          	jal	80012a <exit>
  80085c:	00000417          	auipc	s0,0x0
  800860:	7b840413          	addi	s0,s0,1976 # 801014 <pids+0x14>
  800864:	4088                	lw	a0,0(s1)
  800866:	00a05463          	blez	a0,80086e <main+0x18e>
  80086a:	8f5ff0ef          	jal	80015e <kill>
  80086e:	0491                	addi	s1,s1,4
  800870:	fe849ae3          	bne	s1,s0,800864 <main+0x184>
  800874:	00000617          	auipc	a2,0x0
  800878:	39c60613          	addi	a2,a2,924 # 800c10 <main+0x530>
  80087c:	04b00593          	li	a1,75
  800880:	00000517          	auipc	a0,0x0
  800884:	3a050513          	addi	a0,a0,928 # 800c20 <main+0x540>
  800888:	f98ff0ef          	jal	800020 <__panic>
