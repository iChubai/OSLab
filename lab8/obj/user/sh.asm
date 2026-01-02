
obj/__user_sh.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	02810313          	addi	t1,sp,40
  800026:	e822                	sd	s0,16(sp)
  800028:	8432                	mv	s0,a2
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00001517          	auipc	a0,0x1
  800032:	d4a50513          	addi	a0,a0,-694 # 800d78 <main+0xc8>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	fc3e                	sd	a5,56(sp)
  80003e:	e0c2                	sd	a6,64(sp)
  800040:	e4c6                	sd	a7,72(sp)
  800042:	e41a                	sd	t1,8(sp)
  800044:	1ba000ef          	jal	8001fe <cprintf>
  800048:	65a2                	ld	a1,8(sp)
  80004a:	8522                	mv	a0,s0
  80004c:	18c000ef          	jal	8001d8 <vcprintf>
  800050:	00001517          	auipc	a0,0x1
  800054:	d4850513          	addi	a0,a0,-696 # 800d98 <main+0xe8>
  800058:	1a6000ef          	jal	8001fe <cprintf>
  80005c:	5559                	li	a0,-10
  80005e:	0d8000ef          	jal	800136 <exit>

0000000000800062 <__warn>:
  800062:	715d                	addi	sp,sp,-80
  800064:	e822                	sd	s0,16(sp)
  800066:	02810313          	addi	t1,sp,40
  80006a:	8432                	mv	s0,a2
  80006c:	862e                	mv	a2,a1
  80006e:	85aa                	mv	a1,a0
  800070:	00001517          	auipc	a0,0x1
  800074:	d3050513          	addi	a0,a0,-720 # 800da0 <main+0xf0>
  800078:	ec06                	sd	ra,24(sp)
  80007a:	f436                	sd	a3,40(sp)
  80007c:	f83a                	sd	a4,48(sp)
  80007e:	fc3e                	sd	a5,56(sp)
  800080:	e0c2                	sd	a6,64(sp)
  800082:	e4c6                	sd	a7,72(sp)
  800084:	e41a                	sd	t1,8(sp)
  800086:	178000ef          	jal	8001fe <cprintf>
  80008a:	65a2                	ld	a1,8(sp)
  80008c:	8522                	mv	a0,s0
  80008e:	14a000ef          	jal	8001d8 <vcprintf>
  800092:	00001517          	auipc	a0,0x1
  800096:	d0650513          	addi	a0,a0,-762 # 800d98 <main+0xe8>
  80009a:	164000ef          	jal	8001fe <cprintf>
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

00000000008000f8 <sys_exec>:
  8000f8:	86b2                	mv	a3,a2
  8000fa:	862e                	mv	a2,a1
  8000fc:	85aa                	mv	a1,a0
  8000fe:	4511                	li	a0,4
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

0000000000800114 <sys_read>:
  800114:	86b2                	mv	a3,a2
  800116:	862e                	mv	a2,a1
  800118:	85aa                	mv	a1,a0
  80011a:	06600513          	li	a0,102
  80011e:	b761                	j	8000a6 <syscall>

0000000000800120 <sys_write>:
  800120:	86b2                	mv	a3,a2
  800122:	862e                	mv	a2,a1
  800124:	85aa                	mv	a1,a0
  800126:	06700513          	li	a0,103
  80012a:	bfb5                	j	8000a6 <syscall>

000000000080012c <sys_dup>:
  80012c:	862e                	mv	a2,a1
  80012e:	85aa                	mv	a1,a0
  800130:	08200513          	li	a0,130
  800134:	bf8d                	j	8000a6 <syscall>

0000000000800136 <exit>:
  800136:	1141                	addi	sp,sp,-16
  800138:	e406                	sd	ra,8(sp)
  80013a:	fa7ff0ef          	jal	8000e0 <sys_exit>
  80013e:	00001517          	auipc	a0,0x1
  800142:	c8250513          	addi	a0,a0,-894 # 800dc0 <main+0x110>
  800146:	0b8000ef          	jal	8001fe <cprintf>
  80014a:	a001                	j	80014a <exit+0x14>

000000000080014c <fork>:
  80014c:	bf69                	j	8000e6 <sys_fork>

000000000080014e <waitpid>:
  80014e:	cd89                	beqz	a1,800168 <waitpid+0x1a>
  800150:	7179                	addi	sp,sp,-48
  800152:	e42e                	sd	a1,8(sp)
  800154:	082c                	addi	a1,sp,24
  800156:	f406                	sd	ra,40(sp)
  800158:	f93ff0ef          	jal	8000ea <sys_wait>
  80015c:	6762                	ld	a4,24(sp)
  80015e:	67a2                	ld	a5,8(sp)
  800160:	70a2                	ld	ra,40(sp)
  800162:	c398                	sw	a4,0(a5)
  800164:	6145                	addi	sp,sp,48
  800166:	8082                	ret
  800168:	b749                	j	8000ea <sys_wait>

000000000080016a <__exec>:
  80016a:	619c                	ld	a5,0(a1)
  80016c:	862e                	mv	a2,a1
  80016e:	cb91                	beqz	a5,800182 <__exec+0x18>
  800170:	00858793          	addi	a5,a1,8
  800174:	4701                	li	a4,0
  800176:	6394                	ld	a3,0(a5)
  800178:	07a1                	addi	a5,a5,8
  80017a:	2705                	addiw	a4,a4,1
  80017c:	feed                	bnez	a3,800176 <__exec+0xc>
  80017e:	85ba                	mv	a1,a4
  800180:	bfa5                	j	8000f8 <sys_exec>
  800182:	4581                	li	a1,0
  800184:	bf95                	j	8000f8 <sys_exec>

0000000000800186 <_start>:
  800186:	176000ef          	jal	8002fc <umain>
  80018a:	a001                	j	80018a <_start+0x4>

000000000080018c <open>:
  80018c:	1582                	slli	a1,a1,0x20
  80018e:	9181                	srli	a1,a1,0x20
  800190:	bf8d                	j	800102 <sys_open>

0000000000800192 <close>:
  800192:	bfad                	j	80010c <sys_close>

0000000000800194 <read>:
  800194:	b741                	j	800114 <sys_read>

0000000000800196 <write>:
  800196:	b769                	j	800120 <sys_write>

0000000000800198 <dup2>:
  800198:	bf51                	j	80012c <sys_dup>

000000000080019a <cputch>:
  80019a:	1101                	addi	sp,sp,-32
  80019c:	ec06                	sd	ra,24(sp)
  80019e:	e42e                	sd	a1,8(sp)
  8001a0:	f53ff0ef          	jal	8000f2 <sys_putc>
  8001a4:	65a2                	ld	a1,8(sp)
  8001a6:	60e2                	ld	ra,24(sp)
  8001a8:	419c                	lw	a5,0(a1)
  8001aa:	2785                	addiw	a5,a5,1
  8001ac:	c19c                	sw	a5,0(a1)
  8001ae:	6105                	addi	sp,sp,32
  8001b0:	8082                	ret

00000000008001b2 <fputch>:
  8001b2:	1101                	addi	sp,sp,-32
  8001b4:	e822                	sd	s0,16(sp)
  8001b6:	00a107a3          	sb	a0,15(sp)
  8001ba:	842e                	mv	s0,a1
  8001bc:	8532                	mv	a0,a2
  8001be:	00f10593          	addi	a1,sp,15
  8001c2:	4605                	li	a2,1
  8001c4:	ec06                	sd	ra,24(sp)
  8001c6:	fd1ff0ef          	jal	800196 <write>
  8001ca:	401c                	lw	a5,0(s0)
  8001cc:	60e2                	ld	ra,24(sp)
  8001ce:	2785                	addiw	a5,a5,1
  8001d0:	c01c                	sw	a5,0(s0)
  8001d2:	6442                	ld	s0,16(sp)
  8001d4:	6105                	addi	sp,sp,32
  8001d6:	8082                	ret

00000000008001d8 <vcprintf>:
  8001d8:	1101                	addi	sp,sp,-32
  8001da:	872e                	mv	a4,a1
  8001dc:	75dd                	lui	a1,0xffff7
  8001de:	86aa                	mv	a3,a0
  8001e0:	0070                	addi	a2,sp,12
  8001e2:	00000517          	auipc	a0,0x0
  8001e6:	fb850513          	addi	a0,a0,-72 # 80019a <cputch>
  8001ea:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <shcwd+0xffffffffff7f29d1>
  8001ee:	ec06                	sd	ra,24(sp)
  8001f0:	c602                	sw	zero,12(sp)
  8001f2:	27c000ef          	jal	80046e <vprintfmt>
  8001f6:	60e2                	ld	ra,24(sp)
  8001f8:	4532                	lw	a0,12(sp)
  8001fa:	6105                	addi	sp,sp,32
  8001fc:	8082                	ret

