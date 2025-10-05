
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00003117          	auipc	sp,0x3
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
#include <sbi.h>
int kern_init(void) __attribute__((noreturn));

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00003517          	auipc	a0,0x3
    8020000e:	ffe50513          	addi	a0,a0,-2 # 80203008 <edata>
    80200012:	00003617          	auipc	a2,0x3
    80200016:	ff660613          	addi	a2,a2,-10 # 80203008 <edata>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16 # 80202ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
    8020001c:	4581                	li	a1,0
    8020001e:	8e09                	sub	a2,a2,a0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	47a000ef          	jal	8020049c <memset>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    80200026:	00000597          	auipc	a1,0x0
    8020002a:	48a58593          	addi	a1,a1,1162 # 802004b0 <memset+0x14>
    8020002e:	00000517          	auipc	a0,0x0
    80200032:	4a250513          	addi	a0,a0,1186 # 802004d0 <memset+0x34>
    80200036:	020000ef          	jal	80200056 <cprintf>
   while (1)
    8020003a:	a001                	j	8020003a <kern_init+0x30>

000000008020003c <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    8020003c:	1141                	addi	sp,sp,-16
    8020003e:	e022                	sd	s0,0(sp)
    80200040:	e406                	sd	ra,8(sp)
    80200042:	842e                	mv	s0,a1
    cons_putc(c);
    80200044:	046000ef          	jal	8020008a <cons_putc>
    (*cnt)++;
    80200048:	401c                	lw	a5,0(s0)
}
    8020004a:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    8020004c:	2785                	addiw	a5,a5,1
    8020004e:	c01c                	sw	a5,0(s0)
}
    80200050:	6402                	ld	s0,0(sp)
    80200052:	0141                	addi	sp,sp,16
    80200054:	8082                	ret

0000000080200056 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200056:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200058:	02810313          	addi	t1,sp,40
int cprintf(const char *fmt, ...) {
    8020005c:	f42e                	sd	a1,40(sp)
    8020005e:	f832                	sd	a2,48(sp)
    80200060:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200062:	862a                	mv	a2,a0
    80200064:	004c                	addi	a1,sp,4
    80200066:	00000517          	auipc	a0,0x0
    8020006a:	fd650513          	addi	a0,a0,-42 # 8020003c <cputch>
    8020006e:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200070:	ec06                	sd	ra,24(sp)
    80200072:	e0ba                	sd	a4,64(sp)
    80200074:	e4be                	sd	a5,72(sp)
    80200076:	e8c2                	sd	a6,80(sp)
    80200078:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
    8020007a:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
    8020007c:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	080000ef          	jal	802000fe <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200082:	60e2                	ld	ra,24(sp)
    80200084:	4512                	lw	a0,4(sp)
    80200086:	6125                	addi	sp,sp,96
    80200088:	8082                	ret

000000008020008a <cons_putc>:

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020008a:	0ff57513          	zext.b	a0,a0
    8020008e:	aee1                	j	80200466 <sbi_console_putchar>

0000000080200090 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    80200090:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    80200094:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    80200096:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    8020009a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    8020009c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802000a0:	f022                	sd	s0,32(sp)
    802000a2:	ec26                	sd	s1,24(sp)
    802000a4:	e84a                	sd	s2,16(sp)
    802000a6:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802000a8:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
    802000ac:	84aa                	mv	s1,a0
    802000ae:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
    802000b0:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802000b2:	05067063          	bgeu	a2,a6,802000f2 <printnum+0x62>
    802000b6:	e44e                	sd	s3,8(sp)
    802000b8:	89be                	mv	s3,a5
        while (-- width > 0)
    802000ba:	4785                	li	a5,1
    802000bc:	00e7d763          	bge	a5,a4,802000ca <printnum+0x3a>
            putch(padc, putdat);
    802000c0:	85ca                	mv	a1,s2
    802000c2:	854e                	mv	a0,s3
        while (-- width > 0)
    802000c4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802000c6:	9482                	jalr	s1
        while (-- width > 0)
    802000c8:	fc65                	bnez	s0,802000c0 <printnum+0x30>
    802000ca:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802000cc:	1a02                	slli	s4,s4,0x20
    802000ce:	020a5a13          	srli	s4,s4,0x20
    802000d2:	00000797          	auipc	a5,0x0
    802000d6:	40678793          	addi	a5,a5,1030 # 802004d8 <memset+0x3c>
    802000da:	97d2                	add	a5,a5,s4
}
    802000dc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802000de:	0007c503          	lbu	a0,0(a5)
}
    802000e2:	70a2                	ld	ra,40(sp)
    802000e4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802000e6:	85ca                	mv	a1,s2
    802000e8:	87a6                	mv	a5,s1
}
    802000ea:	6942                	ld	s2,16(sp)
    802000ec:	64e2                	ld	s1,24(sp)
    802000ee:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    802000f0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    802000f2:	03065633          	divu	a2,a2,a6
    802000f6:	8722                	mv	a4,s0
    802000f8:	f99ff0ef          	jal	80200090 <printnum>
    802000fc:	bfc1                	j	802000cc <printnum+0x3c>