00000000008001fe <cprintf>:
  8001fe:	711d                	addi	sp,sp,-96
  800200:	02810313          	addi	t1,sp,40
  800204:	f42e                	sd	a1,40(sp)
  800206:	75dd                	lui	a1,0xffff7
  800208:	f832                	sd	a2,48(sp)
  80020a:	fc36                	sd	a3,56(sp)
  80020c:	e0ba                	sd	a4,64(sp)
  80020e:	86aa                	mv	a3,a0
  800210:	0050                	addi	a2,sp,4
  800212:	00000517          	auipc	a0,0x0
  800216:	f8850513          	addi	a0,a0,-120 # 80019a <cputch>
  80021a:	871a                	mv	a4,t1
  80021c:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <shcwd+0xffffffffff7f29d1>
  800220:	ec06                	sd	ra,24(sp)
  800222:	e4be                	sd	a5,72(sp)
  800224:	e8c2                	sd	a6,80(sp)
  800226:	ecc6                	sd	a7,88(sp)
  800228:	c202                	sw	zero,4(sp)
  80022a:	e41a                	sd	t1,8(sp)
  80022c:	242000ef          	jal	80046e <vprintfmt>
  800230:	60e2                	ld	ra,24(sp)
  800232:	4512                	lw	a0,4(sp)
  800234:	6125                	addi	sp,sp,96
  800236:	8082                	ret

0000000000800238 <cputs>:
  800238:	1101                	addi	sp,sp,-32
  80023a:	e822                	sd	s0,16(sp)
  80023c:	ec06                	sd	ra,24(sp)
  80023e:	842a                	mv	s0,a0
  800240:	00054503          	lbu	a0,0(a0)
  800244:	c51d                	beqz	a0,800272 <cputs+0x3a>
  800246:	e426                	sd	s1,8(sp)
  800248:	0405                	addi	s0,s0,1
  80024a:	4481                	li	s1,0
  80024c:	ea7ff0ef          	jal	8000f2 <sys_putc>
  800250:	00044503          	lbu	a0,0(s0)
  800254:	0405                	addi	s0,s0,1
  800256:	87a6                	mv	a5,s1
  800258:	2485                	addiw	s1,s1,1
  80025a:	f96d                	bnez	a0,80024c <cputs+0x14>
  80025c:	4529                	li	a0,10
  80025e:	0027841b          	addiw	s0,a5,2
  800262:	64a2                	ld	s1,8(sp)
  800264:	e8fff0ef          	jal	8000f2 <sys_putc>
  800268:	60e2                	ld	ra,24(sp)
  80026a:	8522                	mv	a0,s0
  80026c:	6442                	ld	s0,16(sp)
  80026e:	6105                	addi	sp,sp,32
  800270:	8082                	ret
  800272:	4529                	li	a0,10
  800274:	e7fff0ef          	jal	8000f2 <sys_putc>
  800278:	4405                	li	s0,1
  80027a:	60e2                	ld	ra,24(sp)
  80027c:	8522                	mv	a0,s0
  80027e:	6442                	ld	s0,16(sp)
  800280:	6105                	addi	sp,sp,32
  800282:	8082                	ret

0000000000800284 <fprintf>:
  800284:	715d                	addi	sp,sp,-80
  800286:	02010313          	addi	t1,sp,32
  80028a:	8e2e                	mv	t3,a1
  80028c:	f032                	sd	a2,32(sp)
  80028e:	f436                	sd	a3,40(sp)
  800290:	f83a                	sd	a4,48(sp)
  800292:	85aa                	mv	a1,a0
  800294:	0050                	addi	a2,sp,4
  800296:	00000517          	auipc	a0,0x0
  80029a:	f1c50513          	addi	a0,a0,-228 # 8001b2 <fputch>
  80029e:	86f2                	mv	a3,t3
  8002a0:	871a                	mv	a4,t1
  8002a2:	ec06                	sd	ra,24(sp)
  8002a4:	fc3e                	sd	a5,56(sp)
  8002a6:	e0c2                	sd	a6,64(sp)
  8002a8:	e4c6                	sd	a7,72(sp)
  8002aa:	c202                	sw	zero,4(sp)
  8002ac:	e41a                	sd	t1,8(sp)
  8002ae:	1c0000ef          	jal	80046e <vprintfmt>
  8002b2:	60e2                	ld	ra,24(sp)
  8002b4:	4512                	lw	a0,4(sp)
  8002b6:	6161                	addi	sp,sp,80
  8002b8:	8082                	ret

00000000008002ba <initfd>:
  8002ba:	87ae                	mv	a5,a1
  8002bc:	1101                	addi	sp,sp,-32
  8002be:	e822                	sd	s0,16(sp)
  8002c0:	85b2                	mv	a1,a2
  8002c2:	842a                	mv	s0,a0
  8002c4:	853e                	mv	a0,a5
  8002c6:	ec06                	sd	ra,24(sp)
  8002c8:	ec5ff0ef          	jal	80018c <open>
  8002cc:	87aa                	mv	a5,a0
  8002ce:	00054463          	bltz	a0,8002d6 <initfd+0x1c>
  8002d2:	00851763          	bne	a0,s0,8002e0 <initfd+0x26>
  8002d6:	60e2                	ld	ra,24(sp)
  8002d8:	6442                	ld	s0,16(sp)
  8002da:	853e                	mv	a0,a5
  8002dc:	6105                	addi	sp,sp,32
  8002de:	8082                	ret
  8002e0:	e42a                	sd	a0,8(sp)
  8002e2:	8522                	mv	a0,s0
  8002e4:	eafff0ef          	jal	800192 <close>
  8002e8:	6522                	ld	a0,8(sp)
  8002ea:	85a2                	mv	a1,s0
  8002ec:	eadff0ef          	jal	800198 <dup2>
  8002f0:	842a                	mv	s0,a0
  8002f2:	6522                	ld	a0,8(sp)
  8002f4:	e9fff0ef          	jal	800192 <close>
  8002f8:	87a2                	mv	a5,s0
  8002fa:	bff1                	j	8002d6 <initfd+0x1c>

00000000008002fc <umain>:
  8002fc:	1101                	addi	sp,sp,-32
  8002fe:	e822                	sd	s0,16(sp)
  800300:	e426                	sd	s1,8(sp)
  800302:	842a                	mv	s0,a0
  800304:	84ae                	mv	s1,a1
  800306:	4601                	li	a2,0
  800308:	00001597          	auipc	a1,0x1
  80030c:	ad058593          	addi	a1,a1,-1328 # 800dd8 <main+0x128>
  800310:	4501                	li	a0,0
  800312:	ec06                	sd	ra,24(sp)
  800314:	fa7ff0ef          	jal	8002ba <initfd>
  800318:	02054263          	bltz	a0,80033c <umain+0x40>
  80031c:	4605                	li	a2,1
  80031e:	8532                	mv	a0,a2
  800320:	00001597          	auipc	a1,0x1
  800324:	af858593          	addi	a1,a1,-1288 # 800e18 <main+0x168>
  800328:	f93ff0ef          	jal	8002ba <initfd>
  80032c:	02054563          	bltz	a0,800356 <umain+0x5a>
  800330:	85a6                	mv	a1,s1
  800332:	8522                	mv	a0,s0
  800334:	17d000ef          	jal	800cb0 <main>
  800338:	dffff0ef          	jal	800136 <exit>
  80033c:	86aa                	mv	a3,a0
  80033e:	00001617          	auipc	a2,0x1
  800342:	aa260613          	addi	a2,a2,-1374 # 800de0 <main+0x130>
  800346:	45e9                	li	a1,26
  800348:	00001517          	auipc	a0,0x1
  80034c:	ab850513          	addi	a0,a0,-1352 # 800e00 <main+0x150>
  800350:	d13ff0ef          	jal	800062 <__warn>
  800354:	b7e1                	j	80031c <umain+0x20>
  800356:	86aa                	mv	a3,a0
  800358:	00001617          	auipc	a2,0x1
  80035c:	ac860613          	addi	a2,a2,-1336 # 800e20 <main+0x170>
  800360:	45f5                	li	a1,29
  800362:	00001517          	auipc	a0,0x1
  800366:	a9e50513          	addi	a0,a0,-1378 # 800e00 <main+0x150>
  80036a:	cf9ff0ef          	jal	800062 <__warn>
  80036e:	b7c9                	j	800330 <umain+0x34>

0000000000800370 <strnlen>:
  800370:	4781                	li	a5,0
  800372:	e589                	bnez	a1,80037c <strnlen+0xc>
  800374:	a811                	j	800388 <strnlen+0x18>
  800376:	0785                	addi	a5,a5,1
  800378:	00f58863          	beq	a1,a5,800388 <strnlen+0x18>
  80037c:	00f50733          	add	a4,a0,a5
  800380:	00074703          	lbu	a4,0(a4)
  800384:	fb6d                	bnez	a4,800376 <strnlen+0x6>
  800386:	85be                	mv	a1,a5
  800388:	852e                	mv	a0,a1
  80038a:	8082                	ret

000000000080038c <strcpy>:
  80038c:	87aa                	mv	a5,a0
  80038e:	0005c703          	lbu	a4,0(a1)
  800392:	0585                	addi	a1,a1,1
  800394:	0785                	addi	a5,a5,1
  800396:	fee78fa3          	sb	a4,-1(a5)
  80039a:	fb75                	bnez	a4,80038e <strcpy+0x2>
  80039c:	8082                	ret

000000000080039e <strcmp>:
  80039e:	00054783          	lbu	a5,0(a0)
  8003a2:	e791                	bnez	a5,8003ae <strcmp+0x10>
  8003a4:	a01d                	j	8003ca <strcmp+0x2c>
  8003a6:	00054783          	lbu	a5,0(a0)
  8003aa:	cb99                	beqz	a5,8003c0 <strcmp+0x22>
  8003ac:	0585                	addi	a1,a1,1
  8003ae:	0005c703          	lbu	a4,0(a1)
  8003b2:	0505                	addi	a0,a0,1
  8003b4:	fef709e3          	beq	a4,a5,8003a6 <strcmp+0x8>
  8003b8:	0007851b          	sext.w	a0,a5
  8003bc:	9d19                	subw	a0,a0,a4
  8003be:	8082                	ret
  8003c0:	0015c703          	lbu	a4,1(a1)
  8003c4:	4501                	li	a0,0
  8003c6:	9d19                	subw	a0,a0,a4
  8003c8:	8082                	ret
  8003ca:	0005c703          	lbu	a4,0(a1)
  8003ce:	4501                	li	a0,0
  8003d0:	b7f5                	j	8003bc <strcmp+0x1e>

00000000008003d2 <strchr>:
  8003d2:	a021                	j	8003da <strchr+0x8>
  8003d4:	00f58763          	beq	a1,a5,8003e2 <strchr+0x10>
  8003d8:	0505                	addi	a0,a0,1
  8003da:	00054783          	lbu	a5,0(a0)
  8003de:	fbfd                	bnez	a5,8003d4 <strchr+0x2>
  8003e0:	4501                	li	a0,0
  8003e2:	8082                	ret

00000000008003e4 <printnum>:
  8003e4:	7139                	addi	sp,sp,-64
  8003e6:	02071893          	slli	a7,a4,0x20
  8003ea:	f822                	sd	s0,48(sp)
  8003ec:	f426                	sd	s1,40(sp)
  8003ee:	f04a                	sd	s2,32(sp)
  8003f0:	ec4e                	sd	s3,24(sp)
  8003f2:	e456                	sd	s5,8(sp)
  8003f4:	0208d893          	srli	a7,a7,0x20
  8003f8:	fc06                	sd	ra,56(sp)
  8003fa:	0316fab3          	remu	s5,a3,a7
  8003fe:	fff7841b          	addiw	s0,a5,-1
  800402:	84aa                	mv	s1,a0
  800404:	89ae                	mv	s3,a1
  800406:	8932                	mv	s2,a2
  800408:	0516f063          	bgeu	a3,a7,800448 <printnum+0x64>
  80040c:	e852                	sd	s4,16(sp)
  80040e:	4705                	li	a4,1
  800410:	8a42                	mv	s4,a6
  800412:	00f75863          	bge	a4,a5,800422 <printnum+0x3e>
  800416:	864e                	mv	a2,s3
  800418:	85ca                	mv	a1,s2
  80041a:	8552                	mv	a0,s4
  80041c:	347d                	addiw	s0,s0,-1
  80041e:	9482                	jalr	s1
  800420:	f87d                	bnez	s0,800416 <printnum+0x32>
  800422:	6a42                	ld	s4,16(sp)
  800424:	00001797          	auipc	a5,0x1
  800428:	a1c78793          	addi	a5,a5,-1508 # 800e40 <main+0x190>
  80042c:	97d6                	add	a5,a5,s5
  80042e:	7442                	ld	s0,48(sp)
  800430:	0007c503          	lbu	a0,0(a5)
  800434:	70e2                	ld	ra,56(sp)
  800436:	6aa2                	ld	s5,8(sp)
  800438:	864e                	mv	a2,s3
  80043a:	85ca                	mv	a1,s2
  80043c:	69e2                	ld	s3,24(sp)
  80043e:	7902                	ld	s2,32(sp)
  800440:	87a6                	mv	a5,s1
  800442:	74a2                	ld	s1,40(sp)
  800444:	6121                	addi	sp,sp,64
  800446:	8782                	jr	a5
  800448:	0316d6b3          	divu	a3,a3,a7
  80044c:	87a2                	mv	a5,s0
  80044e:	f97ff0ef          	jal	8003e4 <printnum>
  800452:	bfc9                	j	800424 <printnum+0x40>

0000000000800454 <sprintputch>:
  800454:	499c                	lw	a5,16(a1)
  800456:	6198                	ld	a4,0(a1)
  800458:	6594                	ld	a3,8(a1)
  80045a:	2785                	addiw	a5,a5,1
  80045c:	c99c                	sw	a5,16(a1)
  80045e:	00d77763          	bgeu	a4,a3,80046c <sprintputch+0x18>
  800462:	00170793          	addi	a5,a4,1
  800466:	e19c                	sd	a5,0(a1)
  800468:	00a70023          	sb	a0,0(a4)
  80046c:	8082                	ret