00000000802000fe <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    802000fe:	7119                	addi	sp,sp,-128
    80200100:	f4a6                	sd	s1,104(sp)
    80200102:	f0ca                	sd	s2,96(sp)
    80200104:	ecce                	sd	s3,88(sp)
    80200106:	e8d2                	sd	s4,80(sp)
    80200108:	e4d6                	sd	s5,72(sp)
    8020010a:	e0da                	sd	s6,64(sp)
    8020010c:	f862                	sd	s8,48(sp)
    8020010e:	fc86                	sd	ra,120(sp)
    80200110:	f8a2                	sd	s0,112(sp)
    80200112:	fc5e                	sd	s7,56(sp)
    80200114:	f466                	sd	s9,40(sp)
    80200116:	f06a                	sd	s10,32(sp)
    80200118:	ec6e                	sd	s11,24(sp)
    8020011a:	892a                	mv	s2,a0
    8020011c:	84ae                	mv	s1,a1
    8020011e:	8c32                	mv	s8,a2
    80200120:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200122:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200126:	05500b13          	li	s6,85
    8020012a:	00000a97          	auipc	s5,0x0
    8020012e:	462a8a93          	addi	s5,s5,1122 # 8020058c <memset+0xf0>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200132:	000c4503          	lbu	a0,0(s8)
    80200136:	001c0413          	addi	s0,s8,1
    8020013a:	01350a63          	beq	a0,s3,8020014e <vprintfmt+0x50>
            if (ch == '\0') {
    8020013e:	cd0d                	beqz	a0,80200178 <vprintfmt+0x7a>
            putch(ch, putdat);
    80200140:	85a6                	mv	a1,s1
    80200142:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200144:	00044503          	lbu	a0,0(s0)
    80200148:	0405                	addi	s0,s0,1
    8020014a:	ff351ae3          	bne	a0,s3,8020013e <vprintfmt+0x40>
        width = precision = -1;
    8020014e:	5cfd                	li	s9,-1
    80200150:	8d66                	mv	s10,s9
        char padc = ' ';
    80200152:	02000d93          	li	s11,32
        lflag = altflag = 0;
    80200156:	4b81                	li	s7,0
    80200158:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
    8020015a:	00044683          	lbu	a3,0(s0)
    8020015e:	00140c13          	addi	s8,s0,1
    80200162:	fdd6859b          	addiw	a1,a3,-35
    80200166:	0ff5f593          	zext.b	a1,a1
    8020016a:	02bb6663          	bltu	s6,a1,80200196 <vprintfmt+0x98>
    8020016e:	058a                	slli	a1,a1,0x2
    80200170:	95d6                	add	a1,a1,s5
    80200172:	4198                	lw	a4,0(a1)
    80200174:	9756                	add	a4,a4,s5
    80200176:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200178:	70e6                	ld	ra,120(sp)
    8020017a:	7446                	ld	s0,112(sp)
    8020017c:	74a6                	ld	s1,104(sp)
    8020017e:	7906                	ld	s2,96(sp)
    80200180:	69e6                	ld	s3,88(sp)
    80200182:	6a46                	ld	s4,80(sp)
    80200184:	6aa6                	ld	s5,72(sp)
    80200186:	6b06                	ld	s6,64(sp)
    80200188:	7be2                	ld	s7,56(sp)
    8020018a:	7c42                	ld	s8,48(sp)
    8020018c:	7ca2                	ld	s9,40(sp)
    8020018e:	7d02                	ld	s10,32(sp)
    80200190:	6de2                	ld	s11,24(sp)
    80200192:	6109                	addi	sp,sp,128
    80200194:	8082                	ret
            putch('%', putdat);
    80200196:	85a6                	mv	a1,s1
    80200198:	02500513          	li	a0,37
    8020019c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    8020019e:	fff44783          	lbu	a5,-1(s0)
    802001a2:	02500713          	li	a4,37
    802001a6:	8c22                	mv	s8,s0
    802001a8:	f8e785e3          	beq	a5,a4,80200132 <vprintfmt+0x34>
    802001ac:	ffec4783          	lbu	a5,-2(s8)
    802001b0:	1c7d                	addi	s8,s8,-1
    802001b2:	fee79de3          	bne	a5,a4,802001ac <vprintfmt+0xae>
    802001b6:	bfb5                	j	80200132 <vprintfmt+0x34>
                ch = *fmt;
    802001b8:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
    802001bc:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
    802001be:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
    802001c2:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
    802001c6:	8462                	mv	s0,s8
                ch = *fmt;
    802001c8:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
    802001ca:	02e56463          	bltu	a0,a4,802001f2 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
    802001ce:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
    802001d2:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
    802001d6:	0197073b          	addw	a4,a4,s9
    802001da:	0017171b          	slliw	a4,a4,0x1
    802001de:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
    802001e0:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
    802001e4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    802001e6:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    802001ea:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
    802001ee:	feb570e3          	bgeu	a0,a1,802001ce <vprintfmt+0xd0>
            if (width < 0)
    802001f2:	f60d54e3          	bgez	s10,8020015a <vprintfmt+0x5c>
                width = precision, precision = -1;
    802001f6:	8d66                	mv	s10,s9
    802001f8:	5cfd                	li	s9,-1
    802001fa:	b785                	j	8020015a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
    802001fc:	8db6                	mv	s11,a3
    802001fe:	8462                	mv	s0,s8
    80200200:	bfa9                	j	8020015a <vprintfmt+0x5c>
    80200202:	8462                	mv	s0,s8
            altflag = 1;
    80200204:	4b85                	li	s7,1
            goto reswitch;
    80200206:	bf91                	j	8020015a <vprintfmt+0x5c>
    if (lflag >= 2) {
    80200208:	4785                	li	a5,1
            precision = va_arg(ap, int);
    8020020a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    8020020e:	00c7c463          	blt	a5,a2,80200216 <vprintfmt+0x118>
    else if (lflag) {
    80200212:	18060763          	beqz	a2,802003a0 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
    80200216:	000a3603          	ld	a2,0(s4)
    8020021a:	46c1                	li	a3,16
    8020021c:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
    8020021e:	000d879b          	sext.w	a5,s11
    80200222:	876a                	mv	a4,s10
    80200224:	85a6                	mv	a1,s1
    80200226:	854a                	mv	a0,s2
    80200228:	e69ff0ef          	jal	80200090 <printnum>
            break;
    8020022c:	b719                	j	80200132 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
    8020022e:	000a2503          	lw	a0,0(s4)
    80200232:	85a6                	mv	a1,s1
    80200234:	0a21                	addi	s4,s4,8
    80200236:	9902                	jalr	s2
            break;
    80200238:	bded                	j	80200132 <vprintfmt+0x34>
    if (lflag >= 2) {
    8020023a:	4785                	li	a5,1
            precision = va_arg(ap, int);
    8020023c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200240:	00c7c463          	blt	a5,a2,80200248 <vprintfmt+0x14a>
    else if (lflag) {
    80200244:	14060963          	beqz	a2,80200396 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
    80200248:	000a3603          	ld	a2,0(s4)
    8020024c:	46a9                	li	a3,10
    8020024e:	8a3a                	mv	s4,a4
    80200250:	b7f9                	j	8020021e <vprintfmt+0x120>
            putch('0', putdat);
    80200252:	85a6                	mv	a1,s1
    80200254:	03000513          	li	a0,48
    80200258:	9902                	jalr	s2
            putch('x', putdat);
    8020025a:	85a6                	mv	a1,s1
    8020025c:	07800513          	li	a0,120
    80200260:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200262:	000a3603          	ld	a2,0(s4)
            goto number;
    80200266:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200268:	0a21                	addi	s4,s4,8
            goto number;
    8020026a:	bf55                	j	8020021e <vprintfmt+0x120>
            putch(ch, putdat);
    8020026c:	85a6                	mv	a1,s1
    8020026e:	02500513          	li	a0,37
    80200272:	9902                	jalr	s2
            break;
    80200274:	bd7d                	j	80200132 <vprintfmt+0x34>
            precision = va_arg(ap, int);
    80200276:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020027a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
    8020027c:	0a21                	addi	s4,s4,8
            goto process_precision;
    8020027e:	bf95                	j	802001f2 <vprintfmt+0xf4>
    if (lflag >= 2) {
    80200280:	4785                	li	a5,1
            precision = va_arg(ap, int);
    80200282:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200286:	00c7c463          	blt	a5,a2,8020028e <vprintfmt+0x190>
    else if (lflag) {
    8020028a:	10060163          	beqz	a2,8020038c <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
    8020028e:	000a3603          	ld	a2,0(s4)
    80200292:	46a1                	li	a3,8
    80200294:	8a3a                	mv	s4,a4
    80200296:	b761                	j	8020021e <vprintfmt+0x120>
            if (width < 0)
    80200298:	87ea                	mv	a5,s10
    8020029a:	000d5363          	bgez	s10,802002a0 <vprintfmt+0x1a2>
    8020029e:	4781                	li	a5,0
    802002a0:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
    802002a4:	8462                	mv	s0,s8
            goto reswitch;
    802002a6:	bd55                	j	8020015a <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
    802002a8:	000a3703          	ld	a4,0(s4)
    802002ac:	12070b63          	beqz	a4,802003e2 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
    802002b0:	0da05563          	blez	s10,8020037a <vprintfmt+0x27c>
    802002b4:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802002b8:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
    802002bc:	14fd9a63          	bne	s11,a5,80200410 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802002c0:	00074783          	lbu	a5,0(a4)
    802002c4:	0007851b          	sext.w	a0,a5
    802002c8:	c785                	beqz	a5,802002f0 <vprintfmt+0x1f2>
    802002ca:	5dfd                	li	s11,-1
    802002cc:	000cc563          	bltz	s9,802002d6 <vprintfmt+0x1d8>
    802002d0:	3cfd                	addiw	s9,s9,-1
    802002d2:	01bc8d63          	beq	s9,s11,802002ec <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
    802002d6:	0c0b9a63          	bnez	s7,802003aa <vprintfmt+0x2ac>
                    putch(ch, putdat);
    802002da:	85a6                	mv	a1,s1
    802002dc:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802002de:	00044783          	lbu	a5,0(s0)
    802002e2:	0405                	addi	s0,s0,1
    802002e4:	3d7d                	addiw	s10,s10,-1
    802002e6:	0007851b          	sext.w	a0,a5
    802002ea:	f3ed                	bnez	a5,802002cc <vprintfmt+0x1ce>
            for (; width > 0; width --) {
    802002ec:	01a05963          	blez	s10,802002fe <vprintfmt+0x200>
                putch(' ', putdat);
    802002f0:	85a6                	mv	a1,s1
    802002f2:	02000513          	li	a0,32
            for (; width > 0; width --) {
    802002f6:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
    802002f8:	9902                	jalr	s2
            for (; width > 0; width --) {
    802002fa:	fe0d1be3          	bnez	s10,802002f0 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
    802002fe:	0a21                	addi	s4,s4,8
    80200300:	bd0d                	j	80200132 <vprintfmt+0x34>
    if (lflag >= 2) {
    80200302:	4785                	li	a5,1
            precision = va_arg(ap, int);
    80200304:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
    80200308:	00c7c363          	blt	a5,a2,8020030e <vprintfmt+0x210>
    else if (lflag) {
    8020030c:	c625                	beqz	a2,80200374 <vprintfmt+0x276>
        return va_arg(*ap, long);
    8020030e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200312:	0a044f63          	bltz	s0,802003d0 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
    80200316:	8622                	mv	a2,s0
    80200318:	8a5e                	mv	s4,s7
    8020031a:	46a9                	li	a3,10
    8020031c:	b709                	j	8020021e <vprintfmt+0x120>
            if (err < 0) {
    8020031e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200322:	4619                	li	a2,6
            if (err < 0) {
    80200324:	41f7d71b          	sraiw	a4,a5,0x1f
    80200328:	8fb9                	xor	a5,a5,a4
    8020032a:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020032e:	02d64663          	blt	a2,a3,8020035a <vprintfmt+0x25c>
    80200332:	00000797          	auipc	a5,0x0
    80200336:	3b678793          	addi	a5,a5,950 # 802006e8 <error_string>
    8020033a:	00369713          	slli	a4,a3,0x3
    8020033e:	97ba                	add	a5,a5,a4
    80200340:	639c                	ld	a5,0(a5)
    80200342:	cf81                	beqz	a5,8020035a <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
    80200344:	86be                	mv	a3,a5
    80200346:	00000617          	auipc	a2,0x0
    8020034a:	1c260613          	addi	a2,a2,450 # 80200508 <memset+0x6c>
    8020034e:	85a6                	mv	a1,s1
    80200350:	854a                	mv	a0,s2
    80200352:	0f4000ef          	jal	80200446 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200356:	0a21                	addi	s4,s4,8
    80200358:	bbe9                	j	80200132 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
    8020035a:	00000617          	auipc	a2,0x0
    8020035e:	19e60613          	addi	a2,a2,414 # 802004f8 <memset+0x5c>
    80200362:	85a6                	mv	a1,s1
    80200364:	854a                	mv	a0,s2
    80200366:	0e0000ef          	jal	80200446 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020036a:	0a21                	addi	s4,s4,8
    8020036c:	b3d9                	j	80200132 <vprintfmt+0x34>
            lflag ++;
    8020036e:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200370:	8462                	mv	s0,s8
            goto reswitch;
    80200372:	b3e5                	j	8020015a <vprintfmt+0x5c>
        return va_arg(*ap, int);
    80200374:	000a2403          	lw	s0,0(s4)
    80200378:	bf69                	j	80200312 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020037a:	00074783          	lbu	a5,0(a4)
    8020037e:	0007851b          	sext.w	a0,a5
    80200382:	dfb5                	beqz	a5,802002fe <vprintfmt+0x200>
    80200384:	00170413          	addi	s0,a4,1
    80200388:	5dfd                	li	s11,-1
    8020038a:	b789                	j	802002cc <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
    8020038c:	000a6603          	lwu	a2,0(s4)
    80200390:	46a1                	li	a3,8
    80200392:	8a3a                	mv	s4,a4
    80200394:	b569                	j	8020021e <vprintfmt+0x120>
    80200396:	000a6603          	lwu	a2,0(s4)
    8020039a:	46a9                	li	a3,10
    8020039c:	8a3a                	mv	s4,a4
    8020039e:	b541                	j	8020021e <vprintfmt+0x120>
    802003a0:	000a6603          	lwu	a2,0(s4)
    802003a4:	46c1                	li	a3,16
    802003a6:	8a3a                	mv	s4,a4
    802003a8:	bd9d                	j	8020021e <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
    802003aa:	3781                	addiw	a5,a5,-32
    802003ac:	05e00713          	li	a4,94
    802003b0:	f2f775e3          	bgeu	a4,a5,802002da <vprintfmt+0x1dc>
                    putch('?', putdat);
    802003b4:	03f00513          	li	a0,63
    802003b8:	85a6                	mv	a1,s1
    802003ba:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802003bc:	00044783          	lbu	a5,0(s0)
    802003c0:	0405                	addi	s0,s0,1
    802003c2:	3d7d                	addiw	s10,s10,-1
    802003c4:	0007851b          	sext.w	a0,a5
    802003c8:	d395                	beqz	a5,802002ec <vprintfmt+0x1ee>
    802003ca:	f00cd3e3          	bgez	s9,802002d0 <vprintfmt+0x1d2>
    802003ce:	bff1                	j	802003aa <vprintfmt+0x2ac>
                putch('-', putdat);
    802003d0:	85a6                	mv	a1,s1
    802003d2:	02d00513          	li	a0,45
    802003d6:	9902                	jalr	s2
                num = -(long long)num;
    802003d8:	40800633          	neg	a2,s0
    802003dc:	8a5e                	mv	s4,s7
    802003de:	46a9                	li	a3,10
    802003e0:	bd3d                	j	8020021e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
    802003e2:	01a05663          	blez	s10,802003ee <vprintfmt+0x2f0>
    802003e6:	02d00793          	li	a5,45
    802003ea:	00fd9b63          	bne	s11,a5,80200400 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802003ee:	02800793          	li	a5,40
    802003f2:	853e                	mv	a0,a5
    802003f4:	00000417          	auipc	s0,0x0
    802003f8:	0fd40413          	addi	s0,s0,253 # 802004f1 <memset+0x55>
    802003fc:	5dfd                	li	s11,-1
    802003fe:	b5f9                	j	802002cc <vprintfmt+0x1ce>
    80200400:	00000417          	auipc	s0,0x0
    80200404:	0f140413          	addi	s0,s0,241 # 802004f1 <memset+0x55>
                p = "(null)";
    80200408:	00000717          	auipc	a4,0x0
    8020040c:	0e870713          	addi	a4,a4,232 # 802004f0 <memset+0x54>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200410:	853a                	mv	a0,a4
    80200412:	85e6                	mv	a1,s9
    80200414:	e43a                	sd	a4,8(sp)
    80200416:	06a000ef          	jal	80200480 <strnlen>
    8020041a:	40ad0d3b          	subw	s10,s10,a0
    8020041e:	6722                	ld	a4,8(sp)
    80200420:	01a05b63          	blez	s10,80200436 <vprintfmt+0x338>
                    putch(padc, putdat);
    80200424:	2d81                	sext.w	s11,s11
    80200426:	85a6                	mv	a1,s1
    80200428:	856e                	mv	a0,s11
    8020042a:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020042c:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
    8020042e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200430:	6722                	ld	a4,8(sp)
    80200432:	fe0d1ae3          	bnez	s10,80200426 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200436:	00074783          	lbu	a5,0(a4)
    8020043a:	0007851b          	sext.w	a0,a5
    8020043e:	ec0780e3          	beqz	a5,802002fe <vprintfmt+0x200>
    80200442:	5dfd                	li	s11,-1
    80200444:	b561                	j	802002cc <vprintfmt+0x1ce>

0000000080200446 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200446:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200448:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020044c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020044e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200450:	ec06                	sd	ra,24(sp)
    80200452:	f83a                	sd	a4,48(sp)
    80200454:	fc3e                	sd	a5,56(sp)
    80200456:	e0c2                	sd	a6,64(sp)
    80200458:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    8020045a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020045c:	ca3ff0ef          	jal	802000fe <vprintfmt>
}
    80200460:	60e2                	ld	ra,24(sp)
    80200462:	6161                	addi	sp,sp,80
    80200464:	8082                	ret

0000000080200466 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200466:	00003717          	auipc	a4,0x3
    8020046a:	b9a73703          	ld	a4,-1126(a4) # 80203000 <SBI_CONSOLE_PUTCHAR>
    8020046e:	4781                	li	a5,0
    80200470:	88ba                	mv	a7,a4
    80200472:	852a                	mv	a0,a0
    80200474:	85be                	mv	a1,a5
    80200476:	863e                	mv	a2,a5
    80200478:	00000073          	ecall
    8020047c:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    8020047e:	8082                	ret

0000000080200480 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200480:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200482:	e589                	bnez	a1,8020048c <strnlen+0xc>
    80200484:	a811                	j	80200498 <strnlen+0x18>
        cnt ++;
    80200486:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200488:	00f58863          	beq	a1,a5,80200498 <strnlen+0x18>
    8020048c:	00f50733          	add	a4,a0,a5
    80200490:	00074703          	lbu	a4,0(a4)
    80200494:	fb6d                	bnez	a4,80200486 <strnlen+0x6>
    80200496:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200498:	852e                	mv	a0,a1
    8020049a:	8082                	ret

000000008020049c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    8020049c:	ca01                	beqz	a2,802004ac <memset+0x10>
    8020049e:	962a                	add	a2,a2,a0
    char *p = s;
    802004a0:	87aa                	mv	a5,a0
        *p ++ = c;
    802004a2:	0785                	addi	a5,a5,1
    802004a4:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    802004a8:	fef61de3          	bne	a2,a5,802004a2 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    802004ac:	8082                	ret