000000000080046e <vprintfmt>:
  80046e:	7119                	addi	sp,sp,-128
  800470:	f4a6                	sd	s1,104(sp)
  800472:	f0ca                	sd	s2,96(sp)
  800474:	ecce                	sd	s3,88(sp)
  800476:	e8d2                	sd	s4,80(sp)
  800478:	e4d6                	sd	s5,72(sp)
  80047a:	e0da                	sd	s6,64(sp)
  80047c:	fc5e                	sd	s7,56(sp)
  80047e:	f466                	sd	s9,40(sp)
  800480:	fc86                	sd	ra,120(sp)
  800482:	f8a2                	sd	s0,112(sp)
  800484:	f862                	sd	s8,48(sp)
  800486:	f06a                	sd	s10,32(sp)
  800488:	ec6e                	sd	s11,24(sp)
  80048a:	84aa                	mv	s1,a0
  80048c:	8cb6                	mv	s9,a3
  80048e:	8aba                	mv	s5,a4
  800490:	89ae                	mv	s3,a1
  800492:	8932                	mv	s2,a2
  800494:	02500a13          	li	s4,37
  800498:	05500b93          	li	s7,85
  80049c:	00001b17          	auipc	s6,0x1
  8004a0:	d18b0b13          	addi	s6,s6,-744 # 8011b4 <main+0x504>
  8004a4:	000cc503          	lbu	a0,0(s9)
  8004a8:	001c8413          	addi	s0,s9,1
  8004ac:	01450b63          	beq	a0,s4,8004c2 <vprintfmt+0x54>
  8004b0:	cd15                	beqz	a0,8004ec <vprintfmt+0x7e>
  8004b2:	864e                	mv	a2,s3
  8004b4:	85ca                	mv	a1,s2
  8004b6:	9482                	jalr	s1
  8004b8:	00044503          	lbu	a0,0(s0)
  8004bc:	0405                	addi	s0,s0,1
  8004be:	ff4519e3          	bne	a0,s4,8004b0 <vprintfmt+0x42>
  8004c2:	5d7d                	li	s10,-1
  8004c4:	8dea                	mv	s11,s10
  8004c6:	02000813          	li	a6,32
  8004ca:	4c01                	li	s8,0
  8004cc:	4581                	li	a1,0
  8004ce:	00044703          	lbu	a4,0(s0)
  8004d2:	00140c93          	addi	s9,s0,1
  8004d6:	fdd7061b          	addiw	a2,a4,-35
  8004da:	0ff67613          	zext.b	a2,a2
  8004de:	02cbe663          	bltu	s7,a2,80050a <vprintfmt+0x9c>
  8004e2:	060a                	slli	a2,a2,0x2
  8004e4:	965a                	add	a2,a2,s6
  8004e6:	421c                	lw	a5,0(a2)
  8004e8:	97da                	add	a5,a5,s6
  8004ea:	8782                	jr	a5
  8004ec:	70e6                	ld	ra,120(sp)
  8004ee:	7446                	ld	s0,112(sp)
  8004f0:	74a6                	ld	s1,104(sp)
  8004f2:	7906                	ld	s2,96(sp)
  8004f4:	69e6                	ld	s3,88(sp)
  8004f6:	6a46                	ld	s4,80(sp)
  8004f8:	6aa6                	ld	s5,72(sp)
  8004fa:	6b06                	ld	s6,64(sp)
  8004fc:	7be2                	ld	s7,56(sp)
  8004fe:	7c42                	ld	s8,48(sp)
  800500:	7ca2                	ld	s9,40(sp)
  800502:	7d02                	ld	s10,32(sp)
  800504:	6de2                	ld	s11,24(sp)
  800506:	6109                	addi	sp,sp,128
  800508:	8082                	ret
  80050a:	864e                	mv	a2,s3
  80050c:	85ca                	mv	a1,s2
  80050e:	02500513          	li	a0,37
  800512:	9482                	jalr	s1
  800514:	fff44783          	lbu	a5,-1(s0)
  800518:	02500713          	li	a4,37
  80051c:	8ca2                	mv	s9,s0
  80051e:	f8e783e3          	beq	a5,a4,8004a4 <vprintfmt+0x36>
  800522:	ffecc783          	lbu	a5,-2(s9)
  800526:	1cfd                	addi	s9,s9,-1
  800528:	fee79de3          	bne	a5,a4,800522 <vprintfmt+0xb4>
  80052c:	bfa5                	j	8004a4 <vprintfmt+0x36>
  80052e:	00144683          	lbu	a3,1(s0)
  800532:	4525                	li	a0,9
  800534:	fd070d1b          	addiw	s10,a4,-48
  800538:	fd06879b          	addiw	a5,a3,-48
  80053c:	28f56063          	bltu	a0,a5,8007bc <vprintfmt+0x34e>
  800540:	2681                	sext.w	a3,a3
  800542:	8466                	mv	s0,s9
  800544:	002d179b          	slliw	a5,s10,0x2
  800548:	00144703          	lbu	a4,1(s0)
  80054c:	01a787bb          	addw	a5,a5,s10
  800550:	0017979b          	slliw	a5,a5,0x1
  800554:	9fb5                	addw	a5,a5,a3
  800556:	fd07061b          	addiw	a2,a4,-48
  80055a:	0405                	addi	s0,s0,1
  80055c:	fd078d1b          	addiw	s10,a5,-48
  800560:	0007069b          	sext.w	a3,a4
  800564:	fec570e3          	bgeu	a0,a2,800544 <vprintfmt+0xd6>
  800568:	f60dd3e3          	bgez	s11,8004ce <vprintfmt+0x60>
  80056c:	8dea                	mv	s11,s10
  80056e:	5d7d                	li	s10,-1
  800570:	bfb9                	j	8004ce <vprintfmt+0x60>
  800572:	883a                	mv	a6,a4
  800574:	8466                	mv	s0,s9
  800576:	bfa1                	j	8004ce <vprintfmt+0x60>
  800578:	8466                	mv	s0,s9
  80057a:	4c05                	li	s8,1
  80057c:	bf89                	j	8004ce <vprintfmt+0x60>
  80057e:	4785                	li	a5,1
  800580:	008a8613          	addi	a2,s5,8
  800584:	00b7c463          	blt	a5,a1,80058c <vprintfmt+0x11e>
  800588:	1c058363          	beqz	a1,80074e <vprintfmt+0x2e0>
  80058c:	000ab683          	ld	a3,0(s5)
  800590:	4741                	li	a4,16
  800592:	8ab2                	mv	s5,a2
  800594:	2801                	sext.w	a6,a6
  800596:	87ee                	mv	a5,s11
  800598:	864a                	mv	a2,s2
  80059a:	85ce                	mv	a1,s3
  80059c:	8526                	mv	a0,s1
  80059e:	e47ff0ef          	jal	8003e4 <printnum>
  8005a2:	b709                	j	8004a4 <vprintfmt+0x36>
  8005a4:	000aa503          	lw	a0,0(s5)
  8005a8:	864e                	mv	a2,s3
  8005aa:	85ca                	mv	a1,s2
  8005ac:	9482                	jalr	s1
  8005ae:	0aa1                	addi	s5,s5,8
  8005b0:	bdd5                	j	8004a4 <vprintfmt+0x36>
  8005b2:	4785                	li	a5,1
  8005b4:	008a8613          	addi	a2,s5,8
  8005b8:	00b7c463          	blt	a5,a1,8005c0 <vprintfmt+0x152>
  8005bc:	18058463          	beqz	a1,800744 <vprintfmt+0x2d6>
  8005c0:	000ab683          	ld	a3,0(s5)
  8005c4:	4729                	li	a4,10
  8005c6:	8ab2                	mv	s5,a2
  8005c8:	b7f1                	j	800594 <vprintfmt+0x126>
  8005ca:	864e                	mv	a2,s3
  8005cc:	85ca                	mv	a1,s2
  8005ce:	03000513          	li	a0,48
  8005d2:	e042                	sd	a6,0(sp)
  8005d4:	9482                	jalr	s1
  8005d6:	864e                	mv	a2,s3
  8005d8:	85ca                	mv	a1,s2
  8005da:	07800513          	li	a0,120
  8005de:	9482                	jalr	s1
  8005e0:	000ab683          	ld	a3,0(s5)
  8005e4:	6802                	ld	a6,0(sp)
  8005e6:	4741                	li	a4,16
  8005e8:	0aa1                	addi	s5,s5,8
  8005ea:	b76d                	j	800594 <vprintfmt+0x126>
  8005ec:	864e                	mv	a2,s3
  8005ee:	85ca                	mv	a1,s2
  8005f0:	02500513          	li	a0,37
  8005f4:	9482                	jalr	s1
  8005f6:	b57d                	j	8004a4 <vprintfmt+0x36>
  8005f8:	000aad03          	lw	s10,0(s5)
  8005fc:	8466                	mv	s0,s9
  8005fe:	0aa1                	addi	s5,s5,8
  800600:	b7a5                	j	800568 <vprintfmt+0xfa>
  800602:	4785                	li	a5,1
  800604:	008a8613          	addi	a2,s5,8
  800608:	00b7c463          	blt	a5,a1,800610 <vprintfmt+0x1a2>
  80060c:	12058763          	beqz	a1,80073a <vprintfmt+0x2cc>
  800610:	000ab683          	ld	a3,0(s5)
  800614:	4721                	li	a4,8
  800616:	8ab2                	mv	s5,a2
  800618:	bfb5                	j	800594 <vprintfmt+0x126>
  80061a:	87ee                	mv	a5,s11
  80061c:	000dd363          	bgez	s11,800622 <vprintfmt+0x1b4>
  800620:	4781                	li	a5,0
  800622:	00078d9b          	sext.w	s11,a5
  800626:	8466                	mv	s0,s9
  800628:	b55d                	j	8004ce <vprintfmt+0x60>
  80062a:	0008041b          	sext.w	s0,a6
  80062e:	fd340793          	addi	a5,s0,-45
  800632:	01b02733          	sgtz	a4,s11
  800636:	00f037b3          	snez	a5,a5
  80063a:	8ff9                	and	a5,a5,a4
  80063c:	000ab703          	ld	a4,0(s5)
  800640:	008a8693          	addi	a3,s5,8
  800644:	e436                	sd	a3,8(sp)
  800646:	12070563          	beqz	a4,800770 <vprintfmt+0x302>
  80064a:	12079d63          	bnez	a5,800784 <vprintfmt+0x316>
  80064e:	00074783          	lbu	a5,0(a4)
  800652:	0007851b          	sext.w	a0,a5
  800656:	c78d                	beqz	a5,800680 <vprintfmt+0x212>
  800658:	00170a93          	addi	s5,a4,1
  80065c:	547d                	li	s0,-1
  80065e:	000d4563          	bltz	s10,800668 <vprintfmt+0x1fa>
  800662:	3d7d                	addiw	s10,s10,-1
  800664:	008d0e63          	beq	s10,s0,800680 <vprintfmt+0x212>
  800668:	020c1863          	bnez	s8,800698 <vprintfmt+0x22a>
  80066c:	864e                	mv	a2,s3
  80066e:	85ca                	mv	a1,s2
  800670:	9482                	jalr	s1
  800672:	000ac783          	lbu	a5,0(s5)
  800676:	0a85                	addi	s5,s5,1
  800678:	3dfd                	addiw	s11,s11,-1
  80067a:	0007851b          	sext.w	a0,a5
  80067e:	f3e5                	bnez	a5,80065e <vprintfmt+0x1f0>
  800680:	01b05a63          	blez	s11,800694 <vprintfmt+0x226>
  800684:	864e                	mv	a2,s3
  800686:	85ca                	mv	a1,s2
  800688:	02000513          	li	a0,32
  80068c:	3dfd                	addiw	s11,s11,-1
  80068e:	9482                	jalr	s1
  800690:	fe0d9ae3          	bnez	s11,800684 <vprintfmt+0x216>
  800694:	6aa2                	ld	s5,8(sp)
  800696:	b539                	j	8004a4 <vprintfmt+0x36>
  800698:	3781                	addiw	a5,a5,-32
  80069a:	05e00713          	li	a4,94
  80069e:	fcf777e3          	bgeu	a4,a5,80066c <vprintfmt+0x1fe>
  8006a2:	03f00513          	li	a0,63
  8006a6:	864e                	mv	a2,s3
  8006a8:	85ca                	mv	a1,s2
  8006aa:	9482                	jalr	s1
  8006ac:	000ac783          	lbu	a5,0(s5)
  8006b0:	0a85                	addi	s5,s5,1
  8006b2:	3dfd                	addiw	s11,s11,-1
  8006b4:	0007851b          	sext.w	a0,a5
  8006b8:	d7e1                	beqz	a5,800680 <vprintfmt+0x212>
  8006ba:	fa0d54e3          	bgez	s10,800662 <vprintfmt+0x1f4>
  8006be:	bfe9                	j	800698 <vprintfmt+0x22a>
  8006c0:	000aa783          	lw	a5,0(s5)
  8006c4:	46e1                	li	a3,24
  8006c6:	0aa1                	addi	s5,s5,8
  8006c8:	41f7d71b          	sraiw	a4,a5,0x1f
  8006cc:	8fb9                	xor	a5,a5,a4
  8006ce:	40e7873b          	subw	a4,a5,a4
  8006d2:	02e6c663          	blt	a3,a4,8006fe <vprintfmt+0x290>
  8006d6:	00001797          	auipc	a5,0x1
  8006da:	c3a78793          	addi	a5,a5,-966 # 801310 <error_string>
  8006de:	00371693          	slli	a3,a4,0x3
  8006e2:	97b6                	add	a5,a5,a3
  8006e4:	639c                	ld	a5,0(a5)
  8006e6:	cf81                	beqz	a5,8006fe <vprintfmt+0x290>
  8006e8:	873e                	mv	a4,a5
  8006ea:	00000697          	auipc	a3,0x0
  8006ee:	78668693          	addi	a3,a3,1926 # 800e70 <main+0x1c0>
  8006f2:	864a                	mv	a2,s2
  8006f4:	85ce                	mv	a1,s3
  8006f6:	8526                	mv	a0,s1
  8006f8:	0f2000ef          	jal	8007ea <printfmt>
  8006fc:	b365                	j	8004a4 <vprintfmt+0x36>
  8006fe:	00000697          	auipc	a3,0x0
  800702:	76268693          	addi	a3,a3,1890 # 800e60 <main+0x1b0>
  800706:	864a                	mv	a2,s2
  800708:	85ce                	mv	a1,s3
  80070a:	8526                	mv	a0,s1
  80070c:	0de000ef          	jal	8007ea <printfmt>
  800710:	bb51                	j	8004a4 <vprintfmt+0x36>
  800712:	4785                	li	a5,1
  800714:	008a8c13          	addi	s8,s5,8
  800718:	00b7c363          	blt	a5,a1,80071e <vprintfmt+0x2b0>
  80071c:	cd81                	beqz	a1,800734 <vprintfmt+0x2c6>
  80071e:	000ab403          	ld	s0,0(s5)
  800722:	02044b63          	bltz	s0,800758 <vprintfmt+0x2ea>
  800726:	86a2                	mv	a3,s0
  800728:	8ae2                	mv	s5,s8
  80072a:	4729                	li	a4,10
  80072c:	b5a5                	j	800594 <vprintfmt+0x126>
  80072e:	2585                	addiw	a1,a1,1
  800730:	8466                	mv	s0,s9
  800732:	bb71                	j	8004ce <vprintfmt+0x60>
  800734:	000aa403          	lw	s0,0(s5)
  800738:	b7ed                	j	800722 <vprintfmt+0x2b4>
  80073a:	000ae683          	lwu	a3,0(s5)
  80073e:	4721                	li	a4,8
  800740:	8ab2                	mv	s5,a2
  800742:	bd89                	j	800594 <vprintfmt+0x126>
  800744:	000ae683          	lwu	a3,0(s5)
  800748:	4729                	li	a4,10
  80074a:	8ab2                	mv	s5,a2
  80074c:	b5a1                	j	800594 <vprintfmt+0x126>
  80074e:	000ae683          	lwu	a3,0(s5)
  800752:	4741                	li	a4,16
  800754:	8ab2                	mv	s5,a2
  800756:	bd3d                	j	800594 <vprintfmt+0x126>
  800758:	864e                	mv	a2,s3
  80075a:	85ca                	mv	a1,s2
  80075c:	02d00513          	li	a0,45
  800760:	e042                	sd	a6,0(sp)
  800762:	9482                	jalr	s1
  800764:	6802                	ld	a6,0(sp)
  800766:	408006b3          	neg	a3,s0
  80076a:	8ae2                	mv	s5,s8
  80076c:	4729                	li	a4,10
  80076e:	b51d                	j	800594 <vprintfmt+0x126>
  800770:	eba1                	bnez	a5,8007c0 <vprintfmt+0x352>
  800772:	02800793          	li	a5,40
  800776:	853e                	mv	a0,a5
  800778:	00000a97          	auipc	s5,0x0
  80077c:	6e1a8a93          	addi	s5,s5,1761 # 800e59 <main+0x1a9>
  800780:	547d                	li	s0,-1
  800782:	bdf1                	j	80065e <vprintfmt+0x1f0>
  800784:	853a                	mv	a0,a4
  800786:	85ea                	mv	a1,s10
  800788:	e03a                	sd	a4,0(sp)
  80078a:	be7ff0ef          	jal	800370 <strnlen>
  80078e:	40ad8dbb          	subw	s11,s11,a0
  800792:	6702                	ld	a4,0(sp)
  800794:	01b05b63          	blez	s11,8007aa <vprintfmt+0x33c>
  800798:	864e                	mv	a2,s3
  80079a:	85ca                	mv	a1,s2
  80079c:	8522                	mv	a0,s0
  80079e:	e03a                	sd	a4,0(sp)
  8007a0:	3dfd                	addiw	s11,s11,-1
  8007a2:	9482                	jalr	s1
  8007a4:	6702                	ld	a4,0(sp)
  8007a6:	fe0d99e3          	bnez	s11,800798 <vprintfmt+0x32a>
  8007aa:	00074783          	lbu	a5,0(a4)
  8007ae:	0007851b          	sext.w	a0,a5
  8007b2:	ee0781e3          	beqz	a5,800694 <vprintfmt+0x226>
  8007b6:	00170a93          	addi	s5,a4,1
  8007ba:	b54d                	j	80065c <vprintfmt+0x1ee>
  8007bc:	8466                	mv	s0,s9
  8007be:	b36d                	j	800568 <vprintfmt+0xfa>
  8007c0:	85ea                	mv	a1,s10
  8007c2:	00000517          	auipc	a0,0x0
  8007c6:	69650513          	addi	a0,a0,1686 # 800e58 <main+0x1a8>
  8007ca:	ba7ff0ef          	jal	800370 <strnlen>
  8007ce:	40ad8dbb          	subw	s11,s11,a0
  8007d2:	02800793          	li	a5,40
  8007d6:	00000717          	auipc	a4,0x0
  8007da:	68270713          	addi	a4,a4,1666 # 800e58 <main+0x1a8>
  8007de:	853e                	mv	a0,a5
  8007e0:	fbb04ce3          	bgtz	s11,800798 <vprintfmt+0x32a>
  8007e4:	00170a93          	addi	s5,a4,1
  8007e8:	bd95                	j	80065c <vprintfmt+0x1ee>

00000000008007ea <printfmt>:
  8007ea:	7139                	addi	sp,sp,-64
  8007ec:	02010313          	addi	t1,sp,32
  8007f0:	f03a                	sd	a4,32(sp)
  8007f2:	871a                	mv	a4,t1
  8007f4:	ec06                	sd	ra,24(sp)
  8007f6:	f43e                	sd	a5,40(sp)
  8007f8:	f842                	sd	a6,48(sp)
  8007fa:	fc46                	sd	a7,56(sp)
  8007fc:	e41a                	sd	t1,8(sp)
  8007fe:	c71ff0ef          	jal	80046e <vprintfmt>
  800802:	60e2                	ld	ra,24(sp)
  800804:	6121                	addi	sp,sp,64
  800806:	8082                	ret

0000000000800808 <snprintf>:
  800808:	711d                	addi	sp,sp,-96
  80080a:	15fd                	addi	a1,a1,-1
  80080c:	95aa                	add	a1,a1,a0
  80080e:	03810313          	addi	t1,sp,56
  800812:	f406                	sd	ra,40(sp)
  800814:	e82e                	sd	a1,16(sp)
  800816:	e42a                	sd	a0,8(sp)
  800818:	fc36                	sd	a3,56(sp)
  80081a:	e0ba                	sd	a4,64(sp)
  80081c:	e4be                	sd	a5,72(sp)
  80081e:	e8c2                	sd	a6,80(sp)
  800820:	ecc6                	sd	a7,88(sp)
  800822:	cc02                	sw	zero,24(sp)
  800824:	e01a                	sd	t1,0(sp)
  800826:	c515                	beqz	a0,800852 <snprintf+0x4a>
  800828:	02a5e563          	bltu	a1,a0,800852 <snprintf+0x4a>
  80082c:	75dd                	lui	a1,0xffff7
  80082e:	86b2                	mv	a3,a2
  800830:	00000517          	auipc	a0,0x0
  800834:	c2450513          	addi	a0,a0,-988 # 800454 <sprintputch>
  800838:	871a                	mv	a4,t1
  80083a:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <shcwd+0xffffffffff7f29d1>
  80083e:	0030                	addi	a2,sp,8
  800840:	c2fff0ef          	jal	80046e <vprintfmt>
  800844:	67a2                	ld	a5,8(sp)
  800846:	00078023          	sb	zero,0(a5)
  80084a:	4562                	lw	a0,24(sp)
  80084c:	70a2                	ld	ra,40(sp)
  80084e:	6125                	addi	sp,sp,96
  800850:	8082                	ret
  800852:	5575                	li	a0,-3
  800854:	bfe5                	j	80084c <snprintf+0x44>

0000000000800856 <gettoken>:
  800856:	7139                	addi	sp,sp,-64
  800858:	f822                	sd	s0,48(sp)
  80085a:	6100                	ld	s0,0(a0)
  80085c:	fc06                	sd	ra,56(sp)
  80085e:	c815                	beqz	s0,800892 <gettoken+0x3c>
  800860:	f04a                	sd	s2,32(sp)
  800862:	ec4e                	sd	s3,24(sp)
  800864:	f426                	sd	s1,40(sp)
  800866:	892a                	mv	s2,a0
  800868:	89ae                	mv	s3,a1
  80086a:	a021                	j	800872 <gettoken+0x1c>
  80086c:	0405                	addi	s0,s0,1
  80086e:	fe040fa3          	sb	zero,-1(s0)
  800872:	00044583          	lbu	a1,0(s0)
  800876:	00000517          	auipc	a0,0x0
  80087a:	7da50513          	addi	a0,a0,2010 # 801050 <main+0x3a0>
  80087e:	b55ff0ef          	jal	8003d2 <strchr>
  800882:	84aa                	mv	s1,a0
  800884:	f565                	bnez	a0,80086c <gettoken+0x16>
  800886:	00044783          	lbu	a5,0(s0)
  80088a:	eb89                	bnez	a5,80089c <gettoken+0x46>
  80088c:	74a2                	ld	s1,40(sp)
  80088e:	7902                	ld	s2,32(sp)
  800890:	69e2                	ld	s3,24(sp)
  800892:	70e2                	ld	ra,56(sp)
  800894:	7442                	ld	s0,48(sp)
  800896:	4501                	li	a0,0
  800898:	6121                	addi	sp,sp,64
  80089a:	8082                	ret
  80089c:	0089b023          	sd	s0,0(s3)
  8008a0:	00044583          	lbu	a1,0(s0)
  8008a4:	00000517          	auipc	a0,0x0
  8008a8:	7b450513          	addi	a0,a0,1972 # 801058 <main+0x3a8>
  8008ac:	b27ff0ef          	jal	8003d2 <strchr>
  8008b0:	00044583          	lbu	a1,0(s0)
  8008b4:	c505                	beqz	a0,8008dc <gettoken+0x86>
  8008b6:	00144783          	lbu	a5,1(s0)
  8008ba:	0005851b          	sext.w	a0,a1
  8008be:	00040023          	sb	zero,0(s0)
  8008c2:	00140713          	addi	a4,s0,1
  8008c6:	c391                	beqz	a5,8008ca <gettoken+0x74>
  8008c8:	84ba                	mv	s1,a4
  8008ca:	70e2                	ld	ra,56(sp)
  8008cc:	7442                	ld	s0,48(sp)
  8008ce:	00993023          	sd	s1,0(s2)
  8008d2:	69e2                	ld	s3,24(sp)
  8008d4:	74a2                	ld	s1,40(sp)
  8008d6:	7902                	ld	s2,32(sp)
  8008d8:	6121                	addi	sp,sp,64
  8008da:	8082                	ret
  8008dc:	4701                	li	a4,0
  8008de:	02200693          	li	a3,34
  8008e2:	c185                	beqz	a1,800902 <gettoken+0xac>
  8008e4:	c31d                	beqz	a4,80090a <gettoken+0xb4>
  8008e6:	00044783          	lbu	a5,0(s0)
  8008ea:	00d79863          	bne	a5,a3,8008fa <gettoken+0xa4>
  8008ee:	02000793          	li	a5,32
  8008f2:	00f40023          	sb	a5,0(s0)
  8008f6:	00174713          	xori	a4,a4,1
  8008fa:	00144583          	lbu	a1,1(s0)
  8008fe:	0405                	addi	s0,s0,1
  800900:	f1f5                	bnez	a1,8008e4 <gettoken+0x8e>
  800902:	4481                	li	s1,0
  800904:	07700513          	li	a0,119
  800908:	b7c9                	j	8008ca <gettoken+0x74>
  80090a:	00000517          	auipc	a0,0x0
  80090e:	75650513          	addi	a0,a0,1878 # 801060 <main+0x3b0>
  800912:	e43a                	sd	a4,8(sp)
  800914:	abfff0ef          	jal	8003d2 <strchr>
  800918:	6722                	ld	a4,8(sp)
  80091a:	02200693          	li	a3,34
  80091e:	d561                	beqz	a0,8008e6 <gettoken+0x90>
  800920:	00044783          	lbu	a5,0(s0)
  800924:	8722                	mv	a4,s0
  800926:	07700513          	li	a0,119
  80092a:	bf71                	j	8008c6 <gettoken+0x70>

000000000080092c <readline>:
  80092c:	715d                	addi	sp,sp,-80
  80092e:	e486                	sd	ra,72(sp)
  800930:	e0a2                	sd	s0,64(sp)
  800932:	fc26                	sd	s1,56(sp)
  800934:	f84a                	sd	s2,48(sp)
  800936:	f44e                	sd	s3,40(sp)
  800938:	f052                	sd	s4,32(sp)
  80093a:	ec56                	sd	s5,24(sp)
  80093c:	c909                	beqz	a0,80094e <readline+0x22>
  80093e:	862a                	mv	a2,a0
  800940:	00000597          	auipc	a1,0x0
  800944:	53058593          	addi	a1,a1,1328 # 800e70 <main+0x1c0>
  800948:	4505                	li	a0,1
  80094a:	93bff0ef          	jal	800284 <fprintf>
  80094e:	6985                	lui	s3,0x1
  800950:	19f9                	addi	s3,s3,-2 # ffe <__panic-0x7ff022>
  800952:	4401                	li	s0,0
  800954:	448d                	li	s1,3
  800956:	497d                	li	s2,31
  800958:	4a21                	li	s4,8
  80095a:	00002a97          	auipc	s5,0x2
  80095e:	7aea8a93          	addi	s5,s5,1966 # 803108 <buffer.2>
  800962:	4605                	li	a2,1
  800964:	00f10593          	addi	a1,sp,15
  800968:	4501                	li	a0,0
  80096a:	82bff0ef          	jal	800194 <read>
  80096e:	04054163          	bltz	a0,8009b0 <readline+0x84>
  800972:	c549                	beqz	a0,8009fc <readline+0xd0>
  800974:	00f14603          	lbu	a2,15(sp)
  800978:	02960c63          	beq	a2,s1,8009b0 <readline+0x84>
  80097c:	04c97463          	bgeu	s2,a2,8009c4 <readline+0x98>
  800980:	fe89c1e3          	blt	s3,s0,800962 <readline+0x36>
  800984:	00000597          	auipc	a1,0x0
  800988:	6ec58593          	addi	a1,a1,1772 # 801070 <main+0x3c0>
  80098c:	4505                	li	a0,1
  80098e:	8f7ff0ef          	jal	800284 <fprintf>
  800992:	00f14703          	lbu	a4,15(sp)
  800996:	008a87b3          	add	a5,s5,s0
  80099a:	4605                	li	a2,1
  80099c:	00f10593          	addi	a1,sp,15
  8009a0:	4501                	li	a0,0
  8009a2:	00e78023          	sb	a4,0(a5)
  8009a6:	2405                	addiw	s0,s0,1
  8009a8:	fecff0ef          	jal	800194 <read>
  8009ac:	fc0553e3          	bgez	a0,800972 <readline+0x46>
  8009b0:	4501                	li	a0,0
  8009b2:	60a6                	ld	ra,72(sp)
  8009b4:	6406                	ld	s0,64(sp)
  8009b6:	74e2                	ld	s1,56(sp)
  8009b8:	7942                	ld	s2,48(sp)
  8009ba:	79a2                	ld	s3,40(sp)
  8009bc:	7a02                	ld	s4,32(sp)
  8009be:	6ae2                	ld	s5,24(sp)
  8009c0:	6161                	addi	sp,sp,80
  8009c2:	8082                	ret
  8009c4:	01461d63          	bne	a2,s4,8009de <readline+0xb2>
  8009c8:	f8805de3          	blez	s0,800962 <readline+0x36>
  8009cc:	00000597          	auipc	a1,0x0
  8009d0:	6a458593          	addi	a1,a1,1700 # 801070 <main+0x3c0>
  8009d4:	4505                	li	a0,1
  8009d6:	8afff0ef          	jal	800284 <fprintf>
  8009da:	347d                	addiw	s0,s0,-1
  8009dc:	b759                	j	800962 <readline+0x36>
  8009de:	ff660793          	addi	a5,a2,-10
  8009e2:	2601                	sext.w	a2,a2
  8009e4:	c781                	beqz	a5,8009ec <readline+0xc0>
  8009e6:	ff360793          	addi	a5,a2,-13
  8009ea:	ffa5                	bnez	a5,800962 <readline+0x36>
  8009ec:	00000597          	auipc	a1,0x0
  8009f0:	68458593          	addi	a1,a1,1668 # 801070 <main+0x3c0>
  8009f4:	4505                	li	a0,1
  8009f6:	88fff0ef          	jal	800284 <fprintf>
  8009fa:	a019                	j	800a00 <readline+0xd4>
  8009fc:	fa805be3          	blez	s0,8009b2 <readline+0x86>
  800a00:	00002517          	auipc	a0,0x2
  800a04:	70850513          	addi	a0,a0,1800 # 803108 <buffer.2>
  800a08:	942a                	add	s0,s0,a0
  800a0a:	00040023          	sb	zero,0(s0)
  800a0e:	b755                	j	8009b2 <readline+0x86>

0000000000800a10 <reopen>:
  800a10:	7179                	addi	sp,sp,-48
  800a12:	f406                	sd	ra,40(sp)
  800a14:	f022                	sd	s0,32(sp)
  800a16:	ec26                	sd	s1,24(sp)
  800a18:	e432                	sd	a2,8(sp)
  800a1a:	84ae                	mv	s1,a1
  800a1c:	842a                	mv	s0,a0
  800a1e:	f74ff0ef          	jal	800192 <close>
  800a22:	65a2                	ld	a1,8(sp)
  800a24:	8526                	mv	a0,s1
  800a26:	f66ff0ef          	jal	80018c <open>
  800a2a:	87aa                	mv	a5,a0
  800a2c:	00a40763          	beq	s0,a0,800a3a <reopen+0x2a>
  800a30:	fff54713          	not	a4,a0
  800a34:	01f7571b          	srliw	a4,a4,0x1f
  800a38:	eb19                	bnez	a4,800a4e <reopen+0x3e>
  800a3a:	0007851b          	sext.w	a0,a5
  800a3e:	00f05363          	blez	a5,800a44 <reopen+0x34>
  800a42:	4501                	li	a0,0
  800a44:	70a2                	ld	ra,40(sp)
  800a46:	7402                	ld	s0,32(sp)
  800a48:	64e2                	ld	s1,24(sp)
  800a4a:	6145                	addi	sp,sp,48
  800a4c:	8082                	ret
  800a4e:	e42a                	sd	a0,8(sp)
  800a50:	8522                	mv	a0,s0
  800a52:	f40ff0ef          	jal	800192 <close>
  800a56:	6522                	ld	a0,8(sp)
  800a58:	85a2                	mv	a1,s0
  800a5a:	f3eff0ef          	jal	800198 <dup2>
  800a5e:	842a                	mv	s0,a0
  800a60:	6522                	ld	a0,8(sp)
  800a62:	f30ff0ef          	jal	800192 <close>
  800a66:	87a2                	mv	a5,s0
  800a68:	bfc9                	j	800a3a <reopen+0x2a>

0000000000800a6a <runcmd>:
  800a6a:	711d                	addi	sp,sp,-96
  800a6c:	e8a2                	sd	s0,80(sp)
  800a6e:	e0ca                	sd	s2,64(sp)
  800a70:	fc4e                	sd	s3,56(sp)
  800a72:	f852                	sd	s4,48(sp)
  800a74:	ec86                	sd	ra,88(sp)
  800a76:	e4a6                	sd	s1,72(sp)
  800a78:	e42a                	sd	a0,8(sp)
  800a7a:	03e00413          	li	s0,62
  800a7e:	07700a13          	li	s4,119
  800a82:	03b00913          	li	s2,59
  800a86:	03c00993          	li	s3,60
  800a8a:	4481                	li	s1,0
  800a8c:	082c                	addi	a1,sp,24
  800a8e:	0028                	addi	a0,sp,8
  800a90:	dc7ff0ef          	jal	800856 <gettoken>
  800a94:	0c850c63          	beq	a0,s0,800b6c <runcmd+0x102>
  800a98:	04a44163          	blt	s0,a0,800ada <runcmd+0x70>
  800a9c:	13250063          	beq	a0,s2,800bbc <runcmd+0x152>
  800aa0:	09350a63          	beq	a0,s3,800b34 <runcmd+0xca>
  800aa4:	e535                	bnez	a0,800b10 <runcmd+0xa6>
  800aa6:	c885                	beqz	s1,800ad6 <runcmd+0x6c>
  800aa8:	00002417          	auipc	s0,0x2
  800aac:	55840413          	addi	s0,s0,1368 # 803000 <argv.1>
  800ab0:	6008                	ld	a0,0(s0)
  800ab2:	00000597          	auipc	a1,0x0
  800ab6:	68e58593          	addi	a1,a1,1678 # 801140 <main+0x490>
  800aba:	8e5ff0ef          	jal	80039e <strcmp>
  800abe:	14051263          	bnez	a0,800c02 <runcmd+0x198>
  800ac2:	4789                	li	a5,2
  800ac4:	04f49e63          	bne	s1,a5,800b20 <runcmd+0xb6>
  800ac8:	640c                	ld	a1,8(s0)
  800aca:	00003517          	auipc	a0,0x3
  800ace:	63e50513          	addi	a0,a0,1598 # 804108 <shcwd>
  800ad2:	8bbff0ef          	jal	80038c <strcpy>
  800ad6:	4781                	li	a5,0
  800ad8:	a0a9                	j	800b22 <runcmd+0xb8>
  800ada:	0f450c63          	beq	a0,s4,800bd2 <runcmd+0x168>
  800ade:	07c00793          	li	a5,124
  800ae2:	02f51763          	bne	a0,a5,800b10 <runcmd+0xa6>
  800ae6:	e66ff0ef          	jal	80014c <fork>
  800aea:	87aa                	mv	a5,a0
  800aec:	18051f63          	bnez	a0,800c8a <runcmd+0x220>
  800af0:	ea2ff0ef          	jal	800192 <close>
  800af4:	4581                	li	a1,0
  800af6:	4501                	li	a0,0
  800af8:	ea0ff0ef          	jal	800198 <dup2>
  800afc:	87aa                	mv	a5,a0
  800afe:	02054263          	bltz	a0,800b22 <runcmd+0xb8>
  800b02:	4501                	li	a0,0
  800b04:	e8eff0ef          	jal	800192 <close>
  800b08:	4501                	li	a0,0
  800b0a:	e88ff0ef          	jal	800192 <close>
  800b0e:	bfb5                	j	800a8a <runcmd+0x20>
  800b10:	862a                	mv	a2,a0
  800b12:	00000597          	auipc	a1,0x0
  800b16:	60658593          	addi	a1,a1,1542 # 801118 <main+0x468>
  800b1a:	4505                	li	a0,1
  800b1c:	f68ff0ef          	jal	800284 <fprintf>
  800b20:	57fd                	li	a5,-1
  800b22:	60e6                	ld	ra,88(sp)
  800b24:	6446                	ld	s0,80(sp)
  800b26:	64a6                	ld	s1,72(sp)
  800b28:	6906                	ld	s2,64(sp)
  800b2a:	79e2                	ld	s3,56(sp)
  800b2c:	7a42                	ld	s4,48(sp)
  800b2e:	853e                	mv	a0,a5
  800b30:	6125                	addi	sp,sp,96
  800b32:	8082                	ret
  800b34:	082c                	addi	a1,sp,24
  800b36:	0028                	addi	a0,sp,8
  800b38:	d1fff0ef          	jal	800856 <gettoken>
  800b3c:	07700793          	li	a5,119
  800b40:	10f51d63          	bne	a0,a5,800c5a <runcmd+0x1f0>
  800b44:	f456                	sd	s5,40(sp)
  800b46:	6ae2                	ld	s5,24(sp)
  800b48:	4501                	li	a0,0
  800b4a:	e48ff0ef          	jal	800192 <close>
  800b4e:	8556                	mv	a0,s5
  800b50:	4581                	li	a1,0
  800b52:	e3aff0ef          	jal	80018c <open>
  800b56:	87aa                	mv	a5,a0
  800b58:	08054c63          	bltz	a0,800bf0 <runcmd+0x186>
  800b5c:	ed41                	bnez	a0,800bf4 <runcmd+0x18a>
  800b5e:	082c                	addi	a1,sp,24
  800b60:	0028                	addi	a0,sp,8
  800b62:	7aa2                	ld	s5,40(sp)
  800b64:	cf3ff0ef          	jal	800856 <gettoken>
  800b68:	f28518e3          	bne	a0,s0,800a98 <runcmd+0x2e>
  800b6c:	082c                	addi	a1,sp,24
  800b6e:	0028                	addi	a0,sp,8
  800b70:	ce7ff0ef          	jal	800856 <gettoken>
  800b74:	07700793          	li	a5,119
  800b78:	0ef51963          	bne	a0,a5,800c6a <runcmd+0x200>
  800b7c:	f456                	sd	s5,40(sp)
  800b7e:	6ae2                	ld	s5,24(sp)
  800b80:	4505                	li	a0,1
  800b82:	e10ff0ef          	jal	800192 <close>
  800b86:	8556                	mv	a0,s5
  800b88:	45d9                	li	a1,22
  800b8a:	e02ff0ef          	jal	80018c <open>
  800b8e:	87aa                	mv	a5,a0
  800b90:	06054063          	bltz	a0,800bf0 <runcmd+0x186>
  800b94:	4585                	li	a1,1
  800b96:	fcb504e3          	beq	a0,a1,800b5e <runcmd+0xf4>
  800b9a:	852e                	mv	a0,a1
  800b9c:	e03e                	sd	a5,0(sp)
  800b9e:	df4ff0ef          	jal	800192 <close>
  800ba2:	6502                	ld	a0,0(sp)
  800ba4:	4585                	li	a1,1
  800ba6:	df2ff0ef          	jal	800198 <dup2>
  800baa:	8aaa                	mv	s5,a0
  800bac:	6502                	ld	a0,0(sp)
  800bae:	de4ff0ef          	jal	800192 <close>
  800bb2:	fa0ad6e3          	bgez	s5,800b5e <runcmd+0xf4>
  800bb6:	87d6                	mv	a5,s5
  800bb8:	7aa2                	ld	s5,40(sp)
  800bba:	b7a5                	j	800b22 <runcmd+0xb8>
  800bbc:	d90ff0ef          	jal	80014c <fork>
  800bc0:	87aa                	mv	a5,a0
  800bc2:	ee0502e3          	beqz	a0,800aa6 <runcmd+0x3c>
  800bc6:	f4054ee3          	bltz	a0,800b22 <runcmd+0xb8>
  800bca:	4581                	li	a1,0
  800bcc:	d82ff0ef          	jal	80014e <waitpid>
  800bd0:	bd6d                	j	800a8a <runcmd+0x20>
  800bd2:	02000793          	li	a5,32
  800bd6:	0af48263          	beq	s1,a5,800c7a <runcmd+0x210>
  800bda:	6762                	ld	a4,24(sp)
  800bdc:	00349693          	slli	a3,s1,0x3
  800be0:	00002797          	auipc	a5,0x2
  800be4:	42078793          	addi	a5,a5,1056 # 803000 <argv.1>
  800be8:	97b6                	add	a5,a5,a3
  800bea:	2485                	addiw	s1,s1,1
  800bec:	e398                	sd	a4,0(a5)
  800bee:	bd79                	j	800a8c <runcmd+0x22>
  800bf0:	7aa2                	ld	s5,40(sp)
  800bf2:	bf05                	j	800b22 <runcmd+0xb8>
  800bf4:	4501                	li	a0,0
  800bf6:	e03e                	sd	a5,0(sp)
  800bf8:	d9aff0ef          	jal	800192 <close>
  800bfc:	6502                	ld	a0,0(sp)
  800bfe:	4581                	li	a1,0
  800c00:	b75d                	j	800ba6 <runcmd+0x13c>
  800c02:	6008                	ld	a0,0(s0)
  800c04:	4581                	li	a1,0
  800c06:	d86ff0ef          	jal	80018c <open>
  800c0a:	87aa                	mv	a5,a0
  800c0c:	02054263          	bltz	a0,800c30 <runcmd+0x1c6>
  800c10:	d82ff0ef          	jal	800192 <close>
  800c14:	00349793          	slli	a5,s1,0x3
  800c18:	97a2                	add	a5,a5,s0
  800c1a:	0007b023          	sd	zero,0(a5)
  800c1e:	6008                	ld	a0,0(s0)
  800c20:	00002597          	auipc	a1,0x2
  800c24:	3e058593          	addi	a1,a1,992 # 803000 <argv.1>
  800c28:	d42ff0ef          	jal	80016a <__exec>
  800c2c:	87aa                	mv	a5,a0
  800c2e:	bdd5                	j	800b22 <runcmd+0xb8>
  800c30:	5741                	li	a4,-16
  800c32:	eee518e3          	bne	a0,a4,800b22 <runcmd+0xb8>
  800c36:	6014                	ld	a3,0(s0)
  800c38:	00000617          	auipc	a2,0x0
  800c3c:	51060613          	addi	a2,a2,1296 # 801148 <main+0x498>
  800c40:	6585                	lui	a1,0x1
  800c42:	00001517          	auipc	a0,0x1
  800c46:	3be50513          	addi	a0,a0,958 # 802000 <argv0.0>
  800c4a:	bbfff0ef          	jal	800808 <snprintf>
  800c4e:	00001797          	auipc	a5,0x1
  800c52:	3b278793          	addi	a5,a5,946 # 802000 <argv0.0>
  800c56:	e01c                	sd	a5,0(s0)
  800c58:	bf75                	j	800c14 <runcmd+0x1aa>
  800c5a:	00000597          	auipc	a1,0x0
  800c5e:	45e58593          	addi	a1,a1,1118 # 8010b8 <main+0x408>
  800c62:	4505                	li	a0,1
  800c64:	e20ff0ef          	jal	800284 <fprintf>
  800c68:	bd65                	j	800b20 <runcmd+0xb6>
  800c6a:	00000597          	auipc	a1,0x0
  800c6e:	47e58593          	addi	a1,a1,1150 # 8010e8 <main+0x438>
  800c72:	4505                	li	a0,1
  800c74:	e10ff0ef          	jal	800284 <fprintf>
  800c78:	b565                	j	800b20 <runcmd+0xb6>
  800c7a:	00000597          	auipc	a1,0x0
  800c7e:	41e58593          	addi	a1,a1,1054 # 801098 <main+0x3e8>
  800c82:	4505                	li	a0,1
  800c84:	e00ff0ef          	jal	800284 <fprintf>
  800c88:	bd61                	j	800b20 <runcmd+0xb6>
  800c8a:	e8054ce3          	bltz	a0,800b22 <runcmd+0xb8>
  800c8e:	4505                	li	a0,1
  800c90:	d02ff0ef          	jal	800192 <close>
  800c94:	4585                	li	a1,1
  800c96:	4501                	li	a0,0
  800c98:	d00ff0ef          	jal	800198 <dup2>
  800c9c:	87aa                	mv	a5,a0
  800c9e:	e80542e3          	bltz	a0,800b22 <runcmd+0xb8>
  800ca2:	4501                	li	a0,0
  800ca4:	ceeff0ef          	jal	800192 <close>
  800ca8:	4501                	li	a0,0
  800caa:	ce8ff0ef          	jal	800192 <close>
  800cae:	bbe5                	j	800aa6 <runcmd+0x3c>

0000000000800cb0 <main>:
  800cb0:	7179                	addi	sp,sp,-48
  800cb2:	f022                	sd	s0,32(sp)
  800cb4:	842a                	mv	s0,a0
  800cb6:	00000517          	auipc	a0,0x0
  800cba:	49a50513          	addi	a0,a0,1178 # 801150 <main+0x4a0>
  800cbe:	ec26                	sd	s1,24(sp)
  800cc0:	f406                	sd	ra,40(sp)
  800cc2:	84ae                	mv	s1,a1
  800cc4:	d74ff0ef          	jal	800238 <cputs>
  800cc8:	4789                	li	a5,2
  800cca:	04f40c63          	beq	s0,a5,800d22 <main+0x72>
  800cce:	00000497          	auipc	s1,0x0
  800cd2:	4e248493          	addi	s1,s1,1250 # 8011b0 <main+0x500>
  800cd6:	0287d063          	bge	a5,s0,800cf6 <main+0x46>
  800cda:	a059                	j	800d60 <main+0xb0>
  800cdc:	00003797          	auipc	a5,0x3
  800ce0:	42078623          	sb	zero,1068(a5) # 804108 <shcwd>
  800ce4:	c68ff0ef          	jal	80014c <fork>
  800ce8:	c535                	beqz	a0,800d54 <main+0xa4>
  800cea:	04054563          	bltz	a0,800d34 <main+0x84>
  800cee:	006c                	addi	a1,sp,12
  800cf0:	c5eff0ef          	jal	80014e <waitpid>
  800cf4:	cd01                	beqz	a0,800d0c <main+0x5c>
  800cf6:	8526                	mv	a0,s1
  800cf8:	c35ff0ef          	jal	80092c <readline>
  800cfc:	842a                	mv	s0,a0
  800cfe:	fd79                	bnez	a0,800cdc <main+0x2c>
  800d00:	4501                	li	a0,0
  800d02:	70a2                	ld	ra,40(sp)
  800d04:	7402                	ld	s0,32(sp)
  800d06:	64e2                	ld	s1,24(sp)
  800d08:	6145                	addi	sp,sp,48
  800d0a:	8082                	ret
  800d0c:	46b2                	lw	a3,12(sp)
  800d0e:	d6e5                	beqz	a3,800cf6 <main+0x46>
  800d10:	8636                	mv	a2,a3
  800d12:	00000597          	auipc	a1,0x0
  800d16:	48e58593          	addi	a1,a1,1166 # 8011a0 <main+0x4f0>
  800d1a:	4505                	li	a0,1
  800d1c:	d68ff0ef          	jal	800284 <fprintf>
  800d20:	bfd9                	j	800cf6 <main+0x46>
  800d22:	648c                	ld	a1,8(s1)
  800d24:	4601                	li	a2,0
  800d26:	4501                	li	a0,0
  800d28:	ce9ff0ef          	jal	800a10 <reopen>
  800d2c:	c62a                	sw	a0,12(sp)
  800d2e:	4481                	li	s1,0
  800d30:	d179                	beqz	a0,800cf6 <main+0x46>
  800d32:	bfc1                	j	800d02 <main+0x52>
  800d34:	00000697          	auipc	a3,0x0
  800d38:	43468693          	addi	a3,a3,1076 # 801168 <main+0x4b8>
  800d3c:	00000617          	auipc	a2,0x0
  800d40:	43c60613          	addi	a2,a2,1084 # 801178 <main+0x4c8>
  800d44:	0f200593          	li	a1,242
  800d48:	00000517          	auipc	a0,0x0
  800d4c:	44850513          	addi	a0,a0,1096 # 801190 <main+0x4e0>
  800d50:	ad0ff0ef          	jal	800020 <__panic>
  800d54:	8522                	mv	a0,s0
  800d56:	d15ff0ef          	jal	800a6a <runcmd>
  800d5a:	c62a                	sw	a0,12(sp)
  800d5c:	bdaff0ef          	jal	800136 <exit>
  800d60:	00000597          	auipc	a1,0x0
  800d64:	31858593          	addi	a1,a1,792 # 801078 <main+0x3c8>
  800d68:	4505                	li	a0,1
  800d6a:	d1aff0ef          	jal	800284 <fprintf>
  800d6e:	557d                	li	a0,-1
  800d70:	bf49                	j	800d02 <main+0x52>
